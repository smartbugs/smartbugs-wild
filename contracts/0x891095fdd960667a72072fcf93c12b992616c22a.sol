pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXVI_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXVI_III_883		"	;
		string	public		symbol =	"	RUSS_PFXXVI_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1050136908396160000000000000					;	
										
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
	//     < RUSS_PFXXVI_III_metadata_line_1_____BLUE_STREAM_PIPE_CO_20251101 >									
	//        < Ca494Rs7xLS119pBRruIcCeLGedCYN2R82cxj0u65tqPr2Zsytq6Ta7Uoi1s33uh >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000031563105.327936800000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000302957 >									
	//     < RUSS_PFXXVI_III_metadata_line_2_____BLUESTREAM_DAO_20251101 >									
	//        < MosV16G539Xw2UvTY5hgsmz54O1JY3spuVeS92Wgd14V1E6RXedC4QnEP6KV6hHH >									
	//        <  u =="0.000000000000000001" : ] 000000031563105.327936800000000000 ; 000000050763535.354072000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003029574D7582 >									
	//     < RUSS_PFXXVI_III_metadata_line_3_____BLUESTREAM_DAOPI_20251101 >									
	//        < M2f6L4wMLsI1UCLu01WI0g175uVg11Ywu6ac957XB75S9D2TzroW231My1V72lQ7 >									
	//        <  u =="0.000000000000000001" : ] 000000050763535.354072000000000000 ; 000000077982738.406813100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004D758276FE02 >									
	//     < RUSS_PFXXVI_III_metadata_line_4_____BLUESTREAM_DAC_20251101 >									
	//        < 2KrwI8Qcnbfhqq0Ffi5Yif0smiJJ8e78t2iUbT4Ee7QM420ThrWj9Y6Ij1uS5M6J >									
	//        <  u =="0.000000000000000001" : ] 000000077982738.406813100000000000 ; 000000112620423.656611000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000076FE02ABD85A >									
	//     < RUSS_PFXXVI_III_metadata_line_5_____BLUESTREAM_BIMI_20251101 >									
	//        < DG34UetIlLl78CyaBSsL3P2i11YoPQ919KQ63chclhP2KW350cx3Jo2NEJ1n8KOd >									
	//        <  u =="0.000000000000000001" : ] 000000112620423.656611000000000000 ; 000000146963316.710887000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000ABD85AE03F8C >									
	//     < RUSS_PFXXVI_III_metadata_line_6_____PANRUSGAZ_20251101 >									
	//        < Z54z2O4e8kaX9dWYcu0rUV0kQbvSjxh6x14ecnUq2PgH9kgDJOf2r60JW9Bm31lL >									
	//        <  u =="0.000000000000000001" : ] 000000146963316.710887000000000000 ; 000000181943214.198192000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E03F8C1159F91 >									
	//     < RUSS_PFXXVI_III_metadata_line_7_____OKHRANA_PSC_20251101 >									
	//        < j49g3ft7xZ89lIbRRgh0I7UT47HMgURzEJtPMJ6gO7b38F336G4952aq9eiOrw12 >									
	//        <  u =="0.000000000000000001" : ] 000000181943214.198192000000000000 ; 000000209894772.265050000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001159F911404625 >									
	//     < RUSS_PFXXVI_III_metadata_line_8_____PROEKTIROVANYE_OOO_20251101 >									
	//        < 03h5fTfe3i997YlYhUz86Q92x9s468ihP9ykjfQ5y55OSHoAg1m5jOM7yiWBu861 >									
	//        <  u =="0.000000000000000001" : ] 000000209894772.265050000000000000 ; 000000231561741.452806000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000140462516155CE >									
	//     < RUSS_PFXXVI_III_metadata_line_9_____YUGOROSGAZ_20251101 >									
	//        < S3Sx0Poerr2FdbI5OEgtajqZOxP5I66Ez14CGM1iPH4igU4f15Q1cGmVA9RfudUn >									
	//        <  u =="0.000000000000000001" : ] 000000231561741.452806000000000000 ; 000000258864452.352744000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016155CE18AFEED >									
	//     < RUSS_PFXXVI_III_metadata_line_10_____GAZPROM_FINANCE_BV_20251101 >									
	//        < 7I3v970Cfdzcv7HKc8563uoR8n1uSwlA2ep5oauNpZOt0YK0W4Y91J9yBYq6yier >									
	//        <  u =="0.000000000000000001" : ] 000000258864452.352744000000000000 ; 000000280039256.916179000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018AFEED1AB4E56 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVI_III_metadata_line_11_____WINTERSHALL_NOORDZEE_BV_20251101 >									
	//        < 7x0eAiq12tfY07qnP6iqSEGh2RXwp8GDW3L85eQMup6sUmW0ONoHSEdNx0rtb3IA >									
	//        <  u =="0.000000000000000001" : ] 000000280039256.916179000000000000 ; 000000307422848.260099000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001AB4E561D5170D >									
	//     < RUSS_PFXXVI_III_metadata_line_12_____WINTERSHALL_DAO_20251101 >									
	//        < wSD3g21GEiwFS0NJu94nEV9381CVNnF6x156Mkq9uEKsZBGWcdlCJ8lWFI0dcDRm >									
	//        <  u =="0.000000000000000001" : ] 000000307422848.260099000000000000 ; 000000327008774.560045000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D5170D1F2F9CD >									
	//     < RUSS_PFXXVI_III_metadata_line_13_____WINTERSHALL_DAOPI_20251101 >									
	//        < aSSxeyjUlYPOJOxYr9Fu6zOSdt1Pd5AhVFOq06edm5p9ZGQ7W3g1LH6d611DpENG >									
	//        <  u =="0.000000000000000001" : ] 000000327008774.560045000000000000 ; 000000349074851.732302000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F2F9CD214A55D >									
	//     < RUSS_PFXXVI_III_metadata_line_14_____WINTERSHALL_DAC_20251101 >									
	//        < S0FVGU2z74qvX4337mYV5W6oY72324TSq3akd6v2qXLI4PGdge28v232g6zpLvlx >									
	//        <  u =="0.000000000000000001" : ] 000000349074851.732302000000000000 ; 000000369788359.784751000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000214A55D2344094 >									
	//     < RUSS_PFXXVI_III_metadata_line_15_____WINTERSHALL_BIMI_20251101 >									
	//        < z29QLu93387sBJr4z19NEVEROV96CuL3PFCt0jb60P31PD1kDYv5hf1i5531I1YE >									
	//        <  u =="0.000000000000000001" : ] 000000369788359.784751000000000000 ; 000000388821260.567676000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023440942514B4E >									
	//     < RUSS_PFXXVI_III_metadata_line_16_____SAKHALIN_HOLDINGS_BV_20251101 >									
	//        < lJ98WpV3JUp7Joe326iJ4jAJaN67OCFn1aBy6pmHq48nXx5AXE41lF62Pl3G42tI >									
	//        <  u =="0.000000000000000001" : ] 000000388821260.567676000000000000 ; 000000420392670.539661000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002514B4E28177E3 >									
	//     < RUSS_PFXXVI_III_metadata_line_17_____TRANSGAS_KAZAN_20251101 >									
	//        < A8AyvuI4Zy1h1wcKU4H0d34fKuusNFqUk4AR274Vmv67pKYu8q2eqfo9jci5g2Xi >									
	//        <  u =="0.000000000000000001" : ] 000000420392670.539661000000000000 ; 000000453707368.171383000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028177E32B44D71 >									
	//     < RUSS_PFXXVI_III_metadata_line_18_____SOUTH_STREAM_SERBIA_20251101 >									
	//        < m0bp8K3e4O674G6ZOm7F36izQJZ5PP1pr7M3rRqiXfw53OjJW9kBtgB5eGZ3800F >									
	//        <  u =="0.000000000000000001" : ] 000000453707368.171383000000000000 ; 000000486344623.997563000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B44D712E61A5E >									
	//     < RUSS_PFXXVI_III_metadata_line_19_____WINTERSHALL_ERDGAS_HANDELSHAUS_ZUG_AG_20251101 >									
	//        < 4446o7sP5UEnM5qKH3UWipIx4WOXARc3e1tvXMCNn1mGb2Fp8K4b26O64laku9mz >									
	//        <  u =="0.000000000000000001" : ] 000000486344623.997563000000000000 ; 000000521413363.708113000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E61A5E31B9D18 >									
	//     < RUSS_PFXXVI_III_metadata_line_20_____TRANSGAZ_MOSCOW_OOO_20251101 >									
	//        < IPD5w3X7eM6iyrBm0L93Moj4jl0w48ppm50llO8V1TJ888oOjpKJGhSZw7G41kUm >									
	//        <  u =="0.000000000000000001" : ] 000000521413363.708113000000000000 ; 000000547729130.008966000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031B9D18343C4B1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVI_III_metadata_line_21_____PERERABOTKA_20251101 >									
	//        < NyjWdkndW2h2kpxz3rXIMf8CpFY4YZFUmiFE05tG32ttuU9st3c39zY59XqnNJlF >									
	//        <  u =="0.000000000000000001" : ] 000000547729130.008966000000000000 ; 000000579131270.596855000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000343C4B1373AF27 >									
	//     < RUSS_PFXXVI_III_metadata_line_22_____GAZPROM_EXPORT_20251101 >									
	//        < v24Ak2BX6GR7dc1i2uf0FXJa9PqEkjCwmWAhbxmgyWLU8OhibV8iT7I8Pg7I50ai >									
	//        <  u =="0.000000000000000001" : ] 000000579131270.596855000000000000 ; 000000600816055.908082000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000373AF27394C5C6 >									
	//     < RUSS_PFXXVI_III_metadata_line_23_____WINGAS_20251101 >									
	//        < jT481uQwx14a365Bg001Xp8413ODqbU52z7En6nGCGPA25z8Tks7Nl5nKydr8csG >									
	//        <  u =="0.000000000000000001" : ] 000000600816055.908082000000000000 ; 000000633753408.843768000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000394C5C63C707ED >									
	//     < RUSS_PFXXVI_III_metadata_line_24_____DOBYCHA_URENGOY_20251101 >									
	//        < 22i9OxFEseASz7y4MZ3cg1AX2a0Wzgga1TU7FDIZ3LmBw9ruxuwwOE68MlrCJdf7 >									
	//        <  u =="0.000000000000000001" : ] 000000633753408.843768000000000000 ; 000000653112895.324276000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C707ED3E4923A >									
	//     < RUSS_PFXXVI_III_metadata_line_25_____MOSENERGO_20251101 >									
	//        < TAYlbjdqZk8ssG3OF1P7g9y3byLQEY45z8XTlRtId8a363iw0Sf6w52v6a1MdsmL >									
	//        <  u =="0.000000000000000001" : ] 000000653112895.324276000000000000 ; 000000677852171.189879000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E4923A40A5201 >									
	//     < RUSS_PFXXVI_III_metadata_line_26_____OGK_2_AB_20251101 >									
	//        < L9aq8CtR6Qpw4ruAl121fL3jjAh5Ty9VWp30RrWQb0v63zeOGZ8xaCdM5S700oX3 >									
	//        <  u =="0.000000000000000001" : ] 000000677852171.189879000000000000 ; 000000705036427.057424000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000040A5201433CCDB >									
	//     < RUSS_PFXXVI_III_metadata_line_27_____TGC_1_20251101 >									
	//        < fbVMpxGbsSoplMEtQZXBzj1rs62QcRGW76GI2Ref88w1mzLE1Z98G1f2oWUlDws9 >									
	//        <  u =="0.000000000000000001" : ] 000000705036427.057424000000000000 ; 000000728479370.498853000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000433CCDB4579241 >									
	//     < RUSS_PFXXVI_III_metadata_line_28_____GAZPROM_MEDIA_20251101 >									
	//        < Mchg2Xv93Dg1BxT1Qz5MawdgYs3h4CI1AD2uvW0t8WrasPw3N3ghhwv6CTwYSljm >									
	//        <  u =="0.000000000000000001" : ] 000000728479370.498853000000000000 ; 000000756212467.968060000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004579241481E37F >									
	//     < RUSS_PFXXVI_III_metadata_line_29_____ENERGOHOLDING_LLC_20251101 >									
	//        < 3Ii7Zj0SS82L2FzM0Px1Wx66qO0UV3itcTh0JEjR5Bh4GL102326Kh3kI0z6Z2Wc >									
	//        <  u =="0.000000000000000001" : ] 000000756212467.968060000000000000 ; 000000779510585.387803000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000481E37F4A57053 >									
	//     < RUSS_PFXXVI_III_metadata_line_30_____TRANSGAZ_TOMSK_OOO_20251101 >									
	//        < Ub698Hk43NBIo767jXbs3c1Je2bO07SzTp5NJh0ujlkZYGZe8DdtP338ZyEqy3H4 >									
	//        <  u =="0.000000000000000001" : ] 000000779510585.387803000000000000 ; 000000800661036.457297000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A570534C5B638 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXVI_III_metadata_line_31_____DOBYCHA_YAMBURG_20251101 >									
	//        < 42KtRwxw5TgjtjL8KY1nfsXz5D9KoJ67Hv44b7gkdIQ6y8618CCNX0LeHOPAl6U2 >									
	//        <  u =="0.000000000000000001" : ] 000000800661036.457297000000000000 ; 000000820022714.306914000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C5B6384E3415F >									
	//     < RUSS_PFXXVI_III_metadata_line_32_____YAMBURG_DAO_20251101 >									
	//        < pVZHpOFRi6gsNWYeRgIRBw43pOyHm8642a986otb0FVM6wYZxXdEndY73xjhK6aP >									
	//        <  u =="0.000000000000000001" : ] 000000820022714.306914000000000000 ; 000000842118304.707341000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004E3415F504F876 >									
	//     < RUSS_PFXXVI_III_metadata_line_33_____YAMBURG_DAOPI_20251101 >									
	//        < 5Au380uKJ5O9t92cupe9XTeejS958skB9Vusj5z4qx4e4oJad5jUh700W1f5idHu >									
	//        <  u =="0.000000000000000001" : ] 000000842118304.707341000000000000 ; 000000861617057.401773000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000504F876522B92A >									
	//     < RUSS_PFXXVI_III_metadata_line_34_____YAMBURG_DAC_20251101 >									
	//        < b0R54w61iDv6D33Gb8HnG2nGw3N6sIo55475nJxUi8C2i5tCd5go8l7tJ7E9ZZN6 >									
	//        <  u =="0.000000000000000001" : ] 000000861617057.401773000000000000 ; 000000888956107.382225000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000522B92A54C707B >									
	//     < RUSS_PFXXVI_III_metadata_line_35_____YAMBURG_BIMI_20251101 >									
	//        < 0EboqmsTs25225ZUBnZ1p6Dv22GWT95Gc237p8dkxM77F2GzRs7l42NflOZC3G4G >									
	//        <  u =="0.000000000000000001" : ] 000000888956107.382225000000000000 ; 000000923412252.929589000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000054C707B58103E9 >									
	//     < RUSS_PFXXVI_III_metadata_line_36_____EP_INTERNATIONAL_BV_20251101 >									
	//        < Crj0s2C22k4MX0400Ba55Wg19thJkyPoiB23a11VmC8g6U35304AW7QE68Mm25ya >									
	//        <  u =="0.000000000000000001" : ] 000000923412252.929589000000000000 ; 000000944358946.418827000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000058103E95A0FA37 >									
	//     < RUSS_PFXXVI_III_metadata_line_37_____TRANSGAZ_YUGORSK_20251101 >									
	//        < otyr0s1j207jDAyzm924pXE7S3IplYQgbzp4eZ618pBxc2LS35Sq35CgWD1D48QJ >									
	//        <  u =="0.000000000000000001" : ] 000000944358946.418827000000000000 ; 000000963823664.234896000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005A0FA375BEAD9E >									
	//     < RUSS_PFXXVI_III_metadata_line_38_____GAZPROM_GERMANIA_20251101 >									
	//        < p58HBMba4GumGY0UA1L94J39f55vX11GS240V5958S973782keObz33m9S0r5j1Y >									
	//        <  u =="0.000000000000000001" : ] 000000963823664.234896000000000000 ; 000000986910742.735801000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005BEAD9E5E1E802 >									
	//     < RUSS_PFXXVI_III_metadata_line_39_____GAZPROMENERGO_20251101 >									
	//        < H803B9GEBesNYoaCi1kjAhx54KWwghG425Nrh5Z0HYXZ427N9R8oB8bJeoBAXMNo >									
	//        <  u =="0.000000000000000001" : ] 000000986910742.735801000000000000 ; 000001018632152.718210000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005E1E8026124F2F >									
	//     < RUSS_PFXXVI_III_metadata_line_40_____INDUSTRIJA_SRBIJE_20251101 >									
	//        < Rmbd68JJK8O1nt56abo9h848gN426Yfe0G6ZzAP6xDMOr0zGwUo1eYYi6863QRDA >									
	//        <  u =="0.000000000000000001" : ] 000001018632152.718210000000000000 ; 000001050136908.396160000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006124F2F64261BB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}