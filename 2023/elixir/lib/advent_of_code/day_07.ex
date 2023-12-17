defmodule AdventOfCode.Day07 do
  def part1(args) do
    args
    |> parse_args()
    |> Enum.map(fn %{hand: hand} = line ->
      line
      |> Map.put(:type, classify(hand))
      |> Map.put(:eval, rank_hand(hand))
    end)
    |> Enum.sort_by(fn %{type: type} ->
      rank_class(type)
    end, :desc)
    |> Enum.chunk_by(&Map.get(&1, :type))
    |> Enum.map(fn chunk ->
      chunk
      |> Enum.sort_by(&Map.get(&1, :eval), :desc)
    end)
    |> List.flatten()
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {%{bid: bid}, rank}, acc ->
      acc + (bid * rank)
    end)
  end

  def part2(args) do
    args
    |> parse_args()
    |> Enum.map(fn %{hand: hand} = line ->
      line
      |> Map.put(:type, classify_joker(hand))
      |> Map.put(:eval, rank_joker_hand(hand))
    end)
    |> Enum.sort_by(fn %{type: type} ->
      rank_class(type)
    end, :desc)
    |> Enum.chunk_by(&Map.get(&1, :type))
    |> Enum.map(fn chunk ->
      chunk
      |> Enum.sort_by(&Map.get(&1, :eval), :desc)
    end)
    |> List.flatten()
    |> Enum.reverse()
    |> Enum.with_index(1)
    |> Enum.reduce(0, fn {%{bid: bid}, rank}, acc ->
      acc + (bid * rank)
    end)
  end

  defp parse_args(args) do
    args
    |> String.split("\n", trim: true)
    |> Enum.map(fn line ->
      [hand, bid] = String.split(line, " ", parts: 2)

      sorted =
        hand
        |> String.split("", trim: true)
        |> Enum.sort_by(&rank_card/1, :desc)
        |> Enum.join()

      %{
        sorted: sorted,
        hand: hand,
        bid: String.to_integer(bid)
      }
    end)
  end

  defp rank_card("A"), do: "e"
  defp rank_card("K"), do: "d"
  defp rank_card("Q"), do: "c"
  defp rank_card("J"), do: "b"
  defp rank_card("T"), do: "a"
  defp rank_card(x), do: x

  defp rank_joker("A"), do: "e"
  defp rank_joker("K"), do: "d"
  defp rank_joker("Q"), do: "c"
  defp rank_joker("T"), do: "a"
  defp rank_joker("J"), do: "1"
  defp rank_joker(x), do: x

  defp classify(""), do: :five
  defp classify(hand) do
    groups =
      hand
      |> String.split("", trim: true)
      |> Enum.sort()
      |> Enum.chunk_by(&(&1))
      |> Enum.sort_by(&length/1, :desc)

    case groups do
      [[_, _, _, _, _]] -> :five
      [[_, _, _, _] | _] -> :four
      [[_, _, _], [_, _]] -> :house
      [[_, _, _] | _] -> :three
      [[_, _], [_, _] | _] -> :two_pair
      [[_, _] | _] -> :pair
      _ -> :high
    end
  end

  defp classify_joker(hand) do
    {jokers, rest} =
      hand
      |> String.split("", trim: true)
      |> Enum.split_with(&(&1 == "J"))

    rest_class =
      rest
      |> Enum.sort()
      |> Enum.chunk_by(&(&1))
      |> Enum.sort_by(&length/1, :desc)
      |> List.flatten()
      |> Enum.join()
      |> classify()

    case {rest_class, jokers} do
      {:five, _} -> :five
      {:five, _} -> :five
      {:four, [_]} -> :five
      {:four, []} -> :four
      {:house, _} -> :house
      {:three, [_, _]} -> :five
      {:three, [_]} -> :four
      {:three, []} -> :three
      {:two_pair, [_]}  -> :house
      {:two_pair, _}  -> :two_pair
      {:pair, [_, _, _]}  -> :five
      {:pair, [_, _]}  -> :four
      {:pair, [_]}  -> :three
      {:pair, _}  -> :pair
      {:high, [_, _, _, _]} -> :five
      {:high, [_, _, _]} -> :four
      {:high, [_, _]} -> :three
      {:high, [_]} -> :pair
      {:high, _} -> :high
    end
  end

  defp rank_class(:five), do: 7
  defp rank_class(:four), do: 6
  defp rank_class(:house), do: 5
  defp rank_class(:three), do: 4
  defp rank_class(:two_pair), do: 3
  defp rank_class(:pair), do: 2
  defp rank_class(:high), do: 1

  defp rank_hand(hand, joker \\ False) do
    hand
    |> String.split("", trim: true)
    |> Enum.map(&rank_card/1)
    |> Enum.join()
  end

  defp rank_joker_hand(hand) do
    hand
    |> String.split("", trim: true)
    |> Enum.map(&rank_joker/1)
    |> Enum.join()
  end
end
