defmodule AdventOfCode.Day09 do
  def part1(args) do
    args
    |> Intcode.intcode(input: [1])
    |> Map.fetch!(:output)
  end

  def part2(args) do
    args
    |> Intcode.intcode(input: [2])
    |> Map.fetch!(:output)
  end
end
