defmodule AdventOfCode.Day02Test do
  use ExUnit.Case

  import AdventOfCode.Day02

  test "part1" do
    input = [1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50]
    result = part1(input)

    assert result == 3500
  end

  # Need to fix this up so that I can pass in @output as an argument,
  # rather than hard coding it as a moudle attr
  @tag :skip
  test "part2" do
    input = [1, 9, 10, 3, 2, 3, 11, 0, 99, 30, 40, 50]
    result = part2(input)

    assert result == {12, 2}
  end
end
