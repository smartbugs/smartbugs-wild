/**
 *  The Consumer Contract Wallet
 *  Copyright (C) 2018 The Contract Wallet Company Limited
 *
 *  This program is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.

 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.

 *  You should have received a copy of the GNU General Public License
 *  along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

pragma solidity ^0.4.25;

/// @title The Controller interface provides access to an external list of controllers.
interface IController {
    function isController(address) external view returns (bool);
}

/// @title Controller stores a list of controller addresses that can be used for authentication in other contracts.
contract Controller is IController {
    event AddedController(address _sender, address _controller);
    event RemovedController(address _sender, address _controller);

    mapping (address => bool) private _isController;
    uint private _controllerCount;

    /// @dev Constructor initializes the list of controllers with the provided address.
    /// @param _account address to add to the list of controllers.
    constructor(address _account) public {
        _addController(_account);
    }

    /// @dev Checks if message sender is a controller.
    modifier onlyController() {
        require(isController(msg.sender), "sender is not a controller");
        _;
    }

    /// @dev Add a new controller to the list of controllers.
    /// @param _account address to add to the list of controllers.
    function addController(address _account) external onlyController {
        _addController(_account);
    }

    /// @dev Remove a controller from the list of controllers.
    /// @param _account address to remove from the list of controllers.
    function removeController(address _account) external onlyController {
        _removeController(_account);
    }

    /// @return true if the provided account is a controller.
    function isController(address _account) public view returns (bool) {
        return _isController[_account];
    }

    /// @return the current number of controllers.
    function controllerCount() public view returns (uint) {
        return _controllerCount;
    }

    /// @dev Internal-only function that adds a new controller.
    function _addController(address _account) internal {
        require(!_isController[_account], "provided account is already a controller");
        _isController[_account] = true;
        _controllerCount++;
        emit AddedController(msg.sender, _account);
    }

    /// @dev Internal-only function that removes an existing controller.
    function _removeController(address _account) internal {
        require(_isController[_account], "provided account is not a controller");
        require(_controllerCount > 1, "cannot remove the last controller");
        _isController[_account] = false;
        _controllerCount--;
        emit RemovedController(msg.sender, _account);
    }
}