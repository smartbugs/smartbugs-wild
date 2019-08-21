// King of the Ether Throne Contracts.
// Copyright (c) 2016 Kieran Elby. Released under the MIT License.
// Version 0.9.9.2, July 2016.
//
// See also http://www.kingoftheether.com and
// https://github.com/kieranelby/KingOfTheEtherThrone .
// 
// This file contains a number of contracts, of which only
// these three are normally created:
//
// - Kingdom        = maintains the throne for a kingdom
// - World          = runs the world, which is a collection of kingdoms
// - KingdomFactory = used internally by the World contract
//
// The "Mixin" contracts (ThroneRulesMixin, ReentryProtectorMixin,
// CarefulSenderMixin, FundsHolderMixin, MoneyRounderMixin,
// NameableMixin) contain functions / data / structures used
// by the three main contracts.
// The ExposedInternalsForTesting contract is used by automated tests.


/// @title Mixin to help avoid recursive-call attacks.
contract ReentryProtectorMixin {

    // true if we are inside an external function
    bool reentryProtector;

    // Mark contract as having entered an external function.
    // Throws an exception if called twice with no externalLeave().
    // For this to work, Contracts MUST:
    //  - call externalEnter() at the start of each external function
    //  - call externalLeave() at the end of each external function
    //  - never use return statements in between enter and leave
    //  - never call an external function from another function
    // WARN: serious risk of contract getting stuck if used wrongly.
    function externalEnter() internal {
        if (reentryProtector) {
            throw;
        }
        reentryProtector = true;
    }

    // Mark contract as having left an external function.
    // Do this after each call to externalEnter().
    function externalLeave() internal {
        reentryProtector = false;
    }

}


/// @title Mixin to help send ether to untrusted addresses.
contract CarefulSenderMixin {

    // Seems a reasonable amount for a well-written fallback function.
    uint constant suggestedExtraGasToIncludeWithSends = 23000;

    // Send `_valueWei` of our ether to `_toAddress`, including
    // `_extraGasIncluded` gas above the usual 2300 gas stipend
    // with the send call.
    //
    // This needs care because there is no way to tell if _toAddress
    // is externally owned or is another contract - and sending ether
    // to a contract address will invoke its fallback function; this
    // has three implications:
    //
    // 1) Danger of recursive attack.
    //  The destination contract's fallback function (or another
    //  contract it calls) may call back into this contract (including
    //  our fallback function and external functions inherited, or into
    //  other contracts in our stack), leading to unexpected behaviour.
    //  Mitigations:
    //   - protect all external functions against re-entry into
    //     any of them (see ReentryProtectorMixin);
    //   - program very defensively (e.g. debit balance before send).
    //
    // 2) Destination fallback function can fail.
    //  If the destination contract's fallback function fails, ether
    //  will not be sent and may be locked into the sending contract.
    //  Unlike most errors, it will NOT cause this contract to throw.
    //  Mitigations:
    //   - check the return value from this function (see below).
    //
    // 3) Gas usage.
    //  The destination fallback function will consume the gas supplied
    //  in this transaction (which is fixed and set by the transaction
    //  starter, though some clients do a good job of estimating it.
    //  This is a problem for lottery-type contracts where one very
    //  expensive-to-call receiving contract could 'poison' the lottery
    //  contract by preventing it being invoked by another person who
    //  cannot supply enough gas.
    //  Mitigations:
    //    - choose sensible value for _extraGasIncluded (by default
    //      only 2300 gas is supplied to the destination function);
    //    - if call fails consider whether to throw or to ring-fence
    //      funds for later withdrawal.
    //
    // Returns:
    //
    //  True if-and-only-if the send call was made and did not throw
    //  an error. In this case, we will no longer own the _valueWei
    //  ether. Note that we cannot get the return value of the fallback
    //  function called (if any).
    //
    //  False if the send was made but the destination fallback function
    //  threw an error (or ran out of gas). If this hapens, we still own
    //  _valueWei ether and the destination's actions were undone.
    //
    //  This function should not normally throw an error unless:
    //    - not enough gas to make the send/call
    //    - max call stack depth reached
    //    - insufficient ether
    //
    function carefulSendWithFixedGas(
        address _toAddress,
        uint _valueWei,
        uint _extraGasIncluded
    ) internal returns (bool success) {
        return _toAddress.call.value(_valueWei).gas(_extraGasIncluded)();
    }

}


