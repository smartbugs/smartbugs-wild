pragma solidity ^0.4.25;

 library SafeMath{
     function add(uint256 a, uint256 b) internal pure returns (uint256) {
        uint256 c = a + b;
        require(c >= a);
        return c;
    } 
       
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b <= a);
        uint256 c = a - b;
        return c; 
    }
    
     function mul(uint256 a, uint256 b) internal pure returns (uint256) {
        if (a == 0) { 
            return 0;
        }
        uint256 c = a * b;
        require(c / a == b);
        return c;
    }
     
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        require(b > 0);
        uint256 c = a / b;
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


contract byt_str {
    function stringToBytes32(string memory source) pure public returns (bytes32 result) {
       
        assembly {
            result := mload(add(source, 32))
        }
    }

    function bytes32ToString(bytes32 x) pure public returns (string) {
        bytes memory bytesString = new bytes(32);
        uint charCount = 0;
        for (uint j = 0; j < 32; j++) {
            byte char = byte(bytes32(uint(x) * 2 ** (8 * j)));
            if (char != 0) {
                bytesString[charCount] = char;
                charCount++;
            }
        }
        bytes memory bytesStringTrimmed = new bytes(charCount);
        for (j = 0; j < charCount; j++) {
            bytesStringTrimmed[j] = bytesString[j];
        }
        return string(bytesStringTrimmed);
    }

}


interface ERC20_interface {
  function decimals() external view returns(uint8);
  function totalSupply() external view returns (uint256);
  function balanceOf(address who) external view returns (uint256);
  
  function transfer(address to, uint256 value) external returns(bool);
  function transferFrom(address _from, address _to, uint256 _value) external returns (bool success) ;
}


