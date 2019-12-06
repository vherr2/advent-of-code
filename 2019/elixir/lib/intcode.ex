defmodule Instruction do
  defstruct [:opcode, params: [], size: 1]

  @debug_mode false
  @write_ops [01, 02, 03]

  def parse_instruction(program, idx) do
    opcode =
      program
      |> Enum.at(idx)
      |> rem(100)

    ins = %Instruction{opcode: opcode}

    load_params(program, idx, ins)
  end

  defp load_params(program, idx, ins) do
    param_count = param_count(ins)

    params = Enum.slice(program, idx + 1, param_count)

    parameter_modes =
      program
      |> Enum.at(idx)
      |> param_modes(param_count)
      |> swap_write_mode(ins)

    %{ins | params: Enum.zip(parameter_modes, params), size: param_count + 1}
  end

  defp param_count(%__MODULE__{opcode: 01}), do: 3
  defp param_count(%__MODULE__{opcode: 02}), do: 3
  defp param_count(%__MODULE__{opcode: 03}), do: 1
  defp param_count(%__MODULE__{opcode: 04}), do: 1
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
  # TODO
  # defstruct [halted: false]

  def intcode(int_list, opts \\ []) do
    opts = Keyword.merge(opts, [{:debug, @debug_mode}])

    run(int_list, _idx = 0, opts)
  end

  defp run(program, idx, _opts) when idx > length(program), do: program
  defp run(program, idx, opts) do
    instruction = Instruction.parse_instruction(program, idx)

    # TODO: Handle this as a case of execute?
    if instruction.opcode == 99 do
      program
    else
      program
      |> execute(instruction, opts)
      |> run(idx + instruction.size, opts)
    end
  end

  # ADD
  defp execute(program, ins = %Instruction{opcode: 01}, opts) do
    [a, b, c] = ins.params

    left = fetch(program, a)
    right = fetch(program, b)

    new_val = left + right

    if Keyword.get(opts, :debug, false) do
      IO.inspect("ADD #{inspect(a)} (#{left}) and #{inspect(b)} (#{right})")
      IO.inspect("STORE #{new_val} at #{inspect(c)}")
    end

    List.replace_at(program, fetch(program, c), new_val)
  end

  # MULT
  defp execute(program, ins = %Instruction{opcode: 02}, opts) do
    [a, b, c] = ins.params

    left = fetch(program, a)
    right = fetch(program, b)

    new_val = left * right

    if Keyword.get(opts, :debug, false) do
      IO.inspect("MULT #{inspect(a)} (#{left}) and #{inspect(b)} (#{right})")
      IO.inspect("STORE #{new_val} at #{inspect(c)}")
    end

    List.replace_at(program, fetch(program, c), new_val)
  end

  # LOAD
  defp execute(program, ins = %Instruction{opcode: 03}, opts) do
    input = Keyword.fetch!(opts, :input)
    [a] = ins.params

    if Keyword.get(opts, :debug, false) do
      IO.puts("LOAD #{input} to #{fetch(program, a)}")
    end

    List.replace_at(program, fetch(program, a), input)
  end

  # READ
  defp execute(program, ins = %Instruction{opcode: 04}, opts) do
    [a] = ins.params |> IO.inspect()

    if Keyword.get(opts, :debug, false) do
      IO.puts("READ #{inspect(a)}")
    end

    program
    |> fetch(a)
    |> IO.inspect()

    program
  end

  defp fetch(_vals, {:immediate, value}), do: value
  defp fetch(program, {:position, value}), do: Enum.at(program, value)
end
