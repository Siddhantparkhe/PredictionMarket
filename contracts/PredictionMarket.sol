// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract PredictionMarket {
    struct Bet {
        address user;
        uint amount;
        bool prediction; // true = Yes, false = No
    }

    address public owner;
    string public question;
    bool public marketClosed;
    bool public result; // true or false

    Bet[] public bets;
    mapping(address => bool) public hasBet;
    uint public totalYes;
    uint public totalNo;

    constructor(string memory _question) {
        owner = msg.sender;
        question = _question;
        marketClosed = false;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call");
        _;
    }

    modifier marketOpen() {
        require(!marketClosed, "Market is closed");
        _;
    }

    function placeBet(bool _prediction) external payable marketOpen {
        require(msg.value > 0, "Bet amount must be greater than zero");
        require(!hasBet[msg.sender], "Already placed a bet");

        bets.push(Bet(msg.sender, msg.value, _prediction));
        hasBet[msg.sender] = true;

        if (_prediction) {
            totalYes += msg.value;
        } else {
            totalNo += msg.value;
        }
    }

    function closeMarket(bool _actualResult) external onlyOwner {
        require(!marketClosed, "Market already closed");
        marketClosed = true;
        result = _actualResult;

        uint totalPool = address(this).balance;
        uint winnersPool = result ? totalYes : totalNo;

        for (uint i = 0; i < bets.length; i++) {
            Bet memory b = bets[i];
            if (b.prediction == result) {
                uint reward = (b.amount * totalPool) / winnersPool;
                payable(b.user).transfer(reward);
            }
        }
    }

    function getTotalBets() external view returns (uint) {
        return bets.length;
    }
}

