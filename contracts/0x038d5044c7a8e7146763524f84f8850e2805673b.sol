pragma solidity ^0.4.24;


/**
 * @title Ownable
 * @dev El contrato de propiedad tiene una dirección de propietario y proporciona un control de autorización básico
 * funciones, esto simplifica la implementación de "permisos de usuario".
 */
contract Ownable {
    address public owner;

    event OwnershipRenounced(address indexed previousOwner);
    event OwnershipTransferred(
        address indexed previousOwner,
        address indexed newOwner
    );

/**
    * @dev El constructor Ownable establece el "propietario" original del contrato al remitente
    * cuenta.
    */
    constructor() public {
        owner = msg.sender;
    }

    /**
    * @dev Lanza si es llamado por cualquier cuenta que no sea el propietario.
    */
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }
/**
    * @dev Permite al propietario actual transferir el control del contrato a un nuevo propietario.
    * @param newOwner La dirección a la que se transfiere la propiedad.
    */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0));
        emit OwnershipTransferred(owner, newOwner);
        owner = newOwner;
    }

    /**
    * @dev Permite al propietario actual ceder el control del contrato.
    */
    function renounceOwnership() public onlyOwner {
        emit OwnershipRenounced(owner);
        owner = address(0);
    }
}

/**
 * @title SafeMath
 * @dev Operaciones matemáticas con controles de seguridad que arrojan por error.
 */
library SafeMath {

    /**
    * @dev Multiplica dos números, lanza en desbordamiento.
    */
    function mul(uint256 a, uint256 b) internal pure returns (uint256 c) {
        if (a == 0) {
            return 0;
        }
        c = a * b;
        assert(c / a == b);
        return c;
    }

    /**
    * @dev División entera de dos números, truncando el cociente.
    */
    function div(uint256 a, uint256 b) internal pure returns (uint256) {
        return a / b;
    }

    /**
    * @dev Resta dos números, arroja en desbordamiento (es decir, si el sustraendo es mayor que el minuendo).
    */
    function sub(uint256 a, uint256 b) internal pure returns (uint256) {
        assert(b <= a);
        return a - b;
    }

    /**
    * @dev Agrega dos números, arroja sobre desbordamiento.
    */
    function add(uint256 a, uint256 b) internal pure returns (uint256 c) {
        c = a + b;
        assert(c >= a);
        return c;
    }
}

