pragma solidity ^0.4.11;


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) {
      owner = newOwner;
    }
  }

}

contract BlockvPublicLedger is Ownable {

  struct logEntry{
        string txType;
        string txId;
        address to;
        uint256 amountContributed;
        uint8 discount;
        uint256 blockTimestamp;
  }
  struct distributionEntry{
        string txId;
        address to;
        uint256 amountContributed;    
        uint8 discount;
        uint256 tokenAmount;
  }
  struct index {
    uint256 index;
    bool set;
  }
  uint256 public txCount = 0;
  uint256 public distributionEntryCount = 0;
  mapping (string => index) distributionIndex;
  logEntry[] public transactionLog;
  distributionEntry[] public distributionList;
  bool public distributionFixed = false;


  /**
   * @dev BlockvPublicLedger Constructor
   * Runs only on initial contract creation.
   */
  function BlockvPublicLedger() {
  }

  /**
   * @dev update/create a record in the Distribution List
   * @param _tx_id A unique id for the transaction, could be the BTC or ETH tx_id
   * @param _to The address to transfer to.
   * @param _amount The amount contributed in ETH grains.
   * @param _discount The discount value in percent; 100 meaning no discount, 80 meaning 20% discount.
   */
  function appendToDistributionList(string _tx_id, address _to, uint256 _amount, uint8 _discount)  onlyOwner returns (bool) {
        index memory idx = distributionIndex[_tx_id];
        bool ret;
        logEntry memory le;
        distributionEntry memory de;

        if(distributionFixed) {  
          revert();
        }

        if ( _discount > 100 ) {
          revert();
        }
        /* build the log record and add it to the transaction log first */
        if ( !idx.set ) {
            ret = false;
            le.txType = "INSERT";
        } else {
            ret = true;
            le.txType = "UPDATE";          
        }
        le.to = _to;
        le.amountContributed = _amount;
        le.blockTimestamp = block.timestamp;
        le.txId = _tx_id;
        le.discount = _discount;
        transactionLog.push(le);
        txCount++;

        /* now append or update the distributionList */
        de.txId = _tx_id;
        de.to = _to;
        de.amountContributed = _amount;
        de.discount = _discount;
        de.tokenAmount = 0;
        if (!idx.set) {
          idx.index = distributionEntryCount;
          idx.set = true;
          distributionIndex[_tx_id] = idx;
          distributionList.push(de);
          distributionEntryCount++;
        } else {
          distributionList[idx.index] = de;
        }
        return ret;
  }


  /**
  * @dev finalize the distributionList after token price is set and ETH conversion is known
  * @param _tokenPrice the price of a VEE in USD-cents
  * @param _usdToEthConversionRate in grains
  */
  function fixDistribution(uint8 _tokenPrice, uint256 _usdToEthConversionRate) onlyOwner {

    distributionEntry memory de;
    logEntry memory le;
    uint256 i = 0;

    if(distributionFixed) {  
      revert();
    }

    for(i = 0; i < distributionEntryCount; i++) {
      de = distributionList[i];
      de.tokenAmount = (de.amountContributed * _usdToEthConversionRate * 100) / (_tokenPrice  * de.discount / 100);
      distributionList[i] = de;
    }
    distributionFixed = true;
  
    le.txType = "FIXED";
    le.blockTimestamp = block.timestamp;
    le.txId = "__FIXED__DISTRIBUTION__";
    transactionLog.push(le);
    txCount++;

  }

}