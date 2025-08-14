

hey grok;

im trying to relaunch my business but im having trouble with the interface & ui/ux. Can you help me out ?

homepage:{

(logo)     Goate Electric         [signup/login]      [connect device]   [settings]
______________________________________________________________________________

                       $ZPE balance  |  $ZPP balance |  $ZPW balnce
                                $BTC balance  |  $USD balance  | $PI balance
                                          $GOATE balance  |   $ZGI balance


                                                        [Goate Utilities]
                   [Goate Defi]                       [Goate Entertainment]  
_______________________________________________________________________________________
}


goate utilities page: {
(logo)     Goate Electric         [$username]      [$deviceConnected]   [settings]
______________________________________________________________________________

                       $ZPE balance  |  $ZPP balance |  $ZPW balnce
                                $BTC balance  |  $USD balance  | $PI balance
                                          $GOATE balance  |   $ZGI balance

       [buy Zeropoint]     [buy ZeropointWifi]    [buy ZeropointPhoneService]     [buy ZeropointInsurance]
     
          deviceTab{ handheld, vehicle, home, appliance, accessories }(4 free for each, then $1 per device added)
addDevice(manually||scan)                                     
  deviceCard:{ 
device name:
device battery percentage: add $amount $ZPE
device wifi: add $amount $ZPW
device phone service: add $amount $ZPP
device insurance: on||off }
 ____________________________________________________________________________________________________

}

goate defi page: {
(logo)     Goate Electric         [$username]      [$deviceConnected]   [settings]
______________________________________________________________________________

                       $ZPE balance  |  $ZPP balance |  $ZPW balnce
                                $BTC balance  |  $USD balance  | $PI balance
                                          $GOATE balance  |   $ZGI balance


Zeropoint ($ZPE)   |  $balance |      [buy]  [sell]  [transer]  [deposit]  [stake]  [dualStake] [lend] [borrow]
 ____________________________________________________________________________________________________
ZeropointWifi ($ZPW)  |  $balance |      [buy]  [sell]  [transer]  [deposit]  [stake]  [dualStake] [lend] [borrow]
 ____________________________________________________________________________________________________
ZeropointPhoneService ($ZPP)  |  $balance |      [buy]  [sell]  [transer]  [deposit]  [stake]  [dualStake] [lend] [borrow]
 ____________________________________________________________________________________________________
ZeropointGoateInsurance ($ZGI)  |  $balance |      [buy]  [sell]  [transer]  [deposit]  [stake]  [dualStake] [lend] [borrow]
 ____________________________________________________________________________________________________
TheGoateToken ($GOATE)  |  $balance |      [buy]  [sell]  [transer]  [deposit]  [stake]  [dualStake] [lend] [borrow]
 ____________________________________________________________________________________________________
Bitcoin ($BTC)  |  $balance |      [buy]  [sell]  [transer]  [deposit]  [stake]  [dualStake] [lend] [borrow]
 ____________________________________________________________________________________________________
Pi Network ($Pi)  |  $balance |      [buy]  [sell]  [transer]  [deposit]  [stake]  [dualStake] [lend] [borrow]
 ____________________________________________________________________________________________________
United States Dollar ($USD)  |  $balance |      [buy]  [sell]  [transer]  [deposit]  [stake]  [dualStake] [lend] [borrow]
 ____________________________________________________________________________________________________
*// make sure United States Dollar is connected as it's own payment proccessor coin for bank transactions via zelle, cashapp, paypal, and etc; USDC for erc20, bep20, stellar-network, and etc; and USDT erc20, bep20, and etc; they should have different deposit addresses mapped to the same wallet $balance //*

_______________________________________________________________________________________


}


goate entertainment page: {

(logo)     Goate Electric         [$username]      [$deviceConnected]   [settings]
______________________________________________________________________________

                       $ZPE balance  |  $ZPP balance |  $ZPW balnce
                                $BTC balance  |  $USD balance  | $PI balance
                                          $GOATE balance  |   $ZGI balance

   [CardWars]        [HomeTeamBets]     [GerastyOpol]     [Spades]
         
     [Auction-Off GerastyxOpol PropertyNFT] *//sell//*    [Auction-For GerastyxOpol PropertyNFT] *//buy//*
                  
           
  ____________________________________________________________________________________________________

}



CODE
_____________
https://github.com/cj03nes/GoateElectric/tree/main
_________________________________________________________
https://github.com/cj03nes/GoateElectric/tree/main/contracts%20
_________________________________________________________________
DeviceConnect.sol - // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./InstilledInteroperability.sol";

contract DeviceConnect is Ownable {
    InstilledInteroperability public interoperability;
    uint256 public constant FREE_MODALS = 5;
    uint256 public constant MODAL_COST = 1 * 10**6; // $1 in USDC (6 decimals)
    address public revenueRecipient;

    struct Device {
        string deviceId;
        bool isActive;
        uint256 modalCount;
        uint256 batterCapacity; // Percentage (0-100)
        bool isCharging;
    }


    mapping(address => Device[]) public userDevices;
    mapping(string => bool) public deviceExists;

    event DeviceConnected(address indexed user, string deviceId);
    event DeviceUpdated(address indexed user, string deviceId, uint256 batteryCapacity, bool isCharging);

    constructor(address _interoperability, address initialOwner) Ownable(initialOwner) {
        interoperability = InstilledInteroperability(_interoperability);
    }

    function setRevenueRecipient(address recipient) external onlyOwner {
        revenueRecipient = recipient;
    }

    function connectDevice(string memory deviceId) external {
        userDevices[msg.sender].push(Device(deviceId, true, 0, 100, false));
        emit DeviceConnected(msg.sender, deviceId);
    }

    function updateDeviceStatus(string memory deviceId, uint256 batteryCapacity, bool isCharging) external {
        uint256 index = findDeviceIndex(deviceId);
        Device storage device = userDevices[msg.sender][index];
        device.batteryCapacity = batteryCapacity;
        device.isCharging = isCharging;
        emit DeviceUpdated(msg.sender, deviceId, batteryCapacity, isCharging);
    }

    function findDeviceIndex(string memory deviceId) internal view returns (uint256) {
        for (uint256 i = 0; i < userDevices[msg.sender].length; i++) {
            if (keccak256(abi.encodePacked(userDevices[msg.sender][i].deviceId)) == keccak256(abi.encodePacked(deviceId))) {
                return i;
            }
        }
        revert("Device not found");
    }

    function canProvideEnergy(string memory deviceId) external view returns (bool) {
        uint256 index = findDeviceIndex(deviceId);
        Device memory device = userDevices[msg.sender][index];
        return device.batteryCapacity > 96 && device.isCharging;
    }
}

    function addDevice(string memory deviceId) external {
        require(!deviceExists[deviceId], "Device already exists");
        userDevices[msg.sender].push(Device(deviceId, true, 0));
        deviceExists[deviceId] = true;
    }

    function disconnectDevice(string memory deviceId) external {
        Device[] storage devices = userDevices[msg.sender];
        for (uint256 i = 0; i < devices.length; i++) {
            if (keccak256(bytes(devices[i].deviceId)) == keccak256(bytes(deviceId)) && devices[i].isActive) {
                devices[i].isActive = false;
                return;
            }
        }
        revert("Device not found or already disconnected");
    }

    function useModal(string memory deviceId) external {
        Device[] storage devices = userDevices[msg.sender];
        for (uint256 i = 0; i < devices.length; i++) {
            if (keccak256(bytes(devices[i].deviceId)) == keccak256(bytes(deviceId)) && devices[i].isActive) {
                if (devices[i].modalCount < FREE_MODALS) {
                    devices[i].modalCount++;
                } else {
                    require(revenueRecipient != address(0), "Revenue recipient not set");
                    interoperability.crossChainTransfer(1, 1, "USDC", MODAL_COST, revenueRecipient);
                    devices[i].modalCount++;
                }
                return;
            }
        }
        revert("Active device not found");
    }

    function getUserDevices(address user) external view returns (Device[] memory) {
        return userDevices[user];
    }

    function isDeviceActive(string memory deviceId) external view returns (bool) {
        Device[] memory devices = userDevices[msg.sender];
        for (uint256 i = 0; i < devices.length; i++) {
            if (keccak256(bytes(devices[i].deviceId)) == keccak256(bytes(deviceId))) {
                return devices[i].isActive;
            }
        }
        return false;
    }
}
_____________________________________________________________________________________________________
Zeropoint.sol -
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Zeropoint is ERC20, Ownable {
    constructor() ERC20("Zeropoint", "ZPE") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }

    // Provide energy and reward with $ZPE
    function provideEnergy(address user, uint256 amount) external onlyOwner {
        _mint(user, amount);
    }

    // Consume energy by burning $ZPE
    function consumeEnergy(address user, uint256 amount) external {
        require(balanceOf(user) >= amount, "Insufficient $ZPE");
        _burn(user, amount);
    }
}
____________________________________________________________________________________________________
ZeropointPhoneService.sol -
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Zeropoint is ERC20, Ownable {
    constructor() ERC20("Zeropoint", "ZPE") {
        _mint(msg.sender, 1000000 * 10 ** decimals());
    }

    function mint(address to, uint256 amount) public onlyOwner {
        _mint(to, amount);
    }

    function burn(address from, uint256 amount) public onlyOwner {
        _burn(from, amount);
    }

    // Provide energy and reward with $ZPE
    function provideEnergy(address user, uint256 amount) external onlyOwner {
        _mint(user, amount);
    }

    // Consume energy by burning $ZPE
    function consumeEnergy(address user, uint256 amount) external {
        require(balanceOf(user) >= amount, "Insufficient $ZPE");
        _burn(user, amount);
    }
}
___________________________________________________________________________________________________
ZeropointWifi.sol -
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract ZeropointWifi is ERC20, Ownable {
    constructor(address initialOwner) ERC20("ZeropointWifi", "ZPW") Ownable(initialOwner) {
        _mint(initialOwner, 1000000 * 10**2); // Initial supply: 1M $ZPW with 2 decimals
    }

    function decimals() public view virtual override returns (uint8) {
        return 2;
    }

    function mint(address to, uint256 amount) external onlyOwner {
        _mint(to, amount);
    }

    function burn(uint256 amount) external {
        _burn(msg.sender, amount);
    }
}
________________________________________________________________________________________________________________
TheGoateToken.sol -
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract TheGoateToken is ERC20, Ownable {
    struct UserActivity {
        uint256 adsWatched;
        uint256 energyConsumed;
        uint256 validations;
        uint256 stakedAmount;
        uint256 wifiConsumed;
        uint256 digitalStockHeld;
        uint256 betsMade;
        uint256 gerastyxOpolPlayed;
        uint256 lotteryTicketsBought;
        uint256 gamesPlayed;
    }

    mapping(address => UserActivity) public userActivities;
    mapping(address => uint256) public creditScores;

    event ActivityRecorded(address indexed user, string activity, uint256 value);

    constructor() ERC20("The Goate Token", "GOATE") Ownable(msg.sender) {
        _mint(msg.sender, 1000000 * 10**18);
    }

    function recordActivity(address user, string memory activity, uint256 value) external onlyOwner {
        UserActivity storage ua = userActivities[user];
        if (keccak256(bytes(activity)) == keccak256(bytes("adsWatched"))) ua.adsWatched += value;
        else if (keccak256(bytes(activity)) == keccak256(bytes("energyConsumed"))) ua.energyConsumed += value;
        else if (keccak256(bytes(activity)) == keccak256(bytes("validations"))) ua.validations += value;
        else if (keccak256(bytes(activity)) == keccak256(bytes("stakedAmount"))) ua.stakedAmount += value;
        else if (keccak256(bytes(activity)) == keccak256(bytes("wifiConsumed"))) ua.wifiConsumed += value;
        else if (keccak256(bytes(activity)) == keccak256(bytes("digitalStockHeld"))) ua.digitalStockHeld += value;
        else if (keccak256(bytes(activity)) == keccak256(bytes("betsMade"))) ua.betsMade += value;
        else if (keccak256(bytes(activity)) == keccak256(bytes("gerastyxOpolPlayed"))) ua.gerastyxOpolPlayed += value;
        else if (keccak256(bytes(activity)) == keccak256(bytes("lotteryTicketsBought"))) ua.lotteryTicketsBought += value;
        else if (keccak256(bytes(activity)) == keccak256(bytes("gamesPlayed"))) ua.gamesPlayed += value;
        emit ActivityRecorded(user, activity, value);
        updateCreditScore(user);
    }

    function updateCreditScore(address user) internal {
        UserActivity memory ua = userActivities[user];
        uint256 score = (ua.adsWatched * 10) + (ua.stakedAmount / 1e18 * 50) + (ua.energyConsumed / 1e3 * 20);
        creditScores[user] = score > 1000 ? 1000 : score; // Cap at 1000
    }
}
_______________________________________________________________________________________________________________________
GoatePig.sol -
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./USDMediator.sol";
import "./InstilledInteroperability.sol";

