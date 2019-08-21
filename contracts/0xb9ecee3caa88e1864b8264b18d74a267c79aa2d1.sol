contract EthereumRouletteInterface {

  // The owner is responsible for committing and revealing spin results.
  address public owner;
  // Funds that are kept in reserve in order to pay off the winners in all revealed spins.
  // This number increases when new bets are made and decreases when winners collect their
  // winnings. When all winnings have been collected, this should be 0.
  uint public locked_funds_for_revealed_spins;
  // How much time (in seconds) the owner has to reveal the result to a spin after the
  // first bet has been made.
  uint public owner_time_limit;
  // Used to calculate the maximum bet a player can make.
  uint public fraction;
  // Maximum bet that a player can make on one of the numbers this spin.
  uint public max_bet_this_spin;
  // Contains all spins that happened so far. All spins, except that last two, are
  // settled. A spin is settled if and only if the spin_result and nonce are revealed by
  // the owner or owner_took_too_long flag is true. If a spin is settled, then players can
  // collect their winnings from that spin. It's possible that the last two spins are also
  // settled if the owner took too long.
  Spin[] public spins;

  struct Spin {
    // If owner takes too long (does not respond in time and someone calls the
    // player_declare_taking_too_long function), owner_took_too_long will be set to true
    // and all players will be paid out. This represents the total sum that will be paid
    // out in that case.
    uint total_payout;
    // The owner privately computes the sha3 of spin_result + nonce.
    bytes32 commit_hash;
    // Should be in [0, 37] range. 0 and 37 represent 0 and 00 on the roulette wheel.
    uint8 spin_result;
    // Some random value that the owner generates to make it impossible for someone to
    // guess the spin_result based on the commit_hash.
    bytes32 nonce;
    // Total amount that was bet on a particular number. Used to verify that the amount
    // bet on a number does not exceed max_bet_this_spin.
    mapping(uint8 => uint) total_bet_on_number;
    // Maps player address to a bet on a particular spin_result.
    mapping(address => mapping(uint8 => Bet)) bets;
    // This can be set to true if player_declare_taking_too_long is called if the owner is
    // taking too long. In that case all bets in this round will be winners.
    bool owner_took_too_long;
    // Time (in seconds) by which the spin result should be revealed by the owner.
    uint time_of_latest_reveal;
  }

  struct Bet {
    uint amount;
    // True if this bet was already paid.
    bool already_paid;
  }

  // Allows only the owner to call certain functions.
  modifier onlyOwner {}
  // Verifies no Ether is sent when calling a function.
  modifier noEther {}
  // Verifies that more than 0 Ether is sent when calling a function.
  modifier etherRequired {}

  // Player makes a bet on a particular spin_result.
  function player_make_bet(uint8 spin_result) etherRequired;

  // Player calls this function to collect all winnings from a particular spin.
  function player_collect_winnings(uint spin_num) noEther;

  // If the owner is taking too long to reveal the spin result, player can call this
  // function. If enough time passed, all bets in the last two spins (which are
  // unrevealed) will become winners. Player can then call player_collect_winnings.
  function player_declare_taking_too_long() noEther;

  // Owner reveals the spin_result and nonce for the first unrevealed spin (which is
  // second last in the spins array). Owner also also adds a new unrevealed spin to the
  // spins array. All new player bets will be on this new spin after this function is
  // called.
  //
  // The reason why we always have two unrevealed spins (instead of 1) is because of this
  // function. If there was only 1 unrevealed spin, when the owner tried revealing it,
  // an attacker would be able to see the spin result in the transaction that the owner
  // submits and quickly try to place a bet on the spin_result to try to get his
  // trasaction to be processed before the owner.
  function owner_reveal_and_commit(uint8 spin_result, bytes32 nonce, bytes32 commit_hash) onlyOwner noEther;

  // Set a new time limit for the owner between commit and reveal.
  function owner_set_time_limit(uint new_time_limit) onlyOwner noEther;

  // Allows the owner to deposit additional funds into the contract.
  function owner_deposit() onlyOwner etherRequired;

  // Allows the owner to withdraw the winnings. Makes sure that the owner does not
  // withdraw any funds that should be paid out to the players.
  function owner_withdraw(uint amount) onlyOwner noEther;

  // Updates the fraction (has an effect on how large the player bets can be).
  function owner_set_fraction(uint _fraction) onlyOwner noEther;

  function owner_transfer_ownership(address new_owner) onlyOwner noEther;

  event MadeBet(uint amount, uint8 spin_result, address player_addr);
  event Revealed(uint spin_number, uint8 spin_result);
}


