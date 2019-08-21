pragma solidity ^0.4.19;

/**
 * @dev Pre-ico contract interface
 */
contract PreIcoContract {
    function buyTokens (address _investor) public payable;
    uint256 public startTime;
    uint256 public endTime;
}

/**
 * @title Reservation contract
 * @notice Forword ether to pre-ico address
 */
contract ReservationContract {

    // Keep track of who invested
    mapping(address => bool) public invested;
    // Minimum investment for reservation contract
    uint public MIN_INVESTMENT = 1 ether;
    // address of the pre-ico
    PreIcoContract public preIcoAddr;
    // start and end time of the pre-ico
    uint public preIcoStart;
    uint public preIcoEnd;

    /**
     * @dev Constructor
     * @notice Initialize reservation contract
     * @param _preIcoAddr Pre ico address 
     */
    function ReservationContract(address _preIcoAddr) public {
        require(_preIcoAddr != 0x0);
        require(isContract(_preIcoAddr) == true);

        // load pre-ico contract instance
        preIcoAddr = PreIcoContract(_preIcoAddr);

        // get and set start and end time
        preIcoStart = preIcoAddr.startTime();
        preIcoEnd = preIcoAddr.endTime();
        require(preIcoStart != 0 && preIcoEnd != 0 && now <= preIcoEnd);
    }

    /**
     * @dev Fallback function
     * @notice This function will record your investment in
     * this reservation contract and forward eths to the pre-ico,
     * please note, you need to invest at least MIN_INVESTMENT and
     * you must invest directly from your address, contracts are not
     * allowed
     */
    function() public payable {
        require(msg.value >= MIN_INVESTMENT);
        require(now >= preIcoStart && now <= preIcoEnd);
        // check if it's a contract
        require(isContract(msg.sender) == false);

        // update records (used for reference only)
        if (invested[msg.sender] == false) {
            invested[msg.sender] = true;
        }

        // buy tokens
        preIcoAddr.buyTokens.value(msg.value)(msg.sender);
    }

    /**
    * @dev Check if an address is a contract
    * @param addr Address to check
    * @return True if is a contract
    */
    function isContract(address addr) public constant returns (bool) {
        uint size;
        assembly { size := extcodesize(addr) }
        return size > 0;
    }
}