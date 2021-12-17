defmodule Mix.Tasks.D15.P1 do
  use Mix.Task

  import AdventOfCode.Day15

  @shortdoc "Day 15 Part 1"
  def run(args) do
    #
    input =#AdventOfCode.Input.get!(15, 2021)
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



      """
116
138
213
"""


      """
11637
13813
21365
36949
74634
"""

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_1: fn -> input |> part1() end}),
      else:
        input
        |> part1()
        |> IO.inspect(label: "Part 1 Results")
  end
end
