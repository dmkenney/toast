defmodule Toast.Components do
  @moduledoc """
  Toast UI components for LiveToast.
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  @doc """
  Renders an individual toast notification.
  """
  attr(:toast, Toast, required: true)

  def toast(assigns) do
    ~H"""
    <div
      class={["toast", "toast-#{@toast.type}"]}
      data-toast-id={@toast.id}
      data-duration={@toast.duration}
      role="status"
      aria-live={if @toast.important, do: "assertive", else: "polite"}
    >
      <%= if icon = render_icon(@toast) do %>
        <div class="toast-icon">
          <%= icon %>
        </div>
      <% end %>

      <div class="toast-content">
        <div :if={@toast.title} class="toast-title">
          <%= render_content(@toast.title) %>
        </div>
        <div class="toast-message">
          <%= render_content(@toast.message) %>
        </div>
        <div :if={@toast.description} class="toast-description">
          <%= render_content(@toast.description) %>
        </div>
        <div :if={@toast.action && !inline_action?(@toast.action)} class="toast-actions">
          <button
            type="button"
            class="toast-action"
            data-toast-action={Jason.encode!(@toast.action)}
          >
            <%= @toast.action[:label] || "Action" %>
          </button>
        </div>
      </div>

      <%= if @toast.action && inline_action?(@toast.action) do %>
        <button
          type="button"
          class="toast-action-inline"
          data-toast-action={Jason.encode!(@toast.action)}
        >
          <%= @toast.action[:label] || "Action" %>
        </button>
      <% end %>

      <button
        :if={@toast.close_button}
        type="button"
        class="toast-close"
        data-close-toast
        aria-label="Close"
      >
        ×
      </button>
    </div>
    """
  end

  defp render_icon(%{icon: icon}) when is_binary(icon) do
    Phoenix.HTML.raw(icon)
  end

  defp render_icon(%{type: :success} = toast) do
    assigns = %{toast: toast}

    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="20"
      height="20"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <polyline points="20 6 9 17 4 12"></polyline>
    </svg>
    """
  end

  defp render_icon(%{type: :error} = toast) do
    assigns = %{toast: toast}

    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="20"
      height="20"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <circle cx="12" cy="12" r="10"></circle>
      <line x1="12" y1="8" x2="12" y2="12"></line>
      <line x1="12" y1="16" x2="12.01" y2="16"></line>
    </svg>
    """
  end

  defp render_icon(%{type: :warning} = toast) do
    assigns = %{toast: toast}

    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="20"
      height="20"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <path d="M10.29 3.86L1.82 18a2 2 0 0 0 1.71 3h16.94a2 2 0 0 0 1.71-3L13.71 3.86a2 2 0 0 0-3.42 0z"></path>
      <line x1="12" y1="9" x2="12" y2="13"></line>
      <line x1="12" y1="17" x2="12.01" y2="17"></line>
    </svg>
    """
  end

  defp render_icon(%{type: :info} = toast) do
    assigns = %{toast: toast}

    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="20"
      height="20"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
    >
      <circle cx="12" cy="12" r="10"></circle>
      <line x1="12" y1="16" x2="12" y2="12"></line>
      <line x1="12" y1="8" x2="12.01" y2="8"></line>
    </svg>
    """
  end

  defp render_icon(%{type: :loading} = toast) do
    assigns = %{toast: toast}

    ~H"""
    <svg
      xmlns="http://www.w3.org/2000/svg"
      width="20"
      height="20"
      viewBox="0 0 24 24"
      fill="none"
      stroke="currentColor"
      stroke-width="2"
      stroke-linecap="round"
      stroke-linejoin="round"
      class="animate-spin"
    >
      <path d="M21 12a9 9 0 1 1-6.219-8.56"></path>
    </svg>
    """
  end

  defp render_icon(%{type: :default}) do
    nil
  end

  defp render_icon(_toast), do: nil

  defp inline_action?(action) when is_map(action) do
    Map.get(action, :inline, false)
  end

  defp inline_action?(_), do: false

  defp render_content({:safe, _} = safe_content) do
    safe_content
  end

  defp render_content(content) when is_binary(content) do
    content
  end

  defp render_content(content) do
    to_string(content)
  end

  @doc """
  Renders flash messages when not connected to LiveView.
  This provides a fallback for server-rendered pages.
  """
  attr(:flash, :map, required: true)
  attr(:theme, :string, default: "light")
  attr(:position, :string, default: "bottom-right")
  attr(:rich_colors, :boolean, default: false)

  def flash_group(assigns) do
    ~H"""
    <div class={["flash-messages", "flash-position-#{@position}"]} data-theme={@theme} data-rich-colors={to_string(@rich_colors)}>
      <%= for {type, message} <- @flash do %>
        <div class={["toast", "toast-flash", "toast-#{flash_type_to_toast_type(type)}"]} 
             id={"flash-#{type}-#{System.unique_integer([:positive])}"}
             data-flash-key={type}
             data-flash-type={type}
             data-mounted="true"
             role="status"
             aria-live="polite">
          <%= if icon = render_flash_icon(type) do %>
            <div class="toast-icon">
              <%= icon %>
            </div>
          <% end %>

          <div class="toast-content">
            <div class="toast-message">
              <%= render_content(message) %>
            </div>
          </div>

          <button
            type="button"
            class="toast-close"
            data-close-flash
            data-flash-key={type}
            data-flash-type={type}
            aria-label="Close"
          >
            ×
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  defp flash_type_to_toast_type(:error), do: :error
  defp flash_type_to_toast_type("error"), do: :error
  defp flash_type_to_toast_type(:success), do: :success
  defp flash_type_to_toast_type("success"), do: :success
  defp flash_type_to_toast_type(:warning), do: :warning
  defp flash_type_to_toast_type("warning"), do: :warning
  defp flash_type_to_toast_type(:info), do: :info
  defp flash_type_to_toast_type("info"), do: :info
  # Default to info instead of :default
  defp flash_type_to_toast_type(_), do: :info

  defp render_flash_icon(type) do
    # Create a fake toast struct just for icon rendering
    fake_toast = %{type: flash_type_to_toast_type(type)}
    # Fallback to info icon
    render_icon(fake_toast) || render_icon(%{type: :info})
  end

  @doc """
  Renders hidden toasts that show while the LiveView is disconnected.

  These replace the `#client-error` and `#server-error` flashes from Phoenix's
  generated layouts. They use the same `phx-disconnected` and `phx-connected`
  bindings, so no extra JavaScript is needed. They toggle the `hidden`
  attribute instead of setting inline styles, which also works with
  Tailwind's `[hidden] { display: none !important }` reset.
  """
  attr(:id, :string, default: "toast-group")
  attr(:theme, :string, default: "light")
  attr(:rich_colors, :boolean, default: false)
  attr(:client_error_title, :string, default: "We can't find the internet")
  attr(:client_error_message, :string, default: "Attempting to reconnect")
  attr(:server_error_title, :string, default: "Something went wrong!")
  attr(:server_error_message, :string, default: "Hang in there while we get back on track")

  def connection_group(assigns) do
    ~H"""
    <div class="toast-connection-group" data-theme={@theme} data-rich-colors={to_string(@rich_colors)}>
      <.connection_toast
        id={"#{@id}-client-error"}
        error_class="phx-client-error"
        title={@client_error_title}
        message={@client_error_message}
      />
      <.connection_toast
        id={"#{@id}-server-error"}
        error_class="phx-server-error"
        title={@server_error_title}
        message={@server_error_message}
      />
    </div>
    """
  end

  attr(:id, :string, required: true)
  attr(:error_class, :string, required: true)
  attr(:title, :string, required: true)
  attr(:message, :string, required: true)

  defp connection_toast(assigns) do
    ~H"""
    <div
      id={@id}
      class="toast toast-flash toast-error toast-connection"
      data-mounted="true"
      role="alert"
      phx-disconnected={JS.remove_attribute("hidden", to: ".#{@error_class} ##{@id}")}
      phx-connected={JS.set_attribute({"hidden", ""}, to: "##{@id}")}
      hidden
    >
      <div class="toast-icon">
        <%= render_icon(%{type: :loading}) %>
      </div>
      <div class="toast-content">
        <div class="toast-title"><%= @title %></div>
        <div class="toast-message"><%= @message %></div>
      </div>
    </div>
    """
  end

  @doc """
  Renders the toast container element.
  """
  attr(:id, :string, default: "toast-container")
  attr(:class, :string, default: "")
  attr(:position, :string, default: "bottom-right")
  slot(:inner_block)

  def container(assigns) do
    ~H"""
    <div id={@id} class={["toast-container", "toast-position-#{@position}", @class]}>
      <%= render_slot(@inner_block) %>
    </div>
    """
  end
end
