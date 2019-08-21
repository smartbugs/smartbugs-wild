/**
* Copyright Accelerator 2019
*
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is furnished to
* do so, subject to the following conditions:
*
* The above copyright notice and this permission notice shall be included in all
* copies or substantial portions of the Software.
*
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
* WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
* CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
*/
pragma solidity ^0.4.24;
contract Accelerator {
  function transfer(address to, uint256 tokens) public returns (bool success);
  function transferFrom(address from, address to, uint256 value) public returns (bool success);
}
contract Domain {
string public name;
constructor(string register_domain) public {
    name = register_domain;
}
}
contract Registrar {
  /// @dev Set constant values here
  string public constant name = "Accelerator-Registrar";
  address constant public ACCELERATOR_ADDR = 0x13F1b7FDFbE1fc66676D56483e21B1ecb40b58E2; // Accelerator contract address
  // index of created contracts
  address[] public contracts;
  // useful to know the row count in contracts index
  function getContractCount()
    public
    constant
    returns(uint contractCount)
  {
    return contracts.length;
  }
  /// @dev Register Domain
  function register(
    string register_domain
  ) public returns(address newContract)
  {
    //remember to call Token(address).approve(this, amount) or this contract will not be able to do the transfer on your behalf.
    require(Accelerator(ACCELERATOR_ADDR).transferFrom(msg.sender, this, 10**21));
    /// @dev Send the tokens to address(0) (the burn address) - require it or fail here
    require(Accelerator(ACCELERATOR_ADDR).transfer(address(0), 10**21));
    address c = new Domain(register_domain);
    contracts.push(c);
    return c;
  }
}