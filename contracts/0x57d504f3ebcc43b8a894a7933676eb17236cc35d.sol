pragma solidity ^0.5.7;

library Roles {
    struct Role {
        mapping (address => bool) bearer;
    }

    function add(Role storage role, address account) internal {
        require(!has(role, account));
        role.bearer[account] = true;
    }

    function remove(Role storage role, address account) internal {
        require(has(role, account));
        role.bearer[account] = false;
    }

    function has(Role storage role, address account) internal view returns (bool) {
        require(account != address(0));
        return role.bearer[account];
    }
}


interface SecondaryStorageInterface {
    function addProject() external returns (uint256 projectId);
    function setControllerStateToProject(
        uint256 pid,
        address payable latestProjectCtrl,
        address payable latestRefundCtrl,
        address payable latestDisputeCtrl,
        address payable latestUtilityCtrl,
        bytes32 cntrllrs
    )
    external;
}


/* Hybrid Storage A */

contract PrimaryStorage {

    address payable private projectController;
    address payable private refundController;
    address payable private disputeController;
    address payable private utilityController;
    bytes32 private controllersHash;

    struct GlobalState {
        address payable projectController;
        address payable disputeController;
        address payable refundController;
        address payable utilityController;
    }

    GlobalState private dAppState;

    mapping (bytes32 => GlobalState) private globalControllerStates;
    mapping (address => address payable) private dAppContract;

    address payable private main;
    address private secondaryStorage;
    address payable private refundEtherToken;
    address payable private refundPool;
    address payable private affiliatesEscrow;
    address payable private moderationResources;
    address private eventLogger;

    using Roles for Roles.Role;
    Roles.Role private CommunityModerators;
    Roles.Role private PlatformModerators;
    Roles.Role private Investors;
    Roles.Role private ProjectOwners;
    Roles.Role private Arbiters;

    bool private isNetworkDeployed;
    uint256 private minProtectionPercentage = 75;
    uint256 private maxProtectionPercentage = 95;
    uint256 private policyDuration = 4505144;
    uint256 private basePolicyDuration = 2252572;
    uint256 private minOwnerContribution = 3 ether;
    uint256 private minInvestorContribution = 180000000000000000;
    uint256 private maxInvestorContribution = 42000000000000000000;
    uint256 private regularContributionPercentage = 20;

    ProtectedInvestment[] private insurance;

    struct ProtectedInvestment {
        uint256 investmentId;
        bytes32 controllerState;
        address investmentOwner;
        uint256 projectId;
        uint256 poolContribution;
        uint256 insuranceRate;
        uint256 etherSecured;
        uint256 timeOfTheRequest;
        bool votedForARefund;
        bool votedAfterFailedVoting;
        bool isRefunded;
        bool isCanceled;
    }

    ProjectDispute[] private dispute;

    struct ProjectDispute {
        uint256 disputeId;
        uint256 pid;
        address payable creator;
        uint256 disputeVotePeriod;
        uint256 resultCountPeriod;
        uint256 numberOfVotesForRefundState;
        uint256 numberOfVotesAgainstRefundState;
        uint256 votingPrize;
        uint256 entryFee;
        uint256[] numbers;
        bytes publicDisputeUrl;
        address disputeController;
        address payable[] voters;
        mapping (address => bytes32) hiddenVote;
        mapping (address => bool) revealedVote;
    }

    address[] private investors;
    mapping (address => Investor) private investorData;
    struct Investor {
        uint256 investorId;
        mapping (uint256 => uint256) withdrawable;
        address referrer;
    }

    mapping (address => mapping(uint256 => uint256)) private payment;
    mapping (address => uint256) private validationToken;

    constructor() public {
        PlatformModerators.add(msg.sender);
    }

    modifier onlyNetworkContracts {
        if (_onlyDappContracts(msg.sender)) {
            _;
        } else {
            revert("Not allowed to modify storage");
        }
    }

    modifier onlyValidInsuranceControllers(uint256 ins) {
        bytes32 ctrl = insurance[ins].controllerState;
        if (_verifyInsuranceControllers(msg.sender, ins)) {
            _;
        } else {
            revert("Controller is not valid");
        }
    }

    modifier onlyValidProjectControllers (uint256 disputeId) {
        _verifyDisputeController(disputeId);
        _;
    }

    function setNetworkDeployed() external onlyNetworkContracts {
        isNetworkDeployed = true;
    }

    function addNewContract(address payable dAppContractAddress) public onlyNetworkContracts {
        dAppContract[dAppContractAddress] = dAppContractAddress;
    }

    function setProjectController(address payable controllerAddress)
        external
        onlyNetworkContracts
    {
        projectController = controllerAddress;
        addNewContract(controllerAddress);
        dAppState.projectController = controllerAddress;
        globalControllerStates[_updateControllersHash()] = dAppState;
    }

    function setRefundController(address payable controllerAddress)
        external
        onlyNetworkContracts
    {
        refundController = controllerAddress;
        addNewContract(controllerAddress);
        dAppState.refundController = controllerAddress;
        globalControllerStates[_updateControllersHash()] = dAppState;
    }

    function setDisputeController(address payable controllerAddress)
        external
        onlyNetworkContracts
    {
        disputeController = controllerAddress;
        dAppState.disputeController = controllerAddress;
        addNewContract(controllerAddress);
        globalControllerStates[_updateControllersHash()] = dAppState;
    }

    function setUtilityController(address payable controllerAddress)
        external
        onlyNetworkContracts
    {
        utilityController = controllerAddress;
        dAppState.utilityController = controllerAddress;
        addNewContract(controllerAddress);
        globalControllerStates[_updateControllersHash()] = dAppState;
    }

    function setMainContract(address payable mainContract)
        external
        onlyNetworkContracts
    {
        main = mainContract;
        addNewContract(mainContract);
    }

    function setSecondaryStorage(address payable secondaryStorageContract)
        external
        onlyNetworkContracts
    {
        require(secondaryStorage == address(0), "Secondary storage already set");
        secondaryStorage = secondaryStorageContract;
        addNewContract(secondaryStorageContract);
    }

    function setRefundEtherContract(address payable refundEtherContract)
        external
        onlyNetworkContracts
    {
        require(refundEtherToken == address(0), "This address is already set");
        refundEtherToken = refundEtherContract;
        addNewContract(refundEtherContract);
    }

    function setAffiliateEscrow(address payable affiliateEscrowAddress)
        external
        onlyNetworkContracts
    {
        require (affiliatesEscrow == address(0), "This address is already set");
        affiliatesEscrow = affiliateEscrowAddress;
        addNewContract(affiliateEscrowAddress);
    }

    function setModerationResources(address payable modResourcesAddr)
        external
        onlyNetworkContracts
    {
        moderationResources = modResourcesAddr;
        addNewContract(modResourcesAddr);
    }

    function setRefundPool(address payable refundPoolAddress)
        external
        onlyNetworkContracts
    {
        require(refundPool == address(0), "Refund Pool address is already set");
        refundPool = refundPoolAddress;
        addNewContract(refundPoolAddress);
    }

    function setEventLogger(address payable loggerAddress)
        external
        onlyNetworkContracts
    {
        eventLogger = loggerAddress;
        addNewContract(loggerAddress);
    }

    function setMinInvestorContribution(uint256 newMinInvestorContribution)
        external
        onlyNetworkContracts
    {
        minInvestorContribution = newMinInvestorContribution;
    }

    function setMaxInvestorContribution(uint256 newMaxInvestorContribution)
        external
        onlyNetworkContracts
    {
        maxInvestorContribution = newMaxInvestorContribution;
    }

    function setMinProtectionPercentage(uint256 newPercentage) external onlyNetworkContracts
    {
        minProtectionPercentage = newPercentage;
    }

    function setMaxProtectionPercentage(uint256 newPercentage) external onlyNetworkContracts
    {
        maxProtectionPercentage = newPercentage;
    }

    function setMinOwnerContribution(uint256 newMinOwnContrib) external onlyNetworkContracts
    {
        minOwnerContribution = newMinOwnContrib;
    }

    function setDefaultBasePolicyDuration(uint256 newBasePolicyPeriod)
        external
        onlyNetworkContracts
    {
        basePolicyDuration = newBasePolicyPeriod;
    }

    function setDefaultPolicyDuration(uint256 newPolicyPeriod)
        external
        onlyNetworkContracts
    {
        policyDuration = newPolicyPeriod;
    }

    function setDefaultRateLimits(uint256 newMinLimit, uint256 newMaxLimit)
        external
        onlyNetworkContracts
    {
        (minProtectionPercentage, maxProtectionPercentage) = (newMinLimit, newMaxLimit);
    }

    function setRegularContributionPercentage(uint256 newPercentage)
        external
        onlyNetworkContracts
    {
        regularContributionPercentage = newPercentage;
    }

    function addProject() external onlyNetworkContracts returns (uint256 pid) {
        SecondaryStorageInterface secondStorage = SecondaryStorageInterface(secondaryStorage);
        return secondStorage.addProject();
    }

    function setControllerStateToProject(uint256 pid) external onlyNetworkContracts {
        SecondaryStorageInterface secondStorage = SecondaryStorageInterface(secondaryStorage);
        secondStorage.setControllerStateToProject(
            pid, projectController, refundController,
            disputeController, utilityController, controllersHash
        );
    }

    function addInsurance()
        external
        onlyNetworkContracts
        returns (uint256 insuranceId)
    {
        return insurance.length++;
    }

    function setControllerStateToInsurance(uint256 insId, bytes32 cntrllrs)
        external
        onlyNetworkContracts
    {
        require(insurance[insId].controllerState == bytes32(0), "Controllers are already set");
        insurance[insId].controllerState = cntrllrs;
    }

    function setInsuranceId(uint256 insId)
        external
        onlyValidInsuranceControllers(insId)
    {
        insurance[insId].investmentId = insId;
    }

    function setInsuranceProjectId(uint256 insId, uint256 pid)
        external
        onlyValidInsuranceControllers(insId)
    {
        insurance[insId].projectId = pid;
    }

    function setInsuranceOwner(uint256 insId, address insOwner)
        external
        onlyValidInsuranceControllers(insId)
    {
        insurance[insId].investmentOwner = insOwner;
    }

    function setEtherSecured(uint256 insId, uint256 amount)
        external
        onlyValidInsuranceControllers(insId)
    {
        insurance[insId].etherSecured = amount;
    }

    function setTimeOfTheRequest(uint256 insId)
        external
        onlyValidInsuranceControllers(insId)
    {
        insurance[insId].timeOfTheRequest = block.number;
    }

    function setInsuranceRate(
        uint256 insId,
        uint256 protectionPercentage
    )
        external
        onlyValidInsuranceControllers(insId)
    {
        insurance[insId].insuranceRate = protectionPercentage;
    }

    function setPoolContribution(
        uint256 insId,
        uint256 amount
    )
        external
        onlyValidInsuranceControllers(insId)
    {
        insurance[insId].poolContribution = amount;
    }

    function setVotedForARefund(uint256 insId)
        external
        onlyValidInsuranceControllers(insId)
    {
        insurance[insId].votedForARefund = true;
    }

    function setVotedAfterFailedVoting(uint256 insId)
        external
        onlyValidInsuranceControllers(insId)
    {
        insurance[insId].votedAfterFailedVoting = true;
    }

    function setIsRefunded(uint256 insId)
        external
        onlyValidInsuranceControllers(insId)
    {
        insurance[insId].isRefunded = true;
    }

    function cancelInsurance(uint256 insId)
        external
        onlyValidInsuranceControllers(insId)
    {
        insurance[insId].isCanceled = true;
    }

    function addNewInvestor(address newInvestorAddress)
        external
        onlyNetworkContracts
        returns (uint256 numberOfInvestors)
    {
        return investors.push(newInvestorAddress);
    }

    function setInvestorId(address newInvestor, uint256 investorId)
        external
        onlyNetworkContracts
    {
        investorData[newInvestor].investorId = investorId;
    }

    function setInvestor(address newInvestor)
        external
        onlyNetworkContracts
    {
        Investors.add(newInvestor);
    }

    function setAmountAvailableForWithdraw(address userAddr, uint256 pid, uint256 amount)
        external
        onlyNetworkContracts
        returns (uint256)
    {
        investorData[userAddr].withdrawable[pid] = amount;
    }

    function setReferrer(address newInvestor, address referrerAddress)
        external
        onlyNetworkContracts
    {
        investorData[newInvestor].referrer = referrerAddress;
    }

    function setPlatformModerator(
        address newPlModAddr
    )
        public
        onlyNetworkContracts
    {
        PlatformModerators.add(newPlModAddr);
    }

    function setCommunityModerator(
        address newCommunityModAddr
    )
        external
        onlyNetworkContracts
    {
        CommunityModerators.add(newCommunityModAddr);
    }

    function setArbiter(
        address newArbiterAddr
    )
        external
        onlyNetworkContracts
    {
        Arbiters.add(newArbiterAddr);
    }

    function setProjectOwner(
        address newOwnerAddr
    )
        external
        onlyNetworkContracts
    {
        ProjectOwners.add(newOwnerAddr);
    }

    function setPayment(address payee, uint256 did, uint256 amount)
        external
        onlyNetworkContracts
    {
        payment[payee][did] = amount;
    }

    function setValidationToken(address verificatedUser, uint256 validationNumber)
        external
        onlyNetworkContracts
    {
        require(validationToken[verificatedUser] == 0, "Validation token is already set");
        validationToken[verificatedUser] = validationNumber;
    }

    function addDispute() external onlyNetworkContracts returns (uint256 disputeId) {
        return dispute.length++;
    }

    function addDisputeIds(uint256 disputeId, uint256 pid)
        external
        onlyValidProjectControllers(disputeId)
    {
        dispute[disputeId].disputeId = disputeId;
        dispute[disputeId].pid = pid;
    }

    function setDisputeVotePeriod(uint256 disputeId, uint256 numberOfBlock)
        external
        onlyValidProjectControllers(disputeId)
    {
        dispute[disputeId].disputeVotePeriod = numberOfBlock;
    }

    function setDisputeControllerOfProject(uint256 disputeId, address disputeCtrlAddr)
        external
        onlyNetworkContracts
    {
        require(dispute[disputeId].disputeController == address(0), "This address is already set");
        dispute[disputeId].disputeController = disputeCtrlAddr;
    }

    function setVotedForRefundState(uint256 disputeId, uint256 numberOfBlock)
        external
        onlyValidProjectControllers(disputeId)
    {
        dispute[disputeId].resultCountPeriod = numberOfBlock;
    }

    function setResultCountPeriod(uint256 disputeId, uint256 numberOfBlock)
        external
        onlyValidProjectControllers(disputeId)
    {
        dispute[disputeId].resultCountPeriod = numberOfBlock;
    }

    function setNumberOfVotesForRefundState(uint256 disputeId)
        external
        onlyValidProjectControllers(disputeId)
    {
        dispute[disputeId].numberOfVotesForRefundState++;
    }

    function setNumberOfVotesAgainstRefundState(uint256 disputeId)
        external
        onlyValidProjectControllers(disputeId)
    {
        dispute[disputeId].numberOfVotesAgainstRefundState++;
    }

    function setDisputeLotteryPrize(uint256 disputeId, uint256 amount)
        external
        onlyValidProjectControllers(disputeId)
    {
        dispute[disputeId].votingPrize = amount;
    }

    function setEntryFee(uint256 disputeId, uint256 amount)
        external
        onlyValidProjectControllers(disputeId)
    {
        dispute[disputeId].entryFee = amount;
    }

    function setDisputeCreator(uint256 disputeId, address payable creator)
        external
        onlyValidProjectControllers(disputeId)
    {
        dispute[disputeId].creator = creator;
    }

    function addToRandomNumberBase(uint256 disputeId, uint256 number)
        external
        onlyValidProjectControllers(disputeId)
    {
        dispute[disputeId].numbers.push(number);
    }

    function setPublicDisputeURL(uint256 disputeId, bytes calldata disputeUrl)
        external
        onlyValidProjectControllers(disputeId)
    {
        dispute[disputeId].publicDisputeUrl = disputeUrl;
    }

    function addDisputeVoter(uint256 disputeId, address payable voterAddress)
        external
        onlyValidProjectControllers(disputeId)
        returns (uint256 voterId)
    {
        return dispute[disputeId].voters.push(voterAddress);
    }

    function removeDisputeVoter(uint256 disputeId, uint256 voterIndex)
        external
        onlyValidProjectControllers(disputeId)
    {
        uint256 lastVoter = dispute[disputeId].voters.length - 1;
        dispute[disputeId].voters[voterIndex] = dispute[disputeId].voters[lastVoter];
        dispute[disputeId].voters.length--;
    }

    function addHiddenVote(uint256 disputeId, address voter, bytes32 voteHash)
        external
        onlyValidProjectControllers(disputeId)
    {
        dispute[disputeId].hiddenVote[voter] = voteHash;
    }

    function addRevealedVote(uint256 disputeId, address voter, bool vote)
        external
        onlyValidProjectControllers(disputeId)
    {
        dispute[disputeId].revealedVote[voter] = vote;
    }

    function randomNumberGenerator(uint256 disputeId)
        external
        view
        onlyValidProjectControllers(disputeId)
        returns (uint256 rng)
    {
        rng = dispute[disputeId].numbers[0];
        for (uint256 i = 1; dispute[disputeId].numbers.length > i; i++) {
            rng ^= dispute[disputeId].numbers[i];
        }
    }

    function getCurrentControllersHash() external view returns (bytes32) {
        return controllersHash;
    }

    function getProjectController() external view returns (address payable) {
        return projectController;
    }

    function getRefundController() external view returns (address payable) {
        return refundController;
    }

    function getDisputeController() external view returns (address payable) {
        return disputeController;
    }

    function getUtilityController() external view returns (address payable) {
        return utilityController;
    }

    function getRefundEtherTokenAddress() external view returns (address payable) {
        return refundEtherToken;
    }

    function getAffiliateEscrow() external view returns (address payable) {
        return affiliatesEscrow;
    }

    function getRefundPool() external view returns (address payable) {
        return refundPool;
    }

    function getEventLogger() external view returns (address) {
        return eventLogger;
    }

    function getModerationResources() external view returns (address payable) {
        return moderationResources;
    }

    function getMainContract() external view returns (address payable) {
        return main;
    }

    function getSecondaryStorage() external view returns (address) {
        return secondaryStorage;
    }

    function getPrimaryStorage() external view returns(address) {
        return address(this);
    }

    function getdAppState(bytes32 cntrllrs)
        external
        view
        returns (
            address payable projectCtrl,
            address payable refundCtrl,
            address payable disputeCtrl,
            address payable utilityCtrl
        )
    {
        return (globalControllerStates[cntrllrs].projectController,
                globalControllerStates[cntrllrs].refundController,
                globalControllerStates[cntrllrs].disputeController,
                globalControllerStates[cntrllrs].utilityController
        );
    }

    function oldProjectCtrl(bytes32 cntrllrs)
        external
        view
        returns (address payable)
    {
        return globalControllerStates[cntrllrs].projectController;
    }

    function oldRefundCtrl(bytes32 cntrllrs)
        external
        view
        returns (address payable)
    {
        return globalControllerStates[cntrllrs].refundController;
    }

    function oldDisputeCtrl(bytes32 cntrllrs)
        external
        view
        returns (address payable)
    {
        return globalControllerStates[cntrllrs].disputeController;
    }

    function oldUtilityCtrl(bytes32 cntrllrs)
        external
        view
        returns (address payable)
    {
        return globalControllerStates[cntrllrs].utilityController;
    }

    function getIsNetworkDeployed() external view returns (bool) {
        return isNetworkDeployed;
    }

    function getMinInvestorContribution() external view returns (uint256) {
        return minInvestorContribution;
    }

    function getMaxInvestorContribution() external view returns (uint256) {
        return maxInvestorContribution;
    }

    function getNumberOfInvestors() external view returns (uint256) {
        return investors.length;
    }

    function getNumberOfInvestments() external view returns (uint256) {
        return insurance.length;
    }

    function getMinProtectionPercentage() external view returns (uint256) {
        return minProtectionPercentage;
    }

    function getMaxProtectionPercentage() external view returns (uint256) {
        return maxProtectionPercentage;
    }

    function getMinOwnerContribution() external view returns (uint256)
    {
        return minOwnerContribution;
    }

    function getDefaultPolicyDuration() external view returns (uint256) {
        return policyDuration;
    }

    function getDefaultBasePolicyDuration() external view returns (uint256) {
        return basePolicyDuration;
    }

    function getRegularContributionPercentage() external view returns (uint256) {
        return regularContributionPercentage;
    }

    function getInsuranceControllerState(uint256 insId) external view returns(bytes32) {
        return insurance[insId].controllerState;
    }

    function getPoolContribution(uint256 insId) external view returns (uint256) {
        return insurance[insId].poolContribution;
    }

    function getInsuranceRate(uint256 insId) external view returns (uint256) {
        return insurance[insId].insuranceRate;
    }

    function isCanceled(uint256 insId) external view returns (bool) {
        return insurance[insId].isCanceled;
    }

    function getProjectOfInvestment(uint256 insId)
        external
        view
        returns (uint256 projectId)
    {
        return insurance[insId].projectId;
    }

    function getEtherSecured(uint256 insId) external view returns (uint256) {
        return insurance[insId].etherSecured;
    }

    function getInsuranceOwner(uint256 insId) external view returns (address) {
        return insurance[insId].investmentOwner;
    }

    function getTimeOfTheRequest(uint256 insId) external view returns (uint256) {
        return insurance[insId].timeOfTheRequest;
    }

    function getVotedForARefund(uint256 insId) external view returns (bool) {
        return insurance[insId].votedForARefund;
    }

    function getVotedAfterFailedVoting(uint256 insId) external view returns (bool) {
        return insurance[insId].votedAfterFailedVoting;
    }

    function getIsRefunded(uint256 insId) external view returns (bool) {
        return insurance[insId].isRefunded;
    }

    function getDisputeProjectId(uint256 disputeId) external view returns (uint256) {
        return dispute[disputeId].pid;
    }

    function getDisputesOfProject(uint256 pid) external view returns (uint256[] memory disputeIds) {
        for (uint256 i = 0; i < dispute.length; i++) {
            uint256 ids;
            if (dispute[i].pid == pid) {
                disputeIds[ids] = pid;
                ids++;
            }
        }
        return disputeIds;
    }

    function getDisputeControllerOfProject(uint256 disputeId) external view returns (address) {
        return dispute[disputeId].disputeController;
    }

    function getDisputeVotePeriod(uint256 disputeId) external view returns (uint256) {
        return dispute[disputeId].disputeVotePeriod;
    }

    function getResultCountPeriod(uint256 disputeId) external view returns (uint256) {
        return dispute[disputeId].resultCountPeriod;
    }

    function getDisputeLotteryPrize(uint256 disputeId) external view returns (uint256 votingPrize) {
        return dispute[disputeId].votingPrize;
    }

    function getNumberOfVotesForRefundState(uint256 disputeId)
        external
        view
        onlyNetworkContracts
        returns (uint256)
    {
        return dispute[disputeId].numberOfVotesForRefundState;
    }

    function getNumberOfVotesAgainstRefundState(uint256 disputeId)
		external
		view
		onlyNetworkContracts
		returns (uint256)
	{
        return dispute[disputeId].numberOfVotesAgainstRefundState;
    }

    function getEntryFee(uint256 disputeId) external view returns (uint256) {
        return dispute[disputeId].entryFee;
    }

    function getDisputeCreator(uint256 disputeId) external view returns (address payable) {
        return dispute[disputeId].creator;
    }

    function getRandomNumberBaseLength(uint256 disputeId) external view returns (uint256) {
        return dispute[disputeId].numbers.length;
    }

    function getPublicDisputeURL(uint256 disputeId) external view returns (bytes memory) {
        return dispute[disputeId].publicDisputeUrl;
    }

    function getDisputeVoter(uint256 disputeId, uint256 voterId) external view returns (address payable) {
        return dispute[disputeId].voters[voterId];
    }

    function getDisputeNumberOfVoters(uint256 disputeId) external view returns (uint256) {
        return dispute[disputeId].voters.length;
    }

    function getHiddenVote(uint256 disputeId, address voter)
        external
        view
        onlyNetworkContracts
        returns (bytes32)
    {
        return dispute[disputeId].hiddenVote[voter];
    }

    function getRevealedVote(uint256 disputeId, address voter)
		    external
				view
				onlyNetworkContracts
				returns (bool) {
        return dispute[disputeId].revealedVote[voter];
    }

    function isVoteRevealed(uint256 disputeId, address voter)
        external
        view
        onlyNetworkContracts
        returns (bool)
    {
        for (uint256 i = 0; i < dispute[disputeId].voters.length; i++) {
            if (dispute[disputeId].voters[i] == voter) {
                return true;
            }
        }
        return false;
    }

    function getInvestorAddressByInsurance(uint256 insId) external view returns (address) {
        return insurance[insId].investmentOwner;
    }

    function getInvestorAddressById(uint256 investorId) external view returns (address) {
        return investors[investorId];
    }

    function getInvestorId(address investor) external view returns (uint256) {
        return investorData[investor].investorId;
    }

    function getAmountAvailableForWithdraw(address userAddr, uint256 pid) external view returns (uint256) {
        return investorData[userAddr].withdrawable[pid];
    }

    function getReferrer(address investor) external view returns (address) {
        return investorData[investor].referrer;
    }

    function isInvestor(address who) external view returns (bool) {
        return Investors.has(who);
    }

    function isPlatformModerator(address who) public view returns (bool) {
        return PlatformModerators.has(who);
    }

    function isCommunityModerator(address who) external view returns (bool) {
        return CommunityModerators.has(who);
    }

    function isProjectOwner(address who) external view returns (bool) {
        return ProjectOwners.has(who);
    }

    function isArbiter(address who) external view returns (bool) {
        return Arbiters.has(who);
    }

    function getPayment(address payee, uint256 did) external view returns (uint256) {
        return payment[payee][did];
    }

    function onlyInsuranceControllers(address caller, uint256 ins) external view returns (bool) {
        return _verifyInsuranceControllers(caller, ins);
    }

    function getValidationToken(address verificatedUser) external view returns (uint256) {
        return validationToken[verificatedUser];
    }

    function _updateControllersHash() internal returns (bytes32) {
        return controllersHash = keccak256(
            abi.encodePacked(
                projectController,
                refundController,
                disputeController,
                utilityController
        ));
    }

    function _verifyInsuranceControllers(address caller, uint256 ins) internal view returns (bool) {
        bytes32 ctrl = insurance[ins].controllerState;
        if (caller != globalControllerStates[ctrl].projectController &&
            caller != globalControllerStates[ctrl].refundController  &&
            caller != globalControllerStates[ctrl].disputeController &&
            caller != globalControllerStates[ctrl].utilityController) {
            return false;
        } else {
            return true;
        }
    }

    function _verifyDisputeController(uint256 disputeId) internal view {
        if (msg.sender != dispute[disputeId].disputeController) {
            revert("Invalid dispute controller");
        }
    }

    function _onlyDappContracts(address caller) internal view returns (bool) {
        if (isPlatformModerator(caller)) {
            return (isNetworkDeployed == false);
        } else {
            return(dAppContract[caller] != address(0));
        }
    }

    function allowOnlyDappContracts(address caller) external view returns (bool) {
        return _onlyDappContracts(caller);
    }


   /**
    *
    * Additional Amenable to evolution, extensible, flat key-value pair storage.
    * To be used for major dApp upgrades requiring additional data structures.
    *
    */

    mapping(bytes32 => uint256)         private uintStorage;
    mapping(bytes32 => address)         private addressStorage;
    mapping(bytes32 => bytes)           private bytesStorage;
    mapping(bytes32 => bool)            private boolStorage;
    mapping(bytes32 => string)          private stringStorage;
    mapping(bytes32 => int256)          private intStorage;
    mapping(bytes32 => address payable) private payableAddressStorage;

    function getAddress(bytes32 key) external view returns (address) {
        return addressStorage[key];
    }

    function getUint(bytes32 key) external view returns (uint) {
        return uintStorage[key];
    }

    function getBytes(bytes32 key) external view returns (bytes memory) {
        return bytesStorage[key];
    }

    function getBool(bytes32 key) external view returns (bool) {
        return boolStorage[key];
    }

    function getString(bytes32 key) external view returns (string memory) {
        return stringStorage[key];
    }

    function getInt(bytes32 key) external view returns (int) {
        return intStorage[key];
    }

    function getPayableAddress(bytes32 key) external view returns (address payable) {
        return payableAddressStorage[key];
    }

    function setAddress(bytes32 key, address value) external onlyNetworkContracts {
        addressStorage[key] = value;
    }

    function setUint(bytes32 key, uint value) external onlyNetworkContracts {
        uintStorage[key] = value;
    }

    function setBytes(bytes32 key, bytes calldata value) external onlyNetworkContracts {
        bytesStorage[key] = value;
    }

    function setBool(bytes32 key, bool value) external onlyNetworkContracts {
        boolStorage[key] = value;
    }

    function setString(bytes32 key, string calldata value) external onlyNetworkContracts {
        stringStorage[key] = value;
    }

    function setInt(bytes32 key, int value) external onlyNetworkContracts {
        intStorage[key] = value;
    }

    function setPayableAddress(bytes32 key, address payable value) external onlyNetworkContracts {
        payableAddressStorage[key] = value;
    }

    function deleteAddress(bytes32 key) external onlyNetworkContracts {
        delete addressStorage[key];
    }

    function deleteUint(bytes32 key) external onlyNetworkContracts {
        delete uintStorage[key];
    }

    function deleteString(bytes32 key) external onlyNetworkContracts {
        delete stringStorage[key];
    }

    function deleteBytes(bytes32 key) external onlyNetworkContracts {
        delete bytesStorage[key];
    }

    function deleteBool(bytes32 key) external onlyNetworkContracts {
        delete boolStorage[key];
    }

    function deleteInt(bytes32 key) external onlyNetworkContracts {
        delete intStorage[key];
    }

    function deletePayableAddress(bytes32 key) external onlyNetworkContracts {
        delete payableAddressStorage[key];
    }
}