// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;


library RandomNumberLibrary {
    function getRandom(uint256 seed) internal view returns (uint256) {
        return uint256(keccak256(abi.encodePacked(block.timestamp, block.difficulty, seed))) % 100;
    }
}