contract GoatePig is ERC20, Ownable {
    USDMediator public usdMediator;
    InstilledInteroperability public interoperability;
    address public cj03nes;
    address public goatePigReserve = 0xGoatePigReserve; // #!GoatePig
    IERC20 public piToken;

    constructor(address _usdMediator, address _interoperability, address _piToken, address _cj03nes, address initialOwner)
        ERC20("GoatePig", "GP")
        Ownable(initialOwner)
    {
        usdMediator = USDMediator(_usdMediator);
        interoperability = InstilledInteroperability(_interoperability);
        piToken = IERC20(_piToken);
        cj03nes = _cj03nes;
    }

    function buyPiToken(uint256 amount) external {
        require(msg.sender == cj03nes || msg.sender == address(interoperability) || msg.sender == address(usdMediator), "Unauthorized");
        uint256 cj03nesShare = (amount * 50) / 100;
        uint256 iiShare = (amount * 20) / 100;
        uint256 usdMediatorShare = (amount * 20) / 100;
        uint256 goatePigShare = (amount * 10) / 100;

        piToken.transferFrom(cj03nes, goatePigReserve, cj03nesShare);
        piToken.transferFrom(address(interoperability), goatePigReserve, iiShare);
        piToken.transferFrom(address(usdMediator), goatePigReserve, usdMediatorShare);
        piToken.transferFrom(goatePigReserve, goatePigReserve, goatePigShare);

        _mint(goatePigReserve, amount);
    }

    function switchToReserves() external {
        require(msg.sender == cj03nes || msg.sender == address(interoperability) || msg.sender == address(usdMediator), "Unauthorized");
        uint256 amount = balanceOf(goatePigReserve) / 4; // 25%
        _burn(goatePigReserve, amount);
        // Swap to reserve assets (handled by USDMediator/InstilledInteroperability)
        usdMediator.switchToReserves();
    }
}
____________________________________________________________________________________________________________________
GoateStaking -
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./USDMediator.sol";
import "./InstilledInteroperability.sol";

contract GoateStaking is Ownable {
    USDMediator public usdMediator;
    InstilledInteroperability public interoperability;
    address public cj03nes;
    address public goatePigReserve = 0xGoatePigReserve;

    struct Stake {
        address user;
        string asset;
        uint256 amount;
        uint256 startTime;
        uint256 duration;
        uint256 usdValue;
        bool active;
        uint256[] nftIds; // For GerastyxPropertyNFT
    }

    mapping(uint256 => Stake) public stakes;
    uint256 public stakeCounter;
    mapping(string => string[]) public stakingAssets;

    constructor(address _usdMediator, address _interoperability, address _cj03nes, address initialOwner)
        Ownable(initialOwner)
    {
        usdMediator = USDMediator(_usdMediator);
        interoperability = InstilledInteroperability(_interoperability);
        cj03nes = _cj03nes;
        initializeStakingAssets();
    }

    function initializeStakingAssets() internal {
        stakingAssets["USD"] = ["yXLM", "yBTC", "yUSD"];
        stakingAssets["PI"] = ["WFM", "WMT", "SFM"];
        stakingAssets["ZPE"] = ["DLR", "O", "BITF"];
        stakingAssets["ZPP"] = ["VZ", "T", "DIS"];
        stakingAssets["ZPW"] = ["yXLM", "yBTC", "yUSD"];
        stakingAssets["ZHV"] = ["XLM", "yXLM", "GDX"];
        stakingAssets["GySt"] = ["yUSD", "SHW", "USGO"];
        stakingAssets["GOATE"] = ["yXLM", "yBTC", "yUSD"];
        stakingAssets["GP"] = ["yXLM", "AQUA", "yUSD"];
        stakingAssets["SD"] = ["yXLM", "AQUA", "yUSD"];
        stakingAssets["GerastyxPropertyNFT"] = ["yXLM", "yBTC", "yUSD"];
    }

    function stakeAsset(string memory asset, uint256 amount, uint256 durationDays, uint256[] memory nftIds) external {
        require(durationDays >= 30 && durationDays <= 365, "Invalid duration");
        uint256 stakeId = stakeCounter++;
        uint256 duration = durationDays * 1 days;

        interoperability.activeBalances[msg.sender][asset] -= amount;
        interoperability.stakingBalances[msg.sender][asset] += amount / 2;

        uint256 swapAmount = amount / 2;
        string[] memory designatedAssets = stakingAssets[asset];
        for (uint256 i = 0; i < designatedAssets.length; i++) {
            interoperability.quantumSwap(1, 1, asset, designatedAssets[i], swapAmount / designatedAssets.length, msg.sender, address(this));
        }

        uint256 usdValue = interoperability.convertAmount(asset, "USD", amount);
        stakes[stakeId] = Stake(msg.sender, asset, amount, block.timestamp, duration, usdValue, true, nftIds);
        emit Staked(stakeId, msg.sender, asset, amount, duration);
    }

    function calculateAPR(string memory asset, uint256 amount) public view returns (uint256) {
        uint256 apr = 10; // 10% APR (mock)
        uint256 monthlyReturn = (amount * apr) / (12 * 100);
        uint256 revenueDeduction = (monthlyReturn * 25) / 100; // 25% to revenue
        return (monthlyReturn - revenueDeduction) * 100 / amount; // Adjusted APR
    }

    event Staked(uint256 indexed stakeId, address indexed user, string asset, uint256 amount, uint256 duration);
}
__________________________________________________________________________________________________________________________
TokenPairStaking.sol -
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./USDMediator.sol";
import "./InstilledInteroperability.sol";

contract TokenPairStaking is Ownable {
    USDMediator public usdMediator;
    InstilledInteroperability public interoperability;
    address public cj03nes;
    address public goatePigReserve = 0xGoatePigReserve;

    struct Stake {
        address user;
        string asset1;
        string asset2;
        uint256 amount1;
        uint256 amount2;
        uint256 startTime;
        uint256 duration;
        uint256 usdValue;
        bool active;
    }

    mapping(uint256 => Stake) public stakes;
    uint256 public stakeCounter;
    mapping(string => mapping(string => string[])) public stakingPairs;

    constructor(address _usdMediator, address _interoperability, address _cj03nes, address initialOwner)
        Ownable(initialOwner)
    {
        usdMediator = USDMediator(_usdMediator);
        interoperability = InstilledInteroperability(_interoperability);
        cj03nes = _cj03nes;
        initializePairs();
    }

    function initializePairs() internal {
        stakingPairs["DOGE"]["SHIB"] = ["AQUA", "yXLM", "yUSD"];
        stakingPairs["TON"]["PI"] = ["WFM", "WMT", "SFM"];
        stakingPairs["GP"]["GySt"] = ["yXLM", "yBTC", "yUSD"];
        stakingPairs["VVS"]["CRO"] = ["XLM", "yXLM", "GDX"];
        stakingPairs["XLM"]["BTC"] = ["yXLM", "yBTC", "yUSD"];
        stakingPairs["USD"]["GOATE"] = ["yXLM", "yBTC", "yUSD"];
        stakingPairs["PYUSD"]["ZPE"] = ["yXLM", "yBTC", "yUSD"];
        // Add more pairs for GerastyxPropertyNFT
    }

    function stakeTokens(
        string memory asset1,
        string memory asset2,
        uint256 amount1,
        uint256 amount2,
        uint256 durationDays
    ) external {
        require(durationDays >= 30 && durationDays <= 365, "Invalid duration");
        uint256 stakeId = stakeCounter++;
        uint256 duration = durationDays * 1 days;

        interoperability.activeBalances[msg.sender][asset1] -= amount1;
        interoperability.activeBalances[msg.sender][asset2] -= amount2;
        interoperability.stakingBalances[msg.sender][asset1] += amount1 / 2;
        interoperability.stakingBalances[msg.sender][asset2] += amount2 / 2;

        uint256 swapAmount1 = amount1 / 2;
        uint256 swapAmount2 = amount2 / 2;
        string[] memory designatedAssets = stakingPairs[asset1][asset2];
        for (uint256 i = 0; i < designatedAssets.length; i++) {
            interoperability.quantumSwap(1, 1, asset1, designatedAssets[i], swapAmount1 / designatedAssets.length, msg.sender, address(this));
            interoperability.quantumSwap(1, 1, asset2, designatedAssets[i], swapAmount2 / designatedAssets.length, msg.sender, address(this));
        }

        uint256 usdValue = calculateUSDValue(asset1, asset2, amount1, amount2);
        stakes[stakeId] = Stake(msg.sender, asset1, asset2, amount1, amount2, block.timestamp, duration, usdValue, true);
        emit Staked(stakeId, msg.sender, asset1, asset2, amount1, amount2, duration);
    }

    function calculateUSDValue(string memory asset1, string memory asset2, uint256 amount1, uint256 amount2) internal view returns (uint256) {
        uint256 price1 = interoperability.assetPrices[asset1].aggregatedPrice;
        uint256 price2 = interoperability.assetPrices[asset2].aggregatedPrice;
        return (amount1 * price1 + amount2 * price2) / 10**6;
    }

    function withdrawStake(uint256 stakeId) external {
        Stake storage stake = stakes[stakeId];
        require(stake.user == msg.sender, "Not staker");
        require(stake.active, "Stake not active");
        require(block.timestamp >= stake.startTime + stake.duration, "Stake not matured");

        stake.active = false;
        interoperability.activeBalances[msg.sender][stake.asset1] += stake.amount1 / 2;
        interoperability.activeBalances[msg.sender][stake.asset2] += stake.amount2 / 2;

        string[] memory designatedAssets = stakingPairs[stake.asset1][stake.asset2];
        for (uint256 i = 0; i < designatedAssets.length; i++) {
            uint256 amount = interoperability.stakingBalances[msg.sender][designatedAssets[i]];
            interoperability.quantumSwap(1, 1, designatedAssets[i], stake.asset1, amount / 2, address(this), msg.sender);
            interoperability.quantumSwap(1, 1, designatedAssets[i], stake.asset2, amount / 2, address(this), msg.sender);
        }

        uint256 dividends = calculateDividends(stakeId);
        distributeDividends(stake.user, stake.asset1, stake.asset2, dividends);
    }

    function calculateDividends(uint256 stakeId) internal view returns (uint256) {
        Stake storage stake = stakes[stakeId];
        uint256 apr = 10; // 10% APR (mock)
        uint256 usdValue = stake.usdValue;
        uint256 durationInDays = stake.duration / 1 days;
        return (usdValue * apr * durationInDays) / (365 * 100);
    }

    function distributeDividends(address user, string memory asset1, string memory asset2, uint256 amount) internal {
        uint256 userShare1 = (amount * 25) / 100;
        uint256 userShare2 = (amount * 25) / 100;
        uint256 designatedShare = (amount * 25) / 100;
        uint256 revenueShare = (amount * 25) / 100;

        interoperability.activeBalances[user][asset1] += userShare1;
        interoperability.activeBalances[user][asset2] += userShare2;
        // Swap designated share to asset1/asset2 (mocked)
        interoperability.activeBalances[user][asset1] += designatedShare / 2;
        interoperability.activeBalances[user][asset2] += designatedShare / 2;

        uint256 cj03nesShare = (revenueShare * 50) / 100;
        uint256 iiShare = (revenueShare * 20) / 100;
        uint256 usdMediatorShare = (revenueShare * 20) / 100;
        uint256 goatePigShare = (revenueShare * 10) / 100;
        usdMediator.transferUSD(cj03nes, cj03nesShare);
        usdMediator.transferUSD(address(interoperability), iiShare);
        usdMediator.transferUSD(address(usdMediator), usdMediatorShare);
        usdMediator.transferUSD(goatePigReserve, goatePigShare);
    }

    event Staked(uint256 indexed stakeId, address indexed user, string asset1, string asset2, uint256 amount1, uint256 amount2, uint256 duration);
}
________________________________________________________________________________________________________________________________________
ZeropointDigitalStockNFT.sol - // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./USDMediator.sol";
import "./InstilledInteroperability.sol";

