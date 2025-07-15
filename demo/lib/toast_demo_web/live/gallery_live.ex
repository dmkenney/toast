defmodule ToastDemoWeb.GalleryLive do
  use ToastDemoWeb, :live_view

  alias Toast

  def render(assigns) do
    ~H"""
    <style>
      .toast-static .toast {
        position: relative !important;
        transform: none !important;
        opacity: 1 !important;
        pointer-events: auto !important;
        margin: 0 !important;
        width: 356px !important;
        min-width: 316px !important;
      }
    </style>

    <div class="mx-auto max-w-7xl px-4 sm:px-6 lg:px-8 py-10">
      <div class="mx-auto max-w-5xl">
        <div class="text-center mb-12">
          <h1 class="text-5xl font-bold mb-4">Toast Styles Gallery</h1>
          <p class="text-xl text-gray-600">
            All toast styles and configurations displayed statically
          </p>
        </div>

        <div class="space-y-12">
          <%!-- Basic Toast Types - Light Theme --%>
          <section>
            <h2 class="text-3xl font-semibold mb-6">Basic Toast Types - Light Theme</h2>
            <div class="theme-light flex flex-wrap gap-x-6 gap-y-4 justify-center">
              <%= for toast <- basic_toasts() do %>
                <div class="toast-static">
                  <Toast.Components.toast toast={toast} />
                </div>
              <% end %>
            </div>
          </section>

          <%!-- Rich Content Toasts --%>
          <section>
            <h2 class="text-3xl font-semibold mb-6">Rich Content Toasts</h2>
            <div class="theme-light flex flex-wrap gap-x-6 gap-y-4 justify-center">
              <%= for toast <- rich_toasts() do %>
                <div class="toast-static">
                  <Toast.Components.toast toast={toast} />
                </div>
              <% end %>
            </div>
          </section>

          <%!-- Rich Colors Toasts --%>
          <section>
            <h2 class="text-3xl font-semibold mb-6">Rich Colors</h2>
            <div class="flex flex-wrap gap-x-6 gap-y-4 justify-center" data-rich-colors="true">
              <%= for toast <- rich_color_toasts() do %>
                <div class="toast-static">
                  <Toast.Components.toast toast={toast} />
                </div>
              <% end %>
            </div>
          </section>

          <%!-- Custom Icons --%>
          <section>
            <h2 class="text-3xl font-semibold mb-6">Custom Icons</h2>
            <div class="theme-light flex flex-wrap gap-x-6 gap-y-4 justify-center">
              <%= for toast <- custom_icon_toasts() do %>
                <div class="toast-static">
                  <Toast.Components.toast toast={toast} />
                </div>
              <% end %>
            </div>
          </section>

          <%!-- Dark Theme Toasts --%>
          <section>
            <h2 class="text-3xl font-semibold mb-6">Dark Theme</h2>
            <div class="bg-gray-900 p-6 rounded-lg dark" data-theme="dark">
              <div class="flex flex-wrap gap-x-6 gap-y-4 justify-center">
                <%= for toast <- dark_theme_toasts() do %>
                  <div class="toast-static">
                    <Toast.Components.toast toast={toast} />
                  </div>
                <% end %>
              </div>
            </div>
          </section>
        </div>
      </div>
    </div>
    """
  end

  def mount(_params, _session, socket) do
    {:ok, assign(socket, current_path: ~p"/gallery")}
  end

  defp basic_toasts do
    [
      %Toast{
        id: "default-1",
        type: :default,
        message: "This is a default toast",
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "success-1",
        type: :success,
        message: "Operation completed successfully!",
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "error-1",
        type: :error,
        message: "Something went wrong. Please try again.",
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "warning-1",
        type: :warning,
        message: "Please review your input before continuing.",
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "info-1",
        type: :info,
        message: "New features are available in your account.",
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "loading-1",
        type: :loading,
        message: "Loading...",
        duration: 0,
        close_button: false
      }
    ]
  end

  defp rich_toasts do
    [
      %Toast{
        id: "rich-1",
        type: :success,
        title: "Upload Complete",
        message: "Your files have been uploaded successfully.",
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "rich-4",
        type: :loading,
        title: "Processing Payment",
        message: "Please wait while we process your transaction...",
        duration: 0,
        close_button: false
      },
      %Toast{
        id: "rich-2",
        type: :info,
        title: "New Update Available",
        message: "Version 2.0 includes performance improvements.",
        action: %{label: "Update Now", event: "update_app"},
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "rich-3",
        type: :error,
        title: "Payment Failed",
        message: "Your credit card was declined.",
        description: "Please check your payment details and try again.",
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "rich-5",
        type: :default,
        message: "Event has been created",
        action: %{label: "Undo", event: "undo_action", inline: true},
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "rich-6",
        type: :success,
        message: "Changes saved",
        action: %{label: "View", event: "view_action", inline: true},
        duration: 0,
        close_button: true
      }
    ]
  end

  defp dark_theme_toasts do
    [
      %Toast{
        id: "dark-1",
        type: :success,
        message: "Dark theme success toast",
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "dark-2",
        type: :error,
        title: "Error",
        message: "Dark theme error with title",
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "dark-3",
        type: :info,
        title: "System Update",
        message: "Maintenance scheduled for tonight at 2 AM.",
        duration: 0,
        close_button: true
      }
    ]
  end

  defp rich_color_toasts do
    [
      %Toast{
        id: "rich-color-1",
        type: :success,
        message: "Rich color success toast",
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "rich-color-2",
        type: :error,
        title: "Error Occurred",
        message: "Something went wrong. Please try again.",
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "rich-color-3",
        type: :warning,
        message: "Please review your input before continuing.",
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "rich-color-4",
        type: :info,
        message: "New features are available in your account.",
        duration: 0,
        close_button: true
      }
    ]
  end

  defp custom_icon_toasts do
    [
      %Toast{
        id: "custom-1",
        type: :default,
        message: "Toast with custom rocket icon",
        icon:
          ~s(<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M4.5 16.5c-1.5 1.26-2 5-2 5s3.74-.5 5-2c.71-.84.7-2.13-.09-2.91a2.18 2.18 0 0 0-2.91-.09z"></path><path d="m12 15-3-3a22 22 0 0 1 2-3.95A12.88 12.88 0 0 1 22 2c0 2.72-.78 7.5-6 11a22.35 22.35 0 0 1-4 2z"></path><path d="M9 12H4s.55-3.03 2-4c1.62-1.08 5 0 5 0"></path><path d="M12 15v5s3.03-.55 4-2c1.08-1.62 0-5 0-5"></path></svg>),
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "custom-2",
        type: :success,
        message: "Toast with custom heart icon",
        icon:
          ~s(<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M19 14c1.49-1.46 3-3.21 3-5.5A5.5 5.5 0 0 0 16.5 3c-1.76 0-3 .5-4.5 2-1.5-1.5-2.74-2-4.5-2A5.5 5.5 0 0 0 2 8.5c0 2.3 1.5 4.05 3 5.5l7 7z"></path></svg>),
        duration: 0,
        close_button: true
      },
      %Toast{
        id: "custom-3",
        type: :info,
        message: "Toast with custom star icon",
        icon:
          ~s(<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polygon points="12 2 15.09 8.26 22 9.27 17 14.14 18.18 21.02 12 17.77 5.82 21.02 7 14.14 2 9.27 8.91 8.26 12 2"></polygon></svg>),
        duration: 0,
        close_button: true
      }
    ]
  end
end
