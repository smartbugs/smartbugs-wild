pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFV_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFV_I_883		"	;
		string	public		symbol =	"	RUSS_PFV_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		601150973675601000000000000					;	
										
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
	//     < RUSS_PFV_I_metadata_line_1_____SIRIUS_ORG_20211101 >									
	//        < yLgOg3Ypa1TxcG477fOJwe52sK9ZoO3kQR588CBzYY9KXl4pu0S63RpNCURmv2Sy >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000013784239.282422200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000150878 >									
	//     < RUSS_PFV_I_metadata_line_2_____SIRIUS_DAO_20211101 >									
	//        < 9QhZvCLxyrP1GT66t9uB27v33OT3vS0b779EM9IA5TJTJZe269b3w9acYHvKv7Tu >									
	//        <  u =="0.000000000000000001" : ] 000000013784239.282422200000000000 ; 000000027708949.906841700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001508782A47CF >									
	//     < RUSS_PFV_I_metadata_line_3_____SIRIUS_DAOPI_20211101 >									
	//        < 4m1u8nPy6iNYtayavVOvs9k4Qs67D2jXJSoFVNlw1nFC77U6KwYLKOHFP0FOCs59 >									
	//        <  u =="0.000000000000000001" : ] 000000027708949.906841700000000000 ; 000000040913001.775763100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002A47CF3E6DA4 >									
	//     < RUSS_PFV_I_metadata_line_4_____SIRIUS_BIMI_20211101 >									
	//        < s18s4R5YJof6uOtEW7apx9wS7MTmbqNO5lL8H60Z70lc2FQH1FDL9L01uSm2n0tA >									
	//        <  u =="0.000000000000000001" : ] 000000040913001.775763100000000000 ; 000000057709914.222625500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003E6DA4580EEF >									
	//     < RUSS_PFV_I_metadata_line_5_____EDUCATIONAL_CENTER_SIRIUS_ORG_20211101 >									
	//        < r22A4O2v7qsfa4as32J88DgmI3hr12u56R3993s6F5pL6LvwVxcSe6l5475YMIT4 >									
	//        <  u =="0.000000000000000001" : ] 000000057709914.222625500000000000 ; 000000071791726.952027700000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000580EEF6D8BA5 >									
	//     < RUSS_PFV_I_metadata_line_6_____EDUCATIONAL_CENTER_SIRIUS_DAO_20211101 >									
	//        < 805ovx85K20Q9udu4K53D6OAI0lOeZZ1Vq0g2RhDwnd9Olv3JlZgBT9nZ16lN4K7 >									
	//        <  u =="0.000000000000000001" : ] 000000071791726.952027700000000000 ; 000000087764558.844433200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006D8BA585EB08 >									
	//     < RUSS_PFV_I_metadata_line_7_____EDUCATIONAL_CENTER_SIRIUS_DAOPI_20211101 >									
	//        < x0S0j467xT709nJDrUSHQD8pVwOoXAEq0e6nAj1EM95Rl46JOqUPq7cJ42PuC04X >									
	//        <  u =="0.000000000000000001" : ] 000000087764558.844433200000000000 ; 000000102999260.328998000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000085EB089D2A16 >									
	//     < RUSS_PFV_I_metadata_line_8_____EDUCATIONAL_CENTER_SIRIUS_DAC_20211101 >									
	//        < Xxy05bGu37hhIDb46W345PHsticmwod613MRlnWTwQRt56zQ6OZnHUti60d9s2k3 >									
	//        <  u =="0.000000000000000001" : ] 000000102999260.328998000000000000 ; 000000118509147.604150000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009D2A16B4D4A3 >									
	//     < RUSS_PFV_I_metadata_line_9_____SOCHI_PARK_HOTEL_20211101 >									
	//        < uv95I4lbMbU6jQ2nWOJXDRRMnK4FrmW3wbd865F83p45WIwP2hWnXj529V1Kw1KK >									
	//        <  u =="0.000000000000000001" : ] 000000118509147.604150000000000000 ; 000000133084225.174826000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B4D4A3CB1207 >									
	//     < RUSS_PFV_I_metadata_line_10_____GOSTINICHNYY_KOMPLEKS_BOGATYR_20211101 >									
	//        < LdoZqyq0CJ6N64PawjSs8H0mnqcx56f1f995w2oek79rFVnAy25YIijDd22EpuDy >									
	//        <  u =="0.000000000000000001" : ] 000000133084225.174826000000000000 ; 000000147741322.245952000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CB1207E16F74 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFV_I_metadata_line_11_____SIRIUS_IKAISA_BIMI_I_20211101 >									
	//        < tax5oz5SXR4OIX18z21l5Hxu5Eu5j4001qzVtI84L7236QVwTlGNVA6CJ1012ApG >									
	//        <  u =="0.000000000000000001" : ] 000000147741322.245952000000000000 ; 000000162694984.392885000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E16F74F840BA >									
	//     < RUSS_PFV_I_metadata_line_12_____SIRIUS_IKAISA_BIMI_II_20211101 >									
	//        < OAa3WJa56o0YxQE847Sf1LeabP05E5VBx9c60wmADGG4MN5CV6Ei8MJc2yUC23D3 >									
	//        <  u =="0.000000000000000001" : ] 000000162694984.392885000000000000 ; 000000176281883.873433000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F840BA10CFC1C >									
	//     < RUSS_PFV_I_metadata_line_13_____SIRIUS_IKAISA_BIMI_III_20211101 >									
	//        < llIZKwwsZc69G6Op5LDrjNy577UdMb8NBatzYItx049gcl15eFV2lZD372746Nv4 >									
	//        <  u =="0.000000000000000001" : ] 000000176281883.873433000000000000 ; 000000192497216.853430000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010CFC1C125BA3A >									
	//     < RUSS_PFV_I_metadata_line_14_____SIRIUS_IKAISA_BIMI_IV_20211101 >									
	//        < b2TQnjVvqA0rOgf30z5PhiVWl74HcjqtCjdVR175vUR53Qo162ogX6eiI9PTApk3 >									
	//        <  u =="0.000000000000000001" : ] 000000192497216.853430000000000000 ; 000000209281376.212930000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000125BA3A13F568A >									
	//     < RUSS_PFV_I_metadata_line_15_____SIRIUS_IKAISA_BIMI_V_20211101 >									
	//        < X2zPPZ09U4L8uLJ2M5MOMpemdO27cQOv5EHHmb71Z505wlOaeG7ib4A20CURlay0 >									
	//        <  u =="0.000000000000000001" : ] 000000209281376.212930000000000000 ; 000000224315463.414662000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013F568A156473A >									
	//     < RUSS_PFV_I_metadata_line_16_____SIRIUS_IKAISA_BIMI_VI_20211101 >									
	//        < R2abx1dfGoAm6I226Sk9TsG1pzjUgz242aiP4opnze6NUCd8erQ81pNFPVXQIQpX >									
	//        <  u =="0.000000000000000001" : ] 000000224315463.414662000000000000 ; 000000238131932.311190000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000156473A16B5C49 >									
	//     < RUSS_PFV_I_metadata_line_17_____SIRIUS_IKAISA_BIMI_VII_20211101 >									
	//        < uvl7cX87Og4603wLFh93CLFDo4z3rCK51Q4XYY7jeW8K443DQGwmx6Y19E8545lZ >									
	//        <  u =="0.000000000000000001" : ] 000000238131932.311190000000000000 ; 000000253785003.140310000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016B5C491833EC4 >									
	//     < RUSS_PFV_I_metadata_line_18_____SIRIUS_IKAISA_BIMI_VIII_20211101 >									
	//        < nptGspw26KWyd736LeKeFSao1D33NWf1JqcE640NIX8cKlB6MJTO3b5Xgzla4ik4 >									
	//        <  u =="0.000000000000000001" : ] 000000253785003.140310000000000000 ; 000000267049857.874407000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001833EC41977C5A >									
	//     < RUSS_PFV_I_metadata_line_19_____SIRIUS_IKAISA_BIMI_IX_20211101 >									
	//        < PJ1l3qd6Af2NHICLon1vbEklCr1Y1NCR4t1p0JbA0XIa3T352kBHfq6QriN4E372 >									
	//        <  u =="0.000000000000000001" : ] 000000267049857.874407000000000000 ; 000000282428793.431384000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001977C5A1AEF3BF >									
	//     < RUSS_PFV_I_metadata_line_20_____SIRIUS_IKAISA_BIMI_X_20211101 >									
	//        < c67cDN6mUNXZYO6o9Ok6Xb848ZK5m6B7Pu491qOL07sL4sBxTs8zjS6MAdzY31W0 >									
	//        <  u =="0.000000000000000001" : ] 000000282428793.431384000000000000 ; 000000298866747.193170000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AEF3BF1C808D3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFV_I_metadata_line_21_____SOCHI_INFRA_FUND_I_20211101 >									
	//        < kt4hUu34luY7A76NXJg5OXttpme5KwqEMpGXQm3O4PGaezBAla4QheZbdABYO00Z >									
	//        <  u =="0.000000000000000001" : ] 000000298866747.193170000000000000 ; 000000315556221.333945000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C808D31E18026 >									
	//     < RUSS_PFV_I_metadata_line_22_____SOCHI_INFRA_FUND_II_20211101 >									
	//        < 2p5NAAiNa4v2fI72w27aZJOcw8B7ORpOOM6iZ3q8NKvKC5E5tM1UEwIIoz44yA3d >									
	//        <  u =="0.000000000000000001" : ] 000000315556221.333945000000000000 ; 000000331791215.171801000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E180261FA45F2 >									
	//     < RUSS_PFV_I_metadata_line_23_____SOCHI_INFRA_FUND_III_20211101 >									
	//        < 6w3lP3M2U92UoM49o8Z45V7O7f9InSp1hKwaNK36Pl9sl7VNx2WSt0yd2rf3YQVP >									
	//        <  u =="0.000000000000000001" : ] 000000331791215.171801000000000000 ; 000000348291133.885715000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FA45F22137339 >									
	//     < RUSS_PFV_I_metadata_line_24_____SOCHI_INFRA_FUND_IV_20211101 >									
	//        < uCxX7CTj60i3hSjQ0ZW273dzs4Ah0U57oU197rdF0Lft3Mcm9ZHsGW6A6CRAi8ek >									
	//        <  u =="0.000000000000000001" : ] 000000348291133.885715000000000000 ; 000000362179977.457557000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002137339228A48E >									
	//     < RUSS_PFV_I_metadata_line_25_____SOCHI_INFRA_FUND_V_20211101 >									
	//        < bwomQ3ExLW6wlnOFG7RcpI663paQrgC4A69Fxk73AvV2EsZ6kH548syOCYQ3ZgKc >									
	//        <  u =="0.000000000000000001" : ] 000000362179977.457557000000000000 ; 000000378976315.088269000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000228A48E24245A0 >									
	//     < RUSS_PFV_I_metadata_line_26_____LIPNITSK_ORG_20211101 >									
	//        < hwCdzps14el6ZhfB27Xk4xy0B4v1L728XS1yI7yPPWnba0xSK758I9N5qzn8IBjy >									
	//        <  u =="0.000000000000000001" : ] 000000378976315.088269000000000000 ; 000000393035188.915378000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024245A0257B95F >									
	//     < RUSS_PFV_I_metadata_line_27_____LIPNITSK_DAO_20211101 >									
	//        < w3M861WfB9q692u68mo3nkJWC0iraLhaiv61vc4551rw0m5F2h4yMvvq9Tox526p >									
	//        <  u =="0.000000000000000001" : ] 000000393035188.915378000000000000 ; 000000406233349.702331000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000257B95F26BDCE7 >									
	//     < RUSS_PFV_I_metadata_line_28_____LIPNITSK_DAC_20211101 >									
	//        < kp7ygVPj37Kc18rL5TcVxiG4Aj2PpQJ8E4UPZaW5z3lerC8C8SWr9CM90AYQh18z >									
	//        <  u =="0.000000000000000001" : ] 000000406233349.702331000000000000 ; 000000423056314.312295000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026BDCE7285885F >									
	//     < RUSS_PFV_I_metadata_line_29_____LIPNITSK_ADIDAS_AB_20211101 >									
	//        < TL9RAf434aidtB020m3ff1qnPtTRUTi6Za6z9076vL6N83kG6BifBd6jGdl2pZhq >									
	//        <  u =="0.000000000000000001" : ] 000000423056314.312295000000000000 ; 000000439251423.093717000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000285885F29E3E96 >									
	//     < RUSS_PFV_I_metadata_line_30_____LIPNITSK_ALL_AB_M_ADIDAS_20211101 >									
	//        < 1Fl4YtELp8nP8v42mktb2xWrfOOZ9HlEiwP2q7qY7716F0Axdj5qd31mvRxczjqk >									
	//        <  u =="0.000000000000000001" : ] 000000439251423.093717000000000000 ; 000000454257978.291203000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029E3E962B52486 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFV_I_metadata_line_31_____ANADYR_ORG_20211101 >									
	//        < LG24O3WIHDnv34EHUFczekXTGTWeZye2EOgD4j16r7Qw9M80Cm3MUcuQ5W7qix6B >									
	//        <  u =="0.000000000000000001" : ] 000000454257978.291203000000000000 ; 000000468458444.678600000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B524862CACF94 >									
	//     < RUSS_PFV_I_metadata_line_32_____ANADYR_DAO_20211101 >									
	//        < Bxfzk9lZf554pblkvn80jV67e3cSVV3V08RxQQ7y1CZaJ539f10vi268Z0CcRn3b >									
	//        <  u =="0.000000000000000001" : ] 000000468458444.678600000000000000 ; 000000483468185.623138000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CACF942E1B6C3 >									
	//     < RUSS_PFV_I_metadata_line_33_____ANADYR_DAOPI_20211101 >									
	//        < xcLM5GFHD4atT68E6W2s23CL2Eo39pe929oxIHR4ByHRDU14GbS4dxz594305E7O >									
	//        <  u =="0.000000000000000001" : ] 000000483468185.623138000000000000 ; 000000500017870.034778000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E1B6C32FAF77B >									
	//     < RUSS_PFV_I_metadata_line_34_____CHUKOTKA_ORG_20211101 >									
	//        < h4zvf6rC574050bLM75gp78OmWp86YdIzumOdB2cYbP8dcS0BIlNF983uoVS1aAY >									
	//        <  u =="0.000000000000000001" : ] 000000500017870.034778000000000000 ; 000000515154833.054137000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FAF77B312105B >									
	//     < RUSS_PFV_I_metadata_line_35_____CHUKOTKA_DAO_20211101 >									
	//        < wx4gXG8Ye2SNNN91Qp173tw8i7pJOm2qf186yDvU1xuw2MZh39CzPznN6Bf54mr9 >									
	//        <  u =="0.000000000000000001" : ] 000000515154833.054137000000000000 ; 000000529327045.202839000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000312105B327B061 >									
	//     < RUSS_PFV_I_metadata_line_36_____CHUKOTKA_DAOPI_20211101 >									
	//        < 5QA4TArwX31Fy58RHs2VDH0v6gAWDX8EP2rcqw00mE5Rj8s0a8B91CH3L2X90g24 >									
	//        <  u =="0.000000000000000001" : ] 000000529327045.202839000000000000 ; 000000543464654.351163000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000327B06133D42E1 >									
	//     < RUSS_PFV_I_metadata_line_37_____ANADYR_PORT_ORG_20211101 >									
	//        < lK4wu5GrDb4hmEoLM5iPji6KGZ00BG5C9N57ip7qy7Z4x5ybNZavM54qRF8Xlr01 >									
	//        <  u =="0.000000000000000001" : ] 000000543464654.351163000000000000 ; 000000556868281.280467000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033D42E1351B6AC >									
	//     < RUSS_PFV_I_metadata_line_38_____INDUSTRIAL_PARK_ANADYR_ORG_20211101 >									
	//        < 517EGezx2a6HTQY2dR2lMAl0wd475a27Ou6WmKJe0lv0b62X9EJkBYRRmjx0tJ1a >									
	//        <  u =="0.000000000000000001" : ] 000000556868281.280467000000000000 ; 000000572977325.000526000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000351B6AC36A4B45 >									
	//     < RUSS_PFV_I_metadata_line_39_____POLE_COLD_SERVICE_20211101 >									
	//        < 79dX8P5nXwumaiY85D5bf2Og0wpp2oP6WOC7J5PfM8r7WLH1fbtl74fR2gq6bZ6u >									
	//        <  u =="0.000000000000000001" : ] 000000572977325.000526000000000000 ; 000000587711028.499682000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036A4B45380C69F >									
	//     < RUSS_PFV_I_metadata_line_40_____RED_OCTOBER_CO_20211101 >									
	//        < 8Yv94T1dkbEs1MKAB9w65ftMpAd98tTiG3w6540oQp05c02W0RtGb810H3VpWkDZ >									
	//        <  u =="0.000000000000000001" : ] 000000587711028.499682000000000000 ; 000000601150973.675601000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000380C69F3954899 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}