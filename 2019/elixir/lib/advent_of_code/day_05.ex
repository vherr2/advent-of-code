defmodule AdventOfCode.Day05 do
  def part1(args) do
    # 1
    system_id =
      "What system ID would you like to test?"
      |> Mix.Shell.IO.prompt()
      |> String.trim()
      |> String.to_integer()

    Intcode.intcode(args, input: system_id)
  end

  def part2(args) do
    # 5
    system_id =
      "What system ID would you like to test?"
      |> Mix.Shell.IO.prompt()
      |> String.trim()
      |> String.to_integer()

    Intcode.intcode(args, input: system_id)
  end
end
