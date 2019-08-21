pragma solidity ^0.4.19;

contract FakeTokenFactory
{
    function manufacture(address _addr1, address _addr2, address _owner) external
    {
        FakeToken ft = new FakeToken(this, _owner);
        ft.transfer(_addr1, (now % 1000) * 181248934);
        ft.transfer(_addr2, 3.14159265358979 ether);
    }
}

contract FakeToken
{
    function randName(uint256 _maxSyllables, uint256 _seed) internal view returns (string)
    {
        bytes memory consonants = new bytes(17);
        consonants[0] = 'B';
        consonants[1] = 'D';
        consonants[2] = 'F';
        consonants[3] = 'G';
        consonants[4] = 'H';
        consonants[5] = 'K';
        consonants[6] = 'L';
        consonants[7] = 'M';
        consonants[8] = 'N';
        consonants[9] = 'P';
        consonants[10] = 'R';
        consonants[11] = 'S';
        consonants[12] = 'T';
        consonants[13] = 'V';
        consonants[14] = 'W';
        consonants[15] = 'X';
        consonants[16] = 'Z';
        bytes memory vowels = new bytes(5);
        vowels[0] = 'A';
        vowels[1] = 'E';
        vowels[2] = 'I';
        vowels[3] = 'U';
        vowels[4] = 'O';
        
        uint256 syllables = 2 + (now % (_maxSyllables-1));
        bytes memory name = new bytes(syllables*2);
        for (uint i=0; i<syllables; i++)
        {
            uint256 rand = uint256(keccak256(address(this), _seed, i));
            name[i*2+0] = consonants[rand % 17];
            name[i*2+1] = vowels    [rand %  5];
        }
        return string(name);
    }
    
    address private owner;
    FakeTokenFactory private factory;
    
    string private symbol1;
    string private symbol2;
    string private name1;
    string private name2;
    
    function FakeToken(FakeTokenFactory _factory, address _owner) public
    {
        if (_owner == 0x0) _owner = msg.sender;
        owner = _owner;
        factory = _factory;
        symbol1 = randName(3, 1);
        symbol2 = randName(3, 3);
        name1 = randName(15, 5);
        name2 = randName(15, 7);
    }
    function symbol() external view returns (string)
    {
        if (now % 2 == 0) return symbol1; 
        else return symbol2;
    }
    function name() external view returns (string)
    {
        if (now % 2 == 0) return name1;
        else return name2;
    }
    function decimals() public view returns (uint256)
    {
        return uint256(keccak256(now)) % 19;
    }
    function totalSupply() external view returns (uint256)
    {
        return (uint256(keccak256(now)) % 1000) * 10000;
    }
    function balanceOf(address _owner) public view returns (uint256)
    {
        return (uint256(keccak256(now, _owner)) % 1000) * (uint256(10) ** decimals());
    }
    function transfer(address _to, uint256 _amount) external returns (bool)
    {
        uint256 rand = uint256(keccak256(_to, _amount, now));
        
        // lol
        if (rand % 125 == 0)
        {
            factory.manufacture(_to, msg.sender, owner);
        }
        
        // more lolz
        else if (rand % 125 == 1)
        {
            this.airdrop(_to, now%77);
        }
        
        // a different kind of lolz
        else if (rand % 125 == 2)
        {
            this.airdrop(msg.sender, now%77);
        }
        
        Transfer(msg.sender, _to, _amount);
        return true;
    }
    event Transfer(address indexed from, address indexed to, uint256 value);
    function airdrop(address[] _tos) external
    {
        require(msg.sender == owner || msg.sender == address(this));
        for (uint256 i=0; i<_tos.length; i++)
        {
            address _to = _tos[i];
            Transfer(this, _to, balanceOf(_to));
        }
    }
    function airdrop(address _to, uint256 _amount) external
    {
        require(msg.sender == owner || msg.sender == address(this));
        for (uint256 i=0; i<_amount; i++)
        {
            Transfer(this, _to, (uint256(keccak256(now+i)) % 1000) * (uint256(10) ** decimals()));
        }
    }
    function () payable external
    {
        owner.transfer(msg.value);
    }
    function sendTokens(address _contract, uint256 _amount) external
    {
        FakeToken(_contract).transfer(owner, _amount);
    }
    function tokenFallback(address, uint, bytes) external pure
    {
    }
}