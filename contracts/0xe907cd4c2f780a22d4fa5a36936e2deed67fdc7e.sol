pragma solidity ^0.4.15;

// File: contracts/BTC.sol

// Bitcoin transaction parsing library

// Copyright 2016 rain <https://keybase.io/rain>
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//      http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

// https://en.bitcoin.it/wiki/Protocol_documentation#tx
//
// Raw Bitcoin transaction structure:
//
// field     | size | type     | description
// version   | 4    | int32    | transaction version number
// n_tx_in   | 1-9  | var_int  | number of transaction inputs
// tx_in     | 41+  | tx_in[]  | list of transaction inputs
// n_tx_out  | 1-9  | var_int  | number of transaction outputs
// tx_out    | 9+   | tx_out[] | list of transaction outputs
// lock_time | 4    | uint32   | block number / timestamp at which tx locked
//
// Transaction input (tx_in) structure:
//
// field      | size | type     | description
// previous   | 36   | outpoint | Previous output transaction reference
// script_len | 1-9  | var_int  | Length of the signature script
// sig_script | ?    | uchar[]  | Script for confirming transaction authorization
// sequence   | 4    | uint32   | Sender transaction version
//
// OutPoint structure:
//
// field      | size | type     | description
// hash       | 32   | char[32] | The hash of the referenced transaction
// index      | 4    | uint32   | The index of this output in the referenced transaction
//
// Transaction output (tx_out) structure:
//
// field         | size | type     | description
// value         | 8    | int64    | Transaction value (Satoshis)
// pk_script_len | 1-9  | var_int  | Length of the public key script
// pk_script     | ?    | uchar[]  | Public key as a Bitcoin script.
//
// Variable integers (var_int) can be encoded differently depending
// on the represented value, to save space. Variable integers always
// precede an array of a variable length data type (e.g. tx_in).
//
// Variable integer encodings as a function of represented value:
//
// value           | bytes  | format
// <0xFD (253)     | 1      | uint8
// <=0xFFFF (65535)| 3      | 0xFD followed by length as uint16
// <=0xFFFF FFFF   | 5      | 0xFE followed by length as uint32
// -               | 9      | 0xFF followed by length as uint64
//
// Public key scripts `pk_script` are set on the output and can
// take a number of forms. The regular transaction script is
// called 'pay-to-pubkey-hash' (P2PKH):
//
// OP_DUP OP_HASH160 <pubKeyHash> OP_EQUALVERIFY OP_CHECKSIG
//
// OP_x are Bitcoin script opcodes. The bytes representation (including
// the 0x14 20-byte stack push) is:
//
// 0x76 0xA9 0x14 <pubKeyHash> 0x88 0xAC
//
// The <pubKeyHash> is the ripemd160 hash of the sha256 hash of
// the public key, preceded by a network version byte. (21 bytes total)
//
// Network version bytes: 0x00 (mainnet); 0x6f (testnet); 0x34 (namecoin)
//
// The Bitcoin address is derived from the pubKeyHash. The binary form is the
// pubKeyHash, plus a checksum at the end.  The checksum is the first 4 bytes
// of the (32 byte) double sha256 of the pubKeyHash. (25 bytes total)
// This is converted to base58 to form the publicly used Bitcoin address.
// Mainnet P2PKH transaction scripts are to addresses beginning with '1'.
//
// P2SH ('pay to script hash') scripts only supply a script hash. The spender
// must then provide the script that would allow them to redeem this output.
// This allows for arbitrarily complex scripts to be funded using only a
// hash of the script, and moves the onus on providing the script from
// the spender to the redeemer.
//
// The P2SH script format is simple:
//
// OP_HASH160 <scriptHash> OP_EQUAL
//
// 0xA9 0x14 <scriptHash> 0x87
//
// The <scriptHash> is the ripemd160 hash of the sha256 hash of the
// redeem script. The P2SH address is derived from the scriptHash.
// Addresses are the scriptHash with a version prefix of 5, encoded as
// Base58check. These addresses begin with a '3'.

pragma solidity ^0.4.11;

