defmodule Mix.Tasks.D09.P2 do
  use Mix.Task

  import AdventOfCode.Day09

  @shortdoc "Day 09 Part 2"
  def run(args) do
    # AdventOfCode.Input.get!(9, 2021)
    input = AdventOfCode.Input.get!(9, 2021)

    """
    2199943210
    3987894921
    9856789892
    8767896789
    9899965678
    """

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
