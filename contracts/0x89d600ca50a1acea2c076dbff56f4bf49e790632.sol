pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFIX_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFIX_II_883		"	;
		string	public		symbol =	"	RUSS_PFIX_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		820955249671688000000000000					;	
										
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
	//     < RUSS_PFIX_II_metadata_line_1_____POLYUS_GOLD_20231101 >									
	//        < lHsPbRamU2kg1KvInBS91OrzqdNKLAShV86Of2eXFd8OSZSr28KiwQNMc6Qa1UVz >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000023576883.037932300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000023F9B8 >									
	//     < RUSS_PFIX_II_metadata_line_2_____POLYUS_GOLD_GBP_20231101 >									
	//        < 2lw7N8Q8vLXn087973Ha6WIdy2WZa16pF76byaVJ6H63cu1e6yVxTr946R0RiSrv >									
	//        <  u =="0.000000000000000001" : ] 000000023576883.037932300000000000 ; 000000046834747.684432200000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000023F9B84776D3 >									
	//     < RUSS_PFIX_II_metadata_line_3_____POLYUS_GOLD_USD_20231101 >									
	//        < hANgoP6iGXVXeauxohP7ej8dP01WZ0716Y3Qc6l4dK0YsTV21m73p33C578BNalk >									
	//        <  u =="0.000000000000000001" : ] 000000046834747.684432200000000000 ; 000000071292497.409658300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004776D36CC8A2 >									
	//     < RUSS_PFIX_II_metadata_line_4_____POLYUS_KRASNOYARSK_20231101 >									
	//        < H55khjs3CTq39ixg2G6AfO9Mw2QfRDCpY981wN9OxJRXowr1Tj86OCuM4s8vL4b0 >									
	//        <  u =="0.000000000000000001" : ] 000000071292497.409658300000000000 ; 000000090483610.340555300000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000006CC8A28A1129 >									
	//     < RUSS_PFIX_II_metadata_line_5_____POLYUS_FINANCE_PLC_20231101 >									
	//        < 1PCxDt2oHSKfO0b53Y8Q1K0O96oK3E40v6l973r9qTsq9c375Bu7M39HNFO73R5j >									
	//        <  u =="0.000000000000000001" : ] 000000090483610.340555300000000000 ; 000000112566355.119720000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000008A1129ABC33C >									
	//     < RUSS_PFIX_II_metadata_line_6_____POLYUS_FINANS_FI_20231101 >									
	//        < 9HVNfjUhx08sv5ARz8EscHx6BDuhHZuQTBxf1pb1r9ucp254w3NUQ0ufOcnpHSX4 >									
	//        <  u =="0.000000000000000001" : ] 000000112566355.119720000000000000 ; 000000132126921.407658000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000ABC33CC99C14 >									
	//     < RUSS_PFIX_II_metadata_line_7_____POLYUS_FINANS_FII_20231101 >									
	//        < 2MSjFJS3oB585J6GS506rCW92bsaqr7f84ME346Dnrqq2t2bj4908WN0VAE26gkS >									
	//        <  u =="0.000000000000000001" : ] 000000132126921.407658000000000000 ; 000000152929328.837520000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000C99C14E95A05 >									
	//     < RUSS_PFIX_II_metadata_line_8_____POLYUS_FINANS_FIII_20231101 >									
	//        < H58LmUoh9Jz4138Ko0V8Wf94480SMDNH7Y9E2sj7D4i8D9yf6o7d27x60mfsAmE0 >									
	//        <  u =="0.000000000000000001" : ] 000000152929328.837520000000000000 ; 000000170225687.068752000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000E95A05103BE69 >									
	//     < RUSS_PFIX_II_metadata_line_9_____POLYUS_FINANS_FIV_20231101 >									
	//        < XCwRdER01jcF0VBDeS9foKzDDL55fnK6q2s824r4yj4w4dy8dk5keY92kF3XS08E >									
	//        <  u =="0.000000000000000001" : ] 000000170225687.068752000000000000 ; 000000190388078.185847000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000103BE691228258 >									
	//     < RUSS_PFIX_II_metadata_line_10_____POLYUS_FINANS_FV_20231101 >									
	//        < vo0N5kkB5516qk896NgUU0Tz0mp46bMUN0bJX9w4gQYNRhOJWoiXCucAb1L3226g >									
	//        <  u =="0.000000000000000001" : ] 000000190388078.185847000000000000 ; 000000213827068.132007000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012282581464633 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIX_II_metadata_line_11_____POLYUS_FINANS_FVI_20231101 >									
	//        < m4qE81bCxQJDCMfoGkFtC3oeFQMj0iKiH0zhIvTXL40jQGlRGSR3J30YgJIZU93I >									
	//        <  u =="0.000000000000000001" : ] 000000213827068.132007000000000000 ; 000000231210195.544194000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001464633160CC7C >									
	//     < RUSS_PFIX_II_metadata_line_12_____POLYUS_FINANS_FVII_20231101 >									
	//        < NPJ3SHBcet7qiJC6zPhifz15u0p47y73RsL8MbzcQIS4uOX7q66LpGrm75L3507E >									
	//        <  u =="0.000000000000000001" : ] 000000231210195.544194000000000000 ; 000000255359686.727745000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000160CC7C185A5E1 >									
	//     < RUSS_PFIX_II_metadata_line_13_____POLYUS_FINANS_FVIII_20231101 >									
	//        < p0G5Sdyv16JOTLR2f3gpb5vL9o21Kt1KENSDXua879eD1d6rL9GjBz2Wk2uJK0xn >									
	//        <  u =="0.000000000000000001" : ] 000000255359686.727745000000000000 ; 000000271863638.678007000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000185A5E119ED4BC >									
	//     < RUSS_PFIX_II_metadata_line_14_____POLYUS_FINANS_FIX_20231101 >									
	//        < 575j0smTT72EaI0fz88Ew5Mn20uF1kGumdg3x0Jdqv3SEXagg3Gv6Ut38e088dK8 >									
	//        <  u =="0.000000000000000001" : ] 000000271863638.678007000000000000 ; 000000292589000.298935000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019ED4BC1BE7494 >									
	//     < RUSS_PFIX_II_metadata_line_15_____POLYUS_FINANS_FX_20231101 >									
	//        < G7u6jU90CBZ0hBZDBDPqT3L0I8q6ypP7c6zCxtcc7v1Ccd58XRtPsispd19ZSVz3 >									
	//        <  u =="0.000000000000000001" : ] 000000292589000.298935000000000000 ; 000000317054258.830587000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001BE74941E3C952 >									
	//     < RUSS_PFIX_II_metadata_line_16_____SVETLIY_20231101 >									
	//        < d8u8PWgqFP5h2SD0DoJlrA9t84YYnBnX3l8Ax2Va36fcMY5iJiHZ4Ex276j77zci >									
	//        <  u =="0.000000000000000001" : ] 000000317054258.830587000000000000 ; 000000341747208.908181000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E3C9522097701 >									
	//     < RUSS_PFIX_II_metadata_line_17_____POLYUS_EXPLORATION_20231101 >									
	//        < 9yyuL5mC85CB35bc791AxSeZBLauD39gg7v4A66SO98R8601ZSVA2po930C6sUjw >									
	//        <  u =="0.000000000000000001" : ] 000000341747208.908181000000000000 ; 000000363698612.437342000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000209770122AF5C5 >									
	//     < RUSS_PFIX_II_metadata_line_18_____ZL_ZOLOTO_20231101 >									
	//        < KXy4y4aRvGAd4pNR295z3HgvVQK8i7aX03ZE202Lh08K7XG0xxf5PbY74V8DRpVS >									
	//        <  u =="0.000000000000000001" : ] 000000363698612.437342000000000000 ; 000000382492230.009491000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022AF5C5247A307 >									
	//     < RUSS_PFIX_II_metadata_line_19_____SK_FOUNDATION_LUZERN_20231101 >									
	//        < L3Y78672CFbATqbxf3e37YG23bumLmXAClvQYSwaoigPIPRc2bsv8l1S4G71tB0I >									
	//        <  u =="0.000000000000000001" : ] 000000382492230.009491000000000000 ; 000000402535907.508221000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000247A3072663897 >									
	//     < RUSS_PFIX_II_metadata_line_20_____SKFL_AB_20231101 >									
	//        < 097231mZMqu28q5EZ21qM1j7G1GuH8RVv4E3oGeN253j5Bd2GJZ6YDnUcfH16919 >									
	//        <  u =="0.000000000000000001" : ] 000000402535907.508221000000000000 ; 000000417991601.251390000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000266389727DCDF8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIX_II_metadata_line_21_____AB_URALKALI_20231101 >									
	//        < 8N6c9II0n0k63n4ew0NDueSJ64rOI2ByC0KI0wQdwz3VS39Zf5gx9TuTvIJMq4r6 >									
	//        <  u =="0.000000000000000001" : ] 000000417991601.251390000000000000 ; 000000440527423.372449000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027DCDF82A03106 >									
	//     < RUSS_PFIX_II_metadata_line_22_____AB_FK_ANZHI_MAKHA_20231101 >									
	//        < ivKh9UZlr9PAIm3Ld9C125ze98Mo8vV5E0g7y047WydN542Vl9dHMP51kB6P7E10 >									
	//        <  u =="0.000000000000000001" : ] 000000440527423.372449000000000000 ; 000000456338276.699619000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A031062B85124 >									
	//     < RUSS_PFIX_II_metadata_line_23_____AB_NAFTA_MOSKVA_20231101 >									
	//        < wP22GSalpd6HmzgW4C9S6twi2m39UvMJp57A4rYgj2c7c464M69b0NOl4AVGZJd0 >									
	//        <  u =="0.000000000000000001" : ] 000000456338276.699619000000000000 ; 000000481187202.402305000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002B851242DE3BC0 >									
	//     < RUSS_PFIX_II_metadata_line_24_____AB_SOYUZNEFTEEXPOR_20231101 >									
	//        < hqQtqlmmJhvJZNg35U3Ct5u245G8A0682n8Q4Spz5HNHo9VGWYytG8uekN9mapx4 >									
	//        <  u =="0.000000000000000001" : ] 000000481187202.402305000000000000 ; 000000496763946.137312000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002DE3BC02F6006B >									
	//     < RUSS_PFIX_II_metadata_line_25_____AB_FEDPROMBANK_20231101 >									
	//        < 8c27O7Mz2qB0LFI54r8SYYZcy8E8eA773EhxR26m9Lakbd5K3k87385hxQ6RWicl >									
	//        <  u =="0.000000000000000001" : ] 000000496763946.137312000000000000 ; 000000518207949.971992000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F6006B316B8FB >									
	//     < RUSS_PFIX_II_metadata_line_26_____AB_ELTAV_ELEC_20231101 >									
	//        < 0cA67Sswig9Lr0V6u93aaLHOkVqN084O3aOe7uibc48ER94k61G4U4zm7W3CA0P9 >									
	//        <  u =="0.000000000000000001" : ] 000000518207949.971992000000000000 ; 000000538617427.298658000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000316B8FB335DD6F >									
	//     < RUSS_PFIX_II_metadata_line_27_____AB_SOYUZ_FINANS_20231101 >									
	//        < iUVN7CV3758D92H5Q7Ih6U8aBOCFL9yttfm409jkuxc19CR0XdcAd71Faq4GEyzT >									
	//        <  u =="0.000000000000000001" : ] 000000538617427.298658000000000000 ; 000000556313329.245090000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000335DD6F350DDE5 >									
	//     < RUSS_PFIX_II_metadata_line_28_____AB_VNUKOVO_20231101 >									
	//        < h9j40v8ASwEmdcG5F2L3K87U9ldv7k24N88WXqT548t1cCYLxOiK85smgXVVIR23 >									
	//        <  u =="0.000000000000000001" : ] 000000556313329.245090000000000000 ; 000000574287398.893234000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000350DDE536C4B04 >									
	//     < RUSS_PFIX_II_metadata_line_29_____AB_AVTOBANK_20231101 >									
	//        < 0lcr0x4z52KzL79ZZEP3Fhh714Z0KlLe6KtdIb680Z0udA3vkfejDN2So5Wg68Yo >									
	//        <  u =="0.000000000000000001" : ] 000000574287398.893234000000000000 ; 000000593753323.532319000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000036C4B04389FEE4 >									
	//     < RUSS_PFIX_II_metadata_line_30_____AB_SMOLENSKY_PASSAZH_20231101 >									
	//        < 4S65Rs956Vg4UCKPQabJQPACM1mvOdkisXOUg78760Tq630DlULjJ0qFZhUF1sm2 >									
	//        <  u =="0.000000000000000001" : ] 000000593753323.532319000000000000 ; 000000613108571.075175000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000389FEE43A78789 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFIX_II_metadata_line_31_____MAKHA_PORT_20231101 >									
	//        < k5SDhL6Y44WzK13kO45EJ9119N395S01XB5GzBg22944xZzq7YB91RJ4p45r1XbM >									
	//        <  u =="0.000000000000000001" : ] 000000613108571.075175000000000000 ; 000000635170041.072498000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003A787893C9314C >									
	//     < RUSS_PFIX_II_metadata_line_32_____MAKHA_AIRPORT_AB_20231101 >									
	//        < 20HsTqJVcZ87B45rJNr2QKx0817Aq0kVCKrCXySPV1DHA0cPEkIDMn016dFL9bJL >									
	//        <  u =="0.000000000000000001" : ] 000000635170041.072498000000000000 ; 000000654178882.945313000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C9314C3E632A0 >									
	//     < RUSS_PFIX_II_metadata_line_33_____DAG_ORG_20231101 >									
	//        < eTP7oKK5d8CMGJ03PQ52G0gYsoBen30v1g1Qw5T2akl9K6UDc8483d4hd2BZKAH2 >									
	//        <  u =="0.000000000000000001" : ] 000000654178882.945313000000000000 ; 000000676194821.620643000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003E632A0407CA9A >									
	//     < RUSS_PFIX_II_metadata_line_34_____DAG_DAO_20231101 >									
	//        < aWxgg9p8ecwU9WxhV4emv3YY6z4aZ80Jb9c4i1hpV25oBprehdQ6Fq5XKKKBcmX0 >									
	//        <  u =="0.000000000000000001" : ] 000000676194821.620643000000000000 ; 000000695992052.866638000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000407CA9A425FFE5 >									
	//     < RUSS_PFIX_II_metadata_line_35_____DAG_DAOPI_20231101 >									
	//        < 9W0Ob42NCSo0CT70pCya7r750nXez74v00Fb1aN69AHm9eukM8kHnoLtZqpeV307 >									
	//        <  u =="0.000000000000000001" : ] 000000695992052.866638000000000000 ; 000000716035337.064357000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000425FFE5444954E >									
	//     < RUSS_PFIX_II_metadata_line_36_____DAG_DAC_20231101 >									
	//        < Si79km3Oz5X8V5yzhUEU3c2IiQGZwaAFRAZ9UWxJ72mnSr90d98u68U66GLLZDIV >									
	//        <  u =="0.000000000000000001" : ] 000000716035337.064357000000000000 ; 000000733410698.210305000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000444954E45F188E >									
	//     < RUSS_PFIX_II_metadata_line_37_____MAKHA_ORG_20231101 >									
	//        < 37hQP4fL26QVlpRhRIN2763jgF5LsJ4UyJ49A47a7us2n0839U8xaHqRc14c3Boy >									
	//        <  u =="0.000000000000000001" : ] 000000733410698.210305000000000000 ; 000000754697374.223838000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000045F188E47F93A9 >									
	//     < RUSS_PFIX_II_metadata_line_38_____MAKHA_DAO_20231101 >									
	//        < s86QpIovF2u1du8WcQOSQXy6C9yGTH8X6OVJkL5MBebdd5xB7G60IS8D3SRLS5U6 >									
	//        <  u =="0.000000000000000001" : ] 000000754697374.223838000000000000 ; 000000777672982.100502000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000047F93A94A2A282 >									
	//     < RUSS_PFIX_II_metadata_line_39_____MAKHA_DAOPI_20231101 >									
	//        < ixNdsn74qTabSO7lZjVdKeS9uEwip8251HjxYmuqc373N7SU3xE073LkmU039qb1 >									
	//        <  u =="0.000000000000000001" : ] 000000777672982.100502000000000000 ; 000000799540385.292400000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004A2A2824C40077 >									
	//     < RUSS_PFIX_II_metadata_line_40_____MAKHA_DAC_20231101 >									
	//        < aKPEiEwm3pOp4iA4lU04fGp2PzorHts0m5cKPRg5bGUqUN4Xy2zK57HsAOzf56ye >									
	//        <  u =="0.000000000000000001" : ] 000000799540385.292400000000000000 ; 000000820955249.671688000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004C400774E4ADA5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}