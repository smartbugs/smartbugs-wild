/**
 * This contract manages the messages (or ads) to be displayed in the Pray4Prey aquarium.
 **/

contract mortal {
	address owner;

	function mortal() {
		owner = msg.sender;
	}

	function kill() {
		if (owner == msg.sender)
			suicide(owner);
	}
}

contract Display is mortal {
	/** the price per advertisement type per time interval (day, week, month). **/
	uint[][] prices;
	/** the duration of an interval in days **/
	uint16[] duration;
	/** list of advertisements per address **/
	Ad[] ads;
	/** the expiry dates of the locks per adType*/
	uint[] locks;

	struct Ad {
		//the id of the ad
		uint32 id;
		// the type of the ad
		uint8 adType;
		// the expiry timestamp 
		uint expiry;
		//the corresponding address
		address client;
	}

	/** 
	 * sets the default values
	 **/
	function Display() {
		prices = [
			[100000000000000000, 300000000000000000, 500000000000000000],
			[500000000000000000, 1500000000000000000, 2500000000000000000],
			[2000000000000000000, 5000000000000000000, 8000000000000000000]
		];
		duration = [1, 7, 30];
		locks = [now, now, now];
	}

	/** buys the basic ad **/
	function() payable {
		buyAd(0, 0);
	}

	/** buys a specific ad**/
	function buyAd(uint8 adType, uint8 interval) payable {
		if (adType >= prices.length || interval >= duration.length || msg.value < prices[interval][adType]) throw;
		if (locks[adType] > now) throw;
		ads.push(Ad(uint32(ads.length), adType, now + msg.value / prices[interval][adType] * duration[interval] * 1 days, msg.sender));
	}

	/** change the prices of an interval **/
	function changePrices(uint[3] newPrices, uint8 interval) {
		prices[interval] = newPrices;
	}

	/** let the owner withdraw the funds */
	function withdraw() {
		if (msg.sender == owner)
			owner.send(address(this).balance);
	}

	/* returns 10 ads beginning from startindex */
	function get10Ads(uint startIndex) constant returns(uint32[10] ids, uint8[10] adTypes, uint[10] expiries, address[10] clients) {
		uint endIndex = startIndex + 10;
		if (endIndex > ads.length) endIndex = ads.length;
		uint j = 0;
		for (uint i = startIndex; i < endIndex; i++) {
			ids[j] = ads[i].id;
			adTypes[j] = (ads[i].adType);
			expiries[j] = (ads[i].expiry);
			clients[j] = (ads[i].client);
			j++;
		}
	}

	/** returns the number of ads **/
	function getNumAds() constant returns(uint) {
		return ads.length;
	}

	/** returns the prices of an interval**/
	function getPricesPerInterval(uint8 interval) constant returns(uint[]) {
		return prices[interval];
	}

	/** returns the price of a given type for a given interval**/
	function getPrice(uint8 adType, uint8 interval) constant returns(uint) {
		return prices[interval][adType];
	}

	/** locks a type until a given date **/
	function lock(uint8 adType, uint expiry) {
		locks[adType] = expiry;
	}
}