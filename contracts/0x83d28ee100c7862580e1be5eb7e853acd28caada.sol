pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXVII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXVII_I_883		"	;
		string	public		symbol =	"	RUSS_PFXVII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		604875477823722000000000000					;	
										
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
	//     < RUSS_PFXVII_I_metadata_line_1_____URALKALI_1_ORG_20211101 >									
	//        < Fr4R33nGxmuub2t6TNsZHgGQ4FWuamRt2O833t3EZqX58SyN8T81WYqNa7A72Yb4 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000015388044.216454600000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000177AF4 >									
	//     < RUSS_PFXVII_I_metadata_line_2_____URALKALI_1_DAO_20211101 >									
	//        < d8bkWjQG85G67V056E19KUl2p44rkqH5A6XRsx34gcb7389ciX2Q2KFkUeGg8at7 >									
	//        <  u =="0.000000000000000001" : ] 000000015388044.216454600000000000 ; 000000031012729.197002200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000177AF42F5259 >									
	//     < RUSS_PFXVII_I_metadata_line_3_____URALKALI_1_DAOPI_20211101 >									
	//        < 39Vzm16rMf3677r1Z0sT8Bk7rw3h7TXDX1WrAnnaU17O38jLk78IG7g326qPGA4z >									
	//        <  u =="0.000000000000000001" : ] 000000031012729.197002200000000000 ; 000000045394306.810421100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002F5259454427 >									
	//     < RUSS_PFXVII_I_metadata_line_4_____URALKALI_1_DAC_20211101 >									
	//        < Zmiyb27m8hi66mybNxi0YeQ8QCvpZA00Au3XBs6CCD2tvBVuDXbctdXxN1RqRHm7 >									
	//        <  u =="0.000000000000000001" : ] 000000045394306.810421100000000000 ; 000000060540233.245324300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004544275C6087 >									
	//     < RUSS_PFXVII_I_metadata_line_5_____URALKALI_1_BIMI_20211101 >									
	//        < Dpn337ZMzfH113E73O976fbU90noQH12GAZzkpzt05Lg03DIoCY732vn02GCJM2e >									
	//        <  u =="0.000000000000000001" : ] 000000060540233.245324300000000000 ; 000000075283568.775340300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005C608772DFA5 >									
	//     < RUSS_PFXVII_I_metadata_line_6_____URALKALI_2_ORG_20211101 >									
	//        < 9i3CzD6GosHv65yJKrKMmWp74C88eFv4bW4fZoB9nacUA5U1m5ADhz54bSyNa1qE >									
	//        <  u =="0.000000000000000001" : ] 000000075283568.775340300000000000 ; 000000091703728.578190900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000072DFA58BEDC5 >									
	//     < RUSS_PFXVII_I_metadata_line_7_____URALKALI_2_DAO_20211101 >									
	//        < e0858gXzqvo9AO6v0euSmY80OC0I6Vn90CUdxj3o7x4Op5htyH16Ov8LtT6S7AO4 >									
	//        <  u =="0.000000000000000001" : ] 000000091703728.578190900000000000 ; 000000107365953.672404000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008BEDC5A3D3D3 >									
	//     < RUSS_PFXVII_I_metadata_line_8_____URALKALI_2_DAOPI_20211101 >									
	//        < g7syrvx63QhHN0UTL5s0o87tdlha1o28a2QKO40zdmobe6wGTeP1tJySeue6b9QZ >									
	//        <  u =="0.000000000000000001" : ] 000000107365953.672404000000000000 ; 000000124026496.018236000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A3D3D3BD3FDA >									
	//     < RUSS_PFXVII_I_metadata_line_9_____URALKALI_2_DAC_20211101 >									
	//        < 5OU8P87MLam87I4iA5ha9YkmBn07v3P9LPdL383I5Pv3d7uiB5qld1Q4wE1qT7qM >									
	//        <  u =="0.000000000000000001" : ] 000000124026496.018236000000000000 ; 000000141033334.410148000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BD3FDAD73325 >									
	//     < RUSS_PFXVII_I_metadata_line_10_____URALKALI_2_BIMI_20211101 >									
	//        < 5I0Gb2zMYfptD2wXQLBXS34l2CqyXG787qr857690Ar84cyXglau9VY4q4z0j48d >									
	//        <  u =="0.000000000000000001" : ] 000000141033334.410148000000000000 ; 000000155986323.378332000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D73325EE0428 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVII_I_metadata_line_11_____KAMA_1_ORG_20211101 >									
	//        < l9Zs6pr7e5qgNwo4nznTg0y7zy700H23ra80SGq7uQ52h7r1uH9yY1sWH917XP4h >									
	//        <  u =="0.000000000000000001" : ] 000000155986323.378332000000000000 ; 000000172420222.245391000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EE042810717A6 >									
	//     < RUSS_PFXVII_I_metadata_line_12_____KAMA_1_DAO_20211101 >									
	//        < pe0A820jt51d3k5a666ZfGESGS4m3yBr5B9C3lv2vYriYmrgsGVTEu75vjiiX0n8 >									
	//        <  u =="0.000000000000000001" : ] 000000172420222.245391000000000000 ; 000000188699028.387977000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010717A611FEE8F >									
	//     < RUSS_PFXVII_I_metadata_line_13_____KAMA_1_DAOPI_20211101 >									
	//        < W6y621OOs21M0ifY3FdD2TfCIlc9U60P3PuiwvD38JXHL0fQJNwx12A5QC3vUVed >									
	//        <  u =="0.000000000000000001" : ] 000000188699028.387977000000000000 ; 000000201990693.697180000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011FEE8F134369D >									
	//     < RUSS_PFXVII_I_metadata_line_14_____KAMA_1_DAC_20211101 >									
	//        < Bne1038H2m6a6PK8t69UH6wk2Uv3eyDBg83SQpJTOG51Om0sAAPwVkor5J2Ipr9U >									
	//        <  u =="0.000000000000000001" : ] 000000201990693.697180000000000000 ; 000000217110638.777051000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000134369D14B48D8 >									
	//     < RUSS_PFXVII_I_metadata_line_15_____KAMA_1_BIMI_20211101 >									
	//        < 4d08gBF31boU9ZzP8FR9xJYJsI05L4Qy82CJRVm5DBp6JMtWAP87sBS0nL66j40w >									
	//        <  u =="0.000000000000000001" : ] 000000217110638.777051000000000000 ; 000000233984140.377839000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014B48D8165080E >									
	//     < RUSS_PFXVII_I_metadata_line_16_____KAMA_2_ORG_20211101 >									
	//        < acyEcCWbeh0t3185F7RQargypl62H39JwsLd9oUXA9BB5oQ6tPcRhGQ3gnJJql5t >									
	//        <  u =="0.000000000000000001" : ] 000000233984140.377839000000000000 ; 000000247854572.064403000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000165080E17A3231 >									
	//     < RUSS_PFXVII_I_metadata_line_17_____KAMA_2_DAO_20211101 >									
	//        < 2vOTrT5g94jijgutITHspuMMMT66rBlNjoZ0179R2iP4Z06892TvU8cx9I156Q56 >									
	//        <  u =="0.000000000000000001" : ] 000000247854572.064403000000000000 ; 000000262158820.459769000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017A323119005CA >									
	//     < RUSS_PFXVII_I_metadata_line_18_____KAMA_2_DAOPI_20211101 >									
	//        < NF1Rsb4HbG6xUbfQx1r41c8D744iJg34rUy674VWJCM2ijOPJ6j4pXYSc609XKe6 >									
	//        <  u =="0.000000000000000001" : ] 000000262158820.459769000000000000 ; 000000276681674.651383000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019005CA1A62EC7 >									
	//     < RUSS_PFXVII_I_metadata_line_19_____KAMA_2_DAC_20211101 >									
	//        < rD3j026YTTs4qH50Da21co71fnEaSx3627xj5UpOPSsZogckM4xT5N1csGVG4Ot5 >									
	//        <  u =="0.000000000000000001" : ] 000000276681674.651383000000000000 ; 000000290797033.649337000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A62EC71BBB897 >									
	//     < RUSS_PFXVII_I_metadata_line_20_____KAMA_2_BIMI_20211101 >									
	//        < cxOEL9TZ4581KJVSlYXvYIxk6fyH9XV38QWqDT1W6GAfKqd19LZaINI9jWs2Q52K >									
	//        <  u =="0.000000000000000001" : ] 000000290797033.649337000000000000 ; 000000304450708.179356000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BBB8971D08E0F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVII_I_metadata_line_21_____KAMA_20211101 >									
	//        < 6F8vUH8SpBfS2vjWl6dfk7H58nk2lK1txjas1Ak14KRIw8yp4r4NUjK4NkdABqCY >									
	//        <  u =="0.000000000000000001" : ] 000000304450708.179356000000000000 ; 000000319611875.274508000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D08E0F1E7B064 >									
	//     < RUSS_PFXVII_I_metadata_line_22_____URALKALI_TRADING_SIA_20211101 >									
	//        < s98dWzcYZyXAI5K340uBRS2Ij4eRK2tTWuT3rt2P1QjJ1bTkz9oVzDyTUOwm3O71 >									
	//        <  u =="0.000000000000000001" : ] 000000319611875.274508000000000000 ; 000000334255808.793996000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E7B0641FE08AD >									
	//     < RUSS_PFXVII_I_metadata_line_23_____BALTIC_BULKER_TERMINAL_20211101 >									
	//        < 0K0lBhXlR58GWlwlAS8765r74k3l8ZSepYti2cANPPYqTdLiwi4AfW7IUdX981F2 >									
	//        <  u =="0.000000000000000001" : ] 000000334255808.793996000000000000 ; 000000350752959.998230000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FE08AD21734E0 >									
	//     < RUSS_PFXVII_I_metadata_line_24_____URALKALI_FINANCE_LIMITED_20211101 >									
	//        < 0PxzYglP81X8GvJYWR486483dVlG28ynsanzzJax4N146wMs6XEqHG56IU8U46iW >									
	//        <  u =="0.000000000000000001" : ] 000000350752959.998230000000000000 ; 000000366809615.371171000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021734E022FB502 >									
	//     < RUSS_PFXVII_I_metadata_line_25_____SOLIKAMSK_CONSTRUCTION_TRUST_20211101 >									
	//        < Dj2FTAP1E34sec8Y8i6LK7Bgz4Fqra26EhJNaHo4UzLfBnZ57rYk5D3viWfZuswY >									
	//        <  u =="0.000000000000000001" : ] 000000366809615.371171000000000000 ; 000000381005267.296991000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022FB5022455E2F >									
	//     < RUSS_PFXVII_I_metadata_line_26_____SILVINIT_CAPITAL_20211101 >									
	//        < DAP27i39GurmN72g18Kd42ELGFSi22Mh37IxG3F3apPasSH19QQ88e7wFx4VC3MT >									
	//        <  u =="0.000000000000000001" : ] 000000381005267.296991000000000000 ; 000000394920542.454191000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002455E2F25A99D6 >									
	//     < RUSS_PFXVII_I_metadata_line_27_____AUTOMATION_MEASUREMENTS_CENTER_20211101 >									
	//        < GYbwFCr0E7Tkk2UULz0HJ8FJ7ti4RNK48655SpWsm65BcxD1217GnWE03iVUItt8 >									
	//        <  u =="0.000000000000000001" : ] 000000394920542.454191000000000000 ; 000000410471475.269189000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025A99D6272546C >									
	//     < RUSS_PFXVII_I_metadata_line_28_____LOVOZERSKAYA_ORE_DRESSING_CO_20211101 >									
	//        < c83QhCe2XsTNLi7QYYBhpqXRC47aMB176Atn2ygrUP1ZakN31zqoQ1R7ff9pU3hs >									
	//        <  u =="0.000000000000000001" : ] 000000410471475.269189000000000000 ; 000000425487827.851003000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000272546C2893E2F >									
	//     < RUSS_PFXVII_I_metadata_line_29_____URALKALI_ENGINEERING_20211101 >									
	//        < 4O50w8dIXanxqdRtQagEQbrykbS85z5l0OmN3MuWslIDJFJUcjZZjl4CGCZu6Ija >									
	//        <  u =="0.000000000000000001" : ] 000000425487827.851003000000000000 ; 000000441591115.503707000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002893E2F2A1D088 >									
	//     < RUSS_PFXVII_I_metadata_line_30_____URALKALI_DEPO_20211101 >									
	//        < GOyEmoB12H3GLui85O6XbdV8z98pp7kiJj370r2m3YZ36HR4OT7Mi3uT047ARr2c >									
	//        <  u =="0.000000000000000001" : ] 000000441591115.503707000000000000 ; 000000456818992.502096000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A1D0882B90CEB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXVII_I_metadata_line_31_____VAGONNOE_DEPO_BALAKHONZI_20211101 >									
	//        < DkYZ5P4B9ae0Qznb7eEfrsGsg0Gh77q5s6v3fZthi96fFrpv975eu6YLvL5gNeK3 >									
	//        <  u =="0.000000000000000001" : ] 000000456818992.502096000000000000 ; 000000471465116.948914000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B90CEB2CF6610 >									
	//     < RUSS_PFXVII_I_metadata_line_32_____SILVINIT_TRANSPORT_20211101 >									
	//        < bqmjy0h3X7DTnna7237c6lfO1T6v5gWAuJ4eVIwm26XmL7Gs0LUFySKwSRiJlrd4 >									
	//        <  u =="0.000000000000000001" : ] 000000471465116.948914000000000000 ; 000000484686151.851854000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CF66102E39287 >									
	//     < RUSS_PFXVII_I_metadata_line_33_____AUTOTRANSKALI_20211101 >									
	//        < RAe9l55uRA6ffzzVwZ93ebc8wnEUyo6Zx8H49W9p27K8FrYy9MXh2pXzCw7aoC60 >									
	//        <  u =="0.000000000000000001" : ] 000000484686151.851854000000000000 ; 000000497970867.142705000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E392872F7D7DF >									
	//     < RUSS_PFXVII_I_metadata_line_34_____URALKALI_REMONT_20211101 >									
	//        < xDolMUrBql2Qw58mqJvhvV6TOXo18C66z1c1r97RJ55GTxa1lo5tugRN3d126H9b >									
	//        <  u =="0.000000000000000001" : ] 000000497970867.142705000000000000 ; 000000514608982.579153000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F7D7DF3113B22 >									
	//     < RUSS_PFXVII_I_metadata_line_35_____EN_RESURS_OOO_20211101 >									
	//        < x45p0q4DH2w6r4j4GNZJ39qUVrVN0J683glNuOGr83GS20B396t7TPI3Kg5l82Y1 >									
	//        <  u =="0.000000000000000001" : ] 000000514608982.579153000000000000 ; 000000531496075.460598000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003113B2232AFFA8 >									
	//     < RUSS_PFXVII_I_metadata_line_36_____BSHSU_20211101 >									
	//        < Q16ydg1Gjok62q4M4xglHz2495fKtBvcu16Rca09k1Ne36Hr4fY7v2jd8MQ9mQl3 >									
	//        <  u =="0.000000000000000001" : ] 000000531496075.460598000000000000 ; 000000547067845.336645000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032AFFA8342C261 >									
	//     < RUSS_PFXVII_I_metadata_line_37_____URALKALI_TECHNOLOGY_20211101 >									
	//        < FkFKNW5oqr3R5i2s5IlIzGQ3zdkI550ZmAmjOT64cSzL09r706Yr4rCJp68NEiez >									
	//        <  u =="0.000000000000000001" : ] 000000547067845.336645000000000000 ; 000000560858384.469197000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000342C261357CD4E >									
	//     < RUSS_PFXVII_I_metadata_line_38_____KAMA_MINERAL_OOO_20211101 >									
	//        < bKAKs9I518wJiC40t8sW0O6707Xnxa82QDJMWz8h2LT5wx1fewvweRHL3EY928Uw >									
	//        <  u =="0.000000000000000001" : ] 000000560858384.469197000000000000 ; 000000574760024.484490000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000357CD4E36D03A2 >									
	//     < RUSS_PFXVII_I_metadata_line_39_____SOLIKAMSKSTROY_ZAO_20211101 >									
	//        < UGM9RwHOL43hafP102pT09h8b60qPadW8q9evoP06gI01W9FkICU9807i5GbyS0I >									
	//        <  u =="0.000000000000000001" : ] 000000574760024.484490000000000000 ; 000000589078813.681947000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036D03A2382DCE9 >									
	//     < RUSS_PFXVII_I_metadata_line_40_____NOVAYA_NEDVIZHIMOST_20211101 >									
	//        < tzh3oN7bNxo3hpYDy20G01OA55I2OA4JeN5xo107Sx0ie5h9nKaWz4IS2gx9Gfb9 >									
	//        <  u =="0.000000000000000001" : ] 000000589078813.681947000000000000 ; 000000604875477.823722000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000382DCE939AF77C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}