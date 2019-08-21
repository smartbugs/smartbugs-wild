pragma solidity ^0.4.4;

contract Token {

    /// @return cantidad total de tokens
    function totalSupply() constant returns (uint256 supply) {}

    /// @param _owner La dirección desde la cual se recuperara el saldo
    /// @return El balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}

    /// @notice envia `_value` del token a `_to` de `msg.sender`
    /// @param _to La direccion del destinatario
    /// @param _value La cantidad de token que se transferira
    /// @return Si la transferencia fue exitosa o no
    function transfer(address _to, uint256 _value) returns (bool success) {}

    /// @notice envia `_value` del token a `_to` de `_from` con la condicion de que sea aprobado por `_from`
    /// @param _from La direccion del remitente
    /// @param _to La direccion del destinatario
    /// @param _value La cantidad de token que se transferira
    /// @return Si la transferencia fue exitosa o no
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}

    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender La direccion de la cuenta capaz de transferir los tokens
    /// @param _value La cantidad de wei que se aprobará para la transferencia
    /// @return Si la transferencia fue exitosa o no
    function approve(address _spender, uint256 _value) returns (bool success) {}

    /// @param _owner La direccion de la cuenta que posee los tokens
    /// @param _spender La direccion de la cuenta capaz de transferir los tokens
    /// @return Cantidad de tokens restantes permitidos gastar
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
    
}



contract StandardToken is Token {

    function transfer(address _to, uint256 _value) returns (bool success) {
        //El valor predeterminado asume que TotalSupply no puede exceder el máximo (2 ^ 256 - 1).
        //Si tu token omite la oferta total y puede emitir más tokens a medida que pasa el tiempo, debes comprobar si no se ajusta.
        //Reemplace el si con este en su lugar.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }

    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //lo mismo que arriba. Reemplace esta línea con lo siguiente si desea protegerse contra envoltorios uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }

    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }

    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }

    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}


//nombre de este contrato
contract TecnonucleousCoin is StandardToken {

    function () {
        //if ether is sent to this address, send it back.
        throw;
    }

    /* Variables publicas del token */

    /*
    NOTA:
     Las siguientes variables son vanidades OPCIONALES. Uno no tiene que incluirlos.
     Permiten personalizar el contrato de token y de ninguna manera influye en la funcionalidad principal.
     Algunas billeteras / interfaces pueden no molestarse en mirar esta información.
    */
    string public name;                   //nombre elegante: por ejemplo, TecnonucleousCoin
    uint8 public decimals;                //Cuantos decimales mostrar es decir. Podría haber 1000 unidades base con 3 decimales. Significado 0.980 TEC = 980 unidades base Es como comparar 1 wei con 1 éter.
    string public symbol;                 //Un identificador: por ejemplo, TEC
    string public version = 'H1.0';       //humano 0.1 estándar. Solo un esquema de control de versiones arbitrario.

//
// CAMBIE ESTOS VALORES PARA SU TOKEN
//

//Asegurese de que el nombre de esta funcion coincida con el nombre del contrato anterior. Entonces, si su token se llama TecnonucleousCoin, asegurese de que // el nombre del contrato anterior tambien sea TecnonucleousCoin en lugar de ERC20Token

    function TecnonucleousCoin(
        ) {
        balances[msg.sender] = 100000000000000000000000000;               // Dale al creador todos los tokens iniciales (100000, por ejemplo)
        totalSupply = 100000000000000000000000000;                        // Actualizar el suministro total (100000, por ejemplo)
        name = "Tecnonucleous Coin";                                   // Establecer el nombre para fines de visualización
        decimals = 18;                            // Cantidad de decimales para fines de visualización
        symbol = "TEC";                               // Establecer el simbolo para fines de visualizacion
    }

    /* Aprueba y luego llama al contrato de recepcion */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //llame a la funcion receiveApproval en el contrato que desea que se le notifique. Esto crea la firma de la funcion manualmente, por lo que no es necesario incluir un contrato aqui solo para esto.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //se supone que cuando hace esto la llamada * deberia * tener exito, de lo contrario uno usaria vainilla aprobar en su lugar.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}