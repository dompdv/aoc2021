defmodule AdventOfCode.Day12 do
  import Enum

  def parse(args) do
    edges =
      args
      |> String.split("\n", trim: true)
      |> map(fn line ->
        [from, to] = String.split(line, "-")
        {from, to}
      end)

    navigation =
      reduce(edges, %{}, fn {from, to}, nav ->
        nav_with_from = Map.put(nav, from, [to | Map.get(nav, from, [])])
        Map.put(nav_with_from, to, [from | Map.get(nav_with_from, to, [])])
      end)

    large =
      edges
      |> map(&Tuple.to_list/1)
      |> List.flatten()
      |> filter(fn node -> String.slice(node, 0..0) |> to_charlist() |> List.first() <= ?Z end)
      |> MapSet.new()

    {navigation, large}
  end

  def visit("end", _visited_nodes, _navigation, _large_caves, path), do: [["end" | path]]

  def visit(current_node, visited_nodes, navigation, large_caves, path) do
    nodes_to_visit =
      navigation[current_node]
      |> filter(fn n ->
        MapSet.member?(large_caves, n) or not MapSet.member?(visited_nodes, n)
      end)

    reduce(
      nodes_to_visit,
      [],
      fn node_to_visit, acc ->
        visited_nodes =
          if MapSet.member?(large_caves, node_to_visit),
            do: visited_nodes,
            else: MapSet.put(visited_nodes, node_to_visit)

        visit(node_to_visit, visited_nodes, navigation, large_caves, [current_node | path]) ++
          acc
      end
    )
  end

  def part1(args) do
    {navigation, large_caves} = parse(args)
    visit("start", MapSet.new(["start"]), navigation, large_caves, []) |> count()
    #    |> map(&reverse/1)
  end

  def visit2("end", _visited_nodes, _joker, _navigation, _large_caves, path), do: [["end" | path]]

  def visit2(current_node, visited_nodes, joker, navigation, large_caves, path) do
    nodes_to_visit =
      if joker do
        navigation[current_node]
        |> filter(fn n ->
          MapSet.member?(large_caves, n) or not MapSet.member?(visited_nodes, n)
        end)
        |> filter(&(&1 != "start"))
      else
        navigation[current_node]
        |> filter(&(&1 != "start"))
      end

    # IO.inspect({joker, current_node, nodes_to_visit, visited_nodes})
    reduce(
      nodes_to_visit,
      [],
      fn node_to_visit, acc ->
        activate_joker =
          not MapSet.member?(large_caves, node_to_visit) and joker == false and
            MapSet.member?(visited_nodes, node_to_visit)

        new_joker = if activate_joker, do: true, else: joker

        new_visited =
          if MapSet.member?(large_caves, node_to_visit),
            do: visited_nodes,
            else: MapSet.put(visited_nodes, node_to_visit)

        visit2(node_to_visit, new_visited, new_joker, navigation, large_caves, [
          current_node | path
        ]) ++ acc
      end
    )
  end

  def part2(args) do
    {navigation, large_caves} = parse(args)

    visit2("start", MapSet.new(["start"]), false, navigation, large_caves, [])
    |> count()
  end
end
