pragma solidity ^0.8.0;

contract Lottery {
    address public owner;
    uint public ticketPrice;
    uint public totalTickets;
    mapping(address => uint) public tickets;
    address[] public players;

    constructor(uint _ticketPrice, uint _totalTickets) {
        owner = msg.sender;
        ticketPrice = _ticketPrice;
        totalTickets = _totalTickets;
    }

    function buyTickets(uint _numTickets) public payable {
        require(msg.value == _numTickets * ticketPrice, "Incorrect payment amount");
        require(_numTickets <= totalTickets - players.length, "Not enough tickets remaining");

        for (uint i = 0; i < _numTickets; i++) {
            players.push(msg.sender);
            tickets[msg.sender]++;
        }
    }

    function selectWinner() public {
        require(msg.sender == owner, "Only the owner can select the winner");
        require(players.length > 0, "No players in the lottery");

        uint index = uint(keccak256(abi.encodePacked(block.timestamp, block.difficulty, players.length))) % players.length;
        address winner = players[index];
        payable(winner).transfer(address(this).balance);

        // Reset the lottery for a new round
        players = new address[](0);
        totalTickets = 0;
    }

    function withdrawFunds() public {
        require(msg.sender == owner, "Only the owner can withdraw funds");
        payable(owner).transfer(address(this).balance);
    }
}
