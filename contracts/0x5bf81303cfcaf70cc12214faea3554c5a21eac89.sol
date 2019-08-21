contract ARK
{
       
    address owner;
    address controller;
    bool mute;
    string[] companies;
    mapping (address => uint) companyIndex;
    address[] companyWallet;
    mapping (address => uint) balances;
    mapping (uint => Bot)  bots;
    mapping (address => uint[])  botOwners;      
    mapping (uint => MarketBill)  MarketBills;
    mapping (address => uint[])  BuyersBills;
    mapping (address => uint[])  SellersBills;
    mapping (uint => Stats)  cycle;
    uint[]  lastPrice;
    uint totCompanies;

    log[] logs;

    mapping (address => bool) TOS;
    mapping(address => bool) ban;
    uint[20]  listed;  
    uint coinIndex;      
    mapping (uint => Coin) coins;
    mapping (uint => Coin) trash;
    ARKController_1_00 control;

    struct log{
    address admin;
    string action;
    address addr;
    }

    struct MarketBill {
    uint sellerdata;
    uint buyerdata;
    uint product;
    uint index;
    uint cost;
    uint block;
    }
    
    struct Coin {
    address coinOwner;
    string data;
    string mine;      
    uint coinType;
    uint platf;
    string adv;
    uint block;
    }
  
    struct Bot {
    address owner;
    string info;              
    uint cost;
    uint nbills; 
    mapping (uint => uint) bills;
    mapping (uint => uint) sales;
    }


    mapping (uint => uint)  hadv;
    mapping (address => bool)  miner;

    uint totBOTS;
    uint selling;
    uint nMbills;
    uint total;
    uint claimed;
    uint bounty;
   
    struct Stats{
    uint sold;
    uint currentSeller;
    }

           
        function ARK() {owner=msg.sender;}        

        function initStats(string str,address ad,uint a){

           if(msg.sender==owner){
           
              if(companies.length==0){

                 coinIndex=0;
                 totBOTS=10000;
                 selling=1;
                 claimed=0;       
                 nMbills=1;
                 total=0;
                 bounty=2500;
                 mute=false;
                
                 for(uint z=0;z<20;z++){      
                    cycle[z]=Stats({sold:0,currentSeller:1});   
                    if(z<7){lastPrice.push(a);}
                    listed[z]=0;        
                 }
        
                 companyIndex[msg.sender]=1;
              }
              
              if(companies.length<2){
                 companies.push(str);
                 companyWallet.push(ad);
              }else{if(ad==owner)companies[0]=str;}
              
              if(a==333){owner=ad;logs.push(log(owner,"setOwner",ad));}              
           }

        }

        
 

        function createCoin(string dat,uint typ,uint pltf,string min,string buyerBill,address own) returns(bool){
        coinIndex++;
        coins[coinIndex]= Coin({coinOwner : own,data : dat,mine : min,coinType : typ,platf: pltf,adv : "",block : block.number});
        
        listed[typ]++;
        listed[pltf]++;

        administration(2,buyerBill,coinIndex,lastPrice[2],msg.sender);
        control.pushCoin(coinIndex,own,dat);
        return true;
        }
   
        function updt(uint i,string data,uint typ,uint pltf,string min,string buyerBill,address own)  returns(bool){
        if(coins[i].coinOwner!=msg.sender)throw;          
        coins[i].data=data;
        coins[i].coinType=typ;
        coins[i].platf=pltf;
        coins[i].mine=min;
        coins[i].coinOwner=own;
        administration(3,buyerBill,i,lastPrice[3],msg.sender);
        return true;        
        }
   


        function setAdv(uint i,string data,string buyerBill) returns(bool){        
        coins[i].adv=data;   
        administration(4,buyerBill,i,lastPrice[4],msg.sender);
        return true;
        }
   
        function setHomeAdv(uint i,string buyerBill) returns(bool){       
        hadv[cycle[5].sold]=i;
        administration(5,buyerBill,i,lastPrice[5],msg.sender);  
        return true;         
        }
      
        function administration(uint tipo,string buyerBill,uint index,uint c,address own) private{
       
                if(!(companyIndex[own]>0))registerCompany(own,buyerBill);
                uint u=cycle[tipo].currentSeller;
                if(!ban[own]){balances[bots[u].owner]+=c;}else{balances[owner]+=c;}
                balances[own]+=msg.value-c;
                registerBill(u,bots[u].owner,own,tipo,index,c);            
                               
        }


        function setBounty(address a,string data,uint amount){
           if((msg.sender==owner)&&(bounty>amount)){
              for(uint j=0;j<amount;j++){
              bots[selling] = Bot(a,"",0,0);
              botOwners[a].push(selling);
              registerCompany(a,data);
              totBOTS++;
              selling++;
              bounty--;
              }
           }
        }


        function botOnSale(uint i,uint c) {if((msg.sender!=bots[i].owner)||(selling<=totBOTS)||(!TOS[msg.sender]))throw;bots[i].cost=c;}

        
        function buyBOTx(uint i,string buyerbill,string buyerInfo,address buyerwallet,uint amount) returns (bool){
         if((amount<1)||(i>15000)||((amount>1)&&((selling+amount+999>totBOTS)||(selling<400))))throw;
        
                address sellsNow;
                address holder;
                uint sell;
                uint currentSeller;
                uint c;
                
                if(!(companyIndex[buyerwallet]>0))registerCompany(buyerwallet,buyerbill);

                if((miner[msg.sender])&&(claimed<2500)){
                currentSeller=cycle[0].currentSeller;
                sellsNow=bots[currentSeller].owner;
                c=lastPrice[0];
                claimed++;
                totBOTS++;
                miner[msg.sender]=false;
                holder=owner;
                sell=selling;
                     //balances[bots[currentSeller].owner]+=msg.value;
                if(!ban[bots[currentSeller].owner]){balances[bots[currentSeller].owner]+=c;}else{balances[owner]+=c;}
                     //balances[bots[currentSeller].owner]+=c;
                     //balances[msg.sender]+=(msg.value-c);
                selling++;
                bots[sell] = Bot(buyerwallet,buyerInfo,0,0);
                }else{

                if(selling>totBOTS){
                if(bots[i].cost==0)throw;
                currentSeller=cycle[0].currentSeller;
                sellsNow=bots[currentSeller].owner;
                holder=bots[i].owner;
                sell=i;
                c=bots[i].cost+lastPrice[0];
                move(i,buyerwallet);
                   		                  
                if(!ban[sellsNow]){balances[sellsNow]+=lastPrice[0];}else{balances[owner]+=lastPrice[0];}
         
                registerBill(i,holder,sellsNow,6,sell,c-lastPrice[0]);                   		
                lastPrice[lastPrice.length++]=c-lastPrice[0];
                   		
                }else{

                c=lastPrice[6]*amount;
                balances[owner]+=msg.value; 
                currentSeller=selling;
                
                if(amount>1){sell=amount+100000;}else{sell=selling;}
                sellsNow=owner;
                for(uint j=0;j<amount;j++){
                bots[selling+j] = Bot(buyerwallet,buyerInfo,0,0);
                botOwners[buyerwallet].push(selling+j);
                }                                                 
                selling+=amount;
                }
                }
                
                if(sellsNow!=owner)botOwners[buyerwallet].push(sell);
                registerBill(currentSeller,sellsNow,buyerwallet,0,sell,c);
                return true;
        }

   

       function move(uint index,address wallet) private returns (uint[]){

        uint[] l=botOwners[bots[index].owner];                                         
        uint ll=l.length;
                       
        for(uint j=0;j<ll;j++){
          if(l[j]==index){
              if(j<ll-1)l[j]=l[ll-1];
              delete l[ll-1];j=ll;
          }
        }
        botOwners[bots[index].owner]=l;
        botOwners[bots[index].owner].length--;
        bots[index].owner=wallet;
        bots[index].cost=0;

        }


        function updateBOTBillingInfo(uint index,string data,address wallet,string info,string buyerbill,uint updatetype) returns(bool){
               
        if((index>totBOTS)||(msg.sender!=bots[index].owner))throw;
         
                    uint t=1;
                    address cs=bots[cycle[1].currentSeller].owner;
                                   
                    if(bots[index].owner!=wallet){

                       if(!(companyIndex[wallet]>0))registerCompany(wallet,data);
                       botOwners[wallet].push(index); 
                       move(index,wallet);
                                            
                    }else{

                         if(updatetype!=1){
                           t=companyIndex[msg.sender]+100;
                           registerCompany(msg.sender,data);
                           totCompanies--;
                         }

                    }

                 if(updatetype!=2)bots[index].info=info;
                 if(!ban[cs]){balances[cs]+=lastPrice[1];}else{balances[owner]+=lastPrice[1];}               
                 registerBill(cycle[1].currentSeller,cs,msg.sender,t,index,lastPrice[1]);    
                     
           return true;
        }

        
        function registerExternalBill(uint bi,address sellsNow,address buyerwallet,uint tipo,uint sell,uint c){
        if(msg.sender!=controller)throw;
        registerBill(bi,sellsNow,buyerwallet,tipo,sell,c);
        }

        function registerBill(uint bi,address sellsNow,address buyerwallet,uint tipo,uint sell,uint c) private{
         
         if((msg.value<c)||(mute)||(!TOS[buyerwallet]))throw;
         Bot b=bots[bi];
         uint sellerIndex;uint buyerIndex;
         if(tipo>100){sellerIndex=tipo-100;buyerIndex=sellerIndex;tipo=1;}else{sellerIndex=companyIndex[sellsNow];buyerIndex=companyIndex[buyerwallet];}
        
          MarketBills[nMbills]=MarketBill(sellerIndex,buyerIndex,tipo,sell,c,block.number);
       
                b.bills[b.nbills+1]=nMbills;
                b.nbills++;
                b.sales[tipo]++;                
                BuyersBills[buyerwallet][BuyersBills[buyerwallet].length++]=nMbills;
                SellersBills[sellsNow][SellersBills[sellsNow].length++]=nMbills;
                nMbills++;
                if(sellsNow!=owner){
                total+=c;
                if(tipo!=6){
                cycle[tipo].sold++;
                cycle[tipo].currentSeller++;
                if((cycle[tipo].currentSeller>totBOTS)||(cycle[tipo].currentSeller>=selling))cycle[tipo].currentSeller=1;}
                }
                if(claimed<=2500)miner[block.coinbase]=true;
        }

   
        function registerCompany(address wal,string data) private{        
        companyWallet[companyWallet.length++]=wal;
        companyIndex[wal]=companies.length;
        companies[companies.length++]=data;
        totCompanies++;
        }
  
        
        function muteMe(bool m){
        if((msg.sender==owner)||(msg.sender==controller))mute=m;
        }
           
     
        function totBOTs() constant returns(uint,uint,uint,uint,uint) {return  (totBOTS,claimed,selling,companies.length,totCompanies); }
      

        function getBotBillingIndex(uint i,uint bi)  constant returns (uint){
        return bots[i].bills[bi];
        }

            
        function getBill(uint i,uint bi)constant returns(uint,uint,uint,uint,uint,uint){
        MarketBill b=MarketBills[i];
        return (b.sellerdata,b.buyerdata,b.product,b.index,b.cost,b.block);
        }
        

        function getNextSellerBOTdata(uint cyc) constant returns (uint,uint,string){return (cycle[cyc].currentSeller,cycle[cyc].sold,companies[companyIndex[bots[cycle[cyc].currentSeller].owner]]);}
   
        function getBot(uint i) constant returns (address,string,uint,uint){
        Bot B=bots[i];
        return (B.owner,B.info,B.cost,B.nbills);
        }

        function getOwnedBot(address own,uint bindex) constant returns(uint){return botOwners[own][bindex];}
      
  
        function getBotStats(uint i,uint j) constant returns (uint){
        Bot B=bots[i];
        return B.sales[j];}


        function getFullCompany(address w,uint i) constant returns (string,uint,bool,uint,uint,string,address){return (companies[companyIndex[w]],botOwners[w].length,miner[w],balances[w],this.balance,companies[i],companyWallet[i]);}


        function getActorBillXdetail(address w,uint i,bool who) constant returns (uint,uint){if(who){return (SellersBills[w][i],SellersBills[w].length);}else{return (BuyersBills[w][i],BuyersBills[w].length);}}

  
        function getHomeadvIndex(uint ind) constant returns (uint){return hadv[ind];}

        function getLastPrice(uint i) constant returns (uint,uint,uint,uint,uint){return (lastPrice[i],lastPrice[lastPrice.length-1],selling,nMbills,total);}

           
        function setController(address a) returns(bool){if(msg.sender!=owner)throw;controller=a;control=ARKController_1_00(a);logs.push(log(owner,"setCensorer",a));
        return true;
        }

        function readLog(uint i)constant returns(address,string,address){log l=logs[i];return(l.admin,l.action,l.addr);}
    

        function censorship(uint i,bool b,bool c) returns(bool){
        if(msg.sender!=controller)throw;
        if(c){coins[i]=Coin({coinOwner : 0x0,data : "Censored",mine : "",coinType : 0,platf: 0,adv : "",block : 0});}else{
        if(b){
        trash[i]=coins[i];
        coins[i]=Coin({coinOwner : 0x0,data : "Censored",mine : "",coinType : 0,platf: 0,adv : "",block : 0});
        }else{
        coins[i]=trash[i];
        }}
        return true;
        }


        function setPrice(uint i,uint j) returns(bool){if(msg.sender!=controller)throw;if(i<7)lastPrice[i]=j; return true;}   
         

        function acceptTOS(address a,bool b)  returns(bool){
        if(b)if(!ban[msg.sender]){TOS[msg.sender]=true;ban[msg.sender]=false;}
        if(msg.sender==controller){TOS[a]=b;if(!b)ban[a]=true;logs.push(log(controller,"setTOS",a)); return true;}
        }


        function getTOS(address a)constant returns(bool) {return TOS[a];}

        
        function owns(address a) constant returns (bool){return botOwners[a].length>0;}


        function getCoin(uint n) constant returns (address,string,uint,uint,string,string) {
        Coin c = coins[n];
        return (c.coinOwner,c.data,c.coinType,c.platf,c.mine,c.adv);   
        }




        function Trash(uint n) constant returns (address,string,uint,uint,string,string) {
        if((msg.sender!=controller)&&(!(getOwnedBot(msg.sender,0)>0)))      
        Coin c = trash[n];   
        return (c.coinOwner,c.data,c.coinType,c.platf,c.mine,c.adv); 
        }

       
        function getCoinStats(uint i) constant returns (uint,uint){
        return (listed[i],coinIndex);   
        }
       

        function withdraw(){
        if(!TOS[msg.sender])throw;
        uint t=balances[msg.sender];
        balances[msg.sender]=0;
        if(!(msg.sender.send(t)))throw;
        }


        function (){throw;}

 }





