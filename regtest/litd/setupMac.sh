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
#   echo "======= lookup group key for lnfi token ========"
#   group_key_user=$(docker exec -it user-litd tapcli -n regtest --rpcserver=localhost:8444 assets groups | jq '.groups | map_values(select(.assets[] | .tag == "usercoin")) | keys[0]')
#   echo $group_key_user
else
  echo "mining wallet not found, creating new wallet"
  echo "======== lnfi mints assets ========="
  sudo docker exec -it lnfi-litd tapcli --rpcserver=localhost:8443 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon assets mint --type normal --name lnfi --supply 1000000 --new_grouped_asset
  sudo docker exec -it lnfi-litd tapcli --rpcserver=localhost:8443 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon assets mint finalize
  echo "======== lnfi asset mint finalized ========="
  echo "generate 10 more blocks"
  sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcwallet=miningwallet -rpcpassword=polarpass -rpcuser=polaruser -generate 10
  echo "======== finish generate init blocks ========"
  sleep 3

  echo "======== syncing user to lnfi universe ========="
  sudo docker exec -it user-litd tapcli --rpcserver=localhost:8444 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon universe federation add --universe_host=lnfi-litd:8443
  sudo docker exec -it user-litd tapcli --rpcserver=localhost:8444 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon universe federation config global --proof_type issuance --allow_insert true
  sudo docker exec -it user-litd tapcli --rpcserver=localhost:8444 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon universe federation config global --proof_type transfer --allow_insert true

  sudo docker exec -it user-litd tapcli --rpcserver=localhost:8444 --network=regtest --tlscertpath=/root/.lit/tls.cert --macaroonpath=/root/.lit/tapd/data/regtest/admin.macaroon universe sync --universe_host=lnfi-litd:8443
  
  # echo "======== add user node as peer of service ========"
  # sudo docker exec -it lnfi-litd lncli --rpcserver=localhost:10009 --network=regtest connect 02ab65c8c7ab5a8f1248b4829809f392f537ab3f316844078949564a2f4d67208e@user-litd:9736

#   echo "======== sending lnfi to user ========="
#   sudo docker exec -it user-litd tapcli --rpcserver=localhost:8444 --network=regtest --tapddir=/root/.litd/tapd addrs new --asset_id
fi


echo "======== service lnd tls cert hex ========="
alice_cert=$(sudo docker exec -it lnfi-litd cat /root/.lnd/tls.cert | xxd -p -c 1000 | tr -d '\n')
echo "lnfi cert => $alice_cert"

echo "======== service lnd admin macaroon hex ========="
alice_macaroon=$(sudo docker exec -it lnfi-litd xxd -p -c 1000 /root/.lnd/data/chain/bitcoin/regtest/admin.macaroon | tr -d '\n')
echo "lnfi macaroon => $alice_macaroon"

echo "======== service tapd tls cert hex ========="
tapd_cert=$(sudo docker exec -it lnfi-litd cat /root/.lit/tls.cert | xxd -p -c 1000 | tr -d '\n')
echo "tapd cert => $tapd_cert"

echo "======== service tapd admin macaroon hex ========="
tapd_macaroon=$(sudo docker exec -it lnfi-litd xxd -p -c 1000 /root/.lit/tapd/data/regtest/admin.macaroon | tr -d '\n')
echo "tapd macaroon => $tapd_macaroon"

echo "======== user lnd tls cert hex ========="
alice_cert=$(sudo docker exec -it user-litd cat /root/.lnd/tls.cert | xxd -p -c 1000 | tr -d '\n')
echo "user cert => $alice_cert"

echo "======== user lnd admin macaroon hex ========="
alice_macaroon=$(sudo docker exec -it user-litd xxd -p -c 1000 /root/.lnd/data/chain/bitcoin/regtest/admin.macaroon | tr -d '\n')
echo "user macaroon => $alice_macaroon"

echo "======== user tapd tls cert hex ========="
tapd_cert=$(sudo docker exec -it user-litd cat /root/.lit/tls.cert | xxd -p -c 1000 | tr -d '\n')

echo "======== user tapd admin macaroon hex ========="
tapd_macaroon=$(sudo docker exec -it user-litd xxd -p -c 1000 /root/.lit/tapd/data/regtest/admin.macaroon | tr -d '\n')

# start auto mining
sudo docker exec -d -u bitcoin bitcoind-backend bash -c "/home/bitcoin/mining.sh"
echo "finish start auto mining"
sleep 3