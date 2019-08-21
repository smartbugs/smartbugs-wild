pragma solidity ^0.4.6;
/*
    Copyright 2017, Vojtech Simetka

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/// @title Donation Doubler
/// @authors Vojtech Simetka, Jordi Baylina, Dani Philia
/// @notice This contract is used to double a donation to a Giveth Campaign as
///  long as there is enough ether in this contract to do it. If not, the
///  donated value is just sent directly to designated Campaign with any ether
///  that may still be in this contract. The `msg.sender` doubling their
///  donation will receive twice the expected Campaign tokens and the Donor that
///  deposited the inital funds will not receive any donation tokens. 
///  WARNING: This contract only works for ether. A token based contract will be
///  developed in the future. Any tokens sent to this contract will be lost.
///  Next Version: Upgrade the EscapeHatch to be able to remove tokens.


/// @dev `Owned` is a base level contract that assigns an `owner` that can be
///  later changed

// Copyright (C) 2015, 2016, 2017  DappHub, LLC

// Licensed under the Apache License, Version 2.0 (the "License").
// You may not use this file except in compliance with the License.

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND (express or implied).
// 
// Thank you to @zandy and the Dappsys team for writing this beautiful library
// Their math.sol was modified to remove and rename functions and add many
// comments for clarification.
// See their original library here: https://github.com/dapphub/ds-math
//
// Also the OpenZepplin team deserves gratitude and recognition for making
// their own beautiful library which has been very well utilized in solidity
// contracts across the Ethereum ecosystem and we used their max64(), min64(),
// multiply(), and divide() functions. See their library here:
// https://github.com/OpenZeppelin/zeppelin-solidity/blob/master/contracts/SafeMath.sol

pragma solidity ^0.4.6;

contract SafeMath {

    // ensure that the result of adding x and y is accurate 
    function add(uint x, uint y) internal constant returns (uint z) {
        assert( (z = x + y) >= x);
    }
 
    // ensure that the result of subtracting y from x is accurate 
    function subtract(uint x, uint y) internal constant returns (uint z) {
        assert( (z = x - y) <= x);
    }

    // ensure that the result of multiplying x and y is accurate 
    function multiply(uint x, uint y) internal constant returns (uint z) {
        z = x * y;
        assert(x == 0 || z / x == y);
        return z;
    }

    // ensure that the result of dividing x and y is accurate
    // note: Solidity now throws on division by zero, so a check is not needed
    function divide(uint x, uint y) internal constant returns (uint z) {
        z = x / y;
        assert(x == ( (y * z) + (x % y) ));
        return z;
    }
    
    // return the lowest of two 64 bit integers
    function min64(uint64 x, uint64 y) internal constant returns (uint64) {
      return x < y ? x: y;
    }
    
    // return the largest of two 64 bit integers
    function max64(uint64 x, uint64 y) internal constant returns (uint64) {
      return x >= y ? x : y;
    }

    // return the lowest of two values
    function min(uint x, uint y) internal constant returns (uint) {
        return (x <= y) ? x : y;
    }

    // return the largest of two values
    function max(uint x, uint y) internal constant returns (uint) {
        return (x >= y) ? x : y;
    }

    function assert(bool assertion) internal {
        if (!assertion) {
            throw;
        }
    }

}

contract Owned {
    /// @dev `owner` is the only address that can call a function with this
    /// modifier; the function body is inserted where the special symbol
    /// "_;" in the definition of a modifier appears.
    modifier onlyOwner { if (msg.sender != owner) throw; _; }

    address public owner;

    /// @notice The Constructor assigns the message sender to be `owner`
    function Owned() { owner = msg.sender;}

    /// @notice `owner` can step down and assign some other address to this role
    /// @param _newOwner The address of the new owner. 0x0 can be used to create
    ///  an unowned neutral vault, however that cannot be undone
    function changeOwner(address _newOwner) onlyOwner {
        owner = _newOwner;
        NewOwner(msg.sender, _newOwner);
    }
    
    /// @dev Events make it easier to see that something has happend on the
    ///   blockchain
    event NewOwner(address indexed oldOwner, address indexed newOwner);
}
/// @dev `Escapable` is a base level contract built off of the `Owned`
///  contract that creates an escape hatch function to send its ether to
///  `escapeHatchDestination` when called by the `escapeHatchCaller` in the case
///  that something unexpected happens
contract Escapable is Owned {
    address public escapeHatchCaller;
    address public escapeHatchDestination;

    /// @notice The Constructor assigns the `escapeHatchDestination` and the
    ///  `escapeHatchCaller`
    /// @param _escapeHatchDestination The address of a safe location (usu a
    ///  Multisig) to send the ether held in this contract
    /// @param _escapeHatchCaller The address of a trusted account or contract to
    ///  call `escapeHatch()` to send the ether in this contract to the
    ///  `escapeHatchDestination` it would be ideal that `escapeHatchCaller` cannot
    ///  move funds out of `escapeHatchDestination`
    function Escapable(address _escapeHatchCaller, address _escapeHatchDestination) {
        escapeHatchCaller = _escapeHatchCaller;
        escapeHatchDestination = _escapeHatchDestination;
    }

    /// @dev The addresses preassigned the `escapeHatchCaller` role
    ///  is the only addresses that can call a function with this modifier
    modifier onlyEscapeHatchCallerOrOwner {
        if ((msg.sender != escapeHatchCaller)&&(msg.sender != owner))
            throw;
        _;
    }

    /// @notice The `escapeHatch()` should only be called as a last resort if a
    /// security issue is uncovered or something unexpected happened
    function escapeHatch() onlyEscapeHatchCallerOrOwner {
        uint total = this.balance;
        // Send the total balance of this contract to the `escapeHatchDestination`
        if (!escapeHatchDestination.send(total)) {
            throw;
        }
        EscapeHatchCalled(total);
    }
    /// @notice Changes the address assigned to call `escapeHatch()`
    /// @param _newEscapeHatchCaller The address of a trusted account or contract to
    ///  call `escapeHatch()` to send the ether in this contract to the
    ///  `escapeHatchDestination` it would be ideal that `escapeHatchCaller` cannot
    ///  move funds out of `escapeHatchDestination`
    function changeEscapeCaller(address _newEscapeHatchCaller) onlyEscapeHatchCallerOrOwner {
        escapeHatchCaller = _newEscapeHatchCaller;
    }

    event EscapeHatchCalled(uint amount);
}

/// @dev This is an empty contract to declare `proxyPayment()` to comply with
///  Giveth Campaigns so that tokens will be generated when donations are sent
contract Campaign {

    /// @notice `proxyPayment()` allows the caller to send ether to the Campaign and
    /// have the tokens created in an address of their choosing
    /// @param _owner The address that will hold the newly created tokens
    function proxyPayment(address _owner) payable returns(bool);
}

/// @dev Finally! The main contract which doubles the amount donated.
contract DonationDoubler is Escapable, SafeMath {
    Campaign public beneficiary; // expected to be a Giveth campaign

    /// @notice The Constructor assigns the `beneficiary`, the
    ///  `escapeHatchDestination` and the `escapeHatchCaller` as well as deploys
    ///  the contract to the blockchain (obviously)
    /// @param _beneficiary The address of the CAMPAIGN CONTROLLER for the Campaign
    ///  that is to receive donations
    /// @param _escapeHatchDestination The address of a safe location (usually a
    ///  Multisig) to send the ether held in this contract
    /// @param _escapeHatchCaller The address of a trusted account or contract
    ///  to call `escapeHatch()` to send the ether in this contract to the 
    ///  `escapeHatchDestination` it would be ideal that `escapeHatchCaller`
    ///  cannot move funds out of `escapeHatchDestination`
    function DonationDoubler(
            Campaign _beneficiary,
            // person or legal entity that receives money or other benefits from a benefactor
            address _escapeHatchCaller,
            address _escapeHatchDestination
        )
        Escapable(_escapeHatchCaller, _escapeHatchDestination)
    {
        beneficiary = _beneficiary;
    }

    /// @notice Simple function to deposit more ETH to Double Donations
    function depositETH() payable {
        DonationDeposited4Doubling(msg.sender, msg.value);
    }

    /// @notice Donate ETH to the `beneficiary`, and if there is enough in the 
    ///  contract double it. The `msg.sender` is rewarded with Campaign tokens
    // depending on how one calls into this fallback function, i.e. with .send ( hard limit of 2300 gas ) vs .value (provides fallback with all the available gas of the caller), it may throw
    function () payable {
        uint amount;

        // When there is enough ETH in the contract to double the ETH sent
        if (this.balance >= multiply(msg.value, 2)){
            amount = multiply(msg.value, 2); // do it two it!
            // Send the ETH to the beneficiary so that they receive Campaign tokens
            if (!beneficiary.proxyPayment.value(amount)(msg.sender))
                throw;
            DonationDoubled(msg.sender, amount);
        } else {
            amount = this.balance;
            // Send the ETH to the beneficiary so that they receive Campaign tokens
            if (!beneficiary.proxyPayment.value(amount)(msg.sender))
                throw;
            DonationSentButNotDoubled(msg.sender, amount);
        }
    }

    event DonationDeposited4Doubling(address indexed sender, uint amount);
    event DonationDoubled(address indexed sender, uint amount);
    event DonationSentButNotDoubled(address indexed sender, uint amount);
}