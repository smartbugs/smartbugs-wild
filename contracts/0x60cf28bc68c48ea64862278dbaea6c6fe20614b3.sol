{"SafeMath.sol":{"content":"pragma solidity 0.4.24;\n\n/**\n * Math operations with safety checks that throw on overflows.\n */\nlibrary SafeMath {\n    \n    function mul (uint256 a, uint256 b) internal pure returns (uint256 c) {\n        if (a == 0) {\n            return 0;\n        }\n        c = a * b;\n        require(c / a == b);\n        return c;\n    }\n    \n    function div (uint256 a, uint256 b) internal pure returns (uint256) {\n        // assert(b \u003e 0); // Solidity automatically throws when dividing by 0\n        // uint256 c = a / b;\n        // assert(a == b * c + a % b); // There is no case in which this doesn\u0027t hold\n        return a / b;\n    }\n    \n    function sub (uint256 a, uint256 b) internal pure returns (uint256) {\n        require(b \u003c= a);\n        return a - b;\n    }\n\n    function add (uint256 a, uint256 b) internal pure returns (uint256 c) {\n        c = a + b;\n        require(c \u003e= a);\n        return c;\n    }\n\n}"},"TheNuxCoin.sol":{"content":"pragma solidity 0.4.24;\n\nimport \"SafeMath.sol\";\n\n/**\n * TheNux Coin token contract. It implements the next capabilities:\n * 1. Standard ERC20 functionality. [OK]\n * 2. Additional utility function approveAndCall. [OK]\n * 3. Function to rescue \"lost forever\" tokens, which were accidentally sent to the contract address. [OK]\n * 4. Additional transfer and approve functions which allow to distinct the transaction signer and executor,\n *    which enables accounts with no Ether on their balances to make token transfers and use TheNux Coin services. [OK]\n * 5. Token sale distribution rules. [OK]\n */\ncontract TheNuxCoin {\n\n    using SafeMath for uint256;\n\n    string public name;\n    string public symbol;\n    uint8 public decimals; // Makes JavaScript able to handle precise calculations (until totalSupply \u003c 9 milliards)\n    uint256 public totalSupply;\n    mapping(address =\u003e uint256) public balanceOf;\n    mapping(address =\u003e mapping(address =\u003e uint256)) public allowance;\n    mapping(address =\u003e mapping(uint =\u003e bool)) public usedSigIds; // Used in *ViaSignature(..)\n    address public tokenDistributor; // Account authorized to distribute tokens only during the token distribution event\n\n    event Transfer(address indexed from, address indexed to, uint256 value);\n    event Approval(address indexed owner, address indexed spender, uint256 value);\n\n    modifier tokenDistributionPeriodOnly {require(tokenDistributor == msg.sender); _;}\n\n    enum sigStandard { typed, personal, stringHex }\n\n    bytes constant public ethSignedMessagePrefix = \"\\x19Ethereum Signed Message:\\n\";\n    bytes32 constant public sigDestinationTransfer = keccak256(\n        \"address Token Contract Address\",\n        \"address Sender\u0027s Address\",\n        \"address Recipient\u0027s Address\",\n        \"uint256 Amount to Transfer (last six digits are decimals)\",\n        \"uint256 Fee in Tokens Paid to Executor (last six digits are decimals)\",\n        \"address Account which will Receive Fee\",\n        \"uint256 Signature Expiration Timestamp (unix timestamp)\",\n        \"uint256 Signature ID\"\n    ); // `transferViaSignature`: keccak256(address(this), from, to, value, fee, deadline, sigId)\n\n    /**\n     * @param tokenName - full token name\n     * @param tokenSymbol - token symbol\n     */\n    constructor (string tokenName, string tokenSymbol, uint8 tokenDecimals, uint256 tokenTotalSupply) public {\n        name = tokenName;\n        symbol = tokenSymbol;\n        decimals = tokenDecimals;\n        totalSupply = tokenTotalSupply;\n        balanceOf[msg.sender] = balanceOf[msg.sender].add(tokenTotalSupply);\n        tokenDistributor = msg.sender;\n    }\n\n    /**\n     * Utility internal function used to safely transfer `value` tokens `from` -\u003e `to`. Throws if transfer is impossible.\n     * @param from - account to make the transfer from\n     * @param to - account to transfer `value` tokens to\n     * @param value - tokens to transfer to account `to`\n     */\n    function internalTransfer (address from, address to, uint value) internal {\n        require(to != 0x0); // Prevent people from accidentally burning their tokens\n        balanceOf[from] = balanceOf[from].sub(value);\n        balanceOf[to] = balanceOf[to].add(value);\n        emit Transfer(from, to, value);\n    }\n\n    /**\n     * Utility internal function used to safely transfer `value1` tokens `from` -\u003e `to1`, and `value2` tokens\n     * `from` -\u003e `to2`, minimizing gas usage (calling `internalTransfer` twice is more expensive). Throws if\n     * transfers are impossible.\n     * @param from - account to make the transfer from\n     * @param to1 - account to transfer `value1` tokens to\n     * @param value1 - tokens to transfer to account `to1`\n     * @param to2 - account to transfer `value2` tokens to\n     * @param value2 - tokens to transfer to account `to2`\n     */\n    function internalDoubleTransfer (address from, address to1, uint value1, address to2, uint value2) internal {\n        require(to1 != 0x0 \u0026\u0026 to2 != 0x0); // Prevent people from accidentally burning their tokens\n        balanceOf[from] = balanceOf[from].sub(value1.add(value2));\n        balanceOf[to1] = balanceOf[to1].add(value1);\n        emit Transfer(from, to1, value1);\n        if (value2 \u003e 0) {\n            balanceOf[to2] = balanceOf[to2].add(value2);\n            emit Transfer(from, to2, value2);\n        }\n    }\n\n    /**\n     * Internal method that makes sure that the given signature corresponds to a given data and is made by `signer`.\n     * It utilizes three (four) standards of message signing in Ethereum, as at the moment of this smart contract\n     * development there is no single signing standard defined. For example, Metamask and Geth both support\n     * personal_sign standard, SignTypedData is only supported by Matamask, Trezor does not support \"widely adopted\"\n     * Ethereum personal_sign but rather personal_sign with fixed prefix and so on.\n     * Note that it is always possible to forge any of these signatures using the private key, the problem is that\n     * third-party wallets must adopt a single standard for signing messages.\n     * @param data - original data which had to be signed by `signer`\n     * @param signer - account which made a signature\n     * @param deadline - until when the signature is valid\n     * @param sigId - signature unique ID. Signatures made with the same signature ID cannot be submitted twice\n     * @param sig - signature made by `from`, which is the proof of `from`\u0027s agreement with the above parameters\n     * @param sigStd - chosen standard for signature validation. The signer must explicitly tell which standard they use\n     */\n    function requireSignature (\n        bytes32 data,\n        address signer,\n        uint256 deadline,\n        uint256 sigId,\n        bytes sig,\n        sigStandard sigStd\n    ) internal {\n        bytes32 r;\n        bytes32 s;\n        uint8 v;\n        assembly { // solium-disable-line security/no-inline-assembly\n            r := mload(add(sig, 32))\n            s := mload(add(sig, 64))\n            v := byte(0, mload(add(sig, 96)))\n        }\n        if (v \u003c 27)\n            v += 27;\n        require(block.timestamp \u003c= deadline \u0026\u0026 !usedSigIds[signer][sigId]); // solium-disable-line security/no-block-members\n        if (sigStd == sigStandard.typed) { // Typed signature. This is the most likely scenario to be used and accepted\n            require(\n                signer == ecrecover(\n                    keccak256(\n                        sigDestinationTransfer,\n                        data\n                    ),\n                    v, r, s\n                )\n            );\n        } else if (sigStd == sigStandard.personal) { // Ethereum signed message signature (Geth and Trezor)\n            require(\n                signer == ecrecover(keccak256(ethSignedMessagePrefix, \"32\", data), v, r, s) // Geth-adopted\n                ||\n                signer == ecrecover(keccak256(ethSignedMessagePrefix, \"\\x20\", data), v, r, s) // Trezor-adopted\n            );\n        } else { // == 2; Signed string hash signature (the most expensive but universal)\n            require(\n                signer == ecrecover(keccak256(ethSignedMessagePrefix, \"64\", hexToString(data)), v, r, s) // Geth\n                ||\n                signer == ecrecover(keccak256(ethSignedMessagePrefix, \"\\x40\", hexToString(data)), v, r, s) // Trezor\n            );\n        }\n        usedSigIds[signer][sigId] = true;\n    }\n\n    /**\n     * Utility costly function to encode bytes HEX representation as string.\n     * @param sig - signature as bytes32 to represent as string\n     */\n    function hexToString (bytes32 sig) internal pure returns (bytes) { // /to-try/ convert to two uint256 and test gas\n        bytes memory str = new bytes(64);\n        for (uint8 i = 0; i \u003c 32; ++i) {\n            str[2 * i] = byte((uint8(sig[i]) / 16 \u003c 10 ? 48 : 87) + uint8(sig[i]) / 16);\n            str[2 * i + 1] = byte((uint8(sig[i]) % 16 \u003c 10 ? 48 : 87) + (uint8(sig[i]) % 16));\n        }\n        return str;\n    }\n\n    /**\n     * Transfer `value` tokens to `to` address from the account of sender.\n     * @param to - the address of the recipient\n     * @param value - the amount to send\n     */\n    function transfer (address to, uint256 value) public returns (bool) {\n        internalTransfer(msg.sender, to, value);\n        return true;\n    }\n\n    /**\n     * This function distincts transaction signer from transaction executor. It allows anyone to transfer tokens\n     * from the `from` account by providing a valid signature, which can only be obtained from the `from` account\n     * owner.\n     * Note that passed parameter sigId is unique and cannot be passed twice (prevents replay attacks). When there\u0027s\n     * a need to make signature once again (because the first on is lost or whatever), user should sign the message\n     * with the same sigId, thus ensuring that the previous signature won\u0027t be used if the new one passes.\n     * Use case: the user wants to send some tokens to other user or smart contract, but don\u0027t have ether to do so.\n     * @param from - the account giving its signature to transfer `value` tokens to `to` address\n     * @param to - the account receiving `value` tokens\n     * @param value - the value in tokens to transfer\n     * @param fee - a fee to pay to `feeRecipient`\n     * @param feeRecipient - account which will receive fee\n     * @param deadline - until when the signature is valid\n     * @param sigId - signature unique ID. Signatures made with the same signature ID cannot be submitted twice\n     * @param sig - signature made by `from`, which is the proof of `from`\u0027s agreement with the above parameters\n     * @param sigStd - chosen standard for signature validation. The signer must explicitly tell which standard they use\n     */\n    function transferViaSignature (  \n        address     from,\n        address     to,\n        uint256     value,\n        uint256     fee,\n        address     feeRecipient,\n        uint256     deadline,\n        uint256     sigId,\n        bytes       sig,\n        sigStandard sigStd\n    ) external returns (bool) {\n        requireSignature(\n            keccak256(address(this), from, to, value, fee, feeRecipient, deadline, sigId),\n            from, deadline, sigId, sig, sigStd\n        );\n        internalDoubleTransfer(from, to, value, feeRecipient, fee);\n        return true;\n    }\n\n    /**\n     * Allow `spender` to take `value` tokens from the transaction sender\u0027s account.\n     * Beware that changing an allowance with this method brings the risk that `spender` may use both the old\n     * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this\n     * race condition is to first reduce the spender\u0027s allowance to 0 and set the desired value afterwards:\n     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729\n     * @param spender - the address authorized to spend\n     * @param value - the maximum amount they can spend\n     */\n    function approve (address spender, uint256 value) public returns (bool) {\n        allowance[msg.sender][spender] = value;\n        emit Approval(msg.sender, spender, value);\n        return true;\n    }\n\n    /**\n     * Transfer `value` tokens to `to` address from the `from` account, using the previously set allowance.\n     * @param from - the address to transfer tokens from\n     * @param to - the address of the recipient\n     * @param value - the amount to send\n     */\n    function transferFrom (address from, address to, uint256 value) public returns (bool) {\n        allowance[from][msg.sender] = allowance[from][msg.sender].sub(value);\n        internalTransfer(from, to, value);\n        return true;\n    }\n\n    /**\n     * `tokenDistributor` is authorized to distribute tokens to the parties who participated in the token sale by the\n     * time the `lastMint` function is triggered, which closes the ability to mint any new tokens forever.\n     * Once the token distribution even ends (lastMint is triggered), tokenDistributor will become 0x0 and multiMint\n     * function will never work again.\n     * @param recipients - addresses of token recipients\n     * @param amounts - corresponding amount of each token recipient in `recipients`\n     */\n    function multiMint (address[] recipients, uint256[] amounts) external tokenDistributionPeriodOnly {\n        require(recipients.length == amounts.length);\n\n        uint total = 0;\n\n        for (uint i = 0; i \u003c recipients.length; ++i) {\n            balanceOf[recipients[i]] = balanceOf[recipients[i]].add(amounts[i]);\n            total = total.add(amounts[i]);\n            emit Transfer(0x0, recipients[i], amounts[i]);\n        }\n\n        totalSupply = totalSupply.add(total);\n    }\n\n}"}}