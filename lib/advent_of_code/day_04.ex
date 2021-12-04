defmodule AdventOfCode.Day04 do
  import Enum

  def parse(args) do
    [f | r] = String.split(args, "\n\n")
    numbers = f |> String.split(",", trim: true) |> map(&String.to_integer/1)

    boards =
      r
      |> map(fn a_board ->
        a_board
        |> String.split("\n", trim: true)
        |> map(fn line -> String.split(line) |> map(&String.to_integer/1) end)
      end)

    {numbers, boards}
  end

  def winning_boards(boards, numbers),
    do: boards |> filter(fn board -> winning_board(board, numbers) end)

  def winning_board(board, numbers) do
    check_lines =
      any?(board, fn line ->
        count(MapSet.intersection(MapSet.new(line), MapSet.new(numbers))) == 5
      end)

    turned = for row <- 0..4, do: for(col <- 0..4, do: board |> at(col) |> at(row))

    check_cols =
      any?(turned, fn line ->
        count(MapSet.intersection(MapSet.new(line), MapSet.new(numbers))) == 5
      end)

    check_lines or check_cols
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
        else: {:halt, x * (wb |> List.first() |> extract_losers(acc) |> sum())}
    end)
  end

  def part2(args) do
    {numbers, board_list} = parse(args)

    Enum.reduce_while(numbers, {board_list, []}, fn x, {boards, acc} ->
      acc = [x | acc]
      wb = winning_boards(boards, acc)
      remaining_boards = boards |> filter(fn b -> not member?(wb, b) end)

      if count(remaining_boards) == 0 do
        {:halt, x * (wb |> List.first() |> extract_losers(acc) |> sum())}
      else
        {:cont, {remaining_boards, acc}}
      end
    end)
  end
end
