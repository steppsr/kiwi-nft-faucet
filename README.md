# kiwi-nft-faucet
A memorial, commemorative NFT faucet for Kiwi, aka David Hamish Speirs, a true Chia OG.

---

## Front End

___PHP___

| File | Description |
| --- | --- |
| index.php | This is the main home page for the site. <br>_67 lines total, 15 lines are comments/whitespace._|
| submit.php |  This is the page to process each submission and provide feedback to the user before redirecting back to the home page. <br>_85 lines total, 17 lines are comments/whitespace._|
|stats.php | This is a dynamic HTML block that gets included in the `index.php` page and is derived from the Back End. <br>_0 lines._|

___Javascript___
| File | Description |
| --- | --- |
| kiwi.js | 49 lines total, 15 lines are comments/whitespace. This handles setting the visibility of elements on the page, and submitting the Google reCAPTCHA. |

___CSS___
| File | Description |
| --- | --- |
| kiwi.css | 107 lines total, 14 lines are whitespace. Format, Layout, and Style. |

__Approximately, 154 lines of actual code, 93 lines of CSS.__

---

## Back End

___Crontab Jobs___
| File | Description |
| --- | --- |
| nft_move.sh | Will move any Kiwi NFTs in the Unassigned wallet_id to the DID wallet_id. Will only move NFTs in the Kiwi collection. <br>_116 lines, 38 lines are comments/whitespace._|
| stats.sh | Will calculate the stats and write to a PHP file that is included in the `index.php` page. <br>_33 lines, 5 lines are whitespace._|

___Systemd Services___
| File | Description |
| --- | --- |
| kiwifaucet.service.sh | <br>_56 lines, 18 are comments/whitespace._ |
| get_requests.sh | Gets the requests from the website and puts them into the `queue.csv` file. <br>_29 lines, 13 are comments/whitespace._ |

___Maintenace Scripts___
| File | Description |
| --- | --- |
| nft_count.sh | <br>_13 lines, 6 lines are comments/whitespace._|
| take_offers.sh | <br>_81 lines, 27 are comments/whitespace._|

__Approximately, 221 lines of actual code.__

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

---

___kiwifaucet.site is a community-based initiative, independently operated, and is not associated with, nor maintained by Chia Network Inc.___
