pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFV_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFV_I_883		"	;
		string	public		symbol =	"	NDRV_PFV_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		778406367995349000000000000					;	
										
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
	//     < NDRV_PFV_I_metadata_line_1_____talanx primary insurance group_20211101 >									
	//        < szg21bFPjJHj807bN05h16G9S9Hr8Ci7w9Ruo76110A0bKH88yFLpS5H41bwZpLO >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000019280758.870092100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000001D6B8C >									
	//     < NDRV_PFV_I_metadata_line_2_____primary_pensions_20211101 >									
	//        < UpUG78dUA0I9z0I37BgxeEm0h47igd48D2Ks9DlJ1iZ983L9upaV6FZ3xsGN8LVL >									
	//        <  u =="0.000000000000000001" : ] 000000019280758.870092100000000000 ; 000000033892468.512457000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001D6B8C33B73F >									
	//     < NDRV_PFV_I_metadata_line_3_____hdi rechtsschutz ag_20211101 >									
	//        < VYJ8mu47xRzQy10b6ElBW8WFXu2b7er498PBm5mFYwK77XrO4ZR181BYgyPElF02 >									
	//        <  u =="0.000000000000000001" : ] 000000033892468.512457000000000000 ; 000000058686072.171197900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000033B73F598C3F >									
	//     < NDRV_PFV_I_metadata_line_4_____Gerling Insurance Of South Africa Ltd_20211101 >									
	//        < fBv41z57uup1q2vk8IV46qrk3Wguts1cN7l5Fd0BaJigq33v1C56L37p11yCPN33 >									
	//        <  u =="0.000000000000000001" : ] 000000058686072.171197900000000000 ; 000000072925809.192684400000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000598C3F6F46A5 >									
	//     < NDRV_PFV_I_metadata_line_5_____Gerling Global Life Sweden Reinsurance Co LTd_20211101 >									
	//        < Zh2KANkmRc4oW1JlK1GruX386k60b4TfC16Af92G2aU4P19KiW8m5IEvfbhQ2oyf >									
	//        <  u =="0.000000000000000001" : ] 000000072925809.192684400000000000 ; 000000093671680.938182000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006F46A58EEE80 >									
	//     < NDRV_PFV_I_metadata_line_6_____Amtrust Corporate Member Ltd_20211101 >									
	//        < O5E1y1y9fl2G4pyxXLaENgU5f9l2sv091aX22a2lR3v582CPd5EPy28r8Eh2q75I >									
	//        <  u =="0.000000000000000001" : ] 000000093671680.938182000000000000 ; 000000113103886.955503000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008EEE80AC9535 >									
	//     < NDRV_PFV_I_metadata_line_7_____HDI_Gerling Australia Insurance Company Pty Ltd_20211101 >									
	//        < RsDVxW3kM2515o6vJzipR1DueCwQY60367V0WztMKJtvlVW6emomKFSC8IYbkMV8 >									
	//        <  u =="0.000000000000000001" : ] 000000113103886.955503000000000000 ; 000000131928585.030085000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000AC9535C94E9B >									
	//     < NDRV_PFV_I_metadata_line_8_____Gerling Institut GIBA_20211101 >									
	//        < hH0fIN0Ft7upqYq0Psn0ZTbXxQZFZWThw6oDhFi1A91X5Hwi05t86FQFSnTPWgo1 >									
	//        <  u =="0.000000000000000001" : ] 000000131928585.030085000000000000 ; 000000147608772.229534000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C94E9BE13BAD >									
	//     < NDRV_PFV_I_metadata_line_9_____Gerling_org_20211101 >									
	//        < Zmps3h5Pv9l3KF9f1nQ4eBgGurm8mVfLpInriCDe00doAxoF53BV1oC67uw40LjJ >									
	//        <  u =="0.000000000000000001" : ] 000000147608772.229534000000000000 ; 000000162499691.375182000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E13BADF7F471 >									
	//     < NDRV_PFV_I_metadata_line_10_____Gerling_Holdings_20211101 >									
	//        < 2yDg47Ax94GK27fgFZ9oe7Cj24fZ22sq0aUY211Z2TNmPe6920nO8OH1dVg7sbmV >									
	//        <  u =="0.000000000000000001" : ] 000000162499691.375182000000000000 ; 000000184406864.599291000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F7F47111961EE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFV_I_metadata_line_11_____Gerling_Pensions_20211101 >									
	//        < o163e6UCCtbWhUc1xDxeYUJu541NKJOhubiM543t85P5H09EW90LJzsDNhh62hiR >									
	//        <  u =="0.000000000000000001" : ] 000000184406864.599291000000000000 ; 000000205545745.572422000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011961EE139A34F >									
	//     < NDRV_PFV_I_metadata_line_12_____talanx international ag_20211101 >									
	//        < jw4p6g4718sPmh644oPfSTNebO74L9531HqYjH825U21uE3gJ6xbdY8ACY29V3RJ >									
	//        <  u =="0.000000000000000001" : ] 000000205545745.572422000000000000 ; 000000219199270.568060000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000139A34F14E78B7 >									
	//     < NDRV_PFV_I_metadata_line_13_____tuir warta_20211101 >									
	//        < 2804JlXz0EiQ6N7lO0IA5Csy6sQQ6HfEgkxx8ug06tIX3fZPu1I29J3RTgAkFS1e >									
	//        <  u =="0.000000000000000001" : ] 000000219199270.568060000000000000 ; 000000240203978.286558000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014E78B716E85AE >									
	//     < NDRV_PFV_I_metadata_line_14_____tuir warta_org_20211101 >									
	//        < QF9Ktj9E7uKpfPl0q86H619KE590879Ig65J59Fvi7k14RHiwI06hg4aa4eUuh9r >									
	//        <  u =="0.000000000000000001" : ] 000000240203978.286558000000000000 ; 000000261787205.201498000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016E85AE18F74A1 >									
	//     < NDRV_PFV_I_metadata_line_15_____towarzystwo ubezpieczen na zycie warta sa_20211101 >									
	//        < wy3i4916Jy8Ayh0LTPdO6f95vr059wKknLcmnC60j4111O8IY3K79Q00GMzBxvwC >									
	//        <  u =="0.000000000000000001" : ] 000000261787205.201498000000000000 ; 000000279987511.546812000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018F74A11AB3A1F >									
	//     < NDRV_PFV_I_metadata_line_16_____HDI-Gerling Zycie Towarzystwo Ubezpieczen Spolka Akcyjna_20211101 >									
	//        < 8jZ4z5KrYaD0KHDlrj3190s6vb4TYUsee4L5xG3Mtg94uXu9HEKpFIJvTXiYtiX5 >									
	//        <  u =="0.000000000000000001" : ] 000000279987511.546812000000000000 ; 000000297244812.980823000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AB3A1F1C58F41 >									
	//     < NDRV_PFV_I_metadata_line_17_____TUiR Warta SA Asset Management Arm_20211101 >									
	//        < o1cHS9PJSvRDPqQVN1kLmrW42SkU9t66ij7T6MCO74YFKGwKKw02IMCOcNL86uqS >									
	//        <  u =="0.000000000000000001" : ] 000000297244812.980823000000000000 ; 000000318312878.149813000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C58F411E5B4F8 >									
	//     < NDRV_PFV_I_metadata_line_18_____HDI Seguros SA de CV_20211101 >									
	//        < m6h4kK0FKUze4vG2nR4rAb7rYQYIlnjwsQEvd7957VPggSNivFCOCR5OOrBP854j >									
	//        <  u =="0.000000000000000001" : ] 000000318312878.149813000000000000 ; 000000333736520.310988000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E5B4F81FD3DD4 >									
	//     < NDRV_PFV_I_metadata_line_19_____Towarzystwo Ubezpieczen Europa SA_20211101 >									
	//        < zyoR25xOVP95tvhHAhHe5mI1FSPyALn067CSBmoN4tKqxtyU49bp1N0gzF62C954 >									
	//        <  u =="0.000000000000000001" : ] 000000333736520.310988000000000000 ; 000000356380760.240166000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FD3DD421FCB3C >									
	//     < NDRV_PFV_I_metadata_line_20_____Towarzystwo Ubezpieczen Na Zycie EUROPA SA_20211101 >									
	//        < cAuVZLI56rRYcOO0nHC7BCJHnxi2BrKQ95It8k9476ujzO9Vl99SzWCWWbBd3bB8 >									
	//        <  u =="0.000000000000000001" : ] 000000356380760.240166000000000000 ; 000000372690174.897284000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021FCB3C238AE19 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFV_I_metadata_line_21_____TU na ycie EUROPA SA_20211101 >									
	//        < 5294ETmUiS21r3S5Mw6su42Fm33oV7Rr4G1qk61r4f2TqC31c8cXg2LT0a2pFw64 >									
	//        <  u =="0.000000000000000001" : ] 000000372690174.897284000000000000 ; 000000387690222.363416000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000238AE1924F917E >									
	//     < NDRV_PFV_I_metadata_line_22_____Liberty Sigorta_20211101 >									
	//        < RkcTyhp8957P5nFky422WCpy61UqZfQWy0BYZ37MVbp69d8n2uPhoUT82F4aiRF6 >									
	//        <  u =="0.000000000000000001" : ] 000000387690222.363416000000000000 ; 000000409192406.281464000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024F917E27060C9 >									
	//     < NDRV_PFV_I_metadata_line_23_____Aspecta Versicherung Ag_20211101 >									
	//        < lW43KjaGy81XRoo64mE4DshpGT47q4vdKbKvyB9ZJE1g45Ab55S4D6whnIxs3kC3 >									
	//        <  u =="0.000000000000000001" : ] 000000409192406.281464000000000000 ; 000000434861835.411060000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027060C92978BE8 >									
	//     < NDRV_PFV_I_metadata_line_24_____HDI Sigorta AS_20211101 >									
	//        < bS9CjlekG3WG3n1C69r7QIf9P19d7o041jUKTW0wBbX92J3Zh2wYloJmzM78N8K2 >									
	//        <  u =="0.000000000000000001" : ] 000000434861835.411060000000000000 ; 000000450201362.261506000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002978BE82AEF3E8 >									
	//     < NDRV_PFV_I_metadata_line_25_____HDI Seguros SA_20211101 >									
	//        < 7yoFM5hA94W4gmOwqUzbrEdtl92520Gi991j1CFj9f1i7xliPRS3caEg21af4AV8 >									
	//        <  u =="0.000000000000000001" : ] 000000450201362.261506000000000000 ; 000000473151576.704620000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AEF3E82D1F8D6 >									
	//     < NDRV_PFV_I_metadata_line_26_____Aseguradora Magallanes SA_20211101 >									
	//        < 4e50ZD0tq1x6OzZUxT3i5dvvYxLBPv14x3t1HPG0u0b77s8bEW1Z2W7t8F8QhT6Y >									
	//        <  u =="0.000000000000000001" : ] 000000473151576.704620000000000000 ; 000000499073367.763208000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D1F8D62F98689 >									
	//     < NDRV_PFV_I_metadata_line_27_____Asset Management Arm_20211101 >									
	//        < op1KdkxgZgT5Dm1WH8S5vd80dW9m6IO63NCJk44gmseXz09kQqCL3v7i1FZf2pIr >									
	//        <  u =="0.000000000000000001" : ] 000000499073367.763208000000000000 ; 000000521117344.875838000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F9868931B2976 >									
	//     < NDRV_PFV_I_metadata_line_28_____HDI Assicurazioni SpA_20211101 >									
	//        < 160jd5MuAmqL3RKk3S6xF9ERrpzhN2CSkSjf80f9V2U0YJmu6g9FarW8hFILTWR8 >									
	//        <  u =="0.000000000000000001" : ] 000000521117344.875838000000000000 ; 000000538355695.997924000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031B29763357732 >									
	//     < NDRV_PFV_I_metadata_line_29_____InChiaro Assicurazioni SPA_20211101 >									
	//        < U3u3OcFO3vV63dS73GgamUsRM4eZT3Iq9XcGW6G55X57bF7dy6C4X8t7lCPWWd1b >									
	//        <  u =="0.000000000000000001" : ] 000000538355695.997924000000000000 ; 000000560273355.898065000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003357732356E8C8 >									
	//     < NDRV_PFV_I_metadata_line_30_____Inlinea SpA_20211101 >									
	//        < 1o33oVHn9wd431Cov3uUh45vj4FLh6FNk2c03L6R7MSbFn44B8fBOeTJ2D3E8KYJ >									
	//        <  u =="0.000000000000000001" : ] 000000560273355.898065000000000000 ; 000000584487870.479186000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000356E8C837BDB93 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFV_I_metadata_line_31_____Inversiones HDI Limitada_20211101 >									
	//        < 2DO6zaa9D4wN1Aw1teIqhxbVq79VP48gr2I909LaDz5t8YHc9xY41b7cmhVWkjuT >									
	//        <  u =="0.000000000000000001" : ] 000000584487870.479186000000000000 ; 000000610184786.173899000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037BDB933A3116F >									
	//     < NDRV_PFV_I_metadata_line_32_____HDI Seguros de Garantía y Crédito SA_20211101 >									
	//        < Y4w3Xtnp3KgH48F2IlhKq6o8hWt9Q06UVx1iDFGJiH6wWf69V1gjE4vqxy55rLOX >									
	//        <  u =="0.000000000000000001" : ] 000000610184786.173899000000000000 ; 000000627553502.751778000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A3116F3BD9216 >									
	//     < NDRV_PFV_I_metadata_line_33_____HDI Seguros_20211101 >									
	//        < ahIoIB0SJ16yX9eMy0efn16I3j317RS7488qoUbOTbMWBRpT1Dm51jlpky0v40Tt >									
	//        <  u =="0.000000000000000001" : ] 000000627553502.751778000000000000 ; 000000646948991.343119000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BD92163DB2A73 >									
	//     < NDRV_PFV_I_metadata_line_34_____HDI Seguros_Holdings_20211101 >									
	//        < x78s4VBVj1IQFTzxf4PkY2c6aW379FfF17tnm9u4h3raZf82q51U5feAQ8F4Y7VY >									
	//        <  u =="0.000000000000000001" : ] 000000646948991.343119000000000000 ; 000000671605962.043706000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DB2A73400CA14 >									
	//     < NDRV_PFV_I_metadata_line_35_____Aseguradora Magallanes Peru SA Compania De Seguros_20211101 >									
	//        < 5c5ccTI546L6p0EY567k1p9387ZQB8SUmJCWQLm7hF25qwAENnOKkf4GXz56QjSn >									
	//        <  u =="0.000000000000000001" : ] 000000671605962.043706000000000000 ; 000000691299682.507339000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000400CA1441ED6F0 >									
	//     < NDRV_PFV_I_metadata_line_36_____Saint Honoré Iberia SL_20211101 >									
	//        < vrVbm8pZXFg9rgYCpqUNJ1id1Z2eNDLYPlWZRIU9ko30GYpjk03C5x2UbVEvv5BM >									
	//        <  u =="0.000000000000000001" : ] 000000691299682.507339000000000000 ; 000000708283839.308703000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041ED6F0438C160 >									
	//     < NDRV_PFV_I_metadata_line_37_____HDI Seguros SA_20211101 >									
	//        < 559l632DyyNcqAM8CVLpt5c2UWhNJLT3dTAt0WaOcM0GOFjP75Dxq7BPkyH6JTnd >									
	//        <  u =="0.000000000000000001" : ] 000000708283839.308703000000000000 ; 000000728264234.018287000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000438C1604573E37 >									
	//     < NDRV_PFV_I_metadata_line_38_____L_UNION de Paris Cia Uruguaya de Seguros SA_20211101 >									
	//        < sRhkTDxMQ35u66vn16vk0Funa2pQsUDzO5JIUw55VQ21Lb7ugx75Slxw4sZ4dpQd >									
	//        <  u =="0.000000000000000001" : ] 000000728264234.018287000000000000 ; 000000742200901.432960000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004573E3746C823A >									
	//     < NDRV_PFV_I_metadata_line_39_____L_UNION_org_20211101 >									
	//        < cZzbHRhGFLNt8eRjc6HK4Ufz9g8x72JjheeNoLeIjxe9D6b9N3Ry8hLXQLF09Ke5 >									
	//        <  u =="0.000000000000000001" : ] 000000742200901.432960000000000000 ; 000000759216279.272397000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046C823A48678DC >									
	//     < NDRV_PFV_I_metadata_line_40_____Protecciones Esenciales SA_20211101 >									
	//        < RCYym8h0zGBs4J9j6TM1Qu49mL2t7X1S6gsk9t8AJ04J826wv3lhWB3f02M6WGH1 >									
	//        <  u =="0.000000000000000001" : ] 000000759216279.272397000000000000 ; 000000778406367.995349000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048678DC4A3C0FD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}