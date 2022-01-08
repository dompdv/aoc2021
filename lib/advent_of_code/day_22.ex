defmodule AdventOfCode.Day22 do
  import Enum

  @dim_max 50
  @dim_min -50
  def parse_line(line) do
    [switch, right] = String.split(line, " ")

    [x, y, z] =
      String.split(right, ",")
      |> map(fn s ->
        String.slice(s, 2..-1)
        |> String.split("..")
        |> map(&String.to_integer/1)
        |> List.to_tuple()
      end)

    {if(switch == "on", do: :on, else: :off), x, y, z}
  end

  def parse(args), do: args |> String.split("\n", trim: true) |> map(&parse_line/1)

  def set_cube(cuboid, {_switch, {xmin, xmax}, {ymin, ymax}, {zmin, zmax}})
      when xmin > @dim_max or ymin > @dim_max or zmin > @dim_max or xmax < @dim_min or
             ymax < @dim_min or zmax < @dim_min,
      do: cuboid

  def set_cube(cuboid, {switch, {xmin, xmax}, {ymin, ymax}, {zmin, zmax}}) do
    xmin = Kernel.max(@dim_min, xmin)
    ymin = Kernel.max(@dim_min, ymin)
    zmin = Kernel.max(@dim_min, zmin)
    xmax = Kernel.min(@dim_max, xmax)
    ymax = Kernel.min(@dim_max, ymax)
    zmax = Kernel.min(@dim_max, zmax)

    if switch == :off do
      cuboid |> Map.drop(for x <- xmin..xmax, y <- ymin..ymax, z <- zmin..zmax, do: {x, y, z})
    else
      cuboid
      |> Map.merge(
        for x <- xmin..xmax, y <- ymin..ymax, z <- zmin..zmax, into: %{}, do: {{x, y, z}, 1}
      )
    end
  end

  def part1(args) do
    parse(args)
    |> reduce(
      %{},
      fn command, cuboid -> set_cube(cuboid, command) end
    )
    |> count()
  end

  def disjoint({b1, h1}, {b2, h2}) when h1 < b2 or h2 < b1, do: true
  def disjoint(_, _), do: false

  def disjoint_cuboids({{xb1, xh1}, {yb1, yh1}, {zb1, zh1}}, {{xb2, xh2}, {yb2, yh2}, {zb2, zh2}}) do
    disjoint({xb1, xh1}, {xb2, xh2}) or disjoint({yb1, yh1}, {yb2, yh2}) or
      disjoint({zb1, zh1}, {zb2, zh2})
  end

  def belongs_to({{xb, xh}, {yb, yh}, {zb, zh}}, {x, y, z})
      when xb <= x and x <= xh and yb <= y and y <= yh and zb <= z and z <= zh,
      do: true

  def belongs_to(_, _), do: false

  def englob({b1, h1}, {b2, h2}), do: (b1 < b2 and h1 > h2) or (b2 < b1 and h2 > h1)

  def cuboid_included?({{xb1, xh1}, {yb1, yh1}, {zb1, zh1}}, {{xb2, xh2}, {yb2, yh2}, {zb2, zh2}})
      when xb1 >= xb2 and xh1 <= xh2 and yb1 >= yb2 and yh1 <= yh2 and zb1 >= zb2 and zh1 <= zh2,
      do: true

  def cuboid_included?(_, _), do: false

  def switch_off_intervals({b1, h1} = i1, i1), do: [[b1, h1]]

  def switch_off_intervals({b1, h1}, {b2, h2}) do
    cond do
      b1 < b2 ->
        cond do
          h1 < h2 -> [[b1, b2 - 1], [b2, h1], [h1 + 1, h2]]
          h1 == h2 -> [[b1, b2 - 1], [b2, h1]]
          h1 > h2 -> [[b1, b2 - 1], [b2, h2], [h2 + 1, h1]]
        end

      b1 > b2 ->
        cond do
          h1 < h2 -> [[b2, b1 - 1], [b1, h1], [h1 + 1, h2]]
          h1 == h2 -> [[b2, b1 - 1], [b1, h1]]
          h1 > h2 -> [[b2, b1 - 1], [b1, h2], [h2 + 1, h1]]
        end

      b1 == b2 ->
        cond do
          h1 < h2 -> [[b1, h1], [h1 + 1, h2]]
          h1 > h2 -> [[b1, h2], [h2 + 1, h1]]
        end
    end
  end

  def switch_off_overlapping_cuboids(
        {{xb1, xh1}, {yb1, yh1}, {zb1, zh1}} = c1,
        {{xb2, xh2}, {yb2, yh2}, {zb2, zh2}} = c2
      ) do
    for(
      [xb, xh] <- switch_off_intervals({xb1, xh1}, {xb2, xh2}),
      [yb, yh] <- switch_off_intervals({yb1, yh1}, {yb2, yh2}),
      [zb, zh] <- switch_off_intervals({zb1, zh1}, {zb2, zh2}),
      do: {{xb, xh}, {yb, yh}, {zb, zh}}
    )
    |> filter(fn {{xb, xh}, {yb, yh}, {zb, zh}} ->
      center = {div(xb + xh, 2), div(yb + yh, 2), div(zb + zh, 2)}
      belongs_to(c2, center) and not belongs_to(c1, center)
    end)
  end

  def switch_off_cuboid(c1, c2) do
    cond do
      disjoint_cuboids(c1, c2) -> [c2]
      cuboid_included?(c2, c1) -> []
      true -> switch_off_overlapping_cuboids(c1, c2)
    end
  end

  def merge_overlapping_cuboids(
        {{xb1, xh1}, {yb1, yh1}, {zb1, zh1}} = c1,
        {{xb2, xh2}, {yb2, yh2}, {zb2, zh2}} = c2
      ) do
    for(
      [xb, xh] <- switch_off_intervals({xb1, xh1}, {xb2, xh2}),
      [yb, yh] <- switch_off_intervals({yb1, yh1}, {yb2, yh2}),
      [zb, zh] <- switch_off_intervals({zb1, zh1}, {zb2, zh2}),
      do: {{xb, xh}, {yb, yh}, {zb, zh}}
    )
    |> filter(fn {{xb, xh}, {yb, yh}, {zb, zh}} ->
      center = {div(xb + xh, 2), div(yb + yh, 2), div(zb + zh, 2)}
      belongs_to(c1, center) or belongs_to(c2, center)
    end)
  end

  def merge_cuboids(c1, c2) do
    cond do
      disjoint_cuboids(c1, c2) -> [c1, c2]
      cuboid_included?(c1, c2) -> c2
      cuboid_included?(c2, c1) -> c1
      true -> merge_overlapping_cuboids(c1, c2)
    end
  end

  def clean_cuboid_list([]), do: []

  def clean_cuboid_list(l), do: clean_cuboid_list(l, [], false)

  def clean_cuboid_list([], acc, fired),
    do: if(fired, do: clean_cuboid_list(acc), else: acc)

  def clean_cuboid_list([{{xb1, xh1}, {yb1, yh1}, {zb1, zh1}} = c | r], acc, fired) do
    if any?(r, fn {{xb2, xh2}, {yb2, yh2}, {zb2, zh2}} ->
         xb1 >= xb2 and xh1 <= xh2 and yb1 >= yb2 and yh1 <= yh2 and zb1 >= zb2 and zh1 <= zh2
       end),
       do: clean_cuboid_list(r, acc, true),
       else: clean_cuboid_list(r, [c | acc], fired)
  end

  def club_cuboid_list([]), do: []

  def club_cuboid_list(l), do: club_cuboid_list(l, [], false)

  def club_cuboid_list([], acc, fired),
    do: if(fired, do: club_cuboid_list(acc), else: acc)

  def club_cuboid_list([c | r], acc, fired) do
    {new_list, clubbed, clubbed_cuboid} =
      reduce(r, {[], false, nil}, fn c1, {acc, found, c_cuboid} ->
        if found do
          {[c1 | acc], found, c_cuboid}
        else
          clubbed_cuboid = club_2_cuboids(c, c1)
          if clubbed_cuboid, do: {acc, true, clubbed_cuboid}, else: {[c1 | acc], false, c_cuboid}
        end
      end)

    if clubbed,
      do: club_cuboid_list(new_list, [clubbed_cuboid | acc], true),
      else: club_cuboid_list(new_list, [c | acc], fired)
  end

  def club_2_cuboids({{xb1, xh1}, {yb1, yh1}, {zb1, zh1}}, {{xb1, xh1}, {yb1, yh1}, {zb2, zh2}})
      when zb2 == zh1 + 1,
      do: {{xb1, xh1}, {yb1, yh1}, {zb1, zh2}}

  def club_2_cuboids({{xb1, xh1}, {yb1, yh1}, {zb1, zh1}}, {{xb1, xh1}, {yb1, yh1}, {zb2, zh2}})
      when zb1 == zh2 + 1,
      do: {{xb1, xh1}, {yb1, yh1}, {zb2, zh1}}

  def club_2_cuboids({{xb1, xh1}, {yb1, yh1}, {zb1, zh1}}, {{xb1, xh1}, {yb2, yh2}, {zb1, zh1}})
      when yb2 == yh1 + 1,
      do: {{xb1, xh1}, {yb1, yh2}, {zb1, zh1}}

  def club_2_cuboids({{xb1, xh1}, {yb1, yh1}, {zb1, zh1}}, {{xb1, xh1}, {yb2, yh2}, {zb1, zh1}})
      when yb1 == yh2 + 1,
      do: {{xb1, xh1}, {yb2, yh1}, {zb1, zh1}}

  def club_2_cuboids({{xb1, xh1}, {yb1, yh1}, {zb1, zh1}}, {{xb2, xh2}, {yb1, yh1}, {zb1, zh1}})
      when xb2 == xh1 + 1,
      do: {{xb1, xh2}, {yb1, yh1}, {zb1, zh1}}

  def club_2_cuboids({{xb1, xh1}, {yb1, yh1}, {zb1, zh1}}, {{xb2, xh2}, {yb1, yh1}, {zb1, zh1}})
      when xb1 == xh2 + 1,
      do: {{xb2, xh1}, {yb1, yh1}, {zb1, zh1}}

  def club_2_cuboids(_, _), do: false

  def on_cuboid([], new_cuboid), do: [new_cuboid]

  def on_cuboid(l, new_cuboid) do
    map(l, fn c -> merge_cuboids(new_cuboid, c) end)
    |> List.flatten()
    |> clean_cuboid_list()
    |> club_cuboid_list()
  end

  def off_cuboid(l, new_cuboid) do
    map(l, fn c ->
      switch_off_cuboid(new_cuboid, c)
    end)
    |> List.flatten()
    |> clean_cuboid_list()
    |> club_cuboid_list()
  end

  def count_on(l) do
    reduce(l, 0, fn {{xb, xh}, {yb, yh}, {zb, zh}}, acc ->
      acc + (xh - xb + 1) * (yh - yb + 1) * (zh - zb + 1)
    end)
  end

  def one_step({:on, xi, yi, zi}, cuboids), do: cuboids |> on_cuboid({xi, yi, zi})
  def one_step({:off, xi, yi, zi}, cuboids), do: cuboids |> off_cuboid({xi, yi, zi})

  def part2(args) do
    parse(args)
    |> reduce(
      [],
      fn command, cuboids ->
        new_cuboids = one_step(command, cuboids)
        IO.inspect({command, count_on(new_cuboids), count(new_cuboids)})
        new_cuboids
      end
    )
    |> count_on()
  end
end
