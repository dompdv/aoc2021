defmodule AdventOfCode.Day23 do
  import Enum
  @infinite 999_999_999_999

  @maze %{
    0 => %{
      0 => [1],
      1 => [0, 2],
      2 => [1, 3, 12],
      3 => [2, 4],
      4 => [3, 5],
      5 => [4, 6],
      6 => [5, 7],
      7 => [6, 8],
      8 => [7, 9],
      9 => [8, 10],
      10 => [9],
      12 => [2, 13],
      13 => [],
      14 => [4, 15],
      15 => [14],
      16 => [6, 17],
      17 => [16],
      18 => [8, 19],
      19 => [18]
    },
    1 => %{
      0 => [1],
      1 => [0, 2],
      2 => [1, 3],
      3 => [2, 4],
      4 => [3, 5, 14],
      5 => [4, 6],
      6 => [5, 7],
      7 => [6, 8],
      8 => [7, 9],
      9 => [8, 10],
      10 => [9],
      12 => [2, 13],
      13 => [12],
      14 => [4, 15],
      15 => [],
      16 => [6, 17],
      17 => [16],
      18 => [8, 19],
      19 => [18]
    },
    2 => %{
      0 => [1],
      1 => [0, 2],
      2 => [1, 3],
      3 => [2, 4],
      4 => [3, 5],
      5 => [4, 6],
      6 => [5, 7, 16],
      7 => [6, 8],
      8 => [7, 9],
      9 => [8, 10],
      10 => [9],
      12 => [2, 13],
      13 => [12],
      14 => [4, 15],
      15 => [14],
      16 => [6, 17],
      17 => [],
      18 => [8, 19],
      19 => [18]
    },
    3 => %{
      0 => [1],
      1 => [0, 2],
      2 => [1, 3],
      3 => [2, 4],
      4 => [3, 5],
      5 => [4, 6],
      6 => [5, 7],
      7 => [6, 8],
      8 => [7, 9, 18],
      9 => [8, 10],
      10 => [9],
      12 => [2, 13],
      13 => [12],
      14 => [4, 15],
      15 => [14],
      16 => [6, 17],
      17 => [16],
      18 => [8, 19],
      19 => []
    }
  }

  @energy_consumption %{
    0 => 1,
    1 => 10,
    2 => 100,
    3 => 1000
  }

  def print_cell(i, [a1, a2, b1, b2, c1, c2, d1, d2]) do
    cond do
      a1 == i -> ?A
      a2 == i -> ?a
      b1 == i -> ?B
      b2 == i -> ?b
      c1 == i -> ?C
      c2 == i -> ?c
      d1 == i -> ?D
      d2 == i -> ?d
      true -> ?.
    end
  end

  def print(state) do
    l0 = for _ <- 1..13, do: ?#
    l1 = [?#] ++ for(i <- 0..10, do: print_cell(i, state)) ++ [?#]
    left = [?#, ?#, ?#]
    right = [?#, ?#]
    l2 = left ++ for(i <- [12, 14, 16, 18], do: [print_cell(i, state), ?#]) ++ right
    l3 = left ++ for(i <- [13, 15, 17, 19], do: [print_cell(i, state), ?#]) ++ right
    l4 = [32, 32, ?#, ?#, ?#, ?#, ?#, ?#, ?#, ?#, ?#, 32, 32]
    [l0, l1, l2, l3, l4] |> join("\n") |> IO.puts()
    IO.puts("")
  end

  def possible_move([a1, a2, b1, b2, c1, c2, d1, d2] = positions, {who, from, to}) do
    occupied_cells = MapSet.new(positions)
    open_corridor_a = not MapSet.member?(occupied_cells, 12) and (a1 == 13 or a2 == 13)
    open_corridor_b = not MapSet.member?(occupied_cells, 14) and (b1 == 15 or b2 == 15)
    open_corridor_c = not MapSet.member?(occupied_cells, 16) and (c1 == 17 or c2 == 17)
    open_corridor_d = not MapSet.member?(occupied_cells, 18) and (d1 == 19 or d2 == 19)

    cond do
      # Pods able to enter their corridor => priority
      to == 2 and (who == 0 or who == 1) and open_corridor_a ->
        [{who, to, 12}]

      to == 4 and (who == 2 or who == 3) and open_corridor_b ->
        [{who, to, 14}]

      to == 6 and (who == 4 or who == 5) and open_corridor_c ->
        [{who, to, 16}]

      to == 8 and (who == 6 or who == 7) and open_corridor_d ->
        [{who, to, 18}]

      # pods cant stay
      to == 2 or to == 4 or to == 6 or to == 8 ->
        [{who, to, to - 1}, {who, to, to + 1}]

      true ->
        for {pos, pod} <- with_index(positions),
            do: for(dest <- @maze[div(pod, 2)][pos], do: {pod, pos, dest})
    end
    |> List.flatten()
    |> filter(fn {_pod, _origin, dest} = move ->
      not (MapSet.member?(occupied_cells, dest) or move == {who, to, from})
    end)
  end

  def explore({_state, _last_move, best_score, _moves, _energy, _win}, level) when level > 1,
    do: best_score

  def explore({state, last_move, best_score, moves, energy, win}, level) do
    print(state)
    p_moves = possible_move(state, last_move)

    for {who, _from, to} = move <- p_moves do
      new_state = List.update_at(state, who, fn _ -> to end)
      # IO.inspect(move)
      new_energy = energy + @energy_consumption[div(who, 2)]
      new_s = {new_state, move, best_score, [move | moves], new_energy, win}
      explore(new_s, level + 1)
    end
  end

  def part1(_args) do
    start = [13, 19, 12, 16, 14, 17, 15, 18]
    explore({start, {nil, -1, -1}, @infinite, [], 0, false}, 0)
    :ok
  end

  def part2(_args) do
  end
end
