// SPDX-License-Identifier: GPL-3.0-only
pragma solidity 0.8.15;

/// @author philogy <https://github.com/philogy>
contract BitcoinSPV {
    error InvalidLength();
    error InvalidHeaderchain();

    bytes32[] internal txRoots;
    bytes32 public lastBlockhash;

    function addHeaders(bytes calldata _headerData) external {
        assembly {
            let headersLen := _headerData.length
            if mod(headersLen, 0x50) {
                mstore(0x00, 0x947d5a84)
                revert(0x1c, 0x04)
            }
            let freeMem := mload(0x40)
            calldatacopy(freeMem, _headerData.offset, headersLen)

            mstore(0x00, txRoots.slot)
            let txRootsValueSlot := keccak256(0x00, 0x20)
            let totalRoots := sload(txRoots.slot)
            let txRootsStartSlot := add(txRootsValueSlot, totalRoots)

            let hashesValid := 1
            let lastHash := sload(lastBlockhash.slot)
            let totalHeaders := div(_headerData.length, 0x50)
            for { let i := 0 } lt(i, totalHeaders) { i:= add(i, 1)} {
                let headerStart := add(freeMem, mul(i, 0x50))
                let prevBlockhash := mload(add(headerStart, 0x04))
                pop(staticcall(gas(), 0x02, headerStart, 0x50, 0x00, 0x20))
                hashesValid := and(hashesValid, eq(prevBlockhash, lastHash))
                lastHash := mload(0x00)
                sstore(add(txRootsStartSlot, i), mload(add(headerStart, 0x24)))
            }
            sstore(txRoots.slot, add(totalRoots, totalHeaders))

            if iszero(hashesValid) {
                mstore(0x00, 0x34207b29)
                revert(0x1c, 0x04)
            }

            sstore(lastBlockhash.slot, lastHash)
        }
    }

    function totalTxRoots() public view returns (uint256) {
        return txRoots.length;
    }

    function getTxRoot(uint256 _i) public view returns (bytes32) {
        return txRoots[_i];
    }
}
