// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./USDMediator.sol";
import "./InstilledInteroperability.sol";

contract ZeropointInsurance is ERC20, Ownable {
    USDMediator public usdMediator;
    InstilledInteroperability public interoperability;
    uint256 public constant SUBSCRIPTION_COST = 6 * 10**18; // $6 in $ZGI
    uint256 public constant SUBSCRIPTION_DURATION = 30 days;
    uint256 public constant CLAIM_PAYOUT = 100 * 10**18; // Fixed payout amount in $ZGI

    struct InsuredDevice {
        string deviceId;
        bool isInsured;
        uint256 expiry;
        bool shieldActive;
        uint256 shieldDefenseLevel;
    }

    mapping(address => InsuredDevice[]) public insuredDevices;

    event ShieldActivated(address indexed user, string deviceId, uint256 timestamp);
    event ShieldDeactivated(address indexed user, string deviceId, uint256 timestamp);
    event ClaimProcessed(address indexed user, string deviceId, uint256 amount, uint256 timestamp);

    constructor(address _usdMediator, address _interoperability) 
        ERC20("ZeropointInsurance", "ZGI") Ownable(msg.sender) {
        usdMediator = USDMediator(_usdMediator);
        interoperability = InstilledInteroperability(_interoperability);
        _mint(msg.sender, 1000000 * 10**18);
    }

    function subscribe(string memory deviceId, uint256 amount) external {
        require(amount >= SUBSCRIPTION_COST, "Insufficient $ZGI");
        _burn(msg.sender, SUBSCRIPTION_COST);
        insuredDevices[msg.sender].push(InsuredDevice(deviceId, true, block.timestamp + SUBSCRIPTION_DURATION, false, 10000));
    }

    function activateShield(string memory deviceId, uint256 outsideForce) external {
        InsuredDevice[] storage devices = insuredDevices[msg.sender];
        uint256 index = findDeviceIndex(devices, deviceId);
        require(index < devices.length, "Device not insured");
        require(devices[index].isInsured && devices[index].expiry > block.timestamp, "Insurance expired");
        require(outsideForce >= 100, "Force must be at least 100");
        require(devices[index].shieldDefenseLevel >= 10000, "Shield strength insufficient");

        devices[index].shieldActive = true;
        emit ShieldActivated(msg.sender, deviceId, block.timestamp);
    }

    function deactivateShield(string memory deviceId) external {
        InsuredDevice[] storage devices = insuredDevices[msg.sender];
        uint256 index = findDeviceIndex(devices, deviceId);
        require(index < devices.length, "Device not insured");
        require(devices[index].shieldActive, "Shield not active");

        devices[index].shieldActive = false;
        emit ShieldDeactivated(msg.sender, deviceId, block.timestamp);
    }

    function makeClaim(string memory deviceId, string memory claimData) external {
        InsuredDevice[] storage devices = insuredDevices[msg.sender];
        uint256 index = findDeviceIndex(devices, deviceId);
        require(index < devices.length, "Device not insured");
        require(devices[index].isInsured && devices[index].expiry > block.timestamp, "Insurance expired");

        // Automatically process claim and transfer payout
        _mint(msg.sender, CLAIM_PAYOUT);
        emit ClaimProcessed(msg.sender, deviceId, CLAIM_PAYOUT, block.timestamp);

        // Activate shield upon claim if not already active
        if (!devices[index].shieldActive) {
            require(devices[index].shieldDefenseLevel >= 10000, "Shield strength insufficient");
            devices[index].shieldActive = true;
            emit ShieldActivated(msg.sender, deviceId, block.timestamp);
        }
    }

    function findDeviceIndex(InsuredDevice[] storage devices, string memory deviceId) internal view returns (uint256) {
        for (uint256 i = 0; i < devices.length; i++) {
            if (keccak256(bytes(devices[i].deviceId)) == keccak256(bytes(deviceId))) {
                return i;
            }
        }
        return devices.length;
    }

    function getInsuredDevices(address user) external view returns (InsuredDevice[] memory) {
        return insuredDevices[user];
    }
}