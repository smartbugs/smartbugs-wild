pragma solidity ^0.4.18;

// File: contracts/libraries/PermissionsLib.sol

/*

  Copyright 2017 Dharma Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.18;


/**
 *  Note(kayvon): these events are emitted by our PermissionsLib, but all contracts that
 *  depend on the library must also define the events in order for web3 clients to pick them up.
 *  This topic is discussed in greater detail here (under the section "Events and Libraries"):
 *  https://blog.aragon.one/library-driven-development-in-solidity-2bebcaf88736
 */
contract PermissionEvents {
    event Authorized(address indexed agent, string callingContext);
    event AuthorizationRevoked(address indexed agent, string callingContext);
}


library PermissionsLib {

    // TODO(kayvon): remove these events and inherit from PermissionEvents when libraries are
    // capable of inheritance.
    // See relevant github issue here: https://github.com/ethereum/solidity/issues/891
    event Authorized(address indexed agent, string callingContext);
    event AuthorizationRevoked(address indexed agent, string callingContext);

    struct Permissions {
        mapping (address => bool) authorized;
        mapping (address => uint) agentToIndex; // ensures O(1) look-up
        address[] authorizedAgents;
    }

    function authorize(
        Permissions storage self,
        address agent,
        string callingContext
    )
        internal
    {
        require(isNotAuthorized(self, agent));

        self.authorized[agent] = true;
        self.authorizedAgents.push(agent);
        self.agentToIndex[agent] = self.authorizedAgents.length - 1;
        Authorized(agent, callingContext);
    }

    function revokeAuthorization(
        Permissions storage self,
        address agent,
        string callingContext
    )
        internal
    {
        /* We only want to do work in the case where the agent whose
        authorization is being revoked had authorization permissions in the
        first place. */
        require(isAuthorized(self, agent));

        uint indexOfAgentToRevoke = self.agentToIndex[agent];
        uint indexOfAgentToMove = self.authorizedAgents.length - 1;
        address agentToMove = self.authorizedAgents[indexOfAgentToMove];

        // Revoke the agent's authorization.
        delete self.authorized[agent];

        // Remove the agent from our collection of authorized agents.
        self.authorizedAgents[indexOfAgentToRevoke] = agentToMove;

        // Update our indices to reflect the above changes.
        self.agentToIndex[agentToMove] = indexOfAgentToRevoke;
        delete self.agentToIndex[agent];

        // Clean up memory that's no longer being used.
        delete self.authorizedAgents[indexOfAgentToMove];
        self.authorizedAgents.length -= 1;

        AuthorizationRevoked(agent, callingContext);
    }

    function isAuthorized(Permissions storage self, address agent)
        internal
        view
        returns (bool)
    {
        return self.authorized[agent];
    }

    function isNotAuthorized(Permissions storage self, address agent)
        internal
        view
        returns (bool)
    {
        return !isAuthorized(self, agent);
    }

    function getAuthorizedAgents(Permissions storage self)
        internal
        view
        returns (address[])
    {
        return self.authorizedAgents;
    }
}

// File: zeppelin-solidity/contracts/ownership/Ownable.sol

/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() public {
    owner = msg.sender;
  }

  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

// File: zeppelin-solidity/contracts/lifecycle/Pausable.sol

/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

// File: zeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, throws on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    if (a == 0) {
      return 0;
    }
    uint256 c = a * b;
    assert(c / a == b);
    return c;
  }

  /**
  * @dev Integer division of two numbers, truncating the quotient.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  /**
  * @dev Subtracts two numbers, throws on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  /**
  * @dev Adds two numbers, throws on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

// File: contracts/DebtRegistry.sol

/*

  Copyright 2017 Dharma Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.18;





/**
 * The DebtRegistry stores the parameters and beneficiaries of all debt agreements in
 * Dharma protocol.  It authorizes a limited number of agents to
 * perform mutations on it -- those agents can be changed at any
 * time by the contract's owner.
 *
 * Author: Nadav Hollander -- Github: nadavhollander
 */
