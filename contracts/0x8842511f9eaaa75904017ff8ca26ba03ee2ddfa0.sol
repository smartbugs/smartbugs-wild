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






contract ERC20Interface {
    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);

    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);
}







contract ApproveAndCallFallBack {
    function receiveApproval(address from, uint256 tokens, address token, bytes data) public;
}





contract Owned {
    address public owner;
    address public newOwner;
    

    event OwnershipTransferred(address indexed _from, address indexed _to);

    constructor() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner); 
        _;
    }

    function transferOwnership(address _newOwner) public onlyOwner {
        newOwner = _newOwner;
    }
    function acceptOwnership() public {
        require(msg.sender == newOwner);
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
        newOwner = address(0);
    }
}



interface controller{
    function mintToken(address target, uint mintedAmount) external;
    function burnToken(uint8 boxIndex, address target, uint mintedAmount) external;
    function control(uint8 boxIndex, uint8 indexMaterial, address target, uint256 amount) external;
    function setMaterialRate(uint indexMaterial, uint8 rate) external;                                  
    function setAddMaterial(uint8 rate) external;                                                       
    function setAddMaterialAll(uint8 rate1,uint8 rate2,uint8 rate3,uint8 rate4,uint8 rate5,uint8 rate6,uint8 rate7,uint8 rate8,uint8 rate9,uint8 rate10) external; 
    function setAddMaterialEight(uint8 rate1,uint8 rate2,uint8 rate3,uint8 rate4,uint8 rate5,uint8 rate6,uint8 rate7,uint8 rate8) external; 
    function balanceOf(address tokenOwner) external view returns (uint);                                
    function set_material_address(address _material_address) external;
    function set_pet_address(address _pet_address) external;
}


contract Factroy is Owned{
    
    using SafeMath for uint;
    using SafeMath16 for uint16;
    
    address[] public newContracts;
    address personcall_address;
   
    uint16 public box_contract_amount = 0;
    
     
    function createConstruct(string _name, uint8 _level) public onlyOwner{
        address newContract = new createTreasure(_name, _level);
        newContracts.push(newContract);
        box_contract_amount = box_contract_amount.add(1);
    } 
    
    
    function controlMintokenManager(uint8 _index,address target, uint mintedAmount) public{       
         require(msg.sender == owner);
         controller mintokener = controller(newContracts[_index]);
         mintokener.mintToken(target, mintedAmount);
    } 
    

     
    function controlMintoken(uint8 _index,address target, uint mintedAmount) public{        
         require(msg.sender == personcall_address);
         controller mintokener = controller(newContracts[_index]);
         mintokener.mintToken(target, mintedAmount);
    } 
    
    function controlBurntoken(uint8 _index,address target, uint mintedAmount) public{       
         require(msg.sender == personcall_address);
         controller burntokener = controller(newContracts[_index]);
         uint8 boxIndex;
         if(_index<5){
             boxIndex = 0;
         }else if(_index<10){
             boxIndex = 1;
         }else if(_index<15){
             boxIndex = 2;
         }else if(_index<20){
             boxIndex = 3;
         }else if(_index<25){
             boxIndex = 4;
         }else{
             boxIndex = 5;
         }

         burntokener.burnToken(boxIndex, target, mintedAmount);
         
    }
 
    
    function controlMaterialRate(uint8 _index, uint8 materialIndex, uint8 rate ) public onlyOwner{   
         controller setMaterailTokener = controller(newContracts[_index]);
         setMaterailTokener.setMaterialRate(materialIndex,rate);
         
    }
    
    function controlAddMaterial(uint8 _index,uint8 rate) public onlyOwner{        
        controller setAddMaterialler = controller(newContracts[_index]);
        setAddMaterialler.setAddMaterial(rate);
    }  
    
    function controlAddMaterialAll(uint8 _index,uint8 rate1,uint8 rate2,uint8 rate3,uint8 rate4,uint8 rate5,uint8 rate6,uint8 rate7,uint8 rate8,uint8 rate9,uint8 rate10) public onlyOwner{  
        controller setAddMaterialler = controller(newContracts[_index]);
        setAddMaterialler.setAddMaterialAll(rate1,rate2,rate3,rate4,rate5,rate6,rate7,rate8,rate9,rate10);
    }
    
    function controlAddMaterialEight(uint8 _index,uint8 rate1,uint8 rate2,uint8 rate3,uint8 rate4,uint8 rate5,uint8 rate6,uint8 rate7,uint8 rate8) public onlyOwner{  
        controller setAddMaterialler = controller(newContracts[_index]);
        setAddMaterialler.setAddMaterialEight(rate1,rate2,rate3,rate4,rate5,rate6,rate7,rate8);
    } 

    function controlSearchBoxCount(uint8 _index,address target) public view returns (uint) {   
         controller setSearchMaterialCnt = controller(newContracts[_index]);
         return setSearchMaterialCnt.balanceOf(target);
    }
    
    function controlSet_material_address(address _new_material_address) public onlyOwner{
        for(uint8 i=0;i<25;i++){
            controller setter = controller(newContracts[i]);
            setter.set_material_address(_new_material_address);
        }
    }
    
    function controlSet_pet_address(address _new_pet_address) public onlyOwner{
        for(uint8 i=25;i<30;i++){
            controller setter = controller(newContracts[i]);
            setter.set_pet_address(_new_pet_address);
        }
    }
    
    function set_personcall(address _new_personcall) public onlyOwner {
        personcall_address = _new_personcall;
    }
        


}





