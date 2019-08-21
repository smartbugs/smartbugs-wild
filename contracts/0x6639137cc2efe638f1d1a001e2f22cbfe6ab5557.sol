pragma solidity 0.4.25;

/*
* Stin Go 第一份智能合約提供穩定的收入。 
* 智能合約可確保您的資金免遭盜竊和黑客攻擊
* 不要投入超過你可以輸的
*/

contract StinGo {

    struct UserRecord {
        address referrer;
        uint tokens;
        uint gained_funds;
        uint ref_funds;
        // 這個領域可能是負面的
        int funds_correction;
    }

    using SafeMath for uint;
    using SafeMathInt for int;
    using Fee for Fee.fee;
    using ToAddress for bytes;

    // ERC20
    string constant public name = "Stin Go";
    string constant public symbol = "STIN";
    uint8 constant public decimals = 18;

    // Fees
    Fee.fee private fee_purchase = Fee.fee(1, 10); // 10%
    Fee.fee private fee_selling  = Fee.fee(1, 20); // 5%
    Fee.fee private fee_transfer = Fee.fee(1, 100); // 1%
    Fee.fee private fee_referral = Fee.fee(33, 100); // 33%

    // 最少量的令牌將成為推薦計劃的參與者
    uint constant private minimal_stake = 10e18;

    // 轉換eth < - >令牌的因素，具有所需的計算精度
    uint constant private precision_factor = 1e18;

    // 定價政策
    //  - 如果用戶購買1個令牌，價格將增加“price_offset”值
    //  - 如果用戶賣出1個令牌，價格將降低“price_offset”值
    // 有關詳細信息，請參閱方法“fundsToTokens”和“tokensToFunds”
    uint private price = 1e29; // 100 Gwei * precision_factor
    uint constant private price_offset = 1e28; // 10 Gwei * precision_factor

    // 令牌總數
    uint private total_supply = 0;

    // 令牌持有者之間共享的總利潤。由於此參數，它並不能準確反映資金總額
    // 可以修改以在總供應量發生變化時保持真實用戶的股息
    // 有關詳細信息，請參閱方法“dividendsOf”並在代碼中使用“funds_correction”
    uint private shared_profit = 0;

    // 用戶數據的映射
    mapping(address => UserRecord) private user_data;

    // ==== 修改 ==== //

    modifier onlyValidTokenAmount(uint tokens) {
        require(tokens > 0, "令牌數量必須大於零");
        require(tokens <= user_data[msg.sender].tokens, "你沒有足夠的令牌");
        _;
    }

    // ==== 上市 API ==== //

    // ---- 寫作方法 ---- //

    function () public payable {
        buy(msg.data.toAddr());
    }

    /*
    *  從收到的資金購買代幣
    */
    function buy(address referrer) public payable {

        // 報名費
        (uint fee_funds, uint taxed_funds) = fee_purchase.split(msg.value);
        require(fee_funds != 0, "收入資金太小");

        // 更新用戶的推薦人
        //  - 你不能成為自己的推薦人
        //  - 用戶和他的推薦人將在一起生活
        UserRecord storage user = user_data[msg.sender];
        if (referrer != 0x0 && referrer != msg.sender && user.referrer == 0x0) {
            user.referrer = referrer;
        }

        // 申請推薦獎金
        if (user.referrer != 0x0) {
            fee_funds = rewardReferrer(msg.sender, user.referrer, fee_funds, msg.value);
            require(fee_funds != 0, "收入資金太小");
        }

        // 計算代幣金額和變更價格
        (uint tokens, uint _price) = fundsToTokens(taxed_funds);
        require(tokens != 0, "收入資金太小");
        price = _price;

        // 薄荷代幣，增加共享利潤
        mintTokens(msg.sender, tokens);
        shared_profit = shared_profit.add(fee_funds);

        emit Purchase(msg.sender, msg.value, tokens, price / precision_factor, now);
    }

    /*
    *  出售給定數量的代幣並獲得資金
    */
    function sell(uint tokens) public onlyValidTokenAmount(tokens) {

        // 計算資金數額和變更價格
        (uint funds, uint _price) = tokensToFunds(tokens);
        require(funds != 0, "沒有足夠的令牌來做這件事");
        price = _price;

        // 申請費
        (uint fee_funds, uint taxed_funds) = fee_selling.split(funds);
        require(fee_funds != 0, "沒有足夠的令牌來做這件事");

        // 刻錄令牌並為用戶的股息增加資金
        burnTokens(msg.sender, tokens);
        UserRecord storage user = user_data[msg.sender];
        user.gained_funds = user.gained_funds.add(taxed_funds);

        // 增加共享利潤
        shared_profit = shared_profit.add(fee_funds);

        emit Selling(msg.sender, tokens, funds, price / precision_factor, now);
    }

    /*
    *  將給定數量的令牌從發件人轉移到另一個用戶
    * ERC20
    */
    function transfer(address to_addr, uint tokens) public onlyValidTokenAmount(tokens) returns (bool success) {

        require(to_addr != msg.sender, "你不能把代幣轉讓給自己");

        // 申請費
        (uint fee_tokens, uint taxed_tokens) = fee_transfer.split(tokens);
        require(fee_tokens != 0, "沒有足夠的令牌來做到這一點");

        // 計算資金數額和變更價格
        (uint funds, uint _price) = tokensToFunds(fee_tokens);
        require(funds != 0, "沒有足夠的令牌來做到這一點");
        price = _price;

        // 燃燒和薄荷代幣，不含費用
        burnTokens(msg.sender, tokens);
        mintTokens(to_addr, taxed_tokens);

        // 增加共享利潤
        shared_profit = shared_profit.add(funds);

        emit Transfer(msg.sender, to_addr, tokens);
        return true;
    }

    /*
    *  再投資所有股息
    */
    function reinvest() public {

        // 獲得所有股息
        uint funds = dividendsOf(msg.sender);
        require(funds > 0, "你沒有股息");

        // 做出更正，之後的事件將為0
        UserRecord storage user = user_data[msg.sender];
        user.funds_correction = user.funds_correction.add(int(funds));

        // 申請費
        (uint fee_funds, uint taxed_funds) = fee_purchase.split(funds);
        require(fee_funds != 0, "紅利不足以做到這一點");

        // 申請推薦獎金
        if (user.referrer != 0x0) {
            fee_funds = rewardReferrer(msg.sender, user.referrer, fee_funds, funds);
            require(fee_funds != 0, "紅利不足以做到這一點");
        }

        // 計算代幣金額和變更價格
        (uint tokens, uint _price) = fundsToTokens(taxed_funds);
        require(tokens != 0, "紅利不足以做到這一點");
        price = _price;

        // 薄荷代幣，增加共享利潤
        mintTokens(msg.sender, tokens);
        shared_profit = shared_profit.add(fee_funds);

        emit Reinvestment(msg.sender, funds, tokens, price / precision_factor, now);
    }

    /*
    *  撤回所有股息
    */
    function withdraw() public {

        // 獲得所有股息
        uint funds = dividendsOf(msg.sender);
        require(funds > 0, "你沒有股息");

        // 做出更正，之後的事件將為0
        UserRecord storage user = user_data[msg.sender];
        user.funds_correction = user.funds_correction.add(int(funds));

        // 發送資金
        msg.sender.transfer(funds);

        emit Withdrawal(msg.sender, funds, now);
    }

    /*
    *  出售所有代幣和分紅
    */
    function exit() public {

        // 賣掉所有代幣
        uint tokens = user_data[msg.sender].tokens;
        if (tokens > 0) {
            sell(tokens);
        }

        withdraw();
    }

    /*
    * 警告！此方法在令牌持有者之間分配所有傳入資金，並且不提供任何內容
    * 它將在未來由我們的生態系統中的其他合同/地址使用
    * 但如果你想捐款，歡迎你
    */
    function donate() public payable {
        shared_profit = shared_profit.add(msg.value);
        emit Donation(msg.sender, msg.value, now);
    }

    
    function totalSupply() public view returns (uint) {
        return total_supply;
    }

   
    function balanceOf(address addr) public view returns (uint) {
        return user_data[addr].tokens;
    }

   
    function dividendsOf(address addr) public view returns (uint) {

        UserRecord memory user = user_data[addr];

       
        int d = int(user.gained_funds.add(user.ref_funds));
        require(d >= 0);

        if (total_supply > 0) {
            d = d.add(int(shared_profit.mul(user.tokens) / total_supply));
        }

        if (user.funds_correction > 0) {
            d = d.sub(user.funds_correction);
        }
        else if (user.funds_correction < 0) {
            d = d.add(-user.funds_correction);
        }

        require(d >= 0);

        return uint(d);
    }

   
    function expectedTokens(uint funds, bool apply_fee) public view returns (uint) {
        if (funds == 0) {
            return 0;
        }
        if (apply_fee) {
            (,uint _funds) = fee_purchase.split(funds);
            funds = _funds;
        }
        (uint tokens,) = fundsToTokens(funds);
        return tokens;
    }

    function expectedFunds(uint tokens, bool apply_fee) public view returns (uint) {
        // 總共有空令牌或沒有銷售代幣
        if (tokens == 0 || total_supply == 0) {
            return 0;
        }
        // 比總共開採更多的令牌，只是從計算中排除不必要的令牌
        else if (tokens > total_supply) {
            tokens = total_supply;
        }
        (uint funds,) = tokensToFunds(tokens);
        if (apply_fee) {
            (,uint _funds) = fee_selling.split(funds);
            funds = _funds;
        }
        return funds;
    }

    /*
    *  下一個令牌的購買價格
    */
    function buyPrice() public view returns (uint) {
        return price / precision_factor;
    }

    /*
    *  售價下一個令牌
    */
    function sellPrice() public view returns (uint) {
        return price.sub(price_offset) / precision_factor;
    }

    // ==== 私人的 API ==== //

    function mintTokens(address addr, uint tokens) internal {

        UserRecord storage user = user_data[addr];

        bool not_first_minting = total_supply > 0;

        if (not_first_minting) {
            shared_profit = shared_profit.mul(total_supply.add(tokens)) / total_supply;
        }

        total_supply = total_supply.add(tokens);
        user.tokens = user.tokens.add(tokens);

        if (not_first_minting) {
            user.funds_correction = user.funds_correction.add(int(tokens.mul(shared_profit) / total_supply));
        }
    }

    function burnTokens(address addr, uint tokens) internal {

        UserRecord storage user = user_data[addr];

        uint dividends_from_tokens = 0;
        if (total_supply == tokens) {
            dividends_from_tokens = shared_profit.mul(user.tokens) / total_supply;
        }

        shared_profit = shared_profit.mul(total_supply.sub(tokens)) / total_supply;

        total_supply = total_supply.sub(tokens);
        user.tokens = user.tokens.sub(tokens);

        if (total_supply > 0) {
            user.funds_correction = user.funds_correction.sub(int(tokens.mul(shared_profit) / total_supply));
        }
        else if (dividends_from_tokens != 0) {
            user.funds_correction = user.funds_correction.sub(int(dividends_from_tokens));
        }
    }

    function rewardReferrer(address addr, address referrer_addr, uint funds, uint full_funds) internal returns (uint funds_after_reward) {
        UserRecord storage referrer = user_data[referrer_addr];
        if (referrer.tokens >= minimal_stake) {
            (uint reward_funds, uint taxed_funds) = fee_referral.split(funds);
            referrer.ref_funds = referrer.ref_funds.add(reward_funds);
            emit ReferralReward(addr, referrer_addr, full_funds, reward_funds, now);
            return taxed_funds;
        }
        else {
            return funds;
        }
    }

    function fundsToTokens(uint funds) internal view returns (uint tokens, uint _price) {
        uint b = price.mul(2).sub(price_offset);
        uint D = b.mul(b).add(price_offset.mul(8).mul(funds).mul(precision_factor));
        uint n = D.sqrt().sub(b).mul(precision_factor) / price_offset.mul(2);
        uint anp1 = price.add(price_offset.mul(n) / precision_factor);
        return (n, anp1);
    }

    function tokensToFunds(uint tokens) internal view returns (uint funds, uint _price) {
        uint sell_price = price.sub(price_offset);
        uint an = sell_price.add(price_offset).sub(price_offset.mul(tokens) / precision_factor);
        uint sn = sell_price.add(an).mul(tokens) / precision_factor.mul(2);
        return (sn / precision_factor, an);
    }

    // ==== 活動 ==== //

    event Purchase(address indexed addr, uint funds, uint tokens, uint price, uint time);
    event Selling(address indexed addr, uint tokens, uint funds, uint price, uint time);
    event Reinvestment(address indexed addr, uint funds, uint tokens, uint price, uint time);
    event Withdrawal(address indexed addr, uint funds, uint time);
    event Donation(address indexed addr, uint funds, uint time);
    event ReferralReward(address indexed referral_addr, address indexed referrer_addr, uint funds, uint reward_funds, uint time);

    //ERC20
    event Transfer(address indexed from_addr, address indexed to_addr, uint tokens);

}

