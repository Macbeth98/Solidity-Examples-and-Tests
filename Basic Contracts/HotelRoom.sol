// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract HotelRoom {

    enum Status { Vacant, Occupied }
    Status public currentStatus;

    address payable public owner;

    event Occupy(address _occupant, uint _value, bytes _data);

    constructor() {
        owner = payable(msg.sender);
        currentStatus = Status.Vacant;
    }

    modifier onlyWhileVacant {
        require(currentStatus == Status.Vacant, "Currently Occupied");
        _;
    }

    modifier costs(uint _amount) {
        require(msg.value >= _amount, "Not enough Ether provided");
        _;
    }

    function book() payable onlyWhileVacant costs(1 ether) public {

        // require (currentStatus == Status.Vacant, "Currently Occupied");

        // require(msg.value >= 1 ether, "Not enough Ether provided");

        // owner.transfer(msg.value);

        (bool sent, bytes memory data) = owner.call{value: msg.value}("");

        require(sent);

        currentStatus = Status.Occupied;

        emit Occupy(msg.sender, msg.value, data);
    }

}