/// @title Mixin to help track who owns our ether and allow withdrawals.
contract FundsHolderMixin is ReentryProtectorMixin, CarefulSenderMixin {

    // Record here how much wei is owned by an address.
    // Obviously, the entries here MUST be backed by actual ether
    // owned by the contract - we cannot enforce that in this mixin.
    mapping (address => uint) funds;

    event FundsWithdrawnEvent(
        address fromAddress,
        address toAddress,
        uint valueWei
    );

    /// @notice Amount of ether held for `_address`.
    function fundsOf(address _address) constant returns (uint valueWei) {
        return funds[_address];
    }

    /// @notice Send the caller (`msg.sender`) all ether they own.
    function withdrawFunds() {
        externalEnter();
        withdrawFundsRP();
        externalLeave();
    }

    /// @notice Send `_valueWei` of the ether owned by the caller
    /// (`msg.sender`) to `_toAddress`, including `_extraGas` gas
    /// beyond the normal stipend.
    function withdrawFundsAdvanced(
        address _toAddress,
        uint _valueWei,
        uint _extraGas
    ) {
        externalEnter();
        withdrawFundsAdvancedRP(_toAddress, _valueWei, _extraGas);
        externalLeave();
    }

    /// @dev internal version of withdrawFunds()
    function withdrawFundsRP() internal {
        address fromAddress = msg.sender;
        address toAddress = fromAddress;
        uint allAvailableWei = funds[fromAddress];
        withdrawFundsAdvancedRP(
            toAddress,
            allAvailableWei,
            suggestedExtraGasToIncludeWithSends
        );
    }

    /// @dev internal version of withdrawFundsAdvanced(), also used
    /// by withdrawFundsRP().
    function withdrawFundsAdvancedRP(
        address _toAddress,
        uint _valueWei,
        uint _extraGasIncluded
    ) internal {
        if (msg.value != 0) {
            throw;
        }
        address fromAddress = msg.sender;
        if (_valueWei > funds[fromAddress]) {
            throw;
        }
        funds[fromAddress] -= _valueWei;
        bool sentOk = carefulSendWithFixedGas(
            _toAddress,
            _valueWei,
            _extraGasIncluded
        );
        if (!sentOk) {
            throw;
        }
        FundsWithdrawnEvent(fromAddress, _toAddress, _valueWei);
    }

}


/// @title Mixin to help make nicer looking ether amounts.
contract MoneyRounderMixin {

    /// @notice Make `_rawValueWei` into a nicer, rounder number.
    /// @return A value that:
    ///   - is no larger than `_rawValueWei`
    ///   - is no smaller than `_rawValueWei` * 0.999
    ///   - has no more than three significant figures UNLESS the
    ///     number is very small or very large in monetary terms
    ///     (which we define as < 1 finney or > 10000 ether), in
    ///     which case no precision will be lost.
    function roundMoneyDownNicely(uint _rawValueWei) constant internal
    returns (uint nicerValueWei) {
        if (_rawValueWei < 1 finney) {
            return _rawValueWei;
        } else if (_rawValueWei < 10 finney) {
            return 10 szabo * (_rawValueWei / 10 szabo);
        } else if (_rawValueWei < 100 finney) {
            return 100 szabo * (_rawValueWei / 100 szabo);
        } else if (_rawValueWei < 1 ether) {
            return 1 finney * (_rawValueWei / 1 finney);
        } else if (_rawValueWei < 10 ether) {
            return 10 finney * (_rawValueWei / 10 finney);
        } else if (_rawValueWei < 100 ether) {
            return 100 finney * (_rawValueWei / 100 finney);
        } else if (_rawValueWei < 1000 ether) {
            return 1 ether * (_rawValueWei / 1 ether);
        } else if (_rawValueWei < 10000 ether) {
            return 10 ether * (_rawValueWei / 10 ether);
        } else {
            return _rawValueWei;
        }
    }
    
    /// @notice Convert `_valueWei` into a whole number of finney.
    /// @return The smallest whole number of finney which is equal
    /// to or greater than `_valueWei` when converted to wei.
    /// WARN: May be incorrect if `_valueWei` is above 2**254.
    function roundMoneyUpToWholeFinney(uint _valueWei) constant internal
    returns (uint valueFinney) {
        return (1 finney + _valueWei - 1 wei) / 1 finney;
    }

}


