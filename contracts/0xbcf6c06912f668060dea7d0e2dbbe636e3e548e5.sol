/*! airdrop.sol | (c) 2018 BelovITLab LLC | License: MIT */
//
//       ▄▄███████▄▄                                                                                                                             
//    ▄██▀▀        ▀▀█▄                                                                                                                          
//   ██  ▄▄▄     ▄▄   ▀█▄                                                                                                                        
//  █▀  █▌ ▐█  ▐█  █    █▄       ▐█▌       ▄█▌      ██▌      ▐███████▄    █▌    ▄█▀       ▄██████▄   ███████▄      ▄██        ▄██████▄  ▐███████▌
// ██    █▄██   █▄█▀    ▐█       ▐███     ███▌     ██ █▌     ▐█▌    ▐█▌   ██  ▄██         ██         ██     ██    ██ ██     ▄█▀         ▐█▌      
// █▌     ▀█    ██       █       ▐█▌▀█▄  ██▐█▌    ██   █▌    ▐█▌   ▄██▀   █████           ▀█████▄    ██   ▄▄██   ██   ██    ██          ▐███████ 
// ██     █▀█▄ █▀█▌     ▐█       ▐█▌  ███▀ ▐█▌   ████████▌   ▐███████     ██▀ ▀██               ██   █████▀▀    █████████   ██▄         ▐█▌      
//  █▄   ▐█  ▀█  ▐█     █▀       ▐█▌   ▀   ▐█▌  ██       ██  ▐█▌    ██    ██    ▀██  ██   ███████▀   ██        ██       ██   ▀▀██████▀  ▐███████ 
//   ██               ▄█▀                                                                                                                        
//    ▀▀█▄▄        ▄██▀                                                                                                                          
//        ▀███████▀▀                                                                                                                             

pragma solidity 0.4.18;

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    modifier onlyOwner() { require(msg.sender == owner); _; }

    function Ownable() public {
        owner = msg.sender;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        owner = newOwner;
        OwnershipTransferred(owner, newOwner);
    }
}

contract Withdrawable is Ownable {
    function withdrawEther(address _to, uint _value) onlyOwner public returns(bool) {
        require(_to != address(0));
        require(this.balance >= _value);

        _to.transfer(_value);

        return true;
    }

    function withdrawTokens(ERC20 _token, address _to, uint _value) onlyOwner public returns(bool) {
        require(_to != address(0));

        return _token.transfer(_to, _value);
    }
}

contract ERC20 {
    uint256 public totalSupply;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);

    function balanceOf(address who) public view returns(uint256);
    function transfer(address to, uint256 value) public returns(bool);
    function transferFrom(address from, address to, uint256 value) public returns(bool);
    function allowance(address owner, address spender) public view returns(uint256);
    function approve(address spender, uint256 value) public returns(bool);
}

contract AirDrop is Withdrawable {
    event TransferEther(address indexed to, uint256 value);

    function tokenBalanceOf(ERC20 _token) public view returns(uint256) {
        return _token.balanceOf(this);
    }

    function tokenAllowance(ERC20 _token, address spender) public view returns(uint256) {
        return _token.allowance(this, spender);
    }
    
    function tokenTransfer(ERC20 _token, uint _value, address[] _to) onlyOwner public {
        require(_token != address(0));

        for(uint i = 0; i < _to.length; i++) {
            require(_token.transfer(_to[i], _value));
        }
    }
    
    function tokenTransferFrom(ERC20 _token, address spender, uint _value, address[] _to) onlyOwner public {
        require(_token != address(0));

        for(uint i = 0; i < _to.length; i++) {
            require(_token.transferFrom(spender, _to[i], _value));
        }
    }

    function etherTransfer(uint _value, address[] _to) onlyOwner payable public {
        for(uint i = 0; i < _to.length; i++) {
            _to[i].transfer(_value);
            TransferEther(_to[i], _value);
        }
    }
}