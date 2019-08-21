pragma solidity ^0.4.4;

/** 
 YUNIQUE EXCHANGE TOKEN SALE CONTRACT
 
 Yunique Exchange is a Unique centralised and decentralised hybrid exchange 
 which allows the traders to deposit, withdraw, buy and sell, claim some airdrops, 
 use atomic swap, and spend their cryptocurrency with high safety and security.
 
 Website: https://www.yunique.pro
 Twitter: https://twitter.com/YuniqueExchange
 Telegram: https://t.me/yuniquex
 Facebook: https://web.facebook.com/exchange.yunique.pro/
 ------------------------------------------------------------------------------------
 ***Token Sale information***
 
 Minimum investment 0.01 ETH and Maximum Investment 5 ETH
 *** Price and Bonuses as follws
  
  0.01 ETH = 160,000 YQX
  0.1 ETH = 1,600,000 + 20% Bonus
  0.5 ETH = 8,000,000 + 25% Bonus 
  1 ETH = 16,000,000 + 30% Bonus
  5 ETH = 80,000,000 + 40% Bonus
  -----------------------------------------------------------------------------------
  ___________________________________________________________________________________
  
  КОНТРАКТ ПРОДАЖИ ПРОДУКТА YUNIQUE EXCHANGE
 
 Yunique Exchange - это уникальный централизованный и децентрализованный гибридный обмен
 что позволяет трейдерам делать депозиты, снимать, покупать и продавать, требовать какие-то воздушные кадры,
 использовать атомный своп и тратить свою криптовалютность с высокой безопасностью и безопасностью.
 
 Веб-сайт: https://www.yunique.pro
 Twitter: https://twitter.com/YuniqueExchange
 Телеграмма: https://t.me/yuniquex
 Facebook: https://web.facebook.com/exchange.yunique.pro/
 -------------------------------------------------- ----------------------------------
 *** Токен Информация о продаже ***
 
 Минимальные инвестиции 0,01 ETH и максимальные инвестиции 5 ETH
 *** Цена и бонусы, как указано ниже
  
  0,01 ETH = 160 000 YQX
  0.1 ETH = 1,600,000 + 20% Бонус
  0,5 ETH = 8 000 000 + 25% Бонус
  1 ETH = 16,000,000 + 30% Бонус
  5 ETH = 80 000 000 + 40% Бонус
  -------------------------------------------------- ---------------------------------
  ___________________________________________________________________________________
  YUNIQUE EXCHANGE TOKEN xiāoshòu hétóng
 
 Yunique Exchange shì yīgè dútè de jízhōng hé fēnsàn de hùnhé jiāohuàn
 yǔnxǔ jiāoyì zhě cúnkuǎn, qǔkuǎn, mǎimài, yāoqiú yīxiē kōngtóu,
 shǐyòng yuánzǐ jiāohuàn, bìng yǐ gāo ānquán xìng hé ānquán xìng shǐyòng jiāmì huòbì.
 
 Wǎngzhàn:Https://Www.Yunique.Pro
 Twitter:Https://Twitter.Com/YuniqueExchange
 diànbào:Https://T.Me/yuniquex
 Facebook:Https://Web.Facebook.Com/exchange.Yunique.Pro/
 -------------------------------------------------- ----------------------------------
 ***lìng pái xiāoshòu xìnxī***
 
 zuìdī tóuzī 0.01 ETH hé zuìdà tóuzī 5 ETH
 ***jiàgé hé jiǎngjīn rúxià
  
  0.01 ETH = 160,000 YQX
  0.1 ETH = 1,600,000 + 20%jiǎngjīn
  0.5 ETH = 8,000,000 + 25%jiǎngjīn
  1 ETH = 16,000,000 + 30%jiǎngjīn
  5 ETH = 80,000,000 + 40%jiǎngjīn
  -------------------------------------------------- ---------------------------------
  ___________________________________________________________________________________
  KUNTRATT TA 'BEJGĦ TAT-TKEN TA' YUNIQUE
 
 L-Iskambju Yunique huwa skambju ibridu ċentralizzat uniku u deċentralizzat
 li tippermetti lin-negozjanti li jiddepożitaw, jirtiraw, jixtru u jbigħu, jitolbu xi airdrops,
 uża tpartit atomiku, u tqatta 'l-cryptocurrency tagħhom b'sigurtà u sigurtà għolja.
 
 Sit elettroniku: https://www.yunique.pro
 Twitter: https://twitter.com/YuniqueExchange
 Telegramma: https://t.me/yuniquex
 Facebook: https://web.facebook.com/exchange.yunique.pro/
 -------------------------------------------------- ----------------------------------
 *** Informazzjoni dwar it-Token Sale ***
 
 Investiment minimu 0.01 ETH u Investiment Massimu 5 ETH
 *** Prezz u Bonuses bħala follws
  
  0.01 ETH = 160,000 YQX
  0.1 ETH = 1,600,000 + 20% Bonus
  0.5 ETH = 8,000,000 + 25% Bonus
  1 ETH = 16,000,000 + 30% Bonus
  5 ETH = 80,000,000 + 40% Bonus
  -------------------------------------------------- ---------------------------------
  ___________________________________________________________________________________
  ユナイテッド・トーキン・セール・コンクール
 
 Yunique Exchangeはユニークな集中型および分散型のハイブリッド交換機です
 トレーダーが預金、撤退、売買、一部のエアドロップの請求、
 アトミックスワップを使用し、高い安全性とセキュリティを備えた暗号侵害を使います。
 
 ウェブサイト：https://www.yunique.pro
 Twitter：https://twitter.com/YuniqueExchange
 電報：https://t.me/yuniquex
 Facebook：https://web.facebook.com/exchange.yunique.pro/
 -------------------------------------------------- ----------------------------------
 ***トークンセール情報***
 
 最低投資0.01 ETHと最大投資5 ETH
 ***以下のような価格とボーナス
  
  0.01 ETH = 160,000 YQX
  0.1 ETH = 1,600,000 + 20％ボーナス
  0.5 ETH = 8,000,000 + 25％ボーナス
  1 ETH = 16,000,000 + 30％ボーナス
  5 ETH = 80,000,000 + 40％ボーナス
  -------------------------------------------------- ---------------------------------
  ___________________________________________________________________________________
  
  */
 
