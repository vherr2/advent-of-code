defmodule AdventOfCode.Day03 do
  @gear (~r/\*/)
  @symbols (~r/@|#|\$|\=|\+|%|&|\/|\*|-/)

  def part1(input) do
    lines =
      input
      |> String.split("\n")

    [first, second] = Enum.take(lines, 2)

    init = number_bounds(first, first) ++ number_bounds(first, second)

    lines
    |> Enum.chunk_every(3, 1)
    |> Enum.reduce(init, fn group, acc ->
      case group do
        [first, mid, last] ->
          acc ++ number_bounds(mid, first) ++ number_bounds(mid, mid) ++ number_bounds(mid, last)
        [first, last] ->
          acc ++ number_bounds(last, first) ++ number_bounds(last, last)
        _ ->
          acc
      end
    end)
    |> Enum.map(&String.to_integer/1)
    |> Enum.sum()
  end

  defp number_bounds(line, compare) do
    values = Regex.scan(~r/\d+/, line)
    indices = Regex.scan(~r/\d+/, line, return: :index)

    indices
    |> Enum.zip(values)
    |> Enum.reduce([], fn {[{start, length}], [val]}, acc ->
      pattern = String.slice(compare, max(start - 1, 0), length + 2)

      if String.match?(pattern, @symbols) do
        [val | acc]
      else
        acc
      end
    end)
  end

  def part2(input) do
    lines =
      input
      |> String.split("\n")

    [first, second] =
      lines
      |> Enum.take(2)
      |> Enum.with_index

    gear_map =
      %{}
      |> gears(first, first)
      |> gears(first, second)

    lines
    |> Enum.with_index()
    |> Enum.chunk_every(3, 1)
    |> Enum.reduce(gear_map, fn group, acc ->
      case group do
        [first, mid, last] ->
          acc
          |> gears(mid, first)
          |> gears(mid, mid)
          |> gears(mid, last)
        [first, last] ->
          acc
          |> gears(last, first)
          |> gears(last, last)
        _ ->
          acc
      end
    end)
    |> Enum.filter(fn {_k, v} -> length(v) == 2 end)
    |> Enum.map(fn {_, [left, right]} ->
      String.to_integer(left) * String.to_integer(right)
    end)
    |> Enum.sum()
  end

  defp gears(gear_map, {line, lidx}, {compare, _}) do
    @gear
    |> Regex.scan(line, return: :index)
    |> Enum.reduce(gear_map, fn [{start, _}], acc ->
      pattern = String.slice(compare, max(start - 1, 0), 3)

      if String.match?(pattern,~r/\d+/) do
        left =
          compare
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.take_while(fn {val, idx} ->
            String.match?(val, ~r/\d+/) or idx < start
          end)
          |> Enum.reverse()
          |> Enum.take_while(fn {val, _idx} ->
            String.match?(val, ~r/\d+/)
          end)
          |> Enum.reverse()

        right =
          compare
          |> String.graphemes()
          |> Enum.with_index()
          |> Enum.reverse()
          |> Enum.take_while(fn {val, idx} ->
            String.match?(val, ~r/\d+/) or idx > start
          end)
          |> Enum.reverse()
          |> Enum.take_while(fn {val, _idx} ->
            String.match?(val, ~r/\d+/)
          end)

        gear_number =
          [left, right]
          |> Enum.uniq()
          |> Enum.map(fn diglist ->
            diglist
            |> Enum.map(&elem(&1, 0))
            |> Enum.join()
          end)
          |> Enum.reject(&(&1 == ""))

        Map.update(acc, {lidx, start}, gear_number, fn val -> gear_number ++ val end)
      else
        acc
      end
    end)
  end
end
