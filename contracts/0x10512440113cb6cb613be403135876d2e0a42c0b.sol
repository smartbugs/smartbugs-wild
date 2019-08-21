pragma solidity 0.4.18;

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

// File: contracts/TokenRegistry.sol

/**
 * The TokenRegistry is a basic registry mapping token symbols
 * to their known, deployed addresses on the current blockchain.
 *
 * Note that the TokenRegistry does *not* mediate any of the
 * core protocol's business logic, but, rather, is a helpful
 * utility for Terms Contracts to use in encoding, decoding, and
 * resolving the addresses of currently deployed tokens.
 *
 * At this point in time, administration of the Token Registry is
 * under Dharma Labs' control.  With more sophisticated decentralized
 * governance mechanisms, we intend to shift ownership of this utility
 * contract to the Dharma community.
 */
contract TokenRegistry is Ownable {
    mapping (bytes32 => TokenAttributes) public symbolHashToTokenAttributes;
    string[256] public tokenSymbolList;
    uint8 public tokenSymbolListLength;

    struct TokenAttributes {
        // The ERC20 contract address.
        address tokenAddress;
        // The index in `tokenSymbolList` where the token's symbol can be found.
        uint tokenIndex;
        // The name of the given token, e.g. "Canonical Wrapped Ether"
        string name;
        // The number of digits that come after the decimal place when displaying token value.
        uint8 numDecimals;
    }

    /**
     * Maps the given symbol to the given token attributes.
     */
    function setTokenAttributes(
        string _symbol,
        address _tokenAddress,
        string _tokenName,
        uint8 _numDecimals
    )
        public onlyOwner
    {
        bytes32 symbolHash = keccak256(_symbol);

        // Attempt to retrieve the token's attributes from the registry.
        TokenAttributes memory attributes = symbolHashToTokenAttributes[symbolHash];

        if (attributes.tokenAddress == address(0)) {
            // The token has not yet been added to the registry.
            attributes.tokenAddress = _tokenAddress;
            attributes.numDecimals = _numDecimals;
            attributes.name = _tokenName;
            attributes.tokenIndex = tokenSymbolListLength;

            tokenSymbolList[tokenSymbolListLength] = _symbol;
            tokenSymbolListLength++;
        } else {
            // The token has already been added to the registry; update attributes.
            attributes.tokenAddress = _tokenAddress;
            attributes.numDecimals = _numDecimals;
            attributes.name = _tokenName;
        }

        // Update this contract's storage.
        symbolHashToTokenAttributes[symbolHash] = attributes;
    }

    /**
     * Given a symbol, resolves the current address of the token the symbol is mapped to.
     */
    function getTokenAddressBySymbol(string _symbol) public view returns (address) {
        bytes32 symbolHash = keccak256(_symbol);

        TokenAttributes storage attributes = symbolHashToTokenAttributes[symbolHash];

        return attributes.tokenAddress;
    }

    /**
     * Given the known index of a token within the registry's symbol list,
     * returns the address of the token mapped to the symbol at that index.
     *
     * This is a useful utility for compactly encoding the address of a token into a
     * TermsContractParameters string -- by encoding a token by its index in a
     * a 256 slot array, we can represent a token by a 1 byte uint instead of a 20 byte address.
     */
    function getTokenAddressByIndex(uint _index) public view returns (address) {
        string storage symbol = tokenSymbolList[_index];

        return getTokenAddressBySymbol(symbol);
    }

    /**
     * Given a symbol, resolves the index of the token the symbol is mapped to within the registry's
     * symbol list.
     */
    function getTokenIndexBySymbol(string _symbol) public view returns (uint) {
        bytes32 symbolHash = keccak256(_symbol);

        TokenAttributes storage attributes = symbolHashToTokenAttributes[symbolHash];

        return attributes.tokenIndex;
    }

    /**
     * Given an index, resolves the symbol of the token at that index in the registry's
     * token symbol list.
     */
    function getTokenSymbolByIndex(uint _index) public view returns (string) {
        return tokenSymbolList[_index];
    }

    /**
     * Given a symbol, returns the name of the token the symbol is mapped to within the registry's
     * symbol list.
     */
    function getTokenNameBySymbol(string _symbol) public view returns (string) {
        bytes32 symbolHash = keccak256(_symbol);

        TokenAttributes storage attributes = symbolHashToTokenAttributes[symbolHash];

        return attributes.name;
    }

    /**
     * Given the symbol for a token, returns the number of decimals as provided in
     * the associated TokensAttribute struct.
     *
     * Example:
     *   getNumDecimalsFromSymbol("REP");
     *   => 18
     */
    function getNumDecimalsFromSymbol(string _symbol) public view returns (uint8) {
        bytes32 symbolHash = keccak256(_symbol);

        TokenAttributes storage attributes = symbolHashToTokenAttributes[symbolHash];

        return attributes.numDecimals;
    }

    /**
     * Given the index for a token in the registry, returns the number of decimals as provided in
     * the associated TokensAttribute struct.
     *
     * Example:
     *   getNumDecimalsByIndex(1);
     *   => 18
     */
    function getNumDecimalsByIndex(uint _index) public view returns (uint8) {
        string memory symbol = getTokenSymbolByIndex(_index);

        return getNumDecimalsFromSymbol(symbol);
    }

    /**
     * Given the index for a token in the registry, returns the name of the token as provided in
     * the associated TokensAttribute struct.
     *
     * Example:
     *   getTokenNameByIndex(1);
     *   => "Canonical Wrapped Ether"
     */
    function getTokenNameByIndex(uint _index) public view returns (string) {
        string memory symbol = getTokenSymbolByIndex(_index);

        string memory tokenName = getTokenNameBySymbol(symbol);

        return tokenName;
    }

    /**
     * Given the symbol for a token in the registry, returns a tuple containing the token's address,
     * the token's index in the registry, the token's name, and the number of decimals.
     *
     * Example:
     *   getTokenAttributesBySymbol("WETH");
     *   => ["0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2", 1, "Canonical Wrapped Ether", 18]
     */
    function getTokenAttributesBySymbol(string _symbol)
        public
        view
        returns (
            address,
            uint,
            string,
            uint
        )
    {
        bytes32 symbolHash = keccak256(_symbol);

        TokenAttributes storage attributes = symbolHashToTokenAttributes[symbolHash];

        return (
            attributes.tokenAddress,
            attributes.tokenIndex,
            attributes.name,
            attributes.numDecimals
        );
    }

    /**
     * Given the index for a token in the registry, returns a tuple containing the token's address,
     * the token's symbol, the token's name, and the number of decimals.
     *
     * Example:
     *   getTokenAttributesByIndex(1);
     *   => ["0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2", "WETH", "Canonical Wrapped Ether", 18]
     */
    function getTokenAttributesByIndex(uint _index)
        public
        view
        returns (
            address,
            string,
            string,
            uint8
        )
    {
        string memory symbol = getTokenSymbolByIndex(_index);

        bytes32 symbolHash = keccak256(symbol);

        TokenAttributes storage attributes = symbolHashToTokenAttributes[symbolHash];

        return (
            attributes.tokenAddress,
            symbol,
            attributes.name,
            attributes.numDecimals
        );
    }
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

// File: contracts/Collateralizer.sol

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
  * Contains functionality for collateralizing assets, by transferring them from
  * a debtor address to this contract as a custodian.
  *
  * Authors (in no particular order): nadavhollander, saturnial, jdkanani, graemecode
  */
contract Collateralizer is Pausable, PermissionEvents {
    using PermissionsLib for PermissionsLib.Permissions;
    using SafeMath for uint;

    address public debtKernelAddress;

    DebtRegistry public debtRegistry;
    TokenRegistry public tokenRegistry;
    TokenTransferProxy public tokenTransferProxy;

    // Collateralizer here refers to the owner of the asset that is being collateralized.
    mapping(bytes32 => address) public agreementToCollateralizer;

    PermissionsLib.Permissions internal collateralizationPermissions;

    uint public constant SECONDS_IN_DAY = 24*60*60;

    string public constant CONTEXT = "collateralizer";

    event CollateralLocked(
        bytes32 indexed agreementID,
        address indexed token,
        uint amount
    );

    event CollateralReturned(
        bytes32 indexed agreementID,
        address indexed collateralizer,
        address token,
        uint amount
    );

    event CollateralSeized(
        bytes32 indexed agreementID,
        address indexed beneficiary,
        address token,
        uint amount
    );

    modifier onlyAuthorizedToCollateralize() {
        require(collateralizationPermissions.isAuthorized(msg.sender));
        _;
    }

    function Collateralizer(
        address _debtKernel,
        address _debtRegistry,
        address _tokenRegistry,
        address _tokenTransferProxy
    ) public {
        debtKernelAddress = _debtKernel;
        debtRegistry = DebtRegistry(_debtRegistry);
        tokenRegistry = TokenRegistry(_tokenRegistry);
        tokenTransferProxy = TokenTransferProxy(_tokenTransferProxy);
    }

    /**
     * Transfers collateral from the debtor to the current contract, as custodian.
     *
     * @param agreementId bytes32 The debt agreement's ID
     * @param collateralizer address The owner of the asset being collateralized
     */
    function collateralize(
        bytes32 agreementId,
        address collateralizer
    )
        public
        onlyAuthorizedToCollateralize
        whenNotPaused
        returns (bool _success)
    {
        // The token in which collateral is denominated
        address collateralToken;
        // The amount being put up for collateral
        uint collateralAmount;
        // The number of days a debtor has after a debt enters default
        // before their collateral is eligible for seizure.
        uint gracePeriodInDays;
        // The terms contract according to which this asset is being collateralized.
        TermsContract termsContract;

        // Fetch all relevant collateralization parameters
        (
            collateralToken,
            collateralAmount,
            gracePeriodInDays,
            termsContract
        ) = retrieveCollateralParameters(agreementId);

        require(termsContract == msg.sender);
        require(collateralAmount > 0);
        require(collateralToken != address(0));

        /*
        Ensure that the agreement has not already been collateralized.

        If the agreement has already been collateralized, this check will fail
        because any valid collateralization must have some sort of valid
        address associated with it as a collateralizer.  Given that it is impossible
        to send transactions from address 0x0, this check will only fail
        when the agreement is already collateralized.
        */
        require(agreementToCollateralizer[agreementId] == address(0));

        ERC20 erc20token = ERC20(collateralToken);
        address custodian = address(this);

        /*
        The collateralizer must have sufficient balance equal to or greater
        than the amount being put up for collateral.
        */
        require(erc20token.balanceOf(collateralizer) >= collateralAmount);

        /*
        The proxy must have an allowance granted by the collateralizer equal
        to or greater than the amount being put up for collateral.
        */
        require(erc20token.allowance(collateralizer, tokenTransferProxy) >= collateralAmount);

        // store collaterallizer in mapping, effectively demarcating that the
        // agreement is now collateralized.
        agreementToCollateralizer[agreementId] = collateralizer;

        // the collateral must be successfully transferred to this contract, via a proxy.
        require(tokenTransferProxy.transferFrom(
            erc20token,
            collateralizer,
            custodian,
            collateralAmount
        ));

        // emit event that collateral has been secured.
        CollateralLocked(agreementId, collateralToken, collateralAmount);

        return true;
    }

    /**
     * Returns collateral to the debt agreement's original collateralizer
     * if and only if the debt agreement's term has lapsed and
     * the total expected repayment value has been repaid.
     *
     * @param agreementId bytes32 The debt agreement's ID
     */
    function returnCollateral(
        bytes32 agreementId
    )
        public
        whenNotPaused
    {
        // The token in which collateral is denominated
        address collateralToken;
        // The amount being put up for collateral
        uint collateralAmount;
        // The number of days a debtor has after a debt enters default
        // before their collateral is eligible for seizure.
        uint gracePeriodInDays;
        // The terms contract according to which this asset is being collateralized.
        TermsContract termsContract;

        // Fetch all relevant collateralization parameters.
        (
            collateralToken,
            collateralAmount,
            gracePeriodInDays,
            termsContract
        ) = retrieveCollateralParameters(agreementId);

        // Ensure a valid form of collateral is tied to this agreement id
        require(collateralAmount > 0);
        require(collateralToken != address(0));

        // Withdrawal can only occur if the collateral has yet to be withdrawn.
        // When we withdraw collateral, we reset the collateral agreement
        // in a gas-efficient manner by resetting the address of the collateralizer to 0
        require(agreementToCollateralizer[agreementId] != address(0));

        // Ensure that the debt is not in a state of default
        require(
            termsContract.getExpectedRepaymentValue(
                agreementId,
                termsContract.getTermEndTimestamp(agreementId)
            ) <= termsContract.getValueRepaidToDate(agreementId)
        );

        // determine collateralizer of the collateral.
        address collateralizer = agreementToCollateralizer[agreementId];

        // Mark agreement's collateral as withdrawn by setting the agreement's
        // collateralizer to 0x0.
        delete agreementToCollateralizer[agreementId];

        // transfer the collateral this contract was holding in escrow back to collateralizer.
        require(
            ERC20(collateralToken).transfer(
                collateralizer,
                collateralAmount
            )
        );

        // log the return event.
        CollateralReturned(
            agreementId,
            collateralizer,
            collateralToken,
            collateralAmount
        );
    }

    /**
     * Seizes the collateral from the given debt agreement and
     * transfers it to the debt agreement's current beneficiary
     * (i.e. the person who "owns" the debt).
     *
     * @param agreementId bytes32 The debt agreement's ID
     */
    function seizeCollateral(
        bytes32 agreementId
    )
        public
        whenNotPaused
    {

        // The token in which collateral is denominated
        address collateralToken;
        // The amount being put up for collateral
        uint collateralAmount;
        // The number of days a debtor has after a debt enters default
        // before their collateral is eligible for seizure.
        uint gracePeriodInDays;
        // The terms contract according to which this asset is being collateralized.
        TermsContract termsContract;

        // Fetch all relevant collateralization parameters
        (
            collateralToken,
            collateralAmount,
            gracePeriodInDays,
            termsContract
        ) = retrieveCollateralParameters(agreementId);

        // Ensure a valid form of collateral is tied to this agreement id
        require(collateralAmount > 0);
        require(collateralToken != address(0));

        // Seizure can only occur if the collateral has yet to be withdrawn.
        // When we withdraw collateral, we reset the collateral agreement
        // in a gas-efficient manner by resetting the address of the collateralizer to 0
        require(agreementToCollateralizer[agreementId] != address(0));

        // Ensure debt is in a state of default when we account for the
        // specified "grace period".  We do this by checking whether the
        // *current* value repaid to-date exceeds the expected repayment value
        // at the point of time at which the grace period would begin if it ended
        // now.  This crucially relies on the assumption that both expected repayment value
        /// and value repaid to date monotonically increase over time
        require(
            termsContract.getExpectedRepaymentValue(
                agreementId,
                timestampAdjustedForGracePeriod(gracePeriodInDays)
            ) > termsContract.getValueRepaidToDate(agreementId)
        );

        // Mark agreement's collateral as withdrawn by setting the agreement's
        // collateralizer to 0x0.
        delete agreementToCollateralizer[agreementId];

        // determine beneficiary of the seized collateral.
        address beneficiary = debtRegistry.getBeneficiary(agreementId);

        // transfer the collateral this contract was holding in escrow to beneficiary.
        require(
            ERC20(collateralToken).transfer(
                beneficiary,
                collateralAmount
            )
        );

        // log the seizure event.
        CollateralSeized(
            agreementId,
            beneficiary,
            collateralToken,
            collateralAmount
        );
    }

    /**
     * Adds an address to the list of agents authorized
     * to invoke the `collateralize` function.
     */
    function addAuthorizedCollateralizeAgent(address agent)
        public
        onlyOwner
    {
        collateralizationPermissions.authorize(agent, CONTEXT);
    }

    /**
     * Removes an address from the list of agents authorized
     * to invoke the `collateralize` function.
     */
    function revokeCollateralizeAuthorization(address agent)
        public
        onlyOwner
    {
        collateralizationPermissions.revokeAuthorization(agent, CONTEXT);
    }

    /**
    * Returns the list of agents authorized to invoke the 'collateralize' function.
    */
    function getAuthorizedCollateralizeAgents()
        public
        view
        returns(address[])
    {
        return collateralizationPermissions.getAuthorizedAgents();
    }

    /**
     * Unpacks collateralization-specific parameters from their tightly-packed
     * representation in a terms contract parameter string.
     *
     * For collateralized terms contracts, we reserve the lowest order 108 bits
     * of the terms contract parameters for parameters relevant to collateralization.
     *
     * Contracts that inherit from the Collateralized terms contract
     * can encode whichever parameter schema they please in the remaining
     * space of the terms contract parameters.
     * The 108 bits are encoded as follows (from higher order bits to lower order bits):
     *
     * 8 bits - Collateral Token (encoded by its unsigned integer index in the TokenRegistry contract)
     * 92 bits - Collateral Amount (encoded as an unsigned integer)
     * 8 bits - Grace Period* Length (encoded as an unsigned integer)
     *
     * * = The "Grace" Period is the number of days a debtor has between
     *      when they fall behind on an expected payment and when their collateral
     *      can be seized by the creditor.
     */
    function unpackCollateralParametersFromBytes(bytes32 parameters)
        public
        pure
        returns (uint, uint, uint)
    {
        // The first byte of the 108 reserved bits represents the collateral token.
        bytes32 collateralTokenIndexShifted =
            parameters & 0x0000000000000000000000000000000000000ff0000000000000000000000000;
        // The subsequent 92 bits represents the collateral amount, as denominated in the above token.
        bytes32 collateralAmountShifted =
            parameters & 0x000000000000000000000000000000000000000fffffffffffffffffffffff00;

        // We bit-shift these values, respectively, 100 bits and 8 bits right using
        // mathematical operations, so that their 32 byte integer counterparts
        // correspond to the intended values packed in the 32 byte string
        uint collateralTokenIndex = uint(collateralTokenIndexShifted) / 2 ** 100;
        uint collateralAmount = uint(collateralAmountShifted) / 2 ** 8;

        // The last byte of the parameters represents the "grace period" of the loan,
        // as defined in terms of days.
        // Since this value takes the rightmost place in the parameters string,
        // we do not need to bit-shift it.
        bytes32 gracePeriodInDays =
            parameters & 0x00000000000000000000000000000000000000000000000000000000000000ff;

        return (
            collateralTokenIndex,
            collateralAmount,
            uint(gracePeriodInDays)
        );
    }

    function timestampAdjustedForGracePeriod(uint gracePeriodInDays)
        public
        view
        returns (uint)
    {
        return block.timestamp.sub(
            SECONDS_IN_DAY.mul(gracePeriodInDays)
        );
    }

    function retrieveCollateralParameters(bytes32 agreementId)
        internal
        view
        returns (
            address _collateralToken,
            uint _collateralAmount,
            uint _gracePeriodInDays,
            TermsContract _termsContract
        )
    {
        address termsContractAddress;
        bytes32 termsContractParameters;

        // Pull the terms contract and associated parameters for the agreement
        (termsContractAddress, termsContractParameters) = debtRegistry.getTerms(agreementId);

        uint collateralTokenIndex;
        uint collateralAmount;
        uint gracePeriodInDays;

        // Unpack terms contract parameters in order to get collateralization-specific params
        (
            collateralTokenIndex,
            collateralAmount,
            gracePeriodInDays
        ) = unpackCollateralParametersFromBytes(termsContractParameters);

        // Resolve address of token associated with this agreement in token registry
        address collateralTokenAddress = tokenRegistry.getTokenAddressByIndex(collateralTokenIndex);

        return (
            collateralTokenAddress,
            collateralAmount,
            gracePeriodInDays,
            TermsContract(termsContractAddress)
        );
    }
}

// File: contracts/ERC165.sol

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
 * ERC165 interface required by ERC721 non-fungible token.
 *
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 * https://github.com/ethereum/EIPs/blob/master/EIPS/eip-165.md
 */
interface ERC165 {
    /// @notice Query if a contract implements an interface
    /// @param interfaceID The interface identifier, as specified in ERC-165
    /// @dev Interface identification is specified in ERC-165. This function
    ///  uses less than 30,000 gas.
    /// @return `true` if the contract implements `interfaceID` and
    ///  `interfaceID` is not 0xffffffff, `false` otherwise
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}

// File: zeppelin-solidity/contracts/token/ERC721/ERC721Basic.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic interface
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Basic {
  event Transfer(address indexed _from, address indexed _to, uint256 _tokenId);
  event Approval(address indexed _owner, address indexed _approved, uint256 _tokenId);
  event ApprovalForAll(address indexed _owner, address indexed _operator, bool _approved);  

  function balanceOf(address _owner) public view returns (uint256 _balance);
  function ownerOf(uint256 _tokenId) public view returns (address _owner);
  function exists(uint256 _tokenId) public view returns (bool _exists);
  
  function approve(address _to, uint256 _tokenId) public;
  function getApproved(uint256 _tokenId) public view returns (address _operator);
  
  function setApprovalForAll(address _operator, bool _approved) public;
  function isApprovedForAll(address _owner, address _operator) public view returns (bool);

  function transferFrom(address _from, address _to, uint256 _tokenId) public;
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public;  
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public;
}

// File: zeppelin-solidity/contracts/token/ERC721/ERC721.sol

/**
 * @title ERC-721 Non-Fungible Token Standard, optional enumeration extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Enumerable is ERC721Basic {
  function totalSupply() public view returns (uint256);
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256 _tokenId);
  function tokenByIndex(uint256 _index) public view returns (uint256);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, optional metadata extension
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Metadata is ERC721Basic {
  function name() public view returns (string _name);
  function symbol() public view returns (string _symbol);
  function tokenURI(uint256 _tokenId) public view returns (string);
}

/**
 * @title ERC-721 Non-Fungible Token Standard, full implementation interface
 * @dev See https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721 is ERC721Basic, ERC721Enumerable, ERC721Metadata {
}

// File: zeppelin-solidity/contracts/token/ERC721/DeprecatedERC721.sol

/**
 * @title ERC-721 methods shipped in OpenZeppelin v1.7.0, removed in the latest version of the standard
 * @dev Only use this interface for compatibility with previously deployed contracts
 * @dev Use ERC721 for interacting with new contracts which are standard-compliant
 */
contract DeprecatedERC721 is ERC721 {
  function takeOwnership(uint256 _tokenId) public;
  function transfer(address _to, uint256 _tokenId) public;
  function tokensOf(address _owner) public view returns (uint256[]);
}

// File: zeppelin-solidity/contracts/token/ERC721/ERC721Receiver.sol

/**
 * @title ERC721 token receiver interface
 * @dev Interface for any contract that wants to support safeTransfers
 *  from ERC721 asset contracts.
 */
contract ERC721Receiver {
  /**
   * @dev Magic value to be returned upon successful reception of an NFT
   *  Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`,
   *  which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
   */
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba; 

  /**
   * @notice Handle the receipt of an NFT
   * @dev The ERC721 smart contract calls this function on the recipient
   *  after a `safetransfer`. This function MAY throw to revert and reject the
   *  transfer. This function MUST use 50,000 gas or less. Return of other
   *  than the magic value MUST result in the transaction being reverted.
   *  Note: the contract address is always the message sender.
   * @param _from The sending address 
   * @param _tokenId The NFT identifier which is being transfered
   * @param _data Additional data with no specified format
   * @return `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
   */
  function onERC721Received(address _from, uint256 _tokenId, bytes _data) public returns(bytes4);
}

// File: zeppelin-solidity/contracts/AddressUtils.sol

/**
 * Utility library of inline functions on addresses
 */
library AddressUtils {

  /**
   * Returns whether there is code in the target address
   * @dev This function will return false if invoked during the constructor of a contract,
   *  as the code is not actually created until after the constructor finishes.
   * @param addr address address to check
   * @return whether there is code in the target address
   */
  function isContract(address addr) internal view returns (bool) {
    uint256 size;
    assembly { size := extcodesize(addr) }
    return size > 0;
  }

}

// File: zeppelin-solidity/contracts/token/ERC721/ERC721BasicToken.sol

/**
 * @title ERC721 Non-Fungible Token Standard basic implementation
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721BasicToken is ERC721Basic {
  using SafeMath for uint256;
  using AddressUtils for address;
  
  // Equals to `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`
  // which can be also obtained as `ERC721Receiver(0).onERC721Received.selector`
  bytes4 constant ERC721_RECEIVED = 0xf0b9e5ba; 

  // Mapping from token ID to owner
  mapping (uint256 => address) internal tokenOwner;

  // Mapping from token ID to approved address
  mapping (uint256 => address) internal tokenApprovals;

  // Mapping from owner to number of owned token
  mapping (address => uint256) internal ownedTokensCount;

  // Mapping from owner to operator approvals
  mapping (address => mapping (address => bool)) internal operatorApprovals;

  /**
  * @dev Guarantees msg.sender is owner of the given token
  * @param _tokenId uint256 ID of the token to validate its ownership belongs to msg.sender
  */
  modifier onlyOwnerOf(uint256 _tokenId) {
    require(ownerOf(_tokenId) == msg.sender);
    _;
  }

  /**
  * @dev Checks msg.sender can transfer a token, by being owner, approved, or operator
  * @param _tokenId uint256 ID of the token to validate
  */
  modifier canTransfer(uint256 _tokenId) {
    require(isApprovedOrOwner(msg.sender, _tokenId));
    _;
  }

  /**
  * @dev Gets the balance of the specified address
  * @param _owner address to query the balance of
  * @return uint256 representing the amount owned by the passed address
  */
  function balanceOf(address _owner) public view returns (uint256) {
    require(_owner != address(0));
    return ownedTokensCount[_owner];
  }

  /**
  * @dev Gets the owner of the specified token ID
  * @param _tokenId uint256 ID of the token to query the owner of
  * @return owner address currently marked as the owner of the given token ID
  */
  function ownerOf(uint256 _tokenId) public view returns (address) {
    address owner = tokenOwner[_tokenId];
    require(owner != address(0));
    return owner;
  }

  /**
  * @dev Returns whether the specified token exists
  * @param _tokenId uint256 ID of the token to query the existance of
  * @return whether the token exists
  */
  function exists(uint256 _tokenId) public view returns (bool) {
    address owner = tokenOwner[_tokenId];
    return owner != address(0);
  }

  /**
  * @dev Approves another address to transfer the given token ID
  * @dev The zero address indicates there is no approved address.
  * @dev There can only be one approved address per token at a given time.
  * @dev Can only be called by the token owner or an approved operator.
  * @param _to address to be approved for the given token ID
  * @param _tokenId uint256 ID of the token to be approved
  */
  function approve(address _to, uint256 _tokenId) public {
    address owner = ownerOf(_tokenId);
    require(_to != owner);
    require(msg.sender == owner || isApprovedForAll(owner, msg.sender));

    if (getApproved(_tokenId) != address(0) || _to != address(0)) {
      tokenApprovals[_tokenId] = _to;
      Approval(owner, _to, _tokenId);
    }
  }

  /**
   * @dev Gets the approved address for a token ID, or zero if no address set
   * @param _tokenId uint256 ID of the token to query the approval of
   * @return address currently approved for a the given token ID
   */
  function getApproved(uint256 _tokenId) public view returns (address) {
    return tokenApprovals[_tokenId];
  }


  /**
  * @dev Sets or unsets the approval of a given operator
  * @dev An operator is allowed to transfer all tokens of the sender on their behalf
  * @param _to operator address to set the approval
  * @param _approved representing the status of the approval to be set
  */
  function setApprovalForAll(address _to, bool _approved) public {
    require(_to != msg.sender);
    operatorApprovals[msg.sender][_to] = _approved;
    ApprovalForAll(msg.sender, _to, _approved);
  }

  /**
   * @dev Tells whether an operator is approved by a given owner
   * @param _owner owner address which you want to query the approval of
   * @param _operator operator address which you want to query the approval of
   * @return bool whether the given operator is approved by the given owner
   */
  function isApprovedForAll(address _owner, address _operator) public view returns (bool) {
    return operatorApprovals[_owner][_operator];
  }

  /**
  * @dev Transfers the ownership of a given token ID to another address
  * @dev Usage of this method is discouraged, use `safeTransferFrom` whenever possible
  * @dev Requires the msg sender to be the owner, approved, or operator
  * @param _from current owner of the token
  * @param _to address to receive the ownership of the given token ID
  * @param _tokenId uint256 ID of the token to be transferred
  */
  function transferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
    require(_from != address(0));
    require(_to != address(0));

    clearApproval(_from, _tokenId);
    removeTokenFrom(_from, _tokenId);
    addTokenTo(_to, _tokenId);
    
    Transfer(_from, _to, _tokenId);
  }

  /**
  * @dev Safely transfers the ownership of a given token ID to another address
  * @dev If the target address is a contract, it must implement `onERC721Received`,
  *  which is called upon a safe transfer, and return the magic value
  *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
  *  the transfer is reverted.
  * @dev Requires the msg sender to be the owner, approved, or operator
  * @param _from current owner of the token
  * @param _to address to receive the ownership of the given token ID
  * @param _tokenId uint256 ID of the token to be transferred
  */
  function safeTransferFrom(address _from, address _to, uint256 _tokenId) public canTransfer(_tokenId) {
    safeTransferFrom(_from, _to, _tokenId, "");
  }

  /**
  * @dev Safely transfers the ownership of a given token ID to another address
  * @dev If the target address is a contract, it must implement `onERC721Received`,
  *  which is called upon a safe transfer, and return the magic value
  *  `bytes4(keccak256("onERC721Received(address,uint256,bytes)"))`; otherwise,
  *  the transfer is reverted.
  * @dev Requires the msg sender to be the owner, approved, or operator
  * @param _from current owner of the token
  * @param _to address to receive the ownership of the given token ID
  * @param _tokenId uint256 ID of the token to be transferred
  * @param _data bytes data to send along with a safe transfer check
  */
  function safeTransferFrom(address _from, address _to, uint256 _tokenId, bytes _data) public canTransfer(_tokenId) {
    transferFrom(_from, _to, _tokenId);
    require(checkAndCallSafeTransfer(_from, _to, _tokenId, _data));
  }

  /**
   * @dev Returns whether the given spender can transfer a given token ID
   * @param _spender address of the spender to query
   * @param _tokenId uint256 ID of the token to be transferred
   * @return bool whether the msg.sender is approved for the given token ID,
   *  is an operator of the owner, or is the owner of the token
   */
  function isApprovedOrOwner(address _spender, uint256 _tokenId) internal view returns (bool) {
    address owner = ownerOf(_tokenId);
    return _spender == owner || getApproved(_tokenId) == _spender || isApprovedForAll(owner, _spender);
  }

  /**
  * @dev Internal function to mint a new token
  * @dev Reverts if the given token ID already exists
  * @param _to The address that will own the minted token
  * @param _tokenId uint256 ID of the token to be minted by the msg.sender
  */
  function _mint(address _to, uint256 _tokenId) internal {
    require(_to != address(0));
    addTokenTo(_to, _tokenId);
    Transfer(address(0), _to, _tokenId);
  }

  /**
  * @dev Internal function to burn a specific token
  * @dev Reverts if the token does not exist
  * @param _tokenId uint256 ID of the token being burned by the msg.sender
  */
  function _burn(address _owner, uint256 _tokenId) internal {
    clearApproval(_owner, _tokenId);
    removeTokenFrom(_owner, _tokenId);
    Transfer(_owner, address(0), _tokenId);
  }

  /**
  * @dev Internal function to clear current approval of a given token ID
  * @dev Reverts if the given address is not indeed the owner of the token
  * @param _owner owner of the token
  * @param _tokenId uint256 ID of the token to be transferred
  */
  function clearApproval(address _owner, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _owner);
    if (tokenApprovals[_tokenId] != address(0)) {
      tokenApprovals[_tokenId] = address(0);
      Approval(_owner, address(0), _tokenId);
    }
  }

  /**
  * @dev Internal function to add a token ID to the list of a given address
  * @param _to address representing the new owner of the given token ID
  * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
  */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    require(tokenOwner[_tokenId] == address(0));
    tokenOwner[_tokenId] = _to;
    ownedTokensCount[_to] = ownedTokensCount[_to].add(1);
  }

  /**
  * @dev Internal function to remove a token ID from the list of a given address
  * @param _from address representing the previous owner of the given token ID
  * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
  */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    require(ownerOf(_tokenId) == _from);
    ownedTokensCount[_from] = ownedTokensCount[_from].sub(1);
    tokenOwner[_tokenId] = address(0);
  }

  /**
  * @dev Internal function to invoke `onERC721Received` on a target address
  * @dev The call is not executed if the target address is not a contract
  * @param _from address representing the previous owner of the given token ID
  * @param _to target address that will receive the tokens
  * @param _tokenId uint256 ID of the token to be transferred
  * @param _data bytes optional data to send along with the call
  * @return whether the call correctly returned the expected magic value
  */
  function checkAndCallSafeTransfer(address _from, address _to, uint256 _tokenId, bytes _data) internal returns (bool) {
    if (!_to.isContract()) {
      return true;
    }
    bytes4 retval = ERC721Receiver(_to).onERC721Received(_from, _tokenId, _data);
    return (retval == ERC721_RECEIVED);
  }
}

