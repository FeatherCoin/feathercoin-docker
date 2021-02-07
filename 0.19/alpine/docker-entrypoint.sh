#!/bin/sh
set -e

if [ $(echo "$1" | cut -c1) = "-" ]; then
  echo "$0: assuming arguments for feathercoind"

  set -- feathercoind "$@"
fi

if [ $(echo "$1" | cut -c1) = "-" ] || [ "$1" = "feathercoind" ]; then
  mkdir -p "$feathercoin_DATA"
  chmod 700 "$feathercoin_DATA"
  chown -R feathercoin "$feathercoin_DATA"

  echo "$0: setting data directory to $feathercoin_DATA"

  set -- "$@" -datadir="$feathercoin_DATA"
fi

if [ "$1" = "feathercoind" ] || [ "$1" = "feathercoin-cli" ] || [ "$1" = "feathercoin-tx" ] || [ "$1" = "feathercoin-wallet" ]; then
  echo
  exec su-exec feathercoin "$@"
fi

echo
exec "$@"