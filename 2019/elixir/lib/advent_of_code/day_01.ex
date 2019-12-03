defmodule AdventOfCode.Day01 do
  def part1(args) do
    args
    |> Stream.map(&fuel_needed/1)
    |> Enum.sum()
  end

  defp fuel_needed(mass) do
    mass
    |> div(3)
    |> Kernel.-(2)
  end

  def part2(args) do
    args
    |> Stream.map(&fuel_needed2/1)
    |> Enum.sum()
  end

  defp fuel_needed2(mass) when mass < 9, do: 0

  defp fuel_needed2(mass) do
    initial =
      mass
      |> div(3)
      |> Kernel.-(2)

    initial + fuel_needed2(initial)
  end
end
