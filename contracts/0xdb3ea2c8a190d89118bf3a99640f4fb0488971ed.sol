pragma solidity 0.4.24;

contract IAdminContract {
    function getGameAdmin() public view returns (address);

    modifier admin() {
        require(msg.sender == getGameAdmin());
        _;
    }
}

contract IBlockRandomLibrary {
    function setRandomBlock(uint blockNumber) internal;
    function updateRandom() public;
    function isRandomAvailable() public view returns(bool);
    function randomBlockPassed() public view returns(bool); 
    function getRandomValue() public view returns(uint);
    function canStoreRandom() public view returns(bool);
    function isRandomStored() public view returns(bool);
}

contract IStartGame {
    function startOwnFixed(uint gameId, uint length, uint addon, uint prize) public payable;
    function betInGame(uint gameId) public payable;
    function recalcNextGameId() public;
    function getProfitedCount() public view returns(uint);
    function getCreateFastGamesCount() public view returns(uint);
    function setCreateFastGamesCount(uint count) public;
    function canStartGame() public view returns(bool);
    function startGameId() public view returns(uint);
    function startPrizeValue() public view returns(uint);
    function startGameLength() public view returns(uint);
    function startGameAddon() public view returns(uint);
    function getStartGameStatus() public view returns(bool, uint, uint, uint, uint);
    function getTransferProfitedGame(address participant) public view returns(uint);
    function defaultGameAvailable() public view returns(bool);
    function defaultGameId() public view returns(uint);
    function getRepeatBlock() public view returns(uint);
    function getAddonBlock() public view returns(uint);
    function alterRepeatBlock(uint _repeatBlock) public;
    function alterAddonBlock(uint _addonBlock) public;

    event RepeatBlockAltered(uint newValue);
    event RepeatAddonBlockAltered(uint newValue);
    event NextGameIdCalculated(uint gameId);
    event DefaultGameUpdated(uint gameId);
    event TransferBet(address better, uint value);
    event GameProfitedEvent(uint gameId);
    event FastGamesChanged(uint faseGamesCreate);
}

contract ICommonGame is IAdminContract {
    function gameFinishing() public view returns(bool);
    function stopGame() public;
    function totalVariants() public view returns(uint);
    function alterTotalVariants(uint _newVariants) public;
    function autoCreationAllowed() public view returns(bool);
    function setAutoCreation(bool allowed) public;
    function autoCreationAfterOwnAllowed() public view returns(bool);
    function setAutoCreationAfterOwn(bool allowed) public;
    function transferInteractionsAllowed() public view returns(bool); 
    function setTransferInteractions(bool allowed) public; 
    function startOnlyMinPrizes() public view returns (bool);
    function setStartOnlyMinPrizes(bool minPrizes) public;
    function startProfitedGamesAllowed() public view returns (bool);
    function setStartProfitedGamesAllowed(bool games) public;
    function gameFinished() public view returns(bool);
    function gameFinishedBlock() public view returns(uint);

    function creationAllowed() public view returns(bool) {
        return autoCreationAllowed() && !gameFinishing();
    }

    event GameStopInitiated(uint finishingBlock);
    event TransferInteractionsChanged(bool newValue);
    event StartOnlyMinPrizesChanged(bool newValue);
    event StartProfitedGamesAllowedChanged(bool newValue);

    event AutoCreationChanged(bool newValue);
    event AutoCreationAfterOwnChanged(bool newValue);
    event TotalVariantsChanged(uint newTotalVariants);
}

contract IFunctionPrize {
    function calcPrizeX(uint x, uint maxX, uint maxPrize)  public view returns (uint);
    function prizeFunctionName() public view returns (string);
}

contract IPrizeLibrary is ICommonGame {
    function calculatePrize(uint number, uint minPrize, uint maxPrize) public view returns(uint);
    function prizeName() public view returns (string);    
}

contract IBalanceSharePrizeContract {
    function getMaxPrizeShare() public view returns (uint);
    function alterPrizeShare(uint _maxPrizeShare) public;
    event MaxPrizeShareAltered(uint share);
}

contract IMinMaxPrize {
    function getMaxPrize() public view returns(uint);
    function getWholePrize() public view returns(uint);
    function getMinPrize() public view returns(uint);
    function alterMinPrize(uint _minPrize) public;
    function alterMaxPrize(uint _maxPrize) public;

    event MinPrizeAltered(uint prize);
    event MaxPrizeAltered(uint prize);
}

contract IBalanceInfo {
    function totalBalance() public view returns(uint);
    function availableBalance() public view returns(uint);
    function reserveBalance(uint value) internal returns(uint);
    function reservedBalance() public view returns(uint);
    function freeBalance(uint value) internal returns(uint);

    event BalanceReserved(uint value, uint total);
    event BalanceFreed(uint value, uint total);
}

