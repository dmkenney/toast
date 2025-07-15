defmodule Toast.LiveComponentTest do
  use ExUnit.Case, async: true

  alias Toast.LiveComponent

  describe "LiveComponent module" do
    test "is a Phoenix.LiveComponent" do
      behaviors = LiveComponent.__info__(:attributes)[:behaviour] || []
      assert Phoenix.LiveComponent in behaviors
    end
  end
end
