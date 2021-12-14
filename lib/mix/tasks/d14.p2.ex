defmodule Mix.Tasks.D14.P2 do
  use Mix.Task

  import AdventOfCode.Day14

  @shortdoc "Day 14 Part 2"
  def run(args) do
    #
    input = AdventOfCode.Input.get!(14, 2021)

    """
    NNCB

    CH -> B
    HH -> N
    CB -> H
    NH -> C
    HB -> C
    HC -> B
    HN -> C
    NN -> C
    BH -> H
    NC -> B
    NB -> B
    BN -> B
    BB -> N
    BC -> B
    CC -> N
    CN -> C
    """

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_2: fn -> input |> part2() end}),
      else:
        input
        |> part2()
        |> IO.inspect(label: "Part 2 Results")
  end
end
