// the button to connect to an ethereum wallet
const buttonEthConnect = document.querySelector('button');

// the read-only eth fields, we process them automatically
const formInputEthMessage = document.querySelector('input#eth_message');
const formInputEthAddress = document.querySelector('input#eth_address');
const formInputEthSignature = document.querySelector('input#eth_signature');
formInputEthMessage.hidden = true;
formInputEthAddress.hidden = true;
formInputEthSignature.hidden = true;

// get the new session form for submission later
const formNewSession = document.querySelector('form');

// only proceed with ethereum context available
if (typeof window.ethereum !== 'undefined') {
  buttonEthConnect.addEventListener('click', async () => {
    buttonEthConnect.disabled = true;

    // request accounts from ethereum provider
    const accounts = await requestAccounts();
    const etherbase = accounts[0];

    // sign a message with current time
    const customTitle = "Hello from Ruby!";
    const requestTime = Math.floor(new Date().getTime() / 1000);
    const message = customTitle + " " + requestTime;
    const signature = await personalSign(etherbase, message);

    // populate and submit form
    formInputEthMessage.value = message;
    formInputEthAddress.value = etherbase;
    formInputEthSignature.value = signature;
    formNewSession.submit();
  });
} else {
  // disable form submission in case there is no ethereum wallet available
  buttonEthConnect.innerHTML = "No Ethereum Context Available";
  buttonEthConnect.disabled = true;
}

// request ethereum wallet access and approved accounts[]
async function requestAccounts() {
  const accounts = await ethereum.request({ method: 'eth_requestAccounts' });
  return accounts;
}

// request ethereum signature for message from account
async function personalSign(account, message) {
  const signature = await ethereum.request({ method: 'personal_sign', params: [ message, account ] });
  return signature;
}

// get nonce from /api/v1/users/ by account
async function getUuidByAccount(account) {
  const response = await fetch("/api/v1/users/" + account);
  const nonceJson = await response.json();
  if (!nonceJson) return null;
  const uuid = nonceJson[0].eth_nonce;
  return uuid;
}
