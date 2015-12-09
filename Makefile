get_deps:
	mix deps.get

run: get_deps
	mix run --no-halt

test: get_deps
	mix test

build:
	mix build
