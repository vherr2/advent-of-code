defmodule AdventOfCode.Day01Test do
  use ExUnit.Case

  import AdventOfCode.Day01

  test "part1" do
    input = [12, 14, 1969, 100_756]
    result = part1(input)

    assert result == 2 + 2 + 654 + 33_583
  end

  test "part2" do
    input = [14, 1969, 100_756]
    result = part2(input)

    assert result == 2 + 966 + 50_346
  end
end
