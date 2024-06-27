# Generate init blocks and create wallet
echo "========= Create or Read Wallet and Mine 120 Blocks =========="
# note probably any easier way to check if wallet exists
existing_wallet=$(sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser -rpcwallet=miningwallet getwalletinfo | jq -r '.walletname')

if [[ "$existing_wallet" == "miningwallet" ]]; then
  echo "mining wallet found"
else
  echo "mining wallet not found, creating new wallet"
  sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser createwallet "miningwallet" false false "" false true true
fi

sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcwallet=miningwallet -rpcpassword=polarpass -rpcuser=polaruser -generate 120
echo "======== finish generate blocks ========"
sleep 5

# setup service
