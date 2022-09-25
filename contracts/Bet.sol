// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Bet {
    address private owner;
    string winnerTeam = "India";    //statically adding winning team
    bool public isStarted = false;  //match started
    bool public isEnded = false;    //match ended

    struct Participant {
        address payable player;
        string team;
        uint value;
    }

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // mapping (address => Participant) private players;
    Participant[] betters;
    Participant[] winners;

    //start match by calling function
    function startMatch() public onlyOwner {
        isStarted = true;
        isEnded = false;
    }

    //end match by calling function
    function endMatch() public onlyOwner {
        require(isStarted == true, "Match is not started");
        isEnded = true;
        if (betters.length < 1) {
            isStarted = false;
        } else {
            chooseWinners();
        }
    }

    //check betters are already entered or not
    function alreadyEnter() private view returns (bool) {
        for (uint i = 0; i < betters.length; i++) {
            if (betters[i].player == msg.sender) {
                return true;
            }
        }
        return false;
    }

    //add new betters
    function addPlayers(string memory _team) public payable {
        require(
            isStarted == false,
            "Match is started, players cannot enter now"
        );
        require(isEnded != true, "Match is ended");
        require(msg.sender != owner, "Owner cannot enter");
        require(alreadyEnter() == false, "Player already entered");
        require(msg.value == 1 ether, "1 Ether required to participate");
        betters.push(Participant(payable(msg.sender), _team, msg.value));
    }

    //get betters length
    function getbettersLength() public view returns (uint) {
        return betters.length;
    }

    //check the betters who bet on winning team
    function chooseWinners() private {
        if (betters.length >= 1) {
            for (uint i = 0; i < betters.length; i++) {
                if (
                    sha256(abi.encode(betters[i].team)) ==
                    sha256(abi.encode(winnerTeam))
                ) {
                    winners.push(
                        Participant({
                            player: payable(betters[i].player),
                            team: betters[i].team,
                            value: betters[i].value
                        })
                    );
                }
            }
            isStarted = false;
            // isEnded = false;
            delete betters;
            distributeWinningAmount();
        }
    }

    //distributing amount to betters who bet on winning team
    function distributeWinningAmount() private {
        uint totalWinner = winners.length;
        uint totalBalance = address(this).balance;
        uint amountPerPlayer = totalBalance / totalWinner;

        for (uint i = 0; i < winners.length; i++) {
            winners[i].player.transfer(amountPerPlayer);
        }
        delete winners;
    }
}