contract BlockRandomLibrary is IBlockRandomLibrary {
    uint public randomBlock;
    uint public randomValue;
    uint public maxBlocks;

    constructor(uint _maxBlocks) public 
        IBlockRandomLibrary()
    {
        assert(_maxBlocks <= 250);
        randomValue = 0;
        randomBlock = 0;
        maxBlocks = _maxBlocks;
    }

    function setRandomBlock(uint blockNumber) internal {
        randomBlock = blockNumber;
        if (canStoreRandom()) {
            randomValue = uint(blockhash(randomBlock));
            emit RandomValueCalculated(randomValue, randomBlock);
        } else {
            randomValue = 0;
        }
    }

    event RandomValueCalculated(uint value, uint randomBlock);
    
    function updateRandom() public {
        if (!isRandomStored() && canStoreRandom()) {
            randomValue = uint(blockhash(randomBlock));
            emit RandomValueCalculated(randomValue, randomBlock);
        }
    }

    function isRandomAvailable() public view returns(bool) {
        return isRandomStored() || canStoreRandom();
    }

    function getRandomValue() public view returns(uint) {
        if (isRandomStored()) {
            return randomValue;
        } else if (canStoreRandom()) {
            return uint(blockhash(randomBlock));
        } 

        return 0;
    }

    function canStoreRandom() public view returns(bool) {
        return !blockExpired() && randomBlockPassed();
    }
    function randomBlockPassed() public view returns(bool) {
        return block.number > randomBlock;
    }
    function blockExpired() public view returns(bool) {
        return block.number > randomBlock + maxBlocks;
    }
    function isRandomStored() public view returns (bool) {
        return randomValue != 0;
    }
}

contract EllipticPrize16x is IFunctionPrize {
    function calcModulo(uint fMax) internal pure returns (uint) {
        uint sqr = fMax * fMax * fMax * fMax;
        return sqr * sqr * sqr * sqr;
    }

    function calcPrizeX(uint x, uint fMax, uint maxPrize) public view returns (uint) {
        uint xsq = (x + 1) * (x + 1);
        uint xq = xsq * xsq;
        uint xspt = xq * xq;
        return (xspt * xspt * maxPrize) / calcModulo(fMax);
    }

    function prizeFunctionName() public view returns (string) {
        return "E16x";
    }
} 

contract BalanceSharePrizeContract is IBalanceSharePrizeContract, ICommonGame, IMinMaxPrize, IBalanceInfo {
    uint public minPrize;
    uint public maxPrizeShare;

    constructor(uint _minPrize, uint _maxPrizeShare) public {
        assert(_minPrize >= 0);
        assert(_maxPrizeShare > 0 && _maxPrizeShare <= 1 ether);

        minPrize = _minPrize;
        maxPrizeShare = _maxPrizeShare;
    }

    function getMaxPrizeShare() public view returns (uint) {
        return maxPrizeShare;
    }

    function alterPrizeShare(uint _maxPrizeShare) admin public {
        require(_maxPrizeShare > 0 && _maxPrizeShare <= 1 ether, "Prize share should be between 0 and 100%");
        maxPrizeShare = _maxPrizeShare;
        emit MaxPrizeShareAltered(maxPrizeShare);
    }

    function alterMinPrize(uint _minPrize) admin public {
        minPrize = _minPrize;
        emit MinPrizeAltered(minPrize);
    }

    function alterMaxPrize(uint) admin public {
    }

    function getMaxPrize() public view returns(uint) {
        return (availableBalance() * maxPrizeShare) / (1 ether);        
    }

    function getWholePrize() public view returns(uint) {
        return availableBalance();
    }

    function getMinPrize() public view returns(uint) {
        return minPrize;
    }
}

contract PrizeLibrary is IPrizeLibrary, IFunctionPrize {
    constructor() public {}

    function prizeName() public view returns (string) {
        return prizeFunctionName();
    }

    function calculatePrize(uint number, uint minPrize, uint maxPrize) public view returns(uint) {
        uint prize = calcPrizeX(number % totalVariants(), totalVariants(), maxPrize);
        uint minP = minPrize;
        uint maxP = maxPrize;

        if (maxP < minP) {
            return maxP;
        } else if (prize < minP) {
            return minP;
        } else {
            return prize;
        }
    }
}

