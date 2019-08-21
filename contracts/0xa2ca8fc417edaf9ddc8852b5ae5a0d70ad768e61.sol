pragma solidity ^0.4.17;

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

contract APMath {
    function safeAdd(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function safeSub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function safeMul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function safeMin(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function safeMax(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function safeMin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function safeMax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function safeWmul(uint x, uint y) internal pure returns (uint z) {
        z = safeAdd(safeMul(x, y), WAD / 2) / WAD;
    }
    function safeRmul(uint x, uint y) internal pure returns (uint z) {
        z = safeAdd(safeMul(x, y), RAY / 2) / RAY;
    }
    function safeWdiv(uint x, uint y) internal pure returns (uint z) {
        z = safeAdd(safeMul(x, WAD), y / 2) / y;
    }
    function safeRdiv(uint x, uint y) internal pure returns (uint z) {
        z = safeAdd(safeMul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = safeRmul(x, x);

            if (n % 2 != 0) {
                z = safeRmul(z, x);
            }
        }
    }
}

contract DrivezyPrivateCoinSharedStorage is DSAuth {
    uint _totalSupply = 0;

    // オーナー登録されているアドレス
    mapping(address => bool) ownerAddresses;

    // オーナーアドレスの LUT
    address[] public ownerAddressLUT;

    // 信頼できるコントラクトに登録されているアドレス
    mapping(address => bool) trustedContractAddresses;

    // 信頼できるコントラクトの LUT
    address[] public trustedAddressLUT;

    // ホワイトリスト (KYC確認済み) のアドレス
    mapping(address => bool) approvedAddresses;

    // ホワイトリストの LUT
    address[] public approvedAddressLUT;

    // 常に許可されている関数
    mapping(bytes4 => bool) actionsAlwaysPermitted;

    /**
     * custom events
     */

    /* addOwnerAddress したときに発生するイベント
     * {address} senderAddress - 実行者のアドレス
     * {address} userAddress - 許可されたユーザのアドレス
     */
    event AddOwnerAddress(address indexed senderAddress, address indexed userAddress);

    /* removeOwnerAddress したときに発生するイベント
     * {address} senderAddress - 実行者のアドレス
     * {address} userAddress - 許可を取り消されたユーザのアドレス
     */
    event RemoveOwnerAddress(address indexed senderAddress, address indexed userAddress);

    /* addTrustedContractAddress したときに発生するイベント
     * {address} senderAddress - 実行者のアドレス
     * {address} userAddress - 許可されたユーザのアドレス
     */
    event AddTrustedContractAddress(address indexed senderAddress, address indexed userAddress);

    /* removeTrustedContractAddress したときに発生するイベント
     * {address} senderAddress - 実行者のアドレス
     * {address} userAddress - 許可を取り消されたユーザのアドレス
     */
    event RemoveTrustedContractAddress(address indexed senderAddress, address indexed userAddress);


    /**
     * 指定したアドレスをオーナー一覧に追加する
     * @param addr (address) - オーナーに追加したいアドレス
     * @return {bool} 追加に成功した場合は true を返す
     */
    function addOwnerAddress(address addr) auth public returns (bool) {
        ownerAddresses[addr] = true;
        ownerAddressLUT.push(addr);
        AddOwnerAddress(msg.sender, addr);
        return true;
    }

    /**
     * 指定したアドレスを信頼できるコントラクト一覧に追加する
     * ここに追加されたコントラクトは、mint や burn などの管理者コマンドを実行できる (いわゆる sudo)
     * @param addr (address) - 信頼できるコントラクト一覧に追加したいアドレス
     * @return {bool} 追加に成功した場合は true を返す
     */
    function addTrustedContractAddress(address addr) auth public returns (bool) {
        trustedContractAddresses[addr] = true;
        trustedAddressLUT.push(addr);
        AddTrustedContractAddress(msg.sender, addr);
        return true;
    }

    /**
     * 指定したアドレスをKYC承認済みアドレス一覧に追加する
     * ここに追加されたアドレスはトークンの購入ができる
     * @param addr (address) - KYC承認済みアドレス一覧に追加したいアドレス
     * @return {bool} 追加に成功した場合は true を返す
     */
    function addApprovedAddress(address addr) auth public returns (bool) {
        approvedAddresses[addr] = true;
        approvedAddressLUT.push(addr);
        return true;
    }

    /**
     * 指定したアドレスをオーナー一覧から削除する
     * @param addr (address) - オーナーから外したいアドレス
     * @return {bool} 削除に成功した場合は true を返す
     */
    function removeOwnerAddress(address addr) auth public returns (bool) {
        ownerAddresses[addr] = false;
        RemoveOwnerAddress(msg.sender, addr);
        return true;
    }

    /**
     * 指定したアドレスを信頼できるコントラクト一覧から削除する
     * @param addr (address) - 信頼できるコントラクト一覧から外したいアドレス
     * @return {bool} 削除に成功した場合は true を返す
     */
    function removeTrustedContractAddress(address addr) auth public returns (bool) {
        trustedContractAddresses[addr] = false;
        RemoveTrustedContractAddress(msg.sender, addr);
        return true;
    }

    /**
     * 指定したアドレスをKYC承認済みアドレス一覧から削除する
     * @param addr (address) - KYC承認済みアドレス一覧から外したいアドレス
     * @return {bool} 削除に成功した場合は true を返す
     */
    function removeApprovedAddress(address addr) auth public returns (bool) {
        approvedAddresses[addr] = false;
        return true;
    }

    /**
     * 指定したアドレスがオーナーであるかを調べる
     * @param addr (address) - オーナーであるか調べたいアドレス
     * @return {bool} オーナーであった場合は true を返す
     */
    function isOwnerAddress(address addr) public constant returns (bool) {
        return ownerAddresses[addr];
    }

    /**
     * 指定したアドレスがKYC承認済みであるかを調べる
     * @param addr (address) - KYC承認済みであるか調べたいアドレス
     * @return {bool} KYC承認済みであった場合は true を返す
     */
    function isApprovedAddress(address addr) public constant returns (bool) {
        return approvedAddresses[addr];
    }

    /**
     * 指定したアドレスが信頼できるコントラクトであるかを調べる
     * @param addr (address) - 信頼できるコントラクトであるか調べたいアドレス
     * @return {bool} 信頼できるコントラクトであった場合は true を返す
     */
    function isTrustedContractAddress(address addr) public constant returns (bool) {
        return trustedContractAddresses[addr];
    }

    /**
     * オーナーのアドレス一覧に登録しているアドレス数を調べる
     * 同一アドレスについて、リストの追加と削除を繰り返した場合は重複してカウントされる 
     * @return {uint} 登録されているアドレスの数
     */
    function ownerAddressSize() public constant returns (uint) {
        return ownerAddressLUT.length;
    }

    /**
     * n 番目に登録されたオーナーのアドレスを取得する (Look up table)
     * @param index (uint) - n 番目を指定する
     * @return {address} 登録されているアドレス
     */
    function ownerAddressInLUT(uint index) public constant returns (address) {
        return ownerAddressLUT[index];
    }

    /**
     * 信頼できるコントラクト一覧に登録しているアドレス数を調べる
     * 同一アドレスについて、リストの追加と削除を繰り返した場合は重複してカウントされる 
     * @return {uint} 登録されているアドレスの数
     */
    function trustedAddressSize() public constant returns (uint) {
        return trustedAddressLUT.length;
    }

    /**
     * n 番目に登録された信頼できるコントラクトを取得する (Look up table)
     * @param index (uint) - n 番目を指定する
     * @return {address} 登録されているコントラクトのアドレス
     */
    function trustedAddressInLUT(uint index) public constant returns (address) {
        return trustedAddressLUT[index];
    }

    /**
     * KYC承認済みアドレスの一覧に登録しているアドレス数を調べる
     * 同一アドレスについて、リストの追加と削除を繰り返した場合は重複してカウントされる 
     * @return {uint} 登録されているアドレスの数
     */
    function approvedAddressSize() public constant returns (uint) {
        return approvedAddressLUT.length;
    }

    /**
     * n 番目に登録されたKYC承認済みアドレスを取得する (Look up table)
     * @param index (uint) - n 番目を指定する
     * @return {address} 登録されているアドレス
     */
    function approvedAddressInLUT(uint index) public constant returns (address) {
        return approvedAddressLUT[index];
    }


    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        return src == address(this) || src == owner || isOwnerAddress(src) || isTrustedContractAddress(src) || actionsAlwaysPermitted[sig];
    }
}

contract DrivezyPrivateCoinStorage is DSAuth {
    uint _totalSupply = 0;

    // 残高一覧
    mapping(address => uint) coinBalances;

    // 送金許可額の一覧
    mapping(address => mapping (address => uint)) coinAllowances;

    // 共通ストレージ
    DrivezyPrivateCoinSharedStorage public sharedStorage;

    // 常に許可されている関数
    mapping(bytes4 => bool) actionsAlwaysPermitted;

    // ユーザ間での送金ができるかどうか
    bool public transferBetweenUsers;

    function totalSupply() external constant returns (uint) {
        return _totalSupply;
    }

    function setTotalSupply(uint amount) auth external returns (bool) {
        _totalSupply = amount;
        return true;
    }

    function coinBalanceOf(address addr) external constant returns (uint) {
        return coinBalances[addr];
    }

    function coinAllowanceOf(address _owner, address spender) external constant returns (uint) {
        return coinAllowances[_owner][spender];
    }

    function setCoinBalance(address addr, uint amount) auth external returns (bool) {
        coinBalances[addr] = amount;
        return true;
    }

    function setCoinAllowance(address _owner, address spender, uint value) auth external returns (bool) {
        coinAllowances[_owner][spender] = value;
        return true;
    }

    function setSharedStorage(address addr) auth public returns (bool) {
        sharedStorage = DrivezyPrivateCoinSharedStorage(addr);
        return true;
    }

    function allowTransferBetweenUsers() auth public returns (bool) {
        transferBetweenUsers = true;
        return true;
    }

    function disallowTransferBetweenUsers() auth public returns (bool) {
        transferBetweenUsers = false;
        return true;
    }

    function canTransferBetweenUsers() public view returns (bool) {
        return transferBetweenUsers;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        return actionsAlwaysPermitted[sig] || src == address(this) || src == owner || sharedStorage.isOwnerAddress(src) || sharedStorage.isTrustedContractAddress(src);
    }
}

contract DrivezyPrivateCoinAcceptableContract {
    function receiveToken(address addr, uint amount) public returns (bool);

    function isDrivezyPrivateTokenAcceptable() public pure returns (bool);
}

contract DrivezyPrivateCoinImplementation is DSAuth, APMath {
    DrivezyPrivateCoinStorage public coinStorage;
    DrivezyPrivateCoinSharedStorage public sharedStorage;
    DrivezyPrivateCoin public coin;


    /**
     * custom events
     */

    /* storage を設定したときに発生するイベント
     * {address} senderAddress - 実行者のアドレス
     * {address} contractAddress - 設定した storage のコントラクトアドレス
     */
    event SetStorage(address indexed senderAddress, address indexed contractAddress);

    /* shared storage を設定したときに発生するイベント
     * {address} senderAddress - 実行者のアドレス
     * {address} contractAddress - 設定した shared storage のコントラクトアドレス
     */
    event SetSharedStorage(address indexed senderAddress, address indexed contractAddress);

    /* coin を設定したときに発生するイベント
     * {address} senderAddress - 実行者のアドレス
     * {address} contractAddress - 設定した coin のコントラクトアドレス
     */
    event SetCoin(address indexed senderAddress, address indexed contractAddress);

    /* mint したときに発生するイベント
     * {address} senderAddress - 実行者のアドレス
     * {address} receiverAddress - コインを受け取るユーザのアドレス
     * {uint} amount - 発行高
     */
    event Mint(address indexed senderAddress, address indexed receiverAddress, uint amount);

    /* burn したときに発生するイベント
     * {address} senderAddress - 実行者のアドレス
     * {address} receiverAddress - コインを消却するユーザのアドレス
     * {uint} amount - 消却高
     */
    event Burn(address indexed senderAddress, address indexed receiverAddress, uint amount);

    /* addApprovedAddress したときに発生するイベント
     * {address} senderAddress - 実行者のアドレス
     * {address} userAddress - 許可されたユーザのアドレス
     */
    event AddApprovedAddress(address indexed senderAddress, address indexed userAddress);

    /* removeApprovedAddress したときに発生するイベント
     * {address} senderAddress - 実行者のアドレス
     * {address} userAddress - 許可が取り消されたユーザのアドレス
     */
    event RemoveApprovedAddress(address indexed senderAddress, address indexed userAddress);

    /**
     * 総発行高を返す
     * @return {uint} コインの総発行高
     */
    function totalSupply() auth public view returns (uint) {
        return coinStorage.totalSupply();
    }

    /**
     * 指定したアドレスが保有するコインの残高を返す
     * @param addr {address} - コインの残高を調べたいアドレス
     * @return {uint} コインの残高
     */
    function balanceOf(address addr) auth public view returns (uint) {
        return coinStorage.coinBalanceOf(addr);
    }

    /**
     * ERC20 Token Standardに準拠した関数
     *
     * あるユーザが保有するコインを指定したアドレスに送金する
     * @param sender {address} - 送信元 (資金源) のアドレス
     * @param to {address} - 宛先のアドレス
     * @param amount {uint} - 送付するコインの分量
     * @return {bool} コインの残高
     */
    function transfer(address sender, address to, uint amount) auth public returns (bool) {
        // 残高を超えて送金してないか確認
        require(coinStorage.coinBalanceOf(sender) >= amount);

        // 1円以上送ろうとしているか確認
        require(amount > 0);

        // 受取者がオーナーまたは許可された (KYC 通過済み) アドレスかを確認
        require(canTransfer(sender, to));

        // 送金元の残高を減らし、送金先の残高を増やす
        coinStorage.setCoinBalance(sender, safeSub(coinStorage.coinBalanceOf(sender), amount));
        coinStorage.setCoinBalance(to, safeAdd(coinStorage.coinBalanceOf(to), amount));

        // 送金先がコントラクトで、isDrivezyPrivateTokenAcceptable が true を返すコントラクトでは
        // receiveToken() 関数をコールする
        if (isContract(to)) {
            DrivezyPrivateCoinAcceptableContract receiver = DrivezyPrivateCoinAcceptableContract(to);
            if (receiver.isDrivezyPrivateTokenAcceptable()) {
                require(receiver.receiveToken(sender, amount));
            }
        }
        return true;
    }

    /**
     * ERC20 Token Standardに準拠した関数
     *
     * 指定したユーザが保有するコインを指定したアドレスに送金する
     * @param sender {address} - 送付操作を実行するユーザのアドレス
     * @param from {address} - 資金源となるユーザのアドレス
     * @param to {address} - 宛先のアドレス
     * @param amount {uint} - 送付するコインの分量
     * @return {bool} 送付に成功した場合は true を返す
     */
    function transferFrom(address sender, address from, address to, uint amount) auth public returns (bool) {
        // アローアンスを超えて送金してないか確認
        require(coinStorage.coinAllowanceOf(sender, from) >= amount);

        // transfer 処理に引き継ぐ
        transfer(from, to, amount);

        // アローアンスを減らす
        coinStorage.setCoinAllowance(from, sender, safeSub(coinStorage.coinAllowanceOf(sender, from), amount));

        return true;
    }

    /**
     * ERC20 Token Standardに準拠した関数
     *
     * spender（支払い元のアドレス）にsender（送信者）がamount分だけ支払うのを許可する
     * この関数が呼ばれる度に送金可能な金額を更新する。
     *
     * @param sender {address} - 許可操作を実行するユーザのアドレス
     * @param spender (address} - 送付操作を許可する対象ユーザのアドレス
     * @param amount {uint} - 送付を許可するコインの分量
     * @return {bool} 許可に成功した場合は true を返す
     */
    function approve(address sender, address spender, uint amount) auth public returns (bool) {
        coinStorage.setCoinAllowance(sender, spender, amount);
        return true;
    }

    /**
     * ERC20 Token Standardに準拠した関数
     *
     * 指定したユーザに対し、送付操作が許可されているトークンの分量を返す
     *
     * @param owner {address} - 資金源となるユーザのアドレス
     * @param spender {address} - 送付操作を許可しているユーザのアドレス
     * @return {uint} 許可されているトークンの分量を返す
     */
    function allowance(address owner, address spender) auth public constant returns (uint) {
        return coinStorage.coinAllowanceOf(owner, spender);
    }

    /**
     * トークンストレージ (このトークンに限り有効なストレージ) を設定する <Ownerのみ実行可能>
     * @param addr {address} - DrivezyPrivateCoinStorage のアドレス
     * @return {bool} Storage の設定に成功したら true を返す
     */
    function setStorage(address addr) auth public returns (bool) {
        coinStorage = DrivezyPrivateCoinStorage(addr);
        SetStorage(msg.sender, addr);
        return true;
    }

    /**
     * 共有ストレージ (一連の発行において共通利用するストレージ) を設定する <Ownerのみ実行可能>
     * @param addr {address} - DrivezyPrivateCoinSharedStorage のアドレス
     * @return {bool} Storage の設定に成功したら true を返す
     */
    function setSharedStorage(address addr) auth public returns (bool) {
        sharedStorage = DrivezyPrivateCoinSharedStorage(addr);
        SetSharedStorage(msg.sender, addr);
        return true;
    }

    /**
     * Coin (ERC20 準拠の公開するコントラクト) を設定する <Ownerのみ実行可能>
     * @param addr {address} - DrivezyPrivateCoin のアドレス
     * @return {bool} Coin の設定に成功したら true を返す
     */
    function setCoin(address addr) auth public returns (bool) {
        coin = DrivezyPrivateCoin(addr);
        SetCoin(msg.sender, addr);
        return true;
    }

    /**
     * 指定したアドレスにコインを発行する <Ownerのみ実行可能>
     * @param receiver {address} - 発行したコインの受取アカウント
     * @param amount {uint} - 発行量
     * @return {bool} 発行に成功したら true を返す
     */
    function mint(address receiver, uint amount) auth public returns (bool) {
        // 1円以上発行しようとしているか確認
        require(amount > 0);

        // 発行残高を増やす
        coinStorage.setTotalSupply(safeAdd(coinStorage.totalSupply(), amount));

        // 自分自身に発行する
        // 発行に先立ち、自分がトークンを持てるようにする
        addApprovedAddress(address(this));
        coinStorage.setCoinBalance(address(this), safeAdd(coinStorage.coinBalanceOf(address(this)), amount));

        // 自分自身から相手に送付する
        require(coin.transfer(receiver, amount));

        // ログに保存
        Mint(msg.sender, receiver, amount);

        return true;
    }

    /**
     * 指定したアドレスからコインを回収する <Ownerのみ実行可能>
     * @param receiver {address} - 回収先のアカウント
     * @param amount {uint} - 回収量
     * @return {bool} 回収に成功したら true を返す
     */
    function burn(address receiver, uint amount) auth public returns (bool) {
        // 1円以上回収しようとしているか確認
        require(amount > 0);

        // 回収先のアカウントの所持金額以下を回収しようとしているか確認
        require(coinStorage.coinBalanceOf(receiver) >= amount);

        // 回収する残量の approve を強制的に設定する
        // 回収に先立ち、自分がトークンを持てるようにする
        approve(address(this), receiver, amount);
        addApprovedAddress(address(this));

        // 自分自身のコントラクトに回収する
        require(coin.transferFrom(receiver, address(this), amount));

        // 回収後、コインを溶かす
        coinStorage.setTotalSupply(safeSub(coinStorage.totalSupply(), amount));
        coinStorage.setCoinBalance(address(this), safeSub(coinStorage.coinBalanceOf(address(this)), amount));

        // ログに保存
        Burn(msg.sender, receiver, amount);

        return true;
    }

    /**
     * 指定したアドレスをホワイトリストに追加 <Ownerのみ実行可能>
     * @param addr {address} - 追加するアカウント
     * @return {bool} 追加に成功したら true を返す
     */
    function addApprovedAddress(address addr) auth public returns (bool) {
        sharedStorage.addApprovedAddress(addr);
        AddApprovedAddress(msg.sender, addr);
        return true;
    }

    /**
     * 指定したアドレスをホワイトリストから削除 <Ownerのみ実行可能>
     * @param addr {address} - 削除するアカウント
     * @return {bool} 削除に成功したら true を返す
     */
    function removeApprovedAddress(address addr) auth public returns (bool) {
        sharedStorage.removeApprovedAddress(addr);
        RemoveApprovedAddress(msg.sender, addr);
        return true;
    }

    /**
     * ユーザ間の送金を許可する <Ownerのみ実行可能>
     * @return {bool} 許可に成功したら true を返す
     */
    function allowTransferBetweenUsers() auth public returns (bool) {
        coinStorage.allowTransferBetweenUsers();
        return true;
    }

    /**
     * ユーザ間の送金を禁止する <Ownerのみ実行可能>
     * @return {bool} 禁止に成功したら true を返す
     */
    function disallowTransferBetweenUsers() auth public returns (bool) {
        coinStorage.disallowTransferBetweenUsers();
        return true;
    }

    /**
     * DSAuth の canCall(src, dst, sig) の override
     * シグネチャと実行者レベルで関数の実行可否を返す
     #
     * @param src {address} - 呼び出し元ユーザのアドレス
     * @param dst {address} - 実行先コントラクトのアドレス
     * @param sig {bytes4} - 関数のシグネチャ (SHA3)
     * @return {bool} 関数が実行可能であれば true を返す
     */
    function canCall(address src, address dst, bytes4 sig) public constant returns (bool) {
        dst; // HACK - 引数を使わないとコンパイラが警告を出す
        sig; // HACK - こちらも同様

        // オーナーによる実行、「信用するコントラクト」からの呼び出し、コインからの呼び出しは許可
        return src == owner || sharedStorage.isOwnerAddress(src) || sharedStorage.isTrustedContractAddress(src) || src == address(coin);
    }

    /**
     * 指定したユーザ間での転送が承認されるかどうか
     * - 受取者が approvedAddress か ownerAddress に属する
     * - coinStorage.canTransferBetweenUsers = false の場合、受取者か送信者のいずれかが ownerAddress または trustedContractAddress に属する
     * @param from {address} - 送付者のアドレス
     * @param to {address} - 受取者のアドレス
     * @return {bool} 転送できる場合は true を返す
     */
    function canTransfer(address from, address to) internal constant returns (bool) {
        // 受取者がオーナーまたは許可された (KYC 通過済み) アドレスかを確認
        require(sharedStorage.isOwnerAddress(to) || sharedStorage.isApprovedAddress(to));

        // ユーザ間の送金が許可されているか、そうでない場合は送り手または受け手が「オーナー」あるいは「信頼できるコントラクト」に入っているか。
        require(coinStorage.canTransferBetweenUsers() || sharedStorage.isOwnerAddress(from) || sharedStorage.isTrustedContractAddress(from) || sharedStorage.isOwnerAddress(to) || sharedStorage.isTrustedContractAddress(to));

        return true;
    }

    /**
     * DSAuth の isAuthorized(src, sig) の override
     * @param src {address} - コントラクトの実行者
     * @param sig {bytes4} - コントラクトのシグネチャの SHA3 値
     * @return {bool} 呼び出し可能な関数の場合は true を返す
     */
    function isAuthorized(address src, bytes4 sig) internal constant returns (bool) {
        return canCall(src, address(this), sig);
    }

    /**
     * 指定されたアドレスがコントラクトであるか判定する
     * @param addr {address} - 判定対象のコントラクト
     * @return {bool} コントラクトであれば true
     */
    function isContract(address addr) public view returns (bool result) {
        uint length;
        assembly {
            // アドレスが持つマシン語のサイズを取得する
            length := extcodesize(addr)
        }

        // 当該アドレスがマシン語を持てばコントラクトと見做せる
        return (length > 0);
    }

    /**
     * DrivezyPrivateCoinAcceptableContract#isDrivezyPrivateTokenAcceptable の override
     * このコントラクトは Private Token を受け取らない
     * @return {bool} 常に false を返す
     */
    function isDrivezyPrivateTokenAcceptable() public pure returns (bool result) {
        return false;
    }
}


/**
 * ERC20 に準拠したコインの公開インタフェース
 */
contract DrivezyPrivateCoin is ERC20, DSAuth {
    /**
     * public variables - Etherscan などに表示される
     */
    
    /* コインの名前 */
    string public name = "Uni 0.1.0";

    /* コインのシンボル */
    string public symbol = "ORI";

    /* 通貨の最小単位の桁数。 6 の場合は小数第6位が最小単位となる (0.000001 ORI) */
    uint8 public decimals = 6;

    /**
     * custom events
     */

    /* Implementation を設定したときに発生するイベント
     * {address} senderAddress - 実行者のアドレス
     * {address} contractAddress - 設定した implementation のコントラクトアドレス
     */
    event SetImplementation(address indexed senderAddress, address indexed contractAddress);

    /**
     * private variables
     */

    // トークンのロジック実装インスタンス
    DrivezyPrivateCoinImplementation public implementation;

    // ----------------------------------------------------------------------------------------------------
    // ERC20 Token Standard functions
    // ----------------------------------------------------------------------------------------------------

    /**
     * 総発行高を返す
     * @return {uint} コインの総発行高
     */
    function totalSupply() public constant returns (uint) {
        return implementation.totalSupply();
    }

    /**
     * 指定したアドレスが保有するコインの残高を返す
     * @param addr {address} - コインの残高を調べたいアドレス
     * @return {uint} コインの残高
     */
    function balanceOf(address addr) public constant returns (uint) {
        return implementation.balanceOf(addr);
    }

    /**
     * 自分が保有するコインを指定したアドレスに送金する
     * @param to {address} - 宛先のアドレス
     * @param amount {uint} - 送付するコインの分量
     * @return {bool} 送付に成功した場合は true を返す
     */
    function transfer(address to, uint amount) public returns (bool) {
        if (implementation.transfer(msg.sender, to, amount)) {
            Transfer(msg.sender, to, amount);
            return true;
        } else {
            return false;
        }
    }

    /**
     * 指定したユーザが保有するコインを指定したアドレスに送金する
     * @param from {address} - 資金源となるユーザのアドレス
     * @param to {address} - 宛先のアドレス
     * @param amount {uint} - 送付するコインの分量
     * @return {bool} 送付に成功した場合は true を返す
     */
    function transferFrom(address from, address to, uint amount) public returns (bool) {
        if (implementation.transferFrom(msg.sender, from, to, amount)) {
            Transfer(from, to, amount);
            return true;
        } else {
            return false;
        }
    }

    /**
     * 指定したユーザに対し、(トークン所有者に代わって)指定した分量のトークンの送付を許可する
     * @param spender {address} - 送付操作を許可する対象ユーザのアドレス
     * @param amount {uint} - 送付を許可するコインの分量
     * @return {bool} 許可に成功した場合は true を返す
     */
    function approve(address spender, uint amount) public returns (bool) {
        if (implementation.approve(msg.sender, spender, amount)) {
            Approval(msg.sender, spender, amount);
            return true;
        } else {
            return false;
        }
    }

    /**
     * 指定したユーザに対し、送付操作が許可されているトークンの分量を返す
     * @param addr {address} - 資金源となるユーザのアドレス
     * @param spender {uint} - 送付操作を許可しているユーザのアドレス
     * @return {uint} 許可されているトークンの分量を返す
     */
    function allowance(address addr, address spender) public constant returns (uint) {
        return implementation.allowance(addr, spender);
    }

    /**
     * implementation (実装) が定義されたコントラクトを設定する <Ownerのみ実行可能>
     * @param addr {address} - コントラクトのアドレス
     * @return {bool} 設定変更に成功した場合は true を返す
     */
    function setImplementation(address addr) auth public returns (bool) {
        implementation = DrivezyPrivateCoinImplementation(addr);
        SetImplementation(msg.sender, addr);
        return true;
    }

    /**
     * DSAuth の isAuthorized(src, sig) の override
     * @param src {address} - コントラクトの実行者
     * @param sig {bytes4} - コントラクトのシグネチャの SHA3 値
     * @return {bool} 呼び出し可能な関数の場合は true を返す
     */
    function isAuthorized(address src, bytes4 sig) internal constant returns (bool) {
        return src == address(this) ||  // コントラクト自身による呼び出す
            src == owner ||             // コントラクトのデプロイ者
                                        // implementation が定義済みである場合は、Implementation#canCall に呼び出し可否チェックを委譲
            (implementation != DrivezyPrivateCoinImplementation(0) && implementation.canCall(src, address(this), sig));
    }
}


/**
 * ERC20 に準拠したコインの公開インタフェース
 */
contract DrivezyPrivateDecemberCoin is DrivezyPrivateCoin {
    /**
     * public variables - Etherscan などに表示される
     */
    
    /* コインの名前 */
    string public name = "Rental Coins 1.0 1st private offering";

    /* コインのシンボル */
    string public symbol = "RC1";

    /* 通貨の最小単位の桁数。 6 の場合は小数第6位が最小単位となる (0.000001 RC1) */
    uint8 public decimals = 6;

}