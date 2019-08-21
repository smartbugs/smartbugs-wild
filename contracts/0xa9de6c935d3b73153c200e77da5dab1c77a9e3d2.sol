pragma solidity 		^0.4.25	;						
									
contract	EUROSIBENERGO_PFXXI_III_883				{				
									
	mapping (address => uint256) public balanceOf;								
									
	string	public		name =	"	EUROSIBENERGO_PFXXI_III_883		"	;
	string	public		symbol =	"	EUROSIBENERGO_PFXXI_III_IMTD		"	;
	uint8	public		decimals =		18			;
									
	uint256 public totalSupply =		941084866216900000000000000					;	
									
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
// }									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < EUROSIBENERGO_PFXXI_III_metadata_line_1_____Irkutskenergo_JSC_20260321 >									
//        < 6A4wl0r8z81fk8agd00CJTP71Tdlh6o9PMYI77vwJi371Qlcv9jE9ft66DJTW0y1 >									
//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000035951382.787753900000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000000000000036DB82 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_2_____Irkutskenergo_PCI_20260321 >									
//        < I2E2sO8yz8Ro3R5e59ECFuJNkN8Xx1DQ0V8n4JbNk8K6Xn1U7qWN36t1hT9uSMik >									
//        <  u =="0.000000000000000001" : ] 000000035951382.787753900000000000 ; 000000061636490.104548400000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000000036DB825E0CC1 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_3_____Irkutskenergo_PCI_Bratsk_20260321 >									
//        < uTnZ5Ey5YAOJdie9oxRAdMh29ki0265OtuBLOy979Tv24Y9u4ZhoL6eQ3DfiGGmE >									
//        <  u =="0.000000000000000001" : ] 000000061636490.104548400000000000 ; 000000086289833.649846000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000005E0CC183AAF7 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_4_____Irkutskenergo_PCI_Ust_Ilimsk_20260321 >									
//        < upN90365L371DOpbnq2eDX1dnO37GmLouVJski1fWF7eu1QphzV035xtb2S4iBEZ >									
//        <  u =="0.000000000000000001" : ] 000000086289833.649846000000000000 ; 000000113336197.695845000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000000083AAF7ACEFF4 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_5_____Irkutskenergo_Bratsk_org_spe_20260321 >									
//        < wH30md2HCjrUzdv14i0BQ1d3br45NS12wLORw8gD7qWcr2YxdpNo7l093o4a09Uh >									
//        <  u =="0.000000000000000001" : ] 000000113336197.695845000000000000 ; 000000132603989.490905000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000000ACEFF4CA566F >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_6_____Irkutskenergo_Ust_Ilimsk_org_spe_20260321 >									
//        < Ndfmdp05X01lGqcPf803eK7aTM6a6xKUlPpWX8H5eJWkYbX3V28H4e1uiNwlbr1Y >									
//        <  u =="0.000000000000000001" : ] 000000132603989.490905000000000000 ; 000000148952928.641163000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000000CA566FE348BD >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_7_____Oui_Energo_Limited_s_China_Yangtze_Power_Company_20260321 >									
//        < 9i98W85aOXFX34K10ZRAG3Yf2jsZylG68LwR4Lovgmay8Y9F1r9RH420rlajV4BP >									
//        <  u =="0.000000000000000001" : ] 000000148952928.641163000000000000 ; 000000170819949.081077000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000000E348BD104A68B >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_8_____China_Yangtze_Power_Company_limited_20260321 >									
//        < Z8gPubI7cZvwSMS6Q9042afik6piRBNdGx678R2RMGkULzZ73irBQtk72Tlx3j56 >									
//        <  u =="0.000000000000000001" : ] 000000170819949.081077000000000000 ; 000000186884683.790622000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000104A68B11D29D4 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_9_____Three_Gorges_Electric_Power_Company_Limited_20260321 >									
//        < DuL10oerxgCP362ff0oVUp9i25TzHxrf0L42EgX72oDq77CIn0230Tl2NWep5t3y >									
//        <  u =="0.000000000000000001" : ] 000000186884683.790622000000000000 ; 000000207033912.755538000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000011D29D413BE89F >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_10_____Beijing_Yangtze_Power_Innovative_Investment_Management_Company_Limited_20260321 >									
//        < Y82TNgxT0i6O25PM73WcxX9FXv984G06Ej928fdfE6ycxHbnbLXHER7199YqG48d >									
//        <  u =="0.000000000000000001" : ] 000000207033912.755538000000000000 ; 000000236348103.441913000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000013BE89F168A37A >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < EUROSIBENERGO_PFXXI_III_metadata_line_11_____Three_Gorges_Jinsha_River_Chuanyun_Hydropower_Development_Company_Limited_20260321 >									
//        < cz1RZm73M4g5y7M7dqTB5ONVF0N6Po829NhZGkfP68W48w13IK283I45A9A2pVEK >									
//        <  u =="0.000000000000000001" : ] 000000236348103.441913000000000000 ; 000000253865229.824556000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000168A37A1835E1B >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_12_____Changdian_Capital_Holding_Company_Limited_20260321 >									
//        < 7334f5S1fjjqWx3Kf1D2sa590ErfNO5JkX9976blN486dw8eC6a97FfumsBYcPc1 >									
//        <  u =="0.000000000000000001" : ] 000000253865229.824556000000000000 ; 000000274749318.963427000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000001835E1B1A33BF4 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_13_____Eurosibenergo_OJSC_20260321 >									
//        < 2ieh64jM46r0aNO3TP1s50htt912UJynbFVyRbu6HH2gG2g2Oaeb650Jvvr4Lfmd >									
//        <  u =="0.000000000000000001" : ] 000000274749318.963427000000000000 ; 000000299541136.143507000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000001A33BF41C91042 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_14_____Baikalenergo_JSC_20260321 >									
//        < 0YuMk8k31GyT4xATTCPvAv57eyku1nNI7A17Mt6lq54jTTT5IWMvW79fV688f35y >									
//        <  u =="0.000000000000000001" : ] 000000299541136.143507000000000000 ; 000000318313158.976515000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000001C910421E5B514 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_15_____Sayanogorsk_Teploseti_20260321 >									
//        < Mq5k0bylS04211Uz74uo1b0givJ8cby3PL72FGN44kvrZU1WF1mOMuCl0NU56m3y >									
//        <  u =="0.000000000000000001" : ] 000000318313158.976515000000000000 ; 000000349531222.850533000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000001E5B51421557A2 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_16_____China_Yangtze_Power_International_Hong_Kong_Company_Limited_20260321 >									
//        < tO5ItRZY25dwzd0HdDuZjWJK0CGjw77mIvcVYfvg0I2uKtBzV8nu4m8bB5iEP0Yf >									
//        <  u =="0.000000000000000001" : ] 000000349531222.850533000000000000 ; 000000370324484.048062000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000021557A22351200 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_17_____Fujian_Electric_Distribution_Sale_COmpany_Limited_20260321 >									
//        < 3IeK0O0T5InVagAt8P9z1tBy5M0GX3S8N838rML9zfne5D5t7KWiWlZf07X9lk6V >									
//        <  u =="0.000000000000000001" : ] 000000370324484.048062000000000000 ; 000000393177810.176107000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000002351200257F115 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_18_____Bohai_Ferry_Group_20260321 >									
//        < zAjm26a2cC31Qy0vZ8r6SWAziD48OkdbSdlOq2U330h8b1M8kCl979rJJXJ4Y4m7 >									
//        <  u =="0.000000000000000001" : ] 000000393177810.176107000000000000 ; 000000422476580.147117000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000257F115284A5EA >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_19_____Eurosibenergo_OJSC_20260321 >									
//        < 36bjH7f422lPGJ9a7Gnc9o0t4BL9M0y976tXM395WcVwDHU2CYe6Gjsiuix5GJn4 >									
//        <  u =="0.000000000000000001" : ] 000000422476580.147117000000000000 ; 000000446314469.964611000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000284A5EA2A90597 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_20_____Krasnoyarskaya_HPP_20260321 >									
//        < uH06Io3m0pSs6edoD9h64967bkgU2Zg13k8JdHLM58Nd0UIMocZ956kk22j07ir8 >									
//        <  u =="0.000000000000000001" : ] 000000446314469.964611000000000000 ; 000000462661106.000382000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000002A905972C1F6FF >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < EUROSIBENERGO_PFXXI_III_metadata_line_21_____ERA_Group_OJSC_20260321 >									
//        < j2p24F78C2U95TPZ50yhmnBbrRbSE8w5O0i5qo9Ec4mTJy7D9kPowo9N7x1vNMVi >									
//        <  u =="0.000000000000000001" : ] 000000462661106.000382000000000000 ; 000000490848728.836368000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000002C1F6FF2ECF9C9 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_22_____Russky_Kremny_LLC_20260321 >									
//        < cpJP5e5o9S96Lzkef8h5WTQJN5elev72C6qz1LdC0h88h0pxhP7vug7Apco856i4 >									
//        <  u =="0.000000000000000001" : ] 000000490848728.836368000000000000 ; 000000510347180.036768000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000002ECF9C930ABA5E >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_23_____Avtozavodskaya_org_spe_20260321 >									
//        < CesL2X8PH3KtrAORhRj00Qyicn901AgWrJYXe4G0ZM0v788PE7zozev17xD9Soix >									
//        <  u =="0.000000000000000001" : ] 000000510347180.036768000000000000 ; 000000526713003.668519000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000030ABA5E323B344 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_24_____Irkutsk_Electric_Grid_Company_20260321 >									
//        < E18E91bJWz3V91jmc74Jq58eeq09W952mJg67nmpV8BWOKAkboHtmNL9bcSo72C8 >									
//        <  u =="0.000000000000000001" : ] 000000526713003.668519000000000000 ; 000000546973637.975719000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000323B3443429D94 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_25_____Eurosibenergo_OJSC_20260321 >									
//        < 3SvjDWG6a3AjA6AKV84QFf8r1w6BBIe4RzSj57s51z8T97sGE7DLSh0O0Jgphw9V >									
//        <  u =="0.000000000000000001" : ] 000000546973637.975719000000000000 ; 000000582544806.727247000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000003429D94378E491 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_26_____Eurosibenergo_LLC_distributed_generation_20260321 >									
//        < pvxKFDdFP0KW9hbxJVFw3RIppIw9X3P93Vg1v5S60HH76d2V76RZcXXFohGjJ2Jc >									
//        <  u =="0.000000000000000001" : ] 000000582544806.727247000000000000 ; 000000609664363.359802000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000378E4913A24624 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_27_____Generatsiya_OOO_20260321 >									
//        < 7QCWx8q6C5aTmhU16gmB66a5CEm068lQRS1JkGv6Bg4Dsw613Mxf8FDrv3Rcv99e >									
//        <  u =="0.000000000000000001" : ] 000000609664363.359802000000000000 ; 000000629532648.517008000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000003A246243C09731 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_28_____Eurosibenergo_LLC_distributed_gen_NIZHEGORODSKIY_20260321 >									
//        < r88FX8A3v2fWdY87d0s4jeRqEoKRzM5wA48IAX1r7KLBsCDIt72trT95u49b5Uq9 >									
//        <  u =="0.000000000000000001" : ] 000000629532648.517008000000000000 ; 000000653553960.968285000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000003C097313E53E84 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_29_____Angara_Yenisei_org_spe_20260321 >									
//        < zqt59R97H91mIV6GAtCTN04Od8OE38A0RkbOyeA3a0P36FkXCvUuhgeuPx4GQs7p >									
//        <  u =="0.000000000000000001" : ] 000000653553960.968285000000000000 ; 000000686141397.380132000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000003E53E84416F7FC >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_30_____Yuzhno_Yeniseisk_org_spe_20260321 >									
//        < ba9Z379Rosdqx3j3iepfGUY940GwsC4Hid25LUM890VRoplf53F66UAe49AL22a8 >									
//        <  u =="0.000000000000000001" : ] 000000686141397.380132000000000000 ; 000000707195894.789063000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000416F7FC4371865 >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
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
//     < EUROSIBENERGO_PFXXI_III_metadata_line_31_____Teploseti_LLC_20260321 >									
//        < mARQkqlFn0UmFGbmS93gQL23j762Ue87s1YUnrfh88Po53qq0s5glnTGijoVJK3o >									
//        <  u =="0.000000000000000001" : ] 000000707195894.789063000000000000 ; 000000723864371.689881000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000043718654508785 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_32_____Eurosibenergo_Engineering_LLC_20260321 >									
//        < syUxL6dxl6GGh6sNROKIj28C5Cc9oTXVPa51C4O4esN5IgZ4RUpr0WxLz4lFNj11 >									
//        <  u =="0.000000000000000001" : ] 000000723864371.689881000000000000 ; 000000743451767.700430000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000450878546E6AD9 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_33_____EurosibPower_Engineering_20260321 >									
//        < ZegnIK36PGBpH5D0BupIHB521zu34Ij2Ro9B1IBct2jis5d713AlKKPNbMH95U2Q >									
//        <  u =="0.000000000000000001" : ] 000000743451767.700430000000000000 ; 000000767135129.216352000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000046E6AD94928E29 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_34_____Eurosibenergo_hydrogeneration_LLC_20260321 >									
//        < kQUi33gj2StW6zAES43u3642a1tHlOaduj1QaiNSX2W38uwdhY4IQtIu8iAcSIp9 >									
//        <  u =="0.000000000000000001" : ] 000000767135129.216352000000000000 ; 000000795262196.197842000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000004928E294BD794C >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_35_____Mostootryad_org_spe_20260321 >									
//        < de3aFeC69462mh84LTbs439v7bbtRNoT3YEAfNHa6SAI5BU1x875i70x0lbbpp5c >									
//        <  u =="0.000000000000000001" : ] 000000795262196.197842000000000000 ; 000000813827181.275075000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000004BD794C4D9CD3E >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_36_____Irkutskenergoremont_CJSC_20260321 >									
//        < u4U2ogas8B1wiJr8xbxdE3wX2PzS67f11cv65ph7TJA99NxyD26G9HlR8nFMLwhr >									
//        <  u =="0.000000000000000001" : ] 000000813827181.275075000000000000 ; 000000836630587.352741000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000004D9CD3E4FC98D3 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_37_____Irkutsk_Energy_Retail_20260321 >									
//        < fNZJpx6W645sGCS2a7Z6Xex97lkKdgKM8NzQxVG77o07l7R8k034WK52Dh1fC8s6 >									
//        <  u =="0.000000000000000001" : ] 000000836630587.352741000000000000 ; 000000865724667.659517000000000000 ] >									
//        < 0x000000000000000000000000000000000000000000000000004FC98D3528FDB3 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_38_____Iirkutskenergo_PCI_Irkutsk_20260321 >									
//        < FeFj18gGQGF294trUP5exGyMoRi1u2d39NQ74NAZ20pQKfk5RKKbr9z2Hao5EfB9 >									
//        <  u =="0.000000000000000001" : ] 000000865724667.659517000000000000 ; 000000890065963.993296000000000000 ] >									
//        < 0x00000000000000000000000000000000000000000000000000528FDB354E2204 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_39_____Iirkutskenergo_Irkutsk_org_spe_20260321 >									
//        < zgd90M156t6yl1KM782S0X5Z49733lfqHlV20PRH9a4Ylym7fr20LXh3CGrbU2Gg >									
//        <  u =="0.000000000000000001" : ] 000000890065963.993296000000000000 ; 000000912119068.921505000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000054E220456FC883 >									
//     < EUROSIBENERGO_PFXXI_III_metadata_line_40_____Monchegorskaya_org_spe_20260321 >									
//        < s1Ow1C05gJ0w2bi6SpnK81EAJ5HAmZ23S3ilcsLj95ZwFzsRfk5JJ09v09sxyLQR >									
//        <  u =="0.000000000000000001" : ] 000000912119068.921505000000000000 ; 000000941084866.216900000000000000 ] >									
//        < 0x0000000000000000000000000000000000000000000000000056FC88359BFB47 >									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
									
}