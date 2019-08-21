pragma solidity ^0.4.19;

contract Snake {
    address public ownerAddress;
    uint256 public length; // stores length of the snake

    mapping (uint256 => uint256) public snake; // stores prices of the tokens
    mapping (uint256 => address) public owners; // stoes owners of the tokens
    mapping (uint256 => uint256) public stamps; // timestamps of last trades of tokens
    
    event Sale(address owner, uint256 profit, uint256 stamp); // 'stores' sales of tokens
    
    function Snake() public {
        ownerAddress = msg.sender; 
        length = 0; // set initial length of the snake to 0
        _extend(length); // create head of the snake
    }
    
    // this function is called when someone buys a token from someone else
    function buy(uint256 id) external payable {
        require(snake[id] > 0); // must be a valid token
        require(msg.value >= snake[id] / 100 * 150); // must send enough ether to buy it
        address owner = owners[id];
        uint256 amount = snake[id];

        snake[id] = amount / 100 * 150; // set new price of token
        owners[id] = msg.sender; // set new owner of token
        stamps[id] = uint256(now); // set timestamp of last trade of token to now

        owner.transfer(amount / 100 * 125); // transfer investment+gain to previous owner. 
        Sale(owner, amount, uint256(now)); // broadcast Sale event to the 'chain
        // if this is the head token being traded:
        if (id == 0) { 
            length++; // increase the length of the snake
            _extend(length); // create new token
        }
        ownerAddress.transfer(this.balance); // transfer remnant to contract owner, no ether should be stored in contract
    }
    // get price of certain token for UI purposes
    function getToken(uint256 id) external view returns(uint256, uint256, address) {
        return (snake[id] / 100 * 150, stamps[id], owners[id]);
    }
    // increases length of the snake
    function _extend(uint256 id) internal {
        snake[id] = 1 * 10**16;
        owners[id] = msg.sender;
    }
}