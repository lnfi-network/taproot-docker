# Script to generate a new block every minute
# Put this script at the root of your unpacked folder
#!/bin/bash

#bitcoind -conf=/home/bitcoin/config/bitcoin.conf\
echo "bitcoin started~~~~~~~~~~"
# /root/mining.sh &

# cd /
# su bitcoin
# whoami
bitcoind -server=1 -regtest=1 \
    -debug=1 -zmqpubrawblock=tcp://0.0.0.0:28334 \
    -zmqpubrawtx=tcp://0.0.0.0:28335 -zmqpubhashblock=tcp://0.0.0.0:28336 \
    -txindex=1 -dnsseed=0 -upnp=0 -rpcbind=0.0.0.0 -rpcallowip=0.0.0.0/0 \
    -rpcpassword=polarpass -rpcuser=polaruser \
    -rpcport=18443 -rest -listen=1 -listenonion=0 -fallbackfee=0.0002 \
    -blockfilterindex=1 -peerblockfilters=1 \
#     && 

# echo "bitcoin started~"

# sleep 30

#       bitcoind -server=1 -regtest=1
#       -rpcauth=polaruser:5e5e98c21f5c814568f8b55d83b23c1c$$066b03f92df30b11de8e4b1b1cd5b1b4281aa25205bd57df9be82caf97a05526
#       -debug=1 -zmqpubrawblock=tcp://0.0.0.0:28334
#       -zmqpubrawtx=tcp://0.0.0.0:28335 -zmqpubhashblock=tcp://0.0.0.0:28336
#       -txindex=1 -dnsseed=0 -upnp=0 -rpcbind=0.0.0.0 -rpcallowip=0.0.0.0/0
#       -rpcport=18443 -rest -listen=1 -listenonion=0 -fallbackfee=0.0002
#       -blockfilterindex=1 -peerblockfilters=1

# echo "Generating 200 blocks"
# bitcoin-cli -regtest -rpcuser=polaruser -rpcpassword=polarpass -rpcwallet=miningwallet -generate 200

# echo "Generating a block every 30 seconds. "
# while :
# do
#         echo "Generate a new block `date '+%d/%m/%Y %H:%M:%S'`"
#         bitcoin-cli -regtest -rpcuser=polaruser -rpcpassword=polarpass -rpcwallet=miningwallet -generate 1
#         sleep 30
# done