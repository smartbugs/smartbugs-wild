pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXI_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXI_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXXI_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		799361044451549000000000000					;	
										
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
	//     < RUSS_PFXXXI_II_metadata_line_1_____MEGAFON_20231101 >									
	//        < Gj50Igyj7AgJ254Qd2dqDO9nJu9JxbPi12cHevlnmDCE9fo0XCFRF0QA9A4k2rPX >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000022235580.019941900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000021EDC6 >									
	//     < RUSS_PFXXXI_II_metadata_line_2_____EUROSET_20231101 >									
	//        < 45kxjDgdY2Jj1pssK9rpmFW5zDLCH8mMjeYeA2GTc0K0H5Xmrtm07BKkB0f551J8 >									
	//        <  u =="0.000000000000000001" : ] 000000022235580.019941900000000000 ; 000000040009691.845733000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000021EDC63D0CC9 >									
	//     < RUSS_PFXXXI_II_metadata_line_3_____OSTELECOM_20231101 >									
	//        < RV86PC3ySD86FVf9V3MXAVxD0ntIX4118D54KLrvPw2AM6EvNv4JOIO056v2y1R0 >									
	//        <  u =="0.000000000000000001" : ] 000000040009691.845733000000000000 ; 000000058349304.466849000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003D0CC95908B2 >									
	//     < RUSS_PFXXXI_II_metadata_line_4_____GARS_TELECOM_20231101 >									
	//        < 5wVTksmi98N5z1J9zsWaN1ilkdXgmG2tVA2318oxVN6n9Q4L6OvSpGE0KsC8YLqN >									
	//        <  u =="0.000000000000000001" : ] 000000058349304.466849000000000000 ; 000000077240181.682029000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005908B275DBF2 >									
	//     < RUSS_PFXXXI_II_metadata_line_5_____MEGAFON_INVESTMENT_CYPRUS_LIMITED_20231101 >									
	//        < iTqJU5LM063lk7vB3GG48L4mLNd27UxNk7T3G9dB9EE30kJ92PPr44sJ1T4AC408 >									
	//        <  u =="0.000000000000000001" : ] 000000077240181.682029000000000000 ; 000000102086990.573193000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000075DBF29BC5BB >									
	//     < RUSS_PFXXXI_II_metadata_line_6_____YOTA_20231101 >									
	//        < Aon6yK0xZpc5rM1tGhIIvM8KV1QRtnLYr8fz1ebO9Dayk9o1SchJ39395Z9KjioV >									
	//        <  u =="0.000000000000000001" : ] 000000102086990.573193000000000000 ; 000000120407680.229163000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009BC5BBB7BA40 >									
	//     < RUSS_PFXXXI_II_metadata_line_7_____YOTA_DAO_20231101 >									
	//        < 900ed6T6508XjikLPnj2zytOe0A4D1yb212e248Flx34TKIClz3jE5BOFPU1dON6 >									
	//        <  u =="0.000000000000000001" : ] 000000120407680.229163000000000000 ; 000000137430763.107904000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B7BA40D1B3E4 >									
	//     < RUSS_PFXXXI_II_metadata_line_8_____YOTA_DAOPI_20231101 >									
	//        < xDb8p9Amcu3KhrpE1NFCNyZqo690l45ab3q9XMohu9rA7P6daDDn73pJ61G97JS9 >									
	//        <  u =="0.000000000000000001" : ] 000000137430763.107904000000000000 ; 000000155984032.985441000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D1B3E4EE0343 >									
	//     < RUSS_PFXXXI_II_metadata_line_9_____YOTA_DAC_20231101 >									
	//        < GA9tAMI2P5i5QBLB0194Wiby4ycej5XDp34bj472ImrT0nu2va8Kx6Ma35nO988O >									
	//        <  u =="0.000000000000000001" : ] 000000155984032.985441000000000000 ; 000000173929236.001575000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EE0343109651C >									
	//     < RUSS_PFXXXI_II_metadata_line_10_____YOTA_BIMI_20231101 >									
	//        < 4vU8ub6zRnB9Ton9JuwH3ZB97oWKW40kUV0AGeYvTBQiSA7rSGhuzy2qBF3Ww7MN >									
	//        <  u =="0.000000000000000001" : ] 000000173929236.001575000000000000 ; 000000198098653.208605000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000109651C12E4649 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXI_II_metadata_line_11_____KAVKAZ_20231101 >									
	//        < 84HJJp2O1sl7Bn1L9c150aanj4SPf26sIN3FMAp8ynqQ5T36W897GQ49QszM8c2j >									
	//        <  u =="0.000000000000000001" : ] 000000198098653.208605000000000000 ; 000000214678865.937489000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012E464914792EF >									
	//     < RUSS_PFXXXI_II_metadata_line_12_____KAVKAZ_KZT_20231101 >									
	//        < 1SKyauiMvwL1g5gIeM8KLidw1O8U65L49AcFMB8i960kZkfr3B250V678vhN76xr >									
	//        <  u =="0.000000000000000001" : ] 000000214678865.937489000000000000 ; 000000239002502.077128000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014792EF16CB05A >									
	//     < RUSS_PFXXXI_II_metadata_line_13_____KAVKAZ_CHF_20231101 >									
	//        < q67eD0S040751o6FsVqHIITtRfhk3LvNuQag39oXnJo3jIifC0sUkO9hYmE9a331 >									
	//        <  u =="0.000000000000000001" : ] 000000239002502.077128000000000000 ; 000000257321980.098189000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016CB05A188A466 >									
	//     < RUSS_PFXXXI_II_metadata_line_14_____KAVKAZ_USD_20231101 >									
	//        < P5tsI9L1T3Ou65338nYgv4Yxia2DDSDOjs4ae0qLVLht39AJCfO3c2kO4VgG5nin >									
	//        <  u =="0.000000000000000001" : ] 000000257321980.098189000000000000 ; 000000278269905.899461000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000188A4661A89B2F >									
	//     < RUSS_PFXXXI_II_metadata_line_15_____PETERSTAR_20231101 >									
	//        < d0763cPmNV83T82Sh8ZWMIDC5qGoZ9Cxb91tkWP12TLCVmUY4vqAZex4TIroZ8C2 >									
	//        <  u =="0.000000000000000001" : ] 000000278269905.899461000000000000 ; 000000293745992.835777000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A89B2F1C03887 >									
	//     < RUSS_PFXXXI_II_metadata_line_16_____MEGAFON_FINANCE_LLC_20231101 >									
	//        < 28Y21G5C36UDB2o5cJRj7Ah5p9Q3r8139uf6gd4ytuuJRa7djt4KX07Q55uFht0M >									
	//        <  u =="0.000000000000000001" : ] 000000293745992.835777000000000000 ; 000000310852301.527820000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C038871DA52AE >									
	//     < RUSS_PFXXXI_II_metadata_line_17_____LEFBORD_INVESTMENTS_LIMITED_20231101 >									
	//        < 8U7P60d4g0v4cMmNT6lenmUDX77314m4IyrylYZyjsYJdYTBCIpTx5Zb3yFF5Ti8 >									
	//        <  u =="0.000000000000000001" : ] 000000310852301.527820000000000000 ; 000000328743174.991446000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DA52AE1F59F4D >									
	//     < RUSS_PFXXXI_II_metadata_line_18_____TT_MOBILE_20231101 >									
	//        < ZqrAC8cJEBtRdsFU797s267zb189hl8Yg8w0v6oGakoM5Jfi8iuj41Z59LC8l49H >									
	//        <  u =="0.000000000000000001" : ] 000000328743174.991446000000000000 ; 000000349118482.883723000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F59F4D214B668 >									
	//     < RUSS_PFXXXI_II_metadata_line_19_____SMARTS_SAMARA_20231101 >									
	//        < Ror57BTBSFzlQim1tp2uS984TC0TI3L2B2oD0cY6233uwVqsipTpWE94r7aXQ2NZ >									
	//        <  u =="0.000000000000000001" : ] 000000349118482.883723000000000000 ; 000000369637759.863067000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000214B66823405C0 >									
	//     < RUSS_PFXXXI_II_metadata_line_20_____MEGAFON_NORTH_WEST_20231101 >									
	//        < D8AQQfV583SUYZ27hsVQ02M80Qb8aeG3IFRA7d09Do4Nw6cjYbX5UhQKI32cFk2c >									
	//        <  u =="0.000000000000000001" : ] 000000369637759.863067000000000000 ; 000000385108258.590554000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023405C024BA0EA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXI_II_metadata_line_21_____GARS_HOLDING_LIMITED_20231101 >									
	//        < m6gzp5uZ11pUE9g821F8sLbxIV41458a2Om5ZpKExCvPxMFs7nV6fE52HJ4UXS9U >									
	//        <  u =="0.000000000000000001" : ] 000000385108258.590554000000000000 ; 000000404710135.813941000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024BA0EA26989E6 >									
	//     < RUSS_PFXXXI_II_metadata_line_22_____SMARTS_CHEBOKSARY_20231101 >									
	//        < wK0bz188G5h05079w40As93N72565My286H53V8e7w9v93alO3eIH6SmkZZ1WG0w >									
	//        <  u =="0.000000000000000001" : ] 000000404710135.813941000000000000 ; 000000421737424.895583000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026989E6283852E >									
	//     < RUSS_PFXXXI_II_metadata_line_23_____MEGAFON_ORG_20231101 >									
	//        < w8W8cpoPKcRfc58FY86Np2wT52vwW1mm15XN49G4c32Dfdl24ULM7j4ZJyb5vQTL >									
	//        <  u =="0.000000000000000001" : ] 000000421737424.895583000000000000 ; 000000441336653.471569000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000283852E2A16D21 >									
	//     < RUSS_PFXXXI_II_metadata_line_24_____NAKHODKA_TELECOM_20231101 >									
	//        < GbZoET8X73wPkJ82sXc50Sz08HLie4F5C5O4whA0Kw742ZhR2V3UiKuQxgBkBErS >									
	//        <  u =="0.000000000000000001" : ] 000000441336653.471569000000000000 ; 000000461238156.808575000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A16D212BFCB28 >									
	//     < RUSS_PFXXXI_II_metadata_line_25_____NEOSPRINT_20231101 >									
	//        < imR7RoW12Hf5Snk66i2CrUntstFc3l4lzGTjHvMDxGm04wimS8tLbe4IL6Jj3tQ4 >									
	//        <  u =="0.000000000000000001" : ] 000000461238156.808575000000000000 ; 000000479485478.659509000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BFCB282DBA304 >									
	//     < RUSS_PFXXXI_II_metadata_line_26_____SMARTS_PENZA_20231101 >									
	//        < 8oa7SJz4hy7Km0i9ToO9qejDV86304x6L67oGloZ8uC8S6o7aDc87F9OOZUxbm6u >									
	//        <  u =="0.000000000000000001" : ] 000000479485478.659509000000000000 ; 000000502172777.123001000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DBA3042FE413E >									
	//     < RUSS_PFXXXI_II_metadata_line_27_____MEGAFON_RETAIL_20231101 >									
	//        < 82CI14NSYKJQ4hFg3xpRP20K68c0k5ytOZcN3T7tQS1PW42Wg5blqeNTIbY2A1Ev >									
	//        <  u =="0.000000000000000001" : ] 000000502172777.123001000000000000 ; 000000524422236.741445000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FE413E3203470 >									
	//     < RUSS_PFXXXI_II_metadata_line_28_____FIRST_TOWER_COMPANY_20231101 >									
	//        < k860K3rDBBtuRs0l19l6Lh3JOGquPCPwmnKKYGM4F6I9fxO6hu7d66E98469xEQL >									
	//        <  u =="0.000000000000000001" : ] 000000524422236.741445000000000000 ; 000000547159477.366241000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003203470342E62C >									
	//     < RUSS_PFXXXI_II_metadata_line_29_____MEGAFON_SA_20231101 >									
	//        < HxIlIe1joa73z00A963Ihsnw0QyyOm89LqG4UT4bB1TkMoXqDpS7HMCd7oe5xb6p >									
	//        <  u =="0.000000000000000001" : ] 000000547159477.366241000000000000 ; 000000570721286.206245000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000342E62C366DA01 >									
	//     < RUSS_PFXXXI_II_metadata_line_30_____MOBICOM_KHABAROVSK_20231101 >									
	//        < 5iVGu5w5lI3jM7M87Mg5r8oolX2jx7U8t9620fl96e14N9D2O8gCL0hvK7U0cjZ2 >									
	//        <  u =="0.000000000000000001" : ] 000000570721286.206245000000000000 ; 000000594519744.451555000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000366DA0138B2A46 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXI_II_metadata_line_31_____AQUAFON_GSM_20231101 >									
	//        < 2o4A87ggH0K80P95WVqS76AD8D86qvc1sLKpvTvZvU60o3yP023Q877vS0AYwIA6 >									
	//        <  u =="0.000000000000000001" : ] 000000594519744.451555000000000000 ; 000000619133572.810140000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038B2A463B0B90D >									
	//     < RUSS_PFXXXI_II_metadata_line_32_____DIGITAL_BUSINESS_SOLUTIONS_20231101 >									
	//        < czBN3X928vt4fQs6LZ6ee4oF3j9r9855hUu8Z2UdkhwC0z91FGa6BrY1OrB4Qj5R >									
	//        <  u =="0.000000000000000001" : ] 000000619133572.810140000000000000 ; 000000637133389.318110000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B0B90D3CC303B >									
	//     < RUSS_PFXXXI_II_metadata_line_33_____KOMBELL_OOO_20231101 >									
	//        < l05R7kzP143WK7tMgfAYiv6QqxfV1NB4iYl7l95GKDk65EbUq57VeWTu9LCZtSvZ >									
	//        <  u =="0.000000000000000001" : ] 000000637133389.318110000000000000 ; 000000656878922.686170000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CC303B3EA5154 >									
	//     < RUSS_PFXXXI_II_metadata_line_34_____URALSKI_GSM_ZAO_20231101 >									
	//        < y2F0DDzfr1RFZw7CUx6V45B2VYhhCW556r7mc8vrX5rx23ATh7OSNyjUGaoy63Jz >									
	//        <  u =="0.000000000000000001" : ] 000000656878922.686170000000000000 ; 000000678208485.226699000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EA515440ADD31 >									
	//     < RUSS_PFXXXI_II_metadata_line_35_____INCORE_20231101 >									
	//        < 201453O1FL8t28GZ0KPkV6jwkAicgIlNSqpQR3IR4e1Nui7CM9vZ3pjYtuexNZ22 >									
	//        <  u =="0.000000000000000001" : ] 000000678208485.226699000000000000 ; 000000699805389.881233000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040ADD3142BD17B >									
	//     < RUSS_PFXXXI_II_metadata_line_36_____MEGALABS_20231101 >									
	//        < 2eMa3CvKAZbjTVq4gKa34AZwrgp9t5QqEMZl67FFR8Sa1E0x51zooHdkqVLM1t42 >									
	//        <  u =="0.000000000000000001" : ] 000000699805389.881233000000000000 ; 000000719118882.797284000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042BD17B44949D0 >									
	//     < RUSS_PFXXXI_II_metadata_line_37_____AQUAPHONE_GSM_20231101 >									
	//        < jC5j16LB7QTk8WrGghiDB2si644AY6CsS7q50Ka9S1xrYuFBJNe6vQhnRr6JwdE6 >									
	//        <  u =="0.000000000000000001" : ] 000000719118882.797284000000000000 ; 000000738830412.802175000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044949D04675DA1 >									
	//     < RUSS_PFXXXI_II_metadata_line_38_____TC_COMET_20231101 >									
	//        < zoh7lK2XAmgvx99j5lDmT6I4ka7AC82nPZrbXxx3SRy62O4iyy6b3QhoOs1218I5 >									
	//        <  u =="0.000000000000000001" : ] 000000738830412.802175000000000000 ; 000000760006936.709037000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004675DA1487ADB6 >									
	//     < RUSS_PFXXXI_II_metadata_line_39_____DEBTON_INVESTMENTS_LIMITED_20231101 >									
	//        < j6HrcGl1wtugYb54xk7u6fgHrDknH72qS9K965o5LE6hZVDti0GkFR4723dpKbzj >									
	//        <  u =="0.000000000000000001" : ] 000000760006936.709037000000000000 ; 000000780315253.864151000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000487ADB64A6AAA5 >									
	//     < RUSS_PFXXXI_II_metadata_line_40_____NETBYNET_HOLDING_20231101 >									
	//        < 52W9FTuJ8xkBhbDsE4t8aAd3v76LC0c2E36Ax474N0LS8nQ1o6hgtIaD5OEc65Q6 >									
	//        <  u =="0.000000000000000001" : ] 000000780315253.864151000000000000 ; 000000799361044.451549000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A6AAA54C3BA68 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}