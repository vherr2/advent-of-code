defmodule AdventOfCode.Day02 do
  @output 19_690_720

  def part1(args) do
    args
    |> Intcode.intcode()
    |> Map.fetch!(:program)
    |> Enum.at(0)
  end

  def part2(args) do
    {noun, verb} = find_noun_and_verb(args)

    100 * noun + verb
  end

  defp find_noun_and_verb(int_list, noun \\ 0, verb \\ 0)

  defp find_noun_and_verb(int_list, noun, 99) do
    find_noun_and_verb(int_list, noun + 1, 0)
  end

  defp find_noun_and_verb(int_list, noun, verb) do
    output =
      int_list
      |> replace_noun_and_verb(noun, verb)
      |> Intcode.intcode()
      |> Map.fetch!(:program)
      |> Enum.at(0)

    if output == @output do
      {noun, verb}
    else
      find_noun_and_verb(int_list, noun, verb + 1)
    end
  end

  defp replace_noun_and_verb([hd, _pos1, _pos2 | rest], noun, verb) do
    [hd, noun, verb | rest]
  end
end
