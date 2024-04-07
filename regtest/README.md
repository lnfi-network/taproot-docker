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
# For the first time,run setup.sh to generate init block and send btc to alice and bobto alice-lnd and bob-lnd
./setup.sh
# For the others: start auto mining (1 block/60s)
sudo sudo docker exec -d -u bitcoin bitcoind-backend bash -c "/home/bitcoin/mining.sh"
```

## Regtest Installation
``` bash
cd regtest
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