defmodule AdventOfCode.Day03 do
  import Enum

  def to_gamma_epsilon([], g, e), do: {reverse(g), reverse(e)}

  def to_gamma_epsilon([%{?0 => a, ?1 => b} | r], g, e) when a > b,
    do: to_gamma_epsilon(r, [?0 | g], [?1 | e])

  def to_gamma_epsilon([_a | r], g, e), do: to_gamma_epsilon(r, [?1 | g], [?0 | e])

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

  def bit_criteria(numbers, col, rating) do
    %{?0 => a, ?1 => b} =
      at(
        numbers
        |> zip()
        |> map(&Tuple.to_list/1)
        |> map(&frequencies/1),
        col
      )

    sieve =
      case rating do
        :oxygen -> if b >= a, do: ?1, else: ?0
        :co2 -> if a <= b, do: ?0, else: ?1
      end

    filtered_list = numbers |> filter(fn n -> at(n, col) == sieve end)

    if count(filtered_list) == 1,
      do: filtered_list,
      else: bit_criteria(filtered_list, col + 1, rating)
  end

  def part2(args) do
    numbers =
      args
      |> String.split("\n", trim: true)
      |> map(&to_charlist/1)

    {oxy, co2} = {bit_criteria(numbers, 0, :oxygen), bit_criteria(numbers, 0, :co2)}
    String.to_integer("#{oxy}", 2) * String.to_integer("#{co2}", 2)
  end
end
