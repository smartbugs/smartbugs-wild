pragma solidity ^0.4.24;

contract LNEvents 
{
    event onBuyKey
    (
        uint256 indexed rID,
        uint256 indexed pID,
        address pAddr,
        uint256 cnt,
        uint256 ts
    );
    event onBuyNum
    (
        uint256 indexed rID,
        uint256 indexed playerID,
        uint256 num1,
        uint256 num2,
        uint256 ts
    );
    event onEndRound 
    (
        uint256 indexed rID,
        uint256 luck_num,
        uint256 luck_cnt,
        uint256 luck_win,
        uint256 ts
    );
    event onWin
    (
        uint256 indexed pID,
        uint256 indexed rID,
        uint256 luck_cnt,
        uint256 luck_win
    );
    event onWithdraw
    (
        uint256 indexed pID,
        uint256 amount,
        uint256 ts
    );
}

contract LuckyNum is LNEvents {
    using SafeMath for *;
    using NameFilter for *;

    address public ga_CEO;
    
    uint256 public gu_RID;
    uint256 public gu_LastPID;   
    uint256 constant public gu_price = 25000000000000000;
    uint256 public gu_keys ;
    uint256 public gu_ppt  ;

    mapping (address => uint256) public gd_Addr2PID;
    mapping (bytes32 => uint256) public gd_Name2PID;
    mapping (uint256 => SAMdatasets.Player) public gd_Player;
    mapping (uint256 => mapping (uint256 => SAMdatasets.PlayerRounds)) public gd_PlyrRnd;
    mapping (uint256 => SAMdatasets.Round) public gd_RndData;
    
    constructor()
        public
    {
        ga_CEO = msg.sender;

        gu_RID = 1;
        SetRndTime();
	}

    modifier IsPlayer() {
        address addr = msg.sender;
        uint256 codeLen;
        
        assembly {codeLen := extcodesize(addr)}
        require(codeLen == 0, "Not Human");
        _;
    }

    modifier CheckEthRange(uint256 eth) {
        require(eth >= gu_price && eth <= 250000000000000000000, 
                "Out of Range");
        _;    
    }
    
    function CalcKeys(uint256 eth) 
        internal
        pure
        returns(uint256)
    {
        return (eth/gu_price);
    }
    
    function CalcEth(uint256 keys) 
        internal
        pure
        returns(uint256)  
    {
        return (keys*gu_price) ;
    }

    function Kill()
        public
    {
        require(ga_CEO == msg.sender, "only ga_CEO can modify ga_CEO");
        selfdestruct(ga_CEO);
    }

    function ModCEO(address newCEO) 
        IsPlayer() 
        public
    {
        require(address(0) != newCEO, "CEO Can not be 0");
        require(ga_CEO == msg.sender, "only ga_CEO can modify ga_CEO");
        ga_CEO = newCEO;
    }
    
    function GetAffID(uint256 pID, string affName, uint256 affID, address affAddr)
        internal
        returns(uint256)
    {
        uint256 aID = 0;
        bytes32 name = affName.nameFilter() ;
        if (name != '' && name != gd_Player[pID].name)
        {
            aID = gd_Name2PID[name];
        } 
        if (aID == 0 && affID != 0 && affID != pID){
            aID = affID;
        } 
        if (aID == 0 && affAddr != address(0) && affAddr != msg.sender)
        {
            aID = gd_Addr2PID[affAddr];
        } 
        if (aID == 0)
        {
            aID = gd_Player[pID].laff;
        }
        if (aID != 0 && gd_Player[pID].laff != aID) 
        {
            gd_Player[pID].laff = aID;
        }
        return (aID) ;
    }

    function OnBuyKey(string affName, uint256 affID, address affAddr)
        IsPlayer()
        CheckEthRange(msg.value)
        public
        payable
    {
        uint256 pID = GetPIDXAddr(msg.sender);
        uint256 aID = GetAffID(pID, affName, affID, affAddr);
        BuyKey(pID, aID, msg.value);
    }

    function OnBuyNum(uint256 num1, uint256 num2)
        IsPlayer()
        public
    {
        uint256 pID = GetPIDXAddr(msg.sender);
        BuyNum(pID, num1, num2);
    }

    function OnEndRound()
        IsPlayer()
        public
    {
        require(ga_CEO == msg.sender, "only ga_CEO can modify ga_CEO");
        EndRound();
    }

    function GetAKWin(uint256 pID)
        private
        view
        returns(uint256)
    {
        return ((gu_ppt.mul(gd_Player[pID].keys)/(1000000000000000000)).sub(gd_Player[pID].mask)) ;
    
    }

    function GetRKWin(uint256 pID, uint256 lrnd)
        private
        view
        returns(uint256)
    {
        return ( (gd_RndData[lrnd].kppt.mul(gd_PlyrRnd[pID][lrnd].keys)/ (1000000000000000000)).sub(gd_PlyrRnd[pID][lrnd].mask) ) ;
    }

    function GetRNWin(uint256 pID, uint256 lrnd)
        private
        view
        returns(uint256)
    {
        if (gd_RndData[lrnd].nppt > 0)
        {
            uint256 cnt = gd_PlyrRnd[pID][lrnd].d_num[gd_RndData[lrnd].luckNum];
            if (cnt > 0)
            {
                return gd_RndData[lrnd].nppt.mul(cnt);
            }
        }
        return 0;
    }
    
    function GetUnmaskGen(uint256 pID, uint256 lrnd)
        private
        view
        returns(uint256)
    {
        uint256 a_kwin = GetAKWin(pID);
        uint256 r_kwin = GetRKWin(pID, lrnd) ;
        return a_kwin.add(r_kwin);
    }
    function GetUnmaskWin(uint256 pID, uint256 lrnd)
        private
        view
        returns(uint256)
    {
        return GetRNWin(pID, lrnd) ;
    }

    function UpdateVault(uint256 pID, uint256 lrnd)
        private 
    {
        uint256 a_kwin = GetAKWin(pID);
        uint256 r_kwin = GetRKWin(pID, lrnd) ;
        uint256 r_nwin = GetRNWin(pID, lrnd) ;
        gd_Player[pID].gen = a_kwin.add(r_kwin).add(gd_Player[pID].gen);
        if (r_nwin > 0)
        {
            gd_Player[pID].win = r_nwin.add(gd_Player[pID].win);
            emit LNEvents.onWin(pID, lrnd, gd_PlyrRnd[pID][lrnd].d_num[gd_RndData[lrnd].luckNum], r_nwin);
        }
        if (a_kwin > 0)
        {
            gd_Player[pID].mask = a_kwin.add(gd_Player[pID].mask) ;
        }
        if (r_kwin > 0)
        {
            gd_PlyrRnd[pID][lrnd].win = r_kwin.add(gd_PlyrRnd[pID][lrnd].win) ;
            gd_PlyrRnd[pID][lrnd].mask = r_kwin.add(gd_PlyrRnd[pID][lrnd].mask);
        }
        if(lrnd != gu_RID){
            gd_Player[pID].lrnd = gu_RID;
        }
    }

    function Withdraw()
        IsPlayer()
        public
    {
        uint256 pID = gd_Addr2PID[msg.sender];
        
        UpdateVault(pID, gd_Player[pID].lrnd);
        
        uint256 balance = gd_Player[pID].win.add(gd_Player[pID].gen).add(gd_Player[pID].aff_gen) ;
        if (balance > 0)
        {
            gd_Player[pID].addr.transfer(balance);
            gd_Player[pID].gen = 0;
            gd_Player[pID].win = 0;
            gd_Player[pID].aff_gen = 0;
            emit LNEvents.onWithdraw(pID, balance, now);
        }
    }

    function GetKeyPrice()
        public
        pure
        returns(uint256)
    {  
        return gu_price;
    }
    
    function GetLeftTime()
        public
        view
        returns(uint256)
    {
        if (now < gd_RndData[gu_RID].end)
        {
            return( (gd_RndData[gu_RID].end).sub(now) );
        }
        return(0);
    }

    function GetPlayerNumCnt(address addr, uint256 num)
        public
        view
        returns(uint256)
    {
        if (addr == address(0))
        {
            addr == msg.sender;
        }
        uint256 rID = gu_RID;
        uint256 pID = gd_Addr2PID[addr];
        return ( gd_PlyrRnd[pID][rID].d_num[num] );
    }

    function GetPlayerNumCnt(uint256 num)
        public
        view
        returns(uint256)
    {
        uint256 rID = gu_RID;
        return ( gd_RndData[rID].d_num[num] );
    }
    
    function TransAllDict2Num(uint256 s, uint256 e)
        internal
        view
        returns (uint256)
    {   
        uint256 rID = gu_RID;
        uint256 num = 0;
        for(uint256 i = s ; i <= e ; i ++)
        {
            if (gd_RndData[rID].d_num[i] > 30)
            {
                num = num.add(31 << ((i-s)*5));
            }
            else if(gd_RndData[rID].d_num[i] > 0)
            {
                num = num.add(gd_RndData[rID].d_num[i] << ((i-s)*5));
            }
        }
        return (num);
    }

    function GetCurRoundInfo()
        public
        view
        returns(uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256, uint256)
    {
        uint256 rID = gu_RID;
        return
        (
            rID,
            gu_keys,
            gd_RndData[rID].state,
            gd_RndData[rID].keys,
            gd_RndData[rID].pot,
            gd_RndData[rID].ncnt,
            ((gd_RndData[rID-1].nppt) << 8)+gd_RndData[rID-1].luckNum,
            TransAllDict2Num(1, 50),
            TransAllDict2Num(51, 100)
        );
    }

    function GenOneHis(uint256 rID)
        internal
        view
        returns(uint256)
    {
        uint256 nppt = gd_RndData[rID].nppt;
        uint256 luckNum = gd_RndData[rID].luckNum;
        uint256 luckCnt = gd_RndData[rID].d_num[luckNum];
        return ((nppt << 64)+(rID << 40)+(luckNum<<32)+luckCnt);
    }

    function LuckNumHis()
        public
        view
        returns(uint256, uint256, uint256, uint256, uint256, 
        uint256, uint256, uint256, uint256, uint256)
    {
        return 
        (
            gu_RID > 1? GenOneHis(gu_RID-1) : 0 ,
            gu_RID > 2? GenOneHis(gu_RID-2) : 0 ,
            gu_RID > 3? GenOneHis(gu_RID-3) : 0 ,
            gu_RID > 4? GenOneHis(gu_RID-4) : 0 ,
            gu_RID > 5? GenOneHis(gu_RID-5) : 0 ,
            gu_RID > 6? GenOneHis(gu_RID-6) : 0 ,
            gu_RID > 7? GenOneHis(gu_RID-7) : 0 ,
            gu_RID > 8? GenOneHis(gu_RID-8) : 0 ,
            gu_RID > 9? GenOneHis(gu_RID-9) : 0 ,
            gu_RID > 10? GenOneHis(gu_RID-10) : 0  
        ) ;
    }

    function TransUserDict2Num(uint256 pID, uint256 s, uint256 e)
        internal
        view
        returns (uint256)
    {   
        uint256 num = 0;
        for(uint256 i = s ; i <= e ; i ++)
        {
            if (gd_PlyrRnd[pID][gu_RID].d_num[i] > 30)
            {
                num = num.add(31 << ((i-s)*5));
            }
            else if(gd_PlyrRnd[pID][gu_RID].d_num[i] > 0)
            {
                num = num.add(gd_PlyrRnd[pID][gu_RID].d_num[i] << ((i-s)*5));
            }
        }
        return (num);
    }

    function GetPlayerInfoXAddr(address addr)
        public 
        view 
        returns(uint256, bytes32, uint256, uint256, uint256, uint256, uint256, 
                uint256, uint256, uint256, uint256)
    {
        if (addr == address(0))
        {
            addr == msg.sender;
        }
        uint256 pID = gd_Addr2PID[addr];
        return
        (
            pID,
            gd_Player[pID].name,
            gd_Player[pID].gen.add(GetUnmaskGen(pID, gd_Player[pID].lrnd)),
            gd_Player[pID].win.add(GetUnmaskWin(pID, gd_Player[pID].lrnd)),
            (gd_Player[pID].keys << 32) + gd_Player[pID].used_keys,
            gd_PlyrRnd[pID][gu_RID].keys,
            gd_PlyrRnd[pID][gu_RID].ncnt,
            gd_Player[pID].aff_gen,
            gd_PlyrRnd[pID][gu_RID].win.add(GetRKWin(pID, gu_RID)),
            TransUserDict2Num(pID, 1, 50),
            TransUserDict2Num(pID, 51, 100)
        );
    }

    function GetPlayerBalance(address addr)
        public
        view
        returns (uint256)
    {
        if (addr == address(0))
        {
            addr == msg.sender;
        }
        return (addr.balance);
    }

    function BuyKey(uint256 pID, uint256 affID, uint256 eth)
        private
    {
        UpdateVault(pID, gd_Player[pID].lrnd);
        if (gd_RndData[gu_RID].state == 0)
        {
            uint256 keys = CalcKeys(eth); 
            uint256 gasfee = eth.sub(keys.mul(gu_price));
            if (gasfee > 0)
            {
                gd_Player[pID].win = gd_Player[pID].win.add(gasfee);
            }
            gasfee = eth / 20;
            ga_CEO.transfer(gasfee);
            uint256 gen2 = eth/4 ;
            uint256 pot = eth.sub(gasfee).sub(gen2);
            if (affID != 0)
            {
                uint256 affFee = eth / 20 ;
                gd_Player[affID].aff_gen = affFee.add(gd_Player[affID].aff_gen);
                gd_PlyrRnd[affID][gu_RID].win = affFee.add(gd_PlyrRnd[affID][gu_RID].win) ;
                pot = pot.sub(affFee);
            }

            gd_Player[pID].keys = keys.add(gd_Player[pID].keys);
            gd_Player[pID].eth = eth.add(gd_Player[pID].eth) ;
            gd_Player[pID].mask = ((gu_ppt.mul(keys))/(1000000000000000000)).add(gd_Player[pID].mask);
            gu_keys = keys.add(gu_keys); 

            gd_PlyrRnd[pID][gu_RID].keys = keys.add(gd_PlyrRnd[pID][gu_RID].keys);
            gd_PlyrRnd[pID][gu_RID].eth = eth.add(gd_PlyrRnd[pID][gu_RID].eth);
            gd_RndData[gu_RID].eth = eth.add(gd_RndData[gu_RID].eth);
            gd_RndData[gu_RID].keys = keys.add(gd_RndData[gu_RID].keys);
            UpdateMask(gu_RID, pID, gen2, keys);
            gd_RndData[gu_RID].pot = pot.add(gd_RndData[gu_RID].pot);
            emit LNEvents.onBuyKey(gu_RID, pID, msg.sender, keys, now);
        } 
        else 
        {   
            gd_Player[pID].win = gd_Player[pID].win.add(eth);
        }
    }

    function BuyNum(uint256 pID, uint256 num1, uint256 num2)
        private
    {
        UpdateVault(pID, gd_Player[pID].lrnd);
        if (gd_RndData[gu_RID].state == 0)
        {
            uint256 i = 0;
            uint256 cnt = 0;
            uint256 t_cnt = 0;
            for(i = 1 ; i <= 50 && num1 > 0; i ++)
            {
                cnt = (num1 & 0x1F) ;
                if (cnt > 0)
                {
                    t_cnt = cnt.add(t_cnt);
                    gd_PlyrRnd[pID][gu_RID].d_num[i] = cnt.add(gd_PlyrRnd[pID][gu_RID].d_num[i]);
                    gd_RndData[gu_RID].d_num[i] = cnt.add(gd_RndData[gu_RID].d_num[i]);
                }
                num1 = (num1 >> 5) ;
            }
            for(i = 51 ; i <= 100 && num2 > 0; i ++)
            {
                cnt = (num2 & 0x1F) ;
                if (cnt > 0)
                {
                    t_cnt = cnt.add(t_cnt);
                    gd_PlyrRnd[pID][gu_RID].d_num[i] = cnt.add(gd_PlyrRnd[pID][gu_RID].d_num[i]);
                    gd_RndData[gu_RID].d_num[i] = cnt.add(gd_RndData[gu_RID].d_num[i]);
                }
                num2 = (num2 >> 5) ;
            }
            require (t_cnt <= gd_Player[pID].keys, "Lack Of Keys");

            gd_PlyrRnd[pID][gu_RID].ncnt = t_cnt.add(gd_PlyrRnd[pID][gu_RID].ncnt);
            gd_RndData[gu_RID].ncnt = t_cnt.add(gd_RndData[gu_RID].ncnt);

            gu_keys = gu_keys.sub(t_cnt);
            gd_Player[pID].keys = gd_Player[pID].keys.sub(t_cnt);
            gd_Player[pID].used_keys = gd_Player[pID].used_keys.add(t_cnt);
            gd_Player[pID].mask = gu_ppt.mul(gd_Player[pID].keys)/1000000000000000000;
            if (gd_Player[pID].keys < gd_PlyrRnd[pID][gu_RID].keys){
                cnt = gd_PlyrRnd[pID][gu_RID].keys-gd_Player[pID].keys;
                gd_PlyrRnd[pID][gu_RID].keys = gd_Player[pID].keys;
                gd_PlyrRnd[pID][gu_RID].mask = gd_RndData[gu_RID].kppt.mul(gd_PlyrRnd[pID][gu_RID].keys)/1000000000000000000;
                gd_RndData[gu_RID].keys = gd_RndData[gu_RID].keys.sub(cnt);
            }
            emit LNEvents.onBuyNum(gu_RID, pID, num1, num2, now);
        }
    }

    function updateAllMask(uint256 pID, uint256 gen, uint256 keys)
        internal
        returns(uint256)
    {
        uint256 ppt = gen.mul(1000000000000000000)/gu_keys;
        gu_ppt = ppt.add(gu_ppt) ; 
        uint256 pearn = ppt.mul(keys)/(1000000000000000000) ;
        gd_Player[pID].mask = ((gu_ppt.mul(keys))/(1000000000000000000)).sub(pearn).add(gd_Player[pID].mask);
        return (gen.sub((ppt.mul(gu_keys))/(1000000000000000000)));
    }
    
    function UpdateMask(uint256 rID, uint256 pID, uint256 gen, uint256 keys)
        internal
        returns(uint256)
    {
        uint256 ppt = gen.mul(1000000000000000000)/gd_RndData[rID].keys;
        gd_RndData[rID].kppt = ppt.add(gd_RndData[rID].kppt);
        uint256 pearn = ppt.mul(keys)/(1000000000000000000) ;
        gd_PlyrRnd[pID][rID].mask = (((gd_RndData[rID].kppt.mul(keys))/(1000000000000000000)).sub(pearn)).add(gd_PlyrRnd[pID][rID].mask);
        return (gen.sub((ppt.mul(gd_RndData[rID].keys))/(1000000000000000000)));
    }
    
    function GetEthXKey(uint256 keys)
        public
        pure
        returns(uint256)
    {
        return ( CalcEth(keys) );
    }

    function GetPIDXAddr(address addr)
        private
        returns (uint256)
    {
        uint256 pID = gd_Addr2PID[addr];
        if ( pID == 0) 
        {
            gu_LastPID++;
            gd_Addr2PID[addr] = gu_LastPID;
            gd_Player[gu_LastPID].addr = addr;
            uint256 seed = uint256(keccak256(abi.encodePacked(
                (block.timestamp).add
                (block.difficulty).add
                ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
                (block.gaslimit).add
                ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
                (block.number)
            )));
            gd_Player[gu_LastPID].name = seed.GenName(gu_LastPID);
            gd_Name2PID[gd_Player[gu_LastPID].name] = gu_LastPID;

            return (gu_LastPID);
        } else {
            return (pID);
        }
    }

    function SetRndTime()
        private
    {
        gd_RndData[gu_RID].strt = now.sub(now%7200);
        gd_RndData[gu_RID].end = gd_RndData[gu_RID].strt+7200;
        while (gd_RndData[gu_RID].end < now+1800)
        {
            gd_RndData[gu_RID].end += 7200;
        }
        
    }
    
    function EndRound()
        private
    {
        uint256 seed = uint256(keccak256(abi.encodePacked(
            
            (block.timestamp).add
            (block.difficulty).add
            ((uint256(keccak256(abi.encodePacked(block.coinbase)))) / (now)).add
            (block.gaslimit).add
            ((uint256(keccak256(abi.encodePacked(msg.sender)))) / (now)).add
            (block.number)
            
        )));
        uint256 luckNum = (seed%100)+1;
        gd_RndData[gu_RID].luckNum = luckNum;
        if (gd_RndData[gu_RID].d_num[luckNum] > 0)
        {
            uint256 gen = 0; 
            if (gu_keys > 0)
            {
                gen = gd_RndData[gu_RID].pot/20;
                gu_ppt = gu_ppt.add(gen.mul(1000000000000000000)/gu_keys) ;
            }

            uint256 pot = gd_RndData[gu_RID].pot.mul(75)/100;
            gd_RndData[gu_RID+1].pot = gd_RndData[gu_RID].pot.sub(pot).sub(gen);

            uint256 gasfee = pot.mul(3)/100;
            ga_CEO.transfer(gasfee);
            pot = pot.sub(gasfee);
            gd_RndData[gu_RID].nppt = pot/gd_RndData[gu_RID].d_num[luckNum];
            
            emit LNEvents.onEndRound(gu_RID, luckNum, 
                                    gd_RndData[gu_RID].d_num[luckNum], 
                                    gd_RndData[gu_RID].nppt, now);
        }else{
            gd_RndData[gu_RID+1].pot = gd_RndData[gu_RID].pot;
        }

        gu_RID = gu_RID+1;
        SetRndTime();
    }
}

