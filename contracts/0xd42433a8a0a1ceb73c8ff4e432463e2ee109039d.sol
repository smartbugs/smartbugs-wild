contract Token { 
    function issue(address _recipient, uint256 _value) returns (bool success) {} 
    function balanceOf(address _owner) constant returns (uint256 balance) {}
    function unlock() returns (bool success) {}
    function startIncentiveDistribution() returns (bool success) {}
    function transferOwnership(address _newOwner) {}
    function owner() returns (address _owner) {}
}

contract DRPCrowdsale {

    // Crowdsale details
    address public beneficiary; // Company address multisig (49% funding)
    address public confirmedBy; // Address that confirmed beneficiary
    uint256 public minAmount = 4137 ether; // ≈ 724.000 euro
    uint256 public maxAmount = 54285 ether; // ≈ 9.5 mln euro
    uint256 public minAcceptedAmount = 40 finney; // 1/25 ether

    /**
     * 51% of the raised amount remains in the crowdsale contract 
     * to be released to DCORP on launch with aproval of tokenholders.
     *
     * See whitepaper for more information
     */
    uint256 public percentageOfRaisedAmountThatRemainsInContract = 51; // 0.51 * 10^2

    // Eth to DRP rate
    uint256 public rateAngelDay = 650;
    uint256 public rateFirstWeek = 550;
    uint256 public rateSecondWeek = 475;
    uint256 public rateThirdWeek = 425;
    uint256 public rateLastWeek = 400;

    uint256 public rateAngelDayEnd = 1 days;
    uint256 public rateFirstWeekEnd = 8 days;
    uint256 public rateSecondWeekEnd = 15 days;
    uint256 public rateThirdWeekEnd = 22 days;
    uint256 public rateLastWeekEnd = 29 days;

    enum Stages {
        InProgress,
        Ended,
        Withdrawn,
        Proposed,
        Accepted
    }

    Stages public stage = Stages.InProgress;

    // Crowdsale state
    uint256 public start;
    uint256 public end;
    uint256 public raised;

    // DRP token
    Token public drpToken;

    // Invested balances
    mapping (address => uint256) balances;

    struct Proposal {
        address dcorpAddress;
        uint256 deadline;
        uint256 approvedWeight;
        uint256 disapprovedWeight;
        mapping (address => uint256) voted;
    }

    // Ownership transfer proposal
    Proposal public transferProposal;

    // Time to vote
    uint256 public transferProposalEnd = 7 days;

    // Time between proposals
    uint256 public transferProposalCooldown = 1 days;


    /**
     * Throw if at stage other than current stage
     * 
     * @param _stage expected stage to test for
     */
    modifier atStage(Stages _stage) {
        if (stage != _stage) {
            throw;
        }
        _;
    }
    

    /**
     * Throw if at stage other than current stage
     * 
     * @param _stage1 expected stage to test for
     * @param _stage2 expected stage to test for
     */
    modifier atStages(Stages _stage1, Stages _stage2) {
        if (stage != _stage1 && stage != _stage2) {
            throw;
        }
        _;
    }


    /**
     * Throw if sender is not beneficiary
     */
    modifier onlyBeneficiary() {
        if (beneficiary != msg.sender) {
            throw;
        }
        _;
    }


    /**
     * Throw if sender has a DCP balance of zero
     */
    modifier onlyShareholders() {
        if (drpToken.balanceOf(msg.sender) == 0) {
            throw;
        }
        _;
    }


    /**
     * Throw if the current transfer proposal's deadline
     * is in the past
     */
    modifier beforeDeadline() {
        if (now > transferProposal.deadline) {
            throw;
        }
        _;
    }


    /**
     * Throw if the current transfer proposal's deadline 
     * is in the future
     */
    modifier afterDeadline() {
        if (now < transferProposal.deadline) {
            throw;
        }
        _;
    }


    /** 
     * Get balance of `_investor` 
     * 
     * @param _investor The address from which the balance will be retrieved
     * @return The balance
     */
    function balanceOf(address _investor) constant returns (uint256 balance) {
        return balances[_investor];
    }


    /**
     * Most params are hardcoded for clarity
     *
     * @param _tokenAddress The address of the DRP token contact
     */
    function DRPCrowdsale(address _tokenAddress, address _beneficiary, uint256 _start) {
        drpToken = Token(_tokenAddress);
        beneficiary = _beneficiary;
        start = _start;
        end = start + 29 days;
    }


    /**
     * For testing purposes
     *
     * @return The beneficiary address
     */
    function confirmBeneficiary() onlyBeneficiary {
        confirmedBy = msg.sender;
    }


    /**
     * Convert `_wei` to an amount in DRP using 
     * the current rate
     *
     * @param _wei amount of wei to convert
     * @return The amount in DRP
     */
    function toDRP(uint256 _wei) returns (uint256 amount) {
        uint256 rate = 0;
        if (stage != Stages.Ended && now >= start && now <= end) {

            // Check for angelday
            if (now <= start + rateAngelDayEnd) {
                rate = rateAngelDay;
            }

            // Check first week
            else if (now <= start + rateFirstWeekEnd) {
                rate = rateFirstWeek;
            }

            // Check second week
            else if (now <= start + rateSecondWeekEnd) {
                rate = rateSecondWeek;
            }

            // Check third week
            else if (now <= start + rateThirdWeekEnd) {
                rate = rateThirdWeek;
            }

            // Check last week
            else if (now <= start + rateLastWeekEnd) {
                rate = rateLastWeek;
            }
        }

        return _wei * rate * 10**2 / 1 ether; // 10**2 for 2 decimals
    }


    /**
     * Function to end the crowdsale by setting 
     * the stage to Ended
     */
    function endCrowdsale() atStage(Stages.InProgress) {

        // Crowdsale not ended yet
        if (now < end) {
            throw;
        }

        stage = Stages.Ended;
    }


    /**
     * Transfer appropriate percentage of raised amount 
     * to the company address
     */
    function withdraw() onlyBeneficiary atStage(Stages.Ended) {

        // Confirm that minAmount is raised
        if (raised < minAmount) {
            throw;
        }

        uint256 amountToSend = raised * (100 - percentageOfRaisedAmountThatRemainsInContract) / 10**2;
        if (!beneficiary.send(amountToSend)) {
            throw;
        }

        stage = Stages.Withdrawn;
    }


    /**
     * Refund in the case of an unsuccessful crowdsale. The 
     * crowdsale is considered unsuccessful if minAmount was 
     * not raised before end
     */
    function refund() atStage(Stages.Ended) {

        // Only allow refunds if minAmount is not raised
        if (raised >= minAmount) {
            throw;
        }

        uint256 receivedAmount = balances[msg.sender];
        balances[msg.sender] = 0;

        if (receivedAmount > 0 && !msg.sender.send(receivedAmount)) {
            balances[msg.sender] = receivedAmount;
        }
    }


    /**
     * Propose the transfer of the token contract ownership
     * to `_dcorpAddress` 
     *
     * @param _dcorpAddress the address of the proposed token owner 
     */
    function proposeTransfer(address _dcorpAddress) onlyBeneficiary atStages(Stages.Withdrawn, Stages.Proposed) {
        
        // Check for a pending proposal
        if (stage == Stages.Proposed && now < transferProposal.deadline + transferProposalCooldown) {
            throw;
        }

        transferProposal = Proposal({
            dcorpAddress: _dcorpAddress,
            deadline: now + transferProposalEnd,
            approvedWeight: 0,
            disapprovedWeight: 0
        });

        stage = Stages.Proposed;
    }


    /**
     * Allows DRP holders to vote on the poposed transfer of 
     * ownership. Weight is calculated directly, this is no problem 
     * because tokens cannot be transferred yet
     *
     * @param _approve indicates if the sender supports the proposal
     */
    function vote(bool _approve) onlyShareholders beforeDeadline atStage(Stages.Proposed) {

        // One vote per proposal
        if (transferProposal.voted[msg.sender] >= transferProposal.deadline - transferProposalEnd) {
            throw;
        }

        transferProposal.voted[msg.sender] = now;
        uint256 weight = drpToken.balanceOf(msg.sender);

        if (_approve) {
            transferProposal.approvedWeight += weight;
        } else {
            transferProposal.disapprovedWeight += weight;
        }
    }


    /**
     * Calculates the votes and if the majority weigt approved 
     * the proposal the transfer of ownership is executed.
     
     * The Crowdsale contact transferres the ownership of the 
     * token contract to DCorp and starts the insentive 
     * distribution recorded in the token contract.
     */
    function executeTransfer() afterDeadline atStage(Stages.Proposed) {

        // Check approved
        if (transferProposal.approvedWeight <= transferProposal.disapprovedWeight) {
            throw;
        }

        if (!drpToken.unlock()) {
            throw;
        }
        
        if (!drpToken.startIncentiveDistribution()) {
            throw;
        }

        drpToken.transferOwnership(transferProposal.dcorpAddress);
        if (drpToken.owner() != transferProposal.dcorpAddress) {
            throw;
        }

        if (!transferProposal.dcorpAddress.send(this.balance)) {
            throw;
        }

        stage = Stages.Accepted;
    }

    
    /**
     * Receives Eth and issue DRP tokens to the sender
     */
    function () payable atStage(Stages.InProgress) {

        // Crowdsale not started yet
        if (now < start) {
            throw;
        }

        // Crowdsale expired
        if (now > end) {
            throw;
        }

        // Enforce min amount
        if (msg.value < minAcceptedAmount) {
            throw;
        }
 
        uint256 received = msg.value;
        uint256 valueInDRP = toDRP(msg.value);
        if (!drpToken.issue(msg.sender, valueInDRP)) {
            throw;
        }

        balances[msg.sender] += received;
        raised += received;

        // Check maxAmount raised
        if (raised >= maxAmount) {
            stage = Stages.Ended;
        }
    }
}