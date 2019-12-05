defmodule Intcode do
  def intcode(int_list) do
    int_list
    |> Enum.with_index()
    |> Enum.into(%{}, fn {k, v} -> {v, k} end)
    |> apply_opcodes(int_list)
  end

  defp apply_opcodes(vals, [99 | _rest]), do: vals

  defp apply_opcodes(vals, [op, a, b, c | rest]) do
    left = Map.fetch!(vals, a)
    right = Map.fetch!(vals, b)

    new_val = new_val(op, left, right)

    vals
    |> Map.put(c, new_val)
    |> apply_opcodes(rest)
  end

  defp new_val(1, left, right), do: left + right
  defp new_val(2, left, right), do: left * right
end