contract Token {
 
    /// @return total amount of tokens
    function totalSupply() constant returns (uint256 supply) {}
 
    /// @param _owner The address from which the balance will be retrieved
    /// @return The balance
    function balanceOf(address _owner) constant returns (uint256 balance) {}
 
    /// @notice send `_value` token to `_to` from `msg.sender`
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transfer(address _to, uint256 _value) returns (bool success) {}
 
    /// @notice send `_value` token to `_to` from `_from` on the condition it is approved by `_from`
    /// @param _from The address of the sender
    /// @param _to The address of the recipient
    /// @param _value The amount of token to be transferred
    /// @return Whether the transfer was successful or not
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {}
 
    /// @notice `msg.sender` approves `_addr` to spend `_value` tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @param _value The amount of wei to be approved for transfer
    /// @return Whether the approval was successful or not
    function approve(address _spender, uint256 _value) returns (bool success) {}
 
    /// @param _owner The address of the account owning tokens
    /// @param _spender The address of the account able to transfer the tokens
    /// @return Amount of remaining tokens allowed to spent
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {}
 
    event Transfer(address indexed _from, address indexed _to, uint256 _value);
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
   
}
 
 
 
contract StandardToken is Token {
 
    function transfer(address _to, uint256 _value) returns (bool success) {
        //Default assumes totalSupply can't be over max (2^256 - 1).
        //If your token leaves out totalSupply and can issue more tokens as time goes on, you need to check if it doesn't wrap.
        //Replace the if with this one instead.
        //if (balances[msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[msg.sender] >= _value && _value > 0) {
            balances[msg.sender] -= _value;
            balances[_to] += _value;
            Transfer(msg.sender, _to, _value);
            return true;
        } else { return false; }
    }
 
    function transferFrom(address _from, address _to, uint256 _value) returns (bool success) {
        //same as above. Replace this line with the following if you want to protect against wrapping uints.
        //if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && balances[_to] + _value > balances[_to]) {
        if (balances[_from] >= _value && allowed[_from][msg.sender] >= _value && _value > 0) {
            balances[_to] += _value;
            balances[_from] -= _value;
            allowed[_from][msg.sender] -= _value;
            Transfer(_from, _to, _value);
            return true;
        } else { return false; }
    }
 
    function balanceOf(address _owner) constant returns (uint256 balance) {
        return balances[_owner];
    }
 
    function approve(address _spender, uint256 _value) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);
        return true;
    }
 
    function allowance(address _owner, address _spender) constant returns (uint256 remaining) {
      return allowed[_owner][_spender];
    }
 
    mapping (address => uint256) balances;
    mapping (address => mapping (address => uint256)) allowed;
    uint256 public totalSupply;
}
 
 
contract Yunique is StandardToken { // CHANGE THIS. Update the contract name.

    /* Public variables of the token */

    /*
    NOTE:
    The following variables are OPTIONAL vanities. One does not have to include them.
    They allow one to customise the token contract & in no way influences the core functionality.
    Some wallets/interfaces might not even bother to look at this information.
    */
    string public name;                   // Token Name
    uint8 public decimals;                // How many decimals to show. To be standard complicant keep it 18
    string public symbol;                 // An identifier: eg SBX, XPR etc..
    string public version = 'H1.0'; 
    uint256 public unitsOneEthCanBuy;     // How many units of your coin can be bought by 1 ETH?
    uint256 public totalEthInWei;         // WEI is the smallest unit of ETH (the equivalent of cent in USD or satoshi in BTC). We'll store the total ETH raised via our ICO here.  
    address public fundsWallet;           // Where should the raised ETH go?

    // This is a constructor function 
    // which means the following function name has to match the contract name declared above
    function Yunique() {
        balances[msg.sender] = 12888888888000000000000000000;               // Give the creator all initial tokens. This is set to 1000 for example. If you want your initial tokens to be X and your decimal is 5, set this value to X * 100000. (CHANGE THIS)
        totalSupply = 12888888888000000000000000000;                        // Update total supply (1000 for example) (CHANGE THIS)
        name = "Yunique";                                   // Set the name for display purposes (CHANGE THIS)
        decimals = 18;                                               // Amount of decimals for display purposes (CHANGE THIS)
        symbol = "YQX";                                             // Set the symbol for display purposes (CHANGE THIS)
        unitsOneEthCanBuy = 160000000;                                      // Set the price of your token for the ICO (CHANGE THIS)
        fundsWallet = msg.sender;                                  // The owner of the contract gets ETH
    }

    function() payable{
        totalEthInWei = totalEthInWei + msg.value;
        uint256 amount = msg.value * unitsOneEthCanBuy;
        require(balances[fundsWallet] >= amount);

        balances[fundsWallet] = balances[fundsWallet] - amount;
        balances[msg.sender] = balances[msg.sender] + amount;

        Transfer(fundsWallet, msg.sender, amount); // Broadcast a message to the blockchain

        //Transfer ether to fundsWallet
        fundsWallet.transfer(msg.value);                               
    }

    /* Approves and then calls the receiving contract */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData) returns (bool success) {
        allowed[msg.sender][_spender] = _value;
        Approval(msg.sender, _spender, _value);

        //call the receiveApproval function on the contract you want to be notified. This crafts the function signature manually so one doesn't have to include a contract in here just for this.
        //receiveApproval(address _from, uint256 _value, address _tokenContract, bytes _extraData)
        //it is assumed that when does this that the call *should* succeed, otherwise one would use vanilla approve instead.
        if(!_spender.call(bytes4(bytes32(sha3("receiveApproval(address,uint256,address,bytes)"))), msg.sender, _value, this, _extraData)) { throw; }
        return true;
    }
}