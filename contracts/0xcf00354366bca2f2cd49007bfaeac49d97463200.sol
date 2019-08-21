contract ConnectSix {

  uint8 constant public board_size = 19;

  Game[] public games;

  struct Game {
      mapping(uint8 => mapping(uint8 => uint8)) board;
      uint8[] move_history;
      address[3] players;
      // 0 means game did not start yet
      uint8 turn;
      // Either 1 or 2. 0 means not finished
      uint8 winner;
      // true if players agreed to a draw
      uint time_per_move;
      // if move is not made by this time, opponent can claim victory
      uint deadline;
      // amount player 1 put in
      uint player_1_stake;
      // amount player 2 must send to join
      uint player_2_stake;
  }

  event LogGameCreated(uint game_num);
  event LogGameStarted(uint game_num);
  event LogVictory(uint game_num, uint8 winner);
  event LogMoveMade(uint game_num, uint8 x1, uint8 y1, uint8 x2, uint8 y2);

  function new_game(uint _time_per_move, uint opponent_stake) {
    games.length++;
    Game g = games[games.length - 1];
    g.players[1] = msg.sender;
    g.time_per_move = _time_per_move;
    g.player_1_stake = msg.value;
    g.player_2_stake = opponent_stake;
    // make the first move in the center of the board
    g.board[board_size / 2][board_size / 2] = 1;
    LogGameCreated(games.length - 1);
  }

  function join_game(uint game_num) {
    Game g = games[game_num];
    if (g.turn != 0 || g.player_2_stake != msg.value) {
      throw;
    }
    g.players[2] = msg.sender;
    // It's the second player's turn because the first player automatically makes a single move in the center
    g.turn = 2;
    g.deadline = now + g.time_per_move;
    LogGameStarted(game_num);
  }

  function player_1(uint game_num) constant returns (address) {
    return games[game_num].players[1];
  }
  
  function player_2(uint game_num) constant returns (address) {
    return games[game_num].players[2];
  }

  function board(uint game_num, uint8 x, uint8 y) constant returns (uint8) {
    return games[game_num].board[x][y];
  }

  function move_history(uint game_num) constant returns (uint8[]) {
      return games[game_num].move_history;
  }

  function single_move(uint game_num, uint8 x, uint8 y) internal {
    if (x > board_size || y > board_size) {
      throw;
    }
    Game g = games[game_num];
    if (g.board[x][y] != 0) {
      throw;
    }
    g.board[x][y] = g.turn;
  }

  function make_move(uint game_num, uint8 x1, uint8 y1, uint8 x2, uint8 y2) {
    Game g = games[game_num];
    if (g.winner != 0 || msg.sender != g.players[g.turn]) {
      throw;
    }
    single_move(game_num, x1, y1);
    single_move(game_num, x2, y2);
    g.turn = 3 - g.turn;
    g.deadline = now + g.time_per_move;
    g.move_history.length++;
    g.move_history[g.move_history.length - 1] = x1;
    g.move_history.length++;
    g.move_history[g.move_history.length - 1] = y1;
    g.move_history.length++;
    g.move_history[g.move_history.length - 1] = x2;
    g.move_history.length++;
    g.move_history[g.move_history.length - 1] = y2;
    LogMoveMade(game_num, x1, y1, x2, y2);
  }

  function make_move_and_claim_victory(uint game_num, uint8 x1, uint8 y1, uint8 x2, uint8 y2, uint8 wx, uint8 wy, uint8 dir) {
    make_move(game_num, x1, y1, x2, y2);
    claim_victory(game_num, wx, wy, dir);
  }
  
  function pay_winner(uint game_num) internal {
    Game g = games[game_num];
    uint amount = g.player_1_stake + g.player_2_stake;
    if (amount > 0 && !g.players[g.winner].send(amount)) {
      throw;
    }
  }

  function claim_time_victory(uint game_num) {
    Game g = games[game_num];
    if (g.winner != 0 || g.deadline == 0 || now <= g.deadline) {
      throw;
    }
    g.winner = 3 - g.turn;
    pay_winner(game_num);
    LogVictory(game_num, g.winner);
  }

  function claim_victory(uint game_num, uint8 x, uint8 y, uint8 dir) {
    Game g = games[game_num];
    if (x > board_size 
        || y > board_size
        || g.winner != 0
        || g.board[x][y] == 0
        || dir > 3) {
      throw;
    }
    // We don't have to worry about overflow and underflows here because all the values outside the 
    // 19 x 19 board are 0
    if (dir == 3) {
      // this is going diagonal (10:30pm)
      for (uint8 j = 1; j < 6; j++) {
        if (g.board[x - j*dx][y + j*dy] != g.board[x][y]) {
          throw;
        }
      }
    } else {
      uint8 dx = 0;
      uint8 dy = 0;
      if (dir == 2) {
        // diagonal - 1:30pm
        dx = 1;
        dy = 1;
      } else if (dir == 1) {
        // 12:00pm
        dy = 1;
      } else {
        // 3 pm
        dx = 1;
      }
      for (uint8 i = 1; i < 6; i++) {
        if (g.board[x + i*dx][y + i*dy] != g.board[x][y]) {
          throw;
        }
      }
    }
    g.winner = g.board[x][y];
    pay_winner(game_num);
    LogVictory(game_num, g.winner);
  }
}