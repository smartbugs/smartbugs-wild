pragma solidity ^0.4.24;

// File: openzeppelin-solidity/contracts/token/ERC20/IERC20.sol

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
interface IERC20 {
  function totalSupply() external view returns (uint256);

  function balanceOf(address who) external view returns (uint256);

  function allowance(address owner, address spender)
    external view returns (uint256);

  function transfer(address to, uint256 value) external returns (bool);

  function approve(address spender, uint256 value)
    external returns (bool);

  function transferFrom(address from, address to, uint256 value)
    external returns (bool);

  event Transfer(
    address indexed from,
    address indexed to,
    uint256 value
  );

  event Approval(
    address indexed owner,
    address indexed spender,
    uint256 value
  );
}

// File: openzeppelin-solidity/contracts/math/SafeMath.sol

/**
 * @title SafeMath
 * @dev Math operations with safety checks that revert on error
 */
library SafeMath {

  /**
  * @dev Multiplies two numbers, reverts on overflow.
  */
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    // Gas optimization: this is cheaper than requiring 'a' not being zero, but the
    // benefit is lost if 'b' is also tested.
    // See: https://github.com/OpenZeppelin/openzeppelin-solidity/pull/522
    if (a == 0) {
      return 0;
    }

    uint256 c = a * b;
    require(c / a == b);

    return c;
  }

  /**
  * @dev Integer division of two numbers truncating the quotient, reverts on division by zero.
  */
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b > 0); // Solidity only automatically asserts when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold

    return c;
  }

  /**
  * @dev Subtracts two numbers, reverts on overflow (i.e. if subtrahend is greater than minuend).
  */
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b <= a);
    uint256 c = a - b;

    return c;
  }

  /**
  * @dev Adds two numbers, reverts on overflow.
  */
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    require(c >= a);

    return c;
  }

  /**
  * @dev Divides two numbers and returns the remainder (unsigned integer modulo),
  * reverts when dividing by zero.
  */
  function mod(uint256 a, uint256 b) internal pure returns (uint256) {
    require(b != 0);
    return a % b;
  }
}

// File: contracts/ExternalCall.sol

library ExternalCall {
    // Source: https://github.com/gnosis/MultiSigWallet/blob/master/contracts/MultiSigWallet.sol
    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function externalCall(address destination, uint value, bytes data, uint dataOffset, uint dataLength) internal returns(bool result) {
        // solium-disable-next-line security/no-inline-assembly
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas, 34710),   // 34710 is the value that solidity is currently emitting
                                   // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
                                   // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
                destination,
                value,
                add(d, dataOffset),
                dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0                  // Output is ignored, therefore the output size is zero
            )
        }
    }
}

// File: contracts/ISetToken.sol

/*
    Copyright 2018 Set Labs Inc.

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

pragma solidity ^0.4.24;


/**
 * @title ISetToken
 * @author Set Protocol
 *
 * The ISetToken interface provides a light-weight, structured way to interact with the
 * SetToken contract from another contract.
 */
interface ISetToken {

    /* ============ External Functions ============ */

    /*
     * Issue token set
     *
     * @param  amount     Amount of set being issued
     */
    function issue(uint256 amount)
        external;

    /*
     * Redeem token set
     *
     * @param  amount     Amount of set being redeemed
     */
    function redeem(uint256 amount)
        external;

    /*
     * Get natural unit of Set
     *
     * @return  uint256       Natural unit of Set
     */
    function naturalUnit()
        external
        view
        returns (uint256);

    /*
     * Get addresses of all components in the Set
     *
     * @return  componentAddresses       Array of component tokens
     */
    function getComponents()
        external
        view
        returns(address[]);

    /*
     * Get units of all tokens in Set
     *
     * @return  units       Array of component units
     */
    function getUnits()
        external
        view
        returns(uint256[]);

    /*
     * Checks to make sure token is component of Set
     *
     * @param  _tokenAddress     Address of token being checked
     * @return  bool             True if token is component of Set
     */
    function tokenIsComponent(
        address _tokenAddress
    )
        external
        view
        returns (bool);

    /*
     * Mint set token for given address.
     * Can only be called by authorized contracts.
     *
     * @param  _issuer      The address of the issuing account
     * @param  _quantity    The number of sets to attribute to issuer
     */
    function mint(
        address _issuer,
        uint256 _quantity
    )
        external;

