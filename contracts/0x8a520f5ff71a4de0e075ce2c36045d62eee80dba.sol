contract owned {
    address public owner;
    
    function owned() {
        owner = msg.sender;
    }
    
    function setOwner(address _new) onlyOwner {
        owner = _new;
    }
    
    modifier onlyOwner {
        if (msg.sender != owner) throw;
    }
}

contract TheGrid is owned {
	// The number of the game
	uint public gameId = 1;
	// The size of the grid. It will start at 3 and increase
    uint public size = 4;
	uint public nextsize = 5;
	// Number of empty spots. Reaching 0 will create next game
    uint public empty = 16;
    
	// The micro of the owners benefit, i.e. it will gain
	// money / 1000000 * benefitMicros.
    uint public benefitMicros = 24900;
	// The current price for one spot of the grid
    uint public price = 100 finney;
	// The price to start with for one spot
	uint public startPrice = 100 finney;
	// Micros of the price increase after buy, i.e after each buy
	// the price will be old / 1000000 * priceIncrease
	uint public priceIncrease = 15000;
	// The win for this game
    uint public win;
    
	// A mapping of the pending payouts
	mapping(address => uint) public pendingPayouts;
	uint public totalPayouts;
	// A mapping of the points gained in this game
    mapping(address => uint) public balanceOf;
    uint public totalSupply;
    
	// State of the grid. Positions are encoded as _x*size+_y.
    address[] public theGrid;
	// A list of all players, needed for payouts.
    address[] public players;
	// The last player who played. Not allowed to play next turn too.
	address public lastPlayer;
	
	// The timeout interval
	uint public timeout = 6 hours;
	// Timestamp of the timeout if no one plays before
	uint public timeoutAt;
    
	// Will be triggered on the end of each game
	event GameEnded(uint indexed gameId, uint win, uint totalPoints);
	// Will be triggered on each start of a game
	event GameStart(uint indexed gameId, uint size);
	// Will be triggered on each bought position
	event PositionBought(uint indexed gameId, uint indexed moveNo,
						 uint where, address who, uint pointsGained, 
						 uint etherPaid);
	// Will be triggered on each timeout!
	event Timeout(uint indexed gameId, uint indexed moveNo);
	// Will be triggered on each payout withdraw
	event Collect(address indexed who, uint value);
	
    function TheGrid() {
		// Setting the length of theGrid and timeout
        theGrid.length = empty;        
		timeoutAt = now + timeout;
		GameStart(gameId, size);
    }
	
	// The direction count counts the positions hold by this player in ONE
	// direction, i.e. to determine a line length you have to call it twice
	// (one time for north direction, one time for south by example)
	function directionCount(int _x, int _y, int _dx, int _dy)
			internal returns (uint) {
		var found = uint(0);
		var s = int(size);
		_x += _dx;
		_y += _dy;
		// While still on the grid...
		while (_x < s && _y < s && _x >= 0 && _y >= 0) {
			// If it is the sender, gain point, else break
			if (theGrid[getIndex(uint(_x), uint(_y))] == msg.sender) {
				found ++;
			} else {
				break;
			}
			// Go to next position
			_x += _dx;
			_y += _dy;
		}
		return found;
	}
    
    /// Buy the spot at _x, _y if it is available and gain points for every
    /// connected spot of your color sharing lines with this spot.
    function buy(uint _x, uint _y) {
		// Has to be an available position (getIndex will throw off-grid)
        if (theGrid[getIndex(_x, _y)] != 0) throw;
		// No one is allowed to play two token right after each other
		if (msg.sender == lastPlayer) throw;
		// If there is a timeout, divide the price by two and let the
		// next game start at 3 again.
		if (now > timeoutAt) {
			price = price / 2;
			// 1 finney is the lowest acceptable price. It makes sure the
			// calculation of a players share never becomes 0.
			if (price < 1 finney) price = 1 finney;
			nextsize = 3;
			Timeout(gameId, size*size - empty + 1);
		}
		// If more than the price per position is sended, add it to the
		// payouts so it can be withdrawn later
		if (msg.value < price) {
			throw;
		} else {
			// The owner of the contract gets a little benefit
			// The sender gets back the overhead
			var benefit = price / 1000000 * benefitMicros;
			if (pendingPayouts[owner] + benefit < pendingPayouts[owner]) throw;
			pendingPayouts[owner] += benefit;
			if (pendingPayouts[msg.sender] + msg.value - price < pendingPayouts[msg.sender]) throw;
			pendingPayouts[msg.sender] += msg.value - price;
			if (totalPayouts + msg.value - price + benefit < totalPayouts) throw;
			totalPayouts += msg.value - price + benefit;
			// Add the price to the win
			if (win + price - benefit < win) throw;
			win += price - benefit;
		}

        // Set the position to this address
        empty --;
        theGrid[getIndex(_x, _y)] = msg.sender;
        
        // Add player on first time and give him his one joining point
        var found = uint(0);
		if (balanceOf[msg.sender] == 0) {
            players.push(msg.sender);
			found = 1;
        }
        
        // Discover linear connected spots and give the buyer the square
		// of the lines lengths as points. See the rules.
		
		var x = int(_x);
		var y = int(_y);
		
		// East to west
		var a = 1 + directionCount(x, y, 1, 0) + directionCount(x, y, -1, 0);
		if (a >= 3) {
			found += a * a;
		}
		
		// North east to south west
		a = 1 + directionCount(x, y, 1, 1) + directionCount(x, y, -1, -1);
		if (a >= 3) {
			found += a * a;
		}
		
		// North to south
		a = 1 + directionCount(x, y, 0, 1) + directionCount(x, y, 0, -1);
		if (a >= 3) {
			found += a * a;
		}
		
		// North west to south east
		a = 1 + directionCount(x, y, 1, -1) + directionCount(x, y, -1, 1);
		if (a >= 3) {
			found += a * a;
		}
        
        // Add points
		if (balanceOf[msg.sender] + found < balanceOf[msg.sender]) throw;
        balanceOf[msg.sender] += found;
		if (totalSupply + found < totalSupply) throw;
        totalSupply += found;
		
		// Trigger event before the price increases!
		PositionBought(gameId, size*size-empty, getIndex(_x, _y), msg.sender, found, price);
		
		// Increase the price per position by the price Increase
		price = price / 1000000 * (1000000 + priceIncrease);
		
		// Set new timeout and last player played
		timeoutAt = now + timeout;
		lastPlayer = msg.sender;
		
		// If this was the last empty position, initiate next game
        if (empty == 0) nextRound();
    }
	
	/// Collect your pending payouts using this method
	function collect() {
		var balance = pendingPayouts[msg.sender];
		pendingPayouts[msg.sender] = 0;
		totalPayouts -= balance;
		if (!msg.sender.send(balance)) throw;
		Collect(msg.sender, balance);
	}
    
	// Returns the in array index of one position and throws on
	// off-grid position
    function getIndex(uint _x, uint _y) internal returns (uint) {
        if (_x >= size) throw;
        if (_y >= size) throw;
		return _x * size + _y;
    }
    
	// Will initiate the next game by clearing most of the data
	// and calculating the payouts.
    function nextRound() internal {
        GameEnded(gameId, win, totalSupply);
		// Calculate share per point
		if (totalPayouts + win < totalPayouts) throw;
		totalPayouts += win;
		// If the totalSupply is 0, no one played, so no one can gain a share
		// The maximum total Supply is lower than 1.1e9, so the share can't
		// become 0 because of a too high totalSupply, as a finney is still
		// bigger.
		var share = totalSupply == 0 ? 0 : win / totalSupply;
        // Send balances to the payouts
		// If the win was not dividable by the number of points, it is kept
		// for the next game. Most properly only some wei.
        for (var i = 0; i < players.length; i++) {
			var amount = share * balanceOf[players[i]];
			totalSupply -= balanceOf[players[i]];
			balanceOf[players[i]] = 0;
			if (pendingPayouts[players[i]] + amount < pendingPayouts[players[i]]) throw;
            pendingPayouts[players[i]] += amount;
			win -= amount;
        }
		
        
        // Delete positions and player
        delete theGrid;
        delete players;
		lastPlayer = 0x0;
		// The next game will be a bit bigger, but limit it to 64.
        size = nextsize;
		if (nextsize < 64) nextsize ++;
		gameId ++;
		// Calculate empty spots
        empty = size * size;
		theGrid.length = empty;
		// Reset the price
		price = startPrice;
		
		GameStart(gameId, size);
    }
}