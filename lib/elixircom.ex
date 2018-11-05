defmodule Elixircom do
  require Logger
  alias Elixircom.Server

  @type uart_opts :: {:speed, non_neg_integer}

  @doc """
  Run `Elixircom`

  This will, in effect, make your IEx session into a serial port terminal emulator.

  You can always get back to your original IEx session by pressing: `Ctrl+B`

  The first argument is the serial port name which is string of the serial port
  device you are trying to connect to.

  The second argument is a keyword list of `uart_opts`.
  """
  @spec run(serial_port_name :: binary, uart_opts) :: :ok
  def run(serial_port_name, opts \\ []) do
    gl = Process.group_leader()
    orig_opts = :io.getopts(gl)

    :io.setopts(gl, echo: false, expand_fun: false, binary: false)

    case Server.start(
           group_leader: gl,
           uart_opts: opts,
           serial_port_name: serial_port_name,
           io_restore_opts: orig_opts
         ) do
      {:ok, server} ->
        get_chars(gl, server)
        :io.setopts(gl, orig_opts)

      {:error, _} = error ->
        :io.setopts(gl, orig_opts)
        log_error(error)
    end
  end

  defp get_chars(gl, server) do
    case :io.get_chars(gl, "", 1) do
      :eof ->
        get_chars(gl, server)

      [2] ->
        Server.stop(server)
        :ok

      [char] ->
        Server.handle_input(server, char)
        get_chars(gl, server)

      _ ->
        :ok
    end
  end

  defp log_error({:error, :enoent} = error) do
    Logger.error("""
    Unable to find specified port.

    Please make sure your device is plugged in and ready to
    be connected to.
    """)

    error
  end

  defp log_error({:error, :eagain} = error) do
    Logger.error("""
    Serial port is already open.

    Make sure you are not connecting to the port in another
    terminal or IEx session.
    """)

    error
  end

  defp log_error({:error, :eacces} = error) do
    Logger.error("""
    Permission denied when opening port.

    Make sure you have the correct permissions to
    access the port.
    """)

    error
  end
end
