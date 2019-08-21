/* Simple token - simple token for PreICO and ICO
   Copyright (C) 2017  Sergey Sherkunov <leinlawun@leinlawun.org>
   Copyright (C) 2017  OOM.AG <info@oom.ag>

   This file is part of simple token.

   Token is free software: you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation, either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <https://www.gnu.org/licenses/>.  */

pragma solidity ^0.4.18;

library SafeMath {
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;

        assert(c >= a);
    }

    function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
        assert(b <= a);

        c = a - b;
    }

    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a * b;

        assert(c / a == b);
    }

    function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a / b;
    }

    function mod(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a % b;
    }

    function min(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a;

        if(a > b)
           c = b;
    }
}

contract ABXToken {
    using SafeMath for uint256;

    address public owner;

    address public minter;

    string public name;

    string public symbol;

    uint8 public decimals;

    uint256 public totalSupply;

    mapping(address => uint256) public balanceOf;

    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed oldTokensHolder,
                   address indexed newTokensHolder, uint256 tokensNumber);

    //An Attack Vector on Approve/TransferFrom Methods:
    //https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    event Transfer(address indexed tokensSpender,
                   address indexed oldTokensHolder,
                   address indexed newTokensHolder, uint256 tokensNumber);

    event Approval(address indexed tokensHolder, address indexed tokensSpender,
                   uint256 newTokensNumber);

    //An Attack Vector on Approve/TransferFrom Methods:
    //https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    event Approval(address indexed tokensHolder, address indexed tokensSpender,
                   uint256 oldTokensNumber, uint256 newTokensNumber);

    modifier onlyOwner {
        require(owner == msg.sender);

        _;
    }

    //ERC20 Short Address Attack:
    //https://vessenes.com/the-erc20-short-address-attack-explained
    //https://blog.golemproject.net/how-to-find-10m-by-just-reading-blockchain-6ae9d39fcd95
    //https://ericrafaloff.com/analyzing-the-erc20-short-address-attack
    modifier checkPayloadSize(uint256 size) {
        require(msg.data.length == size + 4);

        _;
    }

    modifier onlyNotNullTokenHolder(address tokenHolder) {
        require(tokenHolder != address(0));

        _;
    }

    function ABXToken(string _name, string _symbol, uint8 _decimals,
                      uint256 _totalSupply) public {
        owner = msg.sender;
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
        totalSupply = _totalSupply.mul(10 ** uint256(decimals));

        require(decimals <= 77);

        balanceOf[this] = totalSupply;
    }

    function setOwner(address _owner) public onlyOwner returns(bool) {
        owner = _owner;

        return true;
    }

    function setMinter(address _minter) public onlyOwner returns(bool) {
        safeApprove(this, minter, 0);

        minter = _minter;

        safeApprove(this, minter, balanceOf[this]);

        return true;
    }

    //ERC20 Short Address Attack:
    //https://vessenes.com/the-erc20-short-address-attack-explained
    //https://blog.golemproject.net/how-to-find-10m-by-just-reading-blockchain-6ae9d39fcd95
    //https://ericrafaloff.com/analyzing-the-erc20-short-address-attack
    function transfer(address newTokensHolder, uint256 tokensNumber) public
                     checkPayloadSize(2 * 32) returns(bool) {
        transfer(msg.sender, newTokensHolder, tokensNumber);

        return true;
    }

    //An Attack Vector on Approve/TransferFrom Methods:
    //https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    //
    //ERC20 Short Address Attack:
    //https://vessenes.com/the-erc20-short-address-attack-explained
    //https://blog.golemproject.net/how-to-find-10m-by-just-reading-blockchain-6ae9d39fcd95
    //https://ericrafaloff.com/analyzing-the-erc20-short-address-attack
    function transferFrom(address oldTokensHolder, address newTokensHolder,
                          uint256 tokensNumber) public checkPayloadSize(3 * 32)
                         returns(bool) {
        allowance[oldTokensHolder][msg.sender] =
            allowance[oldTokensHolder][msg.sender].sub(tokensNumber);

        transfer(oldTokensHolder, newTokensHolder, tokensNumber);

        Transfer(msg.sender, oldTokensHolder, newTokensHolder, tokensNumber);

        return true;
    }

    //ERC20 Short Address Attack:
    //https://vessenes.com/the-erc20-short-address-attack-explained
    //https://blog.golemproject.net/how-to-find-10m-by-just-reading-blockchain-6ae9d39fcd95
    //https://ericrafaloff.com/analyzing-the-erc20-short-address-attack
    function approve(address tokensSpender, uint256 newTokensNumber) public
                    checkPayloadSize(2 * 32) returns(bool) {
        safeApprove(msg.sender, tokensSpender, newTokensNumber);

        return true;
    }

    //An Attack Vector on Approve/TransferFrom Methods:
    //https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    //
    //ERC20 Short Address Attack:
    //https://vessenes.com/the-erc20-short-address-attack-explained
    //https://blog.golemproject.net/how-to-find-10m-by-just-reading-blockchain-6ae9d39fcd95
    //https://ericrafaloff.com/analyzing-the-erc20-short-address-attack
    function approve(address tokensSpender, uint256 oldTokensNumber,
                     uint256 newTokensNumber) public checkPayloadSize(3 * 32)
                    returns(bool) {
        require(allowance[msg.sender][tokensSpender] == oldTokensNumber);

        unsafeApprove(msg.sender, tokensSpender, newTokensNumber);

        Approval(msg.sender, tokensSpender, oldTokensNumber, newTokensNumber);

        return true;
    }

    function transfer(address oldTokensHolder, address newTokensHolder,
                      uint256 tokensNumber) private
                      onlyNotNullTokenHolder(oldTokensHolder) {
        balanceOf[oldTokensHolder] =
            balanceOf[oldTokensHolder].sub(tokensNumber);

        balanceOf[newTokensHolder] =
            balanceOf[newTokensHolder].add(tokensNumber);

        Transfer(oldTokensHolder, newTokensHolder, tokensNumber);
    }

    //An Attack Vector on Approve/TransferFrom Methods:
    //https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    function unsafeApprove(address tokensHolder, address tokensSpender,
                           uint256 newTokensNumber) private
                          onlyNotNullTokenHolder(tokensHolder) {
        allowance[tokensHolder][tokensSpender] = newTokensNumber;

        Approval(msg.sender, tokensSpender, newTokensNumber);
    }
    
    //An Attack Vector on Approve/TransferFrom Methods:
    //https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    function safeApprove(address tokensHolder, address tokensSpender,
                         uint256 newTokensNumber) private {
        require(allowance[tokensHolder][tokensSpender] == 0 ||
                newTokensNumber == 0);

        unsafeApprove(tokensHolder, tokensSpender, newTokensNumber);
    }
}

