defmodule AdventOfCode.Day17 do
  import Enum

  def compute_trajectory({x, y}, _, x_min..x_max, y_min..y_max, traj)
      when x >= x_min and x <= x_max and y >= y_min and y <= y_max,
      do: {:boum, reverse(traj)}

  def compute_trajectory({x, _y}, {vx, _vy}, _x_min..x_max, _, traj)
      when x > x_max and vx >= 0,
      do: {:miss, traj}

  def compute_trajectory({x, _y}, {vx, _vy}, x_min.._x_max, _, traj)
      when x < x_min and vx <= 0,
      do: {:miss, traj}

  def compute_trajectory({_x, y}, {_vx, vy}, _, y_min.._y_max, traj)
      when y < y_min and vy < 0,
      do: {:miss, traj}

  def compute_trajectory({x, y}, {vx, vy}, x_range, y_range, traj) do
    # IO.inspect({x, y, vx, vy})
    {x, y} = {x + vx, y + vy}

    vx =
      cond do
        vx == 0 -> 0
        vx > 0 -> vx - 1
        vx < 0 -> vx + 1
      end

    vy = vy - 1
    # IO.inspect({"recur", {x, y}, {vx, vy}, x_range, y_range, [{x, y} | traj]})
    compute_trajectory({x, y}, {vx, vy}, x_range, y_range, [{x, y} | traj])
  end

  def part1(_args) do
    #x=117..164, y=-140..-89
    x_range = 117..164
    y_range = -140..-89


    grid = for vx <- 1..(x_range.last + 1), vy <- -200..1000, do: {vx, vy}

    grid
    |> map(fn v ->
      trajectory = compute_trajectory({0, 0}, v, x_range, y_range, [])
      {v, trajectory |> elem(0), trajectory |> elem(1) |> map(&elem(&1, 1)) |> max()}
    end)
    |> filter(fn {_, s, _} -> s == :boum end)
    |> map(&(elem(&1, 2)))  |> max()
  end

  def part2(_args) do
    x_range = 117..164
    y_range = -140..-89


    grid = for vx <- 1..(x_range.last + 1), vy <- -200..1000, do: {vx, vy}

    grid
    |> map(fn v ->
      trajectory = compute_trajectory({0, 0}, v, x_range, y_range, [])
      {v, trajectory |> elem(0), trajectory |> elem(1) |> map(&elem(&1, 1)) |> max()}
    end)
    |> filter(fn {_, s, _} -> s == :boum end)
    |> count()
  end
end
