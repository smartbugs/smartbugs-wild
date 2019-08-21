pragma solidity ^0.4.17;

// ----------------------------------------------------------------------------
// Future Token Sale Lock Box
//
// Copyright (c) 2017 OpenST Ltd.
// https://simpletoken.org/
//
// The MIT Licence.
// ----------------------------------------------------------------------------

// ----------------------------------------------------------------------------
// SafeMath Library Implementation
//
// Copyright (c) 2017 OpenST Ltd.
// https://simpletoken.org/
//
// The MIT Licence.
//
// Based on the SafeMath library by the OpenZeppelin team.
// Copyright (c) 2016 Smart Contract Solutions, Inc.
// https://github.com/OpenZeppelin/zeppelin-solidity
// The MIT License.
// ----------------------------------------------------------------------------


library SafeMath {

    function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a * b;

        assert(a == 0 || c / a == b);

        return c;
    }


    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        // Solidity automatically throws when dividing by 0
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

//
// Implements basic ownership with 2-step transfers.
//
contract Owned {

    address public owner;
    address public proposedOwner;

    event OwnershipTransferInitiated(address indexed _proposedOwner);
    event OwnershipTransferCompleted(address indexed _newOwner);


    function Owned() public {
        owner = msg.sender;
    }


    modifier onlyOwner() {
        require(isOwner(msg.sender));
        _;
    }


    function isOwner(address _address) internal view returns (bool) {
        return (_address == owner);
    }


    function initiateOwnershipTransfer(address _proposedOwner) public onlyOwner returns (bool) {
        proposedOwner = _proposedOwner;

        OwnershipTransferInitiated(_proposedOwner);

        return true;
    }


    function completeOwnershipTransfer() public returns (bool) {
        require(msg.sender == proposedOwner);

        owner = proposedOwner;
        proposedOwner = address(0);

        OwnershipTransferCompleted(owner);

        return true;
    }
}

contract ERC20Interface {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function name() public view returns (string);
    function symbol() public view returns (string);
    function decimals() public view returns (uint8);
    function totalSupply() public view returns (uint256);

    function balanceOf(address _owner) public view returns (uint256 balance);
    function allowance(address _owner, address _spender) public view returns (uint256 remaining);

    function transfer(address _to, uint256 _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);
    function approve(address _spender, uint256 _value) public returns (bool success);
}

/**
   @title TokenSaleInterface
   @dev Provides interface for calling TokenSale.endTime
*/
contract TokenSaleInterface {
    function endTime() public view returns (uint256);
}

/**
   @title FutureTokenSaleLockBox
   @notice Holds tokens reserved for future token sales. Tokens cannot be transferred for at least six months.
*/
contract FutureTokenSaleLockBox is Owned {
    using SafeMath for uint256;

    // To enable transfers of tokens held by this contract
    ERC20Interface public simpleToken;

    // To determine earliest unlock date after which tokens held by this contract can be transferred
    TokenSaleInterface public tokenSale;

    // The unlock date is initially 26 weeks after tokenSale.endTime, but may be extended
    uint256 public unlockDate;

    event UnlockDateExtended(uint256 _newDate);
    event TokensTransferred(address indexed _to, uint256 _value);

    /**
       @dev Constructor
       @param _simpleToken SimpleToken contract
       @param _tokenSale TokenSale contract
    */
    function FutureTokenSaleLockBox(ERC20Interface _simpleToken, TokenSaleInterface _tokenSale)
             Owned()
             public
    {
        require(address(_simpleToken) != address(0));
        require(address(_tokenSale)   != address(0));

        simpleToken = _simpleToken;
        tokenSale   = _tokenSale;
        uint256 endTime = tokenSale.endTime();

        require(endTime > 0);

        unlockDate  = endTime.add(26 weeks);
    }

    /**
       @dev Limits execution to after unlock date
    */
    modifier onlyAfterUnlockDate() {
        require(hasUnlockDatePassed());
        _;
    }

    /**
       @dev Provides current time
    */
    function currentTime() public view returns (uint256) {
        return now;
    }

    /**
       @dev Determines whether unlock date has passed
    */
    function hasUnlockDatePassed() public view returns (bool) {
        return currentTime() >= unlockDate;
    }

    /**
       @dev Extends unlock date
       @param _newDate new unlock date
    */
    function extendUnlockDate(uint256 _newDate) public onlyOwner returns (bool) {
        require(_newDate > unlockDate);

        unlockDate = _newDate;
        UnlockDateExtended(_newDate);

        return true;
    }

    /**
       @dev Transfers tokens held by this contract
       @param _to account to which to transfer tokens
       @param _value value of tokens to transfer
    */
    function transfer(address _to, uint256 _value) public onlyOwner onlyAfterUnlockDate returns (bool) {
        require(simpleToken.transfer(_to, _value));

        TokensTransferred(_to, _value);

        return true;
    }
}