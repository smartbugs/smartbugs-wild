pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXXXVI_II_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXXXVI_II_883		"	;
		string	public		symbol =	"	RUSS_PFXXXVI_II_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		808961113842187000000000000					;	
										
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
	//     < RUSS_PFXXXVI_II_metadata_line_1_____ROSNEFT_20231101 >									
	//        < EcKL355LKQqlYsOHfP8P872720yd83dYAqPG9QF30SUVwCBUCrhffb9L0m27wF9F >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000023341058.937483800000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000239D9A >									
	//     < RUSS_PFXXXVI_II_metadata_line_2_____ROSNEFT_GBP_20231101 >									
	//        < ZQNl36hUXfxBeLb901A7JH1T538z8N8WmJ4yb2L4r608I91ktam97Y69bfiUblT2 >									
	//        <  u =="0.000000000000000001" : ] 000000023341058.937483800000000000 ; 000000043106731.904649100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000239D9A41C691 >									
	//     < RUSS_PFXXXVI_II_metadata_line_3_____ROSNEFT_USD_20231101 >									
	//        < 36jqfKS7gctSXH9JuGv9iui4bQ5aNyIuG0x42fkUAJ5U0Mv4LmyrI0CV7pQM9J7V >									
	//        <  u =="0.000000000000000001" : ] 000000043106731.904649100000000000 ; 000000062407010.223003500000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000041C6915F39BD >									
	//     < RUSS_PFXXXVI_II_metadata_line_4_____ROSNEFT_SA_CHF_20231101 >									
	//        < iC77f6HzMxVa16v9TK8I0Z4f2b53vZV68vn8iFCAfCWd09IQiHcBW2rCYeM0Jjxd >									
	//        <  u =="0.000000000000000001" : ] 000000062407010.223003500000000000 ; 000000086439484.715327700000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005F39BD83E56C >									
	//     < RUSS_PFXXXVI_II_metadata_line_5_____ROSNEFT_GMBH_EUR_20231101 >									
	//        < s0605f51DZpAIbI0iJN4ZXFr0U0QsZYRjRv8GDb8kvQ57MYmK7oDO8wJMjvj5fv4 >									
	//        <  u =="0.000000000000000001" : ] 000000086439484.715327700000000000 ; 000000101918949.323267000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000083E56C9B8417 >									
	//     < RUSS_PFXXXVI_II_metadata_line_6_____BAIKALFINANSGRUP_20231101 >									
	//        < OthR2c9Jaapkv6v5209R118Q2bSQ02G97784uj6KgC8neohzZjU9093YSBpFsOE6 >									
	//        <  u =="0.000000000000000001" : ] 000000101918949.323267000000000000 ; 000000119891041.693454000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009B8417B6F070 >									
	//     < RUSS_PFXXXVI_II_metadata_line_7_____BAIKAL_ORG_20231101 >									
	//        < 1gxWPNMjLy5vmV5egG9942U2XP6lQjVu67Dejp0Y4Jj5W3ANKM0tmQ7K9rks1v2i >									
	//        <  u =="0.000000000000000001" : ] 000000119891041.693454000000000000 ; 000000136776081.992544000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B6F070D0B428 >									
	//     < RUSS_PFXXXVI_II_metadata_line_8_____BAIKAL_AB_20231101 >									
	//        < AO4w5l9cSHAhC4ktSs04c4l9K4k2wWE2V890t72y95UrqPJ4613pqBaXhO0R25AE >									
	//        <  u =="0.000000000000000001" : ] 000000136776081.992544000000000000 ; 000000156380111.238601000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000D0B428EE9DFB >									
	//     < RUSS_PFXXXVI_II_metadata_line_9_____BAIKAL_CHF_20231101 >									
	//        < 488Rd0k5ekSg3TSjQ85zr84t3t56aqsOT34Q8QbGHMEsHlJwyqvg2yqLC2TBRK5W >									
	//        <  u =="0.000000000000000001" : ] 000000156380111.238601000000000000 ; 000000177173901.023051000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000EE9DFB10E588E >									
	//     < RUSS_PFXXXVI_II_metadata_line_10_____BAIKAL_BYR_20231101 >									
	//        < GpD9x8m12FAFp540tHmQW9x7esRU63407U9vVPahBNx5l1d3067HgN3JfAT9354u >									
	//        <  u =="0.000000000000000001" : ] 000000177173901.023051000000000000 ; 000000197282662.716570000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000010E588E12D078A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVI_II_metadata_line_11_____YUKOS_ABI_20231101 >									
	//        < 1U1IXqyjczjEy1WN938uL9BTmYM184vFm8M3gS2DV9k19eWN2v97jQCfCdb3hae9 >									
	//        <  u =="0.000000000000000001" : ] 000000197282662.716570000000000000 ; 000000217643949.163409000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000012D078A14C192B >									
	//     < RUSS_PFXXXVI_II_metadata_line_12_____YUKOS_ABII_20231101 >									
	//        < s2rpnx9wKwMhgwlel57y0QBUSjfvZ5tdTP2MBXVNR3e04XPe1Eh31890o918wA3s >									
	//        <  u =="0.000000000000000001" : ] 000000217643949.163409000000000000 ; 000000235558649.376579000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000014C192B1676F19 >									
	//     < RUSS_PFXXXVI_II_metadata_line_13_____YUKOS_ABIII_20231101 >									
	//        < W74c599Ac7sw5M9WTvRBKCA2fPsdrD4AL22FC08d9hifPVk3AF7pVc3gNzEmMXqr >									
	//        <  u =="0.000000000000000001" : ] 000000235558649.376579000000000000 ; 000000254953085.355114000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001676F19185070D >									
	//     < RUSS_PFXXXVI_II_metadata_line_14_____YUKOS_ABIV_20231101 >									
	//        < DAS4XFYuHrX1VVhs02xP76D42tmW090pgy2wgI5T0z4B31ce4tt8MoUl8DGYiw63 >									
	//        <  u =="0.000000000000000001" : ] 000000254953085.355114000000000000 ; 000000272748140.058448000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000185070D1A02E3E >									
	//     < RUSS_PFXXXVI_II_metadata_line_15_____YUKOS_ABV_20231101 >									
	//        < xinaI205m8G22i7tF1qX5Pk9ngy5a1vdHIXqfsy370E6gHeXpwuiJ2dHqPk3zFDl >									
	//        <  u =="0.000000000000000001" : ] 000000272748140.058448000000000000 ; 000000294728006.565546000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001A02E3E1C1B821 >									
	//     < RUSS_PFXXXVI_II_metadata_line_16_____ROSNEFT_TRADE_LIMITED_20231101 >									
	//        < 4wEVtNbPmdF1mmJ94Q7e5v4i58prFY2p681Kg5wYM6JLHqD6dAcgUUsSfDP65zO3 >									
	//        <  u =="0.000000000000000001" : ] 000000294728006.565546000000000000 ; 000000318666703.538414000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001C1B8211E63F2E >									
	//     < RUSS_PFXXXVI_II_metadata_line_17_____NEFT_AKTIV_20231101 >									
	//        < ONtN82l38BdFPK63kjxX59MMwO0Q2JBAs452UKy5r7uy3c33br39P54P4vzHbpoQ >									
	//        <  u =="0.000000000000000001" : ] 000000318666703.538414000000000000 ; 000000340334728.139502000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E63F2E2074F41 >									
	//     < RUSS_PFXXXVI_II_metadata_line_18_____ACHINSK_OIL_REFINERY_VNK_20231101 >									
	//        < w0RH9u6O9n25mqa0sehTzuO79uh0Bb3H24i20u3v78Y1uN014uO79vM0074fp0ew >									
	//        <  u =="0.000000000000000001" : ] 000000340334728.139502000000000000 ; 000000362424691.324475000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002074F412290425 >									
	//     < RUSS_PFXXXVI_II_metadata_line_19_____ROSPAN_INT_20231101 >									
	//        < 41C7yZ6MzR0h6yKc1Oe0G4f14aIca95gKY26fP88OjhO8677tzUJZk5L98VSSSBJ >									
	//        <  u =="0.000000000000000001" : ] 000000362424691.324475000000000000 ; 000000380034574.541745000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002290425243E301 >									
	//     < RUSS_PFXXXVI_II_metadata_line_20_____STROYTRANSGAZ_LIMITED_20231101 >									
	//        < 89momd617yjVOQg79chc6Em67ZB1C5fJ14s31s67og2wU3936Ry6DzK7SuK65mn0 >									
	//        <  u =="0.000000000000000001" : ] 000000380034574.541745000000000000 ; 000000404394388.167691000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000243E3012690E8F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVI_II_metadata_line_21_____ROSNEFT_LIMITED_20231101 >									
	//        < uP3M4wI8i16sMAW74mdH41gUe5p0SFgk0nf00hwfi4M5Nrp944N9433s228XX188 >									
	//        <  u =="0.000000000000000001" : ] 000000404394388.167691000000000000 ; 000000425034991.654849000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002690E8F2888D4B >									
	//     < RUSS_PFXXXVI_II_metadata_line_22_____TAIHU_LIMITED_20231101 >									
	//        < 1g0pQ9i23XEIo4BHmE8R2h99ki1Vc59n922s6ur84lG3f59srh56d9519jRTbbTq >									
	//        <  u =="0.000000000000000001" : ] 000000425034991.654849000000000000 ; 000000448539948.627684000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002888D4B2AC6AEB >									
	//     < RUSS_PFXXXVI_II_metadata_line_23_____TAIHU_ORG_20231101 >									
	//        < wYShyEf9t44pkQtihZ83z2xAn7f4h6IN9L6JD2N11BF515iYc9PuOjPaFZi8dwVD >									
	//        <  u =="0.000000000000000001" : ] 000000448539948.627684000000000000 ; 000000469062018.586043000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002AC6AEB2CBBB5A >									
	//     < RUSS_PFXXXVI_II_metadata_line_24_____EAST_SIBERIAN_GAS_CO_20231101 >									
	//        < wN9OC89xCJ8P7Qs596L0el4966Y1CBNj6TZG7GTxRXa2WbycCJPrfkXC395d538y >									
	//        <  u =="0.000000000000000001" : ] 000000469062018.586043000000000000 ; 000000493113963.452747000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002CBBB5A2F06EA4 >									
	//     < RUSS_PFXXXVI_II_metadata_line_25_____RN_TUAPSINSKIY_NPZ_20231101 >									
	//        < PFBW44Rl59TtT58n6rf37Zc6V5ylPv2O7Jh6kg4q0tbDF2C0JqMUB3kcVq02qEKM >									
	//        <  u =="0.000000000000000001" : ] 000000493113963.452747000000000000 ; 000000512929426.937757000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002F06EA430EAB0F >									
	//     < RUSS_PFXXXVI_II_metadata_line_26_____ROSPAN_ORG_20231101 >									
	//        < GE3va38P377HzRpOBW35lkeSo6O654049C9HNBvD33Em954jFtWNKu9iKy6dsy5p >									
	//        <  u =="0.000000000000000001" : ] 000000512929426.937757000000000000 ; 000000536135653.018683000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000030EAB0F33213FD >									
	//     < RUSS_PFXXXVI_II_metadata_line_27_____SYSRAN_20231101 >									
	//        < dy3ghMi7T6473M890fYR4niz1bqU5Fc96JrMnrGwZL9D3LxMBpf03P3Fs78Px2kR >									
	//        <  u =="0.000000000000000001" : ] 000000536135653.018683000000000000 ; 000000555586684.142132000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000033213FD34FC20C >									
	//     < RUSS_PFXXXVI_II_metadata_line_28_____SYSRAN_ORG_20231101 >									
	//        < huF1v3NLy67H77TftkOt06x49ma89GSG16b5739WxyJ4sux9MrS755zbqp1Xrh0F >									
	//        <  u =="0.000000000000000001" : ] 000000555586684.142132000000000000 ; 000000571473042.283292000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000034FC20C367FFA8 >									
	//     < RUSS_PFXXXVI_II_metadata_line_29_____ARTAG_20231101 >									
	//        < rS86M49k7f8FyMa14uA5ffT88id48UVHo60xUys8m9rj34Zbl8AurSqdi8WUy9zG >									
	//        <  u =="0.000000000000000001" : ] 000000571473042.283292000000000000 ; 000000591535792.257137000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000367FFA83869CAB >									
	//     < RUSS_PFXXXVI_II_metadata_line_30_____ARTAG_ORG_20231101 >									
	//        < 2tL86qXlX6aJYK305l9Nc4VcOTwU5bDNSY1RMp2142MGzgR28963vRyTsZv3QI13 >									
	//        <  u =="0.000000000000000001" : ] 000000591535792.257137000000000000 ; 000000607725083.669792000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003869CAB39F509C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXXXVI_II_metadata_line_31_____RN_TUAPSE_REFINERY_LLC_20231101 >									
	//        < DCs3tFgX1hGnaS89Ma1PVR3W6o9G2FBn5JHgL89uDWBjTp5Z7P6155NsU143G706 >									
	//        <  u =="0.000000000000000001" : ] 000000607725083.669792000000000000 ; 000000630853987.735006000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000039F509C3C29B57 >									
	//     < RUSS_PFXXXVI_II_metadata_line_32_____TUAPSE_ORG_20231101 >									
	//        < O5sUNY729NFz573l1LwKVBrJT1z2437FC7tu00DcN9jhN726y6TDxQ7N4wl78p1r >									
	//        <  u =="0.000000000000000001" : ] 000000630853987.735006000000000000 ; 000000649468162.273173000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003C29B573DF0280 >									
	//     < RUSS_PFXXXVI_II_metadata_line_33_____NATIONAL_OIL_CONSORTIUM_20231101 >									
	//        < 607Xig2nYW559YQsfb4AvK06z0D3Q7tX8Cde1A9U4SlhG5n0Vv9FYgz29J1bphq6 >									
	//        <  u =="0.000000000000000001" : ] 000000649468162.273173000000000000 ; 000000666645281.060572000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003DF02803F93850 >									
	//     < RUSS_PFXXXVI_II_metadata_line_34_____RN_ASTRA_20231101 >									
	//        < 3zC3N12t5Aqex60d748u79VwOL6648O52RHjG4OP9B6I65LaAG5Oam8177Dv4Nq5 >									
	//        <  u =="0.000000000000000001" : ] 000000666645281.060572000000000000 ; 000000686905508.844072000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003F938504182277 >									
	//     < RUSS_PFXXXVI_II_metadata_line_35_____ASTRA_ORG_20231101 >									
	//        < iA1F8P1vEO6zfnBhIXxHVfp6aKQWW145147jcq43P4R2DFCF3t67o2bnx156135J >									
	//        <  u =="0.000000000000000001" : ] 000000686905508.844072000000000000 ; 000000705293413.371146000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004182277434313D >									
	//     < RUSS_PFXXXVI_II_metadata_line_36_____ROSNEFT_DEUTSCHLAND_GMBH_20231101 >									
	//        < x6FBP9sbuwGbIW78wohQ6gMBvrGB6yD6c255t33R35HzI5JdV8x6Z13h69Jg5dqg >									
	//        <  u =="0.000000000000000001" : ] 000000705293413.371146000000000000 ; 000000728872772.118302000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000434313D4582BED >									
	//     < RUSS_PFXXXVI_II_metadata_line_37_____ITERA_GROUP_LIMITED_20231101 >									
	//        < 8WahZK0U5DI0OR7L29de2Z3255Zh2548Yh9zC5jbOo1Q53LAi2wG9n96qS9z9exQ >									
	//        <  u =="0.000000000000000001" : ] 000000728872772.118302000000000000 ; 000000747391167.025905000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004582BED4746DAD >									
	//     < RUSS_PFXXXVI_II_metadata_line_38_____SAMOTLORNEFTEGAZ_20231101 >									
	//        < iKtS0Z14sC50zI9nCooqbmeW32VpuNQUGsKV13oFUWilYs78h1I09B3LCf1wN2dA >									
	//        <  u =="0.000000000000000001" : ] 000000747391167.025905000000000000 ; 000000767763552.152976000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004746DAD49383A3 >									
	//     < RUSS_PFXXXVI_II_metadata_line_39_____KUBANNEFTEPRODUCT_20231101 >									
	//        < gAf3wQJPtwmIg41ai506i68yb4Y8D74NAgYBx2c4066mftlaJGcd0f64b8xKKCN3 >									
	//        <  u =="0.000000000000000001" : ] 000000767763552.152976000000000000 ; 000000791986419.693773000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000049383A34B879B2 >									
	//     < RUSS_PFXXXVI_II_metadata_line_40_____KUBAN_ORG_20231101 >									
	//        < fk7l0w0K9ICh1GP6XnbW9g0082TuzdJ7l28zh90x2FYUnK4G802ld8329pGup9kt >									
	//        <  u =="0.000000000000000001" : ] 000000791986419.693773000000000000 ; 000000808961113.842187000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004B879B24D2606F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}