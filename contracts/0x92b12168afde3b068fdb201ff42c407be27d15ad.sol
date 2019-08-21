pragma solidity ^0.4.25;

contract Gravestone {
	/* name of the departed person */
	string public fullname;
	/* birth date of the person */
	string public birth_date;
	/* death date of the person */
	string public death_date;
	
	/* the message engraved on the gravestone */
	string public epitaph;
	
    /* worships to the departed */
    Worship[] public worships;
	uint public worship_count;
	
	/* This runs when the contract is executed */
	constructor(string _fullname,string _birth_date,string _death_date,string _epitaph) public {
		fullname = _fullname;
		birth_date = _birth_date;
		death_date = _death_date;
		epitaph = _epitaph;
	}

    /* worship the departed */
    function do_worship(string _fullname,string _message) public returns (string) {
		uint id = worships.length++;
		worship_count = worships.length;
		worships[id] = Worship({fullname: _fullname, message: _message});
        return "Thank you";
    }
	
	struct Worship {
		/* full name of the worship person */
		string fullname;
		/* message to the departed */
		string message;
	}
}

contract JinYongGravestone is Gravestone {
	constructor() Gravestone("金庸","1924年3月10日","2018年10月30日","这里躺着一个人，在二十世纪、二十一世纪，他写过几十部武侠小说，这些小说为几亿人喜欢。") public {}
}