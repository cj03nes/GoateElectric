// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./USDMediator.sol";
import "./InstilledInteroperability.sol";
import "./TheGoateCard.sol";

contract PayWithCrypto is Ownable {
    USDMediator public usdMediator;
    QuantumInstilledInteroperability public interoperability;
    TheGoateCard public goateCard;
    string[] public supportedAssets;
    mapping(address => mapping(string => bool)) public useForCardPayment;

    event PaymentProcessed(address indexed user, uint256 amount, string paymentMethod, string cardNumber);
    event NFCPaymentInitiated(address indexed user, uint256 amount, string cardNumber);
    event WalletLinked(address indexed user, string cardNumber, string walletType);

    constructor(address _usdMediator, address _interoperability, address _goateCard) Ownable(msg.sender) {
        usdMediator = USDMediator(_usdMediator);
        interoperability = QuantumInstilledInteroperability(_interoperability);
        goateCard = TheGoateCard(_goateCard);
        supportedAssets = ['USD', 'PI', 'ZPE', 'ZPP', 'ZPW', 'ZHV', 'GOATE', 'GySt', 'SD', 'ZGI', 'GP', 'zS'];
    }

    // Process crypto payment (online or POS)
    function payWithCrypto(
        address user,
        uint256 amount,
        string memory paymentMethod,
        string memory pinOrPassword,
        string memory cardNumber
    ) external {
        require(amount >= 0.01 * 10**6, "Minimum transaction amount is $0.01");
        require(verifyCredentials(user, pinOrPassword), "Invalid credentials");
        require(isAuthorizedRecipient(msg.sender, user), "Unauthorized recipient");
        require(verifyCard(user, cardNumber), "Invalid card");

        uint256 totalBalance = calculateTotalBalance(user);
        require(totalBalance >= amount, "Insufficient balance");

        processPayment(user, amount);
        usdMediator.transferUSD(msg.sender, amount);
        emit PaymentProcessed(user, amount, paymentMethod, cardNumber);
    }

    // Process NFC-based payment
    function payWithNFC(
        address user,
        uint256 amount,
        string memory cardNumber,
        bytes memory nfcData
    ) external {
        require(amount >= 0.01 * 10**6, "Minimum transaction amount is $0.01");
        require(verifyCard(user, cardNumber), "Invalid card");
        require(verifyNFCData(nfcData), "Invalid NFC data");

        uint256 totalBalance = calculateTotalBalance(user);
        require(totalBalance >= amount, "Insufficient balance");

        processPayment(user, amount);
        usdMediator.transferUSD(msg.sender, amount);
        emit NFCPaymentInitiated(user, amount, cardNumber);
    }

    // Link card to Google Wallet/Apple Pay
    function linkToWallet(address user, string memory cardNumber, string memory walletType) external {
        require(verifyCard(user, cardNumber), "Invalid card");
        require(
            keccak256(abi.encodePacked(walletType)) == keccak256(abi.encodePacked("GoogleWallet")) ||
            keccak256(abi.encodePacked(walletType)) == keccak256(abi.encodePacked("ApplePay")),
            "Unsupported wallet"
        );
        emit WalletLinked(user, cardNumber, walletType);
    }

    // Calculate total USD balance across supported assets
    function calculateTotalBalance(address user) internal view returns (uint256) {
        uint256 totalBalance = interoperability.activeBalances(user, "USD");
        for (uint256 i = 0; i < supportedAssets.length; i++) {
            string memory asset = supportedAssets[i];
            if (useForCardPayment[user][asset]) {
                totalBalance += interoperability.convertAmount(asset, "USD", interoperability.activeBalances(user, asset));
            }
        }
        return totalBalance;
    }

    // Process payment by deducting from available balances
    function processPayment(address user, uint256 amount) internal {
        uint256 remaining = amount;
        if (interoperability.activeBalances(user, "USD") >= remaining) {
            interoperability.updateBalance(user, "USD", interoperability.activeBalances(user, "USD") - remaining);
            remaining = 0;
        } else {
            remaining -= interoperability.activeBalances(user, "USD");
            interoperability.updateBalance(user, "USD", 0);
            for (uint256 i = 0; i < supportedAssets.length && remaining > 0; i++) {
                string memory asset = supportedAssets[i];
                if (useForCardPayment[user][asset]) {
                    uint256 assetAmount = interoperability.convertAmount("USD", asset, remaining);
                    if (interoperability.activeBalances(user, asset) >= assetAmount) {
                        interoperability.updateBalance(user, asset, interoperability.activeBalances(user, asset) - assetAmount);
                        remaining = 0;
                    } else {
                        remaining -= interoperability.convertAmount(asset, "USD", interoperability.activeBalances(user, asset));
                        interoperability.updateBalance(user, asset, 0);
                    }
                }
            }
        }
    }

    // Verify card details via TheGoateCard contract
    function verifyCard(address user, string memory cardNumber) internal view returns (bool) {
        (string memory storedCardNumber,,,) = goateCard.userCards(user);
        return keccak256(abi.encodePacked(storedCardNumber)) == keccak256(abi.encodePacked(cardNumber));
    }

    // Mock NFC data verification (replace with actual implementation)
    function verifyNFCData(bytes memory nfcData) internal pure returns (bool) {
        return nfcData.length > 0; // Simplified; real NFC validation required
    }

    // Verify user credentials (mock; replace with secure implementation)
    function verifyCredentials(address user, string memory pinOrPassword) internal view returns (bool) {
        return bytes(pinOrPassword).length > 0; // Replace with secure pin/password check
    }

    // Check if recipient is authorized
    function isAuthorizedRecipient(address recipient, address user) internal view returns (bool) {
        return recipient != address(0) && (recipient == user || msg.sender == owner());
    }

    // Enable/disable asset for card payments
    function toggleAssetForPayment(address user, string memory asset, bool enabled) external onlyOwner {
        useForCardPayment[user][asset] = enabled;
    }
}
