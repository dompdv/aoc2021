defmodule AdventOfCode.Day24 do
  import Enum

  def parse(args), do: args |> String.split("\n", trim: true) |> map(&parse_line/1)

  def parse_line("inp " <> register), do: {:inp, String.to_atom(register)}
  def parse_line("add " <> rest), do: parse_rest(:add, rest)
  def parse_line("mul " <> rest), do: parse_rest(:mul, rest)
  def parse_line("div " <> rest), do: parse_rest(:div, rest)
  def parse_line("mod " <> rest), do: parse_rest(:mod, rest)
  def parse_line("eql " <> rest), do: parse_rest(:eql, rest)

  def parse_rest(operation, rest) do
    [register, operand] = String.split(rest)

    {op_type, val} =
      case Integer.parse(operand) do
        :error -> {:register, String.to_atom(operand)}
        {value, _} -> {:value, value}
      end

    {operation, String.to_atom(register), op_type, val}
  end

  def operations,
    do: %{
      :add => fn a, b -> a + b end,
      :mul => fn a, b -> a * b end,
      :div => fn a, b -> div(a, b) end,
      :mod => fn a, b -> rem(a, b) end,
      :eql => fn a, b -> if a == b, do: 1, else: 0 end
    }

  def execute_ins({:inp, register}, {registers, [i | input_buffer]}),
    do: {Map.put(registers, register, i), input_buffer}

  def execute_ins({instruction, register1, :register, register2}, {registers, input_buffer}),
    do:
      {Map.put(
         registers,
         register1,
         operations()[instruction].(registers[register1], registers[register2])
       ), input_buffer}

  def execute_ins({instruction, register1, :value, value}, {registers, input_buffer}),
    do:
      {Map.put(registers, register1, operations()[instruction].(registers[register1], value)),
       input_buffer}

  def execute_program(program, input_buffer),
    do:
      reduce(program, init_state(input_buffer), fn ins, c_state -> execute_ins(ins, c_state) end)

  def init_state(input_buffer), do: {%{x: 0, y: 0, z: 0, w: 0}, input_buffer}

  def part1(args) do
    program = parse(args)
    execute_program(program, [1, 2, 3, 4, 5])
  end

  def part2(_args) do
  end
end
