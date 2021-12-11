defmodule AdventOfCode.Day11 do
  import Enum

  @coords for row <- 0..9, col <- 0..9, do: {row, col}
  @drowcol [{-1, -1}, {0, -1}, {1, -1}, {-1, 0}, {1, 0}, {-1, 1}, {0, 1}, {1, 1}]
  def parse(args) do
    grid =
      args
      |> String.split("\n", trim: true)
      |> map(&to_charlist/1)
      |> map(fn line -> map(line, &(&1 - ?0)) end)

    # Structure de données de la grille :  %{{row,col} => valeur}
    for row <- 0..9, col <- 0..9, into: %{}, do: {{row, col}, grid |> at(row) |> at(col)}
  end

  # Paramètres de la récursivité
  # - liste des couples {row,col} à incrémenter
  # - MapSet des cellules qui ont flashé
  # - la grille elle-même %{{row,col} => valeur}
  # retour : {nombre de cellule qui ont flashé, état de la grille}

  # fin de la récursivité
  def inc1([], flashed, grid),
    # ne garde que le nombre de cellules "flashées"
    do: {
      MapSet.size(flashed),
      # remet à 0 les cellules qui ont > 9
      for({cell, v} <- grid, into: %{}, do: {cell, if(v < 10, do: v, else: 0)})
    }

  # on ignore la mise à jour des cellules hors grille
  def inc1([{row, col} | tail], flashed, grid) when row < 0 or col < 0 or row > 9 or col > 9,
    do: inc1(tail, flashed, grid)

  # Cas fondamental: on traite la première cellule à incrémenter
  def inc1([{row, col} = cell | tail], flashed, grid) do
    # ne rien faire si la cellule a déjà flashé
    if MapSet.member?(flashed, cell) do
      inc1(tail, flashed, grid)
    else
      # modification de la grille: ajouter 1 à la valeur de la cellule dans la grille
      {c, grid} = Map.get_and_update(grid, cell, fn c -> {c, c + 1} end)

      if c >= 9 do
        # Elle "flashe"!
        delta = @drowcol |> map(fn {dr, dc} -> {row + dr, col + dc} end)

        # on ajoute la liste des cellules adjacentes à la liste des cellules à incrémenter et on ajoute la cellule à la liste des flashées
        inc1(delta ++ tail, MapSet.put(flashed, cell), grid)
      else
        # Pas de flash => rien à faire de plus
        inc1(tail, flashed, grid)
      end
    end
  end

  def step({_flashes, grid}) do
    inc1(@coords, MapSet.new(), grid)
  end

  def part1(args) do
    grid = parse(args)
    Stream.iterate({0, grid}, &step/1) |> take(101) |> map(&elem(&1, 0)) |> sum()
  end

  def part2(args) do
    grid = parse(args)
    Stream.iterate({0, grid}, &step/1) |> take_while(fn {n, _} -> n < 100 end) |> count()
  end
end