/// @title Mixin to help allow users to name things.
contract NameableMixin {

    // String manipulation is expensive in the EVM; keep things short.

    uint constant minimumNameLength = 1;
    uint constant maximumNameLength = 25;
    string constant nameDataPrefix = "NAME:";

    /// @notice Check if `_name` is a reasonable choice of name.
    /// @return True if-and-only-if `_name_` meets the criteria
    /// below, or false otherwise:
    ///   - no fewer than 1 character
    ///   - no more than 25 characters
    ///   - no characters other than:
    ///     - "roman" alphabet letters (A-Z and a-z)
    ///     - western digits (0-9)
    ///     - "safe" punctuation: ! ( ) - . _ SPACE
    ///   - at least one non-punctuation character
    /// Note that we deliberately exclude characters which may cause
    /// security problems for websites and databases if escaping is
    /// not performed correctly, such as < > " and '.
    /// Apologies for the lack of non-English language support.
    function validateNameInternal(string _name) constant internal
    returns (bool allowed) {
        bytes memory nameBytes = bytes(_name);
        uint lengthBytes = nameBytes.length;
        if (lengthBytes < minimumNameLength ||
            lengthBytes > maximumNameLength) {
            return false;
        }
        bool foundNonPunctuation = false;
        for (uint i = 0; i < lengthBytes; i++) {
            byte b = nameBytes[i];
            if (
                (b >= 48 && b <= 57) || // 0 - 9
                (b >= 65 && b <= 90) || // A - Z
                (b >= 97 && b <= 122)   // a - z
            ) {
                foundNonPunctuation = true;
                continue;
            }
            if (
                b == 32 || // space
                b == 33 || // !
                b == 40 || // (
                b == 41 || // )
                b == 45 || // -
                b == 46 || // .
                b == 95    // _
            ) {
                continue;
            }
            return false;
        }
        return foundNonPunctuation;
    }

    // Extract a name from bytes `_data` (presumably from `msg.data`),
    // or throw an exception if the data is not in the expected format.
    // 
    // We want to make it easy for people to name things, even if
    // they're not comfortable calling functions on contracts.
    //
    // So we allow names to be sent to the fallback function encoded
    // as message data.
    //
    // Unfortunately, the way the Ethereum Function ABI works means we
    // must be careful to avoid clashes between message data that
    // represents our names and message data that represents a call
    // to an external function - otherwise:
    //   a) some names won't be usable;
    //   b) small possibility of a phishing attack where users are
    //     tricked into using certain names which cause an external
    //     function call - e.g. if the data sent to the contract is
    //     keccak256("withdrawFunds()") then a withdrawal will occur.
    //
    // So we require a prefix "NAME:" at the start of the name (encoded
    // in ASCII) when sent via the fallback function - this prefix
    // doesn't clash with any external function signature hashes.
    //
    // e.g. web3.fromAscii('NAME:' + 'Joe Bloggs')
    //
    // WARN: this does not check the name for "reasonableness";
    // use validateNameInternal() for that.
    //
    function extractNameFromData(bytes _data) constant internal
    returns (string extractedName) {
        // check prefix present
        uint expectedPrefixLength = (bytes(nameDataPrefix)).length;
        if (_data.length < expectedPrefixLength) {
            throw;
        }
        uint i;
        for (i = 0; i < expectedPrefixLength; i++) {
            if ((bytes(nameDataPrefix))[i] != _data[i]) {
                throw;
            }
        }
        // copy data after prefix
        uint payloadLength = _data.length - expectedPrefixLength;
        if (payloadLength < minimumNameLength ||
            payloadLength > maximumNameLength) {
            throw;
        }
        string memory name = new string(payloadLength);
        for (i = 0; i < payloadLength; i++) {
            (bytes(name))[i] = _data[expectedPrefixLength + i];
        }
        return name;
    }

    // Turn a short name into a "fuzzy hash" with the property
    // that extremely similar names will have the same fuzzy hash.
    //
    // This is useful to:
    //  - stop people choosing names which differ only in case or
    //    punctuation and would lead to confusion.
    //  - faciliate searching by name without needing exact match
    //
    // For example, these names all have the same fuzzy hash:
    //
    //  "Banana"
    //  "BANANA"
    //  "Ba-na-na"
    //  "  banana  "
    //  "Banana                        .. so long the end is ignored"
    //
    // On the other hand, "Banana1" and "A Banana" are different to
    // the above.
    //
    // WARN: this is likely to work poorly on names that do not meet
    // the validateNameInternal() test.
    //
    function computeNameFuzzyHash(string _name) constant internal
    returns (uint fuzzyHash) {
        bytes memory nameBytes = bytes(_name);
        uint h = 0;
        uint len = nameBytes.length;
        if (len > maximumNameLength) {
            len = maximumNameLength;
        }
        for (uint i = 0; i < len; i++) {
            uint mul = 128;
            byte b = nameBytes[i];
            uint ub = uint(b);
            if (b >= 48 && b <= 57) {
                // 0-9
                h = h * mul + ub;
            } else if (b >= 65 && b <= 90) {
                // A-Z
                h = h * mul + ub;
            } else if (b >= 97 && b <= 122) {
                // fold a-z to A-Z
                uint upper = ub - 32;
                h = h * mul + upper;
            } else {
                // ignore others
            }
        }
        return h;
    }

}


/// @title Mixin to help define the rules of a throne.
contract ThroneRulesMixin {

    // See World.createKingdom(..) for documentation.
    struct ThroneRules {
        uint startingClaimPriceWei;
        uint maximumClaimPriceWei;
        uint claimPriceAdjustPercent;
        uint curseIncubationDurationSeconds;
        uint commissionPerThousand;
    }

}


