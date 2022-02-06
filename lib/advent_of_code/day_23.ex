defmodule AdventOfCode.Day23 do
  import Enum
  @infinite 999_999_999_999


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
    inverse_pos = with_index(positions) |> Enum.map(fn {k,v} -> {k, div(v,2)} end) |> Map.new()

    hallways = for h <- 0..3, into: %{}, do: {h, opened_hallway(h, occupied_cells, inverse_pos)}

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
    explore({start, @infinite, [], 0, false}, 0)
    :ok
  end

  def part2(_args) do
  end
end
