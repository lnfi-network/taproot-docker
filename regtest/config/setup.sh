# Generate init blocks and create wallet
echo "Start create wallet and generate 120 blocks"
sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser createwallet "miningwallet"
sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcwallet=miningwallet -rpcpassword=polarpass -rpcuser=polaruser -generate 120
echo "======== finish generate init blocks ========"
sleep 5

# setup Alice
echo "======== start send btc to alice ========"

alice=`sudo docker exec -it regtest-alice-lnd lncli --network=regtest newaddress p2tr`
alice=$(echo $alice | awk -F'"' '{print $4}')
echo "alice address => $alice"

sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser -rpcwallet=miningwallet sendtoaddress $alice 100
sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser -rpcwallet=miningwallet -generate 6

echo "======== finish send btc to alice ($alice) ========"
sleep 5

# setup Bob
# echo "======== start send btc to bob ========"

# bob=`sudo docker exec -it regtest-bob-lnd lncli --network=regtest newaddress p2tr`
# bob=$(echo $bob | awk -F'"' '{print $4}')
# echo "bob address => $bob"

# sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser -rpcwallet=miningwallet sendtoaddress $bob 100
# sudo docker exec -it -u bitcoin bitcoind-backend bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser -rpcwallet=miningwallet -generate 6

# echo "======== finish send btc to bob ($bob) ========"
# sleep 5

# start auto mining
# echo "copy ming.sh to backend and start mining"
# copy mining.sh to backend
# cp ./mining.sh ./volumes/bitcoind/backend/regtest/
# start mining
sudo docker exec -d -u bitcoin bitcoind-backend bash -c "/home/bitcoin/.bitcoin/regtest/mining.sh&"
echo "finish start auto mining"
sleep 3