// parse a raw bitcoin transaction byte array
library BTC {
    // Convert a variable integer into something useful and return it and
    // the index to after it.
    function parseVarInt(bytes txBytes, uint pos) returns (uint, uint) {
        // the first byte tells us how big the integer is
        var ibit = uint8(txBytes[pos]);
        pos += 1;  // skip ibit

        if (ibit < 0xfd) {
            return (ibit, pos);
        } else if (ibit == 0xfd) {
            return (getBytesLE(txBytes, pos, 16), pos + 2);
        } else if (ibit == 0xfe) {
            return (getBytesLE(txBytes, pos, 32), pos + 4);
        } else if (ibit == 0xff) {
            return (getBytesLE(txBytes, pos, 64), pos + 8);
        }
    }
    // convert little endian bytes to uint
    function getBytesLE(bytes data, uint pos, uint bits) returns (uint) {
        if (bits == 8) {
            return uint8(data[pos]);
        } else if (bits == 16) {
            return uint16(data[pos])
                 + uint16(data[pos + 1]) * 2 ** 8;
        } else if (bits == 32) {
            return uint32(data[pos])
                 + uint32(data[pos + 1]) * 2 ** 8
                 + uint32(data[pos + 2]) * 2 ** 16
                 + uint32(data[pos + 3]) * 2 ** 24;
        } else if (bits == 64) {
            return uint64(data[pos])
                 + uint64(data[pos + 1]) * 2 ** 8
                 + uint64(data[pos + 2]) * 2 ** 16
                 + uint64(data[pos + 3]) * 2 ** 24
                 + uint64(data[pos + 4]) * 2 ** 32
                 + uint64(data[pos + 5]) * 2 ** 40
                 + uint64(data[pos + 6]) * 2 ** 48
                 + uint64(data[pos + 7]) * 2 ** 56;
        }
    }
    // scan the full transaction bytes and return the first two output
    // values (in satoshis) and addresses (in binary)
    function getFirstTwoOutputs(bytes txBytes)
             returns (uint, bytes20, uint, bytes20)
    {
        uint pos;
        uint[] memory input_script_lens = new uint[](2);
        uint[] memory output_script_lens = new uint[](2);
        uint[] memory script_starts = new uint[](2);
        uint[] memory output_values = new uint[](2);
        bytes20[] memory output_addresses = new bytes20[](2);

        pos = 4;  // skip version

        (input_script_lens, pos) = scanInputs(txBytes, pos, 0);

        (output_values, script_starts, output_script_lens, pos) = scanOutputs(txBytes, pos, 2);

        for (uint i = 0; i < 2; i++) {
            var pkhash = parseOutputScript(txBytes, script_starts[i], output_script_lens[i]);
            output_addresses[i] = pkhash;
        }

        return (output_values[0], output_addresses[0],
                output_values[1], output_addresses[1]);
    }
    // Check whether `btcAddress` is in the transaction outputs *and*
    // whether *at least* `value` has been sent to it.
        // Check whether `btcAddress` is in the transaction outputs *and*
    // whether *at least* `value` has been sent to it.
    function checkValueSent(bytes txBytes, bytes20 btcAddress, uint value)
             returns (bool,uint)
    {
        uint pos = 4;  // skip version
        (, pos) = scanInputs(txBytes, pos, 0);  // find end of inputs

        // scan *all* the outputs and find where they are
        var (output_values, script_starts, output_script_lens,) = scanOutputs(txBytes, pos, 0);

        // look at each output and check whether it at least value to btcAddress
        for (uint i = 0; i < output_values.length; i++) {
            var pkhash = parseOutputScript(txBytes, script_starts[i], output_script_lens[i]);
            if (pkhash == btcAddress && output_values[i] >= value) {
                return (true,output_values[i]);
            }
        }
    }
    // scan the inputs and find the script lengths.
    // return an array of script lengths and the end position
    // of the inputs.
    // takes a 'stop' argument which sets the maximum number of
    // outputs to scan through. stop=0 => scan all.
    function scanInputs(bytes txBytes, uint pos, uint stop)
             returns (uint[], uint)
    {
        uint n_inputs;
        uint halt;
        uint script_len;

        (n_inputs, pos) = parseVarInt(txBytes, pos);

        if (stop == 0 || stop > n_inputs) {
            halt = n_inputs;
        } else {
            halt = stop;
        }

        uint[] memory script_lens = new uint[](halt);

        for (var i = 0; i < halt; i++) {
            pos += 36;  // skip outpoint
            (script_len, pos) = parseVarInt(txBytes, pos);
            script_lens[i] = script_len;
            pos += script_len + 4;  // skip sig_script, seq
        }

        return (script_lens, pos);
    }
    // scan the outputs and find the values and script lengths.
    // return array of values, array of script lengths and the
    // end position of the outputs.
    // takes a 'stop' argument which sets the maximum number of
    // outputs to scan through. stop=0 => scan all.
    function scanOutputs(bytes txBytes, uint pos, uint stop)
             returns (uint[], uint[], uint[], uint)
    {
        uint n_outputs;
        uint halt;
        uint script_len;

        (n_outputs, pos) = parseVarInt(txBytes, pos);

        if (stop == 0 || stop > n_outputs) {
            halt = n_outputs;
        } else {
            halt = stop;
        }

        uint[] memory script_starts = new uint[](halt);
        uint[] memory script_lens = new uint[](halt);
        uint[] memory output_values = new uint[](halt);

        for (var i = 0; i < halt; i++) {
            output_values[i] = getBytesLE(txBytes, pos, 64);
            pos += 8;

            (script_len, pos) = parseVarInt(txBytes, pos);
            script_starts[i] = pos;
            script_lens[i] = script_len;
            pos += script_len;
        }

        return (output_values, script_starts, script_lens, pos);
    }
    // Slice 20 contiguous bytes from bytes `data`, starting at `start`
    function sliceBytes20(bytes data, uint start) returns (bytes20) {
        uint160 slice = 0;
        for (uint160 i = 0; i < 20; i++) {
            slice += uint160(data[i + start]) << (8 * (19 - i));
        }
        return bytes20(slice);
    }
    // returns true if the bytes located in txBytes by pos and
    // script_len represent a P2PKH script
    function isP2PKH(bytes txBytes, uint pos, uint script_len) returns (bool) {
        return (script_len == 25)           // 20 byte pubkeyhash + 5 bytes of script
            && (txBytes[pos] == 0x76)       // OP_DUP
            && (txBytes[pos + 1] == 0xa9)   // OP_HASH160
            && (txBytes[pos + 2] == 0x14)   // bytes to push
            && (txBytes[pos + 23] == 0x88)  // OP_EQUALVERIFY
            && (txBytes[pos + 24] == 0xac); // OP_CHECKSIG
    }
    // returns true if the bytes located in txBytes by pos and
    // script_len represent a P2SH script
    function isP2SH(bytes txBytes, uint pos, uint script_len) returns (bool) {
        return (script_len == 23)           // 20 byte scripthash + 3 bytes of script
            && (txBytes[pos + 0] == 0xa9)   // OP_HASH160
            && (txBytes[pos + 1] == 0x14)   // bytes to push
            && (txBytes[pos + 22] == 0x87); // OP_EQUAL
    }
    // Get the pubkeyhash / scripthash from an output script. Assumes
    // pay-to-pubkey-hash (P2PKH) or pay-to-script-hash (P2SH) outputs.
    // Returns the pubkeyhash/ scripthash, or zero if unknown output.
    function parseOutputScript(bytes txBytes, uint pos, uint script_len)
             returns (bytes20)
    {
        if (isP2PKH(txBytes, pos, script_len)) {
            return sliceBytes20(txBytes, pos + 3);
        } else if (isP2SH(txBytes, pos, script_len)) {
            return sliceBytes20(txBytes, pos + 2);
        } else {
            return;
        }
    }
}

