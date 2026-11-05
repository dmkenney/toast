# Toast

Server-rendered toast notifications for Phoenix LiveView.

**[View Demo](https://toast.dkenney.com)** - See Toast in action with interactive examples.

## What is Toast?

Toast is a notification system for Phoenix LiveView that works as a drop-in replacement for your existing `flash` messages. It provides three ways to show notifications:

1. **Toast messages** - Call `Toast.send_toast()` from your LiveView to show rich, interactive notifications
2. **Pipe operation** - Use `Toast.put_toast()` to pipe toast messages in your socket chain
3. **Flash messages** - Your existing `put_flash()` calls continue to work, displayed in the same toast style

## Features

- 📚 **Stackable toasts** - Unlike flash messages, display multiple toasts simultaneously
- 🔄 **Drop-in replacement** - Your existing `put_flash()` calls render as beautiful toasts  
- ✨ **Beautiful by default** - Inspired by Sonner's elegant design, looks great out of the box
- 🎨 **Framework agnostic styling** - Ships with CSS, works with any CSS framework or custom styles
- ⚙️ **Highly customizable** - Themes, positions, animations, icons, actions - all configurable
- 🚀 **Server-controlled** - Full power of LiveView, no client-side state to manage
- 📦 **Self-contained** - CSS and JS included, no build step or npm required
- 🎯 **Zero configuration** - Works out of the box with sensible defaults
- 🪶 **Tiny footprint** - Single JS hook, no external dependencies

## Installation

Add `toast` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:toast, "~> 0.4.0"}
  ]
end
```

## Setup

These steps match a new Phoenix 1.8 app. Paths assume the default `assets/js/app.js` and `assets/css/app.css`.

### 1. JavaScript

In `assets/js/app.js`, import the hook and add it to your existing LiveSocket hooks. Keep the other options as they are:

```javascript
import Toast from "../../deps/toast/assets/js/toast.js"

const liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {_csrf_token: csrfToken},
  hooks: {...colocatedHooks, Toast},
})
```

On Phoenix 1.7 there is no `hooks` option yet, so add `hooks: {Toast}`.

### 2. CSS

In `assets/css/app.css`, import the stylesheet directly after the `@import "tailwindcss"` line:

```css
@import "tailwindcss" source(none);
@import "../../deps/toast/assets/css/toast.css";
```

If you use daisyUI (the Phoenix 1.8 default), its `toast` class clashes with Toast's. Add `exclude: toast;` to your existing daisyUI plugin block:

```css
@plugin "daisyui/packages/bundle/daisyui" {
  themes: false;
  exclude: toast;
}
```

### 3. Layout

`Toast.toast_group` is a LiveComponent, so it must be rendered inside a LiveView. Do not put it in `root.html.heex`: the root layout is rendered outside the LiveView and every page fails with `cannot convert component Toast.LiveComponent ... to HTML`.

**Phoenix 1.8:** in `lib/my_app_web/components/layouts.ex`, replace `<.flash_group flash={@flash} />` in `Layouts.app` with `Toast.toast_group`. Set `connection_toasts` to keep the "We can't find the internet" and "Something went wrong!" messages from Phoenix's `flash_group` (the `#client-error` and `#server-error` flashes):

```elixir
attr :flash, :map, required: true, doc: "the map of flash messages"
attr :live, :boolean, default: true, doc: "set to false in controller templates"

def app(assigns) do
  ~H"""
  <%!-- generated <header> and <main> stay as they are --%>

  <Toast.toast_group :if={@live} flash={@flash} connection_toasts={true} />
  <Toast.flash_group :if={!@live} flash={@flash} />
  """
end
```

Controller templates that use `Layouts.app` are not LiveViews, so they pass `live={false}` and get a plain flash list in the same style. If you set `position`, `theme` or `rich_colors` on `Toast.toast_group`, pass the same values to `Toast.flash_group`:

```heex
<Layouts.app flash={@flash} live={false}>
  ...
</Layouts.app>
```

Without `live={false}`, a controller page that uses `Layouts.app` fails with the same error as above. On controller pages the flash close button does nothing, because the JavaScript hook only runs in a LiveView.

The generated home page, `lib/my_app_web/controllers/page_html/home.html.heex`, doesn't use `Layouts.app` and renders `<Layouts.flash_group flash={@flash} />` itself. Replace that line with `<Toast.flash_group flash={@flash} />`. Phoenix's own flash relies on daisyUI's `toast` class, which the `exclude: toast;` line above removes.

**Phoenix 1.7:** `app.html.heex` is the layout for both LiveViews and controllers, and only LiveViews have `@socket`. Replace `<.flash_group flash={@flash} />` with:

