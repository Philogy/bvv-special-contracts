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

    function testGetInscription() public {
        assertEq(
            this.callGetInscription(
                hex"02000000000101a7a48379c947824cc7481f8870bcf0b8481c12dd1081cafc9afc9d6ce74b51f300000000000000000001881300000000000022512092b3979c171013aede805a9d4205b30e4f89dd15358451cd80ccc80d8fba3a4a02fd48025100634d080200d9cf10f033c3af26e3997cacb9dd84b500000000022878dadae1c3f0c373c19279a74b36f85c5a925bfbaef0dceb03712a81e77c528cb64dd649ba1976fadbad550d0b422acc573d9afd8e6d651053c66bf6ad4b34d6ed95685f397345b49a42ce548102e7961416f13b0720a6fd9c65e7726abefcd36d9fdc6e7d8f7e74bef51ce7452befb6f8ff217b7e179c4bfec2b8c034537befe4a7a21a467f5f6ce37bf378aaf8863fc2e7036eacf13f5163babef46006c8b47b50d3548fd89dfe7c71e76ecff7d3afef9fcf71d1cb6fc359b635eb176533ec3fd0fd5be71171a63d809ab6e1ce412396cf71c12b0c343f3ef59d5dfccbe8e2ea47697ed2e2f56b9266ed0f49675a7074934383e44f9efd3c75d16a5f3e1f7dcb90377b1adf8f8da7e7bb2cdde4f2695d1cc8b44750d314945f2f293af739679de8bd85ab75fd43a79cdbf44a56a25a6cd1cdfe5b9cd9ccaecc0b96298af66a89377ad41cb628fafb8cb1ac32f08d5f82ce9924118e47b7e6f0bf7a0332ed09d4b4d3862593a4964d4dca7f67754e69eec6a4cde23bfe64696f0b3a557934c34ae2710071a63d839ae6a41aab7736d5c76deefa03a7e256cedacb91b0ce610767afbed2049b9ef285a7b6b32c581a32ed61cffffd5552ea6ecfa6a9ee7f3725b5ccd5f3b2f76feb3db7f5cb6c2724834c7b01352d82d1e0a3f567bdf5d60fbcf3279bc8df65977febcafa41f2a9d4f4d438655a76320dac0b0e4ce3bc98205cd7607df6deec3afda24b29ac8e4a52955f97052c7737f7abbedb0a32edd50140000000ffff58813554016821c13db5eed857d3f6935908eeddf8b96c5d8bb959b26fec9371d48742ee0dbd7ea900000000",
                0
            ),
            hex"00d9cf10f033c3af26e3997cacb9dd84b500000000022878dadae1c3f0c373c19279a74b36f85c5a925bfbaef0dceb03712a81e77c528cb64dd649ba1976fadbad550d0b422acc573d9afd8e6d651053c66bf6ad4b34d6ed95685f397345b49a42ce548102e7961416f13b0720a6fd9c65e7726abefcd36d9fdc6e7d8f7e74bef51ce7452befb6f8ff217b7e179c4bfec2b8c034537befe4a7a21a467f5f6ce37bf378aaf8863fc2e7036eacf13f5163babef46006c8b47b50d3548fd89dfe7c71e76ecff7d3afef9fcf71d1cb6fc359b635eb176533ec3fd0fd5be71171a63d809ab6e1ce412396cf71c12b0c343f3ef59d5dfccbe8e2ea47697ed2e2f56b9266ed0f49675a7074934383e44f9efd3c75d16a5f3e1f7dcb90377b1adf8f8da7e7bb2cdde4f2695d1cc8b44750d314945f2f293af739679de8bd85ab75fd43a79cdbf44a56a25a6cd1cdfe5b9cd9ccaecc0b96298af66a89377ad41cb628fafb8cb1ac32f08d5f82ce9924118e47b7e6f0bf7a0332ed09d4b4d3862593a4964d4dca7f67754e69eec6a4cde23bfe64696f0b3a557934c34ae2710071a63d839ae6a41aab7736d5c76deefa03a7e256cedacb91b0ce610767afbed2049b9ef285a7b6b32c581a32ed61cffffd5552ea6ecfa6a9ee7f3725b5ccd5f3b2f76feb3db7f5cb6c2724834c7b01352d82d1e0a3f567bdf5d60fbcf3279bc8df65977febcafa41f2a9d4f4d4655a76320dac0b0e4ce3bc98205cd7607df6deec3afda24b29ac8e4a52955f97052c7737f7abbedb0a32edd50140000000ffff5881355401"
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

    function callGetInscription(bytes calldata _tx, uint256 _inIndex) external pure returns (bytes memory) {
        return BTCUtils.getInscription(_tx, _inIndex);
    }

    function callGetWitnessRootFromCoinbase(bytes calldata _coinbaseTx) external returns (bytes32) {
        return BTCUtils.getWitnessRootFromCoinbase(_coinbaseTx);
    }

    function sha256d(bytes memory _inp) internal pure returns (bytes32) {
        return sha256(abi.encode(sha256(_inp)));
    }
}
