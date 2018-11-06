# Elixircom

[![CircleCI](https://circleci.com/gh/mattludwigs/elixircom.svg?style=svg)](https://circleci.com/gh/mattludwigs/elixircom)
[![Hex version](https://img.shields.io/hexpm/v/elixircom.svg)](https://hex.pm/packages/elixircom)

A serial port terminal emulator for IEx.

This is useful if you are using Elixir projects that
involve communicating with serial port devices that need
a terminal like environment. Inspired by `picocom`.

To use it, add this project to your deps:

```elixir
def deps do
  [
    {:elixircom, "~> 0.1.0"}
  ]
end
```

After building and starting a new `IEx` prompt, run:

```elixir
iex> Elixircom.run("/dev/tty.usbmodem14103", speed: 115_200)
```

The name that you use will depend on your computer. This opens a serial port on
OSX. To get a list of serial ports, run `Nerves.UART.enumerate()`. The `speed`
parameter is optional. See
[`Nerves.UART.open/3`](https://hexdocs.pm/nerves_uart/Nerves.UART.html#open/3)
for other options.

Here's an example of how to connect to a Raspberry Pi Zero that's running
Nerves:

```elixir
$ cd elixircom
$ iex -S mix
Erlang/OTP 21 [erts-10.0.8] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Interactive Elixir (1.7.3) - press Ctrl+C to exit (type h() ENTER for help)
iex> Nerves.UART.enumerate()
%{
  "/dev/cu.Bluetooth-Incoming-Port" => %{},
  "/dev/cu.MALS" => %{},
  "/dev/cu.SOC" => %{},
  "/dev/cu.usbmodem14103" => %{
    manufacturer: "Linux 4.14.71 with 20980000.usb",
    product_id: 42154,
    vendor_id: 1317
  }
}
iex> Elixircom.run("/dev/tty.usbmodem14103")

nil
iex(pi@pi.local)107>
nil
iex(pi@pi.local)108> 1 + 1
2
iex(pi@pi.local)109>
```

To exit out of the serial port terminal, press `Ctrl+B`.

```elixir
iex> Elixircom.run("/dev/tty.usbmodem14103")

nil
iex(pi@pi.local)158>
nil
iex(pi@pi.local)159>
nil
iex(pi@pi.local)160> 1 + 1
2
iex(pi@pi.local)161> :ok
iex(2)>
nil
iex(3)>
nil
iex(4)>
```

## Known Issues

Currently if you hit a runtime error when connecting to an `IEx` prompt over
serial, for example a device running nerves, the next line waiting for input
will be red along with the error message. To break the red coloring of the text
just press enter/return.

We are waiting for a resolution on
[ERL-768](https://bugs.erlang.org/browse/ERL-768) to fix this.

