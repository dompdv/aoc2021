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
      cuboid |> Map.drop(for x <- xmin..xmax, y <- ymin..ymax, z <- zmin..zmax, do: {x,y,z})
    else
      cuboid |> Map.merge((for x <- xmin..xmax, y <- ymin..ymax, z <- zmin..zmax, into: %{}, do: {{x,y,z},1}))
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

  def part2(_args) do
  end
end
