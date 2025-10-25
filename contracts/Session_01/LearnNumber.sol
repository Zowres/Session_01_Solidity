// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnNumber{
    // disini buat untuk data tanaman
    uint256 plantId;
    uint256 public waterLevel;

    constructor(){
        // disini kita default dulu aja untuk awalnya
        plantId = 1;
        waterLevel = 100;
    }

    function changePlantId (uint256 _newPlantId) public{
        plantId = _newPlantId;
    }

    function addWater () public {
        waterLevel += 10;
    }
}