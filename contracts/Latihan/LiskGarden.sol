// SPDX-License-Identifier: MIT
pragma solidity ^ 0.8.30;

contract LiskGarden{
    enum GrowthStage{SEED,SPROUT,GROWING,BLOOMING}

    struct Plant{
        uint256 id;
        GrowthStage growthStage;
        address owner;
        uint8 waterLevel;
        uint256 plantedDate;
        uint256 lastWatered;
        bool isExists;
        bool isDead;
    }

    mapping(uint256 => Plant) public plants;

    mapping(address => uint256[]) public userPlants;

    uint256 public plantCounter;
    address public owner;

    uint256 public constant PLANT_PRICE = 0.001 ether;
    uint256 public constant PLANT_REWARD = 0.003 ether;
    uint256 public constant STAGE_DURATION = 1 minutes;
    uint256 public constant TIME_PLANT_DEPLETION = 30 seconds;
    uint8 public constant WATER_DEPLETION_RATE = 2;

    event PlantSeeded(address indexed owner, uint256 indexed plantId);
    event PlantWatered(uint256 indexed plantId, uint8 waterLevel);
    event PlantHarvested(uint256 indexed plantId, address indexed owner, uint256 reward);
    event PlantDied(uint256 indexed plantId);
    event StageAdvanced(uint256 indexed plantId, GrowthStage newStage);


    constructor() payable{
        owner = msg.sender;
    }

    function plantSeed() external payable returns(uint256){
        require(msg.value >= PLANT_PRICE, "Insufficient funds to plant a seed");

        plantCounter++;
        plants[plantCounter] = Plant({
            id : plantCounter,
            growthStage : GrowthStage.SEED,
            owner : msg.sender,
            waterLevel: 100,
            plantedDate: block.timestamp,
            lastWatered: block.timestamp,
            isExists: true,
            isDead: false
        });

        userPlants[msg.sender].push(plantCounter);
        emit PlantSeeded(msg.sender, plantCounter);
        return plantCounter;

    }

    function calculateWaterLevel(uint256 plantId) public view returns(uint8){
        Plant storage plant = plants[plantId];

        if(!plant.isExists || plant.isDead){
            return 0;
        }

        uint256 timeSinceWatered = block.timestamp - plant.lastWatered;
        uint256 depletion = timeSinceWatered/ TIME_PLANT_DEPLETION;
        uint256 waterLost = depletion * WATER_DEPLETION_RATE;

        if(waterLost >= plant.waterLevel){
            return 0;
        }

        return uint8(plant.waterLevel - waterLost);

    }

    function updateWaterLevel(uint256 plantId) internal {
        Plant storage plant = plants[plantId];
        uint8 currentWater = calculateWaterLevel(plantId);

        plant.waterLevel = currentWater;

        if(currentWater == 0 && !plant.isDead){
            plant.isDead = true;
            emit PlantDied(plantId);
        }
    }

    function waterPlant(uint256 plantId) external {
        Plant storage plant = plants[plantId];
        require(plant.isExists,"Plant doesn't exists");
    
        require(plant.owner == msg.sender, "Not the plant owner");
        require(!plant.isDead , "Plant is already Dead!");

        plant.waterLevel = 100;
        plant.lastWatered = block.timestamp;
        emit PlantWatered(plantId, plant.waterLevel);

        //update plant stage nanti
        updatePlantStage(plantId);
    }

    function updatePlantStage(uint256 plantId) public {
        Plant storage plant = plants[plantId];
        require(plant.isExists, "Plant does not exists");

        updateWaterLevel(plantId);

        if(plant.isDead) return;

        GrowthStage oldStage = plant.growthStage;

        uint256 timeSincedPlanted = block.timestamp - plant.plantedDate;

        if(timeSincedPlanted >= STAGE_DURATION && plant.growthStage == GrowthStage.SEED){
            plant.growthStage = GrowthStage.SPROUT;
        }
        else if(timeSincedPlanted >= STAGE_DURATION * 2 && plant.growthStage == GrowthStage.SPROUT){
            plant.growthStage = GrowthStage.GROWING;
        }
        else if(timeSincedPlanted >= STAGE_DURATION * 3 && plant.growthStage == GrowthStage.GROWING){
            plant.growthStage = GrowthStage.BLOOMING;
        }

        if (oldStage != plant.growthStage){
            emit StageAdvanced(plantId , plant.growthStage );
        }
    }


    function harvestPlant(uint256 plantId) external {
        Plant storage plant = plants[plantId];
        require(plant.isExists, "Plant does not exists");

        require(msg.sender == plant.owner, "Not the plant owner");
        require(!plant.isDead,"Your plant already dead!");

        updatePlantStage(plantId);
        
        require(plant.growthStage == GrowthStage.BLOOMING, "Plant is not ready to harvest");

        plant.isExists = false;

        emit PlantHarvested(plantId, msg.sender, PLANT_REWARD);

        (bool success, ) = msg.sender.call{value: PLANT_REWARD}("");

        require(success,"Reward Transfer failed");

    }

    function getPlant(uint256 plantId) external view returns (Plant memory){
        Plant memory plant = plants[plantId];
        plant.waterLevel = calculateWaterLevel(plantId);
        return plant;
    }

    function getUserPlants(address user) external view returns(uint256 [] memory){
        return userPlants[user];
    }


    function withdraw() external {
        require(msg.sender == owner, "Bukan owner");
        (bool success, ) = owner.call{value: address(this).balance}("");
        require(success, "Transfer gagal");
    }

    receive() external payable {}


}
