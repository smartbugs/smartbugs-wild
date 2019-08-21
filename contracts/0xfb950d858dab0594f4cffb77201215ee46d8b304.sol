pragma solidity ^0.4.19;

//contract by Adam Skrodzki
//
contract BankAccount {
    Bank parent;
    function() payable public{
        address mainAdr = parent.GetMainAddress();

        mainAdr.transfer(msg.value);
    }

    function BankAccount (address _bankAddress) public {
        parent = Bank(_bankAddress);
    }
    
    function transferTokens(address _tokenAdr) public {
        address mainAdr = parent.GetMainAddress();
        Token t = Token(_tokenAdr);
        t.transfer(mainAdr,t.balanceOf(this));
    }
}

contract Token {
    function balanceOf(address a) constant returns(uint256);
    function transfer(address to,uint256 value);
}

contract Bank {

    address private _mainAddress;
    address public owner ;
    address private operator ;
    BankAccount[] private availableAddresses;
    Token[] private tokens;
    mapping(uint256 => address) private assignments ;

    uint256 public firstFreeAddressIndex = 0;


    function ChangeMainAccount(address mainAddress) public{
        if(msg.sender==owner){
            _mainAddress = mainAddress;
        }
    }
    
    function ChangeOperatorAccount(address addr) public{
        if(msg.sender==owner){
            operator = addr;
        }
    }
    
    function GetNextWithFunds(uint256 startAcc,uint256 startTok) constant returns(uint256,uint256,bool){
            uint256 i = startAcc;
            uint256 j = startTok;
            if(j==0) j=1;
            uint256 counter =0;
            for(i;i<availableAddresses.length && counter<100;i++){
                for(j;j<tokens.length && counter<100;j++){
                    counter++;
                    if(tokens[j].balanceOf(availableAddresses[i])>0){
                        return (i,j,true);
                    }
                }
                j=1;
            }
            if(i==availableAddresses.length){
                return(0,0,false);
            }
            else{
                return(i,j,false);
            }
    }
    function TransferFunds(uint256 addrIdx,uint256 tokIdx) public{
        if(msg.sender==owner || msg.sender==operator){
            availableAddresses[addrIdx].transferTokens.gas(250000)(tokens[tokIdx]);
        }
        else{
          revert();   
        
        }
    }
    function GetMainAddress() public constant returns (address){
        return(_mainAddress);
    }
    function ChangeOwner(address newOwner) public{
        if(msg.sender==owner){
            owner = newOwner;
        }
        else{
          revert();   
        
        }
    }
    function AddToken(address _adr)public {
        if(msg.sender==owner || msg.sender==operator){
            tokens.push(Token(_adr));
        }
        else{
          revert();   
        
        }
    }
    function Bank(address mainAddress) public{
        tokens.push(Token(0));
        owner = msg.sender;
        _mainAddress = mainAddress;
    }
    function CreateNewAccount() public{
        var a = new BankAccount(this);
        availableAddresses.push(a);
    }
    function GetAvailableAddressesCount() private constant returns(uint256){
        return availableAddresses.length-firstFreeAddressIndex;
    }

    function AssignAddress(uint256 holderId) public{
        if(msg.sender==owner || msg.sender==operator){
            if(assignments[holderId]!=0){ // nie można stworzyć 2 adresów dla jednego klienta
    
            }
            else{
                if(GetAvailableAddressesCount()==0){
                        CreateNewAccount();
                }
                assignments[holderId] = availableAddresses[firstFreeAddressIndex];
                firstFreeAddressIndex = firstFreeAddressIndex+1;
            }
        }
        else{
          revert();   
        
        }

    }

    function GetAssignedAddress(uint256 holderId) public constant returns(address){
         return assignments[holderId];
    }


}