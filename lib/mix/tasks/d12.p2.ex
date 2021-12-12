defmodule Mix.Tasks.D12.P2 do
  use Mix.Task

  import AdventOfCode.Day12

  @shortdoc "Day 12 Part 2"
  def run(args) do
    input = AdventOfCode.Input.get!(12, 2021)

    """
    start-A
    start-b
    A-c
    A-b
    b-d
    A-end
    b-end
    """

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
