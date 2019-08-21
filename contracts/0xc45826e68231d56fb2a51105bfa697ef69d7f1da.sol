pragma solidity ^0.4.23;

// ----------------------------------------------------------------------------
contract ERC20 {

    // ERC Token Standard #223 Interface
    // https://github.com/ethereum/EIPs/issues/223

    string public symbol;
    string public  name;
    uint8 public decimals;

    function transfer(address _to, uint _value, bytes _data) external returns (bool success);

    // approveAndCall
    function approveAndCall(address spender, uint tokens, bytes data) external returns (bool success);

    // ERC Token Standard #20 Interface
    // https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20.md


    function totalSupply() public constant returns (uint);
    function balanceOf(address tokenOwner) public constant returns (uint balance);
    function allowance(address tokenOwner, address spender) public constant returns (uint remaining);
    function transfer(address to, uint tokens) public returns (bool success);
    function approve(address spender, uint tokens) public returns (bool success);
    function transferFrom(address from, address to, uint tokens) public returns (bool success);
    event Transfer(address indexed from, address indexed to, uint tokens);
    event Approval(address indexed tokenOwner, address indexed spender, uint tokens);

    // bulk operations
    function transferBulk(address[] to, uint[] tokens) public;
    function approveBulk(address[] spender, uint[] tokens) public;
}


interface TokenRegistryInterface
{
    function getPriceInToken(ERC20 tokenContract, uint128 priceWei) external view returns (uint128);
    function areAllTokensAllowed(address[] tokens) external view returns (bool);
    function isTokenInList(address[] allowedTokens, address currentToken) external pure returns (bool);
    function getDefaultTokens() external view returns (address[]);
    function getDefaultCreatorTokens() external view returns (address[]);
    function onTokensReceived(ERC20 tokenContract, uint tokenCount) external;
    function withdrawEthFromBalance() external;
    function canConvertToEth(ERC20 tokenContract) external view returns (bool);
    function convertTokensToEth(ERC20 tokenContract, address seller, uint sellerValue, uint fee) external;
}

pragma solidity ^0.4.23;

// https://etherscan.io/address/0x3127be52acba38beab6b4b3a406dc04e557c037c#code
contract PriceOracleInterface {

    // How much TOKENs you get for 1 ETH, multiplied by 10^18
    uint256 public ETHPrice;
}

pragma solidity ^0.4.18;





/// @title Kyber Network interface
/// https://raw.githubusercontent.com/KyberNetwork/smart-contracts/master/contracts/KyberNetworkProxyInterface.sol
interface KyberNetworkProxyInterface {
    function getExpectedRate(ERC20 src, ERC20 dest, uint srcQty) external view returns (uint expectedRate, uint slippageRate);
    function swapTokenToEther(ERC20 token, uint srcAmount, uint minConversionRate) external returns(uint);
}

pragma solidity ^0.4.23;


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
  constructor() public {
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
    emit OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}


