pragma solidity  ^0.4.24;
contract AllYours {

    // uint128 private _totalEth = 0.2 ether;

    // uint128 private _winTotalEth = 0.15 ether;

    // uint128 private _platformTotalEth = 0.05 ether;

    // uint16 private _needTimes = 4;

    // uint128 private _oneceEth = 0.05 ether;

     // uint24 private _needTimes = 10;

   

    address private _platformAddress = 0xbE9C1088FEEB8B48A96Da0231062eA757D0a9613;

    uint private _totalEth = 0.05 ether;

 

    uint128 private _oneceEth = 0.01 ether;

    uint256 private _period = 1;

    address private _owner;

    

    constructor() public{

        _owner = msg.sender;

    }

    

    // mapping(address => uint16) private _playerOfNumber;

    mapping(uint24 => address) private _allPlayer;

    address[] private _allAddress;

    uint16 private _currentJoinPersonNumber;

    string private _historyJoin;

    

    event drawCallback(address winnerAddress,uint period,uint balance,uint time );

    

    function getCurrentJoinPersonNumber() view public returns(uint24) {

        return _currentJoinPersonNumber;

    }

    

    // function getAddressJoinPersonNumber() view public returns(uint24) {

    // return _playerOfNumber[msg.sender];

    // }

    

    

    

    function getHistory() view public returns(string) {

        return _historyJoin;

    }

    

    function getPeriod() view public returns(uint256) {

        return _period;

    }

    function getCurrentBalance() view public returns(uint256) {

        return address(this).balance;

    }

 

    

    function draw() internal view returns (uint24) {

        bytes32 hash = keccak256(abi.encodePacked(block.number));

        uint256 random = 0;

        for(uint i=hash.length-8;i<hash.length;i++) {

            random += uint256(hash[i])*(10**(hash.length-i));

        }

        

        random += now;

        

         bytes memory hashAddress=toBytes(_allAddress[0]); 

         for(uint j=0;j<8;j++) {

            random += uint(hashAddress[j])*(10**(8-j));

        }

        

        uint24 index = uint24(random % _allAddress.length);

        

        return index;

       

    }

    

    // 销毁当前合约

    function kill() public payable {

       

        if (_owner == msg.sender) {

             _platformAddress.transfer(address(this).balance);

            selfdestruct(_owner);

        }





    }

   

    function() public payable {

        require(msg.value >= _oneceEth);

        

        // _playerOfNumber[msg.sender] += 1;

        uint len = msg.value/_oneceEth;

        for(uint i=0;i<len;i++) {

            _allPlayer[_currentJoinPersonNumber ++] = msg.sender;

            _allAddress.push(msg.sender);

        }

        

        

        _historyJoin = strConcat(_historyJoin,"&",uint2str(now),"|",addressToString(msg.sender)) ;

        

        if(address(this).balance >= _totalEth) {

            

            uint24 index = draw();

            address drawAddress = _allPlayer[index];

            uint256 b = address(this).balance;

            uint256 pay = b*70/100;

            drawAddress.transfer(pay);

            _platformAddress.transfer(b*30/100);

            

            emit drawCallback(drawAddress,_period,pay,now);

            _period ++;

          clear();

           

   

        }

        

    }

    

    function clear() internal {

         for(uint16 i=0;i<_allAddress.length;i++) {

                // delete _playerOfNumber[_allAddress[i]];

                delete _allPlayer[i];

            }

            

           _currentJoinPersonNumber = 0;

          _historyJoin = "";

           delete _allAddress;

    }

    

    function toBytes(address x) internal pure returns (bytes b) {

         b = new bytes(20);

         for (uint i = 0; i < 20; i++)

                b[i] = byte(uint8(uint(x) / (2**(8*(19 - i)))));

    }

    

    

   function addressToString(address _addr) internal pure returns (string) {

               bytes32 value = bytes32(uint256(_addr));



        bytes memory alphabet = "0123456789abcdef";







        bytes memory str = new bytes(42);



        str[0] = '0';



        str[1] = 'x';



        for (uint i = 0; i < 20; i++) {



            str[2+i*2] = alphabet[uint(value[i + 12] >> 4)];



            str[3+i*2] = alphabet[uint(value[i + 12] & 0x0f)];



        }



        return string(str);

    }

    

    function uint2str(uint256 i) internal pure returns (string){

        if (i == 0) return "0";

        uint j = i;

        uint len;

        while (j != 0){

            len++;

            j /= 10;

        }

        bytes memory bstr = new bytes(len);

        uint k = len - 1;

        while (i != 0){

            bstr[k--] = byte(48 + i % 10);

            i /= 10;

        }

        return string(bstr);

    }

    

    

    

     function strConcat(string _a, string _b, string _c, string _d, string _e) internal pure returns (string) {

        bytes memory _ba = bytes(_a);

        bytes memory _bb = bytes(_b);

        bytes memory _bc = bytes(_c);

        bytes memory _bd = bytes(_d);

        bytes memory _be = bytes(_e);

        string memory abcde = new string(_ba.length + _bb.length + _bc.length + _bd.length + _be.length);

        bytes memory babcde = bytes(abcde);

        uint k = 0;

        for (uint i = 0; i < _ba.length; i++) babcde[k++] = _ba[i];

        for (i = 0; i < _bb.length; i++) babcde[k++] = _bb[i];

        for (i = 0; i < _bc.length; i++) babcde[k++] = _bc[i];

        for (i = 0; i < _bd.length; i++) babcde[k++] = _bd[i];

        for (i = 0; i < _be.length; i++) babcde[k++] = _be[i];

        return string(babcde);

    }

    

    

}