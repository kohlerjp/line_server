defmodule LineServer.LineParser do
  # This function will return a data structure that contains the block size,
  # and a linked list of newline amounts. Each node in the linked list
  # describes how many lines have been seen up to the current block
  def parse_file(filename) do
    size = get_size(filename)
    # Each block will be the square root of total file size
    block_size = :math.sqrt(size) |> Float.ceil() |> round
    {:ok, file} = :file.open(filename, [:read, :binary])
    {time, line_data} = :timer.tc(fn -> do_parse_file(file, 0, [], block_size, 0) end)
    :file.close(file)
    IO.puts("Parsed file in #{time / 1_000_000} seconds")
    {block_size, Enum.reverse(line_data)}
  end

  # Iterates through the file in increments of {block_size}
  # The parser counts the number of new lines in each block
  # Iterate to block_size - 1 blocks, since linked list will be 0-based
  def do_parse_file(_file, block, acc, block_size, _previous_count) when block == block_size - 1, do: acc
  def do_parse_file(file, block, acc, block_size, previous_count) do
    :file.position(file, block * block_size)
    {:ok, text} = :file.read(file, block_size)
    count = count_new_lines(text) + previous_count
    updated_acc = [{block, count} | acc]
    do_parse_file(file, block + 1, updated_acc, block_size, count)
  end

  defp get_size(filename) do
    case File.stat(filename) do
      {:ok, stats} -> stats.size
      _ -> :error
    end
  end

  defp count_new_lines(string) do
    string
    |> String.graphemes
    |> Enum.count(& &1 == "\n")
  end
end
