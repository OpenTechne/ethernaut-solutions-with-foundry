// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

interface ILevel {
    function createInstance(address _player) external returns (address);
    function validateInstance(address payable _instance, address _player) external returns (bool);
}
