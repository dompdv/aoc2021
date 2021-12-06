defmodule AdventOfCode.Day06 do
  import Enum

  def compute_generations(args, n_generations) do
    fishes =
      args
      |> String.trim()
      |> String.split(",", trim: true)
      |> map(&String.to_integer/1)
      |> frequencies()

    1..n_generations
    |> reduce(fishes, fn _, acc ->
      for i <- 0..8 do
        qty = Map.get(acc, i, 0)
        if i == 0, do: [{6, qty}, {8, qty}], else: {i - 1, qty}
      end
      |> List.flatten()
      |> reduce(%{}, fn {i, n}, acc_map -> Map.put(acc_map, i, n + Map.get(acc_map, i, 0)) end)
    end)
    |> Map.values()
    |> sum()
  end

  def part1(args), do: compute_generations(args, 80)
  def part2(args), do: compute_generations(args, 256)
end
