defmodule Toast.Components do
  @moduledoc """
  Toast UI components for LiveToast.
  """

  use Phoenix.Component

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
          <%= @toast.title %>
        </div>
        <div class="toast-message">
          <%= @toast.message %>
        </div>
        <div :if={@toast.description} class="toast-description">
          <%= @toast.description %>
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
              <%= message %>
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
