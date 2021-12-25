defmodule AdventOfCode.Day19 do
  import Enum

  #  @flip [[0, 1, 2], [2, 0, 1], [1, 2, 0]]
  @flip [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]
  @inversions for x <- [-1, 1], y <- [-1, 1], z <- [-1, 1], do: [x, y, z]
  @transfos for f <- @flip, i <- @inversions, do: {f, i}

  def parse(args),
    do: args |> String.split("\n\n", trim: true) |> map(&parse_scanner/1) |> Map.new()

  def parse_scanner(scanner) do
    [head | lines] = String.split(scanner, "\n", trim: true)
    [_, _, scanner_number, _] = String.split(head, " ", trim: true)

    lines =
      lines
      |> map(fn line ->
        String.split(line, ",") |> map(&String.to_integer/1) |> List.to_tuple()
      end)

    {String.to_integer(scanner_number), lines}
  end

  def move_scanner(scanner, {x, y, z}),
    do: map(scanner, fn {x1, y1, z1} -> {x + x1, y + y1, z + z1} end)

  def apply_transfo(scanner, {[f0, f1, f2], [i0, i1, i2]}) do
    scanner
    |> map(fn p ->
      {elem(p, f0) * i0, elem(p, f1) * i1, elem(p, f2) * i2}
    end)
  end

  def scan_coord(scan0, scan1, axis) do
    x0s = scan0 |> map(&elem(&1, axis)) |> MapSet.new()
    scan1_proj = scan1 |> map(&elem(&1, axis))

    {min0_c, max0_c} = min_max(x0s)
    {min1_c, max1_c} = min_max(scan1_proj)
    m = [min0_c, max0_c, min1_c, max1_c] |> map(&abs(&1)) |> max()

    search =
      (-2 * m)..(2 * m)
      |> filter(fn coord ->
        x1s = map(scan1_proj, fn x -> x + coord end) |> MapSet.new()
        MapSet.intersection(x0s, x1s) |> MapSet.size() >= 12
      end)

    if count(search) > 1, do: IO.inspect({"plusieurs", search})
    if empty?(search), do: false, else: hd(search)
  end

  def find_first_overlap(scanners) do
    for({i, scan0} <- scanners, {j, scan1} <- scanners, i < j, do: {i, scan0, j, scan1})
    |> reduce_while(
      nil,
      fn {i, scan0, j, scan1}, _ ->
        IO.inspect({i, j})

        common =
          @transfos
          |> map(fn transfo ->
            {transfo,
             map(0..2, fn axis -> scan_coord(scan0, apply_transfo(scan1, transfo), axis) end)}
          end)
          |> filter(fn {_, [x, y, z]} -> x != false and y != false and z != false end)

        if empty?(common), do: {:cont, nil}, else: {:halt, {i, j, common}}
      end
    )
  end

  def merge_scanners(scan0, scan1, transfo, {x, y, z} = move_by) do
    IO.inspect({"merge", transfo, move_by})
    new_scan1 = scan1 |> apply_transfo(transfo) |> move_scanner({x, y, z})
    MapSet.union(MapSet.new(new_scan1), MapSet.new(scan0)) |> MapSet.to_list()
  end

  def reduce_scanners(scanners) do
    if count(scanners) == 1 do
      scanners
    else
      IO.inspect({"reduce", count(scanners)})

      case find_first_overlap(scanners) do
        nil ->
          scanners

        {i, j, [{transfo, [x, y, z]}]} ->
          new_scan0 = merge_scanners(scanners[i], scanners[j], transfo, {x, y, z})
          reduce_scanners(scanners |> Map.delete(j) |> Map.put(i, new_scan0))
      end
    end
  end

  def part1(args) do
    parse(args)
    |> reduce_scanners()
    |> Map.to_list()
    |> List.first()
    |> elem(1)
    |> MapSet.new()
    |> count()

    #    Map.new([{0, scanners[0]}, {2, scanners[2]}])
  end

  def part2(_args) do
  end
end
