pragma solidity >=0.4.22 <0.6.0;

library ArrayUtil {
function IndexOf(uint[] storage values, uint value) internal returns(uint) {
    uint i = 0;
    while (values[i] != value) {
      i++;
    }
    return i;
  }

  function RemoveByValue(uint[] storage values, uint value) internal {
    uint i = IndexOf(values, value);
    RemoveByIndex(values, i);
  }

  function RemoveByIndex(uint[] storage values, uint i) internal {
    while (i<values.length-1) {
      values[i] = values[i+1];
      i++;
    }
    values.length--;
  }
}

contract UbexContract {
    address public owner = msg.sender;
    modifier onlyBy(address _account)
    {
        require(
            msg.sender == _account,
            "Sender not authorized."
        );
        _;
    }

    struct RequestsIndex {
        address addr;
        bool isEntity;
        uint256 amount;
        bytes32 hash;
    }
	
	event requestAdded(
        uint indexed _id,
        address _addr,
        uint _amount
    );
	
	event requestUpdated(
		uint indexed _id,
        address indexed _addr,
        bytes32 _hash
    );
	
    // Requests ids
    mapping(uint256 => RequestsIndex) public requestsIDsIndex;

    // Queue of open requests
    uint[] queue;

    function addRequest(uint id, address addr, uint256 amount) public onlyBy(owner) returns (bool success) {
		if (isEntity(id)) {
			return false;
		}

		queue.push(id);

		requestsIDsIndex[id] = RequestsIndex({
			addr: addr,
			amount: amount,
			hash: 0,
			isEntity: true
		});
		emit requestAdded(id, addr, amount);
        return true;
    }

    function getQueueSize() public view returns (uint size) {
        return queue.length;
    }

    function getAddrById(uint _id) public view returns (address _addr){
        return requestsIDsIndex[_id].addr;
    }

    function getRequestById(uint256 _id) public view returns(address addr, uint256 amount, bytes32 hash) {
        RequestsIndex memory a = requestsIDsIndex[_id];
        return (a.addr, a.amount, a.hash);
    }

    function isEntity(uint _id) public view returns (bool isIndeed) {
        return requestsIDsIndex[_id].isEntity;
    }
    
    function closeRequest(uint _id, bytes32 _hash) public onlyBy(owner) {
        requestsIDsIndex[_id].hash = _hash;
        ArrayUtil.RemoveByValue(queue, _id);
		emit requestUpdated(_id, requestsIDsIndex[_id].addr, _hash);
    }
}