contract CommonGame is ICommonGame {
    address public gameAdmin;
    uint public blocks2Finish;
    uint internal totalV;
    uint internal sm_reserved;
    bool internal finishing;
    uint internal finishingBlock;
    bool internal autoCreation;
    bool internal autoCreationAfterOwn;
    bool internal transferInteractions;
    bool internal startMinPrizes;
    bool internal profitedGames;

    constructor(address _gameAdmin) public {
        assert(_gameAdmin != 0);
        
        gameAdmin = _gameAdmin;
        blocks2Finish = 50000;
        totalV = 1000;
        autoCreation = true;
        autoCreationAfterOwn = true;
        transferInteractions = false;
        startMinPrizes = false;
        profitedGames = false;
    }

    function getGameAdmin() public view returns (address) {
        return gameAdmin;
    }

    function gameFinished() public view returns(bool) {
        return gameFinishing() && gameFinishedBlock() < block.number;
    }

    function gameFinishing() public view returns(bool) {
        return finishing;
    }

    function stopGame() admin public {
        stopGameInternal(blocks2Finish);
    }

    function totalVariants() public view returns(uint) {
        return totalV;
    }

    function alterTotalVariants(uint _newVariants) admin public {
        totalV = _newVariants;
        emit TotalVariantsChanged(totalV);
    }

    function stopGameInternal(uint blocks2add) internal {
        require(!finishing);

        finishing = true;
        finishingBlock = block.number + blocks2add;
        emit GameStopInitiated(finishingBlock);
    }


    function gameFinishedBlock() public view returns(uint) {
        return finishingBlock;
    }

    function autoCreationAllowed() public view returns(bool) {
        return autoCreation;
    }

    function setAutoCreation(bool allowed) public admin {
        autoCreation = allowed;
        emit AutoCreationChanged(autoCreation);
    }

    function autoCreationAfterOwnAllowed() public view returns(bool) {
        return autoCreationAfterOwn;
    }

    function setAutoCreationAfterOwn(bool allowed) public admin {
        autoCreationAfterOwn = allowed;
        emit AutoCreationAfterOwnChanged(autoCreation);
    }


    function transferInteractionsAllowed() public view returns(bool) {
        return transferInteractions;
    }
    function setTransferInteractions(bool allowed) public admin {
        transferInteractions = allowed;
        emit TransferInteractionsChanged(transferInteractions);
    }

    function startOnlyMinPrizes() public view returns (bool) {
        return startMinPrizes;
    }

    function setStartOnlyMinPrizes(bool minPrizes) public admin {
        startMinPrizes = minPrizes;
        emit StartOnlyMinPrizesChanged(startMinPrizes);
    }

    function startProfitedGamesAllowed() public view returns (bool) {
        return profitedGames;
    }

    function setStartProfitedGamesAllowed(bool games) public admin {
        profitedGames = games;
        emit StartProfitedGamesAllowedChanged(profitedGames);
    }
}

contract BalanceInfo is IBalanceInfo {
    uint internal sm_reserved;

    function totalBalance() public view returns(uint) {
        return address(this).balance;
    } 

    function reservedBalance() public view returns(uint) {
        return sm_reserved;
    }

    function availableBalance() public view returns(uint) {
        if (totalBalance() >= sm_reserved) {
            return totalBalance() - sm_reserved;
        } else {
            return 0;
        }
    } 

    function reserveBalance(uint value) internal returns (uint) {
        uint balance = availableBalance();

        if (value > balance) {
            sm_reserved += balance;
            emit BalanceReserved(balance, sm_reserved);
            return balance;
        } else {
            sm_reserved += value;
            emit BalanceReserved(value, sm_reserved);
            return value;
        }
    }

    function freeBalance(uint value) internal returns(uint) {
        uint toReturn;

        if (value > sm_reserved) {
            toReturn = sm_reserved;
            sm_reserved = 0;
        } else {
            toReturn = value;
            sm_reserved -= value;
        }

        emit BalanceFreed(toReturn, sm_reserved);
        return toReturn;
    }
}

contract IMoneyContract is ICommonGame, IBalanceInfo {
    function profitValue() public view returns(uint);
    function getDeveloperProfit() public view returns(uint);
    function getCharityProfit() public view returns(uint);
    function getFinalProfit() public view returns(uint);
    function getLastBalance() public view returns(uint);
    function getLastProfitSync() public view returns(uint);
    function getDeveloperShare() public view returns(uint);
    function getCharityShare() public view returns(uint);
    function getFinalShare() public view returns(uint);
    function depositToBank() public payable;
    function canUpdatePayout() public view returns(bool);
    function recalculatePayoutValue() public;
    function withdrawPayout() public;
    function withdraw2Address(address addr) public;
    function finishedWithdrawalTime() public view returns(bool);
    function finishedWithdrawalBlock() public view returns(uint);
    function getTotalPayoutValue() public view returns(uint);
    function getPayoutValue(address addr) public view returns(uint);
    function getPayoutValueSender() public view returns(uint);
    function addDeveloper(address dev, string name, string url) public;
    function getDeveloperName(address dev) public view returns (string);
    function getDeveloperUrl(address dev) public view returns (string);
    function developersAdded() public view returns (bool);
    function addCharity(address charity, string name, string url) public;
    function getCharityName(address charity) public view returns (string);
    function getCharityUrl(address charity) public view returns (string);
    function dedicatedCharitySet() public view returns(bool);
    function setDedicatedCharityForNextRound(address charity) public;
    function dedicatedCharityAddress() public view returns(address);

    event MoneyDeposited(address indexed sender, uint value);
    event MoneyWithdrawn(address indexed reciever, uint value);
    event ProfitRecalculated(bool gameFinish, uint developerProfit, uint charityProfit, uint finalProfit, 
    uint developerCount, uint charityCount, bool dedicated, address dedicatedCharity);
    event CharityAdded(address charity, string name, string url);
    event DedicatedCharitySelected(address charity);
    event DeveloperAdded(address developer, string name, string url);
}

