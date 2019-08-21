pragma solidity ^0.5.3;

contract FiftyContract {
	mapping (address => mapping (uint => mapping (uint => mapping (uint => treeNode)))) public treeChildren;
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
	
	address public baseAddr = 0x874D72e8F9908fDC55a420Bead9A22a8A5b20D91;
	FiftyContract bcontract = FiftyContract(baseAddr);
	
	function setContract(address newAddr) public onlyAdmin {
		baseAddr = newAddr;
		bcontract = FiftyContract(baseAddr);
	}
	function getReceivedETH(address r) public view returns (uint, uint, uint, uint, uint){
		return ( bcontract.nodeReceivedETH(r) , bcontract.nodeIDIndex(r, 1 ether) 
		, bcontract.nodeIDIndex(r, 2 ether) , bcontract.nodeIDIndex(r, 3 ether) 
		, bcontract.nodeIDIndex(r, 5 ether) );
	}
	function getTree(address r, uint t, uint cc) public view returns(address[7] memory){
		address[7] memory Adds;
		if(bcontract.nodeIDIndex(r,t) <= cc) return Adds;
		(,uint pp,) = bcontract.treeChildren(r,t,cc,0);
		if (pp!=0 || bcontract.nodeIDIndex(r,t) == (cc+1) ) Adds[0]=r;
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
	function getMemberOrder(address addr, uint orderID) public view returns (uint){
		return bcontract.memberOrders(addr,orderID);
	}
	/*function getHistory(address r, uint s) public view returns (bool,uint8, uint8,uint256){
		if(bcontract.nodeLatestAction(r) <= s) return (false,0,0,0);
		(FiftyContract.nodeActionType aT, uint8 nP, uint256 tT) = bcontract.nodeActionHistory(r,s);
		uint8 actType;
		if(aT == FiftyContract.nodeActionType.joinMember) actType=0;
		if(aT == FiftyContract.nodeActionType.startTree) actType=1;
		if(aT == FiftyContract.nodeActionType.addNode) actType=2;
		if(aT == FiftyContract.nodeActionType.completeTree) actType=3;
		return (true,actType,nP,tT);
	}*/
	function getCurrentTree(address r, uint t) public view returns(address[7] memory){
		address[7] memory Adds;
		if(bcontract.nodeIDIndex(r,t) > (2 ** 32) -2 || !bcontract.currentNodes(r,t)) 
		    return Adds;
		uint cc=bcontract.nodeIDIndex(r,t) - 1;
		Adds[0]=r;
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
	function getMemberShip(address r) public view returns(uint){
		return bcontract.membership(r);
	}
}