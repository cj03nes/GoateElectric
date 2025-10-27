pragma solidity v.0.7;

contract BankConnect (bank, wallet, uint256){


keccak(external uint256) => keccak(internal uint256) BankToWallet;
keccak(internal uint256) => keccak(internal uint256) WalletToBank;

keccak(internal uint256) => keccak(internal uint256) WalletToWallet;
address(uint256) => address(uint256) WalletToWallet;

if msg.sender deposits $20 USD, BankToWallet,
then Bank[balance] - $20 USD, Wallet[balance] + $20 USD,
return error if Bank[balance] < deposit amount;

if msg.sender withdraws $50 USD, WalletToBank,
then Wallet[balance] - $50 USD, Bank[balance] + $50 USD,
return error if Wallet[balance] < withdraw amount;

if msg.sender transfer $5 USD, WalletToWallet,
them msg.sender Wallet[balance] - $5 $USD, recipient Wallet[balance] + $5 USD,
return error if msg.sender Wallet[balance] < transfer amount;

function signIn ( username, credentials, bridgeTo){
msg.sender bank name,
username,
password,
2fa,
return async function bridgeTo (bank, wallet, uint256){

msg.sender[Bank] bridgeTo msg.sender[Wallet];
msg.sender[Bank] => msg.sender[Wallet];
return BankToWallet;
}
}
}
