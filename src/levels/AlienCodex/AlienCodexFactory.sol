// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

import "src/base/Level-05.sol";
import "src/levels/AlienCodex/AlienCodex.sol";

contract AlienCodexFactory is Level {
    function createInstance(address _player) public payable returns (address) {
        _player;
        return address(new AlienCodex());
    }

    function validateInstance(address payable _instance, address _player) public returns (bool) {
        // _player;
        AlienCodex instance = AlienCodex(_instance);
        return instance.owner() == _player;
    }
}
