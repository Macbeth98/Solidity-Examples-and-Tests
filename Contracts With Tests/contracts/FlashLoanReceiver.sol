// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "./FlashLoan.sol";
import "./Token.sol";

import "hardhat/console.sol";

contract FlashLoanReceiver {
    FlashLoan public pool;
    address public owner;

    event LoanReceived(address token, uint256 amount);

    constructor(address _poolAddress) {
        pool = FlashLoan(_poolAddress);
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner can call");
        _;
    }

    function receiveTokens(address _tokenAddress, uint256 _amount) external {
        require(msg.sender == address(pool), "The sender must be the pool");

        // Do stuff with the received tokens

        require(
            Token(_tokenAddress).balanceOf(address(this)) >= _amount,
            "Failed to receive the funds"
        );

        emit LoanReceived(_tokenAddress, _amount);

        // Return the funds
        require(
            Token(_tokenAddress).transfer(msg.sender, _amount),
            "Transfer of Tokens failed."
        );
    }

    function executeFlashLoan(uint _amount) external onlyOwner {
        pool.flashLoan(_amount);
    }
}
