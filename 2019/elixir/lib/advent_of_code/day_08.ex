defmodule AdventOfCode.Day08 do
  @width 25
  @height 6

  def part1(args) do
    %{"1" => ones, "2" => twos} =
      args
      |> Enum.chunk_every(@width * @height)
      |> Enum.map(fn layer -> Enum.group_by(layer, & &1) end)
      |> Enum.min_by(& &1["0"])

    length(ones) * length(twos)
  end

  def part2(args) do
    args
    |> Enum.with_index()
    |> Enum.group_by(
      fn {_pixel, idx} -> rem(idx, @width * @height) end,
      fn {pixel, _idx} -> pixel end
    )
    |> Enum.map(fn {pixel, layers} ->
      {pixel, Enum.find(layers, fn color -> color != "2" end)}
    end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.map(fn {_, color} ->
      if color == "0", do: " ", else: "O"
    end)
    |> Enum.chunk_every(@width)
    |> Enum.map(&Enum.join(&1, " "))
  end
end
