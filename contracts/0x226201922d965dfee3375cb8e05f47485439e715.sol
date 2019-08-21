pragma solidity ^0.4.16;

/**
 * @title Contrato padrão para definição do proprietário do contrato detentor do token
 * @author Alaor Jr.
 */
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

/**
 * @title Contrato para criação do token utilizado no projeto "MaisPetro"
 * @author Alaor Jr.
 */
contract Igni is owned {
    /// Informações do token
    string public name;
    string public symbol;
    uint8 public decimals = 1;
    uint256 public totalSupply;

    /// Array associativo de saldos das carteiras
    mapping (address => uint256) public balanceOf;

    /// Evento que notifica a aplicação cliente Etherum da transferência de tokens
    event Transfer(address indexed from, address indexed to, uint256 value);

    /// Evento que notifica a aplicação cliente Etherum da aprovação de saldo de um proprietário para um "gastador"
    event Approval(address indexed holder, address indexed spender, uint256 value);

    /// Evento que notifica a aplicação cliente Etherum da "queima" de tokens
    event Burn(address indexed from, uint256 value);

    /**
     * @notice Inicializa o contrato com as informações do token passadas por parâmetro
     * @dev É executado uma única vez no momento do deploy na Ethereum Virtual Machine (EVM)
     */
    constructor(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);
        balanceOf[msg.sender] = totalSupply;
        name = tokenName;
        symbol = tokenSymbol;
    }

    /**
     * @notice Transfere tokens de uma carteira para outra
     * @dev Função interna que pode apenas ser chamada pelo contrato
     */
    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);                                            // Previne de enviar tokens para o endereço 0x0
        require(balanceOf[_from] >= _value);                            // Verifica se o saldo na carteira de origem é suficiente
        require(balanceOf[_to] + _value > balanceOf[_to]);              // Previne overflow na carteira de destino
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        balanceOf[_from] -= _value;
        balanceOf[_to] += _value;
        emit Transfer(_from, _to, _value);
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);  // Verificação adicional para um caso de overflow não detectado
    }

    /**
     * @notice Transfere tokens para uma carteira
     *
     * @param _to    Endereço da carteira que receberá os tokens
     * @param _value Quantidade de tokens a ser enviado
     *
     * @return bool
     */
    function transfer(address _to, uint256 _value) public returns (bool success) {
        _transfer(msg.sender, _to, _value);
        return true;
    }

    /**
     * @notice Transfere tokens de para uma carteira em nome de outra carteira
     *
     * @param _from  Endereço da carteira que enviará os tokens
     * @param _to    Endereço da carteira que receberá os tokens
     * @param _value Quantidade de tokens a ser enviado
     * @param _value Quantidade de tokens que serão debitados do valor a receber por "_to", como forma de taxa da transação
     *
     * @return bool
     */
    function transferFrom(address _from, address _to, uint256 _value, uint256 _fee) onlyOwner public returns (bool success) {
        _transfer(_from, owner, _fee);
        _transfer(_from, _to, _value - _fee);
        return true;
    }
}