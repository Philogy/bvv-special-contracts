// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

import {Test} from "forge-std/Test.sol";
import {BTCUtils} from "../../src/btc-relay/BTCUtils.sol";

/// @author philogy <https://github.com/philogy>
contract BTCUtilsTest is Test {
    function setUp() public {}

    function testSmallTree() public {
        bytes32 leRoot = BTCUtils.reverseWord(0xba5771c7c23dbd3a4e1014691c4f5a4d24be882ab5e644292fd634eb49ac6763);
        bytes32 txid1 = BTCUtils.reverseWord(0xc6b25bcfee83677b5c812fed9a39e9fb4e80eb122212581ea2a126cc841240ab);
        bytes32 txid2 = BTCUtils.reverseWord(0x9e74c632c1710226db466ef78f84e7e889c3206168f31d771b6135584d9f3f62);
        bytes32 txid3 = BTCUtils.reverseWord(0x23afc3364704b9018f800f0e673e7c670aa0d28ef810f88c09975760e8586463);
        bytes32[] memory proof = new bytes32[](2);
        proof[0] = txid2;
        proof[1] = sha256d(abi.encode(txid3, txid3));
        assertTrue(this.callIsValidMerkle(leRoot, txid1, 0, proof));
        assertTrue(this.callIsValidMerkleCoinbase(leRoot, txid1, proof));
        proof[0] = txid1;
        assertTrue(this.callIsValidMerkle(leRoot, txid2, 1, proof));
        proof[0] = txid3;
        proof[1] = sha256d(abi.encode(txid1, txid2));
        assertTrue(this.callIsValidMerkle(leRoot, txid3, 2, proof));
    }

    function testSimpleGetWitnessRoot() public {
        assertEq(
            this.callGetWitnessRootFromCoinbase(
                hex"02000000010000000000000000000000000000000000000000000000000000000000000000ffffffff04028d4600ffffffff02786301000000000016001456f46329275352fb0b9c5d95c317d4e5b9d6a2860000000000000000266a24aa21a9ed024c152f229fe6400aeccb868252d04fdfb2a065ffadf39f7083ee533ceab47e00000000"
            ),
            bytes32(0x024c152f229fe6400aeccb868252d04fdfb2a065ffadf39f7083ee533ceab47e)
        );
    }

    function testSimpleGetWitnessScript() public {
        assertEq(
            this.callGetWitnessScript(
                hex"020000000001010f5b56b539c2dc11f49c357825cec2ba493217a1479198ae07aabeaa60ba08a40000000000fdffffff01282300000000000016001456f46329275352fb0b9c5d95c317d4e5b9d6a286044093211166ca954b9c2f9147712e93ed3f2f7e71e0e6c88bf2f703ab412353ebf301ad486f8acaa4deff485bc5c2acb4efe0de49636abc7db92531b03b32eb132920107661134f21fc7c02223d50ab9eb3600bc3ffc3712423a1e47bb1f9a9dbf55f45a8206c60f404f8167a38fc70eaf8aa17ac351023bef86bcb9d1086a19afe95bd533388204edfcf9dfe6c0b5c83d1ab3f78d1b39a46ebac6798e08e19761f5ed89ec83c10ac41c1f30544d6009c8d8d94f5d030b2e844b1a3ca036255161c479db1cca5b374dd1cc81451874bd9ebd4b6fd4bba1f84cdfb533c532365d22a0a702205ff658b17c900000000",
                0
            ),
            hex"a8206c60f404f8167a38fc70eaf8aa17ac351023bef86bcb9d1086a19afe95bd533388204edfcf9dfe6c0b5c83d1ab3f78d1b39a46ebac6798e08e19761f5ed89ec83c10ac"
        );
    }

    // Create external functions so that calldata can be tested
    function callIsValidMerkle(bytes32 _txRoot, bytes32 _baseEl, uint256 _index, bytes32[] calldata _proofEls)
        external
        view
        returns (bool)
    {
        return BTCUtils.isValidMerkle(_txRoot, _baseEl, _index, _proofEls);
    }

    function callIsValidMerkleCoinbase(bytes32 _txRoot, bytes32 _baseEl, bytes32[] calldata _proofEls)
        external
        view
        returns (bool)
    {
        return BTCUtils.isValidMerkleCoinbase(_txRoot, _baseEl, _proofEls);
    }

    function callGetWitnessScript(bytes calldata _tx, uint256 _inIndex) external pure returns (bytes memory) {
        return BTCUtils.getWitnessScript(_tx, _inIndex);
    }

    function callGetWitnessRootFromCoinbase(bytes calldata _coinbaseTx) external returns (bytes32) {
        return BTCUtils.getWitnessRootFromCoinbase(_coinbaseTx);
    }

    function sha256d(bytes memory _inp) internal pure returns (bytes32) {
        return sha256(abi.encode(sha256(_inp)));
    }
}
