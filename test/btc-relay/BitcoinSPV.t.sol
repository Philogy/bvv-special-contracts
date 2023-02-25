// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

import {Test} from "forge-std/Test.sol";
import {BitcoinSPV} from "src/btc-relay/BitcoinSPV.sol";

/// @author philogy <https://github.com/philogy>
contract BitcoinSPVTest is Test {
    BitcoinSPV spv;

    uint32 internal constant MAX_TARGET = 0xffff7f20;

    function setUp() public {
        spv = new BitcoinSPV();
    }

    function testDefaultState() public {
        assertEq(spv.totalTxRoots(), 0);
        assertEq(spv.lastBlockhash(), bytes32(0));
    }

    function testAddHeader() public {
        bytes32 newTxRoot = keccak256("hello world");
        bytes memory header = abi.encodePacked(uint32(0x1), bytes32(0), newTxRoot, uint32(0x2), MAX_TARGET, uint32(0x8));
        spv.addHeaders(header);
        assertEq(spv.totalTxRoots(), 1);
        assertEq(spv.getTxRoot(0), newTxRoot);
        assertEq(spv.lastBlockhash(), hashHeader(header));
    }

    function testAddHeaders() public {
        bytes32 txRoot1 = keccak256("asdfasdflk 1");
        bytes32 txRoot2 = keccak256("asdfasdflk 2");
        bytes memory header1 = abi.encodePacked(uint32(0x1), bytes32(0), txRoot1, uint32(0x2), MAX_TARGET, uint32(0x7));
        bytes memory header2 =
            abi.encodePacked(uint32(0x5), hashHeader(header1), txRoot2, uint32(0x6), MAX_TARGET, uint32(0x11));

        spv.addHeaders(abi.encodePacked(header1, header2));

        assertEq(spv.totalTxRoots(), 2);
        assertEq(spv.getTxRoot(0), txRoot1);
        assertEq(spv.getTxRoot(1), txRoot2);
        assertEq(spv.lastBlockhash(), hashHeader(header2));

        BitcoinSPV altSpv = new BitcoinSPV();
        altSpv.addHeaders(header1);
        altSpv.addHeaders(header2);

        assertEq(altSpv.totalTxRoots(), 2);
        assertEq(altSpv.getTxRoot(0), txRoot1);
        assertEq(altSpv.getTxRoot(1), txRoot2);
        assertEq(altSpv.lastBlockhash(), hashHeader(header2));
    }

    function reverse(bytes32 _b) internal pure returns (bytes32 r) {
        assembly {
            function swapRound(inp, mask, shift) -> res {
                res := or(shl(shift, and(inp, mask)), and(shr(shift, inp), mask))
            }
            r := swapRound(_b, 0x00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff00ff, 0x08)
            r := swapRound(r, 0x0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff0000ffff, 0x10)
            r := swapRound(r, 0x00000000ffffffff00000000ffffffff00000000ffffffff00000000ffffffff, 0x20)
            r := swapRound(r, 0x0000000000000000ffffffffffffffff0000000000000000ffffffffffffffff, 0x40)
            r := or(shr(0x80, r), shl(0x80, r))
        }
    }

    function hashHeader(bytes memory _header) internal pure returns (bytes32) {
        require(_header.length == 80, "Invalid Header Size");
        return sha256(abi.encode(sha256(_header)));
    }
}
