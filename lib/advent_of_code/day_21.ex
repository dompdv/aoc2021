defmodule MemoDay21 do
  use Agent

  def start_link() do
    Agent.start_link(fn -> %{} end, name: __MODULE__)
  end

  def get(key) do
    Agent.get(__MODULE__, fn state -> Map.get(state, key) end)
  end

  def set(key, value) do
    Agent.update(__MODULE__, fn state -> Map.put_new_lazy(state, key, fn -> value end) end)
  end
end

defmodule AdventOfCode.Day21 do
  import Enum

  @outcomes for(i <- 1..3, j <- 1..3, k <- 1..3, do: [i, j, k]) |> map(&sum/1)
  @cross_outcomes (for a <- @outcomes, b <- @outcomes, do: {a,b}) |> frequencies()

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

  def init_cache() do

  end

  def wins(_pos1, score1, _pos2, _score2) when score1 >= 21, do: 1
  def wins(_pos1, _score1, _pos2, score2) when score2 >= 21, do: 0

  def wins(pos1, score1, pos2, score2) do
    memo = MemoDay21.get({pos1, score1, pos2, score2})
    if memo != nil do
      memo
    else
      @cross_outcomes |> map(fn {{rolls1, rolls2}, occurences} ->

        {new_pos1, new_score1} = move_by(rolls1, {pos1, score1})
        total_wins1 = occurences * wins(new_pos1, new_score1, pos2, score2)
        MemoDay21.set({new_pos1, new_score1, pos2, score2}, total_wins1)

        {new_pos2, new_score2} = move_by(rolls2, {pos2, score2})
        total_wins2 = total_wins1 + occurences * wins(new_pos1, new_score1, new_pos2, new_score2)
        MemoDay21.set({new_pos1, new_score1, new_pos2, new_score2}, total_wins2)
        total_wins2
      end) |> sum()

    end
  end
  def part2(_args) do
    #@cross_outcomes |> frequencies()
    MemoDay21.start_link()
    wins(4,0,8,0)
  end
end
