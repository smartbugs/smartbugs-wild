pragma solidity ^0.4.24;

contract DiaOracle {
            address owner;

        struct CoinInfo {
                uint256 price;
                uint256 supply;
                uint256 lastUpdateTimestamp;
                string symbol;
        }

        mapping(string => CoinInfo) diaOracles;

        event newCoinInfo(
                string name,
                string symbol,
                uint256 price,
                uint256 supply,
                uint256 lastUpdateTimestamp
        );
    
        constructor() public {
                owner = msg.sender;
        }

        function changeOwner(address newOwner) public {
                require(msg.sender == owner);
                owner = newOwner;
        }
    
        function updateCoinInfo(string name, string symbol, uint256 newPrice, uint256 newSupply, uint256 newTimestamp) public {
                require(msg.sender == owner);
                diaOracles[name] = (CoinInfo(newPrice, newSupply, newTimestamp, symbol));
                emit newCoinInfo(name, symbol, newPrice, newSupply, newTimestamp);
        }
    
        function getCoinInfo(string name) public view returns (uint256, uint256, uint256, string) {
                return (
                        diaOracles[name].price,
                        diaOracles[name].supply,
                        diaOracles[name].lastUpdateTimestamp,
                        diaOracles[name].symbol
                );
        }
}

contract DiaAssetEurOracle {
    DiaOracle oracle;
    address owner;
    
    constructor() public {
        owner = msg.sender;
    }
    
    function setOracleAddress(address _address) public {
        require(msg.sender == owner);
        oracle = DiaOracle(_address);
    }
    
    function getAssetEurRate(string asset) constant public returns (uint256) {
        (uint ethPrice,,,) = oracle.getCoinInfo(asset);
        (uint eurPrice,,,) = oracle.getCoinInfo("EUR");
        return (ethPrice * 100000 / eurPrice);
    }
    
}