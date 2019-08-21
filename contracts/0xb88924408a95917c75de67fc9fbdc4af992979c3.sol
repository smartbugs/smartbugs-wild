pragma solidity ^0.4.19;


contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function Ownable() public {
    owner = msg.sender;
  }

  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract ERC721 {
    
    function totalSupply() public view returns (uint256 total);
    function balanceOf(address _owner) public view returns (uint256 balance);
    function ownerOf(uint256 _tokenId) external view returns (address owner, uint256 tokenId);
    function approve(address _to, uint256 _tokenId) external;
    function transfer(address _to, uint256 _tokenId) external payable;
    function transferFrom(address _from, address _to, uint256 _tokenId) external payable;


    event Transfer(address from, address to, uint256 tokenId);
    event Approval(address owner, address approved, uint256 tokenId);
    
    
    
}


contract HorseControl  {

    address public ceoAddress=0xC229F1e3D3a798725e09dbC6b31b20c07b95543B;
    address public ctoAddress=0x01569f2D20499ad013daE86B325EE30cB582c3Ba;
 

    modifier onCEO() {
        require(msg.sender == ceoAddress);
        _;
    }

    modifier onCTO() {
        require(msg.sender == ctoAddress);
        _;
    }

    modifier onlyC() {
        require(
            msg.sender == ceoAddress ||
            msg.sender == ctoAddress
        );
        _;
    }

 
}


contract GeneScienceInterface is HorseControl{
    
        mapping (uint256 => uint256) public dna1; 
        mapping (uint256 => uint256) public dna2; 
        mapping (uint256 => uint256) public dna3; 
        mapping (uint256 => uint256) public dna4; 
        mapping (uint256 => uint256) public dna5; 
        mapping (uint256 => uint256) public dna6; 

    
    function mixGenes(uint256 childId, uint256 _mareId, uint16 mumcool, uint256 _stallionId, uint16 dadcool) internal {
     

            uint16 cooldownI = (mumcool+dadcool)/2;     
            
   uint256   childG1;
        uint256   childG2;
        uint256   childG3;
        uint256   childG4;
        uint256   childG5;
        uint256   childG6;

               if(cooldownI<=1 && cooldownI>=0){
                   
                   
           childG1= dna1[_stallionId];
           childG2= dna2[_stallionId];
           childG3= dna3[_mareId];
           childG4= dna4[_mareId];
           childG5= dna5[_mareId];
           childG6= dna6[_stallionId];

          
                  
                  
              }else if(cooldownI<=2 && cooldownI>1){
            childG1= dna1[_stallionId];
           childG2= dna2[_mareId];
           childG3= dna3[_stallionId];
           childG4= dna4[_mareId];
           childG5= dna5[_mareId];
           childG6= dna6[_stallionId];
           
                  
              }else if(cooldownI<=3 && cooldownI>2){
                  
           
         childG1= dna1[_mareId];
           childG2= dna2[_stallionId];
           childG3= dna3[_mareId];
           childG4= dna4[_stallionId];
           childG5= dna5[_stallionId];
           childG6= dna6[_mareId];
        
              }else if(cooldownI<=4 && cooldownI>3){
                  
           childG1= dna1[_mareId];
           childG2= dna2[_mareId];
           childG3= dna3[_stallionId];
           childG4= dna4[_stallionId];
           childG5= dna5[_stallionId];
           childG6= dna6[_mareId];
        
              }

        dna1[childId] = childG1;
        dna2[childId] = childG2;
        dna3[childId] = childG3;
        dna4[childId] = childG4;
        dna5[childId] = childG5;
        dna6[childId] = childG6;

    }
   
}




