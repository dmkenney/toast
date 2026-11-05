defmodule Toast.Components do
  @moduledoc """
  Toast UI components for LiveToast.
  """

  use Phoenix.Component

  alias Phoenix.LiveView.JS

  # LiveView matches elements without an id by a key that changes on every
  # render, so each update_toast/2 replaced the toast element. That replayed it
  # to screen readers as a new live region. With a stable id it is patched in
  # place, which needs LiveView 1.1+: the hook marks the attributes it sets with
  # ignoreAttributes so the patch keeps them. Older versions keep replacing it.
  @patch_in_place Code.ensure_loaded?(Phoenix.LiveView.JS) and
                    function_exported?(Phoenix.LiveView.JS, :ignore_attributes, 1)

  @doc false
  def patch_in_place?, do: @patch_in_place

  @doc """
  Renders an individual toast notification.
  """
  attr(:toast, Toast, required: true)

  def toast(assigns) do
    ~H"""
    <div
      id={if patch_in_place?(), do: "toast-body-#{@toast.id}"}
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
        <progress
          :if={@toast.progress}
          class="toast-progress"
          max="100"
          value={progress_value(@toast.progress)}
          aria-label={progress_label(@toast)}
        >
        </progress>
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

  # :indeterminate renders a <progress> with no value, which browsers and
  # screen readers treat as indeterminate.
  defp progress_value(:indeterminate), do: nil
  defp progress_value(value) when is_number(value), do: value |> max(0) |> min(100)

  # The progressbar's accessible name. Text only, since the title or message may
  # be HTML.
  defp progress_label(%{title: title, message: message}) do
    case title || message do
      {:safe, _} -> "Progress"
      nil -> "Progress"
      text -> to_string(text)
    end
  end

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

  `durations` maps flash types to an auto-dismiss time in milliseconds, set on
  each message as `data-duration`. Only the `Toast` hook inside `toast_group/1`
  acts on it.
  """
  attr(:flash, :map, required: true)
  attr(:theme, :string, default: "light")
  attr(:position, :string, default: "bottom-right")
  attr(:rich_colors, :boolean, default: false)
  attr(:durations, :map, default: %{}, doc: "auto-dismiss time in ms by flash type")
  attr(:keys, :list, default: nil, doc: "flash keys to show, or nil for all")

  def flash_group(assigns) do
    assigns =
      assign(
        assigns,
        :messages,
        assigns.flash
        |> Enum.filter(&show_flash?(&1, assigns.keys))
        |> Enum.map(&flash_message(&1, assigns.durations))
      )

    ~H"""
    <div class={["flash-messages", "flash-position-#{@position}"]} data-theme={@theme} data-rich-colors={to_string(@rich_colors)}>
      <%= for message <- @messages do %>
        <div class={["toast", "toast-flash", "toast-#{flash_type_to_toast_type(message.type)}"]} 
             id={"flash-#{message.key}"}
             data-flash-key={message.key}
             data-flash-type={message.type}
             data-duration={message.duration}
             data-mounted="true"
             role="status"
             aria-live="polite">
          <div class="toast-icon">
            <%= render_flash_icon(message.type) %>
          </div>

          <div class="toast-content">
            <div :if={message.title} class="toast-title">
              <%= render_content(message.title) %>
            </div>
            <div class="toast-message">
              <%= render_content(message.message) %>
            </div>
            <div :if={message.description} class="toast-description">
              <%= render_content(message.description) %>
            </div>
          </div>

          <button
            type="button"
            class="toast-close"
            data-close-flash
            data-flash-key={message.key}
            data-flash-type={message.type}
            aria-label="Close"
          >
            ×
          </button>
        </div>
      <% end %>
    </div>
    """
  end

  # put_toast/4 toasts travel in the flash under the prefix, so they always
  # show. Other keys show when keys is nil or lists them, as atom or string.
  defp show_flash?(_entry, nil), do: true

  defp show_flash?({key, _value}, keys) do
    key = to_string(key)
    String.starts_with?(key, Toast.flash_prefix()) or Enum.any?(keys, &(to_string(&1) == key))
  end

  # Toasts from Toast.put_toast/4 are stored in the flash as maps.
  defp flash_message({key, %{type: _, message: _} = toast}, durations) do
    %{
      key: key,
      type: toast.type,
      title: toast[:title],
      message: toast.message,
      description: toast[:description],
      duration: flash_duration(durations, toast.type)
    }
  end

  defp flash_message({key, message}, durations) do
    %{
      key: key,
      type: key,
      title: nil,
      message: message,
      description: nil,
      duration: flash_duration(durations, key)
    }
  end

  # Flash keys are strings in a LiveView and may be atoms elsewhere, so match
  # durations given with either.
  defp flash_duration(durations, type) do
    Enum.find_value(durations, fn {key, ms} ->
      to_string(key) == to_string(type) and is_integer(ms) and ms > 0 and ms
    end)
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

  # flash_type_to_toast_type/1 only returns types that have an icon.
  defp render_flash_icon(type), do: render_icon(%{type: flash_type_to_toast_type(type)})

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
