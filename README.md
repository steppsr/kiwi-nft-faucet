# kiwi-nft-faucet
A memorial, commemorative NFT faucet for Kiwi, aka David Hamish Speirs, a true Chia OG.

---

## Overview

![Kiwi Faucet Design](public_html/assets/KiwiFaucetWorkflow.png)

## Front End

___PHP___

| File | Description |
| --- | --- |
| index.php | This is the main home page for the site. |
| submit.php |  This is the page to process each submission and provide feedback to the user before redirecting back to the home page. |
|stats.php | This is a dynamic HTML block that gets included in the `index.php` page and is derived from the Back End. |

___Javascript___
| File | Description |
| --- | --- |
| kiwi.js | This handles setting the visibility of elements on the page, and submitting the Google reCAPTCHA. |

___CSS___
| File | Description |
| --- | --- |
| kiwi.css | Format, Layout, and Style. |

---

## Back End

The code for the Back End can be found in the scripts folder.

___Crontab Jobs___
| File | Description |
| --- | --- |
| nft_move.sh | Will move any Kiwi NFTs in the Unassigned wallet_id to the DID wallet_id. Will only move NFTs in the Kiwi collection. |
| stats.sh | Will calculate the stats and write to a PHP file that is included in the `index.php` page. |

___Systemd Services___
| File | Description |
| --- | --- |
| kiwifaucet.service.sh | This is the service engine script that continuously loops to check for new requests and send NFTs. |
| get_requests.sh | Gets the requests from the website and puts them into the `queue.csv` file. |

___Maintenace Scripts___
| File | Description |
| --- | --- |
| nft_count.sh | Will output the number of NFTs in a given wallet. |
| take_offers.sh | Bot to take offers if you have multiple offer files. |

___CSV Files___
| File | Description |
| --- | --- |
| requests.csv | Requests w/ basic validation |
| overflow.csv | Used if `requests.csv` doesn't exist |
| debug.csv | log all entries for debugging if needed |
| debug.0.csv | template for debug archiving |
| moves.csv | Used when bulk moving NFTs from Unassigned to DID |
| queue.csv | List of XCH addresses that need an NFT sent to them |
| transactions.csv | Completed transactions once processed from `queue.csv` |

CSV File Structure

	TIME_STAMP,SEND_TO_ADDRESS

Example:

	2023-06-20T01:02:00+00:00,xch1h8px4kmx9mrwsdak094dfs05rwydjrs42m3a8llafyyv278qymxsyzams8

---

## Faucet Service

Faucet Service Pseudocode - this is an intentional endless loop

	WHILE true
		IF queue > 0 THEN
			pop one address from top of queue
			get one nft_id from DID
			send nft to address
			log transaction
		ELSE
			get all submissions
			FOR EACH item IN submissions
				add item to queue
			LOOP
			empty submissions file
		ENDIF
	LOOP

## Setting up Service

#### Configuration

You will need __systemd__ which is normally already installed, but you can install if needed:
```
sudo apt-get install -y systemd
```
To check what version of __systemd__ you have simple run the command:
`systemd --version`

The command to create the service:
`sudo nano /etc/systemd/system/faucet.service`

Adjust for your configuration:
```
[Unit]
Description=Faucet Service
After=multi-user.target

[Service]
Type=simple
Restart=always
User=YOUR_USER
Group=YOUR_GROUP
ExecStart=PATH_TO_SCRIPT

[Install]
WantedBy=multi-user.target
```
Note: This script is Bash, but you run any program/script, including Python.

## Controlling the Service

| Action | Command |
| --- | --- |
| __Reloading Service__ | `sudo systemctl daemon-reload` |
| __Enabling Service__ | `sudo systemctl enable faucet.service` |
| __Stopping Service__ | `sudo systemctl stop faucet.service` |
| __Starting Service__ | `sudo systemctl start faucet.service` |
| __Restarting Service__ | `sudo systemctl restart faucet.service` |
| __Check Status__ | `sudo systemctl status faucet.service` |

## Setting up Cronjobs

We have two script that we run every 5 minutes from `crontab`. 
1. move_nft.sh - which will move any Kiwi NFTs in the Unassigned wallet, into the Kiwi DID wallet.
2. stats.sh - which will calculate how many total NFTs have been sent out, and the current number of NFTs in our Kiwi DID wallet for use in the webpage.

To enter the cronjobs run the following command:
`crontab -e`

Then add the following:
```
0,5,10,15,20,25,30,35,40,45,50,55 * * * * bash /var/www/kiwifaucet.site/public_html/scripts/nft_move.sh col14rl3mpxfxr6acdnzlu466shl9s8ljr9cm9ujar80j5rld2y8lf5qx36yqf 2
0,5,10,15,20,25,30,35,40,45,50,55 * * * * bash /var/www/kiwifaucet.site/public_html/scripts/stats.sh html
```

## Current Known Issues
* The nft_move.sh script has an issue when ran from `crontab`. For now, I have been running it manually when I notice there are Kiwi NFTs in the Unassigned wallet. I check for these by manually running the following command: `bash stats.sh` from within the scripts folder.
* You need to make sure you have enough coins on hand. The `bash stats.sh` command in the scripts folder will include the number of coins in the stats results, but if it's low, you will need to split some coins. I use the CLI command `chia wallet coins split` to do the split.

---

___kiwifaucet.site is a community-based initiative, independently operated, and is not associated with, nor maintained by Chia Network Inc.___
