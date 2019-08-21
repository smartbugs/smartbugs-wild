pragma solidity ^0.4.24;

contract DappRadar {
    
    mapping(address => mapping(address => uint)) public userDetails;

    event AddUserDetails(address indexed _userAccount, address indexed _userWallet, uint _balance);
    event CreateAccount(address indexed _account);

    constructor() public {}

    function addUserDetails(address _userWallet, uint _balance)
        public
        {
            if (_userWallet != 0x0 && _balance > 0) {
                userDetails[msg.sender][_userWallet] = _balance;
                emit AddUserDetails(msg.sender, _userWallet, _balance);
            }
        }

    function createAccount()
        public
        {
            emit CreateAccount(msg.sender);
        }

}