library SafeMath {

    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, "mul failed");
        return c;
    }

    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a, "sub failed");
        return a - b;
    }

    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "add failed");
        return c;
    }

    function sqrt(uint x) internal pure returns (uint y) {
        uint z = add(x, 1) / 2;
        y = x;
        while (z < y) {
            y = z;
            z = add(x / z, z) / 2;
        }
    }
}

library SafeMathInt {

    function sub(int a, int b) internal pure returns (int) {
        int c = a - b;
        require(c <= a, "sub failed");
        return c;
    }

    function add(int a, int b) internal pure returns (int) {
        int c = a + b;
        require(c >= a, "add failed");
        return c;
    }
}

library Fee {

    using SafeMath for uint;

    struct fee {
        uint num;
        uint den;
    }

    function split(fee memory f, uint value) internal pure returns (uint tax, uint taxed_value) {
        if (value == 0) {
            return (0, 0);
        }
        tax = value.mul(f.num) / f.den;
        taxed_value = value.sub(tax);
    }

    function get_tax(fee memory f, uint value) internal pure returns (uint tax) {
        if (value == 0) {
            return 0;
        }
        tax = value.mul(f.num) / f.den;
    }
}

library ToAddress {

    function toAddr(bytes source) internal pure returns (address addr) {
        assembly {
            addr := mload(add(source, 0x14))
        }
        return addr;
    }
}