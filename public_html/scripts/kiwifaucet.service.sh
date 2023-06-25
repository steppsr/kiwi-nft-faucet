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

cd /home/steve/chia-blockchain
. ./activate
cd /var/www/kiwifaucet.site/public_html/files

fingerprint="357745280"
wid="4"
fee_xch="0.000000000001"

# set up endless loop as our engine
while :
do

   item=""
   addr=""
   nft_id=""
   cmd=""

   # queue depth is number of items in queue.csv
   qdepth=`cat queue.csv | wc -l`

   if [ $qdepth -gt 0 ]; then

      # pop one item from top of the queue.csv file to process (FIFO)
      item=`head -n 1 queue.csv`

      tail -n+2 "queue.csv" > queue.tmp && mv queue.tmp queue.csv
      addr=`echo $item | cut --fields 2 --delimiter=,`

      # get one random NFT ID from the DID wallet
      nft_id=`~/chia-blockchain/venv/bin/chia wallet nft list -f $fingerprint -i $wid | grep "NFT identifier" | cut -c 28- | tail -n 1`

      # send NFT to the address from the queue
      cmd="chia wallet nft transfer -f $fingerprint -i $wid -m $fee_xch -ni $nft_id -ta $addr -r"
      eval "$cmd"

      # write the transaction to the transactions.csv file
      echo "$item" >> transactions.csv
   else
      echo "0 queue depth"
      rdepth=`cat requests.csv | wc -l`
      if [ $rdepth -gt 0 ]; then
         /var/www/kiwifaucet.site/public_html/scripts/get_requests.sh
      fi
   fi
   sleep_countdown 10
done
deactivate
