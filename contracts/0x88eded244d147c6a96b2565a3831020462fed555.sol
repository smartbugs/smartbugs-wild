pragma solidity ^0.4.15;



library SafeMath {

    function mul(uint256 a, uint256 b) internal constant returns (uint256) {
        if (a == 0) {
			return 0;
		}
		uint256 c = a * b;
        assert(c / a == b);
        return c;
    }

    function div(uint256 a, uint256 b) internal constant returns (uint256) {
        // assert(b > 0); // Solidity automatically throws when dividing by 0
        uint256 c = a / b;
        // assert(a == b * c + a % b); // There is no case in which this doesn't hold
        return c;
    }

    function add(uint256 a, uint256 b) internal constant returns (uint256) {
        uint256 c = a + b;
        assert(c >= a && c >= b);
        return c;
    }
	
	function sub(uint256 a, uint256 b) internal constant returns (uint256) {
		assert(b <= a);
		return a - b;
	}

}



contract Token {

    uint256 public totalSupply;

    function balanceOf(address _owner) constant returns (uint256 balance);
    function transfer(address _to, uint256 _value) returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success);
    function approve(address _spender, uint256 _value) returns (bool success);
    function allowance(address _owner, address _spender) constant returns (uint256 remaining);

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

}



contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
		require( msg.data.length >= (2 * 32) + 4 );
		require( _value > 0 );
		require( balances[msg.sender] >= _value );
		require( balances[_to] + _value > balances[_to] );

        balances[msg.sender] -= _value;
        balances[_to] += _value;
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
		require( msg.data.length >= (3 * 32) + 4 );
		require( _value > 0 );
		require( balances[_from] >= _value );
		require( allowed[_from][msg.sender] >= _value );
		require( balances[_to] + _value > balances[_to] );

        balances[_from] -= _value;
		allowed[_from][msg.sender] -= _value;
		balances[_to] += _value;
        Transfer(_from, _to, _value);
        return true;
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
		require( _value == 0 || allowed[msg.sender][_spender] == 0 );

        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
        return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;

}



