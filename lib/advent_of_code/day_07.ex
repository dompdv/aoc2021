defmodule AdventOfCode.Day07 do
  import Enum

  def parse(args) do
    crabs =
      args
      |> String.trim()
      |> String.split(",", trim: true)
      |> map(&String.to_integer/1)
      |> frequencies()

    {min_pos, max_pos} = min_max(Map.keys(crabs))
    {crabs, min_pos, max_pos}
  end

  def fuel_to(pos, crabs), do: for({p, n} <- crabs, do: abs(p - pos) * n) |> sum()

  def part1(args) do
    {crabs, min_pos, max_pos} = parse(args)

    min_pos..(max_pos - 1)
    |> reduce(
      fuel_to(max_pos, crabs),
      fn pos, current_min ->
        fuel_to_pos = fuel_to(pos, crabs)
        if fuel_to_pos < current_min, do: fuel_to_pos, else: current_min
      end
    )
  end

  def fuel_to2(pos, crabs),
    do: for({p, n} <- crabs, do: n * div(abs(p - pos) * (abs(p - pos) + 1), 2)) |> sum()

  def part2(args) do
    {crabs, min_pos, max_pos} = parse(args)

    min_pos..(max_pos - 1)
    |> reduce(
      fuel_to2(max_pos, crabs),
      fn pos, current_min ->
        fuel_to_pos = fuel_to2(pos, crabs)
        if fuel_to_pos < current_min, do: fuel_to_pos, else: current_min
      end
    )
  end
end
