defmodule AdventOfCode.Day04 do
  import Enum

  def parse(args) do
    [f | r] = String.split(args, "\n\n")
    numbers = f |> String.split(",", trim: true) |> map(&String.to_integer/1)

    boards =
      r
      |> map(fn a_board ->
        straight =
          a_board
          |> String.split("\n", trim: true)
          |> map(fn line -> String.split(line) |> map(&String.to_integer/1) end)

        turned = for row <- 0..4, do: for(col <- 0..4, do: straight |> at(col) |> at(row))

        {MapSet.new(straight |> List.flatten()),
         map(straight, &MapSet.new/1) ++ map(turned, &MapSet.new/1)}
      end)

    {numbers, boards}
  end

  def winning_boards(boards, numbers),
    do: boards |> filter(fn board -> winning_board(board, numbers) end)

  def winning_board({_, board_groups}, numbers),
    do: any?(board_groups, fn group -> count(MapSet.intersection(group, numbers)) == 5 end)

  def extract_losers({list_n, _}, numbers) do
    filter(list_n, fn e -> not MapSet.member?(numbers, e) end)
  end

  def part1(args) do
    {numbers, boards} = parse(args)

    Enum.reduce_while(numbers, MapSet.new(), fn x, acc ->
      acc = MapSet.put(acc, x)
      wb = winning_boards(boards, acc)

      if empty?(wb),
        do: {:cont, acc},
        else: {:halt, x * (wb |> List.first() |> extract_losers(acc) |> sum())}
    end)
  end

  def part2(args) do
    {numbers, board_list} = parse(args)

    Enum.reduce_while(numbers, {board_list, MapSet.new()}, fn x, {boards, acc} ->
      acc = MapSet.put(acc, x)
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
