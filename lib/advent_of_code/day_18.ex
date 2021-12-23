defmodule AdventOfCode.Day18 do
  import Enum

  # Tokenize the string
  def tokenize(s), do: tokenize(s, [], [])

  # interpret the accumulator as an integer
  defp to_int(l), do: {:num, String.to_integer(to_string(reverse(l)))}

  # def tokenize(char stream, reverse token stream, accumulator for numerical values)
  # final
  def tokenize([], l, _), do: reverse(l)

  # just put the :ob
  def tokenize([?[ | a], l, []), do: tokenize(a, [:ob | l], [])

  # just put the :cb
  def tokenize([?] | a], l, []), do: tokenize(a, [:cb | l], [])
  # the acc is not empty, so add it
  def tokenize([?] | a], l, acc), do: tokenize(a, [:cb, to_int(acc) | l], [])

  # just put the :comma
  def tokenize([?, | a], l, []), do: tokenize(a, [:comma | l], [])
  # the acc is not empty, so add it
  def tokenize([?, | a], l, acc), do: tokenize(a, [:comma, to_int(acc) | l], [])

  # accumulate values
  def tokenize([c | a], l, acc), do: tokenize(a, l, [c | acc])

  # Creates a Tree structure out of the token stream

  def element([:ob | _] = l), do: pair(l)
  def element([e | r]), do: {e, r}

  # There is always a Pair at the top of the tree

  # the pair function returns a couple {the tree with the pair at the top, the rest of the token stream}

  # First case: there is a pair which has a pair inside
  def pair([:ob, :ob | r]) do
    # interpret the pair of the left operand
    # rest_l is the rest of the token stream, without the comma
    {left_b, [:comma | rest_l]} = pair([:ob | r])
    # interpret the right operand of the pair
    {right_b, rest_d} = element(rest_l)
    # remove the closing bracket
    [:cb | final_rest] = rest_d
    {{:pair, left_b, right_b}, final_rest}
  end

  # Second case: the left operand is a number
  def pair([:ob, left_b, :comma | rest_l]) do
    {right_b, rest_d} = element(rest_l)
    [:cb | final_rest] = rest_d
    {{:pair, left_b, right_b}, final_rest}
  end

  # Modify the tree structure to add the levels. It is a simple recursive expression
  def add_levels({:pair, left, right}, level),
    do: {:pair, add_levels(left, level + 1), add_levels(right, level + 1), level}

  def add_levels({:num, e}, level), do: {:num, e, level}

  # Detection if there is a candidate for explode
  # If yes, return the **path** to the Pair that should explode
  # A path is a list like [:left, :right:, :left]

  # Initiate the recursion
  def detect_explode(tree), do: detect_explode(tree, [])

  # A :num cannot explode
  def detect_explode({:num, _, _}, _), do: false
  # A pair of level 4 can explode. Return the path and the 2 elements of the pair
  def detect_explode({:pair, {:num, le, _}, {:num, ri, _}, 4}, l), do: {reverse(l), le, ri}

  # A pair of different level has to be explored
  def detect_explode({:pair, le, ri, _}, l) do
    # Let's look at the left branch then the right branch of the pair
    compute_left = detect_explode(le, [:left | l])
    if compute_left != false, do: compute_left, else: detect_explode(ri, [:right | l])
  end

  # Replace a Pair at the position indicated by the Path by a 0
  def nullify({:pair, _, _, level}, []), do: {:num, 0, level}
  def nullify({:pair, le, ri, level}, [:left | l]), do: {:pair, nullify(le, l), ri, level}
  def nullify({:pair, le, ri, level}, [:right | l]), do: {:pair, le, nullify(ri, l), level}

  # Returns a list of the Paths leading to numbers in the tree.
  # The list is ordered from the left to the right of the tree structure
  def list_numbers(tree), do: list_numbers([], tree, []) |> reverse()
  def list_numbers(paths, {:num, v, _}, l), do: [{reverse(l), v} | paths]

  def list_numbers(paths, {:pair, le, ri, _}, l) do
    paths |> list_numbers(le, [:left | l]) |> list_numbers(ri, [:right | l])
  end

  # Apply a function to a number located by a path
  def tree_apply({:num, val, level}, [], f), do: {:num, f.(val), level}

  def tree_apply({:pair, le, ri, level}, [:left | l], f),
    do: {:pair, tree_apply(le, l, f), ri, level}

  def tree_apply({:pair, le, ri, level}, [:right | l], f),
    do: {:pair, le, tree_apply(ri, l, f), level}

  # Print a tree in a standard way
  def print_tree({:num, val, _level}), do: Integer.to_string(val)

  def print_tree({:pair, le, ri, _level}) do
    left = print_tree(le)
    right = print_tree(ri)
    "[#{left},#{right}]"
  end

  def explode(tree) do
    explosion = detect_explode(tree)

    if explosion == false do
      {false, tree}
    else
      # there is a Node to explode
      {path, le_value, ri_value} = explosion
      # Replace the pair by 0
      tree = nullify(tree, path)
      # Identify all the numbers
      paths_for_numbers = list_numbers(tree) |> map(&elem(&1, 0))
      # Find the path in the list
      # lexicographic order is implemented by default in Elixir and :left < :right
      index = find_index(paths_for_numbers, fn x -> x >= path end)
      # Add value to the left
      tree =
        if index <= 0,
          do: tree,
          else: tree_apply(tree, at(paths_for_numbers, index - 1), fn x -> x + le_value end)

      # Add value to the right
      tree =
        if index + 1 >= count(paths_for_numbers),
          do: tree,
          else: tree_apply(tree, at(paths_for_numbers, index + 1), fn x -> x + ri_value end)

      {true, tree}
    end
  end

  # Replace a number with a given path by a pair
  def split_node({:num, v, level}, []),
    do: {:pair, {:num, div(v, 2), level + 1}, {:num, v - div(v, 2), level + 1}, level}

  def split_node({:pair, le, ri, level}, [:left | l]), do: {:pair, split_node(le, l), ri, level}
  def split_node({:pair, le, ri, level}, [:right | l]), do: {:pair, le, split_node(ri, l), level}

  # Split the leftmost number of the tree which is >= 10
  def split(tree) do
    candidate = list_numbers(tree) |> filter(fn {_, number} -> number >= 10 end) |> List.first()
    if candidate == nil, do: {false, tree}, else: {true, split_node(tree, elem(candidate, 0))}
  end

  # apply explode and split until nothing can be done
  def reduce_tree(tree) do
    {res, tree} = explode(tree)

    if not res do
      {res, tree} = split(tree)
      if not res, do: tree, else: reduce_tree(tree)
    else
      reduce_tree(tree)
    end
  end

  # compute the magnitude of a tree
  def magnitude({:num, v, _}), do: v
  def magnitude({:pair, le, ri, _}), do: 3 * magnitude(le) + 2 * magnitude(ri)

  # From a string to a tree
  def parse_tree(line) do
    line
    |> to_charlist()
    |> tokenize()
    |> pair()
    |> elem(0)
    |> add_levels(0)
  end

  def part1(args) do
    args
    |> String.split("\n", trim: true)
    # sums all numbers
    |> reduce(fn b, a -> # !! non commutative !!
      reduce_tree(parse_tree("[#{a},#{b}]")) |> print_tree()
    end)
    |> parse_tree()
    |> magnitude()
  end

  def part2(args) do
    numbers = args |> String.split("\n", trim: true)
    max((for n1 <- numbers, n2 <- numbers, n1 != n2, do: reduce_tree(parse_tree("[#{n1},#{n2}]")) |> magnitude()))
  end
end
