defmodule AdventOfCode.Day05 do
  def part1(args) do
    # 1
    system_id =
      "What system ID would you like to test?"
      |> Mix.Shell.IO.prompt()
      |> String.trim()
      |> String.to_integer()
      |> List.wrap()

    args
    |> Intcode.intcode(input: system_id)
    |> Map.fetch!(:output)
  end

  def part2(args) do
    # 5
    system_id =
      "What system ID would you like to test?"
      |> Mix.Shell.IO.prompt()
      |> String.trim()
      |> String.to_integer()
      |> List.wrap()

    args
    |> Intcode.intcode(input: system_id)
    |> Map.fetch!(:output)
  end
end
