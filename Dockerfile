FROM msaraiva/elixir-dev
RUN mix hex.info
RUN apk --update add alpine-sdk

RUN mkdir -p /app
WORKDIR /app
COPY . /app

EXPOSE 8080
CMD mix
