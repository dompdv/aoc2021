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

  def pqueue_remove(list, k), do: list |> filter(fn {keep, _} -> keep != k end)

  def pqueue_update(list, {k, d}) do
    {left, right} = split_while(list, fn {dk, _} -> dk != k end)
    case right do
      [] -> left ++ [{k,d}]
      [_ | r] ->  left ++ [{k,d} | r]
    end
  end

  def pqueue_add(list, l) when is_list(l) do
    reduce(l, list, fn c, a_list -> pqueue_addc(c, a_list) end)
  end
    def pqueue_addc(c, []), do: [c]

    def pqueue_addc({_, dc} = c, list) do
      {left, right} = split_while(list, fn {_, c} -> dc < c end)
      left ++ [c | right]
    end


#  def pqueue_add(list, c), do: pqueue_add(c, list, [])
#  def pqueue_add(nil, [], acc), do: reverse(acc)
#  def pqueue_add(c, [], acc), do: reverse([c | acc])

 # def pqueue_add(nil, [d | r], acc), do: pqueue_add(nil, r, [d | acc])

 # def pqueue_add({_, dc} = c, [{_, dd} = d | r], acc) when dc > dd,
 #   do: pqueue_add(c, r, [d | acc])

 # def pqueue_add(c, [d | r], acc), do: pqueue_add(nil, r, [d, c | acc])

  def spread(grid) do
    max_dim = Map.keys(grid) |> map(&Tuple.to_list/1) |> List.flatten() |> max()
    dist = for({k, _} <- grid, into: %{}, do: {k, 10 * max_dim * max_dim}) |> Map.put({0, 0}, 0)
    pqueue = pqueue_add([], Map.to_list(dist))

    spread(
      dist,
      pqueue,
      grid,
      max_dim
    )
  end

  def spread(dist, [], _grid, _max_dim), do: dist

  def spread(dist, [{{row, col}, _d} | rpqueue]=pqueue, grid, max_dim) do
    if :rand.uniform() > 0.99, do: IO.inspect(count(pqueue))
    neighbours =
      @neighbours
      |> map(fn {dr, dc} -> {row + dr, col + dc} end)
      |> filter(fn {r, c} -> r >= 0 and c >= 0 and r <= max_dim and c <= max_dim end)

    #IO.inspect({dist, pqueue, max_dim})
    {dist, rpqueue} =
      reduce(
        neighbours,
        {dist, rpqueue},
        fn {r, c}, {dist, rpqueue} ->
          alt = dist[{row, col}] + grid[{r, c}]

          if alt >= dist[{r, c}],
            do: {dist, rpqueue},
            else: {Map.put(dist, {r, c}, alt), pqueue_update(rpqueue, {{r, c}, alt})}
        end
      )

    spread(dist, rpqueue, grid, max_dim)
  end

  def part1(args) do
    grid = parse(args)
    dist = spread(grid)
    #for row <- 0..99, do: (for col <- 0..99, do: dist[{row, col}])

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
        {{big_row * (max_dim + 1) + row, big_col * (max_dim + 1) + col}, (if next > 9, do: next - 9, else: next)}
      end
    end |> List.flatten() |> Map.new()

    dist = spread(new_grid)
    max_dim = Map.keys(new_grid) |> map(&Tuple.to_list/1) |> List.flatten() |> max()
    for row <- 0..max_dim, do: (for col <- 0..max_dim, do: new_grid[{row, col}])
    dist[{max_dim, max_dim}]
  end
end
