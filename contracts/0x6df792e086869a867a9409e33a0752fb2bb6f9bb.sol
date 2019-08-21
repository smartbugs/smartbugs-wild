pragma solidity 		^0.4.21	;						
										
	contract	AZOV_PFI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	AZOV_PFI_I_883		"	;
		string	public		symbol =	"	AZOV_PFI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		871427322879442000000000000					;	
										
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
	//     < AZOV_PFI_I_metadata_line_1_____Berdyansk_org_20211101 >									
	//        < 8MuCwK1oI9bmP8TDQ2gyaPPNHOwp13xIkV8q5fTsXc0bQyDqSSc8e8mo30yzJC47 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000018582985.975538200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001C5AFB >									
	//     < AZOV_PFI_I_metadata_line_2_____Zaporizhia_org_20211101 >									
	//        < R8HVYyuz2aV5Sl7S9708uU0Mw568PZXuFIwd9A4k6XxSxY13FSZuZ0by0R74NtBG >									
	//        <  u =="0.000000000000000001" : ] 000000018582985.975538200000000000 ; 000000040681569.376604500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001C5AFB3E133D >									
	//     < AZOV_PFI_I_metadata_line_3_____Berdiansk_Commercial_Sea_Port_20211101 >									
	//        < N1wH3Q55ywZMw9c861283Fj8JEoJl14po37I0H19HnLjLJm7t3QN1ul90f3R034P >									
	//        <  u =="0.000000000000000001" : ] 000000040681569.376604500000000000 ; 000000064694258.639556600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003E133D62B732 >									
	//     < AZOV_PFI_I_metadata_line_4_____Soylu_Group_20211101 >									
	//        < 68yX4064s037ZQz2Zb6m5KvYdb0HrN8gOi8c82RM2R1L89d5lKNfNVo6YYIAzMRH >									
	//        <  u =="0.000000000000000001" : ] 000000064694258.639556600000000000 ; 000000085253943.543061900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000062B732821652 >									
	//     < AZOV_PFI_I_metadata_line_5_____Soylu_Group_TRK_20211101 >									
	//        < 7hIYW3CGVue4k0n5P49X79itGjYv07aX1ph2gh8R74qSA7Z9Y1S3c3B70m0xy87H >									
	//        <  u =="0.000000000000000001" : ] 000000085253943.543061900000000000 ; 000000105903052.213122000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000821652A19861 >									
	//     < AZOV_PFI_I_metadata_line_6_____Ulusoy Holding_20211101 >									
	//        < p9apgtg81J33wmRGz8EaF720J9It505hZF2Y31YQbc4QhTi1TPEm7km0fNOTsNor >									
	//        <  u =="0.000000000000000001" : ] 000000105903052.213122000000000000 ; 000000127841605.850458000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A19861C31221 >									
	//     < AZOV_PFI_I_metadata_line_7_____Berdyansk_Sea_Trading_Port_20211101 >									
	//        < 0bNzFNUysKlmufuFw3wpeq9erlPiXd5sjU2nir5Az4UM1igW476Auv66864Dti99 >									
	//        <  u =="0.000000000000000001" : ] 000000127841605.850458000000000000 ; 000000146623095.337574000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C31221DFBAA6 >									
	//     < AZOV_PFI_I_metadata_line_8_____Marioupol_org_20211101 >									
	//        < rm8G4pcfDE3mxsg6TteZ8sh553k11Fp0l5Pg6CgF9g5pO4gAdl72oPFM532n26TX >									
	//        <  u =="0.000000000000000001" : ] 000000146623095.337574000000000000 ; 000000170286037.717154000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000DFBAA6103D5FC >									
	//     < AZOV_PFI_I_metadata_line_9_____Donetsk_org_20211101 >									
	//        < oTrh5Z3rrfIswd5DU1ZJG5c0WiU5wfKVbavF1u67XHqh447u5DIT0skDezyefwne >									
	//        <  u =="0.000000000000000001" : ] 000000170286037.717154000000000000 ; 000000194749898.690654000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000103D5FC1292A2E >									
	//     < AZOV_PFI_I_metadata_line_10_____Marioupol_Port_Station_20211101 >									
	//        < ve1X7O3M2VSdFnEmm81vjt34tfZ41bB6s487Wo654zJa489djUtJ7ZUIM038CVT7 >									
	//        <  u =="0.000000000000000001" : ] 000000194749898.690654000000000000 ; 000000214590775.434524000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001292A2E1477086 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < AZOV_PFI_I_metadata_line_11_____Yeysk_org_20211101 >									
	//        < garJumg0SBjeMOfrMi6yUb25e3Jficq1iJ4pv6U27A2RTP9Ja1os4ndzbSKS965p >									
	//        <  u =="0.000000000000000001" : ] 000000214590775.434524000000000000 ; 000000230188958.045215000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000147708615F3D90 >									
	//     < AZOV_PFI_I_metadata_line_12_____Krasnodar_org_20211101 >									
	//        < qGJeFZx91mv3008waexSlvrS03bxzCh9IsrdidN11sz16Q5Y2CAJkdW2dYhD8jyM >									
	//        <  u =="0.000000000000000001" : ] 000000230188958.045215000000000000 ; 000000258921910.174612000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015F3D9018B155F >									
	//     < AZOV_PFI_I_metadata_line_13_____Yeysk_Airport_20211101 >									
	//        < 8x4DHVmeiFNU894Rc0i2062MIhl85B7Ahi8m84tHb06I2Y68BG71f0BIG78obkgr >									
	//        <  u =="0.000000000000000001" : ] 000000258921910.174612000000000000 ; 000000277661918.413201000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018B155F1A7ADB0 >									
	//     < AZOV_PFI_I_metadata_line_14_____Kerch_infrastructure_org_20211101 >									
	//        < U321pemp8o6hVN34ecB0qg5RVIO1RnsmJo1d4imwSPQ5D3s3N6XmTuJFVkc6vOF9 >									
	//        <  u =="0.000000000000000001" : ] 000000277661918.413201000000000000 ; 000000295935453.806363000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A7ADB01C38FC9 >									
	//     < AZOV_PFI_I_metadata_line_15_____Kerch_Seaport_org_20211101 >									
	//        < yCc6rr8s0cBVzuph9s6ylNBP21rcPbZm78ErIJMdwYPCb4tzl6R8AFQAugmL72ij >									
	//        <  u =="0.000000000000000001" : ] 000000295935453.806363000000000000 ; 000000316326163.685136000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C38FC91E2ACE8 >									
	//     < AZOV_PFI_I_metadata_line_16_____Azov_org_20211101 >									
	//        < c7nd58VY5rmWdQT4hMaA7gXw2i1UDU022LHU7E5Dtv4dH2oQ4cGasnmv7tuBC7O3 >									
	//        <  u =="0.000000000000000001" : ] 000000316326163.685136000000000000 ; 000000338045460.244604000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E2ACE8203D102 >									
	//     < AZOV_PFI_I_metadata_line_17_____Azov_Seaport_org_20211101 >									
	//        < v9o9PSYNX7dU03T2r46D8pqsdU5igmZ4i9P17311B3Y40s586gd6y9HNKtg6VV09 >									
	//        <  u =="0.000000000000000001" : ] 000000338045460.244604000000000000 ; 000000364211864.153101000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000203D10222BBE42 >									
	//     < AZOV_PFI_I_metadata_line_18_____Azovskiy_Portovyy_Elevator_20211101 >									
	//        < 2zgN1Pg5TIF8430vOP6wIq2DwiwFI3X4TUiq12sD64HKrqmN1qAh5apFLa88SR57 >									
	//        <  u =="0.000000000000000001" : ] 000000364211864.153101000000000000 ; 000000393728446.628753000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022BBE42258C82D >									
	//     < AZOV_PFI_I_metadata_line_19_____Rostov_SLD_org_20211101 >									
	//        < dJqX15tG1E8k91p0j1Q4nZP6l8KXSkq5tkAdQ1t1TJE5La7v3RjN1CFEQ7046ahG >									
	//        <  u =="0.000000000000000001" : ] 000000393728446.628753000000000000 ; 000000411009158.574530000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000258C82D2732674 >									
	//     < AZOV_PFI_I_metadata_line_20_____Rentastroy_20211101 >									
	//        < 0hrLLFELUW5Mn4WM9d43D6xn55fj5O7H2JgVU8Jv38lgNsd7kKGSeFM37LNho485 >									
	//        <  u =="0.000000000000000001" : ] 000000411009158.574530000000000000 ; 000000437566720.011411000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000273267429BAC80 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < AZOV_PFI_I_metadata_line_21_____Moscow_Industrial_Bank_20211101 >									
	//        < XoM5UKczwHt8YEV4e6QxgXVw003L0XnnS8EpIu2OX7X37T56vH2SvFyZKMvI14y0 >									
	//        <  u =="0.000000000000000001" : ] 000000437566720.011411000000000000 ; 000000458994137.648048000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029BAC802BC5E96 >									
	//     < AZOV_PFI_I_metadata_line_22_____Donmasloprodukt_20211101 >									
	//        < 2rrFYz8I9181tx0R906c5z7SZC6ePzr7jR5A2q4cYhdW9ZrQuOBLnuMb2fRdiz74 >									
	//        <  u =="0.000000000000000001" : ] 000000458994137.648048000000000000 ; 000000477671935.321080000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BC5E962D8DE9A >									
	//     < AZOV_PFI_I_metadata_line_23_____Rostovskiy_Portovyy_Elevator_Kovsh_20211101 >									
	//        < C8mrLyU34oWpwyP4oNoR8r15z4ag6mbqH6Bf7i6I8t3aoJxsp0T07D7rW7E1KRf5 >									
	//        <  u =="0.000000000000000001" : ] 000000477671935.321080000000000000 ; 000000498289432.819016000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D8DE9A2F8544F >									
	//     < AZOV_PFI_I_metadata_line_24_____Rostov_Arena_infratructure_org_20211101 >									
	//        < ml53tuGw95S0UHcIjGju78a2Nvu6svRQpZaoCsFMj7V6h25de5Ot9b9B7l9DcYkO >									
	//        <  u =="0.000000000000000001" : ] 000000498289432.819016000000000000 ; 000000524452891.115634000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F8544F3204069 >									
	//     < AZOV_PFI_I_metadata_line_25_____Rostov_Glavny_infrastructure_org_20211101 >									
	//        < E21DMXAS629s33GAfn5sKXe913MS4Ov75TYQd8D6sOH556T3u07j7YU47SLLO38v >									
	//        <  u =="0.000000000000000001" : ] 000000524452891.115634000000000000 ; 000000546879802.702462000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000320406934278EC >									
	//     < AZOV_PFI_I_metadata_line_26_____Rostov_Heliport_infrastructure_org_20211101 >									
	//        < iIbqD9XEcnbd5GrgohDIGAyV5zbj57F1QjB01gV0Glhzr0280TXBdS4AnR5d0h5v >									
	//        <  u =="0.000000000000000001" : ] 000000546879802.702462000000000000 ; 000000576399282.277530000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034278EC36F83F8 >									
	//     < AZOV_PFI_I_metadata_line_27_____Taganrog_org_20211101 >									
	//        < XGbTd6B5Lq0ZOMJZ8v33SdWe3297wF0t6W01E3h7H7239DowC04m6ihKTa11Rc0B >									
	//        <  u =="0.000000000000000001" : ] 000000576399282.277530000000000000 ; 000000593008987.726810000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036F83F8388DC23 >									
	//     < AZOV_PFI_I_metadata_line_28_____Rostov_Airport_org_20211101 >									
	//        < N88c0J35O3hSc145mwg3N6RI40BVSI5lZSxfd9u8vuNtnZ3s3Om0Zn1jjVE3g9y7 >									
	//        <  u =="0.000000000000000001" : ] 000000593008987.726810000000000000 ; 000000620286050.746085000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000388DC233B27B3D >									
	//     < AZOV_PFI_I_metadata_line_29_____Rostov_Airport_infrastructure_org_20211101 >									
	//        < 3r5uHHZ1vwH58biOoBHt9olGL7vs3143fw7R2my583HuYTTN4TI4HZMLwi5I5v9I >									
	//        <  u =="0.000000000000000001" : ] 000000620286050.746085000000000000 ; 000000638186733.748269000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B27B3D3CDCBB1 >									
	//     < AZOV_PFI_I_metadata_line_30_____Mega_Mall_org_20211101 >									
	//        < VE8fF3a9WWtdjD8IbPLddEw5fT3kX4OC0kIZ9sS9A56T5Zvui1J1R20v75K3j8wX >									
	//        <  u =="0.000000000000000001" : ] 000000638186733.748269000000000000 ; 000000656752110.481741000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CDCBB13EA1FCB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < AZOV_PFI_I_metadata_line_31_____Mir_Remonta_org_20211101 >									
	//        < kvvN8iX68lalhRGGbG1610NZee74bbvdUygGZbxwil3BkF4153tii8Yhqh04Hlps >									
	//        <  u =="0.000000000000000001" : ] 000000656752110.481741000000000000 ; 000000684661939.800229000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003EA1FCB414B612 >									
	//     < AZOV_PFI_I_metadata_line_32_____Zemkombank_org_20211101 >									
	//        < 3he7T75s10wowIcln2b5wQ6Sn1hFBTwGP4e4xPlQs84ZDd2Y9C462ec2XW67F5hf >									
	//        <  u =="0.000000000000000001" : ] 000000684661939.800229000000000000 ; 000000702193529.593828000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000414B61242F7659 >									
	//     < AZOV_PFI_I_metadata_line_33_____Telebashnya_tv_infrastrcture_org_20211101 >									
	//        < CVcR3iTG6Dv1utGHA9k9tSjchlv1m2S1JW4GznRCX0n00IAM148WUiprVk9j6q1Q >									
	//        <  u =="0.000000000000000001" : ] 000000702193529.593828000000000000 ; 000000725602603.671153000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042F76594532E84 >									
	//     < AZOV_PFI_I_metadata_line_34_____Taman_Volna_infrastructures_industrielles_org_20211101 >									
	//        < z7Y8QkxflyAO5J8j0KZPO2Di89wgoeG64y6LDD9xR88C5n9r6HH9948dElMQ7elS >									
	//        <  u =="0.000000000000000001" : ] 000000725602603.671153000000000000 ; 000000741318596.087748000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004532E8446B2994 >									
	//     < AZOV_PFI_I_metadata_line_35_____Yuzhnoye_Siyaniye_ooo_20211101 >									
	//        < PSbqbb5K6b0xE4x9bM6Z83rL49m9ThbHk9L932T426Ove5QcBRV8k74BWnp2cu9d >									
	//        <  u =="0.000000000000000001" : ] 000000741318596.087748000000000000 ; 000000764617287.174949000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046B299448EB6A1 >									
	//     < AZOV_PFI_I_metadata_line_36_____Port_Krym_org_20211101 >									
	//        < pGL1wTWXcs4cFIzu7Y6GxC9fi59Mp4tl1Vsn5O5Vl2rI0xV4584cJbbR9wb1R2v6 >									
	//        <  u =="0.000000000000000001" : ] 000000764617287.174949000000000000 ; 000000780037330.115290000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048EB6A14A63E15 >									
	//     < AZOV_PFI_I_metadata_line_37_____Kerchenskaya_équipements_maritimes_20211101 >									
	//        < x0mvc2eq7cZeTpIR6NoYKz6Jo30j8m3K91lSWfJ8IjB2v7uxka5r3cwiX4938zz3 >									
	//        <  u =="0.000000000000000001" : ] 000000780037330.115290000000000000 ; 000000797063539.955568000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A63E154C038F2 >									
	//     < AZOV_PFI_I_metadata_line_38_____Kerchenskaya_ferry_20211101 >									
	//        < wGgKl0T8W349q73WraE0MZt0JHW9yMEEpXII5o4VzQn6b9unY4O6O9QhUdO0193v >									
	//        <  u =="0.000000000000000001" : ] 000000797063539.955568000000000000 ; 000000821248605.893593000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C038F24E5203D >									
	//     < AZOV_PFI_I_metadata_line_39_____Kerch_Port_Krym_20211101 >									
	//        < ACv0I01O9wQEbaD6C91RS44095yUhKUWAsCHJglAhRCBMlgFgyr40nLJWu7vz7b6 >									
	//        <  u =="0.000000000000000001" : ] 000000821248605.893593000000000000 ; 000000845254696.628970000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E5203D509C19E >									
	//     < AZOV_PFI_I_metadata_line_40_____Krym_Station_infrastructure_ferroviaire_org_20211101 >									
	//        < Y3SY7nBP6u0T1Oz22F0382oOHq64c2yDeaSmxhE9Ppg8549V25ZdoelOOIQyHXg1 >									
	//        <  u =="0.000000000000000001" : ] 000000845254696.628970000000000000 ; 000000871427322.879442000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000509C19E531B14C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}