pragma solidity >=0.5.0 <0.6.0;

// we need only a single method of Maker's Medianizer contract
interface IMakerPriceFeed {
    // https://github.com/makerdao/medianizer/blob/master/src/medianizer.sol#L87
    function read() external view returns (bytes32);
}

interface IERC20 {
    function transfer(address _to, uint256 _value) external returns (bool success);
    function balanceOf(address _owner) external view returns (uint256 balance);
}

/**
 * Simple swap contract which allows anybody to swap ETH for a specific ERC-20 token (chosen on deploy) for an USD denominated price.
 * The price in ETH is calculated using the Maker Feeds of the DAI Stablecoin System.
 */
contract EthToErc20Swap {
    address public owner;

    // price of 1 erc20 token in milli-USD
    uint256 public erc20mUSDPrice;
    IMakerPriceFeed ethPriceFeedContract;
    IERC20 erc20TokenContract;

    event Swapped(address account, uint256 ethAmount, uint256 erc20Amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "no permission");
        _;
    }

    // "0x729D19f657BD0614b4985Cf1D82531c67569197B" for the feed on Ethereum
    // "0xe41dd6e41f8f9962c5103d95d95f5d9b82d90fdf" for ATS20 on Ethereum
    constructor(address ethPriceFeedAddr, address erc20TokenAddr, uint256 initialErc20mUSDPrice) public {
        owner = msg.sender;
        ethPriceFeedContract = IMakerPriceFeed(ethPriceFeedAddr);
        erc20TokenContract = IERC20(erc20TokenAddr);
        setPriceInmUSD(initialErc20mUSDPrice);
    }

    // Sending ETH to the contract triggers the swap. If it fails for some reason, the sender won't lose anything (except the tx fee).
    function () external payable {
        // returns the price with 18 digits as bytes32 which can safely be casted to uint256. Will throw if the system has no reliable price.
        // 15 digits are cut off in order to get mUSD
        uint256 ethmUSDPrice = uint256(ethPriceFeedContract.read()) / 1E15;
        uint256 erc20Amount = msg.value * ethmUSDPrice / erc20mUSDPrice;

        // will throw if the sender (our) balance is insufficient
        erc20TokenContract.transfer(msg.sender, erc20Amount);

        emit Swapped(msg.sender, msg.value, erc20Amount);
    }

    function setOwner(address newOwner) public onlyOwner {
        owner = newOwner;
    }

    function setPriceInmUSD(uint256 newPrice) public onlyOwner {
        require(newPrice > 0);
        erc20mUSDPrice = newPrice;
    }

    // withdraw all tokens owned by the contract to the given receiver
    function withdrawErc20To(address receiver) external onlyOwner  {
        uint256 amount = erc20TokenContract.balanceOf(address(this));
        erc20TokenContract.transfer(receiver, amount);
    }

    function withdrawEthTo(address payable receiver) external onlyOwner {
        receiver.transfer(address(this).balance);
    }
}