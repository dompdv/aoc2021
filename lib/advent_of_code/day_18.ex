defmodule AdventOfCode.Day18 do
  import Enum

  def tokenize(s), do: tokenize(s, [], [])
  defp to_int(l), do: {:num, List.first(l) - ?0}
  def tokenize([], l, _), do: reverse(l)

  def tokenize([?[ | a], l, []), do: tokenize(a, [:ob | l], [])

  def tokenize([?] | a], l, []), do: tokenize(a, [:cb | l], [])
  def tokenize([?] | a], l, acc), do: tokenize(a, [:cb, to_int(acc) | l], [])
  def tokenize([?, | a], l, []), do: tokenize(a, [:comma | l], [])
  def tokenize([?, | a], l, acc), do: tokenize(a, [:comma, to_int(acc) | l], [])
  def tokenize([c | a], l, acc), do: tokenize(a, l, [c | acc])

  def element([:ob | _] = l), do: pair(l)
  def element([e | r]), do: {e, r}

  def pair([:ob, :ob | r]) do
    {left_b, [:comma | rest_l]} = pair([:ob | r])
    {right_b, rest_d} = element(rest_l)
    [:cb | final_rest] = rest_d
    {{:pair, left_b, right_b}, final_rest}
  end

  def pair([:ob, e | r]) do
    left_b = e
    [:comma | rest_l] = r
    {right_b, rest_d} = element(rest_l)
    [:cb | final_rest] = rest_d
    {{:pair, left_b, right_b}, final_rest}
  end

  def add_levels({:pair, left, right}, level),
    do: {:pair, add_levels(left, level + 1), add_levels(right, level + 1), level}

  def add_levels({:num, e}, level), do: {:num, e, level}

  def detect_explode(tree), do: detect_explode(tree, [])
  def detect_explode({:num, _, _}, _), do: false
  def detect_explode({:pair, {:num, le, _}, {:num, ri, _}, 4}, l), do: {true, reverse(l), le, ri}

  def detect_explode({:pair, le, ri, _}, l) do
    compute_left = detect_explode(le, [:left | l])
    compute_right = detect_explode(ri, [:right | l])

    cond do
      compute_left != false -> compute_left
      compute_right != false -> compute_right
      true -> false
    end
  end

  def nullify({:pair, _, _, level}, []), do: {:num, 0, level}
  def nullify({:pair, le, ri, level}, [:left | l]), do: {:pair, nullify(le, l), ri, level}
  def nullify({:pair, le, ri, level}, [:right | l]), do: {:pair, le, nullify(ri, l), level}

  def list_numbers(tree), do: list_numbers([], tree, []) |> reverse()
  def list_numbers(paths, {:num, _, _}, l), do: [reverse(l) | paths]

  def list_numbers(paths, {:pair, le, ri, _}, l) do
    paths |> list_numbers(le, [:left | l]) |> list_numbers(ri, [:right | l])
  end

  def tree_apply({:num, val, level}, [], f), do: {:num, f.(val), level}

  def tree_apply({:pair, le, ri, level}, [:left | l], f),
    do: {:pair, tree_apply(le, l, f), ri, level}

  def tree_apply({:pair, le, ri, level}, [:right | l], f),
    do: {:pair, le, tree_apply(ri, l, f), level}

  def print_tree({:num, val, _level}), do: Integer.to_string(val)

  def print_tree({:pair, le, ri, _level}) do
    left = print_tree(le)
    right = print_tree(ri)
    "[#{left},#{right}]"
  end

  def part1(_args) do
    tree =
      "[7,[6,[5,[4,[3,2]]]]]"
      # "[[[[[9,8],1],2],3],4]"
      # "[[6,[5,[4,[3,2]]]],1]"
      |> to_charlist()
      |> tokenize()
      |> pair()
      |> elem(0)
      |> add_levels(0)
      |> IO.inspect()

    IO.inspect("liste 1")
    list_numbers(tree) |> IO.inspect()
    {true, path, le_value, ri_value} = detect_explode(tree)

    IO.inspect({"explode", path})
    tree = nullify(tree, path) |> IO.inspect()

    paths_for_numbers = list_numbers(tree) |> IO.inspect()

    index = find_index(paths_for_numbers, fn x -> x >= path end)

    tree =
      if index <= 0,
        do: tree,
        else: tree_apply(tree, at(paths_for_numbers, index - 1), fn x -> x + le_value end)

    tree =
      if index + 1 >= count(paths_for_numbers),
        do: tree,
        else: tree_apply(tree, at(paths_for_numbers, index + 1), fn x -> x + ri_value end)

    tree |> print_tree()
  end

  def part2(_args) do
  end
end
