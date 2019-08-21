pragma solidity 		^0.4.25	;						
										
	contract	CHEMCHINA_PFVI_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	CHEMCHINA_PFVI_III_883		"	;
		string	public		symbol =	"	CHEMCHINA_PFVI_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		935185536382745000000000000					;	
										
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
	//     < CHEMCHINA_PFVI_III_metadata_line_1_____Shanghai_PI_Chemicals_Limited_20260321 >									
	//        < 1tx9V5HlT3D9sBcrLO9274xVH26cMHPN95pa8ohQU627W17pToaXioP2oVyW359Q >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000023646194.024831300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000002414CB >									
	//     < CHEMCHINA_PFVI_III_metadata_line_2_____Shanghai_PI_Chemicals_Limited_20260321 >									
	//        < 37DVU7EVdv73Qz2657jxLj57Y4uouW37Fe7FUbAa7qouJP5KGA5nslT8sbg7lrb8 >									
	//        <  u =="0.000000000000000001" : ] 000000023646194.024831300000000000 ; 000000045218513.027662900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002414CB44FF7B >									
	//     < CHEMCHINA_PFVI_III_metadata_line_3_____Shanghai_Race_Chemical_Co_Limited_20260321 >									
	//        < uOgMuUkQxNF3zgC7WX4SgoW7RIiuxPTEql1h10mQxrwjGnyOa39iV768B04eU068 >									
	//        <  u =="0.000000000000000001" : ] 000000045218513.027662900000000000 ; 000000067857362.802325600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000044FF7B678AC8 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_4_____Shanghai_Sinch_Parmaceuticals_Tech__Co__Limited_20260321 >									
	//        < 4vX3LUv385SZMvv5w7Q3Tp2a9OHEh6398vWdA9Qgm2k6qlXI7i9hM6T7l6p9Crn4 >									
	//        <  u =="0.000000000000000001" : ] 000000067857362.802325600000000000 ; 000000089104465.302578400000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000678AC887F66F >									
	//     < CHEMCHINA_PFVI_III_metadata_line_5_____Shanghai_Sunway_Pharmaceutical_Technology_Co_Limited_20260321 >									
	//        < 36PAyOt2W0HMs6G96N74d1Hw7R9P79hIO15a24p77Us8zMFYF6RBn2c4HZ8tLB2r >									
	//        <  u =="0.000000000000000001" : ] 000000089104465.302578400000000000 ; 000000111391312.426690000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000087F66FA9F83B >									
	//     < CHEMCHINA_PFVI_III_metadata_line_6_____Shanghai_Tauto_Biotech_Co_Limited_20260321 >									
	//        < ZD8BM0ZZf7b506It42MKaz4D17RLvT2vvKy5kog5q1NQ41r85Kd75o4j6Y7755x6 >									
	//        <  u =="0.000000000000000001" : ] 000000111391312.426690000000000000 ; 000000135541918.783628000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A9F83BCED210 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_7_____Shanghai_UCHEM_org__20260321 >									
	//        < 2G9EbaP00S36yZ4JZ7bL7yBrD9f615WDNc7UOT23YwCkv7wC3O5nR9pyauxilEXw >									
	//        <  u =="0.000000000000000001" : ] 000000135541918.783628000000000000 ; 000000161237807.018316000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CED210F60785 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_8_____Shanghai_UCHEM_inc__20260321 >									
	//        < Dk8C73676tKY3H266y2EkXi788GfH8r8Ak3RvS1mknFx9z9ao9ZlV4FyDFZ1pS5U >									
	//        <  u =="0.000000000000000001" : ] 000000161237807.018316000000000000 ; 000000183297801.344068000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F60785117B0B4 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_9_____Shanghai_UDChem_Technology_Co_Limited_20260321 >									
	//        < QP6wpu6m8Gy7J40T5q6d430K13Q6fB87H1dQdz7n7EKr92z965AO17dqXx6ZOqm5 >									
	//        <  u =="0.000000000000000001" : ] 000000183297801.344068000000000000 ; 000000207884437.041848000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000117B0B413D34DC >									
	//     < CHEMCHINA_PFVI_III_metadata_line_10_____Shanghai_Witofly_Chemical_Co_Limited_20260321 >									
	//        < 3qnDHRlZoQBVw8r722hE4kn2VQ7O2s48R0hcCmEaIg80cR1s2Zz92uSx5RV38Myn >									
	//        <  u =="0.000000000000000001" : ] 000000207884437.041848000000000000 ; 000000228727158.916596000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013D34DC15D028C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVI_III_metadata_line_11_____Shanghai_Worldyang_Chemical_Co_Limited_20260321 >									
	//        < 61E6i1u2Jexsk57ji1Y172u5o1d57D6TNQAm9o4HH3By54OmSeI207r2lNzqA9i6 >									
	//        <  u =="0.000000000000000001" : ] 000000228727158.916596000000000000 ; 000000251289334.450669000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015D028C17F6FE5 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_12_____Shanghai_Yingxuan_Chempharm_Co__Limited_20260321 >									
	//        < 2gk3789MYb3Ye9QPH3C673aqIIiErcf9Hs9Z9eYS7pdD8zW06Y98zIg4T6v8zA94 >									
	//        <  u =="0.000000000000000001" : ] 000000251289334.450669000000000000 ; 000000276710905.519900000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017F6FE51A63A33 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_13_____SHANXI_WUCHAN_FINE_CHEMICAL_Co_Limited_20260321 >									
	//        < 2tYtyZEUO696hbjqhY0o8aPwub98c5rYL1hSQUE2JC23ia2ICdT05Zel26JiWc99 >									
	//        <  u =="0.000000000000000001" : ] 000000276710905.519900000000000000 ; 000000300031527.643790000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A63A331C9CFD1 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_14_____SHENYANG_OLLYCHEM_CO_LTD_20260321 >									
	//        < OY3VDPG4Dom6HDvtPa37Kj3arsEx2ZA0LHP4Lnjmd20lKp6pZHmd2uFVH8s47ssp >									
	//        <  u =="0.000000000000000001" : ] 000000300031527.643790000000000000 ; 000000322365755.980303000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C9CFD11EBE420 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_15_____ShenZhen_Cerametek_Materials_org_20260321 >									
	//        < K73On09yB2f28LJ31FWPuGh291xX5ocL0W16xl89vD2T2Hqoz7oc2bkFs85E4VTq >									
	//        <  u =="0.000000000000000001" : ] 000000322365755.980303000000000000 ; 000000348764754.813935000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EBE4202142C3B >									
	//     < CHEMCHINA_PFVI_III_metadata_line_16_____ShenZhen_Cerametek_Materials_Co_Limited_20260321 >									
	//        < 8h857148R2c4xCRIqa9BwDDPe3XWC1G3t40CrhN2oUxe1tQj2qrtiXO397l4v2Wb >									
	//        <  u =="0.000000000000000001" : ] 000000348764754.813935000000000000 ; 000000375077357.615539000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002142C3B23C5298 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_17_____SHENZHEN_CHEMICAL_Co__Limited_20260321 >									
	//        < 480266Q3xI1c7HN21zz1dSFqbhpOy6VvgBMW0GfW22N4L5Kv4Q8375Bc5X33uMYK >									
	//        <  u =="0.000000000000000001" : ] 000000375077357.615539000000000000 ; 000000395961991.546560000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023C529825C30A7 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_18_____SHOUGUANG_FUKANG_PHARMACEUTICAL_Co_Limited_20260321 >									
	//        < Jx3DU9qt6ERLE4ujLqhG5q5g4lV21O8X29iiobyWBGz86HvVct2EJ6yBUno3t3ef >									
	//        <  u =="0.000000000000000001" : ] 000000395961991.546560000000000000 ; 000000418492467.449589000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025C30A727E919F >									
	//     < CHEMCHINA_PFVI_III_metadata_line_19_____Shouyuan_Chemical_20260321 >									
	//        < jbBb6AY121u8Pi4KwsM13Ac4Ok6Cs3vll9gi1gfgmHo4R1zaJjVsJ3LT85gLTR36 >									
	//        <  u =="0.000000000000000001" : ] 000000418492467.449589000000000000 ; 000000442974219.021736000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027E919F2A3ECCE >									
	//     < CHEMCHINA_PFVI_III_metadata_line_20_____Sichuan_Apothe_Pharmaceuticals_Limited_20260321 >									
	//        < 5yol6P8ng564I8gz37s39RQ1v1Pmb5e599z2RSNrHmI7wmUmiMr9EqXgbHB8Eb24 >									
	//        <  u =="0.000000000000000001" : ] 000000442974219.021736000000000000 ; 000000465150925.733444000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A3ECCE2C5C395 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVI_III_metadata_line_21_____Sichuan_Highlight_Fine_Chemicals_Co__Limited_20260321 >									
	//        < 6sIBM7w5Iba513ps5Q2gyyt05l5E1D0v9U9YQ8kCQvhg4xBGRRO2XlV5rPCKRK1U >									
	//        <  u =="0.000000000000000001" : ] 000000465150925.733444000000000000 ; 000000485984176.551037000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C5C3952E58D92 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_22_____SICHUAN_TONGSHENG_AMINO_ACID_org_20260321 >									
	//        < 5Hx1OH90f4q1Pb8zU9h6fCfZ6264q5yxQ90Um286KjktsTaxI7x1I1QuyMMLS9ZY >									
	//        <  u =="0.000000000000000001" : ] 000000485984176.551037000000000000 ; 000000511919792.055125000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E58D9230D20AB >									
	//     < CHEMCHINA_PFVI_III_metadata_line_23_____SICHUAN_TONGSHENG_AMINO_ACID_Co_Limited_20260321 >									
	//        < 0X50xUg5gW1DO00V1pm8x1c7Ss8l6466tVDpVj2D51672SM9tkFzAnUx3ZP1G2V1 >									
	//        <  u =="0.000000000000000001" : ] 000000511919792.055125000000000000 ; 000000533466551.139076000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030D20AB32E015F >									
	//     < CHEMCHINA_PFVI_III_metadata_line_24_____SightChem_Co__Limited_20260321 >									
	//        < cqQB62jnCKoK5eIvf2I7dGO61NvbgBJ68G4r54V1Y775X2412CVG8sY2tXRhkE7m >									
	//        <  u =="0.000000000000000001" : ] 000000533466551.139076000000000000 ; 000000554542559.139097000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032E015F34E2A30 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_25_____Simagchem_Corporation_20260321 >									
	//        < M41c23zB9g9fSV3eIHNcFYUV8DMV07520pEn405vz107b8xpB3A7xaQiH8e9AKOs >									
	//        <  u =="0.000000000000000001" : ] 000000554542559.139097000000000000 ; 000000577180734.880584000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034E2A30370B539 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_26_____SINO_GREAT_ENTERPRISE_Limited_20260321 >									
	//        < nz7kJhdl7mimCZzVL6tm2jND4xeohCiJ6vx9MG3uxC60au90qDj1jgyG6ALW5Zwo >									
	//        <  u =="0.000000000000000001" : ] 000000577180734.880584000000000000 ; 000000600462787.260077000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000370B5393943BC7 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_27_____SINO_High_Goal_chemical_Techonology_Co_Limited_20260321 >									
	//        < QhmlXw8OSo1g8GZ6VpLt3cru8IXE1Z748ec70as6Lzeowm8B51Tn2Bx4tl3H8158 >									
	//        <  u =="0.000000000000000001" : ] 000000600462787.260077000000000000 ; 000000623533762.157751000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003943BC73B76FE0 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_28_____Sino_Rarechem_Labs_Co_Limited_20260321 >									
	//        < yNX4zzVQ55g2Q6rK47l1oIf560q6JBT81fs7M41r200zJk1Wfx99F1428sboD4ed >									
	//        <  u =="0.000000000000000001" : ] 000000623533762.157751000000000000 ; 000000646488332.457867000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B76FE03DA7681 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_29_____Sinofi_Ingredients_20260321 >									
	//        < MHnPA75J13ip5NSE01qaeZhVa9wHR043Fwb9lKXcfRFLurSv2RVr94VM49kWue8g >									
	//        <  u =="0.000000000000000001" : ] 000000646488332.457867000000000000 ; 000000669664117.857185000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DA76813FDD38C >									
	//     < CHEMCHINA_PFVI_III_metadata_line_30_____Sinoway_20260321 >									
	//        < MD5wu3c5I00S5lqi7Yo6777oaCya11O0PJ0cL6r2NwUskQ0jsJS3D9kl9ZZmwgQg >									
	//        <  u =="0.000000000000000001" : ] 000000669664117.857185000000000000 ; 000000694744274.398119000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FDD38C424187B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < CHEMCHINA_PFVI_III_metadata_line_31_____Skyrun_Industrial_Co_Limited_20260321 >									
	//        < SF26o76u0633244ty3PbZD7d687dpcAhwZx0V3BMGf78hhnYNpLB798IJua3h1AV >									
	//        <  u =="0.000000000000000001" : ] 000000694744274.398119000000000000 ; 000000718844577.775298000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000424187B448DEAA >									
	//     < CHEMCHINA_PFVI_III_metadata_line_32_____Spec_Chem_Industry_org_20260321 >									
	//        < 4wmD0sN587LU1BE685dO4wZXQ8E4NtMlEp51c2pR72N6MI2912z34AG1QxrCI2JI >									
	//        <  u =="0.000000000000000001" : ] 000000718844577.775298000000000000 ; 000000741574406.047041000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000448DEAA46B8D81 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_33_____Spec_Chem_Industry_inc__20260321 >									
	//        < 1Ab97ksPzl6KeQ48H2qS5Fgzr90KmLuGPt8XqKt5o96dsxX2h7q2YKkFJB8gWp1p >									
	//        <  u =="0.000000000000000001" : ] 000000741574406.047041000000000000 ; 000000767088068.559047000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046B8D814927BC7 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_34_____Stone_Lake_Pharma_Tech_Co_Limited_20260321 >									
	//        < dk32tiRZXyyq9hRq63Q8Hv2UmiorCN0Y7TY6Ggbo8FGp4M4g7oCvAL1hftGj2XOW >									
	//        <  u =="0.000000000000000001" : ] 000000767088068.559047000000000000 ; 000000792515027.340330000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004927BC74B9482F >									
	//     < CHEMCHINA_PFVI_III_metadata_line_35_____Suzhou_ChonTech_PharmaChem_Technology_Co__Limited_20260321 >									
	//        < dFMfS0516lv7chfu6z3r7H4BE5qcT9j3dzYU0gjdS9LGBKCVn8tuq17cG7qMVD5h >									
	//        <  u =="0.000000000000000001" : ] 000000792515027.340330000000000000 ; 000000814298963.254644000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B9482F4DA8588 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_36_____Suzhou_Credit_International_Trading_Co__Limited_20260321 >									
	//        < odM928865uQ7JpoqU92InKIv5bUQLIG2Ds34wmAM7uG2pa8ofF5i2SnTXwzE9Kg8 >									
	//        <  u =="0.000000000000000001" : ] 000000814298963.254644000000000000 ; 000000839221947.520822000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004DA85885008D13 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_37_____Suzhou_KPChemical_Co_Limited_20260321 >									
	//        < V3j7Y9ty91xQn80Ra5lT3p9u6LcaVMF2dxhauz8dZWZhWXEAZx6024QKp9971dtq >									
	//        <  u =="0.000000000000000001" : ] 000000839221947.520822000000000000 ; 000000862476933.770626000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005008D13524090D >									
	//     < CHEMCHINA_PFVI_III_metadata_line_38_____Suzhou_Rovathin_Foreign_Trade_Co_Limited_20260321 >									
	//        < J9l5tfl0I32NRW35f017PE6UjP633Xu1S9RZpW9C5r93LzbE29nb69vQ73jB29XO >									
	//        <  u =="0.000000000000000001" : ] 000000862476933.770626000000000000 ; 000000887574804.597463000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000524090D54A54E8 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_39_____SUZHOU_SINOERA_CHEM_org_20260321 >									
	//        < vRDUH6n2R9hIDe7IAJ9FG2Yp4b926S7xqic66Oah9ZITp4brATssx1GJ2Q3d7y5B >									
	//        <  u =="0.000000000000000001" : ] 000000887574804.597463000000000000 ; 000000909969776.509183000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000054A54E856C80F2 >									
	//     < CHEMCHINA_PFVI_III_metadata_line_40_____SUZHOU_SINOERA_CHEM_Co__Limited_20260321 >									
	//        < Zo8pVC8R4iXBP2P54c6gOg8Bcx70QleNL9OCw890VuN3zTXZiOpI9Pe7nEd0w3lX >									
	//        <  u =="0.000000000000000001" : ] 000000909969776.509183000000000000 ; 000000935185536.382745000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000056C80F2592FADA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}