// File: zeppelin-solidity/contracts/token/ERC721/ERC721Token.sol

/**
 * @title Full ERC721 Token
 * This implementation includes all the required and some optional functionality of the ERC721 standard
 * Moreover, it includes approve all functionality using operator terminology
 * @dev see https://github.com/ethereum/EIPs/blob/master/EIPS/eip-721.md
 */
contract ERC721Token is ERC721, ERC721BasicToken {
  // Token name
  string internal name_;

  // Token symbol
  string internal symbol_;

  // Mapping from owner to list of owned token IDs
  mapping (address => uint256[]) internal ownedTokens;

  // Mapping from token ID to index of the owner tokens list
  mapping(uint256 => uint256) internal ownedTokensIndex;

  // Array with all token ids, used for enumeration
  uint256[] internal allTokens;

  // Mapping from token id to position in the allTokens array
  mapping(uint256 => uint256) internal allTokensIndex;

  // Optional mapping for token URIs 
  mapping(uint256 => string) internal tokenURIs;

  /**
  * @dev Constructor function
  */
  function ERC721Token(string _name, string _symbol) public {
    name_ = _name;
    symbol_ = _symbol;
  }

  /**
  * @dev Gets the token name
  * @return string representing the token name
  */
  function name() public view returns (string) {
    return name_;
  }

  /**
  * @dev Gets the token symbol
  * @return string representing the token symbol
  */
  function symbol() public view returns (string) {
    return symbol_;
  }

  /**
  * @dev Returns an URI for a given token ID
  * @dev Throws if the token ID does not exist. May return an empty string.
  * @param _tokenId uint256 ID of the token to query
  */
  function tokenURI(uint256 _tokenId) public view returns (string) {
    require(exists(_tokenId));
    return tokenURIs[_tokenId];
  }

  /**
  * @dev Internal function to set the token URI for a given token
  * @dev Reverts if the token ID does not exist
  * @param _tokenId uint256 ID of the token to set its URI
  * @param _uri string URI to assign
  */
  function _setTokenURI(uint256 _tokenId, string _uri) internal {
    require(exists(_tokenId));
    tokenURIs[_tokenId] = _uri;
  }

  /**
  * @dev Gets the token ID at a given index of the tokens list of the requested owner
  * @param _owner address owning the tokens list to be accessed
  * @param _index uint256 representing the index to be accessed of the requested tokens list
  * @return uint256 token ID at the given index of the tokens list owned by the requested address
  */
  function tokenOfOwnerByIndex(address _owner, uint256 _index) public view returns (uint256) {
    require(_index < balanceOf(_owner));
    return ownedTokens[_owner][_index];
  }

  /**
  * @dev Gets the total amount of tokens stored by the contract
  * @return uint256 representing the total amount of tokens
  */
  function totalSupply() public view returns (uint256) {
    return allTokens.length;
  }

  /**
  * @dev Gets the token ID at a given index of all the tokens in this contract
  * @dev Reverts if the index is greater or equal to the total number of tokens
  * @param _index uint256 representing the index to be accessed of the tokens list
  * @return uint256 token ID at the given index of the tokens list
  */
  function tokenByIndex(uint256 _index) public view returns (uint256) {
    require(_index < totalSupply());
    return allTokens[_index];
  }

  /**
  * @dev Internal function to add a token ID to the list of a given address
  * @param _to address representing the new owner of the given token ID
  * @param _tokenId uint256 ID of the token to be added to the tokens list of the given address
  */
  function addTokenTo(address _to, uint256 _tokenId) internal {
    super.addTokenTo(_to, _tokenId);
    uint256 length = ownedTokens[_to].length;
    ownedTokens[_to].push(_tokenId);
    ownedTokensIndex[_tokenId] = length;
  }

  /**
  * @dev Internal function to remove a token ID from the list of a given address
  * @param _from address representing the previous owner of the given token ID
  * @param _tokenId uint256 ID of the token to be removed from the tokens list of the given address
  */
  function removeTokenFrom(address _from, uint256 _tokenId) internal {
    super.removeTokenFrom(_from, _tokenId);

    uint256 tokenIndex = ownedTokensIndex[_tokenId];
    uint256 lastTokenIndex = ownedTokens[_from].length.sub(1);
    uint256 lastToken = ownedTokens[_from][lastTokenIndex];

    ownedTokens[_from][tokenIndex] = lastToken;
    ownedTokens[_from][lastTokenIndex] = 0;
    // Note that this will handle single-element arrays. In that case, both tokenIndex and lastTokenIndex are going to
    // be zero. Then we can make sure that we will remove _tokenId from the ownedTokens list since we are first swapping
    // the lastToken to the first position, and then dropping the element placed in the last position of the list

    ownedTokens[_from].length--;
    ownedTokensIndex[_tokenId] = 0;
    ownedTokensIndex[lastToken] = tokenIndex;
  }

  /**
  * @dev Internal function to mint a new token
  * @dev Reverts if the given token ID already exists
  * @param _to address the beneficiary that will own the minted token
  * @param _tokenId uint256 ID of the token to be minted by the msg.sender
  */
  function _mint(address _to, uint256 _tokenId) internal {
    super._mint(_to, _tokenId);
    
    allTokensIndex[_tokenId] = allTokens.length;
    allTokens.push(_tokenId);
  }

  /**
  * @dev Internal function to burn a specific token
  * @dev Reverts if the token does not exist
  * @param _owner owner of the token to burn
  * @param _tokenId uint256 ID of the token being burned by the msg.sender
  */
  function _burn(address _owner, uint256 _tokenId) internal {
    super._burn(_owner, _tokenId);

    // Clear metadata (if any)
    if (bytes(tokenURIs[_tokenId]).length != 0) {
      delete tokenURIs[_tokenId];
    }

    // Reorg all tokens array
    uint256 tokenIndex = allTokensIndex[_tokenId];
    uint256 lastTokenIndex = allTokens.length.sub(1);
    uint256 lastToken = allTokens[lastTokenIndex];

    allTokens[tokenIndex] = lastToken;
    allTokens[lastTokenIndex] = 0;

    allTokens.length--;
    allTokensIndex[_tokenId] = 0;
    allTokensIndex[lastToken] = tokenIndex;
  }

}

