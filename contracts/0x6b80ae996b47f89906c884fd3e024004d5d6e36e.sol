pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXIX_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXIX_II_883		"	;
		string	public		symbol =	"	RUSS_PFXIX_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		799779819675914000000000000					;	
										
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
	//     < RUSS_PFXIX_II_metadata_line_1_____Eurochem_20231101 >									
	//        < 6G2jon10G9oGCw2qdFSqST3rT41O6TZ26xg8IqXdt4h1WNKA88ERNhI2emuqB7Ef >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000016248074.394150700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000018CAE7 >									
	//     < RUSS_PFXIX_II_metadata_line_2_____Eurochem_Group_AG_Switzerland_20231101 >									
	//        < C0icXx9hf4i9h9rDW94kMUHFRfad7vRRHtQmNHnUCQfdGEdekxEihA1n5cv3zT5V >									
	//        <  u =="0.000000000000000001" : ] 000000016248074.394150700000000000 ; 000000035666879.126349700000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000018CAE7366C60 >									
	//     < RUSS_PFXIX_II_metadata_line_3_____Industrial _Group_Phosphorite_20231101 >									
	//        < owZE82wXDUfwO8kO00s55JqLYXN83ewUSHl1283P18sXJTf9O73J6zEosLB8mQ51 >									
	//        <  u =="0.000000000000000001" : ] 000000035666879.126349700000000000 ; 000000057186104.114267400000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000366C60574252 >									
	//     < RUSS_PFXIX_II_metadata_line_4_____Novomoskovsky_Azot_20231101 >									
	//        < 0TxxD1EsKIWn4OeKqR6n9OxRe9dNoDER452rX5x2XyeebS0BLGexhmiPQL3Wm6u4 >									
	//        <  u =="0.000000000000000001" : ] 000000057186104.114267400000000000 ; 000000080321377.937928200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005742527A8F8A >									
	//     < RUSS_PFXIX_II_metadata_line_5_____Novomoskovsky_Chlor_20231101 >									
	//        < Tg6qVZsnfYSN3vGBUDDsfAdk0U4nlS09smI8pzI3Kq0X6PI5ru91Z2bp8v58ky0F >									
	//        <  u =="0.000000000000000001" : ] 000000080321377.937928200000000000 ; 000000095780241.047186100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007A8F8A922628 >									
	//     < RUSS_PFXIX_II_metadata_line_6_____Nevinnomyssky_Azot_20231101 >									
	//        < 6XhHW9wtP62s043i5j2U74Ly64OZOR844zvc2Yn4sPvUP5970Pq1t208Z4Rs9TCA >									
	//        <  u =="0.000000000000000001" : ] 000000095780241.047186100000000000 ; 000000117539260.467352000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000922628B359C6 >									
	//     < RUSS_PFXIX_II_metadata_line_7_____EuroChem_Belorechenskie_Minudobrenia_20231101 >									
	//        < 5Y2rMAstbHh1nB1imi78DZ1Nim55d45q8Af06Kx65Wg5e7b2UtLlDaX0LSlm27Sf >									
	//        <  u =="0.000000000000000001" : ] 000000117539260.467352000000000000 ; 000000137405765.512090000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B359C6D1AA21 >									
	//     < RUSS_PFXIX_II_metadata_line_8_____Kovdorsky_GOK_20231101 >									
	//        < 7zXQq9VK2McpY26d02Pl28wF75E0O15tbs6fEA8Y9TR6g3Kl6Ul5GlU1RROod6jP >									
	//        <  u =="0.000000000000000001" : ] 000000137405765.512090000000000000 ; 000000155365259.022083000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D1AA21ED118E >									
	//     < RUSS_PFXIX_II_metadata_line_9_____Lifosa_AB_20231101 >									
	//        < VaH5U3EteLbVN0fSLoe2Wff28G7RjJzdoucO5UixpuJuRNu97GT4US8h7YxoNm4h >									
	//        <  u =="0.000000000000000001" : ] 000000155365259.022083000000000000 ; 000000176791300.173900000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000ED118E10DC31A >									
	//     < RUSS_PFXIX_II_metadata_line_10_____EuroChem_Antwerpen_NV_20231101 >									
	//        < HMHPC86rsa1rkPW58jW1s74F7OffPQyDru53WJO9Tv8E8woHR2BA8xca74DfUOj9 >									
	//        <  u =="0.000000000000000001" : ] 000000176791300.173900000000000000 ; 000000198147914.615496000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010DC31A12E5987 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIX_II_metadata_line_11_____EuroChem_VolgaKaliy_20231101 >									
	//        < lLAWsJZsPqcriuz15n0fxCi47WcSFGrkzBjVG3rn1hfntcmryw655J7ispqg0By9 >									
	//        <  u =="0.000000000000000001" : ] 000000198147914.615496000000000000 ; 000000218025475.319694000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012E598714CAE34 >									
	//     < RUSS_PFXIX_II_metadata_line_12_____EuroChem_Usolsky_potash_complex_20231101 >									
	//        < 76mDO3O6BXLOt9oMEg9Ue8ApmM9fLHEICt60fyXe8hjaxpW6yv1M3KCUcV03rMIU >									
	//        <  u =="0.000000000000000001" : ] 000000218025475.319694000000000000 ; 000000238162016.009803000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014CAE3416B680A >									
	//     < RUSS_PFXIX_II_metadata_line_13_____EuroChem_ONGK_20231101 >									
	//        < yRBFYH32izFt87pW9n4NdihetQMXf67W34uR589ZYFLvkGH7U60IJ6y264RyjV1M >									
	//        <  u =="0.000000000000000001" : ] 000000238162016.009803000000000000 ; 000000258529806.500169000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016B680A18A7C35 >									
	//     < RUSS_PFXIX_II_metadata_line_14_____EuroChem_Northwest_20231101 >									
	//        < 1102C53YzXlo3XVDVks6SPNuk2y7cG4a3z35b16SLuLpbKv7B0uL1vl3nPEVUon6 >									
	//        <  u =="0.000000000000000001" : ] 000000258529806.500169000000000000 ; 000000276074391.399132000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018A7C351A5418F >									
	//     < RUSS_PFXIX_II_metadata_line_15_____EuroChem_Fertilizers_20231101 >									
	//        < M4n8261vqS5FN1TyOZRrl80957sq2nY5Tl7DikQzNLx9KNaRvow923YBpR9N0Pe0 >									
	//        <  u =="0.000000000000000001" : ] 000000276074391.399132000000000000 ; 000000300736000.701019000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A5418F1CAE300 >									
	//     < RUSS_PFXIX_II_metadata_line_16_____Astrakhan_Oil_and_Gas_Company_20231101 >									
	//        < 51Y8Jfd1Oca9h3sGb6p8K38p5d5C2f22ePbtg672b01k50g9WzNGiFrXQl1QjIZZ >									
	//        <  u =="0.000000000000000001" : ] 000000300736000.701019000000000000 ; 000000321990400.596184000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CAE3001EB5180 >									
	//     < RUSS_PFXIX_II_metadata_line_17_____Sary_Tas_Fertilizers_20231101 >									
	//        < OjV8dypG9A01lx1CWBZpl203J455InzNlGaSu89s21z5TTQ0p3o98cKAci018eQE >									
	//        <  u =="0.000000000000000001" : ] 000000321990400.596184000000000000 ; 000000343065524.779996000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EB518020B79F8 >									
	//     < RUSS_PFXIX_II_metadata_line_18_____EuroChem_Karatau_20231101 >									
	//        < 9nT3c195f2eta34KTD30iUa77RS02e1J2PMEir8gk7949EnU6619w7G373Ypubvn >									
	//        <  u =="0.000000000000000001" : ] 000000343065524.779996000000000000 ; 000000361932830.643408000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020B79F82284403 >									
	//     < RUSS_PFXIX_II_metadata_line_19_____Kamenkovskaya_Oil_Gas_Company_20231101 >									
	//        < VAyg6imJUStpGQ2RjD9P23qA3iTJ5Rw60JW8kAl12N8MK52O31sP7lKViHs3Uo75 >									
	//        <  u =="0.000000000000000001" : ] 000000361932830.643408000000000000 ; 000000385461474.438773000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000228440324C2AE3 >									
	//     < RUSS_PFXIX_II_metadata_line_20_____EuroChem_Trading_GmbH_Trading_20231101 >									
	//        < Yv2M1YY3U5inMqp87Vhf67mMVdjF3laTd8Ss2WpGl9mu6dVfY54EoMc8f1CE66a3 >									
	//        <  u =="0.000000000000000001" : ] 000000385461474.438773000000000000 ; 000000408196116.472465000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024C2AE326EDB9C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIX_II_metadata_line_21_____EuroChem_Trading_USA_Corp_20231101 >									
	//        < 423PhRNkQGqaCFgDbKr2K24BOG0J6nc2bn1A353Bs83c2twAr67novV0m0JpSgTu >									
	//        <  u =="0.000000000000000001" : ] 000000408196116.472465000000000000 ; 000000424064809.736016000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000026EDB9C2871251 >									
	//     < RUSS_PFXIX_II_metadata_line_22_____Ben_Trei_Ltd_20231101 >									
	//        < 849qWSDXrSN99XM9n6b54dzkOujo5C94CNSmxTpvKHWJ1x4T3YsGBy1QEG426X6L >									
	//        <  u =="0.000000000000000001" : ] 000000424064809.736016000000000000 ; 000000445001255.768114000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028712512A7049E >									
	//     < RUSS_PFXIX_II_metadata_line_23_____EuroChem_Agro_SAS_20231101 >									
	//        < AgGABcb34zvBjQW0iZgsFAw8tAaLoHKxq6W5Wg93qmkvQZ4QNrg7gN10Ip3jGDF6 >									
	//        <  u =="0.000000000000000001" : ] 000000445001255.768114000000000000 ; 000000466634960.934564000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A7049E2C80748 >									
	//     < RUSS_PFXIX_II_metadata_line_24_____EuroChem_Agro_Asia_20231101 >									
	//        < uQElR5VYs0sbojPBhB3tCnDoMmg1Sfi8qIi8F2dv8ZNK3jDT7t8A688LF14ZLt9j >									
	//        <  u =="0.000000000000000001" : ] 000000466634960.934564000000000000 ; 000000487746551.806516000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002C807482E83DFF >									
	//     < RUSS_PFXIX_II_metadata_line_25_____EuroChem_Agro_Iberia_20231101 >									
	//        < JH23rpVyAlR1BQ476O2k2143kA4Q3R1knVC0s7bGQfZuJ1rYQ2n4dJ6TF62XQ6hq >									
	//        <  u =="0.000000000000000001" : ] 000000487746551.806516000000000000 ; 000000507029406.793290000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E83DFF305AA5D >									
	//     < RUSS_PFXIX_II_metadata_line_26_____EuroChem_Agricultural_Trading_Hellas_20231101 >									
	//        < UIY5A233kvN0kFvpMkhYguds8sNpHzTCIvi0tC1aIa86NTpd89v6j27tR728crvo >									
	//        <  u =="0.000000000000000001" : ] 000000507029406.793290000000000000 ; 000000527188154.930884000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000305AA5D3246CDF >									
	//     < RUSS_PFXIX_II_metadata_line_27_____EuroChem_Agro_Spa_20231101 >									
	//        < 8KH45555TGK6ZBi2Zj3QTgC1pCRMNy5sb17CV9C6g04KZov5ajh3cBlmhUbfMM46 >									
	//        <  u =="0.000000000000000001" : ] 000000527188154.930884000000000000 ; 000000546272286.535815000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003246CDF3418B9D >									
	//     < RUSS_PFXIX_II_metadata_line_28_____EuroChem_Agro_GmbH_20231101 >									
	//        < jbATacuB0io59CHIT8CGfYUpQt4c3ecGZ49QJ5EP9Unx13h6YnC89469Y3Y5ik6z >									
	//        <  u =="0.000000000000000001" : ] 000000546272286.535815000000000000 ; 000000564111631.346470000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003418B9D35CC41B >									
	//     < RUSS_PFXIX_II_metadata_line_29_____EuroChem_Agro_México_SA_20231101 >									
	//        < kAKjh686J6FUEY1vrOmI4v5CdM48292KNo9FSlwwMVUO7EsJyapfxQCit7hoF1rv >									
	//        <  u =="0.000000000000000001" : ] 000000564111631.346470000000000000 ; 000000587514980.495516000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035CC41B3807A0A >									
	//     < RUSS_PFXIX_II_metadata_line_30_____EuroChem_Agro_Hungary_Kft_20231101 >									
	//        < 1lFz5LardO06WIS61cdT69IPs4ub6mo0NxH0Y4yRGEMv0Cu6G5399GfC8tSJ8O5p >									
	//        <  u =="0.000000000000000001" : ] 000000587514980.495516000000000000 ; 000000607821351.880292000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003807A0A39F7637 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXIX_II_metadata_line_31_____Agrocenter_EuroChem_Srl_20231101 >									
	//        < wt541lnrNejtd9IrwA9xxXbBU1y6k9n2PuVqQqnygK6FwQgG9ggAH8pfwy8BkSX6 >									
	//        <  u =="0.000000000000000001" : ] 000000607821351.880292000000000000 ; 000000623707193.031572000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039F76373B7B39F >									
	//     < RUSS_PFXIX_II_metadata_line_32_____EuroChem_Agro_Bulgaria_Ead_20231101 >									
	//        < 4464uL8YkhBZfS3w78119c3aSpl7j9Ns9egHn0ai79Nt0z350ByAGL4L2UddU19P >									
	//        <  u =="0.000000000000000001" : ] 000000623707193.031572000000000000 ; 000000641099691.584319000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B7B39F3D23D91 >									
	//     < RUSS_PFXIX_II_metadata_line_33_____EuroChem_Agro_doo_Beograd_20231101 >									
	//        < 596PM8ocJy7at35b9K91ShRo1d1xmxC93quDRxe8311bnXE5jfLq3Y3KV9SHT80v >									
	//        <  u =="0.000000000000000001" : ] 000000641099691.584319000000000000 ; 000000664745715.337665000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D23D913F6524C >									
	//     < RUSS_PFXIX_II_metadata_line_34_____EuroChem_Agro_Turkey_Tarim_Sanayi_ve_Ticaret_20231101 >									
	//        < 4o47EW0gw9ui4yT4zKnl983izugr6NkoMrv43JMIrfc18YqjTMFy4HCheVltk3Fs >									
	//        <  u =="0.000000000000000001" : ] 000000664745715.337665000000000000 ; 000000681978110.694123000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F6524C4109DB3 >									
	//     < RUSS_PFXIX_II_metadata_line_35_____Emerger_Fertilizantes_SA_20231101 >									
	//        < YTu279L6QE11045GJHrx8qpDZH4j5cRP1LT3Jyq99Zm3yc6deJlh407My8vbD17m >									
	//        <  u =="0.000000000000000001" : ] 000000681978110.694123000000000000 ; 000000700649850.842244000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004109DB342D1B59 >									
	//     < RUSS_PFXIX_II_metadata_line_36_____EuroChem_Comercio_Produtos_Quimicos_20231101 >									
	//        < 6ifwB4D0KcyGGSo872acpkCS7dwKRkCiq9O0rv64FwFycMOsO1K9YiGzr85kS64t >									
	//        <  u =="0.000000000000000001" : ] 000000700649850.842244000000000000 ; 000000720782307.704790000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000042D1B5944BD397 >									
	//     < RUSS_PFXIX_II_metadata_line_37_____Fertilizantes_Tocantines_Ltda_20231101 >									
	//        < AMQC7AI37Mi7yZky1obb6i24965bszx8Eq2204Vv12vDEZ6842O9Zj9U3zW3DSJn >									
	//        <  u =="0.000000000000000001" : ] 000000720782307.704790000000000000 ; 000000739987346.518404000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044BD397469218F >									
	//     < RUSS_PFXIX_II_metadata_line_38_____EuroChem_Agro_Trading_Shenzhen_20231101 >									
	//        < QdoRnxDif1yK3pk9jY3LjTr6O9k9vT0J5enwU90E5HqWnnkC60489HFLHlgEY0Ba >									
	//        <  u =="0.000000000000000001" : ] 000000739987346.518404000000000000 ; 000000759546008.317442000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000469218F486F9A9 >									
	//     < RUSS_PFXIX_II_metadata_line_39_____EuroChem_Trading_RUS_20231101 >									
	//        < r7nd5CQguaz83223bb83dBw8X7s7jH3F62av6Y0g91u489qCtI9q2GSr552FhYyD >									
	//        <  u =="0.000000000000000001" : ] 000000759546008.317442000000000000 ; 000000783554558.284806000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000486F9A94AB9C00 >									
	//     < RUSS_PFXIX_II_metadata_line_40_____AgroCenter_EuroChem_Ukraine_20231101 >									
	//        < EXnd8uy31vds7644Ah770Oi08SWyfIYb0bw8urn1u1YEP1JVX8MKSLuLfB7oTffa >									
	//        <  u =="0.000000000000000001" : ] 000000783554558.284806000000000000 ; 000000799779819.675914000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004AB9C004C45DFE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}