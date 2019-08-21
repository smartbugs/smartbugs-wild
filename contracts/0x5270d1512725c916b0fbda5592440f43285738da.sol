pragma solidity ^0.5.10;


contract Custodian {

  
    struct Request {
        bytes32 lockId;
        bytes4 callbackSelector;
        address callbackAddress;
        uint256 idx;
        uint256 timestamp;
        bool extended;
    }

  
    event Requested(
        bytes32 _lockId,
        address _callbackAddress,
        bytes4 _callbackSelector,
        uint256 _nonce,
        address _whitelistedAddress,
        bytes32 _requestMsgHash,
        uint256 _timeLockExpiry
    );

  
    event TimeLocked(
        uint256 _timeLockExpiry,
        bytes32 _requestMsgHash
    );

    
    event Completed(
        bytes32 _lockId,
        bytes32 _requestMsgHash,
        address _signer1,
        address _signer2
    );

  
    event Failed(
        bytes32 _lockId,
        bytes32 _requestMsgHash,
        address _signer1,
        address _signer2
    );

   
    event TimeLockExtended(
        uint256 _timeLockExpiry,
        bytes32 _requestMsgHash
    );

  
    uint256 public requestCount;

   
    mapping (address => bool) public signerSet;

    
    mapping (bytes32 => Request) public requestMap;

   
    mapping (address => mapping (bytes4 => uint256)) public lastCompletedIdxs;

   
    uint256 public defaultTimeLock;

   
    uint256 public extendedTimeLock;

   
    address public primary;

  
    constructor(
        address[] memory _signers,
        uint256 _defaultTimeLock,
        uint256 _extendedTimeLock,
        address _primary
    )
        public
    {
        
        require(_signers.length >= 2);

      
        require(_defaultTimeLock <= _extendedTimeLock);
        defaultTimeLock = _defaultTimeLock;
        extendedTimeLock = _extendedTimeLock;

        primary = _primary;

        
        requestCount = 0;
        
        for (uint i = 0; i < _signers.length; i++) {
            
            require(_signers[i] != address(0) && !signerSet[_signers[i]]);
            signerSet[_signers[i]] = true;
        }
    }

   
    modifier onlyPrimary {
        require(msg.sender == primary);
        _;
    }

  
    function requestUnlock(
        bytes32 _lockId,
        address _callbackAddress,
        bytes4 _callbackSelector,
        address _whitelistedAddress
    )
        public
        payable
        returns (bytes32 requestMsgHash)
    {
        require(msg.sender == primary || msg.value >= 1 ether);

       
        require(_callbackAddress != address(0));

        uint256 requestIdx = ++requestCount;
      
        uint256 nonce = uint256(keccak256(abi.encodePacked(blockhash(block.number - 1), address(this), requestIdx)));

        requestMsgHash = keccak256(abi.encodePacked(nonce, _whitelistedAddress, uint256(0xFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFFF)));
        requestMap[requestMsgHash] = Request({
            lockId: _lockId,
            callbackSelector: _callbackSelector,
            callbackAddress: _callbackAddress,
            idx: requestIdx,
            timestamp: block.timestamp,
            extended: false
        });

      
        uint256 timeLockExpiry = block.timestamp;
        if (msg.sender == primary) {
            timeLockExpiry += defaultTimeLock;
        } else {
            timeLockExpiry += extendedTimeLock;

          
            requestMap[requestMsgHash].extended = true;
        }

        emit Requested(_lockId, _callbackAddress, _callbackSelector, nonce, _whitelistedAddress, requestMsgHash, timeLockExpiry);
    }

    
    function completeUnlock(
        bytes32 _requestMsgHash,
        uint8 _recoveryByte1, bytes32 _ecdsaR1, bytes32 _ecdsaS1,
        uint8 _recoveryByte2, bytes32 _ecdsaR2, bytes32 _ecdsaS2
    )
        public
        returns (bool success)
    {
        Request storage request = requestMap[_requestMsgHash];

        bytes32 lockId = request.lockId;
        address callbackAddress = request.callbackAddress;
        bytes4 callbackSelector = request.callbackSelector;

       
        require(callbackAddress != address(0));

      
        require(request.idx > lastCompletedIdxs[callbackAddress][callbackSelector]);
        
        address signer1 =  ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _requestMsgHash)), _recoveryByte1,_ecdsaR1, _ecdsaS1);
        require(signerSet[signer1]);

        address signer2 =  ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32", _requestMsgHash)), _recoveryByte2, _ecdsaR2, _ecdsaS2);
        require(signerSet[signer2]);
        require(signer1 != signer2);

        if (request.extended && ((block.timestamp - request.timestamp) < extendedTimeLock)) {
            emit TimeLocked(request.timestamp + extendedTimeLock, _requestMsgHash);
            return false;
        } else if ((block.timestamp - request.timestamp) < defaultTimeLock) {
            emit TimeLocked(request.timestamp + defaultTimeLock, _requestMsgHash);
            return false;
        } else {
            if (address(this).balance > 0) {
                
                success = msg.sender.send(address(this).balance);
            }

         
            lastCompletedIdxs[callbackAddress][callbackSelector] = request.idx;
           
            delete requestMap[_requestMsgHash];

           
            (success,) = callbackAddress.call(abi.encodeWithSelector(callbackSelector, lockId));

            if (success) {
                emit Completed(lockId, _requestMsgHash, signer1, signer2);
            } else {
                emit Failed(lockId, _requestMsgHash, signer1, signer2);
            }
        }
    }

    function deleteUncompletableRequest(bytes32 _requestMsgHash) public {
        Request storage request = requestMap[_requestMsgHash];

        uint256 idx = request.idx;

        require(0 < idx && idx < lastCompletedIdxs[request.callbackAddress][request.callbackSelector]);

        delete requestMap[_requestMsgHash];
    }

  
    function extendRequestTimeLock(bytes32 _requestMsgHash) public onlyPrimary {
        Request storage request = requestMap[_requestMsgHash];

     
        require(request.callbackAddress != address(0));

       
        require(request.extended != true);

        
        request.extended = true;

        emit TimeLockExtended(request.timestamp + extendedTimeLock, _requestMsgHash);
    }
}