contract createTreasure is ERC20Interface, Owned {

    event whatOfHerb(address indexed target, uint8 boxIndex, uint8 materialIndex, uint materialAmount);
    
    
    using SafeMath for uint;
    using SafeMath8 for uint8;
    using SafeMath16 for uint16;
    string public symbol;
    string public  name;
    uint8 public decimals;
    uint8 public level;
    uint _totalSupply;
    
    address  material_address=0x65844f2e98495b6c8780f689c5d13bb7f4975d65;
    address  pet_address;

    mapping(address => uint) balances;
    mapping(address => mapping(address => uint)) allowed;
    
    
    uint8[] public  materialRate;  
    uint[] public materialCount;      
    


    
    
    
    constructor(string _symbol, uint8 _level) public {
    
        symbol = _symbol;
        level = _level;
        decimals = 0;
        _totalSupply = 0;
        balances[owner] = _totalSupply;
        
        emit Transfer(address(0), owner, _totalSupply);

    }
    
    
    
    
    function setAddMaterialAll(uint8 rate1,uint8 rate2,uint8 rate3,uint8 rate4,uint8 rate5,uint8 rate6,uint8 rate7,uint8 rate8,uint8 rate9,uint8 rate10) public onlyOwner{
      materialRate.push(rate1);
      materialRate.push(rate2);
      materialRate.push(rate3);
      materialRate.push(rate4);
      materialRate.push(rate5);
      materialRate.push(rate6);
      materialRate.push(rate7);
      materialRate.push(rate8);
      materialRate.push(rate9);
      materialRate.push(rate10);
      
      for(uint8 o=0;o<10;o++){
          materialCount.push(0);
      }

    }
    
     
    
    
    function setAddMaterialEight(uint8 rate1,uint8 rate2,uint8 rate3,uint8 rate4,uint8 rate5,uint8 rate6,uint8 rate7,uint8 rate8) public onlyOwner{
      materialRate.push(rate1);
      materialRate.push(rate2);
      materialRate.push(rate3);
      materialRate.push(rate4);
      materialRate.push(rate5);
      materialRate.push(rate6);
      materialRate.push(rate7);
      materialRate.push(rate8);
   
      for(uint8 o=0;o<8;o++){
          materialCount.push(0);
      }

    }
    
    
    
    
    function set_material_address(address _material_address) public onlyOwner{
      material_address = _material_address;
    }
    
    
    
    
    function set_pet_address(address _pet_address) public onlyOwner{
      pet_address = _pet_address;
    }
 
 
    
    
    
    function setAddMaterial(uint8 rate) public onlyOwner{
      materialRate.push(rate);
      materialCount.push(0);
    }
    
    
    
    
    function setMaterialRate(uint8 materialIndex, uint8 rate) public onlyOwner{
        materialRate[materialIndex] = rate;
    }
    

    
    
    
    function arrLength() public view returns(uint){
        return materialRate.length;
    }
    
    function arrLengthCount() public view returns(uint){
        return materialCount.length;
    }


    
    
    
    function totalSupply() public view returns (uint) {
        return _totalSupply.sub(balances[address(0)]);
    }


    
    
    
    function balanceOf(address tokenOwner) public view returns (uint balance) {
        return balances[tokenOwner];
    }


    
    
    
    
    
    function transfer(address to, uint tokens) public returns (bool success) {
        balances[msg.sender] = balances[msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(msg.sender, to, tokens);
        return true;
    }


    function approve(address spender, uint tokens) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        return true;
    }


    function transferFrom(address from, address to, uint tokens) public returns (bool success) {
        balances[from] = balances[from].sub(tokens);
        allowed[from][msg.sender] = allowed[from][msg.sender].sub(tokens);
        balances[to] = balances[to].add(tokens);
        emit Transfer(from, to, tokens);
        return true;
    }
 

    function allowance(address tokenOwner, address spender) public view returns (uint remaining) {
        return allowed[tokenOwner][spender];
    }


    function approveAndCall(address spender, uint tokens, bytes data) public returns (bool success) {
        allowed[msg.sender][spender] = tokens;
        emit Approval(msg.sender, spender, tokens);
        ApproveAndCallFallBack(spender).receiveApproval(msg.sender, tokens, this, data);
        return true;
    }
     
    
    

    
    
    
    function mintToken(address target, uint mintedAmount) public onlyOwner { 
        
        balances[target] = balances[target].add(mintedAmount);
        _totalSupply = _totalSupply.add(mintedAmount);
        emit Transfer(address(this), target, mintedAmount);
    }


    
    
    
   
    function burnToken(uint8 boxIndex, address target, uint mintedAmount) public onlyOwner {
        
        require(balances[target] >= mintedAmount);
        balances[target] = balances[target].sub(mintedAmount);
        _totalSupply = _totalSupply.sub(mintedAmount);

        emit Transfer(target, address(0), mintedAmount);
        address factory_address;
         
        if(boxIndex < 5){
            factory_address = material_address;
        }else{
            factory_address = pet_address;
        }
        
        
        controller control2 = controller(factory_address);
        
        for(uint8 j=0;j<materialRate.length;j++){
            materialCount[j] = 0; 
        }
        
        
        for(uint16 i=1;i<=mintedAmount;i++){            
            uint16 random = get_random(i);
            uint16 totalRate = 0;
             for(uint8 m=0;m<materialRate.length;m++){         
                totalRate = totalRate.add(materialRate[m]);
                if(random < totalRate){ 
                  materialCount[m] = uint(materialCount[m].add(1));
                  break;
                }
             }
        }

        for(uint8 n=0;n<materialRate.length;n++){
            if(materialCount[n] !=0){
                control2.control(boxIndex, n, target, materialCount[n]);          
                emit whatOfHerb(target,boxIndex,n,materialCount[n]);              
            }
        }

    }
    
    function get_random(uint amount) private view returns(uint16){
        
        uint16 total;
        for(uint8 i=0;i<materialRate.length;i++){
            total = total.add(materialRate[i]);
        }
        uint16 ramdon = uint16(keccak256(abi.encodePacked(now + uint(amount),blockhash(block.number-1)))); 
        
        return uint16(ramdon) % total;
    } 
    
   
    function () public payable {
        revert();
    }


    function transferAnyERC20Token(address tokenAddress, uint tokens) public onlyOwner returns (bool success) {
        return ERC20Interface(tokenAddress).transfer(owner, tokens);
    }
}