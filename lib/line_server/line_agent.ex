defmodule LineServer.LineAgent do
  use Agent
  @moduledoc """
  This module is responsible for storing and locating line data.
  The state of the module stores the line indexes that were created at startup.
  When a 'get_line' request comes in, the agent will calculate which block (or blocks)
  it will need to look at. It then scans that part of the file for
  the desired line.
  """

  def start_link({line_data, filename}) do
    Agent.start_link(fn -> {line_data, filename} end, name: __MODULE__)
  end

  def get_line(line_number) do
    Agent.get(__MODULE__, fn {line_data, filename} -> do_get_line(line_data, filename, line_number) end)
  end

  defp do_get_line({chunk_size, line_list}, filename, line_number) do
    case find_start(line_list, line_number, 0) do
      {starting_block, seen, read_size} ->
        newline_count = line_number - seen # How many newlines do we need to see in this block
        block_text = get_block_text(chunk_size * starting_block, read_size * chunk_size, filename)
        locate_line(block_text, newline_count)
      :error -> {:error, :beyond_eof}
    end
  end

  # Locates the start of the file and the read size
  def find_start([], _line_number, _acc) do
    :error
  end
  def find_start([{chunk, seen} | rest], line_number, acc) do
    cond do
      line_number == seen -> {chunk, acc, get_read_size(seen, rest)} # line is across blocks
      line_number < seen -> {chunk, acc, 1} # line is in a single block
      true -> find_start(rest, line_number, seen) # continue traversing list
    end
  end

  # determine how many blocks need to be read to find full line
  defp get_read_size(_line_number, []), do: 2 # Need to read at least 2 blocks
  defp get_read_size(base_val, [{_chunk, seen} | rest]) do
    if seen > base_val, do: 2, else: 1 + get_read_size(base_val, rest)
  end

  # scan the file and return the block(s) of text containing desired line
  defp get_block_text(starting_loc, read_size, filename) do
    {:ok, file} = :file.open(filename, [:read, :binary])
    :file.position(file, starting_loc)
    {:ok, text} = :file.read(file, read_size)
    :file.close(file)
    text
  end

  def locate_line(text, count) do
    text 
    |> String.split("\n")
    |> Enum.at(count)
  end
end