```heex
<Toast.toast_group :if={assigns[:socket]} flash={@flash} connection_toasts={true} />
<Toast.flash_group :if={!assigns[:socket]} flash={@flash} />
```

## Basic Usage

### In LiveView

Send toasts from your LiveView event handlers:

```elixir
def handle_event("save", _params, socket) do
  {:noreply, 
   socket
   |> assign(:saved, true)
   |> Toast.put_toast(:success, "Changes saved!")}
end

def handle_event("delete", _params, socket) do
  {:noreply,
   socket
   |> Toast.put_toast(:error, "Failed to delete", duration: 5000)}
end

# put_toast is stored in the flash, so it is still shown after navigating
def handle_event("create", _params, socket) do
  {:noreply,
   socket
   |> Toast.put_toast(:success, "Item created!")
   |> push_navigate(to: ~p"/items")}
end

# Or without piping (shown on the current LiveView only)
def handle_event("notify", _params, socket) do
  Toast.send_toast(:info, "Notification sent!")
  {:noreply, socket}
end
```

Notes on `put_toast` and navigation:
- On `redirect/2` the flash travels in a cookie, which browsers drop above about 4KB. A large toast can push it over, and then no flash messages show on the next page.
- From a LiveComponent, `put_toast` shows the toast right away but doesn't carry it across navigation. Call it in the parent LiveView for that.

### Flash Messages

Toast continues to render your app's flash messages in the same style as toasts:

```elixir
# In a LiveView
def handle_event("save", _params, socket) do
  {:noreply, put_flash(socket, :success, "Settings updated!")}
end

# In a controller
def create(conn, params) do
  conn
  |> put_flash(:success, "Item created successfully!")
  |> redirect(to: ~p"/items")
end
```

By default flash messages stay until the user closes them. To close them on their own, set `flash_durations` on `toast_group` with a time in milliseconds per flash type:

```heex
<Toast.toast_group flash={@flash} flash_durations={%{info: 6000, success: 6000}} />
```

Types not listed, such as `:error` here, stay until closed. Like toasts, the timers pause while the pointer is over the group. A flash that closes on its own is cleared on the server the same way the close button does it, so it doesn't come back on the next render. `Toast.flash_group/1` on controller pages has no JavaScript hook, so its flash messages never auto-dismiss.

Toast shows every flash key as a message by default. Some keys aren't messages: `phx.gen.auth` keeps the login email in the flash under `:email`. Phoenix's own `flash_group` only shows `:info` and `:error`. To do the same, set `flash_keys`, which also works on `Toast.flash_group/1`:

```heex
<Toast.toast_group flash={@flash} flash_keys={~w(info error)} />
```

Toasts from `put_toast` travel in the flash under their own keys and always show. So don't filter `@flash` yourself with `Map.take/2`, which drops them too.

## Toast Types

Toast comes with 6 built-in types, each with its own icon and color:

- `:info` - Blue informational messages
- `:success` - Green success messages
- `:error` - Red error messages
- `:warning` - Yellow warning messages
- `:loading` - Loading state with spinner
- `:default` - Default neutral style

## Configuration Options

### Toast Container Options

Configure the toast container with these attributes:

```heex
<Toast.toast_group
  flash={@flash}
  position="bottom-right"
  theme="light"
  rich_colors={false}
  max_toasts={3}
  animation_duration={400}
  expanded={false}
/>
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `id` | string | `"toast-group"` | DOM id of the toast list. Connection toasts use `"<id>-client-error"` and `"<id>-server-error"`. Render one toast group per page |
| `position` | string | `"bottom-right"` | Position of toasts: `"top-left"`, `"top-center"`, `"top-right"`, `"bottom-left"`, `"bottom-center"`, `"bottom-right"` |
| `theme` | string | `"light"` | `"light"` or `"dark"` always use that theme. `"system"` follows the page theme, then the OS (see [Themes](#themes)) |
| `rich_colors` | boolean | `false` | Use more vibrant colors for toast types |
| `max_toasts` | integer | `3` | Maximum number of toasts shown. Older toasts beyond the limit are removed |
| `animation_duration` | integer | `400` | Duration of animations in milliseconds |
| `connection_toasts` | boolean | `false` | Show an error toast while the LiveView is disconnected |
| `client_error_title` | string | `"We can't find the internet"` | Title when the client loses its connection |
| `client_error_message` | string | `"Attempting to reconnect"` | Message when the client loses its connection |
| `server_error_title` | string | `"Something went wrong!"` | Title when the server crashes |
| `server_error_message` | string | `"Hang in there while we get back on track"` | Message when the server crashes |
| `expanded` | boolean | `false` | Always show toasts expanded instead of stacked |
| `flash_keys` | list | `nil` | Flash keys to show as messages, such as `~w(info error)`. `nil` shows every key. Toasts from `put_toast` always show (see [Flash Messages](#flash-messages)) |
| `flash_durations` | map | `%{}` | Auto-dismiss time in milliseconds per flash type, such as `%{info: 6000}`. Types not listed stay until closed (see [Flash Messages](#flash-messages)) |

### Themes

`theme="light"` and `theme="dark"` ignore the page around them.

`theme="system"` follows the page when it sets a theme, and the OS otherwise:

- A `data-theme="dark"` attribute or `dark` class on an ancestor (such as `<html>`) gives dark toasts.
- A `data-theme="light"` attribute on an ancestor gives light toasts, even when the OS is dark.
- With neither, toasts follow the OS setting via `prefers-color-scheme`.

This works with the light / dark / system toggle in Phoenix 1.8's generated layout, which
sets `data-theme` on `<html>` to the chosen or OS theme.

### Connection Toasts

Phoenix's generated layouts show `#client-error` and `#server-error` flashes when the
LiveView loses its connection. Set `connection_toasts` to show these as toasts instead.
If you replaced `<.flash_group>` as shown in Setup, those flashes are already gone.
Otherwise remove the two `<.flash>` elements from your layout:

