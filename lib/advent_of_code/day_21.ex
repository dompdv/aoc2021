defmodule AdventOfCode.Day21 do
  import Enum

  def move_by(shift, {pos, score}) do
    arrival = rem(pos - 1 + shift, 10) + 1
    {arrival, score + arrival}
  end

  def part1(_args) do
    {_turns, n_rolls, %{0 => {_, p1}, 1 => {_, p2}}} =
    Stream.cycle(1..100)
    |> Stream.chunk_every(3)
    |> reduce_while({0, 0, %{0 => {7, 0}, 1 => {6, 0}}},
    fn rolls, {turn, n_rolls, players} ->
      if (players |> map(fn {_, p} -> elem(p, 1) end)) |> max() >= 1000 do
        {:halt, {turn, n_rolls, players}}
      else
        player_num = rem(turn, count(players))
        {:cont, {turn + 1, n_rolls + count(rolls), Map.put(players, player_num, move_by(sum(rolls), players[player_num]))}}
        end
    end)
    n_rolls * min([p1, p2])
  end

  def part2(_args) do
  end
end
