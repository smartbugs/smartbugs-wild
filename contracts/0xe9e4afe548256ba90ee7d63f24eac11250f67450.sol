pragma solidity ^0.4.18;

contract EtherealId{
     string public constant CONTRACT_NAME = "EtherealId";
    string public constant CONTRACT_VERSION = "B";
    mapping (address => bool) private IsAuthority;
	address private Creator;
	address private Owner;
    bool private Active;
    
	mapping(bytes32 => bool) private Proof;
	mapping (address => bool) private BlockedAddresses;
	function SubmitProofOfOwnership(bytes32 proof) public onlyOwner{
		Proof[proof] = true;
	}	
	function RemoveProofOfOwnership(bytes32 proof) public ownerOrAuthority	{
		delete Proof[proof];
	}	
	function CheckProofOfOwnership(bytes32 proof) view public returns(bool) 	{
		return Proof[proof];
	}
	function BlockAddress(address addr) public ownerOrAuthority	{
		BlockedAddresses[addr] = true;
	}
	function UnBlockAddress(address addr) public ownerOrAuthority	{
		delete BlockedAddresses[addr];
	}
	function IsBlocked(address addr) public view returns(bool){
		return BlockedAddresses[addr];
	}
		
    function Deactivate() public ownerOrAuthority    {
        require(IsAuthority[msg.sender] || msg.sender == Owner);
        Active = false;
        selfdestruct(Owner);
    }
    function IsActive() public view returns(bool)    {
        return Active;
    }
    mapping(bytes32 => bool) private VerifiedInfoHashes;//key is hash, true if verified
    
    event Added(bytes32 indexed hash);
    function AddVerifiedInfo( bytes32 hash) public onlyAuthority    {
        VerifiedInfoHashes[hash] = true;
        Added(hash);
    }
    
    event Removed(bytes32 indexed hash);
    function RemoveVerifiedInfo(bytes32 hash) public onlyAuthority    {
        delete VerifiedInfoHashes[hash];
        Removed(hash);
    }
    
    function EtherealId(address owner) public    {
        IsAuthority[msg.sender] = true;
        Active = true;
		Creator = msg.sender;
		Owner = owner;
    }
    modifier onlyOwner(){
        require(msg.sender == Owner);
        _;
    }
    modifier onlyAuthority(){
        require(IsAuthority[msg.sender]);
        _;
    }
	modifier ownerOrAuthority()	{
        require(msg.sender == Owner ||  IsAuthority[msg.sender]);
        _;
	}
	modifier notBlocked()	{
		require(!BlockedAddresses[msg.sender]);
        _;
	}
    function OwnerAddress() public view notBlocked returns(address)     {
        return Owner;
    }
    function IsAuthorityAddress(address addr) public view notBlocked returns(bool)     {
        return IsAuthority[addr];
    }
    function AddAuthorityAddress(address addr) public onlyOwner    {
        IsAuthority[addr] = true;
    }
    
    function RemoveAuthorityAddress(address addr) public onlyOwner    {
		require(addr != Creator);
        delete IsAuthority[addr];
    }
        
    function VerifiedInfoHash(bytes32 hash) public view notBlocked returns(bool)     {
        return VerifiedInfoHashes[hash];
    }
    
	//this is the fallback
    event RecievedEth(address indexed _from, uint256 _value);
	function () payable public {
		RecievedEth(msg.sender, msg.value);		
	}
	
	event TransferedEth(address indexed _to, uint256 _value);
	function TransferEth(address _to, uint256 _value) public onlyOwner{
	    require(this.balance >= _value);
	    
        if(_value >0)
		{
			_to.transfer(_value);
			TransferedEth(_to, _value);
		}   
	}
}