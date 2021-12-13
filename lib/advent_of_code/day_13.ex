defmodule AdventOfCode.Day13 do
  import Enum

  @fold_axis %{"x" => :x, "y" => :y}
  def parse(args) do
    [points, folds] = args |> String.split("\n\n", trim: true)

    points =
      String.split(points, "\n", trim: true)
      |> map(fn line ->
        String.split(line, ",") |> map(&String.to_integer/1) |> List.to_tuple()
      end)
      |> MapSet.new()

    folds =
      folds
      |> String.split("\n", trim: true)
      |> map(fn line ->
        [_, _, equation] = String.split(line, " ")
        [axis, where] = String.split(equation, "=")
        {@fold_axis[axis], String.to_integer(where)}
      end)

    {points, folds}
  end

  def fold_y(points, axis) do
    points
    |> map(fn {col, row} -> {col, if(row < axis, do: row, else: axis - (row - axis))} end)
    |> MapSet.new()
  end

  def fold_x(points, axis) do
    points
    |> map(fn {col, row} -> {if(col < axis, do: col, else: axis - (col - axis)), row} end)
    |> MapSet.new()
  end

  def fold(points, {:x, axis}), do: fold_x(points, axis)
  def fold(points, {:y, axis}), do: fold_y(points, axis)

  def part1(args) do
    {points, folds} = parse(args)
    fold(points, folds |> List.first()) |> count()
  end

  def print(points) do
    max_row = map(points, &elem(&1, 1)) |> max()
    max_col = map(points, &elem(&1, 0)) |> max()
    {max_row, max_col}

    for row <- 0..max_row do
      for col <- 0..max_col do
        if MapSet.member?(points, {col, row}), do: "#", else: " "
      end
    end
    |> map(fn line -> join(line) end)
  end

  def part2(args) do
    {points, folds} = parse(args)
    IO.inspect("")
    folds |> reduce(points, fn fold, p -> fold(p, fold) end) |> print() |> IO.inspect()
    IO.inspect("")
  end
end
