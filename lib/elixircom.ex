defmodule Elixircom do
  alias Elixircom.Server

  @spec run(serial_port_name :: binary, uart_opts :: keyword) :: :ok
  def run(serial_port_name, opts \\ []) do
    gl = Process.group_leader()
    orig_opts = :io.getopts(gl)

    :io.setopts(gl, echo: false, expand_fun: false, binary: false)

    case Server.start(group_leader: gl, uart_opts: opts, serial_port_name: serial_port_name) do
      {:ok, server} ->
        get_chars(gl, server)
        :io.setopts(gl, orig_opts)
      {:error, _} = error ->
        :io.setopts(gl, orig_opts)
        error
    end
  end

  defp get_chars(gl, server) do
    case :io.get_chars(gl, "", 1) do
      :eof ->
        get_chars(gl, server)

      [char] ->
        Server.handle_input(server, char)
        get_chars(gl, server)

      _ ->
        :ok
    end
  end
end
