pragma solidity ^0.4.15;

contract EngravedToken {
    uint256 public totalSupply;
    function issue(address, uint256) returns (bool) {}
    function balanceOf(address) constant returns (uint256) {}
    function unlock() returns (bool) {}
    function startIncentiveDistribution() returns (bool) {}
    function transferOwnership(address) {}
    function owner() returns (address) {}
}

contract EGRCrowdsale {
    // Crowdsale details
    address public beneficiary;
    address public confirmedBy; // Address that confirmed beneficiary

    // Maximum tokens supply
    uint256 public maxSupply = 1000000000; // 1 billion

    // Minum amount of ether to be exchanged for EGR
    uint256 public minAcceptedAmount = 10 finney; // 0.01 ETH

    //Amount of free tokens per user in airdrop period
    uint256 public rateAirDrop = 1000;

    // Number of airdrop participants
    uint256 public airdropParticipants;

    //Maximum number of airdrop participants
    uint256 public maxAirdropParticipants = 500;

    // Check if this is the first participation in the airdrop
    mapping (address => bool) participatedInAirdrop;

    // ETH to EGR rate
    uint256 public rateAngelsDay = 100000;
    uint256 public rateFirstWeek = 80000;
    uint256 public rateSecondWeek = 70000;
    uint256 public rateThirdWeek = 60000;
    uint256 public rateLastWeek = 50000;

    uint256 public airdropEnd = 3 days;
    uint256 public airdropCooldownEnd = 7 days;
    uint256 public rateAngelsDayEnd = 8 days;
    uint256 public angelsDayCooldownEnd = 14 days;
    uint256 public rateFirstWeekEnd = 21 days;
    uint256 public rateSecondWeekEnd = 28 days;
    uint256 public rateThirdWeekEnd = 35 days;
    uint256 public rateLastWeekEnd = 42 days;

    enum Stages {
        Airdrop,
        InProgress,
        Ended,
        Withdrawn,
        Proposed,
        Accepted
    }

    Stages public stage = Stages.Airdrop;

    // Crowdsale state
    uint256 public start;
    uint256 public end;
    uint256 public raised;

    // EGR EngravedToken
    EngravedToken public EGREngravedToken;

    // Invested balances
    mapping (address => uint256) balances;

    struct Proposal {
        address engravedAddress;
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
		    require(stage == _stage);
        _;
    }


    /**
     * Throw if at stage other than current stage
     *
     * @param _stage1 expected stage to test for
     * @param _stage2 expected stage to test for
     */
    modifier atStages(Stages _stage1, Stages _stage2) {
		    require(stage == _stage1 || stage == _stage2);
        _;
    }


    /**
     * Throw if sender is not beneficiary
     */
    modifier onlyBeneficiary() {
		    require(beneficiary == msg.sender);
        _;
    }


    /**
     * Throw if sender has a EGR balance of zero
     */
    modifier onlyTokenholders() {
		    require(EGREngravedToken.balanceOf(msg.sender) > 0);
        _;
    }


    /**
     * Throw if the current transfer proposal's deadline
     * is in the past
     */
    modifier beforeDeadline() {
		    require(now < transferProposal.deadline);
        _;
    }


    /**
     * Throw if the current transfer proposal's deadline
     * is in the future
     */
    modifier afterDeadline() {
		    require(now > transferProposal.deadline);
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
     * @param _EngravedTokenAddress The address of the EGR EngravedToken contact
     * @param _beneficiary Company address
     * @param _start airdrop start date
     */
    function EGRCrowdsale(address _EngravedTokenAddress, address _beneficiary, uint256 _start) {
        EGREngravedToken = EngravedToken(_EngravedTokenAddress);
        beneficiary = _beneficiary;
        start = _start;
        end = start + 42 days;
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
     * Convert `_wei` to an amount in EGR using
     * the current rate
     *
     * @param _wei amount of wei to convert
     * @return The amount in EGR
     */
    function toEGR(uint256 _wei) returns (uint256 amount) {
        uint256 rate = 0;
        if (stage != Stages.Ended && now >= start && now <= end) {

            // Check for cool down after airdrop
            if (now <= start + airdropCooldownEnd) {
                rate = 0;
            }

            // Check for AngelsDay
            else if (now <= start + rateAngelsDayEnd) {
                rate = rateAngelsDay;
            }

            // Check for cool down after the angels day
            else if (now <= start + angelsDayCooldownEnd) {
      			    rate = 0;
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
	      require(rate != 0); // Check for cool down periods
        return _wei * rate * 10**3 / 1 ether; // 10**3 for 3 decimals
    }

    /**
    * Function to participate in the airdrop
    */
    function claim() atStage(Stages.Airdrop) {
        require(airdropParticipants < maxAirdropParticipants);

        // Crowdsal not started yet
        require(now > start);

        // Airdrop expired
        require(now < start + airdropEnd);

        require(participatedInAirdrop[msg.sender] == false); // Only once per address

        require(EGREngravedToken.issue(msg.sender, rateAirDrop * 10**3));

        participatedInAirdrop[msg.sender] = true;
        airdropParticipants += 1;
    }

    /**
     * Function to end the airdrop and start crowdsale
     */
    function endAirdrop() atStage(Stages.Airdrop) {
	      require(now > start + airdropEnd);

        stage = Stages.InProgress;
    }

    /**
     * Function to end the crowdsale by setting
     * the stage to Ended
     */
    function endCrowdsale() atStage(Stages.InProgress) {

        // Crowdsale not ended yet
	      require(now > end);

        stage = Stages.Ended;
    }


    /**
     * Transfer raised amount to the company address
     */
    function withdraw() onlyBeneficiary atStage(Stages.Ended) {
        require(beneficiary.send(raised));

        stage = Stages.Withdrawn;
    }

    /**
     * Propose the transfer of the EngravedToken contract ownership
     * to `_engravedAddress`
     *
     * @param _engravedAddress the address of the proposed EngravedToken owner
     */
    function proposeTransfer(address _engravedAddress) onlyBeneficiary atStages(Stages.Withdrawn, Stages.Proposed) {

        // Check for a pending proposal
	      require(stage != Stages.Proposed || now > transferProposal.deadline + transferProposalCooldown);

        transferProposal = Proposal({
            engravedAddress: _engravedAddress,
            deadline: now + transferProposalEnd,
            approvedWeight: 0,
            disapprovedWeight: 0
        });

        stage = Stages.Proposed;
    }


    /**
     * Allows EGR holders to vote on the poposed transfer of
     * ownership. Weight is calculated directly, this is no problem
     * because EngravedTokens cannot be transferred yet
     *
     * @param _approve indicates if the sender supports the proposal
     */
    function vote(bool _approve) onlyTokenholders beforeDeadline atStage(Stages.Proposed) {

        // One vote per proposal
	      require(transferProposal.voted[msg.sender] < transferProposal.deadline - transferProposalEnd);

        transferProposal.voted[msg.sender] = now;
        uint256 weight = EGREngravedToken.balanceOf(msg.sender);

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
     * EngravedToken contract to Engraved
     */
    function executeTransfer() afterDeadline atStage(Stages.Proposed) {

        // Check approved
	      require(transferProposal.approvedWeight > transferProposal.disapprovedWeight);

	      require(EGREngravedToken.unlock());

        require(EGREngravedToken.startIncentiveDistribution());

        EGREngravedToken.transferOwnership(transferProposal.engravedAddress);
	      require(EGREngravedToken.owner() == transferProposal.engravedAddress);

        require(transferProposal.engravedAddress.send(this.balance));

        stage = Stages.Accepted;
    }


    /**
     * Receives ETH and issue EGR EngravedTokens to the sender
     */
    function () payable atStage(Stages.InProgress) {

        // Crowdsale not started yet
        require(now > start);

        // Crowdsale expired
        require(now < end);

        // Enforce min amount
	      require(msg.value >= minAcceptedAmount);

        uint256 received = msg.value;
        uint256 valueInEGR = toEGR(msg.value);

        require((EGREngravedToken.totalSupply() + valueInEGR) <= (maxSupply * 10**3));

        require(EGREngravedToken.issue(msg.sender, valueInEGR));

        balances[msg.sender] += received;
        raised += received;
    }
}