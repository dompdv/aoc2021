defmodule AdventOfCode.Day07 do
  import Enum

  def fuel_to(pos, crabs), do: for({p, n} <- crabs, do: abs(p - pos) * n) |> sum()

  def part1(args) do
    crabs =
      args
      |> String.trim()
      |> String.split(",", trim: true)
      |> map(&String.to_integer/1)
      # fishes is a Map %{age => number of fishes of this age}
      |> frequencies()

    {min_pos, max_pos} = min_max(Map.keys(crabs))
    fuel_to_max_pos = fuel_to(max_pos, crabs)

    reduce(
      min_pos..max_pos,
      {max_pos, fuel_to_max_pos},
      fn pos, {current_min_pos, current_min_fuel} ->
        fuel_to_pos = fuel_to(pos, crabs)

        if fuel_to_pos < current_min_fuel,
          do: {pos, fuel_to_pos},
          else: {current_min_pos, current_min_fuel}
      end
    )
    |> elem(1)
  end


  def fuel_to2(pos, crabs), do: for({p, n} <- crabs, do: n * div(abs(p - pos)*(abs(p - pos)+1),2)) |> sum()

  def part2(args) do
    crabs =
      args
      |> String.trim()
      |> String.split(",", trim: true)
      |> map(&String.to_integer/1)
      # fishes is a Map %{age => number of fishes of this age}
      |> frequencies()

      {min_pos, max_pos} = min_max(Map.keys(crabs))
      fuel_to_max_pos = fuel_to2(max_pos, crabs)

      reduce(
        min_pos..max_pos,
        {max_pos, fuel_to_max_pos},
        fn pos, {current_min_pos, current_min_fuel} ->
          fuel_to_pos = fuel_to2(pos, crabs)

          if fuel_to_pos < current_min_fuel,
            do: {pos, fuel_to_pos},
            else: {current_min_pos, current_min_fuel}
        end
      )
      |> elem(1)
  end
end
