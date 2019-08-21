contract SimpleStorage {
    event valueChanged(string oldValue, string newValue);

    string _value;

    function setValue(string value) {
        valueChanged(_value, value);
        _value = value;
    }

    function getValue() constant returns (string) {
        return _value;
    }
}