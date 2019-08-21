pragma solidity ^0.4.24;

contract FamilienSpardose {
    
    // Created by N. Fuchs
    
    // Name der Familienspardose
    string public spardosenName;
    
    //weist einer Addresse ein Guthaben zu
    mapping (address => uint) public guthaben;
    
    // zeigt im smart contract an, wieviel Ether alle Sparer insgesamt halten
    // ".balance" ist eine Objektattribut des Datentyps address, das für jede wallet und jeden smart contract das entsprechende 
    //  Ether-Guthaben darstellt.
    uint public gesamtGuthaben = address(this).balance;
    
    // Konstruktorfunktion: Wird einmalig beim deployment des smart contracts ausgeführt
    // Wenn Transaktionen, die Funktionen auszuführen beabsichtigen, Ether mitgesendet wird (TXvalue > 0), so muss die
    //  ausgeführte Transaktion mit "payable" gekennzeichnet sein. Sicherheitsfeature im Interesse der Nutzer
    constructor(string _name, address _sparer) payable {
        
        
        // Weist der Variablen spardosenName den String _name zu, welcher vom Ersteller
        // des smart contracts als Parameter in der Transaktion übergeben wird:
        spardosenName = _name;
        
        
        // Erstellt einen unsignierten integer, der mit der Menge Ether definiert wird, die der 
        // Transaktion mitgeliefert wird:
        uint startGuthaben = msg.value;
        
        // Wenn der ersteller des smart contracts in der transaktion einen Begünstigten angegeben hat, soll ihm 
        // der zuvor als Startguthaben definierte Wert als Guthaben gutgeschrieben werden.
        // Das mitgesendete Ether wird dabei dem smart contract gutgeschrieben, er war der Empfänger der Transaktion.
        if (_sparer != 0x0) guthaben[_sparer] = startGuthaben;
        else guthaben[msg.sender] = startGuthaben;
    }
    
    
    // Schreibt dem Absender der Transaktion (TXfrom) ihren Wert (TXvalue) als Guthaben zu
    function einzahlen() public payable{
        guthaben[msg.sender] = msg.value;
    }
    
    // Ermöglicht jemandem, so viel Ether aus dem smart contract abzubuchen, wie ihm an Guthaben zur Verfügung steht
    function abbuchen(uint _betrag) public {
        
        // Zunächst prüfen, ob dieser jemand über ausreichend Guthaben verfügt.
        // Wird diese Bedingung nicht erfüllt, wird die Ausführung der Funktion abgebrochen.
        require(guthaben[msg.sender] >= _betrag);
        
        // Subtrahieren des abzuhebenden Guthabens 
        guthaben [msg.sender] = guthaben [msg.sender] - _betrag;
        
        // Überweisung des Ethers
        // ".transfer" ist eine Objektmethode des Datentyps address, die an die gegebene Addresse 
        // die gewünschte Menge Ether zu transferieren versucht. Schlägt dies fehl, wird die
        // Ausführung der Funktion abgebrochen und bisherige Änderungen rückgängig gemacht.
        msg.sender.transfer(_betrag);
    }
    
    // Getter-Funktion; Gibt das Guthaben einer Addresse zurück.
    // Dient der Veranschaulichung von Funktionen, die den state nicht verändern.
    // Nicht explizit notwendig, da jede als public Variable, so auch das mapping guthaben,
    // vom compiler eine automatische, gleichnamige Getter-Funktion erhalten, wenn sie als public
    // deklariert sind.
    function guthabenAnzeigen(address _sparer) view returns (uint) {
        return guthaben[_sparer];
    }
    
    // Eine weitere Veranschaulichung eines Funktionstyps, der den state nicht ändert. 
    // Weil mit pure gekennzeichnete Funktionen auf den state sogar garnicht nicht zugreifen können,
    // werden entsprechende opcodes nicht benötigt und der smart contract kostet weniger Guthabens
    // beim deployment benötigt. 
    function addieren(uint _menge1, uint _menge2) pure returns (uint) {
        return _menge1 + _menge2;
    }
}