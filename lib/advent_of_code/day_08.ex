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
      digits |> map(&count/1) |> filter(&member?([2, 4, 3, 7], &1)) |> count()
    end)
    |> sum()
  end

  def permutations([]), do: [[]]

  def permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])

  def apply_perm(source, perm), do: source |> map(fn c -> at(perm, c - ?a) end)

  def process_line({clues, digits}, possibilities) do
    m_clues = MapSet.new(clues)

    ze_possibility = find(possibilities, &MapSet.equal?(m_clues, MapSet.new(Map.keys(&1))))

    digits
    |> map(&ze_possibility[&1])
    |> zip([1000, 100, 10, 1])
    |> map(fn {n, f} -> n * f end)
    |> sum()
  end

  def part2(args) do
    all_possibilities =
      permutations('abcdefg')
      |> map(fn a_permutation ->
        @numbers
        |> map(&apply_perm(&1, a_permutation))
        |> map(&sort/1)
        |> Enum.with_index()
        |> Map.new()
      end)

    parse(args)
    |> map(&process_line(&1, all_possibilities))
    |> sum()
  end
end
