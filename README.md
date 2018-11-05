# Elixircom

A serial port terminal emulator for iex.

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

After rebuilding and starting a new `IEx` prompt, run:

```
iex(1)> Elixircom.run("/dev/tty.usbmodem14103")
```

Note that the serial port name will be different on different
platforms.

This will connect your current `IEx` session with the serial port.

This example connects to a raspberry pi zero running nerves:

```
Erlang/OTP 21 [erts-10.0.8] [source] [64-bit] [smp:8:8] [ds:8:8:10] [async-threads:1] [hipe]

Interactive Elixir (1.7.3) - press Ctrl+C to exit (type h() ENTER for help)
iex(1)> Elixircom.run "/dev/tty.usbmodem14103"

nil
iex(pi@pi.local)107>
nil
iex(pi@pi.local)108> 1 + 1
2
iex(pi@pi.local)109>
```