// File: contracts/DebtToken.sol

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

// Internal dependencies.




// External dependencies.





/**
 * The DebtToken contract governs all business logic for making a debt agreement
 * transferable as an ERC721 non-fungible token.  Additionally, the contract
 * allows authorized contracts to trigger the minting of a debt agreement token
 * and, in turn, the insertion of a debt issuance into the DebtRegsitry.
 *
 * Author: Nadav Hollander -- Github: nadavhollander
 */
contract DebtToken is ERC721Token, ERC165, Pausable, PermissionEvents {
    using PermissionsLib for PermissionsLib.Permissions;

    DebtRegistry public registry;

    PermissionsLib.Permissions internal tokenCreationPermissions;
    PermissionsLib.Permissions internal tokenURIPermissions;

    string public constant CREATION_CONTEXT = "debt-token-creation";
    string public constant URI_CONTEXT = "debt-token-uri";

    /**
     * Constructor that sets the address of the debt registry.
     */
    function DebtToken(address _registry)
        public
        ERC721Token("DebtToken", "DDT")
    {
        registry = DebtRegistry(_registry);
    }

    /**
     * ERC165 interface.
     * Returns true for ERC721, false otherwise
     */
    function supportsInterface(bytes4 interfaceID)
        external
        view
        returns (bool _isSupported)
    {
        return interfaceID == 0x80ac58cd; // ERC721
    }

    /**
     * Mints a unique debt token and inserts the associated issuance into
     * the debt registry, if the calling address is authorized to do so.
     */
    function create(
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
        whenNotPaused
        returns (uint _tokenId)
    {
        require(tokenCreationPermissions.isAuthorized(msg.sender));

        bytes32 entryHash = registry.insert(
            _version,
            _beneficiary,
            _debtor,
            _underwriter,
            _underwriterRiskRating,
            _termsContract,
            _termsContractParameters,
            _salt
        );

        super._mint(_beneficiary, uint(entryHash));

        return uint(entryHash);
    }

    /**
     * Adds an address to the list of agents authorized to mint debt tokens.
     */
    function addAuthorizedMintAgent(address _agent)
        public
        onlyOwner
    {
        tokenCreationPermissions.authorize(_agent, CREATION_CONTEXT);
    }

    /**
     * Removes an address from the list of agents authorized to mint debt tokens
     */
    function revokeMintAgentAuthorization(address _agent)
        public
        onlyOwner
    {
        tokenCreationPermissions.revokeAuthorization(_agent, CREATION_CONTEXT);
    }

    /**
     * Returns the list of agents authorized to mint debt tokens
     */
    function getAuthorizedMintAgents()
        public
        view
        returns (address[] _agents)
    {
        return tokenCreationPermissions.getAuthorizedAgents();
    }

    /**
     * Adds an address to the list of agents authorized to set token URIs.
     */
    function addAuthorizedTokenURIAgent(address _agent)
        public
        onlyOwner
    {
        tokenURIPermissions.authorize(_agent, URI_CONTEXT);
    }

    /**
     * Returns the list of agents authorized to set token URIs.
     */
    function getAuthorizedTokenURIAgents()
        public
        view
        returns (address[] _agents)
    {
        return tokenURIPermissions.getAuthorizedAgents();
    }

    /**
     * Removes an address from the list of agents authorized to set token URIs.
     */
    function revokeTokenURIAuthorization(address _agent)
        public
        onlyOwner
    {
        tokenURIPermissions.revokeAuthorization(_agent, URI_CONTEXT);
    }

    /**
     * We override approval method of the parent ERC721Token
     * contract to allow its functionality to be frozen in the case of an emergency
     */
    function approve(address _to, uint _tokenId)
        public
        whenNotPaused
    {
        super.approve(_to, _tokenId);
    }

    /**
     * We override setApprovalForAll method of the parent ERC721Token
     * contract to allow its functionality to be frozen in the case of an emergency
     */
    function setApprovalForAll(address _to, bool _approved)
        public
        whenNotPaused
    {
        super.setApprovalForAll(_to, _approved);
    }

    /**
     * Support deprecated ERC721 method
     */
    function transfer(address _to, uint _tokenId)
        public
    {
        safeTransferFrom(msg.sender, _to, _tokenId);
    }

    /**
     * We override transferFrom methods of the parent ERC721Token
     * contract to allow its functionality to be frozen in the case of an emergency
     */
    function transferFrom(address _from, address _to, uint _tokenId)
        public
        whenNotPaused
    {
        _modifyBeneficiary(_tokenId, _to);
        super.transferFrom(_from, _to, _tokenId);
    }

    /**
     * We override safeTransferFrom methods of the parent ERC721Token
     * contract to allow its functionality to be frozen in the case of an emergency
     */
    function safeTransferFrom(address _from, address _to, uint _tokenId)
        public
        whenNotPaused
    {
        _modifyBeneficiary(_tokenId, _to);
        super.safeTransferFrom(_from, _to, _tokenId);
    }

    /**
     * We override safeTransferFrom methods of the parent ERC721Token
     * contract to allow its functionality to be frozen in the case of an emergency
     */
    function safeTransferFrom(address _from, address _to, uint _tokenId, bytes _data)
        public
        whenNotPaused
    {
        _modifyBeneficiary(_tokenId, _to);
        super.safeTransferFrom(_from, _to, _tokenId, _data);
    }

    /**
     * Allows senders with special permissions to set the token URI for a given debt token.
     */
    function setTokenURI(uint256 _tokenId, string _uri)
        public
        whenNotPaused
    {
        require(tokenURIPermissions.isAuthorized(msg.sender));
        super._setTokenURI(_tokenId, _uri);
    }

    /**
     * _modifyBeneficiary mutates the debt registry. This function should be
     * called every time a token is transferred or minted
     */
    function _modifyBeneficiary(uint _tokenId, address _to)
        internal
    {
        if (registry.getBeneficiary(bytes32(_tokenId)) != _to) {
            registry.modifyBeneficiary(bytes32(_tokenId), _to);
        }
    }
}

// File: contracts/DebtKernel.sol

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
 * The DebtKernel is the hub of all business logic governing how and when
 * debt orders can be filled and cancelled.  All logic that determines
 * whether a debt order is valid & consensual is contained herein,
 * as well as the mechanisms that transfer fees to keepers and
 * principal payments to debtors.
 *
 * Author: Nadav Hollander -- Github: nadavhollander
 */
contract DebtKernel is Pausable {
    using SafeMath for uint;

    enum Errors {
        // Debt has been already been issued
        DEBT_ISSUED,
        // Order has already expired
        ORDER_EXPIRED,
        // Debt issuance associated with order has been cancelled
        ISSUANCE_CANCELLED,
        // Order has been cancelled
        ORDER_CANCELLED,
        // Order parameters specify amount of creditor / debtor fees
        // that is not equivalent to the amount of underwriter / relayer fees
        ORDER_INVALID_INSUFFICIENT_OR_EXCESSIVE_FEES,
        // Order parameters specify insufficient principal amount for
        // debtor to at least be able to meet his fees
        ORDER_INVALID_INSUFFICIENT_PRINCIPAL,
        // Order parameters specify non zero fee for an unspecified recipient
        ORDER_INVALID_UNSPECIFIED_FEE_RECIPIENT,
        // Order signatures are mismatched / malformed
        ORDER_INVALID_NON_CONSENSUAL,
        // Insufficient balance or allowance for principal token transfer
        CREDITOR_BALANCE_OR_ALLOWANCE_INSUFFICIENT
    }

    DebtToken public debtToken;

    // solhint-disable-next-line var-name-mixedcase
    address public TOKEN_TRANSFER_PROXY;
    bytes32 constant public NULL_ISSUANCE_HASH = bytes32(0);

    /* NOTE(kayvon): Currently, the `view` keyword does not actually enforce the
    static nature of the method; this will change in the future, but for now, in
    order to prevent reentrancy we'll need to arbitrarily set an upper bound on
    the gas limit allotted for certain method calls. */
    uint16 constant public EXTERNAL_QUERY_GAS_LIMIT = 8000;

    mapping (bytes32 => bool) public issuanceCancelled;
    mapping (bytes32 => bool) public debtOrderCancelled;

    event LogDebtOrderFilled(
        bytes32 indexed _agreementId,
        uint _principal,
        address _principalToken,
        address indexed _underwriter,
        uint _underwriterFee,
        address indexed _relayer,
        uint _relayerFee
    );

    event LogIssuanceCancelled(
        bytes32 indexed _agreementId,
        address indexed _cancelledBy
    );

    event LogDebtOrderCancelled(
        bytes32 indexed _debtOrderHash,
        address indexed _cancelledBy
    );

    event LogError(
        uint8 indexed _errorId,
        bytes32 indexed _orderHash
    );

    struct Issuance {
        address version;
        address debtor;
        address underwriter;
        uint underwriterRiskRating;
        address termsContract;
        bytes32 termsContractParameters;
        uint salt;
        bytes32 agreementId;
    }

    struct DebtOrder {
        Issuance issuance;
        uint underwriterFee;
        uint relayerFee;
        uint principalAmount;
        address principalToken;
        uint creditorFee;
        uint debtorFee;
        address relayer;
        uint expirationTimestampInSec;
        bytes32 debtOrderHash;
    }

    function DebtKernel(address tokenTransferProxyAddress)
        public
    {
        TOKEN_TRANSFER_PROXY = tokenTransferProxyAddress;
    }

    ////////////////////////
    // EXTERNAL FUNCTIONS //
    ////////////////////////

    /**
     * Allows contract owner to set the currently used debt token contract.
     * Function exists to maximize upgradeability of individual modules
     * in the entire system.
     */
    function setDebtToken(address debtTokenAddress)
        public
        onlyOwner
    {
        debtToken = DebtToken(debtTokenAddress);
    }

    /**
     * Fills a given debt order if it is valid and consensual.
     */
    function fillDebtOrder(
        address creditor,
        address[6] orderAddresses,
        uint[8] orderValues,
        bytes32[1] orderBytes32,
        uint8[3] signaturesV,
        bytes32[3] signaturesR,
        bytes32[3] signaturesS
    )
        public
        whenNotPaused
        returns (bytes32 _agreementId)
    {
        DebtOrder memory debtOrder = getDebtOrder(orderAddresses, orderValues, orderBytes32);

        // Assert order's validity & consensuality
        if (!assertDebtOrderValidityInvariants(debtOrder) ||
            !assertDebtOrderConsensualityInvariants(
                debtOrder,
                creditor,
                signaturesV,
                signaturesR,
                signaturesS) ||
            !assertExternalBalanceAndAllowanceInvariants(creditor, debtOrder)) {
            return NULL_ISSUANCE_HASH;
        }

        // Mint debt token and finalize debt agreement
        issueDebtAgreement(creditor, debtOrder.issuance);

        // Register debt agreement's start with terms contract
        // We permit terms contracts to be undefined (for debt agreements which
        // may not have terms contracts associated with them), and only
        // register a term's start if the terms contract address is defined.
        if (debtOrder.issuance.termsContract != address(0)) {
            require(
                TermsContract(debtOrder.issuance.termsContract)
                    .registerTermStart(
                        debtOrder.issuance.agreementId,
                        debtOrder.issuance.debtor
                    )
            );
        }

        // Transfer principal to debtor
        if (debtOrder.principalAmount > 0) {
            require(transferTokensFrom(
                debtOrder.principalToken,
                creditor,
                debtOrder.issuance.debtor,
                debtOrder.principalAmount.sub(debtOrder.debtorFee)
            ));
        }

        // Transfer underwriter fee to underwriter
        if (debtOrder.underwriterFee > 0) {
            require(transferTokensFrom(
                debtOrder.principalToken,
                creditor,
                debtOrder.issuance.underwriter,
                debtOrder.underwriterFee
            ));
        }

        // Transfer relayer fee to relayer
        if (debtOrder.relayerFee > 0) {
            require(transferTokensFrom(
                debtOrder.principalToken,
                creditor,
                debtOrder.relayer,
                debtOrder.relayerFee
            ));
        }

        LogDebtOrderFilled(
            debtOrder.issuance.agreementId,
            debtOrder.principalAmount,
            debtOrder.principalToken,
            debtOrder.issuance.underwriter,
            debtOrder.underwriterFee,
            debtOrder.relayer,
            debtOrder.relayerFee
        );

        return debtOrder.issuance.agreementId;
    }

    /**
     * Allows both underwriters and debtors to prevent a debt
     * issuance in which they're involved from being used in
     * a future debt order.
     */
    function cancelIssuance(
        address version,
        address debtor,
        address termsContract,
        bytes32 termsContractParameters,
        address underwriter,
        uint underwriterRiskRating,
        uint salt
    )
        public
        whenNotPaused
    {
        require(msg.sender == debtor || msg.sender == underwriter);

        Issuance memory issuance = getIssuance(
            version,
            debtor,
            underwriter,
            termsContract,
            underwriterRiskRating,
            salt,
            termsContractParameters
        );

        issuanceCancelled[issuance.agreementId] = true;

        LogIssuanceCancelled(issuance.agreementId, msg.sender);
    }

    /**
     * Allows a debtor to cancel a debt order before it's been filled
     * -- preventing any counterparty from filling it in the future.
     */
    function cancelDebtOrder(
        address[6] orderAddresses,
        uint[8] orderValues,
        bytes32[1] orderBytes32
    )
        public
        whenNotPaused
    {
        DebtOrder memory debtOrder = getDebtOrder(orderAddresses, orderValues, orderBytes32);

        require(msg.sender == debtOrder.issuance.debtor);

        debtOrderCancelled[debtOrder.debtOrderHash] = true;

        LogDebtOrderCancelled(debtOrder.debtOrderHash, msg.sender);
    }

    ////////////////////////
    // INTERNAL FUNCTIONS //
    ////////////////////////

    /**
     * Helper function that mints debt token associated with the
     * given issuance and grants it to the beneficiary.
     */
    function issueDebtAgreement(address beneficiary, Issuance issuance)
        internal
        returns (bytes32 _agreementId)
    {
        // Mint debt token and finalize debt agreement
        uint tokenId = debtToken.create(
            issuance.version,
            beneficiary,
            issuance.debtor,
            issuance.underwriter,
            issuance.underwriterRiskRating,
            issuance.termsContract,
            issuance.termsContractParameters,
            issuance.salt
        );

        assert(tokenId == uint(issuance.agreementId));

        return issuance.agreementId;
    }

    /**
     * Asserts that a debt order meets all consensuality requirements
     * described in the DebtKernel specification document.
     */
    function assertDebtOrderConsensualityInvariants(
        DebtOrder debtOrder,
        address creditor,
        uint8[3] signaturesV,
        bytes32[3] signaturesR,
        bytes32[3] signaturesS
    )
        internal
        returns (bool _orderIsConsensual)
    {
        // Invariant: debtor's signature must be valid, unless debtor is submitting order
        if (msg.sender != debtOrder.issuance.debtor) {
            if (!isValidSignature(
                debtOrder.issuance.debtor,
                debtOrder.debtOrderHash,
                signaturesV[0],
                signaturesR[0],
                signaturesS[0]
            )) {
                LogError(uint8(Errors.ORDER_INVALID_NON_CONSENSUAL), debtOrder.debtOrderHash);
                return false;
            }
        }

        // Invariant: creditor's signature must be valid, unless creditor is submitting order
        if (msg.sender != creditor) {
            if (!isValidSignature(
                creditor,
                debtOrder.debtOrderHash,
                signaturesV[1],
                signaturesR[1],
                signaturesS[1]
            )) {
                LogError(uint8(Errors.ORDER_INVALID_NON_CONSENSUAL), debtOrder.debtOrderHash);
                return false;
            }
        }


        // Invariant: underwriter's signature must be valid (if present)
        if (debtOrder.issuance.underwriter != address(0) &&
            msg.sender != debtOrder.issuance.underwriter) {
            if (!isValidSignature(
                debtOrder.issuance.underwriter,
                getUnderwriterMessageHash(debtOrder),
                signaturesV[2],
                signaturesR[2],
                signaturesS[2]
            )) {
                LogError(uint8(Errors.ORDER_INVALID_NON_CONSENSUAL), debtOrder.debtOrderHash);
                return false;
            }
        }

        return true;
    }

    /**
     * Asserts that debt order meets all validity requirements described in
     * the DebtKernel specification document.
     */
    function assertDebtOrderValidityInvariants(DebtOrder debtOrder)
        internal
        returns (bool _orderIsValid)
    {
        uint totalFees = debtOrder.creditorFee.add(debtOrder.debtorFee);

        // Invariant: the total value of fees contributed by debtors and creditors
        //  must be equivalent to that paid out to underwriters and relayers.
        if (totalFees != debtOrder.relayerFee.add(debtOrder.underwriterFee)) {
            LogError(uint8(Errors.ORDER_INVALID_INSUFFICIENT_OR_EXCESSIVE_FEES), debtOrder.debtOrderHash);
            return false;
        }

        // Invariant: debtor is given enough principal to cover at least debtorFees
        if (debtOrder.principalAmount < debtOrder.debtorFee) {
            LogError(uint8(Errors.ORDER_INVALID_INSUFFICIENT_PRINCIPAL), debtOrder.debtOrderHash);
            return false;
        }

        // Invariant: if no underwriter is specified, underwriter fees must be 0
        // Invariant: if no relayer is specified, relayer fees must be 0.
        //      Given that relayer fees = total fees - underwriter fees,
        //      we assert that total fees = underwriter fees.
        if ((debtOrder.issuance.underwriter == address(0) && debtOrder.underwriterFee > 0) ||
            (debtOrder.relayer == address(0) && totalFees != debtOrder.underwriterFee)) {
            LogError(uint8(Errors.ORDER_INVALID_UNSPECIFIED_FEE_RECIPIENT), debtOrder.debtOrderHash);
            return false;
        }

        // Invariant: debt order must not be expired
        // solhint-disable-next-line not-rely-on-time
        if (debtOrder.expirationTimestampInSec < block.timestamp) {
            LogError(uint8(Errors.ORDER_EXPIRED), debtOrder.debtOrderHash);
            return false;
        }

        // Invariant: debt order's issuance must not already be minted as debt token
        if (debtToken.exists(uint(debtOrder.issuance.agreementId))) {
            LogError(uint8(Errors.DEBT_ISSUED), debtOrder.debtOrderHash);
            return false;
        }

        // Invariant: debt order's issuance must not have been cancelled
        if (issuanceCancelled[debtOrder.issuance.agreementId]) {
            LogError(uint8(Errors.ISSUANCE_CANCELLED), debtOrder.debtOrderHash);
            return false;
        }

        // Invariant: debt order itself must not have been cancelled
        if (debtOrderCancelled[debtOrder.debtOrderHash]) {
            LogError(uint8(Errors.ORDER_CANCELLED), debtOrder.debtOrderHash);
            return false;
        }

        return true;
    }

    /**
     * Assert that the creditor has a sufficient token balance and has
     * granted the token transfer proxy contract sufficient allowance to suffice for the principal
     * and creditor fee.
     */
    function assertExternalBalanceAndAllowanceInvariants(
        address creditor,
        DebtOrder debtOrder
    )
        internal
        returns (bool _isBalanceAndAllowanceSufficient)
    {
        uint totalCreditorPayment = debtOrder.principalAmount.add(debtOrder.creditorFee);

        if (getBalance(debtOrder.principalToken, creditor) < totalCreditorPayment ||
            getAllowance(debtOrder.principalToken, creditor) < totalCreditorPayment) {
            LogError(uint8(Errors.CREDITOR_BALANCE_OR_ALLOWANCE_INSUFFICIENT), debtOrder.debtOrderHash);
            return false;
        }

        return true;
    }

    /**
     * Helper function transfers a specified amount of tokens between two parties
     * using the token transfer proxy contract.
     */
    function transferTokensFrom(
        address token,
        address from,
        address to,
        uint amount
    )
        internal
        returns (bool success)
    {
        return TokenTransferProxy(TOKEN_TRANSFER_PROXY).transferFrom(
            token,
            from,
            to,
            amount
        );
    }

    /**
     * Helper function that constructs a hashed issuance structs from the given
     * parameters.
     */
    function getIssuance(
        address version,
        address debtor,
        address underwriter,
        address termsContract,
        uint underwriterRiskRating,
        uint salt,
        bytes32 termsContractParameters
    )
        internal
        pure
        returns (Issuance _issuance)
    {
        Issuance memory issuance = Issuance({
            version: version,
            debtor: debtor,
            underwriter: underwriter,
            termsContract: termsContract,
            underwriterRiskRating: underwriterRiskRating,
            salt: salt,
            termsContractParameters: termsContractParameters,
            agreementId: getAgreementId(
                version,
                debtor,
                underwriter,
                termsContract,
                underwriterRiskRating,
                salt,
                termsContractParameters
            )
        });

        return issuance;
    }

    /**
     * Helper function that constructs a hashed debt order struct given the raw parameters
     * of a debt order.
     */
    function getDebtOrder(address[6] orderAddresses, uint[8] orderValues, bytes32[1] orderBytes32)
        internal
        view
        returns (DebtOrder _debtOrder)
    {
        DebtOrder memory debtOrder = DebtOrder({
            issuance: getIssuance(
                orderAddresses[0],
                orderAddresses[1],
                orderAddresses[2],
                orderAddresses[3],
                orderValues[0],
                orderValues[1],
                orderBytes32[0]
            ),
            principalToken: orderAddresses[4],
            relayer: orderAddresses[5],
            principalAmount: orderValues[2],
            underwriterFee: orderValues[3],
            relayerFee: orderValues[4],
            creditorFee: orderValues[5],
            debtorFee: orderValues[6],
            expirationTimestampInSec: orderValues[7],
            debtOrderHash: bytes32(0)
        });

        debtOrder.debtOrderHash = getDebtOrderHash(debtOrder);

        return debtOrder;
    }

    /**
     * Helper function that returns an issuance's hash
     */
    function getAgreementId(
        address version,
        address debtor,
        address underwriter,
        address termsContract,
        uint underwriterRiskRating,
        uint salt,
        bytes32 termsContractParameters
    )
        internal
        pure
        returns (bytes32 _agreementId)
    {
        return keccak256(
            version,
            debtor,
            underwriter,
            underwriterRiskRating,
            termsContract,
            termsContractParameters,
            salt
        );
    }

    /**
     * Returns the hash of the parameters which an underwriter is supposed to sign
     */
    function getUnderwriterMessageHash(DebtOrder debtOrder)
        internal
        view
        returns (bytes32 _underwriterMessageHash)
    {
        return keccak256(
            address(this),
            debtOrder.issuance.agreementId,
            debtOrder.underwriterFee,
            debtOrder.principalAmount,
            debtOrder.principalToken,
            debtOrder.expirationTimestampInSec
        );
    }

    /**
     * Returns the hash of the debt order.
     */
    function getDebtOrderHash(DebtOrder debtOrder)
        internal
        view
        returns (bytes32 _debtorMessageHash)
    {
        return keccak256(
            address(this),
            debtOrder.issuance.agreementId,
            debtOrder.underwriterFee,
            debtOrder.principalAmount,
            debtOrder.principalToken,
            debtOrder.debtorFee,
            debtOrder.creditorFee,
            debtOrder.relayer,
            debtOrder.relayerFee,
            debtOrder.expirationTimestampInSec
        );
    }

    /**
     * Given a hashed message, a signer's address, and a signature, returns
     * whether the signature is valid.
     */
    function isValidSignature(
        address signer,
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    )
        internal
        pure
        returns (bool _valid)
    {
        return signer == ecrecover(
            keccak256("\x19Ethereum Signed Message:\n32", hash),
            v,
            r,
            s
        );
    }

    /**
     * Helper function for querying an address' balance on a given token.
     */
    function getBalance(
        address token,
        address owner
    )
        internal
        view
        returns (uint _balance)
    {
        // Limit gas to prevent reentrancy.
        return ERC20(token).balanceOf.gas(EXTERNAL_QUERY_GAS_LIMIT)(owner);
    }

    /**
     * Helper function for querying an address' allowance to the 0x transfer proxy.
     */
    function getAllowance(
        address token,
        address owner
    )
        internal
        view
        returns (uint _allowance)
    {
        // Limit gas to prevent reentrancy.
        return ERC20(token).allowance.gas(EXTERNAL_QUERY_GAS_LIMIT)(owner, TOKEN_TRANSFER_PROXY);
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

// File: contracts/ContractRegistry.sol

contract ContractRegistry is Ownable {

    event ContractAddressUpdated(
        ContractType indexed contractType,
        address indexed oldAddress,
        address indexed newAddress
    );

    enum ContractType {
        Collateralizer,
        DebtKernel,
        DebtRegistry,
        DebtToken,
        RepaymentRouter,
        TokenRegistry,
        TokenTransferProxy
    }

    Collateralizer public collateralizer;
    DebtKernel public debtKernel;
    DebtRegistry public  debtRegistry;
    DebtToken public debtToken;
    RepaymentRouter public repaymentRouter;
    TokenRegistry public tokenRegistry;
    TokenTransferProxy public tokenTransferProxy;

    function ContractRegistry(
        address _collateralizer,
        address _debtKernel,
        address _debtRegistry,
        address _debtToken,
        address _repaymentRouter,
        address _tokenRegistry,
        address _tokenTransferProxy
    )
        public
    {
        collateralizer = Collateralizer(_collateralizer);
        debtKernel = DebtKernel(_debtKernel);
        debtRegistry = DebtRegistry(_debtRegistry);
        debtToken = DebtToken(_debtToken);
        repaymentRouter = RepaymentRouter(_repaymentRouter);
        tokenRegistry = TokenRegistry(_tokenRegistry);
        tokenTransferProxy = TokenTransferProxy(_tokenTransferProxy);
    }

    function updateAddress(
        ContractType contractType,
        address newAddress
    )
        public
        onlyOwner
    {
        address oldAddress;

        if (contractType == ContractType.Collateralizer) {
            oldAddress = address(collateralizer);
            validateNewAddress(newAddress, oldAddress);
            collateralizer = Collateralizer(newAddress);
        } else if (contractType == ContractType.DebtKernel) {
            oldAddress = address(debtKernel);
            validateNewAddress(newAddress, oldAddress);
            debtKernel = DebtKernel(newAddress);
        } else if (contractType == ContractType.DebtRegistry) {
            oldAddress = address(debtRegistry);
            validateNewAddress(newAddress, oldAddress);
            debtRegistry = DebtRegistry(newAddress);
        } else if (contractType == ContractType.DebtToken) {
            oldAddress = address(debtToken);
            validateNewAddress(newAddress, oldAddress);
            debtToken = DebtToken(newAddress);
        } else if (contractType == ContractType.RepaymentRouter) {
            oldAddress = address(repaymentRouter);
            validateNewAddress(newAddress, oldAddress);
            repaymentRouter = RepaymentRouter(newAddress);
        } else if (contractType == ContractType.TokenRegistry) {
            oldAddress = address(tokenRegistry);
            validateNewAddress(newAddress, oldAddress);
            tokenRegistry = TokenRegistry(newAddress);
        } else if (contractType == ContractType.TokenTransferProxy) {
            oldAddress = address(tokenTransferProxy);
            validateNewAddress(newAddress, oldAddress);
            tokenTransferProxy = TokenTransferProxy(newAddress);
        } else {
            revert();
        }

        ContractAddressUpdated(contractType, oldAddress, newAddress);
    }

    function validateNewAddress(
        address newAddress,
        address oldAddress
    )
        internal
        pure
    {
        require(newAddress != address(0)); // new address cannot be null address.
        require(newAddress != oldAddress); // new address cannot be existing address.
    }
}