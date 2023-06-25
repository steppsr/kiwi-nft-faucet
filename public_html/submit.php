<?php
/*
    ██╗  ██╗██╗██╗    ██╗██╗    ███████╗ █████╗ ██╗   ██╗ ██████╗███████╗████████╗
    ██║ ██╔╝██║██║    ██║██║    ██╔════╝██╔══██╗██║   ██║██╔════╝██╔════╝╚══██╔══╝
    █████╔╝ ██║██║ █╗ ██║██║    █████╗  ███████║██║   ██║██║     █████╗     ██║   
    ██╔═██╗ ██║██║███╗██║██║    ██╔══╝  ██╔══██║██║   ██║██║     ██╔══╝     ██║   
    ██║  ██╗██║╚███╔███╔╝██║    ██║     ██║  ██║╚██████╔╝╚██████╗███████╗   ██║   
    ╚═╝  ╚═╝╚═╝ ╚══╝╚══╝ ╚═╝    ╚═╝     ╚═╝  ╚═╝ ╚═════╝  ╚═════╝╚══════╝   ╚═╝   
    Web front end for the Kiwi NFT Faucet. Allow user to submit there Receive Address for Chia Mainnet. 
    If form was submitted, then get the wallet address and put into the json file.
*/
include "recaptcha.inc";

// Define strings we'll use in the code.
DEFINE("NOT_SUBMITTED_MSG","Enter your Wallet Receive Address above and Submit Request to get your NFT.");
DEFINE("NO_SENDTO_ADDRESS","Missing Wallet Address. You must put in a valid Wallet Receive Address for Chia Mainnet.");
DEFINE("INVALID_WALLET_ADDRESS","This is not a valid Chia Mainnet address.");
DEFINE("INVALID_KIWI_WALLET_ADDRESS","You have submitted the Kiwi Faucet Address. We won't send to ourselves.");
DEFINE("REQUEST_ACCEPTED","Your request was submitted.");
DEFINE("KIWI_FAUCET_WALLET","xch1snznymfpvxw4ggq493u9svk78dnuaza7sy8y6cfxpczznj326yjq0q4w0s");
DEFINE("MAINNET_UOM","xch");
DEFINE("MESSAGE_TIMEOUT","5");  // How long in seconds the message is displayed before refreshing back to the home page.

$timeout = MESSAGE_TIMEOUT;
$user_message = NOT_SUBMITTED_MSG;
$passed = false;
$id = "";
$sendto = "";
$timestamp = "";

// Validate the reCAPTCHA
if(array_key_exists('submit',$_POST)) {
    $response_key = $_POST['g-recaptcha-response'];
    $response = file_get_contents(RECAPTCHA_URL.'?secret='.SECRET_KEY.'&response='.$response_key.'&remoteip='.$_SERVER['REMOTE_ADDR']);
    $response = json_decode($response);
    if($response->success == 1) {
        $passed = true;
    } else {
        $user_message = "reCAPTCHA failed.";
    }
}

if(isset($_POST['submit']) && $_POST['submit'] === 'Submit' && $_POST['sendto-address'] != "" && $passed) {	
    if(isset($_POST['sendto-address']) && strlen($_POST['sendto-address'] > 0)) {
        $timestamp = date(DATE_W3C);
        $sendto = $_POST['sendto-address'];

        if(strtolower(substr($sendto,0,3)) != MAINNET_UOM || strlen($sendto) != 62 || strtolower($sendto) == KIWI_FAUCET_WALLET) {
            if(strtolower($sendto) == KIWI_FAUCET_WALLET) {
                $user_message = INVALID_KIWI_WALLET_ADDRESS;
            } else {
                $user_message = INVALID_WALLET_ADDRESS;
            }
        } else {
            $filename = (file_exists("/var/www/kiwifaucet.site/public_html/files/requests.csv")) ? "requests.csv" : "overflow.csv";
            file_put_contents("/var/www/kiwifaucet.site/public_html/files/$filename", "$timestamp,$sendto\n", FILE_APPEND);
            $user_message = REQUEST_ACCEPTED;
        }
        file_put_contents("/var/www/kiwifaucet.site/public_html/files/debug.csv", "$timestamp,$sendto\n", FILE_APPEND);
    } else {
        $user_message = NO_SENDTO_ADDRESS;
    }
} 
?>
<!DOCTYPE html>
<html>
<head>
  <meta http-equiv="refresh" content="<?=$timeout?>;url=index.php" />
  <title>Kiwi Memorial NFT Faucet</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Dosis&display=swap" rel="stylesheet">
  <link href="css/kiwi.css" rel="stylesheet">
</head>
<body>
  <div class="container">
    <h1 style="color: #333333;">Kiwi, Requiescat in Pace | 1967 - 2023</h1>
    <img class="portrait" src="assets/portrait.png" alt="Portrait">
    <h3><?=$user_message?></h3>
    <div class='disclaimer'>
      <p>kiwifaucet.site is a community-based initiative, independently operated, and is not associated with, nor maintained by Chia Network Inc.</p>
    </div>
  </div>
</body>
</html>