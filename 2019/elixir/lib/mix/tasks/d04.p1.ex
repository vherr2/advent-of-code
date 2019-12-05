defmodule Mix.Tasks.D04.P1 do
  use Mix.Task

  import AdventOfCode.Day04

  @shortdoc "Day 04 Part 1"
  def run(args) do
    [first, last] =
      "priv/day_04.txt"
      |> File.stream!([:read])
      |> Stream.map(&String.trim/1)
      |> Enum.flat_map(&String.split(&1, ","))
      |> Enum.map(&String.to_integer/1)

    input = first..last

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_1: fn -> input |> part1() end}),
      else:
        input
        |> part1()
        |> IO.inspect(label: "Part 1 Results")
  end
end
