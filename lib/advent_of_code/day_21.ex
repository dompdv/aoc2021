defmodule AdventOfCode.Day21 do
  import Enum

  @outcomes for(i <- 1..3, j <- 1..3, k <- 1..3, do: [i, j, k]) |> map(&sum/1) |> frequencies()
  def move_by(shift, {pos, score}) do
    arrival = rem(pos - 1 + shift, 10) + 1
    {arrival, score + arrival}
  end

  def part1(_args) do
    {_turns, n_rolls, %{0 => {_, p1}, 1 => {_, p2}}} =
      Stream.cycle(1..100)
      |> Stream.chunk_every(3)
      |> reduce_while(
        {0, 0, %{0 => {7, 0}, 1 => {6, 0}}},
        fn rolls, {turn, n_rolls, players} ->
          if players |> map(fn {_, p} -> elem(p, 1) end) |> max() >= 1000 do
            {:halt, {turn, n_rolls, players}}
          else
            player_num = rem(turn, count(players))

            {:cont,
             {turn + 1, n_rolls + count(rolls),
              Map.put(players, player_num, move_by(sum(rolls), players[player_num]))}}
          end
        end
      )

    n_rolls * min([p1, p2])
  end

  def compute_outcomes(pos, score, n_events, board, wins_so_far) do
    # boucle sur chaque tirage possible. @outcome est %{tirage => nombres d'occurences}

    reduce(
      @outcomes,
      {board, wins_so_far},
      fn {rolls, outcomes}, {acc_board, acc_wins_so_far} ->
        # etant donné un jet de dés (rolls) et un nombre d'outcomes pour ce jet de dés
        # on calcule où on atterit (nouvelle position, nouveau score)
        {new_pos, new_score} = move_by(rolls, {pos, score})

        if new_score >= 21 do
          # si on a gagnés, on incrémente le compteur des victoires
          {acc_board, acc_wins_so_far + n_events * outcomes}
        else
          # si on n'a pas gagné, on va mettre à jour, dans le nouveau board, le nombre d'événements y conduisant
          previous_n_events = Map.get(acc_board, {new_pos, new_score}, 0)

          {Map.put(
             acc_board,
             {new_pos, new_score},
             # nombre d'événements de départ * le nombre d'outcomes du jet de dés
             previous_n_events + n_events * outcomes
           ), wins_so_far}
        end
      end
    )
  end

  def one_turn(event_board) do
    # Le board est un tableau d'états {position, score} => nombre d'événements aboutissant à cet état
    # renvoie un couple {new board, wins} "wins" est le nombre d'événements arrivant à 21 et plus

    # Boucle sur toutes les cases du du board.
    # on fabrique le board du tour suivant (accumulation des wins)
    reduce(event_board, {%{}, 0}, fn {{pos, score}, n_events}, {board, wins_so_far} ->
      compute_outcomes(pos, score, n_events, board, wins_so_far)
    end)
  end

  def move(board1, board2, win1, win2) do
    print_board(board1)
    if empty?(board1) or empty?(board2) do
      {win1, win2}
    else
      {board1, new_win1} = one_turn(board1)
      {board2, new_win2} = one_turn(board2)
      move(board1, board2, win1 + new_win1, win2 + new_win2)
    end
  end

  def print_board(board) do
    m = if empty?(board), do: 0, else:
    board |> Map.values() |> max() |> Integer.to_string() |> String.length()
    ["\n"] ++
    (for pos <- 1..10,
        do:
          for(
            score <- 0..20,
            do:
              Map.get(board, {pos, score}, 0) |> Integer.to_string() |> String.pad_leading(m + 1)
          ) |> join())
    |> join("\n")
    |> IO.puts()
  end

  def part2(_args) do
    # {a,_} = {%{{1, 0} => 1}, 0} |> one_turn() |> IO.inspect() |> one_turn()
    move(%{{4, 0} => 1}, %{{8, 0} => 1}, 0, 0)
  end
end
