defmodule Instruction do
  defstruct [:opcode, params: [], size: 1]

  @write_ops [01, 02, 03, 07, 08]

  def parse_instruction(intcode) do
    opcode =
      intcode.program
      |> Enum.at(intcode.idx)
      |> rem(100)

    ins = %Instruction{opcode: opcode}

    load_params(intcode, ins)
  end

  defp load_params(intcode, ins) do
    param_count = param_count(ins)

    params = Enum.slice(intcode.program, intcode.idx + 1, param_count)

    parameter_modes =
      intcode.program
      |> Enum.at(intcode.idx)
      |> param_modes(param_count)
      |> swap_write_mode(ins)

    %{ins | params: Enum.zip(parameter_modes, params), size: param_count + 1}
  end

  defp param_count(%__MODULE__{opcode: 01}), do: 3
  defp param_count(%__MODULE__{opcode: 02}), do: 3
  defp param_count(%__MODULE__{opcode: 03}), do: 1
  defp param_count(%__MODULE__{opcode: 04}), do: 1
  defp param_count(%__MODULE__{opcode: 05}), do: 2
  defp param_count(%__MODULE__{opcode: 06}), do: 2
  defp param_count(%__MODULE__{opcode: 07}), do: 3
  defp param_count(%__MODULE__{opcode: 08}), do: 3
  defp param_count(%__MODULE__{opcode: 99}), do: 0

  defp param_modes(instruction, param_count) do
    instruction
    |> Integer.digits()
    |> Enum.drop(-2)
    |> pad_leading_params(param_count)
    |> Enum.reverse()
    |> modes()
  end

  defp pad_leading_params(digits, param_count) when length(digits) == param_count, do: digits

  defp pad_leading_params(digits, param_count) do
    pad_size = param_count - length(digits)

    1..pad_size
    |> Enum.map(fn _ -> 0 end)
    |> Enum.concat(digits)
  end

  defp modes(mode_list) when is_list(mode_list), do: Enum.map(mode_list, &modes/1)
  defp modes(0), do: :position
  defp modes(1), do: :immediate

  defp swap_write_mode(params, ins) do
    if ins.opcode in @write_ops do
      params
      |> Enum.reverse()
      |> tl()
      |> List.insert_at(0, :immediate)
      |> Enum.reverse()
    else
      params
    end
  end
end

