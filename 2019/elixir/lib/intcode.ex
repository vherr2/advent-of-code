defmodule Instruction do
  defstruct [:opcode, params: [], size: 1]

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
  defp param_count(%__MODULE__{opcode: 09}), do: 1
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
  defp modes(2), do: :relative
end

defmodule Intcode do
  defstruct [
    :output,
    idx: 0,
    relative_base: 0,
    halted: false,
    paused: false,
    program: [],
    opts: []
  ]

  @debug_mode false
  def intcode(instructions, opts \\ [])

  def intcode(intcode = %Intcode{}, opts) do
    intcode_opts = Keyword.merge([debug: @debug_mode, input: []], opts)

    run(%{intcode | paused: false, opts: intcode_opts})
  end

  def intcode(int_list, opts) do
    intcode_opts = Keyword.merge([debug: @debug_mode, input: []], opts)

    run(%Intcode{program: int_list, opts: intcode_opts})
  end

  defp run(intcode = %Intcode{halted: true}), do: intcode
  defp run(intcode = %Intcode{paused: true}), do: intcode
  defp run(intcode = %Intcode{program: program, idx: idx}) when idx > length(program), do: intcode

  defp run(intcode) do
    instruction = Instruction.parse_instruction(intcode)

    intcode
    |> execute(instruction)
    |> run()
  end

  # ADD
  defp execute(intcode, ins = %Instruction{opcode: 01}) do
    [a, b, c] = ins.params

    left = fetch(intcode, a)
    right = fetch(intcode, b)

    new_val = left + right

    if Keyword.fetch!(intcode.opts, :debug) do
      IO.inspect("ADD #{inspect(a)} (#{left}) and #{inspect(b)} (#{right})")
      IO.inspect("STORE #{new_val} at #{inspect(c)}")
    end

    new_program = write(intcode, c, new_val)

    %{intcode | program: new_program, idx: intcode.idx + ins.size}
  end

  # MULT
  defp execute(intcode, ins = %Instruction{opcode: 02}) do
    [a, b, c] = ins.params

    left = fetch(intcode, a)
    right = fetch(intcode, b)

    new_val = left * right

    if Keyword.fetch!(intcode.opts, :debug) do
      IO.inspect("MULT #{inspect(a)} (#{left}) and #{inspect(b)} (#{right})")
      IO.inspect("STORE #{new_val} at #{inspect(c)}")
    end

    new_program = write(intcode, c, new_val)

    %{intcode | program: new_program, idx: intcode.idx + ins.size}
  end

  # LOAD
  defp execute(intcode, ins = %Instruction{opcode: 03}) do
    input = Keyword.fetch!(intcode.opts, :input)

    # Pause
    if input == [] do
      %{intcode | paused: true}
    else
      [next | rest] = input

      [a] = ins.params

      if Keyword.fetch!(intcode.opts, :debug) do
        IO.puts("LOAD #{next} to #{fetch(intcode, a)}")
      end

      new_program = write(intcode, a, next)

      %{
        intcode
        | program: new_program,
          idx: intcode.idx + ins.size,
          opts: Keyword.put(intcode.opts, :input, rest)
      }
    end
  end

  # READ
  defp execute(intcode, ins = %Instruction{opcode: 04}) do
    [a] = ins.params

    output = fetch(intcode, a)

    if Keyword.fetch!(intcode.opts, :debug) do
      IO.puts("READ #{output}")
    end

    %{intcode | idx: intcode.idx + ins.size, output: output}
  end

  # JNZ
  defp execute(intcode, ins = %Instruction{opcode: 05}) do
    [a, b] = ins.params

    a_val = fetch(intcode, a)
    b_val = fetch(intcode, b)

    if Keyword.fetch!(intcode.opts, :debug) do
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
    [a, b] = ins.params

    a_val = fetch(intcode, a)
    b_val = fetch(intcode, b)

    if Keyword.fetch!(intcode.opts, :debug) do
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
    [a, b, c] = ins.params

    a_val = fetch(intcode, a)
    b_val = fetch(intcode, b)
    c_val = fetch(intcode, c)

    new_val = if a_val < b_val, do: 1, else: 0

    if Keyword.fetch!(intcode.opts, :debug) do
      IO.puts("LT #{inspect(a)} (#{a_val}), #{inspect(b)} (#{b_val})")
      IO.puts("STORE #{new_val} at #{inspect(c)} (#{c_val})")
    end

    new_program = write(intcode, c, new_val)

    %{intcode | program: new_program, idx: intcode.idx + ins.size}
  end

  # EQ
  defp execute(intcode, ins = %Instruction{opcode: 08}) do
    [a, b, c] = ins.params

    a_val = fetch(intcode, a)
    b_val = fetch(intcode, b)
    c_val = fetch(intcode, c)

    new_val = if a_val == b_val, do: 1, else: 0

    if Keyword.fetch!(intcode.opts, :debug) do
      IO.puts("EQ #{inspect(a)} (#{a_val}), #{inspect(b)} (#{b_val})")
      IO.puts("STORE #{new_val} at #{inspect(c)} (#{c_val})")
    end

    new_program = write(intcode, c, new_val)

    %{intcode | program: new_program, idx: intcode.idx + ins.size}
  end

  # OFFSET
  defp execute(intcode, ins = %Instruction{opcode: 09}) do
    relative_base = intcode.relative_base
    [a] = ins.params

    a_val = fetch(intcode, a)

    if Keyword.fetch!(intcode.opts, :debug) do
      IO.puts("OFFSET #{relative_base} by #{inspect(a)} (#{a_val})")
    end

    %{intcode | relative_base: relative_base + a_val, idx: intcode.idx + ins.size}
  end

  # HALT
  defp execute(intcode, %Instruction{opcode: 99}), do: %{intcode | halted: true}

  defp fetch(_intcode, {:immediate, value}), do: value
  defp fetch(intcode, {:position, value}), do: Enum.at(intcode.program, value, 0)

  defp fetch(intcode, {:relative, value}) do
    Enum.at(intcode.program, intcode.relative_base + value, 0)
  end

  defp write(_intcode, {:immediate, _pos}, _val), do: :error
  defp write(intcode, {:position, pos}, val), do: safe_replace(intcode, pos, val)

  defp write(intcode, {:relative, pos}, val) do
    safe_replace(intcode, pos + intcode.relative_base, val)
  end

  defp safe_replace(%{program: program}, idx, val) when idx < length(program) do
    List.replace_at(program, idx, val)
  end

  defp safe_replace(intcode, idx, val) do
    program = intcode.program
    extension = List.duplicate(0, idx - length(program) + 1)

    write(%{intcode | program: program ++ extension}, {:position, idx}, val)
  end
end