contract ZeropointDigitalStockNFT is ERC721, Ownable {
    USDMediator public usdMediator;
    InstilledInteroperability public interoperability;
    uint256 public tokenCounter;
    mapping(uint256 => string) public stockSymbols;
    mapping(uint256 => uint256) public totalInvested;
    mapping(uint256 => mapping(address => uint256)) public userInvestments;
    mapping(uint256 => uint256) public dividendPool;

    event StockPurchased(uint256 tokenId, address buyer, uint256 amount);
    event StockSold(uint256 tokenId, address seller, uint256 amount);
    event DividendDistributed(uint256 tokenId, uint256 amount);

    constructor(address _usdMediator, address _interoperability) ERC721("ZeropointDigitalStockNFT", "ZDSNFT") Ownable(msg.sender) {
        usdMediator = USDMediator(_usdMediator);
        interoperability = InstilledInteroperability(_interoperability);
    }

    function mintStock(address to, string memory stockSymbol) external onlyOwner {
        uint256 tokenId = tokenCounter;
        _mint(to, tokenId);
        stockSymbols[tokenId] = stockSymbol;
        tokenCounter++;
    }

    function buyStock(uint256 tokenId, uint256 amount, uint256 chainId) external {
        require(_exists(tokenId), "Stock does not exist");
        require(amount >= 1e6, "Minimum $1 USD");

        IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        require(usdc.transferFrom(msg.sender, address(usdMediator), amount), "Transfer failed");
        usdMediator.buyStock(stockSymbols[tokenId], amount);

        if (balanceOf(msg.sender) == 0 || ownerOf(tokenId) != msg.sender) {
            _safeTransfer(address(this), msg.sender, tokenId, "");
        }
        totalInvested[tokenId] += amount;
        userInvestments[tokenId][msg.sender] += amount;

        if (chainId != block.chainid) {
            interoperability.crossChainTransfer(block.chainid, chainId, "ZDSNFT", amount, msg.sender);
        }

        emit StockPurchased(tokenId, msg.sender, amount);
    }

    function sellStock(uint256 tokenId, uint256 amount, string memory toAsset, uint256 chainId) external {
        require(ownerOf(tokenId) == msg.sender, "Not owner");
        uint256 userInvestment = userInvestments[tokenId][msg.sender];
        require(amount <= userInvestment, "Insufficient balance");

        uint256 proRata = (userInvestment * 1e18) / totalInvested[tokenId];
        uint256 saleAmount = (proRata * amount) / 1e18;

        usdMediator.sellStock(stockSymbols[tokenId], saleAmount, toAsset, msg.sender);

        totalInvested[tokenId] -= saleAmount;
        userInvestments[tokenId][msg.sender] -= saleAmount;
        if (userInvestments[tokenId][msg.sender] == 0) {
            _safeTransfer(msg.sender, address(this), tokenId, "");
        }

        emit StockSold(tokenId, msg.sender, saleAmount);
    }

    function distributeDividends(uint256 tokenId, uint256 amount) external onlyOwner {
        dividendPool[tokenId] += amount;
        for (uint256 i = 0; i < balanceOf(msg.sender); i++) {
            address holder = ownerOf(tokenId);
            uint256 proRata = (userInvestments[tokenId][holder] * 1e18) / totalInvested[tokenId];
            uint256 dividend = (proRata * amount) / 1e18;
            usdMediator.transferUSD(holder, dividend);
            emit DividendDistributed(tokenId, dividend);
        }
    }
__________________________________________________________________________________________________________________________
p2pLendingAndBorrowing.sol -// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./USDMediator.sol";
import "./InstilledInteroperability.sol";

contract Lending {
    USDMediator public usdMediator;
    InstilledInteroperability public interoperability;
    address public owner;
    string public plaidAPI = "https://api.plaid.com";

    uint256 public borrowPool;
    mapping(address => uint256) public loans;
    mapping(address => uint256) public loanDueDates;
    mapping(address => uint256) public creditScores;

    string[] public stockList = [
        "WMT", "KMB", "MO", "WPC", "CSCO", "T", "BX", "AAPL", "CAT", "SPG",
        "LMT", "AVY", "MCD", "TGT", "TTWO", "DIS", "BAC", "BBY", "MGY", "NKE"
    ];

    event Lent(address indexed user, uint256 amount);
    event Borrowed(address indexed user, uint256 amount);
    event Repaid(address indexed user, uint256 amount);

    constructor(address _usdMediator, address _interoperability) {
        owner = msg.sender;
        usdMediator = USDMediator(_usdMediator);
        interoperability = InstilledInteroperability(_interoperability);
    }

    function lend(uint256 amount) external {
        require(amount >= 1e6, "Minimum $1 USD");
        IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        require(usdc.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        uint256 perStock = amount / 20;
        for (uint256 i = 0; i < stockList.length; i++) {
            usdMediator.buyStock(stockList[i], perStock);
        }
        borrowPool += amount;
        emit Lent(msg.sender, amount);
    }

    function borrow(uint256 amount) external {
        uint256 creditScore = getCreditScore(msg.sender);
        uint256 ecosystemSize = 1000; // Placeholder
        uint256 maxLoan = (creditScore * borrowPool) / (1000 * ecosystemSize);
        require(amount <= maxLoan, "Exceeds loan limit");
        require(loans[msg.sender] == 0, "Existing loan pending");
        require(borrowPool >= amount, "Insufficient pool");

        borrowPool -= amount;
        loans[msg.sender] = amount;
        loanDueDates[msg.sender] = block.timestamp + 30 days;
        usdMediator.transferUSD(msg.sender, amount);
        emit Borrowed(msg.sender, amount);
    }

    function repay(uint256 amount) external {
        require(loans[msg.sender] >= amount, "Invalid amount");
        IERC20 usdc = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
        require(usdc.transferFrom(msg.sender, address(this), amount), "Transfer failed");

        loans[msg.sender] -= amount;
        borrowPool += amount;
        if (loans[msg.sender] == 0) loanDueDates[msg.sender] = 0;
        emit Repaid(msg.sender, amount);
    }

    function handleDefault(address user) external {
        require(loanDueDates[user] != 0 && block.timestamp > loanDueDates[user], "Not defaulted");
        uint256 debt = loans[user];
        usdMediator.stakeDebt(user, debt);
        loans[user] = 0;
        loanDueDates[user] = 0;
    }

    function getCreditScore(address user) internal returns (uint256) {
        if (creditScores[user] == 0) {
            creditScores[user] = 700; // Default, updated off-chain via Plaid
        }
        return creditScores[user];
    }
}cj
_______________________________________________________________________________________________________________
InstilledInteroperability.sol - // SPDX-License-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./TheGoateToken.sol";

contract QuantumInstilledInteroperability {
    address public owner;
    TheGoateToken public goateToken;
    mapping(uint256 => mapping(string => address)) public tokenMap;
    mapping(string => string) public tradingAPIs;
    mapping(string => string) public sportsDataAPIs;
    mapping(string => string) public streamingAPIs;
    mapping(address => mapping(string => uint256)) public activeBalances;
    mapping(address => mapping(string => uint256)) public reserveBalances;
    mapping(address => mapping(string => uint256)) public stakingBalances;
    string[] public supportedAssets = [
        "USDC", "ZPE", "ZPW", "ZPP", "GySt", "GOATE", "ZHV", "SD", "ZGI", "GP", "zS",
        "AQUA", "XLM", "yUSD", "yXLM", "yBTC", "WFM", "TTWO", "BBY", "SFM", "DOLE",
        "WMT", "AAPL", "T", "VZ", "VVS", "CRO", "PYUSD"
    ];
    address public goatePigReserve;

    struct PriceData {
        uint256 contractPrice;
        uint256 coinMarketCapPrice;
        uint256 coinGeckoPrice;
        uint256 aggregatedPrice;
    }
    mapping(string => PriceData) public assetPrices;

    event QuantumTransaction(address indexed sender, address indexed recipient, string fromAsset, string toAsset, uint256 amount, uint256 convertedAmount);
    event ArbitrageDetected(string asset, uint256 arbitrage);
    event DeviceDataSynced(string deviceId, address user, uint256 dataPoints);

    constructor(address _goateToken, address _goatePigReserve) {
        owner = msg.sender;
        goateToken = TheGoateToken(_goateToken);
        goatePigReserve = _goatePigReserve;
        initializeAPIs();
    }

    function initializeAPIs() internal {
        // Trading APIs
        tradingAPIs["uniswap"] = "https://api.uniswap.org/v1";
        tradingAPIs["pancakeswap"] = "https://api.pancakeswap.info/api/v2";
        tradingAPIs["cryptocom"] = "https://api.crypto.com/v2";
        tradingAPIs["1inch"] = "https://api.1inch.exchange/v3.0";
        tradingAPIs["okx"] = "https://www.okx.com/api/v5";
        tradingAPIs["dydx"] = "https://api.dydx.exchange/v3";
        tradingAPIs["sushiswap"] = "https://api.sushiswap.fi/v1";
        tradingAPIs["curve"] = "https://api.curve.fi/v1";
        tradingAPIs["balancer"] = "https://api.balancer.fi/v1";
        tradingAPIs["mastercard"] = "https://api.mastercard.com/v1";
        tradingAPIs["visa"] = "https://api.visa.com/v1";
        tradingAPIs["zelle"] = "https://api.zellepay.com/v1";
        tradingAPIs["stripe"] = "https://api.stripe.com/v1";
        tradingAPIs["plaid"] = "https://api.plaid.com/v1";

        // Streaming APIs
        streamingAPIs["luxplayer"] = "https://api.luxplayer.com/v1";
        streamingAPIs["netflix"] = "https://api.netflix.com/v1";
        streamingAPIs["flixtor"] = "https://api.flixtor.to/v1";
        streamingAPIs["disneyplus"] = "https://api.disneyplus.com/v1";
        streamingAPIs["peacock"] = "https://api.peacock.com/v1";
        streamingAPIs["hulu"] = "https://api.hulu.com/v1";
    }

    function updatePrice(string memory asset) external {
        require(isSupportedAsset(asset), "Unsupported asset");
        uint256 contractPrice = fetchContractPrice(asset);
        uint256 cmcPrice = fetchCoinMarketCapPrice(asset);
        uint256 cgPrice = fetchCoinGeckoPrice(asset);
        uint256 aggregated = (contractPrice + cmcPrice + cgPrice) / 3;
        assetPrices[asset] = PriceData(contractPrice, cmcPrice, cgPrice, aggregated);
    }

    function quantumProportioning(string memory asset, uint256 amount) public view returns (uint256 usdDenomination, uint256 arbitrageOpportunity) {
        uint256 aggregatedPrice = assetPrices[asset].aggregatedPrice;
        usdDenomination = (amount * aggregatedPrice) / 10**6;

        uint256 marketCap = fetchMarketCap(asset);
        uint256 circulatingSupply = fetchCirculatingSupply(asset);
        uint256 proportion = (marketCap * 10**6) / circulatingSupply;
        arbitrageOpportunity = aggregatedPrice > proportion ? aggregatedPrice - proportion : 0;
    }

    function fetchMarketCap(string memory asset) internal pure returns (uint256) {
        return 1000000 * 10**6; // Mock
    }

    function fetchCirculatingSupply(string memory asset) internal pure returns (uint256) {
        return 1000000; // Mock
    }

    function fetchContractPrice(string memory asset) internal pure returns (uint256) {
        return 100 * 10**6; // $100 (mock)
    }

    function fetchCoinMarketCapPrice(string memory asset) internal pure returns (uint256) {
        return 105 * 10**6; // $105 (mock)
    }

    function fetchCoinGeckoPrice(string memory asset) internal pure returns (uint256) {
        return 110 * 10**6; // $110 (mock)
    }

    function quantumSwap(
        uint256 fromChain,
        uint256 toChain,
        string memory fromAsset,
        string memory toAsset,
        uint256 amount,
        address sender,
        address recipient
    ) external {
        require(isSupportedAsset(fromAsset) && isSupportedAsset(toAsset), "Unsupported asset");
        require(activeBalances[sender][fromAsset] >= amount, "Insufficient balance");
        require(amount >= 0.01 * 10**6, "Minimum transaction amount is $0.01");

        activeBalances[sender][fromAsset] -= amount;
        uint256 convertedAmount = convertAmount(fromAsset, toAsset, amount);
        activeBalances[recipient][toAsset] += convertedAmount;

        emit QuantumTransaction(sender, recipient, fromAsset, toAsset, amount, convertedAmount);
    }

    function convertAmount(string memory fromAsset, string memory toAsset, uint256 amount) public view returns (uint256) {
        uint256 fromPrice = assetPrices[fromAsset].aggregatedPrice;
        uint256 toPrice = assetPrices[toAsset].aggregatedPrice;
        require(fromPrice > 0 && toPrice > 0, "Price not available");
        return (amount * fromPrice) / toPrice;
    }

    function updateBalance(address user, string memory asset, uint256 newBalance) external {
        require(msg.sender == owner || msg.sender == address(this), "Unauthorized");
        require(isSupportedAsset(asset), "Unsupported asset");
        activeBalances[user][asset] = newBalance;
    }

    function switchToReserves() external {
        require(msg.sender == owner || msg.sender == address(this), "Unauthorized");
        for (uint256 i = 0; i < supportedAssets.length; i++) {
            string memory asset = supportedAssets[i];
            uint256 amount = activeBalances[address(this)][asset] / 4; // 25%
            activeBalances[address(this)][asset] -= amount;
            reserveBalances[address(this)][asset] += amount;
        }
    }

    function isSupportedAsset(string memory asset) internal view returns (bool) {
        for (uint256 i = 0; i < supportedAssets.length; i++) {
            if (keccak256(bytes(asset)) == keccak256(bytes(supportedAssets[i]))) {
                return true;
            }
        }
        return false;
    }

    // QuantumZeropointDataStorage: Mock device data syncing
    function syncDeviceData(string memory deviceId, address user) external {
        emit DeviceDataSynced(deviceId, user, 800_000_000);
    }
}
_________________________________________________________________________________________________
PayWithCrypto.sol - // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./USDMediator.sol";
import "./QuantumInstilledInteroperability.sol";
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
        // Align supported assets with QuantumInstilledInteroperability
        supportedAssets = [
            "USDC", "ZPE", "ZPW", "ZPP", "GySt", "GOATE", "ZHV", "SD", "ZGI", "GP", "zS",
            "AQUA", "XLM", "yUSD", "yXLM", "yBTC", "WFM", "TTWO", "BBY", "SFM", "DOLE",
            "WMT", "AAPL", "T", "VZ", "VVS", "CRO", "PYUSD"
        ];
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
        uint256 totalBalance = 0;
        for (uint256 i = 0; i < supportedAssets.length; i++) {
            string memory asset = supportedAssets[i];
            if (useForCardPayment[user][asset]) {
                uint256 balance = interoperability.activeBalances(user, asset);
                if (balance > 0) {
                    totalBalance += interoperability.convertAmount(asset, "USDC", balance);
                }
            }
        }
        return totalBalance;
    }

    // Process payment by deducting from available balances
    function processPayment(address user, uint256 amount) internal {
        uint256 remaining = amount;
        if (interoperability.activeBalances(user, "USDC") >= remaining) {
            interoperability.updateBalance(user, "USDC", interoperability.activeBalances(user, "USDC") - remaining);
            remaining = 0;
        } else {
            remaining -= interoperability.activeBalances(user, "USDC");
            interoperability.updateBalance(user, "USDC", 0);
            for (uint256 i = 0; i < supportedAssets.length && remaining > 0; i++) {
                string memory asset = supportedAssets[i];
                if (useForCardPayment[user][asset]) {
                    uint256 assetBalance = interoperability.activeBalances(user, asset);
                    if (assetBalance > 0) {
                        uint256 assetAmountInUSDC = interoperability.convertAmount(asset, "USDC", assetBalance);
                        if (assetAmountInUSDC >= remaining) {
                            uint256 assetAmountNeeded = interoperability.convertAmount("USDC", asset, remaining);
                            interoperability.updateBalance(user, asset, assetBalance - assetAmountNeeded);
                            remaining = 0;
                        } else {
                            remaining -= assetAmountInUSDC;
                            interoperability.updateBalance(user, asset, 0);
                        }
                    }
                }
            }
        }
        require(remaining == 0, "Insufficient funds after processing");
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
        require(interoperability.isSupportedAsset(asset), "Unsupported asset");
        useForCardPayment[user][asset] = enabled;
    }
}
__________________________________________________________________________________________________________
TheGoateCard.sol - // SPDX-License-Identifier: MIT
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
_______________________________________________________________________________________________
USDMediator.sol - // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";