contract MoneyContract is IMoneyContract {
    uint public sm_developerShare; 
    uint public sm_charityShare;
    uint public sm_finalShare;

    ProfitInfo[] public sm_developers;
    uint public sm_maxDevelopers;
    
    ProfitInfo[] public sm_charity;
    mapping(address => bool) public sm_reciever;
    mapping(address => uint) public sm_profits;
    address public sm_dedicatedCharity;

    uint public sm_lastProfitSync;
    uint public sm_profitSyncLength;
    uint public sm_afterFinishLength;
    uint public sm_lastBalance; 
    uint internal sm_reserved;

    struct ProfitInfo {
        address receiver; 
        string description;
        string url;
    }

    constructor(uint _developerShare, uint _maxDevelopers, 
            uint _charityShare, uint _finalShare, uint _profitSyncLength, uint _afterFinishLength) public {
        assert(_developerShare >= 0 && _developerShare <= 1 ether);
        assert(_charityShare >= 0 && _charityShare <= 1 ether);
        assert(_finalShare >= 0 && _finalShare <= 1 ether);

        sm_developerShare = _developerShare;
        sm_maxDevelopers = _maxDevelopers;
        sm_charityShare = _charityShare;
        sm_finalShare = _finalShare;
        sm_profitSyncLength = _profitSyncLength;
        sm_afterFinishLength = _afterFinishLength;
        sm_lastProfitSync = block.number;
    }

    function getDeveloperShare() public view returns(uint) {
        return sm_developerShare;
    }

    function getCharityShare() public view returns(uint) {
        return sm_charityShare;
    }

    function getFinalShare() public view returns(uint) {
        return sm_finalShare;
    }

    function getLastBalance() public view returns(uint) {
        return sm_lastBalance;
    }

    function getLastProfitSync() public view returns(uint) {
        return sm_lastProfitSync;
    }

    function canUpdatePayout() public view returns(bool) {
        return developersAdded() && (gameFinished() || block.number >= sm_profitSyncLength + sm_lastProfitSync);
    }

    function recalculatePayoutValue() public {
        if (canUpdatePayout()) {
            recalculatePayoutValueInternal();
        } else {
            revert();
        }
    }

    function recalculatePayoutValueInternal() internal {
        uint d_profit = 0;
        uint c_profit = 0;
        uint o_profit = 0;
        bool dedicated = dedicatedCharitySet();
        address dedicated_charity = sm_dedicatedCharity;

        if (gameFinished()) {
            o_profit = getFinalProfit();
            c_profit = availableBalance() - o_profit;
            distribute(o_profit, sm_developers);
            distribute(c_profit, sm_charity);
        } else {
            d_profit = getDeveloperProfit();
            c_profit = getCharityProfit();
            distribute(d_profit, sm_developers);

            if (dedicated) {
                distributeTo(c_profit, sm_dedicatedCharity);
            } else {
                distribute(c_profit, sm_charity);
            }

            sm_lastProfitSync = block.number;
            sm_dedicatedCharity = address(0);
        }

        sm_lastBalance = availableBalance();
        emit ProfitRecalculated(gameFinished(), d_profit, c_profit, o_profit, 
            sm_developers.length, sm_charity.length, dedicated, dedicated_charity);
    }

    function addDeveloper(address dev, string name, string url) admin public {
        require(!sm_reciever[dev]);
        require(!gameFinished());
        require(sm_developers.length < sm_maxDevelopers);

        sm_developers.push(ProfitInfo(dev, name, url));
        sm_reciever[dev] = true;
        emit DeveloperAdded(dev, name, url);
    }

    function developersAdded() public view returns (bool) {
        return sm_maxDevelopers == sm_developers.length;
    }

    function getDeveloperName(address dev) public view returns (string) {
        for (uint i = 0; i < sm_developers.length; i++) {
            if (sm_developers[i].receiver == dev) return sm_developers[i].description;
        }

        return "";
    }
    function getDeveloperUrl(address dev) public view returns (string) {
        for (uint i = 0; i < sm_developers.length; i++) {
            if (sm_developers[i].receiver == dev) return sm_developers[i].url;
        }

        return "";
    }

    function addCharity(address charity, string name, string url) admin public {
        require(!sm_reciever[charity]);
        require(!gameFinished());

        sm_charity.push(ProfitInfo(charity, name, url));
        sm_reciever[charity] = true;
        emit CharityAdded(charity, name, url);
    }

    function getCharityName(address charity) public view returns (string) {
        for (uint i = 0; i < sm_charity.length; i++) {
            if (sm_charity[i].receiver == charity) return sm_charity[i].description;
        }

        return "";
    }
    function getCharityUrl(address charity) public view returns (string) {
        for (uint i = 0; i < sm_charity.length; i++) {
            if (sm_charity[i].receiver == charity) return sm_charity[i].url;
        }

        return "";
    }


    function charityIndex(address charity) view internal returns(int) {
        for (uint i = 0; i < sm_charity.length; i++) {
            if (sm_charity[i].receiver == charity) {
                return int(i);
            }
        }
        
        return -1;
    }

    function charityExists(address charity) view internal returns(bool) {
        return charityIndex(charity) >= 0;
    }

    function setDedicatedCharityForNextRound(address charity) admin public {
        require(charityExists(charity));
        require(sm_dedicatedCharity == address(0));
        sm_dedicatedCharity = charity;
        emit DedicatedCharitySelected(sm_dedicatedCharity);
    }

    function dedicatedCharitySet() public view returns(bool) {
        return sm_dedicatedCharity != address(0);
    }

    function dedicatedCharityAddress() public view returns(address) {
        return sm_dedicatedCharity;
    }
    
    function depositToBank() public payable {
        require(!gameFinished());
        require(msg.value > 0);
        sm_lastBalance += msg.value;
        emit MoneyDeposited(msg.sender, msg.value);
    }

    function finishedWithdrawalTime() public view returns(bool) {
        return gameFinished() && (block.number > finishedWithdrawalBlock());
    }

    function finishedWithdrawalBlock() public view returns(uint) {
        if (gameFinished()) {
            return gameFinishedBlock() + sm_afterFinishLength;
        } else {
            return 0;
        }
    }

    function getTotalPayoutValue() public view returns(uint) {
        uint payout = 0;

        for (uint i = 0; i < sm_developers.length; i++) {
            payout += sm_profits[sm_developers[i].receiver];
        }
        for (i = 0; i < sm_charity.length; i++) {
            payout += sm_profits[sm_charity[i].receiver];
        }

        return payout;
    }

    function getPayoutValue(address addr) public view returns(uint) {
        return sm_profits[addr];
    }

    function getPayoutValueSender() public view returns(uint) {
        return getPayoutValue(msg.sender);
    }

    function withdrawPayout() public {
        if (finishedWithdrawalTime() && msg.sender == getGameAdmin()) {
            getGameAdmin().transfer(address(this).balance);
        } else {
            withdraw2Address(msg.sender);
        }
    }

    function withdraw2Address(address addr) public {
        require(sm_profits[addr] > 0);

        uint value = sm_profits[addr];
        sm_profits[addr] = 0;

        freeBalance(value);
        addr.transfer(value);
        emit MoneyWithdrawn(addr, value);
    }

    function profitValue() public view returns(uint) {
        if (availableBalance() >= sm_lastBalance) {
            return availableBalance() - sm_lastBalance;
        } else {
            return 0;
        }
    }

    function getDeveloperProfit() public view returns(uint) {
        return (profitValue() * sm_developerShare) / (1 ether);
    }

    function getCharityProfit() public view returns(uint) {
        return (profitValue() * sm_charityShare) / (1 ether);
    }

    function getFinalProfit() public view returns(uint) {
        return (availableBalance() * sm_finalShare) / (1 ether);
    }

    function distributeTo(uint value, address recv) internal {
        sm_profits[recv] += value;
        reserveBalance(value);
    }

    function distribute(uint profit, ProfitInfo[] recvs) internal {
        if (recvs.length > 0) {
            uint each = profit / recvs.length;
            uint total = 0;
            for (uint i = 0; i < recvs.length; i++) {
                if (i == recvs.length - 1) {
                    distributeTo(profit - total, recvs[i].receiver);
                } else {
                    distributeTo(each, recvs[i].receiver);
                    total += each;
                }
            }
        }
    }
}

