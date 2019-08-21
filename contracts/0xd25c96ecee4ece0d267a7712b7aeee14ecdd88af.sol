// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.

// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.

// You should have received a copy of the GNU General Public License
// along with this program.  If not, see <http://www.gnu.org/licenses/>.

pragma solidity ^0.5.2;

contract IDSToken {
    function mint(address dst, uint wad) public;
    function burn(address dst, uint wad) public;
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(address src, address dst, uint wad) public returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    address      public  authority;
    address      public  owner;

    constructor() public {
        owner = msg.sender;
        emit LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        onlyOwner
    {
        owner = owner_;
        emit LogSetOwner(owner);
    }

    function setAuthority(address authority_)
        public
        onlyOwner
    {
        authority = authority_;
        emit LogSetAuthority(address(authority));
    }

    modifier auth {
        require(isAuthorized(msg.sender), "ds-auth-unauthorized");
        _;
    }

    modifier onlyOwner {
        require(isOwner(msg.sender), "ds-auth-non-owner");
        _;
    }

    function isOwner(address src) public view returns (bool) {
        return bool(src == owner);
    }

    function isAuthorized(address src) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == address(0)) {
            return false;
        } else if (src == authority) {
            return true;
        } else {
            return false;
        }
    }
}

contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint256           wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;
        uint256 wad;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
            wad := callvalue
        }

        emit LogNote(msg.sig, msg.sender, foo, bar, wad, msg.data);

        _;
    }
}

contract DSStop is DSNote, DSAuth {
    bool public stopped;

    modifier stoppable {
        require(!stopped, "ds-stop-is-stopped");
        _;
    }
    function stop() public onlyOwner note {
        stopped = true;
    }
    function start() public onlyOwner note {
        stopped = false;
    }
}

contract MakerProxy is DSStop {

    IDSToken private _dstoken;

    mapping (address => bool) public makerList;

    event AddMakerList(address indexed spender);
    event DelMakerList(address indexed spender);

    constructor(address usdxToken) public {
        _dstoken = IDSToken(usdxToken);
    }

    modifier isMaker {
        require(makerList[msg.sender] == true, "not in MakerList");
        _;
    }

    function addMakerList(address guy) public auth {
        require(guy != address(0));
        makerList[guy] = true;
        emit AddMakerList(guy);
    }

    function delMakerList(address guy) public auth {
        require(guy != address(0));
        delete makerList[guy];
        emit DelMakerList(guy);
    }

    function checkMakerList(address guy) public view returns (bool) {
        require(guy != address(0));
        return bool(makerList[guy]);
    }

    function mint(address dst, uint wad) public auth stoppable {
        _dstoken.mint(address(this), wad);
        _dstoken.transfer(dst, wad);
    }

    function burnx(address dst, uint wad) public isMaker stoppable {
        require(dst != address(this)); //except proxy itself
        _dstoken.transferFrom(dst, address(this), wad);
        _dstoken.burn(address(this), wad);
    }

    function burn(uint wad) public isMaker stoppable {
        _dstoken.transferFrom(msg.sender, address(this), wad);
        _dstoken.burn(address(this), wad);
    }
}