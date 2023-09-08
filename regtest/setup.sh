# Generate init blocks and create wallet
echo "Start create wallet and generate 120 blocks"
docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest createwallet "miningwallet"
docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcwallet=miningwallet -generate 120
echo "======== finish generate init blocks ========"
sleep 5

# setup Alice
echo "======== start send btc to alice ========"

alice=`docker exec -it -u lnd alice-lnd lncli --network=regtest newaddress p2tr`
alice=$(echo $alice | awk -F'"' '{print $4}')
echo "alice address => $alice"

docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcwallet=miningwallet sendtoaddress $alice 100
docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcwallet=miningwallet -generate 6

echo "======== finish send btc to alice ($alice) ========"
sleep 5

# setup Bob
echo "======== start send btc to bob ========"

bob=`docker exec -it -u lnd bob-lnd lncli --network=regtest newaddress p2tr`
bob=$(echo $bob | awk -F'"' '{print $4}')
echo "bob address => $bob"

docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcwallet=miningwallet sendtoaddress $bob 100
docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcwallet=miningwallet -generate 6

echo "======== finish send btc to bob ($bob) ========"
sleep 5

# start auto mining
echo "copy ming.sh to backend and start mining"
# copy mining.sh to backend
cp ./mining.sh ./volumes/bitcoind/backend/regtest/
# start mining
docker exec -d -u bitcoin bitcoind-backend bash -c "/home/bitcoin/.bitcoin/regtest/mining.sh"
echo "finish start auto mining"
sleep 3