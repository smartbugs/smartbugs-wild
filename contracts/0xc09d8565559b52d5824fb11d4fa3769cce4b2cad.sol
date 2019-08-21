pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXV_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXV_I_883		"	;
		string	public		symbol =	"	RUSS_PFXXV_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		596441802286079000000000000					;	
										
		event Transfer(address indexed from, address indexed to, uint256 value);								
										
		function SimpleERC20Token() public {								
			balanceOf[msg.sender] = totalSupply;							
			emit Transfer(address(0), msg.sender, totalSupply);							
		}								
										
		function transfer(address to, uint256 value) public returns (bool success) {								
			require(balanceOf[msg.sender] >= value);							
										
			balanceOf[msg.sender] -= value;  // deduct from sender's balance							
			balanceOf[to] += value;          // add to recipient's balance							
			emit Transfer(msg.sender, to, value);							
			return true;							
		}								
										
		event Approval(address indexed owner, address indexed spender, uint256 value);								
										
		mapping(address => mapping(address => uint256)) public allowance;								
										
		function approve(address spender, uint256 value)								
			public							
			returns (bool success)							
		{								
			allowance[msg.sender][spender] = value;							
			emit Approval(msg.sender, spender, value);							
			return true;							
		}								
										
		function transferFrom(address from, address to, uint256 value)								
			public							
			returns (bool success)							
		{								
			require(value <= balanceOf[from]);							
			require(value <= allowance[from][msg.sender]);							
										
			balanceOf[from] -= value;							
			balanceOf[to] += value;							
			allowance[from][msg.sender] -= value;							
			emit Transfer(from, to, value);							
			return true;							
		}								
