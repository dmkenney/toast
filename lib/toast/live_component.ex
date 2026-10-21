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

  It also accepts `:update_toast` via `send_update/3` (see `Toast.update_toast/2`).
  A map of toast structs by ID is kept alongside the stream so updates can be
  merged into the existing toast, with a list of their IDs, newest first, to
  enforce `:max_toasts`.
  """

  use Phoenix.LiveComponent

  alias Toast.Components

  @impl true
  def mount(socket) do
    {:ok,
     socket
     |> stream(:toasts, [])
     |> assign(:toasts_by_id, %{})
     |> assign(:toast_ids, [])
     |> assign(:max_toasts, nil)
     |> assign(:flash_messages, %{})
     |> assign(:flash_toast_keys, MapSet.new())}
  end

  @impl true
  def update(assigns, socket) do
    socket =
      socket
      |> assign(
        Map.take(assigns, [
          :dom_id,
          :position,
          :theme,
          :rich_colors,
          :max_toasts,
          :animation_duration,
          :connection_toasts,
          :client_error_title,
          :client_error_message,
          :server_error_title,
          :server_error_message,
          :expanded
        ])
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
          insert_toast(socket, toast)

        update = assigns[:update_toast] ->
          update_toast(socket, update.id, update.updates)

        id = assigns[:clear] ->
          delete_toast(socket, id)

        assigns[:clear_all] ->
          clear_all(socket)

        true ->
          socket
      end

    {:ok, enforce_max_toasts(socket)}
  end

  @impl true
  def render(assigns) do
    position = assigns[:position] || "bottom-right"
    is_top_position = String.contains?(position, "top")
    assigns = assign(assigns, :computed_position, position)
    assigns = assign(assigns, :is_top_position, is_top_position)

    ~H"""
    <div class={"live-toast-group toast-position-#{@computed_position}"}>
      <Toast.Components.connection_group :if={@is_top_position && assigns[:connection_toasts]} id={assigns[:dom_id] || "toast-group"} theme={assigns[:theme] || "light"} rich_colors={assigns[:rich_colors] || false} client_error_title={@client_error_title} client_error_message={@client_error_message} server_error_title={@server_error_title} server_error_message={@server_error_message} />
      <Toast.Components.flash_group :if={@is_top_position && map_size(@flash_messages) > 0} flash={@flash_messages} position={@computed_position} theme={assigns[:theme] || "light"} rich_colors={assigns[:rich_colors] || false} />
      <div 
        id={assigns[:dom_id] || "toast-group"}
        class="live-toast-stream"
        data-theme={assigns[:theme] || "light"}
        data-rich-colors={to_string(assigns[:rich_colors] || false)}
        data-max-toasts={assigns[:max_toasts]}
        data-animation-duration={assigns[:animation_duration] || 400}
        data-expanded={to_string(assigns[:expanded] || false)}
        phx-update="stream"
        phx-hook="Toast"
      >
        <div :for={{dom_id, toast} <- @streams.toasts} id={dom_id}>
          <Components.toast toast={toast} />
        </div>
      </div>
      <Toast.Components.flash_group :if={!@is_top_position && map_size(@flash_messages) > 0} flash={@flash_messages} position={@computed_position} theme={assigns[:theme] || "light"} rich_colors={assigns[:rich_colors] || false} />
      <Toast.Components.connection_group :if={!@is_top_position && assigns[:connection_toasts]} id={assigns[:dom_id] || "toast-group"} theme={assigns[:theme] || "light"} rich_colors={assigns[:rich_colors] || false} client_error_title={@client_error_title} client_error_message={@client_error_message} server_error_title={@server_error_title} server_error_message={@server_error_message} />
    </div>
    """
  end

  @impl true
  def handle_event("clear", %{"id" => id}, socket) do
    {:noreply, delete_toast(socket, id)}
  end

  def handle_event("clear-flash", %{"key" => key}, socket) do
    # Remove the flash message by key
    flash_messages = Map.delete(socket.assigns.flash_messages, key)
    {:noreply, assign(socket, :flash_messages, flash_messages)}
  end

  def handle_event("clear-all", _params, socket) do
    {:noreply, clear_all(socket)}
  end

  def handle_event("action", %{"toast_id" => toast_id}, socket) do
    # Use the action stored on the server. The copy in the page can be edited,
    # and turning its event name into an atom would let a client create atoms.
    case socket.assigns.toasts_by_id do
      %{^toast_id => %{action: %{} = action}} ->
        event = action[:event] || action["event"]
        # Params arrive with string keys, as they did when read from the page.
        params =
          (action[:params] || action["params"] || %{}) |> Jason.encode!() |> Jason.decode!()

        # Send the event to the parent LiveView
        send(self(), {to_event(event), params})

      _ ->
        :ok
    end

    # Remove the toast after action
    {:noreply, delete_toast(socket, toast_id)}
  end

  defp to_event(event) when is_atom(event), do: event
  defp to_event(event) when is_binary(event), do: String.to_atom(event)

  defp update_toast(socket, id, updates) do
    case socket.assigns.toasts_by_id do
      %{^id => toast} ->
        toast = struct(toast, Map.delete(Map.new(updates), :id))

        socket
        |> stream_insert(:toasts, toast)
        |> update(:toasts_by_id, &Map.put(&1, id, toast))

      _ ->
        socket
    end
  end

  defp insert_toast(socket, toast) do
    socket
    |> stream_insert(:toasts, toast, at: 0)
    |> update(:toasts_by_id, &Map.put(&1, toast.id, toast))
    |> update(:toast_ids, &[toast.id | List.delete(&1, toast.id)])
  end

  # Drop the oldest toasts over the limit. The client fades them out as soon as
  # they pass the limit, so take them out of the stream once that has run. The
  # client used to send a "clear" for each one, but every push locks the stream
  # container until its reply, and overlapping locks put removed toasts back.
  defp enforce_max_toasts(socket) do
    %{max_toasts: max, toast_ids: ids} = socket.assigns

    if is_integer(max) and max > 0 and length(ids) > max do
      {ids, removed} = Enum.split(ids, max)
      delay = socket.assigns[:animation_duration] || 400

      for id <- removed do
        send_update_after(socket.assigns.myself, %{clear: id}, delay)
      end

      socket
      |> assign(:toast_ids, ids)
      |> update(:toasts_by_id, &Map.drop(&1, removed))
    else
      socket
    end
  end

  defp delete_toast(socket, id) do
    socket
    |> stream_delete(:toasts, %{id: id})
    |> update(:toasts_by_id, &Map.delete(&1, id))
    |> update(:toast_ids, &List.delete(&1, id))
  end

  defp clear_all(socket) do
    socket
    |> stream(:toasts, [], reset: true)
    |> assign(:toasts_by_id, %{})
    |> assign(:toast_ids, [])
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
        insert_toast(socket, struct(Toast, toast))
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
