defmodule AdventOfCode.Day14 do
  import Enum

  def parse(args) do
    [kernel, rules] = args |> String.split("\n\n", trim: true)
    # les règles sont une Map  %([car1, car2] => car_a_inserer)
    {to_charlist(kernel),
     rules
     |> String.split("\n", trim: true)
     |> map(fn line -> line |> String.split(" -> ") |> map(&to_charlist/1) |> List.to_tuple() end)
     |> map(fn {g, d} -> {g, hd(d)} end)
     |> Map.new()}
  end

  def apply_rules(kernel, rules) do
    kernel
    # pour chaque doublet -> frequence
    |> map(fn {[g, d] = doublet, n} ->
      case Map.get(rules, doublet) do
        # pas de règle à appliquer, on ne touche à rien
        nil -> {doublet, n}
        # le doublet se transforme en deux autres doublets
        v -> [{[g, v], n}, {[v, d], n}]
      end
    end)
    # suppression des listes imbriquées
    |> List.flatten()
    # consolidation des fréquences pour les doublets identiques
    |> reduce(%{}, fn {k, v}, acc -> Map.put(acc, k, Map.get(acc, k, 0) + v) end)
  end

  def run_for(args, iterations) do
    {kernel, rules} = args |> parse()

    # Mise à jour itérative du tableau des fréquence de doublets de lettres. %{ 'NN' => 12, 'BC" => 1}
    freqs =
      reduce(1..iterations, kernel |> chunk_every(2, 1, :discard) |> frequencies(), fn _, acc ->
        apply_rules(acc, rules)
      end)
      # On ne garde que la première lettre de chaque doublet (la deuxième est en fait la première d'un autre doublet)
      |> map(fn {[g, _], v} -> {g, v} end)
      # On ajoute les frequences des lettres identiques. Attention, il faut ajouter la dernière lettre du noyau initial
      |> reduce(%{List.last(kernel) => 1}, fn {k, v}, acc ->
        Map.put(acc, k, Map.get(acc, k, 0) + v)
      end)
      # tri des fréquences
      |> Map.values()
      |> sort()

    at(freqs, -1) - at(freqs, 0)
  end

  def part1(args), do: run_for(args, 10)
  def part2(args), do: run_for(args, 40)
end
