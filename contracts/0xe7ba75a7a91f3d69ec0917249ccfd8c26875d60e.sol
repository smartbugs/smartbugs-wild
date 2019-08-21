pragma solidity ^0.4.18;

/*
 * Ownable
 * Base contract with an owner.
 * Provides onlyOwner modifier, which prevents function from running if it is called by anyone other than the owner.
 */
contract Ownable {
    address public owner;

    function Ownable() public {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) {
            revert();
        }
        _;
    }

    function transferOwnership(address newOwner) internal onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title TradeFeeCalculator - Returns the calculated Fee Based on the Trade Value   
 * @dev Fee Calculation contract. All the units are dealt at wei level.
 * @author Dinesh
 */
contract TradeFeeCalculator is Ownable { 
    using SafeMath for uint256; 
    
    // array to store optional fee by category: 0 - Base Token Fee, 1 - Ether Fee, 2 - External token Fee
    // its numbers and its for every 1 token/1 Ether (should be only wei values)
    uint256[3] public exFees;
    
    /**
     * @dev constructor sets up owner
     */
    function TradeFeeCalculator() public {
        // set up the owner
        owner = msg.sender; 
    }
    
    /**
     * @dev function updates the fees charged by the exchange. Fees will be mentioned per Ether (3792 Wand) 
     * @param _baseTokenFee is for the trades who pays fees in Native Tokens
     */
    function updateFeeSchedule(uint256 _baseTokenFee, uint256 _etherFee, uint256 _normalTokenFee) public onlyOwner {
        // Base token fee should not exceed 1 ether worth of tokens (ex: 3792 wand = 1 ether), since 1 ether is our fee unit
        require(_baseTokenFee >= 0 && _baseTokenFee <=  1 * 1 ether);
        
        // If the incoming trade is on Ether, then fee should not exceed 1 Ether
        require(_etherFee >= 0 && _etherFee <=  1 * 1 ether);
       
        // If the incoming trade is on diffrent coins and if the exchange should allow diff tokens as fee, then 
        // input must be in wei converted value to suppport decimal - Special Case 
        /** Caution: Max value check must be done by Owner who is updating this value */
        require(_normalTokenFee >= 0);
        require(exFees.length == 3);
        
        // Stores the fee structure
        exFees[0] = _baseTokenFee;  
        exFees[1] = _etherFee; 
        exFees[2] = _normalTokenFee; 
    }
    
    /**
     * @dev function to calculate transaction fees for given value and token
     * @param _value is the given trade overall value
     * @param _feeIndex indicates token pay options
     * @return calculated trade fee
     * Caution: _value is expected to be in wei units and it works for single token payment
     */
    function calcTradeFee(uint256 _value, uint256 _feeIndex) public view returns (uint256) {
        require(_feeIndex >= 0 && _feeIndex <= 2);
        require(_value > 0);
        require(exFees.length == 3 && exFees[_feeIndex] > 0 );
        
        //Calculation Formula TotalFees = (_value * exFees[_feeIndex])/ (1 ether) 
        uint256 _totalFees = (_value.mul(exFees[_feeIndex])).div(1 ether);
        
        // Calculated total fee must be gretae than 0 for a given base fee > 0
        require(_totalFees > 0);
        
        return _totalFees;
    } 
    
    /**
     * @dev function to calculate transaction fees for given list of values and tokens
     * @param _values is the list of given trade overall values
     * @param _feeIndexes indicates list token pay options for each value 
     * @return list of calculated trade fees each value
     * Caution: _values is expected to be in wei units and it works for multiple token payment
     */
    function calcTradeFeeMulti(uint256[] _values, uint256[] _feeIndexes) public view returns (uint256[]) {
        require(_values.length > 0); 
        require(_feeIndexes.length > 0);  
        require(_values.length == _feeIndexes.length); 
        require(exFees.length == 3);
        
        uint256[] memory _totalFees = new uint256[](_values.length);
        // For Every token Value 
        for (uint256 i = 0; i < _values.length; i++){  
            _totalFees[i] =  calcTradeFee(_values[i], _feeIndexes[i]);
        }
        require(_totalFees.length > 0);
        require(_values.length == _totalFees.length);  
        return _totalFees;
    }
}