contract DebtRegistry is Pausable, PermissionEvents {
    using SafeMath for uint;
    using PermissionsLib for PermissionsLib.Permissions;

    struct Entry {
        address version;
        address beneficiary;
        address underwriter;
        uint underwriterRiskRating;
        address termsContract;
        bytes32 termsContractParameters;
        uint issuanceBlockTimestamp;
    }

    // Primary registry mapping agreement IDs to their corresponding entries
    mapping (bytes32 => Entry) internal registry;

    // Maps debtor addresses to a list of their debts' agreement IDs
    mapping (address => bytes32[]) internal debtorToDebts;

    PermissionsLib.Permissions internal entryInsertPermissions;
    PermissionsLib.Permissions internal entryEditPermissions;

    string public constant INSERT_CONTEXT = "debt-registry-insert";
    string public constant EDIT_CONTEXT = "debt-registry-edit";

    event LogInsertEntry(
        bytes32 indexed agreementId,
        address indexed beneficiary,
        address indexed underwriter,
        uint underwriterRiskRating,
        address termsContract,
        bytes32 termsContractParameters
    );

    event LogModifyEntryBeneficiary(
        bytes32 indexed agreementId,
        address indexed previousBeneficiary,
        address indexed newBeneficiary
    );

    modifier onlyAuthorizedToInsert() {
        require(entryInsertPermissions.isAuthorized(msg.sender));
        _;
    }

    modifier onlyAuthorizedToEdit() {
        require(entryEditPermissions.isAuthorized(msg.sender));
        _;
    }

    modifier onlyExtantEntry(bytes32 agreementId) {
        require(doesEntryExist(agreementId));
        _;
    }

    modifier nonNullBeneficiary(address beneficiary) {
        require(beneficiary != address(0));
        _;
    }

    /* Ensures an entry with the specified agreement ID exists within the debt registry. */
    function doesEntryExist(bytes32 agreementId)
        public
        view
        returns (bool exists)
    {
        return registry[agreementId].beneficiary != address(0);
    }

    /**
     * Inserts a new entry into the registry, if the entry is valid and sender is
     * authorized to make 'insert' mutations to the registry.
     */
    function insert(
        address _version,
        address _beneficiary,
        address _debtor,
        address _underwriter,
        uint _underwriterRiskRating,
        address _termsContract,
        bytes32 _termsContractParameters,
        uint _salt
    )
        public
        onlyAuthorizedToInsert
        whenNotPaused
        nonNullBeneficiary(_beneficiary)
        returns (bytes32 _agreementId)
    {
        Entry memory entry = Entry(
            _version,
            _beneficiary,
            _underwriter,
            _underwriterRiskRating,
            _termsContract,
            _termsContractParameters,
            block.timestamp
        );

        bytes32 agreementId = _getAgreementId(entry, _debtor, _salt);

        require(registry[agreementId].beneficiary == address(0));

        registry[agreementId] = entry;
        debtorToDebts[_debtor].push(agreementId);

        LogInsertEntry(
            agreementId,
            entry.beneficiary,
            entry.underwriter,
            entry.underwriterRiskRating,
            entry.termsContract,
            entry.termsContractParameters
        );

        return agreementId;
    }

    /**
     * Modifies the beneficiary of a debt issuance, if the sender
     * is authorized to make 'modifyBeneficiary' mutations to
     * the registry.
     */
    function modifyBeneficiary(bytes32 agreementId, address newBeneficiary)
        public
        onlyAuthorizedToEdit
        whenNotPaused
        onlyExtantEntry(agreementId)
        nonNullBeneficiary(newBeneficiary)
    {
        address previousBeneficiary = registry[agreementId].beneficiary;

        registry[agreementId].beneficiary = newBeneficiary;

        LogModifyEntryBeneficiary(
            agreementId,
            previousBeneficiary,
            newBeneficiary
        );
    }

    /**
     * Adds an address to the list of agents authorized
     * to make 'insert' mutations to the registry.
     */
    function addAuthorizedInsertAgent(address agent)
        public
        onlyOwner
    {
        entryInsertPermissions.authorize(agent, INSERT_CONTEXT);
    }

    /**
     * Adds an address to the list of agents authorized
     * to make 'modifyBeneficiary' mutations to the registry.
     */
    function addAuthorizedEditAgent(address agent)
        public
        onlyOwner
    {
        entryEditPermissions.authorize(agent, EDIT_CONTEXT);
    }

    /**
     * Removes an address from the list of agents authorized
     * to make 'insert' mutations to the registry.
     */
    function revokeInsertAgentAuthorization(address agent)
        public
        onlyOwner
    {
        entryInsertPermissions.revokeAuthorization(agent, INSERT_CONTEXT);
    }

    /**
     * Removes an address from the list of agents authorized
     * to make 'modifyBeneficiary' mutations to the registry.
     */
    function revokeEditAgentAuthorization(address agent)
        public
        onlyOwner
    {
        entryEditPermissions.revokeAuthorization(agent, EDIT_CONTEXT);
    }

    /**
     * Returns the parameters of a debt issuance in the registry.
     *
     * TODO(kayvon): protect this function with our `onlyExtantEntry` modifier once the restriction
     * on the size of the call stack has been addressed.
     */
    function get(bytes32 agreementId)
        public
        view
        returns(address, address, address, uint, address, bytes32, uint)
    {
        return (
            registry[agreementId].version,
            registry[agreementId].beneficiary,
            registry[agreementId].underwriter,
            registry[agreementId].underwriterRiskRating,
            registry[agreementId].termsContract,
            registry[agreementId].termsContractParameters,
            registry[agreementId].issuanceBlockTimestamp
        );
    }

    /**
     * Returns the beneficiary of a given issuance
     */
    function getBeneficiary(bytes32 agreementId)
        public
        view
        onlyExtantEntry(agreementId)
        returns(address)
    {
        return registry[agreementId].beneficiary;
    }

    /**
     * Returns the terms contract address of a given issuance
     */
    function getTermsContract(bytes32 agreementId)
        public
        view
        onlyExtantEntry(agreementId)
        returns (address)
    {
        return registry[agreementId].termsContract;
    }

    /**
     * Returns the terms contract parameters of a given issuance
     */
    function getTermsContractParameters(bytes32 agreementId)
        public
        view
        onlyExtantEntry(agreementId)
        returns (bytes32)
    {
        return registry[agreementId].termsContractParameters;
    }

    /**
     * Returns a tuple of the terms contract and its associated parameters
     * for a given issuance
     */
    function getTerms(bytes32 agreementId)
        public
        view
        onlyExtantEntry(agreementId)
        returns(address, bytes32)
    {
        return (
            registry[agreementId].termsContract,
            registry[agreementId].termsContractParameters
        );
    }

    /**
     * Returns the timestamp of the block at which a debt agreement was issued.
     */
    function getIssuanceBlockTimestamp(bytes32 agreementId)
        public
        view
        onlyExtantEntry(agreementId)
        returns (uint timestamp)
    {
        return registry[agreementId].issuanceBlockTimestamp;
    }

    /**
     * Returns the list of agents authorized to make 'insert' mutations
     */
    function getAuthorizedInsertAgents()
        public
        view
        returns(address[])
    {
        return entryInsertPermissions.getAuthorizedAgents();
    }

    /**
     * Returns the list of agents authorized to make 'modifyBeneficiary' mutations
     */
    function getAuthorizedEditAgents()
        public
        view
        returns(address[])
    {
        return entryEditPermissions.getAuthorizedAgents();
    }

    /**
     * Returns the list of debt agreements a debtor is party to,
     * with each debt agreement listed by agreement ID.
     */
    function getDebtorsDebts(address debtor)
        public
        view
        returns(bytes32[])
    {
        return debtorToDebts[debtor];
    }

    /**
     * Helper function for computing the hash of a given issuance,
     * and, in turn, its agreementId
     */
    function _getAgreementId(Entry _entry, address _debtor, uint _salt)
        internal
        pure
        returns(bytes32)
    {
        return keccak256(
            _entry.version,
            _debtor,
            _entry.underwriter,
            _entry.underwriterRiskRating,
            _entry.termsContract,
            _entry.termsContractParameters,
            _salt
        );
    }
}