//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

contract ARKController_1_00 {
    /* Constructor */
    ARK Ark;

    event CoinSent(uint indexed id,address from,string name);

    address owner;
    address Source;

    mapping(address => bool)administrator;
    mapping(address => bool)module;
    mapping(address => string)adminName;

    mapping(uint => bool)restore;

////////////////////////////////////////////////
    log[] logs;

    struct log{
    address admin;
    string what;
    uint id;
    address a;
    }
////////////////////////////////////////////////
    
    function ARKController_1_00() {
    owner=msg.sender;
    }

    function setOwner(address a,string name) {
    if(msg.sender==owner)owner=a;
    }

    function ban(address a) returns(bool){
    return false;
    }

    function setAdministrator(address a,string name,bool yesno) {
    if(isModule(msg.sender)){
    administrator[a]=yesno;
    adminName[a]=name;
    
    if(msg.sender==owner)logs.push(log(msg.sender,"setAdmin",0,a));
    if(msg.sender!=owner)logs.push(log(msg.sender,"moduleSetAdmin",0,a));
    
    }
    }

    function setModule(address a,bool yesno) {
    if(!isModule(msg.sender))throw;
    module[a]=yesno;
    logs.push(log(owner,"setModule",0,a));

    }

    function setPrice(uint i,uint j){
    if((!isModule(msg.sender))||(i>6))throw;
    Ark.setPrice(i,j);
    logs.push(log(msg.sender,"setPrice",i,msg.sender));
    }

    function setTOS(address a,bool b){
    if(!isModule(msg.sender))throw;
    Ark.acceptTOS(a,b);
    }

    
    function setSource(address a) {
    if(msg.sender!=owner)throw;
    Ark=ARK(a);    
    Source=a;
    logs.push(log(msg.sender,"setSource",0,a));
    }

    function setARKowner(address a) {
    if(msg.sender!=owner)throw;
    Ark.initStats("",a,333);
    logs.push(log(msg.sender,"setARKowner",0,0x0));
    }

    function restoreItem(uint i){
    if(isAdmin(msg.sender)||isModule(msg.sender)){
    Ark.censorship(i,false,false);
    logs.push(log(msg.sender,"restore",i,0x0));
    }
    }

    function applyCensorship(uint i){
    if(!isAdmin(msg.sender))throw;
    Ark.censorship(i,true,false);
    logs.push(log(msg.sender,"censor",i,0x0));
    }

    function deleteCoin(uint i){
    if(!isModule(msg.sender))throw;
    Ark.censorship(i,true,true);
    logs.push(log(msg.sender,"censor",i,0x0));
    }

    function registerExternalBill(uint bi,address sellsNow,address buyerwallet,uint tipo,uint sell,uint c) private{
    if(!isModule(msg.sender))throw;
    Ark.registerExternalBill(bi,sellsNow,buyerwallet,tipo,sell,c);
    }

    function pushCoin(uint i,address a,string s) returns(bool){
    if(msg.sender!=Source)throw;
    CoinSent(i,a,s);
    return true;
    }

    function isAdmin(address a)constant returns(bool){
    bool b=false;
    if((a==owner)||(administrator[a]))b=true;
    return b;
    }

    function isModule(address a)constant returns(bool){
    bool b=false;
    if((a==owner)||(module[a]))b=true;
    return b;
    }

    function getAdminName(address a)constant returns(string){
    return adminName[a];
    }

    function getSource()constant returns(address){
    return Source;
    }

    function readLog(uint i)constant returns(string,address,string,uint,address){
    log l=logs[i];
    return(getAdminName(l.admin),l.admin,l.what,l.id,l.a);
    }
    

}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract ARKTagger_1_00 {
    /* Constructor */
    ARK Ark;

    address owner;

    string[] lastTags;
    mapping (string => uint[]) tagged;

////////////////////////////////////////////////
    log[] logs;

    struct log{
    address admin;
    string action;
    address addr;
    }
////////////////////////////////////////////////

    function ARKTagger_1_00() {
    owner=msg.sender;
    }

    function setOwner(address a) {
    if(msg.sender!=owner)throw;
    owner=a;
    logs.push(log(owner,"setOwner",a));
    }

    function setSource(address a) {
    if(msg.sender!=owner)throw;
    Ark=ARK(a);
    logs.push(log(owner,"setSource",a));
    }

    function readLog(uint i)constant returns(address,string,address){
    log l=logs[i];
    return(l.admin,l.action,l.addr);
    }

    function getLastTag(uint i) constant returns(string tag){
    return lastTags[i];
    }

    function addTag(uint i,string tag){tagged[tag][tagged[tag].length++]=i;lastTags[lastTags.length++]=tag;}

    function getTag(string tag,uint i) constant returns(uint,uint){return (tagged[tag][i],tagged[tag].length);}


}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


