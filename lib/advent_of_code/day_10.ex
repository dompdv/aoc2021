defmodule AdventOfCode.Day10 do
  import Enum

  @matching %{?{ => ?}, ?( => ?), ?[ => ?], ?< => ?>}
  @scores %{?) => 3, ?] => 57, ?} => 1197, ?> => 25137}
  @scores2 %{?) => 1, ?] => 2, ?} => 3, ?> => 4}

  def analyze_line(line), do: analyze_line(line, [])

  def analyze_line([], []), do: :success
  def analyze_line([], acc), do: {:incomplete, acc}
  def analyze_line([?( | tail], acc), do: analyze_line(tail, [?( | acc])
  def analyze_line([?{ | tail], acc), do: analyze_line(tail, [?{ | acc])
  def analyze_line([?[ | tail], acc), do: analyze_line(tail, [?[ | acc])
  def analyze_line([?< | tail], acc), do: analyze_line(tail, [?< | acc])
  def analyze_line([c | _tail], []), do: {c, []}

  def analyze_line([c | tail], [last | tail_acc] = acc),
    do: if(@matching[last] == c, do: analyze_line(tail, tail_acc), else: {c, acc})

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    |> map(&to_charlist/1)
    |> map(&analyze_line/1)
    |> filter(&(elem(&1, 0) != :incomplete))
    |> map(fn {c, _} -> @scores[c] end)
    |> sum()
  end

  def part2(args) do
    scores =
      args
      |> String.split("\n", trim: true)
      |> map(&to_charlist/1)
      |> map(&analyze_line/1)
      |> filter(&(elem(&1, 0) == :incomplete))
      |> map(&elem(&1, 1))
      |> map(fn l -> map(l, fn c -> @matching[c] end) end)
      |> map(fn line -> reduce(line, 0, fn c, acc -> acc * 5 + @scores2[c] end) end)
      |> sort()

    at(scores, div(count(scores), 2))
  end
end