interface ERC721_interface{
     function balanceOf(address _owner) external view returns (uint256);
     function ownerOf(uint256 _tokenId) external view returns (address);
     function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes data) external payable;
     function safeTransferFrom(address _from, address _to, uint256 _tokenId) external payable;
     function transferFrom(address _from, address _to, uint256 _tokenId) external payable;
     function approve(address _approved, uint256 _tokenId) external payable;
     function setApprovalForAll(address _operator, bool _approved) external;
     function getApproved(uint256 _tokenId) external view returns (address);
     function isApprovedForAll(address _owner, address _operator) external view returns (bool);
 } 
 
 
 interface slave{
    function master_address() external view returns(address);
    
    function transferMayorship(address new_mayor) external;
    function city_number() external view returns(uint16);
    function area_number() external view returns(uint8);
    
    function inquire_totdomains_amount() external view returns(uint16);
    function inquire_domain_level_star(uint16 _id) external view returns(uint8, uint8);
    function inquire_domain_building(uint16 _id, uint8 _index) external view returns(uint8);
    function inquire_tot_domain_attribute(uint16 _id) external view returns(uint8[5]);
    function inquire_domain_cooltime(uint16 _id) external view returns(uint);
    function inquire_mayor_cooltime() external view returns(uint);
    function inquire_tot_domain_building(uint16 _id) external view returns(uint8[]);
    function inquire_own_domain(address _sender) external view returns(uint16[]);
    function inquire_land_info(uint16 _city, uint16 _id) external view returns(uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8);
    
    function inquire_building_limit(uint8 _building) external view returns(uint8);
    
    function domain_build(uint16 _id, uint8 _building) external;
    function reconstruction(uint16 _id, uint8 _index, uint8 _building)external;
    function set_domian_attribute(uint16 _id, uint8 _index) external;
    function domain_all_reward(uint8 _class, address _user) external;
    function mayor_reward(address _user) external; 
    function inquire_mayor_address() external view returns(address);
 
    function domain_reward(uint8 _class, address _user, uint16 _id) external;
    function transfer_master(address _to, uint16 _id) external;
    function retrieve_domain(address _user, uint _id) external;
    function at_Area() external view returns(string);
    function set_domain_cooltime(uint _cooltime) external;
 } 
 
 interface trade{
    function set_city_pool(uint _arina, uint16 _city )external;
    function inquire_pool(uint16 _city) external view returns(uint);
    function exchange_arina(uint _arina, uint16 _city, address _target) external;
 }

 contract master is owned, byt_str {
    using SafeMath for uint;
    using SafeMath16 for uint16;
    
    
    address arina_contract = 0xe6987cd613dfda0995a95b3e6acbabececd41376;
     
    address GIC_contract = 0x340e85491c5f581360811d0ce5cc7476c72900ba;
    address trade_address;
    address mix_address;
    
    uint16 public owner_slave_amount = 0; 
    uint random_seed;
    uint public probability = 1000000;
    bool public all_stop = false;
    
    
    struct _info{
        uint16 city; 
        uint16 domain; 
        bool unmovable; 
        bool lotto; 
        bool build; 
        bool reward;
    }
    
    
    address[] public owner_slave; 
   
    mapping (uint8 => string) public area; 
    mapping (uint8 => string) public building_type;  
    mapping (uint8 => uint) public building_price; 
     
    mapping(address => _info) public player_info;  
    
    mapping(bytes32 => address) public member;
    mapping(address => bytes32) public addressToName;
    
    
    
    event set_name(address indexed player, uint value); 
    event FirstSign(address indexed player,uint time); 
    event RollDice(address indexed player, uint16 city, uint16 id, bool unmovable); 
    event Change_city(address indexed player, uint16 city, uint16 id, bool unmovable);
    event Fly(address indexed player, uint16 city, uint16 id, bool unmovable);
    
    event PlayLotto(address indexed player,uint player_number, uint lotto_number);
    
    event PayArina(address indexed player, uint value, uint16 city, uint16 id);
    event BuyArina(address indexed player, uint value, uint16 city, uint16 id);
    event PayEth(address indexed player, uint value, uint16 city, uint16 id);
    event BuyEth(address indexed player, uint value, uint16 city, uint16 id);
    
    event Build(address indexed player, uint8 building, uint value);
    event Reconstruction(address indexed player, uint8 building, uint value);
    
    


  function register(string _name) public{
      if(keccak256(abi.encodePacked(_name)) == keccak256(abi.encodePacked(""))) {
          revert();
      } 
      bytes32 byte_name =  stringToBytes32(_name);
   
      if(addressToName[msg.sender] == 0x0){
          member[byte_name] = msg.sender;
          addressToName[msg.sender] = byte_name;
          emit FirstSign(msg.sender,now); 
      }else{
          revert(); 
      }
      
  }



    function() public payable{}
    
    function rollDice() external{
        require(!all_stop);
        require(owner_slave_amount >= 1);
        require(!player_info[msg.sender].unmovable,"不可移動");
        uint16 random = uint16((keccak256(abi.encodePacked(now, random_seed))));
        random_seed.add(1);
        
        if(player_info[msg.sender].city == 0){
            player_info[msg.sender].city = 1;
        }
        
        uint16 in_city = player_info[msg.sender].city;
        
        
        uint16 tot_domains = inquire_city_totdomains(in_city);
        uint16 go_domains_id = random % tot_domains; 
        
        
        
        player_info[msg.sender].domain = go_domains_id;
        
        address city_address = owner_slave[in_city];
        address domain_owner = ERC721_interface(city_address).ownerOf(go_domains_id);
        
        if (domain_owner != 0x0){
            if(domain_owner == msg.sender){
                player_info[msg.sender].build = true; 
                
            }
            else{
                player_info[msg.sender].unmovable = true; 
                player_info[msg.sender].reward = false;
            }
		}
        
        emit RollDice(msg.sender, in_city, go_domains_id, player_info[msg.sender].unmovable);
    }
    
    function change_city(address _sender, uint16 go_city) private{
        require(!all_stop);
        require(owner_slave_amount >= 1);
        require(!player_info[_sender].unmovable,"不可移動"); 
        
        uint16 random = uint16((keccak256(abi.encodePacked(now, random_seed))));
        random_seed.add(1);
        
        uint16 tot_domains = inquire_city_totdomains(go_city);
        uint16 go_domains_id = random % tot_domains; 
        
        player_info[_sender].city = go_city;
        player_info[_sender].domain = go_domains_id;
        
        
        address city_address = owner_slave[go_city];
        address domain_owner = ERC721_interface(city_address).ownerOf(go_domains_id);
        
        if (domain_owner != 0x0){
            if(domain_owner == _sender){
                player_info[_sender].build = true; 
                
            }
            else{
                player_info[_sender].unmovable = true; 
                player_info[msg.sender].reward = false;
            }
		}
         
        emit Change_city(_sender, go_city, go_domains_id, player_info[_sender].unmovable);
    }
    
    function fly(uint16 _city, uint16 _domain) public payable{
        require(msg.value == 0.1 ether);
        require(owner_slave_amount >= 1);
        require(!player_info[msg.sender].unmovable);
        
        address[] memory checkPlayer;
        checkPlayer = checkBuildingPlayer(player_info[msg.sender].city,14);
     
        
        player_info[msg.sender].city = _city;
        player_info[msg.sender].domain = _domain;
        
        address city_address = owner_slave[_city];
        address domain_owner = ERC721_interface(city_address).ownerOf(_domain);
        uint exchange_player_ETH;
        

        if(checkPlayer.length!=0){
            exchange_player_ETH = msg.value.div(10).mul(1);
            
            for(uint8 i = 0 ; i< checkPlayer.length;i++){
    	        checkPlayer[i].transfer(exchange_player_ETH.div(checkPlayer.length));
            }
        } 

        
        if (domain_owner != 0x0){
            if(domain_owner == msg.sender){
                player_info[msg.sender].build = true; 
                
            }
            else{
                player_info[msg.sender].unmovable = true; 
                player_info[msg.sender].reward = false;
            }
		}
        player_info[msg.sender].lotto = true;
        emit Fly(msg.sender, _city, _domain , player_info[msg.sender].unmovable);
    }
    
    function playLotto() external{
        require(!all_stop);
        require(player_info[msg.sender].lotto);
        
        uint random = uint((keccak256(abi.encodePacked(now, random_seed))));
        uint random2 = uint((keccak256(abi.encodePacked(random_seed, msg.sender))));
        random_seed = random_seed.add(1);

        address _address = inquire_slave_address(player_info[msg.sender].city);
         
        if(player_info[msg.sender].unmovable == false){
            (,uint8 _star) = slave(_address).inquire_domain_level_star(player_info[msg.sender].domain);
                if(_star <= 1){
                    _star = 1;
                }
            probability = probability.div(2**(uint(_star)-1));                   
            uint8[] memory buildings = slave(_address).inquire_tot_domain_building(player_info[msg.sender].domain);
            for(uint8 i=0;i< buildings.length;i++){
                if(buildings[i] == 8 ){
                    probability = probability.div(10).mul(9);      
                    break; 
                }
            }
        }
        
        uint lotto_number = random % probability;
        uint player_number =  random2 % probability;
        
        probability = 1000000;   
        
        if(lotto_number == player_number){
            msg.sender.transfer(address(this).balance.div(10));
        }
        
        player_info[msg.sender].lotto = false;
        
        
        emit PlayLotto(msg.sender, player_number, lotto_number);
    }

     


    function payRoadETH_amount(uint8 _level, uint8 _star) public pure returns(uint){
         
        if(_level <= 1){
    	   return  0.02 ether * 2**(uint(_star)-1) ;
    	} 
    	else if(_level > 1) {    
    	   return  0.02 ether * 2**(uint(_star)-1)*(3**(uint(_level)-1))/(2**(uint(_level)-1)) ;
    	} 
    }
     
    function buyLandETH_amount(uint8 _level, uint8 _star) public pure returns(uint){

         
        if(_level <= 1){
    	   return  0.2 ether * 2**(uint(_star)-1) ;
    	} 
    	else if(_level > 1) {    
    	   return  0.2 ether * 2**(uint(_star)-1)*(3**(uint(_level)-1))/(2**(uint(_level)-1)) ;
    	} 
    }
     
    function payARINA_amount(uint8 _level, uint8 _star) public pure returns(uint){

        
        if(_level <= 1){
    	return (10**8) * (2**(uint(_star)-1)*10);
    	} 
    	
    	else if(_level > 1) {   
    	return (10**8) * (2**(uint(_star)-1)*10)*(3**(uint(_level)-1))/(2**(uint(_level)-1));
    	}

    }
     
    function buyLandARINA_amount() public pure returns(uint){
        return 2000*10**8;
    }
 
    function payRent_ETH() external payable{
        require(!all_stop);
        require(player_info[msg.sender].unmovable,"檢查不可移動");
        
        uint16 city = player_info[msg.sender].city; 
        uint16 domains_id = player_info[msg.sender].domain;  
        
        address city_address = owner_slave[city];
		address domain_owner = ERC721_interface(city_address).ownerOf(domains_id);
		
		if (domain_owner == 0x0){
		    revert("不用付手續費");
		}
        
        (uint8 _level,uint8 _star) = slave(city_address).inquire_domain_level_star(domains_id);
        
        uint _payRoadETH_amount = payRoadETH_amount(_level, _star);
        
        require(msg.value == _payRoadETH_amount);
        
        player_info[msg.sender].unmovable = false;

        uint payRent_ETH_50toOwner = msg.value.div(10).mul(5);
		uint payRent_ETH_10toTeam = msg.value.div(10);
		uint payRent_ETH_20toCity = msg.value.div(10).mul(2); 
		uint payRent_ETH_20toPool = msg.value.div(10).mul(2);
		uint pay = payRent_ETH_50toOwner + payRent_ETH_10toTeam + payRent_ETH_20toCity + payRent_ETH_20toPool;
		require(msg.value == pay);

		domain_owner.transfer(payRent_ETH_50toOwner); 
        manager.transfer(payRent_ETH_10toTeam); 
        city_address.transfer(payRent_ETH_20toCity); 
        
        player_info[msg.sender].lotto = true;
        player_info[msg.sender].reward = true;
        emit PayEth(msg.sender, msg.value, city, domains_id);
    }
    
    function buyLand_ETH() external payable{
        require(!all_stop);
        require(player_info[msg.sender].unmovable,"檢查不可移動");
        
        uint16 city = player_info[msg.sender].city;
        uint16 domains_id = player_info[msg.sender].domain;
        
        address city_address = owner_slave[city];
        address domain_owner = ERC721_interface(city_address).ownerOf(domains_id);
        
        (uint8 _level,uint8 _star) = slave(city_address).inquire_domain_level_star(domains_id);
        
        uint _buyLandETH_amount = buyLandETH_amount(_level, _star);
        require(msg.value == _buyLandETH_amount); 
        
        if(domain_owner == 0x0){
            revert("第一次請用Arina購買");
        }
        
        uint BuyLand_ETH_50toOwner;
        uint BuyLand_ETH_10toTeam;
        uint BuyLand_ETH_20toCity; 
        uint BuyLand_ETH_20toPool;
        uint pay;
        
        if(_level <= 1){
            BuyLand_ETH_50toOwner = msg.value.div(10).mul(5);
        	BuyLand_ETH_10toTeam = msg.value.div(10);
        	BuyLand_ETH_20toCity = msg.value.div(10).mul(2); 
        	BuyLand_ETH_20toPool = msg.value.div(10).mul(2);
        	pay = BuyLand_ETH_50toOwner + BuyLand_ETH_10toTeam + BuyLand_ETH_20toCity +BuyLand_ETH_20toPool;
        	require(msg.value == pay);
        		 
        	domain_owner.transfer(BuyLand_ETH_50toOwner); 
            manager.transfer(BuyLand_ETH_10toTeam); 
            city_address.transfer(BuyLand_ETH_20toCity); 
            
        }
        else{
            BuyLand_ETH_50toOwner = msg.value.div(10).mul(8);
        	BuyLand_ETH_10toTeam = msg.value.div(20);
        	BuyLand_ETH_20toCity = msg.value.div(20);
        	BuyLand_ETH_20toPool = msg.value.div(10);
        	pay = BuyLand_ETH_50toOwner + BuyLand_ETH_10toTeam + BuyLand_ETH_20toCity +BuyLand_ETH_20toPool;
        	require(msg.value == pay);
        		
        	domain_owner.transfer(BuyLand_ETH_50toOwner); 
            manager.transfer(BuyLand_ETH_10toTeam); 
            city_address.transfer(BuyLand_ETH_20toCity); 
            
        }
        
        slave(city_address).transfer_master(msg.sender, domains_id); 
        
        player_info[msg.sender].unmovable = false;
        player_info[msg.sender].lotto = true;
        emit BuyEth(msg.sender, msg.value, city, domains_id);
    }
     
    function _payRent_ARINA(address _sender, uint _value) private{
        require(!all_stop);
        
        require(player_info[_sender].unmovable,"檢查不可移動");
        
        uint16 city = player_info[_sender].city;
        uint16 domains_id = player_info[_sender].domain; 
        
        address city_address = owner_slave[city];
		address domain_owner = ERC721_interface(city_address).ownerOf(domains_id);
		
		if(domain_owner == 0x0){
            revert("空地不用付手續費");
        }

        (uint8 _level,uint8 _star) = slave(city_address).inquire_domain_level_star(domains_id);
        
        uint _payARINA_amount = payARINA_amount(_level, _star);
        
    	require(_value == _payARINA_amount,"金額不對");
        ERC20_interface arina = ERC20_interface(arina_contract);
        require(arina.transferFrom(_sender, domain_owner, _value),"交易失敗"); 

        player_info[_sender].unmovable = false;
        player_info[_sender].reward = true;
        
        emit PayArina(_sender, _value, city, domains_id);
    }

    function _buyLand_ARINA(address _sender, uint _value) private{ 
        
        
        require(!all_stop);
        uint16 city = player_info[_sender].city;
        uint16 domains_id = player_info[_sender].domain;
        
        address city_address = owner_slave[city];
		address domain_owner = ERC721_interface(city_address).ownerOf(domains_id);
        
        if(domain_owner != 0x0){
            revert("空地才能用Arina買");
        }
        
        uint _buyLandARINA_amount = buyLandARINA_amount();
        
        require(_value ==  _buyLandARINA_amount,"金額不對");
        ERC20_interface arina = ERC20_interface(arina_contract);
        require(arina.transferFrom(_sender, trade_address, _value)); 
        
        slave(city_address).transfer_master(_sender, domains_id); 
        trade(trade_address).set_city_pool(_value,city);          
        
        player_info[_sender].unmovable = false;
        emit BuyArina(_sender, _value, city, domains_id);
    }
    
    function _build(address _sender, uint8 _building,uint _arina) private {
        require(!all_stop);
        require(player_info[_sender].build == true,"不能建設");
        uint16 city = player_info[_sender].city;
        uint16 domains_id = player_info[_sender].domain;
        
        address city_address = owner_slave[city];
		address domain_owner = ERC721_interface(city_address).ownerOf(domains_id);
		require(_sender == domain_owner,"擁有者不是自己");
		
		slave(city_address).domain_build(domains_id, _building);
		player_info[_sender].build = false;
		
		emit Build(_sender, _building,_arina);
    }
    
    function reconstruction(uint8 _index, uint8 _building)public payable{
        uint16 city = player_info[msg.sender].city;
        uint16 domains_id = player_info[msg.sender].domain;
        uint BuyLand_ETH_toTeam;
        address city_address = owner_slave[city];
		address domain_owner = ERC721_interface(city_address).ownerOf(domains_id);
		require(msg.sender == domain_owner, "限定擁有者");
         
        uint arina_price = inquire_type_price(_building);
        uint eth_price = arina_price.mul(10**6); 
        
        require(msg.value == eth_price,"價格不對");
        BuyLand_ETH_toTeam = msg.value.div(10).mul(7);
        manager.transfer(BuyLand_ETH_toTeam); 
        slave(city_address).reconstruction(domains_id, _index, _building);
        player_info[msg.sender].lotto = true;
        emit Reconstruction(msg.sender, _building,eth_price);
    }
    
    function domain_attribute(uint16 _city,uint16 _id, uint8 _index) public{
        require(msg.sender == mix_address);
        require(!all_stop);
        address city_address = owner_slave[_city];
        slave(city_address).set_domian_attribute(_id,_index);
    }
     
    
    function reward(uint8 _class, uint16 _city, uint16 _domains_id) public{
        require(!all_stop);
        if(inquire_owner(_city,_domains_id) != msg.sender){     
            require(!player_info[msg.sender].unmovable,"不可移動"); 
            require(_city == player_info[msg.sender].city && _domains_id == player_info[msg.sender].domain);
            require(player_info[msg.sender].reward == true);
            player_info[msg.sender].reward = false;
        }
     
        address city_address = owner_slave[_city];
        slave(city_address).domain_reward(_class, msg.sender, _domains_id);
    }  
     
    function all_reward(uint8 _class,uint16 _city) public{
        address city_address;
        
        city_address = owner_slave[_city];
        slave(city_address).domain_all_reward(_class, msg.sender);
        
        
    }
      
    function mayor_all_reward(uint16 _city) public{

        address city_address = owner_slave[_city];
        address _mayor = slave(city_address).inquire_mayor_address();
        require(msg.sender == _mayor);
        slave(city_address).mayor_reward(msg.sender);
        
    }
     
    function set_member_name(address _owner, string new_name) payable public{
         require(msg.value == 0.1 ether);
         require(addressToName[msg.sender].length != 0); 
         require(msg.sender == _owner);
           
         bytes32 bytes_old_name = addressToName[msg.sender];   
         member[bytes_old_name] = 0x0;
         
         if(keccak256(abi.encodePacked(new_name)) == keccak256(abi.encodePacked(""))) {
             revert(); 
         } 
         bytes32 bytes_new_name =  stringToBytes32(new_name);    
        
         member[bytes_new_name] = msg.sender; 
         addressToName[msg.sender] = bytes_new_name;
         emit set_name(msg.sender,msg.value);
          
    }
    
    function exchange(uint16 _city,uint _value) payable public{
        uint rate;
        uint pool = trade(trade_address).inquire_pool(_city);
        
        uint exchange_master_ETH;
        uint exchange_player_ETH;
        uint exchange_Pool_ETH;
        require(msg.value == _value*10 ** 13);
        require(_city == player_info[msg.sender].city);
        address[] memory checkPlayer;
        
        
        if(pool > 500000 * 10 ** 8){ 
            rate = 10000;
        }else if(pool > 250000 * 10 ** 8 && pool <= 500000 * 10 ** 8  ){
            rate = 5000;
        }else if(pool > 100000 * 10 ** 8 && pool <= 250000 * 10 ** 8  ){
            rate = 3000;
        }else if(pool <= 100000 * 10 ** 8){
            revert();
        } 
        uint exchangeArina = _value * rate * 10 ** 3;
        trade(trade_address).exchange_arina(exchangeArina,_city, msg.sender);
        
        checkPlayer = checkBuildingPlayer(_city,15);
        
        if(checkPlayer.length !=0){
            exchange_master_ETH = msg.value.div(10).mul(8);
            exchange_player_ETH = msg.value.div(10).mul(1);
            exchange_Pool_ETH = msg.value.div(10).mul(1);
            
            for(uint8 i = 0 ; i< checkPlayer.length;i++){
    	        checkPlayer[i].transfer(exchange_player_ETH.div(checkPlayer.length));
    	    }
        }else{
            exchange_master_ETH = msg.value.div(10).mul(9);
            exchange_Pool_ETH = msg.value.div(10);
        }

        manager.transfer(exchange_master_ETH); 
        

    } 
     
    function checkBuildingPlayer(uint16 _city,uint8 building) public view  returns(address[] ){  
        
        
        address[] memory _players = new address[](100);
        uint16 counter = 0;
        for(uint8 i=0 ; i<100; i++){
            uint8[] memory buildings = slave(owner_slave[_city]).inquire_tot_domain_building(i);
            if(buildings.length != 0){
                for(uint8 j = 0; j < buildings.length; j++){ 
                    if(buildings[j] == building){
                        _players[counter] = inquire_owner(_city,i); 
                        counter = counter.add(1);
                        break;
                    } 
                }  
                
            }
        } 
        address[] memory players = new address[](counter);
        
        for (i = 0; i < counter; i++) {
            players[i] = _players[i];
        }
        
        
        return players;
    
    }
    
    
     
     
 


    
    
    
    

    function inquire_owner(uint16 _city, uint16 _domain) public view returns(address){
        address city_address = owner_slave[_city];
        return ERC721_interface(city_address).ownerOf(_domain);
    }
    
    function inquire_have_owner(uint16 _city, uint16 _domain) public view returns(bool){
        address city_address = owner_slave[_city];
        address domain_owner = ERC721_interface(city_address).ownerOf(_domain);
        if(domain_owner == 0x0){
        return false;
        }
        else{return true;}
    }

    
    function inquire_domain_level_star(uint16 _city, uint16 _domain) public view 
    returns(uint8, uint8){
        address _address = inquire_slave_address(_city);
        return slave(_address).inquire_domain_level_star(_domain);
    }
    
    function inquire_slave_address(uint16 _slave) public view returns(address){
        return owner_slave[_slave];
    }
    
    
    
    
    
    
    function inquire_city_totdomains(uint16 _index) public view returns(uint16){
        address _address = inquire_slave_address(_index);
        return  slave(_address).inquire_totdomains_amount();
    }
    
    function inquire_location(address _address) public view returns(uint16, uint16){
        return (player_info[_address].city, player_info[_address].domain);
    }
     
    function inquire_status(address _address) public view returns(bool, bool, bool){
        return (player_info[_address].unmovable, player_info[_address].lotto, player_info[_address].reward);
    }
    
    function inquire_type(uint8 _typeid) public view returns(string){
        return building_type[_typeid];
    }
    
    function inquire_type_price(uint8 _typeid) public view returns(uint){
        return building_price[_typeid];
    } 
    
    function inquire_building(uint16 _slave, uint16 _domain, uint8 _index)
    public view returns(uint8){
        address _address = inquire_slave_address(_slave);
        return slave(_address).inquire_domain_building(_domain, _index);
    }
    
    function inquire_building_amount(uint16 _slave,uint8 _building) public view returns(uint8){
        address _address = inquire_slave_address(_slave);
        return slave(_address).inquire_building_limit(_building);
    }
     
    function inquire_tot_attribute(uint16 _slave, uint16 _domain)
    public view returns(uint8[5]){
        address _address = inquire_slave_address(_slave);
        return slave(_address).inquire_tot_domain_attribute(_domain);
    }
    

    function inquire_cooltime(uint16 _slave, uint16 _domain)
    public view returns(uint){
        address _address = inquire_slave_address(_slave);
        return slave(_address).inquire_domain_cooltime(_domain);
    }
     
    
    
    
    
    
     
    function inquire_tot_building(uint16 _slave, uint16 _domain)
    public view returns(uint8[]){
        address _address = inquire_slave_address(_slave);
        return slave(_address).inquire_tot_domain_building(_domain);
    }
    
    function inquire_own_domain(uint16 _city) public view returns(uint16[]){
 
        address _address = inquire_slave_address(_city);
        return slave(_address).inquire_own_domain(msg.sender);
    }
    
    function inquire_land_info(uint16 _city, uint16 _id) public view returns(uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8,uint8){
    
        address _address = inquire_slave_address(_city);
        return slave(_address).inquire_land_info(_city,_id);
    }
     
    function inquire_GIClevel(address _address) view public returns(uint8 _level){
        uint GIC_balance = ERC20_interface(GIC_contract).balanceOf(_address);
        if (GIC_balance <= 1000*10**18){
            return 1;
        }
        else if(1000*10**18 < GIC_balance && GIC_balance <=10000*10**18){
            return 2;
        }
        else if(10000*10**18 < GIC_balance && GIC_balance <=100000*10**18){
            return 3;
        }
        else if(100000*10**18 < GIC_balance && GIC_balance <=500000*10**18){
            return 4;
        }
        else if(500000*10**18 < GIC_balance){
            return 5;
        }
        else revert();
    }



    
    function receiveApproval(address _sender, uint256 _value,
    address _tokenContract, bytes _extraData) public{
        
        require(_tokenContract == arina_contract);
          
        bytes1 action = _extraData[0];
    
    
        if (action == 0x0){ 
              
            _payRent_ARINA(_sender, _value);
        }
      
        else if(action == 0x1){ 
          
            _buyLand_ARINA(_sender, _value);
        } 
       
        else if(action == 0x2){ 
            require(_value == 100*10**8);
            uint16 _city = uint16(_extraData[1]);
             
            
            address[] memory checkPlayer;
            checkPlayer = checkBuildingPlayer(player_info[_sender].city,17);  
           
            if(checkPlayer.length != 0){
                for(uint8 i=0;i<checkPlayer.length;i++){
                    require(ERC20_interface(arina_contract).transferFrom(_sender, checkPlayer[i], _value.div(checkPlayer.length)),"交易失敗");
                } 
            }else{
                require(ERC20_interface(arina_contract).transferFrom(_sender, trade_address, _value),"交易失敗");
                trade(trade_address).set_city_pool(_value,player_info[_sender].city);
            }
            
             
            change_city(_sender, _city);
            
        }
      
        else if(action == 0x3){ 
         
            uint8 _building = uint8(_extraData[1]);
            
              
            uint build_value = inquire_type_price(_building);
    		
    		require(_value == build_value,"金額不對"); 
             
            require(ERC20_interface(arina_contract).transferFrom(_sender, trade_address, _value),"交易失敗");
            trade(trade_address).set_city_pool(_value,player_info[_sender].city);
            
            _build(_sender, _building,_value);
        }
        else{revert();}

    }
    


    function set_all_stop(bool _stop) public onlymanager{
        all_stop = _stop;
    }

    function withdraw_all_ETH() public onlymanager{
        manager.transfer(address(this).balance);
    }
     
    function withdraw_all_arina() public onlymanager{
        uint asset = ERC20_interface(arina_contract).balanceOf(address(this));
        ERC20_interface(arina_contract).transfer(manager, asset);
    }
    
    function withdraw_ETH(uint _eth_wei) public onlymanager{
        manager.transfer(_eth_wei);
    }
    
    function withdraw_arina(uint _arina) public onlymanager{
        ERC20_interface(arina_contract).transfer(manager, _arina); 
    }
    
    function set_arina_address(address _arina_address) public onlymanager{
        arina_contract = _arina_address;
    }
  
    
    
    
    
    
    
    function set_slave_mayor(uint16 _index, address newMayor_address) public onlymanager{
        address contract_address = owner_slave[_index];
        slave(contract_address).transferMayorship(newMayor_address); 
    }
     
    function push_slave_address(address _address) external onlymanager{
        
        require(slave(_address).master_address() == address(this));
        owner_slave.push(_address);
        owner_slave_amount = owner_slave_amount.add(1); 
    } 
    
    function change_slave_address(uint16 _index, address _address) external onlymanager{
        owner_slave[_index] = _address; 
    }
    
    function set_building_type(uint8 _type, string _name) public onlymanager{
        building_type[_type] = _name;
    }
    
    function set_type_price(uint8 _type, uint _price) public onlymanager{
        building_price[_type] = _price;
    }
    
    function set_trade_address(address _trade_address) public onlymanager{ 
       trade_address = _trade_address;
    }
    
    function set_mix_address(address _mix_address) public onlymanager{ 
       mix_address = _mix_address;
    }
    
    function set_cooltime(uint16 _index, uint _cooltime) public onlymanager{
        address contract_address = owner_slave[_index];
        slave(contract_address).set_domain_cooltime(_cooltime); 
    }
    


    constructor() public{
        random_seed = uint((keccak256(abi.encodePacked(now))));
        
        owner_slave.push(address(0));
        
        area[1] = "魔幻魔法區";
        area[2] = "蒸氣龐克區";
        area[3] = "現代區";
        area[4] = "SCI-FI科幻未來區";
                
        
        
        
        building_type[0] = "null" ; 
        building_type[1] = "Farm" ; 
        building_type[2] = "Mine" ; 
        building_type[3] = "Workshop" ; 
        building_type[4] = "Bazaar" ; 
        building_type[5] = "Arena" ;
        building_type[6] = "Adventurer's Guild" ; 
        building_type[7] = "Dungeon" ; 
        building_type[8] = "Lucky Fountain" ; 
        building_type[9] = "Stable" ; 
        building_type[10] = "Mega Tower" ; 
        
        building_type[11] = "Fuel station" ; 
        building_type[12] = "Research Lab" ; 
        building_type[13] = "Racecourse" ; 
        building_type[14] = "Airport" ; 
        building_type[15] = "Bank" ; 
        building_type[16] = "Department store" ; 
        building_type[17] = "Station" ;
        building_type[18] = "Hotel" ; 
        building_type[19] = "Shop" ; 
        building_type[20] = "Weapon factory" ; 
        
        
         
        
        building_price[0] = 0 ; 
        building_price[1] = 2000*10**8 ;
        building_price[2] = 2000*10**8 ;
        building_price[3] = 2000*10**8 ; 
        building_price[4] = 2000*10**8 ; 
        building_price[5] = 5000*10**8 ;
        building_price[6] = 5000*10**8 ;
        building_price[7] = 5000*10**8 ;
        building_price[8] = 5000*10**8 ;
        building_price[9] = 5000*10**8 ;
        building_price[10] = 5000*10**8 ; 
        
        building_price[11] = 2000*10**8 ; 
        building_price[12] = 10000*10**8 ;
        building_price[13] = 5000*10**8 ;
        building_price[14] = 20000*10**8 ; 
        building_price[15] = 10000*10**8 ; 
        building_price[16] = 5000*10**8 ;
        building_price[17] = 5000*10**8 ;
        building_price[18] = 5000*10**8 ;
        building_price[19] = 5000*10**8 ;
        building_price[20] = 5000*10**8 ;
    }
    
 }