contract USDMediator is Ownable {
    address public paymentProcessor; // Represents Banxa, MoonPay, etc.
    address public revenueOwner; // e.g., cj03nes address
    address public reserve; // Reserve address for 15%
    uint256 public constant OWNER_SHARE = 80; // 80% to owner
    uint256 public constant RESERVE_SHARE = 15; // 15% to reserve
    uint256 public constant MEDIATOR_SHARE = 5; // 5% to mediator

    event USDTransferred(address indexed recipient, uint256 amount);
    event RevenueDistributed(address indexed recipient, uint256 amount, string category);

    constructor(address _paymentProcessor, address _revenueOwner, address _reserve) Ownable(msg.sender) {
        paymentProcessor = _paymentProcessor;
        revenueOwner = _revenueOwner;
        reserve = _reserve;
    }

    function transferUSD(address recipient, uint256 amount) external {
        require(recipient != address(0), "Invalid recipient");
        require(amount > 0, "Amount must be greater than 0");

        // Distribute revenue
        uint256 ownerAmount = (amount * OWNER_SHARE) / 100;
        uint256 reserveAmount = (amount * RESERVE_SHARE) / 100;
        uint256 mediatorAmount = (amount * MEDIATOR_SHARE) / 100;

        // Simulate transfers (replace with actual token/asset transfers)
        emit RevenueDistributed(revenueOwner, ownerAmount, "Owner");
        emit RevenueDistributed(reserve, reserveAmount, "Reserve");
        emit RevenueDistributed(paymentProcessor, mediatorAmount, "Mediator");

        // Final transfer to recipient
        emit USDTransferred(recipient, amount);
    }

    function updatePaymentProcessor(address _newProcessor) external onlyOwner {
        paymentProcessor = _newProcessor;
    }
}
____________________________________________________________________________________________________
GhostGoate.sol - // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "./USDMediator.sol";
import "./InstilledInteroperability.sol";
cj03nes = $PI Address: GBMWQWG7XFTIIYRH7HMVDKBQGSNIGQ2UGJU3SY4LYCADB4JTH2DPO2FY;

contract GhostGoate is Ownable {
    USDMediator public usdMediator;
    InstilledInteroperability public interoperability;
    address public cj03nes;
    address public goatePigReserve = 0xGoatePigReserve;

    struct DeviceLocation {
        address user;
        string latitude;
        string longitude;
        uint256 timestamp;
    }

    mapping(uint256 => DeviceLocation) public deviceLocations;
    uint256 public locationCounter;
    mapping(address => uint256) public nodeRewards;
    mapping(string => uint256) public assetConsumptionRevenue;

    constructor(address _usdMediator, address _interoperability, address _cj03nes, address initialOwner)
        Ownable(initialOwner)
    {
        usdMediator = USDMediator(_usdMediator);
        interoperability = InstilledInteroperability(_interoperability);
        cj03nes = _cj03nes;
    }

    function updateDeviceLocation(address user, string memory latitude, string memory longitude) external {
        require(msg.sender == cj03nes, "Unauthorized");
        deviceLocations[locationCounter] = DeviceLocation(user, latitude, longitude, block.timestamp);
        locationCounter++;
    }

    function getBalances() external view returns (uint256 cj03nesBalance, uint256 iiBalance, uint256 usdMediatorBalance, uint256 goatePigBalance) {
        require(msg.sender == cj03nes, "Unauthorized");
        cj03nesBalance = interoperability.activeBalances[cj03nes]["USD"];
        iiBalance = interoperability.activeBalances[address(interoperability)]["USD"];
        usdMediatorBalance = interoperability.activeBalances[address(usdMediator)]["USD"];
        goatePigBalance = interoperability.activeBalances[goatePigReserve]["USD"];
    }
}
________________________________________________________________________________________________
ZeropointInsurance.sol - 
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
_____________________________________________________________________________________
ZeropointShield.sol - // SPDX-License-Identifier: MIT
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
___________________________________________________________________________________________
CardWars.sol - // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";

contract War is VRFConsumerBase {
    // Constants
    uint8 constant MIN_PLAYERS = 4;
    uint8 constant MAX_PLAYERS = 8;
    uint8 constant TOTAL_CARDS = 52;

    // Game state
    address[] public players;            // List of player addresses
    uint8 public numPlayers;             // Number of players in the session
    uint8 public firstDealer;            // Index of the first player to receive a card
    mapping(address => uint8[]) public hands;  // Each player's hand of cards
    uint8[] public currentRoundCards;    // Cards played in the current round
    uint256 public randomResult;         // Randomness from Chainlink VRF
    bool public gameOver;                // Tracks if the game has ended
    address public winner;               // Winner of the game

    // Chainlink VRF configuration
    bytes32 internal keyHash;
    uint256 internal fee;

    // Events for Unreal Engine integration
    event RoundWinner(address winner, uint8 cardsWon);
    event GameEnded(address winner);

    // Constructor: Initialize players and Chainlink VRF
    constructor(
        address[] memory _players,
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        uint256 _fee
    ) VRFConsumerBase(_vrfCoordinator, _link) {
        require(_players.length >= MIN_PLAYERS && _players.length <= MAX_PLAYERS, "Invalid number of players");
        players = _players;
        numPlayers = uint8(_players.length);
        keyHash = _keyHash;
        fee = _fee;
        gameOver = false;
    }

    // Start the game by requesting randomness from Chainlink
    function startGame() public {
        require(!gameOver, "Game is over");
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK for VRF");
        requestRandomness(keyHash, fee);
    }

    // Chainlink callback: Use randomness to shuffle and deal cards
    function fulfillRandomness(bytes32, uint256 randomness) internal override {
        randomResult = randomness;

        // Randomly select the first player to receive a card
        firstDealer = uint8(randomness % numPlayers);

        // Initialize the deck (0-51 representing 52 cards)
        uint8[52] memory deck;
        for (uint8 i = 0; i < TOTAL_CARDS; i++) {
            deck[i] = i;
        }

        // Shuffle the deck using Fisher-Yates algorithm
        for (uint8 i = 51; i > 0; i--) {
            uint8 j = uint8(uint256(keccak256(abi.encode(randomness, i))) % (i + 1));
            (deck[i], deck[j]) = (deck[j], deck[i]);
        }

        // Deal cards counterclockwise starting from firstDealer
        uint8 currentPlayer = firstDealer;
        for (uint8 i = 0; i < TOTAL_CARDS; i++) {
            hands[players[currentPlayer]].push(deck[i]);
            currentPlayer = (currentPlayer + numPlayers - 1) % numPlayers; // Counterclockwise
        }
    }

    // Play a round of War
    function playRound() public {
        require(!gameOver, "Game is over");
        require(currentRoundCards.length == 0, "Round already in progress");

        // Each player plays their top card
        for (uint8 i = 0; i < numPlayers; i++) {
            address player = players[i];
            require(hands[player].length > 0, "Player has no cards");
            uint8 card = hands[player][0];
            removeCardFromHand(player, 0);
            currentRoundCards.push(card);
        }

        // Find the highest card and determine the winner(s)
        uint8 highestRank = 0;
        uint8[] memory winners;
        for (uint8 i = 0; i < numPlayers; i++) {
            uint8 rank = getRank(currentRoundCards[i]);
            if (rank > highestRank) {
                highestRank = rank;
                delete winners;
                winners = new uint8[](1);
                winners[0] = i;
            } else if (rank == highestRank) {
                winners.push(i);
            }
        }

        if (winners.length == 1) {
            // Single winner takes all cards
            address roundWinner = players[winners[0]];
            for (uint8 i = 0; i < numPlayers; i++) {
                hands[roundWinner].push(currentRoundCards[i]);
            }
            emit RoundWinner(roundWinner, numPlayers);
        } else {
            // Tie: Trigger a simplified war
            startWar(winners);
        }

        // Clear the round cards
        delete currentRoundCards;

        // Check if the game is over
        for (uint8 i = 0; i < numPlayers; i++) {
            if (hands[players[i]].length == TOTAL_CARDS) {
                gameOver = true;
                winner = players[i];
                emit GameEnded(winner);
                break;
            }
        }
    }

    // Simplified war resolution (random winner for brevity)
    function startWar(uint8[] memory tiedPlayers) internal {
        // In a full implementation, tied players would play additional cards
        // Here, we randomly select a winner among tied players
        uint8 randomIndex = uint8(uint256(keccak256(abi.encode(randomResult, block.timestamp))) % tiedPlayers.length);
        address warWinner = players[tiedPlayers[randomIndex]];
        for (uint8 i = 0; i < numPlayers; i++) {
            hands[warWinner].push(currentRoundCards[i]);
        }
        emit RoundWinner(warWinner, numPlayers);
    }

    // Helper: Get card rank (0=2, ..., 11=King, 12=Ace)
    function getRank(uint8 card) public pure returns (uint8) {
        return card % 13;
    }

    // Helper: Remove a card from a player's hand
    function removeCardFromHand(address player, uint8 index) internal {
        uint8[] storage hand = hands[player];
        require(index < hand.length, "Invalid card index");
        for (uint8 i = index; i < hand.length - 1; i++) {
            hand[i] = hand[i + 1];
        }
        hand.pop();
    }
}
__________________________________________________________________________
HomeTeamBets.sol - // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "./InstilledInteroperability.sol";
import "./USDMediator.sol";

