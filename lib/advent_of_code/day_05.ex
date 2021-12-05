defmodule AdventOfCode.Day05 do
  import Enum

  def parse_line(line) do
    [s, e] = String.split(line, " -> ")
    [x1, y1] = String.split(s, ",")
    [x2, y2] = String.split(e, ",")
    {String.to_integer(x1), String.to_integer(y1), String.to_integer(x2), String.to_integer(y2)}
  end

  def dangerous({x, y}, lines) do
    lines
    |> map(fn {x1, y1, x2, y2} ->
      cond do
        y1 == y2 and y == y1 ->
          if Kernel.min(x1, x2) <= x and x <= Kernel.max(x1, x2), do: 1, else: 0

        x1 == x2 and x == x1 ->
          if Kernel.min(y1, y2) <= y and y <= Kernel.max(y1, y2), do: 1, else: 0

        true ->
          0
      end
    end)
    |> sum()
  end

  def part1(args) do
    lines =
      args
      |> String.split("\n", trim: true)
      |> map(&parse_line/1)
      |> filter(fn {x1, y1, x2, y2} -> x1 == x2 or y1 == y2 end)

    max_x = lines |> map(fn {x1, _y1, x2, _y2} -> Kernel.max(x1, x2) end) |> max()
    max_y = lines |> map(fn {_x1, y1, _x2, y2} -> Kernel.max(y1, y2) end) |> max()

    for(row <- 0..max_y, col <- 0..max_x, do: {col, row})
    |> filter(fn coordinates -> dangerous(coordinates, lines) >= 2 end)
    |> count()
  end

  def part2(_args) do
  end
end
