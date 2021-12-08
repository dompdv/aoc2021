defmodule AdventOfCode.Day08 do
  import Enum

  def parse_line(line) do
    [left, right] = line |> String.split(" | ", trim: true)
    digits = right |> String.split(" ", trim: true) |> map(&to_charlist/1) |> map(&sort/1)
    clues = left |> String.split(" ", trim: true) |> map(&to_charlist/1) |> map(&sort/1)
    {clues, digits}
  end

  def parse(args), do: args |> String.split("\n", trim: true) |> map(&parse_line/1)

  def part1(args) do
    parse(args)
    |> map(fn {_, digits} ->
      digits |> map(&count/1) |> filter(fn c -> member?([2, 4, 3, 7], c) end) |> count()
    end)
    |> sum()
  end

  def process_line({clues, digits}) do
    digits
  end
  def part2(args), do: parse(args) |> map(&process_line/1)
end
