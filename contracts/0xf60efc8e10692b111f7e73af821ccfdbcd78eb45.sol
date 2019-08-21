pragma solidity ^0.4.19;

contract FrikandelToken {
    address public contractOwner = msg.sender; //King Frikandel

    bool public ICOEnabled = true; //Enable selling new Frikandellen
    bool public Killable = true; //Enabled when the contract can commit suicide (In case of a problem with the contract in its early development, we will set this to false later on)

    mapping (address => uint256) balances; //This is where de lekkere frikandellen are stored
    mapping (address => mapping (address => uint256)) allowed; //This is where approvals are stored!

    uint256 internal airdropLimit = 450000; //The maximum amount of tokens to airdrop before the feature shuts down
    uint256 public airdropSpent = 0; //The amount of airdropped tokens given away (The airdrop will not send past this)
    
    //uint256 internal ownerDrop = 50000; //Lets not waste gas storing this solid value we will only use 1 time - Adding it here so its obvious though
    uint256 public totalSupply = 500000; //We're reserving the airdrop tokens, they will be spent eventually. Combining that with the ownerDrop tokens we're at 500k
    uint256 internal hardLimitICO = 750000; //Do not allow more then 750k frikandellen to exist, ever. (The ICO will not sell past this)

    function name() public pure returns (string) { return "Frikandel"; } //Frikandellen zijn lekker
    function symbol() public pure returns (string) { return "FRIKANDEL"; } //I was deciding between FRKNDL and FRIKANDEL, but since the former is already kinda long why not just write it in full
    function decimals() public pure returns (uint8) { return 0; } //Imagine getting half of a frikandel, that must be pretty shitty... Lets not do that. Whish we could store this as uint256 to save gas though lol

    function balanceOf(address _owner) public view returns (uint256) { return balances[_owner]; }

	function FrikandelToken() public {
	    balances[contractOwner] = 50000; //To use for rewards and such - also I REALLY like frikandellen so don't judge please
	    Transfer(0x0, contractOwner, 50000); //Run a Transfer event for this as recommended by the ERC20 spec.
	}
	
	function transferOwnership(address _newOwner) public {
	    require(msg.sender == contractOwner); //:crying_tears_of_joy:

        contractOwner = _newOwner; //Nieuwe eigennaar van de frikandellentent
	}
	
	function Destroy() public {
	    require(msg.sender == contractOwner); //yo what why
	    
	    if (Killable == true){ //Only if the contract is killable.. Go ahead
	        selfdestruct(contractOwner);
	    }
	}
	
	function disableSuicide() public returns (bool success){
	    require(msg.sender == contractOwner); //u dont control me
	    
	    Killable = false; //The contract is now solid and will for ever be on the chain
	    return true;
	}
	
    function Airdrop(address[] _recipients) public {
        require(msg.sender == contractOwner); //no airdrop access 4 u
        if((_recipients.length + airdropSpent) > airdropLimit) { revert(); } //Hey, you're sending too much!!
        for (uint256 i = 0; i < _recipients.length; i++) {
            balances[_recipients[i]] += 1; //One frikandelletje 4 u
        }
        airdropSpent += _recipients.length; //Store the amount of tokens that have been given away. Doing this once instead of in the loop saves a neat amount of gas! (If the code gets intreupted it gets reverted anyways)
    }
	
	function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) { //Useful if someone allowed you to spend some of their frikandellen or if a smart contract needs to interact with it! :)
        //if (msg.data.length < (3 * 32) + 4) { revert(); } - Been thinking about implementing this, but its not fair to waste gas just to potentially ever save someone from sending a dumb malformed transaction, as a fault of their code or systems. (ERC20 Short address migration)
        if (_value == 0) { Transfer(msg.sender, _to, 0); return; } //Follow the ERC20 spec and just mark the transfer event even through 0 tokens are being transfered

        //bool sufficientFunds = balances[_from] >= _value; (Not having this single use variable in there saves us 8 gas)
        //bool sufficientAllowance = allowed[_from][msg.sender] >= _value;
        if (allowed[_from][msg.sender] >= _value && balances[_from] >= _value) {
            balances[_to] += _value;
            balances[_from] -= _value;
            
            allowed[_from][msg.sender] -= _value;
            
            Transfer(_from, _to, _value);
            return true;
        } else { return false; } //ERC20 spec tells us the feature SHOULD throw() if the account has not authhorized the sender of the message, however I see everyone using return false... As its not a MUST to throw(), I'm going with the others and returning false
    }
	
	function approve(address _spender, uint256 _value) public returns (bool success) { //Allow someone else to spend some of your frikandellen
        if (_value != 0 && allowed[msg.sender][_spender] != 0) { return false; } //ERC20 Spend/Approval race conditional migration - Always have a tx set the allowance to 0 first, before applying a new amount.
        
        allowed[msg.sender][_spender] = _value;
        
        Approval(msg.sender, _spender, _value);
        return true;
    }
    
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool) {
        if (allowed[msg.sender][_spender] >= allowed[msg.sender][_spender] + _addedValue) { revert(); } //Lets not overflow the allowance ;) (I guess this also prevents it from being increased by 0 as a nice extra)
        allowed[msg.sender][_spender] += _addedValue;
        Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
	
	function allowance(address _owner, address _spender) constant public returns (uint256) {
        return allowed[_owner][_spender];
    }

    function transfer(address _to, uint256 _value) public returns (bool success) {
        //if (msg.data.length < (2 * 32) + 4) { revert(); } - Been thinking about implementing this, but its not fair to waste gas just to potentially ever save someone from sending a dumb malformed transaction, as a fault of their code or systems. (ERC20 Short address migration)

        if (_value == 0) { Transfer(msg.sender, _to, 0); return; } //Follow the ERC20 specification and just trigger the event and quit the function since nothing is being transfered anyways

        //bool sufficientFunds = balances[msg.sender] >= _value; (Not having this single use variable in there saves us 8 gas)
        //bool overflowed = balances[_to] + _value < balances[_to]; (Not having this one probably saves some too but I'm too lazy to test how much we save so fuck that)

        if (balances[msg.sender] >= _value && !(balances[_to] + _value < balances[_to])) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            
            Transfer(msg.sender, _to, _value);
            return true; //Smakelijk!
        } else { return false; } //Sorry man je hebt niet genoeg F R I K A N D E L L E N
    }

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
	event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function enableICO() public {
        require(msg.sender == contractOwner); //Bro stay of my contract
        ICOEnabled = true;
    }

    function disableICO() public {
        require(msg.sender == contractOwner); //BRO what did I tell you
        ICOEnabled = false; //Business closed y'all
    }

    function() payable public {
        require(ICOEnabled);
        require(msg.value > 0); //You can't send nothing lol. It won't get you anything and I won't allow you to waste your precious gas on it! (You can send 1wei though, which will give you nothing in return either but still run the code below)
        if(balances[msg.sender]+(msg.value / 1e14) > 50000) { revert(); } //This would give you more then 50000 frikandellen, you can't buy from this account anymore through the ICO (If you eat 50000 frikandellen you'd probably die for real from all the layers of fat)
        if(totalSupply+(msg.value / 1e14) > hardLimitICO) { revert(); } //Hard limit on Frikandellen
        
        contractOwner.transfer(msg.value); //Thank you very much for supporting, I'll promise that I will spend an equal amount of money on purchaching frikandellen from my local store!

        uint256 tokensIssued = (msg.value / 1e14); //Since 1 token can be bought for 0.0001 ETH split the value (in Wei) through 1e14 to get the amount of tokens

        totalSupply += tokensIssued; //Lets note the tokens
        balances[msg.sender] += tokensIssued; //Dinner is served (Or well, maybe just a snack... Kinda depends on how many frikandel you've bought)

        Transfer(address(this), msg.sender, tokensIssued); //Trigger a transfer() event :)
    }
}