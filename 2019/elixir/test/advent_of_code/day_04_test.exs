defmodule AdventOfCode.Day04Test do
  use ExUnit.Case

  import AdventOfCode.Day04

  test "part1" do
    input = [111_111, 223_450, 123_789]
    result = part1(input)

    assert result == 1
  end

  test "part2" do
    input = [112_233, 123_444, 111_122]
    result = part2(input)

    assert result == 2
  end
end
