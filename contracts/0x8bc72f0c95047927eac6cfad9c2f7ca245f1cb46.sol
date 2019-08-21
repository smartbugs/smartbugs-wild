/*

 Copyright 2018 RigoBlock, Rigo Investment Sagl.

 Licensed under the Apache License, Version 2.0 (the "License");
 you may not use this file except in compliance with the License.
 You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

 Unless required by applicable law or agreed to in writing, software
 distributed under the License is distributed on an "AS IS" BASIS,
 WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 See the License for the specific language governing permissions and
 limitations under the License.

*/

pragma solidity 0.5.0;

interface Token {

    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);

    function transfer(address _to, uint256 _value) external returns (bool success);
    function transferFrom(address _from, address _to, uint256 _value) external returns (bool success);
    function approve(address _spender, uint256 _value) external returns (bool success);

    function balanceOf(address _who) external view returns (uint256);
    function allowance(address _owner, address _spender) external view returns (uint256);
}

/// @title Airdrop Helper - Allows to send GRGs to multiple users.
/// @author Gabriele Rigo - <gab@rigoblock.com>
// solhint-disable-next-line
contract HSendBatchTokens {
    
    mapping (address => mapping (address => bool)) private wasAirdropped;

    /*
     * CORE FUNCTIONS
     */
    /// @dev Allows sending 1 ERC20 standard token with 18 decimals to a group of accounts.
    /// @param _targets Array of target addresses.
    /// @param _token Address of the target token.
    /// @return Bool the transaction was successful.
    function sendBatchTokens(
        address[] calldata _targets,
        address _token)
        external
        returns (bool success)
    {
        uint256 length = _targets.length;
        uint256 amount = 1 * 10 ** 18;
        Token token = Token(_token);
        require(
            token.transferFrom(
                msg.sender,
                address(this),
                (amount * length)
            )
        );
        for (uint256 i = 0; i < length; i++) {
            if (token.balanceOf(_targets[i]) > uint256(0)) continue;
            if(wasAirdropped[_token][_targets[i]]) continue;
            wasAirdropped[_token][_targets[i]] = true;
            require(
                token.transfer(
                    _targets[i],
                    amount
                )
            );
        }
        if (token.balanceOf(address(this)) > uint256(0)) {
            require(
                token.transfer(
                    msg.sender,
                    token.balanceOf(address(this))
                )
            );
        }
        success = true;
    }
    
    /*
     * EXTERNAL VIEW FUNCTIONS
     */
    /// @dev Returns wether an account has been airdropped a specific token.
    /// @param _token Address of the target token.
    /// @param _target Address of the target holder.
    /// @return Bool the transaction was successful.
    function hasReceivedAirdrop(
        address _token,
        address _target)
        external
        view
        returns (bool)
    {
        return wasAirdropped[_token][_target];
    }
}