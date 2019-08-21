pragma solidity ^0.5;

contract ERC20 {
    mapping(address => mapping(address => uint)) public allowed;
    function transferFrom(address from, address to, uint amount) public returns (bool);
    function transfer(address to, uint amount) public returns (bool);
    function approve(address spender, uint amount) public returns (bool);
    function balanceOf(address a) public view returns (uint);
}

contract ProtocolTypes {
    struct OptionSeries {
        uint expiration;
        Flavor flavor;
        uint strike;
    }
    
    enum Flavor {
        Call,
        Put
    }
}

contract Protocol is ProtocolTypes {
    ERC20 public usdERC20;
    mapping(address => OptionSeries) public seriesInfo;
    mapping(address => mapping(address => uint)) public writers;

    function open(address _series, uint amount) public payable;
    function redeem(address _series) public;
    function settle(address _series) public;
    function close(address _series, uint amount) public;
}

contract Trading is ProtocolTypes {
    
    address payable public owner;
    address public signer = 0x47e3ea40D4F39A8C3a819B90F03FcE162e2fdbe4;
    
    Protocol public protocol;
    ERC20 public usd;
    
    enum Action {
        Buy,
        Sell
    }
    
    constructor(address _protocol) public {
        owner = msg.sender;
        require(_protocol != address(0));
        protocol = Protocol(_protocol);
        usd = ERC20(address(protocol.usdERC20()));
        usd.approve(address(protocol), uint256(0) - 1);
    }
    
    function() external payable {}
    
    function trade(Action action, uint expiration, uint getting, uint giving, address token, uint8 v, bytes32 r, bytes32 s) public payable {
        require(msg.sender == tx.origin);
        require(expiration > now);
        require(ecrecover(keccak256(abi.encodePacked(uint8(action), expiration, getting, giving, token)), v, r, s) == signer);
        
        Flavor flavor;
        uint strike;

        (expiration, flavor, strike) = protocol.seriesInfo(token);
        if (action == Action.Buy) {
            require(msg.value == giving);
            uint owned = ERC20(token).balanceOf(address(this));
            uint needed = owned < getting ? getting - owned : 0;
            
            if (needed > 0) {
                // open value in protocol and send to buyer
                if (flavor == Flavor.Call) {
                    protocol.open.value(needed)(token, needed);
                } else {
                    protocol.open(token, needed);
                }
            }
            
            ERC20(token).transfer(msg.sender, getting);
            // require(token.call(bytes4(keccak256("transfer(address,uint256)")), msg.sender, getting));
        } else {
            require(msg.value == 0);
            // require(token.call(bytes4(keccak256("transferFrom(address,address,uint256)")), msg.sender, address(this), giving));
            ERC20(token).transferFrom(msg.sender, address(this), giving);
            // close value in protocol and send to seller
            uint written = protocol.writers(token, address(this));
            uint closeable = written < giving ? written : giving;
            
            if (closeable > 0) {
                protocol.close(token, closeable); 
            }

            msg.sender.transfer(getting);
        }
    }
    
    function settleWritten(address token) public {
        protocol.redeem(token);
    }
    
    function settle(address token) public {
        protocol.settle(token);
    }
    
    // these functions allow the contract owner to remove liquidity from the contract
    // they have no impact on users funds since this contract never holds users funds
    function withdraw(uint amount) public {
        require(msg.sender == owner);
        owner.transfer(amount);
    }
    
    function withdrawUSD(uint amount) public {
        require(msg.sender == owner);
        usd.transfer(owner, amount);
    }
    
    function withdrawMaxETH() public {
        withdraw(address(this).balance);
    }
    
    function withdrawToken(address token, uint amount) public {
        require(msg.sender == owner);
        ERC20(token).transfer(owner, amount);
    }
    
    function setSigner(address next) public {
        require(msg.sender == owner);
        signer = next;
    }
}