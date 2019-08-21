pragma solidity ^0.4.15;

contract owned {
    function owned() public { owner = msg.sender; }
    address public owner;

    // This contract only defines a modifier but does not use
    // it - it will be used in derived contracts.
    // The function body is inserted where the special symbol
    // "_;" in the definition of a modifier appears.
    // This means that if the owner calls this function, the
    // function is executed and otherwise, an exception is
    // thrown.
    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
}

contract ERC20 {
    function balanceOf(address _owner) public constant returns (uint balance);
    function transfer(address _to, uint _value) public returns (bool success);
    function transferFrom(address _from, address _to, uint _value) public returns (bool success);
    function approve(address _spender, uint _value) public returns (bool success);
    function allowance(address _owner, address _spender) public constant returns (uint remaining);
    event Transfer(address indexed _from, address indexed _to, uint _value);
    event Approval(address indexed _owner, address indexed _spender, uint _value);
}

/// @title Interface for contracts conforming to ERC-721: Non-Fungible Tokens
/// @author Dieter Shirley <dete@axiomzen.co> (https://github.com/dete)
contract ERC721 {
    // Required methods
    function totalSupply() public returns (uint256 total);
    function balanceOf(address _owner) public returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external returns (address owner);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external;
    function transferFrom(address _from, address _to, uint256 _tokenId) external;

    // Events
    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);

    // Optional
    // function name() public view returns (string name);
    // function symbol() public view returns (string symbol);
    // function tokensOfOwner(address _owner) external view returns (uint256[] tokenIds);
    // function tokenMetadata(uint256 _tokenId, string _preferredTransport) public view returns (string infoUrl);

    // ERC-165 Compatibility (https://github.com/ethereum/EIPs/issues/165)
    function supportsInterface(bytes4 _interfaceID) external returns (bool);
}

contract AutoWallet is owned {
    function changeOwner(address _newOwner) external onlyOwner {
        owner = _newOwner;
    }
    
    function () external payable {
        // this is the fallback function; it is called whenever the contract receives ether
        // forward that ether onto the contract owner immediately
        owner.transfer(msg.value);
        // and emit the EtherReceived event in case anyone is watching it
        EtherReceived(msg.sender, msg.value);
    }
    
    function sweep() external returns (bool success) {
        // this can be called by anyone (who wants to pay for gas), but that's safe because it will only sweep
        // funds to the owner's account. it sweeps the entire ether balance
        require(this.balance > 0);
        return owner.send(this.balance);
    }
    
    function transferToken(address _tokenContractAddress, address _to, uint256 _amount) external onlyOwner returns (bool success) {
        // this can only be called by the owner. it sends some amount of an ERC-20 token to some address
        ERC20 token = ERC20(_tokenContractAddress);
        return token.transfer(_to, _amount);
    }
    
    function sweepToken(address _tokenContractAddress) external returns (bool success) {
        // like sweep(), this can be called by anyone. it sweeps the full balance of an ERC-20 token to the owner's account
        ERC20 token = ERC20(_tokenContractAddress);
        uint bal = token.balanceOf(this);
        require(bal > 0);
        return token.transfer(owner, bal);
    }
    
    function transferTokenFrom(address _tokenContractAddress, address _from, address _to, uint256 _amount) external onlyOwner returns (bool success) {
        ERC20 token = ERC20(_tokenContractAddress);
        return token.transferFrom(_from, _to, _amount);
    }
    
    function approveTokenTransfer(address _tokenContractAddress, address _spender, uint256 _amount) external onlyOwner returns (bool success) {
        ERC20 token = ERC20(_tokenContractAddress);
        return token.approve(_spender, _amount);
    }
    
    function transferNonFungibleToken(address _tokenContractAddress, address _to, uint256 _tokenId) external onlyOwner {
        // for cryptokitties etc
        ERC721 token = ERC721(_tokenContractAddress);
        token.transfer(_to, _tokenId);
    }
    
    function transferNonFungibleTokenFrom(address _tokenContractAddress, address _from, address _to, uint256 _tokenId) external onlyOwner {
        ERC721 token = ERC721(_tokenContractAddress);
        token.transferFrom(_from, _to, _tokenId);
    }
    
    function transferNonFungibleTokenMulti(address _tokenContractAddress, address _to, uint256[] _tokenIds) external onlyOwner {
        ERC721 token = ERC721(_tokenContractAddress);
        for (uint i = 0; i < _tokenIds.length; i++) {
            token.transfer(_to, _tokenIds[i]);
        }
    }
    
    event EtherReceived(address _sender, uint256 _value);
}