contract HoresBasis is  GeneScienceInterface {
   
    event Birth(address owner, uint256 HorseId, uint256 mareId, uint256 stallionId);
   
    event Transfer(address from, address to, uint256 tokenId);

    struct Horse {
        uint64 birthTime;
        uint64 unproductiveEndBlock;
        uint32 mareId;
        uint32 stallionId;
        uint32 stallionWithId;
        uint16 unproductiveIndex;
        uint16 generation;
    }

    uint32[5] public sterile = [
        uint32(15 minutes),
        uint32(120 minutes),
        uint32(480 minutes),
        uint32(1800 minutes),
        uint32(3000 minutes)
    ];


    uint256 public secondsPerBlock = 15;

    Horse[] horses;

    mapping (uint256 => address) public horseOwnerIndex;
    
    mapping (uint256 => uint256) public horseIndexPrice;
    
    mapping (uint256 => bool)  horseIndexForSale;

    mapping (address => uint256) tokenOwnershipCount;


   uint256 public saleFee = 20;

   uint256 public BirthFee = 4 finney;
   
   
 
    function _transfer(address _from, address _to, uint256 _tokenId) internal {
        tokenOwnershipCount[_to]++;
        horseOwnerIndex[_tokenId] = _to;
        
        if (_from != address(0)) {
            tokenOwnershipCount[_from]--;
         
        }
       Transfer(_from, _to, _tokenId);
       
    }
    
    
    function _sell(address _from,  uint256 _tokenId, uint256 value) internal {
     
     if(horseIndexForSale[_tokenId]==true){
         
              uint256 price = horseIndexPrice[_tokenId];
            
            require(price<=value);
            
         uint256 Fee = price / saleFee;
            
          uint256  oPrice= price - Fee;
            
            address _to = msg.sender;
            
            tokenOwnershipCount[_to]++;
            horseOwnerIndex[_tokenId] = _to;
            
            horseIndexForSale[_tokenId]=false;
            
            
            if (_from != address(0)) {
                tokenOwnershipCount[_from]--;
               
            }
                 
           Transfer(_from, _to, _tokenId);
             
             _from.transfer(oPrice);
             
             ceoAddress.transfer(Fee);
             
            uint256 bidExcess = value - oPrice - Fee;
            _to.transfer(bidExcess);
            
            
     }else{
          _to.transfer(value);
     }
      
    }
    
    
	
    function _newHorse(
        uint256 _mareId,
        uint256 _stallionId,
        uint256 _generation,
        uint256 _genes1,
        uint256 _genes2,
        uint256 _genes3,
        uint256 _genes4,
        uint256 _genes5,
        uint256 _genes6,
        address _owner
    )
        internal
        returns (uint)
    {
   
        Horse memory _horse = Horse({
           birthTime: uint64(now),
            unproductiveEndBlock: 0,
            mareId: uint32(_mareId),
            stallionId: uint32(_stallionId),
            stallionWithId: 0,
            unproductiveIndex: 0,
            generation: uint16(_generation)
            
        });
       
        
       uint256 newHorseId;
	   
     newHorseId = horses.push(_horse)-1;
     
     makeDna(_mareId, _stallionId, newHorseId, _genes1, _genes2, _genes3, _genes4, _genes5, _genes6);
        require(newHorseId == uint256(uint32(newHorseId)));

       Birth(
            _owner,
            newHorseId,
            uint256(_horse.mareId),
            uint256(_horse.stallionId)
        );

        _transfer(0, _owner, newHorseId);

        return newHorseId;  
    }


function makeDna( uint256 _mareId,
        uint256 _stallionId,
        uint256 _newId,
        uint256 _genes1,
        uint256 _genes2,
        uint256 _genes3,
        uint256 _genes4,
        uint256 _genes5,
        uint256 _genes6)internal{
    
      if(_mareId!=0 && _stallionId!=0){
               
          Horse storage stallion = horses[_stallionId];
     Horse storage mare = horses[_mareId];
     
    GeneScienceInterface.mixGenes(_newId, _mareId,mare.unproductiveIndex, _stallionId, stallion.unproductiveIndex);
         
     }else{
         
        dna1[_newId] = _genes1;
        dna2[_newId] = _genes2;
        dna3[_newId] = _genes3;
        dna4[_newId] = _genes4;
        dna5[_newId] = _genes5;
        dna6[_newId] = _genes6;
     }
}



    function setSecondsPerBlock(uint256 secs) external  onlyC {
    require(secs < sterile[0]);
       secondsPerBlock = secs;
      
    }
   
}


