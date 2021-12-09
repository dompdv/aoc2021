defmodule AdventOfCode.Day09 do
  import Enum

  def parse(args) do
    grid =
      args
      |> String.split("\n", trim: true)
      |> map(&to_charlist/1)
      |> map(fn row -> map(row, &(&1 - ?0)) end)

    n_rows = count(grid) - 1
    n_cols = count(at(grid, 0)) - 1

    # La Grid est modélisée par une  Map %{{row,col} => valeur}
    {for(
       row <- 0..n_rows,
       col <- 0..n_cols,
       into: %{},
       do: {{row, col}, grid |> at(row) |> at(col)}
     ), n_rows, n_cols}
  end

  def is_local_min(grid, {row, col}) do
    [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
    # toutes les 4 cases environnantes doivent être plus hautes (l'extérieur de la grille est plus haut)
    |> map(fn {dr, dc} -> grid[{row, col}] < Map.get(grid, {row + dr, col + dc}, 10) end)
    |> all?()
  end

  def part1(args) do
    {grid, n_rows, n_cols} = parse(args)

    for(row <- 0..n_rows, col <- 0..n_cols, do: {row, col})
    |> map(fn {row, col} ->
      if is_local_min(grid, {row, col}), do: grid[{row, col}] + 1, else: 0
    end)
    |> sum()
  end

  def candidate(grid, acc, row, col, dr, dc) do
    v = Map.get(grid, {row + dr, col + dc}, -1)
    # les cases qui sont candidates pour faire partie du bassin et qu'il faut considérer sont
    # - celles qui ne sont pas déjà dans le bassin (acc) (éviter les doublons)
    # - qui ne sont pas 9
    # - qui sont au dessus de la case courante (on "remonte" le bassin)
    cond do
      member?(acc, {row + dr, col + dc}) -> []
      v == 9 -> []
      v > grid[{row, col}] -> {row + dr, col + dc}
      true -> []
    end
  end

  def spread(grid, basin), do: spread(grid, [basin], [basin])
  def spread(_grid, [], acc), do: acc

  def spread(grid, [{row, col} | r], acc) do
    # on va étendre (spread) le bassin à partir d'une liste cases à considérer
    # deux paramètres fondamentaux
    # - la liste des cases à considérer
    # - la liste des cases déjà identifiées dans le bassin (acc)

    # on détermine parmi les 4 cases autour celles qui font partie du bassin
    to_add =
      [{-1, 0}, {1, 0}, {0, -1}, {0, 1}]
      |> map(fn {dr, dc} -> candidate(grid, acc, row, col, dr, dc) end)
      # petit truc pour simplifier les retours vides ( List.flatten([1, [], 2]) == [1,2])
      |> List.flatten()
    # relancer la recherche jusqu'à épuisement des cases à considérer
    spread(grid, to_add ++ r, to_add ++ acc)
  end

  def part2(args) do
    {grid, n_rows, n_cols} = parse(args)

    for(row <- 0..n_rows, col <- 0..n_cols, do: {row, col})
    # trouve d'abord les points les plus bas. Chaque bassin va partir de ces points
    |> filter(&is_local_min(grid, &1))
    # calcule les bassins à partir de chaque point bas
    |> map(fn b -> spread(grid, b) end)
    # compte le nombre d'éléments par bassin et garde les 3 plus gros
    |> map(&count/1)
    |> sort(:desc)
    |> take(3)
    # mumtiplie les tailles des bassins entre elles
    |> reduce(1, &(&1 * &2))
  end
end