```heex
<Toast.toast_group flash={@flash} connection_toasts={true} />
```

They use the same `phx-disconnected` and `phx-connected` bindings as Phoenix, so they
show while disconnected and hide on reconnect. Pass your own text to translate them:

```heex
<Toast.toast_group
  flash={@flash}
  connection_toasts={true}
  client_error_title={gettext("We can't find the internet")}
  client_error_message={gettext("Attempting to reconnect")}
  server_error_title={gettext("Something went wrong!")}
  server_error_message={gettext("Hang in there while we get back on track")}
/>
```

### Individual Toast Options

`send_toast` and `put_toast` take the same options:

```elixir
Toast.send_toast(:success, "Message",
  title: "Success!",
  description: "Additional details here",
  duration: 10_000,
  close_button: true,
  important: true,
  action: %{
    label: "Undo",
    event: "undo_action",
    params: %{id: 123}
  }
)
```

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `id` | string | random | Toast id. Set it to update or clear the toast later |
| `title` | string | `nil` | Toast title (displayed above message) |
| `description` | string | `nil` | Additional text (displayed below message) |
| `duration` | integer | `6000` | Auto-dismiss time in milliseconds (0 = no auto-dismiss) |
| `close_button` | boolean | `true` | Show close button |
| `important` | boolean | `false` | Use `aria-live="assertive"` for screen readers |
| `icon` | string | `nil` | Custom SVG icon HTML |
| `action` | map | `nil` | Action button configuration |
| `progress` | number or `:indeterminate` | `nil` | Progress bar, 0 to 100. `:indeterminate` for no known value |
| `on_dismiss` | map | `nil` | `%{event: ..., params: ...}` sent to the LiveView when the toast is closed in the browser |

### Action Button Options

Actions can be configured with:

```elixir
action: %{
  label: "Button text",      # Required
  event: "event_name",       # Event to send to LiveView
  params: %{key: "value"},   # Optional parameters
  inline: true               # Show as inline button (default: false)
}
```

Clicking the button closes the toast and sends `{event, params}` to the LiveView that sent the toast. Handle it in `handle_info/2`. The event arrives as an atom and `params` has string keys:

```elixir
def handle_event("delete", %{"id" => id}, socket) do
  Toast.send_toast(:info, "Item deleted",
    action: %{label: "Undo", event: "undo_delete", params: %{id: id}}
  )

  {:noreply, socket}
end

def handle_info({:undo_delete, %{"id" => id}}, socket) do
  # restore the item
  {:noreply, socket}
end
```

### Progress

`progress` shows a progress bar: a number from 0 to 100, or `:indeterminate` when the amount isn't known. Pair it with `duration: 0` and `update_toast/2` for a long-running job:

```elixir
Toast.send_toast(:loading, "Exporting...", id: "export-42", duration: 0, progress: 0)

# Later, as the job runs
Toast.update_toast("export-42", progress: 45, description: "4.5M of 10M rows")

# When it's done. progress: nil removes the bar
Toast.update_toast("export-42",
  type: :success,
  message: "Export ready",
  description: nil,
  progress: nil,
  duration: 6000,
  action: %{label: "Download", event: "download_export", params: %{id: 42}}
)
```

The bar is a native `<progress>` element, so screen readers see it as a progress bar, labeled with the toast's title or message. Values outside 0 to 100 are clamped.

