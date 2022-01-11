defmodule AdventOfCode.Day16 do
  import Enum

  @codes %{
    ?0 => [0, 0, 0, 0],
    ?1 => [0, 0, 0, 1],
    ?2 => [0, 0, 1, 0],
    ?3 => [0, 0, 1, 1],
    ?4 => [0, 1, 0, 0],
    ?5 => [0, 1, 0, 1],
    ?6 => [0, 1, 1, 0],
    ?7 => [0, 1, 1, 1],
    ?8 => [1, 0, 0, 0],
    ?9 => [1, 0, 0, 1],
    ?A => [1, 0, 1, 0],
    ?B => [1, 0, 1, 1],
    ?C => [1, 1, 0, 0],
    ?D => [1, 1, 0, 1],
    ?E => [1, 1, 1, 0],
    ?F => [1, 1, 1, 1]
  }

  def parse(entry), do: entry |> String.to_charlist() |> map(fn l -> @codes[l] end) |> concat()

  def to_number(lzo),
    do: reduce(reverse(lzo), {1, 0}, fn n, {mul, acc} -> {mul * 2, acc + mul * n} end) |> elem(1)

  def packet_value([1, a, b, c, d | r]) do
    {pv, new_r} = packet_value(r)
    IO.inspect({"pv", r, new_r})
    {[a, b, c, d] ++ pv, new_r}
  end

  def packet_value([0, a, b, c, d | r]), do: {[a, b, c, d], r}

  def packet([]), do: nil
  def packet([a, b, c, 1, 0, 0| r]) do
    {val, new_r} = packet_value(r)
    {%{type: :literal, version: to_number([a,b,c]), value: to_number(val)}, new_r}
  end

  def packet([a, b, c, _, _, _, 0, l1,l2,l3,l4,l5,l6,l7,l8,l9,l10,l11,l12,l13,l14,l15 | r]) do
    len = to_number([l1,l2,l3,l4,l5,l6,l7,l8,l9,l10,l11,l12,l13,l14,l15])
    target = count(r) - len
    {new_r, packets} =
    Stream.iterate(0, &(&1+1))
    |> reduce_while({r, []}, fn _n, {rest, acc} ->
      IO.inspect({"acc", rest, acc })
      if count(rest) <= target do
        {:halt, {rest, acc}}
      else
        {new_packet, new_rest} = packet(rest)
        IO.inspect({"p", new_packet, new_rest, acc})
        {:cont, {new_rest, [new_packet|acc]}}
      end
    end)

    {%{type: :operator0, version: to_number([a,b,c]), packets: packets}, new_r}
  end

  def part1(args) do
    parse(args) |> packet()
  end

  def part2(_args) do
  end
end
