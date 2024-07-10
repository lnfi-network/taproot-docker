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
tapcli --rpcserver=localhost:8444 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon addrs new --asset_id=9a0165b476fbe7357dfd843c51c19d991ea66390d5b3983635fe2c4dd79b812b --amt=15000
```

(2) Send to the Address
Note: this command is run from a MacOS terminal

```
sudo docker exec -it lnfi-litd tapcli --rpcserver=localhost:8443 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon assets send --addr taprt1qqqszqspqqzzpxspvk68d7l8x47lmppu28qemxg75e3ep4dnnqmrtl3vfhtehqftq5ssydyfsmlupx447dk3uq9208h8gxcyq8v4rwxldxgp5sgde7y7r57fqcss9xahkgcrl24aew3gkq6lx60y44ec0wsjk29zcugxlkfc3ux9u3ejpqssynvy0xgtx0uh34ztm2x4ymtsxdssxlq6z8w2cq99ehcrrkxv94t7pgpl6w5cpshksctndpkkz6tv8ghj7mtpd9kxymmc9e6x2undd9hxzmpwd35kw6r5de5kueeww3hkgcte8g6rgvcdyft9n
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
`docker exec -it lnfi-litd lncli --rpcserver=localhost:10009 --network=regtest connect 03d4d923f1616c7a0bf1b73ba32ae8f4c09a7fa7136d98e71afec5a9bcbae53b10@user-litd:9736`

# Create the LN Wallets on Each Side

# Open a Regular Lightning Network Channel
`docker exec -it lnfi-litd lncli --rpcserver=localhost:10009 --network=regtest openchannel --node_key=03d4d923f1616c7a0bf1b73ba32ae8f4c09a7fa7136d98e71afec5a9bcbae53b10 --connect=user-litd:9736 --local_amt=5000000`

Note: You can also just use the `--push_amt` flag and use one command below.

# Open a Taproot Asset Channel

`sudo docker exec -it lnfi-litd litcli --rpcserver=localhost:8443 --macaroonpath=/root/.lnd/data/chain/bitcoin/regtest/admin.macaroon --network=regtest ln fundchannel --node_key=03d4d923f1616c7a0bf1b73ba32ae8f4c09a7fa7136d98e71afec5a9bcbae53b10 --asset_amount=150 --asset_id=9a0165b476fbe7357dfd843c51c19d991ea66390d5b3983635fe2c4dd79b812b --help`

`sudo docker exec -it lnfi-litd tapcli --rpcserver=localhost:10029 --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon --network=regtest ln fundchannel --node_key=038f7604ff9c094efa005b018a043b74d67122260cef3e86c1d7b6955d7dd85d91 --asset_amount=150 --asset_id=0`

# Close Channel

# Mint Another Group of Existing Asset
