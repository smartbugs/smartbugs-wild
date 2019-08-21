pragma solidity ^0.4.13;

contract Owned {
    address public Owner;

    function Owned() internal {
        Owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == Owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        Owner = newOwner;
    }
}


contract Feed is Owned {
    uint public basePrice=0.005 ether;
    uint public k=1;
    uint public showInterval=15;
    uint public totalMessages=0;

    
    struct Message
    {
        string content;
        uint date;
        address sender;
        uint price;
        uint show_date;
        uint rejected;
        string rejected_reason;
    }    
    
    mapping (uint => Message) public messageInfo;
    

    /* events */
    event Transfer(address indexed from, address indexed to, uint256 value);


    /* Initializes contract  */
    function Feed() {
       
    }

    function() public payable {
        submitMessage("");
    }    
    
    function queueCount() public returns (uint _count) {
        _count=0;
        for (uint i=totalMessages; i>0; i--) {
            if (messageInfo[i].show_date<(now-showInterval) && messageInfo[i].rejected==0) return _count;
            if (messageInfo[i].rejected==0) _count++;
        }
        return _count;
    }
    
    function currentMessage(uint _now) public returns ( uint _message_id, string _content, uint _show_date,uint _show_interval,uint _serverTime) {
        require(totalMessages>0);
        if (_now==0) _now=now;
        for (uint i=totalMessages; i>0; i--) {
            if (messageInfo[i].show_date>=(_now-showInterval) && messageInfo[i].show_date<_now && messageInfo[i].rejected==0) {
                //good    
                if (messageInfo[i+1].show_date>0) _show_interval=messageInfo[i+1].show_date-messageInfo[i].show_date; else _show_interval=showInterval;
                return (i,messageInfo[i].content,messageInfo[i].show_date,_show_interval,_now);
            }
             if (messageInfo[i].show_date<(_now-showInterval)) throw;
        }
        throw;
    }  

  
    function submitMessage(string _content) payable public returns(uint _message_id, uint _message_price, uint _queueCount) {
        require(msg.value>0);
        if (bytes(_content).length<1 || bytes(_content).length>150) throw;
        uint total=queueCount();
        uint _last_Show_data=messageInfo[totalMessages].show_date;
        if (_last_Show_data==0) _last_Show_data=now+showInterval*2; else {
            if (_last_Show_data<(now-showInterval)) {
                _last_Show_data=_last_Show_data+(((now-_last_Show_data)/showInterval)+1)*showInterval;
            } else _last_Show_data=_last_Show_data+showInterval; 
        }
        uint message_price=basePrice+basePrice*total*k;
        require(msg.value>=message_price);

        // add message
        totalMessages++;
        messageInfo[totalMessages].date=now;
        messageInfo[totalMessages].sender=msg.sender;
        messageInfo[totalMessages].content=_content;
        messageInfo[totalMessages].price=message_price;
        messageInfo[totalMessages].show_date=_last_Show_data;
        
        // refound
        if (msg.value>message_price) {
            uint cashback=msg.value-message_price;
            sendMoney(msg.sender,cashback);
        }
        
        return (totalMessages,message_price,(total+1));
    }

	function sendMoney(address _address, uint _amount) internal {
		require(this.balance >= _amount);
    	if (_address.send(_amount)) {
    		Transfer(this,_address, _amount);
    	}	    
	}
	
	function withdrawBenefit(address _address, uint _amount) onlyOwner public {
		sendMoney(_address,_amount);

	}
	
    
	function setBasePrice(uint _newprice) onlyOwner public returns(uint _basePrice) {
		require(_newprice>0);
		basePrice=_newprice;
		return basePrice;
	}    
	
	function setShowInterval(uint _newinterval) onlyOwner public returns(uint _showInterval) {
		require(_newinterval>0);
		showInterval=_showInterval;
		return showInterval;
	}    	
	
	function setPriceCoeff(uint _new_k) onlyOwner public returns(uint _k) {
		require(_new_k>0);
		k=_new_k;
		return k;
	}  

	
	function rejectMessage(uint _message_id, string _reason) onlyOwner public returns(uint _amount) {
		require(_message_id>0);
		require(bytes(messageInfo[_message_id].content).length > 0);
		require(messageInfo[_message_id].rejected==0);
    	if (messageInfo[_message_id].show_date>=(now-showInterval) && messageInfo[_message_id].show_date<=now) throw;
		messageInfo[_message_id].rejected=1;
		messageInfo[_message_id].rejected_reason=_reason;
		if (messageInfo[_message_id].sender!= 0x0 && messageInfo[_message_id].price>0) {
		    sendMoney(messageInfo[_message_id].sender,messageInfo[_message_id].price);
		    return messageInfo[_message_id].price;
		} else throw;
	}  		
    
}