contract HomeTeamBets {
    InstilledInteroperability public interoperability;
    USDMediator public usdMediator;
    IERC20 public usdcToken = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public owner;
    uint256 public totalRevenue;

    enum BetType { Win, Lose, Tie }

    struct Bet {
        address bettor;
        uint256 amount;
        BetType betType;
        bool overtime;
        uint256 timestamp;
    }

    struct Game {
        string homeTeam;
        string awayTeam;
        uint256 startTime;
        bool isActive;
        uint256 totalPool;
        bool completed;
        BetType result;
        bool hadOvertime;
        mapping(address => Bet) bets;
        address[] bettors;
    }

    mapping(uint256 => Game) public games;
    mapping(address => mapping(uint256 => bool)) public hasBet;
    mapping(address => Bet[]) public transactionHistory;

    AggregatorV3Interface public oracle;
    uint256 public gameCount;

    event BetPlaced(address indexed bettor, uint256 gameId, uint256 amount, BetType betType, bool overtime, uint256 timestamp);
    event GameStarted(uint256 gameId, uint256 startTime);
    event GameCompleted(uint256 gameId, BetType result, bool hadOvertime);
    event WinningsDistributed(address indexed winner, uint256 gameId, uint256 amount);

    constructor(address _interoperability, address _usdMediator, address _oracle) {
        owner = msg.sender;
        interoperability = InstilledInteroperability(_interoperability);
        usdMediator = USDMediator(_usdMediator);
        oracle = AggregatorV3Interface(_oracle);
    }

    function createGame(string memory _homeTeam, string memory _awayTeam, uint256 _startTime) external {
        require(msg.sender == owner, "Only owner can create games");
        require(_startTime > block.timestamp, "Start time must be in the future");

        Game storage game = games[gameCount];
        game.homeTeam = _homeTeam;
        game.awayTeam = _awayTeam;
        game.startTime = _startTime;
        game.isActive = true;
        gameCount++;

        emit GameStarted(gameCount - 1, _startTime);
    }

    function placeBet(uint256 _gameId, uint256 _amount, BetType _betType, bool _overtime) external {
        Game storage game = games[_gameId];
        require(game.isActive, "Betting closed or game not found");
        require(block.timestamp < game.startTime - 5 minutes, "Betting closes 5 mins before start");
        require(!hasBet[msg.sender][_gameId], "One bet per game allowed");
        require(_amount > 0, "Amount must be greater than 0");

        require(usdcToken.transferFrom(msg.sender, address(this), _amount), "USDC transfer failed");

        game.bets[msg.sender] = Bet(msg.sender, _amount, _betType, _overtime, block.timestamp);
        game.bettors.push(msg.sender);
        game.totalPool += _amount;
        hasBet[msg.sender][_gameId] = true;

        transactionHistory[msg.sender].push(Bet(msg.sender, _amount, _betType, _overtime, block.timestamp));

        emit BetPlaced(msg.sender, _gameId, _amount, _betType, _overtime, block.timestamp);
    }

    function startGame(uint256 _gameId) external {
        Game storage game = games[_gameId];
        require(block.timestamp >= game.startTime, "Game not started yet");
        require(game.isActive, "Game already started or invalid");
        game.isActive = false;
        emit GameStarted(_gameId, game.startTime);
    }

    function completeGame(uint256 _gameId, BetType _result, bool _hadOvertime) external {
        require(msg.sender == owner, "Only owner can complete game");
        Game storage game = games[_gameId];
        require(!game.isActive && !game.completed, "Game not started or already completed");

        game.completed = true;
        game.result = _result;
        game.hadOvertime = _hadOvertime;

        distributeWinnings(_gameId);
        emit GameCompleted(_gameId, _result, _hadOvertime);
    }

    function distributeWinnings(uint256 _gameId) internal {
        Game storage game = games[_gameId];
        uint256 revenueShare = (game.totalPool * 20) / 100;
        uint256 winnerPool = game.totalPool - revenueShare;
        totalRevenue += revenueShare;

        uint256 totalWinningWeight = 0;
        address[] memory winners = new address[](game.bettors.length);
        uint256 winnerCount = 0;

        for (uint256 i = 0; i < game.bettors.length; i++) {
            address bettor = game.bettors[i];
            Bet memory bet = game.bets[bettor];
            bool wonMain = bet.betType == game.result;
            bool wonOvertime = bet.overtime == game.hadOvertime;

            if (wonMain && wonOvertime) {
                totalWinningWeight += bet.amount;
                winners[winnerCount] = bettor;
                winnerCount++;
            }
        }

        for (uint256 i = 0; i < winnerCount; i++) {
            address winner = winners[i];
            Bet memory bet = game.bets[winner];
            uint256 winnerShare = (bet.amount * winnerPool) / totalWinningWeight;
            usdMediator.transferUSD(winner, winnerShare);
            transactionHistory[winner].push(Bet(winner, winnerShare, bet.betType, bet.overtime, block.timestamp));
            emit WinningsDistributed(winner, _gameId, winnerShare);
        }
    }

    function withdrawRevenue() external {
        require(msg.sender == owner, "Only owner can withdraw");
        uint256 amount = totalRevenue;
        totalRevenue = 0;
        interoperability.crossChainTransfer(1, 1, "USDC", amount, interoperability.mediatorAccount());
    }

    function getTransactionHistory(address user) external view returns (Bet[] memory) {
        return transactionHistory[user];
    }
}
__________________________________________________________________________________________
Spades.sol - // SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";

contract Spades is VRFConsumerBase {
    // Constants
    uint8 constant NUM_PLAYERS = 4;
    uint8 constant CARDS_PER_PLAYER = 13;
    uint8 constant TOTAL_CARDS = 52;
    uint256 constant BID_TIMEOUT = 30; // 30 seconds

    // Game state
    address[4] public players;
    uint8 public dealer;
    uint8 public leader;
    uint8 public currentPlayer;
    uint8[4] public tricksWon; // Tricks in current hand
    uint256 public teamAScore; // Team 0 & 2 (in wei, e.g., 4400000 = 4.4)
    uint256 public teamBScore; // Team 1 & 3
    uint8 public teamAStrikes;
    uint8 public teamBStrikes;
    uint8 public teamAReneges;
    uint8 public teamBReneges;
    bool public gameOver;
    mapping(uint8 => uint8[]) public hands;
    uint8[] public currentTrick;
    uint8 public suitLed;
    uint8[2] public teamBids; // Team A (0), Team B (1)
    mapping(uint8 => uint8) public playerBids; // Player index => bid
    uint256 public bidStartTime;
    uint8 public biddingPhase; // 0=dealer, 1=dealer's partner, 2=left, 3=left's partner
    bool public firstRound;

    // Betting
    uint256 public betAmount;
    address public revenueAddress;

    // Chainlink VRF
    bytes32 internal keyHash;
    uint256 internal fee;
    uint256 public randomResult;

    // Chainlink Oracle for Time
    AggregatorV3Interface internal timeFeed; // Hypothetical time oracle

    // Events
    event BidPlaced(uint8 indexed player, uint8 bid);
    event TrickWon(uint8 indexed winner, uint8 books);
    event GameEnded(address winnerTeam, uint256 winnings);

    // Constructor
    constructor(
        address[4] memory _players,
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        uint256 _fee,
        address _timeFeed,
        address _revenueAddress
    ) VRFConsumerBase(_vrfCoordinator, _link) payable {
        players = _players;
        keyHash = _keyHash;
        fee = _fee;
        timeFeed = AggregatorV3Interface(_timeFeed);
        revenueAddress = _revenueAddress;
        betAmount = msg.value / 2; // Split between teams
        dealer = uint8(block.timestamp % 4);
        leader = (dealer + 1) % 4;
        currentPlayer = leader;
        firstRound = true;
        biddingPhase = 0;
    }

    // Start a new hand
    function startNewHand() public {
        require(!gameOver, "Game is over");
        require(LINK.balanceOf(address(this)) >= fee, "Not enough LINK");
        requestRandomness(keyHash, fee);
    }

    // Fulfill randomness and deal cards
    function fulfillRandomness(bytes32, uint256 randomness) internal override {
        randomResult = randomness;
        uint8[52] memory deck;
        for (uint8 i = 0; i < 52; i++) deck[i] = i;
        for (uint8 i = 51; i > 0; i--) {
            uint8 j = uint8(uint256(keccak256(abi.encode(randomness, i))) % (i + 1));
            (deck[i], deck[j]) = (deck[j], deck[i]);
        }
        for (uint8 p = 0; p < 4; p++) {
            delete hands[p];
            for (uint8 c = 0; c < 13; c++) {
                hands[p].push(deck[p * 13 + c]);
            }
        }
        resetTrickState();
        bidStartTime = getCurrentTime();
        biddingPhase = 0;
        if (firstRound) {
            teamBids[0] = 4;
            teamBids[1] = 4;
            firstRound = false;
            currentPlayer = leader;
        }
    }

    // Place a bid
    function placeBid(uint8 bid) public {
        require(!firstRound, "First round has fixed bids");
        require(bid <= 13, "Bid must be 0-13");
        require(getCurrentTime() < bidStartTime + BID_TIMEOUT, "Bid timeout");
        require(msg.sender == players[currentBidder()], "Not your turn to bid");

        playerBids[currentBidder()] = bid;
        emit BidPlaced(currentBidder(), bid);

        if (biddingPhase == 0 || biddingPhase == 2) {
            biddingPhase++;
        } else {
            uint8 teamIndex = (currentBidder() % 2 == 0) ? 0 : 1;
            teamBids[teamIndex] = playerBids[currentBidder()] + playerBids[currentBidder() - 1];
            biddingPhase++;
        }

        if (biddingPhase == 4) {
            biddingPhase = 255; // Bidding done
            currentPlayer = leader;
        }
        bidStartTime = getCurrentTime();
    }

    // Play a card
    function playCard(uint8 card) public {
        require(msg.sender == players[currentPlayer], "Not your turn");
        require(biddingPhase == 255 || firstRound, "Bidding not complete");
        require(isValidPlay(card, currentPlayer), "Invalid play");

        bool reneged = checkRenege(card, currentPlayer);
        if (reneged) {
            uint8 team = (currentPlayer % 2 == 0) ? 0 : 1;
            if (team == 0) teamAReneges++;
            else teamBReneges++;
        }

        removeCardFromHand(currentPlayer, card);
        currentTrick.push(card);

        if (currentTrick.length == 1) suitLed = getSuit(card);
        currentPlayer = (currentPlayer + 1) % 4;

        if (currentTrick.length == 4) {
            resolveTrick();
        }
    }

    // Resolve a trick
    function resolveTrick() internal {
        uint8 winner = determineWinner(currentTrick, suitLed);
        tricksWon[winner]++;
        emit TrickWon(winner, tricksWon[winner]);
        leader = winner;
        currentPlayer = winner;

        if (tricksWon[0] + tricksWon[1] + tricksWon[2] + tricksWon[3] == 13) {
            resolveHand();
        } else {
            resetTrickState();
        }
    }

    // Resolve a hand
    function resolveHand() internal {
        uint8 teamATricks = tricksWon[0] + tricksWon[2];
        uint8 teamBTricks = tricksWon[1] + tricksWon[3];

        if (teamATricks >= teamBids[0]) {
            uint256 excess = teamATricks - teamBids[0];
            teamAScore += (teamBids[0] * 1 ether) + (excess * 1 ether / 10);
        } else {
            teamAStrikes++;
        }

        if (teamBTricks >= teamBids[1]) {
            uint256 excess = teamBTricks - teamBids[1];
            teamBScore += (teamBids[1] * 1 ether) + (excess * 1 ether / 10);
        } else {
            teamBStrikes++;
        }

        checkGameEnd();
        if (!gameOver) {
            dealer = (dealer + 1) % 4;
            leader = (dealer + 1) % 4;
            startNewHand();
        }
    }

    // Check game end conditions
    function checkGameEnd() internal {
        bool teamAWins = teamAScore >= 25 ether;
        bool teamBWins = teamBScore >= 25 ether;
        bool teamALoses = (teamAStrikes >= 3) || (teamAReneges >= 2) || 
                         (teamAStrikes >= 2 && teamAStrikes > tricksWon[0] + tricksWon[2]);
        bool teamBLoses = (teamBStrikes >= 3) || (teamBReneges >= 2) || 
                         (teamBStrikes >= 2 && teamBStrikes > tricksWon[1] + tricksWon[3]);

        if (teamAWins || teamBLoses) {
            gameOver = true;
            payable(players[0]).transfer(betAmount * 2);
            emit GameEnded(players[0], betAmount * 2);
        } else if (teamBWins || teamALoses) {
            gameOver = true;
            payable(players[1]).transfer(betAmount * 2);
            emit GameEnded(players[1], betAmount * 2);
        } else if (teamAReneges > 0 && teamBReneges > 0 && currentTrick.length == 4) {
            gameOver = true;
            payable(revenueAddress).transfer(betAmount * 2);
            emit GameEnded(address(0), 0);
        }
    }

    // Helper functions
    function getSuit(uint8 card) public pure returns (uint8) {
        if (card == 51) return 4; // Little Joker
        if (card == 52) return 4; // Big Joker
        return card / 13;
    }

    function getRank(uint8 card) public pure returns (uint8) {
        if (card == 51) return 13;
        if (card == 52) return 14;
        return card % 13;
    }

    function isValidPlay(uint8 card, uint8 player) public view returns (bool) {
        bool hasCard = false;
        for (uint8 i = 0; i < hands[player].length; i++) {
            if (hands[player][i] == card) {
                hasCard = true;
                break;
            }
        }
        if (!hasCard) return false;
        if (currentTrick.length == 0) return true;
        uint8 playerSuit = getSuit(card);
        if (playerSuit == suitLed) return true;
        for (uint8 i = 0; i < hands[player].length; i++) {
            if (getSuit(hands[player][i]) == suitLed) return false;
        }
        return true;
    }

    function checkRenege(uint8 card, uint8 player) internal view returns (bool) {
        if (currentTrick.length == 0 || getSuit(card) == suitLed) return false;
        for (uint8 i = 0; i < hands[player].length; i++) {
            if (getSuit(hands[player][i]) == suitLed && hands[player][i] != card) {
                return true;
            }
        }
        return false;
    }

    function removeCardFromHand(uint8 player, uint8 card) internal {
        for (uint8 i = 0; i < hands[player].length; i++) {
            if (hands[player][i] == card) {
                hands[player][i] = hands[player][hands[player].length - 1];
                hands[player].pop();
                break;
            }
        }
    }

    function determineWinner(uint8[] memory cards, uint8 suitLed) public pure returns (uint8) {
        uint8 maxIndex = 0;
        bool trumpPlayed = false;
        for (uint8 i = 0; i < 4; i++) {
            uint8 suit = getSuit(cards[i]);
            uint8 rank = getRank(cards[i]);
            if (suit == 4 || suit == 0) { // Joker or spade
                if (!trumpPlayed || compareCards(cards[i], cards[maxIndex]) > 0) {
                    maxIndex = i;
                    trumpPlayed = true;
                }
            } else if (!trumpPlayed && suit == suitLed) {
                if (rank > getRank(cards[maxIndex])) maxIndex = i;
            }
        }
        return maxIndex;
    }

    function compareCards(uint8 card1, uint8 card2) public pure returns (int8) {
        uint8 suit1 = getSuit(card1);
        uint8 suit2 = getSuit(card2);
        uint8 rank1 = getRank(card1);
        uint8 rank2 = getRank(card2);
        if (suit1 == 4 && suit2 != 4) return 1;
        if (suit2 == 4 && suit1 != 4) return -1;
        if (suit1 == 4 && suit2 == 4) return (rank1 > rank2) ? int8(1) : int8(-1);
        if (suit1 == 0 && suit2 != 0) return 1;
        if (suit2 == 0 && suit1 != 0) return -1;
        if (suit1 == 0 && suit2 == 0) return (rank1 > rank2) ? int8(1) : int8(-1);
        return (rank1 > rank2) ? int8(1) : int8(-1);
    }

    function resetTrickState() internal {
        delete currentTrick;
        suitLed = 255;
        for (uint8 p = 0; p < 4; p++) tricksWon[p] = 0;
    }

    function getCurrentTime() internal view returns (uint256) {
        (, int256 time, , ,) = timeFeed.latestRoundData();
        return uint256(time);
    }

    function currentBidder() internal view returns (uint8) {
        if (biddingPhase == 0) return dealer;
        if (biddingPhase == 1) return (dealer + 2) % 4;
        if (biddingPhase == 2) return (dealer + 1) % 4;
        return (dealer + 3) % 4;
    }
}
_________________________________________________________________
GerastyxOpol.sol - // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@chainlink/contracts/src/v0.8/VRFConsumerBase.sol";
import "./USDMediator.sol";
import "./InstilledInteroperability.sol";
import "./GerastyxPropertyNFT.sol";
import "./AdWatch.sol";

