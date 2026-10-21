defmodule Toast.LiveCase do
  @moduledoc false
  # Case template for tests that mount real LiveViews against Toast.TestApp.

  use ExUnit.CaseTemplate

  using do
    quote do
      import Phoenix.ConnTest
      import Phoenix.LiveViewTest

      @endpoint Toast.TestApp.Endpoint
    end
  end

  setup do
    {:ok, conn: Phoenix.ConnTest.build_conn()}
  end
end
