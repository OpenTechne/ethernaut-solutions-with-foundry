pragma solidity ^0.8.0;

import "src/levels/EllipticToken/EllipticTokenFactory.sol";
import {EllipticToken} from "src/levels/EllipticToken/EllipticToken.sol";
import "forge-std/Test.sol";

contract EllipticTokenAttackTest is Test {
    address public dummyPlayerAddress;
    uint256 public dummyPlayerPrivateKey;
    EllipticTokenFactory public factory;
    EllipticToken public instance;

    uint256 INITIAL_AMOUNT = 10 ether;
    address ALICE = 0xA11CE84AcB91Ac59B0A4E2945C9157eF3Ab17D4e;
    address BOB = 0xB0B14927389CB009E0aabedC271AC29320156Eb8;

    function setUp() public {
        factory = new EllipticTokenFactory();
        instance = EllipticToken(payable(factory.createInstance(dummyPlayerAddress)));
        (dummyPlayerAddress, dummyPlayerPrivateKey) = makeAddrAndKey("dummyPlayer");
    }

    function test_ShouldNotBeImmediatelySolvable() public {
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), false);
    }

    function test_ShouldAllowThePlayerToSolveTheLevel() public {
        vm.startPrank(dummyPlayerAddress, dummyPlayerAddress);

        // Spoofed signature generated with EllipticToken.py script
        bytes32 r = 0x3a428e988a210ac89b262b44521f3192f1e6309be49b61ccbb22106267f31afc;
        bytes32 s = 0x35d83f57c65d93f446ec3c3329c8040e249dd230bbf28b8dd49d4cd6fe41fa71;
        uint8 v = 27;
        uint256 amount = uint256(0x4e8b732ad1e24ccd3af726f07ef93f9650b4ea124833e40fb0ab3f72f942e12b);
        bytes memory aliceSpoofedSignature = abi.encodePacked(r, s, v);

        // Permit acceptance signature
        bytes32 permitAcceptHash = keccak256(abi.encodePacked(ALICE, dummyPlayerAddress, amount));
        (v, r, s) = vm.sign(dummyPlayerPrivateKey, permitAcceptHash);
        bytes memory playerPermitAcceptanceSignature = abi.encodePacked(r, s, v);

        // Call permit to approve the transfer
        instance.permit(amount, dummyPlayerAddress, aliceSpoofedSignature, playerPermitAcceptanceSignature);

        // Drain the funds
        instance.transferFrom(ALICE, dummyPlayerAddress, INITIAL_AMOUNT);

        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), true);
    }
}
