pragma solidity 0.4.25;


contract Nodes {
	address public owner;
	mapping (uint => Node) public nodes; 
	mapping (string => uint) nodesID;
	mapping (string => uint16) nodeGroupsId;
	mapping (uint16 => string) public nodeGroups;
	mapping (address => string) public confirmationNodes;
	uint16 public nodeGroupID;
	uint public nodeID;
	
	struct Node {
		string nodeName;
		address producer;
		address node;
		uint256 date;
		uint8 starmidConfirmed; //0 - not confirmed; 1 - confirmed; 2 - caution
		string confirmationPost;
		outsourceConfirmStruct[] outsourceConfirmed;
		uint16[] nodeGroup;
		uint8 producersPercent;
	}
	
	struct outsourceConfirmStruct {
		uint8 confirmationStatus;
		address confirmationNode;
		string confirmationPost;
	}
	
	event NewNode(
		uint256 id, 
		string nodeName, 
		uint8 producersPercent, 
		address producer, 
		uint date
		);
	event NewNodeGroup(uint16 id, string newNodeGroup);
	event AddNodeAddress(uint nodeID, address nodeAdress);
	event EditNode(uint nodeID,	address newProducer, uint8 newProducersPercent);
	event ConfirmNode(uint nodeID, uint8 confirmationStatus, string confirmationPost);
	event OutsourceConfirmNode(uint nodeID, uint8 confirmationStatus, address confirmationNode, string confirmationPost);
	event ChangePercent(uint nodeId, uint producersPercent);
	event PushNodeGroup(uint nodeId, uint newNodeGroup);
	event DeleteNodeGroup(uint nodeId, uint deleteNodeGroup);
	
	modifier onlyOwner {
		require(msg.sender == owner);
		_;
	}
	
	function addConfirmationNode(string _newConfirmationNode) public returns(bool) {
		confirmationNodes[msg.sender] = _newConfirmationNode;
		return true;
	}
	
	function addNodeGroup(string _newNodeGroup) public onlyOwner returns(bool _result, uint16 _id) {
		require (nodeGroupsId[_newNodeGroup] == 0);
		_id = nodeGroupID += 1;
		nodeGroups[_id] = _newNodeGroup;
		nodeGroupsId[_newNodeGroup] = nodeGroupID;
		_result = true;
		emit NewNodeGroup(_id, _newNodeGroup);
	}
	
	function addNode(string _newNode, uint8 _producersPercent) public returns (bool _result, uint _id) {
		require(nodesID[_newNode] < 1 && _producersPercent < 100);
		_id = nodeID += 1;
		require(nodeID < 1000000000000);
		nodes[nodeID].nodeName = _newNode;
		nodes[nodeID].producer = msg.sender;
		nodes[nodeID].date = block.timestamp;
		nodes[nodeID].producersPercent = _producersPercent;
		nodesID[_newNode] = nodeID;
		emit NewNode(_id, _newNode, _producersPercent, msg.sender, block.timestamp);
		_result = true;
	}
	
	function editNode(
		uint _nodeID, 
		address _newProducer, 
		uint8 _newProducersPercent
		) public onlyOwner returns (bool) {
			nodes[_nodeID].producer = _newProducer;
			nodes[_nodeID].producersPercent = _newProducersPercent;
			emit EditNode(_nodeID, _newProducer, _newProducersPercent);
			return true;
	}
	
	function addNodeAddress(uint _nodeID, address _nodeAddress) public returns(bool _result) {
		require(msg.sender == nodes[_nodeID].producer && nodes[_nodeID].node == 0);
		nodes[_nodeID].node = _nodeAddress;
		emit AddNodeAddress( _nodeID, _nodeAddress);
		_result = true;
	}
	
	function pushNodeGroup(uint _nodeID, uint16 _newNodeGroup) public returns(bool) {
		require(msg.sender == nodes[_nodeID].node || msg.sender == nodes[_nodeID].producer);
		nodes[_nodeID].nodeGroup.push(_newNodeGroup);
		emit PushNodeGroup(_nodeID, _newNodeGroup);
		return true;
	}
	
	function deleteNodeGroup(uint _nodeID, uint16 _deleteNodeGroup) public returns(bool) {
		require(msg.sender == nodes[_nodeID].node  || msg.sender == nodes[_nodeID].producer);
		for(uint16 i = 0; i < nodes[_nodeID].nodeGroup.length; i++) {
			if(_deleteNodeGroup == nodes[_nodeID].nodeGroup[i]) {
				for(uint16 ii = i; ii < nodes[_nodeID].nodeGroup.length - 1; ii++) 
					nodes[_nodeID].nodeGroup[ii] = nodes[_nodeID].nodeGroup[ii + 1];
		    	delete nodes[_nodeID].nodeGroup[nodes[_nodeID].nodeGroup.length - 1];
				nodes[_nodeID].nodeGroup.length--;
				break;
		    }
	    }
		emit DeleteNodeGroup(_nodeID, _deleteNodeGroup);
		return true;
    }
	
	function confirmNode(uint _nodeID, string confirmationPost, uint8 confirmationStatus) public onlyOwner returns(bool) {
		nodes[_nodeID].starmidConfirmed = confirmationStatus;
		nodes[_nodeID].confirmationPost = confirmationPost;
		emit ConfirmNode(_nodeID, confirmationStatus, confirmationPost);
		return true;
	}
	
	function outsourceConfirmNode(uint _nodeID, string confirmationPost, uint8 confirmationStatus) public returns(bool) {
		nodes[_nodeID].outsourceConfirmed.push(outsourceConfirmStruct(confirmationStatus, msg.sender, confirmationPost));
		emit OutsourceConfirmNode(_nodeID, confirmationStatus, msg.sender, confirmationPost);
		return true;
	}
	
	function changePercent(uint _nodeId, uint8 _producersPercent) public returns(bool) {
		require(msg.sender == nodes[_nodeId].producer && nodes[_nodeId].node == 0x0000000000000000000000000000000000000000);
		nodes[_nodeId].producersPercent = _producersPercent;
		emit ChangePercent(_nodeId, _producersPercent);
		return true;
	}
	
	function getNodeInfo(uint _nodeID) constant public returns(
		address _producer, 
		address _node, 
		uint _date, 
		uint8 _starmidConfirmed, 
		string _nodeName, 
		uint16[] _nodeGroup, 
		uint _producersPercent, 
		string _confirmationPost
		) {
		_producer = nodes[_nodeID].producer;
		_node = nodes[_nodeID].node;
		_date = nodes[_nodeID].date;
		_starmidConfirmed = nodes[_nodeID].starmidConfirmed;
		_nodeName = nodes[_nodeID].nodeName;
		_nodeGroup = nodes[_nodeID].nodeGroup;
		_producersPercent = nodes[_nodeID].producersPercent;
		_confirmationPost = nodes[_nodeID].confirmationPost;
	}
	
	function getOutsourceConfirmation(uint _nodeID, uint _number) constant public returns(
		uint _confirmationStatus, 
		address _confirmationNode, 
		string _confirmationNodeName, 
		string _confirmationPost
		) {
			_confirmationStatus = nodes[_nodeID].outsourceConfirmed[_number].confirmationStatus;
			_confirmationNode = nodes[_nodeID].outsourceConfirmed[_number].confirmationNode;
			_confirmationNodeName = confirmationNodes[_confirmationNode];
			_confirmationPost = nodes[_nodeID].outsourceConfirmed[_number].confirmationPost;
		}
}	

