pragma solidity ^0.4.25;

library SafeMath {
    function add(uint a, uint b) internal pure returns (uint c) {
        c = a + b;
        require(c >= a);
    }
    function sub(uint a, uint b) internal pure returns (uint c) {
        require(b <= a);
        c = a - b;
    }
    function mul(uint a, uint b) internal pure returns (uint c) {
        c = a * b;
        require(a == 0 || c / a == b);
    }
    function div(uint a, uint b) internal pure returns (uint c) {
        require(b > 0);
        c = a / b;
    } 
}

library SafeMath8{
     function add(uint8 a, uint8 b) internal pure returns (uint8) {
        uint8 c = a + b;
        require(c >= a);
        return c;
    }  

    function sub(uint8 a, uint8 b) internal pure returns (uint8) {
        require(b <= a);
        uint8 c = a - b;
        return c;
    }

     function mul(uint8 a, uint8 b) internal pure returns (uint8) {
        if (a == 0) {
            return 0;
        }
        uint8 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint8 a, uint8 b) internal pure returns (uint8) {
        require(b > 0);
        uint8 c = a / b;
        return c;
    }
 }
 
 
interface ERC20 {
  function decimals() external view returns(uint8);
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);

  function transfer(address to, uint256 value) external returns(bool);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) ;
}

interface material{
    function controlSearchCount(uint8 boxIndex, uint8 materialIndex,address target)external view returns (uint);
    function MaterialTokens(uint8 _boxIndex, uint8 _materialIndex) external view returns (address);
}

interface master{
    function addressToName(address awarder) external view returns(bytes32);
    function bytes32ToString(bytes32 x)external view  returns (string);
}
 
contract owned{

    address public manager;

    constructor() public{
        manager = msg.sender;
    }

    modifier onlymanager{
        require(msg.sender == manager);
        _;
    } 

    function transferownership(address _new_manager) public onlymanager {
        manager = _new_manager;
    }
} 


contract activity is owned{
    
    address materialFactory_address = 0x65844f2e98495b6c8780f689c5d13bb7f4975d65;
    address master_address = 0x0ac10bf0342fa2724e93d250751186ba5b659303;
    
    mapping(uint8 => mapping(uint8 => uint)) public awardAmount;
    mapping(uint8 => mapping(uint8 => uint)) public awardPrice;
    uint8 public action;
    uint8 public require_value;
    using SafeMath8 for uint8;
    using SafeMath for uint;
    event awardResult(address indexed awarder,string awardName,uint8 boxIndex, uint8 material_index,uint price,uint8 action);
    
    constructor() public{
        awardAmount[0][27] = 1;     awardPrice[0][27] = 1 ether;
        awardAmount[1][9] = 1;      awardPrice[1][9] = 1 ether;
        awardAmount[2][19] = 1;     awardPrice[2][19] = 1 ether;   
        awardAmount[3][6] = 1;      awardPrice[3][6] = 1 ether;
        awardAmount[4][19] = 1;     awardPrice[4][19] = 1 ether;
        awardAmount[0][21] = 10;    awardPrice[0][21] = 0.1 ether;
        awardAmount[1][8] = 10;     awardPrice[1][8] = 0.1 ether;
        awardAmount[2][12] = 10;    awardPrice[2][12] = 0.1 ether;
        awardAmount[3][4] = 10;     awardPrice[3][4] = 0.1 ether;
        awardAmount[4][15] = 10;    awardPrice[4][15] = 0.1 ether;  
        action = 1;
        require_value = 5;
    }
    
    function() public payable{}

    function receiveApproval(address _sender, uint256 _value,
    address _tokenContract, bytes memory _extraData) public{
        
        uint8 boxIndex;
        uint8 material_index;
        bytes32 byteName;
        string memory awardName;

        boxIndex = uint8(_extraData[1]); 
        material_index = uint8(_extraData[2]);
 
        address material_address = material(materialFactory_address).MaterialTokens(boxIndex,material_index);
        
        require(_tokenContract == material_address);
        require(_value == require_value);
        require(_value <= materialAmount(boxIndex,material_index,_sender));
        require(awardAmount[boxIndex][material_index] != 0);
        require(ERC20(material_address).transferFrom(_sender, address(this), _value),"交易失敗");
 
        awardAmount[boxIndex][material_index] = awardAmount[boxIndex][material_index].sub(1);
        
        byteName = master(master_address).addressToName(_sender);
        awardName =  master(master_address).bytes32ToString(byteName);
         
        _sender.transfer(awardPrice[boxIndex][material_index]); 
        emit awardResult(_sender,awardName, boxIndex, material_index,awardPrice[boxIndex][material_index],action);
        
    }
    
    function materialAmount(uint8 boxIndex, uint8 material_index, address _sender) private  view returns (uint) {    
        return material(materialFactory_address).controlSearchCount(boxIndex,material_index,_sender);
    } 
    
    function inquireAddress(uint8 boxIndex, uint8 material_index) public view returns (address) {    
        return material(materialFactory_address).MaterialTokens(boxIndex,material_index);
    } 
    
    function inquireEth() public view returns (uint){
        return address(this).balance;
    }
   
    function setAciton(uint8 _action) public onlymanager{
        action = _action;
    }
    
    function set_require_value(uint8 _require_value) public onlymanager{
        require_value = _require_value;
    }
     
    function resetAward(uint8 boxIndex, uint8 material_index) public onlymanager{
        awardAmount[boxIndex][material_index] = 0;
        awardPrice[boxIndex][material_index] = 0;
    } 
  
    function setNewMulAward(uint8[] boxIndex, uint8[] material_index , uint8[] amount, uint[] price) public onlymanager{
        require(boxIndex.length == material_index.length && material_index.length == amount.length && amount.length == price.length);
        for(uint8 i = 0;i<boxIndex.length;i++){
            awardAmount[boxIndex[i]][material_index[i]] = amount[i];
            awardPrice[boxIndex[i]][material_index[i]] = price[i] * 10 ** 18;
        } 
    }
    
    function set_master_address(address _master_address) public onlymanager{
        master_address = _master_address;
    }
    
    function set_materialFactory_address(address _materialFactory_address) public onlymanager{
        materialFactory_address = _materialFactory_address;
    }

    function withdraw_all_ETH() public onlymanager{
        manager.transfer(address(this).balance);
    }
 

}