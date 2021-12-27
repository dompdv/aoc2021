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

  def img_get({_img, rows, cols}, row, col, step, algo)
      when row < 0 or col < 0 or row >= rows or col >= cols,
      do:
        if(at(algo, 0) == 0,
          do: 0,
          else: if(rem(step, 2) == 1, do: at(algo, 511), else: at(algo, 0))
        )

  def img_get({img, _rows, _cols}, row, col, _step, _algo), do: img |> at(row) |> at(col)

  def convol(row, col, algo, image, step) do
    index =
      @filter
      |> map(fn {dr, dc} -> img_get(image, row + dr, col + dc, step, algo) end)
      |> reverse()
      |> reduce({1, 0}, fn n, {exp, acc} -> {exp * 2, acc + n * exp} end)
      |> elem(1)

    at(algo, index)
  end

  def one_step({algo, {_img, rows, cols} = image}, step) do
    image = for row <- -1..rows, do: for(col <- -1..cols, do: convol(row, col, algo, image, step))
    {algo, {image, count(image), count(at(image, 0))}}
  end

  def print_image({img, _rows, _cols}) do
    img
    |> map(fn line ->
      map(line, fn c -> if c == 0, do: '.', else: '#' end) |> to_string()
    end)
  end

  def launch(args, n) do
    {_, {img, _, _}} = reduce(1..n, parse(args), fn step, acc -> one_step(acc, step) end)
    img |> List.flatten() |> sum()
  end

  def part1(args), do: launch(args, 2)
  def part2(args), do: launch(args, 50)
end