contract ISignedContractId {
    function getId() public view returns(string);
    function getVersion() public view returns(uint);
    function getIdHash() public view returns(bytes32);
    function getDataHash() public view returns(bytes32);
    function getBytes() public view returns(bytes);
    function sign(uint8 v, bytes32 r, bytes32 s) public;
    function getSignature() public view returns(uint8, bytes32, bytes32);
    function isSigned() public view returns(bool);
}


contract SignedContractId is ISignedContractId {
    string public contract_id;
    uint public contract_version;
    bytes public contract_signature;
    address public info_address;
    address public info_admin;
    uint8 public v; 
    bytes32 public r; 
    bytes32 public s;
    bool public signed;

    constructor(string id, uint version, address info, address admin) public {
        contract_id = id;
        contract_version = version;
        info_address = info;
        info_admin = admin;
        signed = false;
    }
    function getId() public view returns(string) {
        return contract_id;
    }
    function getVersion() public view returns(uint) {
        return contract_version;
    }
    function getIdHash() public view returns(bytes32) {
        return keccak256(abi.encodePacked(contract_id));
    }
    function getBytes() public view returns(bytes) {
        return abi.encodePacked(contract_id);
    }


    function getDataHash() public view returns(bytes32) {
        return keccak256(abi.encodePacked(getIdHash(), getVersion(), info_address, address(this)));
    }

    function sign(uint8 v_, bytes32 r_, bytes32 s_) public {
        require(!signed);
        bytes32 hsh = keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", getDataHash()));
        require(info_admin == ecrecover(hsh, v_, r_, s_));
        v = v_;
        r = r_;
        s = s_;
        signed = true;
    }

    function getSignature() public view returns(uint8, bytes32, bytes32) {
        return (v, r, s);
    }

    function isSigned() public view returns(bool) {
        return signed;
    }
}

contract IGameLengthLibrary is ICommonGame {
    function getMinGameLength() public view returns(uint);
    function getMaxGameLength() public view returns(uint);
    function getMinGameAddon() public view returns(uint);
    function getMaxGameAddon() public view returns(uint);

    function calcGameLength(uint number) public view returns (uint);
    function calcGameAddon(uint number) public view returns (uint);

    event MinGameLengthAltered(uint newValue);
    event MaxGameLengthAltered(uint newValue);
    event AddonAltered(uint newValue);

    function alterMaxGameLength(uint _maxGameLength) public;
    function alterMinGameLength(uint _minGameLength) public;
    function alterAddon(uint _addon) public;
}

