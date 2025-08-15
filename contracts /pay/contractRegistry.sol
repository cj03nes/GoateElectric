contract ContractRegistry {
    mapping(string => address) public addresses;
    mapping(string => string) public abis; // Store ABI as JSON string
    function updateAddress(string memory name, address addr) public {
        addresses[name] = addr;
    }
    function updateAbi(string memory name, string memory abi) public {
        abis[name] = abi;
    }
}