defmodule Intcode do
  defstruct idx: 0, halted: false, program: [], opts: []

  @debug_mode false

  def intcode(int_list, opts \\ []) do
    intcode_opts = Keyword.merge(opts, debug: @debug_mode)

    run(%Intcode{program: int_list, opts: intcode_opts})
  end

  defp run(intcode = %Intcode{halted: true}), do: intcode
  defp run(intcode = %Intcode{program: program, idx: idx}) when idx > length(program), do: intcode

  defp run(intcode) do
    instruction = Instruction.parse_instruction(intcode)

    # TODO: Handle this as a case of execute?
    if instruction.opcode == 99 do
      intcode
    else
      intcode
      |> execute(instruction)
      |> run()
    end
  end

  # ADD
  defp execute(intcode, ins = %Instruction{opcode: 01}) do
    program = intcode.program
    [a, b, c] = ins.params

    left = fetch(program, a)
    right = fetch(program, b)

    new_val = left + right

    if Keyword.get(intcode.opts, :debug, false) do
      IO.inspect("ADD #{inspect(a)} (#{left}) and #{inspect(b)} (#{right})")
      IO.inspect("STORE #{new_val} at #{inspect(c)}")
    end

    new_program = List.replace_at(program, fetch(program, c), new_val)

    %{intcode | program: new_program, idx: intcode.idx + ins.size}
  end

  # MULT
  defp execute(intcode, ins = %Instruction{opcode: 02}) do
    program = intcode.program
    [a, b, c] = ins.params

    left = fetch(program, a)
    right = fetch(program, b)

    new_val = left * right

    if Keyword.get(intcode.opts, :debug, false) do
      IO.inspect("MULT #{inspect(a)} (#{left}) and #{inspect(b)} (#{right})")
      IO.inspect("STORE #{new_val} at #{inspect(c)}")
    end

    new_program = List.replace_at(program, fetch(program, c), new_val)

    %{intcode | program: new_program, idx: intcode.idx + ins.size}
  end

  # LOAD
  defp execute(intcode, ins = %Instruction{opcode: 03}) do
    program = intcode.program
    input = Keyword.fetch!(intcode.opts, :input)
    [a] = ins.params

    if Keyword.get(intcode.opts, :debug, false) do
      IO.puts("LOAD #{input} to #{fetch(program, a)}")
    end

    new_program = List.replace_at(program, fetch(program, a), input)

    %{intcode | program: new_program, idx: intcode.idx + ins.size}
  end

  # READ
  defp execute(intcode, ins = %Instruction{opcode: 04}) do
    [a] = ins.params

    if Keyword.get(intcode.opts, :debug, false) do
      IO.puts("READ #{inspect(a)}")
    end

    intcode.program
    |> fetch(a)
    |> IO.inspect()

    %{intcode | idx: intcode.idx + ins.size}
  end

  # JNZ
  defp execute(intcode, ins = %Instruction{opcode: 05}) do
    program = intcode.program
    [a, b] = ins.params

    a_val = fetch(program, a)
    b_val = fetch(program, b)

    if Keyword.get(intcode.opts, :debug, false) do
      IO.puts("JNZ #{inspect(a)} (#{a_val}) TO #{inspect(b)} (#{b_val})")
    end

    if a_val != 0 do
      %{intcode | idx: b_val}
    else
      %{intcode | idx: intcode.idx + ins.size}
    end
  end

  # JZ
  defp execute(intcode, ins = %Instruction{opcode: 06}) do
    program = intcode.program
    [a, b] = ins.params

    a_val = fetch(program, a)
    b_val = fetch(program, b)

    if Keyword.get(intcode.opts, :debug, false) do
      IO.puts("JZ #{inspect(a)} (#{a_val}) TO #{inspect(b)} (#{b_val})")
    end

    if a_val == 0 do
      %{intcode | idx: b_val}
    else
      %{intcode | idx: intcode.idx + ins.size}
    end
  end

  # LT
  defp execute(intcode, ins = %Instruction{opcode: 07}) do
    program = intcode.program
    [a, b, c] = ins.params

    a_val = fetch(program, a)
    b_val = fetch(program, b)
    c_val = fetch(program, c)

    new_val = if a_val < b_val, do: 1, else: 0

    if Keyword.get(intcode.opts, :debug, false) do
      IO.puts("LT #{inspect(a)} (#{a_val}), #{inspect(b)} (#{b_val})")
      IO.puts("STORE #{new_val} at #{inspect(c)} (#{c_val})")
    end

    new_program = List.replace_at(program, c_val, new_val)

    %{intcode | program: new_program, idx: intcode.idx + ins.size}
  end

  # EQ
  defp execute(intcode, ins = %Instruction{opcode: 08}) do
    program = intcode.program
    [a, b, c] = ins.params

    a_val = fetch(program, a)
    b_val = fetch(program, b)
    c_val = fetch(program, c)

    new_val = if a_val == b_val, do: 1, else: 0

    if Keyword.get(intcode.opts, :debug, false) do
      IO.puts("EQ #{inspect(a)} (#{a_val}), #{inspect(b)} (#{b_val})")
      IO.puts("STORE #{new_val} at #{inspect(c)} (#{c_val})")
    end

    new_program = List.replace_at(program, c_val, new_val)

    %{intcode | program: new_program, idx: intcode.idx + ins.size}
  end

  # HALT
  defp execute(intcode, %Instruction{opcode: 99}), do: %{intcode | halted: true}

  defp fetch(_vals, {:immediate, value}), do: value
  defp fetch(program, {:position, value}), do: Enum.at(program, value)
end
