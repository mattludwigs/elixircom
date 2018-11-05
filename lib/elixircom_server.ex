defmodule Elixircom.Server do
  use GenServer

  alias Nerves.UART

  defmodule State do
    defstruct group_leader: nil, uart: nil, serial_port_name: nil
  end

  def start(opts) do
    GenServer.start(__MODULE__, opts)
  end

  def handle_input(server, char) do
    GenServer.cast(server, {:input, char})
  end

  def stop(server) do
    GenServer.stop(server)
  end

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

  def handle_cast({:input, char}, %State{uart: uart} = state) do
    UART.write(uart, key_to_uart(char))
    {:noreply, state}
  end

  def handle_info({:nerves_uart, _name, data}, %State{group_leader: gl} = state) do
    data = uart_to_printable(data)
    IO.write(gl, data)
    {:noreply, state}
  end

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
