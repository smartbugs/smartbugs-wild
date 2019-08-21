pragma solidity ^0.4.9;

contract SportsBet {
    enum GameStatus { Open, Locked, Scored }
    enum BookType { Spread, MoneyLine, OverUnder }
    enum BetStatus { Open, Paid }

    // indexing on a string causes issues with web3, so category has to be an int
    event GameCreated(bytes32 indexed id, string home, 
        string away, uint16 indexed category, uint64 locktime);
    event BidPlaced(bytes32 indexed game_id, BookType book, 
        address bidder, uint amount, bool home, int32 line);
    event BetPlaced(bytes32 indexed game_id, BookType indexed book, 
        address indexed user, bool home, uint amount, int32 line);
    event GameScored(bytes32 indexed game_id, int homeScore, int awayScore);
    event Withdrawal(address indexed user, uint amount, uint timestamp);

    struct Bid {
        address bidder;
        uint amount; /* in wei */
        bool home; /* true=home, false=away */
        int32 line;
    }

    struct Bet {
        address home;
        address away;
        uint amount; /* in wei */
        int32 line;
        BetStatus status;
    }

    struct Book {
        Bid[] homeBids;
        Bid[] awayBids;
        Bet[] bets;
    }

    struct GameResult {
        int home;
        int away;
    }

    struct Game {
        bytes32 id;
        string home;
        string away;
        uint16 category;
        uint64 locktime;
        GameStatus status;
        mapping(uint => Book) books;
        GameResult result;
    }

    address public owner;
    Game[] games;
    mapping(address => uint) public balances;

    function SportsBet() {
        owner = msg.sender;
    }

	function createGame (string home, string away, uint16 category, uint64 locktime) returns (int) {
        if (msg.sender != owner) return 1;
        bytes32 id = getGameId(home, away, category, locktime);
        mapping(uint => Book) books;
        Bid[] memory homeBids;
        Bid[] memory awayBids;
        Bet[] memory bets;
        GameResult memory result = GameResult(0,0);
        Game memory game = Game(id, home, away, category, locktime, GameStatus.Open, result);
        games.push(game);
        GameCreated(id, home, away, category, locktime);
        return -1;
    }
    
    function cancelOpenBids(bytes32 game_id) private returns (int) {
        Game game = getGameById(game_id);
        Book book = game.books[uint(BookType.Spread)];

        for (uint i=0; i < book.homeBids.length; i++) {
            Bid bid = book.homeBids[i];
            if (bid.amount == 0)
                continue;
            balances[bid.bidder] += bid.amount;
            delete book.homeBids[i];
        }
        for (i=0; i < book.awayBids.length; i++) {
            bid = book.awayBids[i];
            if (bid.amount == 0)
                continue;
            balances[bid.bidder] += bid.amount;
            delete book.awayBids[i];
        }

        return -1;
    }

    function setGameResult (bytes32 game_id, int homeScore, int awayScore) returns (int) {
        if (msg.sender != owner) return 1;

        Game game = getGameById(game_id);
        if (game.locktime > now) return 2;
        if (game.status == GameStatus.Scored) return 3;

        cancelOpenBids(game_id);

        game.result.home = homeScore;
        game.result.away = awayScore;
        game.status = GameStatus.Scored;
        GameScored(game_id, homeScore, awayScore);

        // Currently only handles spread bets
        Bet[] bets = game.books[uint(BookType.Spread)].bets;
        int resultSpread = awayScore - homeScore;
        resultSpread *= 10; // because bet.line is 10x the actual line
        for (uint i = 0; i < bets.length; i++) {
            Bet bet = bets[i];
            if (resultSpread > bet.line) 
                balances[bet.away] += bet.amount * 2;
            else if (resultSpread < bet.line)
                balances[bet.home] += bet.amount * 2;
            else { // draw
                balances[bet.away] += bet.amount;
                balances[bet.home] += bet.amount;
            }
            bet.status = BetStatus.Paid;
        }

        return -1;
    }

    // This will eventually be expanded to include MoneyLine and OverUnder bets
    // line is actually 10x the line to allow for half-point spreads
    function bidSpread(bytes32 game_id, bool home, int32 line) payable returns (int) {
        Game game = getGameById(game_id);
        Book book = game.books[uint(BookType.Spread)];
        Bid memory bid = Bid(msg.sender, msg.value, home, line);

        // validate inputs: game status, gametime, line amount
        if (game.status == GameStatus.Locked)
            return 1;
        if (now > game.locktime) {
            game.status = GameStatus.Locked;    
            cancelOpenBids(game_id);
            return 2;
        }
        if (line % 5 != 0)
            return 3;

        Bid memory remainingBid = matchExistingBids(bid, book, home, game_id);

        // Use leftover funds to place open bids (maker)
        if (bid.amount > 0) {
            Bid[] bidStack = home ? book.homeBids : book.awayBids;
            addBidToStack(remainingBid, bidStack);
            BidPlaced(game_id, BookType.Spread, remainingBid.bidder, remainingBid.amount, home, line);
        }

        return -1;
    }

    // returning an array of structs is not allowed, so its time for a hackjob
    // that returns a raw bytes dump of the combined home and away bids
    // clients will have to parse the hex dump to get the bids out
    // This function is for DEBUGGING PURPOSES ONLY. Using it in a production
    // setting will return very large byte arrays that will consume your bandwidth
    // if you are using Metamask or not running a full node  
    function getOpenBids(bytes32 game_id) constant returns (bytes) {
        Game game = getGameById(game_id);
        Book book = game.books[uint(BookType.Spread)];
        uint nBids = book.homeBids.length + book.awayBids.length;
        bytes memory s = new bytes(57 * nBids);
        uint k = 0;
        for (uint i=0; i < nBids; i++) {
            Bid bid;
            if (i < book.homeBids.length)
                bid = book.homeBids[i];
            else
                bid = book.awayBids[i - book.homeBids.length];
            bytes20 bidder = bytes20(bid.bidder);
            bytes32 amount = bytes32(bid.amount);
            byte home = bid.home ? byte(1) : byte(0);
            bytes4 line = bytes4(bid.line);

            for (uint j=0; j < 20; j++) { s[k] = bidder[j]; k++; }
            for (j=0; j < 32; j++) { s[k] = amount[j]; k++; }
            s[k] = home; k++;
            for (j=0; j < 4; j++) { s[k] = line[j]; k++; }

        }

        return s;
    }

    // Unfortunately this function had too many local variables, so a 
    // bunch of unruly code had to be used to eliminate some variables
    function getOpenBidsByLine(bytes32 game_id) constant returns (bytes) {
        Book book = getBook(game_id, BookType.Spread);

        uint away_lines_length = getUniqueLineCount(book.awayBids);
        uint home_lines_length = getUniqueLineCount(book.homeBids);

        // group bid amounts by line
        mapping(int32 => uint)[2] line_amounts;
        int32[] memory away_lines = new int32[](away_lines_length);
        int32[] memory home_lines = new int32[](home_lines_length);

        uint k = 0;
        for (uint i=0; i < book.homeBids.length; i++) {
            Bid bid = book.homeBids[i]; 
            if (bid.amount == 0) // ignore deleted bids
                continue;
            if (line_amounts[0][bid.line] == 0) {
                home_lines[k] = bid.line;
                k++;
            }
            line_amounts[0][bid.line] += bid.amount;
        }
        k = 0;
        for (i=0; i < book.awayBids.length; i++) {
            bid = book.awayBids[i]; 
            if (bid.amount == 0) // ignore deleted bids
                continue;
            if (line_amounts[1][bid.line] == 0) {
                away_lines[k] = bid.line;
                k++;
            }
            line_amounts[1][bid.line] += bid.amount;
        }

        bytes memory s = new bytes(37 * (home_lines_length + away_lines_length));
        k = 0;
        for (i=0; i < home_lines_length; i++) {
            bytes4 line = bytes4(home_lines[i]);
            bytes32 amount = bytes32(line_amounts[0][home_lines[i]]);
            for (uint j=0; j < 32; j++) { s[k] = amount[j]; k++; }
            s[k] = byte(1); k++;
            for (j=0; j < 4; j++) { s[k] = line[j]; k++; }
        }
        for (i=0; i < away_lines_length; i++) {
            line = bytes4(away_lines[i]);
            amount = bytes32(line_amounts[1][away_lines[i]]);
            for (j=0; j < 32; j++) { s[k] = amount[j]; k++; }
            s[k] = byte(0); k++;
            for (j=0; j < 4; j++) { s[k] = line[j]; k++; }
        }
        
        return s;
    }

    function getUniqueLineCount(Bid[] stack) private constant returns (uint) {
        uint line_count = 0;
        int lastIndex = -1;
        for (uint i=0; i < stack.length; i++) {
            if (stack[i].amount == 0) // ignore deleted bids
                continue;
            if (lastIndex == -1)
                line_count++;
            else if (stack[i].line != stack[uint(lastIndex)].line)
                line_count++;
            lastIndex = int(i);
        }
        return line_count;
    }

    function getOpenBidsByBidder(bytes32 game_id, address bidder) constant returns (bytes) {
        Game game = getGameById(game_id);
        Book book = game.books[uint(BookType.Spread)];
        uint nBids = book.homeBids.length + book.awayBids.length;
        uint myBids = 0;

        // count number of bids by bidder
        for (uint i=0; i < nBids; i++) {
            Bid bid = i < book.homeBids.length ? book.homeBids[i] : book.awayBids[i - book.homeBids.length];
            if (bid.bidder == bidder)
                myBids += 1;
        }

        bytes memory s = new bytes(37 * myBids);
        uint k = 0;
        for (i=0; i < nBids; i++) {
            bid = i < book.homeBids.length ? book.homeBids[i] : book.awayBids[i - book.homeBids.length];
            if (bid.bidder != bidder) // ignore other people's bids
                continue; 
            bytes32 amount = bytes32(bid.amount);
            byte home = bid.home ? byte(1) : byte(0);
            bytes4 line = bytes4(bid.line);

            for (uint j=0; j < 32; j++) { s[k] = amount[j]; k++; }
            s[k] = home; k++;
            for (j=0; j < 4; j++) { s[k] = line[j]; k++; }
        }
        return s;
    }
        

    // for functions throwing a stack too deep error, this helper will free up 2 local variable spots
    function getBook(bytes32 game_id, BookType book_type) constant private returns (Book storage) {
        Game game = getGameById(game_id);
        Book book = game.books[uint(book_type)];
        return book;
    }
    
    function matchExistingBids(Bid bid, Book storage book, bool home, bytes32 game_id) private returns (Bid) {
        Bid[] matchStack = home ?  book.awayBids : book.homeBids;
        int i = int(matchStack.length) - 1;
        while (i >= 0 && bid.amount > 0) {
            uint j = uint(i);
            if (matchStack[j].amount == 0) { // deleted bids
                i--;
                continue;
            }
            if (-bid.line < matchStack[j].line)
                break;

            address homeAddress = home ? bid.bidder : matchStack[j].bidder;
            address awayAddress = home ? matchStack[j].bidder : bid.bidder;
            int32 betLine = home ? -matchStack[j].line : matchStack[j].line;
            uint betAmount;
            if (bid.amount < matchStack[j].amount) {
                betAmount = bid.amount;
                matchStack[j].amount -= betAmount;
            }
            else {
                betAmount = matchStack[j].amount;
                delete matchStack[j];
            }
            bid.amount -= betAmount;

            Bet memory bet = Bet(homeAddress, awayAddress, betAmount, betLine, BetStatus.Open);
            book.bets.push(bet);
            BetPlaced(game_id, BookType.Spread, homeAddress, true, betAmount, betLine);
            BetPlaced(game_id, BookType.Spread, awayAddress, false, betAmount, -betLine);
            i--;
        }
        return bid;
    }

    function cancelBid(address bidder, bytes32 game_id, int32 line, bool home) returns (bool) {
        Game game = getGameById(game_id);
        Book book = game.books[uint(BookType.Spread)];
        Bid[] stack = home ? book.homeBids : book.awayBids;

        // Delete bid in stack, refund amount to user
        bool found = false;
        for (uint i=0; i < stack.length; i++) {
            if (stack[i].bidder == bidder && stack[i].line == line) {
                balances[bidder] += stack[i].amount;
                delete stack[i];
                found = true;
            }
        }
        return found;
    }

    function kill () {
        if (msg.sender == owner) selfdestruct(owner);
    }

    function getGameId (string home, string away, uint16 category, uint64 locktime) constant returns (bytes32) {
        uint i = 0;
        bytes memory a = bytes(home);
        bytes memory b = bytes(away);
        bytes2 c = bytes2(category);
        bytes8 d = bytes8(locktime);

        uint length = a.length + b.length + c.length + d.length;
        bytes memory toHash = new bytes(length);
        uint k = 0;
        for (i = 0; i < a.length; i++) { toHash[k] = a[i]; k++; }
        for (i = 0; i < b.length; i++) { toHash[k] = b[i]; k++; }
        for (i = 0; i < c.length; i++) { toHash[k] = c[i]; k++; }
        for (i = 0; i < d.length; i++) { toHash[k] = d[i]; k++; }
        return keccak256(toHash);
        
    }
    
    function getActiveGames () constant returns (bytes32[]) {
        bytes32[] memory game_ids = new bytes32[](games.length);
        for (uint i=0; i < games.length; i++) {
            game_ids[i] = (games[i].id);
        }
        return game_ids;
    }
        
    function addBidToStack(Bid bid, Bid[] storage stack) private returns (int) {
        stack.push(bid); // make stack one item larger

        if (stack.length <= 1)
            return 0;

        // insert into sorted stack
        uint i = stack.length - 2;
        uint lastIndex = stack.length - 1;
        while (true) {
            if (stack[i].amount == 0) { // ignore deleted bids
                if (i == 0)
                    break;
                i--;
                continue;
            }
            if (stack[i].line > bid.line)
                break;
            stack[lastIndex] = stack[i];
            lastIndex = i;

            // uint exhibits undefined behavior when you take it negative
            // so we have to break manually
            if (i == 0) 
                break;
            i--;
        }
        stack[lastIndex] = bid;
        return -1;
    }
    
    function getGameById(bytes32 game_id) private returns (Game storage) {
        bool game_exists = false;
        for (uint i = 0; i < games.length; i++) {
            if (games[i].id == game_id) {
                Game game = games[i];
                game_exists = true;
                break;
            }
        }
        if (!game_exists)
            throw;
        return game;
    }


    function withdraw() returns (int) {
        var balance = balances[msg.sender];
        balances[msg.sender] = 0;
        if (!msg.sender.send(balance)) {
            balances[msg.sender] = balance;
            return 1;
        }
        Withdrawal(msg.sender, balance, now);
        return -1;
    }

}