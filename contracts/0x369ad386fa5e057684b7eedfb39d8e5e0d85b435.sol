pragma solidity 0.4.25;
pragma experimental ABIEncoderV2;

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  constructor() public {
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
   * @dev Allows the current owner to relinquish control of the contract.
   * @notice Renouncing to ownership will leave the contract without an owner.
   * It will not be possible to call the functions with the `onlyOwner`
   * modifier anymore.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev Transfers control of the contract to a newOwner.
   * @param _newOwner The address to transfer ownership to.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

library ERC20SafeTransfer {
    function safeTransfer(address _tokenAddress, address _to, uint256 _value) internal returns (bool success) {

        require(_tokenAddress.call(bytes4(keccak256("transfer(address,uint256)")), _to, _value));

        return fetchReturnData();
    }

    function safeTransferFrom(address _tokenAddress, address _from, address _to, uint256 _value) internal returns (bool success) {

        require(_tokenAddress.call(bytes4(keccak256("transferFrom(address,address,uint256)")), _from, _to, _value));

        return fetchReturnData();
    }

    function safeApprove(address _tokenAddress, address _spender, uint256 _value) internal returns (bool success) {

        require(_tokenAddress.call(bytes4(keccak256("approve(address,uint256)")), _spender, _value));

        return fetchReturnData();
    }

    function fetchReturnData() internal returns (bool success){
        assembly {
            switch returndatasize()
            case 0 {
                success := 1
            }
            case 32 {
                returndatacopy(0, 0, 32)
                success := mload(0)
            }
            default {
                revert(0, 0)
            }
        }
    }

}

/// @title A contract which allows its owner to withdraw any ether which is contained inside
contract Withdrawable is Ownable {

    /// @notice Withdraw ether contained in this contract and send it back to owner
    /// @dev onlyOwner modifier only allows the contract owner to run the code
    /// @param _token The address of the token that the user wants to withdraw
    /// @param _amount The amount of tokens that the caller wants to withdraw
    /// @return bool value indicating whether the transfer was successful
    function withdrawToken(address _token, uint256 _amount) external onlyOwner returns (bool) {
        return ERC20SafeTransfer.safeTransfer(_token, owner, _amount);
    }

    /// @notice Withdraw ether contained in this contract and send it back to owner
    /// @dev onlyOwner modifier only allows the contract owner to run the code
    /// @param _amount The amount of ether that the caller wants to withdraw
    function withdrawETH(uint256 _amount) external onlyOwner {
        owner.transfer(_amount);
    }
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 {
  function totalSupply() public view returns (uint256);

  function balanceOf(address _who) public view returns (uint256);

  function allowance(address _owner, address _spender)
    public view returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  function approve(address _spender, uint256 _value)
    public returns (bool);

  function transferFrom(address _from, address _to, uint256 _value)
    public returns (bool);

  function decimals() public view returns (uint256);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

/*
  Copyright 2018 ZeroEx Intl.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/





/// @title TokenTransferProxy - Transfers tokens on behalf of contracts that have been approved via decentralized governance.
/// @author Amir Bandeali - <amir@0xProject.com>, Will Warren - <will@0xProject.com>
contract TokenTransferProxy is Ownable {

    /// @dev Only authorized addresses can invoke functions with this modifier.
    modifier onlyAuthorized {
        require(authorized[msg.sender]);
        _;
    }

    modifier targetAuthorized(address target) {
        require(authorized[target]);
        _;
    }

    modifier targetNotAuthorized(address target) {
        require(!authorized[target]);
        _;
    }

    mapping (address => bool) public authorized;
    address[] public authorities;

    event LogAuthorizedAddressAdded(address indexed target, address indexed caller);
    event LogAuthorizedAddressRemoved(address indexed target, address indexed caller);

    /*
     * Public functions
     */

    /// @dev Authorizes an address.
    /// @param target Address to authorize.
    function addAuthorizedAddress(address target)
        public
        onlyOwner
        targetNotAuthorized(target)
    {
        authorized[target] = true;
        authorities.push(target);
        emit LogAuthorizedAddressAdded(target, msg.sender);
    }

    /// @dev Removes authorizion of an address.
    /// @param target Address to remove authorization from.
    function removeAuthorizedAddress(address target)
        public
        onlyOwner
        targetAuthorized(target)
    {
        delete authorized[target];
        for (uint i = 0; i < authorities.length; i++) {
            if (authorities[i] == target) {
                authorities[i] = authorities[authorities.length - 1];
                authorities.length -= 1;
                break;
            }
        }
        emit LogAuthorizedAddressRemoved(target, msg.sender);
    }

    /// @dev Calls into ERC20 Token contract, invoking transferFrom.
    /// @param token Address of token to transfer.
    /// @param from Address to transfer token from.
    /// @param to Address to transfer token to.
    /// @param value Amount of token to transfer.
    /// @return Success of transfer.
    function transferFrom(
        address token,
        address from,
        address to,
        uint value)
        public
        onlyAuthorized
        returns (bool)
    {
        require(ERC20SafeTransfer.safeTransferFrom(token, from, to, value));
        return true;
    }

    /*
     * Public constant functions
     */

    /// @dev Gets all authorized addresses.
    /// @return Array of authorized addresses.
    function getAuthorizedAddresses()
        public
        view
        returns (address[])
    {
        return authorities;
    }
}



/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Paused();
  event Unpaused();

  bool private _paused = false;

  /**
   * @return true if the contract is paused, false otherwise.
   */
  function paused() public view returns (bool) {
    return _paused;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!_paused, "Contract is paused.");
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(_paused, "Contract not paused.");
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() public onlyOwner whenNotPaused {
    _paused = true;
    emit Paused();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() public onlyOwner whenPaused {
    _paused = false;
    emit Unpaused();
  }
}



/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 _a, uint256 _b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (_a == 0) {
      return 0;
    }

    uint256 c = _a * _b;
    require(c / _a == _b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = _a / _b;
    // assert(_a == _b * c + _a % _b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 _a, uint256 _b) internal pure returns (uint256) {
    require(_b <= _a);
    uint256 c = _a - _b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 _a, uint256 _b) internal pure returns (uint256) {
    uint256 c = _a + _b;
    require(c >= _a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}



/*
    Modified Util contract as used by Kyber Network
*/

library Utils {

    uint256 constant internal PRECISION = (10**18);
    uint256 constant internal MAX_QTY   = (10**28); // 10B tokens
    uint256 constant internal MAX_RATE  = (PRECISION * 10**6); // up to 1M tokens per ETH
    uint256 constant internal MAX_DECIMALS = 18;
    uint256 constant internal ETH_DECIMALS = 18;
    uint256 constant internal MAX_UINT = 2**256-1;

    // Currently constants can't be accessed from other contracts, so providing functions to do that here
    function precision() internal pure returns (uint256) { return PRECISION; }
    function max_qty() internal pure returns (uint256) { return MAX_QTY; }
    function max_rate() internal pure returns (uint256) { return MAX_RATE; }
    function max_decimals() internal pure returns (uint256) { return MAX_DECIMALS; }
    function eth_decimals() internal pure returns (uint256) { return ETH_DECIMALS; }
    function max_uint() internal pure returns (uint256) { return MAX_UINT; }

    /// @notice Retrieve the number of decimals used for a given ERC20 token
    /// @dev As decimals are an optional feature in ERC20, this contract uses `call` to
    /// ensure that an exception doesn't cause transaction failure
    /// @param token the token for which we should retrieve the decimals
    /// @return decimals the number of decimals in the given token
    function getDecimals(address token)
        internal
        view
        returns (uint256 decimals)
    {
        bytes4 functionSig = bytes4(keccak256("decimals()"));

        /// @dev Using assembly due to issues with current solidity `address.call()`
        /// implementation: https://github.com/ethereum/solidity/issues/2884
        assembly {
            // Pointer to next free memory slot
            let ptr := mload(0x40)
            // Store functionSig variable at ptr
            mstore(ptr,functionSig)
            let functionSigLength := 0x04
            let wordLength := 0x20

            let success := call(
                                5000, // Amount of gas
                                token, // Address to call
                                0, // ether to send
                                ptr, // ptr to input data
                                functionSigLength, // size of data
                                ptr, // where to store output data (overwrite input)
                                wordLength // size of output data (32 bytes)
                               )

            switch success
            case 0 {
                decimals := 0 // If the token doesn't implement `decimals()`, return 0 as default
            }
            case 1 {
                decimals := mload(ptr) // Set decimals to return data from call
            }
            mstore(0x40,add(ptr,0x04)) // Reset the free memory pointer to the next known free location
        }
    }

    /// @dev Checks that a given address has its token allowance and balance set above the given amount
    /// @param tokenOwner the address which should have custody of the token
    /// @param tokenAddress the address of the token to check
    /// @param tokenAmount the amount of the token which should be set
    /// @param addressToAllow the address which should be allowed to transfer the token
    /// @return bool true if the allowance and balance is set, false if not
    function tokenAllowanceAndBalanceSet(
        address tokenOwner,
        address tokenAddress,
        uint256 tokenAmount,
        address addressToAllow
    )
        internal
        view
        returns (bool)
    {
        return (
            ERC20(tokenAddress).allowance(tokenOwner, addressToAllow) >= tokenAmount &&
            ERC20(tokenAddress).balanceOf(tokenOwner) >= tokenAmount
        );
    }

    function calcDstQty(uint srcQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns (uint) {
        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return (srcQty * rate * (10**(dstDecimals - srcDecimals))) / PRECISION;
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return (srcQty * rate) / (PRECISION * (10**(srcDecimals - dstDecimals)));
        }
    }

    function calcSrcQty(uint dstQty, uint srcDecimals, uint dstDecimals, uint rate) internal pure returns (uint) {

        //source quantity is rounded up. to avoid dest quantity being too low.
        uint numerator;
        uint denominator;
        if (srcDecimals >= dstDecimals) {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            numerator = (PRECISION * dstQty * (10**(srcDecimals - dstDecimals)));
            denominator = rate;
        } else {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            numerator = (PRECISION * dstQty);
            denominator = (rate * (10**(dstDecimals - srcDecimals)));
        }
        return (numerator + denominator - 1) / denominator; //avoid rounding down errors
    }

    function calcDestAmount(ERC20 src, ERC20 dest, uint srcAmount, uint rate) internal view returns (uint) {
        return calcDstQty(srcAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcSrcAmount(ERC20 src, ERC20 dest, uint destAmount, uint rate) internal view returns (uint) {
        return calcSrcQty(destAmount, getDecimals(src), getDecimals(dest), rate);
    }

    function calcRateFromQty(uint srcAmount, uint destAmount, uint srcDecimals, uint dstDecimals)
        internal pure returns (uint)
    {
        require(srcAmount <= MAX_QTY);
        require(destAmount <= MAX_QTY);

        if (dstDecimals >= srcDecimals) {
            require((dstDecimals - srcDecimals) <= MAX_DECIMALS);
            return (destAmount * PRECISION / ((10 ** (dstDecimals - srcDecimals)) * srcAmount));
        } else {
            require((srcDecimals - dstDecimals) <= MAX_DECIMALS);
            return (destAmount * PRECISION * (10 ** (srcDecimals - dstDecimals)) / srcAmount);
        }
    }

    /// @notice Bringing this in from the Math library as we've run out of space in TotlePrimary (see EIP-170)
    function min(uint256 a, uint256 b) internal pure returns (uint256) {
        return a < b ? a : b;
    }
}


contract ErrorReporter {
    function revertTx(string reason) public pure {
        revert(reason);
    }
}



contract Affiliate{

  address public affiliateBeneficiary;
  uint256 public affiliatePercentage; //This is out of 1 ETH, e.g. 0.5 ETH is 50% of the fee

  uint256 public companyPercentage;
  address public companyBeneficiary;

  function init(address _companyBeneficiary, uint256 _companyPercentage, address _affiliateBeneficiary, uint256 _affiliatePercentage) public {
      require(companyBeneficiary == 0x0 && affiliateBeneficiary == 0x0);
      companyBeneficiary = _companyBeneficiary;
      companyPercentage = _companyPercentage;
      affiliateBeneficiary = _affiliateBeneficiary;
      affiliatePercentage = _affiliatePercentage;
  }

  function payout() public {
      // Payout both the affiliate and the company at the same time
      affiliateBeneficiary.transfer(SafeMath.div(SafeMath.mul(address(this).balance, affiliatePercentage), getTotalFeePercentage()));
      companyBeneficiary.transfer(address(this).balance);
  }

  function() public payable {

  }

  function getTotalFeePercentage() public view returns (uint256){
      return affiliatePercentage + companyPercentage;
  }
}




contract AffiliateRegistry is Ownable {

  address target;
  mapping(address => bool) affiliateContracts;
  address public companyBeneficiary;
  uint256 public companyPercentage;

  event AffiliateRegistered(address affiliateContract);


  constructor(address _target, address _companyBeneficiary, uint256 _companyPercentage) public {
     target = _target;
     companyBeneficiary = _companyBeneficiary;
     companyPercentage = _companyPercentage;
  }

  function registerAffiliate(address affiliateBeneficiary, uint256 affiliatePercentage) external {
      Affiliate newAffiliate = Affiliate(createClone());
      newAffiliate.init(companyBeneficiary, companyPercentage, affiliateBeneficiary, affiliatePercentage);
      affiliateContracts[address(newAffiliate)] = true;
      emit AffiliateRegistered(address(newAffiliate));
  }

  function overrideRegisterAffiliate(address _companyBeneficiary, uint256 _companyPercentage, address affiliateBeneficiary, uint256 affiliatePercentage) external onlyOwner {
      Affiliate newAffiliate = Affiliate(createClone());
      newAffiliate.init(_companyBeneficiary, _companyPercentage, affiliateBeneficiary, affiliatePercentage);
      affiliateContracts[address(newAffiliate)] = true;
      emit AffiliateRegistered(address(newAffiliate));
  }

  function deleteAffiliate(address _affiliateAddress) public onlyOwner {
      affiliateContracts[_affiliateAddress] = false;
  }

  function createClone() internal returns (address result) {
      bytes20 targetBytes = bytes20(target);
      assembly {
          let clone := mload(0x40)
          mstore(clone, 0x3d602d80600a3d3981f3363d3d373d3d3d363d73000000000000000000000000)
          mstore(add(clone, 0x14), targetBytes)
          mstore(add(clone, 0x28), 0x5af43d82803e903d91602b57fd5bf30000000000000000000000000000000000)
          result := create(0, clone, 0x37)
      }
  }

  function isValidAffiliate(address affiliateContract) public view returns(bool) {
      return affiliateContracts[affiliateContract];
  }

  function updateCompanyInfo(address newCompanyBeneficiary, uint256 newCompanyPercentage) public onlyOwner {
      companyBeneficiary = newCompanyBeneficiary;
      companyPercentage = newCompanyPercentage;
  }
}



/// @title A contract which can be used to ensure only the TotlePrimary contract can call
/// some functions
/// @dev Defines a modifier which should be used when only the totle contract should
/// able able to call a function
contract TotleControl is Ownable {
    mapping(address => bool) public authorizedPrimaries;

    /// @dev A modifier which only allows code execution if msg.sender equals totlePrimary address
    modifier onlyTotle() {
        require(authorizedPrimaries[msg.sender]);
        _;
    }

    /// @notice Contract constructor
    /// @dev As this contract inherits ownable, msg.sender will become the contract owner
    /// @param _totlePrimary the address of the contract to be set as totlePrimary
    constructor(address _totlePrimary) public {
        authorizedPrimaries[_totlePrimary] = true;
    }

    /// @notice A function which allows only the owner to change the address of totlePrimary
    /// @dev onlyOwner modifier only allows the contract owner to run the code
    /// @param _totlePrimary the address of the contract to be set as totlePrimary
    function addTotle(
        address _totlePrimary
    ) external onlyOwner {
        authorizedPrimaries[_totlePrimary] = true;
    }

    function removeTotle(
        address _totlePrimary
    ) external onlyOwner {
        authorizedPrimaries[_totlePrimary] = false;
    }
}

contract SelectorProvider {
    bytes4 constant getAmountToGiveSelector = bytes4(keccak256("getAmountToGive(bytes)"));
    bytes4 constant staticExchangeChecksSelector = bytes4(keccak256("staticExchangeChecks(bytes)"));
    bytes4 constant performBuyOrderSelector = bytes4(keccak256("performBuyOrder(bytes,uint256)"));
    bytes4 constant performSellOrderSelector = bytes4(keccak256("performSellOrder(bytes,uint256)"));

    function getSelector(bytes4 genericSelector) public pure returns (bytes4);
}

/// @title Interface for all exchange handler contracts
contract ExchangeHandler is SelectorProvider, TotleControl, Withdrawable, Pausable {

    /*
    *   State Variables
    */

    ErrorReporter public errorReporter;
    /* Logger public logger; */
    /*
    *   Modifiers
    */

    /// @notice Constructor
    /// @dev Calls the constructor of the inherited TotleControl
    /// @param totlePrimary the address of the totlePrimary contract
    constructor(
        address totlePrimary,
        address _errorReporter
        /* ,address _logger */
    )
        TotleControl(totlePrimary)
        public
    {
        require(_errorReporter != address(0x0));
        /* require(_logger != address(0x0)); */
        errorReporter = ErrorReporter(_errorReporter);
        /* logger = Logger(_logger); */
    }

    /// @notice Gets the amount that Totle needs to give for this order
    /// @param genericPayload the data for this order in a generic format
    /// @return amountToGive amount taker needs to give in order to fill the order
    function getAmountToGive(
        bytes genericPayload
    )
        public
        view
        returns (uint256 amountToGive)
    {
        bool success;
        bytes4 functionSelector = getSelector(this.getAmountToGive.selector);

        assembly {
            let functionSelectorLength := 0x04
            let functionSelectorOffset := 0x1C
            let scratchSpace := 0x0
            let wordLength := 0x20
            let bytesLength := mload(genericPayload)
            let totalLength := add(functionSelectorLength, bytesLength)
            let startOfNewData := add(genericPayload, functionSelectorOffset)

            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)
            let functionSelectorCorrect := mload(scratchSpace)
            mstore(genericPayload, functionSelectorCorrect)

            success := delegatecall(
                            gas,
                            address, // This address of the current contract
                            startOfNewData, // Start data at the beginning of the functionSelector
                            totalLength, // Total length of all data, including functionSelector
                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.
                            wordLength // Length of return variable is one word
                           )
            amountToGive := mload(scratchSpace)
            if eq(success, 0) { revert(0, 0) }
        }
    }

    /// @notice Perform exchange-specific checks on the given order
    /// @dev this should be called to check for payload errors
    /// @param genericPayload the data for this order in a generic format
    /// @return checksPassed value representing pass or fail
    function staticExchangeChecks(
        bytes genericPayload
    )
        public
        view
        returns (bool checksPassed)
    {
        bool success;
        bytes4 functionSelector = getSelector(this.staticExchangeChecks.selector);
        assembly {
            let functionSelectorLength := 0x04
            let functionSelectorOffset := 0x1C
            let scratchSpace := 0x0
            let wordLength := 0x20
            let bytesLength := mload(genericPayload)
            let totalLength := add(functionSelectorLength, bytesLength)
            let startOfNewData := add(genericPayload, functionSelectorOffset)

            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)
            let functionSelectorCorrect := mload(scratchSpace)
            mstore(genericPayload, functionSelectorCorrect)

            success := delegatecall(
                            gas,
                            address, // This address of the current contract
                            startOfNewData, // Start data at the beginning of the functionSelector
                            totalLength, // Total length of all data, including functionSelector
                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.
                            wordLength // Length of return variable is one word
                           )
            checksPassed := mload(scratchSpace)
            if eq(success, 0) { revert(0, 0) }
        }
    }

    /// @notice Perform a buy order at the exchange
    /// @param genericPayload the data for this order in a generic format
    /// @param  amountToGiveForOrder amount that should be spent on this order
    /// @return amountSpentOnOrder the amount that would be spent on the order
    /// @return amountReceivedFromOrder the amount that was received from this order
    function performBuyOrder(
        bytes genericPayload,
        uint256 amountToGiveForOrder
    )
        public
        payable
        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)
    {
        bool success;
        bytes4 functionSelector = getSelector(this.performBuyOrder.selector);
        assembly {
            let callDataOffset := 0x44
            let functionSelectorOffset := 0x1C
            let functionSelectorLength := 0x04
            let scratchSpace := 0x0
            let wordLength := 0x20
            let startOfFreeMemory := mload(0x40)

            calldatacopy(startOfFreeMemory, callDataOffset, calldatasize)

            let bytesLength := mload(startOfFreeMemory)
            let totalLength := add(add(functionSelectorLength, bytesLength), wordLength)

            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)

            let functionSelectorCorrect := mload(scratchSpace)

            mstore(startOfFreeMemory, functionSelectorCorrect)

            mstore(add(startOfFreeMemory, add(wordLength, bytesLength)), amountToGiveForOrder)

            let startOfNewData := add(startOfFreeMemory,functionSelectorOffset)

            success := delegatecall(
                            gas,
                            address, // This address of the current contract
                            startOfNewData, // Start data at the beginning of the functionSelector
                            totalLength, // Total length of all data, including functionSelector
                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.
                            mul(wordLength, 0x02) // Length of return variables is two words
                          )
            amountSpentOnOrder := mload(scratchSpace)
            amountReceivedFromOrder := mload(add(scratchSpace, wordLength))
            if eq(success, 0) { revert(0, 0) }
        }
    }

    /// @notice Perform a sell order at the exchange
    /// @param genericPayload the data for this order in a generic format
    /// @param  amountToGiveForOrder amount that should be spent on this order
    /// @return amountSpentOnOrder the amount that would be spent on the order
    /// @return amountReceivedFromOrder the amount that was received from this order
    function performSellOrder(
        bytes genericPayload,
        uint256 amountToGiveForOrder
    )
        public
        returns (uint256 amountSpentOnOrder, uint256 amountReceivedFromOrder)
    {
        bool success;
        bytes4 functionSelector = getSelector(this.performSellOrder.selector);
        assembly {
            let callDataOffset := 0x44
            let functionSelectorOffset := 0x1C
            let functionSelectorLength := 0x04
            let scratchSpace := 0x0
            let wordLength := 0x20
            let startOfFreeMemory := mload(0x40)

            calldatacopy(startOfFreeMemory, callDataOffset, calldatasize)

            let bytesLength := mload(startOfFreeMemory)
            let totalLength := add(add(functionSelectorLength, bytesLength), wordLength)

            mstore(add(scratchSpace, functionSelectorOffset), functionSelector)

            let functionSelectorCorrect := mload(scratchSpace)

            mstore(startOfFreeMemory, functionSelectorCorrect)

            mstore(add(startOfFreeMemory, add(wordLength, bytesLength)), amountToGiveForOrder)

            let startOfNewData := add(startOfFreeMemory,functionSelectorOffset)

            success := delegatecall(
                            gas,
                            address, // This address of the current contract
                            startOfNewData, // Start data at the beginning of the functionSelector
                            totalLength, // Total length of all data, including functionSelector
                            scratchSpace, // Use the first word of memory (scratch space) to store our return variable.
                            mul(wordLength, 0x02) // Length of return variables is two words
                          )
            amountSpentOnOrder := mload(scratchSpace)
            amountReceivedFromOrder := mload(add(scratchSpace, wordLength))
            if eq(success, 0) { revert(0, 0) }
        }
    }
}

/// @title The primary contract for Totle
contract TotlePrimary is Withdrawable, Pausable {

    /*
    *   State Variables
    */

    mapping(address => bool) public handlerWhitelistMap;
    address[] public handlerWhitelistArray;
    AffiliateRegistry affiliateRegistry;
    address public defaultFeeAccount;

    TokenTransferProxy public tokenTransferProxy;
    ErrorReporter public errorReporter;
    /* Logger public logger; */

    /*
    *   Types
    */

    // Structs
    struct Trade {
        bool isSell;
        address tokenAddress;
        uint256 tokenAmount;
        bool optionalTrade;
        uint256 minimumExchangeRate;
        uint256 minimumAcceptableTokenAmount;
        Order[] orders;
    }

    struct Order {
        address exchangeHandler;
        bytes genericPayload;
    }

    struct TradeFlag {
        bool ignoreTrade;
        bool[] ignoreOrder;
    }

    struct CurrentAmounts {
        uint256 amountSpentOnTrade;
        uint256 amountReceivedFromTrade;
        uint256 amountLeftToSpendOnTrade;
    }

    /*
    *   Events
    */

    event LogRebalance(
        bytes32 id
    );

    /*
    *   Modifiers
    */

    modifier handlerWhitelisted(address handler) {
        if (!handlerWhitelistMap[handler]) {
            errorReporter.revertTx("Handler not in whitelist");
        }
        _;
    }

    modifier handlerNotWhitelisted(address handler) {
        if (handlerWhitelistMap[handler]) {
            errorReporter.revertTx("Handler already whitelisted");
        }
        _;
    }

    /// @notice Constructor
    /// @param _tokenTransferProxy address of the TokenTransferProxy
    /// @param _errorReporter the address of the error reporter contract
    constructor (address _tokenTransferProxy, address _affiliateRegistry, address _errorReporter, address _defaultFeeAccount/*, address _logger*/) public {
        /* require(_logger != address(0x0)); */
        tokenTransferProxy = TokenTransferProxy(_tokenTransferProxy);
        affiliateRegistry = AffiliateRegistry(_affiliateRegistry);
        errorReporter = ErrorReporter(_errorReporter);
        defaultFeeAccount = _defaultFeeAccount;
        /* logger = Logger(_logger); */
    }

    /*
    *   Public functions
    */

    /// @notice Update the default fee account
    /// @dev onlyOwner modifier only allows the contract owner to run the code
    /// @param newDefaultFeeAccount new default fee account
    function updateDefaultFeeAccount(address newDefaultFeeAccount) public onlyOwner {
        defaultFeeAccount = newDefaultFeeAccount;
    }

    /// @notice Add an exchangeHandler address to the whitelist
    /// @dev onlyOwner modifier only allows the contract owner to run the code
    /// @param handler Address of the exchange handler which permission needs adding
    function addHandlerToWhitelist(address handler)
        public
        onlyOwner
        handlerNotWhitelisted(handler)
    {
        handlerWhitelistMap[handler] = true;
        handlerWhitelistArray.push(handler);
    }

    /// @notice Remove an exchangeHandler address from the whitelist
    /// @dev onlyOwner modifier only allows the contract owner to run the code
    /// @param handler Address of the exchange handler which permission needs removing
    function removeHandlerFromWhitelist(address handler)
        public
        onlyOwner
        handlerWhitelisted(handler)
    {
        delete handlerWhitelistMap[handler];
        for (uint i = 0; i < handlerWhitelistArray.length; i++) {
            if (handlerWhitelistArray[i] == handler) {
                handlerWhitelistArray[i] = handlerWhitelistArray[handlerWhitelistArray.length - 1];
                handlerWhitelistArray.length -= 1;
                break;
            }
        }
    }

    /// @notice Performs the requested portfolio rebalance
    /// @param trades A dynamic array of trade structs
    function performRebalance(
        Trade[] memory trades,
        address feeAccount,
        bytes32 id
    )
        public
        payable
        whenNotPaused
    {
        if(!affiliateRegistry.isValidAffiliate(feeAccount)){
            feeAccount = defaultFeeAccount;
        }
        Affiliate affiliate = Affiliate(feeAccount);
        uint256 feePercentage = affiliate.getTotalFeePercentage();

        emit LogRebalance(id);
        /* logger.log("Starting Rebalance..."); */

        TradeFlag[] memory tradeFlags = initialiseTradeFlags(trades);

        staticChecks(trades, tradeFlags);

        /* logger.log("Static checks passed."); */

        transferTokens(trades, tradeFlags);

        /* logger.log("Tokens transferred."); */

        uint256 etherBalance = msg.value;
        uint256 totalFee = 0;
        /* logger.log("Ether balance arg2: etherBalance.", etherBalance); */

        for (uint256 i; i < trades.length; i++) {
            Trade memory thisTrade = trades[i];
            TradeFlag memory thisTradeFlag = tradeFlags[i];

            CurrentAmounts memory amounts = CurrentAmounts({
                amountSpentOnTrade: 0,
                amountReceivedFromTrade: 0,
                amountLeftToSpendOnTrade: thisTrade.isSell ? thisTrade.tokenAmount : calculateMaxEtherSpend(thisTrade, etherBalance, feePercentage)
            });
            /* logger.log("Going to perform trade. arg2: amountLeftToSpendOnTrade", amounts.amountLeftToSpendOnTrade); */

            performTrade(
                thisTrade,
                thisTradeFlag,
                amounts
            );
            uint256 ethTraded;
            uint256 ethFee;
            if(thisTrade.isSell){
                ethTraded = amounts.amountReceivedFromTrade;
            } else {
                ethTraded = amounts.amountSpentOnTrade;
            }
            ethFee = calculateFee(ethTraded, feePercentage);
            totalFee = SafeMath.add(totalFee, ethFee);
            /* logger.log("Finished performing trade arg2: amountReceivedFromTrade, arg3: amountSpentOnTrade.", amounts.amountReceivedFromTrade, amounts.amountSpentOnTrade); */

            if (amounts.amountReceivedFromTrade == 0 && thisTrade.optionalTrade) {
                /* logger.log("Received 0 from trade and this is an optional trade. Skipping."); */
                continue;
            }

            /* logger.log(
                "Going to check trade acceptable amounts arg2: amountSpentOnTrade, arg2: amountReceivedFromTrade.",
                amounts.amountSpentOnTrade,
                amounts.amountReceivedFromTrade
            ); */

            if (!checkIfTradeAmountsAcceptable(thisTrade, amounts.amountSpentOnTrade, amounts.amountReceivedFromTrade)) {
                errorReporter.revertTx("Amounts spent/received in trade not acceptable");
            }

            /* logger.log("Trade passed the acceptable amounts check."); */

            if (thisTrade.isSell) {
                /* logger.log(
                    "This is a sell trade, adding ether to our balance arg2: etherBalance, arg3: amountReceivedFromTrade",
                    etherBalance,
                    amounts.amountReceivedFromTrade
                ); */
                etherBalance = SafeMath.sub(SafeMath.add(etherBalance, ethTraded), ethFee);
            } else {
                /* logger.log(
                    "This is a buy trade, deducting ether from our balance arg2: etherBalance, arg3: amountSpentOnTrade",
                    etherBalance,
                    amounts.amountSpentOnTrade
                ); */
                etherBalance = SafeMath.sub(SafeMath.sub(etherBalance, ethTraded), ethFee);
            }

            /* logger.log("Transferring tokens to the user arg:6 tokenAddress.", 0,0,0,0, thisTrade.tokenAddress); */

            transferTokensToUser(
                thisTrade.tokenAddress,
                thisTrade.isSell ? amounts.amountLeftToSpendOnTrade : amounts.amountReceivedFromTrade
            );

        }
        if(totalFee > 0){
            feeAccount.transfer(totalFee);
        }
        if(etherBalance > 0) {
            /* logger.log("Got a positive ether balance, sending to the user arg2: etherBalance.", etherBalance); */
            msg.sender.transfer(etherBalance);
        }
    }

    /// @notice Performs static checks on the rebalance payload before execution
    /// @dev This function is public so a rebalance can be checked before performing a rebalance
    /// @param trades A dynamic array of trade structs
    /// @param tradeFlags A dynamic array of flags indicating trade and order status
    function staticChecks(
        Trade[] trades,
        TradeFlag[] tradeFlags
    )
        public
        view
        whenNotPaused
    {
        bool previousBuyOccured = false;

        for (uint256 i; i < trades.length; i++) {
            Trade memory thisTrade = trades[i];
            if (thisTrade.isSell) {
                if (previousBuyOccured) {
                    errorReporter.revertTx("A buy has occured before this sell");
                }

                if (!Utils.tokenAllowanceAndBalanceSet(msg.sender, thisTrade.tokenAddress, thisTrade.tokenAmount, address(tokenTransferProxy))) {
                    if (!thisTrade.optionalTrade) {
                        errorReporter.revertTx("Taker has not sent allowance/balance on a non-optional trade");
                    }
                    /* logger.log(
                        "Attempt to sell a token without allowance or sufficient balance arg2: tokenAmount, arg6: tokenAddress . Otional trade, ignoring.",
                        thisTrade.tokenAmount,
                        0,
                        0,
                        0,
                        thisTrade.tokenAddress
                    ); */
                    tradeFlags[i].ignoreTrade = true;
                    continue;
                }
            } else {
                previousBuyOccured = true;
            }

            /* logger.log("Checking that all the handlers are whitelisted."); */
            for (uint256 j; j < thisTrade.orders.length; j++) {
                Order memory thisOrder = thisTrade.orders[j];
                if ( !handlerWhitelistMap[thisOrder.exchangeHandler] ) {
                    /* logger.log(
                        "Trying to use a handler that is not whitelisted arg6: exchangeHandler.",
                        0,
                        0,
                        0,
                        0,
                        thisOrder.exchangeHandler
                    ); */
                    tradeFlags[i].ignoreOrder[j] = true;
                    continue;
                }
            }
        }
    }

    /*
    *   Internal functions
    */

    /// @notice Initialises the trade flag struct
    /// @param trades the trades used to initialise the flags
    /// @return tradeFlags the initialised flags
    function initialiseTradeFlags(Trade[] trades)
        internal
        returns (TradeFlag[])
    {
        /* logger.log("Initializing trade flags."); */
        TradeFlag[] memory tradeFlags = new TradeFlag[](trades.length);
        for (uint256 i = 0; i < trades.length; i++) {
            tradeFlags[i].ignoreOrder = new bool[](trades[i].orders.length);
        }
        return tradeFlags;
    }

    /// @notice Transfers the given amount of tokens back to the msg.sender
    /// @param tokenAddress the address of the token to transfer
    /// @param tokenAmount the amount of tokens to transfer
    function transferTokensToUser(
        address tokenAddress,
        uint256 tokenAmount
    )
        internal
    {
        /* logger.log("Transfering tokens to the user arg2: tokenAmount, arg6: .tokenAddress", tokenAmount, 0, 0, 0, tokenAddress); */
        if (tokenAmount > 0) {
            if (!ERC20SafeTransfer.safeTransfer(tokenAddress, msg.sender, tokenAmount)) {
                errorReporter.revertTx("Unable to transfer tokens to user");
            }
        }
    }

    /// @notice Executes the given trade
    /// @param trade a struct containing information about the trade
    /// @param tradeFlag a struct containing trade status information
    /// @param amounts a struct containing information about amounts spent
    /// and received in the rebalance
    function performTrade(
        Trade memory trade,
        TradeFlag memory tradeFlag,
        CurrentAmounts amounts
    )
        internal
    {
        /* logger.log("Performing trade"); */

        for (uint256 j; j < trade.orders.length; j++) {

            if(amounts.amountLeftToSpendOnTrade * 10000 < (amounts.amountSpentOnTrade + amounts.amountLeftToSpendOnTrade)){
                return;
            }

            if((trade.isSell ? amounts.amountSpentOnTrade : amounts.amountReceivedFromTrade) >= trade.tokenAmount ) {
                return;
            }

            if (tradeFlag.ignoreOrder[j] || amounts.amountLeftToSpendOnTrade == 0) {
                /* logger.log(
                    "Order ignore flag is set to true or have nothing left to spend arg2: amountLeftToSpendOnTrade",
                    amounts.amountLeftToSpendOnTrade
                ); */
                continue;
            }

            uint256 amountSpentOnOrder = 0;
            uint256 amountReceivedFromOrder = 0;

            Order memory thisOrder = trade.orders[j];

            /* logger.log("Setting order exchange handler arg6: exchangeHandler.", 0, 0, 0, 0, thisOrder.exchangeHandler); */
            ExchangeHandler thisHandler = ExchangeHandler(thisOrder.exchangeHandler);

            uint256 amountToGiveForOrder = Utils.min(
                thisHandler.getAmountToGive(thisOrder.genericPayload),
                amounts.amountLeftToSpendOnTrade
            );

            if (amountToGiveForOrder == 0) {
                /* logger.log(
                    "MASSIVE ERROR: amountToGiveForOrder was found to be 0, this hasn't been caught in preTradeChecks, which means dynamicExchangeChecks isnt written correctly!"
                ); */
                continue;
            }

            /* logger.log(
                "Calculating amountToGiveForOrder arg2: amountToGiveForOrder, arg3: amountLeftToSpendOnTrade.",
                amountToGiveForOrder,
                amounts.amountLeftToSpendOnTrade
            ); */

            if( !thisHandler.staticExchangeChecks(thisOrder.genericPayload) ) {
                /* logger.log("Order did not pass checks, skipping."); */
                continue;
            }

            if (trade.isSell) {
                /* logger.log("This is a sell.."); */
                if (!ERC20SafeTransfer.safeTransfer(trade.tokenAddress,address(thisHandler), amountToGiveForOrder)) {
                    if( !trade.optionalTrade ) errorReporter.revertTx("Unable to transfer tokens to handler");
                    else {
                        /* logger.log("Unable to transfer tokens to handler but the trade is optional"); */
                        return;
                    }
                }

                /* logger.log("Going to perform a sell order."); */
                (amountSpentOnOrder, amountReceivedFromOrder) = thisHandler.performSellOrder(thisOrder.genericPayload, amountToGiveForOrder);
                /* logger.log("Sell order performed arg2: amountSpentOnOrder, arg3: amountReceivedFromOrder", amountSpentOnOrder, amountReceivedFromOrder); */
            } else {
                /* logger.log("Going to perform a buy order."); */
                (amountSpentOnOrder, amountReceivedFromOrder) = thisHandler.performBuyOrder.value(amountToGiveForOrder)(thisOrder.genericPayload, amountToGiveForOrder);
                /* logger.log("Buy order performed arg2: amountSpentOnOrder, arg3: amountReceivedFromOrder", amountSpentOnOrder, amountReceivedFromOrder); */
            }


            if (amountReceivedFromOrder > 0) {
                amounts.amountLeftToSpendOnTrade = SafeMath.sub(amounts.amountLeftToSpendOnTrade, amountSpentOnOrder);
                amounts.amountSpentOnTrade = SafeMath.add(amounts.amountSpentOnTrade, amountSpentOnOrder);
                amounts.amountReceivedFromTrade = SafeMath.add(amounts.amountReceivedFromTrade, amountReceivedFromOrder);

                /* logger.log(
                    "Updated amounts arg2: amountLeftToSpendOnTrade, arg3: amountSpentOnTrade, arg4: amountReceivedFromTrade.",
                    amounts.amountLeftToSpendOnTrade,
                    amounts.amountSpentOnTrade,
                    amounts.amountReceivedFromTrade
                ); */
            }
        }

    }

    /// @notice Check if the amounts spent and gained on a trade are within the
    /// user"s set limits
    /// @param trade contains information on the given trade
    /// @param amountSpentOnTrade the amount that was spent on the trade
    /// @param amountReceivedFromTrade the amount that was received from the trade
    /// @return bool whether the trade passes the checks
    function checkIfTradeAmountsAcceptable(
        Trade trade,
        uint256 amountSpentOnTrade,
        uint256 amountReceivedFromTrade
    )
        internal
        view
        returns (bool passed)
    {
        /* logger.log("Checking if trade amounts are acceptable."); */
        uint256 tokenAmount = trade.isSell ? amountSpentOnTrade : amountReceivedFromTrade;
        passed = tokenAmount >= trade.minimumAcceptableTokenAmount;

        /*if( !passed ) {
             logger.log(
                "Received less than minimum acceptable tokens arg2: tokenAmount , arg3: minimumAcceptableTokenAmount.",
                tokenAmount,
                trade.minimumAcceptableTokenAmount
            );
        }*/

        if (passed) {
            uint256 tokenDecimals = Utils.getDecimals(ERC20(trade.tokenAddress));
            uint256 srcDecimals = trade.isSell ? tokenDecimals : Utils.eth_decimals();
            uint256 destDecimals = trade.isSell ? Utils.eth_decimals() : tokenDecimals;
            uint256 actualRate = Utils.calcRateFromQty(amountSpentOnTrade, amountReceivedFromTrade, srcDecimals, destDecimals);
            passed = actualRate >= trade.minimumExchangeRate;
        }

        /*if( !passed ) {
             logger.log(
                "Order rate was lower than minimum acceptable,  rate arg2: actualRate, arg3: minimumExchangeRate.",
                actualRate,
                trade.minimumExchangeRate
            );
        }*/
    }

    /// @notice Iterates through a list of token orders, transfer the SELL orders to this contract & calculates if we have the ether needed
    /// @param trades A dynamic array of trade structs
    /// @param tradeFlags A dynamic array of flags indicating trade and order status
    function transferTokens(Trade[] trades, TradeFlag[] tradeFlags) internal {
        for (uint256 i = 0; i < trades.length; i++) {
            if (trades[i].isSell && !tradeFlags[i].ignoreTrade) {

                /* logger.log(
                    "Transfering tokens arg2: tokenAmount, arg5: tokenAddress.",
                    trades[i].tokenAmount,
                    0,
                    0,
                    0,
                    trades[i].tokenAddress
                ); */
                if (
                    !tokenTransferProxy.transferFrom(
                        trades[i].tokenAddress,
                        msg.sender,
                        address(this),
                        trades[i].tokenAmount
                    )
                ) {
                    errorReporter.revertTx("TTP unable to transfer tokens to primary");
                }
           }
        }
    }

    /// @notice Calculates the maximum amount that should be spent on a given buy trade
    /// @param trade the buy trade to return the spend amount for
    /// @param etherBalance the amount of ether that we currently have to spend
    /// @return uint256 the maximum amount of ether we should spend on this trade
    function calculateMaxEtherSpend(Trade trade, uint256 etherBalance, uint256 feePercentage) internal view returns (uint256) {
        /// @dev This function should never be called for a sell
        assert(!trade.isSell);

        uint256 tokenDecimals = Utils.getDecimals(ERC20(trade.tokenAddress));
        uint256 srcDecimals = trade.isSell ? tokenDecimals : Utils.eth_decimals();
        uint256 destDecimals = trade.isSell ? Utils.eth_decimals() : tokenDecimals;
        uint256 maxSpendAtMinRate = Utils.calcSrcQty(trade.tokenAmount, srcDecimals, destDecimals, trade.minimumExchangeRate);

        return Utils.min(removeFee(etherBalance, feePercentage), maxSpendAtMinRate);
    }

    // @notice Calculates the fee amount given a fee percentage and amount
    // @param amount the amount to calculate the fee based on
    // @param fee the percentage, out of 1 eth (e.g. 0.01 ETH would be 1%)
    function calculateFee(uint256 amount, uint256 fee) internal view returns (uint256){
        return SafeMath.div(SafeMath.mul(amount, fee), 1 ether);
    }

    // @notice Calculates the cost if amount=cost+fee
    // @param amount the amount to calculate the base on
    // @param fee the percentage, out of 1 eth (e.g. 0.01 ETH would be 1%)
    function removeFee(uint256 amount, uint256 fee) internal view returns (uint256){
        return SafeMath.div(SafeMath.mul(amount, 1 ether), SafeMath.add(fee, 1 ether));
    }
    /*
    *   Payable fallback function
    */

    /// @notice payable fallback to allow handler or exchange contracts to return ether
    /// @dev only accounts containing code (ie. contracts) can send ether to this contract
    function() public payable whenNotPaused {
        // Check in here that the sender is a contract! (to stop accidents)
        uint256 size;
        address sender = msg.sender;
        assembly {
            size := extcodesize(sender)
        }
        if (size == 0) {
            errorReporter.revertTx("EOA cannot send ether to primary fallback");
        }
    }
}



/// @title A contract which is used to check and set allowances of tokens
/// @dev In order to use this contract is must be inherited in the contract which is using
/// its functionality
contract AllowanceSetter {
    uint256 constant MAX_UINT = 2**256 - 1;

    /// @notice A function which allows the caller to approve the max amount of any given token
    /// @dev In order to function correctly, token allowances should not be set anywhere else in
    /// the inheriting contract
    /// @param addressToApprove the address which we want to approve to transfer the token
    /// @param token the token address which we want to call approve on
    function approveAddress(address addressToApprove, address token) internal {
        if(ERC20(token).allowance(address(this), addressToApprove) == 0) {
            require(ERC20SafeTransfer.safeApprove(token, addressToApprove, MAX_UINT));
        }
    }

}

contract TotleProxyPrimary is Ownable, AllowanceSetter {

    TokenTransferProxy public tokenTransferProxy;
    TotlePrimary public totlePrimary;

    constructor(address _tokenTransferProxy, address _totlePrimary) public {
        tokenTransferProxy = TokenTransferProxy(_tokenTransferProxy);
        totlePrimary = TotlePrimary(_totlePrimary);
    }

    function performRebalance(
        TotlePrimary.Trade[] memory trades,
        address feeAccount,
        bytes32 id,
        address paymentReceiver,
        bool redirectEth,
        address[] redirectTokens
    )
        public
        payable
    {
          transferTokensIn(trades);
          totlePrimary.performRebalance.value(msg.value)(trades, feeAccount, id);
          transferTokensOut(trades, paymentReceiver, redirectTokens);
          if(redirectEth) {
              paymentReceiver.transfer(address(this).balance);
          } else {
              msg.sender.transfer(address(this).balance);
          }
    }

    function transferTokensIn(TotlePrimary.Trade[] trades) internal {
        for (uint256 i = 0; i < trades.length; i++) {
            if (trades[i].isSell) {
                if (!tokenTransferProxy.transferFrom(
                        trades[i].tokenAddress,
                        msg.sender,
                        address(this),
                        trades[i].tokenAmount
                )) {
                    revert("TTP unable to transfer tokens to proxy");
                }
                approveAddress(address(totlePrimary), trades[i].tokenAddress);
           }
        }
    }

    function transferTokensOut(TotlePrimary.Trade[] trades, address receiver, address[] redirectTokens) internal {
        for (uint256 i = 0; i < trades.length; i++) {
            bool redirect = false;
            for(uint256 tokenIndex = 0; tokenIndex < redirectTokens.length; tokenIndex++){
                if(redirectTokens[tokenIndex] == trades[i].tokenAddress){
                    redirect = true;
                    break;
                }
            }
            uint256 balance = ERC20(trades[i].tokenAddress).balanceOf(address(this));
            if(balance > 0){
                ERC20SafeTransfer.safeTransfer(trades[i].tokenAddress, redirect ? receiver : msg.sender, balance);
            }
        }
    }

    function setTokenTransferProxy(address _newTokenTransferProxy) public onlyOwner {
        tokenTransferProxy = TokenTransferProxy(_newTokenTransferProxy);
    }

    function setTotlePrimary(address _newTotlePrimary) public onlyOwner {
        totlePrimary = TotlePrimary(_newTotlePrimary);
    }

}