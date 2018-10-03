defmodule LineServerWeb.LineController do
  use LineServerWeb, :controller
  alias LineServer.LineAgent

  def show(conn, %{"id" => id}) do
    {line_number, _} = Integer.parse(id)
    case LineAgent.get_line(line_number) do
      {:error, _} -> 
        conn = put_status(conn, 413)
        json conn, %{reason: "Beyond end of file"}
      line -> json conn, %{response: line}
    end
  end
end
