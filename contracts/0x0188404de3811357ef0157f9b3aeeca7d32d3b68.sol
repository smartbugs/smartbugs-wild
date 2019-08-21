pragma solidity 		^0.4.21	;						
										
	contract	NISSAN_usd_31_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NISSAN_usd_31_883		"	;
		string	public		symbol =	"	NISSAN_usd_31_1subDT		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1143826793595050000000000000					;	
										
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
	//     < NISSAN_usd_31_metadata_line_1_____NISSAN_usd_31Y_abc_i >									
	//        < 96YOuS49yTd3RbDejf6I3831J0EGL7j70u67m2Dk3WF7G6IdWDplWhV765GZ4IjM >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000028767841.219959000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000002BE570 >									
	//     < NISSAN_usd_31_metadata_line_2_____NISSAN_usd_31Y_abc_ii >									
	//        < 984YU567ky87Nyyq5hmTM1IYT6EXZxL8FrNgP5c49zsWb9jEiF7K3bi1MUbe1DKq >									
	//        <  u =="0.000000000000000001" : ] 000000028767841.219959000000000000 ; 000000057616018.039047800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002BE57057EA42 >									
	//     < NISSAN_usd_31_metadata_line_3_____NISSAN_usd_31Y_abc_iii >									
	//        < 9nCNB3Ib35kC42zaVdomS6BIS3Bk1G5Z5eApf83R2e18N20aTEM2jZVKJ4ssAAA2 >									
	//        <  u =="0.000000000000000001" : ] 000000057616018.039047800000000000 ; 000000085462347.503067200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000057EA428267BB >									
	//     < NISSAN_usd_31_metadata_line_4_____NISSAN_usd_31Y_abc_iv >									
	//        < 0uo5wMEi0XfLnp84jyD3wiH1pGlVW93pTPjwbE5284Hswp451q38ZNd3lJQ8rTY9 >									
	//        <  u =="0.000000000000000001" : ] 000000085462347.503067200000000000 ; 000000114532829.475137000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008267BBAEC363 >									
	//     < NISSAN_usd_31_metadata_line_5_____NISSAN_usd_31Y_abc_v >									
	//        < 1SdN5tWLEMOKYy23p875uRgE1S1WeVIsiv6FWKL8O7601C2kSpp99kB1zoy39t7R >									
	//        <  u =="0.000000000000000001" : ] 000000114532829.475137000000000000 ; 000000142952170.950203000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AEC363DA20B1 >									
	//     < NISSAN_usd_31_metadata_line_6_____NISSAN_usd_31Y_abc_vi >									
	//        < hm3zb2Brsh13jq545FlabT3UfYYSn77VDmZlYSgnd66xRetaR70wd134Z1daKL2A >									
	//        <  u =="0.000000000000000001" : ] 000000142952170.950203000000000000 ; 000000171199856.685922000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000DA20B11053AF2 >									
	//     < NISSAN_usd_31_metadata_line_7_____NISSAN_usd_31Y_abc_vii >									
	//        < fp40hDO6rKgG7JzJ9ZXUFau1Gr82e5lSBC6WHGcffOmuOMaiiqEuLO53Qb0BDp5A >									
	//        <  u =="0.000000000000000001" : ] 000000171199856.685922000000000000 ; 000000199971585.406257000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001053AF213121E7 >									
	//     < NISSAN_usd_31_metadata_line_8_____NISSAN_usd_31Y_abc_viii >									
	//        < EPHT7I8G6ilvRanH8hz09Y46LLG8J39ub9Ac8xB0TfQy9cp3uKaN648Ug8Rc1bCH >									
	//        <  u =="0.000000000000000001" : ] 000000199971585.406257000000000000 ; 000000228035387.641908000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013121E715BF453 >									
	//     < NISSAN_usd_31_metadata_line_9_____NISSAN_usd_31Y_abc_ix >									
	//        < 5JfNf3I0IHrqs0sIK4e3s27zUrT8lsd34130p3pzeSM1gBj2o3qVL4P2mTN3Tw0V >									
	//        <  u =="0.000000000000000001" : ] 000000228035387.641908000000000000 ; 000000257137588.192373000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015BF4531885C5F >									
	//     < NISSAN_usd_31_metadata_line_10_____NISSAN_usd_31Y_abc_x >									
	//        < y3LfkWQ1btSy5VmddeW1OK7cz5LY5A6CXlNgI8HVvJB8RuN9VY6vx59060do9sDK >									
	//        <  u =="0.000000000000000001" : ] 000000257137588.192373000000000000 ; 000000285691790.355958000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001885C5F1B3EE5B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NISSAN_usd_31_metadata_line_11_____NISSAN_usd_31Y_abc_xi >									
	//        < n96LYHu2CFFkK8F4DcMrfT8622Utj7FETcHMnN881hMGPJht7Sy2ZXifg1w1yzWo >									
	//        <  u =="0.000000000000000001" : ] 000000285691790.355958000000000000 ; 000000314744010.792358000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B3EE5B1E042E1 >									
	//     < NISSAN_usd_31_metadata_line_12_____NISSAN_usd_31Y_abc_xii >									
	//        < rg8R8sPf219Z0XKtKZKT8EjzOjpp5703i8KTg4iEv0qqRF26j59Kudt8w2v0m8I6 >									
	//        <  u =="0.000000000000000001" : ] 000000314744010.792358000000000000 ; 000000343189395.137307000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E042E120BAA5C >									
	//     < NISSAN_usd_31_metadata_line_13_____NISSAN_usd_31Y_abc_xiii >									
	//        < KJk521PBgH572QwaXxz6jd3c3arV467H42j8aEj6aL4ItPs10frfxt5jVb5iKu6y >									
	//        <  u =="0.000000000000000001" : ] 000000343189395.137307000000000000 ; 000000371969202.174499000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020BAA5C2379478 >									
	//     < NISSAN_usd_31_metadata_line_14_____NISSAN_usd_31Y_abc_xiv >									
	//        < iByhHKbvOuqhqw114r8cTgCd67F2dhCJ3y7y68onBc67F71RNbxXUbr3yI96j9ro >									
	//        <  u =="0.000000000000000001" : ] 000000371969202.174499000000000000 ; 000000400528616.145221000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002379478263287E >									
	//     < NISSAN_usd_31_metadata_line_15_____NISSAN_usd_31Y_abc_xv >									
	//        < Q772ZRUKc38Hmx5rEezHqqVvLH3Mgr53ob0z1iv8E86thQYsMPDQX69Hh0pp61vo >									
	//        <  u =="0.000000000000000001" : ] 000000400528616.145221000000000000 ; 000000428430823.508686000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000263287E28DBBCA >									
	//     < NISSAN_usd_31_metadata_line_16_____NISSAN_usd_31Y_abc_xvi >									
	//        < xpA1EczviPgGhNgw8mU5kTF241K1eeVAZ7Z3591512TC1cx2li5lOZvZafW136bF >									
	//        <  u =="0.000000000000000001" : ] 000000428430823.508686000000000000 ; 000000457481538.603809000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028DBBCA2BA0FBA >									
	//     < NISSAN_usd_31_metadata_line_17_____NISSAN_usd_31Y_abc_xvii >									
	//        < P9MJ59AVPb7ArVAX9T10f7Y3e03v95841UUy4kd25sj6ek693ea6B2Sulub8tkFG >									
	//        <  u =="0.000000000000000001" : ] 000000457481538.603809000000000000 ; 000000486523701.660850000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BA0FBA2E66052 >									
	//     < NISSAN_usd_31_metadata_line_18_____NISSAN_usd_31Y_abc_xviii >									
	//        < NNY82S2ntTuLuTlAkZvDllg3CuV0n6qBfc57O4j2V5JFm88U1PD254dzEq0cDd3z >									
	//        <  u =="0.000000000000000001" : ] 000000486523701.660850000000000000 ; 000000515114825.637636000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E6605231200BB >									
	//     < NISSAN_usd_31_metadata_line_19_____NISSAN_usd_31Y_abc_xix >									
	//        < 6s27Jx5A1hc7GrS0HluaRO3LXQrvM4bLK9241n6kr6GEeM885SJ4AO3tr98aD46Q >									
	//        <  u =="0.000000000000000001" : ] 000000515114825.637636000000000000 ; 000000543845231.531160000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031200BB33DD78B >									
	//     < NISSAN_usd_31_metadata_line_20_____NISSAN_usd_31Y_abc_xx >									
	//        < e2l22pXI8eGbgI91fJ9VXy3FNAIQLXyjyX2pP7Vw91vfpgdG00W158u3ZyyG0kWs >									
	//        <  u =="0.000000000000000001" : ] 000000543845231.531160000000000000 ; 000000573018036.794185000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033DD78B36A5B2C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NISSAN_usd_31_metadata_line_21_____NISSAN_usd_31Y_abc_xxi >									
	//        < zNbC8iS4wCMNttF3j26cZU3LcAxc90QM78X313k6BuO86ATWLhb7oX0DJV73A0qe >									
	//        <  u =="0.000000000000000001" : ] 000000573018036.794185000000000000 ; 000000602204378.030663000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036A5B2C396E416 >									
	//     < NISSAN_usd_31_metadata_line_22_____NISSAN_usd_31Y_abc_xxii >									
	//        < rZ2hxAkIY89Yzx491naed7tL405M3t7JNtBZ38ekW9W8aqil9Q0DsDiSlsBzm4mb >									
	//        <  u =="0.000000000000000001" : ] 000000602204378.030663000000000000 ; 000000630873770.699938000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000396E4163C2A311 >									
	//     < NISSAN_usd_31_metadata_line_23_____NISSAN_usd_31Y_abc_xxiii >									
	//        < UJo6sUHgbBs32e3Hw4UmuI9cdr6HibyMIPfp0Yl09HAV31hT7zyMa0JkDCm63479 >									
	//        <  u =="0.000000000000000001" : ] 000000630873770.699938000000000000 ; 000000658726941.136062000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C2A3113ED2336 >									
	//     < NISSAN_usd_31_metadata_line_24_____NISSAN_usd_31Y_abc_xxiv >									
	//        < 4ELw5F7BXd2NX4rOO0Iuyd2wAd1IliIlIWLHvsQ1R40zzr2MBxGYn6knHFUv5nya >									
	//        <  u =="0.000000000000000001" : ] 000000658726941.136062000000000000 ; 000000687711608.757786000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003ED23364195D59 >									
	//     < NISSAN_usd_31_metadata_line_25_____NISSAN_usd_31Y_abc_xxv >									
	//        < h1CtpEhWM0Fu2u2WCkQMUutm9Nb8swboE92M4r71xk44RqZosORd7cgF3n3oSm9Q >									
	//        <  u =="0.000000000000000001" : ] 000000687711608.757786000000000000 ; 000000715949320.529132000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004195D5944473B4 >									
	//     < NISSAN_usd_31_metadata_line_26_____NISSAN_usd_31Y_abc_xxvi >									
	//        < D2Yt8mQVM82400b7Dj702g7846ZSkpU312d6DGhDY185IjtfATzS3FeMo594lJhU >									
	//        <  u =="0.000000000000000001" : ] 000000715949320.529132000000000000 ; 000000744957265.035860000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044473B4470B6EF >									
	//     < NISSAN_usd_31_metadata_line_27_____NISSAN_usd_31Y_abc_xxvii >									
	//        < 5l9sy3kJOvogDe4MdzhN52Cm12kj7D3RbW4F9c7vQC34R33dWAT46XRZVEx7MmZ7 >									
	//        <  u =="0.000000000000000001" : ] 000000744957265.035860000000000000 ; 000000773985713.381517000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000470B6EF49D022B >									
	//     < NISSAN_usd_31_metadata_line_28_____NISSAN_usd_31Y_abc_xxviii >									
	//        < wK8Y7sZzFp0y4rXbuG9Mp2JEWruGg432KE7eU9631W8tO6zWwzt1mPpQSD0i5v5g >									
	//        <  u =="0.000000000000000001" : ] 000000773985713.381517000000000000 ; 000000801937166.949711000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049D022B4C7A8B5 >									
	//     < NISSAN_usd_31_metadata_line_29_____NISSAN_usd_31Y_abc_xxix >									
	//        < HkLvbGXf7RGRE47NZpy8oFQqTCZWjTl6r59688pgFP3H1v65qB7p1m267R30m41N >									
	//        <  u =="0.000000000000000001" : ] 000000801937166.949711000000000000 ; 000000829891965.270429000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C7A8B54F2508D >									
	//     < NISSAN_usd_31_metadata_line_30_____NISSAN_usd_31Y_abc_xxx >									
	//        < R94ram5M4J0cSm5gGd5214w525ibg1BzHo559dna71G4eTh85lZ1C47Utf4yLL9T >									
	//        <  u =="0.000000000000000001" : ] 000000829891965.270429000000000000 ; 000000858607775.048074000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004F2508D51E21AA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NISSAN_usd_31_metadata_line_31_____NISSAN_usd_31Y_abc_xxxi >									
	//        < C5L64K3J2aNSc8K4RM9s3Ck7Db6vjep4zhpq674FTn6nIz840TZIx5a66Ak9chSU >									
	//        <  u =="0.000000000000000001" : ] 000000858607775.048074000000000000 ; 000000887787841.268889000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000051E21AA54AA820 >									
	//     < NISSAN_usd_31_metadata_line_32_____NISSAN_usd_31Y_abc_xxxii >									
	//        < K352BVy4tdv39sQqMU4c9iKHYQ8If5Uzt08V6O2xxpKl1TvROV6Ywz301Y2QYo7D >									
	//        <  u =="0.000000000000000001" : ] 000000887787841.268889000000000000 ; 000000915689621.864420000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000054AA8205753B42 >									
	//     < NISSAN_usd_31_metadata_line_33_____NISSAN_usd_31Y_abc_xxxiii >									
	//        < 6i771A2mu4W8n2YpH3lm448B7253x0v3529h62lP020CT36g6YG4FN4n4dX6017A >									
	//        <  u =="0.000000000000000001" : ] 000000915689621.864420000000000000 ; 000000944546805.490515000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005753B425A14399 >									
	//     < NISSAN_usd_31_metadata_line_34_____NISSAN_usd_31Y_abc_xxxiv >									
	//        < 4y9CxAa69iOLM87mf1WeLCf47D22R4CaWZ03h2b2RY6irC6bjzZ3Y3aqoPNFos1q >									
	//        <  u =="0.000000000000000001" : ] 000000944546805.490515000000000000 ; 000000972735239.406166000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005A143995CC46B4 >									
	//     < NISSAN_usd_31_metadata_line_35_____NISSAN_usd_31Y_abc_xxxv >									
	//        < nmfy7r0g9dbhcSla1Xm7fRVN3761qbK6qYP9oG4McxdX292LmM6H004KF1fsQiM4 >									
	//        <  u =="0.000000000000000001" : ] 000000972735239.406166000000000000 ; 000001001267688.582230000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005CC46B45F7D031 >									
	//     < NISSAN_usd_31_metadata_line_36_____NISSAN_usd_31Y_abc_xxxvi >									
	//        < EtZ9g1JNa4SuGWQrwsPZN89hgwdZB2Gh9F439h35apLsdAgkPIQ59AQLvYMM04k5 >									
	//        <  u =="0.000000000000000001" : ] 000001001267688.582230000000000000 ; 000001029850374.355630000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005F7D0316236D4D >									
	//     < NISSAN_usd_31_metadata_line_37_____NISSAN_usd_31Y_abc_xxxvii >									
	//        < FD37Fl81tWUA014mcY2fNN34rBJx8wKC9r1lw65M4VffoC7omj0JOXciUP5MwrZh >									
	//        <  u =="0.000000000000000001" : ] 000001029850374.355630000000000000 ; 000001057643159.926470000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006236D4D64DD5DC >									
	//     < NISSAN_usd_31_metadata_line_38_____NISSAN_usd_31Y_abc_xxxviii >									
	//        < uE7qrXRrjOf7L66J0Ny0zl8vdt6XXGrU90woxxmL35qK3KF3MhMF2e06423d57Q3 >									
	//        <  u =="0.000000000000000001" : ] 000001057643159.926470000000000000 ; 000001086536934.649170000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000064DD5DC679EC7D >									
	//     < NISSAN_usd_31_metadata_line_39_____NISSAN_usd_31Y_abc_xxxix >									
	//        < mIYEM49Q6ed8DcI3GANRTIxh4HJJLN7kC8O90mfbc6UTDpnek42Y5w1eG5WbRX7X >									
	//        <  u =="0.000000000000000001" : ] 000001086536934.649170000000000000 ; 000001114969013.452850000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000679EC7D6A54EC5 >									
	//     < NISSAN_usd_31_metadata_line_40_____NISSAN_usd_31Y_abc_xxxx >									
	//        < MYEs6x0tpDp8wLS3XL6f2grncFHM336JDqv969kW1JGJufvW5K1wD7Dhp3C366Oy >									
	//        <  u =="0.000000000000000001" : ] 000001114969013.452850000000000000 ; 000001143826793.595050000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006A54EC56D15757 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}