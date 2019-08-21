contract Mapoc {
    address _owner;
    address _filiate;

    mapping (string => uint) private mapExecs;
    Execution[] private executions;
    event Executed(string Hash);
    event Validated(string Hash);
    
    struct Execution {
        uint dateCreated;
        string hash;
        bool validated;
        uint dateValidated;
    }
    
    
    /* CONSTRUCTOR */
    function Mapoc(/*address filiate*/) {
        _owner = msg.sender;
        _filiate = msg.sender;
    }
    
    function kill() ownerAllowed() {
        suicide(_owner);
    }
    
    /* MAPPING */
    function map(string hash) internal returns(uint) {
        uint ret = mapExecs[hash];
        if(ret >= executions.length || !strEqual(executions[ret].hash, hash)) throw;
        return ret;
    }
    
    /* MODIFIERS */
    modifier bothAllowed() {
        if(msg.sender != _owner && msg.sender != _filiate) throw;
        _;
    }
    
    modifier ownerAllowed() {
        if(msg.sender != _owner) throw;
        _;
    }
    
    modifier filiateAllowed() {
        if(msg.sender != _filiate) throw;
        _;
    }
    
    modifier notYetExist(string hash) {
        uint num = mapExecs[hash];
        if(num < executions.length && strEqual(executions[num].hash, hash)) throw;
        _;
    }
    
    modifier notYetValidated(string hash) {
        Execution e = executions[map(hash)];
        if(e.validated) throw;
        _;
    }
    
    modifier orderExist(string hash) {
        Execution e = executions[map(hash)];
        if(!strEqual(e.hash, hash)) throw;
        _;
    }
    
    /* FONCTIONS */
    function AddExec(string Hash) public ownerAllowed() notYetExist(Hash) {
        uint num = executions.length++;
        mapExecs[Hash] = num;
        Execution e = executions[num];
        e.dateCreated = now;
        e.hash = Hash;
        Executed(Hash);
    }
    
    function ValidateExec(string Hash) public filiateAllowed() notYetValidated(Hash) {
        Execution e = executions[map(Hash)];
        e.validated = true;
        e.dateValidated = now;
        Validated(Hash);
    }
    
    function CheckExecution(string Hash) public bothAllowed() constant returns(bool IsExist, uint DateCreated, bool Validated, uint DateValidated){
        uint ret = mapExecs[Hash];
        if(ret >= executions.length || !strEqual(executions[ret].hash, Hash)) return (false, 0, false, 0);
        Execution e = executions[ret];
        return (true, e.dateCreated, e.validated, e.dateValidated);
    }
    
    function IsValidated(string Hash) public bothAllowed() constant returns(bool) {
        Execution e = executions[map(Hash)];
        return e.validated;
    }
    
    function LastExecuted() public bothAllowed() constant returns(string Hash, uint DateCreated) {
        DateCreated = 0;
        if(executions.length > 0) {
            if(!executions[0].validated) {
                Hash = executions[0].hash;
                DateCreated = executions[0].dateCreated;
            }
            for(uint i = executions.length - 1; i > 0; i--) {
                if(!executions[i].validated && executions[i].dateCreated > DateCreated) {
                    Hash = executions[i].hash;
                    DateCreated = executions[i].dateCreated;
                    break;
                }
            }
        }
        return (Hash, DateCreated);
    }
    
    function LastValidated() public bothAllowed() constant returns(string Hash, uint DateValidated) {
        DateValidated = 0;
        for(uint i = 0; i < executions.length; i++) {
            if(executions[i].validated && executions[i].dateValidated > DateValidated) {
                Hash = executions[i].hash;
                DateValidated = executions[i].dateValidated;
            }
        }
        return (Hash, DateValidated);
    }
    
    function CountExecs() public bothAllowed() constant returns(uint Total, uint NotVal) {
        uint nbNotVal = 0;
        for(uint i = 0; i < executions.length; i++) {
            if(!executions[i].validated) nbNotVal++;
        }
        return (executions.length, nbNotVal);
    }
    
    function NotValSince(uint timestampFrom) public bothAllowed() constant returns(uint Count, string First, uint DateFirst, string Last, uint DateLast) {
        Count = 0;
        DateFirst = now;
        DateLast = 0;
        for(uint i = 0; i < executions.length; i++) {
            if(!executions[i].validated && executions[i].dateCreated >= timestampFrom) {
                Count++;
                if(executions[i].dateCreated < DateFirst) {
                    First = executions[i].hash;
                    DateFirst = executions[i].dateCreated;
                }
                else if(executions[i].dateCreated > DateLast) {
                    Last = executions[i].hash;
                    DateLast = executions[i].dateCreated;
                }
            }
        }
        return (Count, First, DateFirst, Last, DateLast);
    }
    
    function ListNotValSince(uint timestampFrom) public bothAllowed() constant returns(uint Count, string List, uint OldestTime) {
        Count = 0;
        List = "\n";
        OldestTime = now;
        for(uint i = 0; i < executions.length; i++) {
            if(!executions[i].validated && executions[i].dateCreated >= timestampFrom) {
                Count++;
                List = strConcat(List, executions[i].hash, " ;\n");
                if(executions[i].dateCreated < OldestTime)
                    OldestTime = executions[i].dateCreated;
            }
        }
        return (Count, List, OldestTime);
    }
    
    function ListAllSince(uint timestampFrom) public bothAllowed() constant returns(uint Count, string List) {
        List = "\n";
        for(uint i = 0; i < executions.length; i++) {
            string memory val;
            if(executions[i].validated)
                val = "confirmed\n";
            else
                val = "published\n";
                
            List = strConcat(List, executions[i].hash, " : ", val);
        }
        return (executions.length, List);
    }
    
    /* UTILS */
    function strEqual(string _a, string _b) internal returns(bool) {
		bytes memory a = bytes(_a);
		bytes memory b = bytes(_b);
		if (a.length != b.length)
			return false;

		for (uint i = 0; i < a.length; i ++)
			if (a[i] != b[i])
				return false;
		return true;
	}
	
	function strConcat(string _a, string _b, string _c, string _d, string _e) internal returns(string) {
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
    
    function strConcat(string _a, string _b, string _c, string _d) internal returns(string) {
        return strConcat(_a, _b, _c, _d, "");
    }
    
    function strConcat(string _a, string _b, string _c) internal returns(string) {
        return strConcat(_a, _b, _c, "", "");
    }
    
    function strConcat(string _a, string _b) internal returns(string) {
        return strConcat(_a, _b, "", "", "");
    }
    
}