echo "======== start generate init blocks ========"

bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser loadwallet "miningwallet" || bitcoin-cli -regtest -rpcpassword=polarpass -rpcuser=polaruser createwallet "miningwallet" || echo "dont need to create wallet"
bitcoin-cli -regtest -rpcwallet=miningwallet -rpcpassword=polarpass -rpcuser=polaruser -generate 120

echo "======== finish generate init blocks ========"

echo "Generating a block every 60 seconds. "

while true; do
        echo "Generate a new block `date '+%d/%m/%Y %H:%M:%S'`"
        bitcoin-cli -regtest -rpcwallet=miningwallet -rpcpassword=polarpass -rpcuser=polaruser -generate 1 || echo "error generate block"
        sleep 60
done