/**
 * @title ERC20Basic
 * @dev Versión más sencilla de la interfaz ERC20
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
    function totalSupply() public view returns (uint256);
    function balanceOf(address who) public view returns (uint256);
    function transfer(address to, uint256 value) public returns (bool);
    event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
    function allowance(address owner, address spender) public view returns (uint256);
    function transferFrom(address from, address to, uint256 value) public returns (bool);
    function approve(address spender, uint256 value) public returns (bool);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}

contract BasicToken is ERC20Basic {
    using SafeMath for uint256;

    mapping(address => uint256) balances;

    uint256 totalSupply_;

    /**
    * @dev total number of tokens in existence
    */
    function totalSupply() public view returns (uint256) {
        return totalSupply_;
    }

    /**
    * @dev transfer token for a specified address
    * @param _to The address to transfer to.
    * @param _value The amount to be transferred.
    */
    function transfer(address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);

        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    /**
    * @dev Gets the balance of the specified address.
    * @param _owner The address to query the the balance of.
    * @return An uint256 representing the amount owned by the passed address.
    */
    function balanceOf(address _owner) public view returns (uint256) {
        return balances[_owner];
    }

}
/**
 * @title Standard ERC20 token
 *
 * @dev Implementación del token estándar básico.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

    mapping (address => mapping (address => uint256)) internal allowed;
// This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[_from]);
        require(_value <= allowed[_from][msg.sender]);

        balances[_from] = balances[_from].sub(_value);
        balances[_to] = balances[_to].add(_value);
        allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
        emit Transfer(_from, _to, _value);
        return true;
    }

    /**
    * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
    *
    * Beware that changing an allowance with this method brings the risk that someone may use both the old
    * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
    * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
    * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    * @param _spender The address which will spend the funds.
    * @param _value The amount of tokens to be spent.
    */
    function approve(address _spender, uint256 _value) public returns (bool) {
        allowed[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    /**
    * @dev Function to check the amount of tokens that an owner allowed to a spender.
    * @param _owner address The address which owns the funds.
    * @param _spender address The address which will spend the funds.
    * @return A uint256 specifying the amount of tokens still available for the spender.
    */
    function allowance(address _owner, address _spender) public view returns (uint256) {
        return allowed[_owner][_spender];
    }

    /**
    * @dev Increase the amount of tokens that an owner allowed to a spender.
    *
    * approve should be called when allowed[_spender] == 0. To increment
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _addedValue The amount of tokens to increase the allowance by.
    */
    function increaseApproval(address _spender, uint _addedValue) public returns (bool) {
        allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }

    /**
    * @dev Decrease the amount of tokens that an owner allowed to a spender.
    *
    * approve should be called when allowed[_spender] == 0. To decrement
    * allowed value is better to use this function to avoid 2 calls (and wait until
    * the first transaction is mined)
    * From MonolithDAO Token.sol
    * @param _spender The address which will spend the funds.
    * @param _subtractedValue The amount of tokens to decrease the allowance by.
    */
    function decreaseApproval(address _spender, uint _subtractedValue) public returns (bool) {
        uint oldValue = allowed[msg.sender][_spender];
        if (_subtractedValue > oldValue) {
            allowed[msg.sender][_spender] = 0;
        } else {
            allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
        }
        emit Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
        return true;
    }
     /**
     * Destroy tokens
     *
     * Remove `_value` tokens from the system irreversibly
     *
     * @param _value the amount of money to burn
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balances[msg.sender] >= _value);   // Check if the sender has enough
        balances[msg.sender] -= _value;            // Subtract from the sender
        totalSupply_ -= _value;                      // Updates totalSupply
        emit Burn(msg.sender, _value);
        return true;
    }

    /**
     * Destroy tokens from other account
     *
     * Remove `_value` tokens from the system irreversibly on behalf of `_from`.
     *
     * @param _from the address of the sender
     * @param _value the amount of money to burn
     */
    function burnFrom(address _from, uint256 _value) public returns (bool success) {
        require(balances[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowed[_from][msg.sender]);    // Check allowance
        balances[_from] -= _value;                         // Subtract from the targeted balance
        allowed[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply_ -= _value;                              // Update totalSupply
        emit Burn(_from, _value);
        return true;
    }
}

contract MintableToken is StandardToken, Ownable {
    event Mint(address indexed to, uint256 amount);
    event MintFinished();

    bool public mintingFinished = false;


    modifier canMint() {
        require(!mintingFinished);
        _;
    }

    /**
    * @dev Funciónpara acuñar fichas
    * @param _to La dirección que recibirá las fichas acuñadas.
    * @param _amount La cantidad de fichas para acuñar.
    * @return Un valor booleano que indica si la operación se realizó correctamente.
    */
    function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
        totalSupply_ = totalSupply_.add(_amount);
        balances[_to] = balances[_to].add(_amount);
        emit Mint(_to, _amount);
        emit Transfer(address(0), _to, _amount);
        return true;
    }

    /**
    * @dev Función para dejar de acuñar nuevas fichas.
    * @return Es cierto si la operación fue exitosa.
    */
    function finishMinting() onlyOwner canMint public returns (bool) {
        mintingFinished = true;
        emit MintFinished();
        return true;
    }
}

contract Pausable is Ownable {
    event Pause();
    event Unpause();

    bool public paused = false;


    /**
    * @dev Modifier to make a function callable only when the contract is not paused.
    */
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

    /**
    * @dev Modifier to make a function callable only when the contract is paused.
    */
    modifier whenPaused() {
        require(paused);
        _;
    }

    /**
    * @dev called by the owner to pause, triggers stopped state
    */
    function pause() onlyOwner whenNotPaused public {
        paused = true;
        emit Pause();
    }

    /**
    * @dev called by the owner to unpause, returns to normal state
    */
    function unpause() onlyOwner whenPaused public {
        paused = false;
        emit Unpause();
    }
}

contract PausableToken is StandardToken, Pausable {

    function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transfer(_to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
        return super.transferFrom(_from, _to, _value);
    }

    function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
        return super.approve(_spender, _value);
    }

    function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
        return super.increaseApproval(_spender, _addedValue);
    }

    function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
        return super.decreaseApproval(_spender, _subtractedValue);
    }
}

