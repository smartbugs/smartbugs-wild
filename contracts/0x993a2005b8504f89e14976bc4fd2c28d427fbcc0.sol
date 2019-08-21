pragma solidity 		^0.4.21	;						
										
	contract	AZOV_PFI_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	AZOV_PFI_I_883		"	;
		string	public		symbol =	"	AZOV_PFI_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		910127908208497000000000000					;	
										
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
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000027484138.344975600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000002036AF >									
	//     < AZOV_PFI_I_metadata_line_2_____Zaporizhia_org_20211101 >									
	//        < R8HVYyuz2aV5Sl7S9708uU0Mw568PZXuFIwd9A4k6XxSxY13FSZuZ0by0R74NtBG >									
	//        <  u =="0.000000000000000001" : ] 000000027484138.344975600000000000 ; 000000052319145.176106500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002036AF3A3B40 >									
	//     < AZOV_PFI_I_metadata_line_3_____Berdiansk_Commercial_Sea_Port_20211101 >									
	//        < N1wH3Q55ywZMw9c861283Fj8JEoJl14po37I0H19HnLjLJm7t3QN1ul90f3R034P >									
	//        <  u =="0.000000000000000001" : ] 000000052319145.176106500000000000 ; 000000071163525.960062800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003A3B40534BF6 >									
	//     < AZOV_PFI_I_metadata_line_4_____Soylu_Group_20211101 >									
	//        < 68yX4064s037ZQz2Zb6m5KvYdb0HrN8gOi8c82RM2R1L89d5lKNfNVo6YYIAzMRH >									
	//        <  u =="0.000000000000000001" : ] 000000071163525.960062800000000000 ; 000000098721130.109014200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000534BF672AC51 >									
	//     < AZOV_PFI_I_metadata_line_5_____Soylu_Group_TRK_20211101 >									
	//        < 7hIYW3CGVue4k0n5P49X79itGjYv07aX1ph2gh8R74qSA7Z9Y1S3c3B70m0xy87H >									
	//        <  u =="0.000000000000000001" : ] 000000098721130.109014200000000000 ; 000000128690014.479288000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000072AC51945103 >									
	//     < AZOV_PFI_I_metadata_line_6_____Ulusoy Holding_20211101 >									
	//        < p9apgtg81J33wmRGz8EaF720J9It505hZF2Y31YQbc4QhTi1TPEm7km0fNOTsNor >									
	//        <  u =="0.000000000000000001" : ] 000000128690014.479288000000000000 ; 000000148015290.000625000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000945103B5C94E >									
	//     < AZOV_PFI_I_metadata_line_7_____Berdyansk_Sea_Trading_Port_20211101 >									
	//        < 0bNzFNUysKlmufuFw3wpeq9erlPiXd5sjU2nir5Az4UM1igW476Auv66864Dti99 >									
	//        <  u =="0.000000000000000001" : ] 000000148015290.000625000000000000 ; 000000163690422.477893000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B5C94EDA2D33 >									
	//     < AZOV_PFI_I_metadata_line_8_____Marioupol_org_20211101 >									
	//        < rm8G4pcfDE3mxsg6TteZ8sh553k11Fp0l5Pg6CgF9g5pO4gAdl72oPFM532n26TX >									
	//        <  u =="0.000000000000000001" : ] 000000163690422.477893000000000000 ; 000000192250069.265294000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DA2D33EF3B03 >									
	//     < AZOV_PFI_I_metadata_line_9_____Donetsk_org_20211101 >									
	//        < oTrh5Z3rrfIswd5DU1ZJG5c0WiU5wfKVbavF1u67XHqh447u5DIT0skDezyefwne >									
	//        <  u =="0.000000000000000001" : ] 000000192250069.265294000000000000 ; 000000211825208.818462000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EF3B0310B2D65 >									
	//     < AZOV_PFI_I_metadata_line_10_____Marioupol_Port_Station_20211101 >									
	//        < ve1X7O3M2VSdFnEmm81vjt34tfZ41bB6s487Wo654zJa489djUtJ7ZUIM038CVT7 >									
	//        <  u =="0.000000000000000001" : ] 000000211825208.818462000000000000 ; 000000227237029.472683000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010B2D6512BAC2C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//        <  u =="0.000000000000000001" : ] 000000227237029.472683000000000000 ; 000000251792015.926684000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012BAC2C13F8CAA >									
	//     < AZOV_PFI_I_metadata_line_12_____Krasnodar_org_20211101 >									
	//        < qGJeFZx91mv3008waexSlvrS03bxzCh9IsrdidN11sz16Q5Y2CAJkdW2dYhD8jyM >									
	//        <  u =="0.000000000000000001" : ] 000000251792015.926684000000000000 ; 000000275230237.865740000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013F8CAA15F80D4 >									
	//     < AZOV_PFI_I_metadata_line_13_____Yeysk_Airport_20211101 >									
	//        < 8x4DHVmeiFNU894Rc0i2062MIhl85B7Ahi8m84tHb06I2Y68BG71f0BIG78obkgr >									
	//        <  u =="0.000000000000000001" : ] 000000275230237.865740000000000000 ; 000000302254886.057911000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015F80D417867EC >									
	//     < AZOV_PFI_I_metadata_line_14_____Kerch_infrastructure_org_20211101 >									
	//        < U321pemp8o6hVN34ecB0qg5RVIO1RnsmJo1d4imwSPQ5D3s3N6XmTuJFVkc6vOF9 >									
	//        <  u =="0.000000000000000001" : ] 000000302254886.057911000000000000 ; 000000323847560.308133000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017867EC196802A >									
	//     < AZOV_PFI_I_metadata_line_15_____Kerch_Seaport_org_20211101 >									
	//        < yCc6rr8s0cBVzuph9s6ylNBP21rcPbZm78ErIJMdwYPCb4tzl6R8AFQAugmL72ij >									
	//        <  u =="0.000000000000000001" : ] 000000323847560.308133000000000000 ; 000000344871220.647608000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000196802A1AE760A >									
	//     < AZOV_PFI_I_metadata_line_16_____Azov_org_20211101 >									
	//        < c7nd58VY5rmWdQT4hMaA7gXw2i1UDU022LHU7E5Dtv4dH2oQ4cGasnmv7tuBC7O3 >									
	//        <  u =="0.000000000000000001" : ] 000000344871220.647608000000000000 ; 000000363630455.531443000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AE760A1D48683 >									
	//     < AZOV_PFI_I_metadata_line_17_____Azov_Seaport_org_20211101 >									
	//        < v9o9PSYNX7dU03T2r46D8pqsdU5igmZ4i9P17311B3Y40s586gd6y9HNKtg6VV09 >									
	//        <  u =="0.000000000000000001" : ] 000000363630455.531443000000000000 ; 000000386704023.099696000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D486831F66B68 >									
	//     < AZOV_PFI_I_metadata_line_18_____Azovskiy_Portovyy_Elevator_20211101 >									
	//        < 2zgN1Pg5TIF8430vOP6wIq2DwiwFI3X4TUiq12sD64HKrqmN1qAh5apFLa88SR57 >									
	//        <  u =="0.000000000000000001" : ] 000000386704023.099696000000000000 ; 000000409670355.058030000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F66B68213B8AB >									
	//     < AZOV_PFI_I_metadata_line_19_____Rostov_SLD_org_20211101 >									
	//        < dJqX15tG1E8k91p0j1Q4nZP6l8KXSkq5tkAdQ1t1TJE5La7v3RjN1CFEQ7046ahG >									
	//        <  u =="0.000000000000000001" : ] 000000409670355.058030000000000000 ; 000000435279460.695434000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000213B8AB22AF193 >									
	//     < AZOV_PFI_I_metadata_line_20_____Rentastroy_20211101 >									
	//        < 0hrLLFELUW5Mn4WM9d43D6xn55fj5O7H2JgVU8Jv38lgNsd7kKGSeFM37LNho485 >									
	//        <  u =="0.000000000000000001" : ] 000000435279460.695434000000000000 ; 000000464289514.314832000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022AF193245A639 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//        <  u =="0.000000000000000001" : ] 000000464289514.314832000000000000 ; 000000492702082.516782000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000245A63925BAD54 >									
	//     < AZOV_PFI_I_metadata_line_22_____Donmasloprodukt_20211101 >									
	//        < 2rrFYz8I9181tx0R906c5z7SZC6ePzr7jR5A2q4cYhdW9ZrQuOBLnuMb2fRdiz74 >									
	//        <  u =="0.000000000000000001" : ] 000000492702082.516782000000000000 ; 000000521289104.443420000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025BAD542722899 >									
	//     < AZOV_PFI_I_metadata_line_23_____Rostovskiy_Portovyy_Elevator_Kovsh_20211101 >									
	//        < C8mrLyU34oWpwyP4oNoR8r15z4ag6mbqH6Bf7i6I8t3aoJxsp0T07D7rW7E1KRf5 >									
	//        <  u =="0.000000000000000001" : ] 000000521289104.443420000000000000 ; 000000537092326.844432000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027228992962E67 >									
	//     < AZOV_PFI_I_metadata_line_24_____Rostov_Arena_infratructure_org_20211101 >									
	//        < ml53tuGw95S0UHcIjGju78a2Nvu6svRQpZaoCsFMj7V6h25de5Ot9b9B7l9DcYkO >									
	//        <  u =="0.000000000000000001" : ] 000000537092326.844432000000000000 ; 000000556124021.251447000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002962E672B6E413 >									
	//     < AZOV_PFI_I_metadata_line_25_____Rostov_Glavny_infrastructure_org_20211101 >									
	//        < E21DMXAS629s33GAfn5sKXe913MS4Ov75TYQd8D6sOH556T3u07j7YU47SLLO38v >									
	//        <  u =="0.000000000000000001" : ] 000000556124021.251447000000000000 ; 000000585221710.723749000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B6E4132CC4D79 >									
	//     < AZOV_PFI_I_metadata_line_26_____Rostov_Heliport_infrastructure_org_20211101 >									
	//        < iIbqD9XEcnbd5GrgohDIGAyV5zbj57F1QjB01gV0Glhzr0280TXBdS4AnR5d0h5v >									
	//        <  u =="0.000000000000000001" : ] 000000585221710.723749000000000000 ; 000000605172864.152762000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CC4D792EE7B73 >									
	//     < AZOV_PFI_I_metadata_line_27_____Taganrog_org_20211101 >									
	//        < XGbTd6B5Lq0ZOMJZ8v33SdWe3297wF0t6W01E3h7H7239DowC04m6ihKTa11Rc0B >									
	//        <  u =="0.000000000000000001" : ] 000000605172864.152762000000000000 ; 000000631622690.075231000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EE7B73302CCDF >									
	//     < AZOV_PFI_I_metadata_line_28_____Rostov_Airport_org_20211101 >									
	//        < N88c0J35O3hSc145mwg3N6RI40BVSI5lZSxfd9u8vuNtnZ3s3Om0Zn1jjVE3g9y7 >									
	//        <  u =="0.000000000000000001" : ] 000000631622690.075231000000000000 ; 000000659175242.754062000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000302CCDF323E362 >									
	//     < AZOV_PFI_I_metadata_line_29_____Rostov_Airport_infrastructure_org_20211101 >									
	//        < 3r5uHHZ1vwH58biOoBHt9olGL7vs3143fw7R2my583HuYTTN4TI4HZMLwi5I5v9I >									
	//        <  u =="0.000000000000000001" : ] 000000659175242.754062000000000000 ; 000000675699092.569202000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000323E36234283AC >									
	//     < AZOV_PFI_I_metadata_line_30_____Mega_Mall_org_20211101 >									
	//        < VE8fF3a9WWtdjD8IbPLddEw5fT3kX4OC0kIZ9sS9A56T5Zvui1J1R20v75K3j8wX >									
	//        <  u =="0.000000000000000001" : ] 000000675699092.569202000000000000 ; 000000696345498.047185000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034283AC361C656 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//        <  u =="0.000000000000000001" : ] 000000696345498.047185000000000000 ; 000000724317906.625756000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000361C6563773667 >									
	//     < AZOV_PFI_I_metadata_line_32_____Zemkombank_org_20211101 >									
	//        < 3he7T75s10wowIcln2b5wQ6Sn1hFBTwGP4e4xPlQs84ZDd2Y9C462ec2XW67F5hf >									
	//        <  u =="0.000000000000000001" : ] 000000724317906.625756000000000000 ; 000000746074136.143809000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003773667392C58E >									
	//     < AZOV_PFI_I_metadata_line_33_____Telebashnya_tv_infrastrcture_org_20211101 >									
	//        < CVcR3iTG6Dv1utGHA9k9tSjchlv1m2S1JW4GznRCX0n00IAM148WUiprVk9j6q1Q >									
	//        <  u =="0.000000000000000001" : ] 000000746074136.143809000000000000 ; 000000767253427.717624000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000392C58E3ACE099 >									
	//     < AZOV_PFI_I_metadata_line_34_____Taman_Volna_infrastructures_industrielles_org_20211101 >									
	//        < z7Y8QkxflyAO5J8j0KZPO2Di89wgoeG64y6LDD9xR88C5n9r6HH9948dElMQ7elS >									
	//        <  u =="0.000000000000000001" : ] 000000767253427.717624000000000000 ; 000000787337350.561168000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003ACE0993D14043 >									
	//     < AZOV_PFI_I_metadata_line_35_____Yuzhnoye_Siyaniye_ooo_20211101 >									
	//        < PSbqbb5K6b0xE4x9bM6Z83rL49m9ThbHk9L932T426Ove5QcBRV8k74BWnp2cu9d >									
	//        <  u =="0.000000000000000001" : ] 000000787337350.561168000000000000 ; 000000815759834.184081000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D140433E7EF64 >									
	//     < AZOV_PFI_I_metadata_line_36_____Port_Krym_org_20211101 >									
	//        < pGL1wTWXcs4cFIzu7Y6GxC9fi59Mp4tl1Vsn5O5Vl2rI0xV4584cJbbR9wb1R2v6 >									
	//        <  u =="0.000000000000000001" : ] 000000815759834.184081000000000000 ; 000000832549979.807883000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E7EF644062E18 >									
	//     < AZOV_PFI_I_metadata_line_37_____Kerchenskaya_équipements_maritimes_20211101 >									
	//        < x0mvc2eq7cZeTpIR6NoYKz6Jo30j8m3K91lSWfJ8IjB2v7uxka5r3cwiX4938zz3 >									
	//        <  u =="0.000000000000000001" : ] 000000832549979.807883000000000000 ; 000000851750837.064845000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004062E1842008EB >									
	//     < AZOV_PFI_I_metadata_line_38_____Kerchenskaya_ferry_20211101 >									
	//        < wGgKl0T8W349q73WraE0MZt0JHW9yMEEpXII5o4VzQn6b9unY4O6O9QhUdO0193v >									
	//        <  u =="0.000000000000000001" : ] 000000851750837.064845000000000000 ; 000000871798803.606547000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042008EB437DAA0 >									
	//     < AZOV_PFI_I_metadata_line_39_____Kerch_Port_Krym_20211101 >									
	//        < ACv0I01O9wQEbaD6C91RS44095yUhKUWAsCHJglAhRCBMlgFgyr40nLJWu7vz7b6 >									
	//        <  u =="0.000000000000000001" : ] 000000871798803.606547000000000000 ; 000000890659794.430210000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000437DAA0451DCC3 >									
	//     < AZOV_PFI_I_metadata_line_40_____Krym_Station_infrastructure_ferroviaire_org_20211101 >									
	//        < Y3SY7nBP6u0T1Oz22F0382oOHq64c2yDeaSmxhE9Ppg8549V25ZdoelOOIQyHXg1 >									
	//        <  u =="0.000000000000000001" : ] 000000890659794.430210000000000000 ; 000000910127908.208497000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000451DCC34769FB1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}