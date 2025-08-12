    }

    function decimals() public view virtual override returns (uint8) {
        return 2;
    }

    function setRevenueRecipient(address recipient) external onlyOwner {
        revenueRecipient = recipient;
    }

    function subscribe() external {
        require(balanceOf(msg.sender) >= SUBSCRIPTION_COST, "Insufficient $ZPP balance");
        require(revenueRecipient != address(0), "Revenue recipient not set");
        _transfer(msg.sender, revenueRecipient, SUBSCRIPTION_COST);
        lastSubscriptionTime[msg.sender] = block.timestamp + SUBSCRIPTION_DURATION;
    }

    function isSubscribed(address user) public view returns (bool) {
        return lastSubscriptionTime[user] > block.timestamp;
    }
}