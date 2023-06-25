#!/bin/bash

clean_up()
{
   LOCK_FILE=$1
   truncate -s 0 .taking_offer
   truncate -s 0 taken.log
   rm $LOCK_FILE
}

appdir=`pwd`

# make sure the script isn't already running
LOCK_FILE="$appdir/take_offers.lock"
if [ -f "$LOCK_FILE" ]; then
   echo "There is already an instance of the take_offers.sh script running."
   clean_up $LOCK_FILE
   exit 1
fi
touch "$LOCK_FILE"

# make sure the wallet service is running
wallet_service=`ps aux | grep "chia_wallet" | grep -v grep | wc -l`
if [ "$wallet_service" -eq 0 ]; then
   echo "The wallet service is not running."
   clean_up $LOCK_FILE
   exit 1
fi

# make sure temp file is clear - .taking_offer
truncate -s 0 .taking_offer

# make sure the log file is clear - taken.log
truncate -s 0 taken.log

cd /home/steve/chia-blockchain
. ./activate
cd $appdir

for f in ./*.offer; do

   echo "$f ..."
   echo y | chia wallet take_offer -f 357745280 -m 0.000000000001 $f >> $appdir/taken.log

   # check result for offer id
   log=`cat $appdir/taken.log`

   invalid=0
   invalid=`echo $log | grep "This offer is no longer valid" | wc -l`
   if [ "$invalid" -eq "0" ]; then

      offer_id=`echo $log | tr 'ID' '\n' | grep "Use chia wallet get_offers" | cut --fields 2 --delimiter=\ `

      # build status command
      cmd="chia wallet get_offers --id $offer_id -f 357745280"
      echo "$cmd"

      # loop until status is confirmed
      confirmed=0
      until [ $confirmed -ge 1 ];
      do
         printf "."
         status=`eval $cmd`
         confirmed=`echo $status | grep "Status: CONFIRMED" | wc -l`
      done
      echo ""
      echo "$f confirmed"
   fi

   # move offer to taken folder
   mkdir -p $appdir/taken
   mv "$f" $appdir/taken

   # clear .taking_offer & taken.log
   truncate -s 0 $appdir/.taking_offer
   truncate -s 0 $appdir/taken.log

   echo ""

done
clean_up $LOCK_FILE