// File: contracts/TermsContract.sol

/*

  Copyright 2017 Dharma Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.18;


interface TermsContract {
     /// When called, the registerTermStart function registers the fact that
     ///    the debt agreement has begun.  This method is called as a hook by the
     ///    DebtKernel when a debt order associated with `agreementId` is filled.
     ///    Method is not required to make any sort of internal state change
     ///    upon the debt agreement's start, but MUST return `true` in order to
     ///    acknowledge receipt of the transaction.  If, for any reason, the
     ///    debt agreement stored at `agreementId` is incompatible with this contract,
     ///    MUST return `false`, which will cause the pertinent order fill to fail.
     ///    If this method is called for a debt agreement whose term has already begun,
     ///    must THROW.  Similarly, if this method is called by any contract other
     ///    than the current DebtKernel, must THROW.
     /// @param  agreementId bytes32. The agreement id (issuance hash) of the debt agreement to which this pertains.
     /// @param  debtor address. The debtor in this particular issuance.
     /// @return _success bool. Acknowledgment of whether
    function registerTermStart(
        bytes32 agreementId,
        address debtor
    ) public returns (bool _success);

     /// When called, the registerRepayment function records the debtor's
     ///  repayment, as well as any auxiliary metadata needed by the contract
     ///  to determine ex post facto the value repaid (e.g. current USD
     ///  exchange rate)
     /// @param  agreementId bytes32. The agreement id (issuance hash) of the debt agreement to which this pertains.
     /// @param  payer address. The address of the payer.
     /// @param  beneficiary address. The address of the payment's beneficiary.
     /// @param  unitsOfRepayment uint. The units-of-value repaid in the transaction.
     /// @param  tokenAddress address. The address of the token with which the repayment transaction was executed.
    function registerRepayment(
        bytes32 agreementId,
        address payer,
        address beneficiary,
        uint256 unitsOfRepayment,
        address tokenAddress
    ) public returns (bool _success);

     /// Returns the cumulative units-of-value expected to be repaid by a given block timestamp.
     ///  Note this is not a constant function -- this value can vary on basis of any number of
     ///  conditions (e.g. interest rates can be renegotiated if repayments are delinquent).
     /// @param  agreementId bytes32. The agreement id (issuance hash) of the debt agreement to which this pertains.
     /// @param  timestamp uint. The timestamp of the block for which repayment expectation is being queried.
     /// @return uint256 The cumulative units-of-value expected to be repaid by the time the given timestamp lapses.
    function getExpectedRepaymentValue(
        bytes32 agreementId,
        uint256 timestamp
    ) public view returns (uint256);

     /// Returns the cumulative units-of-value repaid by the point at which this method is called.
     /// @param  agreementId bytes32. The agreement id (issuance hash) of the debt agreement to which this pertains.
     /// @return uint256 The cumulative units-of-value repaid up until now.
    function getValueRepaidToDate(
        bytes32 agreementId
    ) public view returns (uint256);

    /**
     * A method that returns a Unix timestamp representing the end of the debt agreement's term.
     * contract.
     */
    function getTermEndTimestamp(
        bytes32 _agreementId
    ) public view returns (uint);
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20Basic.sol

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  function totalSupply() public view returns (uint256);
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

