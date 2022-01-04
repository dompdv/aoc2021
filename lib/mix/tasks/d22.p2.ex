defmodule Mix.Tasks.D22.P2 do
  use Mix.Task

  import AdventOfCode.Day22

  @shortdoc "Day 22 Part 2"
  def run(args) do
    input = """
    on x=10..12,y=10..12,z=10..12
    on x=11..13,y=11..13,z=11..13
    """
#    off x=9..11,y=9..11,z=9..11
##    on x=10..10,y=10..10,z=10..10
#    """

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
