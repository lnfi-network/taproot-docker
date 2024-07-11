## Taproot Asset Channels
`cd regtest/litd`
# Setup Docker Containers
`docker-compose up -d`

# Run Setup Script (Auto Mining)
`./setupMac.sh`

# Get the Asset ID for the Demo
`sudo docker exec -it lnfi-litd tapcli --rpcserver=localhost:8443 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon assets list`

0c60189af34d69ac0437811ecf6f5b86aef8b20285b641b0908419132b68a477

# Send some LNFI token to User LITD

(1) Generate an address
Note: this commands is run from a Docker Desktop Terminal

```
tapcli --rpcserver=localhost:8444 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon addrs new --asset_id=0c60189af34d69ac0437811ecf6f5b86aef8b20285b641b0908419132b68a477 --amt=15000
```

(2) Send to the Address
Note: this command is run from a MacOS terminal

```
sudo docker exec -it lnfi-litd tapcli --rpcserver=localhost:8443 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon assets send --addr taprt1qqqszqspqqzzqrrqrzd0xntf4szr0qg7eah4hp4wlzeq9pdkgxcfppqezv4k3frhq5ss8prqv2fmgtl33y24pkrprm0gp8ht4dcvns79am30mdtwp8pckyxuqcss93rvdz6yq35ddzfvxs83snyts6ae09szdzpec67fr2decm88penypqssyy6aucj4907ejn855x0tcx3376nsevahkzjugx03xv77akykxkzxpgpl6w5cpshksctndpkkz6tv8ghj7mtpd9kxymmc9e6x2undd9hxzmpwd35kw6r5de5kueeww3hkgcte8g6rgvc9vghjz
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
`docker exec -it lnfi-litd lncli --rpcserver=localhost:10009 --network=regtest connect 03864e9cf12c8d0bdaa85784f3ba5c198a0bd99bda74a6400f5a44ada40b788cb4@user-litd:9736`

# Create the LN Wallets on Each Side

# Open a Regular Lightning Network Channel
`docker exec -it lnfi-litd lncli --rpcserver=localhost:10009 --network=regtest openchannel --node_key=03864e9cf12c8d0bdaa85784f3ba5c198a0bd99bda74a6400f5a44ada40b788cb4 --connect=user-litd:9736 --local_amt=5000000`

Note: You can also just use the `--push_amt` flag and use one command below.

# Open a Taproot Asset Channel

`sudo docker exec -it lnfi-litd litcli --rpcserver=localhost:8443 --macaroonpath=/root/.lnd/data/chain/bitcoin/regtest/admin.macaroon --network=regtest ln fundchannel --node_key=03864e9cf12c8d0bdaa85784f3ba5c198a0bd99bda74a6400f5a44ada40b788cb4 --asset_amount=150 --asset_id=95c2c09ef35cdc5bcf5d53338b1f97eca997dfa1214db22029da42447126fe15`

`sudo docker exec -it lnfi-litd tapcli --rpcserver=localhost:10029 --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon --network=regtest ln fundchannel --node_key= --asset_amount=150 --asset_id=0`