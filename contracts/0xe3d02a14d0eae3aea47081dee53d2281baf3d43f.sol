pragma solidity ^0.5.4;

/**
 *	Lottery 5 of 36 (Weekly)
 */
 
contract SmartLotto {
    
	// For safe math operations
    using SafeMath for uint;
    
	// Member struct
	struct Member {
		address addr;								// Address
		uint ticket;								// Ticket number
		uint8[5] numbers;                           // Selected numbers
		uint prize;                                 // Winning prize
		uint8 payout;								// Payout prize
	}
	
	// Game struct
	struct Game {
		uint datetime;								// Game timestamp
		uint8[5] win_numbers;						// Winning numbers
		uint membersCounter;						// Members count
		uint totalFund;                             // Total prize fund
		uint p2;									// Prize for 2 guessed numbers
		uint p3;									// Prize for 3 guessed numbers
		uint p4;									// Prize for 4 guessed numbers
		uint p5;									// Prize for 5 guessed numbers
		uint8 status;                               // Game status: 0 - created, 1 - active
		mapping(uint => Member) members;		    // Members list
	}
	
	mapping(uint => Game) public games;
	
	uint private CONTRACT_STARTED_DATE = 0;
	uint private constant TICKET_PRICE = 0.01 ether;
	uint private constant MAX_NUMBER = 36;						            // Максимально возможное число -> 36
	
	uint private constant PERCENT_FUND_JACKPOT = 15;                        // (%) Increase Jackpot
	uint private constant PERCENT_FUND_4 = 35;                              // (%) Fund 4 of 5
	uint private constant PERCENT_FUND_3 = 30;                              // (%) Fund 3 of 5
    uint private constant PERCENT_FUND_2 = 20;                              // (%) Fund 2 of 5
    
	uint public JACKPOT = 0;
	
	// Init params
	uint public GAME_NUM = 0;
	uint private constant return_jackpot_period = 25 weeks;
	uint private start_jackpot_amount = 0;
	
	uint private constant PERCENT_FUND_PR = 15;                             // (%) PR & ADV
	uint private FUND_PR = 0;                                               // Fund PR & ADV

	// Addresses
	address private constant ADDRESS_SERVICE = 0x203bF6B46508eD917c085F50F194F36b0a62EB02;
	address payable private constant ADDRESS_START_JACKPOT = 0x531d3Bd0400Ae601f26B335EfbD787415Aa5CB81;
	address payable private constant ADDRESS_PR = 0xCD66911b6f38FaAF5BFeE427b3Ceb7D18Dd09F78;
	
	// Events
	event NewMember(uint _gamenum, uint _ticket, address _addr, uint8 _n1, uint8 _n2, uint8 _n3, uint8 _n4, uint8 _n5);
	event NewGame(uint _gamenum);
	event UpdateFund(uint _fund);
	event UpdateJackpot(uint _jackpot);
	event WinNumbers(uint _gamenum, uint8 _n1, uint8 _n2, uint8 _n3, uint8 _n4, uint8 _n5);
	event PayOut(uint _gamenum, uint _ticket, uint _prize, uint8 _payout);
	
	// For many processing transactions
	uint private constant POOL_SIZE = 30;										// MAX processing tickets by transaction
	uint private POOL_COUNTER = 0;
	
	uint private w2 = 0;
	uint private w3 = 0;
	uint private w4 = 0;
	uint private w5 = 0;
	
	// Entry point
	function() external payable {
	    
        // Select action
		if(msg.sender == ADDRESS_START_JACKPOT) {
			processStartingJackpot();
		} else {
			if(msg.sender == ADDRESS_SERVICE) {
				startGame();
			} else {
				processUserTicket();
			}
		}
		
    }
	

	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// Starting Jackpot action
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	function processStartingJackpot() private {
		// If value > 0, increase starting Jackpot
		if(msg.value > 0) {
			JACKPOT += msg.value;
			start_jackpot_amount += msg.value;
			emit UpdateJackpot(JACKPOT);
		// Else, return starting Jackpot
		} else {
			if(start_jackpot_amount > 0){
				_returnStartJackpot();
			}
		}
		
	}
	
	// Return starting Jackpot after 6 months
	function _returnStartJackpot() private { 
		
		if(JACKPOT > start_jackpot_amount * 2 || (now - CONTRACT_STARTED_DATE) > return_jackpot_period) {
			
			if(JACKPOT > start_jackpot_amount) {
				ADDRESS_START_JACKPOT.transfer(start_jackpot_amount);
				JACKPOT = JACKPOT - start_jackpot_amount;
				start_jackpot_amount = 0;
			} else {
				ADDRESS_START_JACKPOT.transfer(JACKPOT);
				start_jackpot_amount = 0;
				JACKPOT = 0;
			}
			emit UpdateJackpot(JACKPOT);
			
		} 
		
	}
	
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// Running a Game
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	function startGame() private {
	    
		if(GAME_NUM == 0) {
		    GAME_NUM = 1;
		    games[GAME_NUM].datetime = now;
		    games[GAME_NUM].status = 1;
		    CONTRACT_STARTED_DATE = now;
		} else {
		    
	        if(games[GAME_NUM].status == 1) {
	            processGame();
		    } else {
		        games[GAME_NUM].status = 1;
		    }
		    
		}
        
	}
	
	function processGame() private {
	    
		uint8[5] memory win_numbers;
		uint8 mn = 0;
		
	    // 1-st time generate winning numbers
		if(POOL_COUNTER == 0) {
			
			w2 = 0;
			w3 = 0;
			w4 = 0;
			w5 = 0;
		
			// Generate winning numbers
			for(uint8 i = 0; i < 5; i++) {
				win_numbers[i] = random(i);
			}

			// Sort winning numbers array
			win_numbers = sortNumbers(win_numbers);
	    
			// Change dublicate numbers
			for(uint8 i = 0; i < 4; i++) {
				for(uint8 j = i + 1; j < 5; j++) {
					if(win_numbers[i] == win_numbers[j]) {
						win_numbers[j]++;
					}
				}
			}
	    
			games[GAME_NUM].win_numbers = win_numbers;
			emit WinNumbers(GAME_NUM, win_numbers[0], win_numbers[1], win_numbers[2], win_numbers[3], win_numbers[4]);
		
		} else {
		    
		    win_numbers = games[GAME_NUM].win_numbers;
		    
		}
		

		// Process tickets list
		uint start 	= POOL_SIZE * POOL_COUNTER + 1;
		uint end 	= POOL_SIZE * POOL_COUNTER + POOL_SIZE;
		
		if(end > games[GAME_NUM].membersCounter) end = games[GAME_NUM].membersCounter;
		
		uint _w2 = 0;
		uint _w3 = 0;
		uint _w4 = 0;
		uint _w5 = 0;
		
	    for(uint i = start; i <= end; i++) {
	       
	        mn = findMatch(win_numbers, games[GAME_NUM].members[i].numbers);
				
			if(mn == 2) { _w2++; continue; }
			if(mn == 3) { _w3++; continue; }
			if(mn == 4) { _w4++; continue; }
			if(mn == 5) { _w5++; }
				
	    }
		
		if(_w2 != 0) { w2 += _w2; }
		if(_w3 != 0) { w3 += _w3; }
		if(_w4 != 0) { w4 += _w4; }
		if(_w5 != 0) { w2 += _w5; }
		
		if(end == games[GAME_NUM].membersCounter) {
		
			// Fund calculate
			uint totalFund = games[GAME_NUM].totalFund;
			
			uint fund2 = totalFund * PERCENT_FUND_2 / 100;
			uint fund3 = totalFund * PERCENT_FUND_3 / 100;
			uint fund4 = totalFund * PERCENT_FUND_4 / 100;
			uint _jackpot = JACKPOT + totalFund * PERCENT_FUND_JACKPOT / 100;

			// If exist tickets 2/5
			if(w2 != 0) { 
				games[GAME_NUM].p2 = fund2 / w2; 
			} else { 
				_jackpot += fund2; 
			}
			
			// If exist tickets 3/5
			if(w3 != 0) { 
				games[GAME_NUM].p3 = fund3 / w3; 
			} else {
				_jackpot += fund3;
			}
			
			// If exist tickets 4/5
			if(w4 != 0) { 
				games[GAME_NUM].p4 = fund4 / w4; 
			} else {
				_jackpot += fund4;
			}
			
			// If exist tickets 5/5
			if(w5 != 0) { 
				games[GAME_NUM].p5 = _jackpot / w5; 
				JACKPOT = 0;
				start_jackpot_amount = 0;
			} else {
				JACKPOT = _jackpot;
			}

			emit UpdateJackpot(JACKPOT);
	    
			// Init next Game /////////////////////////////////////////////////
			GAME_NUM++;
			games[GAME_NUM].datetime = now;
			emit NewGame(GAME_NUM);
			
			POOL_COUNTER = 0;

			// Transfer PR 
			ADDRESS_PR.transfer(FUND_PR);
			FUND_PR = 0;
	    
		} else {
			
			POOL_COUNTER++;

		}
		
	}
	
	// Find match numbers function
	function findMatch(uint8[5] memory arr1, uint8[5] memory arr2) private pure returns (uint8) {
	    
	    uint8 cnt = 0;
	    
	    for(uint8 i = 0; i < 5; i++) {
	        for(uint8 j = 0; j < 5; j++) {
	            if(arr1[i] == arr2[j]) {
	                cnt++;
	                break;
	            }
	        }
	    }
	    
	    return cnt;

	}
	
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	// Buy ticket process (if msg.value != 0.0 ETH) or payout winnings (if msg.value == 0.0 ETH)
	///////////////////////////////////////////////////////////////////////////////////////////////////////
	function processUserTicket() private {
		
		// Payout
		if(msg.value == 0) {
			
			uint payoutAmount = 0;
			for(uint i = 1; i <= GAME_NUM; i++) {
				
				Game memory game = games[i];
				if(game.win_numbers[0] == 0) { continue; }
				
				for(uint j = 1; j <= game.membersCounter; j++) {
				    
				    Member memory member = games[i].members[j];
					
					if(member.payout == 1) { continue; }
					
					uint8 mn = findMatch(game.win_numbers, member.numbers);
					
					if(mn == 2) {
						games[i].members[j].prize = game.p2;
						payoutAmount += game.p2;
					}
					
					if(mn == 3) {
						games[i].members[j].prize = game.p3;
						payoutAmount += game.p3;
					}
					
					if(mn == 4) {
						games[i].members[j].prize = game.p4;
						payoutAmount += game.p4;
					}
					
					if(mn == 5) {
						games[i].members[j].prize = game.p5;
						payoutAmount += game.p5;
					}
					
					games[i].members[j].payout = 1;
					
					emit PayOut(i, j, games[i].members[j].prize, 1);
					
				}
				
			}
			
			if(payoutAmount != 0) msg.sender.transfer(payoutAmount);
			
			return;
		}
		
		// Buy ticket
		if( GAME_NUM > 0 && games[GAME_NUM].status == 1 && POOL_COUNTER == 0 ) {

		    if(msg.value == TICKET_PRICE) {
			    createTicket();
		    } else {
			    if(msg.value < TICKET_PRICE) {
				    FUND_PR = FUND_PR + msg.value.mul(PERCENT_FUND_PR).div(100);
				    games[GAME_NUM].totalFund = games[GAME_NUM].totalFund + msg.value.mul(100 - PERCENT_FUND_PR).div(100);
				    emit UpdateFund(games[GAME_NUM].totalFund);
			    } else {
				    msg.sender.transfer(msg.value.sub(TICKET_PRICE));
				    createTicket();
			    }
		    }
		
		} else {
		     msg.sender.transfer(msg.value);
		}
		
	}
	
	function createTicket() private {
		
		bool err = false;
		uint8[5] memory numbers;
		
		// Calculate funds
		FUND_PR = FUND_PR + TICKET_PRICE.mul(PERCENT_FUND_PR).div(100);
		games[GAME_NUM].totalFund = games[GAME_NUM].totalFund + TICKET_PRICE.mul(100 - PERCENT_FUND_PR).div(100);
		emit UpdateFund(games[GAME_NUM].totalFund);
		
		// Parse and check msg.DATA
		(err, numbers) = ParseCheckData();
		
		uint mbrCnt;
		
		// If error DATA, generate random ticket numbers
		if(err) {
		    
		    // Generate numbers
	        for(uint8 i = 0; i < 5; i++) {
	            numbers[i] = random(i);
	        }

	        // Change dublicate numbers
	        for(uint8 i = 0; i < 4; i++) {
	            for(uint8 j = i + 1; j < 5; j++) {
	                if(numbers[i] == numbers[j]) {
	                    numbers[j]++;
	                }
	            }
	        }
	        
		}
		
		// Sort ticket numbers array
	    numbers = sortNumbers(numbers);

	    // Increase member counter
	    games[GAME_NUM].membersCounter++;
	    mbrCnt = games[GAME_NUM].membersCounter;

	    // Save member
	    games[GAME_NUM].members[mbrCnt].addr = msg.sender;
	    games[GAME_NUM].members[mbrCnt].ticket = mbrCnt;
	    games[GAME_NUM].members[mbrCnt].numbers = numbers;
		    
	    emit NewMember(GAME_NUM, mbrCnt, msg.sender, numbers[0], numbers[1], numbers[2], numbers[3], numbers[4]);

	}
	
	
	// Parse and check msg.DATA function
	function ParseCheckData() private view returns (bool, uint8[5] memory) {
	    
	    bool err = false;
	    uint8[5] memory numbers;
	    
	    // Check 5 numbers entered
	    if(msg.data.length == 5) {
	        
	        // Parse DATA string
		    for(uint8 i = 0; i < msg.data.length; i++) {
		        numbers[i] = uint8(msg.data[i]);
		    }
		    
		    // Check range: 1 - MAX_NUMBER
		    for(uint8 i = 0; i < numbers.length; i++) {
		        if(numbers[i] < 1 || numbers[i] > MAX_NUMBER) {
		            err = true;
		            break;
		        }
		    }
		    
		    // Check dublicate numbers
		    if(!err) {
		    
		        for(uint8 i = 0; i < numbers.length - 1; i++) {
		            for(uint8 j = i + 1; j < numbers.length; j++) {
		                if(numbers[i] == numbers[j]) {
		                    err = true;
		                    break;
		                }
		            }
		            if(err) {
		                break;
		            }
		        }
		        
		    }
		    
	    } else {
	        err = true;
	    }

	    return (err, numbers);

	}
	
	// Sort array of number function
	function sortNumbers(uint8[5] memory arrNumbers) private pure returns (uint8[5] memory) {
	    
	    uint8 temp;
	    
	    for(uint8 i = 0; i < arrNumbers.length - 1; i++) {
            for(uint j = 0; j < arrNumbers.length - i - 1; j++)
                if (arrNumbers[j] > arrNumbers[j + 1]) {
                    temp = arrNumbers[j];
                    arrNumbers[j] = arrNumbers[j + 1];
                    arrNumbers[j + 1] = temp;
                }    
	    }
        
        return arrNumbers;
        
	}
	
	// Contract address balance
    function getBalance() public view returns(uint) {
        uint balance = address(this).balance;
		return balance;
	}
	
	// Generate random number
	function random(uint8 num) internal view returns (uint8) {
        return uint8((uint(blockhash(block.number - 1 - num*2)) + now) % MAX_NUMBER + 1);
    } 
    
	
	//  API  //
	
	// i - Game number
	function getGameInfo(uint i) public view returns (uint, uint, uint8, uint8, uint8, uint8, uint8, uint8, uint, uint, uint, uint) {
	    Game memory game = games[i];
	    return (game.totalFund, game.membersCounter, game.win_numbers[0], game.win_numbers[1], game.win_numbers[2], game.win_numbers[3], game.win_numbers[4], game.status, game.p2, game.p3, game.p4, game.p5);
	}
	
	// i - Game number, j - Ticket number
	function getMemberInfo(uint i, uint j) public view returns (address, uint, uint8, uint8, uint8, uint8, uint8, uint, uint8) {
	    Member memory mbr = games[i].members[j];
	    return (mbr.addr, mbr.ticket, mbr.numbers[0], mbr.numbers[1], mbr.numbers[2], mbr.numbers[3], mbr.numbers[4], mbr.prize, mbr.payout);
	}

}

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal pure returns(uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function sub(uint256 a, uint256 b) internal pure returns(uint256) {
        assert(b <= a);
        return a - b;
    }

    function add(uint256 a, uint256 b) internal pure returns(uint256) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }

}