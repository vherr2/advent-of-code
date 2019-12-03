defmodule AdventOfCode.Day01Test do
  use ExUnit.Case

  import AdventOfCode.Day01

  test "part1" do
    input = [+1, -2, +3, +1]
    result = part1(input)

    assert result == 3
  end

  test "part2" do
    input = [+1, -2, +3, +1]
    result = part2(input)

    assert result == 2
  end
end
