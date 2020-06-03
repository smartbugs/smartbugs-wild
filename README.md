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

1. **Collection of the contract addresses.**
We used Google BigQuery to select all the contracts that have at least one transaction.
The collection was performed on the 8th of August 2019. We used the following request (also available here: https://bigquery.cloud.google.com/savedquery/281902325312:47fd9afda3f8495184d98db6ae36a40c)
```sql
SELECT contracts.address, COUNT(1) AS tx_count
  FROM `ethereum_blockchain.contracts` AS contracts
  JOIN `ethereum_blockchain.transactions` AS transactions 
        ON (transactions.to_address = contracts.address)
  GROUP BY contracts.address
  ORDER BY tx_count DESC
```

2. **Downloading the source code associated with the contract addresses.**
We used [Etherscan](https://etherscan.io) to download the contracts (the script used for the collection is available in the folder `script`).
3. We filtered the contracts by identifying and removing duplicates.

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

## License

The license in the file `LICENSE` applies to all the files in this repository, except for all the files in the `contracts` folder. The files in this folder are publicly available, were obtained using the [Etherscan APIs](https://etherscan.io/apis), and retain their original licenses. Please contact us for any additional questions.
