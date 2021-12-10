defmodule AdventOfCode.Day10 do
  import Enum

  @opening [?(, ?{, ?[, ?<]
  @matching %{?{ => ?}, ?( => ?), ?[ => ?], ?< => ?>}
  @scores %{?) => 3, ?] => 57, ?} => 1197, ?> => 25137}

  def analyze_line(line), do: analyze_line(line, [])

  def analyze_line([], acc), do: {:incomplete, reverse(acc)}

  def analyze_line([c | tail], acc) do
    if member?(@opening, c),
      do: analyze_line(tail, [c | acc]),
      else:
        (case acc do
           [] ->
             {c, reverse(acc)}

           [last | tail_acc] ->
             if @matching[last] == c, do: analyze_line(tail, tail_acc), else: {c, reverse(acc)}
         end)
  end

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> map(&to_charlist/1)
    |> map(&analyze_line/1)
    |> filter(&(elem(&1, 0) != :incomplete))
    |> map(fn {c, _} -> @scores[c] end)
    |> sum()
  end

  def part2(_args) do
  end
end
