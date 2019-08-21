pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFII_I_883		"	;
		string	public		symbol =	"	RUSS_PFII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		607574543126106000000000000					;	
										
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
	//     < RUSS_PFII_I_metadata_line_1_____SISTEMA_20211101 >									
	//        < 400532D9C7J2U6qe416Wstn7oGgz1YiJV9g89G35vim3qU828I2J3dqa7920tcto >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000013966814.050344300000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000154FC9 >									
	//     < RUSS_PFII_I_metadata_line_2_____SISTEMA_usd_20211101 >									
	//        < 8z7I4SlJC702uS33JwJxC0FfUL96xlIa9s9717ib3arA7os31e8H8tZ66415jiD5 >									
	//        <  u =="0.000000000000000001" : ] 000000013966814.050344300000000000 ; 000000029205115.652946000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000154FC92C9040 >									
	//     < RUSS_PFII_I_metadata_line_3_____SISTEMA_AB_20211101 >									
	//        < Kib28jRY9vs6aB2TZ5mAr4Z9Uk21gmM95luXFw3NAmGoSbaNszeDrO1oxZ3qK8tz >									
	//        <  u =="0.000000000000000001" : ] 000000029205115.652946000000000000 ; 000000043863296.235502600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002C904042EE1A >									
	//     < RUSS_PFII_I_metadata_line_4_____RUSAL_20211101 >									
	//        < 4G2k7069MPzmpARK9f74nX03n39M93zeL3BON4Ao656Fja8201SRo16jpgeT3L67 >									
	//        <  u =="0.000000000000000001" : ] 000000043863296.235502600000000000 ; 000000060274378.135398100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000042EE1A5BF8AE >									
	//     < RUSS_PFII_I_metadata_line_5_____RUSAL_HKD_20211101 >									
	//        < wbMsvjw8STJ7g7MX3Lq74Q2v0zDB70I15GEt91EuXaLqGF37O3W9nbzU1P9xRp20 >									
	//        <  u =="0.000000000000000001" : ] 000000060274378.135398100000000000 ; 000000076564365.942667500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005BF8AE74D3F5 >									
	//     < RUSS_PFII_I_metadata_line_6_____RUSAL_GBP_20211101 >									
	//        < jjnsBS323vD44f5o132plPd1Zq38VUk6Sx8Z9hfAtS9W7C17wXBu1u3egr5Bkinq >									
	//        <  u =="0.000000000000000001" : ] 000000076564365.942667500000000000 ; 000000093254439.051892900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000074D3F58E4B84 >									
	//     < RUSS_PFII_I_metadata_line_7_____RUSAL_AB_20211101 >									
	//        < txKyqQ5NQLvHwSUX86C804M9K0opjH7Jk9wHhTKkTz5Qs3FSrepLW7U642i3L7aW >									
	//        <  u =="0.000000000000000001" : ] 000000093254439.051892900000000000 ; 000000108321671.932877000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008E4B84A54927 >									
	//     < RUSS_PFII_I_metadata_line_8_____EUROSIBENERGO_20211101 >									
	//        < yUigUb1YKfjjtNtmS22jS21U4Zg86C4hr2ecYj0ruxAwl2t0p4ExMYV99AzozVf4 >									
	//        <  u =="0.000000000000000001" : ] 000000108321671.932877000000000000 ; 000000123739117.118783000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A54927BCCF98 >									
	//     < RUSS_PFII_I_metadata_line_9_____BASEL_20211101 >									
	//        < Z4rud34HFuqw8YS3gEw32Fx4yRo2Sj4F6p9pvIagC2A2ka613r34z27g8Ll3C0NR >									
	//        <  u =="0.000000000000000001" : ] 000000123739117.118783000000000000 ; 000000137515160.401992000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BCCF98D1D4DC >									
	//     < RUSS_PFII_I_metadata_line_10_____ENPLUS_20211101 >									
	//        < 16Ot29gznKrUybZ8ruC01Naz8UCPszb2zPY4wM4vG3o4c9qn853AB8tCRO8j5tTz >									
	//        <  u =="0.000000000000000001" : ] 000000137515160.401992000000000000 ; 000000154164680.420657000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D1D4DCEB3C94 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFII_I_metadata_line_11_____RUSSIAN_MACHINES_20211101 >									
	//        < j01G2jx120tEtu37kpLLgylZM4391zJj9ngJub94ejA57rmz477DatK6Yk5Ae8aC >									
	//        <  u =="0.000000000000000001" : ] 000000154164680.420657000000000000 ; 000000170904926.034408000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EB3C94104C7BD >									
	//     < RUSS_PFII_I_metadata_line_12_____GAZ_GROUP_20211101 >									
	//        < Clv26Ng63Ft5y4tqPQnjfn7ucldjB37rKk624KIUw239m6wos2a5jF47TJ1Qm8s7 >									
	//        <  u =="0.000000000000000001" : ] 000000170904926.034408000000000000 ; 000000185766635.171482000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000104C7BD11B7518 >									
	//     < RUSS_PFII_I_metadata_line_13_____SMR_20211101 >									
	//        < 3240DVCn6pVuMSfxsrdfIv3JxjFgUkrfX0hnA2QJw44Pe11247FFTZDP7jNZbF0n >									
	//        <  u =="0.000000000000000001" : ] 000000185766635.171482000000000000 ; 000000200395595.534121000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011B7518131C788 >									
	//     < RUSS_PFII_I_metadata_line_14_____ENPLUS_DOWN_20211101 >									
	//        < FAuP69wVE6z3hPMKZm70508RBF5QQzgdW7bSBlH7aL1KK93es53Ku09V3D9J8c0G >									
	//        <  u =="0.000000000000000001" : ] 000000200395595.534121000000000000 ; 000000214427448.591680000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000131C78814730B9 >									
	//     < RUSS_PFII_I_metadata_line_15_____ENPLUS_COAL_20211101 >									
	//        < kXoyWR4p5ykIOZVZ02aDT092xwxshflFlSJ8DPDOi2SigCcg9mb97q3W4RtB4FCr >									
	//        <  u =="0.000000000000000001" : ] 000000214427448.591680000000000000 ; 000000230821502.540603000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014730B916034A6 >									
	//     < RUSS_PFII_I_metadata_line_16_____RM_SYSTEMS_20211101 >									
	//        < Nc3XT2tH2RGEdV6LC4mcwnbOOrBI1M6uyhP4dFSW2R327riXBiD23qDTa8S2Q2L5 >									
	//        <  u =="0.000000000000000001" : ] 000000230821502.540603000000000000 ; 000000245387243.551385000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016034A61766E64 >									
	//     < RUSS_PFII_I_metadata_line_17_____RM_RAIL_20211101 >									
	//        < tB5Y704z8wJ71FmZrSk368f09IUs6S0G4jjw0Yy3rDj0X3SIHI188Q283qto7qV3 >									
	//        <  u =="0.000000000000000001" : ] 000000245387243.551385000000000000 ; 000000259926816.820273000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001766E6418C9DEA >									
	//     < RUSS_PFII_I_metadata_line_18_____AVIAKOR_20211101 >									
	//        < HcC1irGy70i0kX941j211Q3CQ9pckk48TsOw3pn5Nq7YnGAd4C88yS2PTmk5OP20 >									
	//        <  u =="0.000000000000000001" : ] 000000259926816.820273000000000000 ; 000000274940977.108065000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018C9DEA1A386D2 >									
	//     < RUSS_PFII_I_metadata_line_19_____SOCHI_AIRPORT_20211101 >									
	//        < 84YpHEE821Z5oMWJPp444LF861Z6V9hUUS4OAZ6Njt8F7pLGoqjmmn4h9mym256j >									
	//        <  u =="0.000000000000000001" : ] 000000274940977.108065000000000000 ; 000000291626927.375832000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A386D21BCFCC5 >									
	//     < RUSS_PFII_I_metadata_line_20_____KRASNODAR_AIRPORT_20211101 >									
	//        < 0lo3g76tuauj8Vi758BUTz99ta2jx47N1Wn6OZs935z11kKfQ2CJVf46X2Do1KqQ >									
	//        <  u =="0.000000000000000001" : ] 000000291626927.375832000000000000 ; 000000307307067.201196000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BCFCC51D4E9D3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFII_I_metadata_line_21_____ANAPA_AIRPORT_20211101 >									
	//        < YOw5Nl2FbepoE6eV5w22x2dzTcnOC0Uat3fr625z186LO96t5z64zwKF7WcPMWw4 >									
	//        <  u =="0.000000000000000001" : ] 000000307307067.201196000000000000 ; 000000324116923.689032000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D4E9D31EE902C >									
	//     < RUSS_PFII_I_metadata_line_22_____GLAVMOSSTROY_20211101 >									
	//        < BrSC6UIG52uPfn0z52e0RCx89hlw3k158u7syr7lczgiygzsF7JuU6xr24PN7is6 >									
	//        <  u =="0.000000000000000001" : ] 000000324116923.689032000000000000 ; 000000338204089.463682000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EE902C2040EF9 >									
	//     < RUSS_PFII_I_metadata_line_23_____TRANSSTROY_20211101 >									
	//        < 7Z0oeUL3MqSmEkps72NqWB764tE7F0A92XgdaBs5r31iAcc9d27jD3NX8S59qQ6u >									
	//        <  u =="0.000000000000000001" : ] 000000338204089.463682000000000000 ; 000000353006114.624762000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002040EF921AA503 >									
	//     < RUSS_PFII_I_metadata_line_24_____GLAVSTROY_20211101 >									
	//        < 5CQk3X8Xq9O9i60zW3qUxpA2mbn2A97CzzX1vT77FN9aBRjjoowQhj8R8s6W2xhD >									
	//        <  u =="0.000000000000000001" : ] 000000353006114.624762000000000000 ; 000000368836133.419768000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021AA503232CC9D >									
	//     < RUSS_PFII_I_metadata_line_25_____GLAVSTROY_SPB_20211101 >									
	//        < PF55yqHQXr4R12XIqxu6Jq3Esp35n10X1Kls2bfQh3i7hTbQ9jn56z92x030AmmW >									
	//        <  u =="0.000000000000000001" : ] 000000368836133.419768000000000000 ; 000000382664314.614058000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000232CC9D247E63F >									
	//     < RUSS_PFII_I_metadata_line_26_____ROGSIBAL_20211101 >									
	//        < AdXv06Fp03HAXS9F2720kZ05rT3dx84Z9gp5ElXB29PJAr1wRff29mSs62pzUIPR >									
	//        <  u =="0.000000000000000001" : ] 000000382664314.614058000000000000 ; 000000397668457.107775000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000247E63F25ECB3E >									
	//     < RUSS_PFII_I_metadata_line_27_____BASEL_CEMENT_20211101 >									
	//        < jrR87205f9WHMQzGnfw57miJ7grHYb1k17Xf0EIKIr5z5c5fS7u4XWAz9Bk7T4On >									
	//        <  u =="0.000000000000000001" : ] 000000397668457.107775000000000000 ; 000000411502966.431664000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025ECB3E273E759 >									
	//     < RUSS_PFII_I_metadata_line_28_____KUBAN_AGROHOLDING_20211101 >									
	//        < Nv66l62jDG768ge8x409yXrMAFbDLhIZ0TzMxdwmq74MytaP253V5VFnar639a25 >									
	//        <  u =="0.000000000000000001" : ] 000000411502966.431664000000000000 ; 000000425722674.237141000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000273E75928999EB >									
	//     < RUSS_PFII_I_metadata_line_29_____AQUADIN_20211101 >									
	//        < 926yMCo9ucMC0eI62v5F7644S3KCtk1Tuxhv5XLOGKOg5QQ2J263UwESm26GU2bV >									
	//        <  u =="0.000000000000000001" : ] 000000425722674.237141000000000000 ; 000000441597142.003958000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028999EB2A1D2E2 >									
	//     < RUSS_PFII_I_metadata_line_30_____VASKHOD_STUD_FARM_20211101 >									
	//        < J8WNwJ1s0krr9JFvi4RKYOE5gRz3W3rg0hi0hbpS02I3r9ItI856jVwT5n4Z69f8 >									
	//        <  u =="0.000000000000000001" : ] 000000441597142.003958000000000000 ; 000000455922651.352335000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A1D2E22B7AEC9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFII_I_metadata_line_31_____IMERETINSKY_PORT_20211101 >									
	//        < qr8FC1rcw3rFN230611vuY4PZi5xY012xn0R664xR9atl6vxkFk4iIlW67s5740D >									
	//        <  u =="0.000000000000000001" : ] 000000455922651.352335000000000000 ; 000000472179541.710434000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B7AEC92D07D22 >									
	//     < RUSS_PFII_I_metadata_line_32_____BASEL_REAL_ESTATE_20211101 >									
	//        < 7smUpg6sRBv4L68cqvV6Kt1qoVGX7dNTb8ftZ5x1Fl1k0EdL1873YuNGuxu453oe >									
	//        <  u =="0.000000000000000001" : ] 000000472179541.710434000000000000 ; 000000487916490.334400000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D07D222E88061 >									
	//     < RUSS_PFII_I_metadata_line_33_____UZHURALZOLOTO_20211101 >									
	//        < LtoR8AJd2U8Q48B04mRgkRViDk63yq50s1zg81gePDOt8u4zrk2I0EJ8f8Nr9rm3 >									
	//        <  u =="0.000000000000000001" : ] 000000487916490.334400000000000000 ; 000000502942343.486384000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E880612FF6DDA >									
	//     < RUSS_PFII_I_metadata_line_34_____NORILSK_NICKEL_20211101 >									
	//        < UqmyMQCFe0I48YlQBn1KQc1p79QbSo42jxBs0e7nCL9jh1lAHg3J0IIojcd51smO >									
	//        <  u =="0.000000000000000001" : ] 000000502942343.486384000000000000 ; 000000517897736.140637000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FF6DDA3163FCE >									
	//     < RUSS_PFII_I_metadata_line_35_____RUSHYDRO_20211101 >									
	//        < 2Y2fOD0IVYI75pEbHW4ce20TN3Hy990D76961v38ro1MSf1C3nBeYrdK4uY63rqh >									
	//        <  u =="0.000000000000000001" : ] 000000517897736.140637000000000000 ; 000000532380064.861306000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003163FCE32C58F6 >									
	//     < RUSS_PFII_I_metadata_line_36_____INTER_RAO_20211101 >									
	//        < 459p7fiv94XDhM2X6Kz4HsG444lDf4vLfWxinAUW8N5bK6JQg0hFRWD8NF5UWU80 >									
	//        <  u =="0.000000000000000001" : ] 000000532380064.861306000000000000 ; 000000547801430.414180000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032C58F6343E0EF >									
	//     < RUSS_PFII_I_metadata_line_37_____LUKOIL_20211101 >									
	//        < rgZ3zy4Xzb3DB2WCUrULe92jLpc91v7J0TigaZ513of451b2xxv5aO2fvlArP6eu >									
	//        <  u =="0.000000000000000001" : ] 000000547801430.414180000000000000 ; 000000563220607.670890000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000343E0EF35B680D >									
	//     < RUSS_PFII_I_metadata_line_38_____MAGNITOGORSK_ISW_20211101 >									
	//        < V1aOlXiEUaZF73H38pT53mir6KJRq4LawH0bKV03sCmk62qT4I9kuj588YpMtx90 >									
	//        <  u =="0.000000000000000001" : ] 000000563220607.670890000000000000 ; 000000578204708.304968000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035B680D3724537 >									
	//     < RUSS_PFII_I_metadata_line_39_____MAGNIT_20211101 >									
	//        < nTB3nZ6qwkRd58hNNZ96t7yTWGBvs2OO0a6aAsAO0582vfF5KN9Tai0P5Hb0J9j3 >									
	//        <  u =="0.000000000000000001" : ] 000000578204708.304968000000000000 ; 000000592808786.037059000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037245373888DEF >									
	//     < RUSS_PFII_I_metadata_line_40_____IDGC_20211101 >									
	//        < QfI4PgmCY2wp9r6K28x9nq3P2ZkANNDFv0b6V084z8N8M8pr5nI4sA009552c171 >									
	//        <  u =="0.000000000000000001" : ] 000000592808786.037059000000000000 ; 000000607574543.126106000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003888DEF39F15CE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}