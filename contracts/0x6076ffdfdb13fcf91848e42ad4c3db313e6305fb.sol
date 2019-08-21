pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXV_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXV_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXXV_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1025639573146450000000000000					;	
										
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
	//     < RUSS_PFXXXV_III_metadata_line_1_____ALROSA_20251101 >									
	//        < VvWqZ70Oth5t4CDcq18KY2sUX093BiFjPqOeB2JmoH5uG4p756lU011nGyAq4fLP >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000035789551.124190900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000369C4B >									
	//     < RUSS_PFXXXV_III_metadata_line_2_____ARCOS_HK_LIMITED_20251101 >									
	//        < DRhWy55zHTLuwggBV0M79l48Mt0sJLjNKMT9OveR2pOv98K197uA92w26p0Bc6s1 >									
	//        <  u =="0.000000000000000001" : ] 000000035789551.124190900000000000 ; 000000060513645.891902800000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000369C4B5C5625 >									
	//     < RUSS_PFXXXV_III_metadata_line_3_____ARCOS_ORG_20251101 >									
	//        < v61qKU7lvNL2w472Y786py7P0eAt6Cr2ygyNpdnkLPUT5K6BWsNbHsjQRiGKb88N >									
	//        <  u =="0.000000000000000001" : ] 000000060513645.891902800000000000 ; 000000087266328.332871600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005C5625852869 >									
	//     < RUSS_PFXXXV_III_metadata_line_4_____SUNLAND_HOLDINGS_SA_20251101 >									
	//        < O3Ik9oFJ0dXtY5SJ3rdLbdop4iTdPE7hf9aUp2p3205XB5oLYX030rTgoaeiSP3D >									
	//        <  u =="0.000000000000000001" : ] 000000087266328.332871600000000000 ; 000000114063530.522672000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000852869AE0C11 >									
	//     < RUSS_PFXXXV_III_metadata_line_5_____ARCOS_BELGIUM_NV_20251101 >									
	//        < AiDb27vEJU9Z41Lg5aipp2r4lFOLyV9QA3l6z8ekuDPu9ek1nHk20zzkjZZC25Mn >									
	//        <  u =="0.000000000000000001" : ] 000000114063530.522672000000000000 ; 000000132792885.694508000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AE0C11CAA039 >									
	//     < RUSS_PFXXXV_III_metadata_line_6_____MEDIAGROUP_SITIM_20251101 >									
	//        < lfdxH1kPIYa2Rd52Xc4VBHq5HV1RLPtKtJYBuarY8E1Avr7Mh0r9S66ibfFE401w >									
	//        <  u =="0.000000000000000001" : ] 000000132792885.694508000000000000 ; 000000163256003.572272000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CAA039F91BE0 >									
	//     < RUSS_PFXXXV_III_metadata_line_7_____ALROSA_FINANCE_BV_20251101 >									
	//        < 5d5uc4PDK0o3jGHq38clD7A1zx0S4SDZSso33mym70efs1EHv6oT4Rpr19aE4M4d >									
	//        <  u =="0.000000000000000001" : ] 000000163256003.572272000000000000 ; 000000184904607.342137000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F91BE011A245D >									
	//     < RUSS_PFXXXV_III_metadata_line_8_____SHIPPING_CO_ALROSA_LENA_20251101 >									
	//        < 0kbnpK7Wma5fo3hv2qCUPtCo1602oT15osiYcyfpmxsSYG6wGczB7mX34675h85Q >									
	//        <  u =="0.000000000000000001" : ] 000000184904607.342137000000000000 ; 000000207110322.972608000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011A245D13C0678 >									
	//     < RUSS_PFXXXV_III_metadata_line_9_____LENA_ORG_20251101 >									
	//        < Ymz75u36W850Q474s7n21pT3mc6RmJamdSs36WqzS9x9c99QEf5v5Eb9k7r1Yc29 >									
	//        <  u =="0.000000000000000001" : ] 000000207110322.972608000000000000 ; 000000227906513.123918000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013C067815BC1FB >									
	//     < RUSS_PFXXXV_III_metadata_line_10_____ALROSA_AFRICA_20251101 >									
	//        < 8q3QUVpVSa9S98V819JCVPbI9Ns7cUrDk8Njhnks1E8kN4Tkiet2Nf5LIUS7x8JF >									
	//        <  u =="0.000000000000000001" : ] 000000227906513.123918000000000000 ; 000000247761382.917879000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015BC1FB17A0DCA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXV_III_metadata_line_11_____INVESTMENT_GROUP_ALROSA_20251101 >									
	//        < bf68H4p8n12F2TUy47rJX5gV7sbEAf8n0l2a0bXLh047vvnJ8s5lzd58B29q0Dh1 >									
	//        <  u =="0.000000000000000001" : ] 000000247761382.917879000000000000 ; 000000266683604.919027000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017A0DCA196ED48 >									
	//     < RUSS_PFXXXV_III_metadata_line_12_____INVESTITSIONNAYA_GRUPPA_ALROSA_20251101 >									
	//        < QdArYgA17I3De00X6496Wr5lDtU16GLgDJJhLG0O94916W126xV63Hy2HY3W25I4 >									
	//        <  u =="0.000000000000000001" : ] 000000266683604.919027000000000000 ; 000000288820696.833906000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000196ED481B8B496 >									
	//     < RUSS_PFXXXV_III_metadata_line_13_____VILYUISKAYA_GES_3_20251101 >									
	//        < L42Bd10J8l1EQeRf4XJiSlM2364C1vRMwVaHW6FzM8te3C3Eaz2RdyL5fU5z8c9W >									
	//        <  u =="0.000000000000000001" : ] 000000288820696.833906000000000000 ; 000000310132625.827567000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B8B4961D9398F >									
	//     < RUSS_PFXXXV_III_metadata_line_14_____NPP_BUREVESTNIK_20251101 >									
	//        < pqfI191kE77QQ2dUVT2nZigy43P3M606p16EvywU05GAJEe04De8PQ3gDOJDK37U >									
	//        <  u =="0.000000000000000001" : ] 000000310132625.827567000000000000 ; 000000332392456.531638000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D9398F1FB30CE >									
	//     < RUSS_PFXXXV_III_metadata_line_15_____NARNAUL_KRISTALL_FACTORY_20251101 >									
	//        < pf8XGQ351Uwr9jUTc7Y8dI7deqj9wrM15Q67Kfj09WAfIjB5cmdG2F156VjXxiiq >									
	//        <  u =="0.000000000000000001" : ] 000000332392456.531638000000000000 ; 000000354299281.786558000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FB30CE21C9E28 >									
	//     < RUSS_PFXXXV_III_metadata_line_16_____NARNAUL_ORG_20251101 >									
	//        < E96W2r6Wf7MtTIt5d9kmTpAxqmQd597bcDSA61T0GuoEb2Vw7P7QAG1Xg5tp2C3r >									
	//        <  u =="0.000000000000000001" : ] 000000354299281.786558000000000000 ; 000000378475889.388452000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021C9E282418225 >									
	//     < RUSS_PFXXXV_III_metadata_line_17_____HIDROELECTRICA_CHICAPA_SARL_20251101 >									
	//        < q5wYB8IOnX1x3v764yv09AAC9X5UGIi8cz649USXg8G8Fy68lZ45ZWrjz2DtnfMc >									
	//        <  u =="0.000000000000000001" : ] 000000378475889.388452000000000000 ; 000000398258641.497143000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000241822525FB1C8 >									
	//     < RUSS_PFXXXV_III_metadata_line_18_____CHICAPA_ORG_20251101 >									
	//        < i070tMwjisW8n2Uj2879c5l385Dd422W9esFe6mxlzmOyii41R2B6toGJhifvMW0 >									
	//        <  u =="0.000000000000000001" : ] 000000398258641.497143000000000000 ; 000000430450841.934595000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025FB1C8290D0DC >									
	//     < RUSS_PFXXXV_III_metadata_line_19_____ALROSA_VGS_LLC_20251101 >									
	//        < qCCQ016Gn1W41VA15326u14W747B30q47RvDk61UV5VEm4fL9B46442m7FEboA3J >									
	//        <  u =="0.000000000000000001" : ] 000000430450841.934595000000000000 ; 000000451337794.658309000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000290D0DC2B0AFD3 >									
	//     < RUSS_PFXXXV_III_metadata_line_20_____ARCOS_DIAMOND_ISRAEL_20251101 >									
	//        < y6qr264uU4h0L874qs5cdfw8KvExgYA1HKLTD776zPqM7h9iBk5f5t7vI68741j8 >									
	//        <  u =="0.000000000000000001" : ] 000000451337794.658309000000000000 ; 000000478375492.986565000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B0AFD32D9F16D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXV_III_metadata_line_21_____ALMAZY_ANABARA_20251101 >									
	//        < Q5glH2KUMEJr4rwwMu0Wcy0YUOWHw5k9G4l89L5Jyxx86oO7kiw60Idn6qH9SbhC >									
	//        <  u =="0.000000000000000001" : ] 000000478375492.986565000000000000 ; 000000502538751.768340000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D9F16D2FED033 >									
	//     < RUSS_PFXXXV_III_metadata_line_22_____ALMAZY_ORG_20251101 >									
	//        < Mdr2E8v2mxYBWeYoBSUl4kkmkPsl2Au8VaIH89LGjhDFOG07bEPQzV6IM3pNvr5h >									
	//        <  u =="0.000000000000000001" : ] 000000502538751.768340000000000000 ; 000000522910597.568887000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FED03331DE5F4 >									
	//     < RUSS_PFXXXV_III_metadata_line_23_____ALROSA_ORG_20251101 >									
	//        < ufUkL3E608Ir8Az64y49pEfMopS9aypoa3LB5urmK4OG34Qp3Oz7Ho510ZXDB0Kj >									
	//        <  u =="0.000000000000000001" : ] 000000522910597.568887000000000000 ; 000000550929747.408203000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031DE5F4348A6EF >									
	//     < RUSS_PFXXXV_III_metadata_line_24_____SEVERALMAZ_20251101 >									
	//        < G0PxR601Ci8kqYZ06uLC8z7YTB3Is6lh3xnn2X805Q1mOMkE73uRccnCExd2F6N6 >									
	//        <  u =="0.000000000000000001" : ] 000000550929747.408203000000000000 ; 000000580855708.908755000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000348A6EF37650C3 >									
	//     < RUSS_PFXXXV_III_metadata_line_25_____ARCOS_USA_20251101 >									
	//        < 3ZigB22exXe8AiRBYrdz6pLidUX7cQ0jSrRd03rPEHjAMeac8VI8M1m5132X9cNh >									
	//        <  u =="0.000000000000000001" : ] 000000580855708.908755000000000000 ; 000000604604060.304202000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037650C339A8D76 >									
	//     < RUSS_PFXXXV_III_metadata_line_26_____NYURBA_20251101 >									
	//        < 8K5A0Ph12iy4io595uJiIRNz9X30LeBi63ctcl7GLtK1Fk2qpX0qx6ecaLexsYNa >									
	//        <  u =="0.000000000000000001" : ] 000000604604060.304202000000000000 ; 000000636823088.031862000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039A8D763CBB705 >									
	//     < RUSS_PFXXXV_III_metadata_line_27_____NYURBA_ORG_20251101 >									
	//        < 77m60N0XaFDmlE8s3q1Gn3d44cAMQqFxu5Rk6PjVAWCv79867MRXSnffSX54o6v6 >									
	//        <  u =="0.000000000000000001" : ] 000000636823088.031862000000000000 ; 000000662542185.678580000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CBB7053F2F58B >									
	//     < RUSS_PFXXXV_III_metadata_line_28_____EAST_DMCC_20251101 >									
	//        < 1q3MDlrp3U70u8umRwagsqX993Y9C232Ho14A4gS1Z6kE1mIHOCeN3WCT74BeeVp >									
	//        <  u =="0.000000000000000001" : ] 000000662542185.678580000000000000 ; 000000686668607.686575000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F2F58B417C5ED >									
	//     < RUSS_PFXXXV_III_metadata_line_29_____ALROSA_FINANCE_SA_20251101 >									
	//        < 6y3Tuq2bbYwdkh4eOuWP7wzg7AzcmWSGNvl7h7Zwh7cVDd1FYWgWGJAtsK3d6jXe >									
	//        <  u =="0.000000000000000001" : ] 000000686668607.686575000000000000 ; 000000711335225.193994000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000417C5ED43D6953 >									
	//     < RUSS_PFXXXV_III_metadata_line_30_____ALROSA_OVERSEAS_SA_20251101 >									
	//        < 7ty9AwV2XiZhvt54ggHlz49O7Ttly407fysihvdar08lhDPf6barsQUJa4061HjE >									
	//        <  u =="0.000000000000000001" : ] 000000711335225.193994000000000000 ; 000000744041245.381759000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043D695346F511D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXV_III_metadata_line_31_____ARCOS_EAST_DMCC_20251101 >									
	//        < 2L0d7MYj15j5w4Slv442rqQCZ7HPYlvAs99aXAdLb3G9WKrM3T7f96TPh5JV4zBX >									
	//        <  u =="0.000000000000000001" : ] 000000744041245.381759000000000000 ; 000000768853176.879993000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046F511D4952D46 >									
	//     < RUSS_PFXXXV_III_metadata_line_32_____HIDROCHICAPA_SARL_20251101 >									
	//        < nbx975T3UNtoZyf1q3HS4mxoQU9Zuk9gcX48lte4h85Jpc9d7yzJgNR3AwSTGuJa >									
	//        <  u =="0.000000000000000001" : ] 000000768853176.879993000000000000 ; 000000799647406.756539000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004952D464C42A45 >									
	//     < RUSS_PFXXXV_III_metadata_line_33_____ALROSA_GAZ_20251101 >									
	//        < N7qH3Lmrc1G6iP1Jj0UgG3e5CA49iFfX1JOTEaCQynf7uzt8x89Su673OTe1bUPR >									
	//        <  u =="0.000000000000000001" : ] 000000799647406.756539000000000000 ; 000000826593714.267386000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C42A454ED482B >									
	//     < RUSS_PFXXXV_III_metadata_line_34_____SUNLAND_TRADING_SA_20251101 >									
	//        < iMvjcaeV4ml1uPp2bS2SasHcthZomw3aUbJmOW36lAgLYyXbeUKY0oj8H9WaXBC9 >									
	//        <  u =="0.000000000000000001" : ] 000000826593714.267386000000000000 ; 000000858101736.517802000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004ED482B51D5BFE >									
	//     < RUSS_PFXXXV_III_metadata_line_35_____ORYOL_ALROSA_20251101 >									
	//        < SMJvbe52sC5g2386085DKdbxWNeC5622K99yuUThqBih9EgEoh5feQuphIYFRpjb >									
	//        <  u =="0.000000000000000001" : ] 000000858101736.517802000000000000 ; 000000885792919.396686000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000051D5BFE5479CDC >									
	//     < RUSS_PFXXXV_III_metadata_line_36_____GOLUBAYA_VOLNA_HEALTH_RESORT_20251101 >									
	//        < 9NY8qMP87jWx0N1u13zw1yg9s6D0hlA2W9xsw8jK6eiOtLimpPpx6L1sgaB9f176 >									
	//        <  u =="0.000000000000000001" : ] 000000885792919.396686000000000000 ; 000000904470131.292612000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005479CDC5641CA5 >									
	//     < RUSS_PFXXXV_III_metadata_line_37_____GOLUBAYA_ORG_20251101 >									
	//        < 4trg4D03Y5r97H5Tv6H0JUWDnEWThJ4lS1i7BSPuqlx50PfJ6Oz3ED9P5YpADdL7 >									
	//        <  u =="0.000000000000000001" : ] 000000904470131.292612000000000000 ; 000000928679953.395557000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005641CA55890D9B >									
	//     < RUSS_PFXXXV_III_metadata_line_38_____SEVERNAYA_GORNO_GEOLOGIC_KOM_TERRA_20251101 >									
	//        < g6iH7HhugM55Qzg4pGa53uKbfzA2gc32Jo7h43w66Fah46lTLFaX19SqQ5458rVM >									
	//        <  u =="0.000000000000000001" : ] 000000928679953.395557000000000000 ; 000000963895746.914430000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005890D9B5BEC9C7 >									
	//     < RUSS_PFXXXV_III_metadata_line_39_____SEVERNAYA_ORG_20251101 >									
	//        < vQ553BYcc5RsfjNBX1iK5vP6P98hJcXCPFmsGt8SrFa8N39JruF3XONEHVA9R2Y7 >									
	//        <  u =="0.000000000000000001" : ] 000000963895746.914430000000000000 ; 000000996113246.208171000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005BEC9C75EFF2BD >									
	//     < RUSS_PFXXXV_III_metadata_line_40_____ALROSA_NEVA_20251101 >									
	//        < SD795cw54qaQ349O8pYpv8Qa4dli3lqzk8wq83SMM1R736cKqHIos4XMMd4p2r01 >									
	//        <  u =="0.000000000000000001" : ] 000000996113246.208171000000000000 ; 000001025639573.146450000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005EFF2BD61D0075 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}