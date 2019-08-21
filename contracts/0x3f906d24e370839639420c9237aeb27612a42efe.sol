pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFII_II_883		"	;
		string	public		symbol =	"	RUSS_PFII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		804418858970009000000000000					;	
										
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
	//     < RUSS_PFII_II_metadata_line_1_____SISTEMA_20231101 >									
	//        < 922XZW1f1Dkv4X8Zl9IEMhFC9nfhkuF7EYQ03Q5th874VeHS8YnW0vOnIn9A08bc >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000017451345.573337400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001AA0EF >									
	//     < RUSS_PFII_II_metadata_line_2_____SISTEMA_usd_20231101 >									
	//        < xOZOhSs08l5tkly6Yt5F24G34dp9E318I7FL4m1s0Kv8uh9t03ATXnxjqL6jxYEF >									
	//        <  u =="0.000000000000000001" : ] 000000017451345.573337400000000000 ; 000000037630096.284907700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001AA0EF396B42 >									
	//     < RUSS_PFII_II_metadata_line_3_____SISTEMA_AB_20231101 >									
	//        < AG7z7ljGR18V5eJTIAk2m6YTLx8cSiQJVYqOsx85p3FsI5Q8V1r7XLl63P9WIT87 >									
	//        <  u =="0.000000000000000001" : ] 000000037630096.284907700000000000 ; 000000056544824.828423300000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000396B425647D2 >									
	//     < RUSS_PFII_II_metadata_line_4_____RUSAL_20231101 >									
	//        < H9svpA7AYrix7ivBVRyF5d72sO70Kl9Ub1RV03WZ7xJyprJUGKywXFsF9Bx3P2dF >									
	//        <  u =="0.000000000000000001" : ] 000000056544824.828423300000000000 ; 000000079377774.605930700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005647D2791EF1 >									
	//     < RUSS_PFII_II_metadata_line_5_____RUSAL_HKD_20231101 >									
	//        < K2x6n8f35Nhhq4l1y3gDVqRK6nPeXOGb74pmwdgzP9M4iUKbpBJMu5fqXgYSIJ1D >									
	//        <  u =="0.000000000000000001" : ] 000000079377774.605930700000000000 ; 000000101930615.985985000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000791EF19B88A6 >									
	//     < RUSS_PFII_II_metadata_line_6_____RUSAL_GBP_20231101 >									
	//        < S0mV4F4a07D11WwNZLiRcI2p9cXg40y070oI95S4rkC61W0yj0BXL6CkbLQ360aM >									
	//        <  u =="0.000000000000000001" : ] 000000101930615.985985000000000000 ; 000000125414165.017916000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009B88A6BF5DE9 >									
	//     < RUSS_PFII_II_metadata_line_7_____RUSAL_AB_20231101 >									
	//        < nkWK1H47zKYbAdfUQ86WWFgpITznNN0QG1K66sTwQwx09edDJ14qqt389Gf94802 >									
	//        <  u =="0.000000000000000001" : ] 000000125414165.017916000000000000 ; 000000145216778.072324000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BF5DE9DD954E >									
	//     < RUSS_PFII_II_metadata_line_8_____EUROSIBENERGO_20231101 >									
	//        < 0W3tFEaxAs18ixI5q1xf7DVqidZ0aaMCjJU6jeCj8e94zNsSEUdnPyycA2eU57sb >									
	//        <  u =="0.000000000000000001" : ] 000000145216778.072324000000000000 ; 000000165792449.768738000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DD954EFCFAAD >									
	//     < RUSS_PFII_II_metadata_line_9_____BASEL_20231101 >									
	//        < Bs5QAA08389SuO879hvL3f9DAYhCjiwq6KzJRO73w5bZmXiw66CImJf41n2df3X3 >									
	//        <  u =="0.000000000000000001" : ] 000000165792449.768738000000000000 ; 000000182848331.048629000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FCFAAD1170121 >									
	//     < RUSS_PFII_II_metadata_line_10_____ENPLUS_20231101 >									
	//        < iZc2Molh7URSFIHA21v5s725PwZ34G18373lIN3Q021h91lgxkz68czX8ctu2lIs >									
	//        <  u =="0.000000000000000001" : ] 000000182848331.048629000000000000 ; 000000206236857.632158000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000117012113AB146 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFII_II_metadata_line_11_____RUSSIAN_MACHINES_20231101 >									
	//        < 0r1gItZnav8Qqd4O3XUbv8PqH7bQk6M7yG348sx83XeCcIbE8h1VcXFh5b26Us46 >									
	//        <  u =="0.000000000000000001" : ] 000000206236857.632158000000000000 ; 000000229838182.132957000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013AB14615EB48A >									
	//     < RUSS_PFII_II_metadata_line_12_____GAZ_GROUP_20231101 >									
	//        < 0J9o315b28C5S1e2yUAFSjX5KTR0SkrUaVZ6b1I1m0JB021HF8s70b8H414egk5y >									
	//        <  u =="0.000000000000000001" : ] 000000229838182.132957000000000000 ; 000000249192651.200791000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015EB48A17C3CE1 >									
	//     < RUSS_PFII_II_metadata_line_13_____SMR_20231101 >									
	//        < 7h8cdfHmS19rm64NfuDWFjLG21mUEg6X17roNyD7JL8IxxS8T3ze5EL82DR2051T >									
	//        <  u =="0.000000000000000001" : ] 000000249192651.200791000000000000 ; 000000268044579.181637000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017C3CE119900EA >									
	//     < RUSS_PFII_II_metadata_line_14_____ENPLUS_DOWN_20231101 >									
	//        < nHh3Ydp2Br7CYU72t64N2fzx8F68g8a71I0bNuD9F1Q37fPJAECo65576ocI7iGO >									
	//        <  u =="0.000000000000000001" : ] 000000268044579.181637000000000000 ; 000000285631577.152451000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019900EA1B3D6D6 >									
	//     < RUSS_PFII_II_metadata_line_15_____ENPLUS_COAL_20231101 >									
	//        < h9Amta4Wv2SfJUQSRUHIxwxa23ZcAr0XgM0aPBj8uhJW44I2v2T4i6sd78g68631 >									
	//        <  u =="0.000000000000000001" : ] 000000285631577.152451000000000000 ; 000000308425055.241931000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B3D6D61D69E8A >									
	//     < RUSS_PFII_II_metadata_line_16_____RM_SYSTEMS_20231101 >									
	//        < 2VnJmi6CM3TH1KYDg04F4Xq7J20z9VPjBs9l76c5Lw0133Ylib29Z4D8Ks2yb0J7 >									
	//        <  u =="0.000000000000000001" : ] 000000308425055.241931000000000000 ; 000000327141397.256366000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D69E8A1F32D9C >									
	//     < RUSS_PFII_II_metadata_line_17_____RM_RAIL_20231101 >									
	//        < 315b3rXU9e4C38HKK3l8GEfgb7f4QqGT27C7V1lC7Czu850pUMbqPg5SwCf7p50m >									
	//        <  u =="0.000000000000000001" : ] 000000327141397.256366000000000000 ; 000000345801732.158348000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F32D9C20FA6CD >									
	//     < RUSS_PFII_II_metadata_line_18_____AVIAKOR_20231101 >									
	//        < sOTvVLu369O928jLy6P3I99eMuf46WZmvf1u529Snl3C6fnXsU3HXtMVIQsZ72OF >									
	//        <  u =="0.000000000000000001" : ] 000000345801732.158348000000000000 ; 000000365488227.722253000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020FA6CD22DB0D7 >									
	//     < RUSS_PFII_II_metadata_line_19_____SOCHI_AIRPORT_20231101 >									
	//        < fT6zDZ4qLcQ4Vfp07A9G5j6umu6TNoHQ256L8gNMkY4IKABZIE9hc9jE538K3zG1 >									
	//        <  u =="0.000000000000000001" : ] 000000365488227.722253000000000000 ; 000000388962109.233406000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022DB0D72518253 >									
	//     < RUSS_PFII_II_metadata_line_20_____KRASNODAR_AIRPORT_20231101 >									
	//        < Hh6WT5mMO842a4o8XIrcg44zPcj31X9Phu4SU7D3lG6E6q4bC83vGGw91wjF0W74 >									
	//        <  u =="0.000000000000000001" : ] 000000388962109.233406000000000000 ; 000000410125400.960028000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002518253271CD3C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFII_II_metadata_line_21_____ANAPA_AIRPORT_20231101 >									
	//        < 9IJ0511umzaRFI5t0Wy3t9rvPyrDtVnSM1ou13CKH9G5Mj7OB7mRRndpp8pnQk12 >									
	//        <  u =="0.000000000000000001" : ] 000000410125400.960028000000000000 ; 000000433890520.848336000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000271CD3C296107C >									
	//     < RUSS_PFII_II_metadata_line_22_____GLAVMOSSTROY_20231101 >									
	//        < XLCS2ct0JV2slUWeHz56Ub5u18d54XSEG65nPk659sXoHHZ631qBz6X79HHtIg94 >									
	//        <  u =="0.000000000000000001" : ] 000000433890520.848336000000000000 ; 000000451593215.382244000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000296107C2B1139A >									
	//     < RUSS_PFII_II_metadata_line_23_____TRANSSTROY_20231101 >									
	//        < 3R6H103619uFkT149e899QGz6E27VF5E943wSs6OVO1RFHc0RRY2Zo9Bw6iIWO7B >									
	//        <  u =="0.000000000000000001" : ] 000000451593215.382244000000000000 ; 000000470818313.435904000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B1139A2CE6967 >									
	//     < RUSS_PFII_II_metadata_line_24_____GLAVSTROY_20231101 >									
	//        < na3SF9t7eBhI89G10K43L4d926eX4GJnHEy3WOEcZd389gXkRrHLJ5C56o57544Z >									
	//        <  u =="0.000000000000000001" : ] 000000470818313.435904000000000000 ; 000000492319827.910449000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CE69672EF386F >									
	//     < RUSS_PFII_II_metadata_line_25_____GLAVSTROY_SPB_20231101 >									
	//        < Z3vH6AKF22n6O3T9aVtRGChlhhJdyrC54pT28P1OP6xY7sZO60aJW353mCbw1piL >									
	//        <  u =="0.000000000000000001" : ] 000000492319827.910449000000000000 ; 000000509483429.937191000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EF386F30968F7 >									
	//     < RUSS_PFII_II_metadata_line_26_____ROGSIBAL_20231101 >									
	//        < P2oo7Tu6L0AzN5cwAVD31jGe639g9J877bTNaPx8qpAnj475cBBK8ELrqcmGc0Aa >									
	//        <  u =="0.000000000000000001" : ] 000000509483429.937191000000000000 ; 000000529148038.230523000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030968F73276A74 >									
	//     < RUSS_PFII_II_metadata_line_27_____BASEL_CEMENT_20231101 >									
	//        < vWlqau2xdhc24M9vQLvPOwbC1oR8dgf661X368GG2eHDUl6J37biOnrBs1fGO2qj >									
	//        <  u =="0.000000000000000001" : ] 000000529148038.230523000000000000 ; 000000546324733.093281000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003276A74341A019 >									
	//     < RUSS_PFII_II_metadata_line_28_____KUBAN_AGROHOLDING_20231101 >									
	//        < 46Ock5ilM1khYi09k5S4DBWCE112ws00RgGn65w1mBwC7PhXvY4L5Xpb7GOP8Mzk >									
	//        <  u =="0.000000000000000001" : ] 000000546324733.093281000000000000 ; 000000564305896.478938000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000341A01935D0FFE >									
	//     < RUSS_PFII_II_metadata_line_29_____AQUADIN_20231101 >									
	//        < 94874p615j03nsUJIi9rc3ldiQcEe2DW9Xs0FifD0EydM4y36ku0OH285S4d1DlE >									
	//        <  u =="0.000000000000000001" : ] 000000564305896.478938000000000000 ; 000000585908128.295622000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035D0FFE37E065D >									
	//     < RUSS_PFII_II_metadata_line_30_____VASKHOD_STUD_FARM_20231101 >									
	//        < bYD0V5NfzW0ZW6Ko39629LJ70yZyNn9Po5jgRlabK4t9x8jJMvccFB7WB3fs89vG >									
	//        <  u =="0.000000000000000001" : ] 000000585908128.295622000000000000 ; 000000604112825.257725000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037E065D399CD93 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFII_II_metadata_line_31_____IMERETINSKY_PORT_20231101 >									
	//        < 41a19epqY18VdAb2M7TOAtVypWU5NSBVlgpi3T42bZ2hBI54IwALLU3b8A6XW124 >									
	//        <  u =="0.000000000000000001" : ] 000000604112825.257725000000000000 ; 000000626589348.197658000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000399CD933BC1977 >									
	//     < RUSS_PFII_II_metadata_line_32_____BASEL_REAL_ESTATE_20231101 >									
	//        < 61e3214Q0LLx5O9YF7jd5NWz9ql6i1yACml505IaRMjW44eFt5f5OIW0Qv6hejBr >									
	//        <  u =="0.000000000000000001" : ] 000000626589348.197658000000000000 ; 000000647880584.416373000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BC19773DC965A >									
	//     < RUSS_PFII_II_metadata_line_33_____UZHURALZOLOTO_20231101 >									
	//        < yk1H6x6rb4w8jrevUN6gN8K8o8R2gtRKCjPJ67ttoe9bi1q6Go25TU1SrirQDSUN >									
	//        <  u =="0.000000000000000001" : ] 000000647880584.416373000000000000 ; 000000667592639.326294000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DC965A3FAAA60 >									
	//     < RUSS_PFII_II_metadata_line_34_____NORILSK_NICKEL_20231101 >									
	//        < 384Xz6W0y9iwD19QfmdleyPB15A5Vq1atBkBmBy8TDo8YDj7zfUEBTGndY8KjIDr >									
	//        <  u =="0.000000000000000001" : ] 000000667592639.326294000000000000 ; 000000687150876.120440000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FAAA604188250 >									
	//     < RUSS_PFII_II_metadata_line_35_____RUSHYDRO_20231101 >									
	//        < SxiI1SMfpA9ZddmQi6PElMU2ASn46ht1b5nT3e6M0u2b252q8XA4iu4TD3ouyJwc >									
	//        <  u =="0.000000000000000001" : ] 000000687150876.120440000000000000 ; 000000705688924.084725000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004188250434CBBC >									
	//     < RUSS_PFII_II_metadata_line_36_____INTER_RAO_20231101 >									
	//        < M16sHHVG7BaNI2WC74PmDCV8n9yGE09B8F8WH929401igD77kuk8l8p495944qPB >									
	//        <  u =="0.000000000000000001" : ] 000000705688924.084725000000000000 ; 000000726273316.532171000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000434CBBC4543484 >									
	//     < RUSS_PFII_II_metadata_line_37_____LUKOIL_20231101 >									
	//        < o7BDz8eZ0620NuZ525oeJFmXUUjWHj5wfRUO6JdyG0QwfZDRoRQ5Kct2o3zAu824 >									
	//        <  u =="0.000000000000000001" : ] 000000726273316.532171000000000000 ; 000000746852840.991303000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045434844739B64 >									
	//     < RUSS_PFII_II_metadata_line_38_____MAGNITOGORSK_ISW_20231101 >									
	//        < MmU473tg3u7DSS5UQ1tFDxC788CO1sp27lyGrg8tI286293E81BoYv1N9u93m10K >									
	//        <  u =="0.000000000000000001" : ] 000000746852840.991303000000000000 ; 000000766473690.279096000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004739B644918BC9 >									
	//     < RUSS_PFII_II_metadata_line_39_____MAGNIT_20231101 >									
	//        < 4Ks75b80Z8tGPdQC0JJ7x25i5KWX355fJ2ooY4w5BA2w7Xb8j3r4gpFNr7DONL7B >									
	//        <  u =="0.000000000000000001" : ] 000000766473690.279096000000000000 ; 000000785272205.994272000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004918BC94AE3AF5 >									
	//     < RUSS_PFII_II_metadata_line_40_____IDGC_20231101 >									
	//        < Njn48GJDl725365suVz7WY4nZ25pp7F0rcgdGoZsRSmLouj01M3jq6Z1q39g1e8J >									
	//        <  u =="0.000000000000000001" : ] 000000785272205.994272000000000000 ; 000000804418858.970009000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004AE3AF54CB721E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}