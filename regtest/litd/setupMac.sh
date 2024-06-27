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
lnfi=`sudo docker exec -it lnfi-litd lncli --network=regtest newaddress p2tr`
lnfi=$(echo $lnfi | awk -F'"' '{print $4}')
echo "lnfi address => $lnfi"

sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser -rpcwallet=miningwallet sendtoaddress $lnfi 200
sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser -rpcwallet=miningwallet -generate 6

# setup user
user=`sudo docker exec -it user-litd lncli --network=regtest --rpcserver=localhost:10010 newaddress p2tr`
user=$(echo $user | awk -F'"' '{print $4}')
echo "user address => $user"

sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser -rpcwallet=miningwallet sendtoaddress $user 200
sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser -rpcwallet=miningwallet -generate 6

sleep 5

echo "generate 10 more blocks"
sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcwallet=miningwallet -rpcpassword=polarpass -rpcuser=polaruser -generate 10
echo "======== finish generate init blocks ========"
sleep 5

if [[ "$existing_wallet" == "miningwallet" ]]; then
  echo "======= lookup group key for lnfi ========"
  group_key_lnfi=$(docker exec -it lnfi-litd tapcli -n regtest assets groups | jq '.groups | map_values(select(.assets[] | .tag == "lnfi")) | keys[0]')
  echo $group_key_lnfi
#   echo "======= lookup group key for usercoin ========"
#   group_key_user=$(docker exec -it user-litd tapcli -n regtest --rpcserver=localhost:10030 assets groups | jq '.groups | map_values(select(.assets[] | .tag == "usercoin")) | keys[0]')
#   echo $group_key_user
else
  echo "mining wallet not found, creating new wallet"
  echo "======== lnfi mints assets ========="
  sudo docker exec -it lnfi-litd tapcli --network=regtest assets mint --type normal --name lnfi --supply 1000000 --new_grouped_asset
  sudo docker exec -it lnfi-litd tapcli --network=regtest assets mint finalize
  echo "======== lnfi asset mint finalized ========="
  echo "generate 10 more blocks"
  sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcwallet=miningwallet -rpcpassword=polarpass -rpcuser=polaruser -generate 10
  echo "======== finish generate init blocks ========"
  sleep 3

  echo "======== syncing user to lnfi universe ========="
  sudo docker exec -it user-litd tapcli --rpcserver=localhost:10030 --network=regtest --tapddir=/root/.litd/tapd universe federation add --universe_host=lnfi-litd:10029
  sudo docker exec -it user-litd tapcli --rpcserver=localhost:10030 --network=regtest --tapddir=/root/.litd/tapd universe federation config global --proof_type issuance --allow_insert true
  sudo docker exec -it user-litd tapcli --rpcserver=localhost:10030 --network=regtest --tapddir=/root/.litd/tapd universe federation config global --proof_type transfer --allow_insert true

  sudo docker exec -it user-litd tapcli --rpcserver=localhost:10030 --network=regtest --tapddir=/root/.litd/tapd universe sync --universe_host=lnfi-litd:10029
  
#   echo "======== sending lnfi to user ========="
#   sudo docker exec -it user-litd tapcli --rpcserver=localhost:10030 --network=regtest --tapddir=/root/.litd/tapd addrs new --asset_id
fi


echo "======== lnd tls cert hex ========="
alice_cert=$(sudo docker exec -it lnfi-litd cat /root/.litd/lnd/tls.cert | xxd -p -c 1000 | tr -d '\n')
echo "alice cert => $alice_cert"

echo "======== lnd admin macaroon hex ========="
alice_macaroon=$(sudo docker exec -it lnfi-litd xxd -p -c 1000 /root/.litd/lnd/data/chain/bitcoin/regtest/admin.macaroon | tr -d '\n')
echo "alice macaroon => $alice_macaroon"

# echo "======== tapd tls cert hex ========="
# tapd_cert=$(sudo docker exec -it lnfi-litd cat /root/.litd/tapd/tls.cert | xxd -p -c 1000 | tr -d '\n')
# echo "tapd cert => $tapd_cert"

# echo "======== tapd admin macaroon hex ========="
# tapd_macaroon=$(sudo docker exec -it lnfi-litd xxd -p -c 1000 /root/.litd/tapd/data/regtest/admin.macaroon | tr -d '\n')
# echo "tapd macaroon => $tapd_macaroon"

# start auto mining
sudo docker exec -d -u bitcoin bitcoind-backend bash -c "/home/bitcoin/mining.sh"
echo "finish start auto mining"
sleep 3