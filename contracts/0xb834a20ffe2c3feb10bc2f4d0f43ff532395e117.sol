pragma solidity ^0.4.8;

contract IProxy{
	function raiseTransferEvent(address _from, address _to, uint256 _value) returns (bool success) {}
	function raiseApprovalEvent(address _owner, address _spender, uint256 _value) returns (bool success){}
}

contract ProxyManagementContract{

  
    address public dev;
    address public curator;
    address public tokenAddress;

    address[] public proxyList; 

    mapping (address => bool) approvedProxies;
    IProxy dedicatedProxy;


    function ProxyManagementContract(){
        dev = msg.sender;
    }

    function addProxy(address _proxyAdress) returns (uint error){
        if(msg.sender != curator){ return 1;}
        
        approvedProxies[_proxyAdress] = true;
        proxyList.push(_proxyAdress);
        return 0;
    }

    function removeProxy(address _proxyAddress) returns (uint error){
        if(msg.sender != curator){ return 1; }
        if (!approvedProxies[_proxyAddress]) { return 55; }
        
        uint temAddressArrayLength = proxyList.length - 1;
        uint newArrayCnt = 0;
        address[] memory tempAddressArray = new address[](temAddressArrayLength);
        
        for (uint cnt = 0; cnt < proxyList.length; cnt++){
            if (_proxyAddress == proxyList[cnt]){
                approvedProxies[_proxyAddress] = false;
            }
            else{
                tempAddressArray[newArrayCnt] = proxyList[cnt];
                newArrayCnt += 1;
            }
        }
        proxyList = tempAddressArray;
        return 0;
    }

    function changeDedicatedProxy(address _contractAddress) returns (uint error){
        if(msg.sender != curator){ return 1;}
        
        dedicatedProxy = IProxy(_contractAddress);
        return 0;
    }

    function raiseTransferEvent(address _from, address _to, uint256 _value) returns (uint error){
        if (msg.sender != tokenAddress) { return 1; }
        
        dedicatedProxy.raiseTransferEvent(_from, _to, _value);
        return 0;
    }

    function raiseApprovalEvent(address _owner, address _spender, uint256 _value) returns (uint error){
        if (msg.sender == tokenAddress) { return 1; }

        dedicatedProxy.raiseApprovalEvent(_owner, _spender, _value);
        return 0;
    }

    function setProxyManagementCurator(address _curatorAdress) returns (uint error){
        if (msg.sender != dev){ return 1; }
              
        curator = _curatorAdress;
        return 0;
    }

    function setDedicatedProxy(address _contractAddress) returns (uint error){
        if (msg.sender != curator){ return 1; }
              
        dedicatedProxy = IProxy(_contractAddress);
        return 0;
    }

    function setTokenAddress(address _contractAddress) returns (uint error){
        if (msg.sender != curator){ return 1; }
        
        tokenAddress = _contractAddress;
        return 0;
    }

    function killContract() returns (uint error){
        if (msg.sender != dev){ return 1; }

        selfdestruct(dev);
        return 0;
    }

    function dedicatedProxyAddress() constant returns (address contractAddress){
        return address(dedicatedProxy);
    }

    function getApprovedProxies() constant returns (address[] proxies){
        return proxyList;
    }

    function isProxyLegit(address _proxyAddress) constant returns (bool isLegit){
        if (_proxyAddress == address(dedicatedProxy)){ return true; }
        return approvedProxies[_proxyAddress];
    }

    function () {
        throw;
    }
}