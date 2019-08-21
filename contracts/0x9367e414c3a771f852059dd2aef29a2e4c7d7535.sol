pragma solidity ^0.5.1;

contract ERC20Interface {
    function totalSupply() public view returns (uint256);
    function balanceOf(address tokenOwner) public view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);
    function transfer(address to, uint256 tokens) public returns (bool success);
    function approve(address spender, uint256 tokens) public returns (bool success);
    function transferFrom(address from, address to, uint256 tokens) public returns (bool success);
    function rise() public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint256 tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint256 tokens);
}


contract ERC20Proxy {
    function totalSupply() public view returns (uint256);
    function balanceOf(address tokenOwner) public view returns (uint256 balance);
    function allowance(address tokenOwner, address spender) public view returns (uint256 remaining);
    function transfer(address sender, address to, uint256 tokens) public returns (bool success);
    function approve(address sender, address spender, uint256 tokens) public returns (bool success);
    function transferFrom(address sender, address from, address to, uint256 tokens) public returns (bool success);
    function rise(address to) public returns (bool success);
}

contract SlaveEmitter {
    function emitTransfer(address _from, address _to, uint256 _value) public;
    function rememberMe(ERC20Proxy _multiAsset) public returns(bool success) ;
    function emitApprove(address _from, address _spender, uint256 _value) public;
    function emitTransfers(address _from, address[] memory dests, uint256[] memory values) public;
}

contract TorrentShares is ERC20Interface, SlaveEmitter {

    constructor() public {
        owner = msg.sender;
    }

    string public name = "Torrent Shares";
    string public symbol = "TOR";
    uint256 public decimals = 18;

    ERC20Proxy master = ERC20Proxy(address(0x0));
    address owner;

    modifier onlyMaster {
        assert( msg.sender == address(master) || msg.sender == owner);
        _;
    }

    function emitTransfer(address _from, address _to, uint256 _value) public onlyMaster() {
        emit Transfer(_from, _to, _value);
    }

    function transfer(address _to, uint256 _tokens) public returns (bool success) {
        return master.transfer(msg.sender, _to, _tokens);
    }

    function totalSupply() public view returns(uint256) {
        return master.totalSupply();
    }

    function rememberMe(ERC20Proxy _master) public returns(bool success) {
        require(msg.sender == owner || master == ERC20Proxy(0x0));
        master = _master;
        return true;
    }

    function allowance(address _from, address _spender) public view returns(uint256) {
        return master.allowance(_from, _spender);
    }


    function approve(address _spender, uint256 _tokens) public returns (bool success) {
        return master.approve(msg.sender, _spender, _tokens);
    }

    function transferFrom(address _from, address _to, uint256 _tokens) public returns (bool success) {
        return master.transferFrom(msg.sender, _from, _to, _tokens);
    }

    function balanceOf(address _owner) public view returns(uint256) {
        return master.balanceOf(_owner);
    }


    function emitApprove(address _from, address _spender, uint256 _value) public onlyMaster() {
        emit Approval(_from, _spender, _value);
    }

    function emitTransfers(address _from, address[] memory dests, uint256[] memory values) public onlyMaster() {
        for (uint i = 0; i < values.length; i++)
            emit Transfer(_from, dests[i], values[i]);
    }

    function () external payable {
        revert();
    }

    function rise() public onlyMaster() returns (bool success) {
        return master.rise(msg.sender);
    }

    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyMaster() returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}