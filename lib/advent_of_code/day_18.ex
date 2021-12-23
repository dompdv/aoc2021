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
    #IO.inspect({"obob", r})
    {left_b, [:comma | rest_l]} = pair([:ob | r])
    {right_b, rest_d} = element(rest_l)
    [:cb | final_rest] = rest_d
    {{:pair, left_b, right_b}, final_rest}
  end

  def pair([:ob, e | r]) do
    #IO.inspect({"ob",e, r})
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


  def add_to_right({:pair, le, ri, level}, value,  [:left | l]), do: {:pair, add_to_right(le, value, l), ri, level}
  def add_to_right({:pair, le, ri, level}, value,  [:right | l]), do: {:pair, le, add_to_right(ri, value, l), level}
  def add_to_right({:num, e, level}, value,[]), do: {:num, e + value, level}
  def add_to_right({:pair, le, ri, level}, value, []) do
    tree_right = add_to_right(ri, value, [])
    if tree_right != false do
      {:pair, le, tree_right, level}
    else
      tree_left = add_to_right(le, value, [])
      if tree_left != false, do: {:pair, tree_left, ri, level}, else: false
    end
  end

  def part1(_args) do
    tree =
      #"[[[[1,2],[3,4]],[[5,6],[7,8]]],9]"

      #"[[6,[5,[4,[3,2]]]],1]"
      "[[[[[9,8],1],2],3],4]"
      |> to_charlist()
      |> tokenize()
      |> pair()
      |> elem(0)
      |> add_levels(0)
      |> IO.inspect()


      {true, path, le, ri} = detect_explode(tree)
      IO.inspect({"explode", path})
      tree = nullify(tree, path) |> IO.inspect()
      IO.inspect({"add to right"})
      s_path = (drop(path, -1) ++ [:left]) |> IO.inspect()
      add_to_right(tree, le, s_path)
  end

  def part2(_args) do
  end
end
