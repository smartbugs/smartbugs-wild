import os
from etherscan.accounts import Account
import json
import sys

TOKEN = sys.argv[1]

balances = {}
if os.path.exists('balances.json'):
    with open('balances.json') as fd:
        balances = json.load(fd)
count = 0
nb_contracts = 47518
with open('all_contract.csv') as fp:
    line = fp.readline()
    while line:
        address = line.split(',')[0]
        count += 1
        if address == 'address' or address in balances:
            line = fp.readline()
            continue
        if count % 20 == 0:
            with open('balances.json', 'w') as fd:
                json.dump(balances, fd)
        print(count, '/', nb_contracts, round(count * 100 / nb_contracts, 2), '%')
        try:
            api = Account(address=address, api_key=TOKEN)
            balance = int(api.get_balance())
            balances[address] = balance
        except Exception as identifier:
            print(identifier)
            continue
        line = fp.readline()
    