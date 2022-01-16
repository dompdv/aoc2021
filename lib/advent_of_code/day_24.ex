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

  def resume_program(program, registers, input_buffer),
    do:
      reduce(program, {registers, input_buffer}, fn ins, c_state -> execute_ins(ins, c_state) end)

  def init_state(input_buffer), do: {%{x: 0, y: 0, z: 0, w: 0}, input_buffer}

  def find_largest_model_number(program) do
    99_999_999_999_999..11_111_111_111_111
    |> Stream.drop_while(fn n ->
      n_list = to_charlist(Integer.to_string(n)) |> map(&(&1 - ?0))

      if any?(n_list, &(&1 == 0)) do
        true
      else
        if :rand.uniform() > 0.99999, do: IO.inspect({n, DateTime.utc_now()})
        {%{z: z}, _} = execute_program(program, n_list)
        IO.inspect({n, z})
        z != 0
      end
    end)
    |> take(1)
  end

  def diff([], [], _, acc), do: reverse(acc)
  def diff([a1 | r1], [a1 | r2], n, acc), do: diff(r1, r2, n + 1, acc)
  def diff([a1 | r1], [a2 | r2], n, acc), do: diff(r1, r2, n + 1, [{n, a1, a2} | acc])
  def diff(l1, l2), do: diff(l1, l2, 0, [])

  def step_function(z, {inp, [a1, a2, a3]}) do
    if inp == rem(z, 26) + a2, do: div(z, a1), else: inp + a3 + 26 * div(z, a1)
  end

  def execute_n_steps(n_list, steps, parameters) do
    zip(n_list, slice(parameters, 0..(steps - 1)))
    |> reduce(0, fn e, z -> step_function(z, e) end)
  end

  def part1(args) do
    initial_program = parse(args)
    programs = initial_program |> chunk_every(div(252, 14))

    parameters =
      map(programs, fn b ->
        for i <- [4, 5, 15], do: at(b, i) |> elem(3)
      end)
      |> IO.inspect()

    n = 99_969_432_138_785
    n_list = to_charlist(Integer.to_string(n)) |> map(&(&1 - ?0))
    execute_program(initial_program, n_list) |> IO.inspect()

    zip(n_list, parameters) |> reduce(0, fn e, z -> step_function(z, e) end)

    #     for n <- 1..9, m <- 1..9, do: IO.inspect({n, m, execute_n_steps([9,4,9,9,9,7,9,9,4,4,9,4,3,9], 18, parameters)})
    for n <- 1..9,
        m <- 1..9,
        do:
          {n, m,
           execute_program(initial_program, [9, 4, 9, 9, 9, 7, 9, 9, 4, 4, 9, 4, 3, 9])
           |> elem(0)
           |> Map.get(:z)}
          |> IO.inspect()
  end

  def part1_old(args) do
    programs = parse(args) |> chunk_every(div(252, 14))

    bout = hd(programs)
    states_0 = IO.inspect(map(1..9, fn n -> execute_program(bout, [n]) end))
    states_0 = map(states_0, &elem(&1, 0))

    bout2 = at(programs, 1)
    for s <- states_0, n <- 1..9, do: IO.inspect({n, s, resume_program(bout2, s, [n]) |> elem(0)})
    :ok
  end

  def part2(_args) do
  end
end
