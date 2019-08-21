/**
*
The MIT License (MIT)

Copyright (c) 2018 Bitindia.
Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
For more information regarding the MIT License visit: https://opensource.org/licenses/MIT

@AUTHOR Bitindia. https://bitindia.co/
*
*/

pragma solidity ^0.4.19;


contract BurnTokens {
    
  /**
   * Address initiating the contract to make sure it only can destroy the contract
   */ 
  address owner;
  
  /**
   * @notice BurnTokens cnstr
   * Sets the owner address
   */ 
  function BurnTokens() public {
      owner = msg.sender;
  }

    
  /*
  ** @notice selfdestruct contract  
  *  Only owner can call this method
  *  Any token balance before this call will be lost forever
  */
  function destroy() public {
      assert(msg.sender == owner);
      selfdestruct(this);
  }
  
}