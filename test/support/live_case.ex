defmodule Toast.LiveCase do
  @moduledoc false
  # Case template for tests that mount real LiveViews against Toast.TestApp.

  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ConnTest
      import Phoenix.LiveViewTest

      @endpoint Toast.TestApp.Endpoint

      # Closed toasts stay in the stream until their fade has run, which the
      # test layout shortens to 1ms.
      defp wait_for_fade, do: Process.sleep(20)
    end
  end

  setup do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
