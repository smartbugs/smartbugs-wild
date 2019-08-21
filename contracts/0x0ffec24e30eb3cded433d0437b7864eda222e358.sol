pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFIV_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFIV_I_883		"	;
		string	public		symbol =	"	NDRV_PFIV_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		777476110514566000000000000					;	
										
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
	//     < NDRV_PFIV_I_metadata_line_1_____gerling beteiligungs_gmbh_20211101 >									
	//        < 6aWHs6q2Y27Sr2DR2o888y99Y0oJUtzl5O8C3u1waZjj52lvLD27T7b6H4ghmPvq >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000019085392.758606600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001D1F3B >									
	//     < NDRV_PFIV_I_metadata_line_2_____aspecta lebensversicherung ag_20211101 >									
	//        < z01P24I2BR835aVaC7a0Snlnhyz0QSIx4z443v0qM37d4564tcb4s836d3Kekrh9 >									
	//        <  u =="0.000000000000000001" : ] 000000019085392.758606600000000000 ; 000000039889012.812794900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001D1F3B3CDDA5 >									
	//     < NDRV_PFIV_I_metadata_line_3_____ampega asset management gmbh_20211101 >									
	//        < c11Xp845P0oLX36UuBIiG2xM5PlS1MBZS958sW6XqBNnJJBGUJ12xR1qb06KMg50 >									
	//        <  u =="0.000000000000000001" : ] 000000039889012.812794900000000000 ; 000000057849256.878763900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003CDDA558455E >									
	//     < NDRV_PFIV_I_metadata_line_4_____deutschland bancassurance gmbh_20211101 >									
	//        < Jn1dt22UB6i039Qm601v6h47JQ8Af654qNG4xW4sF5Dnw72yttZL90275j1U95H2 >									
	//        <  u =="0.000000000000000001" : ] 000000057849256.878763900000000000 ; 000000072621016.783693500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000058455E6ECF96 >									
	//     < NDRV_PFIV_I_metadata_line_5_____hdi_gerling assurances sa_20211101 >									
	//        < NKCmP9icPm49NLq23X40KmcvP115901jhjrR9BUQoPm9ApDHmqvBgX7ggoH2Iao4 >									
	//        <  u =="0.000000000000000001" : ] 000000072621016.783693500000000000 ; 000000088296979.966481000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006ECF9686BB02 >									
	//     < NDRV_PFIV_I_metadata_line_6_____hdi_gerling firmen und privat versicherung ag_20211101 >									
	//        < rlWY7egBvBO3FJy4yy0iBIi907PJpKH8e6oJ3p35v3JgEjo7A53fJQZ2x8eVBwAC >									
	//        <  u =="0.000000000000000001" : ] 000000088296979.966481000000000000 ; 000000113530158.334938000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000086BB02AD3BB8 >									
	//     < NDRV_PFIV_I_metadata_line_7_____ooo strakhovaya kompaniya civ life_20211101 >									
	//        < 6939qA2utUp2RrnwQ4A8cpQs4s6Z5p8WLR7JLyo9KIbGO8q9B3185Tn3kOCj4RFn >									
	//        <  u =="0.000000000000000001" : ] 000000113530158.334938000000000000 ; 000000135908238.411317000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AD3BB8CF6128 >									
	//     < NDRV_PFIV_I_metadata_line_8_____inversiones magallanes sa_20211101 >									
	//        < 7VojVr91j5i3i58WPwCOOiMyq0aUahm0914CtzrFlQe2d4f5S914Bm1yT82mmrUk >									
	//        <  u =="0.000000000000000001" : ] 000000135908238.411317000000000000 ; 000000156726358.489743000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CF6128EF253C >									
	//     < NDRV_PFIV_I_metadata_line_9_____hdi seguros de vida sa_20211101 >									
	//        < j0K5e77u52FsFuAuJ1FRN208QJtscn0cKyp6sn817U6T5rWMPx2I3tYlEV322xa8 >									
	//        <  u =="0.000000000000000001" : ] 000000156726358.489743000000000000 ; 000000175580138.222440000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EF253C10BE9FE >									
	//     < NDRV_PFIV_I_metadata_line_10_____winsor verwaltungs_ag_20211101 >									
	//        < jGq61feSiVyFfHzOpvB2FSGkEVgM6P2RPOMZ6Ggc3m96eTqBm1u69N8LPz6YA0xI >									
	//        <  u =="0.000000000000000001" : ] 000000175580138.222440000000000000 ; 000000192159414.763105000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010BE9FE1253645 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIV_I_metadata_line_11_____gerling_konzern globale rückversicherungs_ag_20211101 >									
	//        < 83FhB5ds1JobC1UG7Y7ul7DGpvloOSd9P0z0VcL1ARg2j77ix5Agfaf2f8DFz3IB >									
	//        <  u =="0.000000000000000001" : ] 000000192159414.763105000000000000 ; 000000217734256.768988000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000125364514C3C72 >									
	//     < NDRV_PFIV_I_metadata_line_12_____gerling gfp verwaltungs_ag_20211101 >									
	//        < QJeuoamK0wGhGwu7g0Od6f48p5UaZZjWLpiJK7iWmG93f5TplOL10inadWZ2wYex >									
	//        <  u =="0.000000000000000001" : ] 000000217734256.768988000000000000 ; 000000237525075.265234000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014C3C7216A6F3C >									
	//     < NDRV_PFIV_I_metadata_line_13_____hdi kundenservice ag_20211101 >									
	//        < 4P036xxx5N53d7OS7Em0mdarJa3p3vP5c0Iw9I3J1jdU857jFGv0x3d7U3cUp0BO >									
	//        <  u =="0.000000000000000001" : ] 000000237525075.265234000000000000 ; 000000261816927.167926000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016A6F3C18F803D >									
	//     < NDRV_PFIV_I_metadata_line_14_____beteiligungs gmbh co kg_20211101 >									
	//        < G40wB5M5BT85HV9h6RZfwFUD3wt8j971d40dtmfCPM6xS3cVr5oGxiDkPCRAimC0 >									
	//        <  u =="0.000000000000000001" : ] 000000261816927.167926000000000000 ; 000000283092251.191166000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018F803D1AFF6E9 >									
	//     < NDRV_PFIV_I_metadata_line_15_____talanx reinsurance broker gmbh_20211101 >									
	//        < 9uz9H6u7iWLQcP09Nmk81QraJafXiHKCd5hl9KhY5Xq8797ACawyMRTO881s2OsK >									
	//        <  u =="0.000000000000000001" : ] 000000283092251.191166000000000000 ; 000000296180547.786544000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AFF6E91C3EF87 >									
	//     < NDRV_PFIV_I_metadata_line_16_____neue leben holding ag_20211101 >									
	//        < gW5ozGSu8C59mJO3AiU3g81kIH09lrF5a4W2wg0J72SnzCrttd3a74b07ueeu49E >									
	//        <  u =="0.000000000000000001" : ] 000000296180547.786544000000000000 ; 000000311945225.201886000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C3EF871DBFD9B >									
	//     < NDRV_PFIV_I_metadata_line_17_____neue leben unfallversicherung ag_20211101 >									
	//        < pH2Vg2tyg8a4CSU6780OY2I5be9TT1Wge90gE8ZDYWueBnLE0i3nTuMx2Nbawb3d >									
	//        <  u =="0.000000000000000001" : ] 000000311945225.201886000000000000 ; 000000328835580.463624000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DBFD9B1F5C366 >									
	//     < NDRV_PFIV_I_metadata_line_18_____neue leben lebensversicherung ag_20211101 >									
	//        < cvZKc0j7QW34kR058QPzrYTxim12K1dI4igq9p3KZZWE8u4kBG7SpQ5BTmF9mjJR >									
	//        <  u =="0.000000000000000001" : ] 000000328835580.463624000000000000 ; 000000353308219.389432000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F5C36621B1B06 >									
	//     < NDRV_PFIV_I_metadata_line_19_____pb versicherung ag_20211101 >									
	//        < xe993npNV7a5fGB8a6394iN078GASy5xlrf3ggd2YGG1ZYZGf5S58nc3TIsGV58W >									
	//        <  u =="0.000000000000000001" : ] 000000353308219.389432000000000000 ; 000000368471933.593689000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021B1B062323E59 >									
	//     < NDRV_PFIV_I_metadata_line_20_____talanx systeme ag_20211101 >									
	//        < ii072Cui9b879Qcfd23G1t4Ddh189aasMi39BJAomoWaK83lpoF2X1t3zKrLJdp1 >									
	//        <  u =="0.000000000000000001" : ] 000000368471933.593689000000000000 ; 000000385986046.980859000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002323E5924CF7CD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIV_I_metadata_line_21_____hdi seguros sa_20211101 >									
	//        < sw56o7lvi92k9WifnSdlo21hj8h79pqU5mCTr2Jeir8Fkjh5T54G0pij2p716l5o >									
	//        <  u =="0.000000000000000001" : ] 000000385986046.980859000000000000 ; 000000402103324.458131000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024CF7CD2658F9C >									
	//     < NDRV_PFIV_I_metadata_line_22_____talanx nassau assekuranzkontor gmbh_20211101 >									
	//        < MNbpFZ6XtVmY2HTJn96Wd6O9QUqPOyDc52ucuj0h8Fs5q08uw0qQhEu5L2T36QdQ >									
	//        <  u =="0.000000000000000001" : ] 000000402103324.458131000000000000 ; 000000419993041.063351000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002658F9C280DBC8 >									
	//     < NDRV_PFIV_I_metadata_line_23_____td real assets gmbh co kg_20211101 >									
	//        < Q73D0H5BFHJiJIha3xjbvlVrLgZlBE3yLX9o47BohMQHN2cA7TcddIR6173LF8fG >									
	//        <  u =="0.000000000000000001" : ] 000000419993041.063351000000000000 ; 000000441050004.713596000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000280DBC82A0FD28 >									
	//     < NDRV_PFIV_I_metadata_line_24_____partner office ag_20211101 >									
	//        < zu0WQlTem2a5e62qS3Ox3TaoH6P9Suz7MFqy28HuwlT469T8Kiqktk6euK20KxgQ >									
	//        <  u =="0.000000000000000001" : ] 000000441050004.713596000000000000 ; 000000456742662.712912000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A0FD282B8EF1A >									
	//     < NDRV_PFIV_I_metadata_line_25_____hgi alternative investments beteiligungs_gmbh co kg_20211101 >									
	//        < 0mT9eEtbRoUgyo5wD2G8y5oHX1667l3SXoQFscAnfF1Z5Jk78E42cuR23G9HOVs5 >									
	//        <  u =="0.000000000000000001" : ] 000000456742662.712912000000000000 ; 000000482292605.836811000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B8EF1A2DFEB8D >									
	//     < NDRV_PFIV_I_metadata_line_26_____ferme eolienne du mignaudières sarl_20211101 >									
	//        < O929L8NOSQkjFt14YizUHT0lVy3W3bfCHoCEWAT8J7n8bWwB0f9j3E17Qg6c61Nm >									
	//        <  u =="0.000000000000000001" : ] 000000482292605.836811000000000000 ; 000000501256318.792082000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DFEB8D2FCDB40 >									
	//     < NDRV_PFIV_I_metadata_line_27_____talanx ag asset management arm_20211101 >									
	//        < whh4H2c818FRo3UIX1af0QC6ojIX5joP6sij627O3Vmsw078anbJSgWV6zNkRGaT >									
	//        <  u =="0.000000000000000001" : ] 000000501256318.792082000000000000 ; 000000523813328.117842000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FCDB4031F4695 >									
	//     < NDRV_PFIV_I_metadata_line_28_____talanx bureau für versicherungswesen robert gerling & co gmbh_20211101 >									
	//        < ARI3I4X7ECA8e51W8PwTSN4MWSC3FD0rcu6e530Scv2o1uz3cKQlp4OCRCDgG6TT >									
	//        <  u =="0.000000000000000001" : ] 000000523813328.117842000000000000 ; 000000538763833.639200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031F4695336169F >									
	//     < NDRV_PFIV_I_metadata_line_29_____pb pensionskasse aktiengesellschaft_20211101 >									
	//        < 274p358JH6E9t46Ynn4W42uIig9SZG56CPF82Ok54OuW62OqwbKPS8J9CS0bjB4x >									
	//        <  u =="0.000000000000000001" : ] 000000538763833.639200000000000000 ; 000000561668655.668540000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000336169F35909D2 >									
	//     < NDRV_PFIV_I_metadata_line_30_____hdi direkt service gmbh_20211101 >									
	//        < 0sZSr8e09m3mDvjZV5kf0oaZ4mGJNnvWqdQjk8mWh07hD82zKF4Ntr2dTse4uZd9 >									
	//        <  u =="0.000000000000000001" : ] 000000561668655.668540000000000000 ; 000000575770652.775743000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035909D236E8E69 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIV_I_metadata_line_31_____gerling immo spezial 1_20211101 >									
	//        < kyz0aPf94XdS6163K4HK916O90W427J0HKKauzh0YgDwa1voJ3cVa7UQd3D74Y3L >									
	//        <  u =="0.000000000000000001" : ] 000000575770652.775743000000000000 ; 000000593939724.949452000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036E8E6938A47B4 >									
	//     < NDRV_PFIV_I_metadata_line_32_____gente compania de soluciones profesionales de mexico sa de cv_20211101 >									
	//        < iREd0aIi17a8tG3tzm8r0gvYFR1bDocf5317Wr2PxkJxt423f0ZgMp7IfSeVas6g >									
	//        <  u =="0.000000000000000001" : ] 000000593939724.949452000000000000 ; 000000610653710.665238000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038A47B43A3C89B >									
	//     < NDRV_PFIV_I_metadata_line_33_____credit life international versicherung ag_20211101 >									
	//        < S0dEBS14aF18uU167300B19tQSiLeMzvED3xafPPyfkPZN3QsDgE4Riwu5S2SX8I >									
	//        <  u =="0.000000000000000001" : ] 000000610653710.665238000000000000 ; 000000629283317.819977000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A3C89B3C035CC >									
	//     < NDRV_PFIV_I_metadata_line_34_____talanx pensionsmanagement ag_20211101 >									
	//        < x00J79YyQUNOkFD4bzNWv2WCQ2aVY7xc3kVFoZf4T7vY1U3g6ydA0d8k6GC1NtlD >									
	//        <  u =="0.000000000000000001" : ] 000000629283317.819977000000000000 ; 000000649189890.200129000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C035CC3DE95CD >									
	//     < NDRV_PFIV_I_metadata_line_35_____talanx infrastructure portugal 2 gmbh_20211101 >									
	//        < 98Ofqq25uGS887rf7e13JoVZj98y9K90H5WUN5q62WZZrGJuG7K4K9r57Rw7B76A >									
	//        <  u =="0.000000000000000001" : ] 000000649189890.200129000000000000 ; 000000668893998.125886000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DE95CD3FCA6B8 >									
	//     < NDRV_PFIV_I_metadata_line_36_____pnh parque do novo hospital sa_20211101 >									
	//        < 82B3xisG969lJ9zA0R1tKE4k2U35148Pn59X5qFNWcY92I008X81a6Ip23ToEht1 >									
	//        <  u =="0.000000000000000001" : ] 000000668893998.125886000000000000 ; 000000694290195.055875000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FCA6B8423671C >									
	//     < NDRV_PFIV_I_metadata_line_37_____aberdeen infrastructure holdco bv_20211101 >									
	//        < 4FcKKc8IW4W0f1zeukWcG6ffW3EGiqdcy7tiMPPcR48yfs484NZp9pDgz97pAE2F >									
	//        <  u =="0.000000000000000001" : ] 000000694290195.055875000000000000 ; 000000713869849.675733000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000423671C4414769 >									
	//     < NDRV_PFIV_I_metadata_line_38_____escala vila franca sociedade gestora do edifício sa_20211101 >									
	//        < J2tF3c848W5q2O7Mhs96QRreCm8p1Upxn07ys81n8IKE97NjjaKkM3pkC4QRuBa8 >									
	//        <  u =="0.000000000000000001" : ] 000000713869849.675733000000000000 ; 000000738115203.332642000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044147694664640 >									
	//     < NDRV_PFIV_I_metadata_line_39_____pnh parque do novo hospital sa_20211101 >									
	//        < Use7HtO9cyWlAU33i2egE9YdwrZCajXiN3yePK6D1iEU30YF41fU9bIVH0446NhC >									
	//        <  u =="0.000000000000000001" : ] 000000738115203.332642000000000000 ; 000000757628469.167843000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046646404840C9F >									
	//     < NDRV_PFIV_I_metadata_line_40_____tunz warta sa_20211101 >									
	//        < g2D1S7iABiQhdmUhDABk48fu4XFB9rS7y3IL4v5iJBzfrN2xW26K9Jq2idkdaVqo >									
	//        <  u =="0.000000000000000001" : ] 000000757628469.167843000000000000 ; 000000777476110.514566000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004840C9F4A2559B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}