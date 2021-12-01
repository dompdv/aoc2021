defmodule AdventOfCode.Day01 do
  import Enum

  def part1(args) do
    input =
      [_ | t] = args |> String.split() |> map(&String.to_integer/1)

    zip([t, input]) |> map(fn {h, l} -> h - l end) |> filter(&(&1 > 0)) |> count()
  end

  def part2(args) do
    input =
      [_a, b, c | t] =
      args |> String.split() |> map(&String.to_integer/1)

    input = [_ | t] = Enum.zip([input, [b, c | t], [c | t]]) |> map(fn {a, b, c} -> a + b + c end)
    zip([t, input]) |> map(fn {h, l} -> h - l end) |> filter(&(&1 > 0)) |> count()
  end
end
