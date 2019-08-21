/*
   Copyright 2016 Nexus Development, LLC

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

pragma solidity ^0.4.2;

// Token standard API
// https://github.com/ethereum/EIPs/issues/20

contract ERC20Constant {
    function totalSupply() constant returns (uint supply);
    function balanceOf( address who ) constant returns (uint value);
    function allowance(address owner, address spender) constant returns (uint _allowance);
}
contract ERC20Stateful {
    function transfer( address to, uint value) returns (bool ok);
    function transferFrom( address from, address to, uint value) returns (bool ok);
    function approve(address spender, uint value) returns (bool ok);
}
contract ERC20Events {
    event Transfer(address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}
contract ERC20 is ERC20Constant, ERC20Stateful, ERC20Events {}

contract ERC20Base is ERC20
{
    mapping( address => uint ) _balances;
    mapping( address => mapping( address => uint ) ) _approvals;
    uint _supply;
    function ERC20Base( uint initial_balance ) {
        _balances[msg.sender] = initial_balance;
        _supply = initial_balance;
    }
    function totalSupply() constant returns (uint supply) {
        return _supply;
    }
    function balanceOf( address who ) constant returns (uint value) {
        return _balances[who];
    }
    function transfer( address to, uint value) returns (bool ok) {
        if( _balances[msg.sender] < value ) {
            throw;
        }
        if( !safeToAdd(_balances[to], value) ) {
            throw;
        }
        _balances[msg.sender] -= value;
        _balances[to] += value;
        Transfer( msg.sender, to, value );
        return true;
    }
    function transferFrom( address from, address to, uint value) returns (bool ok) {
        // if you don't have enough balance, throw
        if( _balances[from] < value ) {
            throw;
        }
        // if you don't have approval, throw
        if( _approvals[from][msg.sender] < value ) {
            throw;
        }
        if( !safeToAdd(_balances[to], value) ) {
            throw;
        }
        // transfer and return true
        _approvals[from][msg.sender] -= value;
        _balances[from] -= value;
        _balances[to] += value;
        Transfer( from, to, value );
        return true;
    }
    function approve(address spender, uint value) returns (bool ok) {
        _approvals[msg.sender][spender] = value;
        Approval( msg.sender, spender, value );
        return true;
    }
    function allowance(address owner, address spender) constant returns (uint _allowance) {
        return _approvals[owner][spender];
    }
    function safeToAdd(uint a, uint b) internal returns (bool) {
        return (a + b >= a);
    }
}

contract ReducedToken {
    function balanceOf(address _owner) returns (uint256);
    function transfer(address _to, uint256 _value) returns (bool);
    function migrate(uint256 _value);
}

contract DepositBrokerInterface {
    function clear();
}

contract TokenWrapperInterface is ERC20 {
    function withdraw(uint amount);

    // NO deposit, must be done via broker! Sorry!
    function createBroker() returns (DepositBrokerInterface);

    // broker contracts only - transfer to a personal broker then use `clear`
    function notifyDeposit(uint amount);

    function getBroker(address owner) returns (DepositBrokerInterface);
}

contract DepositBroker is DepositBrokerInterface {
    ReducedToken _g;
    TokenWrapperInterface _w;
    function DepositBroker( ReducedToken token ) {
        _w = TokenWrapperInterface(msg.sender);
        _g = token;
    }
    function clear() {
        var amount = _g.balanceOf(this);
        _g.transfer(_w, amount);
        _w.notifyDeposit(amount);
    }
}

contract TokenWrapperEvents {
    event LogBroker(address indexed broker);
}

// Deposits only accepted via broker!
contract TokenWrapper is ERC20Base(0), TokenWrapperInterface, TokenWrapperEvents {
    ReducedToken _unwrapped;
    mapping(address=>address) _broker2owner;
    mapping(address=>address) _owner2broker;
    function TokenWrapper( ReducedToken unwrapped) {
        _unwrapped = unwrapped;
    }
    function createBroker() returns (DepositBrokerInterface) {
        DepositBroker broker;
        if( _owner2broker[msg.sender] == address(0) ) {
            broker = new DepositBroker(_unwrapped);
            _broker2owner[broker] = msg.sender;
            _owner2broker[msg.sender] = broker;
            LogBroker(broker);
        }
        else {
            broker = DepositBroker(_owner2broker[msg.sender]);
        }
        
        return broker;
    }
    function notifyDeposit(uint amount) {
        var owner = _broker2owner[msg.sender];
        if( owner == address(0) ) {
            throw;
        }
        _balances[owner] += amount;
        _supply += amount;
    }
    function withdraw(uint amount) {
        if( _balances[msg.sender] < amount ) {
            throw;
        }
        _balances[msg.sender] -= amount;
        _supply -= amount;
        _unwrapped.transfer(msg.sender, amount);
    }
    function getBroker(address owner) returns (DepositBrokerInterface) {
        return DepositBroker(_owner2broker[msg.sender]);
    }
}