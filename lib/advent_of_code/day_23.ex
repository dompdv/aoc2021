defmodule AdventOfCode.Day23 do
  import Enum

  def path(to, to), do: []

  def path(from, to) when from > 11 and to < 11 do
    from_c = div(from, 100)
    charniere = from_c * 100
    path(from, charniere) ++ [from_c] ++ path(from_c, to)
  end

  def path(from, to) when from > 11 and to > 11 do
    from_c = div(from, 100)
    to_c = div(to, 100)

    if from_c == to_c do
      if from < to, do: [from + 1] ++ path(from + 1, to), else: [from - 1] ++ path(from - 1, to)
    else
      if rem(from, 100) == 0,
        do: [from_c] ++ path(from_c, to),
        else: [from - 1] ++ path(from - 1, to)
    end
  end

  def path(from, to) when to == from + 1 or to == from - 1, do: [to]

  def path(from, to) when to < 11 and from < 11 and to < from,
    do: [from - 1] ++ path(from - 1, to)

  def path(from, to) when to < 11 and from < 11 and to > from,
    do: [from + 1] ++ path(from + 1, to)

  def path(from, to) do
    from_c = div(to, 100)

    cond do
      from == from_c -> [from_c * 100] ++ path(from_c * 100, to)
      from < from_c -> [from + 1] ++ path(from + 1, to)
      from > from_c -> [from - 1] ++ path(from - 1, to)
    end
  end

  @energy_consumption %{
    0 => 1,
    1 => 10,
    2 => 100,
    3 => 1000
  }

  @infinite 999_999_999_999

  def print_cell(i, positions) do
    n_p = div(length(positions), 4)

    case Enum.find_index(positions, fn e -> e == i end) do
      nil -> ?.
      pos -> div(pos, n_p) + ?A
    end
  end

  def print(state) do
    l0 = for _ <- 1..13, do: ?#
    l1 = [?#] ++ for(i <- 0..10, do: print_cell(i, state)) ++ [?#]
    left = [?#, ?#, ?#]
    right = [?#, ?#]

    hallway_lines =
      for l <- 0..(div(length(state), 4) - 1) do
        left ++
          for(i <- [200 + l, 400 + l, 600 + l, 800 + l], do: [print_cell(i, state), ?#]) ++ right
      end

    l4 = [32, 32, ?#, ?#, ?#, ?#, ?#, ?#, ?#, ?#, ?#, 32, 32]
    ([l0, l1] ++ hallway_lines ++ [l4]) |> join("\n") |> IO.puts()
    IO.puts("")
  end

  def hallway_full(h, positions, oc, hallways) do
    p_c = div(length(positions), 4)
    {_hallway_l, hallway_s} = hallways[h]

    targets =
      slice(positions, (h - 1) * p_c, p_c)
      |> MapSet.new()
      |> MapSet.intersection(hallway_s)
      |> MapSet.size()

    all_amphis = oc |> MapSet.intersection(hallway_s) |> MapSet.size()

    cond do
      targets == p_c -> :full
      all_amphis > targets -> :mixed
      true -> :pure
    end
  end

  def hallway_analysis(positions, oc, hallways) do
    h_a = for h <- 1..4, do: hallway_full(h, positions, oc, hallways)
    final = all?(h_a, fn e -> e == :full end)
    if final, do: :win, else: h_a
  end

  def opened_hallway(hallway, occupied, inverse) do
    high = 200 + 2 * hallway
    low = high + 1

    # le hallway est ouvert dans deux cas: soit les deux cases sont vides, soit celle d'en haut est vide et celle d'en bas remplie par le bon type d'amphipod
    cond do
      not MapSet.member?(occupied, high) and not MapSet.member?(occupied, low) -> true
      not MapSet.member?(occupied, high) and Map.get(inverse, low) == hallway -> true
      true -> false
    end
  end

  def last_move(amphic, pos, oc) do
    cond do
      amphic == 0 and pos == 200 and not member?(oc, 201) -> 201
      amphic == 1 and pos == 400 and not member?(oc, 401) -> 401
      amphic == 2 and pos == 600 and not member?(oc, 601) -> 601
      amphic == 3 and pos == 800 and not member?(oc, 801) -> 801
      true -> nil
    end
  end

  def free(oc, cell), do: not MapSet.member?(oc, cell)
  def occupied(oc, cell), do: MapSet.member?(oc, cell)

  def possible_move(positions, h_analysis) do
    oc = MapSet.new(positions)
    h_to_inspect = (1 + find_index(h_analysis, fn e -> e == :pure end)) |> IO.inspect()

    if h_to_inspect != nil and occupied(oc, h_to_inspect * 200),
      do: possible_move_stack(h_to_inspect, oc, positions),
      else: possible_move_standard(positions, oc, h_analysis)
  end

  def possible_move_stack(h_to_inspect, oc, positions) do
    p_c = div(length(positions), 4)
    start = h_to_inspect * 200

    reduce_while((start + 1)..(start + p_c - 1), 0, fn cell, _acc ->
      if occupied(oc, cell) do
        {:cont, 0}
      else
        who = find_index(positions, fn e -> e == cell - 1 end)
        {:halt, {who, cell, @energy_consumption[h_to_inspect - 1]}}
      end
    end)
  end

  def reachable(oc, path_s), do: empty?(MapSet.intersection(oc, path_s))

  def possible_move_standard(positions, oc, h_analysis) do
    p_c = div(length(positions), 4)

    for {pos, amphi} <- with_index(positions) do
      amphic = div(amphi, p_c)
      hallway_status = at(h_analysis, amphic)

      if hallway_status == :full do
        IO.inspect({:full, amphi})
        []
      else
        target = 200 * (amphic + 1)
        in_hallway = pos >= target and pos < target + p_c

        if hallway_status == :pure and in_hallway do
          []
        else
          bercail = path(pos, target) |> MapSet.new()

          if hallway_status == :pure and reachable(oc, bercail) do
            [{amphi, target, MapSet.size(bercail) * @energy_consumption[amphic]}]
          else
            if pos < 11 do
              []
            else
              for(
                target <- [0, 1, 3, 5, 7, 9, 10],
                do: {target, path(pos, target) |> MapSet.new()}
              )
              |> filter(fn {_, path} -> empty?(MapSet.intersection(oc, path)) end)
              |> map(fn {target, p} ->
                {amphi, target, MapSet.size(p) * @energy_consumption[amphic]}
              end)
            end
          end
        end
      end
    end
    |> filter(fn l -> not empty?(l) end)
    |> List.flatten()
  end

  def explore(_state, best_score, _moves, _energy, _hallways, level) when level > 30,
    do: best_score

  def explore(state, best_score, moves, energy, hallways, level) do
    if level > 3 do
      IO.inspect(moves)
      print(state)
    end

    h_analysis = hallway_analysis(state, MapSet.new(state), hallways)
    #    case hallway_analysis(start, MapSet.new(start), hallways) do
    #      :win ->
    #        energy

    #     h_analysis ->
    #       p_moves = possible_move(state, h_analysis, hallways)
    #   end

    reduce(
      possible_move(state, h_analysis),
      best_score,
      fn {who, to, delta_energy} = move, current_best ->
        new_state = List.update_at(state, who, fn _ -> to end)
        new_energy = energy + delta_energy
        new_moves = [move | moves]

        new_best =
          if true do
            if new_energy < current_best do
              IO.inspect({"WIN", current_best, new_energy, new_moves})
              print(new_state)
              new_energy
            else
              current_best
            end
          else
            if new_energy >= current_best,
              do: current_best,
              else: explore(new_state, current_best, new_moves, new_energy, hallways, level + 1)
          end

        Kernel.min(new_best, current_best)
      end
    )
  end

  def part1(_args) do
    # start = [201, 801, 200, 600, 400, 601, 401, 800]
    start = [400, 801, 201, 601, 401, 600, 200, 800]
    start = [201, 601, 400, 401, 801, 600, 10, 800]
    start = [200, 201, 400, 401, 601, 600, 801, 1]
    start = [10, 201, 200, 601, 401, 600, 801, 1]

    print(start)

    hallways =
      for(h <- 1..4, do: {h, for(i <- 0..(div(length(start), 4) - 1), do: 200 * h + i)})
      |> map(fn {h, l} -> {h, {sort(l, :desc), MapSet.new(l)}} end)
      |> Map.new()

    h_analysis = hallway_analysis(start, MapSet.new(start), hallways)
   possible_move(start, h_analysis)

  end

  def part2(_args) do
  end
end
