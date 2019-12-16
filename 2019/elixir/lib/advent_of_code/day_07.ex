defmodule AdventOfCode.Day07 do
  def part1(args) do
    0..4
    |> Enum.to_list()
    |> permutations()
    |> Enum.map(fn phase_setting_sequence ->
      phase_setting_sequence
      |> Enum.reduce(0, fn setting, acc ->
        args
        |> Intcode.intcode(input: [setting, acc])
        |> Map.fetch!(:output)
      end)
    end)
    |> Enum.max()
  end

  def part2(args) do
    5..9
    |> Enum.to_list()
    |> permutations()
    |> Enum.map(fn phase_setting_sequence ->
      first_pass =
        phase_setting_sequence
        |> Enum.reduce([%Intcode{output: 0}], fn setting, acc ->
          output = Intcode.intcode(args, input: [setting, hd(acc).output])

          [output | acc]
        end)
        |> Enum.reverse()
        |> tl()

      Stream.cycle([0])
      |> Enum.reduce_while(first_pass, fn _, acc ->
        [a, b, c, d, e = %{output: output}] = acc

        a1 = Intcode.intcode(a, input: [output])
        b1 = Intcode.intcode(b, input: [a1.output])
        c1 = Intcode.intcode(c, input: [b1.output])
        d1 = Intcode.intcode(d, input: [c1.output])
        e1 = Intcode.intcode(e, input: [d1.output])

        if e1.halted do
          {:halt, e1.output}
        else
          {:cont, [a1, b1, c1, d1, e1]}
        end
      end)
    end)
    |> Enum.max()
  end

  defp permutations([]), do: [[]]

  defp permutations(list),
    do: for(elem <- list, rest <- permutations(list -- [elem]), do: [elem | rest])
end
