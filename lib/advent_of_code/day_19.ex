defmodule AdventOfCode.Day19 do
  import Enum
  def parse_scanner(scanner) do
    [head | lines] = String.split(scanner, "\n", trim: true)
    [_,_,scanner_number, _] = String.split(head, " ", trim: true)
    lines = lines |> map(fn line ->
      String.split(line, ",") |> map(&String.to_integer/1) |> List.to_tuple()
    end)
    {String.to_integer(scanner_number), lines}
  end

  def scalars(scanner, index) do
    {x0, y0, z0} = at(scanner, 0)
    origin_b_0 = scanner |> map(fn {x,y,z} -> {x-x0, y-y0, z-z0} end)
    for {{x1,y1,z1},_i} <- with_index(origin_b_0), {{x2,y2,z2},_j} <- with_index(origin_b_0), do: x1*x2 + y1*y2 + z1*z2
  end
  def part1(args) do
    scanners = args |> String.split("\n\n", trim: true) |> map(&parse_scanner/1) |> Map.new()


    #origin_b_0 = scanners[0] |> map(fn {x,y,z} -> {x-x0, y-y0, z-z0} end)
    #scalar_b_0 = (for {{x1,y1,z1},i} <- with_index(origin_b_0), {{x2,y2,z2},j} <- with_index(origin_b_0), do: {i,j, x1*x2 + y1*y2 + z1*z2})

    for i0 <- 0..(count(scanners[0]) - 1), i1 <- 0..(count(scanners[1]) - 1) do
      s0 = MapSet.new(scalars(scanners[0], i0))
      s1 = MapSet.new(scalars(scanners[1], i1))
      MapSet.intersection(s0, s1) |> count()
    end |> filter(&(&1 > 2))
  end

  def part2(_args) do
  end
end
