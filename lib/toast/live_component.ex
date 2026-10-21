defmodule Toast.LiveComponent do
  @moduledoc """
  The LiveComponent that manages toast notifications using Phoenix streams.

  This component is typically not used directly. Instead, use the `Toast.toast_group/1`
  function component which wraps this LiveComponent.

  ## State Management

  The component maintains toasts using LiveView streams, which provides:
  - Efficient DOM updates
  - Automatic animations via phx-update="stream"
  - Server-side state management

  ## Events

  The component handles the following events:
  - `"clear"` - Removes a specific toast by ID
  - `"clear-flash"` - Removes a flash message
  - `"clear-all"` - Removes all toasts
  - `"action"` - Handles toast action button clicks
  """

  use Phoenix.LiveComponent

  alias Toast.Components

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> stream(:toasts, [])
     |> assign(:toast_count, 0)
     |> assign(:max_toasts, nil)
     |> assign(:flash_messages, %{})
     |> assign(:flash_toast_keys, MapSet.new())}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(
        Map.take(assigns, [:position, :theme, :rich_colors, :max_toasts, :animation_duration])
      )

    # Only update flash messages if flash is explicitly provided in assigns
    socket =
      if Map.has_key?(assigns, :flash) do
        {toasts, flash} = Enum.split_with(assigns.flash, fn {key, _} -> flash_toast?(key) end)

        socket
        |> update_flash_messages(Map.new(flash))
        |> insert_flash_toasts(toasts)
      else
        socket
      end

    socket =
      cond do
        toast = assigns[:toast] ->
          socket
          |> stream_insert(:toasts, toast, at: 0)
          |> update(:toast_count, &(&1 + 1))

        id = assigns[:clear] ->
          socket
          |> stream_delete(:toasts, %{id: id})
          |> update(:toast_count, &max(&1 - 1, 0))

        assigns[:clear_all] ->
          socket
          |> stream(:toasts, [], reset: true)
          |> assign(:toast_count, 0)

        true ->
          socket
      end

    {:ok, socket}
  end

  @impl true
  def render(assigns) do
    position = assigns[:position] || "bottom-right"
    is_top_position = String.contains?(position, "top")
    assigns = assign(assigns, :computed_position, position)
    assigns = assign(assigns, :is_top_position, is_top_position)

    ~H"""
    <div class={"live-toast-group toast-position-#{@computed_position}"} style="display: flex; flex-direction: column;">
      <Toast.Components.flash_group :if={@is_top_position && map_size(@flash_messages) > 0} flash={@flash_messages} position={@computed_position} theme={assigns[:theme] || "light"} rich_colors={assigns[:rich_colors] || false} />
      <div 
        id={assigns[:id] || "toast-group"}
        data-theme={assigns[:theme] || "light"}
        data-rich-colors={to_string(assigns[:rich_colors] || false)}
        data-max-toasts={assigns[:max_toasts]}
        data-animation-duration={assigns[:animation_duration] || 400}
        phx-update="stream"
        phx-hook="Toast"
        style="position: relative;"
      >
        <div :for={{dom_id, toast} <- @streams.toasts} id={dom_id}>
          <Components.toast toast={toast} />
        </div>
      </div>
      <Toast.Components.flash_group :if={!@is_top_position && map_size(@flash_messages) > 0} flash={@flash_messages} position={@computed_position} theme={assigns[:theme] || "light"} rich_colors={assigns[:rich_colors] || false} />
    </div>
    """
  end

  @impl true
  def handle_event("clear", %{"id" => id}, socket) do
    {:noreply, stream_delete(socket, :toasts, %{id: id})}
  end

  def handle_event("clear-flash", %{"key" => key}, socket) do
    # Remove the flash message by key
    flash_messages = Map.delete(socket.assigns.flash_messages, key)
    {:noreply, assign(socket, :flash_messages, flash_messages)}
  end

  def handle_event("clear-all", _params, socket) do
    {:noreply,
     socket
     |> stream(:toasts, [], reset: true)
     |> assign(:toast_count, 0)}
  end

  def handle_event("action", %{"toast_id" => toast_id, "action" => action}, socket) do
    # Parse the JSON action string
    action =
      case Jason.decode(action) do
        {:ok, decoded} -> decoded
        _ -> nil
      end

    if action do
      event = action["event"]
      params = action["params"] || %{}

      # Send the event to the parent LiveView
      send(self(), {String.to_atom(event), params})
    end

    # Remove the toast after action
    {:noreply, stream_delete(socket, :toasts, %{id: toast_id})}
  end

  defp flash_toast?(key), do: is_binary(key) and String.starts_with?(key, Toast.flash_prefix())

  # Toasts from put_toast/4 stay in the flash until the LiveView navigates, so
  # remember which flash keys were shown to avoid inserting them again on
  # re-render. Keys are unique per put_toast/4 call, so a reused toast id is
  # still shown again. Only keys still in the flash are kept.
  defp insert_flash_toasts(socket, toasts) do
    # Skip the dead render: its stream items stay in the DOM after the LiveView
    # connects, and a put_toast/4 in mount/3 runs again with a new id.
    if connected?(socket), do: do_insert_flash_toasts(socket, toasts), else: socket
  end

  defp do_insert_flash_toasts(socket, toasts) do
    shown = socket.assigns.flash_toast_keys

    socket =
      toasts
      |> Enum.reject(fn {key, _} -> MapSet.member?(shown, key) end)
      |> Enum.sort_by(fn {key, _} ->
        key |> String.replace_prefix(Toast.flash_prefix(), "") |> String.to_integer()
      end)
      |> Enum.reduce(socket, fn {_key, toast}, socket ->
        socket
        |> stream_insert(:toasts, struct(Toast, toast), at: 0)
        |> update(:toast_count, &(&1 + 1))
      end)

    assign(socket, :flash_toast_keys, MapSet.new(toasts, fn {key, _} -> key end))
  end

  defp update_flash_messages(socket, new_flash) do
    current = socket.assigns.flash_messages

    # Filter out empty values from new flash
    new_flash = for {k, v} <- new_flash, v != nil and v != "", into: %{}, do: {k, v}

    # Only update if there are actual new flash messages
    # Don't clear existing messages just because new_flash is empty
    if map_size(new_flash) > 0 do
      # Merge new flash messages with current ones
      updated = Map.merge(current, new_flash)
      assign(socket, :flash_messages, updated)
    else
      # Keep current flash messages if no new ones
      socket
    end
  end
end