contract ARK_TROGLOg_1_00 {
    /* TROGLOg is part of ARK Endowment, all the documents are property of the relative ARK BOTs owners */
    ARK Ark;
     
    address owner;

    mapping(uint => string)troglogs;

////////////////////////////////////////////////
    log[] logs;

    struct log{
    address admin;
    string action;
    address addr;
    uint docu;
    }
////////////////////////////////////////////////

    function ARK_TROGLOg_1_00() {
    owner=msg.sender;
    }

    //change TROGLOg controller
    function setOwner(address a) {
    if(msg.sender!=owner)throw;
    owner=a;
    logs.push(log(owner,"setOwner",a,0));
    }

    //point TROGLOg to ARK
    function setSource(address a) {
    if(msg.sender!=owner)throw;
    Ark=ARK(a);
    logs.push(log(owner,"setSource",a,0));
    }

    function readLog(uint i)constant returns(address,string,address,uint){
    log l=logs[i];
    return(l.admin,l.action,l.addr,l.docu);
    }

    
    function submitCoding(string s,uint i){
    var(own,dat,a,b) = Ark.getBot(i);
    if((own==msg.sender)){troglogs[i]=s;logs.push(log(msg.sender,"setDocument",0x0,i));}else{throw;}
    }
        
    

    function getLOg(uint i) constant returns(string){  
    if(!(Ark.getOwnedBot(msg.sender,0)>0))throw;
    return (troglogs[i]);}


}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

