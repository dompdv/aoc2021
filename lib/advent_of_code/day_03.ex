defmodule AdventOfCode.Day03 do
  import Enum

  def to_gamma_epsilon([], g, e), do: {reverse(g), reverse(e)}

  def to_gamma_epsilon([%{48 => a, 49 => b} | r], g, e) when a > b,
    do: to_gamma_epsilon(r, [48 | g], [49 | e])

  def to_gamma_epsilon([_a | r], g, e), do: to_gamma_epsilon(r, [49 | g], [48 | e])

  def part1(args) do
    {gamma, epsilon} =
      args
      |> String.split("\n", trim: true)
      |> map(&to_charlist/1)
      |> zip()
      |> map(&Tuple.to_list/1)
      |> map(&frequencies/1)
      |> to_gamma_epsilon([], [])

    String.to_integer("#{gamma}", 2) * String.to_integer("#{epsilon}", 2)
  end

  def part2(_args) do
  end
end
