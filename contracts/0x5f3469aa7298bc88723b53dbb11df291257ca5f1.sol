/* Token - simple token for PreICO and ICO
   Copyright (C) 2017  Sergey Sherkunov <leinlawun@leinlawun.org>

   This file is part of Token.

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

    assert (c >= a);
  }

  function sub(uint256 a, uint256 b) internal pure returns (uint256 c) {
    assert(b <= a);

    c = a - b;
  }

  function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a * b;

    assert (c / a == b);
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256 c) {
    c = a / b;
  }
}

contract ERC20MintableToken {
  using SafeMath for uint256;

  address public owner;

  Minter public minter;

  string constant public name = "PayAll";

  string constant public symbol = "PLL";

  uint8 constant public decimals = 0;

  uint256 public totalSupply;

  mapping (address => uint256) public balanceOf;

  mapping (address => mapping (address => uint256)) public allowance;

  event Transfer(address indexed _oldTokensHolder,
                 address indexed _newTokensHolder, uint256 _tokensNumber);

  //https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  event Transfer(address indexed _tokensSpender,
                 address indexed _oldTokensHolder,
                 address indexed _newTokensHolder, uint256 _tokensNumber);

  event Approval(address indexed _tokensHolder, address indexed _tokensSpender,
                 uint256 _newTokensNumber);

  //https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  event Approval(address indexed _tokensHolder, address indexed _tokensSpender,
                 uint256 _oldTokensNumber, uint256 _newTokensNumber);

  modifier onlyOwner {
    require (owner == msg.sender);

    _;
  }

  modifier onlyMinter {
    require (minter == msg.sender);

    _;
  }

  //https://vessenes.com/the-erc20-short-address-attack-explained
  //https://blog.golemproject.net/how-to-find-10m-by-just-reading-blockchain-6ae9d39fcd95
  //https://ericrafaloff.com/analyzing-the-erc20-short-address-attack
  modifier checkPayloadSize(uint256 size) {
     require (msg.data.length == size + 4);

     _;
  }

  function setOwner(address _owner) public onlyOwner {
    uint256 _allowance = allowance[this][owner];

    _approve(this, owner, 0);

    owner = _owner;

    _approve(this, owner, _allowance);
  }

  function setMinter(Minter _minter) public onlyOwner {
    uint256 _allowance = allowance[this][minter];

    _approve(this, minter, 0);

    minter = _minter;

    _approve(this, minter, _allowance);
  }

  function ERC20MintableToken(Minter _minter) public {
    owner = tx.origin;
    minter = _minter;
  }

  function _transfer(address _oldTokensHolder, address _newTokensHolder,
                     uint256 _tokensNumber) private {
    balanceOf[_oldTokensHolder] =
      balanceOf[_oldTokensHolder].sub(_tokensNumber);

    balanceOf[_newTokensHolder] =
      balanceOf[_newTokensHolder].add(_tokensNumber);

    Transfer(_oldTokensHolder, _newTokensHolder, _tokensNumber);
  }

  //https://vessenes.com/the-erc20-short-address-attack-explained
  //https://blog.golemproject.net/how-to-find-10m-by-just-reading-blockchain-6ae9d39fcd95
  //https://ericrafaloff.com/analyzing-the-erc20-short-address-attack
  function transfer(address _newTokensHolder, uint256 _tokensNumber) public
                   checkPayloadSize(2 * 32) returns (bool) {
    _transfer(msg.sender, _newTokensHolder, _tokensNumber);

    return true;
  }

  //https://vessenes.com/the-erc20-short-address-attack-explained
  //https://blog.golemproject.net/how-to-find-10m-by-just-reading-blockchain-6ae9d39fcd95
  //https://ericrafaloff.com/analyzing-the-erc20-short-address-attack
  //https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  function transferFrom(address _oldTokensHolder, address _newTokensHolder,
                        uint256 _tokensNumber) public checkPayloadSize(3 * 32)
                       returns (bool) {
    allowance[_oldTokensHolder][msg.sender] =
      allowance[_oldTokensHolder][msg.sender].sub(_tokensNumber);

    _transfer(_oldTokensHolder, _newTokensHolder, _tokensNumber);

    Transfer(msg.sender, _oldTokensHolder, _newTokensHolder, _tokensNumber);

    return true;
  }

  function _approve(address _tokensHolder, address _tokensSpender,
                    uint256 _newTokensNumber) private {
    allowance[_tokensHolder][_tokensSpender] = _newTokensNumber;

    Approval(msg.sender, _tokensSpender, _newTokensNumber);
  }

  //https://vessenes.com/the-erc20-short-address-attack-explained
  //https://blog.golemproject.net/how-to-find-10m-by-just-reading-blockchain-6ae9d39fcd95
  //https://ericrafaloff.com/analyzing-the-erc20-short-address-attack
  //https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  function approve(address _tokensSpender, uint256 _newTokensNumber) public
                  checkPayloadSize(2 * 32) returns (bool) {
    require (allowance[msg.sender][_tokensSpender] == 0 ||
             _newTokensNumber == 0);

    _approve(msg.sender, _tokensSpender, _newTokensNumber);

    return true;
  }

  //https://vessenes.com/the-erc20-short-address-attack-explained
  //https://blog.golemproject.net/how-to-find-10m-by-just-reading-blockchain-6ae9d39fcd95
  //https://ericrafaloff.com/analyzing-the-erc20-short-address-attack
  //https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
  function approve(address _tokensSpender, uint256 _oldTokensNumber,
                   uint256 _newTokensNumber) public checkPayloadSize(3 * 32)
                  returns (bool) {
    require (allowance[msg.sender][_tokensSpender] == _oldTokensNumber);

    _approve(msg.sender, _tokensSpender, _newTokensNumber);

    Approval(msg.sender, _tokensSpender, _oldTokensNumber, _newTokensNumber);

    return true;
  }

  function () public {
    revert();
  }

  function mint(uint256 _tokensNumber) public onlyMinter {
    totalSupply = totalSupply.add(_tokensNumber);

    balanceOf[this] = balanceOf[this].add(_tokensNumber);

    uint256 _allowance = allowance[this][msg.sender].add(_tokensNumber);

    _approve(this, minter, _allowance);

    _approve(this, owner, _allowance);
  }

  function burnUndistributed() public onlyMinter {
    _approve(this, minter, 0);

    _approve(this, owner, 0);

    totalSupply = totalSupply.sub(balanceOf[this]);

    balanceOf[this] = 0;
  }
}

contract Minter {
  using SafeMath for uint256;

  enum MinterState {
    PreICOWait,
    PreICOStarted,
    ICOWait,
    ICOStarted,
    Over
  }

  struct Tokensale {
    uint256 startTime;
    uint256 endTime;
    uint256 tokensMinimumNumberForBuy;
    uint256 tokensCost;
    uint256 tokensNumberForMint;
    bool tokensMinted;
    uint256 tokensStepOneBountyTime;
    uint256 tokensStepTwoBountyTime;
    uint256 tokensStepThreeBountyTime;
    uint256 tokensStepFourBountyTime;
    uint8 tokensStepOneBounty;
    uint8 tokensStepTwoBounty;
    uint8 tokensStepThreeBounty;
    uint8 tokensStepFourBounty;
  }

  address public owner;

  ERC20MintableToken public token;

  Tokensale public PreICO =
    Tokensale(1511193600, 1513785600, 150, 340000000000000 wei, 10000000, false,
              1 weeks, 2 weeks, 3 weeks, 4 weeks + 2 days, 25, 15, 10, 5);

  Tokensale public ICO =
    Tokensale(1526828400, 1529506800, 150, 340000000000000 wei, 290000000,
              false, 1 weeks, 2 weeks, 3 weeks, 4 weeks + 3 days, 20, 10, 5, 0);

  bool public paused = false;

  modifier onlyOwner {
    require (owner == msg.sender);

    _;
  }

  modifier onlyDuringTokensale {
    MinterState _minterState_ = _minterState();

    require (_minterState_ == MinterState.PreICOStarted ||
             _minterState_ == MinterState.ICOStarted);

    _;
  }

  modifier onlyAfterTokensaleOver {
    MinterState _minterState_ = _minterState();

    require (_minterState_ == MinterState.Over);

    _;
  }

  modifier onlyNotPaused {
    require (!paused);

    _;
  }

  modifier checkLimitsToBuyTokens {
    MinterState _minterState_ = _minterState();

    require (_minterState_ == MinterState.PreICOStarted &&
             PreICO.tokensMinimumNumberForBuy <= msg.value / PreICO.tokensCost ||
             _minterState_ == MinterState.ICOStarted &&
             ICO.tokensMinimumNumberForBuy <= msg.value / ICO.tokensCost);

    _;
  }

  function setOwner(address _owner) public onlyOwner {
    owner = _owner;
  }

  function setPaused(bool _paused) public onlyOwner {
    paused = _paused;
  }

  function Minter() public {
    owner = msg.sender;
    token = new ERC20MintableToken(this);
  }

  function _minterState() private constant returns (MinterState) {
    if (PreICO.startTime > now) {
      return MinterState.PreICOWait;
    } else if (PreICO.endTime > now) {
      return MinterState.PreICOStarted;
    } else if (ICO.startTime > now) {
      return MinterState.ICOWait;
    } else if (ICO.endTime > now) {
      return MinterState.ICOStarted;
    } else {
      return MinterState.Over;
    }
  }

  function _tokensaleCountTokensNumber(Tokensale _tokensale, uint256 _timestamp,
                                       uint256 _wei, uint256 _totalTokensNumber,
                                       uint256 _totalTokensNumberAllowance)
                                      private pure
                                      returns (uint256, uint256) {
    uint256 _tokensNumber = _wei.div(_tokensale.tokensCost);

    require (_tokensNumber >= _tokensale.tokensMinimumNumberForBuy);

    uint256 _aviableTokensNumber =
      _totalTokensNumber <= _totalTokensNumberAllowance ?
        _totalTokensNumber : _totalTokensNumberAllowance;

    uint256 _restWei = 0;

    if (_tokensNumber >= _aviableTokensNumber) {
      uint256 _restTokensNumber = _tokensNumber.sub(_aviableTokensNumber);

      _restWei = _restTokensNumber.mul(_tokensale.tokensCost);

      _tokensNumber = _aviableTokensNumber;
    } else {
      uint256 _timePassed = _timestamp.sub(_tokensale.startTime);

      uint256 _tokensNumberBounty = 0;

      if (_timePassed < _tokensale.tokensStepOneBountyTime) {
        _tokensNumberBounty = _tokensNumber.mul(_tokensale.tokensStepOneBounty)
                                           .div(100);
      } else if (_timePassed < _tokensale.tokensStepTwoBountyTime) {
        _tokensNumberBounty = _tokensNumber.mul(_tokensale.tokensStepTwoBounty)
                                           .div(100);
      } else if (_timePassed < _tokensale.tokensStepThreeBountyTime) {
        _tokensNumberBounty =
          _tokensNumber.mul(_tokensale.tokensStepThreeBounty).div(100);
      } else if (_timePassed < _tokensale.tokensStepFourBountyTime) {
        _tokensNumberBounty = _tokensNumber.mul(_tokensale.tokensStepFourBounty)
                                           .div(100);
      }

      _tokensNumber = _tokensNumber.add(_tokensNumberBounty);

      if (_tokensNumber > _aviableTokensNumber) {
        _tokensNumber = _aviableTokensNumber;
      }
    }

    return (_tokensNumber, _restWei);
  }

  function _tokensaleStart(Tokensale storage _tokensale) private {
    if (!_tokensale.tokensMinted) {
      token.mint(_tokensale.tokensNumberForMint);

      _tokensale.tokensMinted = true;
    }

    uint256 _totalTokensNumber = token.balanceOf(token);

    uint256 _totalTokensNumberAllowance = token.allowance(token, this);

    var (_tokensNumber, _restWei) =
      _tokensaleCountTokensNumber(_tokensale, now, msg.value,
                                  _totalTokensNumber,
                                  _totalTokensNumberAllowance);

    token.transferFrom(token, msg.sender, _tokensNumber);

    if (_restWei > 0) {
      msg.sender.transfer(_restWei);
    }
  }

  function _tokensaleSelect() private constant returns (Tokensale storage) {
    MinterState _minterState_ = _minterState();

    if (_minterState_ == MinterState.PreICOStarted) {
      return PreICO;
    } else if (_minterState_ == MinterState.ICOStarted) {
      return ICO;
    } else {
      revert();
    }
  }

  function () public payable onlyDuringTokensale onlyNotPaused
    checkLimitsToBuyTokens {
    Tokensale storage _tokensale = _tokensaleSelect();

    _tokensaleStart(_tokensale);
  }

  function mint(uint256 _tokensNumber) public onlyOwner onlyDuringTokensale {
    token.mint(_tokensNumber);
  }

  function burnUndistributed() public onlyAfterTokensaleOver {
    token.burnUndistributed();
  }

  function withdraw() public onlyOwner {
    msg.sender.transfer(this.balance);
  }
}