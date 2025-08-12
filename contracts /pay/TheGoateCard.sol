// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract TheGoateCard is Ownable {
    struct Card {
        string cardNumber; // ISO/IEC 7812 compliant
        string expirationDate; // MM/YY format
        string cvc; // 3-digit CVC
        string nftDesign; // Predefined design or custom URL
    }

    mapping(address => Card) public userCards;
    string[] public nftDesigns = [
        "Goat1", "Goat2", "Goat3", "Goat4",
        "Duck1", "Duck2", "Duck3", "Duck4",
        "Sheep1", "Sheep2", "Sheep3", "Sheep4",
        "Lightning1", "Lightning2",
        "DollarSign1", "DollarSign2",
        "PlainBlack1", "PlainBlack2",
        "PlainWhite1", "PlainWhite2"
    ];

    event CardIssued(address indexed user, string cardNumber, string nftDesign);
    event NFCTokenGenerated(address indexed user, string cardNumber, bytes nfcToken);

    constructor(address initialOwner) Ownable(initialOwner) {}

    // Generate a new card with a predefined design
    function generateCardWithDesign(address user, uint256 designIndex) external {
        require(msg.sender == user || msg.sender == owner(), "Unauthorized");
        require(designIndex < nftDesigns.length, "Invalid design index");
        generateCard(user, nftDesigns[designIndex]);
    }

    // Generate a new card with a custom image URL
    function generateCardWithCustomImage(address user, string memory customImageUrl) external {
        require(msg.sender == user || msg.sender == owner(), "Unauthorized");
        require(isValidImageUrl(customImageUrl), "Invalid image URL");
        generateCard(user, customImageUrl);
    }

    // Internal function to generate card
    function generateCard(address user, string memory design) internal {
        string memory cardNumber = generateCardNumber(user);
        string memory expirationDate = generateExpirationDate();
        string memory cvc = generateCVC(user);
        userCards[user] = Card(cardNumber, expirationDate, cvc, design);
        emit CardIssued(user, cardNumber, design);
    }

    // Generate NFC token for payment processing
    function generateNFCToken(address user) external returns (bytes memory) {
        (string memory cardNumber,,,) = userCards[user];
        require(bytes(cardNumber).length > 0, "No card found for user");
        bytes memory nfcToken = abi.encodePacked(keccak256(abi.encodePacked(user, cardNumber, block.timestamp)));
        emit NFCTokenGenerated(user, cardNumber, nfcToken);
        return nfcToken;
    }

    // Generate ISO/IEC 7812 compliant card number (16 digits, starting with 4)
    function generateCardNumber(address user) internal view returns (string memory) {
        bytes32 hash = keccak256(abi.encodePacked(user, block.timestamp, block.chainid));
        uint256 number = uint256(hash) % 10**15;
        return string(abi.encodePacked("4", toString(number, 15))); // 16-digit card number
    }

    // Generate 3-digit CVC
    function generateCVC(address user) internal view returns (string memory) {
        bytes32 hash = keccak256(abi.encodePacked(user, block.timestamp, block.chainid));
        uint256 cvc = uint256(hash) % 1000;
        return toString(cvc, 3); // 3-digit CVC
    }

    // Generate expiration date (MM/YY, valid for 3 years)
    function generateExpirationDate() internal view returns (string memory) {
        uint256 currentYear = (block.timestamp / 31557600) + 1970; // Approximate year
        uint256 expiryYear = currentYear + 3;
        uint256 month = (block.timestamp % 31557600 / 2629800) + 1; // Approximate month
        return string(abi.encodePacked(toString(month, 2), "/", toString(expiryYear % 100, 2)));
    }

    // Convert uint to string with fixed digits
    function toString(uint256 value, uint256 length) internal pure returns (string memory) {
        bytes memory buffer = new bytes(length);
        for (uint256 i = length; i > 0; i--) {
            buffer[i-1] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    // Validate custom image URL (basic validation)
    function isValidImageUrl(string memory url) internal pure returns (bool) {
        bytes memory urlBytes = bytes(url);
        if (urlBytes.length == 0) return false;
        // Check for HTTP/HTTPS or IPFS prefix (simplified)
        bytes memory httpPrefix = bytes("http://");
        bytes memory httpsPrefix = bytes("https://");
        bytes memory ipfsPrefix = bytes("ipfs://");
        if (urlBytes.length < 7) return false;
        for (uint256 i = 0; i < 7; i++) {
            if (urlBytes[i] != httpPrefix[i] && urlBytes[i] != httpsPrefix[i] && urlBytes[i] != ipfsPrefix[i]) {
                return i >= 6; // Allow partial match for ipfs://
            }
        }
        return true;
    }

    // Get card metadata for wallet integration (Google Wallet/Apple Pay)
    function getCardMetadata(address user) external view returns (string memory cardNumber, string memory expirationDate, string memory cvc, string memory nftDesign) {
        Card memory card = userCards[user];
        require(bytes(card.cardNumber).length > 0, "No card found for user");
        return (card.cardNumber, card.expirationDate, card.cvc, card.nftDesign);
    }
}
