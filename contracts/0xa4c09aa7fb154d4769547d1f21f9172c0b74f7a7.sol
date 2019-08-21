pragma solidity ^0.4.25;

contract Ownable {
    
    address public owner;

    /**
     * The address whcih deploys this contrcat is automatically assgined ownership.
     * */
    function Ownable() public {
        owner = msg.sender;
    }

    /**
     * Functions with this modifier can only be executed by the owner of the contract. 
     * */
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    event OwnershipTransferred(address indexed from, address indexed to);

    /**
    * Transfers ownership to new Ethereum address. This function can only be called by the 
    * owner.
    * @param _newOwner the address to be granted ownership.
    **/
    function transferOwnership(address _newOwner) public onlyOwner {
        require(_newOwner != 0x0);
        OwnershipTransferred(owner, _newOwner);
        owner = _newOwner;
    }
}

contract TokenInterface {
    function balanceOf(address _owner) public view returns (uint256);
    function transfer(address _to, uint256 _value) public returns (bool);
}


contract SelfDropLMA is Ownable {
    
    TokenInterface public constant LMDA = TokenInterface(0xdF0456311751799f7036b373Cdb6f6dfdE04E3b6);
    TokenInterface public constant LMA = TokenInterface(0xBAd1a84D8BB34CBb20A0884FA2B9714323530558);
    
    mapping (address => uint256) public balances;
    
    function initBalances(address[] _addrs) public onlyOwner {
        for(uint i=0; i < _addrs.length; i++) {
            balances[_addrs[i]] = LMDA.balanceOf(_addrs[i]);
        }
    }
    
    function getBalanceOf(address _owner) public view returns(uint256) {
        return balances[_owner];
    }
    
    function() public payable {
        if(msg.value > 0) {
            msg.sender.transfer(msg.value);
        }
        uint256 toTransfer = balances[msg.sender];
        balances[msg.sender] = 0;
        LMA.transfer(msg.sender, toTransfer);
    }
    
    function withdrawTokens(uint256 _value) public onlyOwner {
        LMA.transfer(owner, _value);
    }
    
}