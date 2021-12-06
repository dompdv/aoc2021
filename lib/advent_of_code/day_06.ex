defmodule AdventOfCode.Day06 do
  import Enum

  def one_generation(_, fishes), do: one_gen(fishes, [])

  def one_gen([], acc), do: acc

  def one_gen([fish | tail], acc) do
    case fish do
      0 -> one_gen(tail, [8, 6 | acc])
      _ -> one_gen(tail, [fish - 1 | acc])
    end
  end

  def part1(args) do
    fishes = args |> String.trim() |> String.split(",", trim: true) |> map(&String.to_integer/1)

    reduce(1..80, fishes, &one_generation/2)
    |> count()
  end

  def part2(args) do
    fishes =
      args
      |> String.trim()
      |> String.split(",", trim: true)
      |> map(&String.to_integer/1)
      |> frequencies()

    reduce(1..256, fishes, fn _, acc ->
      for i <- 8..0 do
        if i == 0,
          do: [{6, Map.get(acc, 0, 0)}, {8, Map.get(acc, 0, 0)}],
          else: {i - 1, Map.get(acc, i, 0)}
      end
      |> List.flatten()
      |> reduce(%{}, fn {i, n}, acc -> Map.put(acc, i, n + Map.get(acc, i, 0)) end)
    end)
    |> Map.values()
    |> sum()
  end
end
