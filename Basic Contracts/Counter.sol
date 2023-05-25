// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;


contract Counter {

    uint public count = 0;

    // constructor()  {
    //     count = 0;
    // }

    // function getCount() public view returns(uint) {
    //     return count;
    // }

    function incrementCount() public {
        count++;
    }
}