contract LockRequestable {

   
    uint256 public lockRequestCount;

    
    constructor() public {
        lockRequestCount = 0;
    }

    function generateLockId() internal returns (bytes32 lockId) {
        return keccak256(abi.encodePacked(blockhash(block.number - 1), address(this), ++lockRequestCount));
    }
}

contract ERC20Interface {
 
  function totalSupply() public view returns (uint256);

 
  function balanceOf(address _owner) public view returns (uint256 balance);

  
  function transfer(address _to, uint256 _value) public returns (bool success);

 
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

  
  function approve(address _spender, uint256 _value) public returns (bool success);

 
  function allowance(address _owner, address _spender) public view returns (uint256 remaining);

  
  event Transfer(address indexed _from, address indexed _to, uint256 _value);

  event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract CustodianUpgradeable is LockRequestable {

    
    struct CustodianChangeRequest {
        address proposedNew;
    }

  
    address public custodian;

    
    mapping (bytes32 => CustodianChangeRequest) public custodianChangeReqs;

  
    constructor(
        address _custodian
    )
      LockRequestable()
      public
    {
        custodian = _custodian;
    }

   
    modifier onlyCustodian {
        require(msg.sender == custodian);
        _;
    }

    function requestCustodianChange(address _proposedCustodian) public returns (bytes32 lockId) {
        require(_proposedCustodian != address(0));

        lockId = generateLockId();

        custodianChangeReqs[lockId] = CustodianChangeRequest({
            proposedNew: _proposedCustodian
        });

        emit CustodianChangeRequested(lockId, msg.sender, _proposedCustodian);
    }

   
    function confirmCustodianChange(bytes32 _lockId) public onlyCustodian {
        custodian = getCustodianChangeReq(_lockId);

        delete custodianChangeReqs[_lockId];

        emit CustodianChangeConfirmed(_lockId, custodian);
    }

   
    function getCustodianChangeReq(bytes32 _lockId) private view returns (address _proposedNew) {
        CustodianChangeRequest storage changeRequest = custodianChangeReqs[_lockId];

       
        require(changeRequest.proposedNew != address(0));

        return changeRequest.proposedNew;
    }
   
    event CustodianChangeRequested(
        bytes32 _lockId,
        address _msgSender,
        address _proposedCustodian
    );

    event CustodianChangeConfirmed(bytes32 _lockId, address _newCustodian);
}

contract ERC20ImplUpgradeable is CustodianUpgradeable  {

   
    struct ImplChangeRequest {
        address proposedNew;
    }

   
    ERC20Impl public erc20Impl;

   
    mapping (bytes32 => ImplChangeRequest) public implChangeReqs;

   
    constructor(address _custodian) CustodianUpgradeable(_custodian) public {
        erc20Impl = ERC20Impl(0x0);
    }

   
    modifier onlyImpl {
        require(msg.sender == address(erc20Impl));
        _;
    }

    
    function requestImplChange(address _proposedImpl) public returns (bytes32 lockId) {
        require(_proposedImpl != address(0));

        lockId = generateLockId();

        implChangeReqs[lockId] = ImplChangeRequest({
            proposedNew: _proposedImpl
        });

        emit ImplChangeRequested(lockId, msg.sender, _proposedImpl);
    }

   
    function confirmImplChange(bytes32 _lockId) public onlyCustodian {
        erc20Impl = getImplChangeReq(_lockId);

        delete implChangeReqs[_lockId];

        emit ImplChangeConfirmed(_lockId, address(erc20Impl));
    }

    
    function getImplChangeReq(bytes32 _lockId) private view returns (ERC20Impl _proposedNew) {
        ImplChangeRequest storage changeRequest = implChangeReqs[_lockId];

     
        require(changeRequest.proposedNew != address(0));

        return ERC20Impl(changeRequest.proposedNew);
    }

  
    event ImplChangeRequested(
        bytes32 _lockId,
        address _msgSender,
        address _proposedImpl
    );

    
    event ImplChangeConfirmed(bytes32 _lockId, address _newImpl);
}

contract ERC20Proxy is ERC20Interface, ERC20ImplUpgradeable {

   
    string public name;

    
    string public symbol;

    
    uint8 public decimals;

    
    constructor(
        string memory _name,
        string memory _symbol,
        uint8 _decimals,
        address _custodian
    )
        ERC20ImplUpgradeable(_custodian)
        public
    {
        name = _name;
        symbol = _symbol;
        decimals = _decimals;
    }

    
    function totalSupply() public view returns (uint256) {
        return erc20Impl.totalSupply();
    }

   
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return erc20Impl.balanceOf(_owner);
    }

    
    function emitTransfer(address _from, address _to, uint256 _value) public onlyImpl {
        emit Transfer(_from, _to, _value);
    }

    
    function transfer(address _to, uint256 _value) public returns (bool success) {
        return erc20Impl.transferWithSender(msg.sender, _to, _value);
    }

    
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        return erc20Impl.transferFromWithSender(msg.sender, _from, _to, _value);
    }

    function emitApproval(address _owner, address _spender, uint256 _value) public onlyImpl {
        emit Approval(_owner, _spender, _value);
    }

    function approve(address _spender, uint256 _value) public returns (bool success) {
        return erc20Impl.approveWithSender(msg.sender, _spender, _value);
    }
 
    function increaseApproval(address _spender, uint256 _addedValue) public returns (bool success) {
        return erc20Impl.increaseApprovalWithSender(msg.sender, _spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint256 _subtractedValue) public returns (bool success) {
        return erc20Impl.decreaseApprovalWithSender(msg.sender, _spender, _subtractedValue);
    }

    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return erc20Impl.allowance(_owner, _spender);
    }
}

