// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

import {Test} from "forge-std/Test.sol";
import {BitcoinSPV} from "src/btc-relay/BitcoinSPV.sol";

/// @author philogy <https://github.com/philogy>
contract BitcoinSPVTest is Test {
    BitcoinSPV spv;

    function setUp() public {
        spv = new BitcoinSPV();
    }

    function testDefaultState() public {
        assertEq(spv.totalTxRoots(), 0);
        assertEq(spv.lastBlockhash(), bytes32(0));
    }

    function testAddHeader() public {
        bytes32 newTxRoot = keccak256("hello world");
        bytes memory header =
            abi.encodePacked(uint32(0x1), bytes32(0), newTxRoot, uint32(0x2), uint32(0x3), uint32(0x4));
        spv.addHeaders(header);
        assertEq(spv.totalTxRoots(), 1);
        assertEq(spv.getTxRoot(0), newTxRoot);
        assertEq(spv.lastBlockhash(), sha256(header));
    }

    function test_fuzzingAddHeaders(bytes32 _txRoot1, bytes32 _txRoot2) public {
        bytes memory header1 =
            abi.encodePacked(uint32(0x1), bytes32(0), _txRoot1, uint32(0x2), uint32(0x3), uint32(0x4));
        bytes memory header2 =
            abi.encodePacked(uint32(0x5), sha256(header1), _txRoot2, uint32(0x6), uint32(0x7), uint32(0x8));

        spv.addHeaders(abi.encodePacked(header1, header2));

        BitcoinSPV altSpv = new BitcoinSPV();
        altSpv.addHeaders(header1);
        altSpv.addHeaders(header2);

        assertEq(spv.totalTxRoots(), 2);
        assertEq(spv.getTxRoot(0), _txRoot1);
        assertEq(spv.getTxRoot(1), _txRoot2);
        assertEq(spv.lastBlockhash(), sha256(header2));

        assertEq(altSpv.totalTxRoots(), 2);
        assertEq(altSpv.getTxRoot(0), _txRoot1);
        assertEq(altSpv.getTxRoot(1), _txRoot2);
        assertEq(altSpv.lastBlockhash(), sha256(header2));
    }
}