// File: contracts/Ownable.sol

contract Ownable {
  address public owner;

  function Ownable() {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    if (msg.sender == owner)
      _;
  }

  function transferOwnership(address newOwner) onlyOwner {
    if (newOwner != address(0)) owner = newOwner;
  }

}

// File: contracts/Pausable.sol

/*
 * Pausable
 * Abstract contract that allows children to implement an
 * emergency stop mechanism.
 */

contract Pausable is Ownable {
  bool public stopped;

  modifier stopInEmergency {
    if (stopped) {
      throw;
    }
    _;
  }

  modifier onlyInEmergency {
    if (!stopped) {
      throw;
    }
    _;
  }

  // called by the owner on emergency, triggers stopped state
  function emergencyStop() external onlyOwner {
    stopped = true;
  }

  // called by the owner on end of emergency, returns to normal state
  function release() external onlyOwner onlyInEmergency {
    stopped = false;
  }

}

// File: contracts/SafeMath.sol

/**
 * Math operations with safety checks
 */
contract SafeMath {
  function safeMul(uint a, uint b) internal returns (uint) {
    uint c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function safeDiv(uint a, uint b) internal returns (uint) {
    assert(b > 0);
    uint c = a / b;
    assert(a == b * c + a % b);
    return c;
  }

  function safeSub(uint a, uint b) internal returns (uint) {
    assert(b <= a);
    return a - b;
  }

  function safeAdd(uint a, uint b) internal returns (uint) {
    uint c = a + b;
    assert(c>=a && c>=b);
    return c;
  }

  function max64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a >= b ? a : b;
  }

  function min64(uint64 a, uint64 b) internal constant returns (uint64) {
    return a < b ? a : b;
  }

  function max256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a >= b ? a : b;
  }

  function min256(uint256 a, uint256 b) internal constant returns (uint256) {
    return a < b ? a : b;
  }

}

