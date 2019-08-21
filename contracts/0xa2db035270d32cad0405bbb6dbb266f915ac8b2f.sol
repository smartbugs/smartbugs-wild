pragma solidity ^0.4.13;

contract DSAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract DSAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract DSAuth is DSAuthEvents {
    DSAuthority  public  authority;
    address      public  owner;

    function DSAuth() public {
        owner = msg.sender;
        LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        LogSetOwner(owner);
    }

    function setAuthority(DSAuthority authority_)
        public
        auth
    {
        authority = authority_;
        LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == DSAuthority(0)) {
            return false;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}

contract DSNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint              wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}

contract DSStop is DSNote, DSAuth {

    bool public stopped;

    modifier stoppable {
        require(!stopped);
        _;
    }
    function stop() public auth note {
        stopped = true;
    }
    function start() public auth note {
        stopped = false;
    }

}

// Token standard API
// https://github.com/ethereum/EIPs/issues/20

contract ERC20 {
    function totalSupply() public view returns (uint supply);
    function balanceOf( address who ) public view returns (uint value);
    function allowance( address owner, address spender ) public view returns (uint _allowance);

    function transfer( address to, uint value) public returns (bool ok);
    function transferFrom( address from, address to, uint value) public returns (bool ok);
    function approve( address spender, uint value ) public returns (bool ok);

    event Transfer( address indexed from, address indexed to, uint value);
    event Approval( address indexed owner, address indexed spender, uint value);
}

contract TokenTransferGuard {
    function onTokenTransfer(address _from, address _to, uint _amount) public returns (bool);
}

contract AGT2ATNSwap is DSStop, TokenTransferGuard {
    ERC20 public AGT;
    ERC20 public ATN;

    uint public gasRequired;

    function AGT2ATNSwap(address _agt, address _atn)
    {
        AGT = ERC20(_agt);
        ATN = ERC20(_atn);
    }

    function tokenFallback(address _from, uint256 _value, bytes _data) public
    {
        tokenFallback(_from, _value);
    }

    function tokenFallback(address _from, uint256 _value) public
    {
        if(msg.sender == address(AGT))
        {
            require(ATN.transfer(_from, _value));

            TokenSwap(_from, _value);
        }
    }

    function onTokenTransfer(address _from, address _to, uint _amount) public returns (bool)
    {
        if (_to == address(this))
        {
            if (msg.gas < gasRequired) return false;

            if (stopped) return false;

            if (ATN.balanceOf(this) < _amount) return false;
        }

        return true;
    }

    function changeGasRequired(uint _gasRequired) public auth {
        gasRequired = _gasRequired;
        ChangeGasReuired(_gasRequired);
    }

    /// @notice This method can be used by the controller to extract mistakenly
    ///  sent tokens to this contract.
    /// @param _token The address of the token contract that you want to recover
    ///  set to 0 in case you want to extract ether.
    function claimTokens(address _token) public auth {
        if (_token == 0x0) {
            owner.transfer(this.balance);
            return;
        }
        
        ERC20 token = ERC20(_token);
        
        uint256 balance = token.balanceOf(this);
        
        token.transfer(owner, balance);
        ClaimedTokens(_token, owner, balance);
    }

    event TokenSwap(address indexed _from, uint256 _value);
    event ClaimedTokens(address indexed _token, address indexed _controller, uint256 _amount);

    event ChangeGasReuired(uint _gasRequired);
}