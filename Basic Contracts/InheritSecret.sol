// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


contract Ownable {
    address owner;

    modifier onlyOwner() {
        require(msg.sender == owner, "Only Owner");
        _;
    }

    constructor() {
        owner = msg.sender;
    }
}

contract SecretVault {
    string secret;

    constructor(string memory _secret) {
        secret = _secret;
    }

    function getSecret() public view returns (string memory) {
        return secret;
    }
}

contract InheritSecret is Ownable {
    // address public owner;
    // string secret;

    address secretVault;

    constructor(string memory _secret) {
        SecretVault _secretVault = new SecretVault(_secret);
        secretVault = address(_secretVault);
        super;
    }


    // modifier onlyOwner() {
    //     require(msg.sender == owner, "Only Owner");
    //     _;
    // }

    function getSecret() public view onlyOwner returns(string memory) {
        return SecretVault(secretVault).getSecret();
    }
}