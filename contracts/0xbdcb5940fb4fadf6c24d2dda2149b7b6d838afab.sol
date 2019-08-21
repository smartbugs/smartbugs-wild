/**
* Copyright Accelerator 2018
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is furnished to
* do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
pragma solidity ^0.4.24;

library SafeMath {

    function safeMul(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeSub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b)
        internal
        pure
        returns (uint256)
    {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract EtherDelta {
  function deposit() public payable {}
  function withdrawToken(address token, uint amount) public {}
  function trade(address tokenGet, uint amountGet, address tokenGive, uint amountGive, uint expires, uint nonce, address user, uint8 v, bytes32 r, bytes32 s, uint amount) public {}
  function balanceOf(address token, address user) public view returns (uint);
}

contract Accelerator {
  function transfer(address to, uint tokens) public returns (bool success);
}

contract AcceleratorX {
  /// @dev Set constant values here
  string public constant name = "AcceleratorX";
  string public constant symbol = "ACCx";
  uint8 public constant decimals = 18;
  uint public totalSupply;
  uint public constant maxTotalSupply = 10**27;
  address constant public ETHERDELTA_ADDR = 0x8d12A197cB00D4747a1fe03395095ce2A5CC6819; // EtherDelta contract address
  address constant public ACCELERATOR_ADDR = 0x13f1b7fdfbe1fc66676d56483e21b1ecb40b58e2; // Accelerator contract address

  event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
  event Transfer(address indexed from, address indexed to, uint tokens);

  mapping(address => uint256) balances;
  mapping(address => mapping (address => uint256)) allowed;

  using SafeMath for uint256;
  /// @dev Burn ACC tokens
  function burn(
    uint volume,
    uint volumeETH,
    uint expires,
    uint nonce,
    address user,
    uint8 v,
    bytes32 r,
    bytes32 s,
    uint amount
  ) public payable
  {
    /// @dev Deposit ethers in EtherDelta
    deposit(msg.value);
    /// @dev Execute the trade
    EtherDelta(ETHERDELTA_ADDR).trade(
      address(0),
      volume,
      ACCELERATOR_ADDR,
      volumeETH,
      expires,
      nonce,
      user,
      v,
      r,
      s,
      amount
    );
    /// @dev Get the balance of ACC tokens stored in the EtherDelta contract
    uint ACC = EtherDelta(ETHERDELTA_ADDR).balanceOf(ACCELERATOR_ADDR, address(this));
    /// @dev Withdraw ACC tokens from EtherDelta
    withdrawToken(ACCELERATOR_ADDR, ACC);
    /// @dev Send the tokens to address(0) (the burn address) - require it or fail here
    require(Accelerator(ACCELERATOR_ADDR).transfer(address(0), ACC));
    /// @dev Proof of Burn = Credit the msg.sender address with volume of tokens trasfered to burn address multiplied by 100 (1 ACC = 100 ACCX)
    uint256 numTokens = SafeMath.safeMul(ACC, 100);
    balances[msg.sender] = balances[msg.sender].safeAdd(numTokens);
    totalSupply = totalSupply.safeAdd(numTokens);
    emit Transfer(address(0), msg.sender, numTokens);
  }
/// @dev Deposit ethers to EtherDelta.
/// @param amount Amount of ethers to deposit in EtherDelta
function deposit(uint amount) internal {
  EtherDelta(ETHERDELTA_ADDR).deposit.value(amount)();
}
/// @dev Withdraw tokens from EtherDelta.
/// @param token Address of token to withdraw from EtherDelta
/// @param amount Amount of tokens to withdraw from EtherDelta
function withdrawToken(address token, uint amount) internal {
  EtherDelta(ETHERDELTA_ADDR).withdrawToken(token, amount);
}

/// @dev ERC20 logic for AcceleratorX token
function balanceOf(address tokenOwner) public view returns (uint) {
    return balances[tokenOwner];
}

function transfer(address receiver, uint numTokens) public returns (bool) {
    require(numTokens <= balances[msg.sender]);
    balances[msg.sender] = balances[msg.sender].safeSub(numTokens);
    balances[receiver] = balances[receiver].safeAdd(numTokens);
    emit Transfer(msg.sender, receiver, numTokens);
    return true;
}

function approve(address delegate, uint numTokens) public returns (bool) {
    allowed[msg.sender][delegate] = numTokens;
    emit Approval(msg.sender, delegate, numTokens);
    return true;
}

function allowance(address owner, address delegate) public view returns (uint) {
    return allowed[owner][delegate];
}

function transferFrom(address owner, address buyer, uint numTokens) public returns (bool) {
    require(numTokens <= balances[owner]);
    require(numTokens <= allowed[owner][msg.sender]);

    balances[owner] = balances[owner].safeSub(numTokens);
    allowed[owner][msg.sender] = allowed[owner][msg.sender].safeSub(numTokens);
    balances[buyer] = balances[buyer].safeAdd(numTokens);
    emit Transfer(owner, buyer, numTokens);
    return true;
}
}