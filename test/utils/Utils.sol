pragma solidity ^0.8.0;

import "forge-std/Test.sol";

contract Utils is Test {
    function oldCompilerFactory(string memory _name) public returns (address _deployed) {
        string memory name = string(abi.encodePacked(_name, ".sol", ":", _name));
        bytes memory bytecode = abi.encodePacked(vm.getCode(name));
        assembly {
            _deployed := create(0, add(bytecode, 0x20), mload(bytecode))
        }
    }
}
