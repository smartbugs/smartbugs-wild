pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFIII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFIII_I_883		"	;
		string	public		symbol =	"	NDRV_PFIII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		773897503952870000000000000					;	
										
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
	//     < NDRV_PFIII_I_metadata_line_1_____talanx_20211101 >									
	//        < TuzMJmRn9HxgTPJB88bB4t9CF8XVVHU9p1njmZSGVezuM83Yxgh9SF098LFWpwT8 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000021148422.606223100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000020451A >									
	//     < NDRV_PFIII_I_metadata_line_2_____hdi haftpflichtverband der deutsch_indus_versicherungsverein gegenseitigkeit_20211101 >									
	//        < jcdux7VSlZT66MMik9T9F6DMv2x33IJ1h1CrWhCdfWzSa52k2j5K030Zl7V847Jn >									
	//        <  u =="0.000000000000000001" : ] 000000021148422.606223100000000000 ; 000000045844903.391986100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000020451A45F42A >									
	//     < NDRV_PFIII_I_metadata_line_3_____hdi global se_20211101 >									
	//        < 759i0KGR2Z5P51q9p95qfmMNftz8ZoPZOc7D2Fn8s5H3vs1V3c872c8M0Tbi7MW6 >									
	//        <  u =="0.000000000000000001" : ] 000000045844903.391986100000000000 ; 000000071245089.939213400000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000045F42A6CB61D >									
	//     < NDRV_PFIII_I_metadata_line_4_____hdi global network ag_20211101 >									
	//        < 8qJF5A6IAggD6A1L55925AQ5GsijkHbaK2JbgfhtgrOvTRqR15z74H6EN8Hdi7mJ >									
	//        <  u =="0.000000000000000001" : ] 000000071245089.939213400000000000 ; 000000086531749.483337300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006CB61D840977 >									
	//     < NDRV_PFIII_I_metadata_line_5_____hdi global network ag hdi global seguros sa_20211101 >									
	//        < dNtpwXP5vaOPsNX2kOH03mD7jib91q9B544oF9Nj4p9I1d5H1OmPAr1HVg2ngT6b >									
	//        <  u =="0.000000000000000001" : ] 000000086531749.483337300000000000 ; 000000105440637.070118000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000840977A0E3C0 >									
	//     < NDRV_PFIII_I_metadata_line_6_____hdi global se hdi-gerling industrial insurance company_20211101 >									
	//        < 7ChX283G07h33T03MKImqKCl3QnR46O74i0z3Nf8ZXLb6XH3IzPquTLYEA1Ow0PJ >									
	//        <  u =="0.000000000000000001" : ] 000000105440637.070118000000000000 ; 000000124792118.012314000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000A0E3C0BE6AEC >									
	//     < NDRV_PFIII_I_metadata_line_7_____hdi_gerling industrial insurance company uk branch_20211101 >									
	//        < 3s5vR8Fsy18T8Cto1TUiW885HPcXNG0xv4903K64d352RKOgiYnWt5Ys3DJpcAG4 >									
	//        <  u =="0.000000000000000001" : ] 000000124792118.012314000000000000 ; 000000143534413.199357000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000BE6AECDB0421 >									
	//     < NDRV_PFIII_I_metadata_line_8_____hdi global se hdi_gerling de méxico seguros sa_20211101 >									
	//        < 5EsyNqbAyz82hffp66w7208xmSnMuPFiS0Yo929498L1yJZr7aK3HJsGGs2u4FM7 >									
	//        <  u =="0.000000000000000001" : ] 000000143534413.199357000000000000 ; 000000156639457.286751000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000DB0421EF034A >									
	//     < NDRV_PFIII_I_metadata_line_9_____hdi global se spain branch_20211101 >									
	//        < k5lB54b3w721HWj7M6cyUXYTj6iF1Ieb2WFbwc8p6Je8whZa64F8v5WF4wZUy3wI >									
	//        <  u =="0.000000000000000001" : ] 000000156639457.286751000000000000 ; 000000177687673.494503000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EF034A10F213F >									
	//     < NDRV_PFIII_I_metadata_line_10_____hdi global se nassau verzekering maatschappij nv_20211101 >									
	//        < 5f5smNDs7nVAJ6v7ehdW54inN4337aDaSijdabjFf1i2c7UziIyGFT6JGUPFpBd7 >									
	//        <  u =="0.000000000000000001" : ] 000000177687673.494503000000000000 ; 000000198824716.845653000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010F213F12F61E8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIII_I_metadata_line_11_____hdi_gerling industrie versicherung ag_20211101 >									
	//        < FNdC6052hK22eVH2OTAp2m9xMw57vU419GimpA19xeP8O4rVxX6MP2y7h9Z28T90 >									
	//        <  u =="0.000000000000000001" : ] 000000198824716.845653000000000000 ; 000000216326892.089863000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012F61E814A16B1 >									
	//     < NDRV_PFIII_I_metadata_line_12_____hdi global se gerling norge as_20211101 >									
	//        < uZzVGB8c83d6ScJyl1xXK70r9Oj4MNeq8DOo08OM9AP0yI4M8adBnaQh3VxY7hP9 >									
	//        <  u =="0.000000000000000001" : ] 000000216326892.089863000000000000 ; 000000240650317.689174000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014A16B116F3408 >									
	//     < NDRV_PFIII_I_metadata_line_13_____hdi_gerling industrie versicherung ag hellas branch_20211101 >									
	//        < T9CUVqXxh14SB58tp2y5P1YXOch4sq6MZ4yd5gQqTiJEMaCeR6O5c032tipbNd0F >									
	//        <  u =="0.000000000000000001" : ] 000000240650317.689174000000000000 ; 000000266836821.570656000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016F34081972922 >									
	//     < NDRV_PFIII_I_metadata_line_14_____hdi_gerling verzekeringen nv_20211101 >									
	//        < 0W7Du2d812u9j9RR2a49q4BBya3l4j8xbs6yyi4RlwJ4wXjVhhP2GY2FQ56R3RH7 >									
	//        <  u =="0.000000000000000001" : ] 000000266836821.570656000000000000 ; 000000284556638.409315000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019729221B232F0 >									
	//     < NDRV_PFIII_I_metadata_line_15_____hdi_gerling verzekeringen nv hj roelofs_assuradeuren bv_20211101 >									
	//        < qec3vN9aTV56W9dHtoMt5z36531h8EkZZC04PJB2YKYTYU7mS6xa5P8ja3i5GrOd >									
	//        <  u =="0.000000000000000001" : ] 000000284556638.409315000000000000 ; 000000306180182.397314000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B232F01D331A2 >									
	//     < NDRV_PFIII_I_metadata_line_16_____hdi global sa ltd_20211101 >									
	//        < 6L3n2MPh43QiJJ1AJTTDIeCq5AhXGEbtlrX5LwWq0n8jWEi0E9oi0ZIIsSrO9u80 >									
	//        <  u =="0.000000000000000001" : ] 000000306180182.397314000000000000 ; 000000330320711.742780000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D331A21F80787 >									
	//     < NDRV_PFIII_I_metadata_line_17_____Hannover Re_20211101 >									
	//        < bp5g8dbesVe032n966PC0S3Uq5G2P6w9P0CQi48cPJY5jmFPrv3Mvv218499y049 >									
	//        <  u =="0.000000000000000001" : ] 000000330320711.742780000000000000 ; 000000352033415.376750000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F80787219290E >									
	//     < NDRV_PFIII_I_metadata_line_18_____hdi versicherung ag_20211101 >									
	//        < 2tDnT2xSOfAfAs087R3cwcLW5ubGoeH3eQG0411P0AjI2y015VA1R1sB7u84hq6i >									
	//        <  u =="0.000000000000000001" : ] 000000352033415.376750000000000000 ; 000000372310708.227819000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000219290E23819DF >									
	//     < NDRV_PFIII_I_metadata_line_19_____talanx asset management gmbh_20211101 >									
	//        < WIrLo75GW28kM3Z3ueV3DLrUhezr3qK0L85vJUZdX27I1VJ8tIUXde0cRV7hjaAN >									
	//        <  u =="0.000000000000000001" : ] 000000372310708.227819000000000000 ; 000000388189299.216205000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000023819DF2505472 >									
	//     < NDRV_PFIII_I_metadata_line_20_____talanx immobilien management gmbh_20211101 >									
	//        < 3n19td1R1UST6Tbdoe70JRy60hw3sYV31uvzHlb393CwJltoj34tyl7s7taD58pg >									
	//        <  u =="0.000000000000000001" : ] 000000388189299.216205000000000000 ; 000000403937255.942329000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025054722685BFE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIII_I_metadata_line_21_____talanx ampega investment gmbh_20211101 >									
	//        < g2W714Im4URzI7JO7oeyQGfcj2x7E8tTe85KcgQmXFz62g7QdEj00JS0QySF55a2 >									
	//        <  u =="0.000000000000000001" : ] 000000403937255.942329000000000000 ; 000000423484465.599918000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002685BFE2862F9F >									
	//     < NDRV_PFIII_I_metadata_line_22_____talanx hdi pensionskasse ag_20211101 >									
	//        < Mr061mJJ4xrxn1RIZpLk8RW8NN7lXqnb7uS55ALV3v1Hv0FI0So4pqW3OF5EZmXP >									
	//        <  u =="0.000000000000000001" : ] 000000423484465.599918000000000000 ; 000000445699417.851273000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002862F9F2A81556 >									
	//     < NDRV_PFIII_I_metadata_line_23_____talanx international ag_20211101 >									
	//        < 77Vhq7mqq3eu3RtXB8FMswhjXs78zPb6FtV3rRf2UGnF2oQo97Gl2ofw1bQZTZ99 >									
	//        <  u =="0.000000000000000001" : ] 000000445699417.851273000000000000 ; 000000459175432.046564000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A815562BCA567 >									
	//     < NDRV_PFIII_I_metadata_line_24_____talanx targo versicherung ag_20211101 >									
	//        < ilg5VS0rR9oE2T6V64cVn1QQplkAoktOEanuw7v5NRs6k59BdrgWpW0BzH4j2lGe >									
	//        <  u =="0.000000000000000001" : ] 000000459175432.046564000000000000 ; 000000479700484.424463000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BCA5672DBF700 >									
	//     < NDRV_PFIII_I_metadata_line_25_____talanx pb lebensversicherung ag_20211101 >									
	//        < da61Qln6i96Z60MQokbix2K5OOiav8j5HYV3noX4k76AH7641dn6dt4sR6BA5du9 >									
	//        <  u =="0.000000000000000001" : ] 000000479700484.424463000000000000 ; 000000504725859.313524000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DBF700302268A >									
	//     < NDRV_PFIII_I_metadata_line_26_____talanx targo lebensversicherung ag_20211101 >									
	//        < W4Ccj33B00TQkYXabPIZp2jWT92NV1gC6T9q35gbl03Huu6GwxIoQ4q19pSYe71i >									
	//        <  u =="0.000000000000000001" : ] 000000504725859.313524000000000000 ; 000000520527700.320618000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000302268A31A4322 >									
	//     < NDRV_PFIII_I_metadata_line_27_____talanx hdi global insurance company_20211101 >									
	//        < 855v35x08wOxW4sq4yL021wGZ3wEsr0z4ed791534c8XFR3q9K29HLpUmu6B68pa >									
	//        <  u =="0.000000000000000001" : ] 000000520527700.320618000000000000 ; 000000540731337.436540000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000031A4322339172E >									
	//     < NDRV_PFIII_I_metadata_line_28_____talanx civ life russia_20211101 >									
	//        < cXmRxW3R28wtOgXm5kEJ79W55K444DJmgMIawr1S4Tp8ht5h7G8iWju4gZMJnB17 >									
	//        <  u =="0.000000000000000001" : ] 000000540731337.436540000000000000 ; 000000558593530.892629000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000339172E3545899 >									
	//     < NDRV_PFIII_I_metadata_line_29_____talanx reinsurance ireland limited_20211101 >									
	//        < 00M4IIaxer3q2w7108jI27XZa0Yyh5gq1Xw94ZgD4FXkpReKD41I0WW6fic6539l >									
	//        <  u =="0.000000000000000001" : ] 000000558593530.892629000000000000 ; 000000575174453.571328000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000354589936DA585 >									
	//     < NDRV_PFIII_I_metadata_line_30_____talanx deutschland ag_20211101 >									
	//        < wm10ir5st1yBm6T4Vr4e4Secihe6sucVUz9xz0OToh64B0XFiL44hJ62EvZww222 >									
	//        <  u =="0.000000000000000001" : ] 000000575174453.571328000000000000 ; 000000595620802.175970000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036DA58538CD860 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFIII_I_metadata_line_31_____talanx service ag_20211101 >									
	//        < u5mkQS28ziLvxgIG40tH5Yoa82T458W1M9c9WKri9S85604992H13vQweD0c346J >									
	//        <  u =="0.000000000000000001" : ] 000000595620802.175970000000000000 ; 000000609175243.024708000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000038CD8603A18714 >									
	//     < NDRV_PFIII_I_metadata_line_32_____talanx service ag hdi risk consulting gmbh_20211101 >									
	//        < 3Hs1b4sAAXI2uSoUS82Q45VwxQGt0fx1iWAwB4r9cArFO6vB0cKNV7Kk4mwk7n77 >									
	//        <  u =="0.000000000000000001" : ] 000000609175243.024708000000000000 ; 000000623934423.745053000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A187143B80C62 >									
	//     < NDRV_PFIII_I_metadata_line_33_____talanx deutschland bancassurance kundenservice gmbh_20211101 >									
	//        < zKE3366208xJHTu8Ku8Yjn6Fo10H7gZFI11P5di1VW6h93RhwlWiV6PHX64aYIhH >									
	//        <  u =="0.000000000000000001" : ] 000000623934423.745053000000000000 ; 000000638615583.539703000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003B80C623CE7336 >									
	//     < NDRV_PFIII_I_metadata_line_34_____magyar posta eletbiztosito zrt_20211101 >									
	//        < CTBP8jv03acDMOiiYD5W5arqcfoW3EErcW0Ql3y6H738KG4B9DM2D60m3wh3h9ZE >									
	//        <  u =="0.000000000000000001" : ] 000000638615583.539703000000000000 ; 000000653950621.042392000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003CE73363E5D976 >									
	//     < NDRV_PFIII_I_metadata_line_35_____magyar posta biztosito zrt_20211101 >									
	//        < QH3U1m91278jZD1QOtLXY2TVE4b30n7Gn3v7s894OQ9LptuNTcu1BZ0cRw3LT58s >									
	//        <  u =="0.000000000000000001" : ] 000000653950621.042392000000000000 ; 000000669301477.294780000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E5D9763FD45E4 >									
	//     < NDRV_PFIII_I_metadata_line_36_____civ hayat sigorta as_20211101 >									
	//        < 8BHcS1tawnTvm5GjyE4XB1AVetFe22y7OBg09rWI1Oq68vgqVEuEIIGDU3uw4L1T >									
	//        <  u =="0.000000000000000001" : ] 000000669301477.294780000000000000 ; 000000695081584.636501000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003FD45E44249C3E >									
	//     < NDRV_PFIII_I_metadata_line_37_____lifestyle protection lebensversicherung ag_20211101 >									
	//        < c9AykXuCVpaP6wnKRCtFKiJHC2M0if49lW146Kdq76jzOFwU8U4rB0Te08qX88T8 >									
	//        <  u =="0.000000000000000001" : ] 000000695081584.636501000000000000 ; 000000713056381.008263000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004249C3E44009A6 >									
	//     < NDRV_PFIII_I_metadata_line_38_____pbv lebensversicherung ag_20211101 >									
	//        < Vb4Ip3F3cQsVu0Zs0f5K9n6bgAaHUrNIipCSm8oLnRlhU189DyAGeJom6CJCuOnJ >									
	//        <  u =="0.000000000000000001" : ] 000000713056381.008263000000000000 ; 000000733543358.743836000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000044009A645F4C60 >									
	//     < NDRV_PFIII_I_metadata_line_39_____generali colombia seguros generales sa_20211101 >									
	//        < f00jS74sq3xtjrzj56L417pto1Tv5kt83ln7iBHYE206CmAq6NQum4bGCQbF4d9t >									
	//        <  u =="0.000000000000000001" : ] 000000733543358.743836000000000000 ; 000000753484537.581355000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045F4C6047DB9E6 >									
	//     < NDRV_PFIII_I_metadata_line_40_____generali colombia vida sa_20211101 >									
	//        < 4xRYi15H0aeImyv1gXR7S3Z9C6D20ZJ0p33d9F512sN5bqY528EfZXWIG1jVw2W5 >									
	//        <  u =="0.000000000000000001" : ] 000000753484537.581355000000000000 ; 000000773897503.952870000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047DB9E649CDFB6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}