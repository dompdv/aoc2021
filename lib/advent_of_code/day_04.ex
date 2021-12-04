defmodule AdventOfCode.Day04 do
  import Enum

  def parse(args) do
    [f | r] = String.split(args, "\n\n")
    numbers = f |> String.split(",", trim: true) |> map(&String.to_integer/1)

    boards =
      r
      |> map(fn a_board ->
        regular =
          a_board
          |> String.split("\n", trim: true)
          |> map(fn line -> String.split(line) |> map(&String.to_integer/1) end)

        turned = for row <- 0..4, do: for(col <- 0..4, do: regular |> at(col) |> at(row))
        {regular, turned}
      end)

    {numbers, boards}
  end

  def winning_boards(boards, numbers),
    do: boards |> filter(fn board -> winning_board(board, numbers) end)

  def winning_board({reg, turned}, numbers),
    do: winning_board(reg, numbers) or winning_board(turned, numbers)

  def winning_board(board, numbers) do
    any?(board, fn line ->
      count(MapSet.intersection(MapSet.new(line), MapSet.new(numbers))) == 5
    end)
  end

  def extract_losers(a_board, numbers) do
    numbers = MapSet.new(numbers)
    List.flatten(a_board) |> filter(fn e -> not MapSet.member?(numbers, e) end)
  end

  def part1(args) do
    {numbers, boards} = parse(args)

    Enum.reduce_while(numbers, [], fn x, acc ->
      acc = [x | acc]
      wb = winning_boards(boards, acc)

      if empty?(wb),
        do: {:cont, acc},
        else: {:halt, x * (wb |> List.first() |> elem(0) |> extract_losers(acc) |> sum())}
    end)
  end

  def part2(args) do
    {numbers, boards} = parse(args)

    Enum.reduce_while(numbers, [], fn x, acc ->
      acc = [x | acc]
      wb = winning_boards(boards, acc)

      if empty?(wb),
        do: {:cont, acc},
        else: {:halt, x * (wb |> List.first() |> elem(0) |> extract_losers(acc) |> sum())}
    end)
  end
end
