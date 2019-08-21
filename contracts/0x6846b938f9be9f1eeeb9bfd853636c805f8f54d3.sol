pragma solidity ^0.4.6;

contract RES { 

    /* Public variables of the token */
    string public name;
    string public symbol;
    uint8 public decimals;
    
    uint public totalSupply;
    
    /* This creates an array with all balances */
    mapping (address => uint256) public balanceOf;
    
    /* This generates a public event on the blockchain that will notify clients */
    event Transfer(address indexed from, address indexed to, uint256 value);
    

    /* Bought or sold */

    event Bought(address from, uint amount);
    event Sold(address from, uint amount);
    event BoughtViaJohan(address from, uint amount);

    /* Initializes contract with name, symbol and decimals */

    function RES() {
        name = "RES";     
        symbol = "RES";
        decimals = 18;
    }

}

contract SwarmRedistribution is RES {
    
    address public JohanNygren;
    bool public campaignOpen;    

    struct dividendPathway {
      address from;
      uint amount;
      uint timeStamp;
    }

    mapping(address => dividendPathway[]) public dividendPathways;
    
    mapping(address => uint256) public totalBasicIncome;

    uint taxRate;

    struct Node {
      address node;
      address parent;
      uint index;
    }
    
    /* Generate a swarm tree */
    Node[] swarmTree;
    
    mapping(address => bool) inSwarmTree;
    
    bool JohanInSwarm;

    event Swarm(address indexed leaf, address indexed node, uint256 share);

    function SwarmRedistribution() {
      
    /* Tax-rate in parts per thousand */
    taxRate = 20;
    JohanNygren = 0x948176CB42B65d835Ee4324914B104B66fB93B52;
    campaignOpen = true;
    
    }
    
    modifier onlyJohan {
      if(msg.sender != JohanNygren) throw;
      _;
    }

    modifier isOpen {
      if(campaignOpen != true) throw;
      _;
    }
    
    function changeJohanNygrensAddress(address _newAddress) onlyJohan {
      JohanNygren = _newAddress;
    }
    
    function closeCampaign() onlyJohan {
        campaignOpen = false;
    }

    function buy() isOpen public payable {
      balanceOf[msg.sender] += msg.value;
      totalSupply += msg.value;
      Bought(msg.sender, msg.value);
    }  

    function buyViaJohan() isOpen public payable {
      balanceOf[msg.sender] += msg.value;
      totalSupply += msg.value;  

      /* Create the dividend pathway */
      dividendPathways[msg.sender].push(dividendPathway({
                                      from: JohanNygren, 
                                      amount:  msg.value,
                                      timeStamp: now
                                    }));

      BoughtViaJohan(msg.sender, msg.value);
    }

    function sell(uint256 _value) public {
      if(balanceOf[msg.sender] < _value) throw;
      balanceOf[msg.sender] -= _value;
    
      if (!msg.sender.send(_value)) throw;

      totalSupply -= _value;
      Sold(msg.sender, _value);

    }

    /* Send coins */
    function transfer(address _to, uint256 _value) isOpen {
        /* reject transaction to self to prevent dividend pathway loops*/
        if(_to == msg.sender) throw;
        
        /* if the sender doenst have enough balance then stop */
        if (balanceOf[msg.sender] < _value) throw;
        if (balanceOf[_to] + _value < balanceOf[_to]) throw;
        
        /* Calculate tax */
        uint256 taxCollected = _value * taxRate / 1000;
        uint256 sentAmount;

        /* Create the dividend pathway */
        dividendPathways[_to].push(dividendPathway({
                                        from: msg.sender, 
                                        amount:  _value,
                                        timeStamp: now
                                      }));
        
        if(swarmRedistribution(_to, taxCollected) == true) {
          sentAmount = _value;
        }
        else {
          /* Return tax */
          sentAmount = _value - taxCollected;
        }
        
          /* Add and subtract new balances */

          balanceOf[msg.sender] -= sentAmount;
          balanceOf[_to] += _value - taxCollected;
        

        /* Notifiy anyone listening that this transfer took place */
        Transfer(msg.sender, _to, sentAmount);
    }

    function swarmRedistribution(address _to, uint256 _taxCollected) internal returns (bool) {
           iterateThroughSwarm(_to, now);
           if(swarmTree.length != 0) {
           return doSwarm(_to, _taxCollected);
           }
           else return false;
      }

    function iterateThroughSwarm(address _node, uint _timeStamp) internal {
      if(dividendPathways[_node].length != 0) {
        for(uint i = 0; i < dividendPathways[_node].length; i++) {
          if(inSwarmTree[dividendPathways[_node][i].from] == false) { 
            
            uint timeStamp = dividendPathways[_node][i].timeStamp;
            if(timeStamp <= _timeStamp) {
                
              if(dividendPathways[_node][i].from == JohanNygren) JohanInSwarm = true;
    
                Node memory node = Node({
                            node: dividendPathways[_node][i].from, 
                            parent: _node,
                            index: i
                          });
                          
                  swarmTree.push(node);
                  inSwarmTree[node.node] = true;
                  iterateThroughSwarm(node.node, timeStamp);
              }
          }
        }
      }
    }

    function doSwarm(address _leaf, uint256 _taxCollected) internal returns (bool) {
      
      uint256 share;
      if(JohanInSwarm) share = _taxCollected;
      else share = 0;
    
      for(uint i = 0; i < swarmTree.length; i++) {
        
        address node = swarmTree[i].node;
        address parent = swarmTree[i].parent;
        uint index = swarmTree[i].index;
        
        bool isJohan;
        if(node == JohanNygren) isJohan = true;

        if(isJohan) {
          balanceOf[swarmTree[i].node] += share;
        totalBasicIncome[node] += share;
        }
          
        if(dividendPathways[parent][index].amount - _taxCollected > 0) {
          dividendPathways[parent][index].amount -= _taxCollected; 
        }
        else removeDividendPathway(parent, index);
        
        inSwarmTree[node] = false;
        
        /* Notifiy anyone listening that this swarm took place */
        if(isJohan) Swarm(_leaf, swarmTree[i].node, share);
      }
      delete swarmTree;
      bool JohanWasInSwarm = JohanInSwarm;
      delete JohanInSwarm;

      if(!JohanWasInSwarm) return false;
      return true;
    }
    
    function removeDividendPathway(address node, uint index) internal {
                delete dividendPathways[node][index];
                for (uint i = index; i < dividendPathways[node].length - 1; i++) {
                        dividendPathways[node][i] = dividendPathways[node][i + 1];
                }
                dividendPathways[node].length--;
        }

}