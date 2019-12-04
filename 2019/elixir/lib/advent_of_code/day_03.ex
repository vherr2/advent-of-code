defmodule AdventOfCode.Day03 do
  def part1(args) do
    [wire_1, wire_2] = args

    wire_1_path = wire_path_to_coordinates(wire_1)
    wire_2_path = wire_path_to_coordinates(wire_2)

    wire_1_path
    |> find_intersections(wire_2_path)
    |> Enum.map(fn {x, y} -> abs(x) + abs(y) end)
    |> Enum.min()
  end

  def part2(args) do
    [wire_1, wire_2] = args

    wire_1_path =
      wire_1
      |> wire_path_to_coordinates()
      |> Enum.reverse()

    wire_2_path =
      wire_2
      |> wire_path_to_coordinates()
      |> Enum.reverse()

    intersections = find_intersections(wire_1_path, wire_2_path)

    intersections
    |> Enum.map(fn coordinate ->
      distance_1 = steps_taken(wire_1_path, coordinate)
      distance_2 = steps_taken(wire_2_path, coordinate)

      distance_1 + distance_2
    end)
    |> Enum.min()
  end

  defp wire_path_to_coordinates(wire) do
    wire
    |> map_wire_lines()
    |> wire_path_to_coordinates(_x = 0, _y = 0, _coordinates = [])
  end

  defp wire_path_to_coordinates([], _, _, coordinates), do: coordinates

  defp wire_path_to_coordinates([{:L, dist} | rest], x, y, coordinates) do
    end_val = x - dist

    updated_coordinates =
      Enum.reduce((x - 1)..end_val, coordinates, fn new_x, acc ->
        [{new_x, y} | acc]
      end)

    wire_path_to_coordinates(rest, end_val, y, updated_coordinates)
  end

  defp wire_path_to_coordinates([{:R, dist} | rest], x, y, coordinates) do
    end_val = x + dist

    updated_coordinates =
      Enum.reduce((x + 1)..end_val, coordinates, fn new_x, acc ->
        [{new_x, y} | acc]
      end)

    wire_path_to_coordinates(rest, end_val, y, updated_coordinates)
  end

  defp wire_path_to_coordinates([{:U, dist} | rest], x, y, coordinates) do
    end_val = y + dist

    updated_coordinates =
      Enum.reduce((y + 1)..end_val, coordinates, fn new_y, acc ->
        [{x, new_y} | acc]
      end)

    wire_path_to_coordinates(rest, x, end_val, updated_coordinates)
  end

  defp wire_path_to_coordinates([{:D, dist} | rest], x, y, coordinates) do
    end_val = y - dist

    updated_coordinates =
      Enum.reduce((y - 1)..end_val, coordinates, fn new_y, acc ->
        [{x, new_y} | acc]
      end)

    wire_path_to_coordinates(rest, x, end_val, updated_coordinates)
  end

  defp map_wire_lines(wire) do
    Enum.map(wire, fn line ->
      {direction, distance} = String.split_at(line, 1)

      {String.to_atom(direction), String.to_integer(distance)}
    end)
  end

  defp find_intersections(left_traversal, right_traversal) do
    MapSet.intersection(MapSet.new(left_traversal), MapSet.new(right_traversal))
  end

  defp steps_taken(path, coordinate) do
    Enum.find_index([{0, 0} | path], &(&1 == coordinate))
  end
end
