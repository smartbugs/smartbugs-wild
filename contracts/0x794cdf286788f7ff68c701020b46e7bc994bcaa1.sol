pragma solidity 		^0.4.25	;						
										
	contract	PI_YU_ROMA_20171122				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	PI_YU_ROMA_20171122_III		"	;
		string	public		symbol =	"	PI_YU_ROMA_20171122_subDTIII		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		27646889884000000000000000000					;	
										
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
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5541 à 5550									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5541 ; 2psZVXDl7iB45hJbc48Z3zD8F1pwS8X1nt75aF1N4J1Gy3TSp ; 20171122 ; subDT >									
//	        < 15urv8El129vxfaE8mZrL648N8d6jQpfdHF81p6Xsw73LNS4Evk8o2qealcTRRje >									
//	        < 6X7BL13ehuf9X10vAoEX4t4Fu6Udl0RMVe2VLFfXESCohlRD44CHG12ajyZ1jGXj >									
//	        < u =="0.000000000000000001" ; [ 000054892426958.000000000000000000 ; 000054903598639.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001472F3247147403E37 >									
//	    < PI_YU_ROMA ; Line_5542 ; fiI4NDPGNKE8Ah49P268Az9d6M6zH6SKRLyGf91mOt49W7o25 ; 20171122 ; subDT >									
//	        < Zn1VFCvr5V2kQ3A8oJtf6gerUeYgY60Xe1XuCyK23ARsca474WfP5bO9imS8NMdR >									
//	        < diow6z4lBIJjkA6HGOa771d0Yt0d49eYJ0Zeqg05LK3n173sh4BWcv38Wte9l6JL >									
//	        < u =="0.000000000000000001" ; [ 000054903598639.000000000000000000 ; 000054916937785.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000147403E371475498D2 >									
//	    < PI_YU_ROMA ; Line_5543 ; 022fow6c0r1xIxF200HCqm90A3CQhFwpr9u4eX4Mj937TYgkh ; 20171122 ; subDT >									
//	        < 35ej1JA7NJQhL3msRAIu32c4fMI6Sk0SCUNkdZ03C4zZcgsm2YnI3n6KPin8VF5m >									
//	        < 14qCk3p6b3Qn1Mft86tz0qdOXGGeDv0auSE7RdPI4l22y8rl49h0k0UBNqA1qCVY >									
//	        < u =="0.000000000000000001" ; [ 000054916937785.000000000000000000 ; 000054931896228.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001475498D21476B6BF6 >									
//	    < PI_YU_ROMA ; Line_5544 ; FCa2TLpaBpP79dqJo873VuVwT18pZc4Ro9Qnp7D47aDIji150 ; 20171122 ; subDT >									
//	        < JIW3cUe6tNkUpUXMUGplaML57AJPDP1YRso0Ukvw08Xo18rp5Uf0NJlJZFWzT6Vu >									
//	        < 24q0SEQNFcOsDCh62Pq93fhj40IisUbV8viovpa3X21Eio8wzVdU4FhE9t1tuE2H >									
//	        < u =="0.000000000000000001" ; [ 000054931896228.000000000000000000 ; 000054941823871.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001476B6BF61477A91F3 >									
//	    < PI_YU_ROMA ; Line_5545 ; Mb8qtrFcaj8L1hRR7P9hr30lVb5IhB772H71XFCdx3vu47JRP ; 20171122 ; subDT >									
//	        < 13T2Vutaq4mBawaBS0dd2zn1E1xZ4zpVo6s8urt7nQK1t2fX6R9hgLV57iuh0oRb >									
//	        < 3ZF7930b5ryIT0jmX41VU9Ws25aH26z8V80MZ8QcQn1Kbd0kiziFuItjtBpi42So >									
//	        < u =="0.000000000000000001" ; [ 000054941823871.000000000000000000 ; 000054946953348.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001477A91F31478265A6 >									
//	    < PI_YU_ROMA ; Line_5546 ; 0X1ujUF47FvKws10PCLtl6gTDWVt7AOqrpRBvs205TiygJ3Oz ; 20171122 ; subDT >									
//	        < Dcqo8a14E8o5oBXd23D8ftXPeA4BR88I0NG7Er4BfXG5Cf12i2opDW5098l15Otz >									
//	        < pxj92D8Yh7uabO2yJiHxLj3cNJ9uf94kqm4VQ5kNm6xwCQcAuTKvFatVZ1kT3I8b >									
//	        < u =="0.000000000000000001" ; [ 000054946953348.000000000000000000 ; 000054956893776.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001478265A61479190A1 >									
//	    < PI_YU_ROMA ; Line_5547 ; QbXF7A6ZpYk66H8Bjd9M5rEZ0o7rCalOdee61tx7KN85g93eA ; 20171122 ; subDT >									
//	        < 51K35QSeOF2V583c69TIlOXMz49ADW2LYMbY704WtOw3DSCnnqh6Am88aenHf8Fm >									
//	        < 325EV1K55wl36Q67Yj0m7cD9MirvQ4Vly7435lY8GEBOIH126c29x0O92pC4hk7c >									
//	        < u =="0.000000000000000001" ; [ 000054956893776.000000000000000000 ; 000054963614440.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001479190A11479BD1E4 >									
//	    < PI_YU_ROMA ; Line_5548 ; Cy76B1yvBESABp27C8FhdT6vPIjpPr0y8UdTJl0lG6FhQLd10 ; 20171122 ; subDT >									
//	        < jZ41myo468y662WA0ji6PF6viNc06w5681wcL29GYeLrI9rOKFwo12mOLBrhzO3O >									
//	        < 19wgsPsUKTs00Sa607NTj2699TvHpWZlKkX1iEyT222MV30dh39KU0vq75NR2bd9 >									
//	        < u =="0.000000000000000001" ; [ 000054963614440.000000000000000000 ; 000054977790124.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001479BD1E4147B17344 >									
//	    < PI_YU_ROMA ; Line_5549 ; frPxkCZ7y84pdCqJMH19Eb08vL7s1y59m5P4dkred3wYvymHN ; 20171122 ; subDT >									
//	        < 5U7Ivd2477YRouslyTp0j5k87U39FlDH7Q04H595o2830r4za7902qfK41Xyru31 >									
//	        < X740P13ftmPD30Q26iwO31F189YhMDBHFuuDmsp0kbX0q2S4UHBDy614049urEnm >									
//	        < u =="0.000000000000000001" ; [ 000054977790124.000000000000000000 ; 000054987341155.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000147B17344147C00623 >									
//	    < PI_YU_ROMA ; Line_5550 ; cy1fcKfhwep6G3j36Sf3BZ4sy0NMD186E2xEH6DOtL5JnnR1z ; 20171122 ; subDT >									
//	        < j4pqNb95x285mB39M3sWYbtlvNfqSHsdnOYxhg6cHN32OWOmz815b3P5404zmYJk >									
//	        < 614RAH7oU16737s7RVBy73a23D0LkXogCDiw14xHhk0H8rQ0oIccj061opAg6C7V >									
//	        < u =="0.000000000000000001" ; [ 000054987341155.000000000000000000 ; 000054993707163.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000147C00623147C9BCDC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5551 à 5560									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5551 ; zi4xqr5M2KMu9gb0xy5BSHZ4307jZpBUvnfkcX52VS9E107xm ; 20171122 ; subDT >									
//	        < 04IqA85B996nWts3311Q7ebvRGH485N33ZAp8Apt2p1l8g10R8O1aD2I8xSGXGm5 >									
//	        < f9rxd51Vb9V9TRIdp6LzLPZ8Rm0J2VP4c4yJW7G1TrZb79uo6lGJV2XYV69Wj19S >									
//	        < u =="0.000000000000000001" ; [ 000054993707163.000000000000000000 ; 000055001502407.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000147C9BCDC147D5A1E0 >									
//	    < PI_YU_ROMA ; Line_5552 ; 0v5hg888Pnjsb155083MhdqZP6qcHR2339iJ5mRdcWV3J7X85 ; 20171122 ; subDT >									
//	        < ufs9B292q4CbR5l75D3NWtxrw1vI6QiH6FQajeE37tIo1N4EP1JaRb89cC38tca2 >									
//	        < 2B8q9T66HH91EROZ76wN480bXPLhpln1210on1FC7aYLNJwqmv62bloDeec3cJp1 >									
//	        < u =="0.000000000000000001" ; [ 000055001502407.000000000000000000 ; 000055011806201.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000147D5A1E0147E55ACC >									
//	    < PI_YU_ROMA ; Line_5553 ; nU47K41HBz3h4QD5M33PO40P7Hx4ma188JBA6kheg0Io9Jr26 ; 20171122 ; subDT >									
//	        < 30JapcVW3l8Ee5ZrQdPG2a68yp36LAeE7q2S4RNRxt29eZc0mfXFIBDFjK8Eq0Fw >									
//	        < YI5WHc44pJxEA4gel1ZntJ5NQx6C2baLjp5fXcOV5U6h21SNsdG4w03qL18Yp8n5 >									
//	        < u =="0.000000000000000001" ; [ 000055011806201.000000000000000000 ; 000055025502637.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000147E55ACC147FA40F7 >									
//	    < PI_YU_ROMA ; Line_5554 ; bemi20K8oarkJtygS9g4C0Xjp1fyT9b8yHNXH079Ho1gN0Ye4 ; 20171122 ; subDT >									
//	        < Y9Faa5kSRcne9pAPjjBSellkCa73oKYL4F6201q6V401ewFz9X6Jh3M5X8L837Kw >									
//	        < T9RGBnsEYfM9q7JcI6NmGTmgK54ceYIo6RceQB1b27R8G1Q2aRqE5lFHIp62jmW3 >									
//	        < u =="0.000000000000000001" ; [ 000055025502637.000000000000000000 ; 000055033972561.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000147FA40F7148072D88 >									
//	    < PI_YU_ROMA ; Line_5555 ; 5EXrfW0D2UkgpweWdPZEasQefJ2t47MVzQBj4tT4ZC0guhsiZ ; 20171122 ; subDT >									
//	        < 7FQX257w71p5uCu7XCCaf9887O8OdPx1F53xk27TEmApn6Z280k901x05875Qlat >									
//	        < wJObZw3Qfo1RZH4287Xo9WtQ1A7JEWgKTJf82K4XYEirHSoOhn5PAv0YPE47291q >									
//	        < u =="0.000000000000000001" ; [ 000055033972561.000000000000000000 ; 000055044932890.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000148072D8814817E6E9 >									
//	    < PI_YU_ROMA ; Line_5556 ; O2DNV3DtRg12tl12uc4a91R7l1982b9N5jgGgYNSQmCaQYN4x ; 20171122 ; subDT >									
//	        < sve2xhvfgt30b84c7eEms9Z5HhvzSMYTMTWHDSUucKAe8pFFL4gKO47HZz8eUvPK >									
//	        < XcnbxkqQ2er5ssQ9s44QazmKkB2lIcEE99I10g8954Fi7B02WM0PmVfkCJD92bQB >									
//	        < u =="0.000000000000000001" ; [ 000055044932890.000000000000000000 ; 000055050508042.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014817E6E91482068B4 >									
//	    < PI_YU_ROMA ; Line_5557 ; 1gpiAuN89NS98eJ9w5JZv1WY8VUY9Mg8eVL1en2glln7iQve2 ; 20171122 ; subDT >									
//	        < hokrp886L63Z1257e6gp78Xy41504f3LfA29K57Hwq2MXWO627V8g4iBy28TE4H4 >									
//	        < 9gGwIvRUPT7CXLUEuAvxF8a2lDp9K1rKDu4KtEZJoo5XHJ8Y0bNL38pBK6YC7D18 >									
//	        < u =="0.000000000000000001" ; [ 000055050508042.000000000000000000 ; 000055064598943.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001482068B414835E8F6 >									
//	    < PI_YU_ROMA ; Line_5558 ; g3Xb0B0neJ61h5Ei2A84pRjTz67FPicZtaC1j5765l98I0mc3 ; 20171122 ; subDT >									
//	        < 0t5aW5FiK6VVieUd9mR2K42STdjMSt466Q225EhT38K8TmD7JL14YOZdNYudAZ9Y >									
//	        < B29clMXdm0o0acwg4MXVHTTOXmVYOG07f1D9Xnm4P9sCpj0JO6B9l86XvsFi28YM >									
//	        < u =="0.000000000000000001" ; [ 000055064598943.000000000000000000 ; 000055079315114.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014835E8F61484C5D77 >									
//	    < PI_YU_ROMA ; Line_5559 ; 63Ra8JQk77wN0SARBb24xZi6J4Mmq309s2Ljb89apE47zcVj3 ; 20171122 ; subDT >									
//	        < gaM8lceCOq7GQ6Ym95t54xHdURZT8wgphp42U6c49nQMI93x150sfjo384XGyjD7 >									
//	        < Uu28aYqJS8t6kYMs66d5C3PW2vo2aEt01cTQNrwP06Pq054sn3lLvzX46B8Wcbtw >									
//	        < u =="0.000000000000000001" ; [ 000055079315114.000000000000000000 ; 000055085675584.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001484C5D77148561206 >									
//	    < PI_YU_ROMA ; Line_5560 ; 6T86tWO6f37nJB7CTHj8R8901d86dM3mE7oBpc8f00BxepqDJ ; 20171122 ; subDT >									
//	        < Eoq2PXVe24P608QAJ4D7W0QLsUMhyB580Zx9rj8V9xJaZ06aU0zxL4hgATw4Ww8y >									
//	        < mBZ02dbEx5ype56Jeed1V670Mcc51y4r1VSOEG8zvuGJ52Z7xe1WTSYbqSGT2SI0 >									
//	        < u =="0.000000000000000001" ; [ 000055085675584.000000000000000000 ; 000055100449073.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001485612061486C9CEB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5561 à 5570									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5561 ; 1iHAUmSN1R98k1AepVtj1JQnk45c4k49f5s7L90D3Gdv087L9 ; 20171122 ; subDT >									
//	        < jt19cyO8DL7PrRWT4sWib4zF7k128ecY9jICM2r73E2of5vnA9w6nry0475NUZRN >									
//	        < aezCoZU6JYjv2w3ap45WqH66qw0cnYLCt8MiuGghegK8yWb9S0TqnbKoEX4m0n8L >									
//	        < u =="0.000000000000000001" ; [ 000055100449073.000000000000000000 ; 000055114907134.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001486C9CEB14882AC99 >									
//	    < PI_YU_ROMA ; Line_5562 ; Zyh1FcTUBYSl7C92o23qpa6XGv24gNgCBa1a7QD1Nh28iioGC ; 20171122 ; subDT >									
//	        < Vt4IXfvSntu9evE8q1bMX7MkcBHco14p45dgoYQ435oYFs3IP7ZHnA0y57HSjN0c >									
//	        < 1b455422wnQPMk3H9d6Jw9CW4L4c92rNJ161p8iAwZ6Ri02BvSvM69nJ70XdQ1S9 >									
//	        < u =="0.000000000000000001" ; [ 000055114907134.000000000000000000 ; 000055124121082.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014882AC9914890BBCC >									
//	    < PI_YU_ROMA ; Line_5563 ; CycAY41wD348SiwNq7u9qMnAGE0h5m89zOA4En7M7Hs45U8S1 ; 20171122 ; subDT >									
//	        < Pp1Rl3qy674IcXQWo3TYvqu27nVvBKMw294Z7917h71jx1QMr0LF84ej0WC4Y2kb >									
//	        < e1xqB066H55A1a1N1ma3JOFagzy6Y07YcS74j8yolk248dT6uoH2lncvKvbZWa9T >									
//	        < u =="0.000000000000000001" ; [ 000055124121082.000000000000000000 ; 000055133107060.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014890BBCC1489E71F2 >									
//	    < PI_YU_ROMA ; Line_5564 ; 0fRemxzFKuNErn4SD4NjAWlL5417u1za7UyUe6ZJQ9UD32y5Q ; 20171122 ; subDT >									
//	        < 3y91s0MK1DyOsd50i0pBfbpitM5m7aH7FxjFa07TZuxTbsKn3bl9kbI2o16Y229V >									
//	        < rf0k3MY07Oz46fkSq7LVp3STyx4FIECN5t68p0139b739Q2o8x6XWQKw3dO31hxd >									
//	        < u =="0.000000000000000001" ; [ 000055133107060.000000000000000000 ; 000055142059687.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001489E71F2148AC1B10 >									
//	    < PI_YU_ROMA ; Line_5565 ; gAkJQea5bRMVQpiYa8ANQ9C0pmycfQXG1x3IwSj7I1Q4Gt7fj ; 20171122 ; subDT >									
//	        < qpJZag60T6TNvheewEXRgTtpaRzJZQp07LoM0MpDfuWJPpeW8v46DH1FzyeJx3lF >									
//	        < ImyFFNj935l013E3ht7AL95MjUb0578dr0kul347ruEK087qY31K4dCh497ScQCf >									
//	        < u =="0.000000000000000001" ; [ 000055142059687.000000000000000000 ; 000055153677369.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000148AC1B10148BDD538 >									
//	    < PI_YU_ROMA ; Line_5566 ; HXLrfI7Dt1O7jPPHzH8N69FEluSil4tWM9hiG9zNTK9kz89b5 ; 20171122 ; subDT >									
//	        < DDAHYM2tjQkytQ204Gop1yN3Lqv6R4h82lOs552bDaztq8zaR8Ld6AGe0x8s30P4 >									
//	        < Ba65Ka9W4Lx276uHit4j5W8jL8GV4LAZn7xXW1iDD8p5ssD8fkfr0oF4OwaqSZ0F >									
//	        < u =="0.000000000000000001" ; [ 000055153677369.000000000000000000 ; 000055164267690.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000148BDD538148CDFE11 >									
//	    < PI_YU_ROMA ; Line_5567 ; ulNoQFd0hh8ROB68Q747iK4RXwqMAcMuhPnFdhfTAT0GUVD2M ; 20171122 ; subDT >									
//	        < qS97jh1B09Q4mzN10D6k4w72YvtXmF1yh7p2y3C63V736RzWu6M8XV8XA0h7u29h >									
//	        < w16Jiw4gz8hx7hw2u38J7M4NvXkioB7i9TH1eyEcWV9v86Tpfyo3Qeb2Z8kgzL3v >									
//	        < u =="0.000000000000000001" ; [ 000055164267690.000000000000000000 ; 000055175955416.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000148CDFE11148DFD395 >									
//	    < PI_YU_ROMA ; Line_5568 ; K44UcJCQ0x1MpyL1My7V1O4ZNf7qNsBbwFM1nyksH9C8i0255 ; 20171122 ; subDT >									
//	        < nLJuiZK4nqz990FE40x30S2sqMT6b09H0ZF9A0DL5s73t4WPj4uTI607dFVI882y >									
//	        < LZhbEBz03vvzaq6B93wg584HZKsFh7HYIrt1MV74Ci2Ta78F8rYiJA3PQX20fu02 >									
//	        < u =="0.000000000000000001" ; [ 000055175955416.000000000000000000 ; 000055185373551.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000148DFD395148EE328B >									
//	    < PI_YU_ROMA ; Line_5569 ; rM69w66Z6KXV0u8z8oQ8q2tw9Q6sxVoNfZb59IkRViaAA668M ; 20171122 ; subDT >									
//	        < j3wfA4X3E9k1GTI5ra7KCP2U1nVbEvOWngTZ1iEJ7jzuPoEz2mlUH79j8dZWB9tO >									
//	        < yY5o7pjjkS9rqO79LCYRD3dJ66VM6c5F96xkx43gegfQ47Mz64FoUfj8174H1gT2 >									
//	        < u =="0.000000000000000001" ; [ 000055185373551.000000000000000000 ; 000055194532372.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000148EE328B148FC2C35 >									
//	    < PI_YU_ROMA ; Line_5570 ; Q0wMcN0W3hKhn57E460zI744Sb3luAaClqol1NEUA5TTwLvty ; 20171122 ; subDT >									
//	        < VdNU09qqE30MdxP2bF4CSQ628okv41sYMxo0qFU8xup25V40NCHiP2PVJn83bLpL >									
//	        < y84HQke6dwEJxo3M7rYGE1F9Qd6u6kSz1R78zn0s3tR623xW267D0YY9Yr1RTXNu >									
//	        < u =="0.000000000000000001" ; [ 000055194532372.000000000000000000 ; 000055208496196.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000148FC2C35149117AD3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5571 à 5580									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5571 ; zpEXsRQOwSlQ2j5R2ZmtT5XMvb50m0OWSBK48GX0aqva034a2 ; 20171122 ; subDT >									
//	        < a9yPJl3YBdsr4s7Uaq7nxy8g90TXN7cJW72uFU2lXw9nL6pH467xXm7sSsj82J6D >									
//	        < U2Kp5mO174m620LtXj5o02RFtgtPMMBsyRxyP7ECG06mLpACMP216qzxJ555Vyf1 >									
//	        < u =="0.000000000000000001" ; [ 000055208496196.000000000000000000 ; 000055217016255.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000149117AD31491E7AF9 >									
//	    < PI_YU_ROMA ; Line_5572 ; xxwxESmJ1Aw4tNi5hXtQqD195om19B39f9dAE6psl0b7PdMU3 ; 20171122 ; subDT >									
//	        < 9Bu0XV601t0AyuNNyKYrk3GXl3oBUSF1m79zfeE4yxS33YveDQySwGk4L4MyB2Ci >									
//	        < Q1H4h69IExT5MHDEu1EsCU4nM1xqK07t9XT1B5inGB2JPCl01t82R7EOSjx7re9p >									
//	        < u =="0.000000000000000001" ; [ 000055217016255.000000000000000000 ; 000055229371339.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001491E7AF914931552D >									
//	    < PI_YU_ROMA ; Line_5573 ; 9510NTFr8G16qD9759LDuOG4i8I4Nd975GOd1P48d6qu9i7e1 ; 20171122 ; subDT >									
//	        < 2HPEy7f9tnGlEsRER1f6ohLI35rQ2WJs3k4b4tPXx7gHsTgR6ALN6006XS4032Ii >									
//	        < 2WR3ESI162n4BK36qP4007c43BE3ONKz9OqhiujYRRFTXtqZ6hfga4wud2P2asyb >									
//	        < u =="0.000000000000000001" ; [ 000055229371339.000000000000000000 ; 000055242973937.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014931552D1494616B1 >									
//	    < PI_YU_ROMA ; Line_5574 ; 27RU9kxKe238C9sWGS8wqgheK8vhP8k355XL7w6M69xd9kNvf ; 20171122 ; subDT >									
//	        < 7l126Cstc65lEBpnMDraeya3S87EI19p4c889kSb774S8690VndD8X38jYIpbMj1 >									
//	        < d5XW64u9JvSU9Fze5KINN0v7SSsh5b2OcE2Ep78zAJ8cbSu1XuKV3C44Y89kVTuA >									
//	        < u =="0.000000000000000001" ; [ 000055242973937.000000000000000000 ; 000055249066089.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001494616B11494F6270 >									
//	    < PI_YU_ROMA ; Line_5575 ; XASXOqi06sL4Vsyl7z65GzHzxaqY5V6SxBfw8MBR9BYNdU7YE ; 20171122 ; subDT >									
//	        < E2Lq89Qd49KRt1H6dYO359R4vH6948qOLB4BK7wq6T1JYBzzdB1xXJHPX4NcZV6e >									
//	        < YMAmBPUrQKsdT19AR9F1uZHdOBe570f33djh46zwO2gVX3D24tR1uxU16oGK0rRH >									
//	        < u =="0.000000000000000001" ; [ 000055249066089.000000000000000000 ; 000055258408257.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001494F62701495DA3B9 >									
//	    < PI_YU_ROMA ; Line_5576 ; FGs0NuN1BQY6X93T2Jx442nNjUCcS2es9MV8uj1Z2yz0uWD8f ; 20171122 ; subDT >									
//	        < 8Auew39nyWdzuY13llQ64u1j18v8Ce3EP7824tCNlp8P9T8Qr1m9o8nFzrTm8C9s >									
//	        < M0r94Kj1025wwGPFh1cA41ZeV4gqc7i2EBJaQx43H28nvP7dSR51SNl8JRy9ERDt >									
//	        < u =="0.000000000000000001" ; [ 000055258408257.000000000000000000 ; 000055266203946.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001495DA3B91496988EA >									
//	    < PI_YU_ROMA ; Line_5577 ; pZiG85157F7XE26LQ325Nx7SEGMahdA2CG98Vx3X1LDvx301S ; 20171122 ; subDT >									
//	        < 3875wnVp6D96Cq2n38tH0BJr0y28v950BERsi3m7yRYXGHl2OZmKe0jRjTcAS755 >									
//	        < L672I7KDfFN4UDB4IRjLJ9ayu5NL4V4ACNi0OkaU4O7lbj7EE8tiK149u411CZ02 >									
//	        < u =="0.000000000000000001" ; [ 000055266203946.000000000000000000 ; 000055280183133.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001496988EA1497EDD89 >									
//	    < PI_YU_ROMA ; Line_5578 ; U8x3Rxf02ZuYJhzArB0Psg3Ix9SQp0FnCoSImpkFUni4O2mmr ; 20171122 ; subDT >									
//	        < mmZ57aU6cS2w6gH5u2Wh47c048YVcW1wE9A0q9eGRAu7avr6tr807VlNNz8R1SNZ >									
//	        < 7gn06SyBBN7SIZo41N6Vd4Jls5lY60enzCwLx5dq2HQ764r5kC1G9G9X1ibdgUD9 >									
//	        < u =="0.000000000000000001" ; [ 000055280183133.000000000000000000 ; 000055292344133.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001497EDD89149916BED >									
//	    < PI_YU_ROMA ; Line_5579 ; dTZU6IIA7m6f2Lx37C364NkV8eJIsOro9GUw0ne425JM1rF13 ; 20171122 ; subDT >									
//	        < ax86A9x7PPkrB9gsDi2HociK763ES41USevXRj215aA053e9X2Qkuze0Phhif9I3 >									
//	        < Nrq4Ov9vrhW32knJZjYtNkoqbrqU4f5563VLrk2R1585Klfn2LOMDroI3u0hoIPB >									
//	        < u =="0.000000000000000001" ; [ 000055292344133.000000000000000000 ; 000055304324219.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000149916BED149A3B3A5 >									
//	    < PI_YU_ROMA ; Line_5580 ; e8UM7h6X4JayZFOE51dM7ThtdLqCHxH9U5Q24Q9nmcQFetFtH ; 20171122 ; subDT >									
//	        < C0Gnj9SMNr3TVG2uRW96MX2wFTp0iH8H18n210TC29Ch1i8690Jj0PC94kqsrKHi >									
//	        < tG3o2BGYEch7lBbxHh107JJ1lT8pO1ywia170s9e39k0Jg55L52WNpdXjuyX9tV4 >									
//	        < u =="0.000000000000000001" ; [ 000055304324219.000000000000000000 ; 000055319093568.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000149A3B3A5149BA3CEC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5581 à 5590									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5581 ; yRZQ349J7SNl8osWwAp04V9X3YQqP3HaKB21KsdV1Sg9QjbUc ; 20171122 ; subDT >									
//	        < 4wBx83I77a08309LxTBH8yUMtWaxEzTykmxDLKS509piy49qbC6Re64iYsu534a6 >									
//	        < wF7f4fXg0w3xjJlm1TR446LC115xwVn3k020X08AfAa43GclItvQzxKzG5U464ts >									
//	        < u =="0.000000000000000001" ; [ 000055319093568.000000000000000000 ; 000055331001330.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000149BA3CEC149CC6865 >									
//	    < PI_YU_ROMA ; Line_5582 ; 01lPEznYcvEiwfJ74TlAEI6a1sbMB2dC8M8QmK238m4AQh2xz ; 20171122 ; subDT >									
//	        < gy0s80YPj68Wy9o9Xm3o18E6897T5oDf4JMp3xQJrZ80xm52B9BTiC3xi627IoJh >									
//	        < W5s9onyGeEZL3PUh9O5Zy4V8u4IM1eJnKJiTbyoyvnj25cvlH1w5Ru4Qf7PC7X8w >									
//	        < u =="0.000000000000000001" ; [ 000055331001330.000000000000000000 ; 000055344494866.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000149CC6865149E0FF4E >									
//	    < PI_YU_ROMA ; Line_5583 ; LfqeyBv2GJ2vWjJl01S16tK07qV0N1F08jWx30ugWF7re6cs0 ; 20171122 ; subDT >									
//	        < GYo687IT7s70LtIA6sahfE93A44TL1pmBTGw4gs5shsR0i8S379vxk48wf37QMJB >									
//	        < 0g7G3rWlPG8w6ybIwZ9wkTYQf7WNWA6aOxL2y001kPph6sT41aLH4LElERIJ7z7z >									
//	        < u =="0.000000000000000001" ; [ 000055344494866.000000000000000000 ; 000055356402954.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000149E0FF4E149F32AE7 >									
//	    < PI_YU_ROMA ; Line_5584 ; P724puw0haP20ts88gr33nZ6nw5A0SkLLETwIPPU7wvjJA5iu ; 20171122 ; subDT >									
//	        < mV8gO5RHofWso0gZop7cfE23YE5D913iwLGtLeO79tiAp6hG63q998NfET0q0D3I >									
//	        < 0MjF75zXw2d2iTlE8zM5p8Iw9j6VAV20XJZZBxy8MPL43R8pL84c3G6CGftPO0sz >									
//	        < u =="0.000000000000000001" ; [ 000055356402954.000000000000000000 ; 000055366035863.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000149F32AE714A01DDC2 >									
//	    < PI_YU_ROMA ; Line_5585 ; BOP4vGP3nT51R35hvbQKSy4MMZWfmE1ZOY4Yg3vx2y9K5LUF4 ; 20171122 ; subDT >									
//	        < fa1tBHkY9zd8LXS78C4Ifuuit3t7zPK55vf9MXsUbbb3YNMRZ54wz0k66w5Q00p0 >									
//	        < lWQsHlZ2771a506AkAkCKV4UDQntuNYHX81VnwvdE177e4paIV6cyfAQ21K5WdyQ >									
//	        < u =="0.000000000000000001" ; [ 000055366035863.000000000000000000 ; 000055373937564.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014A01DDC214A0DEC5C >									
//	    < PI_YU_ROMA ; Line_5586 ; XQzItA75XRfOfMv7suaAgm893lX2zoxxCi3RvbKy9ClfrOJ8z ; 20171122 ; subDT >									
//	        < 297giIS1YV19dL3gg6PgY4b5PGIxS0LXG6x6ch7If067JiQI26TxSFXb21W6jof0 >									
//	        < cdTdhhlOkzAfqe8S02312321zWUugMR1Gfz0l81TThrG4TLB9AV0474Gg5g1fg0G >									
//	        < u =="0.000000000000000001" ; [ 000055373937564.000000000000000000 ; 000055383617982.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014A0DEC5C14A1CB1C6 >									
//	    < PI_YU_ROMA ; Line_5587 ; R4rUZS8G8kUWRNo1A7V03542OTXqT4U3O9qGYg9GmexPPw8X8 ; 20171122 ; subDT >									
//	        < 0YAvBHcIGxnhdV4el1B090U03Vlr6NJ0kImZCCRTxw6c49x0UpH4VOx43zcX1T7D >									
//	        < zoc2TvfPRpN2C3T0oiTAsvSe0Y4W4oYhoT6JL1akP93HuPC8Sab6bik0RZ4xz5Kg >									
//	        < u =="0.000000000000000001" ; [ 000055383617982.000000000000000000 ; 000055389995445.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014A1CB1C614A266CF8 >									
//	    < PI_YU_ROMA ; Line_5588 ; 4yvr7Mnx9udGVrgbPCBIsF8Uyt9LoMfxndYra016M18reT6gD ; 20171122 ; subDT >									
//	        < Q4p13qDHrC10wMQ4Lc0TYtWx6J1sYDd5fRTJsfxhfoVh9Q4f2su825I9ET8gG79e >									
//	        < 46AyQ3gtOFk3PglIr16Rj2oCl4438PaZPpbNcAy99HW2Ybuwq3XR9qAbaDptP6h7 >									
//	        < u =="0.000000000000000001" ; [ 000055389995445.000000000000000000 ; 000055402047522.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014A266CF814A38D0D0 >									
//	    < PI_YU_ROMA ; Line_5589 ; mOKLk2tdVw86LQmrC8seh3bwgI20U878Cm5Ks4h5WcOzye8dI ; 20171122 ; subDT >									
//	        < 0YHnIZtDjRFn64bWOnWz5tFYn1NuNi6PBm18255rGwMOt8o93L0v02ba08cLdGOm >									
//	        < PNdrei686Qa501V11HKxJ1OHqRN5OU1wDSP9XkI5w9333FFy159YZ5OQwnpjj8sr >									
//	        < u =="0.000000000000000001" ; [ 000055402047522.000000000000000000 ; 000055413176084.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014A38D0D014A49CBE8 >									
//	    < PI_YU_ROMA ; Line_5590 ; 528gj95RB2Q9reXyr6Egz27cGxIcLlgAF96Sh46uewrT48n0j ; 20171122 ; subDT >									
//	        < b0J8066PUV2nJOwMqob7ACNvyF3gvL0OVAI5Ah4Za9LZb8VHb6vIPZmjTBd2le4h >									
//	        < ala94C15R9q8Y44s993Ra01goA3A9CC663dt8sN610f063dB6pDB0ce50n6vR0E6 >									
//	        < u =="0.000000000000000001" ; [ 000055413176084.000000000000000000 ; 000055419797392.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014A49CBE814A53E65B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5591 à 5600									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5591 ; 893v1Z0y2AH7g5bkww7g9Ig37E14iEAb41JpmYDrxP1s20Mbi ; 20171122 ; subDT >									
//	        < cEDY6Aq3LE7SSSfS7qP5QQg1GZ51gzxy9I66trfJE6D08q0Esg5J3Uj47PHpsOLE >									
//	        < 6OwbQIqTWy640djQ4Xtopr289x912y37BE883Kfu61ujs6Xm8irZjaHVFMqT8pu6 >									
//	        < u =="0.000000000000000001" ; [ 000055419797392.000000000000000000 ; 000055428508543.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014A53E65B14A613126 >									
//	    < PI_YU_ROMA ; Line_5592 ; 5GDqv6wQv2mqS9B9u1gpMW7i7hUYF474Pd250Qrny0q19uvzF ; 20171122 ; subDT >									
//	        < 4GZRSj297088NrIWrN6dEKl5P3809eq75603n1f8K91Fz6wkpHXIl17pRZUz0Z11 >									
//	        < j2n730ZwmDf9Wnr3q1l91lf471YIHt8tKNd6bFd4Uy0Iy2xO543KTRMXLIn5Y1fl >									
//	        < u =="0.000000000000000001" ; [ 000055428508543.000000000000000000 ; 000055435072340.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014A61312614A6B3522 >									
//	    < PI_YU_ROMA ; Line_5593 ; W48FtVVDI919PFfAreTRkQE1Q00Tlnmyel32s7Pn6Kh13020a ; 20171122 ; subDT >									
//	        < 14G4369K7ZWTKTJsK69RrUVcm83mkX8edJqYQg8uHNRAD5EWo3JU1qr1Ru06dm74 >									
//	        < 7Hd2t9iUQBLs2FjyfppDRtmFqfQb8w6GT4O64K55KtSU7TC4af2Rlt0BD11p1fsZ >									
//	        < u =="0.000000000000000001" ; [ 000055435072340.000000000000000000 ; 000055443433163.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014A6B352214A77F714 >									
//	    < PI_YU_ROMA ; Line_5594 ; f008y4PhQ8G37ZLkr5dXeO77wfMnkTKSF452igaVl2E7uQ991 ; 20171122 ; subDT >									
//	        < 1RsFxnTamtoL51qgv73YZd3376UZGEk1Y17E9VdCIwUKm379T1gCy410YZ8jM9qV >									
//	        < UPuO7cHPxx8FMPsA0e0lhd558akr2308k3RlAgxfeLD8lQ8Y9wiq45Y480k3izLv >									
//	        < u =="0.000000000000000001" ; [ 000055443433163.000000000000000000 ; 000055450706639.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014A77F71414A831047 >									
//	    < PI_YU_ROMA ; Line_5595 ; hK2Az4r7g8rm43164tZo5Z872N8Awf3h7C2tjJH8bNJOd3m7Z ; 20171122 ; subDT >									
//	        < w7ARF0y023DazoP61430dDLi2Y7z1SkIU5VK4jFDaUAFJ9138FZXj228jr051X4n >									
//	        < N79gY0KbNfhe9vx195Nxat3Sv5e6dNbA2KgbIwR3lin1dttXBW4AVS5nlmDG1k62 >									
//	        < u =="0.000000000000000001" ; [ 000055450706639.000000000000000000 ; 000055463317369.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014A83104714A964E58 >									
//	    < PI_YU_ROMA ; Line_5596 ; uSMgU176bH83t686W6pu39UQ3N5JNBskT12Hm5TG887noc27V ; 20171122 ; subDT >									
//	        < 2AA4faOuHwJWTy37qfc52X0w2dzCJlMfIv89r39L6E8HcOy4d889UR18MKQZ5VM7 >									
//	        < P0cuJ3616qD60Jcj345k8zD0gzLDJnw588EN6Rt7lxsvvo1mZn51L9L80GawV2F7 >									
//	        < u =="0.000000000000000001" ; [ 000055463317369.000000000000000000 ; 000055473140498.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014A964E5814AA54B81 >									
//	    < PI_YU_ROMA ; Line_5597 ; eCwPf6Z7Kq0L8UAxVlM9x77BAr9jBn7Fs8986gWfY5UyZgFn6 ; 20171122 ; subDT >									
//	        < p3P8T91964JDZTy18e6ZqvBxYxNSp34kQVd003kl6hn57gIs2i4xH1X7zyt6YWv8 >									
//	        < 77wJ2371Hzt7mztmG2s2zqfdEYEIC05QT04O9xNLh6dR6Bgraf9wepUUMEcahuL3 >									
//	        < u =="0.000000000000000001" ; [ 000055473140498.000000000000000000 ; 000055487401471.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014AA54B8114ABB0E33 >									
//	    < PI_YU_ROMA ; Line_5598 ; Yw3a7k9IUuyktsva3Wp5h4R9oBO44mTGX64K36O0E8Ud0z3kQ ; 20171122 ; subDT >									
//	        < 128KzVBAA2gnet5Xc65eH0F56dZn4hS73VDWr7UEO5p906iMsBdv45V5790BQu60 >									
//	        < 3x0D48O028Jqc2trt4I01d4Kc7jUXtMA54X3OnGqQwY5hXs96E4208B9a4H5cUdy >									
//	        < u =="0.000000000000000001" ; [ 000055487401471.000000000000000000 ; 000055498078484.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014ABB0E3314ACB58E8 >									
//	    < PI_YU_ROMA ; Line_5599 ; ba6L7BNfK4rg2MUp2Sl9QhYBTx5IlMd9lA8qN05rqy9040t5k ; 20171122 ; subDT >									
//	        < gu54FKjnxd1j0ikEKdghwZ8n6C4v6m2vTif1WJ16JzeHDw7tb132LaybR7IkckzC >									
//	        < gp8eB93v9DpwhyA68M85vbk7HIW2rIP1Q3g07y8j2Mg775CT2aAXh2n72296lONo >									
//	        < u =="0.000000000000000001" ; [ 000055498078484.000000000000000000 ; 000055508209192.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014ACB58E814ADACE37 >									
//	    < PI_YU_ROMA ; Line_5600 ; T780r798cstsbRW2DDIx5H3YG9y9b2b5bhPWK0F6YwaZUJOaL ; 20171122 ; subDT >									
//	        < m7qTL2zY4VJ4Od6t7Ie3L8kg69hMrHKVHyT1kFNwbw0DOL7j28AuUvO6XlHF0J6j >									
//	        < To634WImmVsTqvzq1meXg91Y8Vvzz0Uz63PEAVshT9odKGtQ7emqvj40H081BKMv >									
//	        < u =="0.000000000000000001" ; [ 000055508209192.000000000000000000 ; 000055520555009.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014ADACE3714AEDA4CC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5601 à 5610									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5601 ; I8fqEcY0C0Rvy9tb4mkLwx5lYKh9Nm1piTwgL98594CiKW1r6 ; 20171122 ; subDT >									
//	        < 5l0hzHirj27BKuIs5hEycNqN68mxk99b2hbFaJI5p749oY1Ui1u4yCFZD848aUtg >									
//	        < 809IqRsw7cG5OO2wI80JHiIu88F5CEN84qtSI27H3rFm0gX300cFMW9NKK3KuUe2 >									
//	        < u =="0.000000000000000001" ; [ 000055520555009.000000000000000000 ; 000055533531703.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014AEDA4CC14B0171D2 >									
//	    < PI_YU_ROMA ; Line_5602 ; 3PkBh4CYZ3x7554zy955btX614vqJgrZr361HAlnAfN2V5a7I ; 20171122 ; subDT >									
//	        < 3wDx6LdN3M8V67tqkS6YFd07d9h4N9CgefoM0pvN47r9wA9hKRId9tV6749bEr94 >									
//	        < QtzRyob6gIBSkeAIZrnQSsNMpIf07laqVo42W6rVGl8931sxLCfMqiqZk2936rHt >									
//	        < u =="0.000000000000000001" ; [ 000055533531703.000000000000000000 ; 000055546761748.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014B0171D214B15A1CE >									
//	    < PI_YU_ROMA ; Line_5603 ; NglATH1jfo5OZVMIRa979RylJjP6LZv7j1YmsFv2c29TfAlX8 ; 20171122 ; subDT >									
//	        < gTtDtL4hEO4gnzP7mvg101iT0y473V1DZ7g5EWg586FV5875ACuJOtyrpekTLZ0K >									
//	        < YZV58fQ2CxJ9BKZn6q2fs0Zx5JowI9XH079ZtSrNI5tlX7x810E7Fn3ndRBLQ0Fj >									
//	        < u =="0.000000000000000001" ; [ 000055546761748.000000000000000000 ; 000055552429397.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014B15A1CE14B1E47BB >									
//	    < PI_YU_ROMA ; Line_5604 ; X8AkviP905WKP8Q7Ce10546wGW4F9fI2Xl1CeZ3t8452y735g ; 20171122 ; subDT >									
//	        < ZpToGKKJpM41YWWNz0TL377ZViYwcZ4vH87fcNBmBL41WUgz4z4pR86V2k6J0Z9U >									
//	        < Bebb3JTV783QEKp7ByJ2Xuyk3Nv6u6pY8V1M60nqE8VKMxWQ42JBPVI7b25IK8i1 >									
//	        < u =="0.000000000000000001" ; [ 000055552429397.000000000000000000 ; 000055565575376.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014B1E47BB14B3256E1 >									
//	    < PI_YU_ROMA ; Line_5605 ; 8y49fQtmjqht5Lu21K3rd77Fh159zP3dXYyPo83ynG1IqO751 ; 20171122 ; subDT >									
//	        < OwviLDVt5Fk2Bga0FjlPdBUiR1p9R9n3Xl8veB3xj75LA5U6RcvMPtChv419I2pK >									
//	        < 209Jc9wjEY3uMYmC02wed8311Hd758AsoL0KY8UbSWv7Z32KpASRAQ83S29O3Sss >									
//	        < u =="0.000000000000000001" ; [ 000055565575376.000000000000000000 ; 000055576425830.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014B3256E114B42E557 >									
//	    < PI_YU_ROMA ; Line_5606 ; O1Q8096iO2xp09yASR8c5jmE99bb85J1PI2kU08otI81Xs8L1 ; 20171122 ; subDT >									
//	        < x9oX3mi5C2BIPwOLby79xR4NL3UUo8YfHcHIOlk9l7lggdxudy47cM6NN6OpAV0Z >									
//	        < qqtnYsv2jCW4QjRq088s6ZZ0nW4T60X5yADq9Aik5zvVFS5zF7gRA31k7e0zpDSb >									
//	        < u =="0.000000000000000001" ; [ 000055576425830.000000000000000000 ; 000055588569897.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014B42E55714B556D1D >									
//	    < PI_YU_ROMA ; Line_5607 ; 59262x7cpesc5j7iTq8g0tkBK18qZpDH4n90SAp4XbB806i06 ; 20171122 ; subDT >									
//	        < bdc0WzL5e70c6DtsVm730WN7hp3XkwR6If17kCrj3w447Xhw91Zst25XB1bqDgCB >									
//	        < z77nB5I0q22Zr3eZUOQc17bpOZ56bbzxR9Yi1J0bbZ9dY584DBMiQYwVm8G2QDIV >									
//	        < u =="0.000000000000000001" ; [ 000055588569897.000000000000000000 ; 000055599140937.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014B556D1D14B658E6D >									
//	    < PI_YU_ROMA ; Line_5608 ; ob9TxS6Cul4U72L4h9SY9RW8TtD6NVwa5CS3UEo587k2NVNLi ; 20171122 ; subDT >									
//	        < cECWKeNeVVy4x8Ma90c25k8Y6G10cok53jlDgd586Wx66DFD94xw9GeYmg1s6798 >									
//	        < 00x8yEO01365S7n9fV5TX6296x2saY7RJ8IeLk1YiA5cqtb3uIK0M2XV5HU34mSY >									
//	        < u =="0.000000000000000001" ; [ 000055599140937.000000000000000000 ; 000055609047405.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014B658E6D14B74AC24 >									
//	    < PI_YU_ROMA ; Line_5609 ; NE0x592c7Ua7s3LG0OvcxSm63Ko12jjTc0b3R7Mk1AwNG7ofn ; 20171122 ; subDT >									
//	        < L82uonKtWfy0SxbzhG935QCK9uTU5atWzgr9ejZXx24nY0CjI6262G48Ow16K8p4 >									
//	        < 2OX03ZVH014Xwy2PT84Z5w42KUGh32y2lwSvFt3Rd3nUl9ak65rIfnhT12KHAecd >									
//	        < u =="0.000000000000000001" ; [ 000055609047405.000000000000000000 ; 000055618390038.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014B74AC2414B82ED9B >									
//	    < PI_YU_ROMA ; Line_5610 ; HK6KT9190RKc8WR80AhS18B22Jz1CehxwKy073LT2izZbtfl9 ; 20171122 ; subDT >									
//	        < J3y2s6QJP51R10jGYUBfQxM3K9VNO73fC340KWl3TcDi4169EnU7ob87eG1iBm6p >									
//	        < P4bqy0s7bncOwF8jspE5L18HIL665wKH8s377V6qgo1zp6pbleABlWNWR5p3tGFI >									
//	        < u =="0.000000000000000001" ; [ 000055618390038.000000000000000000 ; 000055623634453.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014B82ED9B14B8AEE35 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5611 à 5620									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5611 ; Rt7BHe0v566t7hyNXZFlSPKZ3FQt40R5hiyP909R8re94200y ; 20171122 ; subDT >									
//	        < 75lSBPixuuaONpTE63aJzSBRM9hZO4yeFGxa5PKZK28c6ESzFm58jysLb6Lf914h >									
//	        < YryQEApcvrh1wh7Eb329fL5T7id40WGhF2jd7Kdx2vT3cB8m97XBy87QW2BR13Bw >									
//	        < u =="0.000000000000000001" ; [ 000055623634453.000000000000000000 ; 000055635240032.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014B8AEE3514B9CA3A3 >									
//	    < PI_YU_ROMA ; Line_5612 ; fiuEe08pJnl7aysdK1awd0ufEY5TSeCR20slJD0Dx2QezV860 ; 20171122 ; subDT >									
//	        < uq2PttDO8lJMJJxs5b6Z7Ig136sw5d3y6Zm84FD47U0SujK5xoJr47vET1slsteE >									
//	        < Feq29CB5ByI8o8O6X4I9E9otBmlC1i8O4kDoxEcgrShNB7OXcf99Vq4NU3o15FmI >									
//	        < u =="0.000000000000000001" ; [ 000055635240032.000000000000000000 ; 000055646420135.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014B9CA3A314BADB2DD >									
//	    < PI_YU_ROMA ; Line_5613 ; mWqbin8HPNm37vhD80Cn7LtP9475J38OQjcePmaXC85571biK ; 20171122 ; subDT >									
//	        < 2059nYTdJr18Pd05s12TGRSLJp3kdI931NcEY81xO576ZOUv6YXgEKrO9xMZ3G7j >									
//	        < k9bZmwD2g6qJpm25h626e17qf18ZAKzmlE89906iF2uV0tsBu9ds94UQPWz36F44 >									
//	        < u =="0.000000000000000001" ; [ 000055646420135.000000000000000000 ; 000055657387502.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014BADB2DD14BBE6EFE >									
//	    < PI_YU_ROMA ; Line_5614 ; iA0C48Cl8qZ148pLI50zyFfvb78kVtJn57fHeB06Pgl1kj0nm ; 20171122 ; subDT >									
//	        < 3RjpTHTKpUb7u7U07nDLwrq4258Zi04ZFufu2E58e4K760u5jE70qwZiMw51tQPK >									
//	        < 9N2QsEG2m612j6R2x0QS4TXkbLknkk3Bii70WSnJMyANt20R0F78wxpDRtTnDnM6 >									
//	        < u =="0.000000000000000001" ; [ 000055657387502.000000000000000000 ; 000055662695800.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014BBE6EFE14BC6888C >									
//	    < PI_YU_ROMA ; Line_5615 ; 9SqJ4MUP100g3LSQrH3WhMNxrgxNt3oL7LkqOzZ1M9K83g63i ; 20171122 ; subDT >									
//	        < IHsJUfKw6IZJ2rpbDAc6y41UR7ocTG0g1oN99Y3VsJ4r4cGBAm571U8Wc8SAw16x >									
//	        < Aykx03lTo0JW2v3zk1IFqSm91KW5kwD8R0vRR3DXJDedw9IohM725yOhxl7sbcLA >									
//	        < u =="0.000000000000000001" ; [ 000055662695800.000000000000000000 ; 000055669641354.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014BC6888C14BD121A7 >									
//	    < PI_YU_ROMA ; Line_5616 ; w5C37ugK8mErJ4813wu7mm87aEecKIiNK564t9j2bU8k9SbwO ; 20171122 ; subDT >									
//	        < 2zUUGR4Dqr3KoY8sE1H8iwr26lJ44nx1tsmk1Hvft19NMD264ZeAZqk25pyD5ryS >									
//	        < JKN5u5IKZTfRfqqoThVLTeOk4hnBc5lWJ6255I19LVKy62O1GBfne7eMtrPMw39m >									
//	        < u =="0.000000000000000001" ; [ 000055669641354.000000000000000000 ; 000055675486004.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014BD121A714BDA0CB8 >									
//	    < PI_YU_ROMA ; Line_5617 ; b6ib3NJV058ej56wh1Sg6164QEg588RbIpYvAE1D6H37l4CWl ; 20171122 ; subDT >									
//	        < 4wAMS8Pu9XMss2N2bYrsz7pW1i4S5VZXM5mTC60B3WSdE4Bn6Mn4Bk00qSl0Kn8P >									
//	        < lGT7ZOq0nmhER4Q26D29hDKAcMJ5571z6AWlhL1Nnm45Jl760a9J3Gn42vI07u1O >									
//	        < u =="0.000000000000000001" ; [ 000055675486004.000000000000000000 ; 000055687582544.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014BDA0CB814BEC81EE >									
//	    < PI_YU_ROMA ; Line_5618 ; hS6083SmBv4876X6z5FT3Ej27R9r4Cjd9VL4RVZ2T9QGXcd6I ; 20171122 ; subDT >									
//	        < bcjQn97IZhPR5s7NRrH1ksjj78S4UL7eTnHB2D06y89S183mJ45dq2VDQz32qg1e >									
//	        < Z9Cq209K2Y6a3ZzKER5d1qsZj6zF3xmChQVFl673y6q09A214oYJ2DTR9q1Zgjjk >									
//	        < u =="0.000000000000000001" ; [ 000055687582544.000000000000000000 ; 000055699302870.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014BEC81EE14BFE642F >									
//	    < PI_YU_ROMA ; Line_5619 ; 52Vc0MwC06qYO401I1Oqf0Cns306vBzAK6au1r9GcOxN6r4n4 ; 20171122 ; subDT >									
//	        < ZC2ZMAQ74Osthu70JpoO533rOqS7SD95UQq21Q936rXpyR0gvVcM274K5qlrY1RN >									
//	        < RV47FW53jSDU7GIHCu8BND9NO55E46Vxmb4u5RR870sMngwAmCQioea58yk6nzhw >									
//	        < u =="0.000000000000000001" ; [ 000055699302870.000000000000000000 ; 000055712318329.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014BFE642F14C124058 >									
//	    < PI_YU_ROMA ; Line_5620 ; 1NeD6rI1Bhr1CsAO14hC3MOM6168l6898o85r6cPEwr9JqnzN ; 20171122 ; subDT >									
//	        < Ls09HNy22wpsV55WtBaMS48bb6A4594h1znuGJ956QP6X1h4RqL4h5yv5VR89Hw6 >									
//	        < P3khem22tCHE86fsVYLkSF4GyJa7mc913Yu46otCij5Tz1aX7byUcWE2n6Wt4Gq3 >									
//	        < u =="0.000000000000000001" ; [ 000055712318329.000000000000000000 ; 000055721779206.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014C12405814C20B000 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5621 à 5630									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5621 ; xoH5013XE3eDs2O80VMK9Dz84KnOT87sv32C1Oanx4fj795EJ ; 20171122 ; subDT >									
//	        < LH4qOz2oMrZWl30by2KG3Co5fUC1VgN4bHtj6J8BUG6I5Q5gYdDwl1cipAsm2Bzs >									
//	        < IbLXGGVqL060QH88AghLPs6emC0nJ1FcGa0451P001j7RBnNqi8783cDy4xT6fCW >									
//	        < u =="0.000000000000000001" ; [ 000055721779206.000000000000000000 ; 000055736087471.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014C20B00014C36852B >									
//	    < PI_YU_ROMA ; Line_5622 ; Jdf2HJ5qL4AeBa0Y7EtySiIxLiWW2M9OPO2zeBdV0VUcPInlm ; 20171122 ; subDT >									
//	        < T9jist4YQJ2zr81D5wQXkygw42wXX6YWWN2ivPGb7e9LKRIc7pP8b36fB8836q0r >									
//	        < a2EuGYn1y818XE23ASyoa6006n2M88l00pJ5B3aWS52S7kYZ3Ds18ge9LQKYv6jQ >									
//	        < u =="0.000000000000000001" ; [ 000055736087471.000000000000000000 ; 000055748156739.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014C36852B14C48EFB9 >									
//	    < PI_YU_ROMA ; Line_5623 ; DI7MAOHrN9J7o18SSQ1d68uhwc71288b4wGl6wyAUnPQ0zZ0k ; 20171122 ; subDT >									
//	        < og1669KXvgLos6fBs84dM85Kp07ljszCgYX8LT0PbKIA573ajemu14AAi0X6d0fU >									
//	        < EbCv6iMJJ12Gm7ARg4MCt0OvTc4unxJza9I249Tt000YQ1A9bBIw9NJjhDVgj0Y8 >									
//	        < u =="0.000000000000000001" ; [ 000055748156739.000000000000000000 ; 000055762998337.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014C48EFB914C5F9539 >									
//	    < PI_YU_ROMA ; Line_5624 ; 2u6X8GxUx82zp048q8H7HPcx4eR5p1diDq7zPF9DZ7ahRL20z ; 20171122 ; subDT >									
//	        < Y5kqHSJGN9jID1RP8dME9SfE9ygglZ0E7XS3p0hkDxjDX4HWeOCgBI0UUA3LbOai >									
//	        < pmIe78Uj6yt1n82cdGR9ViNel8GMSd8ucur6M988TdSC80D7wwe0k4PaMGKYASqc >									
//	        < u =="0.000000000000000001" ; [ 000055762998337.000000000000000000 ; 000055777492783.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014C5F953914C75B31E >									
//	    < PI_YU_ROMA ; Line_5625 ; wvM67cu1YP9SpS1BrjdJgKUK5ISB5Kij578sfHaI0455si6CY ; 20171122 ; subDT >									
//	        < X7UJb7tu72ja8iXo8ts8JZt508toiVnE4On6cv2TfaA5Y39U57i087O3y8o4TP3r >									
//	        < fIz5218AJ31f246H4aOzXlLKB973U90AziCx7jIYsb9596IJrO2F8lVXEeHE2d5g >									
//	        < u =="0.000000000000000001" ; [ 000055777492783.000000000000000000 ; 000055791742461.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014C75B31E14C8B7166 >									
//	    < PI_YU_ROMA ; Line_5626 ; 0m19fv184NAH3W73mzazP6X1UJ08WL6e72G3KJ33cCClGNNpt ; 20171122 ; subDT >									
//	        < Tl4IzrHY6rdFKznQd2o8nP6e2iI47h60ZF1ScQ8i66D0sVJT8y1I6ecdgA2a0GQu >									
//	        < wcM69Vo5W56l6Cd7smbg9CK17uI1V93LmG10k23js85WMRYuWmwReolE5eUT602S >									
//	        < u =="0.000000000000000001" ; [ 000055791742461.000000000000000000 ; 000055800644671.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014C8B716614C9906D3 >									
//	    < PI_YU_ROMA ; Line_5627 ; 3w0i8h69W7dsSy6KWVV34YjB465n0r7Kdf4iSDP9zh04805Tc ; 20171122 ; subDT >									
//	        < 025U51mt1X0zS50QjKvAK74gJBf3q4yodWl5Z27gH86O3Tm54y3nIWMZ0PojH5gt >									
//	        < KUcTTs5G541AOvcb85KCHh2auM8G578H3Y9lPLwPd52cAPj08McN005971SO1sC0 >									
//	        < u =="0.000000000000000001" ; [ 000055800644671.000000000000000000 ; 000055812458508.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014C9906D314CAB0D9A >									
//	    < PI_YU_ROMA ; Line_5628 ; u1cn6683AKJO6R59T63UN0cVrL77C1Sq4chsqbV22ky5l86t9 ; 20171122 ; subDT >									
//	        < C5Ev99RoA2kvK62D92fw9MA51ckW9hUwX1oz4g0pm61dpG0XRbJtV0f76R3NHT00 >									
//	        < o0s1WBwlEX48T09xQ7YWVkFLL0Z09W37dgATWRdX2Yh4OXZ98k4lkUyb6owpy98C >									
//	        < u =="0.000000000000000001" ; [ 000055812458508.000000000000000000 ; 000055824295178.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014CAB0D9A14CBD1D4D >									
//	    < PI_YU_ROMA ; Line_5629 ; fq2Dy8Lx5p65Qd58wHj7ViOgEAqKFkthMwvZelYWtPW848p2B ; 20171122 ; subDT >									
//	        < 6GB5tg2KaHNqt1V7gOxf7S7i4M24q34nT6m5GkNM1Msdf03v88qQtxVtj6UBpZ1l >									
//	        < hGC8w0BKME71nGgs05Es979E0HPD6x5Op6H27vWGs1919GI10Nv79a132z2l25ZP >									
//	        < u =="0.000000000000000001" ; [ 000055824295178.000000000000000000 ; 000055831457177.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014CBD1D4D14CC80AF5 >									
//	    < PI_YU_ROMA ; Line_5630 ; 7Q478hSO1C88HC78824071oLc97sG9W5S30Nq2TDux81Nx6Xn ; 20171122 ; subDT >									
//	        < wE87WXL5IH6KCDY10450mX0l9NF2Y3uQAce0J74EJtMjit7Nl6hADLwgR58P33Hv >									
//	        < 4u105dGyqZVfp3602H7HrO37lkM8165q53mDb034jYO92m5c9I90S6NmQ1Tot04K >									
//	        < u =="0.000000000000000001" ; [ 000055831457177.000000000000000000 ; 000055837385957.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014CC80AF514CD116E3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5631 à 5640									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5631 ; Ty86eC56eHCSrbxpay4Plkpi70Tmytu4cL8TP49FzLueKZK4g ; 20171122 ; subDT >									
//	        < ZQNcfUhRMpLYwc3G36pW7qg2804pTmXa2fAAplq1R3G06mJtFQ3hTzViu6Ee8tf8 >									
//	        < 3J0mhdq7o8HQ9eF77pV3OlfbtQm26ovI4mFOZbBvDOP48x2rs7OB3rJ179Q8WDY2 >									
//	        < u =="0.000000000000000001" ; [ 000055837385957.000000000000000000 ; 000055845140999.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014CD116E314CDCEC33 >									
//	    < PI_YU_ROMA ; Line_5632 ; eO9bPrB38NUQszCk5RTUVzUieIBj5Zj8o4B06G1kd6T43r9xk ; 20171122 ; subDT >									
//	        < HNlw2e1BT07267Y3bl882M3v2975m1n78h7gY6M94m47qR6F2nb0qMoQf38q1FZ0 >									
//	        < 70Tg1Ju298pbu6wW9wwypqsHJjlRi812GDlJM6ankbdx74z9coIeQYEjIdJQ4Hou >									
//	        < u =="0.000000000000000001" ; [ 000055845140999.000000000000000000 ; 000055850616100.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014CDCEC3314CE546EA >									
//	    < PI_YU_ROMA ; Line_5633 ; MoJrTJcGF4kNd3FqGtr3q0F6L11hxfNCyv11EcNW4xpDn3Pd2 ; 20171122 ; subDT >									
//	        < eZolt24Ak7S1maUWLf3B8phs4n1y7tqjBt65Guo3tKa9J59uhQhOGJXueaBZeFdg >									
//	        < 4tM1wgVCJX41llL5RBobfQzj0AwPJbo6x6CI8LKcWF208S6r4vW7bBfv6r6ivjQ3 >									
//	        < u =="0.000000000000000001" ; [ 000055850616100.000000000000000000 ; 000055863158819.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014CE546EA14CF86A69 >									
//	    < PI_YU_ROMA ; Line_5634 ; b48mQGg7xA30pxXpQf30bT6yAVqpo1W5w8Ja2TgKojU4M5SAn ; 20171122 ; subDT >									
//	        < 7nyZ01UGD76OrnHYpxHD2MEIMrxH7pbjyE088xMphL8E2f5rxUz963qiPdGO0F9C >									
//	        < g4n57NTYFBjcs77qZrJOpHB1RDH5kIh0P52OX7DIN12Bigg3eTr75jTh8O3Z1298 >									
//	        < u =="0.000000000000000001" ; [ 000055863158819.000000000000000000 ; 000055873743182.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014CF86A6914D0890EE >									
//	    < PI_YU_ROMA ; Line_5635 ; sERtAiGU2E30TiOmgzvfiJvMXVkWdW46IxS1A47YG7e833Vzf ; 20171122 ; subDT >									
//	        < 93k4AVR4wYYLScW1t1vL9DOHEm8s3NxD7EWe9W5T0U2e64tig2Oy7kRIod41dKLQ >									
//	        < b5Qwd3Cf7yTUeWpx3tQ7hKeliJYVFdB6I8ZB0Eu2n6CI0M105WI7W475SRkqtvZ3 >									
//	        < u =="0.000000000000000001" ; [ 000055873743182.000000000000000000 ; 000055879794843.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014D0890EE14D11CCDC >									
//	    < PI_YU_ROMA ; Line_5636 ; G2wvQlJHnKYP39Jh8D5Q1sxu4UaqGgMdb9gY3Q06FBAz72D5O ; 20171122 ; subDT >									
//	        < P66xHdVCPF1Yyg2Kb5m4hiFi9jx048r0YfYvmtg7n6F7HWAjmfeKCj73Qtk59jOC >									
//	        < CzOcy1rMCmajz28dk743jp5lP80f92N3wrcGaD9rAP19YW4d7j4EVGnmEz87s8R9 >									
//	        < u =="0.000000000000000001" ; [ 000055879794843.000000000000000000 ; 000055891921667.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014D11CCDC14D244DE6 >									
//	    < PI_YU_ROMA ; Line_5637 ; BsO87Z0xR9Tjjlxs48M5cm7AN8XG3T811tD4iUpmaLGfI7G8D ; 20171122 ; subDT >									
//	        < Up2588MtAIriPDah0PF6wM99sdp8xegj9fnDr2OvLX1IMy0SGS7WZidXXWO9jp6z >									
//	        < Y2khc8KoQh2u8hX6uR68tQytLU90jo17zkA9ukTv80kkUI4R7mMk3hNBuxVHJb7m >									
//	        < u =="0.000000000000000001" ; [ 000055891921667.000000000000000000 ; 000055901659093.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014D244DE614D332995 >									
//	    < PI_YU_ROMA ; Line_5638 ; WOszg4Z5wRX07Ln6S800iLfoXSC1JZ0v56s370V422X1CSg8p ; 20171122 ; subDT >									
//	        < 6p20Y75Y3sSS8RFe883U1c5FrENguXF14U6UOpMjCOZYFc6FeGaK0g45981rppck >									
//	        < cjGL7wR4i3dBbQm0DLN3P7BuYJ6xq3R1Wot71iKjpuTM7P5bFMNm95ryfVmb26h2 >									
//	        < u =="0.000000000000000001" ; [ 000055901659093.000000000000000000 ; 000055911813372.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014D33299514D42A819 >									
//	    < PI_YU_ROMA ; Line_5639 ; 3HW69fv99MzS00TZ35D2IAT4mTAv87d7K2Z7Y12vFF0GEeZ3x ; 20171122 ; subDT >									
//	        < V893H5w6dB8k1cMB1uPS31Gzz781FOS2IuPAQ4nR6uA99b0N4GxCAFhs09k88n8O >									
//	        < 3JN61xI1H8ssVdlrbj4Ik29TrIawCPPD6o2ic2P9e4RYYy6IQn4E9XHBGP0jFt9p >									
//	        < u =="0.000000000000000001" ; [ 000055911813372.000000000000000000 ; 000055923021481.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014D42A81914D53C244 >									
//	    < PI_YU_ROMA ; Line_5640 ; KImHqPp4pFTB580sUpDAuqjfuUjxTY7P8h88Sm93jLaU93809 ; 20171122 ; subDT >									
//	        < E13VRrOw3btxUoOg1N4f9jN8PMe8Kkn2LbHa9EwqXc3RTcZ549CwxI7PX8hu70BW >									
//	        < Ye9zSA8jHXm7dPfHHNrxYouU61x456gjDZ691k8EWelQW1774wiiQp47Z0QwEq07 >									
//	        < u =="0.000000000000000001" ; [ 000055923021481.000000000000000000 ; 000055930540883.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014D53C24414D5F3B88 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5641 à 5650									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5641 ; J46NMO9A28o171tD4tHgcT2RY2M25Y0G1iUZFJr19YGl66rcs ; 20171122 ; subDT >									
//	        < 15YdT8s080v3RKnbg13lt9NoEDmz2C6JulB81m1NQjfz4P5kR4MyAe2vpt11h6mL >									
//	        < fL2X95Lzp0x14vJBLG68GbzSplUxY193GP4277rI74w9fFd6n2SZ7Xnbk03lt7QZ >									
//	        < u =="0.000000000000000001" ; [ 000055930540883.000000000000000000 ; 000055939963945.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014D5F3B8814D6D9C6A >									
//	    < PI_YU_ROMA ; Line_5642 ; 62xLV41RxhWi4K0k46f37VK6q465Ely56Rx8NQc77ZrQ923AO ; 20171122 ; subDT >									
//	        < P8E808oP8E4zXi2Pc1M4Nr9x81Fd8x5JjJH5NpUh36780xpy2lEz924ggI1M75p5 >									
//	        < ROB37RsPD2Y4oCkpBKt02p3NMh1SZOAfZ1S0kthyt2MdiIc2keO9dI07ro46148r >									
//	        < u =="0.000000000000000001" ; [ 000055939963945.000000000000000000 ; 000055953470339.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014D6D9C6A14D823859 >									
//	    < PI_YU_ROMA ; Line_5643 ; 09B9Yc4clqT94504Ejxyj04sOc9xiH141Z8Fmd9WcnYHXEp9Z ; 20171122 ; subDT >									
//	        < MsVmQzJ86z0F72hUT3LxgVZJYrgdeXr2bcNZr6il51bnw5u9iRxA96Ze91gRkBk7 >									
//	        < 9KVVNHq50VqlUPA4udFg9YyKd04JqyL9qzDopOyJDdlmBqeEIG62Seq0XzLFqMlm >									
//	        < u =="0.000000000000000001" ; [ 000055953470339.000000000000000000 ; 000055960399203.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014D82385914D8CCAF0 >									
//	    < PI_YU_ROMA ; Line_5644 ; Bwt6a4BIv7DU46F0mxhQ8j4LQQ0Y6jXOs6ojYcO92Z7ijIy03 ; 20171122 ; subDT >									
//	        < MWDk4rT5eg29n3V8N24PaF6Tz5xTr71t633lk3xLSdB92U90vHy91rB89675dnI6 >									
//	        < R2CsRO8QpAEIp4Fv4H34az7c8VjSG10M5Z4ipHr7ngtUF1y2Ss195k8Gq1n2IW7k >									
//	        < u =="0.000000000000000001" ; [ 000055960399203.000000000000000000 ; 000055965735110.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014D8CCAF014D94EF47 >									
//	    < PI_YU_ROMA ; Line_5645 ; 1xB0ph6g5NvyFr3doGq1Mp8tLCgG2CbGK034f41AYRMEIZ9Of ; 20171122 ; subDT >									
//	        < htCrR33SxuA5205Y77B7wfTBNnG68gf2FAb2Vi2AJockiX9i1g7vDqcS5zrn7dR5 >									
//	        < tHY59620yEz3yMoTy626qEAsRadttJrl6yN6wm22535Xpx42AC5p395hTE8bL4Du >									
//	        < u =="0.000000000000000001" ; [ 000055965735110.000000000000000000 ; 000055980034454.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014D94EF4714DAAC0F5 >									
//	    < PI_YU_ROMA ; Line_5646 ; aX82H3e8Ju8039EY26RWuQPCtN3AYny8fNf04jQKxmkkuhddt ; 20171122 ; subDT >									
//	        < 6dQzD6KQsFexrsEigJ0Q6JmMSmAG3x259N0n2Y0n79zfIHQY6kOvg8vY5oEWI5uI >									
//	        < ZVSH2L5NOZHtJm18uZetsJExT8KJulpt4umcXdtRY4reEg32561V2JH9j203Rghp >									
//	        < u =="0.000000000000000001" ; [ 000055980034454.000000000000000000 ; 000055994778533.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014DAAC0F514DC1405D >									
//	    < PI_YU_ROMA ; Line_5647 ; 49Et802i2Ll8yy8nilJ2zuk10eND4gX3nOtzp9yL2M5iY0nWe ; 20171122 ; subDT >									
//	        < 92Uj6nI0rK0Fv167Cq50iq3z7dv88BT1yiSzdZ6cB9kdD28QjDgc6bhDXKpgbdA3 >									
//	        < YGnn82x15nO3jrMGRc714fkki3dXY10CNhlnYt2RlcRk8969ZEw13d53FZ6i906l >									
//	        < u =="0.000000000000000001" ; [ 000055994778533.000000000000000000 ; 000056008366243.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014DC1405D14DD5FC10 >									
//	    < PI_YU_ROMA ; Line_5648 ; ogS9F6RFcyTE17574wzOnX8LMw7lFPPUQ1W6E3lZ9M96d82fi ; 20171122 ; subDT >									
//	        < Ue4W9t84ICOO4dfB0fwLgxzWsU7iVFLflka1f34EK2ZZaV4Ec9HBb4au66Xd2bFz >									
//	        < oey57Vi42jUGV71ut2mkAcsy65c8giGUV8gCdUWWmbwsMqez7A1vnBeInGB6T2H9 >									
//	        < u =="0.000000000000000001" ; [ 000056008366243.000000000000000000 ; 000056022959435.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014DD5FC1014DEC4087 >									
//	    < PI_YU_ROMA ; Line_5649 ; 3twm2iFq361od1wtu7DgZrH4lO4NP180Z1i7c3epmth0f9ED9 ; 20171122 ; subDT >									
//	        < E8jc3yM681h977qtC0bvM48vpmmPE2f4Nj0q1v4r2aukEn8UxKVb08TOPKG9STk0 >									
//	        < fyKvnaz2Umg0U3zTIT4HMMf6M5QnIds9p6pSX18Bp6y46hI7vq2MEWu17981Raab >									
//	        < u =="0.000000000000000001" ; [ 000056022959435.000000000000000000 ; 000056035673055.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014DEC408714DFFA6C9 >									
//	    < PI_YU_ROMA ; Line_5650 ; tI7L46g4i89A8xdX68Zp78MHjoXzvX9mSUayxwC9jv4fJlz3v ; 20171122 ; subDT >									
//	        < p4ZCY6zM3alos1dYC3A0ZNh4JPv2Bh5P1q2v920ix7rFSOkemnTb2xh25Xkcrj1y >									
//	        < 1oAK43mehq9bA0d3cSAw8kt31SIAkspy24CQQ51BIUw8nz791L7a0P33686Lg98i >									
//	        < u =="0.000000000000000001" ; [ 000056035673055.000000000000000000 ; 000056042211248.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014DFFA6C914E09A0C4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5651 à 5660									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5651 ; Hd1STQoz0ZQUWkr6WgB95kN4gb18cbceH0u2RjK89szju2ddN ; 20171122 ; subDT >									
//	        < WMoJBmsN052SGE68D82PMpkqLuXQEpmHL773u5j468wy2KIc1xkYD7526NTJgTkp >									
//	        < 1di7FdQblmfz2L44pgIMiDi0vt05yn6Y6q2JX27Ml1Xd3NL1i1wTEcHUY7em50Bt >									
//	        < u =="0.000000000000000001" ; [ 000056042211248.000000000000000000 ; 000056052859272.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014E09A0C414E19E027 >									
//	    < PI_YU_ROMA ; Line_5652 ; 3K1Gu5Pz9p4iZDx568o1iqKqO0q7a6T27M3uVzm3F51iNLe6U ; 20171122 ; subDT >									
//	        < 1S2A24X9Rw17aKYPKXo6pV7ilhTygfV7XP477uq6K47o138BA9w6Yc2Ve1Dx053M >									
//	        < PzCsL5129IZnrfjWZ2I5N5757uRNknrz79s664T98F17RW99x74sxN04H5s6l759 >									
//	        < u =="0.000000000000000001" ; [ 000056052859272.000000000000000000 ; 000056066191959.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014E19E02714E2E383B >									
//	    < PI_YU_ROMA ; Line_5653 ; TbVBTZj0L82G45CTL61FpG1LEKhe1w0e02lCg51gTn2T4qMe0 ; 20171122 ; subDT >									
//	        < rF8O710hEXAiJjI78TTlP87VrbKzHNAs27Mrb017JWn0KW3Fzb7LFla6bhAGEwm3 >									
//	        < y1O6gDPewCXSJ3T35wJyb49bSFC3P6zkl8y1vuvVVUs2NzykKFSNlv8Ht3X4b707 >									
//	        < u =="0.000000000000000001" ; [ 000056066191959.000000000000000000 ; 000056075669296.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014E2E383B14E3CAE51 >									
//	    < PI_YU_ROMA ; Line_5654 ; X3g5gEq3DQ4A4df600B6ElkdRUYqxUNZdGarLa7cM3jtT6gOt ; 20171122 ; subDT >									
//	        < CYF5998t2LX1A7uc5vhP988t7lrc0l4wZ5pJ76jwccn3OAJu1z3Iy681HEz75ILT >									
//	        < uDp2Sw6l0ZjAxLMC1OMwgEz53zIiNZPQDdX40cRqfIj73hY0ML3Al5K5vUAZX7Ww >									
//	        < u =="0.000000000000000001" ; [ 000056075669296.000000000000000000 ; 000056090468836.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014E3CAE5114E534363 >									
//	    < PI_YU_ROMA ; Line_5655 ; 3w38nR5z303vbp4iaY85FD7b948pGE0gafcQ3R278YfDqeUU7 ; 20171122 ; subDT >									
//	        < eH82k28W11x0C50jL9zNmJWn4u79j8dzB78QamqYFmRA7VmR5a24H2LdX6r5fH2h >									
//	        < 1Rd8knB049YoK5ktN3116N4i4B6K97gn8f1xu896S8Dfa5k1FSwfxV009w3NyUMe >									
//	        < u =="0.000000000000000001" ; [ 000056090468836.000000000000000000 ; 000056104889680.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014E53436314E694488 >									
//	    < PI_YU_ROMA ; Line_5656 ; 7sr14v8Im2ETw7uM6VRuRjEv13J3pU1l9b7owZ21gpw4473lo ; 20171122 ; subDT >									
//	        < GRDI0FUGJ0r3e90c35582yBNC4Olp4N8qhccXIHNtzs1vU5xDDSO0f7y14HvzzJ5 >									
//	        < Gp778NwlxrX12ev4O5n62U4hCLO5b0lnm2A7K9i4yo129XAKX789MsS284N5991q >									
//	        < u =="0.000000000000000001" ; [ 000056104889680.000000000000000000 ; 000056116657828.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014E69448814E7B3976 >									
//	    < PI_YU_ROMA ; Line_5657 ; 0mY8484a0AiLLh6r56FB30O58HTppzZD24QmR4kcP0rYV54kr ; 20171122 ; subDT >									
//	        < wZz8fH79nmL0Vw8A61sauNr8lBixc1b5Roj4UA6jyFf80S7FqZ50ebw68C03b4LN >									
//	        < vEuOx42d1l10GcJ5r91U91d43S0684LFoj04ln5tUS5vWb7cr1ISEy1NmN76X7mM >									
//	        < u =="0.000000000000000001" ; [ 000056116657828.000000000000000000 ; 000056123097814.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014E7B397614E850D15 >									
//	    < PI_YU_ROMA ; Line_5658 ; S3zmm5P0qOYYgHa5jFqZaICi761j18CismfcyVUn9EBnpHopw ; 20171122 ; subDT >									
//	        < DpOA32E9MNH9Z89Hptk7FORTz0wML8Y4LjRs5G5MqX2r3qkAv6C2fe2j63Dqvrqi >									
//	        < 17Ob5b8G4q15cBVT9N5wj39G972J0G0A3a7xW2T9eXXlZk94gMOM58mwcZG6ll0q >									
//	        < u =="0.000000000000000001" ; [ 000056123097814.000000000000000000 ; 000056129548244.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014E850D1514E8EE4C8 >									
//	    < PI_YU_ROMA ; Line_5659 ; i6dBUVtV10RncX325fC23DHo79Z4Qsi1Yf1NUcw71Y87XGlmZ ; 20171122 ; subDT >									
//	        < RfP5F8TUo4LZ08o94vckq3OzSo2281vF050Xx82CU5jfY9H7aeC149w4oqHK8Gws >									
//	        < ZZN19sH4q61W5rz2I39IJEdfSy2KK7na3kUL56fsOcH7dti9yJw7gr5eQ881Vy1w >									
//	        < u =="0.000000000000000001" ; [ 000056129548244.000000000000000000 ; 000056138971467.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014E8EE4C814E9D45BA >									
//	    < PI_YU_ROMA ; Line_5660 ; qzfrPfv5zs4ApSJUx4pQJ3R2854vcflpm775a4LD0305TVntN ; 20171122 ; subDT >									
//	        < c8bkY7sorPo1ywhPzerVf107Sl3qou0R3HR8m9zB9apXkMREhg090V4V568xHMX2 >									
//	        < 8T9hIkrJV2Rt6219C6vKFiLD2KA6vYI44GYSK6f62m9wyP4P9wu1rUc51205rOll >									
//	        < u =="0.000000000000000001" ; [ 000056138971467.000000000000000000 ; 000056149208459.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014E9D45BA14EACE48D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5661 à 5670									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5661 ; U24guKc6VqovW6kH4d6k6gu7u509aSs1NUnaln1E2dBRtjZwe ; 20171122 ; subDT >									
//	        < HUEjGp8iAdwc3705u826RoD25C2oKI3d7HubF1mYT17LXj1T41BoGnDtP80C43b6 >									
//	        < NyxlIM8P06kTA8190rD9xeRGxvKRO8RJNi2LNIvtHS22Q9OYFzb2zXmoE8w79O3V >									
//	        < u =="0.000000000000000001" ; [ 000056149208459.000000000000000000 ; 000056158231625.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014EACE48D14EBAA93A >									
//	    < PI_YU_ROMA ; Line_5662 ; U3r012heGED53C1N2dk3Ic8ugd9Uw45sCxYO72P6957k21tpb ; 20171122 ; subDT >									
//	        < qwTJ275V4VsPH8Jkg2XFXWBPhy500TCQ5RCiHFm37XGyLu953986nGx5Fp7Ju0OY >									
//	        < uPYcbvT18lpC3VR10wZMj4YT1J94I100qUwPE1aVN2X35De3r9Dr3zLR4GftWR38 >									
//	        < u =="0.000000000000000001" ; [ 000056158231625.000000000000000000 ; 000056167281308.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014EBAA93A14EC87842 >									
//	    < PI_YU_ROMA ; Line_5663 ; FKt33fTWK6K03l8ZocFKI5eYK289cIz947vJMV4Oilm83bJ7w ; 20171122 ; subDT >									
//	        < nm56oi5d604lKRAAizGPr2G7Io5c49O5kX9EeM92CxE2mw3f864mGSXtv92qbBfa >									
//	        < BI9q99KfGMZ94b3ZT9N2r48rmCOmqyTtz72y2o51utDXCG6GSn5w4Nl3o93xajD8 >									
//	        < u =="0.000000000000000001" ; [ 000056167281308.000000000000000000 ; 000056179348548.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014EC8784214EDAE206 >									
//	    < PI_YU_ROMA ; Line_5664 ; g1AmZ1bH7Qsw68Gw6JC158PC8H1bO7MFWh368nMrhEm01800v ; 20171122 ; subDT >									
//	        < 7ApFrVlK8830muGXn8F2fXlL0p89LS2f85Ei5yaRVFF470dsW7CJp3Sv5hr6f5Z7 >									
//	        < psUdFnYghC65kvK9w11p3NnX70Vw4qGa4D6U5TQUXeoSP3D00YsWQdqNmO4O27Gd >									
//	        < u =="0.000000000000000001" ; [ 000056179348548.000000000000000000 ; 000056189246622.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014EDAE20614EE9FC76 >									
//	    < PI_YU_ROMA ; Line_5665 ; NM7fdlvem9jcyf0jHfRk9hT4trZuZvjK50Xt2cepy6Z3JNTr1 ; 20171122 ; subDT >									
//	        < 1XKO3RfD4Z19pYVbcn503oIGvYotFD64I3fm2AvkM1V0CX3obsR2U0vlWOsGq1zo >									
//	        < 0P6FNTufr5K4IstxibVbM0d4xY6fyrT2hk4fdQdRilXdIUIU6rBU2xJa9Fw79lp8 >									
//	        < u =="0.000000000000000001" ; [ 000056189246622.000000000000000000 ; 000056198619894.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014EE9FC7614EF849E5 >									
//	    < PI_YU_ROMA ; Line_5666 ; 01kWHxHko9yqmPX95F5L4WP1sww6MNC2369nKEQ7h65XxMFmK ; 20171122 ; subDT >									
//	        < GVby1aQH2Vd6EuLci9ypc3r619348784qhF79EX7TjjCdRcD9v36v2sLVIB5rs0I >									
//	        < FZ561TCC2S5j98snx3ZC7oPtnhh8qJ5Li7ycSm8dVZ6X0stFZl5U072J84ibD7lc >									
//	        < u =="0.000000000000000001" ; [ 000056198619894.000000000000000000 ; 000056206119687.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014EF849E514F03BB80 >									
//	    < PI_YU_ROMA ; Line_5667 ; 4n8h8Y620Hc0IVS5Kyq9sQSacVV75qxP8s8400X18NhaIj657 ; 20171122 ; subDT >									
//	        < 881Y3l93k8AY5W6fYNuUt3qvoVkIbQ6Kutzw2Q19BoixBX2vZvEp4BT1ASkR0ehm >									
//	        < N08Y5xORJzTOSE10NfrQlqw5zdwDpcH00XPp557w9RysW40LgiDYL9M3t4Hc8Rx9 >									
//	        < u =="0.000000000000000001" ; [ 000056206119687.000000000000000000 ; 000056214197690.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014F03BB8014F100EF9 >									
//	    < PI_YU_ROMA ; Line_5668 ; fJk0bG78iZ4KonY1VKr7qDN4yCy9P3AY43QylOJEfh2g370Q8 ; 20171122 ; subDT >									
//	        < MhUl91cEcG0d82O0fBybHbnIYvk0oDdGRJMe1uPNG3B3EqH3mlB6N7WLk41c22OO >									
//	        < XsmA8KQyu296oTTMNPUKm649ZDb7Xm65ab9v6XrOVD4PO7IB860H4J08Ju1jWr77 >									
//	        < u =="0.000000000000000001" ; [ 000056214197690.000000000000000000 ; 000056227467426.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014F100EF914F244E76 >									
//	    < PI_YU_ROMA ; Line_5669 ; kMzZO0a4lX91PdkJH9kLGb7L3W33CujwT59Tx6MSVZEN38X9u ; 20171122 ; subDT >									
//	        < ms0559XOPQ249jCmep9q40gR9b971038G7F0tmfWcAJ0Ow47233G5KzWXCvClKoB >									
//	        < 1O4C0bgsGd9t4o4Ltp410RNnfDZS38AlzAj3iP389lNY7ILrM1Y54lCx8MRW71Rv >									
//	        < u =="0.000000000000000001" ; [ 000056227467426.000000000000000000 ; 000056237065649.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014F244E7614F32F3C4 >									
//	    < PI_YU_ROMA ; Line_5670 ; kPeKFKb60jEsZqCh73km7J5E357ENs31VZRL1XMfT7e1A684s ; 20171122 ; subDT >									
//	        < vKf543FLZhTCr76U2EN6kZ58j9ehZ9SHmffpOwmL24yO4Z1u588rn37KF6a2EImo >									
//	        < QOU1fY5BH11323i8s1tp8yeh1KQAX3e5Twkep86r86BZiv73Mwc5UE7jvq0Kpqdl >									
//	        < u =="0.000000000000000001" ; [ 000056237065649.000000000000000000 ; 000056249193700.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014F32F3C414F45754A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5671 à 5680									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5671 ; Z6m3V3d21vg5EfT05643HjxjGRka7oJ7Ss9686vkpV1d25jYu ; 20171122 ; subDT >									
//	        < 1R7jzziBiYWVLp4jNGjecqz9T566wb83Qi3Ic97Q93khba5NS2dx4Nn9Ci073u9R >									
//	        < E7VveMl8zmUf89pHvp7Sdtgx0bbc346Cr24LI882Npy5Yp7beWkbGiwuFTXehX1E >									
//	        < u =="0.000000000000000001" ; [ 000056249193700.000000000000000000 ; 000056256322083.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014F45754A14F5055D0 >									
//	    < PI_YU_ROMA ; Line_5672 ; THBsX9fH8zuyFen1d7g7IEP7v1S8Xx4V4wXY3fwzOM9H63V6w ; 20171122 ; subDT >									
//	        < 3FU76Lp66Lw1nz8NN7ziPpppM50m101Ir24c04aqfaXTw200EE7LRSME13647TCv >									
//	        < G5Ae0YQjbgtJ4H6iUr5tqi1OGB1bT07xp20907JEp3Dpoe3JjkTiao7g7IRuK3by >									
//	        < u =="0.000000000000000001" ; [ 000056256322083.000000000000000000 ; 000056268779291.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014F5055D014F6357E9 >									
//	    < PI_YU_ROMA ; Line_5673 ; eYon5q7M0PbqKAie5Rh2t7F0g7LNOz8m2737jVyZIi23qpfdX ; 20171122 ; subDT >									
//	        < Yf6I0qil4cHtB3q56jy3CZj7H3mVo2fsWf7HB53yeiev84Yp4N37qXOFeQtzVS05 >									
//	        < UltQHWcKr915j7RQd35XdQ51rwOTt7TObGAt02KR21fK27Z63peZ9jwW4n72Vx5U >									
//	        < u =="0.000000000000000001" ; [ 000056268779291.000000000000000000 ; 000056273817628.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014F6357E914F6B0802 >									
//	    < PI_YU_ROMA ; Line_5674 ; XR6aTrmrIZPNb9p1mTAJt0pvzHvnoH55726H5229vIR663jWE ; 20171122 ; subDT >									
//	        < t66ft8o59Ip8flMLuVt009KqALPyuzVWiy0HYusaLztwlj0Bt1ezY6XYrggtD6BZ >									
//	        < er8nzoFsploBXfZyJP8666Z8t1u368TAG350Ms54w33N03Zf3k61FUYds0HFjs68 >									
//	        < u =="0.000000000000000001" ; [ 000056273817628.000000000000000000 ; 000056288649146.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014F6B080214F81A992 >									
//	    < PI_YU_ROMA ; Line_5675 ; f4lFCcqJrYTJJIU53IT93f8U8uKN6K625Ok4ID9CDmksAt8WZ ; 20171122 ; subDT >									
//	        < f1BC80mXkowgGnw1Ho4Rf90p1NXHzg7sR7H7flfe59yMn53HMI6EWyrIjo6Z6tvf >									
//	        < 2wl0tJUboO70e24J2euJE00P87o1XE6jYWn8FEm6qQjrirk3Y17SgnpvIp1bUQsJ >									
//	        < u =="0.000000000000000001" ; [ 000056288649146.000000000000000000 ; 000056296829614.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014F81A99214F8E2511 >									
//	    < PI_YU_ROMA ; Line_5676 ; CY8GK8yMSj9Sps8SXh6g47y9F83UAJbG1XmZ7i5l5lXZYMGvg ; 20171122 ; subDT >									
//	        < vdAajP7Oa8E7db96Vc3DX5bNkO6Pa7941j03UwZm7vv2562gC9Xirqm3NT8zDVMn >									
//	        < u6DQlAYoZ6t2qxs9OgoM6mTHPs5V84OT7XstQ8G4Q9uet1Y6TSB9y284djb29H9O >									
//	        < u =="0.000000000000000001" ; [ 000056296829614.000000000000000000 ; 000056309981956.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014F8E251114FA236B3 >									
//	    < PI_YU_ROMA ; Line_5677 ; d93kNN1g8PwSHyJ19xwei3KYbi8qM4Dmv6e2dI8N4608F4t5E ; 20171122 ; subDT >									
//	        < Ec6005B2cSD2qZ2X1Q1k59B38405e6LSc9y9d83qzUexoCy0TCK7URW80ul3N6Jb >									
//	        < 3w788o3272bV4dx5veUlFNRpleeoybj77A4YripCNGU2J2uDFm9C99eVIMd9JgC7 >									
//	        < u =="0.000000000000000001" ; [ 000056309981956.000000000000000000 ; 000056321607412.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014FA236B314FB3F3E5 >									
//	    < PI_YU_ROMA ; Line_5678 ; 88sUg0oXtcxDfsycMs82XnJ9Uyw5VcxAFQC0oETC77P2tUzg6 ; 20171122 ; subDT >									
//	        < t576JBzAL65bw147GV922r2620SwU82G6Xw0suKE530j2gVj04Vm6XWe9c0WrgZR >									
//	        < Z3E8Frt5KKeC6zi08a3BUfmoFhfj2Jv2q3RW8weTJHxqdogV4t173f79361MwF8N >									
//	        < u =="0.000000000000000001" ; [ 000056321607412.000000000000000000 ; 000056334089889.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014FB3F3E514FC6FFDC >									
//	    < PI_YU_ROMA ; Line_5679 ; Viaxo8tqPzEyQ22OJiwpB9kX9AS5eDYrrsO13uZa3hhqt3VR6 ; 20171122 ; subDT >									
//	        < a9euSieW36S9Fo44lzOp9lS9Lp11ZtYwF4WWx9kRHZjHx13eCC6kvP29Y1e3nMUt >									
//	        < 1wy8rhW4LU2fcb57zR4q2Oa2sHRNS412h41d53Dq49Tue7o1o8lYBGvV92860Pus >									
//	        < u =="0.000000000000000001" ; [ 000056334089889.000000000000000000 ; 000056340625333.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014FC6FFDC14FD0F8C5 >									
//	    < PI_YU_ROMA ; Line_5680 ; 6b2G94uni408eaQepS1p8BMDSa0TEf088ajm28YvbFHr50kzQ ; 20171122 ; subDT >									
//	        < YuzDNBvvMU8ZIicrtGCs9JLa98SPh9XF0d98LtXHjlImmEI3439aq6O9J2cuT5TK >									
//	        < qCWm4dFG820ykr8Z48O5kK9kQZCA5BF5Xo4y4QTo8ypC9Q4MtMunU43vJ2FZ8Q49 >									
//	        < u =="0.000000000000000001" ; [ 000056340625333.000000000000000000 ; 000056355325800.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014FD0F8C514FE76724 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5681 à 5690									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5681 ; S504NJ5M87SpArVMlSZi9jCwK7O2bZQ13Yz4DtPbFm8lz6Gbm ; 20171122 ; subDT >									
//	        < T178HZk2jC9ONgHn020SH9fvdFW5687SuJ9YmC2VW3V0vr4hfD12a56ut278N1MB >									
//	        < IeUFEP6gj99TrZaBJ7UG5VdGQP97yMwjE3cn3007sVY4bLvJD5TPSJV8GY4x3y4V >									
//	        < u =="0.000000000000000001" ; [ 000056355325800.000000000000000000 ; 000056369965554.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014FE7672414FFDBDCB >									
//	    < PI_YU_ROMA ; Line_5682 ; 08ada8s4u8aeX6w07C017W9AeKeav3tS2B9GrX7oh8N6qNE6h ; 20171122 ; subDT >									
//	        < b2r9M680sub4yWk26CY0a79qRsKJu2P32ArRXrJ53KHC4iMI5SxURqcajG0P0jUp >									
//	        < arWw87j152eZ07toJqmcY2momlnUMYmWSwx3ea4l1GBIbfbu0Z6ysf35Mkz2M3R5 >									
//	        < u =="0.000000000000000001" ; [ 000056369965554.000000000000000000 ; 000056382841772.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000014FFDBDCB150116391 >									
//	    < PI_YU_ROMA ; Line_5683 ; tE99ybZgj6V9Wra82pB2cnR0O3854RUkE68j3IjqE1iJ44Tm1 ; 20171122 ; subDT >									
//	        < 9ZyGtwtM9O826k3l2qT2278I994482995K9JZ84DAzZJJ4Z3ro72J17RY618XG67 >									
//	        < 4w98TX0WDR4TU50yJx0OM6RCZzg385j8Wp8x5t8PW7681OXDfdnr1CgZ6732G2Ap >									
//	        < u =="0.000000000000000001" ; [ 000056382841772.000000000000000000 ; 000056393912812.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000150116391150224831 >									
//	    < PI_YU_ROMA ; Line_5684 ; 7CLA6a413ZjH6NX7LTaTM61VSm1q4gO902VxAFBQ0MP9GU802 ; 20171122 ; subDT >									
//	        < 7Ufi7DfPYG3351lO7IQTYQkQL0v1f2q3PfaabTpF9cWh2p8656IDe9E83tQrAk8H >									
//	        < 9157GCS0i8J9i5NgPn14C3WSh2MBbZrbY53ujSKTv8T2q4HKpaUxoS5YMLLhbj36 >									
//	        < u =="0.000000000000000001" ; [ 000056393912812.000000000000000000 ; 000056408841973.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000150224831150390FE5 >									
//	    < PI_YU_ROMA ; Line_5685 ; HXC3y5K5qcm87Kor47rkyjaV3iT4s13oAOqzv7bY5y2C4aKvH ; 20171122 ; subDT >									
//	        < 1hv6r7d54LU50PjE4sSKY3DPsAs5M9ZaT24GWA0rXqOD4iT0g1o3crc7U0tBB9wB >									
//	        < M150niRQ21Cvj08O2AjKP6H9pmT9Bm32IS52iq7Tab7q5d6yZ7ukM69ge7Y0aRsd >									
//	        < u =="0.000000000000000001" ; [ 000056408841973.000000000000000000 ; 000056422232180.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000150390FE51504D7E72 >									
//	    < PI_YU_ROMA ; Line_5686 ; Uiqr13Rqgwa5gtv2x257038G2iBp9WCdlG5BZPC6R8HcL53HK ; 20171122 ; subDT >									
//	        < 82HfyLFv9im3Hu9Lv6I18IQcpkrTHT2OK7Pcb733MMbSywzJHhUXhcWz970VnQH9 >									
//	        < 9iV877c0zRKMH5v2i7ubNrFaXkplqdcLmW8eJk6XqKI4uJxL5aiZmYjAesT6OmIu >									
//	        < u =="0.000000000000000001" ; [ 000056422232180.000000000000000000 ; 000056435792382.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001504D7E72150622F66 >									
//	    < PI_YU_ROMA ; Line_5687 ; 1P8QA7GNdceN3035D89MHM67dk141EIvjtz9Y7laPpeLXM0W3 ; 20171122 ; subDT >									
//	        < Vl7nBTW85g8HoRh19pf1N50ptD113x8SSm1560F211D4743ePF26rt11tQmol19V >									
//	        < G2gxtxSuXb6knL4HHzh6jf61J15585enRIF4TX6U8OH11Kv32oIanbh481RnLoqy >									
//	        < u =="0.000000000000000001" ; [ 000056435792382.000000000000000000 ; 000056449016213.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000150622F66150765CF5 >									
//	    < PI_YU_ROMA ; Line_5688 ; Z3p45Uz7hrkM59Y0WtLD545Xf4J129B43pF8v2iFbeBFkI23n ; 20171122 ; subDT >									
//	        < 0P506sRHa58TxYV1v0u3il08XCP00ft9Jd0JEFlwPhda2W78i8D04L45nH0IY1V3 >									
//	        < A3ESfz8H6xIk5w8Y8D36B8c0x77zgy5mWaq1e3c5spTzJ1g7B9miXcQZlcFkBK93 >									
//	        < u =="0.000000000000000001" ; [ 000056449016213.000000000000000000 ; 000056462843779.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000150765CF51508B7659 >									
//	    < PI_YU_ROMA ; Line_5689 ; 7kS4p957nBfX0Wh5A5Y0I41tDDFW5FSD3rvmyaI1gnLeNe3fg ; 20171122 ; subDT >									
//	        < 1r8SXVp7dApW6bugF395693dy5b52PMIe9lwLNGpvYu4O234faCgQ0N246kI4Z3y >									
//	        < Y68q7QAmwv0rAr88SxhkW6PMWs6U18BWRYUWpNx2N7h1rgw33Jk6o54V1yS2St2M >									
//	        < u =="0.000000000000000001" ; [ 000056462843779.000000000000000000 ; 000056468043057.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001508B7659150936551 >									
//	    < PI_YU_ROMA ; Line_5690 ; PgzJF6DF42S8e04x3wqQl9N2bdDCAE9bQQdxYan4n0gy1oKs0 ; 20171122 ; subDT >									
//	        < u1y13J5i4DViJ4S141B7grWP9XxFAdN9yV8fVEQrEG4rr58ZLEQIVyeQvCK4y16t >									
//	        < A1Ya1dW5xxcY80eIYh1V45W1A1nXv7Zx5rIv6zZiPAdG2Dru49k5r36F86Ujlhg5 >									
//	        < u =="0.000000000000000001" ; [ 000056468043057.000000000000000000 ; 000056481303167.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000150936551150A7A10C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5691 à 5700									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5691 ; Gavo28nHtyV7C9h0475VH6qA9613A16D9Itm26xsan3Xae5n6 ; 20171122 ; subDT >									
//	        < 88GXzO597oJ5n2YmY24PKUcw5mK3MET79GkhuJjKB8ze89K72r4IovX91xU8wt5h >									
//	        < lIOh3tTWDqlR58zE3bVVw2KPAAcZNF2Rc844I8K145Ua8W1F6XtvxitRswu2183t >									
//	        < u =="0.000000000000000001" ; [ 000056481303167.000000000000000000 ; 000056494300378.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000150A7A10C150BB7615 >									
//	    < PI_YU_ROMA ; Line_5692 ; C7lqMMDaFvXFF8X30x80e8vKStcKL4q834j1JXb76NWD59NYS ; 20171122 ; subDT >									
//	        < f68NEJpqg2Ju3u1c8HBElD1RrMG62mgKt4HwgNxSW38xf302s58oqh5BRHOEXus4 >									
//	        < 5fH3kB81bk5AmxV7zCx2FJ151UA7ouUX9K482rcAm080NMDHvKZFwnWjw25S5V7h >									
//	        < u =="0.000000000000000001" ; [ 000056494300378.000000000000000000 ; 000056499794924.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000150BB7615150C3D864 >									
//	    < PI_YU_ROMA ; Line_5693 ; h331BIFXaVyx8Aob7509LxO1d45DNirJ7htPXFKlJ1557JBl0 ; 20171122 ; subDT >									
//	        < Q0dl467VQdGPXt478wuQ4fF6zndCYrBBYR240a5CXG52U06fZj8sC1vAH0yoBIZP >									
//	        < R1S6DN1sp1x788YHk10QfN0xUgsOHMKCVRIlT9f4T9vPjc07W2I02m6N22UR70QI >									
//	        < u =="0.000000000000000001" ; [ 000056499794924.000000000000000000 ; 000056505243209.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000150C3D864150CC28A0 >									
//	    < PI_YU_ROMA ; Line_5694 ; noKpZ7cVokZc0f97OVCL2yByJY06wIHt3Hu19lay6lBpS7aX7 ; 20171122 ; subDT >									
//	        < 8KXssYN3NldW7y6Uh4liPW1b3U2qMb56JvtLr29nS7cogUH8OD73O39Dr8zUNXZo >									
//	        < 577aDL8Jw9alI9RBIqFRae689i71qVV8wJwGs549njH7EB2pzw6uj15zp7Q83z39 >									
//	        < u =="0.000000000000000001" ; [ 000056505243209.000000000000000000 ; 000056512284479.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000150CC28A0150D6E71F >									
//	    < PI_YU_ROMA ; Line_5695 ; 4afmgMu2suDre2y98FqE08CA3ULfd6x0GK3nhukr1qokuma84 ; 20171122 ; subDT >									
//	        < 0jw2S0FAISTp9XIbM483knMOByg0ATzPWjA5kJ29dB9GNTms4xT5tqdHnFC6b0cS >									
//	        < fVjN7XmJ7674Sj7gj76r4w6o68zFQ7fkJi8B1j5l1HtZe130kVRPcbDV5N0L36Jp >									
//	        < u =="0.000000000000000001" ; [ 000056512284479.000000000000000000 ; 000056525797330.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000150D6E71F150EB8595 >									
//	    < PI_YU_ROMA ; Line_5696 ; mKx817J1sAa0911EX2QocwemAq7m8U5KSV62OS6LlEJ690209 ; 20171122 ; subDT >									
//	        < xV06uOI4K9md5dmb7qQC4jM98H9fr8q8gO0aK238O1M12lyvJP0wu1mL3951vTjv >									
//	        < qcp5Gy921vOE44j7tBet6fzN5WPs080JKv25CF4l2106t5SFFrXS4YlO4K7x9saY >									
//	        < u =="0.000000000000000001" ; [ 000056525797330.000000000000000000 ; 000056531347664.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000150EB8595150F3FDAE >									
//	    < PI_YU_ROMA ; Line_5697 ; jFG59eTHOLT3tn10PR0R3B9DtDoSnz8QHKr0jeJy0vl8iw6MV ; 20171122 ; subDT >									
//	        < 30y7YyeKcfy8m2W7O537nU0n25PdpzpqSA0ocN0955TCwKL0v7Qe07nH1382eK1Q >									
//	        < nhK58x7j23to3B9phxts48c8VMQnbBf3UDoCne8b6uIY1INX4DzqTFKU354fBii8 >									
//	        < u =="0.000000000000000001" ; [ 000056531347664.000000000000000000 ; 000056537932316.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000150F3FDAE150FE09CF >									
//	    < PI_YU_ROMA ; Line_5698 ; 5WAM837jV89L51D6Zz9iaQFj0HCjz8smk1y61VBUw0mmTGkFK ; 20171122 ; subDT >									
//	        < s0CMHEV3yT23aCs6RxB06U7pvTS4i824M7Ki1501Aql810XCqMy3x5m2g88b4Z88 >									
//	        < lz3Sg6Fg80N0Ygl029BB47V6302KD5me9xRA4JxVGFYdi2kP82G6a5HfvglX2m5N >									
//	        < u =="0.000000000000000001" ; [ 000056537932316.000000000000000000 ; 000056546771001.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000150FE09CF1510B866C >									
//	    < PI_YU_ROMA ; Line_5699 ; ciFH1v6L63Iym1pDWh5jr69haKjD157uGATVG0c0j2g9vG89o ; 20171122 ; subDT >									
//	        < H201VW0f12o177gYn6ro72qKXHc3V65w84NN07EwoheC7bjsU1DLI632QSfA3C9X >									
//	        < 01TdNqkjawrT0JR4oaYtV2UY28n5cQD0616T8mVJ6ebs0h9jN1Re1WLh7NKIC648 >									
//	        < u =="0.000000000000000001" ; [ 000056546771001.000000000000000000 ; 000056558499679.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001510B866C1511D6BEF >									
//	    < PI_YU_ROMA ; Line_5700 ; f570TAGA1xP5EHK6O4552IjO2s4dxwKHAs9Jg5OrcLx6cR4vi ; 20171122 ; subDT >									
//	        < MsI93pyB3GaLTL7EjqCL1bL6Fv05bqmUd1wpy24pqv8qHAQ15SA98tlFs0e0d7D3 >									
//	        < SE7M5jNKvE27G6G7SBz8qLrpVOI7ph70u8PHGYGSVAmN4zXCWeb2He2T0v9Lx3EW >									
//	        < u =="0.000000000000000001" ; [ 000056558499679.000000000000000000 ; 000056571558352.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001511D6BEF1513158FB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5701 à 5710									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5701 ; si881smn5KF1MR4FF2UqBeHyERKhdiszj3YcfSe27jJiRQSh9 ; 20171122 ; subDT >									
//	        < Q76LIpCH2f9oFT0t5M6x5b988G656990Yi2RGUa8qy7uCCMgg2CW1NF4o4NJ7skQ >									
//	        < SYt683oz1isMEYa6e64aG7hy56sL8GH01pkux14G7673th9QKwi0B19dEOrN5ITf >									
//	        < u =="0.000000000000000001" ; [ 000056571558352.000000000000000000 ; 000056581675117.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001513158FB15140C8D7 >									
//	    < PI_YU_ROMA ; Line_5702 ; dP4iS3ok6nHSoXH8CLzQ49coCV4l0ZhHB012m94S84CspFvUs ; 20171122 ; subDT >									
//	        < uk9o6Fh0Oq3Q9y7q547uj4vFVpR1yTsQe9KCl62Dkd4uql7x8tLBl0QoG8Rg17s8 >									
//	        < 70G69FHga7LlU5HEYVIhb23EoTdn03RMX8qUUvV7gU2iiP92BFLCU3f0OQhIo7Iw >									
//	        < u =="0.000000000000000001" ; [ 000056581675117.000000000000000000 ; 000056592018570.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015140C8D7151509141 >									
//	    < PI_YU_ROMA ; Line_5703 ; MPd30RAjtUdy5nhAyUTiK626L03nv4ZJP1t3ZiBJ31e6fxGrQ ; 20171122 ; subDT >									
//	        < Nbj6qSqazYE22FPf4G6NMU1dm44P8WrT4DRE2Via7bSji54xEeHjbzh3V6l8j5jF >									
//	        < 9x53TE1g5QqePg8zi256YFd35K139p2q9vmwQUhwz9IziYlI6bQkYN50VgUwVNHb >									
//	        < u =="0.000000000000000001" ; [ 000056592018570.000000000000000000 ; 000056600089910.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001515091411515CE21F >									
//	    < PI_YU_ROMA ; Line_5704 ; 2w17GT6xm49UMI1W1nofn1oDu5rpn6P89AHQFu9m0LTQX7CTs ; 20171122 ; subDT >									
//	        < 4fRvajGt48gEgPz0BytJpyqBBmU0Hx01332tYX6YvcP4BZ2ENEyvQ8w0la1AVIJS >									
//	        < ln9u6eLFrf3X45qMFtJ62tEbyyzjiHm5FVv5m7vrQTYwDdMSczdhnrQKg3v2abVY >									
//	        < u =="0.000000000000000001" ; [ 000056600089910.000000000000000000 ; 000056606830588.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001515CE21F151672B32 >									
//	    < PI_YU_ROMA ; Line_5705 ; 3oB7yk1s97Jq05lE99A118PlJtv9q5lw63W1Y5J9pG5508dHM ; 20171122 ; subDT >									
//	        < iCO6lpkji4mfne21hue8wGNcpD1ExTY3WG72sb769Ekr8kAk3tb0Vx9oV2ZS6F63 >									
//	        < F87Zd7KX4zUn8KEtrMArhPToJ837nMiS2weem7swGi1a1y6bJe4L9z1OSPG08mUE >									
//	        < u =="0.000000000000000001" ; [ 000056606830588.000000000000000000 ; 000056621553218.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000151672B321517DA239 >									
//	    < PI_YU_ROMA ; Line_5706 ; 5R56H1acQhkVfhj4B2E1Q8mMX0e30zaNs8v7GJjeb2NBmx8z7 ; 20171122 ; subDT >									
//	        < 8KMvQgRS2reBZ44eilCg56EsF8LE4zS0GGsNquwr12ihO9b5ET6z8N793AEkLx4n >									
//	        < 3R891590DvUj8L58mVCz409wgf5aNTBV4IHcH0T6J6p3DSRy1ufS30vaZR2tLKSe >									
//	        < u =="0.000000000000000001" ; [ 000056621553218.000000000000000000 ; 000056636507550.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001517DA2391519473C3 >									
//	    < PI_YU_ROMA ; Line_5707 ; 6Unq533lmQ7PubTf3S7d8jg6tGyjrP5lXzq50KtJ9hCPp9LJ4 ; 20171122 ; subDT >									
//	        < u64VM05gczq1pilLVpH4i42iFjXKWPILqH67F112hU3Hob3xMdv758UolMG9xmz3 >									
//	        < 3kE3Vf5I9n8MDwCUVEWB6uGH374Iw48tBIx9QvQR5ESr4uv2QUS9j67gH91098m4 >									
//	        < u =="0.000000000000000001" ; [ 000056636507550.000000000000000000 ; 000056651010896.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001519473C3151AA9521 >									
//	    < PI_YU_ROMA ; Line_5708 ; k81CP703OJcNbQPocXkE2VRGR8SgM9BMYYFDn6G012034x3Fd ; 20171122 ; subDT >									
//	        < S6Rx20os0JNFKHNv5y1PCZTl2pR23u10NA00NY6t95fgIC8V7n4OwBmlyK4018Oe >									
//	        < 0cQ0f6I219h3sH820kky8A10olqqlR79p0CD9P47644csE4OFviX2jeXr39D40T5 >									
//	        < u =="0.000000000000000001" ; [ 000056651010896.000000000000000000 ; 000056658047987.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000151AA9521151B551FE >									
//	    < PI_YU_ROMA ; Line_5709 ; 2kwspC27nt3Mu5Rl7RdAK2Lh55PDt32o3347o12NewUCghxNf ; 20171122 ; subDT >									
//	        < Bi3I68ayDz24Eqs11hdsb64Zdb06i51xODmvtjmDHQHE1v7X1U0MFi87RBD57900 >									
//	        < Krgy1LF5r78fCt63APsVMD9NZ86fsEoti76O8Lufc7g17x0zKR8rs690rDj17g95 >									
//	        < u =="0.000000000000000001" ; [ 000056658047987.000000000000000000 ; 000056670743003.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000151B551FE151C8B0FC >									
//	    < PI_YU_ROMA ; Line_5710 ; J44Hb7jsru2e42F6835p6J11wndj002b15vCT48uhjrTjo7N3 ; 20171122 ; subDT >									
//	        < 5cwTA5b08YGpxri3swdN1e5gmI4Df74J2t0v83654m4nzOs9NS19b8W0KzBctL9V >									
//	        < GQ43lyP3B893YnD9Tmell4uBWCAl3p4Ya88uTTapVr9z5341gk212BJ5o4hebImJ >									
//	        < u =="0.000000000000000001" ; [ 000056670743003.000000000000000000 ; 000056677600670.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000151C8B0FC151D327C3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5711 à 5720									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5711 ; 7Qi3vJtc9a733B5xyfn3pTY2IoPTRT85wKV3NrXB8MCg6J1t2 ; 20171122 ; subDT >									
//	        < 6c4Ix7LCn2ub9nZ3khQas2Wvd240qf0mmMWDP8lFR6034K90qTBj96G4p0PhsBzi >									
//	        < fpSvtlCySCHNqe4udl1C7du2a8J8LP7Yvba0y1in8jo3R00F0759odzLY5Hh60hc >									
//	        < u =="0.000000000000000001" ; [ 000056677600670.000000000000000000 ; 000056685319185.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000151D327C3151DEEECE >									
//	    < PI_YU_ROMA ; Line_5712 ; h909A5TDO1a44KRF4W4Xi4ghQ00Z4RZWzNKtI33v56H7cA14V ; 20171122 ; subDT >									
//	        < 98vrjFQ0P986Hg9Ei2z6Eh2Do15x5OezwD701w7bTxG71g8TGp3NpePWFrQ27d05 >									
//	        < uPL29Kbfz1gI47nZSq4tUyXFNlez5a4G5012GnJe6sD6O3lHDiigTs3c5t16pPF5 >									
//	        < u =="0.000000000000000001" ; [ 000056685319185.000000000000000000 ; 000056694902288.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000151DEEECE151ED8E34 >									
//	    < PI_YU_ROMA ; Line_5713 ; Nf299m71XqE9ole7KQT3i7xF9Mr6I71pK1zP8Y115b2TmC2An ; 20171122 ; subDT >									
//	        < yD0J7EjqdbOOlFwSw9pD7mxgZqp4XbemZQaPta30nMYnvsFCc3p70yhyMPENDDuw >									
//	        < h7b137L477MLf1M72GKs3459PDXVbWRrhyTz7k9605FM5wQb48757lJ30m0GX898 >									
//	        < u =="0.000000000000000001" ; [ 000056694902288.000000000000000000 ; 000056701464584.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000151ED8E34151F7919A >									
//	    < PI_YU_ROMA ; Line_5714 ; Ot8kw3WjVR6oEKE45UxDa8MTSi45CHTIj8gI008nj8Ej19Dlx ; 20171122 ; subDT >									
//	        < se483RI7l42M828cY2In6Mq39208d2n54rxt1245jHp9E8F1yl9QI4olYP4CLe71 >									
//	        < pQr2DB262PU358ZW875V7pL7oGa5oV6Yd9iQwa1fCqhYqe86EjvsKyl4697U55M0 >									
//	        < u =="0.000000000000000001" ; [ 000056701464584.000000000000000000 ; 000056707342013.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000151F7919A152008979 >									
//	    < PI_YU_ROMA ; Line_5715 ; i1EODFZIhkqZS43Ado230NrDAP5D3104k13v7LwY4O3omhTs1 ; 20171122 ; subDT >									
//	        < VeR4R879BfkR117EI1m5f5Wn0wwYkKQY8l49rP2vY11u1bI7Za50iGLzRniom7Ue >									
//	        < o5sSPuP9Z6t2v9W91St5WhdPt89eJk0DZ8RVmBcZ7q76830KzyZLEy9r7857RX1o >									
//	        < u =="0.000000000000000001" ; [ 000056707342013.000000000000000000 ; 000056720834091.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000152008979152151FD1 >									
//	    < PI_YU_ROMA ; Line_5716 ; 5C6K0vKB209zSLDL9ZK0zq11UmGs1oPa7Hpt9Z2k1N5E2y6xe ; 20171122 ; subDT >									
//	        < D228i3zBWmmXZi3TV6ul6437KRQXSktroJ1lCxxtmKvT7ppGQT82uy7i4LdWOV8F >									
//	        < 98CWZ0XaAT53cRlx71Q63rGSZsB5KH8k1H75D0d8rWhG4zzWk70u7ayi4mF7BQvI >									
//	        < u =="0.000000000000000001" ; [ 000056720834091.000000000000000000 ; 000056726250869.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000152151FD11521D63BE >									
//	    < PI_YU_ROMA ; Line_5717 ; 8pISpk76q4ssbk2myhAOAEEGPh146Z4BY3TMG5SNgqWTbNOEo ; 20171122 ; subDT >									
//	        < ySn83FZ1145995Vjp5T5fEA0IPDVPj5OjtM24lc4517LU0JJ3o024Q2a3X9m6044 >									
//	        < Qcnp4E80EQ49d8uZHCi276RcuG18k7NZvrvDd2RI9PPvd8SUnN2GSb07if05vxd4 >									
//	        < u =="0.000000000000000001" ; [ 000056726250869.000000000000000000 ; 000056734315403.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001521D63BE15229B1F4 >									
//	    < PI_YU_ROMA ; Line_5718 ; o1Ee532i6oSx1U7ZX9YFR2khBU7Cmu9d631u5mql55407N3W6 ; 20171122 ; subDT >									
//	        < R7se164V6E836ug8EBkUK76ztkqXMfgM9fF6qe860CAP3ck59wne5jk3BdnC0QWa >									
//	        < 8c8g02393U5hL6r4nNoN93dNlY3SD6vNYSy4441bM7kNzl2C9Hy98K4EsTvus8E9 >									
//	        < u =="0.000000000000000001" ; [ 000056734315403.000000000000000000 ; 000056748552371.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015229B1F41523F6B45 >									
//	    < PI_YU_ROMA ; Line_5719 ; BLfne1TdsDy018v9E6Qz65HvI9W0PK15TNhS5FNuVfAzP185k ; 20171122 ; subDT >									
//	        < v0OxVdCkVC7i78c952atP5534AzdNMvjGoBRibaezG8i7E15dya02mtyqNoRT6HG >									
//	        < s935Fm911dU6WvL5tNG7G8JR6iY8D1TYTM4qK9L1Qx933X36SG8I1JfjgkJq4GQ9 >									
//	        < u =="0.000000000000000001" ; [ 000056748552371.000000000000000000 ; 000056754842628.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001523F6B45152490466 >									
//	    < PI_YU_ROMA ; Line_5720 ; 5Adzp0KKJA5dqKMDcxA94gi58GDy86bnrj3VQNSQgA6u652sN ; 20171122 ; subDT >									
//	        < EeCg5KoxmHHqD83w155juTsq3tMjZh4MY5z9NcCZP29THssC5Ut0dr1UNa1300zs >									
//	        < Jo0680h1eZ6D1z4cb2Upw5gL99PcFDP6L8cChiEAOmLpzr65e869F5Lgc8kZXJVO >									
//	        < u =="0.000000000000000001" ; [ 000056754842628.000000000000000000 ; 000056761899975.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015249046615253C92D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5721 à 5730									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5721 ; AE46B0d8HFtn5a30qGvhz8p787d9v2b870gpO4k7nFWwPfism ; 20171122 ; subDT >									
//	        < XlZp1R3z9IZPeZd72YZN7VTV7BK8WgetT4z8ZmjI2RovvPWl55p3sJ2Of1s8naIr >									
//	        < Hwe20naL2rmGJWzRo12uv9aKp23KUcCp7eY1MqrKf738rAZ7RG1kP6S5XaoJF95g >									
//	        < u =="0.000000000000000001" ; [ 000056761899975.000000000000000000 ; 000056775007367.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015253C92D15267C940 >									
//	    < PI_YU_ROMA ; Line_5722 ; B480V2OH8D8dJ6527q9Tta6InpmT8hLR5QSXTV375v8xJkbo4 ; 20171122 ; subDT >									
//	        < 09gD05bKf7L6V6tIF4Zl10Sq4Kzd9HiqOfjyT9e5rP5tp5NoUJCf5V2keA6FyW4l >									
//	        < T4O3s0oFj52L562VBPt22blgRN6qiEPz0N73D14c6W31Y12p2U0bjsx7l0GrlYbQ >									
//	        < u =="0.000000000000000001" ; [ 000056775007367.000000000000000000 ; 000056786687130.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015267C940152799BA9 >									
//	    < PI_YU_ROMA ; Line_5723 ; TBb485US6Fvey8XyIUYNmxgC52ODL4Z5c4NIJ7P9Xg9wou1Aq ; 20171122 ; subDT >									
//	        < PHbL3R4YN1WzVDTF07b17PMZf4z0xW1yKVTCsu99P92m282D2s07w48fv4V6lWIp >									
//	        < 396a9GduS6cX9y05Fxk7fct7eyUr762Kt7700p7733b24HcwdmXgF63Jj2y97MqP >									
//	        < u =="0.000000000000000001" ; [ 000056786687130.000000000000000000 ; 000056794265020.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000152799BA9152852BC6 >									
//	    < PI_YU_ROMA ; Line_5724 ; 9t20Jhca347J4WjjaDxZU8LHLXMg1WiJBpKgbMgha2ZDpmuda ; 20171122 ; subDT >									
//	        < 7Ird48b64331qxgleDJ0zxs29psQyZgpcIPFk3427V6NRFEf04l7DO2oZE031Ij6 >									
//	        < LkJNVBT3OZYrCPVV3V8wvfhbYnOHoV1t2K8QSV0LvT0G1k6A7Y66H9P75c7O9QVD >									
//	        < u =="0.000000000000000001" ; [ 000056794265020.000000000000000000 ; 000056800127081.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000152852BC61528E1DA4 >									
//	    < PI_YU_ROMA ; Line_5725 ; 23343edwLx4jji9OvXiAQT2nJWkm5Ic06T7Jdro76zAe72h1E ; 20171122 ; subDT >									
//	        < XTef0KyHNTHZUKAH6oT8o5FbiWa1vqHV2OIN9yCaA46cQ7bUP6sEb9Rs0LpMe635 >									
//	        < K026uTtIyB0obwE72r6bMc5Aox61E8aDmX3L598H6722q89c7YNP1g6Ft9zsPun7 >									
//	        < u =="0.000000000000000001" ; [ 000056800127081.000000000000000000 ; 000056805536093.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001528E1DA4152965E89 >									
//	    < PI_YU_ROMA ; Line_5726 ; 6zzXW0QD0WZi8l1auKkvxE6l3JmgL0D1sI0TuJW4b1jzI0G9x ; 20171122 ; subDT >									
//	        < CKg4IODERmbPulF5nQ0vCh6R4J2001Jk2pel7s54fEyx840ihzVjR07Pjo311GNB >									
//	        < Oto1BZzP2qV6TS1ToGp67CMP9x5052wqqoPNxzV9G43x0ok8b0v74571GPXc9nl4 >									
//	        < u =="0.000000000000000001" ; [ 000056805536093.000000000000000000 ; 000056815501002.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000152965E89152A59314 >									
//	    < PI_YU_ROMA ; Line_5727 ; XFr5uVA4k5d6R91wn53zxFBPSRHnXbM6nRV36VXo8330EiND5 ; 20171122 ; subDT >									
//	        < M7f87M7dSJElP7Lc03jj8y924hY2j2PevY4y1x5xau30QB5OhxcEAw9ZdSDGFT07 >									
//	        < 287R6NJ10XW0RcCQ304TD83Di21VRr719LHlo9b3Tg1k9gqnU4j51itp770uDUk5 >									
//	        < u =="0.000000000000000001" ; [ 000056815501002.000000000000000000 ; 000056824225011.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000152A59314152B2E2E5 >									
//	    < PI_YU_ROMA ; Line_5728 ; 11LM49bMuoa525rGiE4GnR1sIr9vwGbvSaHEp2SZwO3iG0HrF ; 20171122 ; subDT >									
//	        < rt8j3h74CPxJX01o3LF9v61bI0jUaQUvRnglwe21k0x0x3UKa9uKNeQrA4T88Oig >									
//	        < K9sd69Kk6O5j5hL4w5IbOYBkOExcUG19Rb9rk726i6tSX4RlHr1XZn4a8IKF94lJ >									
//	        < u =="0.000000000000000001" ; [ 000056824225011.000000000000000000 ; 000056838106803.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000152B2E2E5152C81178 >									
//	    < PI_YU_ROMA ; Line_5729 ; 866sD1o1NKtR9TEJLw9G7r1zJO6Od60VRUA6Y84ZUd8778UBO ; 20171122 ; subDT >									
//	        < j3r291ObAFmZD1gtxj0bgQSt7conwU2AC6vxsg58d5Qbq2IPH0t562vW64bNRY11 >									
//	        < HvA5gz5UkN5eru6KeS1cu2KwE0Zwx5xKM95f0FCFAye6ibX5XX2791KadW8px25i >									
//	        < u =="0.000000000000000001" ; [ 000056838106803.000000000000000000 ; 000056852795359.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000152C81178152DE7B2F >									
//	    < PI_YU_ROMA ; Line_5730 ; 08qMzDJE3CO5Sq7sVo4u8g6J3uyU8HLDu4Drg2BqA842J11N3 ; 20171122 ; subDT >									
//	        < Z2Zc6U7u836wGQZpZ87Rn60Y6BkrQk44uG08023SWn25mt84NjPkMnF05i0R7W8w >									
//	        < oEajES3Vr51jKE8gD83f0Em55N0jVzP9Et5sBVOw8gQ7rgSEP9Ac6lngL05jRTTt >									
//	        < u =="0.000000000000000001" ; [ 000056852795359.000000000000000000 ; 000056866873101.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000152DE7B2F152F3F64E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5731 à 5740									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5731 ; IXBIo2F00C5akS8xY1GtnZ576T6hatjDlfZIgp75MFe7haBJ7 ; 20171122 ; subDT >									
//	        < y7gV6RMVjQhX0a5K0DBe7122KrMP5INQXDSn6b3nqWrvFRo411Jgio37SK41t64X >									
//	        < x6bi2ipQURy2Hg62P9bBI5ZD8KGTzt86kHJ983607tU9o9myyDS3x44nI5GJRF7G >									
//	        < u =="0.000000000000000001" ; [ 000056866873101.000000000000000000 ; 000056873781042.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000152F3F64E152FE80B8 >									
//	    < PI_YU_ROMA ; Line_5732 ; O00adjKLX98nuZAg8u2JQh1J334e25M7P8j30RM155VZ9Myyy ; 20171122 ; subDT >									
//	        < nLZ378k4ycmGRW1349Cwkl64Ch0RZwXt3rYJIy3vXips6U2bk10TH4S0i94ZVaU3 >									
//	        < P8kQb1PqTC4yuK862UY6n57hfe03Y6A7Cd53eP0WYPJDH31WA4PEAVAHoGIbqS4n >									
//	        < u =="0.000000000000000001" ; [ 000056873781042.000000000000000000 ; 000056883812706.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000152FE80B81530DCF56 >									
//	    < PI_YU_ROMA ; Line_5733 ; qBA2Y1Ey16CcO8dHu6oai9muwhR4uEcNcgsmks15tqefuBiB7 ; 20171122 ; subDT >									
//	        < 3dhM7QCFyMiBeeI6giFtb23Cy23nY70f6Jv0Yoc55QALy0M4pvpn7643vc3Q09ap >									
//	        < z11f2jQtCFcidHN4DJ3wOEShDrIVxE9rk4t7AU799S40rgGyO5K6d17o5daUlSQQ >									
//	        < u =="0.000000000000000001" ; [ 000056883812706.000000000000000000 ; 000056892416176.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001530DCF561531AF011 >									
//	    < PI_YU_ROMA ; Line_5734 ; 9961PA91oKsrLEKtSHYGQ2D80RV7O24g4P6oJJUI6k1Xp83QW ; 20171122 ; subDT >									
//	        < 9xWicLbMq773T202os2lAAaG435zFWMli63F0whu6j8xcE5579uE7vp978ey8e5q >									
//	        < bxK79IdU0LRWkmQFPXD0jh9VTtpgW6wbf9X548r8v2Qy71GXh0sZ121v5idPp6n9 >									
//	        < u =="0.000000000000000001" ; [ 000056892416176.000000000000000000 ; 000056898216469.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001531AF01115323C9CE >									
//	    < PI_YU_ROMA ; Line_5735 ; j1q8N4x2M6YY0C9o6TZixvke2Xsji9uoxBn6j7k667Za0AzbQ ; 20171122 ; subDT >									
//	        < 2ulc564992QzZh52LLuzE2v19n1JghWyLw86o5piJo68RP9u1anMD76XAm0x4g9f >									
//	        < klaT4U2x812q32WV9A387V4yNfH2FaNyZv24deqQ44ZUAYkNT0Q4M9J2H79WE92c >									
//	        < u =="0.000000000000000001" ; [ 000056898216469.000000000000000000 ; 000056911969036.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015323C9CE15338C5E7 >									
//	    < PI_YU_ROMA ; Line_5736 ; wpo429d7Rz1qp9Pb14GK431eKM441jJsN365V2ud03k9gbbeP ; 20171122 ; subDT >									
//	        < q077s6mVwPsISw3477098Z39lf9K1PwA63Jc3LT07NZ3L2NwPI7by1jMn46yatRE >									
//	        < EL3NMJ0131QHrTjr5v1W83RKbDGg8g979P1OixHr0dsdit3H2Pz2a0iQtpIXefbr >									
//	        < u =="0.000000000000000001" ; [ 000056911969036.000000000000000000 ; 000056926171279.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015338C5E71534E71A7 >									
//	    < PI_YU_ROMA ; Line_5737 ; e41l0vAFnU4q8Iq41lKVP622A3wF8hxFqdl6zgFR4m4ZIce7G ; 20171122 ; subDT >									
//	        < JTwJ5kiwIt0YDbr8Z5575au1wc04WBHO21yFFpd2Hk44Z1flsRx13UB4oAn1xvQO >									
//	        < 5fdK5ES33u7usrA7BZwJamnFu1Npuo93lXEznqSB6Gl18494v277xwb9rs566l7n >									
//	        < u =="0.000000000000000001" ; [ 000056926171279.000000000000000000 ; 000056940793230.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001534E71A715364C15B >									
//	    < PI_YU_ROMA ; Line_5738 ; 1lZrTAXq9IFG1E4X88A9YrG3nPAx53EMq3NgLzyWqlBGcsAYi ; 20171122 ; subDT >									
//	        < 06PE4f4awpx4d69cCgPYD7nE1r10DdKs221cmf0030GgCmzMIHjH8wZuA3Z8U4f1 >									
//	        < 3gp6WUbBRGjwhe9Hc8J6mICO8R8qeteOrix6LANHhP8Nc81EY13iIRnxEnD8FQB5 >									
//	        < u =="0.000000000000000001" ; [ 000056940793230.000000000000000000 ; 000056947374195.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015364C15B1536ECC0B >									
//	    < PI_YU_ROMA ; Line_5739 ; yhdmd5Y4RPo1SEEz0k4gBoiUVSvPi8jU0u5ttKswyL7RZ6D6W ; 20171122 ; subDT >									
//	        < C32Zb44a3a60wYd9JTmn43cdEuMI37BkRCeCgZ8xG0SJjxLLZ41E1HrTH2d26jEP >									
//	        < TcA6hv5NTedJ8vviFSEni2FjJV6z5CU0ugV2oWXNPkY9uskB5b793VBJg9h3648n >									
//	        < u =="0.000000000000000001" ; [ 000056947374195.000000000000000000 ; 000056954795610.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001536ECC0B1537A1F09 >									
//	    < PI_YU_ROMA ; Line_5740 ; K3f1mS5Q9NI9699d4Rr1cx3m0a8I1Pv7jESz3iYX8n8Hv2hnd ; 20171122 ; subDT >									
//	        < NFQ8tLlZK2Hupy7ARItq8H1sUrW559wA8h4faa2T3324NynWk53145mj0pIF712D >									
//	        < 971rPeAvLAC1QqUw8G6jwqmCTGQW7z6jN5ba9c7is5J9VyOK1xMR7K14OEW782FN >									
//	        < u =="0.000000000000000001" ; [ 000056954795610.000000000000000000 ; 000056960869755.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001537A1F091538363BF >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5741 à 5750									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5741 ; Twe539608zZ81p00qXijm269I0o91B3CcXxGbBunEqOB6vzZ8 ; 20171122 ; subDT >									
//	        < 79HL9I2MSewHhg36kMr8M783f247I224Axbm08dq7UJP2k7FA7Yf7R35555A0KVx >									
//	        < 1I27H44z048lh88QW8u9J3t5maqHp21XvF4S56keCbtUwM783PF2FzWoFbseJRUm >									
//	        < u =="0.000000000000000001" ; [ 000056960869755.000000000000000000 ; 000056973549719.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001538363BF15396BCDB >									
//	    < PI_YU_ROMA ; Line_5742 ; 2Lx0ikx5LOaT9RqZL91XhpMi32lYTSa7lIp3G6EWdE3CYGA3o ; 20171122 ; subDT >									
//	        < 8Pqsn28w9mI8DLkc6myE3ZdffwcG97k8w4lEztcyL10LIO18aWVs6amrYYhV7puK >									
//	        < 5X0vu49x4A99Q5EF63nKiKRH72QF54gF46Yqwax58zBGJGypEQ8U3xfNu7RFqYY1 >									
//	        < u =="0.000000000000000001" ; [ 000056973549719.000000000000000000 ; 000056980261097.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015396BCDB153A0FA7D >									
//	    < PI_YU_ROMA ; Line_5743 ; XXa6CbSv4Z8O9F2O9bNb2u7u9Dpq6R07Qbl3L8D70bK9B1P5w ; 20171122 ; subDT >									
//	        < NRtzcQu4e055wts8As2drDLAK0qq7vln4NnJ4g0K6Y18ef3nA9ORNKiUZ264yj20 >									
//	        < 4fMCQTYsy4K5M09xk9Ga5SSKTTjte2ueResRg4z3bL2uVxz6rKvxgD7sHSP1sES5 >									
//	        < u =="0.000000000000000001" ; [ 000056980261097.000000000000000000 ; 000056987523459.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000153A0FA7D153AC0F59 >									
//	    < PI_YU_ROMA ; Line_5744 ; Wh5CWFzd37DEm0Np7Hes9PR7FsVnAKHnqi9oP1jLH3f96b5T7 ; 20171122 ; subDT >									
//	        < N8v0I6Ql85jdx7lViw804xzhPUtcEr3uSz3SfNqFGw41yHbSiigfju7mqa4HDyFV >									
//	        < 364x52X9gMMH17tP8HwT9av6BanMNoCsN704J1FR46ERc1BVH8z8e8vD7502Qwij >									
//	        < u =="0.000000000000000001" ; [ 000056987523459.000000000000000000 ; 000056999613571.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000153AC0F59153BE820D >									
//	    < PI_YU_ROMA ; Line_5745 ; FK0R7v8hf2h7MMxx5NqkQ4YJ9jtCrE5CvqmU8NmAlv7k8zg5j ; 20171122 ; subDT >									
//	        < bXl36l5EOEc777wF4CY1ksii9VvJ3dx2ilCU61n3j4VK78Vqbz0n0Gy0ss20Cz37 >									
//	        < 7DNTwS3l2Q10Mpa2WxUaw5n2350a6D6mhnY4XJtkkGBvxqI5rdH735jJE3fBDhT1 >									
//	        < u =="0.000000000000000001" ; [ 000056999613571.000000000000000000 ; 000057007222774.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000153BE820D153CA1E65 >									
//	    < PI_YU_ROMA ; Line_5746 ; HsBO35lgxUagpU59HINUQ255i30A79K8a0qI974GOjzLoV2Z5 ; 20171122 ; subDT >									
//	        < O53CmjeTLV4y64un6rtFuxZL0Lot8j1SSKoa32yS70GG1m9WqCXIHXsNwj91FT32 >									
//	        < a82Y1vNX9207pZ249NQrzIDNhJQ2mv3X082Kb35sANt46Pp3LvCGe76y3QZwL3Y9 >									
//	        < u =="0.000000000000000001" ; [ 000057007222774.000000000000000000 ; 000057013724692.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000153CA1E65153D40A35 >									
//	    < PI_YU_ROMA ; Line_5747 ; Jhu4V1U08M7rFC39E8bN09dtNh17if1409af6LnAW8ft7H7dd ; 20171122 ; subDT >									
//	        < 89EeEaK3u8Dq7Xeo09f93EUyR0hdhFJ5mQ6h7196zNZ18MQ52R3JZ8YrtWHhN9AQ >									
//	        < uSc9cuXo6xCTg6hoRBZ17z2Tf0P4E60Y36AFyhf6eLPo341xM52GTxq5v1Y4MXM3 >									
//	        < u =="0.000000000000000001" ; [ 000057013724692.000000000000000000 ; 000057023997751.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000153D40A35153E3B71F >									
//	    < PI_YU_ROMA ; Line_5748 ; 1o3598ZZbsOVc3WIf6bxbYskQQ2xE5l4Vu2pvGkie8T3f37E8 ; 20171122 ; subDT >									
//	        < Wzq2V1BZ4Ugvge0IIeNu93djv1Tvo9tPm050psVf8SV4LZuU430T6FwU3sJ30g4y >									
//	        < 17Fxi4H8242eei5ZPcqPNnU5HSk9D7D4Avy5P6F936kZcG3ihu8i1dl9CAA2ma4E >									
//	        < u =="0.000000000000000001" ; [ 000057023997751.000000000000000000 ; 000057033093674.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000153E3B71F153F19837 >									
//	    < PI_YU_ROMA ; Line_5749 ; v39ZmJxcv0SE3L9F46RGhhVJrrPRkg6C0I8RMJC4yk2cStjJE ; 20171122 ; subDT >									
//	        < bYGY2468ODE45c8ZY64M41wI7zhfMS916NR8EJle4S037C5267c03rPXG52ucXC2 >									
//	        < yZ6l4595H9pUNabQ2T7iQ5aVarlR3c6TrYUqvCOO468k10as0imdxmw23ml2j2j1 >									
//	        < u =="0.000000000000000001" ; [ 000057033093674.000000000000000000 ; 000057039935396.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000153F19837153FC08C3 >									
//	    < PI_YU_ROMA ; Line_5750 ; 3Q2ka4VjfM8OXwFBPPzP0811GJ0N2icMljuiO9gl0S0eAsGBP ; 20171122 ; subDT >									
//	        < 6Cw3ehX9Zsw3Iux15yjpVgj6Dr1hBUA4624W7U8BI7CfLIU4QA2ROzCX3QJpoUnP >									
//	        < c4r80Cr8MIbiQkV9t29FmGbQf3Jo0GcK9ZuRgN75Opzluy8sEcm7NQ2Q0i5o8A51 >									
//	        < u =="0.000000000000000001" ; [ 000057039935396.000000000000000000 ; 000057052802447.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000153FC08C31540FAAF4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5751 à 5760									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5751 ; nx5uxb8F93D56OELz84G54uUKNFeEkEalJLL15a5W0D50pxq2 ; 20171122 ; subDT >									
//	        < 62x92mCon5554wpU0Kem0TIu9X0imz90c9g6EY38bS1OWO2NSFVux8ArbEsj1K2u >									
//	        < iPJ0imRELXPp0MLJ0mGZV0BY1hv9rg9pTHKKY73el96Y21w4I52931IASIS92Gw6 >									
//	        < u =="0.000000000000000001" ; [ 000057052802447.000000000000000000 ; 000057057958600.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001540FAAF4154178914 >									
//	    < PI_YU_ROMA ; Line_5752 ; 4l5M4qOg3KTNnjjiMIqW4Sk4L7KA1f6GkGSfx08EPO8xBc82j ; 20171122 ; subDT >									
//	        < R0y3fiZbi9wa8C6gF105C25sJ47781ims4HV2v937Lx1M97hNr7EP82AuO3M0mkT >									
//	        < cvQu039qyNK9Pp19Dc8rtfv2tCrPLCiBJyDIx34EV0Z9KfS4vT65R5JRed97woHo >									
//	        < u =="0.000000000000000001" ; [ 000057057958600.000000000000000000 ; 000057065490931.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000154178914154230765 >									
//	    < PI_YU_ROMA ; Line_5753 ; Tc2eS8th2314Bkgm2G3eIeGcV5De7N2PyjlA98n58VIX7hs82 ; 20171122 ; subDT >									
//	        < iGxJ2Nc5u1U51wk8w7U6x1IE8qfUdF81fHYyoTehUnj6Vk65S0iZ49FtpLNnB1g4 >									
//	        < G2kyHbN4AXukTj8092r0JN6Zz5beaq2aiBCkBOd4z24b8WnQBZ0005R6JD0w33mg >									
//	        < u =="0.000000000000000001" ; [ 000057065490931.000000000000000000 ; 000057074746799.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001542307651543126F7 >									
//	    < PI_YU_ROMA ; Line_5754 ; he575z347DJ2P93PkX22RJxtJ8G6O7y0mRDz066Z3kjP16D93 ; 20171122 ; subDT >									
//	        < XpbnY580plrE0b7cEe7ocY1rk977vt4DL4awYWNMTEi0qC1gg7qXtMVl0OuHFTZ5 >									
//	        < 9h0T7Ick0OO9eUsOI6GYO6YJZ8CW7VV4kzfJQnq60eXLOx4IBf9ZzoPQ9T02EEXE >									
//	        < u =="0.000000000000000001" ; [ 000057074746799.000000000000000000 ; 000057089528761.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001543126F715447B52C >									
//	    < PI_YU_ROMA ; Line_5755 ; 0FL7ZWvl882fOx4dU9e2PDVuLg3m5xi6768qKwNqGwb7PnoCu ; 20171122 ; subDT >									
//	        < h79Lqz6NQ99p7ZF1p5RimqfDXD3aV3S5B03Le7405kQRNj1z8477F9t5TbhWr39z >									
//	        < zg2f0j20mkiH8s732dh8O1tu3IH8t8cmACp3xfDcu4S448EV1e4cq01NluKgbjqK >									
//	        < u =="0.000000000000000001" ; [ 000057089528761.000000000000000000 ; 000057097942690.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015447B52C154548BDD >									
//	    < PI_YU_ROMA ; Line_5756 ; pckmgI6jkXI1v7pFfLF5B8e2s69znMoO7zw1Z1x2Kp6qj4UBr ; 20171122 ; subDT >									
//	        < qKG58oPvI9e3w464HS4ad4PK30k93o7rQlRsBbByd1lw8bXixAXW2CiC36TY30el >									
//	        < oBsNj7Az0Kj9Nei47qVTMHbz5h2QVlCbajGrbT8O8Tpn31VmC85aGhBNDMdd9UYz >									
//	        < u =="0.000000000000000001" ; [ 000057097942690.000000000000000000 ; 000057111510521.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000154548BDD154693FCC >									
//	    < PI_YU_ROMA ; Line_5757 ; r3m925Z9q0F6qq4G5UJDT9tkuM51365UrHKp4nItD37x4u2z8 ; 20171122 ; subDT >									
//	        < AFWmkM8ri3w4a8L69m8eFz94GC1AAr4iyL1jO6vv4eYu7psF2l6YhyLgYeK3s996 >									
//	        < 7zWOrFu7SJqtYvqfyOK0AR7z4F8R9Lb7H1PWs5GKSYuS3aNSp22M3BXdK6nZ11Vl >									
//	        < u =="0.000000000000000001" ; [ 000057111510521.000000000000000000 ; 000057120327033.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000154693FCC15476B3BF >									
//	    < PI_YU_ROMA ; Line_5758 ; olVWuN4Z1gHoCb5a3v0LcUh3m9Lzc3I4Nk99EV69WGHZ1shMB ; 20171122 ; subDT >									
//	        < 6CG91ZZ1XO5Lba3t0SSeCzZkRKb034mi461BDcJ94uBZWgj6BgtWn2SR7dY8B270 >									
//	        < 9K78KD82ef70AwvD2C4x18Le7vf9cUeLFEZBRQYxcGx7VoONyMCxB07z9b9UXRm8 >									
//	        < u =="0.000000000000000001" ; [ 000057120327033.000000000000000000 ; 000057127112614.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015476B3BF154810E5D >									
//	    < PI_YU_ROMA ; Line_5759 ; rZazM7n972xnO9NqBskf0UbMFJ3Lc1jGcmM224N4kNEz5ogi7 ; 20171122 ; subDT >									
//	        < rm53w0zP9GaW0MY0kb831yicZOF2zr6D39OFB1E5Nx8q3UBuSw5FQQWZ5jMNZ7p4 >									
//	        < WSm45i9Kj4E8LKC9vva259MRr59CO1RdJ9lZ1117L5l2x8g6iaInA2bNaeSZwc5s >									
//	        < u =="0.000000000000000001" ; [ 000057127112614.000000000000000000 ; 000057139737368.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000154810E5D1549451E8 >									
//	    < PI_YU_ROMA ; Line_5760 ; h5NUwG45dPqQ1A43G1184w8e6xf3789Gwq30rSMg12rNJc56G ; 20171122 ; subDT >									
//	        < hqydHUkGhW9leKNuR0y5JN3297zeAWOMkd64U38dH5XzCE8EK41bWr7idmFRNT20 >									
//	        < x992O7FZcRf6Ig407uymYV02JS67xEi2H2P3qFoW1p5TX18dM86J8zqzMoyovj21 >									
//	        < u =="0.000000000000000001" ; [ 000057139737368.000000000000000000 ; 000057148062324.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001549451E8154A105D8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5761 à 5770									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5761 ; BBND81c2hYIz6MZ631o23xKrTVnZO8Ir1iJbXSHwqjNqeiDMS ; 20171122 ; subDT >									
//	        < K1BOIMRXatONcKL5X0MTA0F1T9bMNiR8VP3ncfc0EP1422mc1CMZAsLJ3Vts41K8 >									
//	        < wIcx9H8BbzQ4F5y92O7mFP117I2C9mWzjz2i7kX76ew2VPMzX1MUJjS71MWV7nJ0 >									
//	        < u =="0.000000000000000001" ; [ 000057148062324.000000000000000000 ; 000057153613364.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000154A105D8154A97E38 >									
//	    < PI_YU_ROMA ; Line_5762 ; 1y12zuLQl47KqZ6DnnnB42QNQi2Q086Avm8pizywUa8Y9duNo ; 20171122 ; subDT >									
//	        < M7DPsfb0178zo7W7g474293Q1o75p5DKYXabk2myN2ew592YB0rA5D72tU7Ze6mT >									
//	        < ToDS18z9JkJPip2cLHloQxi96yx2o66egY5c9cX369BQVO7KZ1sskq06t9GD13VG >									
//	        < u =="0.000000000000000001" ; [ 000057153613364.000000000000000000 ; 000057163851178.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000154A97E38154B91D5D >									
//	    < PI_YU_ROMA ; Line_5763 ; BS4B36m0Ht054O3mso9m1a4426q4g6RzMEtTzERK5gErspGos ; 20171122 ; subDT >									
//	        < R3169RJ50Mwk4aSKmL8H53CXuFJk6fJf7QREi11I6Xe957fgwIP388dol56y0JD3 >									
//	        < 15rBm610I28PunoWBZVwEje9o1619g0RLYrEIC3oaTb56Qvrwt4c8A94a4WVVftc >									
//	        < u =="0.000000000000000001" ; [ 000057163851178.000000000000000000 ; 000057176861755.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000154B91D5D154CCF79F >									
//	    < PI_YU_ROMA ; Line_5764 ; 5553XrZ9Kv7tqT9Yj75A5SMNqc7aMRE6dV6eMB78ver577Wq9 ; 20171122 ; subDT >									
//	        < 642Q1c1h5JqFv7b1550xs3T50UGdAioJF2eP9a383OU9a213tGhMoZwR6l83SWu0 >									
//	        < Kb7axv0gKOy359a59ZsTJD60h2iHhnBcddUX1A6EcU1WlA3d93841WN9LZLN73vU >									
//	        < u =="0.000000000000000001" ; [ 000057176861755.000000000000000000 ; 000057190014906.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000154CCF79F154E10992 >									
//	    < PI_YU_ROMA ; Line_5765 ; AdyEBYWa1X7koiHfAiC1quJL8xcGJMWgtFY28531mDolncCNB ; 20171122 ; subDT >									
//	        < LuYE480uXOA3nK4wqY3vN1186FOtZ0Rsr81Jo49QNi096p3V99iqj87D1T4omUz4 >									
//	        < yh87Jdf5PR4YD46galnH9G8dGCZq8QQ8Chfw0S2nA2601cj9y3201nk84N7pI02k >									
//	        < u =="0.000000000000000001" ; [ 000057190014906.000000000000000000 ; 000057198491653.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000154E10992154EDF8CD >									
//	    < PI_YU_ROMA ; Line_5766 ; H6MQULpN0CH7Nf2VAOCpyD5tQ3MV6bjRXhY61Xpb54hOO365I ; 20171122 ; subDT >									
//	        < 7T85ChcEH4Z9742ll3O9f7NDZw2i6gGTv3Oi3ynbLWWZlYrm4gfzrOd6g3ztqL8O >									
//	        < k99yKc2NKyz13f69gmcmr5ek91681506873a74x71xu67hQB1OXG4kHmG29cspbp >									
//	        < u =="0.000000000000000001" ; [ 000057198491653.000000000000000000 ; 000057207178447.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000154EDF8CD154FB3A14 >									
//	    < PI_YU_ROMA ; Line_5767 ; Vf6G98e0mhaIVG213iK7KMq7txuT4V979z8R89Bga7NUCd4l8 ; 20171122 ; subDT >									
//	        < 4hOc7575b43SEhn4zKmeKg1LzEUVESuW01p7jKuD8M3xhMrfD2Ozmfo455ifdSvW >									
//	        < B24fpX9945erBk655bSTCVX4273Er3k4b694P0pZGu631cunte8B730c05Z1TswE >									
//	        < u =="0.000000000000000001" ; [ 000057207178447.000000000000000000 ; 000057220295388.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000154FB3A141550F3DE2 >									
//	    < PI_YU_ROMA ; Line_5768 ; UhhxjWuMVD9BHFO9Zffdhsz0xd6Q0A1v471Dz2kreovKGVRJ8 ; 20171122 ; subDT >									
//	        < uv8654P0ts585A06wCGK8b9991a8yd51lSXY4zCeeUA18sW45013TCbBK2001KR8 >									
//	        < R6MJWL5Q9tI7016jX62UOjyi225WWJk8RmcCL6MZ5RzRfXsKZ3ayz6P01e47x5ju >									
//	        < u =="0.000000000000000001" ; [ 000057220295388.000000000000000000 ; 000057228615656.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001550F3DE21551BEFFD >									
//	    < PI_YU_ROMA ; Line_5769 ; iZw0GyPwPc431o7nFbeFiitj2XZLANlYsYdldcQQNrZ99ts0C ; 20171122 ; subDT >									
//	        < e5d6RlBQPcCGJ7g90U09MBQ1EmqnS6cG5b90S04rl0hf6NDwf62HlYi25WNi9025 >									
//	        < l9t521RJaK1e3478IEWPcgb579o16O09C4z7OxJ0377LkL6AOa3Tm61482CaGnxj >									
//	        < u =="0.000000000000000001" ; [ 000057228615656.000000000000000000 ; 000057243207485.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001551BEFFD1553233EC >									
//	    < PI_YU_ROMA ; Line_5770 ; HBatFhS3M3Xv169812Nr789Fs7Tis5CJ93dAAbCKVCwjJIHlt ; 20171122 ; subDT >									
//	        < MpCy6dWH08u7vFtk37566dsFaiINN8zES2B6L2q1G3PT2hO45OP6YoA90x2H2hml >									
//	        < tpXhBHGs21L407nHU37W699YuS01YK3tZ6Yb8dibb5NitaO63S08LW6zta6Z0oxu >									
//	        < u =="0.000000000000000001" ; [ 000057243207485.000000000000000000 ; 000057254453805.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001553233EC155435D04 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5771 à 5780									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5771 ; 7Pt7zfV62gQ1TeRVqPXwWAc5t4uriF7f15R8ajhh75H9Bb40c ; 20171122 ; subDT >									
//	        < 01PdWZCQ69ymmXhHFevYWElWqfRz67Px0V4I71lz39B26J3lQwUPV06S3LC19P3F >									
//	        < bCMrcsYcs0XRFQIp16t4zMtElOurfcITL0e39Y4u6q8o1VzWad49TLFcOFb37sWn >									
//	        < u =="0.000000000000000001" ; [ 000057254453805.000000000000000000 ; 000057264075868.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000155435D04155520BA2 >									
//	    < PI_YU_ROMA ; Line_5772 ; 9mfjQYYdDQ6jKX4rW2afC3HE866KUABbLd6gH93o4EpG9b4RV ; 20171122 ; subDT >									
//	        < iA302JDHrW0b5iW1IoE3TC40bv9545Y61tlsFoHu3n363dt0Gho10xiNb6w4WBr9 >									
//	        < aK8rTw647hVsGIYest4383XH1bQrLa1cK09L7K473Lgd192764J7Q9ezUePjLrCk >									
//	        < u =="0.000000000000000001" ; [ 000057264075868.000000000000000000 ; 000057274522484.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000155520BA215561FC58 >									
//	    < PI_YU_ROMA ; Line_5773 ; 4JPV7ZO54bE845Dyj7B0y3rK3ob0D8J792Lj5o61nlkVYJAat ; 20171122 ; subDT >									
//	        < vv1CXCQ35J7ZdMTVCu485r86u8WOBvY0NPLgww4Yzu1q8fTH5n95vX2MU0yPlG33 >									
//	        < 2gGRZ9ZFY1A8GH3AiCZF9qRINaIZ817mnOS2F99ZP413TP856wGyaNXI8763Dy2q >									
//	        < u =="0.000000000000000001" ; [ 000057274522484.000000000000000000 ; 000057284371571.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015561FC581557103A5 >									
//	    < PI_YU_ROMA ; Line_5774 ; 8j7dB7he9XpU40PS94m0gh25zDWF41py6TP4V9RzdXrro95Z9 ; 20171122 ; subDT >									
//	        < YkX9B87B636YXfczxXJJi6nfou03R5szgNybxJl1D70T8JoUEDw5fkH3hlDuIOid >									
//	        < RvFqDYauJ4Y1m5Wpmwvpn5c11aq5YI1XpF4yEj4SnMM64LoA5KtxwXP2B3Q4Z178 >									
//	        < u =="0.000000000000000001" ; [ 000057284371571.000000000000000000 ; 000057295791083.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001557103A5155827064 >									
//	    < PI_YU_ROMA ; Line_5775 ; 52j39L7vwd33elG1qi3h3N78JT8G5Q1oQb1qADI6wP0z8lk42 ; 20171122 ; subDT >									
//	        < D4p2JHzKPBNY1ecEzB3TaVs1L0Q57pdvAmyO4W50ggAY3dSg0JU5sfr7xSw1B2mE >									
//	        < 5z3D6oAimlOc12v8v8gD2mg2T9pO5EYbrV0x3m8kjwcbnP2450E2C6vMn2Ncs5K5 >									
//	        < u =="0.000000000000000001" ; [ 000057295791083.000000000000000000 ; 000057307934883.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015582706415594F810 >									
//	    < PI_YU_ROMA ; Line_5776 ; 1j34V889WyuOlVfi8s5bHhmT2M6gaDdRpSmjFiD8eI9b9f6AQ ; 20171122 ; subDT >									
//	        < AI904rqVKNTKyWwFkkhxXE34Z7FEa5D493BlZXbJSfQ8z8WRl82oUhqEFnUUd8i7 >									
//	        < 4PbqHb8fUUe9qUOevuEUYV0Z31ZpC24ZC4Isr9B2Vki7UAA22K8nV668m72MIA4F >									
//	        < u =="0.000000000000000001" ; [ 000057307934883.000000000000000000 ; 000057313003114.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015594F8101559CB3D7 >									
//	    < PI_YU_ROMA ; Line_5777 ; CB049I53H8MTtHZhYR86KwZpK5k8hRg679gAJ91vc5fwAhw5Q ; 20171122 ; subDT >									
//	        < QB12M8fFA814WQ71NUj1VWAqiEqEnWhf7jA30jT42u29q1mXlQsJ4u55O84Ak533 >									
//	        < SKgl01jP5yGfOBaDkVkodAJZB603ffH7bx049mN388FhIZdV1m07358W2olH4bCX >									
//	        < u =="0.000000000000000001" ; [ 000057313003114.000000000000000000 ; 000057320616250.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001559CB3D7155A851B9 >									
//	    < PI_YU_ROMA ; Line_5778 ; 8UJm9213lwFQe0igbz2v9cx3R1Se81749fU5p2k7pFVaUf9fj ; 20171122 ; subDT >									
//	        < 7vKk47tqlgnp726g5aLAG7b3qnF40uT9U78qyAt3KBmb0J0l3C4q9EmJd429xJG4 >									
//	        < ZivIR6kp0Rem215Uw4ZZjZ96VbMp93Aeq3u2ZBI773e932ZFDuBd3u8EKC4A3rC2 >									
//	        < u =="0.000000000000000001" ; [ 000057320616250.000000000000000000 ; 000057328902008.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000155A851B9155B4F658 >									
//	    < PI_YU_ROMA ; Line_5779 ; fbylz9tK1s80oY1yhIL9gs9Z1b01a14MYA464QG7SV5he95dR ; 20171122 ; subDT >									
//	        < 08zQj6D04HyaoeLC7931giZ7b382nKk7p2pUKRLbCtAc3Wfj27151Japb402Hxfn >									
//	        < X534hc0RBE26j7IVk1lX546si1JD9iE50JhX7MJV27vAF2X4bNc5h289pvn3X5m1 >									
//	        < u =="0.000000000000000001" ; [ 000057328902008.000000000000000000 ; 000057334401799.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000155B4F658155BD5AB3 >									
//	    < PI_YU_ROMA ; Line_5780 ; B8l5f6YkLa0sJteiFoDnKg9gm32Pur6TOnojzM47BjFBDi0MS ; 20171122 ; subDT >									
//	        < zPi9ydu41Z8K5Xwc5i5ZQ5C030Z66ElHHgkEM6DTH2b48zVwKpusqQyBpG8uPyhA >									
//	        < V3XQTPO9a6h9487x6J5brfb15xEs5LW5KVn2mMxe40jhKOr6a7x1ds9Y1A7fhPsl >									
//	        < u =="0.000000000000000001" ; [ 000057334401799.000000000000000000 ; 000057341053301.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000155BD5AB3155C780F2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5781 à 5790									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5781 ; 1dXk6UJ9n7j04x21me9G3tc78DijbWQ2N51h6wR9zE2MIuFQs ; 20171122 ; subDT >									
//	        < 6Hdv4do5rq3Z0909G7u2OeI218reGSiF879E12w04YJ02nb4NT38nMduLK493YoV >									
//	        < i018B1HrlkeBb0u61p4jG8246oMo8384oQchzGjxPn3zVUV0Uk70As74KYN3c37p >									
//	        < u =="0.000000000000000001" ; [ 000057341053301.000000000000000000 ; 000057354971711.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000155C780F2155DCBDD3 >									
//	    < PI_YU_ROMA ; Line_5782 ; 0w4i3VXk6R59K07SqD8ygCY3rZ4925ohO0IOSDsU96vrTMo6J ; 20171122 ; subDT >									
//	        < eP6XaVrps9V4GCeMY7J646NBS396nXcYO848lV6mCAvh03p917QN1k1M4e80KD2q >									
//	        < y83B1A9U0S9zp0N5479dPIZyK7m2H29w815iBV1jIH31OIKe2R19m6cb5gVc6864 >									
//	        < u =="0.000000000000000001" ; [ 000057354971711.000000000000000000 ; 000057364789307.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000155DCBDD3155EBB8D2 >									
//	    < PI_YU_ROMA ; Line_5783 ; 436Q9XfgAu4l8754LCy5o66XJlI5eq0QtOeXten0Bd3ES2WY5 ; 20171122 ; subDT >									
//	        < 83rL3k2DfB2pdVptVP6G7nv43Hw12J68uKfJ6fmFSDeZOi1Zb22G0n1D81Fzd3Fd >									
//	        < KvzmFvi76XEL16X654SKZ8994atj4q4EMD7ADVrEtMVR4Dc2tS079l4Mxni89jYf >									
//	        < u =="0.000000000000000001" ; [ 000057364789307.000000000000000000 ; 000057378010918.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000155EBB8D2155FFE583 >									
//	    < PI_YU_ROMA ; Line_5784 ; PGwBP02Y25I20ATqo4z63O9Gl3o84NX4ED89LgXmzt8nAk4cd ; 20171122 ; subDT >									
//	        < VZwdNp09C38MLkjS1KBW54TpQ1P7dS6bD2tE9cO0O1pzwD0Qjqy3444ZP0Z1x9BD >									
//	        < l7lnHtr6Gh0o0Mz29Bj10zb9eiGjrk8HIsVXUl1y6mF0S323UpNw2bAmt9Sp67k0 >									
//	        < u =="0.000000000000000001" ; [ 000057378010918.000000000000000000 ; 000057383085476.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000155FFE58315607A3C3 >									
//	    < PI_YU_ROMA ; Line_5785 ; PuyH1kCg135n4Qdoi5q90BWw728C7W2J0S8BbJ3WYa3Rn1Q5T ; 20171122 ; subDT >									
//	        < SMjMYZe33VqAlQ4Row8rNZi4dzdivPCqcPvXsXpwBT5iZMZ2iw7qmi63Sv11g216 >									
//	        < 70kFp9408936WZAyq4BD9c01cq0c1Ze6HjnM45zqj1cnVBCf33t3r65CRPZr2i9k >									
//	        < u =="0.000000000000000001" ; [ 000057383085476.000000000000000000 ; 000057396637571.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015607A3C31561C518D >									
//	    < PI_YU_ROMA ; Line_5786 ; lb0Rydx2eve9Ec28m27S7tEM4E6Jg4YMU983V0C6g2x9hHKLW ; 20171122 ; subDT >									
//	        < x0eFV658s4uluC6fnSWZnK2A6G0y7Dp9840FY4M4u5py08xk5r210a40ZuNxP5l5 >									
//	        < nro8oytLkH6yL5fXXxX737p9Sr0w44iHD6P1W1j1qL5t6r8qqxS3CUC47HGGxgA8 >									
//	        < u =="0.000000000000000001" ; [ 000057396637571.000000000000000000 ; 000057410526355.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001561C518D1563182DB >									
//	    < PI_YU_ROMA ; Line_5787 ; rw312kCm1XCS5Ku8jPP0D991iNI59CoonGIAnDEJ8WvLb6G8R ; 20171122 ; subDT >									
//	        < 1HoEs0XXG8fEBGq9Z016mLqRH5ekYjkgX13ZgcmVDMSUQAJut65SRu0aqh2rI9E6 >									
//	        < q62B87BE1so9cqg7Vf7M6u1G6ALZ7Vpj7rW7a1G42NU7WtBE7JQP71m46l55RSVh >									
//	        < u =="0.000000000000000001" ; [ 000057410526355.000000000000000000 ; 000057418253154.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001563182DB1563D4D23 >									
//	    < PI_YU_ROMA ; Line_5788 ; rwsGWiBQT2WJj52hHt47B5bbhtJ1Icb5UtiUgpKEkzR17vN44 ; 20171122 ; subDT >									
//	        < ooy86P1rnb6n21gdsCjoV7UqEcb5Sw21eS727EHG6t0AzkII1U62D27UEdg1QA4d >									
//	        < 8M3Xqg5r618tPa016h81xXF1mz74428U6601tHqAe7nCSb58aY1325MuqsaO0pmb >									
//	        < u =="0.000000000000000001" ; [ 000057418253154.000000000000000000 ; 000057426635030.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001563D4D231564A174F >									
//	    < PI_YU_ROMA ; Line_5789 ; 79uGgfEzxp8y7uk9o812gOv95sKVPn56I6w34Zd8uB4D14Nl0 ; 20171122 ; subDT >									
//	        < j1fc6RTmYbZ6yAcl85Yfl2mf1dhtQEyBrgr0k942kgaIvY00g2O41Cm2TOQe3ZQ6 >									
//	        < QGu93A7SAQppr39akMMOJs0Ofs57vYkYMk5AuqpHVJU2L3tGxPHk4pr8ntPfbzIo >									
//	        < u =="0.000000000000000001" ; [ 000057426635030.000000000000000000 ; 000057437806163.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001564A174F1565B2308 >									
//	    < PI_YU_ROMA ; Line_5790 ; S5jp6DXCf6dLQtSS16QUg9NCErzD6AL6bMwo1MvwKNqY418t3 ; 20171122 ; subDT >									
//	        < 4eZ4WiEqc6mlL2cVK3U09AE8z0ksXi7myGT30ZEw6fgn4UXZWIEro0PH55I208ju >									
//	        < 5dEY96VghYEW1BJ02sFf1W5T3rE5Nn48eez9ahmOF0zU64453Yd915owPjNLJLA3 >									
//	        < u =="0.000000000000000001" ; [ 000057437806163.000000000000000000 ; 000057444858086.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001565B230815665E5B0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5791 à 5800									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5791 ; WQB0LZ443xSz5OLVS2qFdvo15s5R1n2j1PUOpt8kEPzq8XjxB ; 20171122 ; subDT >									
//	        < 06ei45780cxW4zZ98D830j982Ues9U7Gua1J2kDdJ13Q5I58N8P7R1ImYcP3ob1T >									
//	        < csR1cq3Kao6LQ5dv61K066R7etph97F3lGxvJ6g3AGArrO0YF6K8MhWr8Pb2ui9q >									
//	        < u =="0.000000000000000001" ; [ 000057444858086.000000000000000000 ; 000057454141808.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015665E5B0156741024 >									
//	    < PI_YU_ROMA ; Line_5792 ; BgFZ35xwcc5QbxdMIQ4s2L8wGlPwcs4so9W6rI8FBZjG2XMJN ; 20171122 ; subDT >									
//	        < 693bu979auVhj4zWG7G707HqSprwYt7z3p960cimk7HadT2uN6NR9Z8NP569hZm0 >									
//	        < 6zzKF9KHzH57Ai76r73n1dw1957R4W643877K66moOt82La5hE2PU84PJ3d0l40u >									
//	        < u =="0.000000000000000001" ; [ 000057454141808.000000000000000000 ; 000057461453496.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001567410241567F3845 >									
//	    < PI_YU_ROMA ; Line_5793 ; NmKyjZuJl1Jp3S8Ni52k7HM5DHZcQitL1Xh7w8M1R4C94221Y ; 20171122 ; subDT >									
//	        < 51Rek6k4GEu0N1l6P42USr9xwLP6Zy57d9Rb81pLOqew2F84EgQRCv3fzActA266 >									
//	        < yrT5Qi5YY798DtbEFfhe100NPoolq7mnkb0390W0h2mJ6krwRckcrm2rfk1zc9rz >									
//	        < u =="0.000000000000000001" ; [ 000057461453496.000000000000000000 ; 000057474035689.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001567F3845156926B30 >									
//	    < PI_YU_ROMA ; Line_5794 ; PMLcL57f1l4BDLm1pTMPcOh8FVvtyeqv70L4HNwe53LMOGqCj ; 20171122 ; subDT >									
//	        < b0607HC2hkBAj5iM264Zo2xRTK2ce22bBl57qV50JP7J7CeY29keodWoY88oZI66 >									
//	        < DCI3lM2475J2zF86894kB6r6g8fMY0zmzxNeyb8wvoV2YCnq5P13F86XCocRQO45 >									
//	        < u =="0.000000000000000001" ; [ 000057474035689.000000000000000000 ; 000057487743375.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000156926B30156A755C1 >									
//	    < PI_YU_ROMA ; Line_5795 ; 9jfAfuU9rLNBcib3a2fP21wrhQK2P8RyP7Ex0169ma9LYx527 ; 20171122 ; subDT >									
//	        < I5P9j17H1UU62d0zE2FCzfhi7K90u4BV3lG3sPgvf16jXp01b85L5SLjF8oiym3M >									
//	        < 2p77DI48pDA603jOmzCKy6T6P65YW3y4P14aUW213ARWaljPjYuR5jXn8NhAdT7T >									
//	        < u =="0.000000000000000001" ; [ 000057487743375.000000000000000000 ; 000057495796829.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000156A755C1156B39FA2 >									
//	    < PI_YU_ROMA ; Line_5796 ; 9xtQa8n94F3JgMP76289Wv8091CXmm5b4rgEWSXhs84L5y342 ; 20171122 ; subDT >									
//	        < d0A0K6e4D07aJ2MVe5c1vB2R8WX3w1jeH2VCJgvwH2J2DnzA0O6j59jj14OHN834 >									
//	        < 0gdHdW5bX053PUA45DD77y2r350vE1U5p1Lno9NH7PU1b2Nq4eAP6ESl618Y10Bj >									
//	        < u =="0.000000000000000001" ; [ 000057495796829.000000000000000000 ; 000057505306800.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000156B39FA2156C22278 >									
//	    < PI_YU_ROMA ; Line_5797 ; 9p85018CTnxl3EljdivIZHAg0s47J5mnOo53p2LvLg9pEH73Q ; 20171122 ; subDT >									
//	        < g1czR2c2sc8h4OgYQb0G3SqPU1GE1jzDU0An98wrA0DuAbJe4gXD7r3K5O9oZ388 >									
//	        < Bi51Bg3suCR3ghQ5dXk34l4rb25QgQq9Qy9Ueppp0z7l79Kq3IML0bh7HWd91j8J >									
//	        < u =="0.000000000000000001" ; [ 000057505306800.000000000000000000 ; 000057512249915.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000156C22278156CCBA9F >									
//	    < PI_YU_ROMA ; Line_5798 ; 6my6x4fOBpwLv9rN9tk6SLe4382kQ32US2ETRbEBVWo4DoI2s ; 20171122 ; subDT >									
//	        < 165eY2j934mlfNf8t985IZPa4awH3lx5yC70596k7uk1734U7r96I50vgC8curPK >									
//	        < gI6pew33fo78d1VxoLPSt0UQFFz1GP8Z47pyM3pKsYRLJa9Q32dh0HUKjfTQ4m8X >									
//	        < u =="0.000000000000000001" ; [ 000057512249915.000000000000000000 ; 000057519454057.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000156CCBA9F156D7B8BD >									
//	    < PI_YU_ROMA ; Line_5799 ; ix0FU6byBzaPKMxt4g2w21huC5z3RqEF579R0401g3du5NM5r ; 20171122 ; subDT >									
//	        < 4W2vhLP82bZHnmGR9SQ38Mhsn1O5l9Y8au59ppF8LKL4hN2K976U21R0D06RGjsr >									
//	        < gi181k7n8qZYjRDUjmqxib038Js6m5EnX3hS53Ysu8LH51Jxt4tRKxggiDwahOXp >									
//	        < u =="0.000000000000000001" ; [ 000057519454057.000000000000000000 ; 000057531197887.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000156D7B8BD156E9A42C >									
//	    < PI_YU_ROMA ; Line_5800 ; RSDdeQf119KeRRK81vLW856aP2cPZ4eyWHdvS782KA6c26N7w ; 20171122 ; subDT >									
//	        < 04C2y4Pk6tde05x4i5Rw6YM0A8roZFChvu1ul2plyuwsX2r7SXF18M3NUg8zXyAP >									
//	        < ebd8jQ5asWnx2vAsq51asOkcQ3v0pguDeDF2h8583auDsNWiD93641vrAaEysn1P >									
//	        < u =="0.000000000000000001" ; [ 000057531197887.000000000000000000 ; 000057543726799.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000156E9A42C156FCC247 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5801 à 5810									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5801 ; arxA9cSD38n5j2poG0pXWRa4Zf21yab9RtFqMJ92zXiDy5byH ; 20171122 ; subDT >									
//	        < yj7RU4eZhaW2U47N6F69n72L4to5wFyEr1KhtwQJz00PRi3Y8l9dN498218ym188 >									
//	        < 8wM2utu3pCK4nNpmgTc6356fy207Hxac4Sc0N8qOLFF7h575fCB5F2S37IRt522n >									
//	        < u =="0.000000000000000001" ; [ 000057543726799.000000000000000000 ; 000057555791346.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000156FCC2471570F2AFE >									
//	    < PI_YU_ROMA ; Line_5802 ; h8pC9MfhZ13wE95qOw3RC1qNoeD6cWXmm0gBGOswnB5bt5H20 ; 20171122 ; subDT >									
//	        < Qbg64FxxKdt08hOiMGB2Pkn6IhmI04L3308FAgS4OL468w003lxY513tc3E0pvZY >									
//	        < YX2JW57r9245QX5EX8t63wv164Rby6hvBPAeEQi07O5m5O9pqFQ5K1Ws65898S88 >									
//	        < u =="0.000000000000000001" ; [ 000057555791346.000000000000000000 ; 000057566896816.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001570F2AFE157201D11 >									
//	    < PI_YU_ROMA ; Line_5803 ; Yw6rZ54N163je3MSeavfI75u6ys2NUUsUCiT5isr2ou9PPCm3 ; 20171122 ; subDT >									
//	        < 765VtaxKgSEw7LK0sPjQitfE4umutm0W9yc2UK7JVok359H47b32pT448VJ82W0i >									
//	        < f0ZvT2c6H2MoCH48379J47j6VVrCJhlFx51RcuUlYg63okwmCxe1FvLtGFs7e4L2 >									
//	        < u =="0.000000000000000001" ; [ 000057566896816.000000000000000000 ; 000057578930274.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000157201D111573279A3 >									
//	    < PI_YU_ROMA ; Line_5804 ; IZ9pEt01i1560pwBEDfilU8HjmefS2E0zC1Da01MGqB7smNY9 ; 20171122 ; subDT >									
//	        < IDT5N8blYlt6p7OqS4HoobaB6SMf0lTtec4UYBJY0gkrDSO9jdK2vkQhgH4454d7 >									
//	        < Vaph0N5mv5l9Eo38hMfRdkYG3Jc1OssE1H3u9EAoSt2r8fdzeVjIrETMQcAb4M1V >									
//	        < u =="0.000000000000000001" ; [ 000057578930274.000000000000000000 ; 000057592625851.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001573279A3157475F79 >									
//	    < PI_YU_ROMA ; Line_5805 ; meBC3o1EjWaiIjsUoj8iW81ONGztX52Oa7dMg6lz4aSTW0RL2 ; 20171122 ; subDT >									
//	        < nR1x5VBa06974ZLZY344woktj2dOG3qhwJEUWIT0fW4jIprxeuNi7AYX611Qqk2J >									
//	        < xjYwd2dYw7A60Kanwjjj3T2Ky94JtHgzIzasiVuW0Abu2ej45snvgRoJtVN4mAAj >									
//	        < u =="0.000000000000000001" ; [ 000057592625851.000000000000000000 ; 000057602437103.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000157475F791575657FE >									
//	    < PI_YU_ROMA ; Line_5806 ; kGl2gAc6y4QBL7eNjWQ94HrHjHxzgNtuw5ZW0Hzf9UbQ63seO ; 20171122 ; subDT >									
//	        < Uf9vWg47Cn8uDn37ea9yk6aCBBGr4Yr42VjjLsN48a3rx8dXq0iIskiKA35rLRD0 >									
//	        < 1dXPwulzhyD2KTYU7COKdTCexB85X7EJ0EK5ch58c7NKlXfwS7Yq18921Gnt63yN >									
//	        < u =="0.000000000000000001" ; [ 000057602437103.000000000000000000 ; 000057611204731.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001575657FE15763B8D9 >									
//	    < PI_YU_ROMA ; Line_5807 ; DGtiMsl9fGQeQ2NSCWkdtMBIFL0cz2T1i93p5cf2yjmXcxPa4 ; 20171122 ; subDT >									
//	        < f6hN2DkOCXSwoJSHs9C19o74ovZJQlMCg8yMwSnMXUwPR10E32kJ0rx47b9AKgoR >									
//	        < 8c1q14iC3BYiHf5qpSBaeqW646toJ480U6gJVbnlb2zvq2Nr1zGdhqfej5v1UYOo >									
//	        < u =="0.000000000000000001" ; [ 000057611204731.000000000000000000 ; 000057623608495.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015763B8D915776A611 >									
//	    < PI_YU_ROMA ; Line_5808 ; 9Rmi7l21tB12YSg3z8yp9pi5ShJS4uvq7hlYX4M7ug5NzQaHZ ; 20171122 ; subDT >									
//	        < 171x7R3dhS89tw9eHhGBLAMAt4nV4796HajQZGUsaWk0i15BFt8og8Y7zIrn2RWQ >									
//	        < w4ATxGfO6JGmfYbPZZOYcDYEdktZozRB047oi2HjlSowg84NvG5dbLvv5yCith03 >									
//	        < u =="0.000000000000000001" ; [ 000057623608495.000000000000000000 ; 000057636968285.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015776A6111578B08BC >									
//	    < PI_YU_ROMA ; Line_5809 ; 5fQ44ZzmVt6381EcCI6F121Fa3E2UZJrO77m1sR494CJJxC14 ; 20171122 ; subDT >									
//	        < UdP18OOY6d8Jzlc0Se2424O66ju8a6VAkS0tvJac66MB6l8LT6n42Ux9DVlipXVV >									
//	        < XXzW0EqbT3sIwp65i9g9A8U4g3Ou01ZIUA1BFz8677z6gfAI7KW7hlS0c79gQ44u >									
//	        < u =="0.000000000000000001" ; [ 000057636968285.000000000000000000 ; 000057644402254.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001578B08BC1579660A1 >									
//	    < PI_YU_ROMA ; Line_5810 ; He51BhY87w5C2CW8L18SV141eT9o5djNMbzm47s4f8wc0KJwG ; 20171122 ; subDT >									
//	        < 8X8F5qB2U3raOj6B9051es9p9WY3YI47g0p3u8ZG6yv1aENo7tnTgA2tS0B2TL8y >									
//	        < ZWmbR5mvYt5e725rkkAJJIXa95J7rGoRC36DzM674E0lgiU3pPglON45Vz8cZZ96 >									
//	        < u =="0.000000000000000001" ; [ 000057644402254.000000000000000000 ; 000057653638264.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001579660A1157A47872 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5811 à 5820									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5811 ; g9gk5boSk4HxfF9rfpa1n5ec6CyGmJfDJ38UTd3G5F63l4e47 ; 20171122 ; subDT >									
//	        < BZ031WsVy32ChH1HAsdFZC0shCGXzxQ258sOlA8Xva3M4Ga92db324y6NW0C459b >									
//	        < 7hwyf6AO8n44K8Of3SQ0h75gWB8Gi4o1KUBf8lAS9LSAIB1mxj3QqEDZ1m3Isox4 >									
//	        < u =="0.000000000000000001" ; [ 000057653638264.000000000000000000 ; 000057665222974.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000157A47872157B625B9 >									
//	    < PI_YU_ROMA ; Line_5812 ; hHZ07S5P52HYfB55xADK70gSs4WGF50hRM3ah5Vk0SVrk6q2n ; 20171122 ; subDT >									
//	        < cJclNzFL2yIA2q7j0Iw425s9C4vu8b45Jj6cmeqYxu3WGi1lAfG381f421cj02wm >									
//	        < bMQ83JSJ2i0ZCB24wpH0CWLEx8FV1n56g1PT1su2Ax3S930gn502HKVnP5r1nt68 >									
//	        < u =="0.000000000000000001" ; [ 000057665222974.000000000000000000 ; 000057674033480.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000157B625B9157C39754 >									
//	    < PI_YU_ROMA ; Line_5813 ; 772ewrGV8CP47MmQ4a3N350148M9dYWs21sDa2850V8426RBb ; 20171122 ; subDT >									
//	        < uc2rfC8f1RmnQMTf3iN69MN4Vw26yXAMm3g5biw9E1TDoQ3s183VmNPYV0yudR9u >									
//	        < uJSMXRK4S2pk7yW3d6Z699XZOQIBGUjJ1v7y5qxDco9ay2r35VK4WPstGa1o23to >									
//	        < u =="0.000000000000000001" ; [ 000057674033480.000000000000000000 ; 000057682750777.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000157C39754157D0E485 >									
//	    < PI_YU_ROMA ; Line_5814 ; gjZgDo0CZURE95JW4Qtjl5go2V0i0991W9n1zB2H8u1H2W07i ; 20171122 ; subDT >									
//	        < XAo0e0V6qMUn92Rk8lNn29HXmcfym2A4B7r0ae58PC32nCRRhgh043PTx2LlI33X >									
//	        < 7DWh2X768ewdB8npHRZvHZS95II67PYl8hUdyj6KpkvP4EiH7OHTEm8Oj7kVG8An >									
//	        < u =="0.000000000000000001" ; [ 000057682750777.000000000000000000 ; 000057692679892.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000157D0E485157E00B15 >									
//	    < PI_YU_ROMA ; Line_5815 ; lzk5J2wwatwo9k1K1QLVvtHmqTyV27360cD2J18OiF9Q725t2 ; 20171122 ; subDT >									
//	        < ZYXvez10Wg46bTl6n5J0smnObNdbifPD995A7C4Owh2ze76qKB0510QZs2gqn1Z7 >									
//	        < BCvkt5B4ela53Qc0YexMxQ5GfrrG11uX4qsM17HgNZcud50KBzd9F9S5rvOh4KY3 >									
//	        < u =="0.000000000000000001" ; [ 000057692679892.000000000000000000 ; 000057701628980.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000157E00B15157EDB2D2 >									
//	    < PI_YU_ROMA ; Line_5816 ; Tf6726B00blqBjaQZxhvNnYvDHKZPU7SXr9vMq6bEd4F8138c ; 20171122 ; subDT >									
//	        < d3hwwl11W4S334i519Q4bLV6KfNlVWyrV9w24v9mEPr8S2Uir84J7Iq5acD9r588 >									
//	        < KnZpyAJDgIB46XmY28Jh9p5iaYfQ2yPXiQHP46TgMM4fPxu45AKi51r5q7504H80 >									
//	        < u =="0.000000000000000001" ; [ 000057701628980.000000000000000000 ; 000057711357838.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000157EDB2D2157FC8B27 >									
//	    < PI_YU_ROMA ; Line_5817 ; 5wB2aZm32XXkar4SHRe4N4VxqR6q934h9ZO86fVPH9OI3447u ; 20171122 ; subDT >									
//	        < BL65E19AvIwy4OZYn99ynko00fL8ZhKhYnD285pKMN5ma2vCqIeZ6eBY10A45vUQ >									
//	        < 51dh9YO7YKy0E0AteujQZ6M1v3keV186d6dXMgKP2Qq5Xay7PAp79os8PL3C5ckU >									
//	        < u =="0.000000000000000001" ; [ 000057711357838.000000000000000000 ; 000057716517169.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000157FC8B27158046A84 >									
//	    < PI_YU_ROMA ; Line_5818 ; wqLRrSHp0yqN5hE7vHeK3Xi745T1Kc0hhhQ0s0Z8GFYwc2677 ; 20171122 ; subDT >									
//	        < vwh5X1r9ioCy3S1rj9k558b3960jbSjkN9QlyrsAMqVRYwoafYV01N95Gw08zRwR >									
//	        < 170Bh79N7CMSquIQ12H1BkIxXSuXNO8LbejTIDJxm55iTLnc288RpEoF1EX5FkMt >									
//	        < u =="0.000000000000000001" ; [ 000057716517169.000000000000000000 ; 000057730762091.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000158046A841581A26F1 >									
//	    < PI_YU_ROMA ; Line_5819 ; EeH0ThdzogLBJRXPs07S3B1912rGImtU4jo27G9sWpU3ltfFm ; 20171122 ; subDT >									
//	        < 8YCnVpi4bU36t74r08k79V73DHCxSt5jB7AI3JCOd1ZF65AYJBt1DrS1WkaPWsPc >									
//	        < j7u3HDXWAff0Gbv0jqlbOent4Hyi1q7YEJa3LsGVmY0trV0X1d2rjECNaF90Iylw >									
//	        < u =="0.000000000000000001" ; [ 000057730762091.000000000000000000 ; 000057738263600.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001581A26F1158259938 >									
//	    < PI_YU_ROMA ; Line_5820 ; wFeyPeEn6g3B2sk8eT799D5rve3HZ4UG2GPnHGX4OdYIQttd5 ; 20171122 ; subDT >									
//	        < q7rF5ieLjk9S9237mTnlf36FG9lSXZVC3Em6v81LSZ4FC3yd521t1GF9Oo7B1b10 >									
//	        < 9B926i9E1lxzDv8jjAHs2187KFEV5FZ6wr5KyYUevRq0M9i9XQ6vIL4chQHZZvZ1 >									
//	        < u =="0.000000000000000001" ; [ 000057738263600.000000000000000000 ; 000057750622992.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015825993815838751B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5821 à 5830									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5821 ; 20N9VBFnUgkQ6h0VNBA0Zb51KG0hR7Y0390A0Wnh6u9z5uIXX ; 20171122 ; subDT >									
//	        < 63j157J6K3GuiH0K0s1dxB8Ox4M8qXO4SVTGpO5G6YHEcJtS9RZ2p6UZwfBP886e >									
//	        < FszN5kBO57vnZ9nsjd5BEO30ud5w86z5M67F6z2l7015JH2rBi9eOo8464M0i5N8 >									
//	        < u =="0.000000000000000001" ; [ 000057750622992.000000000000000000 ; 000057760783437.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015838751B15847F607 >									
//	    < PI_YU_ROMA ; Line_5822 ; Qpy1mEW2y8n76hK111HBO01oSAIp6ILG0HjnbaE6sBT0aLT3a ; 20171122 ; subDT >									
//	        < 83e5p4Z86ohMN06zJKdOZ28xb46kmP40L7c34Sf36EzyH65TvOjh0gL04kC5d38W >									
//	        < 3gyhvFfG9LR0J2QSxhRb5nS997C5hVCU1j3k0b82853uH0Ra4mIZ9Qh6TT1B3F0G >									
//	        < u =="0.000000000000000001" ; [ 000057760783437.000000000000000000 ; 000057773605735.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015847F6071585B86BD >									
//	    < PI_YU_ROMA ; Line_5823 ; Ag0b502zvU2R243iv2u837f5oHj37vOKlkjnxP63UHWA0LO71 ; 20171122 ; subDT >									
//	        < L29s70X62rObO5T6nDQn9qF0SrKFoiGspHc45t1amwX2b18o08W5AIgO5hxrQEoy >									
//	        < 73R2pCOwNHx02jtv7HN3ny4QeDTiDi2OX9ld5tC6b0F4rRo79OwO6SDCN17N8RdU >									
//	        < u =="0.000000000000000001" ; [ 000057773605735.000000000000000000 ; 000057788019619.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001585B86BD158718529 >									
//	    < PI_YU_ROMA ; Line_5824 ; 78eEr5fMK6fpg9x4vQ1rC951qaCx39765zV8Wp0g2P7K547lL ; 20171122 ; subDT >									
//	        < q1Wlt874LO05kn46ExDonBCD59FimrtyQZFtAK3i9z8nl8n2Hu58o08j7n9uM718 >									
//	        < D3RdJ1Jz4v0y6uKtc3sFgQrYg1EqXgohMoVef46I83kPrwPC6WKU7r5Nc0v9v2B4 >									
//	        < u =="0.000000000000000001" ; [ 000057788019619.000000000000000000 ; 000057802767525.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000158718529158880610 >									
//	    < PI_YU_ROMA ; Line_5825 ; yqZ4vu9v57ou6Xw9h7wwo4nF645c37K5ATfls97QwIHIg9DW9 ; 20171122 ; subDT >									
//	        < NE6saa0i3Vunt5g50qa5ij360qV3c3f922Ro110BUA5f0XYV4vj3l6v6M4MN8a3f >									
//	        < a9hQl4K401MndZ4GXtYBd9378R1Yzaszj47LrN679QO4781uMmXhO5XxIjCt2pb8 >									
//	        < u =="0.000000000000000001" ; [ 000057802767525.000000000000000000 ; 000057814810814.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001588806101589A6679 >									
//	    < PI_YU_ROMA ; Line_5826 ; r9LK5kmP9HJ12B7RW4H2O2b48rk9e0W5Mi5UoGauloZgsapD8 ; 20171122 ; subDT >									
//	        < 8x0730y267O73hH5wxy4Qz21Dzny45818y8RJOF6D62B90HdRQzD5sq2SrgzIXza >									
//	        < Go5acf6729J8O6jOeAdmA7gl0dTh0zux8u7VuLrWVZNq2qvfs8j304C3MQ2D0MmH >									
//	        < u =="0.000000000000000001" ; [ 000057814810814.000000000000000000 ; 000057824852668.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001589A6679158A9B912 >									
//	    < PI_YU_ROMA ; Line_5827 ; 49CN3jU849a11s3n96DJFJ7wMcms3RtJ8Ho58Vircr4mYan14 ; 20171122 ; subDT >									
//	        < VN0458wT3b9B7k8y3O68bedn3dA6kB7n2Q8LitTrvvD68Y0fUg9Qb88Lv9Cmx5sH >									
//	        < 3TcUBmhQ7x245932yyku5h15uWgnAB5a9s6XEyx3TcN2Y9txzd4Ho2McB86M5XVn >									
//	        < u =="0.000000000000000001" ; [ 000057824852668.000000000000000000 ; 000057839280793.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000158A9B912158BFBD0F >									
//	    < PI_YU_ROMA ; Line_5828 ; aoz62UmJ6I4RQXEhfwfdon5MI2ho8VZwR33JoFXF4f79i43MP ; 20171122 ; subDT >									
//	        < 8s3OuZ299DBx5cgmfWCXiQZDGiDN3poQT4GR6Li75fY8Z00zW7iBAvxURzo5JfR3 >									
//	        < Xg71K6G34MJxxikk1z7hOs5ZeN0WoTq4gNA4Kwr35YW01WU4rlbCKKwh1bnaXhFR >									
//	        < u =="0.000000000000000001" ; [ 000057839280793.000000000000000000 ; 000057853524060.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000158BFBD0F158D578D6 >									
//	    < PI_YU_ROMA ; Line_5829 ; VyA0wlS9nX3A9zuGFUz14gCeUmQfpVYBkLV2fGWC80Ajp69C7 ; 20171122 ; subDT >									
//	        < d2iEH219x1B4n97GIAe33Np2g9I1sq4q73163QF2977VPeBXvMeUPWL8UgFMUadg >									
//	        < Fp06jHUu8y6DF2bL64LWPyYvl5N89Nuixc4bXCOfXs96tTVlTW3O7xi1NqM22Qrr >									
//	        < u =="0.000000000000000001" ; [ 000057853524060.000000000000000000 ; 000057862230019.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000158D578D6158E2C199 >									
//	    < PI_YU_ROMA ; Line_5830 ; zh6Eszp38GN021d5NiHMwUQaAIVL2FPxyHN1PzTiI76FuWmv4 ; 20171122 ; subDT >									
//	        < orfNsSH7zo2nlcanFl8d1J8g32a6mJwQ1WxKQ2u01Qz27l3CMfUdS78fb20gt2Vd >									
//	        < 7iKSilUiXdn91j1racUjwNnbC6QBMpZ67xzH4519j90V01IPNG9rFbg16KPD6eI5 >									
//	        < u =="0.000000000000000001" ; [ 000057862230019.000000000000000000 ; 000057867262576.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000158E2C199158EA6F71 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5831 à 5840									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5831 ; rGpCDmCRPC7CQ63yzk90jaBX0kyN6zyX0L76M8YG89Crf5kNz ; 20171122 ; subDT >									
//	        < 0vIQ80mS0LKGtxdGQKeL76d8yfGN9hbF40xUVOR64BcO9o68ZkEpXg168e4DmpRi >									
//	        < 5ehUk811Z6365bAkz5i1Wov3Z1mc9G891q7o0gltcIi08DWK84BBQ6Mt25K71Zv5 >									
//	        < u =="0.000000000000000001" ; [ 000057867262576.000000000000000000 ; 000057873283347.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000158EA6F71158F39F4E >									
//	    < PI_YU_ROMA ; Line_5832 ; 6cr1EpDJK3h0j4G9wjnaQdyfaDW52Fv9lWdTj62CnGCFLdXGh ; 20171122 ; subDT >									
//	        < GW18VI7okA82On0sLJE0e7o6DQ2fsv5GdvQMIgHlnxNppaa7x8E1IkrI3EeEyo6Q >									
//	        < 3lwCaZ5aP66dsGPcB3y9CFs8wpmm2p084xUqw4c6rxd6T7wUl9055j16YB7y8fzd >									
//	        < u =="0.000000000000000001" ; [ 000057873283347.000000000000000000 ; 000057882145062.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000158F39F4E1590124EA >									
//	    < PI_YU_ROMA ; Line_5833 ; 9lRme14dNLfgKRIGwgIO0E15t4iU2kmphkb1TBheC5u7Nd9y6 ; 20171122 ; subDT >									
//	        < Ll8q955TMn99ZbNl525YXZ0oR00TV5WlZ4n2492GTpS1j8kz0KwaN81Bm4ZPXH34 >									
//	        < 91RU33B0J1JF4ZHzvlx53AO951qMBMaz1B85qL16K7w7vcNEG0fr96X3Mc927eJm >									
//	        < u =="0.000000000000000001" ; [ 000057882145062.000000000000000000 ; 000057890480956.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001590124EA1590DDD1F >									
//	    < PI_YU_ROMA ; Line_5834 ; 7pF220iUYR9q1b56PW5HIMwSFH1W8s1T2Cf93oeucKE62tFXo ; 20171122 ; subDT >									
//	        < gOv0Za37KY4hrwl0V07f7pT47LOUW8HPjve3RW41pjT84z4pLehzax014EDm29r0 >									
//	        < F9FAh4luibEiQJ3j9Db1b9iOcdIVxI0f1PN9jCo1zQWqCKJpD72V78t34PncWj8s >									
//	        < u =="0.000000000000000001" ; [ 000057890480956.000000000000000000 ; 000057904943943.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001590DDD1F15923EEBA >									
//	    < PI_YU_ROMA ; Line_5835 ; f3R1UlKF5L3nZhkkwE70c6fcbKd9syS6JIqxX0C3YsicwA6RH ; 20171122 ; subDT >									
//	        < 0J75ib1DPyAGnzzvRr7fd28t6oRN4AASgyYH0c938FAGGLMYqY6VrcH5fv0Ud42D >									
//	        < CSMPJnD004WIS9F3z761Nm1qzTZpAegx647EY3hNw0SqRnPzV6oG1N0ubrB5P00s >									
//	        < u =="0.000000000000000001" ; [ 000057904943943.000000000000000000 ; 000057916986045.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015923EEBA159364EAC >									
//	    < PI_YU_ROMA ; Line_5836 ; ePDW43yIPvd58LvQnp8aV1u0Ph9ffNu2jV8EMiHQ3d02jDjhI ; 20171122 ; subDT >									
//	        < VDQC1H0w7E8tXlRC97V98u0OL4Bw5Tp7h3zzc2v14Nmb0OO51eoO0Je52F2v1NQR >									
//	        < dMJMC8rl7Qt5gLJz6sgI4b1N9I2WOO7nsM4Gxte3dc84SRu7uw6E5NRfsPc8X2ST >									
//	        < u =="0.000000000000000001" ; [ 000057916986045.000000000000000000 ; 000057931217943.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000159364EAC1594C0602 >									
//	    < PI_YU_ROMA ; Line_5837 ; XV0LIL43xM8B1T34fS7GcNU1r1rWeT20X4zbnE2mQ9ef74cr6 ; 20171122 ; subDT >									
//	        < ZJYLa0eZ1Z4FEV6WM425JU3Qw779BsG9qh3KR55nitJ01tbwuMDs1OL2G2khy49b >									
//	        < EtK6A0lw55s98PpsmBgKf67qiOc6MWJr4uQdZ50Ba2iy2Dx51qJw83FJg777b9rt >									
//	        < u =="0.000000000000000001" ; [ 000057931217943.000000000000000000 ; 000057937662263.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001594C060215955DB52 >									
//	    < PI_YU_ROMA ; Line_5838 ; 5x5Mf04oMqI3o82kKP3EzLAlS6Mh78an8VZ5b03IMR2ydTopW ; 20171122 ; subDT >									
//	        < Bvm0rq04p0nX76Hb0DkFw5MBve3v5giWnMEQ0gvaZ3m38SQ5KhGy2cW0lepilq1s >									
//	        < fXgfr66m39aNd397s2hmy26vorsg87QRC9ucDjAfVU11xo4ryX40S0SYVA0zsx7s >									
//	        < u =="0.000000000000000001" ; [ 000057937662263.000000000000000000 ; 000057947515194.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015955DB5215964E41F >									
//	    < PI_YU_ROMA ; Line_5839 ; vDCo19ZKN5PgiS3ZECNR2G9eQ7kUGGGiqBytGqQveq9Fk7515 ; 20171122 ; subDT >									
//	        < 3bV9npM5PpOhex7MVlkl8aw0vzW6Kczyr256q7uT9K4euHbjz2Gk3vKayCE0t59h >									
//	        < 2tegv1J7Fy7I3C1TS6nw4t98bzKG0878850J3n2Bij3f996ba6GKJB7rw36d1uBK >									
//	        < u =="0.000000000000000001" ; [ 000057947515194.000000000000000000 ; 000057953166629.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015964E41F1596D83B6 >									
//	    < PI_YU_ROMA ; Line_5840 ; jF085Z40WzFXF82kACiel5j3f1wLmv4P5K5M88ZTN79Uxl1dD ; 20171122 ; subDT >									
//	        < DpyEo3VoudB4560FDHefk6p45T3JWZ7qwYWLU45S2MVr9k50k59q39724BIX2dY1 >									
//	        < shrCr2aic29BK4EzAerp0BkAFEOAM2i09UtBfB3lHXj90I9N0n0Tu5TKh91SCGON >									
//	        < u =="0.000000000000000001" ; [ 000057953166629.000000000000000000 ; 000057958177961.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001596D83B6159752944 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5841 à 5850									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5841 ; M0m4DDg8WaJDk2ZUJFpn7KS8i9MYd1G761mjgjq2x8xdURumN ; 20171122 ; subDT >									
//	        < PuvnFbCffJp8H6zXnKrj9IPa4BEim5BE0tVRUf99L1iSFMi5xPJdBK5T7170sgbg >									
//	        < 3jy6dPFIMpyYLTHRlOY2S3Q2n3lEkorDEaH6JbVyVkZmmxz22hazBjIsQ43oZ2V5 >									
//	        < u =="0.000000000000000001" ; [ 000057958177961.000000000000000000 ; 000057967954029.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015975294415984140A >									
//	    < PI_YU_ROMA ; Line_5842 ; 5g2jAme3Z8VnjdQ937CjYfqZg7BDrZp99D9225ZG6q9P6q264 ; 20171122 ; subDT >									
//	        < hu6017Z240n8rwqz06I038CRfm8h3Yc4QA40MgIuGvuQobAtWtL2Fj24N7aytutc >									
//	        < IgdZ15O19Om0hQBdMe05fQ9yB17NLalCrj0iMymHQ10889712C32FehA64LiB79N >									
//	        < u =="0.000000000000000001" ; [ 000057967954029.000000000000000000 ; 000057976783990.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015984140A159918D3F >									
//	    < PI_YU_ROMA ; Line_5843 ; 8w75j9i0SMX5s207khl5H4jKA96bUV050femERzTq2ezbofZK ; 20171122 ; subDT >									
//	        < 3LF3V7HiIo5X4m5p9N5oPso8U72G0nmMrysMwPtCA9riAkT131T7b65gugJF2U43 >									
//	        < MQ56rMGdE6lkLmnpOWv4I3RmDpiB1kjUv53Xp9UUYc3hLpr0wnGg24oYNGpv4y1s >									
//	        < u =="0.000000000000000001" ; [ 000057976783990.000000000000000000 ; 000057987598002.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000159918D3F159A20D78 >									
//	    < PI_YU_ROMA ; Line_5844 ; 19zABwRS54I7t4CP3Q642ay14B3TcU6836klg7OBhXhOB7Lke ; 20171122 ; subDT >									
//	        < AqMC6nOQd59aEFQ7Ll8hS0P0ZUeN75UnxnfW9z3sE3K28501k1lQRlmNknXlow5b >									
//	        < EDOq49BiT8EWct7013H2x96Za577YGNFFEAnHN13yP3zU3gI0r182bt659v3IRWj >									
//	        < u =="0.000000000000000001" ; [ 000057987598002.000000000000000000 ; 000057995343772.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000159A20D78159ADDF29 >									
//	    < PI_YU_ROMA ; Line_5845 ; 3h8B6B2wWL4o04bYdnq943bgUO7R0M3T94wV6P067UoSnGAbk ; 20171122 ; subDT >									
//	        < tcPK7jgEZS58i49X34DQQsBi7KsLOkPU5PF358rLATA586vlf86650IpdnYz67sD >									
//	        < rywXXxO52hoTin03k4XGMvTpA429sfB2Bg6Ro9931G7tpkfzo4fwO0xFNHHs53jr >									
//	        < u =="0.000000000000000001" ; [ 000057995343772.000000000000000000 ; 000058002723784.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000159ADDF29159B921FA >									
//	    < PI_YU_ROMA ; Line_5846 ; 1ZTvGdCnM6A32CKwIjA9Z5X2JtkwpEfn3CZ0TFu4f7FJM3to5 ; 20171122 ; subDT >									
//	        < 24Rs6LWBvn76Ixy0V1N7rgymQyF7ACRT605ebEvsGtkQt2k2w21StMlZEk1i37r1 >									
//	        < v3wGTJyBDW61H5jPs038xo5lMRVIE9TYks1mSXux9HhE86HN2uhag5SNT5VIEp9J >									
//	        < u =="0.000000000000000001" ; [ 000058002723784.000000000000000000 ; 000058009769071.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000159B921FA159C3E20B >									
//	    < PI_YU_ROMA ; Line_5847 ; Gxv575xouEYv51ovQ7mvH6g8gYpVhb9o3J58O6u26NU0vWy0c ; 20171122 ; subDT >									
//	        < KH5ff2ybkpFg5T0U14gz0hQ03zAB8RdHs5NW0eetB7gQA4IRdtGAQ5dp6P7wD7KJ >									
//	        < SEJQBscv7mrDaQ3cuh855kFQGgWBQYT4cjwwhg6n37bU581lyL38YbOsNEv8A5B1 >									
//	        < u =="0.000000000000000001" ; [ 000058009769071.000000000000000000 ; 000058015530440.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000159C3E20B159CCAC94 >									
//	    < PI_YU_ROMA ; Line_5848 ; nxn3PIVaxolWe13J8vtE7LCGa6Y0qmdyVISO0w1Bk25aWHwwe ; 20171122 ; subDT >									
//	        < MSS66ZH3lfqsNq13fGG4CaqsjGG94r2B39u56MZ0FERj2iM3RJE7cnRI964m7Oai >									
//	        < 3K5q4G3tcZL3h3z0146H6Z15zh06751fqP7xiu2TkdQpGW8L4msYLNwcCa8P8WF5 >									
//	        < u =="0.000000000000000001" ; [ 000058015530440.000000000000000000 ; 000058025052540.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000159CCAC94159DB3426 >									
//	    < PI_YU_ROMA ; Line_5849 ; IiUYgMPqD2wN0H6Mm940TvjFlieYcsu4JuLFTs104Zqv3h31t ; 20171122 ; subDT >									
//	        < CdSpuqJnu245I5nfQ0oN0L0tmiUeqLWbhiAso48F6HEWQ8Yr96k2MCT8SuOCxB33 >									
//	        < Y98Z44jDDSiUC749FP4L721LR3Z69kjs60ixfH0PH84h4VAg272qnauuds2w4z12 >									
//	        < u =="0.000000000000000001" ; [ 000058025052540.000000000000000000 ; 000058030141498.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000159DB3426159E2F805 >									
//	    < PI_YU_ROMA ; Line_5850 ; VO4V94jvFk4nEbb53c4a0Vmfak54hCMKPZ1kjZ6i7j1aV347y ; 20171122 ; subDT >									
//	        < 6rr3ONwuj6jK6Fdfz50mEnfHr8SpdN1eWw4k0fltPE9k4MCA6P1z0f5O9rs350vk >									
//	        < mf2218WTTw1G20RDGKt3P4rubd1ifz9AK6GQ3ju3t131ZDz5R6w2U9Vg92IVZjbX >									
//	        < u =="0.000000000000000001" ; [ 000058030141498.000000000000000000 ; 000058043464152.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000159E2F805159F74C2F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5851 à 5860									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5851 ; 7z5CfB3Z5tO6TD350w7m3dioAI4sB2Gh35mM38XTywdTadYu8 ; 20171122 ; subDT >									
//	        < 2f2GFCDl65eU9Bx14vXaHfF54msh272N9qXEuCR7694h5l3J2431r1WRksz90CZU >									
//	        < qT7H3RvrmzzwgM2l0z36d5i3wDFAxe84xS5pJNEzmn5sA5jrzAD4JXeP09j9uB64 >									
//	        < u =="0.000000000000000001" ; [ 000058043464152.000000000000000000 ; 000058057492561.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000159F74C2F15A0CB408 >									
//	    < PI_YU_ROMA ; Line_5852 ; IAk044QGoV8OfdB638yd4VhH8ybJjk2p9w1ho9u1AOgqx2AXk ; 20171122 ; subDT >									
//	        < BKv8mC5gt9kecwPjVRjj3sTRckI640L5O78M73S43364tekaubQ56BHmoWY4Ap2o >									
//	        < NgShR5p45X92062j1Ppe13d362S6Q25iawYTaVA4zR754YqR43Kx2W235c255Nh3 >									
//	        < u =="0.000000000000000001" ; [ 000058057492561.000000000000000000 ; 000058067488599.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015A0CB40815A1BF4BB >									
//	    < PI_YU_ROMA ; Line_5853 ; 4hJ027zltNWZY2h7O8RmwK408na2mBr2B4Pq54V7l6Cl9v4TU ; 20171122 ; subDT >									
//	        < uok2c2IbgovXX25q87dlU15WMnTEg3M1rg8iqcb9DvOcZE4qRr0Crf6SUoyFa1zW >									
//	        < T0C4M0B7XkgOz95Cee7zQF8Q77UIOwP5dVtQ4a35211qd9d7Ots1H7mYh8uqPZJH >									
//	        < u =="0.000000000000000001" ; [ 000058067488599.000000000000000000 ; 000058079187679.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015A1BF4BB15A2DCEAF >									
//	    < PI_YU_ROMA ; Line_5854 ; 2Fl5e86pS73Y48800HpvHRxmSELjX0bC9o3xK2li50M8e8wJg ; 20171122 ; subDT >									
//	        < h838S3r9m8nA7aHG897gsaTS60H2T0muuE7u9LReId90EUC2Sp28RltT12pI8XBA >									
//	        < KG9h8fA9RA18ACV14L3y1CtSgWq6k2RXE668KenFIR4a1QjT8PWQRws9R8bD4D2Q >									
//	        < u =="0.000000000000000001" ; [ 000058079187679.000000000000000000 ; 000058092246735.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015A2DCEAF15A41BBE1 >									
//	    < PI_YU_ROMA ; Line_5855 ; M1zHo4262ahU17sGft6e8g0zk6X0DlyvZXiD6vGo5Lrpf79LE ; 20171122 ; subDT >									
//	        < G048P60SpYS9ygQbJTJCHU256jP31FSL4cGOWC7n0EIEa9jzFM67DB98Tgs5Tk74 >									
//	        < wJouM6O7g9WmZdGTFbjC7f0F44J0Y8iXb89JHnh7y2Ifz15Q07zjQ64ZcHTgHbXU >									
//	        < u =="0.000000000000000001" ; [ 000058092246735.000000000000000000 ; 000058106209834.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015A41BBE115A570A37 >									
//	    < PI_YU_ROMA ; Line_5856 ; t22b6k11iq5X1St249HQX69Mch19N9tHNvX3ca0yBb8ox81jH ; 20171122 ; subDT >									
//	        < I2YC8K8QGnnbqmwdI47894KTbk5M5J0C5ruPax96SHd1Hp4hUaP8G1y1nQe1PL64 >									
//	        < SPZz01o59046kb5fY61pPa8H9pKJeYPww5F8f289Pnz3a2pvuypbpC9Xrab0z5U4 >									
//	        < u =="0.000000000000000001" ; [ 000058106209834.000000000000000000 ; 000058120947629.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015A570A3715A6D872A >									
//	    < PI_YU_ROMA ; Line_5857 ; 6D504YW1p3RUxWZ7FZCQX6W0PQL1G2k48h985B45D7404yLNW ; 20171122 ; subDT >									
//	        < 05asXfB7qvwdpP43M81mia3sF5m7rdBWb24q1TZoPDHMELYEAbz0O7UxHc0049QX >									
//	        < 2Y39K37fz4DOdtkckT265Mu8d0FIL5RdP1a935krV76bhAZ1mD76KG245Oi89S28 >									
//	        < u =="0.000000000000000001" ; [ 000058120947629.000000000000000000 ; 000058135690505.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015A6D872A15A84061A >									
//	    < PI_YU_ROMA ; Line_5858 ; m51ARYE5dXMpjob5BsbC0hgHZ0ix0xhestUy9fXbE80fLwOU0 ; 20171122 ; subDT >									
//	        < Lo3m7PT8F0JOc0rB3ZydycX3c852621K61rhkl1nCeBypJt4eEXkb4VKW55EU67V >									
//	        < 4juH9c823Ryx7e7v1MtO7dBq12191aOGr0aSDwCV31bwIu5FLwOjP608kKwtn0mU >									
//	        < u =="0.000000000000000001" ; [ 000058135690505.000000000000000000 ; 000058143759817.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015A84061A15A90562D >									
//	    < PI_YU_ROMA ; Line_5859 ; T7HX1zLHyJIy1KFgwFttvsaXZ5nkur1LlVDV3F9VJ8iSMGm2I ; 20171122 ; subDT >									
//	        < HNM3J2hS8AjL9Jl147khmUfXXPKh798dsM324Mwp2e7sW0rNlSMH4UXH7pLpUY8X >									
//	        < 59xtavAOUYz8Fl7j29twBQsQ11ZGtgSdKK4s4poTUjT802035Pvu5E7w144CY987 >									
//	        < u =="0.000000000000000001" ; [ 000058143759817.000000000000000000 ; 000058150549625.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015A90562D15A9AB272 >									
//	    < PI_YU_ROMA ; Line_5860 ; 42k8N235CBq38sX9T4T9GRR5k62harPL2n6w3OvsO4wlDEhLe ; 20171122 ; subDT >									
//	        < BNA802rd1Ur6YM843pMjC928i219SRf1eo3VC5HOhDltIsHq6w6bZoqd39nh4w6A >									
//	        < DnujU6S2o5a67Hjs0BQW97hFcYix78sSI2Uh4XB4MvJwYlW5UitQkFB7sPR83fP1 >									
//	        < u =="0.000000000000000001" ; [ 000058150549625.000000000000000000 ; 000058156333203.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015A9AB27215AA385A8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5861 à 5870									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5861 ; MiapMhv7eWhHLHvQ97K8P0WwfHiBdvQcC6O357an55o60r2gc ; 20171122 ; subDT >									
//	        < w45D85IUTyBg1Y0wy4LHp55gteiX995vFvzwvO83eE0k3IFzC001lM5x32N6UFeg >									
//	        < Qqvy08eN512F4BhQeceZ2FZyVH5onLVS0EQ4iW8axs1H5FGr3J2W56P2v50d75AU >									
//	        < u =="0.000000000000000001" ; [ 000058156333203.000000000000000000 ; 000058164512887.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015AA385A815AB000D8 >									
//	    < PI_YU_ROMA ; Line_5862 ; MB71okD0IlU7KIr8sT23ctDfq2t977mudWWrTI4Ym5d4Ni4k6 ; 20171122 ; subDT >									
//	        < H11oeV3I5M1x02jvzaU8t04C36v9j7B7vJI3svWJ844Ck2Q5dqosRjAPYwyi98P8 >									
//	        < dK7lGo3j9VGdiyv5v6X8StHU3Fkp4mqgdL9RPho1CgTO994s0A4Ww3zAjek4cJq7 >									
//	        < u =="0.000000000000000001" ; [ 000058164512887.000000000000000000 ; 000058174107436.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015AB000D815ABEA4B7 >									
//	    < PI_YU_ROMA ; Line_5863 ; SMsTN5ZfL8nN5iDZCS4f986H8MfDqS09UMZA9CVOR7rqoT46N ; 20171122 ; subDT >									
//	        < G3U4X1Q64s614mq67XuV2AysLlz7RB95ZkZnVDdIlo7M985H9vf8Z1d65Ul5mqHw >									
//	        < 067HWGmvD4F5J7yx181nEKgSabrrz0a0ko8O6V45BxBc2F0G0Z0D95w6NY9KL151 >									
//	        < u =="0.000000000000000001" ; [ 000058174107436.000000000000000000 ; 000058188259803.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015ABEA4B715AD43CFC >									
//	    < PI_YU_ROMA ; Line_5864 ; 0qFRAQJTQwL10y8U64wVpc050UJf5Jc6b5rONto2BhhcLwL7Y ; 20171122 ; subDT >									
//	        < l7g86451hSqO673sy0kayoNzDXU98P1GuR00F7d4U4tC2VaNyz5sHo0xH4109zAj >									
//	        < r7sr5477m1a6F7Xr3Iv05gL6V548292NMMlR62GQDu4c7082j1Px7N8p0RV7T819 >									
//	        < u =="0.000000000000000001" ; [ 000058188259803.000000000000000000 ; 000058200275399.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015AD43CFC15AE69293 >									
//	    < PI_YU_ROMA ; Line_5865 ; 84i8TgyW89uvRfdP86NL67ZI6tlCPd9hDVc6N23n9OSVfX6tZ ; 20171122 ; subDT >									
//	        < 00rm4suLp0RuNZky8sVl3qbvoU0mA2PY5h6iYUwSn3HsNa0UZ3S642zpE07yt80E >									
//	        < RZruB588F8atYnejT0u765N1C656iIyyb6Ke8EVoR2pez2LAiYX5RNs3a6qkbRiX >									
//	        < u =="0.000000000000000001" ; [ 000058200275399.000000000000000000 ; 000058211687287.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015AE6929315AF7FC58 >									
//	    < PI_YU_ROMA ; Line_5866 ; 9dxoXEAwr4n697ZedccYuzNXmvoXD8712gdiJYPXeTl68jk02 ; 20171122 ; subDT >									
//	        < Hq5S04fxf8YYLx2ouYLfW3ML91nI5qXx0GhJ70khO4olYBJ9850gGBYPLARk0x2z >									
//	        < b0iSuGqp3XVNY49N9uY30Vn0WWl4ucRHSrC9poZj34sf8813EMI2L7qcIENgN4Ix >									
//	        < u =="0.000000000000000001" ; [ 000058211687287.000000000000000000 ; 000058224267299.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015AF7FC5815B0B2E69 >									
//	    < PI_YU_ROMA ; Line_5867 ; YY02h33PP96eVrBJ7j0R4He00491rF43ue3ZcqwSmNZ8X66Ev ; 20171122 ; subDT >									
//	        < 26pu81QDN0jPqg3YKLdiyZOojunvrqSoG4gi2113YPjU00gAu1u8MXTgb06tA5gH >									
//	        < m10D9buSYT47Z0ir748Bu7BMg8SW04qHIB2K6ozMh10230odZeU9K9d61znpww0f >									
//	        < u =="0.000000000000000001" ; [ 000058224267299.000000000000000000 ; 000058231795053.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015B0B2E6915B16AAF1 >									
//	    < PI_YU_ROMA ; Line_5868 ; SQN8p0c3B84kio5htI1wU9N16d1Wt9FIcMU9RBrx8Qh7poWwY ; 20171122 ; subDT >									
//	        < HZ1R8L9aqOA6UNbjzx2u3uFHrcDYXjUwzxYg4qdAnfA5xV64076J68zrBb4Q1d95 >									
//	        < 9NrQz7qRIR2RF526nVz6kZD0IX5oFnor45D1b18LIFz0lgDnJH6V20nKy1tLPH61 >									
//	        < u =="0.000000000000000001" ; [ 000058231795053.000000000000000000 ; 000058243855909.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015B16AAF115B291236 >									
//	    < PI_YU_ROMA ; Line_5869 ; 8Crq1kF837Ci61Tq9fUs8PffH42xqb776f1g7P09bl458M53C ; 20171122 ; subDT >									
//	        < A66tDXq6q35joT5XtrQptW6V5ocNU2pcffiOieOp1i92B489mU0tLBywX45kr41m >									
//	        < D7u9Ja7oTUrQ8DPy6D1cSgvk1P4lEweN05jPn7Z1mSD54J218Gda8R96S860pw1t >									
//	        < u =="0.000000000000000001" ; [ 000058243855909.000000000000000000 ; 000058254912933.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015B29123615B39F15D >									
//	    < PI_YU_ROMA ; Line_5870 ; jjL3jaBvwaV2M9BRG88nt48pUF5R9AW730NP8l8Nqz6u2fVeD ; 20171122 ; subDT >									
//	        < 91YC9Iwbkzy0GQyiyC7vy5wg6a8r6z6ErudAaVMq3azZp4Rjz0N4200lYAR457UA >									
//	        < i6rG9bsSXE2LP1Od9c3cQ73565Rpdv9GZuIthS8Ipn2D5982Jp0gWRZqyfmax6hW >									
//	        < u =="0.000000000000000001" ; [ 000058254912933.000000000000000000 ; 000058269593211.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015B39F15D15B5057D9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5871 à 5880									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5871 ; 5Z76mJRrMUopfUdGnTztf2U501srm0hj1XjpQvKo8Y3hRI2z3 ; 20171122 ; subDT >									
//	        < 2VwnlM86gD4akgl52Q1T1e166947sD2A16kYGAZWb2Q5GdfkMF3jbBo48bOs6z38 >									
//	        < 6Vorg15ZY9oedHyelokjGQ27f9Os568s0v09I3s4xR9e3VVz1BXS2EnO5G18ZjsU >									
//	        < u =="0.000000000000000001" ; [ 000058269593211.000000000000000000 ; 000058282600719.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015B5057D915B6430E7 >									
//	    < PI_YU_ROMA ; Line_5872 ; 87RDB6DNk3JZ925t8ioZXf6Z3zvV5dq2HtLGQnocAE548Khyx ; 20171122 ; subDT >									
//	        < 82UVoM9nd8PY408z7DUf0EOc0Y6267H41Sjft1S6zmhMOS0oDu0U0m4b7IuILnFp >									
//	        < uX7msKHV8LskWF0o6pBNSOKuOz1fgA5bR8flX0SC4Bc4Q1upD99H8jaQ5uJK3JEq >									
//	        < u =="0.000000000000000001" ; [ 000058282600719.000000000000000000 ; 000058292419594.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015B6430E715B732C67 >									
//	    < PI_YU_ROMA ; Line_5873 ; zmCkc2l4d0D59ScT709WZIybYk8Xau04EbWynBD5h3sYD7030 ; 20171122 ; subDT >									
//	        < 7tswjp6yl59KRPgboDrV64KIRJk8G1MJg732keNZNQdSz98Wc3X1W0JJRKJwBSOY >									
//	        < 7EcWC95Fh803cn79j18PVj7s9uL4v7kJ4SiRl0hx9D88QscsMunXuyWOBXmlKJZG >									
//	        < u =="0.000000000000000001" ; [ 000058292419594.000000000000000000 ; 000058306914207.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015B732C6715B894A5C >									
//	    < PI_YU_ROMA ; Line_5874 ; FDJpzE19RR8uPsrl0h8UBJ41jwlFOb72uqaZ8gNv5Lcfib9IT ; 20171122 ; subDT >									
//	        < VJ4lpf16Z960gP250i4269eU543fQ12ql09owoVeaG6dU1P038Lq7ICHn2IP2434 >									
//	        < AsCLtkxw72SNyVB04WUCB7i5MYkTN9UXfZKyf42hFG8mLykEr9gtl3w8zuZv3Yjt >									
//	        < u =="0.000000000000000001" ; [ 000058306914207.000000000000000000 ; 000058315171181.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015B894A5C15B95E3BE >									
//	    < PI_YU_ROMA ; Line_5875 ; 9Wcsxm96A6WvnPZm6TfvIz9xwgpzo6hiNKEQ2m28IzS5yEUBr ; 20171122 ; subDT >									
//	        < NNKTXe26tiAwSvN99PbnzrX2482cn1Hk9Ac167zZSt6y8KO4Xcw1z04nG4TUhAz0 >									
//	        < F7Z7c1m6Vxd06YL3u0V6rg7q2OF38z7sPV28JenUOe9dGN4URrhLR258ZJ8z6rHE >									
//	        < u =="0.000000000000000001" ; [ 000058315171181.000000000000000000 ; 000058320705629.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015B95E3BE15B9E55A2 >									
//	    < PI_YU_ROMA ; Line_5876 ; j2HHXXZY2muDRiehfp7ZlR9M6UDApDPXGQLhbpcbdyXEVLEoz ; 20171122 ; subDT >									
//	        < 66aV7370G0A53kzejfewrICy8oeBd5D1BEoavy9Yjvl9r0K4375Y540qB9Ug7zio >									
//	        < Me8mqQ7r495cQ5unU7Nnom3b1hq957bHFs4Ui4UzgQ36gopE8Lm5Np5z09gmCllZ >									
//	        < u =="0.000000000000000001" ; [ 000058320705629.000000000000000000 ; 000058328579548.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015B9E55A215BAA5962 >									
//	    < PI_YU_ROMA ; Line_5877 ; W8oX1KKF85y8W36bEovRpa0JT7ah2y0053RLBliK5X83jQCAd ; 20171122 ; subDT >									
//	        < 7hxjlX6f56S0d4n6N829cfFji963JDPRKgJDhfyLIxg9GGD55TT3ZTN3QDWEqYk5 >									
//	        < 8n2pu9D5AGhE3WLNjm10KpIr83BE52nCLI1eUna8sBY99xbk0YqVnXhOww96AC30 >									
//	        < u =="0.000000000000000001" ; [ 000058328579548.000000000000000000 ; 000058338940129.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015BAA596215BBA287C >									
//	    < PI_YU_ROMA ; Line_5878 ; 6fVWIp9tyI4l95a2c6JiSQ0woU3N9ZDrVx9tQ49xOyK090c8L ; 20171122 ; subDT >									
//	        < 83F9RuMLkxIz98i9x6njXhyF3u28KgwCx9Ga0ZbH4v9K645KTY8P5DD14MYMi9zH >									
//	        < 77Ls1K7c6QcPN9g9FV48Y3GF8Uifdt74SA7X7F0BdSP8MlLJol8QH185XfjL8STD >									
//	        < u =="0.000000000000000001" ; [ 000058338940129.000000000000000000 ; 000058353634021.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015BBA287C15BD0944A >									
//	    < PI_YU_ROMA ; Line_5879 ; aLCL70xt09hjF4HdVWz35SG541oBRwssiH0F4unJ6LzYLD895 ; 20171122 ; subDT >									
//	        < 1LbuRaMhH320qPy108b5jC72LQ5roH6639oIC2Re7IffropjEy12Wj604YQ8LdoM >									
//	        < 00iypIyNP5H4F5tTSjr4tA9pexDoj5Fmkn0G8tm5A5I7rPVBEArJdsAUMAGfXzp6 >									
//	        < u =="0.000000000000000001" ; [ 000058353634021.000000000000000000 ; 000058365351032.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015BD0944A15BE2753F >									
//	    < PI_YU_ROMA ; Line_5880 ; kSEZJ41LF539M6B88a1pMwC0ECHD31d2fEmBGWjp6ngA0vN44 ; 20171122 ; subDT >									
//	        < mYGpV6vqthXh8Pad5dp7sZVn8jbLZ15RE1Bpe72z74n10yD9w3MjBo00tso6YBk7 >									
//	        < 8mRxkqYa7yNkV12dFg91izJCYpL33WJzc3bR4LC5jUt4lpSjR4f530fcJks8h1cn >									
//	        < u =="0.000000000000000001" ; [ 000058365351032.000000000000000000 ; 000058375770274.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015BE2753F15BF25B43 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5881 à 5890									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5881 ; ZaGOXVgsx6bX4uEm2eBNav7JML675qw32RNn7H8Yw3HSs3a5R ; 20171122 ; subDT >									
//	        < q3qs4fvBxc2cR5ZcI2zSO8m49d9M2M5i57TZXn3ZSvoo46J71hdSZcYbzA0H2T97 >									
//	        < 4CVkv0U66nBO89OI3OU2g7T7es8U50OC7s3191xBtDl94R2a7FGbOhGL6grLjDfO >									
//	        < u =="0.000000000000000001" ; [ 000058375770274.000000000000000000 ; 000058386139312.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015BF25B4315C022DAB >									
//	    < PI_YU_ROMA ; Line_5882 ; F1cUXnUfLjcIS8ZIeHP2vuQ1IbHy9pSOOx0TFyF9K0L8B8x7p ; 20171122 ; subDT >									
//	        < Rdos3LGd4RboGJU772Ua84cX19yZ442A9gK39qLNbv6FOYvg6DQb8MN840jrQQi8 >									
//	        < NiifhXx5e5hnmtcc3hS2ypY85DPYD1bBTNgzk1wE7wFbWJL6GFpnCNNx1av36YjV >									
//	        < u =="0.000000000000000001" ; [ 000058386139312.000000000000000000 ; 000058393610764.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015C022DAB15C0D9434 >									
//	    < PI_YU_ROMA ; Line_5883 ; U3Ega0zg7t3y0POS8Zd0S9AryVr9BnbpgY5HyCx9xFE6ug725 ; 20171122 ; subDT >									
//	        < WbKfD9a3fCWuU8giboMAz8Ouct23fb4w9fSH4IdNZr3KLoFdXc7lchK1SGLw9n14 >									
//	        < H4Vjawg8rTFQGVKQF9JrtA4T7tIp151vfhTEj5kbNC04t63xqk8cF4P78pewqchP >									
//	        < u =="0.000000000000000001" ; [ 000058393610764.000000000000000000 ; 000058400004628.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015C0D943415C1755CE >									
//	    < PI_YU_ROMA ; Line_5884 ; 40uhasWIK3S6UnPN36Gzh9Ha2Afib15064j5Se3l1XucmZzL0 ; 20171122 ; subDT >									
//	        < YUzOFJI9J2qTMFD7SCQziPkRd5IDGD5qSH0MM498v3qtm5F2Xw3ddJ2NyK3a9T06 >									
//	        < 72RtIwa1w82g3AD3BGrzkc3UDAG6y4c8T52W5G91KMVlFsU2AHvWi14RzpU3s2NH >									
//	        < u =="0.000000000000000001" ; [ 000058400004628.000000000000000000 ; 000058414826092.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015C1755CE15C2DF371 >									
//	    < PI_YU_ROMA ; Line_5885 ; 64809BHn4h68JFYbya6A2f43xh0w0zYX5X1248O8d9q6DD1SM ; 20171122 ; subDT >									
//	        < 8333pzt9qk05c5h5Xuxg0ewO9SV5K6KqWy6aik00gHCaq92I08mj9f0FQkq5t152 >									
//	        < Wy10PNO873dNo3FW4dCZIl4a7NZ0D2jjG4Jy8I17X4Bvv6T8E6y68Rfn1TP2Fx8K >									
//	        < u =="0.000000000000000001" ; [ 000058414826092.000000000000000000 ; 000058422087041.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015C2DF37115C3907C0 >									
//	    < PI_YU_ROMA ; Line_5886 ; NTK9k5iLJjm80xoS11G11nKNiUXr3c2zDTbm7qV5M03Tf0uBa ; 20171122 ; subDT >									
//	        < IZbpF9BQW58Q48iuiNvhN8UxB0B1742azH1x59DAG9VkH1o6aqfnG5oSV3qzYL3P >									
//	        < j05PFbJTCXc4EH0Qmha6cE2ng00h82jVl4UfeD4rooOnMYmLv77t49RSm9Skj8fQ >									
//	        < u =="0.000000000000000001" ; [ 000058422087041.000000000000000000 ; 000058435446158.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015C3907C015C4D6A27 >									
//	    < PI_YU_ROMA ; Line_5887 ; Jz5704g67KAFqtpr8747aqd703Of8Z2Xq473Smwl3lUH6xfzN ; 20171122 ; subDT >									
//	        < w04zve5H2NHhp8S8S2T1E33TF9HDIt1X60d6OMNwk0uPhT9n7xCIEIC3bYxuwv4f >									
//	        < 4Y05y44jRtNO1nS7EQ73mPLM4uGNWNHb308p1Z035bZB83Wn7v9NO4Kqnqja5883 >									
//	        < u =="0.000000000000000001" ; [ 000058435446158.000000000000000000 ; 000058448582124.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015C4D6A2715C617564 >									
//	    < PI_YU_ROMA ; Line_5888 ; zw5lSK08B83eU4233UEZJvK51rRb5o8QM8e0EOfFSk1u79ham ; 20171122 ; subDT >									
//	        < 17bz875Laj2F5h9e83p341711xMHI13drBi46FaH6q4N81Z5G0tcKi681HuC1R4J >									
//	        < ICEmKrwpR9J7cq5rRrdk0l7t87hZq9q48W9Lc57tBZpcWLA0URd802yWd0SMu5dC >									
//	        < u =="0.000000000000000001" ; [ 000058448582124.000000000000000000 ; 000058458790386.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015C61756415C7108FE >									
//	    < PI_YU_ROMA ; Line_5889 ; HQgAvH6v0qw52QjaKLOONBpbtJw66g14UQ1r24OL95T6bUAoH ; 20171122 ; subDT >									
//	        < MojWzGptLjQN5y5yap5TQ06592zSmAr6FN0a1gypSaSGN5vND619DoRpOA19z7h4 >									
//	        < V04Btni7LUEfH797Ucyxc7603wrR82gKBo7A2M44F46VA02s3tzti0TWf8hMA2hi >									
//	        < u =="0.000000000000000001" ; [ 000058458790386.000000000000000000 ; 000058466288645.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015C7108FE15C7C7A00 >									
//	    < PI_YU_ROMA ; Line_5890 ; H23tO6t52Xb75P9iB7QB5eKkyR31j6I5hM564vV08PQ5amb5w ; 20171122 ; subDT >									
//	        < dR5dvJMwY05qdZ9jW3k22y7r1ayQer96eM6p73t75w8CZ7L9OD7M7VM8SX665R4s >									
//	        < y9mlR7as4MpGdgArf7z68wqQk1VAXRMPR4hq4Ll4L6MG4790VjG7zTbd9vHORYDG >									
//	        < u =="0.000000000000000001" ; [ 000058466288645.000000000000000000 ; 000058475731494.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015C7C7A0015C8AE29D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5891 à 5900									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5891 ; 3VlGQI67C7Wy1rKIoAm54I39u0N5Mt741kz9o1BhXm9yfiEk7 ; 20171122 ; subDT >									
//	        < 55C1QestPIOrdI35mdjlEh40WtT4qs84Fij5u23Mh1dG82806BOd0yag81Yl1fBw >									
//	        < E08Xb8P3zj9620j3vTDyXuf2woOqBjti92iLuVG8QaMxiPrVlAq89jozOguuV3lM >									
//	        < u =="0.000000000000000001" ; [ 000058475731494.000000000000000000 ; 000058487814504.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015C8AE29D15C9D528A >									
//	    < PI_YU_ROMA ; Line_5892 ; 7u31N2a2lnDZPAn5hSAO2Ce2nGISO0aAjJKG21gWW0dk1iM2K ; 20171122 ; subDT >									
//	        < 4DJ5A2W1qKy89m95CdfcE5lu5BimS9nUufm0s6Vp3R3Y4YPcS2131uRHy06kl6Q1 >									
//	        < 6hj3q36k7fj8Q1BM65sU6JAi1yXO9ANlPu4q9wAn3AgV8WE277CCjgnhJ9325FCu >									
//	        < u =="0.000000000000000001" ; [ 000058487814504.000000000000000000 ; 000058494492514.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015C9D528A15CA78323 >									
//	    < PI_YU_ROMA ; Line_5893 ; 0toA0N9Lz50K46zm4pUBIv18C5dV4bUFd6Voe8y3u9xXYY8CH ; 20171122 ; subDT >									
//	        < L878Vk5AT5Pz1933B4ZAB7ggTH0x7GC6aMn7nu82DIn449BywF8O010I9vd9VGCv >									
//	        < uGDRrbBP7fl71O9qxFDMO1Bw4khHj82dBoTrCx707CdBQ0rur89QJ8V9689I9WhB >									
//	        < u =="0.000000000000000001" ; [ 000058494492514.000000000000000000 ; 000058508919435.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015CA7832315CBD86A7 >									
//	    < PI_YU_ROMA ; Line_5894 ; LVgZI204e5q6o6T2F99z5r62o2PHp2AiJ5kBcmPj0cSz12So6 ; 20171122 ; subDT >									
//	        < 41qeGU75v6974wanE3w3tk3zm736CCL5T17wc6cjf1Iyms0588A9984XfNt06lYF >									
//	        < 1ivepymmOb4M49G9u09oHnyWokHdmF2Es19H6hZzg5SplrlEEGdTwgF71M82SEgH >									
//	        < u =="0.000000000000000001" ; [ 000058508919435.000000000000000000 ; 000058517495188.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015CBD86A715CCA9C8E >									
//	    < PI_YU_ROMA ; Line_5895 ; 0SHPCZHZNs1TasS9A11kM5r2t94O60bhj0aU0AUJAA3AnRGtw ; 20171122 ; subDT >									
//	        < P51WV4mmO445eHqIVepRu91pnk2MDuj9Ar6e7HyCh3aNq6yD01Z5P246VLyT428Z >									
//	        < 728ZUtw7cnK8A4HnRUnp322mE1A3j5D0RdsGlzjJX06V2vy3wf6HiuDxsG92okCw >									
//	        < u =="0.000000000000000001" ; [ 000058517495188.000000000000000000 ; 000058524028062.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015CCA9C8E15CD49476 >									
//	    < PI_YU_ROMA ; Line_5896 ; Pqk0ja59y2b0p37giq534JhhkrJ5nZ13mHl13WDZsG6Bpv9B9 ; 20171122 ; subDT >									
//	        < idZsNLdpCUjbm8w6826RPh8wwSLCTFJQO9J7N370SUNi79xPJu6G7roKf5f09oz5 >									
//	        < w82R1K5mVof8GNKSe37I1TINo1d655o5acuRYRnbfMf2evohLA1X088b9719w6p9 >									
//	        < u =="0.000000000000000001" ; [ 000058524028062.000000000000000000 ; 000058537309462.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015CD4947615CE8D882 >									
//	    < PI_YU_ROMA ; Line_5897 ; qflPYX17ySW6t1PpZ8518q9YJ7OHEePZ8j61aqIhycrKPDw1G ; 20171122 ; subDT >									
//	        < 082LjZ7nh74ga2n21v6E9d6Ky8m5KuH36ZZCiLRKZUvf6mv72fzlCyCs57GHjDB0 >									
//	        < 8ixoB9oE4jaA1l44K0rQrXgb1HymCS5Eoq5Qr8N0oV2MR1pczTk5X3ksrF13ncbd >									
//	        < u =="0.000000000000000001" ; [ 000058537309462.000000000000000000 ; 000058544998802.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015CE8D88215CF49428 >									
//	    < PI_YU_ROMA ; Line_5898 ; fWG3q2M1Z4BOAuqfEhf7DrJ11cp4L9kKNJt7K5i5L4TVORYP1 ; 20171122 ; subDT >									
//	        < s3K0CsV49OM8CkihCyT7ORgcIl0NG0W631x4393poc0tE9R11H8E5IS6rzcl7QGD >									
//	        < pSV7r5iS2Vm7ehb62A85v7V1jjz21x5i3UMMgl70IoQwfZXgmW42TGp5091M7J2B >									
//	        < u =="0.000000000000000001" ; [ 000058544998802.000000000000000000 ; 000058555835038.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015CF4942815D051D0F >									
//	    < PI_YU_ROMA ; Line_5899 ; HpeSwiPni7632g6479G57IK22XKQpX86W3lvJ2f7C3nkse80E ; 20171122 ; subDT >									
//	        < DQT33fS99O9n55oM90dQmjXb92Z5FmW68Q4mi53lf0xjaYMs7mYGDFK8hNk4XU05 >									
//	        < f2ly36OQ82Kj002y78P6E2aVLZ3hp0ihNsM9t57zd2c3tfck8vf7k0P9cQ7bJfai >									
//	        < u =="0.000000000000000001" ; [ 000058555835038.000000000000000000 ; 000058562133413.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015D051D0F15D0EB95D >									
//	    < PI_YU_ROMA ; Line_5900 ; FeTR62oOcvFM61kumO7r62JAPe6EaOZVHLsqj6FQxo107cfCe ; 20171122 ; subDT >									
//	        < 6xrtdwq98x2KER19xEQyqeuf4147eX6g9VSdt5mE692BJas4fl99BTPjVZH9Nw6O >									
//	        < 1g8O8809Y66ja5bweQg79Ku2Y433E1iYP7PMJtT8H1V95TcpX2X8ve3h906w5LGE >									
//	        < u =="0.000000000000000001" ; [ 000058562133413.000000000000000000 ; 000058572805417.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015D0EB95D15D1F021D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5901 à 5910									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5901 ; hDvm4K9kj9e72H4a1EDnPsBXZdaoPV695pHIlME71wsW7424O ; 20171122 ; subDT >									
//	        < B5fN0hok3i6h6tonUX14O1We3Z90SC1o4gB52l4m21yu9bi2haob102f79J3Qzgn >									
//	        < jv1Cp8Cye0B4Rbn2eQ6an5cfGc6Hw8st9ihV8z4MbnJ1f6J9DEe9ylx6eh4uqxk0 >									
//	        < u =="0.000000000000000001" ; [ 000058572805417.000000000000000000 ; 000058586474472.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015D1F021D15D33DD97 >									
//	    < PI_YU_ROMA ; Line_5902 ; I2119r2Wlhp3055C28v108E28QxAw3PgMyMTw61gl6KjqPXJD ; 20171122 ; subDT >									
//	        < kf154I22YS8Z84928z046cksV3B9tDkuF3H134LN3398W961OORKVMMc8U091Qky >									
//	        < F2HbfcH6QeyVxccCNNmBtZkFKMI6cI5Ta45t4abJFwJWbzcA8ZjuImn9bbdNGIO0 >									
//	        < u =="0.000000000000000001" ; [ 000058586474472.000000000000000000 ; 000058598527330.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015D33DD9715D4641BD >									
//	    < PI_YU_ROMA ; Line_5903 ; 83cNv02G4PGkgvIz02s1NP9z8FBJ7mX7128KZkM5yMyqQb2ER ; 20171122 ; subDT >									
//	        < n2xegDF0R5besq0996H2kN2u5ZS8kB760H0V3TkBw8S5d7hd05HsZ64gcRfUbL51 >									
//	        < l6oSRf7ng3jj18Z2OWa7bJ4i87741n15DO5PVXR3W0fnByEG6Xd6P4Ww75gLJ7Z7 >									
//	        < u =="0.000000000000000001" ; [ 000058598527330.000000000000000000 ; 000058611550808.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015D4641BD15D5A2108 >									
//	    < PI_YU_ROMA ; Line_5904 ; 5d0U21V0yuE0vl8789MMRE5p280935op0SV6F8LW4krTIyDT0 ; 20171122 ; subDT >									
//	        < F4lM85t175NWYzRgjGMNXENlhT7M1fdAaG050Flmn7zB57a6Oxw1xWs32nj078Si >									
//	        < apb2A93cMeBU6acT3RM93J17hG028e0B9fkWopJm463sgsjaT424Ag00x0BH65Qs >									
//	        < u =="0.000000000000000001" ; [ 000058611550808.000000000000000000 ; 000058624130708.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015D5A210815D6D530E >									
//	    < PI_YU_ROMA ; Line_5905 ; HGEQ9FSXtJih6M3RkFRRv4L2vjzCx6H8de6AaA53zg3oP1YN4 ; 20171122 ; subDT >									
//	        < zDI5b8qJq845ZQXXxb7wVk8286RbriHw7hg5vlyu79k0I6cbci8T9np8i68pH17e >									
//	        < 6453vpAJ9uKaGI7K1MT1wi94eyfzJJ0g899LydI484c15lUl35xpn9j61Ul5JNld >									
//	        < u =="0.000000000000000001" ; [ 000058624130708.000000000000000000 ; 000058629252675.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015D6D530E15D7523D3 >									
//	    < PI_YU_ROMA ; Line_5906 ; Y3xv4PYIzzrnKtTr4Wu67u5X3r9VUWwpd3pGtPd65651muLhB ; 20171122 ; subDT >									
//	        < aMwZuADmvgyN0Nq9UMv6Jm1wuDsl3NjEWI85PrdnP53K3uK2TqT53740h4D7ny41 >									
//	        < 81dh1ocE9us6ET2JoR6Uu7W3hwHMPUUE6buS7B1DbGO3FgeTz39f5ewqo85W97cB >									
//	        < u =="0.000000000000000001" ; [ 000058629252675.000000000000000000 ; 000058640082183.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015D7523D315D85AA1A >									
//	    < PI_YU_ROMA ; Line_5907 ; jUSLJioL48HRuzR23k7BqyYOam57GfOe3K9gu8r7d2Z54KmYq ; 20171122 ; subDT >									
//	        < 5k6Y2X34VBSK4Pc4G4eTo360T8bXC6A7Big56jtTu55K97V0UG51D6z5JIK6s65l >									
//	        < TJ4DpHkzgXct6NKpfbHI60XXewu2EsCeEnz5F64v3mSZ1KKzBI88PxL2XP0IkjAf >									
//	        < u =="0.000000000000000001" ; [ 000058640082183.000000000000000000 ; 000058652517675.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015D85AA1A15D98A3B7 >									
//	    < PI_YU_ROMA ; Line_5908 ; d189d237v7Wt2R5gDkLUcOyUTrE7ZCIDIS4GoTL71A8j8UXfO ; 20171122 ; subDT >									
//	        < 0YFLN9iD6l1kLl2LZ28rcDRC5z2AG0gdWFiMOxL7PaZGuq5928Ex552bMUwI654Z >									
//	        < tk1CmAVUf1V2HDB0YNQyFox61i0Nyt3418nqhxEk9W1VPR7bUzR3RpN1OPYTaRx7 >									
//	        < u =="0.000000000000000001" ; [ 000058652517675.000000000000000000 ; 000058663847202.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015D98A3B715DA9ED50 >									
//	    < PI_YU_ROMA ; Line_5909 ; pH5VseIwXbxRMm9c4HFpcIux7i11upGL42lZ84E4ZEv0H39P8 ; 20171122 ; subDT >									
//	        < n7CoLHvv7maTR07SQDmZA36LCo572T2pL06aB9P1b0xV99V1eH05w9k9Yxp71a6u >									
//	        < V9qp8lpGkKLgSLDVfn8qMOL42v62Wm3vsjBK35Skxsg0M2mxM2OWlpxOymy1752A >									
//	        < u =="0.000000000000000001" ; [ 000058663847202.000000000000000000 ; 000058678650869.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015DA9ED5015DC083FE >									
//	    < PI_YU_ROMA ; Line_5910 ; 4h8ttQFqsEKpeNJ89SgQodbV3axhuqjphgMV4K9sPeMXN1pMn ; 20171122 ; subDT >									
//	        < 94UXuMOaU34tRc3DD5kT5xvsN2gke3W2PgXDqa2IJu3SVqRts94s03J2Cx26V1bD >									
//	        < Ny46IYiiJ0vZ8QzQ6L2p9qd9WicI699XnQo3ruZpv8t69G71G76q8koNHQn899XU >									
//	        < u =="0.000000000000000001" ; [ 000058678650869.000000000000000000 ; 000058686875631.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015DC083FE15DCD10CB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5911 à 5920									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5911 ; 9Jth7cni8Ctk3Ecoj9t4v4y3H6IivZr9E4TV4jTr9P2g6JAy7 ; 20171122 ; subDT >									
//	        < 9whez9HT58OiM4s1FXopq59M1r454mQE50I7rDa2Jy8y27GNTKS5wUKSh2jmSibU >									
//	        < fwQq89J8lGXJ7980IAk10a7D2dg57uQXf5Eb3pA00GP6ScqD28117d7ac686r36L >									
//	        < u =="0.000000000000000001" ; [ 000058686875631.000000000000000000 ; 000058698965499.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015DCD10CB15DDF8365 >									
//	    < PI_YU_ROMA ; Line_5912 ; Cd8oTmk809JaIo69u2NBUj6Dc32S4viYNoXXPXB2W2W56KY1Z ; 20171122 ; subDT >									
//	        < GfqskqbHSGX2C2VTS579oZM1a6kCq6f86vGLQHghAis0iui99aTNS6aaU782zz1u >									
//	        < dECI34Hj88eZ0AXQjX5NCLe7Jkj5YwQsqgHo4Ga97l1Gku9mFE8f893QzIef0cXL >									
//	        < u =="0.000000000000000001" ; [ 000058698965499.000000000000000000 ; 000058706076566.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015DDF836515DEA5D28 >									
//	    < PI_YU_ROMA ; Line_5913 ; SU64422zgp6NuXIu98B3yah4Ytl0Eq06791rxdPX57E8PQlAN ; 20171122 ; subDT >									
//	        < k04jJz3AWc8P1n6Z5Bo35NO08Bw52d83C0a94R4120H9p4h8GQgsH545oA671Rj8 >									
//	        < noisM2bUs9Ytm04Q1yeJLZNU31yT232C7Tkc63EPx4BNAABqO4Tn7aQw5KxaSb9R >									
//	        < u =="0.000000000000000001" ; [ 000058706076566.000000000000000000 ; 000058712750358.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015DEA5D2815DF48C1B >									
//	    < PI_YU_ROMA ; Line_5914 ; 7IoqG3V9yS1j9y87tCKioclzHa7psLMARebZkIEBN1kKUUV2f ; 20171122 ; subDT >									
//	        < g2t62iLj2SIS6n2kP0UrSYegYgEgejIq92TTnvS7Y3Q18fAEjK11x05EdvdCvX66 >									
//	        < KUC2nNA1L7PP5FceV4n4B86n6yShG4lc8As3QEylM3Gcjsi6ex8rD2PS369q27VE >									
//	        < u =="0.000000000000000001" ; [ 000058712750358.000000000000000000 ; 000058723212947.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015DF48C1B15E04830E >									
//	    < PI_YU_ROMA ; Line_5915 ; 239dB1izA9403997LNCH2NrCTPR1Z3gJsbhpAdzayUs9OvyDa ; 20171122 ; subDT >									
//	        < MLlck7DxH4iOwy8dL4q2DaBi96K1xW7QeG8zi71qE35263P2PBN9zDU9c6XjW4mD >									
//	        < 5qKVjK6DB1nncu7EnLKaac8yEw5B6U6nkif2VVRMjW5EMW9PghSL7L6T9U497lj9 >									
//	        < u =="0.000000000000000001" ; [ 000058723212947.000000000000000000 ; 000058733617704.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015E04830E15E14636A >									
//	    < PI_YU_ROMA ; Line_5916 ; 381M46kfK9HVHx25993702zQ1sL768dl96a7VwTGR9o0XAh3d ; 20171122 ; subDT >									
//	        < cVeNOOSU9JcD8t74ZSX5AY32bk5oPmslW4HsK2mF6I7gmI3HqT8kQNXg2vODNpXL >									
//	        < 16suhw5h2Ug4ArLNtK9GneID5o4b23v10u4Bh5iWl0p951eeKOlDVD2915b4lJYh >									
//	        < u =="0.000000000000000001" ; [ 000058733617704.000000000000000000 ; 000058746555091.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015E14636A15E282115 >									
//	    < PI_YU_ROMA ; Line_5917 ; 33D1yQso1O7Lz26107l580cd9a8WgJ4WldPi6988HbEo06Dx8 ; 20171122 ; subDT >									
//	        < ne5F0zKXYI39l6bcdg616L0x1mZ92EILt9c9BKk6apNv6v23ucfDrMdf9cXDLz45 >									
//	        < q2TA21Yx0f0PYVdiDjXF0VRn0c8hPJwQckJ82VtBSB19SbY7Pns3i8COV76X0e9K >									
//	        < u =="0.000000000000000001" ; [ 000058746555091.000000000000000000 ; 000058758326508.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015E28211515E3A174A >									
//	    < PI_YU_ROMA ; Line_5918 ; K1VvLktQK4J5aI4xABaG1v79nwZ5yfQ1i1N97kSN9O7Phs997 ; 20171122 ; subDT >									
//	        < 2JXBoCS2z53sjioDS2a06U74h9cbNtWYG96kDi4t3yfLC5VFReO4ZTaMU37L8Vb1 >									
//	        < p37hjXiqAxOq7M1I73yna7m4LJ9tJ8FptBbWonD0yXAi5mJ6606nEp403Pkf10fO >									
//	        < u =="0.000000000000000001" ; [ 000058758326508.000000000000000000 ; 000058772936800.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015E3A174A15E506270 >									
//	    < PI_YU_ROMA ; Line_5919 ; j9f2zV81BrZ8l21HI365Kf5F10NaO3rGGg9UUHQq07Ki8Bfbh ; 20171122 ; subDT >									
//	        < Q9bbs2zFAr9C3YUJd87q2LvG4MDa9LuzV6Nm6WA5i4yNW92pPw430a9Qojz993M5 >									
//	        < 9QwJo5lVXKtIaAK9sb0Vip8B3KBtgWlPWAl2er39c5P3P024YXohRxdvc0JDQMU2 >									
//	        < u =="0.000000000000000001" ; [ 000058772936800.000000000000000000 ; 000058779239328.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015E50627015E5A005C >									
//	    < PI_YU_ROMA ; Line_5920 ; fJJ3yQM581r3Wzm5h7z7FtylTt8lu6Rm7jeXaYHxDxiJTGPq4 ; 20171122 ; subDT >									
//	        < qJ66oxQB42b68Zq0lVi89W8l351w5S2D9F5Asf700QUs8LS00sYA2Ux8qtLBsSf0 >									
//	        < 8qggo2U3P9Sp682KBd8484OLopIz5n69pec11u76dmoBRYfVplI7jPzom19EzRBM >									
//	        < u =="0.000000000000000001" ; [ 000058779239328.000000000000000000 ; 000058784608045.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015E5A005C15E623184 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5921 à 5930									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5921 ; 7v3iU06F6ldY0PSc06qcO9BE3yPAliW89DdZPbVJW2j6r6PvI ; 20171122 ; subDT >									
//	        < 658np1Zq6qsee0096FC4Ll69E3g6Yr11bHE617EDwJXlUTH4zO425n1k9dJON3HS >									
//	        < JCLM7qC5hJQ8q9H9IoaZiZlh86xl8RzD0QLf06U2jIStoFPGt3WZwjwKHcObNvN2 >									
//	        < u =="0.000000000000000001" ; [ 000058784608045.000000000000000000 ; 000058796842893.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015E62318415E74DCC1 >									
//	    < PI_YU_ROMA ; Line_5922 ; rS2CWK0Z2F3XW8C82LUqo7lSCW00rl5e67uTNRI6tMD1DvzQS ; 20171122 ; subDT >									
//	        < if1k1ADTxc39xlmaY1woXUsV1yMukjj1sH0v3I5C5FX84cMD85iZ14vg6k4BQc87 >									
//	        < 3R7U1atVg1c7xzP1k62y8Nx1buYtdj71p87mEH7am2yX00kUP0Y9X0pzn41JDuHa >									
//	        < u =="0.000000000000000001" ; [ 000058796842893.000000000000000000 ; 000058801991066.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015E74DCC115E7CB7C2 >									
//	    < PI_YU_ROMA ; Line_5923 ; I1WGDNl808NF3n4oXC96Ce8I62j68lLul0oFhKKfFpiu58jyD ; 20171122 ; subDT >									
//	        < R4UJLJ572QaGUqG56c0E1z86CbuMpflGGmiEV59n3GR12Io0LwdGD3d8UHu5s88x >									
//	        < E0IY9R6G6uoVr062P5B9wZ4v8I551DSrrxDj5juca5i2Y4B94hO8wD6FURSm92x8 >									
//	        < u =="0.000000000000000001" ; [ 000058801991066.000000000000000000 ; 000058808194596.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015E7CB7C215E862F03 >									
//	    < PI_YU_ROMA ; Line_5924 ; P3UO7j5Zyagrku8m8r3uq4wW79940454r7zKLSk04oF6eB0xp ; 20171122 ; subDT >									
//	        < xaytZwHx76aGD5QomM2kMY54uf70emVrAw0m63J90L8SnLBtj37zj9UNcQm141BP >									
//	        < 2nP3v31bDUCC4AI3IN3Pd7640l5xa1I76k9H43m92wU8f1Z0S24bsvIkWCF97vxW >									
//	        < u =="0.000000000000000001" ; [ 000058808194596.000000000000000000 ; 000058813975895.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015E862F0315E8F0155 >									
//	    < PI_YU_ROMA ; Line_5925 ; mg78rWf0TeKWlvx6qMXsRXva1DtBnp3aB9x63N27B7sFpT4Js ; 20171122 ; subDT >									
//	        < fB8qOyypF59EeeK4ui3urCv3FOBZI7reZGetvI79w7SkOnE29jNI1e69Quo24pq0 >									
//	        < 2JuQTD2e0SxA31Sat8jSPrT2XzOak7b3FogQHRp96UAbTfZ8CA3030gR3jC8ghDP >									
//	        < u =="0.000000000000000001" ; [ 000058813975895.000000000000000000 ; 000058826130326.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015E8F015515EA18D28 >									
//	    < PI_YU_ROMA ; Line_5926 ; P63c2Hug32fg47J2a26vTxG29ePPP8go45HkF86u8x1hV27rR ; 20171122 ; subDT >									
//	        < vRwbGbdnmjBS0H5VTUejSX0ZxTP3gEwe51cM4C7PvdS97GcXwfisJGgOICEB2wy9 >									
//	        < 4Cf9c5zm2TctSjxwOmqv3Dh42gKCR99LPxmE58N7lEqLjQk7y3B3e36cCbTeTkjs >									
//	        < u =="0.000000000000000001" ; [ 000058826130326.000000000000000000 ; 000058840688127.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015EA18D2815EB7C3CC >									
//	    < PI_YU_ROMA ; Line_5927 ; 2G7axe80NRl4ASO6O6hc7C2l81vi4zie833nOV0QwnN2UN4d7 ; 20171122 ; subDT >									
//	        < NdC8ix6biPH162MyIqtF9l7K8Rt3V3HeQ97787svds4SXS9324q612vRnXK6H7z3 >									
//	        < X57zk5uDJ43s2GF70l67PQsq02V9f49vU2ng4I9i9PG1jrn7wy6mN49DI7XnUlG9 >									
//	        < u =="0.000000000000000001" ; [ 000058840688127.000000000000000000 ; 000058847141242.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015EB7C3CC15EC19C8C >									
//	    < PI_YU_ROMA ; Line_5928 ; PnX726rzRshW1Zo1s6S3SzFxeyX1Wv4z58074hPmjBrcT7o36 ; 20171122 ; subDT >									
//	        < kp6Y0W8P5hYNbN96jG2cy3kN4K11L4Jn1tvYZ3CX2DMrPQRLbP1JMGbf9XJYZu6G >									
//	        < VTpUE04oJ5f9f0NUWu00BOmteWOgJ3q2Wd1EOe420JedmeWR24d0A854KRc5Sp6d >									
//	        < u =="0.000000000000000001" ; [ 000058847141242.000000000000000000 ; 000058860355742.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015EC19C8C15ED5C676 >									
//	    < PI_YU_ROMA ; Line_5929 ; 6e1dMnk2ab4F4vfIi656LmDUlL1B3HS1O759HcUV1C0DWpPY8 ; 20171122 ; subDT >									
//	        < sOT20KQbO8h76G903imJEzl7kF3QX6Ygt9NMETDO8158mP1zE4LdhZ8k6098z944 >									
//	        < 72VT9mkiUYD9s7Daz9v2644N5T2V6NS5k0lhtvwYVobv49wHbWZqZvA94oy370tm >									
//	        < u =="0.000000000000000001" ; [ 000058860355742.000000000000000000 ; 000058868791022.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015ED5C67615EE2A57E >									
//	    < PI_YU_ROMA ; Line_5930 ; K8R1aOlY275H00Sq6wK3g48pKBOKvE2zaH9pj4L3333Y6g9N9 ; 20171122 ; subDT >									
//	        < 4F1E5CHH35KARg13hOJvQ4o36K6D140rzGvyJrY8w8OffwovVXQMSNh7BJ4zi7SQ >									
//	        < fRybBX7jEyN07sD8L2Fzte1YMsYgl741I2wg5j1K3dGLPg0WBmiXOXI7M40Z7uF7 >									
//	        < u =="0.000000000000000001" ; [ 000058868791022.000000000000000000 ; 000058874288982.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015EE2A57E15EEB0922 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5931 à 5940									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5931 ; r33skHxaqyqaR61uXqrnS8YTP4bn4GSk87qU04U0WaD6O55VF ; 20171122 ; subDT >									
//	        < PGuNUF7ya8j5kM6ib5a1a23g8TSA3e1semNPxAHdY4c23AnCjCD7Zvzbi37X5Pw6 >									
//	        < q3EVd8458j00n6JF73kV596jG528U7qfQwUPRvk0894UDroY4Sqte4Z3W0x8Hwl4 >									
//	        < u =="0.000000000000000001" ; [ 000058874288982.000000000000000000 ; 000058886158366.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015EEB092215EFD259C >									
//	    < PI_YU_ROMA ; Line_5932 ; V7iv93d64lq8S0wxX6I59lR05tElOfWXsTG2N3NUx7J3eNvZr ; 20171122 ; subDT >									
//	        < 8x9bf3996fEZ6lV4p1dUfoqw0UoB4qd8b0v298Ykf3laItT67UDR2Oz8k5Nm6Yu2 >									
//	        < QZPGWb21Fn6zatP5KE2p9Kj0Of2OrRko4inIX21XrG9Mk02Rljn1KQbyO61141l9 >									
//	        < u =="0.000000000000000001" ; [ 000058886158366.000000000000000000 ; 000058899771890.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015EFD259C15F11EB65 >									
//	    < PI_YU_ROMA ; Line_5933 ; wPMDaIli92iO64c8f2FyE2KJaVMSbCh8N48Hq7Bx3gz82Ui5S ; 20171122 ; subDT >									
//	        < rGVi4P96mQ9r19nfahK9lBHlQSvmq26dMPLP5zzx240XT1Cz8rW8qOUl88AyASO7 >									
//	        < 0DaRbtYTSqtF1gjc4md06rhl59nphAk6I4uYA0406UIqK4I943EwkNcKtEQB4193 >									
//	        < u =="0.000000000000000001" ; [ 000058899771890.000000000000000000 ; 000058910558996.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015F11EB6515F22611B >									
//	    < PI_YU_ROMA ; Line_5934 ; x70B24v31Z86Tp7Pu41MC7NZnAgI0g8U6lM007u679KsplYDx ; 20171122 ; subDT >									
//	        < 4gMFs4HSbWw1h29q5min9Uq204PKGW731lBG8t9Js2B2R3qphO2XCKs5p69Zu4K3 >									
//	        < lgJn5yt64HKjWyE68j8y0KLBXkyL1lMkgtP3LV23Yh0QvZ7CySM1TUlwQTsK7nOb >									
//	        < u =="0.000000000000000001" ; [ 000058910558996.000000000000000000 ; 000058922149551.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015F22611B15F3410AB >									
//	    < PI_YU_ROMA ; Line_5935 ; etMf3wLNGGVp5e01Wd30dzoM7q6eoA9472XD516M6u09b8wJw ; 20171122 ; subDT >									
//	        < 9nHHNIHoRMhEFLHF36A97rj3qQb810CTHH8QXOR468DDs3RT21b4Ov0hC43OmGFU >									
//	        < K5gPbDmNPs194CFv1lmxBy4ci5BVDTXyx65Ca62CeLKa3Xb4ZLwbvfJQ3H8zM5GT >									
//	        < u =="0.000000000000000001" ; [ 000058922149551.000000000000000000 ; 000058928067777.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015F3410AB15F3D1879 >									
//	    < PI_YU_ROMA ; Line_5936 ; L07e4FL21RtV6n443yqdxWuE55B7S4443CjiDJTsaz68146LI ; 20171122 ; subDT >									
//	        < xd1RiZi0YaQUIx23C58k12yA1cOprOl4lhZ68EsF8L1eqSxQo8m38juhvdSsrne2 >									
//	        < UIb36tBcf9XWvFOCEt9B8V13xwjNj1u79rP222HGc101swLyTdKxqBawUY8bMJBw >									
//	        < u =="0.000000000000000001" ; [ 000058928067777.000000000000000000 ; 000058933822018.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015F3D187915F45E039 >									
//	    < PI_YU_ROMA ; Line_5937 ; oKCoxfdJS5f9bn1Uz9eHz3G9y2e3PYh96Z7aZ6pEEc0QGT143 ; 20171122 ; subDT >									
//	        < 5h8Q5XRAJSQbU8GT39FFj9hh2G41dAZL5pvf0u1zq29zojoA39Mo7NDScr6441se >									
//	        < B9292925k9QLZ900LL06iVLtt8gOfc768S24f8Z6Y3a3LY2mMLckyC12Tn7p8n4i >									
//	        < u =="0.000000000000000001" ; [ 000058933822018.000000000000000000 ; 000058946039578.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015F45E03915F5884B5 >									
//	    < PI_YU_ROMA ; Line_5938 ; P33EqVMg0lSwBh7ihoCjO3vi5u90OnKjN2R8Ji10OH6WJ88ze ; 20171122 ; subDT >									
//	        < 4YYTTf6ky0c4I9JpYH79H76fRuH2NmnUny4iYK4wKMCdH2Dt8U96oKN4xmo78W5L >									
//	        < jh6ST6GJ7344IG9bT4l2e2sBGFMDeP5uqe3DMNThX5tH57peBPlbZy54368s14yz >									
//	        < u =="0.000000000000000001" ; [ 000058946039578.000000000000000000 ; 000058951380767.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015F5884B515F60AB1C >									
//	    < PI_YU_ROMA ; Line_5939 ; NC47kps6unP1e1ah8bAX4SI2WCx1I2wd8ZH12MmL16qFZBY9s ; 20171122 ; subDT >									
//	        < sbkV60BxaOx3dSv820BP6ZF8Nwk64JMYO3IXeM0s5676X4v12tlGNLXiVV8zmsqZ >									
//	        < 7yhPitoVv1uIt868A8MGG7NNhskG8bPr74K0gzA2HFaY2YlhF33vlp5w534I48va >									
//	        < u =="0.000000000000000001" ; [ 000058951380767.000000000000000000 ; 000058964694708.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015F60AB1C15F74FBDE >									
//	    < PI_YU_ROMA ; Line_5940 ; o35K29edDasW099upII4li8K33h75DFWCZ04u9kxYsmEyuUw0 ; 20171122 ; subDT >									
//	        < y9ks8dvea7xc1KZk61857mIc4GXvj3cE7CIe21luE56iIWM85CFw70hnnZ69XBrl >									
//	        < w0ls7kk35C1LK99zYJU2xo3J1r0gdWZwq76PG5N2Tlg2QUDU357dL7fc7r44ab8d >									
//	        < u =="0.000000000000000001" ; [ 000058964694708.000000000000000000 ; 000058970554794.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015F74FBDE15F7DECF7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5941 à 5950									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5941 ; e3822K9J9l81c2j4f0Mz18k1HD030m0uA9Ct34bcp7bHDVK3W ; 20171122 ; subDT >									
//	        < EE9EycT8f3q04V7k12C5t32Wq9L1Sp3tv3gOtj90O29C2hVJ7PVxfWI3aW2LHxeA >									
//	        < HY4hzj1s6vqZb4d039KwPNDlV1183889fXP5Sz0g2v36jiSHUl7g9ZfBxZO0kM2f >									
//	        < u =="0.000000000000000001" ; [ 000058970554794.000000000000000000 ; 000058980595370.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015F7DECF715F8D3F11 >									
//	    < PI_YU_ROMA ; Line_5942 ; AA2D18ylr16E3d63pPHG7U0U8TD39JL307U7HNRQmjx3r5Kj4 ; 20171122 ; subDT >									
//	        < 9m8TpIgH8rLURvIkJJi12SbF4s7vZKBmgI8grxQDlJKa24p87jz5jft8vw98569m >									
//	        < lksdxvJJiD91K32ee6KNw98p5VmX6sOwYkKiQHQM92spXbOl8SgbB8enk50hmV5m >									
//	        < u =="0.000000000000000001" ; [ 000058980595370.000000000000000000 ; 000058988239741.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015F8D3F1115F98E926 >									
//	    < PI_YU_ROMA ; Line_5943 ; LG4XJUW62Nmr7qY1P586zlF9932W6zB17g3fnGz065G58o0ea ; 20171122 ; subDT >									
//	        < QYLrAGiYjuGR7GX0dTob0NeD7jY6zhG041y9p40rqb2hBKjg3i23JlpYC6euzJl8 >									
//	        < 3jwK7Su1vZzzbI8R2rZ55nlD41jI46XJN70WPOz52nnsaBW35byxmutG7bC95clE >									
//	        < u =="0.000000000000000001" ; [ 000058988239741.000000000000000000 ; 000058999105095.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015F98E92615FA97D6D >									
//	    < PI_YU_ROMA ; Line_5944 ; iKMp8Bw4pRIyksXBMm24arItQ4p7P894Fg3pqGQY25ARh8kmk ; 20171122 ; subDT >									
//	        < uHA37xA4WPa45ciC0cK5d546z7nTGXVi1kV4V1ZBEY0LgxggT6hO4Ge161tjWNeN >									
//	        < FeILUpl7kW3LCVXm9O851y4133lsVwVmkwa5MY0002lD6058kfL8Pfpqj308u67a >									
//	        < u =="0.000000000000000001" ; [ 000058999105095.000000000000000000 ; 000059004492512.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015FA97D6D15FB1B5E3 >									
//	    < PI_YU_ROMA ; Line_5945 ; D8WZjWn64vxDK7QAFFv193A1DHdgF56lVKm7Q8M0u6spGIGGu ; 20171122 ; subDT >									
//	        < S7157XVe11my0j5K642RyIyYfSmu6U2p4bf13V2yV1IXDPc7j0Egqq1k29b1TstL >									
//	        < g8UvE031MIw499Q8leL9qBTW2jR0x1Q1dmvrt96lE0DmT7w9iVqLk9yv0zTo9J9A >									
//	        < u =="0.000000000000000001" ; [ 000059004492512.000000000000000000 ; 000059009988705.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015FB1B5E315FBA18D6 >									
//	    < PI_YU_ROMA ; Line_5946 ; qAJ7sCAq1h35npj1VV8D1MZBpXtTqmEze4Sx7fmlq07ghIXbw ; 20171122 ; subDT >									
//	        < 7FV155bd6dMluZM0iVu3cRu5t9VJx26TQrIkd5xpw9V1dgvpDuU1zjm7uwJwtc48 >									
//	        < NGABcX9AcFn5i16IULuf7X6XZ85725KnVtv340o7WV4O158I8h6lm5NzD2R6u3FG >									
//	        < u =="0.000000000000000001" ; [ 000059009988705.000000000000000000 ; 000059018697202.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015FBA18D615FC76298 >									
//	    < PI_YU_ROMA ; Line_5947 ; 164Wo7ZFwIVfy91dHX6MWp9dMk98pn6BO5ZOElD74wLdmqhnd ; 20171122 ; subDT >									
//	        < WGQDNfXzSk9Zlu6vScE1e5Z11idZ56LGcHRD45HH403jRM2f15Mil8p855h08V84 >									
//	        < 72e7FYZQS3Zi72Pumpbfaq5M7ScrZ736Luvdz947OcaEPA4vvwjxbyFRnf8wt6O3 >									
//	        < u =="0.000000000000000001" ; [ 000059018697202.000000000000000000 ; 000059024959260.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015FC7629815FD0F0B6 >									
//	    < PI_YU_ROMA ; Line_5948 ; JgCzq66gbP8yoK2oh7NaFI3z146MDh3WBF3ts9OSi3JuO5A8k ; 20171122 ; subDT >									
//	        < o13I8boI4g9Fqj4V8pcUsK978XK2aVdHLv01X1925G3TV4SG7fVKL9HK8E78cppb >									
//	        < 2Tzi8x6tcqPbq0EYXGf34R94lhDQG5w5OGkTD707G3jk7U6TUC901qD8KWm4gwf6 >									
//	        < u =="0.000000000000000001" ; [ 000059024959260.000000000000000000 ; 000059035156776.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015FD0F0B615FE0801D >									
//	    < PI_YU_ROMA ; Line_5949 ; o683VDr3d4OweguK2FVINd473b2L7ch7RVu60w4PGIi02T9Om ; 20171122 ; subDT >									
//	        < 22YR2sH7x31NC8BW3T4T4Bv8B303l35dY956mKpbi9SEC1lBhMXkoKuii7z888sf >									
//	        < XMYjjBO47BZw7aiXIQ8p9h7O45iC9MA09d8Ceu47NlCf564AWb0kyJsNx685lmKN >									
//	        < u =="0.000000000000000001" ; [ 000059035156776.000000000000000000 ; 000059045854371.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015FE0801D15FF0D2DD >									
//	    < PI_YU_ROMA ; Line_5950 ; AmBOK80ks6GXO23Ag65NP9bgsBg2NC8O3uf5bFKii78emxrnR ; 20171122 ; subDT >									
//	        < PT97n3xY6L2d2zOxFLU3QKkx5Ahei5JIdh67MWlA3P4B48Pe8O16cY6jaFMvwqSJ >									
//	        < Y9p0c5545X6k6qFT41mWaIlPoIRsGZpYbSzr2iC4aSXAvKX27LO3uQ3rarJbg14I >									
//	        < u =="0.000000000000000001" ; [ 000059045854371.000000000000000000 ; 000059051136269.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015FF0D2DD15FF8E21A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5951 à 5960									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5951 ; uXBkOL2ejOhQl5h75l9Gf84oTfX0eiyJ54AbizzVxoCehnUr1 ; 20171122 ; subDT >									
//	        < GNI63jm6qcTm40wU0HXfJRWUgPWvdX8v6QrSF4Qi1g9U63dHpXL6AmMYPkZC2c9d >									
//	        < 41RlVX5wwY4IyKOy5n7iKM1dUa1JjIWOcX9qpkW286Sp8Kj15XrOh0bhDDYQ9SCx >									
//	        < u =="0.000000000000000001" ; [ 000059051136269.000000000000000000 ; 000059058190427.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000015FF8E21A16003A5A2 >									
//	    < PI_YU_ROMA ; Line_5952 ; C1JEGzrZ13880cEm3KzoF3Kc0dVub8KpU6ljtO2l1f5lIDrjs ; 20171122 ; subDT >									
//	        < tJPcR56WtAX018a5mu8K8XM5bUxJ8ogTv7rs98DyuCKhLE6ykXDpCylQhY68dheD >									
//	        < 03Xkeh2Z4g3JdUTs0pEng52J5nqp2lK4sP98KA5ZH1u2y2e9Hz8ZuqI7LxFnh5Aj >									
//	        < u =="0.000000000000000001" ; [ 000059058190427.000000000000000000 ; 000059064109598.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016003A5A21600CADCF >									
//	    < PI_YU_ROMA ; Line_5953 ; s5xTy4079J2kW6OY1z3g5zSet9qG0aM41E69F0Bb025u56VGF ; 20171122 ; subDT >									
//	        < Mhss67539m7fIANkIvXd9V1dUKzFbz16z7hsE0XoFr5zm4YGhzu8A33My16u33Xn >									
//	        < hIW71HJq1qakOqbFWqtAZIJ76pDn6tzC2w0DCowx27resdIUp1I5D1X21TYC1M04 >									
//	        < u =="0.000000000000000001" ; [ 000059064109598.000000000000000000 ; 000059069718401.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001600CADCF160153CC0 >									
//	    < PI_YU_ROMA ; Line_5954 ; dacrk1kZf1q9s8jUe0M911h9h7DpwI369v51It41E5PteMnW9 ; 20171122 ; subDT >									
//	        < v6z4QK8bcRm7vNQa68e51prs94E5mO8w9m36phq3n4juHqcl067d6QU7tPQualQ7 >									
//	        < XKhL89tvZ1W57ocgi35zxGX2pl952KQ8WiYo9X6WBmsqJ96i7N1OD2G9N3yyZ1xy >									
//	        < u =="0.000000000000000001" ; [ 000059069718401.000000000000000000 ; 000059079787919.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000160153CC0160249A27 >									
//	    < PI_YU_ROMA ; Line_5955 ; MB9lcdUV23GC93h2g2MdeLYm6y81vGnMAL9dn5vTFkCBq53do ; 20171122 ; subDT >									
//	        < 4wGS28e80l4U866Zow9O84CMatKkh8d99q6D162D2iWWb9Xg1zfzaCJO6x6T531W >									
//	        < 35apn3tL6J7aArDs8d7jRIPdgG92Es5eTokTR9GJVtDR29e151bTn3QPA9R770tw >									
//	        < u =="0.000000000000000001" ; [ 000059079787919.000000000000000000 ; 000059086979298.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000160249A271602F9349 >									
//	    < PI_YU_ROMA ; Line_5956 ; 0DmK4z5jZ4d5B74fNF2dRYB6V3r49gWVXcKEJ3Z6mqVy3xrn1 ; 20171122 ; subDT >									
//	        < RoXme7E77CZ2E58e0ul1MxlJ05839WqFfNGbKswmiZ6sJ0y6k0lxzf6BJCf6WLbS >									
//	        < 2c2d41dy431CZ4E12258Gxp2d212WOg7G6laQ8XGOaE9MnYo00e6zv3LKTNPZ3h9 >									
//	        < u =="0.000000000000000001" ; [ 000059086979298.000000000000000000 ; 000059094630710.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001602F93491603B401F >									
//	    < PI_YU_ROMA ; Line_5957 ; fu4FXDGD22K4J9ezH5Cc17Gk25yntpHW9FMq8jC2h8ZFKJZG7 ; 20171122 ; subDT >									
//	        < K58oEerMhjL8lrOX7u928NS3CdDt36zTOVo25D3ppk36E1dQ1L7F0U86ntmuU3X8 >									
//	        < fiPV08Hs38lyRCd346qDOa6D2eemtL5f0G3iip625nz2A6k1Z2i3gEfEnq1L8nu6 >									
//	        < u =="0.000000000000000001" ; [ 000059094630710.000000000000000000 ; 000059099695150.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001603B401F16042FA6B >									
//	    < PI_YU_ROMA ; Line_5958 ; eh7FK1spG9urCDERd837klmCR51G62LQ0352hCobP9JrJ66on ; 20171122 ; subDT >									
//	        < 3RU5mm4fObeHFvqY7lh6yCPc252U9JKgFP64bds5I3qYHFTf67o17626x8Ik452M >									
//	        < bz5w69Al4776BI6s06i8y92IEORrUGP66v1aUxNF9Qz362aMPpkJn6k1Q394uZgB >									
//	        < u =="0.000000000000000001" ; [ 000059099695150.000000000000000000 ; 000059109109224.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016042FA6B1605157CA >									
//	    < PI_YU_ROMA ; Line_5959 ; pb11XWUeq9Bx9R0YC804eqJt0754o4v064FwDQsyyxRif8k3F ; 20171122 ; subDT >									
//	        < Advx4m559duw52jWoC0v76uTixLXMvdfHSlOqa8a7Gc1Ska5Rup4463Nf4kn1uoT >									
//	        < qa8nzGzpP40K1Os4b996WOLRI0XZIfQ2uUk8AOf29984866IsudE18wD2l2KA7vP >									
//	        < u =="0.000000000000000001" ; [ 000059109109224.000000000000000000 ; 000059115474360.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001605157CA1605B0E2C >									
//	    < PI_YU_ROMA ; Line_5960 ; 8GWe7f675FA4hfVR1Fq8j0F7s4PMa3069Z21X72DFaa0sovKE ; 20171122 ; subDT >									
//	        < BS06J2Y9c6k4y3anh4GD0JyOyjubKK3KF4EUgLm5305HblVMx5I2eW0am39A32qE >									
//	        < Jod5z410X821270z7y1a64pW853v7mK0xUvpgH003xt10jV0Xxb5pbnfRIgM7IjJ >									
//	        < u =="0.000000000000000001" ; [ 000059115474360.000000000000000000 ; 000059124640453.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001605B0E2C160690AAD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5961 à 5970									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5961 ; 59uYxO56B5422ID8sTw8vUvIZI54VD9OiT71bGIVNt1x1D9bb ; 20171122 ; subDT >									
//	        < Va66xv4Xz7fpayY46ROvVjG7MkC6337eA5GRrcNy6BKG8HwzM1q7f7bld4DJ45u9 >									
//	        < 99Lr29QXK2K8EZ1nAuy7IhA02NAYfL5U8hBZl2LF9g3t3zsV29cOXS5Eqq3uB4JU >									
//	        < u =="0.000000000000000001" ; [ 000059124640453.000000000000000000 ; 000059133087477.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000160690AAD16075EE4B >									
//	    < PI_YU_ROMA ; Line_5962 ; lx59289aE44Rs461L6U0mDg103eQ1yJ2lgwT310bB9Wl1648l ; 20171122 ; subDT >									
//	        < gCB9c80ZmGk6598mDs1WO4C54A1hobi3F4p6L2nG6J16GqnNFf6n2hJmDzn01x65 >									
//	        < a3HgngVf6et2ndf5tcaTzxm1Lhh518gvXUo1I2ls4NOEI3eVW9p0SLeya4Dv8O33 >									
//	        < u =="0.000000000000000001" ; [ 000059133087477.000000000000000000 ; 000059145083520.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016075EE4B160883C40 >									
//	    < PI_YU_ROMA ; Line_5963 ; Xoy7AyrDj13pZnkPXfJ509fgs35E7IU97pJifljDEL7UJ4VLf ; 20171122 ; subDT >									
//	        < vjO99F6u4U2yCM3yGkJtI0y18kQF3I188T00T5GdxQSp6lo0Yx4l8um8pHXAu0X8 >									
//	        < T8d428Wh7a60MkNK6sswbp3Wb8nSOvvQ8BgGqqkwZDx7TM24yC22y9Vy154NMcj5 >									
//	        < u =="0.000000000000000001" ; [ 000059145083520.000000000000000000 ; 000059150458631.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000160883C40160906FE7 >									
//	    < PI_YU_ROMA ; Line_5964 ; 077aryx6O9NX6uL28MNGvLx83GxXd6lb67mIC09W59zNCepgq ; 20171122 ; subDT >									
//	        < 9r2dXXRMf3sy9Ye7Y0414JpwhDRI6M6zWxb68bbK2Xo8sa09zS0fx7t2Zv4S3Y0x >									
//	        < 78AqAmo3DriWdq20S4SBubL3sY26B26WM0fSNzetpOx2nuC8mVOy3Q92WOGE9AKT >									
//	        < u =="0.000000000000000001" ; [ 000059150458631.000000000000000000 ; 000059164301647.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000160906FE7160A58F54 >									
//	    < PI_YU_ROMA ; Line_5965 ; k8vv4nq49bAmuN46qGbG7N5R3U43PTc9rAMX1z773iX49qfD8 ; 20171122 ; subDT >									
//	        < 962fUEynkQhrPyYV3os6Lp47pKPy96lw261loC5jeq8J14AZV887bdOL9fTyfIF0 >									
//	        < rSBE1o9hF8q67dk67hi685CbxkY26Hs1QT72v681rsw93pWXJs5Y4z2TfrVG7QXt >									
//	        < u =="0.000000000000000001" ; [ 000059164301647.000000000000000000 ; 000059169719900.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000160A58F54160ADD3D6 >									
//	    < PI_YU_ROMA ; Line_5966 ; mY31vV1BRBxIKY5Z96fgRbve7j44b26qys5q06AbYRduJfUQ7 ; 20171122 ; subDT >									
//	        < K80D4T17Ra85k6021ihM0m4O5RKaTP73vC3zyc7y3LqGW066FC0KjWgsv9F761m8 >									
//	        < 04M29M90terlUS6QL4LS27mA43Ah8rU1mDBo5uWVaHhtc88p8l15pm564dr82uMb >									
//	        < u =="0.000000000000000001" ; [ 000059169719900.000000000000000000 ; 000059180918799.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000160ADD3D6160BEEA67 >									
//	    < PI_YU_ROMA ; Line_5967 ; 7RpJueAMb45230nj0gw9e98xU74QyknlT749a1JGka427D8c4 ; 20171122 ; subDT >									
//	        < cgSi3jl0n93JXxZ6rx0UjMBcb8MN8KdCJZOgWSRLADa4Y1pD2Jv7Xq701R2QxCqy >									
//	        < 6qwK69Ez64G50go41SXYxZdjr6mb1f28Lk9bF1tH8AMz25wPu7S3pR93WU7KV44d >									
//	        < u =="0.000000000000000001" ; [ 000059180918799.000000000000000000 ; 000059187639488.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000160BEEA67160C92BAC >									
//	    < PI_YU_ROMA ; Line_5968 ; fsvr97WtIZxDgla43y4qP39bYs934519mRAhb9LpBiTo45hRg ; 20171122 ; subDT >									
//	        < 93j66yMh29QDOZhuERuC4gG50rWVtrh4M439vFGLN3ee1JWQ7F7hp48y4O33v378 >									
//	        < 6U8JIYZ57r5883b4v2DGGZJsRvJ749Po7hG42cx8xR92v40xIWTWhi1L2124zsEA >									
//	        < u =="0.000000000000000001" ; [ 000059187639488.000000000000000000 ; 000059202599341.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000160C92BAC160DFFF5E >									
//	    < PI_YU_ROMA ; Line_5969 ; pYa7mus9g8cj2nju1DS0n6q6h6SLlhxNPbqunuq0BP6A574L8 ; 20171122 ; subDT >									
//	        < CNFK1U435ny1PHzx63yP0w5Q4eBZC2D54A1FJ7w2mjDrv03tvV053WcQ1C7xavlI >									
//	        < EzT3aj6A48AX9mhSuDp03HesJbdXdqXd6heP1Gjz0zRS31x4uuEhOD3Cpd6vOwE3 >									
//	        < u =="0.000000000000000001" ; [ 000059202599341.000000000000000000 ; 000059208332255.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000160DFFF5E160E8BEC9 >									
//	    < PI_YU_ROMA ; Line_5970 ; d6y108XAHSuhj86tz64yJ8hDK03sCk2qt12v9ido5cE0oJAiG ; 20171122 ; subDT >									
//	        < 1Cbaan4ku4tCiWLay633uThc5o6GH4W9D3pN0A6Oy4XhDUYm5b65ZahEjvJsRlPc >									
//	        < jmGQnIsx756QK1WYsbgCB12Gi97XPNahUE2oFd95taHQp3122J8f1Uno4Vd3y31S >									
//	        < u =="0.000000000000000001" ; [ 000059208332255.000000000000000000 ; 000059219141373.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000160E8BEC9160F93D19 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5971 à 5980									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5971 ; 5Iv19178d028UNb9P8ZI080TQjic3Qp4dzihbJwjg36Lo767y ; 20171122 ; subDT >									
//	        < VrZ7hnMo5PWFTGfs19YCqeOi76o974Obk17e2m4o7fev7308p0I24RVGncBS9X97 >									
//	        < 1qdDgp4HIQAisE571oBY0h66ZTk10QR2L19bypW00LxL662qz0c1mM8ABvbp6pVn >									
//	        < u =="0.000000000000000001" ; [ 000059219141373.000000000000000000 ; 000059231580087.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000160F93D191610C37F8 >									
//	    < PI_YU_ROMA ; Line_5972 ; Z1R4Tlt4h3k0cf0zUZeC50aCAr4dWu1FUzn7Zh9g19DJkc0U1 ; 20171122 ; subDT >									
//	        < 6J2wIWQY40f5A6Alnbx56Bg8ZmM97s3p5SO2GdjyLkR391zjUECwZ31bMd7JR43B >									
//	        < J425JI33Qu9078jQN0W0W86w58H9xZv2vw9XTxu1315TU8Z315Ke30NOChoQtd9z >									
//	        < u =="0.000000000000000001" ; [ 000059231580087.000000000000000000 ; 000059240837401.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001610C37F81611A581C >									
//	    < PI_YU_ROMA ; Line_5973 ; 286XY8zv623C2a4jyrizmgF9GAo0KPw61pIZp6IbW9vOClr1z ; 20171122 ; subDT >									
//	        < M3N5eTJ0B65TiZhMS8346G29o9Vbj67342DgdGf3gwAo1Q3J1EC6qw2iBon6yFO8 >									
//	        < 4zbwQ50GVSvWNkp2tKGb20cpyZEWLZvo94IW67zmK7Vlx1bn4MeCRSmLyqbvuMCv >									
//	        < u =="0.000000000000000001" ; [ 000059240837401.000000000000000000 ; 000059252365631.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001611A581C1612BEF53 >									
//	    < PI_YU_ROMA ; Line_5974 ; T3sp646IS7vDtnlK66TVSv9d3PXh33gPETqj75841y1T25ie2 ; 20171122 ; subDT >									
//	        < cJTN3GV537AqSl7m49Oi3o9Q7XZJY42F5067EYSHe3Mdt9U2V6zd3rTxZ9B1DQMH >									
//	        < uRg6vsjKo8a4zOn9Z0bcFyUB9r6X0uHqnHlyAX277MmbPd9dmv5LQb0yc2A0TK17 >									
//	        < u =="0.000000000000000001" ; [ 000059252365631.000000000000000000 ; 000059264289757.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001612BEF531613E212F >									
//	    < PI_YU_ROMA ; Line_5975 ; iq84ed8oqcmEjqfTaU7b3O3Qac6WMq7eDewlDLm1YKbfIYu1u ; 20171122 ; subDT >									
//	        < X52LG4T75oG32S0uv17H0u3m40h3Q8W194mBa8TCMJ3GIvGcWvme9BT2OjwMu6Xo >									
//	        < 13885wFU84lszi95578KePCYHNomiba8elUXiDG6hd6TtB5DT4Lm3nfMMxClC59E >									
//	        < u =="0.000000000000000001" ; [ 000059264289757.000000000000000000 ; 000059273762578.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001613E212F1614C9581 >									
//	    < PI_YU_ROMA ; Line_5976 ; CrIxK14SZiO0ePmy17qSuyY6t26lvqaXesFiO6H97LMQbf95B ; 20171122 ; subDT >									
//	        < gnotA15QJG1021wc8g4FfqO0bI3npkMSFn49h87C8yn0mx0B129rYnb79n2oBQO4 >									
//	        < WPHbE0jwiTUpkgaJHJf5jgshdAazonmYyT64NmWHRLkp6nRZt57aeShtF7pas5QB >									
//	        < u =="0.000000000000000001" ; [ 000059273762578.000000000000000000 ; 000059281621908.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001614C958116158938E >									
//	    < PI_YU_ROMA ; Line_5977 ; bXEqPeB7e9tb5JPbGE379kQLBagwHlj8uGQd2B3X19Qd3sZS3 ; 20171122 ; subDT >									
//	        < x3v3Irg1910o0f726hw2AJCB27ZA6IUWBBJE5CTUaLbKfvt3M70ojWdMBkTPD4Ku >									
//	        < 2M770pA73AHZ1qvW0159GVA5jkMg1Zg3x6aCe4zrVM4oWYoe3R5r010ggaa72YY1 >									
//	        < u =="0.000000000000000001" ; [ 000059281621908.000000000000000000 ; 000059286745167.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016158938E1616064D4 >									
//	    < PI_YU_ROMA ; Line_5978 ; bD01bF14z1BAge2sc102VO79Oj1m69EE94EjP09UmFz451Bkr ; 20171122 ; subDT >									
//	        < 7td1Kro5q53aMF20cwB44uslN95arco76ax3Ss78Ra7o3I9EMi7F4T71C49D5a2u >									
//	        < 7kaqZbfcHmDIiWYhrFv04j1QRo2kW7wxaDrlK1Jp1w0Cb4AcFm8474w6MY6YwhnX >									
//	        < u =="0.000000000000000001" ; [ 000059286745167.000000000000000000 ; 000059297268402.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001616064D4161707378 >									
//	    < PI_YU_ROMA ; Line_5979 ; 2IrwUMu32VEo4o7RFKMQxRtVx0GY01SBCstEG1NMB536lxX72 ; 20171122 ; subDT >									
//	        < xL5MY6472rKdwe0L7Bdsf6HLxwu2AP7qCW6DHYmZ44X7oHP6oZ93mpugmm7qS3SX >									
//	        < 5rdUYAdGdHePEi7RAjUwTGuC9SkoQ81181wkhtFa2qDb13OFwD311T768elF92T7 >									
//	        < u =="0.000000000000000001" ; [ 000059297268402.000000000000000000 ; 000059308906746.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001617073781618235B2 >									
//	    < PI_YU_ROMA ; Line_5980 ; YZG0VGXitl5Zh8Z6xT9hSX1TbD36rL9x25WsL8pJRKKo1977n ; 20171122 ; subDT >									
//	        < uYdF67NNR77E64B4Rz6n12vZ6CHmxL69L6Mgm2iuYlNctA6tV2CDq600PvX8MsyZ >									
//	        < xTd8FL64SdZUMdNP4HEsuOjCxwriQ03aPOGGGeEICN352zppcH1ws82Pl7d3xJmQ >									
//	        < u =="0.000000000000000001" ; [ 000059308906746.000000000000000000 ; 000059314663896.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001618235B21618AFE95 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5981 à 5990									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5981 ; 63h3lYEnfvU9mK5eVi164NmUbXbfF3YiMWtOhynN05Y71VAKx ; 20171122 ; subDT >									
//	        < IbM4stFUWfP2NfQGEK5dfL32GcC0mQ5HCBEzIWeCr27P73bQ6olIIYZZTo175ul2 >									
//	        < 3GzK0ZZ3c6vdfV8Gch5S98HrguM8E9SLStqZks9NRwKBX6YG232Agiqlga85mI29 >									
//	        < u =="0.000000000000000001" ; [ 000059314663896.000000000000000000 ; 000059323739439.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001618AFE9516198D7B7 >									
//	    < PI_YU_ROMA ; Line_5982 ; oTrvrv5B1i08TN03wcf15VA50RoFKwLDM1MzjhUvjv5X0ikMS ; 20171122 ; subDT >									
//	        < l1xs5M8tUtaZzOeEu21RKUpqi9Etu7FQ52Q1BaCkmV4r3014ITv742sjniAXnzC8 >									
//	        < Gr85POum6R0iI01hL7o8z8uOpY7443v2xS9PCI6L1JWg60SY3n7xH4W4Pqdo7U57 >									
//	        < u =="0.000000000000000001" ; [ 000059323739439.000000000000000000 ; 000059334260664.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016198D7B7161A8E592 >									
//	    < PI_YU_ROMA ; Line_5983 ; 1ScM4HR707Hm8a55B58rVOYadixA7i5KWGfmSY2iS8ZC8h4eu ; 20171122 ; subDT >									
//	        < j9ho6Tu342M3rcdBOG9sDy2TdyHmo6UInzVq4kFHilIF7UVX66z5r896nYW9leFP >									
//	        < 8MsmmCD7r12O9lE26TlQzKOq2b7wWTe8UHF0a56l8v2p9LEWI5234CDM64jR0ASP >									
//	        < u =="0.000000000000000001" ; [ 000059334260664.000000000000000000 ; 000059346555346.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000161A8E592161BBA82E >									
//	    < PI_YU_ROMA ; Line_5984 ; uHOq3WDtre3ER66mG3tyC7bOI622lp5YBBU3weq4M1W5wMKgB ; 20171122 ; subDT >									
//	        < s5g4L710XThOemSj8X8X833MCq6zH83AI3LxL93zp9U61uR83Nmq17KfgiR4TMf3 >									
//	        < 23BClu41E21xX1jKE7NtOToUq048r702223EENSxqUIZAJv6bIf54vxbXX1hI1fy >									
//	        < u =="0.000000000000000001" ; [ 000059346555346.000000000000000000 ; 000059359390088.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000161BBA82E161CF3DC0 >									
//	    < PI_YU_ROMA ; Line_5985 ; 2phiLJY8mPUjDxsxHhD8qeYv1431Q7MHRf7x7YxUnpL52xKEk ; 20171122 ; subDT >									
//	        < h0HZJH7stp779c92yI88Nt2Q1p6FTQV7H9JIF3868PFtT4X96wtjBNK1BPTpWWb1 >									
//	        < q3rm3s8r4LKneu8oRrNijn5XFe14HTeI0227dpdI66za899zaVUvJW2aa4vsJNO9 >									
//	        < u =="0.000000000000000001" ; [ 000059359390088.000000000000000000 ; 000059369566377.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000161CF3DC0161DEC4DD >									
//	    < PI_YU_ROMA ; Line_5986 ; FY9V4T7DZFhF9Fm8ID7KEN93gzfJou5B8qxJX4d4I5dm1wri7 ; 20171122 ; subDT >									
//	        < UkPf873pmJ72yG2wSw6NbIrViu77EPNf45no0lej47EsJewhD0qpsLT3UWQofu6e >									
//	        < AfDDQR278tS5B75CX0uuTTs2B68G4f0EpI27tkh0B7iWtofv7f8h9NF3ap2d72Gf >									
//	        < u =="0.000000000000000001" ; [ 000059369566377.000000000000000000 ; 000059384038162.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000161DEC4DD161F4D9E8 >									
//	    < PI_YU_ROMA ; Line_5987 ; HJ1IUQ4GFFCuuLr91un5Fgd4g8TkmI4H5umddPFN4ALXE70BQ ; 20171122 ; subDT >									
//	        < C3o611s00ao994E31dr8j3zv5G08kXvr0TFc2a9X1hVCOL7mWy4Dx00ZG9PvnFkR >									
//	        < WvcHG8qI0sA6Q2wqtY634930qIv5bzQv4b8RpzY6IWBgBCp09JZ2hHe6uH2U0JQe >									
//	        < u =="0.000000000000000001" ; [ 000059384038162.000000000000000000 ; 000059398126054.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000161F4D9E81620A58FD >									
//	    < PI_YU_ROMA ; Line_5988 ; 1ulWTbm5RU2sa71eXiy9Tk95q685Va002faom7h8ZJIL9y2bj ; 20171122 ; subDT >									
//	        < GyRkIeZ8fh1E0985nVS5e5sJAy0cJLNLC9Gnzh1SqJQ33RTkZeD9Bx1KNPdy45C6 >									
//	        < m1aAtU2Ocds7dKexna2yDNpXf6D93v41F5M18da049811z205wLCZh2JmMtGMBWZ >									
//	        < u =="0.000000000000000001" ; [ 000059398126054.000000000000000000 ; 000059411315835.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001620A58FD1621E793F >									
//	    < PI_YU_ROMA ; Line_5989 ; Yd26UK6uDVtPvtHtspY7jxtEa9i7eQyLiwS0E3un81NCQgz64 ; 20171122 ; subDT >									
//	        < mU2dOoJC0v2L5vHRCLE1UCzjOYrtCr5aLV778T8811P7rDd2XJnTv5J1d5F9OqZW >									
//	        < Ou5fk4R2UPqniHvKb4Lfzte790Sm2ECta0prni2329q0z4XVoJUPqvg8OM96KV3b >									
//	        < u =="0.000000000000000001" ; [ 000059411315835.000000000000000000 ; 000059417238248.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001621E793F1622782B0 >									
//	    < PI_YU_ROMA ; Line_5990 ; 6VoU6JL88klUE4inCPyNnKKeNL8hDx12XEYOjvws6iaZp5D94 ; 20171122 ; subDT >									
//	        < 2Xa3Vb6R4kS7V0MuKrPmYGkbWsCb40mU8CaU17Yd7wL6n0fyTRZS4WQWUYF668M6 >									
//	        < 7agK64C2QAM9uCG4guM1ODhVZMnX72gM8M4A5zI2iOrZEU1lFAP422VcdCDPN3vN >									
//	        < u =="0.000000000000000001" ; [ 000059417238248.000000000000000000 ; 000059422725787.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001622782B01622FE242 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 5991 à 6000									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_5991 ; 982W8v3m555py47tC7SUMiyTwhIwa6Wvg1mU8Ralm00bgK5v4 ; 20171122 ; subDT >									
//	        < 8J9E6p1jxxQzohBs4AQF1NA8VpeX55roVIYQjOh6c17x691u3l93n1u96ZBQr67w >									
//	        < 7Q1sf1Mq2Rj9vz9RQ4SXrIjxIKw361pjd33O53G39Dt998aITEIy63l4h1n963jd >									
//	        < u =="0.000000000000000001" ; [ 000059422725787.000000000000000000 ; 000059433118746.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001622FE2421623FBE02 >									
//	    < PI_YU_ROMA ; Line_5992 ; gfNaSw108OOTA38mEW3Jrk5FFhWNP1T3Z1h1Js25r7nSYH5WW ; 20171122 ; subDT >									
//	        < ImyPuq47fV2G306J0F082K3Jou6dcaYF25lEuBHSG7nsU22zAmR1E7bnYB7Y45Db >									
//	        < 7L1aDTz8GAK47g8mSq9g3WS1KDO1518dliI5mGB8C0PoOFkxxUWNy4070Gzt1x74 >									
//	        < u =="0.000000000000000001" ; [ 000059433118746.000000000000000000 ; 000059439918652.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001623FBE021624A1E39 >									
//	    < PI_YU_ROMA ; Line_5993 ; 6Dq0ccsL1ZN2GlH8VKC474ISR4pS5tbhk044O6cJrgIMLEkd0 ; 20171122 ; subDT >									
//	        < rYh290t63e48OsOOkmXYZc2yAx5QsrINN4Y6i2V3NNrE1LDJB2073RHRp5JdNz5Y >									
//	        < sMcdbUa8712sdXw0lkd59NQpApObYovSqmD6Ma0l81WMct77C6j0TrmbT939RGPS >									
//	        < u =="0.000000000000000001" ; [ 000059439918652.000000000000000000 ; 000059447656948.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001624A1E3916255ECFE >									
//	    < PI_YU_ROMA ; Line_5994 ; M709GihlGL3D0BTNU3coEer0bUr3viuwng9Ugd79F2oYDTJ57 ; 20171122 ; subDT >									
//	        < s0UMTR5PMq5Rlci9cvQHxCdZ1u2LpQdg2FlQ6fpdS6FZxLcc64v1Ld8tqx47204A >									
//	        < RLZbsm2kH6lUgL7ysz8Kx7O8VKs45rK9PB63yjGT77NoMt0pOgdVcjS9mym2F81N >									
//	        < u =="0.000000000000000001" ; [ 000059447656948.000000000000000000 ; 000059454669963.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016255ECFE16260A074 >									
//	    < PI_YU_ROMA ; Line_5995 ; DGNx7i35Dv3kO91PMa1XH86Jg1kjE0897tv1AaM2wuPcImtzm ; 20171122 ; subDT >									
//	        < VSRIqipVQX362y7M55Uy59cokg87Dbz4e361mHuet3UZpeW9JDmpr2842Fy5sD4X >									
//	        < 3m9388CuJyP16ny5081r46dsB3PNC6y7vu3E0I3z05H57q4Z31YRyHTJ928i3e8k >									
//	        < u =="0.000000000000000001" ; [ 000059454669963.000000000000000000 ; 000059464317929.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016260A0741626F5930 >									
//	    < PI_YU_ROMA ; Line_5996 ; IBR3DF11Jh0IY3XmtG3AI446RntbJiVeS8kymoUMI5b5V336J ; 20171122 ; subDT >									
//	        < 5k58zD9INEe6Q801D0F5e5mH6ZI14V1oHq5VxcQwpnCq38hxk004y499L9783oDY >									
//	        < PnKCjt0Q94a931789h6dgmyOsthY327fQA40glnOcSgT7G33I02YWa053ZVSb2Xs >									
//	        < u =="0.000000000000000001" ; [ 000059464317929.000000000000000000 ; 000059473113142.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001626F59301627CC4D2 >									
//	    < PI_YU_ROMA ; Line_5997 ; 7x5XSnVtG32o6jNbJy4LC2miiix1AB0Y04s3V2H2O7CErr80P ; 20171122 ; subDT >									
//	        < VtMG7KV1s82oJZpozltR4zyt2qK1i8rVN0GREqQc19224YX42UVwICy16B5eXNn4 >									
//	        < 8cfFL1xs0778ILk0Zvmo1o0fq4t65Ob4s3T2z9Kf298CL6b6qXB5pq6SbM4vH5y6 >									
//	        < u =="0.000000000000000001" ; [ 000059473113142.000000000000000000 ; 000059483928748.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001627CC4D21628D45AA >									
//	    < PI_YU_ROMA ; Line_5998 ; 13WruP94SaZVAsMErF58z998DFK2u3rZvK2C3TsLXak7avmfo ; 20171122 ; subDT >									
//	        < 9fL8IsASlnfP6FG983Vq3mHg73C30JIU6bC86132q4rhWVihHq0Mz3D9NWw6C9aC >									
//	        < yPnLUuRm6kAbEqiYpNL4JxF70eYU9zi5To4On91JPja48J95emXnn63VlRoC4N6N >									
//	        < u =="0.000000000000000001" ; [ 000059483928748.000000000000000000 ; 000059491528620.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001628D45AA16298DE5E >									
//	    < PI_YU_ROMA ; Line_5999 ; N74uEdHa0Jh0Z84s9e396fGHiS808gxk0V3lIa7U1e39WAD5c ; 20171122 ; subDT >									
//	        < 8Urjo2c37979EukrGieJ3bGJlvh0Z6U6K7p887CxVLDL64r5sx307bEB58FOpaic >									
//	        < uD83yyLo2S86G5JQiBf81Rb5qQD660vI7Iq14ncADM9ZkFVC0sHmpu339Yiepu6R >									
//	        < u =="0.000000000000000001" ; [ 000059491528620.000000000000000000 ; 000059496715225.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016298DE5E162A0C862 >									
//	    < PI_YU_ROMA ; Line_6000 ; 53Df2z0x6lZQre7NVq229n58mlZGLLa4p4a81jr1nwsNz4YME ; 20171122 ; subDT >									
//	        < u2K2e0UBsx5oASS9SqBSHOp6R8s4jWjn8b8qO0RoKM3qhJUUqAHBvi0V6gBR4LzE >									
//	        < 20f3i4I2717GiUj12x198eDM62v1L1Z2BYvz83c446Nf857A4CUs3908N53pTOzF >									
//	        < u =="0.000000000000000001" ; [ 000059496715225.000000000000000000 ; 000059511121518.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000162A0C862162B6C3D7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6001 à 6010									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6001 ; s5S029J7Dutn65NfZRBcw7b6ddFPKd1Z6443dd4i357cxL5bG ; 20171122 ; subDT >									
//	        < SOPtg5eOZmQ21ETkD2fju8FieB2szn9zEnM64o1pw1Kix0jL0UCI9PchRwUJ5B6w >									
//	        < 8Z9pqy00HsNq0EOjVY47bRUuAVCt0aV1mYyye1FXBVrpFxqW9uK8hE789AgtqLYx >									
//	        < u =="0.000000000000000001" ; [ 000059511121518.000000000000000000 ; 000059517952464.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000162B6C3D7162C1302E >									
//	    < PI_YU_ROMA ; Line_6002 ; YcI9G529bdiP15YK6u3NOnr6P65HTq1236rT2ri63Iw96jLe4 ; 20171122 ; subDT >									
//	        < eUSkT4r3HsA9Bpg152daJ44pXJi6mvnG0COhsF6Z17kh0dc8jb2PzfHzADHvYdAf >									
//	        < 8M2y6T36dHTC5xwBcONV834pDQ7sBv4KI39M1k675hnFDv0CuaRuotMwPd3QZng9 >									
//	        < u =="0.000000000000000001" ; [ 000059517952464.000000000000000000 ; 000059527433993.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000162C1302E162CFA7E7 >									
//	    < PI_YU_ROMA ; Line_6003 ; 7Pg9EJN5k1ZyNRnVZj1A6RN662TRXfGr8Sifm7mrzyr717Td9 ; 20171122 ; subDT >									
//	        < EzgAQ1ojse1N2clKkik56WZEfn7HcM4Xx8J3M59PxE1c1l3x5Jh2R1h9Cev7OfW3 >									
//	        < Rnr2Ek38sRuW1LrMJ6zyJoqzQ7xrvp5gmodo73LiI7Nm0y37eD75Zq6yMj6gx20J >									
//	        < u =="0.000000000000000001" ; [ 000059527433993.000000000000000000 ; 000059537600531.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000162CFA7E7162DF2B35 >									
//	    < PI_YU_ROMA ; Line_6004 ; jZ9q6G3Wp2JR4tiNG7PKlTKEk99Q3VYx19Q3jJj8W82Vq645B ; 20171122 ; subDT >									
//	        < PzQbkkj9yWQD56I1cZgh508FTHIJRFbp3rcbCOCZB26urTAY7sE9JBcKKCtj9fO5 >									
//	        < 2IUCn5N9F86OBEArCf4Ao0cu1VF4Fa3GZXq3ILO8j0En6zQGDqzf7oYc1yCIgddQ >									
//	        < u =="0.000000000000000001" ; [ 000059537600531.000000000000000000 ; 000059551472964.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000162DF2B35162F45620 >									
//	    < PI_YU_ROMA ; Line_6005 ; u78MttK8RUzG8BtGeG10jPhNZZ20f6Yhu1BoOMS989nLnHrt9 ; 20171122 ; subDT >									
//	        < E47X3070c3m4mSQaqYiMc7k6VvoQofdeq5300fIay5mUT2AxeGN5KFyXIBAzT1Xr >									
//	        < Sr3P6vj600nLoPG4eFtxCKk94dYDbM9Ow3B209Y68Jwmd07m7pvqe3A0XW74iQ4Q >									
//	        < u =="0.000000000000000001" ; [ 000059551472964.000000000000000000 ; 000059557951052.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000162F45620162FE38A1 >									
//	    < PI_YU_ROMA ; Line_6006 ; F8zonO1itvxUwm3l9MP56a3nK7g028mNZqLEN7A8Os2cpJhY8 ; 20171122 ; subDT >									
//	        < z9mQ9y8IQ9JrNdVVDbReTPs9mJ1fVZRO8y0Ww2li08SR2p3q2LglNaR9edy4lhF7 >									
//	        < iKedjlFr1H60f396aA6Gbk0sDNDb4x1v7pMVUj0IqQ8Qa6ASGhi43gS7zLnwLoA2 >									
//	        < u =="0.000000000000000001" ; [ 000059557951052.000000000000000000 ; 000059563130472.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000162FE38A1163061FD7 >									
//	    < PI_YU_ROMA ; Line_6007 ; a2OUtJs87J24kea0Sb8jD385ml3nB29d1IHQ6lG1uSDAY3Ch6 ; 20171122 ; subDT >									
//	        < 8P5bR39jwfBsq6Bh0C88hEF3AXkPrM6h4IwmQnp9DA4SiOn4vLo28PXGwyrU7gUg >									
//	        < 4WjVBexHFNoz5908NJfmEFpwVzrZA510734x0Ca13l309CS14Mno2vs5047tJ1A7 >									
//	        < u =="0.000000000000000001" ; [ 000059563130472.000000000000000000 ; 000059572247403.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000163061FD7163140924 >									
//	    < PI_YU_ROMA ; Line_6008 ; 12OgzPtPJhYqFp0Qod8KnUNc8w7B7a4DP410eHVts1wk8wRg5 ; 20171122 ; subDT >									
//	        < 0Rvp13Wk3c5fc75UJI4E2M58P8y6Uqjr4Xs4kr45zSnX3j320rq4e4vZQzCWEfjL >									
//	        < CEi7UY4WcI9nP0Bp7H0i19n7DWwQBmZ9yxvJOgd0sh790Mi68tMZW1Dan6a0UW5K >									
//	        < u =="0.000000000000000001" ; [ 000059572247403.000000000000000000 ; 000059584404145.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001631409241632695DE >									
//	    < PI_YU_ROMA ; Line_6009 ; zjGL50ef6L1wT6qdySx65c0l4FuPO8U3pE5T0RZ2WIFm8J3kI ; 20171122 ; subDT >									
//	        < CCYjl47IgQJrH7152UVtqek9Y5gA70VcLMU9N2Mmbyf5vBO8W1tQQk2X53Tk5fSR >									
//	        < NO9uqe91GRH10N1rGyoVqOi5Myb4oo288cpfkh2RRsv1UcDdr3h87hi8Kc8qJ3Er >									
//	        < u =="0.000000000000000001" ; [ 000059584404145.000000000000000000 ; 000059595809881.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001632695DE16337FD3C >									
//	    < PI_YU_ROMA ; Line_6010 ; zxuv35oB3RFnZT61lKst207jUSuuDJE9O57Nx767q8Wpy5526 ; 20171122 ; subDT >									
//	        < joE5tm3nydPi29Ja8aO23SpA22TWKt98Kr7TgYn5ufG6fLiKn9n0mc0qFBUIq7GE >									
//	        < vwAOOCC9mQlW8kfKE2hart39455fkeVoXZqQv8eD7D96vqfrPu090A48vEVrfY10 >									
//	        < u =="0.000000000000000001" ; [ 000059595809881.000000000000000000 ; 000059604727928.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016337FD3C1634598D8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6011 à 6020									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6011 ; E2Bs1p9i9gF3t368aI853otyW7Hrr0QiJd9M56y4zZ1deoA2w ; 20171122 ; subDT >									
//	        < IDYJn5r1BVWJw7a1F3u5q10WZlR7ZxyHa3ZCbO89f8e6l9V8B3xFDN9DH3k01Yk5 >									
//	        < MyttP2QWJTcQJ877ykzSfVQhaaAJyt7De39lzt179WGfy689nGNE6p56GCcHzX0b >									
//	        < u =="0.000000000000000001" ; [ 000059604727928.000000000000000000 ; 000059617014076.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001634598D816358581F >									
//	    < PI_YU_ROMA ; Line_6012 ; QsPKcTg3136je63hi5V9FJ3vxt0Bd2e4pMi5lg6wgejs90rw8 ; 20171122 ; subDT >									
//	        < 233wk1qJWa2r3kg262RtA01b3lV3i303U7KA92N562B2HsG7XlwsFmb5MzXd33Uo >									
//	        < F7nIvw00y2657qCqQV763n9zX222ZE2va3DJ17k2593hiR2rH6D8H76UT7qX671R >									
//	        < u =="0.000000000000000001" ; [ 000059617014076.000000000000000000 ; 000059622303377.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016358581F163606A41 >									
//	    < PI_YU_ROMA ; Line_6013 ; 4xMZ99Cw3p3Otmk60eA0RMgre3GV6fOle737aiiuK7VQ8BO5J ; 20171122 ; subDT >									
//	        < D3g6GFteXoH0bmiNzSkDUX4xuC3zBOmI8fw37If8xTRpSbW41sc8SaTwbkZAW6nA >									
//	        < 78s89nhDkv25r2x2xF5g9Vm8n5Nj5IH2fY06aIvAaXm0745MAudh3i0fYrG343SQ >									
//	        < u =="0.000000000000000001" ; [ 000059622303377.000000000000000000 ; 000059631960686.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000163606A411636F26A4 >									
//	    < PI_YU_ROMA ; Line_6014 ; H824xgkfUl1l1zS2FJR9I7zA8r5QM0Ovkmy9CF9gIZ4h928js ; 20171122 ; subDT >									
//	        < 1MnHnEFr7L6bYfB94e69gD9OH9n3wNc2RwS3442n886591JSYv77XzOQ4iKxmVbC >									
//	        < l2599t97O8bGCgvcDGQlb5tHx51qxP6o5Hc0Ksagbd6VPwv9waKVbwmK5ZtgBa9P >									
//	        < u =="0.000000000000000001" ; [ 000059631960686.000000000000000000 ; 000059641654119.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001636F26A41637DF123 >									
//	    < PI_YU_ROMA ; Line_6015 ; 6j7084lE86z4PIkJV5XPnA2vOeA8G1Yv8rB5cKK0MdNK8gZGi ; 20171122 ; subDT >									
//	        < F1Ok9K4BnwRfa16wUa9Ws3g92C3rwMr91ZTaMACSZR664KdfTwaFfKnJz78DIF30 >									
//	        < Y59d6o2f0h0P0XBDUWK0S33zGB0E5m63fZN7xk6Dd82IjhT28o2d303esLUizzbA >									
//	        < u =="0.000000000000000001" ; [ 000059641654119.000000000000000000 ; 000059656011694.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001637DF12316393D991 >									
//	    < PI_YU_ROMA ; Line_6016 ; nRV60vM9nG378636kO9u2Z1wdi3r7eA824n3Bx6Y57V5187e7 ; 20171122 ; subDT >									
//	        < st32AxGtWrcz22ZG8dX5Gi391F4DhExYNt7t4Dqy7Fjrj6UF87V4TMU177tzvxMc >									
//	        < T5837p5YGQ7EOWLB17sL95L5T08x2D2Nys0L04j230143USI40xqzSa5vqvWTkIQ >									
//	        < u =="0.000000000000000001" ; [ 000059656011694.000000000000000000 ; 000059665175945.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016393D991163A1D55A >									
//	    < PI_YU_ROMA ; Line_6017 ; Xt7C802D68exOFZu609jzRn7pS78GV73b75kEcyDU66AR4tw2 ; 20171122 ; subDT >									
//	        < 3loEk1r317C3igNh8LY8aiC839o5KnldjYeDALwU4jZVFqEyAAw4oZEfBLXGV5p3 >									
//	        < KPF0q5tTRWT98ZPX9JUl3jUvJDVE452JFvDV475c40377U8GWL13J9fqw7u8G0ev >									
//	        < u =="0.000000000000000001" ; [ 000059665175945.000000000000000000 ; 000059675142076.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000163A1D55A163B10A5F >									
//	    < PI_YU_ROMA ; Line_6018 ; p0Q30pcBuuqk2dnb9lRVcxr9954U6WcVOom8o46oCfP4s49CP ; 20171122 ; subDT >									
//	        < qONWypTwn12m5OEUxhGi263k64ex2iIHm59WS69ZBAmbUmIdS0wya8Dv469G7hNG >									
//	        < iEJ0QA8r8tttEMD775VOku6X5ktgVP03Z7S9IVso4HID49DFHCvnUdyW67bMPC0w >									
//	        < u =="0.000000000000000001" ; [ 000059675142076.000000000000000000 ; 000059684772008.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000163B10A5F163BFBC10 >									
//	    < PI_YU_ROMA ; Line_6019 ; AYgbGtO1HyP5pNZMp41Q79fXecm30geWm1bfnN0N0xh31FIf1 ; 20171122 ; subDT >									
//	        < 442tg0Y1P8k6jfhz5499G2xJ4Y914kkQL4117eQH1h1k4sp2e5uwMy7Xh4X1G037 >									
//	        < w721SPAkS53ZHWOT351oT6qP4YBjVydL4sIHKFG02SdHg4V0pI8hxdkJUc56uiyy >									
//	        < u =="0.000000000000000001" ; [ 000059684772008.000000000000000000 ; 000059696790390.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000163BFBC10163D212BF >									
//	    < PI_YU_ROMA ; Line_6020 ; 3MnVbm54Q68XBTIPMWr7vq2lcdv27T3QydG4eBxs54J1LY3l8 ; 20171122 ; subDT >									
//	        < hAJ43339qak32h3zkcUfQP9x8M4aQ33M49efPk72DXwKjRM4V8I1Cd80hgPK50y4 >									
//	        < WKyOv27RiVFGDO3c1sb00QJd6h5m6Y1V4tGL5x63IrFr6SrJeme822x5OZsI2SWr >									
//	        < u =="0.000000000000000001" ; [ 000059696790390.000000000000000000 ; 000059705928459.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000163D212BF163E0044D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6021 à 6030									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6021 ; m909N953luRqKg286rY39cFc1Qb9Wfo6dMD91AawuDMT3urVj ; 20171122 ; subDT >									
//	        < ThwMUZlaPGPPcRQFAF7YFJ5BY2XZQKy29X6aGRV78XGNA20DNj3w9O7e4bNoz8l0 >									
//	        < tZf0J7jzIv2bN5X7ZF6MR7vf3bzmP7VfKxVu8h9Eka6SN8Y7LQ5r7Y2l27D6VY18 >									
//	        < u =="0.000000000000000001" ; [ 000059705928459.000000000000000000 ; 000059713586871.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000163E0044D163EBB3DF >									
//	    < PI_YU_ROMA ; Line_6022 ; HUD7tnUP1WRptWiVY9c289ZvDPNpkHQYq9O4aQM5O735syT0g ; 20171122 ; subDT >									
//	        < B0704d5zE680aRG11Em89YZX3r3tap0YSePikiXgxCw1BnJHc96ne3Wp0YY5iHU4 >									
//	        < 919Jp1Gi3LMlI2g3RS85Hr3d0C24Tmfg8D3uVshhUl2aikX3Kow6Qf6gacCKbAXT >									
//	        < u =="0.000000000000000001" ; [ 000059713586871.000000000000000000 ; 000059720925320.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000163EBB3DF163F6E674 >									
//	    < PI_YU_ROMA ; Line_6023 ; BYaMI13rvOR5kf9xC2321BmFH7UWA4SGNJ474om15f4VKXCI9 ; 20171122 ; subDT >									
//	        < yTtrCeyMi6liz6v1um8te64k1H6A4D4v7lxX5LAM4i9B146M8P5nt14V46pV27A2 >									
//	        < d5blLUG67ruE2Vs5DCUFe96i5I2z4M8Dp1XV0xAw17hynRLfd3G8s3h66481jejw >									
//	        < u =="0.000000000000000001" ; [ 000059720925320.000000000000000000 ; 000059732368009.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000163F6E674164085C40 >									
//	    < PI_YU_ROMA ; Line_6024 ; dSONB51IzS813zzz4lUXjghN5Wy2RQY96738aPxA598cqe07e ; 20171122 ; subDT >									
//	        < VivfN9KiHb0sS4vvVF3LrO93GLf9nlokOcpTaYDubXnV05228r4yYm32GIm1UdV8 >									
//	        < fMdKcCH913L7663a5ob00hgZJos54hKF83L8g3X1OvK3UvOH5drC0m837Eyhb494 >									
//	        < u =="0.000000000000000001" ; [ 000059732368009.000000000000000000 ; 000059746862362.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000164085C401641E7A1C >									
//	    < PI_YU_ROMA ; Line_6025 ; h8w5Q8FKHgXKwRwe30kSh773b4YH3dg4FbU1cRBfHR7y81vgo ; 20171122 ; subDT >									
//	        < Cte48zvwTZxsL0tpv54GyuC88n2y5kV2LApAi0YZ3q5MIOot8RQ82Rv79a2l73AU >									
//	        < p8S85207gswk0GzQM0G7a9Gub89Ky94Gy58ihIDOXFbolIimulBfduQN4X3xWt2m >									
//	        < u =="0.000000000000000001" ; [ 000059746862362.000000000000000000 ; 000059754259628.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001641E7A1C16429C3AA >									
//	    < PI_YU_ROMA ; Line_6026 ; 9cu7FZ8n1BZ94jCD7CRfyP05cRL6dY0u0NAcqKZd9uN1Spy8S ; 20171122 ; subDT >									
//	        < 015m6497zxt3Ni45LN7ULsQK2JbDD2mJ11baV77RhAns8fAel45B7VETA5JUd67f >									
//	        < g0wXvgsTtiyfGY3s1m3GKwoCFWLKO1IsJ7mdj9Zc2AD9EFUy2vl1xe60V1kgxMe8 >									
//	        < u =="0.000000000000000001" ; [ 000059754259628.000000000000000000 ; 000059760585938.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016429C3AA164336AE1 >									
//	    < PI_YU_ROMA ; Line_6027 ; lW73vtKzveCHslP49R3b7ti8OO9ZqCaoIg304VKnrZ007pk43 ; 20171122 ; subDT >									
//	        < NKPv51g1cL8k8Et2n0qCp59H735b7Tb23tJd9ppy372CN6V3KzO913V5eOLy2sMF >									
//	        < vAzsKv711LIwm1RnE31827pllZ7oQXr1u0oMdd2hGNs184dY23KI5hx3Z7Jy14i5 >									
//	        < u =="0.000000000000000001" ; [ 000059760585938.000000000000000000 ; 000059771695190.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000164336AE1164445E6F >									
//	    < PI_YU_ROMA ; Line_6028 ; eky3RAj39z80iramzCGyVDkwW9P1iclg6O86305904KWkU460 ; 20171122 ; subDT >									
//	        < zQRxQMrHO2AdZbL8N594BJq241zatNm6j09mpJlG515SaSiCOEX6cxch722eWmvW >									
//	        < FaD5q9byDbX60nQZ7I4yXIh8nOK0x06JMUXF3mTn1T049Im2d4FuzadOdcil03U4 >									
//	        < u =="0.000000000000000001" ; [ 000059771695190.000000000000000000 ; 000059786028234.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000164445E6F1645A3D47 >									
//	    < PI_YU_ROMA ; Line_6029 ; Xc9SDYwYWc1u6FiGe92w0HSVzBHFl1hsU326n2EBRR4EylBE1 ; 20171122 ; subDT >									
//	        < 557sDL3Vp773HCo40b013H9wH09z8Palyha2TLs84uCPNr8ya5yLEAw284I69A2l >									
//	        < BWimk39LjDbxy24oLgFnBd2D710t7w2es400UDvTnTwDYN1f2ioj2963GnQA96Zk >									
//	        < u =="0.000000000000000001" ; [ 000059786028234.000000000000000000 ; 000059795610437.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001645A3D4716468DC53 >									
//	    < PI_YU_ROMA ; Line_6030 ; 1EAv9bzOTGcd9f120vd5gOo178gx0spma7X4LT6PTau4A4C6C ; 20171122 ; subDT >									
//	        < UaTKHmsOMtGtr31Nl7Pb1eXJs0PTz4w7n42T3rio3b0Kh64VoYQcR0794et034A5 >									
//	        < GLI5eqkHX66htg7U28T7c0WIXENTNILonap6XO9ZSzc2S5ssS6hYtn9c0g8yvYEu >									
//	        < u =="0.000000000000000001" ; [ 000059795610437.000000000000000000 ; 000059801535270.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016468DC5316471E6B7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6031 à 6040									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6031 ; 7fJL07YsG8Ia5338E0tMAz6dAEMvf9RSDSI59G4qh8Pw6HB5n ; 20171122 ; subDT >									
//	        < tn3aNaSlLc7S8NT2magrxaom8138as57Mr6KBvX3jRj08mMAAl1F6aW0ZU2S3nWw >									
//	        < 9q3si7BwE3bAW9Pt13Aq690MaI16ssj5NZ5J3IK1OmYv7SWJ3T9D0G737O7eRVWh >									
//	        < u =="0.000000000000000001" ; [ 000059801535270.000000000000000000 ; 000059809668033.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016471E6B71647E4F93 >									
//	    < PI_YU_ROMA ; Line_6032 ; B17C41iy5pE11Lq5IWbJ4k194LXuPy8HV3B3JX0Jf27Iny2pu ; 20171122 ; subDT >									
//	        < mBSjDI85A01z603mvf3mG4xOaTM8tSaNRILefHO048UQ444LsF8cLr5FX003Jd8G >									
//	        < kdoJ93p0M69R8k1H5DAHP42DMAm0ev4LScgm9bx6I5Kv1y5Pz9regcaG0bQh8h3E >									
//	        < u =="0.000000000000000001" ; [ 000059809668033.000000000000000000 ; 000059818887988.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001647E4F931648C611E >									
//	    < PI_YU_ROMA ; Line_6033 ; le2xF2YD9yvixNj30JuyZ9qVCwTOwAk151aqP2cJ06puclgn3 ; 20171122 ; subDT >									
//	        < h5oJFIWnUXU63mev8NW6Wc5cYv6C1V00WS14Q9tQuN8wgeah5v2q4vV1v1f0UJr7 >									
//	        < kIRD69j2313Ro1734U1IpYW6p2YMz7SjANa77a2nZ6Hd2E84JqSN69XdaC69f2b2 >									
//	        < u =="0.000000000000000001" ; [ 000059818887988.000000000000000000 ; 000059826909396.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001648C611E164989E7B >									
//	    < PI_YU_ROMA ; Line_6034 ; FU4sJf76tbl0X7lA5umjD9i56u1oK86vF1r1ck5F8dOSnsUny ; 20171122 ; subDT >									
//	        < 36y278086uPl4OMg43e3V8HXER283a25XKX7cewkT4a050v91uZJg5X64uB8N1u7 >									
//	        < ocX7QU96AD856Q356k9xEkhW9S39B8y5BU6u4f6C3tfHWcrxE8hX17tr9ij729VZ >									
//	        < u =="0.000000000000000001" ; [ 000059826909396.000000000000000000 ; 000059841388644.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000164989E7B164AEB670 >									
//	    < PI_YU_ROMA ; Line_6035 ; 2pMeFmLprWW6KpmD4j8md01oKF2b5KvZ88JN1otRf9IZZkuxK ; 20171122 ; subDT >									
//	        < 25nnp316sUWP7N0D69P82QUstJ882MP44kKaH5EMwIq0kS08M8924hMje7mEuZ71 >									
//	        < 9B1Jg9z4XUX3tU409k9gOV887oOKdFC403nOZ15hf38Y39CSxXRB5d5r1g2l7lVy >									
//	        < u =="0.000000000000000001" ; [ 000059841388644.000000000000000000 ; 000059855361851.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000164AEB670164C408B9 >									
//	    < PI_YU_ROMA ; Line_6036 ; Vub2as869gN31M53E2t913xJMttg7v5F0v0J3c39UP4by4Pgv ; 20171122 ; subDT >									
//	        < aWxfIfYU474mRydat14AUxt3TgcwzPe02o6c6Bn38w6vY86KakNQofW0nju0D8z5 >									
//	        < he448lCZil1BbIM97u2oeTJ1RavJDCe65tvpjKBcEj6CXYU7JnE1G3L3Lp5Q8US8 >									
//	        < u =="0.000000000000000001" ; [ 000059855361851.000000000000000000 ; 000059864212735.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000164C408B9164D18A19 >									
//	    < PI_YU_ROMA ; Line_6037 ; WV3YmBz58Hm53D6GO6y46Sr4OU4XNPW1rt7PStMx0PA15U06x ; 20171122 ; subDT >									
//	        < TO65Y5eSEtPTu2x35be69h5e7hlGfH7fayec2bxQZumo0u9t70Wg235ECo292dLP >									
//	        < 40rHPtSPeh6nCbEBNsiE4KM53ngK9x83P1y83B4bymsAEco35Li8c0JpfmPtfKMY >									
//	        < u =="0.000000000000000001" ; [ 000059864212735.000000000000000000 ; 000059876209824.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000164D18A19164E3D876 >									
//	    < PI_YU_ROMA ; Line_6038 ; onlywU0900HD636JX20TED0Thc5lIJ4LrOmPN0R1DL15i8d3x ; 20171122 ; subDT >									
//	        < axfrul1PjHi7seF69U9RmaQ0461WHB701PUReV2hakV6R2aAUtL3B0SQLcgD6pof >									
//	        < E044H8MN245192oUf9q41Ls58y65T6YVwk9eq8bBwHtmT0HD89rE3w8zyIy42mjP >									
//	        < u =="0.000000000000000001" ; [ 000059876209824.000000000000000000 ; 000059889174284.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000164E3D876164F7A0B4 >									
//	    < PI_YU_ROMA ; Line_6039 ; v63N8N78OUOia6NmywXW1l0VIV45eSF42JjpjT69mghX3ZTeg ; 20171122 ; subDT >									
//	        < t8q72xPZ6BiF0K4ZLcN3GuZgl8vvY5t9t458QYgJQhofoV6D48iTLAYj2TSr8YQT >									
//	        < EmM58u68q02nxOYQzgMLg8u73DGlAmR4285juom2OCDQUC88lhp3szf11zlqPJXj >									
//	        < u =="0.000000000000000001" ; [ 000059889174284.000000000000000000 ; 000059896778933.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000164F7A0B4165033B45 >									
//	    < PI_YU_ROMA ; Line_6040 ; 70Q0TDLj2yxnLo9G6H26l2l6aF6lFdGXjJ03g7AmQ830H10jD ; 20171122 ; subDT >									
//	        < W58Rf97Rd3ZFV1SJFFueM2HNm070Tn4I4vT044esbDH96is0j63dFn4lSIS967D5 >									
//	        < b1wmy8qeqf4Z3pVh77gBx5lgmit3f7tWtqxta7B29p277v8h3367BdvCBxuAj85y >									
//	        < u =="0.000000000000000001" ; [ 000059896778933.000000000000000000 ; 000059908214342.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000165033B4516514AE3A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6041 à 6050									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6041 ; 01VfT9754zM3lirvb8IlN7i495640esqEwF67CuXJJ431kOlu ; 20171122 ; subDT >									
//	        < tn6EMVcetyZ3z8zxaugoa4RHs0mc9js4xkg4322J1X7u4i9Wj5I4KifF36TQ0314 >									
//	        < 404ljv765hpPuvG0IA3AM899z72cF9hDsjSD0Eo0wdSuKgUStB1pz7I7D66X9Fl5 >									
//	        < u =="0.000000000000000001" ; [ 000059908214342.000000000000000000 ; 000059919589006.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016514AE3A165260974 >									
//	    < PI_YU_ROMA ; Line_6042 ; A11By34lmt2dCgd55pg1239dPJ943dAf6zKdSc493551kg5E8 ; 20171122 ; subDT >									
//	        < 64bEJ1atHjVz8n0xr03206JlZ38Z8aycg9tMDH26wvyzWIvfJ003L4Tn92t86h5t >									
//	        < Wv07xyFttP79t9hIHL12Yi9E5EY2PmHNe4aPdX33yp1zXTilY7ut0l0SonM0yXhY >									
//	        < u =="0.000000000000000001" ; [ 000059919589006.000000000000000000 ; 000059927876732.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016526097416532AED9 >									
//	    < PI_YU_ROMA ; Line_6043 ; V82pdL7k9Z6RRQmxcN1P5T9LMx13th666T2j9m5IeXu8eL5xi ; 20171122 ; subDT >									
//	        < tddB1Vb9z2dSifpkS41KCo284aSie5x46J10GD9RuI3ct27rI0EBTaX3Ri29Y8UT >									
//	        < t0H5oBDzNtoWKWNVYRdD0Np7Rxpxt3NdYy5ZC0gw5gd0uUCSmaWrFL1hE35k7v9c >									
//	        < u =="0.000000000000000001" ; [ 000059927876732.000000000000000000 ; 000059942211339.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016532AED9165488E4D >									
//	    < PI_YU_ROMA ; Line_6044 ; 0B0vxC7D1WX3t01O98Sh646r6dHZ7Sth3eEvQUxZ6ugC8XyJ7 ; 20171122 ; subDT >									
//	        < oUa6n390NtBgljg4m5H5g63Kw7TXeO0cL7s7GzYiovuU27LxAEt2A780n1OZxgZh >									
//	        < fet6c4g1n4yPWKNQDjxcXnC90B8ug1yw3qKpcd556n3L04gMtP6e4OXO4fvozEnU >									
//	        < u =="0.000000000000000001" ; [ 000059942211339.000000000000000000 ; 000059947900548.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000165488E4D165513CA6 >									
//	    < PI_YU_ROMA ; Line_6045 ; SWxQ2NciolJfk3WU8ESAr1Av0H4Ak98Kr8MfeH8S0jTjd21Uy ; 20171122 ; subDT >									
//	        < n22E5gM7o5nGNmQpQ5D3u9RhHK9sPCzc3sXZQ4L8ACL8ePQScVAgNyhp32vprLVI >									
//	        < 6vW0i4f9rVYxBoBYlS0J15iRlfo0v6pcv7tWh0rhM478N6z35JRWrDrN4wye0k0C >									
//	        < u =="0.000000000000000001" ; [ 000059947900548.000000000000000000 ; 000059960774356.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000165513CA616564E17B >									
//	    < PI_YU_ROMA ; Line_6046 ; lO2P551xT0MQGe5Ub8l9D64unqM3dQl9J6r9m9ZNkA9k1j9lN ; 20171122 ; subDT >									
//	        < k7t6E10oQ2126eQ3IsU23t1CtKgqY5NdA7NBF9YK25TL9Ee7HsgBf3eJI9aPBT8g >									
//	        < gchyrO8pMXwB124oPKydn8HxcPwnsq5XS9lIGMZ6d8z14Hb40O8qs586i5BTXb6Y >									
//	        < u =="0.000000000000000001" ; [ 000059960774356.000000000000000000 ; 000059973504241.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016564E17B165784E18 >									
//	    < PI_YU_ROMA ; Line_6047 ; 6o78aGCZaXM7tQW2VVdYs82vtq61J1MC2T15Vf83C7Az2wH36 ; 20171122 ; subDT >									
//	        < KB09C4w3pu8U0848G03L6Urv8gW4511LDz97mI18CD97BOF5ZECKV6M2TNsFz6sa >									
//	        < ICb8bFbX1ypw7ZQ3P518ip0n5SzE0ROwctc30I7MU75LICieHT7x7qq5e0W5645b >									
//	        < u =="0.000000000000000001" ; [ 000059973504241.000000000000000000 ; 000059985286410.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000165784E181658A4881 >									
//	    < PI_YU_ROMA ; Line_6048 ; 8ODex15D0g14zQ7zoocH5HuO3yhHzglty2fC1bzsmzR1MKY9X ; 20171122 ; subDT >									
//	        < nuT74Q6GQVimnzPdDAUodYf484173jU3q7ORCq9AKFo3714U7HUr0ile0yqmmRiA >									
//	        < 3m14s7RhEreTuArB7nOj1Q9akiQxLcJwC355ZvW68do6612kQ00atO87u42UL36N >									
//	        < u =="0.000000000000000001" ; [ 000059985286410.000000000000000000 ; 000059993005853.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001658A4881165960FE9 >									
//	    < PI_YU_ROMA ; Line_6049 ; 7I3wBw06wVU0u3NG8iv120Yxlk7neK8wXP3Gzzio4kyP31dB7 ; 20171122 ; subDT >									
//	        < PsNJCA8oE5vXd36mi7ABvBJ606166tdgd6U8L1RNW87Eyc3o22d0a1CewKcoh4z1 >									
//	        < 6npH83LKcV5K669YjD5L3QYmGWvvmDs87an30XOi6MaB4tOBDFET3069974P6bm7 >									
//	        < u =="0.000000000000000001" ; [ 000059993005853.000000000000000000 ; 000060007718922.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000165960FE9165AC8334 >									
//	    < PI_YU_ROMA ; Line_6050 ; oA5Mo0KpcJKE7cc25fr6FAk7TyKJAnu9WCK982h1Yd46nGs7m ; 20171122 ; subDT >									
//	        < 2F2w3G5W79gm43LJGT5pau4405nDw2e2477Q3j7i15yIfCw5IKNrK3i45j3G1l92 >									
//	        < A7mMKzcG811DkXv6ghu07S0sS1pG5Zw58hHPcBvwMtr3Pdm4GT9706X0090HFoy1 >									
//	        < u =="0.000000000000000001" ; [ 000060007718922.000000000000000000 ; 000060014976368.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000165AC8334165B79624 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6051 à 6060									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6051 ; wy3dT4Jo6EZwN2Rt2NyD9apNZMgL0NxA0H7i7CgDM4UFJW7L8 ; 20171122 ; subDT >									
//	        < 7C97v61rUY6L4iMBV7HrO71n2L603n7s62utwi0keBj965I6ZUMqK9uv8nULZVz2 >									
//	        < hVNT4zjTPYeE4s1y455dpV10m5zZ35a5V5Gv2BJ396EHY369cxRfAX37QHAsir35 >									
//	        < u =="0.000000000000000001" ; [ 000060014976368.000000000000000000 ; 000060027460662.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000165B79624165CAA2D2 >									
//	    < PI_YU_ROMA ; Line_6052 ; 0NnARqLXZ7DVV3xdAz8qM6K8wmj14F66pO9s6rp1Ss4s6jO34 ; 20171122 ; subDT >									
//	        < wbqFTJ7MHJ7iO5ahMFTxxsKl3bhRB3Hi8N5WvNAfd7550FU15Y4G4hKy6rs6Fqf1 >									
//	        < kJ65Q7V7eROCyAt5cEJhS3r9O57AmfTR35F5aU0S4E8WKfXVWrr9398lsdtZH76X >									
//	        < u =="0.000000000000000001" ; [ 000060027460662.000000000000000000 ; 000060039903785.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000165CAA2D2165DD9F6A >									
//	    < PI_YU_ROMA ; Line_6053 ; 5NzlrHs6W6dYw0nag3yTPacJL2US2PG47q9DO4XKg174YUt4s ; 20171122 ; subDT >									
//	        < I4Vnc5xr84JbU0fLWKppWd8OjKw6593xUavvNZi864Ta9R0qXrm89oShrLsG0n0X >									
//	        < 342vUIrKA1mgsw2VAkA7w7G50lsX5vHYGkWKBA1TO684f361WIV2aFgEX10JyhhA >									
//	        < u =="0.000000000000000001" ; [ 000060039903785.000000000000000000 ; 000060051918240.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000165DD9F6A165EFF490 >									
//	    < PI_YU_ROMA ; Line_6054 ; hz873MsbU2f2Na45FGf4vK2i3yYAN9IG6tx323lWpM1a3aSiP ; 20171122 ; subDT >									
//	        < 511v6929r58EfW1yTY2BHw3474Tl4s8X1rO9TvkSh77MgN97i8m6xzy3kcX22ICx >									
//	        < 41304O21bFB3v176Q8SDM2WYOwC9ey03285EQj2Q8oZ789zaRrtYDQX3zo3qSIu7 >									
//	        < u =="0.000000000000000001" ; [ 000060051918240.000000000000000000 ; 000060058672488.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000165EFF490165FA42F0 >									
//	    < PI_YU_ROMA ; Line_6055 ; 1MxaJYb3F2qjfC752HazhdOdcS9Q74vLN3qHXGW668dLHi7GQ ; 20171122 ; subDT >									
//	        < oKP0y7NFa2lY4tWauAtjvDwdqs8UUK2HZP2u3AJFxfjFhflqbs332Fh80R3Hg5G9 >									
//	        < DyVzuj7wOfQtUmH5ZI2WKDzr83U4Z6Ejt1wOePXW5dN6JGVBV0E1947ogir22rT9 >									
//	        < u =="0.000000000000000001" ; [ 000060058672488.000000000000000000 ; 000060067007257.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000165FA42F016606FAB5 >									
//	    < PI_YU_ROMA ; Line_6056 ; anKaYbsgJeSG5nwVrGe7BpBs1934VpDUwBU84tYvIC4qnBJg6 ; 20171122 ; subDT >									
//	        < t86HNVl6qb5xbyAXhefH5UFACgtRF033VB6M7b6c6257VObWzCT59gMYIIn7X9WA >									
//	        < 2KurXtfoiZ5tiRL6lv63kEGv8d671w79J0jG4ums5atXK7Rzqi1J9L5nb78oKJ9K >									
//	        < u =="0.000000000000000001" ; [ 000060067007257.000000000000000000 ; 000060077941830.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016606FAB516617AA07 >									
//	    < PI_YU_ROMA ; Line_6057 ; jW0CuI2pT6BjHyMc95bic1Tv3796ua2q0025Ke2HR4lig0uxE ; 20171122 ; subDT >									
//	        < 16712K2R4P2RW4jlQHKS9OaM7zstj4kU0E52byNgMV0M2k9Zf6NGssW8e6wK5YQX >									
//	        < Ry3f00qx2Vq1D8GXlT54fsrN93qu00P9DzpNfMsqFZ8T9FESe4B9DAm8480d3R5r >									
//	        < u =="0.000000000000000001" ; [ 000060077941830.000000000000000000 ; 000060087849623.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016617AA0716626C842 >									
//	    < PI_YU_ROMA ; Line_6058 ; Enjq7v09Fg17K266DNJeuR6jcnXK98z637YRTzC3j6mbeh9m6 ; 20171122 ; subDT >									
//	        < sk2BZSHp7da09203Y15hLRi1G7ONIeAFaKg4oWm9C39KoMWhst4tm23FS9kdjByc >									
//	        < 9PL726W1hOlo6s0kr6N0440gtb2NdxwdndkJ62WX34GYVsn5W6J4i2Gr6XmO43b8 >									
//	        < u =="0.000000000000000001" ; [ 000060087849623.000000000000000000 ; 000060101565348.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016626C8421663BB5F6 >									
//	    < PI_YU_ROMA ; Line_6059 ; QH3Y3MvPbvqd5uEevoUEmH7ONTupABbGNzbvY6q3tBwp4zI19 ; 20171122 ; subDT >									
//	        < jiz2YJTcphpxP60DWHf9u891D2p6h1DdUf5V2wQhaSHK9ZrpZ9fP9kWqq4u6K4Tb >									
//	        < OPp9iMn07M80zAChzJ09Aq568bX0P1i438v1KDVkhe8JPKif6U37YN3q80yFMr62 >									
//	        < u =="0.000000000000000001" ; [ 000060101565348.000000000000000000 ; 000060107721121.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001663BB5F6166451A90 >									
//	    < PI_YU_ROMA ; Line_6060 ; Zx9u0sJssuMm8mGRImwbzI8yAVUz7S5ow5XTrU83T80jN4W8O ; 20171122 ; subDT >									
//	        < 0S3W34mB84G7Zv4m15ezH576NrMP2NfzWY611tkSN86fK5l6Q6FJs9V0APylyDNJ >									
//	        < hyLN41JqT184Dw3yI15JmwlQoZ9b5neU5GOyUK3LiUH0oEoMM4nJa0Rq0P4Bji2C >									
//	        < u =="0.000000000000000001" ; [ 000060107721121.000000000000000000 ; 000060115450570.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000166451A9016650E5E1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6061 à 6070									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6061 ; 4Z0O1F4oogFB8YmSy1PeOpw7W38f0zCHRY4e12807KVr7408K ; 20171122 ; subDT >									
//	        < SsV3F3E5Ti8ePb4iekmGwl05zTAbCbH8702wKsq3joy302YZGtATP36H6V65UioU >									
//	        < M34Q4PlOPpBcRbLj4SOrBQ6bSaQ81L9h5t35fqi2cr0bPKgoN27GQO92OF486lQK >									
//	        < u =="0.000000000000000001" ; [ 000060115450570.000000000000000000 ; 000060128070400.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016650E5E1166642780 >									
//	    < PI_YU_ROMA ; Line_6062 ; grk53vW6DngGXvdNq825wgFa638D8xAW9Z8EMw4iG02eL67b9 ; 20171122 ; subDT >									
//	        < 06GV647m0ia1d64Y7J1WFxBSRLXE9M6F2K7d9uSCY660NlYM5nAoy7Bwtmo6i3Dx >									
//	        < 1TyDcEFxJWCSP6HZ299UqQhv9a9wVIh25UL5f9NcZ3m0cA1hwWu407abgJwQevc5 >									
//	        < u =="0.000000000000000001" ; [ 000060128070400.000000000000000000 ; 000060140489217.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000166642780166771A99 >									
//	    < PI_YU_ROMA ; Line_6063 ; xZeNK45xmv1nRUlO96M0s8z83C8u4Y402Ci4EI0kF9XExV874 ; 20171122 ; subDT >									
//	        < zzC9WdFhtlo2d77eZgD4kkr70Z16wj83a389NSFZ3RfB966R0tVtO7d78Wjc3fA7 >									
//	        < 2680Y3T6BAfCuAjZ317FX6kr2SCYT3Ta4GA0DN6tL1m2kg4SbifO24X5OtWhrZ0M >									
//	        < u =="0.000000000000000001" ; [ 000060140489217.000000000000000000 ; 000060148948966.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000166771A99166840330 >									
//	    < PI_YU_ROMA ; Line_6064 ; no9va83D98Wn6H3Brj2M1VJ1kzeX4D0IuSPg1j6oUol7mA4NW ; 20171122 ; subDT >									
//	        < 45nWsDs9v80s7x4I7oBQ5D12EKd9nrVm1zA6vB9F786V8sc2HGSLcJU94uzWJ1U1 >									
//	        < 20Gb31ooDNb6rm36AqQQg6681rlTYX6RNA1T6FKXTn9228H7Ya4RLC60f5UhgM14 >									
//	        < u =="0.000000000000000001" ; [ 000060148948966.000000000000000000 ; 000060157944931.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016684033016691BD3D >									
//	    < PI_YU_ROMA ; Line_6065 ; XK78gCMmh3OODUbGk0P0hz4Gyw3uYSjIWkCuXw6t63yU5V75L ; 20171122 ; subDT >									
//	        < 72359u801BQkWcWMd0NWhp4G7A8SgRr48zUJ9I9ivbD5ajGb43D8A0Oqo26P2KX6 >									
//	        < q42ZTB8z41swZkU6e7743iriNu9W396KHiXUVHDxmui9WpH6zjup6tx2m2921n4S >									
//	        < u =="0.000000000000000001" ; [ 000060157944931.000000000000000000 ; 000060163670668.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016691BD3D1669A79DA >									
//	    < PI_YU_ROMA ; Line_6066 ; 3Ks4cmmBW9LNrzMqGciUndG14Aqyf4DPt7Ho17x9IMlHgwl7z ; 20171122 ; subDT >									
//	        < n14Xdt9bFJUUF7PJ86tf5cR541nZK80sXxkTqo4p8W7gh2ets49CKbWSN53O7st7 >									
//	        < QUNR84680V7651aVMh7yF4318hp98759jS87R9FIgB4CJHbox5j9KSffGUx6RG4h >									
//	        < u =="0.000000000000000001" ; [ 000060163670668.000000000000000000 ; 000060171516499.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001669A79DA166A672A1 >									
//	    < PI_YU_ROMA ; Line_6067 ; 0xwn3Hs115aIEp440fduCSuV5X9yv3rG16njyTFJPesmwX2yW ; 20171122 ; subDT >									
//	        < zRe13iDa0F1LVEi80QJaY3905x5AhG8EAjCvcSq8qKZKkN91Fbn1fmb9W1crjyJq >									
//	        < AA405EKW8Dap40lktd7HYoXFxBtUs2I5ZIqA5RG6zpSle3g68CZ71z1N2uFotFUw >									
//	        < u =="0.000000000000000001" ; [ 000060171516499.000000000000000000 ; 000060183828600.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000166A672A1166B93C0C >									
//	    < PI_YU_ROMA ; Line_6068 ; 5jtP2MwcH8h183LIS9RG9eoM65R9PFo1u9tKrz44xfP5XME89 ; 20171122 ; subDT >									
//	        < s2t19kz69oA2mv7GZL3xZe653SHq9QBto83xkp7LYbO1m63w5XRu4e3v4l03W6Wn >									
//	        < KVey5H7S0X6TLUqgF0eMzlHS7t0uunKP86Vn41n0srP4i8iI8fx49P5ncLBNyuhf >									
//	        < u =="0.000000000000000001" ; [ 000060183828600.000000000000000000 ; 000060193527344.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000166B93C0C166C8089E >									
//	    < PI_YU_ROMA ; Line_6069 ; k69x4dNcAZFzTAvw0G11WT256dr4OjL43v6y5fyx4nk2WffG0 ; 20171122 ; subDT >									
//	        < 1D7uKFx1RI6r2q7we0Lur11LmiNq18i66MNZsiEHNz75cllo5kFtt7am9066UN7a >									
//	        < 3VfuKeJnixyYcSYYD5QF62Tbae2h6r39CBptqT76G7zFX6uwfcDGliRBAQf1peAM >									
//	        < u =="0.000000000000000001" ; [ 000060193527344.000000000000000000 ; 000060208402852.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000166C8089E166DEBB5D >									
//	    < PI_YU_ROMA ; Line_6070 ; r56T4jn57WCq46V9mY9161ew9ZvF9z236fR8fJ0i7Qtk2L20L ; 20171122 ; subDT >									
//	        < 3f67V3IYEJ4gG9Wv21UTtLkMadG8D4jiDo7XX0Ec3hMIufS5Wk4Ca9sN613FuD9R >									
//	        < 1lpzSI455DU3Okh9r9UhR2oTa9hM578vwYkjRQVv2rM5Vk5h8JVckkOqSQdol56S >									
//	        < u =="0.000000000000000001" ; [ 000060208402852.000000000000000000 ; 000060220209546.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000166DEBB5D166F0BF5A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6071 à 6080									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6071 ; q78CkcsLHZ3h9ka5z6J6V0pGh4fzyufPP2g4ah08714aqNFyw ; 20171122 ; subDT >									
//	        < YW4IA68Qy628mr27U3J49yG18R63m6QmKjWQalHX96i9d0e7npwapXQevsq90368 >									
//	        < s247yVM6aBdG0B30kqu08BMA27dH7D8Qt6SG1wReddUmJ4SbWr0NV7okoHKXb1Y0 >									
//	        < u =="0.000000000000000001" ; [ 000060220209546.000000000000000000 ; 000060228670848.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000166F0BF5A166FDA88C >									
//	    < PI_YU_ROMA ; Line_6072 ; EY9BiUR07l68orredV0pw81E80lv777TJWJwQZ3AW3C6abCv1 ; 20171122 ; subDT >									
//	        < 7O2HjgZIK9F861AEG909m3HLD5u8X3FuPXYMapa1d8ZQBQeO201PNQ91Yr2BMfsE >									
//	        < C3H8VO02L9u51575a5UWc89NGcYMULmX6oVE1Z3H9WboG10O9B86R2M2bhbmoS3l >									
//	        < u =="0.000000000000000001" ; [ 000060228670848.000000000000000000 ; 000060239392110.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000166FDA88C1670E048B >									
//	    < PI_YU_ROMA ; Line_6073 ; Dj9k5j4ro7a3pk2teM43GrE0192gB0DDFVksjd5G4imL2V2fz ; 20171122 ; subDT >									
//	        < 5xJlnjn4BkAAt7PD0py3GvCEdE2uK52L0Vmhqf1T9VD9fQHIjhH6K9A6y5ahG69K >									
//	        < 3ju4JHaOa5Za9r6Sm1YeS8qJvgSejPsxkJzvg7A422x7u6qGr9RbZyIYWicV23m0 >									
//	        < u =="0.000000000000000001" ; [ 000060239392110.000000000000000000 ; 000060250938718.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001670E048B1671FA2EF >									
//	    < PI_YU_ROMA ; Line_6074 ; 3R1y5Q90H8PGdRCp07k6OdQ4Bz26BYZGw3yJ7RGa6YMsUV97y ; 20171122 ; subDT >									
//	        < i0VlX4Mu2sBGxfs38Ar4T9xuLWfourzE5Q7rD16SOCiAy6x1kTYrMGGE7l90d7Md >									
//	        < U4jigIDsuSPSW1xt75H34YH911AYn8yo2PSPFBU90MXh9g9L8cHpkkeN7JRI5z3Y >									
//	        < u =="0.000000000000000001" ; [ 000060250938718.000000000000000000 ; 000060259337000.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001671FA2EF1672C7384 >									
//	    < PI_YU_ROMA ; Line_6075 ; 0ovc327cD87c3lX05GyR4PF600oMs5Qp42aVSv9A5rF6C7d3k ; 20171122 ; subDT >									
//	        < yqq4c292l4KS1ClE4t1Q34SXM0srP11wQAUDBDWADmzGY0sgK515C64WUOa8WU2p >									
//	        < Ii3eo9daMd5r4wiJt7sJn3zvp31HnV5Tf8z1JA5f11T0itIzQNoYTWIrxww3Sg5U >									
//	        < u =="0.000000000000000001" ; [ 000060259337000.000000000000000000 ; 000060265980383.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001672C7384167369696 >									
//	    < PI_YU_ROMA ; Line_6076 ; 5xI6XTzm1i2U63lT8tEAq38OYpm44XpgkTgH39363e2uXgHV2 ; 20171122 ; subDT >									
//	        < nTi8F6O7861R059K6i9l2278zCGTutQpUO583kVB07qD5C324Iv6T5856TNLs138 >									
//	        < 8PcM1v81HKyVK1A3yE8N6Z2bm8Y1ej64rF6LH258hDc4tO2bXQ9zCxHO1Tyq1tnm >									
//	        < u =="0.000000000000000001" ; [ 000060265980383.000000000000000000 ; 000060280670975.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001673696961674D0119 >									
//	    < PI_YU_ROMA ; Line_6077 ; vHALghLCPtNDRwZX296m2d4Gw33g2Kd6956I6m5MxZZKgcUh1 ; 20171122 ; subDT >									
//	        < CZ7iGYwt59J22xkziWBBZg08niG91q2wS5Y3Qz4J1lm38me5iR5Z7jh1mLej94Bm >									
//	        < GINph7GAry0XSdsOu707Kh88h4gZDahGBQ2d13NS5DevaZb9x6vp84ao7b7kw02H >									
//	        < u =="0.000000000000000001" ; [ 000060280670975.000000000000000000 ; 000060291961440.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001674D01191675E3B70 >									
//	    < PI_YU_ROMA ; Line_6078 ; 7nZP5n33tR95F06Nlh8QaGh94EdzB57T4MsbViB0JnY9IPnke ; 20171122 ; subDT >									
//	        < 5wbt4N4uYR6A4qPtyHx0QLnZ13i1o4QoeTW68eYVzYL0Zm8tO5aIa64JA3ds4E7D >									
//	        < P9vF6twjEr5ARZx5g7pr42Vo7lwMfm440Rn0r8izBr6Ggf3rr4dmSOd5M5t27Wdn >									
//	        < u =="0.000000000000000001" ; [ 000060291961440.000000000000000000 ; 000060297866195.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001675E3B70167673DFB >									
//	    < PI_YU_ROMA ; Line_6079 ; gVpAe4S9yVH6hE2n7v1GZmrPHt0LPoGapZM3dgepCn6Y5t5wo ; 20171122 ; subDT >									
//	        < zYfzRrn1Z41Grq11v9qST56E9TmCm2rL56cld8lz4AQmkl463Gt57WKe3THsD6Kg >									
//	        < mhYD3NzZ327WMz2tSb6F13FPVJb20iEbYI2ynbafKnxHaJ0QEG5MnPbZ2aC8G2Ow >									
//	        < u =="0.000000000000000001" ; [ 000060297866195.000000000000000000 ; 000060303964099.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000167673DFB167708BF9 >									
//	    < PI_YU_ROMA ; Line_6080 ; ex8q37mzl5hf81h06XXA9ggWJK80Iai484E9zc64KaAh9ZBGW ; 20171122 ; subDT >									
//	        < wKzFv2I3KDxlew0BBJMG54P3cgLI0r9jMY3MHsdP06gvJf2y3JX0AxpowgbGmbF6 >									
//	        < 78x8ojE2gD08sVMpGTP94y7R77zPWu6e9Mx35uah1Ujq1gMO8523UWok2O765RQY >									
//	        < u =="0.000000000000000001" ; [ 000060303964099.000000000000000000 ; 000060318886405.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000167708BF9167875100 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6081 à 6090									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6081 ; I6u3gYMzOdD75dEzRZ0fb0iLU8gn9ks6q30DLY2U1u40VFoqn ; 20171122 ; subDT >									
//	        < lrf6VGP049IPs6wWYkli4n2lA0RjimLBSO7v2q1ORUFveNRSZL0ueLIJw5Xmc7kg >									
//	        < CDBBpu8sJWSLRFz3dL234Um6s2UxUT1w03lMt9860zOFiLBdu860EGQV8e208w1x >									
//	        < u =="0.000000000000000001" ; [ 000060318886405.000000000000000000 ; 000060330576390.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000167875100167992767 >									
//	    < PI_YU_ROMA ; Line_6082 ; 0S4pZ4H966Z3P6xep4uX1BDXv4i0khhp0Cfb8S98a8jR33uoi ; 20171122 ; subDT >									
//	        < 4M7uho267a7ER8IwfbZ23z51chS883Q82v2wgN9HK4g3yrL1AIZCz650l3224GG6 >									
//	        < k3jNs63lLUhZ53R6NtWrQcN0GYNo7wpWgjA8epK6g47j2y9GwOt0jCGIE4iN03gE >									
//	        < u =="0.000000000000000001" ; [ 000060330576390.000000000000000000 ; 000060345178510.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000167992767167AF6F5B >									
//	    < PI_YU_ROMA ; Line_6083 ; hJbFLhxiNR85RcWlo88oP3C93J99Rj8ilF8o4dzfMj00hsqN1 ; 20171122 ; subDT >									
//	        < 0B0Ug9EI7FdjdYp0rh8CjN55ua7sliQ8WWq9PS0XZ7ZsIgXFtkbr4T3Rz13V8bp8 >									
//	        < w8pRz56xiA6U3x1k7i6ELcn67oG6jULv5VXssIH6LDCV5yh41eYUw4v0k7UN4mO2 >									
//	        < u =="0.000000000000000001" ; [ 000060345178510.000000000000000000 ; 000060359665825.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000167AF6F5B167C58A76 >									
//	    < PI_YU_ROMA ; Line_6084 ; 6RHFhjoC954S0gOFnY30yHh6rRUd9k0LW17G7Ec614eeqd45O ; 20171122 ; subDT >									
//	        < 5MQbBq7GL7lfp1v5r3kHl6p6967QZbdssquLJa1f6jzo3F2M7IXk29Vx4849Ed8G >									
//	        < Bj2M9wib7FXv2l4Ymy7Zr1c5376724c3xgsc9p7ZOSf5w43Uk4MCB8kOU1JR77xp >									
//	        < u =="0.000000000000000001" ; [ 000060359665825.000000000000000000 ; 000060368111776.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000167C58A76167D26DA9 >									
//	    < PI_YU_ROMA ; Line_6085 ; hPujoX63N48Cun5X8WAgJ1IO82BxQWv206VNm1FEpCaoF5U0Q ; 20171122 ; subDT >									
//	        < qCgMcm93DJ6845kAKlz5D79pMd77SzTUq0eQmfKVeI8453ku24W0ST00WQ3O9Gn7 >									
//	        < gN0km1jbL7z4DHVS375iA5VZNwtPQs0g9I6MPV4xaswGA0nE55g14ZB2jelFIEk7 >									
//	        < u =="0.000000000000000001" ; [ 000060368111776.000000000000000000 ; 000060381510061.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000167D26DA9167E6DF5E >									
//	    < PI_YU_ROMA ; Line_6086 ; mSkKla9XGA24W8E7UwOKW27i0Vr63SW565P3RfxNv7PGT06H8 ; 20171122 ; subDT >									
//	        < 66m8DnlUaoAEP69R7js61C79kdobq505ny76RejweO65jY60QaDBA45rn5z489Hc >									
//	        < Oy3XSnVfXlyRM27C8NItyq1cG99J9iSzq8DxL073qR571f6w96ONo3oHjdC68K19 >									
//	        < u =="0.000000000000000001" ; [ 000060381510061.000000000000000000 ; 000060391448637.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000167E6DF5E167F6099F >									
//	    < PI_YU_ROMA ; Line_6087 ; 5s0C9F99Y8g22MNUBE1759spnHuhN6C428VY73UontTizkYQE ; 20171122 ; subDT >									
//	        < jK99a1X7W9a1x0Ga30RSu6V1Q6wRs0gN09AmS3654oOU3ZMBfZA5lJSO01DA66vf >									
//	        < ZCr9QaTc56b8dv7vrJ13mJ3aNe5L0kg1xmvezxpIuE60wB6UMtXUm7k6td6YwNcM >									
//	        < u =="0.000000000000000001" ; [ 000060391448637.000000000000000000 ; 000060405077434.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000167F6099F1680AD55F >									
//	    < PI_YU_ROMA ; Line_6088 ; 4LpeVagB5677pWx7f202Yv6f656m7XXCMz9dAgzlr9dxoEKEU ; 20171122 ; subDT >									
//	        < 074C77AFWajqwpHoIZ6z2ANZd61OwYC1Hc35xKwpt0R5FXG19pl0DX67aEh4jkak >									
//	        < HxTd01LS56VH4FZw66X2W70ewD67H0KT4Q0SqALJh3NnBn8FEB8wo8I88MN9i6V4 >									
//	        < u =="0.000000000000000001" ; [ 000060405077434.000000000000000000 ; 000060418492119.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001680AD55F1681F4D7B >									
//	    < PI_YU_ROMA ; Line_6089 ; iWDOimscNpKb9r2245LVyumkGDK79v4D37nAw3xqZWFYo2k0j ; 20171122 ; subDT >									
//	        < 4612v0CZ1Z3b23moI91ZU58xs7Gax30lKR3KL9qDa84yG0H7fIqI4qB67hKgWC2u >									
//	        < D03uI473pAFt4kJWb0r3Pk633zEBp4V1QU1prxl74F3s7H5Fp0r00kQHIZxZRJJ0 >									
//	        < u =="0.000000000000000001" ; [ 000060418492119.000000000000000000 ; 000060428782782.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001681F4D7B1682F0146 >									
//	    < PI_YU_ROMA ; Line_6090 ; WrwZAB8w2DvK7tQ3bWEX5RtK515AbkxVf71ohBzRhPhyWH9ze ; 20171122 ; subDT >									
//	        < PLn6YxWPXy028kSM10bkRrr56M30xcaVpMv365AP4hHO35wMU5XAaVDY8vVB3qPa >									
//	        < c7ZcER2Wn5SB04U3R137GcGTqp1CK99yN8JjAW0ZYo2Ogct3e4baoS0JwpK9hnMx >									
//	        < u =="0.000000000000000001" ; [ 000060428782782.000000000000000000 ; 000060437731257.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001682F01461683CA8C5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6091 à 6100									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6091 ; jtSTuy7gUWHc2j4e184dTzA4TiV3tILxeNi1XSFy2bnlZEwZG ; 20171122 ; subDT >									
//	        < w182H18QT3b4S1H8Z9Sbv748408Pg7545282JB2wcQ0rqWsZ0cZxPaB5Wjh7kgP4 >									
//	        < 95ROH5of6i7Uf7iWaxaiYx8t58IA3br8c2xO055qJ4qp8990q456WEbOnAxdpoqL >									
//	        < u =="0.000000000000000001" ; [ 000060437731257.000000000000000000 ; 000060443014557.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001683CA8C516844B88F >									
//	    < PI_YU_ROMA ; Line_6092 ; 5gw5sVG54yJL7hY3VV8ZFOnbP9BkPGENLYyrR3wwW3R04A2ls ; 20171122 ; subDT >									
//	        < 2Xyi6N8ESvh8wF4Q4q4W9S28z6Irrj8os0AB9Ok3699dksXx8XwdSFm56uc22AA9 >									
//	        < TAzQK6B4TnK7gklDw3yNn5rn3xu49z62JMhZb6cHXs83VDjS5q25EbG7CYyQNc5W >									
//	        < u =="0.000000000000000001" ; [ 000060443014557.000000000000000000 ; 000060450732922.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016844B88F168507F8C >									
//	    < PI_YU_ROMA ; Line_6093 ; COIxkKc4mYLEVc75hqD2npr2SoDfTuLhyt18jrQ1G9FpH9Kip ; 20171122 ; subDT >									
//	        < 0X1Z94SDEFQqx7Gc05MK9Vbv0QG9B8nU14FO5ltn6ak0R62EFdmmO8lh4R4mrfD5 >									
//	        < 39eMSK9boSQHOG5pj33r42zL6ksvMbVm5wtm3FVlep89ZB9oOVJU0x51HHBn5EU8 >									
//	        < u =="0.000000000000000001" ; [ 000060450732922.000000000000000000 ; 000060459324857.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000168507F8C1685D9BC5 >									
//	    < PI_YU_ROMA ; Line_6094 ; sW853hCIP8eoO56BrM8s9T2995VEPuEMT0626uBG3FzFPJ456 ; 20171122 ; subDT >									
//	        < 95qVCjifBLz47xd99n10hctD5Ws628fWYaFkXQU3W8BzuW6b8muY687Ao31ay7Ky >									
//	        < woQSXfS2rl8R2uD0H7YT59kw3W2DJ15eKYr9vh94gdSl7W6jWs1q715U5937jdV5 >									
//	        < u =="0.000000000000000001" ; [ 000060459324857.000000000000000000 ; 000060470608785.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001685D9BC51686ED38E >									
//	    < PI_YU_ROMA ; Line_6095 ; 0g011TAPN6pE9WuxosrU8TarW4u6w0KzI0htVxdRD4thpjS0j ; 20171122 ; subDT >									
//	        < Ewa4YkVUG160k6X4nH85A987yvhLLD058twDUQzmxwId53Pw2THV4HTxrLF242O0 >									
//	        < xD6857d0Pv950gFIVmQW68991TT66SEXG5i2B4H2jEMa0x3fmmS5N16Zrfz8QUK6 >									
//	        < u =="0.000000000000000001" ; [ 000060470608785.000000000000000000 ; 000060482679413.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001686ED38E168813EA5 >									
//	    < PI_YU_ROMA ; Line_6096 ; aA3lk4Xc4R3LKAuJJ2Jko6tFn3H4dR1727XcOT807eeklCL24 ; 20171122 ; subDT >									
//	        < MkbSLYdKx36P3kz7s9w0d82NExrt2Ud2pt1qmEuldPyP3MuI3R7ZZ8yYKZ9o3G33 >									
//	        < TmEybV9lJ4GJGA5D5eLZ4Ana6ZOnxHMeh4Ajn3JEtEWqUYqG76mRep44KbmSZKxr >									
//	        < u =="0.000000000000000001" ; [ 000060482679413.000000000000000000 ; 000060489073406.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000168813EA51688B004C >									
//	    < PI_YU_ROMA ; Line_6097 ; nh8Llv1Eo5Xks6bqz47M5lZ1Z5edX6MgpRYhnc28EI475Ut89 ; 20171122 ; subDT >									
//	        < n0ie7augaRh9t799e64o4te44nc13laxGjL0hRRsy0o2KCKtiAz5XM1s5680e1xL >									
//	        < 5IG06USgN42U6SjpJsf7qPnpQ6XH2zw06atNYRgO52harSrkdiMo97yN9mpG3Sb5 >									
//	        < u =="0.000000000000000001" ; [ 000060489073406.000000000000000000 ; 000060496790785.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001688B004C16896C6E6 >									
//	    < PI_YU_ROMA ; Line_6098 ; or3AW4Jx6knmPF3LzzFlOsX5c26059jo1FOu9S3HNo61dMsX4 ; 20171122 ; subDT >									
//	        < AiynUjbCDhy70zT1Brf39sTumXwhG4K52Ru7iq6Olf1mV660hRFPX1Vd46UotVzy >									
//	        < 43DMl2YNq83Jy9HEhc1jcXzJeEm0m26LDpES7LPD65oN2vQJHEKiA1q108BTtz82 >									
//	        < u =="0.000000000000000001" ; [ 000060496790785.000000000000000000 ; 000060505662793.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016896C6E6168A45087 >									
//	    < PI_YU_ROMA ; Line_6099 ; 505bKLuSX1422s2L3Ccrx0J8GfolECAiZ7PD35hR146Xf7X8D ; 20171122 ; subDT >									
//	        < 3h26A2JDtGdgt95C2vGHCGu4wKMkKu14q6701MtiBtkqpXo9052cRz2y4eyTL4mt >									
//	        < zH61nFO840Khe22FT4Jy3lL0Lq5txluk2bJmc23Y8vbPUK5qJP0ZYC4eaECMXr11 >									
//	        < u =="0.000000000000000001" ; [ 000060505662793.000000000000000000 ; 000060517020653.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000168A45087168B5A531 >									
//	    < PI_YU_ROMA ; Line_6100 ; T997CP5TARQwPs49UT71MNm1to79ThzV1RIbHPv127r7869hu ; 20171122 ; subDT >									
//	        < L32ZG19y1wtYTat0QrJ0z23UsB729BF49lNXDtY9JMGVa45Qs767dgwge71IwciW >									
//	        < 715t17130pEvL4fvz33wG9jJqNL1dhpF8ceCkEmrVjTVVGLX2JzkF7T669Ja7YPs >									
//	        < u =="0.000000000000000001" ; [ 000060517020653.000000000000000000 ; 000060526455816.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000168B5A531168C40ACD >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6101 à 6110									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6101 ; p1Z3d41pxQr7vUL98Q8edwK40J8N04J3zt6T782HL7UQQv30F ; 20171122 ; subDT >									
//	        < nJmu2O3kJip444440i3WB2s86l4oTWZwhief7PD56T3819DD17wZyS3dFtiOlNT6 >									
//	        < p2IWdrxRoqRJnhZG9Sp4jccW2dhu148yQjV7G2TSlPCkURbkrdB27B0JJT5WfIQ7 >									
//	        < u =="0.000000000000000001" ; [ 000060526455816.000000000000000000 ; 000060539522962.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000168C40ACD168D7FB28 >									
//	    < PI_YU_ROMA ; Line_6102 ; yZ16sNuq3v4tp5RiujH7065iEon62p1Vf1f9E7P5n3P1MM3iq ; 20171122 ; subDT >									
//	        < X47j0zNTJwDVd5tqfcfWZUQ1O193T58ZYyw5ob9w1Wh5K9J642sd90BiM6JMKGpi >									
//	        < Nd32Q96Q28h6mWZdvYR80W0cYr3a8od7e3cnkd3OwC9OG828e0r0NZ449QL75u26 >									
//	        < u =="0.000000000000000001" ; [ 000060539522962.000000000000000000 ; 000060553162378.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000168D7FB28168ECCB0D >									
//	    < PI_YU_ROMA ; Line_6103 ; 612SxxgRFZwDw4B99Yak032IH4ayeI5VnbFhKeH91wG972w09 ; 20171122 ; subDT >									
//	        < tk0q217HD1e5fgGe03855hqGtkH11Z7Mq8708pBH3Kfy3kfHC8VWR8pYw6mh5tAj >									
//	        < VHHLHLD6BukeozD29EnBJto7GTq1FzVf0AKcRvm20J2R32bD1FvdAgIQ3gnjMvxA >									
//	        < u =="0.000000000000000001" ; [ 000060553162378.000000000000000000 ; 000060558560585.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000168ECCB0D168F507BA >									
//	    < PI_YU_ROMA ; Line_6104 ; 2tr6u217aho28hghC8o5pGV0a2bJVxsl0928EXrI57e2Ft68C ; 20171122 ; subDT >									
//	        < slK90k7f78J7UjBtB1Y3eWgcSc96CZAxJ4qi6OkUW0OT9Y07hurA8pZ30Em3eogo >									
//	        < C3t6If0jeNFBZl0dZQJMrgiF5FS634j34oSHj47E3hN0TmHW1SZg173JxHP30PC1 >									
//	        < u =="0.000000000000000001" ; [ 000060558560585.000000000000000000 ; 000060566651411.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000168F507BA169016035 >									
//	    < PI_YU_ROMA ; Line_6105 ; IesIUXfaGR75Z0AM8ZVne67teMd2sSDXx3M3jJAmZDzb8U95Q ; 20171122 ; subDT >									
//	        < 6jy55j4FE0D3z0X5g5e8Z1rUPG6cB1qTyf8HOURsf4jatn00Sz25C7Yp3u625S5x >									
//	        < I4Z3K0ScyR8jd30654y2dYJy1LWng4Fz0y27Ngpk7H8QTZD197MXnnLY0op58O80 >									
//	        < u =="0.000000000000000001" ; [ 000060566651411.000000000000000000 ; 000060577588792.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016901603516912109F >									
//	    < PI_YU_ROMA ; Line_6106 ; E6c8NgJ9Fk9JzR9qlAK14DGrdi5kXgoV32IxCzADXKf3bpHAI ; 20171122 ; subDT >									
//	        < RtFaJTqzkZwF7wiFc5eqKtjKDztDZU8UZMXIk15hX7eEW9bsx30E4DZtHhCecgx4 >									
//	        < 3L9afLfDGXgzmjFJHSGb7U1A9f4GSIGr2aPl93io5d2Of9382gFE7IU40Y02p58N >									
//	        < u =="0.000000000000000001" ; [ 000060577588792.000000000000000000 ; 000060588720532.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016912109F169230CF5 >									
//	    < PI_YU_ROMA ; Line_6107 ; 0dcSLn39KBxFe64fDtixqAWS8ncWQuh7qAp7i4jj3YU048Ir0 ; 20171122 ; subDT >									
//	        < 2Z98RWL9BZ2XWK25UU9oA7halkpqukHClLcDw03nZZcSwduMj3x55403SonAq09i >									
//	        < 1d8Rp9Iex10MJ64xI0s557iffAKIjX5q1c5MkWzS342l78KqHnH4NeTO9Az509y5 >									
//	        < u =="0.000000000000000001" ; [ 000060588720532.000000000000000000 ; 000060593977356.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000169230CF51692B1267 >									
//	    < PI_YU_ROMA ; Line_6108 ; fHdhat8ehG50fMgT9b9z4eAnyOB04HL56WtEq3aKw41Sd54z6 ; 20171122 ; subDT >									
//	        < 1uGOs9RtffBIna5Kf5v8a26x6KF5wAI06322wI41EFHk9Io5E6bxeb1z8U3L1b53 >									
//	        < HHMMgwNeSf3482Vt6OXeoNEJztB22j942i3o26G226Qvp8xj7Eh3E7z1QZ2aeXZz >									
//	        < u =="0.000000000000000001" ; [ 000060593977356.000000000000000000 ; 000060599656135.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001692B126716933BCAD >									
//	    < PI_YU_ROMA ; Line_6109 ; Zni75fmndjc807u7neeSXUPv64tEe9rTtP6RltTt0b4Aw87ey ; 20171122 ; subDT >									
//	        < NPaJ5D151vknS2297Z6yrNFDl3ScTLFa33dEKTOt2t4taArexLg8w0Y79sQoLeyp >									
//	        < 28Vn9O3H37Q6sXYMG8h5NSdaAUmkpS60OI3LmX51t8Dx0t8TT5jPAlzvxaQ7lbgj >									
//	        < u =="0.000000000000000001" ; [ 000060599656135.000000000000000000 ; 000060611254852.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016933BCAD169456F6D >									
//	    < PI_YU_ROMA ; Line_6110 ; 452j1XR2c6ZbV4b66ET72WQlVD3GA537dqBTEL95T00N5Ha5A ; 20171122 ; subDT >									
//	        < 84iIPp5U97k4g6AYczcOfH7o0U7877U68zxv197c663Td94RWNYGKl15V8306QXH >									
//	        < 29ICa03CSyzgnU8pDNA02XBg0J89W3378BeJ7f4H31ieG4paf1hVK1jD85V092ZZ >									
//	        < u =="0.000000000000000001" ; [ 000060611254852.000000000000000000 ; 000060616704617.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000169456F6D1694DC03D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6111 à 6120									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6111 ; TLi24Bi36NVeFp482e88jmngQDwq2xstyi4jqut7FBe4A5dNi ; 20171122 ; subDT >									
//	        < LZ55rq7jiC0R8u1w2lQSpEsf31zs7xOcvEKaF1KISVjujhDMX6OJ0OrdnTI6J4y7 >									
//	        < k63IWL4Hy963FUR9M94iklPBe7E9mKTKA817i9s0sx9sBKOTN5PP2RCo3SUNf3Lo >									
//	        < u =="0.000000000000000001" ; [ 000060616704617.000000000000000000 ; 000060628403713.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001694DC03D1695F9A33 >									
//	    < PI_YU_ROMA ; Line_6112 ; kChE0MTO0P6cE9tqFkcp3Jxa1J6C26GRQv9qeKFW0LgXtVR9N ; 20171122 ; subDT >									
//	        < 4QcamT054Qyzx3M8rn53jfQ9x8AjG2SEfC6hI8At7XdFm20Xa5RmY17na9zIhSVq >									
//	        < 23Iq75M5Y50t677aUXeOgVA2KNUGxtF4TU5DPavDAm543Mkz59r66NA2q15b095a >									
//	        < u =="0.000000000000000001" ; [ 000060628403713.000000000000000000 ; 000060633577925.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001695F9A33169677F60 >									
//	    < PI_YU_ROMA ; Line_6113 ; S8IQ63N3YO5wZ21csgVA5zt6H2r2aIsq26Vx0oCx5NtLMJGIc ; 20171122 ; subDT >									
//	        < AdE22GLkpwQYU27gk9P91Xhb10zl6L4fytHa9Dde48wN9NZFt467yp340ygMdfs6 >									
//	        < XSbfBI6hFtOf40SzioKyv47BwfV4TEZA8hxVK4Hyw3bHbJYatVbq02OOEkJtqlhP >									
//	        < u =="0.000000000000000001" ; [ 000060633577925.000000000000000000 ; 000060644373381.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000169677F6016977F85A >									
//	    < PI_YU_ROMA ; Line_6114 ; 5ZiSSPmcU0oQ9V3a0sqR4Kj55SC0ouQ6PGF97MO6ejLWudDi1 ; 20171122 ; subDT >									
//	        < c7vlqt6E818q7MJy9g3e61c7DA47uV0s0C8EHKZ55Q6t0O1Et48ukiNCv7u8mi4O >									
//	        < TQd8Z43q3oQNVyzfGED6Kcz2Io4tTYIyo0n7xTAMS0GjnI6tZgAYtc2jX1j7VhcA >									
//	        < u =="0.000000000000000001" ; [ 000060644373381.000000000000000000 ; 000060657185890.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016977F85A1698B853D >									
//	    < PI_YU_ROMA ; Line_6115 ; tHektVIcY2bS038EC71jeyD5pj0mSN462jto95Usr1yL4qpt3 ; 20171122 ; subDT >									
//	        < 1OqZVll2oC9gVDO6TsstTBWs94Z4W0z76TcJih1D68Z8Kwsj1577l523U786ytqz >									
//	        < Dv0b67y7N73C940sru7ASH11Zp68f5y1gF3Y71199JDCax82J6aovyx1nTmuoc8Y >									
//	        < u =="0.000000000000000001" ; [ 000060657185890.000000000000000000 ; 000060668838341.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001698B853D1699D4CFA >									
//	    < PI_YU_ROMA ; Line_6116 ; Z809cHiiwUvxMcRZN7g210SO9jEehooUqHO7RCN0hL1Xrb83v ; 20171122 ; subDT >									
//	        < kMYFP10EWVKY8Ygw6r77nXSYI1GzsPmE31LK00268i2jCe5LC4d8Vzy711QfYkhz >									
//	        < l191HEPMKmFF6SNafonLJXNkRsW1v2MGb4gFbJ6LJQBl175uEw8fA5226jUwwFyq >									
//	        < u =="0.000000000000000001" ; [ 000060668838341.000000000000000000 ; 000060683350953.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001699D4CFA169B371F7 >									
//	    < PI_YU_ROMA ; Line_6117 ; G2U18UOPg5O46OTEaasZfgBCZLEw2oG88wOOvjjxyxwinH9N6 ; 20171122 ; subDT >									
//	        < M77R90X3143pI1b3fF4bGaFm6S3x9l5m095N6k0Gf22qC6VzfFf24wey8LZ1975p >									
//	        < 119u5822qZ0w7RR44N09IneQh4AXVEMvR9cgsv16b96NUQ9y0BW102B51gYrn3cf >									
//	        < u =="0.000000000000000001" ; [ 000060683350953.000000000000000000 ; 000060692280458.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000169B371F7169C1120D >									
//	    < PI_YU_ROMA ; Line_6118 ; E0iRNG6Vw2un7PJ809A6A00Vj8jPk4mJsBsBI63qP2510E3WP ; 20171122 ; subDT >									
//	        < 5d32YW8pZ75UrYY7L5l80J2Af027q612GH1eG6xROzp06EEQ99zt39L6D1KCJYRz >									
//	        < 0sDR7LcCz2w28X0c0k6756457q2yV9X6iz1aDuv452El5Ed0bAs4s2ZlYSzxgjg7 >									
//	        < u =="0.000000000000000001" ; [ 000060692280458.000000000000000000 ; 000060703349782.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000169C1120D169D1F602 >									
//	    < PI_YU_ROMA ; Line_6119 ; a4N5i8R6lRrfvCFHbWK8GNFrr382SjbBjr7RYtjICG3q8yc7s ; 20171122 ; subDT >									
//	        < 9GY5R1FdgMQEQ225Z8ktR3H01GecFrTTAE7g7r637U74BFtd533vVybwHgymd0Il >									
//	        < 8s2zL8Z43SnLM84mCd9pJF0xZ6i77SGDk43U6oe1tAsblXVXYPk33xy2qeT8O937 >									
//	        < u =="0.000000000000000001" ; [ 000060703349782.000000000000000000 ; 000060714874710.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000169D1F602169E38BEF >									
//	    < PI_YU_ROMA ; Line_6120 ; BadwQLmqgkoLJ058fP1J050hW3o260w7k9AxEy61Ud2nx2jva ; 20171122 ; subDT >									
//	        < a9ES971EGI46Bp5bmOafI04MoKuOqLLcZlk00cE5sbkkw7y4BhB8Sv79BCkG2CO6 >									
//	        < mXD57A993MiKS2fCCmE40C8qJ7pD6S47TyTi5oYvE7Ubf6tRLtSZF75IN09b6nWd >									
//	        < u =="0.000000000000000001" ; [ 000060714874710.000000000000000000 ; 000060720957386.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000169E38BEF169ECD3FA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6121 à 6130									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6121 ; I49Am2t676b4oxDuT512M920Dcf8efp6g57EYl4maH8yFCmv2 ; 20171122 ; subDT >									
//	        < q301A7jkK1q798bbKcNw922F2W44xMkx548F15v44c7pg74e4qFD1VllV7ce46I8 >									
//	        < 6ZBhl334s8quXY6zvpPPNks01b4Me6oLgvExi3If0yAe7kV59e61BoGxUfAIN0ag >									
//	        < u =="0.000000000000000001" ; [ 000060720957386.000000000000000000 ; 000060733438172.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000169ECD3FA169FFDF49 >									
//	    < PI_YU_ROMA ; Line_6122 ; ez5x9wDM6TxjVGe8P443wt0WeP6AnDOP5reuEQ6S0J5E0a14e ; 20171122 ; subDT >									
//	        < VGLIp9WLMNOOypjv0y6rw9PE7TWRucB4q0vNITjmpEcUL5H18JBku2Pw8YCcbQy7 >									
//	        < OB216E977j9rxi8x67tas26eJroScp64dTUU21g5x44pKGto4E3hhX85f38uotOE >									
//	        < u =="0.000000000000000001" ; [ 000060733438172.000000000000000000 ; 000060747419441.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000169FFDF4916A1534B8 >									
//	    < PI_YU_ROMA ; Line_6123 ; 042rzeG3oSq7HzQ6q8CH098bcfwH8dBdR1P0BBT66We4611r0 ; 20171122 ; subDT >									
//	        < 3QsJSr6u6zGnRl5hdpKkrgCoHQ27pVY7O8xG7737P4RJL3b4Sd6cto5334ZEYw68 >									
//	        < V33x16yj3y4MN839wY0HvlGJ28548S5L8vy7QxOB19eUxL04MZ910V6Jke2viEOy >									
//	        < u =="0.000000000000000001" ; [ 000060747419441.000000000000000000 ; 000060758854697.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016A1534B816A26A79D >									
//	    < PI_YU_ROMA ; Line_6124 ; AC7CYHMHnY2tFv9oJz1KmCEIVzBR2c6q1cnejDOC7HR8eHO36 ; 20171122 ; subDT >									
//	        < Ntc1b92i8KItFfHHH75C0BG7H84PtlV98K7l1KJ6LjW3k782rd43nKp9fPO8Wa39 >									
//	        < 1DsZfsPbXRQPRbDEp7CLjLjVgSo1rMY22GZWBtSV1D8ADaFqW2jJYj1PT1L256h0 >									
//	        < u =="0.000000000000000001" ; [ 000060758854697.000000000000000000 ; 000060771313114.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016A26A79D16A39AA2F >									
//	    < PI_YU_ROMA ; Line_6125 ; p6V567X374b99xOPLFMNeaLz3kPo6iYO5zn87Mnd16FLu5yS0 ; 20171122 ; subDT >									
//	        < TiVSrE2D00hlOjskh1t3W2chicOClQ77L3Pzj7r0wzoy7fE6BCY54z3o7Cnnp6B0 >									
//	        < h6h9aH4x200U86597GNk459UL0JFaTAhg67Q1QwXKQ92jI2F15A9D42l4vXfQX5i >									
//	        < u =="0.000000000000000001" ; [ 000060771313114.000000000000000000 ; 000060776662407.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016A39AA2F16A41D3C0 >									
//	    < PI_YU_ROMA ; Line_6126 ; oYryavhuMWx40m6Ht3RWg9Z6QaiNiK9xz52MSwB3Lh2Hl28aq ; 20171122 ; subDT >									
//	        < mz7m8t2dmV28rPJXs192q3GJpoFB7FM8kXjw08oBCd1eT0q2e5EtH8i753O8Wl85 >									
//	        < 57tce8bJR64cTrOfScA1l7gfnFQN8u0qvVgtprWEAb7aal30N07Osi9rb7zdGF7a >									
//	        < u =="0.000000000000000001" ; [ 000060776662407.000000000000000000 ; 000060786217615.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016A41D3C016A506841 >									
//	    < PI_YU_ROMA ; Line_6127 ; nS7AjA11TxVBRWCVO5iS6EW63ZmFwz471Iz202ga767Y67jT5 ; 20171122 ; subDT >									
//	        < hQhByeV5TPq012EfSr9W4qpW84cppYVyUi53Vv8360LZjA8ezAMg13rGO1E3qfo3 >									
//	        < 3siv1KiX9qfEP6K3EVAsrh7429L7hUfDu9RSe33HtisE69rdnR8PAp32BTgq95Mn >									
//	        < u =="0.000000000000000001" ; [ 000060786217615.000000000000000000 ; 000060795875508.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016A50684116A5F24DE >									
//	    < PI_YU_ROMA ; Line_6128 ; 7F280mQf4NOR6b8A5L5h8TGy7sICFYxDN51986FX6Kf4b9AUv ; 20171122 ; subDT >									
//	        < 0zP0LWC72aJtsuNb057Jid4iNMC1u2m20iNX0UbVveXCcJVKM0ACRg64QrGpovfX >									
//	        < I5Caqd2imPp288h3B6T2C0RoZHTi82x9SS9Jz5FGUW3VRr6xkcSd8b5H6C44nZ8p >									
//	        < u =="0.000000000000000001" ; [ 000060795875508.000000000000000000 ; 000060805384981.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016A5F24DE16A6DA782 >									
//	    < PI_YU_ROMA ; Line_6129 ; 38v5bAk49aQd1m084hvjw1d7Sa93lz37AN32hC86Aj3N68EmX ; 20171122 ; subDT >									
//	        < 26834ckI573fVB9mAd10g8M8nP5Kx99PP8CH2i3A6CG986l4487s6EKdhfE6O3u6 >									
//	        < 6AkJ2EMCjkl7ErsTqW4XWGn50166UxDwPu5uh8pKX66t60547lFZCopnw09O3rs3 >									
//	        < u =="0.000000000000000001" ; [ 000060805384981.000000000000000000 ; 000060813875652.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016A6DA78216A7A9C2D >									
//	    < PI_YU_ROMA ; Line_6130 ; 41b0Wqt7I4fv9CXVJojml8t3B246s6c76VvUho42V9S04A9SM ; 20171122 ; subDT >									
//	        < 7nF7g2GeH8rGt5k39Xv0MpiFiH2R2qG314kjLGSaFA9ibz79el9p226or2qHLlDN >									
//	        < pS6R5s46lWleX5DG8uV9g5VKfIZCK2q2AM789H6ir7FUnn8u3E6h234I566pjR1x >									
//	        < u =="0.000000000000000001" ; [ 000060813875652.000000000000000000 ; 000060823702044.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016A7A9C2D16A899A9C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6131 à 6140									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6131 ; E1qRGW9kUD529coRPap8ggs6r3y89jNJyS6Eye7E0FxT5J5Uz ; 20171122 ; subDT >									
//	        < 1N79Jf8c0QxngmI12L2QsFilUPtiJkwb1HDlz3oEkw6iPtJWshxXZQgnD9J9tRG5 >									
//	        < Pcav4P0BQP708JeZVrnV6umlK4Qg90I31ryaX5171oYhc8j5ayRwCHEDj4lNAl19 >									
//	        < u =="0.000000000000000001" ; [ 000060823702044.000000000000000000 ; 000060838695406.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016A899A9C16AA07B64 >									
//	    < PI_YU_ROMA ; Line_6132 ; nFlU98zGzECm3sr9S6111h64e8gKG08Bg49v0p1fU6G3z7C0R ; 20171122 ; subDT >									
//	        < F6KkukBly5pulnPXjRX0tx7aM0WO5K0gidFARHRQadKPWdf05p06eNT77m4pp8kP >									
//	        < ujO77CHQwHLX12yD8I48epQAok8876j8EHtiaW1CKpNv6wiM7k8fU647wzfd2b4k >									
//	        < u =="0.000000000000000001" ; [ 000060838695406.000000000000000000 ; 000060845912405.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016AA07B6416AAB7E88 >									
//	    < PI_YU_ROMA ; Line_6133 ; siVMa9zRwZ7XJC3D1Ndx5GMzUKI7MLoqhtn0Yjx7qvVdfi6Mf ; 20171122 ; subDT >									
//	        < qkY2Uo5EJn6fITe0YV60IlMvMWYlu5S8PMVu68z29ygj748mF5J21i6mEE9GV25M >									
//	        < N1H809hVpZDz85pWTBvd7jthx1O8cccG8VPxCDOX8VR2H7rG090Lq893K8R89M2m >									
//	        < u =="0.000000000000000001" ; [ 000060845912405.000000000000000000 ; 000060858410466.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016AAB7E8816ABE9096 >									
//	    < PI_YU_ROMA ; Line_6134 ; z2vQiFF5B1jmDpD4lwx5ix27DzWaM43ETQ8Qu0iCPHER3o143 ; 20171122 ; subDT >									
//	        < K0lpA0JjKC5TYIhXhsGZ4n1PRJBNiQOoxWCQXq2OOl0ZUkjeLim7IydSH5M1PXhB >									
//	        < DFo8p1f34DFD74u94FKX5fcm2b96PtEaA604KWq8fiUPP54OwKGsal36FUYxEc5p >									
//	        < u =="0.000000000000000001" ; [ 000060858410466.000000000000000000 ; 000060873379472.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016ABE909616AD567DB >									
//	    < PI_YU_ROMA ; Line_6135 ; e2g8G7568Zxgh4aui0CfTp7sxZdwrlfOBJ725hNri99R7zU1y ; 20171122 ; subDT >									
//	        < qoXQuD9jpyCBz97DslNMDXBn8mf9S9qEoFg9gaZSQL8TbM1TDt7R9d0f2ra69mD0 >									
//	        < 4bnpZB9aigZkQ8157h8wm2dPjebn47j5oo7M122AUp7LMbk7zAF3q9wtND4Hq2Hx >									
//	        < u =="0.000000000000000001" ; [ 000060873379472.000000000000000000 ; 000060881729074.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016AD567DB16AE2256B >									
//	    < PI_YU_ROMA ; Line_6136 ; MAh7xlGSGzuU9vU4l0X41luCo91G6EqciGmid0JY5lD7il4Im ; 20171122 ; subDT >									
//	        < 7Bt1D8Gr56Yq0Wv0E5E2dAW1PgSajN3e79tU5DU35XHxL843f7m97Gg0316YMuX0 >									
//	        < MQ6z8M8Rj2H6CNFSxdTjN0BKwcW8l9HlvSxoWUHc7gc9pAc1c3s1nAaIunOOZbFl >									
//	        < u =="0.000000000000000001" ; [ 000060881729074.000000000000000000 ; 000060890445795.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016AE2256B16AEF7263 >									
//	    < PI_YU_ROMA ; Line_6137 ; JPP49cHT2g25143QtnxKwLF85HkKxzT35q43m6zlZz6QXoeRd ; 20171122 ; subDT >									
//	        < Z02aMa1SR5VUki5esR2UHba55R01M7owMHJ675810Vhu6XQpKDqdxr16o51p3cZy >									
//	        < 4ei8rhb7crzqyBvI4GFMn472zsSsXof8AToY1k7mHF6SA31yb1gHATtI2E8uDKoS >									
//	        < u =="0.000000000000000001" ; [ 000060890445795.000000000000000000 ; 000060905319573.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016AEF726316B062475 >									
//	    < PI_YU_ROMA ; Line_6138 ; 1cLYVsa1b1Ih3bW26x29ZFSihL4w8hLgK722woGyRQp649G36 ; 20171122 ; subDT >									
//	        < s3uk7g1RU7u12XdNIuD95u7GdXULi23gaN8f7sZBTGu9YC5Nw4Xjvf3ae00UJEL8 >									
//	        < w20QJxDnRqVAJ5W6OelOXE82RUMIle0OC9265a8Ue639dK095Z08Kk00l2BGx51T >									
//	        < u =="0.000000000000000001" ; [ 000060905319573.000000000000000000 ; 000060917116897.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016B06247516B1824C9 >									
//	    < PI_YU_ROMA ; Line_6139 ; VQmn2M0Z077a1yUAk1NA94tPq7AigCsgOV0565x912HK1fwu3 ; 20171122 ; subDT >									
//	        < jch14IhsWjQGCs8ZDw5KUfA8z177yeY80Fmb36087R3XSr8ybE1a3qhjiryd079D >									
//	        < 31nanpAVvR686i9Rpi4SwnQO9l76bvyUkT88j1U08gsPwyR8W00Is9ZRzFDldhNm >									
//	        < u =="0.000000000000000001" ; [ 000060917116897.000000000000000000 ; 000060930254931.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016B1824C916B2C30D5 >									
//	    < PI_YU_ROMA ; Line_6140 ; w5NUC726XZhrvX7D6FoA4yUYllayUEIpOwPtaQxi76qV5NbCI ; 20171122 ; subDT >									
//	        < 0PDI1v73X965w6BNQXIvlG11x2EeE8ual65S9lDv6170h1IvC9710F9N8cmL4IlL >									
//	        < L2ivgTnpu27XK2GiCOKcd4n6348D2Fz2dTlmu5j0yup1K97Pn5C4BL8kG077piV7 >									
//	        < u =="0.000000000000000001" ; [ 000060930254931.000000000000000000 ; 000060943828883.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016B2C30D516B40E728 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6141 à 6150									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6141 ; 2SUvdD7a862qG76OVQq1exTh0RIbE6NKqlO3FDSK14lI0lkLk ; 20171122 ; subDT >									
//	        < 7TvGy3i4248dvq6HgSs3M6CcVH0X91Ur7hM2chHY5o804i3kA103hkE04h0E78CH >									
//	        < 2s0p2R0c68Em05CkQrdW9alFP7A9D77H6YJ2pcUvgvJjsIdo3N7nDoC1PshXdm03 >									
//	        < u =="0.000000000000000001" ; [ 000060943828883.000000000000000000 ; 000060957262416.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016B40E72816B5566A1 >									
//	    < PI_YU_ROMA ; Line_6142 ; ceifLPEI3eyvA0xNKcrpXLFY270M8Cbj6nN4o0kF1473vm7x9 ; 20171122 ; subDT >									
//	        < w7fr4C01mM21HUH75eDaVtBa5OqA6lE0iLa781DU40BsJmrvc5mnmJCi5cp015qO >									
//	        < vJI0jD0GzW81A4p6ZgTZ3AJt53YpZ3sY6dU65K65846ynkBWhO8ZV3SsZT02GRg6 >									
//	        < u =="0.000000000000000001" ; [ 000060957262416.000000000000000000 ; 000060967395607.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016B5566A116B64DCE8 >									
//	    < PI_YU_ROMA ; Line_6143 ; 1AZhZ7L4IlpEv4M4IcnbKT5K0lc95iW4v94SW43T39or69in6 ; 20171122 ; subDT >									
//	        < U0jjrj584mjJW7JHs0l476BW68T35buhT4U60K6X4XfRubZs1c02jH0Sfi7Bi10Z >									
//	        < t073EOtmbR8doRweFq3KrWezx3oTbuR4YCkS1G3Z7W2YaIdUOH2rmZHt4JNTIKZ5 >									
//	        < u =="0.000000000000000001" ; [ 000060967395607.000000000000000000 ; 000060973359857.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016B64DCE816B6DF6B1 >									
//	    < PI_YU_ROMA ; Line_6144 ; 8DUz3jR710j9rWjbhma8he10NJ6SSDv0wz7bYl146hK526mg9 ; 20171122 ; subDT >									
//	        < oDS2f7i0L91QiR7X93pE4v842a1j9925y2CbvTHurcri4wHs35g9Q27gNw67N07x >									
//	        < HSO589l1eJzJ3AC7XD2mO6fu1qkTpwy2KQflRe5LoAa69tQG87SNDAcP5m8OH7Mn >									
//	        < u =="0.000000000000000001" ; [ 000060973359857.000000000000000000 ; 000060982983037.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016B6DF6B116B7CA5BF >									
//	    < PI_YU_ROMA ; Line_6145 ; 1jgaM4iVR8ZsW6W3UI5S0zi4rV2l3vSVCl9jPKRhY4XxRD92x ; 20171122 ; subDT >									
//	        < q7P9puha2TA66368Hj9xUq464G9YnCpsyXcq9su9zUXSK15QY4E79BH49IHryYTy >									
//	        < LCTPd6pbdR8t98KjjYoSm22102gvY3m98Q2c9u6GGiWw3ALQQzOKP2f8LIzpG9lG >									
//	        < u =="0.000000000000000001" ; [ 000060982983037.000000000000000000 ; 000060993249170.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016B7CA5BF16B8C4FF5 >									
//	    < PI_YU_ROMA ; Line_6146 ; Wb67mT58Wn4zpdjVuK4NqxVJa1WTg53OfLhkCgIxI8kUW6Pmg ; 20171122 ; subDT >									
//	        < 984XiQE30RWkC0RXwo7awp9Tq9CRpsB8tAM5rEhuLMd0b7M7to2sf2H3O4Rwr2Uj >									
//	        < Fd4M6m3616QKzFm855J3643z7n6e1J7Q4Ky05V1vRmp08wbU9PH4966vWm8xrHZS >									
//	        < u =="0.000000000000000001" ; [ 000060993249170.000000000000000000 ; 000061000070641.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016B8C4FF516B96B898 >									
//	    < PI_YU_ROMA ; Line_6147 ; OeMZFDhRo8ROigZj1KS934PDq98286Q76cx8VHlAB248phhS6 ; 20171122 ; subDT >									
//	        < B8M067036XpOo7Fj2eo9hR35w9D1B5at2O6t3OUUKUB00c3T6HPczWz1TZ38B0iq >									
//	        < c55HlG15bb7bIkBm4Wn7qABET2R12Gwa9v5T881xb6GO3JxBzZm829k6ImGi064W >									
//	        < u =="0.000000000000000001" ; [ 000061000070641.000000000000000000 ; 000061008567341.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016B96B89816BA3AF9E >									
//	    < PI_YU_ROMA ; Line_6148 ; 5qpHJ24Bm0EG0J1mQ15SUz4WUjpH64e2Elt193Fdhj98DqLa6 ; 20171122 ; subDT >									
//	        < Ur4n25k60kPa4oKv78i3N44n32i0zQByZteF6h1Zdiq6e09HaRq20Tnqpm1D84TH >									
//	        < sJQ97ZOII49IDD49Ae5U3SHyiG6WHq0iR8KcS2R0Cb6462MM3XXv3tf61yrn2vZ8 >									
//	        < u =="0.000000000000000001" ; [ 000061008567341.000000000000000000 ; 000061014059497.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016BA3AF9E16BAC10FD >									
//	    < PI_YU_ROMA ; Line_6149 ; 1FvB7R2e9230Qf719x50jCKsE2Lx3j0QnL4KQAHOoGd1n7Asc ; 20171122 ; subDT >									
//	        < uBbzC5DGB4c31nWApUIWa893r37741PxWLay8t38zjPK06ESTq3N89L1LSaG9HRu >									
//	        < L69r8pVSw7yc25tc53hu9dx4Wu47pXOF6IezE8866Vle72ydt3x931irh2R23RI8 >									
//	        < u =="0.000000000000000001" ; [ 000061014059497.000000000000000000 ; 000061020278719.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016BAC10FD16BB58E5F >									
//	    < PI_YU_ROMA ; Line_6150 ; e6vvn0bPNnC3eXOykB5EyTLQh8527XtY54a923Ld430aLIef8 ; 20171122 ; subDT >									
//	        < OWFf2y5pNgDsFdZxA59FZ748uhf7OuhJqNKoIgC6349om4FEG028B8r152C7y2wd >									
//	        < tmt33U8lUZd72wjqgxui3SMz003LOO64R8zpopCZ2C2m9zEA9V5SgRy7vXC10NSB >									
//	        < u =="0.000000000000000001" ; [ 000061020278719.000000000000000000 ; 000061033412245.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016BB58E5F16BC998A8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6151 à 6160									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6151 ; i73UjgSE029GGee5a7Um77t3AUwN6WYT90D1cSUDVr3hnq7u0 ; 20171122 ; subDT >									
//	        < UgQqIWS5X11B0rBPnH6uXQUC995JKC49FB7934BI0j6Ydo1S65R5QXXC54ZWBj8o >									
//	        < LGwO6FtUvb3M1lSeZSz9s5YB5gomq946XtnNeE9yhLT187CJtNv286o4p27G308X >									
//	        < u =="0.000000000000000001" ; [ 000061033412245.000000000000000000 ; 000061048158835.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016BC998A816BE0190B >									
//	    < PI_YU_ROMA ; Line_6152 ; 9xyzD4haKc9dTF7Z5Pm5tywt34Cndoxdnr6r54rBLqiz493rX ; 20171122 ; subDT >									
//	        < e4uMIaC4ut8x3FP8m7x8oWLBQ7nMjMQx2pl0PnXd93RsN4q3BZN3SrGkSwkm77Ux >									
//	        < hDC2oAFuxRuf6n8W98g8Cg7fy1lRYpNfm6Z39oJKRR2AaSx1Q89TujB9fXM82s3J >									
//	        < u =="0.000000000000000001" ; [ 000061048158835.000000000000000000 ; 000061058961713.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016BE0190B16BF094EB >									
//	    < PI_YU_ROMA ; Line_6153 ; 0NoTpg5wV6fTrK5F04p4V2K82j0z49xQaeW1t0Zu8grK63449 ; 20171122 ; subDT >									
//	        < 2JPlbWK3h6tSy4EbpvrLXFt0m8d1H1suz1DE3VYR5T15iqrkGoG6ipD6FnYx8g0t >									
//	        < 0j77Ge7y3YoONPKak5ImrUwLbRxZX5m57J8z602n0BApLHe4jpya5Z3f6b70PMKG >									
//	        < u =="0.000000000000000001" ; [ 000061058961713.000000000000000000 ; 000061067553168.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016BF094EB16BFDB0F4 >									
//	    < PI_YU_ROMA ; Line_6154 ; GnjNahvHS8D19K47ehhnDT3f5661vdj6w9y1nW2bQ2LokvJ4N ; 20171122 ; subDT >									
//	        < GH4ozIM2tgMR1ia6x5b3P9JB2f04aUylY3tUfql9vvDyjOXYAaZzUf5J4CxhW5FG >									
//	        < 2Kqd9F2LKw3F94fZxf2oO0J4nOPSY343Qn3Dg51WfN5msD9JgXDR0NWWBk4lkoL0 >									
//	        < u =="0.000000000000000001" ; [ 000061067553168.000000000000000000 ; 000061079768985.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016BFDB0F416C1054C2 >									
//	    < PI_YU_ROMA ; Line_6155 ; lu0GX9Kba84DEcCsZN5HYj7DBr9F7337dok1bHw7VHCDM4k9a ; 20171122 ; subDT >									
//	        < ZZ572FjeY8d9Yz50V8Fs83Ehtwu11X07h9cS4ilR6Pi3a61PDvQw1ejWQp5CApU8 >									
//	        < A4b10K9zdXj290cyr1mJ4Jl6401Nte5J995m63JMw8ylT8Kkye608nAGdp59ZLvr >									
//	        < u =="0.000000000000000001" ; [ 000061079768985.000000000000000000 ; 000061085336528.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016C1054C216C18D394 >									
//	    < PI_YU_ROMA ; Line_6156 ; 7O1KQPm5BiR922f4u69cWOUxnLATMuwSe12zU8jrc3S20hN8X ; 20171122 ; subDT >									
//	        < WYHjAmu384123SzpSRf7a60E76V4d2L5z7702UZjBm4k3qdS45Rvn8P34C0DYoLn >									
//	        < 47Orp4PdPV3N4LUR4Lz1UQvmhQt1785UlK0TX2WWQH26DMo5wx29aOR15y92AJVl >									
//	        < u =="0.000000000000000001" ; [ 000061085336528.000000000000000000 ; 000061097690275.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016C18D39416C2BAD43 >									
//	    < PI_YU_ROMA ; Line_6157 ; V8XA4JJAUtr5zc0eLLm3PqN71H1GM2o1Ucn2X352SeQ3s5257 ; 20171122 ; subDT >									
//	        < H85I6N6fimMMf8BsBfGVn4AIX1xJSnRe8Va0d479OqJUIi6x94kLDw5SmNm7W915 >									
//	        < 04G3JiKHiAN9aVIi7zVYPnfEiU95BCih6LQ2fPdM10Y52hI2nz8Du7SXX4398Ko6 >									
//	        < u =="0.000000000000000001" ; [ 000061097690275.000000000000000000 ; 000061103121176.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016C2BAD4316C33F6B5 >									
//	    < PI_YU_ROMA ; Line_6158 ; Kd082Z1S3bae29IeRCd4rtDd77a0qz4cIORN60UW0YkRP4bcD ; 20171122 ; subDT >									
//	        < cv7lYGdd8U1sDRjw8la9InAbwmjf8fjxE6j4o3Z4T2C7AEPt9JTMW6b757lst1op >									
//	        < LZe88Y8HBn42E0FdSGn5M94vG4Lh9fl5Ng20Mh3ueu3n1yFmMVC73KOFe6Yx7G7a >									
//	        < u =="0.000000000000000001" ; [ 000061103121176.000000000000000000 ; 000061108464326.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016C33F6B516C3C1DE0 >									
//	    < PI_YU_ROMA ; Line_6159 ; dT2PpNyZ2U8T1Sb6xAa0ce3jyJ65593OF5ZMCq4PZkXy1Di4m ; 20171122 ; subDT >									
//	        < V0D07JEQiXZ5cJRYQiVm7LkHVTnsm4Miq5558Zx8Xme9xr502Us6wc3a70CVAH0g >									
//	        < Gl65lPipRoJO25r3A1Lu3GA0Qm3CLxS0heizazYh5MgwlAar8Y81E4198vY1l5fK >									
//	        < u =="0.000000000000000001" ; [ 000061108464326.000000000000000000 ; 000061116370520.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016C3C1DE016C482E3C >									
//	    < PI_YU_ROMA ; Line_6160 ; jCXv1uq4k6MXHdH2WgaQ3kPY23l6o6PS1L9Jb13Od3gOiGh0g ; 20171122 ; subDT >									
//	        < 30Ru83dA0KwB28mNoK1bhFTP968410Tn7jx0rmhry2N4T09qbqNzyVS83m13pCe5 >									
//	        < 011Ub9y1yk7J6jB6w8SoGZBd8k8ZL3naWS8cv1QO600o2d6K0EWpf8BiXMPtS2ed >									
//	        < u =="0.000000000000000001" ; [ 000061116370520.000000000000000000 ; 000061128159184.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016C482E3C16C5A2B2E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6161 à 6170									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6161 ; k3O538118dP2BdR6Mk4RT84l7R55q7S86FPQFS78UID4lcsLd ; 20171122 ; subDT >									
//	        < ft3ot7DAj9j42f2ggj2HB08VH7yVs1tPhXemJx08ue951PIfpc905VUaM87xH8PX >									
//	        < 53uZfSH539FE3gJYE6m72TBS6kIq0Jd0wgSkDB4i2oS9yf94o3QUAl8a872ju4cM >									
//	        < u =="0.000000000000000001" ; [ 000061128159184.000000000000000000 ; 000061138674795.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016C5A2B2E16C6A36D7 >									
//	    < PI_YU_ROMA ; Line_6162 ; DB3VRC8ZK72Uh7RX0rc5EBx47uytIsvo5Y3C2KgBS0uoo0wAo ; 20171122 ; subDT >									
//	        < ZDrDOeQW81B7O565ZKcbUKV67l378503VL18F6EZ8SwzhS7ik3n34Jy2s8OxeYXN >									
//	        < rjrT4lg51w31622GDtM5iqf5divs9uQYW2gBlN4cwCk5i3apYfW152xC8f71Hloz >									
//	        < u =="0.000000000000000001" ; [ 000061138674795.000000000000000000 ; 000061151538468.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016C6A36D716C7DD7B6 >									
//	    < PI_YU_ROMA ; Line_6163 ; D4pThdbOod5Xoa43J3pBjXOVh5leK9oaWyVk6p42V4RPlKBoK ; 20171122 ; subDT >									
//	        < ZWGsWKn377T5v071954w2zGnhfa0aXC66FP91RI0MmsZiFoqi5NDkJf9a8hcHCcF >									
//	        < 59407oM8e271i8ANBnI7bWwZWZIxqJD09GbhkIlvB94amh3c7db1js2yUyCB8g4N >									
//	        < u =="0.000000000000000001" ; [ 000061151538468.000000000000000000 ; 000061165910379.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016C7DD7B616C93C5BD >									
//	    < PI_YU_ROMA ; Line_6164 ; Lt7fSOH60lVgQWaIDz6hHkkg3VDqQnT7Yi1dkk524r6L0lRiT ; 20171122 ; subDT >									
//	        < 97Y1SRSrCgxhyrMW7PiGgGCK32lkqsZP5SYkrY9ALoI26E3is116UD3V8gaOO6F9 >									
//	        < 0oG5C2LnmQxBHy0SZ02K9w88Y7Cz58gb0rB6o5wgKuw6PDjA1U4lY3x8TOFB56M0 >									
//	        < u =="0.000000000000000001" ; [ 000061165910379.000000000000000000 ; 000061178890836.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016C93C5BD16CA7943B >									
//	    < PI_YU_ROMA ; Line_6165 ; y2IvOy27EPZ0R4d527K7R8CZw4Kl0D5acLZ2y8tnOzv6B8ZMS ; 20171122 ; subDT >									
//	        < pb0Ho8e59c2BTWU5tToVB38o2xI57eluFBKr9s2gwIpW5WZ8c0ptxm16Tcdj3DUO >									
//	        < 9I4EttOh4w89PbIu7enobsKH6129tP29r4bzwQx6ul4VqR308wQln8y9kv07fZKW >									
//	        < u =="0.000000000000000001" ; [ 000061178890836.000000000000000000 ; 000061192237881.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016CA7943B16CBBF1EC >									
//	    < PI_YU_ROMA ; Line_6166 ; 608KcEwVKlqJIQi0gLH1TI8EKK74T360SgRk6w5rd2PfnPLh4 ; 20171122 ; subDT >									
//	        < ckp7ybaW020z3ZWxj5a6Ht24WQBT7FvG90owD5FSz2xb7L7PBXnJfVpYD11yO0wd >									
//	        < Y2vqK44EOCnKIUE7cQ1bPiLy87LyXlL22RH5VK6nUTRsLFUVYzSPKNDL96mv4rx8 >									
//	        < u =="0.000000000000000001" ; [ 000061192237881.000000000000000000 ; 000061204448169.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016CBBF1EC16CCE9390 >									
//	    < PI_YU_ROMA ; Line_6167 ; 69OGt8Bj8zhTzQ968vpRNToOJTq8hv4DuIf4mg53EZsCKClO1 ; 20171122 ; subDT >									
//	        < L1Ea2HiF1w1ACwn6eEB22zSz9IItz9JZQ2o2r1860Y9X9Qg4lB7wXoS0LajTX0L9 >									
//	        < OdGWuhc4dj3a9w0N4wgLR0u1vJ4U34pgAUQ36Ve3E5WLKa8w3CSO0ZoFvrd2DpMy >									
//	        < u =="0.000000000000000001" ; [ 000061204448169.000000000000000000 ; 000061218456223.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016CCE939016CE3F376 >									
//	    < PI_YU_ROMA ; Line_6168 ; Oz0Iwp9QMRJe7F4MBktIgiSRvg9vFt37HR9k78rB090219im1 ; 20171122 ; subDT >									
//	        < lFCvqyH3PL4IAc5v9Yu1yDtzZnubFr3tZrZM75P8QRS3DZ7nWPfWRat7WEw4fEOo >									
//	        < ilV5u8ZyL6DuTfiT1sJ87Lh1KWJvBSv5oS4fabc188tT34eQ7Z750NXcc3w5ZAHx >									
//	        < u =="0.000000000000000001" ; [ 000061218456223.000000000000000000 ; 000061223570461.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016CE3F37616CEBC136 >									
//	    < PI_YU_ROMA ; Line_6169 ; W05G9N1RkG95kGrGQiYnLXL5k2i1bluLvEUG50IJj4p1u408D ; 20171122 ; subDT >									
//	        < q0Ron78DYWhaNMX7QnqDVZ77e8jYw9hbUFBHA6vwZe7yJZ1v92V085rRQaV4Qr85 >									
//	        < 2iJtM3gqm1r9r32rC9G2XLiRoZsM829BL4Q3Zhc4NjT2z6KgyJ2l36t5c8d988Fn >									
//	        < u =="0.000000000000000001" ; [ 000061223570461.000000000000000000 ; 000061231876248.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016CEBC13616CF86DA8 >									
//	    < PI_YU_ROMA ; Line_6170 ; 435a9R29c9qlrxrIQ66x2ci06H0068QgWxe8T9m4dz342q7Yr ; 20171122 ; subDT >									
//	        < yf6L9g401XTv8X9P2b3mBA6zPCs9D9Byb77SVSxUJW02Lnncc4EVg7ks4ge9l895 >									
//	        < 29Hq606RG82HSIVhAuV8INT2rGH55u1EJDvXhk00Lz8HWrCJ0yz6GGa3bgAf1CAA >									
//	        < u =="0.000000000000000001" ; [ 000061231876248.000000000000000000 ; 000061244500888.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016CF86DA816D0BB128 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6171 à 6180									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6171 ; 0657CNH2T5VmxxD0gE1u9O54g140K9wCGm90F14168Mg6v4tj ; 20171122 ; subDT >									
//	        < 9DJ088m30myC34b7eU0y43LWG8vGZrI07a10NE8379PO0R0xu99kClJVH2NcUfBl >									
//	        < 5KrE7o9zY56m48qac9sFM3LN5N9217Rvo0P753p41BxvCsV3fghi8WZqcGMyUW7g >									
//	        < u =="0.000000000000000001" ; [ 000061244500888.000000000000000000 ; 000061255756186.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016D0BB12816D1CDDC2 >									
//	    < PI_YU_ROMA ; Line_6172 ; 95F9D72MX9Exc5h0bl6o7MoPF7Ellc58m6pSL73h9N32Y328A ; 20171122 ; subDT >									
//	        < 347xS3b72ke0CXY8S6bvEeWp0FEf133KscIh7P148K14ijTz1bDr7Df7k73s4aZX >									
//	        < C8Xm8ZhTck4QmSoPok6zS55h7YoAmG46vW05Ac3Audrw4NAQNt97JmbhM0Y96WrE >									
//	        < u =="0.000000000000000001" ; [ 000061255756186.000000000000000000 ; 000061266104132.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016D1CDDC216D2CA7ED >									
//	    < PI_YU_ROMA ; Line_6173 ; 4u273rw1uMyLD3KFS63hE09LvArf8Qg0E2L906qJHJ20FBC8m ; 20171122 ; subDT >									
//	        < MhzDvef8j0rNQnG9rserUztPl376N89bb7hoWl1ern7UAEd87f0VKX0svNdlt83X >									
//	        < 1dYWLsmUOlKjrl5c8WqD6B0KedY676YXl7Le6HLsJaZ5XbQeZ1E9QxhL119d1z9D >									
//	        < u =="0.000000000000000001" ; [ 000061266104132.000000000000000000 ; 000061275145543.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016D2CA7ED16D3A73BA >									
//	    < PI_YU_ROMA ; Line_6174 ; XeUn8y2YC1M2mldI29zRUkZE3rk9ZVZ7D3wsToZlPRWeK93oi ; 20171122 ; subDT >									
//	        < 2r4xy8VtOpw1m3xw1v9tN9GGzthYbYi3N01eO1xAv3C8Ek8u1L27B32N5f4lqq8S >									
//	        < btE27STWtQS91yqw5545d5BCiJZT17V81J36W8ELL1oU4QM5w90opjahbPYtXWF8 >									
//	        < u =="0.000000000000000001" ; [ 000061275145543.000000000000000000 ; 000061289639081.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016D3A73BA16D509144 >									
//	    < PI_YU_ROMA ; Line_6175 ; 77pFtM3OC0yL9LJL5m4ZorLnr8e40kdsj7JFgWF52JO5eMkq3 ; 20171122 ; subDT >									
//	        < Duw0Pyc0oN3r4D4o933l36EF08OA3w9aU6hw0A3ZP3FJ0Z4gL2i2hTQDOTs34JVD >									
//	        < Y1pd0BDt5X5z3Sg4X2152VpIFzECNLoWqZCuW1u0mxxY1eT85TGe21pWKU2iMjle >									
//	        < u =="0.000000000000000001" ; [ 000061289639081.000000000000000000 ; 000061295928253.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016D50914416D5A29F9 >									
//	    < PI_YU_ROMA ; Line_6176 ; wc129VW4oM0f45At326l9OB0Ln5Dt7yc2n8zR5qgdyhMdH98U ; 20171122 ; subDT >									
//	        < Zj92T248v3VjE9kTcPB4i0L3Dzo2P9m20ugJ64Zx0bq91tdMp9c51TD48si5W7jx >									
//	        < 8DV48krgLBK77S4O7634h5Gak75L72mWRK26DxMz87cGWFb0t133Hs53L8APK3tI >									
//	        < u =="0.000000000000000001" ; [ 000061295928253.000000000000000000 ; 000061301910846.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016D5A29F916D634AEC >									
//	    < PI_YU_ROMA ; Line_6177 ; mjL4WsTAP8JDsSuGphyDS0YI360ML74t00Yz600e9I7UQc3C4 ; 20171122 ; subDT >									
//	        < QQhp611t5MbAbY4HR8voev4e6mFE5O3QG6s5JuJ367A5CmV5DCL94jfw0bPOJ4Vj >									
//	        < dZ3W5pQ2pZrsv8WK7v0sx5J4f3zbmT22BI8475JauZkPTjJBg0pkTxQUTWud2q43 >									
//	        < u =="0.000000000000000001" ; [ 000061301910846.000000000000000000 ; 000061313461765.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016D634AEC16D74EB00 >									
//	    < PI_YU_ROMA ; Line_6178 ; P9e8WGxYuH6Z3uckiA19t869g6TW8pJ3Ed5F3ZRGZLP895GaP ; 20171122 ; subDT >									
//	        < Z9hFg526jqhHWuP9zdbzCCvtalU7JKjrrDL40f6E1gx42jgcdYi399YFyyd0R0Cv >									
//	        < S9HEEYXJHahcFg7k5o31JAv3BsTOjB8sFl64AHFByotLUt8HCvRY3Y518z0E3QPr >									
//	        < u =="0.000000000000000001" ; [ 000061313461765.000000000000000000 ; 000061321855031.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016D74EB0016D81B99F >									
//	    < PI_YU_ROMA ; Line_6179 ; 644TUyga2JCzs5woI1404725wwgrSUSFrBxyhoAgL7RGLq45S ; 20171122 ; subDT >									
//	        < m2dY6xrxLj4Y17Dy0iFogL6428HAxz15IGy7K0B8z4O2v0e7tqu10w72xhd94eR1 >									
//	        < kMwvnDX5zs4Qt9856Us6TybBel8nFxl5zE6y5EJ8bPPiuSFcaLpTX2mJ4mEhPV7c >									
//	        < u =="0.000000000000000001" ; [ 000061321855031.000000000000000000 ; 000061332826522.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016D81B99F16D92775C >									
//	    < PI_YU_ROMA ; Line_6180 ; GXejvoG650LnR9M1697wGF5C3dYXB5SyvjfqrL88Gcr94wL5R ; 20171122 ; subDT >									
//	        < 9OVdoQivENqqIBDlBG5B0LSE732eiUcJIUI7Ga23ZPM3oC022wx0S6uCjTnyuLfQ >									
//	        < KpVX3aHHPFl12a36UPn5DzCHfj6yd79wYgj226h68KpK9344O8A1m9982w4qT4M4 >									
//	        < u =="0.000000000000000001" ; [ 000061332826522.000000000000000000 ; 000061340979616.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016D92775C16D9EE829 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6181 à 6190									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6181 ; Xu8s1pPQJt10FUrqUu04Krp1eT94nxexR3DDo6O32gL7z4IPl ; 20171122 ; subDT >									
//	        < MjWcA88sRX6P8ckFX1199PoAISp9Rx8Es1D15QP3Dn516dkHoV4Cf3PpYBxiJ4Yo >									
//	        < 6QBqtTY47B6Z0sNiiAPYQ7rV4920qh4wsuIO4zlSUJoXs06bLo7G7qcQQ9A8f3CU >									
//	        < u =="0.000000000000000001" ; [ 000061340979616.000000000000000000 ; 000061352976020.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016D9EE82916DB13642 >									
//	    < PI_YU_ROMA ; Line_6182 ; OV45l1Z842879IRTQV3Wab5HXI5734EmZRSe31m64cd2GhKe9 ; 20171122 ; subDT >									
//	        < gyY7RM9BXX31kJ0eY1crs40URh9RP9HHYB5VlWmW66Ot62EgcY3DaM8eVWiUE1n7 >									
//	        < kO230fu1zWmOlamt13maY3uwM27f1u4dD3k0FSHa6X571XRLw684APPELzS4wAof >									
//	        < u =="0.000000000000000001" ; [ 000061352976020.000000000000000000 ; 000061366866018.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016DB1364216DC66809 >									
//	    < PI_YU_ROMA ; Line_6183 ; mMgM93WV11qy0B4917SJ7AeTmS84Yi1T4p105UuE1XL2bt03W ; 20171122 ; subDT >									
//	        < RqLEs5zsDLAUW8c994zWIN5UO5Ot3u5WvlM5t5PZLsJG5qz44qWGVJYl85kjHt03 >									
//	        < sRAC7WIdgf261clR6jgd145x80gk86tkSH3Ggp7cSGwhB4c96zDH1apUP1272v7g >									
//	        < u =="0.000000000000000001" ; [ 000061366866018.000000000000000000 ; 000061372592589.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016DC6680916DCF24FA >									
//	    < PI_YU_ROMA ; Line_6184 ; 1158ZMk30MdO0QMS9q88g97t1Bsz1L3jFe0eEJYxTty2WMJP7 ; 20171122 ; subDT >									
//	        < v0M9Iacq1yR9qQO6s4P9ZGQ82K11c2hqjh7fpeg9AE452C6Ts1dpHnTxA1ra89nd >									
//	        < 2rm3P3MRLhANrQ89K4x6QB4J5x0462rf7Q12tSOZtq69f18MFOYsQO5DCEn02m51 >									
//	        < u =="0.000000000000000001" ; [ 000061372592589.000000000000000000 ; 000061379695534.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016DCF24FA16DD9FB91 >									
//	    < PI_YU_ROMA ; Line_6185 ; 0gvjO25KpHSBZA3Hj6Gj52RNwiv3nFK3zZ0cv6iWaGJH22273 ; 20171122 ; subDT >									
//	        < k64i06lWu4gODAQHtx34DK4Lci82xuR9MI1OHwE5o9Uk9tnnfhC6k4s02paShk90 >									
//	        < y3Icp293PIKu3EHP050gC24qlKUDJP36Aq5MG8yHv316x6QxInU1qtdsm534EBVn >									
//	        < u =="0.000000000000000001" ; [ 000061379695534.000000000000000000 ; 000061385672157.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016DD9FB9116DE31A2F >									
//	    < PI_YU_ROMA ; Line_6186 ; 75fbPq6YgQV79ET275fGLHJlVXoFg38D033FH1DIur02xA2hM ; 20171122 ; subDT >									
//	        < 45Ua5D69A7Yi72ngbfh9F2CwnIf3e3ETHmkVmvH2fzHc919gJVT06cX5k225VbYC >									
//	        < Azypgf7zevr12x04A766X92lwU19Oin7o0Ck3hmK53DSBON46vbM8H4ky3xUvfKw >									
//	        < u =="0.000000000000000001" ; [ 000061385672157.000000000000000000 ; 000061399190389.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016DE31A2F16DF7BABE >									
//	    < PI_YU_ROMA ; Line_6187 ; Z30kR71f3I217R5RRD9Vkn2Dfk9Vtj6289Re1DozBd4QTs402 ; 20171122 ; subDT >									
//	        < b4FntdH2x3I6Z2A3Em1DlP28u7575CZH0XZz4I8b0gae6YJ6YxCQIFEV43zK3a9V >									
//	        < 4j9fQRc5La8F8AO1gATUnsLD1brAEOR2HPqv27P3j2FH5LVk3aRkLq03242eonfr >									
//	        < u =="0.000000000000000001" ; [ 000061399190389.000000000000000000 ; 000061409962592.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016DF7BABE16E082AA3 >									
//	    < PI_YU_ROMA ; Line_6188 ; Rrq6qmzDnHSpgAJXFuJ713VNpi0d42cIp9G81tethcAphF005 ; 20171122 ; subDT >									
//	        < e4hthzI00uh38HfrNS1217bp76v2Hov55JSjmaaoz2x0pS1p5B9zuarfj4yS569A >									
//	        < Z7Sf372wq9MxZJSAsG4k3E3RqJd2pFbNoXkVogqOC13x3A78LR74Kbgt9LfS403J >									
//	        < u =="0.000000000000000001" ; [ 000061409962592.000000000000000000 ; 000061419060923.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016E082AA316E160CAC >									
//	    < PI_YU_ROMA ; Line_6189 ; Z9XV82t3TmyoIaXh7bIx4B9drGSS29c00L8KEEDHO23JBf9MM ; 20171122 ; subDT >									
//	        < T0N053I11Gaf06DQoYj6r9576l754Qq24P253FlaY4AamhC4Uf5mwh5ucjYV0l40 >									
//	        < DTM4Ac4y58dlv7n9WjQn0H6bfBl610HQbY78ygMGQQ2UCW3hQgvR6vtrUuZI86jn >									
//	        < u =="0.000000000000000001" ; [ 000061419060923.000000000000000000 ; 000061432917988.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016E160CAC16E2B3196 >									
//	    < PI_YU_ROMA ; Line_6190 ; LeNg25A4fVX1C7mWo55r2sAYlNCD7fK6X49IwL62fzaaX8Zbu ; 20171122 ; subDT >									
//	        < RrPCfhOJds00I6NjW7D49A9o4815P0uhMVz98e2CHK3Up6WS7Xq5741HDK3Z6Cur >									
//	        < 3DP4eDffq3p5xKG2qO5id0510MZ3nCGe786PrPf979A9zpXEvZ9vqM4v8NfRHA8i >									
//	        < u =="0.000000000000000001" ; [ 000061432917988.000000000000000000 ; 000061447669700.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016E2B319616E41B3FA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6191 à 6200									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6191 ; 80OfUN9mBd7L16bTFGz9G2N6p466306V1fhM6Hbdf4xUeM61G ; 20171122 ; subDT >									
//	        < P0MEja4bUhTEmYc22s0jpU8Zr74ZsHE6grNj7V39V8s2cttkYrkMFx4Db4LyJ824 >									
//	        < RU1hA4H884S6Ow2xu7at0eVJCSq2bK7Gh2oFo4lu01oIlmJ8M9iuj4r12W80zwAR >									
//	        < u =="0.000000000000000001" ; [ 000061447669700.000000000000000000 ; 000061462660500.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016E41B3FA16E5893C2 >									
//	    < PI_YU_ROMA ; Line_6192 ; Xrb7etBpI1LfD4vQqnz3Zc8uSDc4spw8sCFHc5H9990t190XY ; 20171122 ; subDT >									
//	        < MR30fKOTNc1b8Vat24xig1tHckYkBvVYI6WTnxFzW8BYd0D5XusWr870adH6NCvz >									
//	        < 77U5aE4yNw1h76OHz4K664TkX53cE5cYvkzF32z0kcwl8OTlYcZD89sNLOZ6vFL1 >									
//	        < u =="0.000000000000000001" ; [ 000061462660500.000000000000000000 ; 000061471634625.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016E5893C216E664546 >									
//	    < PI_YU_ROMA ; Line_6193 ; ou675afjt292lE5rkM9VG7t968ziPUYYW4eY1l09WbTyFvKx8 ; 20171122 ; subDT >									
//	        < JMOctTi8b0hN4ef62f04972e89161iiC26avUrC9pb850eIpUrJ8u8JXSdl0c8zL >									
//	        < C9gAph3LTPT7rxO35IE4iB5sNC9L6kJKWNnIG6DvbGH265o755B9z8u5ahEK1u2y >									
//	        < u =="0.000000000000000001" ; [ 000061471634625.000000000000000000 ; 000061477418619.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016E66454616E6F18A5 >									
//	    < PI_YU_ROMA ; Line_6194 ; lo7Fcwbe1567eHNOkn1812Ux85YCZ7f623ILIl8aVW5uCXbaz ; 20171122 ; subDT >									
//	        < AXgmuJ4MRW4qEM5Jv6Ldo7y9Cd1lVWdae43A6685fT2rMF7Vwi90mUD91r2gsnqQ >									
//	        < 57cmmxyWXwj7YZvs57G5rJZt45WURJEqjhp320M7o6SQ1xOjFVl8KcWirY57mzHd >									
//	        < u =="0.000000000000000001" ; [ 000061477418619.000000000000000000 ; 000061488355596.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016E6F18A516E7FC8E7 >									
//	    < PI_YU_ROMA ; Line_6195 ; JZ7nbxnuonUQnEbqeBVGo56e2AJJgX2d15UMslPqVk0cYdxP3 ; 20171122 ; subDT >									
//	        < 0nq7z3pO47l1cSA7x30R589K7he6r7gBhOaW499l2sQOYm4UwmaL847gB52n85Ei >									
//	        < U46Viuh6Los3X15o3QNPM25V61M1415vws69OgQx7y1Z4T76iYvF82m4j0BXNK4s >									
//	        < u =="0.000000000000000001" ; [ 000061488355596.000000000000000000 ; 000061502226895.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016E7FC8E716E94F361 >									
//	    < PI_YU_ROMA ; Line_6196 ; By905V10841H0eejokYgMVw4rJe5iv64b27q1nDTswWq8Me9G ; 20171122 ; subDT >									
//	        < yrw56xw1140eqiX3QmMfbCqjz2K85AWTL7kMUaJS798eh0j2e5izAW9RGF8u2XLZ >									
//	        < X73znP9KLHQ8q8aH4ACE13d15488K82MT0BOHDT76i18KW1bUT523S49oe76somG >									
//	        < u =="0.000000000000000001" ; [ 000061502226895.000000000000000000 ; 000061513212522.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016E94F36116EA5B6A4 >									
//	    < PI_YU_ROMA ; Line_6197 ; 5fs4e7g98J555z13s86M8wN2q8I7O73aDI8Y8mDGr6pK7026L ; 20171122 ; subDT >									
//	        < Dgw300keV1M5IkfgAk06Y5l1UWuQ7zVPfGflaOzTR7sKoJ6Zi9upwcUUQFScTTU3 >									
//	        < E3s2am74Q8534v3MWb40B4eOTt25Ow3uSSrj05biE8w5J0Uq7Fd568Cgu3vuK24E >									
//	        < u =="0.000000000000000001" ; [ 000061513212522.000000000000000000 ; 000061521254924.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016EA5B6A416EB1FC34 >									
//	    < PI_YU_ROMA ; Line_6198 ; 9D5pfRZhY7fIN2R7W34vI9AKE1cl8uVo11Wev4KxqDgW3D79e ; 20171122 ; subDT >									
//	        < 9Z7sEb3933L208bNARLkK8bzridexlHqFkPj4cix9R63gp60DNZUuMvmI93Eo7O8 >									
//	        < istuK9Hpmouv0YAde9mb44f7B07ln2t74O3jTwJ7XBlqUkhu7DV7jR8Hb123olLG >									
//	        < u =="0.000000000000000001" ; [ 000061521254924.000000000000000000 ; 000061532210871.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016EB1FC3416EC2B3DF >									
//	    < PI_YU_ROMA ; Line_6199 ; 7Wlptba4LDXpmXTeVJ5yK10EKV94Ls7yHhA7J97sLSgX61zq1 ; 20171122 ; subDT >									
//	        < qextE1um4Fr6RV3SnNJMQ7yyYWHYT5o2Ev0Q6Tjzbx14fnIUu2wUIhKkVE811eHh >									
//	        < Ndhyd6xb2e8zEMiKs16f4xr951RV0A0xK95nnE011UR3993oaaQx97MhAfLoOAy9 >									
//	        < u =="0.000000000000000001" ; [ 000061532210871.000000000000000000 ; 000061544370927.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016EC2B3DF16ED541E4 >									
//	    < PI_YU_ROMA ; Line_6200 ; S1NO7zP8Ks5LG4jMe7yS72lw9p4l843Jh9d8190lcw8496xv4 ; 20171122 ; subDT >									
//	        < 0ns832f419pm97kSP3fqu8PJ98nOvD889Edl6G1z4e8L6tv4Z93v868Qh93gXZmK >									
//	        < N1SVrvt0m2N5BIa06y6t7jCK28UmM5SH7tl6anMB21CpN8uR0CCK9Hqs90695CZ5 >									
//	        < u =="0.000000000000000001" ; [ 000061544370927.000000000000000000 ; 000061554798575.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016ED541E416EE52B31 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6201 à 6210									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6201 ; z21nl7T3VK72cX2W5exX5OJ9Nd604zZ1wE7op8806E5KG0pL5 ; 20171122 ; subDT >									
//	        < Zwur2YKB477Zy9ea5U2Ty525cQ7L4xHk1Uye02K65IlBtwg707au1AAQF429sh17 >									
//	        < 4DY9X3Kis0wXjvvS38ezAwI6hpNRf0Lse44y58g25CVus1XI4Zdz0JiTS86941C9 >									
//	        < u =="0.000000000000000001" ; [ 000061554798575.000000000000000000 ; 000061563329353.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016EE52B3116EF22F87 >									
//	    < PI_YU_ROMA ; Line_6202 ; J82l2g7sCN50pSI75U7i5c88669yZmmnUSj6E7nB5un62s69u ; 20171122 ; subDT >									
//	        < rOIQ9C4kEl0hRpTOGiJ6hLbEx72GqMqa0919CSCcahpVSCbGt29HH8F5VF6FK20l >									
//	        < VM5btT9tbw34F16Z2IwAAz0ZyweBvSkc0XvBDl6Wn820ndJY98JU8o3QCJnTIR3B >									
//	        < u =="0.000000000000000001" ; [ 000061563329353.000000000000000000 ; 000061569850532.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016EF22F8716EFC22DD >									
//	    < PI_YU_ROMA ; Line_6203 ; xuE95fm919z8JK85SLUKoe89Il3V3VV08tZf9492L2WnYs2f8 ; 20171122 ; subDT >									
//	        < 2N12livA05ZE8W6vkaS8XY9570z1tnSpAaK25r211Yd5T2JO0WSKM64nRa85C7ei >									
//	        < nPdYXaC9n8EoPaZC61sW4d4qc0l1Rn1otrvYp00581mnzVB8PUsM7s3OC9n07GB4 >									
//	        < u =="0.000000000000000001" ; [ 000061569850532.000000000000000000 ; 000061584278981.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016EFC22DD16F1226FA >									
//	    < PI_YU_ROMA ; Line_6204 ; 2hTH86PfXqHnp2ZFWhlt76BY7cmJG7jpULPU6r9lIFvvax2rO ; 20171122 ; subDT >									
//	        < xSKvElCT60MlwFcd3ks8908LgU0x7H5yEvN8Y8xuI6KpFFQr17mvAC04aMo54fV3 >									
//	        < poa00vSy489v5y6Ik158p9oyX12T375q4XeoL5I2GmWa6zW9EYUiA7gS8fqZb2da >									
//	        < u =="0.000000000000000001" ; [ 000061584278981.000000000000000000 ; 000061593677314.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016F1226FA16F207E33 >									
//	    < PI_YU_ROMA ; Line_6205 ; RYS94wVT3om2xHgW8rx006JJ91gg197f1zoim4wI4ojF444oZ ; 20171122 ; subDT >									
//	        < RiqB9K98G096cVC6s6NpTsm2ox7gFfI98Wh61p5FzOc35krrlU8rdagzn69lt255 >									
//	        < 4hmdz622H1f0r62zTWA7b99AoSmDp2JBj7vbLP06k48no1gXPbXi0r6U1mVp8n00 >									
//	        < u =="0.000000000000000001" ; [ 000061593677314.000000000000000000 ; 000061605377792.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016F207E3316F3258B3 >									
//	    < PI_YU_ROMA ; Line_6206 ; SmIz3x0pR30Yfb6gn5LTFN7aMbRYzj6NeH6P97UMvMkgsmN48 ; 20171122 ; subDT >									
//	        < x45Klocsgy8Kv2sCXT04sl3b63w1x3IZEaz9GBn0t9gHB795562cwNRxBTEk5aTu >									
//	        < YIuZdi57Mc5c5V57Cm0vxXnlPV2Hhr8Tx97j3xK2Auh1Rr2Nkwe2O1xlifm9VsBp >									
//	        < u =="0.000000000000000001" ; [ 000061605377792.000000000000000000 ; 000061618856220.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016F3258B316F46E9B6 >									
//	    < PI_YU_ROMA ; Line_6207 ; nmu5hDRxW2GW9PbfkTUSi9yEZmuPqNp92upjj0h9sE5jZ8j6u ; 20171122 ; subDT >									
//	        < oauE9408RD8xMbM8xuqJNQJQMWRxDmx11fY0b3I3N8g416y11k5dzkBOqZ29Pu8H >									
//	        < QaPWdDcy3pmR88vouL1V9YXxGv8kx09Zm9m8aIISg223Vp6TfBaq2wmHVfNd15fK >									
//	        < u =="0.000000000000000001" ; [ 000061618856220.000000000000000000 ; 000061628807822.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016F46E9B616F56190E >									
//	    < PI_YU_ROMA ; Line_6208 ; 2b1GTExOhJCSbOkw5I9M2MlHV4c069Cbe9gpfg0GiwGK9sp7m ; 20171122 ; subDT >									
//	        < 3L5J52tAg7CRat767YOQQeNLak1Y3Pc0wWZyyHxPfYC976mBO673191g69ncMZ5e >									
//	        < PIH1ZMVA53y0a12l0KU5FaJzA4Ja0N0fl3Ho8tHH4I73e8ullJMjExNMD6sb7qOb >									
//	        < u =="0.000000000000000001" ; [ 000061628807822.000000000000000000 ; 000061637064710.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016F56190E16F62B267 >									
//	    < PI_YU_ROMA ; Line_6209 ; oj5renl3N9rXj6e3TQ79VovIlgD2IGWboxl3Ao4p4h6Gj2Zf1 ; 20171122 ; subDT >									
//	        < 8l12sI51HpJZYkoTx4k11Dfa0kcur3F2t6v45gp1S8gIRpTWZyc345EmYX67D99K >									
//	        < Y970OfC8f9ovH8sBdqVJa6pl447uRGDP4x3xFsJ46WoCij1WK166bWHlD8sLrkAj >									
//	        < u =="0.000000000000000001" ; [ 000061637064710.000000000000000000 ; 000061642622798.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016F62B26716F6B2D87 >									
//	    < PI_YU_ROMA ; Line_6210 ; 8Ykq8cu9D0RH4USl1Z2em8g0quNNt80334T459tew07Etf4pp ; 20171122 ; subDT >									
//	        < 5DqkS9InEUAYfX6xtQ0298RMr1UFSjpBoov1Va0mlAAPU47QEIWUuzTl0S7jOfeG >									
//	        < 631c0B1NRs0778pY18bp780mO71El6prLtve2o66vg0B35T0KoCx2v3vYJHEmf2q >									
//	        < u =="0.000000000000000001" ; [ 000061642622798.000000000000000000 ; 000061656690201.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016F6B2D8716F80A49C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6211 à 6220									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6211 ; luK5a9223HmTc8o5pKsQr9kNqCQDmU5UDpYElB5eb6T3U96l8 ; 20171122 ; subDT >									
//	        < 1Cs1JRjIBH4gF7V1366LeVZ7hulWapb7q6ewxS3t1WP79j0jcN0VncqUGgrx53Bi >									
//	        < 49GS5b95MTwuNEif1L4im7l9Q9Clr7o74KV86FraHaK1O5RyB7OM1bJ99r51x59w >									
//	        < u =="0.000000000000000001" ; [ 000061656690201.000000000000000000 ; 000061662124801.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016F80A49C16F88EF80 >									
//	    < PI_YU_ROMA ; Line_6212 ; 9p384uy16m8P9VBQR124ZH0L4h1fnxDEmKlMcFZOA64ecQ2Mh ; 20171122 ; subDT >									
//	        < 75K2jKZs4My55Ueu51822P19Xc1W7W5M5UnK3SMj8NYS4KB1gye0M3U9OH0EV7oc >									
//	        < t539c73h0xr2493nCocT85OV43UOyYrZs14Kpd95GAHP92ZX06433DyL17W0V5VE >									
//	        < u =="0.000000000000000001" ; [ 000061662124801.000000000000000000 ; 000061675943199.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016F88EF8016F9E054F >									
//	    < PI_YU_ROMA ; Line_6213 ; sYvEqnyC26mu50lkmW2gXSLj13dv4QvxEjx660gvodPY5mQJm ; 20171122 ; subDT >									
//	        < Rdh65D7BpS70T46ABM7D2k94Q74cr40bC4M56n6fhn31vr7xWB7Okf0TN4QMmqCa >									
//	        < pJ771sWM8tUXlHJpz1o18wECh3R95c66lorw8n1EX8JZb41oTSHZ61kUe0G7gy4a >									
//	        < u =="0.000000000000000001" ; [ 000061675943199.000000000000000000 ; 000061690702541.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016F9E054F16FB48AAE >									
//	    < PI_YU_ROMA ; Line_6214 ; 2YlnUuyYsuU1slRTT82g8cKjdfm1byu49EpU37MZ5G2155Hyt ; 20171122 ; subDT >									
//	        < E4q844q52z408smwOkd7pf0PDpYma6DFL4H975oCP1258190M57XqyqtUu2H3XbD >									
//	        < b0Bv983IVxBf1mILwk29L12ulCjti07Xc1ee4u7Nn3YN7BdT8poySGLtslNZlW3A >									
//	        < u =="0.000000000000000001" ; [ 000061690702541.000000000000000000 ; 000061702259463.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016FB48AAE16FC62D1A >									
//	    < PI_YU_ROMA ; Line_6215 ; 3dI8X28DlS7iKtNOlwJ9e5I6aODBYeB844xJiWRahxi78B0yB ; 20171122 ; subDT >									
//	        < T9uQcaDXuY4q29ODehPEwD52uQo46Wf1s97z71Xe4LlJ1k21rIa8Aqn2emEhmioI >									
//	        < RF3jjC48898Bo0KpNWx26k4IFF43KuzPj1AMH28F6EH9tYA3SoueO64sEqWGND7b >									
//	        < u =="0.000000000000000001" ; [ 000061702259463.000000000000000000 ; 000061713257745.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016FC62D1A16FD6F54E >									
//	    < PI_YU_ROMA ; Line_6216 ; 75P5Al3dogPBhe0vzF6u22cA351Bw0hKxg2rgn742zl4ElTbX ; 20171122 ; subDT >									
//	        < JBlK5SB5kip17PaGnU9pFYgLq5yjxhLUYJ5efd8Qa9Sqx0dx2PDq6yBP4g56MTUD >									
//	        < 815Sqyx6L9kn5m6A48owNRt134I8S05XISFErL40A2tZ5zDx732yA4Crz04nT562 >									
//	        < u =="0.000000000000000001" ; [ 000061713257745.000000000000000000 ; 000061724470835.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016FD6F54E16FE8116B >									
//	    < PI_YU_ROMA ; Line_6217 ; Ix24nJEM2Bo2xY586k2jlnTPy740azv98K177TGUteXZa0Ke4 ; 20171122 ; subDT >									
//	        < a2Qy61K1n2UN9i2R7roypDgIsBLRfnsN4Hoydti52o1LN0NQUd80oi2eaxzu5O5Q >									
//	        < eWuP5Ebh350GKGAS63K814GI3Oie11W2c2V1lcPktyu7b18YO0t60jX8p42n4dm9 >									
//	        < u =="0.000000000000000001" ; [ 000061724470835.000000000000000000 ; 000061736074471.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016FE8116B16FF9C617 >									
//	    < PI_YU_ROMA ; Line_6218 ; O9Hxxd9q1cRwjuMzk21Y35YeTZrm1u4HFR19Q2Jqcv49j75W2 ; 20171122 ; subDT >									
//	        < 3NVlnElLXNlX1872D0qHE929iLKJkdipLFhWNig5357XcLNMlLUtBTVlA9w4wxEO >									
//	        < 5RR1ffHxoRJlud6lx9KfuNA3W6hpNLAX3P7F6656Y5nUUSlVb9w73hVfDWQ4MaQX >									
//	        < u =="0.000000000000000001" ; [ 000061736074471.000000000000000000 ; 000061748403872.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000016FF9C6171700C9643 >									
//	    < PI_YU_ROMA ; Line_6219 ; 3raDWfhAz1R4RMC515KH7cV478xwXNd6774080OIM9BP3Ad6G ; 20171122 ; subDT >									
//	        < W047S1jcW6onXYsKO9XnC54vEKBQLuPPS128708MX5K4HO03PFw0oxQBVEUL09ze >									
//	        < 1U55M264K7yy1y9dhG54aysyas2lUMuA255TOZ85JBAMQZOf68Tf1Y442dgf2woe >									
//	        < u =="0.000000000000000001" ; [ 000061748403872.000000000000000000 ; 000061760826711.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001700C96431701F8AEF >									
//	    < PI_YU_ROMA ; Line_6220 ; H4HZ9QHAljH1vtq2h5LF3CqzTc03Hq8uIa69L2L31QuXl5RuT ; 20171122 ; subDT >									
//	        < 7X40F7NwTXJ9tAdAKMr88zxlbJwwblvgiRL5Jt0X73sg4nptFuyKC7d857QGRs4s >									
//	        < tRtCok7rt1qV0Zr9ojh4j6EJnYEvKe40S87BT43FSb4R0xN0P88rsOQn0O5TEKPu >									
//	        < u =="0.000000000000000001" ; [ 000061760826711.000000000000000000 ; 000061765915784.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001701F8AEF170274EDA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6221 à 6230									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6221 ; qFR8pVFyW51LE5Q3w8Lc7Huf51U2kDnXG3V8lSwoaGz3A5a6P ; 20171122 ; subDT >									
//	        < cB64Y1LHSvB25ZJIHgj6389n1DpPJo42tk1lOM6szd63vIW4WNn5s0e1GsAoG59N >									
//	        < PD0fsMkt92sKhcW965rtiQtdDg0bJ65LbX33Ox2CL3vUbbH7H5CQ7ZFi4wiv3JRi >									
//	        < u =="0.000000000000000001" ; [ 000061765915784.000000000000000000 ; 000061772441553.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000170274EDA1703143FB >									
//	    < PI_YU_ROMA ; Line_6222 ; rGqXb3e27g95Zhfpz2hG4zJ29ceLJfvt1oNf3A0Gc0LeUpHEm ; 20171122 ; subDT >									
//	        < ZE23I2b1eLenq7Eax56BR5wtQAa5Zh7NP952KND2rY0Anp4Rvt5I7a8622oI37iI >									
//	        < hWP5XDLj15T61nObA3Ntw1999g3acUYfytoi8yXkqwtDc3ylTzCL148k2e5zwEo9 >									
//	        < u =="0.000000000000000001" ; [ 000061772441553.000000000000000000 ; 000061786884758.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001703143FB170474DDB >									
//	    < PI_YU_ROMA ; Line_6223 ; TYBd9308BTcVW28P014vgR260rD2aSD26np3GGZaxc340PfSI ; 20171122 ; subDT >									
//	        < WUEwa4NXrkYpinp4ViXI1w8nUj62Tur5Q8xS5UOSRgmcNHR30t4yY39hMt89abei >									
//	        < tq6700W4sek5v36pG26g44p19F9nBPZOJTIujzaBM655riPi7U269PDc6YMvGe0k >									
//	        < u =="0.000000000000000001" ; [ 000061786884758.000000000000000000 ; 000061795096649.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000170474DDB17053D5A0 >									
//	    < PI_YU_ROMA ; Line_6224 ; Nn78ds7R97Z48zHLWlLM90lZJLCko10k6C637geVTr02psF1T ; 20171122 ; subDT >									
//	        < v8KRZUMSD4ILR2q9KM2BLIpB481mi60jhB0jtqXXwrik4dYslMUU1welvPps6q58 >									
//	        < Xgx0vy4WJB9mrKBhBZkp0K82V1Sdn65TQl8hu189xW1g2Fy55F29qu0J172Pw8OT >									
//	        < u =="0.000000000000000001" ; [ 000061795096649.000000000000000000 ; 000061808925100.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017053D5A017068EF5E >									
//	    < PI_YU_ROMA ; Line_6225 ; YL91xu1RvIWHobF2cbrQh5VBM484TQ57UqP2fRTbb9vvP0IxD ; 20171122 ; subDT >									
//	        < lvsqIme81vbe71N6GD9xvZRVUq8d9bRG91egzZFLTy3qFRa0N9tOdg08T4a3S97p >									
//	        < 64EKkNVOl8xBbgicwUiunXkMcbz3VA7RN57lp97CcmIYt5K5xPhqms8Oyk8qGK06 >									
//	        < u =="0.000000000000000001" ; [ 000061808925100.000000000000000000 ; 000061817349821.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017068EF5E17075CA46 >									
//	    < PI_YU_ROMA ; Line_6226 ; KeQ7I6K577DXeY3lZSbJ5mgjI5gv5p9356B9jxOdmU8m34tjK ; 20171122 ; subDT >									
//	        < u54RP0yvPSknz8HQ3fYtxL5tnqR5R7WTqr8mscF0yI18dH303b00qWFGUgiThBDc >									
//	        < SI655l4OxrDW40EwP531Nq62CIxo0gc0Ax6bRL78A8Yx1iA60G46bNxix0XTNp97 >									
//	        < u =="0.000000000000000001" ; [ 000061817349821.000000000000000000 ; 000061831635632.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017075CA461708B96AB >									
//	    < PI_YU_ROMA ; Line_6227 ; Xbln13tV8p7XdWL143O0ANNTycO7o3KrPOl841OO8J8WYJRdM ; 20171122 ; subDT >									
//	        < 1pRt6S1Ps044NJ29CSf8TQJ639271ijpRtL0ohSILH4584fY58bRfIlqp5QWn6Hc >									
//	        < qTylU5mOf0P2VLEJYwVHyoP0RPg559X7qJA4pbo2hIsW37W9845o24nZ9Y3Q2R7N >									
//	        < u =="0.000000000000000001" ; [ 000061831635632.000000000000000000 ; 000061839681922.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001708B96AB17097DDC0 >									
//	    < PI_YU_ROMA ; Line_6228 ; 1GAlt1EXyY3QI46ylC8cvnt9h3206Ee1kkOkpNa7q2Ru60F39 ; 20171122 ; subDT >									
//	        < 5CN80GGZ65dH09dGvCmYwAZqEs1ER90Jy5GPaWLDo3qPMvXRU0SSPd6K7PMXhFZ8 >									
//	        < QRsb6ZdtM6XEB2hBpr8eY09Hjw6eq3M3DRbVApuVs0bbmr8ZNm02n4i25e6M3I1q >									
//	        < u =="0.000000000000000001" ; [ 000061839681922.000000000000000000 ; 000061846837096.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017097DDC0170A2C8BD >									
//	    < PI_YU_ROMA ; Line_6229 ; SVHL12skcR60Y9g8K8Y4xV6JA6a56lwoikd1eVR87VtW1QfYH ; 20171122 ; subDT >									
//	        < spMtbGb1yK7ADAD3QGYE0s83Y3VMddOrUxo5R8oO1Z5e86oTjOVHh8tPZ6SMkF8u >									
//	        < 5tqEiro04fs7sZoo1Ofk3r376KCSt15Z5tz21Ns6016L8rCRHFn0Xl81s0bAkx7e >									
//	        < u =="0.000000000000000001" ; [ 000061846837096.000000000000000000 ; 000061857852011.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000170A2C8BD170B39771 >									
//	    < PI_YU_ROMA ; Line_6230 ; zs49iw7V9oGHic74vhl13xFEtM52GhDSte2opTnw9vDVfsQ13 ; 20171122 ; subDT >									
//	        < RPX5K6dx9cPFqK8rBlsKql4AFRuukth0HSk8hyqNQFCHSt356fxaWcZMoHQjSspq >									
//	        < Dh5Bmnc7Qd14YUf317C8BDQl8n2qPZc2t8TkSSf0HrL6RdbNU7HX44w0UU03toi3 >									
//	        < u =="0.000000000000000001" ; [ 000061857852011.000000000000000000 ; 000061872143875.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000170B39771170C96633 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6231 à 6240									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6231 ; tE5Pye1fkeoayX6K79j2wmnU7bfYW8CHVOGKJW51EC36z31uc ; 20171122 ; subDT >									
//	        < PZOmsxRxbaYN8if9p3K908J10IC0gX0BGtxNbjuo8DVdI9xeX2FF2km2siBRq68r >									
//	        < 81hYN6WB6765rZCybO8La57J385rL9Y2ze9Ywl3rZc9KwII7588a3yXhvwpMIS8P >									
//	        < u =="0.000000000000000001" ; [ 000061872143875.000000000000000000 ; 000061878694575.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000170C96633170D36511 >									
//	    < PI_YU_ROMA ; Line_6232 ; 53B6pET7yab63ttK40xh345S5PGa3Ru97Q9KCN83Ri2yS1E57 ; 20171122 ; subDT >									
//	        < WwqcxRxjK0N4DHhNfb7viJk57MF6bY2KftdF8tV3YmY0Y3keRLIH65SGC2W22wfS >									
//	        < 4q05t1xGqG45E9aIsRA91Lak5SqSb1z7sT44lz3xK7qSmf9s494362RVRR4y4QMq >									
//	        < u =="0.000000000000000001" ; [ 000061878694575.000000000000000000 ; 000061883964118.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000170D36511170DB6F7B >									
//	    < PI_YU_ROMA ; Line_6233 ; cMP2gsv8mZpL4rgjJundc12t5v6Q8L16hz1sKpt145N3Gi0L7 ; 20171122 ; subDT >									
//	        < 1c8B15ULZB42R2HX592WPw931aS534HQ3dt3E7004c7F00l5hXJ8Uy3973Zp6xZF >									
//	        < EPK4InSqv2481oalnz9U5z3N6J4ewnrnfAku2294v829vpcs6QYlVexHSDXor56b >									
//	        < u =="0.000000000000000001" ; [ 000061883964118.000000000000000000 ; 000061889433274.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000170DB6F7B170E3C7DF >									
//	    < PI_YU_ROMA ; Line_6234 ; BWW789J78B7k1oqUNkoCmem6NttXLj7i8cPue8RHSBl1r6S3f ; 20171122 ; subDT >									
//	        < YlC5KigVqwvl58A3lS42S5AM4E6bBK5mD2yN4tDjcHV53O054utjqnl91M5a1Muv >									
//	        < 6D3Cv7Beqg7oQ7ggkXA62WbtQoHonW2PzU7gmSeFc5s9ENkX1Ct81lmaRcw7beNS >									
//	        < u =="0.000000000000000001" ; [ 000061889433274.000000000000000000 ; 000061895709667.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000170E3C7DF170ED5B96 >									
//	    < PI_YU_ROMA ; Line_6235 ; J0MtT7FRa79u4M0e0l4id18498k7FM00D1yP5eu82dk6hsC6h ; 20171122 ; subDT >									
//	        < 049skrksx37j1FMs6kCgSJd1q64qj9pw0etnEq64Fg53enH8r60ugW59Y2fJ4VOF >									
//	        < JYPTMtMj2n8O38pZ8xfZexRf6DV5ms5ddofubpeXVy767NRTMTPDmFW9Qjt836IW >									
//	        < u =="0.000000000000000001" ; [ 000061895709667.000000000000000000 ; 000061905656021.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000170ED5B96170FC88E2 >									
//	    < PI_YU_ROMA ; Line_6236 ; ci6bA5RR7cRl477lI583sP2FUGwR67Af8pPLk2wHX8B49xYTE ; 20171122 ; subDT >									
//	        < 57u3tXvCDLyd53SQ0h4Savg4LzQ3II8356hel3J1Tu415aXl34U2zcsmXsnbhqH9 >									
//	        < C8Mrd93MXpRRb8cSGefRjHlU9oX2is07xKY9PT1y98yt5071kz108Q5u00aQ3sKN >									
//	        < u =="0.000000000000000001" ; [ 000061905656021.000000000000000000 ; 000061912411072.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000170FC88E217106D793 >									
//	    < PI_YU_ROMA ; Line_6237 ; de67XxR3Ld84eiKxGrL8xsF3J9vDNDs0WUR7Z6XGRJw8S4JfU ; 20171122 ; subDT >									
//	        < E37BZSDgx8Bgo0CkhRShjANOJ1H10zO3IB1GBF0n9Sznemj6G70P5bf8S3f5f52n >									
//	        < dEtpIeUA4BTe04o9TG83IZnbl8g1tej8R17c2tBl3kcS74UfFv976sc66oz4tL5o >									
//	        < u =="0.000000000000000001" ; [ 000061912411072.000000000000000000 ; 000061925989093.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017106D7931711B8F7D >									
//	    < PI_YU_ROMA ; Line_6238 ; WucQ88t8wCD1UoCR5U51u8W35fsvT2X3QT297D00d47s5PG8I ; 20171122 ; subDT >									
//	        < m31dPQ5G2x29R0O7v5mx203Xi97rlZi7wfMN0dWJ2uT76G3tLIuYmIw1HbVvQ5uK >									
//	        < cDzTEuq7gOq8cE0XqAQ46Erfjg0LsG3w5j0w611C9Tg6qtIGJQfQL4ZKp0zpMJmL >									
//	        < u =="0.000000000000000001" ; [ 000061925989093.000000000000000000 ; 000061932400693.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001711B8F7D171255805 >									
//	    < PI_YU_ROMA ; Line_6239 ; tJF2tL7WcMGudWIzKXIBTtsPky3d5E8R3d2eP1YGyE1K8wceD ; 20171122 ; subDT >									
//	        < b45UQ6WA93G4VsHa7ox23g5fv716iBMOunJzMp1M9BqX3Hhr6iAjW470dby8i3co >									
//	        < 2ebiUSdxLgP7Vsse1Yd3XO53t6g57K1bNadsevmf8EJg8XuE33USBc2ixQ62MauW >									
//	        < u =="0.000000000000000001" ; [ 000061932400693.000000000000000000 ; 000061939104343.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001712558051712F92A2 >									
//	    < PI_YU_ROMA ; Line_6240 ; X98Pr2qJa2X6R4O60Gfj33ZTyewP2xav9BjTCuO8lgj6JL6X0 ; 20171122 ; subDT >									
//	        < yAngLNe4qoqd6dSXo9Rm1590Pg93C9T95d39ga54S36Bim4FwmuQcnQ79hLL1C30 >									
//	        < O8cK66I2e7rFl0ew8spGKN1epjZ0EDElmsY00aLS44FbP9DfKe9smn7I5p7eAWTy >									
//	        < u =="0.000000000000000001" ; [ 000061939104343.000000000000000000 ; 000061944502572.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001712F92A217137CF51 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6241 à 6250									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6241 ; xi43s5Ynuz7260e20146jDjYp5wcRWZfmZf2AJiXstwsE9I0t ; 20171122 ; subDT >									
//	        < PETCOWM8myW76fqAS0jo7k5ee3jl5Fv0rwS14OBCKYjg9sZlNJQOjos4fC3DgCXK >									
//	        < A0jkgynn4HnfAc9pQLBIYZ20a938Dgu646c117ACQ73T196SGG1Ekl2T9hi6cGh5 >									
//	        < u =="0.000000000000000001" ; [ 000061944502572.000000000000000000 ; 000061958720712.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017137CF511714D8147 >									
//	    < PI_YU_ROMA ; Line_6242 ; y9YMyum86mZ857xEc1qU9eCS1P1te7BpM036tcAMV8d026458 ; 20171122 ; subDT >									
//	        < D3dA4pZ79tUN188508OGgX6TA6lOf4TJMGl4dcXRCuXLP9zwVO14D629AB55Z2Rg >									
//	        < S7MITpZh0fRx2PmC5v0Wsg4zjPo5d8Y3Fb9J37pjq5f7vr290Qu8W6CJA4U8HYZ7 >									
//	        < u =="0.000000000000000001" ; [ 000061958720712.000000000000000000 ; 000061968392707.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001714D81471715C4366 >									
//	    < PI_YU_ROMA ; Line_6243 ; vJ86a463f3u4sP1D3SmLhJuO6S8fr0h5556D21pSCBta9Kf3L ; 20171122 ; subDT >									
//	        < RT8aTC16748mfw8r83hJQdN06e3TcB1h9JV8XEL3nSC2v4yekV2jcZA9CGXIJdU4 >									
//	        < 97RbgCt01c2gJv74X3vRt2GXUz95gq74038NkrJbmgnWq14bYN5K2hBZmy5s6J8w >									
//	        < u =="0.000000000000000001" ; [ 000061968392707.000000000000000000 ; 000061979226146.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001715C43661716CCB36 >									
//	    < PI_YU_ROMA ; Line_6244 ; Cn5rsFQ3kIJwEFFtr26qkz9BcXhJ4qEW4Nf4mareB0JRU77RI ; 20171122 ; subDT >									
//	        < H85g9M727wW91Gq7pSytp1OP5K1U5N5L2Jm5eO1cclC68gQ0e0Mg9H19V3Hhj6pm >									
//	        < tM4aaKQD2AIUE1DiIePVp1b661fBq99cTFc4B025uZo8I7BxtoNc80iXfw4LMraL >									
//	        < u =="0.000000000000000001" ; [ 000061979226146.000000000000000000 ; 000061984516429.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001716CCB3617174DDBA >									
//	    < PI_YU_ROMA ; Line_6245 ; hKdmBy845zP78Y7c4M0RxPcLqwc58HxIaK84lF56fOO4ncLD6 ; 20171122 ; subDT >									
//	        < oYJ6Sj2h5j6K7sLguPQxlF9NGzlS6wkGaWN5YnwLjVZcbthAl52U7FrO52gc9zrk >									
//	        < 5In2356eXyj555FD5ZN5tLu6J26KNOgYfk3k4pNTK9qRATaV1y1k1cGEH1Z5500t >									
//	        < u =="0.000000000000000001" ; [ 000061984516429.000000000000000000 ; 000061991689203.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017174DDBA1717FCF98 >									
//	    < PI_YU_ROMA ; Line_6246 ; 7PS7d6S1100csh69roq2bp34DCHGhEsZz4N19jR2a5kP77wO8 ; 20171122 ; subDT >									
//	        < u7D9KJ2VHV5ZGV9YhB9r121nt07lme5XWqmRj9Gzly2J6uYDPwT7CHIZ20X4RDI0 >									
//	        < 2AI8vL5NPs32WT74Wfq3wIlupi753nD942o1ta3WeySJTFsbMe9ReiAKxBj0kkSv >									
//	        < u =="0.000000000000000001" ; [ 000061991689203.000000000000000000 ; 000062000236207.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001717FCF981718CDA44 >									
//	    < PI_YU_ROMA ; Line_6247 ; H32303Hd4kmW4gVpyq9SSyq701BT063ve167fLWggb9KXDDSD ; 20171122 ; subDT >									
//	        < 23gQUNi41Nj5RrxfF4E3D7li9WSYhDf36wcTrn6vqkRBKoP1m3wyy8u1TS76hSQv >									
//	        < 4OiLi0r3X6n71txgC91zfPBnGWE8X969Da29FNBJz8N2IG1Zf2EmZLxMqph88bg7 >									
//	        < u =="0.000000000000000001" ; [ 000062000236207.000000000000000000 ; 000062012016170.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001718CDA441719ED3D1 >									
//	    < PI_YU_ROMA ; Line_6248 ; v68KvL8q04yIS9rmORhQ8uKeduARSW17a7eD1lLg1w37421no ; 20171122 ; subDT >									
//	        < f02X3VNxkkX13NNL4yXyvasFQ5c4hN74f156F394GJMAfuW1ZaLrOnLt9gjkbY6B >									
//	        < l9v8w4qu4epLRF23bqjXg0K6qrPiwI5kG9qSHBT524U4aY7Kav3e56Z252wRYJv8 >									
//	        < u =="0.000000000000000001" ; [ 000062012016170.000000000000000000 ; 000062018808354.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001719ED3D1171A93103 >									
//	    < PI_YU_ROMA ; Line_6249 ; SlFXbj5w118W3xS4GLO51Dz03jqLG9h3g40JS7603DGf1R676 ; 20171122 ; subDT >									
//	        < qXy5xGMaNa574Ir32xGiJ1BldENapJgZ5DLO80z6lse5q0GPVYg0P44lNFJ9Xo0O >									
//	        < 6013Wv7S67d4MLbR47CAqlm87wVW3WGK02D210MgziexG6Y4Ed169iLk67h68jkE >									
//	        < u =="0.000000000000000001" ; [ 000062018808354.000000000000000000 ; 000062032257037.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000171A93103171BDB667 >									
//	    < PI_YU_ROMA ; Line_6250 ; BuZj8XMJzT3g70F2u2Q8v7cEaxJPy5BxL5tyY2J4OY07Nqo17 ; 20171122 ; subDT >									
//	        < n4r3R1Uo3SlA9cAvVk74fj6Ou4uMjvb3521M8t1VMUAyYwmKp9LZHeB5WVwtgbt2 >									
//	        < R0xj94n6TJlq1o6wGx09T8Q2pknwHJTi04yqn7uG0rhB7ft3IN708iA54S9QJajs >									
//	        < u =="0.000000000000000001" ; [ 000062032257037.000000000000000000 ; 000062045853157.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000171BDB667171D27563 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6251 à 6260									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6251 ; n3bltikT7Y7357T2dc66V6qPJ3g6vc45vpzXEij7E622GndKo ; 20171122 ; subDT >									
//	        < 2TF3xtG0y77N6Fr7XTv41Kh2C7PymISjKRx1oF0b6q0doybYvCf68ft7XVCb18Xp >									
//	        < pPDm2257R79HJ35988PiWLaNPhXmLMB3bJy7l1NF4vbrFn2sZ4b7JU2sBYzK4Y2w >									
//	        < u =="0.000000000000000001" ; [ 000062045853157.000000000000000000 ; 000062057116029.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000171D27563171E3A4F2 >									
//	    < PI_YU_ROMA ; Line_6252 ; j22H3i7F59G27Z9PcEgs3yCQDA0g6wa968tQ6tywOJM7H3xtr ; 20171122 ; subDT >									
//	        < 0ML2Y635g7VVVaooW2k05V74piUGM0snpU64Yg95672zibeedqpo89sPdkDfz092 >									
//	        < 4TDpfMKsvsP17cVH37J2j49eC5N1rjm29v3E3l7BmWCVGAX897yHn0L0doadMkC4 >									
//	        < u =="0.000000000000000001" ; [ 000062057116029.000000000000000000 ; 000062069339834.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000171E3A4F2171F64BDF >									
//	    < PI_YU_ROMA ; Line_6253 ; 6M4ItPA8aO6PKr9wgnWmD3L1wKrv42F6r5AXdWC0Y3NCS4SZJ ; 20171122 ; subDT >									
//	        < NY7J61fom18hyKcj87uM8iD2omvX8cOqiH0w1v7Hc26J5Zi8g5l1cCF84XK6P06Q >									
//	        < BbgU2S458HpcrJGcwjH796hWE874v6y7bS7931Aqqz0ZOPM964ikhs7S2MX3a0ci >									
//	        < u =="0.000000000000000001" ; [ 000062069339834.000000000000000000 ; 000062082028712.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000171F64BDF17209A877 >									
//	    < PI_YU_ROMA ; Line_6254 ; Uopz22Ca5NUnzP6aMby19tdY6vne23Js0Vh2s7uUsKYP1HC84 ; 20171122 ; subDT >									
//	        < I7gmD6AHdKprMf74YBi2fMP7NgqKui211ZoyzRACV9NSQF97TT017DPerQ6U9EOF >									
//	        < s2rw5dDc7kWauVzPR6RsN6kr6kxSwt4SH0p25N012r0oW7aydPM6voOi3X6Gc2F1 >									
//	        < u =="0.000000000000000001" ; [ 000062082028712.000000000000000000 ; 000062087194643.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017209A877172118A68 >									
//	    < PI_YU_ROMA ; Line_6255 ; 2Mdp9tKiwBND6cS8XxY0Bh4hGiW3fL62vyUD7CU3cF5UW8Dfh ; 20171122 ; subDT >									
//	        < j7KS8URHm3M3iOsbg8kHaMeqBKA08H0Tx7yj9GFyHVIzz3MkI3c79Q0wQs2wU32b >									
//	        < n5777dN7ZjoN4Z6UMo1pm9YkYzMKlsLpwXi92876y6D4XyE8P4KzIcxLE3nj9l1R >									
//	        < u =="0.000000000000000001" ; [ 000062087194643.000000000000000000 ; 000062096355462.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000172118A681721F84DA >									
//	    < PI_YU_ROMA ; Line_6256 ; EEGc543KzRR5Roq915T7hv4n0A06Tg884RW680naPD8Pm2EEg ; 20171122 ; subDT >									
//	        < 1wt05hlPw947lxHPtzZ2S5MB9ve6Y972rf8yT7wXwk155ZAHyIBzia11AdS4Tgyr >									
//	        < e507o9E004FzIf2u89Wqjxcy3DR9yoGn9l6jfa5QDybce8YE356p0zWTq1vkSF43 >									
//	        < u =="0.000000000000000001" ; [ 000062096355462.000000000000000000 ; 000062106773816.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001721F84DA1722F6A85 >									
//	    < PI_YU_ROMA ; Line_6257 ; 83bsEJB8v40oG30C88GvNrHcpTDgPgSQTK0C1Uq6d5OQ010Eb ; 20171122 ; subDT >									
//	        < pF74uy3m98OV8CezbKHP6xm9Z4sYMX89ECbaV2bp2xaWG9P95C0DgOhDidh4b9w8 >									
//	        < Gxji6lpOkqN9t8Vh699ibzM788DD2H9u680a06Bj26n2cPzCkd46x1MQj2URL3mW >									
//	        < u =="0.000000000000000001" ; [ 000062106773816.000000000000000000 ; 000062114795747.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001722F6A851723BA816 >									
//	    < PI_YU_ROMA ; Line_6258 ; 4gLGBCaQUeUNicro4GNL31h5Zzn458VnU27FTTC536RNis5oX ; 20171122 ; subDT >									
//	        < m9QcYTtI4U4Ac268KX6A6gHd2744Id4ePOqOF6uX49pNYw25l61AQGyWLe4Ln71i >									
//	        < PRJ6Q53MO9ly6uRfeS6r39SrgYSd2qx3IjEW70X950lBCs4rrq0eV4652zMlhBu5 >									
//	        < u =="0.000000000000000001" ; [ 000062114795747.000000000000000000 ; 000062123982415.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001723BA81617249ACA1 >									
//	    < PI_YU_ROMA ; Line_6259 ; 1M749hQ2b2q555Npt4dJsbWE9J11rJ7hpVphCm7QR655zs677 ; 20171122 ; subDT >									
//	        < 91FG34R41ystoM2OMliSH8af0GsfKU5I6IYeV3LZ3LLe7wf8PU1l4RCdKE90pf17 >									
//	        < LWm8MAN3hfeApsq8hLfEa54a858P178QUlUqPb966oNAcF5OxnW01MYqXqTg165t >									
//	        < u =="0.000000000000000001" ; [ 000062123982415.000000000000000000 ; 000062131809372.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017249ACA1172559E09 >									
//	    < PI_YU_ROMA ; Line_6260 ; Wg5h5i6Y8vXbsHOxtFl2AC0ix413WvA586Oes12hwuRbh1pY5 ; 20171122 ; subDT >									
//	        < NEPQSJ8wn03qjbGG3v1K5Zcf6S52L42lWu9rC97L45f7jZ21FtBR0iYUxaGuMzu3 >									
//	        < TuV679Q9x7pR869l2j0EqjEwyQcuwP73mDX00D76lm7r84xZTAwZLaKH93wCi5jQ >									
//	        < u =="0.000000000000000001" ; [ 000062131809372.000000000000000000 ; 000062142976390.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000172559E0917266A827 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6261 à 6270									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6261 ; q8naIlI8de74Dr1kKX9oL0FC0fO18gsfuNMi6q5v69O7p6D7g ; 20171122 ; subDT >									
//	        < aXQsOi2B53mIajjm7dbU0G748Xbs8IK1A61RY0sN7p71y4N8fv91w7ObRGELB4ZW >									
//	        < 7v0pK8LS3R27fzqS787gEfdfmAVa3bbi7j0X36bpm7EIiGAsjvdC6wDC31W357FU >									
//	        < u =="0.000000000000000001" ; [ 000062142976390.000000000000000000 ; 000062150889601.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017266A82717272BB40 >									
//	    < PI_YU_ROMA ; Line_6262 ; H9nN28QIr4csl1LSI2VQA9hRnjKP1P7AZ9ZIqv9Un7TtfL16V ; 20171122 ; subDT >									
//	        < j5ni3ZOGYWbtF3WdPuo25Vt872AzPTy1BZeY0tF9U3BSB7Cs0579ZQB5R0zxCCk8 >									
//	        < 12M0Be0015Y7796XJc5JYcM3684pRDMH0YcW6562WFV9JQKm9S0O6P0UrPww6oEc >									
//	        < u =="0.000000000000000001" ; [ 000062150889601.000000000000000000 ; 000062163747157.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017272BB401728659BB >									
//	    < PI_YU_ROMA ; Line_6263 ; Yb2z40hs0lh8kVa3Ocsy29tiaNi010rtiLu38F21HTwppkutO ; 20171122 ; subDT >									
//	        < 275akrEMN0hy89su90LW7XNQ71Lf6og5c47tC7atm1GmjieXtzyxQt612OF2RWPC >									
//	        < bU81CnB28GZYcovDvz37OcgiOk0X26ik90h5ERtPbS6kWt2MlV0gf1pWQf5J38w6 >									
//	        < u =="0.000000000000000001" ; [ 000062163747157.000000000000000000 ; 000062171284229.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001728659BB17291D9E6 >									
//	    < PI_YU_ROMA ; Line_6264 ; wSHvfjignHfYF3Civh64uSLn9oR0RVJ7VPO0VMlvI22A7HbIr ; 20171122 ; subDT >									
//	        < 1YWAYGXBTZytmlzk7o30ymQ76wE8es7waYc1J44Js02yh4f8f8I97mb41jDL2ws5 >									
//	        < H47riaAn4OAM4CW5sOor6rmj3O4Kxz6ssuyn20594zaL5ulDb154nQjIuchEVU5Z >									
//	        < u =="0.000000000000000001" ; [ 000062171284229.000000000000000000 ; 000062186050524.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017291D9E6172A861FC >									
//	    < PI_YU_ROMA ; Line_6265 ; RZ2vv95wRr8eBN0h5pZVbRR1OUTepQ6DV7ZuWTOtPRM5It56L ; 20171122 ; subDT >									
//	        < gq5P5jAEyjE37MvJMrG3xDU8XFe2vx2buzPpwMOvZut3btMz5GXpNX2v4WvnRjuy >									
//	        < KY93ffG1LvZ3PBwITQsFid07D7D2Sx86UtC1r57YGGHUwKebEipg25m8bpGHTZQm >									
//	        < u =="0.000000000000000001" ; [ 000062186050524.000000000000000000 ; 000062198144608.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000172A861FC172BAD63C >									
//	    < PI_YU_ROMA ; Line_6266 ; 221W1I43Zf4efwGyPv25k7UJ7YP7y5aThc4vXjP9kzN578efh ; 20171122 ; subDT >									
//	        < iz9IyK7SJU16Lk4B4fC452Z6bMBlbi2Zkv5up4wmwNaU997vAJ6h09dk5LH1Y0f6 >									
//	        < t6ZVklg5w6DLGDTNLRCWF927nTo4mh5oZ9x9tOpiO1O09HnDe84681bna160IdSF >									
//	        < u =="0.000000000000000001" ; [ 000062198144608.000000000000000000 ; 000062204946835.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000172BAD63C172C5375B >									
//	    < PI_YU_ROMA ; Line_6267 ; 21XLP6vPcfA5z5IQQ2I1Ml3E9072jaz7m7WyhcfxM8BUW1UFU ; 20171122 ; subDT >									
//	        < Ju2waIzEhz6x69KSog9ft5Q6Mev7A863cv8Nx3o5giVgJ2C4p9lQgI98qzELEeYc >									
//	        < J97LGmU28eZe75m3X5puaaK0A7P2PKAp47C9r9RS5klQX1eVaiw5SAO1igWrzWeg >									
//	        < u =="0.000000000000000001" ; [ 000062204946835.000000000000000000 ; 000062218516190.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000172C5375B172D9EBE3 >									
//	    < PI_YU_ROMA ; Line_6268 ; PS0T4F6lKTYy2n41PeaEZe3sQwo0970fe9AVeJw6s7QbbvRSi ; 20171122 ; subDT >									
//	        < O2w5P2cClZ9KrxUeyp2Er2902rld6Ij8ejoShnL0uyO44bo5sp108ya71S11t8Jp >									
//	        < k7XLkn8evv46ycMZm2K2K9ITTKHpHD53e7sfE5SvbHmAjBYFo88A9DtJV5M584T2 >									
//	        < u =="0.000000000000000001" ; [ 000062218516190.000000000000000000 ; 000062229666357.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000172D9EBE3172EAEF6B >									
//	    < PI_YU_ROMA ; Line_6269 ; 15n4UZZz0jV73iwormZ4cUs3nBbe65xiGq4lQHW4MM72i5C94 ; 20171122 ; subDT >									
//	        < EP2F64Qdu2kkn21i451947f0bV4h4J06c2AiLUK3tJ0Y774308U1AnaTp5nOqD73 >									
//	        < TH7ut4eGH0xOR0Pz2EbV5Te3SgoU6ll157AP1TYfY47nhipC6v12uqI7bDgnv0h2 >									
//	        < u =="0.000000000000000001" ; [ 000062229666357.000000000000000000 ; 000062236889423.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000172EAEF6B172F5F4EE >									
//	    < PI_YU_ROMA ; Line_6270 ; HMYot21I86eHxfV3Is978tq956O0Z0CeOYEjaYDqveOBZf9NH ; 20171122 ; subDT >									
//	        < wcuRR63Q5b5MQZ40PqRVL2f3sB376FC7lBz7EU19TpwxnsqmyV67GYdJ07yU768T >									
//	        < EFevmJ7emKnp7p1NxzK3RrJ400dssa7sY2ib6S8XFhQQYQ1e7jtufYl2JadWD5V1 >									
//	        < u =="0.000000000000000001" ; [ 000062236889423.000000000000000000 ; 000062249487286.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000172F5F4EE173092DF8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6271 à 6280									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6271 ; 673m9GmhIsns2BS2fjLfYi95d72x7f96H93b3EfhrORBp2B81 ; 20171122 ; subDT >									
//	        < F16k7ta4wPzy4fcMTXbWJ7lJfqh3dTf9Aqm2p10zFB8fcmCk7bqJd45KHW409O66 >									
//	        < GO5q0w38Hac181joJ77gR5rrW1OgOET892l2AIpKsUGi8p7dPu81G43NEs243549 >									
//	        < u =="0.000000000000000001" ; [ 000062249487286.000000000000000000 ; 000062259800329.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000173092DF817318EA80 >									
//	    < PI_YU_ROMA ; Line_6272 ; b0937e1FdlcDx44FV37r53d91cLJMZaCf5X1ARo5dZSFa2M14 ; 20171122 ; subDT >									
//	        < jn4v9ZR41l26Y7MH341T2N21Zu7Z365clv87cnZ07j3VBLne0sD7nciw9v1y449Z >									
//	        < f7ebfYG1J57h20MVI9Ay3TiWg0C5ojfa4z8W75i674BdeJ8N0VoFU0koq9J9qC9B >									
//	        < u =="0.000000000000000001" ; [ 000062259800329.000000000000000000 ; 000062269186064.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017318EA80173273CCE >									
//	    < PI_YU_ROMA ; Line_6273 ; MUm1ibQwQ5FkGXOaEPwi35hUybS8Q7pv7W9yc56R88tCMDIBJ ; 20171122 ; subDT >									
//	        < 6L8qtNACnRT136474ro72hpQYRK1V6oDNT2ZdcijQU9ndM3qzvc21ZvfsQQw3pZE >									
//	        < 5WU5j1l75ZW2kAEjAlQt1it6SvFFKZSdzCp5zclezvQ0Qb14R1Z9hmMXv8XU545q >									
//	        < u =="0.000000000000000001" ; [ 000062269186064.000000000000000000 ; 000062277964873.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000173273CCE17334A207 >									
//	    < PI_YU_ROMA ; Line_6274 ; R3031BKyz0SNa3q7xWw0Uh1D8C8EyCoARA0Q451mbX4woJ0m3 ; 20171122 ; subDT >									
//	        < a92xn7MCgA8W5ty0GTIplk566ALUbC3hd0nq4HPCgc12VE7FtUglT2N8Yj1WPJGG >									
//	        < r0uwb66v3oUhFO14977LZ3gw9kz7t0NeqZ3645S40583MO400rKpr8f6ETc7yE9G >									
//	        < u =="0.000000000000000001" ; [ 000062277964873.000000000000000000 ; 000062285996529.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017334A20717340E364 >									
//	    < PI_YU_ROMA ; Line_6275 ; 5232nlpup3p4F3X4xxF4536H447Rmtdo0Q2z7A37VgSG9B5rF ; 20171122 ; subDT >									
//	        < 1Ly56262ylw2Tz8dt4SHIi3UbpC7937zAdWN7raZZ2MmjGewVbL9RxnVa2zY2bDm >									
//	        < aDI9chy052te9rh7Kl4kVYrq581Zrs4xpiWWXr1XM2RuPZf1NS7UQG2DfEa3DU89 >									
//	        < u =="0.000000000000000001" ; [ 000062285996529.000000000000000000 ; 000062297734865.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017340E36417352CCAE >									
//	    < PI_YU_ROMA ; Line_6276 ; 7cnfa4Q5iCm22B749Jo6Gv0YoNu71vey5t9Ljc7Tmmd14IA2X ; 20171122 ; subDT >									
//	        < 4a0AsOKsxd7nZnZJLuy76jCAUdG5j2v10d035mCrsAIB2NGDJiKjj5Tl4HFqzZ0l >									
//	        < 2rqTy8qN5Dpe606pY37u48YM5EGkVsBtAanrzpjBmfe0R5ZYWNFW0PkGa12wKfmv >									
//	        < u =="0.000000000000000001" ; [ 000062297734865.000000000000000000 ; 000062307843376.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017352CCAE173623951 >									
//	    < PI_YU_ROMA ; Line_6277 ; Y9b0C0j882L4vmfdW325Br84s7H017eWJkNZP42eyHo632PK7 ; 20171122 ; subDT >									
//	        < BXJS3erH0yk7OmCr253c7VbNV3H8KP7cS4y5g6Snbi5yk47epM54DT8xQ2Ma7V8P >									
//	        < pS8l8u9R4952G31m9rr2FsFXT00IG79a1Rl46sS5Vq6g4htj06J0Db7fIH5r1y33 >									
//	        < u =="0.000000000000000001" ; [ 000062307843376.000000000000000000 ; 000062317297148.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017362395117370A632 >									
//	    < PI_YU_ROMA ; Line_6278 ; dBNJj7Dj4jPpddiq651hJh7gillQS7ADCK62lZ236qc4308Zo ; 20171122 ; subDT >									
//	        < FV78aM0d9OM6CBxOMX8zqVdnZ7f6yOhH1Mj0HC320DfH1bBA3iORDN3717K95ePD >									
//	        < rmpG0L68RSG6B7Cs6J9M32nJcA6vSPVviH7zVl63byRS2B2B8J5K114nY2pw0Y8W >									
//	        < u =="0.000000000000000001" ; [ 000062317297148.000000000000000000 ; 000062330340024.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017370A632173848D12 >									
//	    < PI_YU_ROMA ; Line_6279 ; rc427Wkf1G29EBJNWp0OHeHLJgKm0q052gW59wsR2QKm4DT8W ; 20171122 ; subDT >									
//	        < JHu186nW5n8li5xw9G9NqE3dc7pGmlBEF34A6D25LGy5zBo66O8dhMnpQ3l4902u >									
//	        < 19gh90CMCMB4nXjb2phX9fo8961VW3B0wx5M409ml02d500I2U1RW7v99A4jyh4H >									
//	        < u =="0.000000000000000001" ; [ 000062330340024.000000000000000000 ; 000062344969728.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000173848D121739ADFCC >									
//	    < PI_YU_ROMA ; Line_6280 ; 7Ulig5067N32b734w6hsFkFg6pC0K85XC8nfxm0p7J7kA7Am8 ; 20171122 ; subDT >									
//	        < f69h0JHw3USD6DZvLzoQSVUx2fCi96ZXtO9Y52ieipN9a258fZMlJ4VbEG0lfb3f >									
//	        < Xa2Nx7hR3c1KCg12uD9tfQmQSB0z268TUBq5t1m8O5F5s35117nNrtJPSueikT5N >									
//	        < u =="0.000000000000000001" ; [ 000062344969728.000000000000000000 ; 000062352799365.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001739ADFCC173A6D240 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6281 à 6290									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6281 ; XKxV32Og229Mu772C2EXR6s6mcF9Pt0VqPcsJxNY6CT4F7ly0 ; 20171122 ; subDT >									
//	        < D8248DBh5bi8C8K5m1WO8ec3rJ4k98avDS084Oe7X9lhz2SxE54Em4XoMIbF77Mv >									
//	        < j403295LWaTq1WSYD0q046r45TmS52ju0urfRPw76tR1xmd0R0Y714duz3x6XW8j >									
//	        < u =="0.000000000000000001" ; [ 000062352799365.000000000000000000 ; 000062359100195.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000173A6D240173B06F83 >									
//	    < PI_YU_ROMA ; Line_6282 ; 6rq9aaSB3tnzo2zMLIjJM8MPUBQS1gVOE6MMe4s6zW8GwIjRs ; 20171122 ; subDT >									
//	        < 1kRn303rkyF7ezXw47SgZ31Vb7C3tQSC9TR9J3lnqLcytyCy7tELB6cezcOU3Fz5 >									
//	        < 9jrL5CDj1azfcwoCxZh9YTSJMpweqh3Tj3l2CIYxZ2sm9qDP4sFNyPh1mEJDR2pS >									
//	        < u =="0.000000000000000001" ; [ 000062359100195.000000000000000000 ; 000062374099635.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000173B06F83173C752AB >									
//	    < PI_YU_ROMA ; Line_6283 ; jc3U0S4HHzd2i206xiO16ntdfz2WA51M3iU4WL1TA6pAYH247 ; 20171122 ; subDT >									
//	        < T8Ye91Ix3VJDPWBjd4b7yhjw458I9m3rKOqqO27vfXkD38l6FMr7O0weXMw3Vfl2 >									
//	        < HaYqgyZ9BM8lKw10Av0D8YdvBRchLc5e9ZtcsqBnkmbGwwYg5MUCNfkU35esAk9o >									
//	        < u =="0.000000000000000001" ; [ 000062374099635.000000000000000000 ; 000062386653465.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000173C752AB173DA7A82 >									
//	    < PI_YU_ROMA ; Line_6284 ; Cdu8xftU6QLTE7oo62aZ7095P03R4liuk28ky7nGmnd1B443i ; 20171122 ; subDT >									
//	        < h2sBLFLWC05B0fKqu62XW9F5493ci0n61wXkI13HVtqDDO4kdNz5E01h1o0DAZ9r >									
//	        < dSDAKCL0geTw1842p5Iz5nA0232ck4rH633r1FC04qVtVu5CQTz6HP1kt144n3nb >									
//	        < u =="0.000000000000000001" ; [ 000062386653465.000000000000000000 ; 000062394718375.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000173DA7A82173E6C8DD >									
//	    < PI_YU_ROMA ; Line_6285 ; 7NVyjmWCwJB1il1lZj8yk71rNVu469xl0N64s14xNyG64Wdod ; 20171122 ; subDT >									
//	        < E97i09fW3L3uR2JZEogQg7V9MJsaLm32XpIb0fOw4C9DF3oOwf9Gsex4IU7amkxN >									
//	        < e0GaLg6PS0vZl7fNq0Hsu96I3G78cm76Gi38e25JQ1qj3eZ7gQGF6DU20l6AeNER >									
//	        < u =="0.000000000000000001" ; [ 000062394718375.000000000000000000 ; 000062406019764.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000173E6C8DD173F80778 >									
//	    < PI_YU_ROMA ; Line_6286 ; k7I0dHcVAAr3I1rg643CXD4f8LiJB36L17jF7o9J2U8f0pYkn ; 20171122 ; subDT >									
//	        < SWToog4QYJ0Kgr8b4M2ptMd2K4IjcVyOX8486By7eKKA7Noj3jhMDah6Z696sTiH >									
//	        < 9V5rnqgA3BO37snt6qQctyb6prZUjZ2oXtxMpdLQtodsZuKy0kwc41DU15YrH3SM >									
//	        < u =="0.000000000000000001" ; [ 000062406019764.000000000000000000 ; 000062417676738.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000173F8077817409D0F9 >									
//	    < PI_YU_ROMA ; Line_6287 ; 4392AdFNJ5dJIVu33vVl04SRHKb9y4NKGUPj0LC5v4E60O1rn ; 20171122 ; subDT >									
//	        < 9N7902BHY3F264HZN86X3K6u9LdVD3OH5AmIaV7E8QrSFh6Wb4Swk8cw323351WZ >									
//	        < 5n310MP1C2EBh0XU6Q54j8210nhTWhI5sd9EHlmHS38Zm5LBwp35RBS9vyGD25mO >									
//	        < u =="0.000000000000000001" ; [ 000062417676738.000000000000000000 ; 000062429206400.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017409D0F91741B68C0 >									
//	    < PI_YU_ROMA ; Line_6288 ; 6DjhYwPQwa5909QCVFWnN4Qux8ka26r6Bo3f362nPdKgoFbSn ; 20171122 ; subDT >									
//	        < kIoH1WOphNYlaR3oHHMxySY572bD21I49bX3VNMg7EHl8s70jEFpBBt1VLFYOTBi >									
//	        < u0KE3X6I8rrFojTEQAPU9Y12e4ZYEDe3Wn4D94m7ua1U05c95Z1yateNWZmvI4nx >									
//	        < u =="0.000000000000000001" ; [ 000062429206400.000000000000000000 ; 000062441843577.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001741B68C01742EB125 >									
//	    < PI_YU_ROMA ; Line_6289 ; Ep8EjF47q0aC635YVCs2sa7s62YzG38ihL2j70sSlb5FXtbnj ; 20171122 ; subDT >									
//	        < ZCMhg071WF8GBUxc3GnbGXl84ZKLA6zEA5Nl4D4Yi210s9Eh62ONID5nZV5eNPkD >									
//	        < 2C61B8gy35V8iwCjhqh6h7H3vMDWLccx0rYYqcgJ252O4vt6D9dM5UKXraz5Mo69 >									
//	        < u =="0.000000000000000001" ; [ 000062441843577.000000000000000000 ; 000062456031699.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001742EB125174445761 >									
//	    < PI_YU_ROMA ; Line_6290 ; ihQzsd8Ae7h5W5b11q3eYq8924a0989KBD9qr2lFx05431SYu ; 20171122 ; subDT >									
//	        < 30Q4MQxkaQ5ThW3KQul6mcsUGu659f8ytEJanECbM03aFWE8Otut50BcrPHuaBwl >									
//	        < L6VSH6M5ug4o8Y1Y0l3Odk212oixP5Si92HR8GELH3D526DQD0Q9DpVO54HmO7aG >									
//	        < u =="0.000000000000000001" ; [ 000062456031699.000000000000000000 ; 000062466067354.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017444576117453A78F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6291 à 6300									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6291 ; PzUKsouFZfD3N4o3wZ5T5JWsaDrnL3f54djMERdgPYzj2Om3u ; 20171122 ; subDT >									
//	        < JN6el9c61nnQMhw2AyRDi7IxhbTKBx3424Tr2Pugc2tyh2XrK7J3pAEfMSO4dxDB >									
//	        < 30IDD4dnD96ar8JIi76oM5W0gz62f0a6sR0iOA77UpsiUD6c6uJ93vF8PDvz05m6 >									
//	        < u =="0.000000000000000001" ; [ 000062466067354.000000000000000000 ; 000062471068995.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017453A78F1745B4953 >									
//	    < PI_YU_ROMA ; Line_6292 ; i5A54601iJa70GU4241ti7Ib2M4CNQeVyEuH4QQWC89C8VL1i ; 20171122 ; subDT >									
//	        < 76NsL19fj7AFF2N41F3An0mBl4lzvyYIz8ryj7ts7eA3Wiqt7OF5Uf2gdmH9elY6 >									
//	        < Q5eWv2z0hnE4C8GREl85MjkwzYz03u79M9j14pvDXhUZ2kId58yx3p1p8Az76OW7 >									
//	        < u =="0.000000000000000001" ; [ 000062471068995.000000000000000000 ; 000062481705314.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001745B49531746B8423 >									
//	    < PI_YU_ROMA ; Line_6293 ; XXSlR9HaxAxM5E3RQ6u6IcpCtFcqSAh6imlZGuHa9C0IpKj01 ; 20171122 ; subDT >									
//	        < H9wGqE1f20q93bwckbtIfI728ul4yd26o6g884dCzrFR2wT1lr03yIB5X3gmS46D >									
//	        < YAkRW11AmEn6ao7tlBltR3AD857cPOt8xR7A3NUB36W8jafCtQ9QWePlzCZ89JXS >									
//	        < u =="0.000000000000000001" ; [ 000062481705314.000000000000000000 ; 000062490078040.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001746B8423174784ABC >									
//	    < PI_YU_ROMA ; Line_6294 ; WQ3F2pitv2PF1Dk1iCnQvLsd5x77g6b1Mu9Frg9bi7i6R5B71 ; 20171122 ; subDT >									
//	        < I6yIJ67f2lQ2L4qZMS85o82hTaDB892n2e54ATam60gsI7kDPoRPC0utw8y9m39n >									
//	        < 3Fpyiw6zFNp2bGOICz3rf436RA47bpCpKl9LpJ55rPnB0o7c57440gcf3174V7RM >									
//	        < u =="0.000000000000000001" ; [ 000062490078040.000000000000000000 ; 000062495553140.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000174784ABC17480A572 >									
//	    < PI_YU_ROMA ; Line_6295 ; 0m0q7L4Em5KysW8U5148M0hr6Qa1OK4SZG3yK902Y73X01U0g ; 20171122 ; subDT >									
//	        < p6v16PMHyW22k21KE0OkC0J15NBqqcp2g3igh5XNH93Sy83CWiLVhUOFHT6Z6tes >									
//	        < UfmZC2u3R2mNQyP1Uvd49N1LLdI28kC4j7GFZKCUqL51fidv5F30i2bwVr058yYv >									
//	        < u =="0.000000000000000001" ; [ 000062495553140.000000000000000000 ; 000062500823312.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017480A57217488B01B >									
//	    < PI_YU_ROMA ; Line_6296 ; i6F1Mr6MLS4T71VEixo3t2v4gaNR98hW4tf24N0Ppe2q208r2 ; 20171122 ; subDT >									
//	        < zcQYxvz8l93Q8715bf0o9mNekvyn1d15rd9qXYw5qzGnEDP34k7WB81MElCE0PQ2 >									
//	        < 4Wv9d276MiC4TAL24Q7HUpu7Pd7QtY918BDbysGh82OQb8bwV7h7870KW6dJ3D8G >									
//	        < u =="0.000000000000000001" ; [ 000062500823312.000000000000000000 ; 000062505916290.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017488B01B17490758D >									
//	    < PI_YU_ROMA ; Line_6297 ; IX3aDd94S54096F71ptW0II91ZA4U78kaSbaPJSK5m8lS51y7 ; 20171122 ; subDT >									
//	        < yl0qo34U5f34PC24938iBxfE1HazFO0i0k0b0SCExmfd22CHUx1yBx2Yh39Uy564 >									
//	        < f5yy4czVvp780w0Yo3u98AdglhDQB8zNz4TzA4WyGP0ttkRc2s9nAZ5GeT43cois >									
//	        < u =="0.000000000000000001" ; [ 000062505916290.000000000000000000 ; 000062517491872.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017490758D174A21F43 >									
//	    < PI_YU_ROMA ; Line_6298 ; snjA4I742j0TD4bwy7JbNtEutN1FbqTPWoQFiSJ525Tur0vrr ; 20171122 ; subDT >									
//	        < VWsFNOiIvJ87w175B4nx31pdl3YKJdE0j7EkJw3QTK9k6660ggFZioKmR4zR0dR3 >									
//	        < nX3remD9IrpcLJ98PxtWfBoI55ib7Nt6q41l8A1Nu2Si57pVJxz0PDCl5aIlNkR9 >									
//	        < u =="0.000000000000000001" ; [ 000062517491872.000000000000000000 ; 000062529937506.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000174A21F43174B51CD6 >									
//	    < PI_YU_ROMA ; Line_6299 ; o8Qd44onlF4aidh93B02nZvj23quoXIjyy2R1p6t4f8s1WBp2 ; 20171122 ; subDT >									
//	        < oXK1Nh0HfzAaQSspzSS6x1IoFiVv1nyn2tAEKVix3Q7d1HitSBAiq2DkJ67e1baD >									
//	        < PMZwc9HFZbc5i59a61wJHsyA6wPN760954yxp4QGtDkVku9PvcTi8MER96Av6Yec >									
//	        < u =="0.000000000000000001" ; [ 000062529937506.000000000000000000 ; 000062535127741.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000174B51CD6174BD0846 >									
//	    < PI_YU_ROMA ; Line_6300 ; C96aG02o37b5u1uCel33J4qipeN9247bTvY2f9C9rv5ABm1P1 ; 20171122 ; subDT >									
//	        < q9i02IHKAyK75E02oB7qh7366y3MEkUqAjC2sU3GWYkkr54KImOR60y00xNSMU5a >									
//	        < 97vNnvhZjkkTV9ZgMM0hDoEqDX9Mi6444fgr8q638SQoRykwXH9vl344nBL0Qf9s >									
//	        < u =="0.000000000000000001" ; [ 000062535127741.000000000000000000 ; 000062546991939.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000174BD0846174CF22B9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6301 à 6310									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6301 ; sI3HPqJX8m3X089k9m6Og07NcWDRVa747K6VGw2v32W4s0u9V ; 20171122 ; subDT >									
//	        < 1mmRuE18so4fM4dF5492oS7Lw843TrW96Nwwf4s4vb035Vth2usYE05Fe8vYk8Od >									
//	        < 8Xwi2WuK8gN6IPQ4555EB9siJaj4YVVKx76Y82DyzbniAXqbAM1FA03zRr3Ry7F3 >									
//	        < u =="0.000000000000000001" ; [ 000062546991939.000000000000000000 ; 000062552192733.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000174CF22B9174D71249 >									
//	    < PI_YU_ROMA ; Line_6302 ; JZj4oBa7tWNBMHKDby4071vBB350jErLYcvu40wqflfIAI65D ; 20171122 ; subDT >									
//	        < Yto86K42oPmxRlcg50E275Fu5LE5727unSXRn9kl9GRW0Lkh2b351C2j3BmJveF4 >									
//	        < RnuVkh6eg0HshFuzwJe2UwW00e5j2H38nB95l0oDYHtC5JL44c09E4X7jYmm7yLs >									
//	        < u =="0.000000000000000001" ; [ 000062552192733.000000000000000000 ; 000062558356212.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000174D71249174E079E5 >									
//	    < PI_YU_ROMA ; Line_6303 ; 4rRd1z546m9OrSB6jq8kcdEw7Kv6OjCx3bGPOWqTGxZ4t7RJp ; 20171122 ; subDT >									
//	        < bAods00KwPaM0U4ZG8J74UnupGaLXglTpEk0cz950248BIYv7B5tZ5MFZu1W4Ny4 >									
//	        < TTDfj09vaFe4JbU3FOxTv0wmjP70pi4r3TC84zFvV7H9BT3Q47tp5Cs6L1KV9K6F >									
//	        < u =="0.000000000000000001" ; [ 000062558356212.000000000000000000 ; 000062566094788.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000174E079E5174EC48C6 >									
//	    < PI_YU_ROMA ; Line_6304 ; n9q0Mhkbpc3rKxOR36Bv7cdFh8bCoJQnC666l758079L17qEx ; 20171122 ; subDT >									
//	        < gT19a00o6IknqUh4Y8L9p7o9J8ikRl9z38c7Fw09C5L7Y3kzFeS4qKITu734y6Cg >									
//	        < 1gH8TIYtfWJ68wBrHN6MNtnOZEw19yJcdf5BQy7Lq00afFCOG62F8q6HsV7Cioj1 >									
//	        < u =="0.000000000000000001" ; [ 000062566094788.000000000000000000 ; 000062575629103.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000174EC48C6174FAD51E >									
//	    < PI_YU_ROMA ; Line_6305 ; S0Ttwi0wZ4U58hbmQrjtY2zdhN9yozkH18L7QcBYF203d5sxs ; 20171122 ; subDT >									
//	        < 3Lv9nQGx7kyH0y55lMoBXT8h5y8Ev8JL3m1r787DgN6NQDTae6F5AX0S47DK6PAv >									
//	        < 7p25PFjK84Y0O8egcr6lBZX3VzCE84ediIDft5463rvYQwN17BjpEj8u5RTD8tNH >									
//	        < u =="0.000000000000000001" ; [ 000062575629103.000000000000000000 ; 000062581401929.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000174FAD51E17503A420 >									
//	    < PI_YU_ROMA ; Line_6306 ; uV64EvH1by4I2hLmAKjl6ZARN9EHKsRNVqqlt7kH5rh34GG19 ; 20171122 ; subDT >									
//	        < hTm64bP9Z641U6iHztqrYCn7dLE5aoskR9A8hwk4C7gLB92R7QXukm6oE2D1hPbD >									
//	        < 63MBqQznJ7iI17PTMWq54PGP192RkWF0AtC1qooE44uxANqy0jVbJC92Q0C2E913 >									
//	        < u =="0.000000000000000001" ; [ 000062581401929.000000000000000000 ; 000062589112803.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017503A4201750F6830 >									
//	    < PI_YU_ROMA ; Line_6307 ; Ng8qdYhz486kR3d8KV7P0f0I5M5FUk9Nj3ur5s37729v5Yyz0 ; 20171122 ; subDT >									
//	        < skXl6xVkb7eW5Ack4y3u21lpmco2UNQlDa62mo36n6uLsmAcS8EHt19n7642Sf3f >									
//	        < 8WxviN7myb9yMcUX0aC4o2R45hx54bcT247byYCJlHo30oC3lGm73F9xS4sAt6w0 >									
//	        < u =="0.000000000000000001" ; [ 000062589112803.000000000000000000 ; 000062603113183.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001750F683017524C516 >									
//	    < PI_YU_ROMA ; Line_6308 ; v1AU30R3p57qKhtb6RSDU78nu2IAl92L5i6Cb0xZQ2o1keP4g ; 20171122 ; subDT >									
//	        < uKhSGO1dS9h5kw5oU563Xu42N591ZJ7R5tdJo3TpI3VPUBC5zzjfl8aden7Qc3Fr >									
//	        < M3J2HAV5r315YLBpeizY0CCsPbAtRwM2RA3XMsY9Lpfa4WdhZiAxoQx8Hqy4cNUJ >									
//	        < u =="0.000000000000000001" ; [ 000062603113183.000000000000000000 ; 000062616949797.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017524C51617539E203 >									
//	    < PI_YU_ROMA ; Line_6309 ; TJwZ6l40ngZDwmQkMJX17N1Z428MFQHDv7ILwWAbBavAbGe4A ; 20171122 ; subDT >									
//	        < C3b1yizhJ1o5ub0u1NAHm1ZN7UcXPrf2dKXW2kjCDpd3yrrPCNE1XbIW38iQvFlm >									
//	        < Ub3Hp9e0n47hXq211GRU6S5044eY4h87z5W7L9zzxiPAgEXZ97hT5M22H8a0Rnp3 >									
//	        < u =="0.000000000000000001" ; [ 000062616949797.000000000000000000 ; 000062631868959.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017539E20317550A5CF >									
//	    < PI_YU_ROMA ; Line_6310 ; G7H9iflkc94HxW1I3roK06gX71R3Km1R3K8zH1D954ytS0Qx9 ; 20171122 ; subDT >									
//	        < LAA824IKS2YWO87d1JH7u0a8QC8IW45J1p0B5dJni2X12wT4PE9CEzvzuw7n5iOQ >									
//	        < 3VGsWBEldr91740f50Eeg15bT17Dl135x9x3TAo64TPZj6802Vv9k7944X5n03dL >									
//	        < u =="0.000000000000000001" ; [ 000062631868959.000000000000000000 ; 000062645137794.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017550A5CF17564E4F3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6311 à 6320									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6311 ; 238f1jrs21JUZn9G6DOPC6ey9A9tVnzuv3Ac0N0S6x73v9907 ; 20171122 ; subDT >									
//	        < 5mYxsb97TF6WrGG80InEJpN19IkVaRSnb8l731m7djg73f3KF24Jt37PM8Ouw4sV >									
//	        < b9WwyqJqr0ifqs631Y39P6tP59B2mj5tucuKr2ihg1rEQu1pTNWUf68G6EiuK0S5 >									
//	        < u =="0.000000000000000001" ; [ 000062645137794.000000000000000000 ; 000062653911619.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017564E4F3175724839 >									
//	    < PI_YU_ROMA ; Line_6312 ; a4cAlYDZ1RUDo3DBowkHKuim9CHTp3i1rm0Gdb08GcckoaeWB ; 20171122 ; subDT >									
//	        < Ouue0H9DPT07HdJU49YP2BO5FxB9GDlgOYBKg0Oo4U0c11x07qyJXLjH7q9qRbQD >									
//	        < OZ76KK67RB3W1hr09u56JFeyl0R0A9SQd15u6e6Ncc1mmcZQO762Jw2vrK136R01 >									
//	        < u =="0.000000000000000001" ; [ 000062653911619.000000000000000000 ; 000062659819553.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001757248391757B4C03 >									
//	    < PI_YU_ROMA ; Line_6313 ; 2hWVgvUswcV0wnaQ3mMiITQ7il2v52579Rl97Xticwrnv5GP2 ; 20171122 ; subDT >									
//	        < pP5iy9xC8FvIqj3AxnF69NTPNQaVDr2lu03X311mTcyuWVOKfDk0BE6xEOQE4Qgr >									
//	        < cSR3e0C9Xgb9t7p0avV0jmTo4lFGS912YfFFo65H6gWTuqRUaUCy1fpHg0AhsR3T >									
//	        < u =="0.000000000000000001" ; [ 000062659819553.000000000000000000 ; 000062672304998.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001757B4C031758E5923 >									
//	    < PI_YU_ROMA ; Line_6314 ; 6rhF9TGOL5Y3sjbCFbCzU8uJo4hl6RG2o2TURBz4227Wx6K4L ; 20171122 ; subDT >									
//	        < d4Ie1G747z31kGwR9DnSrfO6XCwKQ90b2R3piGu6MSXnLchUk21ymCO5tZZO2q7W >									
//	        < d585a35aJ1z2fruJ5D502d7q43B911hS287pgsVq4qkg89aOb7fdGeZO2p01898l >									
//	        < u =="0.000000000000000001" ; [ 000062672304998.000000000000000000 ; 000062684742755.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001758E5923175A153A3 >									
//	    < PI_YU_ROMA ; Line_6315 ; WpgtU6DB93Rx35a84sXiZiI0A65g7d6EPB8oVEj22eeI2e63B ; 20171122 ; subDT >									
//	        < V120rMnIc8dzTF7X7K26J0rpkS4xnPSTNLDo2qJ0kR8J4Gw5ED4B0y3n8j1eDw8k >									
//	        < guy7a328QPR32N9oKiToxC20qqmsBC8s37NyuMVx28O6zx19zd3IrAb3W3ts02Ht >									
//	        < u =="0.000000000000000001" ; [ 000062684742755.000000000000000000 ; 000062691213515.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000175A153A3175AB3347 >									
//	    < PI_YU_ROMA ; Line_6316 ; C8148NXS5LEYLj5v97Bq8p3OZEY9ySYHHn0FpJO21eX1P5a0P ; 20171122 ; subDT >									
//	        < SNQf44NmSe9nna3sr8ep3SCCZrUWXq66u54MG2576Bb6HqxK13p95wRG84N9bUdH >									
//	        < i17TMsSsySD2Y7q5VCbmTEz6MCAmmOq6LEx3gR444825bn26NjR9Vv2tWBwztKQo >									
//	        < u =="0.000000000000000001" ; [ 000062691213515.000000000000000000 ; 000062700788622.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000175AB3347175B9CF8E >									
//	    < PI_YU_ROMA ; Line_6317 ; d3j3W181bPx63QZjR9YcSHpli0mxjXu948vL836Y975YE7lBr ; 20171122 ; subDT >									
//	        < CaT94Uc88Ko7e3I7fZWH1YpvvkF7gvyWRD9eVBRHZAdhGhz49383qK9p3j2pYz16 >									
//	        < ZRGIMuei95q1j4L1gTE3pczLt6B9b4lcw793H7DmVxTVK3v363m4sOrVRUzNiGv9 >									
//	        < u =="0.000000000000000001" ; [ 000062700788622.000000000000000000 ; 000062711333239.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000175B9CF8E175C9E68B >									
//	    < PI_YU_ROMA ; Line_6318 ; Cjdhyu2jY0g0iH1TLB0fM3N3LLmGt5ZNvjn07hAc3l3pVVcwO ; 20171122 ; subDT >									
//	        < 67W2uhzAoo4z5YKjdPtNn8f8HnLrJ7RAfR24e7M4fpDy839t7CZt4mh9Js2a2oO5 >									
//	        < 6M7Q1ru67oL8iTw984Y4u8te5I7mr77L60Nd4e6U5x7Hawa0EIrm8P89s2lQZVmJ >									
//	        < u =="0.000000000000000001" ; [ 000062711333239.000000000000000000 ; 000062726268225.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000175C9E68B175E0B086 >									
//	    < PI_YU_ROMA ; Line_6319 ; LB260wM9Q2Bnuozf1cZp4cfD5cr5O126IWpKha7CNVr086Z59 ; 20171122 ; subDT >									
//	        < Ptl6O8kEv2O11022I676q05WTy6H48BL19515VSqkDJ6x8z4dCl9t8Y5yYR31Dv9 >									
//	        < HL6xF0Z2oTK0Q6hLdLIqP1T4kmHQpv8bK646a05dAH8uKfiDk15o2i6E47NSGvJU >									
//	        < u =="0.000000000000000001" ; [ 000062726268225.000000000000000000 ; 000062737861030.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000175E0B086175F260F7 >									
//	    < PI_YU_ROMA ; Line_6320 ; CYzqk0C6OFoA9k7NfWN6xmxalU3VM4zQ56TdJ7diaUn4oxC6u ; 20171122 ; subDT >									
//	        < N8lmyElDC75DIIVnw55i1uu239HH9MrN2wW3s8D06RPbPetDn44I73kS8FHy1d3X >									
//	        < sE9x3BjDPAa6Sg6J32aZvb4vi5bJ70I0k7MVyUEF329IvEO277Z48OwLdEY7R713 >									
//	        < u =="0.000000000000000001" ; [ 000062737861030.000000000000000000 ; 000062748040809.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000175F260F717601E970 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6321 à 6330									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6321 ; b8c4L1kB34EEfy9694gw1Cn00njj089alL4JlUt2TFr637up4 ; 20171122 ; subDT >									
//	        < k0Np72ihWA379cMGsD9MP1kkSgCx1OChccw6wIZQyV67O0R9C87rYO329cCT8EFm >									
//	        < SkDP0w4l0u749PQC818MHL66e2a5UaAd1ai19RC7v0snAA8ulGag0rrMHYSN2g52 >									
//	        < u =="0.000000000000000001" ; [ 000062748040809.000000000000000000 ; 000062753380414.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017601E9701760A0F39 >									
//	    < PI_YU_ROMA ; Line_6322 ; 5gkH56UTl957N2R2G8tr7uI9n97Z097YgWFgmM7i3T3hd21DJ ; 20171122 ; subDT >									
//	        < oWJ7I4I4fPw1n81Peg98Igu6I8qk8fpQbg2S8SiK800FwO25wCkLvCl28gMNk2LF >									
//	        < BuJXHchxKbar4OSvPTvLu4iwF5K04w2Df8NQ76huv83cwps13DfliJDm8E14I2BS >									
//	        < u =="0.000000000000000001" ; [ 000062753380414.000000000000000000 ; 000062764588845.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001760A0F391761B2984 >									
//	    < PI_YU_ROMA ; Line_6323 ; w0kOmj6JYtcKkUNsjwH8UVH5sO32uN9Wmt69lEbjuD68iaxSL ; 20171122 ; subDT >									
//	        < yL7104QIyfbZ6cb10Fz8OoDLi8Ec3fK4vr9jJ5Lc0aRmj5tfLht5eVQGpK440yR3 >									
//	        < 92X938x0bxU8qW29OqTps96ZlBh4UWvMP33JNY649d3IZRWvz1I710E9Uo5294cY >									
//	        < u =="0.000000000000000001" ; [ 000062764588845.000000000000000000 ; 000062775158501.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001761B29841762B4A4A >									
//	    < PI_YU_ROMA ; Line_6324 ; xVso90P45xNHy4wsD2WXxS4gC8R8e3Jn6T75gR7P3qKBjCc5T ; 20171122 ; subDT >									
//	        < R0311Hw4i3iewiqq5Hew7nlXqg7xwK5P0M8ag9eVN7fxmJ16GG0ZZ0N3yUggAk49 >									
//	        < 9Ts0GY049u90hIHTh4I3950Mf40FG0J2odXJm51CocYJ1l5pmaZH1eH8Pix1e791 >									
//	        < u =="0.000000000000000001" ; [ 000062775158501.000000000000000000 ; 000062781597340.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001762B4A4A176351D76 >									
//	    < PI_YU_ROMA ; Line_6325 ; zNJiCq79PjsEFcZ6I09615WDu6aXy69tBWs8CJe111m5KK01e ; 20171122 ; subDT >									
//	        < GdpM2H5J811285h1ZrDS50QHU6486M32Ue22AS71Z4nCQRe27kiAEda1kVyDvEt4 >									
//	        < iPle86y5N0C5jBh56758vu204cWRzZOIemk6f7m7PqwfpBmJ3wHZ9M67M65La77i >									
//	        < u =="0.000000000000000001" ; [ 000062781597340.000000000000000000 ; 000062790129893.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000176351D7617642227D >									
//	    < PI_YU_ROMA ; Line_6326 ; yTjSxOtd41IsBG6B7LWCgX7919wGXaOwWZ6SMZ9xWF9boSehe ; 20171122 ; subDT >									
//	        < S897s9dbdKwVkCcn9h7ltEI52jH7sIYtnj68tHxyAVM32T5ME655U0d5LEMH3e3S >									
//	        < z9e97wEiE57gNJ6b6THxZhwOQG4CDSVG841vy1KIWKqhG5e537oGSqIrE72tQtwT >									
//	        < u =="0.000000000000000001" ; [ 000062790129893.000000000000000000 ; 000062795659866.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017642227D1764A92A2 >									
//	    < PI_YU_ROMA ; Line_6327 ; 1ZXxXzkl4gXSj6Z0y527mH71jwm6wfIY3JTmjYR0X7r6dqxPj ; 20171122 ; subDT >									
//	        < hr5VpB40Nb54p6K6cM4syzjjbG6Gj90whNRiK4D5s48k9cX8CYGxkmx4a045AZWX >									
//	        < Tu33EaB81P74J5C9r60Z5xf82Ux9U0IjuCCJ1s0bS5rB0Fbl2h1v7v82L4Qa8KS3 >									
//	        < u =="0.000000000000000001" ; [ 000062795659866.000000000000000000 ; 000062806347247.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001764A92A21765AE164 >									
//	    < PI_YU_ROMA ; Line_6328 ; MNF45Ue8e706VvDZ1yXVZeJ9ko6uz9Wb0703ygeVGtV733020 ; 20171122 ; subDT >									
//	        < pu107iW17nP6Hg8aiKLaKIz2651MRtR0H7Z07F704JwdAy9OOLfLV3DnGv99C3Fv >									
//	        < oyUK4RS749nT79g5FpyeuZ82O3C3W98i6m56Vj92v8zVc9nHo0dDQI23DeV9CSWz >									
//	        < u =="0.000000000000000001" ; [ 000062806347247.000000000000000000 ; 000062819781625.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001765AE1641766F6132 >									
//	    < PI_YU_ROMA ; Line_6329 ; 2cT25n4f8h3MgjaRJ1SEiH7K7rzs4ymP25Pnf04Jq4HHB7O0E ; 20171122 ; subDT >									
//	        < 65307c0U8RQ396NQPy84Cv6n5Vt4fT9yY1P442j8y843Bm6gvfxrVQ2iq7fL6J66 >									
//	        < 3k2I73TMjT0qN7H9P3z30p9Ff9UDatvogJtYeJzI1l81Sk7q1K7m6h6pTR6Y849Q >									
//	        < u =="0.000000000000000001" ; [ 000062819781625.000000000000000000 ; 000062830752645.000000000000000000 [ >									
//	        < 88_32 0x00000000000000000000000000000000000000000000001766F6132176801EC0 >									
//	    < PI_YU_ROMA ; Line_6330 ; 8FeL6e33aH29Y6Mh9p7FN9m49b1871HVG6Wa4EV6na1ap6371 ; 20171122 ; subDT >									
//	        < Pb39X65zpKACtx5QPCeH9EzCitKzPvmpX0638AyF9T2v3RYqusz8DDEq0UIVx66k >									
//	        < S6kZE1ddImW1Pa0313Nhksn7AuodrF772Xj23zN18up9HDr6d5jFths6I097mJ84 >									
//	        < u =="0.000000000000000001" ; [ 000062830752645.000000000000000000 ; 000062842734191.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000176801EC017692670B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 6331 à 6340									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_6331 ; Aokk8G7s1g7v3N0l8M63au29rJrRZe2OP5qcjoVRG3415N07o ; 20171122 ; subDT >									
//	        < QvtP7JMtmre6HbHduZ4a83Cqf65R9EdG0cL5PO0l2R852G07MK3xRe2W7YN1kADS >									
//	        < 52UGy35y3R6P4Op3z56dB9Fo7thoT0VAbnbCy2Ls7MLmsIH7gF197x4xupV1T66t >									
//	        < u =="0.000000000000000001" ; [ 000062842734191.000000000000000000 ; 000062851878523.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000017692670B176A05B0C >									
//	    < PI_YU_ROMA ; Line_6332 ; ISZNIBlH28nfme2zJ1pkJHSuTp5Y62AG7SMYhLsT87w24918J ; 20171122 ; subDT >									
//	        < IX00352R03gUFb1lF1TX7tqMuq59R8jBZDr77SiigBJS6dET2iBL88Hm034pw656 >									
//	        < AC1YC15ToZL53r37X5251fqm54u4kQ36ghp32wL9ZNl6m6Me5D1iMOdc4hjgXsL7 >									
//	        < u =="0.000000000000000001" ; [ 000062851878523.000000000000000000 ; 000062858200430.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000176A05B0C176AA008B >									
//	    < PI_YU_ROMA ; Line_6333 ; A3833hrk8ljVY4AXAl055G219di8D18CS5xVh3s8vNgQd8kBZ ; 20171122 ; subDT >									
//	        < 07VxhPQ99VVnNpq3IozDdJR5QtM7lTVg26kY5SrS2319uL47VX65bIzYh8g3C9UR >									
//	        < v0gv87cr38kIcb53po0tou94j9NwCK99a44A1b7Hj9W80Hb80e7XQMt15NyiM0Ya >									
//	        < u =="0.000000000000000001" ; [ 000062858200430.000000000000000000 ; 000062866176353.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000176AA008B176B62C23 >									
//	    < PI_YU_ROMA ; Line_6334 ; Qf639v9OX53BG6by2jz4I0KQzaMzDrN9Jq2dbSp91yaE11hJ8 ; 20171122 ; subDT >									
//	        < VR3Zq87cEDPMtXYTA5WFg9oLqjd4O97rQ5YZ69bHx4S090sfYFVhP77244M3oWB1 >									
//	        < Xf4WL681Bs3UFj297qL93R1Q4njkH7Pm67sE0Rp6y9Wgmb295Tb3GrHmV1SV1zQk >									
//	        < u =="0.000000000000000001" ; [ 000062866176353.000000000000000000 ; 000062875347179.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000176B62C23176C42A7D >									
//	    < PI_YU_ROMA ; Line_6335 ; XEKGVY5WKgP99H7fFM3ZR5QY7NuBVib1ajeI554kCH64FQ1p0 ; 20171122 ; subDT >									
//	        < LAT9CQu67gZ4NRCGPgAh12Q1YHJD00ME8k6HMw3J4dw3J2pJp4tw7a0F2J0Xy5I0 >									
//	        < PV53DpvGk1qw2pUw7y76K9W7g3Pj242w40Rpk90551fZHg6dHi12zD2XcZF4HC7E >									
//	        < u =="0.000000000000000001" ; [ 000062875347179.000000000000000000 ; 000062886334335.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000176C42A7D176D4EE59 >									
//	    < PI_YU_ROMA ; Line_6336 ; 12o30Eg5aAa0hPFQLM68h1hGgcmoRs5Ggv45xKGWHcK3Tm5I0 ; 20171122 ; subDT >									
//	        < 8VCFG7IF87grv8do5O6yFoTPZN9M19gXDxn8A2XlSf7NdscU81K59Z77iMOCw50p >									
//	        < vco7n3eRI4UrWu7A7GzHm8F0h4E8P8443tp3tUV79iks4x1652r4p3Oe2EuUM709 >									
//	        < u =="0.000000000000000001" ; [ 000062886334335.000000000000000000 ; 000062891364407.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000176D4EE59176DC9B38 >									
//	    < PI_YU_ROMA ; Line_6337 ; 6WJiP59q7F7878zosawmbu8UDEmkyJn7f3iNhsSyMxBpkRyew ; 20171122 ; subDT >									
//	        < gRxyBWegb9C0uN6djJv44o0Gk18JoNYQ5dUjy3FS5T6VJAqQ0B57yZX2UqfIO8Xo >									
//	        < T5N4043q6sF4DpLMog07G2acFO3OBf44D8414SjJf5wIND03LhCN92cl3f4hyttw >									
//	        < u =="0.000000000000000001" ; [ 000062891364407.000000000000000000 ; 000062896626146.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000176DC9B38176E4A296 >									
//	    < PI_YU_ROMA ; Line_6338 ; KqNFtA26CYwIiL8K8xC0n11d8ZKrbY5b2E9dO4n35dFEwPS8r ; 20171122 ; subDT >									
//	        < B8OI5818ayQgGqr4y9Pv4d009mqArX8ErsixzC7xoATiwBRYoJ5o3ee0hBVf03e5 >									
//	        < Ajb61G71L042m600W0K9gDFV4Hi0x9e74I5bHY86C5t97c6u7bC9H6BzG680mYVH >									
//	        < u =="0.000000000000000001" ; [ 000062896626146.000000000000000000 ; 000062911252162.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000176E4A296176FAF3E0 >									
//	    < PI_YU_ROMA ; Line_6339 ; t8dGey0g4J6ZO0BH7t2uEGMbi6yW3miRb1ne2y71H7Jj3Kl2O ; 20171122 ; subDT >									
//	        < Ezf6aR8Wh464U1nZ2MPBA922bu6a9JF1663Zf1q6et7iqY076Ko2Vk06345uhm2c >									
//	        < UHg9jWs0htM06ns701V7sLOP61bp4O2ZaDOrUzIzxTPbV2Ez056m2ZQ1kZi9lhkG >									
//	        < u =="0.000000000000000001" ; [ 000062911252162.000000000000000000 ; 000062917863817.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000176FAF3E0177050A8D >									
//	    < PI_YU_ROMA ; Line_6340 ; puYFW02QvHp1d4V05r81m7h0z0dv9ZM2OJhNe5A0T011mxRkn ; 20171122 ; subDT >									
//	        < 43kG5e45w0gbu12Jobn45m8NBDNYBPt18mjKXRRkrstJRB7tl3qw1OtBi4IDBz9q >									
//	        < N6jL0p1XCC25g72dtUHF06E6hNPh4y1cNAO4X06PNMA10fl1Sk4Bs0jAL9z68Nt7 >									
//	        < u =="0.000000000000000001" ; [ 000062917863817.000000000000000000 ; 000062929023323.000000000000000000 [ >									
//	        < 88_32 0x0000000000000000000000000000000000000000000000177050A8D1771611BC >									
}