/// @title Maintains the throne of a kingdom.
contract Kingdom is
  ReentryProtectorMixin,
  CarefulSenderMixin,
  FundsHolderMixin,
  MoneyRounderMixin,
  NameableMixin,
  ThroneRulesMixin {

    // e.g. "King of the Ether"
    string public kingdomName;

    // The World contract used to create this kingdom, or 0x0 if none.
    address public world;

    // The rules that govern this kingdom - see ThroneRulesMixin.
    ThroneRules public rules;

    // Someone who has ruled (or is ruling) our kingdom.
    struct Monarch {
        // where to send their compensation
        address compensationAddress;
        // their name
        string name;
        // when they became our ruler
        uint coronationTimestamp;
        // the claim price paid (excluding any over-payment)
        uint claimPriceWei;
        // the compensation sent to or held for them so far
        uint compensationWei;
    }

    // The first ruler is number 1; the zero-th entry is a dummy entry.
    Monarch[] public monarchsByNumber;

    // The topWizard earns half the commission.
    // They are normally the owner of the World contract.
    address public topWizard;

    // The subWizard earns half the commission.
    // They are normally the creator of this Kingdom.
    // The topWizard and subWizard can be the same address.
    address public subWizard;

    // NB: we also have a `funds` mapping from FundsHolderMixin,
    // and a rentryProtector from ReentryProtectorMixin.

    event ThroneClaimedEvent(uint monarchNumber);
    event CompensationSentEvent(address toAddress, uint valueWei);
    event CompensationFailEvent(address toAddress, uint valueWei);
    event CommissionEarnedEvent(address byAddress, uint valueWei);
    event WizardReplacedEvent(address oldWizard, address newWizard);
    // NB: we also have a `FundsWithdrawnEvent` from FundsHolderMixin

    // WARN - does NOT validate arguments; you MUST either call
    // KingdomFactory.validateProposedThroneRules() or create
    // the Kingdom via KingdomFactory/World's createKingdom().
    // See World.createKingdom(..) for parameter documentation.
    function Kingdom(
        string _kingdomName,
        address _world,
        address _topWizard,
        address _subWizard,
        uint _startingClaimPriceWei,
        uint _maximumClaimPriceWei,
        uint _claimPriceAdjustPercent,
        uint _curseIncubationDurationSeconds,
        uint _commissionPerThousand
    ) {
        kingdomName = _kingdomName;
        world = _world;
        topWizard = _topWizard;
        subWizard = _subWizard;
        rules = ThroneRules(
            _startingClaimPriceWei,
            _maximumClaimPriceWei,
            _claimPriceAdjustPercent,
            _curseIncubationDurationSeconds,
            _commissionPerThousand
        );
        // We number the monarchs starting from 1; it's sometimes useful
        // to use zero = invalid, so put in a dummy entry for number 0.
        monarchsByNumber.push(
            Monarch(
                0,
                "",
                0,
                0,
                0
            )
        );
    }

    function numberOfMonarchs() constant returns (uint totalCount) {
        // zero-th entry is invalid
        return monarchsByNumber.length - 1;
    }

    // False if either there are no monarchs, or if the latest monarch
    // has reigned too long and been struck down by the curse.
    function isLivingMonarch() constant returns (bool alive) {
        if (numberOfMonarchs() == 0) {
            return false;
        }
        uint reignStartedTimestamp = latestMonarchInternal().coronationTimestamp;
        if (now < reignStartedTimestamp) {
            // Should not be possible, think miners reject blocks with
            // timestamps that go backwards? But some drift possible and
            // it needs handling for unsigned overflow audit checks ...
            return true;
        }
        uint elapsedReignDurationSeconds = now - reignStartedTimestamp;
        if (elapsedReignDurationSeconds > rules.curseIncubationDurationSeconds) {
            return false;
        } else {
            return true;
        }
    }

    /// @notice How much you must pay to claim the throne now, in wei.
    function currentClaimPriceWei() constant returns (uint priceInWei) {
        if (!isLivingMonarch()) {
            return rules.startingClaimPriceWei;
        } else {
            uint lastClaimPriceWei = latestMonarchInternal().claimPriceWei;
            // no danger of overflow because claim price never gets that high
            uint newClaimPrice =
              (lastClaimPriceWei * (100 + rules.claimPriceAdjustPercent)) / 100;
            newClaimPrice = roundMoneyDownNicely(newClaimPrice);
            if (newClaimPrice < rules.startingClaimPriceWei) {
                newClaimPrice = rules.startingClaimPriceWei;
            }
            if (newClaimPrice > rules.maximumClaimPriceWei) {
                newClaimPrice = rules.maximumClaimPriceWei;
            }
            return newClaimPrice;
        }
    }

    /// @notice How much you must pay to claim the throne now, in finney.
    function currentClaimPriceInFinney() constant
    returns (uint priceInFinney) {
        uint valueWei = currentClaimPriceWei();
        return roundMoneyUpToWholeFinney(valueWei);
    }

    /// @notice Check if a name can be used as a monarch name.
    /// @return True if the name satisfies the criteria of:
    ///   - no fewer than 1 character
    ///   - no more than 25 characters
    ///   - no characters other than:
    ///     - "roman" alphabet letters (A-Z and a-z)
    ///     - western digits (0-9)
    ///     - "safe" punctuation: ! ( ) - . _ SPACE
    function validateProposedMonarchName(string _monarchName) constant
    returns (bool allowed) {
        return validateNameInternal(_monarchName);
    }

    // Get details of the latest monarch (even if they are dead).
    //
    // We don't expose externally because returning structs is not well
    // supported in the ABI (strange that monarchsByNumber array works
    // fine though). Note that the reference returned is writable - it
    // can be used to update details of the latest monarch.
    // WARN: you should check numberOfMonarchs() > 0 first.
    function latestMonarchInternal() constant internal
    returns (Monarch storage monarch) {
        return monarchsByNumber[monarchsByNumber.length - 1];
    }

    /// @notice Claim throne by sending funds to the contract.
    /// Any future compensation earned will be sent to the sender's
    /// address (`msg.sender`).
    /// Sending from a contract is not recommended unless you know
    /// what you're doing (and you've tested it).
    /// If no message data is supplied, the throne will be claimed in
    /// the name of "Anonymous". To supply a name, send data encoded
    /// using web3.fromAscii('NAME:' + 'your_chosen_valid_name').
    /// Sender must include payment equal to currentClaimPriceWei().
    /// Will consume up to ~300,000 gas.
    /// Will throw an error if:
    ///   - name is invalid (see `validateProposedMonarchName(string)`)
    ///   - payment is too low or too high
    /// Produces events:
    ///   - `ThroneClaimedEvent`
    ///   - `CompensationSentEvent` / `CompensationFailEvent`
    ///   - `CommissionEarnedEvent`
    function () {
        externalEnter();
        fallbackRP();
        externalLeave();
    }

    /// @notice Claim throne in the given `_monarchName`.
    /// Any future compensation earned will be sent to the caller's
    /// address (`msg.sender`).
    /// Caller must include payment equal to currentClaimPriceWei().
    /// Calling from a contract is not recommended unless you know
    /// what you're doing (and you've tested it).
    /// Will consume up to ~300,000 gas.
    /// Will throw an error if:
    ///   - name is invalid (see `validateProposedMonarchName(string)`)
    ///   - payment is too low or too high
    /// Produces events:
    ///   - `ThroneClaimedEvent
    ///   - `CompensationSentEvent` / `CompensationFailEvent`
    ///   - `CommissionEarnedEvent`
    function claimThrone(string _monarchName) {
        externalEnter();
        claimThroneRP(_monarchName);
        externalLeave();
    }

    /// @notice Used by either the topWizard or subWizard to transfer
    /// all rights to future commissions to the `_replacement` wizard.
    /// WARN: The original wizard retains ownership of any past
    /// commission held for them in the `funds` mapping, which they
    /// can still withdraw.
    /// Produces event WizardReplacedEvent.
    function replaceWizard(address _replacement) {
        externalEnter();
        replaceWizardRP(_replacement);
        externalLeave();
    }

    function fallbackRP() internal {
        if (msg.data.length == 0) {
            claimThroneRP("Anonymous");
        } else {
            string memory _monarchName = extractNameFromData(msg.data);
            claimThroneRP(_monarchName);
        }
    }
    
    function claimThroneRP(
        string _monarchName
    ) internal {

        address _compensationAddress = msg.sender;

        if (!validateNameInternal(_monarchName)) {
            throw;
        }

        if (_compensationAddress == 0 ||
            _compensationAddress == address(this)) {
            throw;
        }

        uint paidWei = msg.value;
        uint priceWei = currentClaimPriceWei();
        if (paidWei < priceWei) {
            throw;
        }
        // Make it easy for people to pay using a whole number of finney,
        // which could be a teeny bit higher than the raw wei value.
        uint excessWei = paidWei - priceWei;
        if (excessWei > 1 finney) {
            throw;
        }
        
        uint compensationWei;
        uint commissionWei;
        if (!isLivingMonarch()) {
            // dead men get no compensation
            commissionWei = paidWei;
            compensationWei = 0;
        } else {
            commissionWei = (paidWei * rules.commissionPerThousand) / 1000;
            compensationWei = paidWei - commissionWei;
        }

        if (commissionWei != 0) {
            recordCommissionEarned(commissionWei);
        }

        if (compensationWei != 0) {
            compensateLatestMonarch(compensationWei);
        }

        // In case of any teeny excess, we use the official price here
        // since that should determine the new claim price, not paidWei.
        monarchsByNumber.push(Monarch(
            _compensationAddress,
            _monarchName,
            now,
            priceWei,
            0
        ));

        ThroneClaimedEvent(monarchsByNumber.length - 1);
    }

    function replaceWizardRP(address replacement) internal {
        if (msg.value != 0) {
            throw;
        }
        bool replacedOk = false;
        address oldWizard;
        if (msg.sender == topWizard) {
            oldWizard = topWizard;
            topWizard = replacement;
            WizardReplacedEvent(oldWizard, replacement);
            replacedOk = true;
        }
        // Careful - topWizard and subWizard can be the same address,
        // in which case we must replace both.
        if (msg.sender == subWizard) {
            oldWizard = subWizard;
            subWizard = replacement;
            WizardReplacedEvent(oldWizard, replacement);
            replacedOk = true;
        }
        if (!replacedOk) {
            throw;
        }
    }

    // Allow commission funds to build up in contract for the wizards
    // to withdraw (carefully ring-fenced).
    function recordCommissionEarned(uint _commissionWei) internal {
        // give the subWizard any "odd" single wei
        uint topWizardWei = _commissionWei / 2;
        uint subWizardWei = _commissionWei - topWizardWei;
        funds[topWizard] += topWizardWei;
        CommissionEarnedEvent(topWizard, topWizardWei);
        funds[subWizard] += subWizardWei;
        CommissionEarnedEvent(subWizard, subWizardWei);
    }

    // Send compensation to latest monarch (or hold funds for them
    // if cannot through no fault of current caller).
    function compensateLatestMonarch(uint _compensationWei) internal {
        address compensationAddress =
          latestMonarchInternal().compensationAddress;
        // record that we compensated them
        latestMonarchInternal().compensationWei = _compensationWei;
        // WARN: if the latest monarch is a contract whose fallback
        // function needs more 25300 gas than then they will NOT
        // receive compensation automatically.
        bool sentOk = carefulSendWithFixedGas(
            compensationAddress,
            _compensationWei,
            suggestedExtraGasToIncludeWithSends
        );
        if (sentOk) {
            CompensationSentEvent(compensationAddress, _compensationWei);
        } else {
            // This should only happen if the latest monarch is a contract
            // whose fallback-function failed or ran out of gas (despite
            // us including a fair amount of gas).
            // We do not throw since we do not want the throne to get
            // 'stuck' (it's not the new usurpers fault) - instead save
            // the funds we could not send so can be claimed later.
            // Their monarch contract would need to have been designed
            // to call our withdrawFundsAdvanced(..) function mind you.
            funds[compensationAddress] += _compensationWei;
            CompensationFailEvent(compensationAddress, _compensationWei);
        }
    }

}


