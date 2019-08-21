pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXI_I_883		"	;
		string	public		symbol =	"	RUSS_PFXXI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		605069603335981000000000000					;	
										
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
	//     < RUSS_PFXXI_I_metadata_line_1_____EUROCHEM_20211101 >									
	//        < nDRWM59pPXG9sWKoG6IDiAeI07B2W368h6yTrhD63GnB2nqBdABzH3BGT1BtF1ss >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000016110595.504242200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000189534 >									
	//     < RUSS_PFXXI_I_metadata_line_2_____Eurochem_Org_20211101 >									
	//        < G2CV9lH337oBbcWD2V9Z459D8IY50INe0Mf13B1V8Wh1h1lb4Y40xZCw35iTGqTu >									
	//        <  u =="0.000000000000000001" : ] 000000016110595.504242200000000000 ; 000000029472245.923642500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001895342CF899 >									
	//     < RUSS_PFXXI_I_metadata_line_3_____Hispalense_Líquidos_SL_20211101 >									
	//        < 1veW3AM85DXa13y87ZgXcx9lUcN6rMzbpAB28B373H0Teo17FXqsk8DEh39Hx32Z >									
	//        <  u =="0.000000000000000001" : ] 000000029472245.923642500000000000 ; 000000046404661.686044600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002CF89946CED2 >									
	//     < RUSS_PFXXI_I_metadata_line_4_____Azottech_LLC_20211101 >									
	//        < 3IA9002lV6xV1elxqq9FcZWDkWimqEdiIKU3foDJpSc8E0fgq923mI3z0O5P8qwr >									
	//        <  u =="0.000000000000000001" : ] 000000046404661.686044600000000000 ; 000000063423651.107270200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000046CED260C6DD >									
	//     < RUSS_PFXXI_I_metadata_line_5_____Biochem_Technologies_LLC_20211101 >									
	//        < 4RLhpg6u1UQ19k5Ix5o9i904MnD9Gaszdq6z1G3Qq07LL9FoS6wICf2oJ81723HK >									
	//        <  u =="0.000000000000000001" : ] 000000063423651.107270200000000000 ; 000000078301868.763730900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000060C6DD777AAB >									
	//     < RUSS_PFXXI_I_metadata_line_6_____Eurochem_1_Org_20211101 >									
	//        < k27E5s1nP5188P4xCV5dXwu16zOq4m42699k8LlD8Z5e1gylJY7vat1xD59955qP >									
	//        <  u =="0.000000000000000001" : ] 000000078301868.763730900000000000 ; 000000095512653.033391500000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000777AAB91BDA1 >									
	//     < RUSS_PFXXI_I_metadata_line_7_____Eurochem_1_Dao_20211101 >									
	//        < j7606eKMgBL9f5E6nGZ7dz4ynz1REPK3Rpk642IJG8E1002961oOi1Ib5sql2MyH >									
	//        <  u =="0.000000000000000001" : ] 000000095512653.033391500000000000 ; 000000110450067.245517000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000091BDA1A8888F >									
	//     < RUSS_PFXXI_I_metadata_line_8_____Eurochem_1_Daopi_20211101 >									
	//        < kzEDlId1jT7Ia694QRXu25Q754n1giXi6u74mFrQ8asmz1XFC5cRx0CsmziR48N6 >									
	//        <  u =="0.000000000000000001" : ] 000000110450067.245517000000000000 ; 000000127601563.844301000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A8888FC2B45C >									
	//     < RUSS_PFXXI_I_metadata_line_9_____Eurochem_1_Dac_20211101 >									
	//        < I9hOMw8U03xzervN2V43EsYy3xabk5p4Z9ph2N0DXdFyn0tj0v7wZm9nu5meABk6 >									
	//        <  u =="0.000000000000000001" : ] 000000127601563.844301000000000000 ; 000000143068432.325246000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C2B45CDA4E1B >									
	//     < RUSS_PFXXI_I_metadata_line_10_____Eurochem_1_Bimi_20211101 >									
	//        < 92IW77TiXr21QG133Qy2e473VsM5WH6u5Mm34J3m7wQUeEHI112sgb1h5H9VrZ3x >									
	//        <  u =="0.000000000000000001" : ] 000000143068432.325246000000000000 ; 000000157681714.641320000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DA4E1BF09A6B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXI_I_metadata_line_11_____Eurochem_2_Org_20211101 >									
	//        < R2AwBNqPWBP83251465ckV0G280pQAZ6KEiUkw8988ZQ8AbqBswWlvwsET6kXZRu >									
	//        <  u =="0.000000000000000001" : ] 000000157681714.641320000000000000 ; 000000174367170.281268000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F09A6B10A102D >									
	//     < RUSS_PFXXI_I_metadata_line_12_____Eurochem_2_Dao_20211101 >									
	//        < 50qet3KNHHqlAV5AZ4RrOR097ArFq0ewHNeyUH1KT866lv29Z484vn18UGGBs30n >									
	//        <  u =="0.000000000000000001" : ] 000000174367170.281268000000000000 ; 000000187371296.831050000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010A102D11DE7EA >									
	//     < RUSS_PFXXI_I_metadata_line_13_____Eurochem_2_Daopi_20211101 >									
	//        < Yi3IFD88yT3FR0iNR8v7Zk9BNed1KmA9ji3hi7fap1F8E0RkuakmmxrAGi4qG5OL >									
	//        <  u =="0.000000000000000001" : ] 000000187371296.831050000000000000 ; 000000201069733.346227000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011DE7EA132CEDD >									
	//     < RUSS_PFXXI_I_metadata_line_14_____Eurochem_2_Dac_20211101 >									
	//        < 3LS8mRfAPSz7jvJ732yEAia62yA8z45A4756RJ3SHDSOhgQt61y1gn900Dtr0Cj5 >									
	//        <  u =="0.000000000000000001" : ] 000000201069733.346227000000000000 ; 000000216677313.608643000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000132CEDD14A9F93 >									
	//     < RUSS_PFXXI_I_metadata_line_15_____Eurochem_2_Bimi_20211101 >									
	//        < 591zlJ0x9BsQtW88OaPewBF45KYCC7zz79UaTFdcbRvlR82BT836fYYawTecK17L >									
	//        <  u =="0.000000000000000001" : ] 000000216677313.608643000000000000 ; 000000232505926.630920000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014A9F93162C6A1 >									
	//     < RUSS_PFXXI_I_metadata_line_16_____Melni_1_Org_20211101 >									
	//        < 5MkcQJ1dFUs88fWpfobytcMolUJXG6Gku5959YMf6iiV8rmgoBYG22u8yxT57456 >									
	//        <  u =="0.000000000000000001" : ] 000000232505926.630920000000000000 ; 000000247596467.849797000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000162C6A1179CD5F >									
	//     < RUSS_PFXXI_I_metadata_line_17_____Melni_1_Dao_20211101 >									
	//        < 680925ESf9CEGczQqhF4cOYPU5GG74JYM7J2545Uh0II770138d3E5k4lDd08uJ1 >									
	//        <  u =="0.000000000000000001" : ] 000000247596467.849797000000000000 ; 000000262136169.717443000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000179CD5F18FFCF1 >									
	//     < RUSS_PFXXI_I_metadata_line_18_____Melni_1_Daopi_20211101 >									
	//        < 4239Phac0H4C0S1ZtkUBj8g5G7tbYeGpW63aK9C68ONA9aL8DA2G8gIz0sgNEP3x >									
	//        <  u =="0.000000000000000001" : ] 000000262136169.717443000000000000 ; 000000278394737.484621000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018FFCF11A8CBF2 >									
	//     < RUSS_PFXXI_I_metadata_line_19_____Melni_1_Dac_20211101 >									
	//        < L179HbLMX9PaMk06AMBc4YiwUGQ7gmohJEoA77Tb07I1SC389Nh9jKXwpT0U11F3 >									
	//        <  u =="0.000000000000000001" : ] 000000278394737.484621000000000000 ; 000000293129197.298558000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A8CBF21BF4798 >									
	//     < RUSS_PFXXI_I_metadata_line_20_____Melni_1_Bimi_20211101 >									
	//        < 3V5M16D9WkXPl9X0f50mvW55dxeOQpa13kmdE6d7e9fSoU71BGbN9074r08WCXwd >									
	//        <  u =="0.000000000000000001" : ] 000000293129197.298558000000000000 ; 000000306295399.283295000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BF47981D35EA4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXI_I_metadata_line_21_____Melni_2_Org_20211101 >									
	//        < w7jkLZ11u552z4hxz6Kqt1V1D3SCOvJ5Pq5UE3IRC1Ni7pYeZTWKM18TJvZsT7Uu >									
	//        <  u =="0.000000000000000001" : ] 000000306295399.283295000000000000 ; 000000319827145.948163000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D35EA41E8047B >									
	//     < RUSS_PFXXI_I_metadata_line_22_____Melni_2_Dao_20211101 >									
	//        < 59Ol6H5B6QFv06005mB4rFkuQcz559S50qe5yClh4gS4AfM1cJI2jHl9494862Ce >									
	//        <  u =="0.000000000000000001" : ] 000000319827145.948163000000000000 ; 000000335540551.268178000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E8047B1FFFE87 >									
	//     < RUSS_PFXXI_I_metadata_line_23_____Melni_2_Daopi_20211101 >									
	//        < 3lh61Vn5O9LhsaV34ar5Ul17dOwf7i9W17fnoq4MJ0M55bBNRkTnvy24W3gtCr5Y >									
	//        <  u =="0.000000000000000001" : ] 000000335540551.268178000000000000 ; 000000352099021.567141000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FFFE8721942AE >									
	//     < RUSS_PFXXI_I_metadata_line_24_____Melni_2_Dac_20211101 >									
	//        < At98I29s29FRFClNq7hnDc1Ib7Nchd3V2TEvtFI3a0ronUEQgt77nPWNY4uowm25 >									
	//        <  u =="0.000000000000000001" : ] 000000352099021.567141000000000000 ; 000000366335133.392957000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021942AE22EFBA9 >									
	//     < RUSS_PFXXI_I_metadata_line_25_____Melni_2_Bimi_20211101 >									
	//        < k9f395G9PlVb52XCF2rx3BFH9uUjyY558tpop86E5fezV0WLuB2DtbR699J8DoIp >									
	//        <  u =="0.000000000000000001" : ] 000000366335133.392957000000000000 ; 000000380731405.900228000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022EFBA9244F335 >									
	//     < RUSS_PFXXI_I_metadata_line_26_____Lifosa_Ab_Org_20211101 >									
	//        < 2050H0r9PjSQ9tjRfj74jC6JOYkr2U2b5xxuR0JDv4CE4ZFdBDDw591r0ozN53Yu >									
	//        <  u =="0.000000000000000001" : ] 000000380731405.900228000000000000 ; 000000397136904.120959000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000244F33525DFB9A >									
	//     < RUSS_PFXXI_I_metadata_line_27_____Lifosa_Ab_Dao_20211101 >									
	//        < IOeGgf6NclxyfbIBMg05q1849yd74500W174ipDyFj50q96B1jo374gPiXFfFG3j >									
	//        <  u =="0.000000000000000001" : ] 000000397136904.120959000000000000 ; 000000412911489.050695000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025DFB9A2760D8D >									
	//     < RUSS_PFXXI_I_metadata_line_28_____Lifosa_Ab_Daopi_20211101 >									
	//        < o2m7yK0cXf7ZrucWYT33WV6xKmKR6KhVwAMuX247gr42TxfQE1803gy8NmjQduk7 >									
	//        <  u =="0.000000000000000001" : ] 000000412911489.050695000000000000 ; 000000429992672.891664000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002760D8D2901DE3 >									
	//     < RUSS_PFXXI_I_metadata_line_29_____Lifosa_Ab_Dac_20211101 >									
	//        < 13O0VOpDIn2915zb7554Nk7P6btciyvK3732Q0eov1FRs4n1mN8616BzKrF1262u >									
	//        <  u =="0.000000000000000001" : ] 000000429992672.891664000000000000 ; 000000445021188.653083000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002901DE32A70C67 >									
	//     < RUSS_PFXXI_I_metadata_line_30_____Lifosa_Ab_Bimi_20211101 >									
	//        < w5Oq7s7KR1g22VQB79akkRjtCo2K9X2L789Ro40XFOn19J7PD3X7kqv9k619Ef77 >									
	//        <  u =="0.000000000000000001" : ] 000000445021188.653083000000000000 ; 000000460016789.675259000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A70C672BDEE0F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXI_I_metadata_line_31_____Azot_Ab_1_Org_20211101 >									
	//        < Hq9gHOzYLv2Kk0C3243CHNwlzwZ5M2YDAyIqJS9uiC04Olt591U7aw6VfvIOq58B >									
	//        <  u =="0.000000000000000001" : ] 000000460016789.675259000000000000 ; 000000476197344.292022000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BDEE0F2D69E96 >									
	//     < RUSS_PFXXI_I_metadata_line_32_____Azot_Ab_1_Dao_20211101 >									
	//        < uK7qmtu6VTYk5nQ0W3sjY647A0uqj1tr2yyh4hw4pl461N62Jl1FWmvt9t38OBth >									
	//        <  u =="0.000000000000000001" : ] 000000476197344.292022000000000000 ; 000000490486857.731439000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D69E962EC6C6E >									
	//     < RUSS_PFXXI_I_metadata_line_33_____Azot_Ab_1_Daopi_20211101 >									
	//        < 4rD0nlf9UHH51P6bpnGalF6S0mhXfn7k8U3OQ238U0a6s246Y55TByGm8T79Fstg >									
	//        <  u =="0.000000000000000001" : ] 000000490486857.731439000000000000 ; 000000504145362.624490000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EC6C6E30143C8 >									
	//     < RUSS_PFXXI_I_metadata_line_34_____Azot_Ab_1_Dac_20211101 >									
	//        < KB1gQmQ96fOcGcBIFm303S79JJXx4CXHGM4HRRrjd4g9fHTYcEMYi5WI9T1tb9EB >									
	//        <  u =="0.000000000000000001" : ] 000000504145362.624490000000000000 ; 000000517834317.495934000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030143C83162708 >									
	//     < RUSS_PFXXI_I_metadata_line_35_____Azot_Ab_1_Bimi_20211101 >									
	//        < nQvL7iZIVW1FDfqZibRUnt5bYhUG55Ivo6L539oyL4tPFGCDSW187v7gqL3T3mIa >									
	//        <  u =="0.000000000000000001" : ] 000000517834317.495934000000000000 ; 000000531198093.428824000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000316270832A8B41 >									
	//     < RUSS_PFXXI_I_metadata_line_36_____Azot_Ab_2_Org_20211101 >									
	//        < Of65J8BJAIAZk8xkiO1OKFu2224G4MfFNQ968EB8324b3981J2a6FvdR2a1455GZ >									
	//        <  u =="0.000000000000000001" : ] 000000531198093.428824000000000000 ; 000000548080219.943078000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032A8B413444DD6 >									
	//     < RUSS_PFXXI_I_metadata_line_37_____Azot_Ab_2_Dao_20211101 >									
	//        < p905URomDVcT8H4bPJ1lbpGtib0A4S8m9rH2Dk5lN8W18P0yX39ros5hOcH7riOQ >									
	//        <  u =="0.000000000000000001" : ] 000000548080219.943078000000000000 ; 000000562772172.505926000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003444DD635AB8E1 >									
	//     < RUSS_PFXXI_I_metadata_line_38_____Azot_Ab_2_Daopi_20211101 >									
	//        < 8VT7a6LDU3VJ045w6p7n1ObtWf7W872HSVw53Z3FVmb5s9pQPSM20OQBI295CE0b >									
	//        <  u =="0.000000000000000001" : ] 000000562772172.505926000000000000 ; 000000576226434.597916000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035AB8E136F4073 >									
	//     < RUSS_PFXXI_I_metadata_line_39_____Azot_Ab_2_Dac_20211101 >									
	//        < 3gUyBTTmg1a21HW60mS8H9H58yW7dHsCk8fe9tCEAS745Rjc9H3OW716Ie6Q7d19 >									
	//        <  u =="0.000000000000000001" : ] 000000576226434.597916000000000000 ; 000000591103107.152590000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036F4073385F3A7 >									
	//     < RUSS_PFXXI_I_metadata_line_40_____Azot_Ab_2_Bimi_20211101 >									
	//        < K7IP90f9q8J9ZMQ590cWlY9pa9o2W677qzP70MjV5ByK3g323A3MaX75Gfzpf29H >									
	//        <  u =="0.000000000000000001" : ] 000000591103107.152590000000000000 ; 000000605069603.335981000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000385F3A739B4350 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}