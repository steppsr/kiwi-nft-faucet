// Get references to the input box and the div
const inputBox = document.getElementById('sendto');
const myDiv = document.getElementById('recaptcha');
const myButtonDiv = document.getElementById('submit-button-div');
const myButton = document.getElementById('ripkiwi');
const myProgressBar = document.getElementById('progress');

// Function to handle showing or hiding the div
function handleDivVisibility() {
  // Check if the input box is empty or if the recaptcha div is hidden
  if (inputBox.value === '') {
    // Hide the div
    myDiv.style.display = 'none';
  } else {
    // Show the div
    myDiv.style.display = 'block';
    renderRecaptcha(); // Render the reCAPTCHA widget
    myButtonDiv.style.display = 'block';
  }
}

function handleButtonClick() {
    myButton.style.display = 'none';
    myProgressBar.style.display = 'block';
}

// Function to render the reCAPTCHA widget
function renderRecaptcha() {
  if (typeof grecaptcha === 'undefined') {
    // If the grecaptcha object is not defined, wait and try again
    setTimeout(renderRecaptcha, 100);
    return;
  }

  grecaptcha.ready(function() {
    grecaptcha.render('recaptcha', {
      sitekey: '6LdFGmMmAAAAAKeuI7-sRUcFlEwtI1ygpD3cFj84'
    });
  });
}

// Add the onchange event listener to the input box
inputBox.onchange = handleDivVisibility;
inputBox.onpaste = handleDivVisibility;
inputBox.oninput = handleDivVisibility;
myButton.onclick = handleButtonClick;

// Call the handleDivVisibility function initially to set the initial visibility
handleDivVisibility();
