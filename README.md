[![Travis CI Build Status](https://travis-ci.org/coinmetrics-io/haskell-tools.svg?branch=master)](https://travis-ci.org/coinmetrics-io/haskell-tools) [![Docker Repository on Quay](https://quay.io/repository/coinmetrics/haskell-tools/status "Docker Repository on Quay")](https://quay.io/repository/coinmetrics/haskell-tools)

# Haskell-based CoinMetrics.io tools

These tools are used by CoinMetrics.io team for exporting data from blockchains into analytical databases and monitoring full nodes synchronization state.

## Utilities

* [coinmetrics-export](coinmetrics-export/README.md) - utility for exporting data from blockchains in formats suitable for inserting into analytics databases (SQL, Avro).
* [coinmetrics-monitor](coinmetrics-monitor/README.md) - utility for monitoring blockchain nodes and providing Prometheus-compatible metrics.

## Status

The project is being used in production at Coin Metrics, but a lot of things are in flux or fragile. Command line interface is more or less stable but may change. Please use with caution.

Supported blockchains:

* Binance Chain
* [Bitcoin](https://bitcoin.org/)
* [Cardano](https://www.cardanohub.org/)
* [Cosmos](https://cosmos.network/)
* [EOS](https://eos.io/)
* [Ethereum](https://www.ethereum.org/)
* [Grin](https://grin-tech.org/)
* [IOTA](https://iota.org/)
* [Monero](https://getmonero.org/)
* [NEM](https://nem.io/)
* [NEO](https://neo.org/)
* [Ripple](https://ripple.com/)
* [Stellar](https://www.stellar.org/)
* Generic [Tendermint](https://tendermint.com/)
* [Tezos](https://tezos.com/)
* [Tron](https://tron.network/) (WIP)
* [Waves](https://wavesplatform.com/)

## Binaries (experimental)

There're no stable releases yet. All binaries are "bleeding edge" ones built on Travis CI.

One easy way to run the tools is to use docker.

Pull the latest version:
```bash
docker pull quay.io/coinmetrics/haskell-tools
```

Run e.g. `coinmetrics-export` tool:
```bash
docker run -it --rm --net host quay.io/coinmetrics/haskell-tools coinmetrics-export <arguments>
```

Alternatively you can download executables:

* [generic Linux](https://bintray.com/coinmetrics/haskell-tools)

Or packages:

* [.deb packages](https://bintray.com/coinmetrics/haskell-tools-deb)
* [.rpm packages](https://bintray.com/coinmetrics/haskell-tools-rpm)

Or setup package repository to receive updates:

For .deb:
```bash
echo 'deb https://dl.bintray.com/coinmetrics/haskell-tools-deb unstable main' > /etc/apt/sources.list.d/coinmetrics-haskell-tools.list
curl 'https://bintray.com/user/downloadSubjectPublicKey?username=bintray' | apt-key add -
apt update
apt install coinmetrics-export
```

For .rpm:
```bash
(cd /etc/yum.repos.d/ && curl -JOL https://bintray.com/coinmetrics/haskell-tools-rpm/rpm)
yum install coinmetrics-export
```

Packages have the advantage of providing bash completion support out of the box.

## Building from source

Get [stack](https://docs.haskellstack.org/en/stable/install_and_upgrade/).

Run `stack build --install-ghc --copy-bins --local-bin-path <path for executables>`. Executables will be built and placed by specified path.

The code is only tested on Linux (but maybe works on other OSes too).
