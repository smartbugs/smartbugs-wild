contract BlocksureInfo {

    address public owner;
    string public name;
    
    mapping (string => string) strings;

    function BlocksureInfo() {
        owner = tx.origin;
    }
    
    modifier onlyowner { if (tx.origin == owner) _ }

    function addString(string _key, string _value) onlyowner {
        strings[_key] = _value;
    }
    
    function setOwner(address _owner) onlyowner {
        owner = _owner;
    }
    
    function setName(string _name) onlyowner {
        name = _name;
    }
    
    function destroy() onlyowner {
        suicide(owner);
    }
}