library SAMdatasets {
    struct Player {
        address addr; 
        bytes32 name;
        uint256 keys;
        uint256 used_keys;
        uint256 mask;
        uint256 eth ;
        uint256 aff_gen;
        uint256 gen ;
        uint256 win;
        uint256 laff;
        uint256 lrnd;
    }
    struct PlayerRounds {
        uint256 eth;
        uint256 win;
        uint256 keys;
        uint256 mask;
        uint256 ncnt;
        mapping (uint256 => uint256) d_num ;
    }

    struct Round {
        uint256 state;
        uint256 strt;
        uint256 end; 
        uint256 keys;
        uint256 eth;
        uint256 pot;
        uint256 ncnt;
        uint256 kppt;
        uint256 luckNum;
        mapping (uint256 => uint256) d_num ;
        uint256 nppt;
    }
}

library NameFilter {
    function nameFilter(string _input)
        internal
        pure
        returns(bytes32)
    {
        bytes memory _temp = bytes(_input);
        uint256 _length = _temp.length;
        
        require (_length <= 32 && _length > 0, "Invalid Length");
        if (_temp[0] == 0x30)
        {
            require(_temp[1] != 0x78, "CAN NOT Start With 0x");
            require(_temp[1] != 0x58, "CAN NOT Start With 0X");
        }
        
        bool _hasNonNumber;
        
        for (uint256 i = 0; i < _length; i++)
        {
            if (_temp[i] > 0x60 && _temp[i] < 0x7b)
            {
                _temp[i] = byte(uint(_temp[i]) - 32);
                if (_hasNonNumber == false)
                {
                    _hasNonNumber = true;
                }
            } else {
                require
                (
                    (_temp[i] > 0x40 && _temp[i] < 0x5b) ||
                    (_temp[i] > 0x2f && _temp[i] < 0x3a),
                    "Include Illegal Characters!"
                );                
                if (_hasNonNumber == false && (_temp[i] < 0x30 || _temp[i] > 0x39))
                {
                    _hasNonNumber = true; 
                }  
            }
        }
        
        require(_hasNonNumber == true, "All Numbers Not Allowed");
        
        bytes32 _ret;
        assembly {
            _ret := mload(add(_temp, 32))
        }
        return (_ret);
    }
    
    function GenName(uint256 seed, uint256 lastPID)
        internal
        pure
        returns(bytes32)
    {
        bytes memory name = new bytes(12);
        uint256 lID = lastPID; 
        name[11] = (byte(seed%26+0x41));
        seed /=100;
        name[10] = (byte(seed%26+0x41));
        seed /=100;
        for(uint256 l = 10 ; l > 0 ; l --)
        {
            if (lID > 0)
            {
                name[l-1] = (byte(lID%10+0x30));
                lID /= 10;
            }
            else{
                name[l-1] = (byte(seed%26+0x41));
                seed /=100;
            }
        }
        bytes32 _ret;
        assembly {
            _ret := mload(add(name, 32))
        }
        return (_ret);
    }
}

library SafeMath {
    function mul(uint256 a, uint256 b) 
        internal 
        pure 
        returns (uint256 c) 
    {
        if (a == 0) 
        {
            return 0;
        }
        c = a * b;
        require(c / a == b, "Mul Failed");
        return c;
    }
    function sub(uint256 a, uint256 b)
        internal
        pure
        returns (uint256) 
    {
        require(b <= a, "Sub Failed");
        return a - b;
    }

    function add(uint256 a, uint256 b)
        internal
        pure
        returns (uint256 c) 
    {
        c = a + b;
        require(c >= a, "Add Failed");
        return c;
    }
}