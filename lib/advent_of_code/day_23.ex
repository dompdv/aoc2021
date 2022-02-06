defmodule Day23Temp do
  def replace_targets(map, targets) do
    for {from, tos} <- targets do
      from = if Map.has_key?(map, from), do: Map.get(map, from), else: from
      tos = for e <- tos, do: if(Map.has_key?(map, e), do: Map.get(map, e), else: e)
      {from, tos}
    end
    #|> Enum.sort(fn {_, a}, {_, b} -> length(a) < length(b) end)
    |> Enum.map(fn {from, tos} -> {from, for(to <- tos, do: {to, path(from, to)})} end)
    |> Map.new()

    #    |> List.flatten()
  end

  def path(to, to), do: []
  def path(12, 13), do: [13]
  def path(14, 15), do: [15]
  def path(16, 17), do: [17]
  def path(18, 19), do: [19]
  def path(from, to) when from in [13, 15, 17, 19], do: [from - 1] ++ path(from - 1, to)
  def path(from, to) when from in [12, 14, 16, 18], do: [from - 10] ++ path(from - 10, to)

  def path(from, to) when to == from + 1 or to == from - 1, do: [to]

  def path(from, to) when to < 11 and from < 11 and to < from,
    do: [from - 1] ++ path(from - 1, to)

  def path(from, to) when to < 11 and from < 11 and to > from,
    do: [from + 1] ++ path(from + 1, to)

  def path(from, to) when to in [12, 13] and from == 2, do: [12] ++ path(12, to)
  def path(from, to) when to in [12, 13] and from < 2, do: [from + 1] ++ path(from + 1, to)
  def path(from, to) when to in [12, 13] and from > 2, do: [from - 1] ++ path(from - 1, to)
  def path(from, to) when to in [14, 15] and from == 4, do: [14] ++ path(14, to)
  def path(from, to) when to in [14, 15] and from < 4, do: [from + 1] ++ path(from + 1, to)
  def path(from, to) when to in [14, 15] and from > 4, do: [from - 1] ++ path(from - 1, to)
  def path(from, to) when to in [16, 17] and from == 6, do: [16] ++ path(16, to)
  def path(from, to) when to in [16, 17] and from < 6, do: [from + 1] ++ path(from + 1, to)
  def path(from, to) when to in [16, 17] and from > 6, do: [from - 1] ++ path(from - 1, to)
  def path(from, to) when to in [18, 19] and from == 8, do: [18] ++ path(18, to)
  def path(from, to) when to in [18, 19] and from < 8, do: [from + 1] ++ path(from + 1, to)
  def path(from, to) when to in [18, 19] and from > 8, do: [from - 1] ++ path(from - 1, to)
end

defmodule AdventOfCode.Day23 do
  import Enum

  @targets_generic %{
    :a_l => [],
    :a_h => [:a_l],
    0 => [:a_l, :a_h],
    1 => [:a_l, :a_h],
    3 => [:a_l, :a_h],
    5 => [:a_l, :a_h],
    7 => [:a_l, :a_h],
    9 => [:a_l, :a_h],
    10 => [:a_l, :a_h],
    :b_l => [:a_l, :a_h, 0, 1, 3, 5, 7, 9, 10],
    :b_h => [:a_l, :a_h, 0, 1, 3, 5, 7, 9, 10],
    :c_l => [:a_l, :a_h, 0, 1, 3, 5, 7, 9, 10],
    :c_h => [:a_l, :a_h, 0, 1, 3, 5, 7, 9, 10],
    :d_l => [:a_l, :a_h, 0, 1, 3, 5, 7, 9, 10],
    :d_h => [:a_l, :a_h, 0, 1, 3, 5, 7, 9, 10]
  }

  @target_cases %{
    0 => %{a_l: 13, a_h: 12, b_l: 15, b_h: 14, c_l: 17, c_h: 16, d_l: 19, d_h: 18},
    1 => %{a_l: 15, a_h: 14, b_l: 13, b_h: 12, c_l: 17, c_h: 16, d_l: 19, d_h: 18},
    2 => %{a_l: 17, a_h: 16, b_l: 15, b_h: 14, c_l: 13, c_h: 12, d_l: 19, d_h: 18},
    3 => %{a_l: 19, a_h: 18, b_l: 15, b_h: 14, c_l: 17, c_h: 16, d_l: 13, d_h: 12}
  }

  @paths for {i, r} <- @target_cases,
               into: %{},
               do: {i, Day23Temp.replace_targets(r, @targets_generic)}

  @energy_consumption %{
    0 => 1,
    1 => 10,
    2 => 100,
    3 => 1000
  }

  @infinite 999_999_999_999

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

  def opened_hallway(hallway, occupied, inverse) do
    high = 12 + 2 * hallway
    low = high + 1

    # le hallway est ouvert dans deux cas: soit les deux cases sont vides, soit celle d'en haut est vide et celle d'en bas remplie par le bon type d'amphipod
    cond do
      not MapSet.member?(occupied, high) and not MapSet.member?(occupied, low) -> true
      not MapSet.member?(occupied, high) and Map.get(inverse, low) == hallway -> true
      true -> false
    end
  end

  def possible_move([a1, a2, b1, b2, c1, c2, d1, d2] = positions) do
    occupied_cells = MapSet.new(positions)
    inverse_pos = with_index(positions) |> Enum.map(fn {k, v} -> {k, div(v, 2)} end) |> Map.new()

    hallways =
      for h <- 0..3,
          into: %{},
          do:
            {h, opened_hallway(h, occupied_cells, inverse_pos)}
            |> IO.inspect()
  end

  def explore({_state, best_score, _moves, _energy, _win}, level) when level > 1,
    do: best_score

  def explore({state, best_score, moves, energy, win}, level) do
    print(state)
    p_moves = possible_move(state)

    for {who, _from, to} = move <- p_moves do
      new_state = List.update_at(state, who, fn _ -> to end)
      # IO.inspect(move)
      new_energy = energy + @energy_consumption[div(who, 2)]
      new_s = {new_state, best_score, [move | moves], new_energy, win}
      explore(new_s, level + 1)
    end
  end

  def part1(_args) do
    start = [13, 19, 12, 16, 14, 17, 15, 18]
    # explore({start, @infinite, [], 0, false}, 0)
    @paths
  end

  def part2(_args) do
  end
end
