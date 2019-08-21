pragma solidity 		^0.4.21	;						
										
	contract	NDD_PIN_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDD_PIN_I_883		"	;
		string	public		symbol =	"	NDD_PIN_I_1subDT		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1529765730801750000000000000					;	
										
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
	//     < NDD_PIN_I_metadata_line_1_____6938413225 Lab_x >									
	//        < 9phar9EbOhb1t2urNizZ649wt8kOO6ZJd84yIZ3OHP96Hzy9CbgNjbOa7jQM2Z1i >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000000F4240 >									
	//     < NDD_PIN_I_metadata_line_2_____9781285179 Lab_y >									
	//        < Jp7RdN3l6X5YaTle7o3n43i42C3q00rG3DBB984R9s6h803NTh608l44Tkg1T7Z6 >									
	//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000F42401E8480 >									
	//     < NDD_PIN_I_metadata_line_3_____2305657346 Lab_100 >									
	//        < x49Tk1serR7WqyFM7jFE08920d38Xi4qgW42C4MFO4u301xuws0nxcHqqW6MQ9Nq >									
	//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000030735258.562575000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E84802EE5F6 >									
	//     < NDD_PIN_I_metadata_line_4_____2398942531 Lab_110 >									
	//        < eZ1BPj2Z73yLG486c5kOVp7K2vvw4Wc68m4d13mk1z2Ph58AE9yWyaAt15aaPaOs >									
	//        <  u =="0.000000000000000001" : ] 000000030735258.562575000000000000 ; 000000041809883.322991600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002EE5F63FCBFC >									
	//     < NDD_PIN_I_metadata_line_5_____2360808243 Lab_410/401 >									
	//        < 1Se7Eo9ENoZ4KiSq25cLvd4stm94TehWN2ID6HBhM1w8eiwNO7osZmlH0O2o4Ms6 >									
	//        <  u =="0.000000000000000001" : ] 000000041809883.322991600000000000 ; 000000056108382.364658200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003FCBFC559D56 >									
	//     < NDD_PIN_I_metadata_line_6_____2346263729 Lab_810/801 >									
	//        < Zml3VpsTMEnbwxzDmX190k5ZI5yv9UO0nDVt002fzC9A83I3jV7UsG2r90D4cB9q >									
	//        <  u =="0.000000000000000001" : ] 000000056108382.364658200000000000 ; 000000074705380.447991200000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000559D5671FDCA >									
	//     < NDD_PIN_I_metadata_line_7_____2360808243 Lab_410_3Y1Y >									
	//        < H8upX801XXdrn01X6cXD2oF80829ECS40qUp6B0j52LmuH09039h1k78x7c0C6Tl >									
	//        <  u =="0.000000000000000001" : ] 000000074705380.447991200000000000 ; 000000103938243.485353000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000071FDCA9E98E0 >									
	//     < NDD_PIN_I_metadata_line_8_____2346263729 Lab_410_5Y1Y >									
	//        < BfFUY3cPu1A8vMbyWM7SW9C5nyJOpcMwQl5kj95sQfir5rKoLqXDTJ8hrmJSW8G6 >									
	//        <  u =="0.000000000000000001" : ] 000000103938243.485353000000000000 ; 000000113938243.485353000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009E98E0ADDB20 >									
	//     < NDD_PIN_I_metadata_line_9_____2323232323 Lab_410_7Y1Y >									
	//        < 7Y56L0HSulyHE67hRV6RqNa3c75s0q9yck5Umo2wKMsk9r5GNno873aZFd8hXjQm >									
	//        <  u =="0.000000000000000001" : ] 000000113938243.485353000000000000 ; 000000123938243.485353000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000ADDB20BD1D60 >									
	//     < NDD_PIN_I_metadata_line_10_____2323232323 Lab_810_3Y1Y >									
	//        < 2OVq0vqKoB84tmj5c9Ak989fRk9y6Mak8q2V8wbC632Ok7kD865EY3VHO7R1KZ21 >									
	//        <  u =="0.000000000000000001" : ] 000000123938243.485353000000000000 ; 000000188255652.220798000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000BD1D6011F415D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_PIN_I_metadata_line_11_____2370858245 Lab_810_5Y1Y >									
	//        < 85K312v3yfgJu5RlODno94slKQ2z457714bG4z9VRwuFmx7nLvY4dKRp5476bRgy >									
	//        <  u =="0.000000000000000001" : ] 000000188255652.220798000000000000 ; 000000198255652.220798000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011F415D12E839D >									
	//     < NDD_PIN_I_metadata_line_12_____2308213497 Lab_810_7Y1Y >									
	//        < 85AaJ7R9KBCBycxZe3Sj9qKRl0MuG1H67NIEoW6iKYGicqTPyX8G91nZV48ZdNDp >									
	//        <  u =="0.000000000000000001" : ] 000000198255652.220798000000000000 ; 000000208255652.220798000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012E839D13DC5DD >									
	//     < NDD_PIN_I_metadata_line_13_____2323232323 ro_Lab_110_3Y_1.00 >									
	//        < Fvg4Q3N0dLaH4camTBcBE1661S78587R1lRyP943WUk4zrAaXnx3tO0mxtNDbpSg >									
	//        <  u =="0.000000000000000001" : ] 000000208255652.220798000000000000 ; 000000229397197.483751000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013DC5DD15E0848 >									
	//     < NDD_PIN_I_metadata_line_14_____2323232323 ro_Lab_110_5Y_1.00 >									
	//        < NB7i3bVcCAT835wS2UuR9e87e7niv2OoSei9hvfFoLQFGGHgcc9r1wdJMm0y1q50 >									
	//        <  u =="0.000000000000000001" : ] 000000229397197.483751000000000000 ; 000000239397197.483751000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015E084816D4A88 >									
	//     < NDD_PIN_I_metadata_line_15_____2323232323 ro_Lab_110_5Y_1.10 >									
	//        < 44P83YeuVDUN5A4o6qvhg96k9LZqBW2ORe75UUTlAa2es5vB51K3STeL33yjusI8 >									
	//        <  u =="0.000000000000000001" : ] 000000239397197.483751000000000000 ; 000000249397197.483751000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016D4A8817C8CC8 >									
	//     < NDD_PIN_I_metadata_line_16_____2323232323 ro_Lab_110_7Y_1.00 >									
	//        < 899fA296Z6RrGc8ORm7rV4ZLyLLqL2W9d5NmrDnq81s8p811CZXSGp89TRl243NN >									
	//        <  u =="0.000000000000000001" : ] 000000249397197.483751000000000000 ; 000000259397197.483751000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000017C8CC818BCF08 >									
	//     < NDD_PIN_I_metadata_line_17_____2323232323 ro_Lab_210_3Y_1.00 >									
	//        < Jl0cSrVj6Dx257gZxF65icq0rH3wdp8SVR1M7ez9X7Eyl8FV462d2TLjDGkIYRZ4 >									
	//        <  u =="0.000000000000000001" : ] 000000259397197.483751000000000000 ; 000000270839422.696095000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018BCF0819D44A6 >									
	//     < NDD_PIN_I_metadata_line_18_____2323232323 ro_Lab_210_5Y_1.00 >									
	//        < 9g79Q3jIRa092eQ1o4pXQkDrL92JqW67XxcWP33nJSvfGn41F60aD781s5ipYai2 >									
	//        <  u =="0.000000000000000001" : ] 000000270839422.696095000000000000 ; 000000280839422.696095000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019D44A61AC86E6 >									
	//     < NDD_PIN_I_metadata_line_19_____2323232323 ro_Lab_210_5Y_1.10 >									
	//        < IYprAC438U2rP9lXKBdkM9xmEc8UXb2eJ6DkULntUuU7m8hZ6dmKNN5Hi68AtWLw >									
	//        <  u =="0.000000000000000001" : ] 000000280839422.696095000000000000 ; 000000290839422.696095000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AC86E61BBC926 >									
	//     < NDD_PIN_I_metadata_line_20_____2323232323 ro_Lab_210_7Y_1.00 >									
	//        < 2e5l46X3F3ua05S3P8bNHk1ONqP6r32x1ioVl9iDpVV8AZ36olTZ1sB5aFb3rRNb >									
	//        <  u =="0.000000000000000001" : ] 000000290839422.696095000000000000 ; 000000300839422.696095000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BBC9261CB0B66 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_PIN_I_metadata_line_21_____2307471523 ro_Lab_310_3Y_1.00 >									
	//        < io23EOERploeixol0a099ekv9O336AUwa1w4waI6M56uBHy7J5vlSlCDok81J2i9 >									
	//        <  u =="0.000000000000000001" : ] 000000300839422.696095000000000000 ; 000000312698016.730034000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CB0B661DD23AA >									
	//     < NDD_PIN_I_metadata_line_22_____2305707086 ro_Lab_310_5Y_1.00 >									
	//        < l5yPQ7r77D8N0ie71A1hqjkW10NvNOsKTis4ansR39jTAHQ296p8NjDS37aIAVa1 >									
	//        <  u =="0.000000000000000001" : ] 000000312698016.730034000000000000 ; 000000322698016.730034000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DD23AA1EC65EA >									
	//     < NDD_PIN_I_metadata_line_23_____2395473493 ro_Lab_310_5Y_1.10 >									
	//        < 6V9m85o98Vab6P4L78oLmg278yR92IBMnMpQ8awV26BQPsefmBPc9bNY9E02B6f4 >									
	//        <  u =="0.000000000000000001" : ] 000000322698016.730034000000000000 ; 000000332698016.730034000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001EC65EA1FBA82A >									
	//     < NDD_PIN_I_metadata_line_24_____2323232323 ro_Lab_310_7Y_1.00 >									
	//        < uO083Tf2oUA3h3Gf06ciDQ3XgPa8v5q9Cu1Xf6Ru9Lp9M00tms9J5E5epQfh4981 >									
	//        <  u =="0.000000000000000001" : ] 000000332698016.730034000000000000 ; 000000342698016.730034000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FBA82A20AEA6A >									
	//     < NDD_PIN_I_metadata_line_25_____2323232323 ro_Lab_410_3Y_1.00 >									
	//        < 7d55IN8A23iZjSgul3UKoABDmlA9uBsfZ39mZWJR9FPQ1U0gFh9Nno1I8Ua2Xw30 >									
	//        <  u =="0.000000000000000001" : ] 000000342698016.730034000000000000 ; 000000355045844.403500000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000020AEA6A21DC1C8 >									
	//     < NDD_PIN_I_metadata_line_26_____2323232323 ro_Lab_410_5Y_1.00 >									
	//        < Zl3d2176WGhHuzArfI9xS8k1Gpnw7591GZSJ69yJk9BnH1uxAYMQ6K1876Mq7MUX >									
	//        <  u =="0.000000000000000001" : ] 000000355045844.403500000000000000 ; 000000365045844.403500000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021DC1C822D0408 >									
	//     < NDD_PIN_I_metadata_line_27_____2323232323 ro_Lab_410_5Y_1.10 >									
	//        < IO63DT0iM3x5L78MO3NwSJf77wtHW9JC616uklE53n55wzTu748mt4iGZ4fCPSZp >									
	//        <  u =="0.000000000000000001" : ] 000000365045844.403500000000000000 ; 000000375045844.403500000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022D040823C4648 >									
	//     < NDD_PIN_I_metadata_line_28_____2323232323 ro_Lab_410_7Y_1.00 >									
	//        < NjqJg93DHYd6FtGod8iZced5V0OA08Z7RuYAJDzXQcHM44Ljm9u73z5FOEetu0OI >									
	//        <  u =="0.000000000000000001" : ] 000000375045844.403500000000000000 ; 000000385045844.403500000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023C464824B8888 >									
	//     < NDD_PIN_I_metadata_line_29_____2323232323 ro_Lab_810_3Y_1.00 >									
	//        < L32DLuiw0z5M21WCg2r8y6Op8fXNquaIi4hGPSp3332vaPtTf8R98IwjB86JN6ka >									
	//        <  u =="0.000000000000000001" : ] 000000385045844.403500000000000000 ; 000000400192498.714373000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000024B8888262A532 >									
	//     < NDD_PIN_I_metadata_line_30_____2323232323 ro_Lab_810_5Y_1.00 >									
	//        < W07YuvhBq5BdDbNU63X1fjxxyqHrdic3ka498dTkbJ3f0DaHBclEYhCIS33A7J2O >									
	//        <  u =="0.000000000000000001" : ] 000000400192498.714373000000000000 ; 000000410192498.714373000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000262A532271E772 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_PIN_I_metadata_line_31_____2399960061 ro_Lab_810_5Y_1.10 >									
	//        < nf8q1FDuIxO5j5g41KG89HgXKvoCzPlQ2h1jI89F3Ti1O2s2PoVK68W501gt1qW1 >									
	//        <  u =="0.000000000000000001" : ] 000000410192498.714373000000000000 ; 000000420192498.714373000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000271E77228129B2 >									
	//     < NDD_PIN_I_metadata_line_32_____2377677875 ro_Lab_810_7Y_1.00 >									
	//        < nKNzK0805NDs2VA5NtX1e18f8aE6Cgm55WuFL4f68bje4zfM62QxOugl73heYpE0 >									
	//        <  u =="0.000000000000000001" : ] 000000420192498.714373000000000000 ; 000000430192498.714373000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028129B22906BF2 >									
	//     < NDD_PIN_I_metadata_line_33_____2396008384 ro_Lab_411_3Y_1.00 >									
	//        < xH6X5u0EF97uCwFwYB7b9tStF02e3XZ3iWOfe4v8krVGDlvO5hZ0FbE0B60cS48Y >									
	//        <  u =="0.000000000000000001" : ] 000000430192498.714373000000000000 ; 000000443188087.365060000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002906BF22A44059 >									
	//     < NDD_PIN_I_metadata_line_34_____2364853061 ro_Lab_411_5Y_1.00 >									
	//        < Co9D918Il6A1pC52vtXa2iMPAS4B90h4K68qJZvvkEh6ayKXKYwH0719Tga8H25B >									
	//        <  u =="0.000000000000000001" : ] 000000443188087.365060000000000000 ; 000000468396270.419902000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A440592CAB74B >									
	//     < NDD_PIN_I_metadata_line_35_____2335569401 ro_Lab_411_5Y_1.10 >									
	//        < Q4m6GFy0qz7WqY6BkyGUvWJZ63rYHwmDa8HUWFkEhxmtV56sFNTrIo665B9V21g2 >									
	//        <  u =="0.000000000000000001" : ] 000000468396270.419902000000000000 ; 000000486572375.298407000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CAB74B2E67356 >									
	//     < NDD_PIN_I_metadata_line_36_____2382176926 ro_Lab_411_7Y_1.00 >									
	//        < zMQ9F7Y3R427XKwfqMTr6q52894TCiJ6cxOXHg0gC19zqpyCFXg0rC5G2M5GoL14 >									
	//        <  u =="0.000000000000000001" : ] 000000486572375.298407000000000000 ; 000000578766695.015263000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E6735637320BE >									
	//     < NDD_PIN_I_metadata_line_37_____2366871106 ro_Lab_811_3Y_1.00 >									
	//        < 7lW69Xl35lNefvkLp1SgJ9D1Lpk12oR2t8CO603n2TTFpA45Jlnb89ZHzMiL86Na >									
	//        <  u =="0.000000000000000001" : ] 000000578766695.015263000000000000 ; 000000594992131.819053000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000037320BE38BE2CD >									
	//     < NDD_PIN_I_metadata_line_38_____2328029932 ro_Lab_811_5Y_1.00 >									
	//        < z7f191GHs7PHLA2lnF8dresn54r52MRCMO8v9gqA027gzXOkItp01v6WR30WA5wo >									
	//        <  u =="0.000000000000000001" : ] 000000594992131.819053000000000000 ; 000000670055334.605039000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038BE2CD3FE6C5D >									
	//     < NDD_PIN_I_metadata_line_39_____2323232323 ro_Lab_811_5Y_1.10 >									
	//        < 2OW32hM1116HRf8s0514xKhV4Zs5tq8dL3l0l888Ysi3ad9pyGPHopv8D24y3IWU >									
	//        <  u =="0.000000000000000001" : ] 000000670055334.605039000000000000 ; 000000711969404.737258000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FE6C5D43E610C >									
	//     < NDD_PIN_I_metadata_line_40_____2323232323 ro_Lab_811_7Y_1.00 >									
	//        < 80OUaCXs4vtjJ6j3QpGSL31eIYW07hg6Ado5Uol4vuY2Y8du9TOtX48Jel19j4r3 >									
	//        <  u =="0.000000000000000001" : ] 000000711969404.737258000000000000 ; 000001529765730.801750000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043E610C91E3CBD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}