contract ERC20Store is ERC20ImplUpgradeable {

    uint256 public totalSupply;

   
    mapping (address => uint256) public balances;

   
    mapping (address => mapping (address => uint256)) public allowed;

    
    constructor(address _custodian) ERC20ImplUpgradeable(_custodian) public {
        totalSupply = 0;
    }

    function setTotalSupply(
        uint256 _newTotalSupply
    )
        public
        onlyImpl
    {
        totalSupply = _newTotalSupply;
    }

    function setAllowance(
        address _owner,
        address _spender,
        uint256 _value
    )
        public
        onlyImpl
    {
        allowed[_owner][_spender] = _value;
    }

    function setBalance(
        address _owner,
        uint256 _newBalance
    )
        public
        onlyImpl
    {
        balances[_owner] = _newBalance;
    }

    function addBalance(
        address _owner,
        uint256 _balanceIncrease
    )
        public
        onlyImpl
    {
        balances[_owner] = balances[_owner] + _balanceIncrease;
    }
}

contract ERC20Impl is CustodianUpgradeable {

  
    struct PendingPrint {
        address receiver;
        uint256 value;
    }

    ERC20Proxy public erc20Proxy;


    ERC20Store public erc20Store;

   
    address public sweeper;

    
    bytes32 public sweepMsg;

    
    mapping (address => bool) public sweptSet;

    
    mapping (bytes32 => PendingPrint) public pendingPrintMap;

   
    constructor(
          address _erc20Proxy,
          address _erc20Store,
          address _custodian,
          address _sweeper
    )
        CustodianUpgradeable(_custodian)
        public
    {
        require(_sweeper != address(0));
        erc20Proxy = ERC20Proxy(_erc20Proxy);
        erc20Store = ERC20Store(_erc20Store);

        sweeper = _sweeper;
        sweepMsg = keccak256(abi.encodePacked(address(this), "sweep"));
    }

   
    modifier onlyProxy {
        require(msg.sender == address(erc20Proxy));
        _;
    }
    modifier onlySweeper {
        require(msg.sender == sweeper);
        _;
    }


   
    function approveWithSender(
        address _sender,
        address _spender,
        uint256 _value
    )
        public
        onlyProxy
        returns (bool success)
    {
        require(_spender != address(0));
        erc20Store.setAllowance(_sender, _spender, _value);
        erc20Proxy.emitApproval(_sender, _spender, _value);
        return true;
    }

   
    function increaseApprovalWithSender(
        address _sender,
        address _spender,
        uint256 _addedValue
    )
        public
        onlyProxy
        returns (bool success)
    {
        require(_spender != address(0)); 
        uint256 currentAllowance = erc20Store.allowed(_sender, _spender);
        uint256 newAllowance = currentAllowance + _addedValue;

        require(newAllowance >= currentAllowance);

        erc20Store.setAllowance(_sender, _spender, newAllowance);
        erc20Proxy.emitApproval(_sender, _spender, newAllowance);
        return true;
    }

    
    function decreaseApprovalWithSender(
        address _sender,
        address _spender,
        uint256 _subtractedValue
    )
        public
        onlyProxy
        returns (bool success)
    {
        require(_spender != address(0)); 
        uint256 currentAllowance = erc20Store.allowed(_sender, _spender);
        uint256 newAllowance = currentAllowance - _subtractedValue;

        require(newAllowance <= currentAllowance);

        erc20Store.setAllowance(_sender, _spender, newAllowance);
        erc20Proxy.emitApproval(_sender, _spender, newAllowance);
        return true;
    }

    
    function requestPrint(address _receiver, uint256 _value) public returns (bytes32 lockId) {
        require(_receiver != address(0));

        lockId = generateLockId();

        pendingPrintMap[lockId] = PendingPrint({
            receiver: _receiver,
            value: _value
        });

        emit PrintingLocked(lockId, _receiver, _value);
    }

   
    function confirmPrint(bytes32 _lockId) public onlyCustodian {
        PendingPrint storage print = pendingPrintMap[_lockId];

     
        address receiver = print.receiver;
        require (receiver != address(0));
        uint256 value = print.value;

        delete pendingPrintMap[_lockId];

        uint256 supply = erc20Store.totalSupply();
        uint256 newSupply = supply + value;
        if (newSupply >= supply) {
          erc20Store.setTotalSupply(newSupply);
          erc20Store.addBalance(receiver, value);

          emit PrintingConfirmed(_lockId, receiver, value);
          erc20Proxy.emitTransfer(address(0), receiver, value);
        }
    }

 
    function burn(uint256 _value) public returns (bool success) {
        uint256 balanceOfSender = erc20Store.balances(msg.sender);
        require(_value <= balanceOfSender);

        erc20Store.setBalance(msg.sender, balanceOfSender - _value);
        erc20Store.setTotalSupply(erc20Store.totalSupply() - _value);

        erc20Proxy.emitTransfer(msg.sender, address(0), _value);

        return true;
    }

  
    function batchTransfer(address[] memory _tos, uint256[] memory _values) public returns (bool success) {
        require(_tos.length == _values.length);

        uint256 numTransfers = _tos.length;
        uint256 senderBalance = erc20Store.balances(msg.sender);

        for (uint256 i = 0; i < numTransfers; i++) {
          address to = _tos[i];
          require(to != address(0));
          uint256 v = _values[i];
          require(senderBalance >= v);

          if (msg.sender != to) {
            senderBalance -= v;
            erc20Store.addBalance(to, v);
          }
          erc20Proxy.emitTransfer(msg.sender, to, v);
        }

        erc20Store.setBalance(msg.sender, senderBalance);

        return true;
    }

    
    function enableSweep(uint8[] memory _vs, bytes32[] memory _rs, bytes32[] memory _ss, address _to) public onlySweeper {
        require(_to != address(0));
        require((_vs.length == _rs.length) && (_vs.length == _ss.length));

        uint256 numSignatures = _vs.length;
        uint256 sweptBalance = 0;

        for (uint256 i=0; i<numSignatures; ++i) {
          address from = ecrecover(keccak256(abi.encodePacked("\x19Ethereum Signed Message:\n32",sweepMsg)), _vs[i], _rs[i], _ss[i]);

      
          if (from != address(0)) {
            sweptSet[from] = true;

            uint256 fromBalance = erc20Store.balances(from);

            if (fromBalance > 0) {
              sweptBalance += fromBalance;

              erc20Store.setBalance(from, 0);

              erc20Proxy.emitTransfer(from, _to, fromBalance);
            }
          }
        }

        if (sweptBalance > 0) {
          erc20Store.addBalance(_to, sweptBalance);
        }
    }

    
    function replaySweep(address[] memory _froms, address _to) public onlySweeper {
        require(_to != address(0));
        uint256 lenFroms = _froms.length;
        uint256 sweptBalance = 0;

        for (uint256 i=0; i<lenFroms; ++i) {
            address from = _froms[i];

            if (sweptSet[from]) {
                uint256 fromBalance = erc20Store.balances(from);

                if (fromBalance > 0) {
                    sweptBalance += fromBalance;

                    erc20Store.setBalance(from, 0);

                    erc20Proxy.emitTransfer(from, _to, fromBalance);
                }
            }
        }

        if (sweptBalance > 0) {
            erc20Store.addBalance(_to, sweptBalance);
        }
    }

   
    function transferFromWithSender(
        address _sender,
        address _from,
        address _to,
        uint256 _value
    )
        public
        onlyProxy
        returns (bool success)
    {
        require(_to != address(0)); 

        uint256 balanceOfFrom = erc20Store.balances(_from);
        require(_value <= balanceOfFrom);

        uint256 senderAllowance = erc20Store.allowed(_from, _sender);
        require(_value <= senderAllowance);

        erc20Store.setBalance(_from, balanceOfFrom - _value);
        erc20Store.addBalance(_to, _value);

        erc20Store.setAllowance(_from, _sender, senderAllowance - _value);

        erc20Proxy.emitTransfer(_from, _to, _value);

        return true;
    }

    function transferWithSender(
        address _sender,
        address _to,
        uint256 _value
    )
        public
        onlyProxy
        returns (bool success)
    {
        require(_to != address(0)); 
        uint256 balanceOfSender = erc20Store.balances(_sender);
        require(_value <= balanceOfSender);

        erc20Store.setBalance(_sender, balanceOfSender - _value);
        erc20Store.addBalance(_to, _value);

        erc20Proxy.emitTransfer(_sender, _to, _value);

        return true;
    }

    
    function totalSupply() public view returns (uint256) {
        return erc20Store.totalSupply();
    }

   
    function balanceOf(address _owner) public view returns (uint256 balance) {
        return erc20Store.balances(_owner);
    }

   
    function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
        return erc20Store.allowed(_owner, _spender);
    }

   
    event PrintingLocked(bytes32 _lockId, address _receiver, uint256 _value);
  
    event PrintingConfirmed(bytes32 _lockId, address _receiver, uint256 _value);
}

