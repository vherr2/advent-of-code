defmodule AdventOfCode.Day04 do
  def part1(args) do
    args
    |> String.trim()
    |> String.split("\n")
    |> Enum.reduce(%{}, fn day, acc ->
      [card, numbers] = String.split(day, ":", parts: 2)

      key =
        card
        |> String.trim_leading("Card")
        |> String.trim_leading(" ")

      [winning, yours] =
        numbers
        |> String.trim()
        |> String.split("|", parts: 2)
        |> Enum.map(fn nums ->
          nums
          |> String.split(" ")
          |> Enum.reject(&(&1 == ""))
          |> MapSet.new()
        end)

      Map.put(acc, key, %{winning: winning, yours: yours})
    end)
    |> Enum.reduce(0, fn {_day, nums}, acc ->
      %{winning: winning, yours: yours} = nums
      num_matches =
        winning
        |> MapSet.intersection(yours)
        |> MapSet.size()

      case num_matches do
        0 -> acc
        _ -> acc + (2 ** (num_matches - 1))
      end
    end)
  end

  def part2(args) do
    parsed =
      args
      |> String.trim()
      |> String.split("\n")
      |> Enum.reverse()
      |> Enum.reduce([], fn day, acc ->
        [card, numbers] = String.split(day, ":", parts: 2)

        {day, _} =
          card
          |> String.trim_leading("Card")
          |> String.trim_leading(" ")
          |> Integer.parse()

        [winning, yours] =
          numbers
          |> String.trim()
          |> String.split("|", parts: 2)
          |> Enum.map(fn nums ->
            nums
            |> String.split(" ")
            |> Enum.reject(&(&1 == ""))
            |> MapSet.new()
          end)

        [%{day: day, winning: winning, yours: yours, copies: 1} | acc]
      end)

    1..length(parsed)
    |> Enum.reduce(parsed, fn idx, acc ->
      day = Enum.find(acc, &(&1[:day] == idx))

      set_copies(day, acc)
    end)
    |> Enum.map(&(&1[:copies]))
    |> Enum.sum()
  end

  defp set_copies(details, cards) do
    %{day: day, winning: winning, yours: yours, copies: copies} = details

    won_copies =
      winning
      |> MapSet.intersection(yours)
      |> MapSet.size()

    case won_copies do
      0 -> cards
      _ ->
        Enum.reduce(1..won_copies, cards, fn idx, acc ->
          acc
          |> List.update_at(day + idx - 1, fn val ->
            Map.update!(val, :copies, &(&1 + copies))
          end)
        end)
    end
  end
end
