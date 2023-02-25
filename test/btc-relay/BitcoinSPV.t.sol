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

    function testAddBlockhash() public {
        bytes32 newTxRoot = keccak256("hello world");
        spv.addHeaders(abi.encodePacked(uint32(0x1), bytes32(0), newTxRoot, uint32(0x2), uint32(0x3), uint32(0x4)));
        assertEq(spv.totalTxRoots(), 1);
        assertEq(spv.getTxRoot(0), newTxRoot);
    }
}
