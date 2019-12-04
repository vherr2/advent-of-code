defmodule AdventOfCode.Day02 do
  @output 19_690_720

  def part1(args) do
    args
    |> intcode()
    |> Map.get(0)
  end

  def part2(args) do
    {noun, verb} = find_noun_and_verb(args)

    100 * noun + verb
  end

  defp find_noun_and_verb(int_list, noun \\ 0, verb \\ 0)

  defp find_noun_and_verb(int_list, noun, 99) do
    find_noun_and_verb(int_list, noun + 1, 0)
  end

  defp find_noun_and_verb(int_list, noun, verb) do
    output =
      int_list
      |> replace_noun_and_verb(noun, verb)
      |> intcode()
      |> Map.get(0)

    if output == @output do
      {noun, verb}
    else
      find_noun_and_verb(int_list, noun, verb + 1)
    end
  end

  defp replace_noun_and_verb([hd, _pos1, _pos2 | rest], noun, verb) do
    [hd, noun, verb | rest]
  end

  defp intcode(int_list) do
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
