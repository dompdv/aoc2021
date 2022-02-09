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

  def possible_move(positions, h_analysis, paths) do
    oc = MapSet.new(positions)
    h_to_inspect = find_index(h_analysis, fn e -> e == :pure end)

    if h_to_inspect != nil and occupied(oc,(1 + h_to_inspect) * 200),
      do: possible_move_stack(h_to_inspect, oc, positions),
      else: possible_move_standard(positions, oc, h_analysis, paths)
  end

  def possible_move_stack(h_to_inspect, oc, positions) do
    p_c = div(length(positions), 4)
    start = (1+h_to_inspect) * 200

    reduce_while((start + 1)..(start + p_c - 1), 0, fn cell, _acc ->
      if occupied(oc, cell) do
        {:cont, 0}
      else
        who = find_index(positions, fn e -> e == cell - 1 end)
        {:halt, [{who, cell, @energy_consumption[h_to_inspect]}]}
      end
    end)
  end

  def reachable(oc, path_s), do: empty?(MapSet.intersection(oc, path_s))

  def possible_move_standard(positions, oc, h_analysis, paths) do
    p_c = div(length(positions), 4)

    for {pos, amphi} <- with_index(positions) do
      amphic = div(amphi, p_c)
      hallway_status = at(h_analysis, amphic)

      if hallway_status == :full do
        []
      else
        target = 200 * (amphic + 1)
        in_hallway = pos >= target and pos < target + p_c

        if hallway_status == :pure and in_hallway do
          []
        else
          {bercail, l} = paths[{pos, target}]

          if hallway_status == :pure and reachable(oc, bercail) do
            [{amphi, target, l * @energy_consumption[amphic]}]
          else
            if pos < 11 do
              []
            else
              for(
                target <- [0, 1, 3, 5, 7, 9, 10],
                do: {target, paths[{pos, target}]}
              )
              |> filter(fn {_, {path, _}} -> empty?(MapSet.intersection(oc, path)) end)
              |> map(fn {target, {_, l}} ->
                {amphi, target, l * @energy_consumption[amphic]}
              end)
            end
          end
        end
      end
    end
    |> filter(fn l -> not empty?(l) end)
    |> List.flatten()
  end

 # def explore(_state, best_score, _moves, _energy, _hallways, _paths, level) when level > 60, do: best_score

  def explore(state, best_score, moves, energy, hallways, paths, level) do
    h_analysis = hallway_analysis(state, MapSet.new(state), hallways)

    if h_analysis == :win do
      IO.inspect(moves)
      print(state)
      IO.inspect({energy, best_score})
      Kernel.min(energy, best_score)
    else
      reduce(
        possible_move(state, h_analysis, paths),
        best_score,
        fn {who, to, delta_energy} = move, current_best ->
          new_state = List.update_at(state, who, fn _ -> to end)
          new_energy = energy + delta_energy
          new_moves = [move | moves]

          new_best =
              if new_energy >= current_best,
                do: current_best,
                else: explore(new_state, current_best, new_moves, new_energy, hallways, paths, level + 1)

          Kernel.min(new_best, current_best)
        end
      )
    end
  end

  def part1(_args) do
    # start = [201, 801, 200, 600, 400, 601, 401, 800]
    state = [400, 801, 201, 601, 401, 600, 200, 800]

    print(state)

    pos = [0,1,2,3,4,5,6,7,8,9,10,200,201,400,401,600,601,800,801]
    paths = (for from <- pos, to <- pos, do: {{from, to}, {path(from, to) |> MapSet.new(), length(path(from, to))}}) |> Map.new()
    hallways =
      for(h <- 1..4, do: {h, for(i <- 0..(div(length(state), 4) - 1), do: 200 * h + i)})
      |> map(fn {h, l} -> {h, {sort(l, :desc), MapSet.new(l)}} end)
      |> Map.new()

   # h_analysis = hallway_analysis(state, MapSet.new(state), hallways)
   #possible_move(state, h_analysis)
   explore(state, @infinite, [], 0, hallways, paths, 0)
  end

  def part2(_args) do

#############
#...........#
###B#C#B#D###
  #D#C#B#A#
  #D#B#A#C#
  #A#D#C#A#
  #########

  state = [203, 602, 801, 803, 200, 402, 600, 601, 400, 401, 603, 802, 201, 202, 403, 800]

# le mien
#############
#...........#
###D#A#C#D###
  #D#C#B#A#
  #D#B#A#C#
  #B#C#B#A#
  #########
  state = [400,602,801,803,203,402,601,603,401,403,600,802,200,201,202,800]
#  state = [1,201,202,203,400,401,402,403,600,601,602,603,800,801,802,803]

    print(state)

    pos = [0,1,2,3,4,5,6,7,8,9,10, 200,201,202,203, 400,401,402,403, 600,601,602,603, 800,801,802,803]
    paths = (for from <- pos, to <- pos, do: {{from, to}, {path(from, to) |> MapSet.new(), length(path(from, to))}}) |> Map.new()
    hallways =
      for(h <- 1..4, do: {h, for(i <- 0..(div(length(state), 4) - 1), do: 200 * h + i)})
      |> map(fn {h, l} -> {h, {sort(l, :desc), MapSet.new(l)}} end)
      |> Map.new()

   # h_analysis = hallway_analysis(state, MapSet.new(state), hallways)
   #possible_move(state, h_analysis)
   explore(state, 50000, [], 0, hallways, paths, 0)
  end
end
