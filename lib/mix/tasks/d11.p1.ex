defmodule Mix.Tasks.D11.P1 do
  use Mix.Task

  import AdventOfCode.Day11

  @shortdoc "Day 11 Part 1"
  def run(args) do
    input = AdventOfCode.Input.get!(11, 2021)

    """
    5483143223
    2745854711
    5264556173
    6141336146
    6357385478
    4167524645
    2176841721
    6882881134
    4846848554
    5283751526
    """

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_1: fn -> input |> part1() end}),
      else:
        input
        |> part1()
        |> IO.inspect(label: "Part 1 Results")
  end
end
