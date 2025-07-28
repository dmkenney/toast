defmodule Mix.Tasks.Mode do
  @moduledoc """
  Shows the current toast dependency mode (local or published).

  ## Usage

      mix mode
  """

  use Mix.Task

  @shortdoc "Show current toast dependency mode"
  @requirements []

  @impl true
  def run(_args) do
    content = File.read!("mix.exs")

    mode =
      cond do
        Regex.match?(~r/{:toast,\s*path:\s*"\.\.\/"},?/, content) -> "local"
        Regex.match?(~r/{:toast,\s*"[^"]+"},?/, content) -> "published"
        true -> "unknown"
      end

    case mode do
      "local" ->
        absolute_path = Path.expand("../")
        version = get_local_version(absolute_path)

        Mix.shell().info("Mode: local")
        Mix.shell().info("Path: #{absolute_path}")
        Mix.shell().info("Version: #{version}")

      "published" ->
        version = get_hex_version()

        Mix.shell().info("Mode: published")
        Mix.shell().info("Source: Hex package")
        Mix.shell().info("Version: #{version}")

      _ ->
        Mix.shell().error("Mode: unknown")
        Mix.shell().error("Toast dependency not found in expected format")
    end
  end

  defp get_local_version(path) do
    mix_file = Path.join(path, "mix.exs")

    if File.exists?(mix_file) do
      # Read the mix.exs file and extract version
      content = File.read!(mix_file)

      case Regex.run(~r/@version\s+"([^"]+)"/, content) do
        [_, version] -> version
        _ -> "unknown"
      end
    else
      "unknown"
    end
  end

  defp get_hex_version do
    lock_file = "mix.lock"

    if File.exists?(lock_file) do
      # Read mix.lock and find toast version
      {lock_data, _} = Code.eval_file(lock_file)

      case lock_data[:toast] do
        {:hex, :toast, version, _, _, _, _, _} -> version
        _ -> "0.2.0 (from mix.exs)"
      end
    else
      "0.2.0 (from mix.exs)"
    end
  end
end
