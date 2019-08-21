/*
    cEthereumlotteryNet
    Coded by: iFA
    http://c.ethereumlottery.net
*/

contract cEthereumlotteryNet {
        address owner;
        address drawerAddress;
        bool contractEnabled = true;
        uint public constant ticketPrice = 10 finney;
        uint constant defaultJackpot = 100 ether;
        uint constant feep = 23;
        uint constant hit3p = 35;
        uint constant hit4p = 25;
        uint constant hit5p = 40;
        uint8 constant maxNumber = 30;
        uint constant drawCheckStep = 80;
        uint feeValue;

        struct hits_s {
                uint prize;
                uint count;
        }

        enum drawStatus_ {
                Wait,
                InProcess,
                Done,
                Failed
        }

        struct tickets_s {
                uint hits;
                bytes5 numbers;
        }

        struct games_s {
                uint start;
                uint end;
                uint jackpot;
                bytes32 secret_Key_Hash;
                string secret_Key;
                uint8[5] winningNumbers;
                mapping(uint => hits_s) hits;
                uint prizePot;
                drawStatus_ drawStatus;
                bytes32 winHash;
                mapping(uint => tickets_s) tickets;
                uint ticketsCount;
                uint checkedTickets;
                bytes32 nextHashOfSecretKey;
        }

        mapping(uint => games_s) games;

        uint public CurrentGameId = 0;

        struct player_s {
                bool paid;
                uint[] tickets;
        }

        mapping(address => mapping(uint => player_s)) players;
        uint playersSize;

        function ContractStatus() constant returns(bool Enabled) {
                Enabled = contractEnabled;
        }

        function GameDetails(uint GameId) constant returns(
                uint Jackpot, uint TicketsCount, uint StartBlock, uint EndBlock) {
                Jackpot = games[GameId].jackpot;
                TicketsCount = games[GameId].ticketsCount;
                StartBlock = games[GameId].start;
                EndBlock = games[GameId].end;
        }

        function DrawDetails(uint GameId) constant returns(
                bytes32 SecretKeyHash, string SecretKey, string DrawStatus, bytes32 WinHash,
                uint8[5] WinningNumbers, uint Hit3Count, uint Hit4Count, uint Hit5Count,
                uint Hit3Prize, uint Hit4Prize, uint Hit5Prize) {
                DrawStatus = WritedrawStatus(games[GameId].drawStatus);
                SecretKeyHash = games[GameId].secret_Key_Hash;
                if (games[GameId].drawStatus != drawStatus_.Wait) {
                        SecretKey = games[GameId].secret_Key;
                        WinningNumbers = games[GameId].winningNumbers;
                        Hit3Count = games[GameId].hits[3].count;
                        Hit4Count = games[GameId].hits[4].count;
                        Hit5Count = games[GameId].hits[5].count;
                        Hit3Prize = games[GameId].hits[3].prize;
                        Hit4Prize = games[GameId].hits[4].prize;
                        Hit5Prize = games[GameId].hits[5].prize;
                        WinHash = games[GameId].winHash;
                } else {
                        SecretKey = "";
                        WinningNumbers = [0, 0, 0, 0, 0];
                        Hit3Count = 0;
                        Hit4Count = 0;
                        Hit5Count = 0;
                        Hit3Prize = 0;
                        Hit4Prize = 0;
                        Hit5Prize = 0;
                        WinHash = 0;
                }
        }

        function CheckTickets(address Address, uint GameId, uint TicketNumber) constant returns(uint8[5] Numbers, uint Hits, bool Paid) {
                if (players[Address][GameId].tickets[TicketNumber] > 0) {
                        Numbers[0] = uint8(uint40(games[GameId].tickets[players[Address][GameId].tickets[TicketNumber]].numbers) / 256 / 256 / 256 / 256);
                        Numbers[1] = uint8(uint40(games[GameId].tickets[players[Address][GameId].tickets[TicketNumber]].numbers) / 256 / 256 / 256);
                        Numbers[2] = uint8(uint40(games[GameId].tickets[players[Address][GameId].tickets[TicketNumber]].numbers) / 256 / 256);
                        Numbers[3] = uint8(uint40(games[GameId].tickets[players[Address][GameId].tickets[TicketNumber]].numbers) / 256);
                        Numbers[4] = uint8(games[GameId].tickets[players[Address][GameId].tickets[TicketNumber]].numbers);
                        Numbers = sortWinningNumbers(Numbers);
                        Hits = games[GameId].tickets[players[Address][GameId].tickets[TicketNumber]].hits;
                        Paid = players[Address][GameId].paid;
                }
        }
        string constant public Information = "http://c.ethereumlottery.net";

        function UserCheckBalance(address addr) constant returns(uint Balance) {
                for (uint a = 0; a < CurrentGameId; a++) {
                        if (players[addr][a].paid == false) {
                                if (games[a].drawStatus == drawStatus_.Done) {
                                        for (uint b = 0; b < players[addr][a].tickets.length; b++) {
                                                if (games[a].tickets[players[addr][a].tickets[b]].hits == 3) {
                                                        Balance += games[a].hits[3].prize;
                                                } else if (games[a].tickets[players[addr][a].tickets[b]].hits == 4) {
                                                        Balance += games[a].hits[4].prize;
                                                } else if (games[a].tickets[players[addr][a].tickets[b]].hits == 5) {
                                                        Balance += games[a].hits[5].prize;
                                                }
                                        }
                                } else if (games[a].drawStatus == drawStatus_.Failed) {
                                        Balance += ticketPrice * players[addr][a].tickets.length;
                                }
                        }
                }
        }

        function cEthereumlotteryNet(bytes32 SecretKeyHash) {
                owner = msg.sender;
                CreateNewDraw(defaultJackpot, SecretKeyHash);
                drawerAddress = owner;
        }

        function UserGetPrize() external {
                uint Balance;
                uint GameBalance;
                for (uint a = 0; a < CurrentGameId; a++) {
                        if (players[msg.sender][a].paid == false) {
                                if (games[a].drawStatus == drawStatus_.Done) {
                                        for (uint b = 0; b < players[msg.sender][a].tickets.length; b++) {
                                                if (games[a].tickets[players[msg.sender][a].tickets[b]].hits == 3) {
                                                        GameBalance += games[a].hits[3].prize;
                                                } else if (games[a].tickets[players[msg.sender][a].tickets[b]].hits == 4) {
                                                        GameBalance += games[a].hits[4].prize;
                                                } else if (games[a].tickets[players[msg.sender][a].tickets[b]].hits == 5) {
                                                        GameBalance += games[a].hits[5].prize;
                                                }
                                        }
                                } else if (games[a].drawStatus == drawStatus_.Failed) {
                                        GameBalance += ticketPrice * players[msg.sender][a].tickets.length;
                                }
                                players[msg.sender][a].paid = true;
                                games[a].prizePot -= GameBalance;
                                Balance += GameBalance;
                                GameBalance = 0;
                        }
                }
                if (Balance > 0) {
                        if (msg.sender.send(Balance) == false) {
                                throw;
                        }
                } else {
                        throw;
                }
        }

        function UserAddTicket(bytes5[] tickets) OnlyEnabled OnlyDrawWait external {
                uint ticketsCount = tickets.length;
                if (ticketsCount > 70) {
                        throw;
                }
                if (msg.value < ticketsCount * ticketPrice) {
                        throw;
                }
                if (msg.value > (ticketsCount * ticketPrice)) {
                        if (msg.sender.send(msg.value - (ticketsCount * ticketPrice)) == false) {
                                throw;
                        }
                }
                for (uint a = 0; a < ticketsCount; a++) {
                        if (!CheckNumbers(ConvertNumbers(tickets[a]))) {
                                throw;
                        }
                        games[CurrentGameId].ticketsCount += 1;
                        games[CurrentGameId].tickets[games[CurrentGameId].ticketsCount].numbers = tickets[a];
                        players[msg.sender][CurrentGameId].tickets.length += 1;
                        players[msg.sender][CurrentGameId].tickets[players[msg.sender][CurrentGameId].tickets.length - 1] = games[CurrentGameId].ticketsCount;
                }
        }

        function() {
                throw;
        }

        function AdminDrawProcess() OnlyDrawer OnlyDrawProcess {
                uint StepCount = drawCheckStep;
                if (games[CurrentGameId].checkedTickets < games[CurrentGameId].ticketsCount) {
                        for (uint a = games[CurrentGameId].checkedTickets; a <= games[CurrentGameId].ticketsCount; a++) {
                                if (StepCount == 0) {
                                        break;
                                }
                                for (uint b = 0; b < 5; b++) {
                                        for (uint c = 0; c < 5; c++) {
                                                if (uint8(uint40(games[CurrentGameId].tickets[a].numbers) / (256 ** b)) == games[CurrentGameId].winningNumbers[c]) {
                                                        games[CurrentGameId].tickets[a].hits += 1;
                                                }
                                        }
                                }
                                games[CurrentGameId].checkedTickets += 1;
                                StepCount -= 1;
                        }
                }
                if (games[CurrentGameId].checkedTickets >= games[CurrentGameId].ticketsCount) {
                        //kesz
                        for (a = 0; a < games[CurrentGameId].ticketsCount; a++) {
                                if (games[CurrentGameId].tickets[a].hits == 3) {
                                        games[CurrentGameId].hits[3].count += 1;
                                } else if (games[CurrentGameId].tickets[a].hits == 4) {
                                        games[CurrentGameId].hits[4].count += 1;
                                } else if (games[CurrentGameId].tickets[a].hits == 5) {
                                        games[CurrentGameId].hits[5].count += 1;
                                }
                        }
                        if (games[CurrentGameId].hits[3].count > 0) {
                                games[CurrentGameId].hits[3].prize = games[CurrentGameId].prizePot * hit3p / 100 / games[CurrentGameId].hits[3].count;
                        }
                        if (games[CurrentGameId].hits[4].count > 0) {
                                games[CurrentGameId].hits[4].prize = games[CurrentGameId].prizePot * hit4p / 100 / games[CurrentGameId].hits[4].count;
                        }
                        if (games[CurrentGameId].hits[5].count > 0) {
                                games[CurrentGameId].hits[5].prize = games[CurrentGameId].jackpot / games[CurrentGameId].hits[5].count;
                        }
                        uint NextJackpot;
                        if (games[CurrentGameId].hits[5].count == 0) {
                                NextJackpot = games[CurrentGameId].prizePot * hit5p / 100 + games[CurrentGameId].jackpot;
                        } else {
                                NextJackpot = defaultJackpot;
                        }
                        games[CurrentGameId].drawStatus = drawStatus_.Done;
                        CreateNewDraw(NextJackpot, games[CurrentGameId].nextHashOfSecretKey);
                }
        }

        function AdminDrawError() external OnlyDrawer OnlyDrawProcess {
                games[CurrentGameId].prizePot = games[CurrentGameId].ticketsCount * ticketPrice;
                games[CurrentGameId].drawStatus = drawStatus_.Failed;
                CreateNewDraw(games[CurrentGameId].jackpot, games[CurrentGameId].nextHashOfSecretKey);
        }

        function AdminStartDraw(string secret_Key, bytes32 New_secret_Key_Hash) external OnlyDrawer OnlyDrawWait returns(uint ret) {
                games[CurrentGameId].end = block.number;
                if (sha3(secret_Key) != games[CurrentGameId].secret_Key_Hash) {
                        games[CurrentGameId].prizePot = games[CurrentGameId].ticketsCount * ticketPrice;
                        games[CurrentGameId].drawStatus = drawStatus_.Failed;
                        games[CurrentGameId].secret_Key = secret_Key;
                        CreateNewDraw(games[CurrentGameId].jackpot, New_secret_Key_Hash);
                        return;
                }
                games[CurrentGameId].drawStatus = drawStatus_.InProcess;
                games[CurrentGameId].nextHashOfSecretKey = New_secret_Key_Hash;
                games[CurrentGameId].secret_Key = secret_Key;
                games[CurrentGameId].winHash = sha3(games[CurrentGameId].secret_Key, games[CurrentGameId].secret_Key_Hash, games[CurrentGameId].ticketsCount, now);
                games[CurrentGameId].winningNumbers = sortWinningNumbers(GetNumbersFromHash(games[CurrentGameId].winHash));
                if (games[CurrentGameId].ticketsCount > 1) {
                        feeValue += ticketPrice * games[CurrentGameId].ticketsCount * feep / 100;
                        games[CurrentGameId].prizePot = ticketPrice * games[CurrentGameId].ticketsCount - feeValue;
                        AdminDrawProcess();
                } else {
                        games[CurrentGameId].drawStatus = drawStatus_.Done;
                }
        }

        function AdminSetDrawer(address NewDrawer) external OnlyOwner {
                drawerAddress = NewDrawer;
        }

        function AdminCloseContract() OnlyOwner external {
                if (!contractEnabled) {
                        if (games[CurrentGameId].ticketsCount == 0) {
                                uint contractbalance = this.balance;
                                for (uint a = 0; a < CurrentGameId; a++) {
                                        contractbalance -= games[a].prizePot;
                                }
                                contractbalance += games[a].jackpot - defaultJackpot;
                                if (owner.send(contractbalance) == false) {
                                        throw;
                                }
                                feeValue = 0;
                        } else {
                                throw;
                        }
                } else {
                        contractEnabled = false;
                }
        }

        function AdminAddFunds() OnlyOwner {
                return;
        }

        function AdminGetFee() OnlyOwner {
                if (owner.send(feeValue) == false) {
                        throw;
                }
                feeValue = 0;
        }

        modifier OnlyDrawer() {
                if ((drawerAddress != msg.sender) && (owner != msg.sender)) {
                        throw;
                }
                _
        }

        modifier OnlyOwner() {
                if (owner != msg.sender) {
                        throw;
                }
                _
        }

        modifier OnlyEnabled() {
                if (!contractEnabled) {
                        throw;
                }
                _
        }

        modifier OnlyDrawWait() {
                if (games[CurrentGameId].drawStatus != drawStatus_.Wait) {
                        throw;
                }
                _
        }

        modifier OnlyDrawProcess() {
                if (games[CurrentGameId].drawStatus != drawStatus_.InProcess) {
                        throw;
                }
                _
        }

        function CreateNewDraw(uint Jackpot, bytes32 SecretKeyHash) internal {
                CurrentGameId += 1;
                games[CurrentGameId].start = block.number;
                games[CurrentGameId].jackpot = Jackpot;
                games[CurrentGameId].secret_Key_Hash = SecretKeyHash;
                games[CurrentGameId].drawStatus = drawStatus_.Wait;
        }

        function ConvertNumbers(bytes5 input) internal returns(uint8[5] output) {
                output[0] = uint8(uint40(input) / 256 / 256 / 256 / 256);
                output[1] = uint8(uint40(input) / 256 / 256 / 256);
                output[2] = uint8(uint40(input) / 256 / 256);
                output[3] = uint8(uint40(input) / 256);
                output[4] = uint8(input);
        }

        function CheckNumbers(uint8[5] tickets) internal returns(bool ok) {
                for (uint8 a = 0; a < 5; a++) {
                        if ((tickets[a] < 1) || (tickets[a] > maxNumber)) {
                                return false;
                        }
                        for (uint8 b = 0; b < 5; b++) {
                                if ((tickets[a] == tickets[b]) && (a != b)) {
                                        return false;
                                }
                        }
                }
                return true;
        }

        function GetNumbersFromHash(bytes32 hash) internal returns(uint8[5] tickets) {
                bool ok = true;
                uint8 num = 0;
                uint hashpos = 0;
                uint8 a;
                for (a = 0; a < 5; a++) {
                        while (true) {
                                ok = true;
                                if (hashpos == 32) {
                                        hashpos = 0;
                                        hash = sha3(hash);
                                }
                                num = GetPart(hash, hashpos);
                                num = num % maxNumber + 1;
                                hashpos += 1;
                                for (uint8 b = 0; b < 5; b++) {
                                        if (tickets[b] == num) {
                                                ok = false;
                                                break;
                                        }
                                }
                                if (ok == true) {
                                        tickets[a] = num;
                                        break;
                                }
                        }
                }
        }

        function GetPart(bytes32 a, uint i) internal returns(uint8) {
                return uint8(byte(bytes32(uint(a) * 2 ** (8 * i))));
        }

        function WritedrawStatus(drawStatus_ input) internal returns(string drawStatus) {
                if (input == drawStatus_.Wait) {
                        drawStatus = "Wait";
                } else if (input == drawStatus_.InProcess) {
                        drawStatus = "In Process";
                } else if (input == drawStatus_.Done) {
                        drawStatus = "Done";
                } else if (input == drawStatus_.Failed) {
                        drawStatus = "Failed";
                }
        }

        function sortWinningNumbers(uint8[5] numbers) internal returns(uint8[5] sortednumbers) {
                sortednumbers = numbers;
                for (uint8 i = 0; i < 5; i++) {
                        for (uint8 j = i + 1; j < 5; j++) {
                                if (sortednumbers[i] > sortednumbers[j]) {
                                        uint8 t = sortednumbers[i];
                                        sortednumbers[i] = sortednumbers[j];
                                        sortednumbers[j] = t;
                                }
                        }
                }
        }
}