contract PrintLimiter is LockRequestable {

   
    struct PendingCeilingRaise {
        uint256 raiseBy;
    }

  
    ERC20Impl public erc20Impl;

   
    address public custodian;

    address public limitedPrinter;

    uint256 public totalSupplyCeiling;

    mapping (bytes32 => PendingCeilingRaise) public pendingRaiseMap;

    constructor(
        address _erc20Impl,
        address _custodian,
        address _limitedPrinter,
        uint256 _initialCeiling
    )
        public
    {
        erc20Impl = ERC20Impl(_erc20Impl);
        custodian = _custodian;
        limitedPrinter = _limitedPrinter;
        totalSupplyCeiling = _initialCeiling;
    }

   
    modifier onlyCustodian {
        require(msg.sender == custodian);
        _;
    }
    modifier onlyLimitedPrinter {
        require(msg.sender == limitedPrinter);
        _;
    }

    function limitedPrint(address _receiver, uint256 _value) public onlyLimitedPrinter {
        uint256 totalSupply = erc20Impl.totalSupply();
        uint256 newTotalSupply = totalSupply + _value;

        require(newTotalSupply >= totalSupply);
        require(newTotalSupply <= totalSupplyCeiling);
        erc20Impl.confirmPrint(erc20Impl.requestPrint(_receiver, _value));
    }

    function requestCeilingRaise(uint256 _raiseBy) public returns (bytes32 lockId) {
        require(_raiseBy != 0);

        lockId = generateLockId();

        pendingRaiseMap[lockId] = PendingCeilingRaise({
            raiseBy: _raiseBy
        });

        emit CeilingRaiseLocked(lockId, _raiseBy);
    }

    function confirmCeilingRaise(bytes32 _lockId) public onlyCustodian {
        PendingCeilingRaise storage pendingRaise = pendingRaiseMap[_lockId];

      
        uint256 raiseBy = pendingRaise.raiseBy;

        require(raiseBy != 0);

        delete pendingRaiseMap[_lockId];

        uint256 newCeiling = totalSupplyCeiling + raiseBy;
        if (newCeiling >= totalSupplyCeiling) {
            totalSupplyCeiling = newCeiling;

            emit CeilingRaiseConfirmed(_lockId, raiseBy, newCeiling);
        }
    }

  
    function lowerCeiling(uint256 _lowerBy) public onlyLimitedPrinter {
        uint256 newCeiling = totalSupplyCeiling - _lowerBy;
        // overflow check
        require(newCeiling <= totalSupplyCeiling);
        totalSupplyCeiling = newCeiling;

        emit CeilingLowered(_lowerBy, newCeiling);
    }

   
    function confirmPrintProxy(bytes32 _lockId) public onlyCustodian {
        erc20Impl.confirmPrint(_lockId);
    }

   
    function confirmCustodianChangeProxy(bytes32 _lockId) public onlyCustodian {
        erc20Impl.confirmCustodianChange(_lockId);
    }

   
    event CeilingRaiseLocked(bytes32 _lockId, uint256 _raiseBy);
  
    event CeilingRaiseConfirmed(bytes32 _lockId, uint256 _raiseBy, uint256 _newCeiling);

   
    event CeilingLowered(uint256 _lowerBy, uint256 _newCeiling);
}