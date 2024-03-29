defmodule Mix.Tasks.D24.P1 do
  use Mix.Task

  import AdventOfCode.Day24

  @shortdoc "Day 24 Part 1"
  def run(args) do
    input = AdventOfCode.Input.get!(24, 2021)

    """
    inp w
    inp x
    inp y
    inp z
    """

    input2 = """
    inp w
    add z w
    mod z 2
    div w 2
    add y w
    mod y 2
    div w 2
    add x w
    mod x 2
    div w 2
    mod w 2
    """

    # AdventOfCode.Input.get!(24, 2021)

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_1: fn -> input |> part1() end}),
      else:
        input
        |> part1()
        |> IO.inspect(label: "Part 1 Results")
  end
end
