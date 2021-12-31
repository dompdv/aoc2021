defmodule AdventOfCode.Day21 do
  import Enum

  # |> frequencies()
  @outcomes for(i <- 1..3, j <- 1..3, k <- 1..3, do: [i, j, k]) |> map(&sum/1)
  @outcomes_cross for(i <- @outcomes, j <- @outcomes, do: {i, j}) |> frequencies()
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

  def compute_outcomes(pos1, score1, pos2, score2, n_events, board, wins_so_far1, wins_so_far2) do
    reduce(
      @outcomes_cross,
      {board, wins_so_far1, wins_so_far2},
      fn {{rolls1, rolls2}, occurences}, {acc_board, acc_wins_so_far1, acc_wins_so_far2} ->
        {new_pos1, new_score1} = move_by(rolls1, {pos1, score1})
        {new_pos2, new_score2} = move_by(rolls2, {pos2, score2})
        new_events = n_events * occurences

        if new_score1 >= 21 do
          {acc_board, acc_wins_so_far1 + new_events, acc_wins_so_far2}
        else
          if new_score2 >= 21 do
            {acc_board, acc_wins_so_far1, acc_wins_so_far2 + new_events}
          else
            previous_n_events =
              Map.get(acc_board, {new_pos1, new_score1, new_pos2, new_score2}, 0)

            {Map.put(
               acc_board,
               {new_pos1, new_score1, new_pos2, new_score2},
               previous_n_events + new_events
             ), acc_wins_so_far1, acc_wins_so_far2}
          end
        end
      end
    )
  end

  def one_turn(event_board, win1, win2) do
    # Le board est un tableau d'états {position1, score1, position2, score2} => nombre d'événements aboutissant à cet état
    # renvoie un couple {new board, wins} "wins" est le nombre d'événements arrivant à 21 et plus
    reduce(
      event_board,
      {%{}, win1, win2},
      fn {{pos1, score1, pos2, score2}, n_events}, {board, wins_so_far1, wins_so_far2} ->
        compute_outcomes(pos1, score1, pos2, score2, n_events, board, wins_so_far1, wins_so_far2)
      end
    )
  end

  def move(board, win1, win2, turn) do
    if empty?(board) do
      {win1, win2}
    else
      {board, win1p, win2p} = one_turn(board, win1, win2)
      IO.inspect({win1p, win2p})
      move(board, win1p, win2p, turn + 1)
    end
  end

  def part2(_args) do
    move(%{{4, 0, 8, 0} => 1}, 0, 0, 0)
  end
end
