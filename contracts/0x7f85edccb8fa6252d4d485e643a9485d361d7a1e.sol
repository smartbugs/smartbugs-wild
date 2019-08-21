pragma solidity ^0.4.25;

// File: contracts/MoonRaffleContractInterface.sol

contract MoonRaffleContractInterface {

    function sendContractSeed() public payable;

    function sendContractDeposit() public payable;

    function hasEntry() public view returns (bool);

    function isValidReferrer(address) public view returns (bool);

    function play(address) external payable;

    function claimPrize() external;

    function claimReferralBonus() external;

    function claimRefund() external;

    function calculateNonce() external;

    function calculateFinalRandomNumber(string, uint)  internal;

    function calculateWinners() internal;

    function calculatePrizes() internal;

    function finishMoonRaffle(string, string, string, string) external;

    function claimFeeAndDeposit() external;

    function claimRollover() external;

    function recoverUnclaimedBalance() external;

    function retractContract() external;

    function burnDeposit() internal;

    function getRandomNumber() external view returns (bytes32);

    function getTime() external view returns (uint256);

    function getSeedAmount() external view returns (uint256);

    function getDepositAmount() external view returns (uint256);

    function getCurrentPrizeAmounts() external view returns (uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256);

    function getWinners() external view returns (address, address, address);

    function getFirstPrizeAddress() external view returns (address);

    function getSecondPrizeAddress() external view returns (address);

    function getThirdPrizeAddress() external view returns (address);

    function getMyStatus() external view returns (uint256, bool, uint256, uint256);

    function getCurrentPhase() external view returns (uint256, string);

    function getAddresses() external view returns (address, address);

    function getMoonRaffleEntryParameters() external view returns (uint256, uint256);

    function getMoonRaffleTimes() external view returns (uint256, uint256, uint256, uint256, uint256, uint256);

    function getMoonRaffleStatus() external view returns (uint256, uint256, uint256);

    function getCurrentDefaultReferrer() external view returns (address);

    function getStarReferrerDetails() external view returns (address, uint256);

    function getBinaryNonce() external view returns (bool[256]);

    function getMoonRaffleParamenters() external view returns (
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256,
      uint256
      );

    function hasPlayerClaimedPrize() external view returns (bool);

    function hasPlayerClaimedReferralBonus() external view returns (bool);

    function getContractBalance() external view returns (uint256);

    function isRetractable() external view returns (bool);

}

// File: contracts/MoonRaffleContractFactoryInterface.sol

contract MoonRaffleContractFactoryInterface {

    function createMoonRaffleContract(
        address _addressOne,
        bytes32 _initialSecretHash1,
        bytes32 _initialSecretHash2,
        bytes32 _initialSecretHash3,
        bytes32 _initialSecretHash4,
        uint256[14] _moonRaffleParameters
        )
        public
        payable
        returns (address);

}

// File: contracts/MoonRaffleMain.sol