contract ARK_VOTER_1_00{

  ARK Ark;
  ARKController_1_00 controller;
  address owner;
  mapping(uint => uint)thresold;
  Vote[] votes;
  uint max;
  uint min;
  Vote[] tv;
  uint[] lastblock;
  uint vmin=30;
  uint vmax=700;
  uint qmin=30;
  uint qmax=700;

        struct Vote {
        uint up;
        uint down;

        mapping (address => bool) voters;
        }

////////////////////////////////////////////////
    log[] logs;

    struct log{
    address admin;
    string action;
    address addr;
    uint i;
    }
////////////////////////////////////////////////

   function ARK_VOTER_1_00(uint a,uint b,uint c,uint d,uint e,uint f){

   owner=msg.sender;
   //tv.push();
   thresold[0]=a; //blackflag quorum
   thresold[1]=b; //censor quorum
   thresold[2]=c; //price vote quorum
   thresold[3]=d; //quorum voting quorum
   thresold[4]=e;
   thresold[5]=f;

   for(uint z=0;z<9;z++){ votes.push(Vote({up:0,down:0})); lastblock.push(1);}
   min=50000000000000000;
   max=2000000000000000000;
   vmin=30;
   vmax=700;
   qmin=30;
   qmax=700;
   }

  

    function setOwner(address a) {
    if(msg.sender!=owner)throw;
    owner=a;
    logs.push(log(owner,"setOwner",a,0));
    }


    function setSource(address a) {
    if(msg.sender!=owner)throw;
    Ark=ARK(a);
    logs.push(log(owner,"setSource",a,0));
    }

    function setController(address a) {
    if(msg.sender!=owner)throw;
    controller=ARKController_1_00(a);
    logs.push(log(owner,"setController",a,0));
    }

    function readLog(uint i)constant returns(address,string,address){
    log l=logs[i];
    return(l.admin,l.action,l.addr);
    }

    function setThresold(uint i,uint j){
    if(msg.sender!=owner)throw;
    thresold[i]=j;

    if(i==0)logs.push(log(owner,"setThresold0",0x0,j));
    if(i==1)logs.push(log(owner,"setThresold1",0x0,j));
    if(i==2)logs.push(log(owner,"setThresold2",0x0,j));
    if(i==3)logs.push(log(owner,"setThresold3",0x0,j));
    if(i==4)logs.push(log(owner,"setThresold4",0x0,j));
    if(i==5)logs.push(log(owner,"setThresold5",0x0,j));

    }

    function setMin(uint i,uint w) {
    if(msg.sender!=owner)throw;
    if(w==0){min=i; logs.push(log(owner,"setMin",0x0,i));}
    if(w==1){vmin=i; logs.push(log(owner,"setVMin",0x0,i));}
    if(w==2){qmin=i; logs.push(log(owner,"setQMin",0x0,i));}
    }

    function setMax(uint i,uint w) {
    if(msg.sender!=owner)throw;
    if(w==0){max=i; logs.push(log(owner,"setMax",0x0,i));}
    if(w==1){vmax=i; logs.push(log(owner,"setVMax",0x0,i));}
    if(w==2){qmax=i; logs.push(log(owner,"setQMax",0x0,i));}
    }

    function setPrice(uint i,uint j) {
    if(msg.sender!=owner)throw;

    if(i==0)logs.push(log(owner,"setPrice0",0x0,j));
    if(i==1)logs.push(log(owner,"setPrice1",0x0,j));
    if(i==2)logs.push(log(owner,"setPrice2",0x0,j));
    if(i==3)logs.push(log(owner,"setPrice3",0x0,j));
    if(i==4)logs.push(log(owner,"setPrice4",0x0,j));
    if(i==5)logs.push(log(owner,"setPrice5",0x0,j));
    controller.setPrice(i,j);

    }
    
    function check(uint i)constant returns(bool){
        if((Ark.getOwnedBot(msg.sender,0)>0)&&(block.number-lastblock[i]>1000)){return true;}else{return false;}   
    }
    
      
    function votePrice(uint x,bool v){
       

        Vote V=votes[x];
        var(a,b,c,d,e) = Ark.getLastPrice(x);

        if(check(x)&&(!(V.voters[msg.sender]))&&(x<=5)&&(a<=max)&&(a>=min)){

        V.voters[msg.sender]=true;

            
        
           
            if(v){V.up++;
                  if(V.up>thresold[2]){
                      
                            uint u=a+(a/10);
                            controller.setPrice(x,u);
                            lastblock[x]=block.number;
                            votes[x]=Vote({up:0,down:0});
                  }
            }else{
                  V.down++;
                  if(V.down>thresold[2]){
                       
                            uint z=a-(a/10);
                            controller.setPrice(x,z);
                            lastblock[x]=block.number;
                            votes[x]=Vote({up:0,down:0});
                      
                  }
            }
           
        
        }else{throw;}
        }


        function voteQuorum(uint x,bool v){

        Vote V=votes[x];

        if((check(x))&&(!(V.voters[msg.sender]))&&(x>5)&&(x<9)&&(thresold[x-6]<vmax)&&(thresold[x-6]>vmin)){

        V.voters[msg.sender]=true;
           
            if(v){V.up++;
                  if(V.up>thresold[3]){                       
                       thresold[x-6]+=thresold[x-6]/10;
                       lastblock[x]=block.number;
                       votes[x]=Vote({up:0,down:0});
                  }
            }else{
                  V.down++;
                  if(V.down>thresold[3]){
                    thresold[x-6]-=thresold[x-6]/10;
                    lastblock[x]=block.number;
                    votes[x]=Vote({up:0,down:0});
                  }
            }
            
        
        }else{throw;}
        }



        function voteSuperQuorum(uint x,bool v){
     
        Vote V=votes[x];

        if((check(x))&&(!(V.voters[msg.sender]))&&(x>8)&&(thresold[3]<qmax)&&(thresold[3]>qmin)){

        V.voters[msg.sender]=true;
           
            if(v){V.up++;
                  if(V.up>thresold[3]){                       
                  thresold[3]+=thresold[3]/10;
                  lastblock[x]=block.number;
                  votes[x]=Vote({up:0,down:0});   
                  }
            }else{
                  V.down++;
                  if(V.down>thresold[3]){
                  thresold[3]-=thresold[3]/10;
                  lastblock[x]=block.number;
                  votes[x]=Vote({up:0,down:0});  
                  }
            }
            
        
        }else{throw;}
        }


        function getVotes(uint x) constant returns(uint,uint,bool){
        Vote V=votes[x];
        return (V.up,V.down,V.voters[msg.sender]);
        }

        function getThresold(uint i)constant returns(uint){return thresold[i];}

        function getMinMax()constant returns(uint,uint,uint,uint,uint,uint){return (min,max,vmin,vmax,qmin,qmax);}
}


