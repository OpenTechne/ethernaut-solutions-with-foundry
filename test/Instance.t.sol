pragma solidity ^0.8.0;

import "src/levels/Instance/InstanceFactory.sol";
import "src/levels/Instance/Instance.sol";
import "forge-std/Test.sol";

contract InstanceAttackTest is Test {
    address public dummyPlayerAddress = 0x30d2554d48037F642f095F24098319481A6D6642;
    InstanceFactory public factory;
    Instance public instance;

    function setUp() public {
        factory = new InstanceFactory();
        instance = Instance(payable(factory.createInstance(dummyPlayerAddress)));
    }

    function test_ShouldNotBeImmediatelySolvable() public {
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), false);
    }

    function test_ShouldAllowThePlayerToSolveTheLevel() public {
        payable(dummyPlayerAddress).transfer(0.0011 ether);
        vm.startPrank(dummyPlayerAddress, dummyPlayerAddress);

        string memory pw = instance.password();
        instance.authenticate(pw);
        
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), true);
    }
}

