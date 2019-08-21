pragma solidity ^0.4.13;

contract Database
{
    address public m_Owner;
    address public m_Owner2;
    address public m_Creator;
    mapping(address => mapping(uint256 => mapping(uint256 => bytes32))) public m_Data;

    modifier OnlyOwner()
    {
        require(msg.sender == m_Owner || msg.sender == m_Owner2);

        _;
    }

    function() public payable
    {

    }

    function Database() public
    {
        m_Owner = address(0);
        m_Owner2 = address(0);
        m_Creator = msg.sender;
    }

    function ChangeOwner(address new_owner) public
    {
        require(msg.sender == m_Owner || msg.sender == m_Creator || msg.sender == m_Owner2);

        m_Owner = new_owner;
    }

    function ChangeOwner2(address new_owner2) public
    {
        require(msg.sender == m_Owner || msg.sender == m_Creator || msg.sender == m_Owner2);

        m_Owner2 = new_owner2;
    }

    function Store(address user, uint256 category, uint256 index, bytes32 data) public OnlyOwner()
    {
        m_Data[user][category][index] = data;
    }

    function Load(address user, uint256 category, uint256 index) public view returns (bytes32)
    {
        return m_Data[user][category][index];
    }

    function TransferFunds(address target, uint256 transfer_amount) public OnlyOwner()
    {
        target.transfer(transfer_amount);
    }
}