contract GerastyxOpol is Ownable, VRFConsumerBase {
    USDMediator public usdMediator;
    InstilledInteroperability public interoperability;
    GerastyxPropertyNFT public propertyNFT;
    AdWatch public adWatch;
    IERC20 public usdcToken;
    address public revenueRecipient;
    bytes32 internal keyHash;
    uint256 internal fee;

    // Game constants
    uint256 public constant BOARD_SIZE = 40;
    uint256 public constant MAX_PLAYERS = 8;
    uint256 public constant MIN_PLAYERS = 4;
    uint256 public constant TURN_TIMEOUT = 30 seconds;
    uint256 public constant AUTO_ROLL_COST = 1 * 10**6; // $1 in USDC
    uint256 public constant JAIL_POSITION = 10;

    // Game modes
    enum GameMode { Free, Civilian, Banker, Monopoly }
    mapping(GameMode => uint256) public entryFees; // In USDC (6 decimals)
    mapping(GameMode => uint256) public passGoRewards; // In USDC
    mapping(GameMode => uint256) public startingBalances; // In USDC

    // Board setup
    mapping(uint256 => uint256) public positionToProperty; // Board position => Property tokenId
    mapping(uint256 => bool) public isLuckyCardPosition;
    mapping(uint256 => bool) public isKarmaCardPosition;
    mapping(uint256 => uint256) public taxPositions; // Position => Tax amount (USDC)

    // Game state
    struct Player {
        address playerAddress;
        uint256 position; // Board position (0–39)
        uint256 balance; // In-game USDC balance
        bool isActive;
        uint256[] ownedProperties; // Token IDs of owned GerastyxPropertyNFTs
        uint256 luckyCards; // Number of LuckyCards
        uint256 karmaCards; // Number of KarmaCards
        bool hasGetOutOfJailCard;
        bool inJail;
        uint256 doubleRolls; // Consecutive doubles rolled
        bool autoRollEnabled;
        uint256 pieceId; // 0: Animal, 1: Clothing, 2: Food, 3: Emoji Rock-Boulder
        uint256 lastTurnTime; // Timestamp of last turn
    }

    struct Game {
        uint256 gameId;
        GameMode mode;
        address[] players;
        mapping(address => Player) playerData;
        uint256 currentPlayerIndex;
        bool isActive;
        bool canJoin;
        uint256 totalPool; // Total USDC in the game
        uint256 adScreenCounter; // Tracks turns for ad screens in Free mode
    }

    mapping(uint256 => Game) public games;
    mapping(bytes32 => uint256) public diceRequestToGameId;
    mapping(bytes32 => uint256) public coinRequestToGameId;
    mapping(address => bool) public hasPassedGo; // Tracks if player passed Go
    mapping(uint256 => uint256) public jailedPlayers; // Player => Remaining jail turns

    // Events for Unreal Engine
    event GameStarted(uint256 indexed gameId, GameMode mode, address[] players, string boardColor);
    event PlayerMoved(address indexed player, uint256 newPosition, uint256 diceRoll, bool movedLeft);
    event PropertyPurchased(address indexed player, uint256 tokenId, uint256 amount);
    event RentPaid(address indexed payer, address indexed receiver, uint256 amount);
    event LuckyCardDrawn(address indexed player, string action);
    event KarmaCardDrawn(address indexed player, string action);
    event PlayerJailed(address indexed player, uint256 turns);
    event PlayerFreed(address indexed player);
    event GameEnded(uint256 indexed gameId, address winner, uint256 winnings);
    event AdScreenTriggered(uint256 indexed gameId, uint256 turnCount);
    event AutoRollEnabled(address indexed player, uint256 gameId);

    constructor(
        address _usdMediator,
        address _interoperability,
        address _propertyNFT,
        address _adWatch,
        address _usdcToken,
        address _vrfCoordinator,
        address _link,
        bytes32 _keyHash,
        uint256 _fee,
        address initialOwner
    )
        Ownable(initialOwner)
        VRFConsumerBase(_vrfCoordinator, _link)
    {
        usdMediator = USDMediator(_usdMediator);
        interoperability = InstilledInteroperability(_interoperability);
        propertyNFT = GerastyxPropertyNFT(_propertyNFT);
        adWatch = AdWatch(_adWatch);
        usdcToken = IERC20(_usdcToken);
        revenueRecipient = initialOwner;
        keyHash = _keyHash;
        fee = _fee;

        // Initialize game modes
        entryFees[GameMode.Free] = 0;
        entryFees[GameMode.Civilian] = 5 * 10**6; // $5
        entryFees[GameMode.Banker] = 20 * 10**6; // $20
        entryFees[GameMode.Monopoly] = 100 * 10**6; // $100

        passGoRewards[GameMode.Free] = 0;
        passGoRewards[GameMode.Civilian] = 5 * 10**6; // $5
        passGoRewards[GameMode.Banker] = 20 * 10**6; // $20
        passGoRewards[GameMode.Monopoly] = 100 * 10**6; // $100

        startingBalances[GameMode.Free] = 250 * 10**6; // $250
        startingBalances[GameMode.Civilian] = 250 * 10**6; // $250
        startingBalances[GameMode.Banker] = 250 * 10**6; // $250
        startingBalances[GameMode.Monopoly] = 500 * 10**6; // $500

        // Initialize board (example positions)
        positionToProperty[1] = 1; // Duck Crossing
        positionToProperty[3] = 2; // Duck Coast
        // Add more properties (up to 30)
        isLuckyCardPosition[2] = true;
        isLuckyCardPosition[7] = true;
        isKarmaCardPosition[4] = true;
        isKarmaCardPosition[9] = true;
        taxPositions[12] = 2 * 10**6; // $2 tax
        taxPositions[28] = 5 * 10**6; // $5 tax
    }

    function startGame(address[] memory players, GameMode mode, uint256[] memory pieceIds) external onlyOwner {
        require(players.length >= MIN_PLAYERS && players.length <= MAX_PLAYERS, "Invalid player count");
        require(pieceIds.length == players.length, "Invalid piece IDs");
        for (uint256 i = 0; i < pieceIds.length; i++) {
            require(pieceIds[i] <= 3, "Invalid piece ID"); // 0: Animal, 1: Clothing, 2: Food, 3: Emoji Rock-Boulder
        }

        uint256 gameId = games.length;
        Game storage game = games[gameId];
        game.gameId = gameId;
        game.mode = mode;
        game.isActive = true;
        game.canJoin = true;
        game.players = players;
        game.currentPlayerIndex = 0;
        game.totalPool = entryFees[mode] * players.length;

        for (uint256 i = 0; i < players.length; i++) {
            if (mode == GameMode.Free) {
                adWatch.watchAd("GameEntry", players[i]);
            } else {
                require(usdcToken.transferFrom(players[i], address(this), entryFees[mode]), "Entry fee transfer failed");
            }
            game.playerData[players[i]] = Player({
                playerAddress: players[i],
                position: 0,
                balance: startingBalances[mode],
                isActive: true,
                ownedProperties: new uint256[](0),
                luckyCards: 0,
                karmaCards: 0,
                hasGetOutOfJailCard: false,
                inJail: false,
                doubleRolls: 0,
                autoRollEnabled: false,
                pieceId: pieceIds[i],
                lastTurnTime: block.timestamp
            });
        }

        emit GameStarted(gameId, mode, players, "BlackAndGold");
    }

    function enableAutoRoll(uint256 gameId) external {
        Game storage game = games[gameId];
        require(game.isActive, "Game not active");
        require(game.playerData[msg.sender].isActive, "Player not active");
        require(!game.playerData[msg.sender].autoRollEnabled, "Auto-roll already enabled");
        require(usdcToken.transferFrom(msg.sender, address(this), AUTO_ROLL_COST), "Auto-roll fee failed");
        game.playerData[msg.sender].autoRollEnabled = true;
        game.totalPool += AUTO_ROLL_COST;
        emit AutoRollEnabled(msg.sender, gameId);
    }

    function rollDiceAndCoin(uint256 gameId) external {
        Game storage game = games[gameId];
        require(game.isActive, "Game not active");
        require(msg.sender == game.players[game.currentPlayerIndex], "Not your turn");
        require(block.timestamp <= game.playerData[msg.sender].lastTurnTime + TURN_TIMEOUT, "Turn timeout");
        require(LINK.balanceOf(address(this)) >= fee * 2, "Insufficient LINK for VRF");

        // Request dice roll
        bytes32 diceRequestId = requestRandomness(keyHash, fee);
        diceRequestToGameId[diceRequestId] = gameId;

        // Request coin flip
        bytes32 coinRequestId = requestRandomness(keyHash, fee);
        coinRequestToGameId[coinRequestId] = gameId;
    }

    function autoRoll(uint256 gameId) external {
        Game storage game = games[gameId];
        address currentPlayer = game.players[game.currentPlayerIndex];
        require(game.isActive, "Game not active");
        require(game.playerData[currentPlayer].autoRollEnabled, "Auto-roll not enabled");
        require(block.timestamp >= game.playerData[currentPlayer].lastTurnTime + TURN_TIMEOUT - 5, "Too early for auto-roll");
        require(LINK.balanceOf(address(this)) >= fee * 2, "Insufficient LINK for VRF");

        // Request dice roll
        bytes32 diceRequestId = requestRandomness(keyHash, fee);
        diceRequestToGameId[diceRequestId] = gameId;

        // Request coin flip
        bytes32 coinRequestId = requestRandomness(keyHash, fee);
        coinRequestToGameId[coinRequestId] = gameId;
    }

    function fulfillRandomness(bytes32 requestId, uint256 randomness) internal override {
        uint256 gameId = diceRequestToGameId[requestId] != 0 ? diceRequestToGameId[requestId] : coinRequestToGameId[requestId];
        Game storage game = games[gameId];
        require(game.isActive, "Game not active");

        address currentPlayer = game.players[game.currentPlayerIndex];
        Player storage player = game.playerData[currentPlayer];

        if (diceRequestToGameId[requestId] != 0) {
            // Handle dice roll
            uint256 dice1 = (randomness % 6) + 1;
            uint256 dice2 = ((randomness >> 128) % 6) + 1;
            uint256 diceRoll = dice1 + dice2;
            bool isDouble = dice1 == dice2;

            if (isDouble) {
                player.doubleRolls++;
                if (player.doubleRolls >= 3) {
                    sendToJail(gameId, currentPlayer);
                    return;
                }
            } else {
                player.doubleRolls = 0;
            }

            // Store dice roll for coin flip processing
            player.position = diceRoll; // Temporarily store dice roll
            emit PlayerMoved(currentPlayer, diceRoll, diceRoll, false); // Temporary event for UI
        } else if (coinRequestToGameId[requestId] != 0) {
            // Handle coin flip
            bool moveLeft = (randomness % 2) == 0; // 0: Left, 1: Right
            uint256 diceRoll = player.position; // Retrieve stored dice roll
            uint256 newPosition = calculateNewPosition(player.position, diceRoll, moveLeft);

            // Update position and process
            if (newPosition < player.position && hasPassedGo[currentPlayer]) {
                if (game.mode == GameMode.Free) {
                    adWatch.watchAd("PassGo", currentPlayer);
                } else {
                    player.balance += passGoRewards[game.mode];
                    game.totalPool += passGoRewards[game.mode];
                }
            }
            player.position = newPosition;
            emit PlayerMoved(currentPlayer, newPosition, diceRoll, moveLeft);

            // Process position
            processPosition(gameId, currentPlayer, newPosition);

            // Check if player can roll again
            if (player.doubleRolls > 0 && !player.inJail) {
                player.lastTurnTime = block.timestamp;
            } else {
                // Next player's turn
                game.currentPlayerIndex = (game.currentPlayerIndex + 1) % game.players.length;
                while (!game.playerData[game.players[game.currentPlayerIndex]].isActive) {
                    game.currentPlayerIndex = (game.currentPlayerIndex + 1) % game.players.length;
                }
                game.playerData[game.players[game.currentPlayerIndex]].lastTurnTime = block.timestamp;
            }

            // Trigger ad screen in Free mode
            if (game.mode == GameMode.Free) {
                game.adScreenCounter++;
                if (game.adScreenCounter % 3 == 0) {
                    emit AdScreenTriggered(gameId, game.adScreenCounter);
                }
            }

            // Update join status
            if (game.canJoin && game.adScreenCounter >= game.players.length) {
                game.canJoin = false;
            }

            // Check game end
            checkGameEnd(gameId);
        }
    }

    function calculateNewPosition(uint256 currentPosition, uint256 diceRoll, bool moveLeft) internal pure returns (uint256) {
        if (moveLeft) {
            return (currentPosition + BOARD_SIZE - diceRoll) % BOARD_SIZE;
        } else {
            return (currentPosition + diceRoll) % BOARD_SIZE;
        }
    }

    function processPosition(uint256 gameId, address player, uint256 position) internal {
        Game storage game = games[gameId];
        Player storage playerData = game.playerData[player];

        if (playerData.inJail) {
            handleJail(gameId, player);
            return;
        }

        if (positionToProperty[position] > 0) {
            uint256 tokenId = positionToProperty[position];
            address propertyOwner = propertyNFT.ownerOf(tokenId);
            if (propertyOwner == address(0) && hasPassedGo[player]) {
                // Unowned property, player can buy (handled via frontend options)
                // Options: "buy property", "roll dice" (if double), "pass turn"
            } else if (propertyOwner != player && propertyOwner != address(0)) {
                // Pay rent
                uint256 rent = propertyNFT.propertyValues(tokenId) / 10; // 10% of property value
                handleRentPayment(gameId, player, propertyOwner, rent, tokenId);
            }
        } else if (isLuckyCardPosition[position]) {
            drawLuckyCard(gameId, player);
        } else if (isKarmaCardPosition[position]) {
            drawKarmaCard(gameId, player);
        } else if (taxPositions[position] > 0) {
            if (game.mode == GameMode.Free) {
                adWatch.watchAd("Tax", player);
            } else {
                if (playerData.balance >= taxPositions[position]) {
                    playerData.balance -= taxPositions[position];
                    game.totalPool += taxPositions[position];
                } else {
                    handleBankruptcy(gameId, player, address(0), taxPositions[position]);
                }
            }
        }
    }

    function buyProperty(uint256 gameId, uint256 tokenId) external {
        Game storage game = games[gameId];
        require(game.isActive, "Game not active");
        require(hasPassedGo[msg.sender], "Must pass Go first");
        require(propertyNFT.ownerOf(tokenId) == address(0), "Property already owned");
        require(positionToProperty[game.playerData[msg.sender].position] == tokenId, "Not on property position");

        Player storage player = game.playerData[msg.sender];
        uint256 cost = game.mode == GameMode.Civilian ? 1 * 10**6 : propertyNFT.propertyValues(tokenId);
        if (game.mode == GameMode.Free) {
            adWatch.watchAd("BuyProperty", msg.sender);
        } else {
            require(player.balance >= cost, "Insufficient balance");
            player.balance -= cost;
            game.totalPool += cost;
        }

        if (game.mode == GameMode.Monopoly) {
            propertyNFT.mint(msg.sender, tokenId);
        } else {
            // In-game property (not NFT)
            player.ownedProperties.push(tokenId);
        }
        emit PropertyPurchased(msg.sender, tokenId, cost);
    }

    function handleRentPayment(uint256 gameId, address payer, address receiver, uint256 amount, uint256 tokenId) internal {
        Game storage game = games[gameId];
        Player storage payerData = game.playerData[payer];
        if (game.mode == GameMode.Free) {
            adWatch.watchAd("Rent", payer);
            emit RentPaid(payer, receiver, 0);
        } else if (payerData.balance >= amount) {
            payerData.balance -= amount;
            game.playerData[receiver].balance += (amount * 99) / 100;
            uint256 nftShare = amount / 100;
            game.totalPool += nftShare;
            emit RentPaid(payer, receiver, amount);
        } else {
            handleBankruptcy(gameId, payer, receiver, amount);
        }
    }

    function handleBankruptcy(uint256 gameId, address player, address owedTo, uint256 amountOwed) internal {
        Game storage game = games[gameId];
        Player storage playerData = game.playerData[player];
        uint256 totalValue = playerData.balance;

        // Sell in-game properties
        for (uint256 i = 0; i < playerData.ownedProperties.length; i++) {
            uint256 tokenId = playerData.ownedProperties[i];
            uint256 value = propertyNFT.propertyValues(tokenId) * 80 / 100; // 80% of value
            totalValue += value;
        }

        if (totalValue >= amountOwed) {
            // Pay owed amount
            if (owedTo != address(0)) {
                game.playerData[owedTo].balance += (amountOwed * 99) / 100;
                game.totalPool += amountOwed / 100;
            } else {
                game.totalPool += amountOwed;
            }
            playerData.balance = totalValue - amountOwed;
            // Clear properties
            delete playerData.ownedProperties;
        } else {
            // Full bankruptcy
            if (owedTo != address(0)) {
                game.playerData[owedTo].balance += (totalValue * 99) / 100;
                game.totalPool += totalValue / 100;
            } else {
                game.totalPool += totalValue;
            }
            playerData.balance = 0;
            delete playerData.ownedProperties;
            playerData.isActive = false;
            if (game.mode == GameMode.Free) {
                adWatch.watchAd("Bankruptcy", player);
            }
        }

        emit RentPaid(player, owedTo, totalValue);
    }

    function drawLuckyCard(uint256 gameId, address player) internal {
        Game storage game = games[gameId];
        Player storage playerData = game.playerData[player];
        // Random selection (simplified, could use VRF)
        uint256 action = block.timestamp % 8;
        if (action == 0) {
            // Get $1 from every player
            for (uint256 i = 0; i < game.players.length; i++) {
                if (game.playerData[game.players[i]].isActive && game.players[i] != player) {
                    if (game.mode == GameMode.Free) {
                        adWatch.watchAd("LuckyCard", game.players[i]);
                    } else {
                        game.playerData[game.players[i]].balance -= 1 * 10**6;
                        playerData.balance += 1 * 10**6;
                    }
                }
            }
            emit LuckyCardDrawn(player, "Get $1 from every player");
        } else if (action == 1) {
            // Extra roll
            playerData.doubleRolls = 1; // Allows another roll
            emit LuckyCardDrawn(player, "Extra roll");
        } else if (action == 2) {
            // Go to Go
            playerData.position = 0;
            if (game.mode != GameMode.Free) {
                playerData.balance += passGoRewards[game.mode];
                game.totalPool += passGoRewards[game.mode];
      
_______________________________________________________________________
GerastyxOpolPropertyNFT.sol - // SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./USDMediator.sol";
import "./InstilledInteroperability.sol";

contract GerastyxPropertyNFT is ERC721, Ownable {
    USDMediator public usdMediator;
    InstilledInteroperability public interoperability;
    uint256 public constant TOTAL_PROPERTIES = 30;
    uint256 public constant TOKENS_PER_PROPERTY = 1_000_000_000;
    uint256 public tokenCounter;

    mapping(uint256 => uint256) public propertyValues; // Token ID => Value in USDC
    mapping(uint256 => uint256) public propertyMarketCaps; // Token ID => Market cap
    mapping(address => uint256[]) public userDecks; // User's selected deck (max 15 NFTs)
    mapping(uint256 => mapping(string => uint256)) public assetAllocations; // Token ID => Asset => Amount

    string[] public supportedAssets = [
        "AQUA", "XLM", "yUSD", "yXLM", "yBTC", "WFM", "TTWO", "BBY", "SFM", "DOLE"
    ];

    event PropertyMinted(uint256 tokenId, address owner, uint256 value);
    event DeckUpdated(address owner, uint256[] tokenIds);
    event RevenueDistributed(uint256 tokenId, uint256 amount, string asset);

    constructor(address _usdMediator, address _interoperability, address initialOwner)
        ERC721("GerastyxPropertyNFT", "GPNFT")
        Ownable(initialOwner)
    {
        usdMediator = USDMediator(_usdMediator);
        interoperability = InstilledInteroperability(_interoperability);
        initializeProperties();
    }

    function initializeProperties() internal {
        propertyValues[1] = 100 * 10**6; // Duck Crossing
        propertyValues[2] = 110 * 10**6; // Duck Coast
        // Initialize remaining 28 properties with values
        for (uint256 i = 3; i <= TOTAL_PROPERTIES; i++) {
            propertyValues[i] = 100 * 10**6 + (i - 1) * 10 * 10**6;
        }
    }

    function mint(address to, uint256 tokenId) external onlyOwner {
        require(tokenId <= TOTAL_PROPERTIES * TOKENS_PER_PROPERTY, "Exceeds total supply");
        _safeMint(to, tokenId);
        tokenCounter++;
        emit PropertyMinted(tokenId, to, propertyValues[tokenId]);
    }

    function buyPropertyNFT(address buyer, uint256 tokenId, uint256 amount) external {
        require(tokenId <= TOTAL_PROPERTIES, "Invalid property");
        require(amount >= propertyValues[tokenId], "Insufficient payment");
        require(tokenCounter < TOTAL_PROPERTIES * TOKENS_PER_PROPERTY, "Max supply reached");

        // Allocate payment across supported assets
        uint256 perAsset = amount / supportedAssets.length;
        for (uint256 i = 0; i < supportedAssets.length; i++) {
            assetAllocations[tokenId][supportedAssets[i]] += perAsset;
            usdMediator.buyStock(supportedAssets[i], perAsset);
        }

        _safeMint(buyer, tokenId);
        tokenCounter++;
        propertyMarketCaps[tokenId] += amount;
        emit PropertyMinted(tokenId, buyer, amount);
    }

    function sellPropertyNFT(address seller, uint256 tokenId, bool isAuction) external {
        require(ownerOf(tokenId) == seller, "Not owner");
        uint256 value = propertyValues[tokenId];
        uint256 payout = isAuction ? (value * 80) / 100 : value;

        // Sell underlying assets
        for (uint256 i = 0; i < supportedAssets.length; i++) {
            uint256 assetAmount = assetAllocations[tokenId][supportedAssets[i]];
            usdMediator.sellStock(supportedAssets[i], assetAmount, "USDC", seller);
            assetAllocations[tokenId][supportedAssets[i]] = 0;
        }

        if (isAuction) {
            uint256 mediatorShare = value / 10;
            usdMediator.transferUSD(address(interoperability), mediatorShare / 2);
            usdMediator.transferUSD(address(usdMediator), mediatorShare / 2);
        }

        _burn(tokenId);
        propertyMarketCaps[tokenId] -= value;
    }

    function distributeDividends(uint256 tokenId, uint256 amount) external onlyOwner {
        uint256 revenueShare = (amount * 50) / 100;
        uint256 nftShare = (amount * 30) / 100;
        uint256 userShare = (amount * 20) / 100;

        // Revenue distribution
        usdMediator.transferUSD(0xCj03nesRevenueAddress, revenueShare / 2);
        usdMediator.transferUSD(address(interoperability), revenueShare / 4);
        usdMediator.transferUSD(address(usdMediator), revenueShare / 4);

        // NFT share (1% to each of 30 properties)
        for (uint256 i = 1; i <= TOTAL_PROPERTIES; i++) {
            propertyMarketCaps[i] += nftShare / TOTAL_PROPERTIES;
        }

        // User share (split across GOATE, GySt, BTC, USD)
        address owner = ownerOf(tokenId);
        usdMediator.transferUSD(owner, userShare / 4); // USD
        interoperability.crossChainTransfer(1, 1, "GOATE", userShare / 4, owner);
        interoperability.crossChainTransfer(1, 1, "GySt", userShare / 4, owner);
        interoperability.crossChainTransfer(1, 1, "BTC", userShare / 4, owner);

        emit RevenueDistributed(tokenId, amount, "USDC");
    }

    function updateDeck(uint256[] memory tokenIds) external {
        require(tokenIds.length <= 15, "Deck cannot exceed 15 NFTs");
        for (uint256 i = 0; i < tokenIds.length; i++) {
            require(ownerOf(tokenIds[i]) == msg.sender, "Not owner of NFT");
        }
        userDecks[msg.sender] = tokenIds;
        emit DeckUpdated(msg.sender, tokenIds);
    }
}


index.js - html {
  scroll-behavior: smooth;
}

* {
  box-sizing: border-box;
}

body {
  background-color: #035096;
  color: #F9B234;

  font-family: Avenir-Roman, sans-serif;
  margin: 0;
  padding: 0;
}

a {
  color: #F9B234;
  text-decoration: none;
}

@media only screen and (min-width: 768px) {
  body {
    font-size: 16px;
  }
}
@media only screen and (min-width: 480px) and (max-width: 768px) {
  body {
    font-size: 15px;
  }
}
@media only screen and (max-width: 479px) {
  body {
      font-size: 14px;
  }
}
______________________________________________________________________________________________________________________

index.css - body {
    font-family: Arial, sans-serif;
    margin: 0;
    padding: 0;
    color: #333;
    background: 
        linear-gradient(rgba(255, 255, 255, 0.7), rgba(255, 255, 255, 0.7)),
        url('background-image1.jpg') center/cover no-repeat,
        url('background-image2.jpg') center/cover no-repeat,
        url('background-image3.jpg') center/cover no-repeat,
        url('background-image4.jpg') center/cover no-repeat,
        url('background-image5.jpg') center/cover no-repeat,
        url('background-image6.jpg') center/cover no-repeat,
        #918d8d; /* Fallback color */
    background-blend-mode: overlay;
    min-height: 100vh;
}

/* Ensure text is readable against the background */
h1, p, button, .service {
    color: black;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.8);
}

header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    background-color: rgba(0, 123, 255, 0.9);
    color: white;
    padding: 10px 20px;
}

.header-left {
    display: flex;
    align-items: center;
}

.logo {
    width: 50px;
    height: 50px;
    margin-right: 10px;
}

h1 {
    margin: 0;
    font-size: 24px;
}

.header-right button {
    margin-left: 10px;
    padding: 10px;
    background-color: rgba(40, 167, 69, 0.9);
    border: none;
    color: white;
    cursor: pointer;
    border-radius: 5px;
}

.header-right button:hover {
    background-color: rgba(33, 136, 56, 0.9);
}

.services {
    display: flex;
    justify-content: center;
    gap: 20px;
    padding: 20px;
}

.service {
    background-color: rgba(255, 255, 255, 0.9);
    padding: 20px;
    border-radius: 5px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
    text-align: center;
    cursor: pointer;
    width: 200px;
    font-size: 18px;
    position: relative;
    color: #333;
    text-shadow: none;
    border: none;
    transition: background-color 0.3s;
}

.service:hover {
    background-color: rgba(224, 224, 224, 0.9);
}

/* Specific styles for Goate Electric button */
.service.goate-electric {
    background-image: url('goate-electric-logo.png');
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    color: white;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.8);
}

.service.goate-electric::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    border-radius: 5px;
    z-index: 0;
}