contract TokenRegistry is TokenRegistryInterface, Ownable
{
    mapping (address => PriceOracleInterface) public priceOracle;
    address[] public allTokens;
    address[] public allOracleTokens;
    mapping (address => bool) operators;
    mapping (address => KyberNetworkProxyInterface) public kyberOracle;
    ERC20 constant internal ETH_TOKEN_ADDRESS = ERC20(0x00eeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeeee);
    bool public allowConvertTokensToEth = true;

    modifier onlyOperator() {
        require(operators[msg.sender] || msg.sender == owner);
        _;
    }

    function addOperator(address _newOperator) public onlyOwner {
        operators[_newOperator] = true;
    }

    function removeOperator(address _oldOperator) public onlyOwner {
        delete(operators[_oldOperator]);
    }

    function setAllowConvertTokensToEth(bool _newValue) public onlyOwner
    {
        allowConvertTokensToEth = _newValue;
    }

    function getDefaultCreatorTokens() external view returns (address[])
    {
        return allOracleTokens;
    }

    function getDefaultTokens() external view returns (address[])
    {
        return allTokens;
    }

    function areAllTokensAllowed(address[] _tokens) external view returns (bool)
    {
        for (uint i = 0; i < _tokens.length; i++)
        {
            if (address(priceOracle[_tokens[i]]) == address(0x0) &&
                address(kyberOracle[_tokens[i]]) == address(0x0))
            {
                return false;
            }
        }
        return true;
    }

    function getPriceInToken(ERC20 _tokenContract, uint128 priceWei)
        external
        view
        returns (uint128)
    {
        if (isKyberToken(_tokenContract))
        {
            return getPriceInTokenKyber(_tokenContract, priceWei);
        }
        else
        {
            return getPriceInTokenOracle(_tokenContract, priceWei);
        }
    }

    function getPriceInTokenOracle(ERC20 _tokenContract, uint128 priceWei) public view returns (uint128)
    {
        PriceOracleInterface oracle = priceOracle[address(_tokenContract)];
        require(address(oracle) != address(0));

        uint256 ethPerToken = oracle.ETHPrice();
        int256 power = 36 - _tokenContract.decimals();
        require(power > 0);
        return uint128(uint256(priceWei) * ethPerToken / (10 ** uint256(power)));
    }

    function getPriceInTokenKyber(ERC20 _tokenContract, uint128 priceWei) public view returns (uint128)
    {
        KyberNetworkProxyInterface oracle = kyberOracle[address(_tokenContract)];
        require(address(oracle) != address(0));

        uint256 ethPerToken;
        (, ethPerToken) = oracle.getExpectedRate(ETH_TOKEN_ADDRESS, _tokenContract, priceWei);
        require(ethPerToken > 0);
        int256 power = 36 - _tokenContract.decimals();
        require(power > 0);
        return uint128(uint256(priceWei) * ethPerToken / (10 ** uint256(power)));
    }

    function isTokenInList(address[] _allowedTokens, address _currentToken) external pure returns (bool)
    {
        for (uint i = 0; i < _allowedTokens.length; i++)
        {
            if (_allowedTokens[i] == _currentToken)
            {
                return true;
            }
        }
        return false;
    }

    /// @dev Allow buy cuties for token
    function addToken(ERC20 _tokenContract, PriceOracleInterface _priceOracle) external onlyOwner
    {
        // check if not added yet
        require(address(priceOracle[address(_tokenContract)]) == address(0x0));
        require(address(kyberOracle[address(_tokenContract)]) == address(0x0));

        priceOracle[address(_tokenContract)] = _priceOracle;
        allTokens.push(_tokenContract);
        allOracleTokens.push(_tokenContract);
    }

    /// @dev Allow buy cuties for token
    function addKyberToken(ERC20 _tokenContract, KyberNetworkProxyInterface _priceOracle) external onlyOwner
    {
        // check if not added yet
        require(address(priceOracle[address(_tokenContract)]) == address(0x0));
        require(address(kyberOracle[address(_tokenContract)]) == address(0x0));

        kyberOracle[address(_tokenContract)] = _priceOracle;
        allTokens.push(_tokenContract);
    }

    /// @dev Disallow buy cuties for token
    function removeToken(ERC20 _tokenContract) external onlyOwner
    {
        delete priceOracle[address(_tokenContract)];
        delete kyberOracle[address(_tokenContract)];

        /*
        uint256 kindex = 0;
        while (kindex < allTokens.length)
        {
            if (address(allTokens[kindex]) == address(_tokenContract))
            {
                allTokens[kindex] = allTokens[allTokens.length-1];
                allTokens.length--;
            }
            else
            {
                kindex++;
            }
        }*/

        uint256 kindex = 0;
        while (kindex < allOracleTokens.length)
        {
            if (address(allOracleTokens[kindex]) == address(_tokenContract))
            {
                allOracleTokens[kindex] = allOracleTokens[allOracleTokens.length-1];
                allOracleTokens.length--;
            }
            else
            {
                kindex++;
            }
        }
    }

    // @dev Transfers to _withdrawToAddress all tokens controlled by
    // contract _tokenContract.
    function withdrawTokenFromBalance(ERC20 _tokenContract, address _withdrawToAddress) external onlyOperator
    {
        uint256 balance = _tokenContract.balanceOf(address(this));
        _tokenContract.transfer(_withdrawToAddress, balance);
    }

    function withdrawEthFromBalance() external onlyOperator
    {
        msg.sender.transfer(address(this).balance);
    }

    function onTokensReceived(ERC20 tokenContract, uint tokenCount) external onlyOperator
    {
        if (canConvertToEth(tokenContract))
        {
            _swapTokenToEther(
                kyberOracle[address(tokenContract)],
                tokenContract,
                tokenCount,
                this,
                0);
        }
    }

    function canConvertToEth(ERC20 tokenContract) public view returns (bool)
    {
        return allowConvertTokensToEth && isKyberToken(tokenContract);
    }

    function isKyberToken(ERC20 tokenContract) public view returns (bool)
    {
        return address(kyberOracle[address(tokenContract)]) != 0x0;
    }

    //@dev Converts tokens to ETH and transfers ETH to destAddress minus fee
    //@fee 0-10,000 means 0%-100%
    function convertTokensToEth(ERC20 tokenContract, address destAddress, uint tokenCount, uint fee) public onlyOperator
    {
        require(allowConvertTokensToEth);

        _swapTokenToEther(
            kyberOracle[address(tokenContract)],
            tokenContract,
            tokenCount,
            destAddress,
            fee);
    }

    //@param _kyberNetworkProxy kyberNetworkProxy contract address
    //@param token source token contract address
    //@param tokenQty token wei amount
    //@param destAddress address to send swapped ETH to
    //@fee 0-10,000 means 0%-100%
    function _swapTokenToEther(KyberNetworkProxyInterface _kyberNetworkProxy, ERC20 token, uint tokenQty, address destAddress, uint fee) internal {

        uint minRate;
        (, minRate) = _kyberNetworkProxy.getExpectedRate(token, ETH_TOKEN_ADDRESS, tokenQty);

        // Mitigate ERC20 Approve front-running attack, by initially setting
        // allowance to 0
        require(token.approve(_kyberNetworkProxy, 0));

        // Approve tokens so network can take them during the swap
        token.approve(address(_kyberNetworkProxy), tokenQty);
        uint destAmount = _kyberNetworkProxy.swapTokenToEther(token, tokenQty, minRate);

        if (destAddress != address(this))
        {
            // Send received ethers to destination address
            uint sellerValue = destAmount * (10000 - fee) / 10000;
            destAddress.transfer(sellerValue);
        }
    }

    function () external payable
    {
    }
}