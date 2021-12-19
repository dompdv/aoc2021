defmodule Mix.Tasks.D15.P2 do
  use Mix.Task

  import AdventOfCode.Day15

  @shortdoc "Day 15 Part 2"
  def run(args) do
    # AdventOfCode.Input.get!(15, 2021)
    input = AdventOfCode.Input.get!(15, 2021)

    """
    1163751742
    1381373672
    2136511328
    3694931569
    7463417111
    1319128137
    1359912421
    3125421639
    1293138521
    2311944581
    """

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
