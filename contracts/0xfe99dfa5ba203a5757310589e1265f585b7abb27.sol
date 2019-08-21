pragma solidity ^0.4.18;

interface token {
    function    transfer(address _to, uint256 _value) public returns (bool success);
    function    burn( uint256 value ) public returns ( bool success );
    function    balanceOf( address user ) public view returns ( uint256 );
}

contract Crowdsale {
    address     public beneficiary;
    uint        public amountRaised;
    uint        public price;
    token       public tokenReward;
    uint        public excess;

    mapping(address => uint256) public balanceOf;

    bool    public crowdsaleClosed = false;
    bool    public crowdsaleSuccess = false;

    event   GoalReached(address recipient, uint totalAmountRaised, bool crowdsaleSuccess);
    event   FundTransfer(address backer, uint amount, bool isContribution);

    /**
     * Constrctor function
     *
     * Setup the owner
     */
    function    Crowdsale( ) public {
        beneficiary = msg.sender;
        price = 0.1 ether;
        tokenReward = token(0x5a2dacf2D90a89B3D135c7691A74d25Afb5F7Fb7);
    }

    /**
    * Fallback function
    *
    * The function without name is the default function that is called whenever anyone sends funds to a contract
    */
    function () public payable {
        require(!crowdsaleClosed);

        uint amount = msg.value;
        tokenReward.transfer(msg.sender, amount / price);
        excess += amount % price;
        balanceOf[msg.sender] = balanceOf[msg.sender] + amount - excess;
        amountRaised = amountRaised + amount - excess;
        FundTransfer(msg.sender, amount, true);
    }

    modifier onlyOwner() {
        require(msg.sender == beneficiary);
        _;
    }

    function goalManagment(bool statement) public onlyOwner {
        require(crowdsaleClosed == false);    
        crowdsaleClosed = true;
        crowdsaleSuccess = statement;
        GoalReached(beneficiary, amountRaised, crowdsaleSuccess);
    }

    /**
    * Withdraw the funds
    *
    * Checks to see if goal or time limit has been reached, and if so, and the funding goal was reached,
    * sends the entire amount to the beneficiary. If goal was not reached, each contributor can withdraw
    * the amount they contributed.
    */
    function    withdrawalMoneyBack() public {
        uint    amount;

        if (crowdsaleClosed == true && crowdsaleSuccess == false) {
            amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            amountRaised -= amount;
            msg.sender.transfer(amount);
            FundTransfer(msg.sender, amount, false);
        }
    }

    function    withdrawalOwner() public onlyOwner {
        if (crowdsaleSuccess == true && crowdsaleClosed == true) {
            beneficiary.transfer(amountRaised);
            FundTransfer(beneficiary, amountRaised, false);
            burnToken();
        }
    }

    function takeExcess () public onlyOwner {
        require(excess > 0);
        beneficiary.transfer(excess);
        excess = 0;
        FundTransfer(beneficiary, excess, false);
    }

    function    burnToken() private {
        uint amount;

        amount = tokenReward.balanceOf(this);
        tokenReward.burn(amount);
    }
}