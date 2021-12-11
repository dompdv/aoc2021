defmodule AdventOfCode.Day11 do
  import Enum

  @coords for row <- 0..9, col <- 0..9, do: {row, col}
  @drowcol [{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}]
  def parse(args) do
    grid =
      args
      |> String.split("\n", trim: true)
      |> map(&to_charlist/1)
      |> map(fn line -> map(line, &(&1 - ?0)) end)

    for row <- 0..9, col <- 0..9, into: %{}, do: {{row, col}, grid |> at(row) |> at(col)}
  end

  def inc1([], flashed, grid), do: {MapSet.size(flashed), grid}

  def inc1([{row, col} | tail], flashed, grid) when row < 0 or col < 0 or row > 9 or col > 9,
    do: inc1(tail, flashed, grid)

  def inc1([{row, col} = cell | tail], flashed, grid) do
    if MapSet.member?(flashed, cell) do
      inc1(tail, flashed, grid)
    else
      {c, grid} = Map.get_and_update(grid, cell, fn c -> {c, c + 1} end)

      if c >= 9 do
        delta = @drowcol |> map(fn {dr, dc} -> {row + dr, col + dc} end)
        inc1(delta ++ tail, MapSet.put(flashed, cell), grid)
      else
        inc1(tail, flashed, grid)
      end
    end
  end

  def step({_flashes, grid}) do
    {n_flashed, grid} = inc1(@coords, MapSet.new(), grid)
    {n_flashed, for({cell, v} <- grid, into: %{}, do: {cell, if(v < 10, do: v, else: 0)})}
  end

  def part1(args) do
    grid = parse(args)
    Stream.iterate({0, grid}, &step/1) |> take(101) |> map(&elem(&1, 0)) |> sum()
  end

  def part2(args) do
    grid = parse(args)
    Stream.iterate({0, grid}, &step/1) |> take_while(fn {n, _} -> n < 100 end) |> count()
  end
end
