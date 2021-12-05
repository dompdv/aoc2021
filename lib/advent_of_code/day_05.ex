defmodule AdventOfCode.Day05 do
  def parse_line(line) do
    [s, e] = String.split(line, " -> ")
    [x1, y1] = String.split(s, ",")
    [x2, y2] = String.split(e, ",")
    {String.to_integer(x1), String.to_integer(y1), String.to_integer(x2), String.to_integer(y2)}
  end

  def dangerous({x, y}, lines) do
    lines
    |> Enum.map(fn {x1, y1, x2, y2} ->
      if min(x1, x2) <= x and x <= max(x1, x2) and min(y1, y2) <= y and y <= max(y1, y2),
        do: 1,
        else: 0
    end)
    |> Enum.sum()
  end

  def part1(args) do
    lines =
      args
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)
      |> Enum.filter(fn {x1, y1, x2, y2} -> x1 == x2 or y1 == y2 end)

    max_x = lines |> Enum.map(fn {x1, _y1, x2, _y2} -> max(x1, x2) end) |> Enum.max()
    max_y = lines |> Enum.map(fn {_x1, y1, _x2, y2} -> max(y1, y2) end) |> Enum.max()

    for(row <- 0..max_y, col <- 0..max_x, do: {col, row})
    |> Enum.filter(fn coordinates -> dangerous(coordinates, lines) >= 2 end)
    |> Enum.count()
  end

  def on_line({x, y}, {x1, y1, x2, y2})
      when (x < x1 and x < x2) or (x > x1 and x > x2) or (y < y1 and y < y2) or
             (y > y1 and y > y2),
      do: 0

  def on_line({x, y}, {x1, y1, x2, y2}) do
    cond do
      (x == x1 and y == y1) or (x == x2 and y == y2) -> 1
      y1 == y2 or x1 == x2 -> 1
      y == y1 -> if (y - y1) / (x - x1) == (y2 - y1) / (x2 - x1), do: 1, else: 0
      true -> if (x - x1) / (y - y1) == (x2 - x1) / (y2 - y1), do: 1, else: 0
    end
  end

  def on_lines(coord, lines),
    do: lines |> Enum.map(fn line -> on_line(coord, line) end) |> Enum.sum()

  def part2(args) do
    lines =
      args
      |> String.split("\n", trim: true)
      |> Enum.map(&parse_line/1)

    max_x = lines |> Enum.map(fn {x1, _y1, x2, _y2} -> max(x1, x2) end) |> Enum.max()
    max_y = lines |> Enum.map(fn {_x1, y1, _x2, y2} -> max(y1, y2) end) |> Enum.max()

    for(row <- 0..max_y, col <- 0..max_x, do: {col, row})
    |> Enum.filter(fn coordinates -> on_lines(coordinates, lines) >= 2 end)
    |> Enum.count()
  end
end
