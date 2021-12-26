defmodule AdventOfCode.Day20 do
  import Enum

  @filter for i <- -1..1, j <- -1..1, do: {i, j}

  def to_zero_one(?#), do: 1
  def to_zero_one(?.), do: 0

  def parse(args) do
    [algo, image] = String.split(args, "\n\n", trim: true)
    algo = map(to_charlist(algo), &to_zero_one/1)

    image =
      String.split(image, "\n", trim: true)
      |> map(fn line -> map(to_charlist(line), &to_zero_one/1) end)

    {algo, {image, count(image), count(at(image, 0))}}
  end

  def img_get({_img, rows, cols}, row, col)
      when row < 0 or col < 0 or row >= rows or col >= cols,
      do: 0

  def img_get({img, _rows, _cols}, row, col), do: img |> at(row) |> at(col)

  def convol(row, col, algo, image) do
    index =
      @filter
      |> map(fn {dr, dc} -> img_get(image, row + dr, col + dc) end)
      |> reverse()
      |> reduce({1, 0}, fn n, {exp, acc} -> {exp * 2, acc + n * exp} end)
      |> elem(1)

    at(algo, index)
  end

  def one_step({algo, {_img, rows, cols} = image}) do
    image = for row <- -1..rows, do: for(col <- -1..cols, do: convol(row, col, algo, image))
    {algo, {image, count(image), count(at(image, 0))}}
  end

  def part1(args) do
    parse(args) |> one_step() |> one_step() |> elem(1) |> elem(0) |> List.flatten() |> sum()
  end

  def part2(_args) do
  end
end
