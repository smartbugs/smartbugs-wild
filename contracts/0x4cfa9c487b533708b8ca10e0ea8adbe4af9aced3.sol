# @title Serenus Coin ERC20 contract
# @notice Implements https://github.com/ethereum/EIPs/blob/master/EIPS/eip-20-token-standard.md
# @notice All mint/burn calls are acceptable only if the issuer is approved by the Factory contract
# @notice Source code found at https://github.com/serenuscoin
# @notice Use at your own risk
# @dev Compiled with Vyper 0.1.0b8

# @dev Contract interface to serenus issuer and governor
contract Issuer:
    def nonce() -> int128: constant

contract Governor:
    def nonce() -> int128: constant

# @dev Events issued by the contract
Transfer: event({_from: indexed(address), _to: indexed(address), _value: uint256(wei)})
Approval: event({_owner: indexed(address), _spender: indexed(address), _value: uint256(wei)})
OpenMinter: event({_newMinter: indexed(address)})
CloseMinter: event({_oldMinter: indexed(address)})

governor: Governor

factory_address: public(address)

minter_addresses: public(map(address, bool))
owner: public(address)
name: public(bytes[12])
symbol: public(bytes[3])
decimals: public(uint256)
commission: public(uint256)
balances: public(map(address, uint256(wei)))
allowances: map(address, map(address, uint256(wei)))
num_issued: uint256(wei)

@public
def __init__():
    self.owner = msg.sender
    self.name = "Serenus Coin"
    self.symbol = "SRS"
    self.decimals = 18
    self.commission = 10

@public
def changeOwner(_address: address):
    assert msg.sender == self.owner
    self.owner = _address

# @notice Burn tokens if the issuer is valid and the governor nonces match
# @params Seller address holding tokens
# @params Amount to be burnt from that address
@public
def burn(_seller: address, _amount: uint256(wei)):
    assert self.minter_addresses[msg.sender] == True
    assert self.governor.nonce() == Issuer(msg.sender).nonce()

    assert self.balances[_seller] >= _amount
    self.balances[_seller] -= _amount
    self.num_issued -= _amount
    log.Transfer(_seller, ZERO_ADDRESS, _amount)  # log transfer event.

# @notice Mint tokens if the issuer is valid and the governor nonces match
# @params Buyer address to send tokens
# @params Amount to be minted to that address
@public
def mint(_buyer: address, _amount: uint256(wei)):
    assert self.minter_addresses[msg.sender] == True
    assert self.governor.nonce() == Issuer(msg.sender).nonce()
    
    commissionAmount: uint256(wei) = (_amount * self.commission) / 10000

    self.balances[self.owner] += commissionAmount

    self.balances[_buyer] += _amount - commissionAmount

    self.num_issued += _amount

    log.Transfer(ZERO_ADDRESS, _buyer, _amount - commissionAmount )  # log transfer event.
    log.Transfer(ZERO_ADDRESS, self.owner, commissionAmount )  # log transfer event.

@public
def setGovernorAddress(_address: address):
    assert msg.sender == self.owner
    self.governor = _address

@public
def setFactoryAddress(_address: address):
    assert msg.sender == self.owner
    self.factory_address = _address
    
# @notice Set a new issuer as minter if created by the factory
@public
def setMinterAddress(_new_issuer: address):
    assert msg.sender == self.factory_address
    self.minter_addresses[_new_issuer] = True
    log.OpenMinter(_new_issuer)

# @notice Remove an issuer as minter if that issuer requests it
@public
def removeMinterAddress():
    assert self.minter_addresses[msg.sender] == True
    self.minter_addresses[msg.sender] = False
    log.CloseMinter(msg.sender)
    
@public
@constant
def totalSupply() -> uint256(wei):
    return self.num_issued

@public
@constant
def balanceOf(_owner : address) -> uint256(wei):
    return self.balances[_owner]

@public
def transfer(_to : address, _value : uint256(wei)) -> bool:
    _sender: address = msg.sender
    self.balances[_sender] -= _value
    self.balances[_to] += _value

    log.Transfer(_sender, _to, _value)
    return True

@public
def transferFrom(_from : address, _to : address, _value : uint256(wei)) -> bool:
    _sender: address = msg.sender
    self.balances[_from] -= _value
    self.balances[_to] += _value
    self.allowances[_from][_sender] -= _value

    log.Transfer(_from, _to, _value)
    return True

@public
def approve(_spender : address, _value : uint256(wei)) -> bool:
    _sender: address = msg.sender
    self.allowances[_sender][_spender] = _value

    log.Approval(_sender, _spender, _value)
    return True

@public
@constant
def allowance(_owner : address, _spender : address) -> uint256(wei):
    return self.allowances[_owner][_spender]