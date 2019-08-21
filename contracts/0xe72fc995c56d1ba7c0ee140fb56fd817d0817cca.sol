pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFII_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFII_III_883		"	;
		string	public		symbol =	"	RUSS_PFII_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		1227195821591560000000000000					;	
										
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
	//     < RUSS_PFII_III_metadata_line_1_____SISTEMA_20251101 >									
	//        < WTiINsowsmGng18Sml2Bk2bm5X93723IOWO7WMgbXVf4QnMU9O3VnDDpMx36p49x >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000032317822.495067900000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000315026 >									
	//     < RUSS_PFII_III_metadata_line_2_____SISTEMA_usd_20251101 >									
	//        < 50lX4u529Blr8T1K7fZBu69m1H4X13apN5SVa5Brx9oq2267i2Dnub7j59Y082c2 >									
	//        <  u =="0.000000000000000001" : ] 000000032317822.495067900000000000 ; 000000057890917.358749400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003150265855A4 >									
	//     < RUSS_PFII_III_metadata_line_3_____SISTEMA_AB_20251101 >									
	//        < BI95Igga636C40hZgf06L6J9zoCdpnrdiDhj6YUp81lRAVhn9EKxyL09MvUAk9a9 >									
	//        <  u =="0.000000000000000001" : ] 000000057890917.358749400000000000 ; 000000085827286.215121800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005855A482F649 >									
	//     < RUSS_PFII_III_metadata_line_4_____RUSAL_20251101 >									
	//        < 7c31OHA6cQFU98033e7de395hEUY21Nih1670oKHpYa20Kf50TcVLOI9KgA7Dn87 >									
	//        <  u =="0.000000000000000001" : ] 000000085827286.215121800000000000 ; 000000123492376.719388000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000082F649BC6F36 >									
	//     < RUSS_PFII_III_metadata_line_5_____RUSAL_HKD_20251101 >									
	//        < 7Zl0H0d08m9bT0szf3IONx2fy39IOsloPtv22f4B01K54xPU8i70v7R84P20PVyU >									
	//        <  u =="0.000000000000000001" : ] 000000123492376.719388000000000000 ; 000000151931118.367688000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BC6F36E7D418 >									
	//     < RUSS_PFII_III_metadata_line_6_____RUSAL_GBP_20251101 >									
	//        < 93J3d0th7Ig7u9k7okBLxvyb4Co2HyhM9rv0HZQb3qY96348v4OeytVDe5HvuFp6 >									
	//        <  u =="0.000000000000000001" : ] 000000151931118.367688000000000000 ; 000000185609864.199651000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E7D41811B37DA >									
	//     < RUSS_PFII_III_metadata_line_7_____RUSAL_AB_20251101 >									
	//        < 8p3Zl6I6IOURopFZm868ngq420CXjduO8gMg4g36xFf6a7i719q7K7eVZ2LTkbCo >									
	//        <  u =="0.000000000000000001" : ] 000000185609864.199651000000000000 ; 000000212267667.197239000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000011B37DA143E50F >									
	//     < RUSS_PFII_III_metadata_line_8_____EUROSIBENERGO_20251101 >									
	//        < 0asE2ow160uhG15R8078876v8pElts6TmlED0a9s2KgPx8lz3g738G1J16FC5JSA >									
	//        <  u =="0.000000000000000001" : ] 000000212267667.197239000000000000 ; 000000237582327.120245000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000143E50F16A8599 >									
	//     < RUSS_PFII_III_metadata_line_9_____BASEL_20251101 >									
	//        < sqcIt0MZAvSV09n15P4f6B2w9D54SKI817bS5X069YLbOU2534tAeaO40JnQ0Ji7 >									
	//        <  u =="0.000000000000000001" : ] 000000237582327.120245000000000000 ; 000000269580853.968830000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016A859919B5905 >									
	//     < RUSS_PFII_III_metadata_line_10_____ENPLUS_20251101 >									
	//        < blt47uQR5LPT0X5e0eTrXDw6sa1W3bXYMp3goo9iHCtBnuDxA9dH7NIeHeE2wzmc >									
	//        <  u =="0.000000000000000001" : ] 000000269580853.968830000000000000 ; 000000305455101.787325000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019B59051D21666 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFII_III_metadata_line_11_____RUSSIAN_MACHINES_20251101 >									
	//        < 0NSDA0bVe9gOEmtSc5E1cvB8tn25m2gy6T915ytOe5WL3j89q0K95r2vRfoKq9yO >									
	//        <  u =="0.000000000000000001" : ] 000000305455101.787325000000000000 ; 000000333787896.083815000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D216661FD51E6 >									
	//     < RUSS_PFII_III_metadata_line_12_____GAZ_GROUP_20251101 >									
	//        < Q4o4kWSRLO1yMIdvQ69GWEsSxO7cm413BmbP3op5Edv6qtNQWghdd7z6vIRcEhv7 >									
	//        <  u =="0.000000000000000001" : ] 000000333787896.083815000000000000 ; 000000365730889.863000000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FD51E622E0FA1 >									
	//     < RUSS_PFII_III_metadata_line_13_____SMR_20251101 >									
	//        < 9cneGZ85D7VcW0LPIi6Xr32Pp3ppvgy7W5UhRz34fy17Z1h6YKXaqVm28Y4wbn6j >									
	//        <  u =="0.000000000000000001" : ] 000000365730889.863000000000000000 ; 000000393553523.753079000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022E0FA125883D8 >									
	//     < RUSS_PFII_III_metadata_line_14_____ENPLUS_DOWN_20251101 >									
	//        < 5WS4aISSiJAN9Js0V2vE5uZfA592f71HL77IIoehfZO115oIL70FBStFolCrfqL3 >									
	//        <  u =="0.000000000000000001" : ] 000000393553523.753079000000000000 ; 000000431415419.095992000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025883D829249A6 >									
	//     < RUSS_PFII_III_metadata_line_15_____ENPLUS_COAL_20251101 >									
	//        < OH2F4AOimKjc5RMg227c5iou8cpyrW2Z4M06fe89auXmetA2hHNTaIhnu4mPfD2p >									
	//        <  u =="0.000000000000000001" : ] 000000431415419.095992000000000000 ; 000000458680024.729224000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000029249A62BBE3E2 >									
	//     < RUSS_PFII_III_metadata_line_16_____RM_SYSTEMS_20251101 >									
	//        < C09nObCLReKSA1r87Pi25Ocs8gQ3F5V9b2AWbiGaK22HSnXj5Zp2ZM3IChj9an1F >									
	//        <  u =="0.000000000000000001" : ] 000000458680024.729224000000000000 ; 000000491812043.501746000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BBE3E22EE7214 >									
	//     < RUSS_PFII_III_metadata_line_17_____RM_RAIL_20251101 >									
	//        < T14PIO5v1cJ04qqw7b4iXH99ygUt63L733Di979y9zlaT41UY8jp2lMaW34wzlbr >									
	//        <  u =="0.000000000000000001" : ] 000000491812043.501746000000000000 ; 000000519775468.363795000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002EE72143191D4B >									
	//     < RUSS_PFII_III_metadata_line_18_____AVIAKOR_20251101 >									
	//        < nZTy2ZUUd88fi2q30RzNI5iI7cx0Qm2h0S9vSxn66h805bmm4o6x3Lb7dxBI01gC >									
	//        <  u =="0.000000000000000001" : ] 000000519775468.363795000000000000 ; 000000554621591.804295000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003191D4B34E490F >									
	//     < RUSS_PFII_III_metadata_line_19_____SOCHI_AIRPORT_20251101 >									
	//        < ynZatR64pc6g7I9fng3Ry2dDLJG4lM4p5ca8Oj9VBnoOfT4C66681l9s74NeanyG >									
	//        <  u =="0.000000000000000001" : ] 000000554621591.804295000000000000 ; 000000582525442.440025000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034E490F378DD00 >									
	//     < RUSS_PFII_III_metadata_line_20_____KRASNODAR_AIRPORT_20251101 >									
	//        < 857S10QT0WzGcS8bEag0130aR7dCJ6luXJPo6HfSKTYn98uE26rZj2447049KQyy >									
	//        <  u =="0.000000000000000001" : ] 000000582525442.440025000000000000 ; 000000619532436.169571000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000378DD003B154DC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFII_III_metadata_line_21_____ANAPA_AIRPORT_20251101 >									
	//        < jqfZ9CbGli3ym1ob7y97C0z9XOr0ofjV0V4gGUN5IdC5K0p4VWFA601mM84yW436 >									
	//        <  u =="0.000000000000000001" : ] 000000619532436.169571000000000000 ; 000000644919080.180729000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B154DC3D81184 >									
	//     < RUSS_PFII_III_metadata_line_22_____GLAVMOSSTROY_20251101 >									
	//        < 79SIHL4d83u51pm286SHxSs78UIkSQD343hEz8r6R88akL2KXS114mh5AkQQ8Ea9 >									
	//        <  u =="0.000000000000000001" : ] 000000644919080.180729000000000000 ; 000000683437746.051230000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D81184412D7DF >									
	//     < RUSS_PFII_III_metadata_line_23_____TRANSSTROY_20251101 >									
	//        < O6C322aK0c62eQLYv8GcECa3h4baZ1WBh7e8m8Z2xcUQ23Y4yeIFq7gPU4pyQDhp >									
	//        <  u =="0.000000000000000001" : ] 000000683437746.051230000000000000 ; 000000712982700.034061000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000412D7DF43FECDE >									
	//     < RUSS_PFII_III_metadata_line_24_____GLAVSTROY_20251101 >									
	//        < TbZ76aAD57sMtU3A0djno9F9P6wV80ZXfS73oL72XgQ1ZE4m1X9t8Co8X8p66wJa >									
	//        <  u =="0.000000000000000001" : ] 000000712982700.034061000000000000 ; 000000742007948.640583000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043FECDE46C36DB >									
	//     < RUSS_PFII_III_metadata_line_25_____GLAVSTROY_SPB_20251101 >									
	//        < 65C55sSlIPD58Hl1Q6jGQss6J67hUh3eJd5CX63R4K58H4Mve4IG1zDsYS3P573u >									
	//        <  u =="0.000000000000000001" : ] 000000742007948.640583000000000000 ; 000000769103922.346593000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000046C36DB4958F38 >									
	//     < RUSS_PFII_III_metadata_line_26_____ROGSIBAL_20251101 >									
	//        < ALjTb4SWCpP47krfvGRWp05tgBW68jTg265F9xowMa9h46J0UbG0m2iz21fKZnAp >									
	//        <  u =="0.000000000000000001" : ] 000000769103922.346593000000000000 ; 000000794801236.278625000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004958F384BCC53C >									
	//     < RUSS_PFII_III_metadata_line_27_____BASEL_CEMENT_20251101 >									
	//        < 4v77tfaIY4kyq136U3yHuW2j407ZOBKu5NkP1Vln908qSzFoVB65d42GXvKQb6Q6 >									
	//        <  u =="0.000000000000000001" : ] 000000794801236.278625000000000000 ; 000000825524603.578182000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004BCC53C4EBA68C >									
	//     < RUSS_PFII_III_metadata_line_28_____KUBAN_AGROHOLDING_20251101 >									
	//        < jOFKIzu703kk536835tjZt2TbNUbxiDdY9393Dwh8U1ku2YZGA562BskwPtD7CP0 >									
	//        <  u =="0.000000000000000001" : ] 000000825524603.578182000000000000 ; 000000856329520.268352000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004EBA68C51AA7B8 >									
	//     < RUSS_PFII_III_metadata_line_29_____AQUADIN_20251101 >									
	//        < O3o07d2LKBeZPXE80j8n79wGg6um60d1iQ3YVE8v64Qq8yTe8x0I224g6r5Zg8IC >									
	//        <  u =="0.000000000000000001" : ] 000000856329520.268352000000000000 ; 000000890145706.235790000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000051AA7B854E412B >									
	//     < RUSS_PFII_III_metadata_line_30_____VASKHOD_STUD_FARM_20251101 >									
	//        < wwJu1hUWIoprHBnFaTW7ZZ8m06tGo81wxXCD65m6ptyH91p5fM5947cl2977A8QM >									
	//        <  u =="0.000000000000000001" : ] 000000890145706.235790000000000000 ; 000000925148720.629074000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000054E412B583AA38 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFII_III_metadata_line_31_____IMERETINSKY_PORT_20251101 >									
	//        < 6A894LAK2i2acW72l0ef0TT6r81tds2AHQE6DH14UYz2kiZJH6Gzj66S3o7y3VZg >									
	//        <  u =="0.000000000000000001" : ] 000000925148720.629074000000000000 ; 000000952647584.092162000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000583AA385AD9FF6 >									
	//     < RUSS_PFII_III_metadata_line_32_____BASEL_REAL_ESTATE_20251101 >									
	//        < XZn5yN3cWJj1MdAp6u8PwIyXtVr74vgGbw409K3G8CU5ftBIGr2YQoRt2qSD21Zk >									
	//        <  u =="0.000000000000000001" : ] 000000952647584.092162000000000000 ; 000000983475776.386917000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005AD9FF65DCAA3A >									
	//     < RUSS_PFII_III_metadata_line_33_____UZHURALZOLOTO_20251101 >									
	//        < 4Wz4Q0ONA4EhGpKb03svD6Vjp4YXV9S59A1Ko9wy5qe0Q12i23F2k8d9PF7k0Z3P >									
	//        <  u =="0.000000000000000001" : ] 000000983475776.386917000000000000 ; 000001014599683.557480000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005DCAA3A60C2800 >									
	//     < RUSS_PFII_III_metadata_line_34_____NORILSK_NICKEL_20251101 >									
	//        < AZDcs3BYLaKFu3p69ThcRO6KO9tF2DSUXr2wuw0EEpXObpwgchJlhUrJqGZ3zrsT >									
	//        <  u =="0.000000000000000001" : ] 000001014599683.557480000000000000 ; 000001053530609.499370000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000060C28006478F65 >									
	//     < RUSS_PFII_III_metadata_line_35_____RUSHYDRO_20251101 >									
	//        < HzWVe8xk8jc62i21jZV1Vlg4RnZ722Os8J4DO8gFh1ZvEJo02WuswXQ11SyrJeZW >									
	//        <  u =="0.000000000000000001" : ] 000001053530609.499370000000000000 ; 000001079316431.848130000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006478F6566EE7FB >									
	//     < RUSS_PFII_III_metadata_line_36_____INTER_RAO_20251101 >									
	//        < 2Iv7rS5vhcIZGELnp5eWFw2kyTY56oLuoK8y2bTovl93Z1QURcC6g2WHCVwyF0J7 >									
	//        <  u =="0.000000000000000001" : ] 000001079316431.848130000000000000 ; 000001105798667.776590000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000066EE7FB697509B >									
	//     < RUSS_PFII_III_metadata_line_37_____LUKOIL_20251101 >									
	//        < 4VvxpY410LHmh9t4MM1croL58ptkFX8YF5S0u28Jy6jHz0Ta8tY9JF3I2840w67t >									
	//        <  u =="0.000000000000000001" : ] 000001105798667.776590000000000000 ; 000001134373370.728240000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000697509B6C2EA99 >									
	//     < RUSS_PFII_III_metadata_line_38_____MAGNITOGORSK_ISW_20251101 >									
	//        < 36WYhl5zY6Dv9GO3K2WZ74cS9DXqCgj3C2OrYodi5mO7DADg4O3h1MRt5oDGCIu3 >									
	//        <  u =="0.000000000000000001" : ] 000001134373370.728240000000000000 ; 000001169069712.351510000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006C2EA996F7DBDB >									
	//     < RUSS_PFII_III_metadata_line_39_____MAGNIT_20251101 >									
	//        < 232gv2bonec0Ddgj27TTUGcrLCKoL56e8352CH9tDu77N520AbZ7952MYcusO6My >									
	//        <  u =="0.000000000000000001" : ] 000001169069712.351510000000000000 ; 000001198828255.604450000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006F7DBDB725444A >									
	//     < RUSS_PFII_III_metadata_line_40_____IDGC_20251101 >									
	//        < ld6F3nWBcUYY6CfIy0Ggp6Hh459cHS0ACtc78ReIkLLfid2oDGFkNTkPz3uuy3vv >									
	//        <  u =="0.000000000000000001" : ] 000001198828255.604450000000000000 ; 000001227195821.591560000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000725444A7508D5E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}