contract Coinbase is Ownable {
    using SafeMath for uint256;
    uint256 public blockHeight;
    uint256 public decimals; 
    uint256 public coinbaseInit;

    // Generar nuevo bloque cada 6 horas. Reducir a la mitad la base de monedas cada 120 días.
    uint256 public halvingPeriod = 4 * 120;

    uint256 public maxSupply;
    uint256[6] private coinbaseArray;
    uint256 public exodus;

    event LogBlockHeight(uint256 blockHeight);

    constructor(uint256 _decimals) public{
        decimals = _decimals;
        maxSupply = 710000000 * (10 ** uint256(decimals));
        // 10% of maxSupply acuñar antes de bloque de genesis
        exodus = maxSupply / 10;

        // 90% de maxSupply para los próximos 2 años.
        coinbaseInit = 196875 * (10 ** uint256(decimals));
        coinbaseArray = [
            coinbaseInit,
            coinbaseInit / 2,
            coinbaseInit / 4,
            coinbaseInit / 8,
            coinbaseInit / 16,
            coinbaseInit / 16
        ];
       
    }
    
    /**
    * @dev Función para aumentar la altura del bloque.
    * @return 
    */
    function nextBlock() onlyOwner public {
        blockHeight = blockHeight.add(1);
        emit LogBlockHeight(blockHeight);
    }

    /**
    * @dev Función para calcular la cantidad de coinbase del bloque en este momento.
    * @return Un booleano que indica si la operación se realizó correctamente.
    */
    function coinbaseAmount() view internal returns (uint){
        uint256 index = blockHeight.sub(1).div(halvingPeriod);
        if (index > 5 || index < 0) {
            return 0;
        }
        return coinbaseArray[index];
    }

}

contract SlonpayToken is MintableToken, PausableToken, Coinbase {
    string public constant name = "Slonpay Token"; 
    string public constant symbol = "SLPT"; 
    uint256 public constant decimals = 18; 


    constructor() Coinbase(decimals) public{
        mint(owner, exodus);
    }

    /**
    * @dev Función para coinbase en nuevo bloque 
    * @return Un booleano que indica si la operación se realizó correctamente.
    */
    function coinbase() onlyOwner canMint whenNotPaused public returns (bool) {
        nextBlock();
        uint256 _amount =  coinbaseAmount();
        if (_amount == 0) {
            finishMinting();
            return false;
        }
        return super.mint(owner, _amount);
    }

    /**
    * @dev Función para dejar de acuñar nuevas fichas.
    * @return Es cierto si la operación fue exitosa.
    */
    function finishMinting() onlyOwner canMint whenNotPaused public returns (bool) {
        return super.finishMinting();
    }

    /**
    * @dev Permite al propietario actual transferir el control del contrato a un nuevo propietario.
    * @param newOwner La dirección para transferir la propiedad a.
    */
    function transferOwnership(address newOwner) onlyOwner whenNotPaused public {
        super.transferOwnership(newOwner);
    }

    /**
    * The fallback function.
    */
    function() payable public {
        revert();
    }
}