contract Minter {
    using SafeMath for uint256;

    enum MinterState {
        tokenSaleWait,
        tokenSaleStarted,
        Over
    }

    struct Tokensale {
        uint256 startTime;
        uint256 endTime;
        uint256 tokensMinimumNumberForBuy;
        uint256 tokensCost;
    }

    address public owner;

    address public manager;

    bool public paused = false;

    mapping(address => bool) public whiteList;

    ABXToken public token;

    Tokensale public tokenSale;

    modifier onlyOwner {
        require(owner == msg.sender);

        _;
    }

    modifier onlyNotPaused {
        require(!paused);

        _;
    }

    modifier onlyDuringTokensale {
        require(minterState() == MinterState.tokenSaleStarted);

        _;
    }

    modifier onlyAfterTokensaleOver {
        require(minterState() == MinterState.Over);

        _;
    }

    modifier onlyWhiteList {
        require(whiteList[msg.sender]);

        _;
    }

    modifier checkLimitsToBuyTokens {
        require(tokenSale.tokensMinimumNumberForBuy <=
                tokensNumberForBuy().div(10 ** uint256(token.decimals())));

        _;
    }

    function Minter(address _manager, ABXToken _token,
                    uint256 tokenSaleStartTime, uint256 tokenSaleEndTime,
                    uint256 tokenSaleTokensMinimumNumberForBuy) public {
        owner = msg.sender;
        manager = _manager;
        token = _token;
        tokenSale.startTime = tokenSaleStartTime;
        tokenSale.endTime = tokenSaleEndTime;
        tokenSale.tokensMinimumNumberForBuy =
            tokenSaleTokensMinimumNumberForBuy;
    }

    function setOwner(address _owner) public onlyOwner {
        owner = _owner;
    }

    function setManager(address _manager) public onlyOwner {
        manager = _manager;
    }

    function setPaused(bool _paused) public onlyOwner {
        paused = _paused;
    }

    function addWhiteList(address tokensHolder) public onlyOwner {
        whiteList[tokensHolder] = true;
    }

    function removeWhiteList(address tokensHolder) public onlyOwner {
        whiteList[tokensHolder] = false;
    }

    function setTokenSaleStartTime(uint256 timestamp) public onlyOwner {
        tokenSale.startTime = timestamp;
    }

    function setTokenSaleEndTime(uint256 timestamp) public onlyOwner {
        tokenSale.endTime = timestamp;
    }

    function setTokenSaleTokensMinimumNumberForBuy(uint256 tokensNumber) public
                                               onlyOwner {
        tokenSale.tokensMinimumNumberForBuy = tokensNumber;
    }

    function setTokenSaleTokensCost(uint256 tokensCost) public onlyOwner {
        tokenSale.tokensCost = tokensCost;
    }

    function transferRestTokensToOwner() public onlyOwner
                                      onlyAfterTokensaleOver {
        token.transferFrom(token, msg.sender, token.allowance(token, this));
    }

    function () public payable onlyDuringTokensale onlyNotPaused onlyWhiteList
                checkLimitsToBuyTokens {
        uint256 tokensNumber = tokensNumberForBuy();

        uint256 aviableTokensNumber =
            token.balanceOf(token).min(token.allowance(token, this));

        uint256 restCoins = 0;

        if(tokensNumber >= aviableTokensNumber) {
            uint256 restTokensNumber = tokensNumber.sub(aviableTokensNumber);

            restCoins =
                restTokensNumber.mul(tokenSale.tokensCost)
                                .div(10 ** uint256(token.decimals()));

            tokensNumber = aviableTokensNumber;
        }

        token.transferFrom(token, msg.sender, tokensNumber);

        msg.sender.transfer(restCoins);

        manager.transfer(msg.value.sub(restCoins));
    }

    function minterState() private constant returns(MinterState) {
        if(tokenSale.startTime > now) {
            return MinterState.tokenSaleWait;
        } else if(tokenSale.endTime > now) {
            return MinterState.tokenSaleStarted;
        } else {
            return MinterState.Over;
        }
    }

    function tokensNumberForBuy() private constant returns(uint256) {
        return msg.value.mul(10 ** uint256(token.decimals()))
                        .div(tokenSale.tokensCost);
    }
}