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

if(isset($_SESSION['msg']) && strlen($_SESSION['msg'] > 0)) {
  $user_message = $_SESSION['msg'];
  unset($_SESSION['msg']);
}

?>
<!DOCTYPE html>
<html>
<head>
  <meta name="viewport" content="width=device-width, initial-scale=1, maximum-scale=1, user-scalable=no" />
  <title>Kiwi Memorial NFT Faucet</title>
  <script src="https://www.google.com/recaptcha/api.js" async defer></script>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Dosis&display=swap" rel="stylesheet">
  <link href="css/kiwi.css" rel="stylesheet">
</head>
<body>
  <div class="container">
    <h1 style="color: #333333;">Kiwi, Requiescat in Pace | 1967 - 2023</h1>
    <img class="portrait" src="assets/portrait.png" alt="Portrait">
    <form action="submit.php" method="POST">
    <div class="message-box">
        <p> In memory of David Hamish Speirs, Kiwi to his friends. A true Chia OG. 
            Kiwi inspired and led people and communities everywhere he went.
            His presence will be missed, but his impact lives on. Rest in peace, friend.
            For a commemorative NFT in his honor, please provide an xch address.
        </p>
      <input type="text" id='sendto' name='sendto-address' placeholder="xch address"></input>
      <div id="recaptcha" style="display: none;" class="recaptcha-container">
        <div class="g-recaptcha" data-sitekey="<?php echo SITE_KEY; ?>"></div>
      </div>
      <div id="submit-button-div" class="submit-button">
        <button id="ripkiwi" type="submit" name="submit" value="Submit">RIP Kiwi</button>
        <img id='progress' src='assets/progress.gif'>
      </div>
    </div>
  </form>
  <div class='donate'>
     <p>You can donate a Kiwi, Requiescat in Pace NFT to the faucet by transferring the NFT here:<br>
     <i>xch1snznymfpvxw4ggq493u9svk78dnuaza7sy8y6cfxpczznj326yjq0q4w0s</i></p>
  </div>
  <div class='disclaimer'>
      <p>kiwifaucet.site is a community-based initiative, independently operated, and is not associated with, nor maintained by Chia Network Inc.</p>
  </div>

  <?php include_once 'stats.php';?>

  <script src="js/kiwi.js"></script>
</body>
</html>