.service.goate-electric span {
    position: relative;
    z-index: 1;
}

/* Specific styles for Gerastyx button */
.service.gerastyx {
    background-image: url('gerastyx-logo.png');
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    color: white;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.8);
}

.service.gerastyx::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    border-radius: 5px;
    z-index: 0;
}

.service.gerastyx span {
    position: relative;
    z-index: 1;
}

/* Specific styles for GoatePig button */
.service.goatepig {
    background-image: url('goate-pig-logo.png');
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    color: white;
    text-shadow: 1px 1px 2px rgba(0, 0, 0, 0.8);
}

.service.goatepig::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
    border-radius: 5px;
    z-index: 0;
}

.service.goatepig span {
    position: relative;
    z-index: 1;
}

footer {
    text-align: center;
    padding: 20px;
    background-color: rgba(0, 123, 255, 0.9);
    color: white;
}

.modal {
    display: none;
    position: fixed;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(0, 0, 0, 0.5);
}

.modal-content {
    background-color: white;
    margin: 15% auto;
    padding: 20px;
    width: 80%;
    max-width: 600px;
    border-radius: 5px;
    text-align: center;
    position: relative;
}

/* Apply background image for Goate Electric modal */
#feature-modal .modal-content:has(#feature-title:where(:text("Goate Electric"))) {
    background-image: url('goate-electric-bg.jpg');
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    background-color: rgba(255, 255, 255, 0.8);
}

