defmodule AdventOfCode.Day14 do
  import Enum

  def parse(args) do
    [kernel, rules] = args |> String.split("\n\n", trim: true)

    {to_charlist(kernel),
     rules
     |> String.split("\n", trim: true)
     |> map(fn line -> line |> String.split(" -> ") |> map(&to_charlist/1) |> List.to_tuple() end)
     |> map(fn {g, d} -> {g, hd(d)} end)
     |> Map.new()}
  end

  def apply_rules(kernel, rules) do
    kernel
    |> map(fn {[g, d] = doublet, n} ->
      case Map.get(rules, doublet) do
        nil -> {doublet, n}
        v -> [{[g, v], n}, {[v, d], n}]
      end
    end)
    |> List.flatten()
    |> reduce(%{}, fn {k, v}, acc -> Map.put(acc, k, Map.get(acc, k, 0) + v) end)
  end

  def run_for(args, iterations) do
    {kernel, rules} = args |> parse()

    freqs =
      reduce(1..iterations, kernel |> chunk_every(2, 1, :discard) |> frequencies(), fn _, acc ->
        apply_rules(acc, rules)
      end)
      |> map(fn {[g, _], v} -> {g, v} end)
      |> reduce(%{List.last(kernel) => 1}, fn {k, v}, acc ->
        Map.put(acc, k, Map.get(acc, k, 0) + v)
      end)
      |> Map.values()
      |> sort()

    at(freqs, -1) - at(freqs, 0)
  end

  def part1(args), do: run_for(args, 10)
  def part2(args), do: run_for(args, 40)
end
