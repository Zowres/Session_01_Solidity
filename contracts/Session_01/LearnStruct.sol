// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnStruct{
    enum GrowthStage {SEED,SPROUT,GROWING,BLOOMING}

    struct Plant{
        uint256 id;
        address owner;
        GrowthStage growthStage;
        uint8 waterLevel;
        bool isAlive;
    }

    Plant public myPlant;

    constructor(){
        myPlant = Plant({
            id: 1,
            owner: msg.sender,
            growthStage: GrowthStage.SEED,
            waterLevel: 100,
            isAlive: true
        });

    }

    function water() public{
        myPlant.waterLevel = 100;
    }

    function grow() public {
        if(myPlant.growthStage == GrowthStage.SEED){
            myPlant.growthStage = GrowthStage.SPROUT;
        }else if(myPlant.growthStage == GrowthStage.SPROUT){
            myPlant.growthStage = GrowthStage.GROWING;
        }else if(myPlant.growthStage == GrowthStage.GROWING){
            myPlant.growthStage = GrowthStage.BLOOMING;
        }
    }


}