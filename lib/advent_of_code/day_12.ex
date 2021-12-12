defmodule AdventOfCode.Day12 do
  import Enum

  def parse(args) do
    args
    |> String.split("\n", trim: true)
    |> map(fn line -> String.split(line, "-") |> List.to_tuple() end)
    |> reduce(%{}, fn {from, to}, nav ->
      type_from = if from |> to_charlist() |> List.first() <= ?Z, do: :large, else: :small
      type_to = if to |> to_charlist() |> List.first() <= ?Z, do: :large, else: :small

      nav_with_from = Map.put(nav, from, [{to, type_to} | Map.get(nav, from, [])])
      Map.put(nav_with_from, to, [{from, type_from} | Map.get(nav_with_from, to, [])])
    end)
  end

  def visit("end", path, _visited_nodes, _navigation), do: [["end" | path]]

  def visit(current_node, path, visited_nodes, navigation) do
    nodes_to_visit =
      navigation[current_node]
      |> filter(fn {n, type_node} ->
        type_node == :large or not MapSet.member?(visited_nodes, n)
      end)

    reduce(
      nodes_to_visit,
      [],
      fn {node_to_visit, type_node}, acc ->
        visited_nodes =
          if type_node == :large,
            do: visited_nodes,
            else: MapSet.put(visited_nodes, node_to_visit)

        visit(node_to_visit, [current_node | path], visited_nodes, navigation) ++ acc
      end
    )
  end

  def part1(args) do
    navigation = parse(args)
    visit("start", [], MapSet.new(["start"]), navigation) |> count()
  end

  def visit2("end", path, _visited_nodes, _joker, _navigation), do: [["end" | path]]

  def visit2(current_node, path, visited_nodes, joker, navigation) do
    nodes_to_visit =
      if joker do
        navigation[current_node]
        |> filter(fn {n, type_node} ->
          type_node == :large or not MapSet.member?(visited_nodes, n)
        end)
        |> filter(&(&1 != "start"))
      else
        navigation[current_node]
        |> filter(&(elem(&1, 0) != "start"))
      end

    reduce(
      nodes_to_visit,
      [],
      fn {node_to_visit, type_node}, acc ->
        activate_joker =
          type_node == :small and joker == false and
            MapSet.member?(visited_nodes, node_to_visit)

        joker = if activate_joker, do: true, else: joker

        visited =
          if type_node == :large,
            do: visited_nodes,
            else: MapSet.put(visited_nodes, node_to_visit)

        visit2(node_to_visit, [current_node | path], visited, joker, navigation) ++ acc
      end
    )
  end

  def part2(args) do
    navigation = parse(args)
    visit2("start", [], MapSet.new(["start"]), false, navigation) |> count()
  end
end