// File: zeppelin-solidity/contracts/token/ERC20/ERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public view returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

// File: contracts/TokenTransferProxy.sol

/*

  Copyright 2017 Dharma Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.18;






/**
 * The TokenTransferProxy is a proxy contract for transfering principal
 * and fee payments and repayments between agents and keepers in the Dharma
 * ecosystem.  It is decoupled from the DebtKernel in order to make upgrades to the
 * protocol contracts smoother -- if the DebtKernel or RepyamentRouter is upgraded to a new contract,
 * creditors will not have to grant new transfer approvals to a new contract's address.
 *
 * Author: Nadav Hollander -- Github: nadavhollander
 */
contract TokenTransferProxy is Pausable, PermissionEvents {
    using PermissionsLib for PermissionsLib.Permissions;

    PermissionsLib.Permissions internal tokenTransferPermissions;

    string public constant CONTEXT = "token-transfer-proxy";

    /**
     * Add address to list of agents authorized to initiate `transferFrom` calls
     */
    function addAuthorizedTransferAgent(address _agent)
        public
        onlyOwner
    {
        tokenTransferPermissions.authorize(_agent, CONTEXT);
    }

    /**
     * Remove address from list of agents authorized to initiate `transferFrom` calls
     */
    function revokeTransferAgentAuthorization(address _agent)
        public
        onlyOwner
    {
        tokenTransferPermissions.revokeAuthorization(_agent, CONTEXT);
    }

    /**
     * Return list of agents authorized to initiate `transferFrom` calls
     */
    function getAuthorizedTransferAgents()
        public
        view
        returns (address[] authorizedAgents)
    {
        return tokenTransferPermissions.getAuthorizedAgents();
    }

    /**
     * Transfer specified token amount from _from address to _to address on give token
     */
    function transferFrom(
        address _token,
        address _from,
        address _to,
        uint _amount
    )
        public
        returns (bool _success)
    {
        require(tokenTransferPermissions.isAuthorized(msg.sender));

        return ERC20(_token).transferFrom(_from, _to, _amount);
    }
}

