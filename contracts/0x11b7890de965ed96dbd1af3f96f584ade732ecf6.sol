pragma solidity ^0.4.15;

library SafeMath {
    function mul(uint a, uint b) internal returns (uint) {
        uint c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }
    function div(uint a, uint b) internal returns (uint) {
        assert(b > 0);
        uint c = a / b;
        assert(a == b * c + a % b);
        return c;
    }
    function sub(uint a, uint b) internal returns (uint) {
        assert(b <= a);
        return a - b;
     }
    function add(uint a, uint b) internal returns (uint) {
         uint c = a + b;
         assert(c >= a);
         return c;
     }
    function max64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a >= b ? a : b;
     }

    function min64(uint64 a, uint64 b) internal constant returns (uint64) {
        return a < b ? a : b;
    }

    function max256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a >= b ? a : b;
    }

    function min256(uint256 a, uint256 b) internal constant returns (uint256) {
        return a < b ? a : b;
    }
}

contract tokenLUCG {
    /* Public variables of the token */
        string public name;
        string public symbol;
        uint8 public decimals;
        uint256 public totalSupply = 0;


        function tokenLUCG (string _name, string _symbol, uint8 _decimals){
            name = _name;
            symbol = _symbol;
            decimals = _decimals;

        }
    /* This creates an array with all balances */
        mapping (address => uint256) public balanceOf;

}

contract Presale is tokenLUCG {

        using SafeMath for uint;
        string name = 'Level Up Coin Gold';
        string symbol = 'LUCG';
        uint8 decimals = 18;
        address manager;
        address public ico;

        function Presale (address _manager) tokenLUCG (name, symbol, decimals){
             manager = _manager;

        }

        event Transfer(address _from, address _to, uint256 amount);
        event Burn(address _from, uint256 amount);

        modifier onlyManager{
             require(msg.sender == manager);
            _;
        }

        modifier onlyIco{
             require(msg.sender == ico);
            _;
        }
        function mintTokens(address _investor, uint256 _mintedAmount) public onlyManager {
             balanceOf[_investor] = balanceOf[_investor].add(_mintedAmount);
             totalSupply = totalSupply.add(_mintedAmount);
             Transfer(this, _investor, _mintedAmount);

        }

        function burnTokens(address _owner) public onlyIco{
             uint  tokens = balanceOf[_owner];
             require(balanceOf[_owner] != 0);
             balanceOf[_owner] = 0;
             totalSupply = totalSupply.sub(tokens);
             Burn(_owner, tokens);
        }

        function setIco(address _ico) onlyManager{
            ico = _ico;
        }
}