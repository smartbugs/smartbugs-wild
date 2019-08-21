pragma solidity 		^0.4.21	;						
										
	contract	RUSS_PFXII_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	RUSS_PFXII_I_883		"	;
		string	public		symbol =	"	RUSS_PFXII_I_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		608320960998063000000000000					;	
										
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
	//     < RUSS_PFXII_I_metadata_line_1_____TMK_20211101 >									
	//        < Mh5Gc2iX95I4672mtR8E97351tR7FaZmDBJ28HyAHA4q52u3u2w5drx29uS2nC1N >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000014240150.533360000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000000000015BA8F >									
	//     < RUSS_PFXII_I_metadata_line_2_____TMK_ORG_20211101 >									
	//        < 7YSTW2X938DR9jY95iqx7OS4EIfaEV6UGKujS4rFezCe5uKYEUkJ92V331BKjhpx >									
	//        <  u =="0.000000000000000001" : ] 000000014240150.533360000000000000 ; 000000028873425.793190300000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000015BA8F2C0EAF >									
	//     < RUSS_PFXII_I_metadata_line_3_____TMK_STEEL_LIMITED_20211101 >									
	//        < CCiN3D8VnfZ6b2jo7UunD5G002wl10K4JC0wWbfN4YM7s3T7w4t656sG8686ex3K >									
	//        <  u =="0.000000000000000001" : ] 000000028873425.793190300000000000 ; 000000045380023.073879900000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002C0EAF453E92 >									
	//     < RUSS_PFXII_I_metadata_line_4_____IPSCO_TUBULARS_INC_20211101 >									
	//        < 3W32x2xAyI33PY9D2rCz5xhmoZow01N1s35NWb661ehN7xDKmP2BnW9BOP578F43 >									
	//        <  u =="0.000000000000000001" : ] 000000045380023.073879900000000000 ; 000000060222776.900335800000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000453E925BE486 >									
	//     < RUSS_PFXII_I_metadata_line_5_____VOLZHSKY_PIPE_PLANT_20211101 >									
	//        < 2F7KA041uDuwROp3z87DNxD8d73n5KJHx8uKoE04JP3v3V1m6849Eb2x545in4Iy >									
	//        <  u =="0.000000000000000001" : ] 000000060222776.900335800000000000 ; 000000075168746.555674200000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005BE48672B2CB >									
	//     < RUSS_PFXII_I_metadata_line_6_____SEVERSKY_PIPE_PLANT_20211101 >									
	//        < D1jAoAq3j512XIpyHFEyG7j4C852TbJvT5P1U60FDcHF904T2RLtY1T2IBQXgNYT >									
	//        <  u =="0.000000000000000001" : ] 000000075168746.555674200000000000 ; 000000088432753.085307100000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000072B2CB86F00B >									
	//     < RUSS_PFXII_I_metadata_line_7_____RESITA_WORKS_20211101 >									
	//        < UzckNf81Ol27haXZL13LdcLAspivf9ewj13luFJRf68Y4Oki46z79Py1Z4e1q8aW >									
	//        <  u =="0.000000000000000001" : ] 000000088432753.085307100000000000 ; 000000103379470.222730000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000086F00B9DBE9B >									
	//     < RUSS_PFXII_I_metadata_line_8_____GULF_INTERNATIONAL_PIPE_INDUSTRY_20211101 >									
	//        < 03NG6mIF29A75nApzLWHDwbDZ027I52Axp3162reSF8USh5lFs8vM2nR7t5Q741Q >									
	//        <  u =="0.000000000000000001" : ] 000000103379470.222730000000000000 ; 000000120131580.033049000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000009DBE9BB74E66 >									
	//     < RUSS_PFXII_I_metadata_line_9_____TMK_PREMIUM_SERVICE_20211101 >									
	//        < 4W3ugBo63YZ9mVOiYO9GhqihQxHNN40fIv8941CP6I7RtfGxDYXuN4xuq7SpK7qP >									
	//        <  u =="0.000000000000000001" : ] 000000120131580.033049000000000000 ; 000000135575949.827674000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000B74E66CEDF5B >									
	//     < RUSS_PFXII_I_metadata_line_10_____ORSKY_MACHINE_BUILDING_PLANT_20211101 >									
	//        < S8kYYaik5xzHRrS5i69HHdI9tuu5iye2aYXr175rzs33fMBwR9KlnV711JjzZ7yO >									
	//        <  u =="0.000000000000000001" : ] 000000135575949.827674000000000000 ; 000000148705475.014904000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000CEDF5BE2E814 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXII_I_metadata_line_11_____TMK_CAPITAL_SA_20211101 >									
	//        < 1pW2uIwOT74IV0e55squ4n1meUSif40I6K1NcjId6MAhJZuI2l6Qf4k8VoE08CQC >									
	//        <  u =="0.000000000000000001" : ] 000000148705475.014904000000000000 ; 000000164904458.214878000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000E2E814FB9FCE >									
	//     < RUSS_PFXII_I_metadata_line_12_____TMK_NSG_LLC_20211101 >									
	//        < u7szy0aW2p2mHsVtMG4iGE7eLV2BHPzfYe7q3g5HndIxnhkRWovJhgprWDuGLGmA >									
	//        <  u =="0.000000000000000001" : ] 000000164904458.214878000000000000 ; 000000178325075.682662000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000FB9FCE1101A3C >									
	//     < RUSS_PFXII_I_metadata_line_13_____TMK_GLOBAL_AG_20211101 >									
	//        < 960gh8KoDp88r7435qnl602SKm1A765Q84JdMIg76Yk74tOJ35P28FzNJs4L0Uhr >									
	//        <  u =="0.000000000000000001" : ] 000000178325075.682662000000000000 ; 000000194125470.667404000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001101A3C1283643 >									
	//     < RUSS_PFXII_I_metadata_line_14_____TMK_EUROPE_GMBH_20211101 >									
	//        < c2vjDv2ntMjIs8kFPO2B75JxnZfgqvS6xsfco6BwIlPvM61j1M16JUmj6y6PFfN9 >									
	//        <  u =="0.000000000000000001" : ] 000000194125470.667404000000000000 ; 000000210869686.042589000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001283643141C2F9 >									
	//     < RUSS_PFXII_I_metadata_line_15_____TMK_MIDDLE_EAST_FZCO_20211101 >									
	//        < p89XGaLRQ2f4ee4M3d8YRKgEJ7k0AHgiy2qfqbiqE3bd3f9u29rXRus7NmxpJpz6 >									
	//        <  u =="0.000000000000000001" : ] 000000210869686.042589000000000000 ; 000000225118461.014831000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000141C2F915780E6 >									
	//     < RUSS_PFXII_I_metadata_line_16_____TMK_EUROSINARA_SRL_20211101 >									
	//        < E8Hic2Kdnt1Va4Zg4Wn5WaStLC2EF0VwphiVjI7xvAr1ZU40RQn6C14lkl621sM5 >									
	//        <  u =="0.000000000000000001" : ] 000000225118461.014831000000000000 ; 000000238769454.429900000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015780E616C5551 >									
	//     < RUSS_PFXII_I_metadata_line_17_____TMK_EASTERN_EUROPE_SRL_20211101 >									
	//        < 15efgo3mdznRa7U6zhy98eF3hwat8Dog2KO83nS68qu4K9WkLGhLcz8iuL395ESn >									
	//        <  u =="0.000000000000000001" : ] 000000238769454.429900000000000000 ; 000000255932623.395731000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000016C555118685AE >									
	//     < RUSS_PFXII_I_metadata_line_18_____TMK_REAL_ESTATE_SRL_20211101 >									
	//        < 5p9L0L8yR0l2H696tfcD6shZ620BRs398v8n7ICkAr638X3Z0nl1bwLmfmGCD0Mv >									
	//        <  u =="0.000000000000000001" : ] 000000255932623.395731000000000000 ; 000000272497191.654542000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000018685AE19FCC37 >									
	//     < RUSS_PFXII_I_metadata_line_19_____POKROVKA_40_20211101 >									
	//        < xrsxo85LSo07tgG38t0DA7dp5OxValoQZ1aYo6yWcL076kan38F38sD7qL94m4aB >									
	//        <  u =="0.000000000000000001" : ] 000000272497191.654542000000000000 ; 000000285756227.390008000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000019FCC371B40787 >									
	//     < RUSS_PFXII_I_metadata_line_20_____THREADING_MECHANICAL_KEY_PREMIUM_20211101 >									
	//        < G6HJTq3NTEG72sk94T1SA70jXuFas880q59hwd5PW2hknSh00I29re2lAQ7rPwer >									
	//        <  u =="0.000000000000000001" : ] 000000285756227.390008000000000000 ; 000000300952770.279426000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001B407871CB37AD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXII_I_metadata_line_21_____TMK_NORTH_AMERICA_INC_20211101 >									
	//        < CE2aiiNqcCba6ShO3OI1w147QV3Vcbcg74cL60T5J9HFA924wl4C9FunJ7vpDd04 >									
	//        <  u =="0.000000000000000001" : ] 000000300952770.279426000000000000 ; 000000316207442.227362000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001CB37AD1E27E88 >									
	//     < RUSS_PFXII_I_metadata_line_22_____TMK_KAZAKHSTAN_20211101 >									
	//        < Yj3PXH9jHJ3oK0FYi2SEjNxcDTMAoMmP45Fja9a00819Ve785MsMGPXAseld9zHS >									
	//        <  u =="0.000000000000000001" : ] 000000316207442.227362000000000000 ; 000000333173845.277847000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001E27E881FC6209 >									
	//     < RUSS_PFXII_I_metadata_line_23_____KAZTRUBPROM_20211101 >									
	//        < 33q6A7kOSRg226VijJOV7c0VCJ3MZZFaf5tTU12Brf5vOp0Ls7xDaHppOdmR9s5W >									
	//        <  u =="0.000000000000000001" : ] 000000333173845.277847000000000000 ; 000000347630985.404761000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001FC6209212715B >									
	//     < RUSS_PFXII_I_metadata_line_24_____PIPE_METALLURGIC_CO_COMPLETIONS_20211101 >									
	//        < c3Wm6Mx2ayU2F528MvosgA2K3xr527MxcuHN77WHvH0Lb9iv74k0GM0xZ1H2S1Sr >									
	//        <  u =="0.000000000000000001" : ] 000000347630985.404761000000000000 ; 000000363323883.237395000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000212715B22A6364 >									
	//     < RUSS_PFXII_I_metadata_line_25_____ZAO_TRADE_HOUSE_TMK_20211101 >									
	//        < 6MS0Ne1FZXs8BsRb0HiC6BGgTw3hPz55Ve5wp9PydT5Amt2D85QWj5u7W97JaI2p >									
	//        <  u =="0.000000000000000001" : ] 000000363323883.237395000000000000 ; 000000380325303.608395000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022A63642445492 >									
	//     < RUSS_PFXII_I_metadata_line_26_____TMK_ZAO_PIPE_REPAIR_20211101 >									
	//        < McyW5174Mv3slNq627q6G9Ou8gr4l5L2rS0lY8D0y0498bB91eQx50rt8vZ3F91z >									
	//        <  u =="0.000000000000000001" : ] 000000380325303.608395000000000000 ; 000000396883550.107409000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000244549225D98A3 >									
	//     < RUSS_PFXII_I_metadata_line_27_____SINARA_PIPE_WORKS_TRADING_HOUSE_20211101 >									
	//        < 62GgSruB0dix2jMfbpTj2W1udoat6duDQZbug60b55Kv7VWg8p7ryYo9kDl60pS0 >									
	//        <  u =="0.000000000000000001" : ] 000000396883550.107409000000000000 ; 000000411704216.283444000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000025D98A327435F6 >									
	//     < RUSS_PFXII_I_metadata_line_28_____SKLADSKOY_KOMPLEKS_20211101 >									
	//        < a49P6IJlxv6Hd35FO4v0tUPd4q816p0TBY0aWa975HM74e12veGVAj3tDtuFUsW1 >									
	//        <  u =="0.000000000000000001" : ] 000000411704216.283444000000000000 ; 000000427860336.035075000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000027435F628CDCF2 >									
	//     < RUSS_PFXII_I_metadata_line_29_____RUS_RESEARCH_INSTITUTE_TUBE_PIPE_IND_20211101 >									
	//        < Ds665I3eOWmo5RTI92P2rDQmb06s8V62H11y5492OLUUHjS197aHdk4wKG5Vo30t >									
	//        <  u =="0.000000000000000001" : ] 000000427860336.035075000000000000 ; 000000442755534.961097000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000028CDCF22A39761 >									
	//     < RUSS_PFXII_I_metadata_line_30_____TAGANROG_METALLURGICAL_PLANT_20211101 >									
	//        < RBNfGYza68VC00xprl6sH5Oqz9Pty76vtZ4lVk2l4qmzVfKOP1rtjzc31Z7DjGO6 >									
	//        <  u =="0.000000000000000001" : ] 000000442755534.961097000000000000 ; 000000458278205.580079000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A397612BB46ED >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < RUSS_PFXII_I_metadata_line_31_____TAGANROG_METALLURGICAL_WORKS_20211101 >									
	//        < nQ41mfeHxOmFDb32Sl89Ehyh45W4V422dsicg8C4lrn3MqTQga8l0697Sh7kA839 >									
	//        <  u =="0.000000000000000001" : ] 000000458278205.580079000000000000 ; 000000471972675.401917000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002BB46ED2D02C54 >									
	//     < RUSS_PFXII_I_metadata_line_32_____IPSCO_CANADA_LIMITED_20211101 >									
	//        < nCc4dVsT4c1h1u4kFM5nyH7MswoN424u952PhU134ul56x9EnU00lmi2CfbTnuau >									
	//        <  u =="0.000000000000000001" : ] 000000471972675.401917000000000000 ; 000000485948702.191812000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002D02C542E57FB6 >									
	//     < RUSS_PFXII_I_metadata_line_33_____SINARA_NORTH_AMERICA_INC_20211101 >									
	//        < v8xiQ42cAK7i9zG08x9gh9kT3DLinn6dYI9n3aH5Uf2J0Ha50amQ64kesujHZO8t >									
	//        <  u =="0.000000000000000001" : ] 000000485948702.191812000000000000 ; 000000502285753.182763000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002E57FB62FE6D5F >									
	//     < RUSS_PFXII_I_metadata_line_34_____PIPE_METALLURGICAL_CO_TRADING_HOUSE_20211101 >									
	//        < fh04F2AmCq8MqK4zetudXJ4t7UxkR6jmoNs1aN3C3Zk2ncP19oA72B0B6aT1K7pS >									
	//        <  u =="0.000000000000000001" : ] 000000502285753.182763000000000000 ; 000000516475026.411092000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FE6D5F314140F >									
	//     < RUSS_PFXII_I_metadata_line_35_____TAGANROG_METALLURGICAL_WORKS_20211101 >									
	//        < 0h5yCWp4FVG2FuHjC8n5q6qRaK1u172hEt7Qwu48PvkymS9D527E9UJU8Rkt86zO >									
	//        <  u =="0.000000000000000001" : ] 000000516475026.411092000000000000 ; 000000532507306.917102000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000314140F32C8AAB >									
	//     < RUSS_PFXII_I_metadata_line_36_____SINARSKY_PIPE_PLANT_20211101 >									
	//        < 58nh5MY30Hb51bSk0eHNyTvrEw84IGyKlSqPJl39SwUZUzk0yVklpC5g1fsc6iUk >									
	//        <  u =="0.000000000000000001" : ] 000000532507306.917102000000000000 ; 000000548440190.093789000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000032C8AAB344DA73 >									
	//     < RUSS_PFXII_I_metadata_line_37_____TMK_BONDS_SA_20211101 >									
	//        < FxE8T9ySX9ErKB6sZR1fR14Yt0VKDVUODjZxN76m8OG7Gh242jLXwcqLR2XL2YMD >									
	//        <  u =="0.000000000000000001" : ] 000000548440190.093789000000000000 ; 000000565671704.201412000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000344DA7335F2582 >									
	//     < RUSS_PFXII_I_metadata_line_38_____OOO_CENTRAL_PIPE_YARD_20211101 >									
	//        < burRg8xWX0mbX86k93r483kM8dd3YN4y0UQk0D5BtmSlJwi99cDFwhwJCc12t67T >									
	//        <  u =="0.000000000000000001" : ] 000000565671704.201412000000000000 ; 000000579461250.586275000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000035F2582374300D >									
	//     < RUSS_PFXII_I_metadata_line_39_____SINARA_PIPE_WORKS_20211101 >									
	//        < VNcD13Axe2C89ZW0LtqkU81RSu7qf81541SNm3u8s1cL4ftW1k22PVlalo3Y3zB6 >									
	//        <  u =="0.000000000000000001" : ] 000000579461250.586275000000000000 ; 000000593387450.150903000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000374300D3896FF9 >									
	//     < RUSS_PFXII_I_metadata_line_40_____ZAO_TMK_TRADE_HOUSE_20211101 >									
	//        < 4q5K6odNN0R7474jogRMX366VOCY4PZM8bw7xLwV5T1YJ4aW28Zw46sZTvO1N53g >									
	//        <  u =="0.000000000000000001" : ] 000000593387450.150903000000000000 ; 000000608320960.998063000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003896FF93A03960 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}