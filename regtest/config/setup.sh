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

# setup Alice
echo "======== start send btc to alice ========"

alice=`sudo docker exec -it regtest-alice-lnd lncli --network=regtest newaddress p2tr`
alice=$(echo $alice | awk -F'"' '{print $4}')
echo "alice address => $alice"

sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser -rpcwallet=miningwallet sendtoaddress $alice 200
sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser -rpcwallet=miningwallet -generate 6

echo "======== finish send btc to alice ($alice) ========"
sleep 5

# setup Bob
echo "======== start send btc to bob ========"

bob=`sudo docker exec -it regtest-bob-lnd lncli --network=regtest --rpcserver=localhost:10010 newaddress p2tr`
bob=$(echo $bob | awk -F'"' '{print $4}')
echo "bob address => $bob"

sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser -rpcwallet=miningwallet sendtoaddress $bob 200
sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser -rpcwallet=miningwallet -generate 6

echo "======== finish send btc to bob ($bob) ========"
sleep 5

echo "generate 10 more blocks"
sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcwallet=miningwallet -rpcpassword=polarpass -rpcuser=polaruser -generate 10
echo "======== finish generate init blocks ========"
sleep 5

echo "======== alice mints assets ========="
sudo docker exec -it regtest-alice-tap tapcli --network=regtest assets mint --type normal --name alicecoin --supply 1000000 --new_grouped_asset
sudo docker exec -it regtest-alice-tap tapcli --network=regtest assets mint finalize
echo "======== alice asset mint finalized ========="

echo "======== bob mints assets ========="
sudo docker exec -it regtest-bob-tap tapcli --network=regtest --rpcserver=localhost:10030 assets mint --type normal --name bobcoin --supply 1000000 --new_grouped_asset
sudo docker exec -it regtest-bob-tap tapcli --network=regtest --rpcserver=localhost:10030 assets mint finalize
echo "======== bob asset mint finalized ========="

echo "generate 10 more blocks"
sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcwallet=miningwallet -rpcpassword=polarpass -rpcuser=polaruser -generate 10
echo "======== finish generate init blocks ========"
sleep 3

echo "======== syncing alice to bob universe ========="
sudo docker exec -it regtest-alice-tap tapcli --network=regtest universe federation add --universe_host=regtest-bob-tap:10030

sudo docker exec -it regtest-alice-tap tapcli --network=regtest universe federation config global --proof_type issuance --allow_insert true
sudo docker exec -it regtest-alice-tap tapcli --network=regtest universe federation config global --proof_type transfer --allow_insert true
sudo docker exec -it regtest-alice-tap tapcli --network=regtest universe sync --universe_host=regtest-bob-tap:10030

echo "======== syncing bob to alice universe ========="
sudo docker exec -it regtest-bob-tap tapcli --rpcserver=localhost:10030 --network=regtest universe federation add --universe_host=regtest-alice-tap:10029
sudo docker exec -it regtest-bob-tap tapcli --rpcserver=localhost:10030 --network=regtest universe federation config global --proof_type issuance --allow_insert true
sudo docker exec -it regtest-bob-tap tapcli --rpcserver=localhost:10030 --network=regtest universe federation config global --proof_type transfer --allow_insert true

sudo docker exec -it regtest-bob-tap tapcli --rpcserver=localhost:10030 --network=regtest universe sync --universe_host=regtest-alice-tap:10029


echo "======== lnd tls cert hex ========="
alice_cert=$(sudo docker exec -it regtest-alice-lnd cat /root/.lnd/tls.cert | xxd -p -c 1000 | tr -d '\n')
echo "alice cert => $alice_cert"

echo "======== lnd admin macaroon hex ========="
alice_macaroon=$(sudo docker exec -it regtest-alice-lnd xxd -p -c 1000 /root/.lnd/data/chain/bitcoin/regtest/admin.macaroon | tr -d '\n')
echo "alice macaroon => $alice_macaroon"

echo "======== tapd tls cert hex ========="
tapd_cert=$(sudo docker exec -it regtest-alice-tap cat /root/.tapd/tls.cert | xxd -p -c 1000 | tr -d '\n')
echo "tapd cert => $tapd_cert"

echo "======== tapd admin macaroon hex ========="
tapd_macaroon=$(sudo docker exec -it regtest-alice-tap xxd -p -c 1000 /root/.tapd/data/regtest/admin.macaroon | tr -d '\n')
echo "tapd macaroon => $tapd_macaroon"

# start auto mining
sudo docker exec -d -u bitcoin bitcoind-backend bash -c "/home/bitcoin/mining.sh"
echo "finish start auto mining"
sleep 3