defmodule Mix.Tasks.D10.P1 do
  use Mix.Task

  import AdventOfCode.Day10

  @shortdoc "Day 10 Part 1"
  def run(args) do
    input =
      "priv/day_10.txt"
      |> File.stream!([:read])
      |> Stream.map(&String.trim/1)
      |> Enum.map(&String.split(&1, "", trim: true))

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_1: fn -> input |> part1() end}),
      else:
        input
        |> part1()
        |> IO.inspect(label: "Part 1 Results")
  end
end
