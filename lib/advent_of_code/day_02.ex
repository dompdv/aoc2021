defmodule AdventOfCode.Day02 do
  import Enum

  def parse_line(str) do
    [dir, qty] = String.split(str, " ")
    {dir, String.to_integer(qty)}
  end

  def part01(args) do
    {position, depth} =
      args
      |> String.split("\n")
      |> drop(-1)
      |> map(&parse_line/1)
      |> reduce({0, 0}, fn {dir, thrust}, {position, depth} ->
        case dir do
          "forward" -> {position + thrust, depth}
          "up" -> {position, depth - thrust}
          "down" -> {position, depth + thrust}
        end
      end)

    position * depth
  end

  def part2(args) do
    {position, depth, _} =
      args
      |> String.split("\n")
      |> drop(-1)
      |> map(&parse_line/1)
      |> reduce({0, 0, 0}, fn {dir, thrust}, {position, depth, aim} ->
        case dir do
          "forward" -> {position + thrust, depth + aim * thrust, aim}
          "up" -> {position, depth, aim - thrust}
          "down" -> {position, depth, aim + thrust}
        end
      end)

    position * depth
  end
end