    /*
     * Burn set token for given address
     * Can only be called by authorized contracts
     *
     * @param  _from        The address of the redeeming account
     * @param  _quantity    The number of sets to burn from redeemer
     */
    function burn(
        address _from,
        uint256 _quantity
    )
        external;

    /**
    * Balance of token for a specified address
    *
    * @param who  The address
    * @return uint256 Balance of address
    */
    function balanceOf(
        address who
    )
        external
        view
        returns (uint256);

    /**
    * Transfer token for a specified address
    *
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transfer(
        address to,
        uint256 value
    )
        external
        returns (bool);

    /**
    * Transfer token for a specified address
    *
    * @param from The address to transfer from.
    * @param to The address to transfer to.
    * @param value The amount to be transferred.
    */
    function transferFrom(
        address from,
        address to,
        uint256 value
    )
        external
        returns (bool);
}

// File: contracts/SetBuyer.sol

contract IKyberNetworkProxy {
    function tradeWithHint(
        address src,
        uint256 srcAmount,
        address dest,
        address destAddress,
        uint256 maxDestAmount,
        uint256 minConversionRate,
        address walletId,
        bytes hint
    )
        public
        payable
        returns(uint);

    function getExpectedRate(
        address source,
        address dest,
        uint srcQty
    )
        public
        view
        returns (
            uint expectedPrice,
            uint slippagePrice
        );
}


contract SetBuyer {
    using SafeMath for uint256;
    using ExternalCall for address;

    address constant public ETHER_ADDRESS = 0xEeeeeEeeeEeEeeEeEeEeeEEEeeeeEeeeeeeeEEeE;

    function buy(
        ISetToken set,
        IKyberNetworkProxy kyber
    )
        public
        payable
    {
        address[] memory components = set.getComponents();
        uint256[] memory units = set.getUnits();

        uint256 weightSum = 0;
        uint256[] memory weight = new uint256[](components.length);
        for (uint i = 0; i < components.length; i++) {
            (weight[i], ) = kyber.getExpectedRate(components[i], ETHER_ADDRESS, units[i]);
            weightSum = weightSum.add(weight[i]);
        }

        uint256 fitMintAmount = uint256(-1);
        for (i = 0; i < components.length; i++) {
            IERC20 token = IERC20(components[i]);

            if (token.allowance(this, set) == 0) {
                require(token.approve(set, uint256(-1)), "Approve failed");
            }

            uint256 amount = msg.value.mul(weight[i]).div(weightSum);
            uint256 received = kyber.tradeWithHint.value(amount)(
                ETHER_ADDRESS,
                amount,
                components[i],
                this,
                1 << 255,
                0,
                0,
                ""
            );

            if (received / units[i] < fitMintAmount) {
                fitMintAmount = received / units[i];
            }
        }

        set.issue(fitMintAmount * set.naturalUnit());
        set.transfer(msg.sender, set.balanceOf(this));

        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
        for (i = 0; i < components.length; i++) {
            token = IERC20(components[i]);
            if (token.balanceOf(this) > 0) {
                require(token.transfer(msg.sender, token.balanceOf(this)), "transfer failed");
            }
        }
    }

    function() public payable {
        require(tx.origin != msg.sender);
    }

    function sell(
        ISetToken set,
        uint256 amountArg,
        IKyberNetworkProxy kyber
    )
        public
    {
        uint256 naturalUnit = set.naturalUnit();
        uint256 amount = amountArg.div(naturalUnit).mul(naturalUnit);

        set.transferFrom(msg.sender, this, amount);
        set.redeem(amount);

        address[] memory components = set.getComponents();

        for (uint i = 0; i < components.length; i++) {
            IERC20 token = IERC20(components[i]);

            if (token.allowance(this, kyber) == 0) {
                require(token.approve(kyber, uint256(-1)), "Approve failed");
            }

            kyber.tradeWithHint(
                components[i],
                token.balanceOf(this),
                ETHER_ADDRESS,
                this,
                1 << 255,
                0,
                0,
                ""
            );

            if (token.balanceOf(this) > 0) {
                require(token.transfer(msg.sender, token.balanceOf(this)), "transfer failed");
            }
        }

        if (address(this).balance > 0) {
            msg.sender.transfer(address(this).balance);
        }
    }
}