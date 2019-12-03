defmodule Mix.Tasks.D02.P1 do
  use Mix.Task

  import AdventOfCode.Day02

  @shortdoc "Day 02 Part 1"
  def run(args) do
    input =
      "priv/day_02.txt"
      |> File.stream!([:read])
      |> Enum.map(&String.split(&1, ","))
      |> List.flatten()
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.to_integer/1)
      |> restore_gravity_assist()

    if Enum.member?(args, "-b"),
      do: Benchee.run(%{part_1: fn -> input |> part1() end}),
      else:
        input
        |> part1()
        |> IO.inspect(label: "Part 1 Results")
  end

  # Replace position `1` with the value `12`
  # Replace position `2` with the value `2`
  defp restore_gravity_assist([hd, _pos1, _pos2 | rest]), do: [hd, 12, 2 | rest]
end
