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

    function sha256d(bytes memory _inp) internal pure returns (bytes32) {
        return sha256(abi.encode(sha256(_inp)));
    }
}
