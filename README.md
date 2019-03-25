# Elixircom

[![CircleCI](https://circleci.com/gh/mattludwigs/elixircom.svg?style=svg)](https://circleci.com/gh/mattludwigs/elixircom)
[![Hex version](https://img.shields.io/hexpm/v/elixircom.svg)](https://hex.pm/packages/elixircom)

A serial port terminal emulator for IEx.

This is useful if you are using Elixir projects that involve communicating with
serial port devices that need a terminal like environment. Inspired by
`picocom`.

To use it, add this project to your deps:

```elixir
def deps do
  [
    {:elixircom, "~> 0.2.0"}
  ]
end
```

Once built, you can run it interactively be starting it from the `IEx` prompt.
Here's an example that uses `Elixircom` to interact with a modem:

```elixir
$ cd elixircom
$ iex -S mix
iex> Elixircom.run("/dev/tty.usbmodem14103", speed: 115_200)
AT
OK

^B
iex>
```

The name that you use will depend on your computer. This opens a serial port on
OSX. To get a list of serial ports, run `Circuits.UART.enumerate()`. The `speed`
parameter is optional. See
[`Circuits.UART.open/3`](https://hexdocs.pm/circuits_uart/Circuits.UART.html#open/3)
for other options.

```elixir
$ cd elixircom
$ iex -S mix
Erlang/OTP 21 [erts-10.0.8] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Interactive Elixir (1.7.3) - press Ctrl+C to exit (type h() ENTER for help)
iex> Circuits.UART.enumerate()
%{
  "ttyUSB0" => %{
    description: "FT232R USB UART",
    manufacturer: "FTDI",
    product_id: 24577,
    serial_number: "AH05M2WB",
    vendor_id: 1027
  },
  "ttyUSB1" => %{
    description: "Qualcomm CDMA Technologies MSM",
    manufacturer: "Qualcomm, Incorporated",
    product_id: 37042,
    serial_number: "ed3b781a",
    vendor_id: 1478
  },
iex> Elixircom.run("/dev/ttyUSB1")
AT
OK
```
