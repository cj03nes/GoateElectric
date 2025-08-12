// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Interface for Zeropoint digital energy (infinite supply)
interface IZeropoint {
    function drawZeropoint(address user, uint256 amount) external returns (bool);
    function returnZeropoint(address user, uint256 amount) external returns (bool);
    function totalSupply() external view returns (uint256);
}

// Interface for ZeropointShield (AetherTouch integration)
interface IZeropointShield {
    function activateAetherTouch(address user, uint256 duration) external returns (bool);
    function getAetherTouchStatus(address user) external view returns (bool, uint256);
}

contract ZeropointRegenerationBed {
    // State variables
    address public owner;
    IZeropoint public zeropointContract;
    IZeropointShield public zeropointShieldContract;
    mapping(address => bool) public connectedBeds;
    mapping(address => Patient) public patients;
    mapping(string => bool) public validConditions;
    mapping(address => uint256) public usedZeropoint; // Track Zeropoint drawn per patient

    // Patient data structure
    struct Patient {
        bytes32 biometrics; // Hash of patient data
        string condition; // Diagnosed condition
        uint256 severity; // 0 (healthy) to 10 (life-threatening)
        uint256 startTime; // Healing start timestamp
        uint256 duration; // Healing duration in seconds
        bool active; // Healing in progress
    }

    // Events
    event BedConnected(address indexed bed, string bedInfo);
    event PatientRegistered(address indexed patient, bytes32 biometrics, string condition, uint256 severity);
    event HealingStarted(address indexed patient, string condition, uint256 duration, uint256 zeropointAmount);
    event HealingStatusUpdated(address indexed patient, string status, string lighting, string audio);
    event HealingFailed(address indexed patient, string condition, string reason);
    event AetherTouchActivated(address indexed patient, uint256 duration);
    event ZeropointDrawn(address indexed patient, uint256 amount);
    event ZeropointReturned(address indexed patient, uint256 amount);

    // Errors
    error Unauthorized();
    error InvalidCondition();
    error PatientNotRegistered();
    error BedNotConnected();
    error HealingAlreadyActive();
    error ZeropointOperationFailed();

    // Modifiers
    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    modifier onlyConnectedBed() {
        if (!connectedBeds[msg.sender]) revert BedNotConnected();
        _;
    }

    constructor(address _zeropointContract, address _zeropointShieldContract) {
        owner = msg.sender;
        zeropointContract = IZeropoint(_zeropointContract);
        zeropointShieldContract = IZeropointShield(_zeropointShieldContract);

        // Initialize valid medical conditions
        initializeConditions();
    }

    // Initialize valid medical conditions
    function initializeConditions() internal {
        validConditions["cancer"] = true;
        validConditions["diabetes"] = true;
        validConditions["broken-bones"] = true;
        validConditions["concussion"] = true;
        validConditions["alzheimers"] = true;
    }

    // Connect a regeneration bed
    function connectBed(address bed, string memory bedInfo) external onlyOwner {
        connectedBeds[bed] = true;
        emit BedConnected(bed, bedInfo);
    }

    // Register patient biometrics and diagnosis
    function registerPatient(address patient, string memory condition, uint256 severity, string memory biometricData) external onlyOwner {
        if (!validConditions[condition]) revert InvalidCondition();
        if (severity > 10) revert InvalidCondition(); // Severity must be 0-10

        bytes32 biometrics = keccak256(abi.encodePacked(patient, biometricData));
        patients[patient] = Patient({
            biometrics: biometrics,
            condition: condition,
            severity: severity,
            startTime: 0,
            duration: 0,
            active: false
        });

        emit PatientRegistered(patient, biometrics, condition, severity);
    }

    // Start healing process
    function startHealing(address patient) external onlyConnectedBed {
        Patient storage patientData = patients[patient];
        if (patientData.biometrics == bytes32(0)) revert PatientNotRegistered();
        if (patientData.active) revert HealingAlreadyActive();

        // Calculate Zeropoint cost and healing duration
        uint256 zeropointAmount = calculateZeropointCost(patientData.severity);
        uint256 healingDuration = calculateHealingDuration(patientData.severity);

        // Draw Zeropoint from totalSupply
        if (!zeropointContract.drawZeropoint(patient, zeropointAmount)) revert ZeropointOperationFailed();
        usedZeropoint[patient] = zeropointAmount;
        emit ZeropointDrawn(patient, zeropointAmount);

        // Activate AetherTouch
        if (!zeropointShieldContract.activateAetherTouch(patient, healingDuration)) revert ZeropointOperationFailed();

        // Apply healing mechanisms (shockTherapy, waterFrequency, AetherTouch)
        bool success = applyHealingMechanisms(patient, patientData.condition);
        if (success) {
            patientData.startTime = block.timestamp;
            patientData.duration = healingDuration;
            patientData.active = true;
            emit HealingStarted(patient, patientData.condition, healingDuration, zeropointAmount);
            emit HealingStatusUpdated(patient, "active", "yellow and green", "");
            emit AetherTouchActivated(patient, healingDuration);
        } else {
            // Return Zeropoint if healing fails
            if (!zeropointContract.returnZeropoint(patient, zeropointAmount)) revert ZeropointOperationFailed();
            usedZeropoint[patient] = 0;
            emit ZeropointReturned(patient, zeropointAmount);
            emit HealingFailed(patient, patientData.condition, "Healing mechanism failed");
        }
    }

    // Calculate Zeropoint cost based on severity
    function calculateZeropointCost(uint256 severity) internal pure returns (uint256) {
        // Example: 100 Zeropoint per severity level
        return severity * 100;
    }

    // Calculate healing duration based on severity
    function calculateHealingDuration(uint256 severity) internal pure returns (uint256) {
        // Base duration: 7 days (604800 seconds) for severity 10
        // Scale linearly: severity 0 = 0 seconds, severity 10 = 7 days
        return (severity * 604800) / 10;
    }

    // Apply healing mechanisms (placeholder for off-chain medical logic)
    function applyHealingMechanisms(address patient, string memory condition) internal returns (bool) {
        // Simulate shockTherapy, waterFrequency, and AetherTouch
        // Assume no harm (!hurt) is verified off-chain
        return true; // Placeholder: actual medical logic handled off-chain
    }

    // Check healing status and update
    function checkHealingStatus(address patient) external returns (string memory status, string memory lighting, string memory audio) {
        Patient storage patientData = patients[patient];
        if (patientData.biometrics == bytes32(0)) revert PatientNotRegistered();

        if (!patientData.active) {
            return ("inactive", "yellow and red", "");
        }

        if (block.timestamp >= patientData.startTime + patientData.duration) {
            patientData.active = false;
            patientData.severity = 0; // Assume fully healed

            // Return Zeropoint to totalSupply
            uint256 zeropointAmount = usedZeropoint[patient];
            if (zeropointAmount > 0) {
                if (!zeropointContract.returnZeropoint(patient, zeropointAmount)) revert ZeropointOperationFailed();
                emit ZeropointReturned(patient, zeropointAmount);
                usedZeropoint[patient] = 0;
            }

            emit HealingStatusUpdated(
                patient,
                "completed",
                "purple and green",
                "https://www.youtube.com/watch?v=CS9OO0S5w2k&list=RDCS9OO0S5w2k&start_radio=1"
            );
            return (
                "completed",
                "purple and green",
                "https://www.youtube.com/watch?v=CS9OO0S5w2k&list=RDCS9OO0S5w2k&start_radio=1"
            );
        }

        return ("active", "yellow and green", "");
    }

    // Get patient diagnosis
    function getPatientDiagnosis(address patient) external view returns (string memory condition, uint256 severity) {
        Patient storage patientData = patients[patient];
        if (patientData.biometrics == bytes32(0)) revert PatientNotRegistered();
        return (patientData.condition, patientData.severity);
    }

    // Get AetherTouch status
    function getAetherTouchStatus(address patient) external view returns (bool active, uint256 duration) {
        return zeropointShieldContract.getAetherTouchStatus(patient);
    }

    // Get used Zeropoint for a patient
    function getUsedZeropoint(address patient) external view returns (uint256) {
        return usedZeropoint[patient];
    }
}
