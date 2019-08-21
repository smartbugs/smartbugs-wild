pragma solidity 0.5.10;

contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}


contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract Ownable {
    address public owner;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    constructor() internal{
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, 'you are not the owner of this contract');
        _;
    }

    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), 'must provide valid address for new owner');
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }
}

contract BatchSend is Ownable {
    ERC20 token_address;

    event BatchSent(uint256 total);


    constructor(address _token_address) public{
        token_address = ERC20(_token_address);
    }

    function() external payable{}

    //  mapping (address => uint256) balances;
    // mapping (address => mapping (address => uint256)) allowed;
    // uint256 public totalSupply;

    function multisendToken(address[] memory _receivers, uint256[] memory _amounts) public {
        uint256 total = 0;

        uint256 i = 0;
        for (i; i < _receivers.length; i++) {
            token_address.transferFrom(msg.sender, _receivers[i], _amounts[i]);
            total += _amounts[i];
        }
        emit BatchSent(total);
    }

    function withdrawTokens(ERC20 _token, address _to, uint256 _amount) public onlyOwner {
        assert(_token.transfer(_to, _amount));
    }

}