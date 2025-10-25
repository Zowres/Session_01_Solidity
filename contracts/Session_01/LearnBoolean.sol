// SPDX-License-Identifier: MIT
pragma solidity ^0.8.30;

contract LearnBoolean{
    bool public isAlive;
    bool public isBlooming;


    constructor(){
        isAlive = true;
        isBlooming = false;
    }


    function changeStats(bool _newStatus) public {
        isAlive = _newStatus;
    }

    function bloom() public{
        isBlooming = true;
    }
}