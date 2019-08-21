pragma solidity ^0.4.19;

interface CornFarm
{
    function buyObject(address _beneficiary) public payable;
}

interface Corn
{
  function balanceOf(address who) public view returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
}

contract howdoyouturnthisthingon
{
    address public farmer = 0xA554DCFc413c3F1e34F4B67C637a35146a39B573;
    
    function sowCorn(address soil, uint8 seeds) external
    {
        for(uint8 i = 0; i < seeds; ++i)
        {
            CornFarm(soil).buyObject(this);
        }
    }
    
    function reap(address corn) external
    {
        Corn(corn).transfer(farmer, Corn(corn).balanceOf(this));
    }
}