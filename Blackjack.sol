// SPDX-License-Identifier: MIT

pragma solidity >=0.4.22 <0.9.0;

contract Blackjack{
  uint256 public constant minimumBet = 0.01 ether;

  struct Player {
    uint256 id;
    uint256 balance;
    bool isPlaying;
    uint256 handValue;
    uint8 numCards;
    bool isStand;
  }

  struct Deck {
    uint8[] cards;
    uint8 index;
  }

  mapping(address => Player) public players;
  address[] public playerList;
  Deck public deck;

  event GameStarted(address player, uint256 betAmount);
  event CardDealt(address player, uint8 card);
  event GameEnded(address player, uint256 payout);

  function startGame() external payable {
    require(msg.value >= minimumBet, "Minimum bet not met");
    require(!players[msg.sender].isPlaying, "Player already playing");

    players[msg.sender].id = playerList.length;
    players[msg.sender].balance = msg.value;
    players[msg.sender].isPlaying = true;

    playerList.push(msg.sender);

    if (playerList.length == 1) {
      initializeDeck();
    }

    emit GameStarted(msg.sender, msg.value);
  }

  function initializeDeck() internal {
    deck.cards = [2, 3, 4, 5, 6, 7, 8, 9, 10, 10, 10, 10, 11];
    deck.index = 0;
  }

  function dealCard(address player) internal {
    uint8 card = deck.cards[deck.index];
    deck.index += 1;

    players[player].handValue += card;
    players[player].numCards += 1;

    emit CardDealt(player, card);
  }

  function playerHit() external {
    require(players[msg.sender].isPlaying, "Player not playing");
    require(!players[msg.sender].isStand, "Player has already stood");

    dealCard(msg.sender);

    if (players[msg.sender].handValue > 21) {
      endGame();
    }
  }

  function playerStand() external {
    require(players[msg.sender].isPlaying, "Player not playing");
    require(!players[msg.sender].isStand, "Player has already stood");

    players[msg.sender].isStand = true;

    uint256 dealerHand = players[playerList[0]].handValue;
    while (dealerHand < 17) {
      dealCard(playerList[0]);
      dealerHand = players[playerList[0]].handValue;
    }

    if (dealerHand > 21 || dealerHand < players[msg.sender].handValue) {
      endGame();
    }
  }

  function endGame() internal {
    uint256 payout;

    if (players[msg.sender].handValue > 21) {
      payout = 0;
    } else if (players[playerList[0]].handValue > 21) {
      payout = players[msg.sender].balance * 2;
    } else if (players[msg.sender].handValue > players[playerList[0]].handValue) {
      payout = players[msg.sender].balance * 2;
    } else if (players[msg.sender].handValue == players[playerList[0]].handValue) {
      payout = players[msg.sender].balance;
    }

    players[msg.sender].balance += payout;
    players[msg.sender].isPlaying = false;
}
}