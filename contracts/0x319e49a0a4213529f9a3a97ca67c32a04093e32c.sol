pragma solidity ^0.4.24;

contract Ownable {}
contract CREDITS is Ownable{}
contract CREDITCoins is CREDITS{
    bool public Frozen;
    mapping(address => bool) public AccountIsFrozen;
    mapping(address => bool) public AccountIsNotFrozen;
    mapping(address => uint) public AccountIsFrozenByDate;
    mapping(address => uint256) public balanceOf;
    mapping (address => bool) public isHolder;
    address [] public Arrholders;
    mapping(address => bool) public AccountIsNotFrozenForReturn;
    address public AddressForReturn;
    
    function transfer(address _to, uint256 _value) public;
}

contract ContractSendCreditCoins {
    //storage
    CREDITCoins public company_token;
    address public PartnerAccount;
  
    //Events
    event Transfer(address indexed to, uint indexed value);

    //constructor
    constructor (CREDITCoins _company_token) public {
        PartnerAccount = 0x4f89aaCC3915132EcE2E0Fef02036c0F33879eA8;
        company_token = _company_token;
    }
  
    function sendCurrentPayment() public {  
            company_token.transfer(PartnerAccount, 1);
            emit Transfer(PartnerAccount, 1);
    }
}