contract HorseOwnership is HoresBasis, ERC721{

  string public constant  name = "CryptoHorse";
    string public constant symbol = "CHC";
     uint8 public constant decimals = 0; 

    function horseForSale(uint256 _tokenId, uint256 price) external {
  
     address  ownerof =  horseOwnerIndex[_tokenId];
        require(ownerof == msg.sender);
        horseIndexPrice[_tokenId] = price;
        horseIndexForSale[_tokenId]= true;
		}


 function horseNotForSale(uint256 _tokenId) external {
         address  ownerof =  horseOwnerIndex[_tokenId];
            require(ownerof == msg.sender);
        horseIndexForSale[_tokenId]= false;

    }


    function _owns(address _applicant, uint256 _tokenId) internal view returns (bool) {
        return horseOwnerIndex[_tokenId] == _applicant;
    }


    function balanceOf(address _owner) public view returns (uint256 count) {
        return tokenOwnershipCount[_owner];
    }

    function transfer(
        address _to,
        uint256 _tokenId
    )
        external
        payable
    {
        require(_to != address(0));
		
        require(_to != address(this));
 
        require(_owns(msg.sender, _tokenId));
       _transfer(msg.sender, _to, _tokenId);
    }

    function approve(
        address _to,
        uint256 _tokenId
    )
        external 
    {
        require(_owns(msg.sender, _tokenId));

        Approval(msg.sender, _to, _tokenId);
    }

    function transferFrom(address _from, address _to, uint256 _tokenId ) external payable {
        
        if(_from != msg.sender){
              require(_to == msg.sender);
                 
                require(_from==horseOwnerIndex[_tokenId]);
        
               _sell(_from,  _tokenId, msg.value);
            
        }
 
    }

    function totalSupply() public view returns (uint) {
        return horses.length;
    }

    function ownerOf(uint256 _tokenId)  external view returns (address owner, uint256 tokenId)  {
        owner = horseOwnerIndex[_tokenId];
        tokenId=_tokenId;
       
       return;
       
    }

       function horseFS(uint256 _tokenId) external view  returns (bool buyable, uint256 tokenId) {
        buyable = horseIndexForSale[_tokenId];
        tokenId=_tokenId;
       return;
       
    }
	
	function horsePr(uint256 _tokenId) external view  returns (uint256 price, uint256 tokenId) {
        price = horseIndexPrice[_tokenId];
        tokenId=_tokenId;
       return;
       
    }
    
}

