pragma solidity ^0.4.16;

// --- ShareHolder forward declaration ---
contract ShareHolder
{
	function addToShareHoldersProfit(string, string) payable
	{
		// ...
	}
}
// --- End of ShareHolder forward declaration ---

contract Ownable 
{
	address m_addrOwner;

	function Ownable() 	
	{ 
		m_addrOwner = msg.sender; 
	}

	modifier onlyOwner() 
	{
		if (msg.sender != m_addrOwner) 
		{
			revert();
		}
    	_;
	}

	// ---

	function transferOwnership(address newOwner) onlyOwner 
	{
		m_addrOwner = newOwner;
	}

	// ---

	function isOwner() constant returns (bool bIsOwner) { return (m_addrOwner == msg.sender); }

}

// ------

contract DukeOfEther is Ownable
{
	address m_addrShareHolder = 0;      // addr. of ShareHolder Profit Manager

	uint m_deployedAtBlock = 0;			// Initial block of a contract, used in logging/reporting
	uint m_nOwnersMoney = 0;
	uint m_nNewCountryPrice = 1 ether;  // Pay to create NEW country
    uint m_nMinDukePrice = 1 finney;
    uint m_nDeterioration = 3;          // After day 60, loose 3% a day till m_nMinDukePrice
	uint m_nDaysBeforeDeteriorationStarts = 60;
    uint m_NextDukePaymentIncrease = 150; // Next Duke pays 150% of current
    uint m_nNumberOfActiveCountries = 0;

	struct Country
	{
        bool m_bIsDestroyed;
		string m_strNickName;
		uint m_nLastDukeRiseDate;
		address m_addrCurrentDuke;
		uint m_nCurrentDukePaid;
		string m_strCountry;
	}
	
	mapping (string => Country) m_Countries;	// Russia, USA, China... Add more using addNewCountry()
    
    // --- Events ---

	event updateDukeHistory(string strCountry, bool bIsDestroyed, string strNickName, 
        address indexed addrCurrentDuke, uint nCurrentDukePaid, uint date);
	event errorMessage(string strMessage);

	// --- Functions ---

	function DukeOfEther()
	{
        m_deployedAtBlock = block.number;
        // ---
		addCountry("USA");
		addCountry("Russia");
		addCountry("China");
        addCountry("Japan");
        addCountry("Taiwan");
        addCountry("Ukraine");
	}

	// ---
	
	function addCountry(string strCountry) internal
	{
	    Country memory newCountryInfo;
	    
        newCountryInfo.m_bIsDestroyed = false;
		newCountryInfo.m_strNickName = "Vacant";
		newCountryInfo.m_addrCurrentDuke = m_addrOwner;
		newCountryInfo.m_nCurrentDukePaid = m_nMinDukePrice;

        newCountryInfo.m_strCountry = strCountry;
        newCountryInfo.m_nLastDukeRiseDate = now;
		m_Countries[strCountry] = newCountryInfo;
        
        updateDukeHistory(strCountry, false, "Vacant", m_addrOwner, 0, now);
        
        m_nNumberOfActiveCountries++;
	}
	
	// ---
	
	function verifyNickNameAndCountry(string strCountry, string strNickName) internal
    {
		if(bytes(strNickName).length > 30 || bytes(strCountry).length > 30)
        {
            errorMessage("String too long: keep strNickName and strCountry <= 30");
            revert();
        }
	}

	// ---
	
	function processShareHolderFee(uint nFee, string strNickName) internal
	{	
		// --- ShareHolder interface ---
		if(m_addrShareHolder != 0)
        {
            ShareHolder contractShareHolder = ShareHolder(m_addrShareHolder);
            contractShareHolder.addToShareHoldersProfit.value(nFee)(strNickName, "");
        }
	}

	// ---
	
	function addRemoveCountry(string strCountry, string strNickName, bool bDestroy) payable
	{
		verifyNickNameAndCountry(strCountry, strNickName);

        if(!bDestroy && m_nNumberOfActiveCountries >= 12)
        {
            errorMessage("Too many active countries. Consider destroying few.");
            revert();
        }
        else if(bDestroy && m_nNumberOfActiveCountries <= 3)
        {
            errorMessage("There should be at least 3 countries alive");
            revert();
        }
        
        // Demiurg pays more, then gets even
        if(msg.value < getPaymentToAddRemoveCountry(strCountry, bDestroy))
		{
			errorMessage("Sorry, but country costs more");
			revert();
		}
      
        // Note that we do not check if the country exists: 
        // we take money and promote next Duke or Destroyer

		address addrPrevDuke = m_Countries[strCountry].m_addrCurrentDuke;
		
		uint nFee = msg.value / 25;	// 4%
        uint nAmount = msg.value - nFee;
        uint nDemiurgsEffectiveAmount = 100 * nAmount / m_NextDukePaymentIncrease;
	
		processShareHolderFee(nFee, strNickName);
        
        updateDukeHistory(strCountry, bDestroy, strNickName, msg.sender, msg.value, now);    
        
		Country memory newCountryInfo;
        newCountryInfo.m_bIsDestroyed = bDestroy;
        newCountryInfo.m_strCountry = strCountry;
        newCountryInfo.m_strNickName = strNickName;
		newCountryInfo.m_nLastDukeRiseDate = now;
		newCountryInfo.m_addrCurrentDuke = msg.sender;
		newCountryInfo.m_nCurrentDukePaid = nDemiurgsEffectiveAmount;
        
		m_Countries[strCountry] = newCountryInfo;
        
        if(bDestroy)
            m_nNumberOfActiveCountries--;
        else
            m_nNumberOfActiveCountries++;
        
        m_nOwnersMoney += (nAmount - nDemiurgsEffectiveAmount);
                
        addrPrevDuke.transfer(nDemiurgsEffectiveAmount);
	}
	
	// ---
	
	function becomeDuke(string strCountry, string strNickName) payable
	{
		if(msg.value < getMinNextBet(strCountry))
			revert();

        if(bytes(strNickName).length > 30 || bytes(strCountry).length > 30)
        {
            errorMessage("String too long: keep strNickName and strCountry <= 30");
            revert();
        }
            
        Country memory countryInfo = m_Countries[strCountry];
        if(countryInfo.m_addrCurrentDuke == 0 || countryInfo.m_bIsDestroyed == true)
		{
			errorMessage("This country does not exist: use addRemoveCountry first");
			revert();
		}
		
		address addrPrevDuke = m_Countries[strCountry].m_addrCurrentDuke;
            
		uint nFee = msg.value / 25;	// 4%
		uint nOwnersFee = msg.value / 100;	// 1%
		m_nOwnersMoney += nOwnersFee;

        uint nPrevDukeReceived = msg.value - nFee - nOwnersFee;
       
        countryInfo.m_bIsDestroyed = false;
        countryInfo.m_strNickName = strNickName;
		countryInfo.m_nLastDukeRiseDate = now;
		countryInfo.m_addrCurrentDuke = msg.sender;
		countryInfo.m_nCurrentDukePaid = msg.value;
		countryInfo.m_strCountry = strCountry;
        
        m_Countries[strCountry] = countryInfo;
        
        updateDukeHistory(strCountry, false, strNickName, msg.sender, msg.value, now); 

		processShareHolderFee(nFee, strNickName);
        
        addrPrevDuke.transfer(nPrevDukeReceived);
	}
	
	// ---
	
	function withdrawDukeOwnersMoney() onlyOwner
	{
		m_addrOwner.transfer(m_nOwnersMoney);
	}
	
	// ---
	
    function setShareHolder(address addr) onlyOwner { m_addrShareHolder = addr; }
    
	function isDestroyed(string strCountry) constant returns (bool) { return m_Countries[strCountry].m_bIsDestroyed; }
	function getInitBlock() constant returns (uint nInitBlock) { return m_deployedAtBlock; }
	function getDukeNickName(string strCountry) constant returns (string) 
        { return m_Countries[strCountry].m_strNickName; }
	function getDukeDate(string strCountry) constant returns (uint date) 
        { return m_Countries[strCountry].m_nLastDukeRiseDate; }
	function getCurrentDuke(string strCountry) constant returns (address addr) 
        { return m_Countries[strCountry].m_addrCurrentDuke; }
	function getCurrentDukePaid(string strCountry) constant returns (uint nPaid) 
        { return m_Countries[strCountry].m_nCurrentDukePaid; }
	function getMinNextBet(string strCountry) constant returns (uint nNextBet) 
	{
		if(m_Countries[strCountry].m_nCurrentDukePaid == 0)
			return 1 finney;

        uint nDaysSinceLastRise = (now - m_Countries[strCountry].m_nLastDukeRiseDate) / 86400;
        uint nDaysMax = m_nDaysBeforeDeteriorationStarts + 100 / m_nDeterioration;
        if(nDaysSinceLastRise >= nDaysMax)
            return 1 finney;

        uint nCurrentDukeDue = m_Countries[strCountry].m_nCurrentDukePaid;
        if(nDaysSinceLastRise > m_nDaysBeforeDeteriorationStarts)
            nCurrentDukeDue = nCurrentDukeDue * (nDaysSinceLastRise - m_nDaysBeforeDeteriorationStarts) * m_nDeterioration / 100; 
            
		return  m_NextDukePaymentIncrease * nCurrentDukeDue / 100; 
	}

	function getPaymentToAddRemoveCountry(string strCountry, bool bRemove) constant returns (uint)
	{
		if(bRemove && m_Countries[strCountry].m_addrCurrentDuke == 0)
			return 0;
		else if(!bRemove && m_Countries[strCountry].m_addrCurrentDuke != 0 && m_Countries[strCountry].m_bIsDestroyed == false)	
			return 0;

		uint nPrice = m_NextDukePaymentIncrease * getMinNextBet(strCountry) / 100;
		if(nPrice < m_nNewCountryPrice)
			nPrice = m_nNewCountryPrice;
		return nPrice;	
	}
	
    // TBD: make it deletable
}