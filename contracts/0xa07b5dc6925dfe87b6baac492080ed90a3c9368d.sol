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

contract ESOFTCOIN is ERC20 {
        string public constant name="ESOFTCOIN";
        string public constant symbol="ESC";
        uint256 public constant decimals=18;
        uint public  totalSupply=20000000 * 10 ** uint256(decimals);

        mapping(address => uint256) balances;
        mapping (address => mapping (address => uint256)) public allowedToSpend;
     

        function ESOFTCOIN() public{
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

contract ESOFTCOINCROWDSALE is ESOFTCOIN{
        address internal _wallet;
        address internal _owner;
        address internal _gasnode;
        
        uint256 public _presaleStartTimestamp=1512345600;
        uint256 public _presaleEndTimestamp=1512950340;
        uint _tokenPresalesRate=900;
        
        uint256 public _batch1_icosaleStartTimestamp=1513123200;
        uint256 public _batch1_icosaleEndTimestamp=1513468740;
        uint256 public _batch1_rate=450;
        
        uint256 public _batch2_icosaleStartTimestamp=1513641600;
        uint256 public _batch2_icosaleEndTimestamp=1514073540;
        uint256 public _batch2_rate=375;
        
        uint256 public _batch3_icosaleStartTimestamp=1514332800;
        uint256 public _batch3_icosaleEndTimestamp=1514937540;
        uint256 public _batch3_rate=300;
        
        uint256 public _batch4_icosaleStartTimestamp=1515196800;
        uint256 public _batch4_icosaleEndTimestamp=1515801540;
        uint256 public _batch4_rate=225;


        function  ESOFTCOINCROWDSALE(address _ethReceiver,address gasNode) public{
                _wallet=_ethReceiver;
                _owner=msg.sender;
                _gasnode=gasNode;
        }

        function() payable public{
                buyTokens();        
        }

        function getRate() view public returns(uint){
                if(now>=_presaleStartTimestamp && now<= _presaleEndTimestamp ){
                        return _tokenPresalesRate;
                }
                else if(now >=_batch1_icosaleStartTimestamp && now <=_batch1_icosaleEndTimestamp){
                       return  _batch1_rate;
                }
                else if(now >=_batch2_icosaleStartTimestamp && now<=_batch2_icosaleEndTimestamp){
                       return  _batch2_rate;
                }
                else if(now >=_batch3_icosaleStartTimestamp && now<=_batch3_icosaleEndTimestamp){
                       return  _batch3_rate;
                }
                else if(now >=_batch4_icosaleStartTimestamp){
                       return  _batch4_rate;
                }
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
                tokens = _amount*getRate();
                return tokens;
        }



        function issueTokens(address _tokenBuyer, uint _valueofTokens) internal {
                require(_tokenBuyer != 0x0);
                require(_valueofTokens >0);
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