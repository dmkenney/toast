defmodule Toast.LiveComponentTest do
  use ExUnit.Case, async: true

  import Phoenix.LiveViewTest

  alias Toast.LiveComponent

  describe "LiveComponent module" do
    test "is a Phoenix.LiveComponent" do
      behaviors = LiveComponent.__info__(:attributes)[:behaviour] || []
      assert Phoenix.LiveComponent in behaviors
    end
  end

  describe "expanded" do
    test "defaults to false" do
      html = render_component(LiveComponent, id: "toast-group")

      assert html =~ ~s(data-expanded="false")
    end

    test "emits data-expanded when set" do
      html = render_component(LiveComponent, id: "toast-group", expanded: true)

      assert html =~ ~s(data-expanded="true")
    end
  end
end