// File: contracts/RepaymentRouter.sol

/*

  Copyright 2017 Dharma Labs Inc.

  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.

*/

pragma solidity 0.4.18;







/**
 * The RepaymentRouter routes allowers payers to make repayments on any
 * given debt agreement in any given token by routing the payments to
 * the debt agreement's beneficiary.  Additionally, the router acts
 * as a trusted oracle to the debt agreement's terms contract, informing
 * it of exactly what payments have been made in what quantity and in what token.
 *
 * Authors: Jaynti Kanani -- Github: jdkanani, Nadav Hollander -- Github: nadavhollander
 */
contract RepaymentRouter is Pausable {
    DebtRegistry public debtRegistry;
    TokenTransferProxy public tokenTransferProxy;

    enum Errors {
        DEBT_AGREEMENT_NONEXISTENT,
        PAYER_BALANCE_OR_ALLOWANCE_INSUFFICIENT,
        REPAYMENT_REJECTED_BY_TERMS_CONTRACT
    }

    event LogRepayment(
        bytes32 indexed _agreementId,
        address indexed _payer,
        address indexed _beneficiary,
        uint _amount,
        address _token
    );

    event LogError(uint8 indexed _errorId, bytes32 indexed _agreementId);

    /**
     * Constructor points the repayment router at the deployed registry contract.
     */
    function RepaymentRouter (address _debtRegistry, address _tokenTransferProxy) public {
        debtRegistry = DebtRegistry(_debtRegistry);
        tokenTransferProxy = TokenTransferProxy(_tokenTransferProxy);
    }

    /**
     * Given an agreement id, routes a repayment
     * of a given ERC20 token to the debt's current beneficiary, and reports the repayment
     * to the debt's associated terms contract.
     */
    function repay(
        bytes32 agreementId,
        uint256 amount,
        address tokenAddress
    )
        public
        whenNotPaused
        returns (uint _amountRepaid)
    {
        require(tokenAddress != address(0));
        require(amount > 0);

        // Ensure agreement exists.
        if (!debtRegistry.doesEntryExist(agreementId)) {
            LogError(uint8(Errors.DEBT_AGREEMENT_NONEXISTENT), agreementId);
            return 0;
        }

        // Check payer has sufficient balance and has granted router sufficient allowance.
        if (ERC20(tokenAddress).balanceOf(msg.sender) < amount ||
            ERC20(tokenAddress).allowance(msg.sender, tokenTransferProxy) < amount) {
            LogError(uint8(Errors.PAYER_BALANCE_OR_ALLOWANCE_INSUFFICIENT), agreementId);
            return 0;
        }

        // Notify terms contract
        address termsContract = debtRegistry.getTermsContract(agreementId);
        address beneficiary = debtRegistry.getBeneficiary(agreementId);
        if (!TermsContract(termsContract).registerRepayment(
            agreementId,
            msg.sender,
            beneficiary,
            amount,
            tokenAddress
        )) {
            LogError(uint8(Errors.REPAYMENT_REJECTED_BY_TERMS_CONTRACT), agreementId);
            return 0;
        }

        // Transfer amount to creditor
        require(tokenTransferProxy.transferFrom(
            tokenAddress,
            msg.sender,
            beneficiary,
            amount
        ));

        // Log event for repayment
        LogRepayment(agreementId, msg.sender, beneficiary, amount, tokenAddress);

        return amount;
    }
}