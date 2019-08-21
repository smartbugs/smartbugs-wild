pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFIV_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFIV_II_883		"	;
		string	public		symbol =	"	NDRV_PFIV_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1173533492794600000000000000					;	
										
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
	//     < NDRV_PFIV_II_metadata_line_1_____gerling beteiligungs_gmbh_20231101 >									
	//        < mlEGAMf4As0q7t4hGNNz9ig52W29HheGrRSq2fVZAy65aABwAKZ2zZ3sn2Ky7md0 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000020669414.623124000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001F89FD >									
	//     < NDRV_PFIV_II_metadata_line_2_____aspecta lebensversicherung ag_20231101 >									
	//        < FXaRbv50i5PIyGC928954VuR27jetQ8759dYh7nRa04p6QN6QQZ1Km616Mk708QZ >									
	//        <  u =="0.000000000000000001" : ] 000000020669414.623124000000000000 ; 000000064165569.335083400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001F89FD61E8AD >									
	//     < NDRV_PFIV_II_metadata_line_3_____ampega asset management gmbh_20231101 >									
	//        < n6Z7XuL56Q2dGeV9i1e732u8rA17vFT0BFp6bp8ad1mJ5DPfXlKO4vA9cG0HPlPi >									
	//        <  u =="0.000000000000000001" : ] 000000064165569.335083400000000000 ; 000000081299717.055406300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000061E8AD7C0DB4 >									
	//     < NDRV_PFIV_II_metadata_line_4_____deutschland bancassurance gmbh_20231101 >									
	//        < G4KBtY9qRsUAs5CdLwFQQySJF6MM361h64vt3enX4S74mJI44BDP1aAm3I5C30D0 >									
	//        <  u =="0.000000000000000001" : ] 000000081299717.055406300000000000 ; 000000102237015.542463000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007C0DB49C0056 >									
	//     < NDRV_PFIV_II_metadata_line_5_____hdi_gerling assurances sa_20231101 >									
	//        < 06c64R75g5F07QzOciU7w26O4F8Y9B3L6u28rpnB7GHsxAZx6xe46VQ3436Mx7Lu >									
	//        <  u =="0.000000000000000001" : ] 000000102237015.542463000000000000 ; 000000117987739.556514000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009C0056B408F6 >									
	//     < NDRV_PFIV_II_metadata_line_6_____hdi_gerling firmen und privat versicherung ag_20231101 >									
	//        < 108x96FizY81PhXSX11Rm9d3flDF6QGZzCwsD29vDxFKG90YRxLn5T97DBWBQpkq >									
	//        <  u =="0.000000000000000001" : ] 000000117987739.556514000000000000 ; 000000135833885.998880000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B408F6CF441D >									
	//     < NDRV_PFIV_II_metadata_line_7_____ooo strakhovaya kompaniya civ life_20231101 >									
	//        < 2x43kmcr51P6Kee32jHUimO3WowTlXSQ5cfWPd00VXVj91LQeHB7N6lYgx21go92 >									
	//        <  u =="0.000000000000000001" : ] 000000135833885.998880000000000000 ; 000000154264813.615301000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CF441DEB63B1 >									
	//     < NDRV_PFIV_II_metadata_line_8_____inversiones magallanes sa_20231101 >									
	//        < Zj4425p39IMG1G1bvBK4kIbb9YE688vu45OUS5zOosD5c43IG79A3vbHH5KR46Cu >									
	//        <  u =="0.000000000000000001" : ] 000000154264813.615301000000000000 ; 000000182615261.957128000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EB63B1116A616 >									
	//     < NDRV_PFIV_II_metadata_line_9_____hdi seguros de vida sa_20231101 >									
	//        < nVF86gbkEe4a6GEGREIN2apx1ExVg3C3sZJJLPrBopQyrAM3OggIy9I0222O38rj >									
	//        <  u =="0.000000000000000001" : ] 000000182615261.957128000000000000 ; 000000198615525.335799000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000116A61612F1031 >									
	//     < NDRV_PFIV_II_metadata_line_10_____winsor verwaltungs_ag_20231101 >									
	//        < euTudj1EcvT4KOnpOYK48G6fka2gONHr241CoHJ36wqlTTxU3V4qw000S2gTR7LF >									
	//        <  u =="0.000000000000000001" : ] 000000198615525.335799000000000000 ; 000000232198190.987012000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012F10311624E6B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIV_II_metadata_line_11_____gerling_konzern globale rückversicherungs_ag_20231101 >									
	//        < YIbsTWnY16e74AFafWkmJBQfchs3U1Qs4gt3SK77Pu46zhi4B72C04JuD2EHw2Wu >									
	//        <  u =="0.000000000000000001" : ] 000000232198190.987012000000000000 ; 000000249366956.148127000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001624E6B17C80F8 >									
	//     < NDRV_PFIV_II_metadata_line_12_____gerling gfp verwaltungs_ag_20231101 >									
	//        < 6DUU11dYqKsaObMY4g7SV297C9n68Jt38ye26WxNJMm1Nx92i5s5tzH6C17CLJYq >									
	//        <  u =="0.000000000000000001" : ] 000000249366956.148127000000000000 ; 000000286578401.637402000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017C80F81B548B0 >									
	//     < NDRV_PFIV_II_metadata_line_13_____hdi kundenservice ag_20231101 >									
	//        < HE5P48D91NlpJuxk1lk7aHfrVBzpKdRgGDgn9SUWmL4YO9WJtHB9mECWtN6g2az5 >									
	//        <  u =="0.000000000000000001" : ] 000000286578401.637402000000000000 ; 000000307731514.082813000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B548B01D58F9F >									
	//     < NDRV_PFIV_II_metadata_line_14_____beteiligungs gmbh co kg_20231101 >									
	//        < 3a7ASF324Um67HXiiiULjQj8PAtTaFTtm0J4b8nD86eRL39u4jE162HKX635X9ha >									
	//        <  u =="0.000000000000000001" : ] 000000307731514.082813000000000000 ; 000000333260523.924776000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D58F9F1FC83E4 >									
	//     < NDRV_PFIV_II_metadata_line_15_____talanx reinsurance broker gmbh_20231101 >									
	//        < 02804hI3nW7oP1BSq9NJy1Y76cE83CNOgZt96jdql2lyXGf14Sa69D16Yk8NG2Kb >									
	//        <  u =="0.000000000000000001" : ] 000000333260523.924776000000000000 ; 000000350458500.884943000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FC83E4216C1DA >									
	//     < NDRV_PFIV_II_metadata_line_16_____neue leben holding ag_20231101 >									
	//        < 99eE129OqwS5540qU9NYDczLYQvWx5Lj4Y2zhp7Y6mtZtAd0JCq9GWH9O24hKq1z >									
	//        <  u =="0.000000000000000001" : ] 000000350458500.884943000000000000 ; 000000367853869.184471000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000216C1DA2314CEB >									
	//     < NDRV_PFIV_II_metadata_line_17_____neue leben unfallversicherung ag_20231101 >									
	//        < 47V1ZiXFpK6UrEAPP2ASR5DIY5F6v1vwyBbjXECcSp57oQyK86X99lExwbweiB0a >									
	//        <  u =="0.000000000000000001" : ] 000000367853869.184471000000000000 ; 000000387033416.357964000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002314CEB24E90EE >									
	//     < NDRV_PFIV_II_metadata_line_18_____neue leben lebensversicherung ag_20231101 >									
	//        < BdK78ez8IedJl1J0alftddO007lKuRpw6w71066m2sUvMtgivup8k83O9oH8Dtny >									
	//        <  u =="0.000000000000000001" : ] 000000387033416.357964000000000000 ; 000000410814343.331630000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024E90EE272DA5A >									
	//     < NDRV_PFIV_II_metadata_line_19_____pb versicherung ag_20231101 >									
	//        < 69aFYnykZkb5HxTUB8y9iDoI74BoLwWUCYujt0I3HuHIucGI00QD7r54J621HS2G >									
	//        <  u =="0.000000000000000001" : ] 000000410814343.331630000000000000 ; 000000451935705.547642000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000272DA5A2B19963 >									
	//     < NDRV_PFIV_II_metadata_line_20_____talanx systeme ag_20231101 >									
	//        < 00mOA4K8C5mb3fw875Byu8dCEPsOIg3QE4v7mFeOPo5w9E2XROoi7NEO7VwvwEjt >									
	//        <  u =="0.000000000000000001" : ] 000000451935705.547642000000000000 ; 000000491134794.154304000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B199632ED6987 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIV_II_metadata_line_21_____hdi seguros sa_20231101 >									
	//        < zn14rNbYHb70O5X7R716Rj5BLG141kxyKVgX0Q1F5MMkFReqFG0D5kuJ0XZ1e23z >									
	//        <  u =="0.000000000000000001" : ] 000000491134794.154304000000000000 ; 000000526272633.116627000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002ED6987323073F >									
	//     < NDRV_PFIV_II_metadata_line_22_____talanx nassau assekuranzkontor gmbh_20231101 >									
	//        < C5mkNQ6YcY745d5Bo0LfHW18a29g1K78Q9x1fewzdHZq65u83icDOS6J03Eu57PR >									
	//        <  u =="0.000000000000000001" : ] 000000526272633.116627000000000000 ; 000000567621293.327726000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000323073F3621F11 >									
	//     < NDRV_PFIV_II_metadata_line_23_____td real assets gmbh co kg_20231101 >									
	//        < yL2K4K68n030h20HUTbmD6ic975HQ39oB15dFCQZ17qxVyTfl09mmcHjgP7I9Rq7 >									
	//        <  u =="0.000000000000000001" : ] 000000567621293.327726000000000000 ; 000000616626668.271404000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003621F113ACE5CB >									
	//     < NDRV_PFIV_II_metadata_line_24_____partner office ag_20231101 >									
	//        < LYJNMqoj9e9dVFI03KVO724oINn9u3764s8gg0rDwW7T1Tc0MJZ26sQ2KpO0CL9c >									
	//        <  u =="0.000000000000000001" : ] 000000616626668.271404000000000000 ; 000000654310705.626700000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003ACE5CB3E6661F >									
	//     < NDRV_PFIV_II_metadata_line_25_____hgi alternative investments beteiligungs_gmbh co kg_20231101 >									
	//        < QYeTE8ZyHOdN7y783x1tyYkF5aG050rbK2HG9DSaK70596kLZ1426u6qrq7gL2RT >									
	//        <  u =="0.000000000000000001" : ] 000000654310705.626700000000000000 ; 000000697796826.862476000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E6661F428C0E3 >									
	//     < NDRV_PFIV_II_metadata_line_26_____ferme eolienne du mignaudières sarl_20231101 >									
	//        < SXG7DO1YUb2vi7UvUZNJaYgVj2L7jAuQHzqEnoSF5E6ySX29202rpIRCgyg59O29 >									
	//        <  u =="0.000000000000000001" : ] 000000697796826.862476000000000000 ; 000000737363626.189272000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000428C0E346520AB >									
	//     < NDRV_PFIV_II_metadata_line_27_____talanx ag asset management arm_20231101 >									
	//        < 16ad8h1K9ekgkF8ytF6YS151832aVAF08GnhVd4lWza78PJe9Vxc4MOlx52TxkK8 >									
	//        <  u =="0.000000000000000001" : ] 000000737363626.189272000000000000 ; 000000775591313.969623000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046520AB49F755B >									
	//     < NDRV_PFIV_II_metadata_line_28_____talanx bureau für versicherungswesen robert gerling & co gmbh_20231101 >									
	//        < A00VX3zUld1cdTb1D9kD7x9ei25h4gQBRe8V83faUZkSv67Kt59Xy7pCz3LS75UU >									
	//        <  u =="0.000000000000000001" : ] 000000775591313.969623000000000000 ; 000000799681332.223189000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049F755B4C43785 >									
	//     < NDRV_PFIV_II_metadata_line_29_____pb pensionskasse aktiengesellschaft_20231101 >									
	//        < 87WQbw4g1jH05JYF9p8j8E6WnEdsJa1V28KlXQ3gjy576tTHXdQKMDr1Kpl095P3 >									
	//        <  u =="0.000000000000000001" : ] 000000799681332.223189000000000000 ; 000000817982908.570690000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C437854E02493 >									
	//     < NDRV_PFIV_II_metadata_line_30_____hdi direkt service gmbh_20231101 >									
	//        < fvK6mc8xF1HTTYW7ORtyxn19UhGyEoZA0KF1877o1hK2ifbL865D1kq1VguvkfN2 >									
	//        <  u =="0.000000000000000001" : ] 000000817982908.570690000000000000 ; 000000859483055.272588000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E0249351F7792 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIV_II_metadata_line_31_____gerling immo spezial 1_20231101 >									
	//        < Y5mZJE7dDaCw3oW1X3UqLkU4a3h8b2Oc60XGg604u7q988zH250IF6KrtUOwvj28 >									
	//        <  u =="0.000000000000000001" : ] 000000859483055.272588000000000000 ; 000000903600099.342691000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000051F7792562C8CA >									
	//     < NDRV_PFIV_II_metadata_line_32_____gente compania de soluciones profesionales de mexico sa de cv_20231101 >									
	//        < a7391Qd9qgoSN311oUPEpah49jBeJdjgPrAq7845OS16RoHQuod0bE69C703eO6H >									
	//        <  u =="0.000000000000000001" : ] 000000903600099.342691000000000000 ; 000000922120638.987508000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000562C8CA57F0B60 >									
	//     < NDRV_PFIV_II_metadata_line_33_____credit life international versicherung ag_20231101 >									
	//        < Bt1dZAc3jq4EEhqxhW7eH2Kju1dwRUG0sDoL7qWfYaO2zdQ53D54c3ih26b90O9A >									
	//        <  u =="0.000000000000000001" : ] 000000922120638.987508000000000000 ; 000000962579489.604980000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057F0B605BCC79D >									
	//     < NDRV_PFIV_II_metadata_line_34_____talanx pensionsmanagement ag_20231101 >									
	//        < RatG5L2w4ij8y3ft2N4X49e91k6HpamKeQE7u6dxKJ9aNWwDzF29Eg4F9tHcFVgf >									
	//        <  u =="0.000000000000000001" : ] 000000962579489.604980000000000000 ; 000001003244995.469020000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005BCC79D5FAD494 >									
	//     < NDRV_PFIV_II_metadata_line_35_____talanx infrastructure portugal 2 gmbh_20231101 >									
	//        < 6yAJGcYzQyZ2XeHgj1M2B50id5nASh45w4pKXo9Enc0FmYi85EJ9YW4UKEj356NH >									
	//        <  u =="0.000000000000000001" : ] 000001003244995.469020000000000000 ; 000001019272553.505380000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005FAD4946134957 >									
	//     < NDRV_PFIV_II_metadata_line_36_____pnh parque do novo hospital sa_20231101 >									
	//        < 0cpCshwjRI3q71sd220k97irkbKSGk1UiUSBWPgjOR5H5hm9H9kpk4M9R9Nuvo7r >									
	//        <  u =="0.000000000000000001" : ] 000001019272553.505380000000000000 ; 000001049565612.177240000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000061349576418291 >									
	//     < NDRV_PFIV_II_metadata_line_37_____aberdeen infrastructure holdco bv_20231101 >									
	//        < 6f6q8l9OQyLe2ccE96Tjokof6Y5fR2Wf3dIqp8N1doqhI8HcJHzvW5LNg0F92V9z >									
	//        <  u =="0.000000000000000001" : ] 000001049565612.177240000000000000 ; 000001089654079.232160000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000641829167EAE20 >									
	//     < NDRV_PFIV_II_metadata_line_38_____escala vila franca sociedade gestora do edifício sa_20231101 >									
	//        < sW7NPnT3mI5IwH7xcDKP4kpVtAFVW9qz1jAImM2vWM555om8932U2O5j5Y02OOcZ >									
	//        <  u =="0.000000000000000001" : ] 000001089654079.232160000000000000 ; 000001126750535.712960000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000067EAE206B748EE >									
	//     < NDRV_PFIV_II_metadata_line_39_____pnh parque do novo hospital sa_20231101 >									
	//        < WgIJX1lofMWbvbF4M38o8S7lD1q4vO62Mr7KC4B6x17sGGVZO4lYy721VofghB90 >									
	//        <  u =="0.000000000000000001" : ] 000001126750535.712960000000000000 ; 000001145439933.884130000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006B748EE6D3CD79 >									
	//     < NDRV_PFIV_II_metadata_line_40_____tunz warta sa_20231101 >									
	//        < B3g0n1n1ZR8d175UPZ1r6zORB1WK4w99Yq767hh73OVrzc2zD65bH7N0kz7QJ58m >									
	//        <  u =="0.000000000000000001" : ] 000001145439933.884130000000000000 ; 000001173533492.794600000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006D3CD796FEAB85 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}