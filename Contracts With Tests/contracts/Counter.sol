// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

contract Counter {
    string public countName;

    uint public count;

    constructor(string memory _countName, uint _count) {
        count = _count;
        countName = _countName;
    }

    // function getCount() public view returns(uint) {
    //     return count;
    // }

    function incrementCount() public {
        count++;
    }

    function decrementCount() public {
        count--;
    }
}
