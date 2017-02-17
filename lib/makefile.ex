defmodule Makefile do
  @moduledoc """
  Documentation for Makefile.
  """

  @doc """

  ## Examples

      iex> Makefile.generate
      "PATH_TO_MAKEFILE"

  > mix makefile.generate

  """

  @template File.read!('lib/makefile.elixir.mk')

  def generate do
    @template
  end

end
