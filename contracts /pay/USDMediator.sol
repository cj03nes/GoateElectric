// SPDX-License-Identifier: MIT
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
