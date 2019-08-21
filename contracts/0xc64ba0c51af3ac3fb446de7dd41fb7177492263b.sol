pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXIII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXIII_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXIII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1006586027158770000000000000					;	
										
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
	//     < RUSS_PFXXIII_III_metadata_line_1_____INGOSSTRAKH_20251101 >									
	//        < mh058Fy8277SfZncLhEHNU9rEm0jh53JDU2FgXF6qcjbX8wG16DHOvt0m6B1vBE4 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000019611777.094009300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001DECDA >									
	//     < RUSS_PFXXIII_III_metadata_line_2_____ROSGOSSTRAKH_20251101 >									
	//        < r81g31mKXonIGgq472O4Au115s2YD4HW5YV93hXb34zCZ6XEfcQj4IQ7ht739p0o >									
	//        <  u =="0.000000000000000001" : ] 000000019611777.094009300000000000 ; 000000046343880.317292700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001DECDA46B714 >									
	//     < RUSS_PFXXIII_III_metadata_line_3_____TINKOFF_INSURANCE_20251101 >									
	//        < BrHcjclActi415rU2h2d9Oc0L05NuEe5SeU4XgQap2228uSCv7I3PE86khhBOR0w >									
	//        <  u =="0.000000000000000001" : ] 000000046343880.317292700000000000 ; 000000072496648.616534500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000046B7146E9F01 >									
	//     < RUSS_PFXXIII_III_metadata_line_4_____MOSCOW_EXCHANGE_20251101 >									
	//        < NHfAlC40z6pDyKNOx8e4B7F83s176g5O6mL6122OlO63uEvjy33K2eF13yoG12Nb >									
	//        <  u =="0.000000000000000001" : ] 000000072496648.616534500000000000 ; 000000091746553.868617900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006E9F018BFE7F >									
	//     < RUSS_PFXXIII_III_metadata_line_5_____YANDEX_20251101 >									
	//        < 73nD1jva88iLmlV5MA968784LbZHkQRctnh06YBXKwnsbk6a1317P4lPN2FPcI86 >									
	//        <  u =="0.000000000000000001" : ] 000000091746553.868617900000000000 ; 000000114836093.271344000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008BFE7FAF39D9 >									
	//     < RUSS_PFXXIII_III_metadata_line_6_____UNIPRO_20251101 >									
	//        < yl504r0Flo2moHUmAIMq130ps052CP234Jx60Y38FtKYo72UKxi1M4Nmbdbc0z26 >									
	//        <  u =="0.000000000000000001" : ] 000000114836093.271344000000000000 ; 000000145076016.480153000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AF39D9DD5E52 >									
	//     < RUSS_PFXXIII_III_metadata_line_7_____DIXY_20251101 >									
	//        < v4Q578V0SQ48TU2xoyN2WcQMyS185Bj2TT0gqo0CcdepYCZo2hw11a9YkYE955c3 >									
	//        <  u =="0.000000000000000001" : ] 000000145076016.480153000000000000 ; 000000168176819.241449000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000DD5E521009E12 >									
	//     < RUSS_PFXXIII_III_metadata_line_8_____MECHEL_20251101 >									
	//        < 9cE0wv6WTF99kltMtbU0JZOCbnK0W97yWPSf6uBOdONCS1eDDM5fvBGAZHb3Lgd6 >									
	//        <  u =="0.000000000000000001" : ] 000000168176819.241449000000000000 ; 000000199874890.429468000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001009E12130FC21 >									
	//     < RUSS_PFXXIII_III_metadata_line_9_____VSMPO_AVISMA_20251101 >									
	//        < 35r0gjaRqJNClOL6YMIim9dA9b7x3f59K1GoU01aYM6G5j73sxp2A9ehR2BkLnG8 >									
	//        <  u =="0.000000000000000001" : ] 000000199874890.429468000000000000 ; 000000226450162.836307000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000130FC211598918 >									
	//     < RUSS_PFXXIII_III_metadata_line_10_____AGRIUM_20251101 >									
	//        < 5QAI356GIDMj11xgnaHGzSz9t21egFDhh4DDSgYdJNTy1T0whJm6T7dAaQQB7Wyu >									
	//        <  u =="0.000000000000000001" : ] 000000226450162.836307000000000000 ; 000000244808536.325588000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015989181758C56 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIII_III_metadata_line_11_____ONEXIM_20251101 >									
	//        < Ee2vJ0YWfF44CtH8Fcj0m5s65H5zhGgc7mePvKg03f5iPVJV4Jn4kaA6BgpCI5Wz >									
	//        <  u =="0.000000000000000001" : ] 000000244808536.325588000000000000 ; 000000263390306.281952000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001758C56191E6D7 >									
	//     < RUSS_PFXXIII_III_metadata_line_12_____SILOVYE_MACHINY_20251101 >									
	//        < 1aUs9B46o73B2CTqsgtBdcGu9gomX6S7IdpS6OB4rYc9JdJ926GGbntEhb95UW68 >									
	//        <  u =="0.000000000000000001" : ] 000000263390306.281952000000000000 ; 000000294858735.538297000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000191E6D71C1EB32 >									
	//     < RUSS_PFXXIII_III_metadata_line_13_____RPC_UWC_20251101 >									
	//        < T9BpXTLjj9c6YD5nXdyZMAK4OkXfDjNx7N0h9K6no0FdqnjqW65R694qMBPOTEd6 >									
	//        <  u =="0.000000000000000001" : ] 000000294858735.538297000000000000 ; 000000327844771.334790000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C1EB321F4405D >									
	//     < RUSS_PFXXIII_III_metadata_line_14_____INTERROS_20251101 >									
	//        < zt215r71o7Tg1k9j730HIVFa4KJG7A6JKLdJlIHF3eV47160309b32O041D6mmk6 >									
	//        <  u =="0.000000000000000001" : ] 000000327844771.334790000000000000 ; 000000356445699.837770000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F4405D21FE49A >									
	//     < RUSS_PFXXIII_III_metadata_line_15_____PROF_MEDIA_20251101 >									
	//        < oQKrdS1NZau7oSr67aI45meBK5025f2EMUShTlgHVO07708QMz2pr49LOVPfbBO6 >									
	//        <  u =="0.000000000000000001" : ] 000000356445699.837770000000000000 ; 000000389424590.559964000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021FE49A25236FB >									
	//     < RUSS_PFXXIII_III_metadata_line_16_____ACRON_GROUP_20251101 >									
	//        < 1Fk5klfrigg8Gb7k1FT70pcurdK3Cq1PXACY59C376v089FDmKl9nZkpG3E3SQYJ >									
	//        <  u =="0.000000000000000001" : ] 000000389424590.559964000000000000 ; 000000417885768.538147000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025236FB27DA4A1 >									
	//     < RUSS_PFXXIII_III_metadata_line_17_____RASSVET_20251101 >									
	//        < Z08Ue1scTh874lWK7WZ1SyS2OVBTn1QW3JBKbW13K27sAXtgNg68GQmQMSDXAvcm >									
	//        <  u =="0.000000000000000001" : ] 000000417885768.538147000000000000 ; 000000452728030.955724000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027DA4A12B2CEE3 >									
	//     < RUSS_PFXXIII_III_metadata_line_18_____LUZHSKIY_KOMBIKORMOVIY_ZAVOD_20251101 >									
	//        < OnU2z7rp19ILwEUK1Ma927v949X3MUpG1V4Nk7QYgchQ5aBE6uX4tJ9mAfDLmDrY >									
	//        <  u =="0.000000000000000001" : ] 000000452728030.955724000000000000 ; 000000478487317.333100000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B2CEE32DA1D1C >									
	//     < RUSS_PFXXIII_III_metadata_line_19_____LSR GROUP_20251101 >									
	//        < H3B2l8Tck6x08idcyU8kbW9pH63i9uv8A1t8KxYuG1STrkKR2Hf9R0e8r0HMKK6F >									
	//        <  u =="0.000000000000000001" : ] 000000478487317.333100000000000000 ; 000000504084353.701002000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DA1D1C3012BF3 >									
	//     < RUSS_PFXXIII_III_metadata_line_20_____MMK_20251101 >									
	//        < 2bS9Fl63MIG000vXb85qoZW6QZw69etkFM1009H881796C1r8GpH5bzKTQpgnZ41 >									
	//        <  u =="0.000000000000000001" : ] 000000504084353.701002000000000000 ; 000000524766623.322086000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003012BF3320BAF6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIII_III_metadata_line_21_____MOESK_20251101 >									
	//        < OdRzAvwO44Z12h96xT4KT2RRV6vWc3dZ5Tf2C1y907K31ivQecTBA5xQUV3ODJ32 >									
	//        <  u =="0.000000000000000001" : ] 000000524766623.322086000000000000 ; 000000549615656.027289000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000320BAF6346A59E >									
	//     < RUSS_PFXXIII_III_metadata_line_22_____MOSTOTREST_20251101 >									
	//        < UCM1l4m78imY65vo94Sv9IEvF4C2R0YpLV33O0W7H8r7b2Yxi35t7jubQnG3i28F >									
	//        <  u =="0.000000000000000001" : ] 000000549615656.027289000000000000 ; 000000568729006.169307000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000346A59E363CFC5 >									
	//     < RUSS_PFXXIII_III_metadata_line_23_____MVIDEO_20251101 >									
	//        < x753W5iS0qWsW62r4NKVwot02KfLK9YiN6I503y0bs6W38g9XOUnJ7WrkOT20yei >									
	//        <  u =="0.000000000000000001" : ] 000000568729006.169307000000000000 ; 000000590206243.786195000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000363CFC53849550 >									
	//     < RUSS_PFXXIII_III_metadata_line_24_____NCSP_20251101 >									
	//        < 1UODwBgX09AFwx0fvScFUmCI9rmKKA3s8g38LMf20NDBij2z6Qtx6V950vFP9ebT >									
	//        <  u =="0.000000000000000001" : ] 000000590206243.786195000000000000 ; 000000612715681.251825000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038495503A6EE10 >									
	//     < RUSS_PFXXIII_III_metadata_line_25_____MOSAIC_COMPANY_20251101 >									
	//        < 9aWksI2Eic0PA1326528agkSc2DH2jr1HR1oG4ekT6PVoN4Rk88aVtD6gvaM33B9 >									
	//        <  u =="0.000000000000000001" : ] 000000612715681.251825000000000000 ; 000000635800835.357967000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A6EE103CA27B4 >									
	//     < RUSS_PFXXIII_III_metadata_line_26_____METALLOINVEST_20251101 >									
	//        < AKe7HWuRlb4g6VE1DqL7m1jy47zc5EMt8D9NDU00fH8TP814u2I5l2a02WP6wytA >									
	//        <  u =="0.000000000000000001" : ] 000000635800835.357967000000000000 ; 000000655315492.251635000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CA27B43E7EE9D >									
	//     < RUSS_PFXXIII_III_metadata_line_27_____TOGLIATTIAZOT_20251101 >									
	//        < oUZ31HIr8gaT9i8d2jiBkdVl6V1h7zRK83m0O1STciWlI1WBJ6m8Dh1x54iLLT58 >									
	//        <  u =="0.000000000000000001" : ] 000000655315492.251635000000000000 ; 000000680697272.249041000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E7EE9D40EA95F >									
	//     < RUSS_PFXXIII_III_metadata_line_28_____METAFRAKS_PAO_20251101 >									
	//        < 0h4Q4I5j3crKh770CHMYG82X2vr7aN09C34g0XEDUoyh0JrykEEuY2wSURDrMeOc >									
	//        <  u =="0.000000000000000001" : ] 000000680697272.249041000000000000 ; 000000705713426.240233000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040EA95F434D54F >									
	//     < RUSS_PFXXIII_III_metadata_line_29_____OGK_2_CHEREPOVETS_GRES_20251101 >									
	//        < 7vyA3Xy38J5EkgA65iIF91c4o57w5x8LV6nFSBxFR9HTn2ioYfp7LkZ6bJ57Ro4e >									
	//        <  u =="0.000000000000000001" : ] 000000705713426.240233000000000000 ; 000000724394680.246832000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000434D54F45156AC >									
	//     < RUSS_PFXXIII_III_metadata_line_30_____OGK_2_GRES_24_20251101 >									
	//        < kSHxsPy6LaL2eEYDSD8gu3m1yADxbx8T06z0fwHG4IC9Pg32DHeN7YGicHB4mJ7a >									
	//        <  u =="0.000000000000000001" : ] 000000724394680.246832000000000000 ; 000000750902910.695438000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045156AC479C973 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXIII_III_metadata_line_31_____PHOSAGRO_20251101 >									
	//        < 6GgHtdu473OZq6AMTVCDGZlmwuLSxzjenCXCh39QHJnM5IsHh8Ghhmton6P40tEI >									
	//        <  u =="0.000000000000000001" : ] 000000750902910.695438000000000000 ; 000000770706201.980248000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000479C973498011C >									
	//     < RUSS_PFXXIII_III_metadata_line_32_____BELARUSKALI_20251101 >									
	//        < NCVb44d21h9vG5b8q305xL4M9TqvGF3de9CNt7BJEIxQ2Ubz9Hp5m6Tok5O7nx2H >									
	//        <  u =="0.000000000000000001" : ] 000000770706201.980248000000000000 ; 000000799812045.922014000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000498011C4C46A95 >									
	//     < RUSS_PFXXIII_III_metadata_line_33_____KPLUSS_20251101 >									
	//        < SaWrSbl2uB9dbb95F8KZy54vfHElGbJ0R78ZoCoaUQFKpw069rjQ2Sdi931vuA67 >									
	//        <  u =="0.000000000000000001" : ] 000000799812045.922014000000000000 ; 000000820765269.443839000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C46A954E4636F >									
	//     < RUSS_PFXXIII_III_metadata_line_34_____KPLUSS_ORG_20251101 >									
	//        < Jh3dIL93LaDtQoJoMG6F70L50v7Zr4I2AQMA5zg52MF8nQ7XPiCc7a0gLq36HAZC >									
	//        <  u =="0.000000000000000001" : ] 000000820765269.443839000000000000 ; 000000845757982.187755000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E4636F50A8636 >									
	//     < RUSS_PFXXIII_III_metadata_line_35_____POTASHCORP_20251101 >									
	//        < c6HtPB7GBVhGA42cEqKwx4L21px5yk289kTpbrD2s8yp2VLF1jVyN7eT142XxpbK >									
	//        <  u =="0.000000000000000001" : ] 000000845757982.187755000000000000 ; 000000870039278.083073000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000050A863652F9318 >									
	//     < RUSS_PFXXIII_III_metadata_line_36_____BANK_URALSIB_20251101 >									
	//        < B73un8D3dZ38R9hE8k2swLfZye2iVCQWH6Z75jgGR9x6S0b1RxxIl6qbJ4nKv5o0 >									
	//        <  u =="0.000000000000000001" : ] 000000870039278.083073000000000000 ; 000000898455456.347633000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000052F931855AEF2A >									
	//     < RUSS_PFXXIII_III_metadata_line_37_____URALSIB_LEASING_CO_20251101 >									
	//        < oshos588L2U7gqMe7b0nwzjgYEqk3BH3h3A588HfIJ18Vzan4mEj6emDR5Vltl5R >									
	//        <  u =="0.000000000000000001" : ] 000000898455456.347633000000000000 ; 000000933743450.197498000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000055AEF2A590C789 >									
	//     < RUSS_PFXXIII_III_metadata_line_38_____BANK_URALSIB_AM_20251101 >									
	//        < 63PDcX7d6t0Zl3ZQ5my07XZXI8IpDU2WosEyfl3lc083sDc6OH06yr9wt649HBS7 >									
	//        <  u =="0.000000000000000001" : ] 000000933743450.197498000000000000 ; 000000964757081.194233000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000590C7895C01A3C >									
	//     < RUSS_PFXXIII_III_metadata_line_39_____BASHKIRSKIY_20251101 >									
	//        < w4r7yHJ6CzdVu61wEGssetpB5nH9VUtlW0BFU247mh09I1ZNHlu7VSS4TU7X6I24 >									
	//        <  u =="0.000000000000000001" : ] 000000964757081.194233000000000000 ; 000000985734565.155253000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C01A3C5E01C91 >									
	//     < RUSS_PFXXIII_III_metadata_line_40_____URALSIB_INVESTMENT_ARM_20251101 >									
	//        < NXJ8JL5PIGYcbC2Trb5UUNlP839HSA9e0IG1O08443Q5CGTka5109KN3476JRwTd >									
	//        <  u =="0.000000000000000001" : ] 000000985734565.155253000000000000 ; 000001006586027.158770000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005E01C915FFEDAB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}