pragma solidity ^0.4.25;


contract Ownable {
    
    address public owner;
    mapping (address => bool) public superUsers;
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    
    constructor() public {
        owner = msg.sender;
        superUsers[msg.sender] = true;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
    
     modifier onlySuperUser() {
        require(superUsers[msg.sender] == true);
        _;
    }
    
    function setSuperUser(address user) public onlyOwner {
        superUsers[user] = true;
    }
    
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract SuperToken is Ownable {
    struct Token {
        address owner;
        uint8 tokenType;
        uint32 amount;
    }

    Token[] public tokens;
    bool public implementsERC721 = true;
    string public name = "ever test token";
    string public symbol = "ST";
    mapping(uint256 => address) public approved;
    mapping(address => uint256) public balances;
    
    
    modifier onlyTokenOwner(uint256 _tokenId) {
        require(tokens[_tokenId].owner == msg.sender);
        _;
    }
   
    function mintToken(address _owner) public onlyOwner() {
        tokens.length ++;
        Token storage Token_demo = tokens[tokens.length - 1];
        Token_demo.owner = _owner;
        balances[_owner] += 1;
        emit Transfer(address(0), _owner, tokens.length - 1);
    }

    function getTokenType(uint256 _tokenId) view public returns (uint8 tokenType) {
        tokenType = tokens[_tokenId].tokenType;
    }

    function getTokenAmount(uint256 _tokenId) view public returns (uint32 tokenAmount) {
        tokenAmount = tokens[_tokenId].amount;
    }

    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);

    function totalSupply() public view returns (uint256 total) {
        total = tokens.length;
    }

    function balanceOf(address _owner) public view returns (uint256 balance){
        balance = balances[_owner];
    }

    function ownerOf(uint256 _tokenId) public view returns (address owner){
        owner = tokens[_tokenId].owner;
    }

    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        require(tokens[_tokenId].owner == _from);
        tokens[_tokenId].owner = _to;
        approved[_tokenId] = address(0);
        balances[_from] -= 1;
        balances[_to] += 1;
        emit Transfer(_from, _to, _tokenId);
    }

    function transfer(address _to, uint256 _tokenId) public onlyTokenOwner(_tokenId) returns (bool){
        _transfer(msg.sender, _to, _tokenId);
        return true;
    }
    
    function superTransfer(address _from, address _to, uint256 _tokenId) public onlySuperUser returns(bool){
        _transfer(_from, _to, _tokenId);
        return true;
    }
    
    function approve(address _to, uint256 _tokenId) public onlyTokenOwner(_tokenId){
        approved[_tokenId] = _to;
        emit Approval(msg.sender, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId) public returns (bool) {
        require(approved[_tokenId] == msg.sender);
        _transfer(_from, _to, _tokenId);
        return true;
    }


    function takeOwnership(uint256 _tokenId) public {
        require(approved[_tokenId] == msg.sender);
        _transfer(ownerOf(_tokenId), msg.sender, _tokenId);
    }
}