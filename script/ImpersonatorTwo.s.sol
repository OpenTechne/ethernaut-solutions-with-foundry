// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import "src/levels/ImpersonatorTwo/ImpersonatorTwo.sol";
import {ImpersonatorTwoFactory} from "src/levels/ImpersonatorTwo/ImpersonatorTwoFactory.sol";
import {IERC20} from "openzeppelin-contracts-v5.4.0/token/ERC20/IERC20.sol";
import {IERC721} from "openzeppelin-contracts-v5.4.0/token/ERC721/IERC721.sol";
import {ECDSA} from "openzeppelin-contracts-08/utils/cryptography/ECDSA.sol";

ImpersonatorTwo constant target = ImpersonatorTwo(payable(0x0000000000000000000000000000000000000000)); // Insert target address
address constant player = 0x0000000000000000000000000000000000000000; // Insert player address

contract ImpersonatorTwoAttackScript is Script {

    function setUp() public {}

    function run() public {


        vm.startBroadcast();

        // Signatures generated with ImpersonatorTwo.py script
        bytes memory setAdminSig = abi.encodePacked(
            hex"e5648161e95dbf2bfc687b72b745269fa906031e2108118050aba59524a23c40", // r
            hex"3fdf38049273e38f11ace1e26f383bb5170417d25d5b120196309972b48e27c4", // s
            uint8(27) // v
        );
        bytes memory switchLockSig = abi.encodePacked(
            hex"e5648161e95dbf2bfc687b72b745269fa906031e2108118050aba59524a23c40", // r
            hex"2a04aa67c7760a7bec982fde4b387e1e62dc26ba69dd74444e68ffe28851375e", // s
            uint8(28) // v
        );

        target.setAdmin(setAdminSig, player);
        target.switchLock(switchLockSig);
        target.withdraw();
            
        vm.stopBroadcast();
    }
}

contract ImpersonatorTwoGetHash is Script {
    function setUp() public {}

    function run() public {

        vm.startBroadcast();

        string memory message1 = string(abi.encodePacked("admin", "2", player));
        console.log("Set Admin hash:");
        console.logBytes32(ECDSA.toEthSignedMessageHash(abi.encodePacked(message1)));

        string memory message2 = string(abi.encodePacked("lock", "3"));
        console.log("Switch Lock hash:");
        console.logBytes32(ECDSA.toEthSignedMessageHash(abi.encodePacked(message2)));
            
        vm.stopBroadcast();
    }

}