#feature-modal .modal-content:has(#feature-title:where(:text("Goate Electric")))::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(255, 255, 255, 0.8);
    z-index: 0;
}

#feature-modal .modal-content:has(#feature-title:where(:text("Goate Electric"))) * {
    position: relative;
    z-index: 1;
}

/* Apply background image for Gerastyx modal */
#feature-modal .modal-content:has(#feature-title:where(:text("Gerastyx"))) {
    background-image: url('gerastyx-bg.jpg');
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    background-color: rgba(255, 255, 255, 0.8);
}

#feature-modal .modal-content:has(#feature-title:where(:text("Gerastyx")))::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(255, 255, 255, 0.8);
    z-index: 0;
}

#feature-modal .modal-content:has(#feature-title:where(:text("Gerastyx"))) * {
    position: relative;
    z-index: 1;
}

/* Apply background image for GoatePig modal */
#feature-modal .modal-content:has(#feature-title:where(:text("GoatePig"))) {
    background-image: url('goatepig-bg.jpg');
    background-size: cover;
    background-position: center;
    background-repeat: no-repeat;
    background-color: rgba(255, 255, 255, 0.8);
}

#feature-modal .modal-content:has(#feature-title:where(:text("GoatePig")))::before {
    content: '';
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    background-color: rgba(255, 255, 255, 0.8);
    z-index: 0;
}

#feature-modal .modal-content:has(#feature-title:where(:text("GoatePig"))) * {
    position: relative;
    z-index: 1;
}

.close {
    color: #aaa;
    float: right;
    font-size: 28px;
    cursor: pointer;
}

.close:hover {
    color: black;
}

#sign-in-pi, #sign-in-google, #sign-in-apple {
    display: block;
    margin: 10px auto;
    padding: 10px;
    width: 80%;
    background-color: #007bff;
    color: white;
    border: none;
    cursor: pointer;
}

#sign-in-pi:hover, #sign-in-google:hover, #sign-in-apple:hover {
    background-color: #0056b3;
}

#pi-auth button {
    margin: 10px;
    padding: 10px;
    background-color: #28a745;
    color: white;
    border: none;
    cursor: pointer;
}

#pi-auth button:hover {
    background-color: #218838;
}

#create-account {
    font-size: 12px;
    background-color: #007bff;
    position: absolute;
    bottom: 10px;
    right: 10px;
}

.balances {
    display: grid;
    grid-template-columns: repeat(3, 1fr);
    gap: 10px;
    padding: 20px;
    text-align: center;
}

.balance {
    background-color: rgba(255, 255, 255, 0.9);
    padding: 15px;
    border-radius: 5px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

.token-logo {
    width: 30px;
    height: 30px;
    margin-right: 10px;
}

.games, .goatepig, .devices, .settings {
    padding: 10px;
}

.device, .asset-card {
    background-color: rgba(255, 255, 255, 0.9);
    padding: 10px;
    margin: 10px 0;
    border-radius: 5px;
    box-shadow: 0 2px 5px rgba(0, 0, 0, 0.1);
}

.add-device {
    background-color: #28a745;
    color: white;
    padding: 10px;
    border: none;
    cursor: pointer;
    border-radius: 5px;
}

.add-device:hover {
    background-color: #218838;
}

/* Chain selector styles */
.chain-selector {
    margin: 10px 0;
}

.chain-option {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 5px 0;
}

.switch {
    position: relative;
    display: inline-block;
    width: 60px;
    height: 34px;
}

.switch input {
    opacity: 0;
    width: 0;
    height: 0;
}

.slider {
    position: absolute;
    cursor: pointer;
    top: 0;
    left: 0;
    right: 0;
    bottom: 0;
    background-color: #ccc;
    transition: 0.4s;
    border-radius: 34px;
}

.slider:before {
    position: absolute;
    content: "";
    height: 26px;
    width: 26px;
    left: 4px;
    bottom: 4px;
    background-color: white;
    transition: 0.4s;
    border-radius: 50%;
}

input:checked + .slider {
    background-color: #28a745; /* Green when active */
}

input:checked + .slider.active {
    background-color: #28a745; /* Ensure green when active */
}

input:checked + .slider:before {
    transform: translateX(26px);
}
