pragma solidity ^0.4.24;


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
  
contract owned {

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

interface master{
     function owner_slave(uint _index) external view returns(address);
     function owner_slave_amount()external view returns(uint);
}
 


interface controller{
    function controlMintoken(uint8 _index, address target, uint mintedAmount) external;
    function controlBurntoken(uint8 _index, address target, uint burnedAmount) external;
    function controlSearchBoxCount(uint8 _boxIndex, address target)external view returns (uint);
    function controlSearchCount(uint8 _boxIndex, uint8 _materialIndex, address target)external view returns (uint);
    function controlPetCount(uint8 _boxIndex, uint8 _materialIndex, address target)external view returns (uint);
}

contract personCall is owned{ 
    
    address public master_address;
    address public BoxFactory_address =0x8842511f9eaaa75904017ff8ca26ba03ee2ddfa0;
    address public MaterialFactory_address =0x65844f2e98495b6c8780f689c5d13bb7f4975d65;
    address public PetFactory_address;
    
    address[] public dungeons; 

    function checkSlave() public view returns(bool){ 
        uint length = master(master_address).owner_slave_amount();
        for(uint i=1;i<=length;i++){
             address slave = master(master_address).owner_slave(i);
             if(msg.sender == slave){
                 return true;
             }
        }
        return false;
    }
    
    function checkDungeons() public view returns(bool){ 
        for(uint i=0;i<dungeons.length;i++){
             if(msg.sender == dungeons[i]){
                 return true;
             }
        }
        return false;
    }
    
    
    
    function callTreasureMin(uint8 index,address target, uint mintedAmount) public {    
         require(checkSlave() || checkDungeons());
         controller mintokener = controller(BoxFactory_address);
   
         mintokener.controlMintoken(index, target, mintedAmount);
    }

 
    function callTreasureBurn(uint8 index, uint burnedAmount) public{       
        controller burnTokenr = controller(BoxFactory_address);
        burnTokenr.controlBurntoken(index, msg.sender, burnedAmount);
    }
    
    
    function showBoxAmount(uint8 _boxIndex) public view returns (uint){         
        controller showBoxer = controller(BoxFactory_address);
        return showBoxer.controlSearchBoxCount(_boxIndex,msg.sender);
    }
    
    function showMaterialAmount(uint8 _boxIndex, uint8 _materialIndex) public view returns (uint){   
        controller showMaterialer = controller(MaterialFactory_address);
        return showMaterialer.controlSearchCount(_boxIndex,_materialIndex,msg.sender);
    }
    
    function showPetAmount(uint8 _boxIndex, uint8 _materialIndex) public view returns (uint){   
        controller showPeter = controller(PetFactory_address);
        return showPeter.controlPetCount(_boxIndex,_materialIndex,msg.sender);
    }
    
    
    
    function push_dungeons(address _dungeons_address) public onlymanager{               
        dungeons.push(_dungeons_address);
    }
    
    function change_dungeons_address(uint index,address _dungeons_address) public onlymanager{    
        dungeons[index] = _dungeons_address;
    }
    
    function set_master_address(address _master_address) public onlymanager{        
        master_address = _master_address;
    }
    
    function set_BoxFactory_address(address _BoxFactory_address) public onlymanager{        
        BoxFactory_address = _BoxFactory_address;
    }
    
    function set_MatFactory_address(address _MaterialFactory_address) public onlymanager{        
        MaterialFactory_address = _MaterialFactory_address;
    }
    
    function set_PetFactory_address(address _PetFactory_address) public onlymanager{        
        PetFactory_address = _PetFactory_address;
    }
    

}