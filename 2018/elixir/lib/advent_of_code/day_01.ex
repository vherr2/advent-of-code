defmodule AdventOfCode.Day01 do
  def part1(args) do
    Enum.sum(args)
  end

  def part2(args) do
    args
    |> Stream.cycle()
    |> Enum.reduce_while(%{count: 0, seen: []}, fn freq, acc ->
      new_freq = acc.count + freq

      if new_freq not in acc.seen do
        new_acc =
          acc
          |> Map.put(:count, new_freq)
          |> Map.update!(:seen, &([new_freq | &1]))

          {:cont, new_acc}
        else
          {:halt, new_freq}
        end
      end)
  end
end
