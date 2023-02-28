// SPDX-License-Identifier: MIT
pragma solidity 0.8.15;

/// @author philogy <https://github.com/philogy>
library BTCUtils {
    function isValidMerkle(bytes32 _txRoot, bytes32 _baseEl, uint256 _index, bytes32[] calldata _proofEls)
        internal
        view
        returns (bool isValid)
    {
        assembly {
            let proofSize := _proofEls.length
            let proofOffset := _proofEls.offset

            let proofEnd := add(proofOffset, shl(5, proofSize))
            for {} lt(proofOffset, proofEnd) {} {
                // Use Solady trick to efficiently order elements in memory
                let scratch := shl(5, and(_index, 1))
                mstore(scratch, _baseEl)
                mstore(xor(0x20, scratch), calldataload(proofOffset))
                pop(staticcall(gas(), 0x02, 0x00, 0x40, 0x00, 0x20))
                pop(staticcall(gas(), 0x02, 0x00, 0x20, 0x00, 0x20))
                _baseEl := mload(0x00)
                _index := shr(1, _index)
                proofOffset := add(proofOffset, 0x20)
            }
            isValid := eq(_txRoot, _baseEl)
        }
    }

    function isValidMerkleCoinbase(bytes32 _txRoot, bytes32 _baseEl, bytes32[] calldata _proofEls)
        internal
        view
        returns (bool isValid)
    {
        assembly {
            let proofSize := _proofEls.length
            let proofOffset := _proofEls.offset

            let proofEnd := add(proofOffset, shl(5, proofSize))
            for {} lt(proofOffset, proofEnd) {} {
                mstore(0x00, _baseEl)
                mstore(0x20, calldataload(proofOffset))
                pop(staticcall(gas(), 0x02, 0x00, 0x40, 0x00, 0x20))
                pop(staticcall(gas(), 0x02, 0x00, 0x20, 0x00, 0x20))
                _baseEl := mload(0x00)
                proofOffset := add(proofOffset, 0x20)
            }
            isValid := eq(_txRoot, _baseEl)
        }
    }

    function reverseWord(bytes32 _b) internal pure returns (bytes32 r) {
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
}
