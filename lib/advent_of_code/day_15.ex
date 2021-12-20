defmodule AdventOfCode.Day15 do
  import Enum

  @neighbours [{1, 0}, {0, 1}, {0, -1}, {-1, 0}]

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn line -> to_charlist(line) |> map(&(&1 - ?0)) end)
    |> with_index()
    |> map(fn {line, i} -> for {c, j} <- with_index(line), do: {{i, j}, c} end)
    |> List.flatten()
    |> Map.new()
  end

  def spread(grid) do
    cells = Map.keys(grid)
    max_dim = cells |> map(&Tuple.to_list/1) |> List.flatten() |> max()
    dist = for({k, _} <- grid, into: %{}, do: {k, 10 * max_dim * max_dim}) |> Map.put({0, 0}, 0)

    spread(
      dist,
      cells,
      grid,
      max_dim
    )
  end

  def min_dist([], _dist, _current_min, current_node, acc), do: {current_node, acc}

  def min_dist([elt | r], dist, current_min, current_node, acc) do
    d = dist[elt]

    if d < current_min,
      do: min_dist(r, dist, d, elt, if(current_node == nil, do: acc, else: [current_node | acc])),
      else: min_dist(r, dist, current_min, current_node, [elt | acc])
  end

  def spread(dist, [], _grid, _max_dim), do: dist

  def spread(dist, pqueue, grid, max_dim) do
    if :rand.uniform() > 0.99, do: IO.inspect(count(pqueue))
    # IO.inspect(pqueue)
    {{row, col}, new_queue} = min_dist(pqueue, dist, 10 * max_dim * max_dim, nil, [])

    neighbours =
      @neighbours
      |> map(fn {dr, dc} -> {row + dr, col + dc} end)
      |> filter(fn {r, c} -> r >= 0 and c >= 0 and r <= max_dim and c <= max_dim end)

    dist =
      reduce(
        neighbours,
        dist,
        fn {r, c}, dist ->
          alt = dist[{row, col}] + grid[{r, c}]

          if alt >= dist[{r, c}],
            do: dist,
            else: Map.put(dist, {r, c}, alt)
        end
      )

    spread(dist, new_queue, grid, max_dim)
  end

  def part1(args) do
    grid = parse(args)
    dist = spread(grid)
    max_dim = Map.keys(grid) |> map(&Tuple.to_list/1) |> List.flatten() |> max()
    dist[{max_dim, max_dim}]
  end

  def part2(args) do
    grid = parse(args)
    max_dim = Map.keys(grid) |> map(&Tuple.to_list/1) |> List.flatten() |> max()

    new_grid =
      for big_row <- 0..4, big_col <- 0..4 do
        for row <- 0..max_dim, col <- 0..max_dim do
          next = grid[{row, col}] + big_row + big_col

          {{big_row * (max_dim + 1) + row, big_col * (max_dim + 1) + col},
           if(next > 9, do: next - 9, else: next)}
        end
      end
      |> List.flatten()
      |> Map.new()

    dist = spread(new_grid)
    max_dim = Map.keys(new_grid) |> map(&Tuple.to_list/1) |> List.flatten() |> max()
    dist[{max_dim, max_dim}]
  end
end
