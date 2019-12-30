defmodule Coordinate do
  @empty "."
  @asteroid "#"

  defstruct [:element, :x, :y]

  def empty?(%__MODULE__{element: element}), do: element == @empty

  def asteroid?(%__MODULE__{element: element}), do: element == @asteroid

  def angle(%{x: x, y: y}, %{x: x, y: y}), do: nil
  def angle(%{x: x, y: ly}, %{x: x, y: ry}), do: {:=, sign(ly, ry), :infinity}

  def angle(left, right) do
    %{x: lx, y: ly} = left
    %{x: rx, y: ry} = right
    dx = lx - rx
    dy = ly - ry

    {sign(lx, rx), sign(ly, ry), :math.tan(dy / dx)}
  end

  defp sign(left, right) when left == right, do: :=
  defp sign(left, right) when left < right, do: :-
  defp sign(left, right) when left > right, do: :+
end

defmodule AdventOfCode.Day10 do
  def part1(args) do
    asteroids =
      args
      |> Enum.map(&Enum.with_index/1)
      |> Enum.with_index()
      |> Enum.flat_map(fn {xs, y} ->
        Enum.map(xs, fn {element, x} ->
          %Coordinate{element: element, x: x, y: y}
        end)
      end)
      |> Enum.filter(&Coordinate.asteroid?/1)

    asteroids
    |> Enum.map(fn asteroid ->
      asteroids
      |> Enum.map(fn dest -> Coordinate.angle(asteroid, dest) end)
      |> Enum.reject(&is_nil/1)
      |> Enum.uniq()
      |> length()
    end)
    |> Enum.max()
  end

  def part2(args) do
  end
end
