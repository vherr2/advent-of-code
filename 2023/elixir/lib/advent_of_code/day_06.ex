defmodule AdventOfCode.Day06 do
  def part1(args) do
    race_pairs =
      args
      |> String.trim()
      |> String.split("\n", parts: 2)
      |> Enum.map(fn part ->
        part
        |> String.split(~r/\s/)
        |> Enum.reject(&(&1 == ""))
        |> Enum.drop(1)
        |> Enum.map(&Integer.parse/1)
        |> Enum.map(&elem(&1, 0))
      end)
      |> Enum.zip()

    race_pairs
    |> Enum.map(fn {time, distance} ->
      1..time
      |> Enum.map(fn speed ->
        speed * (time - speed)
      end)
      |> Enum.filter(&(&1 > distance))
      |> length()
    end)
    |> Enum.reduce(1, fn margin, acc ->
      acc * margin
    end)
  end

  def part2(args) do
    [time, distance] =
      args
      |> String.trim()
      |> String.split("\n", parts: 2)
      |> Enum.map(fn part ->
        part
        |> String.split(~r/\s/)
        |> Enum.reject(&(&1 == ""))
        |> Enum.drop(1)
        |> Enum.map(&Integer.parse/1)
        |> Enum.map(&elem(&1, 0))
        |> Enum.join()
        |> Integer.parse
        |> elem(0)
      end)

    1..time
    |> Enum.map(fn speed ->
      speed * (time - speed)
    end)
    |> Enum.filter(&(&1 > distance))
    |> length()
  end
end
