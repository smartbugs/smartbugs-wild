pragma solidity ^0.4.18;

contract owned {
    address public owner;

    function owned() public {
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

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract FootCoin {
    // Variáveis públicas do token
    string public name;
    string public symbol;
    uint8 public decimals = 8;
    // 8 casas decimais
    uint256 public totalSupply;

    // Criação de uma matriz com todos os saldos
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // Geração de um evento público no blockchain que notificará os clientes
    event Transfer(address indexed from, address indexed to, uint256 value);

    // Notificação aos clientes sobre a quantidade queimada
    event Burn(address indexed from, uint256 value);

    /**
     * Função Constrctor
     *
     * Inicializa o contrato com número inicial dos tokens para o criador do contrato
     */
    function FootCoin(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Atualiza a oferta total com os valores decimais
        balanceOf[msg.sender] = totalSupply;                // Envia ao criador todos os tokens iniciais
        name = tokenName;                                   // Define o nome para fins de exibição
        symbol = tokenSymbol;                               //  Definir o símbolo para fins de exibição
    }

    /**
     * Transferência interna, só pode ser chamada por este contrato
     */
    function _transfer(address _from, address _to, uint _value) internal {
        // Impede a transferência para o endereço 0x0
        require(_to != 0x0);
        // Verifica o saldo do remetente
        require(balanceOf[_from] >= _value);
        // Verifica overflows
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Guarda para conferência futura
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtrai do remetente
        balanceOf[_from] -= _value;
        // Adiciona o mesmo valor ao destinatário
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
        // Verificação usada para usar a análise estática do contrato, elas nunca devem falhar
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    /**
     * Transferência dos tokens
     *
     * Envio `_value` tokens para `_to` da sua conta
     *
     * @param _to O endereço do destinatário
     * @param _value O valor a enviar
     */
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }
    /**
     * Destruição dos Tokens
     *
     * Remove `_value` tokens do sistema irreversivelmente
     *
     * @param _value O valor a ser queimado
     */
    function burn(uint256 _value) public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Verifique se tem o suficiente
        balanceOf[msg.sender] -= _value;            // Subtrair do remetente
        totalSupply -= _value;                      // Atualiza o totalSupply
        Burn(msg.sender, _value);
        return true;
    }
}