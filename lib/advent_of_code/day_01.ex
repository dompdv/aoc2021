defmodule AdventOfCode.Day01 do
  import Enum
  def part1(args) do
    input = [_ | t] = args |> String.split("\n") |> drop(-1) |> map(fn v -> String.to_integer(v) end)
    Enum.zip([t, input]) |> map(fn {h,l}-> h-l end) |> filter(&(&1 > 0)) |> count()
  end

  def part2(_args) do
  end
end
