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

  def merge_intervals([a]=l), do: [a,a]
  def merge_intervals([{_b1, h1}, {b2, _h2}]=l) when h1 < b2, do: l
  def merge_intervals([{b1, h1}, {_b2, h2}]), do: [{b1, max([h1, h2])}, :merge]


  def clean_intervals(intervals), do: clean_intervals(intervals, [], false)
  def clean_intervals([{b1, h1}, {b2, h2}|r], acc, merged) when (h1 + 1) < b2, do: clean_intervals([{b2,h2}|r], [{b1,h1}|acc], merged)
  def clean_intervals([{b1, h1}, {b2, h2}|r], acc, _merged) when b2 <= (h1 + 1), do: clean_intervals(r, [{b1, max([h1, h2])}|acc], true)
  def clean_intervals([i], acc, merged) do
    if merged, do: clean_intervals(reverse([i|acc]), [], false), else: reverse([i|acc])
  end

  def add_interval(l, interval), do: sort([interval | l]) |> clean_intervals()

  def part2(_args) do
    [] |> add_interval({10, 15}) |> add_interval({20, 25}) |> add_interval({5, 13}) |> add_interval({8, 18}) |> add_interval({30, 32})
    |> IO.inspect()

  end
end
