FROM msaraiva/elixir-dev
RUN mix hex.info
RUN apk --update add alpine-sdk postgresql-client

RUN mkdir -p /app
WORKDIR /app
COPY . /app

RUN mix archive.install --force https://github.com/phoenixframework/archives/raw/master/phoenix_new.ez

EXPOSE 8080
CMD mix
