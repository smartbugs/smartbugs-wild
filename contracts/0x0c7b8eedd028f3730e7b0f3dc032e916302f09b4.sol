//Contract Adress: 0xb58b2b121128719204d1F813F8B4100F63511F50
//
//Query "CafeMaker.locked": https://api.etherscan.io/api?module=proxy&action=eth_getStorageAt&address=0xb58b2b121128719204d1F813F8B4100F63511F50&position=0x0&tag=latest&apikey=YourApiKeyToken

contract CafeMaker{

	bool public locked = true;

	uint public CafePayed;
	uint public CafeDelivered;


	uint public PricePerCafe = 50000000000000000; //0.05 eth
	address public DeviceOwner = msg.sender;
	address public DeviceAddr;

	function RegisterDevice() {
		DeviceAddr = msg.sender;
	}

	function BookCafe(){

		if(DeviceAddr != msg.sender)
			throw; //only the device can call this

		CafeDelivered += 1;

		if(CafePayed - CafeDelivered < 1)
			locked=true;

	}


	function CollectMoney(uint amount){
       if (!DeviceOwner.send(amount))
            throw;
		
	}


	//ProcessIncomingPayment
    function () {

		CafePayed += (msg.value / PricePerCafe);

		if(CafePayed - CafeDelivered < 1){
			locked=true;
		} else {
			locked=false;
		}

    }
}