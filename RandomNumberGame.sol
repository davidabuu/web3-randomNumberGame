// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;
import { RandomNumberLibrary } from "./RandomNumberLibrary.sol";

contract RandomNumberGame {
    using RandomNumberLibrary for uint256;

    struct Players {
        string name;
        address playerAddress;
    }

    mapping(address => Players) public players;
    mapping(address => bool) public isRegistered;

    uint256 public constant MINIMUM_USD = 2e18;
    address public immutable i_owner;
    bool public lotteryOpen; // Tracks if the lottery is active

    constructor() {
        i_owner = msg.sender;
        lotteryOpen = false; // Lottery starts as closed
    }

    //Only owner can start the lottery
    function startLottery() public onlyOwner {
        require(!lotteryOpen, "Lottery already started!");
        lotteryOpen = true;
    }

    //Only owner can end the lottery
    function endLottery() public onlyOwner {
        require(lotteryOpen, "Lottery is not active!");
        lotteryOpen = false;
    }

    //Players can only enter if the lottery is open
    function enterLottery(string memory playerName) public payable {
        require(lotteryOpen, "Lottery is not open!");
        require(!isRegistered[msg.sender], "User Already Exists");
        require(msg.value >= MINIMUM_USD, "Not enough ETH to enter the lottery game");

        players[msg.sender] = Players(playerName, msg.sender);
        isRegistered[msg.sender] = true;
    }

    //Only owner can generate a random number
    function getRandomNumber() public view onlyOwner returns (uint256) {
        return block.timestamp.getRandom();
    }

    //Players can try to withdraw if they guess the correct number
    function withdraw(uint256 guessNumber) public {
        require(isRegistered[msg.sender], "User does not exist");
        require(lotteryOpen, "Lottery is not active!");

        if (guessNumber == getRandomNumber()) {
            bool sendSuccess = payable(msg.sender).send(address(this).balance);
            require(sendSuccess, "Send Failed");
            delete players[msg.sender];
        } else {
            revert("You failed, try again");
        }
    }

    // Modifier to restrict functions to the owner
    modifier onlyOwner() {
        require(i_owner == msg.sender, "Not the owner of this contract");
        _;
    }
}
