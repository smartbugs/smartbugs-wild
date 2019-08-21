pragma solidity ^0.4.25;

contract Token {
    function transfer(address receiver, uint amount) public;
    function balanceOf(address receiver)public returns(uint);
}

///@title Axioms-Airdrops
///@author Lucasxhy & Kafcioo

contract Axioms {
    Airdrop [] public airdrops;
    address owner;
    uint idCounter;
    
    ///@notice  Set the creator of the smart contract to be its sole owner
    constructor () public {
        owner = msg.sender;
    }
    
    
    ///@notice  Modifier to require a minimum amount of ether for the function to launch
    modifier minEth {
        require(msg.value >= 2000); 
        _;
    }

    ///@notice  Modifier that only allows the owner to execute a function
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    ///@notice  Creates a structure for airdrops, which stores all the necessary information for users to look up the history effectively and directly from the smart contract
    struct Airdrop {
        uint id;
        uint tokenAmount;
        string name;
        uint countDown;
        address distributor;
        Token tokenSC;
        mapping(address => address) uniqueAirdrop;
    }

    ///@notice  Adds a new airdrop to the smart contract and starts the count down until it is distributed
   function addNewAirdrop(
     uint _tokenAmount,
     string _name,
     uint _countDown,
     address  _smartContract
   
   )
     public
     minEth
     payable
   {
       Token t = Token(_smartContract);
       if(t.balanceOf(this)>=_tokenAmount){
        uint lastIndex = airdrops.length++;
        Airdrop storage airdrop = airdrops[lastIndex];
        airdrop.id =idCounter;
        airdrop.tokenAmount = _tokenAmount;
        airdrop.name=_name;
        airdrop.countDown=_countDown;
        airdrop.distributor = msg.sender;
        airdrop.tokenSC = Token(_smartContract);
        airdrop.uniqueAirdrop[msg.sender]=_smartContract;
        idCounter = airdrop.id+1;
       }else revert('Air Drop not added, Please make sure you send your ERC20 tokens to the smart contract before adding new airdrop');
   }

    ///@notice  Distirbutes a different quantity of tokens to all the specified addresses
    ///@dev Distribution will only occur when a distribute function is called and passed the correct parameters. It is not the smart contract's job to produce the addresses or determine the amounts
    ///@param index  The airdrop to distribute based in the the array in which is saved
    ///@param _addrs The set of addresses in array form, to which the airdrop will be distributed
    ///@param _vals  The set of values to be distributed to each address in array form
    function distributeVariable(
        uint index,
        address[] _addrs,
        uint[] _vals
    )
        public
        onlyOwner
    {
        if(timeGone(index)==true) {
            Airdrop memory airdrop = airdrops[index];
            for(uint i = 0; i < _addrs.length; ++i) {
                airdrop.tokenSC.transfer(_addrs[i], _vals[i]);
            }
        } else revert("Distribution Failed: Countdown not finished yet");
    }

    ///@notice  Distirbutes a constant quantity of tokens to all the specified addresses
    ///@dev Distribution will only occur when a distribute function is called and passed the correct parameters. It is not the smart contract's job to produce the addresses or determine the amounts
    ///@param index  The airdrop to distribute based in the the array in which is saved
    ///@param _addrs The set of addresses in array form, to which the airdrop will be distributed
    ///@param _amoutToEach  The value to be distributed to each address in array form
    function distributeFixed(
        uint index,
        address[] _addrs,
        uint _amoutToEach
    )
        public
        onlyOwner
    {
         if(timeGone(index)==true) {
            Airdrop memory airdrop = airdrops[index];
            for(uint i = 0; i < _addrs.length; ++i) {
                airdrop.tokenSC.transfer(_addrs[i], _amoutToEach);
            }
        } else revert("Distribution Failed: Countdown not finished yet");
    }

    ///@notice Refund tokens back to the to airdrop creator 
    function refoundTokens(
        uint index,
        address receiver,
        address sc
    )
        public
        onlyOwner
    {   
        
        Airdrop memory airdrop = airdrops[index];
        if(isAirDropUnique(index,receiver,sc)==true){
        airdrop.tokenSC.transfer(airdrop.distributor,airdrop.tokenAmount);
        }else revert();
        
    }
    
    ///@notice Refund eth left over from Distribution back to the airdrop creator 
    function refundLeftOverEth (
        uint index,
        uint amount,
        address reciever,
        address sc
    )
        public 
        onlyOwner
    {
         Airdrop memory airdrop = airdrops[index];
         if(isAirDropUnique(index,reciever,sc)==true){
        airdrop.distributor.transfer(amount);
         }else revert();
    }
      
    ///@notice  Determines whether an aidrop is due to be distributed or not
    ///@dev Distribution will only occur when a distribute function is called and passed the correct parameters. It is not the smart contract's job to produce the addresses or determine the amounts
    function timeGone(uint index) private view returns(bool){
        Airdrop memory airdrop = airdrops[index];
        uint timenow=now;
        if ( airdrop.countDown <timenow){
            return (true);
        }else return (false);
      }
      
    ///@notice  Determines whether an aidrop unique
    function isAirDropUnique(uint index, address receiver, address sc) private view returns(bool){
        Airdrop storage airdrop = airdrops[index];
        if(airdrop.uniqueAirdrop[receiver]==sc){
            return true;
        }else return false; 
    }

    ///@notice Transfer smartContract ownership
    function transferOwnership(address _newOwner) public onlyOwner(){
        require(_newOwner != address(0));
        owner = _newOwner;
    }
}