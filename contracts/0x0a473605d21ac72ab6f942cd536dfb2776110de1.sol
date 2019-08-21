contract Americo {
  /* Variables públicas del token */
    string public standard = 'Token 0.1';
    string public name;
    string public symbol;
    uint8 public decimals;
    uint256 public initialSupply;
    uint256 public totalSupply;

    /* Esto crea una matriz con todos los saldos */
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

  
    /* Inicializa el contrato con los tokens de suministro inicial al creador del contrato */
    function Americo() {

         initialSupply=160000000000000;
         name="Americo";
        decimals=6;
         symbol="AME";
        
        balanceOf[msg.sender] = initialSupply;              // Americo recibe todas las fichas iniciales
        totalSupply = initialSupply;                        // Actualizar la oferta total
                                   
    }

    /* Send coins */
    function transfer(address _to, uint256 _value) {
        if (balanceOf[msg.sender] < _value) throw;           // Compruebe si el remitente tiene suficiente
        if (balanceOf[_to] + _value < balanceOf[_to]) throw; // Verificar desbordamientos
        balanceOf[msg.sender] -= _value;                     // Reste del remitente
        balanceOf[_to] += _value;                            // Agregue lo mismo al destinatario
      
    }

    /* Esta función sin nombre se llama cada vez que alguien intenta enviar éter a ella */
    function () {
        throw;     // Evita el envío accidental de éter
    }
}