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
     |> assign(:flash_messages, %{})}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(Map.take(assigns, [:position, :theme, :rich_colors, :max_toasts]))

    # Only update flash messages if flash is explicitly provided in assigns
    socket =
      if Map.has_key?(assigns, :flash) do
        update_flash_messages(socket, assigns.flash)
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
