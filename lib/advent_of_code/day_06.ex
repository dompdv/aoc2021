defmodule AdventOfCode.Day06 do
  import Enum

  def compute_generations(args, n_generations) do
    fishes =
      args
      |> String.trim()
      |> String.split(",", trim: true)
      |> map(&String.to_integer/1)
      # fishes is a Map %{age => number of fishes of this age}
      |> frequencies()

    1..n_generations
    |> reduce(fishes, fn _, acc ->
      # Produces a list of [{age, quantities}]
      for i <- 0..8 do
        qty = Map.get(acc, i, 0)
        if i == 0, do: [{6, qty}, {8, qty}], else: {i - 1, qty}
      end
      # flatten the list because the age 0 creates a nested list
      |> List.flatten()
      # creates a Map, adding quantities when there are several occurences of the same age (happens with 6, but the approach is general)
      |> reduce(%{}, fn {i, n}, acc_map -> Map.update(acc_map, i, n, &(&1 + n)) end)
    end)
    |> Map.values()
    |> sum()
  end

  def part1(args), do: compute_generations(args, 80)
  def part2(args), do: compute_generations(args, 256)
end
