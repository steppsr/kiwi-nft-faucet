#!/bin/bash

# Rename temporarily so more requests dont come into this file while processing.
# Since requests.csv wont be found the new requests will get written into the overflow.csv file instead.
mv /var/www/kiwifaucet.site/public_html/files/requests.csv /var/www/kiwifaucet.site/public_html/files/requests.processing

items=`cat /var/www/kiwifaucet.site/public_html/files/requests.processing`
for item in $items; do
	time_stamp=`echo $item | cut --fields 1 --delimiter=,`
	xch_address=`echo $item | cut --fields 2 --delimiter=,`
	unit=`echo $xch_address | cut -c 1-3`
	valid=`cat ../files/transactions.csv | grep "$xch_address" | wc -l`

	# make sure is valid with 62 character length, first 3 characters equal xch, and is not already in transactions.csv file
	if [ "$unit" = "xch" ] && [ ${#xch_address} -eq 62 ] && [ $valid -eq 0 ]; then
		echo "$time_stamp,$xch_address" >> /var/www/kiwifaucet.site/public_html/files/queue.csv
	fi
done
# empty the requests file
truncate -s 0 /var/www/kiwifaucet.site/public_html/files/requests.processing

# rename back to requests.csv to accept new requests
mv /var/www/kiwifaucet.site/public_html/files/requests.processing /var/www/kiwifaucet.site/public_html/files/requests.csv

# copy any requests written into the overflow file back into requests.csv
cat /var/www/kiwifaucet.site/public_html/files/overflow.csv >> /var/www/kiwifaucet.site/public_html/files/requests.csv

# empty the overflow file
truncate -s 0 /var/www/kiwifaucet.site/public_html/files/overflow.csv
