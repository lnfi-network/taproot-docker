# Build a testnet or regtest tapd server.
Released under the terms of the [MIT LICENSE].

Minimal docker setup to run a regtest node with lnd and taro.

## Architecture
1 bitcoind + 2 lnd daemon + 2 tap daemon
    bitcoin---
        ---->Alice-Lnd ---> Alice-Tap
        ---->Bob-Lnd ---> Bob-Tap
## Regtest Installation
``` bash
cd regtest
# run docker-compose
sudo docker-compose up -d
# set auto mining(30s/block), transfer gas to alice-lnd and bob-lnd
./config/setup.sh
```

## Regtest Installation
``` bash
cd testnet
# run docker-compose
sudo docker-compose up -d
# TIP : need send test btc to alice-lnd and bob-lnd as gas fee
```

## Connection
Alice-Tap : 
    REST API PORT:8289
    RPC API PORT:12029
Bob-Tap : 
    REST API PORT:8290
    RPC API PORT:12030

## Get testnet btc faucet
https://testnet-faucet.com/btc-testnet/

## Thanks
https://hub.docker.com/r/polarlightning

https://github.com/davisv7/sashimi