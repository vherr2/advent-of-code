defmodule AdventOfCode.Day15 do
  def part1(args) do
    args
    |> String.trim()
    |> String.split(",")
    |> Enum.map(fn seq ->
      seq
      |> String.split("")
      |> Enum.reject(&(&1 == ""))
      |> Enum.reduce(0, fn char, acc -> parse_char(char, acc) end)
    end)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> String.trim()
    |> String.split(",")
    |> Enum.reduce(List.duplicate([], 256), fn seq, acc ->
      cond do
        String.contains?(seq, "-") -> remove_lens(seq, acc)
        String.contains?(seq, "=") -> replace_lens(seq, acc)
      end
    end)
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {box, box_idx}, acc ->
      box
      |> Enum.with_index(1)
      |> Enum.reduce(0, fn {{_, focus}, idx}, acc ->
        acc + (box_idx * idx * focus)
      end)
      |> Kernel.+(acc)
    end)
  end

  defp ascii(var) do
    <<v::utf8>> = var

    v
  end

  def parse_char(char, acc) do
    rem((acc + ascii(char)) * 17, 256)
  end

  defp hash_box(label) do
    label
    |> String.split("", trim: true)
    |> Enum.reduce(0, &parse_char/2)
  end

  defp remove_lens(seq, acc) do
    [label, length] = String.split(seq, "-", parts: 2)

    box = hash_box(label)

    List.update_at(acc, box, fn contents ->
      List.keydelete(contents, label, 0)
    end)
  end

  defp replace_lens(seq, acc) do
    [label, length] = String.split(seq, "=", parts: 2)

    box = hash_box(label)

    List.update_at(acc, box, fn contents ->
      List.keystore(contents, label, 0, {label, String.to_integer(length)})
    end)
  end
end
