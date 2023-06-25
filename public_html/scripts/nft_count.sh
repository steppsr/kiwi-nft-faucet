#!/bin/bash

# parameter is the wallet id to count
# return the count of nfts in the faucet DID wallet

# lets make sure the wallet service is running
wallet_service=`ps aux | grep "chia_wallet" | grep -v grep | wc -l`
if [ "$wallet_service" -eq "0" ]; then
   exit 1
fi

echo `chia wallet nft list -i $1 | grep "NFT identifier" | wc -l`