contract HorseStud is HorseOwnership {
  
    event Pregnant(address owner, uint256 mareId, uint256 stallionId, uint256 unproductiveEndBlock);

    uint256 public pregnantHorses;


    function _isStallionPermitted(uint256 _stallionId, uint256 _mareId) internal view returns (bool) {
        address mareOwner = horseOwnerIndex[_mareId];
        address stallionOwner = horseOwnerIndex[_stallionId];
        return (mareOwner == stallionOwner);
    }

 function setBirthFee(uint256 val) external onCTO {
        BirthFee = val;
    }
    
 function setSaleFee(uint256 val) external onCTO {
        saleFee = val;
    }

 
    function isReadyToBear(uint256 _horseId) public view returns (bool) {
        require(_horseId > 0);
        Horse storage knight = horses[_horseId];
        require(knight.unproductiveIndex<4);  
    
        bool ready = (knight.stallionWithId == 0) && (knight.unproductiveEndBlock <= uint64(block.number));
       return ready;
    }

    function isPregnant(uint256 _horseId) public view returns (bool) {
        require(_horseId > 0);
        return horses[_horseId].stallionWithId != 0;
    }

	
    function _canScrewEachOther(uint256 _mareId, uint256 _stallionId) private view returns(bool) {
		
        if (_mareId == _stallionId) {
            return false;
        }
        
     uint256   matronSex=dna4[_mareId];
     uint256   sireSex=dna4[_stallionId];

        if(matronSex!=1){
            return false;
        }
        
         if(sireSex!=2){
            return false;
        }
        
      if(matronSex==sireSex){
          return false;
      }  
        
        return true;
    }

    function canBearWith(uint256 _mareId, uint256 _stallionId)
        external
        view
        returns(bool)
    {
        require(_mareId > 0);
        require(_stallionId > 0);
        return _canScrewEachOther( _mareId,  _stallionId) &&
            _isStallionPermitted(_stallionId, _mareId);
    }

    
    function _bearWith(uint256 _mareId, uint256 _stallionId) internal {
        Horse storage stallion = horses[_stallionId];
        Horse storage mare = horses[_mareId];

        mare.stallionWithId = uint32(_stallionId);
       
         stallion.unproductiveEndBlock = uint64((sterile[stallion.unproductiveIndex]/secondsPerBlock) + block.number);
 mare.unproductiveEndBlock = uint64((sterile[mare.unproductiveIndex]/secondsPerBlock) + block.number);
        
        if (stallion.unproductiveIndex < 5) {
            stallion.unproductiveIndex += 1;
        }
		 if (mare.unproductiveIndex < 5) {
					mare.unproductiveIndex += 1;
		}
		 
        pregnantHorses++;

        Pregnant(horseOwnerIndex[_mareId], _mareId, _stallionId, mare.unproductiveEndBlock);
   
   bearChild(_mareId);

    }

	
	
    function stallionWith(uint256 _mareId, uint256 _stallionId) external payable  {
		require(_owns(msg.sender, _mareId));
        require(_owns(msg.sender, _stallionId));

        Horse storage mare = horses[_mareId];

        require(isReadyToBear(_mareId));
        require(isReadyToBear(_stallionId));

        bool (mare.stallionWithId == 0) && (mare.unproductiveEndBlock <= uint64(block.number));

        Horse storage stallion = horses[_stallionId];

        bool (stallion.stallionWithId == 0) && (stallion.unproductiveEndBlock <= uint64(block.number));

        require(_canScrewEachOther(
            _mareId,
            _stallionId
        ));
        
        if(BirthFee>= msg.value){
           
		   ceoAddress.transfer(BirthFee);
             uint256   rest=msg.value-BirthFee;
                msg.sender.transfer(rest);   
     _bearWith(uint32(_mareId), uint32(_stallionId));
 
        
        }else{
            
               msg.sender.transfer(msg.value);
  
        }
        
    }

	
	
    function bearChild(uint256 _mareId) internal  {
        
            Horse storage mare = horses[_mareId];
          
               require(mare.birthTime != 0);
        
                bool (mare.stallionWithId != 0) && (mare.unproductiveEndBlock <= uint64(block.number)); 
            
              uint256 stallionId = mare.stallionWithId;
                
               Horse storage stallion = horses[stallionId];
        
                uint16 parentGen = mare.generation;
                if (stallion.generation > mare.generation) {
                    parentGen = stallion.generation;
                }
        
                address owner = horseOwnerIndex[_mareId];
                
             _newHorse(_mareId, stallionId, parentGen + 1, 0,0,0,0,0,0, owner);
           
              mare.stallionWithId=0;
                
                pregnantHorses--;
                
    }
    
    
    
}




contract HorseMinting is HorseStud {

    uint256 public  GEN_0_LIMIT = 20000;


    uint256 public gen0Count;

    

    function createGen0Horse(uint256 _genes1,uint256 _genes2,uint256 _genes3,uint256 _genes4,uint256 _genes5,uint256 _genes6, address _owner) external onCTO {
        address horseOwner = _owner;
       if (horseOwner == address(0)) {
             horseOwner = ctoAddress;
        }
    require(gen0Count < GEN_0_LIMIT);

            
              _newHorse(0, 0, 0, _genes1, _genes2, _genes3, _genes4, _genes5, _genes6, horseOwner);
            
        gen0Count++;
        
    }

   
}


contract GetTheHorse is HorseMinting {


    function getHorse(uint256 _id)
        external
        view
        returns (
        uint256 price,
        uint256 id,
        bool forSale,
        bool isGestating,
        bool isReady,
        uint256 unproductiveIndex,
        uint256 nextActionAt,
        uint256 stallionWithId,
        uint256 birthTime,
        uint256 mareId,
        uint256 stallionId,
        uint256 generation
		
    ) {
		price = horseIndexPrice[_id];
        id = uint256(_id);
		forSale = horseIndexForSale[_id];
        Horse storage knight = horses[_id];
        isGestating = (knight.stallionWithId != 0);
        isReady = (knight.unproductiveEndBlock <= block.number);
        unproductiveIndex = uint256(knight.unproductiveIndex);
        nextActionAt = uint256(knight.unproductiveEndBlock);
        stallionWithId = uint256(knight.stallionWithId);
        birthTime = uint256(knight.birthTime);
        mareId = uint256(knight.mareId);
        stallionId = uint256(knight.stallionId);
        generation = uint256(knight.generation);

    }

  

}