/// @title Used by the World contract to create Kingdom instances.
/// @dev Mostly exists so topWizard can potentially replace this
/// contract to modify the Kingdom contract and/or rule validation
/// logic to be used for *future* Kingdoms created by the World.
/// We do not implement rentry protection because we don't send/call.
/// We do not charge a fee here - but if you bypass the World then
/// you won't be listed on the official World page of course.
contract KingdomFactory {

    function KingdomFactory() {
    }

    function () {
        // this contract should never have a balance
        throw;
    }

    // See World.createKingdom(..) for parameter documentation.
    function validateProposedThroneRules(
        uint _startingClaimPriceWei,
        uint _maximumClaimPriceWei,
        uint _claimPriceAdjustPercent,
        uint _curseIncubationDurationSeconds,
        uint _commissionPerThousand
    ) constant returns (bool allowed) {
        // I suppose there is a danger that massive deflation/inflation could
        // change the real-world sanity of these checks, but in that case we
        // can deploy a new factory and update the world.
        if (_startingClaimPriceWei < 1 finney ||
            _startingClaimPriceWei > 100 ether) {
            return false;
        }
        if (_maximumClaimPriceWei < 1 ether ||
            _maximumClaimPriceWei > 100000 ether) {
            return false;
        }
        if (_startingClaimPriceWei * 20 > _maximumClaimPriceWei) {
            return false;
        }
        if (_claimPriceAdjustPercent < 1 ||
            _claimPriceAdjustPercent > 900) {
            return false;
        }
        if (_curseIncubationDurationSeconds < 2 hours ||
            _curseIncubationDurationSeconds > 10000 days) {
            return false;
        }
        if (_commissionPerThousand < 10 ||
            _commissionPerThousand > 100) {
            return false;
        }
        return true;
    }

    /// @notice Create a new Kingdom. Normally called by World contract.
    /// WARN: Does NOT validate the _kingdomName or _world arguments.
    /// Will consume up to 1,800,000 gas (!)
    /// Will throw an error if:
    ///   - rules invalid (see validateProposedThroneRules)
    ///   - wizard addresses "obviously" wrong
    ///   - out of gas quite likely (perhaps in future should consider
    ///     using solidity libraries to reduce Kingdom size?)
    // See World.createKingdom(..) for parameter documentation.
    function createKingdom(
        string _kingdomName,
        address _world,
        address _topWizard,
        address _subWizard,
        uint _startingClaimPriceWei,
        uint _maximumClaimPriceWei,
        uint _claimPriceAdjustPercent,
        uint _curseIncubationDurationSeconds,
        uint _commissionPerThousand
    ) returns (Kingdom newKingdom) {
        if (msg.value > 0) {
            // this contract should never have a balance
            throw;
        }
        // NB: topWizard and subWizard CAN be the same as each other.
        if (_topWizard == 0 || _subWizard == 0) {
            throw;
        }
        if (_topWizard == _world || _subWizard == _world) {
            throw;
        }
        if (!validateProposedThroneRules(
            _startingClaimPriceWei,
            _maximumClaimPriceWei,
            _claimPriceAdjustPercent,
            _curseIncubationDurationSeconds,
            _commissionPerThousand
        )) {
            throw;
        }
        return new Kingdom(
            _kingdomName,
            _world,
            _topWizard,
            _subWizard,
            _startingClaimPriceWei,
            _maximumClaimPriceWei,
            _claimPriceAdjustPercent,
            _curseIncubationDurationSeconds,
            _commissionPerThousand
        );
    }

}


