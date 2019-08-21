pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFIV_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFIV_III_883		"	;
		string	public		symbol =	"	NDRV_PFIV_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1925056343068320000000000000					;	
										
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
	//     < NDRV_PFIV_III_metadata_line_1_____gerling beteiligungs_gmbh_20251101 >									
	//        < R5Tr5nsyj5aTe5Gb8Cf30891imBwzKP4TAW1athPACbIfjL1PEZErlzaDja6Ozar >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000086957871.609982100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000084AFEB >									
	//     < NDRV_PFIV_III_metadata_line_2_____aspecta lebensversicherung ag_20251101 >									
	//        < 8jIFEn0dRdEMnYMBL8F453UJ7123Bp0qpBtI7h1SVNtbey1S28EY0AAbqSBkhc3H >									
	//        <  u =="0.000000000000000001" : ] 000000086957871.609982100000000000 ; 000000136333769.114658000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000084AFEBD00761 >									
	//     < NDRV_PFIV_III_metadata_line_3_____ampega asset management gmbh_20251101 >									
	//        < pdx7F4uBkc361wX7N56xj95T9Qzb880D3Qzv13izdJv5yB6Z5nWeq5k3BjM53a7u >									
	//        <  u =="0.000000000000000001" : ] 000000136333769.114658000000000000 ; 000000170163120.439260000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000D00761103A5F8 >									
	//     < NDRV_PFIV_III_metadata_line_4_____deutschland bancassurance gmbh_20251101 >									
	//        < UmMsQ6bNYTr08Q953rrZPJb5G7dBshIew141bSz8IKQ6j5q5VTYd1ciYRvNs35Ja >									
	//        <  u =="0.000000000000000001" : ] 000000170163120.439260000000000000 ; 000000199210186.949335000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000103A5F812FF87B >									
	//     < NDRV_PFIV_III_metadata_line_5_____hdi_gerling assurances sa_20251101 >									
	//        < y74GC041tlnruw4I9jn3uFC25EGe3Keb627kIjO38eA4Y7oB9ztoa65Yv53vpALv >									
	//        <  u =="0.000000000000000001" : ] 000000199210186.949335000000000000 ; 000000231175040.228633000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012FF87B160BEC0 >									
	//     < NDRV_PFIV_III_metadata_line_6_____hdi_gerling firmen und privat versicherung ag_20251101 >									
	//        < 773ILvZk2EBZ92C93Lzf65tYE38aqAUV9wgTV57pXQ3X2IR69RRa84vNYACxgKMd >									
	//        <  u =="0.000000000000000001" : ] 000000231175040.228633000000000000 ; 000000318751732.089241000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000160BEC01E66065 >									
	//     < NDRV_PFIV_III_metadata_line_7_____ooo strakhovaya kompaniya civ life_20251101 >									
	//        < 60tVi05e4XRs9YO2U4q7K16L150iNrtu3JXNJKVVJM0BP3S7lY4jrmy6K802A2xf >									
	//        <  u =="0.000000000000000001" : ] 000000318751732.089241000000000000 ; 000000343309841.874867000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E6606520BD968 >									
	//     < NDRV_PFIV_III_metadata_line_8_____inversiones magallanes sa_20251101 >									
	//        < djl3Tls72MHXhhj3Z0ID23J2yTxf11jkH2H2Sz18UsnZ3v8G0cBY3xJwP7Hr6Ua3 >									
	//        <  u =="0.000000000000000001" : ] 000000343309841.874867000000000000 ; 000000388345294.020755000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020BD9682509161 >									
	//     < NDRV_PFIV_III_metadata_line_9_____hdi seguros de vida sa_20251101 >									
	//        < S10Y2dm2012z199iy0L1RvWiL79AB14m87zEcokG3Et07Q21N1uTKyZ6CXwwnpE3 >									
	//        <  u =="0.000000000000000001" : ] 000000388345294.020755000000000000 ; 000000409642162.692650000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025091612711078 >									
	//     < NDRV_PFIV_III_metadata_line_10_____winsor verwaltungs_ag_20251101 >									
	//        < Qx2KZK2hG60Tp66WQtlg0TMRM4mC2Fd5q0byQ95Vz6nrvao3bUPExW5M3vie8X6T >									
	//        <  u =="0.000000000000000001" : ] 000000409642162.692650000000000000 ; 000000459663102.323896000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027110782BD63E6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIV_III_metadata_line_11_____gerling_konzern globale rückversicherungs_ag_20251101 >									
	//        < k5hdj9D6i1JOAXE4IjGKd5u8o9nGSD2Bh5v82409V30zuJ13QQj3K9CFS4qM4IPb >									
	//        <  u =="0.000000000000000001" : ] 000000459663102.323896000000000000 ; 000000528665849.104118000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BD63E6326AE19 >									
	//     < NDRV_PFIV_III_metadata_line_12_____gerling gfp verwaltungs_ag_20251101 >									
	//        < 1IeH31I0Tlc2z7CowWPi1pKmQqWS7f6JIqk07Uw44Yh4R42hOdOFr00Qeh4ufKUz >									
	//        <  u =="0.000000000000000001" : ] 000000528665849.104118000000000000 ; 000000564210555.096467000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000326AE1935CEAC0 >									
	//     < NDRV_PFIV_III_metadata_line_13_____hdi kundenservice ag_20251101 >									
	//        < 30P0CN4j2ED4ZMwKYkSxV1WJ3A60Ywy5g1d667HR16z4FI4fR5Xrtz7dJwsJ1ZM7 >									
	//        <  u =="0.000000000000000001" : ] 000000564210555.096467000000000000 ; 000000649154796.849370000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035CEAC03DE8818 >									
	//     < NDRV_PFIV_III_metadata_line_14_____beteiligungs gmbh co kg_20251101 >									
	//        < lQn4CoO6Mfr2M1uIjMzmRShI4l1M56pmT26Q8HxQ1Teo73UAZRs0AN6LFm9N6ENM >									
	//        <  u =="0.000000000000000001" : ] 000000649154796.849370000000000000 ; 000000681614267.105650000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DE88184100F93 >									
	//     < NDRV_PFIV_III_metadata_line_15_____talanx reinsurance broker gmbh_20251101 >									
	//        < kXU5JfwL2k37m36u4tD0h0H359Vr1JPFt35B5CtKZ5qQe7MdAF71BHxr72sHHiW9 >									
	//        <  u =="0.000000000000000001" : ] 000000681614267.105650000000000000 ; 000000735903423.681053000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004100F93462E646 >									
	//     < NDRV_PFIV_III_metadata_line_16_____neue leben holding ag_20251101 >									
	//        < xn48gcymCGrniI93Sa5DZGcILSs48j786RRy5lsIa5jZ4Kcg2a9JJN9F0w5se3X9 >									
	//        <  u =="0.000000000000000001" : ] 000000735903423.681053000000000000 ; 000000755877748.674287000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000462E64648160BF >									
	//     < NDRV_PFIV_III_metadata_line_17_____neue leben unfallversicherung ag_20251101 >									
	//        < z2omcsTR9PxtA4N74HdZ4aoX1kQ2pWNe7P72CADmF3ZYGwGI0ii97fT14Tuu4MVC >									
	//        <  u =="0.000000000000000001" : ] 000000755877748.674287000000000000 ; 000000790458340.565877000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048160BF4B624CA >									
	//     < NDRV_PFIV_III_metadata_line_18_____neue leben lebensversicherung ag_20251101 >									
	//        < ENcRDoC3Z60DKk25h20vN33B5hV41Lw9rt90775F85zYIEY0Tir7dDjk3Doe99G1 >									
	//        <  u =="0.000000000000000001" : ] 000000790458340.565877000000000000 ; 000000820020065.195557000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B624CA4E34057 >									
	//     < NDRV_PFIV_III_metadata_line_19_____pb versicherung ag_20251101 >									
	//        < mq482sU7PNiO3pAHiBdZw02SozVOdT9ib5AvJQuroG2812xAxB3D322CH9dvBx8Z >									
	//        <  u =="0.000000000000000001" : ] 000000820020065.195557000000000000 ; 000000854406127.692836000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E34057517B865 >									
	//     < NDRV_PFIV_III_metadata_line_20_____talanx systeme ag_20251101 >									
	//        < YnK4VKC2USs8Tl9308TQJSw4w8GH0cXxUNa4PZ9zLi0DczvVQGPxb8k8nwdw34Ob >									
	//        <  u =="0.000000000000000001" : ] 000000854406127.692836000000000000 ; 000000929319934.877889000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000517B86558A0799 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIV_III_metadata_line_21_____hdi seguros sa_20251101 >									
	//        < L2SyFiQIgj588DnS7J88Ofug85fNO2jRc8VCQF6xlxC8uTkb7xgMt14a0ReKOpS1 >									
	//        <  u =="0.000000000000000001" : ] 000000929319934.877889000000000000 ; 000001017670253.705160000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000058A0799610D771 >									
	//     < NDRV_PFIV_III_metadata_line_22_____talanx nassau assekuranzkontor gmbh_20251101 >									
	//        < LvdyaKMkK4Y4c0K8Y7dKFZi0k7q4VM3TF2kWSi162p60v70Qd7WTLAvW590wadCH >									
	//        <  u =="0.000000000000000001" : ] 000001017670253.705160000000000000 ; 000001109232457.342420000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000610D77169C8DEE >									
	//     < NDRV_PFIV_III_metadata_line_23_____td real assets gmbh co kg_20251101 >									
	//        < tL3UTX8D90sFY768pj0w40CMsi1L9hTRdQ7CMN93XiLpO1m4B3l4alWy6MWY5Cwb >									
	//        <  u =="0.000000000000000001" : ] 000001109232457.342420000000000000 ; 000001140104324.669140000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000069C8DEE6CBA940 >									
	//     < NDRV_PFIV_III_metadata_line_24_____partner office ag_20251101 >									
	//        < y3p3M18czMn4CQpY04ctHBEyQLEj3K20126w41rCX9UfT6mplRT3Y4EC8bnm65nm >									
	//        <  u =="0.000000000000000001" : ] 000001140104324.669140000000000000 ; 000001200756009.868600000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006CBA9407283551 >									
	//     < NDRV_PFIV_III_metadata_line_25_____hgi alternative investments beteiligungs_gmbh co kg_20251101 >									
	//        < XFt3H0fp6DIP65qx26wsm30Z8H99z4Mfv1ZX51c9N8rKHF5201RD9QxrB65l0LBj >									
	//        <  u =="0.000000000000000001" : ] 000001200756009.868600000000000000 ; 000001271322575.864070000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007283551793E262 >									
	//     < NDRV_PFIV_III_metadata_line_26_____ferme eolienne du mignaudières sarl_20251101 >									
	//        < 9JwhvGI86k56H6pD22y64apX3l454e5ap4p26RTUUH843uY20KRUEGs82021m6JT >									
	//        <  u =="0.000000000000000001" : ] 000001271322575.864070000000000000 ; 000001301416452.721410000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000793E2627C1CDCD >									
	//     < NDRV_PFIV_III_metadata_line_27_____talanx ag asset management arm_20251101 >									
	//        < O9SY0jHV8DRVRaz61uZnVZb5yi760w19miB8B4hpUaJwz2p3H56622b8OF6Qb9KS >									
	//        <  u =="0.000000000000000001" : ] 000001301416452.721410000000000000 ; 000001354023019.948580000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007C1CDCD812133E >									
	//     < NDRV_PFIV_III_metadata_line_28_____talanx bureau für versicherungswesen robert gerling & co gmbh_20251101 >									
	//        < Lr7870937m8ZsUni6tLki6iPKAgOsiZ86EeWA11vgK1mkzk2g6V8LW0g5i15cfSP >									
	//        <  u =="0.000000000000000001" : ] 000001354023019.948580000000000000 ; 000001410016311.884690000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000812133E867839F >									
	//     < NDRV_PFIV_III_metadata_line_29_____pb pensionskasse aktiengesellschaft_20251101 >									
	//        < jTd0d6q2vmZpH59fF3Z2i7CnvOiXUF2x4fk0OOfs9E4Ve6MqwMxNJ236Y56478a9 >									
	//        <  u =="0.000000000000000001" : ] 000001410016311.884690000000000000 ; 000001472493161.175080000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000867839F8C6D8A4 >									
	//     < NDRV_PFIV_III_metadata_line_30_____hdi direkt service gmbh_20251101 >									
	//        < tV1Zh5W6o2Z098IR3e7opFvWYUId52Dy8aJ197oxt97581pGs31qn37lB2oFXrR9 >									
	//        <  u =="0.000000000000000001" : ] 000001472493161.175080000000000000 ; 000001520589019.104080000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008C6D8A49103C16 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIV_III_metadata_line_31_____gerling immo spezial 1_20251101 >									
	//        < DT7IS6IfS7jVgH3JS006w5x3mn7Oy5ynOBo5t4pxQ645G5F4s008I0JVLYbdyib9 >									
	//        <  u =="0.000000000000000001" : ] 000001520589019.104080000000000000 ; 000001551007842.818090000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009103C1693EA670 >									
	//     < NDRV_PFIV_III_metadata_line_32_____gente compania de soluciones profesionales de mexico sa de cv_20251101 >									
	//        < zJn6N5e9SDKrDqQE93zt69Ct6G1e0216D9wd3O8zMPCbL4rZ7MrVDsFCy7m8yiG8 >									
	//        <  u =="0.000000000000000001" : ] 000001551007842.818090000000000000 ; 000001604748014.027150000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000093EA670990A6B1 >									
	//     < NDRV_PFIV_III_metadata_line_33_____credit life international versicherung ag_20251101 >									
	//        < 9g9i3b08xvCm7iR3KKJssdYuxQT8VUibR4IpLZlCK9mS4bz8zzBNCKm2ki1xNac0 >									
	//        <  u =="0.000000000000000001" : ] 000001604748014.027150000000000000 ; 000001625209079.678100000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000990A6B19AFDF4C >									
	//     < NDRV_PFIV_III_metadata_line_34_____talanx pensionsmanagement ag_20251101 >									
	//        < 16q0o3Z6bnx392l74AY1J057K467K7Cly690kb1OKK9nMl07684hNiueZYrftk7S >									
	//        <  u =="0.000000000000000001" : ] 000001625209079.678100000000000000 ; 000001657546825.866710000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009AFDF4C9E1373B >									
	//     < NDRV_PFIV_III_metadata_line_35_____talanx infrastructure portugal 2 gmbh_20251101 >									
	//        < Ks4eHaZznCVuKWDPQG026a6d18F546xjhSz014psPUDl0iF9LwZbsqZwu8FueaBM >									
	//        <  u =="0.000000000000000001" : ] 000001657546825.866710000000000000 ; 000001681550791.224500000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009E1373BA05D7C7 >									
	//     < NDRV_PFIV_III_metadata_line_36_____pnh parque do novo hospital sa_20251101 >									
	//        < 6uf8f311rHb42lT43D8KeU68q5O0IjRoJCOzIY7pZaIzqfRIj5vlrhs1p6imsoQg >									
	//        <  u =="0.000000000000000001" : ] 000001681550791.224500000000000000 ; 000001705064018.375300000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A05D7C7A29B8A2 >									
	//     < NDRV_PFIV_III_metadata_line_37_____aberdeen infrastructure holdco bv_20251101 >									
	//        < nkKQ9w3O2Aa3ppjJ9QgojOvCb8610Xme4p51rth831zTHK4f74FoAeW2ARF45v5V >									
	//        <  u =="0.000000000000000001" : ] 000001705064018.375300000000000000 ; 000001729660663.093860000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A29B8A2A4F40B2 >									
	//     < NDRV_PFIV_III_metadata_line_38_____escala vila franca sociedade gestora do edifício sa_20251101 >									
	//        < 0568N1R56Bt9uUQ0KSyb7p5gO4t2LhCJpyhgR92m9y29872uRp5P3DIcJSagL9Uq >									
	//        <  u =="0.000000000000000001" : ] 000001729660663.093860000000000000 ; 000001764425032.508040000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A4F40B2A844C87 >									
	//     < NDRV_PFIV_III_metadata_line_39_____pnh parque do novo hospital sa_20251101 >									
	//        < W5kbv8016o4U6cJ0zEsc5GB4rw1JS9Ay0yE8WGF7TypRPGst0mI973Pi078LtaoM >									
	//        <  u =="0.000000000000000001" : ] 000001764425032.508040000000000000 ; 000001832884340.366080000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A844C87AECC272 >									
	//     < NDRV_PFIV_III_metadata_line_40_____tunz warta sa_20251101 >									
	//        < 4euxMR5Q7iH2j9l8L87bJ72T9q2B5571UP43b1A0c2sfZS39YluU5sXyC62ElxLc >									
	//        <  u =="0.000000000000000001" : ] 000001832884340.366080000000000000 ; 000001925056343.068320000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000AECC272B796722 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}