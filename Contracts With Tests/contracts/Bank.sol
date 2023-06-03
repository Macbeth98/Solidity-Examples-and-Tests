// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "hardhat/console.sol";

contract Bank {
    using Address for address payable;

    mapping(address => uint256) public balance;

    function deposit() external payable {
        balance[msg.sender] += msg.value;
    }

    function withdraw() external {
        uint256 depositAmount = balance[msg.sender];
        // require(depositAmount > 0, "Amount must be greater than 0");
        // require(depositAmount >= _amount, "Not Enough Balance.");
        console.log(msg.sender, depositAmount);
        payable(msg.sender).sendValue(depositAmount);
        balance[msg.sender] = 0;
        console.log("Updating balance....", balance[msg.sender]);
    }
}