contract LinearGameLibrary is IGameLengthLibrary {
    uint public minLength;
    uint public maxLength;
    uint public addon;

    constructor(uint _minLength, uint _maxLength, uint _addon) public {
        assert(_minLength <= _maxLength);

        minLength = _minLength;
        maxLength = _maxLength;
        addon = _addon;
    }

    function calcGameLength(uint number) public view returns (uint) {
        return minLength + ((maxLength - minLength) * ((number % totalVariants()) + 1)) / totalVariants();
    }
    
    function calcGameAddon(uint) public view returns (uint) {
        return addon;
    }

    function getMinGameLength() public view returns(uint) {
        return minLength;
    }

    function getMaxGameLength() public view returns(uint) {
        return maxLength;
    }

    function getMinGameAddon() public view returns(uint) {
        return addon;
    }

    function getMaxGameAddon() public view returns(uint) {
        return addon;
    }
     
    function alterMaxGameLength(uint _maxGameLength) public admin {
        require(_maxGameLength > 0, "Max game length should be not zero");
        require(_maxGameLength >= minLength, "Max game length should be not more than min length");
        maxLength = _maxGameLength;
        emit MaxGameLengthAltered(maxLength);
    }

    function alterMinGameLength(uint _minGameLength) public admin {
        require(_minGameLength > 0, "Min game length should be not zero");
        require(_minGameLength <= maxLength, "Min game length should be less than max length");
        minLength = _minGameLength;
        emit MinGameLengthAltered(minLength);
    }

    function alterAddon(uint _addon) public admin {
        addon = _addon;
        emit AddonAltered(addon);
    }
}
 
contract IGameManager {
    function startGameInternal(uint gameId, uint length, uint addOn, uint prize) internal;
    function betInGameInternal(uint gameId, uint bet) internal;

    function withdrawPrize(uint gameId) public;
    function withdrawPrizeInternal(uint gameId, uint additional) internal;

    function gameExists(uint gameId) public view returns (bool);
    function finishedGame(uint gameId) public view returns(bool);
    function getWinner(uint gameId) public view returns(address);
    function getBet(uint gameId, address better) public view returns(uint);
    function payedOut(uint gameId) public view returns(bool);
    function prize(uint gameId) public view returns(uint);
    function endsIn(uint gameId) public view returns(uint);
    function lastBetBlock(uint gameId) public view returns(uint);

    function addonEndsIn(uint gameId) public view returns(uint);
    function totalBets(uint gameId) public view returns(uint);
    function gameProfited(uint gameId) public view returns(bool);

    event GameStarted(uint indexed gameId, address indexed starter, uint blockNumber, uint finishBlock, uint prize);
    event GameBet(uint indexed gameId, address indexed bidder, address indexed winner, uint highestBet, uint finishBlock, uint value);
    event GamePrizeTaken(uint indexed gameId, address indexed winner);
}

