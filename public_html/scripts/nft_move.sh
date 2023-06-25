#!/bin/bash

sleep_countdown()
{
        secs=$(($1))
        while [ $secs -gt 0 ]; do
           echo -ne " $secs\033[0K\r"
           sleep 1
           : $((secs--))
        done
}

# lets make sure the script isn't already running
LOCK_FILE="nft_move.lock"
if [ -f "$LOCK_FILE" ]; then
   exit 1
fi
touch "$LOCK_FILE"
echo "Lock file created."

# lets make sure the wallet service is running
wallet_service=`ps aux | grep "chia_wallet" | grep -v grep | wc -l`
if [ "$wallet_service" -eq 0 ]; then
   exit 1
fi
echo "Wallet service is running."

appdir=`pwd`
cd /home/steve/chia-blockchain
. ./activate
cd /var/www/kiwifaucet.site/public_html/files

# move the nft from the given collection into the given did wallet
col=$1
wid=$2

nft_wallet_id="4"
did_id="did:chia:195q60gs9z5rl99tyt5r3plm9neqthzndg8d7rgcnsv22s5qdhxhsk069x2"
fee_xch=0.000000000001

if [ "$col" == "" ] || [ "$wid" == "" ]; then
	echo ""
	echo "Missing parameters."
	echo "USAGE: bash nft_move.sh <collection_id> <wallet_id>"
	echo ""
	exit
else

echo "Arguments received."

	c=`chia rpc wallet nft_count_nfts '{"wallet_id":'$wid'}' | jq -r '.count'`
	nft_ids=`chia rpc wallet nft_get_nfts '{"wallet_id":'$wid', "start_index":0, "num":'$c', "ignore_size_limit": false}' | grep "nft_id" | cut -c 24-85`

	for id in $nft_ids; do

		found=0
		found=`chia wallet nft get_info -ni $id | grep "   https://bafybeif3cugqxtterr373gqupd6odpsxo7c5qpeoaaufhbs6lehtpqyava.ipfs.nftstorage.link/metadata.json" | wc -l`
		if [ "$found" -eq "1" ]; then
			echo "$id" >> moves.csv
		fi
	done
fi
echo "moves.csv updated."

# lets make sure no left over files are around
if [ -f "batch_*" ]; then
	rm -f batch_*
fi

# now lets split the move.csv into batchs of 25
split -l 25 moves.csv batch_

# clear moves.csv file
truncate -s 0 moves.csv

batchs=`ls -1 batch_*`
echo "Batches:"
echo "$batchs"
echo ""

json=""
for batch in $batchs; do
echo "Batch: $batch"
	# build json for RPC command
	json=`jq -n --argjson nft_coin_list "[]" --arg did_id "$did_id" --arg fee "FEE_VALUE" '$ARGS.named' `

	file_contents=`cat $batch`
	for nft_id in $file_contents; do
		json=`echo $json | jq '.nft_coin_list += [{"nft_coin_id":"'"$nft_id"'","wallet_id":'"$nft_wallet_id"'}]'`
	done

	# call RPC for bulk move on batch
	json=`echo $json | jq -c .`
	json="${json//\"FEE_VALUE\"/$fee_xch}"
	cmd="chia rpc wallet nft_set_did_bulk '$json'"
	eval "$cmd" >/dev/null 2>&1
	sleep 120
done

if [ -f "batch_*" ]; then
	rm -f batch_*
fi

cd $appdir
deactivate
rm "$LOCK_FILE"
