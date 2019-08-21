pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFVII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFVII_I_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFVII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		574167219425869000000000000					;	
										
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
	//     < CHEMCHINA_PFVII_I_metadata_line_1_____Taizhou_Creating_Chemical_Co_Limited_20220321 >									
	//        < tZSXb7Hvv01BuY8L853OJuhLCKmrW15Q70SCoIm3jqo96H2D062z01hseJZb0hVv >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000012832143.844479100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000013948E >									
	//     < CHEMCHINA_PFVII_I_metadata_line_2_____Tetrahedron_Scientific_Inc_20220321 >									
	//        < b433tnPEbOA6MSmUl3F85Qv9C29zIbu889iFztx4i7kXw2799oZl88DFW44Tb4X3 >									
	//        <  u =="0.000000000000000001" : ] 000000012832143.844479100000000000 ; 000000027999651.326964800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000013948E2AB95D >									
	//     < CHEMCHINA_PFVII_I_metadata_line_3_____Tianjin_Boai_NKY_International_Limited_20220321 >									
	//        < 1ZPpxuGuJGusStn3qvvK09qVzISMkqxYtY0yNr30RnL8c1x060y6r19EV4zH4xSH >									
	//        <  u =="0.000000000000000001" : ] 000000027999651.326964800000000000 ; 000000042284436.741502100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002AB95D40855C >									
	//     < CHEMCHINA_PFVII_I_metadata_line_4_____Tianjin_Boron_PharmaTech_Co__Limited_20220321 >									
	//        < Y4P6iY6m8O15l21Xrj3695rwFG1M5qaBrJB721zvOcq77N3j57jZ5qEP67OYEED5 >									
	//        <  u =="0.000000000000000001" : ] 000000042284436.741502100000000000 ; 000000058593284.849375600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000040855C596800 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_5_____TianJin_HuiQuan_Chemical_Industry_Co_Limited_20220321 >									
	//        < pZ6BuPQ96FY4nCKaOfQzV4I284s56ytonz1RYIaUuakkxas2IGLTVO7xKYMQPzZv >									
	//        <  u =="0.000000000000000001" : ] 000000058593284.849375600000000000 ; 000000073851259.866473700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000059680070B026 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_6_____Tianjin_McEIT_Co_Limited_20220321 >									
	//        < 8gp593De90HNexx7PFa1BjljukazVCFlGM76s7fsLYWRikxIc422I878YP26lL9i >									
	//        <  u =="0.000000000000000001" : ] 000000073851259.866473700000000000 ; 000000087557158.622290000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000070B026859A04 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_7_____Tianjin_Norland_Biotech_org_20220321 >									
	//        < BRYFPL7q0zuL0ccnmTfyLe8Ng33Jk7L34o97ICc96cHoXgrn0i2G1wN4Pr8qP9kv >									
	//        <  u =="0.000000000000000001" : ] 000000087557158.622290000000000000 ; 000000100218963.260173000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000859A0498EC08 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_8_____Tianjin_Norland_Biotech_Co_Limited_20220321 >									
	//        < k5QzIa2lws4f4o8JR8ZN5iX06oy3YfL5MrbwaTwKYMcL3YQg1Qh6tjE2g3PG7s52 >									
	//        <  u =="0.000000000000000001" : ] 000000100218963.260173000000000000 ; 000000116345389.025319000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000098EC08B1876B >									
	//     < CHEMCHINA_PFVII_I_metadata_line_9_____Tianjin_Tiandingren_Technology_Co_Limited_20220321 >									
	//        < j9H3qakcw87Itv6C5fhPWTO820oF0RE417pbl2X3beja45609stna8HKwXISl40M >									
	//        <  u =="0.000000000000000001" : ] 000000116345389.025319000000000000 ; 000000132607669.984398000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B1876BCA57DF >									
	//     < CHEMCHINA_PFVII_I_metadata_line_10_____TOP_FINE_CHEM_20220321 >									
	//        < 7Lkj0Nkw2sUaCX7T2ose5L6zm6tV8uAEAKA3RR8T19Lknb669FLzAf3g3c0nxV6i >									
	//        <  u =="0.000000000000000001" : ] 000000132607669.984398000000000000 ; 000000145387860.124293000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CA57DFDDD822 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVII_I_metadata_line_11_____Trust_We_Co__Limited_20220321 >									
	//        < e6apG38pbw30U7Pye58m8n988eQG04hd02soP6EMLo7PYKX45Js158ju0fEKlH1t >									
	//        <  u =="0.000000000000000001" : ] 000000145387860.124293000000000000 ; 000000159198431.637443000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DDD822F2EAE3 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_12_____Unispec_Chemicals_Co__20220321 >									
	//        < 5ut0arIBzTj4BD9P2wPKW6o435587j032mJLQ0RGj0x69J0ChKHfFUYL6o124WF9 >									
	//        <  u =="0.000000000000000001" : ] 000000159198431.637443000000000000 ; 000000175343745.270895000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F2EAE310B8DA7 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_13_____Varnor_Chemical_Co_Limited_20220321 >									
	//        < SJScHD08GA0K195Oba110wLPYVOK4zHEOUo5rQd4OsHUcX4t8J6EK7KHWrJrRmoY >									
	//        <  u =="0.000000000000000001" : ] 000000175343745.270895000000000000 ; 000000188815728.975720000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010B8DA71201C25 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_14_____VEGSCI,_inc__20220321 >									
	//        < jtcpwG1t7p4rV08NGHf7jNa3F9N6P5gzQMEmH2q66axL7z9XD75ho4dsZ2r7jU6I >									
	//        <  u =="0.000000000000000001" : ] 000000188815728.975720000000000000 ; 000000203572817.165125000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001201C25136A0A2 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_15_____Vesino_Industrial_Co__Limited_20220321 >									
	//        < IGH4Wr0xth2j9ZFq6j11GBxfrE9q4AvBe8JYn4dv8Bq7lJ2Zgy25fyE5l6dxF2Ow >									
	//        <  u =="0.000000000000000001" : ] 000000203572817.165125000000000000 ; 000000217445190.282841000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000136A0A214BCB87 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_16_____Volant_Chem_org_20220321 >									
	//        < bu0lRdkCjLrwur6Qh1RoHD46FERt66z4PPMoNoP67cgw19ky1RoGc6O19djvtXQh >									
	//        <  u =="0.000000000000000001" : ] 000000217445190.282841000000000000 ; 000000233757471.140327000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014BCB87164AF83 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_17_____Volant_Chem_Corp__20220321 >									
	//        < gl89aCiGQa3M66Hs22hRH7d26jm20io0v2H6PF53LU5o03rfuPdDCxyqK6lB622r >									
	//        <  u =="0.000000000000000001" : ] 000000233757471.140327000000000000 ; 000000249071526.223903000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000164AF8317C0D91 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_18_____Win_Win_chemical_Co_Limited_20220321 >									
	//        < ULmwxxJK0svKufzzhPro55nhsPg4QFEi03BHjtx2ol2QKOkbN4w375vhwYnm7JHS >									
	//        <  u =="0.000000000000000001" : ] 000000249071526.223903000000000000 ; 000000264267777.263461000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017C0D911933D9A >									
	//     < CHEMCHINA_PFVII_I_metadata_line_19_____WJF_Chemicals_Co__20220321 >									
	//        < fsa7MrD9ZFzzCJVc196fMovwAQT6KwaCcD0Sdtv5RN8kD70mZF03oO0QxHtJm71A >									
	//        <  u =="0.000000000000000001" : ] 000000264267777.263461000000000000 ; 000000278158767.907587000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001933D9A1A86FC5 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_20_____Wuhan_Bright_Chemical_Co__Limited_20220321 >									
	//        < 0rzB3yh7HRc99epj3am03vOqe5Y2I971c1hKF82KvBj4sX417SF4E70on587i06R >									
	//        <  u =="0.000000000000000001" : ] 000000278158767.907587000000000000 ; 000000291571674.224149000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A86FC51BCE72F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVII_I_metadata_line_21_____Wuhan_Yuancheng_Chemical_Manufactory_org_20220321 >									
	//        < XoTS0T6I48949WX2xiioW9N6pgKru4y3rgeJoO55kDBIxT8YagR3QC6i574VsFuN >									
	//        <  u =="0.000000000000000001" : ] 000000291571674.224149000000000000 ; 000000303978940.144320000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BCE72F1CFD5C6 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_22_____Wuhan_Yuancheng_Chemical_Manufactory_20220321 >									
	//        < S8u00Yq38j9t2L7Q2Rj96ebjwjLeefbfNXfs7ToT1v2Yrx98T0p11V3PWSG92OjZ >									
	//        <  u =="0.000000000000000001" : ] 000000303978940.144320000000000000 ; 000000316713840.752036000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CFD5C61E34458 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_23_____Wuhu_Foman_Biopharma_Co_Limited_20220321 >									
	//        < v6Pv1EVjrN5L6wp91499rv2zLG8kq7Ythdg8VY4dQ8A44f5DSoy8w79aMJ9U48y4 >									
	//        <  u =="0.000000000000000001" : ] 000000316713840.752036000000000000 ; 000000332934323.628757000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E344581FC0478 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_24_____Xi_an_Caijing_Opto_Electrical_Science___Technology_Co__Limited_20220321 >									
	//        < Bbl5txGp80TbrFjv44PU46h8hnq89qP8HI5QgMNRR3BV3qR10zEzzGQq7p8033rb >									
	//        <  u =="0.000000000000000001" : ] 000000332934323.628757000000000000 ; 000000348492593.601768000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FC0478213C1EB >									
	//     < CHEMCHINA_PFVII_I_metadata_line_25_____XIAMEN_EQUATION_CHEMICAL_org_20220321 >									
	//        < 586b3WtMrTu7s6VoxXYB0bZbdjguC7wh3AyS3l0969T8L2F7qo320hvPhDhnZEaL >									
	//        <  u =="0.000000000000000001" : ] 000000348492593.601768000000000000 ; 000000361187590.186482000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000213C1EB22720E7 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_26_____XIAMEN_EQUATION_CHEMICAL_Co_Limited_20220321 >									
	//        < es28842J9gP1oPMD0HVX8AbgiPzOZ453vl384O7dRFRrQfFN0t31O52x5tqp33gJ >									
	//        <  u =="0.000000000000000001" : ] 000000361187590.186482000000000000 ; 000000374719989.057514000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022720E723BC6FF >									
	//     < CHEMCHINA_PFVII_I_metadata_line_27_____Yacoo_Chemical_Reagent_Co_Limited_20220321 >									
	//        < 292E0MLu27yCn6l2MJp877m8Z89HnMpYPyZU8394XYp471d1D500RlpfzO4VmXCx >									
	//        <  u =="0.000000000000000001" : ] 000000374719989.057514000000000000 ; 000000387269016.847468000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023BC6FF24EECF6 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_28_____Yantai_Taroke_Bio_engineering_Co_Limited_20220321 >									
	//        < Y25un23qA1Cvp34cfAr22lp8C2294H6a30o04zI4L5KV6WNW7MmW31fmQQjy5T82 >									
	//        <  u =="0.000000000000000001" : ] 000000387269016.847468000000000000 ; 000000401901766.232141000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024EECF626540E1 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_29_____Zehao_Industry_Co__Limited_20220321 >									
	//        < 3oDyf6lJcOLDvi143auV11AQNqWo6HDA70x33IVxD666QM6I2Birk2Wlm20E3eGQ >									
	//        <  u =="0.000000000000000001" : ] 000000401901766.232141000000000000 ; 000000414356290.116480000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026540E127841ED >									
	//     < CHEMCHINA_PFVII_I_metadata_line_30_____Zeroschem_org_20220321 >									
	//        < 0vl218sC10NhMvQ8B9P75nXD7szJ4klFUw8K5qur53er6z27M70158shBKqK5LxY >									
	//        <  u =="0.000000000000000001" : ] 000000414356290.116480000000000000 ; 000000427903587.894231000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027841ED28CEDD7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVII_I_metadata_line_31_____Zeroschem_Co_Limited_20220321 >									
	//        < CXybtr2AcIFgb8q43vBfS4Xf192GRvL9eO3V9Z6hzJ6p8rvBm9obS7FhF1L4xS04 >									
	//        <  u =="0.000000000000000001" : ] 000000427903587.894231000000000000 ; 000000442947411.985212000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028CEDD72A3E255 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_32_____ZHANGJIAGANG_HUACHANG_PHARMACEUTICAL_Co__Limited_20220321 >									
	//        < aJ1U4B99pEXYJ8l9Ok7o92P8ZkEbbtq8IH8Q27F6o7mlUtpEsZmr3E21m7ZyFQUt >									
	//        <  u =="0.000000000000000001" : ] 000000442947411.985212000000000000 ; 000000457287001.200732000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A3E2552B9C3BC >									
	//     < CHEMCHINA_PFVII_I_metadata_line_33_____Zheda_Panaco_Chemical_Engineering_Co___Ltd___ZhedaChem__20220321 >									
	//        < KW8939b4c4Zm0ZLb470O5ZH8up03800jaAC6Y9MnjCvPuCZNQEDz0294O3AS5h2c >									
	//        <  u =="0.000000000000000001" : ] 000000457287001.200732000000000000 ; 000000473170610.915617000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B9C3BC2D20045 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_34_____Zhejiang_J_C_Biological_Technology_Co_Limited_20220321 >									
	//        < 13Jq2pHgUX1ktQXeDsSp1aKg2VXo3lRaN19e3LY7vFSfPumbVy2n12MzpZvYn931 >									
	//        <  u =="0.000000000000000001" : ] 000000473170610.915617000000000000 ; 000000487777711.740377000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D200452E84A2B >									
	//     < CHEMCHINA_PFVII_I_metadata_line_35_____Zhengzhou_Meitong_Pharmaceutical_Technology_20220321 >									
	//        < 45lliHkA6l003fcGBUCHqCC8K69j94pWJSqHmzPt0VS2t9ZZ0P1p8n7VT5H2xt32 >									
	//        <  u =="0.000000000000000001" : ] 000000487777711.740377000000000000 ; 000000503185900.594993000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E84A2B2FFCCFE >									
	//     < CHEMCHINA_PFVII_I_metadata_line_36_____ZHIWE_ChemTech_org_20220321 >									
	//        < 2IPsSjoEs3fW1Gu5A4fMo7lQJls7fg44KRyh715g1C6CyrTI1N3967J7A603o60G >									
	//        <  u =="0.000000000000000001" : ] 000000503185900.594993000000000000 ; 000000518238715.526291000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FFCCFE316C500 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_37_____ZHIWE_ChemTech_Co_Limited_20220321 >									
	//        < tWQwGy3qy693p054JuVunMUd66jum7d2ilv82Vy7aYr9XdL9efqp25u0H8t50g8I >									
	//        <  u =="0.000000000000000001" : ] 000000518238715.526291000000000000 ; 000000533135087.143333000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000316C50032D7FE5 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_38_____Zhongtian_Kosen_Corporation_Limited_20220321 >									
	//        < 6gbs57Cc826g36YvompUyYX3f2c4a4a6bK6TZcB3s2HXo6rKoAIxwUlFZmoyWMjA >									
	//        <  u =="0.000000000000000001" : ] 000000533135087.143333000000000000 ; 000000546232654.215847000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032D7FE53417C21 >									
	//     < CHEMCHINA_PFVII_I_metadata_line_39_____Zibo_Honors_chemical_Co_Limited_20220321 >									
	//        < q311xzBi7393cWL5EY9J8K0rAdTug5HlhyO089j9lSsrWS27b3t791A0x188v73m >									
	//        <  u =="0.000000000000000001" : ] 000000546232654.215847000000000000 ; 000000561450072.072253000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003417C21358B46F >									
	//     < CHEMCHINA_PFVII_I_metadata_line_40_____Zouping_Mingxing_Chemical_Co__Limited_20220321 >									
	//        < u9pVFU7whJ3y83YPBpRgjal01225vhKSdX1gDEB41sDlh8mN1W434m1ge2k07gw6 >									
	//        <  u =="0.000000000000000001" : ] 000000561450072.072253000000000000 ; 000000574167219.425869000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000358B46F36C1C12 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}