contract GameManager is IBalanceInfo, IGameManager {
    mapping (uint => GameInfo) games;
    mapping (uint => mapping (address => uint)) bets;

    struct GameInfo {
        address highestBidder; // the person who made the highest bet in this game
        address starter; // the person who started this game
        uint blockFinish; // the block when the game will be finished
        uint prize; // the prize, that will be awarded to the winner
        uint totalBets; // the amount of total bets to this game
        bool payedOut; // true, if the user has taken back his deposit
        uint lastBetBlock;
        uint addOn;
    }

    function startGameInternal(uint gameId, uint length, uint addOn, uint prize) internal {
        require(!gameExists(gameId));
        require(prize > 0);
        require(length > 0);
        games[gameId].starter = msg.sender;
        games[gameId].prize = prize;
        reserveBalance(prize);
        games[gameId].blockFinish = block.number + length - 1;
        games[gameId].addOn = addOn;
        emit GameStarted(gameId, msg.sender, block.number, games[gameId].blockFinish, prize);
    }

    function betInGameInternal(uint gameId, uint bet) internal {
        require(bet > 0, "Bet should be not zero");
        require(gameExists(gameId), "No such game");
        require(!finishedGame(gameId), "Game is finished");
        uint newBet = bets[gameId][msg.sender] + bet;
        
        if (newBet > bets[gameId][games[gameId].highestBidder]) {
            games[gameId].highestBidder = msg.sender;
            games[gameId].lastBetBlock = block.number;
        } 

        bets[gameId][msg.sender] = newBet;
        games[gameId].totalBets += bet;
        emit GameBet(gameId, msg.sender, games[gameId].highestBidder, bets[gameId][games[gameId].highestBidder], addonEndsIn(gameId), newBet);
    }

    function withdrawPrize(uint gameId) public {
        withdrawPrizeInternal(gameId, 0);
    }

    function withdrawPrizeInternal(uint gameId, uint additional) internal {
        require(finishedGame(gameId), "Game not finished");
        require(msg.sender == games[gameId].highestBidder, "You are not the winner");
        require(!games[gameId].payedOut, "Game already payed");
        games[gameId].payedOut = true;
        freeBalance(games[gameId].prize);
        msg.sender.transfer(games[gameId].prize + additional);
        emit GamePrizeTaken(gameId, msg.sender);
    }

    function gameExists(uint gameId) public view returns (bool) {
        return games[gameId].blockFinish != 0;
    }

    function getWinner(uint gameId) public view returns(address) {
        return games[gameId].highestBidder;
    }

    function finishedGame(uint gameId) public view returns(bool) {
        if (!gameExists(gameId)) 
            return false;
        return addonEndsIn(gameId) < block.number;
    }

    function payedOut(uint gameId) public view returns(bool) {
        return games[gameId].payedOut;
    }

    function prize(uint gameId) public view returns(uint) {
        return games[gameId].prize;
    }

    function lastBetBlock(uint gameId) public view returns(uint) {
        return games[gameId].lastBetBlock;
    }

    function getBet(uint gameId, address better) public view returns(uint) {
        return bets[gameId][better];
    }

    function endsIn(uint gameId) public view returns(uint) {
        return games[gameId].blockFinish;
    }

    function addonEndsIn(uint gameId) public view returns(uint) {
        uint addonB = games[gameId].lastBetBlock + games[gameId].addOn;
        if (addonB >= games[gameId].blockFinish) {
            return addonB;
        } else {
            return games[gameId].blockFinish;
        }
    }

    function totalBets(uint gameId) public view returns(uint) {
        return games[gameId].totalBets;
    }

    function gameProfited(uint gameId) public view returns(bool) {
        return games[gameId].totalBets >= games[gameId].prize;
    }
}
contract StartGame is IStartGame, ICommonGame, IPrizeLibrary, IMinMaxPrize, IGameLengthLibrary, IGameManager, IBlockRandomLibrary {
    bool internal previousCalcRegular;

    constructor(uint _repeatBlock, uint _addonBlock) public
    {
        assert(_repeatBlock <= 250);
        repeatBlock = _repeatBlock;
        addonBlock = _addonBlock;
        calcNextGameId();
        defaultId = nextGameId;
    }

    function startOwnFixed(uint gameId, uint length, uint addon, uint prize) public admin payable {
        require(msg.value > 0);
        require(!gameExists(gameId));
        require(gameId % 2 == 1);
        require(length >= getMinGameLength());
        require(prize >= getMinPrize() && prize <= getWholePrize());

        updateRandom();
        startGameInternal(gameId, length, addon, prize);
        profitedBet(gameId);
    }

    function randomValueWithMinPrize() internal view returns(uint) {
        if (!startOnlyMinPrizes() && isRandomAvailable()) {
            return getRandomValue();
        }

        return 0;
    }

    function startGameDetermine(uint gameId) internal {
        uint random = randomValueWithMinPrize();
        startGameInternal(gameId, calcGameLength(random), calcGameAddon(random), calculatePrize(random, getMinPrize(), getMaxPrize()));
    }

    function betInGame(uint gameId) public payable {
        require(msg.value > 0, "Bet should be not zero");
        updateRandom();

        if (!gameExists(gameId)) {
            require(canStartGame(), "Game cannot be started");
            require(startGameId() == gameId, "No such scheduled game");
            startGameDetermine(gameId);
            updateDefaultGame(gameId);
            calcNextGameId();
        }

        profitedBet(gameId);
    }

    function profitedBet(uint gameId) internal {
        bool profited = gameProfited(gameId);
        betInGameInternal(gameId, msg.value);
        if (profited != gameProfited(gameId)) {
            if (startProfitedGamesAllowed() && (gameId % 2 == 0 || autoCreationAfterOwnAllowed())) {
                createFastGamesCount++;
                if (!isRandomAvailable() && previousCalcRegular && createFastGamesCount == 1) {
                    calcNextGameId();
                }
                emit FastGamesChanged(createFastGamesCount);
            }
            profitedCount++;
            emit GameProfitedEvent(gameId);
        }
    }
        
    uint public repeatBlock;
    uint public addonBlock;

    function getRepeatBlock() public view returns(uint) {
        return repeatBlock;
    }
    function getAddonBlock() public view returns(uint) {
        return addonBlock;
    }

    function alterRepeatBlock(uint _repeatBlock) admin public {
        assert(_repeatBlock < 250);
        repeatBlock = _repeatBlock;
        emit RepeatBlockAltered(repeatBlock);
    }

    function alterAddonBlock(uint _addonBlock) admin public {
        addonBlock = _addonBlock;
        emit RepeatAddonBlockAltered(addonBlock);
    }

    uint internal nextGameId;
    uint internal defaultId;
    uint internal profitedCount;
    uint internal createFastGamesCount;

    function getProfitedCount() public view returns(uint) {
        return profitedCount;
    }

    function getCreateFastGamesCount() public view returns(uint) {
        return createFastGamesCount;
    }

    function setCreateFastGamesCount(uint count) public admin {
        createFastGamesCount = count;
        emit FastGamesChanged(createFastGamesCount);
    }

    function recalcNextGameId() public admin {
        if (!isRandomAvailable()) {
            calcNextGameId();
        } else {
            revert("You cannot recalculate, unless the prize has expired");
        }
    }

    function calcNextGameId() internal {
        uint ngi;

        previousCalcRegular = createFastGamesCount == 0;

        if (createFastGamesCount > 0) {
            ngi = block.number + addonBlock;
            createFastGamesCount--;
        } else {
            ngi = block.number + (repeatBlock - block.number % repeatBlock);
        }

        if (ngi % 2 == 1) {
            ngi++;
        }

        nextGameId = ngi;
        setRandomBlock(nextGameId);
        updateDefaultGame(nextGameId);
        emit NextGameIdCalculated(nextGameId);
    }

    function canStartGame() public view returns(bool) {
        return randomBlockPassed() && creationAllowed();
    }

    function startGameId() public view returns(uint) {
        return nextGameId;
    }

    function startPrizeValue() public view returns(uint) {
        return calculatePrize(randomValueWithMinPrize(), getMinPrize(), getMaxPrize());
    }

    function startGameLength() public view returns(uint) {
        return calcGameLength(randomValueWithMinPrize());
    }

    function startGameAddon() public view returns(uint) {
        return calcGameAddon(randomValueWithMinPrize());
    }

    function getStartGameStatus() public view returns(bool, uint, uint, uint, uint) {
        uint random = randomValueWithMinPrize();
        return (
            canStartGame(), 
            nextGameId, 
            calculatePrize(random, getMinPrize(), getMaxPrize()),
            calcGameLength(random),
            calcGameAddon(random));
    }

    function updateDefaultGame(uint gameId) internal {
        if (finishedGame(defaultId) || !gameExists(defaultId)) {
            defaultId = gameId;
            emit DefaultGameUpdated(defaultId);
        } 
    }

    function defaultGameId() public view returns(uint) {
        if (!finishedGame(defaultId) && gameExists(defaultId)) return defaultId;
        if (canStartGame()) return startGameId();
        return 0;
    }

    function defaultGameAvailable() public view returns(bool) {
        return !finishedGame(defaultId) && gameExists(defaultId) || canStartGame();
    }

    mapping (address => uint) transferGames;

    function getTransferProfitedGame(address participant) public view returns(uint) {
        if (finishedGame(transferGames[participant]) && getWinner(transferGames[participant]) == participant) {
            return transferGames[participant];
        }

        return 0;
    }

    function getTransferProfitedGame() internal view returns(uint) {
        return getTransferProfitedGame(msg.sender);
    }

    function processTransfer() internal {
        uint tpg = getTransferProfitedGame();
        if (tpg == 0) {
            if (!finishedGame(defaultId) && gameExists(defaultId)) {
                betInGame(defaultId);
            } else {
                betInGame(startGameId());
            }
            transferGames[msg.sender] = defaultId;
        } else {
            transferGames[msg.sender] = 0;
            withdrawPrizeInternal(tpg, msg.value);
        } 

        emit TransferBet(msg.sender, msg.value);
    }

    function processTransferInteraction() internal {
        if (transferInteractionsAllowed()) {
            processTransfer();
        } else {
            revert();
        }
    }
}

