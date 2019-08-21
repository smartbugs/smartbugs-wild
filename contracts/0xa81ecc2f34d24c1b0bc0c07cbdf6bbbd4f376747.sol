pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXI_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXI_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXI_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		805221946908889000000000000					;	
										
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
	//     < RUSS_PFXXI_II_metadata_line_1_____EUROCHEM_20231101 >									
	//        < 930OAEVjmBlQ053FSvp5k35rZ6rN1W39yCTd5YD1930zL39q8278mCml69rCh2eN >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000016611399.323489600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001958D4 >									
	//     < RUSS_PFXXI_II_metadata_line_2_____Eurochem_Org_20231101 >									
	//        < NQ5RR42bXcwwqqd49GOFgie39lg29IqsZeHNg8GmvQVHL7k63WSwhC719RFsM2mp >									
	//        <  u =="0.000000000000000001" : ] 000000016611399.323489600000000000 ; 000000037841607.559845400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001958D439BDE1 >									
	//     < RUSS_PFXXI_II_metadata_line_3_____Hispalense_Líquidos_SL_20231101 >									
	//        < O4a7juxu37PgqPBG717H057g6AM4U1u1T831Gk5r4848ul457uB9dqU81hgShifw >									
	//        <  u =="0.000000000000000001" : ] 000000037841607.559845400000000000 ; 000000062667222.117960700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000039BDE15F9F62 >									
	//     < RUSS_PFXXI_II_metadata_line_4_____Azottech_LLC_20231101 >									
	//        < ym2L1t1uUZTg7T9nxlX3DTu4qR0rbD3p2VTD6Kvz7AnWqpl1H48TOf22m9c4X53I >									
	//        <  u =="0.000000000000000001" : ] 000000062667222.117960700000000000 ; 000000080109856.281920900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005F9F627A3CEA >									
	//     < RUSS_PFXXI_II_metadata_line_5_____Biochem_Technologies_LLC_20231101 >									
	//        < vOuSfTvFZDf2b1u984ffjxL0vpoFq705ATwc7NK3ro6hMfzKOMsWIa090VVFXeO2 >									
	//        <  u =="0.000000000000000001" : ] 000000080109856.281920900000000000 ; 000000102871045.217460000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007A3CEA9CF801 >									
	//     < RUSS_PFXXI_II_metadata_line_6_____Eurochem_1_Org_20231101 >									
	//        < 3BY4tWMrP4p9U4FuEd8m2647Gtk0U161QRa4e0EG5aIfisGejmmN5mX31Ui23u05 >									
	//        <  u =="0.000000000000000001" : ] 000000102871045.217460000000000000 ; 000000126888574.726201000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009CF801C19DD9 >									
	//     < RUSS_PFXXI_II_metadata_line_7_____Eurochem_1_Dao_20231101 >									
	//        < id612fVPC9RD9fWOn5x4zO2g7rTIv9L08Sm4U69u5zLn0c0km3L7JRt1R39E5w20 >									
	//        <  u =="0.000000000000000001" : ] 000000126888574.726201000000000000 ; 000000149638822.486787000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C19DD9E454AA >									
	//     < RUSS_PFXXI_II_metadata_line_8_____Eurochem_1_Daopi_20231101 >									
	//        < zp3cn286125zfH3Ee1HtkZFsF4o4GTwu8VZ2Benlg3vVM56p4wDAi19gZizTeXKP >									
	//        <  u =="0.000000000000000001" : ] 000000149638822.486787000000000000 ; 000000170414251.147433000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E454AA1040811 >									
	//     < RUSS_PFXXI_II_metadata_line_9_____Eurochem_1_Dac_20231101 >									
	//        < D9BL775zM7ABz5VHsq6QRugdmPjcbPb4LcDY1H4yOYz5GX39ORW7Ijaljw8E80F7 >									
	//        <  u =="0.000000000000000001" : ] 000000170414251.147433000000000000 ; 000000190430072.749687000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000104081112292BF >									
	//     < RUSS_PFXXI_II_metadata_line_10_____Eurochem_1_Bimi_20231101 >									
	//        < Ok067Q5168rWqD4c0fsRPgBZ9075onRDyjlQn26S2a1Jw86xd87R6SSRYLx1qT1V >									
	//        <  u =="0.000000000000000001" : ] 000000190430072.749687000000000000 ; 000000206137924.821921000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012292BF13A8AA0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXI_II_metadata_line_11_____Eurochem_2_Org_20231101 >									
	//        < 3zSPGtwo9C1i46L8Z98g2fqnUu7mb80POH1Qxo2NJ7xane57zd5de6kaI399Z5bO >									
	//        <  u =="0.000000000000000001" : ] 000000206137924.821921000000000000 ; 000000230030669.438427000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013A8AA015EFFBB >									
	//     < RUSS_PFXXI_II_metadata_line_12_____Eurochem_2_Dao_20231101 >									
	//        < 2Kh511WO6AbEA6lrvf5d63s0E9dMlmJGJ5XM4L4wS0Ou6NS5j0h46Y090V2r8uFv >									
	//        <  u =="0.000000000000000001" : ] 000000230030669.438427000000000000 ; 000000246845953.585542000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015EFFBB178A833 >									
	//     < RUSS_PFXXI_II_metadata_line_13_____Eurochem_2_Daopi_20231101 >									
	//        < g12naP1kMex8jm10jut9Ggz1Bo4tMA4j4XZ12ZDuk46TR5NvgVQig2q2t5Q7AAUB >									
	//        <  u =="0.000000000000000001" : ] 000000246845953.585542000000000000 ; 000000263723463.167124000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000178A83319268FA >									
	//     < RUSS_PFXXI_II_metadata_line_14_____Eurochem_2_Dac_20231101 >									
	//        < s0muGw73mEodJQykAE75y9F30G28lwvEn66aR0TX0uZJBYV7xdz32FxDA2RKYC3b >									
	//        <  u =="0.000000000000000001" : ] 000000263723463.167124000000000000 ; 000000288477118.129522000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019268FA1B82E60 >									
	//     < RUSS_PFXXI_II_metadata_line_15_____Eurochem_2_Bimi_20231101 >									
	//        < V4vZy7bnOT53jO72X15uJeiFTVvK1vV5rdbxB95v3729hYVDs3Vysm0yt3P0wcKI >									
	//        <  u =="0.000000000000000001" : ] 000000288477118.129522000000000000 ; 000000310639664.108619000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B82E601D9FF9E >									
	//     < RUSS_PFXXI_II_metadata_line_16_____Melni_1_Org_20231101 >									
	//        < P2VypO738C89t27pEzD2e1psd2MTqlnpN23IW5wfzE9hRYU6zdA880X7ER0mxlFO >									
	//        <  u =="0.000000000000000001" : ] 000000310639664.108619000000000000 ; 000000334193741.282362000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D9FF9E1FDF06E >									
	//     < RUSS_PFXXI_II_metadata_line_17_____Melni_1_Dao_20231101 >									
	//        < hwl1FQ0xxg8LfImJh324VBN106eHK5TbyH8dDQ8uOApCDkytfDs57N9s8Hy5jB5z >									
	//        <  u =="0.000000000000000001" : ] 000000334193741.282362000000000000 ; 000000357663903.309225000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FDF06E221C076 >									
	//     < RUSS_PFXXI_II_metadata_line_18_____Melni_1_Daopi_20231101 >									
	//        < zmmDG82QQX0m78J6pLKr2j720KLtKFdeT8532jhRTA5Ni4By64KZO5DL6x8e4HIz >									
	//        <  u =="0.000000000000000001" : ] 000000357663903.309225000000000000 ; 000000376627840.870958000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000221C07623EB040 >									
	//     < RUSS_PFXXI_II_metadata_line_19_____Melni_1_Dac_20231101 >									
	//        < z0GI8On2vDLWuQNYZx0c0TG9GzIQKRX5kb563W5ZV8g39d07YJAA02j8meY92fpt >									
	//        <  u =="0.000000000000000001" : ] 000000376627840.870958000000000000 ; 000000396048454.157939000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023EB04025C526D >									
	//     < RUSS_PFXXI_II_metadata_line_20_____Melni_1_Bimi_20231101 >									
	//        < BH0KM0O81xy52NA5UV9lUdRrM09XidC8rUAev2ng6U2BbPoe6y2Chtj0d2REx5tF >									
	//        <  u =="0.000000000000000001" : ] 000000396048454.157939000000000000 ; 000000412307261.980410000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025C526D2752186 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXI_II_metadata_line_21_____Melni_2_Org_20231101 >									
	//        < 1u4Pw6j5HZzgt48Wf1g3XMeY1bUt8Bb65Q65zR80d6C11qhhfBE55cVAaNqmUIk6 >									
	//        <  u =="0.000000000000000001" : ] 000000412307261.980410000000000000 ; 000000430541528.459924000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002752186290F449 >									
	//     < RUSS_PFXXI_II_metadata_line_22_____Melni_2_Dao_20231101 >									
	//        < ygQlindqt2ubSMMoB47Jwso1Wc944lbuCXH5Y3DZoWh1r6qU9NFFYt97G46835gQ >									
	//        <  u =="0.000000000000000001" : ] 000000430541528.459924000000000000 ; 000000451812446.989190000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000290F4492B1693D >									
	//     < RUSS_PFXXI_II_metadata_line_23_____Melni_2_Daopi_20231101 >									
	//        < tPulidVmbLQ3nAuM78Zecw55k3TkG1H1fPgG8X7QZ93oM85T6OBT7Ppgxvrb0Un3 >									
	//        <  u =="0.000000000000000001" : ] 000000451812446.989190000000000000 ; 000000470137771.151784000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B1693D2CD5F91 >									
	//     < RUSS_PFXXI_II_metadata_line_24_____Melni_2_Dac_20231101 >									
	//        < PJ72droe6vsRGqD9f7Mxl12V8JsaHhF9iWLLs4ZU6YK2cjdZl5KAu9Bd4hNqN931 >									
	//        <  u =="0.000000000000000001" : ] 000000470137771.151784000000000000 ; 000000493624291.943217000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CD5F912F135FD >									
	//     < RUSS_PFXXI_II_metadata_line_25_____Melni_2_Bimi_20231101 >									
	//        < vOEvr2seA03e1La75b4HqB0OWUwMBh74wjk3RJ6sUW5zi7e0K0dhbBch1i3202H7 >									
	//        <  u =="0.000000000000000001" : ] 000000493624291.943217000000000000 ; 000000514524991.493669000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F135FD3111A53 >									
	//     < RUSS_PFXXI_II_metadata_line_26_____Lifosa_Ab_Org_20231101 >									
	//        < 3L115TP3C0R5R01H2hKKj9Rtv6UXn0m2LYJ96RNoqnas4LIzfc17Z6C1527kk29S >									
	//        <  u =="0.000000000000000001" : ] 000000514524991.493669000000000000 ; 000000532862027.847582000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003111A5332D153B >									
	//     < RUSS_PFXXI_II_metadata_line_27_____Lifosa_Ab_Dao_20231101 >									
	//        < mlg094wwwr2sJc7hbg5Qrw8y6R06Q6uq866O030J7263NEm7D9c666p8k0nbncLN >									
	//        <  u =="0.000000000000000001" : ] 000000532862027.847582000000000000 ; 000000550309914.039471000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032D153B347B4CF >									
	//     < RUSS_PFXXI_II_metadata_line_28_____Lifosa_Ab_Daopi_20231101 >									
	//        < s88jaC7wn2882i5Vh9uD3TD3JP2BLGHryt491k09D2T1Q96E856r2s7KMIn3I8o2 >									
	//        <  u =="0.000000000000000001" : ] 000000550309914.039471000000000000 ; 000000569797831.962526000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000347B4CF3657147 >									
	//     < RUSS_PFXXI_II_metadata_line_29_____Lifosa_Ab_Dac_20231101 >									
	//        < F9t2U1ntl67D4PS57725NQPKkSgOR9fJakkW7JvIuw4f35NSJtR50NI1fll2W471 >									
	//        <  u =="0.000000000000000001" : ] 000000569797831.962526000000000000 ; 000000589751827.013634000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003657147383E3CF >									
	//     < RUSS_PFXXI_II_metadata_line_30_____Lifosa_Ab_Bimi_20231101 >									
	//        < 6Y4N5hP5jK4i7eiBfc0nfvK3Z66j5dTO0Yusz5xgNzf0v2n8msKT6uME1PDhu00S >									
	//        <  u =="0.000000000000000001" : ] 000000589751827.013634000000000000 ; 000000609396874.156012000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000383E3CF3A1DDA7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXI_II_metadata_line_31_____Azot_Ab_1_Org_20231101 >									
	//        < 3q7MEcN2z9an9D99j3GwchPr277mKnEVvc0M1p27nkAJx8mEv7w0gSM0b59rC8GU >									
	//        <  u =="0.000000000000000001" : ] 000000609396874.156012000000000000 ; 000000627586281.499586000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A1DDA73BD9EE4 >									
	//     < RUSS_PFXXI_II_metadata_line_32_____Azot_Ab_1_Dao_20231101 >									
	//        < B2jy6Wq4zPgRl075RFR9m7v74Ze4Fcmyr6P2nfS0tRy81gcmnNZ1qQILD8T113y2 >									
	//        <  u =="0.000000000000000001" : ] 000000627586281.499586000000000000 ; 000000645309728.280375000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BD9EE43D8AA1D >									
	//     < RUSS_PFXXI_II_metadata_line_33_____Azot_Ab_1_Daopi_20231101 >									
	//        < dy3Y6txne5h3IP7Z19Eq3Y72XqbXU047Whh7h3Qey8GbJcjqigU2g93A6E6a767m >									
	//        <  u =="0.000000000000000001" : ] 000000645309728.280375000000000000 ; 000000664635413.070464000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D8AA1D3F62735 >									
	//     < RUSS_PFXXI_II_metadata_line_34_____Azot_Ab_1_Dac_20231101 >									
	//        < tJmq5K2b1HeIG1iVL9150Pj7uZE5J7gak3mZ3iS2hdfUxIIzS4908dO34wmDkdn7 >									
	//        <  u =="0.000000000000000001" : ] 000000664635413.070464000000000000 ; 000000684356682.314421000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F627354143ED4 >									
	//     < RUSS_PFXXI_II_metadata_line_35_____Azot_Ab_1_Bimi_20231101 >									
	//        < e52v851ruBz7f7Q2hjaykXO135nGzdv43VZTGbjB83bnI2cJr8s33tffZrSy6Mx5 >									
	//        <  u =="0.000000000000000001" : ] 000000684356682.314421000000000000 ; 000000701684497.398804000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004143ED442EAF82 >									
	//     < RUSS_PFXXI_II_metadata_line_36_____Azot_Ab_2_Org_20231101 >									
	//        < gv5oQ8FGoA16L7q3G4L8rbiWibd635qN9BDs5MS96o602y28QmdA8CTeLLrj59Yx >									
	//        <  u =="0.000000000000000001" : ] 000000701684497.398804000000000000 ; 000000721267251.173662000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042EAF8244C9105 >									
	//     < RUSS_PFXXI_II_metadata_line_37_____Azot_Ab_2_Dao_20231101 >									
	//        < 3lv29OZ4858Hn1efo17DcRN0SPSMA34oGl4dZFXuuSsIq3yrz7XNS5Kb47o7KYMU >									
	//        <  u =="0.000000000000000001" : ] 000000721267251.173662000000000000 ; 000000745706175.630697000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044C9105471DB7A >									
	//     < RUSS_PFXXI_II_metadata_line_38_____Azot_Ab_2_Daopi_20231101 >									
	//        < ungJbHx72Ch6HrL25W6EyWKrVqf74Rya6sQvGv259M86TTmvuC7YC8PfD0TLl4l9 >									
	//        <  u =="0.000000000000000001" : ] 000000745706175.630697000000000000 ; 000000765984917.852062000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000471DB7A490CCDC >									
	//     < RUSS_PFXXI_II_metadata_line_39_____Azot_Ab_2_Dac_20231101 >									
	//        < q9W305B69BoI3Tu1Zl1oY76MbqDYc3PuiNr513327S334y76ObnYZP60XOKC9au2 >									
	//        <  u =="0.000000000000000001" : ] 000000765984917.852062000000000000 ; 000000786051193.050150000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000490CCDC4AF6B3F >									
	//     < RUSS_PFXXI_II_metadata_line_40_____Azot_Ab_2_Bimi_20231101 >									
	//        < Js0YADVYnF7tpjJl24yz37aNJ28V5T4owmkGQBEwec2Vx4t23r234EIRIvt4zQz8 >									
	//        <  u =="0.000000000000000001" : ] 000000786051193.050150000000000000 ; 000000805221946.908889000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004AF6B3F4CCABD3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}