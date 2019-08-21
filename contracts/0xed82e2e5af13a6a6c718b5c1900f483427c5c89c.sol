pragma solidity ^0.5.3;

contract FiftyContract {
	mapping (address => mapping (uint => mapping (uint => mapping (uint => treeNode)))) public treeChildren;
	mapping (address => mapping (uint => mapping (uint => treeNode))) public treeParent;
	mapping (address => mapping (uint => bool)) public currentNodes;
	mapping (address => mapping (uint => uint)) public nodeIDIndex;
	mapping (address => uint) public membership;
	mapping(address => mapping(uint => uint)) public memberOrders;
	mapping (address => uint) public nodeReceivedETH;
	struct treeNode {
		 address payable ethAddress; 
		 uint nodeType; 
		 uint nodeID;
	}
	uint public spread;
}
contract Adminstrator {
  address public admin;
  address payable public owner;

  modifier onlyAdmin() { 
        require(msg.sender == admin || msg.sender == owner,"Not authorized"); 
        _;
  } 

  constructor() public {
    admin = msg.sender;
	owner = msg.sender;
  }

  function transferAdmin(address newAdmin) public onlyAdmin {
    admin = newAdmin; 
  }
}
contract readFiftyContract is Adminstrator{
	
	address public baseAddr = 0x0C00a40c0eB7b208900AbeA6587bfb07EFb0C6b6;
	FiftyContract bcontract = FiftyContract(baseAddr);
	
	function setContract(address newAddr) public onlyAdmin {
		baseAddr = newAddr;
		bcontract = FiftyContract(baseAddr);
	}

	function getStatus(address r) public view returns(uint, uint,
	uint, uint, uint, uint, uint, uint, uint){
	    uint[9] memory result;
	    result[0] = bcontract.membership(r);
	    result[1] = bcontract.nodeReceivedETH(r);
	    if(bcontract.currentNodes(r,1 ether)) result[2] = 1;
	    if(bcontract.nodeIDIndex(r,1 ether) > (2 ** 32) -2) result[2] = 2;
	    if(bcontract.currentNodes(r,2 ether)) result[3] = 1;
	    if(bcontract.nodeIDIndex(r,2 ether) > (2 ** 32) -2) result[3] = 2;
	    if(bcontract.currentNodes(r,3 ether)) result[4] = 1;
	    if(bcontract.nodeIDIndex(r,3 ether) > (2 ** 32) -2) result[4] = 2;
	    if(bcontract.currentNodes(r,5 ether)) result[5] = 1;
	    if(bcontract.nodeIDIndex(r,5 ether) > (2 ** 32) -2) result[5] = 2;
	    if(bcontract.currentNodes(r,10 ether)) result[6] = 1;
	    if(bcontract.nodeIDIndex(r,10 ether) > (2 ** 32) -2) result[6] = 2;
	    if(bcontract.currentNodes(r,50 ether)) result[7] = 1;
	    if(bcontract.nodeIDIndex(r,50 ether) > (2 ** 32) -2) result[7] = 2;
	    if( (bcontract.nodeIDIndex(r,1 ether) > 1 
	        || (bcontract.nodeIDIndex(r,1 ether) == 1 && !bcontract.currentNodes(r,1 ether))
	        ) &&
	        (bcontract.nodeIDIndex(r,2 ether) > 1 
	        || (bcontract.nodeIDIndex(r,2 ether) == 1 && !bcontract.currentNodes(r,2 ether))
	        ) &&
	        (bcontract.nodeIDIndex(r,3 ether) > 1 
	        || (bcontract.nodeIDIndex(r,3 ether) == 1 && !bcontract.currentNodes(r,3 ether))
	        ) &&
	        (bcontract.nodeIDIndex(r,2 ether) > 1 
	        || (bcontract.nodeIDIndex(r,5 ether) == 1 && !bcontract.currentNodes(r,5 ether))
	        )
	        ) result[8] = 1;
	    return(result[0],result[1],result[2],result[3],result[4],result[5],
	    result[6],result[7],result[8]);
	}
	function getLastTree(address r, uint t) public view returns(address[7] memory, address[7] memory){
	    address[7] memory latestTree;
	    address[7] memory lastCompletedTree;
	    if(bcontract.nodeIDIndex(r,t) >0 && bcontract.nodeIDIndex(r,t) <= (2 ** 32) -2 
	        && bcontract.currentNodes(r,t)){
	        uint cc=bcontract.nodeIDIndex(r,t) - 1;
    		latestTree = getTree(r,t,cc);
    		if(bcontract.nodeIDIndex(r,t) > 1){
    		    lastCompletedTree = getTree(r,t,cc-1);
    		}
    		return (latestTree,lastCompletedTree);
	    } 
		if(bcontract.nodeIDIndex(r,t) >0 && bcontract.nodeIDIndex(r,t) <= (2 ** 32) -2 
		    && !bcontract.currentNodes(r,t)){
		    uint cc=bcontract.nodeIDIndex(r,t) - 1;
    		lastCompletedTree = getTree(r,t,cc);
    		return (latestTree,lastCompletedTree);
		}
		if(bcontract.nodeIDIndex(r,t) > (2 ** 32) -2){
		    for(uint cc=0;cc < (2 ** 32) -2;cc++){
		        latestTree = getTree(r,t,cc);
		        if(latestTree[0] == address(0)) break;
		        else lastCompletedTree = getTree(r,t,cc);
		    }
		}
		return (latestTree,lastCompletedTree);
	}
	
	function getTree(address r, uint t, uint cc) public view returns(address[7] memory){
		address[7] memory Adds;
		if(bcontract.nodeIDIndex(r,t) <= cc) return Adds;
		(,uint pp,) = bcontract.treeChildren(r,t,cc,0);
		//if (pp!=0 || bcontract.nodeIDIndex(r,t) == (cc+1) ) Adds[0]=r;
		if (pp!=0 || bcontract.nodeIDIndex(r,t) == (cc+1) ){
		  (address parent,,)=bcontract.treeParent(r,t,cc);
		  Adds[0] = parent;
		} 
		else return Adds;
		uint8 spread = uint8(bcontract.spread());
		for (uint8 i=0; i < spread; i++) {
		    (address k,uint p,uint m) = bcontract.treeChildren(r,t,cc,i);
			if(p != 0){
				Adds[i+1]=k;
				for (uint8 a=0; a < spread; a++) {
				    (address L,uint q,) = bcontract.treeChildren(k,p,m,a);    
					if(q != 0) Adds[i*2+a+3] = L;
				}
			}
		}
		return Adds;
	}
}