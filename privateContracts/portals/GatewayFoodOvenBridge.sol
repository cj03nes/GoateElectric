// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Zeropoint.sol";
import "./deviceConnect.sol";

contract GatewayFoodOvenBridge {
    // State variables
    address public owner;
    uint256 public constant FOOD_DELIVERY_FEE = 5 ether; // Lower fee for food delivery, adjust as needed
    uint256 public constant CORE_TEAM_SHARE = 75; // 75% to core team
    uint256 public constant CJ03NES_SHARE = 25;  // 25% to cj03nes
    address public constant CJ03NES_ADDRESS = 0xYourAddressHere; // Replace with actual address

    // Structs
    struct Device {
        bool isConnected;
        string ipAddress;
        string wifiMacAddress;
        string locationType; // "Enterprise" or "Consumer"
        string locationName; // e.g., "RestaurantX" or "Home123"
    }

    // Struct for food items to enforce restrictions
    struct FoodItem {
        string itemName;
        uint256 weight; // in grams, for validation
        bool isNonLiving; // Must be true for transport
    }

    // Mappings
    mapping(string => mapping(string => uint256)) public deliveryFees; // enterprise => consumer => fee
    mapping(address => uint256) public accountBalances;
    mapping(string => mapping(address => Device)) public chainToDevice; // chain => device => Device info
    mapping(string => mapping(string => bool)) public enterpriseToConsumerConnections;

    // Events
    event FoodDeliveryPurchased(address indexed buyer, string enterprise, string consumer, uint256 fee, string itemName);
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

    // Initialize delivery fees for supported enterprise-to-consumer routes
    function initializeDeliveryFees() private {
        string[3] memory enterprises = ["RestaurantNY", "BakeryDallas", "CafeAtlanta"];
        string[3] memory consumers = ["HomeNY", "OfficeDallas", "ApartmentAtlanta"];

        for (uint i = 0; i < enterprises.length; i++) {
            for (uint j = 0; j < consumers.length; j++) {
                deliveryFees[enterprises[i]][consumers[j]] = FOOD_DELIVERY_FEE;
            }
        }
    }

    // Connect a device to the food oven gateway
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
            keccak256(bytes(locationType)) == keccak256(bytes("Enterprise")) ||
            keccak256(bytes(locationType)) == keccak256(bytes("Consumer")),
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

    // Purchase a food delivery
    function buyFoodDelivery(
        string memory enterpriseLocation,
        string memory consumerLocation,
        FoodItem memory foodItem
    ) external payable returns (bool) {
        // Enforce non-living restriction
        require(foodItem.isNonLiving, "Living organisms not allowed");
        require(foodItem.weight <= 5000, "Weight exceeds 5kg limit"); // Arbitrary limit for food
        require(deliveryFees[enterpriseLocation][consumerLocation] > 0, "Invalid delivery route");
        require(msg.value >= FOOD_DELIVERY_FEE, "Insufficient funds");
        require(chainToDevice["mainnet"][msg.sender].isConnected, "Device not connected");
        require(
            keccak256(bytes(chainToDevice["mainnet"][msg.sender].locationType)) == keccak256(bytes("Consumer")),
            "Sender must be a consumer device"
        );

        // Distribute funds
        uint256 coreTeamAmount = (FOOD_DELIVERY_FEE * CORE_TEAM_SHARE) / 100;
        uint256 cj03nesAmount = (FOOD_DELIVERY_FEE * CJ03NES_SHARE) / 100;

        accountBalances[owner] += coreTeamAmount;
        accountBalances[CJ03NES_ADDRESS] += cj03nesAmount;

        // Refund excess payment
        if (msg.value > FOOD_DELIVERY_FEE) {
            payable(msg.sender).transfer(msg.value - FOOD_DELIVERY_FEE);
        }

        emit FoodDeliveryPurchased(msg.sender, enterpriseLocation, consumerLocation, FOOD_DELIVERY_FEE, foodItem.itemName);
        emit FundsDistributed(owner, coreTeamAmount);
        emit FundsDistributed(CJ03NES_ADDRESS, cj03nesAmount);

        return true;
    }

    // Create a bridge between enterprise and consumer locations
    function createFoodBridge(
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
            keccak256(bytes(chainToDevice[chainA][msg.sender].locationType)) == keccak256(bytes("Enterprise")),
            "LocationA must be Enterprise"
        );
        require(
            keccak256(bytes(chainToDevice[chainB][msg.sender].locationType)) == keccak256(bytes("Consumer")),
            "LocationB must be Consumer"
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
        // This could integrate with external oracles or sensors in a real implementation
        // For now, rely on FoodItem.isNonLiving flag
        return true;
    }
}
