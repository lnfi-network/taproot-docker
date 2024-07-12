## Taproot Asset Channels
`cd regtest/litd`
# Setup Docker Containers
`docker-compose up -d`

# Run Setup Script (Auto Mining)
`./setupMac.sh`

# Get the Asset ID for the Demo
`sudo docker exec -it lnfi-litd tapcli --rpcserver=localhost:8443 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon assets list`



# Send some LNFI token to User LITD

(1) Generate an address
Note: this commands is run from a Docker Desktop Terminal

```
tapcli --rpcserver=localhost:8444 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon addrs new --asset_id=31f70c24762f27db979278cf8e7484f87e0b357268f6230fa5c6b3b3cc176acd --amt=15000
```

(2) Send to the Address
Note: this command is run from a MacOS terminal

```
sudo docker exec -it lnfi-litd tapcli --rpcserver=localhost:8443 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon assets send --addr taprt1qqqszqspqqzzqv0hpsj8vte8mwtey7x03e6gf7r7pv6hy68kyv86t34nk0xpw6kdq5ss877pms5e6j5l28nd2h606we66w9svzc56qatzleem6ulxkhunj0xqcss9f8ycwwvcrdehz40c37g69hyw76z0tu5fshfqcqfgwx5e8pzxee6pqssyeduhrlwheu0qa4jz60relhtuls03xt0d8rtku8d0t04r5eag4axpgpl6w5cpshksctndpkkz6tv8ghj7mtpd9kxymmc9e6x2undd9hxzmpwd35kw6r5de5kueeww3hkgcte8g6rgvchz364e
```

(3) Confirm that the assets have been received by the User
```
tapcli --rpcserver=localhost:8444 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon assets list
```

# Connect the LITD Instance as Lightning Network Peers
Get the pubkeys of each instance

`lncli --network=regtest --rpcserver=localhost:10010 getinfo`

Ex:
03864e9cf12c8d0bdaa85784f3ba5c198a0bd99bda74a6400f5a44ada40b788cb4

Then add the peer
`docker exec -it lnfi-litd lncli --rpcserver=localhost:10009 --network=regtest connect 03ae00f5ed6991a0973b32eb3e55295433bfccc8742aba750e23a5ce5e7c41d47e@user-litd:9736`

# Create the LN Wallets on Each Side

# Open a Regular Lightning Network Channel
`docker exec -it lnfi-litd lncli --rpcserver=localhost:10009 --network=regtest openchannel --node_key=03ae00f5ed6991a0973b32eb3e55295433bfccc8742aba750e23a5ce5e7c41d47e --connect=user-litd:9736 --local_amt=5000000 --push_amt=1500000`

Note: You can also just use the `--push_amt` flag and use one command below.

# Check that the Channel Opened on the User Side
```
lncli --network=regtest --rpcserver=localhost:10010 listchannels
```

# Open a Taproot Asset Channel

`sudo docker exec -it lnfi-litd litcli --rpcserver=localhost:8443 --macaroonpath=/root/.lnd/data/chain/bitcoin/regtest/admin.macaroon --network=regtest ln fundchannel --node_key=03ae00f5ed6991a0973b32eb3e55295433bfccc8742aba750e23a5ce5e7c41d47e --asset_amount=150 --asset_id=31f70c24762f27db979278cf8e7484f87e0b357268f6230fa5c6b3b3cc176acd --sat_per_vbyte=3 --push_amt=50`

# Check that the Taproot Asset Channel is open Now
```
lncli --network=regtest --rpcserver=localhost:10010 listchannels
```

# Add Invoice
`sudo docker exec -it lnfi-litd litcli --rpcserver=localhost:8443 --macaroonpath=/root/.lnd/data/chain/bitcoin/regtest/admin.macaroon --network=regtest ln addinvoice --asset_id=31f70c24762f27db979278cf8e7484f87e0b357268f6230fa5c6b3b3cc176acd --asset_amount=10`

