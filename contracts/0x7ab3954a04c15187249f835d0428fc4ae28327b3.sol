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

 }

 library SafeMath16{
     function add(uint16 a, uint16 b) internal pure returns (uint16) {
        uint16 c = a + b;
        require(c >= a);

        return c;
    }

    function sub(uint16 a, uint16 b) internal pure returns (uint16) {
        require(b <= a);
        uint16 c = a - b;
        return c;
    }

     function mul(uint16 a, uint16 b) internal pure returns (uint16) {
        if (a == 0) {
            return 0;
        }
        uint16 c = a * b;
        require(c / a == b);
        return c;
    }

    function div(uint16 a, uint16 b) internal pure returns (uint16) {
        require(b > 0);
        uint16 c = a / b;
        return c;
    }
 }

library Address {

    function isContract(address account) internal view returns (bool) {
        uint256 size;
        assembly { size := extcodesize(account) }
        return size > 0;
    }
}

interface master{
    function inquire_location(address _address) external view returns(uint16, uint16);
    function inquire_slave_address(uint16 _slave) external view returns(address);
    function inquire_land_info(uint16 _city, uint16 _id) external view returns(uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8);
    function domain_attribute(uint16 _city,uint16 _id, uint8 _index) external;
    
    function inquire_tot_attribute(uint16 _slave, uint16 _domain) external view returns(uint8[5]);
     
    function inquire_owner(uint16 _city, uint16 id) external view returns(address);
    
}

 interface material{
     function control_burn(uint8 boxIndex, uint8 materialIndex, address target, uint256 amount) external;
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

contract mix is owned{   
    
    event mix_result(address indexed player, bool result, uint16 rate); 

    address arina_address = 0xe6987cd613dfda0995a95b3e6acbabececd41376;
    address master_address = 0x0ac10bf0342fa2724e93d250751186ba5b659303;
    
    address material_contract = 0x65844f2e98495b6c8780f689c5d13bb7f4975d65;  
    
    uint16[5] paramA;
    uint16[5] paramB; 
    uint16[5] paramC; 
    uint16[5] paramD;
    uint16[5] paramE; 
    uint16[5] paramF;

    
    constructor() public{
        paramA=[50,30,10,5,1];
        paramB=[100,50,30,10,5]; 
        paramC=[200,100,50,30,10];
        paramD=[300,150,100,50,30];
        paramE=[400,200,150,100,50];
        paramF=[500,300,200,150,100]; 

    } 
     
    using SafeMath for uint256;
    using SafeMath16 for uint16;
    using SafeMath8 for uint8;
    using Address for address;
    
    function set_material_contract(address _material_contract) public onlymanager{
        material_contract = _material_contract;
    }
    
    function set_master(address _new_master) public onlymanager {
        master_address = _new_master;
    } 
    
     
    
    function materialMix(uint16 city,uint16 id,uint8 proIndex, uint8[] mixArray) public {
    
        require(msg.sender == master(master_address).inquire_owner(city,id));
        (uint16 _city,uint16 _id) = master(master_address).inquire_location(msg.sender);
        require(city == _city && id == _id);
         
        uint8 produce;        
        uint8 attribute; 
        uint8 index2;         
        uint16 total = 0;     
        uint16 random = uint16((keccak256(abi.encodePacked(now, mixArray.length))));
  
         
        if(proIndex == 1){
            (produce,,,,,,,,,) = master(master_address).inquire_land_info(city,id);
             
        }else if(proIndex == 2){
            (,produce,,,,,,,,) = master(master_address).inquire_land_info(city,id);
        }else if(proIndex == 3){
            (,,produce,,,,,,,) = master(master_address).inquire_land_info(city,id);
        }else if(proIndex == 4){
            (,,,produce,,,,,,) = master(master_address).inquire_land_info(city,id);
        }else{
            (,,,,produce,,,,,) = master(master_address).inquire_land_info(city,id);
        }

        attribute = produce.add(master(master_address).inquire_tot_attribute(city,id)[(proIndex-1)]);
        
        require(attribute>=0 && attribute < 10);
         
        
        if( attribute < 2)
            index2 = 0;
        else if(attribute > 1 && attribute < 4)
            index2 = 1; 
        else if(attribute > 3 && attribute < 6)
            index2 = 2;
        else if(attribute > 5 && attribute < 8)
            index2 = 3;
        else
            index2 = 4; 
            
        for( i=0;i<mixArray.length;i++){          
            total = total.add(getParam(mixArray[i],index2));
        }    
  
        for(uint8 i=0;i < mixArray.length; i++){                        
            
            if(proIndex == 2){
                mixArray[i] = mixArray[i]%30;
            }else if(proIndex == 3){
                mixArray[i] = mixArray[i]%40;
            }else if(proIndex == 4){
                mixArray[i] = mixArray[i]%60;
            }else if(proIndex == 5){
                mixArray[i] = mixArray[i]%68;
            }


             material(material_contract).control_burn((proIndex-1),(mixArray[i]-1),msg.sender,1);
        }  

        


        if((random%1000) <= total){
            
            master(master_address).domain_attribute(city, id, (proIndex-1));
            emit mix_result(msg.sender,true,total);
            
        } else{
            emit mix_result(msg.sender,false,total);
        }
    
    }
    
     
    function getParam(uint index1,uint16 index2) private view returns(uint16){     
           
           if(index1<6 || index1==31 || index1==32 || (index1>40 && index1<46) || index1==61 || index1==62 || (index1>68 && index1<74)){
               return paramA[index2];
           }else if((index1>5 && index1<11) || index1==33 || index1==34 || (index1>45 && index1<51) || index1==63 || index1==64 || (index1>73 && index1<79)){
               return paramB[index2];
           }else if((index1>10 && index1<16) || index1==35 || index1==36 || (index1>50 && index1<56) || index1==65 || index1==66 || (index1>78 && index1<84)){
               return paramC[index2];
           }else if((index1>15 && index1<21) || index1==37 || index1==38 || (index1>55 && index1<61)|| (index1>83 && index1<89)){
               return paramD[index2];
           }else if((index1>25 && index1<31) || index1==39 || index1==40 || index1==67 || index1==68){
               return paramF[index2];
           }else{
               return paramE[index2];
           }
    }
    

    
    
    
}