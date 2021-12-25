defmodule AdventOfCode.Day19 do
  import Enum

  @flip [[0, 1, 2], [2, 0, 1], [1, 2, 0]]
  @inversions [
    [1, 1, 1],
    [1, 1, -1],
    [1, -1, 1],
    [1, -1, -1],
    [-1, 1, 1],
    [-1, 1, -1],
    [-1, -1, 1],
    [-1, -1, -1]
  ]
  @transfos for f <- @flip, i <- @inversions, do: {f, i}

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

  def scalars(scanner, index) do
    {x0, y0, z0} = at(scanner, 0)
    origin_b_0 = scanner |> map(fn {x, y, z} -> {x - x0, y - y0, z - z0} end)

    for {{x1, y1, z1}, _i} <- with_index(origin_b_0),
        {{x2, y2, z2}, _j} <- with_index(origin_b_0),
        do: x1 * x2 + y1 * y2 + z1 * z2
  end

  def move_scanner(scanner, {x, y, z}),
    do: map(scanner, fn {x1, y1, z1} -> {x + x1, y + y1, z + z1} end)

  def dist_scanners(scanner1, scanner2, p) do
    scanner2 = move_scanner(scanner2, p)

    distances =
      for(
        {x2, y2, z2} <- scanner2,
        do:
          for(
            {x1, y1, z1} <- scanner1,
            do: (x1 - x2) * (x1 - x2) + (y1 - y2) * (y1 - y2) + (z1 - z2) * (z1 - z2)
          )
          |> min()
          |> :math.sqrt()
      )

    nuls = filter(distances, &(&1 == 0)) |> count()

    # IO.inspect({"nulllllls", nuls})
    sum(distances)
  end

  def gradient(scanner1, scanner2, {x, y, z}) do
    d = dist_scanners(scanner1, scanner2, {x, y, z})
    dx = dist_scanners(scanner1, scanner2, {x + 1, y, z})
    dy = dist_scanners(scanner1, scanner2, {x, y + 1, z})
    dz = dist_scanners(scanner1, scanner2, {x, y, z + 1})
    {{dx - d, dy - d, dz - d}, d}
  end

  def move({x, y, z}, {gx, gy, gz}, alpha),
    do: {round(x + alpha * gx), round(y + alpha * gy), round(z + alpha * gz)}

  def apply_transfo(scanner, {[f0, f1, f2], [i0, i1, i2]}) do
    scanner
    |> map(fn p ->
      {elem(p, f0) * i0, elem(p, f1) * i1, elem(p, f2) * i2}
    end)
  end

  def part1(args) do
    scanners = args |> String.split("\n\n", trim: true) |> map(&parse_scanner/1) |> Map.new()
    alpha = 0.5

    Map.put(scanners, 1, move_scanner(scanners[0], {50, 20, 30}))

    a = [
      @transfos
      |> List.first()
    ]

    a
    |> map(fn transfo ->
      scanner1 = apply_transfo(scanners[1], transfo)

      res =
        Stream.iterate({{0, 0, 0}, nil, nil, 0}, fn {{x, y, z}, _g, _d, step} = r ->
          IO.inspect({">", r})
          {{gx, gy, gz}, d} = gradient(scanners[0], scanner1, {x, y, z})
          {move({x, y, z}, {gx, gy, gz}, alpha), {gx, gy, gz}, d, step + 1}
        end)
        |> Stream.drop_while(fn {_, _, _, step} -> step < 100 end)
        |> take(1)

      IO.inspect({transfo, res})
    end)

    :ok
  end

  def part1_old(args) do
    scanners = args |> String.split("\n\n", trim: true) |> map(&parse_scanner/1) |> Map.new()

    # origin_b_0 = scanners[0] |> map(fn {x,y,z} -> {x-x0, y-y0, z-z0} end)
    # scalar_b_0 = (for {{x1,y1,z1},i} <- with_index(origin_b_0), {{x2,y2,z2},j} <- with_index(origin_b_0), do: {i,j, x1*x2 + y1*y2 + z1*z2})

    for i0 <- 0..(count(scanners[0]) - 1), i1 <- 0..(count(scanners[1]) - 1) do
      s0 = MapSet.new(scalars(scanners[0], i0))
      s1 = MapSet.new(scalars(scanners[1], i1))
      MapSet.intersection(s0, s1) |> count()
    end
    |> filter(&(&1 > 2))
  end

  def part2(_args) do
  end
end
