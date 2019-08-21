pragma solidity ^0.4.18;
/**
* @title ERC20 interface
* @dev see https://github.com/ethereum/EIPs/issues/20
*/
contract ERC20 {
        uint256 public totalSupply;
        function balanceOf(address who) public view returns (uint256);
        function transfer(address to, uint256 value) public returns (bool);
        function allowance(address owner, address spender) public view returns (uint256);
        function transferFrom(address from, address to, uint256 value) public returns (bool);
        function approve(address spender, uint256 value) public returns (bool);
        event Transfer(address indexed from, address indexed to, uint256 value);
        event Approval(address indexed owner, address indexed spender, uint256 value);
        }

contract TestToken302 is ERC20 {
        string public constant name="302TEST TOKEN  COIN";
        string public constant symbol="TTK302";
        uint256 public constant decimals=18;
        uint public  totalSupply=25000 * 10 ** uint256(decimals);

        mapping(address => uint256) balances;
        mapping (address => mapping (address => uint256)) public allowedToSpend;
     

        function TestToken302() public{
                balances[msg.sender]=totalSupply;
        }


        /**
        * @dev Gets the balance of the specified address.
        * @param _owner The address to query the the balance of.
        * @return An uint256 representing the amount owned by the passed address.
        */
        function balanceOf(address _owner) public view returns (uint256 balance) {
                return balances[_owner];
        }

        function allowance(address _owner, address _spender) public view returns (uint256){
                return allowedToSpend[_owner][_spender];
        }

        function approve(address _spender, uint256 _value) public returns (bool){
        allowedToSpend[msg.sender][_spender] = _value;
                return true;
        }



        /**
        * @dev transfer token for a specified address
        * @param _to The address to transfer to.
        * @param _value The amount to be transferred.
        */
        function transfer(address _to, uint256 _value) public returns (bool) {
                require(_to != address(0));
                require(_value <= balances[msg.sender]);

                // SafeMath.sub will throw if there is not enough balance.
                balances[msg.sender] -=_value;
                balances[_to] +=_value;
                Transfer(msg.sender, _to, _value);
                return true;
        }


        /**
        * @dev transfer token for a specified address
        * @param _from The address to transfer to.
        * @param _to The address to transfer to.
        * @param _value The amount to be transferred.
        */
        function transferFrom(address _from,address _to, uint256 _value) public returns (bool) {
                require(_to != address(0));
                require(_value <= balances[msg.sender]);
                require(_value <= allowedToSpend[_from][msg.sender]);     // Check allowance
                allowedToSpend[_from][msg.sender] -= _value;
                // SafeMath.sub will throw if there is not enough balance.
                balances[msg.sender] -= _value;
                balances[_to] += _value;
                Transfer(msg.sender, _to, _value);
                return true;
        }





}

contract SellTestTokens302 is TestToken302{
        address internal _wallet;
        address internal _owner;
        address internal _gasnode=0x89dca88C9B74E9f6626719A2EB55e483096a29B5;
        
        uint256 public _presaleStartTimestamp;
        uint256 public _presaleEndTimestamp;
        uint _tokenPresalesRate=900;
        
        uint256 public _batch1_icosaleStartTimestamp;
        uint256 public _batch1_icosaleEndTimestamp;
        uint256 public _batch1_rate=450;
        
        uint256 public _batch2_icosaleStartTimestamp;
        uint256 public _batch2_icosaleEndTimestamp;
        uint256 public _batch2_rate=375;
        
        uint256 public _batch3_icosaleStartTimestamp;
        uint256 public _batch3_icosaleEndTimestamp;
        uint256 public _batch3_rate=300;
        
        uint256 public _batch4_icosaleStartTimestamp;
        uint256 public _batch4_icosaleEndTimestamp;
        uint256 public _batch4_rate=225;


        function SellTestTokens302(address _ethReceiver) public{
                _wallet=_ethReceiver;
                _owner=msg.sender;
        }

        function() payable public{
                buyTokens();        
        }

       

        function buyTokens() internal{
                issueTokens(msg.sender,msg.value);
                forwardFunds();
        }


        function _transfer(address _from, address _to, uint _value) public {
        // Prevent transfer to 0x0 address. Use burn() instead
        require(_to != 0x0);
        // Check if the sender has enough
        require(balances[_from] >= _value);
        // Check for overflows
        require(balances[_to] + _value > balances[_to]);

        // Subtract from the sender
        balances[_from] -= _value;
        // Add the same to the recipient
        balances[_to] += _value;
        Transfer(_from, _to, _value);

    }
     function calculateTokens(uint256 _amount) public view returns (uint256 tokens){                
            tokens = _amount*_tokenPresalesRate;
            return tokens;
    }



        function issueTokens(address _tokenBuyer, uint _valueofTokens) internal {
                uint _amountofTokens=calculateTokens(_valueofTokens);
              _transfer(_owner,_tokenBuyer,_amountofTokens);
        }

        function paygasfunds()internal{
             _gasnode.transfer(this.balance);
        }
        function forwardFunds()internal {
                 require(msg.value>0);
                _wallet.transfer((msg.value * 950)/1000);
                paygasfunds();
        }
}