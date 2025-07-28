defmodule Mix.Tasks.Mode.Local do
  @moduledoc """
  Switch toast dependency to local development mode.

  This will:
  - Update mix.exs to use the local toast project
  - Create a symlink from deps/toast to the parent directory
  - Clean and rebuild dependencies

  ## Usage

      mix mode.local
  """

  use Mix.Task

  @shortdoc "Switch to local toast development"
  @requirements []

  @mix_file "mix.exs"
  @local_pattern ~r/{:toast,\s*path:\s*"\.\.\/"},?/
  @published_pattern ~r/{:toast,\s*"[^"]+"},?/

  @impl true
  def run(_args) do
    Mix.shell().info("Switching to local development mode...")

    # Update mix.exs
    update_mix_file()

    # Clean deps and build
    System.cmd("rm", ["-rf", "deps/toast", "_build"])

    # Run deps.get
    Mix.shell().info("Getting dependencies...")
    {_output, _} = System.cmd("mix", ["deps.get"], into: IO.stream(:stdio, :line))

    # Create symlink
    Mix.shell().info("Creating symlink...")
    create_symlink()

    toast_path = Path.expand("../")
    Mix.shell().info("\n✓ Switched to local development mode")
    Mix.shell().info("  Your demo now uses the local toast project at #{toast_path}")
  end

  defp update_mix_file do
    content = File.read!(@mix_file)
    local_dep = ~s({:toast, path: "../"},)

    cond do
      Regex.match?(@published_pattern, content) ->
        updated_content = Regex.replace(@published_pattern, content, local_dep)
        File.write!(@mix_file, updated_content)
        Mix.shell().info("✓ Updated mix.exs")

      Regex.match?(@local_pattern, content) ->
        Mix.shell().info("  Already in local mode")

      true ->
        Mix.shell().error("Could not find toast dependency in mix.exs")
        Mix.shell().error("Expected format: {:toast, \"~> X.Y.Z\"} or {:toast, path: \"../\"}")
        System.halt(1)
    end
  end

  defp create_symlink do
    toast_path = Path.expand("../")
    deps_toast_path = Path.join(["deps", "toast"])

    File.rm_rf(deps_toast_path)
    File.ln_s!(toast_path, deps_toast_path)

    Mix.shell().info("✓ Created symlink: deps/toast -> #{toast_path}")
  end
end
