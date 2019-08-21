pragma solidity ^0.5;

contract owned {
    address payable public owner;

    constructor () public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address payable newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract limited is owned {
    mapping (address => bool) canAsk ;
    
     modifier onlyCanAsk {
        require(canAsk[msg.sender]);
        _;
    }
    
    function changeAsk (address a,bool allow) onlyOwner public {
        canAsk[a] = allow;
    }
    
}

interface ICampaign {
    function update(bytes32 idRequest,uint64 likes,uint64 shares,uint64 views) external  returns (bool ok);
}

interface IERC20 {
   function transfer(address _to, uint256 _value) external;
}

contract oracle is limited {
    
    
    // social network ids: 
    // 01 : facebook;
    // 02 : youtube
    // 03 : instagram
    // 04 : twitter
    // 05 : url TLS Notary
    
    event AskRequest(bytes32 indexed idRequest, uint8 typeSN, string idPost,string idUser);
    event AnswerRequest(bytes32 indexed idRequest, uint64 likes, uint64 shares, uint64 views);
    
    function  ask (uint8 typeSN,string memory idPost,string memory idUser, bytes32 idRequest) public onlyCanAsk
    {
        emit AskRequest(idRequest, typeSN, idPost, idUser );
    }
    
    function answer(address campaignContract,bytes32 idRequest,uint64 likes,uint64 shares, uint64 views) public onlyOwner {
        ICampaign campaign = ICampaign(campaignContract);
        campaign.update(idRequest,likes,shares,views);
        emit AnswerRequest(idRequest,likes,shares,views);
    }
    
    function() external payable {}
    
    function withdraw() onlyOwner public {
        owner.transfer(address(this).balance);
    }
    
    function transferToken (address token,address to,uint256 val) public onlyOwner {
        IERC20 erc20 = IERC20(token);
        erc20.transfer(to,val);
    }
    
}