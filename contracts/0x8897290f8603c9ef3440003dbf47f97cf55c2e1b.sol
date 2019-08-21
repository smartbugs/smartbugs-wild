pragma solidity ^0.4.22;
contract Ownable {
  address public owner;

  event OwnershipRenounced(address indexed previousOwner);
  event OwnershipTransferred(
    address indexed previousOwner,
    address indexed newOwner
  );

  /**
   * @dev 可拥有的构造函数将合同的原始“所有者”设置为发送者
   * account.
   */
  constructor() public {
    owner = msg.sender;
  }

  /**
   * @dev 如果由所有者以外的任何帐户调用，则抛出
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev 允许业主放弃合同的控制权.
   */
  function renounceOwnership() public onlyOwner {
    emit OwnershipRenounced(owner);
    owner = address(0);
  }

  /**
   * @dev 允许当前所有者将合同的控制转移给新所有者.
   */
  function transferOwnership(address _newOwner) public onlyOwner {
    _transferOwnership(_newOwner);
  }

  /**
   * @dev 将合同的控制权移交给新所有者.
   */
  function _transferOwnership(address _newOwner) internal {
    require(_newOwner != address(0));
    emit OwnershipTransferred(owner, _newOwner);
    owner = _newOwner;
  }
}

contract TokenMall is Ownable {
  /**
   * @dev 抵押物上链信息.
   */
  struct MortgageInfo {
      bytes32 projectId;//项目ID 
      string currency;//抵押币种 
      string mortgageAmount;//抵押数量 
      string releaseAmount;//释放数量 
  }
  mapping(bytes32 =>MortgageInfo) mInfo;
  bytes32[] mortgageInfos;
   
  /**
   * @dev 添加数据.
   */
    event MessageMintInfo(address sender,bool isScuccess,string message);
    function mintMortgageInfo(string _projectId,string currency,string mortgageAmount,string releaseAmount) onlyOwner{
        bytes32 proId = stringToBytes32(_projectId);
        if(mInfo[proId].projectId != proId){
              mInfo[proId].projectId = proId;
              mInfo[proId].currency = currency;
              mInfo[proId].mortgageAmount = mortgageAmount;
              mInfo[proId].releaseAmount = releaseAmount;
              mortgageInfos.push(proId);
              MessageMintInfo(msg.sender, true,"添加成功");
            return;
        }else{
             MessageMintInfo(msg.sender, false,"项目ID已经存在");
            return;
        }
    }
  /**
   * @dev 更新数据.
   */
    event MessageUpdateInfo(address sender,bool isScuccess,string message);
    function updateMortgageInfo(string _projectId,string releaseAmount) onlyOwner{
         bytes32 proId = stringToBytes32(_projectId);
        if(mInfo[proId].projectId == proId){
              mInfo[proId].releaseAmount = releaseAmount;
              mortgageInfos.push(proId);
              MessageUpdateInfo(msg.sender, true,"修改成功");
            return;
        }else{
             MessageUpdateInfo(msg.sender, false,"项目ID不存在");
            return;
        }
    }
     
     
  /**
   * @dev 查询数据.
   */
    function getMortgageInfo(string _projectId) 
    public view returns(string projectId,string currency,string mortgageAmount,string releaseAmount){
         
         bytes32 proId = stringToBytes32(_projectId);
         
         MortgageInfo memory mi = mInfo[proId];
        
        return (_projectId,mi.currency,mi.mortgageAmount,mi.releaseAmount);
    }
    
     /// string类型转化为bytes32型转
    function stringToBytes32(string memory source) constant internal returns(bytes32 result){
        assembly{
            result := mload(add(source,32))
        }
    }
    /// bytes32类型转化为string型转
    function bytes32ToString(bytes32 x) constant internal returns(string){
        bytes memory bytesString = new bytes(32);
        uint charCount = 0 ;
        for(uint j = 0 ; j<32;j++){
            byte char = byte(bytes32(uint(x) *2 **(8*j)));
            if(char !=0){
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for(j=0;j<charCount;j++){
            bytesStringTrimmed[j]=bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

}