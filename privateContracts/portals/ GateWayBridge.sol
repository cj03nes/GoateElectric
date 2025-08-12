// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./Zeropoint.sol";
import "./deviceConnect.sol";

contract GatewayBridge {
    // State variables
    address public owner;
    uint256 public constant ONE_WAY_TICKET = 25 ether; // Using ether for simplicity, adjust as needed
    uint256 public constant ROUND_TRIP_TICKET = 40 ether;
    uint256 public constant CORE_TEAM_SHARE = 75; // 75% to core team
    uint256 public constant CJ03NES_SHARE = 25;  // 25% to cj03nes
    address public constant CJ03NES_ADDRESS = 0xYourAddressHere; // Replace with actual address

    // Structs
    struct Device {
        bool isConnected;
        string ipAddress;
        string wifiMacAddress;
        string location;
    }

    // Mappings
    mapping(string => mapping(string => uint256)) public ticketPrices; // locationA => locationB => price
    mapping(address => uint256) public accountBalances;
    mapping(string => mapping(address => Device)) public chainToDevice; // chain => device => Device info
    mapping(string => mapping(uint256 => mapping(string => mapping(address => Device)))) public zeropointToDevice;
    mapping(string => mapping(string => bool)) public crossChainConnections;

    // Events
    event TicketPurchased(address indexed buyer, string fromLocation, string toLocation, uint256 price, bool isRoundTrip);
    event DeviceConnected(address indexed device, string chain, string location);
    event FundsDistributed(address indexed recipient, uint256 amount);

    // Modifiers
    modifier onlyOwner() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor() {
        owner = msg.sender;
        initializeTicketPrices();
    }

    // Initialize ticket prices for supported locations
    function initializeTicketPrices() private {
        string[5] memory locations = ["NewYork", "Dallas", "NewOrleans", "Atlanta", "Florida"];
        
        for (uint i = 0; i < locations.length; i++) {
            for (uint j = 0; j < locations.length; j++) {
                if (i != j) { // No self-to-self routes
                    ticketPrices[locations[i]][locations[j]] = ONE_WAY_TICKET;
                }
            }
        }
    }

    // Connect a device to the gateway
    function connectGateway(address device, string memory chain, string memory ipAddress, string memory wifiMacAddress, string memory location) 
        external 
        onlyOwner 
        returns (bool) 
    {
        require(device != address(0), "Invalid device address");
        require(bytes(chain).length > 0, "Invalid chain");
        require(bytes(location).length > 0, "Invalid location");

        chainToDevice[chain][device] = Device({
            isConnected: true,
            ipAddress: ipAddress,
            wifiMacAddress: wifiMacAddress,
            location: location
        });

        emit DeviceConnected(device, chain, location);
        return true;
    }

    // Purchase a teleportation ticket
    function buyTicket(string memory fromLocation, string memory toLocation, bool isRoundTrip) 
        external 
        payable 
        returns (bool) 
    {
        uint256 price = isRoundTrip ? ROUND_TRIP_TICKET : ONE_WAY_TICKET;
        require(ticketPrices[fromLocation][toLocation] > 0, "Invalid route");
        require(msg.value >= price, "Insufficient funds");
        require(chainToDevice["mainnet"][msg.sender].isConnected, "Device not connected");

        // Distribute funds
        uint256 coreTeamAmount = (price * CORE_TEAM_SHARE) / 100;
        uint256 cj03nesAmount = (price * CJ03NES_SHARE) / 100;

        accountBalances[owner] += coreTeamAmount;
        accountBalances[CJ03NES_ADDRESS] += cj03nesAmount;

        // Refund excess payment
        if (msg.value > price) {
            payable(msg.sender).transfer(msg.value - price);
        }

        emit TicketPurchased(msg.sender, fromLocation, toLocation, price, isRoundTrip);
        emit FundsDistributed(owner, coreTeamAmount);
        emit FundsDistributed(CJ03NES_ADDRESS, cj03nesAmount);

        return true;
    }

    // Create a bridge between two locations
    function createBridge(string memory chainA, string memory chainB, string memory locationA, string memory locationB) 
        external 
        onlyOwner 
        returns (bool) 
    {
        require(bytes(chainA).length > 0 && bytes(chainB).length > 0, "Invalid chains");
        require(bytes(locationA).length > 0 && bytes(locationB).length > 0, "Invalid locations");
        require(chainToDevice[chainA][msg.sender].isConnected, "Device A not connected");
        require(chainToDevice[chainB][msg.sender].isConnected, "Device B not connected");

        crossChainConnections[locationA][locationB] = true;
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

    // Check if a route is valid
    function isValidRoute(string memory fromLocation, string memory toLocation) 
        external 
        view 
        returns (bool) 
    {
        return ticketPrices[fromLocation][toLocation] > 0 && crossChainConnections[fromLocation][toLocation];
    }
}