contract EthereumRoulette is EthereumRouletteInterface {

  modifier onlyOwner {if (msg.sender != owner) throw; _}

  modifier noEther {if (msg.value > 0) throw; _}

  modifier etherRequired {if (msg.value == 0) throw; _}

  function EthereumRoulette() {
    owner = msg.sender;
    fraction = 800;
    owner_time_limit = 7 days;
    // The contract must always have 2 unrevealed spins. This is why we commit the first
    // two spins in the constructor. This means that it's not possible to bet on spin #1.
    bytes32 first_num_hash = 0x3c81cf7279de81901303687979a6b62fdf04ec93480108d2ef38090d6135ad9f;
    bytes32 second_num_hash = 0xb1540f17822cbe4daef5f1d96662b2dc92c5f9a2411429faaf73555d3149b68e;
    spins.length++;
    spins[spins.length - 1].commit_hash = first_num_hash;
    spins.length++;
    spins[spins.length - 1].commit_hash = second_num_hash;
    max_bet_this_spin = address(this).balance / fraction;
  }

  function player_make_bet(uint8 spin_result) etherRequired {
    Spin second_unrevealed_spin = spins[spins.length - 1];
    if (second_unrevealed_spin.owner_took_too_long
        || spin_result > 37
        || msg.value + second_unrevealed_spin.total_bet_on_number[spin_result] > max_bet_this_spin
        // verify it will be possible to pay the player in the worst case
        || msg.value * 36 + reserved_funds() > address(this).balance) {
      throw;
    }
    Bet b = second_unrevealed_spin.bets[msg.sender][spin_result];
    b.amount += msg.value;
    second_unrevealed_spin.total_bet_on_number[spin_result] += msg.value;
    second_unrevealed_spin.total_payout += msg.value * 36;
    if (second_unrevealed_spin.time_of_latest_reveal == 0) {
      second_unrevealed_spin.time_of_latest_reveal = now + owner_time_limit;
    }
    MadeBet(msg.value, spin_result, msg.sender);
  }

  function player_collect_winnings(uint spin_num) noEther {
    Spin s = spins[spin_num];
    if (spin_num >= spins.length - 2) {
      throw;
    }
    if (s.owner_took_too_long) {
      bool at_least_one_number_paid = false;
      for (uint8 roulette_num = 0; roulette_num < 38; roulette_num++) {
        Bet messed_up_bet = s.bets[msg.sender][roulette_num];
        if (messed_up_bet.already_paid) {
          throw;
        }
        if (messed_up_bet.amount > 0) {
          msg.sender.send(messed_up_bet.amount * 36);
          locked_funds_for_revealed_spins -= messed_up_bet.amount * 36;
          messed_up_bet.already_paid = true;
          at_least_one_number_paid = true;
        }
      }
      if (!at_least_one_number_paid) {
        // If at least one number does not get paid, we let the user know when they try to estimate gas.
        throw;
      }
    } else {
      Bet b = s.bets[msg.sender][s.spin_result];
      if (b.already_paid || b.amount == 0) {
        throw;
      }
      msg.sender.send(b.amount * 36);
      locked_funds_for_revealed_spins -= b.amount * 36;
      b.already_paid = true;
    }
  }

  function player_declare_taking_too_long() noEther {
    Spin first_unrevealed_spin = spins[spins.length - 2];
    bool first_spin_too_long = first_unrevealed_spin.time_of_latest_reveal != 0
        && now > first_unrevealed_spin.time_of_latest_reveal;
    Spin second_unrevealed_spin = spins[spins.length - 1];
    bool second_spin_too_long = second_unrevealed_spin.time_of_latest_reveal != 0
        && now > second_unrevealed_spin.time_of_latest_reveal;
    if (!(first_spin_too_long || second_spin_too_long)) {
      throw;
    }
    first_unrevealed_spin.owner_took_too_long = true;
    second_unrevealed_spin.owner_took_too_long = true;
    locked_funds_for_revealed_spins += (first_unrevealed_spin.total_payout + second_unrevealed_spin.total_payout);
  }

  function () {
    // Do not allow sending Ether without calling a function.
    throw;
  }

  function commit(bytes32 commit_hash) internal {
    uint spin_num = spins.length++;
    Spin second_unrevealed_spin = spins[spins.length - 1];
    second_unrevealed_spin.commit_hash = commit_hash;
    max_bet_this_spin = (address(this).balance - reserved_funds()) / fraction;
  }

  function owner_reveal_and_commit(uint8 spin_result, bytes32 nonce, bytes32 commit_hash) onlyOwner noEther {
    Spin first_unrevealed_spin = spins[spins.length - 2];
    if (!first_unrevealed_spin.owner_took_too_long) {
      if (sha3(spin_result, nonce) != first_unrevealed_spin.commit_hash || spin_result > 37) {
        throw;
      }
      first_unrevealed_spin.spin_result = spin_result;
      first_unrevealed_spin.nonce = nonce;
      locked_funds_for_revealed_spins += first_unrevealed_spin.total_bet_on_number[spin_result] * 36;
      Revealed(spins.length - 2, spin_result);
    }
    // If owner took too long, the spin result and nonce can be ignored because all payers
    // won.
    commit(commit_hash);
  }

  function owner_set_time_limit(uint new_time_limit) onlyOwner noEther {
    if (new_time_limit > 2 weeks) {
      // We don't want the owner to be able to set a time limit of something like 1000
      // years.
      throw;
    }
    owner_time_limit = new_time_limit;
  }

  function owner_deposit() onlyOwner etherRequired {}

  function owner_withdraw(uint amount) onlyOwner noEther {
    if (amount > address(this).balance - reserved_funds()) {
      throw;
    }
    owner.send(amount);
  }

  function owner_set_fraction(uint _fraction) onlyOwner noEther {
    if (_fraction == 0) {
      throw;
    }
    fraction = _fraction;
  }

  function owner_transfer_ownership(address new_owner) onlyOwner noEther {
    owner = new_owner;
  }

  function seconds_left() constant returns(int) {
    // Seconds left until player_declare_taking_too_long can be called.
    Spin s = spins[spins.length - 1];
    if (s.time_of_latest_reveal == 0) {
      return -1;
    }
    if (now > s.time_of_latest_reveal) {
      return 0;
    }
    return int(s.time_of_latest_reveal - now);
  }

  function reserved_funds() constant returns (uint) {
    // These funds cannot be withdrawn by the owner. This is the amount contract will have
    // to keep in reserve to be able to pay all players in the worst case.
    uint total = locked_funds_for_revealed_spins;
    Spin first_unrevealed_spin = spins[spins.length - 2];
    if (!first_unrevealed_spin.owner_took_too_long) {
      total += first_unrevealed_spin.total_payout;
    }
    Spin second_unrevealed_spin = spins[spins.length - 1];
    if (!second_unrevealed_spin.owner_took_too_long) {
      total += second_unrevealed_spin.total_payout;
    }
    return total;
  }

  function get_hash(uint8 number, bytes32 nonce) constant returns (bytes32) {
    return sha3(number, nonce);
  }

  function bet_this_spin() constant returns (bool) {
    // Returns true if there was a bet placed in the latest spin.
    Spin s = spins[spins.length - 1];
    return s.time_of_latest_reveal != 0;
  }

  function check_bet(uint spin_num, address player_addr, uint8 spin_result) constant returns (uint) {
    // Returns the amount of ether a player player bet on a spin result in a given spin
    // number.
    Spin s = spins[spin_num];
    Bet b = s.bets[player_addr][spin_result];
    return b.amount;
  }

  function current_spin_number() constant returns (uint) {
    // Returns the number of the current spin.
    return spins.length - 1;
  }
}