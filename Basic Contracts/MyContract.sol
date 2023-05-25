// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MyContract {

    // data Types

    uint256 public myUint = 1;
    int256 public  myInt = 1;
    int public integer = 1; // int256

    string public myString = "Hello";
    bytes32 public myBytes32 = "Hello";

    address public myAddress = 0x5B38Da6a701c568545dCfcB03FcB875f56beddC4;

    struct Person {
        uint age;
        string name;
    }

    Person public p1 = Person(24, "Macbeth");

    uint[] public intArray = [1, 2, 3];
    string[] public stringArray = ["ABC", "DEF"];
    string[] public anArray;

    function pushValue(string memory _value) public returns(uint) {
        anArray.push(_value);
        return anArray.length;
    }

    // 2D Array
    uint256[][] public array2D = [[1, 2, 3], [4, 5, 6]];

    // Mapping
    mapping (uint => string) public names;

    address public owner;

    constructor() {
        names[1] = "A";
        names[2] = "B";

        owner = msg.sender;
    }

    mapping (uint => Person) public personMap;

    function addPerson(uint _id, uint _age, string memory _name) public {
        personMap[_id] = Person(_age, _name);
    }


    // NESTED Mapping
    mapping (address => mapping (uint => Person)) public myPeople;

    function addMyPerson(uint _id, uint _age, string memory _name) public {
        myPeople[msg.sender][_id] = Person(_age, _name); 
    }

    // Conditionals & Loops

    // pure is used here as the function here is not altering the state but also not reading anything from the storage.
    function isEvenNumber(uint _number) public pure returns(bool) {
        if (_number % 2 == 0) {
            return true;
        } else {
            return false;
        }
    }

    function sumArrayEvenNums() public view returns(uint) {
        uint count = 0;

        for (uint i = 0; i < intArray.length; i++) {
            if (isEvenNumber(intArray[i])) {
                count += intArray[i];
            }
        }

        return count;
    }

    function isOwner() public view returns (bool) {
        return (owner == msg.sender);
    }
    
}