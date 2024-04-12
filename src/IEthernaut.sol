// SPDX-License-Identifier: MIT

interface IEthernaut {
    // Only registered levels will be allowed to generate and validate level instances.
    function registerLevel(address _level) external;

    function setStatistics(address _statProxy) external;

    function createLevelInstance(address _level) external;

    function submitLevelInstance(address _instance) external;
}
