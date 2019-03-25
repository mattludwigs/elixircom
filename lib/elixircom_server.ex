defmodule Elixircom.Server do
  use GenServer

  @moduledoc false

  alias Circuits.UART

  defmodule State do
    @moduledoc false
    defstruct group_leader: nil, uart: nil, serial_port_name: nil, io_restore_opts: []
  end

  @spec start(keyword()) :: GenServer.on_start()
  def start(opts) do
    GenServer.start(__MODULE__, opts)
  end

  @spec handle_input(GenServer.server(), integer()) :: :ok
  def handle_input(server, char) do
    GenServer.cast(server, {:input, char})
  end

  @spec stop(GenServer.server()) :: :ok
  def stop(server) do
    GenServer.stop(server)
  end

  @impl true
  def init(opts) do
    serial_port_name = Keyword.get(opts, :serial_port_name)

    uart_opts =
      opts
      |> Keyword.get(:uart_opts)
      |> clean_uart_opts()

    with {:ok, uart} <- UART.start_link(),
         :ok <- UART.open(uart, serial_port_name, uart_opts),
         opts = Keyword.put(opts, :uart, uart) do
      {:ok, struct(State, opts)}
    else
      {:error, reason} ->
        {:stop, reason}
    end
  end

  @impl true
  def handle_cast({:input, char}, %State{uart: uart} = state) do
    UART.write(uart, key_to_uart(char))
    {:noreply, state}
  end

  @impl true
  def handle_info(
        {:circuits_uart, _name, {:error, :einval}},
        %State{group_leader: gl, io_restore_opts: io_opts} = state
      ) do
    IO.puts("""
    Looks like there is trouble with serial port communication, stopping Elixircom.

    Please ensure your device is connected.
    """)

    :io.setopts(gl, io_opts)
    {:stop, :normal, state}
  end

  @impl true
  def handle_info({:circuits_uart, _name, data}, %State{group_leader: gl} = state) do
    data = uart_to_printable(data)
    IO.write(gl, data)
    {:noreply, state}
  end

  @impl true
  def terminate(:normal, %State{uart: uart}) do
    UART.close(uart)
    :ok
  end

  defp uart_to_printable(data) do
    for <<c <- data>>, into: "", do: make_printable(c)
  end

  defp make_printable(0), do: <<>>
  defp make_printable(?\a), do: <<>>
  defp make_printable(?\b), do: IO.ANSI.cursor_left()
  defp make_printable(other), do: <<other>>

  defp key_to_uart(10), do: <<?\r, ?\n>>
  defp key_to_uart(127), do: <<?\b>>
  defp key_to_uart(key), do: <<key>>

  defp clean_uart_opts(uart_opts) do
    Enum.filter(uart_opts, fn
      {:speed, _} -> true
      _ -> false
    end)
  end
end
