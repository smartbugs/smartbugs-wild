pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXIII_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXIII_II_883		"	;
		string	public		symbol =	"	RUSS_PFXIII_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		800200638111902000000000000					;	
										
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
	//     < RUSS_PFXIII_II_metadata_line_1_____NORILSK_NICKEL_20211101 >									
	//        < uv04MbSo0lH2O21syGI289Lnj3tn3hkH2NW33srU9036EgDSFL2RwqLGsU0wbNUZ >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000021616514.980950100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000020FBF3 >									
	//     < RUSS_PFXIII_II_metadata_line_2_____NORNICKEL_ORG_20211101 >									
	//        < GOu01lM6l0xKzgT9v621Uh4uoNxQ8Ip0brgQw9WCD784q91Cc0wK5L9L7963OKsd >									
	//        <  u =="0.000000000000000001" : ] 000000021616514.980950100000000000 ; 000000037287077.463051600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000020FBF338E544 >									
	//     < RUSS_PFXIII_II_metadata_line_3_____NORNICKEL_DAO_20211101 >									
	//        < Wi45vbzo0W8GgH6kRA2MylzXq8NYxRAE72U705O6IEBxVpolc461F48IM25V32Zi >									
	//        <  u =="0.000000000000000001" : ] 000000037287077.463051600000000000 ; 000000059990273.595737100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000038E5445B89B3 >									
	//     < RUSS_PFXIII_II_metadata_line_4_____NORNICKEL_DAOPI_20211101 >									
	//        < e7nA6162RBR6B5j3SGZJAq29wA5zY8zfk81JD3auWDIC37dDsk7OAd0GpPHQGW2Q >									
	//        <  u =="0.000000000000000001" : ] 000000059990273.595737100000000000 ; 000000075477757.482188300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005B89B3732B80 >									
	//     < RUSS_PFXIII_II_metadata_line_5_____NORNICKEL_PENSII_20211101 >									
	//        < 96dKqEWWAoBqs3jJw1y9457F3PB0V80L4hVx501EI3cAQIYbhmom37V2Q8YO0zAm >									
	//        <  u =="0.000000000000000001" : ] 000000075477757.482188300000000000 ; 000000095606700.822903000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000732B8091E25E >									
	//     < RUSS_PFXIII_II_metadata_line_6_____NORNICKEL_DAC_20211101 >									
	//        < E6IL22n64T9uo9c7840S24R94HfH3MR7v1fr7270QIEV5c50nUAoVHH63t3p91l9 >									
	//        <  u =="0.000000000000000001" : ] 000000095606700.822903000000000000 ; 000000117330559.138001000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000091E25EB30840 >									
	//     < RUSS_PFXIII_II_metadata_line_7_____NORNICKEL_BIMI_20211101 >									
	//        < 1548Jbm459yA9e8DFax31x20mjFd2PgWjjNN9IX51a4jTHFi8C0F5r3VX25xsKL3 >									
	//        <  u =="0.000000000000000001" : ] 000000117330559.138001000000000000 ; 000000133047973.704839000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B30840CB03DD >									
	//     < RUSS_PFXIII_II_metadata_line_8_____NORNICKEL_ALIANS_20211101 >									
	//        < Z9uUqmQt9y8Rq1WzD8JIDKF5fga6tB234qgCliw1Svx53sW2VatihNW27uf23oUl >									
	//        <  u =="0.000000000000000001" : ] 000000133047973.704839000000000000 ; 000000150837740.502825000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CB03DDE628FE >									
	//     < RUSS_PFXIII_II_metadata_line_9_____NORNICKEL_KOMPLEKS_20211101 >									
	//        < WsP0I0AWP28hkHq3Z10rfg2yAm68VZ25t8yJ0F7S73WWRTim0L2cRz7UQW4G3Gy0 >									
	//        <  u =="0.000000000000000001" : ] 000000150837740.502825000000000000 ; 000000169330177.757505000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E628FE102609A >									
	//     < RUSS_PFXIII_II_metadata_line_10_____NORNICKEL_PRODUKT_20211101 >									
	//        < KwbN8W5E5Z74v84pi9cj306LNWeY67Lnw719I2o7709qtyz7OAQi014sr2JL8YdJ >									
	//        <  u =="0.000000000000000001" : ] 000000169330177.757505000000000000 ; 000000190629975.508229000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000102609A122E0D6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIII_II_metadata_line_11_____YENESEI_RIVER_SHIPPING_CO_20211101 >									
	//        < VU701151Fa0WNi8BlQ0uCu31g5miiQ340HmBBu3zZyUbPMSGSZWAGYN33nQ65kcu >									
	//        <  u =="0.000000000000000001" : ] 000000190629975.508229000000000000 ; 000000207346296.220721000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000122E0D613C62A6 >									
	//     < RUSS_PFXIII_II_metadata_line_12_____YENESEI_PI_PENSII_20211101 >									
	//        < ov2Lo4hgR5xm7L5em33CR0DY7Y9W7Uh0mSf98nW423X92J0UptX0VM01EOBJ65K2 >									
	//        <  u =="0.000000000000000001" : ] 000000207346296.220721000000000000 ; 000000224308503.112461000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013C62A61564482 >									
	//     < RUSS_PFXIII_II_metadata_line_13_____YENESEI_PI_ALIANS_20211101 >									
	//        < 01D7KQj19uxa5LqDI54aN15Wv3z4E3e6bCX9De17c0bi69RTQ92nH4aReHdn2YAH >									
	//        <  u =="0.000000000000000001" : ] 000000224308503.112461000000000000 ; 000000244219177.055818000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001564482174A61E >									
	//     < RUSS_PFXIII_II_metadata_line_14_____YENESEI_PI_KROM_20211101 >									
	//        < VcU9rwu5Mmgk3g3FE28bYk4o817n129HKx5972WXlyeR9wak5oxXyTf2Ha70Xrvz >									
	//        <  u =="0.000000000000000001" : ] 000000244219177.055818000000000000 ; 000000262286314.274241000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000174A61E1903797 >									
	//     < RUSS_PFXIII_II_metadata_line_15_____YENESEI_PI_FINANS_20211101 >									
	//        < UQ0t8aS5k4i71UI8URuOo794c38Z0T3Gfo75XVslzlWgSk2zOczaU33Q4dI5Egy1 >									
	//        <  u =="0.000000000000000001" : ] 000000262286314.274241000000000000 ; 000000285572234.951639000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019037971B3BFA7 >									
	//     < RUSS_PFXIII_II_metadata_line_16_____YENESEI_PI_KOMPLEKS_20211101 >									
	//        < OzI68d91h9loP81K143us9I5sgc66Z44aF0rOEAgF97039lt9j7233Q69N4rgg4O >									
	//        <  u =="0.000000000000000001" : ] 000000285572234.951639000000000000 ; 000000305025826.313445000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B3BFA71D16EB7 >									
	//     < RUSS_PFXIII_II_metadata_line_17_____YENESEI_PI_TECH_20211101 >									
	//        < r22c96O92dE583nYYpBl250vOnv1D1wa7ub373sNJr216kJygxq5H1iBJG2OCWAl >									
	//        <  u =="0.000000000000000001" : ] 000000305025826.313445000000000000 ; 000000323739241.087803000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D16EB71EDFCA4 >									
	//     < RUSS_PFXIII_II_metadata_line_18_____YENESEI_PI_KOMPANIYA_20211101 >									
	//        < VwtMX6TUbf1z5Dxz7zwx98Vt8owO5H4wH05w3129aK54uWM71T0PgikN1Irv6sH1 >									
	//        <  u =="0.000000000000000001" : ] 000000323739241.087803000000000000 ; 000000344107678.187154000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EDFCA420D1110 >									
	//     < RUSS_PFXIII_II_metadata_line_19_____YENESEI_PI_MATHS_20211101 >									
	//        < UP7ae98Yj3aaxA8ek0XBZe3465UF0Kq6c4KKYPj7q8as10N4a3E647rlaDmzKvjh >									
	//        <  u =="0.000000000000000001" : ] 000000344107678.187154000000000000 ; 000000368202646.185857000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020D1110231D529 >									
	//     < RUSS_PFXIII_II_metadata_line_20_____YENESEI_PI_PRODUKT_20211101 >									
	//        < M192dSE6SDUP3K8Op51fp1zx3533AVR14f6DFS6665cE2Jy470515F6B5153A2By >									
	//        <  u =="0.000000000000000001" : ] 000000368202646.185857000000000000 ; 000000389233332.467328000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000231D529251EC45 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIII_II_metadata_line_21_____YENESEI_1_ORG_20211101 >									
	//        < teNx34AzTvfC8GH94Thecs88GYx4D16Lk64L2aN6VP1fT0NItHF58T601W4tT0V8 >									
	//        <  u =="0.000000000000000001" : ] 000000389233332.467328000000000000 ; 000000405189565.767081000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000251EC4526A452D >									
	//     < RUSS_PFXIII_II_metadata_line_22_____YENESEI_1_DAO_20211101 >									
	//        < 2yR671ng7sqoKp1iU6McB8F5S7kL316iU4PqYsQneGGYL855r5807rjv9y23LIV8 >									
	//        <  u =="0.000000000000000001" : ] 000000405189565.767081000000000000 ; 000000426450429.087643000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026A452D28AB633 >									
	//     < RUSS_PFXIII_II_metadata_line_23_____YENESEI_1_DAOPI_20211101 >									
	//        < iAW8umN23pvJhZywcNXAm34h2hU70I3l66UT8Fw5CXE8XiGNKejc37WNR7L1HuAb >									
	//        <  u =="0.000000000000000001" : ] 000000426450429.087643000000000000 ; 000000445474353.858141000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028AB6332A7BD6B >									
	//     < RUSS_PFXIII_II_metadata_line_24_____YENESEI_1_DAC_20211101 >									
	//        < 1JPiqRLIdD17g3XNjBWrmp90wb1JWQtXx70tA6Rw61bt4K915f51y2X92KU54jfB >									
	//        <  u =="0.000000000000000001" : ] 000000445474353.858141000000000000 ; 000000468713147.334887000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A7BD6B2CB3313 >									
	//     < RUSS_PFXIII_II_metadata_line_25_____YENESEI_1_BIMI_20211101 >									
	//        < 6sEcV06383VSq0OEGK21736Lh5q4lyIJ25zWBPPunzxnq1b01B3z844xjT87TRG2 >									
	//        <  u =="0.000000000000000001" : ] 000000468713147.334887000000000000 ; 000000487262849.729895000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CB33132E7810D >									
	//     < RUSS_PFXIII_II_metadata_line_26_____YENESEI_2_ORG_20211101 >									
	//        < tRv861yQ3N5HI8H19G77Y3JF0x8Ar1gQ3n24pCv6720Fu2FCZ0afFw34L07BMmbC >									
	//        <  u =="0.000000000000000001" : ] 000000487262849.729895000000000000 ; 000000504314176.635971000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E7810D30185BA >									
	//     < RUSS_PFXIII_II_metadata_line_27_____YENESEI_2_DAO_20211101 >									
	//        < 77Fo7c5L8FTh5500GQIzgk1Cfmb32TDgzaR0b6nOXYq659P6nGg864hfO6YN4k4M >									
	//        <  u =="0.000000000000000001" : ] 000000504314176.635971000000000000 ; 000000522169950.613744000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030185BA31CC4A3 >									
	//     < RUSS_PFXIII_II_metadata_line_28_____YENESEI_2_DAOPI_20211101 >									
	//        < 17acW3x3SYlVQ6k1kVM8f6gsoEs3otvzx7f3R96zWmD4yyGkq0M7AnteD7w23sFI >									
	//        <  u =="0.000000000000000001" : ] 000000522169950.613744000000000000 ; 000000546954459.047287000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031CC4A33429616 >									
	//     < RUSS_PFXIII_II_metadata_line_29_____YENESEI_2_DAC_20211101 >									
	//        < eQorS14s3KbCf08OgdV8S6Tp0mCzsnO5LbiKjuiUE2zDXUijLPI3zDJ95839hi4C >									
	//        <  u =="0.000000000000000001" : ] 000000546954459.047287000000000000 ; 000000569481018.980012000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003429616364F586 >									
	//     < RUSS_PFXIII_II_metadata_line_30_____YENESEI_2_BIMI_20211101 >									
	//        < z9763T23Oqp95zhrLF6tK47ILkS3R00l37LwpFMeuJXwjaq3U530MUdhHUIYcntv >									
	//        <  u =="0.000000000000000001" : ] 000000569481018.980012000000000000 ; 000000587553630.370976000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000364F5863808923 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIII_II_metadata_line_31_____NORDAVIA_20211101 >									
	//        < coUOU32ZK9cW19jB24jqGsT213u23B90ps3z99R74JTTcVj52LcFyoy6t3JR5Q7m >									
	//        <  u =="0.000000000000000001" : ] 000000587553630.370976000000000000 ; 000000611979171.051940000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038089233A5CE5D >									
	//     < RUSS_PFXIII_II_metadata_line_32_____NORDSTAR_20211101 >									
	//        < Q7NZWDKruMyxxI97CJ26jun3mtuTK71iiH1Wc8uwBVZN40k5x5bcq3fWPtg0nBm3 >									
	//        <  u =="0.000000000000000001" : ] 000000611979171.051940000000000000 ; 000000633025779.701917000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A5CE5D3C5EBB2 >									
	//     < RUSS_PFXIII_II_metadata_line_33_____OGK_3_20211101 >									
	//        < Nnybatf8XfH5koeWz3V8aA9o4zb1x0I8K6H4gCh6mev333jzPiMIP62pym7PR28o >									
	//        <  u =="0.000000000000000001" : ] 000000633025779.701917000000000000 ; 000000649276602.729422000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C5EBB23DEB7AC >									
	//     < RUSS_PFXIII_II_metadata_line_34_____TAIMYR_ENERGY_CO_20211101 >									
	//        < ySsuXLq9Ds97Moc8g18lzwkTdEuiTA2nra3cl7b4LSNH84mtJ2xtR3e6TVG04aGn >									
	//        <  u =="0.000000000000000001" : ] 000000649276602.729422000000000000 ; 000000666109836.847485000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DEB7AC3F86728 >									
	//     < RUSS_PFXIII_II_metadata_line_35_____METAL_TRADE_OVERSEAS_AG_20211101 >									
	//        < 807jQQInd9INbMCtE98nW7xlb9Enl2n07LGmz48S36rmiyq404L4Rm4f594UBCs7 >									
	//        <  u =="0.000000000000000001" : ] 000000666109836.847485000000000000 ; 000000690273982.171239000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F8672841D4646 >									
	//     < RUSS_PFXIII_II_metadata_line_36_____KOLSKAYA_GMK_20211101 >									
	//        < aN7NvR1n7k09WY0ZjIKhr5809XeIXl23UuIr8SuzevfZ7cA3S8LI8I8QZKKO3CMQ >									
	//        <  u =="0.000000000000000001" : ] 000000690273982.171239000000000000 ; 000000714246499.940152000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041D4646441DA8A >									
	//     < RUSS_PFXIII_II_metadata_line_37_____NORNICKEL_MMC_FINANCE_LIMITED_20211101 >									
	//        < Oyl4SBrbIt5t0jOnL6QAJJ7ta5vLiWS8oBEro5F5Q8DJr0IJzR8AIKqs0yeatJIW >									
	//        <  u =="0.000000000000000001" : ] 000000714246499.940152000000000000 ; 000000735083871.611530000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000441DA8A461A623 >									
	//     < RUSS_PFXIII_II_metadata_line_38_____NORNICKEL_ASIA_LIMITED_20211101 >									
	//        < l2g4VW4467U9V9Zl8eWg1k5J2fe75jt16qXHIu8Me8mOh7Q9XBbFTz4gg2qY66h4 >									
	//        <  u =="0.000000000000000001" : ] 000000735083871.611530000000000000 ; 000000756581792.441206000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000461A62348273C3 >									
	//     < RUSS_PFXIII_II_metadata_line_39_____TATI_NICKEL_MINING_CO_20211101 >									
	//        < q5CvLHU2esD354LY1ZqTn8t0uouVT0XpK7NZ4x3ay88S7Gx97AL4RIlUrYtJPt4S >									
	//        <  u =="0.000000000000000001" : ] 000000756581792.441206000000000000 ; 000000776962209.793371000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048273C34A18CDD >									
	//     < RUSS_PFXIII_II_metadata_line_40_____TATI_ORG_20211101 >									
	//        < 4EuPq8IRJKeXsJcFTc96NVOUtmtgM10A6r35S71yhyZB0p45p4Nl8qsli9QJ6XXU >									
	//        <  u =="0.000000000000000001" : ] 000000776962209.793371000000000000 ; 000000800200638.111902000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A18CDD4C50260 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}