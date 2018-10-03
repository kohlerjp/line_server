defmodule LineServer.LineAgentTest do
  use ExUnit.Case
  import LineServer.LineAgent
  @line_data [{0, 30}, {1, 90}, {2, 200}, {3, 290}, {4, 320}]

  test "Returns :error if line is beyond end of file" do
    assert find_start(@line_data, 400, 0) == :error
  end

  test "returns the starting block for the given line" do
    {starting_block, _seen, _size} = find_start(@line_data, 100, 0)
    assert starting_block == 2
  end

  test "returns the amount of lines seen up to the starting block" do
    {_starting_block, seen, _size} = find_start(@line_data, 250, 0)
    assert seen == 200
  end

  test "returns correct read size when line is in single block" do
    {_starting_block, _seen, size} = find_start(@line_data, 250, 0)
    assert size == 1
  end

  test "returns correct read size when line is across multiple blocks" do
    {_starting_block, _seen, size} = find_start(@line_data, 200, 0)
    assert size == 2
  end

  test "returns correct read size when line is across many blocks" do
    line_data = [{0, 20}, {1, 30}, {2, 30}, {3, 30}, {4, 30}, {5, 35}]
    {_starting_block, _seen, size} = find_start(line_data, 30, 0)
    assert size == 5
  end

  test "returns correct attributes when entire file is a single line" do
    line_data = [{0, 0}, {1, 0}, {2, 0}, {3, 0}, {4, 0}, {5, 1}]
    {starting_block, seen, size} = find_start(line_data, 0, 0)
    assert starting_block == 0
    assert seen == 0
    assert size == 6
  end

  test "locates correct line" do
    text = "line 0\nline 1\nline 2\nline 3\nline 4"
    requested_line = locate_line(text, 3)
    assert requested_line == "line 3"
  end
end
