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
tapcli --rpcserver=localhost:8444 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon addrs new --asset_id=6637690c5200b73f75dda
b5efa5b0a64c3e426e4cc7a669da46e6ede447e233d --amt=15000
```

(2) Send to the Address
Note: this command is run from a MacOS terminal

```
sudo docker exec -it lnfi-litd tapcli --rpcserver=localhost:8443 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon assets send --addr taprt1qqqszqspqqzzqe3hdyx9yq9h8a6am267lfds5exrusnwfnr6v6w6gmnwmez8ugeaq5ss9jqpjfahywg528mz5ramamaw8as32kxvsycke4624spxtwjngqm4qcss9thglzl5qmuzultdvhw70gh0c23q8cac64nk2pdqd0vz43f73lvrpqssye9028v6ht9du8x3l7r2v7np7r2vg43npa2w4mm5ltnrswxx7v8xpgpl6w5cpshksctndpkkz6tv8ghj7mtpd9kxymmc9e6x2undd9hxzmpwd35kw6r5de5kueeww3hkgcte8g6rgvc9u30nw
```

(3) Confirm that the assets have been received by the User
```
tapcli --rpcserver=localhost:8444 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon assets list
```

# Connect the LITD Instance as Lightning Network Peers
Get the pubkeys of each instance

`lncli --network=regtest --rpcserver=localhost:10010 getinfo`

Ex:
02ab65c8c7ab5a8f1248b4829809f392f537ab3f316844078949564a2f4d67208e

Then add the peer (setupMac.sh will take care of this now)
`docker exec -it lnfi-litd lncli --rpcserver=localhost:10009 --network=regtest connect 02ab65c8c7ab5a8f1248b4829809f392f537ab3f316844078949564a2f4d67208e@user-litd:9736`

# Create the LN Wallets on Each Side

# Open a Regular Lightning Network Channel
`docker exec -it litd lncli --rpcserver=localhost:10009 --network=regtest openchannel --node_key=02ab65c8c7ab5a8f1248b4829809f392f537ab3f316844078949564a2f4d67208e --connect=user-litd:9736 --local_amt=5000000`

Note: You can also just use the `--push_amt` flag and use one command below.

# Open a Taproot Asset Channel

`sudo docker exec -it lnfi-litd litcli --rpcserver=localhost:8443 --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon --network=regtest ln fundchannel --node_key=02ab65c8c7ab5a8f1248b4829809f392f537ab3f316844078949564a2f4d67208e --asset_amount=150 --asset_id=6637690c5200b73f75ddab5efa5b0a64c3e426e4cc7a669da46e6ede447e233d`

sudo docker exec -it lnfi-litd litcli --rpcserver=localhost:8443 --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon --basedir=/root/.lit/tapd --network=regtest ln fundchannel --node_key=02ab65c8c7ab5a8f1248b4829809f392f537ab3f316844078949564a2f4d67208e --asset_amount=150 --asset_id=6637690c5200b73f75ddab5efa5b0a64c3e426e4cc7a669da46e6ede447e233d