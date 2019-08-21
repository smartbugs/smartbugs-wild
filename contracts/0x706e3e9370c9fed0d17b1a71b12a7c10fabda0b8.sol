pragma solidity 		^0.4.25	;						
										
	contract	PI_YU_ROMA_20171122				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	PI_YU_ROMA_20171122_II		"	;
		string	public		symbol =	"	PI_YU_ROMA_20171122_subDTII		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		27615773076000000000000000000					;	
										
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
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2771 à 2780									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2771 ; ie7T262ZXz7j3PMei3C23AsKbiq6q7Hb1I3mKVB09xUVtvGa7 ; 20171122 ; subDT >									
//	        < 7P3FCgoABR1P0abf0fpAprUdR81Q6BWV25FX5kdI4AquDm31jfNpHthMN8g26z6v >									
//	        < O1czdXOIaAQmuGPp1q0rg4roT7a0MBM83876APs8nT1vhR6DIQ9O25wE4TZk19Hc >									
//	        < u =="0.000000000000000001" ; [ 000027870278582.000000000000000000 ; 000027879534067.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A61EAB92A62CCAFE >									
//	    < PI_YU_ROMA ; Line_2772 ; BEqq6665Rt8j7NrJlMqECYmfce0034bbk6OyJGmqw1A9h6Pz7 ; 20171122 ; subDT >									
//	        < HywR81tjCTFS87g385VO46G9ia1XLZi2n2QSJ9iCV68gVha9qCwaXN6Q25tSaI46 >									
//	        < Ey0nSwj3f5O3d4j6FlUCuk3zPLbA5Sf8gAv20sy66ZU3TkHD1Os9JnZ1ru78sBGl >									
//	        < u =="0.000000000000000001" ; [ 000027879534067.000000000000000000 ; 000027889079289.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A62CCAFEA63B5B98 >									
//	    < PI_YU_ROMA ; Line_2773 ; fqc0KS31hWVebOyX4U0LGokWx3SV1De1gQSR25t9symWDMjEC ; 20171122 ; subDT >									
//	        < nUrxeg2034Y1Y57wk9awc83Vh4vQq2NCHmjSKlDRIJ989kFmO560CPlGIWCd9hur >									
//	        < xH24e6QY8ijk5B5S5e98AX2Q9R6bN1vvD3P9X6deNMYu4KGDmT1QR1YTh0GJBCBt >									
//	        < u =="0.000000000000000001" ; [ 000027889079289.000000000000000000 ; 000027902289206.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A63B5B98A64F83B8 >									
//	    < PI_YU_ROMA ; Line_2774 ; H9J23M52Cip9EBt2LcTkHXrg5E3bVmAaQ9dbb6Wp9uc9W3Fir ; 20171122 ; subDT >									
//	        < Ma85HmMB6t6BpL8brM7a5MnDDN2jPX43AK68LFGi3QBm99F9DkpLQTaaA1l8xw33 >									
//	        < a733pDal1SqfQC9LyNzk71CRCFbS1Kdre20O8d5XU4i6RcE084nT5Q26NbDuRDX7 >									
//	        < u =="0.000000000000000001" ; [ 000027902289206.000000000000000000 ; 000027910064747.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A64F83B8A65B610A >									
//	    < PI_YU_ROMA ; Line_2775 ; C6dD0PHl915bjT64jCKwsw04QSEGP67hsEVLCun8Z67Nh6Yql ; 20171122 ; subDT >									
//	        < DM7ZrW2Ne5E18aW6380F1g5ln4G9eVDF9geK0J4Z0bds107tUmJjcaIjnmyC1U9W >									
//	        < 2KoxC4m89Y7F00H1JhxCh19b417z5MuyqY9QJ0p7g85cyJ1e12Wd1XppSl2Hs31Y >									
//	        < u =="0.000000000000000001" ; [ 000027910064747.000000000000000000 ; 000027918268388.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A65B610AA667E596 >									
//	    < PI_YU_ROMA ; Line_2776 ; c1ieyZ2ExE1ekEnz60BResvSMhGuA3oipnYPdKfVqTul1N4RP ; 20171122 ; subDT >									
//	        < lDmaBu0tmsw0q6B68PcXe2k0qdc2DFJqyo272ecF1O14J3gY1RKB41WKi5K3Q574 >									
//	        < W05Nb6F1rHtfx2W13LNvKo7R5Yo0x8szy30dEHPzANgXnq2io53x9pU65z2NKe0A >									
//	        < u =="0.000000000000000001" ; [ 000027918268388.000000000000000000 ; 000027929934207.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A667E596A679B28C >									
//	    < PI_YU_ROMA ; Line_2777 ; rrEw53NyKSq3Y1q409f50z3013YtHq5N1I8068YU6E3QLP25D ; 20171122 ; subDT >									
//	        < vavzoF5a4TZO3R2DOq199fluaCZ4PCKkg514WRxT9uB60v4J681tdUs1n7Hoicg4 >									
//	        < ZXo5pgkF2VP6r5RXJqNcrRQHw06BA881gmU1Gm7rbi33EPj4FNIS36C9eg2O6k3y >									
//	        < u =="0.000000000000000001" ; [ 000027929934207.000000000000000000 ; 000027939130431.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A679B28CA687BAD3 >									
//	    < PI_YU_ROMA ; Line_2778 ; dB8r4rTH30Qp85xHOF8a6r5UXJ6xqp78sJNCG51uXoWebv97X ; 20171122 ; subDT >									
//	        < Ojcx5y568a6ir4MHu51BY45KyR16Lanvz8eNzjG5l0a31jJbQW4PDFUuDsiN3nJ8 >									
//	        < K464H12qvqeQ6MEfxxCv20T45153hQlVfO2U5f2qljycZ9Tds75u023egOcaC3gA >									
//	        < u =="0.000000000000000001" ; [ 000027939130431.000000000000000000 ; 000027953591179.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A687BAD3A69DCB8D >									
//	    < PI_YU_ROMA ; Line_2779 ; bBssDC467ebWDc8i1a1c4NScb0BEdSk73i2PVl0AZ748tCSsW ; 20171122 ; subDT >									
//	        < amhSd1n3ErDi6Zn8BXDXT4OYF4bOnFE7OD5bw9gUrQXd3ba284rcP3Yt2wev7OTh >									
//	        < B9bZ3U3XLV5tCn5vI597Ny08XGb45gK9Z4883M0SrE63Wg6BuA8gcMP73Miu6Cpd >									
//	        < u =="0.000000000000000001" ; [ 000027953591179.000000000000000000 ; 000027962758630.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A69DCB8DA6ABC897 >									
//	    < PI_YU_ROMA ; Line_2780 ; YPa6t9HJ2813J7Iq3NjPxamTh389wMNI3S3786tqIcGiQK3Ib ; 20171122 ; subDT >									
//	        < 043AfWttw0Sr1q38Pd9FE616Pi4nClRIJLImoLuFUI5a28JWSj9bhtT1oNysl82q >									
//	        < 3OQ67E7Jik55lpUzFz2tD9AsB7J2irD6D7fUqopeC3075D5LY39k5qD9y5SYXFti >									
//	        < u =="0.000000000000000001" ; [ 000027962758630.000000000000000000 ; 000027973233148.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A6ABC897A6BBC432 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2781 à 2790									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2781 ; 3T8cn8FlNvAN9jT41Tr5Uyv64GD83uz65YbFkQvwFO5xSViay ; 20171122 ; subDT >									
//	        < 117A8d8z4roc5oZ6DN2bs97GcWQeCt562cV3eYGn1z60zR4fiMkI9V5s8L2C3ufP >									
//	        < 032lf6tPxeX5zAf219J91Dq18fEzgwfAoLUFQYcsAMxp52DlC84Jyi6574qz3RYB >									
//	        < u =="0.000000000000000001" ; [ 000027973233148.000000000000000000 ; 000027983764018.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A6BBC432A6CBD5D1 >									
//	    < PI_YU_ROMA ; Line_2782 ; VU4hu6Th7Nlyb0lL2FH2t6LC4bW85VECW8ygk99og1GYWxeB4 ; 20171122 ; subDT >									
//	        < Bcp9cLqUm0d4843q1OD382G8eb8kBKj6amcBb4hPqTRT968dSUBGf3hba3BPZVGa >									
//	        < urhQJq7r4OHOdN2v79D6MFBUJi8ZmwjmfrR4Z5Si0DX07nSlIV7nPFO7R8wN2Dss >									
//	        < u =="0.000000000000000001" ; [ 000027983764018.000000000000000000 ; 000027993440233.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A6CBD5D1A6DA9997 >									
//	    < PI_YU_ROMA ; Line_2783 ; 49B9E5X9o6j8r4J0pkRYMLRm01hk3bRgd300A0OMQ70t24A42 ; 20171122 ; subDT >									
//	        < usB3RikD24o9WTjodd4MAXIG04s1gZIYJ1x0Gz637R0xjuIRsQ050eXR8i0vzhst >									
//	        < x4ksZVr0l6v4y0s7Ye1R9eWbluul4AuOY6QrPqO1njsJEzHRmtwzH36CvGBR8S2y >									
//	        < u =="0.000000000000000001" ; [ 000027993440233.000000000000000000 ; 000028000269424.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A6DA9997A6E5053E >									
//	    < PI_YU_ROMA ; Line_2784 ; Icm0O8J5UGTI1JmpkzX048I78YDG08fK7ZJe0nan4XuE0N0FJ ; 20171122 ; subDT >									
//	        < YP8JhEhK83jJKOSTBVqOFviNGOIWS699g99isdo7GqcDYLI9flms945RtUtTuiO6 >									
//	        < 3DzM14YmhK3f6wopLikh3qF40NBtZIUmx84U0HSxqo4ORtn16Veax81EOPPao959 >									
//	        < u =="0.000000000000000001" ; [ 000028000269424.000000000000000000 ; 000028007127903.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A6E5053EA6EF7C56 >									
//	    < PI_YU_ROMA ; Line_2785 ; jIRGTd5w2OUPoeK00Layo5J3s6nYJJkVMhcXT9ksJtcoe8qNq ; 20171122 ; subDT >									
//	        < j7UYXCqV2W7m0Qfu53GvRe4RtQE3N55q0Shu11qi6iUlC13DQ6R9ZnDtq50aJiTa >									
//	        < 8dcXv92Nj0o5emCuDigJ2RFHevEd3Sa3Mf3dI9O9EJ6y0nAX30tpwNLv7N7rMFOA >									
//	        < u =="0.000000000000000001" ; [ 000028007127903.000000000000000000 ; 000028018061066.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A6EF7C56A7002B1A >									
//	    < PI_YU_ROMA ; Line_2786 ; 52TV4DmM0wSHILUqmLm6GlT427d8U1nO61fqKm0Kvj73YuU3L ; 20171122 ; subDT >									
//	        < gEq97xXNqPVKUjLq3N0aeL88438MFG2K7w2a1v556jiK1v6w12LVUUd16ENH64b0 >									
//	        < 2xbJXRQOAo8T6CjdGHgTJn1A75hqLa84Noz23xaRbQ1rxtM8MAMB67scG8BH35A4 >									
//	        < u =="0.000000000000000001" ; [ 000028018061066.000000000000000000 ; 000028025378626.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7002B1AA70B5586 >									
//	    < PI_YU_ROMA ; Line_2787 ; 8Z2idXz5Lu0IQTl5mJkDx9vE7NaWxEiTRnLDo76Kv3Ud7iHHI ; 20171122 ; subDT >									
//	        < u59luajBRcpl0WzjfxQWIy9F5vu6i0St2PJ63UvuBy9w5eNSWZcFDqMS68c3dDN6 >									
//	        < LiIB2dCf09kXNjLsDuji4P2ax5mkil57Gjb9Zrt9VP9p6j00Sk087En2TPC4iX1o >									
//	        < u =="0.000000000000000001" ; [ 000028025378626.000000000000000000 ; 000028038013494.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A70B5586A71E9D05 >									
//	    < PI_YU_ROMA ; Line_2788 ; 4337pIe4Pz6eECsg52vbI1pfKHdPIx995nOhC1v3gC4SvNgv5 ; 20171122 ; subDT >									
//	        < 0LdL01Hom3WRdTSQD9dfsSOQGyrCGtjvo7AsJV8I8KVL77Yo2C0EiPwgIJ2IJ1pf >									
//	        < 2pJ8mV2Rsc3XyCdy31Bkb62lnV9lYZh6yc59Vf7v31ZFM5ERA7KaDUrXgJw9z516 >									
//	        < u =="0.000000000000000001" ; [ 000028038013494.000000000000000000 ; 000028047495586.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A71E9D05A72D14F6 >									
//	    < PI_YU_ROMA ; Line_2789 ; 4xOd7BLrRQ6332u8y2I0hyVZ1B9Iu2Z8m5cvV2o68c0RWPn20 ; 20171122 ; subDT >									
//	        < 30u874e8k6qKtV1MGGplnh7C286woImGi7DXIESJaU53cTnOOGsSNRV441P8GXg0 >									
//	        < 19TbdLQGInCTd1P3FWtuv20wkZ1W69Ap07ijypWI058CUnOcsjG5Dv2M3CHeeNHv >									
//	        < u =="0.000000000000000001" ; [ 000028047495586.000000000000000000 ; 000028054871715.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A72D14F6A7385643 >									
//	    < PI_YU_ROMA ; Line_2790 ; cX687e5tihDNtwXqR90dHRa798ZWMAyvF36qadH045Rb7ZA1A ; 20171122 ; subDT >									
//	        < Je59KVVEDiQ31DO2wYaQGfjNuGwcfAT24He1U06yblf736MCXMtk38rvXJkb0dI0 >									
//	        < e10HOv011ktLJIQoAYugu107h4fdT4i676ZIsJ90q99lyQ90U3Y4lBhohmd862vY >									
//	        < u =="0.000000000000000001" ; [ 000028054871715.000000000000000000 ; 000028062116267.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7385643A743642A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2791 à 2800									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2791 ; hP8UA05ua7sMbKK1Z2SG3hQtto1R41Nm4wqQq7r0fiJv6Htz9 ; 20171122 ; subDT >									
//	        < 7A1237ZX1sX20b7W9X4N8A2OcqJZah3E7r0426f2635N7uwfKbG8E3hgZ8x4v2kq >									
//	        < 8t6nepdvKuQApOUYOhai6s8jR432jXVy9mXXij51J02TjN7riUM7D31aJWd1bwW5 >									
//	        < u =="0.000000000000000001" ; [ 000028062116267.000000000000000000 ; 000028077005673.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A743642AA75A1C57 >									
//	    < PI_YU_ROMA ; Line_2792 ; PeJTn86MsKopRQ90yAm85o9KRAUb4UE1LX89EJm90G15kHkny ; 20171122 ; subDT >									
//	        < Wp022nPw7zQ73Bx6058juC8h54wNx7k0C20VaX71JblccjKeVto6g2g0J1s2fB31 >									
//	        < L35YnuPdf0qgyTh0ap1C0uEimNoMNSXyzx1il2G1T3P268wbg933ddRBcTIGox3C >									
//	        < u =="0.000000000000000001" ; [ 000028077005673.000000000000000000 ; 000028088433981.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A75A1C57A76B8C86 >									
//	    < PI_YU_ROMA ; Line_2793 ; 8eI80AFvwMzrvsYxrHt8oZzu49zQQv35SL9a1c33VNlJj4BSJ ; 20171122 ; subDT >									
//	        < vQkXWEJ2B9GtvRsU9749T4bQ7R507I433C36HyzEjY4NO5ldFDzUfo1BcE2O2RmJ >									
//	        < 7981m12Ac226cBqxicRmL76y0HoJrAFCzE4j3YdWhgRF56Nv6LwE7G537I6vRV8K >									
//	        < u =="0.000000000000000001" ; [ 000028088433981.000000000000000000 ; 000028097584636.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A76B8C86A77982FF >									
//	    < PI_YU_ROMA ; Line_2794 ; 0f5Xw3460gRg00dy63U4JkE0E9G6i8Pl6r5kh67ey55cdmAz8 ; 20171122 ; subDT >									
//	        < 2AsHV2081d0c3zQ64pVrQ2OmOJ2XGzv0QKjz9Sy2cE70BKPbOjp48L9QO76327Te >									
//	        < u7783paPVV59d846ua3eLNzzn5Qk0Zh5800XRq7fz96y6PIAUQ2Paxlo8x95fSlk >									
//	        < u =="0.000000000000000001" ; [ 000028097584636.000000000000000000 ; 000028105774836.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A77982FFA786024B >									
//	    < PI_YU_ROMA ; Line_2795 ; oR445zwSy6v36H7LV30wRz8Jp037DL6RfaQ9oM4C8RJ99cB4M ; 20171122 ; subDT >									
//	        < 53G0dCG336knxzy7On9188hE5o0vQ01YOtaNSCk5FTK65B715W4WXnxAHaZHjYHJ >									
//	        < bdY3io8H4LXEHqrlYSFz8gReE7g3NAbkYff4Hs1tuV3L3VGK11A7xA69vjmBGGUb >									
//	        < u =="0.000000000000000001" ; [ 000028105774836.000000000000000000 ; 000028119944481.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A786024BA79BA150 >									
//	    < PI_YU_ROMA ; Line_2796 ; vMF2o36543Ss93LU7u0E9ViZ9q1jI1oHmcO2fdRmViCvIO4f9 ; 20171122 ; subDT >									
//	        < I7u5oAA23N1LEiU2BmV8s3t1uOCakq5RQ61QDJb8ox09SKc0szx2iQ83ljyuP3ut >									
//	        < 0vPN7Dg0Dmg438ksVcfwDY74MZp3GznqC1cmBvkh9ql1Z9YIrA53O89377dbMX1K >									
//	        < u =="0.000000000000000001" ; [ 000028119944481.000000000000000000 ; 000028130407497.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A79BA150A7AB986D >									
//	    < PI_YU_ROMA ; Line_2797 ; SBOt1E0Abl6KLhfJ15pzn5f6jMv67iyo4CcG3VmnO03B5L4GV ; 20171122 ; subDT >									
//	        < 71XyL1w4r7tLnlb6HZl02GPnqPmMya2xcYjwv0D139eV5VW7U0zjET5g1UoTpRaH >									
//	        < C918Gg25dXli0sjpnU1HhfN2bu22V34qLw0zUxAg0FQ1Bw09OE7iq6e7ZhFPWaR7 >									
//	        < u =="0.000000000000000001" ; [ 000028130407497.000000000000000000 ; 000028142927169.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7AB986DA7BEB2EC >									
//	    < PI_YU_ROMA ; Line_2798 ; 0RyFSLP95U2is4YU7N8LQmqbx0Hl5a0aaiK72aALHaFFZGB6X ; 20171122 ; subDT >									
//	        < 3DyhT5KF5yM2e784AU9fr1zItR90gh69D4C054w1HCy57333zm23N8Ol26FB004P >									
//	        < hu61dZ64aa5zkW22RrvMF3dlgd0pH1M4KIuOnTYypYi4BRcR1Y2G1wbii5e0nVJl >									
//	        < u =="0.000000000000000001" ; [ 000028142927169.000000000000000000 ; 000028149523408.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7BEB2ECA7C8C394 >									
//	    < PI_YU_ROMA ; Line_2799 ; 4h470Ij0mXo3dKTY7MVRQ03oLjsSwkNNhg0YN7lFQ2YGM0Bxl ; 20171122 ; subDT >									
//	        < w3D065HFhd0z1YU0ya9GNJYdv2ru5Yw46sQ0JzGJ6E68qR58fr40nn5sDzTN9o11 >									
//	        < zl3F4Q35t1s2n2Fx14ewxqeL3678vD1mKA7UyP415a3IrRGjBj76v1p68ELn0fLH >									
//	        < u =="0.000000000000000001" ; [ 000028149523408.000000000000000000 ; 000028162998208.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7C8C394A7DD532C >									
//	    < PI_YU_ROMA ; Line_2800 ; D7Lcs73xI1G9nHF2vRxi9KHCRNLhas43eJ0438z84jwvK6c8T ; 20171122 ; subDT >									
//	        < agr5gXEL802RCr7393V0RMU9VXVN9hhx9d3777KQaixO87nnTVc5S6143ZRMEQFS >									
//	        < wk3H5J14f1UV46r3uD7Rik101Va4aw0kZU2iHiq39UIjmn7J482Pn2t5282Y97pk >									
//	        < u =="0.000000000000000001" ; [ 000028162998208.000000000000000000 ; 000028168888134.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7DD532CA7E64FED >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2801 à 2810									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2801 ; XO8E33u89IxHAnNAlDnRBkKc666pip3H3bUEs1325z47avwwB ; 20171122 ; subDT >									
//	        < i1O58sdcw9mue5NVj23u98n7K102SJwTmSz4Fj4qGH3US5kndrpTOpwU3Q9b550j >									
//	        < Cjep7Mai3YtewDv1k7ViXMXUZao7r4v3S8zr501q5u1u4VQ32nEN5YJVKE4e81yI >									
//	        < u =="0.000000000000000001" ; [ 000028168888134.000000000000000000 ; 000028174382019.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7E64FEDA7EEB1F9 >									
//	    < PI_YU_ROMA ; Line_2802 ; wl8fYY88LGSdw7q74gB2t3teFelB5E1Q6396bz292znW76HWa ; 20171122 ; subDT >									
//	        < Iml4Z3ak1It25Yb2Y04YANxzBIs7vu4X7seNmo9C7u94NFQZA68D5Q5X9mVo4T1C >									
//	        < 0QI362ftKi2DB709JIr6ZB713706ExHGdf6buR0yNu7SF62u0Ims3s7PDA15swg2 >									
//	        < u =="0.000000000000000001" ; [ 000028174382019.000000000000000000 ; 000028187434216.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7EEB1F9A8029C7D >									
//	    < PI_YU_ROMA ; Line_2803 ; 2HaKS0ekoSNM9S0l9n4vyF4cS3F2Du6vclNwN046ldRpROFbe ; 20171122 ; subDT >									
//	        < NWVzfo65jzy2Sw5B8PuL1GyvzTeFU1DwR17a22u9C5dK5WBf1803aq0R5pkFRPWv >									
//	        < 6TY2JC5G39x40lV63yniV724D8z9k2SIBH0SOKn7cxtbSzx1qjp85DNUbuSng9G0 >									
//	        < u =="0.000000000000000001" ; [ 000028187434216.000000000000000000 ; 000028197485814.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8029C7DA811F2E5 >									
//	    < PI_YU_ROMA ; Line_2804 ; hctozs7qf490Rg3O0a05w0f99TxAz498Cr65S871424WM9u54 ; 20171122 ; subDT >									
//	        < 1UdZv5iR6E3g66ByVxjf1222r1nV058n4PXsiB1slT17DA7SIxwxo0UnJAhgzcK8 >									
//	        < 7YY75O0qBgh6SMZ5PYIj176Oa1GD8J6UIWWUUF9Wbee5Vs4m7dtJqtpHeJpQl36h >									
//	        < u =="0.000000000000000001" ; [ 000028197485814.000000000000000000 ; 000028202827101.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A811F2E5A81A1956 >									
//	    < PI_YU_ROMA ; Line_2805 ; 05P1F7qSvc6Er089kg61kTmjpc4N28nYcG9I8ib4Ony67z82G ; 20171122 ; subDT >									
//	        < R0IM8Qe1Wx9lZq7ouE8aaCQ2naUn3hVA1zkCfeHCiLxLG92r38h28VqsqVSCuQzM >									
//	        < WeLc7H1sncK7ld198ImGsUa861xdikpHN5H01BAYVLSVa369U3MGR1AqarYxgjU6 >									
//	        < u =="0.000000000000000001" ; [ 000028202827101.000000000000000000 ; 000028213536737.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A81A1956A82A70C9 >									
//	    < PI_YU_ROMA ; Line_2806 ; twdbpaxFOQZUNuQYKi59EJ6c4qOT4NHO3xOu2Z01JJuY4rUi2 ; 20171122 ; subDT >									
//	        < r05rGjvXMi447bA1MdTHXjkNm2jHtqi41OIZiHQ0oAP7p9J852Sod2D161ky621g >									
//	        < lYUx3g0B3oD4zBBN6648wbdiUu7ol84xsDb97CiklS97K9hd7MWPK05C0W56j17W >									
//	        < u =="0.000000000000000001" ; [ 000028213536737.000000000000000000 ; 000028220865321.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A82A70C9A8359F84 >									
//	    < PI_YU_ROMA ; Line_2807 ; HtSvTR76mskDcEymulEaI175028GaeRpD7i5M4IB3rTNY5r8z ; 20171122 ; subDT >									
//	        < A41Y7tk8hRrRQ8l8I3USACZWGO4hF2Cl9lfb8t31X56hVWvggnJNXp10f6U759TE >									
//	        < Khf9qJG79I7LwI42B61aEvICi615fy7F02355r8GC0kg5c6tsGfHZ92pG7gtyU42 >									
//	        < u =="0.000000000000000001" ; [ 000028220865321.000000000000000000 ; 000028227848709.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8359F84A8404766 >									
//	    < PI_YU_ROMA ; Line_2808 ; yvz22zHUzbn79WAAPKpLH2522xaF7NBPdYfITe2hkGwfBG4pM ; 20171122 ; subDT >									
//	        < 0hT9nh88CoFm4PeYUeSVE5m98O0xUT6AMKD4pamyIic6V6qE7uH7miw1wNZ3Uf0w >									
//	        < YyNy4fhMQ2UT90WJ59adFC1MpQCJ7D3N0cV9h1oRgBYJ7ss1GEZ638P46NCGjZMB >									
//	        < u =="0.000000000000000001" ; [ 000028227848709.000000000000000000 ; 000028242205397.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8404766A8562F7B >									
//	    < PI_YU_ROMA ; Line_2809 ; 42IzZJQSVVd3v5J83A298hts3694iM4KU68kCBv91O1gZzec9 ; 20171122 ; subDT >									
//	        < jT2ihq0o99DDb8iC6Snec49S8i22s6JEETIqOtxyuq36jh45sM2616f0b747qU16 >									
//	        < 587xlU7y9363Ii42f5sD3IwevLbC1ZE5J9SsX1xH743a1PSWC710uEUx8eQ28Fc7 >									
//	        < u =="0.000000000000000001" ; [ 000028242205397.000000000000000000 ; 000028255239035.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8562F7BA86A12BF >									
//	    < PI_YU_ROMA ; Line_2810 ; b1Q7Nwp16O1R2Yijg3n49S2ZsWgtN5lbLvvu1u50r49xzZ78y ; 20171122 ; subDT >									
//	        < ou3xKQIXm3gHL69B8i7GUqvswiSHUAQ4CzwuCc259o7BxqmlJGB533c85zPOohZ4 >									
//	        < 0w7i3cQwy4soR2XaAFiuoT39Rfh00VNe1P9mJHbFt13E60UhZBG8c4yr7T5CwNI7 >									
//	        < u =="0.000000000000000001" ; [ 000028255239035.000000000000000000 ; 000028264475798.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A86A12BFA8782ADB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2811 à 2820									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2811 ; 9Aryhf74OD1ve3i5o4sEs3QjUgzSV877HtMN43KzUGBKW5X1G ; 20171122 ; subDT >									
//	        < ttjE9PQfLV5Bi7imU4Yd2NJgs9NxrW0OVk1L760lmaDvoxc5AtuTLp30L5okZ1as >									
//	        < xz8s1Lrx352Ymi5i1UX3Gir32TSts66n8z2j2Eha595K8Y0Cc32VO4nSZ1876qpQ >									
//	        < u =="0.000000000000000001" ; [ 000028264475798.000000000000000000 ; 000028278079079.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8782ADBA88CECA3 >									
//	    < PI_YU_ROMA ; Line_2812 ; 58f2wDT8Uy1V9r7I51u3gzL5AQ9t40Hkre0Sl4M5yP68T5F32 ; 20171122 ; subDT >									
//	        < NRgvB54VG5CgRa555ai96E8Fa5SC81E59Gi2CC6QUif7m46LY5twHueDz6OeN207 >									
//	        < huK8rN7ws1Wa7SHJ1JFE5VT2Tsb01m2a0qOCy9nxFrw79499600VdK4J7l0MtS45 >									
//	        < u =="0.000000000000000001" ; [ 000028278079079.000000000000000000 ; 000028284670460.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A88CECA3A896FB66 >									
//	    < PI_YU_ROMA ; Line_2813 ; YpTDpXFZV3mI2fo5mkteq9PlVI7jhZb2FLA8Nh5LKXJy25LH5 ; 20171122 ; subDT >									
//	        < kQb7wA9ka6pzaN865MoAN9FK32g3bXFFDi0djurv5AE8B3G2DM167htBB8Je8ku2 >									
//	        < 0nibmc7B428c2DbEmP81wq8Ok8AG4b4r5T7Aj6LDAqC79KoKIDuN37K3zIL3EvIJ >									
//	        < u =="0.000000000000000001" ; [ 000028284670460.000000000000000000 ; 000028295894269.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A896FB66A8A81BB2 >									
//	    < PI_YU_ROMA ; Line_2814 ; 3S8A3Zs22svCC47efRu2Bgc4DHB7InzhWbWkX79gq8M9n8kH1 ; 20171122 ; subDT >									
//	        < Dz7k6wqbYiXp879ERKC7N4fbpmJUWFs6sggz9f1874k0qRRtX9UuC68Ra4b0rlC0 >									
//	        < s2iKw0d9jT7Z9MlD24yghZ1z3t872F1fA20hDYsdn8SQK3u9No1Kis1Zaqq1JhJ6 >									
//	        < u =="0.000000000000000001" ; [ 000028295894269.000000000000000000 ; 000028305083620.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8A81BB2A8B6214A >									
//	    < PI_YU_ROMA ; Line_2815 ; z3ISkNqJhJ8pU0B6q7K8okj76CI5TqlVTFhIcopl3045tI6M8 ; 20171122 ; subDT >									
//	        < w8a892Hs041V6T234302rE3AYB67jE8OK4x4kMpbB6m9f15H1PTINBbLi8W9v8l2 >									
//	        < 4V1RmU0QyB91ukAsk123LM4CJtJ1009NPwc4I9c4gAqM09w19YdcW3A0Fu025ZX9 >									
//	        < u =="0.000000000000000001" ; [ 000028305083620.000000000000000000 ; 000028318867299.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8B6214AA8CB2989 >									
//	    < PI_YU_ROMA ; Line_2816 ; H5Jsb2qP5s830sGlmGHUEq5HMaYY3p1uXUhHwPj5J5h1lkyw6 ; 20171122 ; subDT >									
//	        < vPT5M6UJMk25dVEmaft9yL6BwV5e8Z6v68Mg363MZIpdt5Te4Mex5527mO6yJ8M2 >									
//	        < BX700AiMvc6t2gGD4Q7OYU34szBCGc8PyDE6758zCtP4qOGFj0gG5AXU4ZfXIEXx >									
//	        < u =="0.000000000000000001" ; [ 000028318867299.000000000000000000 ; 000028332399770.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8CB2989A8DFCFA9 >									
//	    < PI_YU_ROMA ; Line_2817 ; 6152uZDf1g0s1ryp1a8lTCRbsCuSJ04w9qfzwJiX03YI808u6 ; 20171122 ; subDT >									
//	        < f6mR1Oml8AXcAlL7w7393clmfm6i479Yy26S76BWt663WJ3981sRIhCH7z556dn9 >									
//	        < 9352rK12R9Ii6WeB605toHgQNXNF5fS3raZa3jX3L91GABo10GL3TdWlec7shzz6 >									
//	        < u =="0.000000000000000001" ; [ 000028332399770.000000000000000000 ; 000028345013905.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8DFCFA9A8F30F0E >									
//	    < PI_YU_ROMA ; Line_2818 ; 3499vRI900Rr311Am1suJL3oQa0NKx2e1OqbjnIz508W82DHQ ; 20171122 ; subDT >									
//	        < b79yStG7yDj5i0ej94wGet7s0Ndg7utM0uxSG84If49rV20ZV06C9H2W4uvyqa59 >									
//	        < 6pCs1obQVemU2LUgH3fbk95zB05a81x13PUGcNJRU3QGUW2SNOX7UJ3sJ82yf8N9 >									
//	        < u =="0.000000000000000001" ; [ 000028345013905.000000000000000000 ; 000028358621143.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8F30F0EA907D262 >									
//	    < PI_YU_ROMA ; Line_2819 ; 2NNE9GQ5p4IYg25Ezh83G658Af780rJt4Oo50oPqg6MDQz3BD ; 20171122 ; subDT >									
//	        < 9yb84uAnR802Oj5r3etW25zhJyr6yV4NxNc03D4qP291B5crh69Q0Ijn18zQpP0f >									
//	        < WovQ5y9QazZplDx2Zead17zdJRpC0dhVGb0QV1xBp1qL3GkQwu1Gnqg8Xvap1nd4 >									
//	        < u =="0.000000000000000001" ; [ 000028358621143.000000000000000000 ; 000028373552333.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A907D262A91E9AE1 >									
//	    < PI_YU_ROMA ; Line_2820 ; 5PVGDJ7e97zk2P0qt2nFBC63DjS3MuysCrmqkis2mO5qEb89w ; 20171122 ; subDT >									
//	        < 5DzJbZSEIzAL9J5on963omK40q7CXXsTdk3J0s7RXt42LC880a0YsIiXehRyKBW4 >									
//	        < 0ThuX8M4tzR6x2vQ2R2zUI9J4ec7VcvPUR887439AwOGMySL3i2C0q2W44z19Yua >									
//	        < u =="0.000000000000000001" ; [ 000028373552333.000000000000000000 ; 000028387232016.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A91E9AE1A9337A81 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2821 à 2830									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2821 ; B50h6j5HaME39a23BWIGb4G0w8CO14dve5V3oZlB4FfMH7wzu ; 20171122 ; subDT >									
//	        < 1P5b6pLENVSiN7QJo56XvaS0wc0H6rkP5AIn78HiZ1ab3v3Ea0BwzOR5To0V0t0F >									
//	        < gHcJ6hL503u99HTg86X41TCs786iH0ipGu5GC47DAccp9UMw3k2kcmh89WaqLqpM >									
//	        < u =="0.000000000000000001" ; [ 000028387232016.000000000000000000 ; 000028401932600.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9337A81A949E8EC >									
//	    < PI_YU_ROMA ; Line_2822 ; gR07l94vToeA9GRSmEeFbI1P6I6E0B0HLy6p04621xSHylHvc ; 20171122 ; subDT >									
//	        < S0k7ta22DX85Cd1zU5qwFY1HGbrA9N0A4mwu4iXHH4Aie4oP88JK9D94phMyB2Q0 >									
//	        < DajTGATL340fJRugh4VU626hfQ0OOGMZkISZlWBW4i2HCZ6W0903AwS2o5oIJ5It >									
//	        < u =="0.000000000000000001" ; [ 000028401932600.000000000000000000 ; 000028414232184.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A949E8ECA95CAD72 >									
//	    < PI_YU_ROMA ; Line_2823 ; ci4Hmuztf7QZ4879jEjP3iq65h7zJTMhjgHBJ3U1fLk351Za2 ; 20171122 ; subDT >									
//	        < 97Ht2pJHuVqsvqK8677Uq2x3IpFCs2jbI05AbO581Rc7VYTa4UxwQbVmqeEiLi27 >									
//	        < h3ytL1osm7tos777K8u62f2Cid8VzZi3y9JBLo0q2opMO0821WDfc4XRQcBte6w4 >									
//	        < u =="0.000000000000000001" ; [ 000028414232184.000000000000000000 ; 000028425442938.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A95CAD72A96DC8A5 >									
//	    < PI_YU_ROMA ; Line_2824 ; SzV177OXH9O1RJ8v4EZeQ879709KBsYOKCD8fuTtEM1dh1xA8 ; 20171122 ; subDT >									
//	        < KIlIul2iqfkbPVnkJ8X0gyVWq3l3Ye7I5O3s68JgNaW0ToE2ySjj4Q5JmiuxQWu3 >									
//	        < tFFHg94Nc17NlMhnP5Pvb5oWkbuf761Ljqu3y3sMBh5rAyN6E4uLz1NG0844jKY1 >									
//	        < u =="0.000000000000000001" ; [ 000028425442938.000000000000000000 ; 000028434451327.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A96DC8A5A97B878C >									
//	    < PI_YU_ROMA ; Line_2825 ; 75KRLd1V9D7EDgSAKiO2WCMNC1N3nfZo6IU1Kp8yH4yxwBOC9 ; 20171122 ; subDT >									
//	        < z27PufNuN8MFUWmmDLg2tBOo9I17HDCGkGArS4K4NbbFwF9d28t57xNAy5920OaI >									
//	        < 21MbHL8xFsMH959MK4mI0tGEh3azf0R3Qy6aScOAFb4A2j00NH304TH7E082R1i6 >									
//	        < u =="0.000000000000000001" ; [ 000028434451327.000000000000000000 ; 000028440439918.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A97B878CA984AAD7 >									
//	    < PI_YU_ROMA ; Line_2826 ; Zs220qx8Q49en3e4rTlddzR1135p46aP14ph15K0BQiti9y27 ; 20171122 ; subDT >									
//	        < 1BZ08oKOq1jEQ2t2OW3Qs2WGeUjpo7yYb567qwvSR8m0I2sA113qYPtzyZmlz3Y6 >									
//	        < Mr9uD0R348SL4M2D7n418bdb8GROW8h6UPp361dLOexNrOPSCxBd91DQxvgSskIG >									
//	        < u =="0.000000000000000001" ; [ 000028440439918.000000000000000000 ; 000028452566402.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A984AAD7A9972BC0 >									
//	    < PI_YU_ROMA ; Line_2827 ; 1fJuA31P88B5699Q2s589zmCR8lNOt3Iofk3GM2N2P6kTTH1Z ; 20171122 ; subDT >									
//	        < Ji4r278zoAWp978Jc9AY18h33uIMzNVX9FxAa10pTm1WkO32yE666OqYz198geop >									
//	        < nPdGORH377cqOduAheWDHmig2532D3R7Mq55hH66cICR2fONOws6897UmKy09UEy >									
//	        < u =="0.000000000000000001" ; [ 000028452566402.000000000000000000 ; 000028466317940.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9972BC0A9AC2772 >									
//	    < PI_YU_ROMA ; Line_2828 ; 6Xl71N5cl1Er2agW5I0PmaF4oapUvGPwL6e4FtZaZ62697p1p ; 20171122 ; subDT >									
//	        < 78fK3NEYgEZcUo3f79N4nylsgRKjzgHYY2bYcqb9Tiz3yU6O6Ox48SnFhU2v3Dwq >									
//	        < M8a50WwISlT5Z8099as2M5r439li7gSV21biD886vR7NImL53oI33ZYk005Wr0sF >									
//	        < u =="0.000000000000000001" ; [ 000028466317940.000000000000000000 ; 000028473938033.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9AC2772A9B7C80B >									
//	    < PI_YU_ROMA ; Line_2829 ; w25uSbhiWE10mnN9NunxpFaK242H8sLUCXTVzwWb1nb54LD8t ; 20171122 ; subDT >									
//	        < 3B051NFyaQ293TAM8y1XT5sP1Xtz2kG6sFnBx3B3eQ0v4Bw492f10epNv2l0xh3w >									
//	        < uB86d8cUJ6VsJrI5IEB9UJ5Gw69aj7nK636f2HzIqc7iw3uUYVPkMmaaU5q8KzSO >									
//	        < u =="0.000000000000000001" ; [ 000028473938033.000000000000000000 ; 000028486256782.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9B7C80BA9CA940E >									
//	    < PI_YU_ROMA ; Line_2830 ; X80koVAfl1bbCNJfzgOLOtugaPmfqAt5mVFvCjON10om0QYjr ; 20171122 ; subDT >									
//	        < 0n4TE4zDH4A3f9NOe0vHLZk73nevqa8jcv81WqWbDw3gDu57Q6cRM10pk9I9y5ma >									
//	        < b2NL9Zg05S077Gkg856tRFoB3dsQU8o7x90321bq6rr6nEsNmC558H9EuT2C05o5 >									
//	        < u =="0.000000000000000001" ; [ 000028486256782.000000000000000000 ; 000028497123315.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9CA940EA9DB28CB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2831 à 2840									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2831 ; R7Jr1D770ky0jtgWg36z6YfN9iO5edEip5lBaFh676tHQYfaC ; 20171122 ; subDT >									
//	        < 51ab8E896aPcTY7O474iMQnyUOEe9vAEQM7UT933l6pO6ixSK28ayrY949KqPy03 >									
//	        < z8TqIFfPDP0hjnNPQ0213c283nwRH1YuGYDZf4ov1yEvp8SiVOTec114LkQs7qXE >									
//	        < u =="0.000000000000000001" ; [ 000028497123315.000000000000000000 ; 000028508281145.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9DB28CBA9EC2F52 >									
//	    < PI_YU_ROMA ; Line_2832 ; b566eay2ZXV2Qy82So4JKC74k3wVZRWuZHyn835jcz4D0h2SM ; 20171122 ; subDT >									
//	        < Q8Gfckep8671UMutQsho7Q9zLRQ628vc86ftFK41KaQ806CN6rMCd7Pjzk56sx7X >									
//	        < pORsq62kNm5vWl983eik7DDBCYYeqov791k1I8F2le1nqfti7pk2O0I3bjR77g1V >									
//	        < u =="0.000000000000000001" ; [ 000028508281145.000000000000000000 ; 000028513935114.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9EC2F52A9F4CFE7 >									
//	    < PI_YU_ROMA ; Line_2833 ; dCHCrTE978s2qPX67xCZ01XSWMCQXpZGsyC9z19X55SO52FNm ; 20171122 ; subDT >									
//	        < 9R7i3Pib7uUDV467hr5LW80gW1aA81u3a0SO4nSqbvWc4wbpt9Cn9f0xWE41fvmV >									
//	        < h9d9b2mXuE2dTOLJ77zsN0SEuDPt8eiPXo4639VJPj9J3Q1AtksPOi2BxUhi61E1 >									
//	        < u =="0.000000000000000001" ; [ 000028513935114.000000000000000000 ; 000028521981302.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9F4CFE7AA0116F2 >									
//	    < PI_YU_ROMA ; Line_2834 ; 806DrsF4eqzxdUJ61VC5asJU9EF7IymONPmS16h5WAse89q93 ; 20171122 ; subDT >									
//	        < BF4x1Zv2d0X6lHLzzh79O5JQHmV35x685I73F48ofUKQyD3YP362NJE932Mkh59n >									
//	        < 64rUJOVBW40p6H3x6AxDm36MR8CXw5b9EwO5B6Hv6yO688m72nG4jR7b1v47k7T6 >									
//	        < u =="0.000000000000000001" ; [ 000028521981302.000000000000000000 ; 000028527237357.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA0116F2AA091C17 >									
//	    < PI_YU_ROMA ; Line_2835 ; toQvwSdj1ZU0fc66fbhTy3Dq7TYGc5cHy7nYzQ724u6j0sZ07 ; 20171122 ; subDT >									
//	        < BpsuqBM08qU3az79r7TT2ZqybVeUnBzgbK3XKB1h1o8S13Qs3XNQucLP60nJeTUm >									
//	        < 4e0SD073aKM0u48p6z0t5LDxNBS457v3BC6E7G582xA6SU4r1m00XE3QFUISMF7s >									
//	        < u =="0.000000000000000001" ; [ 000028527237357.000000000000000000 ; 000028535767790.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA091C17AA16204B >									
//	    < PI_YU_ROMA ; Line_2836 ; e7X4lP8mQSY437PJFv8gBvSIYL1KR4iej7dDT4iXai25056lY ; 20171122 ; subDT >									
//	        < zHNkX1m63l4V5x99uZ3C94IWgSIt6PwTC3NoVa9stil1ju3TcvOC0hPzaX4h0LJI >									
//	        < 1dQ9TabXGR5duMYzl3HTzybGYJ285JpJ2r2ZM96mG6ag6nxmLlu1LY2C26L22q6m >									
//	        < u =="0.000000000000000001" ; [ 000028535767790.000000000000000000 ; 000028543097438.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA16204BAA214F6F >									
//	    < PI_YU_ROMA ; Line_2837 ; 4Nl92X3w7WgJjrgP5Z922qMVR7175XH0k89I8Gm9Fg9m2km4r ; 20171122 ; subDT >									
//	        < s7B9I4lDhwm9d8H34fm54FIA8Ak13v705Ax5gr93EJJgLM9AfnYwPnrUmLx3iXr4 >									
//	        < 06xMIp9Hq7miC6FIDhB0Hq6JsleaapDLb6nsA4Z1dQ78FfKc3Xhed7lC29T54dQJ >									
//	        < u =="0.000000000000000001" ; [ 000028543097438.000000000000000000 ; 000028552019769.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA214F6FAA2EECB8 >									
//	    < PI_YU_ROMA ; Line_2838 ; 5IpF35l39tt2H1i2245dTXn8wC24SRqxD4B0TGSZ30Jcidx0u ; 20171122 ; subDT >									
//	        < 6xk707DqNdnP36l37oRod4iyN8BD8ChMLKl6R7F423K33661Ug07kc89w4KM7Ut0 >									
//	        < 7o3nbZn2F20pJqNsVw934K1J9T9Zytje4yVjMWlsr53Lf1z21312jXFH7PvNUxxz >									
//	        < u =="0.000000000000000001" ; [ 000028552019769.000000000000000000 ; 000028564371346.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA2EECB8AA41C58E >									
//	    < PI_YU_ROMA ; Line_2839 ; f1h1l09XYx6sq1120g2o2s7i317mGDfnW6g1IRV009n71o0qi ; 20171122 ; subDT >									
//	        < KCW48X9n5DWMC0hRaT0Tb4D088890ydLUfEl3xwH8ncQy02kN8F87E34fA4xbS31 >									
//	        < 9wIC16ZLigB7ben8zroqjGUkghx141m7Pu6Cx0M5eXPr09l87U6u08W2Ar5HKd05 >									
//	        < u =="0.000000000000000001" ; [ 000028564371346.000000000000000000 ; 000028576671680.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA41C58EAA548A60 >									
//	    < PI_YU_ROMA ; Line_2840 ; zr1n9t2VdXM8b92TEsx0j29SeMkvcYZ3WY8vbwb4J4kj67lBs ; 20171122 ; subDT >									
//	        < cJBWQ044eysJU2u5HX8u17aM2KUl7bj1TZs4VVNU2GaY8f5m9oz3yBP83IcQyWJ4 >									
//	        < kkc5AhC9BKccWgpnWPOsppFO88kFpq1Qrfm787s963OVM0dsW8QSOL64pdFPo290 >									
//	        < u =="0.000000000000000001" ; [ 000028576671680.000000000000000000 ; 000028583577766.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA548A60AA5F1410 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2841 à 2850									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2841 ; M1HSk0rMj9K3A0680g4yNokT3sgHuxWWs4OB0an1jAu6kjdb8 ; 20171122 ; subDT >									
//	        < 6O88EVr6S5g2l5yj4fs1Yy7Z595z51Njyej50aB836Ame7BI6Gg3qsXfSxEYsvEz >									
//	        < c3S2o7yt7Ie94rWRI56X32789d493d19E0ivi9Ld3Qa4TRWkr4M2PEZ34LTJWxTx >									
//	        < u =="0.000000000000000001" ; [ 000028583577766.000000000000000000 ; 000028596667673.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA5F1410AA730D4F >									
//	    < PI_YU_ROMA ; Line_2842 ; 3o57Bf4UgQ8h48ZfySS4aRG8Rl7Js6I4tKs2kS3dw7VdUPIV6 ; 20171122 ; subDT >									
//	        < c2Fb38kK1572e02iHePbhh7BJ6O14vQX2PH36qoMbixN82LLS1RYbI4y4539SmsW >									
//	        < 7fkZt93A015Me7zH28I1YwnMfQ4d63Fv79Co7JVCJ057p58yPwy63zQ1xWX49K4Z >									
//	        < u =="0.000000000000000001" ; [ 000028596667673.000000000000000000 ; 000028608540232.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA730D4FAA852B07 >									
//	    < PI_YU_ROMA ; Line_2843 ; 5WXL6apxmmpS29b8y7zbR1F8g337lE093oCn012JLwQBJdbN7 ; 20171122 ; subDT >									
//	        < 78zoq94w9jBudfF8zKMuyv8GuYFP276WX4D4vo41TAx7772ZyOIHLsH3s7fHnHq4 >									
//	        < lwE8AQ0M9r0862BzBU7cy4VuFFiWXytYeNtUf9iGn89KcZY0Tufg987UX4q73X3W >									
//	        < u =="0.000000000000000001" ; [ 000028608540232.000000000000000000 ; 000028620230829.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA852B07AA9701AA >									
//	    < PI_YU_ROMA ; Line_2844 ; 3jB6W889D66MPDPG5cB2NscD4l1H7z10pHq6veaERm1JcnSLb ; 20171122 ; subDT >									
//	        < qzf38kj6rhla9RZ1ZFsdk0iz2R4taJ5TvUNUZiGm314OczJpDx7106wh1T9xa6uA >									
//	        < hU3Gk7QOTM5hc94p48aa6lK296gfGI17ilYE2lA1D7RELgP4ajW58DLXkwTAkn6U >									
//	        < u =="0.000000000000000001" ; [ 000028620230829.000000000000000000 ; 000028625840814.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA9701AAAA9F9111 >									
//	    < PI_YU_ROMA ; Line_2845 ; 0bMuN4Flq1IZgX6MidBxPJVtPxK5331Pa7j7IcxjJTvN42MRL ; 20171122 ; subDT >									
//	        < 6HsKrXwX2u5smOFANdG8W52O4371sd7O148qwkGY8jU2fmxeYORNeVGezmjQUM4t >									
//	        < c3ZWadA7O8d3M7cww5tXzpq1uIrslHuUn028w3V0PxqafYl00yys2K4mFP84r427 >									
//	        < u =="0.000000000000000001" ; [ 000028625840814.000000000000000000 ; 000028634651043.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA9F9111AAAD0290 >									
//	    < PI_YU_ROMA ; Line_2846 ; 9sKZS7UL4CAd2iHqy8k9K22wAtnj1Pzhdo6LlHhEOOWo9kwjZ ; 20171122 ; subDT >									
//	        < 5V4EEjTgM9i17e4HZe3s3QmH62ze7Es9Gj8r1tNJS39yu3m2OlkcwmT18925qgc5 >									
//	        < Ieal49zV3Y56R7xSHyOUTYvnvCO2K7V9X66n7xkHzzTK99p9q1LzToUMLwDQm9Jo >									
//	        < u =="0.000000000000000001" ; [ 000028634651043.000000000000000000 ; 000028647519679.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AAAD0290AAC0A55F >									
//	    < PI_YU_ROMA ; Line_2847 ; 7VRhOT6U7Vknu08NFPDo53YMkXPBMSw01uMPzu4ANM3zmh0yn ; 20171122 ; subDT >									
//	        < oGo1B288302IFY7Oz89CxVjdgm3V2qxmTPbDDFOF4u7K5e6zZjIM4ReveTXJqv9H >									
//	        < ysBLWTffHMf7O5eDwx9mleigSf39xk3Jv28Af190Xar44NWYboaoR02Ks1CY5JK9 >									
//	        < u =="0.000000000000000001" ; [ 000028647519679.000000000000000000 ; 000028661121405.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AAC0A55FAAD5668C >									
//	    < PI_YU_ROMA ; Line_2848 ; 12gdUW5Co637TaVWePoFHYVdYU44dF7Q9z4Rr81CAJ3UO82Qh ; 20171122 ; subDT >									
//	        < NN7Y9qYQ74l1N55YXzvJYrj756m8zdAj0b54ksiraVp63O8pgCTD9IzLY60LK3MR >									
//	        < 4wu9I9959IGMzFuwF1v90F8VYZ077Nh41h50RAZ7fu96gT8NHRtQaw7pCt4srKAm >									
//	        < u =="0.000000000000000001" ; [ 000028661121405.000000000000000000 ; 000028675079420.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AAD5668CAAEAB2E6 >									
//	    < PI_YU_ROMA ; Line_2849 ; s871c290W1LClGS7339U7VOv95d5lq6JQX667DNhfoX99qf2X ; 20171122 ; subDT >									
//	        < HSGtl8QuFqPB2RVhJc0uxYDsY3Xg56Kdl5pb5TA6Z3znsyF6Y8f6nmZ069K7N6cM >									
//	        < 15L4qvb5V84kX51zm4SXf2sXakqMf1iN2Y7pJqwHOYknlR7B5WSun7y0zc0h1tNi >									
//	        < u =="0.000000000000000001" ; [ 000028675079420.000000000000000000 ; 000028681641810.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AAEAB2E6AAF4B655 >									
//	    < PI_YU_ROMA ; Line_2850 ; Er9O8LpxixN83XM22BGe590YwgwqTMf9TRNY1vjFRgkYGuOLe ; 20171122 ; subDT >									
//	        < 6n3vWcs43bEDZLAUEit66yEd7VHS4Z5Ll73dxsK63Fqe64q7D7VIJaG6TzvbJ8Gr >									
//	        < RSgd3vpYTwQ826zE25071h4o98947c2tc57j0ZZTu7C445xD1Z11R0JSPTp2c64B >									
//	        < u =="0.000000000000000001" ; [ 000028681641810.000000000000000000 ; 000028687871778.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AAF4B655AAFE37E9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2851 à 2860									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2851 ; ie1mu6ZKPU10YHI35AtXzNHcrvGQz4CC8gsPKT1Md6U7V6lkL ; 20171122 ; subDT >									
//	        < A2Ha7hB2UV7Sz9R4ygSKTewV58t818Du9k9Dby9P7m9Y855T2nbgoFUkBrdqy2AQ >									
//	        < Fa18x7uhf5tbrmgrH5IMn7oLGy2ngatg7bSo7YpghCZHCk3HwL4sJFCT4m0Z857L >									
//	        < u =="0.000000000000000001" ; [ 000028687871778.000000000000000000 ; 000028701199333.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AAFE37E9AB128DFD >									
//	    < PI_YU_ROMA ; Line_2852 ; 9tf26fG63krF8PLjN2RRa68bDFisXKvFg12d8x7i7Rj104xjv ; 20171122 ; subDT >									
//	        < dzMLD42ZC3V56kfWwVV6I3y5eb7Mof1zJjlI16xJ3cwDk4I7563M68do2kfcTcJr >									
//	        < 31mKeqgBx4aOQpB54afYEj2I42D90biYfh0Em33L4M6OEa2Mfdt9286duFrqoT8w >									
//	        < u =="0.000000000000000001" ; [ 000028701199333.000000000000000000 ; 000028707468794.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB128DFDAB1C1EFF >									
//	    < PI_YU_ROMA ; Line_2853 ; 1763mgcH2Hnr67Np59AL3hx15q852LDiAdOyExC77kk8V4M5m ; 20171122 ; subDT >									
//	        < WNxs1m7e9z0z4zono06wwmOwt086iteYUHI3189WXa243t49hG454nXB5Lw92CXF >									
//	        < 46wNRJ7cBRPLy36qFO7PRH9z1uTs0wOk5BR175Ao86Tr8r572tP9zZ2BumTjlVXn >									
//	        < u =="0.000000000000000001" ; [ 000028707468794.000000000000000000 ; 000028721327061.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB1C1EFFAB314462 >									
//	    < PI_YU_ROMA ; Line_2854 ; Zc75e40HSIYtzerSX02P7so41w611WPEyui62mofft2r8SEpp ; 20171122 ; subDT >									
//	        < cgS8Wq0dX21op4Sw0o1W61e3976f61kDk3yd6I514XXRQXkWhztS4Hv1gAqjVYZ4 >									
//	        < 4L2BCJPK4tl4vkFBPp1hyU82AqtJCkCUx49lBk4FmOEG41gWN2RzN72HxMp1rgHU >									
//	        < u =="0.000000000000000001" ; [ 000028721327061.000000000000000000 ; 000028732152206.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB314462AB41C8F4 >									
//	    < PI_YU_ROMA ; Line_2855 ; GB5Eq72we3ozS411XmbmRPcfjAFL8Li774B0h0Nr35Vq84087 ; 20171122 ; subDT >									
//	        < LQhyyKu173bSrRXE7TPIB29QmllpNr4sGfvJjv7P9kW83mT7CM9Zu0IuR40Pda0y >									
//	        < 1ze7T0770oM1wEUY94Zc7BMQ6SHkUUNlX91e5TYOIY8mFJi90l92PqW1q63PtOnh >									
//	        < u =="0.000000000000000001" ; [ 000028732152206.000000000000000000 ; 000028739310189.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB41C8F4AB4CB50A >									
//	    < PI_YU_ROMA ; Line_2856 ; doVk446AclatW0L4GrC65LS7mQbswvl2XNzpe4kMr02Xqfk8q ; 20171122 ; subDT >									
//	        < t1biRxivsCEb4FCgyav2rA561t66EK066KExkRilwx6TF5ru8Q81sJMW4U3NFZqU >									
//	        < F0krr57O1lGM9Gt01d109x873OTMn8Dvb2cuiFbJGDx4ts349S1oUrOUxTe44w9v >									
//	        < u =="0.000000000000000001" ; [ 000028739310189.000000000000000000 ; 000028749642984.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB4CB50AAB5C794A >									
//	    < PI_YU_ROMA ; Line_2857 ; 9Es4vQDC7A0yA0bPnCCccQvk571VFElPrt7NFBYsZ6t89w4lt ; 20171122 ; subDT >									
//	        < 55f2DWW1eH2Fzm49H9gdH0PK3rXzFbgWklu4StkpBK5opLk0GpVRm7Z90dzuLmvj >									
//	        < pv1202sMvXqsJIqCA9WX6F9y0v8MfLIi8YfUSG7r82u1r6PlVT82tya7ek6G14Ba >									
//	        < u =="0.000000000000000001" ; [ 000028749642984.000000000000000000 ; 000028757486755.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB5C794AAB687143 >									
//	    < PI_YU_ROMA ; Line_2858 ; w8057gm10UjA38rrO01F4YE6B700g4b9X3qlmEtDCyiClcc1k ; 20171122 ; subDT >									
//	        < 0YiBQTZCWILvGZN5nxvt5T7yCGc8ykPyjgciaas4CPDxxV75wEF70yk73C26xqA9 >									
//	        < QcSfuHn82pnb34vbb8I80Yt4EFs39B9q13Cpk5Q3dxS7z2o2TzKra7B3I5A43RyU >									
//	        < u =="0.000000000000000001" ; [ 000028757486755.000000000000000000 ; 000028771063464.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB687143AB7D28AA >									
//	    < PI_YU_ROMA ; Line_2859 ; 23yy5sw6qApl381eeMSABSx42eI870wnO6ZNBR9c37NQMr81m ; 20171122 ; subDT >									
//	        < qqhveHFjkaA8e5DnA90Z5lF49z8L29IMDwz9J312J54LgO29KgOT84c2sy31O0Bz >									
//	        < 0t4Zi1let60345tK4OidGE7Cv0X3hcp9x7N1TBh19huAqItC66acyyo6F6F4I48J >									
//	        < u =="0.000000000000000001" ; [ 000028771063464.000000000000000000 ; 000028776440868.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB7D28AAAB855D36 >									
//	    < PI_YU_ROMA ; Line_2860 ; 9I6l6dmeHJHs4E92W4j8OWCFnTrx0D1kxOd1K0L5k025NHEaT ; 20171122 ; subDT >									
//	        < o226yjCr1WYw6DoUp5r6U4uN278TVWaiJEXFHEH7DMO7RFJlLW6iHZl6ZD1oJ5v1 >									
//	        < aWymkx091b6A3lq8nblEo86Z2vQWMKaf9SFt6Wy9R0r0biWACz9o9964oA01J4Pm >									
//	        < u =="0.000000000000000001" ; [ 000028776440868.000000000000000000 ; 000028782910569.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB855D36AB8F3C70 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2861 à 2870									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2861 ; 998vNWV2gg759Y0o48D82Wn5gqABSJCIm2ZY41l428RU61kiY ; 20171122 ; subDT >									
//	        < NvzrJJiVEx74JigeVbk5DdUHIZ0QG40eT1ctopO1K3Id1wFVn3mdfodggv3K3B4o >									
//	        < rP82a2040ThBKiNa65DpW51u1HF2pUH8Lud9L8U6B5e0OKDyB64q8d4DEqzua5W3 >									
//	        < u =="0.000000000000000001" ; [ 000028782910569.000000000000000000 ; 000028795402587.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB8F3C70ABA24C22 >									
//	    < PI_YU_ROMA ; Line_2862 ; PhMO888Gt5ej1I10z5wAeYANCEXSyoS0EJMAnKiZ8Ugdf0Khz ; 20171122 ; subDT >									
//	        < 9Q9h2Gxu3gq1UNhF69jjLGWC6NFR5X0m88nOr4pxj0hG25C4e541Wl84zMeJEE1i >									
//	        < T6n5k8941F158Q57FKfSSzBTF1amri906uXO26tBqdvL70cO5T0MI783dw7PIvgi >									
//	        < u =="0.000000000000000001" ; [ 000028795402587.000000000000000000 ; 000028802699392.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ABA24C22ABAD6E73 >									
//	    < PI_YU_ROMA ; Line_2863 ; 8soVi862tOnY8Pi6Wd06JytYS8kWL3SU8h045OaasUk3JFRUf ; 20171122 ; subDT >									
//	        < Nk402LrQ7Lwh1AN7nlZ7S3y70H0gxY5c202FK7k792MZDYN99SpQvXin42C8roi1 >									
//	        < DX1w098933r1t3a1qE9z8JhhEd78L39c0ehyRBru6lUsH7A4QG23n12p9H77XMj7 >									
//	        < u =="0.000000000000000001" ; [ 000028802699392.000000000000000000 ; 000028816509324.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ABAD6E73ABC280F4 >									
//	    < PI_YU_ROMA ; Line_2864 ; 074HryW2rp4r5t7Z2sYp10M48km3x35Vnux3WL8003ydD875w ; 20171122 ; subDT >									
//	        < rY0ZP62cYAI0I4T6MT96s0L2hPJHklmDIEKQWnO1ii03FG792dOkT0j51xc3334r >									
//	        < K9ttQbD9S1Z88o9eO588606RAL5431R3pLA4ekjx4Nitb3AMlTL6mdECQKXFsm3E >									
//	        < u =="0.000000000000000001" ; [ 000028816509324.000000000000000000 ; 000028828191075.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ABC280F4ABD45423 >									
//	    < PI_YU_ROMA ; Line_2865 ; v2AiA4GfiZKwiT7O9QTjZyH1RssGh51KhOrdQl5t4bLJ0HN6j ; 20171122 ; subDT >									
//	        < Qu9N02dMO5bPM8Fu3fSub7x57ySC44j6t09qX9G61753G6l3X47FWGeJ90CY1coI >									
//	        < lHyMp5DV89tRTA4NhW14OGF5QVn0Xe15zvkaUgWUptGbl4pFSc6Rnn7csZMoV9WL >									
//	        < u =="0.000000000000000001" ; [ 000028828191075.000000000000000000 ; 000028834960348.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ABD45423ABDEA862 >									
//	    < PI_YU_ROMA ; Line_2866 ; mzw7alKe8GtbT2gU14aE88miFO2ItQ8Q42hC27HBbfoaCzLz8 ; 20171122 ; subDT >									
//	        < TBCuL848Vmpd6uEoAN6y66lGNMjxE6yPvO7izFntsv3T7EvSMz3v760IoMYuwOF2 >									
//	        < DNQ37UuaE9twvB392wajmVv6z0726AtI4h5Njb3627s51A5PrLt5ynPoVI9CC8MA >									
//	        < u =="0.000000000000000001" ; [ 000028834960348.000000000000000000 ; 000028848165118.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ABDEA862ABF2CE7F >									
//	    < PI_YU_ROMA ; Line_2867 ; KA0w6flp0vhxwgpXL9K88v0os4jgv5ntaJ5O5p2X8K662Dot3 ; 20171122 ; subDT >									
//	        < t2p51z8i63tPU06L7K18274NT7ygkCwD98Hu5pHL166Z8eGs6lcci2dAv2OWaAA5 >									
//	        < IOc9A3700Vi9jW64ndMusoaDne33SlRqTUX2ww30oFcAG5806IPD1984ANqSkX07 >									
//	        < u =="0.000000000000000001" ; [ 000028848165118.000000000000000000 ; 000028859159480.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ABF2CE7FAC03952C >									
//	    < PI_YU_ROMA ; Line_2868 ; Z2mB9YB9735eZ875VUDZB76eqs53Qc2x2bQ0i9511LRI2KZ8j ; 20171122 ; subDT >									
//	        < 95zyc8utxY6H7i0CF2rdg93ozkQ5aFHU9yfAs8YX1TXftT5z23TR9Ib13H1Cfr30 >									
//	        < 50I3GE0FRh5Av8FgrOgocL4pA9MOu7YnCb8kzbXdZ4D56Z1ymx3kcfZ7ieDtM569 >									
//	        < u =="0.000000000000000001" ; [ 000028859159480.000000000000000000 ; 000028866271560.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC03952CAC0E6F54 >									
//	    < PI_YU_ROMA ; Line_2869 ; tFhe81B99nIz91Kq97z2fDIoFvY3I2Oh1NugNJ2u59aPu3L2g ; 20171122 ; subDT >									
//	        < t4y5R7R133SxdDsBRbqjy4bxPS37xQw4sk7U1JX7jhXGMyreTLmTv1G9rUj606U3 >									
//	        < LHC5iAV746qSVIr0OtB3gbY0JqyowiR8RSqn5E1X044UlEzxSiXXBsxNIsPKUiuZ >									
//	        < u =="0.000000000000000001" ; [ 000028866271560.000000000000000000 ; 000028879856081.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC0E6F54AC2329C8 >									
//	    < PI_YU_ROMA ; Line_2870 ; p8m29ptm0vB7zfFvfkSltZ742lsU4B0ISiS4Z75ee6b3n8UNh ; 20171122 ; subDT >									
//	        < nC61RhyoD68Laq4o5G4Zl2055H9M027jV9Bjq37qV7ejO9h7yrKSaQ808cB3YBXh >									
//	        < M52fysYZE5Y3Yo22rkR1AQ7mGyFsOkjSWGqT7q0C1X3cZI7K13X2007t27N7c6EK >									
//	        < u =="0.000000000000000001" ; [ 000028879856081.000000000000000000 ; 000028888689079.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC2329C8AC30A42B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2871 à 2880									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2871 ; m45wPz1m7K36K6ZOHAp0Xa2W3zT6i6u2a4NX1VN9DyF2y6Hd9 ; 20171122 ; subDT >									
//	        < 6Q4EQLKR1baJeJn7Zst5NvS1T7ZgdMX12501ybUK6C7P1PH19mo59uEB8k7GbrW7 >									
//	        < 816jdPm491oc6274X5A7h8R92TX88SMFWPNoeDQ42rfJYZ8Oz4I57T9nQZsowgJ7 >									
//	        < u =="0.000000000000000001" ; [ 000028888689079.000000000000000000 ; 000028896802501.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC30A42BAC3D057A >									
//	    < PI_YU_ROMA ; Line_2872 ; YCIhlX9HcMD2C3CvpO0xYBYvA5NZGa2Tb8NdrIkq5J7Sjuayp ; 20171122 ; subDT >									
//	        < uXAzhE3d9APgy3i4093vWAevO8lT28Mj2fbh5eyxHI54pU6TpLR0zW2dr412A2C8 >									
//	        < kq9R02gGvW09PtmFI9I0u708j48sT5J4bfQbsRBbsE7hA32OGh6pVJN8v3bxmp7b >									
//	        < u =="0.000000000000000001" ; [ 000028896802501.000000000000000000 ; 000028903660285.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC3D057AAC477C4C >									
//	    < PI_YU_ROMA ; Line_2873 ; 4qiT9wsm9lG17hZ2PZuXlmxn4E2O8XIu1mg4BzLnm3FV1p2vx ; 20171122 ; subDT >									
//	        < wkAGQ10xO6TzFK1mncIo7RwUDtqnKVL5LBqARkghPnUlxpraiu15Mg9QdQjdeY35 >									
//	        < wRVc88Aqiiw757Cs0D4tOZAmR5Z3cWEur7db6sL5DP0S0kxmocYuf9PmvaGGz062 >									
//	        < u =="0.000000000000000001" ; [ 000028903660285.000000000000000000 ; 000028911960695.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC477C4CAC5426A5 >									
//	    < PI_YU_ROMA ; Line_2874 ; 8XbW4S7n27h44PC2J0nCGL4TtW94MGM9S130aq6UqNdTY5v7m ; 20171122 ; subDT >									
//	        < TDw4xA5037658j5HTaRZ2E7k8n6bBhofeF3yn8T63b09iH7iuhvWuZWkHBaeNXIc >									
//	        < i5SX0OEN88ou5Eeqk4aV5CfRwP97WELyRJ45JWZ0OU5UbMHlU7CJDGp1IfFDL2X5 >									
//	        < u =="0.000000000000000001" ; [ 000028911960695.000000000000000000 ; 000028917872430.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC5426A5AC5D2BEB >									
//	    < PI_YU_ROMA ; Line_2875 ; w3d5a4eFW684W668psQNn4US98MnEA603oNkqJ91n779CUa47 ; 20171122 ; subDT >									
//	        < md2iq932Pt6vx6zR62p939Kj077yS315mmL3Nkz6BXjWOKijL74K742BH3g9Uk6V >									
//	        < d06sXdf0W9PT424QuPayvBIfqs1i9YAAGljw5sOMovg29uvt362YZ68F876zco6v >									
//	        < u =="0.000000000000000001" ; [ 000028917872430.000000000000000000 ; 000028926147062.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC5D2BEBAC69CC32 >									
//	    < PI_YU_ROMA ; Line_2876 ; dzeF072eFIu3WFo3uN0luhkswF6uhQ845oA1d04ICFo62h85e ; 20171122 ; subDT >									
//	        < U6TGgJpr8IHQI01k2wPNH6aiUqf6DbybZtToIJY6HJpndlonQB8rHAb456Y47k16 >									
//	        < FK4fN6qTD5VSI6e3Qlkp26R5R8tM7GDMm1BxSZE5Z903uHjhhvQ0B8vX4ljQoFgq >									
//	        < u =="0.000000000000000001" ; [ 000028926147062.000000000000000000 ; 000028939742599.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC69CC32AC7E8AF3 >									
//	    < PI_YU_ROMA ; Line_2877 ; P290BQGY4d1jZvp4O06Bj14P9OHzYa1TT7neR44Fll1yez897 ; 20171122 ; subDT >									
//	        < s0DMMvhRkXRa18I5uKB87IMi3lvibE6nHnNfnb4ECGmCLEdDrbuyZVGLLIuNiL1t >									
//	        < O7N74veIRvYuO56BQedMo2iRoXjCXFU480GfweLP3d23zAF016QjQJm5eRS33a6f >									
//	        < u =="0.000000000000000001" ; [ 000028939742599.000000000000000000 ; 000028947786655.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC7E8AF3AC8AD129 >									
//	    < PI_YU_ROMA ; Line_2878 ; 4LR61qj5d1tKWuXpT883zjaTK6T16A7H7Nz0hZkzg4i5J3C4w ; 20171122 ; subDT >									
//	        < 7UyekO0dKTiWlotGw2wx9zEx09qexM71zd3ZEnVyVovzv4hfhUY7ICmPNA3yNiQ2 >									
//	        < 2N195xMmoHn6otXgqd4tz79yposhCvOKMdab5QFpzVaia763s4e4mliX4hT6Ax9m >									
//	        < u =="0.000000000000000001" ; [ 000028947786655.000000000000000000 ; 000028957990706.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC8AD129AC9A631E >									
//	    < PI_YU_ROMA ; Line_2879 ; 6g16SCv26o7E5NNPcsM23sB6o96vVNcIBSXENX63ncuJPGM1d ; 20171122 ; subDT >									
//	        < j5f70cyUrqdF17Tu957EWBLpi0utunJwkD5141jdkuAO0vw6dB8wL124SMZNe1T1 >									
//	        < H3c0n86RzdFymwe32JP6nPsA28783XW0266z4veWgC56lW65TY1DuGPe6572j74Q >									
//	        < u =="0.000000000000000001" ; [ 000028957990706.000000000000000000 ; 000028968403187.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC9A631EACAA467E >									
//	    < PI_YU_ROMA ; Line_2880 ; Q7ULZDjvG5Eae05g13D5D8qR2g333I35bKaXgXvf5W1r83k59 ; 20171122 ; subDT >									
//	        < EN71yYDiPTEUiTE7AYocfwVxiRd7VW750x3ax13kMyMQ33n6jTbXrLM9a2fmTMvr >									
//	        < WBXwb3C3noK9ZtynghXAF1avs6GvnGFixnRwyC3iT6czv39i61N3Et9mi5tiu0yE >									
//	        < u =="0.000000000000000001" ; [ 000028968403187.000000000000000000 ; 000028977001544.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ACAA467EACB7653A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2881 à 2890									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2881 ; KtS3cZb5ojM258fqi3Mr1mBiW7ITlJEm56UlT1p8Q7Y3zj4ed ; 20171122 ; subDT >									
//	        < 2g21ljlgrq6Y7EwMnEMrDgjkZdbV1BGiiSeO7P437zZOnuD85U6QEOmVRmWT8720 >									
//	        < q3H5jE5JDyf5tO5M9QT2RpWHLVc1114v8kf8c5h08G463Q6boW4qbCU37IWDlHly >									
//	        < u =="0.000000000000000001" ; [ 000028977001544.000000000000000000 ; 000028985860068.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ACB7653AACC4E996 >									
//	    < PI_YU_ROMA ; Line_2882 ; q0Vy2x6f37mirvNX06YKzz76qH3wK243Nbms93P38N0esYQw9 ; 20171122 ; subDT >									
//	        < U21R56V64u3ljYiJfc4dp6JY863Q5UK0mi5rnpqYnfqz9mpvKG75isn0543YyEkC >									
//	        < THM1VuC1quOmnXxEvQkJA9ondgnSCSSls8VY8S5V0bGSB6FdEBvotVuUhm2X1UBx >									
//	        < u =="0.000000000000000001" ; [ 000028985860068.000000000000000000 ; 000028991096113.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ACC4E996ACCCE6EB >									
//	    < PI_YU_ROMA ; Line_2883 ; j8611iB98soqU6e46i2DI94255NmxgOHtnX8XuoSyCcebChIO ; 20171122 ; subDT >									
//	        < N25DmMR8qh0w9TVCWfIPO1PvCnrfbTMD7Puhsv13olAR7Eg1I90XdoKRx4M37739 >									
//	        < doXtVrS4m4Qje3yNo7WNrVn8zJCchN365M5j1rLU7imH644F2XwvvhNfN54a7FD6 >									
//	        < u =="0.000000000000000001" ; [ 000028991096113.000000000000000000 ; 000029003013240.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ACCCE6EBACDF160C >									
//	    < PI_YU_ROMA ; Line_2884 ; QL1L1I5A91gE3KBfFo35LBFq9S3e1yVI449WS50R0z71tLHU7 ; 20171122 ; subDT >									
//	        < KB7lbeI8WLv13Z1gzu4oc8DlOQ7PM4NG5IJs1yzZvCQ4A351rtu9KR9pF7jj0i39 >									
//	        < 06fS34lnklh816Dvbl5APTs7kjSahVI38H0rV0S748C3zv7Yl0d51y9L0qi6R8Tp >									
//	        < u =="0.000000000000000001" ; [ 000029003013240.000000000000000000 ; 000029013727491.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ACDF160CACEF6F4D >									
//	    < PI_YU_ROMA ; Line_2885 ; P4z16Pz75fV0hN87l93648x9C6WFf4ePlB36621YTPAnhky3k ; 20171122 ; subDT >									
//	        < skrc24xL4qeOJ8374c8MxBDl4NYGg9ubHXD4s7yyT5Pht7hH274V5i4E8mf503b8 >									
//	        < 0HRu0ZIM61guOys8w9P8SMA2VOE1q8s27H5NNrYPXUW02hbjeFb461YhSQ84Q3GU >									
//	        < u =="0.000000000000000001" ; [ 000029013727491.000000000000000000 ; 000029024465345.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ACEF6F4DACFFD1C6 >									
//	    < PI_YU_ROMA ; Line_2886 ; ZBwp5o9U1fP27f76TYK5B6YYN9C0Zr28uJKJ2Gw0gh0m64A6p ; 20171122 ; subDT >									
//	        < 8h56sH5VX4f86fTLH2CRsa2G7L1JNUsA0AYPMFe2b8iwI14ZwUXvwZRU1EdCgko4 >									
//	        < EIlNvp714qWP7mjOaU8VRiUcKYh5sa496FV0tKjJ84TOd8H46WL09xPPQ69AtbJ6 >									
//	        < u =="0.000000000000000001" ; [ 000029024465345.000000000000000000 ; 000029037968633.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ACFFD1C6AD146C7F >									
//	    < PI_YU_ROMA ; Line_2887 ; k3pekXUhtyvPiP44vT7ph1f1awrnUNQ587d7wF059yAhtAq75 ; 20171122 ; subDT >									
//	        < GvirsfKzWc650nENQX3GZxK6V52xdT409gcC5F0CTP8G0r2SIP2shorpa8n8wLGG >									
//	        < 94CR8NuT1C23g59VeRlsULcIIEybBz5hxiG18D3Z19tB9308gn8DT9rwBQw3uT86 >									
//	        < u =="0.000000000000000001" ; [ 000029037968633.000000000000000000 ; 000029051867134.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD146C7FAD29A199 >									
//	    < PI_YU_ROMA ; Line_2888 ; a72amCIKDL5x5evzq52BntZ7QcqLol1Tg5M4gut6VGxRG7urQ ; 20171122 ; subDT >									
//	        < 6t5Tw1iXT6NjY3S9901QYg6f6ytpJ7Quw0NY97Gg4ANfjI34Q0eQyHy9NXF3y069 >									
//	        < 8k8xS5Mi2Tk2o7jwFMA6lSqNK777VJ9lm22A7hfOGvyCvp127aQQ8MzCyDV72htK >									
//	        < u =="0.000000000000000001" ; [ 000029051867134.000000000000000000 ; 000029066143644.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD29A199AD3F6A5C >									
//	    < PI_YU_ROMA ; Line_2889 ; G02Xuf18nB249W27U2n80tGDP62196I8RZQvPO519iDXete8l ; 20171122 ; subDT >									
//	        < ECJ6S3kN14Bx3D6Ms6q6Q25f0J27eh7mwZsBxYpyTtwLCddAOPm5R66og6i8LPSD >									
//	        < AdlvsIx3yj2ymnFZ91BrfH2LZo3qfyo6q387fG56JRf6c7Go81KvV203T0980b61 >									
//	        < u =="0.000000000000000001" ; [ 000029066143644.000000000000000000 ; 000029076465336.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD3F6A5CAD4F2A45 >									
//	    < PI_YU_ROMA ; Line_2890 ; Fp6G7D98q7JOqi1eE23XC0FGav14I2rLv20PO06amV84ERmF1 ; 20171122 ; subDT >									
//	        < pUYgzamcX93a8V6Y7gZELo50xrw2C6yyZ9EFqHG1bsgaelykIPL1C28E1xk59I4C >									
//	        < lma99pw11KShii0Ls3OWi029jzPXDhr1Q4Hh8ZIQNUM306F1TY60nFh6S0L48li5 >									
//	        < u =="0.000000000000000001" ; [ 000029076465336.000000000000000000 ; 000029086330104.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD4F2A45AD5E37B2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2891 à 2900									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2891 ; c3fyC4ujN47fWE0o3hh4932w6rw96CI3FTHR4YmNyRz40X5I8 ; 20171122 ; subDT >									
//	        < ej9oE281gHL3OW4yUKDq5iAVKGCgb039k8CBH0Hd4c8L523037stD0ra94Bn8uA3 >									
//	        < FBm2Q69Kyhdyk2op5jjm1Hbct42E7HoTX9OURj83AyCMnyds6zd72i8Fm6qewiWW >									
//	        < u =="0.000000000000000001" ; [ 000029086330104.000000000000000000 ; 000029100744953.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD5E37B2AD74367F >									
//	    < PI_YU_ROMA ; Line_2892 ; sKNCVd9ldAh1B56y99T6G1H7Ro9KWe8NaXK9bMxFIIlKVh4N4 ; 20171122 ; subDT >									
//	        < E0rsfhCa2CA432oL8N0H7MY30g17lKMfEROU7h3rulf9W8h9ti8EtG320GESNpqA >									
//	        < 0fXCB8Fp64y3H3N0Y32S7dH36bWX37RBlQuR407W3W4jg118uTZSL8bw6t1y7m54 >									
//	        < u =="0.000000000000000001" ; [ 000029100744953.000000000000000000 ; 000029106961330.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD74367FAD7DB2C5 >									
//	    < PI_YU_ROMA ; Line_2893 ; 664ibtbtlazfUwQPOHOv7n6SS1x4I7OVMBl488HQ22AREg88O ; 20171122 ; subDT >									
//	        < El1426512R1T3ziZ99SrCAKYWv563i5N5AmNo61p2Ka2751d1zFtt7SbW307K6XJ >									
//	        < z2F9yE57NoyvN06MocxQ2s2oZyTDjZ0T1en0OqP6qBhbb10Mz6M9Q1edRtHcoNj7 >									
//	        < u =="0.000000000000000001" ; [ 000029106961330.000000000000000000 ; 000029116507094.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD7DB2C5AD8C4395 >									
//	    < PI_YU_ROMA ; Line_2894 ; 4mIE67SuIV1zvaN011612E27NDe9SM9N11rrRAT590b0857Pj ; 20171122 ; subDT >									
//	        < TRuRDsFF3nq6M40tXVdTertdtUFOnZs80j067w470P29b3Ey9vZe2n1eq6o84o3f >									
//	        < Kihi00zyoek58qU7dp5xkyc09miv27kB5lYEO76r7P9t9ff7x0eWzY4tu0jUKGya >									
//	        < u =="0.000000000000000001" ; [ 000029116507094.000000000000000000 ; 000029121990764.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD8C4395AD94A1A4 >									
//	    < PI_YU_ROMA ; Line_2895 ; Bz1trY2L0U0RVlL08sf7STGnptdu95QS83YmY2s3ru4BvVGqf ; 20171122 ; subDT >									
//	        < r9497m1b5qxihNPwb289ucZM4UsueG9lcMP90yTNjNA7S10Yg04SNJ89E18C8ptl >									
//	        < q1CJfXnFgGTb02QspRv2Qblu8w7144q5Jr56TH67718D146cU0131kTdGtx32u99 >									
//	        < u =="0.000000000000000001" ; [ 000029121990764.000000000000000000 ; 000029130333588.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD94A1A4ADA15C8E >									
//	    < PI_YU_ROMA ; Line_2896 ; 5GD4G68FW10JD280KLZ5rGiG1c3O8lsdCn8Vp2pWY65ZWsN2x ; 20171122 ; subDT >									
//	        < 0SgUiULV5y1laG8Bg136fT1pCERl573vT21ZR5qn1CeU4oy8g7n33t5Z8SUHvwas >									
//	        < AV8Is3ZLqovSP2r567U26b6dNgt80JsuA6YM3p9f0889CLu83f8jyCFYrpOfUGX4 >									
//	        < u =="0.000000000000000001" ; [ 000029130333588.000000000000000000 ; 000029142585209.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ADA15C8EADB40E58 >									
//	    < PI_YU_ROMA ; Line_2897 ; OKwtnyRa8vC28FUZ8fO9jXLDOA8mTH7w8mEcCOB14XC9t0Eaj ; 20171122 ; subDT >									
//	        < L6hd7YxS0pxhbV2a19HcaWuK4p3y5M4Gyo88b89eckOV9xsc2uzGRQ1w36tVqZz1 >									
//	        < y18ACd2sY2s2KPoDz800Z7EUOLnv2413WQ95KlikbV33D7BXjEvTr4GJ2jqk5311 >									
//	        < u =="0.000000000000000001" ; [ 000029142585209.000000000000000000 ; 000029155575659.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ADB40E58ADC7E0BD >									
//	    < PI_YU_ROMA ; Line_2898 ; 3I74uRwMe1kb2b8J8kleNRay0xX16gx0wNSmqVf61fLSgGJ26 ; 20171122 ; subDT >									
//	        < DDDq9eDnkVCt0FdXn223nk0llX1hBKZG4ltHAM8S6Dyd825DNi98LAo8juxdX6Eu >									
//	        < grGrnF4jE575I6Vwbq7S883FGL6k8cGxCWRTRtaasRP68KyJCWp7Yl67Mu33HUID >									
//	        < u =="0.000000000000000001" ; [ 000029155575659.000000000000000000 ; 000029160805035.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ADC7E0BDADCFDB77 >									
//	    < PI_YU_ROMA ; Line_2899 ; iZ5068XLGFKL3x00vZ9IR7W34C8n7BV12BCwm6Qw74c07D65a ; 20171122 ; subDT >									
//	        < XN455q251Gu7y4e3Uz3D50D0PboiDpjyjUBKP4FwsGAVkC7B75zwmaQ666r6Jl48 >									
//	        < 8cTV3HBHkegAg6uQ9t3W0QFBS6FdrmuaXz68xVGLzGoI75c8l2g5cady7Pq8Bi5H >									
//	        < u =="0.000000000000000001" ; [ 000029160805035.000000000000000000 ; 000029168539659.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ADCFDB77ADDBA8CD >									
//	    < PI_YU_ROMA ; Line_2900 ; V5BdBV64IF14TWqBvPBww6989vRDERPK1fiBRxj7ae8al7Qkj ; 20171122 ; subDT >									
//	        < DC1G3c1KiMjHfHwPbp23Cf71u25i77Ozc35wU1HeqXNI67q5xMt4rmcXEw9BbW5V >									
//	        < 7B3MFx787gt2pvJq65Dv41N509otN940Tz707m6z9ATG72m0P9j83HZiBh43213x >									
//	        < u =="0.000000000000000001" ; [ 000029168539659.000000000000000000 ; 000029174464492.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ADDBA8CDADE4B331 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2901 à 2910									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2901 ; GWUCL6Nf63NdgDM4yp7gEt8au7G1i3VXKD2X1CUKX4AzdnR2K ; 20171122 ; subDT >									
//	        < 143G14H1lVKcDy4m6X9nk9m83nO5xrJDnF7B6O7Z5ECuU0QQi730qaPeUXSsYnPB >									
//	        < vGNCsJV960grQop323DN84PwzN5gXOssiAFrOEximVc1CCJsF05fez1RD3F7p7v2 >									
//	        < u =="0.000000000000000001" ; [ 000029174464492.000000000000000000 ; 000029187816549.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ADE4B331ADF912D6 >									
//	    < PI_YU_ROMA ; Line_2902 ; 887wA2Lj33ZxsKUt1iV9QbsI2mHcGzhk1JRb016bgHyJlbfxV ; 20171122 ; subDT >									
//	        < g6R9AV8uCuu2tl5q47UOCjfDi31CMmTA57CrAp0y3P2PTCzz349hmO41l2bxlw0F >									
//	        < 9K7p70NvMuV2e82KWckG3wnn365umicNapKN09r90r822uf668g01ZzRST96k5CM >									
//	        < u =="0.000000000000000001" ; [ 000029187816549.000000000000000000 ; 000029201809545.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ADF912D6AE0E6CDA >									
//	    < PI_YU_ROMA ; Line_2903 ; 4PSPJYzH942uFmzxnXff401loSU6593HWpA90neiBhKVIQW62 ; 20171122 ; subDT >									
//	        < 8p9i35IiKBcr2c65zvv0BtK0y13Y3oXA85mD6727DDoJ9OtP6L9wDAze94m81U6h >									
//	        < 7f5kcAfzbx1xI49g0hGa15R9B9jkhiyRZt7MhFhf2jI8LC0t9y4Nkm05U91z5eAN >									
//	        < u =="0.000000000000000001" ; [ 000029201809545.000000000000000000 ; 000029213734833.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE0E6CDAAE209F2B >									
//	    < PI_YU_ROMA ; Line_2904 ; 64MNvsACe6ZyTsc8T7GhDrNhf7p94PpQnW1XOwwm1PWu2i577 ; 20171122 ; subDT >									
//	        < 9BEqxGj7sv9oe9hIxpRE0eZxk910WQJy2gwCPC70LKVD0j02Si8fFRQR759mUc8j >									
//	        < 786SAzk8j6RZ30l0djLCO4G6B7lC3V6RF8FuL9avL1Ko8yZ0gzN2fP9i03BrJfW1 >									
//	        < u =="0.000000000000000001" ; [ 000029213734833.000000000000000000 ; 000029226034909.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE209F2BAE3363E2 >									
//	    < PI_YU_ROMA ; Line_2905 ; 31fk2C01mBVPa1dGLGv2Pi6FDkjH57ijll7kO40pWe8pCKf0t ; 20171122 ; subDT >									
//	        < A950obYls2q5Wq74PI5ebJeym4Si7xJhcTFbelL335b9CCc4I55uH6wjVmMKlKA2 >									
//	        < K7x5yCRXNTG858BfLLQcxNeK7UWQh5e96peS61g9BZSBf2KNXJ1ijn97yCQSj80g >									
//	        < u =="0.000000000000000001" ; [ 000029226034909.000000000000000000 ; 000029232848589.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE3363E2AE3DC97A >									
//	    < PI_YU_ROMA ; Line_2906 ; 2ej178eQe6vFRybV582gg9mHwluV4sO5EJYVj110JyHOZQBoY ; 20171122 ; subDT >									
//	        < CGdM7aE30VGY3AYx1c1R73C23191Xq1DHv72H0o3wW8O3A0U4Mxt1irjEm5E8Ix8 >									
//	        < jpeZHlDrev7ha6NA8ln43Z3hv5EqNDn63n1H7UM2QH7bq319z2M0Q606FrhMlBK6 >									
//	        < u =="0.000000000000000001" ; [ 000029232848589.000000000000000000 ; 000029247006881.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE3DC97AAE536410 >									
//	    < PI_YU_ROMA ; Line_2907 ; R7AnoTns454lrl0BaBs6y8pdRx1b8f1dJ6m94Ej9HuZ69VAXT ; 20171122 ; subDT >									
//	        < K5pi4Pi8032YPkOTB7R3aI75754qNBV092xdJZ2mOJCpeW8I7jAun4rO8QC846xL >									
//	        < jpaNkg17u9MY8uZyFQR5393tZ544AFfz7oz3a7Ha38xBA627O8fH5gPxqH12j679 >									
//	        < u =="0.000000000000000001" ; [ 000029247006881.000000000000000000 ; 000029252848358.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE536410AE5C4DE3 >									
//	    < PI_YU_ROMA ; Line_2908 ; Uf9ADVV3HXrwU6G7s3a0ao7T74d1pYN46939s1w06x3892L1g ; 20171122 ; subDT >									
//	        < HQ037K5b8HWQ1aPn5TrH2WMIRHNp5QB042F2p7iFTW2Nyv5Xv47hetxOtbe33rz0 >									
//	        < 10SL1HwG2fRYa1t3OYmts5C0s8XE61AL6Iw3qiixnbrt2x051dC35agRz119FZR0 >									
//	        < u =="0.000000000000000001" ; [ 000029252848358.000000000000000000 ; 000029266039641.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE5C4DE3AE706EBC >									
//	    < PI_YU_ROMA ; Line_2909 ; vJT3KA6lg4Yo7ig3gU084627n81Q3500i04uzD78096hbW6nC ; 20171122 ; subDT >									
//	        < BJZlnI5FrIAM61T4xc7iPvDsJNCYo337fZ413uk8g5mY6M2W1m7kl59v316h1UBn >									
//	        < wiND9Y1y62ACrj06iPJC3009z279kw7088oIc5alMPWP0T4jda284qBdpD8VioLl >									
//	        < u =="0.000000000000000001" ; [ 000029266039641.000000000000000000 ; 000029272057186.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE706EBCAE799D56 >									
//	    < PI_YU_ROMA ; Line_2910 ; Y2QoDxIEZ36uo9UjngYG574rbLP3ziP74F2G2e1FC12h97171 ; 20171122 ; subDT >									
//	        < z2gkm559KObovpyuI23u93438f15tb094OOKH5AW2s5fzVf7o90q88FlOd08aa9X >									
//	        < 7b71HHeznGo9HeLXbn294d8ikDeUR683YoK4t4d312Oa0Wg0g7H4VBXdgQ0U5VIz >									
//	        < u =="0.000000000000000001" ; [ 000029272057186.000000000000000000 ; 000029278585526.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE799D56AE839378 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2911 à 2920									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2911 ; HP84qdRAtjgGX0TMET4pF0Qu8ue7nlh915JeIPV7EU68Yuqgi ; 20171122 ; subDT >									
//	        < iMoFN2d54Ay7ufGo2yX2Hga2DAceqzBQnr1VVKGoFOF0z58h6ZWUTnnKAogIN8VY >									
//	        < UW1XBcNOmq4t7uydOfGgh6M8qCcAv3Ved01QdCKb2Z0668Dh8I05B26R1DFIe8W9 >									
//	        < u =="0.000000000000000001" ; [ 000029278585526.000000000000000000 ; 000029291761693.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE839378AE97AE69 >									
//	    < PI_YU_ROMA ; Line_2912 ; RZKj8eVlJL6r5zUlJHc77vyJwc9j8sqdAcQA66U3toMM8LWrJ ; 20171122 ; subDT >									
//	        < IWAgHX6zYbl8ru8PBm6l0jp3l6B36cGhmPLLLrmOI3WXsu233mZ34no9Sk1adOU0 >									
//	        < n8ev737fil85XhCEa62I6eRdtR935252upvitv5m7CEOn11RSN98N6JO1CxEb63o >									
//	        < u =="0.000000000000000001" ; [ 000029291761693.000000000000000000 ; 000029305650907.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE97AE69AEACDFE2 >									
//	    < PI_YU_ROMA ; Line_2913 ; YtPE65JxP81FHvLXJ5ouzxBaj0jMJrB4xRsQcB9Za6c6h3joM ; 20171122 ; subDT >									
//	        < ony028uIegQ3UyQ6L682Zavi9TZ78WJp8Ol6biMES070MYtgrSN0X6u7acXrv829 >									
//	        < 7Q87Y29lZz2n9KJbYLqbfwqp73NZ692hKSXethcv37F6bpejuNgi3N2drIj91LvK >									
//	        < u =="0.000000000000000001" ; [ 000029305650907.000000000000000000 ; 000029311553459.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AEACDFE2AEB5E191 >									
//	    < PI_YU_ROMA ; Line_2914 ; Sx8c163MAiajRL195swLar7XFGH9Ra62s9PB9kOuH4Wy1r0Se ; 20171122 ; subDT >									
//	        < 9su2H5UfGnt4q897JlOu6EgatjDKNti095YfgE3sga29xBlLEHmU72eov9ltw64Q >									
//	        < 7N5BtY6CK648y8bxgX282L9sa6mn109XreWE4bYuzGLYJ7HIG848tyKwY1bqRpy2 >									
//	        < u =="0.000000000000000001" ; [ 000029311553459.000000000000000000 ; 000029321879874.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AEB5E191AEC5A353 >									
//	    < PI_YU_ROMA ; Line_2915 ; 1JAT3Au92dC16xrDYRvf49r6Wx05r8lOlu1qH6m2E4kw27b4k ; 20171122 ; subDT >									
//	        < T2uocLWBl6Eou4Wj15PWI2hHllvuggedgAckViTPcUKlG9EHDCTpSc10psql0169 >									
//	        < 2wkZR3zBb4p6LurwEdm5KfC479CgVR773NWuO4e0Pyw5tyfd5I2P73A02MTo37PZ >									
//	        < u =="0.000000000000000001" ; [ 000029321879874.000000000000000000 ; 000029336664539.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AEC5A353AEDC3295 >									
//	    < PI_YU_ROMA ; Line_2916 ; 2wMsSvOuvM7hiIQXD186Nl26WbVphFZSGy03S8vZkGkirmx8K ; 20171122 ; subDT >									
//	        < 9QF2s4HGMV0Qi4y28BRHC77Fn1ebSd4O9gSEluCI8cLeq816iboRfdCAge31r191 >									
//	        < AUeSa9tE4v3U654yXCfqw7jbJdcKgwK1e6RHL4Z3w6OBp5o1iyU3Zdpm534L29ma >									
//	        < u =="0.000000000000000001" ; [ 000029336664539.000000000000000000 ; 000029351456417.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AEDC3295AEF2C4A9 >									
//	    < PI_YU_ROMA ; Line_2917 ; Jrgf8FN7I5bH6r6Ofz0zyxykjWN3fyNp73mUCC5Z2YIXCvYV5 ; 20171122 ; subDT >									
//	        < 4EzT4DxPK07t60zsjBZCE6X3le7lBqkt5Y3R2Jc9UO6K7p18me4m93qZJhc2x27h >									
//	        < pjb10344U1OOgESpa3v2le3Dg247tq12uBYQ5f0Ef86UN4YmI9Xy5Ow59d0ptgJ0 >									
//	        < u =="0.000000000000000001" ; [ 000029351456417.000000000000000000 ; 000029364753679.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AEF2C4A9AF070EE7 >									
//	    < PI_YU_ROMA ; Line_2918 ; 3KDO3XkOYIy7tMi1V4ryFuglMxW6hd2gig1BH27ZWoyLt0aYe ; 20171122 ; subDT >									
//	        < emsZ96mW7aG489C18SlHT8tD398Izs13Z17WSWWko7duV1nj0A4ZS6F6zlA453Rg >									
//	        < jDvT05k32cr6mN31IwLB84H5RFLK0iRRsOKSms9lLm4rGs5L3Z6Spr7O6GmrggOT >									
//	        < u =="0.000000000000000001" ; [ 000029364753679.000000000000000000 ; 000029377736604.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF070EE7AF1ADE5C >									
//	    < PI_YU_ROMA ; Line_2919 ; Jqvt24v34woWb6BWB0ZrQ2KC3YKzCi7XriZ9uG4sn27nnvxWH ; 20171122 ; subDT >									
//	        < cYZ0qjzeuOaFu5Q24JqG4325q61aax9bHnH2rqmPBy5na3tuZ2sgkO23gd4qD6uY >									
//	        < oZYibzU7NAou11bxmWjq020QlCrvM1d8Gz18M8x214zd2k8W21P6S87uKYL18Hru >									
//	        < u =="0.000000000000000001" ; [ 000029377736604.000000000000000000 ; 000029383262824.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF1ADE5CAF234D0A >									
//	    < PI_YU_ROMA ; Line_2920 ; 7S0d4vq45PB6cNAiKnBTWm8wtH56I3w88b4gNBH8eAXETAfNX ; 20171122 ; subDT >									
//	        < N69651rR2TcA26CTj3WXQT83s2368cpyTR1M592AEJn67e772P0I56hqC54yDNE2 >									
//	        < 8FD7H5csKT2gE4614DE68FQ2xzx5iaK7W687b5zijUbgxaaHU30lB0d1dix3W5rm >									
//	        < u =="0.000000000000000001" ; [ 000029383262824.000000000000000000 ; 000029397587793.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF234D0AAF3928BB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2921 à 2930									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2921 ; IHcxKyfWo259Tuy34qRKs2LWY3399ioZhchWJjPF65THCCSUU ; 20171122 ; subDT >									
//	        < KY98O0Gl4Kd9T125WfuvNd0TveNJ7sWr45ZRCj324uZZ1rf5i83Ftdn51nnsbfwD >									
//	        < 4E8EzZirGtW4Rj68CSawnNKb6o265uLEixzcR0vWL17FqvXzl6fvtal2m4oOGyl9 >									
//	        < u =="0.000000000000000001" ; [ 000029397587793.000000000000000000 ; 000029407876210.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF3928BBAF48DBA5 >									
//	    < PI_YU_ROMA ; Line_2922 ; o3C9Z29fCeiL7ufjA05pDisc9NImwdn4904t9NiT3Ff3g1tzs ; 20171122 ; subDT >									
//	        < 9fX93H0S88Y9qKH6JS4ayPZqDF77g9qnws70shT4gPMiwL06V1560bwU3s9w7mOJ >									
//	        < QAN058x99XK2hrFi8wJODpAMp1uY02L409u912wA7G9F1ZAj7U4sAuXQ1f1ibnBq >									
//	        < u =="0.000000000000000001" ; [ 000029407876210.000000000000000000 ; 000029420456473.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF48DBA5AF5C0DCF >									
//	    < PI_YU_ROMA ; Line_2923 ; fF30pg17zKr69Rn9GapX8f0d32l1qE52q16W6haWN0S0a5re5 ; 20171122 ; subDT >									
//	        < d7643t69d50878x4643gzFcbDSpur3GSNsjBZ665j6wb1hKuAKgxHe88Wa51b4jO >									
//	        < W90n3BjL4X10uG7J9Bky5ePahMe4OAxs7l8qD419agUK73aN0dgihk17BHzM3Qe2 >									
//	        < u =="0.000000000000000001" ; [ 000029420456473.000000000000000000 ; 000029431300936.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF5C0DCFAF6C99ED >									
//	    < PI_YU_ROMA ; Line_2924 ; vjuh909t2Jx17vlLg58872m0tF1kzp3Ov2zJ0FC3ee8zmk7Ii ; 20171122 ; subDT >									
//	        < cHyoo2K39AT272B0sCYIT5iUSaYYDm3tDSu5jZs0Ha56180029bxL4EC6EgENN1m >									
//	        < iQpg1L9eT512MyuWJazPolcz0490GOne071Gq96555Q8I06NWblEHfV2tqu0vMd5 >									
//	        < u =="0.000000000000000001" ; [ 000029431300936.000000000000000000 ; 000029441063436.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF6C99EDAF7B7F67 >									
//	    < PI_YU_ROMA ; Line_2925 ; k769Sf7e73S783wj3pcnkh4PUN9762arj5i4AbMU0eETJ1kj9 ; 20171122 ; subDT >									
//	        < US4JJ45SBX1S9nW76V8uanjVC3D7ZAJik9g9QCf2KEWPWSZd7d8XyCTJhSYtsmM3 >									
//	        < kx5302y1P0mE4r0BrrW6xPg0t82ncFr3y7r5V3hT2fh446GQA0c0kSahl7kNsTXZ >									
//	        < u =="0.000000000000000001" ; [ 000029441063436.000000000000000000 ; 000029452876746.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF7B7F67AF8D85FA >									
//	    < PI_YU_ROMA ; Line_2926 ; a7LP3M9ekcxogmwGgY9D6330K1TVCfj1P9koDp7LRX3hxYz2U ; 20171122 ; subDT >									
//	        < 98paKM8s1sS58c3L1yg9RL0HxAPE7dLUeHjXhs8CI861bM6h3KjgF3RX64YBMCi5 >									
//	        < j1ZrAHaIscEFB84wZQQ4OCSVq415J13Q6XgX3g8D1DYv7K1KL8gj6J7yL6mo6404 >									
//	        < u =="0.000000000000000001" ; [ 000029452876746.000000000000000000 ; 000029467091309.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF8D85FAAFA3368A >									
//	    < PI_YU_ROMA ; Line_2927 ; FB74P6xd0QtNMaznVlwsYCEDlRsUs0600no6e7YSGLY3B3i34 ; 20171122 ; subDT >									
//	        < k66C1V4k0NXW69Ne8Kp7E13c3Ndq7iV567FV6nuPdAK16a0003C2rhG3ZC6Z39PW >									
//	        < 1A976X8otr0CJ286fej6t8R4eqqAa8AJxB8ogDvEITnN0QUJ91RpLyeOInmW23mV >									
//	        < u =="0.000000000000000001" ; [ 000029467091309.000000000000000000 ; 000029472714864.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AFA3368AAFABCB3E >									
//	    < PI_YU_ROMA ; Line_2928 ; 168472XmGeRqT5i1l0C6Q2N1TWeq5voZeIcwc5Iq2vC8O2MFv ; 20171122 ; subDT >									
//	        < 16bTn6R5PBphoMRov71fNK9H2te9WUg09z9y45Js3dv4m95Mvx5DXJUNF80Ds7LF >									
//	        < 9dqHgtUON2Yfhnrp36n7E8hg0c9354uWjnW8T7TShi494XKa7O73ab65J35wq3K6 >									
//	        < u =="0.000000000000000001" ; [ 000029472714864.000000000000000000 ; 000029483777641.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AFABCB3EAFBCACA4 >									
//	    < PI_YU_ROMA ; Line_2929 ; 97Jruk7zLUxhU6mo79uKvHO2qTFU69CBO5HHxTtpNywwEVwQE ; 20171122 ; subDT >									
//	        < 9is6cBT9p3WJ11Sx06WSGePSvW0Z1994In5avL8BcsNfqc8YNw91c3PLV66InH6P >									
//	        < z3U8tS78gPAXdN878fynV8rR2vD74nfy1s405Nmb7B03NUs1TEtY8G723L1d2L89 >									
//	        < u =="0.000000000000000001" ; [ 000029483777641.000000000000000000 ; 000029495956157.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AFBCACA4AFCF41DF >									
//	    < PI_YU_ROMA ; Line_2930 ; T4zG3T6B5445iLQV4IR80lhbOn0g8U5LUFXi513S4eUJo86yp ; 20171122 ; subDT >									
//	        < S1N5V4K2OBpG4nxi5fSLUhjvu75p9gs2PJf57s4677d02xJXzTJ0DBvDxz09dJmi >									
//	        < z266wd5LyXeeW74E4Q9dU4n0237RL67seC1X887o1D6gy21aW2093VPEhfSDf0D7 >									
//	        < u =="0.000000000000000001" ; [ 000029495956157.000000000000000000 ; 000029509739411.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AFCF41DFAFE449F5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2931 à 2940									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2931 ; D3lkxJB7Yt3Axm76D3Om27cb3z11ZH95FkMawxkS30UgmuOMf ; 20171122 ; subDT >									
//	        < hdGD9uzN905ixwJO1v9s93cwN6i4IsX752HD1JMQ3ALwM49z1KtCt506r4i9309N >									
//	        < gXQGZBlKKFz8Y7f2fbExabC1vRty39EavY2Fir9kF9uF94JCD1230bhDh7a2Z0HA >									
//	        < u =="0.000000000000000001" ; [ 000029509739411.000000000000000000 ; 000029521404130.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AFE449F5AFF6167D >									
//	    < PI_YU_ROMA ; Line_2932 ; ytDG4H6hRv41ZeihfyUSkQ9U2e5NlHbW1EYJQwELULBN0J9to ; 20171122 ; subDT >									
//	        < TyuRa2yTL4iQKSi1XLQ3pq0ttKZK21zuQSI306iAVWVkBdKe5648RQIea9PpW7Op >									
//	        < Rs8eKKwg3cT8Jg33H0ssiA2xnHGRWIy0QPZdGNFzJ31701aHvdq6PV3EXHRt55Fd >									
//	        < u =="0.000000000000000001" ; [ 000029521404130.000000000000000000 ; 000029533796177.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AFF6167DB008FF21 >									
//	    < PI_YU_ROMA ; Line_2933 ; H2Pln3yDvr1Z976T17BkLwbTB1i5RgY0s5BOn62uCC5fl863w ; 20171122 ; subDT >									
//	        < Agw2E4879L63dckSj14kgZQ5kb76o02xWrkDwh7y802xIqXD5MAq9B4Qcvc57I3p >									
//	        < 4tttsOYSCt275SKin04CnUZcvcBWTpSebJCBhlpqpaiDQTPDD60eYxjW1hhHk5LU >									
//	        < u =="0.000000000000000001" ; [ 000029533796177.000000000000000000 ; 000029546552711.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B008FF21B01C7627 >									
//	    < PI_YU_ROMA ; Line_2934 ; FVY3g61PvctMARq6VlT9JICV4378Pp53024mbhT8nYFYHxnwW ; 20171122 ; subDT >									
//	        < RQk428fl5uR1xTTYvGJ0f7kAA5cdcfy3EbL6wo53sKU29WLNeZB2iHRHUBiZ1Bq2 >									
//	        < 0m6HCvElgBb3YNQVzsLzeq41nu7pOt1H2DLTBRlnMzXk8v989YlGqferHKa3Wxcg >									
//	        < u =="0.000000000000000001" ; [ 000029546552711.000000000000000000 ; 000029558625123.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B01C7627B02EE1F0 >									
//	    < PI_YU_ROMA ; Line_2935 ; 18BpGvjUdC9Z9om5zVXy44H2iwEY5Z66Zv95HJRGeIB0d18r8 ; 20171122 ; subDT >									
//	        < 09QD1M0S57OdFSKQy97cPdxB5QUTuk06xcK9X9dnce4pG41j62c94cgMRc55t06C >									
//	        < 8OrcMH8rFxchsxDYj3Ny0yfIY0n34wL84I5S572tD460kPlDQIK86zV8MLvab79p >									
//	        < u =="0.000000000000000001" ; [ 000029558625123.000000000000000000 ; 000029566135052.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B02EE1F0B03A5781 >									
//	    < PI_YU_ROMA ; Line_2936 ; 3vXA7eRW9ixr0k2X6Lh5sC1lP842cKT5fmb00ia8GeJZCjWXb ; 20171122 ; subDT >									
//	        < q5gWINCuZvVlLA8sHc0wOJRPv5W0mn8SZ8I8qjikD05TkvQ5P22piLf253qay6og >									
//	        < dh15YVO2v6T28i39r5wFnvNktjkO0p9Stp81690K3PGW1Y7YKL96z8aaTcQ4Z94p >									
//	        < u =="0.000000000000000001" ; [ 000029566135052.000000000000000000 ; 000029573574905.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B03A5781B045B1B2 >									
//	    < PI_YU_ROMA ; Line_2937 ; HIqWRQ90q0qO8259J00Z2Tt0B2f9wbO3TueDmlJArmvfyG8fK ; 20171122 ; subDT >									
//	        < sbS49rxQ4nG1Fp84zc59ladO7KdkAc2Tr7L5s9MI6X2C53F55l3U1r9UaMZB8S4n >									
//	        < wxhM76pw0UVe5ixrU68IX4hie7qLXfyd6a5NytR15VT51Zd430U6RN665vfebNQ4 >									
//	        < u =="0.000000000000000001" ; [ 000029573574905.000000000000000000 ; 000029586248556.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B045B1B2B0590857 >									
//	    < PI_YU_ROMA ; Line_2938 ; 27L1PhP1I12inE4u29YoFZLoQUnQtwatW87lTLjgaihxP9OHt ; 20171122 ; subDT >									
//	        < ONRKmPxev5e04qfJicGp2mvUzlg3HD5z8tK254t45z0z2XZ9pTPTe2TI6Q32TJ4z >									
//	        < OOu1h8bm0ZkxONW2U3v3NUL4FKAZnmp41vy2zWChFsVkoWA8D6tE08kSt8ReqCzP >									
//	        < u =="0.000000000000000001" ; [ 000029586248556.000000000000000000 ; 000029594885268.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0590857B066360E >									
//	    < PI_YU_ROMA ; Line_2939 ; kV5a8BmMnkJhA54M5K5mpxUt2393mlU2YuUw7E89Vl7vpkATE ; 20171122 ; subDT >									
//	        < NkYlCUp3xMt3p025VEB39w38QBBav2vN795XcZ4H417eSE2xuJ41YBK47t1w9q6n >									
//	        < 54u9yX03Fv03C8Cr65x9REuUB9sh5Zanw5cxA0n8ner8i00mh2Y9T5sQ39x88D1O >									
//	        < u =="0.000000000000000001" ; [ 000029594885268.000000000000000000 ; 000029607079153.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B066360EB078D14B >									
//	    < PI_YU_ROMA ; Line_2940 ; do4Q3371NzXizeqcUj0mSVOA0VVpfu8N7H7MjS6D3mV828FNm ; 20171122 ; subDT >									
//	        < SxhT3fw9A03S9911uf8C5TUV5VRswJ6103BiTfUzzx5qd5pHOpjedocLx7m093Q2 >									
//	        < 034MBVlJ5FQevj1sWLxWqc9O7e0Lg4LA6WJgN6gpQv9v4ggHQI1T73k5dzECE1lC >									
//	        < u =="0.000000000000000001" ; [ 000029607079153.000000000000000000 ; 000029615099505.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B078D14BB0850E3E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2941 à 2950									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2941 ; 2xu1msekO7LtAGa8s3emh74eO3sT15r6zeHG422l6sRzpH05V ; 20171122 ; subDT >									
//	        < I09F7TT2xQ4H7uFaFjqCqcJTgyCa80En5J537cqCJtkK7zHnmM9k9RKqz8x4VS9J >									
//	        < X4s2wjEA54Ti1f7PUyqlxwIQ79ukjG9qLez30ZhXXVCBd28V60ax9Fa1XZ9oPA7H >									
//	        < u =="0.000000000000000001" ; [ 000029615099505.000000000000000000 ; 000029620198116.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0850E3EB08CD5E3 >									
//	    < PI_YU_ROMA ; Line_2942 ; 1RSstmHcds3p25NLJOpRuP8y8v5E8c2trZ98h2A48Qlp9ag2d ; 20171122 ; subDT >									
//	        < qoyjVH42LKX0S239HkA6Q77K4I01EIK02jxWbpECy7j5n7SEJO3DyyddV54ps019 >									
//	        < 0eeJf0GNKI781rVkqm5Q7L6rW1bzCUVOJHo9jRh3I3smXVsJ9n8L9Fi3Awe7x3DE >									
//	        < u =="0.000000000000000001" ; [ 000029620198116.000000000000000000 ; 000029626496202.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B08CD5E3B0967214 >									
//	    < PI_YU_ROMA ; Line_2943 ; 2DVI6682av2d0sO6vGY31GlIDuu66f7GQB37t2A42KzX4Kz01 ; 20171122 ; subDT >									
//	        < PmWEq7kl8d45tFjD9P15S1q720JAO17SSDAGS811yy4Gzr9SA65353a6h5e9D6Nd >									
//	        < cq8gZqwq4Fsl40LJqadM6742YKWoYD05VwbOIw4j993t6FMZIacjT88QLHgmtuqu >									
//	        < u =="0.000000000000000001" ; [ 000029626496202.000000000000000000 ; 000029635581550.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0967214B0A44F0B >									
//	    < PI_YU_ROMA ; Line_2944 ; JCZi229qa90i9RxWXjS7DWkITfR8696RTkSy2J87OD2Fo7k1B ; 20171122 ; subDT >									
//	        < PA8X3ZZ7CDQws39kLrW3cXBjt15P9L0AWd7RhG4m4qjMQI0jlNGVW70QzITkf5wD >									
//	        < qiQw16g3vuHy366m1o0adZSFzbmK8Kk5A44Q763fN3SP91P7ArX44uSvZ4hG29HR >									
//	        < u =="0.000000000000000001" ; [ 000029635581550.000000000000000000 ; 000029648423428.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0A44F0BB0B7E766 >									
//	    < PI_YU_ROMA ; Line_2945 ; 5979PEqqR3sWr7aOdsGDqXxSUS3aoN4pCo8y5o4XCmQJiQTN3 ; 20171122 ; subDT >									
//	        < 0w613YjHZuHQ20YLe2G4VT60LEkO21nI0UT1jjID701zteK2Iw7GMJa1IiJDOS85 >									
//	        < e92306d9wvdOw5Ljuqc6iaW80NJy7qS8f2FidjoU9O3a58R8GM04Z76XLpvPmA0x >									
//	        < u =="0.000000000000000001" ; [ 000029648423428.000000000000000000 ; 000029656655892.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0B7E766B0C47735 >									
//	    < PI_YU_ROMA ; Line_2946 ; CvOgvvyVqx9VbBZCOETSa6JzxMe6kJDSw8jOS3jz3X4Ia866m ; 20171122 ; subDT >									
//	        < 8s7MFc7YVTLcodN2hG719Pd7R0oTzAQY210Fl3MiotymF8uarK6M1MWWw67Y6YXr >									
//	        < y3UG3XAcBNtjexWET9rpr2w2zldB5AhR4EJgVs4E2s3eA7teA6aq51fldcm9Ey8E >									
//	        < u =="0.000000000000000001" ; [ 000029656655892.000000000000000000 ; 000029670141827.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0C47735B0D90B26 >									
//	    < PI_YU_ROMA ; Line_2947 ; XAz7T0D96H1gn5ysJ9S7uC84i8g78t600zkf6D8i3GS824261 ; 20171122 ; subDT >									
//	        < sc723sX7998y2Hze9cl4fmJQ5ElgMQW1Vzzoz338xE63fc0ta05L5Hy67x7w6Iy8 >									
//	        < 038EsmV8JzxfO52232ihs3wkQJ04g7WOc0MfCw2Gn1t9vVEoziDHh09hrQr0dXD7 >									
//	        < u =="0.000000000000000001" ; [ 000029670141827.000000000000000000 ; 000029680848300.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0D90B26B0E9615E >									
//	    < PI_YU_ROMA ; Line_2948 ; 3I085OiySVm9Z3c64YPW79uW30468D9fV0ERTlEkfms01EF31 ; 20171122 ; subDT >									
//	        < IkO93632795Qe0tss5321As90Z6f4dyFddNyAVK73beg6qi6XSAN10Sz76Pdzti1 >									
//	        < r9Rc0cNNp9mIfd6taUK2Lnr3nHSXYp06m3mV9h9MCBpDXuKgbF03N1ORk46Dw7rZ >									
//	        < u =="0.000000000000000001" ; [ 000029680848300.000000000000000000 ; 000029687769937.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0E9615EB0F3F121 >									
//	    < PI_YU_ROMA ; Line_2949 ; byKu28Od34L3z05oMIUYPzxdgrh6J2l55T0gV8J80612aZcj4 ; 20171122 ; subDT >									
//	        < gMMdy9k42Ov1RtUkS7Ety838lzf5nNJ9X3c2162gUjYC3j0iDmt2t2OC56kV1QWI >									
//	        < FxEy5JemsmXG7d8eQDZPqztS6S61yrHsQ3yrN02pE8FyC8d023sxq7boV9Ak6KDM >									
//	        < u =="0.000000000000000001" ; [ 000029687769937.000000000000000000 ; 000029695296518.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0F3F121B0FF6D33 >									
//	    < PI_YU_ROMA ; Line_2950 ; oMPn5zVvS7753wyXEPT9YdVF78cH446U1R33g3k9sYnq4958s ; 20171122 ; subDT >									
//	        < NflQ47g1QlMa5sBo50eT4b0Q473DdgPp9xn4BYsSNdM5d4ThxXjqr4927500C8E2 >									
//	        < QzW8OnxE1mD7hE7qP87l2B24YOOHPl1SMgBPuu59LL9aJ4zpYVJ3V2b7cV05Kc42 >									
//	        < u =="0.000000000000000001" ; [ 000029695296518.000000000000000000 ; 000029708918811.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0FF6D33B1143669 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2951 à 2960									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2951 ; asBisVr7FGDXE50NU6iG0xZ3CirA9IV9kuhUbj3B5yUNE3qGZ ; 20171122 ; subDT >									
//	        < pkpyepZhVJ3aGE6fg3zGg4aI2W7D5979U20MHRPGU02D562a3BSJ8wlt3v1z4QQ4 >									
//	        < uM13O8bsI6TrMxZBu29M0X6gSBq0jG87nR0Qq8927OCT1RofKQ4c2G9t4Bg76C8f >									
//	        < u =="0.000000000000000001" ; [ 000029708918811.000000000000000000 ; 000029722127317.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1143669B1285DFB >									
//	    < PI_YU_ROMA ; Line_2952 ; ONR5tA7D4kgg2Fur24R19Wm2Vn5AV45NV2dg5521wgzq12AI7 ; 20171122 ; subDT >									
//	        < VT668BE4hTPb1K2FJ8A3DRn5VDd3Q3Uqia5213fP59LKI9FC62FlVp89hBRpURAS >									
//	        < 9iBIq1FH9Q1rru3xNw7otMVgl540P88b6R37454N4FTfk92z4O6T7i9a9649Ltia >									
//	        < u =="0.000000000000000001" ; [ 000029722127317.000000000000000000 ; 000029729624456.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1285DFBB133CE8D >									
//	    < PI_YU_ROMA ; Line_2953 ; 59rx4q1mWhz0D69kPodSq212U9if2u1v8He3TpKwWJ6fcA7aV ; 20171122 ; subDT >									
//	        < 22wrBVZsvuxXmALJ482bszKcOnUnkcvnhEoCZ7oRlJ0ZF0rezVOVb3Om9quqti26 >									
//	        < me9acfUh6Pgx9Ou472DC4bc00kyZw7js0e1Vakk3Q2nMS2QmYi43vZ5B6516Xlyz >									
//	        < u =="0.000000000000000001" ; [ 000029729624456.000000000000000000 ; 000029742699034.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B133CE8DB147C1CF >									
//	    < PI_YU_ROMA ; Line_2954 ; 3386aiqo0ZC5zss1P88Zdmc5mnmD909hE0YBvLwtrS7DVT0RF ; 20171122 ; subDT >									
//	        < 51ib9uZ42i8oLnsGxO795e7DgQfk98F5eI83RtgQc3Qx6A7mOL9KIU3301uBpZyq >									
//	        < 4GqHrty06aA52338uGM1H6JCqzYw1RUuDmF39S4Fp6GT321zRpO6y497uVbZIMVM >									
//	        < u =="0.000000000000000001" ; [ 000029742699034.000000000000000000 ; 000029755103857.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B147C1CFB15AAF71 >									
//	    < PI_YU_ROMA ; Line_2955 ; 3EJ5ZcU75aM87Nm71167HCofhOb785uICDS3lNx0HvXli1S2S ; 20171122 ; subDT >									
//	        < g01wm3XqHO105Hle1EhTi49YFAWwm7a7Kq33o19Kq9DF99xafNsfa73H32Mk69aE >									
//	        < UQATR5wbX8w4LbhRzXE6rClgT28NwKVJAHWEnnZ8y12kuhhseDA3ElKvKlEvx62f >									
//	        < u =="0.000000000000000001" ; [ 000029755103857.000000000000000000 ; 000029765754645.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B15AAF71B16AEFE8 >									
//	    < PI_YU_ROMA ; Line_2956 ; jLqGDsS0vh6a3yO1us7Do0gr4BxapdGXkd9x1IG824yDsCf2P ; 20171122 ; subDT >									
//	        < omVUdfZ7yp5y2l2EXPRo6g6dRDHr2y3vlE65Y93oM7cLZf8Di32D790Dhano9Ztw >									
//	        < 17HxbhAFlVd4YuGe726x9ypS1M1eCBC751JapwIdJXo1O4j4X3cJ1QXYHdo1Dhd1 >									
//	        < u =="0.000000000000000001" ; [ 000029765754645.000000000000000000 ; 000029778010143.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B16AEFE8B17DA336 >									
//	    < PI_YU_ROMA ; Line_2957 ; 5x36wCo83q5800RPkbX6l7P4IjFDr8fG171ya0HDnpzNRHSxt ; 20171122 ; subDT >									
//	        < 46o5MEvZPlW5NouCAFNP52E16vOfsU1WhQY2O0Ig8KtQUvg7mp446uw20ZxxV6A6 >									
//	        < 8v4DkT3bE3V5FAO9WTc6g9w3s6P5dgBJtS7s63Ks36D6w1X0by5z524JTRFPRnhu >									
//	        < u =="0.000000000000000001" ; [ 000029778010143.000000000000000000 ; 000029783789014.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B17DA336B1867495 >									
//	    < PI_YU_ROMA ; Line_2958 ; y0A81N29E8x9Eu4K7dCKv2Z6Jmv900BMRdZpl9lCw8DpirufY ; 20171122 ; subDT >									
//	        < vi7E8V0B6sBl5R3Y3RGAlRl8fU0TLD4gT7b9SU22vv31j749Cl8a8fGq73V3LvHE >									
//	        < ZMLe70zgjm60sl7nW6K5G0QF9fLC61JN4B6f44UP0nVpVE0m8ax5DVt5aKGI4shT >									
//	        < u =="0.000000000000000001" ; [ 000029783789014.000000000000000000 ; 000029796018624.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1867495B1991DC6 >									
//	    < PI_YU_ROMA ; Line_2959 ; AkftNc3xi9yb66zPJV7n0e39PbpADa0QnagZ7ulLVOKf8K38e ; 20171122 ; subDT >									
//	        < 4pI37VXrEnuZ6PpMqtQPs7W30PSbzf5qKtoIk7LDqNl8c97939c2j9Fqu2d3yH2h >									
//	        < BHzl522BDAkPgPN1aUevKpOZx6kl8D17WjpJbl7X623KES2LZc104I2zgn385i4q >									
//	        < u =="0.000000000000000001" ; [ 000029796018624.000000000000000000 ; 000029810168926.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1991DC6B1AEB53C >									
//	    < PI_YU_ROMA ; Line_2960 ; i1JWxYlJnIyFS9yVmK93BaQlF795v87b68wpb1zP6ANFPm48S ; 20171122 ; subDT >									
//	        < Jv15Pn0r37nl6Ifms4wO80Kj1nPq70Kw8K93M5bZhqJI6Th8tCO4fm1d3Hw043Zs >									
//	        < f03BRYDg4YU8wJYDRPRer6axY3QkW55H5GUmbj3MkY25cG7j690Y9HV45p5q7wZc >									
//	        < u =="0.000000000000000001" ; [ 000029810168926.000000000000000000 ; 000029817790583.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1AEB53CB1BA5672 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2961 à 2970									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2961 ; 4EqCKS2HYyfh3sK1bLtJ0nF7MnNAKu3nKRr7F1Z70jj0359ho ; 20171122 ; subDT >									
//	        < yeqtn3zVUqH4qsECsqY79nXSTNp6Ft9F7KRIOzzEV89fCuc9Yzz87eg49Hb11nGm >									
//	        < vv34WOutxW05yfoWCuBdKGDyM45TC0Rz597ad8if4WjpX65U2qp3Esz3kE741irL >									
//	        < u =="0.000000000000000001" ; [ 000029817790583.000000000000000000 ; 000029827560789.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1BA5672B1C93EEE >									
//	    < PI_YU_ROMA ; Line_2962 ; 3mupvGTgK5j7ILO9iJ6dxxYlzi2Tx9mff8L909J80J09dbgD0 ; 20171122 ; subDT >									
//	        < 5DfU5960q4qEIk8SX0X7PF3TAha2In2sC8lSeS7KD1ykdvuMdFqxlDv9kyj5J78u >									
//	        < R7MKl0M33yQ8aLg342k89dfDk79Nj4X3G1cX2688BtAxTRB27vymYDH3ad91je2v >									
//	        < u =="0.000000000000000001" ; [ 000029827560789.000000000000000000 ; 000029835856241.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1C93EEEB1D5E758 >									
//	    < PI_YU_ROMA ; Line_2963 ; r4Gc086DPc9M5ikywFb669JEC0Yzj6szb6AMM7c67MiWwpq1g ; 20171122 ; subDT >									
//	        < 2THor35PkftaO5s8tliRnmtN279O048LmQ5RfNyJQBUQ4nLu6FiCN69UROG6N3uR >									
//	        < 2Q3Qx6u1xiXE97oeIdb5V6q715q6827N4s2qzGq2Qa7TA79lOm06ChTu5Xa16wL3 >									
//	        < u =="0.000000000000000001" ; [ 000029835856241.000000000000000000 ; 000029843690238.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1D5E758B1E1DB7F >									
//	    < PI_YU_ROMA ; Line_2964 ; sKt0FcNSWK4KEcMUL7OaLx0rrZQ8kRA472YD3d6466o512OqV ; 20171122 ; subDT >									
//	        < 2D4ufxbz8SipXQY6yy8077EKy6r298c4v7VW3ZJGmuqENbLHvr46R833eMLsShWi >									
//	        < 137Q1d2ZTWvSNxo6gnEX8WaKC95MG3ER7MXaL3lSXnoU81S0x3vrSmHKE4QT2GG8 >									
//	        < u =="0.000000000000000001" ; [ 000029843690238.000000000000000000 ; 000029848910798.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1E1DB7FB1E9D2C7 >									
//	    < PI_YU_ROMA ; Line_2965 ; fts6EygZr4xp1NvnG667PX22N02DZB7LR70lt6180K99QrJH8 ; 20171122 ; subDT >									
//	        < y5an5u332K2x692309q6Vxv4nbrqrQ5EKC6cIJOi1419yWu7187x9450853hYEB6 >									
//	        < 43D3qaTr4piX59PU39bLuU4AVpsPz46xkC47A1913iTqJ299n835n6x8YQ10dX6A >									
//	        < u =="0.000000000000000001" ; [ 000029848910798.000000000000000000 ; 000029860413515.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1E9D2C7B1FB6007 >									
//	    < PI_YU_ROMA ; Line_2966 ; rpPq75VcbZyFG8Krr6V4C48zS8so5snbQlCp41lRhVFW2F4z9 ; 20171122 ; subDT >									
//	        < P29I3ZOdRE7E9mz1ms49S9U8Z1GKG38Ml48l0oplOSSM7tG1F4ue8Vbv0fqt9a5h >									
//	        < r76m4nRfpGaA1E9K6Yj10W9t888VSf22aEwDp9lZzp1Id9s57M5KtM427WAnDcAv >									
//	        < u =="0.000000000000000001" ; [ 000029860413515.000000000000000000 ; 000029865888451.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1FB6007B203BAAD >									
//	    < PI_YU_ROMA ; Line_2967 ; 9PRCj06Ni3j1uBU1dzPqot2IQnLhEo7O8D0FvcPIz496Y1pkk ; 20171122 ; subDT >									
//	        < DJuyu2b2s7OFwLdtPKyRSq7N2SEMQc4WcUhFz5bii9uNjS18w6t3vws99584iZHG >									
//	        < 3WscaCW7V8znrzm0kJ739aOm5aRNFI8cbs2VuVYeH1uxp5233Sn4L521kQT52MC7 >									
//	        < u =="0.000000000000000001" ; [ 000029865888451.000000000000000000 ; 000029873169072.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B203BAADB20ED6AB >									
//	    < PI_YU_ROMA ; Line_2968 ; CE3XYb7hTdi5c5aq6Qcq8k40Ia7k88Ps24wB1r2NLtKJc4M6L ; 20171122 ; subDT >									
//	        < pcQ5Nx81Ts66qpe8TQAHJCg24IKrM5Y8Gf6lkOC2tbz64Ejt7lO0KVpO0vpsCJP2 >									
//	        < 7fiPteug2V9U6UZ9AIGqc4XiJ1Ww8j505D1L79k7yoSK2UwPEr5T8gU027h4KKo1 >									
//	        < u =="0.000000000000000001" ; [ 000029873169072.000000000000000000 ; 000029886568379.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B20ED6ABB22348C5 >									
//	    < PI_YU_ROMA ; Line_2969 ; 1swhM6U4sypw7ng7yvvyTq27NSJeZKy4he8PA197y71r7Kj85 ; 20171122 ; subDT >									
//	        < ks3tltOhPi3J9L0rMm8yCyfImTE71d1FysI5o3yd1Q5zrj49wYekzr70x5h8r3C7 >									
//	        < TCUe20afjCI28588KGWleAsddhUqD7Q64rz5RhzgfQm692q63pa1rLrj2270j18D >									
//	        < u =="0.000000000000000001" ; [ 000029886568379.000000000000000000 ; 000029897384309.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B22348C5B233C9BE >									
//	    < PI_YU_ROMA ; Line_2970 ; 796857f93ZP10AO676Xc4Iv8u58EA1v2y3SrgJX834c63Ne7o ; 20171122 ; subDT >									
//	        < Oh2yvm9oI5u5NpXCyC6JAyz1Lpzd83uj43TqqBS6d9Npd5NI0lkiavfl8aG4R94y >									
//	        < Z6ss8dO5Zun7a13N0nkAIC4lHpB10otX8SF4w9Ni0JQwq3272jrzz0gmiwS3qrlG >									
//	        < u =="0.000000000000000001" ; [ 000029897384309.000000000000000000 ; 000029902774201.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B233C9BEB23C032C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2971 à 2980									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2971 ; zld48N5C24EwVhD88C23WJ5lTGS2gPnN0j76d4jAtBqjx7OZ5 ; 20171122 ; subDT >									
//	        < XVQ0D09p01g0v9Y7373nsVRY6W8zl01i1057UIS84rMHeMVgOAk7xacZ6O4e1G2x >									
//	        < k483ImFjz779ne10AP2v255SKA5272cI1iKNf20b6t6o4f0BFMjmK0G44otI9T8T >									
//	        < u =="0.000000000000000001" ; [ 000029902774201.000000000000000000 ; 000029907996046.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B23C032CB243FAF4 >									
//	    < PI_YU_ROMA ; Line_2972 ; Xi8kP9ET9U2Ol6KqZvgu0Z8ZRHnD7N7e3fH13GBoo94xUEhhF ; 20171122 ; subDT >									
//	        < 63lq0C8ip598ZQ6z775vcn6hk9tSK794Ku9lX7dC25MMtJGr8H9XZeC7zDh6l016 >									
//	        < w9lM5lmH4Sm9L67VB68fnMhfRZ3dk3tVPK8B1NJ0W70A63h95VQLEX62xU2j2Jm9 >									
//	        < u =="0.000000000000000001" ; [ 000029907996046.000000000000000000 ; 000029921202340.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B243FAF4B25821AA >									
//	    < PI_YU_ROMA ; Line_2973 ; 0XDx26QeN746XJs92w1S9oD44oFq4odOeT77WGZOam11r2ZA4 ; 20171122 ; subDT >									
//	        < pABJW0pV6w2MrWXwUq12JeDV69ZMt4sGi7P2wWpH7dqM4fEZ6QQ7R7qcQ2arde0O >									
//	        < 33mcM5T141GJsodP7IK2f89Rh9E7z0S2vjp9BDP7J99XBydIowVD3BTY2Q4kqaFn >									
//	        < u =="0.000000000000000001" ; [ 000029921202340.000000000000000000 ; 000029929918097.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B25821AAB2656E41 >									
//	    < PI_YU_ROMA ; Line_2974 ; zv2Rkyt8c3i2h0eV8H4tVnDOrJm5CN9fM9E6oh0HBi6O6X7TE ; 20171122 ; subDT >									
//	        < OHAW9J22O96RFkDGXJyNgLE3807mJqu05cAiGk99FpW0XRNT3PW5w9XAVkl7y73i >									
//	        < m3KAFB2KUU1A2rHbYrIep0mVS1aUJ0fxY1uHCTInsfMe6aCALa4FFW75wpZ83m4C >									
//	        < u =="0.000000000000000001" ; [ 000029929918097.000000000000000000 ; 000029936465417.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2656E41B26F6BCD >									
//	    < PI_YU_ROMA ; Line_2975 ; f06R1V24N9cSrxVRgU2xo6fr2B2Cxi16JDyi7048P1bmbD2j8 ; 20171122 ; subDT >									
//	        < skIJF67lQ7qYx6XUxbZQSWS3gva65022gdIJN0jk96bnjLwq8UyA4KZrkzTp99B3 >									
//	        < GMdALW0J9Ay96O5Tks5ddss7gVeD6iVYGvN0303XWqoIGA6VLh008N2sgey16h9I >									
//	        < u =="0.000000000000000001" ; [ 000029936465417.000000000000000000 ; 000029948435900.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B26F6BCDB281AFC6 >									
//	    < PI_YU_ROMA ; Line_2976 ; PpWM6nsEVRp8i1GSo3i5OS70cLB6eXt0311Q3SOIZ4L48eTJy ; 20171122 ; subDT >									
//	        < w1nkm55rxW0D0ntj0Oap5Iy82mw3Civ5vtdMg1IEtvnf4yyDUxi0P4FH9j9mqxy4 >									
//	        < HWewzcfzl7J9hNUb0VUGzvj1PC5VAOI41ev3WOV929sXK9RSDzjbR87yLu0iId53 >									
//	        < u =="0.000000000000000001" ; [ 000029948435900.000000000000000000 ; 000029954602976.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B281AFC6B28B18C9 >									
//	    < PI_YU_ROMA ; Line_2977 ; 55yPJg12DabhP9GSa7VxTZdo9aa2D035BbW8ujeh3K3ajhp3z ; 20171122 ; subDT >									
//	        < B25N8JFoYv3l4t0hXgV4GmnEgYzf9d8496lZjqPuwJWL3X44l23z7VkfviHCVVoe >									
//	        < V8G268k78hh0rG207QupAvFTmOn32KynlwFXfu6mScglFQEg1eYY00L262lg3UjU >									
//	        < u =="0.000000000000000001" ; [ 000029954602976.000000000000000000 ; 000029965218004.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B28B18C9B29B4B48 >									
//	    < PI_YU_ROMA ; Line_2978 ; 1zceIoZiuDkYdeIuAJB8BX5YI5S555LeRq1EDx91d22V18vF5 ; 20171122 ; subDT >									
//	        < sAPR8J3324rCqn6Q65psCGWabUap6zNhEdkq1d2dpAtss20125ba4ZLrn1qBN31n >									
//	        < t9ME2bYh4DW3azp5iZsJTvviqo0zt7B5dwdv0Cybtf0AB7n72uQkj3IK6KsDhlVh >									
//	        < u =="0.000000000000000001" ; [ 000029965218004.000000000000000000 ; 000029970419297.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B29B4B48B2A33B09 >									
//	    < PI_YU_ROMA ; Line_2979 ; EWR21L1l4j07z3WAU14j9NcAGi5465OnB9sl5707WSNu1l37w ; 20171122 ; subDT >									
//	        < 0hezhzHLKQL41858tx6eNf10o8UzuaILnxC95Qoe9bPF6JC05vH8u9fijwe9b0vJ >									
//	        < 8haki2BBEuQ2zAKBjAuUy890TZmYP1SGbqof88aWxROt7yDP9v1UgsFjQQK576JX >									
//	        < u =="0.000000000000000001" ; [ 000029970419297.000000000000000000 ; 000029982030311.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2A33B09B2B4F297 >									
//	    < PI_YU_ROMA ; Line_2980 ; o24259Gh84yXq9gkjea5Z2rFQ8wnaB1i519uSC3f20V6rVbJ9 ; 20171122 ; subDT >									
//	        < xf9K34U90J7cYsszebX7DQvM7nMmH289waAlm74i53rrsoC9Qk3rcHTmgaPCAhJ7 >									
//	        < Xa4952ranOAwiACiVB8MaclWwNTT5QXCQWfg9gHHgO8Tr8haQ5a5ILC9n47q40PX >									
//	        < u =="0.000000000000000001" ; [ 000029982030311.000000000000000000 ; 000029989551183.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2B4F297B2C06C6E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2981 à 2990									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2981 ; 3sAvYPlDN3qcpY5YuhaG9U88rV15786P58a27mOU62r51qDnL ; 20171122 ; subDT >									
//	        < Q2IE262sV4mD4HGouf9234XV7EiqNK9VEi592DO3PX8ZhO1jNx9713YZN7XpqpsN >									
//	        < 4h8JSvO9F1mLq26TwXsv0k064ZySgX4344y7VR29hA1JVxFxZ0TCJ9mLS0Cq5zl5 >									
//	        < u =="0.000000000000000001" ; [ 000029989551183.000000000000000000 ; 000029996098223.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2C06C6EB2CA69DE >									
//	    < PI_YU_ROMA ; Line_2982 ; aPADcPL15bVqM2NIC7WK4h5zO9Fp30881SobGy93jDBhOx733 ; 20171122 ; subDT >									
//	        < aNj4o5w7V514s4SO32qBgp8W6OzFH1MK41tGZNx3K9ldEL4vCJfMtn0NC5OXz4s5 >									
//	        < Ja0SUrF80I5012HRSZowl9x2XdHroGeD669IZ7C7y2Gm6qLc82Ch0SP0851dpCrY >									
//	        < u =="0.000000000000000001" ; [ 000029996098223.000000000000000000 ; 000030004944300.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2CA69DEB2D7E95E >									
//	    < PI_YU_ROMA ; Line_2983 ; Zcpt8w7Q3lYS7M9qPy95tDERxlkHXX217BOw5jR795L0YVNp5 ; 20171122 ; subDT >									
//	        < F80tOikx4riBi4hvT8Y0Z94sE6Fn8hJ6xsqWzw4V63vpu7W513nR0U8dIEIGc497 >									
//	        < 2TbfpwmBu9gt5KllFpY0Y2Blz639LiLo9u3664c25J4Vlq643uprz5BC34lM681v >									
//	        < u =="0.000000000000000001" ; [ 000030004944300.000000000000000000 ; 000030016408433.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2D7E95EB2E9678B >									
//	    < PI_YU_ROMA ; Line_2984 ; uzLbkigZE7Lt4um6i558M1J7p9088NC106gJRj636Ky4OdWc5 ; 20171122 ; subDT >									
//	        < z5661h478w90q4nnUTv8S0s9VpAEghNbHNe6eEF0qB6s4gz9AU7YNGRe2769E9k6 >									
//	        < 6qW0m0a7U2k8P528pI38h2J537eDey9pU9dPgkN24iuFUjsPIaNGP4119VOvCfk0 >									
//	        < u =="0.000000000000000001" ; [ 000030016408433.000000000000000000 ; 000030021635726.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2E9678BB2F16174 >									
//	    < PI_YU_ROMA ; Line_2985 ; op4g68F4vf2JbUI9aFLvcj51mq02r61364Y7YNB0X5N8A2hm7 ; 20171122 ; subDT >									
//	        < H4sl16EwBhY05E80Z4551xVD5Ts6WIrKt1ZD1BmI5WqcXj3WyL44Yx9m6539R76S >									
//	        < 429hmVmI55JI4N8o8fygXUJC40XDgUll5T5JjABUUxnGyi5TtQ4dL0KZdfDX04Gy >									
//	        < u =="0.000000000000000001" ; [ 000030021635726.000000000000000000 ; 000030028510207.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2F16174B2FBDECC >									
//	    < PI_YU_ROMA ; Line_2986 ; 1vHV43PAsl924jOCbroH99YqqoM5WRux8f82EJ4wCfk3H2W4k ; 20171122 ; subDT >									
//	        < dkdqC7OGBC34XOV2Ic6ZS5bD7i5X6H68j88W8ZbLc016QeoWs7Yo8fOQ4w2Q098O >									
//	        < v0lxL6t1Xc2Z9ykbV6kuk4kj2EPMA9ZsfS9PJW2f06kRQQ8FCk1xVOSSI9bc261k >									
//	        < u =="0.000000000000000001" ; [ 000030028510207.000000000000000000 ; 000030033859966.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2FBDECCB304088C >									
//	    < PI_YU_ROMA ; Line_2987 ; 92Sr4342pZVsn6Rb86ISkj4L19tMf3sm6Gjw73TA7MrbR3emV ; 20171122 ; subDT >									
//	        < 1Ib3NKXnfg06S92CkP6kYqF957r8CDhaePyXB5G0JKz00VdUcli2f7M5H1jOZ677 >									
//	        < cB5s82N25c33d7c0hHKT4WFzsaa7thF5MO3Ow9R90ydN97S779j761I7i45K52lT >									
//	        < u =="0.000000000000000001" ; [ 000030033859966.000000000000000000 ; 000030043567370.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B304088CB312D881 >									
//	    < PI_YU_ROMA ; Line_2988 ; VA0jQ85tm5bh3JKbPfeSavxJ7h1r9ZWbh59Pa9e50J73U7B4L ; 20171122 ; subDT >									
//	        < gHT5P0Ca3R8xbmF94R1heKzlmCXUA6LMC83PdAeJhgKij8N3K1eoweW0q6vO1iO2 >									
//	        < J4p9QKf35f78yGle6O8Xi4iMtSH75mhPJkS74uc23vJJPPzdNI5fBTi9VEe85RMY >									
//	        < u =="0.000000000000000001" ; [ 000030043567370.000000000000000000 ; 000030052711824.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B312D881B320CC8E >									
//	    < PI_YU_ROMA ; Line_2989 ; h02BN8HzEQqNOWzrH6sKBnfA26d1gA4YI9IG042LuAUZFdCcR ; 20171122 ; subDT >									
//	        < 9h15z73RdvTkBlPZJys9IIn3hNR0n3YUP9PuFidbFY38t32M2a62eX1WK00RG0U4 >									
//	        < 20aM2iBYJdZZkOK8kAJc671FUh41Ljt4G9R2neSJ2wvARIMUuf57Cqm2n7wuV3O9 >									
//	        < u =="0.000000000000000001" ; [ 000030052711824.000000000000000000 ; 000030064648140.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B320CC8EB333032E >									
//	    < PI_YU_ROMA ; Line_2990 ; 58jJ0KpJc9Y5o28xR6m46A9hwovWGD6816j9SnJaPnJ2rps6h ; 20171122 ; subDT >									
//	        < 7U3x819tdtN26G10Aui8C4Q5Ht3q247O77nbnQzFVTD730TnSN622aHe082IVz9W >									
//	        < 34s11qOeSczfe2c3GJ9mVRip0V5C30u1338rdEFL4fwrK1qUPAS018IUb6bS13uR >									
//	        < u =="0.000000000000000001" ; [ 000030064648140.000000000000000000 ; 000030071014803.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B333032EB33CBA28 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2991 à 3000									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2991 ; rGL3E3R1DT2zNk9lc0Lie1863kEHBYeUCI9Z5Xd2Pp3T0rri2 ; 20171122 ; subDT >									
//	        < S74774Se44jFl49sDiKM9grXlJRckezQqIGr1dUboE9CDw8aH06hbJJ0q3A997d9 >									
//	        < lOsJ2CQY8iNy2015TO28s48n28N3ize77d6s7qG1KT3650MP5949Qp6B2eaajgeF >									
//	        < u =="0.000000000000000001" ; [ 000030071014803.000000000000000000 ; 000030085819193.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B33CBA28B353511F >									
//	    < PI_YU_ROMA ; Line_2992 ; WLQzBOUSd164T4Aoue4S0QOkkc1y5bb7tvf160FBlm4iElRbP ; 20171122 ; subDT >									
//	        < c87Ab2ySalMfaU5u0Ah4p41Nx2l1yT2dzPB9943DO7V18CI1Is9rqJP6TfNjbu4k >									
//	        < 4xtGdD8g665M3243Ef24129p4k9n7I44raN5ndrNO6d6eBUVT84QWDDV8iBZri01 >									
//	        < u =="0.000000000000000001" ; [ 000030085819193.000000000000000000 ; 000030096749360.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B353511FB363FEB8 >									
//	    < PI_YU_ROMA ; Line_2993 ; PP09QlbBpVe0zMdrvgQZC2xEtfoaeUgDcu1Oc595109rdfjyF ; 20171122 ; subDT >									
//	        < 8c5gy8v8UO81Qwa5S6G772a5T800Hxp24EcRQQ5tpR58E0c11n58426DhM2X1YEk >									
//	        < mZko61jykJjehuv3lqj94D8O9u6a5LHfHe69m5hBQszTF34gqiJfCYM2bNdradZW >									
//	        < u =="0.000000000000000001" ; [ 000030096749360.000000000000000000 ; 000030110987488.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B363FEB8B379B87C >									
//	    < PI_YU_ROMA ; Line_2994 ; 7KUOPY4HRfDNt3914022GGzbCAXF3H94bZtdBQsv6ekR38F2b ; 20171122 ; subDT >									
//	        < AD4EvIRLeEynVuMWL0bTvh9eJE33K5v844c91rU5q9X0JMBoPQ5u490nZ4oSYDye >									
//	        < 3n6Gj9SCPk1949dP4WDtXAuaYWLGZ7N723akHB9J1Jt5r8rkwOi6C8bcpHo8pA00 >									
//	        < u =="0.000000000000000001" ; [ 000030110987488.000000000000000000 ; 000030122492595.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B379B87CB38B46AB >									
//	    < PI_YU_ROMA ; Line_2995 ; UM16U65gXZSEhfJer21Qtpi8367M0z76l8b5x2eQX2C5jw8HM ; 20171122 ; subDT >									
//	        < WnVkzOK151UX45M82RUA4ia7JFWEiYpMQYwqYUIY6eWIF089ggSjUJcii2iM0GhD >									
//	        < nH5AEKvh4C9lvpJPzK0zIXvFx2we4rE46HcjQ8YG1NKBr2k3S601pDp4RN56KC3T >									
//	        < u =="0.000000000000000001" ; [ 000030122492595.000000000000000000 ; 000030134985904.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B38B46ABB39E56DE >									
//	    < PI_YU_ROMA ; Line_2996 ; X2EcSClgh3d0fMg4BNSW0gEY81r7Oe8mG1m02BtfG6210CcBa ; 20171122 ; subDT >									
//	        < X6pn1LsD9aAy36T77rQsH8eTB0JSxyWrWT90W6t3GGc0JFCznaefF45VJ74877vH >									
//	        < dsv63vIDodZ6Lsjc0TWq84RUaqYd8Ziwb62L8isn8996WF862w50sJSHG078Z6Rp >									
//	        < u =="0.000000000000000001" ; [ 000030134985904.000000000000000000 ; 000030143322044.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B39E56DEB3AB0F2C >									
//	    < PI_YU_ROMA ; Line_2997 ; 9Aa34A093Y118wn4m8mR6oRH08y95TnpEI4EWq1O8H6m46eBs ; 20171122 ; subDT >									
//	        < c4oLoOZp5223bh66y82z7qGx1aFQs1otT3v46e57I2FqmxU6hddlU7D07TeEM4ex >									
//	        < tJ0FoS6S1k75DvR2V19N07Li9N41O3F7l2n73Rmk19a1U5qQ12OL3wrBjntabo7N >									
//	        < u =="0.000000000000000001" ; [ 000030143322044.000000000000000000 ; 000030152123548.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3AB0F2CB3B87D42 >									
//	    < PI_YU_ROMA ; Line_2998 ; EMaN48OP229uRRuKO5rnLyPGI9z7dBVtp29ld0Iqoy0aWHAFC ; 20171122 ; subDT >									
//	        < Z438d1g616JrYtaC35gRkdW0FF81XW7a8uCZJhO01c62jdrx677r2ijA67yY7OEd >									
//	        < 0U2ndBTC4QvSn2q77m4a076R4wo3cn7GazARopgRR2Us5c28939BXtPcVM444nYi >									
//	        < u =="0.000000000000000001" ; [ 000030152123548.000000000000000000 ; 000030166614936.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3B87D42B3CE99F5 >									
//	    < PI_YU_ROMA ; Line_2999 ; QDi561kJ6ZphnGHP7YDPw7aqNUl6p9Mg0uPKhXn31hH6pwpFv ; 20171122 ; subDT >									
//	        < 1d0H67F6snX975p6M3P6H20lymz1J2dVAuRAP4pDV502MIihE1r4b2x39Zf3Ai66 >									
//	        < XSxNMgyYpzL982y9GQ1WAKu17Li3HptC4025bT2SA4aLgMzDblf7N4jQ82QeT4bc >									
//	        < u =="0.000000000000000001" ; [ 000030166614936.000000000000000000 ; 000030177861762.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3CE99F5B3DFC340 >									
//	    < PI_YU_ROMA ; Line_3000 ; 1887i99JSJZrj7kHLG5Ghzhq4lEqy04YzExmg6k0u144r8uEQ ; 20171122 ; subDT >									
//	        < VGUfK1N7Ld3bN5V3305SyHoYi6jS72EU5c6f8ZEXFs9L4855YeI5FiOuv75jtD1b >									
//	        < 8Zx9nD5UoW41Tw08MN19x6kc24rOyuB2CpGvGG019JKM61ln3MVyWj6LlgFEE3C6 >									
//	        < u =="0.000000000000000001" ; [ 000030177861762.000000000000000000 ; 000030189440883.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3DFC340B3F16E58 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3001 à 3010									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3001 ; 574W09hxbXQ0sLvP8U4LqbFcA48CVZ3sk6QPahj4Er5373KxW ; 20171122 ; subDT >									
//	        < v26S10BnfOfUFZI7hk5eZxcKeHuyk2Li0020hkZP607EPBfjZH1H3uc7jE4smMVU >									
//	        < KxWI53PY9zs8zmp9WxcbpkUpuDcbrrCAE0nD3UUu03jLqwQc3KVx9Be6q1VwmB02 >									
//	        < u =="0.000000000000000001" ; [ 000030189440883.000000000000000000 ; 000030195525430.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3F16E58B3FAB71F >									
//	    < PI_YU_ROMA ; Line_3002 ; qeeUW3164GkjBL243gWdz5w3sW6QV7LUz88Y7TdG478DVZVC2 ; 20171122 ; subDT >									
//	        < 0bQ059j476v5681Qk6m7hT2kbQDk7BFkbU0Ni4A3CxJsK1sQ9RS4i1rtbqu4S3KQ >									
//	        < 7DZSjjrpK1mcC6kzVwRGjO2HvGi4U4bwoXCc62gem9ZGkXA2rMxpQh4Q1zhNu5Qy >									
//	        < u =="0.000000000000000001" ; [ 000030195525430.000000000000000000 ; 000030200555980.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3FAB71FB402642E >									
//	    < PI_YU_ROMA ; Line_3003 ; xz1BD4Tp2iMV42W1at90cNK3iYWX9ZTKR4IBaY3K5gj010NXl ; 20171122 ; subDT >									
//	        < W9U8xxtBt68bra1x7UDhqJTV09DAdwTA1Qi64nC6Ry8e2Q6d56m7GitU3yQs31F1 >									
//	        < a66MF5boDZh9P7GMQP9oP8g3CYMIq75LV9ZLjl10mlgV26S6L6P8xwhlr50RyS2T >									
//	        < u =="0.000000000000000001" ; [ 000030200555980.000000000000000000 ; 000030214273661.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B402642EB41752A6 >									
//	    < PI_YU_ROMA ; Line_3004 ; gA4IK6Hrw3R9CnISHXnC7S8JMTiGt14MuWzWl12fMsT14ot25 ; 20171122 ; subDT >									
//	        < x0W6SDjuve205z20Hm7P02jfv1rgF5ULHAN4121nuAJ5c08szTzF2t1tFvxbD38u >									
//	        < jX85Yx4AxaN7JuMs3XJq5rE628BSw40m1KztV2ih4LjF4oH39C9N2GAgJ048wvVj >									
//	        < u =="0.000000000000000001" ; [ 000030214273661.000000000000000000 ; 000030222671821.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B41752A6B424232E >									
//	    < PI_YU_ROMA ; Line_3005 ; x8Diht2a42xFW0BA5LinOWcJz16WkM5d1nl1b15ZfxqH9H3uB ; 20171122 ; subDT >									
//	        < x395Pk75HfhtOGAyxgR5zK9t9duy3095mUbmQaB0XJrCeAh7T2Ug4E8Iefn78CJn >									
//	        < y9I06C7QJwM5Tkj24GaIw2ZoSnWAkWxv4lFvX58nm14U4RZn8p4ROlxsnxp6oqVx >									
//	        < u =="0.000000000000000001" ; [ 000030222671821.000000000000000000 ; 000030232371980.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B424232EB432F04E >									
//	    < PI_YU_ROMA ; Line_3006 ; fs7RubvqO29ssqslCimHenB1SqXV534D5Djq2L217Yed6c7EM ; 20171122 ; subDT >									
//	        < Y9WxUdQQtAIm225bH64tPIXUmlMOF62p7gnE6GoVcL6jZwP32k2PdhNefb5n48k1 >									
//	        < e7lYodpaji4f3pxYe4D9wt2OYCZ7jB2NsoRAHB6A7hkbgg1vwt90FwUV8X5gSy80 >									
//	        < u =="0.000000000000000001" ; [ 000030232371980.000000000000000000 ; 000030237729176.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B432F04EB43B1CF5 >									
//	    < PI_YU_ROMA ; Line_3007 ; 5gr45kFgLn4tu24R3dJMQFc423PVsdkdiiDS0UQ972LxQXLus ; 20171122 ; subDT >									
//	        < 42Y7AA3rwaYWguBNTXpb2PTj3FeE50pJWk8GiNUZ6llFz867cHH4RssXHS8SAfA8 >									
//	        < m3uDsUr87sHg8oc0TUuo32SYB07Au5uGWFvMDV06PCrl4NF02RzkPo1U7ClH1R4M >									
//	        < u =="0.000000000000000001" ; [ 000030237729176.000000000000000000 ; 000030251582889.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B43B1CF5B4504090 >									
//	    < PI_YU_ROMA ; Line_3008 ; IfH28VJK6o0f8i56c1kzoVspj165dE5DTHWxM0TeNJlo11XH2 ; 20171122 ; subDT >									
//	        < z91KCmP2LyNE5PI22uKe0dxHVTP67558m44dGigK4EPYrrwRgsGvG01KD2b77w0n >									
//	        < C7Y8o3io2NaTKol9wqyQ7U6T0K1257n9jboNpj0al8EDQN62K01tHFg79t733481 >									
//	        < u =="0.000000000000000001" ; [ 000030251582889.000000000000000000 ; 000030256763383.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4504090B4582832 >									
//	    < PI_YU_ROMA ; Line_3009 ; 55jSUI1pHdJAJ655pX1H11l8Ge1qD2Y3n5J3wH8lg0P77sjZT ; 20171122 ; subDT >									
//	        < IEglSV0dV86RS56t088iR1s4XY9dBmX8fV0S7A7592jruG0Gyy4TyoY55lNg1YUy >									
//	        < 0fMajNuNOI2SWIwICK4iyf19M44xS43EhbUvY79lT25otUZF5kA6gHE8n2q3s3B1 >									
//	        < u =="0.000000000000000001" ; [ 000030256763383.000000000000000000 ; 000030266323006.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4582832B466BE6C >									
//	    < PI_YU_ROMA ; Line_3010 ; BlOfz7Sz2thTvGieAEs8Mj8vxYfFTK0q69dC654F455l9a30s ; 20171122 ; subDT >									
//	        < sMT04TBdoF2zZtnTf95JpbX5Kz4CSwJxbJ52nhng0sAyMrQc6A9TP92wYNxr423p >									
//	        < Ym9ZBB904501xf571331X22vq0Bk9vdZCA4Ou2DZ9MuVJAU8B0G3c9f9KE4LJmC0 >									
//	        < u =="0.000000000000000001" ; [ 000030266323006.000000000000000000 ; 000030271747709.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B466BE6CB46F0572 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3011 à 3020									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3011 ; mGP37erK29YhIsQn0kED94hGT7Jy5koFRudH6BYAo01NK1vsX ; 20171122 ; subDT >									
//	        < cNxD5uak55fXBMSU8fw079z8ZTIjY17CyFV2R00p17V9VwOuO1y6YvO97nm210hm >									
//	        < 22Hy6jEWtDYW1Es2VnpG8hxVqW3lfqxhW82L4nh47ZdapbHa29zkz89V1KVL6o87 >									
//	        < u =="0.000000000000000001" ; [ 000030271747709.000000000000000000 ; 000030282344375.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B46F0572B47F30C5 >									
//	    < PI_YU_ROMA ; Line_3012 ; aRae5uH6Sn4673xbUPN2UDVdGxxJE0a6XQI18TFjmdpztJ6YX ; 20171122 ; subDT >									
//	        < ETZZY31882z1h84a7Q30enoaV5m5f2hdRPZtj2iqNcoakwOZE7pJNzk5TzHF8R1M >									
//	        < u6OD2irChMsRYfT2SEp0teGq9JXsPkFhVjgkr0jy09fuUDMs59N6UwZdOnohffgx >									
//	        < u =="0.000000000000000001" ; [ 000030282344375.000000000000000000 ; 000030296727194.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B47F30C5B495230F >									
//	    < PI_YU_ROMA ; Line_3013 ; Y3F2nkvDYI5fNSNdd5kAa9A75A5a3GQ86C98nsk3lr6aZS9eb ; 20171122 ; subDT >									
//	        < 1452cm8qf9jW0bZeOo8Rs785nqWBegqhfZTclB1498631QLiC2txitojZpsVl9G3 >									
//	        < 1It0sAHcalJQiUKzUVicIQ40Tr1f4v21AFW0GRVyP0y4p8owG9CbST8gT6utHSpe >									
//	        < u =="0.000000000000000001" ; [ 000030296727194.000000000000000000 ; 000030308947358.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B495230FB4A7C88F >									
//	    < PI_YU_ROMA ; Line_3014 ; Na0AoSVx56b7UK34D7sTzdT3PlX55bxDRHXqzQ7R50Dp0DtV9 ; 20171122 ; subDT >									
//	        < PD2YKHu1hC1588enPaiS8w9KafZDeG5ez1fLO22M2090vXu2F3g4v4fM3MIfVegU >									
//	        < 8Y8ZReWA6t35v51E4Xa4NSvHHORZ74w4VF2hMwYu4W43Euf8op090S32JlIPP3Jx >									
//	        < u =="0.000000000000000001" ; [ 000030308947358.000000000000000000 ; 000030315636347.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4A7C88FB4B1FD72 >									
//	    < PI_YU_ROMA ; Line_3015 ; 6SpUmElb3qJ9wocYLe4R8kQSB281064e219B3zdxdVHG7JH7f ; 20171122 ; subDT >									
//	        < Pu9N470P0nat1zjt06f0H1kHEP1GA9Ny5Sc52BF80NuTzxLNBFLzSsXt0G4SdCw7 >									
//	        < FN5L6LQ9IXAZ6GLJTWNY0NqJdYgVzsX5RO4Yp6O87Q3lCx7G6pi0DPe8FGLaB22u >									
//	        < u =="0.000000000000000001" ; [ 000030315636347.000000000000000000 ; 000030321045714.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4B1FD72B4BA3E7B >									
//	    < PI_YU_ROMA ; Line_3016 ; q3dN2KGvp4gKuS8FQ4GhjVC4oldjnpNRp4s19qZ9Df38WBhYj ; 20171122 ; subDT >									
//	        < 1657I220IV9kpQ8pb2nxV1VYTm178lHy0daliL45mw7S3M4GUE627Y0Q2515a5bd >									
//	        < jKRzG4Pk06lLYgkhpJSc1p742V1xF4bNH8zP05lmLX9g2xxRqfpxAel1c913lA97 >									
//	        < u =="0.000000000000000001" ; [ 000030321045714.000000000000000000 ; 000030328843950.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4BA3E7BB4C624AB >									
//	    < PI_YU_ROMA ; Line_3017 ; 0NEunP2w0hy659Hop2k5QY0Mer985S0gyheoZe04RLB1L713z ; 20171122 ; subDT >									
//	        < J6Q0Djr1u1s8Ar3HMr1V0Y49q445cr51l4ccq0D9P039MAsD2IJMA035FShJM7sn >									
//	        < n104xNCQ89j5Cy5Ft1j9YglH26mXF4jTMZ6AKYN5UZ9hn0jNcH3z48Jajz65IW30 >									
//	        < u =="0.000000000000000001" ; [ 000030328843950.000000000000000000 ; 000030342883279.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4C624ABB4DB90C7 >									
//	    < PI_YU_ROMA ; Line_3018 ; DZ61ABh2B3nbQ0RwLYC65wS75YqSI8Z8q7fIZQy80tt8mR7W3 ; 20171122 ; subDT >									
//	        < U2D2F7dV6fZQfXwacM3t1h5toc0Wv88ES8MHW47Cw095vLjx1b9AI1ztev3PcS40 >									
//	        < 0H9b4isL8FvFsYynqHRM5lrkr1E5Wz1i0atxX4kMAxX1R78ZjkdG6QFIxit265mS >									
//	        < u =="0.000000000000000001" ; [ 000030342883279.000000000000000000 ; 000030350978930.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4DB90C7B4E7EB25 >									
//	    < PI_YU_ROMA ; Line_3019 ; gu7o8jXYxPcC63nFFmchCF4RG54v37ek1D5T27U826kwlvy8S ; 20171122 ; subDT >									
//	        < 5x46UCt58Rk8usih3GN7A30vJEv5JfwGz115Vyi8ksEuN9Sd3eK9p5C23ghbbfzf >									
//	        < w9vNROU6f4q3T3T8dAEk4FZ501VnZZXcGx1lgEdymtt72wRyUjwL41b6gBbX1f1Y >									
//	        < u =="0.000000000000000001" ; [ 000030350978930.000000000000000000 ; 000030363069038.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4E7EB25B4FA5DD7 >									
//	    < PI_YU_ROMA ; Line_3020 ; px1leHYd2aZ9wN5IzL624PCKVs29X25R39SptI3ap3Kmj49N2 ; 20171122 ; subDT >									
//	        < 8CEqt1uqHV17pdSU6Q6wNx91dLQOG9NznMg9lyHA03WjpDC708v5OaxVUGf1xNLT >									
//	        < DCKTCB0YD7WCkjwl4qkM1PFRFCi1vX1ki8Is4JOU1v78PBw8x75k99CJrMFqZ9Fb >									
//	        < u =="0.000000000000000001" ; [ 000030363069038.000000000000000000 ; 000030377011800.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4FA5DD7B50FA43C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3021 à 3030									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3021 ; fzX4KebmxW1Xl9mwoPl41BIzX5vN9J15Prh69kxqYB5u678T2 ; 20171122 ; subDT >									
//	        < EovpN4jOkE8Pcvzkp17yw8eWt89RJrm4IP8BOVjtE9G6DE0JH7Q1lv99ExroFl77 >									
//	        < 4kE2Hty9qTgpaA18tp34ykjy7a0rg7ZpX5MVoaT9C60A2VQdTt71qapFk6Fy2mX3 >									
//	        < u =="0.000000000000000001" ; [ 000030377011800.000000000000000000 ; 000030387513415.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B50FA43CB51FAA6D >									
//	    < PI_YU_ROMA ; Line_3022 ; i7KduAfZHUmGxZPZU5C3WGBXes26rOH4M1vV38DeFr9K2sKSS ; 20171122 ; subDT >									
//	        < 3HSg045WUb3adW64kC0jc60t1he25jn2o5h6GKuIewLjO373t1t4G82GZh88Jj26 >									
//	        < xv5Cic1FarI2YgMaviv7ZnOmqymQ71WF0wS30LPv2EGkCT91Td4WEe4DGbFJRmqN >									
//	        < u =="0.000000000000000001" ; [ 000030387513415.000000000000000000 ; 000030396388406.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B51FAA6DB52D3538 >									
//	    < PI_YU_ROMA ; Line_3023 ; 93Q9ssGc1HFYmukm1GfbpjGZ38uOK9H4vKH87rpsmWS2nqu8o ; 20171122 ; subDT >									
//	        < 2uDqcsd11s4859a2uNyGzL4t4LpmJ14Blp7XAvkp98u52V5AF6l4FP3SRvzN3mxi >									
//	        < yI40HKnvy73cvS7qX0yr9XG85WeH17B5lixuwFE0k1qo8jE6eZ0G4Q95icUnx4T9 >									
//	        < u =="0.000000000000000001" ; [ 000030396388406.000000000000000000 ; 000030409645012.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B52D3538B5416F95 >									
//	    < PI_YU_ROMA ; Line_3024 ; aC1YC5T7VhzPdVJDQ1aKO7bd5I0ba7z1896bEhkjP8718A6KI ; 20171122 ; subDT >									
//	        < 6gfS5QKH18X50344sEwPgiQ1C4tN69KCb79TpCMw4R1lFW24U41B5K6k8IO57P94 >									
//	        < 30bVi64Z876D9U0MRw28zC44QBj30HNnLx9TRXJU0d4LWoxxE3WI2Xbu577SrJSJ >									
//	        < u =="0.000000000000000001" ; [ 000030409645012.000000000000000000 ; 000030422366616.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5416F95B554D8F5 >									
//	    < PI_YU_ROMA ; Line_3025 ; bxIVHM8w91Ct4Q1LvI62P4mQ3iKps95a41qjgT805n3EkV54M ; 20171122 ; subDT >									
//	        < Q0z7jR5A91LtR6Z4MjM22s5JqD6ybIYv533i5DzJ796ymb4BQ17AsUuYIIS4XJ3v >									
//	        < zJKmGw4qHLm9Q094K5RVsV5fZWq2zqn2RJNTB1v5Axlc4cZlXw4I5VBW8oOfsE01 >									
//	        < u =="0.000000000000000001" ; [ 000030422366616.000000000000000000 ; 000030428786647.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B554D8F5B55EA4C8 >									
//	    < PI_YU_ROMA ; Line_3026 ; 38B7uaVVAJ9El3tn3KaI1k4c8vIOjlnu3u941Bn3yq369pHHz ; 20171122 ; subDT >									
//	        < W7FRygEw1VXp25NymigR74ftJ93bwZ07hR148gbC6gFDIe8R95sr8hMfJyGL5hil >									
//	        < elhi6xniKqqqjCT2jwl0bI46Q4uhZkPc52b4Fz2wnuIs2KFg4vH435js3WZ3H28z >									
//	        < u =="0.000000000000000001" ; [ 000030428786647.000000000000000000 ; 000030440227193.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B55EA4C8B57019BF >									
//	    < PI_YU_ROMA ; Line_3027 ; AugJSdtfJu5xP65737az95Mr0gY8r0t9kU7tXv1fKRTp3VGWO ; 20171122 ; subDT >									
//	        < 3H9ZEEj04ZhD2L1OWWy07836jTet5LMTp742d6BliUBshlXi00UUlUaHeI171bVl >									
//	        < dP932txt7tm3jTI6ycasCBCt5GH13H8hKu4l74i5aPXYZq34uJW477SnWIMy4h0j >									
//	        < u =="0.000000000000000001" ; [ 000030440227193.000000000000000000 ; 000030447729964.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B57019BFB57B8C84 >									
//	    < PI_YU_ROMA ; Line_3028 ; 1jNKhr1lo8G0UELZ97wmn4x92w1G5Ulu0j2CF15D49i76r6YP ; 20171122 ; subDT >									
//	        < 9he1nh4d8xN9204BjIoBMWrQxK08EBp0btLIuFPMb24HR0wYe2fk5M053yB0b4B0 >									
//	        < 6IPqj91O2CQIr7LLf957s9a57soEYL7gr1HQyV8153436M0GS935Y41or4N8M0RV >									
//	        < u =="0.000000000000000001" ; [ 000030447729964.000000000000000000 ; 000030460626474.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B57B8C84B58F3A37 >									
//	    < PI_YU_ROMA ; Line_3029 ; WbJgz99L154yL9JJF8kKENt0l7l4Q5XtzmcNYZTYsDkw7M5J4 ; 20171122 ; subDT >									
//	        < 8rBHQ89Jxv241JX7AyIMJj9q297kw5E1HO9rJ4IFz7P8e09pMRVB0XBLbh4jx1x8 >									
//	        < n4S3D7E6uqEdo2b4apINBQvh5I66R20U593TmvzcWDswHvQ3aLw60NG2S996k8vL >									
//	        < u =="0.000000000000000001" ; [ 000030460626474.000000000000000000 ; 000030475266004.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B58F3A37B5A590C8 >									
//	    < PI_YU_ROMA ; Line_3030 ; BS7ME9J3OpZO68u72OdhAWL7Y139Srnr9caAb55j07JkQ2dzz ; 20171122 ; subDT >									
//	        < 75g6LYbbtg1oOv2sy2T98N6F1rh3r2QH4FYaYpI4Wg8BYGq64j4xVZCAyqJhYAbn >									
//	        < s45G4VIPcZIWw72BJ5PT918eFEs4Q7Ku07Xg7589LdvVWnEtWtHz9Jt5jxt9I7M1 >									
//	        < u =="0.000000000000000001" ; [ 000030475266004.000000000000000000 ; 000030481986822.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5A590C8B5AFD21A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3031 à 3040									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3031 ; 1959Yg7r1ZKNj0P56EKT08BYI88S2i43tTKRDd71G0ZF1sn9F ; 20171122 ; subDT >									
//	        < 70GqsD4oR76xHm4pObXk7bFNR1703lHcxH6I7P5ieo36Atx5TkPgMH767FvhunB2 >									
//	        < so96iU4Fm8Fux92F2E967d8TGJl0iF87TyBFe5xf3Qn0nWSfT353WBJSgk5n4h80 >									
//	        < u =="0.000000000000000001" ; [ 000030481986822.000000000000000000 ; 000030493602977.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5AFD21AB5C18BA9 >									
//	    < PI_YU_ROMA ; Line_3032 ; q5J3nyO9yI5efr3hZ2MFckK883DoNBIF3MbM314v87bTP1AKu ; 20171122 ; subDT >									
//	        < Oo7jPb2MhYrJ0XfP22AGqdMmnoaahrKq19q1zg91bBPw9r5nb640klPANjh0Eaep >									
//	        < i2Y163P3ya82s8d1m5cFW00AbKvg1MoT2eHps1Hjnvwjgog661DN292UNqAhL091 >									
//	        < u =="0.000000000000000001" ; [ 000030493602977.000000000000000000 ; 000030503396333.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5C18BA9B5D07D31 >									
//	    < PI_YU_ROMA ; Line_3033 ; otaHX3Pc2z6CfZHq75icMetVz24I7b9r0Jo0o2P78475e7ykE ; 20171122 ; subDT >									
//	        < 7DLH0d45LpfurAUnirUBjz6lvY080d0cLE54eDCg872iX2u57a4Qn7o07c45a44w >									
//	        < 7510LxA8CHeza3PCUu14ac5z6XhFxX6J91m9HA8y6j624iXqBHf6r8UmBMH99Aqq >									
//	        < u =="0.000000000000000001" ; [ 000030503396333.000000000000000000 ; 000030510622929.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5D07D31B5DB8414 >									
//	    < PI_YU_ROMA ; Line_3034 ; V8VQP4eKv930rFu31Xc80FhZf3xpgO1xn44zX1qlhbnjt3N03 ; 20171122 ; subDT >									
//	        < Fb7U7DQa8Oq8t5G8o6YjRaR87TSRNP49Dgf9UyOPJFL34DDqb7c2JbZoFK11w7or >									
//	        < P9tawY540DI5b33L50XuT6H5NJDy8rh6471Oec9rY4LM2JV4zM3U3Oj24agxF63t >									
//	        < u =="0.000000000000000001" ; [ 000030510622929.000000000000000000 ; 000030521611155.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5DB8414B5EC485B >									
//	    < PI_YU_ROMA ; Line_3035 ; LdZ24HjgR0X1XZ5Wle8n7wu4TRbsHY0aBAR7APT6aYqU6ak19 ; 20171122 ; subDT >									
//	        < r9JcZuhEiY3jUgZJB2x40TLfTM9BmZ5SYU0eZm2mUDEbLXU3RQR8A9IuH2U74pRD >									
//	        < lR6BKZY117oR8UY3r59K8MrJ9MJ0BcMqft347Gf6kv5C345Ti4yt9E2QY4H6Vhze >									
//	        < u =="0.000000000000000001" ; [ 000030521611155.000000000000000000 ; 000030530486702.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5EC485BB5F9D35E >									
//	    < PI_YU_ROMA ; Line_3036 ; Cv6GJ3AVaVPpd40H77aaLEIN3EVJ5706j97ZC2D807Q99eoK7 ; 20171122 ; subDT >									
//	        < oKZrT1k0qx757Zf36v8l036804288LSm2f0Fh7m63BSjBv1eGe4m1m22fCfO96vY >									
//	        < 3yV22r2gB7g8Pv2VqA5bA86p59PeL65gds4m8R1pE90yPh9Xp5Ud3k78bVOYn6h1 >									
//	        < u =="0.000000000000000001" ; [ 000030530486702.000000000000000000 ; 000030540995347.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5F9D35EB609DC4E >									
//	    < PI_YU_ROMA ; Line_3037 ; CzPqMZ885Lk8oFCUwM9H3Xj4iRXZ351rC9wHF723ssuHGc8hk ; 20171122 ; subDT >									
//	        < QuzM29eIjTopW72n4r71r2i5E9p0yfNeh084K7OFBL5Pyxn2VdwcG6JC30eQ3dy2 >									
//	        < fki65NYMAH2jmC6J2uF55UQUR8d0P31MAB53l08V9XLxAaO62fahTVXLo4RmO88P >									
//	        < u =="0.000000000000000001" ; [ 000030540995347.000000000000000000 ; 000030549130277.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B609DC4EB6164603 >									
//	    < PI_YU_ROMA ; Line_3038 ; a3S0u2AlnN0Qri0hNjnLuC8ETFkT6o5108aXvcWUvHKs8Er84 ; 20171122 ; subDT >									
//	        < U1yO1Tv8utG7AkWAfKeC9dvLq31TRbd0b1Zaw2bP7n80xd9rU19HJ19fZeaejliH >									
//	        < 7Q89yP286DU3yyn4qZ8662Uvg13T9r1pd3nRR6DQL8NoI63g6rV7D2lk38A1g3o4 >									
//	        < u =="0.000000000000000001" ; [ 000030549130277.000000000000000000 ; 000030564108299.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6164603B62D20CD >									
//	    < PI_YU_ROMA ; Line_3039 ; JbRvPa032ngiscz8Dc0782YU5zWti49F1dlU4OuMAdo994e14 ; 20171122 ; subDT >									
//	        < un98iWh2Q3Alf46jzQsamk330z6b36S17YaQyHA2wA6aUBQBk9YQEGr9S313QLr9 >									
//	        < 3Lw87q8JPioyK0SvGOTX0Vhg0pQDqUJS3Q5QGYijTy6xDghSxIiPK7QPSy1ZKcIP >									
//	        < u =="0.000000000000000001" ; [ 000030564108299.000000000000000000 ; 000030572436944.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B62D20CDB639D62E >									
//	    < PI_YU_ROMA ; Line_3040 ; BMlr3Yp2s8iQE3USC6Gf662B89HE91Lecw2Rh2vc2ljBjfa37 ; 20171122 ; subDT >									
//	        < 0L0XXhZpE209teVBvA015wP90K3D80Xqg78dJ7AEg4f65IZUs5YdU7uO0900J36k >									
//	        < dqMVkj191AeML1n707dPZ53iVfzuaLibMXcE6vvrrsY054f573kl5025jX0B5ryV >									
//	        < u =="0.000000000000000001" ; [ 000030572436944.000000000000000000 ; 000030583326069.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B639D62EB64A73BE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3041 à 3050									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3041 ; ndE285k9LLhe2tzyPFYlQ4ti2xqgLko65lS85JE5fDORUBbQ6 ; 20171122 ; subDT >									
//	        < mntT6td3il17lL5dhjd22tDV508J3QV19zifoW8039Xw46sp5B6UJeJk6fLlIf4y >									
//	        < 3AE9ra5NZ7C72a3N383elstY2Vw2s7M1fa5h8cr4O2lM9AadRo5dFojoHiw385u1 >									
//	        < u =="0.000000000000000001" ; [ 000030583326069.000000000000000000 ; 000030589936695.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B64A73BEB6548A05 >									
//	    < PI_YU_ROMA ; Line_3042 ; 57oOGql0Le74DgvqkdMCCG315zH19oxQIgtp6ZX7kd05z60m3 ; 20171122 ; subDT >									
//	        < 37d8Yo9GeV3nNWWgPj8L68Au1Ze9T78M7d2kcHTluV345NfkEuatD4HybVuS1l9f >									
//	        < sS5TP5YE887za72bI42cOBVBM42Q93kmaKRX206bC9hSZrtp3k1r7pfcNt09eame >									
//	        < u =="0.000000000000000001" ; [ 000030589936695.000000000000000000 ; 000030596889414.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6548A05B65F25ED >									
//	    < PI_YU_ROMA ; Line_3043 ; AnBm5lz5ANc12562tdLXxmonQjG714Tyf0VaT98vcJh0aLA87 ; 20171122 ; subDT >									
//	        < f796wSpJhpfi1uKKQ98291XF2mlFz4tR0UfG41U3A9TfP605SNL92VUD44c695H0 >									
//	        < hY6701I6yi3Qd510m60703dZ3R8Q4L5wkL07wSf088yl4ebJtR2533alrWaWLFIV >									
//	        < u =="0.000000000000000001" ; [ 000030596889414.000000000000000000 ; 000030607883173.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B65F25EDB66FEC5D >									
//	    < PI_YU_ROMA ; Line_3044 ; F3KdhhoLUIBcBROVEUrLx5rXrE2d391K5r1gN3X6BFQKpIzmH ; 20171122 ; subDT >									
//	        < QJ4sg6ZJYqL8391FbzY4fy35GtB1Js2BxgHYVjrEO4bCX5g30I05LNzvddsT1kZm >									
//	        < mkJWo6LAV5mI9GN229YNv5QsRJQHJ1894771rb1x5S04B6rFSXxnXYXvEusK1t32 >									
//	        < u =="0.000000000000000001" ; [ 000030607883173.000000000000000000 ; 000030621743344.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B66FEC5DB685127E >									
//	    < PI_YU_ROMA ; Line_3045 ; txWL62FE1aJMsq090LH049789EyujBw2tbH81deF4BecrR8uj ; 20171122 ; subDT >									
//	        < s8FFBvpYWyB19QAS4wu4ymtR1MniJu3kUZT6PSfQrfk543PeTp6bLg9eN1nYK3cf >									
//	        < EJrwsI8FB2Y0vI7798mFPismVRWPqqme1vU5pwU3E22Tb9Gw9hWdS9Dg01mRtbcq >									
//	        < u =="0.000000000000000001" ; [ 000030621743344.000000000000000000 ; 000030627163805.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B685127EB68D57DC >									
//	    < PI_YU_ROMA ; Line_3046 ; W9r4PxE2GON3uOmfn6sABJ9XzGulDW8v723k2EJJj62boGQF6 ; 20171122 ; subDT >									
//	        < UQ5LsPGRH91324pOUOeW6Gy3IRItwGGIe00I7GyGn3OMPSwFu451Vdj2NjRdB81P >									
//	        < q36grq3Tg86rEriXr9977QaiMdpFZ6z59Rc25ageZc7Dk0yD0ETpkrV40eF5H1Ud >									
//	        < u =="0.000000000000000001" ; [ 000030627163805.000000000000000000 ; 000030639613267.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B68D57DCB6A056EE >									
//	    < PI_YU_ROMA ; Line_3047 ; 0L22FMSFO0pLdGS778OsmLZPGgqGK9R44F9ZbZxmVfvpAU1J2 ; 20171122 ; subDT >									
//	        < Ec63GS9toP8DdDx5zo6CGPsIvgYdfO7tL7E57e7o2oLZ1306iV9h8xt9Ub7G0S08 >									
//	        < 4de1mkrF99iE52OtMA7OR0L52KbvF6553y5PYnly1K6XBYtSJ8wiT31Oz2aO4SE8 >									
//	        < u =="0.000000000000000001" ; [ 000030639613267.000000000000000000 ; 000030652642544.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6A056EEB6B4387E >									
//	    < PI_YU_ROMA ; Line_3048 ; 83ZRsiTmub056Mefy71LA89ZHU8mTBC1J8EO206Uy5fK8ciNg ; 20171122 ; subDT >									
//	        < 9O3pCA4353oZolRiiloQFV4b8SCGKQ63XZ47SSu3d6r6IsEPKVeJd59Nn5bABUsj >									
//	        < 1xrso2Suzy4Wxfe0KD55v9WrqN45cgICBcstJQy5d990398b6oRNJXdTu56uU1rO >									
//	        < u =="0.000000000000000001" ; [ 000030652642544.000000000000000000 ; 000030664379083.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6B4387EB6C62114 >									
//	    < PI_YU_ROMA ; Line_3049 ; NeV0V2zAZ9bm7y5lu4i4rnh3HI44Am41K9imZGj9C0ULAT833 ; 20171122 ; subDT >									
//	        < CwzEmxUCw74eFmOwtIPw7XHB0APowuj28tHfJ3huKVdSX7Vdwz7j8z4JiHoBye6T >									
//	        < o78HxwJxL2Tg3NLZqQ2Q58YlE3B1ne5b2f5hk28GLUwNSHz9r7I8SuTo57u7gkPb >									
//	        < u =="0.000000000000000001" ; [ 000030664379083.000000000000000000 ; 000030678705688.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6C62114B6DBFD68 >									
//	    < PI_YU_ROMA ; Line_3050 ; 8d9A2kqeyyl5B86iw1ciYLW2HfX7R0aec76I8hW36V2B8320X ; 20171122 ; subDT >									
//	        < 0jMW0RBlBxiBd3gNMcrU59LC5x6jBgqkLK6Ru1nO6n9D7c3j5qz91ttET17Sjbga >									
//	        < 9we2i9u397qkdjM52D7bU06weH1HLhi35gO7pO93S2xw2eQKqc526vDGQR3U869l >									
//	        < u =="0.000000000000000001" ; [ 000030678705688.000000000000000000 ; 000030686588525.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6DBFD68B6E804A4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3051 à 3060									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3051 ; o2XKeNABKEjd3pXGoirLm1N28UCJlo05v3IaDEqbErWCz7CH4 ; 20171122 ; subDT >									
//	        < NSUt1CUNDuevBohrgHSy72LtYhly0aBOYjiC5p7WEp34Iy99uwYKP1gs02w58OVx >									
//	        < 4j7s28IYGf16hQ9005D6Q91Gg3xE5gg29jZK1J0tX05CF2vEb6QkkF7mjTw8ff55 >									
//	        < u =="0.000000000000000001" ; [ 000030686588525.000000000000000000 ; 000030698209160.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6E804A4B6F9BFF4 >									
//	    < PI_YU_ROMA ; Line_3052 ; olT5d5WX3iNo9gU41g54EG9xi32tUU3MhwfSAkH8brt4pdOBC ; 20171122 ; subDT >									
//	        < sFqtaT6746x8WooPYebK08y90ge5Na0mLZseko7i90F1jjijT5zObe8HPCg2QMt2 >									
//	        < R5gfqf5Ex79SS6gkbMxpga75vz3Y57s53laaA4U460247KHNgAw46ad514hbOyMF >									
//	        < u =="0.000000000000000001" ; [ 000030698209160.000000000000000000 ; 000030710324727.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6F9BFF4B70C3C98 >									
//	    < PI_YU_ROMA ; Line_3053 ; Y4FoN1nnfW1r6Lkw8n8GSR5Qwqj887IAF1pT5PF4gEAQ1MveB ; 20171122 ; subDT >									
//	        < xqYwme9KkRzFRQjIjj9xF2w01Jxr4OXhdbdkrMIR0J10u8G9j2blLf2T9Tobu8iI >									
//	        < EN6RsP6B6a2IN1Z4agyi4Otg0ta3DjUed8676d9Am0DHzX991y3Fb7zQDDAaFTWl >									
//	        < u =="0.000000000000000001" ; [ 000030710324727.000000000000000000 ; 000030721744705.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B70C3C98B71DA986 >									
//	    < PI_YU_ROMA ; Line_3054 ; H5wSu7dY8Ntc9Uu8DEy7AIVGeZ4M7GIAdIdkoWCew4twO97zr ; 20171122 ; subDT >									
//	        < 2a6vQ276g63RaAV32o0h6FvkcApZ8G6xdmqbvfH3x4iZ588J73I5o8k7822659wL >									
//	        < O1197QKlFi3oSEci27EZA9NKW0hk28OZORm1I9zKA3BLEImhc9hRf0ZiSV047w58 >									
//	        < u =="0.000000000000000001" ; [ 000030721744705.000000000000000000 ; 000030730178415.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B71DA986B72A87F1 >									
//	    < PI_YU_ROMA ; Line_3055 ; xJOcDK8cepJvW02L9HvU7qQIrCm8FcP3fh29M58TUJ4fSV9uX ; 20171122 ; subDT >									
//	        < 68RL65FC6qPf72K1HsA6921jI7J9i1Cb70LCKI9yDGpZMP6sbjk04IpADA18E01S >									
//	        < mHx9L6wT2ni7in06Re4YMIxD745NyFzRa5Bm0d2GM30F5jQh1bD677CUQmvgnc1o >									
//	        < u =="0.000000000000000001" ; [ 000030730178415.000000000000000000 ; 000030739499545.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B72A87F1B738C102 >									
//	    < PI_YU_ROMA ; Line_3056 ; Syq25XHuQzx616SOJG1mt6ENQrQDVmKbW9N8mD44hF52W4Psl ; 20171122 ; subDT >									
//	        < payd2PKH2k0L7G0FdbYkx5wpOG0l23C760mBtFKvF6xzWaXK30K8p4ri5vmP2MVS >									
//	        < j9nK8Z890k3h0GJulieMiW126ae98nUUf3vLl7dmis2Dz54g1E3vX26h8JjC45P5 >									
//	        < u =="0.000000000000000001" ; [ 000030739499545.000000000000000000 ; 000030751424279.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B738C102B74AF31B >									
//	    < PI_YU_ROMA ; Line_3057 ; ygth1GYDbhZaXk45AgcIv930odG20d3612I8YqfCcSbj247ou ; 20171122 ; subDT >									
//	        < uED9HgVHq2Fe09g36D1l54lFJz5ztki363C7c1S2FvyTo00n7Gle8AViQ324QOuA >									
//	        < BX2FeZ7mfNywjgJm3Zo07b6gK13JwDq2VAsWE0SIaq3CEjzTKvczjj32uYJEz1Ga >									
//	        < u =="0.000000000000000001" ; [ 000030751424279.000000000000000000 ; 000030759569106.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B74AF31BB75760AE >									
//	    < PI_YU_ROMA ; Line_3058 ; LhlI8KDE44LXN4g6fkaRkTLvmFf86a8g5TJ28K9jG78758wob ; 20171122 ; subDT >									
//	        < 1WZ3Oe97AazL20Okdh0Y4M5MbmxkJXOY6ot259lFnv18BU568oy920XP7XX6P011 >									
//	        < 2fNL477JIuMXHa3Z30bG4q6058R605gAA9V0a2wdt2L4XbAV7C65K99XGC1b2Z4R >									
//	        < u =="0.000000000000000001" ; [ 000030759569106.000000000000000000 ; 000030767730079.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B75760AEB763D48F >									
//	    < PI_YU_ROMA ; Line_3059 ; FCn6dMq5W8Cr8t052jnhk714B9X0IQGXU71NX3gso13fX77M0 ; 20171122 ; subDT >									
//	        < 1ee4Npw7UAHQYrI64XyosXN9B8KD89lb3gSXk91r149Lyn29JTw59r7q29u0IMV3 >									
//	        < Tri9dVBVwNxbk95VO1pfMAhe12R3pur5gv3c9c997WG3CBFLxE5TPeR3m0EHas30 >									
//	        < u =="0.000000000000000001" ; [ 000030767730079.000000000000000000 ; 000030777519877.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B763D48FB772C4B3 >									
//	    < PI_YU_ROMA ; Line_3060 ; MACb3kl841OAWR7aY3qmgsr4m7f9Ls29DBJOtNpmhF41Cry7W ; 20171122 ; subDT >									
//	        < Xm2b5YU8Y1SSA662O7Xe1JA8QX472b7Aj1Wx8Il8BB6XXR30zbYnm7X05aF81E17 >									
//	        < 9r5pBb7B6j1z9n8sAJ6iirQ9FY3IH8aSu72qaHSsyIM7YMT7Ib89LY5YxRg1xY9v >									
//	        < u =="0.000000000000000001" ; [ 000030777519877.000000000000000000 ; 000030790129601.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B772C4B3B7860260 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3061 à 3070									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3061 ; 7aAFCl44996eeTg9ONcNaUAL7yBR482Z3m0R8Uz40ez24f43A ; 20171122 ; subDT >									
//	        < B9ujzDj7c3e8X2TfFTdi3x33D9198l3wuVvr4zKp45P7m786Nxls0d88D65uX78a >									
//	        < B7n0T9m70qVxmu023I1q54m08U3o684oQ5elLLeD9yUo34oJs45Gs445aqLPoU98 >									
//	        < u =="0.000000000000000001" ; [ 000030790129601.000000000000000000 ; 000030800090682.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7860260B795356C >									
//	    < PI_YU_ROMA ; Line_3062 ; 5EBsE6ZW3PqS8j60G4wgaiflEGXwk9e2vqTr21fZg7tfPx12q ; 20171122 ; subDT >									
//	        < Vy5YijdA4f3pp2Ym9AJlkJUxI7iM2X619Fc6G0H7Px7C6dfLMt9P7AQOP39EHEBc >									
//	        < L378E8K2R7OAm4Jsdm31uy2JLCP2Sg62AtbitSV4VyTgOqlq08fTSzBMkZi4976r >									
//	        < u =="0.000000000000000001" ; [ 000030800090682.000000000000000000 ; 000030808008781.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B795356CB7A14A6E >									
//	    < PI_YU_ROMA ; Line_3063 ; p98QPvOohWW5f27XN348bJeJ4x8l72L9VYvY6F0Ff5cWC5Kxx ; 20171122 ; subDT >									
//	        < KH37kG3N39ySC2hVwt74416T20nDNM14XXfwZ4j3bZDI5OtNXD9iLcus29SdukC9 >									
//	        < 4LNIF4iAUHR7p1e8zn4Ih1W4iJ2OuJHndx1654600Ec98VyCXbp588is381WwN9M >									
//	        < u =="0.000000000000000001" ; [ 000030808008781.000000000000000000 ; 000030819479980.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7A14A6EB7B2CB5E >									
//	    < PI_YU_ROMA ; Line_3064 ; 90MAszhXJPDS9XM1ypA19P3IJBXV890v5H163z4R6I90FKP68 ; 20171122 ; subDT >									
//	        < X1DN6h4GM3DdG1Inbw8sU8dk8c9OBN1yw82KAH7c505TfeRO5MWT2ttgii9clnX5 >									
//	        < nadp549y220Ygoy70sa1kwFyVYFtv8rhOVD6w7O57tRr0a0ltYp57x4721er1Npv >									
//	        < u =="0.000000000000000001" ; [ 000030819479980.000000000000000000 ; 000030826910597.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7B2CB5EB7BE21F3 >									
//	    < PI_YU_ROMA ; Line_3065 ; D0uaqq4lwYhXMDKycUTy65Y6HIZ7Yvgr8znIs443Z4Fx098EL ; 20171122 ; subDT >									
//	        < 8Q8687XR3vMg9FaG5ddK04hhDC03M148gB2Crqf3IDq21U2DU6bvj43q9jU75fov >									
//	        < klwGUq4Pi0dCh7cRPKlQZdtDYEBp2NBSBeY4MoK71ol0XV0Rv2WkJvQbfk6748lH >									
//	        < u =="0.000000000000000001" ; [ 000030826910597.000000000000000000 ; 000030834362661.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7BE21F3B7C980EA >									
//	    < PI_YU_ROMA ; Line_3066 ; 5mG46Gcj87Cj8FfNVsvKc2qj2MrU51az5W95N9y65U20155Mv ; 20171122 ; subDT >									
//	        < ivwPCDwqLxq8uFHHnoW2Wxeh5em31l6N3q40n480wP1aa03pTH5OOSSmIjMOai47 >									
//	        < qLtFZ09tvV9MY5Ud9R58V5iR24X448UqKKCqeK1jhbOk6bINq22QbbUn6WsLNV5z >									
//	        < u =="0.000000000000000001" ; [ 000030834362661.000000000000000000 ; 000030840601947.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7C980EAB7D30622 >									
//	    < PI_YU_ROMA ; Line_3067 ; QOz1G9KKGa5Zrya71M24VxO05D962h95hXdj76th4B2dB0cfh ; 20171122 ; subDT >									
//	        < 4LZ8LAldaBHV50Bu30V3q7VEkfSoj78512uLkTg23oGRTUwt3xVjxBHj48vnBV6J >									
//	        < 7C04R8UveMtHfQ4i82G5sg516nY6avINlj4EilxTBhuv8XKb8Xh3TRw5G310I6c0 >									
//	        < u =="0.000000000000000001" ; [ 000030840601947.000000000000000000 ; 000030850321178.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7D30622B7E1DAB5 >									
//	    < PI_YU_ROMA ; Line_3068 ; cZYMY698IZP5d45qAj2CTE675aXFIIvJ2x6175sif4R70s48Y ; 20171122 ; subDT >									
//	        < 973z2XbvV58d0sGp8JnBrJoahovsjisUWfriXDolS9a0S8pqEqgDG9X5BVjaUYu9 >									
//	        < azo8WVw4Ko3Y6O97lXwT1zOg150o4AZ58fhcPPqUT7g5TeCSdjcmw8bxl74OXzYe >									
//	        < u =="0.000000000000000001" ; [ 000030850321178.000000000000000000 ; 000030857947540.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7E1DAB5B7ED7DC2 >									
//	    < PI_YU_ROMA ; Line_3069 ; 9rTj4JgKUBiZS6m8btG45Ge29l3vAtGc39C386V4o770HbFFL ; 20171122 ; subDT >									
//	        < gg3y8sL8W92xDDo9zlE5N3G5JkS7gL11vK9S0bAgU9jdqvOZLh9qYSlqzQtwP19U >									
//	        < qNftRPRrS6rW5jsHe0G0WNsFA352c8MKnzVP4fmhbUif9G57Z5529PWK0pSNUhXe >									
//	        < u =="0.000000000000000001" ; [ 000030857947540.000000000000000000 ; 000030863241840.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7ED7DC2B7F591D8 >									
//	    < PI_YU_ROMA ; Line_3070 ; 4oHeXtVYb69s617hz4y774x2P4sNCSPlyPQpS11k23Ya34LcF ; 20171122 ; subDT >									
//	        < kO9tlGVn5QUcHMkaJcx97d3N537096sd95V3z2mLTB3wKOL5RpHW1S1Tl5213EJz >									
//	        < 2U13vxCje59ZV1BDC6DAECV1zgkKpxvbz9MJqxCaDwPEu0R9hDqq6lk6bv2A4csb >									
//	        < u =="0.000000000000000001" ; [ 000030863241840.000000000000000000 ; 000030872392804.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7F591D8B8038870 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3071 à 3080									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3071 ; q0ttt2TpX72b4w05Pa7Z2IcKnWMhX2aaK7M1cJHMjkYcii9G2 ; 20171122 ; subDT >									
//	        < 0Wof5MiiuNg06ep07rR8xpN7DFqfa39D8Ke83txd737x5EkM26uYxu72nrFik4m8 >									
//	        < uOOVuN5232cnQThx4329yh5fBSbrKIHYdP14UqJrN1LFgDUO4QjpEMHcyaKa9hwC >									
//	        < u =="0.000000000000000001" ; [ 000030872392804.000000000000000000 ; 000030883512027.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8038870B8147FE2 >									
//	    < PI_YU_ROMA ; Line_3072 ; 4e3NdK80c3W84L7784fZGytp0tY0EUYkvsEteEapQpOCW52jz ; 20171122 ; subDT >									
//	        < Y03jPABR49iC6c18ZC1A61XS3D6azr989N6WY7jo1KN7L179axonl2kIEr59V58Z >									
//	        < t7FM3Dz2d5sNM3aZk0fFp6m5h884m3Mk6RIGb9E5S6vISrYWoQM703u8Td6211fF >									
//	        < u =="0.000000000000000001" ; [ 000030883512027.000000000000000000 ; 000030898047380.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8147FE2B82AADC2 >									
//	    < PI_YU_ROMA ; Line_3073 ; 095f53DP4s9839c36t495q9Yel5rW2ZC3EIy6OOpK506OGZ5g ; 20171122 ; subDT >									
//	        < v3ah53M4jM1ZdtLQ3o4oCiWq7Rretj8aQ8Piid75nr57YGfx4Eq7ZPzhAAd9kT6n >									
//	        < 1EvkBqVKmCR2G1xTPM7Tmt3R96iv9417O8KgD3P87hJc2bl4Kb799LPdAO5Ft0nL >									
//	        < u =="0.000000000000000001" ; [ 000030898047380.000000000000000000 ; 000030903092649.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B82AADC2B8326090 >									
//	    < PI_YU_ROMA ; Line_3074 ; UDH79U028wnAc7hJQk7qCijOU04pGj48SKv47ZaF4BK1iU3k6 ; 20171122 ; subDT >									
//	        < a7n0Tct05sT9OzH85IJ2lYX9D6902632KUD9fT8VglG7tuiWW9I847j5tXX1f66k >									
//	        < LP43C0jku30jn0fjBI4714sM59JD0398TT650fU4K0xWtVi4BBwAM5JRhI0YDpL8 >									
//	        < u =="0.000000000000000001" ; [ 000030903092649.000000000000000000 ; 000030917832504.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8326090B848DE52 >									
//	    < PI_YU_ROMA ; Line_3075 ; 1NQ2CfTmv5P9z9xou9c5M6s7F3gu2e31raox7ZExolspdYmZa ; 20171122 ; subDT >									
//	        < d7nrmldCmsjxjMqyZdCGJ96wIIg178LT1MJ5mN9enh5P87GU8O5rJ662p658vt4P >									
//	        < GD7Kf9AGf4fu5rsymBsQ73qvH6cOx7K1z84QF9V0h6HZH5E97KUdz3Q73eO0hAhx >									
//	        < u =="0.000000000000000001" ; [ 000030917832504.000000000000000000 ; 000030923198079.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B848DE52B8510E3F >									
//	    < PI_YU_ROMA ; Line_3076 ; RTK4bTLYS8vNtuR5Q13QXRiyyjEZ1fuqpJ54B0Yn8x6k0U40H ; 20171122 ; subDT >									
//	        < f3p3IYdOy64s3xs4Z54Tj46DH2YAmAWrHnFfQlpMNEyYa7bzS1493cS9oc8wsv69 >									
//	        < H4tLoWZau675p4ElWvGg73762x6vFM89V0xt845z9fj32w5eOmix7BT0d1n485pN >									
//	        < u =="0.000000000000000001" ; [ 000030923198079.000000000000000000 ; 000030933031026.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8510E3FB8600F3E >									
//	    < PI_YU_ROMA ; Line_3077 ; 578dT0c6woEFI8RoH9WY2lcD998qJd4px1P83KyYuBo837X4j ; 20171122 ; subDT >									
//	        < 3d3lgeFrD8UDHG2VP97kAT30d3nq7EO3Y8sEUF5Mub7sNri3FZ04a6vY871cxXpV >									
//	        < aZL0EOs8S2T3h8Bu21ytfPLCIFLSYLDLkm34pY3vmHvCW3e9Vp4806wm6QJCC2DI >									
//	        < u =="0.000000000000000001" ; [ 000030933031026.000000000000000000 ; 000030941993143.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8600F3EB86DBC12 >									
//	    < PI_YU_ROMA ; Line_3078 ; 34Zl08ZbgR2AVgv89HpSKVp56UVZHQ7al1n3I05Bj1Z7Xzzlz ; 20171122 ; subDT >									
//	        < JN5fWLQILkfTXNmU64mx46FTV5aGaXM0koNI2O6215d74Cx3xe21w8873SoomV40 >									
//	        < BqkaaIa14VWZ3gMdAyem3sxvE9NJOAGm1WWJ0udGYX5x4qQ1477V1fheW0MChF9b >									
//	        < u =="0.000000000000000001" ; [ 000030941993143.000000000000000000 ; 000030950818389.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B86DBC12B87B336E >									
//	    < PI_YU_ROMA ; Line_3079 ; yM1Bzb213kJ9h0439fMCrik9bvyIm6P3pL0DVav0j5wBj5NzZ ; 20171122 ; subDT >									
//	        < qVahq833r3JWjU92Qdr44Yw4S4522TVep2F48O84pLbNTgO278JSfO2u31x894Vl >									
//	        < M3uC44N02Z37ADFXl8ePYU0SCf36Cf04w42S6e5r955R0E9ID5Qyl8h0pSCGI7tx >									
//	        < u =="0.000000000000000001" ; [ 000030950818389.000000000000000000 ; 000030956718238.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B87B336EB884340F >									
//	    < PI_YU_ROMA ; Line_3080 ; 72nOo220M94446i05Q31Y9U2DVKdfMl3mOsWQ7bc72PlXQ8tQ ; 20171122 ; subDT >									
//	        < BsUrj83v3i96WblK07ze6uBs1SKSl50o1H5Ui6YP6vh55K2NH1P8JOk6P83ci0q7 >									
//	        < 8iBRY2TpC53PdYok6f40kaWY28Evs9xVFZj3yc1Ue52frloTx0q9Uf47QTB3sQlg >									
//	        < u =="0.000000000000000001" ; [ 000030956718238.000000000000000000 ; 000030968495751.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B884340FB8962CA7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3081 à 3090									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3081 ; 7lJz24148h5R141aHw58Q4kUKAaOE1Dw2c3oDzO2kn0jArm29 ; 20171122 ; subDT >									
//	        < y112JJ6VXHsLjB0e12OB0Zi6c13qTS5JR3y6Hf09Z759g8yH1Bcg20ONjQ1HmoES >									
//	        < o4t8s7QPfRADn5i8m1Q0n7oWlPo6e7KM8r09SR2NUz6qYw0NCz8lo8j1f94gp3fT >									
//	        < u =="0.000000000000000001" ; [ 000030968495751.000000000000000000 ; 000030978642094.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8962CA7B8A5A811 >									
//	    < PI_YU_ROMA ; Line_3082 ; 3d5kBR1SNYlM700Lhs4c9u041ROYjKUw1gK3S2MeShEajQ7zn ; 20171122 ; subDT >									
//	        < omEgYd7rw48Wtuy6pb0fTK0vL5yzMyfT1IXOoLWSpY0Nw07CD6786gGsYN0k7hl8 >									
//	        < 1d27Iu7K57gH1oR40i9bQWX517buL01FTM21NiU1RUHH8mI2HJReY0c0K3q6vryg >									
//	        < u =="0.000000000000000001" ; [ 000030978642094.000000000000000000 ; 000030992108531.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8A5A811B8BA3465 >									
//	    < PI_YU_ROMA ; Line_3083 ; 6FlV1gHiA5Q4qnrE4s82BdPQt772Of0BK2Da00D29u4YH60ZF ; 20171122 ; subDT >									
//	        < uj9cAHHacJ22KuD0U9j4OM3WjJFWGXdT0XbWhOrOn4so64uUJQYJbb87qDj3DjNr >									
//	        < lSW9yVtyV9C5L94IYH8kTQ9zg51lg56v3NeOJ32Vq6y21M74Dho9HZiRwjyE0m1W >									
//	        < u =="0.000000000000000001" ; [ 000030992108531.000000000000000000 ; 000031002417295.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8BA3465B8C9EF41 >									
//	    < PI_YU_ROMA ; Line_3084 ; B2GfSKJGhKYM81O38RMQoWiUa21Apb68d24IH9GseLxYiyEpU ; 20171122 ; subDT >									
//	        < wkmlHc25F1PZmbtxj6712Y2GYzCe627eVibB9ep8fZhqR9xbaOzFwpm8JEgoPa9t >									
//	        < 9Iaw6IdJluoXqk2ZqiP0V2R9aq30f467ghYviNrS492P5T0e6wZM0QWg0c6wfpLF >									
//	        < u =="0.000000000000000001" ; [ 000031002417295.000000000000000000 ; 000031012970146.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8C9EF41B8DA0976 >									
//	    < PI_YU_ROMA ; Line_3085 ; 7598x1x9x16Fbb0rzc4kHdQv95fX338ffE9pFtivi8004Ybou ; 20171122 ; subDT >									
//	        < 25KgjVsVSlY9EBM1RMdSO65HYKb21cSqh1EydM5BPnZ3Cxe0pE290T5Iq4Ofb2iH >									
//	        < XfiVP7Ta1bVbk175Vk8IRTIjF5xf2Y09zGSUDfh8Nn607F633Op4G61K30oaI652 >									
//	        < u =="0.000000000000000001" ; [ 000031012970146.000000000000000000 ; 000031023785281.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8DA0976B8EA8A20 >									
//	    < PI_YU_ROMA ; Line_3086 ; J6zTv52Pgqyj4d43zs6LAZtd2GGISdbcI20k9tu93z9wJuR39 ; 20171122 ; subDT >									
//	        < gAX1qO8ej5Q9qcH9qC8660p69k8Q9B32B732mn727IMbOMGEp1eI1g6NX7i6JVIW >									
//	        < dM14WUguRR1lSlSLdAu3TZqrt5z25XLbU33JpQZM1Q81v3a4m41csGp62AqB2Epk >									
//	        < u =="0.000000000000000001" ; [ 000031023785281.000000000000000000 ; 000031033081109.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8EA8A20B8F8B94E >									
//	    < PI_YU_ROMA ; Line_3087 ; x94i4Pt2wKoH02RxxIwf3PKw99966g5OtQjMQpBc40E8pwTQY ; 20171122 ; subDT >									
//	        < LmYBa4lZ922vI28K0gLT1zl7mSzqZxTGvcR29Z45Lrtnxx093Kgyso9fyEl7Z5mY >									
//	        < Io7IP7UBZdKjoqJs7R2eAa7IQ3HXM83c70WVnobtZWiav64c407zM8poy47N7QZ3 >									
//	        < u =="0.000000000000000001" ; [ 000031033081109.000000000000000000 ; 000031039110871.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8F8B94EB901ECAF >									
//	    < PI_YU_ROMA ; Line_3088 ; E0YRhqj01S04r9igLzFumBe6eZFHEQGtxW3Pz2J8QiPdQaTEK ; 20171122 ; subDT >									
//	        < 45hRlII63l010252M2aY6PBo0J4gI3vuX4POF1c045ftBMOo2yte35dBlPlD56gH >									
//	        < z35D0rxgIDfCvxn795F0XOhOb7092BXzHAufyTZeUq6ig535Q5y6j7394Rxi1274 >									
//	        < u =="0.000000000000000001" ; [ 000031039110871.000000000000000000 ; 000031046633947.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B901ECAFB90D6762 >									
//	    < PI_YU_ROMA ; Line_3089 ; 88EI7N3Bs7jmR93Am0454P5GYIE6AS3ecY9QM2wXSmBP5JPBG ; 20171122 ; subDT >									
//	        < Sb2IzD0Yx1N2K991XuN5mahk5dyF5t56xUaL99m7x34h7sQ49EDxOwl6rRYCXMfm >									
//	        < p0wrLWsi1Nk5Rge38hWLBXddZZcADCCmZ8my7X5vFGZogBO04OxH41KLy53pjX56 >									
//	        < u =="0.000000000000000001" ; [ 000031046633947.000000000000000000 ; 000031061289407.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B90D6762B923C42C >									
//	    < PI_YU_ROMA ; Line_3090 ; b1KCoR6AU3V1zu4aU2U6OhpT2Ct1bbT970O4OTzt6G7lPSc5Y ; 20171122 ; subDT >									
//	        < ys0y69bEI21kN3q6TvCa2OG5nreR5G6af4hfn8I1VUG9Z14H39SvEQw8H2JPELk0 >									
//	        < zXEasRz1VoaMBlR1pIUBBxy8z4ZBI5k1o1Dpi24h143boQb26GpRmw3Fh1TnqsH3 >									
//	        < u =="0.000000000000000001" ; [ 000031061289407.000000000000000000 ; 000031074089127.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B923C42CB9374C10 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3091 à 3100									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3091 ; WeAnrL3g2Kzr2D7Di3d1oSSV98g8vCv4J6WGoP68tMqZmN2R0 ; 20171122 ; subDT >									
//	        < DY670Fepn0LgW7k9gr99BFzu6K73Iul4e3Nxq8hP8hM8bmN8q3a8yuvB743WlXFo >									
//	        < 6Nc0xeg7vwkU64q0kKxav2AJ88R29OXDWyn3h4KpyQ2etD7sWB56C3Iz6p93lF50 >									
//	        < u =="0.000000000000000001" ; [ 000031074089127.000000000000000000 ; 000031080692099.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9374C10B9415F59 >									
//	    < PI_YU_ROMA ; Line_3092 ; nf9Y4G6lywmAv0n1B2WL58mDEtEVr11BrzxwI970sNr5C2tS1 ; 20171122 ; subDT >									
//	        < P6mbAmtrT53sT55Ibn3R9Fpme8C3Q37h489y97RVxyWMpNY3LNTHM71zp85ABBd9 >									
//	        < T0isT1Q10K738IvsHC3B3tgATgF81986jq9jg45m9Fr36nEM8X5r3WZbd8iMRER0 >									
//	        < u =="0.000000000000000001" ; [ 000031080692099.000000000000000000 ; 000031095258782.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9415F59B9579976 >									
//	    < PI_YU_ROMA ; Line_3093 ; NpP7U6i7z45g05f9qTgmh9E8w9cA4km6L606ixFO3bhuI1I4D ; 20171122 ; subDT >									
//	        < Vwjj6mguw9R80U0hMN3Lk8Y7D2O56vzfJ0358WUQ993Eeh1QvdHFlx09G67424py >									
//	        < jodU84Tsq22P9ArSki348k5IrGCwxS71k3s9AE7qYbDny2556tKK0q9Na1TQ297b >									
//	        < u =="0.000000000000000001" ; [ 000031095258782.000000000000000000 ; 000031107869747.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9579976B96AD79E >									
//	    < PI_YU_ROMA ; Line_3094 ; B33jdKTc3JOkXG2P6vy6GU10gaKe51v238g29PmQP4NT4089C ; 20171122 ; subDT >									
//	        < j8725pCztuPN1Wm1w36Q9yUg5rdVRP529hyn3ax7I579h9Jp9mS6F98ePowm6GNy >									
//	        < v22fa8uqGLuR3UM62GBiiCV94G6ioJ7dqqI577b0N48963cB2o2B81pjd2l8A62T >									
//	        < u =="0.000000000000000001" ; [ 000031107869747.000000000000000000 ; 000031119067667.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B96AD79EB97BEDCE >									
//	    < PI_YU_ROMA ; Line_3095 ; OI3RX45jY3WelieBww49Ko1W67DCD2qMXgr4WXG5j2VxDZc8m ; 20171122 ; subDT >									
//	        < 7SWwRg6E0ToLWxc2ngHsZN94kO1j878dl824Fu2PC9Kxff8M8J1b71MnTZ5stth3 >									
//	        < QtcLkQbYyP71uyoOr5ow15jNKn7Ku9N6vwH06WM727w58LUzWmwQfJOx5f3AMUmf >									
//	        < u =="0.000000000000000001" ; [ 000031119067667.000000000000000000 ; 000031133197821.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B97BEDCEB9917D66 >									
//	    < PI_YU_ROMA ; Line_3096 ; WisSRMdyw0w05qKAtf3LeTY1gRa10PFs5s770o1bc2P4i3tzc ; 20171122 ; subDT >									
//	        < KQxHy5EDg5W3a581wjs99cSY67etBJ06Rlxz0ARj11317k6zgnlYuTQD9g55jc1a >									
//	        < 4WhcWqxC92j1lFUUb9FOaMEw73L73kI31D32Z6pkYvQDG4wMg3E354W90J093a6A >									
//	        < u =="0.000000000000000001" ; [ 000031133197821.000000000000000000 ; 000031138416081.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9917D66B99973C8 >									
//	    < PI_YU_ROMA ; Line_3097 ; 4RQ5Oi46AGxkPj2EUz4B1hEP825r1MIFO8vvUVluf7m8FdcFA ; 20171122 ; subDT >									
//	        < zsf01loA18D61YtAv46s00CCig07a11Sq8py7X9zB5XZG8a28suaeZd624170wkw >									
//	        < DBTXli8A1hpqUE20t5EE2d7r0URCghli3pmHRtIe4j27VNkGAwROEPE9Wvd23YXA >									
//	        < u =="0.000000000000000001" ; [ 000031138416081.000000000000000000 ; 000031146633418.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B99973C8B9A5FDAD >									
//	    < PI_YU_ROMA ; Line_3098 ; M3x42Y7a5MgHvK0vBh4FUVn6z1dJuPYO5F7zAN5F9j1453008 ; 20171122 ; subDT >									
//	        < O02IS9hDb5sCNViHDu2s76ydyv7WU2MCf43xEEw98LOcS0zr9kF50326x9qPXDT9 >									
//	        < 6LiqJCw9FR54uwIq7PdlKu9f2bhIVd6Tz8Ay1064zT9T53s4U61QAWmr6L7jevfs >									
//	        < u =="0.000000000000000001" ; [ 000031146633418.000000000000000000 ; 000031152777651.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9A5FDADB9AF5DC5 >									
//	    < PI_YU_ROMA ; Line_3099 ; z6i7uBdwY4qoxk048XERA8C2ykru0IQZL5yJvjnWGkIu1d8TV ; 20171122 ; subDT >									
//	        < NB8HQW1GvS65e6SG8xNL5214TiMEGFhCT0Y0K9r0M0tFNs4dV0P967QYdpxq9qo0 >									
//	        < SARGbf1i7YNP4K56KtFCWi6l1hW2eUkjpZP6c5j5MH5CMd7E4u80zU3zB1T63Lf3 >									
//	        < u =="0.000000000000000001" ; [ 000031152777651.000000000000000000 ; 000031166673952.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9AF5DC5B9C49203 >									
//	    < PI_YU_ROMA ; Line_3100 ; 2U04PkDwrmXXwu2pxu46sXX6e3dR26qZY4OudDnhu6F4h4LP4 ; 20171122 ; subDT >									
//	        < 4i16zar710CCrdQV4uF70sYjuqPF9242NZcbFKJSTjZa1e2yqe4QYoO3GUhkwyq6 >									
//	        < Pvt5dv2xMDsa7L6yBpW3Q3Df9ZfcADY97FtnvxF5FEujY7Vd0k5oWA53QgmqN63k >									
//	        < u =="0.000000000000000001" ; [ 000031166673952.000000000000000000 ; 000031178377170.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9C49203B9D66D95 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3101 à 3110									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3101 ; WeaTS581dcRx4W905W5sG0m1Sy7qMgrI3Gv08kMY09CI4ImHz ; 20171122 ; subDT >									
//	        < U6790FSDoJ2jljDOp0B2RvUsbcNl1Ib0JcPjzH7n8R9qVI27gj8M8ir9r5pVtJ2D >									
//	        < geZ2RNJ3n84bCgs82PtKVr931Jrlg902ZWSY5a10j1P2t6s41vV4SdX5Bet746Ed >									
//	        < u =="0.000000000000000001" ; [ 000031178377170.000000000000000000 ; 000031186828720.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9D66D95B9E352F8 >									
//	    < PI_YU_ROMA ; Line_3102 ; 4lqk516o9v9vfQY4PjAx6vkuPsOgcFO2I40CUg4cXOnOF277F ; 20171122 ; subDT >									
//	        < MJ6Bkynvk751K1M9MmGs802b3fW9N2l8G3b9glr16T3vHoBGSOO89I686Vfo3HIl >									
//	        < lqhIO38xS6J3r62okM88Pgzsn4vpy3MWygHW40LhBt3eG5m2OOx26k045sQW40nF >									
//	        < u =="0.000000000000000001" ; [ 000031186828720.000000000000000000 ; 000031192324013.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9E352F8B9EBB591 >									
//	    < PI_YU_ROMA ; Line_3103 ; 19crJdmM4q5Ido87xPJQCc8Hm60PTOOz244quVO9cFy67mt7A ; 20171122 ; subDT >									
//	        < B8A0vU3O1ZBAMtJs2SohxVle07rBj559j3dIH1W2g59uTR3fKCwY2aPpTCGvw39L >									
//	        < ueewhA9ngd2R0L3T50RbN16TIJWugN979YtH0o75A1Oo6D5L73y6IJP1LJc801cq >									
//	        < u =="0.000000000000000001" ; [ 000031192324013.000000000000000000 ; 000031206126364.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9EBB591BA00C51C >									
//	    < PI_YU_ROMA ; Line_3104 ; KSt449W2KFf6Oh03Cn6ez9lH953D88OOb9z4Yt36w0UZx4Ak0 ; 20171122 ; subDT >									
//	        < Pmg5W2A2nTZ6OS1JIuEPlL625DcudI7wd85FxaGN0tR2i8hJK07dOqY5bI107v3G >									
//	        < X7T0r865Lv8voQc1012jhx90YS339oG6q2X90P02k9103W9Wa9u441D7UGU28PA2 >									
//	        < u =="0.000000000000000001" ; [ 000031206126364.000000000000000000 ; 000031214256885.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA00C51CBA0D2D18 >									
//	    < PI_YU_ROMA ; Line_3105 ; 65B86GkM3qOL7K8Rj2rO74KTL9KE31kcmbW4I5LPRV567jfZp ; 20171122 ; subDT >									
//	        < c2h1G4t1mN44y50AcqM2N18o0h39DC0RH3m9yII6Lh8Mo181OE2oMv4k0giA7UHh >									
//	        < SKQaHC92qC452HW7p2Rx70XHD6B740cB0QNzM15vo6AL69Jhy1PgAbX392kn9566 >									
//	        < u =="0.000000000000000001" ; [ 000031214256885.000000000000000000 ; 000031227230257.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA0D2D18BA20F8D1 >									
//	    < PI_YU_ROMA ; Line_3106 ; 66on57H2VZwL4X8RB8LkqJthH8hBI8p2y84h83T3Q0CJK8766 ; 20171122 ; subDT >									
//	        < weNsYeKQTEgA2v08bK9J7W5zWkpe480qvo7A4Oqz4959o4pkiOS1v66E88k82IDx >									
//	        < x43XRa0mGFD64C02QU2Sn8FAZ6uffzUV0j3ZvoH4d44zq5I5zlOa3kf9EZ52Gi1V >									
//	        < u =="0.000000000000000001" ; [ 000031227230257.000000000000000000 ; 000031234503267.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA20F8D1BA2C11D6 >									
//	    < PI_YU_ROMA ; Line_3107 ; 0hadNr6LNo2OFdrB8Tb08sOGg82d3j9MyBKbeg5yChlZ3p9w4 ; 20171122 ; subDT >									
//	        < w4XyfqJ08pFtJf58o5v1SE2zJCWZx15Mi4Jj4PSu14AWYhL1XWwa7hCaZKMzrJVy >									
//	        < 5FwrTF6HmWcBt88kcq9GOx7ii3bGlQzv4AIS4GBK301DS0TWMDU3asU4037S1bii >									
//	        < u =="0.000000000000000001" ; [ 000031234503267.000000000000000000 ; 000031241372769.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA2C11D6BA368D3C >									
//	    < PI_YU_ROMA ; Line_3108 ; YHR0Ks38BFi4LI12nGn4k7BevivZOL21eLmK82LJ50a67eUR3 ; 20171122 ; subDT >									
//	        < O4679g4cd8VcQ6460YgEs9bqgADIpfJb2b3e5p9wLJsQGA809VWBAOXDi6ObpEmc >									
//	        < fdhnHiA08ZPm10Nekx6M9UeZ03MvCVvzme4XLbpFl0IjYxtchyKlWaO73PwE7IXo >									
//	        < u =="0.000000000000000001" ; [ 000031241372769.000000000000000000 ; 000031253333775.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA368D3CBA48CD81 >									
//	    < PI_YU_ROMA ; Line_3109 ; ePoYRPgrtNhj6wEy7G1L8p0R9x74x58fuit3397lmVYX9TyG7 ; 20171122 ; subDT >									
//	        < 5ua6K25KB835L34jPYXV5Mpy7ht62G1b9swAh3U5W29rAeBHPqzRDmHjz3y6iGHT >									
//	        < BHUNPZ416Bl996T235RP4n1j28VvcR6ZdhTKKmB2k8B6C70Y0A31MRLudAV3xjS8 >									
//	        < u =="0.000000000000000001" ; [ 000031253333775.000000000000000000 ; 000031265157705.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA48CD81BA5AD83A >									
//	    < PI_YU_ROMA ; Line_3110 ; 1d1Y89n6fO2nJra8qIlPuDLo3D9D4374PSRuU5950110kg417 ; 20171122 ; subDT >									
//	        < 1CcbumUG58vz3Xp92Q9Ex74EpOGMIuV4Bi6afvfw7ny8k90Yi6OHYJn6q4LP6q2W >									
//	        < jfB6PjO37Sk5MY9qP1fLegqnRBPaJor163ZS6Vr58Nu797331c439pKZg8KBH8q3 >									
//	        < u =="0.000000000000000001" ; [ 000031265157705.000000000000000000 ; 000031277291141.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA5AD83ABA6D5BDA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3111 à 3120									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3111 ; 6Dk5F8FEn0Gi2mtCqQo4nCjyDJVIWU8p1jmrEPl5d2crGZkBJ ; 20171122 ; subDT >									
//	        < 26oCeUGbG664A4f4fCP4NpoZ10egf2rLUjHaC2l84t5ngF48RA60in79YW66Z9WF >									
//	        < KHaoJ55A7389rxnp069OqwSOyO6098W7eQfYA3R7b6cTgxtGE1PTzc01sI19vOca >									
//	        < u =="0.000000000000000001" ; [ 000031277291141.000000000000000000 ; 000031290424562.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA6D5BDABA816618 >									
//	    < PI_YU_ROMA ; Line_3112 ; X23EX25v3h3v9MQkD1eoAV782D06N73aob8Hx45a4BL7500CX ; 20171122 ; subDT >									
//	        < 6KBpNE4RGZwH1ixsi3hX1tr7OdCg54462F8d5S39T1h209wU49gbL6225nm5EISC >									
//	        < 9794SBa5zgfdxK83ZP3w2hGYxIJ8TVFsduoW3uzu060YLhQ9i4qEVsWUWn4h96f2 >									
//	        < u =="0.000000000000000001" ; [ 000031290424562.000000000000000000 ; 000031305276218.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA816618BA980F85 >									
//	    < PI_YU_ROMA ; Line_3113 ; nOiC6fhDIu624EI7uf18Lu3tEWkgy329S7E73E1PlZ5KRlhqe ; 20171122 ; subDT >									
//	        < 0icoe1pSpQgWnz22oIu8KxuUYIiFZWR7dyWKGiP0q5X9W0unZ3T0H8bpvT1V6rcU >									
//	        < CC33168c9mLa4JoqP4i7khuKF1J7JdKtDQK3eLE0O94Td7z979xh3tjlhp60U9W8 >									
//	        < u =="0.000000000000000001" ; [ 000031305276218.000000000000000000 ; 000031311219218.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA980F85BAA12101 >									
//	    < PI_YU_ROMA ; Line_3114 ; bc41z5sd7gt4T68tcx94B0Cki2q96i2wlq84Uus7Y88y5462z ; 20171122 ; subDT >									
//	        < 16Q91pBaD7z0KV7DXz816R2bZahAQ20Nl4BW4GlCRr5187qdeD9o4487joxSe3jc >									
//	        < j2dEn6Q1pKi30QZnj1rR919VT1y2757Tf7j7BqrgOb56BXVjIVVDa3bfm0B9urNQ >									
//	        < u =="0.000000000000000001" ; [ 000031311219218.000000000000000000 ; 000031322393694.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BAA12101BAB22E09 >									
//	    < PI_YU_ROMA ; Line_3115 ; B70yGmTWmj7xoTpj8TqMF4u2kRzXf5H32t0sQddm1Zv2fnMZ4 ; 20171122 ; subDT >									
//	        < v7gFyNfUeA8TIrt027sS7JoST6tap9mHIOp81cxjtvaWjmZL7g653w9B8nkYePsJ >									
//	        < xerTRk17C3jDP2c85bRMiXN4IVYz6192x8al5049HTt0Yc5uo9EbuV81V3COeOjv >									
//	        < u =="0.000000000000000001" ; [ 000031322393694.000000000000000000 ; 000031328413445.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BAB22E09BABB5D80 >									
//	    < PI_YU_ROMA ; Line_3116 ; 36R104n268q4A0RbJ8uNE0YUBDx1wq4Szl9lUm8nfQN4wQu8s ; 20171122 ; subDT >									
//	        < Gcd55NfBmtms76qUk63v56B5b2XozCbWsLZYL13Zs1N34MLj9zM908ya01yYGLDQ >									
//	        < N713X3CSyH93wH9Eg688vtkjx7MuBJXH9B9cB9QOzD0zLfuMoSMYC93ywf57JW0e >									
//	        < u =="0.000000000000000001" ; [ 000031328413445.000000000000000000 ; 000031337287547.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BABB5D80BAC8E7F2 >									
//	    < PI_YU_ROMA ; Line_3117 ; Q99h1pYKj4fda9t0w5rfl59o8TSlsU9PX3dSmDmjFpYUxg7nA ; 20171122 ; subDT >									
//	        < 5C2n3201ZDDU1g9gcv80IOLwiEpiUDJyO03efulZ57LvjPQHLJvmt62iSd0vMPR6 >									
//	        < 7EfIWThQ7NDzlcT3Ypsx5G9Pz1d3Yc8eEVWaz9GdBUaaNzXvg9N7zw15Zjhyn6U8 >									
//	        < u =="0.000000000000000001" ; [ 000031337287547.000000000000000000 ; 000031345704850.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BAC8E7F2BAD5BFF5 >									
//	    < PI_YU_ROMA ; Line_3118 ; 5ZrI8qVKY44AH1IXk66vtU0Xx8v3XmdMWv387TQcfR61UYK5O ; 20171122 ; subDT >									
//	        < Fyzy495CuZX78Ro8xm4BEqdr5aO8R2o9F3RP52G9BiyKpKf3igZG4mmmhZj3ZG4l >									
//	        < AnjvjUgv6o812bbHNHOqg0MuXvm7gIP1Uq8F63yYQgj1Dfl2i4c5T7w236ujDuse >									
//	        < u =="0.000000000000000001" ; [ 000031345704850.000000000000000000 ; 000031353052145.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BAD5BFF5BAE0F5FE >									
//	    < PI_YU_ROMA ; Line_3119 ; a89WR16TmZw172xxwg4rw1HfG39C78Nris1y4Humw6CPfW7Cp ; 20171122 ; subDT >									
//	        < Wz068bfwh19LKp2hg518HQ6yvwok49JQjxbT5qZGE0yWdU2ZgwCAoUTMAe7BZ6z1 >									
//	        < o4at80ZxU1w6wc80wL8V7rFaf48RWgOL6D4Fq9efa90h21df614di648tB03I9dY >									
//	        < u =="0.000000000000000001" ; [ 000031353052145.000000000000000000 ; 000031360307615.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BAE0F5FEBAEC0829 >									
//	    < PI_YU_ROMA ; Line_3120 ; MQ4wfZh2p1D4Gn1i4ogI8U6tZ5yk802fslxIbtmpA313qT1B6 ; 20171122 ; subDT >									
//	        < Dj43PK2J3NuqcVjTxj1La9r3EH0o379rmDc6m0bTkTJx1J07R88hLs5ECvq790nc >									
//	        < 559jc7vf0gqUhHO0AWiD4J7lnW2gq6ahPy3dZLB40P7MM7PXWzdSI2T6N3Bid2rb >									
//	        < u =="0.000000000000000001" ; [ 000031360307615.000000000000000000 ; 000031367266919.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BAEC0829BAF6A6A3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3121 à 3130									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3121 ; c2Us7i0p5ht04cqag39Zs9M3h4r8O7U91Tnqm5Fl1T7zbNz36 ; 20171122 ; subDT >									
//	        < tb5jGdMsXg0S5095b54QAe49h9Hnt7tdFtF6LRtc7s796OsC6xBTRNSMs3R78Tid >									
//	        < 4Z9NM0Utkq203m5na7HTUl18B68OYre4Uyh406Ikx3YrKSV6X0mAiktYw0dX5jG5 >									
//	        < u =="0.000000000000000001" ; [ 000031367266919.000000000000000000 ; 000031375933314.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BAF6A6A3BB03DFF3 >									
//	    < PI_YU_ROMA ; Line_3122 ; 19e0GDYHpKcZ7fVu6GqmZHO181ZADxnaauDI8neWe4pNQiuN3 ; 20171122 ; subDT >									
//	        < 96C2956ZtP860Nwm7jwmWcs930wu1PJ8f4r2c8E1W7A1IBUqH9V70g0z25Y6TN1a >									
//	        < o3HbIo02z6a5lF6N6q660kuY6f142HqIv4l8y1f5dN5O9IbOt6CP4x4Bys467G89 >									
//	        < u =="0.000000000000000001" ; [ 000031375933314.000000000000000000 ; 000031384965879.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB03DFF3BB11A84B >									
//	    < PI_YU_ROMA ; Line_3123 ; KN33o5RI21OY8k45rl9xcFcKc96Y8y67BQIhgCy3Tdb801uyu ; 20171122 ; subDT >									
//	        < mhe5W4RA7sEiRBelg6E293ZlU52L3d9O8Ce6maQAfc4i60ekE53ootaNohTKV153 >									
//	        < 72z8N7G427BlZQs1kU649R4b5bftjr352MPd5yz3V07X76754iU7M5vJb28IzMp3 >									
//	        < u =="0.000000000000000001" ; [ 000031384965879.000000000000000000 ; 000031390654034.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB11A84BBB1A563B >									
//	    < PI_YU_ROMA ; Line_3124 ; v1vl7nbAlr6X7X1ZfJIWNB8nzngTPs5tv2Jw9M63DpxXko343 ; 20171122 ; subDT >									
//	        < zVt3143t04bIC2aIDY6XFro80E2PcggT99jA8dcQiM7cOAX18lSHZRp9n7FOx3oY >									
//	        < DuYVHMdAb8li5eQAWE3CcxN4oHW70h7Zo48cEj1MrJ5FRm1le68nBLKxY068J928 >									
//	        < u =="0.000000000000000001" ; [ 000031390654034.000000000000000000 ; 000031398253515.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB1A563BBB25EEC7 >									
//	    < PI_YU_ROMA ; Line_3125 ; mxBv8Xb4lgX0Pyaf6StF8l71qrEqSWJlsTWx09ErnT9I7dedA ; 20171122 ; subDT >									
//	        < 1E2t3rOTX8aUxVH7qhYcGGLzz1Nz1o93Omfgmy1ocQ3lmFgqujTu6B77xP7R8TQv >									
//	        < 7GhyG1N02k9MbN45W19DWfxMuz48R4sdL3ZeuKef0ale9389hCfElM6l38SIKso0 >									
//	        < u =="0.000000000000000001" ; [ 000031398253515.000000000000000000 ; 000031403272645.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB25EEC7BB2D9760 >									
//	    < PI_YU_ROMA ; Line_3126 ; BD7Vd8QY0mna5lo2sfFYTyPS9VhCYda5p8QM8HY93le6felGO ; 20171122 ; subDT >									
//	        < MX7mKYH27M2W4harboHd11JgsTWYULD2gEX48uwF0L05OqFYI7jEe4sngx48J15d >									
//	        < 0wC5nNgl0ILT0rwfypxS6Qi277JpNj1doCXi2Vf67nErg9o15cL7b4iFZc18v9ih >									
//	        < u =="0.000000000000000001" ; [ 000031403272645.000000000000000000 ; 000031416360695.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB2D9760BB418FE5 >									
//	    < PI_YU_ROMA ; Line_3127 ; YHUMXfNbEGP6ujA3Q496qeEY4oe78TPbWiasbIC1xEaJAB37y ; 20171122 ; subDT >									
//	        < HVd0DIFPvYr0zBy0S8mlkDWd47iPtyVA5u7fSptT6Cja6xRNO22rkUjkE7iz8AT4 >									
//	        < FlOL5mWG2O6V9Jz0AKCb0ocQA6AwR5cG4Y6y0Q2zO2XB2Ol4mWS6i91dE8RD606v >									
//	        < u =="0.000000000000000001" ; [ 000031416360695.000000000000000000 ; 000031424314393.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB418FE5BB4DB2CF >									
//	    < PI_YU_ROMA ; Line_3128 ; 6ABgiBE085Ydfs2yh35DTg251FWp4S942AX2XlnIdN8qEgxcL ; 20171122 ; subDT >									
//	        < wRx3M4Z7h7tsMQ51Wci8qZUZ54AE201S44B872KN8w3S8ecXIQ1IaKPT07Ji1t5a >									
//	        < XHRpXFGYh3959EsDzZ4TsQ6W90DIK36607exD97GkH473V7tTbZl5Cb4ms238DZs >									
//	        < u =="0.000000000000000001" ; [ 000031424314393.000000000000000000 ; 000031429902611.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB4DB2CFBB5639B5 >									
//	    < PI_YU_ROMA ; Line_3129 ; OKIR5Rg9Q0dr9718INKVke801kp61Z0mH6e32DBpX60o60Ecl ; 20171122 ; subDT >									
//	        < elOfTpA52jodRJ5s3n45x2zU3lRHXf397gsANX5VCV0X73AHss20cfx01p3yCfj3 >									
//	        < 868uu28PATl3L9qrjKZg6OXMcx65nVr58QKeFc79dEux88tf3wpWOiwj311c7Ket >									
//	        < u =="0.000000000000000001" ; [ 000031429902611.000000000000000000 ; 000031443875953.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB5639B5BB6B8C0B >									
//	    < PI_YU_ROMA ; Line_3130 ; VQrrDZO7h76Y6ly0tMNVIvMn9PTDPB7UDd6qOA36gslPfezTL ; 20171122 ; subDT >									
//	        < YxLdI3e1cnZ2DY0T4zr823b28aQ3oxN9vj6JVFHHr0M0EfTR4WbGHn7Io2806tRa >									
//	        < D72shbYR62cSf7sCNb4qTuFtJeg5CCjpxIzcWyFJzwl352C9z3ou3W165007fo39 >									
//	        < u =="0.000000000000000001" ; [ 000031443875953.000000000000000000 ; 000031457217803.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB6B8C0BBB7FE7B4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3131 à 3140									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3131 ; Ue1j004xx8T0ZcRpUxL32sTs0gi1I7AnV3P6hLj6DkyIv16oS ; 20171122 ; subDT >									
//	        < b4M5pU23uCA9fK7V00Ww5v9EOI5659oIv4M1gfb0iZ4aC6LN4QRh3bpdRXXV915B >									
//	        < qxL0fw1J2rPIeFU1767b10VWEu778gRoWg7nYwbFv2y384QlPvUaSchDA0whd1I6 >									
//	        < u =="0.000000000000000001" ; [ 000031457217803.000000000000000000 ; 000031468574974.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB7FE7B4BB913C19 >									
//	    < PI_YU_ROMA ; Line_3132 ; NP2XgC58N8nSEN1T2pQ72cI4D9b2MI8UKZ5l23521dO2McFxg ; 20171122 ; subDT >									
//	        < T1QxIqpb328XSTHXHi5ISM5W6zZD26X30FRP1PTY1ZvB4fy3CiD2TV307t1b9FPM >									
//	        < fq42PL1uJ8XYqUBeCSQfPI68G1Xrux3DWYJ03y1aKfi9Ce2Oh3bjOTib2024Lg6I >									
//	        < u =="0.000000000000000001" ; [ 000031468574974.000000000000000000 ; 000031483517229.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB913C19BBA808EA >									
//	    < PI_YU_ROMA ; Line_3133 ; EE61phcaOW27hD4FJW9b88Lt34Kx03z0tgfD4Om3sh5HxEWwL ; 20171122 ; subDT >									
//	        < 8ZG02m2l44DbO3b7f7qBeZ5o07AD3QyfyVqonXeJahM50I5J33F34cJA569NH822 >									
//	        < qmWUsF38415asN9su9kU5Gp3kPHq5Llxe8shB6YdI2Lc2fJZTpMlKm7AdE11WxSn >									
//	        < u =="0.000000000000000001" ; [ 000031483517229.000000000000000000 ; 000031493308662.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BBA808EABBB6F9B2 >									
//	    < PI_YU_ROMA ; Line_3134 ; ZH0sIHKq6C9H8ukcsONxCVVI030PvI0IA67FvBfhfgj66I431 ; 20171122 ; subDT >									
//	        < 6v7a3EJtlKp9rO79N2L57yix8n9HDnHc949hD99cH0Z9T1G9U632fY7pIdneR75s >									
//	        < yYCSS6aR2PfpEAUStfHg3XzFXbi6KYOWCuCFHz2v54ue6yhj6X5wOPZr0tzcHMci >									
//	        < u =="0.000000000000000001" ; [ 000031493308662.000000000000000000 ; 000031507481033.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BBB6F9B2BBCC99C7 >									
//	    < PI_YU_ROMA ; Line_3135 ; 89m48UOPq0c817l3uwcCurL6hpgmPlNcqPE4X4F2xySY68i9L ; 20171122 ; subDT >									
//	        < M17fE9sjX9VLLnmt881hq3z9krIA7xJHgmcwNyz44shgG7op4Hfp67M41X11siz8 >									
//	        < K26aZd63KL6UXt33d3g3jGKZ8eQcZMZcK3jNoa0xJ01r16874YgYCB0N1XB6A8E2 >									
//	        < u =="0.000000000000000001" ; [ 000031507481033.000000000000000000 ; 000031513191096.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BBCC99C7BBD55045 >									
//	    < PI_YU_ROMA ; Line_3136 ; K9rFyNcaT02IomdEPITTq0Ca9ed6a3fNO2Hm4wwqYj0DM98de ; 20171122 ; subDT >									
//	        < UmXdLn6X45a4gL2LQL26N4HlJo6hL22G9VG91jry9F7b6FaOhDSxdSt4A5Zqm1Pd >									
//	        < vTm3sXRPpp94eqkSsZVB1rmLhbeO05lkCO5MtV11S26yK64TE0ztlUocz6piI8sU >									
//	        < u =="0.000000000000000001" ; [ 000031513191096.000000000000000000 ; 000031527181530.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BBD55045BBEAA949 >									
//	    < PI_YU_ROMA ; Line_3137 ; 160U1uyJG524qkl4c8He5QZkxp07NsEcqa1W5fquh306itdf0 ; 20171122 ; subDT >									
//	        < N5mWKu5YzTN99oSc7neV0d2qzz6jh7FV3973luB2B1hOWooBvkC0vNFskShDSmBy >									
//	        < 8A2m6eNtsf0CS0GDc1wqRnwDmFq7MHsHx3lqYU3ro2T4eM937Hm3XRV9sSTZOKf4 >									
//	        < u =="0.000000000000000001" ; [ 000031527181530.000000000000000000 ; 000031534350103.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BBEAA949BBF59982 >									
//	    < PI_YU_ROMA ; Line_3138 ; pAcUB855ddjG5MlrdL49PsoOqJrLqnp8MP43NKQ0KPYNs39bm ; 20171122 ; subDT >									
//	        < T67KlX7osaf30969VinLAHffD521a96KCC1o6Xp4j7FPgVRLiYnfx99ZnwBN39St >									
//	        < RJyz2275Y1LbN2ZG1r8fNmE54rjCLXiTJrELCcV63EgDqI8w46o71kMl5kIKYKZq >									
//	        < u =="0.000000000000000001" ; [ 000031534350103.000000000000000000 ; 000031548350142.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BBF59982BC0AF646 >									
//	    < PI_YU_ROMA ; Line_3139 ; j6ZO77O9i5Y92IY68Ah97gkCPm2aGX0dJyM30ZP0j3ljOA7xO ; 20171122 ; subDT >									
//	        < ly5cyVJSa9jH1smkg8e4CYq5lomAW2v4R25w16iV7aDEQ63eO7BGESrSrd989D45 >									
//	        < 99c7obEREOZ1ot382m8627in5FH27m4SKD7nZ82Xr7oLDj5wN37J5I0mtBOnk2Up >									
//	        < u =="0.000000000000000001" ; [ 000031548350142.000000000000000000 ; 000031556229084.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC0AF646BC16FBFC >									
//	    < PI_YU_ROMA ; Line_3140 ; rRS1Sc4XgxA3oUcw5a5x4UiP5yFkLHY7I2pR9c0izJt4Br8OI ; 20171122 ; subDT >									
//	        < TuyxN9ELMVo1O14jlyTZD3G0wnd1O8qF0x53W71GqdwZJJCErdC5RsY7b403FOUe >									
//	        < u9IRT61536r0EwR7R754wR185Rq5nWDfrFpUPxe04T2UFsbCV13fX5BkJ94i5XiD >									
//	        < u =="0.000000000000000001" ; [ 000031556229084.000000000000000000 ; 000031568981200.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC16FBFCBC2A7148 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3141 à 3150									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3141 ; Ynb032A2b43D32A6ijT8uFN3XZ22t08S0uf2yw7q6agWhi8To ; 20171122 ; subDT >									
//	        < 5co3GDlW41EZdr6CtNqL15cdKQ1t0HpwU3oDO57zKlI6nPmFBPA8V00USkrb245S >									
//	        < ivu2UCuuypksVO2M8HS5ZtO1z2Ac5pmihh9ME5y605ZX6qpL2P9FBxuD7T71709t >									
//	        < u =="0.000000000000000001" ; [ 000031568981200.000000000000000000 ; 000031578300966.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC2A7148BC38A9D0 >									
//	    < PI_YU_ROMA ; Line_3142 ; 8R8j0FnSv5eyXwul87RVi1S145CIz8bryqQu11t413CAXF2kH ; 20171122 ; subDT >									
//	        < c5Vg8Qa6x91px2fzpwarwLBztv9VnarP55T63aSgm94hdX7G5PKlZ57Vq9t1XzPo >									
//	        < Ef8ZVXrgpb4fUgzU8R6811E4CBQZ6rvp03WxTvz1NiG2Apc0ym082BhwhQI870RV >									
//	        < u =="0.000000000000000001" ; [ 000031578300966.000000000000000000 ; 000031587151271.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC38A9D0BC462AF7 >									
//	    < PI_YU_ROMA ; Line_3143 ; I8rgfWiZq8Y6J6r7AHzfjaq92yG1i97vHcEq2l0Tkd0i2iq19 ; 20171122 ; subDT >									
//	        < Y1CJsuM92P46h6J3K8cJ5A19u6E4l572x9C1h5IYYV77L0l4L80xDP5uZ489vBR9 >									
//	        < fj4y9Kl0z10xEty2dSARNm7lO8jt4E651v8lxLwM1j504JZE80D4RJD9v2IJ0zjh >									
//	        < u =="0.000000000000000001" ; [ 000031587151271.000000000000000000 ; 000031599965610.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC462AF7BC59B891 >									
//	    < PI_YU_ROMA ; Line_3144 ; 4rMZB8nIk8UfgD69bNeJNq4aeJ6A1CrtxUcR89RG57Nffo2b8 ; 20171122 ; subDT >									
//	        < L50jTZkUFf9APO0u72G4U09O8jg17r9U1089j94737Iczc7K6K4F0u155ML9QZ6D >									
//	        < z70y66lCHYl8D7Gy7GpCk9tsArJQ4cbg9KkDRai9FLa9kbq1V2n4yR8nMkz3X3WA >									
//	        < u =="0.000000000000000001" ; [ 000031599965610.000000000000000000 ; 000031614069482.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC59B891BC6F3DE4 >									
//	    < PI_YU_ROMA ; Line_3145 ; k848rr77cVZaztQiTr1aFl6347m4l5m86D7k9I0M499Ie63cE ; 20171122 ; subDT >									
//	        < 7dyz0OWSdD6M6mCC8XC04x9acUb7bRKX7AD2tQIBMO1ZW9dkf50OO29wll22J4t5 >									
//	        < hZca98qc6kk00o747ZZ77AkxsaLM4W52N2IJY2904h7PM44y47x46qk0tIVPGRdg >									
//	        < u =="0.000000000000000001" ; [ 000031614069482.000000000000000000 ; 000031627429573.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC6F3DE4BC83A0AD >									
//	    < PI_YU_ROMA ; Line_3146 ; y03gLo4994105a4Xfgr31t20iwe1S1a3aTq22aWF6o10mJzJQ ; 20171122 ; subDT >									
//	        < qBT252oTKiqfpu3Lb9zwq1Bo0tVadKJOG1cu1UuTn54I64jN84750DmltomsNRG0 >									
//	        < WHbTEkdc923f9M1w8GthQ91qKsClcfQMnuUpAs709pG0aF6O7NVv0jP8uJlJ4y89 >									
//	        < u =="0.000000000000000001" ; [ 000031627429573.000000000000000000 ; 000031640055101.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC83A0ADBC96E486 >									
//	    < PI_YU_ROMA ; Line_3147 ; hde5PHPX255qHPI2Go1LMK01azmUBQO29l20LJ1FUn14p6g52 ; 20171122 ; subDT >									
//	        < M41s4S8G0n77rf8j2gA3D4cjXAV71k80523g03l3ewQm9h0ltnXdGe8EADhfc1u2 >									
//	        < w713T6TO2a30wJ16efkVT3dq40l2m3dH3HHX9495D38c3180TFbfpJm01kmEwM0N >									
//	        < u =="0.000000000000000001" ; [ 000031640055101.000000000000000000 ; 000031648150737.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC96E486BCA33EE1 >									
//	    < PI_YU_ROMA ; Line_3148 ; F4siTOr660tNwtOzDcA1Y7Fy0lqsW2UyVr6a4ePaM3Y4QSVDb ; 20171122 ; subDT >									
//	        < XUTQG9751TsOPnKC3O0p0q4mJC060dnSTpxWje7beYaspu5Z5k49CcJI0UEslR3r >									
//	        < 1zY343uNcha858t78EI3qa87mvSfVzdT1y94oqVJKeZA798E8Rs1DFEc1b1cfrMb >									
//	        < u =="0.000000000000000001" ; [ 000031648150737.000000000000000000 ; 000031662029843.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BCA33EE1BCB86C68 >									
//	    < PI_YU_ROMA ; Line_3149 ; CUxdqC678Ro92MBHdji32V99GAZwUNl4D0vKe3aZzd21ED7lS ; 20171122 ; subDT >									
//	        < I1Cj7lP3595L2AGkZeMkh8L887Ey775t5691hxNk40llZ08wKNf21h245Ll59rXY >									
//	        < z4S49mTqbunD0RSwq59E7LuR0vRa9uQVQOX69m8RLOKJE7FfaZ7vpISaB8V412ap >									
//	        < u =="0.000000000000000001" ; [ 000031662029843.000000000000000000 ; 000031668962614.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BCB86C68BCC30085 >									
//	    < PI_YU_ROMA ; Line_3150 ; 9Hi19y254rotwWDW5EYsLyi9YqDvk1dBTQ3iXb190nk6uWgxg ; 20171122 ; subDT >									
//	        < 3FcGH1npksku0842ad1PLf15dqst9q09lunJsrxm6q3IonHc89w4CShVjJsZ1bRn >									
//	        < ESHFBavHzMtOK4S63Xa71a4L8D7JC1b4a997bMV9n5f8CueVhgueq94Z6X9Z054n >									
//	        < u =="0.000000000000000001" ; [ 000031668962614.000000000000000000 ; 000031676797187.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BCC30085BCCEF4E6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3151 à 3160									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3151 ; 3ep72Qu8xF1k0TeXu1F283pafnVp19GFrGQi0f94zPCBtSK0D ; 20171122 ; subDT >									
//	        < mOwz159Wyf0toB706AZa9i4WqQ1Y2I0bLO3750dZ260aLys87I28M3MA2bFC31z5 >									
//	        < ywZP898823Yo3o5K4TcG9tdiVzKcw6jc9N66n6y99nCe18kiW8tPMFpJd3gOJqAe >									
//	        < u =="0.000000000000000001" ; [ 000031676797187.000000000000000000 ; 000031682930204.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BCCEF4E6BCD8509C >									
//	    < PI_YU_ROMA ; Line_3152 ; P37u13ZaqDm8c0B7v6XT4XeZ649ZSZaQbT99ECWj0z2J0H19N ; 20171122 ; subDT >									
//	        < 6f62JzHe1KiX05PL81KcZHsaaYAQ7Fa4rgk9r4oot4g6w8Eu2QXaRK9FwK24Pk0I >									
//	        < 365BiPiWjZ1vwZwh4pCBJpMzDCLf185gwCi8A1B8yGl6PDlp7MZRA2mHYsX7RqP1 >									
//	        < u =="0.000000000000000001" ; [ 000031682930204.000000000000000000 ; 000031688598442.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BCD8509CBCE0F6C4 >									
//	    < PI_YU_ROMA ; Line_3153 ; iWm7y1dp5xsbVj2VGb5eoKy0nLpkGllNHzmhxdu674cCx5C9r ; 20171122 ; subDT >									
//	        < srK86LY1ZRRKOFv2S043zQ08I11NdhU143wknsAt0468HjrPRVI517dpel8pS8Fp >									
//	        < 62AXLscC7K3D4cVT2C87LbIX7o4XS5pV96wuXoRfdpi6k4fjKY1Vxo5G8Z1LH80s >									
//	        < u =="0.000000000000000001" ; [ 000031688598442.000000000000000000 ; 000031701478038.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BCE0F6C4BCF49DDB >									
//	    < PI_YU_ROMA ; Line_3154 ; 4GEE66sgP410tmi4rd40v607BO41yUcwTV6ztq5ffxWXqUcUS ; 20171122 ; subDT >									
//	        < s1amQD48C8mn3p0kCHTnhTosJaYFn3aMEHTE7293Dee68By18yQ5O7QO66VrUKia >									
//	        < FlF9h01p82yGeryPLHmLZ11x6ss20mAmF28H40lgj8gywbQHizJZ6y8NDPhVO3Sh >									
//	        < u =="0.000000000000000001" ; [ 000031701478038.000000000000000000 ; 000031711688331.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BCF49DDBBD043241 >									
//	    < PI_YU_ROMA ; Line_3155 ; WhVNAj55WBTnlsZphl3dtY9i6z1m1SHrQX9Xlzuh9A5B90kGE ; 20171122 ; subDT >									
//	        < m712Z4UTqfIdB45xQ3LK243660yxu6pyznPMeor9hf218V6nWQ4MTMHFSI6vdWpn >									
//	        < R9u02BQqv0V5PYnMimSVqa8qbGRc9clr994fGdhrl36LqITc7G1IUi9UU97kFs2E >									
//	        < u =="0.000000000000000001" ; [ 000031711688331.000000000000000000 ; 000031726299849.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD043241BD1A7DE0 >									
//	    < PI_YU_ROMA ; Line_3156 ; 3Pg6rN7P3881J5j842SH0JxiPCktqCO1e45196Aaa88D1dPBf ; 20171122 ; subDT >									
//	        < e9JaCX4VXKan3tHgByUOoYKJTD9967ji2nTP7LG9tUX97JuS6EZw0J2ITCtqN6ak >									
//	        < a4W9t7Ea9xS299w2CNBe98FPI8O7p15U61TvZ7MKryki0jHgYdU32cs3FPshNheR >									
//	        < u =="0.000000000000000001" ; [ 000031726299849.000000000000000000 ; 000031738920381.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD1A7DE0BD2DBFC6 >									
//	    < PI_YU_ROMA ; Line_3157 ; 5qI5N99CPJ5r4ns7C9N1gH269q09tVE09uk34LbbgxsQgpg7N ; 20171122 ; subDT >									
//	        < 7QpDDY3A7yJqkcs2XPI2z8gzNelc7HM6hD2OOz2Wp288TxS0hL453x67V077PtBT >									
//	        < 11CoP0S3ru1v8676AAw51jYOV267rL5Mt9q0OQplPna4V0S29P8NVDcC1SEfV3oA >									
//	        < u =="0.000000000000000001" ; [ 000031738920381.000000000000000000 ; 000031753094339.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD2DBFC6BD436079 >									
//	    < PI_YU_ROMA ; Line_3158 ; fMtA7Cb61Bn37F3892Uau3EmUdq4JeV8n7QvO459jHM14rSl5 ; 20171122 ; subDT >									
//	        < b350u45fa4373Tm9u544OMzEOWd2v9Jdz8b5K8zZqo4x59NADzjbZl9R26slVaHj >									
//	        < OXyyTCcO0162GBUOXB91Ov04Iv2180HduEup5bySz17fP111cvT91p78LDi6486M >									
//	        < u =="0.000000000000000001" ; [ 000031753094339.000000000000000000 ; 000031763089138.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD436079BD52A0B1 >									
//	    < PI_YU_ROMA ; Line_3159 ; tazxZdV4QlauMI85LGCtUbYL4QcUx3J74aLsfid8J1vNF2r63 ; 20171122 ; subDT >									
//	        < 4h7UjEpHJk1Hz13b69KDKfU36YX7erqi68wq78rShv1WbRk5iRE7XiI21d0Hg5W1 >									
//	        < a1DQ0r75YbEp9oyPT44W66iJG8ejL65K3L534KA181cEdadGKwdzq8BiXBPzT1O1 >									
//	        < u =="0.000000000000000001" ; [ 000031763089138.000000000000000000 ; 000031776644460.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD52A0B1BD674FBE >									
//	    < PI_YU_ROMA ; Line_3160 ; 27L0j1xyQ380jv0iyl74r8qM8t5LlQbrP38YPejPKz8kllxZC ; 20171122 ; subDT >									
//	        < za84MC951vL5tLTY6eyFu3bI5549h9IZo6q23168d455FmDttNzO777RQ9e50KSy >									
//	        < ZBnA2eK1gL69h3g5wo5zlkMBJLhYvNAaY17g224426tauX290i0p4aXPruQe8KB1 >									
//	        < u =="0.000000000000000001" ; [ 000031776644460.000000000000000000 ; 000031786781275.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD674FBEBD76C76F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3161 à 3170									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3161 ; P1b6e3PmYL5xEO96oT5y0SMb5zUga4K4vpNMByC2se22TNOf7 ; 20171122 ; subDT >									
//	        < dR59ZifLWxYWr3VaejTP8dj6MtI3zMY7v9Tw4xN9wSe5Lp8duG1V6RTfT3UKwDBc >									
//	        < xug1IXkr8Dj9p24o9eEFbRlxh7WyEXcCGKa3Wyl9u3R0GZGEzpqos7NzK2CY15b0 >									
//	        < u =="0.000000000000000001" ; [ 000031786781275.000000000000000000 ; 000031797491593.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD76C76FBD871F27 >									
//	    < PI_YU_ROMA ; Line_3162 ; J7n4BXHbF2BTvs7897Lm0nDgSZh7f8r3em0zrK65566V2pB37 ; 20171122 ; subDT >									
//	        < KZur6euN8nL11151b309opzy1C9oQL42N9iEP2AKox9CYd69L6lh6LhuO9oK8NKJ >									
//	        < jJbU813E84QF2V3y279MXoSD3esaIX0E5U1HH47IxS1cHJO6pskCCh5N4VQDB8Z2 >									
//	        < u =="0.000000000000000001" ; [ 000031797491593.000000000000000000 ; 000031802549901.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD871F27BD8ED70E >									
//	    < PI_YU_ROMA ; Line_3163 ; 72P47AtrH85RIv0UdtPSEtnd7QBe68vHYcKsFdMUC7PnFxD59 ; 20171122 ; subDT >									
//	        < 9m1ireP2grCrt69FFhi0LB86RJ4XqjZqk45RY602376Ry5IyyQ2THI9pq899OF4q >									
//	        < 7Y656AOq8sE6t91tPOttSbzx9v95a089zUJAASXk7nn305D96hyYqkTGPGf8373L >									
//	        < u =="0.000000000000000001" ; [ 000031802549901.000000000000000000 ; 000031808594653.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD8ED70EBD981049 >									
//	    < PI_YU_ROMA ; Line_3164 ; aNhpcthnYDSlE7663Z10DwKOl2bQD1OTj2f0WtQ65R6so3lom ; 20171122 ; subDT >									
//	        < rosf9oPY9nak6V99JtPCkMTtnWfaik1gUo2uwUGlAbFcYWRsXM26Km822OU46mhd >									
//	        < pLdV37ExQBSZ6qR2GbJPgn2T43Cp0JktD292F89dtLmOUY7lG53UDa04Ib82WNdQ >									
//	        < u =="0.000000000000000001" ; [ 000031808594653.000000000000000000 ; 000031818835342.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD981049BDA7B08E >									
//	    < PI_YU_ROMA ; Line_3165 ; 3F4M8wRyYWZU67OsKrJz2SBu59WT9M48r0FYUh35T2XQl80u0 ; 20171122 ; subDT >									
//	        < 5C08KZJqJ9Rkz4PRu6wP20c78stAi1ekY91QM0h7OugE0969sokNJR7RS4tzks0T >									
//	        < 4PF08R1TPyB4Y35OzvCwCzjbIfhJT73kJx4f4084TD1x1lRMDt6KOuSp2XXK73o7 >									
//	        < u =="0.000000000000000001" ; [ 000031818835342.000000000000000000 ; 000031831227830.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BDA7B08EBDBA995F >									
//	    < PI_YU_ROMA ; Line_3166 ; Hh48BIFbOb2JR2OjqrT19tp0EihgDnFreyuaz7x4IE5VfJ7E8 ; 20171122 ; subDT >									
//	        < 445Dt6Q7D9Yl1M5BHgAF7745K1plw63GF9o4O1Qx1e2v39rVD80OjiVh4W7Bc36I >									
//	        < 534H87OaG52mB5s30Ww0TzD9akGfOsMvc6S3262k107cIm8bzUIv7Zwb8H69u0L4 >									
//	        < u =="0.000000000000000001" ; [ 000031831227830.000000000000000000 ; 000031842174894.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BDBA995FBDCB4D91 >									
//	    < PI_YU_ROMA ; Line_3167 ; tGo1E8Oj2012H88XV6aH0e65xY9b1ARTVNr40PcnvqHaNECgg ; 20171122 ; subDT >									
//	        < x2coxUlt6eEi7yGNYa0yJZBzem6778pDIiTdcuNx2L10US9a4Xw498hqD9U3a10w >									
//	        < CxV8N518DrKY9zp6a4ASmLF41SuG49sRzSA6ieGVD0jUspbExt9I1CIaQQhJF2VJ >									
//	        < u =="0.000000000000000001" ; [ 000031842174894.000000000000000000 ; 000031850362002.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BDCB4D91BDD7CBA8 >									
//	    < PI_YU_ROMA ; Line_3168 ; qAEa9483u62Kg0nQ4t9879llG6daKInMXA65xT5aR52J0N52G ; 20171122 ; subDT >									
//	        < 3ARQ7W6vW3kTH8AFtcdFdR74KOa4VRMjY28Ier345jrcAEP66W2B6YRNWyI79l6w >									
//	        < M0qruGSza1p9F3H2PgQo1on1uFug89I2br8DlUmnNxoOOyR18eu0iMeAixMqAy3I >									
//	        < u =="0.000000000000000001" ; [ 000031850362002.000000000000000000 ; 000031863641903.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BDD7CBA8BDEC0F1E >									
//	    < PI_YU_ROMA ; Line_3169 ; xHspZwqPM2N9A9KvMDU8216CAOJoLLcslFPnme94u0vwwuFNB ; 20171122 ; subDT >									
//	        < 5jO7j3oBKzmhdn1UW39NS9k6gE2NSg6M5596f3h4QaKWFj74G0rOjo36HWm61G3O >									
//	        < olGllc9uDCAE8Gl3M971LIZP12fCdOdag8327YPUpMXcTrfcI55jb6ky942hKqtG >									
//	        < u =="0.000000000000000001" ; [ 000031863641903.000000000000000000 ; 000031872089726.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BDEC0F1EBDF8F30C >									
//	    < PI_YU_ROMA ; Line_3170 ; TSId5T9bW29KQjtq0R13yk60iE5q6i55ePVS5BMK4LtTMbu8D ; 20171122 ; subDT >									
//	        < 11UHU8hZW376ikXtdc8xSuqV7UwoZE0y4lBne1P9u3vE2ifOiwu8xfR4l9ZgdbX2 >									
//	        < pBqHEMHsZIxfX2xeq95Egxflj5x5nZ55k7sLDi443M81n38F7f049Xh1p89Q8gkf >									
//	        < u =="0.000000000000000001" ; [ 000031872089726.000000000000000000 ; 000031878778509.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BDF8F30CBE0327DA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3171 à 3180									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3171 ; 9lq1595W2JL6h5dwsh3QgsuJT47qP9r7v2PlY7AGz335uF545 ; 20171122 ; subDT >									
//	        < K5a2jeL0Aj96uX0N7T4fkd2t25k3H910ym55xVgkVuTgOVrIF3T8FanS542135m5 >									
//	        < ulUjxE3xIbj6yAH524OeWAJhc3e3na7I9RTotg1ADs343JWeA5Xdhww8N9fLy6Xs >									
//	        < u =="0.000000000000000001" ; [ 000031878778509.000000000000000000 ; 000031888238219.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE0327DABE11970D >									
//	    < PI_YU_ROMA ; Line_3172 ; 3u07utu5891gwOg98KpULJBku22Q4CyZ9K186h22NdnvhrU71 ; 20171122 ; subDT >									
//	        < c7A3n4bRIe6TMsh2ofw5QZIRnTKII8911q72gk4p0MbF6At8g1d500loq5836Oku >									
//	        < TU4EV923I6PRe9t7R9131hJrJZk97NMBm13kh5gjX7y7xwYyyIhl794qe9qhrEAy >									
//	        < u =="0.000000000000000001" ; [ 000031888238219.000000000000000000 ; 000031897455017.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE11970DBE1FA75D >									
//	    < PI_YU_ROMA ; Line_3173 ; ct5Kc5X1GKp78Ss72Rw776ia19GspFlb5vcY0SYMG15Om4DMu ; 20171122 ; subDT >									
//	        < hbS3N585J252I5bXe80XoyB7FE6Ye787JU9ri286lqlC2H5SAcIq3gFjdFXCydEE >									
//	        < QPNW538BC05p7L5rL30X7rn06qOMeWT2kgVJ46s7VEEI913tZc0tk7e5LA47fEA5 >									
//	        < u =="0.000000000000000001" ; [ 000031897455017.000000000000000000 ; 000031905509848.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE1FA75DBE2BF1C8 >									
//	    < PI_YU_ROMA ; Line_3174 ; u6orb25ksr62sD2Qo5Sz54Tcyow46pJ224o2T36HbFkw6q5Ql ; 20171122 ; subDT >									
//	        < 829hu4g1Pe88147D349N1MpmEwMG71r11B8V0sp9oW6r3y008WW4iMu0U189J9d6 >									
//	        < O1VtM7U8dE164gFM0FzZJ115h6rHZf2lf7F00sX3a6Om1G1O0N5e60e7YDVH54Az >									
//	        < u =="0.000000000000000001" ; [ 000031905509848.000000000000000000 ; 000031912350959.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE2BF1C8BE366217 >									
//	    < PI_YU_ROMA ; Line_3175 ; 4gt9cn03085J1hWV0H53l9u3l8A5I37621aIMAUb3u8rh7fL5 ; 20171122 ; subDT >									
//	        < QDChoP6H0gCR8e52H64eJ0L2EQe4bmc265YbV1z9xw6zCar9u139szmjz5lVvpR6 >									
//	        < y9979jLWEhG191Lbf1D9NgSf12IO767BqO6vD9VuE07ePxQ861p8V5BpJ1RdvqSW >									
//	        < u =="0.000000000000000001" ; [ 000031912350959.000000000000000000 ; 000031923395740.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE366217BE473C76 >									
//	    < PI_YU_ROMA ; Line_3176 ; be2GEj94AaejOI62Je82Z2pUqGYM9JL8CDFNk4om93mX7z74j ; 20171122 ; subDT >									
//	        < r65g8I8QFi6C7Rbi5uIzRxURdo46eUwnUovh4VxH8r8Twt5YFBdnZ09Q69ayXn7a >									
//	        < N24Z1N937cDq9113P3p74SEwJ3gzcmKNtO2sLa72v16ZehWo1vL7QiPOBcZ63U8T >									
//	        < u =="0.000000000000000001" ; [ 000031923395740.000000000000000000 ; 000031937388522.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE473C76BE5C9664 >									
//	    < PI_YU_ROMA ; Line_3177 ; K60TULx334f46Qo8joh9FlQ260Tk58W95hNZ9j1XquYe10R54 ; 20171122 ; subDT >									
//	        < M3261Ce3mytRI3wxxl7ZF6QXssPdaX3r2LdvB9j5G0xk30L85oE54f90545zOSkS >									
//	        < a4k2388UJ0yf7728Kt2zZ09272erBruEcOnwiMb0x1JcCjSM3FMR487orjsUn1Mw >									
//	        < u =="0.000000000000000001" ; [ 000031937388522.000000000000000000 ; 000031952238343.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE5C9664BE733F1A >									
//	    < PI_YU_ROMA ; Line_3178 ; PoWGa0oUxh4vsv40lyYoT4vfK38D10Zdw28tAsu4URLcZO4JH ; 20171122 ; subDT >									
//	        < ZC087hUj0U3A8cMzAQ530P578GkGS32xQJ6f53FyQ26qR0wiDyI52w9WFID9A8N5 >									
//	        < fQwa986P178hjd4262Z2VC60fy8sMU44O1rmoxNL450C9i5Q9LpA61N4ioI9Spb9 >									
//	        < u =="0.000000000000000001" ; [ 000031952238343.000000000000000000 ; 000031963955122.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE733F1ABE851FF8 >									
//	    < PI_YU_ROMA ; Line_3179 ; q0X8DuNuwbwk5OPD0E7l89E37f2x34NpgHj9z22Fp19i14iAa ; 20171122 ; subDT >									
//	        < 34i382WOGkJ7Q4X9YHYxnAhPW7KP73yX4Sk91YFne9J46I8UMZvPP8LmDaFAk5dU >									
//	        < 1lTlaOKeznj7IAc212YNmsRHEa9PpVtUx8nL86uU827ZFI8XnYuaZSZ75Xi39Z96 >									
//	        < u =="0.000000000000000001" ; [ 000031963955122.000000000000000000 ; 000031977598658.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE851FF8BE99F179 >									
//	    < PI_YU_ROMA ; Line_3180 ; 9UTqv8fk0XUu1NiJMPAv0Er9qwsdK5gHSCNVGDjLeYPVR29F1 ; 20171122 ; subDT >									
//	        < 1t53vrs71o3y34ZblQh8GjRQ7QNQz312dLHsJrB87RDUo8X2dBLIh81eO9LlR6Kv >									
//	        < xKLO67cBxirqWTu45bHYDbm28lf19zK691Hpl5h4hu9L2w4lm1JW24978hT1KXJY >									
//	        < u =="0.000000000000000001" ; [ 000031977598658.000000000000000000 ; 000031987195488.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE99F179BEA8963C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3181 à 3190									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3181 ; 7U7qOI9qnzT5Qb0FajY8jIVi0XoloGMFdf7p3nW4vmF7S8gA3 ; 20171122 ; subDT >									
//	        < V2V4jpF5h50Z80d0J22S4oLG29T4Z10gj9EvRhdCDgY54pJ00qfZ3Ef4t04Q0R0N >									
//	        < Ol4uT850k6mhN3OTbK6Kk8uL3VaRC7QN8FQqqDCUId0ougbquq9hT3VZD19gX41M >									
//	        < u =="0.000000000000000001" ; [ 000031987195488.000000000000000000 ; 000031994495409.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BEA8963CBEB3B9C4 >									
//	    < PI_YU_ROMA ; Line_3182 ; 29907k5gjIphxKoba75A1rNNK4d29neopOPM3b1Qn1N3T52Ax ; 20171122 ; subDT >									
//	        < 86oJeema04plPW5p1r3QXv5PHd26GGRkjkSM2X08tZzpy32B1CH3J37zv617Y6cY >									
//	        < rJ9VcnsTPp5Ou5oXUTtEYpBIy4vRZIx3n7E3WzAg34ocIBp9HXJ9oC4I3vbH2nxg >									
//	        < u =="0.000000000000000001" ; [ 000031994495409.000000000000000000 ; 000032003396850.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BEB3B9C4BEC14EE5 >									
//	    < PI_YU_ROMA ; Line_3183 ; ubceIfUUG16Z07Ec58lJ0dmp4QwGC2u409579g40qWR6sy35U ; 20171122 ; subDT >									
//	        < SzG0yv299g9SOYE225nW0K2397p4JknOp6m4YGNgpsF1rF09oIxEfB02v4hIMN69 >									
//	        < BJHCBY8YBz06T066xmazZG2T25ZDc8AqT4cE0XRGj3ai3xw5h768rzQw84EZSke1 >									
//	        < u =="0.000000000000000001" ; [ 000032003396850.000000000000000000 ; 000032009954029.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BEC14EE5BECB504A >									
//	    < PI_YU_ROMA ; Line_3184 ; WM17z72n9ZC7C6LS5h8ty6t1SiIn903ojiLl8dj5UZJ4oI134 ; 20171122 ; subDT >									
//	        < 3vqr8Kusv5t894ju8qQcVth6RKSnYAxKSKr701Ziqrqeh9lIM0u07Fr2BwwxyliI >									
//	        < zjRStTZ2f4qY82XuevxR6HAK0P63SZSc98lFr6C19we2ks49E5UuVRfWn1829hww >									
//	        < u =="0.000000000000000001" ; [ 000032009954029.000000000000000000 ; 000032023077112.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BECB504ABEDF567F >									
//	    < PI_YU_ROMA ; Line_3185 ; oqHrbnA0VbDTySZ3m5qBbneRXJ5rq5s46Ry1873h25FTxbae9 ; 20171122 ; subDT >									
//	        < vcTihQz6ZsH6n5W71wI4G95Sryl5Bq3t6c95NKxHa74kl6N020VTqa0mtzm5IxJQ >									
//	        < 5gXPcPxUf2l46xwFq8tiGlpb17cODLuz1O4WFY7OVjC41IP3Qy9q709JTH3k0zRo >									
//	        < u =="0.000000000000000001" ; [ 000032023077112.000000000000000000 ; 000032037808617.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BEDF567FBEF5D0FD >									
//	    < PI_YU_ROMA ; Line_3186 ; fdGwuAC0cnuDoIvXWS7o3X8jeS7Ri9Zsz38R2o4KiZ299yAgk ; 20171122 ; subDT >									
//	        < 1C4aQ06S3OGz4Nl5ZOENSh8O93Jcg0Rk4o404FS6gOlqwJbAsQ19fufK885xO74Z >									
//	        < brrPgdk2XoxXt6o55igpU6dxxM2Smalb3suv3x001y1PHV8LC0wHf0n0jm5O6EeL >									
//	        < u =="0.000000000000000001" ; [ 000032037808617.000000000000000000 ; 000032042823909.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BEF5D0FDBEFD7816 >									
//	    < PI_YU_ROMA ; Line_3187 ; 03I1ED4g2C3HYBw1TH6n035mYHTJofnv150fE17kwmymi319Z ; 20171122 ; subDT >									
//	        < Ig695Bc5C5f3tlY3uVG604fl6YAl9K4koq3Qi44520it7ICu77uzX1Rz6ACg9FjD >									
//	        < aEd0pv4NsxSTqRTI2zYpGR94XR0weu4vf13YT3md7z4E9D1wsVF4XJ97e4g15F2v >									
//	        < u =="0.000000000000000001" ; [ 000032042823909.000000000000000000 ; 000032049977884.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BEFD7816BF08629C >									
//	    < PI_YU_ROMA ; Line_3188 ; otbONCA790Ygneu9KE3fDcmQDXiRptos29K4i7vYIW81852P9 ; 20171122 ; subDT >									
//	        < vl7tG27YMJ3jPjuVf86LHqJOJx5o26cBWkf13kJz5nzOu6Z1Zqt8Y9l8A36Zgr66 >									
//	        < jq6ea10sLxz0v2CRF4b9GSEeU4X6v8dDk7bAC7zN4w6537FrGxl7O96GhH1wTck9 >									
//	        < u =="0.000000000000000001" ; [ 000032049977884.000000000000000000 ; 000032055704441.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF08629CBF111F8C >									
//	    < PI_YU_ROMA ; Line_3189 ; 47iY50ywva89wt9S9vyIT88eUq8g4DR4X9KcC2qzv5W6bCahi ; 20171122 ; subDT >									
//	        < Y5W94YvKhcx0rkXB32FnER19hO8gW9ka00Z1q7TUUK0BQyM3Y0RJj535GtQdyQF5 >									
//	        < l304O2Bp1vjpaUTfCW746Xe49G24vZB0MwHeo7sNSSLH42ea9PQRp1N07B2i7qUQ >									
//	        < u =="0.000000000000000001" ; [ 000032055704441.000000000000000000 ; 000032065385309.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF111F8CBF1FE522 >									
//	    < PI_YU_ROMA ; Line_3190 ; 6rakD17D1zgEJfAXM127sB5QXI2C4dbAt01if6NU81G2Nw9Uk ; 20171122 ; subDT >									
//	        < iGFOAtTEaR3wWKVUJk30Gp6tb77yF2I1969Jw2nxtIjuks520jc6999Zr51tX186 >									
//	        < 6z1ZHVEhHnnf483UcmTNy32RPJ0C29W2D5NxDoM9QAC4uCD5ROKEgm52bsw3tT2b >									
//	        < u =="0.000000000000000001" ; [ 000032065385309.000000000000000000 ; 000032070407460.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF1FE522BF278EEA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3191 à 3200									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3191 ; KKZ4izLMJuMkBjXUg8V2KTu52f16kM4pObTSZHd87MLGIc7kQ ; 20171122 ; subDT >									
//	        < 17mY5dvhV4n6C0dGbsxs6PpUYJxp9pq73v2eQjlQRM0B7ztuc25fSVx3ae1EF30e >									
//	        < ugDwJq0z3kj99o9i0SwxFSZKjZ06wiXNumU26l0W6Hz38x4nLdTyKvAd9ora2Kx9 >									
//	        < u =="0.000000000000000001" ; [ 000032070407460.000000000000000000 ; 000032079060333.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF278EEABF34C2F1 >									
//	    < PI_YU_ROMA ; Line_3192 ; YyulABEzvV9zw1cKNx9dUY59BEes10yF74Rh9XdcGtP92H3TG ; 20171122 ; subDT >									
//	        < 1rB1SW9yNG0Kb0fWY04PT8dFb688hXDW95F3l3u7cgz24808g465rkZqnmjbD922 >									
//	        < 6nv2EovXWMXp2g7xvC9nh1Ohv73YBB0e8ixy3l1T5VL69R3m4bCZzqNxG237qx2n >									
//	        < u =="0.000000000000000001" ; [ 000032079060333.000000000000000000 ; 000032086365870.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF34C2F1BF3FE8AB >									
//	    < PI_YU_ROMA ; Line_3193 ; E8BFmI1e0fPXgyo8T790t8fBK03Oa4jfvp1388LI1i8arG81N ; 20171122 ; subDT >									
//	        < ZITSFx101Ub500P904NgVtwW6tR25CkWx09khkN14v2LY0AC8C9yDc9QMObZ2xm7 >									
//	        < 6fJ9zZ7nA8YqZoClEK9nke2ujY26GqipY3Yi053ltL3SQ4VSF301p90Dt5s2EzOJ >									
//	        < u =="0.000000000000000001" ; [ 000032086365870.000000000000000000 ; 000032094257994.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF3FE8ABBF4BF387 >									
//	    < PI_YU_ROMA ; Line_3194 ; q63TF53rIMm1zVYxUWKvXe76Obn4a1Dlbw08Qi25c1oTYOxa7 ; 20171122 ; subDT >									
//	        < wlI45nmk60nETffqGC43R33c0e2cPP6ax165ILVzt5I1MeI4O704rzKtt4c5EtC7 >									
//	        < wF1Yi2UYTdeF0HMuLbNepem8X2074q3XKTK0cuas2yq8GC9o11Bk0AYRaENa71kf >									
//	        < u =="0.000000000000000001" ; [ 000032094257994.000000000000000000 ; 000032106505610.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF4BF387BF5EA3C1 >									
//	    < PI_YU_ROMA ; Line_3195 ; 64tujsg7vvn4oh7P823cLVQ841tg13sGoP2Ro1J2SQhfgEX0P ; 20171122 ; subDT >									
//	        < AyEO75KCnNE5ir9Qhi0tG17hl8zb4h89POEH8942Gjev0KcIupUFp62xL2V7bcDc >									
//	        < kWV48HhTyDdH1Qy2TSaI7ssn67kf32y3lWeG306qZ5BK8Z4nPCR3XJa9s80Sb603 >									
//	        < u =="0.000000000000000001" ; [ 000032106505610.000000000000000000 ; 000032113158103.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF5EA3C1BF68CA62 >									
//	    < PI_YU_ROMA ; Line_3196 ; BJT6SLV4EPA2j75trM6PGH54S151XlZDJ6V3c6Z9RxEze0vfm ; 20171122 ; subDT >									
//	        < bh9iGRdgyHtS8UzVwL7hybqLDdvlZ6xJaxlWGF7j85n57ktfOjEjCow9Elbm1H8r >									
//	        < Otmu2ErhlpuKxbuxVE6K9sEf3O1IQ5wcFwk0oY7vfbGsdV7zPk4nENGdyryuw8E9 >									
//	        < u =="0.000000000000000001" ; [ 000032113158103.000000000000000000 ; 000032119475765.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF68CA62BF726E38 >									
//	    < PI_YU_ROMA ; Line_3197 ; C7SH1mXQpa1KIdDY4v8NRn6Dp4xs3aP4A463V9j9qMaRx9Hng ; 20171122 ; subDT >									
//	        < 7K749s37b93Pjv395RIcpgdUB94mMF70wRB8umbkMPZC78DsPI42Tz506p6m0H38 >									
//	        < Kl79i9u5gai5170S8MJ1F500tmKb1F416Aw5u9wQlbE2cit9494TE4cdB89y62ks >									
//	        < u =="0.000000000000000001" ; [ 000032119475765.000000000000000000 ; 000032134246617.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF726E38BF88F815 >									
//	    < PI_YU_ROMA ; Line_3198 ; S9v8zI8q3F2qI337n3dPp450ta4u4KAgLoZ2U7kNBIK2W8XwK ; 20171122 ; subDT >									
//	        < q40i41Rd6750pQKU951cYK4FMH62RvTup35Dbb765tRcPhg0P61lm7yQhje9Zz58 >									
//	        < 9ExVY6749f7655CA1jvSje4l02b1Q0FsI61pX0xNK7QHdi44KXfGRx162GExM5mM >									
//	        < u =="0.000000000000000001" ; [ 000032134246617.000000000000000000 ; 000032149072219.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF88F815BF9F9755 >									
//	    < PI_YU_ROMA ; Line_3199 ; a6yJHgf35LUo8nYeH3e5Fsox3hmNpv54RT241WOZ58K8GXhl5 ; 20171122 ; subDT >									
//	        < 20ro8nXXOoS4v86U4rWHiQ2roTI9uYt8FDMv0t0oQalp72D3i455Jk961sZb38bS >									
//	        < kd2ia3e3dkp6WBotP9nZ051Ec8WaHeKhOo3xgHr0S5E78LBf00oXE91xTo15Sc65 >									
//	        < u =="0.000000000000000001" ; [ 000032149072219.000000000000000000 ; 000032156388550.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF9F9755BFAAC147 >									
//	    < PI_YU_ROMA ; Line_3200 ; Yg2qWP0GQRw2o01na1PlQ31s5Dv408y811U3dPFEC8H3L45Sf ; 20171122 ; subDT >									
//	        < D4hX1GNzl07xFiQzknCA4MrPkBtF0Dz5zU70pZG573f2t49qYTVWJNcNF60FOhVf >									
//	        < 5lCxnP79Fg1nd86R2RA5Ls4hm5myJu9rp1XaYMr32ak08dRgvd5789B3gue0qgIF >									
//	        < u =="0.000000000000000001" ; [ 000032156388550.000000000000000000 ; 000032171028054.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BFAAC147BFC117D5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3201 à 3210									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3201 ; n8sxhtmfY6N2PQEl6dY242pj1Iz110jCYxMGu3HaNXQ54M35S ; 20171122 ; subDT >									
//	        < wMs89H8yYd33E3RHfio7nz4aBYz78cn2Dpt3mk9knb96x2IS8Q7L6kUCdu228lul >									
//	        < 4c05uwpujhgY0z4sLQ7b83Yd1IQK6O02LdgE5AeE05k4s7ChljzDPQ39ZNXxNJpM >									
//	        < u =="0.000000000000000001" ; [ 000032171028054.000000000000000000 ; 000032182487391.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BFC117D5BFD29423 >									
//	    < PI_YU_ROMA ; Line_3202 ; 1aDWStLNLd9P502iZuQ2y0cu1Xy1hC2tICPbrjGu9X36OfdCM ; 20171122 ; subDT >									
//	        < Wz31VSR115p4WzU5HGPmgy4Dv068w29Ha4Hu07Se2oCeRWfCx47wi51s7p7DM4gk >									
//	        < 0izf8mnO2rvz24LZkAbgJ0ElGH6h86Fn3XwI5KIyy6YHdC13pLkgvjxEdBMVbjtL >									
//	        < u =="0.000000000000000001" ; [ 000032182487391.000000000000000000 ; 000032191856231.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BFD29423BFE0DFD7 >									
//	    < PI_YU_ROMA ; Line_3203 ; z8Zkc7310bO7av0O6SR8h7ufMaDezx4xZX6Z7Vdc0ieQm382l ; 20171122 ; subDT >									
//	        < 5yUCrB5261i61ASG86113uW2be0C0EzYgPSLIXW83lrI37nCdJnL754Vc55u5Cd2 >									
//	        < P57dKSCdekpEzPHSc4Y1e8ds89I6vd4AxFVQI3Vr48964aSB095R7zffd7N7mVZr >									
//	        < u =="0.000000000000000001" ; [ 000032191856231.000000000000000000 ; 000032205480059.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BFE0DFD7BFF5A9A5 >									
//	    < PI_YU_ROMA ; Line_3204 ; 48PXRAvNCMcFx4gjK9U5UyA7FN8ZpY150RNO4r64V0cgeTo0s ; 20171122 ; subDT >									
//	        < 64oOUt67el61LTV2sI27WaZqUoWKteOvv46c5e5Xm3eUEsnHBVzOm9w56CUe943f >									
//	        < Ms4PIG446B5OHPNSO3WK9KvCOw1UhPUH1445FU5wRt37pl6S2Sbarlo9Jomb5on3 >									
//	        < u =="0.000000000000000001" ; [ 000032205480059.000000000000000000 ; 000032213832265.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BFF5A9A5C002683A >									
//	    < PI_YU_ROMA ; Line_3205 ; N27bo0fO4AS10mwjSM4Hmor5JIggTP07u2NyrYkv44Dzevz9n ; 20171122 ; subDT >									
//	        < T2j3qME829pohY48tgA9fuTnAn509r4lqTcA0q8g0exqsF8fU8D2e0CurEuTEcNT >									
//	        < K4onmR0345R2mSmnM4w8cbm3nqAO48tN018YAlxix83Y38VQnzVn3epMH2twLEAf >									
//	        < u =="0.000000000000000001" ; [ 000032213832265.000000000000000000 ; 000032227574940.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C002683AC0176076 >									
//	    < PI_YU_ROMA ; Line_3206 ; 89Rp2LHck5F0Cc7p0i707th3G7I7uyF6o7K9uI97x3VarNYfE ; 20171122 ; subDT >									
//	        < 0Jk9S52nKa59k0unn3G2hfL9vl7i5vWSfem800EQy0yAY1szXDWLCZSDtXQ6Hpgr >									
//	        < W9RAs2W5sOd9Y8xHBJ3eu6FH2brZd151RZ6YM1gn2hQNSS6z8GL84yguUUq86l1Y >									
//	        < u =="0.000000000000000001" ; [ 000032227574940.000000000000000000 ; 000032240682747.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0176076C02B60B2 >									
//	    < PI_YU_ROMA ; Line_3207 ; b6867PEm6Wd4X6E748Mk2068f3ZeRUa1em1T6o4uI18E87kCr ; 20171122 ; subDT >									
//	        < 5Pj26pF9Z5Pb6saI6eh3SjRxH2mktk7BX6coNTS1STN7x8jvCsXe9l4a61q1dBS2 >									
//	        < vkIywb199l3DvKFm9r7m0ljvgHFk5RXvBVxIO5ouDs6y7t8n82B9m53kOhLG9WW6 >									
//	        < u =="0.000000000000000001" ; [ 000032240682747.000000000000000000 ; 000032245701719.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C02B60B2C033093B >									
//	    < PI_YU_ROMA ; Line_3208 ; Ihne5UdiJK2p5395a3CD8n865Pr12GQrZFPtLO58YJTzBvEG0 ; 20171122 ; subDT >									
//	        < 4cL9tSk85m9Nng833y0WcVqOkQkm43Nlnw9A0g9vBVJB0yCwLq2tnS0o9kBVIuLh >									
//	        < 7U60Db4s6d9VgnrMN12uYhwEVr8Nu4L15Q6ieWzpf859wJkf15d4ZJZVWyLsQWgS >									
//	        < u =="0.000000000000000001" ; [ 000032245701719.000000000000000000 ; 000032251590077.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C033093BC03C055F >									
//	    < PI_YU_ROMA ; Line_3209 ; x6pHc48nPE3fQD898VzsF2v23t79s8PeV048h3la0h047BtGJ ; 20171122 ; subDT >									
//	        < 4q0lV1MwLLXE31XFXW4dj8hA734U4k7m0NrH91693wk1vRh7DoI2S8t8yK06rd5C >									
//	        < 8ZkP7X90cPlDGFh5l4cFriDlSUs0Ng7P1W2p0HfBg4quFIjjNt69yGHzMAnXM7Ie >									
//	        < u =="0.000000000000000001" ; [ 000032251590077.000000000000000000 ; 000032266285809.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C03C055FC05271E4 >									
//	    < PI_YU_ROMA ; Line_3210 ; HEQwH8dFaFT2540LBxBUD69bkWNz9XMncknyR2Xsrz4NHr39v ; 20171122 ; subDT >									
//	        < p0r5Jl3X83Qjbzo0y29DlrK22k9v9fWA7FqZiPE3vvOy1VB6R4nYlP8OK6438B0h >									
//	        < 8xL2OW0w959O0c8kVRgf56vv8fJd3vc9pJYy1CcGeEqW9gT8223yP5WEK9KxBz5M >									
//	        < u =="0.000000000000000001" ; [ 000032266285809.000000000000000000 ; 000032275645339.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C05271E4C060B9F5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3211 à 3220									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3211 ; ySxtB9czW83i8s80ZGTD1UwIoAJOLgQMnKlg5Pz79h26Dw9W4 ; 20171122 ; subDT >									
//	        < 06aj1rA103tRH57MifmRG8Z4ImyWH0Wx5y8521FSOS87P1VlnDT4bjqB9FGu24oS >									
//	        < VPm8BE0o8zW8mgaJbuqokOrNXRaasgJ9XjhjdVQiY1YCe4VWlt8347ofYz94Z7vu >									
//	        < u =="0.000000000000000001" ; [ 000032275645339.000000000000000000 ; 000032283484272.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C060B9F5C06CB00B >									
//	    < PI_YU_ROMA ; Line_3212 ; 8Eyy8ss6BYRh2t4jC72u5kM3y4R81F5m7C4Frqv33388B93ZH ; 20171122 ; subDT >									
//	        < YseS3x0h3OvT40B52LS78Lyg30mE3R5r0maq7fyh4zSP9FQ3Xr93gIfT48n56gK3 >									
//	        < k7sr3uhCK4tT3K110abt6TYhFCY6Cz6jcuf6D4ZE80S53ac3fduUX4I2p58Vjbzq >									
//	        < u =="0.000000000000000001" ; [ 000032283484272.000000000000000000 ; 000032294066646.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C06CB00BC07CD5C8 >									
//	    < PI_YU_ROMA ; Line_3213 ; 3Lf8Wpq6RHi1EIj6D6z4NEhjdGa2rdX4KtSne83f875bjOvYx ; 20171122 ; subDT >									
//	        < y1fj7J5L0GIggys4X3TB9LFN25x0A81mbwAJdCSf70hT987Ih88MaPc3e3S5c2IM >									
//	        < N5628465zZQ6rGk8G2M4h7OQNojRRd8I7k7QhHI0gpyQjZTJEh6R59ttjGk3izMw >									
//	        < u =="0.000000000000000001" ; [ 000032294066646.000000000000000000 ; 000032308822865.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C07CD5C8C09359EE >									
//	    < PI_YU_ROMA ; Line_3214 ; FfyBav1dc0sKy22887gRt0hY4TkpviUWDttlcsLcfs9mcUCIc ; 20171122 ; subDT >									
//	        < XfkXqWVE90fheC14cHZUQ96u9MmY28r7F9zAJ49FFdm68VTGdU7OTF9rhBYc1n9y >									
//	        < OUZyps5ucUS36A63219px8G84R5v2hOm30WiCx89Li2ry68vhkLkYAnP4ByjSnkk >									
//	        < u =="0.000000000000000001" ; [ 000032308822865.000000000000000000 ; 000032318807319.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C09359EEC0A2961B >									
//	    < PI_YU_ROMA ; Line_3215 ; OM5Q7cBUrE6KQ6KOn20a707v5VKA2Yde5Z1Vv8FN7LKS2wnMP ; 20171122 ; subDT >									
//	        < cjLa741U9r87P144gUH1f5wmDm40jtxmF5QeSa9f4L71z9j4D1X04u4yZZV4Q25l >									
//	        < kPcrdAwzTgUgRKkgZL8D42V6t9rfknLM6Jo7hRx56WTZn2UZ43oGXW34g96L5Lw8 >									
//	        < u =="0.000000000000000001" ; [ 000032318807319.000000000000000000 ; 000032331190435.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0A2961BC0B57B43 >									
//	    < PI_YU_ROMA ; Line_3216 ; Vho75Us0lr5b2e6Fntg6Uz1yK1It2i4iDa6w72k0c59W2oqyh ; 20171122 ; subDT >									
//	        < HFtc4SH6MZFB7Ko1ELvpI1S3qn9rOdR9JbRP3X61iP0TBQ91tFRnsHgolh2J27CA >									
//	        < qrfKWXysxcBf2j8Mdp2LKr8KKAts1V4y4D1iZ374ypB2dpC1EGT442gR9t3897vn >									
//	        < u =="0.000000000000000001" ; [ 000032331190435.000000000000000000 ; 000032338271680.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0B57B43C0C04960 >									
//	    < PI_YU_ROMA ; Line_3217 ; 4p7OPBeH8f8wqo0xvlbW4SBGt9Hmne4YX2I5nH42110IqU380 ; 20171122 ; subDT >									
//	        < V98X76FY922j2ut3DNI0726OT9MB6Ze2gW3ZqJ29CrE3z4pQ6f72498t2BHRa40V >									
//	        < eI9Gq08K7nAn2F714WF0Z2I4Ul8ZV2W7Ms0THiI5B9xu1ToGU7m5p8a0R1L7BNwI >									
//	        < u =="0.000000000000000001" ; [ 000032338271680.000000000000000000 ; 000032349728394.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0C04960C0D1C4A7 >									
//	    < PI_YU_ROMA ; Line_3218 ; 343VWvi4AR05bIFU6PiL5TPW81pW7p76cAmKU67p5LvH9SedO ; 20171122 ; subDT >									
//	        < 9z33OcR8OHBGMQeXpRX9oAx77w9658a92TV4iQ0IGhj56BJZ79f30euYe6k83sk4 >									
//	        < m329k17YD6GRU4RZz26d5vOa0Z9FhJ1KzLq3CW8Wwsby7002pNBw4mOS2DwNTsnj >									
//	        < u =="0.000000000000000001" ; [ 000032349728394.000000000000000000 ; 000032355183818.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0D1C4A7C0DA17AD >									
//	    < PI_YU_ROMA ; Line_3219 ; QRs1Kd896JZjK9yx11JmGZTU6ek3WTh0ZQ3eUG4IgO0QmpbH1 ; 20171122 ; subDT >									
//	        < pkodQL2Hcz857KX2WE5409Xpp07V1i0U9OCA9U2v3OeaFA6zt25pNP1H2TLQ0bQS >									
//	        < b38LwMNSbmKX9r2c520U0YBn32373JEUT1My6Uc86obq9y74tQiXTkU2m1Q0ViG5 >									
//	        < u =="0.000000000000000001" ; [ 000032355183818.000000000000000000 ; 000032366723082.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0DA17ADC0EBB334 >									
//	    < PI_YU_ROMA ; Line_3220 ; J7f33wJV7Y2ru68u98vY722yMrJK4z30PwUtbOq3YyhC0L5Hz ; 20171122 ; subDT >									
//	        < Y8q1wZV6d683TpV7jUo1ZSdf22c02Af133519Q5ucb7eNHgx99X42rVa298IQf8i >									
//	        < q4mvFTNV7I0n4v0r60dD6EoM5oxEdvqEAh7K863LLL1Zhz8Mq5NgW8zm1g1BlSLm >									
//	        < u =="0.000000000000000001" ; [ 000032366723082.000000000000000000 ; 000032376820577.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0EBB334C0FB1B89 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3221 à 3230									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3221 ; 4oE1W06aGz4FZ0d2u8A3x9OhdaK0ZsJ038w3H6vHXiS9opm5V ; 20171122 ; subDT >									
//	        < PsINuw6k3iy18TlWAL53Oz4O94iU1uBbWw54b16jj400UiwHDKA4NM99M69f1cfa >									
//	        < J54OvLG587fP262gZW5b32lxHbQRpEu7OVG1b48JBu5X4Ua07D1134pR06b1W98I >									
//	        < u =="0.000000000000000001" ; [ 000032376820577.000000000000000000 ; 000032386698864.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0FB1B89C10A2E3E >									
//	    < PI_YU_ROMA ; Line_3222 ; Q9FBhV3Fe7zP0Rv3nMzS0t3Lb57MMYJ7m2k4K32C21cdr94bD ; 20171122 ; subDT >									
//	        < Zv3Od7CE14RRirnvtV4T8s4MDqCajr1fzzJHk8763hSFR92We51lG737z0aG5c23 >									
//	        < Y8xl9FF94L7b9V3h77R65XQmGzJZpYQT1337M16un0R3w1tOp2AtB124M7R4bC82 >									
//	        < u =="0.000000000000000001" ; [ 000032386698864.000000000000000000 ; 000032393028650.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C10A2E3EC113D6D1 >									
//	    < PI_YU_ROMA ; Line_3223 ; S091PIb1Aqa358G59zOVBwh9zvDnO9qO57y3cYd7x04g55PjJ ; 20171122 ; subDT >									
//	        < 2U96UG57wG53wGjicV94gPpZhB14An7A0zIlrkBTpzCWVReWHOBygC886Y0f2j65 >									
//	        < oyAEM3A47VAoY2vLBzqB2wY43aoJI0b79pReOeTB6zkwPpqvJaIDVWxG9hLvnsJZ >									
//	        < u =="0.000000000000000001" ; [ 000032393028650.000000000000000000 ; 000032400461043.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C113D6D1C11F2E18 >									
//	    < PI_YU_ROMA ; Line_3224 ; YG9w6cg2171Z1gi65Ao4LkFclZxBvyS11r3kDis5oVXu31OUH ; 20171122 ; subDT >									
//	        < rs2686n4CZv82nnwfA9SMN66b9vGllat3gzWx8ayrhu0p946d0rVFjhcV7Z9jHP2 >									
//	        < aBP5WwDNXYK8767HGtd1xBAMwH7GuaQg0QVX3eiPkMA8a88quJ6x2XWHdqg2sWJ5 >									
//	        < u =="0.000000000000000001" ; [ 000032400461043.000000000000000000 ; 000032412082857.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C11F2E18C130E9DD >									
//	    < PI_YU_ROMA ; Line_3225 ; Scyo37NmLrA4n5L43y69ZZ20Au50Y3DISGnRyTO03sLL0QrY4 ; 20171122 ; subDT >									
//	        < 4ikh2rkHg9Ne1o7FI0ATud5fg8QVh23xLJZA26O2RHQ9lczVcGog279H65DAPE7r >									
//	        < 7hMrRTiDm6VUopc63AtO7Y28d6ONIvXyVJ2S9lb58P86FVzAR3Gt7tWkew9E53sa >									
//	        < u =="0.000000000000000001" ; [ 000032412082857.000000000000000000 ; 000032426593358.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C130E9DDC1470E07 >									
//	    < PI_YU_ROMA ; Line_3226 ; 7Xysr3V46ZDTzIRR0if4hTvqXDe1TGMxgsxei4H67VUylLwLn ; 20171122 ; subDT >									
//	        < z4SRxW13M272TjEGsFVc50kkLDrzkVREn7Rzw9tw449u1nx8lNQIq843i3s27717 >									
//	        < XhNvB9H857d8jAd8jzS5453yO12Fx5b4bdVPgd90N1BZLM04H7XnqSffF6M7Lfv7 >									
//	        < u =="0.000000000000000001" ; [ 000032426593358.000000000000000000 ; 000032437846712.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1470E07C15839DF >									
//	    < PI_YU_ROMA ; Line_3227 ; EcL2V2JDqjz6z9nnA268u0BKLJO1Qi5K9odA30r8aO4Iw3p1t ; 20171122 ; subDT >									
//	        < 2UXwS3kj1cf40XHHA30T78403N27g84UqFr9OB67fn4t9jO9tZh22TmLdGt8264J >									
//	        < Qd85iY4sCFC5cGweE2EcekZFuNuSk1gdKzf29Dsfrw87Q0754e15qlR95ob9f4Xe >									
//	        < u =="0.000000000000000001" ; [ 000032437846712.000000000000000000 ; 000032447557151.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C15839DFC1670B03 >									
//	    < PI_YU_ROMA ; Line_3228 ; A8mK88ZCIDS3F2nMx144vK0qjQ8V6xcN5CKS8RBPOnCcojBC2 ; 20171122 ; subDT >									
//	        < 15qS6Z67ivTgh96K6qKpzknF5aCQB9426e6l9RtR821X7qP8zcz7680cpI9kR13c >									
//	        < 2cZ5MmM9s5w0i3y9s8cad2EP419cBW4qgPu59MW6mhbb5reqLVX108gnDe164OR2 >									
//	        < u =="0.000000000000000001" ; [ 000032447557151.000000000000000000 ; 000032457353686.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1670B03C175FDC8 >									
//	    < PI_YU_ROMA ; Line_3229 ; 91IP8ZrOu5387C1DEHEMeCUhGl47zVza8BE72IW7s2qYXp5vi ; 20171122 ; subDT >									
//	        < 4u08KJr9UmJz7CE97AUK4CPacGv5avD50aZOtd30Q9r4lUpNQHG1Ui7uqHkWB88Z >									
//	        < xhQz1bhsf9JsKR261IHFt3Ut4288rBR0J8rY9m8Zt8677r9bbTJh6gw08tSgRB67 >									
//	        < u =="0.000000000000000001" ; [ 000032457353686.000000000000000000 ; 000032462385376.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C175FDC8C17DAB49 >									
//	    < PI_YU_ROMA ; Line_3230 ; AE77ju485oOkFDDiuH6CG4ryJdVUqEIWbXqmy1MH5Kej12976 ; 20171122 ; subDT >									
//	        < 34N03m3iaZcJEyGNT2c6e93PUiIB0Z15Qu6Eiy4062j2UV7hHz5j25j4zX60n88h >									
//	        < esCdc5Xi3k936CT4pwbRcZAEaMny3CH72yrAM5nr4K00hhWQ6w6Qzz3NzDWWrGeF >									
//	        < u =="0.000000000000000001" ; [ 000032462385376.000000000000000000 ; 000032467978901.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C17DAB49C1863442 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3231 à 3240									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3231 ; rQmg73g1425o9O7j1mO5MKHel73nQOYTy03rVF894cR530t3S ; 20171122 ; subDT >									
//	        < 2Y3NkyG2sGO559UzaISfn6OMJsz2sbImSKe21HSs7vZ98ugM5dIahsKg8FsR2yzx >									
//	        < p5bYeTgdOrLiGpVpLkDFQCh8UlqtBBJpa90kK4Z9DuC2B9lG8HO9jhYb70EIjAvA >									
//	        < u =="0.000000000000000001" ; [ 000032467978901.000000000000000000 ; 000032480519261.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1863442C19956D6 >									
//	    < PI_YU_ROMA ; Line_3232 ; tXIttu6npZ629LugA1l2Kp7dB1F5D3jCquvH86753Vp8yFAKO ; 20171122 ; subDT >									
//	        < ga98XAB2fz02weuQ77w7rlqOKK2xy05jkUt5961M816cMoZ51rOyzrasBM548Ofx >									
//	        < Nfi8k7DJ5hq5fCsaIV4r34EuYfq9W836Gfzn9IlCilG58ystuIA6zgKQ15oOo3na >									
//	        < u =="0.000000000000000001" ; [ 000032480519261.000000000000000000 ; 000032491591061.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C19956D6C1AA3BC2 >									
//	    < PI_YU_ROMA ; Line_3233 ; 9v97Y4SJmXf2ERdNO1ide38jkr39OsLJ6pNGECMCOMCKFBY5K ; 20171122 ; subDT >									
//	        < g3CKgM3m7le5l2sfPBlGeSHbgp309S8VvRMTmsloK8m4Et57K6YWNit26grMkWDF >									
//	        < 4IIdZZLJ0rpBW2OT1QPbpTS85G6449483vD408Aa96t8vYWXjQH1mNg8984K6902 >									
//	        < u =="0.000000000000000001" ; [ 000032491591061.000000000000000000 ; 000032506171340.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1AA3BC2C1C07B2E >									
//	    < PI_YU_ROMA ; Line_3234 ; qqehH86fjY5E0ojXhjR9u7CtD9en3Mt216q9M71Fw4U7gt1HQ ; 20171122 ; subDT >									
//	        < ruSsXXFT517Lq1092qRcCH2Tdz1Dx4Qd3uzOTFLWEp26h3NmtXk42P59oQydIhsY >									
//	        < B44da3ytC9mVe3e35fOXug0dTZ0bjwPnp9N21K21H174A90Mo7b3z2Yu65Ihddl8 >									
//	        < u =="0.000000000000000001" ; [ 000032506171340.000000000000000000 ; 000032519894055.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1C07B2EC1D56B9D >									
//	    < PI_YU_ROMA ; Line_3235 ; 0j2IuKX04mp2F9TRE5A8PGHtdVJPPLbL2KUs1R1UGZz8uUwox ; 20171122 ; subDT >									
//	        < 8v1FU228m151mKr5IqTco10JkJvWh79flYaIJO35mL61R41WrQA61CPSlhjE3pGh >									
//	        < Z8UbF6FH2U9gX81693785oD631py9FtiE6stKv1414MHVNA78Joqht7SH6VifGqx >									
//	        < u =="0.000000000000000001" ; [ 000032519894055.000000000000000000 ; 000032526563999.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1D56B9DC1DF990F >									
//	    < PI_YU_ROMA ; Line_3236 ; xDo03l2LRUcjH09kw3JJsrca7Wv2RWGx2bChV2OUOd2OE2djt ; 20171122 ; subDT >									
//	        < p5r4qgg3Hzxyq2S9aD26767946C5c5L4Eq049HyNmaKZlXJv87Cw4KBYy859O7qr >									
//	        < zMLEXPtQ5Q4hGlx8c0AO0ae6DkeCbK6DO01nw6n4341C9TO05l8B7Kk4I8Id3ibS >									
//	        < u =="0.000000000000000001" ; [ 000032526563999.000000000000000000 ; 000032540044281.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1DF990FC1F42ACC >									
//	    < PI_YU_ROMA ; Line_3237 ; 3iaaAFmu3T1AEOz7L274lj3yxYMkWoRuwb2vQl0E3H6D03hu1 ; 20171122 ; subDT >									
//	        < i54m42zMP5HM05kHXw7E1Nn0t9CvR3QQ31pW7Ey1MLXw8ohRUDilU4RaY61j4L65 >									
//	        < bUHnOocDr57KO54pwLLBVH2YvFzQcfQVJwDS13Oq91mSCt1oC1rhl8sux849bwy6 >									
//	        < u =="0.000000000000000001" ; [ 000032540044281.000000000000000000 ; 000032547463098.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1F42ACCC1FF7CC5 >									
//	    < PI_YU_ROMA ; Line_3238 ; V29nx43syj4599SUCDQq20g13KDw48AQ49psbcWW87fyt7vL6 ; 20171122 ; subDT >									
//	        < gSyyWUUbLxP5826z847Ngp1w0uA6F7X5F24M2ei03ynb35cCMYj2hzmH9K19IOi1 >									
//	        < 3WB8rVVzdcXpzqc35zqr5LMIn6bJ15kG8qrlW91NPl20ogj7Z9Qq2TWHQT1160cI >									
//	        < u =="0.000000000000000001" ; [ 000032547463098.000000000000000000 ; 000032561712225.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1FF7CC5C2153AD6 >									
//	    < PI_YU_ROMA ; Line_3239 ; 9co9bLMno4KkIC9s2zB81P4Ika9MsZF4X56aWlBcYY2fSmTTN ; 20171122 ; subDT >									
//	        < 6cgYyrX65lJM606o02q93g6sXaQQkb942Pm8xFa6DV1b93E8waa23KjkpH8z1W1E >									
//	        < 055pizbPLs8tX93N21T80V86c2TFyr9QOh28nDP5qgcq86P8sVMAhh7q128KA0qB >									
//	        < u =="0.000000000000000001" ; [ 000032561712225.000000000000000000 ; 000032571361819.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2153AD6C223F435 >									
//	    < PI_YU_ROMA ; Line_3240 ; iaguL3agn8Xc6w362ia29764329yYuRWuVtjZ71PFe8sEWzR9 ; 20171122 ; subDT >									
//	        < 72gDaZZ41eI8U33i63HP4Pj6R3JMUzniz6C4QZ5ysYdmeCQy28nA8DW902ak3Xd7 >									
//	        < 074t5Rb3BYl8UxsPUs4UadYRB88YFL7BCxy1g2416Qbme81S2sh11FDDRSKvOHbb >									
//	        < u =="0.000000000000000001" ; [ 000032571361819.000000000000000000 ; 000032585951765.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C223F435C23A3768 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3241 à 3250									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3241 ; 17tx41747eVeL0eN6617jfK7D8bw1Uxw4Nm96IC6EA82mJE5R ; 20171122 ; subDT >									
//	        < av7m23EeK4odKo1lGo3M9QYe4cGXMi72HO5V61pw4sLZCUS1Fx9KYA3ryN99M462 >									
//	        < 3CY95OU3891BB13h2o2V1647qfcW7T34Hmi28AOn4f5qqpWVpH1D85gdblN7X6DC >									
//	        < u =="0.000000000000000001" ; [ 000032585951765.000000000000000000 ; 000032597798947.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C23A3768C24C4B36 >									
//	    < PI_YU_ROMA ; Line_3242 ; NbHlo3jPwisr4PUnkDwMR5wzw9w0FbDv7mfXmR918R528gtxx ; 20171122 ; subDT >									
//	        < ULgN716GZcaS5lNgPnlPMpB0dgZrzuG8Bmclwi7n5OLfWW2wFlen2q20E1pkhd57 >									
//	        < 73Tf8gpz6Jwvj5Y78Kq6V2j1VK2Tg84s5QR9N30O02PamShPB41u3cpqM5ino26f >									
//	        < u =="0.000000000000000001" ; [ 000032597798947.000000000000000000 ; 000032610622450.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C24C4B36C25FDC65 >									
//	    < PI_YU_ROMA ; Line_3243 ; 8P302k9y14QWuyJ80h04aN3DuJ1zZSk51ry27CKUj9UtTK682 ; 20171122 ; subDT >									
//	        < 3vw4i7Z1oZNvhwfefRye2wJ1gMUw92jpoN5VZgQ7CRQmn1h22ej6FN5e1VUpHE2x >									
//	        < GQ7LW727Y6327t6XST108L3NXFL82iqh1hx9Bhx5zZ6jU34Lalo55aw4XXI0y9oz >									
//	        < u =="0.000000000000000001" ; [ 000032610622450.000000000000000000 ; 000032616398588.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C25FDC65C268ACB2 >									
//	    < PI_YU_ROMA ; Line_3244 ; 2y8P560g34rq7UifL9p23168yTzX1uoI21npO6tHH7eUCfZ5U ; 20171122 ; subDT >									
//	        < oN1dHU71ej53ygrzwZ6pwDQ1Zo462M39O3G24ShbJV3wBVv3iG8H4REkgR5UJK1R >									
//	        < LB8J7MvZExy3gcbr9xm2bmwXrp40B48o5rZ9TNC1L2Qnh2JzAm0Hcm3YE9TFXP9S >									
//	        < u =="0.000000000000000001" ; [ 000032616398588.000000000000000000 ; 000032622278650.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C268ACB2C271A599 >									
//	    < PI_YU_ROMA ; Line_3245 ; 2M9X98F0aYIRASMxy0fF4484iP7r23bxJ2BR8e6333HEWw977 ; 20171122 ; subDT >									
//	        < Zr9qx6S2g2uzy8C51fsNbMrC919zG5r2c025ieN4etPkjcUPQZiU84b7nz9zfV8m >									
//	        < r73xCDzJmyKV85z3xPUw348SoiPu1al3Z2PTUKklqz24g2Owh1J60F8QB67dPQ1Y >									
//	        < u =="0.000000000000000001" ; [ 000032622278650.000000000000000000 ; 000032628798233.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C271A599C27B984F >									
//	    < PI_YU_ROMA ; Line_3246 ; qkOTjuA2YiNFv349961ujRnLQX8ZxUWODIb6pyruK7L0drRMs ; 20171122 ; subDT >									
//	        < fNyeUsO9oW81RO731gkh9XL9N5wJCw22rkIN0cqqj0LE21GG48kYOT1qp015WJp7 >									
//	        < KjodQj8Yaq4B1LciIgIoz7v6VI5lHCI3e5qs9A4tgh6nV9sZ33gP4CqiZLu04ohf >									
//	        < u =="0.000000000000000001" ; [ 000032628798233.000000000000000000 ; 000032636213865.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C27B984FC286E90A >									
//	    < PI_YU_ROMA ; Line_3247 ; 6243ty95MkgB3g8CXymSX2Q4S2H9cva7VD0GG419h6Q5G87MN ; 20171122 ; subDT >									
//	        < L8YGIKB752VXAi681rQFcsg75f25hycZ7i6apOj94xC0uFGeOV0d3E3Kz2gea462 >									
//	        < 8RdeHFVhAPMjqJC1uKK83blLnclJg286tJasH3e0cJk54a4008A9vl1n7ZE89KSO >									
//	        < u =="0.000000000000000001" ; [ 000032636213865.000000000000000000 ; 000032644288038.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C286E90AC2933B03 >									
//	    < PI_YU_ROMA ; Line_3248 ; p0F00Ga2S1fXw012i6wQU1g80kmOrSR42k3au7o13kys8LvoE ; 20171122 ; subDT >									
//	        < 33O681cFoqC4774mVUZH9S4v2I5hcqU5pg45I0UI1Bwp9brBre7tNelyP8384AMx >									
//	        < RDQNYMYFB9DanNmbi2s4ESn996dzf90u9UnuNuOf5030eXHv5IOkOYnfKRmwNlD1 >									
//	        < u =="0.000000000000000001" ; [ 000032644288038.000000000000000000 ; 000032652755616.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2933B03C2A026A9 >									
//	    < PI_YU_ROMA ; Line_3249 ; Bu9PR1ma8W724c7kJ9Zm8L39hVzct4NX5AL79AU95L0ZYdi39 ; 20171122 ; subDT >									
//	        < 9nYnooPe1IOR68PUAO034ZT1uL97gi1A2Z1FhnC4c05anWL7VNf1E4uTld3g1p2o >									
//	        < ZN0033jpBvvrzdwB3XJI065fUAGx17l277nO3o81NRe92op3p9yH0g31m2M13Mq3 >									
//	        < u =="0.000000000000000001" ; [ 000032652755616.000000000000000000 ; 000032664780642.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2A026A9C2B27FF0 >									
//	    < PI_YU_ROMA ; Line_3250 ; 7wCbrURO9lWA31xljQBjMG3vyreH06jAwtc0IQT0fy66cCRD6 ; 20171122 ; subDT >									
//	        < 0y0I9G23jK2x0APjBSUs5oMNeh7T1l0pBhu352P8056iWFx4r56YrA0vbE82ayTm >									
//	        < Zuwp5HCz24cb96qXH1Po7q13MC9BaIT6upnmZO4K2f0V58AgbeZI10vG8LkW6e6V >									
//	        < u =="0.000000000000000001" ; [ 000032664780642.000000000000000000 ; 000032678936145.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2B27FF0C2C8196E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3251 à 3260									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3251 ; u3UrN74a29oBxD229w9iBe6WJo9JB2Dv466mjF84m3p39aN6s ; 20171122 ; subDT >									
//	        < EnUz6359HvMTuJN51X7UFB1o1UbBOWDFCeIPcqS4R44vQP382BYssN0RU4308BrT >									
//	        < 6FVCaWx08t47BWGbMQlS7X09s368GEjmUnGwVl7b1q02vhejPzwy6K6Ptsy8KZ16 >									
//	        < u =="0.000000000000000001" ; [ 000032678936145.000000000000000000 ; 000032693364366.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2C8196EC2DE1D74 >									
//	    < PI_YU_ROMA ; Line_3252 ; OQSctAHS3lYx5G4tWQQPsM2Gzo8xe57NRKx3Srq5v1F1Aw4H5 ; 20171122 ; subDT >									
//	        < 8F1xc0RGEP012Zh9mBM90pCkpnZL0QicSAsW9kXW1RNWiSK9FxETxYIzK1dkqL5d >									
//	        < 5957KaSsxhv9s8hO4kvEMG1gjnoTh5omFw1p1g89Y89phT7L2zqItnFmKq22i8HS >									
//	        < u =="0.000000000000000001" ; [ 000032693364366.000000000000000000 ; 000032698683073.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2DE1D74C2E63B13 >									
//	    < PI_YU_ROMA ; Line_3253 ; awpoP6Q3bvYw4VFWjD297JhLyVKkIf2Qu3RU4sZBItjTd854O ; 20171122 ; subDT >									
//	        < dwr2se8Oi1gY19o7cKdc537a5D7gdx90HrwGwM5skEmgck0uR907JAw281vL8OI3 >									
//	        < V7E9qmQS3X3B3q4oXAZDw3V2ie7FW868549fleA6Y3PRI16HLj2RLa344Dj14Lhw >									
//	        < u =="0.000000000000000001" ; [ 000032698683073.000000000000000000 ; 000032708597298.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2E63B13C2F55BD1 >									
//	    < PI_YU_ROMA ; Line_3254 ; nOL77sUBZt5O5X7v76nyBpcVpgjF2xhDDbh2JrMZbX6SbJG97 ; 20171122 ; subDT >									
//	        < gm5kVekv10ly9uVglbbBU9Un3k98ail2YPeXyrloPNKX448KDHeWkN4Z4U6oEJE9 >									
//	        < 6vHS2w1l8h9eotgx3gAIqFK3q8BEJmhmyhh1O5J5vX8lBuTz16WTT56RHcM4OpkU >									
//	        < u =="0.000000000000000001" ; [ 000032708597298.000000000000000000 ; 000032716264676.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2F55BD1C3010EE3 >									
//	    < PI_YU_ROMA ; Line_3255 ; ms4U888KUm8ALZhZkJ05xIqPfOHV1mA0MI3KtKcq85DF2ghoX ; 20171122 ; subDT >									
//	        < 52880M1Rd9Ym2CU8EB74rgLzn65uyD748AaWYI0WSANm5Ovsw6tzBg7MdbMPT2jL >									
//	        < wZFnmZKQsYH0TwAk4QxJMsvkMq89hDtjJ0Dp0u6by23BzAuSwVmd3YpbJSsU7r3h >									
//	        < u =="0.000000000000000001" ; [ 000032716264676.000000000000000000 ; 000032730712716.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3010EE3C3171AA7 >									
//	    < PI_YU_ROMA ; Line_3256 ; qE6K50TLDVeaJvoG1v86R5EfIXkGLPST2Zzb1Lg66PAMGcMfT ; 20171122 ; subDT >									
//	        < Z2dWTIvi8TCHtNtFFZ875Q6GfY6hA5X5mi90Q9WM9DH3m3A3k8sSb5qYl2Rt5cWM >									
//	        < hYx3nNwY58T4yn9A5W4KWgUq4gxxYjVm7wwlS15oeCvH6KO8ELpoRp92R6YtI16L >									
//	        < u =="0.000000000000000001" ; [ 000032730712716.000000000000000000 ; 000032741853916.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3171AA7C3281AAF >									
//	    < PI_YU_ROMA ; Line_3257 ; B0Q63iA9lWwZKpDQh2FS1Mm3Mb2U403B0WZVd9tgIbiY1iS76 ; 20171122 ; subDT >									
//	        < ZR10Bp3a8JU8T3ZH7fQ4Pqd4HdxUnMUzBBTq4I4h3ot223JB3n1ZqLTMM6y8Pv5W >									
//	        < WYcc1obM20ZbZO1nN3tX3vDIn95fCfNIy7oup20g1zK6Xq5lh4Z5p82pIkdO1KDD >									
//	        < u =="0.000000000000000001" ; [ 000032741853916.000000000000000000 ; 000032755608225.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3281AAFC33D1776 >									
//	    < PI_YU_ROMA ; Line_3258 ; hqZHAkVJ45w6jgd9nTpqU6grervqyDfw4Vk2S2406KH1vUYs2 ; 20171122 ; subDT >									
//	        < 72K904n7T8I5w2n75YBcb4hJjQA34ufd65jcAC9iZzpiIf8D9yqJaIdD66N54GnC >									
//	        < 1zjWtsyPf2A3IGXP018H4yH98OckqV7ylm04yM63N0h1HRcD33E3ClW35LWPo35S >									
//	        < u =="0.000000000000000001" ; [ 000032755608225.000000000000000000 ; 000032767116784.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C33D1776C34EA6FE >									
//	    < PI_YU_ROMA ; Line_3259 ; 8KPMn5u1p50442LcGCrkEzC4Ogz6ZVV4Jp8of9v0lnfxY760L ; 20171122 ; subDT >									
//	        < Pk1p95G95BEbmg4z13746dJZ8Gq0E7yc8kaW9RsJW9UGPx3b82vK7Eu3pOPmws4L >									
//	        < 56QH5UcCOIk6gRuG2hFL31Q6Ldal5SlzfHq4dw4OeL8Tu5gW6QQ1O27q9xXdx8Qj >									
//	        < u =="0.000000000000000001" ; [ 000032767116784.000000000000000000 ; 000032774792015.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C34EA6FEC35A5D21 >									
//	    < PI_YU_ROMA ; Line_3260 ; ZtsBJ48UaE276b4L10N6208Q6Edr3cMbbA5I8089K4xmyX2nS ; 20171122 ; subDT >									
//	        < Dx8uSGFLV5jqghS4QlOJsE84zfM670zYn67px5Pa14muFzALt0au1M5YJEX3ZNm6 >									
//	        < ZHs483JVYXS0uS4fe11Z4t9904tNfmF2LMFCYi27liM065Edb1Nx9S32eCmJy2C8 >									
//	        < u =="0.000000000000000001" ; [ 000032774792015.000000000000000000 ; 000032786989034.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C35A5D21C36CF997 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3261 à 3270									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3261 ; I0tORP08G5X1sa9WtZ6G78Xzx8o98HXyzk4B48YBeq027CVkw ; 20171122 ; subDT >									
//	        < rB7hx0PtBEcIj31H8f3u7b7Ux5c35eS1pqUOr5rargnp4Zw0whbTIa2jro5nlqN6 >									
//	        < rV6760Rp02PZ8H1NSKxZH37BXERf762az63RA4Eu5r71JkCRkJg4rQiU6GoFYqX0 >									
//	        < u =="0.000000000000000001" ; [ 000032786989034.000000000000000000 ; 000032798161181.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C36CF997C37E05B6 >									
//	    < PI_YU_ROMA ; Line_3262 ; 2ctARrE86Ak5Qk6AhNWdP89dW81vj83A7zzut1cUXW145q410 ; 20171122 ; subDT >									
//	        < mvg35vh637sqZ92503Cznl9cs3V4Lf8d2LeBE7Cw1DbiPyMeNr5j50884v0c1WJy >									
//	        < 4LfPZx8H2xvx5hQUN1DTII8BSiXt4eky2xC2wZi51GJYYFrlvQx58MRymT8crl6g >									
//	        < u =="0.000000000000000001" ; [ 000032798161181.000000000000000000 ; 000032807120040.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C37E05B6C38BB144 >									
//	    < PI_YU_ROMA ; Line_3263 ; eke34x89IwtwtFK4WE6pucY86LQ3t2W4Iz2SkjnI7I4esXlPy ; 20171122 ; subDT >									
//	        < n7Hx74uM4dFv3X6IGQ60zsaj04Zv14A7e6319uUpAP15r4BhtgcfiUDn7wPzlwIs >									
//	        < 8117siYM29718CtlfU510DMLor2QQ27ckeb3MbCz7bZL75TY24mBW612AMDGv1oG >									
//	        < u =="0.000000000000000001" ; [ 000032807120040.000000000000000000 ; 000032818961333.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C38BB144C39DC2C5 >									
//	    < PI_YU_ROMA ; Line_3264 ; T2T6r8OBM7Fj0FHH7E4vV5b8791sO8DDB07C1i8L2lmX2Z6Wx ; 20171122 ; subDT >									
//	        < 12YWiRot7mlLPj9QS0j9Gr3rK99F8aW281xRy091vzq6fgwrtrnoG8PqFaLd7GPb >									
//	        < 03eKL1YK0zp6u1MlujbX8VXZ63NqHUIj9gOumJrSheUd1383JYhZo5RQSI6Fe56E >									
//	        < u =="0.000000000000000001" ; [ 000032818961333.000000000000000000 ; 000032827029854.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C39DC2C5C3AA1289 >									
//	    < PI_YU_ROMA ; Line_3265 ; qp8zYsvht4f3U0Az575YMI3vRMPT70fm1DpcxD3AtVyldq9mw ; 20171122 ; subDT >									
//	        < boeRqLf4h14cJ73DRvC65BHvm5mV7tsMYFI8Qe6KB42Y6uGH42y7P0Q3i98tmkl1 >									
//	        < 0hqu3N0jHXQ1ZjI6ARqYFN987nqScBkqeLS0TYV8Xuo1hKOL0lLM5vl684z9B1UI >									
//	        < u =="0.000000000000000001" ; [ 000032827029854.000000000000000000 ; 000032833982526.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3AA1289C3B4AE6C >									
//	    < PI_YU_ROMA ; Line_3266 ; f945dvYf86dl6eoB6Otil90XeEMY7cq63I32XgmNd3b44dtwO ; 20171122 ; subDT >									
//	        < 3vOo59825tb66K4653W5pRl68Uno9er0vbjUREq5Xk9P01bP3i9xhydH587os84N >									
//	        < 74Cpn1daK317TUg7XAvgksRRDx7y1q7SSTRsn3UFX8QuvOCliN0d4j6Y1o3bRTMe >									
//	        < u =="0.000000000000000001" ; [ 000032833982526.000000000000000000 ; 000032839605774.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3B4AE6CC3BD4301 >									
//	    < PI_YU_ROMA ; Line_3267 ; HXmDOQ6yYKulj9x6hCucmKMoVi5D4B13xI5CWUFjDMS3ZAnw9 ; 20171122 ; subDT >									
//	        < 7tZU0xErRp58SyZKwAP0Ig3q4whu688Z25HdWe333iJYj5o5L60FH7B7w05C9sve >									
//	        < Uf5Xc7E02xdXj1PJHh0AdoqNgpuuHSupSEFXw8x2bV492n94E6hCxb3SO6J3N586 >									
//	        < u =="0.000000000000000001" ; [ 000032839605774.000000000000000000 ; 000032847136237.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3BD4301C3C8C097 >									
//	    < PI_YU_ROMA ; Line_3268 ; kI26z8J4vL546HTvXEQsT30y14yoN2Ha0zV99a9gxw0Zxa552 ; 20171122 ; subDT >									
//	        < 4c1u80mxL9bJyxj4f7ikPomMt92XYICPSeKND1XjYKY5A64Qrs76O5bkLi7sI17u >									
//	        < 2EHnT4H0CyUJFgm96qY1BRCkZDHU4T8I5FGyt0304uhxpWX4cKVp0d0b5OZ4ed8w >									
//	        < u =="0.000000000000000001" ; [ 000032847136237.000000000000000000 ; 000032860332833.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3C8C097C3DCE383 >									
//	    < PI_YU_ROMA ; Line_3269 ; Xk6286h6trcWCG3a3G95BCwKg6W089bJxUQvNdFp4kQ10mdSF ; 20171122 ; subDT >									
//	        < YjQA06Dy1qrV14636jWEkE9814t6PnPkJ5ocHaN0jkis7Ge81KX9aAxR23LEHJCS >									
//	        < mbo99Vl8hP8AF5xd0d87m9orVknmpSB9PbZ9A7Rg4ZGj37BI5E1nz4X3X5021czv >									
//	        < u =="0.000000000000000001" ; [ 000032860332833.000000000000000000 ; 000032875188849.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3DCE383C3F38EA4 >									
//	    < PI_YU_ROMA ; Line_3270 ; 5K1nfXJtGbq9bsy8fC9GEx5ut95775DtzS097pTyMD8JRfr4Y ; 20171122 ; subDT >									
//	        < ukElHqPOK0StNENL14QJ5qhGWaH89qI1EmSnp9TX2xOH01Z36NO3K4iLKuZ467sp >									
//	        < aKJ02v15r7pnLY6Kl3MmMGoDa27e2NSrd7DOqUDEM4BR5HCu5LOj2FHCvO87Mp9x >									
//	        < u =="0.000000000000000001" ; [ 000032875188849.000000000000000000 ; 000032886653124.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3F38EA4C4050CE0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3271 à 3280									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3271 ; sgp53Qa4LEzns29ZQgS3XOke2dK8Oob8P09qnMzJLLc6kTEr0 ; 20171122 ; subDT >									
//	        < b8Cz59gTKk6mMloM9G557uRf857ghkzi5b9b48dPJ83XJiLThnV946MRJrCjL9V6 >									
//	        < xN40lSNUzn0CZc91TaPhqb7d6g9qr32SF2InxQl2RiY6MLDAPiefz32P59wH1I7E >									
//	        < u =="0.000000000000000001" ; [ 000032886653124.000000000000000000 ; 000032897693829.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4050CE0C415E5A6 >									
//	    < PI_YU_ROMA ; Line_3272 ; gzJ1c0Kpr75drL9woVLOl32EjgXTgDzq7fnXAD05ISzxkd0RQ ; 20171122 ; subDT >									
//	        < 1qkdFx8wNX0sa8sYMGathVd0a83SB51ObqMUtR0ilF89E386BJp1d3XzScsJGAL0 >									
//	        < HSf54r8y56uE6ef130R4k0qroIgV12eU4JgsozMg8Qe2e0Dkb05S595qL7tluDy6 >									
//	        < u =="0.000000000000000001" ; [ 000032897693829.000000000000000000 ; 000032909527973.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C415E5A6C427F45D >									
//	    < PI_YU_ROMA ; Line_3273 ; 4BUZAiRtwByE0yZQzglM5JF2RnYWFwcAAd0aaaY0O0486Fg64 ; 20171122 ; subDT >									
//	        < ECvOkUN4W49KeatNK09Hgyxy2L3JJ9gDG9sx9plaJOCH53uq9YKdinhwOfbS7Cre >									
//	        < 7j98JZ4CajF2r6xH07FSK8Chp2YB3rn45Se8Q5Gsg2rNQlzkk7GQ714S9qM8BjAb >									
//	        < u =="0.000000000000000001" ; [ 000032909527973.000000000000000000 ; 000032916562321.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C427F45DC432B028 >									
//	    < PI_YU_ROMA ; Line_3274 ; 26bASxhc3wddPesA6qWQu2UhME1m445188v71sg2B2J211W94 ; 20171122 ; subDT >									
//	        < Vtl15zx99x60SDGqYDbJ26WezQDpI7c5z802KDR8FJ021W3ryhhpiQfGGIADW805 >									
//	        < 47w8g6S5LT3ysLJGm8HtTYFBOE03PGeTq8F8wgtsI9A6vaHiz648nFzGL0786qx8 >									
//	        < u =="0.000000000000000001" ; [ 000032916562321.000000000000000000 ; 000032929568485.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C432B028C44688B0 >									
//	    < PI_YU_ROMA ; Line_3275 ; 3v1gJP901c3mYeEX2y8miQQqsklbq25aRPwHPmNrKJCA6s33U ; 20171122 ; subDT >									
//	        < xi6s585RV2s9d9yPgy2YG39cjZx2vJ0vvHXhvuS0VfmHwfHP83g4y2f18y484e53 >									
//	        < 0E5w92ieQz33qBnfV9zzH8RuHV22ppn27qCxfzS88Q3h01243U5yNLlrYUBW82AC >									
//	        < u =="0.000000000000000001" ; [ 000032929568485.000000000000000000 ; 000032940338769.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C44688B0C456F7D4 >									
//	    < PI_YU_ROMA ; Line_3276 ; QAH0Ob9TgH1xQGS59P8fe20vCFjh1ml1yKD5qN6SsFoHD8McS ; 20171122 ; subDT >									
//	        < dQiDx46897FA5r3c05sS2U51mJa16kWj1484xc8l9AqrSB9oG884Y0Dy4chis6k6 >									
//	        < 2PUylOt13DC7726lOWszvg7m2e1BDZJk6d0qPu2Q1h78qwnR5awHSgqsAjBaTPLY >									
//	        < u =="0.000000000000000001" ; [ 000032940338769.000000000000000000 ; 000032952304355.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C456F7D4C46939E3 >									
//	    < PI_YU_ROMA ; Line_3277 ; NZOcmG1rsitp3c8q7VOji1CcORhbYrnbXWpLxNKN3jOaM5tIQ ; 20171122 ; subDT >									
//	        < M2GYgFHyiH086j3k9ORd9hqZ1Q3d7akgnBFB1JV7H0elp47z0HKPuwo9iIxV51OJ >									
//	        < XARmh7dSh5ifI55B0Bv9JJksriF2Sk6iOuluwX3QtXxN2yRy6dqEmuY9Vsm8YIAK >									
//	        < u =="0.000000000000000001" ; [ 000032952304355.000000000000000000 ; 000032961362296.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C46939E3C4770C25 >									
//	    < PI_YU_ROMA ; Line_3278 ; dxrPARE8osEoK0nP95TYuc1yW64bT664J7B75Yjb878x3ds27 ; 20171122 ; subDT >									
//	        < 2c50oBg2MG446Zbyk4n3C0U27Q0Fox1HGi1hd063ZqYvOx0q44Qv2u25Qa98y402 >									
//	        < 551A21ddg37db7Ulv2CELuNrF3wx37b176b2d12q7KQd9W0wYwjsuoN495e1UEW8 >									
//	        < u =="0.000000000000000001" ; [ 000032961362296.000000000000000000 ; 000032970158748.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4770C25C4847842 >									
//	    < PI_YU_ROMA ; Line_3279 ; Up2WFYLS3xAJJ6BqXyExkr5PLpMRiHZ75tmxo4eMsXuoFuhw8 ; 20171122 ; subDT >									
//	        < rsvVRR9bqrlc081jYQePp5bnO4hNdrzwRSX548W97kAJBQTYB0YNuMKP5Mw89sKL >									
//	        < 3Ecrqj159wv8WOxfBMsN0M1dCej9HN8247R649c1e5QUggdisO126qF14oKir1Z6 >									
//	        < u =="0.000000000000000001" ; [ 000032970158748.000000000000000000 ; 000032977318640.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4847842C48F6518 >									
//	    < PI_YU_ROMA ; Line_3280 ; 2srp0aI041L8d2kiF2eRuM28H4Z87T6hRL7L8A9eB70w4XLFZ ; 20171122 ; subDT >									
//	        < 8GBMr4ybI6VRzBL5R8sBl83hVqbGisPyriw8G7Ccz24NQW4Oo3itXNW0Ff8PypQB >									
//	        < 5nw9h783v3tBVr65jywYIESTrqp5gA62S2PRw9eLbvV6WkFburp000Cs24ec6da9 >									
//	        < u =="0.000000000000000001" ; [ 000032977318640.000000000000000000 ; 000032984556435.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C48F6518C49A705B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3281 à 3290									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3281 ; d2x2R0i59JC1c7rgEL047qnKs15Y99Y103qW1uJYntwnhiBnP ; 20171122 ; subDT >									
//	        < 65x3kqg2Mw11MsWjHgE9Vtxj8UsPM75mb6Wzf6u9R9XiO55h4w58w7l0Y7zbLeea >									
//	        < U30507LzTW0wSDml1dppuAeA5EK9oF5TqzyJ0796CbXmCXJ5M9jLy9lKfeAxYmCq >									
//	        < u =="0.000000000000000001" ; [ 000032984556435.000000000000000000 ; 000032992653013.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C49A705BC4A6CB15 >									
//	    < PI_YU_ROMA ; Line_3282 ; 0bMj0lxwTSnK3RCq3xY3re94I5tu8uP7jOkA8mmi649aiQul4 ; 20171122 ; subDT >									
//	        < 4VMJ75YVVd3Saie9XUP6A028X8KT57F4agNrxbov2l7vEBS4Wo2yXKgj1q2B1h11 >									
//	        < V2bZKRV7BXdVYz46wK2XENmQ6gYp1ISfPl6x08uXg5obNt7JAKB9Um262SQ176Bo >									
//	        < u =="0.000000000000000001" ; [ 000032992653013.000000000000000000 ; 000032998511384.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4A6CB15C4AFBB82 >									
//	    < PI_YU_ROMA ; Line_3283 ; JY1RQyGy1444UH4YDLxP9Mos8295pod38of2xnhQSW2E8sIze ; 20171122 ; subDT >									
//	        < 7l73y8gsCyL4JCRwI68oih5w3A1uAdn8Yi7W777L45wMFPjaHoXj6747z5H20p3G >									
//	        < 12NMfVjZbhR5Q03EE57ujdq7Y8aTUfU421MvrXre40xUsC6apTPkhgAH410Nt809 >									
//	        < u =="0.000000000000000001" ; [ 000032998511384.000000000000000000 ; 000033009142467.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4AFBB82C4BFF446 >									
//	    < PI_YU_ROMA ; Line_3284 ; 36niH93Ks1X4H23HJZ5Ty8HfMy0QAkbbc5zsQOipq6nvK1P0l ; 20171122 ; subDT >									
//	        < tfDFaVK4aNtjkXw1GeZb6Jy14aXDz5BgBMvu0ml78P4mHM12TZmW17aw8506kNU8 >									
//	        < v10nXWYA869j6cZT9E9hWG4563l1368EXTM0JzlFMDQ069O22DTCN33dvIVP3Tla >									
//	        < u =="0.000000000000000001" ; [ 000033009142467.000000000000000000 ; 000033016479537.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4BFF446C4CB2651 >									
//	    < PI_YU_ROMA ; Line_3285 ; 749JTyo75e25ALT7imfeiauH3dA8apyjKw8753hz1y78Tc9H4 ; 20171122 ; subDT >									
//	        < 209Bw98M5fi1y2n9q5tXEU3rwIYJedVKwaNIv3fo0wPvzNh5PYd25r6H1iY9w7WQ >									
//	        < 3nNKRMjCPCy014HDbO4ohBKukoO0hGj6o08ev3Ht4z8FXQg1y4XA37YH6uTN17dJ >									
//	        < u =="0.000000000000000001" ; [ 000033016479537.000000000000000000 ; 000033027534004.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4CB2651C4DC0478 >									
//	    < PI_YU_ROMA ; Line_3286 ; 6h6Wmg9JI6E0Zzu93WmiS1t85KUwRt3ODV2rG86r1wWRhN3B7 ; 20171122 ; subDT >									
//	        < T6sOR1GOn5yLLA85RlGlT55l15ZorV9sx3u8Vbcq352O6sOGHLUp0IBv7it0o94d >									
//	        < 246ljznj5Z6LDDZM8y7Ucd1cpMES0b1J5cQLp5x164gh5h4BjI0RMF9Ixe875O8y >									
//	        < u =="0.000000000000000001" ; [ 000033027534004.000000000000000000 ; 000033040114252.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4DC0478C4EF36A1 >									
//	    < PI_YU_ROMA ; Line_3287 ; zBOeD8sWkG30uf79Bv0aDrjH5ShCO3T2i61MfECwZsgh8ir8t ; 20171122 ; subDT >									
//	        < OhsN2MYS667eV5nteQGcbAtmMA7CdwuE0MRzK9b79VoOlY9hC5QL8620tS4rOYYo >									
//	        < vEFbTe7UB3Sj8QOgRkjTpDe2W00EF35r5713hg452VCcmn7OaTPm6b4v2LX6P12t >									
//	        < u =="0.000000000000000001" ; [ 000033040114252.000000000000000000 ; 000033049408139.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4EF36A1C4FD650D >									
//	    < PI_YU_ROMA ; Line_3288 ; SRZI6D4AqDMhP2hp4eFj1AuTJNPnsg7jmQNf6XG0312Eef16I ; 20171122 ; subDT >									
//	        < 0t5TBXVszEq8cy7SvcpE0R3w7H2FFp1PV59Sr51NOVI3D6neZCuR9fBG775iN992 >									
//	        < LYg67Hdc6RnTDt4sUJ8fUu0S5OxLu0gDYQU7vD4G02OQq4994hubXavI2O9R1Ie4 >									
//	        < u =="0.000000000000000001" ; [ 000033049408139.000000000000000000 ; 000033062810746.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4FD650DC511D872 >									
//	    < PI_YU_ROMA ; Line_3289 ; NH433pYMb657RUx2Eb8xcCPJyj2o2ON19w8gRt4664k4UI61h ; 20171122 ; subDT >									
//	        < q0mw45NuuuG15EmA18mtNKZEWfjs4Ig0uIr0HiO2NQ48p1hZgn00PXbT9WjE6eGS >									
//	        < VJlhoeQE7ZxZ0V115y88J4dkquLtLA0GgowcXvzCp0X0MjUC6SyU32Lj5IEdM0tQ >									
//	        < u =="0.000000000000000001" ; [ 000033062810746.000000000000000000 ; 000033067911470.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C511D872C519A0EB >									
//	    < PI_YU_ROMA ; Line_3290 ; 3wv4UnWq8kvIqR5VlhgAoZeq68VnP7v28wi2CE1SKz90I41zb ; 20171122 ; subDT >									
//	        < 32aFSVLFg3v6pN69K1pMppXM59s8ZJbu0109eGOY7u0yS47zipq7IS1BA6rQHb99 >									
//	        < niUkFSIpw9V5xH57HZd300y48qX07vBx8D3Vs055te5wxs9Onev8Dq08Z34wI3Ss >									
//	        < u =="0.000000000000000001" ; [ 000033067911470.000000000000000000 ; 000033079505364.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C519A0EBC52B51C8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3291 à 3300									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3291 ; 896lvJPK8UzRgN16c9WLJdcJg6bwPghVfYjJB8g0yOb9qtsQ4 ; 20171122 ; subDT >									
//	        < n8fyrdRg7A9KTClC72EYFaOBCUztlNd7qO99ody90Oa0QqkX5F8N6ehMm7TYiZil >									
//	        < b6f1N8S2kCeQ2Z0792BICA365FI1Z4kg63sa1TwL15Kasod5KIsF89F5XZqqbP5J >									
//	        < u =="0.000000000000000001" ; [ 000033079505364.000000000000000000 ; 000033087054627.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C52B51C8C536D6B6 >									
//	    < PI_YU_ROMA ; Line_3292 ; j7t80rCFg1T3tszScV5gF861IwI0j1XI5dqbw931Vzx4kPmf2 ; 20171122 ; subDT >									
//	        < MK3Xlp4648QkgN1NVtC1tSqYmXQ5aGF9R4tp69i8586Z8x74tJXQZmm7Fs7x9zNt >									
//	        < SGxv8p702D79686EdqAjc2Fnyq3fttSsjGPsqN5kLHAqpt6x0P7Zl1r1DK5VIPbF >									
//	        < u =="0.000000000000000001" ; [ 000033087054627.000000000000000000 ; 000033099812772.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C536D6B6C54A4E5D >									
//	    < PI_YU_ROMA ; Line_3293 ; tHq69tu2D5b7iPOOC69Q42159ks6sGpZUM7oO0q18tHZ3m4aX ; 20171122 ; subDT >									
//	        < N4WlMInI385vyaHYfG6jMgi5147PoKcp3T01dc8414vX8PqY1Agy7TT24gsXD4fE >									
//	        < t17Igup6kE4zPz0cGT82Ktv8Ubs8b21onUg3ESDBd9jGajE23186BgpZy737fR0t >									
//	        < u =="0.000000000000000001" ; [ 000033099812772.000000000000000000 ; 000033114019662.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C54A4E5DC55FFBEE >									
//	    < PI_YU_ROMA ; Line_3294 ; 6asHfK4tblqHdNrsxA3JpC3be0b9236DtXv0Z496VVAMJS8A0 ; 20171122 ; subDT >									
//	        < UNFiuKXk95JQn42O6cxn22hsVQPawRfrzOkKoU8r7h1M9XtQOylTJ6ac2RpBhfaJ >									
//	        < 0Pzv9S11eiCgrzQdHOXlNK011lL1VkTpXd02pw45Zvq2BDIfXksUptgNPG8zi60P >									
//	        < u =="0.000000000000000001" ; [ 000033114019662.000000000000000000 ; 000033120422524.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C55FFBEEC569C10C >									
//	    < PI_YU_ROMA ; Line_3295 ; uhjlJAmgB3L7aWfK6F7NF8090bjvs4sBdu77x5Mm7GQOrNA78 ; 20171122 ; subDT >									
//	        < rfHxl7r764O5X8tXC8e5YEk8Gu1rvqD00y9U1L4CZjKr6k929t6SDZO43QUfrnEH >									
//	        < P8jJY9GGT2761a0tK3z5S47tk9Z4b2503yfUE9DDkpYo6KHGMeep0MncgnBCBjjv >									
//	        < u =="0.000000000000000001" ; [ 000033120422524.000000000000000000 ; 000033130431613.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C569C10CC57906D9 >									
//	    < PI_YU_ROMA ; Line_3296 ; 2a533Nh229s47eJDmX1Y6WuU0s7G4iS50g786zgcc6JIY2niL ; 20171122 ; subDT >									
//	        < 4iQ1O9y79yI2Nx1429j56ir3a0O3GTa8s0t633kcE8v7Or3t93CP9OUK7h0777wM >									
//	        < mGww3srH4sd0G9K80KyGw8jG4P55bfAakoGFOje6Ix373pFClA5lXrFqv4PrL09K >									
//	        < u =="0.000000000000000001" ; [ 000033130431613.000000000000000000 ; 000033144877472.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C57906D9C58F11C3 >									
//	    < PI_YU_ROMA ; Line_3297 ; 6ItJt74wI09E41d151obq1A73afXfb1rn7zDgYxsanZqDx0vu ; 20171122 ; subDT >									
//	        < 10AK893cN27UM90prD6xwqDt45wEY6lrs40xN4xs5P6K3ab9Nfdv6ZDmacRHqppy >									
//	        < Y0u3uil7xvjDk8tDk7TPYvWTpc4qQ9vYeJA63JKZpcIjbYp2ypwQr2rB46wSJN77 >									
//	        < u =="0.000000000000000001" ; [ 000033144877472.000000000000000000 ; 000033155943808.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C58F11C3C59FF48C >									
//	    < PI_YU_ROMA ; Line_3298 ; 8w3qQEX2g7ur2G53seHaRqsLBW7sCiYDHUW19VMy9FTketO3M ; 20171122 ; subDT >									
//	        < W44WiO2K7sn3yd8b7x4a5793oVhR5YsJyr28ZHKIS087Kez46TeU250V6D4eII9Z >									
//	        < i7C9jo50Kn7XPseK3RSs6Z9JG3LIhbu3kFn784Aotm2q46M0i7zfS84Fmb52j9D1 >									
//	        < u =="0.000000000000000001" ; [ 000033155943808.000000000000000000 ; 000033166881335.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C59FF48CC5B0A505 >									
//	    < PI_YU_ROMA ; Line_3299 ; 03pVnBIpVtCl89qTHLB269ojL77hcWM8pr0o63e0149f5S3GZ ; 20171122 ; subDT >									
//	        < ZNrf3h1nDwku40ozo64aDArF5d4ed4c3MqILeGaixJQe4DI0wrJM06g5GC45HCg6 >									
//	        < dI1w7qhfpB8nVa40w1UR30zq19458xr1xHhv9RY895P3lZ7I01K7551Mi44BX37M >									
//	        < u =="0.000000000000000001" ; [ 000033166881335.000000000000000000 ; 000033172356253.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C5B0A505C5B8FFA9 >									
//	    < PI_YU_ROMA ; Line_3300 ; m1fQVym4k2Hq3rSzVKLX4Ja6cCCXEM4gjUU7NLYS5hvERlOy3 ; 20171122 ; subDT >									
//	        < TLktvsy1tGCz25N6329Yvlk3P0aYaQ861Iznx2W0vE3pRy51iiOC6Yejpp4b9y89 >									
//	        < 9C9pVcmA8a68V6653Gz0O0e2CydXNGeydK8G0sUmbl11lx9ZKvnXJOqoLu8nGok1 >									
//	        < u =="0.000000000000000001" ; [ 000033172356253.000000000000000000 ; 000033179195801.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C5B8FFA9C5C36F5C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3301 à 3310									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3301 ; e5f0GO1F493ADKzWbJa4svBhG6vl933Rb1N2795B7liUy7ZBz ; 20171122 ; subDT >									
//	        < 2IY9E1kY9j18Mj7iv0ALjllw0pkh34xrBePa2w9LG4eLVFe7Y6jgka79RxDF1qkZ >									
//	        < 6fOU4kWpvY75AOI24bW3ibP1Cn1y6l44N2op6jTUjJcFuCT05zIs9T3gK8uZR2Bt >									
//	        < u =="0.000000000000000001" ; [ 000033179195801.000000000000000000 ; 000033185900809.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C5C36F5CC5CDAA80 >									
//	    < PI_YU_ROMA ; Line_3302 ; w5Y6iLkdhpl805xs918uo6JPaE82hpBs8xKVJ5wAC4W75xYcc ; 20171122 ; subDT >									
//	        < c6vb685DwkmM7Ba824Ai5vhXD7Hs5le56gg6c3rZ94L5LX45opF7SCud2w0T6X7V >									
//	        < 5180Kbj55RkAk5i03D1kVbI3NM5C45f0g9mJIA82G5lZ5vqG5o1aMkRC5nXkl483 >									
//	        < u =="0.000000000000000001" ; [ 000033185900809.000000000000000000 ; 000033192131585.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C5CDAA80C5D72C66 >									
//	    < PI_YU_ROMA ; Line_3303 ; 04xv6HZloi414vxW3Lm1LR79hqjGMIyN2DG23odY8BDUD0I2P ; 20171122 ; subDT >									
//	        < 0w82QR7RM353Zfna8e7eCc9BVpSZLTk8lG7I3IlnQs8yP8Fj0QdnR9355XI8FhIa >									
//	        < KjnY7ZzpKGxJDVHJE4psZ5nIe08850NGOGWSPuKc1B6gCZN7N69n0wxiiWvn4869 >									
//	        < u =="0.000000000000000001" ; [ 000033192131585.000000000000000000 ; 000033202548091.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C5D72C66C5E71159 >									
//	    < PI_YU_ROMA ; Line_3304 ; K0oQ0jyUUuT2lCg87B911g32dsIs7we7Zn8072x8V5B1f7910 ; 20171122 ; subDT >									
//	        < 7aTlqqZw68UwXWWoyL51C0ccAYTIk2Mv861ykLg9QZLNleE6gKap3ddxnm4w2eWm >									
//	        < Nb16Rh38186Kt966TWW4468fIl7Ye4CPHHBt2tssRxjGXz623P1lU9K56qs7gl2w >									
//	        < u =="0.000000000000000001" ; [ 000033202548091.000000000000000000 ; 000033209074656.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C5E71159C5F106C9 >									
//	    < PI_YU_ROMA ; Line_3305 ; 0HzMx15Zm891Kw1Wkv77HNk6dPQD9crm8U7FoEhu9AiIcpGu9 ; 20171122 ; subDT >									
//	        < yCAg1fJ6Tpvo58y1cZxfpPW0TH0d6o88YmtN9GKH128tMuJ8KAYQe4bkMw63FdJ7 >									
//	        < SfvZT89KdTWHgS7Mtqg8cukEUZqKxo37T65f1948voA7D2P174u45K20STLwQ9Go >									
//	        < u =="0.000000000000000001" ; [ 000033209074656.000000000000000000 ; 000033222863415.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C5F106C9C6061105 >									
//	    < PI_YU_ROMA ; Line_3306 ; B78jX6c1mCw7uLBFc7q5mP7cbA66ZSkEXd3fhk4OPU44Lb64h ; 20171122 ; subDT >									
//	        < euuq3k2au7y1COWuzrJ0bPx33n2H555Ph40jjqxPyomC6heFKKF7kEY3Swg1d010 >									
//	        < 7w2f2k6kb06g8wXvtSAvXnc0ZnMJ0aG08VDa563mRBO1dONJDBXJ9uGZ54jg44r6 >									
//	        < u =="0.000000000000000001" ; [ 000033222863415.000000000000000000 ; 000033235487441.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6061105C6195448 >									
//	    < PI_YU_ROMA ; Line_3307 ; k966LBo3O8J37C00ZkV29DD02mh900WDKOm53U2ky20c5s54t ; 20171122 ; subDT >									
//	        < G9sRdWTfJYEU0eU5y54sX1Mgk34fw72U9V0YYr3aGyfLj3pnOi5dyRFw6u86X8G3 >									
//	        < Vco52cHL1KQrpaNQqpQ6LcVuJ60NX85LssPePzSPCqjJ4RN8h7eud837QNp1J3am >									
//	        < u =="0.000000000000000001" ; [ 000033235487441.000000000000000000 ; 000033250006532.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6195448C62F7BCD >									
//	    < PI_YU_ROMA ; Line_3308 ; 4Kqbbnj1E88l1H0RpyQnNQ84X9Or28aEY25d6IPn7C4boYZe8 ; 20171122 ; subDT >									
//	        < 4elvEd6sj8JStso3pG59avw3I7g1nDmIwvq4p6xk8Qq7cWcylBzrz2nR6pR88Cjo >									
//	        < RNnZXE4n3TKnfKsbIyy5nQ7Gv7QQQ4WoXwFs26a8sZeHEpw5Woo250C73RmTh3qW >									
//	        < u =="0.000000000000000001" ; [ 000033250006532.000000000000000000 ; 000033258451634.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C62F7BCDC63C5EAB >									
//	    < PI_YU_ROMA ; Line_3309 ; rL2jJSE4G3qJF0fwmqjlEm107yYfDYXd1UJ6SpV9A3229W71V ; 20171122 ; subDT >									
//	        < brLG3v51udFVROqCH5Y466209MJPh2xTvd6oD9xF5f8y8YtLa71UxRL5HbE8A3PS >									
//	        < k6Fp1DHEOK6gmn7KfIl3In54rmPHDG7hMuEPG1w45GETNd0s9xHew6Y4oo7jMk9a >									
//	        < u =="0.000000000000000001" ; [ 000033258451634.000000000000000000 ; 000033265932455.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C63C5EABC647C8DD >									
//	    < PI_YU_ROMA ; Line_3310 ; 7jnt3oje06eJ9sdq1J3ekYEQ5Prc9l43dT3J501S22D2I3jua ; 20171122 ; subDT >									
//	        < bLM917805Svb9jphE9pVFc3Jsw3Y6wOUwS32m9766Dk221GmH3DMyDT9zwvXwgq0 >									
//	        < oMzPPU43rpylzA8BY3MC2RIS9Rsc0z0j05Hq1Deac5pgF4bfI886N71Y3elDJlza >									
//	        < u =="0.000000000000000001" ; [ 000033265932455.000000000000000000 ; 000033280567920.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C647C8DDC65E1DD8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3311 à 3320									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3311 ; 1pI6l4H9t8O6S6SB1LQp7S4I1XBojScPY8f5Ft0zQ76sBIyI6 ; 20171122 ; subDT >									
//	        < hJUY39YjI2DIs56fk853WVfLaIYx9BrxqfosEuoLj8K4n8x1xY2wdL3hymlmpG61 >									
//	        < 8YR1iRuxPc9Do7pWzBA0XTL8zuS3LX03N83K73bpz5o9gX172JrCW78DStAdnu93 >									
//	        < u =="0.000000000000000001" ; [ 000033280567920.000000000000000000 ; 000033290865055.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C65E1DD8C66DD429 >									
//	    < PI_YU_ROMA ; Line_3312 ; diWl6gc4jgDTPPl80MaLsqYQCn84oUc7Z8hMmd5227f0i5TU2 ; 20171122 ; subDT >									
//	        < GsUoZemEh6RlvOnW4XLX09xK58f1vHH6y0808jJ50qz5tD4RNeGPOO1A7H333ffo >									
//	        < aC3gFXniuIQGJd3cw8y00wCSO8xdCxEZI02f128WwrM076w1g9vDLk4WMh1p58RP >									
//	        < u =="0.000000000000000001" ; [ 000033290865055.000000000000000000 ; 000033301209695.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C66DD429C67D9D09 >									
//	    < PI_YU_ROMA ; Line_3313 ; wMZRHw1JTxt04nKis3z6TzN98fKISB7CamD41yGqkwH9N7tJS ; 20171122 ; subDT >									
//	        < SBfdR8E2g5ulpz2IJ0j584Qi8FM74cqTAa4TjF1Du1r9lq49tOVi1phW459DdN2I >									
//	        < JLr92rcGb08DFnRn3Jx14D04dxg20MSZkCLBLivYYbjYH7M9k3Sy1MjpwLe212Ln >									
//	        < u =="0.000000000000000001" ; [ 000033301209695.000000000000000000 ; 000033308782181.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C67D9D09C6892B0A >									
//	    < PI_YU_ROMA ; Line_3314 ; 3wMBv4X8fi61A5s095zNY95U12Wu1h8H1f58aL42r5V5VdGbj ; 20171122 ; subDT >									
//	        < UEH9P9n3a0GYYCq46C70e0t951v2441jCsvY4zdxi5TExuVhX9fqz643PoeJPCy1 >									
//	        < 1tc0VsQO8UmPU7VxYiGaAN8mlMeKy4n60A0Q4EED1zFs01kkT13Ng3Yn1dY5g0Ub >									
//	        < u =="0.000000000000000001" ; [ 000033308782181.000000000000000000 ; 000033316314050.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6892B0AC694A92D >									
//	    < PI_YU_ROMA ; Line_3315 ; BwO0YYpKXZ09i9hh0hoZ1dB9ix55o43s5RCpT5FN34uE1caNF ; 20171122 ; subDT >									
//	        < x7e298SY27E27k8zc5iTBWPjsqMx6MEcAw0If084dKuFnP596tKG1CBWZXU9Vdki >									
//	        < h690qhlB3PwJ97LVv4aV0mx3L4W2SBKfHHSc0vYbd0fow7W18wp03wL8Lt0Pjs32 >									
//	        < u =="0.000000000000000001" ; [ 000033316314050.000000000000000000 ; 000033325853482.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C694A92DC6A33784 >									
//	    < PI_YU_ROMA ; Line_3316 ; AA61ns4QQo667lY1tuMfufU9ym08G4yO2pasO0yjupu8u00lV ; 20171122 ; subDT >									
//	        < W49iXVuzSiX64c56A6bnA4icEBCLzu2xx5RmLpa8ByW7h86XwPY2W6hbry6qo4NG >									
//	        < hYy0v8NKWNPD6F784Us2mFQd33Cx7m86KK1F9thzQ5wQl4EgzX9Nh4PC7A45an6K >									
//	        < u =="0.000000000000000001" ; [ 000033325853482.000000000000000000 ; 000033338847725.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6A33784C6B70B64 >									
//	    < PI_YU_ROMA ; Line_3317 ; j2Oz39UG9xi8xg1IlkEISDycB24EN2mt7EnnMmXPgdx26hdP7 ; 20171122 ; subDT >									
//	        < 8oc9Km6E4g72GrdxARUTNcg9471VpUOYSIec784Q3hQ9v1Wv4os98s8D25NC6W3T >									
//	        < CMFi7abnjHAIo4nlIRk3mxMO6KY50oYC0SlhVG291u0TY6xTTfT8Z3S34728P3w2 >									
//	        < u =="0.000000000000000001" ; [ 000033338847725.000000000000000000 ; 000033348094405.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6B70B64C6C52760 >									
//	    < PI_YU_ROMA ; Line_3318 ; VC7Ar6342TeEKH4fe4SXYM3MSZf4h7K0FpNPgD2gcib02Rsb1 ; 20171122 ; subDT >									
//	        < F965BMHPQfIMz8yaGDYxi000o118x3QAIzUU1m7rJWKyCb68Ef8GAmRh1E20N1aZ >									
//	        < mHiSx23ALmvitRDB433rrO536SaEWMprepp0o01D5B3jIA126Unp0u0zZ2Hq1Bxx >									
//	        < u =="0.000000000000000001" ; [ 000033348094405.000000000000000000 ; 000033359880091.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6C52760C6D72329 >									
//	    < PI_YU_ROMA ; Line_3319 ; 6Az7vLfZ1x06U465GU3868qCL6x9y1B6NWn01kWl5pGansH7E ; 20171122 ; subDT >									
//	        < DF1j479Wa46S8UaHoxGaY8o7C3P908TzZ698hcX0Ye1Osjqrj6J4W5vfA60Q94lE >									
//	        < cF1b835LpQy595i33xkh71PeOxnqV4Y6rg255TOVd53oPG4634d7YehVd7O8ER3x >									
//	        < u =="0.000000000000000001" ; [ 000033359880091.000000000000000000 ; 000033366013976.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6D72329C6E07F35 >									
//	    < PI_YU_ROMA ; Line_3320 ; 558zoZo2FR7XICK6UAU6DqT4P5I269030CBbDtyEr7Ca8kWmb ; 20171122 ; subDT >									
//	        < Y0SB19n3TLp9R4py86G32g70Q4HDw6FG0dFDZTcV5Pe9CVsYMXC943rPQZ5nbrR4 >									
//	        < 6ne2OVP5O8DW754CehCcbxr2669KE36NGbF498pOQcTeyHFk4zPc8899Yans22O7 >									
//	        < u =="0.000000000000000001" ; [ 000033366013976.000000000000000000 ; 000033375654798.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6E07F35C6EF3527 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3321 à 3330									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3321 ; U1Di3goyRViOIaHPqg8XN1b1Vcp8WhRe12z892UQWfH15S460 ; 20171122 ; subDT >									
//	        < 8BQ10FC5077AM9QlaqaoY9JFx8F7MZRG6tKg4uksOidt0UO4rsVP22bPz9MlPwrH >									
//	        < 8346Be7I17huV19nkWou234RzkJEp9AkU9u3pdGnA4wiG9eAWAYULlZDYd04WaCP >									
//	        < u =="0.000000000000000001" ; [ 000033375654798.000000000000000000 ; 000033384593143.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6EF3527C6FCD8B2 >									
//	    < PI_YU_ROMA ; Line_3322 ; 8S14t29eaT66nZ379ws0TYa6ipA5GgObVvWdkxz1Clt4W74P9 ; 20171122 ; subDT >									
//	        < yvFrImFrffsRVWz3QSF92F58ix56pUc2293OP76U2PM1I623uBOSQ0Op8N7bAMxk >									
//	        < 8t2BHIs9K3d0nb93S7JZA8dx7Mmy5VEWcp30cecUcJFpA3lCe2axlx0Tn44taFHD >									
//	        < u =="0.000000000000000001" ; [ 000033384593143.000000000000000000 ; 000033390515364.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6FCD8B2C705E210 >									
//	    < PI_YU_ROMA ; Line_3323 ; XN51pCKdNaxyyxsXti0O0FSPmE4MxC0II0VN10kHaP506f1qq ; 20171122 ; subDT >									
//	        < Yd0cIFN0697jn8a2b8Lb5pXyYatLvrd6401L97ua7X3ah32f537cG93fY1ykk4R1 >									
//	        < BhRjhG40a8M5S7021P7JDNy0SOKi4Y6Wx8GO7Sol6r3wDC5QzzKoM8H9QHkYi24R >									
//	        < u =="0.000000000000000001" ; [ 000033390515364.000000000000000000 ; 000033403373838.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C705E210C71980E7 >									
//	    < PI_YU_ROMA ; Line_3324 ; 0i0kVyY882ww4921p7HXdk5UjBDykwpqKFO178rmDClS40E0f ; 20171122 ; subDT >									
//	        < hFAVbWPFAQubDxH6Ev1v5VECIrzha3w0tbWBG1wSQ2a6GjsY0Lm3FLFq0t7mb53u >									
//	        < hgkBdfpKnZ4tU8Gkbp1qHl3gzTb7987sj2Lty1A8p6MuSh5TZUgpBf1rYh8w8FF7 >									
//	        < u =="0.000000000000000001" ; [ 000033403373838.000000000000000000 ; 000033412331129.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C71980E7C7272BD8 >									
//	    < PI_YU_ROMA ; Line_3325 ; c7v5BloX50we5585lbQlfb7kI71MVVI3L7Flyu96I0JYpoA9D ; 20171122 ; subDT >									
//	        < 4H4RDdUSnSsA2I03m8r0E01foWcqI5Q0dJ8497aqh09KBM26N68X7TPIC086n6HB >									
//	        < lNBQl8QB26vH6KgW9bA12ezXRmkmF0BxPnDlacYDbSgLwYqpCLHwDrM4zOmgeMwz >									
//	        < u =="0.000000000000000001" ; [ 000033412331129.000000000000000000 ; 000033417783734.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7272BD8C72F7DC5 >									
//	    < PI_YU_ROMA ; Line_3326 ; FGLOm1CGTzVsv65drhHBmn0576Jx1Hi3r55ef9F14KOiB802B ; 20171122 ; subDT >									
//	        < 6t4b3O9MYD9e866tSbbZ4Y4C0GJ9DQ0k754Keo6Lz6PT6D61EQuUVzu2vg896a41 >									
//	        < ejfjt7fQwLw1e955OKLcD8XMZ8L67Z5tkLdHA6Yzo35vU2xoVsX013Rg4ypLfyFE >									
//	        < u =="0.000000000000000001" ; [ 000033417783734.000000000000000000 ; 000033430141607.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C72F7DC5C7425910 >									
//	    < PI_YU_ROMA ; Line_3327 ; RUtY4OqCF9MJKXqV21w96t5r28LAz7TH17m94lW6E49l8go7T ; 20171122 ; subDT >									
//	        < 7nJOe2Zi05K2hp5yc92Je55SXxM8J5zn29Gtb26s8s1fa4RMfK8PZtp9Ct0bZkQ5 >									
//	        < EJU753cfr5YUtfM48bE6jC6Nc67zFBXx4sZ231ZON8w471yqJ4viKrWqpmG75s8l >									
//	        < u =="0.000000000000000001" ; [ 000033430141607.000000000000000000 ; 000033440592728.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7425910C7524B88 >									
//	    < PI_YU_ROMA ; Line_3328 ; J0hbt761k688j59mP05n76f24h3oE698w7LlQcr1zmfA7Ra49 ; 20171122 ; subDT >									
//	        < 3dhetPUH5Ith7bgVTYHzHjtz4VY074qpM6OmA71O59OHl2vcX7He108u3435A4qg >									
//	        < C668h06gHb8jdurYZ08XK5Btj5b7RL8WLF1NMbD517yt8a5V5Aw0cmmLn0m8JWLN >									
//	        < u =="0.000000000000000001" ; [ 000033440592728.000000000000000000 ; 000033446554334.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7524B88C75B6449 >									
//	    < PI_YU_ROMA ; Line_3329 ; 4tsD9Pt0HE5ClwtNgZfDMFP65q6tBc7tT1J1wOZO274lv7iRY ; 20171122 ; subDT >									
//	        < 7wZ5goo09ID002TM3vi1KXAN0I4kAysy6ln3xxsH1OcYrIe20SoE3az9H7EM4NCZ >									
//	        < 5zA65zM67Y53BUU1DP7qF6vH0WWhO47Ihz9552m3tqMys0K80fV0bPWRq93iK2EJ >									
//	        < u =="0.000000000000000001" ; [ 000033446554334.000000000000000000 ; 000033453450546.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C75B6449C765EA1E >									
//	    < PI_YU_ROMA ; Line_3330 ; QO7a9a1kSFAQ95T5I4eEu1oNXrcH5151OD20s440bC818kg23 ; 20171122 ; subDT >									
//	        < V7ewmby5104EBBXZCcB1UXJanI6tqjwEW9168SCvL04182c73LDz2Q2Hm25PcEB4 >									
//	        < hDAr663URilcIi8iKqpzPT00jhm51niPB74tPgxw44f8H47H89EqoFNCKeOb67F5 >									
//	        < u =="0.000000000000000001" ; [ 000033453450546.000000000000000000 ; 000033466366022.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C765EA1EC7799F3A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3331 à 3340									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3331 ; 8suGK46721t44K9C69DJ6Lm0lenDJypEp1GJF2iaxGfW995KT ; 20171122 ; subDT >									
//	        < 5d9vyj0sYPfLhv2TvkJMy8FKT8IOr1112xywS45M4wseDXVQ15CkjOYXskH3q5a8 >									
//	        < V1HNX279yzF4h74U140B3ih6PKuiOJEp0Abj8HSyGYfjiAAt6f5ye1Mf4584RAa3 >									
//	        < u =="0.000000000000000001" ; [ 000033466366022.000000000000000000 ; 000033476716601.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7799F3AC7896A6C >									
//	    < PI_YU_ROMA ; Line_3332 ; Y1EIu3li55pZAF63h0YHWNg6Z48w8Y5v32880626bKj4J1r9o ; 20171122 ; subDT >									
//	        < L13zNvpgP83E4259bam6q0k1eefHDzNDLFJu514X8OoTf6bS09IhelE243WffRLT >									
//	        < IVZa26f0lpRBVFX81zkI29273jp60zIQ0xBnzZMx52fVga4zIQ9mgLbb5QwRkZ82 >									
//	        < u =="0.000000000000000001" ; [ 000033476716601.000000000000000000 ; 000033484231023.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7896A6CC794E1BE >									
//	    < PI_YU_ROMA ; Line_3333 ; 34d8192zv5rMOwXu14U6e8glEzfnwZ4w9eq80fXpT0YCt0N16 ; 20171122 ; subDT >									
//	        < t8A60V3JQBK5Ya4Wy6zy0l4xsvkFW0cD1uhvuL4WX6Z8cj701MQKCOdIYJxSN3Af >									
//	        < GIyHY3b5YA1ei7G2eT4E9h6BH53jUMbgHxb6FX6Ol491zLtQ3ji8a274e89Gc2xm >									
//	        < u =="0.000000000000000001" ; [ 000033484231023.000000000000000000 ; 000033491635809.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C794E1BEC7A02E3C >									
//	    < PI_YU_ROMA ; Line_3334 ; b7gNs550Sy2U1BnuV3ai2HgWmXoJNj9gS6zgOEYfW2U5AjSk3 ; 20171122 ; subDT >									
//	        < 98v5zQs0c4P2uR0IfmXr1T6k753rgB3yVENA767hL88HvQVeUSST3rW95vY4ef2O >									
//	        < UCwi771Yh0DGBPF9Cjg2Rt8uDa9780bg7LIuiTgv3y2738z841h3a62xHke3Lgle >									
//	        < u =="0.000000000000000001" ; [ 000033491635809.000000000000000000 ; 000033501339868.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7A02E3CC7AEFCE2 >									
//	    < PI_YU_ROMA ; Line_3335 ; 7Y94s7gG07RTx86BzhpU2o10Xc7Ah4y3cIDw8Iq1I56NzgZU2 ; 20171122 ; subDT >									
//	        < 6dm579bVywW5rY9cuQNa7EzztC3p6RvuUNeKMOy43Ww2b21aPan01TF8413uCg9G >									
//	        < WT7i0Zbbv3RNBnw668KqMh6Yps9F4ckbLv40z985KLDHF38eB83q746zhTeG5KHc >									
//	        < u =="0.000000000000000001" ; [ 000033501339868.000000000000000000 ; 000033515395914.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7AEFCE2C7C46F87 >									
//	    < PI_YU_ROMA ; Line_3336 ; SF3711cE60sJSM4Z7uHLd0PK85EM04Ux87U34mlBcqQYa6gk7 ; 20171122 ; subDT >									
//	        < gx9VO4a51S9m029DjQvLv21e6IPR35O5x1JE7lBzMreo4BI55f0MjVGrT2slzoCt >									
//	        < zir609KGd1r2MeH47y22yBjj3MDdnA2oPAMC6t7MzfvOdjs4XP728Mhj3mhgrSm4 >									
//	        < u =="0.000000000000000001" ; [ 000033515395914.000000000000000000 ; 000033522797671.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7C46F87C7CFBAD7 >									
//	    < PI_YU_ROMA ; Line_3337 ; I00lHKyDK7xS24Cb2mCfhoym2Q546J0pT8X426lC968jnFB8a ; 20171122 ; subDT >									
//	        < q3UUK8BCu4ikaWA2076pbP50dgEuuD702P4i0Q44q4QvF1dcBR51Gf5bty35tQax >									
//	        < 2iC9dtF6vfCVnv1Gi6q81Arqy6w9HdoZ73jBf07C0AP0r13OQ3z2U1fW66I2ojp8 >									
//	        < u =="0.000000000000000001" ; [ 000033522797671.000000000000000000 ; 000033531971719.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7CFBAD7C7DDBA73 >									
//	    < PI_YU_ROMA ; Line_3338 ; NHvg54Rn2SCMa6Dkvg3JwZ5Tg802f33vPLXYQsk746Z4nh49v ; 20171122 ; subDT >									
//	        < 1fhH08fidY9dFYT1KjN1E713dmh123ye25AhtXHwUpkD7N6JX252LWsNZDwuUV4L >									
//	        < Fq8WN56rH6himfoZE576tU0H0zdtnih0244Xh1z7S72b25624USkMzN3p66Uv6Bm >									
//	        < u =="0.000000000000000001" ; [ 000033531971719.000000000000000000 ; 000033542842112.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7DDBA73C7EE50B3 >									
//	    < PI_YU_ROMA ; Line_3339 ; 13yF3Ofx3cHqIyHLREplJgRf1lQG5uw4f7VoIT551Pb96MO29 ; 20171122 ; subDT >									
//	        < K5n1K1dwP2B0GX3P691dCL5zasct543zH1Ph2Z7Gewbj23M6Vbdluyo7QZaV5YUL >									
//	        < iiBMaG93t93m1I1vgDdeGB86s47H0vV4m6E1VIDd2yG25i0Nkz9JjTg74RbDf5Cj >									
//	        < u =="0.000000000000000001" ; [ 000033542842112.000000000000000000 ; 000033548172381.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7EE50B3C7F672D6 >									
//	    < PI_YU_ROMA ; Line_3340 ; EtkM0sUDTRLyg2FtC27h0gblNDz4PdUr6z3H5P0XxDL3yIvs9 ; 20171122 ; subDT >									
//	        < 8lDZlPycw58nrhvc1wS6lX7j05nH8BcPmd7UG84sdsV6f212Ptjd6CFv1Rc8pNX8 >									
//	        < BG5aQZz0V3bN0ICj732LdwO03Mc2o3AXu53yLX5rYwWD000CXcw3Q8mZRT07tlLM >									
//	        < u =="0.000000000000000001" ; [ 000033548172381.000000000000000000 ; 000033556804327.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7F672D6C8039EB0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3341 à 3350									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3341 ; 6mtABq6y2l6K5pC80xaHTuM4d40Od46MsRCF7Ae5O7G4m25LG ; 20171122 ; subDT >									
//	        < WAt1qn9Gb6oo01QP31EMdDnL3SDbWns6r5aC140c0xDA5GT8m1x09U3w38FQ3z4A >									
//	        < 6I49WXhRwZYfO831KLtkHO3zyd7SBPir8tawMYVkcJD2HHZAewrBO9wlGL8372cK >									
//	        < u =="0.000000000000000001" ; [ 000033556804327.000000000000000000 ; 000033563646411.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8039EB0C80E0F61 >									
//	    < PI_YU_ROMA ; Line_3342 ; JjRSHcHyJwij7637lbBAx3FrXOE5d3Ek8Yt6gF9DGL7UfXW86 ; 20171122 ; subDT >									
//	        < zgIxjv8IpgPoirkp4XJw2TR91iixzj3C1q0GTT8pM37dMr0Wh47ZSvLM24CiKkfK >									
//	        < 92mH11uyVcUWlC2G4mF2SKNlu9Am549N4mdzHrN5EBql7e5Y3xFvs5774vZ9MT8I >									
//	        < u =="0.000000000000000001" ; [ 000033563646411.000000000000000000 ; 000033575960944.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C80E0F61C820D9BE >									
//	    < PI_YU_ROMA ; Line_3343 ; F8XZSzG5SU9EUi67KSV2780PZLcg2940b8O5Cp5JJWXORuSnk ; 20171122 ; subDT >									
//	        < ID2mD10qI5TFAvTCgeUcBA64Tx81Uc0MsHz7YaFuEUYE55J8DDw1T01ViX5Kn7WM >									
//	        < 655JjjDR8hrOG2IfpFq86x3n1Ph76MrR2567x5NS3e8gZk9AB1e0yn1wvO1x9bgr >									
//	        < u =="0.000000000000000001" ; [ 000033575960944.000000000000000000 ; 000033590331545.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C820D9BEC836C742 >									
//	    < PI_YU_ROMA ; Line_3344 ; 4msa33iznIv3h4R2XLHq8obtxBB334qBP1Mj4Rz4oqkEfcG1n ; 20171122 ; subDT >									
//	        < 25f2653BoSZ3P11a9vRK9K6xSjzw92zNi0PbD7vgPH7q3T42Na7yr35y09YIvKw3 >									
//	        < 1BZh0I557nUvoX88587b56fWG9VzBfK26579rWq04e3jaeYXk0iSjT2Ll1FH18l6 >									
//	        < u =="0.000000000000000001" ; [ 000033590331545.000000000000000000 ; 000033599068226.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C836C742C8441C06 >									
//	    < PI_YU_ROMA ; Line_3345 ; 42IgD4z8XGvJk9LSW4i6hx41fkn33ZB6yX8JbFBc3MK98du55 ; 20171122 ; subDT >									
//	        < P6dXh9cinstcK8W65so14OWiZsho5N5jwSG0SPNDhOuEzL289I9W2W18kj3yVlLZ >									
//	        < TWkAeorR99vSP2OP8TrnkxYc4F9xn4P4bSq68hAoctf1NFI9Bcz73hUGM3742VnQ >									
//	        < u =="0.000000000000000001" ; [ 000033599068226.000000000000000000 ; 000033606764135.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8441C06C84FDA3D >									
//	    < PI_YU_ROMA ; Line_3346 ; U9sJ5MgDSwH8eCQ1z5ag6s862wqYQTnFFRK84rNE4vHtZsTu2 ; 20171122 ; subDT >									
//	        < xf2RV9fxidRDsb9s5uC6f3x7Wk3cItclXZREas427f7cdA52TWI6chjKhjwZ4JW3 >									
//	        < vD45kw083rYhy5ehD1F97OD0F2x3LB6h1D2A4S1Y750a89K9ET1YpkV55tg0Gcsr >									
//	        < u =="0.000000000000000001" ; [ 000033606764135.000000000000000000 ; 000033619638246.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C84FDA3DC8637F30 >									
//	    < PI_YU_ROMA ; Line_3347 ; vt39XR2f37Jw0CIFAK896m0sNmyoPaHg1L6pg76I97M0bC9pF ; 20171122 ; subDT >									
//	        < Uit6o95V7RtOQx65HdY6P4ecTfy1P97aqgx2cb53gG63LoAdZsu9Myb082HzZb8d >									
//	        < 266813N7XKNhd7r19pArNgo52fRgcreH6ToRB6W0Hr6039zippMED58l2H4fLf98 >									
//	        < u =="0.000000000000000001" ; [ 000033619638246.000000000000000000 ; 000033633110994.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8637F30C8780DFB >									
//	    < PI_YU_ROMA ; Line_3348 ; 7mWo7birAYI3xqJTdE30AiFeu1D3ps4xFyDhY7xc1R28ZncLM ; 20171122 ; subDT >									
//	        < 92718m3UsYal4MV1AZIRA6X3Wt5ru5M71iE3u6Lxa5mgt844y9Hy71I87W66wX69 >									
//	        < 19R61oJW8vK8Ev1v6U3sT8x1RlaS06aeumWW30SGKGjIpc1t5Ecg9o2e69BUObbW >									
//	        < u =="0.000000000000000001" ; [ 000033633110994.000000000000000000 ; 000033646759106.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8780DFBC88CE146 >									
//	    < PI_YU_ROMA ; Line_3349 ; 8tS6Qy8BdlzHszsE3UBGLaCBzX34X9jEBX6OO37xu8DEr33wi ; 20171122 ; subDT >									
//	        < fd40jwTu7CLlCr0um8pzd44ryDLRYp22FykLXkMCRVKIa472F7Dp2TR8lFARhhTa >									
//	        < 1g7sK69hEi7VKF3NdmsEH1W502Rh79TSg6Q034TuiG3cwhp5Y4dwt0rOWW1pc81A >									
//	        < u =="0.000000000000000001" ; [ 000033646759106.000000000000000000 ; 000033654982807.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C88CE146C8996DA8 >									
//	    < PI_YU_ROMA ; Line_3350 ; 0BMG0deWBLUs1MQyZTDPHm54r2uBS1RmAl4LBjvEDGzJ4Vd6B ; 20171122 ; subDT >									
//	        < y5ooFlx6j45xYgQfnFkPk4gdLQ52dYc0Yjb6w2zror396c35B15O8S5u643N3Mll >									
//	        < ZT6hW67QHeFj6VZfsLOn202h906dBZ9X6bk85h6x955U9G7dq17YhUtjkIzfEqSQ >									
//	        < u =="0.000000000000000001" ; [ 000033654982807.000000000000000000 ; 000033667612790.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8996DA8C8ACB33F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3351 à 3360									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3351 ; F4VX9ASbSi8C33t9I4o0h066Xz9iq0652V5z2iWmtVno9VBok ; 20171122 ; subDT >									
//	        < 44xiWY2rO46SCm722358Y1IH6rszpj2pDB2jHDFp023mM0By6ToGcBsm079K0mH9 >									
//	        < lJEsNreKhVThLl0tqCp3S34072sWumkpA4n0v95qz26A6409wBdxQQd51arqO7TD >									
//	        < u =="0.000000000000000001" ; [ 000033667612790.000000000000000000 ; 000033675716999.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8ACB33FC8B910F3 >									
//	    < PI_YU_ROMA ; Line_3352 ; Cs63d8e1AozZ4X9uA5AE0FO8ASEi0vvUve4mb6q1cU6v7fr9w ; 20171122 ; subDT >									
//	        < kMt2MKoc1k05547szlY45V0m6PzHb3kTmBFO0k3XTBgSwU4pt2ilJ3had0V1e7YP >									
//	        < 57ZOkTT9sh4tPCG02n0fLR8A5EvtAwzvZ3lV04HG0d5nO2j3G4YTIKDlcbI1D7Ug >									
//	        < u =="0.000000000000000001" ; [ 000033675716999.000000000000000000 ; 000033690150942.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8B910F3C8CF1736 >									
//	    < PI_YU_ROMA ; Line_3353 ; S8kR4q1ZD2WkiImiW7L7r27Rtt8xHII9O684U1cxjy59yrx54 ; 20171122 ; subDT >									
//	        < k3Wfl35nnpz69686G6eFAS8l0vG03wRkXd2ObN9j2ocGl43B01dx9H5aIBna3152 >									
//	        < CtSI0Y707xl8Q0nB1zxa0Dc0bIkDYDfBlXkcXhhj5fXT8162P6Xe0a0h35ds8W0E >									
//	        < u =="0.000000000000000001" ; [ 000033690150942.000000000000000000 ; 000033697498888.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8CF1736C8DA4D80 >									
//	    < PI_YU_ROMA ; Line_3354 ; C1cUu6d6618538V30tSs6uRxt5lFle7WJ1jNfaXx92Snw7wCo ; 20171122 ; subDT >									
//	        < g2I2YuZi9354833xz545xsUYwX09lB5ZaFCeJUFk1w51kurJsxJx6e6q9g41yXxF >									
//	        < mmdOt38D999wF6xQWm80We6bl98orx916S28svS282C7qemjwYh4dIjkwpq5kx7D >									
//	        < u =="0.000000000000000001" ; [ 000033697498888.000000000000000000 ; 000033708743508.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8DA4D80C8EB75EE >									
//	    < PI_YU_ROMA ; Line_3355 ; vmiaH53VyIcCq7105Mr15fw4Qj5f8nD6Nb1tzU28kp1l4fLJx ; 20171122 ; subDT >									
//	        < kEKIUPC27oPb472Qb2L74288x5DSpc9SusB178LZV7G4nsOiW0nWdIFukRj0fUuG >									
//	        < 8Oa0hJDa7u5P30W4Bi44DdOr0P9hDF95016E2GFz0LDo8lEClx90rx95AklVSuNK >									
//	        < u =="0.000000000000000001" ; [ 000033708743508.000000000000000000 ; 000033714723891.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8EB75EEC8F49605 >									
//	    < PI_YU_ROMA ; Line_3356 ; 1681J64s21b9A63CaExMin3505f1XrG918TCWx30fqSq1iPeb ; 20171122 ; subDT >									
//	        < fKuDDHH6EmRnKpiy3Bn2Uh7blK7c499NVpEJbhGmvshsESMGZDfJxlDM9U2RWvF4 >									
//	        < uIG0vt4z4UQSBWByM62bVweC8nO1Q5Ojq9d0eKmvFi2kkWPfl2IHXt0DCt5aLoy8 >									
//	        < u =="0.000000000000000001" ; [ 000033714723891.000000000000000000 ; 000033727355452.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8F49605C907DC39 >									
//	    < PI_YU_ROMA ; Line_3357 ; iDWSMROi51aWpS7l5K8XA52oN4N03g6PO72v34heK0V7fJ6AF ; 20171122 ; subDT >									
//	        < y9GmipT67682mO6taA40t4K4D0PWW4KnJYqq5KZ11GlZASkP0X5drghel6VzTSdn >									
//	        < 7bgI8C901Z93VM820YzB5Eqp42Y422L7sUT88xwj17p0tO9nsmv9UnunC6v13IXs >									
//	        < u =="0.000000000000000001" ; [ 000033727355452.000000000000000000 ; 000033735651617.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C907DC39C91484E9 >									
//	    < PI_YU_ROMA ; Line_3358 ; U7M8cKswCttQbbIW3Tj9AsTy7r951D07ZPHD0gj29kOsbzM5p ; 20171122 ; subDT >									
//	        < 8Kvsa7X1zoCcVZY2QA12u2e7l345gk87X0MKv9Pn3E5n3jRM5sjtqJS4BgfFn3k5 >									
//	        < IuBQsfA620d524Qrr7KuW16AVRL1q2oAowj4K2u3ohE82rHCHMCg9E4443nRokw6 >									
//	        < u =="0.000000000000000001" ; [ 000033735651617.000000000000000000 ; 000033746766390.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C91484E9C9257A9F >									
//	    < PI_YU_ROMA ; Line_3359 ; 4B9r167M9RuIOWNp82J8ek5RL4N8mO5X4BJpyjST8hqnx2eg6 ; 20171122 ; subDT >									
//	        < ksV9CFBwt73qqBHEX5CQT7K1Zx2l6I2KKqwis4GkeV9wQ7EKKw771nK47UJHqF2P >									
//	        < NeupIGiPHi9J0UJ4TIlW8XVGmQUv1Oc7pL7pv3Q7923x5J5navi020wAgwok9YRV >									
//	        < u =="0.000000000000000001" ; [ 000033746766390.000000000000000000 ; 000033754330676.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9257A9FC931056B >									
//	    < PI_YU_ROMA ; Line_3360 ; 7CKVnSLx5F29dqr9GiVMbhpU7SQECz6w6wMYYe9cu2WnSG1c2 ; 20171122 ; subDT >									
//	        < q5I14CjIl1LtH87G12d8AF280f1v74Df7n68cR5O3I12r2m7FI6zHKKaSAN5dq06 >									
//	        < KD4Nslmlqnvu73kKsi8TYjS6f9vsvH5xsS70l5f6KAPWOV9WnNf1Mm56Z9OJQ21x >									
//	        < u =="0.000000000000000001" ; [ 000033754330676.000000000000000000 ; 000033761134334.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C931056BC93B6719 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3361 à 3370									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3361 ; VUQU519AZh1Wm593QXhUF1om7Oz996mWhT7SQ4Fp4o4t00216 ; 20171122 ; subDT >									
//	        < nP6y7KRVo0t3r01zu5jsF9xguMcP53If6Lhw1iNMzNH6z47Sy65LC6sa62EXC3Wy >									
//	        < fOB967G0lMka7Mz785I3h4yZSdLAYK726V3YdyptJb0EGg0C72Oq5zXbWY7g04N7 >									
//	        < u =="0.000000000000000001" ; [ 000033761134334.000000000000000000 ; 000033769602829.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C93B6719C948531A >									
//	    < PI_YU_ROMA ; Line_3362 ; M8917RInYw3KYXRul2jlZ02hok1rlZb515ncV2J3q1a4g2GjO ; 20171122 ; subDT >									
//	        < 35hig1FH3uo8INmS2z9sf8iiuG2MD15mG94GaQh9s1q1Ns4HGcrQ12q71T4eOFDc >									
//	        < 0EW48KugQC59QJIWrbn0pS79O1i001J3gEsDR9pY607yHD8KUKDrt0D5eypX2doH >									
//	        < u =="0.000000000000000001" ; [ 000033769602829.000000000000000000 ; 000033775335056.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C948531AC9511241 >									
//	    < PI_YU_ROMA ; Line_3363 ; 1Xx6C886zYj24eT26Oe96mx0C4MZS8JFEhq6Ps1uAa5oYngAA ; 20171122 ; subDT >									
//	        < 7611LP2y1SU8h8IPYY1vLAI6EFIJFgyG52xfR52b35Sa0M1El42SS3l353alrtQp >									
//	        < YjHn96bL2ozO662V8P527235N42b4y99I3G95t7KZn10k6auH3oQG448fTu5VZeX >									
//	        < u =="0.000000000000000001" ; [ 000033775335056.000000000000000000 ; 000033790314188.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9511241C967ED7A >									
//	    < PI_YU_ROMA ; Line_3364 ; 4B1zo03gJ68i4AzT0oQ8e1EIqkDi2xrBX4NozsPbxi4ru3jC2 ; 20171122 ; subDT >									
//	        < OfxJ4CFBz7QN2bM3y7aZNEkgm5KRSW8xXji6goB27fOSn15O726j37rVz8aMZ323 >									
//	        < 00XuHE8Ck4NGv0oq9uO5q4HS780HjgtfkZftP0v0ROaOzb1KVKTNo3sZU1OwmwH5 >									
//	        < u =="0.000000000000000001" ; [ 000033790314188.000000000000000000 ; 000033802529106.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C967ED7AC97A90EE >									
//	    < PI_YU_ROMA ; Line_3365 ; 4ta2u67EmtXA2vb7840e2qIf0lVN6GZlv1F6IwGt2nN05CZP8 ; 20171122 ; subDT >									
//	        < DX3a1hAC42CQR8qB2RT8Lvm00R814JG8Yg6B27wU7gCm9ZFFuF73Uw8EHKoyZsJ1 >									
//	        < 8KiTWlkj1CyfkH7w1ZuEE9Nw625WeZoz9xW2TDoBCJLNV98DXJiN5YcFB93V4Pkt >									
//	        < u =="0.000000000000000001" ; [ 000033802529106.000000000000000000 ; 000033812846206.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C97A90EEC98A4F0C >									
//	    < PI_YU_ROMA ; Line_3366 ; M6GzU2326H9Q2Pmud5ka3hJG2BhCc50WA2PP3RWKbDQT7qWj1 ; 20171122 ; subDT >									
//	        < Tpvm4OIDrsowp4u4r8NS2F8W89dlgW0y68Il6c2x4q3LT31G75qW5IxGTzX62m73 >									
//	        < YdHlDJ234jz83w2H539ZuFZmLuO6WQNII49GWv0qvU698wQj38335k2dvl354mYT >									
//	        < u =="0.000000000000000001" ; [ 000033812846206.000000000000000000 ; 000033819627598.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C98A4F0CC994A807 >									
//	    < PI_YU_ROMA ; Line_3367 ; 6xI3I3CCReOfcR341MfLU9Uc3HnPgYxn9eA26JR37Ov995nKM ; 20171122 ; subDT >									
//	        < EbF3H1Rn4Bb0zcxulZZ3Tav37a710e0x5uS6Jh46SW8SPR2SW567gzFAp3IjlH7x >									
//	        < 50J0xMchSN4DO23G6fkENFzBzDeodrqOjvnDu9PxdQ1ACYM0QdCi3R1C9Rm3ObbQ >									
//	        < u =="0.000000000000000001" ; [ 000033819627598.000000000000000000 ; 000033827441029.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C994A807C9A09426 >									
//	    < PI_YU_ROMA ; Line_3368 ; 6m185o8E3r80dWa4U4c2kNVzuRIS8Tx19Z5HaRmb9bn9fX0EM ; 20171122 ; subDT >									
//	        < 45x1ts0xaOOPkKlKBEuX6VxlNE9C62c8pR8lx0CfklPzu767tFxzi5RA8nr5WzXP >									
//	        < 8BCU50l5fbZ1JyE8Sqn684lu24ZYPk9a51lj5Blwh6nMhwClvit0DoIWmNdS3Whz >									
//	        < u =="0.000000000000000001" ; [ 000033827441029.000000000000000000 ; 000033834530870.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9A09426C9AB659F >									
//	    < PI_YU_ROMA ; Line_3369 ; I3OwF48bzxWTLTX8q7H966pHkRCd7R6JA2MH5wR7y95t781O9 ; 20171122 ; subDT >									
//	        < 29b2Xu82xv2cu4qARkzkAXTCCR9OJ1MBuwqvyUD6U1OYd64Z6jxmWe7s4DFN8wQX >									
//	        < dYp8695J5Wgukk1U6FmSUvZ2gPdYe93Yk7b0pE346936YVIrt893hipQ6go6RmAj >									
//	        < u =="0.000000000000000001" ; [ 000033834530870.000000000000000000 ; 000033840831141.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9AB659FC9B502AA >									
//	    < PI_YU_ROMA ; Line_3370 ; o8h75MSA7h3xc4B03QNIN1R7nu2F29mT7b6s94uw5VBb6FeW3 ; 20171122 ; subDT >									
//	        < 37UjP98oB679f47XArwH2YUvdkp4B50InhT2u7H0C51406ecHh1817z5lJ5K1H9S >									
//	        < 3937K6Ht152ICe0L67D660TT39cA7YawG320ZSgFWbTlQw2ezl8yHf2LCtD175i4 >									
//	        < u =="0.000000000000000001" ; [ 000033840831141.000000000000000000 ; 000033850568552.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9B502AAC9C3DE57 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3371 à 3380									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3371 ; u090vww87y6HutZ73I69zNXaV6Bs0xLMAYE0263vSja0jsT4V ; 20171122 ; subDT >									
//	        < x3V6C121fLKyTtUO80pZY14Myk46aby8JHAqoq3V12aEkoimVdn0f7T8OBqXrpoM >									
//	        < 3vd7wKLxmQ7Y4x1GHyTCDl3XFVz0n69Kp5qoV2eo1Ob23q0bYHj50hcEtyb5Yy01 >									
//	        < u =="0.000000000000000001" ; [ 000033850568552.000000000000000000 ; 000033862898333.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9C3DE57C9D6AEA9 >									
//	    < PI_YU_ROMA ; Line_3372 ; 0h6zp5L4Hn9X1ME9ezz94f6C0aD9y840pQo6s9VbYZ6L4V5G8 ; 20171122 ; subDT >									
//	        < 5uh46GV2HlL2lgHK2rrwVM9WKY8QC9Vb074248L6MAg6KuD43X9VpEK6CJ178u80 >									
//	        < h43FZH9FB12BRT3vQ8rt2K1ejqg6QoKeNlLHqo34hTJ6Z3G71vC44qXowA4hxfF6 >									
//	        < u =="0.000000000000000001" ; [ 000033862898333.000000000000000000 ; 000033873844179.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9D6AEA9C9E76261 >									
//	    < PI_YU_ROMA ; Line_3373 ; XKjhx4oUVW0lr872WF9pqYhqqxeNjkdrdQ18n6v1n8m4tH6Vw ; 20171122 ; subDT >									
//	        < zN1UAc1Ev2ww1VPyd0dUMC4Ov2kKxr17pGBb2Y7lcz6r9g0t6zgH5jDg6BfHl630 >									
//	        < 85iSyY8kDg3mRku77dTyk8sExzM8KQc8eweF8pZn6R37pzw8d39Yk3ShgugmZB4H >									
//	        < u =="0.000000000000000001" ; [ 000033873844179.000000000000000000 ; 000033886172678.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9E76261C9FA3233 >									
//	    < PI_YU_ROMA ; Line_3374 ; 91w7KQnEY6g3WH5MK71fDSwBYl9F4QN7HTSfl4fJYhATz6x94 ; 20171122 ; subDT >									
//	        < qz9RZJ1V7L47bTJgEn6f2CQNYgcQFp6fpx40BgfO0051IurM6Tp2J1vo132u1J8y >									
//	        < 8fdNru3E381fI6X60ij32y319OoJ52Xq019N1UL8Zu16rmZ105jW59dEflJqvhaW >									
//	        < u =="0.000000000000000001" ; [ 000033886172678.000000000000000000 ; 000033892949655.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9FA3233CA048975 >									
//	    < PI_YU_ROMA ; Line_3375 ; ieQQ86Om5M1Yil4f0xpW6qrl6RmAyP5YvM911w21WcEmg80WR ; 20171122 ; subDT >									
//	        < pG5Ivq2qn9fcoWwN98pAtg6x3fus9bGnA42F0T916JqJRLs1BM36D5HV6K6J18Mn >									
//	        < 2A4SVwVFH0A28U9xOL0DN06HOGyLXaM81E1D8PPvf3APM6ZK69T2k0AE6JL3neUX >									
//	        < u =="0.000000000000000001" ; [ 000033892949655.000000000000000000 ; 000033902165943.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA048975CA129992 >									
//	    < PI_YU_ROMA ; Line_3376 ; 267XT7LzlLgsY8AeE134N8UeVxGF20rKig1l9ipz5rl2h0cJ8 ; 20171122 ; subDT >									
//	        < Ma64Nt9AYe3leedJGFFL3w9KqFOx1751B9lw7eQdD7UV7pwiHScWW5fYLK1jOp0D >									
//	        < 36C52135Nhki8gA6ZvXm1522r3sXluQ3FiE0N0786oy4q67y1su7p4jEArd1zi4f >									
//	        < u =="0.000000000000000001" ; [ 000033902165943.000000000000000000 ; 000033916425389.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA129992CA285BAA >									
//	    < PI_YU_ROMA ; Line_3377 ; HgE74roILUw2W4rP9wMXPGKh0k9QgY016IT63GnFKUi7DRd5p ; 20171122 ; subDT >									
//	        < E8h35T3l11a70QQBULKGnjW54CjoRBIVg56XWhpxJB1b70BR0LK9x92f320B3CT1 >									
//	        < j72Yuc3Ky2gnblv8ID8O1e08qXeBVM383x8dA7G7v3k6J0DBQJ3cKI2o2rhdjQWp >									
//	        < u =="0.000000000000000001" ; [ 000033916425389.000000000000000000 ; 000033923154710.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA285BAACA32A04F >									
//	    < PI_YU_ROMA ; Line_3378 ; 5F8iS5AomvC4S3nn37e829e43bi8498t0uq27gK83LE17tQ7F ; 20171122 ; subDT >									
//	        < 7K1CCPU4eHQd8meZar75tAF0HDkGn6oh2DPU25RHOCS39R21d2vDqXN2R6tm946v >									
//	        < bOAP4cw99S42q3JD3556060Xz8KnNujL6dAtU0D6EBv6j62twuP8psSaT5e1ocU6 >									
//	        < u =="0.000000000000000001" ; [ 000033923154710.000000000000000000 ; 000033934248203.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA32A04FCA438DB4 >									
//	    < PI_YU_ROMA ; Line_3379 ; Ag2T1J61i9QKwVcipc2jiE8p761U6L4q3Dn9353q1woRK4FpY ; 20171122 ; subDT >									
//	        < BId5dA636F9r2fCihqnn6R7Y7bkYN0hM2pw6UoynA6uG36962oNQRqy5CAd2rPm3 >									
//	        < K79FQpYn4N3MUKM25qzPgj0ZWn6yGL9p5G9M9VFH5qAqNt0HM470RmrfApQhZHzA >									
//	        < u =="0.000000000000000001" ; [ 000033934248203.000000000000000000 ; 000033940889350.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA438DB4CA4DAFE7 >									
//	    < PI_YU_ROMA ; Line_3380 ; 1qCUsbM4U1S8O8F12sIkrY5P32cCm8lZyBbBBdvXzCv9J75gl ; 20171122 ; subDT >									
//	        < urUutCnYYtCW5JMw3KQvkw7QuQjBIknF9w7Ts4q1znezHkcqEmfKJ06PdPYDS1Kn >									
//	        < zgc7Uhr456ceeVsZd0Iqhb488d4B6VQ6Qdg2Gnu47O86bt7y1JkqW0pS130zTEbV >									
//	        < u =="0.000000000000000001" ; [ 000033940889350.000000000000000000 ; 000033954643845.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA4DAFE7CA62ACC0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3381 à 3390									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3381 ; apIBKkP1NwR5MwErtlWO9j4GZuD0N9DyRljq9Vv79bw639k08 ; 20171122 ; subDT >									
//	        < pvfZ9iko5r2fD1rPXUsj0itSEkt9Qyjv1T4849n0W1U8o7yYEkSSkANKzD3fS2n3 >									
//	        < J0Fn77pM10ekM4tGRS4qp685YhC10z9EeBS9746Zhc0Z01kYJ34oI3RFL0NLgtl2 >									
//	        < u =="0.000000000000000001" ; [ 000033954643845.000000000000000000 ; 000033964956530.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA62ACC0CA726925 >									
//	    < PI_YU_ROMA ; Line_3382 ; 4loeErT2eRnkU10xth5ytkaS8X0of9cztT4YZci6l98b1EDYp ; 20171122 ; subDT >									
//	        < GyTS98bZj7i70Yu3rdMzp3Cl20xQ9rf9K8JDRMy6qwL76VZ0Fc3Y7wmlhMyaw2Q2 >									
//	        < kKsnciLRsZcpW65gZdNl7l5phGhNky1Tch47DxABEB6dVx2tqHF4F2Evf9AVo787 >									
//	        < u =="0.000000000000000001" ; [ 000033964956530.000000000000000000 ; 000033974406006.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA726925CA80D458 >									
//	    < PI_YU_ROMA ; Line_3383 ; 617k3657j5t9ua5gdBA29XIT5CsoF0ow5zTIGf96M4PuI88r3 ; 20171122 ; subDT >									
//	        < 7ww4iHBdRrk6R50yPrlN355Ty0LBECM2M5DqiDaY3MGzjjorpAdM10t6ahpX9ou6 >									
//	        < p99TUXO4kEfE6Fwmc39VzG37xNY1nSRKXq5MfmGS49Iu5zc45xZhC29LzCc4lfLw >									
//	        < u =="0.000000000000000001" ; [ 000033974406006.000000000000000000 ; 000033982327020.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA80D458CA8CEA7E >									
//	    < PI_YU_ROMA ; Line_3384 ; v7w81F127e09101eApfcztzi7mv6GwIcIHq9MabSVcrt7zwU1 ; 20171122 ; subDT >									
//	        < ZH1w7n7E3gs16I9CTtI4mzTjUOTa4Z9jdoR9WHz1DK712a63138D4zy4G1yON2W5 >									
//	        < SK0SZkDVtPke8s2QxnmhLO338NskY8fqZt7wTm3lFTdFD8UDj42G22J9w81qQb6I >									
//	        < u =="0.000000000000000001" ; [ 000033982327020.000000000000000000 ; 000033991637101.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA8CEA7ECA9B1F3E >									
//	    < PI_YU_ROMA ; Line_3385 ; 1NSrI6b3Z2pd368KtzLIS6ho13r20Lh999RNWRs7YV3QES6Bg ; 20171122 ; subDT >									
//	        < o92fYS8SoRqUpi030o12nWThE18Xbw7OxrF5zu6hBusQ02WEczkHvuG2g4z5MZk0 >									
//	        < IyN56DFCAOw77kM4Q99lz91p077NOMBb7hSX6S1P5oOzG5yqBW5Z78I9uvj4P8Zk >									
//	        < u =="0.000000000000000001" ; [ 000033991637101.000000000000000000 ; 000034003976495.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA9B1F3ECAADF351 >									
//	    < PI_YU_ROMA ; Line_3386 ; 29dkqnQW4gNcFGHhb2X28V9pD5Tggogx55St6lFPT4dP9a1Ev ; 20171122 ; subDT >									
//	        < WKv1yGfW07m2aVDvT0ybv5v8omw0hu9BO574Wlp68v0kE0u1olGCk72T06TI22OK >									
//	        < 63J3pCE6eC28j5A2BZ5f5Z2LV27jEhEr63kWxOhK0y3g5LkSfGtEA2aY3F40bdqf >									
//	        < u =="0.000000000000000001" ; [ 000034003976495.000000000000000000 ; 000034009310550.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CAADF351CAB616EF >									
//	    < PI_YU_ROMA ; Line_3387 ; K7z58Wg6tY2fU5yDxth3mQ5J1mtgh5mP175VIA8Uy62S6l653 ; 20171122 ; subDT >									
//	        < jYP5d6nlU6jvZr01AmK9sP27xmNZQEe7U42Dm921grWR04Y30nMINeHH4YlLz2ZU >									
//	        < x9x1ycf8LbGyrSInDFKJ4H3iWXK2cPX71Is3guEnaVXJeqSv0K30h44047pPPQs8 >									
//	        < u =="0.000000000000000001" ; [ 000034009310550.000000000000000000 ; 000034017890026.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CAB616EFCAC32E4A >									
//	    < PI_YU_ROMA ; Line_3388 ; nGq5uE8qEidT3lkO1TAzUJ0yUdtVOPIQ4BzirFL2E2F2Ox61z ; 20171122 ; subDT >									
//	        < g7NDY0JL0Jfolq37Dvz983BE0X6gUOL1qX7kv2WbPZrBnrJ4kxy7N5sP2JoB53oG >									
//	        < 1XXFk0Ka5U52Tu1W95168B00xeMWmx8430Fj7URy68m7RV3V963AqxR3Pu48hxCx >									
//	        < u =="0.000000000000000001" ; [ 000034017890026.000000000000000000 ; 000034029060863.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CAC32E4ACAD439E6 >									
//	    < PI_YU_ROMA ; Line_3389 ; cQWC8lMMT2ddHt5P3oZk2l5zb1sHXqcQFoO4Rhkifl74D5yF6 ; 20171122 ; subDT >									
//	        < lBnO5y2nSZR0txj6iKQxE721EmMe4p56n12VK82avHS25z20cl4Xqoqw29pRYaNR >									
//	        < Hw6t80bndOrU65Hd392J63E6HSz3Vmf6szp6GYm54578x65xkKr4EG7Z7EMf45fO >									
//	        < u =="0.000000000000000001" ; [ 000034029060863.000000000000000000 ; 000034042960314.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CAD439E6CAE96F5F >									
//	    < PI_YU_ROMA ; Line_3390 ; 0tPlGvwMSXedjdhdPqT4BA61tKaf5jujx5h9d5n4fLJbTt527 ; 20171122 ; subDT >									
//	        < BdI8MU7Q1Q1z19dR0rV1DgEQtkt5I0NiSTn3Gj8dd8eN522TxE55Jj4d2j887qVv >									
//	        < qo543qzD8lX8yBuLMl2Y21RR35GqvOd5kFD75aO9l2sGerQMv1MT587EQoZt06Xt >									
//	        < u =="0.000000000000000001" ; [ 000034042960314.000000000000000000 ; 000034055813642.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CAE96F5FCAFD0C34 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3391 à 3400									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3391 ; FBA96OR3Roy8Mac30VkWcUpxM7nKS7mJd5qs8Ekn6Et925DES ; 20171122 ; subDT >									
//	        < VjGdWSWDaAKKFL4Ah26ST50C9g9GaCfj2kz1ntgrE4dELv0RX6a57OI5gJlmjKdv >									
//	        < 13748R0HZ83diq3rQ67b8Rs9z7cYGk5m4IyIn1eVoYuWK4Rkx8aW5R60GI2Rgz01 >									
//	        < u =="0.000000000000000001" ; [ 000034055813642.000000000000000000 ; 000034066678079.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CAFD0C34CB0DA01F >									
//	    < PI_YU_ROMA ; Line_3392 ; h6PgtMhb167vOeU245Rdd242De262QT81KuLy3NZ636iM494u ; 20171122 ; subDT >									
//	        < kz0YCc630a0O97AxIT85gMo8a4NpU6A1uvHKGDwN0J3kFA2T0FvHPq16La3w6Mne >									
//	        < lbmtYmNVqWhxuGNd6hLnN8mvZ7rp6QejWf2YcMISs802gt6echb69aI2ccsA4Txg >									
//	        < u =="0.000000000000000001" ; [ 000034066678079.000000000000000000 ; 000034078057389.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB0DA01FCB1EFD2A >									
//	    < PI_YU_ROMA ; Line_3393 ; QX4CgJy9q6S34x8WkbuV46Vlp5otT91NHYGw1Hg8HoMLlVY78 ; 20171122 ; subDT >									
//	        < AqvBO6vhyauqVmxNp3s0vw4y1qTKKvMiV2XXAlOKvCO9Hk6Z9Ppi861yy0W61o8M >									
//	        < IKdfIJxnWr45BaWWlUh6I5Je168i10XIZp63vJjzF82T9lM68ka6tkKgDqun68aw >									
//	        < u =="0.000000000000000001" ; [ 000034078057389.000000000000000000 ; 000034087591969.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB1EFD2ACB2D899C >									
//	    < PI_YU_ROMA ; Line_3394 ; z6Ob8T4iL3U22a30o5287orF77Vs4f29TWB19HT36h4T186y8 ; 20171122 ; subDT >									
//	        < 3zyWHvmv1dxtmh554GA2B5F2o5FD9n75Ia5PbrPZx4CkCXlARyp3qUaOBp9Cf61h >									
//	        < lqt7mxDHNuJkHuI7eK21x9qeMwXmBr3oFYD49X3lXRbCq2MRUX4VnQVXW6oj7cpd >									
//	        < u =="0.000000000000000001" ; [ 000034087591969.000000000000000000 ; 000034093891855.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB2D899CCB372681 >									
//	    < PI_YU_ROMA ; Line_3395 ; 55njj9U51234iiMoemve0N70d8J91O9yWXDEh0Sx84hDzy3MP ; 20171122 ; subDT >									
//	        < q2cEMcmX5571Qu52HAi3FAtBMwOwYdJz5cM5fMb181nVAISEgjq2hdUVs7y7s960 >									
//	        < F1BsA31WAu06F40Pz5q939Y7aH7Hq360BSOj77w3pb151b2elXtkYZD1785rJ9u7 >									
//	        < u =="0.000000000000000001" ; [ 000034093891855.000000000000000000 ; 000034107870514.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB372681CB4C7AEB >									
//	    < PI_YU_ROMA ; Line_3396 ; 1lzL5tqTT00MGiRK3j44t09UKuCv548Bl8cZLbx724k3jMY9l ; 20171122 ; subDT >									
//	        < 600yjYqsd7r3j584760g8vjZfFG9EvcOVU7t3glfMN0d2xN6A9479kCnUshOM2QL >									
//	        < h12PWF4mP2Ee20x55H89uIdf7XDh60mhTN2Aa79Xc42oYvwUb9QK91ud0CU6f4y5 >									
//	        < u =="0.000000000000000001" ; [ 000034107870514.000000000000000000 ; 000034114266912.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB4C7AEBCB563D83 >									
//	    < PI_YU_ROMA ; Line_3397 ; 6ZgdtQ9U05ElKeiOJaQeMR4CnA3zL5i0IebMdEJ7t1tiH6TfX ; 20171122 ; subDT >									
//	        < 3UfiYpCdmEiWvMRx17LpfT3DcWE40ZEvqv6enn66j6Mg70dnwV1S545n1kWA06fn >									
//	        < 4XYndmFUGlPnS3AHhxFRP5z58758OX6Gbmf58o1brJa65AGdx65344I081iTKRF2 >									
//	        < u =="0.000000000000000001" ; [ 000034114266912.000000000000000000 ; 000034126644554.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB563D83CB692087 >									
//	    < PI_YU_ROMA ; Line_3398 ; a1M47A55h9PM21fD3JPEOSpS1fiyhKRSZOYvzst2hlmeHbBbn ; 20171122 ; subDT >									
//	        < 9YsyPPtub689g280uA06U142no9567CdeJh97YIE59OTlOtVq8946sSnjZH7615z >									
//	        < 0nb9k225d2V40AuoyNchn7o63r0TxzCu0cK763SK1f1XlS4R1agl93CcwzAafEas >									
//	        < u =="0.000000000000000001" ; [ 000034126644554.000000000000000000 ; 000034133897381.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB692087CB7431AA >									
//	    < PI_YU_ROMA ; Line_3399 ; 35i1eRW0WYn11dP54p04OP7qJEZin88KDv0n17i395ed02P37 ; 20171122 ; subDT >									
//	        < pJL4EE4K30m3r5TN8gZ2p715knTwv77pQ1hl56w91mqYhONp3ArPp8kQuCnU2Kd3 >									
//	        < Q0P5Ytx9HYx2bsp31725j4tuvM039Zlk1d0D4VCt344F42j6lu8OPB80dA90dfRn >									
//	        < u =="0.000000000000000001" ; [ 000034133897381.000000000000000000 ; 000034148482269.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB7431AACB8A72E2 >									
//	    < PI_YU_ROMA ; Line_3400 ; y0j57yMN82Fez7Mex91zULckU86zczXZSb8CObqUGIB711Ab8 ; 20171122 ; subDT >									
//	        < yj828bkvFWj57hDbY8x6jF2bLWZ1fWonB8z3b5fN925IM0cnDlQJz490p2Kz9jwV >									
//	        < bodHG3zjGTttdg3Yln5O9L19zX59OmZ90y9PvjmDKtqlB7AB5FV88bbCX1zJD2Db >									
//	        < u =="0.000000000000000001" ; [ 000034148482269.000000000000000000 ; 000034159297929.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB8A72E2CB9AF3C0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3401 à 3410									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3401 ; NuX5eq4yNl1Mabt0g4J4b4LE1D6L3z2A6le5bWWoZcx1164s2 ; 20171122 ; subDT >									
//	        < bZ154UQ3VnJgVGHeov14CL03g8l9sPv04j73g8gNGee2s2Wm03A5R1i7D8id1a6H >									
//	        < 2bH9WelDBvx82XJvgZH3E9DLs8KTRM9ID46Nqs201oyHmY458v9g71T89OBZ6ap5 >									
//	        < u =="0.000000000000000001" ; [ 000034159297929.000000000000000000 ; 000034171711667.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB9AF3C0CBADE4DE >									
//	    < PI_YU_ROMA ; Line_3402 ; 6VZ7k0344IeZw2I7j554lc01bz6Vuo1VjU24Ln182cmlj03at ; 20171122 ; subDT >									
//	        < c62l5bO1J7j679Z5GdEb5pWotC9Nu4J2bO59yWu9YSAR7QxzvRS9PI3jPoBo29E1 >									
//	        < 3ipFWg4Q46ca0d035brYTZVqwSG53J8C6Ev15SoAN23fN88SwyP02BdWUOmyTM0i >									
//	        < u =="0.000000000000000001" ; [ 000034171711667.000000000000000000 ; 000034185651631.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CBADE4DECBC32A2B >									
//	    < PI_YU_ROMA ; Line_3403 ; QVmFLki5UhkZ9VkY24mqnnASjKBcfC6zWibF921a70Wu5822r ; 20171122 ; subDT >									
//	        < 5Y31Bn1d74tB2QHYr138Pagn2CM8gbyQY9g1O4xkl9069M7K0zs7bv66XI5D10QM >									
//	        < B5OSyV6K7S1JHx90Cu72LYOoVZOqesxy51oVmBBLe0mXoWuwrl7Cm1c6f6av5ObZ >									
//	        < u =="0.000000000000000001" ; [ 000034185651631.000000000000000000 ; 000034196011467.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CBC32A2BCBD2F8FA >									
//	    < PI_YU_ROMA ; Line_3404 ; v0LlOi6w2mwRl32y1wT3562x73XXXE8f7t9aVK2wYY2moRY3z ; 20171122 ; subDT >									
//	        < kp71e6n3OXz0tDm33AYhG9nin9qKh53S5ycfS30O9Ap76sRl4Ay500Hl18Wa40Io >									
//	        < 2KbSMi0uT7T115g07r0NZhul74h5z02EVOd3X6tqFcDS3DX427U6d1cF5H9gJfwI >									
//	        < u =="0.000000000000000001" ; [ 000034196011467.000000000000000000 ; 000034205517456.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CBD2F8FACBE17A41 >									
//	    < PI_YU_ROMA ; Line_3405 ; 84TS70e2F7Ct1VBwQvJXNtuaoE2NvML46lVkmsxQsx09htJ1X ; 20171122 ; subDT >									
//	        < fRR1fpqUT361O71i68L1RBpbufxM3UTSqT7ODQNcsdnSLYY3OAMz79jyuVs56kLJ >									
//	        < lMRu43ggg2E63dn7VyLbnw8nD5SCYkTUlSCJdRTF50ZXKASbfCdsF1020662tK7Y >									
//	        < u =="0.000000000000000001" ; [ 000034205517456.000000000000000000 ; 000034218034506.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CBE17A41CBF493BA >									
//	    < PI_YU_ROMA ; Line_3406 ; B3141wDk402A2y7SVdp878Hz31RQvS5N3Ml2226t6m51pLnHS ; 20171122 ; subDT >									
//	        < a7d40AatL48K6P8KPQ2K0Jz9SuFB6550bRaYqo0mJ7Zr3YyvC5wry0SU2g2SmxIg >									
//	        < ZBVk2OmwqI3mb99S3T3z6116mZ1IO1u21HNb6A9tXIeTYt9TN4585oNS2ue8fN15 >									
//	        < u =="0.000000000000000001" ; [ 000034218034506.000000000000000000 ; 000034224673612.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CBF493BACBFEB521 >									
//	    < PI_YU_ROMA ; Line_3407 ; d5dg6kg9OV4BLsbnor4Li0Jz89b7Y3Su8ssOeC7fQ2Zo9z23N ; 20171122 ; subDT >									
//	        < N7870WA21t392T163Ir5X8C1Z1p0AMkzxYuI1dMz3LH747968G0v7vv7ZH6bqI5G >									
//	        < 43ec8lvqhaHUrYMh9u5gYCc9Vip3563C1o7E4HHq4GgZa3cD56kyX50C46y3RI4i >									
//	        < u =="0.000000000000000001" ; [ 000034224673612.000000000000000000 ; 000034232044368.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CBFEB521CC09F454 >									
//	    < PI_YU_ROMA ; Line_3408 ; 0tn45Riz6yh5M1Ex9j9sqWtweA0cTjQiu4LDBLIZ4Z3RIE3ax ; 20171122 ; subDT >									
//	        < T1fG47MTD5yCt6uVWp01RQYK4PNqDayeALivK0hDMCzV5U33c3tIFocj6skdSNJ9 >									
//	        < o4odvIjdt2wj3y0UAD2dRpdI4i8owf80OZZUi2g06ubzzxykrFNY02YIU3s432iB >									
//	        < u =="0.000000000000000001" ; [ 000034232044368.000000000000000000 ; 000034243100410.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC09F454CC1AD319 >									
//	    < PI_YU_ROMA ; Line_3409 ; F979ze5E9k85v16R3koDcw66N2q03OnIQqwgluf156A40583G ; 20171122 ; subDT >									
//	        < 02Pw5YYzSy67H53t6R0Cicmmk91cY7pwbQxPVadDm4V09JCMYy9jcJslUp1GCO68 >									
//	        < 6crgpy4BlJ93vPR8j7I3TmErym66No0ANSj2o1WA45Op00Ja10r7K6kD6i83M9kr >									
//	        < u =="0.000000000000000001" ; [ 000034243100410.000000000000000000 ; 000034251587565.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC1AD319CC27C664 >									
//	    < PI_YU_ROMA ; Line_3410 ; F19717MENV5caJzvx2C07k6Fw322u8J1878fdT4Ie4SZ7w4WI ; 20171122 ; subDT >									
//	        < oU0slTVS17Iprbq0tK6kd4taP7LjZlKlGzjtGt0yLfRzFlz01Sa2Bi6w7p5KNl04 >									
//	        < MPog7RfKl85v41q04269OuDWkeGF73x2M6jMFtJ31avUjw6ijVo7rp0Tiyrchu2V >									
//	        < u =="0.000000000000000001" ; [ 000034251587565.000000000000000000 ; 000034261147666.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC27C664CC365CCE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3411 à 3420									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3411 ; hNEI8xddTsRE00Abd20IArq3wb1hRrWsupbCkP690FEP8i123 ; 20171122 ; subDT >									
//	        < 043aa5l66GGY296y9NmOfyf5A4GAd6J4Ws4kq4i3CEUV9KSJnJ9S4l741270jGy6 >									
//	        < Y8JJ7i39286a9u55YBzx2MF3893XzXG64UJD44B8yKOwTkBVIV4f4dK4VJx33LD3 >									
//	        < u =="0.000000000000000001" ; [ 000034261147666.000000000000000000 ; 000034275885374.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC365CCECC4CD9B9 >									
//	    < PI_YU_ROMA ; Line_3412 ; n0I9b80nRoezgi1bAL5lE4wy5jo84784oXw2BW72K54nL8L9B ; 20171122 ; subDT >									
//	        < 6j4C20rbZ9AEGJ0ZKx4VDs8OhyN8ao429QmmvwkA2iqYe408ie20Z4J3sBp5RTCR >									
//	        < H5x3ubDh75tYivs2N0u4ab5n74H79fdAwlNBTg44zYQ32WhyxJOGGFKV0Htrwz0F >									
//	        < u =="0.000000000000000001" ; [ 000034275885374.000000000000000000 ; 000034283444464.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC4CD9B9CC58627E >									
//	    < PI_YU_ROMA ; Line_3413 ; 2849ryrQGQc5nA3DRD51N21MLAOX8TpJy56k3Z0LoLi6mHyVK ; 20171122 ; subDT >									
//	        < tf2CAVXtq17EPHOA7TgZ31fSQQkFi0JFK74fglq43XAS856y4gmHoVrm6c87rU72 >									
//	        < RNkHIx809DV94Bd7MdAJM197Ps3mMVRF9DN1QLV7ysaH45zG0b7x7e1t0zMtg6UV >									
//	        < u =="0.000000000000000001" ; [ 000034283444464.000000000000000000 ; 000034291292641.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC58627ECC645C30 >									
//	    < PI_YU_ROMA ; Line_3414 ; VOR1V969Obv2fgh0Oxia8K36Un47qUv1lp5zWsYNB2M10pbp4 ; 20171122 ; subDT >									
//	        < o6IRueW5GKWz17tu5O9sz6M3T0fy21sMDBKAAi5jazx718C8s4Wv8PtHJR39CwxM >									
//	        < zxrI90bQLT8N05tfom4STd4sK2mZd54b72SMeYaQRccXNDUqpVAkM1kB5uN41541 >									
//	        < u =="0.000000000000000001" ; [ 000034291292641.000000000000000000 ; 000034305362107.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC645C30CC79D412 >									
//	    < PI_YU_ROMA ; Line_3415 ; Axj3amrey4Xtq3w5UZQ873iJgmKOnoSL9qY86Fs1pxyolsJ8h ; 20171122 ; subDT >									
//	        < IuT4V4N8Zt1nlItxAq60sn658mo3fP17w4FQTK87jP65u3aA3T9O23rh1Xid3Ko1 >									
//	        < P0w646wza7pcZna3sZ698jf7LPAZiJIlBN0qVTdR22eQN2kr3G9E61tJJKacCL9Y >									
//	        < u =="0.000000000000000001" ; [ 000034305362107.000000000000000000 ; 000034313776207.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC79D412CC86AAD4 >									
//	    < PI_YU_ROMA ; Line_3416 ; 2756P4vzp3S0q5F141wLUoDknyutXiX396TwyTQJs5LzMe1j3 ; 20171122 ; subDT >									
//	        < r0hjxaaepbnXQ0SP36E0afO95rjI95b5iKuMT4pER2XSruMI8PQdJ6V7Ub610N3g >									
//	        < xk6knrALOYZ8ZMRQqCC160ggd9Ks3Tjt952flE4TO8NOkg16tp8fz8mrvIMD9c63 >									
//	        < u =="0.000000000000000001" ; [ 000034313776207.000000000000000000 ; 000034323181378.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC86AAD4CC9504B9 >									
//	    < PI_YU_ROMA ; Line_3417 ; 8dp3i9Qh5o7i4XSF33q44tMFyp7scCC7U9u9Hvrq3bD1oUDM0 ; 20171122 ; subDT >									
//	        < 72Th1OCS45Ns5c1751F5QO53EtWth16tni7E1hGjr0kp8pB4y1V1lFZzJ2i53SfU >									
//	        < F8W4dQMr2DLzbxnh0l5RCnk9BEIA976JOtS6f75gWRu9tP7Of3aE1j2k9slLur67 >									
//	        < u =="0.000000000000000001" ; [ 000034323181378.000000000000000000 ; 000034335064555.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC9504B9CCA72697 >									
//	    < PI_YU_ROMA ; Line_3418 ; VlqxB0Snk59UZqwmB2FR5GA7mmUHO38dbNd6lUeZw7NLs4jLH ; 20171122 ; subDT >									
//	        < u5po1r7sDdS3vCL5968W3A6tlhO6UIm1MZ5FkCyaam4oFfU5sv3jsNgse73Xur56 >									
//	        < qqtjFmC7PO7sY37286HFaUbhbk2iz0zdIIm8ceyY607Fwls5vdE4bm5Ghfge6SA2 >									
//	        < u =="0.000000000000000001" ; [ 000034335064555.000000000000000000 ; 000034348613299.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CCA72697CCBBD311 >									
//	    < PI_YU_ROMA ; Line_3419 ; TK82YJ093VUbz13980X2hwn61883x19oJsoM238GMIZ6Sc0OV ; 20171122 ; subDT >									
//	        < 02nRk53n91Ldm9gQL4LrFx1LD1530k3HIuVZ8MOJP20O5k44nNJ335eJ227g4COg >									
//	        < 83Mhb690y8al34O123q34VQ6aK6EQGrAZMJ5SIAEf262fwO5Ns4aoe8lIiMGTLAr >									
//	        < u =="0.000000000000000001" ; [ 000034348613299.000000000000000000 ; 000034354422109.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CCBBD311CCC4B022 >									
//	    < PI_YU_ROMA ; Line_3420 ; IFacF2xXiAY1853tQ3idHLT1uRMXEqY94kDq3PNx39fL16mu4 ; 20171122 ; subDT >									
//	        < iv4BYJ8Y5qqEBB70iX891risSi1hJP79GPgXIIZj6coI263582nLBDiXC1Iyt272 >									
//	        < ufBcqyFpr5pLGUcO17238m7KO93172viYct7l8edbUjSv5VHiaSqv38Kt9nm1X57 >									
//	        < u =="0.000000000000000001" ; [ 000034354422109.000000000000000000 ; 000034361704247.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CCC4B022CCCFCCB8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3421 à 3430									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3421 ; 69W0rt52tj880jhj95odgqeM96vW7PnM5qE1RoY583MR5Su8N ; 20171122 ; subDT >									
//	        < y8uT347cPBqgreFt5m3q4WbySKd47Cl9Qf2zm15HxR07druQK506kokC9n99W53m >									
//	        < WLc7Z4idAdttgaggZ52800rdXlD5Rf4I80ZBx4w7eza8T504ua37UVXZ06Lq5bH1 >									
//	        < u =="0.000000000000000001" ; [ 000034361704247.000000000000000000 ; 000034370256576.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CCCFCCB8CCDCD979 >									
//	    < PI_YU_ROMA ; Line_3422 ; Yh475pP574RQ3y85tP6cFuwey3xTB1g06019YbcVQ9NTAKmI9 ; 20171122 ; subDT >									
//	        < isX6Am67A75QJ4RPrK4n72N602DqtSd4484f4FPG1M71b95637xgEozT4Mii40lB >									
//	        < Tb5OtW3sTKI8MSfHkp8ryz4FQqTjp0IQ3d27VZJj15l80T5u8XS1sl84SAzqrVGS >									
//	        < u =="0.000000000000000001" ; [ 000034370256576.000000000000000000 ; 000034377808812.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CCDCD979CCE85F91 >									
//	    < PI_YU_ROMA ; Line_3423 ; Wv5f1fsQHlRVtm0M2s5GR3ss1uY7SV9a0Z8K5Jiizq1gySv9A ; 20171122 ; subDT >									
//	        < 11duw8H9VH12H8W6N4JA72GzN9wHVXxo6Uj083t5zcIz2eGrn5E2fIaTnEwpa02I >									
//	        < 8KBsgxEXAb447HcxG6RlY7lU7eW4N07w5bGLqCJOZ5Hj5bbaMppXzqV45DWh3A0R >									
//	        < u =="0.000000000000000001" ; [ 000034377808812.000000000000000000 ; 000034383825487.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CCE85F91CCF18DD4 >									
//	    < PI_YU_ROMA ; Line_3424 ; a26NZIGPE90SExOMMOVn6WJ8Dn20hTi6R1mm4SNEKcmXqH1sC ; 20171122 ; subDT >									
//	        < DQ3Ub73EOs2Ao1Y06d1mlSPp7zpT5KidzTm01PCU8374CcU7GoePc8wuysDa1qm7 >									
//	        < rG8h9cGns5t5GUU1XZpRARtMAZ918Fu1M0Q5nStg6p32Uq90441qVHOOL64OJ172 >									
//	        < u =="0.000000000000000001" ; [ 000034383825487.000000000000000000 ; 000034394345291.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CCF18DD4CD019B21 >									
//	    < PI_YU_ROMA ; Line_3425 ; 394W6K8e924smgO594uq6E7v2Aa3w1QX759A3HrU5gA81T6QL ; 20171122 ; subDT >									
//	        < 2pRLWgp8gjIX6IWIZ9xcYIfCLjK8r13ilZ8Er028QWR2HyROUFK37v1HEG5utpm6 >									
//	        < bFC2161q3QRF6gxfY6x34JBpjJk8WHKILUaPr4Ak7U5nC63l0AT0BjM96X3ftg07 >									
//	        < u =="0.000000000000000001" ; [ 000034394345291.000000000000000000 ; 000034405675958.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD019B21CD12E52B >									
//	    < PI_YU_ROMA ; Line_3426 ; XD7bRvB7qzgHwOD02044R3S45G689io6IQd7I6AOh91V3fC01 ; 20171122 ; subDT >									
//	        < 8r0Fg0aek01tA0s29Y4rZk6Gu0OfB3aEgvzXa3pr3pJJu25aYv6x5rYA00VmEsuG >									
//	        < F6bX4j9IKUe467p2yz2IHnz1B861PlzYJ164F09L72S8aC6PMdob5G04JM1YVHlq >									
//	        < u =="0.000000000000000001" ; [ 000034405675958.000000000000000000 ; 000034417238328.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD12E52BCD2489B8 >									
//	    < PI_YU_ROMA ; Line_3427 ; A5Hk3vgciUtUb3718BADP50fX08w7r66Md9r6wl2T0qj9Jz95 ; 20171122 ; subDT >									
//	        < kXA9adYJEhW65bFjSCjg36eQLXH0357QBTw9gW6gz14333jt08xjRUmrGep7m0vQ >									
//	        < oo9n3qvq46sp632n8b6Y8vZk8uwV9Cfg9p9S66NWHe8UrxgdV61z5S4VJ688VIM4 >									
//	        < u =="0.000000000000000001" ; [ 000034417238328.000000000000000000 ; 000034431520413.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD2489B8CD3A54A9 >									
//	    < PI_YU_ROMA ; Line_3428 ; 3boQuBN9WL4NT4dh33nL27cbmgJue2wUK376Z6rL5v41O8B06 ; 20171122 ; subDT >									
//	        < eE5b34oV3veUA03usTUnSaWKl872lnWUi3Oi3rq7YufKkr5Va11pt34z2E8Wa0Uw >									
//	        < 56cAwSfvj71o5DE3N0cl0XrD2l48ncAN9xCw0QzE7x3MIXBh0DV91t7ggxI21yT7 >									
//	        < u =="0.000000000000000001" ; [ 000034431520413.000000000000000000 ; 000034441022049.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD3A54A9CD48D43C >									
//	    < PI_YU_ROMA ; Line_3429 ; y045M6w4at474B3MggFHe4AM3G072WC5RrIh52rT7YavPPTmz ; 20171122 ; subDT >									
//	        < 9Z0iC4aCdT8rg75FVCt64Sd08n9Sz3rOXzYEEF83DNg9bMDcl2W8zt8G5UZo772R >									
//	        < YpWW4k6cNwhlmY81GvfT2g5R0x70pAGjOm30m2klrH8xSiPISgCY0vVtKiima34y >									
//	        < u =="0.000000000000000001" ; [ 000034441022049.000000000000000000 ; 000034447048409.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD48D43CCD520648 >									
//	    < PI_YU_ROMA ; Line_3430 ; lXaREGW18ML8kbmM6W7A7f00ZYL1v87y87K8QP68jynxfyxCu ; 20171122 ; subDT >									
//	        < Svn90XEy58VNVsX6aeqVxJ41rtUhBbkMTc0Nd4JIO65i6xlkddQ97V57dtXI5R67 >									
//	        < 76f4SRW3E8gLc9X0Ez2gD40jvJrB2eeCVijac61w5gU5GdMOUV2a2qT0ZZHV3nzd >									
//	        < u =="0.000000000000000001" ; [ 000034447048409.000000000000000000 ; 000034458737725.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD520648CD63DC6C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3431 à 3440									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3431 ; 16359O7kBgvda22WUWIUWrpj195rkQkX5Kqt29hwZ2Ni39209 ; 20171122 ; subDT >									
//	        < Ftnj03V60cmHBw4BMG0QHexTLs9ZIGeGSvJ122K53r5Xdv67h186VCc5LQ9063pj >									
//	        < d7m72K150P8oy1s5MB962mzC5Dw28M131Y1BsZH5Vg5l8518763Am6cJ9ztxIHME >									
//	        < u =="0.000000000000000001" ; [ 000034458737725.000000000000000000 ; 000034469632122.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD63DC6CCD747C0C >									
//	    < PI_YU_ROMA ; Line_3432 ; Htg18RGc8lvXBPv1NW8PN8LRL7X0OV0JUYFib908f46pxcc0P ; 20171122 ; subDT >									
//	        < X1J9Aye2V3Oxft4qQzcgU74ZW4NbiFRTRz423PsD018wbygp8db1yAzhhmwTJci4 >									
//	        < 58mhAQ5jA1018O42508018cMSBAQ6Kdk8B4ktvFuFy3nmkRocOHq81ZM8Frp0f62 >									
//	        < u =="0.000000000000000001" ; [ 000034469632122.000000000000000000 ; 000034482936069.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD747C0CCD88C8E6 >									
//	    < PI_YU_ROMA ; Line_3433 ; kn3u6av1G9V30801m9XsZ6Jt2Rdm4LiZhM0zO9io9pzq144nQ ; 20171122 ; subDT >									
//	        < V173B8rt1P1298rFTStH7CuTi2G05iNKSciaQ1rlJkj7K6pE4jNH9Do8hu4W3xDx >									
//	        < 1N2jyhS0SsPk3gW5R28dM4L7HQsSZ0H7mY5gONKXyBZAM81XHlTTw9faHeWOXY8D >									
//	        < u =="0.000000000000000001" ; [ 000034482936069.000000000000000000 ; 000034495526065.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD88C8E6CD9BFEDE >									
//	    < PI_YU_ROMA ; Line_3434 ; EJ27E44irojziTicYR0XEIF6vuM1Nv6yVJ8U8Q244EX6nb5PX ; 20171122 ; subDT >									
//	        < TvXj7QjLNh9yhLHz86ADNLp57930DUw7XdrGH7268v4wW437Vik2ln88HPI0Jm16 >									
//	        < 55547nW00Hjcxr3HVpEI2G4VfCXlrVB4dF5Au7891y9Gji1Z7TL5dq0W34RJ7Emf >									
//	        < u =="0.000000000000000001" ; [ 000034495526065.000000000000000000 ; 000034500980215.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD9BFEDECDA45165 >									
//	    < PI_YU_ROMA ; Line_3435 ; vFm776jAmFQmVrnZJbmm94kXEfusVq0smK89r3Jy9Tzl6UwjG ; 20171122 ; subDT >									
//	        < 23528LE54yHArvEeOCxjBrUJp85KQG01BLzr547pG5329N6Qp0247EN4Kj148iYG >									
//	        < WcGR33W6F2sGA4yVIdRk9ai1sU8N2uMa8pm88WVIk8FnutQkwJ230lc5hKCvibw1 >									
//	        < u =="0.000000000000000001" ; [ 000034500980215.000000000000000000 ; 000034506447956.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CDA45165CDACA93B >									
//	    < PI_YU_ROMA ; Line_3436 ; 3iLb95G3XtRkRHbSIpSEwBdZs6GN017j5H6CoUo040PGjxkzn ; 20171122 ; subDT >									
//	        < tn62Z6KHz768kM6TDrrZ7mCFo3B0hUf3WSi9BcRqkPplJGgULy4kbDj2h6wvlTy5 >									
//	        < w3MtDJJ2n0V8A9Pw69Wg1af80AJSmn4GA8img2do16MpP8Mn01I84RY9QHrZxUXk >									
//	        < u =="0.000000000000000001" ; [ 000034506447956.000000000000000000 ; 000034515360663.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CDACA93BCDBA42C2 >									
//	    < PI_YU_ROMA ; Line_3437 ; 9TT574BHW53A72qWP4iwq60tvr2fYLCht498671fW521TjnpZ ; 20171122 ; subDT >									
//	        < GXS1W1d9oDMT8jhla85eHdpJav3Cr988kb2w2F44qJ32b8r8fCPM2Xt8s2pVbuj1 >									
//	        < 4yR6tgbVf8XRI0xMkEvZl400UUA07aqg0oNT37F1SIf2ELmSN5HFKREj0n0rAM1O >									
//	        < u =="0.000000000000000001" ; [ 000034515360663.000000000000000000 ; 000034524423850.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CDBA42C2CDC81711 >									
//	    < PI_YU_ROMA ; Line_3438 ; IQ3phc7n7r6dDx1tSz9N6YVh3W1b1cC0R2aFtODzmA2h1JhK8 ; 20171122 ; subDT >									
//	        < M4LdYd910i5U9sj7I7lhXYdKuO4qa7406vtqlYQSq73x13UY8i60Z3LIpY7WfjmN >									
//	        < Py5P3iu5j7bpOrW1YIJ1JnDM2eA6kPn9o844210ExN4DOS8vXsJkqi7MRKd01gVB >									
//	        < u =="0.000000000000000001" ; [ 000034524423850.000000000000000000 ; 000034535157750.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CDC81711CDD877FF >									
//	    < PI_YU_ROMA ; Line_3439 ; 8Nmq9tOPQ29v30o15uhOEkuNby28Hrfx5NQLK4e92sS1RUJ58 ; 20171122 ; subDT >									
//	        < 4IR10ACBG5Ee0cY6JKQH1C7KTe2QSVn60o1sI9ZU34reAIV2jrc2PHOQ17PT0COw >									
//	        < 65dmB6U43zvoqJ5c7Cb4NLVl1mm0dd0Pp3fr7s10qB084EeoBx0eBgLk1SpaEo8w >									
//	        < u =="0.000000000000000001" ; [ 000034535157750.000000000000000000 ; 000034543930073.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CDD877FFCDE5DAAF >									
//	    < PI_YU_ROMA ; Line_3440 ; 58905hv9m9Zemg7WxNLC1BYO47gauOL3nrQLk3iF0sBdI1BS7 ; 20171122 ; subDT >									
//	        < QA6jtR84mlCOAH3E15kFlMfar9SHITIx1n26P0k2rii5D5I1YEEttIp0N0r48Oce >									
//	        < 6o234XUrG1w6nq7a92y3WUDV25Sj3WhDcK6Cy3DIZ1OUpoJ1IH3FYeS6Dqe0ssTS >									
//	        < u =="0.000000000000000001" ; [ 000034543930073.000000000000000000 ; 000034557277949.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CDE5DAAFCDFA38B2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3441 à 3450									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3441 ; d2J0K09nbCsJDKiWdmFELt8ZlbHVlX3A47l40a75037AeRz3Y ; 20171122 ; subDT >									
//	        < yK0uCSc9934F66m6xNemKFXnL0sts1TZd4dO2GJ4YT59Z8gOMcVzupJhz2N45Uh5 >									
//	        < oh2z7J4m23xnus4Q763KwB8qVb7F4hJPFyrEww179qf9pA49YG08d2ON8y5UKGu1 >									
//	        < u =="0.000000000000000001" ; [ 000034557277949.000000000000000000 ; 000034569187199.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CDFA38B2CE0C64BF >									
//	    < PI_YU_ROMA ; Line_3442 ; 63oagd99E4b6mM5J7QCp6M9vKN4iTaa898rFyHC3KDcRo8W7O ; 20171122 ; subDT >									
//	        < 0I8cH6KO5m6lC2bV66UywiVQSE4g30Q6583SYqS3799I319hD217nXVgnRRwsNzf >									
//	        < m7ifngqdh6yb646Ivkxr8xGygtfRN54T5xij4t4jdKYVYKKBxdTMVn0Fbs019JoJ >									
//	        < u =="0.000000000000000001" ; [ 000034569187199.000000000000000000 ; 000034583976960.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE0C64BFCE22F600 >									
//	    < PI_YU_ROMA ; Line_3443 ; voYdSeNld4in0tXGt4M229zQ360mCrkSX75571jtNZXzUlrth ; 20171122 ; subDT >									
//	        < NtImzIBSyhJ4f3FRW350Ah3g9tgc40Ea6cg5a3Y0V1o8xF55oj1M3dupCyuw4Wsi >									
//	        < O4n8q72BYkJT7f7cG9KR4mOw6Qb1bfo10xoqeG7Vc3d1DqSwy2NN4Q9W36bkB1x4 >									
//	        < u =="0.000000000000000001" ; [ 000034583976960.000000000000000000 ; 000034590688452.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE22F600CE2D33AD >									
//	    < PI_YU_ROMA ; Line_3444 ; OqD8k3rWLmA9k6EwHU9updocIIwnZ89b2X3PuZeNQx3J1RrF3 ; 20171122 ; subDT >									
//	        < 5g9uTCI35e4K419484kqcZ3qX5U89S4W125RhNMyuLlT4RdbJ1mp0Q2A36CL72y7 >									
//	        < w0lPqYyLbU619pew77k14MHAFxckwIt7Uq8j4y2J17Boe6I8BH0HQc4EKF31PhRd >									
//	        < u =="0.000000000000000001" ; [ 000034590688452.000000000000000000 ; 000034604209245.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE2D33ADCE41D53C >									
//	    < PI_YU_ROMA ; Line_3445 ; jOGToKMF6tu2UX9AiOet78wU2aes09sQ8B4nFGGK1D0I2E0sp ; 20171122 ; subDT >									
//	        < HwsybBvOA6dH16YwpzD8INo216B65Vu87ym06KzEw645hvhqa8MVAR3E02Ms1sqI >									
//	        < 8fFCj1GFKaB3u0SG9NWZ0Siz6xKN4aFbTWSyNm2LWBWBan29VXci43J9NY5250Hf >									
//	        < u =="0.000000000000000001" ; [ 000034604209245.000000000000000000 ; 000034613403483.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE41D53CCE4FDCBC >									
//	    < PI_YU_ROMA ; Line_3446 ; u10f51SQT89n2u02ENIlNz4Y8Bu8RWnhgsnnKsTuKENv78eTG ; 20171122 ; subDT >									
//	        < leWJ4q1Z5m14I3JJLF78gTP0FLqC0y5hHm9d3p7mqc4gikysfw15J144Tv1kG7Tk >									
//	        < gA9QsUtUhkRJqdmee8eUzhe58L2Y78oN6Sp2lskiTL004NlxEVHqdWsu4561W4Fr >									
//	        < u =="0.000000000000000001" ; [ 000034613403483.000000000000000000 ; 000034627228445.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE4FDCBCCE64F51C >									
//	    < PI_YU_ROMA ; Line_3447 ; vp55EcWL8J79cC3ef7Fuoy77k07u45ft6FWc88ok50Vj9GH2b ; 20171122 ; subDT >									
//	        < DeK6bUw4y5rqslur1YKbuw9j035eA7me83bTd0878B2A66651XNvjHIdC23WOGF1 >									
//	        < V01EPWC20q4TF93N85X1ZMQzpQr32Dj8Nv5FYNFjT1ooBFiHW60Q53L1bHu76863 >									
//	        < u =="0.000000000000000001" ; [ 000034627228445.000000000000000000 ; 000034633065820.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE64F51CCE6DDD56 >									
//	    < PI_YU_ROMA ; Line_3448 ; Fhvy7aU44n2Cuw3Iu58Dk6q5nK2mEeRlx78OE8869ASOs4vk2 ; 20171122 ; subDT >									
//	        < 0BYP2q3KKiwZZ0E4d9ya5C8x53KyF4Nv4n220a6o91AOCue91ApuFb4CQSI3zcn3 >									
//	        < 34CMz0wbd1di49VfTHRfHcUV0Jic4J1C317V8FS895i3ipA9IZ7k08R974az9MuS >									
//	        < u =="0.000000000000000001" ; [ 000034633065820.000000000000000000 ; 000034638767942.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE6DDD56CE7690BA >									
//	    < PI_YU_ROMA ; Line_3449 ; pE8xnF1goDsozbs1yrB3OvAmV1cTba79m95404Jv3HoL095kr ; 20171122 ; subDT >									
//	        < Gu20V9UzuVsT4dH5ahpe244O5ckw9E2N0hKKTUxoucGc59yr9kA8mKcT8Oz9g9I9 >									
//	        < 21acKWctO12jHg8ZFo0EwW3u85A7REw07yGjX570649SDIEVA4yZwBldq1I3lOE9 >									
//	        < u =="0.000000000000000001" ; [ 000034638767942.000000000000000000 ; 000034644533699.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE7690BACE7F5CF9 >									
//	    < PI_YU_ROMA ; Line_3450 ; f0l8h12V3tnuS3C91X4aB46TS6oUmWF9sWd71Xr82Qh767WN6 ; 20171122 ; subDT >									
//	        < h9I5D9EO84mflsUM3dFUfjqGAC20wyEKrooKy3lwiE5FK89NQkeocZy8ialJ249e >									
//	        < hly5h49m21F00ncSX66zFS5B3lT73YsM40x5WSs898qHd34xjUr3o680Yfmzfx81 >									
//	        < u =="0.000000000000000001" ; [ 000034644533699.000000000000000000 ; 000034655710355.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE7F5CF9CE906ADB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3451 à 3460									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3451 ; 8I9vidFQprdzENJNRi23f8iP20EFT624OFg79OPaGH69IX743 ; 20171122 ; subDT >									
//	        < 41rSCO5MzP3aX61jJQmL8Bv7ytc0SF0VnGtJ48DNa9O15YJ36kJM3fEx2265uV66 >									
//	        < CVLXUBjUxO5S8jJYEPhWm9Mux9NJDrprc5PZVA26E3U40gSY66rr0zLbf0F35h6R >									
//	        < u =="0.000000000000000001" ; [ 000034655710355.000000000000000000 ; 000034662914233.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE906ADBCE9B68DF >									
//	    < PI_YU_ROMA ; Line_3452 ; U0AE5uOv5Tb8Q4sS6H7JRMw0Ah6hjNQYcS7HIXA3aO98Tg6At ; 20171122 ; subDT >									
//	        < Bh164cIpDeB0shT1lKe268a8y28e6obPwChZA9D8IOSLZNx9Wqp5g7IwTymvphW5 >									
//	        < K2i19zBn26fDUVEBUw8fR26pMpWbPjH4XM9d5zG6X9V0gLqTI54V3D4xsc4i291J >									
//	        < u =="0.000000000000000001" ; [ 000034662914233.000000000000000000 ; 000034674350750.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE9B68DFCEACDC43 >									
//	    < PI_YU_ROMA ; Line_3453 ; Q31JpO2jh1DlNLt5OS6CGPa70A34v98N4T20Ny605LzBbJ9K1 ; 20171122 ; subDT >									
//	        < m1abO288hS3GnL1q9wi18b89reF8cnrQ28Ce7Fe9G1Q4Thv15cGW2jyW870GT9BM >									
//	        < lp9UJ7SEZ92VqM25JuSrGen05BYH103SWwh7NkMSM7ocEne4uu3mh93V2cm342XZ >									
//	        < u =="0.000000000000000001" ; [ 000034674350750.000000000000000000 ; 000034681568374.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CEACDC43CEB7DFA5 >									
//	    < PI_YU_ROMA ; Line_3454 ; ANnXMi1piagzoq6r5761Q7B7aSq84E3hq38b8drj5rk63tE0J ; 20171122 ; subDT >									
//	        < MuhK2GzC3387Flvh7P9rjlt1KDhCU5fxGR15mQN6UMsqlPR4on3m4rV95ZF332s6 >									
//	        < qmB791FM2F1F74t0uEfv19V05BA0m7c2PcLZMyz0BJP3N108uLR7UTF1dpGLFJMT >									
//	        < u =="0.000000000000000001" ; [ 000034681568374.000000000000000000 ; 000034693575369.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CEB7DFA5CECA31E0 >									
//	    < PI_YU_ROMA ; Line_3455 ; YjRP3nG4iut3CKE708tuN7XcZAJi58a5exVDa505Fqfc5Kr52 ; 20171122 ; subDT >									
//	        < SPfcFbi8xYgV59a2nn3OtekpMu4L01E466C9Oa5j8jE2VoI3sfe32Em9Nojh3l81 >									
//	        < kad1Qxs5f81hIscba5K39Sc6pt9g644764pz6VYTpfxVs2fTES3T16aYSh2Zf562 >									
//	        < u =="0.000000000000000001" ; [ 000034693575369.000000000000000000 ; 000034706342759.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CECA31E0CEDDAD23 >									
//	    < PI_YU_ROMA ; Line_3456 ; YPrT922FUiD5jJe56Z8w97BI1Kc5bgmKZ1WaK5DNiT4NyCn7M ; 20171122 ; subDT >									
//	        < U0O3aU8BdLl6fX0l549q1LL3775LCTTw18xtiX1G92pYgHEm9KwtJ7Udt2pzDU57 >									
//	        < bkwKpByJN2i2S076AVQnI28223qGjAP61o4XV1E80k9CD5O1r4OFqbp7j10ppXyH >									
//	        < u =="0.000000000000000001" ; [ 000034706342759.000000000000000000 ; 000034716721782.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CEDDAD23CEED8372 >									
//	    < PI_YU_ROMA ; Line_3457 ; 692Kz7L4VA5hKzV9XuG54i5AH19H12xQ59gLO1kL1D5Qv6o0F ; 20171122 ; subDT >									
//	        < p45Cwjvx521tt65t0m81X9Ai0HjcTYbOsvtkkaQT9vcziQ6ZLE7K1aMw4bwaQ9xM >									
//	        < jji1BHW6043xC0F4598j8E8N1gH2y789RlJ9D0P0Je21777w49Y1dNplBAfmWz57 >									
//	        < u =="0.000000000000000001" ; [ 000034716721782.000000000000000000 ; 000034723895040.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CEED8372CEF87580 >									
//	    < PI_YU_ROMA ; Line_3458 ; 8YI7hNZvL8VYRygiFpcb56l1385GtVbQE5top0HOoZCUrp1Hp ; 20171122 ; subDT >									
//	        < q65nGpL688bxxj00S4358lSY79hR09xAKHCAWJ02Ky5A0c949vpUk7K14136S77h >									
//	        < 0u115pdRWD865j5ilKHRZ5466w02PfCTTonz4XRe32m7d752h6tt69QzQ04xq0YD >									
//	        < u =="0.000000000000000001" ; [ 000034723895040.000000000000000000 ; 000034731649235.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CEF87580CF044A7B >									
//	    < PI_YU_ROMA ; Line_3459 ; 3o19u67oTwTd2BBtr51911pG0LkP8j1h9c74AYJq4Q1da83UO ; 20171122 ; subDT >									
//	        < a7I3Q5931sf8xoC76hQH19Xc6xi2YZDA657IHk5YhpFdnw8N361z2Db77uQgNkLu >									
//	        < 1v6MHyQm1zmJeKTpE5i19cSZaq8303etlab5HsITgKHQb5xcv4DIf8zzbPZ65HVa >									
//	        < u =="0.000000000000000001" ; [ 000034731649235.000000000000000000 ; 000034736741462.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF044A7BCF0C0FA2 >									
//	    < PI_YU_ROMA ; Line_3460 ; YE4tBgnkQ9F1oT48UIS43lAzE4p8t7TOL5Rdqmr7K6MFwbdg9 ; 20171122 ; subDT >									
//	        < 7HmfzVPO4kNraW3W5RY0M7O1K7fltS7SUjJ0IpslJuv281ILO8QQJ3jW1wsJ00TO >									
//	        < 9fUGS454g3F9GBhohy28H16OtS5l7YV16s4QixWs42qnYZq6ARq0RHU1W0npe292 >									
//	        < u =="0.000000000000000001" ; [ 000034736741462.000000000000000000 ; 000034742196707.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF0C0FA2CF146296 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3461 à 3470									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3461 ; u8E7F30ck39z5OvjaC58MLG4zb83P6GFR8i54aH6m89uFXj3X ; 20171122 ; subDT >									
//	        < 5Psa33CtNp0yxYj4NM0CK7Leo1u6D3rxqTMsgORi7sbklvjh92d6hlhL5sU814gP >									
//	        < bXV7h4wx3mkW6ZD3zly4rs6qx76lT7F8kNkRL00oSr12p7FD21XtE6lZLxvWzA1u >									
//	        < u =="0.000000000000000001" ; [ 000034742196707.000000000000000000 ; 000034749016591.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF146296CF1ECA9B >									
//	    < PI_YU_ROMA ; Line_3462 ; 8eGV87fv6nIaZ49QTlMQKcR30i09HKuckDcyIaCWnx725RQLb ; 20171122 ; subDT >									
//	        < 1X235t483PeXigkKW15HuF6vMugA6pIx1i9I44hh9H39GJ8FM8WmbgBQ6XNsx3f9 >									
//	        < 7PH6ZPdv0YFl7hUq39EUoGPNO6HvAKv9yC74ogRGQt7NcTXU6xjaQ21C6J6yCeS8 >									
//	        < u =="0.000000000000000001" ; [ 000034749016591.000000000000000000 ; 000034755807424.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF1ECA9BCF292746 >									
//	    < PI_YU_ROMA ; Line_3463 ; 6KH1S9HMNXx198Q3i7pJ60A3P2btC7UmfX6c0Y6G1w36BKrIf ; 20171122 ; subDT >									
//	        < 2eaSoM6L3t2bFGqAT8OOoOtel7L9IM8N2h9GS8bC14dwR82D7wybk9pgS8gX2Nr1 >									
//	        < 2ugCiQ41wSo68IT85oEBA72lI6dV0iJ5P501Zjr9Y6JmN04k29CAyzP2pFbhT2ni >									
//	        < u =="0.000000000000000001" ; [ 000034755807424.000000000000000000 ; 000034762570471.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF292746CF337917 >									
//	    < PI_YU_ROMA ; Line_3464 ; JTl376D56hWE7Vpw25b4DT8pEE8Zr6q9gV49D59qsWQUmE48G ; 20171122 ; subDT >									
//	        < vJ7X5t2UVVMFsCtC4a2Y3Ook8WhIE85CXey5QG17l0ASrO4dsGXt2ThYyBeF3PC8 >									
//	        < 310cdDm6Y1lD841hRpH0s6Y8U0J2WU1tq4Bd8kl3PA0z0QXys1d35Y22kPil4760 >									
//	        < u =="0.000000000000000001" ; [ 000034762570471.000000000000000000 ; 000034776378655.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF337917CF488AE9 >									
//	    < PI_YU_ROMA ; Line_3465 ; pp2w3n0hx0KQHKdPivzz5XzC95YX9P0OoLy3GdtAU7e9t05U1 ; 20171122 ; subDT >									
//	        < kHa06JAv1o8sj00pW6rXwsz1mXO4AZVA0eZxyH76vxtB0tuP1gEpc9YFvx981A3R >									
//	        < 9i60ods7Nn20Ao2uIc9rM8e4c7l0C2jk7hSb34kO9urkBvyV1S7az4L8ByFLD9Y6 >									
//	        < u =="0.000000000000000001" ; [ 000034776378655.000000000000000000 ; 000034790531624.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF488AE9CF5E236A >									
//	    < PI_YU_ROMA ; Line_3466 ; c4LWe2PA4aR667Io7v31RgZag5ZqJc663vm2jJrBZm9101gO7 ; 20171122 ; subDT >									
//	        < H2RYin6scm5zfAJJ9aZ4zuh0FDx7PsBJizYnwzSPz5MkUm3Vel66aZyU7vi0Bk1S >									
//	        < 2Uh28pK4Q32CS3r9JW4bprQ9dgJ5ZuoIHDlocgDxqW9z6iJbMPF2J2ZoWLmU38dx >									
//	        < u =="0.000000000000000001" ; [ 000034790531624.000000000000000000 ; 000034801940844.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF5E236ACF6F8C24 >									
//	    < PI_YU_ROMA ; Line_3467 ; 9V561HHmrTAWud8js8Ta0wO10cTovYZHY8G5Gv7Obl4Z61d08 ; 20171122 ; subDT >									
//	        < LQaCI81Jejx130b8oX9NGVoIi5B1v3CZdf6jq9VB02206ck54lTPy4SCNR7dJvWh >									
//	        < UuNdyU4LdujiXrD3Ba7dX0S88760dYoBbEy6C8fS62GIr6230Yzpi5W0FEVc525c >									
//	        < u =="0.000000000000000001" ; [ 000034801940844.000000000000000000 ; 000034815833633.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF6F8C24CF84BF03 >									
//	    < PI_YU_ROMA ; Line_3468 ; aUPrqD9l8BHlC8108c16IJ52D4T7rKYYwDpBy8UQ3MIj4DtrP ; 20171122 ; subDT >									
//	        < Rk5Ka024YfF5O9DS0Dhxt60e7HPWZExbG9T95ihqLK7Nw42x608zIWqPsDXJz9n2 >									
//	        < 41xomn1L91u4p17AyoeCWcU86HAKCZaB2m6Zzt2W3KF1fV41rr3C8z8FnD5EPqJ6 >									
//	        < u =="0.000000000000000001" ; [ 000034815833633.000000000000000000 ; 000034824155234.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF84BF03CF9171A3 >									
//	    < PI_YU_ROMA ; Line_3469 ; 99T6R74r7uZgY9L8Chd4aRP7293qXACpgEWTb7dWowNp582IH ; 20171122 ; subDT >									
//	        < 16TP05pX66t3WM2qY26hX9Y54d2w3VUed221u780bTaAIdg6sq6jl99thFbDi2qP >									
//	        < k89Ahq458Z7AtaLm2746D7G878b7651X6tSp92VmgEth75uSushdG1MoC4zwPq7F >									
//	        < u =="0.000000000000000001" ; [ 000034824155234.000000000000000000 ; 000034834127735.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF9171A3CFA0A925 >									
//	    < PI_YU_ROMA ; Line_3470 ; 8uaa610Gb8grq3ET017Sd4rI95Os7qy2KRcDHrZO9zefp9VsP ; 20171122 ; subDT >									
//	        < Lr7fEG07b936x2e1WSNjpt1XTo8t8cBix3mUf91M7JhC8aBPotLSaR8oOu8A4ku0 >									
//	        < 08uuy0zvb29MP4820sm01zC55FwJ0I4tqKS4rmV87gc5C5RJ1253m87Ip7X45e0Y >									
//	        < u =="0.000000000000000001" ; [ 000034834127735.000000000000000000 ; 000034844991748.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CFA0A925CFB13CE6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3471 à 3480									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3471 ; k3zBs6J26uTx9F74fWib32w5a8u8H6OaMw1440ERwDgge74v3 ; 20171122 ; subDT >									
//	        < mCVWMD32f2gdiol5DaK3h6zBXDzkS08pQ4jg4J9O1H0u38c6YuTZJJICFFyBcwnO >									
//	        < hpK8k8gyFrWsA00T00lO8lI4gM2Ia1zuMzcQa7LdvnhlrIjF882bVI301vb13nYU >									
//	        < u =="0.000000000000000001" ; [ 000034844991748.000000000000000000 ; 000034852646060.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CFB13CE6CFBCEADE >									
//	    < PI_YU_ROMA ; Line_3472 ; 6LnKnVT4z3307281B3VBYL1gV08ncwj9pFAIF38uF1fRV19Vn ; 20171122 ; subDT >									
//	        < R7P92InIWu0e5hppOOrN6787A79tX9bnwswIRot34b3lvXKUxz730I8zj3mTG936 >									
//	        < iH3T7mmUyIQL65xFA62gnXO3WefV94pr00d7n2n1TZ0uM92tMu5FX3RW2qTw9A1f >									
//	        < u =="0.000000000000000001" ; [ 000034852646060.000000000000000000 ; 000034864671911.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CFBCEADECFCF4477 >									
//	    < PI_YU_ROMA ; Line_3473 ; nZX4IE633WJvwc4ayrAXdv2C58R3yjaUK3x829B1Kud6cF599 ; 20171122 ; subDT >									
//	        < Ue71ya71z42JawC9HzT8LuM2MY5pobpT9QEK5xRmXk0RW7AgZ1p4ECLgsoK1Lncu >									
//	        < 4vzHDytcPZolZ48FAAqzF77417YchU7q1bzDDSIKcoHNT67C4j4H4X3n310SU5En >									
//	        < u =="0.000000000000000001" ; [ 000034864671911.000000000000000000 ; 000034874040216.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CFCF4477CFDD8FF5 >									
//	    < PI_YU_ROMA ; Line_3474 ; 9U98WafgqG8dAmcS5YI3ikKSlO2xlF0Yr1E9n1w6uT467sMhU ; 20171122 ; subDT >									
//	        < 7w5ile0q6vK6tPkcRfhgZOhhy40804iEVznwvPWPCHb154k97cLHohTsFqOsLbLi >									
//	        < A7WHnt2592V2U0O10L67ZjwR181c1C5A1NIbKBGp86Mdt1gU7XubI97z9TcP0hvE >									
//	        < u =="0.000000000000000001" ; [ 000034874040216.000000000000000000 ; 000034888597338.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CFDD8FF5CFF3C655 >									
//	    < PI_YU_ROMA ; Line_3475 ; HRgIF9BIV7z4HXOX3E3ANU6GR679m90vzar4DN56eV9K7Y19c ; 20171122 ; subDT >									
//	        < zdLdTzD34DZ6j2A56oqSA5s8td6bS8mxpbw5jfGiPs7MqWhR9VbcsJNuX005mp3k >									
//	        < K9M5y0v1lE6SBf3Lmh3jP32jbXoHUlx4P81mkbiIVJymkvepyU0MO523Fv1gNxYE >									
//	        < u =="0.000000000000000001" ; [ 000034888597338.000000000000000000 ; 000034901546153.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CFF3C655D0078877 >									
//	    < PI_YU_ROMA ; Line_3476 ; 1H15CWHQEVid71j0y3lN48l628X2P403QC5HoQ63ATpeNtp4M ; 20171122 ; subDT >									
//	        < LURTxs76aL63Jfgbz8HnMLVDhnes3RNQQzxjgDWLtjYAAH7UI65B8vH6yK28Q39I >									
//	        < FMexx4P1BE1095w9oI4UK6XIHyvh3uGb2ltpxl21ooFZ2Nwj6wodcQZx33UeDLI6 >									
//	        < u =="0.000000000000000001" ; [ 000034901546153.000000000000000000 ; 000034907939874.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0078877D0114A03 >									
//	    < PI_YU_ROMA ; Line_3477 ; Hv4HQtprXhroBb6A4rpn3r05NLvv4mn9YD8ryVvgZJ2373ik2 ; 20171122 ; subDT >									
//	        < OpUrCqCzQpPOHATN3k5ipuF0Ti68g7q3uAT0ft2e6cBdu203RZwaiq0uEdKkeQuV >									
//	        < 6wY0TSf2uoBMoLJjolw1B5Qv9GPy7V584CM6661T6nqN9IMUSg1kjE4d1GsHfAU5 >									
//	        < u =="0.000000000000000001" ; [ 000034907939874.000000000000000000 ; 000034913133186.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0114A03D01936A6 >									
//	    < PI_YU_ROMA ; Line_3478 ; Ol4khzy8W7h5u11L659B3YCfJCRUBiHunQr3CMr4fBJ2w48I4 ; 20171122 ; subDT >									
//	        < JoXy08rqWC3JjYGCEMWS2O0SF4f63m1rkSjvV6HHK590GyUk1ZN8Kz4vsnih4H6H >									
//	        < Px8YtdCjLu930D591igaUZ5dFW41UGlZcVBUx8qj7RLc69bt5ALLK1ATB2mOKLOH >									
//	        < u =="0.000000000000000001" ; [ 000034913133186.000000000000000000 ; 000034925033739.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D01936A6D02B5F4D >									
//	    < PI_YU_ROMA ; Line_3479 ; PFPrZ624Ob4tWX348X05RvA3Z7kMX26XIuW5OML67GXl9MZkN ; 20171122 ; subDT >									
//	        < sBu8k4x2Arb735At5q7Hm25670o1KW0PGIaoTOQ8f097J0Nk895DBh83j1X6ulg2 >									
//	        < 28L3S03I54SQGBb81Xd1n6HLr8290IkAbyQaU2Plom0EE6c1bsKqY2XP79xOku5Z >									
//	        < u =="0.000000000000000001" ; [ 000034925033739.000000000000000000 ; 000034937825953.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D02B5F4DD03EE443 >									
//	    < PI_YU_ROMA ; Line_3480 ; en8Rvp3401ZvVmA59EIl1L7BpuA622w9gkP07e5BPRBA8nzfD ; 20171122 ; subDT >									
//	        < MwaVmuTRaIYHGs6EgxMNfgK9QS1Y33RM2I49ZDdWG45RF7maW3b8GGhGmwZxEtU1 >									
//	        < 5x5To8QZRZdSG59qK033rp0BUk86L8MRA8R42fzG3875Ck86N1oB9513etidG8Ft >									
//	        < u =="0.000000000000000001" ; [ 000034937825953.000000000000000000 ; 000034945752690.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D03EE443D04AFCA5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3481 à 3490									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3481 ; MyUnsg85r211A0cVcCu1Q7CB4IkjwtQFvCjC7XC0p05AAv6Ib ; 20171122 ; subDT >									
//	        < YZqI7Kr2otNTxN7PdPtRddrAG9nvS3Z50OaIPG8trNyzzToYyUw8sJI16iR4nXOm >									
//	        < 5jC3YeAAky1h125hIIVbf4UkqKdKBJ7C5f4y1o42n27gK9C4AF261jkH42SK9gMt >									
//	        < u =="0.000000000000000001" ; [ 000034945752690.000000000000000000 ; 000034954446880.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D04AFCA5D05840D0 >									
//	    < PI_YU_ROMA ; Line_3482 ; H180pSv8043HfhkrcQ209H3494K3GLbqhWCxCP8c163tj5U0U ; 20171122 ; subDT >									
//	        < nz77W678o7C5B0x1i3754sD621825Fw0qWj6JEZkv80Ts5OxNLIqNaEL39M8FW0v >									
//	        < 882tMzF3UAa6Msb8O35mncC31491iwHd8jW8jlkM89T5fPHw0CAHz7e0Z96zN295 >									
//	        < u =="0.000000000000000001" ; [ 000034954446880.000000000000000000 ; 000034968278475.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D05840D0D06D5BC7 >									
//	    < PI_YU_ROMA ; Line_3483 ; 1D8LER5izlgTawJKGe2eUgILmmGlM0oHC0GfT0F5K7m54g4Uj ; 20171122 ; subDT >									
//	        < Xfa6T5Xgsb0FSS89q7oGRG304sDVXGR8tpetizWBS0u37lod3u3x4tB7825g68ib >									
//	        < Q85h64vRUpWUX1Z2J03hVx0y8NHn0h9LicdWQ2Efn12TITm1rdvi7uBWK6KRj6BA >									
//	        < u =="0.000000000000000001" ; [ 000034968278475.000000000000000000 ; 000034982409537.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D06D5BC7D082EBB9 >									
//	    < PI_YU_ROMA ; Line_3484 ; W4XX21Ho0JY0P2cC4w4vcgG9mDivj1y19FIb0NVC9320g5e2E ; 20171122 ; subDT >									
//	        < 7MUx14l9Qs7xMQ5uP7YqI8DI2Eoge7dYTkIm7s4Qn859Ulvy0dY9sOAQOKJ3n30D >									
//	        < J6Ox45ZQ442nm1SRg8jb8rv46Z6q0oOIuBafroQ91MDwVA0iBu0433bq65N39qq1 >									
//	        < u =="0.000000000000000001" ; [ 000034982409537.000000000000000000 ; 000034990856724.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D082EBB9D08FCF68 >									
//	    < PI_YU_ROMA ; Line_3485 ; L1okIrt1Tj45OB1eqJN3htIPBi2OB37Ikj8pHzNfsIMy262U9 ; 20171122 ; subDT >									
//	        < 11h4keU5P6QqSdu29T6T3F8q668EFteVGBs6AubwqcOp0fnwgigG57Zmh245ulZu >									
//	        < hLH8w4EA04H9U7KWu5pUY27U1Rv8m1m78F8BJa70oiqsKVtn0LgZxe73L14UhLMz >									
//	        < u =="0.000000000000000001" ; [ 000034990856724.000000000000000000 ; 000035002086607.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D08FCF68D0A0F214 >									
//	    < PI_YU_ROMA ; Line_3486 ; mjtrjHTy8yj3gVURiKK7gJWBrmvZqCkx6f0Qj4g7QG34q19OW ; 20171122 ; subDT >									
//	        < NDPKSC4zMKSQQW41dPzb9Ly366M21m656N1I83Zb37XEIe9n2xdEZ4DpE456H54u >									
//	        < 4zIu1323m6Vo4Ygx8V8HQe7kW3XSxp2wzzcR3Dinlb8Wbpytn0bK0X43rr9Cr923 >									
//	        < u =="0.000000000000000001" ; [ 000035002086607.000000000000000000 ; 000035013183933.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0A0F214D0B1E0F9 >									
//	    < PI_YU_ROMA ; Line_3487 ; m5lkUXjMqUDq4JT7k613JhWaD0dbz8P3DvWqjc43wpeZUUVN0 ; 20171122 ; subDT >									
//	        < Q77DasZDY92e63LTAvxpo1659LI8h57ek2w1ipF458MzLV2xwILIxsaBQK6TtLUh >									
//	        < t4we8ju000tyrLeANpnN4i85D2vaj753LgeOZ6f49RH2QBSwG9900f9bQG26IZ8t >									
//	        < u =="0.000000000000000001" ; [ 000035013183933.000000000000000000 ; 000035024462367.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0B1E0F9D0C3169C >									
//	    < PI_YU_ROMA ; Line_3488 ; oxm8Up3NVaX1c976Tc7i6uGF4KVg28rl4x46q9Mf902h968DZ ; 20171122 ; subDT >									
//	        < 4xmQ12zpNm1z56j6VQn9tEO1waNc9W86nenP09B6wUQ83IcXm8bWTPLEk7eD464v >									
//	        < a0UuOPhv98by5m0lrOlCM1SW0xM4y8V4jrPO64qaj3QPpjKKmNFmR04eLRA2e555 >									
//	        < u =="0.000000000000000001" ; [ 000035024462367.000000000000000000 ; 000035036922697.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0C3169CD0D619ED >									
//	    < PI_YU_ROMA ; Line_3489 ; ovn5Up3en7Mj0fGe36FCW6IGl2s3UzwVlRRc7geB8Fu41SFRO ; 20171122 ; subDT >									
//	        < TDRlMn9U2T80atOprq247Psqd7s87e2m969356JJ1XV23u6iDppLQZpL2XwyQJtD >									
//	        < 6ZCW5fJuo4uOW5zB91iFCEe15HPehEbn833sgM0DdeoCDCs0SPEa3yNymKkYGaKg >									
//	        < u =="0.000000000000000001" ; [ 000035036922697.000000000000000000 ; 000035051192199.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0D619EDD0EBDFF3 >									
//	    < PI_YU_ROMA ; Line_3490 ; 4D3sMBt8n4JEF44fc2zU2XUtKS7z64iDPey8T08g0837cQ4m0 ; 20171122 ; subDT >									
//	        < n022S87124O0N8NRWjzsLxPd2agRN4FTQg8f91G17iPZEV7y53Q7Q4L8jI2Y4Dk9 >									
//	        < 8iQ9VSzrq486b7q3Jse29F5F6Ybp7m2mEIh25OWN5kppfO964v5ixP2ZGof5dJ5G >									
//	        < u =="0.000000000000000001" ; [ 000035051192199.000000000000000000 ; 000035060833821.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0EBDFF3D0FA9636 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3491 à 3500									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3491 ; 41xOJpS8JC0NNn0ja07N7acY3AK75Mgb0X8SHav4ypL18uhhY ; 20171122 ; subDT >									
//	        < cC5LGHOE81NY33f0LhvtTBvOHA7POko652t9e49d97mJeuJQ1BT40TR9G7Xo7EaA >									
//	        < e1og0kCaymXuOUR5pG06Z8R473uyDbq5S5gkFc5T1wH1rv6Tam6821jR3MblNNoC >									
//	        < u =="0.000000000000000001" ; [ 000035060833821.000000000000000000 ; 000035075075895.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0FA9636D1105185 >									
//	    < PI_YU_ROMA ; Line_3492 ; Ryj38b0TWKsp7a1yphvRPxgiyCD296soRmk4XjghQ1R4YJDoJ ; 20171122 ; subDT >									
//	        < Gf72ChxdVwz7K31J7QX73HBfLOXF8114B6h4T0zL029ydlGPqcz0Of2q7YP9xGvz >									
//	        < 160VQwS1kkzod30dZdR3W3KDk10VELnj4YQ3BEBWTedXoBian2fuX9v8qNsNrbxQ >									
//	        < u =="0.000000000000000001" ; [ 000035075075895.000000000000000000 ; 000035080575503.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1105185D118B5CE >									
//	    < PI_YU_ROMA ; Line_3493 ; 8M7PSxP6uk7404UyUfkxU5gV9JFTe3lhrxu7cBppPtjjLHEGV ; 20171122 ; subDT >									
//	        < 3CX0I2W5Bl0i97yrIW9mOfd172M3RuFrTB9ktO2x2l94bRLlNwsbxLTDM6i2gX2c >									
//	        < UdMJ6l0Z9t4pKB25mzKkGv1f2XY4FtwF0NvqT75Pv9g43cD9dWvqf7YwnGcO5TNu >									
//	        < u =="0.000000000000000001" ; [ 000035080575503.000000000000000000 ; 000035090268062.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D118B5CED1277FF6 >									
//	    < PI_YU_ROMA ; Line_3494 ; K6I29tiADgFu641bxKwp68H6Vocdn8eKyjr76LYiTS3d4OTpd ; 20171122 ; subDT >									
//	        < 0tSsoQSPUF9Fq7DDAabU4l6U4TJ0GwVspxb8B4780gqCOmEEI4g1Kr97ELEjkl2N >									
//	        < 15TO6TuM9toc81Q0Ac9qyUDqMx7CbBKiE319gi63B67y906t4tqa2KKM5E6yt6E6 >									
//	        < u =="0.000000000000000001" ; [ 000035090268062.000000000000000000 ; 000035095838189.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1277FF6D12FFFCA >									
//	    < PI_YU_ROMA ; Line_3495 ; UItYwB7241uZ30xP7C32N05o74jj77N87j781vv7ivkyw7Cyf ; 20171122 ; subDT >									
//	        < 5cZCy2DV9sG8V21XO3jhyI27I9mXF2w3RGil76CA695505zXh08SWIVvOwxsR44y >									
//	        < w9Lyqpf3blE0UG93Sf1m9BOY6P9tzJ0fy2COBsT565p1T55F390nJWfTGf5ThS6t >									
//	        < u =="0.000000000000000001" ; [ 000035095838189.000000000000000000 ; 000035105342096.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D12FFFCAD13E8041 >									
//	    < PI_YU_ROMA ; Line_3496 ; ekD7n9l82W0DCF3Lgw7huvR3QL7kKd9kppU7Dp84Kslp5PMLO ; 20171122 ; subDT >									
//	        < lcPN9CuHjX1lkeyA4dH77j9p33SAH7272iGl8cea9DUx96h67BqXGV1uM3dwXvSZ >									
//	        < IS3i8fx585l56Ep4p96J9alMqySKQ9q7c73kDWKVrgg0wd55I9O9pVUn5BGt5H55 >									
//	        < u =="0.000000000000000001" ; [ 000035105342096.000000000000000000 ; 000035113722023.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D13E8041D14B49AA >									
//	    < PI_YU_ROMA ; Line_3497 ; KpROBjD65156ucXR3ruMU27XiI4nAq3Zfy5yR7Q0143V2Keri ; 20171122 ; subDT >									
//	        < bE562v0WDbl0EovBE05qEO5479nMSsAZlPX7b0lmQyme48eNMqbTjmCYbO3t7Kl2 >									
//	        < dzok65HseMGTO3s3A7t5H4H5Ku1W8SC8jff49qJ3Q4UA9G8A1dK8Ro6Y25cHcDai >									
//	        < u =="0.000000000000000001" ; [ 000035113722023.000000000000000000 ; 000035120131726.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D14B49AAD1551174 >									
//	    < PI_YU_ROMA ; Line_3498 ; ZIsO03FU7257VFRnW8qI0oOp0Lub9eXw9hnge4t11dj5y4d24 ; 20171122 ; subDT >									
//	        < 8PO8V8JFMG63v7P1N3xgg5M3PkAt6m0qCO7mT3Ma2kHWm6B02MC9bnCO6nRf328P >									
//	        < WO3TBf9Zun48yTPxC2D5ns85B8u38tRXHRA17XO70ieNNpS21bEWP0nT57sxwket >									
//	        < u =="0.000000000000000001" ; [ 000035120131726.000000000000000000 ; 000035131158588.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1551174D165E4D2 >									
//	    < PI_YU_ROMA ; Line_3499 ; q4Fb3a4QY5WeDIzP8dpHcIK21o95lFW5b5uIsxndy93Sm3x5c ; 20171122 ; subDT >									
//	        < U3VhxW7Qy9huI7Omb9ObilW6u5NjvRu29WCpO2emB75GpKVcSRYcrvFqA1kYASQZ >									
//	        < RgU0RM41vQrrz71b7Xv582II3a5vg1Y4K1wS3g7JqANmKiNEUlr0VZ37uViji61u >									
//	        < u =="0.000000000000000001" ; [ 000035131158588.000000000000000000 ; 000035146035956.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D165E4D2D17C984B >									
//	    < PI_YU_ROMA ; Line_3500 ; cY32wF7cJoaKH782psKAggZ40DHFgZrI5IY7hjgFFsh5TFP43 ; 20171122 ; subDT >									
//	        < fA7W5zi07Crt5j9C80UH96nz5z71pc7w17dLbHR1yNqqr3k748afxOvbU8NkXN8w >									
//	        < 1rwT2q0OXHYVc38xxgf03126k3Y3t82SCC8MjI6HQg7C9C0b5OtQ0pgMrenzx4j6 >									
//	        < u =="0.000000000000000001" ; [ 000035146035956.000000000000000000 ; 000035154024616.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D17C984BD188C8DD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3501 à 3510									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3501 ; KNg166TAKS3cH3dyZmb51v7cs02G1RJyc92x9A3ZW9fJn1Zio ; 20171122 ; subDT >									
//	        < nTb3rUbn94J6S52c7yc3HmkfQppiUvFu69CHQ2mXJnpl7N5qH8110sp3sxW8zZ0v >									
//	        < Z463L9AGlP2v6v4lkrbSUb6VUMWzR5D871bio5N30xatS7UshcRBeVrh0LKuk3Ll >									
//	        < u =="0.000000000000000001" ; [ 000035154024616.000000000000000000 ; 000035166120866.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D188C8DDD19B3DF6 >									
//	    < PI_YU_ROMA ; Line_3502 ; uhCYmU9o70W3c0Obj12F0UC3zeW6WjBF84m2ye2pF58P96TRD ; 20171122 ; subDT >									
//	        < lpsyi15KR4931QZOFlW687tV26PGR8e82VxvjxH1WFJX8G0j3UPkVoHW6zmoCSoV >									
//	        < 7C42s6BY995FG2MWB4G24J6N4Lon8Mw62fDZDGw5eyuyUyRiV15N7g6SN7n8iPIz >									
//	        < u =="0.000000000000000001" ; [ 000035166120866.000000000000000000 ; 000035171368682.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D19B3DF6D1A33FE4 >									
//	    < PI_YU_ROMA ; Line_3503 ; EJwO2POZxV7R8gfSnAW3xD7B5KVJCIpAM54YBmAk7GCvAlXa1 ; 20171122 ; subDT >									
//	        < oz9lV1rnKhN84TBmr529BMT9rCB69auqkIsq87u5fobK3oMN6V71F20CC1sXdghd >									
//	        < 5l55R1AQ7QyVr6yB0hHU0h0HJok3JbYw2f8bS5GUf88YVrLi4V5h6G9bxRV1YsBE >									
//	        < u =="0.000000000000000001" ; [ 000035171368682.000000000000000000 ; 000035183262021.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1A33FE4D1B565BA >									
//	    < PI_YU_ROMA ; Line_3504 ; 4o825T8QuaQiY113A0t0lk5hbWdSjDpJkYl7YKL8MdTRZIG7X ; 20171122 ; subDT >									
//	        < qxG2Uv73IrmOhxj0CJgMI3Ze8bt9dkzw6nmV4up92QdYRk1x2x64T4MIUj81e0Z6 >									
//	        < O8gMXGwV3f7p36cjBzq90A6q0deWubNR1z51Hpl9JqVnnY5SrPO55Stos8m6509B >									
//	        < u =="0.000000000000000001" ; [ 000035183262021.000000000000000000 ; 000035189574288.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1B565BAD1BF0774 >									
//	    < PI_YU_ROMA ; Line_3505 ; Tf5oem6id5sB55R27J7Hepp4nGUAlgmG42J4AM5wSR2JX6F77 ; 20171122 ; subDT >									
//	        < J42D3fllfVM65gH7T3Xh4Mlc5nHD9yDnCq2J75rTLFDbSQR2OxlR2BJy6EevyEnL >									
//	        < 1948eurLX5A3M6Z1Bag18h6HpkFJcR4mEpbTNibDMUa1HVti72914h66tRg6sO2z >									
//	        < u =="0.000000000000000001" ; [ 000035189574288.000000000000000000 ; 000035198503476.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1BF0774D1CCA76B >									
//	    < PI_YU_ROMA ; Line_3506 ; Ojpz1OE5Q9tRSG2MjU3tp03sxgm635dYy46jwU8555AfzRby5 ; 20171122 ; subDT >									
//	        < LAIbs9K5s0y5bsrSr3g533IGtWwLgo5Qpk05WS396RLRrGY4S3Y4AQyGaTYWf8cd >									
//	        < fPVVD8Ag3UW4futjQfvY3Gv42h3k6H9O5H94H333gP6FwNcNv95si3fj406e8gQ4 >									
//	        < u =="0.000000000000000001" ; [ 000035198503476.000000000000000000 ; 000035208784504.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1CCA76BD1DC5772 >									
//	    < PI_YU_ROMA ; Line_3507 ; PqCXKYEga4x80ZpJ5ot1xBKN2NVkOxabh4Lu9K4oT7S9lUU8g ; 20171122 ; subDT >									
//	        < Ozn34Nk8k7d4S42VQuN524dECIF28JcgIX6Q83j2PjVgY2zAT85cwJYGB0I6i4R5 >									
//	        < IeX4bgR2h0Jpd4I51ByV9YXs4b807v9t9ZIdKnk8FE6MhU8D7UJKBtHYn0v2Ie0j >									
//	        < u =="0.000000000000000001" ; [ 000035208784504.000000000000000000 ; 000035218087435.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1DC5772D1EA8967 >									
//	    < PI_YU_ROMA ; Line_3508 ; ba7MHEL723qtVAv9loUaKkQnb82BC6SPILJ89db4SvAnSkv1Z ; 20171122 ; subDT >									
//	        < 1G82s8AS6PsCZ3qoFC56JMk4Rvha65yTXfl8gn4SD9fPO4hTHl00m11J9BNbcCM7 >									
//	        < 3DHyoyeWp098V826J4lIk95JDHcpqYMP2D1t01lZnMTrVf4cvZ2GVj63Tklz7YsU >									
//	        < u =="0.000000000000000001" ; [ 000035218087435.000000000000000000 ; 000035232635997.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1EA8967D200BC6F >									
//	    < PI_YU_ROMA ; Line_3509 ; EL456V1y154P1vmLV7iKurBNJo801wKZ72pA5AdixU3y5wvNF ; 20171122 ; subDT >									
//	        < L9b38BUNXmkoo4sB57Id3Yk6JSvI6HnL6fnGqCCsm0ui97K19546ZYrS4Wwc5Acd >									
//	        < YJg6239P01W49037R9z50uG0txOm284N83f9IitgcJeFeEzAyh369a5id0ujpOly >									
//	        < u =="0.000000000000000001" ; [ 000035232635997.000000000000000000 ; 000035239884069.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D200BC6FD20BCBB6 >									
//	    < PI_YU_ROMA ; Line_3510 ; 48XMMhz9D4v98kCE78Qz7Bm7oyz84FCGspGL2go12ZT6i79Md ; 20171122 ; subDT >									
//	        < J9T6mf38ivn4h5K7Ii3Ck9t2irFmHA490NZMu2x3NC7gs3Rcq98ju5CgCJN98UK6 >									
//	        < 2e4rvLq6j8666oPS7Si7gPl2Cv5zz028G49SBDTL84k54V72WwSJ6D3dgSSm8w4i >									
//	        < u =="0.000000000000000001" ; [ 000035239884069.000000000000000000 ; 000035245916507.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D20BCBB6D2150022 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3511 à 3520									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3511 ; J58MHk3uOgR1T5eGYCrHvsSY1j2VCKCr0Z0D3iBLX5loKEq1t ; 20171122 ; subDT >									
//	        < HL8m876SsiUc3v9z263GR9qZleCns2r2sZFC8J304r4Y2mSr906A1J6fG3sKlr3t >									
//	        < oq941zMykCK8cS2Du4g0lpOC0513W1sxvTf0A2792nGPmnBi53D7W0tP2Y1eGA7F >									
//	        < u =="0.000000000000000001" ; [ 000035245916507.000000000000000000 ; 000035254146958.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2150022D2218F27 >									
//	    < PI_YU_ROMA ; Line_3512 ; Mk5yGw25oznopYWKeA7gAeu7ZK2Z762Vf3yQ0Kt3U84YkXQ3f ; 20171122 ; subDT >									
//	        < HQk22J420b9L2M0pPd1mXqcLfW8ULaTxfYE7gI7O8E1V31BSZ9VBXNqJ0xjFsbN7 >									
//	        < p47VU8Z9N48F050g1AEpT6Jf40Qdk68L4AKrsQiot5c7dViKVn6969100sLpg3a7 >									
//	        < u =="0.000000000000000001" ; [ 000035254146958.000000000000000000 ; 000035263082538.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2218F27D22F319D >									
//	    < PI_YU_ROMA ; Line_3513 ; 6UK5BFZNqdTwZ4baH8164Tm59JXT4DFHR116Z5o0LsLgu2YrY ; 20171122 ; subDT >									
//	        < iR8Dy5S7OqPaG0Z7EHZvBzn56b6VVPf01Uz25j4g1rqlmvU8TjxYausK1y0owu1o >									
//	        < l25R8ZbIC8V7A5YmtCf1heys8u2v5N9sbQ3c71Nyta379fybRzbDHD2Uq55leXeV >									
//	        < u =="0.000000000000000001" ; [ 000035263082538.000000000000000000 ; 000035270770561.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D22F319DD23AECC0 >									
//	    < PI_YU_ROMA ; Line_3514 ; yasfu961nUwKx978b82iNkWh6vbXO3867P9Q4Uj291RxF5a5P ; 20171122 ; subDT >									
//	        < Cre2960Nx8f8p7nH2S650t0M54UON4t0EHjU9630bgX2pZDf152hioV8kf3P5hoD >									
//	        < 56y83hsSBT9zzHVwWhFvjDzShhd8TvCty9vkmU4G3kk3TRf45AhOi8iKt85B6996 >									
//	        < u =="0.000000000000000001" ; [ 000035270770561.000000000000000000 ; 000035279692020.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D23AECC0D24889B2 >									
//	    < PI_YU_ROMA ; Line_3515 ; XXFw9R32NP1M81hdW7XFH08OOYS3nLemG6Rd2fGEzJz1o1Ec5 ; 20171122 ; subDT >									
//	        < zYLs1W6U26dkPk7DgSrkM0LIz0s2QiNViLv51C9XF2ayzdL4Rs9iATW9xR4J1Ll3 >									
//	        < ZRE4LM2mRqyqD606Q4I788zvg1bjh44z84bGRI3TFF7ebbV3QV7osXwe76mLYxHE >									
//	        < u =="0.000000000000000001" ; [ 000035279692020.000000000000000000 ; 000035290389562.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D24889B2D258DC6C >									
//	    < PI_YU_ROMA ; Line_3516 ; A2ik733iyJWLoCJs2Wd45jO9UZSYZVjb7l7c7bUE6F41756P4 ; 20171122 ; subDT >									
//	        < vFnS9586nw3FU47QUG4zYebtejc8w184N8DfQbYPaD7x6966e35JaJ2g1B4Ol5dt >									
//	        < NO3c5G4B22V5JcdH6KjR55F8Dlle8qXw7xq9DGDIQJEt9IHOFXM40oOVrW430W7A >									
//	        < u =="0.000000000000000001" ; [ 000035290389562.000000000000000000 ; 000035300856699.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D258DC6CD268D525 >									
//	    < PI_YU_ROMA ; Line_3517 ; l5JB75AB0zmyS9b0mm7Bk18aoDPZdSL5E0Va91AT1iLo8we5s ; 20171122 ; subDT >									
//	        < EDw8MGY8kBz00KPoWLo8P10VyOe6dGfeIDneF46KkFXn8p60eNsR591A5NrMf9Q4 >									
//	        < Yt60Bc5ZDf0pjkW75aMmHdQR97Z8yLPKx5FZ24FUkl5g3cyWTcV9e7diAl37w5Jo >									
//	        < u =="0.000000000000000001" ; [ 000035300856699.000000000000000000 ; 000035306759900.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D268D525D271D716 >									
//	    < PI_YU_ROMA ; Line_3518 ; d8YR0A841GKuPmJdo12Z3ND0uL3L5wBoxFe0CSPKHnwRjCP8v ; 20171122 ; subDT >									
//	        < 28c49Vmb1V8V7V94rihBaNNMu73h1MsJ0xsa7Bp2IJ4HjGB82FckNHxU5E21O6C7 >									
//	        < rV8UdMQUR354ZGY0BDWls1TD2CTobC18ZfyXzK6P6QqwLELxo4sEV7zhhuY3Py50 >									
//	        < u =="0.000000000000000001" ; [ 000035306759900.000000000000000000 ; 000035316991492.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D271D716D28173CD >									
//	    < PI_YU_ROMA ; Line_3519 ; n588o6A6UtNGd2mGa9h8lzwc477q79nzLmeXU9kUV57VOL8KK ; 20171122 ; subDT >									
//	        < 4VJro88jGsH2l983xqa3iv74l298i2F0P0qZ044UgrGS9MwrD29rA7TV0i4H0G4s >									
//	        < 5C0Npnz1902Qc1H83o5Q1S9Gg6SUqI7ySj4BUcsUEkHSq1kJ5Ro69AIh569Mm2eq >									
//	        < u =="0.000000000000000001" ; [ 000035316991492.000000000000000000 ; 000035324934788.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D28173CDD28D92A6 >									
//	    < PI_YU_ROMA ; Line_3520 ; 88E2P7ig17h4e2Etx4syu8VL50YFS26An1EbNZ1xuPGgJ1MP0 ; 20171122 ; subDT >									
//	        < hjN7M67oi7EMMM21fORXkvbnZAG97DRi8R45VGUs5N948EB21axl96Sg70iC31Yy >									
//	        < 87105kW253rOwGDFnmyCi2oaZqo86Ll06GiSV0dOw1cs8KzuRA2RrI04O38YlxtG >									
//	        < u =="0.000000000000000001" ; [ 000035324934788.000000000000000000 ; 000035332238749.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D28D92A6D298B7C2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3521 à 3530									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3521 ; H8y88wX9rUJQa9qj73nJ74ZWNvpo3hjwFGIge4k66j44VxSe7 ; 20171122 ; subDT >									
//	        < G9BMhm2IaSwTW27iK8UVr65P19JUITm3E1v47HM5dfUhOIi4MD6koW894rtfr72W >									
//	        < 97bU74h29DqQZojKEXlPFSB8q8341pZ1TW9DoElUp7i66KGVW7BO7J7Q600VxL34 >									
//	        < u =="0.000000000000000001" ; [ 000035332238749.000000000000000000 ; 000035338098178.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D298B7C2D2A1A899 >									
//	    < PI_YU_ROMA ; Line_3522 ; Dd99I1Yvj0AF0G2ZY75v46hq09RwsyJYU68TeoM2J2xmMJrvm ; 20171122 ; subDT >									
//	        < i1bQJtH6j9GaeiWUuv2x4ok51Tu9dzeQmY2a8f06e0nAnVrylDhDg5D1A9C0pa9p >									
//	        < 736UaFmxNk4RON14hXi65kxckbFLeS9I4887YcMn3g4aL543WeMp29eCRiJFvg3Z >									
//	        < u =="0.000000000000000001" ; [ 000035338098178.000000000000000000 ; 000035345579413.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2A1A899D2AD12F5 >									
//	    < PI_YU_ROMA ; Line_3523 ; d3p9feceCCeBprMJji1RXHUmqMW5Muy6p6MoaRueHihB2R9oI ; 20171122 ; subDT >									
//	        < iG81a2iF90EnNTJh6ZA60HTXEs5Qkc58t0m1q1Q9smDNL2G8clxIpowHRR5svJE7 >									
//	        < aRr017s0bWlXAq6NfGzegWdALAzwsRO8134fR6yX2We36Uy7X6628384i329ozfh >									
//	        < u =="0.000000000000000001" ; [ 000035345579413.000000000000000000 ; 000035357342424.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2AD12F5D2BF05E2 >									
//	    < PI_YU_ROMA ; Line_3524 ; 9650ol4h96Vyrwlh1w9m0VgE6f3M93Llbt4flD5y546S8W87i ; 20171122 ; subDT >									
//	        < jbU3779xadk4bhc0g7p0zWF6cqBMn6c25x2sIYsuo4FrD5aIyIMqH2M5C0za2D31 >									
//	        < Tsym27HNyRGVsE37WJCmuG7IRv70nR61hj71Y94n7PtMxU9vOdmzk038yv9PKh6q >									
//	        < u =="0.000000000000000001" ; [ 000035357342424.000000000000000000 ; 000035372014792.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2BF05E2D2D56947 >									
//	    < PI_YU_ROMA ; Line_3525 ; UH3MT8T1b96Fm1ceaI9193Y88KHi5ynW10JXp54J8Kr3zGc4t ; 20171122 ; subDT >									
//	        < 6I57t539CD526eCd4r10jDX1wx7JAPi2R24mHC8l3kXoOxgrE980KzT8jU0294aJ >									
//	        < J2a0MFCe254ETJ9q0rhvOG5PnCy0sn4T0c5yIFEfSNH1P0dM9O8pv8b7A42cX334 >									
//	        < u =="0.000000000000000001" ; [ 000035372014792.000000000000000000 ; 000035383369187.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2D56947D2E6BC96 >									
//	    < PI_YU_ROMA ; Line_3526 ; B8G6Jc53YSG3X8uk253fQmUngD20z0iCM5K4q4ZnIq0InI9Cf ; 20171122 ; subDT >									
//	        < 0EP1V3g289UZ2D1d5uPW4B7QA36ha74481B860S71yZ6SnOcErG7lhs8sw71MUvJ >									
//	        < QDqC49Y9e8TNBA3tv6BM8vov1D8AKgyoL29Rgv81c3D0N3dtf3oXlBw84cLGog1V >									
//	        < u =="0.000000000000000001" ; [ 000035383369187.000000000000000000 ; 000035393743747.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2E6BC96D2F69126 >									
//	    < PI_YU_ROMA ; Line_3527 ; 01d822Cm9A4U7YJ98Jt79Wc7H9XQ57h5Lu2kFD3N9qkZC53Jc ; 20171122 ; subDT >									
//	        < xW6Su8w75dhO1KHgrZ0HiCMf03f5yuz16FvC3EB1zqALZ41w43qf92N52Vm5Sytr >									
//	        < k8oRxSuB2W2t1a8C0cTvoTKoDRG1zH4Fo99nPvofcddHptFvUG9038X8UikWC58e >									
//	        < u =="0.000000000000000001" ; [ 000035393743747.000000000000000000 ; 000035405527295.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2F69126D3088C19 >									
//	    < PI_YU_ROMA ; Line_3528 ; YMf679iz3k86E16gw91sZ961OF2oW046W1O2q0LWCb0zjNPGp ; 20171122 ; subDT >									
//	        < YVK1MR0sr9u01M4tROnHn188x7tE6Ror5y3z9ZF4cWH2t81f18b4Zf2NR54b3aTq >									
//	        < ytX6LOeVELaH6J8s41qH733pBSL760Vq6DEsS6SnfxUk6ieZpaFu0pzsJqx4a6d8 >									
//	        < u =="0.000000000000000001" ; [ 000035405527295.000000000000000000 ; 000035418165896.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3088C19D31BD50D >									
//	    < PI_YU_ROMA ; Line_3529 ; jgV754w0O89o9w605VRyi4ARpJ2oGj6zM1OH2waf526w8w1oA ; 20171122 ; subDT >									
//	        < t8349R4QY2TcPAyR1tqCjxAL7BvOk0249SiXu7xf5BW5vK10AYxhm4K10XtZ42xv >									
//	        < Scas4M4pf79KtJzxIm722bn8TV6kgljzbaYKtxyW066w64mI4k0qE67J96WtUdf1 >									
//	        < u =="0.000000000000000001" ; [ 000035418165896.000000000000000000 ; 000035423600351.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D31BD50DD3241FE3 >									
//	    < PI_YU_ROMA ; Line_3530 ; YX7tlz5UwV3Yt1SFDI7x3P2GwyVN0538i3qG1cUGj5X253i24 ; 20171122 ; subDT >									
//	        < YFAO94x9385YMR9MHtU10X1uaunYAAJsfEzYxME3f41KA7Fr3qZ7JQ0oInZ6KD8x >									
//	        < 37iX7en8ZR4xO1g50ST7HGI6d34Q2C2V1663w1garl0uS55Qa6VUj9C7hLYBRsWS >									
//	        < u =="0.000000000000000001" ; [ 000035423600351.000000000000000000 ; 000035437156944.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3241FE3D338CF6E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3531 à 3540									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3531 ; 33DQG7M3w8XS0t0fw9PiF3HHtM70Q9hV6fjKiRQ3bofZtM3Oa ; 20171122 ; subDT >									
//	        < t7ETrsKq9tv2oG4NE4dL2PVUVE99VR7K9hwVc54I3qAFmru254ksZGNY2W4qEr33 >									
//	        < owP2VcYyzX2FgqCJH33bv9bHw0CE2zgU57C768HOL1QB5tbaB8YHmbWT5C5CLQ5t >									
//	        < u =="0.000000000000000001" ; [ 000035437156944.000000000000000000 ; 000035448465379.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D338CF6ED34A10C9 >									
//	    < PI_YU_ROMA ; Line_3532 ; zPg77Hom6f1z4z7vj51955Z77gXdMi15f55X22mHbcXZZt2DQ ; 20171122 ; subDT >									
//	        < ksbXkm5Y1PrqZ9VHKrI83w1lYk2X68FzH3IEgdlZ7uG971HggvUQoVrHn83vfRfM >									
//	        < v43K59ndjzEFPxPfD420k4ch6wE0FaD3S47ySL1rc1N1V2y6xpM5vJGIhPIPe6Ol >									
//	        < u =="0.000000000000000001" ; [ 000035448465379.000000000000000000 ; 000035460761279.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D34A10C9D35CD3DF >									
//	    < PI_YU_ROMA ; Line_3533 ; Tk2yF5aVvOyaxW05Ud20l9TTWWu6na1UtXbmND9T6mR753x57 ; 20171122 ; subDT >									
//	        < 9qDIhFd2V0RKu5qo5oBO8uTE364o80fCkrPxCKvMz8aM61kv7C9XpR16vfXMRse1 >									
//	        < yWL8F5DSzUG36n6wIu7Ja51Q5J7qn9aXW1VkE044w6yzGc9pO14Mz9pmJQ3VNUG9 >									
//	        < u =="0.000000000000000001" ; [ 000035460761279.000000000000000000 ; 000035474701256.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D35CD3DFD372192D >									
//	    < PI_YU_ROMA ; Line_3534 ; y9JwNeQ12d5q4RKkhWjY2wtf219v852h2468z1j569N8No1Sr ; 20171122 ; subDT >									
//	        < 8r4I30yjgEsM4dtSDC8ejbPeS2EiyF2Tc9hqKH3g2I7HJliOXdm09Y1KeAm09u51 >									
//	        < B89w3F62Rki8bC8sZ8Oqu449i6BdweAn3AKKAVkk7P5Aqpk33b9MDAM22a3P3ptj >									
//	        < u =="0.000000000000000001" ; [ 000035474701256.000000000000000000 ; 000035483266685.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D372192DD37F2B0C >									
//	    < PI_YU_ROMA ; Line_3535 ; oLE2B907xkz5gkA23w5I8t322CmR1A1kLNvO30Lj8UwxxOZ56 ; 20171122 ; subDT >									
//	        < tg19d7Fr5jFM9KnB8SJhXaU1n1oOiko19HvU3TJ1LTODrR9OU1fY38uW1ow0gOvH >									
//	        < XRp5BjuKcdHW0qS1NXp6wJF3lTFA4j1QCsxY4BWYQBB1mOPNtU57MR1DziY3852r >									
//	        < u =="0.000000000000000001" ; [ 000035483266685.000000000000000000 ; 000035497683904.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D37F2B0CD3952AC6 >									
//	    < PI_YU_ROMA ; Line_3536 ; l9t4058jfMdkH5f9u8q2XdKq8fS874Vy8kf1m7OvStYeSx4J9 ; 20171122 ; subDT >									
//	        < DL126UGPYQu0KIDP43gEq8n60B8qlEwjSVr0XYzX680LSwL989zrMVr2HZIkq4d3 >									
//	        < mjln19A6BkQ6ZJ63aiX87tJOx5p8egys9UGY91y1I96vB4Y8Oef104J9dd8NEYXy >									
//	        < u =="0.000000000000000001" ; [ 000035497683904.000000000000000000 ; 000035512072844.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3952AC6D3AB1F74 >									
//	    < PI_YU_ROMA ; Line_3537 ; Sy63g7Y0oyFrAe0gkb7wRiuDoN1066t30Do03cVlaOi6vN6hZ ; 20171122 ; subDT >									
//	        < asM3fl245sxFtwKJEM92TCf6Oc4UlA3r00qNFCNyT6P984634li8L92s3ir9be0a >									
//	        < leG3GAvZ3dvpCva297Lq0568w4Cqi3CahPGsD4T9txQqUY6lC4w74E2i45G40JME >									
//	        < u =="0.000000000000000001" ; [ 000035512072844.000000000000000000 ; 000035525344398.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3AB1F74D3BF5FA7 >									
//	    < PI_YU_ROMA ; Line_3538 ; ymcswrcelpV5eScPv873nrShn8J7pQfhd4rp41sK706YFKck5 ; 20171122 ; subDT >									
//	        < SZtrX6uRAf973rH3XX6XLy5mM1VoMetTa0dqX6QZY8f1CHd9wuSesvzsMK4sTPe4 >									
//	        < OK0nr31E489MO152wg4EciPbXcyapaWqa46w068BX7epidlE3d27Hq59tVs8c9lm >									
//	        < u =="0.000000000000000001" ; [ 000035525344398.000000000000000000 ; 000035537736969.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3BF5FA7D3D24880 >									
//	    < PI_YU_ROMA ; Line_3539 ; 35oVRce419UL7PJCZ0mFkc09nokW2V01RegUiGTse072lBO3w ; 20171122 ; subDT >									
//	        < c3KLRqDc7k80ZWqCnrslt57ogoP1spjm7y72s4d1jxB49m5R1e48cL6BzjN039Su >									
//	        < da3wHpkRJ6e3H8PZT00vJ1hEHfs7U9PW01O4k6Y6Ot0xZh423Ts7eQYFr6j3tigX >									
//	        < u =="0.000000000000000001" ; [ 000035537736969.000000000000000000 ; 000035546457954.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3D24880D3DF9723 >									
//	    < PI_YU_ROMA ; Line_3540 ; 1G924xMwp0EzE2z8oOq0oEyZa1HcZS2j8agl9JQDch45Q73jq ; 20171122 ; subDT >									
//	        < KUl5i1hD37nvR9C5AmpYM0k2V21PDbMVY6a5ZzK57dJMPj2fLnj6z1y2G0j3042i >									
//	        < e8BR0ZEAU2FY38Hkh3VW6L1jbficDH6B7JtG4miI3kA81x0z8113XFs7t695WRUK >									
//	        < u =="0.000000000000000001" ; [ 000035546457954.000000000000000000 ; 000035554368447.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3DF9723D3EBA92C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3541 à 3550									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3541 ; rc61M5ZwIXex6Se11HTVy49DSl4303M31maGefw3zR03O60Is ; 20171122 ; subDT >									
//	        < 4x90eNAkQ2Jw887xKtH0vCCuZ9WB3za9OD34m7W16fA1E89cobDmHqzolyXyYL7j >									
//	        < hYJN20o5Qh0D5z8na0n5yFMsL53r3V6e5w0VJYHXxYl9A3o867K2915Ak7fKD94b >									
//	        < u =="0.000000000000000001" ; [ 000035554368447.000000000000000000 ; 000035563215255.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3EBA92CD3F928F5 >									
//	    < PI_YU_ROMA ; Line_3542 ; c275HtR05vCH85xol3Qidt8RQqY24mhxaH8DOCYWVA3zjSnhh ; 20171122 ; subDT >									
//	        < Fud8y58P4vxps4JEtaNZfq0ugrfi8t8z9TFiCbI6IgZt7J8HcwjVKDdr5HeeK1d2 >									
//	        < 1OL6Ob6ih3t7394ZjCDSm6hOK2v76oxC6a830kU4BZWQX34xJKs9jsBty8t5psV3 >									
//	        < u =="0.000000000000000001" ; [ 000035563215255.000000000000000000 ; 000035578158318.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3F928F5D40FF617 >									
//	    < PI_YU_ROMA ; Line_3543 ; tEA7P0CVTDlWX3774ueARUtrA1EUUGi25303AL7lQBvY94Uv5 ; 20171122 ; subDT >									
//	        < C13A9s0X1Yt5QCwSOU1faBR6u3sWX795hhmSGdia27y98Ffo1nuglz17tf3l6zFO >									
//	        < cUjC5q54M6Q8oE9qH7z9WN5i1AS1M8WR0Zg6G2i6i12UJur566CS9qcowKh5lmIi >									
//	        < u =="0.000000000000000001" ; [ 000035578158318.000000000000000000 ; 000035588319919.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D40FF617D41F7777 >									
//	    < PI_YU_ROMA ; Line_3544 ; J1kRwM64ev687F6Jk6845jMNLA6mtu3E7k0leQs3T8nTH0v37 ; 20171122 ; subDT >									
//	        < rY8fbW3O8k62RxEW4TXubIZ2Vm7TyK7AQK4tH45vjg0YqJEUMhd5s03q9AZSDQk2 >									
//	        < 85m8Cnx6C648z7r1XJ7m53PIjB245sjLH4POn7VrCBlvO1AB5Zi09x6s0FT5uD89 >									
//	        < u =="0.000000000000000001" ; [ 000035588319919.000000000000000000 ; 000035594791454.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D41F7777D4295769 >									
//	    < PI_YU_ROMA ; Line_3545 ; wXkFpa47y4JbdPCd7l7r93V9AtN0c5izIDqI0K7F5Cb095O7t ; 20171122 ; subDT >									
//	        < staQW0wEV09SdA0zL2F90n92y3YhJ84se440A9fuLig1hVNLq6b2spwjSkl3410g >									
//	        < 8NE8147M7d1p6h5VR1sn9eTM3at69pK9324qkUb3xr45uv2U043I5MGHjEiOBYyh >									
//	        < u =="0.000000000000000001" ; [ 000035594791454.000000000000000000 ; 000035607695804.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4295769D43D082C >									
//	    < PI_YU_ROMA ; Line_3546 ; PIGTQ1sZ2yeWUb9SotD744363i3cPy1Adogj7sjsrqaLFU0ZK ; 20171122 ; subDT >									
//	        < 1sn7WPe5K274ZlJx2hT7nr6yjhKNtDe3P8Xc3xi0OcU263b82xZGqGrCHSg23rql >									
//	        < bMy1igXthUIFyHDdbFZ83EV3Um5U7K44KR34QzoYi5Pr0lOHtrO9oK1RCcGfB6Fs >									
//	        < u =="0.000000000000000001" ; [ 000035607695804.000000000000000000 ; 000035620346744.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D43D082CD45055F2 >									
//	    < PI_YU_ROMA ; Line_3547 ; uUwGiVSLS0uTAGn47YGvT2hhf4aZx5Lq5UP6US1xt1p9SQ7pe ; 20171122 ; subDT >									
//	        < 6Gzi3V718RbH3360puxoigiOYtJBoiGs72v1dXjbc53E6507JH47DS8K9967eD68 >									
//	        < wM5Q3eViESbirD6clBqNx7I3CQDxCAvM4ht9FA3M9klK1Ijf1xNIKFGKNWgWVNgY >									
//	        < u =="0.000000000000000001" ; [ 000035620346744.000000000000000000 ; 000035625836770.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D45055F2D458B67D >									
//	    < PI_YU_ROMA ; Line_3548 ; Ru2jkm39JeS8h6gO7rftr90x7kTvB9eWIMR85eK3D6yn8ExU0 ; 20171122 ; subDT >									
//	        < V3710P56F2dI5gkaz199HPrBgXw5372R6259O0pH24erAHsfz4jV8nJlkp5q5421 >									
//	        < 7k51I78qA0iy7XAZGohHH4u0eS7J4las8yanQQ28N4x4bx0uSy70FYP3ZLWSn6RH >									
//	        < u =="0.000000000000000001" ; [ 000035625836770.000000000000000000 ; 000035640290134.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D458B67DD46EC455 >									
//	    < PI_YU_ROMA ; Line_3549 ; 9Uc5Es2eumRKZ90106p6xf31r57JOfoML27G1Rk6Wy12gXRef ; 20171122 ; subDT >									
//	        < 8cphAV9ctdfsD1QI6a17d89hf416l12TM82u7bM25W49Udy29Bhx1poueOkyy4F8 >									
//	        < B7ISI6J0V8hma008WpTjSmI1T6oeEL0dex583k6fEm7nbTfK3K9HIINJs8ZHVGEx >									
//	        < u =="0.000000000000000001" ; [ 000035640290134.000000000000000000 ; 000035655020059.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D46EC455D4853E35 >									
//	    < PI_YU_ROMA ; Line_3550 ; 06er8MEPjYESIoaT4b2SkNf2BLHM1SNa3o1vguXCQenhkFwsy ; 20171122 ; subDT >									
//	        < 9sFcqjnDKW2EwPji6K11G1khtbzs59SEkevfxvxANh1G9wIjhn6a0R7x0q9exXJa >									
//	        < 9b7byz6t4Fof54Z10ogFnUA6VRZ6Z7LmMj5g21Uwp1S4CC1zJVe0634tA2sIPp06 >									
//	        < u =="0.000000000000000001" ; [ 000035655020059.000000000000000000 ; 000035669446365.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4853E35D49B417C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3551 à 3560									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3551 ; hQ5Wn3EhFWTpN49Emtd7E87UfAnURvzPj71MVdi3t5GT4WZN4 ; 20171122 ; subDT >									
//	        < K407R3EW0wn9a2f9g40FeLU9IWo565B6MhLn2127DHww17a64qdgsxc5Dn7M9maE >									
//	        < 30atPK1GZcPpmvQGghGQO8u48yPXJuwUZ00IP7sV5L3Rh0Z6ILwVypUFJhqiQtHT >									
//	        < u =="0.000000000000000001" ; [ 000035669446365.000000000000000000 ; 000035675887268.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D49B417CD4A51576 >									
//	    < PI_YU_ROMA ; Line_3552 ; 4g44e1RUvn9MHbSAY1Qw8WUOQ2ONsazeQ6lYx4zx7pVg86eFB ; 20171122 ; subDT >									
//	        < NXGjAzw2boFRhNv0D6aI748j0i2gh98QAaGLLHs5K5CXio5TWL3ddf71K2eL6W6y >									
//	        < 36Xp1dlvchX3tG6z0La8A2XjY2xxrXg3mgUnOXhZNxx0MLs30IFETJyuq2R4La5H >									
//	        < u =="0.000000000000000001" ; [ 000035675887268.000000000000000000 ; 000035684976381.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4A51576D4B2F3E6 >									
//	    < PI_YU_ROMA ; Line_3553 ; Wi9H3NwUyGa68Fk4joo1922uNbcJq64zNpWbkDtRT7oJMmFvj ; 20171122 ; subDT >									
//	        < 2o4Npa4CPORMWWv4F61WH3rHYa8CKmrdV3E16Pe8BF9OdcrgywrP0X9H7e5kGQ5D >									
//	        < 55m7ZoC4qEWeG4hj2Z4TVK33CLwV0BLBQIHuiVOwoo1zBI0srPqa2jv8gok9keUx >									
//	        < u =="0.000000000000000001" ; [ 000035684976381.000000000000000000 ; 000035693216395.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4B2F3E6D4BF86A7 >									
//	    < PI_YU_ROMA ; Line_3554 ; 8bzjT7O07t34yyRW7HxVS3O0y7xdN658LavA4dIgZzw7rYb4i ; 20171122 ; subDT >									
//	        < R780C2RsKGeU9xdKs529qcbNQX8TdC5hP0820OB14W0tbSD0AA5Vi3cAX2891OwF >									
//	        < i4Wl589eFQ7q1laeF1sOeO68l03uX82Dvz5gcrMoAgi48Nme562615vwoDGC5rG0 >									
//	        < u =="0.000000000000000001" ; [ 000035693216395.000000000000000000 ; 000035705830462.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4BF86A7D4D2C606 >									
//	    < PI_YU_ROMA ; Line_3555 ; 71lz0nx4997K97w5NMgbW2IafbWZa4Q50p65zOr61MM009J5Z ; 20171122 ; subDT >									
//	        < EtQdga85WT3glFTzDoC1H2VCb29hAXW0hypP34m5c9ZeOWU7sXyU91r9kRjTYyuO >									
//	        < Aea4iLNI3inJgd35BIK37RKH68J0f0Pz1F5bBd59RkwmD4I7A40bl82ESr3tl5cm >									
//	        < u =="0.000000000000000001" ; [ 000035705830462.000000000000000000 ; 000035719832613.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4D2C606D4E8239D >									
//	    < PI_YU_ROMA ; Line_3556 ; EU0az65mhf2Jlw5572F9CW7c1f1Yq2JW3W0skqL90H84n7mU4 ; 20171122 ; subDT >									
//	        < GWOwCWTfb6f9pm5TUgR2Nh41FoJ3Z4j6Y1RL5i1iwO1717qxotrc3n29FONd2gSe >									
//	        < 4llm0NDQMlKylEv0Tt3YnABOkzc74kv2KSMA33I1Of6f7attLfZ7W34YLENU0SRb >									
//	        < u =="0.000000000000000001" ; [ 000035719832613.000000000000000000 ; 000035726914834.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4E8239DD4F2F21B >									
//	    < PI_YU_ROMA ; Line_3557 ; B0bv2097n1Y8zO7hs18Z70LOom48G7HFDj0D22f3395XMpxQ2 ; 20171122 ; subDT >									
//	        < bi8u2XWiF4fh7c3C2HPXihs5ia6P8g4344Zn1T1AWk8JIFT0VPHtKxD76s2im7yC >									
//	        < Da8620W1vJ8TzQHvVqH44udKz6RTJopRRAkyJxNCFut4DNo6GRf0yOAXyXTCq28j >									
//	        < u =="0.000000000000000001" ; [ 000035726914834.000000000000000000 ; 000035741615975.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4F2F21BD50960BD >									
//	    < PI_YU_ROMA ; Line_3558 ; AfC5eTI5jjd0Vpr0QMBh3J5wasvfZM1e3yTZ686J1UiQ4hwJZ ; 20171122 ; subDT >									
//	        < xVMWsnU5Qirk8xGs2YWbM0XEN5zR96zrJb7iyLS00RYMXW7UVYP1vfT8Aelh35fn >									
//	        < 2IQ323ogD0d1L4c4AhdtLD8xv2H390tY73t4W00Xl9LJao57470p90Mv65FY7m0L >									
//	        < u =="0.000000000000000001" ; [ 000035741615975.000000000000000000 ; 000035747664123.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D50960BDD5129B4C >									
//	    < PI_YU_ROMA ; Line_3559 ; 4GeQSIB5q5555Xg7aco8jQg3h1Di190h1taQ8Rqdp9Qnuu205 ; 20171122 ; subDT >									
//	        < Yx0ljhGooyV008Os6fuZefkEC83Bjk5u0DWYJf1Br07k28208J5n2A0t5Z1t51N9 >									
//	        < Jx3eY57T694f2COu3336Z34UromWXeh9nw9ypO2K14CP4X19kI91edtxqE06Y2dG >									
//	        < u =="0.000000000000000001" ; [ 000035747664123.000000000000000000 ; 000035760769174.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5129B4CD5269A75 >									
//	    < PI_YU_ROMA ; Line_3560 ; txn7EVT60kPtSBOtPu8we9150Usv3ROO2X0bv6Zm2JJ8rJYiy ; 20171122 ; subDT >									
//	        < qNM8Acc48nm6QrVP4RxS012WHff859ZIhR1A45W2c2w4oie6C4lHvdbM9wu8pNS2 >									
//	        < IGB4GV0yF3rA4F5Osm3DJ6a4pfA8hEn1zu34YBvh6ysT47ngpaai64LD84Kcn6cT >									
//	        < u =="0.000000000000000001" ; [ 000035760769174.000000000000000000 ; 000035775068868.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5269A75D53C6C46 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3561 à 3570									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3561 ; d0J1xU6h6i8nRmXmJ2CC780fcOzkE7qTTjf7k6LN23E7bHzO7 ; 20171122 ; subDT >									
//	        < zrl52vkR6x9IcE49giD79s514w2ws4A30D8e8G0Gt527Q4NQ3poHsEOLB7XpIM44 >									
//	        < 6MXAI5GE86yb6easv05ub56LYBAMnJowIK7z2Q945SqBZ1cEZ9G693rF67UwDAkj >									
//	        < u =="0.000000000000000001" ; [ 000035775068868.000000000000000000 ; 000035789245319.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D53C6C46D5520DF3 >									
//	    < PI_YU_ROMA ; Line_3562 ; ORd133hm9y5Wlz8y0u9wHEntOv3FtBGgEjw0U3Gv476236al2 ; 20171122 ; subDT >									
//	        < 0WG78o35Ia089kAAK1BoCJ5cdxLyx5Sx2NSu1x7UfOQYdmJ0InIwEnd9WqSl4Ia7 >									
//	        < NGR0ta5vuue666t76M65GjlnxKe1SOwf3O1qGa0T8jlbMWcHS72NQcMs549LyC76 >									
//	        < u =="0.000000000000000001" ; [ 000035789245319.000000000000000000 ; 000035803099934.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5520DF3D56731E9 >									
//	    < PI_YU_ROMA ; Line_3563 ; 3B7Bh6d0hn2j2ZBp9O9k2g31ch1T4kfu0LzC3E57XY1yIIy18 ; 20171122 ; subDT >									
//	        < 0nI5duAvWH971S15X7JC2HLYKW9OQz0JBVl92v5KlupvH66nav36r3aB3mdK0481 >									
//	        < hgD16v6Ews15Q8T1jVjAUQZ5FLA2D225QlwH15ry3z79N5RkcaM171RA058Ij49O >									
//	        < u =="0.000000000000000001" ; [ 000035803099934.000000000000000000 ; 000035808699831.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D56731E9D56FBD5F >									
//	    < PI_YU_ROMA ; Line_3564 ; 56j2RBnnQ1p972JinUAPDJz47Fk1wCgv2X5Fa63Ikn5FRT8GA ; 20171122 ; subDT >									
//	        < 9EXvSnyKNTmgaW82qZ4Ya6If834e90jEBKWDfqEYU9g4d45PbMLWQhAAD85unPyZ >									
//	        < y6L0N9YlAU7exFGnclNcFQJtLhLv24knKYF1647ah89svvBXZNINd2UV7WYQC20q >									
//	        < u =="0.000000000000000001" ; [ 000035808699831.000000000000000000 ; 000035817704935.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D56FBD5FD57D7AFD >									
//	    < PI_YU_ROMA ; Line_3565 ; eKO50bRAVKQY1djih51G344h880gwwsWcHP63vUR87C8T0zn0 ; 20171122 ; subDT >									
//	        < BJnI8S5dxeQJD5a5wp56Zi1M7NlS3sFD6Au0b5EP0J8PKpRB9Y0MtM543k83y6Jx >									
//	        < 6n1IyU091Ms4tO4Y8PvVo6i70keG0CHbh5nrc9sU7DEQ92vdW4wK26Su77kB96s9 >									
//	        < u =="0.000000000000000001" ; [ 000035817704935.000000000000000000 ; 000035828926465.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D57D7AFDD58E9A66 >									
//	    < PI_YU_ROMA ; Line_3566 ; 5awY0Ig6MNz7ASp472ddsFe7CqRztLFwoD2yfwb96p6foTHYx ; 20171122 ; subDT >									
//	        < YxwTOY181v9OH1D4pLWR96ni6q8aU2ydSCo1doTghVEgB2bg0LRw6xwm0s190aTs >									
//	        < d9PczvIKIr4ccUNvaZl0U45WoFPQ9eMprGiIVD2km84CtnBmhOz24O7rwLkUY7xG >									
//	        < u =="0.000000000000000001" ; [ 000035828926465.000000000000000000 ; 000035838121957.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D58E9A66D59CA263 >									
//	    < PI_YU_ROMA ; Line_3567 ; I1q1mo403R5oOlT30687J1DiIatY2QwbHJuy46i12hqpqc4D5 ; 20171122 ; subDT >									
//	        < 7d59ENq9cULKe7x0EIzSKldNn63mOvgVy0rEU1Ho31b103ebGmgraz0qL8ASPcsV >									
//	        < unYnr7zD68l0ysIyXu6J00X78WKO5P18Qm41Le4QEdS9k7aomaW61q4u4gzC1Llx >									
//	        < u =="0.000000000000000001" ; [ 000035838121957.000000000000000000 ; 000035848033375.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D59CA263D5ABC209 >									
//	    < PI_YU_ROMA ; Line_3568 ; xDHJ31Bj2Z44oA6YhFhib4t9GZt9nf6Vu5k5Or6Nm6K6c86rs ; 20171122 ; subDT >									
//	        < Rlv8I6sNp55rxgMH1DgCA7W4W62Q13K1llnu7Fh1TM56227I7234zNgzQe3qJ941 >									
//	        < OpddfBEtETQDclKaTrl4DdDtN8cB8cfqvqvRj7Yy42qC3XDW0jBqcH766835ntL1 >									
//	        < u =="0.000000000000000001" ; [ 000035848033375.000000000000000000 ; 000035856105026.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5ABC209D5B81306 >									
//	    < PI_YU_ROMA ; Line_3569 ; X8T68c2f6e64z2u83yzQo5v0J82ZIQuADllvAdu27w9U8t96J ; 20171122 ; subDT >									
//	        < 0BKkiu6t1j29cs6kyBVHKs8avASfUsPW0u5RI5rVaeZAsO1zUt61dUMxI9crR5m1 >									
//	        < uIoQOlfo54xKpK8fn83czcMv2y4W529fHT5Ng3e79Yp10Kv8798lN4kTDmB50yyH >									
//	        < u =="0.000000000000000001" ; [ 000035856105026.000000000000000000 ; 000035863400130.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5B81306D5C334AD >									
//	    < PI_YU_ROMA ; Line_3570 ; JG2OvmAC67ZpAKXBohox6cv9Hd1CXQe37Ck74C549X9BdC5tV ; 20171122 ; subDT >									
//	        < fdA5TCv8W0YFBY7f7Ht8C2MzcJNfdhn0PCDF3ywvuc49m6zSElV3s5Y0s0rhzI6E >									
//	        < t4Yc5BE2bxL83fDI8fm5cef2ZaJcP5pdqVqQE6R00y2ssq4vzg0BAe54CLaiBqro >									
//	        < u =="0.000000000000000001" ; [ 000035863400130.000000000000000000 ; 000035875687578.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5C334ADD5D5F475 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3571 à 3580									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3571 ; 0PKmeTwF8S5TmnbYcBrShp64eCBn71wG7JGj22cWMiz0U64lj ; 20171122 ; subDT >									
//	        < ZTv8Akdm1PnqKX9vrD5marJsdYKuM9pjK4S95Dxl111s4eJz8oEdiZ2dx9b1Ks2M >									
//	        < oheIQyhK5uobSxl8TzM6c059M7QulUqm4bQr4947WdyjM25Uvje0q7bqt9Gqs25m >									
//	        < u =="0.000000000000000001" ; [ 000035875687578.000000000000000000 ; 000035884357867.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5D5F475D5E32F4A >									
//	    < PI_YU_ROMA ; Line_3572 ; o1Zw8IK4ESoOp0OTM05jC8xN24XRJ97uXOqMV0320E59f2Zss ; 20171122 ; subDT >									
//	        < 56U5B7wVCu4Yv6LrdSe13LyvyAl76N9G4uLXGOS7ik1y29XWa7o3t9Rj33veLY47 >									
//	        < mm02zvMxp7pp4V35adq15b245PN20h6zAtj84iQp96Q8l3yQ2h8z19S5AEH7BFvt >									
//	        < u =="0.000000000000000001" ; [ 000035884357867.000000000000000000 ; 000035892339163.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5E32F4AD5EF5CFC >									
//	    < PI_YU_ROMA ; Line_3573 ; S2WiXZ56w5x5VR8tngx5oCFCk334h4EcA27wj98hIJ5GV2JpC ; 20171122 ; subDT >									
//	        < 9Pf80SLvbc6iYjpj5ZcntpE91M3ti2RCM2uM2S435TJJD7300WPjjRLrdZMqZwMY >									
//	        < Js21keK72Xs209y8Ft8NU6aAIq2tdhR3AURU0i076m9b39s9b2WJ590X9u548Rm3 >									
//	        < u =="0.000000000000000001" ; [ 000035892339163.000000000000000000 ; 000035905896803.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5EF5CFCD6040CF0 >									
//	    < PI_YU_ROMA ; Line_3574 ; NWWXzED9SY5m966yQci30bO18iR911qC2oa0dGY3Wmn36S3pR ; 20171122 ; subDT >									
//	        < cruQ63sd1w6ry3aE2tgQ17KUAH54D2tSoa8NT1vugOXcfULLMNW02DSWcOI3D1eS >									
//	        < 34K3xr15eLemiuJf1y8t2jb30yGV2kZtn8TJxFxFpPjkVXwz5kE3gtF1BJOJ4TrX >									
//	        < u =="0.000000000000000001" ; [ 000035905896803.000000000000000000 ; 000035918659817.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6040CF0D617867D >									
//	    < PI_YU_ROMA ; Line_3575 ; 3R03o5kWM7V8Vlsyi0P2pU5VmB4las1t260prZP15LIyp0X1m ; 20171122 ; subDT >									
//	        < J1zKYk8RGzXn6Lv6eMTuO9r9di128CQ0PvA82yQyR3OHl8SlMCdKCjJw1EzZh9Iq >									
//	        < gm5GISskH9Bs5vx6k0bTR6oTyTup5X2VLd46mimTw3mczZzj86656m69xE70O16D >									
//	        < u =="0.000000000000000001" ; [ 000035918659817.000000000000000000 ; 000035933541760.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D617867DD62E3BC0 >									
//	    < PI_YU_ROMA ; Line_3576 ; Fj754c95ERvXmwjQ4Mf0nkQ8yhFW8WzyqdMgsd919965c6X3O ; 20171122 ; subDT >									
//	        < df6CEGzAseWZC6Fld8kSr7tP2ct2w5e1tWKz3Vy6RDt7T4XcTiRtSZL48pXGPnto >									
//	        < xO0cpz2dgvy8bHQEV51H8xsXrlA5Yc13p378X3Ga3z4C42oy1IL9997HUR8HzVnX >									
//	        < u =="0.000000000000000001" ; [ 000035933541760.000000000000000000 ; 000035943712747.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D62E3BC0D63DC0CA >									
//	    < PI_YU_ROMA ; Line_3577 ; Q1Xyv61lXOeKhJBgBfQVJVBFk522G21O6ApbrgxocdjaS3M4J ; 20171122 ; subDT >									
//	        < 89NZ2fbjjarRm2S62G26940V8tzfOWBMH1y10f8zx9F794164n36kb4557fDEg3x >									
//	        < Dvhh35w07QT1366NEOMKOetBvGHSlaXATm6Kg81ZMT131T371LMJ75BH36f0M8pS >									
//	        < u =="0.000000000000000001" ; [ 000035943712747.000000000000000000 ; 000035952741933.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D63DC0CAD64B87D1 >									
//	    < PI_YU_ROMA ; Line_3578 ; HiGNmxnd4GtYR74MG7Y6k4Z20EFfYQ27Dg9R1Vd46s4rT57lu ; 20171122 ; subDT >									
//	        < 195q7ILw9L3YgYPwJAIkL4D80mX67p3L436y4f8Xm8wsLY5upyD62jqY08fSD9hZ >									
//	        < B2Rc7KV7DbqS2316Pm9O3D7d4G0wlBXVjQV22m8Dis3r49Sld5zy8247OaHqg47o >									
//	        < u =="0.000000000000000001" ; [ 000035952741933.000000000000000000 ; 000035964628090.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D64B87D1D65DAAD9 >									
//	    < PI_YU_ROMA ; Line_3579 ; p1Mh0bik1Y42dFomm9aa80f6t31iWBRO439zXmV55p34aubD2 ; 20171122 ; subDT >									
//	        < A2kbS1NMFO526l175ME30QZgiG7b3WEGLl4WxkCd4fH3IhQob2l2YOp7sRe85wXL >									
//	        < Pl073D1k02F7GoA4C62W0517O718cwS2fG85A6IAoJ8BXr1qo5W6mWE1X2Wrti08 >									
//	        < u =="0.000000000000000001" ; [ 000035964628090.000000000000000000 ; 000035978862928.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D65DAAD9D6736354 >									
//	    < PI_YU_ROMA ; Line_3580 ; jZRKFqvPrRgje6Wmy3cc0Ay9WPNy9hT4845vlz2S4w5N0B9y0 ; 20171122 ; subDT >									
//	        < l53lWLm6E2b3xK8RP6N172Rs1W8326R2W5S865v6w4Gm55N4965Hvrv5N40ZMQ9B >									
//	        < jR4z80ouo3K128uz19KHhqB52gU9y73Riqb1Cx31vfDd391gtsd8EDBu9U5jdK79 >									
//	        < u =="0.000000000000000001" ; [ 000035978862928.000000000000000000 ; 000035993806865.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6736354D68A30CE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3581 à 3590									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3581 ; q6aQF8EoUNxgGanxv5kupAlnoXbESueyKMEGJA6u38kC0r46D ; 20171122 ; subDT >									
//	        < vBARX2pOmB803095Z3f4u4711V0rJq7aptL805C0qTXFJcrhNTc6k3BQ2LVg3PJ3 >									
//	        < 8T71wBQ2KfZ2lP9kgguQ9wr31R6o1MPC24fhHGBIFuUb1s5N6jh3aVgK87fHzN67 >									
//	        < u =="0.000000000000000001" ; [ 000035993806865.000000000000000000 ; 000036004607626.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D68A30CED69AABDA >									
//	    < PI_YU_ROMA ; Line_3582 ; E0zbZe22BW79m39h35cOtt6J585jdolf9GdnU4r7UC9ph6Y9c ; 20171122 ; subDT >									
//	        < L4fGbXlmOSaI24J9EiI5059J4s8yJ591JeReTRx543aSVQop2879YPiE9zR0Ow3I >									
//	        < 1g0iEIFI5P77dqqN1rcV5B95hysGv6H33gS6nONqJ82EUC6s516NjZF7p428Z6gl >									
//	        < u =="0.000000000000000001" ; [ 000036004607626.000000000000000000 ; 000036011143731.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D69AABDAD6A4A505 >									
//	    < PI_YU_ROMA ; Line_3583 ; 9rg6j7y8oyzk2vm4xrmew7V8eoW909369qSIjUnf25JtxAu7h ; 20171122 ; subDT >									
//	        < 1b37AAg1Q8rSuj1g0z79019IufJ61609L4A01HM08W27834I3EHfkwg5A26Z8Hjv >									
//	        < 104iBhN7I7YTixe1zc69xOjf9Wafikkb5hm2rsM5IBmw1zl77KLCfmU39DXpePe7 >									
//	        < u =="0.000000000000000001" ; [ 000036011143731.000000000000000000 ; 000036025304595.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6A4A505D6BA409B >									
//	    < PI_YU_ROMA ; Line_3584 ; 19FFQWTK1ytWG2r4U5g6kdojfi6L6aFShs028KBUh23bJAe83 ; 20171122 ; subDT >									
//	        < 49778hHvptmKVNb3yOxIi9c290OJRO2c3gxxRYbtf7B76134p3R1wqnGODa3eJ29 >									
//	        < gn87388M6Bmo3j79ZvsH2HwV97laV9817lQ07Bo3lm8Itc140McrzvUe1t3I69Sj >									
//	        < u =="0.000000000000000001" ; [ 000036025304595.000000000000000000 ; 000036035556671.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6BA409BD6C9E553 >									
//	    < PI_YU_ROMA ; Line_3585 ; x1BvC4EtsqRRUBjQGqudiGhpLrWcNmrf4AsH1Stx7daUV1Ucu ; 20171122 ; subDT >									
//	        < B1SP101wOiB200ZIR268zv7wX2hFbLKT6oBPZaLoen67W26y3oG8Dn7bZ9xj2Cmd >									
//	        < FdKhfio7S18KSepd433V0F15cGAXUlN9mRu6FQ0355Z6607uEiitNh5CSFe01I9c >									
//	        < u =="0.000000000000000001" ; [ 000036035556671.000000000000000000 ; 000036049171228.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6C9E553D6DEAB82 >									
//	    < PI_YU_ROMA ; Line_3586 ; IfyHgd9wN7CkHLUPiqdg6VVHj8qY5thZfEuW4Sha0p393A64J ; 20171122 ; subDT >									
//	        < EW65j7xl3FOl7wz046y0CF0jP40f42QYiIz2Oj3QOdy04I1Uj4VTGffQD00dt7P0 >									
//	        < voj8tcZb4ab1DPH9EeRZ7Kf5WYfC3fytz9AXlWoRP8kERe27PzIhOr4Pqx21Vsbz >									
//	        < u =="0.000000000000000001" ; [ 000036049171228.000000000000000000 ; 000036063970823.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6DEAB82D6F5409A >									
//	    < PI_YU_ROMA ; Line_3587 ; spy08k24Fi8AdCT4juWoRvWfG8jzFcz0yiY8Y4C78p44vvP88 ; 20171122 ; subDT >									
//	        < t02PZM8o84n5XuIcJPm4aP6411Y0STxUVcLBvUJ01x2ddpF9V3Ni44M3FZRmMF7T >									
//	        < OO4M1HeJjL3ZCenL5wt5WtWd72ymT0XIz07C3K63lIA05HYu53l7hxwQEpXf5LyI >									
//	        < u =="0.000000000000000001" ; [ 000036063970823.000000000000000000 ; 000036071719764.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6F5409AD7011388 >									
//	    < PI_YU_ROMA ; Line_3588 ; jE2xxHcjoZ41YT3Ohajv14X6qBw868c7OjF5AzFtMNNC85IG9 ; 20171122 ; subDT >									
//	        < Ov7MJYm2adxwIO2yE8lNcYhqJ2fqoZ7FW37PjrcjH57kb89XT1xSeA1l4bs9wHCn >									
//	        < au6d5H6hj3K2Led53aGkqE2Ji9xR07svXE8ZtK5qMc90DAYCV48P5U5G9v3sWqg7 >									
//	        < u =="0.000000000000000001" ; [ 000036071719764.000000000000000000 ; 000036078053226.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7011388D70ABD8A >									
//	    < PI_YU_ROMA ; Line_3589 ; kvS38LpDEI9TjeKpEsEX83D97365vQzmm918JRPIYybPBZgT9 ; 20171122 ; subDT >									
//	        < 90SYdY291Kb1U75b8Qtl98h2905q4a830fODQ4w5Jrprgz66harFsdO1Krr3OV1s >									
//	        < XtBKgC681vhvjeV0fnBojbVyAm193bKRcX6XgGsDiy6j7WJ42JD27hvQ356JZ5br >									
//	        < u =="0.000000000000000001" ; [ 000036078053226.000000000000000000 ; 000036084409596.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D70ABD8AD714707F >									
//	    < PI_YU_ROMA ; Line_3590 ; qh3h9QltE2Ywn76w98HL366NXAmxJe1mz4zp0RKZbu53h5S7v ; 20171122 ; subDT >									
//	        < aju9gt81fx85NZEnFQTQ8MY6Sp2hspAY3K7s2scw63pB7bt9p1G76L9Hi4x0R75o >									
//	        < qsToi3FZUi7SU58Lxh0Z28vG1tNqU21B1yAhOlRo06jQ0512IB87GQ60h42hD3Rn >									
//	        < u =="0.000000000000000001" ; [ 000036084409596.000000000000000000 ; 000036095430291.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D714707FD7254175 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3591 à 3600									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3591 ; E5EWz9bhSO3920951yYtb5272514t605WQE9rgxEEE40m18iL ; 20171122 ; subDT >									
//	        < TFViLEfDiD6U75vytbJJjdd7S5Vbd2yxA742vdf4ee3E96zQ5C6HVV1Q5pxJwrE8 >									
//	        < zfYG8F94RE5Jh1vZ8SeU5C7JP9TiU1r9M6iD4yGWm8MQdKqF6a5n9M29618nUmNH >									
//	        < u =="0.000000000000000001" ; [ 000036095430291.000000000000000000 ; 000036100601591.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7254175D72D257F >									
//	    < PI_YU_ROMA ; Line_3592 ; 1o0e4nTmS8Dbv45DFXPqqw7J472MaHI9Oc4qjERyRN7lt71Zv ; 20171122 ; subDT >									
//	        < c965pj8a6sBeVtQfudPsdQkO3632F1l33qfz5Ct661zmcD8e6495qT81E2l6mnJc >									
//	        < SlV47xz42oz0CpYuXR5U373Q0aQTVN3T2GyovXxGrfSflfdaP20fxE6uM95n7pcq >									
//	        < u =="0.000000000000000001" ; [ 000036100601591.000000000000000000 ; 000036112160006.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D72D257FD73EC880 >									
//	    < PI_YU_ROMA ; Line_3593 ; pi32H36Z4k37MWsab0V3bXhS49hR1Uihzym0X3bgZc65XVQ09 ; 20171122 ; subDT >									
//	        < wu6Q6qWu58fkZN7N2V1PUoA4zQy53KpMZzOnd0mdvQN5q1hltH98w1h5zM3aUO2g >									
//	        < 5lYc9413pgVa4W715OI94mRr2z0q46xgkz092w2GWaG437pFsA2TE71Z70S6Z0aN >									
//	        < u =="0.000000000000000001" ; [ 000036112160006.000000000000000000 ; 000036125907929.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D73EC880D753C2C8 >									
//	    < PI_YU_ROMA ; Line_3594 ; ZyzT1dIMeY2K59fs3nRqy2v79iOn9IiHOV071vhtG1tPg9p3l ; 20171122 ; subDT >									
//	        < has13sEqd29Xm2GBIDY0bSrtLuL0Suva2xAHbOj8kc1O147g59QvsBAyI1ri59gn >									
//	        < bqJVFvODnb0y7NO2Wxuo99sQr0eg8J7gn6I7a1Gu6o5oSWvWkcYf0K5oOqQKrRiB >									
//	        < u =="0.000000000000000001" ; [ 000036125907929.000000000000000000 ; 000036133549290.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D753C2C8D75F6BB1 >									
//	    < PI_YU_ROMA ; Line_3595 ; U4heV80y5pnR7NgpY8hHW53r0U39RH7QG1fVh0ChFhxT6UpRp ; 20171122 ; subDT >									
//	        < S1653O4u62PdThXRosMa03ZG25inSmt5waGF9ecB94v6x9aM4Sb5jV8CIk9K1019 >									
//	        < ky7eMzPnxq2jLEn3ig37dEJv8VWcHaVk0wNe1VsnRDw1VCdKds5164nZMtZFXIE7 >									
//	        < u =="0.000000000000000001" ; [ 000036133549290.000000000000000000 ; 000036144847499.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D75F6BB1D770A90D >									
//	    < PI_YU_ROMA ; Line_3596 ; gqIFoTrTr5iAQ2K1ZgS71N3n27n8695351xqL64WQO0Y081x7 ; 20171122 ; subDT >									
//	        < PM1fH4EQ2G3A181SjaZ7y2PvW8tfNQ2TZE5e73c116Sb27TJ7Av4w2XGrjN7uFtB >									
//	        < CB7ZD3UBJL4yyM44TDlbU6549hY67hher2vb8ND6vKO55V3Kao6ZwUt010bQAVs3 >									
//	        < u =="0.000000000000000001" ; [ 000036144847499.000000000000000000 ; 000036153637379.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D770A90DD77E1299 >									
//	    < PI_YU_ROMA ; Line_3597 ; k9pw9Vp9mXm120s2W9y3ko0ww4ZFViZ44uGdP865g346r4oNf ; 20171122 ; subDT >									
//	        < 8bexf7y00Jeeqxd5q7o2Xx6L66WjgN156cY7Ha7P4Fc23K9fd4urGj314chr3dwC >									
//	        < DG0v3WEQ44n25hE1fGl3y888l2dn8Bau8OXyVClCk3np9GS0e9jxu80W0MP4q2NQ >									
//	        < u =="0.000000000000000001" ; [ 000036153637379.000000000000000000 ; 000036162343383.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D77E1299D78B5B62 >									
//	    < PI_YU_ROMA ; Line_3598 ; d5TTmg58im12TszZZL4do9l5EImUYshBl11HBg4YOgdK0248J ; 20171122 ; subDT >									
//	        < Bu7d4J5ehT9V7e6N5Sk506ToB64N2yfDZ72x4Gjz303j7UsNq6Y154A0fUq992ei >									
//	        < vG2n5S7OT36b167qJh72e9icBIs1byy256JN4upifTA9jzE1016s7bb5533DhdO1 >									
//	        < u =="0.000000000000000001" ; [ 000036162343383.000000000000000000 ; 000036173798699.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D78B5B62D79CD61D >									
//	    < PI_YU_ROMA ; Line_3599 ; S6D842QssHc2cKrd99TQSxVIw54O8Jkooya97MATmPM7AMhuG ; 20171122 ; subDT >									
//	        < FO5E6u4iZjyc3r2vTBH5ghJV3R3xk7328y7jznCDHJ13I9yDYaFXnLu69PEXKyYM >									
//	        < H2p9czEOBZu9TDnwv62a6KkYJU7Lb8Fy6CRZs5tCYJZ07I76HWwX9X7CDoLH0xMg >									
//	        < u =="0.000000000000000001" ; [ 000036173798699.000000000000000000 ; 000036184488515.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D79CD61DD7AD25D3 >									
//	    < PI_YU_ROMA ; Line_3600 ; OGwKxPhA01X299YE19We99vW8W939MM7W69Xk8S157kXc3PQ0 ; 20171122 ; subDT >									
//	        < DDs4DfyCmU64E2Z00i19F6Ag157pVYn7wBM5nuRo5cNx24PV1m53Fw9PVz80B5gA >									
//	        < Gh3svoP5XqP5EddE1cK3QC3a0alUXmHOmvcSgT0HHu4947rn46LZMnz2s5oPsi78 >									
//	        < u =="0.000000000000000001" ; [ 000036184488515.000000000000000000 ; 000036190388419.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7AD25D3D7B62679 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3601 à 3610									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3601 ; lI1Z4KXTKgzbU9y5pb3OTImAbuuu0DK3P37plMJ5Ce35F0J4M ; 20171122 ; subDT >									
//	        < 28E20M3ECZ9rN6OzYv0sc6lzkD7jmPs019PmXGWjCC2TRn089eSI004Ma4RplGtz >									
//	        < Jo1IYXdC6xstk7Y8SA5t8KAET3Y6jryrfz2V820X4y4K2rE4RYture8XB4v9JIsg >									
//	        < u =="0.000000000000000001" ; [ 000036190388419.000000000000000000 ; 000036198021604.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7B62679D7C1CC30 >									
//	    < PI_YU_ROMA ; Line_3602 ; 05NR01cIIWpXzKUznYeqTFb2G0Wzcw389D14zC9PnEk3GooS3 ; 20171122 ; subDT >									
//	        < rHfNvrEW8Ntatbq6MJg3ppH81AWvG0CZV2BTWfjPMFn1p71QZgh72S2g6N9kceGt >									
//	        < Vc41QXuGVmh60BQJ35t4oczi5rFEcgqlN1p0tvG9oadDF745Nr3x4Z6jQ7V1iW0Y >									
//	        < u =="0.000000000000000001" ; [ 000036198021604.000000000000000000 ; 000036203222483.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7C1CC30D7C9BBC8 >									
//	    < PI_YU_ROMA ; Line_3603 ; 33Ti954z88teK8e8L2bLzkHMV4G0lfR2gF51925dEzYNDRM6d ; 20171122 ; subDT >									
//	        < R8JjQc93n3r7676yw132Abn85f64i62X202VpgkZnj14rGu9rVoL9Bo2Gk9joHee >									
//	        < 7Vn2YTo027fIPFG21m7t1ZLXD6PeH27kH8SJkFi6uqTX7K3n29gNSzHwu66r3zh1 >									
//	        < u =="0.000000000000000001" ; [ 000036203222483.000000000000000000 ; 000036214258907.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7C9BBC8D7DA92E2 >									
//	    < PI_YU_ROMA ; Line_3604 ; 37Q5A2NyNB4s006G1qD0ILlcg3RDkujYbi5l6Bfn8pOXciK8g ; 20171122 ; subDT >									
//	        < 13WA2ym2c1hlq23pLu0Ja2GHd9CbCWm3JC6oM55U79ubEQnH3o1Yr4inzNr03Psa >									
//	        < A380O9HIKsQor9sTHOTyFIOwtNm15x9ONENEs9YCP9peq2K8Zogl5QqLr5F5Ma7B >									
//	        < u =="0.000000000000000001" ; [ 000036214258907.000000000000000000 ; 000036219620066.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7DA92E2D7E2C116 >									
//	    < PI_YU_ROMA ; Line_3605 ; WdZg369zgA17e0Leeau3oRDWEGgRCLEJ0TB0nDklo87zFMJ83 ; 20171122 ; subDT >									
//	        < RG4rhxs0d50gep0Ven2rPIts1TT7p7019E086GCr1b6IFTY6pR0UayvxhP2s6637 >									
//	        < uY3H66RiGkl0d0Fr77gK87u3J6lJ511ke0nKX4nmBLA2MeOD3ugolP8GFlc4s8Jo >									
//	        < u =="0.000000000000000001" ; [ 000036219620066.000000000000000000 ; 000036229297048.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7E2C116D7F18528 >									
//	    < PI_YU_ROMA ; Line_3606 ; J1bLry946050XP1r0R70yK7AUL2ig5df7zuq1pwnZ59DaY39R ; 20171122 ; subDT >									
//	        < sVrl8XA8734n3C5mdB4FMfcirTr4iKSYh5D7eKufZsET4A8m47NdFCIx6FpMMdwR >									
//	        < 15jC003cjgMDSqkw5ldnOfjgysGVFjTR0Ff2mvCU1aV35Two4W29TV5UOl1MMcy3 >									
//	        < u =="0.000000000000000001" ; [ 000036229297048.000000000000000000 ; 000036237976891.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7F18528D7FEC3B9 >									
//	    < PI_YU_ROMA ; Line_3607 ; V571B4Jlpta34Jm7uiG21nqX791m8Xz5d7CO4589tlg4s7eSs ; 20171122 ; subDT >									
//	        < 59woF83TR3WfJvZc2lKGSvsXzT3ESB774cwkmSRyyePBW497JCbp44zDC6uAR9Vc >									
//	        < 1913e8XGO7UbG69HnpYGx7285G3W80It56R0Zw2x2M49fN6wfB0aKkN31EqrQ9Dv >									
//	        < u =="0.000000000000000001" ; [ 000036237976891.000000000000000000 ; 000036249141229.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7FEC3B9D80FCCCA >									
//	    < PI_YU_ROMA ; Line_3608 ; 5bTJn9H6SjZ6YCp135O4tU1PK0U7oXBP1Rb6bVDXay13IbFCx ; 20171122 ; subDT >									
//	        < 77vq13Syi9UU41051EZCiot3yDTq24KlfF4Q0ZmxUjKiD2YR2mhl89zm8wDY98il >									
//	        < uo6FskXGSE5uH88tQcx516XM3s0e956rnoVHGX6ft73vME04361KH452u4f3yN5J >									
//	        < u =="0.000000000000000001" ; [ 000036249141229.000000000000000000 ; 000036261252294.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D80FCCCAD82247AD >									
//	    < PI_YU_ROMA ; Line_3609 ; a7N27L44x8g3A9j5W7aAJz1d2sM8kKD8OHJwG29SUseq6W2R5 ; 20171122 ; subDT >									
//	        < r33IFY92M9Y6U39dX2W0DltqkrK62OTir3caga3FiOeE86fZj3ouuBEDpZx8Di2j >									
//	        < HNoOdq0uiVWc6W15g1ux9UT6v4E8rA43gA04Nn4f6JlQX47hJM77l95Jhp48R49Y >									
//	        < u =="0.000000000000000001" ; [ 000036261252294.000000000000000000 ; 000036270725871.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D82247ADD830BC4B >									
//	    < PI_YU_ROMA ; Line_3610 ; 9sfmW4Z5txzErWs4BrfwsFR5tjlz98N9F2jHUou68J12edVdd ; 20171122 ; subDT >									
//	        < yFrks0HW64iPC16s0PIXM21Ci47G47a7q71Izo7rw52ps89iS4qiCoPJraU3E5wP >									
//	        < j0lfEi7qk33bdm33rd53SA9WPYaF6JVAmsa7Wyc1r4oYR2e1Wv259xqqgHfrQCj5 >									
//	        < u =="0.000000000000000001" ; [ 000036270725871.000000000000000000 ; 000036276910550.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D830BC4BD83A2C2F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3611 à 3620									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3611 ; 9GA77my7sMKM26eip12Jc6rU8sVRJtcf6hGldqX9RuyfVKg8I ; 20171122 ; subDT >									
//	        < ww1JmKl0LqUivs99xVVhc2PoBba8cEfgBWsb68zvCKhZ4317ofHw0fKDr5DFtfmY >									
//	        < 60TSaUbJa1FI13qPMgm3xx26Mk45YEfg1YALqf0t2VLh1ljM4ok8YBctG05Yu237 >									
//	        < u =="0.000000000000000001" ; [ 000036276910550.000000000000000000 ; 000036288010518.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D83A2C2FD84B1C1B >									
//	    < PI_YU_ROMA ; Line_3612 ; 5mUHH59Hi19qJ8D0G3l9hgeeP3T1gmHCeLGG8mCuqU4zm9R06 ; 20171122 ; subDT >									
//	        < GoOux2209G0YtRd9LCClTJ5YXVxd8D33it89UdLEvQLH03j638oofy5EIb9tMn7Z >									
//	        < HR10D1zA8wQ8RwjnC9s0hq95ZKppcF4z4651cXq0Re7RY0p70I89QL2glEhOcqLT >									
//	        < u =="0.000000000000000001" ; [ 000036288010518.000000000000000000 ; 000036299074939.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D84B1C1BD85BFE25 >									
//	    < PI_YU_ROMA ; Line_3613 ; QPwG9yPs2Uf8EsP02kV2ZEX85WxqP79ve5F6BB4c7253a8SLJ ; 20171122 ; subDT >									
//	        < S4RmpY0Frf1Y21pXGTQOKXTl15RCNl3Hfo577pta64LhP33v6a32hVn6M954pri2 >									
//	        < 6958WQR8TD2Pm4h6gZ6puJ0f59IV2x72jH93k5u6H8G5MP4Nb595V57UyIScRnzf >									
//	        < u =="0.000000000000000001" ; [ 000036299074939.000000000000000000 ; 000036308400574.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D85BFE25D86A38F9 >									
//	    < PI_YU_ROMA ; Line_3614 ; 4FphgYAdtEVQcKeXsXJ2AzTqKr5xH26iup4KBKgc3ia46yFuZ ; 20171122 ; subDT >									
//	        < dv0Hh39Uv1NdMS895w9jVkr35DGTD09X8E2069U64AULsdgy9cBWlx1O2alYIZlT >									
//	        < 6xpri3gL9Mr7WJ6r8kdaB0QowRZQUvrO5D14I99zL0RV5yzdA2DJ1Uv42TQnXh08 >									
//	        < u =="0.000000000000000001" ; [ 000036308400574.000000000000000000 ; 000036320389538.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D86A38F9D87C8429 >									
//	    < PI_YU_ROMA ; Line_3615 ; pBjTrln2Ww76Apt6EeffCxg9OMkzaFT07ZP9ZyPHnhw33qh71 ; 20171122 ; subDT >									
//	        < vn3iIc3DOhLgM4nqWgo9vmz5Ajnt5kQgN1c1HWUEaJRDEX8DF4375NOLFHh5f03z >									
//	        < d3FRZmCi7vSSy88eIHJy3jOYGxtw3rAgLzZ1I7PHhoiJzn738srI3j9yR3LI410y >									
//	        < u =="0.000000000000000001" ; [ 000036320389538.000000000000000000 ; 000036326961567.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D87C8429D8868B5C >									
//	    < PI_YU_ROMA ; Line_3616 ; 9d6sV0n02tajKodFcM46732mlI681V09G28bChI7inULSpzV1 ; 20171122 ; subDT >									
//	        < 9MocP6Zj1K9c0P5h51NK8pGBhL9rDa8V7utUog7m6zXzr498Cf6Fk3VI3t8VsDK6 >									
//	        < e6i3k7LJqQ0GwRsQF7C889N54ZkH2qL31iM2ewE4i03bDUx2LUm5Rx2q4oEwCZ5R >									
//	        < u =="0.000000000000000001" ; [ 000036326961567.000000000000000000 ; 000036341095258.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8868B5CD89C1C55 >									
//	    < PI_YU_ROMA ; Line_3617 ; 2AWata7HEzSnyM9F28lK00M8P8w75btchaGKaL80C6F8q8Ig1 ; 20171122 ; subDT >									
//	        < 9xVEh7xNc3I06ISn1O5YDy3AS2OdDRaLCGG1VT4W4KvfKLaJVKZKwNx1071136vY >									
//	        < ApsGzQGT26WjIH6veB1v5pW75Gl7g7xScOhwwY9FQfukM2KYbsvLBRq2u99l9259 >									
//	        < u =="0.000000000000000001" ; [ 000036341095258.000000000000000000 ; 000036348888875.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D89C1C55D8A800B7 >									
//	    < PI_YU_ROMA ; Line_3618 ; T01H341Iht756rbdojhqpZs1os9o16M94c22smyJv0B7SctAU ; 20171122 ; subDT >									
//	        < B1WFHtxBvNtM9iWemsGn71vBZqVXDHc1Rk6LuNjeCSQ5GL75vH8Brel9h5GE8u5u >									
//	        < 20IwNJQ04g9vRaK1fjdKxhrI4z5Zf3cOWmnroV3Dj1M75t93h5VcQXiE63W8B9h8 >									
//	        < u =="0.000000000000000001" ; [ 000036348888875.000000000000000000 ; 000036354877430.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8A800B7D8B123FF >									
//	    < PI_YU_ROMA ; Line_3619 ; ONUkqvq8P8g6bt8zxov5DofgA0Vl1HMzrs8nZQOu96idHTdWW ; 20171122 ; subDT >									
//	        < Ly4C314q9JxicDD30xTJFspK5Zn1hH9eLAEt5b4equC7103VAGgM8zsa5zFGI1rV >									
//	        < tLmrI608eh4yZZtn5K45j5rU85vl3e3PZXH097XweXm21N84Ckj0WNwOMXytd97Q >									
//	        < u =="0.000000000000000001" ; [ 000036354877430.000000000000000000 ; 000036369488493.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8B123FFD8C76F71 >									
//	    < PI_YU_ROMA ; Line_3620 ; h8x81zQAXyk00dUtur6J6qw9R0D838Dkwf7IhDOeFBrc6Fii2 ; 20171122 ; subDT >									
//	        < BhrSXA8lS11s4ZTOx0RMw3KE1U470O09iC05m6nTmO1m1ln8OvQIBYsO1VVYaYE5 >									
//	        < 0c008zvAALQuT49w3T5TWp038O5AM1L0srWfSDX3PpSMd7MUs0CBw1Mkme67e419 >									
//	        < u =="0.000000000000000001" ; [ 000036369488493.000000000000000000 ; 000036377858496.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8C76F71D8D434F9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3621 à 3630									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3621 ; 0ZHuw046geyiq0g64TDQIx57xq74aA6W767JT2a5uJ51S8k64 ; 20171122 ; subDT >									
//	        < ciXI6uUAMUaCsNX4VzEXBT897526J47J2uXiDx4SA6W0faQ5FLS56ugrNGagrjrp >									
//	        < JDh9V8252SIt3U8Xj19uQL6yPjKZ4cc7iC2byiqVh4ny3UO31POJEhEo1eaSL85N >									
//	        < u =="0.000000000000000001" ; [ 000036377858496.000000000000000000 ; 000036385644832.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8D434F9D8E01683 >									
//	    < PI_YU_ROMA ; Line_3622 ; TW66jd7fBFUPOTU2aoGFXqN9gjR9ZVt04n29DBniF2U799C6Y ; 20171122 ; subDT >									
//	        < 26qi23PLJ5108on18BxrZbAMYbL8NaPL5y3Cs7Z7vlgm81BEZFj7ExpgNj9Li0b2 >									
//	        < M273o005QBFR321bfOYHaegDP0SJ6m1rI5TYEiWYmq2Dja0r3cMBzt39CKLZT1MQ >									
//	        < u =="0.000000000000000001" ; [ 000036385644832.000000000000000000 ; 000036400159838.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8E01683D8F63C6F >									
//	    < PI_YU_ROMA ; Line_3623 ; Bz1H857g5eEp82UUCXlRS34k0oWI268Jmg293otF4eY6mbeuT ; 20171122 ; subDT >									
//	        < 71oD85FcTn0r3EYNSndE1b76N4Yc21MRISJ8SVYg21g2J1A5g9C1urpvtTkzIUja >									
//	        < 0UuY63bVI4HdBrJ0AU4D7nqj96Y9Q948l7cWzfAmi6Ko1Ur1W53jc26C353LfoBC >									
//	        < u =="0.000000000000000001" ; [ 000036400159838.000000000000000000 ; 000036407202932.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8F63C6FD900FBA5 >									
//	    < PI_YU_ROMA ; Line_3624 ; 4hlxze316X5r8Vyxp451cYdP88YFCvMFcBmCF1s88kAxDvY10 ; 20171122 ; subDT >									
//	        < k233Ig1neIoeeiemohT7coxm0VemBEYB9lJe4Y8W4ZTFBf1cg0Mbyb356Vptr4o9 >									
//	        < 247dJqd2BiDcA3f8Y6937xCgICCBrUFS5VVQxYz4cMOwnv08GrZxC5fUVq3VJTu5 >									
//	        < u =="0.000000000000000001" ; [ 000036407202932.000000000000000000 ; 000036417878318.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D900FBA5D91145B7 >									
//	    < PI_YU_ROMA ; Line_3625 ; 6OG8n73D45IP5K568b02744WVet1fgZAcYJ14Q6pg2L25rql8 ; 20171122 ; subDT >									
//	        < xR4T9btuv37cE4Vv27nPvGw990BsBp3DsCaDVuOZtdb7u4ZXTcGgPg1p0W4V0EcU >									
//	        < ClBkf80XgM7tACT9kbA1TRJlPT9j90159t6heMT0D9anZ2Ei9dzTd3mgYPrQbVdT >									
//	        < u =="0.000000000000000001" ; [ 000036417878318.000000000000000000 ; 000036426750077.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D91145B7D91ECF3F >									
//	    < PI_YU_ROMA ; Line_3626 ; 3fb975I63w5Rq5G0m9Uzb6ljsFER09vyp7QMJ0s0V9MPE6VZT ; 20171122 ; subDT >									
//	        < CH8S5H6ErzNu4Edi2E6n7OeZ6IN51E27fM3PI16je7i38OgS8XR191y4S0uOOa71 >									
//	        < m4YWzRN2nu4D5fRfGwIvXMjfI4BB78J5O4N4wEgS7Rq1sJ6DNIn421yJ14hXAXhE >									
//	        < u =="0.000000000000000001" ; [ 000036426750077.000000000000000000 ; 000036435167616.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D91ECF3FD92BA759 >									
//	    < PI_YU_ROMA ; Line_3627 ; 2E1rsnj597bIxRyDLpYw8rnsZ68Dr7oFK0rZV0ZLUwRFIg495 ; 20171122 ; subDT >									
//	        < pRou7ie6r8uTsdD6T81Y51Xh5SjG9I7elK932xS20BgN3NN9A3a2wIWot9342qUb >									
//	        < IgewDO13TqGfV6cvpy9X1Z07SO6G9FXWn9K55nBe4ui1WH01456wpCi2NWtSSM27 >									
//	        < u =="0.000000000000000001" ; [ 000036435167616.000000000000000000 ; 000036442346670.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D92BA759D9369BAB >									
//	    < PI_YU_ROMA ; Line_3628 ; k5C8bkqbO8r47v0lORLyfYeAIP2W1PvyFNoKmc6HdTt4OZ24N ; 20171122 ; subDT >									
//	        < 6ChbQJSf8IC7bgZwza2KFUcszzY4aOVAaeuRVpN61063ju52R802V1sE20XX4FY4 >									
//	        < p7403C0L0219doN67Sjw8hte9zYA17ajkZ4D3d3DYV8Ic7249qblAmA4O2mW9H0t >									
//	        < u =="0.000000000000000001" ; [ 000036442346670.000000000000000000 ; 000036449510389.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9369BABD94189FE >									
//	    < PI_YU_ROMA ; Line_3629 ; as82Zha2226Y7c4SGZfmLrpdUbPnnn5M23SoI1XP9r3eaFPYy ; 20171122 ; subDT >									
//	        < pEWY8So1DeAtf919m71K34KF08Zcji71VvJOjzv1EOB9T7137if3ANVb1PH9BYoI >									
//	        < Q2VzXwJjYN9zHCwOk9n166Yzujx7qYydbc7413r6wUnc1t2kH15GcxFbxM6FuRfT >									
//	        < u =="0.000000000000000001" ; [ 000036449510389.000000000000000000 ; 000036460213324.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D94189FED951DED4 >									
//	    < PI_YU_ROMA ; Line_3630 ; v466Y2a9GaK3N6A56t5Fo0iYaz1E1aKfIqapW32la5wg4CqT4 ; 20171122 ; subDT >									
//	        < 1spNoHk16o9F6jmlH7JC0Aa31pX1tX2219p3V2U0JEQ68gu4xj5o4a3VaPOKa74U >									
//	        < 2sa0By73mva00A40nj4L9Z0822979jhL7xF7iZSS2qPRcsbl1wfW224Xtiy4pzqC >									
//	        < u =="0.000000000000000001" ; [ 000036460213324.000000000000000000 ; 000036467257953.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D951DED4D95C9EA3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3631 à 3640									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3631 ; 942lO68Gqh8SNR0h190bLrZ83id2zq8cK550xW6bYyNU4p3Kn ; 20171122 ; subDT >									
//	        < arLI73k8P2Oig687Ismr0yxES0Q4n1hGN3xfPz4wXr8TUv3o0moh0oTx4TNhiGRV >									
//	        < 0r369FWOTt9E4FU8DR20a2m7DhMIS4LKQQx0C63h9a8Rkq7x7IgXm6G43E376F6H >									
//	        < u =="0.000000000000000001" ; [ 000036467257953.000000000000000000 ; 000036475719944.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D95C9EA3D969881A >									
//	    < PI_YU_ROMA ; Line_3632 ; 118bU9btJ8X5cP3tT6l82GQd5plC7d81LbQhGKLD5G78njXEq ; 20171122 ; subDT >									
//	        < 02v7x743m94951ByqCEjL10sIIWB6OlXFeu8xgSal6E06DC2THwWRZJr4bVxffmr >									
//	        < P67UcJ8dh1nc5ul7vN38A7dm014ZV3EI6lZe1wzi2Gq8b0iw89k9c986p02N85dW >									
//	        < u =="0.000000000000000001" ; [ 000036475719944.000000000000000000 ; 000036482734316.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D969881AD9743C17 >									
//	    < PI_YU_ROMA ; Line_3633 ; c29i0s93UekQLTPUG1L8lNjH3ReFI7JUOOZI3c045kYZOdCf2 ; 20171122 ; subDT >									
//	        < TtIrA1rehQQ7WN00S0Rv312Ow1egH2i7K5J6n755haEXD5P0wIY66a523s4oVJ48 >									
//	        < y0Kc4FUMu11MNlZ7s0d8Y11823nB5lAFs71Pp38Sj88q1HfmxC58N99yS5v2D8R0 >									
//	        < u =="0.000000000000000001" ; [ 000036482734316.000000000000000000 ; 000036493594206.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9743C17D984CE3C >									
//	    < PI_YU_ROMA ; Line_3634 ; 14mBqwm56B6qaeC2lOtyDEiydLCkZ3LiuX083yO5A29JaKJuo ; 20171122 ; subDT >									
//	        < EZNFL45OR72r3PhQxy0QjmnxktGB7n3nMt7gs9iwD4902ypt0MMl5a7qUjbZRM13 >									
//	        < B130vAuJCp8103Cw1q9f5H8041v4t5KLB2q3dG63umzN0IQ95Zu1jm870ClUPI31 >									
//	        < u =="0.000000000000000001" ; [ 000036493594206.000000000000000000 ; 000036498610761.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D984CE3CD98C75D4 >									
//	    < PI_YU_ROMA ; Line_3635 ; sT2V85U7x8fms2rvp1lVX11WkFGbeY04ThO9WufZ8zHL479SR ; 20171122 ; subDT >									
//	        < 8zbR0E4Ykwh29XIr882qEqixspH0k1cYEF8C0Z3O31p3rmb74881g0JKoTUxOe5N >									
//	        < esoGB9BWN5Mu01AnXPjJge83QO6x78kD40VeAtZokQFm7ZXaavg0X1LvPRpOmj5h >									
//	        < u =="0.000000000000000001" ; [ 000036498610761.000000000000000000 ; 000036505521686.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D98C75D4D9970168 >									
//	    < PI_YU_ROMA ; Line_3636 ; 960V45k1z63JA03dWtFJ038eqtt19c5idKzOwb7ofx08FDcQE ; 20171122 ; subDT >									
//	        < 8FbdcdDP1P887W44Ph7p87NGlt7ww84H6M06LhTG8b8ZkP9IQo8NX8DK6XJd6jmj >									
//	        < Qv6645Bm81AcCEHp78p6s41uWV8Zx0Fv12WxXr5mOzutmJCUX36IIxi6th2mwtMz >									
//	        < u =="0.000000000000000001" ; [ 000036505521686.000000000000000000 ; 000036511284965.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9970168D99FCCB0 >									
//	    < PI_YU_ROMA ; Line_3637 ; 90yJ5IqVhVrXJ965gf0v73g9jYN56Q819qxDX4i9OPj06fzvK ; 20171122 ; subDT >									
//	        < B4195qjo2E4fqnz8NzqPxlLb9Uv5J4wXuI8HhlPS3nJyO3rQMK2f5gn30zG0mRi5 >									
//	        < gTEBSy79SX28eMbFxe20Vw4Qj4Z1aPZ24a0H7YJqZS2AWVD0ZSjCw3I5AeiJCZ1y >									
//	        < u =="0.000000000000000001" ; [ 000036511284965.000000000000000000 ; 000036517934927.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D99FCCB0D9A9F254 >									
//	    < PI_YU_ROMA ; Line_3638 ; 4tC7ib8i00osNmfcVq21223s1VfOr1OkZxd96i0Fq64cA4in6 ; 20171122 ; subDT >									
//	        < c67pIc148Z911jrn7eYP1dgdJ0ytGu914vCsjdaHNj52RZ5Vm26gTMVe4NCTh2gN >									
//	        < Sg695h03GeiorbddLj0LcUzV7nGJpevJm5R9BD18Dp7hKuG9XPfq2iks270vBF0I >									
//	        < u =="0.000000000000000001" ; [ 000036517934927.000000000000000000 ; 000036526549666.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9A9F254D9B71776 >									
//	    < PI_YU_ROMA ; Line_3639 ; D6Q6gvEyf9xAVpb0GexQg7Wni29s6s9iDZQHeLf7h0V6Tvg7h ; 20171122 ; subDT >									
//	        < GSj45o3b6JX0b9rTkI2aFp7lRkcfraHJ94h35Se38Ma7su483iokd1sQxY84Q253 >									
//	        < X7XH8r1eV9Xlx96u1X8MwQke5D0m36Z85FN434Ka2XqN45n81Le3t9rZE80w1SCb >									
//	        < u =="0.000000000000000001" ; [ 000036526549666.000000000000000000 ; 000036541519647.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9B71776D9CDEF1C >									
//	    < PI_YU_ROMA ; Line_3640 ; r3Bn34wRSZ96G2wfh6XFfR1BkhaQoQofarlUvqyv0y6PZbUlO ; 20171122 ; subDT >									
//	        < T1ASpf1oVRl4ay4Pf7K1Lxn91rAdr054H17OTrOF9z03UE2g1dbFdX71XGHL8xPu >									
//	        < 13Jxm1c7N48y3l870Fsz0Z02ZIu9LW10DT8v7PYmbH4hE7qn72ZyeRuaO9amtjV4 >									
//	        < u =="0.000000000000000001" ; [ 000036541519647.000000000000000000 ; 000036555407806.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9CDEF1CD9E3202C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3641 à 3650									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3641 ; acYsP6b3uVx462okDw5MBpW2iKyf26fDLJw45n5BEqOjk6nc2 ; 20171122 ; subDT >									
//	        < b3r4OTKl4cnJ9G4yLD6M1Bkbp1OWMIn1OKMKD8mspIYUMfRaAiI9rL9W34286IxS >									
//	        < zjpuggCnML9cc6934mTib4Oycxh09U8rLWasBSt13NXAA361qAr8JF2lYmcqLJ4i >									
//	        < u =="0.000000000000000001" ; [ 000036555407806.000000000000000000 ; 000036567912079.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9E3202CD9F634A7 >									
//	    < PI_YU_ROMA ; Line_3642 ; 22MhUp3EMvHnsm9l2D9Gt8LeNJQ52afgPVwo5NosaHGbkxS7N ; 20171122 ; subDT >									
//	        < 3GS3Y57YY95l9yI546q51o47NUi4Cf4ld1rs5aC93q8JgfL0dmF3KujUXyL3QDJ8 >									
//	        < eaXD85i1OA11OZKG5591t04c5Ve188AMq81ZLL6h3qvDj30eqY49ug4I2N6E59VV >									
//	        < u =="0.000000000000000001" ; [ 000036567912079.000000000000000000 ; 000036580930102.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9F634A7DA0A11D2 >									
//	    < PI_YU_ROMA ; Line_3643 ; 8maZ8Qk5vk88W7UAZnwqRKOT6n2P6JVZtjmv03rxDPpmgO4hO ; 20171122 ; subDT >									
//	        < 7aI0fmAycLbc4zi4m75vzvmZ96kA5732OUDpJf8i7yf0vvm4Eq3EveZ2Cm1Nir2D >									
//	        < bIkE0C7Om3Z92p782ehF0YP9NPS9OLI92s1bzf255fIc3S3UVukWkt9sm7fK17sU >									
//	        < u =="0.000000000000000001" ; [ 000036580930102.000000000000000000 ; 000036590886226.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA0A11D2DA1942EE >									
//	    < PI_YU_ROMA ; Line_3644 ; 20J20h59wseOa348472Gw1RyZE814Z42BH67P28AzxS226J5f ; 20171122 ; subDT >									
//	        < A23X7Hij8NH776o35gjeesz89iw2iH9s7lU1i1Nm6ez9fEX8uJePc20Zo7O7bcM3 >									
//	        < 7v9D9ndhC90rpEe3enAiX991fFJ8zmXlFOoba8Z4TMk37KhXDL5J8x45EyBM7GSe >									
//	        < u =="0.000000000000000001" ; [ 000036590886226.000000000000000000 ; 000036605702297.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA1942EEDA2FDE75 >									
//	    < PI_YU_ROMA ; Line_3645 ; Q3kbk5162SJcPu35Vx3HD6Ty8dM9JgZ7r6bUXDDOO512z5ANI ; 20171122 ; subDT >									
//	        < y227Ne4DBRggrvf3vtO3KqM8C86eZB5H3ZwqF54wiPNm35tiLyaQ1AUH10Z7fhzs >									
//	        < 27ivY827Q0H3Ixk1f7QFX7hJOvbaZaVG7rDt8z7Bm37Yo26b7ec8WUHdl70g9dI2 >									
//	        < u =="0.000000000000000001" ; [ 000036605702297.000000000000000000 ; 000036615260588.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA2FDE75DA3E742A >									
//	    < PI_YU_ROMA ; Line_3646 ; Z2Z89ISsABu7770wS9yo5GLIamP5R1TAX72Qheuh74Mz2moo8 ; 20171122 ; subDT >									
//	        < e2gDHEd8Re9J5w7JbnVJ1XynsThrc93K9rAUDs1h7e73NKwjJ5ZnM9415Y4BSYSp >									
//	        < fJmgFy17N73W3yHx1GtWKf97nvA1UFaAet3eUcVE32bClEjRX1iR9oZBO90auN3V >									
//	        < u =="0.000000000000000001" ; [ 000036615260588.000000000000000000 ; 000036620518319.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA3E742ADA4679F7 >									
//	    < PI_YU_ROMA ; Line_3647 ; Xgb7Z7f36qFf94bi8sNza9P1I4t1UnjmHONFjzIf9Vy04U0is ; 20171122 ; subDT >									
//	        < SaVqd0lRFw782WFz137jBh1h5ee3IwH5tA7OxJN9k7Bnynlk76wC996DlKXc657X >									
//	        < 8O162QEfL0grw7t1w94EFE4X7Jd64pv5PsAZA9541NaaxBD1pJhACF255zvG6Rf9 >									
//	        < u =="0.000000000000000001" ; [ 000036620518319.000000000000000000 ; 000036627965445.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA4679F7DA51D700 >									
//	    < PI_YU_ROMA ; Line_3648 ; bP7fnp1Fvc6P47rsEyRr3exw90a8iX2PJ0tNaQ51epgq68d0W ; 20171122 ; subDT >									
//	        < 2e7O1i0sj1u1eLQfKUjz30qxWJ9s2J1Ke0R2fkQ5Rv4vkNu952TPB34PivTBMOGt >									
//	        < tHc8IUuCIDSYLhWjjk6266M7ft4eH7NIWLnuyFNu6SepQqC00030Wx29Y2d1oyFv >									
//	        < u =="0.000000000000000001" ; [ 000036627965445.000000000000000000 ; 000036638048246.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA51D700DA613998 >									
//	    < PI_YU_ROMA ; Line_3649 ; 1jUyQuMADbOG3gsNgM2iiAq9ZTn9LjY2ABGMbjf2hAEs5wQ92 ; 20171122 ; subDT >									
//	        < hOpPgF87qqI4485Dx1Q2UFmPitcU1r5Yorfa8g7Yden5Q6Q17jb6AcZ249dUSN23 >									
//	        < e197TOhhR25k7SPnUE7f38rwKPOg5K714gJ4DJabT06Z5Of5Asn1udn937bo0LwW >									
//	        < u =="0.000000000000000001" ; [ 000036638048246.000000000000000000 ; 000036646732884.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA613998DA6E7A08 >									
//	    < PI_YU_ROMA ; Line_3650 ; 862zfL02lT57oRazD3P4tOVU06m07agIjS7Dr9l8Z0O73m4Q0 ; 20171122 ; subDT >									
//	        < 0iOcE2P9Rz19U6SaK7bIM50M4JRDH01J4BE3qOj6l3xX1TkZ5zKO1pvbeMuHqtep >									
//	        < Z98Zmma2q843p3ZLxD3biqwetFWM4HDPVWn2qSCjTO01DXA07nrc91Y9N244te50 >									
//	        < u =="0.000000000000000001" ; [ 000036646732884.000000000000000000 ; 000036659545163.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA6E7A08DA8206D4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3651 à 3660									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3651 ; 528h02ZGsgv99e5cIGNoiS4Ntb9Q8EN65ucGt3HUbH738hhsD ; 20171122 ; subDT >									
//	        < 9v68Rn3WDPnKah0nra0pMx0Xc9fA4r4N2OSj119J6T5COyeX9kK6a23c557rKJni >									
//	        < L545K9nYz9984b3OuSpuS705WTBb60isF3ol019wiMxIPVvKQecrr5F179xJNDbX >									
//	        < u =="0.000000000000000001" ; [ 000036659545163.000000000000000000 ; 000036669109270.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA8206D4DA909ECF >									
//	    < PI_YU_ROMA ; Line_3652 ; vAQ08WNhrme02S5t2Ez3K1SEGPN8qnqM3JBJYz2tbZR59oIWV ; 20171122 ; subDT >									
//	        < Imr70j5gk764wAJU94pu146lF6mDS0tP06Xw53Yr8xlQvh2X4Q9Bg6s5Zx54Nte2 >									
//	        < T5m69Ju9861cgs5E5jE8oIWcrIrE9Rie2O1Va7tp0v194bVhyCLIB2RmLX6NlDQ6 >									
//	        < u =="0.000000000000000001" ; [ 000036669109270.000000000000000000 ; 000036676364740.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA909ECFDA9BB0FA >									
//	    < PI_YU_ROMA ; Line_3653 ; cEW70yhP1P8t0Bn40thrYM2Jv19EnX6026QYpxF1ww73VIYDH ; 20171122 ; subDT >									
//	        < S87F29SmZlrMO5DTZd9l29SW061LgHrK5eK565FO93Qwy3bzM64JhQc50n9gj5uq >									
//	        < P3E4lgiP7x89AZ67Sa2xxONceeikiAUPKx0pD1D0aTmXCAL5rbMq533wyk525wg9 >									
//	        < u =="0.000000000000000001" ; [ 000036676364740.000000000000000000 ; 000036682654107.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA9BB0FADAA549C2 >									
//	    < PI_YU_ROMA ; Line_3654 ; b7N4b9n1vfZt1YvXCEUU8ePimCEx7jbZH0f10D89A31E08f1B ; 20171122 ; subDT >									
//	        < 3I9OPMmChbv7YcmIhTmVkzW23IixHCG23F6Uk6E6PWuer2baC6JC07EkqDV1N1SE >									
//	        < W7s9QDd4a24qYIBMzf9N5GXG79qYrp3zzB6216oL2Dis9R9u4B6zd16014q4TTUI >									
//	        < u =="0.000000000000000001" ; [ 000036682654107.000000000000000000 ; 000036691210365.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DAA549C2DAB2580C >									
//	    < PI_YU_ROMA ; Line_3655 ; 61w2LFvzv2p8wI5MSIE2QVVm6Dc4317MKTBCotDB7EanGR9kc ; 20171122 ; subDT >									
//	        < s3zu2u67BR4AIpXjhD3D8LL634Eq6S9K4wji9o67lgm6N8aL65SpgUK1j79dIrz7 >									
//	        < VX9pLcukwqbvCVtKiX0C3Ye0rU2Jp7o89uY18nq8N25G0Zu8x5npn7rDqzIRBsQQ >									
//	        < u =="0.000000000000000001" ; [ 000036691210365.000000000000000000 ; 000036706185208.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DAB2580CDAC93198 >									
//	    < PI_YU_ROMA ; Line_3656 ; 7MIMbhq00cAHNbp58uTW2oIZcpa953CL6nx9Oqi3zJf2S1137 ; 20171122 ; subDT >									
//	        < SqP84ww37Eu9GM7C3A27183xv2aL6250V9O6xZA6FEIEnOi90PXT0SfEJeUFLCt7 >									
//	        < Yy2jL0Ov33168R579k4vFUI5k8gnzpF6yYH63BZIW9l3808T6v06N8xMMZT82lWS >									
//	        < u =="0.000000000000000001" ; [ 000036706185208.000000000000000000 ; 000036719487690.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DAC93198DADD7DE1 >									
//	    < PI_YU_ROMA ; Line_3657 ; abWe43A47w03Xyc30R77ij5MRI68Ll1YEj4G3ijLuf27u2R0d ; 20171122 ; subDT >									
//	        < 697iAu3p55L90s2Hu09xx51Gff9IrW3vZ4Y3H6x9Hu72w6g87g5pBd400932aAO6 >									
//	        < 1Pib531ozAJmi9q2929kYE55wY1pZImXk3UEe3nzyPA61wR9cO3m4e8Nb0l9jR4K >									
//	        < u =="0.000000000000000001" ; [ 000036719487690.000000000000000000 ; 000036728846544.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DADD7DE1DAEBC5AE >									
//	    < PI_YU_ROMA ; Line_3658 ; PGG07U0k60N4O0w6e6GM8sDxno3e9OC3awQqpA6bUVrCJj308 ; 20171122 ; subDT >									
//	        < 36r14X7eo1b0itFU63fv70W90239qw2W3dSJ2qsg7SynqJmBgILp508k31ypo274 >									
//	        < 5F91dfguyQiNPCYOB4r61e916XRY89It81763H4R9yYxKf2l303vq5Af921Lp47G >									
//	        < u =="0.000000000000000001" ; [ 000036728846544.000000000000000000 ; 000036739873294.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DAEBC5AEDAFC9901 >									
//	    < PI_YU_ROMA ; Line_3659 ; j6JA4rI194ot75SymujV7s0pHyLSwuIOrAEH9nLhT3yKk1FM7 ; 20171122 ; subDT >									
//	        < tG048P66V0jz7sus20tQyR3ZCscdcsfTkXpdgt8MN1xsg18K16BFg8o1iPP2dd53 >									
//	        < Ve7C6Hm0VKPQxNaouxP6vncfw9SO21tY8Y6MVHTl7q80vIyA3h6E21s80N5iRw6X >									
//	        < u =="0.000000000000000001" ; [ 000036739873294.000000000000000000 ; 000036747790330.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DAFC9901DB08AD99 >									
//	    < PI_YU_ROMA ; Line_3660 ; 38YhGXrsGE2c9yuR99K65sa5IQb9KSe0ToP7PkjqmwfdlP63Q ; 20171122 ; subDT >									
//	        < fz1i6525ZK8w419mRaBMfR67DvV9mc98HzPveud70xXEOZ32JzKA5jlMMY08oGJj >									
//	        < t33wrcRm10nTI929v9zIwhO7431r7i639W2RgXIO3O3AVmJQy02KrCm374yG1PPv >									
//	        < u =="0.000000000000000001" ; [ 000036747790330.000000000000000000 ; 000036759148794.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB08AD99DB1A027F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3661 à 3670									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3661 ; KwNB03c28SXHa1Ep720oqc8yQbk5PkiI3q6RF56Zltv3eU9HG ; 20171122 ; subDT >									
//	        < u9wPRVWhSw1bvtC1D426FIy2Kgf9mTP8P25RV19aT699RS9wWwjk0i42941GNM36 >									
//	        < 2hpk8i30su08s9252494d85YbLw0n8617f1wBd5e48rq0M0FBi3gRBDKn8AMFz8K >									
//	        < u =="0.000000000000000001" ; [ 000036759148794.000000000000000000 ; 000036766865726.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB1A027FDB25C8EC >									
//	    < PI_YU_ROMA ; Line_3662 ; H5G07oAJ7E53GNDsEwz09Fr09078xCGs7r955U9J1rw0JuGSc ; 20171122 ; subDT >									
//	        < wc81Y8r8Kt2X8Ycb74u0V7toLBqcm5OjZ7bd0Z05gZD5B16U34l6bFKBA33oN0zM >									
//	        < NW56Vrv9bCg20EFNfjLp939w9O5228Nlwq7Z6s91A48HP16FB4d247Ldwd3AcVZH >									
//	        < u =="0.000000000000000001" ; [ 000036766865726.000000000000000000 ; 000036777913270.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB25C8ECDB36A45F >									
//	    < PI_YU_ROMA ; Line_3663 ; 9s8zzGA8Yv2kaFm89HV51Brh4mTY18cW6iHRxzBIQzzAYKWro ; 20171122 ; subDT >									
//	        < 4S678yQ8pJ1U44zjgB6RF1r56gAJW0c9c453Mz8XSVENUFXHJVG54CtW1L9qv59E >									
//	        < p5RI6gNqJ1qIZH6Sk8j3NvJ4w7R2zSbL3uwEcbMkx4wu0U5qS21S9OFqfTEz0H53 >									
//	        < u =="0.000000000000000001" ; [ 000036777913270.000000000000000000 ; 000036783192950.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB36A45FDB3EB2BF >									
//	    < PI_YU_ROMA ; Line_3664 ; rK28mS2h05d56R4mYh5xHrl2UU121JtbA2ngeb3P9OCoyX464 ; 20171122 ; subDT >									
//	        < R4Zd6fmdl1taP5EKyBC40LfJrM6BFevcUI85TFOr10rCvq8Puu30v52i17bRz4tT >									
//	        < Vc1j2L25M87yBPKaEeaY12VMz52VhyD4U7H171FvLfZt5mgw1Bi30xz3Oe7izwn1 >									
//	        < u =="0.000000000000000001" ; [ 000036783192950.000000000000000000 ; 000036789310203.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB3EB2BFDB48084C >									
//	    < PI_YU_ROMA ; Line_3665 ; 81CeKM7a5RVLoT7wP7fx1vv2INer299xoy71P4Kj7DMXHV18R ; 20171122 ; subDT >									
//	        < 4w6s9I7WK4tw4V4r263g473AxZQYPXKK8DAmk2oBAaHx1OU4d5pUVBdlX48hp7LK >									
//	        < nA65gGw8Rco5uSyev4xZZ3IL13Povcu3XV5G0TvA1zIrl1fRs7DV8f2996ClCAW7 >									
//	        < u =="0.000000000000000001" ; [ 000036789310203.000000000000000000 ; 000036800045933.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB48084CDB5869F1 >									
//	    < PI_YU_ROMA ; Line_3666 ; v25gnoL99H771v6zWwdsd41yoF6E1Q9SA2j4DSJ7woWw8ts0g ; 20171122 ; subDT >									
//	        < 5zVfhGF3841tO0zd381OqHr3KUJ3yI11xDQA74pyjbBt86Js7JYh39OB2XWd7O1v >									
//	        < fvN1ReHbExv2F148f0RA7QZ0ml7Q2ZLvb027XJ801Zwmo58a64nWB9o1L6Qi01g5 >									
//	        < u =="0.000000000000000001" ; [ 000036800045933.000000000000000000 ; 000036811553241.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB5869F1DB69F8FC >									
//	    < PI_YU_ROMA ; Line_3667 ; 2DVgP2AhuyN9CB068Un48T2zd3SGef0XAF8EbxZ82o73o950F ; 20171122 ; subDT >									
//	        < 6lZ593x4dT5qvbY8T9QCzuAtw5x1Y812PHJz0akiT6C35FNXme12Fz2Xja2iY2sV >									
//	        < l16Ea4VnwInygr0w2vCE9hXt0n4St6mM91g65Zyzk3h4ym0b2chB46Jf9m986fc2 >									
//	        < u =="0.000000000000000001" ; [ 000036811553241.000000000000000000 ; 000036819672149.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB69F8FCDB765C6E >									
//	    < PI_YU_ROMA ; Line_3668 ; I33O0KVtbo1vWrPmsW91gK8q9F43490yCAAL6Syclkk2BK58b ; 20171122 ; subDT >									
//	        < vrxWu08C125tsXXO0rP00ADiwA1hr39cqdw3Vt58Wd7Dt9QK1319EvBnfJowovzS >									
//	        < W9OZQn4b0C09H9MXz99H5S7r513WNl8EGUGqSPydz0vf2v9WdYm07Fp7pOoIesT3 >									
//	        < u =="0.000000000000000001" ; [ 000036819672149.000000000000000000 ; 000036825498479.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB765C6EDB7F4057 >									
//	    < PI_YU_ROMA ; Line_3669 ; d2Gvo8r4Ci8k9C798N9WK3jdUiyDlgU7i8RpL2OTa167Cxb4U ; 20171122 ; subDT >									
//	        < d73W80Ww61mO4EgdNlY6414xr51fF0365s4ShZM01OuXt33K3vkBjkgO9thaLahr >									
//	        < VF6L4aubZaC7VDulLUbmn7XGw38GHA79zHa7L1vmdkef4CeV3K8HIyhlo6S1X5KG >									
//	        < u =="0.000000000000000001" ; [ 000036825498479.000000000000000000 ; 000036835594543.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB7F4057DB8EA81E >									
//	    < PI_YU_ROMA ; Line_3670 ; MuJs71EuP8D7C700J84Zsq4kE4ugLil23fV7ATkbK4UB89au0 ; 20171122 ; subDT >									
//	        < rZTjqHe1YKj5EM3LVzYN4QVUP793K30htZ436h1qWtaK614JEia605q9kQsG9NP7 >									
//	        < Jnq23s7k18tQlNP3zrdpPQucU36vZnJvedvZ7y3TD9sGM4V2rTTVKae5EKb01k8e >									
//	        < u =="0.000000000000000001" ; [ 000036835594543.000000000000000000 ; 000036850486416.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB8EA81EDBA56141 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3671 à 3680									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3671 ; T471dQP143z8cID1Un4USpea948rNy5wKQ1rww9Qv4H2EX2ao ; 20171122 ; subDT >									
//	        < C72923iJD4B6Sf3c44QFOu0Y9F42Tl7Li56EhDdp51V9Y4813fy77nNFHqFNlsH3 >									
//	        < 0965kY16581g2JYpZJEChg7AhB079Jx1vOH9W0s5AGgoonrvyIv4hBQg6uojr3m3 >									
//	        < u =="0.000000000000000001" ; [ 000036850486416.000000000000000000 ; 000036864950448.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DBA56141DBBB7344 >									
//	    < PI_YU_ROMA ; Line_3672 ; F22X7XRONuFt5RHA4F7tr3Ey58692xzHvb43G4D5qTW8sfJJT ; 20171122 ; subDT >									
//	        < 1ZIwa9LuM726z6jdn1Se0Kj63WZTCkjN8S0osYr70G7zrQb0UWN6wtSFI8I1gDBv >									
//	        < hEzw8Pwal5n83r8MUhU21121c1zyg1gacPWr6NorT5aQ8T28Z1a8G2rBrxq5Cyt1 >									
//	        < u =="0.000000000000000001" ; [ 000036864950448.000000000000000000 ; 000036869982221.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DBBB7344DBC320CE >									
//	    < PI_YU_ROMA ; Line_3673 ; s9I371Dtb1yqReU2Y9Q4TTijTq393HbUcS4A03VH1G4h0yMMW ; 20171122 ; subDT >									
//	        < y0KDp3HyeSBT3wo1B1brBU4RM1SrtDd9N8Y9BA16ag19pap3f394yu6eZ9ACIiHM >									
//	        < G7HRdP3ZT9WEIJKQcccdWj466wM80GU5K0lFQS0EJF7Fy9V9Un46eBRG2gy0qln4 >									
//	        < u =="0.000000000000000001" ; [ 000036869982221.000000000000000000 ; 000036877377740.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DBC320CEDBCE69AE >									
//	    < PI_YU_ROMA ; Line_3674 ; U33Gaq23tylf3wiTb11I1W0J5qxg843RlxLphvNdaul0y31QB ; 20171122 ; subDT >									
//	        < 0va42Zuz7YJ88G9e82893P8N6XU59vEf3wzISLp5y5R0ziH3I3eN4nr01u4z3EAw >									
//	        < Q1I5514Q6WUOmnu0rx16WRH6QqFy1kblaiY923G4ZHtdeohcr290E092dpMUvSQF >									
//	        < u =="0.000000000000000001" ; [ 000036877377740.000000000000000000 ; 000036892001545.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DBCE69AEDBE4BA1A >									
//	    < PI_YU_ROMA ; Line_3675 ; uvfxy870cabelmu577cQVcaM5g1v6Sb9Jmz9rT8J2D3kw4b3K ; 20171122 ; subDT >									
//	        < 8vr4G1bP76znLrI1605q32CzaKKs5X6xLcVMo3336px9IL3bY654aj4a5vNexQmK >									
//	        < i4r47R4430j4F9jFm1aq84qaC2Ite7qKVGKa5VmyN81WMRQ2ZFWYqupRlXHw5dgR >									
//	        < u =="0.000000000000000001" ; [ 000036892001545.000000000000000000 ; 000036905559969.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DBE4BA1ADBF96A5C >									
//	    < PI_YU_ROMA ; Line_3676 ; ugyOCrxfc9y1KZT8pCY2fv09F84OFDG938B25El1Ry4Uvbd7B ; 20171122 ; subDT >									
//	        < 1Ldblsmv8S79fUc15iP33Pe85rJGc9Jd9mrrAlBWBmSIICO0L0yHI3mN7F72UFwg >									
//	        < PuW1dYaa8NNsQKWmfN25254y92iqdB65J71NAjBNAtnrNw087xJKlnnx8WZ2qh9L >									
//	        < u =="0.000000000000000001" ; [ 000036905559969.000000000000000000 ; 000036914345615.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DBF96A5CDC06D241 >									
//	    < PI_YU_ROMA ; Line_3677 ; 7PXs5tc5DB4EMzf5190Dyr6U5Olj83GTWqw0C2F56uN9iAs09 ; 20171122 ; subDT >									
//	        < 3GF2285rsBydur3EM56Leq55Jj9S3jL1E6fRV0Q4IY96YDI0m7AjTf7Zv80V9doT >									
//	        < dWINp4ETL8c87o6YZU5fYfV4gKNz5XdPLr58eW6q54Cr4R8n3JR2DBAGU78tljfS >									
//	        < u =="0.000000000000000001" ; [ 000036914345615.000000000000000000 ; 000036922004075.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC06D241DC1281D7 >									
//	    < PI_YU_ROMA ; Line_3678 ; w237ZEI1LE36104HEjM1pwf3Z9ep1lYP5a8E21vGWHGZ0r9q2 ; 20171122 ; subDT >									
//	        < P4v11025uDqhyBqsn7CuacNBw25cE7wuSUh29DRlEg4s8sdEAt0oRLouEC2lnZ5i >									
//	        < j9YiKm0oC8pJ6QB7WBxscg02DwIS659kyMC7pu5Il3y0X71V4mmU18ZQZxQ3nqrY >									
//	        < u =="0.000000000000000001" ; [ 000036922004075.000000000000000000 ; 000036928574958.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC1281D7DC1C8897 >									
//	    < PI_YU_ROMA ; Line_3679 ; 5ps31I1154DxA3d48RUYWSRb4I41UOS2Q2fL1jkS8A1Z86Ebh ; 20171122 ; subDT >									
//	        < Ifb1YB1K4Du1On3j6yP0lJXxx5p7ItZQKK6F6701UF3V5Qt83t4jEwsFe94atQ9K >									
//	        < ULiK87cm72uU6gs749Eaa9288VDgq9uy56gRxwUFgXitPx5bBmL2qrc9LDQ5HPzD >									
//	        < u =="0.000000000000000001" ; [ 000036928574958.000000000000000000 ; 000036936225578.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC1C8897DC28351D >									
//	    < PI_YU_ROMA ; Line_3680 ; 8FQW2irZmv4ACJJCr4atoI37CaL3Gd18pGcXEIY7zn9Iy5qf5 ; 20171122 ; subDT >									
//	        < 6x5ac86y2a9WI0EB87VR14FxVOx45g1gSeI7gE8VB7Rr3M7itto3o542afZl7l3a >									
//	        < qp3VcL1xOd9rooYaHOyR4D856rUz6150q67Y8HuLeP4OOD9sDc4u1hKjfYJbT0Bb >									
//	        < u =="0.000000000000000001" ; [ 000036936225578.000000000000000000 ; 000036950872440.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC28351DDC3E8E8C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3681 à 3690									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3681 ; 634Y30SWV7r97U78s5Q2Dicxt110Qcgtw8wVz8xMAKSpnt8Qr ; 20171122 ; subDT >									
//	        < 3JdZj1mXB60Y65AMwbeEtAxFWT2j1w5uB12OKpFu6aShu7FCl36SKXQhxqw5262t >									
//	        < 064y7KcAsuMAnzNkgL9AUCW0FMIv8DWBTUGoJ51TejdNYC9n8hB5743q7WoK1GNt >									
//	        < u =="0.000000000000000001" ; [ 000036950872440.000000000000000000 ; 000036959527573.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC3E8E8CDC4BC375 >									
//	    < PI_YU_ROMA ; Line_3682 ; 44Z9ZWhJhoQAgYu7Od9B62ve30tFQ6a6liz02TT65Qm7l6V06 ; 20171122 ; subDT >									
//	        < DB8n70tEw4nBsbx8PZWGPonDVE3307eFV6pEZZMUKqBXViP1KI59kdLINyqU1Gy3 >									
//	        < Wj6M791Vv3u43PQ968PcNrqeo7zq2Dn11bHIyDkOqZPjXarP63RmJmv3M8pK8MK3 >									
//	        < u =="0.000000000000000001" ; [ 000036959527573.000000000000000000 ; 000036966353589.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC4BC375DC562DDE >									
//	    < PI_YU_ROMA ; Line_3683 ; f984VUtdg2Gdf19KHa5T1Q071MPJg1bfQS60Y2950124F12hN ; 20171122 ; subDT >									
//	        < ZdD961aS76Gy3o0kitWBy3u0GKCC65iuooB2e0MfwsMCSXV0472xs4Xla4YJEDzr >									
//	        < 88S3GA2baZ8LyGBNaCdg4O20TWHesP5tuY1ViUv7tEzvwmMwt3YF2mfiG24w5393 >									
//	        < u =="0.000000000000000001" ; [ 000036966353589.000000000000000000 ; 000036980735109.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC562DDEDC6C1FA6 >									
//	    < PI_YU_ROMA ; Line_3684 ; y3o2Yc8h9AK1ByZFHbAE3MXOkT635RtHJel7Hvnn18ssOzD0d ; 20171122 ; subDT >									
//	        < NsBr215c82sJ0nMUtgbheobJL8KQGHCc79F92133A5Hl5E03sD4Ytql3cc99ZvvO >									
//	        < E5sNfB1T05ZU5g4a1y43e4AJfYMoZK8685b59hJr4a951L33PQ3t219N8FbVfFer >									
//	        < u =="0.000000000000000001" ; [ 000036980735109.000000000000000000 ; 000036989142324.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC6C1FA6DC78F3B8 >									
//	    < PI_YU_ROMA ; Line_3685 ; XN1Ry0CmY0o0YfzBPH0abZt4233kbuG7zmmsDT58umG11OtjC ; 20171122 ; subDT >									
//	        < 6WmTXSuys2xZUHOM3g3BFJFADQ89a6wccX6RCVjHw2Ye0G1sr6N8Bj8rWyKGE87u >									
//	        < Q2snC6x94RcXSFv7K1B7p7l52cAqyFMYaiceZ98d1pr3a4zH0caDuo50Ej11p4GA >									
//	        < u =="0.000000000000000001" ; [ 000036989142324.000000000000000000 ; 000036998315365.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC78F3B8DC86F2F0 >									
//	    < PI_YU_ROMA ; Line_3686 ; g8ng9J1wJuUsUTQ92Ryjlj3A21SBI1ZTmp94evuUKAzSV5Lqb ; 20171122 ; subDT >									
//	        < T18dd315CKIw311SH01xs2o2D2957Tuc97d80g00S5U1qS70yuq6428c9B660Ij3 >									
//	        < P3y0j2fiEPnLnWThkv9933HPTfu2vfb2n1EAYcXZoP56xJzh909WL6O8Zr0m8M40 >									
//	        < u =="0.000000000000000001" ; [ 000036998315365.000000000000000000 ; 000037008337170.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC86F2F0DC963DB5 >									
//	    < PI_YU_ROMA ; Line_3687 ; jJMD98VDENH64Yx5nSRObihY1w0Cq4lj02ytW9j49gH3FynfB ; 20171122 ; subDT >									
//	        < l548aZurnE9KBf5vU5bhkDu2Anouk269ACftc2h5088JbXR50LXtjhLWA1N773aA >									
//	        < q87680NqZ7wu228tZCKWBhp9xKez53J7ItL4k9Q5C90oRMVMmwisqTl0xl3C4dWz >									
//	        < u =="0.000000000000000001" ; [ 000037008337170.000000000000000000 ; 000037018867032.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC963DB5DCA64EEF >									
//	    < PI_YU_ROMA ; Line_3688 ; rTt0Q0f5KKuqgH48uRDG0s0RJEC9Jp334Gq2NgTkNK2P36gUn ; 20171122 ; subDT >									
//	        < yiOUqr2tu8oYgE99yy6N7r82Fmmp90PPKMC2XR57N9xW5tEQDQ2iU6XgKOzg2Gj6 >									
//	        < KslxMO8KY6rJ0Xtwm13aG7V82k6qIEF55KLRLx3iGy8KNgabb08DV42FF27BE0c8 >									
//	        < u =="0.000000000000000001" ; [ 000037018867032.000000000000000000 ; 000037027234865.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DCA64EEFDCB3139E >									
//	    < PI_YU_ROMA ; Line_3689 ; h9Cb3N7Ar5HBrQfbAB55Rj2LGSgaj2z71846T749y3x5cPd16 ; 20171122 ; subDT >									
//	        < 5cw98699MgPWrO3fW1fBpM76mk3Q6CCU6BP44e857bZY3b22O689OT4i6e9vmMyx >									
//	        < DXcp7EF21PAu6454hj5jjvt3489EH307msSRDNpgZB4e30naz9cc2f6QB88jiM79 >									
//	        < u =="0.000000000000000001" ; [ 000037027234865.000000000000000000 ; 000037041743706.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DCB3139EDCC93722 >									
//	    < PI_YU_ROMA ; Line_3690 ; ipU8I79ez4F18uXNDbwvlWbdO3w8A50h10MFvQ9rZB8XVyfIF ; 20171122 ; subDT >									
//	        < vqqZsr70oYyQPIQDk2GKTW6VL518c56R9z7yh0Ga9tYwJSCuPjuw00678zE2pn58 >									
//	        < tvTgH6ZDos05OL152UokMQ5jy72Fsxb33j36kD5n3EUi3pmK4niHo5u1e0csL9B5 >									
//	        < u =="0.000000000000000001" ; [ 000037041743706.000000000000000000 ; 000037053708510.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DCC93722DCDB78E3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3691 à 3700									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3691 ; 9XdBocU68yK1Z77rw33Wvo0g6nz2a384J4Lde21ZoVR40aZ2i ; 20171122 ; subDT >									
//	        < cYpKx0H2gggP35rTqncKZ5c70K3AE8YQUPVSz3J5k7c7cKUrUykdzC7Oilh14AC8 >									
//	        < 1Dn5FZklc40J5lCF20pgJ78WMW4a04t0KNHvW5gojho88q34SHlO362VXSe3aI0W >									
//	        < u =="0.000000000000000001" ; [ 000037053708510.000000000000000000 ; 000037067618697.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DCDB78E3DCF0B28D >									
//	    < PI_YU_ROMA ; Line_3692 ; GI6qNpiZZO3ddqwxNhP3Vx5QwMf8nFxi2Xm6YnlziA4RzMOe0 ; 20171122 ; subDT >									
//	        < g9X98DfikAQ4oTw0z29JO81JITT2xkzUu224KOlUd8AQbe0Mh3h176e0z93d3685 >									
//	        < uKg3CoRn5g43kxyVtCgnf79C6f5mVO560lNQ8HT7f842JXKr72UeQxgN218ir76R >									
//	        < u =="0.000000000000000001" ; [ 000037067618697.000000000000000000 ; 000037080192215.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DCF0B28DDD03E215 >									
//	    < PI_YU_ROMA ; Line_3693 ; 23qZ02WZs5G7h630TY2yM7X6UHLVXZXcg11CDIEqMwaj608S0 ; 20171122 ; subDT >									
//	        < WhMOkb8PWg1RtqDBBGr4X434jxIKyZPHk7eD02rNt27Aff828Hqd3LpQWUIYpO8Q >									
//	        < 9N09c35Z2wuFdjGJ555ZoPtgbrnc9zwPvjL3X5mj350kPr7Vh98wHJwxLK7s2F7R >									
//	        < u =="0.000000000000000001" ; [ 000037080192215.000000000000000000 ; 000037093838618.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD03E215DD18B4B5 >									
//	    < PI_YU_ROMA ; Line_3694 ; 8X55ZWlux2786mjZ3SbU1w5QG3hLM8RVROtu2Q0O9BDj0QSvV ; 20171122 ; subDT >									
//	        < O1cF8eouqash1mYKy1Gg020tEk83fqqeLWktcTmO9os7Z9l1MVA4A0B4leRpq0Jl >									
//	        < gfVk52qzN7UZ3F3JTE32cRt404T25oYvCIIPB8XfemGqQiPJy5LHWw2lLWwyS9s0 >									
//	        < u =="0.000000000000000001" ; [ 000037093838618.000000000000000000 ; 000037102914292.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD18B4B5DD268DE5 >									
//	    < PI_YU_ROMA ; Line_3695 ; OH67O2IL73rdBYyqJob6i7GEEwV89xwVu38FO1YiS6e7zZ831 ; 20171122 ; subDT >									
//	        < T38q5De53Os96VF44O4khUSR30igO7LCe0Sz3qjk78GB69vd923dG7n4q0d3YJbz >									
//	        < 02FhZsZ4hT4gsHVQe084V198C6KWCQTFucfcrg3zZ26oR3r2k3yG1JnYGbwGO6lg >									
//	        < u =="0.000000000000000001" ; [ 000037102914292.000000000000000000 ; 000037109567086.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD268DE5DD30B4A4 >									
//	    < PI_YU_ROMA ; Line_3696 ; oTIvLymNCd9zx51IG7OoRV17oJ777I4ezN13B22VXd38T2LVD ; 20171122 ; subDT >									
//	        < cYzPk3Z2E1fFDE9WDpTL57rarHXw9qe7L7gPwggOUE3zB3HVorPxjUH1Ep6joGD5 >									
//	        < fO96XIrUOUq9e7yjX6G4672884X5EcXRlZ0e0Wt6mXE5c7Z1lp0IlqqPH3L9TzP1 >									
//	        < u =="0.000000000000000001" ; [ 000037109567086.000000000000000000 ; 000037119086424.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD30B4A4DD3F3B22 >									
//	    < PI_YU_ROMA ; Line_3697 ; 4X0RAVa4ZS1xC9Wx7NBCOZik5BrTu6x5Fer69Tx1JRD001RH9 ; 20171122 ; subDT >									
//	        < n03990Q616puqL0x8qG6bnTrE3a4A1nrKwSVkAd6wMk31u1wkGdKsj96DfGD5rx9 >									
//	        < 39fw6BwFR4Hi19CkGq5y5dE2o49g5yizsPQO77TO440h5Y7gjSY63cq069zXd63L >									
//	        < u =="0.000000000000000001" ; [ 000037119086424.000000000000000000 ; 000037128279125.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD3F3B22DD4D4208 >									
//	    < PI_YU_ROMA ; Line_3698 ; 37nM6502HXv4PaQRC2wkx9dv30B83dA939C6zD87ylytG3DpT ; 20171122 ; subDT >									
//	        < mb6i774F4FSg318YMmNpyw503NWn6Xf635S01M7Rey78GjM10kh84bedqSaKK46M >									
//	        < zRl640y240l0h76Sqk1Fw2Q390ja9aa6k5WfYfOQpCJpIvD3iFdIxRGb3ZyPuuhL >									
//	        < u =="0.000000000000000001" ; [ 000037128279125.000000000000000000 ; 000037139432004.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD4D4208DD5E46A0 >									
//	    < PI_YU_ROMA ; Line_3699 ; 1N7Gi85O9gJkOYIN65Tf0w76268Qy8qQN0Za0IzJB4733G3bA ; 20171122 ; subDT >									
//	        < 2h42UD8w0mD7oKtSOR0jEuyp5nfhfyq02995Nhbw8zh8j1v816PPpwWHi533pkOg >									
//	        < z15cV31qc27dWxIrlW7w4JxK3NqI7iIQX654DfX3Xc0f2A9Zd9c2G1GI813Cj9cQ >									
//	        < u =="0.000000000000000001" ; [ 000037139432004.000000000000000000 ; 000037154133776.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD5E46A0DD74B581 >									
//	    < PI_YU_ROMA ; Line_3700 ; r6lypNVRAuB5afM8vLMqtHsu98h5kd8m5Wy1c72Q6r2C8pkDZ ; 20171122 ; subDT >									
//	        < Z1CHGzw29gA7N00Z324fXBnSRW273yZ6FAFJcaj3bRM606pB3XF94IRy62cWXF4B >									
//	        < YCivlbC87OPL07Wz8hOn0100IzBicuTwvvYH9V7yi497wc4b3f5EkF021AUKv29T >									
//	        < u =="0.000000000000000001" ; [ 000037154133776.000000000000000000 ; 000037160436177.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD74B581DD7E5361 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3701 à 3710									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3701 ; 2O6SHW8cte597nau93n26S2Dzk0iACwRVk4j18rRd1TF8rv9I ; 20171122 ; subDT >									
//	        < zS8wGVAmPRAWfMk8vxcN3NDpAp8B88HW81M3ZZ2AS353Jw1goG8IbtoBTQg4Q8Yx >									
//	        < oKfJamUnd8SJRUak6Sc42qDaQ5JK2Oebb4H6p1xe9fg1gLIh9BsPUy8Hl14132kd >									
//	        < u =="0.000000000000000001" ; [ 000037160436177.000000000000000000 ; 000037169204295.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD7E5361DD8BB46D >									
//	    < PI_YU_ROMA ; Line_3702 ; cC7ai692M9FQ2O7aQ2205LB5klK1Y39Kbwgs35yQ0YFppb11h ; 20171122 ; subDT >									
//	        < yq4PYO0108R20UWJFXd354HSBJHXi7195wz98MTQG7tgo8wm5yySb3q840985i0W >									
//	        < Uj1J939l9QiOWq6G896431Dddtwpa78V7LcCm2KmGgE0BzyHU1eQW47hVNfIavGE >									
//	        < u =="0.000000000000000001" ; [ 000037169204295.000000000000000000 ; 000037180453360.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD8BB46DDD9CDE98 >									
//	    < PI_YU_ROMA ; Line_3703 ; ylh7wA1YqhfWAt4dT4MYNjd0Rnu4o2pHGGSftQu9b90ImY9QS ; 20171122 ; subDT >									
//	        < DN5FvZRm0Lwva59XWETJZD3R8ZB9lzy5l17Yd7EsjC28sdtkv112N316flfuJ2M5 >									
//	        < V570Gh2bjO139502tSvIEXtJAv3n1wFF3SP8acJn41eZVUj1qwlQ1W1WUTx5WcX0 >									
//	        < u =="0.000000000000000001" ; [ 000037180453360.000000000000000000 ; 000037188177536.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD9CDE98DDA8A7D9 >									
//	    < PI_YU_ROMA ; Line_3704 ; u9skVx7jgT8u96up4U6f5C24bc223g5x7AJtecNQFXaeB18gH ; 20171122 ; subDT >									
//	        < Wd7r03ii4KD956oN7ZK14sfm0t03ng7534hm5zI6jUMdWE4Bo7u65xA1J6t8zK0p >									
//	        < 5Ex3lp7Re6EcJ5OW3Tf48bYMtZZm625C83ctfF1Mo5JEQBQIH9678W2NH6Rnj0ro >									
//	        < u =="0.000000000000000001" ; [ 000037188177536.000000000000000000 ; 000037200094547.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DDA8A7D9DDBAD6EE >									
//	    < PI_YU_ROMA ; Line_3705 ; d39MIb1Ug9mMGtwaf8m0Xw44MlgzCa4M7i2qG2nHxfTtX55M6 ; 20171122 ; subDT >									
//	        < ysH71cvM1O65PwXGwyC0523VL3bSx2a64kJ97DnfEcjdi4ej5x4J1CwZZ8UiTQ83 >									
//	        < On7J4xBBRJ4fkfg4khEjSVfgiD2FH2ahq9ZzFPZsA2WGYw08W8L3jf47ab7D8K6u >									
//	        < u =="0.000000000000000001" ; [ 000037200094547.000000000000000000 ; 000037207968152.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DDBAD6EEDDC6DA8F >									
//	    < PI_YU_ROMA ; Line_3706 ; f68Pxkx28jC8x45igXX2YrW86Xn3MJzyX00abEacA8fgV0q6h ; 20171122 ; subDT >									
//	        < WA1zSfuLB1ESE59ydIsgtwlgwIw51rZEV94wjS6f1W1M265F6pNvik6SraW0Ci89 >									
//	        < bqh8sWw72iu1h2875287E9v9aKz0iHm3Fj8G0z3k5oVcz84vY6f9La1Mq3Al0kUT >									
//	        < u =="0.000000000000000001" ; [ 000037207968152.000000000000000000 ; 000037220411729.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DDC6DA8FDDD9D754 >									
//	    < PI_YU_ROMA ; Line_3707 ; Wi9OS3IJ499wq8351aPaX59Df63aBKf842yZ0OOdnbMO5w75n ; 20171122 ; subDT >									
//	        < BpflM5wz45M35lPfEbbTiiB21q9557G2cD94miDOS3s5NG4gtfO6PtZPAkZq9X8E >									
//	        < 4WO0zQUT1iZWd77noR57798wF6OZ2sxh982A6Chb8j8t8nJ1LfK3KTuoo74kGL4R >									
//	        < u =="0.000000000000000001" ; [ 000037220411729.000000000000000000 ; 000037227843391.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DDD9D754DDE52E53 >									
//	    < PI_YU_ROMA ; Line_3708 ; sj8dhVkHm9J6KFVxX5vs8gPLQt5o4YwcxxAaK4pv539k3rVfa ; 20171122 ; subDT >									
//	        < ln5hDNveu397lc35l20HeqAVq0s7U0yvb99Wt2jSIiHB3a4aZnIF11vjvnuA9uG3 >									
//	        < p155b7vdrXn9weoEUr9QJ3x3OAEjW0YPy8NGQbF0B9k1fRV5qUqTCg8EKcWI93t7 >									
//	        < u =="0.000000000000000001" ; [ 000037227843391.000000000000000000 ; 000037233843664.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DDE52E53DDEE562E >									
//	    < PI_YU_ROMA ; Line_3709 ; 9vV0HCT4v84EDSj40yK022V43j3PduhyJ5bJYr5fM0teGkl8u ; 20171122 ; subDT >									
//	        < Ee97KrQv0Ch2DWe4ye2s2vsZF4wS9RaVwQa5MH1vXdgqo1e79215bSPoMR81Q5Uy >									
//	        < 18fsvm05GDM80QcGp5Extcha6B0Hnz14sy70rSs4fesN5Y9MpDfg3F8F0kc8K4UP >									
//	        < u =="0.000000000000000001" ; [ 000037233843664.000000000000000000 ; 000037245955365.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DDEE562EDE00D150 >									
//	    < PI_YU_ROMA ; Line_3710 ; Y90GQ9x910X1lEss9w0hHo7Ch0Nagm1vZ841311Z5H74Gjr9t ; 20171122 ; subDT >									
//	        < S88OM1LZFCbCh04M01r6xMu4P5a2243fQ68pj67Gm4vLlL0qk0VJK4n4cxcJ9ST2 >									
//	        < gieSbzK48vZe5sr5MoUVha86E4MRNz1488MkUe6Z0T3lv2XWfb622BD61egIeFV3 >									
//	        < u =="0.000000000000000001" ; [ 000037245955365.000000000000000000 ; 000037253148789.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE00D150DE0BCB3E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3711 à 3720									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3711 ; 3q783OgQ7jLMBt5R63VMJ57Y1omOKa5v22Qujxioa7K9gQLSm ; 20171122 ; subDT >									
//	        < m48QBAc7wUkTvMeKMXu33J3owk9EpG3Td7lkSVv10T7UyCebO4S13i7XUWXg59q6 >									
//	        < jjX5Sx32NR8T0pznh9ajLGZntYAUxSNH1K18tVp8gF43Jq9pAKJ10b9jw3GPQN47 >									
//	        < u =="0.000000000000000001" ; [ 000037253148789.000000000000000000 ; 000037260829551.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE0BCB3EDE17838B >									
//	    < PI_YU_ROMA ; Line_3712 ; hq4vp95jqulJifz3W18h80Y8jCMiGI99T9Vmzny742KLFP21L ; 20171122 ; subDT >									
//	        < 26ewej71f68KZ6of9lm9N0gx467KB4rnHi6GBmLW87FPwV51OqB6oY02LOM02e2b >									
//	        < 5rAfU94fK57hGje6cPQnG1qlsk9S39kKDl77YTbM7Dadnb8PICXsPf8DpqxVnG8l >									
//	        < u =="0.000000000000000001" ; [ 000037260829551.000000000000000000 ; 000037266654409.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE17838BDE2066E0 >									
//	    < PI_YU_ROMA ; Line_3713 ; 2BH80d75nbnAqx9pd80A4N59Qv2I5989MafJ2T96Cng4fVGRX ; 20171122 ; subDT >									
//	        < 3v9os9jlgc4061LM5gqAF5gs97dRDnBRn8Y2572nTL0TrOw26eKUImfrp2s08q1X >									
//	        < n12PdJKE2XC405R5cne8bn16eE1cg0fdR8PCz91Jr54atQtQ01akDvo7a8z06L04 >									
//	        < u =="0.000000000000000001" ; [ 000037266654409.000000000000000000 ; 000037280941467.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE2066E0DE3633C2 >									
//	    < PI_YU_ROMA ; Line_3714 ; afO0gQ5OmSqlBD1CJWHG2Vg38Gn6L2my7VM71yef292J7tyGx ; 20171122 ; subDT >									
//	        < b3C9HCZ740J40sGZ4n9QeK1l3sgkA2g0NBA4R8Py9fSt5TMji7dc6dEzJt9irCWk >									
//	        < JQ4E4bBsD3Av3D96OSCgyyze780H31CpMZyvMXdO0Dwqk7Be8Z1cBV21gI5imcnR >									
//	        < u =="0.000000000000000001" ; [ 000037280941467.000000000000000000 ; 000037291207330.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE3633C2DE45DDDD >									
//	    < PI_YU_ROMA ; Line_3715 ; ZZgX4Fy6dhh48pL9gM9n6CjdQ39Ll7SH17uv8hKE9do1j64P2 ; 20171122 ; subDT >									
//	        < UtU7SoIvk485aZdzGAWkdU6QSh07P75s5uFpluXE1kDwo6I8G9o1Ppq7269ub3m4 >									
//	        < D7jWp5yD9ikNCNhTGH0C021d48gHRYG3qT66aFaeuyjivmO916gsADmy0B2YWTRM >									
//	        < u =="0.000000000000000001" ; [ 000037291207330.000000000000000000 ; 000037305756359.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE45DDDDDE5C1113 >									
//	    < PI_YU_ROMA ; Line_3716 ; J0P5T5WsX5nx5o083I6wGskA4dq1zOw5SH9XCRw5gX87F7xk0 ; 20171122 ; subDT >									
//	        < Hk45IN32q0hOVXKq7sR2I9SKQB455rn0EprE28y8Yr420VhB9HseeU3chIYqB26E >									
//	        < dN97M29oWS6O91tXN5kx4rRM1Sht63ng575Z59YVA9t1pLg1Zhz7tC1FxD8Xa4S5 >									
//	        < u =="0.000000000000000001" ; [ 000037305756359.000000000000000000 ; 000037315198947.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE5C1113DE6A7996 >									
//	    < PI_YU_ROMA ; Line_3717 ; NQF8TO8I41z9WaM348uj49TF5em39n3AoidvTtCJfaA467ZJJ ; 20171122 ; subDT >									
//	        < tb65TuDMGETQ8VbN25i2Bu51vTZk3wM8K6U0144tx2JwwRrUqT6gJ89NCEYp8m3w >									
//	        < wjlJK4nM2dhUeXMN345f07jrK0Q9u1QlmqkZKiA4bqc7swtmT9mXIkaKAuLmDDJ5 >									
//	        < u =="0.000000000000000001" ; [ 000037315198947.000000000000000000 ; 000037326554092.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE6A7996DE7BCD31 >									
//	    < PI_YU_ROMA ; Line_3718 ; z927EU2QrJCS67W4BKPF9u5E0WNvO6G0bf07ybvQxI39A1PYH ; 20171122 ; subDT >									
//	        < vurj10sv1Z3QnSgr633tqmFwOi7n5Y3W589QAtfOB00u4r3U2Un6yJ7W9ReiFk5z >									
//	        < 1Sa0Og6R5B58LZBwWAZLxSJctSU9UG17U544ly0Ez751eIqa2BfwfiD461Er9bYs >									
//	        < u =="0.000000000000000001" ; [ 000037326554092.000000000000000000 ; 000037332703992.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE7BCD31DE852F7F >									
//	    < PI_YU_ROMA ; Line_3719 ; IVjDg183yJ9EEfEA81Kp4jQqRowX5h6rBwfowwt21HWH18OpT ; 20171122 ; subDT >									
//	        < 32d59NX46Z07S8TyLJCBci0u037EZZ0FD0d79HHr66hOzDQkuL732eYT7PVCsR47 >									
//	        < M989TcV8pasgVh19Pn62KAonI36N12X0vPJbg4WV3701Jp044G6qht6Adl4xXU5h >									
//	        < u =="0.000000000000000001" ; [ 000037332703992.000000000000000000 ; 000037337951587.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE852F7FDE8D3156 >									
//	    < PI_YU_ROMA ; Line_3720 ; jezMe91oa3gf613yZ14ysTTp4gO78xKne7V6A7f98d0M9Comm ; 20171122 ; subDT >									
//	        < httn466tnHf6bBWPGvML3fk4PTHX89mqTuy1kKb97779wLNCct2RxYx5p7X0o18W >									
//	        < mT4Ag22Y62x4fTz1v45uqXvK5s8OwQn8I18lNjn9k06a4fEZ902CY9Vfn6v89Q8o >									
//	        < u =="0.000000000000000001" ; [ 000037337951587.000000000000000000 ; 000037344937462.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE8D3156DE97DA32 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3721 à 3730									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3721 ; e0f6Y62n8s4B9N6w76H5Pvw6OkFNoL699A159LcaOmNt0izB3 ; 20171122 ; subDT >									
//	        < r1SPdygYk0Kdld5Uj9U6M4X6tpusRdIft29uoh5ueMG4f8lG0pVInw68yHVA25Gi >									
//	        < 5vR19lqX1GIa1kMmkf4AjSXZ44OVdIis58jGhom2h0i4UEZAe3DioP346k4fZVbH >									
//	        < u =="0.000000000000000001" ; [ 000037344937462.000000000000000000 ; 000037357240576.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE97DA32DEAAA019 >									
//	    < PI_YU_ROMA ; Line_3722 ; KxpbmkNySDeY7E6TkhK5dqI3G0rQFat861j4t0t9sHqseyrLQ ; 20171122 ; subDT >									
//	        < D8x8VvBKKv9943pEKphjKUW6NFF6M2ZHmOvdr7KB3EgjGLOp45133QOrNUH4O8M2 >									
//	        < 65a2H7lDTRjWEDbXy266v0idn20803ul39Zg9W4Vh6zNa73C7td8BpFtd55Ul5vr >									
//	        < u =="0.000000000000000001" ; [ 000037357240576.000000000000000000 ; 000037368462617.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DEAAA019DEBBBFB5 >									
//	    < PI_YU_ROMA ; Line_3723 ; 752XaxTJJN11a4SM18auQ6222o9GK3yU6la8P5yeCgY27ER30 ; 20171122 ; subDT >									
//	        < lqKw3VEf7S9W9gJKIhUkWvsL0Oa3IzT07N6nsLMutRXy7dnW4ew4eTw95l6M1bWA >									
//	        < IRa192HR51Hs8irGCH7nALmL80v2N7FQcwME87jbob2E55EX24KgI59Ty9Btlk3w >									
//	        < u =="0.000000000000000001" ; [ 000037368462617.000000000000000000 ; 000037374010593.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DEBBBFB5DEC436E3 >									
//	    < PI_YU_ROMA ; Line_3724 ; o1hn2ZK6pw67Z0DC36U2nhYOOZGo2gxggOZUlo6Swg7ViwH1g ; 20171122 ; subDT >									
//	        < 3J58Ht2qopR0Ju26JpsxP98rHyIm3l5vC5a0q5xhyvvB8967430EP63i8Ism42n7 >									
//	        < OCffTU6Fkqg68I9upBnJpx778Ln83pz6KO8g22Pt98aRThO2R9f4gZT2BIRdfTr7 >									
//	        < u =="0.000000000000000001" ; [ 000037374010593.000000000000000000 ; 000037380067283.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DEC436E3DECD74C8 >									
//	    < PI_YU_ROMA ; Line_3725 ; 1yh3rc13KqeUqId8w39FojGnb0i4Pwy8BRwI8etACr07K48q3 ; 20171122 ; subDT >									
//	        < jF8z7m9ktog4r98NM3i7407IUEqN6695Ap3340hz76o6H9U2p3Vpur5pciNcb5oh >									
//	        < 18z5UwJiG9456sbRC8R1x0b59cwR7F1j6b9Z839mzmXIhpePNpCn09b4EP5aPBsa >									
//	        < u =="0.000000000000000001" ; [ 000037380067283.000000000000000000 ; 000037392620512.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DECD74C8DEE09C63 >									
//	    < PI_YU_ROMA ; Line_3726 ; 48jBhGMM0STvov28NRXI5SOH69VfDmJRL2Uu826A8bGayM3IC ; 20171122 ; subDT >									
//	        < my23tQi0Lm2zhnTPDrLiUDy07h8LWpsOZl3c04lpUm90Jl9a9gS97ePXV8VsCleN >									
//	        < m8DPvgvz83dr4k3TC55fhCQFt09g3NT0Dq1lrRG0RJqM4jxUs5UacYX3ydHj2E9T >									
//	        < u =="0.000000000000000001" ; [ 000037392620512.000000000000000000 ; 000037399527615.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DEE09C63DEEB2679 >									
//	    < PI_YU_ROMA ; Line_3727 ; IT9bDre2u997kl8c3mXsGK91rilo92TO6KUpCV0lMFAPy2GLb ; 20171122 ; subDT >									
//	        < v69jJ13SCS9zj76NTEp2dO0jxW4DpPGR4naRHxeaT63sOdyr5jmPBIP66yjTmNi9 >									
//	        < YrL8KG9r4yaB9oih8t0LevV9DR1jDh54suAuJZa627tUzygWIuC11O1VmR5QY0r0 >									
//	        < u =="0.000000000000000001" ; [ 000037399527615.000000000000000000 ; 000037412369802.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DEEB2679DEFEBEF4 >									
//	    < PI_YU_ROMA ; Line_3728 ; ZH0duhw9q2DOfvAnz5Y1ke7k04w4f38faOnHU80qDjVHb27P5 ; 20171122 ; subDT >									
//	        < T5Ifn8sTt505sJ9RLrfR2d2xp19fQsx4pN0201Gq1F4nUkQ429t9fiD6oT3h6bNo >									
//	        < O9ObN3U08ob1e3jM8TRHerGBIqm2lNGLD2889axIGWE8UtR8RUwjQf6n9nt2uvv5 >									
//	        < u =="0.000000000000000001" ; [ 000037412369802.000000000000000000 ; 000037420646747.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DEFEBEF4DF0B6022 >									
//	    < PI_YU_ROMA ; Line_3729 ; h8aCuJNsV0f4VkepzPAOZ0NxY4id657Q28C17E5KAtOMCQ31b ; 20171122 ; subDT >									
//	        < M2m3pp7xt88MhQc8ndjk1EO7faB8wJAIo9x5ka0gLCIpY3mPB9BWAJSK61Y8FD3R >									
//	        < kSxkPxwCmN9atoe2T4aHLM5a5E9us8mnUqWYLo1rh9aN9M86mR6BWH1T7h2MD6Uw >									
//	        < u =="0.000000000000000001" ; [ 000037420646747.000000000000000000 ; 000037427311446.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF0B6022DF158B88 >									
//	    < PI_YU_ROMA ; Line_3730 ; q0pM1FytpYoM934ZMJFZQlVusj52TMxr2l17EbSzyYlz9ausy ; 20171122 ; subDT >									
//	        < gjg7QQXrY83957VEmtJk00Lr0OaMnl8lF7Or9n93yv3s3UCw869d5kH7fQITEpYb >									
//	        < 59d7q7iLU07j7PAM22fC3gpqnWmmsNqT8128H0mfD2Qk7GX9SbBzPWu1GGeBD700 >									
//	        < u =="0.000000000000000001" ; [ 000037427311446.000000000000000000 ; 000037437100374.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF158B88DF247B55 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3731 à 3740									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3731 ; beNZ9HH3Rt2I4fp2R85skXl0KcRhv363e9f25y1kNTYf6T7n1 ; 20171122 ; subDT >									
//	        < 8gH0KoSeB9ld8l1ewo0Ysu0mK4o40Qd081c1w59q22p0E2CqM7n26XEzjY942nc9 >									
//	        < 1c7SeugDWtclckJI99wt079h3q6C3H4hy0bsxsl2836fR19jy02FU4R8g5QPZis5 >									
//	        < u =="0.000000000000000001" ; [ 000037437100374.000000000000000000 ; 000037446725565.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF247B55DF332B2C >									
//	    < PI_YU_ROMA ; Line_3732 ; S5q6iDIrHVDn3443yLpA1v2EqduD9Pxr857j9L0839fU2QKJN ; 20171122 ; subDT >									
//	        < g9FQaQEe77mHu9ur6dEHpxK1f8CO5x1hAR4858RAJRS30OFS28zreoTM3EdLKJrR >									
//	        < 0468B3FqAiJC42Q486cV8ro60d052Yz666km5c11064yBA5kct82Wb53BztYSXhA >									
//	        < u =="0.000000000000000001" ; [ 000037446725565.000000000000000000 ; 000037455155327.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF332B2CDF40080C >									
//	    < PI_YU_ROMA ; Line_3733 ; KvnsW6Pg31eSc9OYZlpDM0GZeyKlg64ITeCG72FwWlFsW8E00 ; 20171122 ; subDT >									
//	        < 4VO9IaU6Hl1XqvA9BurxCrt2RbPayJZk2cR81Z90MW66T3T8F1T1G81ZqYcMn50o >									
//	        < QPVNzaEGtiTUNBezuY1lTl30UCE5jZrxHmJ0Omjn3ULi9w0VOirAb521xo5C431f >									
//	        < u =="0.000000000000000001" ; [ 000037455155327.000000000000000000 ; 000037469726979.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF40080CDF564419 >									
//	    < PI_YU_ROMA ; Line_3734 ; 0k2ABPQJw4H62UhAzp5gmS7mIDFLP6n4zd5e5ChI57DC4tO2s ; 20171122 ; subDT >									
//	        < dq45xotQyXY2U5bBogmNow532t4xw860XIgkrCR47pPnjk57APWGp79M79H9nFAN >									
//	        < 8T8NEz9JR9jx11mu2F09E72y0698554ciI348A74BYfcO2QS974RX2q84q2wmXJd >									
//	        < u =="0.000000000000000001" ; [ 000037469726979.000000000000000000 ; 000037477856541.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF564419DF62ABB6 >									
//	    < PI_YU_ROMA ; Line_3735 ; HeP3COwiMFOAGb68p30AfXk4Zf81h7arb7lg99E0acoPSMQ75 ; 20171122 ; subDT >									
//	        < 8UGKDU2eCY90dl10VLMrE39PIBW7o3LTr5SiK3kOIMIl7gOQ2pJ6j00g0Ip0eIF2 >									
//	        < Rsxy1Dvdb2D7aTs0zzs214I52TRzAE88oiE85z8BO8LUIOM804uEBa2l99xE7wHb >									
//	        < u =="0.000000000000000001" ; [ 000037477856541.000000000000000000 ; 000037492571937.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF62ABB6DF791FE9 >									
//	    < PI_YU_ROMA ; Line_3736 ; B826CNObstk9iNm2TDG71X13QXz53f7NnM3q1G49GM395EjY4 ; 20171122 ; subDT >									
//	        < Pi0etear5e80WP98r198mIH5bdnK5nuzi0kN6mra5Z0Ui8IoVXo49645Z5HHJOP9 >									
//	        < 1eAn4qEkR96ZNW4ETq99282WW72RL6wUO44Ih3Ea2fr6VqCbS4hF7EkbMGOBx3cl >									
//	        < u =="0.000000000000000001" ; [ 000037492571937.000000000000000000 ; 000037502260263.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF791FE9DF87E86A >									
//	    < PI_YU_ROMA ; Line_3737 ; 1L2ts40cEzI0deNp3DItz8CLevg16OE2DzneCJi26rn05K7lg ; 20171122 ; subDT >									
//	        < H3omYWSX3B9Q00idDc5VvqiR30s79xLAhY1cY0buwZ84d4Ne18kKfGJP6Gt7MN60 >									
//	        < tK3f6Y75t4LQg27vl7RzU60V6n4ut45eW65v36CaK82rZJqGi22Y819n38W4Tz5u >									
//	        < u =="0.000000000000000001" ; [ 000037502260263.000000000000000000 ; 000037516244301.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF87E86ADF9D3EEE >									
//	    < PI_YU_ROMA ; Line_3738 ; h4zmw03KFjZW9e8Pbag077p8Z74O33qdumlQH4f95iPyiVUUH ; 20171122 ; subDT >									
//	        < 3z9A72y3L479IVqsypORIzjf1HAqoMMZagrGEiu3o9EF947R7nyvO1G4aIvd2Gy5 >									
//	        < vQiDytAd00bqLL3qfb9DaVaq8VjAwPi8wQNp98oyX7Y3K4Kzbpkb40EObDLcJzus >									
//	        < u =="0.000000000000000001" ; [ 000037516244301.000000000000000000 ; 000037522431835.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF9D3EEEDFA6AFEF >									
//	    < PI_YU_ROMA ; Line_3739 ; 7TT6TXXXKQp3SoMfa8E86xH6QGlJ49T4OuEylStF33dT6yfFC ; 20171122 ; subDT >									
//	        < 5Y47U4sF6Y6a5kL16276fr7fJmiSaqL6HXid7j57j96vVwluRClfO2MzJ5I28iOy >									
//	        < 5Aockh0yRqIpEYqNM8v9h3sxY7l6H3TfgnyWKNzn6Z88s50AfK7b8SJriAHPV7m2 >									
//	        < u =="0.000000000000000001" ; [ 000037522431835.000000000000000000 ; 000037531022711.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DFA6AFEFDFB3CBBF >									
//	    < PI_YU_ROMA ; Line_3740 ; 0Z7u8iUhW4hBViMYQ6I19e8HGn7Fw8Upu2AR01PH8dW6f5NTq ; 20171122 ; subDT >									
//	        < I3VSIDi55b4d8mVY5Ihth44WYg5DK4Na3Oft74zRWrd506dB77SA5cSfH44NoT1Y >									
//	        < naIBLf3gLTT6wUp3XVH7XoqiH74QLeCxBHwwd78ewdvRk49z3Nq93P8AA2M6a5pw >									
//	        < u =="0.000000000000000001" ; [ 000037531022711.000000000000000000 ; 000037537727621.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DFB3CBBFDFBE06DA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3741 à 3750									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3741 ; bM2tjQjwJLjGc3f909SUwGc4Z2mO9nHdDDOi4Nim24ABkn0wC ; 20171122 ; subDT >									
//	        < RxQ3y2RHP19h0sPzOLc8rq09vMHZ1lG3o4fGHc27rDPNQDRGrv29LEkf0vdOzNXk >									
//	        < dy8HM4m4J1LcX8Jj338IbL6K4S0ipSjXYP9c7Ceu4zYOJ660LqdY4udAJs34E0Ei >									
//	        < u =="0.000000000000000001" ; [ 000037537727621.000000000000000000 ; 000037550396466.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DFBE06DADFD15B9E >									
//	    < PI_YU_ROMA ; Line_3742 ; 8X2z29qj56O0AIIT6S0YJk80q0SIET9LUkXcaAgH66osr0w4W ; 20171122 ; subDT >									
//	        < 0d9tv754JOk5LKFL4sHl3qPSqu62l6pVMN0X4468JPXpVRtJodE8XsXJMsvbB037 >									
//	        < F2rEP4l7613lhPKmf6Sl4q0A1xh5P7yj0WdPYMDa7jj40C6QiJhr5C4S0UC66SHi >									
//	        < u =="0.000000000000000001" ; [ 000037550396466.000000000000000000 ; 000037560830539.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DFD15B9EDFE1476D >									
//	    < PI_YU_ROMA ; Line_3743 ; YR6P80moDrqHATPV7SdWTk5u2lV98g6i06LZda97jgNIel12y ; 20171122 ; subDT >									
//	        < p3c55wp6o1W03pkhcM2eUz5Xo4iXCz6AUMt88bia7N6HrJtAU4G9ef6DRxLE315Y >									
//	        < EuKJzLO8V4N4wzCNWD73r3C9QCqwJH8Y4c3t3341X8A3tG29CKqT3VKTorzWC5u6 >									
//	        < u =="0.000000000000000001" ; [ 000037560830539.000000000000000000 ; 000037566014920.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DFE1476DDFE93094 >									
//	    < PI_YU_ROMA ; Line_3744 ; ADuHTZs0831oCF8xt3om6286i849nH9RfdANPV1qZmr9RUP8j ; 20171122 ; subDT >									
//	        < 9W1988ELJ32h57iTv964H2DIanpgy5eqOLA2ZCgHQg9e2E7db7EBZKvVA6rJ8pKf >									
//	        < 63eoa4IeQR7192R16y0o0yPey0CDAP4fsf4ibt8o6iPiM60Ph189575Rh39zi13e >									
//	        < u =="0.000000000000000001" ; [ 000037566014920.000000000000000000 ; 000037571257022.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DFE93094DFF13046 >									
//	    < PI_YU_ROMA ; Line_3745 ; AaAxbC180AmKz738NBoZKG115IrbL1s0EKmx2lj78MH6g2Y9a ; 20171122 ; subDT >									
//	        < hZXPhx9I1r3es7Q9R4XfAs2HqmRXSx11468ykxV19dNiMnYiga2C1K596ZkoQWo4 >									
//	        < awO0wR7vn4He3CYRFcqmpUF37j1S0c1elAxT2tn8HS4Yxqb0tLM0623Oy25RER85 >									
//	        < u =="0.000000000000000001" ; [ 000037571257022.000000000000000000 ; 000037582268638.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DFF13046E001FDAF >									
//	    < PI_YU_ROMA ; Line_3746 ; 2WDEL4BllDuRvWHg7MS24bESzZcM51m2YBytw9qvLXXaniNZ2 ; 20171122 ; subDT >									
//	        < 12gD3pc21T5ChiXPCr7KP8A61RZPTrDLML065h9Vz00lukIuhK61ir099uXt4ySu >									
//	        < v89n446bWne494D7I4C7N6D828Y1jwNI0J369v7e1qpG0056zoDiZa7473yT6kZ6 >									
//	        < u =="0.000000000000000001" ; [ 000037582268638.000000000000000000 ; 000037591064112.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E001FDAFE00F696B >									
//	    < PI_YU_ROMA ; Line_3747 ; 2DQfXKJYfyr5c7vQKKe45613ksJSfX2d7TD4DT5v6Rz7RdAZ2 ; 20171122 ; subDT >									
//	        < JgAs67r55wOW6Tl6ObaVSu0UBas49JZjhZj526qwi1ukAgN9n6FuQn4K0ymQM9D0 >									
//	        < 6hp7029FdwA084Na5PH1UhL2i4UIlC76s0yQXWy2FEJ9208qK5VWbntR4BH0V7VS >									
//	        < u =="0.000000000000000001" ; [ 000037591064112.000000000000000000 ; 000037597583927.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E00F696BE0195C38 >									
//	    < PI_YU_ROMA ; Line_3748 ; H36tbbSQMdD8z5PWHp3bFNePVt1Vkw0oJJ2vc980IewL5ThfK ; 20171122 ; subDT >									
//	        < tZ2C04U73WsEzLnGjwt3jEX38fUR65SNJLkUV7JuFXrYWOvqN7VZv5MuQ9XcG63P >									
//	        < C6wlX5KGe1Pw12jI3o4kB1UaPel9ol3YtHNN7ZGoA22BBrI6IiNhjF7tA94Gt322 >									
//	        < u =="0.000000000000000001" ; [ 000037597583927.000000000000000000 ; 000037605586491.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0195C38E0259239 >									
//	    < PI_YU_ROMA ; Line_3749 ; 5QuWvb2ktUq678GOByA7Vo3q85zje1696o4EOB1GQAgixEReq ; 20171122 ; subDT >									
//	        < JF4J2iWTn95ndugsCjoihVhILHnT092rG4Ov577mk040O0umWgHDY8vO9Gd4XpG7 >									
//	        < v8x2wi0XJXVBM089xk2YS9IbP6hLwG272l0WxC4393Za4oH6Y7q80d3vpdbOc6Ce >									
//	        < u =="0.000000000000000001" ; [ 000037605586491.000000000000000000 ; 000037611797601.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0259239E02F0C70 >									
//	    < PI_YU_ROMA ; Line_3750 ; s1E9i203Ss062p8s3p7HZ5urO40Q58A89079vyLQItaKi378O ; 20171122 ; subDT >									
//	        < 27873409ZD0RmdFi0JLg303M57kzKk7H36ax17781d25teOOR027f4jS0017Oak5 >									
//	        < 0gqarqx2N89eCsGI0D2Wk3F5vp6Q96i0D718f9nr323mCb3ETC8k5NakH3oUYP5K >									
//	        < u =="0.000000000000000001" ; [ 000037611797601.000000000000000000 ; 000037626140422.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E02F0C70E044EF1A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3751 à 3760									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3751 ; 09D5MQ9oTdP224b94sU54lAw14xdyU48uSJQc62h18K2o2dus ; 20171122 ; subDT >									
//	        < HRE51nV2PB8tm114dK00XOOF8suu826m1crKo7hSwv098INFFOqb7R7DD76h11JU >									
//	        < 4r2fjw8HjKWvgN3X0Z2ck62k24VA9OMK86ltgZ8U0fODo5pDt2cDx31076n6ss31 >									
//	        < u =="0.000000000000000001" ; [ 000037626140422.000000000000000000 ; 000037638514520.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E044EF1AE057D0BC >									
//	    < PI_YU_ROMA ; Line_3752 ; GBcQ1p8KOK1IM980gX8wNIa858w2sCJUpZ389iSu4Zc5Q24o9 ; 20171122 ; subDT >									
//	        < 8oa8wDdRFGn1Ho8Db17do1R0y4c7g0hN9t8j2w2P0eiwloK8mpSUeN4Aj3RQDB7T >									
//	        < aAZwc6Tr697Ib3LCFVLYEAKEV4lUdh4RVj86Jo3F59Z2OMukJhU4l5o8v49331j0 >									
//	        < u =="0.000000000000000001" ; [ 000037638514520.000000000000000000 ; 000037648645983.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E057D0BCE0674656 >									
//	    < PI_YU_ROMA ; Line_3753 ; dkD6yNJ04MPe5zl09uH5BGm23ap157zwDpsrz6PDqmaPSd5GA ; 20171122 ; subDT >									
//	        < 4DX2Q235361Z55Alb1z7951a6fk7ZBhO6PLODcboH8x1E94Gjv610on81655rw1r >									
//	        < 6shbmuX3qeMOkLm258I4E0390Yyv9d86IbZ2O4P7360L16D5PZ7q83eDNw0Uxh9B >									
//	        < u =="0.000000000000000001" ; [ 000037648645983.000000000000000000 ; 000037660082135.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0674656E078B995 >									
//	    < PI_YU_ROMA ; Line_3754 ; Sl4VSS1073EzyX89WN61e1RyQErycw3jZvN1Xg6o0E5f3WV0N ; 20171122 ; subDT >									
//	        < z1Y4hQuJmkK37iZoHEFN1C5V7A561kt0BYXgL0navh56rpduAmYf4zG4JMB7bqdi >									
//	        < oY8FAPj62S354zPgfM97J13HO2R8g91NknF2H5F94EpW5Hd9Ln0Gfb4x3IF0J478 >									
//	        < u =="0.000000000000000001" ; [ 000037660082135.000000000000000000 ; 000037668723396.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E078B995E085E913 >									
//	    < PI_YU_ROMA ; Line_3755 ; 0Zo159Sz7093Y4065mcHpS1fRRl8QEw41c5mLfaQ4hcW2PReg ; 20171122 ; subDT >									
//	        < m09WDn8xYHF88EfVnQCXZa4uiRBu1FrpNR3VeVkyNduL2jPMgf4Io76pxBlmN0DI >									
//	        < 57qvslm8O4MZIstkK24wOWn38N0NT1tg431tMQi72299i7VsdB7VfGbNUbltBUH4 >									
//	        < u =="0.000000000000000001" ; [ 000037668723396.000000000000000000 ; 000037678602020.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E085E913E094FBEA >									
//	    < PI_YU_ROMA ; Line_3756 ; ZmjQw3QlN4e6V169uQPb4mLwMH746h3xeCZ4RdGE0rk9Y6YHJ ; 20171122 ; subDT >									
//	        < 5m4MLf59wMU383w71KMMqLT86nR63b5bQ0RQDXG7ql52vWR29DIVFwBRqOnOwaAD >									
//	        < XQeGXruh7N4lGC4c6THP19zglKiXj7SujfbZC9KuaezsfHeh44Ctydb698Brom33 >									
//	        < u =="0.000000000000000001" ; [ 000037678602020.000000000000000000 ; 000037692369998.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E094FBEAE0A9FE07 >									
//	    < PI_YU_ROMA ; Line_3757 ; 0w07315m56VdROBvoLi2xvabN0Hgy0eOhD9P5QiX9wX2mk0Ou ; 20171122 ; subDT >									
//	        < DSBU298cOCFU6f24U9mH8h30DUs7hsZK0w4OM1261fJS6hu6rUvs36kjZP9FF92g >									
//	        < nW3bJ29s0ZuWKC6XfVhuIqp7B44Tbti7su643z937nGXF4HHWe8FMBniv6myEwc9 >									
//	        < u =="0.000000000000000001" ; [ 000037692369998.000000000000000000 ; 000037698909547.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0A9FE07E0B3F88A >									
//	    < PI_YU_ROMA ; Line_3758 ; VGI5gL311MpKj6aDZpFLXkAoxk4ltDCsq8OHM6Mv7nE3dr7rJ ; 20171122 ; subDT >									
//	        < 0e4gC5L2wlHnaf2jHNe4Gp769uGwHJXVq7H30817moVQ4Vc5wDZ9vnj96uwZThu5 >									
//	        < 0hT63xXqvMIm1ODEz58667Ux8I52zZLL88zZVa8n4u5624gAmk572Lq2JE6VKIaf >									
//	        < u =="0.000000000000000001" ; [ 000037698909547.000000000000000000 ; 000037709186332.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0B3F88AE0C3A6E9 >									
//	    < PI_YU_ROMA ; Line_3759 ; 8sIbPScx8Ue9L8f8LC05pycthIJ1Y510AD500RGin068klqgk ; 20171122 ; subDT >									
//	        < 4RG196HcAD67fa6efahCwkL7H3sFJ460Br72368PN2f12Xowq3BFJGT2OXGKwrC2 >									
//	        < t3LhEVB1HwUMF2UY3Zj8UvrfxKZXoX9JNF5MBWp5a2v2TKebsEKx76V6ku4508UY >									
//	        < u =="0.000000000000000001" ; [ 000037709186332.000000000000000000 ; 000037717041325.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0C3A6E9E0CFA344 >									
//	    < PI_YU_ROMA ; Line_3760 ; P0C6pVHJzu1iS5RA9rVM9Lzc47aao0v79t9ejsspErM21b8p0 ; 20171122 ; subDT >									
//	        < bIb6YDy3C8uYBNYFl0FNGsAXEGNNFNBe63lwMwa45Spm5g72rWnv4P9JUnfwFKn3 >									
//	        < StMW59oq6uohONPAix0L4bP449IQ945xEM26A87g1f8q7zhw6Ux09m94xql5BzZI >									
//	        < u =="0.000000000000000001" ; [ 000037717041325.000000000000000000 ; 000037728212231.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0CFA344E0E0AEE7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3761 à 3770									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3761 ; Z30mVxc5A6pP1VLcSgty7BNdsFoCVl05XeM4u735n2hjxI0c8 ; 20171122 ; subDT >									
//	        < 9ZSi8MLi1wJbPQT6MkG997MtVYcVIY6ug4F01o6XYLQErTiwdSRa661nVJH74bXt >									
//	        < AoS1N6b77atn5386VN60AKpM3ZZDfyfV5ye0Ax0rlZeIEe2vr0BnIv52gvUDVRsv >									
//	        < u =="0.000000000000000001" ; [ 000037728212231.000000000000000000 ; 000037733651619.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0E0AEE7E0E8FBA9 >									
//	    < PI_YU_ROMA ; Line_3762 ; 9O79w0O239k4J7Cx1o5m211lUy3F17DKh8bR41Li6XU03O70X ; 20171122 ; subDT >									
//	        < 8Oi3qdkr8jxyxZXS32m78cLr0G7n6Y0VZ3Lw18CzDgNNY1oy0ci2akU96IW86lb9 >									
//	        < wkTgH8a7OisPx33a92DEy6d0aJiLm790g9r5plW498cbv0Kb67ha98jz8A1ooW0t >									
//	        < u =="0.000000000000000001" ; [ 000037733651619.000000000000000000 ; 000037741213268.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0E8FBA9E0F4856E >									
//	    < PI_YU_ROMA ; Line_3763 ; WI75pMvh6uFqK034ToHltG9UFY9ZFzJZPLOc396jE0iO5IVO5 ; 20171122 ; subDT >									
//	        < KxWIQd1PxEFElG6Q4aduvxDM6770t3W2AQQJm6k1xvvr75s8pu23TM247R20pZZm >									
//	        < w2EV49GGFoUIk77Wqi10C8QyY8V9IR0qhg9bX7kEv5DrVe5o5ehjp217q96GX1di >									
//	        < u =="0.000000000000000001" ; [ 000037741213268.000000000000000000 ; 000037748449883.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0F4856EE0FF903C >									
//	    < PI_YU_ROMA ; Line_3764 ; 097G48Sd3gB406g7XqnNlNZL8r3W6iiEvv4YSk2rR584Iu18t ; 20171122 ; subDT >									
//	        < GHK9L18hRXCG5BIm827yM4R8X10AZ5g5TT306M0zgL9OSwuO7LWUf088186ZQ05e >									
//	        < 5Krz345FSTBooLZYhaMqNoSW3ItcJ9jJbwOKHYm76cscJz7s4e44AS6Sjy14K1ln >									
//	        < u =="0.000000000000000001" ; [ 000037748449883.000000000000000000 ; 000037756542048.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0FF903CE10BE93C >									
//	    < PI_YU_ROMA ; Line_3765 ; 70gVxE0v4D4N2aky6gH9SQjcsfX7mlzcy3Qo4x9HkIRG6G8mz ; 20171122 ; subDT >									
//	        < D5RYGv8Q0hiY555yR3g76CxU1R8hd9rE0ro7iKzX0Ts1b2mw8W8S6RjAVe3TENyx >									
//	        < 9eOSE5usNZtEa5IFH4826Nnc1qDpZ74KDxT7Vj64agG02FD5ua8Ld3T0a15sthC0 >									
//	        < u =="0.000000000000000001" ; [ 000037756542048.000000000000000000 ; 000037769024345.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E10BE93CE11EF522 >									
//	    < PI_YU_ROMA ; Line_3766 ; M7ZONCuFVL67F24dkna7JBP810C2fF48RLEK7WiVlil2fSg2X ; 20171122 ; subDT >									
//	        < HhucMO9n8Bgomb7w8QAv5CjEu0Zg0Mth15ieR3I6u4JSD7g407WFa7317x30hMcx >									
//	        < 0W7L82gcVzhQ6xR9e98q7U4reBQ4j9C060HqTgH8gqUxAxXOnElK76qLRx66fQW5 >									
//	        < u =="0.000000000000000001" ; [ 000037769024345.000000000000000000 ; 000037782806195.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E11EF522E133FCAB >									
//	    < PI_YU_ROMA ; Line_3767 ; tK98UsV8748uCY66sKAk306k1wLzRo0HesNxyL5One3y6J589 ; 20171122 ; subDT >									
//	        < 4jPHAag1L0z0fu2C3palPH89Cn01SK0g5y36j2DY78x65uVxXhIbl7V9yh37443O >									
//	        < W5QdM7ZvIap08LY6F7wM51Eg4xa224CC06489RHxjTvLJPSmj2I4WIQ58f1Uo29p >									
//	        < u =="0.000000000000000001" ; [ 000037782806195.000000000000000000 ; 000037789339955.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E133FCABE13DF4EB >									
//	    < PI_YU_ROMA ; Line_3768 ; WN4GrnJn080SU2FjOz7N9kyeHlp60UCUAA7r457EPvPSCd0ae ; 20171122 ; subDT >									
//	        < ExFqWoUlq268NtqhpY0e95d0d98c5bc52eOPoKy7884Ttzj00BIC5a6t55lIxZlW >									
//	        < WSWlRn16GuPGt3P0Zv2uc4LPX8ISpukQ4hgur9nriw0tYTeRgR43bPf130GI7834 >									
//	        < u =="0.000000000000000001" ; [ 000037789339955.000000000000000000 ; 000037801234288.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E13DF4EBE1501B24 >									
//	    < PI_YU_ROMA ; Line_3769 ; vnw9E50k3Nl89VSJV8V0JOZcQ9S2Yf650u3k188iZWss9g06k ; 20171122 ; subDT >									
//	        < 68xa9IPR7odgB2tmjOQ4kaJ7M8T5jWJujVK7D2KQokMwv0xcA83DLlrbai1z5A0T >									
//	        < rZI78EHeKic1JWi4pwgscOy2CYmFw2022G1mxDYnIeEI3aolA97j3i9qUSI7Er2S >									
//	        < u =="0.000000000000000001" ; [ 000037801234288.000000000000000000 ; 000037811132478.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1501B24E15F359F >									
//	    < PI_YU_ROMA ; Line_3770 ; bXI8V4611tzSQG9gMVeUI8wH3o9WBRPZw5xJAOta1XI3hYdkr ; 20171122 ; subDT >									
//	        < Ewu1cP67gHCKBfrAcdVk7wS3diIv9J33Sn2FAf03nyF8VqwJT4EEHaTy0D0KZwv6 >									
//	        < P5O490Hc0q94ulCdTPc0K9C1zf8bg9SzB7A1gI78Uc0l4Z5BCJ752zSaoCv85m5D >									
//	        < u =="0.000000000000000001" ; [ 000037811132478.000000000000000000 ; 000037823446696.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E15F359FE171FFDD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3771 à 3780									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3771 ; YJ1GUzSD084436rQXBwEebD5V02EXcAlSwp5biX3D3hK97tH8 ; 20171122 ; subDT >									
//	        < Sp07fpHMeBrxp46c1AFX67QF3a4CSq9U2O14Pg9ykKM407wpQL80j69h3T4Nn8kk >									
//	        < U88Q7v51sS41W4I6qwBST0551GRM4eD45Vwr16XSc7xg3Lej2PRp57F313934V24 >									
//	        < u =="0.000000000000000001" ; [ 000037823446696.000000000000000000 ; 000037832961745.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E171FFDDE18084AE >									
//	    < PI_YU_ROMA ; Line_3772 ; 2t55Fl10EYlu7v4RZJqtkr66FKWd6hN2O7Lcw48kI4Jx9Mt1r ; 20171122 ; subDT >									
//	        < C64l9X2hntSDT68UD47W3v0Nh2oV8DA1Nr2p0fbs1yE23MvtmOUPU1vh4Y1yz1CH >									
//	        < Jdx14d4H5kOE3Ci07fywY77D6by8dtTu6s2ioTcLu182xo0c3pn2nc17IhH8w857 >									
//	        < u =="0.000000000000000001" ; [ 000037832961745.000000000000000000 ; 000037840763902.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E18084AEE18C6C66 >									
//	    < PI_YU_ROMA ; Line_3773 ; fT3d0bm6WtJx91pEh0QHux50wYB2iDZSeU047ErK17GClszjD ; 20171122 ; subDT >									
//	        < 7o71Q9jbdipm6m0iRFX7uLXv5WgJvyQeQTIeS1824aaRw5bNav78Z6TqV2r3sV2a >									
//	        < pvg04anctD6QB0NmW2JfqQC1hLuhvLy13DJF6n4jgK85sg70rpV6CvTHwv246jHE >									
//	        < u =="0.000000000000000001" ; [ 000037840763902.000000000000000000 ; 000037852124723.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E18C6C66E19DC238 >									
//	    < PI_YU_ROMA ; Line_3774 ; WO138O520E5041735HbKaQa07w778P70upB5rt09v22fG8429 ; 20171122 ; subDT >									
//	        < uk0RkT3P0YIpq6vKiD04afalD4DRzOo0YB8n67cmahh5GDwuq012c8sJA16HoUZ7 >									
//	        < Jy46Lw5CzuaDQ1nQyn1bC06I2UnVEWfXyi9hH4jXUZ2f3Wn7XdX2z30L97rQ6HRE >									
//	        < u =="0.000000000000000001" ; [ 000037852124723.000000000000000000 ; 000037866108612.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E19DC238E1B318AD >									
//	    < PI_YU_ROMA ; Line_3775 ; 5Ft30970W0M4Zg61Fj0wq7NJeeM2pNr0UPi7qQu5morweq8Gn ; 20171122 ; subDT >									
//	        < 7ygUXYradcnbM7G4sDDVGB8Wi94U4G4w3PFfx2K9Q886eQSFcaqUuLR769iS1VeS >									
//	        < 36wet9M9GHWL7Ymwy2XuxdXkeXOKv6w30a8VJ9Hbj7JyT59389NWZMfCnx1odwXa >									
//	        < u =="0.000000000000000001" ; [ 000037866108612.000000000000000000 ; 000037879425235.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1B318ADE1C76A7B >									
//	    < PI_YU_ROMA ; Line_3776 ; 029eR0BU4b06AblMP5S1YL8PeCyiN9v767u3GI7jyx7c0ft0p ; 20171122 ; subDT >									
//	        < 6MScfiB9e8S610tgHVDZ4tV0A6Ffk3gZ5ROjMP9s78ZEOO92kAHIf19i3H2qX0Yx >									
//	        < jGYui8a5JAD0PbhU8SQpZ7IaV8M55AhPHQTyOEa3R55R3lx0NV6DZXErN4xVSAx5 >									
//	        < u =="0.000000000000000001" ; [ 000037879425235.000000000000000000 ; 000037884906243.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1C76A7BE1CFC780 >									
//	    < PI_YU_ROMA ; Line_3777 ; 1fgu1c09Hed84jTTq785Tfm2cP5hUyba66hgH3TZHS0Ktw77y ; 20171122 ; subDT >									
//	        < v9B14YL0y1IM17uvkVQr75qg831KefJS7YD6333dbc0nf67SLCM65dl9An33e23d >									
//	        < injOmWwPJ1y2euxx31bdV7DI7TC6k9dramtnX560p3xtFy4YN1ys6DmH9I80ZH9Y >									
//	        < u =="0.000000000000000001" ; [ 000037884906243.000000000000000000 ; 000037895894655.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1CFC780E1E08BD9 >									
//	    < PI_YU_ROMA ; Line_3778 ; r504wRZo8AKNE1o74oXiL74YO6eY6R0P0GOkFBeKksQmRx7Po ; 20171122 ; subDT >									
//	        < law0LeKPe8dgt96802yy56240e5iN02Y7v9tdkiNd8f92ddI7R5sNggh4B7EAd3f >									
//	        < PUJUhAXuK9GmsqU0nPWESHdKz9zw0e5Ciz06Pp0DC6R1Fi99N72FkXA075i3hvip >									
//	        < u =="0.000000000000000001" ; [ 000037895894655.000000000000000000 ; 000037907352207.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1E08BD9E1F20774 >									
//	    < PI_YU_ROMA ; Line_3779 ; 8BJZUf4f7V80JGh7GkO0sQF4024LeeHX8p9LRvogYnZ8JXO62 ; 20171122 ; subDT >									
//	        < DVC1uL4VG5799cRX10Bgi72Mv2o4cX9xu5EdK56fdpz756aZhM9bmg1xKgc3Q2kl >									
//	        < DTApSQ933C8YbQOTq1R49XmI15EVKfxm472k2N4YuL0ZcaKg9MH1GjYaf28olAjf >									
//	        < u =="0.000000000000000001" ; [ 000037907352207.000000000000000000 ; 000037915754123.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1F20774E1FED974 >									
//	    < PI_YU_ROMA ; Line_3780 ; Qm7pZx8MmM52RWuHo1s1BJvx8Fe8rJ2KK4T4Sdi2zpANYfDll ; 20171122 ; subDT >									
//	        < 57RFzs3j5OE42vq44569jL5qmhNc19ch3v366832zG4UVol26O4B8Rikl9Ra3Ueo >									
//	        < 7rP62c116R23i47yjSK43vQctQ3l6sjnSYcOW3KEMek635b9xUVka0q15I214rhF >									
//	        < u =="0.000000000000000001" ; [ 000037915754123.000000000000000000 ; 000037921978871.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1FED974E20858FF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3781 à 3790									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3781 ; z9kJoa8pMA6nPIhYK67Po94hasiK0H7vR5Pm8zixz88cj1HkZ ; 20171122 ; subDT >									
//	        < 6f056fH3cunUYXvcbvpJ3GDu79z8v8hWX3aNma8jI2lF6N7k81ndrkDavNoOLcc5 >									
//	        < lQRDnYQd3b9AC6Vavnwk6y516594g875n0B0s7qNEywPCA20QuNUHM5F35RAam6b >									
//	        < u =="0.000000000000000001" ; [ 000037921978871.000000000000000000 ; 000037932345802.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E20858FFE2182A94 >									
//	    < PI_YU_ROMA ; Line_3782 ; 9h8Hsi7aP9gAXp9535M08U49403eMQej6SX5OBIDtAYtAifeR ; 20171122 ; subDT >									
//	        < 36gUVs6oP47G1iQwfC5j9zQ6qy5uRqu5Kmo5tOfWVK4bhEffQa9u5qL72pK1mhY5 >									
//	        < 1104Rk4ZzI1y4uFkMDZh8UP7NE9ly0BOCIeOaszHvrVsTcEkl9KlNGwE80Se0L9E >									
//	        < u =="0.000000000000000001" ; [ 000037932345802.000000000000000000 ; 000037938431819.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2182A94E22173ED >									
//	    < PI_YU_ROMA ; Line_3783 ; 1l7yC7mQG97jw60r7eb85U41CiWQ518536YlL7oV42g5K7w3g ; 20171122 ; subDT >									
//	        < mlVs1NbB8ZlbHDpI096b29L3Z9t1928K6DrnGq5d62xJ17p0GJ4kyMsY9Z5jLie3 >									
//	        < 9KXdJ4d96ou2310Nub6ckXkg8zlA31Hdh6ZPM7vfdEQ7MYf9Fh05M8fw4RHvxkxU >									
//	        < u =="0.000000000000000001" ; [ 000037938431819.000000000000000000 ; 000037952669724.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E22173EDE2372D9C >									
//	    < PI_YU_ROMA ; Line_3784 ; ejMzK6W9UIB5U4v65GL02xUq3A9RX0JPMAfC28Q79c7CZk2Tl ; 20171122 ; subDT >									
//	        < uu86o6q3cxf2zblH7Q13i2l0iPcPz7x6GG14W7pTNAv7W0J46xo9RHOP100WEQqW >									
//	        < h5J5oe47n2TXaL5GEakd502Hpl4F3Sv1cYNXC85iFMCzz1VJ1jd1Xk4hRawz4r0V >									
//	        < u =="0.000000000000000001" ; [ 000037952669724.000000000000000000 ; 000037964251361.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2372D9CE248D9B0 >									
//	    < PI_YU_ROMA ; Line_3785 ; q5pEzZ6Dkj3V4Dxifvyv1Ws1AfXZXLtu8qdGTNcB312IT7jkn ; 20171122 ; subDT >									
//	        < W0DQ2Mebr2DiL6ei6zLL40c0qNgHZCxzGCeAC1KcZ16W5c1xtawJuKCOpapjlM38 >									
//	        < FpDt19EZGVkv622V3J8u34awIU8x5EJ0474x415tdR267J475sHp5N7N03dWtHY6 >									
//	        < u =="0.000000000000000001" ; [ 000037964251361.000000000000000000 ; 000037976050957.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E248D9B0E25ADAE7 >									
//	    < PI_YU_ROMA ; Line_3786 ; 142y9SVkvjMnp3140H1x286GVz3Yq58xJ6sJ064QCZio9c8n2 ; 20171122 ; subDT >									
//	        < tJ6nZ508z67Glv56g1KL5fj36iIQ596RxmBky3896t0sDKmTYqnpjb35e1PvLzII >									
//	        < ZQR2z92gY3Zpny2AWix51G43iIBbsVHzkE7IuPD3R37i4WYc49sc743hFf4ye14B >									
//	        < u =="0.000000000000000001" ; [ 000037976050957.000000000000000000 ; 000037981494537.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E25ADAE7E263294D >									
//	    < PI_YU_ROMA ; Line_3787 ; 3f12W3Z7ikpIUj0S1lknRbQ4he3c8J1t01H2U3Ebr172r8A8r ; 20171122 ; subDT >									
//	        < YAtfb4fX1L97G9Th5nr3VK90Mq5MhmMf5tx72AFuWT1mxJwVeT5i28DuT4GLNI9z >									
//	        < 3Ilz44iEM0Vq4Op8q4F39VfSDM6O2rF806VxT1QaH9xO5WFe1Oy48cgItGCTrh4d >									
//	        < u =="0.000000000000000001" ; [ 000037981494537.000000000000000000 ; 000037996331714.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E263294DE279CD13 >									
//	    < PI_YU_ROMA ; Line_3788 ; EqKN11Hx853wDl01169T2dm3Z2GPw6jG1Wo5CVSiFr56y0q12 ; 20171122 ; subDT >									
//	        < D5uOSgBUvJ74miGX5GVH8BB268HuHFgfv3QIIaeC0r9K4OxKG5KAmdmz54xwEO9u >									
//	        < cFh86kShpI009bsu3V2D159u02307URvgW352Eol31W33hnK35Cs118JVICTm4oI >									
//	        < u =="0.000000000000000001" ; [ 000037996331714.000000000000000000 ; 000038004309375.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E279CD13E285F959 >									
//	    < PI_YU_ROMA ; Line_3789 ; YwrErZ8nZWo48AP3ml6vn0S4272PbM951RGqKIWFD3Q1aE191 ; 20171122 ; subDT >									
//	        < 1KWj26K0K68BDV61Qm74Sf5y8S2wyK3NP1x6M97X9U502P9L73BM35gFr8VwO1yM >									
//	        < CrwrkN3d696OKN2rs458N660vfMBS8A4jRuw1V7ez2f7j3KEs86haiziw1TelAd5 >									
//	        < u =="0.000000000000000001" ; [ 000038004309375.000000000000000000 ; 000038017010852.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E285F959E2995ADD >									
//	    < PI_YU_ROMA ; Line_3790 ; kmI2bnJRCn887sIqQrbpYwmfz1p5l8sO352129N3G9A3TouW0 ; 20171122 ; subDT >									
//	        < ZkK032H31S0104AJq6wL9fB8H4G53m8jY9nhDMr50XQL2qH08uH8ZOpVmN8uRS01 >									
//	        < rTaPkJgmrGpgY5wqORR3xv39kYeT38Yv7Sc5j8RW3A5YeQ90JMElOnf1iSf4804n >									
//	        < u =="0.000000000000000001" ; [ 000038017010852.000000000000000000 ; 000038028049141.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2995ADDE2AA32B2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3791 à 3800									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3791 ; eAF0xb4K31CK9iB6A991qy8LvKR4i7C4V99HpHuUmzxq16CQ0 ; 20171122 ; subDT >									
//	        < ty3DVll1PPWayDbPVX4t0CRi211mlcTT8O9g56QR0969il5aT51Pj8cF3KIQDs0z >									
//	        < 3Pww8nsa72E6ldj3LGL1riU8u1RE4k7DsG4IhKwfn9y3cS9sXL5NctWC5vC0f8rr >									
//	        < u =="0.000000000000000001" ; [ 000038028049141.000000000000000000 ; 000038040509834.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2AA32B2E2BD3627 >									
//	    < PI_YU_ROMA ; Line_3792 ; 3P2JXVukQ0Rk81gX1ix2hhJ486Fmwa4135s1yY0m97WN7MOGo ; 20171122 ; subDT >									
//	        < rx65gVSoB8DRKD2g9Z060LrD15yI3mFnOR6EzXb3Nc9J758j97O380W3017GM4n1 >									
//	        < Yp2rNlIRe85980F6Oye410VL3ezUMFrZfJLdDkPwX1CIG98v1CKY21WhC2H6c18c >									
//	        < u =="0.000000000000000001" ; [ 000038040509834.000000000000000000 ; 000038048602508.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2BD3627E2C98F5A >									
//	    < PI_YU_ROMA ; Line_3793 ; a7aD3krjHe7H4T95qCd8jUg2tWGo66Djw67X6Yker0x9E5K6G ; 20171122 ; subDT >									
//	        < z006OVZH7lIxh7K56O5Q8q81y6B54007u8uWQrAA6S0Ev79EoMvwlHjJtPV85Q6q >									
//	        < 4EEfDc6IEKA5gory7zUh9Eoi647qusnOMY2B9shYo9C275OIjqSt9OmPUovmTo17 >									
//	        < u =="0.000000000000000001" ; [ 000038048602508.000000000000000000 ; 000038062273705.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2C98F5AE2DE6BAA >									
//	    < PI_YU_ROMA ; Line_3794 ; J35oqwE24rW2qfTILVHE1StbDwhjI9yMF0h3pf5Sx4KYvd8AJ ; 20171122 ; subDT >									
//	        < zAs7z8T3eLV3NhyhDyI06Ut440KyNZ88wDo0O6482oxN7ng0fK8VuKuHhhUWaE1t >									
//	        < 3Kh9K8F8q4SJ6XjrzdVStaho53XAe1V2MPaq0JTZ3sFY9On6eS91S9hcIy3aj5W3 >									
//	        < u =="0.000000000000000001" ; [ 000038062273705.000000000000000000 ; 000038074846735.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2DE6BAAE2F19B01 >									
//	    < PI_YU_ROMA ; Line_3795 ; VXaoGp4lbTh8aVpByp0JU76UVeVPGey82TXZjm0fv4kFf30a7 ; 20171122 ; subDT >									
//	        < 8ioc1FMPl12heYUuhFk9d9tS728mNuq9u4n2FwOsci19nDY52eeeiqNyw596Cbed >									
//	        < iM37F9M3BLYc4C4JSHr7Zy3cieltaO77uLbBzjy7AAwU498X6bI2UuseQ2v0oOn8 >									
//	        < u =="0.000000000000000001" ; [ 000038074846735.000000000000000000 ; 000038082548662.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2F19B01E2FD5B92 >									
//	    < PI_YU_ROMA ; Line_3796 ; FRisexTINU832PO7m7J0mw7I1ct0uIZF4h770u1qD7ilNAv4w ; 20171122 ; subDT >									
//	        < 6qkDbl2im66PNMaZfsWh9R15M32m2P5KvpGjpbM8EN62SPBjv2LRJvga37A9Gbl2 >									
//	        < 6Uu42jt0dqp6LmukP8ADrC5DS88gEm8AfVon4XTy36wMzFb4tOvC5d7eiQgo10nF >									
//	        < u =="0.000000000000000001" ; [ 000038082548662.000000000000000000 ; 000038095838196.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2FD5B92E311A2CB >									
//	    < PI_YU_ROMA ; Line_3797 ; GAP0a933wdrIj5krqgf1Fydn6gVuHix5FOKRm4N90L59s58mo ; 20171122 ; subDT >									
//	        < rMrWdqI8RvB931B566ml1lmR4a1iRd2A2G94a68OksUF9R3WCk54HHd15B3nyJ39 >									
//	        < caa9TkeIYlJ08oVwjQ89Mv9sL0CTcV05IwXoPs1Yltb0GzUA817i0AntjJ4oI3SS >									
//	        < u =="0.000000000000000001" ; [ 000038095838196.000000000000000000 ; 000038108514279.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E311A2CBE324FA63 >									
//	    < PI_YU_ROMA ; Line_3798 ; W39Jn4etNXCRr2O35cq0ywX6nU64xp15gD1j1nx1l4r5l0O60 ; 20171122 ; subDT >									
//	        < yV930XaHIIaf002sJQH21FS455XtCAdM00zy6v92QKw3bQQjGTH6HETb6x1844ja >									
//	        < XvrY4B98oi0A7gqUCNSYAOW5OXv9u4MFQ2PWFIz2R7GJ8S8QP85i5YXe9Yx1Wrx3 >									
//	        < u =="0.000000000000000001" ; [ 000038108514279.000000000000000000 ; 000038120463734.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E324FA63E3373625 >									
//	    < PI_YU_ROMA ; Line_3799 ; 2JRNx8D0q7MMd4K3m92Fd0F6M86JdSOw5vDbXar6vMufu5rG7 ; 20171122 ; subDT >									
//	        < Y677yo5Uyo58T36pD856Z578OQ1VMJ5DaXVMAsx10MfCFD24tVFszJTN909NS8v9 >									
//	        < MhnN7SX1E5hM70K15rdd8Jw8Porwir3oj2Q194gAYNP9dgTuSb4f4GxMas7Admk7 >									
//	        < u =="0.000000000000000001" ; [ 000038120463734.000000000000000000 ; 000038128434504.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3373625E3435FBA >									
//	    < PI_YU_ROMA ; Line_3800 ; llL849wS980a456c3g2Kf068Umef5lt30VnY9P3PVmay2WgkY ; 20171122 ; subDT >									
//	        < on4634tcv48y1RSQckmMukpyjT3re6FVY5gYn7Qd9R88Mw0094iNA4EQsSj3RdFv >									
//	        < 8hzRVgo63297GOkHGDe525SS2Hx5D77uA52ed43ReU5sO0J2xcI04I3iF6sIXH5n >									
//	        < u =="0.000000000000000001" ; [ 000038128434504.000000000000000000 ; 000038140696885.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3435FBAE35615B8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3801 à 3810									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3801 ; wAKZ2oWLn5wz6IbDitL0BhMAGE3ju42Cm7JW0Qb1r7774rdzf ; 20171122 ; subDT >									
//	        < GY588cE6W7nN8bPSm4Yd0wtRHpxvi8mv7N5Jo7yWHz2VZ22S7ofyrc2lfIs4UabF >									
//	        < ivSbfY9896xTTwvtXc1Yr297eP1FYUVqPVz2jHvQ9gVx9Qt7BjK1a9Lrxj1hgp0M >									
//	        < u =="0.000000000000000001" ; [ 000038140696885.000000000000000000 ; 000038152527008.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E35615B8E36822DC >									
//	    < PI_YU_ROMA ; Line_3802 ; z5Q045A92u8r0zQhH3kovNqH0a138ZzGoc11Qm38Wu7z0KiX1 ; 20171122 ; subDT >									
//	        < voboq629wz587M0k65076jZYM1jkjIKmie261IUuOS94t1f1r4Y8e0erNPN8RY23 >									
//	        < 0jK8P6aIRU13aR5H28mW1UEwk862dny38HI5LaPkNpK9I2RtfhXjq2TJGT98RZqu >									
//	        < u =="0.000000000000000001" ; [ 000038152527008.000000000000000000 ; 000038160188551.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E36822DCE373D3A7 >									
//	    < PI_YU_ROMA ; Line_3803 ; 9nppRxFoNDuaZU6Sk126B2E3B6vRI1k3V6wgY4MLAnDD40hZO ; 20171122 ; subDT >									
//	        < n2f2DRZb8U06gkCeDYCOo3PjK80TZ51c7D30GBLQnS7sz9SDfzl7ADR0Y44AN9J8 >									
//	        < b4K074eTDI79FqWHx8gZfW0sbLM5txDVDPgJDROEhMz6odD4Z8O518I85GY84dTN >									
//	        < u =="0.000000000000000001" ; [ 000038160188551.000000000000000000 ; 000038165289306.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E373D3A7E37B9C22 >									
//	    < PI_YU_ROMA ; Line_3804 ; 5FJUsq9txh4Jal28fcoEEGMY11wxgo5Ucwx9aD5resPrymWNc ; 20171122 ; subDT >									
//	        < g5OdC6uUNkgRD29pw9LMZHLy0hf8J138c16JZhoJ4lZarWujKu9CieC0W0E70rHT >									
//	        < A610kkH1DeG6Guc1226Guwp8x104N6P2ZCXKk2lG0alfmYx7N244M8rU6bHGap3Q >									
//	        < u =="0.000000000000000001" ; [ 000038165289306.000000000000000000 ; 000038178367764.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E37B9C22E38F90E8 >									
//	    < PI_YU_ROMA ; Line_3805 ; 8FES60d60ClR2A00Qe9VnmGY1Ut79Y3EdJ6RhHpr1qCLu8sCI ; 20171122 ; subDT >									
//	        < u8V3541L2U1VfcUuN75d27DX4r0cH8djz26Xk4vdtUL6b8mj7ZCb8RYrnrCDTVf2 >									
//	        < ZBZX6jlfvbSEBsczeEeOFnI91AB5Spwg8B6wc1k4FVrh5V8t08861R932GvmQS86 >									
//	        < u =="0.000000000000000001" ; [ 000038178367764.000000000000000000 ; 000038186155309.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E38F90E8E39B72EA >									
//	    < PI_YU_ROMA ; Line_3806 ; 99A4J90yY30CM19jd129NYDrd7wjJBT1vk9cd9F5w8pNjk9pk ; 20171122 ; subDT >									
//	        < QnA6W50eowOYcyZ1efHQZ6oQ5G2VULYbcJp65t9qF94urLZDgckhDpntNwU6U13m >									
//	        < z37Ifi54jtmClK3kf91zjgD41rz3h4pGKAcoZw1X6yL8n44W9WqQ0B0G46cEqZ2L >									
//	        < u =="0.000000000000000001" ; [ 000038186155309.000000000000000000 ; 000038193163491.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E39B72EAE3A6247D >									
//	    < PI_YU_ROMA ; Line_3807 ; ku7e6Gud3pHt1zbUPX4I1S8X92K463ubTBBF6z2s6LSs8u64c ; 20171122 ; subDT >									
//	        < b1C3jWXu2109X2s432E6K3Mnf607EU7b392U5Z9F8c6UTK74160U1Bcs181kncBN >									
//	        < PgP7ywxJMHzh6myVav96YTlk6jPsEnhPQ8IGsAiYH69c9qHivEL4UNJBAZPGio03 >									
//	        < u =="0.000000000000000001" ; [ 000038193163491.000000000000000000 ; 000038198698914.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3A6247DE3AE96C3 >									
//	    < PI_YU_ROMA ; Line_3808 ; dfP0JB05HR3qJanh7x7Ad327N1Dll2En5S9nO75MBTj3e5ka7 ; 20171122 ; subDT >									
//	        < EMDBoUsl9GEk5zGWCj943nH1GT0xTz5Rw7U8Gwg08HEZ4DcmU294tNybh0G7umWJ >									
//	        < NY0k5WpGC7O7pLYxdR4KH1172830k3wZxYcTwgE9G5X0u8T1cmJ06M407OM5P303 >									
//	        < u =="0.000000000000000001" ; [ 000038198698914.000000000000000000 ; 000038211414527.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3AE96C3E3C1FDCC >									
//	    < PI_YU_ROMA ; Line_3809 ; DZYqKH04F7D349w020rW3Sd4i7030tcWuTnwvC8NEuMi8eQp2 ; 20171122 ; subDT >									
//	        < s25Rw2ZVo5k3ng8l9sQUahlqDg9tTW48V9h3yQ3p55F955inlzn9L00D325fw04K >									
//	        < DH30tLEfayRJ7SwnpZfRsVUxDg1Jl1g6IRCl7wmb8vJGQY7M9F54337rbIVh3aHH >									
//	        < u =="0.000000000000000001" ; [ 000038211414527.000000000000000000 ; 000038217568711.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3C1FDCCE3CB61C7 >									
//	    < PI_YU_ROMA ; Line_3810 ; 2kHcjBiSmO31zo80S5grPU3n4q4ie9MyH3Ko5Hv94orG6IabN ; 20171122 ; subDT >									
//	        < bFzKYGjcFk05Asn2nrT6rT4m9FL6G5Q2gj6V1zs6El552QNB4CG5l9c7XYBG5PX7 >									
//	        < xEQrF17X18xwv9sNR8slKELss6153Dtr9y67F2518I7U0196o5M73s1xZ84Zjqyk >									
//	        < u =="0.000000000000000001" ; [ 000038217568711.000000000000000000 ; 000038227725824.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3CB61C7E3DAE166 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3811 à 3820									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3811 ; gAtEENGqDP1jJwS9Z3X6x2k5auG4X70b8Du3X2T69cl9f8929 ; 20171122 ; subDT >									
//	        < dQzyxoo84Tp7tx4I7s8b1W2D8Zw5B3y0HE1CMZRIo2K54oY2fYP9908JZhz5k5U3 >									
//	        < vD0OhSSN0ICRsWbM6j5bfm6bPZ025qKNAs3hxk93SdXYhY749eqBtrbKa8wtvf0P >									
//	        < u =="0.000000000000000001" ; [ 000038227725824.000000000000000000 ; 000038236394653.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3DAE166E3E81BA9 >									
//	    < PI_YU_ROMA ; Line_3812 ; 65ua64MqF67JIvU5X747o9xe5q7uO2Sp76O38w9n63fRynt25 ; 20171122 ; subDT >									
//	        < YCVfV7LS623mQ15PmjjA27Da32S9xs1ASbO1Ot6qN9TA8e9E9pa5jXgl19c55mKT >									
//	        < sWStKtF67fmM5V6t28DjO287X4RF8MTiSJUm209fC6h89247j6188ere0Ei9cpGX >									
//	        < u =="0.000000000000000001" ; [ 000038236394653.000000000000000000 ; 000038241518483.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3E81BA9E3EFED28 >									
//	    < PI_YU_ROMA ; Line_3813 ; 1JvGgA61Vaa88HnZp7C5ZQ9ewZ2Xr1y9328nR4TqAFMaHY85O ; 20171122 ; subDT >									
//	        < 43vJ7S9K6AWu6nRNmwO2emTOzUb978qGX678XIcL50vuRc6Bj2cliuD8jn6fdRqP >									
//	        < WnnL97j4X8w24a2rhfe5OimMw046n5pbO8K6315jY9923vrEsiKA688BMg3II41h >									
//	        < u =="0.000000000000000001" ; [ 000038241518483.000000000000000000 ; 000038247253229.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3EFED28E3F8AD4A >									
//	    < PI_YU_ROMA ; Line_3814 ; ZIGxXOB72QhNw82z4U4IvrDmVqgFD4bGHm68Z9792z5Yv77m4 ; 20171122 ; subDT >									
//	        < Nxki72c2AFDb5ZC8x7c8Gdmu2zLfUnD7Cd0bAFoUY5BvQXKM9m0JGFlZfcHWy453 >									
//	        < 7100ql0YP5vPKfGvAwiv1CKz2tk0451P50yB58s063KKFj7WrBy0yHqV6i5p2i6Q >									
//	        < u =="0.000000000000000001" ; [ 000038247253229.000000000000000000 ; 000038259485601.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3F8AD4AE40B5790 >									
//	    < PI_YU_ROMA ; Line_3815 ; MPt6MtIDT866kw55CQRy9TQxOzP490PY8nTbLs268xkR0T0k1 ; 20171122 ; subDT >									
//	        < fM5W90lIke2mqP4Va8d9Kea082Pzb2CmL555do1Dr8kQClLBfrIbyOt47DOIzQZJ >									
//	        < 8S7T3SDzdQ39Ufg5p9bH91Bmv815e79056931915L7I7SXWhRskWl8ut57Mf4COO >									
//	        < u =="0.000000000000000001" ; [ 000038259485601.000000000000000000 ; 000038270967687.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E40B5790E41CDCC0 >									
//	    < PI_YU_ROMA ; Line_3816 ; 0MWQ59N28PwuY05KZ4pUB7s59Zgzf5iZAVLXvofD8Yb69XS29 ; 20171122 ; subDT >									
//	        < dtola3d4k3zsK03G0V4fvS6w08bQ5un789ea5lvn37Y63RsQJGR4wTrZ22Pg9g9R >									
//	        < 7027PG5BJvAUpR2zr5kAQ06jo5n5v89HyypU5Zt7D1d6fwKsCoqqDLaPY692km1w >									
//	        < u =="0.000000000000000001" ; [ 000038270967687.000000000000000000 ; 000038279271853.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E41CDCC0E4298891 >									
//	    < PI_YU_ROMA ; Line_3817 ; NQ5Jj76j36G9DGKD73U0oWo3wNhR0h9a7ae77ZcWDX7A7Rr5U ; 20171122 ; subDT >									
//	        < JrBid6LI29hPhb7cc6eUzg24K05Sf45kf6KNHJX90SJiDyquzpji379wjLyl8rfm >									
//	        < a2Gk624y04En8inT7HNgPCE90x05042r8WQsHoENFER7bGoM66RazG4S9g2QJSp2 >									
//	        < u =="0.000000000000000001" ; [ 000038279271853.000000000000000000 ; 000038290528812.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4298891E43AB5D1 >									
//	    < PI_YU_ROMA ; Line_3818 ; 4PfrQnsNoUrABa3cR5g3uTCYsN4hsLy08c4LfI7RgXFA9B8cY ; 20171122 ; subDT >									
//	        < d0r6hMUKVZ1ests5JCXFRv62320kuUfaB05lrLWS8os89a9k216akw0yfI4gpQcs >									
//	        < T5098dJ5pFruey1Wz8AKNh0a55UlO0jjeW5flcwzgGA0T9KLaEx1A8kl8aD3665Q >									
//	        < u =="0.000000000000000001" ; [ 000038290528812.000000000000000000 ; 000038298194340.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E43AB5D1E446682A >									
//	    < PI_YU_ROMA ; Line_3819 ; LImWvp473J6P9S4cgfU6WE22Eub9OtdJ0S3XY0vUtgi2yF962 ; 20171122 ; subDT >									
//	        < om1vTLVBs2k90NnTOW0IzkaC0Yy2BPv810DJ0oN05cMIFse1X5h4N6T1r0eV7dVX >									
//	        < lHU627K25dc9rZE6G2KCm0GzZ01AjlW7sJEUg42tRE49z3w8P1CoC53h803ofA2T >									
//	        < u =="0.000000000000000001" ; [ 000038298194340.000000000000000000 ; 000038307832988.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E446682AE4551D42 >									
//	    < PI_YU_ROMA ; Line_3820 ; Yn4R23w9gvPlDVLlVH26eV56CwoEP3i57l3s004LnOQL7xUtT ; 20171122 ; subDT >									
//	        < e26l2ir27149xZp31UDxfI1174K5yiUJj8nF4Fejoa6eaT2uWEc4VUM4HH9yvZfb >									
//	        < z83eg2n280U0709GAQ3YCMdQ8R0283bgJv9c2hhv87Z03A1RE6ivj4FPXr8Cd4kS >									
//	        < u =="0.000000000000000001" ; [ 000038307832988.000000000000000000 ; 000038322028032.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4551D42E46AC633 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3821 à 3830									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3821 ; adVXJP60FY03742182F5JY9Tzz572deVRUF9fqiZ786AJwC0c ; 20171122 ; subDT >									
//	        < L73o574DmeQPpy6HKTvQ0082avQ1WVVG87tW3vsha2on41gHrnFB56i43dST5w6F >									
//	        < Y6gH5E8zQaiOM6KEche3x58KKik5imBcabpRKB6x945Ci8457u2a6jlMvEc2EHRo >									
//	        < u =="0.000000000000000001" ; [ 000038322028032.000000000000000000 ; 000038328090842.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E46AC633E474067C >									
//	    < PI_YU_ROMA ; Line_3822 ; fepUxvbP5LY5YCWc17awK37UXjO2BljvY54deG68I5WW7F47t ; 20171122 ; subDT >									
//	        < YREUHE02Bvq4bB8YTRL32NLN3tGIBpe0h7cQa165APJWcA5F0frCB41CCDfA5Ni1 >									
//	        < OKGFtHX6DnS2QTt897MK1bmU932t85mS45F94su8Qja10Py337CJJfq4Z98AyaOk >									
//	        < u =="0.000000000000000001" ; [ 000038328090842.000000000000000000 ; 000038340791909.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E474067CE48767D6 >									
//	    < PI_YU_ROMA ; Line_3823 ; XGs56ZZet7eM0p6cSzJMEBzqt9YaC9E8D64f343UTv49jpP9g ; 20171122 ; subDT >									
//	        < gVB112ow7emHzCu23Qs1QZFk8hKEM44NCx81uiU3r9AvA9CNo67PTXOUHsD4l5mM >									
//	        < 20CAKykw2L5omb6DzJk41XY8Fg8Y4DB4eJsE0yj6GNSGIS8bO770ebkE1o7TRh9d >									
//	        < u =="0.000000000000000001" ; [ 000038340791909.000000000000000000 ; 000038355110434.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E48767D6E49D4103 >									
//	    < PI_YU_ROMA ; Line_3824 ; 4P594R56ZX4vWGkH24hcTXsUT1d9TA0FrozT30z308R03Ns46 ; 20171122 ; subDT >									
//	        < WW9966ob2osKGzlNt89o836f00Jfv1Uo6hB202M41M1009S7sv32d9KZ0287i3g2 >									
//	        < JW68fytdaYPP4z9wADH11N6zr9i66nUQpFB4hJ3MZNWMJ8ALppvr88w3copbzqvE >									
//	        < u =="0.000000000000000001" ; [ 000038355110434.000000000000000000 ; 000038366796556.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E49D4103E4AF15E7 >									
//	    < PI_YU_ROMA ; Line_3825 ; bwtE3rzDygJ5dz6rv9830gr111m9aENP6I652N56Q8QQQTYQ3 ; 20171122 ; subDT >									
//	        < rk055aiP9DKHnejH654tcnxn10mhk5shU0gpAa7R5g4f0pUwyC36gukp36pwy8Y5 >									
//	        < m95296W2RjXXQfEbGMDPZ9x3kghrDJ94d5Ze21fY39v4Y4rI9KWSnuH66LMhI3EF >									
//	        < u =="0.000000000000000001" ; [ 000038366796556.000000000000000000 ; 000038376494446.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4AF15E7E4BDE224 >									
//	    < PI_YU_ROMA ; Line_3826 ; 479VIcKbYl682bSBqklP09972o1b75H62OVQ6l070pS3tAwMV ; 20171122 ; subDT >									
//	        < NkdlImj8UoFtsoF9QK6d4031q96DEMaDW4Vr6h8Op22295G37f56H3DlG9HY01O7 >									
//	        < 0K0qK6zTyJC2P5PGZ46Htvs429cU8iv7hj2BOZUQKw5hDW4B9I68aH89kVhOxt85 >									
//	        < u =="0.000000000000000001" ; [ 000038376494446.000000000000000000 ; 000038388652858.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4BDE224E4D06F85 >									
//	    < PI_YU_ROMA ; Line_3827 ; Lz1xy2C4Ng2PQlx5Qa4aZ13E18Vjn9G8IJ6372786FSZ0880h ; 20171122 ; subDT >									
//	        < F666a3bjSTO8yr0W747NoiU8jXOrLH37LtyqryELXzcOg16XtiRLEmbq2x3seKOI >									
//	        < Rxmh3t88642KqHN15rxvigt2jAN886NHuT6TPzJ70Gk7mvy96Y466cCKJ3Fy0445 >									
//	        < u =="0.000000000000000001" ; [ 000038388652858.000000000000000000 ; 000038397627868.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4D06F85E4DE2162 >									
//	    < PI_YU_ROMA ; Line_3828 ; IDLd3m14mwWuXjyPI7DwPur4IBSM19olpPmgV3nQAY9MkmvA7 ; 20171122 ; subDT >									
//	        < cz6A377MgBoEPCtgk5QaMKCjM55Fnu6pBZ2a3lt61y27zR3vZWaMEr65Qs284H7H >									
//	        < m3ksYlTv8TljK2nB0dJruvPU20Jy2PboupCD7uy2QUw436CU6R936bW175075HTi >									
//	        < u =="0.000000000000000001" ; [ 000038397627868.000000000000000000 ; 000038403502761.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4DE2162E4E71844 >									
//	    < PI_YU_ROMA ; Line_3829 ; gcM4OIMn5yWsjVK9eAyIP9V72Zrq44TqS7jo36nu235A9338N ; 20171122 ; subDT >									
//	        < u8g63nf9LsUZN3U1qA59RXK5WsApPf1s2IvxWNVacu05j1ItZc4z40192wQ7bfXp >									
//	        < 82DL5qw17Jl56HRAmIRVUPRF6PAW5eu0gJ3FymT2VvUDZjDg99dTTZ9lY7J581Bk >									
//	        < u =="0.000000000000000001" ; [ 000038403502761.000000000000000000 ; 000038417778398.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4E71844E4FCE0AF >									
//	    < PI_YU_ROMA ; Line_3830 ; 0XLJ0AsaMbBJKDO6q432X19FMlR5LF1sf53In11BgSuB2nwLF ; 20171122 ; subDT >									
//	        < 2esB6mk4OQ417gcH0oU5813eCU2J1SbxJGcYYp0eZ474ZML3GYUoFQX79CM7u0aI >									
//	        < mhwJ80a7uD5M8926zP1JfDSBO1XaEITc021VQpVP0654DRM1kH4LJsWrwR3shU6l >									
//	        < u =="0.000000000000000001" ; [ 000038417778398.000000000000000000 ; 000038428709045.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4FCE0AFE50D8E78 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3831 à 3840									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3831 ; Tb0z8VRRk0kCyYjubb99hyVeA67d63Ku41kPEykT8w5QxE75S ; 20171122 ; subDT >									
//	        < 6wB43vgl29r1327Yk7Y0cdf72D85aqWD7gRB83S0j4nQL4pNSd0Uz93o88n9AhB0 >									
//	        < W05i586FF4Me9y5pK7cW466e602TXRzRPj095MX6ByGC06wRU2rJ85enHi61WoE9 >									
//	        < u =="0.000000000000000001" ; [ 000038428709045.000000000000000000 ; 000038434045509.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E50D8E78E515B306 >									
//	    < PI_YU_ROMA ; Line_3832 ; DjBGp305Y5KTQCoH2PKcn85L846o3j7fhVTHVcNG0O4Ug0e71 ; 20171122 ; subDT >									
//	        < 4knsO1si290Dq4mq136aZ308G2o49Ax1HW5tKN6dgTGKG3qeyh542CAMc7459i66 >									
//	        < np40a2A4X9vQS7P7wbzfxa3k0uJjRDm352179HzXIJ33iDYB32XEpQy9n4ZMHn0f >									
//	        < u =="0.000000000000000001" ; [ 000038434045509.000000000000000000 ; 000038446906037.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E515B306E52952AB >									
//	    < PI_YU_ROMA ; Line_3833 ; 3TQZuM0hjr46blw9sWaNQZFGQzeD2E1i0t365lOsfuVwNj8j3 ; 20171122 ; subDT >									
//	        < 1z5S83WnbFSsW1Hv9I32336Z3Aq83ox3APts5AV26Zm14973jpG14ky6gfgH5RfO >									
//	        < a2kDbnUZ828NadrMz3hX06hgrGau00rspdHR4gXD3c0kSpPkHG4N3DHHcD21lg46 >									
//	        < u =="0.000000000000000001" ; [ 000038446906037.000000000000000000 ; 000038453041155.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E52952ABE532AF33 >									
//	    < PI_YU_ROMA ; Line_3834 ; 294i1ohomaH63vSWgup8Q6nP8GD43e4MvoIjOod622Iuour36 ; 20171122 ; subDT >									
//	        < 1Q6N7K5Ttj56fSkkyqq862582Tn4245b324SUx5UG9g59tdW3F5CaqZH0DWOwthr >									
//	        < btsI34ywsFQ9vRi7a1Z8mZ5L4f5WKYQYXB30JhfribRLL99sa8qR61trK44grl9B >									
//	        < u =="0.000000000000000001" ; [ 000038453041155.000000000000000000 ; 000038460046462.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E532AF33E53D5FA6 >									
//	    < PI_YU_ROMA ; Line_3835 ; KUzO3b0AP5Bi2V99G1Mcs77d3v6myt4Dz5x6m2xyZy7rN8j30 ; 20171122 ; subDT >									
//	        < x28tNZ17sfTlDq2RGlf3g51F76wvRTX0QME91J479SHdWhnOqRKB8qsG83kP6EYO >									
//	        < Jx0JVhhQu1yUqG5Vcb7TTo0gLunH6x2sVpymWlH09xk600zQUi8v13KYdpT5pH4K >									
//	        < u =="0.000000000000000001" ; [ 000038460046462.000000000000000000 ; 000038471389598.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E53D5FA6E54EAE8F >									
//	    < PI_YU_ROMA ; Line_3836 ; X793zD61nJ036vXYoSw0598xK6645I7nLzGj4MS6d1R2lV800 ; 20171122 ; subDT >									
//	        < eZOH09b2Q7W7k7QtmtN96MnxaoR10c50m5u1igY147x5h2rKG7CAAH967p36wsIl >									
//	        < 29yz42DkSga5D22xyUOuDwLUoYIKZo6d75K6VTh3fTFlO5C7Nag2bs92Tsoee7w3 >									
//	        < u =="0.000000000000000001" ; [ 000038471389598.000000000000000000 ; 000038480396571.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E54EAE8FE55C6CE9 >									
//	    < PI_YU_ROMA ; Line_3837 ; 7lVIpf5Y0m9t1Ig7Qzhltz638oW8HTYGdUzA3LEJ352dBrBa4 ; 20171122 ; subDT >									
//	        < 9HSfI216708mRivtCsyuOb97SLqxhc8TlQL9T0CD1bR06uZXegWx61m6I3kCk8Lg >									
//	        < 3LMdf1wcs7aj6X0dWXtG1WFr5746f8i9jO3gsnvS2mD1fN45m6AuY9quE7SE4MEt >									
//	        < u =="0.000000000000000001" ; [ 000038480396571.000000000000000000 ; 000038485954497.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E55C6CE9E564E7F9 >									
//	    < PI_YU_ROMA ; Line_3838 ; u5NpdZfPDql3e25FZ467p4hKL37Vt16ox56Ytg8T0jI9DN3z1 ; 20171122 ; subDT >									
//	        < AB0038Gv4Ka14V2hC5WPT4aT38rMTW5p5YVi7YX479Rk9lxbU8J1G7T00VxYoNlC >									
//	        < GT9jctoOolg4U5To0zfA3ymiBqDJCCq8NtWbR91ej9uUTg2JRT75127B4i4H6vf2 >									
//	        < u =="0.000000000000000001" ; [ 000038485954497.000000000000000000 ; 000038499394828.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E564E7F9E5796A1A >									
//	    < PI_YU_ROMA ; Line_3839 ; 7M583OaIs6c73JRL5f978o9a1evhhgZXE2t4hg0VFwCPU9S0q ; 20171122 ; subDT >									
//	        < 9362H2Pw4PfTLdzx6ZLw7FyJ60e0Y7Jc3Fw8921lldQWaqBkcK1VtX9JqdlQA6ck >									
//	        < n5pq1v5GZ60L8YoVN0GFV48Rfgl1LX1QslN7QDoYady6GN3Z4R1W5u8v95EF0RlZ >									
//	        < u =="0.000000000000000001" ; [ 000038499394828.000000000000000000 ; 000038511025708.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5796A1AE58B296A >									
//	    < PI_YU_ROMA ; Line_3840 ; sYl5b78j9mNQ8rSO4V2308080L5JGZJy4y3yID2W5Bxh9iSD4 ; 20171122 ; subDT >									
//	        < iUng322iiI705ayxoaKVW3weT34PD7DKAF6fZEYPU8exl3KeYN7NRKj99ezxu2Lh >									
//	        < e01pN7Z1yzl2gq6NZPkvzNO0f834w6K2A0McRm1oa6gG8yuh64a3RmplKI08jpxv >									
//	        < u =="0.000000000000000001" ; [ 000038511025708.000000000000000000 ; 000038520653751.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E58B296AE599DA5F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3841 à 3850									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3841 ; lU2H3VtqyuA3W77w4H0tv8az8k3R3Tno3MfqtbU6rxDpj9r15 ; 20171122 ; subDT >									
//	        < xIyX9LDthox762u8H8rWu43zrIm7WgeYy4V0FVok6Yvm52UO46C2zgE5to3nn0a8 >									
//	        < 6l0nX17VTS9J9WQiy3g8N56Upu796o4ukwdA4qCHighIOR930g4LDE03sVIPAGoQ >									
//	        < u =="0.000000000000000001" ; [ 000038520653751.000000000000000000 ; 000038530294335.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E599DA5FE5A89039 >									
//	    < PI_YU_ROMA ; Line_3842 ; g7C61T17yoDOVnvjK3OZcVsqhvE5XWF645CW4K95keBcrSVg8 ; 20171122 ; subDT >									
//	        < 1IHT19Cx0Vtcbh09R3I1UkHf0147KU0rcjDe9ov6qzmi68oOIy7MBQU57S4878x1 >									
//	        < 0GyozU1yMgAZS9799m15ea17Maw5iO59YY2u4OjwWvEHVDBxcBW6ptvd5gvdt6Un >									
//	        < u =="0.000000000000000001" ; [ 000038530294335.000000000000000000 ; 000038535346217.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5A89039E5B0459D >									
//	    < PI_YU_ROMA ; Line_3843 ; 3t7tmG9SMn82esF9bdrdladi49pG7YSQoFoD9LHj63J16dzCs ; 20171122 ; subDT >									
//	        < eA9xzDyj8xqP5goD4851VaID52r78k312Fq5zYWQ5h8p9217USv37xDY31oEJ598 >									
//	        < UnS8yjIoZm88C4n98y02wLXco7J32Amfrexa3MEXcDTsj55pNq33H295HuUy55H6 >									
//	        < u =="0.000000000000000001" ; [ 000038535346217.000000000000000000 ; 000038544248935.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5B0459DE5BDDB3D >									
//	    < PI_YU_ROMA ; Line_3844 ; W85QL8r5uoH1vVW9n9E580tD96p7Ow25xUP12NW4t8n9fjk8L ; 20171122 ; subDT >									
//	        < z2jMQK6X59SDhw09HOs8j545oTQYA7p3Yv353VQ5Ow8lSD8Tg2P946tel698pYq9 >									
//	        < tSz5RDVXtmL75a26371lB40NkZ0ANTIfHqb5Y5B4Dt5qu6T5kJkQ1MYUJSDGh73t >									
//	        < u =="0.000000000000000001" ; [ 000038544248935.000000000000000000 ; 000038551421101.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5BDDB3DE5C8CCDE >									
//	    < PI_YU_ROMA ; Line_3845 ; 9985dzDZBdRSl294fxY0q1cD17717u1hotA5aYiLFrCot205k ; 20171122 ; subDT >									
//	        < Ea2URx4702V6Q0MlkI7QUYIvP28DeG28Othvv3YP6z0854mkgw671sOm8l8mXVmG >									
//	        < s1iYvSbjdmrxVuj1Ihb0IRYl3xy0nwD63q3Z13JqY5sW27nN1Xa5n42hGwhBD44A >									
//	        < u =="0.000000000000000001" ; [ 000038551421101.000000000000000000 ; 000038559600528.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5C8CCDEE5D547F4 >									
//	    < PI_YU_ROMA ; Line_3846 ; kWRfD472L34mEp6Waga78gV8NOM50LqTgJ6619If4Tv44bA9o ; 20171122 ; subDT >									
//	        < 5i5EroaJW49zv6y7tyxEyy3G33dmGENF21nVBMii5VGS1Tx17m7XlD2p9G271vB0 >									
//	        < SStrrkP2r7MQ7e3bd2D16WIfjArcw118ccW9u7ALw08D231ZvCcUUpmR2e1g1wPO >									
//	        < u =="0.000000000000000001" ; [ 000038559600528.000000000000000000 ; 000038566466113.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5D547F4E5DFC1D3 >									
//	    < PI_YU_ROMA ; Line_3847 ; qJS0elw0pvR55L5SF4e8378OofeTADNO1uiWj57U3OJQda46L ; 20171122 ; subDT >									
//	        < ie4XWc19JDphgurQLg7GIreFPPqPw85gMp7yK5x8nw90DWW3HTawXG6r58AZWdxr >									
//	        < cvwhu3J6ab4tBSVj7M54Gui077zp5rihayN0vp4XO4nm7Z14vX1gojMmlT7MF130 >									
//	        < u =="0.000000000000000001" ; [ 000038566466113.000000000000000000 ; 000038580770041.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5DFC1D3E5F5954C >									
//	    < PI_YU_ROMA ; Line_3848 ; e3fZIhSvKQ0cOzWS0bGS0T58xhFMCrPi0nkFAkxme4Jk32trf ; 20171122 ; subDT >									
//	        < 99r1JKZ0IS7bUxp4lj9I00HdiWI1VP8Xi37B3m1RF5k6SYjYK68dfe4bA8v13mcA >									
//	        < LdO5a8rRu378uAuX2nsc315wiJ5arL5rha1y3oCYGl4N9Aw7tO4q5121u4okodlI >									
//	        < u =="0.000000000000000001" ; [ 000038580770041.000000000000000000 ; 000038590913051.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5F5954CE6050F69 >									
//	    < PI_YU_ROMA ; Line_3849 ; R4ORThLO297p3AdM6UBNw7CEsv9Er75sL2qTNKY1P4lUJikDE ; 20171122 ; subDT >									
//	        < n6P27nn03NDXXzn919lm34X9M2sXOI516r191f8Jc21qfd56UoQXO1s6BA6XM41e >									
//	        < eltsY3oLf9bWtEWhn3pa3Y76W4x52DB0539X0pkSV1f50832WTU9jrJ2pG0FO4Av >									
//	        < u =="0.000000000000000001" ; [ 000038590913051.000000000000000000 ; 000038598300677.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6050F69E6105533 >									
//	    < PI_YU_ROMA ; Line_3850 ; vYeNETGZk9e0NYLs3Eun1q180V9RwAXWOl270sw8gHqqF2RE2 ; 20171122 ; subDT >									
//	        < a8doo3nBCdu12YXyTNPr0AbLSsN6BRjL1fei9kSoS8B39oFBIwYb39081xAw80RJ >									
//	        < 10OvEXs9C7dx9FvtZJhWbwb0wq8zm8i86KvW56lkw2GO1C0byxou29753e65T64u >									
//	        < u =="0.000000000000000001" ; [ 000038598300677.000000000000000000 ; 000038609188877.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6105533E620F267 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3851 à 3860									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3851 ; Q8yh6UDy4l8MZvDOgvtzo6Fs39tXg6DnD0nW6Mr6E22zd35F1 ; 20171122 ; subDT >									
//	        < 3cg38iXvQelK6kmv0C765VTQMA2IK5E8v0Mvy3uF7rQieXU87KB4O81y92dLIl4Y >									
//	        < n69l43TU8DokAf0u7k2Guf0CF7CcsUW67cvE9J8Yy983AGF155sGyzzGdfO3AIn5 >									
//	        < u =="0.000000000000000001" ; [ 000038609188877.000000000000000000 ; 000038618427348.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E620F267E62F0B2E >									
//	    < PI_YU_ROMA ; Line_3852 ; 7uaRP557Cr4O598INnh56P8VGlHXw5GP3GZpP0WFRX2bYXvj8 ; 20171122 ; subDT >									
//	        < GidgyTY1lhb327884cmd3JRiWf5o4vE271xK59p2GKw7GQNln7F1OW5ffk0Z5w3m >									
//	        < JR0Q4I4t2re2bS1BNrXwqzc8Q26PrDKM42kU2IGUPZXO7o67L5bzdFy1cU33QvFM >									
//	        < u =="0.000000000000000001" ; [ 000038618427348.000000000000000000 ; 000038627875559.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E62F0B2EE63D75E3 >									
//	    < PI_YU_ROMA ; Line_3853 ; Zlo61bNOHmmuyizU3uC2ayFvCD6z59A8uAK5DT197D86vbKg6 ; 20171122 ; subDT >									
//	        < 276r1jnVBY4IM1h38tP9di6442es430YP9NFevn7bBc78iU7w33Aalv4H62b03FM >									
//	        < ZDoPcb363HQcj18Z4FBRN6lONE0iadwwseqW2W89JdUyK7P84zz9APNLm3jNE6dH >									
//	        < u =="0.000000000000000001" ; [ 000038627875559.000000000000000000 ; 000038642647199.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E63D75E3E654000F >									
//	    < PI_YU_ROMA ; Line_3854 ; NY766y7MF23AigCeYnju9H73Hv43yq91Mhuf559Mv18CMS86r ; 20171122 ; subDT >									
//	        < zYomzEpfTwC3I996GWYOVF5fhjxA2Ldtoz497wU7Oz1Ne85279BpSlN71vHLEWmP >									
//	        < 2h7FvzsO5m8tNJCy9KcBGaxMY5x8n93UlYW650uo5I2Gu9C7gVs1vfbI23XJ76n2 >									
//	        < u =="0.000000000000000001" ; [ 000038642647199.000000000000000000 ; 000038655105726.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E654000FE66702AC >									
//	    < PI_YU_ROMA ; Line_3855 ; b9pJq9h3k7sYJdGD3VZP5BF4e3CbElMIc2N3vG5dL0myTHOVX ; 20171122 ; subDT >									
//	        < 1uLTEL6G0bKIRiN1Iu4Xx6DQk5yg6ZsQ5319ueNZfhTJT6j2z0V7c24fHjXKVFVW >									
//	        < cFaU9fIxQxctY1J3VuYB7wFX5rmjcc2PiLfv99FhU16rWBP59T4Yv6yC3hP02r5m >									
//	        < u =="0.000000000000000001" ; [ 000038655105726.000000000000000000 ; 000038667526996.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E66702ACE679F6BB >									
//	    < PI_YU_ROMA ; Line_3856 ; 1r6oy9b5yZJh8VI55eF6gBMFj3XJB12ZQ6OoYGv7phVcA5WT1 ; 20171122 ; subDT >									
//	        < Tk63xGt8GGnx76qNJf6O0m3Kk2gNnk0h9j75NV77D0Tj7lmpG5Z6430CxdO8I41c >									
//	        < iaropzTcxlyXV944NA23DVjiXOd5ubp36ZIkWXR2Q14expC36h25P2Q9ui1p0WQD >									
//	        < u =="0.000000000000000001" ; [ 000038667526996.000000000000000000 ; 000038673919723.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E679F6BBE683B7E4 >									
//	    < PI_YU_ROMA ; Line_3857 ; 49s95z4UIyHJ0Xvp8Ep6LY3s00Y9jA9byU0ZKa9FSXWe5cQq5 ; 20171122 ; subDT >									
//	        < VNsRwfJoOL48qp3jTgdv3xygj88482bZ2o4eltOhn80W105AE737wT3l60Zd5YmU >									
//	        < 1fnwcFdv9y03C2aBZB1R8npP9709E52GYkVUSxR6zOctt294d7uy9cr6s5I2V2iJ >									
//	        < u =="0.000000000000000001" ; [ 000038673919723.000000000000000000 ; 000038683788982.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E683B7E4E692C712 >									
//	    < PI_YU_ROMA ; Line_3858 ; mIxDo18l65dqQdDxayXAFM1keVolRNYgBX5Mdoui4u3mTuA8b ; 20171122 ; subDT >									
//	        < NP1KggANw18EZA2brMBs3UJGZhEYALq0b53KMHSK03vXonUZsv1DJ2yW4RP869Bj >									
//	        < PlY2J2b46ojS2vVE8UT8R4mse3c6AcvBpq7abfqwi5JNB91TF5pO6j4fjqjiRzEJ >									
//	        < u =="0.000000000000000001" ; [ 000038683788982.000000000000000000 ; 000038697047217.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E692C712E6A70211 >									
//	    < PI_YU_ROMA ; Line_3859 ; qZ4x8NXZBVx652AMrIin55T352K95xlRD7k8MDmw699S270X1 ; 20171122 ; subDT >									
//	        < RD03p237YJcPA301GYaTzcZ8sgIhL69Z1g0YnIgFv6MfhsqN65tf33sk29NorX39 >									
//	        < 2XHD2B4NNQf3DM8SqOFp8DG0w3oEOb1Y2HghJUVB7ZsHZyfS7ISjT52A2ymY1w4L >									
//	        < u =="0.000000000000000001" ; [ 000038697047217.000000000000000000 ; 000038704880493.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6A70211E6B2F5F1 >									
//	    < PI_YU_ROMA ; Line_3860 ; 2PHvYNkz0Je0UGSu8T1ax7g71J367WP8coU3qe2Pfa3Lsb1sy ; 20171122 ; subDT >									
//	        < 7hBHQPljJFdm73tcLLzZ0QRBC3vAbcOdppXbxs9tS4q4vCy6rdCD79Qa24C48as3 >									
//	        < 9jKt0g0ybSLdsb8bb6L9hG1816Li7zhOC0iFGo9q7yQ8fZ1LA5FxsK4c1xkNx2Bf >									
//	        < u =="0.000000000000000001" ; [ 000038704880493.000000000000000000 ; 000038716448879.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6B2F5F1E6C49CD7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3861 à 3870									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3861 ; h07FZ4XiOD811UrX0LdkTdU8awPs57rNMc7zxMVvP82jw92cs ; 20171122 ; subDT >									
//	        < Wo81d388Lap82L7621N61r7vy8Y57PnPslNY14486us3eH44l62i23aG9f0e28Bp >									
//	        < 9LL3X1UM6oy2UoY4cYa1QYiUw9s05CE4B8K436g7Fc8s34c1FJ7DP0Y0366mz0Y3 >									
//	        < u =="0.000000000000000001" ; [ 000038716448879.000000000000000000 ; 000038724026685.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6C49CD7E6D02CEC >									
//	    < PI_YU_ROMA ; Line_3862 ; ndzt4cQ1hjuV3H08yta3g7F4A7jiO4Dau0c3X7qXsQ6KwU4d8 ; 20171122 ; subDT >									
//	        < XUF32svsojWa85PJ80FKzaHHo3Kb5MAW1dYrKjzO5UK1W3vy3z7n7Kt6D32sAgGi >									
//	        < pI8sdGVluRWknl1iQLG3206960M1vL4g93HeVFvKms9aEuB4V1WiNK3mxYS940EK >									
//	        < u =="0.000000000000000001" ; [ 000038724026685.000000000000000000 ; 000038729497433.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6D02CECE6D885EF >									
//	    < PI_YU_ROMA ; Line_3863 ; IOIB0H7Wi23lyxUaWmm3S2A3up7iazy2sNu9734jvFX3MQ753 ; 20171122 ; subDT >									
//	        < Uz4C993NPWpI7gN6JK6d5TJLoMx5LrAPju1Gq2l1C8RLHMRq3h2R5Mn9j0L4909j >									
//	        < 4VjxoT5ijylGGNo1F23z8CnpbH1xAx81Lkseb6Y5S27Fda4MtPkPfvVFuvi260l1 >									
//	        < u =="0.000000000000000001" ; [ 000038729497433.000000000000000000 ; 000038742545825.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6D885EFE6EC6EF6 >									
//	    < PI_YU_ROMA ; Line_3864 ; qvU62Lwd8M5d2Ong6IViw8JNSZ24tDgN14Qy30J1QydO0lZCI ; 20171122 ; subDT >									
//	        < 0MN7mT75zSm6wVTa2A1f0sJP09S1Aw9P9FZf2KhvHL3cB70m7mEB8NW9wX6HUfnj >									
//	        < JjC51C88S9h2S9iFz3G4ZienU5s7j5zQYqhyk1Tkg701YVRpaH0Xv930I6cC0A4x >									
//	        < u =="0.000000000000000001" ; [ 000038742545825.000000000000000000 ; 000038756344027.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6EC6EF6E7017CE2 >									
//	    < PI_YU_ROMA ; Line_3865 ; blq0Y5xEIVKh2K2HQb851Gt5h3oEwez3DJW418L585lYKBEvq ; 20171122 ; subDT >									
//	        < dad21Xq2U88xZr8KG2vqr3d84ZN3arBrG51vs0wWTrW0S9MQ2hvB8K28go9Y5f2a >									
//	        < 7reTW0oBBA7pRF2js15d3f8290D465D1HA90Zc77J244slckQT5OCp8goxg1k906 >									
//	        < u =="0.000000000000000001" ; [ 000038756344027.000000000000000000 ; 000038766625958.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7017CE2E7112D43 >									
//	    < PI_YU_ROMA ; Line_3866 ; 5k7JKGNzU58BI78vV2cS7p6jun5vo26VT7B4mJdY1Dfn273kD ; 20171122 ; subDT >									
//	        < lpxPkkp73XzA28cqS9y7uW0CFlu6h44BLh5Y9HW61DqUcGBf7j58xGPm0nIxZ57Q >									
//	        < JflzwJ3uz0Iwgm401b2acMV90MP4e8F156Y9spZ3NmIczgd3Aq07eZ7Tl658X6l8 >									
//	        < u =="0.000000000000000001" ; [ 000038766625958.000000000000000000 ; 000038778289189.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7112D43E722F936 >									
//	    < PI_YU_ROMA ; Line_3867 ; oBaIdgQx9o52H2fxaJdiU7UHcedyN3vBXL6D8VDPt55R6K2xs ; 20171122 ; subDT >									
//	        < p66SW3Zi75507IQ64fV39i8befjl16wN0R194z2IhOQ9l00omJvy99gXfJ3J55S3 >									
//	        < 8Ufrv3ep438x55WC5aJ3969lmqGQXw46jOUIA1Zsv2Y9zMAm1AjBoC1Tw1i19Xu8 >									
//	        < u =="0.000000000000000001" ; [ 000038778289189.000000000000000000 ; 000038785576974.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E722F936E72E1801 >									
//	    < PI_YU_ROMA ; Line_3868 ; BJbbvl6Q8tUp9CyIKsyL5B65U89br0A4mCRF7qAxuprs3Jw6E ; 20171122 ; subDT >									
//	        < nNe44RGGJs73cMcLue4M8JCONX88e4c1NfPS7BM9129rmXLAoMVsS4AitD5C5M1S >									
//	        < GkbHZL7ua1q6I1JNFS7eWa3sd7C5282TbFxP93520D3DtoI17B956tDWk6bDi48b >									
//	        < u =="0.000000000000000001" ; [ 000038785576974.000000000000000000 ; 000038790847866.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E72E1801E73622F2 >									
//	    < PI_YU_ROMA ; Line_3869 ; vsJFDi6lp7ex7K05jPjf3CZwqjf00fgG0oYutBw4sy1i68ls6 ; 20171122 ; subDT >									
//	        < 7qT0la4oodzFpGDIylZ7K7a5R2X8AQlw4a86E00m7XGNtSJh59274Cc9H0QdcVa4 >									
//	        < 6p4764b5J55K929DjwJQCqm39LSl85d5IEdntU66s6XFk71j7QRCL2bqKB04i1Dq >									
//	        < u =="0.000000000000000001" ; [ 000038790847866.000000000000000000 ; 000038801547197.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E73622F2E746765F >									
//	    < PI_YU_ROMA ; Line_3870 ; u5n5Rrr610G8ljoD438vZ280unF6H7BkMNpe1miSZK5278gTr ; 20171122 ; subDT >									
//	        < ovI050uRZW385cH63onyKbj5IRYcTwkg22a3pxZMt7u3LQO6FXaBfn80591mvS54 >									
//	        < wpXcDK5QTLyOgmkGg375gNUIS67564Xaq44WjIokvTy69u5vmGV7HFdrLY1ZG5yW >									
//	        < u =="0.000000000000000001" ; [ 000038801547197.000000000000000000 ; 000038813509325.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E746765FE758B714 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3871 à 3880									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3871 ; bKHggZ3rMr4bdQ6fbp5vtgVIykbVOo0sYc82x6cT9X582i6M0 ; 20171122 ; subDT >									
//	        < GEhsmueyB0XgpB8oZJKY1655ADUnGor8Cexn5V732SoYSdd5zRgt3QZtwo749KsW >									
//	        < ROVwvAOkUvtB9DfzuDPAmu29yo3Fk9y3LrmuTqzWXN39Nve81R6iIOLA7F0y8Ew0 >									
//	        < u =="0.000000000000000001" ; [ 000038813509325.000000000000000000 ; 000038820893689.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E758B714E763FB98 >									
//	    < PI_YU_ROMA ; Line_3872 ; OE15yR5ZiuKlBcbtQj02Y42677Fqq9pGq104Rys7SetNLXfJ3 ; 20171122 ; subDT >									
//	        < 4vNI8EG72ziA19OtcunPu0J9Y2ZmzYHcsI4ROHUmCjNi53V4AoOG6YZPO5gla8sy >									
//	        < H8Bl6g01rwF980X174iO9IGxUaZ0tL981o5C6zQ8bb2j6T0E5YxR5eMG2YcHdohL >									
//	        < u =="0.000000000000000001" ; [ 000038820893689.000000000000000000 ; 000038831203146.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E763FB98E773B6BA >									
//	    < PI_YU_ROMA ; Line_3873 ; R6HUZYdqwp8E43CCztVpryV6Or0MOYHRX97SsJf6j26epx906 ; 20171122 ; subDT >									
//	        < UZ2Eu6xLLsv4n3G7jN2us5Fau48C3AhcO7YsyZD5GCYW19Z2hQR4dfT7JAZv85A1 >									
//	        < z3s3IgylctJ0X2Olqmb6Hv89H4xnPkhq723lLphRXFawIlQ4vT5cBiP4um5PnZT5 >									
//	        < u =="0.000000000000000001" ; [ 000038831203146.000000000000000000 ; 000038838540540.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E773B6BAE77EE8E6 >									
//	    < PI_YU_ROMA ; Line_3874 ; HjkW8xjpHo9cgiud4d9uLsb65lqDm7p0u231cXHyprAbNS9b1 ; 20171122 ; subDT >									
//	        < oP0drwdH2lrKZ79EfzM2vJdwBOcjIGfTH58J94e1p5i18j3B16XQoOErx3wh732G >									
//	        < 9dOliR0BEsCK0F3aY2j1D9p381y7VWrT9Of9VvjUZYPisyAirAJ7dABLj45Pfg16 >									
//	        < u =="0.000000000000000001" ; [ 000038838540540.000000000000000000 ; 000038845409862.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E77EE8E6E789643A >									
//	    < PI_YU_ROMA ; Line_3875 ; t7FYKXIvglzm9chJmlFPMCPCaKD6z9Y7nCv49TL32tK83zJFe ; 20171122 ; subDT >									
//	        < DDpNAW22RKrB4a2p36k7278a3RIVasOR04n61Z0xW5wA61M7qi4K65pN9eqACqNI >									
//	        < AhUzP9yR3mDWLN3s5mVH9UWk42Ul98MwO9dX2j4kT9B5y815hj21o925K40U4VbL >									
//	        < u =="0.000000000000000001" ; [ 000038845409862.000000000000000000 ; 000038858846264.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E789643AE79DE4D2 >									
//	    < PI_YU_ROMA ; Line_3876 ; D1JQj276igdW453V3g0S7WkI0mShNxwo961TY3gX80P1q5ACw ; 20171122 ; subDT >									
//	        < 45hXOp20lDq9RWSbC577sNercqNqGAjGS1ZJmtGKnCh3YVi5bVgfy98XlF0JPW3B >									
//	        < 210F9tp3os91X1eMlS6Ktq8S7ER9u4M50ACuF5PYXW6911xDF2lL487vRMG8N0qG >									
//	        < u =="0.000000000000000001" ; [ 000038858846264.000000000000000000 ; 000038869621670.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E79DE4D2E7AE55F7 >									
//	    < PI_YU_ROMA ; Line_3877 ; 82da849cj564x2HYHv8Wq2g2huxA6kyUOe9E2gv669g5hng37 ; 20171122 ; subDT >									
//	        < oso4aR7kyD55rb7V33yM5y8tLyM8R397iE55sYwhkmvEAdMFF72s63guLUcfck4Q >									
//	        < 69e7EpY9SXT9Hllu0111a958p3vqOj3994gU2E8N46Sxrtdh1JPcT2L05zeYoPiF >									
//	        < u =="0.000000000000000001" ; [ 000038869621670.000000000000000000 ; 000038879873537.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7AE55F7E7BDFA99 >									
//	    < PI_YU_ROMA ; Line_3878 ; F6g946bBQaZX5AF451r47g3uFyH023b5GGxcgX5hCPPfl1Vb2 ; 20171122 ; subDT >									
//	        < Mk0hCyq44nHnjw0ogg40k1clCj62sOFc9dk2DWJOmUn81xbPa8ls13tQ5SL1uk01 >									
//	        < 1oLQFNgsNzSldA7qEP3h9441uMJ8x474qQ8zRB313eu5Yy7O9B3gi63lW1OtIN72 >									
//	        < u =="0.000000000000000001" ; [ 000038879873537.000000000000000000 ; 000038891565983.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7BDFA99E7CFD1F6 >									
//	    < PI_YU_ROMA ; Line_3879 ; Fn9V8jH16heJRQ1sgD0zB2UgWD5R0u15T67174FA6JXo4PxW3 ; 20171122 ; subDT >									
//	        < qNiN0teHH1vV05rRq17p1cuTe88QAHh2cG5ik5IIDfU52SZH45n3slaT86inUA69 >									
//	        < JZu44113C1h257B8Ae06n6C8L3jdO75V5UOk7w76Bgj679SKGIgA14ETXZk98exa >									
//	        < u =="0.000000000000000001" ; [ 000038891565983.000000000000000000 ; 000038901029728.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7CFD1F6E7DE42BC >									
//	    < PI_YU_ROMA ; Line_3880 ; dwtc760Ows7xpdG0Ls8oryw7FV9ZemH62itEQ7Ju5e91q8W7V ; 20171122 ; subDT >									
//	        < 14S79rGEpcj0tJvq7p37l2I21KD89y0OwoHj8uEbZskPR05kt79F76BSxHl6k8JF >									
//	        < U5vCVtzh2d2HnNSITjZg2W61s76bE5TMY771l4Sz6sFxtQjKuONCPx3F24BN1kHa >									
//	        < u =="0.000000000000000001" ; [ 000038901029728.000000000000000000 ; 000038909004340.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7DE42BCE7EA6DD2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3881 à 3890									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3881 ; gr3PM67A6ayJg5ek74GBj9J0R4NA697po8V3HO753YKNc705V ; 20171122 ; subDT >									
//	        < 63wJjWdC753z4OgD87G96gheCRi695E45ACwxbc9wcO1CZCbfW7HXv9IdoB9mmx4 >									
//	        < d4M9s23OR68F3l43P2Vg7fii749424ksZ7S0vLSGuoj3J6fy4tIU1DT6393W9SSu >									
//	        < u =="0.000000000000000001" ; [ 000038909004340.000000000000000000 ; 000038914785635.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7EA6DD2E7F34023 >									
//	    < PI_YU_ROMA ; Line_3882 ; k29PGlTKjHjwD15hVO93H42swPnSNYV8gbJE7d8fg984C76Y4 ; 20171122 ; subDT >									
//	        < O2EZf4ZcXw74nOqBncEaCgCyIyMGESyYXvD762i0759nAq9iJC1261X0YRHk5FXu >									
//	        < M5jbDS4H4T71m9u4yeT5AKh1LBfrWd5Mv97j6P2z7I2sg9I2B5vuQlvFkVFj5F0i >									
//	        < u =="0.000000000000000001" ; [ 000038914785635.000000000000000000 ; 000038920244518.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7F34023E7FB9483 >									
//	    < PI_YU_ROMA ; Line_3883 ; 2z970m24HGc5mBl8j2e4J243sm8h5ElkoEXhhPL0thz1kiC2U ; 20171122 ; subDT >									
//	        < UGNW9tL5p009G583nyLAXwWfyj12YPb0dZd0752rMVw2hoK780j4esK2ivZKHX5h >									
//	        < m44USCQ27585IIT716lM0D8Y5WPYA13r9W0YWi7Hb8d387UL50uNRxszj7m7M77p >									
//	        < u =="0.000000000000000001" ; [ 000038920244518.000000000000000000 ; 000038927977950.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7FB9483E8076163 >									
//	    < PI_YU_ROMA ; Line_3884 ; 5D4sj8wiTpWGGLYzRaN7Y6uJK7lI49BKoW0S5wg7sLknr0fC5 ; 20171122 ; subDT >									
//	        < 6rpu7f9eNvs6sc02m2VU1mkHYnn4RC8icw28lnbHZFG4hgZwDqj84zH7m73qThiu >									
//	        < Ay8xFadqRkQrR7i4P5t5P87q49pUYcb50ho4c4zF5IDbVu71015m62dP7K10967e >									
//	        < u =="0.000000000000000001" ; [ 000038927977950.000000000000000000 ; 000038936453842.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8076163E8145048 >									
//	    < PI_YU_ROMA ; Line_3885 ; OFP30u39yHGuniQ78W4YX1i364PeHr9zdtZh4zeP23S8OR2C0 ; 20171122 ; subDT >									
//	        < 0f7zbLW2bzld7rE8WQbLw4bNu70HM5n95M59Whyq0z55RnyZVEXA76e5lWEPC4P8 >									
//	        < CwECelE9Shc37z0l0rOBP8MTD6p6oJ1GbJMg6UJyx95uZytJj56S6KmOf9W4F5kk >									
//	        < u =="0.000000000000000001" ; [ 000038936453842.000000000000000000 ; 000038951237109.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8145048E82ADEFE >									
//	    < PI_YU_ROMA ; Line_3886 ; ei2ktN20oBDGjqhkyYo5M1DK60Nyw7W8VfxeP99HZO8R718NJ ; 20171122 ; subDT >									
//	        < ZVqWl9HyWrY0f259B8ADPZF2ioJqv345cq6opn3a5w6o6hLHhyXU2Eq6KBIU96bl >									
//	        < 9e41r2p8xckLmKLLJJmp3uZFOrQg8Ky37eYABOz23BOi8dUv4A5p1M3C6l483804 >									
//	        < u =="0.000000000000000001" ; [ 000038951237109.000000000000000000 ; 000038961118446.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E82ADEFEE839F2E4 >									
//	    < PI_YU_ROMA ; Line_3887 ; 233CdF3wQ81k874KKyga49X4LW68qA5ccek250OLaoqk1Qly2 ; 20171122 ; subDT >									
//	        < uA2twG9H45S9E2x5aGwSem7h9MBKoE5HXZG46ygH4Yq43qtJvF7lI7n9crH7v014 >									
//	        < RjOXQ9jK6oy4EKorWnG2Rq0vf8u7KyWylU7uc3rzK25G166nhertF1B1dPx0cgU7 >									
//	        < u =="0.000000000000000001" ; [ 000038961118446.000000000000000000 ; 000038973087778.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E839F2E4E84C3669 >									
//	    < PI_YU_ROMA ; Line_3888 ; S1Z7Psg28bB9PR4ZCxYi8R0FYGu41B7Di5irAIddZdT37Vn4F ; 20171122 ; subDT >									
//	        < xXf02oZ041x90uocTz44AyaTElMO9101IU2O2B78I8qSu32cUd8NO5sFiF15MVWV >									
//	        < U86iH7j1vkJ58lhSdqZXV76S875MwQ2NTR6a5HZ5nMfrRLchmLdpo1CnQReLm23s >									
//	        < u =="0.000000000000000001" ; [ 000038973087778.000000000000000000 ; 000038981721160.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E84C3669E85962D4 >									
//	    < PI_YU_ROMA ; Line_3889 ; JRM0teCZFynbKH5g9CDkkdPDTPBJLb4Wm0B5y31lKPLc3EIbE ; 20171122 ; subDT >									
//	        < 77xHKMd72X7P3ytUEYb6TSIi4GfS6252BO9byymQXRLveq37pZtk1gRpmX126ToW >									
//	        < K35371Y9aftx1fEY0n39aVyL18RcUPG0B1x2mOy665b3L9juJ0aT92L6IQn4ag6x >									
//	        < u =="0.000000000000000001" ; [ 000038981721160.000000000000000000 ; 000038996520019.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E85962D4E86FF7A1 >									
//	    < PI_YU_ROMA ; Line_3890 ; ydJ15gxJUk82UqeZF99O5UhdCr3l74xBBlT39Sm2A85g8wKTt ; 20171122 ; subDT >									
//	        < 3zaX2wW5O4cyr0K0vK3Xh1HdAUf99p42292Z18uG2i63hGezxg8syR4sOCJFmW6H >									
//	        < K61ZcrKw4Wsu3P9y5b125nLgmH8cb90dD0aGD0wwYqw3b1xGqjFTicwqBdf6GeE0 >									
//	        < u =="0.000000000000000001" ; [ 000038996520019.000000000000000000 ; 000039009924248.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E86FF7A1E8846BA8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3891 à 3900									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3891 ; a6JvYlQMyXEGGIq929y1U9l5H0795oP7PDru7sD03HEFwxESu ; 20171122 ; subDT >									
//	        < G18V7N1r2Nk7q6pXObYB44ka3cn4sDLnmknTMWjN6AbQxOO4BALZJY3SLP3q15w5 >									
//	        < 8S6YcJsc4tc5w868SjQyRhOJ2Ofy076V425XYi144rLMZ3yvRxkCNZQ2hgIT0GGZ >									
//	        < u =="0.000000000000000001" ; [ 000039009924248.000000000000000000 ; 000039017655246.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8846BA8E8903794 >									
//	    < PI_YU_ROMA ; Line_3892 ; MwF0i3C29nr0JVIV9Kos3Ue0IeDp58lKm2shMWU2ub21FGTSD ; 20171122 ; subDT >									
//	        < O82Tzo7N19vo73iydOtOuJR6VTJJIL2e4XapSGpuYQ7s1LFFEUfd7NqfecyeWVIO >									
//	        < p4R93MI55tNMTno8B4I2YftKeKe1oaB69qrjcy73l05L9V6fbvFlF6ASoqNx0l3D >									
//	        < u =="0.000000000000000001" ; [ 000039017655246.000000000000000000 ; 000039023220054.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8903794E898B555 >									
//	    < PI_YU_ROMA ; Line_3893 ; 0LnN9NkwmIGeaoR9AC4251W5j458x4aKDZ54r4ox0v7wfSZ0Q ; 20171122 ; subDT >									
//	        < YjmbSqN2TKDhFyoTsrlZGvR3g51IjN3ah1z490yUVtMW41u58wc4nU5dc3T0G289 >									
//	        < n1r7V37ZPeJZYEcHl6pt8t9ejQl515K48Lo6d149kGxnj4t2Dh4e7TsXtDcXzf60 >									
//	        < u =="0.000000000000000001" ; [ 000039023220054.000000000000000000 ; 000039037885549.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E898B555E8AF160A >									
//	    < PI_YU_ROMA ; Line_3894 ; bi44Z5G8iknr10jiFsOX6oXnkon2TI48XBm831SALjL0Z3f98 ; 20171122 ; subDT >									
//	        < 00rz6lsuhiqeSEn22Rl3HR9l6bPX4Q15X9V8g0APBXa0TfOU6a6rrLg0y0tkt4VR >									
//	        < 002BAnAMFAK25GBK7245SlF0vlofQknGO3AR9uE8A4z0T82112g0SjRt6p9wyhSr >									
//	        < u =="0.000000000000000001" ; [ 000039037885549.000000000000000000 ; 000039043461307.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8AF160AE8B79812 >									
//	    < PI_YU_ROMA ; Line_3895 ; k8m6X5KQ96b6ov3Orm7eJub4DGI94ffvhW74dZyA3RUCuOC0f ; 20171122 ; subDT >									
//	        < U5Ur8naK2A7wmdi02ZirdP3A8vkei93sFt6ukbAv4Hk6r2B8nWHyx3lRDIbaIpGN >									
//	        < 8Mp7Dpp0q35Z6Rcb7vCIZCPIBxz0IEqk4VNVdeB5m0uORqmYnR5mbQzZKoIXVIhY >									
//	        < u =="0.000000000000000001" ; [ 000039043461307.000000000000000000 ; 000039055407532.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8B79812E8C9D291 >									
//	    < PI_YU_ROMA ; Line_3896 ; 3Cp9m6y0RH2aMY8kXEqfL2iZ2fNMgoD4S1UXuXckAGnbq9j19 ; 20171122 ; subDT >									
//	        < JZbYDL55gqVX622Fk9qNcerAD09DXKNNYLD920sNISsRZqW1zM9hBB2bmM00Y0kN >									
//	        < m25LKmOlqbQEIxEcir1BZAHtCpH0s2R8VqBIojtTL15NOb081juk3y91wQHV1JT3 >									
//	        < u =="0.000000000000000001" ; [ 000039055407532.000000000000000000 ; 000039064452930.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8C9D291E8D79FED >									
//	    < PI_YU_ROMA ; Line_3897 ; fF6VJuQRJ5GFM49GyjgOPepMe03OI82i0Ef7BjMFaYY6kQ96R ; 20171122 ; subDT >									
//	        < q463HVGsX3dHrAcs9wa4gM2y5G8QLqM082G6UBzir075ywwGM9KSqRP94WhALzfF >									
//	        < qEv8HX65OBt0ND841vMZz8gOHo3J8Ur90nPeAHYkpsxH55JTSney0sOIeiZESmn2 >									
//	        < u =="0.000000000000000001" ; [ 000039064452930.000000000000000000 ; 000039070598371.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8D79FEDE8E1007D >									
//	    < PI_YU_ROMA ; Line_3898 ; Enq051343JqwdjzUN9tEcQV5qgO6Zjv2mm42e340MjcdU3ix4 ; 20171122 ; subDT >									
//	        < 23hRfU8xbzEo19x1us0lBnCtQ78O7iuVqoj39D126Na995s6L1bzT6oUA1KrfOgu >									
//	        < OmIT4I5Qh4M2IztE93PCB2pAvy1C4Wzd76G0MH3l0XRTWg04TLXimZV8k66FLG3V >									
//	        < u =="0.000000000000000001" ; [ 000039070598371.000000000000000000 ; 000039085213075.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8E1007DE8F74D5B >									
//	    < PI_YU_ROMA ; Line_3899 ; pNx2A31po9Zsr47WK1464vO8232550ML77l90KR47GqsPWZS3 ; 20171122 ; subDT >									
//	        < 8XY2KQCS6xwo9L8F6nyqHkN6QEPX3e6JkO9hMCP2STnf151LBk799v0E78146T9y >									
//	        < GIGdbiWa607N6Iw3lgIHWUEkT9EH1d08V8ovagqV7jRPC1bWm3l6X6fSQM92R5kP >									
//	        < u =="0.000000000000000001" ; [ 000039085213075.000000000000000000 ; 000039094642516.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8F74D5BE905B0BB >									
//	    < PI_YU_ROMA ; Line_3900 ; d0f3xZl3Ql8TwO1926Nlo68vZ3fZZ20MvrD9Qv9MbqCC9lmS9 ; 20171122 ; subDT >									
//	        < a583w8u3LBHUso4geMX1bSBFCEJauHFLu9oSKD6MCAG4V91nNLe1qk73UX80ZtMh >									
//	        < sFpdFk0yqF4fiu6VU4QeILC44F9DahDvuC421phLAM0z3v91EU172tz9PfJt2R9i >									
//	        < u =="0.000000000000000001" ; [ 000039094642516.000000000000000000 ; 000039101028370.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E905B0BBE90F6F35 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3901 à 3910									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3901 ; eyC4fWu32i8K2fltxZS528B15Oi29U6a6mj0BJIn9he80xqPO ; 20171122 ; subDT >									
//	        < B2p0n9q05Ch4unHZKmNpdQ2KT481dsK7FeT7W8o38C53qM34KyfZL7d7raIyY91h >									
//	        < Z45D2838u58Z6yGLL0zT7k8Xii7k7Xxd9qYKWQ3YajNNs1d3K28PSYfp8WNwcAeU >									
//	        < u =="0.000000000000000001" ; [ 000039101028370.000000000000000000 ; 000039109035493.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E90F6F35E91BA6FD >									
//	    < PI_YU_ROMA ; Line_3902 ; 89Z4n58R97OU5uUk4piwM34Y7u3P27aG56O667aKlco9r92zM ; 20171122 ; subDT >									
//	        < Go0AE6Eh6ElQ3G1lmQ9dUY6i7I0ubgG59k1D7zabxh9Dvyr009fkdV6Wy92uTvX5 >									
//	        < O2T9So0rjP6dRb0hy84L9dVqexI7TKCFfC8JL1BgNms09vyMl43KI3u6mAWaQ0Jj >									
//	        < u =="0.000000000000000001" ; [ 000039109035493.000000000000000000 ; 000039118491484.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E91BA6FDE92A14BC >									
//	    < PI_YU_ROMA ; Line_3903 ; fbP5oZ6jC05wqr4zCV88WFUXWd478H2E2xT2jU44zGj654ag4 ; 20171122 ; subDT >									
//	        < 1Tdq7aAq4HVIX0lx36J0P08sylmp8qulKv72674PGOj807WAm8hg3NrQNF675U6e >									
//	        < FHXkyum76WIq35uMrGMLUclJLpp0nE26Zx311G50eNGU5DhyGr61kp2yjYwd3DdH >									
//	        < u =="0.000000000000000001" ; [ 000039118491484.000000000000000000 ; 000039128869796.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E92A14BCE939EAC3 >									
//	    < PI_YU_ROMA ; Line_3904 ; qm1c2Xg80bb5jx0wT79Haqh5O3SjQTUv1AzE7m5ljme2xje0H ; 20171122 ; subDT >									
//	        < mL153gO11Yp0aB5Mbf7QP9l5r5D8aC1jSiUd6Yj6s0b16YFd2c60O6mnfPk0CbIv >									
//	        < 26C0sfmCA1UU7XmgAQjuuc3fzh1mvv2Z4waFbFlNXalfUMuC790yV6A4QLY307vF >									
//	        < u =="0.000000000000000001" ; [ 000039128869796.000000000000000000 ; 000039134178329.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E939EAC3E9420468 >									
//	    < PI_YU_ROMA ; Line_3905 ; 587Bmyzkz2t9ohp2S6W2c36E2M6o4yl9I1h6iH8393gTvhK5t ; 20171122 ; subDT >									
//	        < R30dIEjPyCvcy9Hv6Udq1kuGS493ZuXc2c4W9kP9p1jf5XPn8g4i0X0IX1PS7J4U >									
//	        < E166pgiSPhva0RFiz8qXHAbJ3ki5Khmy36eh36898C1y1ln8Ero1sc63Pz8sC4AX >									
//	        < u =="0.000000000000000001" ; [ 000039134178329.000000000000000000 ; 000039143008205.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9420468E94F7D94 >									
//	    < PI_YU_ROMA ; Line_3906 ; 401wY5F4blJF6Tl7zHwg8RZ9Ju232A3b6hxyBMgZJAGX4RJ2W ; 20171122 ; subDT >									
//	        < w3I7Isg679ifnXBtTFwu2O097hI14WD0rcwyou2SrewKjr0EOHb6XU5ood7CQs62 >									
//	        < 0ilimRi58JzImxT96Q5Qv43YU2A2e9AiUiGlVby7ej7suPwsoQGZ8bFgNxT4f2XR >									
//	        < u =="0.000000000000000001" ; [ 000039143008205.000000000000000000 ; 000039152055130.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E94F7D94E95D4B89 >									
//	    < PI_YU_ROMA ; Line_3907 ; T76G7RF1DNfYTM5Ox7I17LYuXsL9L016RW3U3E1zVbj4zf65V ; 20171122 ; subDT >									
//	        < LBYfQ9isL0uupNOu8y3Ku6bVbv8LVKrG1NUD76BP6RB46161QFoohD7jsCeVik23 >									
//	        < r2a37YKx5Y23JE2olXf85ubZ0I0uQ2WXneXDOjAyzr13kxXWcbIeYSdu3xndlxE8 >									
//	        < u =="0.000000000000000001" ; [ 000039152055130.000000000000000000 ; 000039159103295.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E95D4B89E9680CB9 >									
//	    < PI_YU_ROMA ; Line_3908 ; 1BU54K19N3D6YMMUGqa7GuF4ac5xwyxk19aTs97W3rM6QlcrS ; 20171122 ; subDT >									
//	        < pUpfqQ5W5M2QAG7xP3N6PDN33G0dRX8qW73UsGOsbnulHAIE07c3G8xd097t5SOB >									
//	        < k6f8tGitr695bnyu820pb1I53H7iH6541WbUZU2TP1c5h5kOWL2o97bDrGyes423 >									
//	        < u =="0.000000000000000001" ; [ 000039159103295.000000000000000000 ; 000039164585885.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9680CB9E9706A5C >									
//	    < PI_YU_ROMA ; Line_3909 ; e27w6ryrk88c9p57mJDOT8EM9zb0qibEVuZij4x5nW9rbJ89w ; 20171122 ; subDT >									
//	        < Gh5302C5y0J5E12gcYcQ7IDkJFh6wi0WyZJBn84MSLj1ZQv23KyWuH3NPOKhhMZj >									
//	        < 9MLE3hIlR11uLqDdVxGQ946p6MxebV8E1krnWHH1HibxpEECI575HD6oAg2sl825 >									
//	        < u =="0.000000000000000001" ; [ 000039164585885.000000000000000000 ; 000039176868967.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9706A5CE9832870 >									
//	    < PI_YU_ROMA ; Line_3910 ; YzVU1ehbZmufV931FoIF7TM8oP32XYq48zzR811g70z17b03y ; 20171122 ; subDT >									
//	        < nrEQ54o1AgRfntT1gfIDP2j2PK9k2Wq5qhKW7MXou0VRE8W2BAju5U2cwUSIdA19 >									
//	        < 9u3ZWPjhosz3a5g9pDZ5068O472OC74GF00XZ40tG8BKYzB2EkJ149bF4gxA8o4K >									
//	        < u =="0.000000000000000001" ; [ 000039176868967.000000000000000000 ; 000039189824353.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9832870E996ED23 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3911 à 3920									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3911 ; 819TtKuLsSz1vOpwDd0W8fuP7sO16B8j4S6Y1u3K99FlmNoUb ; 20171122 ; subDT >									
//	        < z0C2W5rloOX7XvNTdFbYkr6R5CD0f43nH9ZhB7O85rShR53NIiZLe2a3pS9jtM9a >									
//	        < 4FA49XoPBD98CZn0XN29X0RPGx4d0z4qCe9te5lKGhqEm6qaveWMGt21kAOZ99N2 >									
//	        < u =="0.000000000000000001" ; [ 000039189824353.000000000000000000 ; 000039197829648.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E996ED23E9A32434 >									
//	    < PI_YU_ROMA ; Line_3912 ; kTCz56cdo7anhQoA52Sf4j6w6wmFd0Pk5F99bEgWnIZH5y0Qv ; 20171122 ; subDT >									
//	        < gM75s40o24uKfiMHBsCz9zqx4mohqEGDR153a781H2YXxQStMUl9gFUiw8k8YOi4 >									
//	        < u0A1Q85AIg5CL2Rwl91iKRDJ6Drz5a9lrP4Bu5AbSf2IZxx8j4dIUaW3A99w3dmJ >									
//	        < u =="0.000000000000000001" ; [ 000039197829648.000000000000000000 ; 000039210827623.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9A32434E9B6F98A >									
//	    < PI_YU_ROMA ; Line_3913 ; xk7q0SshEUKvtLeCUaCJh2RWtSu0Z757GS8mqutOcD01033BW ; 20171122 ; subDT >									
//	        < 1311M6M2hdNywh88S803lpz2BWERTfD702Zs8Hm2i8kO38qz8M53j9lCq6625VrM >									
//	        < A7b4zLVHwCTiiL73Olvg56yqCD0frip36c7RjcNaSdMG1WFcvg2KV0DUvFvRoH2w >									
//	        < u =="0.000000000000000001" ; [ 000039210827623.000000000000000000 ; 000039217582687.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9B6F98AE9C1483C >									
//	    < PI_YU_ROMA ; Line_3914 ; 7w6Dol06LP42O779NkSrfhp7o7c8hXSN2jB0664V0Bepxka21 ; 20171122 ; subDT >									
//	        < 8JWt2ql07njjX46nAL5pHVo6Qx417572S2Q36yN53FLvbf0gQ42FJ2m04YuA07Kk >									
//	        < NfSSUWKkw577P1QQ4c50Lzj57DiniCjX5em0CnJ50Fu3a2l2r76b4416QGvvOq0L >									
//	        < u =="0.000000000000000001" ; [ 000039217582687.000000000000000000 ; 000039226593287.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9C1483CE9CF0800 >									
//	    < PI_YU_ROMA ; Line_3915 ; V39tjIjSr7tBPWIOiWnLqCqwF8BFE9tu48k0LMBJTL64g2N73 ; 20171122 ; subDT >									
//	        < e1L0uDJrmOlOImoBQbUawC2ted261ReDqx535rIwP6Z42iS3z2Z1bjKatQ39dk5j >									
//	        < UzS8ZTYd5JsZy8W76DasLLH8ZlXExr05CvU93waMX0b2jFT291IiH9e79SDH5F9g >									
//	        < u =="0.000000000000000001" ; [ 000039226593287.000000000000000000 ; 000039232310801.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9CF0800E9D7C168 >									
//	    < PI_YU_ROMA ; Line_3916 ; cY7uGt89MT5STVj68M1A509T5O0dj5I9weh34UqHG86o11ZXn ; 20171122 ; subDT >									
//	        < uGHc7b1Q5ugolGojnjmm0UzV850Hn8p9LP8624h8kqtRJ660l26I9aG2381J3A35 >									
//	        < 8uYbeP1gZ7x868GtNIIdp5L84P5HRvIS7Crq12f1Es13p40vvGrQyB1SVZ2M7zxb >									
//	        < u =="0.000000000000000001" ; [ 000039232310801.000000000000000000 ; 000039245416334.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9D7C168E9EBC0C1 >									
//	    < PI_YU_ROMA ; Line_3917 ; VX1V2Wq15OTr3o4wu1v7BElFSo5m3rIajzQ2gvJuj5761jwr3 ; 20171122 ; subDT >									
//	        < 3F8Z1xpOrtsmMu6ypXk0E5SsvP1Y0TJH9N2O7sCabU4cyMAMW3b7hQ4F0KX89N3S >									
//	        < 7BF97nWGV76sUhGJkpNt7ri5DJCo9BqlNP636obrpc3Juu0pO5ev0pOF82LXR83n >									
//	        < u =="0.000000000000000001" ; [ 000039245416334.000000000000000000 ; 000039252523696.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9EBC0C1E9F69911 >									
//	    < PI_YU_ROMA ; Line_3918 ; k0V97k7C0O038xNZTMXt179Dxsd0BO8WC6TlGEK6C6Sol4s7i ; 20171122 ; subDT >									
//	        < dFcvxQ55lbX7FF8D5n90aF8zDXXsdy3p6V4a039qa197Ht8e69ySk83nuXm57IKQ >									
//	        < r997F3V7736my5Wu0vYwm31qe1wvvKp1PNE8h47DU7kNIbXt2cy665gdxdZ4wUN4 >									
//	        < u =="0.000000000000000001" ; [ 000039252523696.000000000000000000 ; 000039259237912.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9F69911EA00D7CF >									
//	    < PI_YU_ROMA ; Line_3919 ; G0BasC9IYih9vG3aRy7R036JhIbMvLlw25vr6x5Db1Ai78Lj9 ; 20171122 ; subDT >									
//	        < SN598dEGu8vFqR00ohBVAFJYSjK8S2brxRh3DC475Bqf3g4yO3GXZeTi962A61g4 >									
//	        < x8OrYy21nXccCgJ7176cF1d8rwF9s2Q8o8c52G80dt8t6r7506Wv10e957uIu6ig >									
//	        < u =="0.000000000000000001" ; [ 000039259237912.000000000000000000 ; 000039269905195.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA00D7CFEA111EB7 >									
//	    < PI_YU_ROMA ; Line_3920 ; UuaYSmOvlcd9qv2IrJKKhm9JZ5Bl4hh96iUpFwm7gl3810G95 ; 20171122 ; subDT >									
//	        < rgiUO4cURA97DV6is7KfGHBnccw9grLcaIFYauAqzI4GxK205h5tx0E2190AjkrC >									
//	        < V8i089H8LeP0q08biZEwp2W3Z60BfFj33T3KHh2BNIwt28P92k31zsB2anc69jP8 >									
//	        < u =="0.000000000000000001" ; [ 000039269905195.000000000000000000 ; 000039282532999.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA111EB7EA246373 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3921 à 3930									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3921 ; BtbBq0sAhLnAX90Y93mXk3T0IvTEvk7CJlIujuq7316378S0x ; 20171122 ; subDT >									
//	        < J2N38LoaGs787i6C0Tj98yscCOQ9Xsk4d8Ca5lX75QyAW37mwzDchy7KWbAyq7Z7 >									
//	        < 95e0t6Oz80d72q2ora6zACkk9KFk65E0hX3vhw4WHBnF1uv4qImmLrvp81v4FWU1 >									
//	        < u =="0.000000000000000001" ; [ 000039282532999.000000000000000000 ; 000039296217292.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA246373EA3944E1 >									
//	    < PI_YU_ROMA ; Line_3922 ; 48arr0T3QD71W41i6rxV6KpiS5oH493oT8U323K7YINd2ItcN ; 20171122 ; subDT >									
//	        < 420Gwx8DzmVNT76bl8e98AU9HEB2tRY4iSXK3Mo8jg9C3M1u4715Yi35QcRgR440 >									
//	        < B5ZrR24401tBTD9k0t6QekkJ646092gu8Ko29CZ2r1WS5ZP5aiKO809791GDxDr5 >									
//	        < u =="0.000000000000000001" ; [ 000039296217292.000000000000000000 ; 000039309355871.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA3944E1EA4D5123 >									
//	    < PI_YU_ROMA ; Line_3923 ; zfMROk77Lp351s0go2yqKSC77NM3C6wgndda1LYdj4j0URvBM ; 20171122 ; subDT >									
//	        < fURKF8t0AX5t3lhn6z7I840K9t32o1G1du99EVQ6MN37eXyjMAsiPEAk13kJ009w >									
//	        < 90o5cq43v3U3OK3tD0JHnAl8PQsLHoMOm05k9e5G275Wa8DA8xEnZf379bs7ol1t >									
//	        < u =="0.000000000000000001" ; [ 000039309355871.000000000000000000 ; 000039322342968.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA4D5123EA612238 >									
//	    < PI_YU_ROMA ; Line_3924 ; 2W4Xh5UVokS3D1ne5s7O15ZjKADK3kAj1F8pwlbgk9u8hs7Gx ; 20171122 ; subDT >									
//	        < RuwtP6391Yf7DZTSrm02XLoySF81GZOK658OEhyI03dprHftc8yOevNySne1adff >									
//	        < R0Qo48EIuRq5o1JfCOieN8tE13be5810kreDLM0lo0Anris2AfjP1gGug2i0BZPv >									
//	        < u =="0.000000000000000001" ; [ 000039322342968.000000000000000000 ; 000039333699410.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA612238EA727655 >									
//	    < PI_YU_ROMA ; Line_3925 ; x9jdTpDstU52ZCGBx5vGr12X3XwJmGW39s4n1C5I1UP37MYJT ; 20171122 ; subDT >									
//	        < i31xp04tdNZI6TymWiUIRRjs2syr01i938DvIZg6N0dViu5UF4Vtcdyaq8723tSx >									
//	        < RVmuweAwb0p3ozBKfKBIyb7QsZnt0KYatmvB712Y5391J2A8lyWu784u3k1E6S8b >									
//	        < u =="0.000000000000000001" ; [ 000039333699410.000000000000000000 ; 000039341203321.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA727655EA7DE98C >									
//	    < PI_YU_ROMA ; Line_3926 ; glx1iRpfuKgrdZqR3i68H5V5wrl43Rle34NDqncQRT1Te882K ; 20171122 ; subDT >									
//	        < ub2mU00nF9t22wFRSQZx76G1b36DbJOf0003xW59PnWVOggd7J2T13gIswn1g4w4 >									
//	        < C62mWFu547rRqqJV8tDKPi13YhcH15S59RhsV4V6lUv5M9RXX5e22iDbgZ1gH2c0 >									
//	        < u =="0.000000000000000001" ; [ 000039341203321.000000000000000000 ; 000039349592992.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA7DE98CEA8AB6C3 >									
//	    < PI_YU_ROMA ; Line_3927 ; x2KSDQ52oGU1Uo0icBQOrP129NuC6w7S0036nQ5JY9p9vX8Sv ; 20171122 ; subDT >									
//	        < 51s5VURpMRZ8QN3cc1c6R86e3E97gQ3tjU303TB8hu6hxTR40P1edczh504hsJxQ >									
//	        < 555Ab75xTO8CdsZHH8S1E9T2S9Y5bu0v3Hpq9lnNbfrWdEFQsKS3v1A9oItQBSPJ >									
//	        < u =="0.000000000000000001" ; [ 000039349592992.000000000000000000 ; 000039358470366.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA8AB6C3EA98427C >									
//	    < PI_YU_ROMA ; Line_3928 ; 7P8R8uNA6IGQ031iS2HAq2k0C4Ut2l6C8S6y00A1D6711USt3 ; 20171122 ; subDT >									
//	        < w7cF9N7970N5KmFF684QeEyQbB04ah2cA3cTGB7WW95K0lMGKMrMn698M1SxaAab >									
//	        < 6KIjcpUMs13zTS4KY67l4lh7vP965CR897svJgr1jM9lZwUBXH41N02IP4XyNtV8 >									
//	        < u =="0.000000000000000001" ; [ 000039358470366.000000000000000000 ; 000039373331832.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA98427CEAAEEFBF >									
//	    < PI_YU_ROMA ; Line_3929 ; 6jH258r0c3Rbd2UGLh7l075l452iIa10Dz99dqft6u7H2hUgm ; 20171122 ; subDT >									
//	        < D6y38RkhB5l3QB5s2nQi36sI0eGd0Ld6tT03PQOM69dy90oov5MM01rbk5443M5E >									
//	        < 5Z0UcKR159164p4Xc30BL5uQf2BbvJ0ie95zXU9V0CeJvZPih091qqPFu3h65NO2 >									
//	        < u =="0.000000000000000001" ; [ 000039373331832.000000000000000000 ; 000039379517495.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EAAEEFBFEAB86005 >									
//	    < PI_YU_ROMA ; Line_3930 ; 63Zz7D1A4svlsvgSha6066nmqzt69779Vucjb5ni5c85ev28T ; 20171122 ; subDT >									
//	        < 3f49yPm4uiok822lWXG82CML22WYBW5A8e9iL8v16Ynr4P8MkdYKNNqjJEk0h6D8 >									
//	        < PynEY44adS2G7232uMwnhOaCX9562yBNyw3OgRHY58eDUiv1EDLLL7mXMH08KOx2 >									
//	        < u =="0.000000000000000001" ; [ 000039379517495.000000000000000000 ; 000039393292563.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EAB86005EACD64E8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3931 à 3940									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3931 ; k489pvY91YCa8n3kw6uW5JVTWf5Kpsra2C52tf49CC73aF9Ag ; 20171122 ; subDT >									
//	        < o9t62V9AAyH3T97Dc8Z7iA5w69eP5QCi6X0upaM5KH7wZ6To35E563A49z88XsWL >									
//	        < W6F5yygrGwc51H2E78u54eO7764wNdpZ5r3ciWZfO2nu714zSW1aM0Trj3EdJxx0 >									
//	        < u =="0.000000000000000001" ; [ 000039393292563.000000000000000000 ; 000039399298813.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EACD64E8EAD68F19 >									
//	    < PI_YU_ROMA ; Line_3932 ; RE8QFgq9p38VBgZQmVscNfTP538Q3xk3q2xRu7UISzK63zgcB ; 20171122 ; subDT >									
//	        < V1RJb1rZltN4393wclKm1cs7CiBlDv2uaoKJY3cvcuDhbh0MoWQsc6ad87MxaREg >									
//	        < F3ca9qV7uTohm1kWVLmCflVizk1MP44QP4O4b2J79BFBn0351kdMY7pubjnz3ovM >									
//	        < u =="0.000000000000000001" ; [ 000039399298813.000000000000000000 ; 000039412317696.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EAD68F19EAEA6C99 >									
//	    < PI_YU_ROMA ; Line_3933 ; qXc0Iyu2AP08feOc2Pubz948Fqsq1hzZLQ2SH1G5xOL5fgOUd ; 20171122 ; subDT >									
//	        < 9Eo6yjyt4M9v95C87ZTA3s4YIZO6D3Vmx43r2gKw6geZjm0R7g8867G7kfixW17p >									
//	        < 3GW5KNLu7wn49WMT0osZPOc8Q29U2hSaj0YNtwQ1mbg68p5hjbn89kyq0DG3j04B >									
//	        < u =="0.000000000000000001" ; [ 000039412317696.000000000000000000 ; 000039426624050.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EAEA6C99EB004105 >									
//	    < PI_YU_ROMA ; Line_3934 ; PM21H24d480S4T90HCoak2jbA2aK51Rd36QDB4vkjIc19N2kX ; 20171122 ; subDT >									
//	        < zxFr8ddW0P52QNQ2Io974X2Nd5JlxtEbk2gE583M8yg88u8Je60o8M9Q3RJm3a92 >									
//	        < 1fpl2B3at18H3T61O9zd3FkI7E0ll7XrSqgu7j1LCTf55XPL6PfRIbxtU1qpUatP >									
//	        < u =="0.000000000000000001" ; [ 000039426624050.000000000000000000 ; 000039434933586.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB004105EB0CEEEE >									
//	    < PI_YU_ROMA ; Line_3935 ; 8SDg5qb49Kwq1WH6Kz272nW74tQ35pigfM93C6dT6t9S8h7f2 ; 20171122 ; subDT >									
//	        < qh02XDkDwP0h4j8mOaqL6rA3o751BPfUU0552Y30HLuPNbDSQP143y3fnp93627Q >									
//	        < g01yuRYo4Ih3a8993Z1707H7EU0nV6fWl0685337aLkyE3lXi09VXYNjuK7GyFT5 >									
//	        < u =="0.000000000000000001" ; [ 000039434933586.000000000000000000 ; 000039445346437.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB0CEEEEEB1CD273 >									
//	    < PI_YU_ROMA ; Line_3936 ; X4AqpJ1d7AeQRqCgq8o27zS7gc2m3h5QK4Z3SJhx45lCXI0ki ; 20171122 ; subDT >									
//	        < Ru7uiLqpBc63ewj6LzX94yWK9e63xY8D291868YaxG6qE1Y9O70u3LAyx4Fsz6x3 >									
//	        < 41F4utRaQSf44VlW36rl4H1J7cL2ub725I8Z9IfY0194z1Xo4vQy51BTsBP4Hfyp >									
//	        < u =="0.000000000000000001" ; [ 000039445346437.000000000000000000 ; 000039457936304.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB1CD273EB30085E >									
//	    < PI_YU_ROMA ; Line_3937 ; uWrLFR5Ij1JUq1C399f7oKyh8oiZ7285nrF0WLcy483FDDU3V ; 20171122 ; subDT >									
//	        < YSYla3c25uNoY3ykCL7MN95Pk2jK01GV50HL2S95hgm1032a34RYiO5xNmeWN04L >									
//	        < rvXvd2U39GBivj0mmmCSmj6tFmkkTdEbLcKQqNX4vJJIiui6I52LT3FYXVvf53s0 >									
//	        < u =="0.000000000000000001" ; [ 000039457936304.000000000000000000 ; 000039469399560.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB30085EEB418634 >									
//	    < PI_YU_ROMA ; Line_3938 ; 19n1ybi2dymqor195YmlzPhaCF3E40j17gVmGsILC739IY6sU ; 20171122 ; subDT >									
//	        < l8Tjk7I05i9040QW8i6O10u2RCUg7om033cUj7m7w8cwe6K23Wrg70gWuL5RI3Fc >									
//	        < SPg7A4Sb9E3cl7C85Th0mQi9Y3WeZD00858Cwd57X9BjVxZrLCV3UTDF3W9WnopB >									
//	        < u =="0.000000000000000001" ; [ 000039469399560.000000000000000000 ; 000039480306037.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB418634EB522A8B >									
//	    < PI_YU_ROMA ; Line_3939 ; zX8MD89fSGDt11miZ06467pG2902VK3eb1F58t9OU715719Pf ; 20171122 ; subDT >									
//	        < kT2AYGwL673QdVo5NeK3Pzb3k8y13Yxq119wtx1PWEVt81sk6rW6JQlhy19F4fvG >									
//	        < o0OamcMz163qTeOW1PfjU80U993Had5u3y1t2C9r5d32pMzB7li4umVec7Du9AbZ >									
//	        < u =="0.000000000000000001" ; [ 000039480306037.000000000000000000 ; 000039486783636.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB522A8BEB5C0CDB >									
//	    < PI_YU_ROMA ; Line_3940 ; LGL1XIBalpH8V0viHeZTukrNxmnX0mIB5FGzu0Lv59j6Cq84i ; 20171122 ; subDT >									
//	        < 57J333Gj2Ml3e0gP5OSY2imQKUpgXGAZ8jJKz1LeZU4EZTtQi7SfMM2312KB0zrW >									
//	        < W87t210H9KlP6nOMr55Z8E4CTmDSU5Kf80VDTr24Fn3PTChX34A0XH5L7Pjp6mtT >									
//	        < u =="0.000000000000000001" ; [ 000039486783636.000000000000000000 ; 000039499177355.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB5C0CDBEB6EF627 >									
}