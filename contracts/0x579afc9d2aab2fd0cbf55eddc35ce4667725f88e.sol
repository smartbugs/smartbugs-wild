pragma solidity ^0.4.19;

contract FrikandelToken {
    address public contractOwner = msg.sender; //King Frikandel

    bool public ICOEnabled = true; //Enable selling new Frikandellen
    bool public Killable = true; //Enabled when the contract can commit suicide (In case of a problem with the contract in its early development, we will set this to false later on)

    mapping (address => uint256) balances;

    uint256 public totalSupply = 500000; //500k Frikandellen (y'all ready for some airdrop??)
    uint256 internal hardLimitICO = 750000; //Do not allow more then 750k frikandellen to exist, ever. (The ICO will not sell past this)

    function name() public pure returns (string) { return "Frikandel"; } //Frikandellen zijn lekker
    function symbol() public pure returns (string) { return "FRKNDL"; }
    function decimals() public pure returns (uint8) { return 0; } //Imagine getting half of a frikandel, that must be pretty shitty... Lets not do that

    function balanceOf(address _owner) public view returns (uint256) { return balances[_owner]; }

	function FrikandelToken() public {
	    balances[contractOwner] = totalSupply; //Lets get this started :)
	}
	
	function transferOwnership(address newOwner) public {
	    if (msg.sender != contractOwner) { revert(); } //:crying_tears_of_joy:

        contractOwner = newOwner; //Nieuwe eigennaar van de frikandellentent
	}
	
	function Destroy() public {
	    if (msg.sender != contractOwner) { revert(); } //yo what why
	    
	    if (Killable == true){ //Only if the contract is killable.. Go ahead
	        selfdestruct(contractOwner);
	    }
	}
	
	function DisableSuicide() public returns (bool success){
	    if (msg.sender != contractOwner) { revert(); } //u dont control me
	    
	    Killable = false;
	    return true;
	}

    function transfer(address _to, uint256 _value) public returns (bool success) {
        if(msg.data.length < (2 * 32) + 4) { revert(); } //Something wrong yo

        if (_value == 0) { return false; } //y try to transfer without specifying any???

        uint256 fromBalance = balances[msg.sender];

        bool sufficientFunds = fromBalance >= _value;
        bool overflowed = balances[_to] + _value < balances[_to];

        if (sufficientFunds && !overflowed) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            
            Transfer(msg.sender, _to, _value);
            return true; //Smakelijk!
        } else { return false; } //Sorry man je hebt niet genoeg F R I K A N D E L L E N
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);

    function enableICO() public {
        if (msg.sender != contractOwner) { revert(); } //Bro stay of my contract
        ICOEnabled = true;
    }

    function disableICO() public {
        if (msg.sender != contractOwner) { revert(); } //BRO what did I tell you
        ICOEnabled = false;
    }

    function() payable public {
        if (!ICOEnabled) { revert(); }
        if(balances[msg.sender]+(msg.value / 1e14) > 30000) { revert(); } //This would give you more then 30000 frikandellen, you can't buy from this account anymore through the ICO
        if(totalSupply+(msg.value / 1e14) > hardLimitICO) { revert(); } //Hard limit on Frikandellen
        if (msg.value == 0) { return; }

        contractOwner.transfer(msg.value);

        uint256 tokensIssued = (msg.value / 1e14); //Since 1 token can be bought for 0.0001 ETH split the value (in Wei) through 1e14 to get the amount of tokens

        totalSupply += tokensIssued;
        balances[msg.sender] += tokensIssued;

        Transfer(address(this), msg.sender, tokensIssued);
    }
}