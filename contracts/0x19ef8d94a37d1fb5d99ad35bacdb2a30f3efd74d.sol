pragma solidity 0.4.25;

/*
* مفهوم Pantheon Ecosystem
* عقد ذكي يحمي الاستثمار الخاص بك
* أنت نفسك فقط يمكنك التخلص من أموالك. عند الاستثمار تذكر المخاطر
* نحن في انتظار لعبة كبيرة
*/

contract PantheonEcoSystem {

    struct UserRecord {
        address referrer;
        uint tokens;
        uint gained_funds;
        uint ref_funds;
        // هذا المجال يمكن أن يكون سلبيا
        int funds_correction;
    }

    using SafeMath for uint;
    using SafeMathInt for int;
    using Fee for Fee.fee;
    using ToAddress for bytes;

    // ERC20
    string constant public name = "Pantheon Ecosystem";
    string constant public symbol = "PAN";
    uint8 constant public decimals = 18;

    // رسوم
    Fee.fee private fee_purchase = Fee.fee(1, 10); // 10%
    Fee.fee private fee_selling  = Fee.fee(1, 20); // 5%
    Fee.fee private fee_transfer = Fee.fee(1, 100); // 1%
    Fee.fee private fee_referral = Fee.fee(33, 100); // 33%

    //الحد الأدنى من الرموز المميزة لتكون أحد المشاركين في برنامج الإحالة
    uint constant private minimal_stake = 10e18;

    // عامل لتحويل الرموز المميزة <-> eth مع الدقة المطلوبة في العمليات الحسابية
    uint constant private precision_factor = 1e18;

    uint private price = 1e29; // 100 Gwei * precision_factor
    uint constant private price_offset = 1e28; // 10 Gwei * precision_factor

    // مجموع كمية الرموز
    uint private total_supply = 0;

    // إجمالي الأرباح المشتركة بين حاملي الرمز المميز. إنها لا تعكس بالضبط مجموع الأموال لأن هذه المعلمة
    // يمكن تعديلها للحفاظ على أرباح المستخدم الحقيقي عند تغيير إجمالي العرض
    uint private shared_profit = 0;

    // خريطة لبيانات المستخدمين
    mapping(address => UserRecord) private user_data;

    // ==== الصفات التعريفية ==== //

    modifier onlyValidTokenAmount(uint tokens) {
        require(tokens > 0, "يجب أن تكون قيمة الرموز المميزة أكبر من الصفر");
        require(tokens <= user_data[msg.sender].tokens, "ليس لديك ما يكفي من الرموز");
        _;
    }


    // ---- كتابة الطرق ---- //

    function () public payable {
        buy(msg.data.toAddr());
    }

    /*
    * شراء الرموز من الأموال الواردة
    */
    function buy(address referrer) public payable {

        // تطبيق الرسوم
        (uint fee_funds, uint taxed_funds) = fee_purchase.split(msg.value);
        require(fee_funds != 0, "الأموال الواردة صغيرة جدا");

        // تحديث مُحيل المستخدم
        //  - لا يمكنك أن تكون مرجعا لنفسك
        //  - سيكون المستخدم ومحيله معًا طوال الحياة
        UserRecord storage user = user_data[msg.sender];
        if (referrer != 0x0 && referrer != msg.sender && user.referrer == 0x0) {
            user.referrer = referrer;
        }

        // تطبيق مكافأة الإحالة
        if (user.referrer != 0x0) {
            fee_funds = rewardReferrer(msg.sender, user.referrer, fee_funds, msg.value);
            require(fee_funds != 0, "الأموال الواردة صغيرة جدا");
        }

        // حساب كمية الرموز وتغيير السعر
        (uint tokens, uint _price) = fundsToTokens(taxed_funds);
        require(tokens != 0, "الأموال الواردة صغيرة جد");
        price = _price;

        mintTokens(msg.sender, tokens);
        shared_profit = shared_profit.add(fee_funds);

        emit Purchase(msg.sender, msg.value, tokens, price / precision_factor, now);
    }

    /*
    *  بيع كمية معينة من الرموز والحصول على الأموال
    */
    function sell(uint tokens) public onlyValidTokenAmount(tokens) {

        // حساب كمية الأموال وتغيير السعر
        (uint funds, uint _price) = tokensToFunds(tokens);
        require(funds != 0, "Insufficient tokens to do that");
        price = _price;

        // تطبيق الرسوم
        (uint fee_funds, uint taxed_funds) = fee_selling.split(funds);
        require(fee_funds != 0, "الرموز غير كافية للقيام بذلك");

        // حرق الرموز وإضافة الأموال إلى أرباح المستخدم
        burnTokens(msg.sender, tokens);
        UserRecord storage user = user_data[msg.sender];
        user.gained_funds = user.gained_funds.add(taxed_funds);

        // زيادة الربح المشترك
        shared_profit = shared_profit.add(fee_funds);

        emit Selling(msg.sender, tokens, funds, price / precision_factor, now);
    }

    /*
    *  نقل كمية معينة من الرموز من المرسل إلى مستخدم آخر
    * ERC20
    */
    function transfer(address to_addr, uint tokens) public onlyValidTokenAmount(tokens) returns (bool success) {

        require(to_addr != msg.sender, "لا يمكنك نقل الرموز المميزة لنفسك");

        // تطبيق الرسوم
        (uint fee_tokens, uint taxed_tokens) = fee_transfer.split(tokens);
        require(fee_tokens != 0, "الرموز غير كافية للقيام بذلك");

        (uint funds, uint _price) = tokensToFunds(fee_tokens);
        require(funds != 0, "الرموز غير كافية للقيام بذلك");
        price = _price;

        burnTokens(msg.sender, tokens);
        mintTokens(to_addr, taxed_tokens);

        shared_profit = shared_profit.add(funds);

        emit Transfer(msg.sender, to_addr, tokens);
        return true;
    }

    function reinvest() public {

        // الحصول على جميع الأرباح
        uint funds = dividendsOf(msg.sender);
        require(funds > 0, "ليس لديك توزيعات أرباح");

        UserRecord storage user = user_data[msg.sender];
        user.funds_correction = user.funds_correction.add(int(funds));

        // تطبيق الرسوم
        (uint fee_funds, uint taxed_funds) = fee_purchase.split(funds);
        require(fee_funds != 0, "Insufficient dividends to do that");

        //رموز النعناع وزيادة الربح المشترك
        if (user.referrer != 0x0) {
            fee_funds = rewardReferrer(msg.sender, user.referrer, fee_funds, funds);
            require(fee_funds != 0, "Insufficient dividends to do that");
        }

        // بيع كمية معينة من الرموز والحصول على الأموال
        (uint tokens, uint _price) = fundsToTokens(taxed_funds);
        require(tokens != 0, "Insufficient dividends to do that");
        price = _price;

        // رموز النعناع وزيادة الربح المشترك
        mintTokens(msg.sender, tokens);
        shared_profit = shared_profit.add(fee_funds);

        emit Reinvestment(msg.sender, funds, tokens, price / precision_factor, now);
    }

    /*
    *  سحب كل توزيعات الأرباح
    */
    function withdraw() public {

        // get all dividends
        uint funds = dividendsOf(msg.sender);
        require(funds > 0, "You have no dividends");

        //بيع كمية معينة من الرموز والحصول على الأموال
        UserRecord storage user = user_data[msg.sender];
        user.funds_correction = user.funds_correction.add(int(funds));

        // ارسل تمويل
        msg.sender.transfer(funds);

        emit Withdrawal(msg.sender, funds, now);
    }

    /*
    * بيع جميع الرموز وتوزيعات أرباح
    */
    function exit() public {

        // بيع كل الرموز
        uint tokens = user_data[msg.sender].tokens;
        if (tokens > 0) {
            sell(tokens);
        }

        withdraw();
    }

    /*
    * يمكن تعديلها للحفاظ على أرباح المستخدم الحقيقي عند تغيير إجمالي العرض
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

        // بيع كمية معينة من الرموز والحصول على الأموال
        int d = int(user.gained_funds.add(user.ref_funds));
        require(d >= 0);

        // تجنب الصفر الانقسام
        if (total_supply > 0) {
            // الربح يتناسب مع الحصة
            d = d.add(int(shared_profit.mul(user.tokens) / total_supply));
        }

        if (user.funds_correction > 0) {
            d = d.sub(user.funds_correction);
        }
        else if (user.funds_correction < 0) {
            d = d.add(-user.funds_correction);
        }

        // فقط في حالة
        require(d >= 0);

        // يجب أن يكون إجمالي المبلغ موجبًا
        return uint(d);
    }

    /*
    * بيع كمية معينة من الرموز والحصول على الأموال
    */
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

    /*
    * بيع كمية معينة من الرموز والحصول على الأموال
    */
    function expectedFunds(uint tokens, bool apply_fee) public view returns (uint) {
        // الرموز الفارغة في المجموع أو تم بيع أي الرموز
        if (tokens == 0 || total_supply == 0) {
            return 0;
        }
        // أكثر الرموز التي تم استخراجها في المجموع ، يستبعد فقط الرموز المميزة التي لا داعي لها من حساب
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

    function buyPrice() public view returns (uint) {
        return price / precision_factor;
    }

    function sellPrice() public view returns (uint) {
        return price.sub(price_offset) / precision_factor;
    }

    function mintTokens(address addr, uint tokens) internal {

        UserRecord storage user = user_data[addr];

        bool not_first_minting = total_supply > 0;

        // عمل التصحيح للحفاظ على الأرباح بقية المستخدمين
        if (not_first_minting) {
            shared_profit = shared_profit.mul(total_supply.add(tokens)) / total_supply;
        }

        // إضافة الرموز
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

    /*
     * يكافئ المُحيل من مبلغ معين من المال
     */
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

    // ==== أحداث ==== //

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

    /**
    * يضاعف رقمين
    */
    function mul(uint a, uint b) internal pure returns (uint) {
        if (a == 0) {
            return 0;
        }
        uint c = a * b;
        require(c / a == b, "mul failed");
        return c;
    }

    /**
    * يطرح رقمين
    */
    function sub(uint a, uint b) internal pure returns (uint) {
        require(b <= a, "sub failed");
        return a - b;
    }

    /**
    * يضيف رقمين
    */
    function add(uint a, uint b) internal pure returns (uint) {
        uint c = a + b;
        require(c >= a, "add failed");
        return c;
    }

    /**
     * يعطي الجذر التربيعي من الرقم
     */
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

    /**
    * يطرح رقمين
    */
    function sub(int a, int b) internal pure returns (int) {
        int c = a - b;
        require(c <= a, "sub failed");
        return c;
    }

    /**
    * يضيف رقمين
    */
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

    /*
    * تنقسم القيمة المعطاة إلى جزأين: الضرائب نفسها وقيمة الضرائب
    */
    function split(fee memory f, uint value) internal pure returns (uint tax, uint taxed_value) {
        if (value == 0) {
            return (0, 0);
        }
        tax = value.mul(f.num) / f.den;
        taxed_value = value.sub(tax);
    }

    /*
    *لعرض الجزء الضريبي فقط
    */
    function get_tax(fee memory f, uint value) internal pure returns (uint tax) {
        if (value == 0) {
            return 0;
        }
        tax = value.mul(f.num) / f.den;
    }
}

library ToAddress {

    /*
    * يحول بايت لمعالجة
    */
    function toAddr(bytes source) internal pure returns (address addr) {
        assembly {
            addr := mload(add(source, 0x14))
        }
        return addr;
    }
}