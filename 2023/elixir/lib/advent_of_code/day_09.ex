defmodule AdventOfCode.Day09 do
  def part1(args) do
    args
    |> parse_args()
    |> Enum.map(&Enum.reverse/1)
    |> Enum.map(fn seq -> historic(seq, &Kernel.-/2) end)
    |> Enum.map(&List.first/1)
    |> Enum.sum()
  end

  def part2(args) do
    args
    |> parse_args()
    |> Enum.map(fn seq -> historic(seq, &Kernel.-/2) end)
    |> Enum.map(&List.first/1)
    |> Enum.sum()
  end

  defp parse_args(args) do
    args
    |> String.trim()
    |> String.split("\n")
    |> Enum.map(fn line ->
      line
      |> String.split(~r/\s/)
      |> Enum.map(&Integer.parse/1)
      |> Enum.map(&elem(&1, 0))
    end)
  end

  defp historic(sequence, op) do
    if Enum.all?(sequence, &(&1 == 0)) do
      [0 | sequence]
    else
      extended =
        sequence
        |> Enum.chunk_every(2, 1, :discard)
        |> Enum.map(fn [r, l] -> r - l end)
        |> historic(op)

      [List.first(extended) + List.first(sequence) | sequence]
    end
  end
end
