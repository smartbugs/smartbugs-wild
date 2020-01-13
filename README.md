# SmartBugs Wild Dataset

This repository contain the 47,518 smart-contact extracted from the Ethereum network.

SmartBugs is available at: https://github.com/smartbugs/smartbugs

The results of the analysis of those contract is available at: https://github.com/smartbugs/smartbugs-results

## Structure of the repository

```
├─ contracts
│  └─ <contract_address>.sol
├─ contracts.csv.tar.gz # the meta data of all the contract
├─ script
│  ├─ get_contracts.py # collect the source code of the contracts from Etherscan
│  └─ get_balance.py   # collect the balance of the contracts from Etherscan
```

## Creation of the dataset

1. Collect the contract addresses
We use Google BigQuery to select all the contracts that have at least one transaction.
We use the following request (also available here: https://bigquery.cloud.google.com/savedquery/281902325312:47fd9afda3f8495184d98db6ae36a40c)
```sql
SELECT contracts.address, COUNT(1) AS tx_count
  FROM `ethereum_blockchain.contracts` AS contracts
  JOIN `ethereum_blockchain.transactions` AS transactions 
        ON (transactions.to_address = contracts.address)
  GROUP BY contracts.address
  ORDER BY tx_count DESC
```
2. Download the source code related to the contract addresses 
We use Etherscan to download to the contracts (the script of the collect is available in `script`).
3. We filter the contract by identifying the duplicate

## Metric

| Metric                        | Value   |
| ----------------------------- | ------- |
| Solidity source not available | 1290074 |
| Solidity source available     | 972975  |
| Unaccessible                  | 47      |
| Total                         | 2263096 |
| Unique Solidity Contracts     | 47518   |
| LOC of the unique contracts   | 9693457 |
