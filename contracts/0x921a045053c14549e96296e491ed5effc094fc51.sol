pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXVIII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXVIII_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXVIII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		813183889037939000000000000					;	
										
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
	//     < RUSS_PFXXVIII_II_metadata_line_1_____SIBUR_GBP_20231101 >									
	//        < JIEiiKHoTdsQ1565p6R7U79A3kcVOh3It0uJvnMJ0S7YlBn0j4A7G2OP3STb8lsB >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000018880968.643347600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001CCF61 >									
	//     < RUSS_PFXXVIII_II_metadata_line_2_____SIBUR_USD_20231101 >									
	//        < y9Az6AQSd4X43MQg3NjNiRh2tBpd4DKlM882s03d08B0g2JRUt8Nj2eM2fh8qD60 >									
	//        <  u =="0.000000000000000001" : ] 000000018880968.643347600000000000 ; 000000035862860.805272500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001CCF6136B8EE >									
	//     < RUSS_PFXXVIII_II_metadata_line_3_____SIBUR_FINANCE_CHF_20231101 >									
	//        < dC031Jv6y47c0Mtj8L9tGrQF162snwpK8uykEgLtt596C149JCx7th8TO7363Wyc >									
	//        <  u =="0.000000000000000001" : ] 000000035862860.805272500000000000 ; 000000054331334.656538800000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000036B8EE52E72D >									
	//     < RUSS_PFXXVIII_II_metadata_line_4_____SIBUR_FINANS_20231101 >									
	//        < N59MdEy65ls4YD4E8Z4Btc6pvyO66600tzf987n0m45iJU0m2z4pqmx07A2W8B0i >									
	//        <  u =="0.000000000000000001" : ] 000000054331334.656538800000000000 ; 000000071638991.522174100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000052E72D6D4FFB >									
	//     < RUSS_PFXXVIII_II_metadata_line_5_____SIBUR_SA_20231101 >									
	//        < H0NLs6nxn92yy7u9Uag0Yb792IH2o3HnQ2Ry63vuc3L2Z8H70i2tgRt55dV1q419 >									
	//        <  u =="0.000000000000000001" : ] 000000071638991.522174100000000000 ; 000000094945627.862312800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006D4FFB90E023 >									
	//     < RUSS_PFXXVIII_II_metadata_line_6_____VOSTOK_LLC_20231101 >									
	//        < 9WGn5xoiyJBc26R8Un6oLrsRhK3tEAkDCubflPbvB6d0IXSEn06Lh1uUnp63gE8G >									
	//        <  u =="0.000000000000000001" : ] 000000094945627.862312800000000000 ; 000000117383070.776912000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000090E023B31CC3 >									
	//     < RUSS_PFXXVIII_II_metadata_line_7_____BELOZERNYI_GPP_20231101 >									
	//        < 3Q23Itg16ZV04jBcgwgL4jcsou53YBa2b4GSD5RVbXPeIY6hE2j3QM75P8mg082W >									
	//        <  u =="0.000000000000000001" : ] 000000117383070.776912000000000000 ; 000000141831573.561568000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B31CC3D86AF5 >									
	//     < RUSS_PFXXVIII_II_metadata_line_8_____KRASNOYARSK_SYNTHETIC_RUBBERS_PLANT_20231101 >									
	//        < pZpMlqzR217z8L0DIAHpQ55QCsL1yv6oJlw9EzgWJ257YIo4c7Ol8hK1kF25Oy80 >									
	//        <  u =="0.000000000000000001" : ] 000000141831573.561568000000000000 ; 000000165267181.488624000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D86AF5FC2D7E >									
	//     < RUSS_PFXXVIII_II_metadata_line_9_____ORTON_20231101 >									
	//        < BjeuHcevI93MZAmP6Ays44Zgsp5AeW2Emut99j8Uf7kduFm8d2oqjVW6Egxmj3l4 >									
	//        <  u =="0.000000000000000001" : ] 000000165267181.488624000000000000 ; 000000184946654.987961000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FC2D7E11A34C9 >									
	//     < RUSS_PFXXVIII_II_metadata_line_10_____PLASTIC_GEOSYNTHETIC_20231101 >									
	//        < ESbRxR75eL4r7GxA568vY23pof9439WR3f5ybZ99GibkwnS3YCwJc9ps0Mukn62N >									
	//        <  u =="0.000000000000000001" : ] 000000184946654.987961000000000000 ; 000000205997054.371609000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011A34C913A5399 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVIII_II_metadata_line_11_____TOBOLSK_COMBINED_HEAT_POWER_PLANT_20231101 >									
	//        < 7iJ586H1vFjzo62Z9yQflnd3r46fk4eFuu5R3HDTMAQ2S28h2Q10yKRQm9vqz957 >									
	//        <  u =="0.000000000000000001" : ] 000000205997054.371609000000000000 ; 000000225445436.992094000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013A539915800A0 >									
	//     < RUSS_PFXXVIII_II_metadata_line_12_____UGRAGAZPERERABOTKA_20231101 >									
	//        < mH1OudMFo6k58M3vXRjaw4rC6q5ovW2vACe04d89AMReU7XGOGha3d3s3lb8wuTU >									
	//        <  u =="0.000000000000000001" : ] 000000225445436.992094000000000000 ; 000000243227728.346119000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015800A017322D5 >									
	//     < RUSS_PFXXVIII_II_metadata_line_13_____UGRAGAZPERERABOTKA_GBP_20231101 >									
	//        < 1HA0wGjAlo9WvTY36Q7Zv5v4Y6m209e1P55v593RL9pzCCz3A18un45wxnt212qv >									
	//        <  u =="0.000000000000000001" : ] 000000243227728.346119000000000000 ; 000000262027797.465509000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017322D518FD29C >									
	//     < RUSS_PFXXVIII_II_metadata_line_14_____UGRAGAZPERERABOTKA_BYR_20231101 >									
	//        < 08rT2rE0c8knzLeeQkSi1Gg6cG9iDN8v8U2OMBeUA4ab8SxJ0cAJihGDR035yHp4 >									
	//        <  u =="0.000000000000000001" : ] 000000262027797.465509000000000000 ; 000000278670990.193437000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018FD29C1A937DB >									
	//     < RUSS_PFXXVIII_II_metadata_line_15_____RUSTEP_20231101 >									
	//        < DmOQFd4E7V5gHKW8cEPeDk9sPkb5rFTf8w4r79hajY68zTDd01BKBys73H0niR7C >									
	//        <  u =="0.000000000000000001" : ] 000000278670990.193437000000000000 ; 000000300305298.836667000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A937DB1CA3AC2 >									
	//     < RUSS_PFXXVIII_II_metadata_line_16_____RUSTEP_RYB_20231101 >									
	//        < bzFl37A7D8Fyy9oHlv3G1W5fFn8QGsqZg3ImKLQgo80Z3qX56Y7eMZke83V7k9UC >									
	//        <  u =="0.000000000000000001" : ] 000000300305298.836667000000000000 ; 000000322284432.122109000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CA3AC21EBC45B >									
	//     < RUSS_PFXXVIII_II_metadata_line_17_____BALTIC_BYR_20231101 >									
	//        < 75Y52xPy6AIbSxV5CQNG1L12iqVU8TARz89GSA4QcO62km5hyU2ApY4v8O8ZU6R7 >									
	//        <  u =="0.000000000000000001" : ] 000000322284432.122109000000000000 ; 000000337748239.460211000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EBC45B2035CE8 >									
	//     < RUSS_PFXXVIII_II_metadata_line_18_____ARKTIK_BYR_20231101 >									
	//        < GKZ6Hh75PM74th0aW6Ht03JWDdZU6d50sbp5H0b5hwPhr6Sby2195ZT3S13hYh9t >									
	//        <  u =="0.000000000000000001" : ] 000000337748239.460211000000000000 ; 000000360184187.761386000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002035CE822598F3 >									
	//     < RUSS_PFXXVIII_II_metadata_line_19_____VOSTOK_BYR_20231101 >									
	//        < wna9r1OodlI4C1Ruvgt9GWsCBNyHJ093p0ZlGS9bE41Uz75Pu9vSwf93nMFcl3F4 >									
	//        <  u =="0.000000000000000001" : ] 000000360184187.761386000000000000 ; 000000378540554.803969000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022598F32419B67 >									
	//     < RUSS_PFXXVIII_II_metadata_line_20_____VINYL_BYR_20231101 >									
	//        < ch7RtoP9ICe927v2GWQ5bEannT01VxAXoMc8X9I7lpj9m56ZT2ibRk4Bn036AnK8 >									
	//        <  u =="0.000000000000000001" : ] 000000378540554.803969000000000000 ; 000000402395744.343947000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002419B6726601D6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVIII_II_metadata_line_21_____TOBOLSK_BYR_20231101 >									
	//        < 5e4D6JwC1CdfxD0dsQrq38hCxT0i9b4bau5a1E1pqXduUee6fd0q2Kayst3O0Aj7 >									
	//        <  u =="0.000000000000000001" : ] 000000402395744.343947000000000000 ; 000000422742219.187415000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026601D62850DAE >									
	//     < RUSS_PFXXVIII_II_metadata_line_22_____ACRYLATE_BYR_20231101 >									
	//        < rSPjvix5xD53dbCSF5Kc74X5vLj580keABL9yA7Q4ssNK30FhzDc75l29ksfd04J >									
	//        <  u =="0.000000000000000001" : ] 000000422742219.187415000000000000 ; 000000445090087.159275000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002850DAE2A72751 >									
	//     < RUSS_PFXXVIII_II_metadata_line_23_____POLIEF_BYR_20231101 >									
	//        < 5nEkdRgu7wN1M4t1wz9t79Eu48TaZqRWSMz9cJJL1S0B3PKvA13mYulN0L86r58x >									
	//        <  u =="0.000000000000000001" : ] 000000445090087.159275000000000000 ; 000000466232268.845673000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A727512C769FB >									
	//     < RUSS_PFXXVIII_II_metadata_line_24_____NOVAENG_BYR_20231101 >									
	//        < khy0Wt23c4dM4Tyk1G9ng2QUk8oLgFuH8ZDFPWzh1taCo8XznhGXtSGKnBLbcRIU >									
	//        <  u =="0.000000000000000001" : ] 000000466232268.845673000000000000 ; 000000482310687.217256000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C769FB2DFF29D >									
	//     < RUSS_PFXXVIII_II_metadata_line_25_____BIAXP_BYR_20231101 >									
	//        < aRyWK9i0U01xEau8O2MudZUMXgvdiCJ1SlKdd9K6Fp0rVD3m1dUgwM7m8JNNnVrf >									
	//        <  u =="0.000000000000000001" : ] 000000482310687.217256000000000000 ; 000000505128220.962905000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DFF29D302C3B6 >									
	//     < RUSS_PFXXVIII_II_metadata_line_26_____YUGRAGAZPERERABOTKA_AB_20231101 >									
	//        < Q3BzD5UT7568B198AlI560ACnT98gVAKxpcO76i823h0kg594F8WPPReM7wew69R >									
	//        <  u =="0.000000000000000001" : ] 000000505128220.962905000000000000 ; 000000528739210.211307000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000302C3B6326CAC1 >									
	//     < RUSS_PFXXVIII_II_metadata_line_27_____TOMSKNEFTEKHIM_AB_20231101 >									
	//        < D5Kj392vo8RfhwQUcRTKNO8blFnR6Bq0q1P0dt084hNe0fnUHrH8pC6m22UB4A1m >									
	//        <  u =="0.000000000000000001" : ] 000000528739210.211307000000000000 ; 000000547454123.231146000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000326CAC13435944 >									
	//     < RUSS_PFXXVIII_II_metadata_line_28_____BALTIC_LNG_AB_20231101 >									
	//        < Wf863ZDez5O1BfW1mU73dP2kz0wf63K47VFITB20908RZ0r3914kzQ47Zre376D0 >									
	//        <  u =="0.000000000000000001" : ] 000000547454123.231146000000000000 ; 000000570688855.072005000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003435944366CD56 >									
	//     < RUSS_PFXXVIII_II_metadata_line_29_____SIBUR_INT_AB_20231101 >									
	//        < vOx3eJNl433Dv1z9rHG6nNtvg2td5ak97z593OnWPO52Rh4NyJFpGVICOM1h783N >									
	//        <  u =="0.000000000000000001" : ] 000000570688855.072005000000000000 ; 000000589416806.464131000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000366CD5638360F1 >									
	//     < RUSS_PFXXVIII_II_metadata_line_30_____TOBOL_SK_POLIMER_AB_20231101 >									
	//        < 2AcsFtS8a4Q8ZlH3Kw4B8DmKUVKd721G16RY7T2K52NziG1wKuBQ7hY8Bc4i7z18 >									
	//        <  u =="0.000000000000000001" : ] 000000589416806.464131000000000000 ; 000000609943314.889962000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038360F13A2B31B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVIII_II_metadata_line_31_____SIBUR_SCIENT_RD_INSTITUTE_GAS_PROCESS_AB_20231101 >									
	//        < G4W2sO2xEaGeT3tUG1lPnBrY6nDT44aT6F02GA6dd378GT0JM5W8mlEv96LBO7T5 >									
	//        <  u =="0.000000000000000001" : ] 000000609943314.889962000000000000 ; 000000627573949.850765000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A2B31B3BD9A13 >									
	//     < RUSS_PFXXVIII_II_metadata_line_32_____ZAPSIBNEFTEKHIM_AB_20231101 >									
	//        < 53te52cIvQ82959fLY8NrSSqIxQD6kj72u488H6su25w60dC2xQ6hRK3qDs2lM1P >									
	//        <  u =="0.000000000000000001" : ] 000000627573949.850765000000000000 ; 000000647649809.110474000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BD9A133DC3C35 >									
	//     < RUSS_PFXXVIII_II_metadata_line_33_____NEFTEKHIMIA_AB_20231101 >									
	//        < 4n0t6Imcxusboc15HaQZIIlM5j03c6VV6bt2Pg3dRAN0efEe7U86fmRAf24f403c >									
	//        <  u =="0.000000000000000001" : ] 000000647649809.110474000000000000 ; 000000665864074.776195000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DC3C353F80727 >									
	//     < RUSS_PFXXVIII_II_metadata_line_34_____OTECHESTVENNYE_POLIMERY_AB_20231101 >									
	//        < eakRPobtTWNumPaCw49Yz164V079R2z9bGgi3GZb5A2Z8a6Jizvz4o6HbLu23ycc >									
	//        <  u =="0.000000000000000001" : ] 000000665864074.776195000000000000 ; 000000686965515.353715000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F8072741839E8 >									
	//     < RUSS_PFXXVIII_II_metadata_line_35_____SIBUR_TRANS_AB_20231101 >									
	//        < 8CB0OAH40U698Bh2ro8JWG4QZq7SD4hOF7LTenIvi5zLA5HrUx65k28b8WCoo5iM >									
	//        <  u =="0.000000000000000001" : ] 000000686965515.353715000000000000 ; 000000708640671.061384000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041839E84394CC3 >									
	//     < RUSS_PFXXVIII_II_metadata_line_36_____TOGLIATTIKAUCHUK_AB_20231101 >									
	//        < 329ai6cRJhH70uix0JKktRp305C8bT7y9e0iPx8HhuB4505EhYOmGRo3617sD4Mr >									
	//        <  u =="0.000000000000000001" : ] 000000708640671.061384000000000000 ; 000000731983959.294132000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004394CC345CEB3C >									
	//     < RUSS_PFXXVIII_II_metadata_line_37_____NPP_NEFTEKHIMIYA_AB_20231101 >									
	//        < a9815F0dmCOJJZAIuuUNW7p7QnvIt365AbyLcNOOyEjmt69y51g5v6Mg37Qmgh0y >									
	//        <  u =="0.000000000000000001" : ] 000000731983959.294132000000000000 ; 000000753562412.175109000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045CEB3C47DD851 >									
	//     < RUSS_PFXXVIII_II_metadata_line_38_____SIBUR_KHIMPROM_AB_20231101 >									
	//        < 1f31Ji1S1K88LEjdB733P74y26SO1ZAPR115m0o2RihBuqkLC76Jc8VJf1img5D7 >									
	//        <  u =="0.000000000000000001" : ] 000000753562412.175109000000000000 ; 000000778180158.799397000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047DD8514A368A0 >									
	//     < RUSS_PFXXVIII_II_metadata_line_39_____SIBUR_VOLZHSKY_AB_20231101 >									
	//        < lfuS4625BVX315Lb32V5K0yxC9MJj241uvMzKeua2JwIzUzYOm2JNFQ1X88O9N8g >									
	//        <  u =="0.000000000000000001" : ] 000000778180158.799397000000000000 ; 000000796172394.935449000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A368A04BEDCD7 >									
	//     < RUSS_PFXXVIII_II_metadata_line_40_____VORONEZHSINTEZKAUCHUK_AB_20231101 >									
	//        < 6b5Soj1E6r1iULOq9R5B12ljYMu01Vs7Cupt0HLo7dH08mrEf3o5q3pyvCI2fyA8 >									
	//        <  u =="0.000000000000000001" : ] 000000796172394.935449000000000000 ; 000000813183889.037939000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004BEDCD74D8D1F5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}