contract WhaleToken is StandardToken {

    using SafeMath for uint256;

	string public constant name = "WhaleFUND";								// WHALE tokens name
    string public constant symbol = "WHALE";								// WHALE tokens ticker
    uint256 public constant decimals = 18;									// WHALE tokens decimals
	string public version = "1.0";											// WHALE version

	uint256 public constant maximumSupply =  800 * (10**3) * 10**decimals;	// Maximum 800k Whale tokens
	uint256 public constant operatingFund = 152 * (10**3) * 10**decimals;	// 19% - 152k WHALE reserved for operating expenses
	uint256 public constant teamFund = 120 * (10**3) * 10**decimals;		// 15% - 120k WHALE reserved for WhaleFUND team
	uint256 public constant partnersFund = 24 * (10**3) * 10**decimals;		// 3% - 24k WHALE reserved for partner program
	uint256 public constant bountyFund = 24 * (10**3) * 10**decimals;		// 3% - 24k WHALE reserved for bounty program
	
	uint256 public constant whaleExchangeRate = 100;						// 100 WHALE tokens per 1 ETH
	
	uint256 public constant preIcoBonus = 15;								// PreICO bonus 15%
	uint256 public constant icoThreshold1 = 420 * (10**3) * 10**decimals;	// <100k sold WHALE tokens, without 152k+120k+24k+24k=320k reserved tokens
	uint256 public constant icoThreshold2 = 520 * (10**3) * 10**decimals;	// >100k && <200k sold WHALE tokens, without 152k+120k+24k+24k=320k reserved tokens
	uint256 public constant icoThreshold3 = 620 * (10**3) * 10**decimals;	// >200k && <300k sold WHALE tokens, without 152k+120k+24k+24k=320k reserved tokens
	uint256 public constant icoThresholdBonus1 = 10;						// ICO threshold bonus 10%
	uint256 public constant icoThresholdBonus2 = 5;							// ICO threshold bonus 5%
	uint256 public constant icoThresholdBonus3 = 3;							// ICO threshold bonus 3%
	uint256 public constant icoAmountBonus1 = 2;							// ICO amount bonus 2%
	uint256 public constant icoAmountBonus2 = 3;							// ICO amount bonus 3%
	uint256 public constant icoAmountBonus3 = 5;							// ICO amount bonus 5%

    address public etherAddress;
    address public operatingFundAddress;
	address public teamFundAddress;
	address public partnersFundAddress;
	address public bountyFundAddress;
	address public dividendFundAddress;

    bool public isFinalized;
	uint256 public constant crowdsaleStart = 1511136000;					// Monday, 20 November 2017, 00:00:00 UTC
	uint256 public constant crowdsaleEnd = 1513555200;						// Monday, 18 December 2017, 00:00:00 UTC

    event createWhaleTokens(address indexed _to, uint256 _value);


    function WhaleToken(
        address _etherAddress,
        address _operatingFundAddress,
		address _teamFundAddress,
		address _partnersFundAddress,
		address _bountyFundAddress,
		address _dividendFundAddress
	)
    {

        isFinalized = false;

        etherAddress = _etherAddress;
        operatingFundAddress = _operatingFundAddress;
		teamFundAddress = _teamFundAddress;
	    partnersFundAddress = _partnersFundAddress;
		bountyFundAddress = _bountyFundAddress;
		dividendFundAddress = _dividendFundAddress;
		
		totalSupply = totalSupply.add(operatingFund).add(teamFund).add(partnersFund).add(bountyFund);

		balances[operatingFundAddress] = operatingFund;						// Update operating funds balance
		createWhaleTokens(operatingFundAddress, operatingFund);				// Create operating funds tokens

		balances[teamFundAddress] = teamFund;								// Update team funds balance
		createWhaleTokens(teamFundAddress, teamFund);						// Create team funds tokens

		balances[partnersFundAddress] = partnersFund;						// Update partner program funds balance
		createWhaleTokens(partnersFundAddress, partnersFund);				// Create partner program funds tokens
		
		balances[bountyFundAddress] = bountyFund;							// Update bounty program funds balance
		createWhaleTokens(bountyFundAddress, bountyFund);					// Create bounty program funds tokens

	}


    function makeTokens() payable  {

		require( !isFinalized );
		require( now >= crowdsaleStart );
		require( now < crowdsaleEnd );
		
		if (now < crowdsaleStart + 7 days) {
			require( msg.value >= 3000 finney );
		} else if (now >= crowdsaleStart + 7 days) {
			require( msg.value >= 10 finney );
		}


		uint256 buyedTokens = 0;
		uint256 bonusTokens = 0;
		uint256 bonusThresholdTokens = 0;
		uint256 bonusAmountTokens = 0;
		uint256 tokens = 0;


		if (now < crowdsaleStart + 7 days) {

			buyedTokens = msg.value.mul(whaleExchangeRate);								// Buyed WHALE tokens without bonuses
			bonusTokens = buyedTokens.mul(preIcoBonus).div(100);						// preICO bonus 15%
			tokens = buyedTokens.add(bonusTokens);										// Buyed WHALE tokens with bonuses
	
		} else {
		
			buyedTokens = msg.value.mul(whaleExchangeRate);								// Buyed WHALE tokens without bonuses

			if (totalSupply <= icoThreshold1) {
				bonusThresholdTokens = buyedTokens.mul(icoThresholdBonus1).div(100);	// ICO threshold bonus 10%
			} else if (totalSupply > icoThreshold1 && totalSupply <= icoThreshold2) {
				bonusThresholdTokens = buyedTokens.mul(icoThresholdBonus2).div(100);	// ICO threshold bonus 5%
			} else if (totalSupply > icoThreshold2 && totalSupply <= icoThreshold3) {
				bonusThresholdTokens = buyedTokens.mul(icoThresholdBonus3).div(100);	// ICO threshold bonus 3%
			} else if (totalSupply > icoThreshold3) {
				bonusThresholdTokens = 0;												// ICO threshold bonus 0%
			}

			if (msg.value < 10000 finney) {
				bonusAmountTokens = 0;													// ICO amount bonus 0%
			} else if (msg.value >= 10000 finney && msg.value < 100010 finney) {
				bonusAmountTokens = buyedTokens.mul(icoAmountBonus1).div(100);			// ICO amount bonus 2%
			} else if (msg.value >= 100010 finney && msg.value < 300010 finney) {
				bonusAmountTokens = buyedTokens.mul(icoAmountBonus2).div(100);			// ICO amount bonus 3%
			} else if (msg.value >= 300010 finney) {
				bonusAmountTokens = buyedTokens.mul(icoAmountBonus3).div(100);			// ICO amount bonus 5%
			}

			tokens = buyedTokens.add(bonusThresholdTokens).add(bonusAmountTokens);		// Buyed WHALE tokens with bonuses

		}

	    uint256 currentSupply = totalSupply.add(tokens);

		require( maximumSupply >= currentSupply );

        totalSupply = currentSupply;

        balances[msg.sender] += tokens;										// Update buyer balance 
        createWhaleTokens(msg.sender, tokens);								// Create buyed tokens
		
		etherAddress.transfer(msg.value);									// Transfer ETH to MultiSig Address

    }


    function() payable {

        makeTokens();

    }


    function finalizeCrowdsale() external {

		require( !isFinalized );											// Required crowdsale state FALSE
		require( msg.sender == teamFundAddress );							// Required call from team fund address
		require( now > crowdsaleEnd || totalSupply == maximumSupply );		// Required crowdsale ended or maximum supply reached
		
		uint256 remainingSupply = maximumSupply.sub(totalSupply);			// Remaining tokens to reach maximum supply
		if (remainingSupply > 0) {
			uint256 updatedSupply = totalSupply.add(remainingSupply);		// New total supply
			totalSupply = updatedSupply;									// Update total supply
			balances[dividendFundAddress] += remainingSupply;				// Update dividend funds balance
			createWhaleTokens(dividendFundAddress, remainingSupply);		// Create dividend funds tokens
		}

        isFinalized = true;													// Set crowdsale state TRUE

    }

}