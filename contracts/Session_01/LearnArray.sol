// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnArray{
    uint256[] public allPlantsId;

    function addPlant(uint256 _plantId) public {
        allPlantsId.push(_plantId);
    }

    function getTotalPlant() public view returns(uint256){
        return allPlantsId.length;
    }
    function getAllPlants() public view returns(uint256 [] memory){
        return allPlantsId;
    }
}