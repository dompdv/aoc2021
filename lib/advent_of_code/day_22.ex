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

  def disjoint({b1, h1}, {b2, h2}), do: Range.disjoint?(Range.new(b1, h1), Range.new(b2, h2))
  def englob({b1, h1}, {b2, h2}), do: (b1 < b2 and h1 > h2) or (b2 < b1 and h2 > h1)

  def disjoint_cuboids({{xb1, xh1}, {yb1, yh1}, {zb1, zh1}}, {{xb2, xh2}, {yb2, yh2}, {zb2, zh2}}) do
    disjoint({xb1, xh1}, {xb2, xh2}) or disjoint({yb1, yh1}, {yb2, yh2}) or
      disjoint({zb1, zh1}, {zb2, zh2})
  end

  def belongs_to({{xb1, xh1}, {yb1, yh1}, {zb1, zh1}}, {x, y, z}) do
    xb1 <= x and x <= xh1 and yb1 <= y and y <= yh1 and zb1 <= z and z <= zh1
  end

  def englobing_cuboids(
        {{xb1, xh1}, {yb1, yh1}, {zb1, zh1}},
        {{xb2, xh2}, {yb2, yh2}, {zb2, zh2}}
      ) do
    englob({xb1, xh1}, {xb2, xh2}) and englob({yb1, yh1}, {yb2, yh2}) and
      englob({zb1, zh1}, {zb2, zh2})
  end

  def switch_off_intervals({b1, h1}, {b2, h2}) do
    cond do
      b1 <= b2 and h1 >= h2 -> []
      b1 < b2 and h1 < h2 -> [[b1, b2 - 1], [b2, h1], [h1 + 1, h2]]
      b1 == b2 and h1 < h2 -> [[b1, h1], [h1 + 1, h2]]
      b1 > b2 and h1 < h2 -> [[b2, b1 - 1], [b1, h1], [h1 + 1, h2]]
      b1 > b2 and h1 >= h2 -> [[b2, b1 - 1], [b1, h1]]
    end
  end

  def switch_off_overlapping_cuboids(
        {{xb1, xh1}, {yb1, yh1}, {zb1, zh1}} = c1,
        {{xb2, xh2}, {yb2, yh2}, {zb2, zh2}} = c2
      ) do
    x_points = overlap_points({xb1, xh1}, {xb2, xh2})
    y_points = overlap_points({yb1, yh1}, {yb2, yh2})
    z_points = overlap_points({zb1, zh1}, {zb2, zh2})
    # IO.inspect({"off", x_points, y_points, z_points}, charlists: :as_lists)

    for(
      [xb, xh] <- x_points,
      [yb, yh] <- y_points,
      [zb, zh] <- z_points,
      do: {{xb, xh}, {yb, yh}, {zb, zh}}
    )
    |> filter(fn {{xb, xh}, {yb, yh}, {zb, zh}} ->
      not belongs_to(c1, {div(xb + xh, 2), div(yb + yh, 2), div(zb + zh, 2)}) and
        belongs_to(c2, {div(xb + xh, 2), div(yb + yh, 2), div(zb + zh, 2)})
    end)
  end

  def switch_off_cuboid(
        {{xb1, xh1}, {yb1, yh1}, {zb1, zh1}} = c1,
        {{xb2, xh2}, {yb2, yh2}, {zb2, zh2}} = c2
      ) do
    cond do
      disjoint_cuboids(c1, c2) -> [c2]
      xb1 <= xb2 and xh1 >= xh2 and yb1 <= yb2 and yh1 >= yh2 and zb1 <= zb2 and zh1 >= zh2 -> []
      true -> switch_off_overlapping_cuboids(c1, c2)
    end
  end

  def overlap_points({b1, h1} = i1, {b2, h2} = i2) do
    {b1, h1, b2, h2} = if b1 <= b2, do: {b1, h1, b2, h2}, else: {b2, h2, b1, h1}

    cond do
      i1 == i2 -> [[b1, h1]]
      h1 < b2 -> nil
      h1 >= b2 and h1 < h2 -> [[b1, b2 - 1], [b2, h1], [h1 + 1, h2]]
      h1 == h2 -> [[b1, b2 - 1], [b2, h2]]
      h1 > h2 -> [[b1, b2 - 1], [b2, h2], [h2 + 1, h1]]
    end
  end

  def merge_overlapping_cuboids(
        {{xb1, xh1}, {yb1, yh1}, {zb1, zh1}} = c1,
        {{xb2, xh2}, {yb2, yh2}, {zb2, zh2}} = c2
      ) do
    x_points = overlap_points({xb1, xh1}, {xb2, xh2})
    y_points = overlap_points({yb1, yh1}, {yb2, yh2})
    z_points = overlap_points({zb1, zh1}, {zb2, zh2})
    # IO.inspect({"on", x_points, y_points, z_points}, charlists: :as_lists)

    for(
      [xb, xh] <- x_points,
      [yb, yh] <- y_points,
      [zb, zh] <- z_points,
      do: {{xb, xh}, {yb, yh}, {zb, zh}}
    )
    |> filter(fn {{xb, xh}, {yb, yh}, {zb, zh}} ->
      belongs_to(c1, {div(xb + xh, 2), div(yb + yh, 2), div(zb + zh, 2)}) or
        belongs_to(c2, {div(xb + xh, 2), div(yb + yh, 2), div(zb + zh, 2)})
    end)
  end

  def merge_cuboids({{xb1, _xh1}, _, _} = c1, {{xb2, _}, _, _} = c2) do
    cond do
      disjoint_cuboids(c1, c2) -> [c1, c2]
      englobing_cuboids(c1, c2) -> if xb1 < xb2, do: c1, else: c2
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

  def on_cuboid([], new_cuboid), do: [new_cuboid]

  def on_cuboid(l, new_cuboid) do
    map(l, fn c -> merge_cuboids(new_cuboid, c) end)
    |> List.flatten()
    |> clean_cuboid_list()
  end

  def off_cuboid(l, new_cuboid) do
    map(l, fn c ->
      switch_off_cuboid(new_cuboid, c)
    end)
    |> List.flatten()
    |> clean_cuboid_list()
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
        new_cuboid = one_step(command, cuboids)
        IO.inspect({command, count_on(new_cuboid)})
        new_cuboid
      end
    )
    |> count_on()
  end
end
