Logger.configure(level: :warning)

Application.put_env(:toast, Toast.TestApp.Endpoint,
  secret_key_base: String.duplicate("a", 64),
  live_view: [signing_salt: "toast-test-lv"],
  render_errors: [formats: [html: Toast.TestApp.Layouts]],
  server: false
)

{:ok, _} = Toast.TestApp.Endpoint.start_link()

ExUnit.start()
