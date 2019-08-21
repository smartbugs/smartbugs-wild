pragma solidity ^0.4.6;

contract MetaPoc {
    /* VARIABLES */
    address public _owner;
    address public _filiate;

    struct Execution {
        uint dateCreated;
        string hash;
        bool validated;
        uint dateValidated;
    }
    
    mapping (string => uint) private mapExecs;
    Execution[] private executions;
    
    /* PRIVATE CONST */
    uint private nb_total = 0;
    uint private nb_notVal = 0;
    uint private nb_val = 0;
    
    string private last_exec = "none";
    uint private last_execDateCreated = 0;
    
    string private notVal_list = "none";
    uint private notVal_since = 0;
    string private notVal_last = "none";
    uint private notVal_lastDateCreated = 0;
    
    string private val_list = "none";
    uint private val_since = 0;
    string private val_last = "none";
    uint private val_lastDateCreated = 0;
    uint private val_lastDateValidated = 0;
    
    /* EVENTS */
    event Executed(string Hash, uint Created);
    event Validated(string Hash, uint Validated);
    event Checked(string Hash, bool IsExit, uint Created, bool IsValidated, uint Validated);
    event Listed_Validated(uint Since, string List);
    event Listed_NotValidated(uint Since, string List);
    event Owner_Changed(address Owner);
    event Filiate_Changed(address Filiate);
    
    
    /* CONSTRUCTOR */
    function MetaPoc(address filiate) {
        _owner = msg.sender;
        _filiate = filiate;
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
    
    /* INIT */
    function ChangeOwner(address owner) ownerAllowed() {
        if(owner.balance <= 0) throw;
        
        _owner = owner;
        Owner_Changed(_owner);
    }
    
    function ChangeFiliate(address filiate) bothAllowed() {
        if(filiate.balance <= 0) throw;
        
        _filiate = filiate;
        Filiate_Changed(_filiate);
    }
    
    function kill() ownerAllowed() {
        suicide(_owner);
    }
    
    /* PUBLIC FUNCTIONS */
    function AddExec(string Hash) public ownerAllowed() notYetExist(Hash) {
        uint num = executions.length++;
        mapExecs[Hash] = num;
        Execution e = executions[num];
        e.dateCreated = now;
        e.hash = Hash;
        executions[num] = e;
        
        /* màj public const */
        nb_total++;
        nb_notVal++;
        notVal_last = e.hash;
        notVal_lastDateCreated = e.dateCreated;
        MajListAll();
        
        Executed(e.hash, e.dateCreated);
    }
    
    function ValidateExec(string Hash) public filiateAllowed() notYetValidated(Hash) {
        Execution e = executions[map(Hash)];
        e.validated = true;
        e.dateValidated = now;
        executions[map(Hash)] = e;
        
        /* màj public const */
        nb_val++;
        nb_notVal--;
        val_last = e.hash;
        val_lastDateCreated = e.dateCreated;
        val_lastDateValidated = e.dateValidated;
        MajListAll();
        MajLastNotVal();
        
        Validated(e.hash, e.dateValidated);
    }
    
    function CheckExec(string Hash) public bothAllowed() {
        uint ret = mapExecs[Hash];
        if(ret >= executions.length || !strEqual(executions[ret].hash, Hash)) {
            Checked(Hash, false, 0, false, 0);
        } else {
            Execution e = executions[ret];
            Checked(e.hash, true, e.dateCreated, e.validated, e.dateValidated);
        }
    }
    
    function ListAllSince(uint timestampFrom) public bothAllowed() {
        val_since = timestampFrom;
        notVal_since = timestampFrom;
        MajListAll();
        Listed_Validated(val_since, val_list);
        Listed_NotValidated(notVal_since, notVal_list);
    }
    
    function ListNotValSince(uint timestampFrom) public bothAllowed() {
        notVal_since = timestampFrom;
        MajListNotVal();
        Listed_NotValidated(notVal_since, notVal_list);
    }
    
    function ListValSince(uint timestampFrom) public bothAllowed() {
        val_since = timestampFrom;
        MajListVal();
        Listed_Validated(val_since, val_list);
    }
    
    
    /* CONSTANTS */
    function CountExecs() public constant returns(uint Total, uint NbValidated, uint NbNotVal) {
        return (nb_total, nb_val, nb_notVal);
    }
    
    function LastExec() public constant returns(string Hash, uint Created) {
        return (notVal_last, notVal_lastDateCreated);
    }
    
    function LastValidated() public constant returns(string Hash, uint Created, uint Validated) {
        return (val_last, val_lastDateCreated, val_lastDateValidated);
    }
    
    function ListNotValidated() public constant returns(uint Since, string List) {
        return (notVal_since, notVal_list);
    }

    function ListValidated() public constant returns(uint Since, string List) {
        return (val_since, val_list);
    }
    
    /* PRIVATE FUNCTIONS */
    function MajListAll() private {
        MajListVal();
        MajListNotVal();
    }
    
    function MajListVal() private {
        val_list = "none";
        for(uint i = 0; i < executions.length; i++) {
            if(executions[i].dateCreated >= val_since && executions[i].validated) {
                if(strEqual(val_list, "none")) val_list = executions[i].hash;
                else val_list = strConcat(val_list, " ; ", executions[i].hash);
            }
        }
    }
    
    function MajListNotVal() private {
        notVal_list = "none";
        for(uint i = 0; i < executions.length; i++) {
            if(executions[i].dateCreated >= notVal_since && !executions[i].validated) {
                if(strEqual(notVal_list, "none")) notVal_list = executions[i].hash;
                else notVal_list = strConcat(notVal_list, " ; ", executions[i].hash);
            }
        }
    }
    
    function MajLastNotVal() private {
        notVal_lastDateCreated = 0;
        notVal_last = "none";
        if(executions.length > 0) {
            if(!executions[0].validated) {
                notVal_last = executions[0].hash;
                notVal_lastDateCreated = executions[0].dateCreated;
            }
            for(uint i = executions.length - 1; i > 0; i--) {
                if(!executions[i].validated && executions[i].dateCreated > notVal_lastDateCreated) {
                    notVal_last = executions[i].hash;
                    notVal_lastDateCreated = executions[i].dateCreated;
                    break;
                }
            }
        }
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