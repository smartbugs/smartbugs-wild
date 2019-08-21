# Contract multisend
# This contract is meant to send ethereum
# and ethereum tokens to several addresses
# in at most two ethereum transactions

# erc20 token abstract
class Token():
    def transfer(_to: address, _value: uint256) -> bool: modifying
    def transferFrom(_from: address, _to: address, _value: uint256) -> bool: modifying
    def allowance(_owner: address, _spender: address) -> uint256: constant


# Events



# Variables
owner: public(address)
sendTokenFee: public(wei_value) # wei
sendEthFee: public(wei_value) # wei


# Functions

# Set owner of the contract
@public
@payable
def __init__():
    self.owner = msg.sender


# MultisendEther
# accepts lists of addresses and corresponding amounts to be sent to them
# calculates the total amount and add fee
# distribute ether if sent ether is suficient
# return change back to the owner
@public
@payable
def multiSendEther(addresses: address[100], amounts: wei_value[100]) -> bool:
    sender: address = msg.sender
    total: wei_value = as_wei_value(0, "wei")
    zero_wei: wei_value = total
    value_sent: wei_value = msg.value
    
    # calculate total
    for n in range(100):
        if(amounts[n] <= zero_wei):
            break
        total += amounts[n]
        
    # required amount is amount plus fee
    requiredAmount: wei_value = total + (self.sendEthFee)

    # Check if sufficient eth amount was sent
    assert value_sent >= requiredAmount

    # Distribute ethereum
    for n in range(100):
        if(amounts[n] <= zero_wei):
            break
        send(addresses[n], as_wei_value(amounts[n], "wei"))

    # Send back excess amount
    if value_sent > requiredAmount:
        change: wei_value = value_sent - requiredAmount
        send(sender, as_wei_value(change, "wei"))

    return True


# Multisend tokens
# accepts token address, lists of addresses and corresponding amounts to be sent to them
# calculates the total amount and add fee
# distribute ether if sent ether is suficient
# return change back to the owner
@public
@payable
def multiSendToken(tokenAddress: address, addresses: address[100], amounts: uint256[100]) -> bool:
    sender: address = msg.sender
    total: int128 = 0
    value_sent: wei_value = msg.value
    for amount in amounts:
        total += convert(amount, int128)

    requiredWeiAmount: wei_value = self.sendTokenFee

    # Check if the correct amount of ether was sent
    assert value_sent >= requiredWeiAmount

    # Check if this contract is allowed to transfer
    # the required amount of token
    assert Token(tokenAddress).allowance(sender, self) >= convert(total, uint256)

    # Distribute the token
    for n in range(100):
        if amounts[n] <= 0:
            break
        assert Token(tokenAddress).transferFrom(sender, addresses[n], amounts[n])

    # Send back excess amount
    if value_sent > requiredWeiAmount:
        change: wei_value = value_sent - requiredWeiAmount
        send(sender, as_wei_value(change, "wei"))

    return True


# Other functions
@public
@constant
def getBalance(_address: address) -> wei_value:
    return _address.balance


@public
@constant
def calc_total(numbs: wei_value[100]) -> wei_value:
    total: wei_value = as_wei_value(0, "wei")
    zero_wei: wei_value = total
    for numb in numbs:
        if(as_wei_value(numb, "wei") <= zero_wei):
            break
        total += as_wei_value(numb, "wei")
    return total

    
@public
@constant
def find(numbs: wei_value[100], n: int128) -> wei_value:
    return numbs[n]

@public
@payable
def deposit() -> bool:
    return True


@public
def withdrawEther(_to: address, _value: uint256) -> bool:
    assert msg.sender == self.owner
    send(_to, as_wei_value(_value, "wei"))
    return True

@public
def withdrawToken(tokenAddress: address, _to: address, _value: uint256) -> bool:
    assert msg.sender == self.owner
    assert Token(tokenAddress).transfer(_to, _value)
    return True


@public
def setSendTokenFee(_sendTokenFee: uint256) -> bool:
    assert msg.sender == self.owner
    self.sendTokenFee = as_wei_value(_sendTokenFee, "wei")
    return True


@public
def setSendEthFee(_sendEthFee: wei_value) -> bool:
    assert msg.sender == self.owner
    self.sendEthFee = _sendEthFee
    return True


@public
def destroy(_to: address):
    assert msg.sender == self.owner
    selfdestruct(_to)