Get an Output like this:
```
/ # litcli --network=regtest --rpcserver=localhost:8444 --macaroonpath=/root/.lnd/data/chain/bitcoin/regtest/admin.macaroon ln addinvoice --asset_id=31f70c24762f27db979278cf8e7484f87e0b357268f6230fa5c6b3b3cc176a
cd --asset_amount=10
Asking peer 03d4c62e4ce14ddb9f428196c393ff1a6b4c4472bbf35535feb3cc94c726199bb5 for quote to buy assets to receive for invoice over 10 units; waiting up to 60s
{
    "r_hash":  "108cd768cc937551a3d9121cc300fa1e4894805247378a7274df7512773ceab4",
    "payment_request":  "lnbcrt101pnfpvajpp5zzxdw6xvjd64rg7ezgwvxq86reyffqzjgumc5un5ma63yaeua26qdqqcqzzsxqzpurzjq02vvtjvu9xah86zsxtv8yllrf45c3rjh0e42d07k0xff3exrxdm22gl96j36m6flsqqqqlgqqqqqqgq2qsp5tl32lvlk9twhc3m2fntzl7v4rwzcgejr05d499qmxe8crfeju0ds9qxpqysgqvr3hqfafhlzkzvtmjs7y7zq5hqemqxje0hayzyl3rxay6pa73u0rpsdssr4gspm4chxjnz7qpjnnwgw0zpg8tmmu999dy763u7d0x5cpydf34z",
    "add_index":  "1",
    "payment_addr":  "5fe2afb3f62add7c476a4cd62ff9951b858466437d1b52941b364f81a732e3db"
}
```

However several issues seem to exist still with `addinvoice`

(a) Channel Opener gets either a assets not in channel error

```
[litcli] unable to send asset_id=31f70c24762f27db979278cf8e7484f87e0b357268f6230fa5c6b3b3cc176acd, not in channel
```

The above appears to go away after some blocks.

Or, 

(b) Channel Opener gets a no remote balance available for asset_id error, even though
funds were pushed for both the bitcoin channel and the Taproot Asset Channel.

```
[litcli] no remote asset balance available for receiving asset_id=31f70c24762f27db979278cf8e7484f87e0b357268f6230fa5c6b3b3cc176acd
```

(b) persists even after the Non-Channel Opening party 

Further, the following RFQ related error appears after trying to `addinvoice`

```
2024-07-12 00:39:48 2024-07-12 04:39:48.940 [INF] GRDN: New block at height 316
2024-07-12 00:40:17 2024-07-12 04:40:17.920 [INF] LITD: Handling gRPC request: /lnrpc.Lightning/ListChannels
2024-07-12 00:40:17 2024-07-12 04:40:17.936 [INF] LITD: Handling gRPC request: /lnrpc.Lightning/BakeMacaroon
2024-07-12 00:40:17 2024-07-12 04:40:17.944 [INF] LITD: Handling gRPC request: /rfqrpc.Rfq/AddAssetBuyOrder
2024-07-12 00:40:18 2024-07-12 04:40:18.011 [WRN] RFQS: Unable to unmarshal channel asset data: unexpected end of JSON input
2024-07-12 00:40:18 2024-07-12 04:40:18.018 [INF] LITD: Handling gRPC request: /lnrpc.Lightning/GetChanInfo
2024-07-12 00:40:18 2024-07-12 04:40:18.027 [INF] LITD: Handling gRPC request: /lnrpc.Lightning/AddInvoice
2024-07-12 00:40:19 2024-07-12 04:40:19.029 [INF] CRTR: Pruning channel graph using block 50837839ab85690d35554b8a7eb303aacc787e7f53f1681d015b07a28d6c3f24 (height=317)
2024-07-12 00:40:19 2024-07-12 04:40:19.037 [INF] CRTR: Block 50837839ab85690d35554b8a7eb303aacc787e7f53f1681d015b07a28d6c3f24 (height=317) closed 0 channels
2024-07-12 00:40:19 2024-07-12 04:40:19.055 [INF] NTFN: New block: height=317, sha=50837839ab85690d35554b8a7eb303aacc787e7f53f1681d015b07a28d6c3f24
2024-07-12 00:40:19 2024-07-12 04:40:19.056 [INF] UTXN: Attempting to graduate height=317: num_kids=0, num_babies=0
2024-07-12 00:40:19 2024-07-12 04:40:19.056 [INF] GRDN: New block at height 317
```

# Trying to Use RFQ to Help
It seems we must setup a price oracle to really make things work. However, some configs can be used to override the need for the price oracle for now (see the taproot-docker /regtest/litd/docker-compose.yaml).

As far as using the CLI goes, only `tapcli` has a single command available to help accept an offer:

```
/ # tapcli --network=regtest --rpcserver=localhost:8444 rfq --help
NAME:
   tapcli rfq - Interact with Taproot Asset RFQs.

USAGE:
   tapcli rfq command [command options] [arguments...]

COMMANDS:
   acceptedquotes, q  show all accepted quotes of the node's peers

OPTIONS:
   --help, -h  show help
```