// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract ZeropointShield {
    // State variables for shield properties
    string public color = "blue";
    bool public translucent = true;
    bool public permeable = false;
    string public form = "solid";
    bool public isActive = false;
    uint256 public activationTime;
    uint256 public defenseLevel = 0;
    uint256 public outsideViewOpacity = 75;
    uint256 public insideViewOpacity = 100;
    uint256 public outsideAudio = 0;
    uint256 public insideAudio = 100;

    // Address of the shield owner
    address public owner;

    // Minimum force required for shield to activate
    uint256 public constant MIN_FORCE_THRESHOLD = 100;
    // Minimum shield strength to handle force
    uint256 public constant MIN_SHIELD_STRENGTH = 10000;

    // Events for logging shield actions
    event ShieldActivated(address indexed user, uint256 timestamp);
    event ShieldDeactivated(address indexed user, uint256 timestamp);
    event ForceHandled(address indexed user, uint256 force, string action);
    event ShieldPropertiesUpdated(string color, uint256 outsideView, uint256 defense);

    // Constructor to set the owner
    constructor() {
        owner = msg.sender;
    }

    // Modifier to restrict access to the owner
    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    // Function to activate the shield and handle external force
    function activateShield(uint256 outsideForce) external onlyOwner {
        require(outsideForce >= MIN_FORCE_THRESHOLD, "Force must be at least 100");
        require(defenseLevel >= MIN_SHIELD_STRENGTH, "Shield strength insufficient");

        isActive = true;
        activationTime = block.timestamp;

        // Handle the outside force (deflect, catch, or dissolve)
        handleForce(outsideForce);

        // Update shield properties if active for 3 seconds or more
        if (block.timestamp >= activationTime + 3) {
            updateShieldProperties();
        }

        emit ShieldActivated(msg.sender, block.timestamp);
    }

    // Internal function to handle external force
    function handleForce(uint256 force) internal {
        // Logic for deflecting, catching, or dissolving force
        if (force <= defenseLevel) {
            emit ForceHandled(msg.sender, force, "Deflected");
        } else if (force <= defenseLevel * 2) {
            emit ForceHandled(msg.sender, force, "Caught and Encompassed");
        } else {
            emit ForceHandled(msg.sender, force, "Dissolved");
        }

        // Ensure no collateral damage (rebound force is zero)
        require(force <= defenseLevel, "Collateral force detected");
    }

    // Internal function to update shield properties after 3 seconds
    function updateShieldProperties() internal {
        color = "clear";
        defenseLevel = type(uint256).max; // Maximum defense
        outsideViewOpacity = 75; // Transparent blue for front and rear view
        insideViewOpacity = 100;
        outsideAudio = 0;
        insideAudio = 100;

        emit ShieldPropertiesUpdated(color, outsideViewOpacity, defenseLevel);
    }

    // Function to deactivate the shield
    function deactivateShield() external onlyOwner {
        require(isActive, "Shield is not active");
        isActive = false;
        activationTime = 0;

        // Reset properties to initial state
        color = "blue";
        defenseLevel = 0;
        outsideViewOpacity = 75;
        insideViewOpacity = 100;
        outsideAudio = 0;
        insideAudio = 100;

        emit ShieldDeactivated(msg.sender, block.timestamp);
    }

    // Function to set defense level (for testing or owner control)
    function setDefenseLevel(uint256 newLevel) external onlyOwner {
        defenseLevel = newLevel;
    }

    // Function to check shield status
    function getShieldStatus() external view returns (
        bool active,
        string memory currentColor,
        uint256 currentDefense,
        uint256 currentOutsideView,
        uint256 currentInsideView
    ) {
        return (
            isActive,
            color,
            defenseLevel,
            outsideViewOpacity,
            insideViewOpacity
        );
    }
}
