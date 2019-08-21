pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFV_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFV_II_883		"	;
		string	public		symbol =	"	RUSS_PFV_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		798187600859198000000000000					;	
										
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
	//     < RUSS_PFV_II_metadata_line_1_____SIRIUS_ORG_20231101 >									
	//        < q1f5O2Q8Y8BLJAG1Ej3yE8bid7Q7ucUbSV47x8lzR0V0iR1G9Qwg6cG9Uz26Y235 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000021538036.199862100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000020DD4C >									
	//     < RUSS_PFV_II_metadata_line_2_____SIRIUS_DAO_20231101 >									
	//        < ykO4wQP1H0IFuQFC16E977js9m4iJj6Ln55qaHOM2Qp628890kL0S7aS75Xr5873 >									
	//        <  u =="0.000000000000000001" : ] 000000021538036.199862100000000000 ; 000000039755861.273611300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000020DD4C3CA9A2 >									
	//     < RUSS_PFV_II_metadata_line_3_____SIRIUS_DAOPI_20231101 >									
	//        < VuiiQ9Mn14D2z8MsX4k371p8U3bJG03HkJ7d6V7Sy8Te081A6cnkEqhG6gY0V2Ga >									
	//        <  u =="0.000000000000000001" : ] 000000039755861.273611300000000000 ; 000000060801496.935786200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003CA9A25CC696 >									
	//     < RUSS_PFV_II_metadata_line_4_____SIRIUS_BIMI_20231101 >									
	//        < TpZcpKa7Y0j6eAw1U4EN547elXjfgf26HJjPD923YO5xE3hxmqcN2a5b2x5Dy4jM >									
	//        <  u =="0.000000000000000001" : ] 000000060801496.935786200000000000 ; 000000084568668.581259000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005CC696810AA3 >									
	//     < RUSS_PFV_II_metadata_line_5_____EDUCATIONAL_CENTER_SIRIUS_ORG_20231101 >									
	//        < LFXX6XoAI6v5406BEk3q54T8J9Wrj23Ph7CRye2ki3j9yMI324vYOEZtA5J9xF48 >									
	//        <  u =="0.000000000000000001" : ] 000000084568668.581259000000000000 ; 000000103938221.455990000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000810AA39E98DE >									
	//     < RUSS_PFV_II_metadata_line_6_____EDUCATIONAL_CENTER_SIRIUS_DAO_20231101 >									
	//        < htJG1V14eXOaY729cSVWVTIHuyhLLnGo5jcP8EQVRUXMbm65KoWNpV8ep1kLVI1i >									
	//        <  u =="0.000000000000000001" : ] 000000103938221.455990000000000000 ; 000000120902143.001827000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009E98DEB87B66 >									
	//     < RUSS_PFV_II_metadata_line_7_____EDUCATIONAL_CENTER_SIRIUS_DAOPI_20231101 >									
	//        < VSrAwP3yYI1doQ8j83bcXotGW2yY3zC4V4cm46JVZR36MsoJvkxf9uutGP7Sa7RP >									
	//        <  u =="0.000000000000000001" : ] 000000120902143.001827000000000000 ; 000000143120181.560600000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B87B66DA6252 >									
	//     < RUSS_PFV_II_metadata_line_8_____EDUCATIONAL_CENTER_SIRIUS_DAC_20231101 >									
	//        < b123LRd3nuam7idKi2GKRLWL7V5E725gQuZHL43LNGzo9784cJa42T5NTT1vxWwO >									
	//        <  u =="0.000000000000000001" : ] 000000143120181.560600000000000000 ; 000000162444551.859078000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DA6252F7DEE7 >									
	//     < RUSS_PFV_II_metadata_line_9_____SOCHI_PARK_HOTEL_20231101 >									
	//        < tNEjYT5220n8UOt7BEHnQ89nP4u32370358lFY5FDAj70X16d8ke8X3TVrTUz3d8 >									
	//        <  u =="0.000000000000000001" : ] 000000162444551.859078000000000000 ; 000000180657496.823826000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F7DEE7113A956 >									
	//     < RUSS_PFV_II_metadata_line_10_____GOSTINICHNYY_KOMPLEKS_BOGATYR_20231101 >									
	//        < AR1Pl99e1A487m6X0l1PH3x46FmSGTsx1F50zUU38QO8NXDD2X3o8DzS5N83a6m4 >									
	//        <  u =="0.000000000000000001" : ] 000000180657496.823826000000000000 ; 000000196466657.982259000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000113A95612BC8CA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFV_II_metadata_line_11_____SIRIUS_IKAISA_BIMI_I_20231101 >									
	//        < Jx3l6652EV46cM1d3Mr9Zc870KC7rG3vWC97nsu5bJ43cCZcE9r9dA0j64rDJ6wG >									
	//        <  u =="0.000000000000000001" : ] 000000196466657.982259000000000000 ; 000000213709747.173358000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012BC8CA146185F >									
	//     < RUSS_PFV_II_metadata_line_12_____SIRIUS_IKAISA_BIMI_II_20231101 >									
	//        < 112qBs1iEY9B9495MrMK1g4aKS4X5YdxcL8ZzRl44wmC6W25p1OAVt1l3l5q02lD >									
	//        <  u =="0.000000000000000001" : ] 000000213709747.173358000000000000 ; 000000238362384.439975000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000146185F16BB64E >									
	//     < RUSS_PFV_II_metadata_line_13_____SIRIUS_IKAISA_BIMI_III_20231101 >									
	//        < gsdMcLAE2o9X86fmt484P93ScVu5tbhyvoU1p5hb07ovnUl401gsBaSj806Ha60p >									
	//        <  u =="0.000000000000000001" : ] 000000238362384.439975000000000000 ; 000000260692481.332762000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016BB64E18DC900 >									
	//     < RUSS_PFV_II_metadata_line_14_____SIRIUS_IKAISA_BIMI_IV_20231101 >									
	//        < 8PMXo082hq0zKaX25iLmEhC746RxrnRNeod6U89Bm96JjOQmAHc0vm0oJ3pFAKN9 >									
	//        <  u =="0.000000000000000001" : ] 000000260692481.332762000000000000 ; 000000276585415.253188000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018DC9001A6092E >									
	//     < RUSS_PFV_II_metadata_line_15_____SIRIUS_IKAISA_BIMI_V_20231101 >									
	//        < 90yThg9PlAn48yb8DEwY1P47wi9NY8zM8bWznW0ZSeUo4f0n4ZQFvnxV9KJLGf05 >									
	//        <  u =="0.000000000000000001" : ] 000000276585415.253188000000000000 ; 000000298021455.351306000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A6092E1C6BEA2 >									
	//     < RUSS_PFV_II_metadata_line_16_____SIRIUS_IKAISA_BIMI_VI_20231101 >									
	//        < TgxTqHXBo48e020134Uvy0R76C4XAqbH68rk84iJr2P7WLS80aw0w5CO97nzNR35 >									
	//        <  u =="0.000000000000000001" : ] 000000298021455.351306000000000000 ; 000000319775942.597005000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C6BEA21E7F07A >									
	//     < RUSS_PFV_II_metadata_line_17_____SIRIUS_IKAISA_BIMI_VII_20231101 >									
	//        < qFq2g145uSJWn56m9N7xXOdL6mI72o2D32Q6v1N7T7b6Z4m6GIFVAh2zNW6w97yv >									
	//        <  u =="0.000000000000000001" : ] 000000319775942.597005000000000000 ; 000000342830981.714960000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E7F07A20B1E5A >									
	//     < RUSS_PFV_II_metadata_line_18_____SIRIUS_IKAISA_BIMI_VIII_20231101 >									
	//        < k87yHz5YTuHPvhkJR109P42cwFJg202MAX7u909ehL338BO2b7Ygog3yhU0pnm39 >									
	//        <  u =="0.000000000000000001" : ] 000000342830981.714960000000000000 ; 000000367391631.915472000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020B1E5A230985B >									
	//     < RUSS_PFV_II_metadata_line_19_____SIRIUS_IKAISA_BIMI_IX_20231101 >									
	//        < Go75UeYpZx1Y21GwuUy0Z6jFqsQhHX0rDjz1d55T1o3333s8ji8F9z5pXzl7hJ9d >									
	//        <  u =="0.000000000000000001" : ] 000000367391631.915472000000000000 ; 000000385820513.609592000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000230985B24CB723 >									
	//     < RUSS_PFV_II_metadata_line_20_____SIRIUS_IKAISA_BIMI_X_20231101 >									
	//        < f8h3fSCi7vUO9y744TI173Xvbct00ZxXlp8jCJD7837MebGGIgw6AVC7iMcpe4XJ >									
	//        <  u =="0.000000000000000001" : ] 000000385820513.609592000000000000 ; 000000406236747.129309000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024CB72326BDE3B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFV_II_metadata_line_21_____SOCHI_INFRA_FUND_I_20231101 >									
	//        < NidC2bLL9OSuzWWLkYnA0BE5zeQ6IRp05GOL1pbX45clJJWg4Ft8ddT38h3FCgZX >									
	//        <  u =="0.000000000000000001" : ] 000000406236747.129309000000000000 ; 000000429761436.508642000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026BDE3B28FC390 >									
	//     < RUSS_PFV_II_metadata_line_22_____SOCHI_INFRA_FUND_II_20231101 >									
	//        < WfVMeffu0M9jVFoHk67h9H48e0dpnU97F9316DA88meT8R3f7D42b7s55oU6gx2O >									
	//        <  u =="0.000000000000000001" : ] 000000429761436.508642000000000000 ; 000000446337178.787164000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028FC3902A90E76 >									
	//     < RUSS_PFV_II_metadata_line_23_____SOCHI_INFRA_FUND_III_20231101 >									
	//        < Kyz9NzKJxrLz6tju9R2qhxz8841e36r1DxL7A828qMdM0JWrVt597Dc8PnHGQ1oi >									
	//        <  u =="0.000000000000000001" : ] 000000446337178.787164000000000000 ; 000000463708021.651718000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A90E762C38FF2 >									
	//     < RUSS_PFV_II_metadata_line_24_____SOCHI_INFRA_FUND_IV_20231101 >									
	//        < 78wYunuHDG4JysCb7ma13p78stX4Yb94285E8AKJx9zH376zv61fZq9xri53oYE1 >									
	//        <  u =="0.000000000000000001" : ] 000000463708021.651718000000000000 ; 000000480068874.511742000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C38FF22DC86E7 >									
	//     < RUSS_PFV_II_metadata_line_25_____SOCHI_INFRA_FUND_V_20231101 >									
	//        < k1TkT9UwrjlwSw633OSti2M4ODd6FoG2Vk5WYhQ4h5x302Wyqd09tF5PQdSMXCx3 >									
	//        <  u =="0.000000000000000001" : ] 000000480068874.511742000000000000 ; 000000504691619.396274000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DC86E7302192A >									
	//     < RUSS_PFV_II_metadata_line_26_____LIPNITSK_ORG_20231101 >									
	//        < quo7rJnw7K6jOS4qdOC8xN55s7n1Eod5l33UAM5p9K4Tcz99dZ5ZCepG874g17RL >									
	//        <  u =="0.000000000000000001" : ] 000000504691619.396274000000000000 ; 000000528838752.082723000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000302192A326F1A3 >									
	//     < RUSS_PFV_II_metadata_line_27_____LIPNITSK_DAO_20231101 >									
	//        < T6WhQ4A6IKXCj6W338p65cyb6Q33Gfi2wjf6ajwUOZ5M0VO2DGQ1e5xlW87469JO >									
	//        <  u =="0.000000000000000001" : ] 000000528838752.082723000000000000 ; 000000546904636.528287000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000326F1A334282A0 >									
	//     < RUSS_PFV_II_metadata_line_28_____LIPNITSK_DAC_20231101 >									
	//        < EXEzvwESQ2m6dP600b5ozLF67m4wuy2QIv32K626khp950MdbkAryu1zZIoSb6hK >									
	//        <  u =="0.000000000000000001" : ] 000000546904636.528287000000000000 ; 000000569019765.313558000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034282A03644159 >									
	//     < RUSS_PFV_II_metadata_line_29_____LIPNITSK_ADIDAS_AB_20231101 >									
	//        < pksF41vQ2221U71cPlG2C14qD2A18vPKHnI3r46696BZYzp663hi167m2nwL4Z52 >									
	//        <  u =="0.000000000000000001" : ] 000000569019765.313558000000000000 ; 000000585368667.632971000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000364415937D33A3 >									
	//     < RUSS_PFV_II_metadata_line_30_____LIPNITSK_ALL_AB_M_ADIDAS_20231101 >									
	//        < m6NYYA8NrvUWKq8F1W2uy42Xyk4gP8m0b7Tw5MVt76ydg06qvVVI3oOcn1hy4yw1 >									
	//        <  u =="0.000000000000000001" : ] 000000585368667.632971000000000000 ; 000000605621991.493844000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037D33A339C1B17 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFV_II_metadata_line_31_____ANADYR_ORG_20231101 >									
	//        < 8nDkuIQjRLItagxQ7sS71CiAKFt8PF0oNH7eXcRWrcONS3BAXN8HHbmfW6s1xZBO >									
	//        <  u =="0.000000000000000001" : ] 000000605621991.493844000000000000 ; 000000625374304.615169000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039C1B173BA3ED6 >									
	//     < RUSS_PFV_II_metadata_line_32_____ANADYR_DAO_20231101 >									
	//        < 9M9N9Y8E8YR8WD4110r6ujRYDwqRha4ACf1YhLmN52G0Hxc5Uz065YV9CN1d2pd6 >									
	//        <  u =="0.000000000000000001" : ] 000000625374304.615169000000000000 ; 000000647691372.134958000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BA3ED63DC4C71 >									
	//     < RUSS_PFV_II_metadata_line_33_____ANADYR_DAOPI_20231101 >									
	//        < 4K3Yxg561rBJdK295LK0APY6NRXhf7stHxH1U4XEJFuf4HijkN7yPa6ZH008Y8y0 >									
	//        <  u =="0.000000000000000001" : ] 000000647691372.134958000000000000 ; 000000663247066.235712000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DC4C713F408E3 >									
	//     < RUSS_PFV_II_metadata_line_34_____CHUKOTKA_ORG_20231101 >									
	//        < 29MMfDF8Hvc1clrjtIMV432J5szAc8lp9l80N2u97XvZ9cZDxU6HMs65IQoxu4ct >									
	//        <  u =="0.000000000000000001" : ] 000000663247066.235712000000000000 ; 000000681256336.385067000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F408E340F83C2 >									
	//     < RUSS_PFV_II_metadata_line_35_____CHUKOTKA_DAO_20231101 >									
	//        < Y5xH0M0CL3q5UrPBNLSG9fje4upLTMUiOjcXwvHE8PzK1298ipPe7wE5rRZ3Iz1h >									
	//        <  u =="0.000000000000000001" : ] 000000681256336.385067000000000000 ; 000000701649073.851938000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040F83C242EA1AB >									
	//     < RUSS_PFV_II_metadata_line_36_____CHUKOTKA_DAOPI_20231101 >									
	//        < Jgwb4Jz9BttF6i3wO4q9Zca6MN1Qi5Aoe475WOK6D4BPY9dx8D8L87xuGw7Bnjy2 >									
	//        <  u =="0.000000000000000001" : ] 000000701649073.851938000000000000 ; 000000722995222.832477000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042EA1AB44F3402 >									
	//     < RUSS_PFV_II_metadata_line_37_____ANADYR_PORT_ORG_20231101 >									
	//        < o8GX1VQ6w1TLu569gN5bi2ZfBWDGuVSeNh39I9M772p7joSouyfdp5i6F7vPXKO6 >									
	//        <  u =="0.000000000000000001" : ] 000000722995222.832477000000000000 ; 000000744001799.164284000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044F340246F41B4 >									
	//     < RUSS_PFV_II_metadata_line_38_____INDUSTRIAL_PARK_ANADYR_ORG_20231101 >									
	//        < V78N8uMjDdmbLfN6BwWbPSjt1KE6H4eI1QjuxZiC99a88pfO9sFFiP56SY10e0V6 >									
	//        <  u =="0.000000000000000001" : ] 000000744001799.164284000000000000 ; 000000762397514.019584000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046F41B448B5387 >									
	//     < RUSS_PFV_II_metadata_line_39_____POLE_COLD_SERVICE_20231101 >									
	//        < H5mAs3YdR0yp6Oc86y5C1BVgatl8Fnmpo4Q3X7pKLu88qb0D7J1xYfgO1JzuT28U >									
	//        <  u =="0.000000000000000001" : ] 000000762397514.019584000000000000 ; 000000778508105.875572000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048B53874A3E8BB >									
	//     < RUSS_PFV_II_metadata_line_40_____RED_OCTOBER_CO_20231101 >									
	//        < 2tv6y1m1RTEO1bWP9O5BL98Q1sC4A37MofUu4UGj61hs2yahiZhU0KbJOFK5HPp8 >									
	//        <  u =="0.000000000000000001" : ] 000000778508105.875572000000000000 ; 000000798187600.859198000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A3E8BB4C1F008 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}