//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

contract ARK_FLAGGER_1_00{

  ARK Ark;
  ARKController_1_00 ARKcontroller;
  address owner;
  ARK_VOTER_1_00 ARKvoter;

  struct BlackFlag{
  uint blackflagrequest;
  uint blackflags;
  }

    mapping(uint => BlackFlag) blackflags;


    mapping(uint => Censorship)censoring;
    struct Censorship{mapping(address => bool) censor;}

   uint[] thresold;

    
  
////////////////////////////////////////////////
    log[] logs;

    struct log{
    address admin;
    string action;
    address addr;
    uint i;
    }
////////////////////////////////////////////////

   function ARK_FLAGGER_1_00(){

   owner=msg.sender;
   
   thresold.push(3);
   thresold.push(3);
   thresold.push(3);
   thresold.push(3);
   thresold.push(3);
   thresold.push(3);
   }

  

    function setOwner(address a) {
    if(msg.sender!=owner)throw;
    owner=a;
    logs.push(log(owner,"setOwner",a,0));
    }

    function setController(address a) {
    if(msg.sender!=owner)throw;
    ARKcontroller=ARKController_1_00(a);
    logs.push(log(owner,"setController",a,0));
    }

    function setVoter(address a) {
    if(msg.sender!=owner)throw;
    ARKvoter=ARK_VOTER_1_00(a);
    logs.push(log(owner,"setVoter",a,0));
    }


    function setSource(address a) {
    if(msg.sender!=owner)throw;
    Ark=ARK(a);
    logs.push(log(owner,"setSource",a,0));
    }

    function readLog(uint i)constant returns(address,string,address,uint){
    log l=logs[i];
    return(l.admin,l.action,l.addr,l.i);
    }

    function check()constant returns(bool){
        var b=false;
        if(Ark.getOwnedBot(msg.sender,0)>0)b=true;
        return b;
       
    }

        function setBlackflag(uint i,bool b){if(msg.sender!=owner)throw;if(b){blackflags[i].blackflags++;}else{blackflags[i].blackflags--;}}




        function setBlackFlagRequest(uint index,uint typ){
 
        var (x,y) = Ark.getCoinStats(0);
        BlackFlag c = blackflags[index];
        
        if((index<=y)&&(check())&&((typ==1)||(typ==1001)||(typ==10001))&&(!censoring[index].censor[msg.sender])){
        if(c.blackflagrequest==0){censoring[index]=Censorship(); c.blackflagrequest=typ;}
        logs.push(log(msg.sender,"requestBlackFlag",0x0,index));
        censoring[index].censor[msg.sender]=true;      
        }else{throw;}
        }




       function getBlackflag(uint index,address a) constant returns(bool,uint,uint){
        BlackFlag c = blackflags[index];
        return (censoring[index].censor[a],c.blackflagrequest,c.blackflags);
        }

        function confirmBlackFlag(uint index,bool confirm){
        BlackFlag c = blackflags[index];
        uint t=c.blackflagrequest;

        
        if((check())&&(t>=1)&&(!censoring[index].censor[msg.sender])){
            if(confirm){
        
               if((t<(1+thresold[0]))||((1000<t)&&(t<(1001+thresold[0])))||((t>10000)&&(t<(10000+thresold[1])))){
                  c.blackflagrequest++;
                  //censoring[index].blackflagasker=msg.sender;
                  censoring[index].censor[msg.sender]=true;
               }else{   
                   if(t>=10000+thresold[1]){
                    ARKcontroller.applyCensorship(index);
                    censoring[index]=Censorship();
                   }else{                      
                    c.blackflags++;     
                   } 
                   c.blackflagrequest=0;
               }      
            }else{if(t>10000){c.blackflagrequest=0;logs.push(log(msg.sender,"nullCensorshipRequest",0x0,index));}else{c.blackflagrequest--;}}
        }else{throw;}
        }


        function setThresold(uint i,uint j){
        if(msg.sender!=owner)throw;
        thresold[i]=j;
 
        if(i==0)logs.push(log(owner,"setThresold0",0x0,j));
        if(i==1)logs.push(log(owner,"setThresold1",0x0,j));
        if(i==2)logs.push(log(owner,"setThresold2",0x0,j));
        if(i==3)logs.push(log(owner,"setThresold3",0x0,j));
        if(i==4)logs.push(log(owner,"setThresold4",0x0,j));
        if(i==5)logs.push(log(owner,"setThresold5",0x0,j));
        }

        function updateThresold(uint i){
        thresold[i]=ARKvoter.getThresold(i);
        //uint u=ARKvoter.getThresold(i);
        if(i==0)logs.push(log(owner,"updateThresold0",0x0,i));
        if(i==1)logs.push(log(owner,"updateThresold1",0x0,i));
        if(i==2)logs.push(log(owner,"updateThresold2",0x0,i));
        if(i==3)logs.push(log(owner,"updateThresold3",0x0,i));
        if(i==4)logs.push(log(owner,"updateThresold4",0x0,i));
        if(i==5)logs.push(log(owner,"updateThresold5",0x0,i));
        }

        function getThresold()constant returns(uint,uint,uint,uint,uint,uint){
        return (thresold[0],thresold[1],thresold[2],thresold[3],thresold[4],thresold[5]);
        }


}