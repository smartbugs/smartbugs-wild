pragma solidity 0.4.18;

//! The owned contract.
//!
//! Copyright 2016 Gavin Wood, Parity Technologies Ltd.
//!
//! Licensed under the Apache License, Version 2.0 (the "License");
//! you may not use this file except in compliance with the License.
//! You may obtain a copy of the License at
//!
//!     http://www.apache.org/licenses/LICENSE-2.0
//!
//! Unless required by applicable law or agreed to in writing, software
//! distributed under the License is distributed on an "AS IS" BASIS,
//! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//! See the License for the specific language governing permissions and
//! limitations under the License.

contract Owned {
  modifier only_owner { require(msg.sender == owner); _; }

  event NewOwner(address indexed old, address indexed current);

  function setOwner(address _new) only_owner public { NewOwner(owner, _new); owner = _new; }

  address public owner = msg.sender;
}


/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}


/**
 *  CanYa Coin contract
 */


contract ERC20TokenInterface {

    /// @return The total amount of tokens
    function totalSupply() constant returns (uint256 supply);

    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant public returns (uint256 balance);

    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) public returns (bool success);

    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

    /// @notice `msg.sender` approves `_spender` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of tokens to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) public returns (bool success);

    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant public returns (uint256 remaining);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

}


contract CanYaCoin is ERC20TokenInterface {

    string public constant name = "CanYaCoin";
    string public constant symbol = "CAN";
    uint256 public constant decimals = 6;
    uint256 public constant totalTokens = 100000000 * (10 ** decimals);

    mapping (address => uint256) public balances;
    mapping (address => mapping (address => uint256)) public allowed;

    function CanYaCoin() {
        balances[msg.sender] = totalTokens;
    }

    function totalSupply() constant returns (uint256) {
        return totalTokens;
    }

    function transfer(address _to, uint256 _value) public returns (bool) {
        if (balances[msg.sender] >= _value) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        }
        return false;
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value) {
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(_from, _to, _value);
            return true;
        }
        return false;
    }

    function balanceOf(address _owner) constant public returns (uint256) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant public returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

}


contract AssetSplit is Owned {
  using SafeMath for uint256;

  CanYaCoin public CanYaCoinToken;

  address public operationalAddress;
  address public rewardAddress;
  address public charityAddress;
  address public constant burnAddress = 0x000000000000000000000000000000000000dEaD;

  uint256 public constant operationalSplitPercent = 30;
  uint256 public constant rewardSplitPercent = 30;
  uint256 public constant charitySplitPercent = 10;
  uint256 public constant burnSplitPercent = 30;

  event OperationalSplit(uint256 _split);
  event RewardSplit(uint256 _split);
  event CharitySplit(uint256 _split);
  event BurnSplit(uint256 _split);

  /// @dev Deploys the asset splitting contract
  /// @param _tokenAddress Address of the CAN token contract
  /// @param _operational Address of the operational holdings
  /// @param _reward Address of the reward holdings
  /// @param _charity Address of the charity holdings
  function AssetSplit (
    address _tokenAddress,
    address _operational,
    address _reward,
    address _charity) public {
    require(_tokenAddress != 0);
    require(_operational != 0);
    require(_reward != 0);
    require(_charity != 0);
    CanYaCoinToken = CanYaCoin(_tokenAddress);
    operationalAddress = _operational;
    rewardAddress = _reward;
    charityAddress = _charity;
  }

  /// @dev Splits the tokens from the owner address to the defined locations
  /// @param _amountToSplit Amount of tokens to redistribute from the owner
  function split (uint256 _amountToSplit) public only_owner {
    require(_amountToSplit != 0);
    // check that we are going to have enough tokens to transfer
    require(CanYaCoinToken.allowance(owner, this) >= _amountToSplit);

    // now we get the amounts of tokens for each recipient
    uint256 onePercentOfSplit = _amountToSplit / 100;
    uint256 operationalSplitAmount = onePercentOfSplit.mul(operationalSplitPercent);
    uint256 rewardSplitAmount = onePercentOfSplit.mul(rewardSplitPercent);
    uint256 charitySplitAmount = onePercentOfSplit.mul(charitySplitPercent);
    uint256 burnSplitAmount = onePercentOfSplit.mul(burnSplitPercent);

    // double check that we're not going to try to send too many tokens
    require(
      operationalSplitAmount
        .add(rewardSplitAmount)
        .add(charitySplitAmount)
        .add(burnSplitAmount)
      <= _amountToSplit
    );

    // we now should be able to make the transfers
    require(CanYaCoinToken.transferFrom(owner, operationalAddress, operationalSplitAmount));
    require(CanYaCoinToken.transferFrom(owner, rewardAddress, rewardSplitAmount));
    require(CanYaCoinToken.transferFrom(owner, charityAddress, charitySplitAmount));
    require(CanYaCoinToken.transferFrom(owner, burnAddress, burnSplitAmount));

    OperationalSplit(operationalSplitAmount);
    RewardSplit(rewardSplitAmount);
    CharitySplit(charitySplitAmount);
    BurnSplit(burnSplitAmount);
  }

}