contract MoonRaffleMain {

    address addressOne;
    address moonRaffleFactoryAddress;

    uint256 moonRaffleCounter = 0;    //Keeps track of how many raffles have been completed
    string publicMessage = "when moon? buy your ticket now!";

    // ECONOMIC SETTINGS
    uint256 pricePerTicket = 1 finney;
    uint256 maxTicketsPerTransaction = 300;
    uint256 prizePoolPercentage = 75;
    uint256 firstPrizePercentage = 55;
    uint256 secondPrizePercentage = 15;
    uint256 thirdPrizePercentage = 5;
    uint256 contractFeePercentage = 5;
    uint256 rolloverPercentage = 10;
    uint256 referralPercentage = 10;
    uint256 referralHurdle = 10;
    uint256 referralFloorTimePercentage = 75;

    // TIME SETTINGS
    uint256 moonRaffleLiveSecs = 518400; // 6 DAYS default
    uint256 winnerCalcSecs = 345600; // 4 DAYS default
    uint256 claimSecs = 15552000; // 180 DAYS default

    uint256 latestMoonRaffleCompleteTime = 0;
    bool latestMoonRaffleSeeded = true;

    // CURRENT LIVE ITERATION ADDRESS
    address[] oldMoonRaffleAddresses;
    address currentMoonRaffleAddress = 0;

    mapping(address => address[]) winners;

    // EVENTS
    event logNewMoonRaffleFactorySet(address _moonRaffleFactory);
    event logDonation(address _sender, uint256 _amount);
    event logNewMoonRaffle(address _newMoonRaffle);
    event logUpdatedPricePerTicket(uint256 _newPricePerTicket);
    event logUpdatedMaxTicketsPerTransaction(uint256 _newMaxTicketsPerTransaction);
    event logUpdatedPayoutEconomics(uint256 _newPrizePoolPercentage, uint256 _newFirstPrizePercentage, uint256 _newSecondPrizePercentage, uint256 _newThirdPrizePercentage, uint256 _newContractFeePercentage, uint256 _newRolloverPercentage, uint256 _newReferralPercentage, uint256 _newReferralHurdle);
    event logUpdatedTimeParams(uint256 _newMoonRaffleLiveSecs, uint256 _newWinnerCalcSecs, uint256 _newClaimSecs, uint256 _referralFloorTimePercentage);
    event logChangedAddressOne(address _newAddressOne);
    event logAddedToCurrentMoonRaffle(uint256 _addedAmount);
    event logChangedPublicMessage(string _newPublicMessage);

    modifier onlyAddressOne() {
        require(msg.sender == addressOne);
        _;
    }

    modifier isNoLottoLive() {
        require(now > latestMoonRaffleCompleteTime);
        _;
    }

    // FALLBACK
    function() public payable {
        emit logDonation(msg.sender, msg.value);
    }

    constructor() public payable {
        addressOne = msg.sender;
    }

    function newMoonRaffle(
        bytes32 _initialSecretHash1,
        bytes32 _initialSecretHash2,
        bytes32 _initialSecretHash3,
        bytes32 _initialSecretHash4
    )
    onlyAddressOne
    isNoLottoLive
    external
    {
        require(latestMoonRaffleCompleteTime == 0);

       currentMoonRaffleAddress = MoonRaffleContractFactoryInterface(moonRaffleFactoryAddress).createMoonRaffleContract(
            addressOne,
            _initialSecretHash1,
            _initialSecretHash2,
            _initialSecretHash3,
            _initialSecretHash4,
            [
                pricePerTicket,
                maxTicketsPerTransaction,
                prizePoolPercentage,
                firstPrizePercentage,
                secondPrizePercentage,
                thirdPrizePercentage,
                contractFeePercentage,
                rolloverPercentage,
                referralPercentage,
                referralHurdle,
                referralFloorTimePercentage,
                moonRaffleLiveSecs,
                winnerCalcSecs,
                claimSecs
            ]
        );

        latestMoonRaffleCompleteTime = now + moonRaffleLiveSecs;
        latestMoonRaffleSeeded = false;
        moonRaffleCounter += 1;
        emit logNewMoonRaffle(currentMoonRaffleAddress);
    }

    function seedMoonRaffle(uint256 _seedAmount) onlyAddressOne external {
        require(latestMoonRaffleCompleteTime != 0);
        require(latestMoonRaffleSeeded == false);
        require(_seedAmount <= address(this).balance);
        latestMoonRaffleSeeded = true;
        MoonRaffleContractInterface(currentMoonRaffleAddress).sendContractSeed.value(_seedAmount)();
    }

    function retractMoonRaffle() onlyAddressOne external {
        require(latestMoonRaffleCompleteTime != 0);
        require(MoonRaffleContractInterface(currentMoonRaffleAddress).isRetractable() == true);
        if (address(currentMoonRaffleAddress).balance > 0) { MoonRaffleContractInterface(currentMoonRaffleAddress).retractContract();}
        latestMoonRaffleCompleteTime = 0;
        moonRaffleCounter -= 1;
        latestMoonRaffleSeeded = true;
        if (oldMoonRaffleAddresses.length > 0) {
            currentMoonRaffleAddress = oldMoonRaffleAddresses[(oldMoonRaffleAddresses.length - 1)];
        } else {
            currentMoonRaffleAddress = 0;
        }
    }

    function logFinishedInstance() onlyAddressOne public {
        assert(now >= latestMoonRaffleCompleteTime);
        assert(latestMoonRaffleCompleteTime > 0);
        latestMoonRaffleCompleteTime = 0;
        oldMoonRaffleAddresses.push(currentMoonRaffleAddress);
        MoonRaffleContractInterface tempMoonRaffle = MoonRaffleContractInterface(currentMoonRaffleAddress);
        winners[tempMoonRaffle.getFirstPrizeAddress()].push(currentMoonRaffleAddress);
        winners[tempMoonRaffle.getSecondPrizeAddress()].push(currentMoonRaffleAddress);
        winners[tempMoonRaffle.getThirdPrizeAddress()].push(currentMoonRaffleAddress);
    }

    function updatePricePerTicket(uint256 _newPricePerTicket) onlyAddressOne public {
        require(_newPricePerTicket >= 1 finney);
        require(_newPricePerTicket <= 1 ether);
        pricePerTicket = _newPricePerTicket;
        emit logUpdatedPricePerTicket(_newPricePerTicket);
    }

    function updateMaxTicketsPerTransaction(uint256 _newMaxTickets) onlyAddressOne public {
        require(_newMaxTickets >= 10);
        maxTicketsPerTransaction = _newMaxTickets;
        emit logUpdatedMaxTicketsPerTransaction(_newMaxTickets);
    }


    function updatePayoutEconomics(
        uint256 _newPrizePoolPercentage,
        uint256 _newFirstPrizePercentage,
        uint256 _newSecondPrizePercentage,
        uint256 _newThirdPrizePercentage,
        uint256 _newContractFeePercentage,
        uint256 _newRolloverPercentage,
        uint256 _newReferralPercentage,
        uint256 _newReferralHurdle
    )
    onlyAddressOne
    public
    {
        require(_newPrizePoolPercentage + _newContractFeePercentage + _newRolloverPercentage + _newReferralPercentage == 100);
        require(_newPrizePoolPercentage == _newFirstPrizePercentage + _newSecondPrizePercentage + _newThirdPrizePercentage);
        require(_newContractFeePercentage <= 10);
        require(_newRolloverPercentage <= 20);
        require(_newReferralPercentage <= 20);
        require(_newReferralHurdle <= maxTicketsPerTransaction);

        prizePoolPercentage = _newPrizePoolPercentage;
        firstPrizePercentage = _newFirstPrizePercentage;
        secondPrizePercentage = _newSecondPrizePercentage;
        thirdPrizePercentage = _newThirdPrizePercentage;
        contractFeePercentage = _newContractFeePercentage;
        rolloverPercentage = _newRolloverPercentage;
        referralPercentage = _newReferralPercentage;
        referralHurdle = _newReferralHurdle;

        emit logUpdatedPayoutEconomics(_newPrizePoolPercentage, _newFirstPrizePercentage, _newSecondPrizePercentage, _newThirdPrizePercentage, _newContractFeePercentage, _newRolloverPercentage, _newReferralPercentage, _newReferralHurdle);
    }

    function updateTimeParams(
        uint256 _moonRaffleLiveSecs,
        uint256 _winnerCalcSecs,
        uint256 _claimSecs,
        uint256 _referralFloorTimePercentage
    )
    onlyAddressOne
    public
    {
        require(_moonRaffleLiveSecs >= 86400);
        // Min 1 day
        require(_moonRaffleLiveSecs <= 15552000);
        // Max 180 days
        require(_winnerCalcSecs >= 43200);
        // Min 12 hour
        require(_winnerCalcSecs <= 345600);
        // Max 96 hours
        require(_claimSecs >= 2592000);
        // Min 30 days
        require(_claimSecs <= 31536000);
        // Max 365 days
        require(_referralFloorTimePercentage >= 25);
        // Min 25%
        require(_referralFloorTimePercentage <= 90);
        // Max 90%
        moonRaffleLiveSecs = _moonRaffleLiveSecs;
        winnerCalcSecs = _winnerCalcSecs;
        claimSecs = _claimSecs;
        referralFloorTimePercentage = _referralFloorTimePercentage;

        emit logUpdatedTimeParams(_moonRaffleLiveSecs, _winnerCalcSecs, _claimSecs, _referralFloorTimePercentage);
    }

    function updatePublicMessage(string _newPublicMessage) onlyAddressOne public {
        publicMessage = _newPublicMessage;
        emit logChangedPublicMessage(_newPublicMessage);
    }

    // CHANGE ADMIN ADDRESSES
    function updateAddressOne(address _newAddressOne) onlyAddressOne public {
        addressOne = _newAddressOne;
        emit logChangedAddressOne(_newAddressOne);
    }

    function addToCurrentMoonRaffle(uint256 _amountAdded) onlyAddressOne external {
        require(now < latestMoonRaffleCompleteTime);
        require(address(this).balance >= _amountAdded);
        emit logAddedToCurrentMoonRaffle(_amountAdded);
        currentMoonRaffleAddress.transfer(_amountAdded);
    }

    function updateMoonRaffleFactoryAddress(address _newMoonRaffleFactoryAddress) onlyAddressOne external {
        moonRaffleFactoryAddress = _newMoonRaffleFactoryAddress;
        emit logNewMoonRaffleFactorySet(_newMoonRaffleFactoryAddress);
    }

    function donate() external payable {
        require(msg.value > 0);
        emit logDonation(msg.sender, msg.value);
    }

    function getNextMoonRaffleParameters() external view returns (
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256,
        uint256
    ) {
        return (
            pricePerTicket,
            maxTicketsPerTransaction,
            prizePoolPercentage,
            firstPrizePercentage,
            secondPrizePercentage,
            thirdPrizePercentage,
            contractFeePercentage,
            rolloverPercentage,
            referralPercentage,
            referralHurdle,
            referralFloorTimePercentage,
            moonRaffleLiveSecs,
            winnerCalcSecs,
            claimSecs
        );
    }

    function getCurrentMoonRaffleAddress() external view returns (address) {
        return currentMoonRaffleAddress;
    }

    function getMoonRaffleCounter() external view returns (uint256) {
        return moonRaffleCounter;
    }

    function getLastMoonRaffleAddress() external view returns (address) {
        return oldMoonRaffleAddresses[(oldMoonRaffleAddresses.length - 1)];
    }

    function getAllPreviousMoonRaffleAddresses() external view returns (address[]) {
        return oldMoonRaffleAddresses;
    }

    function getMainAddresses() external view returns (address, address) {
        return (addressOne, moonRaffleFactoryAddress);
    }

    function getLatestMoonRaffleCompleteTime() external view returns (uint256) {
        return latestMoonRaffleCompleteTime;
    }

    function getPublicMessage() external view returns (string) {
        return publicMessage;
    }

    function checkAddressForWins() external view returns (address[]) {
        return winners[msg.sender];
    }

    function getContractBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getMainStatus() external view returns (string) {
        if (latestMoonRaffleCompleteTime == 0) {return "ready for new moonraffle";}
        if (now < latestMoonRaffleCompleteTime) {return "current moonraffle still in progress";}
        return "current moonraffle past complete time. check if it is complete and loggable";
    }

}