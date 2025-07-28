defmodule Mix.Tasks.Mode.Published do
  @moduledoc """
  Switch toast dependency to published package mode.

  This will:
  - Update mix.exs to use the Hex package
  - Remove the local symlink
  - Fetch the package from Hex

  ## Usage

      mix mode.published
  """

  use Mix.Task

  @shortdoc "Switch to published toast package"
  @requirements []

  @mix_file "mix.exs"
  @local_pattern ~r/{:toast,\s*path:\s*"\.\.\/"},?/
  @published_pattern ~r/{:toast,\s*"[^"]+"},?/

  @impl true
  def run(_args) do
    Mix.shell().info("Switching to published package mode...")

    # Update mix.exs
    update_mix_file()

    # Clean deps and build
    System.cmd("rm", ["-rf", "deps/toast", "_build"])

    # Run deps.get
    Mix.shell().info("Getting dependencies...")
    {_output, _} = System.cmd("mix", ["deps.get"], into: IO.stream(:stdio, :line))

    Mix.shell().info("\n✓ Switched to published package mode")
    Mix.shell().info("  Your demo now uses toast from Hex")
  end

  defp update_mix_file do
    content = File.read!(@mix_file)

    cond do
      Regex.match?(@local_pattern, content) ->
        # Get the version from the parent project
        version = get_toast_version()
        published_dep = ~s({:toast, "~> #{version}"},)

        updated_content = Regex.replace(@local_pattern, content, published_dep)
        File.write!(@mix_file, updated_content)
        Mix.shell().info("✓ Updated mix.exs to use version ~> #{version}")

      Regex.match?(@published_pattern, content) ->
        Mix.shell().info("  Already in published mode")

      true ->
        Mix.shell().error("Could not find toast dependency in mix.exs")
        Mix.shell().error("Expected format: {:toast, path: \"../\"} or {:toast, \"~> X.Y.Z\"}")
        System.halt(1)
    end
  end

  defp get_toast_version do
    toast_mix = Path.join([Path.expand("../"), "mix.exs"])

    if File.exists?(toast_mix) do
      content = File.read!(toast_mix)

      case Regex.run(~r/@version\s+"([^"]+)"/, content) do
        [_, version] -> version
        _ -> "0.1.0"
      end
    else
      "0.1.0"
    end
  end
end