On LiveView 1.1 and later, each update patches the toast in place: it doesn't animate in again, its timer only restarts when `duration` changes, and screen readers only read out the text that changed. A changed `progress` value alone isn't read out. On older LiveView versions the toast element is replaced on each update, which looks the same but may be read out again in full.

### Dismiss Callback

`on_dismiss` tells the LiveView when a toast goes away in the browser. It sends `{event, params}` like an action, with a `"reason"` key added to `params`:

- `"closed"`: the user clicked the close button
- `"timeout"`: the toast's `duration` ran out
- `"action"`: the user clicked the action button. The action's own event is sent first

```elixir
Toast.send_toast(:loading, "Exporting...",
  id: "export-42",
  duration: 0,
  on_dismiss: %{event: :export_toast_closed, params: %{id: 42}}
)

def handle_info({:export_toast_closed, %{"id" => id, "reason" => _reason}}, socket) do
  # don't show this export's toast again on the next page
  {:noreply, socket}
end
```

It isn't sent when the server removes the toast (`clear_toast/1`, `clear_all_toasts/0`, or `max_toasts`), when `update_toast/2` changes it, or while the LiveView is disconnected. A `"reason"` key in your own `params` is replaced. As with actions, the event name is kept on the server, never read from the page.

## Advanced Usage

### Custom Icons

Provide custom SVG icons:

```elixir
Toast.send_toast(:info, "Custom icon",
  icon: ~s(<svg>...</svg>)
)
```

### HTML Content

Toast supports rendering raw HTML in messages, titles, and descriptions using `Phoenix.HTML.raw/1`:

```elixir
# Basic HTML formatting
Toast.send_toast(:info, Phoenix.HTML.raw("<strong>Bold</strong> and <em>italic</em> text"))

# Rich HTML content
Toast.send_toast(:success, Phoenix.HTML.raw("Payment processed"),
  title: Phoenix.HTML.raw("Transaction <em>Complete</em>"),
  description: Phoenix.HTML.raw("ID: <code>TXN-12345</code>")
)

# Mixed content (some fields escaped, some raw)
Toast.send_toast(:info, "This is escaped: <script>",
  description: Phoenix.HTML.raw("This is <strong>HTML</strong>")
)
```

**⚠️ Security Warning**: Only use `Phoenix.HTML.raw/1` with trusted content. Never render user-generated HTML without proper sanitization as it can lead to XSS vulnerabilities.

### Update Existing Toasts

Update a toast after it's displayed:

```elixir
# Create with custom ID. duration: 0 keeps it open until it is updated
Toast.send_toast(:loading, "Processing...", id: "upload-toast", duration: 0)

# Later, update it
Toast.update_toast("upload-toast",
  type: :success,
  message: "Upload complete!",
  duration: 3000
)
```

The toast is re-rendered in place. A new `duration` restarts its timer. Updating an ID that is no longer showing does nothing. Any toast option can be updated, including `progress`, `action`, and `on_dismiss`.

### Clear Toasts

Remove toasts programmatically:

```elixir
# Clear specific toast
Toast.clear_toast("toast-id")

# Clear all toasts
Toast.clear_all_toasts()
```


## Stacking Behavior

When multiple toasts are displayed:

- Toasts stack with the newest on top
- Hovering expands the stack to show all toasts and pauses every toast's timer. Each one resumes with the time it had left when the pointer leaves
- Set `expanded={true}` to turn off stacking and always show toasts expanded
- Only the newest `max_toasts` are kept. Older ones fade out and are removed
- Toasts animate smoothly when added/removed

## CSS Customization

Each toast reads its colors from CSS custom properties: `--toast-bg`, `--toast-color`, `--toast-border` and `--toast-icon-color`. Override them per type in your `app.css`, after the Toast import:

```css
.live-toast-group .toast-success {
  --toast-bg: #10b981;
  --toast-color: white;
  --toast-border: #059669;
  --toast-icon-color: white;
}
```

Set the animation speed with the `animation_duration` attribute, not CSS.

## Content Security Policy

Toast renders no inline `style` attributes or `<style>` elements, so it works under a strict CSP such as `style-src 'self'` without `'unsafe-inline'`. Load `toast.css` as part of your own stylesheet. Any HTML you pass in yourself (custom icons, `Phoenix.HTML.raw/1` content) must also avoid inline styles.

## Acknowledgments

Toast was heavily influenced by:
- [Sonner](https://github.com/emilkowalski/sonner) - An opinionated toast component for React.
- [LiveToast](https://github.com/srcrip/live_toast) - A beautiful drop-in replacement for the Phoenix Flash system.
## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

MIT License - see LICENSE file for details.

