/**
 * Spork Token Contracts
 * See Spork contract below for more detail.
 *
 * The DAO and Spork is free software: you can redistribute it and/or modify
 * it under the terms of the GNU lesser General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * The DAO and Spork is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU lesser General Public License for more details.
 *
 * http://www.gnu.org/licenses/
 *
 * credit
 *   The DAO, Slock.it, Ethereum Foundation, EthCore, Consensys, pseudonymous
 *   rebels everywhere, and every lunch spot with proper eating utensils. ?
 */

/**
 * @title TokenInterface
 * @notice ERC 20 token standard and DAO token interface.
 */
contract TokenInterface {

    event Transfer(
        address indexed _from,
        address indexed _to,
        uint256 _amount);

    event Approval(
        address indexed _owner,
        address indexed _spender,
        uint256 _amount);

    mapping (address => // owner
        uint256) balances;

    mapping (address => // owner
    mapping (address => // spender
        uint256)) allowed;

    uint256 public totalSupply;

    function balanceOf(address _owner)
    constant
    returns (uint256 balance);

    function transfer(address _to, uint256 _amount)
    returns (bool success);

    function transferFrom(address _from, address _to, uint256 _amount)
    returns (bool success);

    function approve(address _spender, uint256 _amount)
    returns (bool success);

    function allowance(address _owner, address _spender)
    constant
    returns (uint256 remaining);

}

/**
 * @title Spork
 *
 * @notice A rogue upgrade token for The DAO. There is nothing safe about this
 *   contract or this life so strap in, bitches. You are responsible for you.
 *   A Spork is minted through burning DAO tokens. This is irreversible and for
 *   entertainment purposes. So why would you do this? Do it for love, do it
 *   for So Tokey Nada Mojito, do it for the lulz; just do it with conviction!
 *
 * usage
 *   1. Use The DAO to grant an allowance of DAO for the Spork contract.
 *      + `DAO.approve(spork_contract_address, amount_of_DAO_to_burn)`
 *      + Only grant the amount of DAO you are ready to destroy forever.
 *   2. Use the Spork mint function to ...
 *      1. Burn an amount of DAO up to the amount approved in the previous step.
 *      2. Mint an equivalent amount of Spork.
 *      3. Assign Spork tokens to the sender account.
 *   3. You now have Sporks. Dig in!
 */
contract Spork is TokenInterface {

    // crash and burn
    address constant TheDAO = 0xbb9bc244d798123fde783fcc1c72d3bb8c189413;

    event Mint(
        address indexed _sender,
        uint256 indexed _amount,
        string _lulz);

    // vanity attributes
    string public name = "Spork";
    string public symbol = "SPRK";
    string public version = "Spork:0.1";
    uint8 public decimals = 0;

    // @see {Spork.mint}
    function () {
        throw; // this is a coin, not a wallet.
    }

    /**
     * @notice Burn DAO tokens in exchange for Spork tokens
     * @param _amount Amount of DAO to burn and equivalent Spork to mint
     * @param _lulz If you gotta go, go with a smile! ?
     * @return Determine if request was successful
     */
    function mint(uint256 _amount, string _lulz)
    returns (bool success) {
        if (totalSupply + _amount <= totalSupply)
            return false; // zero or rollover value

        if (!TokenInterface(TheDAO).transferFrom(msg.sender, this, _amount))
            return false; // unable to retrieve DAO tokens for sender

        balances[msg.sender] += _amount;
        totalSupply += _amount;

        Mint(msg.sender, _amount, _lulz);
        return true;
    }

    /**
     * @notice Transfer Spork tokens from `msg.sender` to another account.
     * @param _to Account receiving tokens
     * @param _amount Amount of tokens to transfer
     * @return Determine if request was successful
     */
    function transfer(address _to, uint256 _amount)
    returns (bool success) {
        if (balances[_to] + _amount <= balances[_to])
            return false; // zero or rollover value

        if (balances[msg.sender] < _amount)
            return false; // party foul, sender does not have enough sporks

        balances[msg.sender] -= _amount;
        balances[_to] += _amount;

        Transfer(msg.sender, _to, _amount);
        return true;
    }

    /**
     * @notice Transfer Spork tokens from one account to another
     * @param _from Account holding tokens for which `msg.sender` is an approved
     *              spender with an allowance of at least `_amount` tokens
     * @param _to Account receiving tokens
     * @param _amount Amount of tokens to transfer
     * @return Determine if request was successful
     */
    function transferFrom(address _from, address _to, uint256 _amount)
    returns (bool success) {
        if (balances[_to] + _amount <= balances[_to])
            return false; // zero or rollover value

        if (allowed[_from][msg.sender] < _amount)
            return false; // sender does not have enough allowance

        if (balances[msg.sender] < _amount)
            return false; // party foul, sender does not have enough sporks

        balances[_to] += _amount;
        balances[_from] -= _amount;
        allowed[_from][msg.sender] -= _amount;

        Transfer(_from, _to, _amount);
        return true;
    }

    /**
     * @notice Determine the Spork token balance for an account
     * @param _owner Account holding tokens
     * @return Token balance
     */
    function balanceOf(address _owner)
    constant
    returns (uint256 balance) {
        return balances[_owner];
    }

    /**
     * @notice Approve an address to spend tokens on your behalf
     * @param _spender Account to spend tokens on behalf of `msg.sender`
     * @param _amount Maximum amount `_spender` can transfer from `msg.sender`
     * @return Determine if request was successful
     */
    function approve(address _spender, uint256 _amount)
    returns (bool success) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

    /**
     * @notice Maximum amount a spender can withdraw from an account
     * @param _owner The account holding tokens
     * @param _spender The account spending tokens
     * @return Remaining allowance `_spender` can withdraw from `_owner`
     */
    function allowance(address _owner, address _spender)
    constant
    returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }

}