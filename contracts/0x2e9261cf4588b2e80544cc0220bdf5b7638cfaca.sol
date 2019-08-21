pragma solidity ^0.4.24;
contract owned {
    address public owner;
constructor() public {
        owner = msg.sender;
    }
modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }
function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) external; }
contract TokenERC20 {
    // Variables públicos del token (hey, por ahora)
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;
    // esto crea un array con todos los balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;
    // estas dos lineas generan un evento público que notificará a todos los clientes
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    // quemamos?
    event Burn(address indexed from, uint256 value);
     /**
     * 
     * Funcion constructor
     *
     **/
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  //le da los 18 decimales
        balanceOf[msg.sender] = totalSupply;                    // le da al creador toodo los tokens iniciales
        name = tokenName;                                       // nombre del token
        symbol = tokenSymbol;                                   // simbolo del token
    }

     /**
     * transferencia interna, solo puede ser llamado desde este contrato
     **/
    function _transfer(address _from, address _to, uint _value) internal {
        // previene la transferencia al address 0x0, las quema
        require(_to != 0x0);
        // chequear si el usuario tiene suficientes monedas
        require(balanceOf[_from] >= _value);
        // Chequear  por overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Restarle al vendedor
        balanceOf[_from] -= _value;
        // Agregarle al comprador
        balanceOf[_to] += _value;
	// se genera la transferencia
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }
/**
     * Transferir monedas
     *
     * mandar `_value` tokens to `_to` desde tu cuenta
     *
     * @param _to el address del comprador
     * @param _value la cantidad a vender
**/
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }
/**
     * transferir cuentas desde otro adress
     *
     * mandar `_value` tokens a `_to` desde el address `_from`
     *
     * @param _from el address del vendedor
     * @param _to el address del comprador
     * @param _value la cantidad a vender
     */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }
/**
     * permitir para otros address
     *
     * permite al `_spender` a vender no mas `_value` tokens de los que tiene
     *
     * @param _spender el address autorizado a vender
     * @param _value la cantidad máxima autorizada a vender
**/
    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }
/**
     * permitir a otros otros address y notificar
     *
     * permite al `_spender` a vender no mas `_value` tokens de los que tiene, y después genera un ping al contrato
     *
     * @param _spender el address autorizado a vender
     * @param _value la cantidad máxima que puede vender
     * @param _extraData algo de informacio extra para mandar el contrato aprobado
**/
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }
/**
     * Destruir tokens
     *
     * destruye `_value` tokens del sistema irreversiblemente
     *
     * @param _value la cantidad de monedas a quemar
 **/
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }
/**
     * destruye tokens de otra cuenta
     *
     * destruye `_value` tokens del sistema irreversiblemente desde la cuenta `_from`.
     *
     * @param _from el address del usuario 
     * @param _value la cantidad de monedas a quemar
**/
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balanceOf[_from] >= _value);                // checkea si la cantidad a quemar es menor al address
        require(_value <= allowance[_from][msg.sender]);    // checkea permisos
        balanceOf[_from] -= _value;                         // resta del balarce
        allowance[_from][msg.sender] -= _value;             // sustrae del que permite la quema
        totalSupply -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
}

contract YamanaNetwork is owned, TokenERC20 {
uint256 public sellPrice;
    uint256 public buyPrice;
mapping (address => bool) public frozenAccount;
/* Esto generea un evento publico en la blockchain que notifica clientes*/
    event FrozenFunds(address target, bool frozen);
/* inicia el contrato en el address del creador del contrato */
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}
/* solo puede ser llamado desde este contrato */
    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);                               
        require (balanceOf[_from] >= _value);               
        require (balanceOf[_to] + _value >= balanceOf[_to]); 
        require(!frozenAccount[_from]);                     
        require(!frozenAccount[_to]);                      
        balanceOf[_from] -= _value;                        
        balanceOf[_to] += _value;                          
        emit Transfer(_from, _to, _value);
    }

    /// @notice Create `mintedAmount` tokens and send it to `target`
    /// @param target Address to receive the tokens
    /// @param mintedAmount the amount of tokens it will receive
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        emit Transfer(0, this, mintedAmount);
        emit Transfer(this, target, mintedAmount);
    }
/// @notice `freeze? Prevent | Allow` `target` from sending & receiving tokens
    /// @param target Address to be frozen
    /// @param freeze either to freeze it or not
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        emit FrozenFunds(target, freeze);
    }
/// @notice Allow users to buy tokens for `newBuyPrice` eth and sell tokens for `newSellPrice` eth
    /// @param newSellPrice Price the users can sell to the contract
    /// @param newBuyPrice Price users can buy from the contract
    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }
/// @notice Buy tokens from contract by sending ether
    function buy() payable public {
        uint amount = msg.value / buyPrice;               // calculates the amount
        _transfer(this, msg.sender, amount);              // makes the transfers
    }
/// @notice Sell `amount` tokens to contract
    /// @param amount amount of tokens to be sold
    function sell(uint256 amount) public {
        address myAddress = this;
        require(myAddress.balance >= amount * sellPrice);      // checks if the contract has enough ether to buy
        _transfer(msg.sender, this, amount);              // makes the transfers
        msg.sender.transfer(amount * sellPrice);          // sends ether to the seller. It's important to do this last to avoid recursion attacks
    }
}