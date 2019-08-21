pragma solidity 		^0.4.21	;						
										
	contract	NDRV_PFVI_III_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDRV_PFVI_III_883		"	;
		string	public		symbol =	"	NDRV_PFVI_III_IMTD		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		2024678126180670000000000000					;	
										
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
	//     < NDRV_PFVI_III_metadata_line_1_____Hannover_Re_20251101 >									
	//        < k9sJNvK138X2XKfY7s72VZ553t72erWA5znO247FmAl862KzP6s2foAlu6jEdfG8 >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000054013008.255193400000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000000000526AD5 >									
	//     < NDRV_PFVI_III_metadata_line_2_____International Insurance Company of Hannover SE_20251101 >									
	//        < VZepbwM7vk464nsonMLE45iUmk1recCag9Oe0Vj22iX7IKfU8sKzAB1W0LTHY7FT >									
	//        <  u =="0.000000000000000001" : ] 000000054013008.255193400000000000 ; 000000082940528.406727100000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000526AD57E8EA5 >									
	//     < NDRV_PFVI_III_metadata_line_3_____Hannover Life Reassurance Company of America_20251101 >									
	//        < jgCLDH5yJ5l15Po7G2x27hNd5gWZX0i7hZK90brRsO6U0EtCOS3h95AbOl6ozk60 >									
	//        <  u =="0.000000000000000001" : ] 000000082940528.406727100000000000 ; 000000108595454.079861000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000007E8EA5A5B419 >									
	//     < NDRV_PFVI_III_metadata_line_4_____Hannover Reinsurance_20251101 >									
	//        < CZdl3XQF31mROLw51gzhTuCN5AOGx52vQK0EQMTu531Z1ja7H0FeV7E6jKpC9Qk7 >									
	//        <  u =="0.000000000000000001" : ] 000000108595454.079861000000000000 ; 000000168826068.406538000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000A5B4191019BAF >									
	//     < NDRV_PFVI_III_metadata_line_5_____Clarendon Insurance Group Inc_20251101 >									
	//        < ebCCycRVY0eZO4OE7c7cZRy0fb1Ul290P5bqd7U6uQO4XO9KHrdDLTr4XmaIx1HI >									
	//        <  u =="0.000000000000000001" : ] 000000168826068.406538000000000000 ; 000000226993856.382071000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001019BAF15A5D7A >									
	//     < NDRV_PFVI_III_metadata_line_6_____Argenta Holdings plc_20251101 >									
	//        < OV9p5bP790WRSpilmdsaiD3SM9B2YMA2Bg2Y6ukD12PY5KtV4pst85lN7icK05tw >									
	//        <  u =="0.000000000000000001" : ] 000000226993856.382071000000000000 ; 000000306946230.626298000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000015A5D7A1D45CDF >									
	//     < NDRV_PFVI_III_metadata_line_7_____Argenta Syndicate Management Limited_20251101 >									
	//        < 8w1xJ056rmP26LrWaCf8qQHg5157wpu1dFE256LO3ZT9saJ2upEvj82V0I79rVrk >									
	//        <  u =="0.000000000000000001" : ] 000000306946230.626298000000000000 ; 000000327108977.570565000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001D45CDF1F320F2 >									
	//     < NDRV_PFVI_III_metadata_line_8_____Argenta Private Capital Limited_20251101 >									
	//        < 5eR7rvCjESfuYJvTx0CO6L3MOp2u2VdyFMiJF4Ap95wO6ZWvDv3S1PuHcF491JLD >									
	//        <  u =="0.000000000000000001" : ] 000000327108977.570565000000000000 ; 000000366012148.781024000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001F320F222E7D7F >									
	//     < NDRV_PFVI_III_metadata_line_9_____Argenta Tax & Corporate Services Limited_20251101 >									
	//        < xpHXScLa9Pdb4122ot54xcz8H53YU7Od76b2P0bdG6ynOHn4wex4VAm7Muq35Yb0 >									
	//        <  u =="0.000000000000000001" : ] 000000366012148.781024000000000000 ; 000000442830571.831166000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000022E7D7F2A3B4B1 >									
	//     < NDRV_PFVI_III_metadata_line_10_____Hannover Life Re AG_20251101 >									
	//        < e0mBDNhKRH06Yj8RIHeR9rRh7iVsE3tHE37XgEQzw27Z0oO6N8u7E09w3yB834Vs >									
	//        <  u =="0.000000000000000001" : ] 000000442830571.831166000000000000 ; 000000502057404.118296000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002A3B4B12FE142C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVI_III_metadata_line_11_____Hannover Life Re of Australasia Ltd_20251101 >									
	//        < 9885WV136l07HQoDDyyO4v889mbf4z6h29055a5xzrDZ296fY5HdHtx89wXt2AI1 >									
	//        <  u =="0.000000000000000001" : ] 000000502057404.118296000000000000 ; 000000546380375.291329000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000002FE142C341B5D6 >									
	//     < NDRV_PFVI_III_metadata_line_12_____Hannover Life Re of Australasia Ltd New Zealand_20251101 >									
	//        < smM4u364bsSl1QR32M9Tlky0jAeFv5YW2wP1Mdcrn0BDQEDS3A6p5cHmj1c2FZzJ >									
	//        <  u =="0.000000000000000001" : ] 000000546380375.291329000000000000 ; 000000618653104.368619000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000341B5D63AFFD5E >									
	//     < NDRV_PFVI_III_metadata_line_13_____Hannover Re Ireland Designated Activity Company_20251101 >									
	//        < 5c70RUhP9y9Riva44gDEJO010z57pOYvvGrO4C178NPKItecG6Cyz2yKuWdt1QAP >									
	//        <  u =="0.000000000000000001" : ] 000000618653104.368619000000000000 ; 000000644308234.103061000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003AFFD5E3D722E7 >									
	//     < NDRV_PFVI_III_metadata_line_14_____Hannover Re Guernsey PCC Limited_20251101 >									
	//        < iSkEXY2y07Fr0lH876JmZOTqPtT561EgoYf9MbX0ro4JjuLjsr56x9K9IDpytvoO >									
	//        <  u =="0.000000000000000001" : ] 000000644308234.103061000000000000 ; 000000734401110.162556000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000003D722E74609B6F >									
	//     < NDRV_PFVI_III_metadata_line_15_____Hannover Re Euro RE Holdings GmbH_20251101 >									
	//        < JNo7Q8QMe1m3IBHSKxwMsBW3SmZ0RoR0dw8xtASE8As24AzWwy5c6daL4ya7Q79H >									
	//        <  u =="0.000000000000000001" : ] 000000734401110.162556000000000000 ; 000000763559915.527303000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004609B6F48D1998 >									
	//     < NDRV_PFVI_III_metadata_line_16_____Skandia Portfolio Management GmbH_20251101 >									
	//        < 56muK77N51MB9yRoVHeGf6TxYBwk7B02wBO2Tx74q28H4vNBjHsyLk478W3BefrR >									
	//        <  u =="0.000000000000000001" : ] 000000763559915.527303000000000000 ; 000000858513993.754839000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000048D199851DFD07 >									
	//     < NDRV_PFVI_III_metadata_line_17_____Skandia Lebensversicherung AG_20251101 >									
	//        < 1xlL6kzMvDifN3l1mdMKCp65Gog56fGrzKcNU3CR3dJRxNwDk3t9CN7723Gpu2CL >									
	//        <  u =="0.000000000000000001" : ] 000000858513993.754839000000000000 ; 000000914557507.374989000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000051DFD075738107 >									
	//     < NDRV_PFVI_III_metadata_line_18_____Hannover Life Reassurance Bermuda Ltd_20251101 >									
	//        < SD8K2JG2j0Co4qx7psRP36DgoOdlS28fguU6boqm3i1o9m7V1SxUQBea2ms0iKps >									
	//        <  u =="0.000000000000000001" : ] 000000914557507.374989000000000000 ; 000001005864009.101320000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057381075FED3A1 >									
	//     < NDRV_PFVI_III_metadata_line_19_____Hannover Re Services Japan KK_20251101 >									
	//        < f82OaCo479d162Ut2oDFXlEUd1C7o1aqLEo0kNlZ0Oa7D1JvM7tbr18aPl599qXA >									
	//        <  u =="0.000000000000000001" : ] 000001005864009.101320000000000000 ; 000001076014632.808100000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000005FED3A1669DE37 >									
	//     < NDRV_PFVI_III_metadata_line_20_____Hannover Finance Inc_20251101 >									
	//        < 16f4j79xtT82lHRLaQc1R6e3Xd9kuy02902WTvUOef3Uyb6hVjB4CuC1hkzgFuL1 >									
	//        <  u =="0.000000000000000001" : ] 000001076014632.808100000000000000 ; 000001109453316.431650000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000669DE3769CE434 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVI_III_metadata_line_21_____Atlantic Capital Corp_20251101 >									
	//        < 8zsZoEIS3149UZRZvie7a6rrkj5M221Qo2VNcWKi38EZ230W21EK4UR1a85frjAY >									
	//        <  u =="0.000000000000000001" : ] 000001109453316.431650000000000000 ; 000001131644868.011680000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000069CE4346BEC0C7 >									
	//     < NDRV_PFVI_III_metadata_line_22_____Hannover Re Bermuda Ltd_20251101 >									
	//        < EC7OfIkFPn4TVxteEuVNIf3Dvl312f7POKDjb7g68o38gd2997wW9q9QDT8fPTZr >									
	//        <  u =="0.000000000000000001" : ] 000001131644868.011680000000000000 ; 000001153128084.185960000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006BEC0C76DF88A8 >									
	//     < NDRV_PFVI_III_metadata_line_23_____Hannover Re Consulting Services India Private Limited_20251101 >									
	//        < Pc1f21gk12Q88alFGL403sdns4Mzd7j7XJWLnku93l7WB3nR3o339G4RoO4y7rgJ >									
	//        <  u =="0.000000000000000001" : ] 000001153128084.185960000000000000 ; 000001215673940.047060000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000006DF88A873EF8A2 >									
	//     < NDRV_PFVI_III_metadata_line_24_____HDI Global Specialty SE_20251101 >									
	//        < bv2Y83Zryxv9MK96vDbtPM0SaPkZP7r607s546B7OQ6g38h8u46N74C91Q3ggJ17 >									
	//        <  u =="0.000000000000000001" : ] 000001215673940.047060000000000000 ; 000001245116558.316310000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000073EF8A276BE5A8 >									
	//     < NDRV_PFVI_III_metadata_line_25_____Hannover Services México SA de CV_20251101 >									
	//        < 5aWnGrSdc5GntfY0Hcbe0sY4h5E8ZW8L7ok5GrWg8Ukm0VDIFEO72b9uNFOs481W >									
	//        <  u =="0.000000000000000001" : ] 000001245116558.316310000000000000 ; 000001315190378.078710000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000076BE5A87D6D23E >									
	//     < NDRV_PFVI_III_metadata_line_26_____Hannover Re Real Estate Holdings Inc_20251101 >									
	//        < 53MPZ3DumsUoR36eQ923du0Wh92mGWUN04V82IdI8N0wMq8GoRSje2hH6wv4eZm4 >									
	//        <  u =="0.000000000000000001" : ] 000001315190378.078710000000000000 ; 000001353839576.366530000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000007D6D23E811CB96 >									
	//     < NDRV_PFVI_III_metadata_line_27_____GLL HRE Core Properties LP_20251101 >									
	//        < Grhhn2B4J8hT61ZKLF1HeO1HpO9Z7kUn5wM6zYqAd33Y51ZYrXm4699L6BI3vmXO >									
	//        <  u =="0.000000000000000001" : ] 000001353839576.366530000000000000 ; 000001392059858.698780000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000811CB9684C1D62 >									
	//     < NDRV_PFVI_III_metadata_line_28_____Broadway101 Office Park Inc_20251101 >									
	//        < 04Bzqg2322bSgwBWI5sxLkkQVTlEqWOkZT6vWFkKtjOF1vaz0IzGp04hy84l28CU >									
	//        <  u =="0.000000000000000001" : ] 000001392059858.698780000000000000 ; 000001440068454.490070000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000084C1D628955EBD >									
	//     < NDRV_PFVI_III_metadata_line_29_____Broadway 101 LLC_20251101 >									
	//        < MD2NaXtkH2duYNamM89z8gg2S91mprpkzHt0N37EBiCV2F7C3H4mMvW8AXD0m01a >									
	//        <  u =="0.000000000000000001" : ] 000001440068454.490070000000000000 ; 000001503377466.777950000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008955EBD8F5F8D3 >									
	//     < NDRV_PFVI_III_metadata_line_30_____5115 Sedge Corporation_20251101 >									
	//        < 20fbhKZhQsdR977TcJNj42U9Ldnl0r6598FrRCH5NxvqR5ZE3uXm844X890Lk9fJ >									
	//        <  u =="0.000000000000000001" : ] 000001503377466.777950000000000000 ; 000001582555059.305220000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000008F5F8D396EC992 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDRV_PFVI_III_metadata_line_31_____Hannover Re Euro Pe Holdings Gmbh & Co Kg_20251101 >									
	//        < XofCQ5n34m3GLh49CHq3Q0Mnvn61h12HP3SsdlWO71211X11by6xbU75UeM1ETZm >									
	//        <  u =="0.000000000000000001" : ] 000001582555059.305220000000000000 ; 000001645948043.142300000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000096EC9929CF8474 >									
	//     < NDRV_PFVI_III_metadata_line_32_____Compass Insurance Company Ltd_20251101 >									
	//        < 2237aR3a5tpuJ9Xql9R03m29bNAUpr7Sgu16A4lkpfN8iHututtJG5Zk7gVuHb0n >									
	//        <  u =="0.000000000000000001" : ] 000001645948043.142300000000000000 ; 000001681218414.762480000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000009CF8474A0555F1 >									
	//     < NDRV_PFVI_III_metadata_line_33_____Commercial & Industrial Acceptances Pty Ltd_20251101 >									
	//        < 57EcJsjC0MowNwDscrfaM3S68iX5Bsv1Deo8CEVYl304UWbSoGR22YPjh2s08U6a >									
	//        <  u =="0.000000000000000001" : ] 000001681218414.762480000000000000 ; 000001744893175.161380000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A0555F1A667EE6 >									
	//     < NDRV_PFVI_III_metadata_line_34_____Kaith Re Ltd_20251101 >									
	//        < Q5WIUaDXNitdLxWlFjOo0WfSDSE1W4e08wE5yt7MZvSlAi9lMUg1B2NwdO48RLq6 >									
	//        <  u =="0.000000000000000001" : ] 000001744893175.161380000000000000 ; 000001825944283.976280000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000A667EE6AE22B7C >									
	//     < NDRV_PFVI_III_metadata_line_35_____Leine Re_20251101 >									
	//        < JZMNAkl58bW93XvJ707UQv0dmYWA4Y3kz8e7ob2MF6I70OkWO91BBrpxrs93iuMH >									
	//        <  u =="0.000000000000000001" : ] 000001825944283.976280000000000000 ; 000001854576632.074250000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000AE22B7CB0DDBFF >									
	//     < NDRV_PFVI_III_metadata_line_36_____Hannover Re Services Italy Srl_20251101 >									
	//        < BnIIsm51oZz9IBOZxPLkX18h8E8c92EZ24SJT3s35Y2x1aHdA8jYLdmEepqWJYNY >									
	//        <  u =="0.000000000000000001" : ] 000001854576632.074250000000000000 ; 000001874998331.656590000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000B0DDBFFB2D0539 >									
	//     < NDRV_PFVI_III_metadata_line_37_____Hannover Services UK Ltd_20251101 >									
	//        < 4zsgA6GjQ503F84r999EHNq8QIDSd35wW9z1ZkP8tYQCmnVr2AP80e4Kz66RR3q6 >									
	//        <  u =="0.000000000000000001" : ] 000001874998331.656590000000000000 ; 000001894195536.751120000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000B2D0539B4A5022 >									
	//     < NDRV_PFVI_III_metadata_line_38_____Hr Gll Central Europe Holding Gmbh_20251101 >									
	//        < 8ZzrH3L7KpXr3P5uRB5J28j12fRUJA430iDpTFuXduun3FXT2WUL088BLcIrX7mj >									
	//        <  u =="0.000000000000000001" : ] 000001894195536.751120000000000000 ; 000001919973912.355520000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000B4A5022B71A5CF >									
	//     < NDRV_PFVI_III_metadata_line_39_____Hannover Re Risk Management Services India Private Limited_20251101 >									
	//        < TtFXp2YmbI3L25DqE7il54o9tFPsn1I8hy39J03S2200uKOVlqDpPtT1QoaFRogZ >									
	//        <  u =="0.000000000000000001" : ] 000001919973912.355520000000000000 ; 000001956918480.995410000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000B71A5CFBAA0548 >									
	//     < NDRV_PFVI_III_metadata_line_40_____HAPEP II Holding GmbH_20251101 >									
	//        < a676nHto6IEy3Wo9e7KU7I985tZP7o4e5QL6gn2QYJsD8h75s5lY2wAgm2dHaR84 >									
	//        <  u =="0.000000000000000001" : ] 000001956918480.995410000000000000 ; 000002024678126.180670000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000BAA0548C1169E5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}