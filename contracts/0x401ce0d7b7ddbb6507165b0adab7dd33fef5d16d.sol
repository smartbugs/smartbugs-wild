pragma solidity 0.5.4;


library SafeMath {
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    require(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0);
    uint256 c = a / b;
    return c;
  }
  
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;
    return c;
  }

 
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);
    return c;
  }
}

contract ERC20 {
  function transfer(address to, uint256 value) public returns (bool);
}

contract MultiSign {
    using SafeMath for uint;
    
    address public Exchange = address(0x9E832A9CEaDf1E97D6d8da6922b87b59d25eEee0);
    address public Foundation = address(0x5a403e651EC2cD3b6B385dC639f1A90ea01017f7);
    uint256 public ProposalID = 0;
    mapping(uint => Proposal) public Proposals;

    struct Proposal {
        uint256 id;
        address to;
        bool close; // false open, true close
        address tokenContractAddress; // ERC20 token contract address
        uint256 amount;
        uint256 approvalByExchange; // default 0  approva 1 refuse 2
        uint256 approvalByFoundation;
    }
    
    
    constructor() public {
    }
    
    function lookProposal(uint256 id) public view returns (uint256 _id, address _to, bool _close, address _tokenContractAddress, uint256 _amount, uint256 _approvalByExchange, uint256 _approvalByFoundation) {
        Proposal memory p = Proposals[id];
        return (p.id, p.to, p.close, p.tokenContractAddress, p.amount, p.approvalByExchange, p.approvalByFoundation);
    }
    
    // only  Foundation or Exchange can proposal
    function proposal (address _to, address _tokenContractAddress, uint256 _amount) public returns (uint256 id) {
        require(msg.sender == Foundation || msg.sender == Exchange);
        ProposalID = ProposalID.add(1);
        Proposals[ProposalID] = Proposal(ProposalID, _to, false, _tokenContractAddress, _amount, 0, 0);
        return id;
    }
    
    // only  Foundation or Exchange can approval
    function approval (uint256 id) public returns (bool) {
        require(msg.sender == Foundation || msg.sender == Exchange);
        Proposal storage p = Proposals[id];
        require(p.close == false);
        if (msg.sender == Foundation && p.approvalByFoundation == 0) {
            p.approvalByFoundation = 1;
            Proposals[ProposalID] = p;
        }
        if (msg.sender == Exchange && p.approvalByExchange == 0) {
            p.approvalByExchange = 1;
            Proposals[ProposalID] = p;
        }
        
        if (p.approvalByExchange == 1 && p.approvalByFoundation == 1) {
            p.close = true;
            Proposals[ProposalID] = p;
            ERC20(p.tokenContractAddress).transfer(p.to, p.amount.mul(1e18));
        }
        return true;
    }
    
    // only  Foundation or Exchange can refuse
    function refuse (uint256 id) public returns (bool) {
        require(msg.sender == Foundation || msg.sender == Exchange);
        Proposal storage p = Proposals[id];
        require(p.close == false);
        if (msg.sender == Foundation && p.approvalByFoundation == 0) {
            p.close = true;
            p.approvalByFoundation = 2;
            Proposals[ProposalID] = p;
            return true;
        }
        if (msg.sender == Exchange && p.approvalByExchange == 0) {
            p.close = true;
            p.approvalByExchange = 2;
            Proposals[ProposalID] = p;
            return true;
        }
    }
    
    
    function() payable external {
        revert();
    }
}