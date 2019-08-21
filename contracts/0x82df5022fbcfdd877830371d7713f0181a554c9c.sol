pragma solidity ^0.4.8;

contract mortal {
	address owner;

	function mortal() {
		owner = msg.sender;
	}

	function kill()  {
	    if(msg.sender==owner)
		    suicide(owner);
	}
}



contract Aquarium{
  function receive(address receiver, uint8 animalType, uint32[] ids) payable {}
}


contract Intermediary is mortal{
  Aquarium aquarium;
  uint[] values;
  
  event NewAquarium(address aqua);
  
  function Intermediary(){
    
    values =  [95000000000000000, 190000000000000000, 475000000000000000, 950000000000000000, 4750000000000000000];
  }
  function transfer(uint8[] animalTypes, uint8[] numsXType, uint32[] ids) payable{
    uint needed;
     for(uint8 i = 0; i < animalTypes.length; i++){
      needed+=values[animalTypes[i]]*numsXType[i];
    }
    if (msg.value<needed) throw;
    
    uint8 from;
    for(i = 0; i < animalTypes.length; i++){
      aquarium.receive.value(values[animalTypes[i]]*numsXType[i])(msg.sender,animalTypes[i],slice(ids,from,numsXType[i]));
      from+=numsXType[i];
    }
  }
  
  function setAquarium(address aqua){
    if(msg.sender==owner){
      aquarium = Aquarium(aqua);
      NewAquarium(aqua);
    }
      
  }
  
  function slice(uint32[] array, uint8 from, uint8 number) returns (uint32[] sliced){
    sliced = new uint32[](number);
    for(uint8 i = from; i < from+number; i++){
      sliced[i-from] = array[i];
    }
  }
}