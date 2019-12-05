defmodule AdventOfCode.Day04 do
  def part1(args) do
    filter_func = fn group -> length(group) >= 2 end

    args
    |> Stream.filter(&monotonic_increase?/1)
    |> Stream.filter(&two_adjacent?(&1, filter_func))
    |> Enum.count()
  end

  def part2(args) do
    filter_func = fn group -> length(group) == 2 end

    args
    |> Stream.filter(&monotonic_increase?/1)
    |> Stream.filter(&two_adjacent?(&1, filter_func))
    |> Enum.count()
  end

  defp monotonic_increase?(number) do
    number
    |> to_string()
    |> String.split("", trim: true)
    |> Enum.chunk_every(2, 1, :discard)
    |> Enum.all?(fn [left, right] -> left <= right end)
  end

  defp two_adjacent?(number, filter_func) do
    number
    |> to_string()
    |> String.split("", trim: true)
    |> Enum.group_by(& &1)
    |> Map.values()
    |> Enum.any?(&filter_func.(&1))
  end
end
