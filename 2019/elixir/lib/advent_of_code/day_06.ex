defmodule AdventOfCode.Day06 do

  @root :COM
  @you :YOU
  @santa :SAN

  def part1(args) do
    args
    |> Stream.flat_map(&String.split(&1, ")"))
    |> Stream.map(&String.to_atom/1)
    |> Stream.chunk_every(2)
    |> Enum.reduce([], fn [parent, child], acc ->
      [{parent, child} | acc]
    end)
    |> orbit_distance()
    |> Keyword.values()
    |> Enum.sum()
  end

  def part2(args) do
    orbits =
      args
      |> Stream.flat_map(&String.split(&1, ")"))
      |> Stream.map(&String.to_atom/1)
      |> Stream.chunk_every(2)
      |> Enum.reduce([], fn [parent, child], acc ->
        [{parent, child} | acc]
      end)

    path_to_self = full_traversal(orbits, @you) -- [@you]
    path_to_santa = full_traversal(orbits, @santa) -- [@santa]

    length(path_to_self -- path_to_santa) + length(path_to_santa -- path_to_self)
  end

  defp orbit_distance(orbits, key \\ @root, depth \\ 0)
  defp orbit_distance(orbits, key, depth) do
    orbits
    |> Keyword.get_values(key)
    |> Enum.reduce([], fn child, acc ->
      acc ++ orbit_distance(orbits, child, depth + 1)
    end)
    |> Keyword.put(key, depth)
  end

  defp full_traversal(orbits, src \\ @root, dest)
  defp full_traversal(_orbits, dest, dest), do: [dest]
  defp full_traversal(orbits, src, dest) do
    orbits
    |> Keyword.get_values(src)
    |> Enum.reduce([], fn child, acc ->
      acc ++ full_traversal(orbits, child, dest)
    end)
    |> maybe_prepend(src)
  end

  defp maybe_prepend([], _src), do: []
  defp maybe_prepend(list, src), do: [src | list]
end
