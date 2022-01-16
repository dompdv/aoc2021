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
    {[a, b, c, d] ++ pv, new_r}
  end

  def packet_value([0, a, b, c, d | r]), do: {[a, b, c, d], r}

  def packet([]), do: nil

  def packet([a, b, c, 1, 0, 0 | r]) do
    {val, new_r} = packet_value(r)
    {%{type: :literal, tn: 4, version: to_number([a, b, c]), value: to_number(val)}, new_r}
  end

  def packet([
        a,
        b,
        c,
        ta,
        tb,
        tc,
        0,
        l1,
        l2,
        l3,
        l4,
        l5,
        l6,
        l7,
        l8,
        l9,
        l10,
        l11,
        l12,
        l13,
        l14,
        l15 | r
      ]) do
    len = to_number([l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11, l12, l13, l14, l15])
    target = count(r) - len

    {new_r, packets} =
      Stream.iterate(0, &(&1 + 1))
      |> reduce_while({r, []}, fn _n, {rest, acc} ->
        if count(rest) <= target do
          {:halt, {rest, acc}}
        else
          {new_packet, new_rest} = packet(rest)
          {:cont, {new_rest, [new_packet | acc]}}
        end
      end)

    {%{
       type: :operator,
       tn: to_number([ta, tb, tc]),
       version: to_number([a, b, c]),
       packets: reverse(packets)
     }, new_r}
  end

  def packet([a, b, c, ta, tb, tc, 1, l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11 | r]) do
    len = to_number([l1, l2, l3, l4, l5, l6, l7, l8, l9, l10, l11])

    {new_r, packets} =
      Stream.iterate(0, &(&1 + 1))
      |> reduce_while({r, []}, fn _n, {rest, acc} ->
        if count(acc) >= len do
          {:halt, {rest, acc}}
        else
          {new_packet, new_rest} = packet(rest)
          {:cont, {new_rest, [new_packet | acc]}}
        end
      end)

    {%{
       type: :operator,
       tn: to_number([ta, tb, tc]),
       version: to_number([a, b, c]),
       packets: reverse(packets)
     }, new_r}
  end

  def add_version_number(%{type: :literal, version: v}), do: v

  def add_version_number(%{type: :operator, version: v, packets: packets}),
    do: v + sum(map(packets, &add_version_number/1))

  def product(l), do: reduce(l, 1, &(&1 * &2))
  def compute(%{type: :literal, value: val}), do: val
  def compute(%{tn: 0, packets: packets}), do: packets |> map(&compute/1) |> sum()
  def compute(%{tn: 1, packets: packets}), do: packets |> map(&compute/1) |> product()
  def compute(%{tn: 2, packets: packets}), do: packets |> map(&compute/1) |> min()
  def compute(%{tn: 3, packets: packets}), do: packets |> map(&compute/1) |> max()

  def compute(%{tn: 5, packets: packets}),
    do: if(compute(at(packets, 0)) > compute(at(packets, 1)), do: 1, else: 0)

  def compute(%{tn: 6, packets: packets}),
    do: if(compute(at(packets, 0)) < compute(at(packets, 1)), do: 1, else: 0)

  def compute(%{tn: 7, packets: packets}),
    do: if(compute(at(packets, 0)) == compute(at(packets, 1)), do: 1, else: 0)

  def part1(args), do: parse(args) |> packet() |> elem(0) |> add_version_number()

  def part2(args), do: parse(args) |> packet() |> elem(0) |> compute()
end