//	}									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d'émission - Lignes 1 à 10									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ]									
	//         [ Adresse exportée ]									
	//         [ Unité ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     < RUSS_PFXXV_I_metadata_line_1_____GAZPROM_20211101 >									
	//        < 3f7B3cky9m8eExCpw6KPV8kEExeeX7UhQa542UKSXbQ98fz16ApvJm23kN620jsJ >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000015866682.586014000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001835EC >									
	//     < RUSS_PFXXV_I_metadata_line_2_____PROM_DAO_20211101 >									
	//        < w2iS8Co6V46xR6hk6M369BSr19npF0uhc7X998l7cH22Dy5jEeaTcKk1Groz83x9 >									
	//        <  u =="0.000000000000000001" : ] 000000015866682.586014000000000000 ; 000000030248296.129152100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001835EC2E27BE >									
	//     < RUSS_PFXXV_I_metadata_line_3_____PROM_DAOPI_20211101 >									
	//        < 2pO3ao29WcRe8T9g7Qgew92bRxfqJkw93Vdy6ihv5h7e6zPwDG5WURS9J1XVk9SD >									
	//        <  u =="0.000000000000000001" : ] 000000030248296.129152100000000000 ; 000000045560327.316280800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002E27BE458501 >									
	//     < RUSS_PFXXV_I_metadata_line_4_____PROM_DAC_20211101 >									
	//        < lJ2DuQgf1rTwt1D4FMWUFuZsw2ULlN80k2CxNSqWGqep7iyh2y0hhDSqn47kkBY5 >									
	//        <  u =="0.000000000000000001" : ] 000000045560327.316280800000000000 ; 000000059725682.690168400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004585015B2258 >									
	//     < RUSS_PFXXV_I_metadata_line_5_____PROM_BIMI_20211101 >									
	//        < w6XI8S8HO86cUN4TFBE804Z4tzqoK6lT6927F1iYRrJcIJBgtcqTG1dxXG839twa >									
	//        <  u =="0.000000000000000001" : ] 000000059725682.690168400000000000 ; 000000074195533.011233800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005B22587136A1 >									
	//     < RUSS_PFXXV_I_metadata_line_6_____GAZPROMNEFT_20211101 >									
	//        < 8Uk9G26Gx4A7HPKDROQHlP6q8B5ilvE3jsN40p165q5dV2d472aAm8TvlcnC4Z5z >									
	//        <  u =="0.000000000000000001" : ] 000000074195533.011233800000000000 ; 000000088527811.138290700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007136A187152D >									
	//     < RUSS_PFXXV_I_metadata_line_7_____GAZPROMBANK_BD_20211101 >									
	//        < sXmaLOwpJ1745S1k55houl7VY51vwgH76GkJ9B8HBUcmtDz4hvsXIr5265cKE58P >									
	//        <  u =="0.000000000000000001" : ] 000000088527811.138290700000000000 ; 000000104660723.109786000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000087152D9FB318 >									
	//     < RUSS_PFXXV_I_metadata_line_8_____MEZHEREGIONGAZ_20211101 >									
	//        < resX90X562nmneG93myW976eV1b35ZDa7u83542b07p1YGTv3pbw1V57D2ubDSNe >									
	//        <  u =="0.000000000000000001" : ] 000000104660723.109786000000000000 ; 000000118816683.247653000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009FB318B54CC4 >									
	//     < RUSS_PFXXV_I_metadata_line_9_____SALAVATNEFTEORGSINTEZ_20211101 >									
	//        < Fxdhp3cOTkCtYDk41kDj4Btlq658apOu9Fu61oU4UIOMEC9k7v2pcf8E0SGflcoI >									
	//        <  u =="0.000000000000000001" : ] 000000118816683.247653000000000000 ; 000000134359340.063529000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B54CC4CD041E >									
	//     < RUSS_PFXXV_I_metadata_line_10_____SAKHALIN_ENERGY_20211101 >									
	//        < numzUBR9Jsqz56hz7QbRbUHt6h4X03tC51Z7Z45TUZl6YxJAW75PDd6NfJ40H48S >									
	//        <  u =="0.000000000000000001" : ] 000000134359340.063529000000000000 ; 000000147654241.709127000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CD041EE14D70 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d'émission - Lignes 11 à 20									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ]									
	//         [ Adresse exportée ]									
	//         [ Unité ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     < RUSS_PFXXV_I_metadata_line_11_____NORDSTREAM_AG_20211101 >									
	//        < 5QzKR7DXs0cs937pSdwz4i6lCWFZn0u1Xb1Co6in7Ycvy7FAkwy9aL8J00K2Ew5n >									
	//        <  u =="0.000000000000000001" : ] 000000147654241.709127000000000000 ; 000000160778473.378789000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E14D70F55417 >									
	//     < RUSS_PFXXV_I_metadata_line_12_____NORDSTREAM_DAO_20211101 >									
	//        < 5iD0n3B2A13jbPv1680TnNyWPeRtDzsp9Z44P628Ukkpm8z19Vm9NrnrCFGy30qt >									
	//        <  u =="0.000000000000000001" : ] 000000160778473.378789000000000000 ; 000000177731301.909452000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F5541710F324A >									
	//     < RUSS_PFXXV_I_metadata_line_13_____NORDSTREAM_DAOPI_20211101 >									
	//        < 4RrKWDOZ4W7IWGLS1ao15CoD84upls7GgwYwfg51SB7y007IpZxv125pvZ3nE5ZA >									
	//        <  u =="0.000000000000000001" : ] 000000177731301.909452000000000000 ; 000000190974195.753674000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010F324A123674C >									
	//     < RUSS_PFXXV_I_metadata_line_14_____NORDSTREAM_DAC_20211101 >									
	//        < jzGgJsTd7T4Jq6ceDse3cqtK07e0m69vVFakG22iH8uoFto17uRWxrnP2W3o2U4i >									
	//        <  u =="0.000000000000000001" : ] 000000190974195.753674000000000000 ; 000000204609397.580780000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000123674C138358C >									
	//     < RUSS_PFXXV_I_metadata_line_15_____NORDSTREAM_BIMI_20211101 >									
	//        < tjVJHWd324BM6NsRnV2MBUcg1wAuS04aP3f9hauSl3l3l4WRLIYa8i5MVk7JXu99 >									
	//        <  u =="0.000000000000000001" : ] 000000204609397.580780000000000000 ; 000000221078434.254257000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000138358C15156C3 >									
	//     < RUSS_PFXXV_I_metadata_line_16_____GASCAP_ORG_20211101 >									
	//        < 379m0jbXgC01vu8597t4nvpHe54cl05XsSj34kzOLCgNQ7Z9FUdZv9smV4M2QDVO >									
	//        <  u =="0.000000000000000001" : ] 000000221078434.254257000000000000 ; 000000234532830.528585000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015156C3165DE63 >									
	//     < RUSS_PFXXV_I_metadata_line_17_____GASCAP_DAO_20211101 >									
	//        < YJ4z520HDLqOa2KDUCV21lGryYZ973IqeuEVrxX00O30ZWjZ35QWeT2wnQA15jEF >									
	//        <  u =="0.000000000000000001" : ] 000000234532830.528585000000000000 ; 000000248181143.917963000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000165DE6317AB1C2 >									
	//     < RUSS_PFXXV_I_metadata_line_18_____GASCAP_DAOPI_20211101 >									
	//        < 997u2shm37V0DfCWL9HDB4Upmb6bhTvmKA3atx663y6TblbCG4A447QwYB80nl7E >									
	//        <  u =="0.000000000000000001" : ] 000000248181143.917963000000000000 ; 000000264386611.241142000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017AB1C21936C05 >									
	//     < RUSS_PFXXV_I_metadata_line_19_____GASCAP_DAC_20211101 >									
	//        < 9Niy5Vq783k3Bt31cSfSZ6xRJom19vm3yNBbIyj3MiiXIO3M2YDwLYyoH2GvQ6dZ >									
	//        <  u =="0.000000000000000001" : ] 000000264386611.241142000000000000 ; 000000280656308.245198000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001936C051AC3F5F >									
	//     < RUSS_PFXXV_I_metadata_line_20_____GASCAP_BIMI_20211101 >									
	//        < Z9o7qvxUv8Rcp6FpGab0LxaAQSOv1DMR6DR6QrFsDj6DNa7z042gLvVB84trQ2Fx >									
	//        <  u =="0.000000000000000001" : ] 000000280656308.245198000000000000 ; 000000296439994.705233000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AC3F5F1C454DF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d'émission - Lignes 21 à 30									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ]									
	//         [ Adresse exportée ]									
	//         [ Unité ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     < RUSS_PFXXV_I_metadata_line_21_____GAZ_CAPITAL_SA_20211101 >									
	//        < MoYXwMt3G5mP9O66Q5Fa8pSKkvyfU5B3uMNRU8LDf5A7o7Ad47yj96i2183Wcr9V >									
	//        <  u =="0.000000000000000001" : ] 000000296439994.705233000000000000 ; 000000310901388.255898000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C454DF1DA65DB >									
	//     < RUSS_PFXXV_I_metadata_line_22_____BELTRANSGAZ_20211101 >									
	//        < R9M7cC3crBYSgyHB0eg94a762olCcq6HGCGYu0NY1Qf1P2yu7Q18wKu0wlCHNBUq >									
	//        <  u =="0.000000000000000001" : ] 000000310901388.255898000000000000 ; 000000324056512.361406000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DA65DB1EE7893 >									
	//     < RUSS_PFXXV_I_metadata_line_23_____OVERGAS_20211101 >									
	//        < 8hDbHWab6Cbl2PCC26L8zAJRBDdtArJcAz9fwDKcj8a1QVUN8LVsn9JcL1DxavU8 >									
	//        <  u =="0.000000000000000001" : ] 000000324056512.361406000000000000 ; 000000338077453.467057000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EE7893203DD81 >									
	//     < RUSS_PFXXV_I_metadata_line_24_____GAZPROM_MARKETING_TRADING_20211101 >									
	//        < z27BIFvaLB3fBw7uTSD44QEpM3SLmRiB2fNU8x33k8qqMR567ckO5q9k5Gj7SJFA >									
	//        <  u =="0.000000000000000001" : ] 000000338077453.467057000000000000 ; 000000351134144.538491000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000203DD81217C9C6 >									
	//     < RUSS_PFXXV_I_metadata_line_25_____ROSUKRENERGO_20211101 >									
	//        < HmfNhZW3cR4S51U7o72iz09BAPR10mFzspmU89gAqS1ag1bx25y0VoN581DoPezQ >									
	//        <  u =="0.000000000000000001" : ] 000000351134144.538491000000000000 ; 000000365798833.893935000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000217C9C622E2A2B >									
	//     < RUSS_PFXXV_I_metadata_line_26_____TRANSGAZ_VOLGORAD_20211101 >									
	//        < 6875oVCq5Z7HrIJVWR52D7lAq4Ly7985kUW7vmam4MYq4S51yPWFIXMBzOBdaBQ8 >									
	//        <  u =="0.000000000000000001" : ] 000000365798833.893935000000000000 ; 000000380046929.282338000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022E2A2B243E7D5 >									
	//     < RUSS_PFXXV_I_metadata_line_27_____SPACE_SYSTEMS_20211101 >									
	//        < yYImal31X3HeJv7y2Fyk9jbxo3H4udS4A15DIM742M84i2O73f2BBg8Phk7w4mML >									
	//        <  u =="0.000000000000000001" : ] 000000380046929.282338000000000000 ; 000000396585482.568826000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000243E7D525D2434 >									
	//     < RUSS_PFXXV_I_metadata_line_28_____MOLDOVAGAZ_20211101 >									
	//        < L43pQ964JTHx7ku57G11sCJ4Gz7ps2R0fgGUrZ7UuObf32fuUBEh6F9q91MP73cd >									
	//        <  u =="0.000000000000000001" : ] 000000396585482.568826000000000000 ; 000000411862810.071007000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025D243427473E9 >									
	//     < RUSS_PFXXV_I_metadata_line_29_____VOSTOKGAZPROM_20211101 >									
	//        < c1GF6l3ffmM6I8os8I12cyTvxM623zhvm26S63Pw9Z9RVW08r7WjB56ELc9i4Hf4 >									
	//        <  u =="0.000000000000000001" : ] 000000411862810.071007000000000000 ; 000000429028604.629720000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027473E928EA54C >									
	//     < RUSS_PFXXV_I_metadata_line_30_____GAZPROM_UK_20211101 >									
	//        < VVAm5eo2Q59uSODl8X01ay351021gRtwN3oOTnQ70H04Wc9203tbvwT2D98e7w26 >									
	//        <  u =="0.000000000000000001" : ] 000000429028604.629720000000000000 ; 000000445003646.144161000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028EA54C2A7058D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	// Programme d'émission - Lignes 31 à 40									
	//									
	//									
	//									
	//									
	//     [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ]									
	//         [ Adresse exportée ]									
	//         [ Unité ; Limite basse ; Limite haute ]									
	//         [ Hex ]									
	//									
	//									
	//									
	//     < RUSS_PFXXV_I_metadata_line_31_____SOUTHSTREAM_AG_20211101 >									
	//        < 0pR72o3f4z39RwS4q66qu8Yu5X0i1B14K8qwcy1oL75638HL8DZhv7DQR8U7L1mP >									
	//        <  u =="0.000000000000000001" : ] 000000445003646.144161000000000000 ; 000000459433497.989266000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A7058D2BD0A36 >									
	//     < RUSS_PFXXV_I_metadata_line_32_____SOUTHSTREAM_DAO_20211101 >									
	//        < mRUf159YkpHx9QUKgB9I9tEiz1aRzUnxROv7IVEj7ACbwz0B1TvrMgc4u0A1n5E2 >									
	//        <  u =="0.000000000000000001" : ] 000000459433497.989266000000000000 ; 000000474084457.718789000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BD0A362D3653E >									
	//     < RUSS_PFXXV_I_metadata_line_33_____SOUTHSTREAM_DAOPI_20211101 >									
	//        < 4XA3ttk57Dq4jT445wW6QKnc6WPmqPW9577r7u61K7Q51AIOIO2h248Zo2fnebpk >									
	//        <  u =="0.000000000000000001" : ] 000000474084457.718789000000000000 ; 000000490511003.489901000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D3653E2EC75DC >									
	//     < RUSS_PFXXV_I_metadata_line_34_____SOUTHSTREAM_DAC_20211101 >									
	//        < 6uhxd7v3N2Br34G7L1jkR98MK2W3S7WKwAr8TMCJTM93lxMUl1iwwR2sY1RNGj3y >									
	//        <  u =="0.000000000000000001" : ] 000000490511003.489901000000000000 ; 000000504674100.374332000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EC75DC3021252 >									
	//     < RUSS_PFXXV_I_metadata_line_35_____SOUTHSTREAM_BIMI_20211101 >									
	//        < qFlUf45B1frE6Hts8LmzAhK2zh1lpskd0a4ZQziIogiG56cN7C2u6wF40ZCWx616 >									
	//        <  u =="0.000000000000000001" : ] 000000504674100.374332000000000000 ; 000000519632633.076998000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003021252318E57F >									
	//     < RUSS_PFXXV_I_metadata_line_36_____GAZPROM_ARMENIA_20211101 >									
	//        < 5f8869j47dJ93xD1Th6K1BL2RyMBYyYZun3WVFWi9nZf36p1u0U968n7it9SwSgm >									
	//        <  u =="0.000000000000000001" : ] 000000519632633.076998000000000000 ; 000000535829398.464982000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000318E57F3319C5C >									
	//     < RUSS_PFXXV_I_metadata_line_37_____CHORNOMORNAFTOGAZ_20211101 >									
	//        < 947Xc8V5iO1SJN2tZ52N5b9q4L69jV32ClS1BKey3pr4wR7DO0e0AZ355LljOHM9 >									
	//        <  u =="0.000000000000000001" : ] 000000535829398.464982000000000000 ; 000000552551938.171334000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003319C5C34B209A >									
	//     < RUSS_PFXXV_I_metadata_line_38_____SHTOKMAN_DEV_AG_20211101 >									
	//        < Y1p18363zjs5Cy5eX5nIF20uy8oxhgG3LtxlV82z6SV0LuAKzc74SuVRH19U9UH8 >									
	//        <  u =="0.000000000000000001" : ] 000000552551938.171334000000000000 ; 000000568829181.331705000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034B209A363F6E6 >									
	//     < RUSS_PFXXV_I_metadata_line_39_____VEMEX_20211101 >									
	//        < RHKIx4be41ZIN633m2kW6g3bd1G5ym4pYb8M16JmnN5uLNlDxLcq2lQc31jmk5MB >									
	//        <  u =="0.000000000000000001" : ] 000000568829181.331705000000000000 ; 000000582056811.082134000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000363F6E637825F1 >									
	//     < RUSS_PFXXV_I_metadata_line_40_____BOSPHORUS_GAZ_20211101 >									
	//        < 9Oso6524T34h6qZ2Sa4Thd8djv3sqcX1QbIY8Cw85sXuet5hayX4X2p4VMm2p2By >									
	//        <  u =="0.000000000000000001" : ] 000000582056811.082134000000000000 ; 000000596441802.286079000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037825F138E1914 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}