defmodule Mix.Tasks.Makefile.Generate do
  use Mix.Task

  @shortdoc "Generate a Mailefile.elixir.mk template"
  def run(_) do
    path = Path.relative_to_cwd('Mailefile.elixir.mk')
    IO.puts path
    File.write(path, Makefile.generate)
  end
end
