defmodule AdventOfCode.Day23 do
  import Enum
  @infinite 999_999_999_999

  @maze %{
    0 => [1],
    1 => [0, 2],
    2 => [1, 3, 11],
    3 => [2, 4],
    4 => [3, 5, 13],
    5 => [4, 6],
    6 => [5, 7, 15],
    7 => [6, 8],
    8 => [7, 9, 17],
    9 => [8, 10],
    10 => [9],
    11 => [2, 12],
    12 => [11],
    13 => [4, 14],
    14 => [13],
    15 => [6, 16],
    16 => [15],
    17 => [8, 18],
    18 => [17]
  }

  @index_to_pod %{0 => 1, 1 => 5, 2 => 2, 3 => 6, 4 => 3, 5 => 7, 6 => 4, 7 => 8}
  @pod_to_index %{1 => 0, 5 => 1, 2 => 2, 6 => 3, 3 => 4, 7 => 5, 4 => 6, 8 => 7}
  @energy_consumption %{1 => 1, 5 => 1, 2 => 10, 6 => 10, 3 => 100, 7 => 100, 4 => 1000, 8 => 1000}

  @forbidden_moves MapSet.new([
                     {1, 4, 13},
                     {5, 4, 13},
                     {1, 6, 15},
                     {5, 6, 15},
                     {1, 8, 17},
                     {5, 8, 17},
                     {2, 2, 11},
                     {6, 2, 11},
                     {2, 6, 15},
                     {6, 6, 15},
                     {2, 8, 17},
                     {6, 8, 17},
                     {3, 4, 13},
                     {7, 4, 13},
                     {3, 2, 11},
                     {7, 2, 11},
                     {3, 8, 17},
                     {7, 8, 17},
                     {4, 4, 13},
                     {8, 4, 13},
                     {4, 6, 15},
                     {8, 6, 15},
                     {4, 2, 11},
                     {8, 2, 11},
                     # Don't try to move if you're at the right place
                     {1, 12, 11},
                     {5, 12, 11},
                     {2, 14, 13},
                     {6, 14, 13},
                     {3, 16, 15},
                     {7, 16, 15},
                     {4, 18, 17},
                     {8, 18, 17}
                   ])
  def print_cell(i, [a1, a2, b1, b2, c1, c2, d1, d2]) do
    cond do
      a1 == i or a2 == i -> ?A
      b1 == i or b2 == i -> ?B
      c1 == i or c2 == i -> ?C
      d1 == i or d2 == i -> ?D
      true -> ?.
    end
  end

  def print(state) do
    l0 = for _ <- 1..13, do: ?#
    l1 = [?#] ++ for(i <- 0..10, do: print_cell(i, state)) ++ [?#]

    l2 = [
      32,
      32,
      ?#,
      print_cell(11, state),
      ?#,
      print_cell(13, state),
      ?#,
      print_cell(15, state),
      ?#,
      print_cell(17, state),
      ?#,
      32,
      32,
      32
    ]

    l3 = [
      32,
      32,
      ?#,
      print_cell(12, state),
      ?#,
      print_cell(14, state),
      ?#,
      print_cell(16, state),
      ?#,
      print_cell(18, state),
      ?#,
      32,
      32,
      32
    ]

    l4 = [32, 32, ?#, ?#, ?#, ?#, ?#, ?#, ?#, ?#, ?#, 32, 32]
    [l0, l1, l2, l3, l4] |> join("\n") |> IO.puts()
  end

  def possible_move([a1, a2, b1, b2, c1, c2, d1, d2] = positions, {who, from, to}) do
    occupied_cells = MapSet.new(positions)
    open_corridor_a = not MapSet.member?(occupied_cells, 11) and (a1 == 12 or a2 == 12)
    open_corridor_b = not MapSet.member?(occupied_cells, 13) and (b1 == 14 or b2 == 14)
    open_corridor_c = not MapSet.member?(occupied_cells, 15) and (c1 == 16 or c2 == 16)
    open_corridor_d = not MapSet.member?(occupied_cells, 17) and (d1 == 18 or d2 == 18)

    cond do
      # Pods able to enter their corridor => priority
      to == 2 and (who == 1 or who == 5) and open_corridor_a ->
        [{who, to, 11}]

      to == 4 and (who == 2 or who == 6) and open_corridor_b ->
        [{who, to, 13}]

      to == 6 and (who == 3 or who == 7) and open_corridor_c ->
        [{who, to, 15}]

      to == 8 and (who == 4 or who == 8) and open_corridor_d ->
        [{who, to, 17}]

      # pods cant stay
      to == 2 or to == 4 or to == 6 or to == 8 ->
        [{who, to, to - 1}, {who, to, to + 1}]

      true ->
        for {pos, pod} <- with_index(positions),
            do: for(dest <- @maze[pos], do: {@index_to_pod[pod], pos, dest})
    end
    |> List.flatten()
    |> filter(fn {pod, origin, dest} = move ->
      not (MapSet.member?(occupied_cells, dest) or MapSet.member?(@forbidden_moves, move) or
             move == {who, to, from})
    end)
  end

  def explore({_state, _last_move, best_score, _moves, _energy, _win}, level) when level > 7, do: best_score

  def explore({state, last_move, best_score, moves, energy, win}, level) do
    print(state)
    p_moves = possible_move(state, last_move)
    for {who, _from, to} = move <- p_moves do
      new_state = List.update_at(state, @pod_to_index[who], fn _ -> to end)
      #IO.inspect(move)
      new_energy = energy + @energy_consumption[who]
      new_s = {new_state, move, best_score, [move|moves], new_energy, win}
      explore(new_s, level + 1)
    end
  end

  def part1(_args) do
    start = [12, 18, 11, 15, 13, 16, 14, 17]
    explore({start, {nil, -1, -1}, @infinite, [], 0, false}, 0)
    :ok
  end

  def part2(_args) do
  end
end
