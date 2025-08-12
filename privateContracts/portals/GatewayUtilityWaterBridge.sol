// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Zeropoint.sol";
import "./deviceConnect.sol";

contract GatewayUtilityWaterBridge {
    // State variables
    address public owner;
    uint256 public constant WATER_DELIVERY_FEE = 2 ether; // Low fee for water delivery, adjust as needed
    uint256 public constant CORE_TEAM_SHARE = 75; // 75% to core team
    uint256 public constant CJ03NES_SHARE = 25;  // 25% to cj03nes
    address public constant CJ03NES_ADDRESS = 0xYourAddressHere; // Replace with actual address

    // Structs
    struct Device {
        bool isConnected;
        string ipAddress;
        string wifiMacAddress;
        string locationType; // "Ocean", "Sanitation", or "Consumer"
        string locationName; // e.g., "AtlanticSource", "SanitationNY", "HomeDallas"
    }

    // Struct for water cargo to enforce restrictions
    struct WaterCargo {
        uint256 volume; // in liters, for validation
        bool isSanitized; // Must be true for transport
        bool isNonLiving; // Must be true to prevent living organisms
    }

    // Mappings
    mapping(string => mapping(string => mapping(string => uint256))) public deliveryFees; // ocean => sanitation => consumer => fee
    mapping(address => uint256) public accountBalances;
    mapping(string => mapping(address => Device)) public chainToDevice; // chain => device => Device info
    mapping(string => mapping(string => mapping(string => bool))) public oceanToSanitationToConsumerConnections;

    // Events
    event WaterDeliveryPurchased(
        address indexed buyer,
        string ocean,
        string sanitation,
        string consumer,
        uint256 fee,
        uint256 volume
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

    // Initialize delivery fees for ocean-to-sanitation-to-consumer routes
    function initializeDeliveryFees() private {
        string[2] memory oceans = ["AtlanticSource", "PacificSource"];
        string[2] memory sanitations = ["SanitationNY", "SanitationCA"];
        string[2] memory consumers = ["HomeNY", "OfficeCA"];

        for (uint i = 0; i < oceans.length; i++) {
            for (uint j = 0; j < sanitations.length; j++) {
                for (uint k = 0; k < consumers.length; k++) {
                    deliveryFees[oceans[i]][sanitations[j]][consumers[k]] = WATER_DELIVERY_FEE;
                }
            }
        }
    }

    // Connect a device to the water bridge gateway
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
            keccak256(bytes(locationType)) == keccak256(bytes("Ocean")) ||
            keccak256(bytes(locationType)) == keccak256(bytes("Sanitation")) ||
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

    // Purchase a water delivery
    function buyWaterDelivery(
        string memory oceanLocation,
        string memory sanitationLocation,
        string memory consumerLocation,
        WaterCargo memory waterCargo
    ) external payable returns (bool) {
        // Enforce restrictions
        require(waterCargo.isNonLiving, "Living organisms not allowed");
        require(waterCargo.isSanitized, "Water must be sanitized");
        require(waterCargo.volume <= 1000, "Volume exceeds 1000L limit"); // Arbitrary limit
        require(
            deliveryFees[oceanLocation][sanitationLocation][consumerLocation] > 0,
            "Invalid delivery route"
        );
        require(msg.value >= WATER_DELIVERY_FEE, "Insufficient funds");
        require(chainToDevice["mainnet"][msg.sender].isConnected, "Device not connected");
        require(
            keccak256(bytes(chainToDevice["mainnet"][msg.sender].locationType)) == keccak256(bytes("Consumer")),
            "Sender must be a consumer device"
        );

        // Distribute funds
        uint256 coreTeamAmount = (WATER_DELIVERY_FEE * CORE_TEAM_SHARE) / 100;
        uint256 cj03nesAmount = (WATER_DELIVERY_FEE * CJ03NES_SHARE) / 100;

        accountBalances[owner] += coreTeamAmount;
        accountBalances[CJ03NES_ADDRESS] += cj03nesAmount;

        // Refund excess payment
        if (msg.value > WATER_DELIVERY_FEE) {
            payable(msg.sender).transfer(msg.value - WATER_DELIVERY_FEE);
        }

        emit WaterDeliveryPurchased(
            msg.sender,
            oceanLocation,
            sanitationLocation,
            consumerLocation,
            WATER_DELIVERY_FEE,
            waterCargo.volume
        );
        emit FundsDistributed(owner, coreTeamAmount);
        emit FundsDistributed(CJ03NES_ADDRESS, cj03nesAmount);

        return true;
    }

    // Create a bridge from ocean to sanitation to consumer
    function createWaterBridge(
        string memory chainA,
        string memory chainB,
        string memory chainC,
        string memory oceanLocation,
        string memory sanitationLocation,
        string memory consumerLocation
    ) external onlyOwner returns (bool) {
        require(
            bytes(chainA).length > 0 &&
            bytes(chainB).length > 0 &&
            bytes(chainC).length > 0,
            "Invalid chains"
        );
        require(
            bytes(oceanLocation).length > 0 &&
            bytes(sanitationLocation).length > 0 &&
            bytes(consumerLocation).length > 0,
            "Invalid locations"
        );
        require(chainToDevice[chainA][msg.sender].isConnected, "Ocean device not connected");
        require(chainToDevice[chainB][msg.sender].isConnected, "Sanitation device not connected");
        require(chainToDevice[chainC][msg.sender].isConnected, "Consumer device not connected");
        require(
            keccak256(bytes(chainToDevice[chainA][msg.sender].locationType)) == keccak256(bytes("Ocean")),
            "LocationA must be Ocean"
        );
        require(
            keccak256(bytes(chainToDevice[chainB][msg.sender].locationType)) == keccak256(bytes("Sanitation")),
            "LocationB must be Sanitation"
        );
        require(
            keccak256(bytes(chainToDevice[chainC][msg.sender].locationType)) == keccak256(bytes("Consumer")),
            "LocationC must be Consumer"
        );

        oceanToSanitationToConsumerConnections[oceanLocation][sanitationLocation][consumerLocation] = true;
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
    function isValidDeliveryRoute(
        string memory oceanLocation,
        string memory sanitationLocation,
        string memory consumerLocation
    ) external view returns (bool) {
        return deliveryFees[oceanLocation][sanitationLocation][consumerLocation] > 0 &&
               oceanToSanitationToConsumerConnections[oceanLocation][sanitationLocation][consumerLocation];
    }

    // Reject transport of living organisms or biometrics
    function restrictLivingTransport() internal pure returns (bool) {
        // Placeholder for integration with oracles/sensors to verify water purity
        return true;
    }
}
