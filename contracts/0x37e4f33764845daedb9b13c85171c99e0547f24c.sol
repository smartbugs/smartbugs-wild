// solhint-disable max-line-length
// @title A contract to store a list of messages. Obtainable as events.

/* Deployment:
Owner: 0x33a7ae7536d39032e16b0475aef6692a09727fe2
Owner Ropsten testnet: 0x4460f4c8edbca96f9db17ef95aaf329eddaeac29
Owner private testnet: 0x4460f4c8edbca96f9db17ef95aaf329eddaeac29
Address: 0x37e4f33764845daedb9b13c85171c99e0547f24c
Address Ropsten testnet: 0x93f28d717011771aaa0e462bd7ee5c43c98819f2
Address private testnet: 0x3fb4de9f7a4fe40f10f04bc347c11c5ad9094029
ABI: [{"constant":false,"inputs":[],"name":"kill","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[],"name":"flush","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":false,"inputs":[{"name":"_version","type":"uint256"},{"name":"_eventType","type":"uint16"},{"name":"_timeSpan","type":"uint256"},{"name":"_dataInfo","type":"string"}],"name":"add","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"owner","outputs":[{"name":"","type":"address"}],"payable":false,"stateMutability":"view","type":"function"},{"constant":false,"inputs":[{"name":"_tokenAddress","type":"address"}],"name":"flushToken","outputs":[],"payable":false,"stateMutability":"nonpayable","type":"function"},{"constant":true,"inputs":[],"name":"contentCount","outputs":[{"name":"","type":"uint256"}],"payable":false,"stateMutability":"view","type":"function"},{"inputs":[],"payable":false,"stateMutability":"nonpayable","type":"constructor"},{"payable":false,"stateMutability":"nonpayable","type":"fallback"},{"anonymous":false,"inputs":[{"indexed":true,"name":"version","type":"uint256"},{"indexed":true,"name":"sender","type":"address"},{"indexed":true,"name":"timePage","type":"uint256"},{"indexed":false,"name":"eventType","type":"uint16"},{"indexed":false,"name":"timeSpan","type":"uint256"},{"indexed":false,"name":"dataInfo","type":"string"}],"name":"LogStore","type":"event"}]
Optimized: yes
Solidity version: v0.4.24
*/

// solhint-enable max-line-length

pragma solidity 0.4.24;


contract MiniMeToken {

    /// @notice Send `_amount` tokens to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _amount) public returns (bool success);

    /// @notice Send `_amount` tokens to `_to` from `_from` on the condition it
    ///  is approved by `_from`
    /// @param _from The address holding the tokens being transferred
    /// @param _to The address of the recipient
    /// @param _amount The amount of tokens to be transferred
    /// @return True if the transfer was successful
    function transferFrom(address _from, address _to, uint256 _amount) public returns (bool success);

    /// @param _owner The address that's balance is being requested
    /// @return The balance of `_owner` at the current block
    function balanceOf(address _owner) public constant returns (uint256 balance);

    /// @notice `msg.sender` approves `_spender` to spend `_amount` tokens on
    ///  its behalf. This is a modified version of the ERC20 approve function
    ///  to be a little bit safer
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _amount The amount of tokens to be approved for transfer
    /// @return True if the approval was successful
    function approve(address _spender, uint256 _amount) public returns (bool success);
}


contract Store {

    //enum EventTypes
    uint16 constant internal NONE = 0;
    uint16 constant internal ADD = 1;
    uint16 constant internal CANCEL = 2;

    address public owner;
    uint public contentCount = 0;
    
    event LogStore(uint indexed version, address indexed sender, uint indexed timePage,
        uint16 eventType, uint timeSpan, string dataInfo);

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
    
    constructor() public {
        owner = msg.sender;
    }

    // @notice fallback function, don't allow call to it
    function () public {
        revert();
    }

    function kill() public onlyOwner {

        selfdestruct(owner);
    }

    function flush() public onlyOwner {

        if (!owner.send(address(this).balance))
            revert();
    }

    function flushToken(address _tokenAddress) public onlyOwner {

        MiniMeToken token = MiniMeToken(_tokenAddress);
        uint balance = token.balanceOf(this);

        if (!token.transfer(owner, balance))
            revert();
    }

    function add(uint _version, uint16 _eventType, uint _timeSpan, string _dataInfo) public {
        contentCount++;
        emit LogStore(_version, msg.sender, block.timestamp / (1 days), _eventType, _timeSpan, _dataInfo);
    }
}