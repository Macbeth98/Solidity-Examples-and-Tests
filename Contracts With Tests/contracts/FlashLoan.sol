// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "./Token.sol";
import "./ReentrancyGuard.sol";

interface IReceiver {
    function receiveTokens(address tokenAddress, uint256 amount) external;
}

contract FlashLoan is ReentrancyGuard {
    Token public token;
    uint256 public poolBalance;

    constructor(address _tokenAddress) {
        token = Token(_tokenAddress);
    }

    modifier validAmount(uint256 amount) {
        require(amount > 0, "The amount must be greater than 0!");
        _;
    }

    function depositTokens(
        uint256 _amount
    ) external nonReentrant validAmount(_amount) {
        token.transferFrom(msg.sender, address(this), _amount);

        poolBalance = poolBalance + _amount;
    }

    function flashLoan(
        uint256 _borrowAmount
    ) external nonReentrant validAmount(_borrowAmount) {
        uint256 balanceBefore = token.balanceOf(address(this));
        require(
            balanceBefore >= _borrowAmount,
            "Not enough tokens in the pool."
        );

        assert(poolBalance == balanceBefore);

        // Send tokens to receiver
        token.transfer(msg.sender, _borrowAmount);

        // Use loan, Get paid back
        IReceiver(msg.sender).receiveTokens(address(token), _borrowAmount);

        // Ensure loan paid back
        uint256 balanceAfter = token.balanceOf(address(this));
        require(balanceAfter >= balanceBefore, "Flash Loan was not paid back.");
    }
}
