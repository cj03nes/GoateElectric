// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Zeropoint.sol";
import "./deviceConnect.sol";

contract GatewayMailDeliveryBridge {
    // State variables
    address public owner;
    uint256 public constant MAIL_DELIVERY_FEE = 3 ether; // Fee for mail delivery, adjust as needed
    uint256 public constant CORE_TEAM_SHARE = 75; // 75% to core team
    uint256 public constant CJ03NES_SHARE = 25;  // 25% to cj03nes
    address public constant CJ03NES_ADDRESS = 0xYourAddressHere; // Replace with actual address

    // Structs
    struct Device {
        bool isConnected;
        string ipAddress;
        string wifiMacAddress;
        string locationType; // "EnterpriseMail" or "ConsumerMailbox"
        string locationName; // e.g., "PostOfficeNY", "MailboxDallas123"
    }

    // Struct for mail items to enforce restrictions
    struct MailItem {
        string itemDescription; // e.g., "Letter", "Package"
        uint256 weight; // in grams, for validation
        bool isNonLiving; // Must be true to prevent living organisms
    }

    // Mappings
    mapping(string => mapping(string => uint256)) public deliveryFees; // enterprise => consumer => fee
    mapping(address => uint256) public accountBalances;
    mapping(string => mapping(address => Device)) public chainToDevice; // chain => device => Device info
    mapping(string => mapping(string => bool)) public enterpriseToConsumerConnections;

    // Events
    event MailDeliveryPurchased(
        address indexed buyer,
        string enterprise,
        string consumer,
        uint256 fee,
        string itemDescription
    );
    event DeviceConnected(address indexed device, string chain, string locationType, string locationName);
    event FundsDistributed(address indexed recipient, uint256 amount);
    event TransportRejected(string reason);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
        initializeDeliveryFees();
    }

    // Initialize delivery fees for enterprise-to-consumer routes
    function initializeDeliveryFees() private {
        string[3] memory enterprises = ["PostOfficeNY", "CourierHubCA", "MailCenterTX"];
        string[3] memory consumers = ["MailboxNY123", "MailboxCA456", "MailboxTX789"];

        for (uint i = 0; i < enterprises.length; i++) {
            for (uint j = 0; j < consumers.length; j++) {
                deliveryFees[enterprises[i]][consumers[j]] = MAIL_DELIVERY_FEE;
            }
        }
    }

    // Connect a device to the mail delivery gateway
    function connectGateway(
        address device,
        string memory chain,
        string memory ipAddress,
        string memory wifiMacAddress,
        string memory locationType,
        string memory locationName
    ) external onlyOwner returns (bool) {
        require(device != address(0), "Invalid device address");
        require(bytes(chain).length > 0, "Invalid chain");
        require(
            keccak256(bytes(locationType)) == keccak256(bytes("EnterpriseMail")) ||
            keccak256(bytes(locationType)) == keccak256(bytes("ConsumerMailbox")),
            "Invalid location type"
        );
        require(bytes(locationName).length > 0, "Invalid location name");

        chainToDevice[chain][device] = Device({
            isConnected: true,
            ipAddress: ipAddress,
            wifiMacAddress: wifiMacAddress,
            locationType: locationType,
            locationName: locationName
        });

        emit DeviceConnected(device, chain, locationType, locationName);
        return true;
    }

    // Purchase a mail delivery
    function buyMailDelivery(
        string memory enterpriseLocation,
        string memory consumerLocation,
        MailItem memory mailItem
    ) external payable returns (bool) {
        // Enforce restrictions
        require(mailItem.isNonLiving, "Living organisms not allowed");
        require(mailItem.weight <= 2000, "Weight exceeds 2kg limit"); // Arbitrary limit for mail
        require(deliveryFees[enterpriseLocation][consumerLocation] > 0, "Invalid delivery route");
        require(msg.value >= MAIL_DELIVERY_FEE, "Insufficient funds");
        require(chainToDevice["mainnet"][msg.sender].isConnected, "Device not connected");
        require(
            keccak256(bytes(chainToDevice["mainnet"][msg.sender].locationType)) == keccak256(bytes("ConsumerMailbox")),
            "Sender must be a consumer mailbox device"
        );

        // Distribute funds
        uint256 coreTeamAmount = (MAIL_DELIVERY_FEE * CORE_TEAM_SHARE) / 100;
        uint256 cj03nesAmount = (MAIL_DELIVERY_FEE * CJ03NES_SHARE) / 100;

        accountBalances[owner] += coreTeamAmount;
        accountBalances[CJ03NES_ADDRESS] += cj03nesAmount;

        // Refund excess payment
        if (msg.value > MAIL_DELIVERY_FEE) {
            payable(msg.sender).transfer(msg.value - MAIL_DELIVERY_FEE);
        }

        emit MailDeliveryPurchased(
            msg.sender,
            enterpriseLocation,
            consumerLocation,
            MAIL_DELIVERY_FEE,
            mailItem.itemDescription
        );
        emit FundsDistributed(owner, coreTeamAmount);
        emit FundsDistributed(CJ03NES_ADDRESS, cj03nesAmount);

        return true;
    }

    // Create a bridge from enterprise to consumer mailbox
    function createMailBridge(
        string memory chainA,
        string memory chainB,
        string memory enterpriseLocation,
        string memory consumerLocation
    ) external onlyOwner returns (bool) {
        require(bytes(chainA).length > 0 && bytes(chainB).length > 0, "Invalid chains");
        require(bytes(enterpriseLocation).length > 0 && bytes(consumerLocation).length > 0, "Invalid locations");
        require(chainToDevice[chainA][msg.sender].isConnected, "Enterprise device not connected");
        require(chainToDevice[chainB][msg.sender].isConnected, "Consumer device not connected");
        require(
            keccak256(bytes(chainToDevice[chainA][msg.sender].locationType)) == keccak256(bytes("EnterpriseMail")),
            "LocationA must be EnterpriseMail"
        );
        require(
            keccak256(bytes(chainToDevice[chainB][msg.sender].locationType)) == keccak256(bytes("ConsumerMailbox")),
            "LocationB must be ConsumerMailbox"
        );

        enterpriseToConsumerConnections[enterpriseLocation][consumerLocation] = true;
        return true;
    }

    // Withdraw funds (for owner or cj03nes)
    function withdraw() external {
        uint256 amount = accountBalances[msg.sender];
        require(amount > 0, "No funds to withdraw");
        require(msg.sender == owner || msg.sender == CJ03NES_ADDRESS, "Not authorized");

        accountBalances[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }

    // Check if a delivery route is valid
    function isValidDeliveryRoute(string memory enterpriseLocation, string memory consumerLocation)
        external
        view
        returns (bool)
    {
        return deliveryFees[enterpriseLocation][consumerLocation] > 0 &&
               enterpriseToConsumerConnections[enterpriseLocation][consumerLocation];
    }

    // Reject transport of living organisms or biometrics
    function restrictLivingTransport() internal pure returns (bool) {
        // Placeholder for integration with oracles/sensors to verify mail contents
        return true;
    }
}
