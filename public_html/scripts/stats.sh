#!/bin/bash

appdir="/var/www/kiwifaucet.site/public_html/"
cd /home/steve/chia-blockchain
. ./activate
cd $appdir

type=$1

if [ -f $type ]; then
   type="screen"
fi

unassigned=`bash $appdir/scripts/nft_count.sh 2`
did=`bash $appdir/scripts/nft_count.sh 4`
coins=`chia wallet coins list --no-paginate | grep "Coin ID" |  wc -l`
sent=`cat $appdir/files/transactions.csv | wc -l`

if [ "$type" == "screen" ]; then
   echo "Sent: $sent"
   echo "DID Wallet: $did"
   echo "Non-DID Wallet: $unassigned"
   echo "Coin count: $coins"
fi

if [ "$type" == "html" ]; then
   echo "<div id='stats'>" > $appdir/stats.php
   echo "<table>" >> $appdir/stats.php
   echo "<tr><td>Total NFTs Sent:</td><td>$sent</td></tr>" >> $appdir/stats.php
   echo "<tr><td>Current Balance: </td><td>$did</td></tr>" >> $appdir/stats.php
   echo "</table>" >> $appdir/stats.php
   echo "</div>" >> $appdir/stats.php
fi
