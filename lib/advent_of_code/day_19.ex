defmodule AdventOfCode.Day19 do
  import Enum

  #  @flip [[0, 1, 2], [2, 0, 1], [1, 2, 0]]
  @flip [[0, 1, 2], [0, 2, 1], [1, 0, 2], [1, 2, 0], [2, 0, 1], [2, 1, 0]]
  @inversions for x <- [-1, 1], y <- [-1, 1], z <- [-1, 1], do: [x, y, z]

  # Les transformations sont des couples {[a,b,c], [d,e,f]}.
  # a,b,c sont dans 0,1 ou 2. Par exemple {2,0,1} signifie que x (=0) devient z (=2), y deveint x et z devient y
  # d,e,f valent 1 ou -1. Cela indique s'il faut mumtiplier x par 1 ou -1 (garder le sens ou le laisser inchangé)
  @transfos for f <- @flip, i <- @inversions, do: {f, i}

  # Parse le fichier. renvoie une Map %{numero de scanner => liste de points} (un point est un tuple {x,y,z}))
  def parse(args),
    do: args |> String.split("\n\n", trim: true) |> map(&parse_scanner/1) |> Map.new()

  # Parse un scanner. renvoie un tuple {numero de scanner, liste de {x,y,z}}
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

  # Translate toutes une liste de coordonnées d'un même vecteur
  def move_scanner(scanner, {x, y, z}),
    do: map(scanner, fn {x1, y1, z1} -> {x + x1, y + y1, z + z1} end)

  # Applique une transformation. Voir commentaire de @transfos
  def apply_transfo(scanner, {[f0, f1, f2], [i0, i1, i2]}) do
    scanner
    |> map(fn p ->
      {elem(p, f0) * i0, elem(p, f1) * i1, elem(p, f2) * i2}
    end)
  end

  # Detecte si 2 listes ORDONNEES ont au moin "target" éléments en commun
  def in_common(_, _, target, target), do: true
  def in_common([], _, _, _), do: false
  def in_common(_, [], _, _), do: false
  def in_common([a | r1], [a | r2], target, acc), do: in_common(r1, r2, target, acc + 1)

  def in_common([a | r1], [b | _r2] = l2, target, acc) when a < b,
    do: in_common(r1, l2, target, acc)

  def in_common(l1, [_b | r2], target, acc), do: in_common(l1, r2, target, acc)

  # Coeur du réacteur: scan0 et scan1 sont deux listes de points. axis vaut 0, 1 ou 2 (x,y ou z)
  # renvoie false si il n'y a pas moyen de "superposer" les deux listes pour faire coincider au moins 12 points
  # renvoie la translation nécessaire sinon
  def scan_coord(scan0, scan1, axis) do
    # On sélectionne l'axe (x,y ou z) et on trie les deux listes. Scan0 ne bougera plus
    x0s = scan0 |> map(&elem(&1, axis)) |> sort()
    x1s = scan1 |> map(&elem(&1, axis)) |> sort()

    # On détermine la taille maximale à considérer, à partir des points les plus grands (en valeur absolue)
    m = [abs(at(x0s, 0)), abs(at(x0s, -1)), abs(at(x1s, 0)), abs(at(x1s, -1))] |> max()

    # On va tester toutes les translations justqu'à trouver une qui coincide
    search =
      Stream.zip(0..(2 * m), 0..(-2 * m))
      |> Stream.flat_map(&Tuple.to_list/1)
      |> Stream.drop_while(fn coord ->
        not in_common(x0s, map(x1s, fn x -> x + coord end), 12, 0)
      end)
      |> take(1)
      if empty?(search), do: false, else: hd(search)
  end

  def find_first_overlap(scanners) do
    for(
      {i, scan0} <- [{0, scanners[0]}], #sort(scanners),
      {j, scan1} <- to_list(scanners) |> shuffle(), #sort(scanners),
      i < j,
      do: {i, scan0, j, scan1}
    )
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

  def find_overlap(scanners) do
    for(
      {i, scan0} <- [{0, scanners[0]}], #sort(scanners),
      {j, scan1} <- to_list(scanners) |> shuffle(), #sort(scanners),
      i < j,
      do: {i, scan0, j, scan1}
    )
    |> reduce(
      [],
      fn {i, scan0, j, scan1}, acc ->
        IO.inspect({i, j})

        common =
          @transfos
          |> map(fn transfo ->
            {transfo,
             map(0..2, fn axis -> scan_coord(scan0, apply_transfo(scan1, transfo), axis) end)}
          end)
          |> filter(fn {_, [x, y, z]} -> x != false and y != false and z != false end)

        if empty?(common), do: acc, else: [{i, j, common} | acc]
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
  end

  def part2(args) do
    parse(args)
    |> reduce_scanners()
    |> Map.to_list()
    |> List.first()
    |> elem(1)
    |> MapSet.new()
    |> count()
  end
end
