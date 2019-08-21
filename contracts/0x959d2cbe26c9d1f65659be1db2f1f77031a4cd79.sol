pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXX_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXX_II_883		"	;
		string	public		symbol =	"	RUSS_PFXX_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		802492326563360000000000000					;	
										
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
	//     < RUSS_PFXX_II_metadata_line_1_____Eurochem_20231101 >									
	//        < DtUX44cirG6XI5N81GUg0LWKd9D8354GEBwJifMbek9IT0N44UoG2lSmogxv1392 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000021579568.568397600000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000020ED85 >									
	//     < RUSS_PFXX_II_metadata_line_2_____Eurochem_Group_AG_Switzerland_20231101 >									
	//        < 2BYQ0552EVKttj98BmXZIop2yftKu9Tka3U32Y4g2Lvf198Abm0gD0x3uUrjN106 >									
	//        <  u =="0.000000000000000001" : ] 000000021579568.568397600000000000 ; 000000039731309.950399900000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000020ED853CA00B >									
	//     < RUSS_PFXX_II_metadata_line_3_____Industrial _Group_Phosphorite_20231101 >									
	//        < w181LKWscBQNr7hleTTY61v5Q7RVV7F9DTE2Okc4lljlcPD924Iw06U5VnNs9Pr4 >									
	//        <  u =="0.000000000000000001" : ] 000000039731309.950399900000000000 ; 000000063208714.472552700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000003CA00B6072E7 >									
	//     < RUSS_PFXX_II_metadata_line_4_____Novomoskovsky_Azot_20231101 >									
	//        < UHojoLqsMqPV94zyxj8T49HXM0LtH3m46QuH582J7szr3J247J8HHR7N6JDET929 >									
	//        <  u =="0.000000000000000001" : ] 000000063208714.472552700000000000 ; 000000080724765.963905400000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006072E77B2D1D >									
	//     < RUSS_PFXX_II_metadata_line_5_____Novomoskovsky_Chlor_20231101 >									
	//        < 5aWRI3YLKeN1K7xw91W34ZouBZ6j6XZz31gl6vNTTqi04PENNjNO3gm88E730Ox5 >									
	//        <  u =="0.000000000000000001" : ] 000000080724765.963905400000000000 ; 000000101456063.297591000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007B2D1D9ACF46 >									
	//     < RUSS_PFXX_II_metadata_line_6_____Nevinnomyssky_Azot_20231101 >									
	//        < dO5U2xnWpil3gW0Da8oh15tg12bCHueqjfK6e0e392Gt8U8u2L4snKd99Ax5sQS5 >									
	//        <  u =="0.000000000000000001" : ] 000000101456063.297591000000000000 ; 000000120426278.827442000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009ACF46B7C184 >									
	//     < RUSS_PFXX_II_metadata_line_7_____EuroChem_Belorechenskie_Minudobrenia_20231101 >									
	//        < 3t8VfHj5N28ILlwqqn0q59fCyu6l69vt7FhhQuHo5qZ4a0Ii89KF3tw99H6kGy2L >									
	//        <  u =="0.000000000000000001" : ] 000000120426278.827442000000000000 ; 000000140009723.396492000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B7C184D5A34C >									
	//     < RUSS_PFXX_II_metadata_line_8_____Kovdorsky_GOK_20231101 >									
	//        < eIbe6E4aK24U97JAay1GW3R8mLO9C883V5r82ShUY02R85R7D9k2Uj06rjQP58Nn >									
	//        <  u =="0.000000000000000001" : ] 000000140009723.396492000000000000 ; 000000160418916.710220000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D5A34CF4C7A4 >									
	//     < RUSS_PFXX_II_metadata_line_9_____Lifosa_AB_20231101 >									
	//        < WStgZJmY606IabU4N89A178SuI1hBMsv0ShgFEQViUaFD9Mqgwpj0i4Fw1A9Olc3 >									
	//        <  u =="0.000000000000000001" : ] 000000160418916.710220000000000000 ; 000000183118343.022979000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000F4C7A41176A9A >									
	//     < RUSS_PFXX_II_metadata_line_10_____EuroChem_Antwerpen_NV_20231101 >									
	//        < LogT50E0749OCi2749L8O2oi05eppu9j456DoTh3T30sG4f53x589n58A2VQH3dP >									
	//        <  u =="0.000000000000000001" : ] 000000183118343.022979000000000000 ; 000000203378391.368614000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001176A9A13654AF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXX_II_metadata_line_11_____EuroChem_VolgaKaliy_20231101 >									
	//        < a8MaePTJ7Rw2Uw4i7zykiC9nL397JuJS4dztO78JlK298K753v917f12Td1k9x9k >									
	//        <  u =="0.000000000000000001" : ] 000000203378391.368614000000000000 ; 000000226754823.869890000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000013654AF15A001A >									
	//     < RUSS_PFXX_II_metadata_line_12_____EuroChem_Usolsky_potash_complex_20231101 >									
	//        < UX66Qg7pr76WfGrMSqCwsEsBNrgZH2f8DE36eQiUashrhuo7fH7WUCg5P09MlxEb >									
	//        <  u =="0.000000000000000001" : ] 000000226754823.869890000000000000 ; 000000246896013.717954000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015A001A178BBC1 >									
	//     < RUSS_PFXX_II_metadata_line_13_____EuroChem_ONGK_20231101 >									
	//        < c81INHZj1Moq3ZkI4iEG22sK21oZQVad5m2CfPc6VbU44iL4UmghwuMpIItlD7d1 >									
	//        <  u =="0.000000000000000001" : ] 000000246896013.717954000000000000 ; 000000268747832.237278000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000178BBC119A139F >									
	//     < RUSS_PFXX_II_metadata_line_14_____EuroChem_Northwest_20231101 >									
	//        < LS88J0goi6ov26qtEnDJ7nd9pOAH5fT3NMSK3MJs1qV8Y5p3wY0GJX3Fw4uRH3Yo >									
	//        <  u =="0.000000000000000001" : ] 000000268747832.237278000000000000 ; 000000286336336.769571000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019A139F1B4EA22 >									
	//     < RUSS_PFXX_II_metadata_line_15_____EuroChem_Fertilizers_20231101 >									
	//        < iw9O9CS0As9cMYhTS2J89944t5AAb4bHmT8HynJsA1Xi9ZG7C4nFjutgNWCCfTI8 >									
	//        <  u =="0.000000000000000001" : ] 000000286336336.769571000000000000 ; 000000309762245.547748000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B4EA221D8A8E1 >									
	//     < RUSS_PFXX_II_metadata_line_16_____Astrakhan_Oil_and_Gas_Company_20231101 >									
	//        < tk8ovk75Z8067UC0oYIb9C3Uvz9HNf58qwuuHJjxFuC6X6TbfkbWry5xRaAbT6Z1 >									
	//        <  u =="0.000000000000000001" : ] 000000309762245.547748000000000000 ; 000000330031819.051205000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D8A8E11F796AE >									
	//     < RUSS_PFXX_II_metadata_line_17_____Sary_Tas_Fertilizers_20231101 >									
	//        < Wul8y8Ag7j2yEa6DzvA1dIj9kWHnT8Wc8a6JuKUTGwAnjM6lkkl747V21FhEmTZ7 >									
	//        <  u =="0.000000000000000001" : ] 000000330031819.051205000000000000 ; 000000353954086.599739000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F796AE21C1751 >									
	//     < RUSS_PFXX_II_metadata_line_18_____EuroChem_Karatau_20231101 >									
	//        < w8Dp1qb0L3RS2F6N73NCG7lCQxy63v7WCzGt0s584K8yf5195yqkF4M44uk5KRL5 >									
	//        <  u =="0.000000000000000001" : ] 000000353954086.599739000000000000 ; 000000376119930.137568000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000021C175123DE9D9 >									
	//     < RUSS_PFXX_II_metadata_line_19_____Kamenkovskaya_Oil_Gas_Company_20231101 >									
	//        < NhqWdK2P06635fA4a8ey75QzS0NJ93E7GOWA473sDp5683C7v3xybNGabCx28WVQ >									
	//        <  u =="0.000000000000000001" : ] 000000376119930.137568000000000000 ; 000000395231082.904869000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023DE9D925B1324 >									
	//     < RUSS_PFXX_II_metadata_line_20_____EuroChem_Trading_GmbH_Trading_20231101 >									
	//        < Xfsp42Ui7JWR7X3XP6MI0576nKf8mUNQBwg48h32awj07q1U04sdT2cE7z6jt6dF >									
	//        <  u =="0.000000000000000001" : ] 000000395231082.904869000000000000 ; 000000413797214.864988000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025B13242776789 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXX_II_metadata_line_21_____EuroChem_Trading_USA_Corp_20231101 >									
	//        < 10GgAWLA0RSU0ufNXqEbv5BwPgd56B6f48Ti35Pc4ifb7i2N7Ki9S16J0IjZD0DU >									
	//        <  u =="0.000000000000000001" : ] 000000413797214.864988000000000000 ; 000000434312091.053626000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002776789296B529 >									
	//     < RUSS_PFXX_II_metadata_line_22_____Ben_Trei_Ltd_20231101 >									
	//        < C3k5L6O9J16uQYhaAmX4H380s9H5as797g10a6st8t9l89kHrVD0SdN6kmk8xPdi >									
	//        <  u =="0.000000000000000001" : ] 000000434312091.053626000000000000 ; 000000451570022.042606000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000296B5292B10A8A >									
	//     < RUSS_PFXX_II_metadata_line_23_____EuroChem_Agro_SAS_20231101 >									
	//        < 8xy6ZR8X2In39DXh0ZjU4hW27I5M5x7VDof72Vag0kvA87z66a1kzgvBdBqj9Rp8 >									
	//        <  u =="0.000000000000000001" : ] 000000451570022.042606000000000000 ; 000000471139499.580446000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B10A8A2CEE6DE >									
	//     < RUSS_PFXX_II_metadata_line_24_____EuroChem_Agro_Asia_20231101 >									
	//        < AQQ82e8MS9kBZ3dK5BSNfp4I1I2Q8XOeti7qCygtgN237H6fkh04239NKY81lvqS >									
	//        <  u =="0.000000000000000001" : ] 000000471139499.580446000000000000 ; 000000495146218.901561000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CEE6DE2F3887E >									
	//     < RUSS_PFXX_II_metadata_line_25_____EuroChem_Agro_Iberia_20231101 >									
	//        < 4CluGX0Hd2jqpyaQtBY5J9jUX4yNU34L7biBa7RwNUv5C75281572z26oDNipsIv >									
	//        <  u =="0.000000000000000001" : ] 000000495146218.901561000000000000 ; 000000511346627.493334000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F3887E30C40C7 >									
	//     < RUSS_PFXX_II_metadata_line_26_____EuroChem_Agricultural_Trading_Hellas_20231101 >									
	//        < u0GUwCu9DAME6M1H7M0C2W3Xh5xE4K1Hx3YpO7lE1LELGLT0XR2a3KQhS59qy45a >									
	//        <  u =="0.000000000000000001" : ] 000000511346627.493334000000000000 ; 000000526809996.899413000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030C40C7323D928 >									
	//     < RUSS_PFXX_II_metadata_line_27_____EuroChem_Agro_Spa_20231101 >									
	//        < BWWqJz3iw4cu1f6ig0Hovdl3Y2d8G4m0W4HkOq7TN2T9iaHqw666KTtXnT54FK2c >									
	//        <  u =="0.000000000000000001" : ] 000000526809996.899413000000000000 ; 000000546656634.918768000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000323D92834221BF >									
	//     < RUSS_PFXX_II_metadata_line_28_____EuroChem_Agro_GmbH_20231101 >									
	//        < N1MDglFoytd2lumd2I2NqcAio0M7cNNjZ9xa094ec68dr6C5V4uC953AKPA162D4 >									
	//        <  u =="0.000000000000000001" : ] 000000546656634.918768000000000000 ; 000000569423938.652262000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034221BF364DF3A >									
	//     < RUSS_PFXX_II_metadata_line_29_____EuroChem_Agro_México_SA_20231101 >									
	//        < OYq9Su4oNhJh6ntXHf54lK2w08S3uH0XzzbUChR4QGKM11iqayy2YE4Wnp637htb >									
	//        <  u =="0.000000000000000001" : ] 000000569423938.652262000000000000 ; 000000594155895.408431000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000364DF3A38A9C26 >									
	//     < RUSS_PFXX_II_metadata_line_30_____EuroChem_Agro_Hungary_Kft_20231101 >									
	//        < HCd0D7FVqWUPtXkcM26ISf978mCTQ185q8OP2L61iM0p86npVT1303H3Pk00dR5H >									
	//        <  u =="0.000000000000000001" : ] 000000594155895.408431000000000000 ; 000000611472727.161119000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038A9C263A50889 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXX_II_metadata_line_31_____Agrocenter_EuroChem_Srl_20231101 >									
	//        < pI55kMj7z7VXD94gnOL7xrXsavzmVyI3bxyy5rD53hR1a8iXx48v2fUt0rSM264w >									
	//        <  u =="0.000000000000000001" : ] 000000611472727.161119000000000000 ; 000000628733730.649446000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A508893BF5F1D >									
	//     < RUSS_PFXX_II_metadata_line_32_____EuroChem_Agro_Bulgaria_Ead_20231101 >									
	//        < N913rq7T6D56ty2eagWNx8wl8TdPWURdLfvxjlYmKy4zTeU5iUqGQ6mOm5CT7816 >									
	//        <  u =="0.000000000000000001" : ] 000000628733730.649446000000000000 ; 000000644898789.718428000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003BF5F1D3D80997 >									
	//     < RUSS_PFXX_II_metadata_line_33_____EuroChem_Agro_doo_Beograd_20231101 >									
	//        < cOe8Rv1V9qH7VfDHSIFP7QysB4DEO74Cp3w01J39gMxpfdWsp8bwec2609YMy250 >									
	//        <  u =="0.000000000000000001" : ] 000000644898789.718428000000000000 ; 000000665838420.859239000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D809973F7FD22 >									
	//     < RUSS_PFXX_II_metadata_line_34_____EuroChem_Agro_Turkey_Tarim_Sanayi_ve_Ticaret_20231101 >									
	//        < 96U1XqijtITRKzx0bK9Ar6W5l2o47cs3b3i1YPeYgp6E3UW117oeG6KeC8ER60NC >									
	//        <  u =="0.000000000000000001" : ] 000000665838420.859239000000000000 ; 000000688891125.939819000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F7FD2241B2A19 >									
	//     < RUSS_PFXX_II_metadata_line_35_____Emerger_Fertilizantes_SA_20231101 >									
	//        < 0FEL5OL19f3BhOHihLpe1w3QB3o7d1508E13kss4hBM36drjU2Q0PSVMOq41i7Kx >									
	//        <  u =="0.000000000000000001" : ] 000000688891125.939819000000000000 ; 000000711895090.644615000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000041B2A1943E4405 >									
	//     < RUSS_PFXX_II_metadata_line_36_____EuroChem_Comercio_Produtos_Quimicos_20231101 >									
	//        < Et4bVgEfmO3sjMDdedmtclfw89h6U09kexint7SYU0ogmXaS2v69lS4egxeyUs0M >									
	//        <  u =="0.000000000000000001" : ] 000000711895090.644615000000000000 ; 000000731801854.481690000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000043E440545CA419 >									
	//     < RUSS_PFXX_II_metadata_line_37_____Fertilizantes_Tocantines_Ltda_20231101 >									
	//        < 2YRKo3iS5SO44pT5QX1i1MB5Oh7FgNwZuz3p6Er4bhaYjoNI2tJ7101kPD5JOt27 >									
	//        <  u =="0.000000000000000001" : ] 000000731801854.481690000000000000 ; 000000747236494.429365000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045CA4194743141 >									
	//     < RUSS_PFXX_II_metadata_line_38_____EuroChem_Agro_Trading_Shenzhen_20231101 >									
	//        < v338l9huYbd9S05tF0149TfFHTgRSN4QsXro7NBU2Ua2G5Se0DMsgNl62926ldGt >									
	//        <  u =="0.000000000000000001" : ] 000000747236494.429365000000000000 ; 000000763409107.194679000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000474314148CDEAF >									
	//     < RUSS_PFXX_II_metadata_line_39_____EuroChem_Trading_RUS_20231101 >									
	//        < 67zk8N7ELys9QZ2Ibvn2JGkoLlk9cWg1biMIudkNNVP5C4840u1xK0817J23uTqH >									
	//        <  u =="0.000000000000000001" : ] 000000763409107.194679000000000000 ; 000000780980945.543265000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048CDEAF4A7AEAF >									
	//     < RUSS_PFXX_II_metadata_line_40_____AgroCenter_EuroChem_Ukraine_20231101 >									
	//        < 3Ww1CZ746w0st78NwFi8T068foLCQ4KcE93TKd3VN80ahs1v4c98iud78mgr5Zu2 >									
	//        <  u =="0.000000000000000001" : ] 000000780980945.543265000000000000 ; 000000802492326.563360000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A7AEAF4C88191 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}