contract ICharbetto is IMoneyContract, IStartGame, IBalanceSharePrizeContract,
        IBlockRandomLibrary, IMinMaxPrize, IGameLengthLibrary, IGameManager, IFunctionPrize, IPrizeLibrary {
    function recalculatePayoutValueAdmin() public;
    function stopGameFast() public;
}

contract Charbetto is CommonGame, BlockRandomLibrary, BalanceInfo, PrizeLibrary, EllipticPrize16x, 
        MoneyContract, StartGame, GameManager, LinearGameLibrary, BalanceSharePrizeContract {
    constructor(address _admin) public
        CommonGame(_admin) 
        BlockRandomLibrary(250)
        BalanceInfo()
        PrizeLibrary()
        EllipticPrize16x()
        MoneyContract(
            10 finney /*1 percent*/, 
            5, /*5 developers at maximum*/
            100 finney /*10 percent*/, 
            100 finney /*10 percent*/, 
            20000, 200000)
        StartGame(5, 3)  
        GameManager()
        LinearGameLibrary(50, 1000, 3)
        BalanceSharePrizeContract(10 finney, 100 finney)
    {
        totalV = 1000;
        minLength = 20;
        maxLength = 30;
        transferInteractions = true;
    }
    function betInGame(uint gameId) public payable {
        bool exists = gameExists(gameId);

        if (!exists) {
            reserveBalance(msg.value);
        }

        super.betInGame(gameId);

        if (!exists) {
            freeBalance(msg.value);
        }
    }

    function isItReallyCharbetto() public pure returns (bool) {
        return true;
    }

    function () payable public {
        processTransferInteraction();
    }
}

contract ISignedCharbetto is ISignedContractId, ICharbetto {}

contract SignedCharbetto is Charbetto, SignedContractId {
    constructor(address admin_, uint version_, address infoContract_, address infoAdminAddress_) public 
        Charbetto(admin_) 
        SignedContractId("charbetto", version_, infoContract_, infoAdminAddress_)
    {} 

    function recalculatePayoutValueAdmin() admin public {
        revert();
    }

    function stopGameFast() admin public {
        revert();
    }

    function () payable public {
        processTransferInteraction();
    }
}