pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXV_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXV_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXV_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1067985630555170000000000000					;	
										
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
	//     < RUSS_PFXXV_III_metadata_line_1_____GAZPROM_20251101 >									
	//        < MIj70sVA0Dq1J9l7AzJSMkc2csC9YtNDpTpMWqn93591CFBcI273pEp7eX2O9jYs >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000019162790.696707700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001D3D77 >									
	//     < RUSS_PFXXV_III_metadata_line_2_____PROM_DAO_20251101 >									
	//        < KwigY9RX50xA4h9AuQwh4Yt5Y51cR0V191oZtAN92Fit7J5MD94o57MjjU2Cl04t >									
	//        <  u =="0.000000000000000001" : ] 000000019162790.696707700000000000 ; 000000050450110.990550600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001D3D774CFB13 >									
	//     < RUSS_PFXXV_III_metadata_line_3_____PROM_DAOPI_20251101 >									
	//        < kRL1tWQ51V3rdGwUy5VYXhyY9qlYaCal377H82xZAJCZFss2gBJ2xs012jw4Lnk4 >									
	//        <  u =="0.000000000000000001" : ] 000000050450110.990550600000000000 ; 000000071788982.834694400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004CFB136D8A92 >									
	//     < RUSS_PFXXV_III_metadata_line_4_____PROM_DAC_20251101 >									
	//        < q8UT4Tu9YyYW1f7m8g48rkwMo7X9i23D2mi72ng6Wq710YQ7680Obi1Pbum7R8R2 >									
	//        <  u =="0.000000000000000001" : ] 000000071788982.834694400000000000 ; 000000095908732.588568500000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006D8A92925859 >									
	//     < RUSS_PFXXV_III_metadata_line_5_____PROM_BIMI_20251101 >									
	//        < 3qxarp216N4amXk3ceGQr40vR9x16cLxnDbOW008pN2fwekIXo0E1yLx973SvLf1 >									
	//        <  u =="0.000000000000000001" : ] 000000095908732.588568500000000000 ; 000000123695204.878770000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000925859BCBE70 >									
	//     < RUSS_PFXXV_III_metadata_line_6_____GAZPROMNEFT_20251101 >									
	//        < C0kz3xzDsX0MPZd7HoiiOzE86GVqxbzK6ZRbtqFtkDf2Z5iM0OR5ArKK0wi2Z858 >									
	//        <  u =="0.000000000000000001" : ] 000000123695204.878770000000000000 ; 000000158460238.263226000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BCBE70F1CA88 >									
	//     < RUSS_PFXXV_III_metadata_line_7_____GAZPROMBANK_BD_20251101 >									
	//        < xk4reRAG18l20X7qPQ85102ukPwLFFew9F76KLAhRR5rHvbJpq50996Kp61gdBao >									
	//        <  u =="0.000000000000000001" : ] 000000158460238.263226000000000000 ; 000000192985755.071795000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F1CA881267910 >									
	//     < RUSS_PFXXV_III_metadata_line_8_____MEZHEREGIONGAZ_20251101 >									
	//        < 442s8HMF05tg8AjOo8g7RD4niIBVcIrem0O40LtM7mL8xoum4zUn7SUL0g6j67Vl >									
	//        <  u =="0.000000000000000001" : ] 000000192985755.071795000000000000 ; 000000227777085.119975000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000126791015B8F6D >									
	//     < RUSS_PFXXV_III_metadata_line_9_____SALAVATNEFTEORGSINTEZ_20251101 >									
	//        < DWdxjHAqw82EP2tQd3vExQ5Lt5MO5C29UqtcolFLd1WP4fuKu9EK7Na017Ln6zZl >									
	//        <  u =="0.000000000000000001" : ] 000000227777085.119975000000000000 ; 000000254558161.885468000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015B8F6D1846CC8 >									
	//     < RUSS_PFXXV_III_metadata_line_10_____SAKHALIN_ENERGY_20251101 >									
	//        < 4QCKz9B0rtrhuv6Ri1tS9Q6Frsq0TSIn7F1p471Wo6rjKT5d243g9nEd5tO0993F >									
	//        <  u =="0.000000000000000001" : ] 000000254558161.885468000000000000 ; 000000289258629.255044000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001846CC81B95FA7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXV_III_metadata_line_11_____NORDSTREAM_AG_20251101 >									
	//        < 9zcBpP5z067nyj1F1178Cnq0u92Q5vhCaF5H30eW7ucnR2u3422GI9s9l57k6RNX >									
	//        <  u =="0.000000000000000001" : ] 000000289258629.255044000000000000 ; 000000322034140.170393000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B95FA71EB6296 >									
	//     < RUSS_PFXXV_III_metadata_line_12_____NORDSTREAM_DAO_20251101 >									
	//        < 7zA7T41t0UnA1K2qSFc3lhN8oVtcJz0I6s173480KD8hn9022R1Np22BrbmXTN66 >									
	//        <  u =="0.000000000000000001" : ] 000000322034140.170393000000000000 ; 000000355109451.141612000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EB629621DDAA1 >									
	//     < RUSS_PFXXV_III_metadata_line_13_____NORDSTREAM_DAOPI_20251101 >									
	//        < ImA1jMl9H13OQAUn20561M6DP04NEEMC6zk4lJ25j50NIbJ7jHqqQq4hU0Xh7j00 >									
	//        <  u =="0.000000000000000001" : ] 000000355109451.141612000000000000 ; 000000387198076.259448000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021DDAA124ED140 >									
	//     < RUSS_PFXXV_III_metadata_line_14_____NORDSTREAM_DAC_20251101 >									
	//        < 486qM10F33eV8uR33xhvM47T43HtVcn3TR6lDlawm7KtPlr6y2K3m376H9UdXp0t >									
	//        <  u =="0.000000000000000001" : ] 000000387198076.259448000000000000 ; 000000415029252.739705000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024ED14027948CD >									
	//     < RUSS_PFXXV_III_metadata_line_15_____NORDSTREAM_BIMI_20251101 >									
	//        < 29d773v26V5NH694ePlO4e08cQk4P905MvWKd3tk3thlJXJxvOX4x1M0erG26LLu >									
	//        <  u =="0.000000000000000001" : ] 000000415029252.739705000000000000 ; 000000435461862.886281000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027948CD298764A >									
	//     < RUSS_PFXXV_III_metadata_line_16_____GASCAP_ORG_20251101 >									
	//        < KPbcBNws73O0EOP7s1a155ojY8Gp34MMO4SpK7MLBX0Cpw75irzFEhtn6U4vl4Rk >									
	//        <  u =="0.000000000000000001" : ] 000000435461862.886281000000000000 ; 000000466424474.047841000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000298764A2C7B50F >									
	//     < RUSS_PFXXV_III_metadata_line_17_____GASCAP_DAO_20251101 >									
	//        < UH89tVx0QYyr0a7QpO35UQZ0Wb3sZ5WjG5oZSy5037f93K79hCbDQi5S0prMT0MV >									
	//        <  u =="0.000000000000000001" : ] 000000466424474.047841000000000000 ; 000000488685368.023583000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C7B50F2E9ACB9 >									
	//     < RUSS_PFXXV_III_metadata_line_18_____GASCAP_DAOPI_20251101 >									
	//        < r13G6R6TVOqsGOh7883SazZ5f22iTF70x0Vq9dwcln40fyyM129yLVj4KcHQvOec >									
	//        <  u =="0.000000000000000001" : ] 000000488685368.023583000000000000 ; 000000515179598.830706000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E9ACB93121A08 >									
	//     < RUSS_PFXXV_III_metadata_line_19_____GASCAP_DAC_20251101 >									
	//        < VlrL7owb28J96c826d205UrCM741uJTfBj25V38ogoDRzblEi724njFo1DISf1fg >									
	//        <  u =="0.000000000000000001" : ] 000000515179598.830706000000000000 ; 000000539103872.670177000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003121A083369B73 >									
	//     < RUSS_PFXXV_III_metadata_line_20_____GASCAP_BIMI_20251101 >									
	//        < ATFS5yq8zI5LBrd7u3Mec2g2NF2bcV5AJNliyYIK2IvfE34h9w8Undh0s1Jb06fn >									
	//        <  u =="0.000000000000000001" : ] 000000539103872.670177000000000000 ; 000000558326304.359721000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003369B73353F036 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXV_III_metadata_line_21_____GAZ_CAPITAL_SA_20251101 >									
	//        < W8ULNbkOZjM83VFBlZuWo34H5rIH8fxIIG2fBW1Wms58A0QlHfpdW9ikXkZ65z28 >									
	//        <  u =="0.000000000000000001" : ] 000000558326304.359721000000000000 ; 000000593473052.417507000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000353F0363899169 >									
	//     < RUSS_PFXXV_III_metadata_line_22_____BELTRANSGAZ_20251101 >									
	//        < XG3HtJ9qr93AZ219ku0Rm3yPQiH573o74Zme8R8n91t3Y6020R6rw86a7XG54Yb7 >									
	//        <  u =="0.000000000000000001" : ] 000000593473052.417507000000000000 ; 000000623421281.803526000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038991693B743F0 >									
	//     < RUSS_PFXXV_III_metadata_line_23_____OVERGAS_20251101 >									
	//        < bo267DLUz0K88947V563wNTcI4QQ84SEn7f0CH46tf5S6Nd6mE48axW07ae70710 >									
	//        <  u =="0.000000000000000001" : ] 000000623421281.803526000000000000 ; 000000654925146.478292000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B743F03E75623 >									
	//     < RUSS_PFXXV_III_metadata_line_24_____GAZPROM_MARKETING_TRADING_20251101 >									
	//        < 6Y8K89O8Rd6yW5EVy37O7sY8W9Lmxri52S50kkh8r2o2p8u7M2f6ypn6Bp4855PE >									
	//        <  u =="0.000000000000000001" : ] 000000654925146.478292000000000000 ; 000000674137314.570937000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E75623404A6E3 >									
	//     < RUSS_PFXXV_III_metadata_line_25_____ROSUKRENERGO_20251101 >									
	//        < 878rBmEjSJx565PykivbmB1UR6uWMVp2c297r9piq1S8HkduNl80ndvp1G1sxWtW >									
	//        <  u =="0.000000000000000001" : ] 000000674137314.570937000000000000 ; 000000698627208.812908000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000404A6E342A0541 >									
	//     < RUSS_PFXXV_III_metadata_line_26_____TRANSGAZ_VOLGORAD_20251101 >									
	//        < B6118V594ygHH2zg0kbE8s3N76x781T4l6Vjcxj724a18K6myw6vF67Fe3i7CGEd >									
	//        <  u =="0.000000000000000001" : ] 000000698627208.812908000000000000 ; 000000726217720.097880000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042A05414541ECC >									
	//     < RUSS_PFXXV_III_metadata_line_27_____SPACE_SYSTEMS_20251101 >									
	//        < v8HBLF6t0r4VXS827qqWR1eR5Krd2Zz0Dh1WoR353IIsfbXg99tKfZ70UKDMJYf5 >									
	//        <  u =="0.000000000000000001" : ] 000000726217720.097880000000000000 ; 000000753544020.590338000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004541ECC47DD122 >									
	//     < RUSS_PFXXV_III_metadata_line_28_____MOLDOVAGAZ_20251101 >									
	//        < BB65ga6T2bg2Z08Ze80ti1KRPFcHn5S9ZP2M05M52Po7a4TCUG76DTMN6j69mtFT >									
	//        <  u =="0.000000000000000001" : ] 000000753544020.590338000000000000 ; 000000774356241.027675000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047DD12249D92E8 >									
	//     < RUSS_PFXXV_III_metadata_line_29_____VOSTOKGAZPROM_20251101 >									
	//        < o4876jIx3v0xcw2tzd0VdbE9M7ivxMe97tJayE536G1M23PGp4cuX6S0SV4chTaF >									
	//        <  u =="0.000000000000000001" : ] 000000774356241.027675000000000000 ; 000000794170701.232528000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049D92E84BBCEEE >									
	//     < RUSS_PFXXV_III_metadata_line_30_____GAZPROM_UK_20251101 >									
	//        < 0H08IXJh6UsMWc93a9Io3i8L3r4i5PR9CL69qG4C5E0qC038642uHL7uhbSYh52r >									
	//        <  u =="0.000000000000000001" : ] 000000794170701.232528000000000000 ; 000000817638491.263247000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004BBCEEE4DF9E09 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXV_III_metadata_line_31_____SOUTHSTREAM_AG_20251101 >									
	//        < e9qAVg1s2DbbhOneVgD2OE8A0b5RvOB86pY8p6UWToqw4DC9TtC5eaoesaZxMNo3 >									
	//        <  u =="0.000000000000000001" : ] 000000817638491.263247000000000000 ; 000000849067020.861433000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004DF9E0950F92CE >									
	//     < RUSS_PFXXV_III_metadata_line_32_____SOUTHSTREAM_DAO_20251101 >									
	//        < SW5IpR2t023Y96C87ek8m04L1M86Qa487F4V2zH38Y2hVNemhOklMPl9a69RrM0I >									
	//        <  u =="0.000000000000000001" : ] 000000849067020.861433000000000000 ; 000000868650895.952162000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000050F92CE52D74C2 >									
	//     < RUSS_PFXXV_III_metadata_line_33_____SOUTHSTREAM_DAOPI_20251101 >									
	//        < fvRde12436Grk3A6O2BC2229OLi0J027YCYRD65nWxgl61CjN3szyJeC80cafj4W >									
	//        <  u =="0.000000000000000001" : ] 000000868650895.952162000000000000 ; 000000898279388.762022000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000052D74C255AAA63 >									
	//     < RUSS_PFXXV_III_metadata_line_34_____SOUTHSTREAM_DAC_20251101 >									
	//        < G3iOpFVpWtOzNgBg12X7tJ8jV01jQn70eZ6t93LuaCj4nw75wf1r2SQCR94FRtN2 >									
	//        <  u =="0.000000000000000001" : ] 000000898279388.762022000000000000 ; 000000918859969.714199000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000055AAA6357A11AD >									
	//     < RUSS_PFXXV_III_metadata_line_35_____SOUTHSTREAM_BIMI_20251101 >									
	//        < llTfSuXVAGTWb99HY21aL4vC6mE85biuc34pC0qDL3OnqMr6h06CzNPfT4PSH6K5 >									
	//        <  u =="0.000000000000000001" : ] 000000918859969.714199000000000000 ; 000000942885996.034889000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057A11AD59EBAD8 >									
	//     < RUSS_PFXXV_III_metadata_line_36_____GAZPROM_ARMENIA_20251101 >									
	//        < 9864Aj0X72w2FK64C3e5r7Vn75aA2D7c4P7b2H7o9oX6lOW9Am7yyXsPVbBwiH18 >									
	//        <  u =="0.000000000000000001" : ] 000000942885996.034889000000000000 ; 000000965960552.660323000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000059EBAD85C1F057 >									
	//     < RUSS_PFXXV_III_metadata_line_37_____CHORNOMORNAFTOGAZ_20251101 >									
	//        < VZuf66JAwq44gp02ulzfnOY3t70hYvu8fWoT4NUdt1SyewpC8sfQq7OJCsB4RFif >									
	//        <  u =="0.000000000000000001" : ] 000000965960552.660323000000000000 ; 000000985875277.316508000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005C1F0575E05388 >									
	//     < RUSS_PFXXV_III_metadata_line_38_____SHTOKMAN_DEV_AG_20251101 >									
	//        < Iz8T16B0025m0VtV5SP37Om3y6pSKjoQ1kREY9DwWpxgbMEjmU3rHSzqD6Z2L7Bu >									
	//        <  u =="0.000000000000000001" : ] 000000985875277.316508000000000000 ; 000001019377494.145290000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005E053886137255 >									
	//     < RUSS_PFXXV_III_metadata_line_39_____VEMEX_20251101 >									
	//        < f4EpuEVeb6971R2J8Dr59hQe2667Qbqgshnb49hOX0sMC8V3Dj8z00vu8w1OYTER >									
	//        <  u =="0.000000000000000001" : ] 000001019377494.145290000000000000 ; 000001038868933.945070000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006137255631302D >									
	//     < RUSS_PFXXV_III_metadata_line_40_____BOSPHORUS_GAZ_20251101 >									
	//        < TI3czO682c9WAoPHX203Ld447zv1ykNpN5I192ibtb331WDwtM3E37kqyY4HaJ5G >									
	//        <  u =="0.000000000000000001" : ] 000001038868933.945070000000000000 ; 000001067985630.555170000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000631302D65D9DE3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}