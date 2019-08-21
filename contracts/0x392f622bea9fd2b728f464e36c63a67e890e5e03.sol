pragma solidity ^0.4.0;
contract ProvaSegura {

    struct Prova {
        bool existe;
        uint block_number;
        string numero;
        string data_hora;
        string coordenadas;
    }

    mapping(bytes32 => Prova) public provas;
    address public admin;

    function ProvaSegura() public {
        admin = msg.sender;
    }
    
    function TrocarAdmin(address _admin) public {
        require(msg.sender == admin);
        admin = _admin;
    }

    function GuardaProva(string _hash, string _numero, string _data_hora, string _coordenadas) public {
        require(msg.sender == admin);
        bytes32 hash = sha256(_hash);
        require(!provas[hash].existe);
        provas[hash].existe = true;
        provas[hash].block_number = block.number;
        provas[hash].numero = _numero;
        provas[hash].data_hora = _data_hora;
        provas[hash].coordenadas = _coordenadas;
    }

    function ConsultaProva(string _hash) public constant returns (uint, string, string, string) {
        bytes32 hash = sha256(_hash);
        require(provas[hash].existe);
        return (provas[hash].block_number, provas[hash].numero, provas[hash].data_hora, provas[hash].coordenadas);
    }
}