# SmartBugs Wild Dataset

This repository contains 47,398 smart contracts extracted from the Ethereum network.

[SmartBugs](https://github.com/smartbugs/smartbugs) was used to analyze this
dataset. The results are available at: [https://github.com/smartbugs/smartbugs-results](https://github.com/smartbugs/smartbugs-results)
For more details on the analysis, please see [the ICSE 2020 paper](https://arxiv.org/abs/1910.10601).

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
3. We filter the contracts by identifying duplicates

## Metrics

| Metric                        | Value   |
| ----------------------------- | ------- |
| Solidity source not available | 1290074 |
| Solidity source available     | 972855  |
| Unaccessible                  | 47      |
| Invalid                       | 120     |
| Total                         | 2263096 |
| Unique Solidity Contracts     | 47398   |
| LOC of the unique contracts   | 9693457 |
