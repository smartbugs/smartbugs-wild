pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

contract IERC721 {
  function balanceOf(address owner) public view returns (uint256 balance);
  function ownerOf(uint256 tokenId) public view returns (address owner);

  function approve(address to, uint256 tokenId) public;
  function getApproved(uint256 tokenId) public view returns (address operator);

  function setApprovalForAll(address operator, bool _approved) public;
  function isApprovedForAll(address owner, address operator) public view returns (bool);

  function transferFrom(address from, address to, uint256 tokenId) public;
  function safeTransferFrom(address from, address to, uint256 tokenId) public;

  function safeTransferFrom(address from, address to, uint256 tokenId, bytes memory data) public;
}

contract Wizards {

  IERC721 internal constant wizards = IERC721(0x2F4Bdafb22bd92AA7b7552d270376dE8eDccbc1E);
  uint8 internal constant ELEMENT_FIRE = 1;
  uint8 internal constant ELEMENT_WIND = 2;
  uint8 internal constant ELEMENT_WATER = 3;
  uint256 internal constant MAX_WAIT = 86400; // 1 day timeout

  uint256 public ids;

  struct Game {
    uint256 id;
    // player 1
    address player1;
    uint256 player1TokenId;
    bytes32 player1SpellHash;
    uint8 player1Spell;
    // player 2
    address player2;
    uint256 player2TokenId;
    uint8 player2Spell;
    uint256 timer;
    // result
    address winner;
  }

  mapping (uint256 => Game) public games;
  
  event GameUpdate(uint256 indexed gameId);

  function start(uint256 tokenId, bytes32 spellHash) external {
    // TODO: transfer wizard to this contract
    // wizards.transferFrom(msg.sender, address(this), tokenId);
    
    // increment game ids
    ids++;

    // add game details
    games[ids].id = ids;
    games[ids].player1 = msg.sender;
    games[ids].player1TokenId = tokenId;
    games[ids].player1SpellHash = spellHash;
    
    emit GameUpdate(ids);
  }

  function join(uint256 gameId, uint256 tokenId, uint8 player2Spell) external {
    Game storage game = games[gameId];

    // player 1 must exist
    require(game.player1 != address(0));

    // player 2 must not exist
    require(game.player2 == address(0));
    
    // player1 cannot be player2
    require(game.player1 != game.player2);
    
    // spell must be valid
    require(player2Spell > 0 && player2Spell < 4);
    
    // TODO: player 2 wizard power can only be equal to or greater than player 1 wizard
   
    // TODO: transfer wizard to this contract
    // wizards.transferFrom(msg.sender, address(this), tokenId);

    // update game details
    game.player2 = msg.sender;
    game.player2TokenId = tokenId;
    game.player2Spell = player2Spell;
    game.timer = now;
    
    emit GameUpdate(gameId);
  }

  function revealSpell(uint256 gameId, uint256 salt, uint8 player1Spell) external {
    Game storage game = games[gameId];

    // player 2 must exist
    require(game.player2 != address(0));
    
    // game must not have ended
    require(game.winner == address(0));
    
    // spell must be valid
    require(player1Spell > 0 && player1Spell < 4);
    
    bytes32 revealHash = keccak256(abi.encodePacked(address(this), salt, player1Spell));

    // revealed hash must match committed hash
    require(revealHash == game.player1SpellHash);
    
    // set player 1 spell
    game.player1Spell = player1Spell;
    
    uint8 player2Spell = game.player2Spell;
    
    emit GameUpdate(gameId);

    if (player1Spell == player2Spell) {
      // draw
      game.winner = address(this);
      // TODO: return wizards to rightful owners
      // wizards.transferFrom(address(this), game.player1, game.player1TokenId);
      // wizards.transferFrom(address(this), game.player2, game.player2TokenId);
      return;
    }

    // Fire is effective against wind and weak to water
    if (player1Spell == ELEMENT_FIRE) {
      if (player2Spell == ELEMENT_WIND) {
        // player 1 wins
        _winner(gameId, game.player1);
      } else {
        // player 2 wins
        _winner(gameId, game.player2);
      }
    }

    // Water is effective against fire and weak to wind
    if (player1Spell == ELEMENT_WATER) {
      if (player2Spell == ELEMENT_FIRE) {
        // player 1 wins
        _winner(gameId, game.player1);
      } else {
        // player 2 wins
        _winner(gameId, game.player2);
      }
    }

    // Wind is effective against water and weak to fire
    if (player1Spell == ELEMENT_WIND) {
      if (player2Spell == ELEMENT_WATER) {
        // player 1 wins
        _winner(gameId, game.player1);
      } else {
        // player 2 wins
        _winner(gameId, game.player2);
      }
    }
  }

  function timeout(uint256 gameId) public {
    Game storage game = games[gameId];
    
    // game must not have ended
    require(game.winner == address(0));
    
    // game timer must have started
    require(game.timer != 0);

    // game must have timed out
    require(now - game.timer >= MAX_WAIT);

    // if player 1 did not reveal their spell
    // player2 wins automatically
    _winner(gameId, game.player2);
    
    emit GameUpdate(gameId);
  }

  function _winner(uint256 gameId, address winner) internal {
    Game storage game = games[gameId];
    game.winner = winner;
    // wizards.transferFrom(address(this), winner, game.player2TokenId);
    // wizards.transferFrom(address(this), winner, game.player1TokenId);
  }
  
  function getGames(uint256 from, uint256 limit, bool descending) public view returns (Game [] memory) {
    Game [] memory gameArr = new Game[](limit);
    if (descending) {
      for (uint256 i = 0; i < limit; i++) {
        gameArr[i] = games[from - i];
      }
    } else {
      for (uint256 i = 0; i < limit; i++) {
        gameArr[i] = games[from + i];
      }
    }
    return gameArr;
  }
}