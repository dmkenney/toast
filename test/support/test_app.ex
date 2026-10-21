defmodule Toast.TestApp do
  @moduledoc false
  # Minimal Phoenix app for LiveView integration tests.

  defmodule Layouts do
    use Phoenix.Component

    def root(assigns) do
      ~H"""
      <!DOCTYPE html>
      <html>
        <body>{@inner_content}</body>
      </html>
      """
    end

    def app(assigns) do
      ~H"""
      <Toast.toast_group flash={@flash} />
      {@inner_content}
      """
    end
  end

  defmodule ToastComponent do
    use Phoenix.LiveComponent

    def render(assigns) do
      ~H"""
      <div id={@id}>
        <button id="component-toast" phx-click="toast" phx-target={@myself}>Toast</button>
        <button id="component-toast-and-navigate" phx-click="toast_and_navigate" phx-target={@myself}>
          Toast and navigate
        </button>
      </div>
      """
    end

    def handle_event("toast", _params, socket) do
      {:noreply, Toast.put_toast(socket, :info, "From component")}
    end

    def handle_event("toast_and_navigate", _params, socket) do
      {:noreply,
       socket
       |> Toast.put_toast(:info, "Navigated from component")
       |> push_navigate(to: "/target")}
    end
  end

  defmodule SourceLive do
    use Phoenix.LiveView

    def mount(_params, _session, socket) do
      {:ok, socket, layout: {Layouts, :app}}
    end

    def render(assigns) do
      ~H"""
      <h1>Source</h1>
      <.live_component module={Toast.TestApp.ToastComponent} id="toast-component" />
      """
    end

    def handle_event("toast", %{"message" => message}, socket) do
      {:noreply, Toast.put_toast(socket, :success, message)}
    end

    def handle_event("toast_and_navigate", %{"message" => message}, socket) do
      {:noreply,
       socket
       |> Toast.put_toast(:success, message, duration: 10_000)
       |> push_navigate(to: "/target")}
    end

    def handle_event("two_toasts_and_navigate", _params, socket) do
      {:noreply,
       socket
       |> Toast.put_toast(:info, "First toast")
       |> Toast.put_toast(:info, "Second toast")
       |> push_navigate(to: "/target")}
    end

    def handle_event("toast_and_redirect", %{"message" => message}, socket) do
      {:noreply,
       socket
       |> Toast.put_toast(:success, message)
       |> redirect(to: "/target")}
    end

    def handle_event("toast_with_id", %{"message" => message}, socket) do
      {:noreply, Toast.put_toast(socket, :info, message, id: "save-toast")}
    end

    def handle_event("rerender", _params, socket) do
      {:noreply, assign(socket, :rerendered, true)}
    end

    def handle_event("flash_and_navigate", %{"message" => message}, socket) do
      {:noreply,
       socket
       |> put_flash(:info, message)
       |> push_navigate(to: "/target")}
    end
  end

  defmodule TargetLive do
    use Phoenix.LiveView

    def mount(_params, _session, socket) do
      {:ok, socket, layout: {Layouts, :app}}
    end

    def render(assigns) do
      ~H"""
      <h1>Target</h1>
      """
    end
  end

  defmodule Router do
    use Phoenix.Router
    import Phoenix.LiveView.Router

    pipeline :browser do
      plug(:fetch_session)
      plug(:fetch_live_flash)
      plug(:put_root_layout, html: {Toast.TestApp.Layouts, :root})
    end

    scope "/" do
      pipe_through(:browser)
      live("/source", SourceLive)
      live("/target", TargetLive)
    end
  end

  defmodule Endpoint do
    use Phoenix.Endpoint, otp_app: :toast

    @session_options [store: :cookie, key: "_toast_test", signing_salt: "toast-test"]

    socket("/live", Phoenix.LiveView.Socket,
      websocket: [connect_info: [session: @session_options]]
    )

    plug(Plug.Session, @session_options)
    plug(Router)
  end
end
