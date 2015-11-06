# Pylon

Pylon is an Open Source API Gateway which is written in Elixir.

It uses a redis backend.

## Why Elixir?

In a previous life (job) I worked on an erlang adserving application.
It was basically a giant API Gateway.  We implemented features such as
rate limiting, traffic mirroring, and fetching from multiple sources and
aggregating the result.

Erlang was an amazing language to do these sorts of tasks.  We could
decide what tasks needed to happen in real-time, while others could
happen as background tasks.  Erlang handles this very nicely as well as
handling a MASSIVE amount of concurrency.