// File: contracts/StandardToken.sol

contract Token {
    uint256 public totalSupply;

    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}


/*  ERC 20 token */
contract StandardToken is Token {

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

    function transfer(address _to, uint256 _value) returns (bool success) {
      if (balances[msg.sender] >= _value && _value > 0) {
        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
        } else {
            return false;
        }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
      if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
        balances[_to] += _value;
        balances[_from] -= _value;
        allowed[_from][msg.sender] -= _value;
        Transfer(_from, _to, _value);
        return true;
        } else {
            return false;
        }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
  }


}

// File: contracts/Utils.sol

contract Utils{

	//verifies the amount greater than zero

	modifier greaterThanZero(uint256 _value){
		require(_value>0);
		_;
	}

	///verifies an address

	modifier validAddress(address _add){
		require(_add!=0x0);
		_;
	}
}

// File: contracts/Crowdsale.sol

contract Crowdsale is StandardToken, Pausable, SafeMath, Utils{
	string public constant name = "Mudra";
	string public constant symbol = "MUDRA";
	uint256 public constant decimals = 18;
	string public version = "1.0";
	bool public tradingStarted = false;

    /**
   * @dev modifier that throws if trading has not started yet
   */
   modifier hasStartedTrading() {
   	require(tradingStarted);
   	_;
   }
  /**
   * @dev Allows the owner to enable the trading. This can not be undone
   */
   function startTrading() onlyOwner() {
   	tradingStarted = true;
   }

   function transfer(address _to, uint _value) hasStartedTrading returns (bool success) {super.transfer(_to, _value);}

   function transferFrom(address _from, address _to, uint _value) hasStartedTrading returns (bool success) {super.transferFrom(_from, _to, _value);}

   enum State{
   	Inactive,
   	Funding,
   	Success,
   	Failure
   }

   uint256 public investmentETH;
   uint256 public investmentBTC;
   mapping(uint256 => bool) transactionsClaimed;
   uint256 public initialSupply;
   address wallet;
   uint256 public constant _totalSupply = 100 * (10**6) * 10 ** decimals; // 100M ~ 10 Crores
   uint256 public fundingStartBlock; // crowdsale start block
   uint256 public constant minBtcValue = 10000; // ~ approx 1$
   uint256 public tokensPerEther = 450; // 1 ETH = 460 tokens
   uint256 public tokensPerBTC = 140 * 10 ** 10 * 10 ** 2; // 1 btc = 11500 Tokens
   uint256 public constant tokenCreationMax = 10 * (10**6) * 10 ** decimals; // 10M ~ 1 Crores
   address[] public investors;

   //displays number of uniq investors
   function investorsCount() constant external returns(uint) { return investors.length; }

   function Crowdsale(uint256 _fundingStartBlock, address _owner, address _wallet){
      owner = _owner;
      fundingStartBlock =_fundingStartBlock;
      totalSupply = _totalSupply;
      initialSupply = 0;
      wallet = _wallet;

      //check configuration if something in setup is looking weird
      if (
        tokensPerEther == 0
        || tokensPerBTC == 0
        || owner == 0x0
        || wallet == 0x0
        || fundingStartBlock == 0
        || totalSupply == 0
        || tokenCreationMax == 0
        || fundingStartBlock <= block.number)
      throw;

   }

   // don't just send ether to the contract expecting to get tokens
   //function() { throw; }
   ////@dev This function manages the Crowdsale State machine
   ///We make it a function and do not assign to a variable//
   ///so that no chance of stale variable
   function getState() constant public returns(State){
   	///once we reach success lock the State
   	if(block.number<fundingStartBlock) return State.Inactive;
   	else if(block.number>fundingStartBlock && initialSupply<tokenCreationMax) return State.Funding;
   	else if (initialSupply >= tokenCreationMax) return State.Success;
   	else return State.Failure;
   }

   ///get total tokens in that address mapping
   function getTokens(address addr) public returns(uint256){
   	return balances[addr];
   }

   ///get the block number state
   function getStateFunding() public returns (uint256){
   	// average 6000 blocks mined in 24 hrs
   	if(block.number<fundingStartBlock + 180000) return 20; // 1 month 20%
   	else if(block.number>=fundingStartBlock+ 180001 && block.number<fundingStartBlock + 270000) return 10; // next 15 days
   	else if(block.number>=fundingStartBlock + 270001 && block.number<fundingStartBlock + 36000) return 5; // next 15 days
   	else return 0;
   }
   ///a function using safemath to work with
   ///the new function
   function calNewTokens(uint256 tokens) returns (uint256){
   	uint256 disc = getStateFunding();
   	tokens = safeAdd(tokens,safeDiv(safeMul(tokens,disc),100));
   	return tokens;
   }

   function() external payable stopInEmergency{
   	// Abort if not in Funding Active state.
   	if(getState() == State.Success) throw;
   	if (msg.value == 0) throw;
   	uint256 newCreatedTokens = safeMul(msg.value,tokensPerEther);
   	newCreatedTokens = calNewTokens(newCreatedTokens);
   	///since we are creating tokens we need to increase the total supply
   	initialSupply = safeAdd(initialSupply,newCreatedTokens);
   	if(initialSupply>tokenCreationMax) throw;
      if (balances[msg.sender] == 0) investors.push(msg.sender);
      investmentETH += msg.value;
      balances[msg.sender] = safeAdd(balances[msg.sender],newCreatedTokens);
      // Pocket the money
      if(!wallet.send(msg.value)) throw;
   }


   ///token distribution initial function for the one in the exchanges
   ///to be done only the owner can run this function
   function tokenAssignExchange(address addr,uint256 val)
   external
   stopInEmergency
   onlyOwner()
   {
   	if(getState() == State.Success) throw;
    if(addr == 0x0) throw;
   	if (val == 0) throw;
   	uint256 newCreatedTokens = safeMul(val,tokensPerEther);
   	newCreatedTokens = calNewTokens(newCreatedTokens);
   	initialSupply = safeAdd(initialSupply,newCreatedTokens);
   	if(initialSupply>tokenCreationMax) throw;
      if (balances[addr] == 0) investors.push(addr);
      investmentETH += val;
      balances[addr] = safeAdd(balances[addr],newCreatedTokens);
   }

   ///function to run when the transaction has been veified
   function processTransaction(bytes txn, uint256 txHash,address addr,bytes20 btcaddr)
   external
   stopInEmergency
   onlyOwner()
   returns (uint)
   {
   	if(getState() == State.Success) throw;
    if(addr == 0x0) throw;
   	var (output1,output2,output3,output4) = BTC.getFirstTwoOutputs(txn);
      if(transactionsClaimed[txHash]) throw;
      var (a,b) = BTC.checkValueSent(txn,btcaddr,minBtcValue);
      if(a){
         transactionsClaimed[txHash] = true;
         uint256 newCreatedTokens = safeMul(b,tokensPerBTC);
         ///since we are creating tokens we need to increase the total supply
         newCreatedTokens = calNewTokens(newCreatedTokens);
         initialSupply = safeAdd(initialSupply,newCreatedTokens);
         ///remember not to go off the LIMITS!!
         if(initialSupply>tokenCreationMax) throw;
         if (balances[addr] == 0) investors.push(addr);
         investmentBTC += b;
         balances[addr] = safeAdd(balances[addr],newCreatedTokens);
         return 1;
      }
      else return 0;
   }

   ///change exchange rate ~ update price everyday
   function changeExchangeRate(uint256 eth, uint256 btc)
   external
   onlyOwner()
   {
     if(eth == 0 || btc == 0) throw;
     tokensPerEther = eth;
     tokensPerBTC = btc;
  }

  ///blacklist the users which are fraudulent
  ///from getting any tokens
  ///to do also refund just in cases
  function blacklist(address addr)
  external
  onlyOwner()
  {
     balances[addr] = 0;
  }

}