contract Starmid is Nodes {
	uint24 public emissionLimits;
	uint8 public feeMultipliedByTen;
	mapping (uint => emissionNodeInfo) public emissions;
	mapping (address => mapping (uint => uint)) balanceOf;
	mapping (address => mapping (uint => uint)) frozen;
	uint128 public orderId;
	mapping (uint => mapping (uint => orderInfo[])) buyOrders;
	mapping (uint => mapping (uint => orderInfo[])) sellOrders;
	mapping (uint => uint[]) buyOrderPrices;
	mapping (uint => uint[]) sellOrderPrices;
	mapping (address => uint) public pendingWithdrawals;
	address public multiKey;
	
	struct orderInfo {
		address client;
		uint amount;
		uint orderId;
		uint8 fee;
    }
	struct emissionNodeInfo {
		uint emissionNumber;
		uint date;
	}
	
	event Emission(uint node, uint date);
	event BuyOrder(uint orderId, uint node, uint buyPrice, uint amount);
	event SellOrder(uint orderId, uint node, uint sellPrice, uint amount);
	event CancelBuyOrder(uint orderId, uint node, uint price);
	event CancelSellOrder(uint orderId, uint node, uint price);
	event TradeHistory(uint node, uint date, address buyer, address seller, uint price, uint amount, uint orderId);
	
	constructor() public {
		owner = msg.sender;
		emissionLimits = 1000000;
		feeMultipliedByTen = 20;
	}
	
	//-----------------------------------------------------Starmid Exchange------------------------------------------------------
	function withdraw() public returns(bool _result, uint _amount) {
        _amount = pendingWithdrawals[msg.sender];
        pendingWithdrawals[msg.sender] = 0;
        msg.sender.transfer(_amount);
		_result = true;
    }
	
	function changeOwner(address _newOwnerAddress) public returns(bool) {
		require(msg.sender == owner || msg.sender == 0x1335995a62a6769b0a44a8fcc08d9c3324456df0);
		if(multiKey == 0x0000000000000000000000000000000000000000)
			multiKey = msg.sender;
		if(multiKey == owner && msg.sender == 0x1335995a62a6769b0a44a8fcc08d9c3324456df0) {
			owner = _newOwnerAddress;
			multiKey = 0x0000000000000000000000000000000000000000;
			return true;
		}
		if(multiKey == 0x1335995a62a6769b0a44a8fcc08d9c3324456df0 && msg.sender == owner) {
			owner = _newOwnerAddress;
			multiKey = 0x0000000000000000000000000000000000000000;
			return true;
		}
	}
	
	function changeFee(uint8 _newFee) public onlyOwner returns(bool) {
		feeMultipliedByTen = _newFee;
		return true;
	}
	
	function getEmission(uint _node) constant public returns(uint _emissionNumber, uint _emissionDate) {
		_emissionNumber = emissions[_node].emissionNumber;
		_emissionDate = emissions[_node].date;
	}
	
	function emission(uint _node) public returns(bool _result, uint _producersPercent) {
		address _nodeProducer = nodes[_node].producer;
		address _nodeOwner = nodes[_node].node;
		_producersPercent = nodes[_node].producersPercent;
		require(msg.sender == _nodeOwner || msg.sender == _nodeProducer);
		require(_nodeOwner != 0x0000000000000000000000000000000000000000 && emissions[_node].emissionNumber == 0);
		balanceOf[_nodeOwner][_node] += emissionLimits*(100 - _producersPercent)/100;
		balanceOf[_nodeProducer][_node] += emissionLimits*_producersPercent/100;
		emissions[_node].date = block.timestamp;
		emissions[_node].emissionNumber = 1;
		emit Emission(_node, block.timestamp);
		_result = true;
	}
	
	function getStockBalance(address _address, uint _node) constant public returns(uint _balance) {
		_balance = balanceOf[_address][_node];
	}
	
	function getWithFrozenStockBalance(address _address, uint _node) constant public returns(uint _balance) {
		_balance = balanceOf[_address][_node] + frozen[_address][_node];
	}
	
	function getOrderInfo(bool _isBuyOrder, uint _node, uint _price, uint _number) constant public returns
	(address _address, uint _amount, uint _orderId, uint8 _fee) {
		if(_isBuyOrder == true) {
			_address = buyOrders[_node][_price][_number].client;
			_amount = buyOrders[_node][_price][_number].amount;
			_orderId = buyOrders[_node][_price][_number].orderId;
			_fee = buyOrders[_node][_price][_number].fee;
		}
		else {
			_address = sellOrders[_node][_price][_number].client;
			_amount = sellOrders[_node][_price][_number].amount;
			_orderId = sellOrders[_node][_price][_number].orderId;
		}
	}
	
	function getBuyOrderPrices(uint _node) constant public returns(uint[] _prices) {
		_prices = buyOrderPrices[_node];
	}
	
	function getSellOrderPrices(uint _node) constant public returns(uint[] _prices) {
		_prices = sellOrderPrices[_node];
	}
	
	function buyOrder(uint _node, uint _buyPrice, uint _amount) payable public returns (bool _result, uint _orderId) {
		//check if there is a better price
		uint _minSellPrice = _buyPrice + 1;
		for (uint i = 0; i < sellOrderPrices[_node].length; i++) {
			if(sellOrderPrices[_node][i] < _minSellPrice) 
				_minSellPrice = sellOrderPrices[_node][i];
		}
		require(_node > 0 && _buyPrice > 0 && _amount > 0 && msg.value > 0 && _buyPrice < _minSellPrice);
		require(msg.value == _amount*_buyPrice + _amount*_buyPrice*feeMultipliedByTen/1000);
		_orderId = orderId += 1;
		buyOrders[_node][_buyPrice].push(orderInfo(msg.sender, _amount, _orderId, feeMultipliedByTen));
		//Add _buyPrice to buyOrderPrices[_node][]
		uint it = 999999;
		for (uint itt = 0; itt < buyOrderPrices[_node].length; itt++) {
			if (buyOrderPrices[_node][itt] == _buyPrice) 
				it = itt;
		}
		if (it == 999999) 
			buyOrderPrices[_node].push(_buyPrice);
		_result = true;
		emit BuyOrder(orderId, _node, _buyPrice, _amount);
	}
	
	function sellOrder(uint _node, uint _sellPrice, uint _amount) public returns (bool _result, uint _orderId) {
		//check if there is a better price
		uint _maxBuyPrice = _sellPrice - 1;
		for (uint i = 0; i < buyOrderPrices[_node].length; i++) {
			if(buyOrderPrices[_node][i] > _maxBuyPrice) 
				_maxBuyPrice = buyOrderPrices[_node][i];
		}
		require(_node > 0 && _sellPrice > 0 && _amount > 0 && balanceOf[msg.sender][_node] >= _amount && _sellPrice > _maxBuyPrice);
		_orderId = orderId += 1;
		sellOrders[_node][_sellPrice].push(orderInfo(msg.sender, _amount, _orderId, feeMultipliedByTen));
		//transfer stocks to the frozen balance
		frozen[msg.sender][_node] += _amount;
		balanceOf[msg.sender][_node] -= _amount;
		//Add _sellPrice to sellOrderPrices[_node][]
		uint it = 999999;
		for (uint itt = 0; itt < sellOrderPrices[_node].length; itt++) {
			if (sellOrderPrices[_node][itt] == _sellPrice) 
				it = itt;
		}
		if (it == 999999) 
			sellOrderPrices[_node].push(_sellPrice);
		_result = true;
		emit SellOrder(orderId, _node, _sellPrice, _amount);
	}
	
	function cancelBuyOrder(uint _node, uint _orderId, uint _price) public returns (bool _result) {
		orderInfo[] buyArr = buyOrders[_node][_price];
		for (uint iii = 0; iii < buyArr.length; iii++) {
			if (buyArr[iii].orderId == _orderId) {
				require(msg.sender == buyArr[iii].client);
				pendingWithdrawals[msg.sender] += _price*buyArr[iii].amount + _price*buyArr[iii].amount*buyArr[iii].fee/1000;//returns ether and fee to the buyer
				//delete buyOrders[_node][_price][iii] and move each element
				for (uint ii = iii; ii < buyArr.length - 1; ii++) {
					buyArr[ii] = buyArr[ii + 1];
				}
				delete buyArr[buyArr.length - 1];
				buyArr.length--;
				break;
			}
		}
		//Delete _price from buyOrderPrices[_node][] if it's the last order
		if (buyArr.length == 0) {
			uint _fromArg = 99999;
			for (iii = 0; iii < buyOrderPrices[_node].length - 1; iii++) {
				if (buyOrderPrices[_node][iii] == _price) {
					_fromArg = iii;
				}
				if (_fromArg != 99999 && iii >= _fromArg) buyOrderPrices[_node][iii] = buyOrderPrices[_node][iii + 1];
			}
			delete buyOrderPrices[_node][buyOrderPrices[_node].length-1];
			buyOrderPrices[_node].length--;
		}
		_result = true;
		emit CancelBuyOrder(_orderId, _node, _price);
	}
	
	function cancelSellOrder(uint _node, uint _orderId, uint _price) public returns (bool _result) {
		orderInfo[] sellArr = sellOrders[_node][_price];
		for (uint iii = 0; iii < sellArr.length; iii++) {
			if (sellArr[iii].orderId == _orderId) {
				require(msg.sender == sellArr[iii].client);
				//return stocks from the frozen balance to seller
				frozen[msg.sender][_node] -= sellArr[iii].amount;
				balanceOf[msg.sender][_node] += sellArr[iii].amount;
				//delete sellOrders[_node][_price][iii] and move each element
				for (uint ii = iii; ii < sellArr.length - 1; ii++) {
					sellArr[ii] = sellArr[ii + 1];
				}
				delete sellArr[sellArr.length - 1];
				sellArr.length--;
				break;
			}
		}
		//Delete _price from sellOrderPrices[_node][] if it's the last order
		if (sellArr.length == 0) {
			uint _fromArg = 99999;
			for (iii = 0; iii < sellOrderPrices[_node].length - 1; iii++) {
				if (sellOrderPrices[_node][iii] == _price) {
					_fromArg = iii;
				}
				if (_fromArg != 99999 && iii >= _fromArg) sellOrderPrices[_node][iii] = sellOrderPrices[_node][iii + 1];
			}
			delete sellOrderPrices[_node][sellOrderPrices[_node].length-1];
			sellOrderPrices[_node].length--;
		}
		_result = true;
		emit CancelSellOrder(_orderId, _node, _price);
	}
	
	function buyCertainOrder(uint _node, uint _price, uint _amount, uint _orderId) payable public returns (bool _result) {
		require(_node > 0 && _price > 0 && _amount > 0 && msg.value > 0 );
		orderInfo[] sellArr = sellOrders[_node][_price];
		for (uint iii = 0; iii < sellArr.length; iii++) {
			if (sellArr[iii].orderId == _orderId) {
				require(_amount <= sellArr[iii].amount && msg.value == _amount*_price + _amount*_price*feeMultipliedByTen/1000);
				address _client = sellArr[iii].client;
				//buy stocks for ether
				balanceOf[msg.sender][_node] += _amount;// adds the amount to buyer's balance
				frozen[_client][_node] -= _amount;// subtracts the amount from seller's frozen balance
				//transfer ether to the seller and fee to a contract owner
				pendingWithdrawals[_client] += _price*_amount;
				pendingWithdrawals[owner] += _price*_amount*feeMultipliedByTen/1000;
				//save the transaction
				emit TradeHistory(_node, block.timestamp, msg.sender, _client, _price, _amount, _orderId);
				//delete sellArr[iii] and move each element
				if (_amount == sellArr[iii].amount) {
					for (uint ii = iii; ii < sellArr.length - 1; ii++) 
						sellArr[ii] = sellArr[ii + 1];
					delete sellArr[sellArr.length - 1];
					sellArr.length--;
				}
				else {
					sellArr[iii].amount = sellArr[iii].amount - _amount;//edit sellOrders
				}
				//Delete _price from sellOrderPrices[_node][] if it's the last order
				if (sellArr.length == 0) {
					uint _fromArg = 99999;
					for (uint i = 0; i < sellOrderPrices[_node].length - 1; i++) {
						if (sellOrderPrices[_node][i] == _price) {
							_fromArg = i;
						}
						if (_fromArg != 99999 && i >= _fromArg) sellOrderPrices[_node][i] = sellOrderPrices[_node][i + 1];
					}
					delete sellOrderPrices[_node][sellOrderPrices[_node].length-1];
					sellOrderPrices[_node].length--;
				}
				break;
			}
		}
		_result = true;
	}
	
	function sellCertainOrder(uint _node, uint _price, uint _amount, uint _orderId) public returns (bool _result) {
		require(_node > 0 && _price > 0 && _amount > 0 );
		orderInfo[] buyArr = buyOrders[_node][_price];
		for (uint iii = 0; iii < buyArr.length; iii++) {
			if (buyArr[iii].orderId == _orderId) {
				require(_amount <= buyArr[iii].amount && balanceOf[msg.sender][_node] >= _amount);
				address _client = buyArr[iii].client;
				//sell stocks for ether
				balanceOf[_client][_node] += _amount;// adds the amount to buyer's balance
				balanceOf[msg.sender][_node] -= _amount;// subtracts the amount from seller's frozen balance
				//transfer ether to the seller and fee to a contract owner
				pendingWithdrawals[msg.sender] += _price*_amount;
				pendingWithdrawals[owner] += _price*_amount*buyArr[iii].fee/1000;
				//save the transaction
				emit TradeHistory(_node, block.timestamp, _client, msg.sender, _price, _amount, _orderId);
				//delete buyArr[iii] and move each element
				if (_amount == buyArr[iii].amount) {
					for (uint ii = iii; ii < buyArr.length - 1; ii++) 
						buyArr[ii] = buyArr[ii + 1];
					delete buyArr[buyArr.length - 1];
					buyArr.length--;
				}
				else {
					buyArr[iii].amount = buyArr[iii].amount - _amount;//edit buyOrders
				}
				//Delete _price from buyOrderPrices[_node][] if it's the last order
				if (buyArr.length == 0) {
					uint _fromArg = 99999;
					for (uint i = 0; i < buyOrderPrices[_node].length - 1; i++) {
						if (buyOrderPrices[_node][i] == _price) {
							_fromArg = i;
						}
						if (_fromArg != 99999 && i >= _fromArg) buyOrderPrices[_node][i] = buyOrderPrices[_node][i + 1];
					}
					delete buyOrderPrices[_node][buyOrderPrices[_node].length-1];
					buyOrderPrices[_node].length--;
				}
				break;
			}
		}
		_result = true;
	}
}