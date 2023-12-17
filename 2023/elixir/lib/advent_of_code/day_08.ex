defmodule AdventOfCode.Day08 do
  def part1(args) do
    %{
      sequence: sequence,
      network: network
    } =
      args
      |> parse_args()

    end_fn = (fn x -> x == "ZZZ" end)

    count_steps("AAA", end_fn, sequence, network)
  end

  def part2(args) do
    %{
      sequence: sequence,
      network: network
    } =
      args
      |> parse_args()

    starts =
      network
      |> Enum.filter(fn {k, _} -> String.ends_with?(k, "A") end)
      |> Enum.map(&elem(&1, 0))

    ends =
      network
      |> Enum.filter(fn {k, _} -> String.ends_with?(k, "Z") end)
      |> Enum.map(&elem(&1, 0))

    end_fn = (fn x -> Enum.member?(ends, x) end)


    starts
    |> Enum.map(&count_steps(&1, end_fn, sequence, network))
    |> lcm()
  end

  defp parse_args(args) do
    [sequence, _ | network] =
      args
      |> String.trim()
      |> String.split("\n")


    cycle =
      sequence
      |> String.split("")
      |> Enum.reject(&(&1 == ""))
      |> Enum.map(&String.to_atom/1)
      |> Stream.cycle()

    parsed =
      network
      |> Enum.reduce(%{}, fn ins, acc ->
        parsed = Regex.named_captures(~r/(?<node>\w{3}) = \((?<left>\w{3}), (?<right>\w{3})\)/, ins)

        Map.put(acc, parsed["node"], %{"L": parsed["left"], "R": parsed["right"]})
      end)

    %{
      sequence: cycle,
      network: parsed
    }
  end

  defp count_steps(start, end_fn, sequence, network) do
    sequence
    |> Enum.reduce_while({0, start}, fn direction, {cnt, node} ->
      next =
        network
        |> Map.get(node)
        |> Map.get(direction)

      if end_fn.(next) do
        {:halt, cnt + 1}
      else
        {:cont, {cnt + 1, next}}
      end
    end)
  end

  def gcd(a, 0), do: a
	def gcd(0, b), do: b
	def gcd(a, b), do: gcd(b, rem(a,b))

  def lcm(0, 0), do: 0
  def lcm(a, b), do: div(a*b, gcd(a,b))
  def lcm([x]), do: x
  def lcm([a, b | rest]), do: lcm([lcm(a, b) | rest])
end
