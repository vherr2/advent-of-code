defmodule Instruction do
  defstruct [:opcode, params: [], size: 1]

  @write_ops [01, 02]

  def parse_instruction(program) do
    ins = %Instruction{opcode: rem(hd(program), 100)}

    load_params(program, ins)
  end

  defp load_params(program, ins) do
    param_count = param_count(ins)

    params = Enum.slice(program, 1, param_count)
    parameter_modes =
      program
      |> param_modes(param_count)
      |> swap_write_mode(ins)

    %{ins | params: Enum.zip(parameter_modes, params), size: param_count + 1}
  end

  defp param_count(%__MODULE__{opcode: 01}), do: 3
  defp param_count(%__MODULE__{opcode: 02}), do: 3
  defp param_count(%__MODULE__{opcode: 03}), do: 1
  defp param_count(%__MODULE__{opcode: 04}), do: 1
  defp param_count(%__MODULE__{opcode: 99}), do: 0

  defp param_modes(program, param_count) do
    program
    |> hd()
    |> Integer.digits()
    |> Enum.drop(-2)
    |> pad_leading_params(param_count)
    |> Enum.reverse()
    |> modes()
  end

  defp pad_leading_params(digits, param_count) when length(digits) == param_count, do: digits
  defp pad_leading_params(digits, param_count) do
    pad_size = param_count - length(digits)
    pad = Enum.map(1..pad_size, fn _ -> 0 end)

    Enum.concat(digits, pad)
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

  def intcode(int_list) do
    int_list
    |> Enum.with_index()
    |> Enum.into(%{}, fn {k, v} -> {v, k} end)
    |> run(int_list)
  end

  defp run(vals, program) do
    instruction = Instruction.parse_instruction(program)

    # TODO: Handle this as a case of execute?
    if instruction.opcode == 99 do
      vals
    else
      vals
      |> execute(instruction)
      |> run(Enum.drop(program, instruction.size))
    end
  end

  defp execute(vals, ins = %Instruction{opcode: 01}) do
    [a, b, c] = ins.params

    left = fetch(vals, a)
    right = fetch(vals, b)

    new_val = left + right

    Map.put(vals, fetch(vals, c), new_val)
  end

  defp execute(vals, ins = %Instruction{opcode: 02}) do
    [a, b, c] = ins.params

    left = fetch(vals, a)
    right = fetch(vals, b)

    new_val = left * right

    Map.put(vals, fetch(vals, c), new_val)
  end

  defp fetch(_vals, {:immediate, value}), do: value
  defp fetch(vals, {:position, value}), do: Map.fetch!(vals, value)
end
