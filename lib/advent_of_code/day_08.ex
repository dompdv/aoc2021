defmodule AdventOfCode.Day08 do
  import Enum
 @numbers [
  'abcefg',
  'cf',
  'acdeg',
  'acdfg',
  'bcdf',
  'abdfg',
  'abdefg',
  'acf',
  'abcdefg',
  'abcdfg'
]
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

  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def apply_perm(source, perm), do: source |> map(fn c -> at(perm, c - ?a) end)

  def process_line({clues, digits}, possibilities) do
    m_clues = MapSet.new(clues)

    ze_possibility =
      reduce_while(possibilities, 0, fn a_possib, _ ->
        m_possib = MapSet.new(Map.keys(a_possib))
        if MapSet.equal?(m_clues, m_possib), do: {:halt, a_possib}, else: {:cont, 0}
      end)

    digits
    |> map(fn digit -> ze_possibility[digit] end)
    |> zip([1000, 100, 10, 1])
    |> map(fn {n, f} -> n * f end)
    |> sum()
  end

  def part2(args) do
    all_possibilities =
      permutations('abcdefg')
      |> map(fn a_permutation ->
        @numbers
        |> map(fn n -> apply_perm(n, a_permutation) end)
        |> map(&sort/1)
        |> Enum.with_index()
        |> Map.new()
      end)

    parse(args)
    |> map(fn line -> process_line(line, all_possibilities) end)
    |> sum()
  end
end
