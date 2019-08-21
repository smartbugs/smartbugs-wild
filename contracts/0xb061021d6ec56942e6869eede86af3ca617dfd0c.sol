pragma solidity ^0.4.25;

/*
    Lambo Lotto Win | Dapps game for real crypto human
    site: https://llotto.win/
    telegram: https://t.me/Lambollotto/
    discord: https://discord.gg/VWV5jeW/
    
    win 122%, bet 0.15 ETH, 5 players 4 winners
    win 131%, bet 0.10 ETH, 4 players 3 winners
    win 144%, bet 0.05 ETH, 3 players 2 winners
    win 194%, bet 0.01 ETH, 2 players 1 winners
*/    
    
contract umbrellaLlotto {
    
    address public tech = msg.sender;
    address public promo = msg.sender;

    uint private techGet = 0;
    uint private promoGet = 0;
    
    address[] public placesFirst;
    address[] public placesSecond;
    address[] public placesThird;
    address[] public placesFour;
    
    uint private seed;
    
    uint public totalIn;
    
    uint public roundPlacesFirst = 1;
    uint public roundPlacesSecond = 1;
    uint public roundPlacesThird = 1;
    uint public roundPlacesFour = 1;

    event playerFirstEvent(uint numpl, address pl, uint indexed round);
    event playerSecondEvent(uint numpl, address pl, uint indexed round);
    event playerThirdEvent(uint numpl, address pl, uint indexed round);
    event playerFourEvent(uint numpl, address pl, uint indexed round);

    event placesFirstEvent(address indexed pl, uint round, bool win);
    event placesSecondEvent(address indexed pl, uint round, bool win);
    event placesThirdEvent(address indexed pl, uint round, bool win);
    event placesFourEvent(address indexed pl, uint round, bool win);
    
    // returns a pseudo-random number
    function random(uint lessThan) internal returns (uint) {
        return uint(sha256(abi.encodePacked(
            blockhash(block.number - lessThan - 1),
            msg.sender,
            seed += (block.difficulty % lessThan)
        ))) % lessThan;
    }
    
    function() external payable {
        
        require(msg.sender == tx.origin);
        require(msg.value == 0.15 ether || msg.value == 0.1 ether || msg.value == 0.05 ether || msg.value == 0.01 ether);
        
        totalIn += msg.value;
        
        if(msg.value == 0.01 ether) // 1 from 2 players get 194%
        {
            placesFirst.push(msg.sender);
            emit playerFirstEvent(placesFirst.length , msg.sender, roundPlacesFirst);
            
            if (placesFirst.length == 2) {
                uint loserF = random(placesFirst.length);
                for (uint iF = 0; iF < placesFirst.length; iF++) {
                    if (iF != loserF) {
                        placesFirst[iF].transfer(0.0194 ether);
                        emit placesFirstEvent(placesFirst[iF], roundPlacesFirst, true);
                    }else{
                        emit placesFirstEvent(placesFirst[iF], roundPlacesFirst, false);
                    }
                }
                
                promoGet += 0.0004 ether;
                techGet += 0.0002 ether;
                
                delete placesFirst;
                roundPlacesFirst++;
            }
        }

        if(msg.value == 0.05 ether) // 2 from 3 players get 144%
        {
            placesSecond.push(msg.sender);
            emit playerSecondEvent(placesSecond.length, msg.sender, roundPlacesSecond);
            
            if (placesSecond.length == 3) {
                uint loserS = random(placesSecond.length);
                for (uint iS = 0; iS < placesSecond.length; iS++) {
                    if (iS != loserS) {
                        placesSecond[iS].transfer(0.072 ether);
                        emit placesSecondEvent(placesSecond[iS], roundPlacesSecond, true);
                    }else{
                        emit placesSecondEvent(placesSecond[iS], roundPlacesSecond, false);
                    }
                }

                promoGet += 0.004 ether;
                techGet += 0.002 ether;
                
                delete placesSecond;
                roundPlacesSecond++;
            }
        }
        
        if(msg.value == 0.1 ether) // 3 from 4 players get 131%
        {
            placesThird.push(msg.sender);
            emit playerThirdEvent(placesThird.length, msg.sender, roundPlacesThird);
            
            if (placesThird.length == 4) {
                uint loserT = random(placesThird.length);
                for (uint iT = 0; iT < placesThird.length; iT++) {
                    if (iT != loserT) {
                        placesThird[iT].transfer(0.131 ether);
                        emit placesThirdEvent(placesThird[iT], roundPlacesThird, true);
                    }else{
                        emit placesThirdEvent(placesThird[iT], roundPlacesThird, false);
                    }
                }

                promoGet += 0.004 ether;
                techGet += 0.003 ether;
                
                delete placesThird;
                roundPlacesThird++;
            }
        } 
        
        if(msg.value == 0.15 ether) // 4 from 5 players get 122%
        {
            placesFour.push(msg.sender);
            emit playerFourEvent(placesFour.length, msg.sender, roundPlacesFour);
            
            if (placesFour.length == 5) {
                uint loserFr = random(placesFour.length);
                for (uint iFr = 0; iFr < placesFour.length; iFr++) {
                    if (iFr != loserFr) {
                        placesFour[iFr].transfer(0.183 ether);
                        emit placesFourEvent(placesFour[iFr], roundPlacesFour, true);
                    }else{
                        emit placesFourEvent(placesFour[iFr], roundPlacesFour, false);
                    }
                }

                promoGet += 0.012 ether;
                techGet += 0.006 ether;
                
                delete placesFour;
                roundPlacesFour++;
            }
        }        

    }
    
    function promoGetGift() public{
        require(msg.sender == promo);
        if(promo.send(promoGet)){
            promoGet = 0;
        }    
    } 
    
    function techGetGift() public{
        require(msg.sender == tech);
        if(tech.send(techGet)){
            techGet = 0;
        }
    }   
    
    function setPromoGet(address _newPromoGet)
        public{
        require(msg.sender == tech);
        require(msg.sender == tx.origin);
        promo =  _newPromoGet;
    }    
}