/// @title Runs the world, which is a collection of Kingdoms.
contract World is
  ReentryProtectorMixin,
  NameableMixin,
  MoneyRounderMixin,
  FundsHolderMixin,
  ThroneRulesMixin {

    // The topWizard runs the world. They charge for the creation of
    // kingdoms and become the topWizard in each kingdom created.
    address public topWizard;

    // How much one must pay to create a new kingdom (in wei).
    // Can be changed by the topWizard.
    uint public kingdomCreationFeeWei;

    struct KingdomListing {
        uint kingdomNumber;
        string kingdomName;
        address kingdomContract;
        address kingdomCreator;
        uint creationTimestamp;
        address kingdomFactoryUsed;
    }
    
    // The first kingdom is number 1; the zero-th entry is a dummy.
    KingdomListing[] public kingdomsByNumber;

    // For safety, we cap just how high the price can get.
    // Can be changed by the topWizard, though it will only affect
    // kingdoms created after that.
    uint public maximumClaimPriceWei;

    // Helper contract for creating Kingdom instances. Can be
    // upgraded by the topWizard (won't affect existing ones).
    KingdomFactory public kingdomFactory;

    // Avoids duplicate kingdom names and allows searching by name.
    mapping (uint => uint) kingdomNumbersByfuzzyHash;

    // NB: we also have a `funds` mapping from FundsHolderMixin,
    // and a rentryProtector from ReentryProtectorMixin.

    event KingdomCreatedEvent(uint kingdomNumber);
    event CreationFeeChangedEvent(uint newFeeWei);
    event FactoryChangedEvent(address newFactory);
    event WizardReplacedEvent(address oldWizard, address newWizard);
    // NB: we also have a `FundsWithdrawnEvent` from FundsHolderMixin

    // Create the world with no kingdoms yet.
    // Costs about 1.9M gas to deploy.
    function World(
        address _topWizard,
        uint _kingdomCreationFeeWei,
        KingdomFactory _kingdomFactory,
        uint _maximumClaimPriceWei
    ) {
        if (_topWizard == 0) {
            throw;
        }
        if (_maximumClaimPriceWei < 1 ether) {
            throw;
        }
        topWizard = _topWizard;
        kingdomCreationFeeWei = _kingdomCreationFeeWei;
        kingdomFactory = _kingdomFactory;
        maximumClaimPriceWei = _maximumClaimPriceWei;
        // We number the kingdoms starting from 1 since it's sometimes
        // useful to use zero = invalid. Create dummy zero-th entry.
        kingdomsByNumber.push(KingdomListing(0, "", 0, 0, 0, 0));
    }

    function numberOfKingdoms() constant returns (uint totalCount) {
        return kingdomsByNumber.length - 1;
    }

    /// @return index into kingdomsByNumber if found, or zero if not. 
    function findKingdomCalled(string _kingdomName) constant
    returns (uint kingdomNumber) {
        uint fuzzyHash = computeNameFuzzyHash(_kingdomName);
        return kingdomNumbersByfuzzyHash[fuzzyHash];
    }

    /// @notice Check if a name can be used as a kingdom name.
    /// @return True if the name satisfies the criteria of:
    ///   - no fewer than 1 character
    ///   - no more than 25 characters
    ///   - no characters other than:
    ///     - "roman" alphabet letters (A-Z and a-z)
    ///     - western digits (0-9)
    ///     - "safe" punctuation: ! ( ) - . _ SPACE
    ///
    /// WARN: does not check if the name is already in use;
    /// use `findKingdomCalled(string)` for that afterwards.
    function validateProposedKingdomName(string _kingdomName) constant
    returns (bool allowed) {
        return validateNameInternal(_kingdomName);
    }

    // Check if rules would be allowed for a new custom Kingdom.
    // Typically used before calling `createKingdom(...)`.
    function validateProposedThroneRules(
        uint _startingClaimPriceWei,
        uint _claimPriceAdjustPercent,
        uint _curseIncubationDurationSeconds,
        uint _commissionPerThousand
    ) constant returns (bool allowed) {
        return kingdomFactory.validateProposedThroneRules(
            _startingClaimPriceWei,
            maximumClaimPriceWei,
            _claimPriceAdjustPercent,
            _curseIncubationDurationSeconds,
            _commissionPerThousand
        );
    }

    // How much one must pay to create a new kingdom (in finney).
    // Can be changed by the topWizard.
    function kingdomCreationFeeInFinney() constant
    returns (uint feeInFinney) {
        return roundMoneyUpToWholeFinney(kingdomCreationFeeWei);
    }

    // Reject funds sent to the contract - wizards who cannot interact
    // with it via the API won't be able to withdraw their commission.
    function () {
        throw;
    }

    /// @notice Create a new kingdom using custom rules.
    /// @param _kingdomName \
    ///   e.g. "King of the Ether Throne"
    /// @param _startingClaimPriceWei \
    ///   How much it will cost the first monarch to claim the throne
    ///   (and also the price after the death of a monarch).
    /// @param _claimPriceAdjustPercent \
    ///   Percentage increase after each claim - e.g. if claim price
    ///   was 200 ETH, and `_claimPriceAdjustPercent` is 50, the next
    ///   claim price will be 200 ETH + (50% of 200 ETH) => 300 ETH.
    /// @param _curseIncubationDurationSeconds \
    ///   The maximum length of a time a monarch can rule before the
    ///   curse strikes and they are removed without compensation.
    /// @param _commissionPerThousand \
    ///   How much of each payment is given to the wizards to share,
    ///   expressed in parts per thousand - e.g. 25 means 25/1000,
    ///   or 2.5%.
    /// 
    /// Caller must include payment equal to kingdomCreationFeeWei.
    /// The caller will become the 'sub-wizard' and will earn half
    /// any commission charged by the Kingdom.  Note however they
    /// will need to call withdrawFunds() on the Kingdom contract
    /// to get their commission - it's not send automatically.
    ///
    /// Will consume up to 1,900,000 gas (!)
    /// Will throw an error if:
    ///   - name is invalid (see `validateProposedKingdomName(string)`)
    ///   - name is already in use (see `findKingdomCalled(string)`)
    ///   - rules are invalid (see `validateProposedKingdomRules(...)`)
    ///   - payment is too low or too high
    ///   - insufficient gas (quite likely!)
    /// Produces event KingdomCreatedEvent.
    function createKingdom(
        string _kingdomName,
        uint _startingClaimPriceWei,
        uint _claimPriceAdjustPercent,
        uint _curseIncubationDurationSeconds,
        uint _commissionPerThousand
    ) {
        externalEnter();
        createKingdomRP(
            _kingdomName,
            _startingClaimPriceWei,
            _claimPriceAdjustPercent,
            _curseIncubationDurationSeconds,
            _commissionPerThousand
        );
        externalLeave();
    }

    /// @notice Used by topWizard to transfer all rights to future
    /// fees and future kingdom wizardships to `_replacement` wizard.
    /// WARN: The original wizard retains ownership of any past fees
    /// held for them in the `funds` mapping, which they can still
    /// withdraw. They also remain topWizard in any existing Kingdoms.
    /// Produces event WizardReplacedEvent.
    function replaceWizard(address _replacement) {
        externalEnter();
        replaceWizardRP(_replacement);
        externalLeave();
    }

    /// @notice Used by topWizard to vary the fee for creating kingdoms.
    function setKingdomCreationFeeWei(uint _kingdomCreationFeeWei) {
        externalEnter();
        setKingdomCreationFeeWeiRP(_kingdomCreationFeeWei);
        externalLeave();
    }

    /// @notice Used by topWizard to vary the cap on claim price.
    function setMaximumClaimPriceWei(uint _maximumClaimPriceWei) {
        externalEnter();
        setMaximumClaimPriceWeiRP(_maximumClaimPriceWei);
        externalLeave();
    }

    /// @notice Used by topWizard to vary the factory contract which
    /// will be used to create future Kingdoms.
    function setKingdomFactory(KingdomFactory _kingdomFactory) {
        externalEnter();
        setKingdomFactoryRP(_kingdomFactory);
        externalLeave();
    }

    function createKingdomRP(
        string _kingdomName,
        uint _startingClaimPriceWei,
        uint _claimPriceAdjustPercent,
        uint _curseIncubationDurationSeconds,
        uint _commissionPerThousand
    ) internal {

        address subWizard = msg.sender;

        if (!validateNameInternal(_kingdomName)) {
            throw;
        }

        uint newKingdomNumber = kingdomsByNumber.length;
        checkUniqueAndRegisterNewKingdomName(
            _kingdomName,
            newKingdomNumber
        );

        uint paidWei = msg.value;
        if (paidWei < kingdomCreationFeeWei) {
            throw;
        }
        // Make it easy for people to pay using a whole number of finney,
        // which could be a teeny bit higher than the raw wei value.
        uint excessWei = paidWei - kingdomCreationFeeWei;
        if (excessWei > 1 finney) {
            throw;
        }
        funds[topWizard] += paidWei;
        
        // This will perform rule validation.
        Kingdom kingdomContract = kingdomFactory.createKingdom(
            _kingdomName,
            address(this),
            topWizard,
            subWizard,
            _startingClaimPriceWei,
            maximumClaimPriceWei,
            _claimPriceAdjustPercent,
            _curseIncubationDurationSeconds,
            _commissionPerThousand
        );

        kingdomsByNumber.push(KingdomListing(
            newKingdomNumber,
            _kingdomName,
            kingdomContract,
            msg.sender,
            now,
            kingdomFactory
        ));
    }

    function replaceWizardRP(address replacement) internal { 
        if (msg.sender != topWizard) {
            throw;
        }
        if (msg.value != 0) {
            throw;
        }
        address oldWizard = topWizard;
        topWizard = replacement;
        WizardReplacedEvent(oldWizard, replacement);
    }

    function setKingdomCreationFeeWeiRP(uint _kingdomCreationFeeWei) internal {
        if (msg.sender != topWizard) {
            throw;
        }
        if (msg.value != 0) {
            throw;
        }
        kingdomCreationFeeWei = _kingdomCreationFeeWei;
        CreationFeeChangedEvent(kingdomCreationFeeWei);
    }

    function setMaximumClaimPriceWeiRP(uint _maximumClaimPriceWei) internal {
        if (msg.sender != topWizard) {
            throw;
        }
        if (_maximumClaimPriceWei < 1 ether) {
            throw;
        }
        maximumClaimPriceWei = _maximumClaimPriceWei;
    }

    function setKingdomFactoryRP(KingdomFactory _kingdomFactory) internal {
        if (msg.sender != topWizard) {
            throw;
        }
        if (msg.value != 0) {
            throw;
        }
        kingdomFactory = _kingdomFactory;
        FactoryChangedEvent(kingdomFactory);
    }

    // If there is no existing kingdom called `_kingdomName`, create
    // a record mapping that name to kingdom no. `_newKingdomNumber`.
    // Throws an error if an existing kingdom with the same (or
    // fuzzily similar - see computeNameFuzzyHash) name exists.
    function checkUniqueAndRegisterNewKingdomName(
        string _kingdomName,
        uint _newKingdomNumber
    ) internal {
        uint fuzzyHash = computeNameFuzzyHash(_kingdomName);
        if (kingdomNumbersByfuzzyHash[fuzzyHash] != 0) {
            throw;
        }
        kingdomNumbersByfuzzyHash[fuzzyHash] = _newKingdomNumber;
    }

}


/// @title Used on the testnet to allow automated testing of internals.
contract ExposedInternalsForTesting is
  MoneyRounderMixin, NameableMixin {

    function roundMoneyDownNicelyET(uint _rawValueWei) constant
    returns (uint nicerValueWei) {
        return roundMoneyDownNicely(_rawValueWei);
    }

    function roundMoneyUpToWholeFinneyET(uint _valueWei) constant
    returns (uint valueFinney) {
        return roundMoneyUpToWholeFinney(_valueWei);
    }

    function validateNameInternalET(string _name) constant
    returns (bool allowed) {
        return validateNameInternal(_name);
    }

    function extractNameFromDataET(bytes _data) constant
    returns (string extractedName) {
        return extractNameFromData(_data);
    }
    
    function computeNameFuzzyHashET(string _name) constant
    returns (uint fuzzyHash) {
        return computeNameFuzzyHash(_name);
    }

}