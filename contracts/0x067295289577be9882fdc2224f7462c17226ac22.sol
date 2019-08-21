pragma solidity 		^0.4.25	;						
										
	contract	PI_YU_ROMA_20171122				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	PI_YU_ROMA_20171122_II		"	;
		string	public		symbol =	"	PI_YU_ROMA_20171122_subDTII		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		27440338941000000000000000000					;	
										
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
										
										
										
										
//	    < PI_YU_ROMA ; Line_2771 ; xETmmrh18e4RDjm46Ul1bQVxBqPY60geaYMq7ZAtXq8r0fVqe ; 20171122 ; subDT >									
//	        < EJCG3b1dGjS5tBT7tuJmf8cFb01bAZb8Vp0uF3C490383E86SNwiBAQPaYFYv7oQ >									
//	        < q2K8mBT52F1j3eoXtBC61j2hddW2z1EtOyuxRDZapMcL4w8DL9O8608N1t78Br2s >									
//	        < u =="0.000000000000000001" ; [ 000027452088017.000000000000000000 ; 000027459740976.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A3A08FE1A3AC3D51 >									
//	    < PI_YU_ROMA ; Line_2772 ; Q58L76D25bv9BIF8g1gi3Gj6hgmKjIuaP2dIT4ZcXb13b9V5j ; 20171122 ; subDT >									
//	        < B7H4Yx8UDW5P4jjzObfKt4tUXkq6p6paapk3p8qu7S8KYF6J3674gD560Y87Kb8C >									
//	        < Ud7YIMzr2voXi44fbiGLS98F6389j96c77g13034i3tJZy8E2atOUDzhFSV0z0fz >									
//	        < u =="0.000000000000000001" ; [ 000027459740976.000000000000000000 ; 000027472495334.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A3AC3D51A3BFB37D >									
//	    < PI_YU_ROMA ; Line_2773 ; n4DNh3eEv47VZz1fvA3OY8yqB9ZrWN7kOZ8yNy4BJERJ21t0d ; 20171122 ; subDT >									
//	        < q1hXyf8sk70x0dTAI06m7Leakz3DsmF1KCwQSuDU184H8Jwaqi3io2wz4qo6T7IJ >									
//	        < Q2zWvEfvIS9g47tKZdGA9iwC1gYzKS4jouHYtAEGA4MMo08a8exudA4b87989Ygy >									
//	        < u =="0.000000000000000001" ; [ 000027472495334.000000000000000000 ; 000027478583460.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A3BFB37DA3C8FDAA >									
//	    < PI_YU_ROMA ; Line_2774 ; B8R1K8YQ2Z606oXdtEz313VWbAP9KShgW41SBp1K15533fv46 ; 20171122 ; subDT >									
//	        < 00TrH9M87CVja8q3szJrm9XZ0Hdh3Zf6Y6y3SYfB239084Bk42f9oo01Kd17S178 >									
//	        < qCgLhPYOC1NGH8o82jmJWTBWf6622QYq05Z4BGIZAg0CjFp24F9EbQ7f7E9FlV0s >									
//	        < u =="0.000000000000000001" ; [ 000027478583460.000000000000000000 ; 000027487376740.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A3C8FDAAA3D6688A >									
//	    < PI_YU_ROMA ; Line_2775 ; 6Kcg901V6n4u5z2W2CH6vKe9iE4B7qMdE8c4l9O55sV30X8MW ; 20171122 ; subDT >									
//	        < BwHRh3v83086r2rxM53mW1jzs0jg10S6SS2y48JHX0ISYaK5VP2drdqdzjLF62FZ >									
//	        < Vja7QeRv7707rTP39Vw6Y01gDa2SF00oFAbRmi3Z5cxfZ4P0Uu6s0e2Uj4leWPyX >									
//	        < u =="0.000000000000000001" ; [ 000027487376740.000000000000000000 ; 000027500327844.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A3D6688AA3EA2B90 >									
//	    < PI_YU_ROMA ; Line_2776 ; 8eZhtN8O079Q10R60OkIue89d5kYdv58Cy19P4JGFEzb7NXEn ; 20171122 ; subDT >									
//	        < 3LQ23bLMcZoPu72dX1y3iM83jlJHfeWtpQmSOHm86kI3pC9Sv7qP8ygA7yt20TyK >									
//	        < YpPJ7s79vmeRloq5cDC2i849151Kd8HPMcageSkcF7YS14Y0sgn5hmW9RN2Gctg4 >									
//	        < u =="0.000000000000000001" ; [ 000027500327844.000000000000000000 ; 000027511905389.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A3EA2B90A3FBD60A >									
//	    < PI_YU_ROMA ; Line_2777 ; 56z3KZiAzOy4Sc7zCDCj16q20ro89xNxNsFStnjMR09wji21B ; 20171122 ; subDT >									
//	        < e25I1sq0Ogb7D27FmzrJz0Ax6dZ49ss7dT00GWyG5Bi5580ZjVTBS5V87PrbSlTg >									
//	        < lAlYtpsn7sh6f1PPz3DuI0Ro7DbO2x1flZ6fKp0Qz9Q9dhPpOnrQ73uQJOBV644b >									
//	        < u =="0.000000000000000001" ; [ 000027511905389.000000000000000000 ; 000027524358734.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A3FBD60AA40ED6A1 >									
//	    < PI_YU_ROMA ; Line_2778 ; zCa9BNzKOD19Bd2Cvz1A9pn8DRvXLX4p2X09735iW8v1wV34h ; 20171122 ; subDT >									
//	        < 7VkN2n2y12Cvkt4fUtR0iM26xT8zJX9fO1Jzu4Cs6cuP3bNFRS3poRm9E672xp2O >									
//	        < eMM2NM47tO9Ruwjy6lo8QU5k60f401kmnXP7G9p4gtoAYgJfhKvd41qQlA55jB27 >									
//	        < u =="0.000000000000000001" ; [ 000027524358734.000000000000000000 ; 000027532297884.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A40ED6A1A41AF3DC >									
//	    < PI_YU_ROMA ; Line_2779 ; XYfBMa5UboELmFNZuls5z619GjT87DH49Yq7699Eb0VEE3AN7 ; 20171122 ; subDT >									
//	        < F53uR8TKB8NeW3OOeFlm66bxj0Gd34nQuuQeaa20Zn03134pVphH6A25gDH4038N >									
//	        < 83OT04s6QmUMI7J8C48dxi2xvJF66y4VG5Vs6dU1kZ6o1bG5TbWd40EGRkTax79f >									
//	        < u =="0.000000000000000001" ; [ 000027532297884.000000000000000000 ; 000027542351448.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A41AF3DCA42A4B08 >									
//	    < PI_YU_ROMA ; Line_2780 ; oyhys9k1XwAN0DYD039Do7j25juBBBke45rthGojYd5YCk64v ; 20171122 ; subDT >									
//	        < 0f03O44VVo6SHwQn5FF2o2vjWhFf5WiXN40bpoAXg0WJi67z3sCE15g9lMDcKih9 >									
//	        < W298UT9gvd21ewB6k7wpFyp7SCZw3551Nha6G9682xCu974r5rCYByr0LcurHI3X >									
//	        < u =="0.000000000000000001" ; [ 000027542351448.000000000000000000 ; 000027547638203.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A42A4B08A4325C2C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2781 à 2790									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2781 ; p9pY2qZF4Cn3243OKOL57WNg8VH6d608D0dgPTDCv33EOeGoa ; 20171122 ; subDT >									
//	        < wooAOkVpv3KNcF4O3j20j0003vBGayJr4C0qxq8t6bG088wd1Wu49Oo2q16EeU5V >									
//	        < DsEw6C8pWOopLrV472EX41p1vS6aXXGqB652855l4x991914Zyk31W31dBH2u05D >									
//	        < u =="0.000000000000000001" ; [ 000027547638203.000000000000000000 ; 000027553614196.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A4325C2CA43B7A8B >									
//	    < PI_YU_ROMA ; Line_2782 ; vSLxmk9kq6L22t0za9Zs4FozLW5GsWvtSLHU6A79eUPs6Za32 ; 20171122 ; subDT >									
//	        < ZP6r759jD97slqv54YCUtvEt6vCwEDN3oT3w75AU516l41B1FVTOtXaGb0xsKWBv >									
//	        < q5G484tf4he5u9vIIKspJreT51XjxO2zg8P3U59PG99e01iR272eLp450yiJpk1l >									
//	        < u =="0.000000000000000001" ; [ 000027553614196.000000000000000000 ; 000027561258763.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A43B7A8BA44724B4 >									
//	    < PI_YU_ROMA ; Line_2783 ; Zp3FzEip15x9LvFv8ZaX7R7BaAl7vnCVanxCLX0DY52LxATWp ; 20171122 ; subDT >									
//	        < 89O2JZX2Vdu9KAhAwluv67QO9kQVMVoxS3YB1QLrq21vXbI53BdTp3Wh5U17971l >									
//	        < Q7JMt1p8Cf612jJK5rc9DuaM30GLg7lR0u9MSM0R6V94Mkf77B4dzlTpbc9Q6UDB >									
//	        < u =="0.000000000000000001" ; [ 000027561258763.000000000000000000 ; 000027567629775.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A44724B4A450DD61 >									
//	    < PI_YU_ROMA ; Line_2784 ; EG8932l1qk3C0zUG5jyj3EL3Em6XezGum5ZdmMEbs9jQ14Ox3 ; 20171122 ; subDT >									
//	        < F0N6vdMPaS46D2s6cYROKJ7pZM1978Z2372Gl38GePIWJZ70y1Z2e3q0OdYOxB66 >									
//	        < 5fi359K4TT22DDbhumZeLDJJMsQFdAlpVhKYX8E3IIhyNhl9V3glP4ZLq7Bvy413 >									
//	        < u =="0.000000000000000001" ; [ 000027567629775.000000000000000000 ; 000027572858272.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A450DD61A458D7C3 >									
//	    < PI_YU_ROMA ; Line_2785 ; aUNEwiu9sq738f8cWOCHvPT72PL49rdHa076H75CHILuahYsU ; 20171122 ; subDT >									
//	        < lJVeCaCje3MFnp37wnDMazBy7m0mC1yz4N192obxXW0VdFiAiNWZB9Z25e1yjK0C >									
//	        < w22dRuOO9P30847CX0iz2iti7Hro96OXOPT6VN1bXq5oxd79783F889C6aUkkRVN >									
//	        < u =="0.000000000000000001" ; [ 000027572858272.000000000000000000 ; 000027586289534.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A458D7C3A46D5659 >									
//	    < PI_YU_ROMA ; Line_2786 ; ml3emjg5yxe442ID51oB1rls3VW0tev5T09ozCfsBT0RNoZI8 ; 20171122 ; subDT >									
//	        < Kqz60KKS8DAv5NqZdT3Wlx37buGxjP4QJ96Esr5JItJx65KZ6N6MsKyLQ0Ber9hA >									
//	        < L4a7H87IHRH6943lt03793g53527w5987cEYw9241h74kPUOpHT9T9ByxXzvSw3a >									
//	        < u =="0.000000000000000001" ; [ 000027586289534.000000000000000000 ; 000027591462393.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A46D5659A4753AFF >									
//	    < PI_YU_ROMA ; Line_2787 ; fdTT9Zi29RgH7j2aigEkY3vlyPjttBE88pK3U1O426aiGlPu8 ; 20171122 ; subDT >									
//	        < 0W6UNlvSj7MJ8q8F9dEj4uPZB2mu581eVY1z6D94msz2BJf4ROP7bwY7rI9E3672 >									
//	        < L3NMpsM47jr04A66iZK1J6suG12yU1x9pO66GPnSh4U0q5gL64500m2PAjf3FbOD >									
//	        < u =="0.000000000000000001" ; [ 000027591462393.000000000000000000 ; 000027604261999.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A4753AFFA488C2D7 >									
//	    < PI_YU_ROMA ; Line_2788 ; z5m36hx4PQU6k4V63pVuDpvKV9T8uk07JaO61Aab3HXUfKUS4 ; 20171122 ; subDT >									
//	        < s2g8rlo21VO5bdf5xiRbP537J27V6io5WcuRUc69vR73XX20v96DC6T4Kjft10C2 >									
//	        < 857U1U510pBpZ6P1VIqICzHjjNY32bmK7O9A6LrL5zFVos9Qc6k9h46H4i3fH3Xi >									
//	        < u =="0.000000000000000001" ; [ 000027604261999.000000000000000000 ; 000027614622114.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A488C2D7A49891C3 >									
//	    < PI_YU_ROMA ; Line_2789 ; 9RM72g0yCMO4rpUNZb70XiJj8wmtWnqJFOZaL4xPKG20F83b1 ; 20171122 ; subDT >									
//	        < fw0z4T9dTG4006Y2yZ8J2RlU4Yq0W1Sd88uN4N964ADxX12677pHSYyy7jm4751b >									
//	        < F5Ah8S9q5taN33wZVTmQu87x8ax6l5OhY4Yeh3gO6RIG416zD41Q5TB8c6Z28XAv >									
//	        < u =="0.000000000000000001" ; [ 000027614622114.000000000000000000 ; 000027625471129.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A49891C3A4A91FA8 >									
//	    < PI_YU_ROMA ; Line_2790 ; 8925hmiNQtJOK954a4kyVw964sXCLSF63vJ38rKK1Y44yU5A5 ; 20171122 ; subDT >									
//	        < aDwHWT78ug27ObEYKmlKV1Z7p572x73781yXGbI64SO51aPOTpQd3ztC8l5GACDB >									
//	        < 4j0B5Wm8720fyrd63jd3Bv40uU6WO5QXTdu79WT4Ee479qcjp19ZmDwo330EA1F8 >									
//	        < u =="0.000000000000000001" ; [ 000027625471129.000000000000000000 ; 000027636389292.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A4A91FA8A4B9C891 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2791 à 2800									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2791 ; r6kn1TgcFfDe5ht6BcIyKzQRiUE22znKkP41hML8Fuw7c97s7 ; 20171122 ; subDT >									
//	        < 9ordV4UpAYwl12yIY88EbW1zFffWMPCo1uSI6OgR88Cw8dMRr1CYN2Y8A23hyV30 >									
//	        < Qya2zCwa2794478lGA67023BaudR1Ho2R7UIeH9Hl2ffG2O0V862RnYL84vy8KYi >									
//	        < u =="0.000000000000000001" ; [ 000027636389292.000000000000000000 ; 000027649285817.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A4B9C891A4CD7645 >									
//	    < PI_YU_ROMA ; Line_2792 ; Zqfvvb396tXF8eRqIIMeL8MhPe4lVbACNOh2fu5KUrbBDV9ch ; 20171122 ; subDT >									
//	        < ahYBNVaQEexIz2csFG3ajm8F63V5ZUKVJ1z80LhPxZ3ri2CRc11gMu82mw9WtQpK >									
//	        < QVotzj536n19nImOIwNY4msD9pjgFDalE77PhpbP2c4063nD4g886XGs38DI4I8N >									
//	        < u =="0.000000000000000001" ; [ 000027649285817.000000000000000000 ; 000027661910031.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A4CD7645A4E0B99B >									
//	    < PI_YU_ROMA ; Line_2793 ; 2R2h0OpSG5B3gWzL6v6wA7PmrILwlt6G3s57C9504sB79q34u ; 20171122 ; subDT >									
//	        < Y9W9v1AsAsO1GL0G69G8a58402drtoxDfY399k9f6p8hP0IxemJxM5WbIBGF4n28 >									
//	        < 3hU1K5e0R7JRQm2t68MOSAd1MDni4JxY2Fe2SYXXvr653qWBDauSMq863pMT54cV >									
//	        < u =="0.000000000000000001" ; [ 000027661910031.000000000000000000 ; 000027668923537.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A4E0B99BA4EB6D41 >									
//	    < PI_YU_ROMA ; Line_2794 ; GkV3fVN8wMHrXdJ7AtEJQ6Ws367h5P0Tc0wc96tVhGY8fJ5S6 ; 20171122 ; subDT >									
//	        < K3XSvD9iR3qjbVP5zg3d05v7wJ1nGzbzN78N8GiO94yopb2fS1INN2DJmLM7f3Hj >									
//	        < YOMkCD6iAAsTn2wREjfUcRJ940Hew4lW3Q467lafZ033aVmp4N895f80Pa8qeg8i >									
//	        < u =="0.000000000000000001" ; [ 000027668923537.000000000000000000 ; 000027680674588.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A4EB6D41A4FD5B82 >									
//	    < PI_YU_ROMA ; Line_2795 ; 3gQ7Xk288VL2MXeP0z2U27r7mRa830q92d632623M8MJG4MyS ; 20171122 ; subDT >									
//	        < TmWA0v76nBE76e4AnJ9ER47S5G5kzV9GDx4gfaN4J0oQSDD498b1cXeTJl5M0M8e >									
//	        < 6S3rgr56I9X0O6h3B2euRtd2PBzrRQ4890XxfQ78Xc3F3MjRA2aIjH9VwEI5nf9u >									
//	        < u =="0.000000000000000001" ; [ 000027680674588.000000000000000000 ; 000027688446324.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A4FD5B82A5093758 >									
//	    < PI_YU_ROMA ; Line_2796 ; 414I2a63tFfehLU5sr325SMj0m02HfYOp6k88n6Cc38zxFdb7 ; 20171122 ; subDT >									
//	        < sp9je2tFnCNc3RMEgLg41y573eRk2vk134rs111vktzs63091o727cq7B00xVA1F >									
//	        < a6u84K4KTT8a6fzxXPoJn80F2cD26R8f8om40TZIvwmLoN05kJ1b445LVw8cbD75 >									
//	        < u =="0.000000000000000001" ; [ 000027688446324.000000000000000000 ; 000027695703594.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A5093758A5144A37 >									
//	    < PI_YU_ROMA ; Line_2797 ; I1uHsD962Bsf01tQ1wL2oZDm8i8sv7d92nIB8LmfIRNar496j ; 20171122 ; subDT >									
//	        < 7eWs1MrDTox9pGLfrQIAEtz77M3AfRqR59Xw176vIXk8u7DoWtF2xi91b6h8Wkcc >									
//	        < UAd651Ic611m6Jv4H2Vi4FOwv4CQjOCf5868xGs1j8jBXYrJ4i99V8XZ5bsPc0K0 >									
//	        < u =="0.000000000000000001" ; [ 000027695703594.000000000000000000 ; 000027709710891.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A5144A37A529A9D1 >									
//	    < PI_YU_ROMA ; Line_2798 ; 5gA6Y0hKjX0iRfVwm45Jt0l7G6478vGU25n5z659LH4Z83AD5 ; 20171122 ; subDT >									
//	        < b8EonifpsavTQ3WS50vTMyl8csYT8i6olBI97JjAY0qOX0gA6m91Y2yoFWgIl6Q2 >									
//	        < L5v0Z2nj1JvD4e8fe2KLfpRDAk10bzZ0GbcO53LK6AMyo4KIF964uLjk8EbBx0b9 >									
//	        < u =="0.000000000000000001" ; [ 000027709710891.000000000000000000 ; 000027723297483.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A529A9D1A53E6514 >									
//	    < PI_YU_ROMA ; Line_2799 ; mNC82na5WHmsbd8l0qh5rY212znkuEAx4jlHn37zzCIvHne45 ; 20171122 ; subDT >									
//	        < c72z8Z5wK2D1vlQ4RBPY1eaVB4Fe15wg4W47haMbgf8mkSu1YRZtFPAj3JGZ9kjM >									
//	        < ELPjdfIeHHoDPaUWhb7MmPbEnlfL3hBxUtPUvXYVcc0qL3WxgB8sNSgRRH2H0odY >									
//	        < u =="0.000000000000000001" ; [ 000027723297483.000000000000000000 ; 000027733264683.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A53E6514A54D9A84 >									
//	    < PI_YU_ROMA ; Line_2800 ; X80UbM4hG5KeHmHmM1V9ON59l3NRDMG2FWr8NlHM6xT8aa0zq ; 20171122 ; subDT >									
//	        < 93w1f97XDT13lyvv1p6fynb7pnVRvYmMPT58VSXm24zX4FY1oJFagmD5uDCh9i3i >									
//	        < w0ip0pK9Jj0p05t1TKL81llWBQzFCEZ9l1EIAOVb1sX97A0rnw09B5ohJr0603OM >									
//	        < u =="0.000000000000000001" ; [ 000027733264683.000000000000000000 ; 000027748142150.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A54D9A84A5644E07 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2801 à 2810									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2801 ; S7oqp2GyDlq116K53odpJ9Cb01etDIi27SwxcS465PImwnc9M ; 20171122 ; subDT >									
//	        < MD2WKl50kM77Xl2U44YWjw9FK2lMT7993IDWMOb23p4sOGX0X5fB58tse4W74kef >									
//	        < wRb96ATcb002hVF4L6l97E91B786dVXMGISB5MSbEXKjcaA32HFFtr66O5EulmCc >									
//	        < u =="0.000000000000000001" ; [ 000027748142150.000000000000000000 ; 000027757558763.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A5644E07A572AC64 >									
//	    < PI_YU_ROMA ; Line_2802 ; JKxe5svx0OtM49IeUXNAo2ttloOKRyUOGdTTLZa819LyXpR5O ; 20171122 ; subDT >									
//	        < w262zw98miktWdsZY7BJckKNbG32ZgkK3DTGM9TUmd92PTkyA58UErx3pj02S1Lz >									
//	        < K92282fN1JnhPVvrsqDo1pne6biron5QYA53dh8K4TFtTYjnTS71Z0lk9Y77C2Bo >									
//	        < u =="0.000000000000000001" ; [ 000027757558763.000000000000000000 ; 000027764720810.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A572AC64A57D9A11 >									
//	    < PI_YU_ROMA ; Line_2803 ; qQeWYKkD84v3usP3KTZF98R98T481uylklO8SSQDlqvB55G54 ; 20171122 ; subDT >									
//	        < yuIKsVig02u9trlu9Z7HDJU90uIZ4odzQ790Av0JWc70huhaaHMo5uVe7Ez9TQ1Y >									
//	        < 7kTx8JDoKP98DtgmG0iF0b5yYoipGCwxhHk5EtGjUSDARWmy07HbMvtord2Y4M85 >									
//	        < u =="0.000000000000000001" ; [ 000027764720810.000000000000000000 ; 000027771182951.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A57D9A11A5877657 >									
//	    < PI_YU_ROMA ; Line_2804 ; EgUVqzUz3vtxW5y62n1M3fDQm2IBWjAPeGBwwLUo1Qg7n80x6 ; 20171122 ; subDT >									
//	        < N67rqFh14AP9NTXhtS34xSDDU1Um5182n33993WrWJiEmJN7mm6cf5K90XwBGvpw >									
//	        < J13F7mQp00Q0Fw3cTFn345GmI0d9LIAS880HkaAKMIwQRD472i3Woy9vydGaFRVo >									
//	        < u =="0.000000000000000001" ; [ 000027771182951.000000000000000000 ; 000027782189596.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A5877657A59841CF >									
//	    < PI_YU_ROMA ; Line_2805 ; lIQCBnqGT7Z25435HLf9GVn0HKYoTCgM19617Re31o0ddVME6 ; 20171122 ; subDT >									
//	        < SGz7CYVbrT9jlulsI5y7OEl7tXScR7tLRpn1wOLSD0P3FBIXazXYEH4v2HQcl55W >									
//	        < fVMYjT0zf8NoSIG5vg7WjSWiq39w0nY5v25hDZWb1Gt3JWPp4ZSCQe19dd2h5jW1 >									
//	        < u =="0.000000000000000001" ; [ 000027782189596.000000000000000000 ; 000027792608127.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A59841CFA5A8278C >									
//	    < PI_YU_ROMA ; Line_2806 ; 47Hb80cH0X2iBJwd1951KCsho0j0l77YS8OpV53NT2KBQs8v5 ; 20171122 ; subDT >									
//	        < V53ORVNe2i8KsfRXgf0d2mVN0bas4T005F0PDfT2302QT76kpiyIO4L7phOL7upq >									
//	        < h7b5w9K54At0DvJz9T3Mo11U1Fm53h9FxM5srz35a8k186WL7JDNyL19KLx5S1E4 >									
//	        < u =="0.000000000000000001" ; [ 000027792608127.000000000000000000 ; 000027805047299.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A5A8278CA5BB2299 >									
//	    < PI_YU_ROMA ; Line_2807 ; ZN9Dfhm7J2F4806sV6yj6064amlCaUF0z7yy9w8hK93SI9RIS ; 20171122 ; subDT >									
//	        < JVJNk3s77FMqD2TeGLKCTz2qx1lB9mA1cTqnQQU0jp8UupaN6OV3IN80Wf4z4p9x >									
//	        < 9L48z1g9K1IWLOYCt82174LQG971W5IJ05XCt7YCOzhSE50l4loxhgkhxc00f8FM >									
//	        < u =="0.000000000000000001" ; [ 000027805047299.000000000000000000 ; 000027813954280.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A5BB2299A5C8B9E4 >									
//	    < PI_YU_ROMA ; Line_2808 ; UE6e9J8H3W3284fhz0baendG8rp41QDml662E1wquZVULWg04 ; 20171122 ; subDT >									
//	        < 714DX4Hq1y0uIT3XkTT7QkNK316XS1W5nS365S1YAT3tu1jCv2g1567X8jR7gJXE >									
//	        < 8rMIu0Otro1C5fE720ez537t05KqdD6Sf0iRks6J2JkLr38K1a43bMh0F1V451w6 >									
//	        < u =="0.000000000000000001" ; [ 000027813954280.000000000000000000 ; 000027821277863.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A5C8B9E4A5D3E6AA >									
//	    < PI_YU_ROMA ; Line_2809 ; 4eKI0EEmVcZVi0rL91l3E92i94xt06iJK745Ll4J6K7PAI6g0 ; 20171122 ; subDT >									
//	        < Q21KKFKwV33p05Yo1gYy4w0J88mMmF0RG13XXNEy7e3n91zMpaoZj6ENwFmR9w21 >									
//	        < QHM9PCUA04012G3V24ZYU9QgoRj7pKTk6rSW8RS6sLp6B1Jp29r712Ptv1843yi0 >									
//	        < u =="0.000000000000000001" ; [ 000027821277863.000000000000000000 ; 000027827713601.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A5D3E6AAA5DDB8A0 >									
//	    < PI_YU_ROMA ; Line_2810 ; S26j262tY10EJL4A6O795mw656td4NQxdS2xP878W5aTQldAu ; 20171122 ; subDT >									
//	        < 7606y2l7YcII2JRr0I59f2v8TYg5Yf7G2mX0hk12CNzXHzF9wWN8xu2Xt1PB1Umq >									
//	        < 4bMjjNm7wKwj7Nl41amL5YmwEdqeOKF264Vvr1nghJv8y0oAl9K4uq415cUU7Bw8 >									
//	        < u =="0.000000000000000001" ; [ 000027827713601.000000000000000000 ; 000027839448566.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A5DDB8A0A5EFA098 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2811 à 2820									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2811 ; Apd7YPst94x4jc5lDe5i0pVc6W4Q9FbQ295iK4Vzp9FtUQStb ; 20171122 ; subDT >									
//	        < 1yZX2VIL99D90cpfe4i68e5sZWLpgyB25ZysnR76xqTH56IpNrOcw7F1NEr5v4A7 >									
//	        < fFSxJ5PJ4B00L5CDlE728g1ks5v9wqqKrLFTllQsuUM5fCXI9dv2fsyMotF8vNWt >									
//	        < u =="0.000000000000000001" ; [ 000027839448566.000000000000000000 ; 000027850026494.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A5EFA098A5FFC499 >									
//	    < PI_YU_ROMA ; Line_2812 ; Eb4Bsp9YOR4lm718KOvLgqhKZd7ynGm73a800yGDJ2p6uCfB0 ; 20171122 ; subDT >									
//	        < 186RZ2X6GO6QT90bP9Ib3KEA6r46hPeyJ3EvL5k8j1XMLA7s4EA4vK0E4Fq3n3J3 >									
//	        < 4p2f6MAog5573A1l11fz0lm4gQqKaDn0qVrQC8j79i9GoLLCPlQjihYG2wK9ycfN >									
//	        < u =="0.000000000000000001" ; [ 000027850026494.000000000000000000 ; 000027859315441.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A5FFC499A60DF118 >									
//	    < PI_YU_ROMA ; Line_2813 ; VQ5IvyYA06s38C2I3CN4x3ahK6K85i5Dma0Tyw6kG5485Q46D ; 20171122 ; subDT >									
//	        < hr4IX7W89oZqEqXwzGdaXfhpM3VMnwx651q2rIE42jv23VtvVZlSw595nBcmuQ8G >									
//	        < l7V93Cgd9ZsQ6j8RMz1A83c8BYJ2bOF9kN4Jk88GV7X08jbMulQCpdcXC27RkTJ0 >									
//	        < u =="0.000000000000000001" ; [ 000027859315441.000000000000000000 ; 000027868087580.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A60DF118A61B53B6 >									
//	    < PI_YU_ROMA ; Line_2814 ; xnJt4P8hkNu0Qy25A7oe0L9N09yYRiuqe10MOdp08B683D9lR ; 20171122 ; subDT >									
//	        < 8dDHJTU16fRY22fy3GIGkW1kZ4t77G7ZPt61DudayX7Lqxv2DyQkw754OocIn98t >									
//	        < 7i6tV5HtbpY408oEQq8ik06BVMJ8aP7Mt9Ake02cK9ObCUqs7LIknIxB2ayy1M9c >									
//	        < u =="0.000000000000000001" ; [ 000027868087580.000000000000000000 ; 000027874723308.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A61B53B6A62573CA >									
//	    < PI_YU_ROMA ; Line_2815 ; N81P5KWe381qoEJbx0AI10P1mQI5OHT32a077rT830iaZB1Va ; 20171122 ; subDT >									
//	        < lprb6QbvZTv2Qq8A0BIe9ovzpY0Gn4ES059qpF4q1s6A9eNU9dUpi3XOY6e5Kyll >									
//	        < DtPW10ZecNn1Nn3d0594MUm4jYRucEnTeKd88c1p7Aa9CA0c0luOd2tLvgWkKk7x >									
//	        < u =="0.000000000000000001" ; [ 000027874723308.000000000000000000 ; 000027889451626.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A62573CAA63BED0A >									
//	    < PI_YU_ROMA ; Line_2816 ; u35TTcN8p3o5j9fJV1wOsZGSe6TbnAv7Vp65R6BY1ePF0HQD9 ; 20171122 ; subDT >									
//	        < 702d558u8T718cQlejRg2q405n6cP5uYyp44gu5a5KrYK2sYARjgu4bm7lO5k62i >									
//	        < qds2rCp1MHWt2O52i17gpbr3hk9jE8Aa5cHbr5v4b9RNp26Y562J59Aq42LJqyaT >									
//	        < u =="0.000000000000000001" ; [ 000027889451626.000000000000000000 ; 000027899066710.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A63BED0AA64A98EF >									
//	    < PI_YU_ROMA ; Line_2817 ; g87uE5YU8zAF1LTT7jL7903BT0i5zs5R9aIF3k05MQ2I2h104 ; 20171122 ; subDT >									
//	        < 49BwXwdHQAgLeid4fkdPn68GwQ85hJ2396oCU1nJbmY5g272tbrt05LsyWApp923 >									
//	        < kxZ8bOL953NQeJAFv26UAebl9Pr1ki4y6j5LB9UaWGF7CNNvzbv41hYU6xyGymtN >									
//	        < u =="0.000000000000000001" ; [ 000027899066710.000000000000000000 ; 000027908556830.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A64A98EFA6591403 >									
//	    < PI_YU_ROMA ; Line_2818 ; Vx4M77ZDOz9Gcnh60X70maMtI88iaFV9L2jc821haZ0K04kW1 ; 20171122 ; subDT >									
//	        < SNk37zEPF5cL5XnJvzAwND91nY6F9XUKl69Z5N8YNrpU16Ba1Hu39hZAX7F6o354 >									
//	        < 3z5sv8y1OUaVJ46GbE9J2RMLpBuWub28X91fZW35f5Gva3dma8y16a14P50v353a >									
//	        < u =="0.000000000000000001" ; [ 000027908556830.000000000000000000 ; 000027915587878.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A6591403A663CE83 >									
//	    < PI_YU_ROMA ; Line_2819 ; dY8DkcYfMF4wRqsK2W58cV5gPb3M392NQ06MR6SBymi8J01cW ; 20171122 ; subDT >									
//	        < Bp5B7i095WkOpRtm0S65O3vtXn4fGGHu8x228HNwr73k97xVbJVwE91X7h7BW0rS >									
//	        < gt6Dk76i84gkZHIgyAbV7J28crJNl8q1WBrjnSRQ4PHvxw7F8muPzUHLM1M6482C >									
//	        < u =="0.000000000000000001" ; [ 000027915587878.000000000000000000 ; 000027924197313.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A663CE83A670F193 >									
//	    < PI_YU_ROMA ; Line_2820 ; T048VJk4B3nUPIxyL7MO7erP9BINf11dA08h8d7bQL6UWySJQ ; 20171122 ; subDT >									
//	        < LOx2N1eQ2J3WhbWhsk2Xwo46hL2wc8f3H0e3zTrsh2bSYaG7G8w2h2N915Xyo94u >									
//	        < 7i0SX1gQqwbSkBJJV9ubA89661jkx1B10qBIn9oHUdfLKC2YSYd5620Z5aZVK4VA >									
//	        < u =="0.000000000000000001" ; [ 000027924197313.000000000000000000 ; 000027930624336.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A670F193A67AC021 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2821 à 2830									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2821 ; L87tEgD8t6743S6iCUI4ZlKqUTLRX12F95e11p8xDNydGs64M ; 20171122 ; subDT >									
//	        < uILxJULNU6T15cPadl9xa5NuZ8ZWHthE7Hbc3w0qKOLe8B5Adw36W3O8L1pa3jsv >									
//	        < wya6wp92PdkqP6B7GPWZeOf8W5VCYX0E34x71jiCDaND1f33bsmaBTzSA46pG1Tq >									
//	        < u =="0.000000000000000001" ; [ 000027930624336.000000000000000000 ; 000027938138472.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A67AC021A6863757 >									
//	    < PI_YU_ROMA ; Line_2822 ; hK06lU4NjGP4G6qjqOFgzDe60yyp466OHWCQokid8y6W98YbI ; 20171122 ; subDT >									
//	        < 005f86OS37q1ic2dfjK0Fiy7uA21JN2otdJdO0rhY8g31h0rN8sKbLKn7iWBs03R >									
//	        < GPVfJ3GbhPSky2oAuKXzUwhob3kB6p3LL5JU4iTKR04G7R8aSj6pusti1SdP52kH >									
//	        < u =="0.000000000000000001" ; [ 000027938138472.000000000000000000 ; 000027951500856.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A6863757A69A9B05 >									
//	    < PI_YU_ROMA ; Line_2823 ; qcGPw5hjURC8Qt7DFVJ5zJCV0q98uXziQdT927Z6cw4niwl80 ; 20171122 ; subDT >									
//	        < SlTv8gZRXF0aH0sXrZqLMI544WaROcEUA1oITdb0s3ye0zriBH4uRen9R7X4Jh6t >									
//	        < 3FMFK9Kq1IsJFeB4lu50PIO7DtBYzi26Jl0L39h4w8gal58S1o6w39713g4zKfn7 >									
//	        < u =="0.000000000000000001" ; [ 000027951500856.000000000000000000 ; 000027957513748.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A69A9B05A6A3C7CE >									
//	    < PI_YU_ROMA ; Line_2824 ; oC7lu4jmJlB6LD8Kh2OoI1ifcvd92i0u5jOf9ZV46598d7CPo ; 20171122 ; subDT >									
//	        < 63HAmm8z1Be7aK2jh8g0ibuRuJfHV4w3f7o9Dp84QbJ6u81Y1UlkeH2TtB2Y3z5G >									
//	        < 7RXd4IxU01k37xJLUw0isls79pcFk0JPNlJA350cYp76k0Ys4vh6eGvk93w91DrW >									
//	        < u =="0.000000000000000001" ; [ 000027957513748.000000000000000000 ; 000027969619596.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A6A3C7CEA6B640A7 >									
//	    < PI_YU_ROMA ; Line_2825 ; Qb0E6gNQ0mN2vJeXMAEEm7id6u83NMSa81KUs9F8oSmBkBj75 ; 20171122 ; subDT >									
//	        < zTO7GE6xtzCGY45359u4Zn22eVW3872VU3zInT3316cmvp41ct72Yy6t0fGDR05P >									
//	        < 63hkixaYmezfhPfyq8OguEzm954UfAc96cZ55L8D8559fwRDLBZ0BxkwJCfn1qNH >									
//	        < u =="0.000000000000000001" ; [ 000027969619596.000000000000000000 ; 000027980581689.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A6B640A7A6C6FAB8 >									
//	    < PI_YU_ROMA ; Line_2826 ; 34Oh2T52Xz5mrrM37P3V0aFhWl5g89vUJrHqEYlgJ0j53WJYp ; 20171122 ; subDT >									
//	        < w2KC4t3y9DE7dVfDy0Oa0R9sw9Kjd5UP6tK3fWJALv301j4TW7jK11C40fOYk1v2 >									
//	        < g8b4vOXVt4Lm5bYmOum3UJ48wWd5H0L0kB0A427hcL6f38hTCn0LKxoIlL2fzwSb >									
//	        < u =="0.000000000000000001" ; [ 000027980581689.000000000000000000 ; 000027990044351.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A6C6FAB8A6D56B13 >									
//	    < PI_YU_ROMA ; Line_2827 ; ie8d3yCZhOw1Mvc4t0C21Hi1LsnIixdwBoDcqjc4j5QMeG0T3 ; 20171122 ; subDT >									
//	        < nHE1YhNTC9pQz9EL8719UTItWZV2F8MPc556MI88nYZe5n4v1SeV0z7l6FbAdPS9 >									
//	        < vndAU1d7aBe6vh0Gc67Ay29nJWRVXuMuiPPT64OYa8EhEpI497zIBvqT87yCLsmi >									
//	        < u =="0.000000000000000001" ; [ 000027990044351.000000000000000000 ; 000028001900032.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A6D56B13A6E78233 >									
//	    < PI_YU_ROMA ; Line_2828 ; 1vxTqz0j56BUQtcLwshFP22sDckO4356FO1wccDGLFpvXGWKg ; 20171122 ; subDT >									
//	        < 0k0lqFAkesuZc8sl3RBXhyYfo12l5vqBCSm89k7f64DBgL6D0K7uEaL48QIQ973Q >									
//	        < m4Br7CMGpZCuurnbB5NA5l529O94i8FrqurPORAvIKRwPZW45a9a2mw1fQmgpfVe >									
//	        < u =="0.000000000000000001" ; [ 000028001900032.000000000000000000 ; 000028012601357.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A6E78233A6F7D667 >									
//	    < PI_YU_ROMA ; Line_2829 ; 8oMU2tM0dG9qeD8CQglKc2uNIln5VVmVbV82810Gl2YnuNaxm ; 20171122 ; subDT >									
//	        < Ez8JQM87cY63eB8Jr6hCyb8xYpKSbsZF33iYtbT0Qh1DT84LY2eY34FQxFPy3tib >									
//	        < 6rzoTZ6T7Dso7OJ2uzk8Dh68TSo1N1RR2Re5058Fzr9vHF31pMOuI6R8D591F9L0 >									
//	        < u =="0.000000000000000001" ; [ 000028012601357.000000000000000000 ; 000028018634806.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A6F7D667A7010B38 >									
//	    < PI_YU_ROMA ; Line_2830 ; A8Qnv3y73qF04x144Lvw7JPPQ751Mr2eN5zXr946bmud0y80o ; 20171122 ; subDT >									
//	        < VCfk9dp8PyrxB1vJ7Aph0o454BPQmLHle92RJFtzYo75X29Fm403Espd2bH3W8S4 >									
//	        < a1D2s00vhtop9WB49Fi22r8bk1ZpWtn9Nh55703577fFzU7qLa5v5TssjyU9IAsR >									
//	        < u =="0.000000000000000001" ; [ 000028018634806.000000000000000000 ; 000028026830213.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7010B38A70D8C8D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2831 à 2840									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2831 ; RVwEyIXdiOB372ikf9bcRQ26E60NH4ec1aAN1CLYXXG63bhZg ; 20171122 ; subDT >									
//	        < vlL6vD164Udn03i9PzE4j08uPByO6LbzlxX0DZ6aK1XGqvOWQ71R5hrvpd3dVy2k >									
//	        < U2xf1697E2FWOyc2rn2czasNAOn8hPW0X1O1TD8s28BXPb1wCxGIEEyCT5BP73lQ >									
//	        < u =="0.000000000000000001" ; [ 000028026830213.000000000000000000 ; 000028033209982.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A70D8C8DA71748A6 >									
//	    < PI_YU_ROMA ; Line_2832 ; 0mVEu9eW1K3109NP961o7Pk00phVJ448L8792F94eIoukP2J8 ; 20171122 ; subDT >									
//	        < FFfhN61asJaD1qeomFi8GZAcMN4U9w8fzP83hBlHSsD96M1A11j8935YsbuEFdZm >									
//	        < jk0D8c6dvGJl9VT0t8y4zjg7Ks1tD39OuJzGrs25oNVE30aUUL7L9GNXy1AE2uP6 >									
//	        < u =="0.000000000000000001" ; [ 000028033209982.000000000000000000 ; 000028045263805.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A71748A6A729AD2C >									
//	    < PI_YU_ROMA ; Line_2833 ; NITes82q17n20fk79p48C8fixlHnQ8Oza8721nK85YV44P6tE ; 20171122 ; subDT >									
//	        < m1TnYg5haH91rBoqtgad4sREQgCEWuY0776tnrSb8vcImY2a2wKr33ks6j20aX39 >									
//	        < 6z94s1y024NsVB6A8hW8fXbl2O623nBHpqH8lEd7ObDRls6bbZEfBIl32fVa68Ze >									
//	        < u =="0.000000000000000001" ; [ 000028045263805.000000000000000000 ; 000028052202289.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A729AD2CA7344384 >									
//	    < PI_YU_ROMA ; Line_2834 ; pdi6wFGJZbt6y4yGkkm220phogyilwSoZze8vIkA7d179R0Z6 ; 20171122 ; subDT >									
//	        < 37c8EwtRElCoVI8Z4toilNbv16m0p8RmF2iWytzLqJtkvHC05B7d2a52a388Pu54 >									
//	        < k6gBh6Jf7vtW81gYG83ciyKJuHc0iLZuMYK04P6lu83KB0T986yZ6g6DrdgQHcS8 >									
//	        < u =="0.000000000000000001" ; [ 000028052202289.000000000000000000 ; 000028064746880.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7344384A74767C0 >									
//	    < PI_YU_ROMA ; Line_2835 ; Crdo3HHtx3qfjSCKUUbv7TXt2Zo9Y2m44aG60Btd50W2dE6M3 ; 20171122 ; subDT >									
//	        < Lxe7000kj1pYVz6lxnXO5ZU30aDaJ0057r9Ccat3P1wDjvdcJPQF8IkUQoWhv6Z2 >									
//	        < E5CWAc8d4X3EMge4Lq2BK9LVJX25nGHuiM17k1smj23cy42Mh8Zf59L2o5DNhLRU >									
//	        < u =="0.000000000000000001" ; [ 000028064746880.000000000000000000 ; 000028075685803.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A74767C0A75818C4 >									
//	    < PI_YU_ROMA ; Line_2836 ; WB8k1kMz8lx7FxiIh9V9GjMQmgcM71e2WFV3WCkXw7Yv3y6Nl ; 20171122 ; subDT >									
//	        < u15R95qwtZrOT2401s5gz3Gb1SE0UBZ7Vqa8K34S30AVokumI05Vxi6ik10x36PH >									
//	        < y0P8G52w7929572PX13a0t4Az1ld03J7u6Odcy58v6b2eP5hW4cq6c4KynGh5V33 >									
//	        < u =="0.000000000000000001" ; [ 000028075685803.000000000000000000 ; 000028082494161.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A75818C4A7627C48 >									
//	    < PI_YU_ROMA ; Line_2837 ; T2q5i11my1A96G8oD7pWje3iP4815JgPYintQPu8LKd8xagvn ; 20171122 ; subDT >									
//	        < 1X0y81xzXydsHxoq6ABZ08nMkPlP071Q27uViV5G2yf3644G1v9acA5K4Q94ZW5E >									
//	        < wD9lU095uGRc7uhq61c3YJo4knhR8ERY3ffTDKI96s63A3QLwoFU09x093AjAeOd >									
//	        < u =="0.000000000000000001" ; [ 000028082494161.000000000000000000 ; 000028088989905.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7627C48A76C65AE >									
//	    < PI_YU_ROMA ; Line_2838 ; 272tjf8N0oy4An4z31v6bvm6xfGa6jF1DV3vdj5CUK923AlW2 ; 20171122 ; subDT >									
//	        < L6q0nVh0XHC03yMTBm1eQ0Ta27D1vd3981vxvJ0WWE2KW832u9Im6bUVM0s3XJ21 >									
//	        < Boz0I569X07q57B8dLapGjRvoo15o1YrQXMA9d3bC8O0t47w7mGD2sBd7lkDuB19 >									
//	        < u =="0.000000000000000001" ; [ 000028088989905.000000000000000000 ; 000028100798835.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A76C65AEA77E6A8B >									
//	    < PI_YU_ROMA ; Line_2839 ; A7SGew6D4MmMD3nG6qk0M89SbrhWpX8fOB1CTORc9o8ZDWzM9 ; 20171122 ; subDT >									
//	        < ObLQEj37kww6fP3hgFDV0eGZVdA83u4w3Mu355650Ch668Wn3oROM1wUiIamaVs9 >									
//	        < j6320Na84NEt398s897XfA0nugByEsRBG5tLF5ssa6uAD888gWDxhavD9Ts4AB96 >									
//	        < u =="0.000000000000000001" ; [ 000028100798835.000000000000000000 ; 000028115614785.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A77E6A8BA7950606 >									
//	    < PI_YU_ROMA ; Line_2840 ; NF0qSZensTwaM6r3X5Np8NzHrIdPc8DrUZF8VHu4zLF97Rn28 ; 20171122 ; subDT >									
//	        < vGx0q92CbjsVb4HFzm3um7yq70VjBZj25We311lS4aN9fjF13qRPoVYE2Gid7ar2 >									
//	        < d5s90TDuK2J7I8aEvY5ji8QJSDRk1C2a2C3Xe1qaZ30x5cjJN0e12Jv6hTja70wE >									
//	        < u =="0.000000000000000001" ; [ 000028115614785.000000000000000000 ; 000028126707805.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7950606A7A5F33C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2841 à 2850									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2841 ; r9ry26B7ik5xFILfV4tS743P0p3jCpk7iVN4nYnlU6I304505 ; 20171122 ; subDT >									
//	        < x4H1YF66ytVQ2cd1H0AxAP7Dwut3xG5hmbOC4LAtV7sfRtkX239208oVsGtUpw9S >									
//	        < FTU3m6424zoIdx8UpBOuuQeL0I464jb2uYaKlwhgX4R078nvUpWV3fREIUNcxq42 >									
//	        < u =="0.000000000000000001" ; [ 000028126707805.000000000000000000 ; 000028138622945.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7A5F33CA7B82196 >									
//	    < PI_YU_ROMA ; Line_2842 ; v5q041wxZalIksmzEwA3XAUp1kqk3OBNlXEQ5IC7k1H32IdGa ; 20171122 ; subDT >									
//	        < BMr2pa3jA6iopdF4Tun003r1HoWp046N8Eo9RlqH0oHVCl9S87RF56d7j2nu2I3e >									
//	        < 9prMALo0Ie88DNKmc5f99T9cVdtz96hTVFC87Ga0344la3avmXkd23v73XnwOMpX >									
//	        < u =="0.000000000000000001" ; [ 000028138622945.000000000000000000 ; 000028151590808.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7B82196A7CBEB28 >									
//	    < PI_YU_ROMA ; Line_2843 ; 3L8L2OTyhc4XaWefRZmtTk8AR6zUz90t47N62905VciW9i62E ; 20171122 ; subDT >									
//	        < Rlg0A955xCZW5g1uGuQ1E8e8vV6FiObut4zZ4M85faT6548PvoyC2vN9nNI4jT40 >									
//	        < aHh9twn2JiNZH60XH68BMy1o56zdyHlXmbnP3D4Y57IS883nZEF4nTT68Qp9Fugu >									
//	        < u =="0.000000000000000001" ; [ 000028151590808.000000000000000000 ; 000028161797845.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7CBEB28A7DB7E48 >									
//	    < PI_YU_ROMA ; Line_2844 ; yyP2l64H6n5WX70jvr1QdjVnC25YKS1NGZ4H1oD6nACSMjjYW ; 20171122 ; subDT >									
//	        < DzYPMDq1KEvUKFXCDuTH6tg9sQwMmEmNFw6059V5008RaVJQaM9BRLpVyYi01keU >									
//	        < C6mJX64iba87NK5RxV5G38yD4U1gKo34g6TcVVF3UTnWP0qveS7kx6zbRKOBz0JS >									
//	        < u =="0.000000000000000001" ; [ 000028161797845.000000000000000000 ; 000028169083543.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7DB7E48A7E69C42 >									
//	    < PI_YU_ROMA ; Line_2845 ; VFz73T8TGptCC4UKhODcnUSsmIU17qQME176WK6X0H69Mr8ku ; 20171122 ; subDT >									
//	        < gF1CoW18W8m0r1F1ZXvEp5JYrk1lIOdZF0N1GemIeFXQ9I0J5SxnWt3wDps0Piyp >									
//	        < g84aHQo9024Y0R3M7UDFEkI8za62298wTfZo74y18PuXA1mLZi896WyVL3es42C0 >									
//	        < u =="0.000000000000000001" ; [ 000028169083543.000000000000000000 ; 000028177965925.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7E69C42A7F429F0 >									
//	    < PI_YU_ROMA ; Line_2846 ; 5a4UZZrdXX4holN5vB17818F80JRZ5DvfcQw8ewF6t4Ksg15x ; 20171122 ; subDT >									
//	        < 98TpC8Ds22Vqkd5f4dL9m7JLskO6wx9o9VkIi3vv3Vh71x4GbV2m0eP7jsD01r94 >									
//	        < FcqCV3Po7esZZv5j2MhE5ldOGQr77OYIGm61O7umlXk2917qZiZpxLMD44kM59q8 >									
//	        < u =="0.000000000000000001" ; [ 000028177965925.000000000000000000 ; 000028190663867.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A7F429F0A8078A12 >									
//	    < PI_YU_ROMA ; Line_2847 ; 3rZ8295YsGL95JxVM27ySFb0j0iYF614hh0FG12cua0IL47rh ; 20171122 ; subDT >									
//	        < uogSQBnC6yAhl5P682lj9BonITScxWoLn8ALAZUuqSkD13bgzFHH7CL3J4a2ml5x >									
//	        < H3MXixWvSX169rY5p4FLo0nR4e9mTOSD9ON78bUe9o4CgFxK7H9v160akLjZwO7g >									
//	        < u =="0.000000000000000001" ; [ 000028190663867.000000000000000000 ; 000028203129786.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8078A12A81A8F92 >									
//	    < PI_YU_ROMA ; Line_2848 ; 5Y6UnU8649441RwUOgAGq3ltD9sCDZ16ZMCMWPmg56NZT8Huw ; 20171122 ; subDT >									
//	        < o1n3FaY4R0pL45245N3t2S9i487qKAU9FW7yYsaAp8522WH5zLZXr4mnXN59u4We >									
//	        < C6P2PVqClMr89kh4Zw2Ta06G5o07Iw2k2nzeA9XVGF0L65uA3c8EV9mdmIRjhra2 >									
//	        < u =="0.000000000000000001" ; [ 000028203129786.000000000000000000 ; 000028208230703.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A81A8F92A822581E >									
//	    < PI_YU_ROMA ; Line_2849 ; uT694z761CWWH30bkG3aRlehQ01Z3uUPBNHnCMAJC30nnZU9m ; 20171122 ; subDT >									
//	        < Xb9AE8NWhGuOnbl9zC17A663mv3Dq2j41JRo69d1Y4du9T58D7dY29ee6GZ7OtK9 >									
//	        < nVzU0UMr67HG5AbIS4C77hM28ttX6hpKNx0pzSKI84E16G1beiO2n2d3S1O6t7Br >									
//	        < u =="0.000000000000000001" ; [ 000028208230703.000000000000000000 ; 000028221493611.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A822581EA83694F1 >									
//	    < PI_YU_ROMA ; Line_2850 ; V6zt8xxm6UEqX1A4b7uCC14F7mE6cIFU8fvv8Wbsns8iYwQLb ; 20171122 ; subDT >									
//	        < Zi3ANvjy7g6k48YcwBM3C4L9op507T3iLBYIw871N4vp1L9762K1LiNC5196Ef3T >									
//	        < gXi2KjGD5B7LaFQQlcXCJ40CNw44y17UNNG5r4vy2mje9RbX2Y5dJ8DQR7JE69Xt >									
//	        < u =="0.000000000000000001" ; [ 000028221493611.000000000000000000 ; 000028229548506.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A83694F1A842DF62 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2851 à 2860									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2851 ; 16b4br1xt91HbS77T6Hwarn3P2QFhzf8yrKTlj1vIG5Pbz2uY ; 20171122 ; subDT >									
//	        < MZU1Y9rUhi47r672R20Zd6I1Gy1KTTR1CZU914Laa8O43dOkjn47IYEzm188F6vd >									
//	        < Z9tJq8OFSLv3DGr1eHP5qV63Ku5QQH14wKXF0Pc2gnyGF1ZOoqoo2w6w2382zwe1 >									
//	        < u =="0.000000000000000001" ; [ 000028229548506.000000000000000000 ; 000028242966283.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A842DF62A85758B4 >									
//	    < PI_YU_ROMA ; Line_2852 ; 095xtqWUcA1h3qL3oBhQn4Khpe6jq6C814x3Anx7cspL14867 ; 20171122 ; subDT >									
//	        < m5vbP73ah9K2hcVnn3YT429Aa93Sh516ir1L5T1Wqv11x2m7CCx1MnZlpOk7eO69 >									
//	        < mxLU2T49EU7wvq58zD2M7X1hdeVMPWxyx5H3e16GUUW31tKID9vNWyPR6cuISW7p >									
//	        < u =="0.000000000000000001" ; [ 000028242966283.000000000000000000 ; 000028256489429.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A85758B4A86BFB2E >									
//	    < PI_YU_ROMA ; Line_2853 ; TGuIxWsv9UYd1egwL1HWqYX6xp8f27Q9XWn0vtpQitUhISe82 ; 20171122 ; subDT >									
//	        < UzUxJx69oHON4c8T6edRpE6JNV02U7f42741CQ39mp916WDuY27XrC7vaz7Lc56u >									
//	        < gy0a33w9zM24zE2UF63G7Tyl32warg6VmrF1gfax0LErXs2YBO736m473pA8G0I5 >									
//	        < u =="0.000000000000000001" ; [ 000028256489429.000000000000000000 ; 000028264092036.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A86BFB2EA87794F3 >									
//	    < PI_YU_ROMA ; Line_2854 ; zTSxA91NRc8y89qMo0zjjj237HP9gtxmqA32LEjZt6mIeR24N ; 20171122 ; subDT >									
//	        < 3W40V69PajE6NrUUoKdJWATL070ZaTrSP6dWrRlP9t60RlyYmk0Pqrg0054g5N6p >									
//	        < lOBcJiFDC82EJShts0L0958BSF12o6TRCI52Ft1t5tv8aV154u23p77IxqF17De4 >									
//	        < u =="0.000000000000000001" ; [ 000028264092036.000000000000000000 ; 000028276173619.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A87794F3A88A0451 >									
//	    < PI_YU_ROMA ; Line_2855 ; 474i2KJ0NGMyuV9F0Mrl8l8isldySK73q8c7cnLDRk8gfeM35 ; 20171122 ; subDT >									
//	        < Hu2rMN061aSwzGS5U4GuLc3Hkzu7Rd5z23IGkknV18TouTWJ17Gvs40108sbhq8V >									
//	        < UPOo6584HbVj6FPYS60H141tgqZrVIW6EJG7UocttjoCV9O571IVZNl8U6QfOgeK >									
//	        < u =="0.000000000000000001" ; [ 000028276173619.000000000000000000 ; 000028290131768.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A88A0451A89F50B8 >									
//	    < PI_YU_ROMA ; Line_2856 ; 19P0hiQNQd8t5fv3jFzoN5rmR2G5ogCGy591HzB6RBk1PnqmW ; 20171122 ; subDT >									
//	        < YyqYVY2O3Qcwx04NXnIx88LTaolP7B95SyLVJIAU957X8EFw9tP8oRv93jnevDtD >									
//	        < Wa3E98a90Mp1qncVsA3k03RKNQ8Z25le609VQ5Z2g8M6C934n1ZNG7R1tZfpp11G >									
//	        < u =="0.000000000000000001" ; [ 000028290131768.000000000000000000 ; 000028297882053.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A89F50B8A8AB242D >									
//	    < PI_YU_ROMA ; Line_2857 ; cGR04nMbIFBcf3oG1bE0Vs8j3Tqz6K7jRt8rYoeH06pgRIQXz ; 20171122 ; subDT >									
//	        < 84QI9dob86Ep9c1I3DhYkm2TI50BZNGl87f911HphoD2Jvt83L2ptQ2CPZs4UhZB >									
//	        < r7mNhVE1q6BzcdL94Dj26dn8Dz8vdGg524fYlmYQcPU9Q4c7PSRRHa5X45W1a6Qg >									
//	        < u =="0.000000000000000001" ; [ 000028297882053.000000000000000000 ; 000028305331921.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8AB242DA8B68248 >									
//	    < PI_YU_ROMA ; Line_2858 ; 7YRjLyiokS50eK846CUPM45lQ3x1Ey6Lnoz0vE0550Iu3sP0s ; 20171122 ; subDT >									
//	        < A1jorJf1001CiRfYPQE01H235P4wF4pipgS15ON8OSAVMj05AdYI7S4UrQ1MbuYZ >									
//	        < PqQoJP5f49WPJh7cOACMXwsc0D23mPjf3x8gGf5S5uNsy4HuJe2801GCLN0dwJ16 >									
//	        < u =="0.000000000000000001" ; [ 000028305331921.000000000000000000 ; 000028319118180.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8B68248A8CB8B8A >									
//	    < PI_YU_ROMA ; Line_2859 ; bI89h6RILCqqRnU26Cislb622hwGM80OOaPBAkDK1Rw8xFtBv ; 20171122 ; subDT >									
//	        < 8U1bT88hPHMWh70R4klD3hK6be5l0J3xw5q319gMMe1986skgbyhjUofM2L3ytF4 >									
//	        < W40ab6Biwj896M48LF1Qa8Xy1utJTIwJYVtCJB4iN3v3N4V5LCVNI2MeMr6n8DNb >									
//	        < u =="0.000000000000000001" ; [ 000028319118180.000000000000000000 ; 000028328563282.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8CB8B8AA8D9F508 >									
//	    < PI_YU_ROMA ; Line_2860 ; Qhs0Vy2SulB0Y3nQU1KhkEk611S9h20Fl7RZ6I63twGB3661e ; 20171122 ; subDT >									
//	        < CWhsBr6O4JcsC6x7H13gheYnzskz0o9sVL32eGi2D613g39nEDtOWraY6Nrge9V6 >									
//	        < flOqaWwIjCuiDEVfpaeA8SmY1O2xk9U7eJ93fS0R5NzFEb3DKupV520WTVLq13Uz >									
//	        < u =="0.000000000000000001" ; [ 000028328563282.000000000000000000 ; 000028336452014.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8D9F508A8E5FE91 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2861 à 2870									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2861 ; vVRo5m899ikbss02B4MRRC0J92rZiN81f7c6F31c818qZ3ZT0 ; 20171122 ; subDT >									
//	        < 4xo2sxt1B0Nql2mzuy6j2w0p582mk5Ji10Sknx710lKCSO4ZD0u2Zyp8DC37jSZA >									
//	        < rtO4KSFukFLmQN7SbAXtc33QLLT7HHO17E659b0FpGTw5d0GnlQBdvFZV3NmwOhM >									
//	        < u =="0.000000000000000001" ; [ 000028336452014.000000000000000000 ; 000028344920054.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8E5FE91A8F2EA65 >									
//	    < PI_YU_ROMA ; Line_2862 ; Dp840m4WQi43X01lryPK3K31WgQ86bvAWCph8LbshFk4MD712 ; 20171122 ; subDT >									
//	        < 9O2540195A6ZvroMrROtmI3cxGO591N2UIfs3h7k4fx7NdcJAx5kwt3lRcBezDg0 >									
//	        < 5b9bhdu323Ko9OP2JPVciEB24SJ3183w4TY4Qon7paUimrs1FRge31Jlqg25p939 >									
//	        < u =="0.000000000000000001" ; [ 000028344920054.000000000000000000 ; 000028350217724.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8F2EA65A8FAFFCC >									
//	    < PI_YU_ROMA ; Line_2863 ; 48jc1af2uxQoM987598hTo9Z70RK4KR6Uc644w7wKIt835mb8 ; 20171122 ; subDT >									
//	        < 3a49z7Inm3CFW8OHB6Gk5Tom3R2qY81urwuX7ntj6IDo1nU7e3QPRI2kH4tbRZ7U >									
//	        < kvyTX508WQj2spDs22tfm42gqj9jOh96KC43L1mi4nZ26da8oJH16Y9rZtV1dBqH >									
//	        < u =="0.000000000000000001" ; [ 000028350217724.000000000000000000 ; 000028362249377.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A8FAFFCCA90D5BA9 >									
//	    < PI_YU_ROMA ; Line_2864 ; 7Cs17y7Ap75FYG9hxgn9i4B4Sd9W74B4cacX7i7GTwM2rV0a6 ; 20171122 ; subDT >									
//	        < 0khT57beBBXdPc5iiZ8SvPYOldPpFKY3pM6y5qVvekWafSqcXT24nEzJqAN5VbdV >									
//	        < 2JHu50b0UkeW0h6g2dlWyR3vNtw8vFPG1wCyVXQ11gp98Zw459HKG1v389uJp11d >									
//	        < u =="0.000000000000000001" ; [ 000028362249377.000000000000000000 ; 000028371742430.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A90D5BA9A91BD7E3 >									
//	    < PI_YU_ROMA ; Line_2865 ; GjW40s7bI0koYeXk6MMNdZ5VgD1RCgRJ150Hvvmd3zp3rKeWO ; 20171122 ; subDT >									
//	        < 9w30r742QSUSf6y18VX4QCoNiSS53K5uR5MV1P2ro53HITN1RuJf578y58ura8X5 >									
//	        < IVYWx9I3W8kEB7Hu7WOVeL5gBiechWdiNHBChPpxTo25YlgXq4lO9oBYg8ee88F5 >									
//	        < u =="0.000000000000000001" ; [ 000028371742430.000000000000000000 ; 000028383155812.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A91BD7E3A92D423D >									
//	    < PI_YU_ROMA ; Line_2866 ; daBgT6j1uYGsRKNUl9xenmy2lOBF9l0XfMHB2jliy5zYWtePy ; 20171122 ; subDT >									
//	        < sU81A9fhf2F43FT77pWKILZSV6yah0370QTy54ZbP0x2K8LbobE1621CuQ7k7n0V >									
//	        < Z3l9psX2GEy5tp2UYNB94D5Sca4b6K6N757uW32a4Xec94G316fa2IKdB490v84c >									
//	        < u =="0.000000000000000001" ; [ 000028383155812.000000000000000000 ; 000028393604265.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A92D423DA93D33AA >									
//	    < PI_YU_ROMA ; Line_2867 ; l85br47PYBxd5yLqtTmry26SX9KJwsliP95NwW44nd5YTv6kE ; 20171122 ; subDT >									
//	        < XiL8Nm72OX06eMHua65h5xtz7rF4V9HSB8dQ1jKJWt4KlsNq3K9VZs8535HZ3c29 >									
//	        < DDKH4lEfn9Zbvt8EETA86WG2gotXr912Qc5x1CrJLIfVeMZC3Lv46JWyYgM1q3P1 >									
//	        < u =="0.000000000000000001" ; [ 000028393604265.000000000000000000 ; 000028401039973.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A93D33AAA9488C3D >									
//	    < PI_YU_ROMA ; Line_2868 ; n0CGBI0od6yLhs2lVB1VEE34bnYYqIbW5JSpvp7BRe28VpH16 ; 20171122 ; subDT >									
//	        < IY3hxM4Ql093HEYXZ740VzLwQd3t97BbCV4QHirmWBo19QdBRJ5WlE01Etw6ka0H >									
//	        < n7LY4EH2tN13dj0ml8m7986vIw96YlgkY4jh0Ymxq6Au92YiFKkZv846Vcc1QP0v >									
//	        < u =="0.000000000000000001" ; [ 000028401039973.000000000000000000 ; 000028413098909.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9488C3DA95AF2C2 >									
//	    < PI_YU_ROMA ; Line_2869 ; PNgDjmR888DTRCvhc3NdjnnA18X0P9b5UJPmUv0PK2FKeUw1n ; 20171122 ; subDT >									
//	        < 42RsJ6K4uzpwz4pdRl94agO734g0xm2NWL18TZGTc1H0M4dnVVzoF41Dip151WeW >									
//	        < x25LRO3BbRh8V21Zwp1BqBCD6ovSrK4b7f3Lx7m9b8wJY7u9E6Vvkgz147V3V0C2 >									
//	        < u =="0.000000000000000001" ; [ 000028413098909.000000000000000000 ; 000028421754239.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A95AF2C2A96827BF >									
//	    < PI_YU_ROMA ; Line_2870 ; NbH7ia2j8E1RU0aXCY4g303pt5I4W8i225yhJ1Yw5Hea6A1tZ ; 20171122 ; subDT >									
//	        < POhuA664l00fvw0P85q324T8v35v8g25eSV7mFuvwOYpo8qSrHZOB3TGF7ju51lm >									
//	        < RosSi774291CKa8O62c4rfXzi88f6CFWC7HrgVnJ6AOKTm4eHcO05y9875j3zE3r >									
//	        < u =="0.000000000000000001" ; [ 000028421754239.000000000000000000 ; 000028434775426.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A96827BFA97C0626 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2871 à 2880									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2871 ; 9ow56ND0g489Ui00iXdGdv0Z99QGLRr1r1R16GA46tbzznSa1 ; 20171122 ; subDT >									
//	        < q61433PpKBcpKnScu4nZniHh7s2DDnrO1NK3GuHZ88AwRo9bQm3sb05z8R6rg4cK >									
//	        < tpUIQFO8z9b29mJjMY0f91C7X8PMM8hQ097l6G27Eq46zg31PM25v1x55HNU66wA >									
//	        < u =="0.000000000000000001" ; [ 000028434775426.000000000000000000 ; 000028442834891.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A97C0626A9885261 >									
//	    < PI_YU_ROMA ; Line_2872 ; JTVw56dp9Kj3yDh9lmci3ow7cG5E2Pev5q34R87Qj61GjVBhA ; 20171122 ; subDT >									
//	        < YA90t9145FEuvl4x1Q03JQ04KUodWFoHLG0N75F562v1VQVQjgNZN2eRttpe8tpA >									
//	        < 0y8wa3M3Ef4E33f3u9cdZC260Y96q0ivN0LX45W6H27B1F8Rnv19Lb592yMIv005 >									
//	        < u =="0.000000000000000001" ; [ 000028442834891.000000000000000000 ; 000028449586472.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9885261A9929FB7 >									
//	    < PI_YU_ROMA ; Line_2873 ; 70e836JF08y547o5l9cu615Szov1Nv43K9g7hvNE51YW8U2Ys ; 20171122 ; subDT >									
//	        < 4v234l5s48KQV9zth8R10898Q46C46AdKuK9tw5EOIs054QC68oc481Q0u30U6rA >									
//	        < 1RM7c20Act55RCfTY17TOZxO9fqN21y2ZHiBEj4gP9La7h9JuEq7BTK00Xc79nW1 >									
//	        < u =="0.000000000000000001" ; [ 000028449586472.000000000000000000 ; 000028459543151.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9929FB7A9A1D10B >									
//	    < PI_YU_ROMA ; Line_2874 ; O33GXJZN7qBJl95MLHda73jU4WyPY72014G433713bV6eu7NM ; 20171122 ; subDT >									
//	        < 6VvxtOu06jL6VgAsk3D9o6uWndlYWL2986Tb5bEJmZ4nP7bom4017q3qZEQ0meKe >									
//	        < S78WG51B5yMOI85v3FJ87PIDAD0srEU2RfSXqm86gfsFU6yrK0bQ85C5Q4YVZfgD >									
//	        < u =="0.000000000000000001" ; [ 000028459543151.000000000000000000 ; 000028467158403.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9A1D10BA9AD6FC0 >									
//	    < PI_YU_ROMA ; Line_2875 ; FPFINeEC9vkGy8eFgUw08A4r5135yCZy8g0F4TLP7p0re9DJp ; 20171122 ; subDT >									
//	        < 9zC7dtI2V7zEP7Rb19J51C80B0ps7vdeAneM27NhyG7A3ILnk031YSoFw521a72M >									
//	        < 5qktbSNy63x5Uo3Nh5iCE8MBx73M8dQL2azT7N1Y6HdQ5a06FyilMSECel537TiX >									
//	        < u =="0.000000000000000001" ; [ 000028467158403.000000000000000000 ; 000028472179333.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9AD6FC0A9B5190D >									
//	    < PI_YU_ROMA ; Line_2876 ; 7mma7ERL4eA63dsY4ItIlb3MjPKv43gTic52h0sIjaM8tnPtN ; 20171122 ; subDT >									
//	        < 87H51M6EjifAkl6a9J5ET8w9D6OxnE50qB63vhARf3B0Cg39O9rmaR26HqmSKJ61 >									
//	        < or0x2M00WBCzPpXUbiNQw7zY3E7fhU8yceqA88PxMm98z275c0TjMMQJ84m2B20H >									
//	        < u =="0.000000000000000001" ; [ 000028472179333.000000000000000000 ; 000028479124176.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9B5190DA9BFB1E1 >									
//	    < PI_YU_ROMA ; Line_2877 ; d2D5OMeg8l8KSms9Sn7QGOUOPha00Dn76HbdAa1O3OQxDfu2X ; 20171122 ; subDT >									
//	        < NrS9FV44755hVkA172j3J372g5v0Mml5z7ReKAs678x8195kL08P7Q2b39Y5rX6Y >									
//	        < 0jLNpQ8b9x1f8eVF4VU15uSNN75pUnjD876y13ttA90pasJ94UuRb4A095Lw5x29 >									
//	        < u =="0.000000000000000001" ; [ 000028479124176.000000000000000000 ; 000028492874355.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9BFB1E1A9D4AD0B >									
//	    < PI_YU_ROMA ; Line_2878 ; dbO1nsMX1p11Z0Me09MB16X9mOkG6C2l8J4ehzyN6JqX4v2Xy ; 20171122 ; subDT >									
//	        < I07a1Rl0wZMyV3ZsE66HJaxE424E38siRUDn3ECCBbYP3FP41epeQ2FJ13X7SA7l >									
//	        < 946BxT48wJm7qIHeP4A7i6X84Awo15DTivbBJy6FEJRsGC5i2M74liZRHj3kcIQD >									
//	        < u =="0.000000000000000001" ; [ 000028492874355.000000000000000000 ; 000028500603284.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9D4AD0BA9E07828 >									
//	    < PI_YU_ROMA ; Line_2879 ; VWPypR9SgbSpL9gw5rDNCMkkE3mELuXbBd143PKAgg7UyO1QU ; 20171122 ; subDT >									
//	        < u901ovf9C6oP7p48Fw9y6C6vpsbE5V7j3Vbnh6qoC8Kil37JOW0jaose3NJtwgwb >									
//	        < ZSX2TSv01grl3VJP7WmZ06y41N6a9449a2X8i7qF4kMyiHJenpuB1zBy2gevGpQa >									
//	        < u =="0.000000000000000001" ; [ 000028500603284.000000000000000000 ; 000028513711596.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9E07828A9F47897 >									
//	    < PI_YU_ROMA ; Line_2880 ; 84meqTJFWs8tHAP8xlxpkiD3t1Aa9wUFAnIEAm7xZp7Xt5Y6f ; 20171122 ; subDT >									
//	        < hJ2e5nY8J0413BKv549UJo51234aB1ZVwkO5Wt6G85YJhfTn5e1Qg6Pz2fRBW7XP >									
//	        < gTb1n34E8l6L8lb975Y4mw0dySg5gx2Jx93FAl69Zs79hfRFZ4GyUt9AzXssSZmb >									
//	        < u =="0.000000000000000001" ; [ 000028513711596.000000000000000000 ; 000028526368853.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000A9F47897AA07C8D5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2881 à 2890									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2881 ; M1gSdxJc1Rf7CV0l9lRZe621321R6H41cT9ALUD77828oreQW ; 20171122 ; subDT >									
//	        < p8Vg7TLO9jrgsbSyZev9u2j3Atq273cmPcvKpEzs9kI0FtDzzlpFDL0IdA341jUD >									
//	        < zngNdnBju59f7qgS4lM66ZRN7g5N86PVQyjSPjg1QUkC7QTBU8gD8rihyI6MLCiq >									
//	        < u =="0.000000000000000001" ; [ 000028526368853.000000000000000000 ; 000028540554429.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA07C8D5AA1D6E12 >									
//	    < PI_YU_ROMA ; Line_2882 ; Z2nzTbD1G1USCjH7e2Tk1jC7UxbEsR42pFuB24XD0wBY51be4 ; 20171122 ; subDT >									
//	        < 23Fe7HB3tCHddp7R1jU1ZD0A8QPIUXMG46k3A9tuyv12z3bGfM1vtScIwCNo0VC5 >									
//	        < BJN6PxG0Upw08vG6cfmTFyfzps9ssT8jde525N03HxvXg111RFaZdLQXo77a26lH >									
//	        < u =="0.000000000000000001" ; [ 000028540554429.000000000000000000 ; 000028546646763.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA1D6E12AA26B9E4 >									
//	    < PI_YU_ROMA ; Line_2883 ; NOY79rqLuN4fJ7jT7YBR1S1gT9lq7B8x8kpU5C4bzH6u222f1 ; 20171122 ; subDT >									
//	        < 7cBQe0Lxh4aj5qGA1dTK83T54T1pN67ckee9HB6HjRumDh3kmkTwpCcyIK2Iunwi >									
//	        < n4N9oOQM8f9sJ50fWCoy19KLCx4GQKr10J5VAhLz6QClvtE0f96n7aHUWMK9SCsM >									
//	        < u =="0.000000000000000001" ; [ 000028546646763.000000000000000000 ; 000028557735072.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA26B9E4AA37A543 >									
//	    < PI_YU_ROMA ; Line_2884 ; E62Bl933Dbwv36fo9QVY8Qfd4009a7dcgc2D34ZjbMlnt30Tm ; 20171122 ; subDT >									
//	        < K4cIlczQjL568nr8a8yMtJnHTaLoc1wO8oJw3Nqrg4JJRoXiz5Lt45uV21Sw0Ua9 >									
//	        < 6ZXAEzB98f30D9C15cH67aj44eBdKGvjt0VvBE9c04677UGWZQbc1zg9bv2LS7K4 >									
//	        < u =="0.000000000000000001" ; [ 000028557735072.000000000000000000 ; 000028562953702.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA37A543AA3F9BCA >									
//	    < PI_YU_ROMA ; Line_2885 ; 4n0Q1mDS1KV5Z4raHKRl5Yt74EEX8UeF4cTDo4DIJs4PdrB21 ; 20171122 ; subDT >									
//	        < wZj1a61r20SMJtr4JwXNtw2J61hlP86ZanC7f14k9BQ1rT5i7tkNG19245c3Iwg6 >									
//	        < A1Q3x53xoTkQf771861A7DS508k3m709bM7NIFKRLtC8QwJ1r64LGF7BxcMt8Ys9 >									
//	        < u =="0.000000000000000001" ; [ 000028562953702.000000000000000000 ; 000028573900179.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA3F9BCAAA504FC1 >									
//	    < PI_YU_ROMA ; Line_2886 ; jUSIfUAA94hG60yvi759NK5WBT8O496L68rkJRjLA3jN4izD4 ; 20171122 ; subDT >									
//	        < 98wjwtqZ9LKOH47Om0NG2WTnLWb1KjF2o1479XmaRO3p1yK5h710TEqB6d57uk0j >									
//	        < 2u2VSrr5q19q242b0u7yoCEd5erb93ML5K3VaGt98q6i5y76qw6D9Qh5FIJum2QE >									
//	        < u =="0.000000000000000001" ; [ 000028573900179.000000000000000000 ; 000028585029599.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA504FC1AA614B2F >									
//	    < PI_YU_ROMA ; Line_2887 ; 1q527RN5W32w3a5y4Dkhk5aqid3FLg9Poui42lj55ss6Jt6At ; 20171122 ; subDT >									
//	        < 86YVBPU5Rlr3380k4o15781l6604wsv1DyCFXwqkGvp151AMST3aU0aPbDBg438R >									
//	        < HFcC517Npajt0SFIATh10KDg7zoOGw1SR2fE6v9hI518nGzqXE1Fj72q8O4UsILy >									
//	        < u =="0.000000000000000001" ; [ 000028585029599.000000000000000000 ; 000028592038337.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA614B2FAA6BFCF9 >									
//	    < PI_YU_ROMA ; Line_2888 ; ej8x94IqcRujR3G56X0s6pM7h1VcJ55aZx09pua4H0M4H7l6d ; 20171122 ; subDT >									
//	        < Lw9uy5hqPh3942EHY9j9qsbuTl0fm0nPDPstyK130mIGfrAYWvGyOC0PN7AjWY02 >									
//	        < U3FS0L68nps3w83G6oc761fU7a25jiQ41J8kwbRNi7d7tA28BTc1Z95450AWs6Uf >									
//	        < u =="0.000000000000000001" ; [ 000028592038337.000000000000000000 ; 000028603949465.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA6BFCF9AA7E29C2 >									
//	    < PI_YU_ROMA ; Line_2889 ; BZhvYo9v9zsOFrapBUb22dRGxdn1oBVQg1ELkc367gDCWg1t2 ; 20171122 ; subDT >									
//	        < Kn12B7in6Tc70q9715v7V27TK0v0Yp925szRvmjz42VE8ua8amMH9E03be2guVpr >									
//	        < PZgBGmr1rpbF74c9Cf598WDSh67XLd199fFoV5ZY096p48J0ok2t99G8P6CEAwCD >									
//	        < u =="0.000000000000000001" ; [ 000028603949465.000000000000000000 ; 000028610672116.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA7E29C2AA886BCB >									
//	    < PI_YU_ROMA ; Line_2890 ; KkMiUo377aiVkPeebUvoM32RTi90dSKF5n4U2c1aXx2xhFE9v ; 20171122 ; subDT >									
//	        < k46ZhaClr088bg075U02N3e31t15Y3ac3t6pcnsn9ah5D3jo5hdJ6LWbpVraki5t >									
//	        < hGwfEDb0W614Db19si2XZR0Hv74OE1XwQj517DSX7bjx9mYV90j690S4ahe46r5R >									
//	        < u =="0.000000000000000001" ; [ 000028610672116.000000000000000000 ; 000028622061568.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA886BCBAA99CCCC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2891 à 2900									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2891 ; Gv2w54ZxlQaZCJ2a1JID0AqqM2h164IEArDa2N1hLI8L394WY ; 20171122 ; subDT >									
//	        < u78vmbkJKH0q4hZqzGoOUMw49xc6Vl4fN29k82M5D9NvfNeikkJqvDs2YJ8Kt1C8 >									
//	        < V4Bc5Lv7KLT2nBA91965o1MLFbRes7sM02m4wF4yVq0p9i08S2q094KurN4sP8kA >									
//	        < u =="0.000000000000000001" ; [ 000028622061568.000000000000000000 ; 000028630974885.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AA99CCCCAAA76690 >									
//	    < PI_YU_ROMA ; Line_2892 ; aNk8QHrXeWej7Kb28R4h05jVIK764tWb05pQ45J1eS4PqL8e6 ; 20171122 ; subDT >									
//	        < O4H4Ncx7J9B8XhENoXB1pbpl940795adq6vs4p14U3AP52TNTfC6yDr82RjkUZ1l >									
//	        < W7UtLpRtM304V6mF10CXu6KALrSk1TJx8uqgoRO9NqCa4ah41K2ad4gq44ajXR79 >									
//	        < u =="0.000000000000000001" ; [ 000028630974885.000000000000000000 ; 000028636796944.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AAA76690AAB048CE >									
//	    < PI_YU_ROMA ; Line_2893 ; dsG59B297Ewy854X6H5HvMFXg0mXR18Zj6dTm75d7znFGiE8a ; 20171122 ; subDT >									
//	        < ykN8u7I4q0UvzRNZwa0DA31Mo410PrF78YznJ7798AYkrqxYrIQdcj92i54M2XK5 >									
//	        < zQk90m3Z3RH8Y068M26O3nE4I2YE9HO6SfAQE3fWB64Iv16pLKexcsqXNvcl89B0 >									
//	        < u =="0.000000000000000001" ; [ 000028636796944.000000000000000000 ; 000028651507742.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AAB048CEAAC6BB36 >									
//	    < PI_YU_ROMA ; Line_2894 ; WmT15IW2eXIX53t71TApmCtl9O40V9e2ozNEzdX7u4riwA8Yl ; 20171122 ; subDT >									
//	        < F08tf9Nue9N5z2vYlmNLIN5QgHtN7Hu6UAj6hnMdxgoWH26PRn3KAcx3Z7R971t1 >									
//	        < H4U9k6F2wV0ldDD0ggAEip06q8f8bM6MyfGQ1vPNkTPHT4x0944jCd44mwPmr7em >									
//	        < u =="0.000000000000000001" ; [ 000028651507742.000000000000000000 ; 000028665412829.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AAC6BB36AADBF2E2 >									
//	    < PI_YU_ROMA ; Line_2895 ; u4PW2sBXvAC1iI51P2RX9tj9LC3kslPk6FjvWh2z1mn1lg4NP ; 20171122 ; subDT >									
//	        < yXp8dITcqn0893zuv831b4s8wPoK9Ml47n2g638T51jvq093871NX2GOv7L8h832 >									
//	        < ZgPj7PDEhb689R0tb5hToHqL8ToPmgKyN5w9WOp5jr1x8G580HGclcKBWBXly18U >									
//	        < u =="0.000000000000000001" ; [ 000028665412829.000000000000000000 ; 000028673644842.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AADBF2E2AAE88284 >									
//	    < PI_YU_ROMA ; Line_2896 ; ED48O6DuZS3Cr3DC8U189oFSWSj3L7GkgruO5Ehd7E489eFms ; 20171122 ; subDT >									
//	        < lyVivFM7v0dOgThfYRWj74d7HfFP6i9IQGGhjvT4bGgd92F6I3AQEr83I18LlrnQ >									
//	        < x92sOH6QOq9TR5AEY1N17ABiB34u12XOWbI6nKH5UpNU0i5n24tuoPS52i4yIX3V >									
//	        < u =="0.000000000000000001" ; [ 000028673644842.000000000000000000 ; 000028682793918.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AAE88284AAF6785F >									
//	    < PI_YU_ROMA ; Line_2897 ; 44Ym7y0d0YPwA6qV964zP359r3VR08a362K779R2j44VQpu48 ; 20171122 ; subDT >									
//	        < bKCBP9z039zmbZpyRMhd62ArkDJAH55x5NRvIW4l8GzJ674y56hrL4YDX176BOns >									
//	        < JVBTtLtO28QRbyUtYra18L72BFA2KFm3z46cpFqpjbraSPcWaQj3YPDrgVb9Tsj7 >									
//	        < u =="0.000000000000000001" ; [ 000028682793918.000000000000000000 ; 000028689497240.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AAF6785FAB00B2DC >									
//	    < PI_YU_ROMA ; Line_2898 ; 6N65xK0H7gOl8Dt0b65FFo3s6dWScQ7B8BuPSDP0BrD6uoEme ; 20171122 ; subDT >									
//	        < VE89XbczIG7ydAJl6S8fNmTxpv69O4HlnAakmRa46utsUCkh6ChRlO9g66JQ01gL >									
//	        < 20466I5cz6cDy3z6638PHsj9Uw0bKy5Q2h311I95k5IHNRsvlSuuV2jbAggllC1o >									
//	        < u =="0.000000000000000001" ; [ 000028689497240.000000000000000000 ; 000028699815542.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB00B2DCAB107172 >									
//	    < PI_YU_ROMA ; Line_2899 ; ZTH4s41J8oD1L097NF7KDw6SSo5nrQ2dzBe04QSHT7bVN7l13 ; 20171122 ; subDT >									
//	        < 48zq6jUVn77c1sZfG2NjbApi0cG5TNJ8lN7wjV67LcvMktR7LWc4lYP7PEC01z12 >									
//	        < bfA34yTq7Q4OUyBWpl84u09rxP05G89I13PabUv963hqcBZZf2M8x2Erj02P83cF >									
//	        < u =="0.000000000000000001" ; [ 000028699815542.000000000000000000 ; 000028712144877.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB107172AB234197 >									
//	    < PI_YU_ROMA ; Line_2900 ; 2m4R697HhBgzVxwhY549gfcnv6t6tcm7RL8P9kV3QzdA836nC ; 20171122 ; subDT >									
//	        < 0ZINm0cex20Y9u3SERy89MQhwdnAgR24M6HC1XaJrIhaoTPy76l239U6HU1M9q7j >									
//	        < Wn1w1Ase55cJ268afuy6gCFDS6aTm2qJYhoId5iqT8IaSC3GTejGYYcThWNajgbd >									
//	        < u =="0.000000000000000001" ; [ 000028712144877.000000000000000000 ; 000028724199465.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB234197AB35A66A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2901 à 2910									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2901 ; f2IRt148ASlt1O8v9khdvAGbAzVpvEOc8y6D30d3xar0vUa0J ; 20171122 ; subDT >									
//	        < mU25XORZ2X4rwR0CBv5gcL95rO00a8CKWrk67E92br2s6Fcz08qVOX6oG1OOkBhq >									
//	        < Sqkx256zRO73I3y9EAf6d6TY3oV1cLgnEn9Z83in72LorY3a9oHQe6FbGNnW5cJF >									
//	        < u =="0.000000000000000001" ; [ 000028724199465.000000000000000000 ; 000028729788433.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB35A66AAB3E2D9B >									
//	    < PI_YU_ROMA ; Line_2902 ; 6hczW3M4l37VlkGdc93AZzPzVP6R50a1mj2mPvB0cLCi95QBH ; 20171122 ; subDT >									
//	        < nblce0J9dkUGj51Q7tAgnyRWNE63vL7ZEbjz1d4TlOUFRK6NYt7tlyscdFwSgnTH >									
//	        < pUq77o83Ag9P9Syx6LbnkVwnDwe9I7K05I0UTHYsfU37u1L3AKjm923wfK93IK64 >									
//	        < u =="0.000000000000000001" ; [ 000028729788433.000000000000000000 ; 000028741633925.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB3E2D9BAB5040C0 >									
//	    < PI_YU_ROMA ; Line_2903 ; 80SfyEeNF7zO1MEb07f219qOaKwiQY5K3zJnPTZh6f65B7NFu ; 20171122 ; subDT >									
//	        < eVI1ZB948B2JpoR2138t1ymTVfRei8uN7OvTMxSom1W2hK9YUqq3uoMPitqtZnU4 >									
//	        < Sr5R6wV0ndS6VX8FD25x86pc7Y9f18s2NpUYw3QW7qP1m5PdMt57mO0CFW38bu64 >									
//	        < u =="0.000000000000000001" ; [ 000028741633925.000000000000000000 ; 000028755015513.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB5040C0AB64ABEF >									
//	    < PI_YU_ROMA ; Line_2904 ; VCDS43S4Q3Ugz2MtjC3bnu8oOZK98tY3Fn35MC9jDM7xr5Vqx ; 20171122 ; subDT >									
//	        < 9uobclJia3Bb8IV1uCZ18c5O0yYRp59H5vCJrmL13OoMBEAiN55qqTDI9L4RY11u >									
//	        < 1KZD13pF81AtflWlfDQaiHsARTG1J68zJq10v3l66s5Rk11p7bh995978c2xLYMp >									
//	        < u =="0.000000000000000001" ; [ 000028755015513.000000000000000000 ; 000028761625931.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB64ABEFAB6EC221 >									
//	    < PI_YU_ROMA ; Line_2905 ; 6w1gn3D74719Vd67k6Py0CFa84D0tSHSzQF84Rnfn80H9idO5 ; 20171122 ; subDT >									
//	        < B3K3tkfI75xF0G4rRSPD8sH88dQLdomT8V83E7H3dK7hH2LwNj6DU5G4HGbm3695 >									
//	        < 9CiU0V0jx9r3AT19Tjt68prDiMoVQ7250D6m8zLWWLGg259uhF9TpTi8fLUmc5tJ >									
//	        < u =="0.000000000000000001" ; [ 000028761625931.000000000000000000 ; 000028770721809.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB6EC221AB7CA334 >									
//	    < PI_YU_ROMA ; Line_2906 ; Vuak73s53f546Aw7V59Pm0M9z5SfYAO1vTf5yZeWNAgrcVJw0 ; 20171122 ; subDT >									
//	        < 1C4gw8snqogeDv7IDY8Nf82SF7I151YXwiql0sqR7Q1WmG1QXwmppEVDTbo2V47S >									
//	        < 51ElSxJ7F1RI567zHQF5nPYx7E2UTdrU24Y6fg1PO5KVoe5x99E41DgAg5DzxiKt >									
//	        < u =="0.000000000000000001" ; [ 000028770721809.000000000000000000 ; 000028785369289.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB7CA334AB92FCE0 >									
//	    < PI_YU_ROMA ; Line_2907 ; TpQV9GA9Zs2vL9Y75a2HI9dirXa4t864fjV1TKs0CnY2s5GL9 ; 20171122 ; subDT >									
//	        < 4A10fE0IIHp95i45vh0Kly22W6P7nwYtYDBya8BI9656cSP27Vu0rQMLK1yevwUN >									
//	        < gLpwbpR2AKgqCYB02XiSkX3Z7BY2I7OBLW4S46l33lHS48u83t5G6xsX51430ley >									
//	        < u =="0.000000000000000001" ; [ 000028785369289.000000000000000000 ; 000028798146851.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AB92FCE0ABA67C1D >									
//	    < PI_YU_ROMA ; Line_2908 ; 4j1fxO5YO65GAW6ySCUDd319KaOXUfZ9M6x1Ip2J57l3dsHp4 ; 20171122 ; subDT >									
//	        < 8qG174EUNVeVwgAA2QFAtKWCbMN98xYw335FM1ZsG8s0p96k4jh2n8HKO21O750Z >									
//	        < xIRI47ZQfAoiQjlG549uIgj770W9IacFVFFn6BfpHksRU6j7hCXi0n6rhE6ixl8W >									
//	        < u =="0.000000000000000001" ; [ 000028798146851.000000000000000000 ; 000028812044692.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ABA67C1DABBBB0F5 >									
//	    < PI_YU_ROMA ; Line_2909 ; pekm644v4ILqFRcsF7Y4wX1Z1C274T6NPoY21fcEf7578aqpS ; 20171122 ; subDT >									
//	        < 1WzzAD8JyFglHLDz8tYsXzW93t9CBBPYx9ZStUD51wf5ml81be2Q8dv4eOAiB857 >									
//	        < 50H3VugfI78uv34SsawN1RxpsOoay953cCo27N1244nC8oI2wzyDd3cdUCwTf5Fv >									
//	        < u =="0.000000000000000001" ; [ 000028812044692.000000000000000000 ; 000028817439800.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ABBBB0F5ABC3EC6C >									
//	    < PI_YU_ROMA ; Line_2910 ; ovBml715r2W4djFP3V77Ub6yhS80RHf6eKV4Wk0p8ev3TiX5u ; 20171122 ; subDT >									
//	        < P0750gFtQ8E42H4zm1w48x9xSHmpqK2dUTb09m65K4aXQNC2JI3u336SbACCrj8k >									
//	        < SO898RxjGH9KzfQc7E7LUWqo7rpDa76M0B06NL9MHBG5Rm6DCAfDcJbn886mYUTH >									
//	        < u =="0.000000000000000001" ; [ 000028817439800.000000000000000000 ; 000028828631469.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ABC3EC6CABD5002A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2911 à 2920									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2911 ; FM6Hmhj0wDbip61dFTU9W84Vp1z05MJv82G65T5uu0WPOUlg1 ; 20171122 ; subDT >									
//	        < 4IX89447200v564Ck37U6O3Ro1Sj2Pc59660HPnd4wI8lA6w05qUc21m865lyP9a >									
//	        < 01jFE2MIe2E152Hi59xKH92xz38koJ26Kv0a3nr173VPXrMouEJb9kxR5g4bi60m >									
//	        < u =="0.000000000000000001" ; [ 000028828631469.000000000000000000 ; 000028843556612.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ABD5002AABEBC64D >									
//	    < PI_YU_ROMA ; Line_2912 ; 3nqBNjJF70iQYiuLa4R6Bw2kRgjOVm02mhOkZARks535BUEdR ; 20171122 ; subDT >									
//	        < 4PvmzyvBLsdd3sm408mHnsH453Ngj0Td75Ds37154zW65MC9F1a2FF40g6vtLOOr >									
//	        < UEad99p0GA20Y673tsEOYB9gNE68l72PX8pJE6aE7Qm4Dty1Zm0x30XjtF9jSXA5 >									
//	        < u =="0.000000000000000001" ; [ 000028843556612.000000000000000000 ; 000028855974302.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ABEBC64DABFEB8F6 >									
//	    < PI_YU_ROMA ; Line_2913 ; QcMQEHF24QMj3fef9uInunf4jN2TyLYHk78Xiw7Sy7k8XfK5Q ; 20171122 ; subDT >									
//	        < T06rw3U129v8DG1rO2EKW438Uno2C1MKlvaAgK7Tr2JYUA25P252jLH0vUZfg8Uo >									
//	        < x7HYs3l65s7hat0x9Sga8QNcdJmf0Cz5sH75L7X394CE6eJ5NxtmzN9H4bi28XTk >									
//	        < u =="0.000000000000000001" ; [ 000028855974302.000000000000000000 ; 000028868520756.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ABFEB8F6AC11DDEB >									
//	    < PI_YU_ROMA ; Line_2914 ; QEjZxKllV1Fk85Ax1tlpkzPHrr46vSabyioDFTP0chyYU30q5 ; 20171122 ; subDT >									
//	        < l638vR67swt5qFdrLXU3fL7ls1j3n6Fa1o541Ajy04p9P3V6zW5XiYQnPoSq8676 >									
//	        < pu39186fqo6C2BpXOD5XM9O8as46dm8uZ9zavBRy88jp319nVC9p1qWC3lE6Pl93 >									
//	        < u =="0.000000000000000001" ; [ 000028868520756.000000000000000000 ; 000028873803805.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC11DDEBAC19ED9C >									
//	    < PI_YU_ROMA ; Line_2915 ; 4V01Wi43301KebyEvJEq8nQnAJNyw5ddPy9FJ3O9s8QM5i305 ; 20171122 ; subDT >									
//	        < eGJ1ANb7C08085CPTHZ5UMf28rqbi34SbAH1Z2WTU129Qe4oUx9Ur4LZoqQ831Y6 >									
//	        < Md6jqD7oYbMMlp6760Dm5ltJUypVbqNp6f9wmw2b1Wz9aUzS46ONnTDaTFysFV8q >									
//	        < u =="0.000000000000000001" ; [ 000028873803805.000000000000000000 ; 000028886716930.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC19ED9CAC2DA1CD >									
//	    < PI_YU_ROMA ; Line_2916 ; 5xLbl9n8tbu485efAO4huDQI6502i89rJcyB658Bj9drkn82Y ; 20171122 ; subDT >									
//	        < 3z4hJ14U5r5C48J2Rv9975ULhb0n613aHxx77cjMwlsB5zdDK4W3sU5s77JrWa09 >									
//	        < m82iXnnhj4jUS2pqK2U0kKn9jBwj1YKfh1eRulj3faxds4vTg063flB7cwt56n2h >									
//	        < u =="0.000000000000000001" ; [ 000028886716930.000000000000000000 ; 000028898410706.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC2DA1CDAC3F79AE >									
//	    < PI_YU_ROMA ; Line_2917 ; lSSdd6l9pfoOC2nOT2S3491S1wAsJ8d9HZkCQ2y4isrRj3Hu4 ; 20171122 ; subDT >									
//	        < Uzd95Dscn72uVfIL61yjF2MJzC8541tHF7Atj3jaUGeNmgTFfUl1iwZLLH47s116 >									
//	        < a3595YU10LGf8x5Dp0nKKN38PVe0f35w6BqF19eCBHk7dC0sbnFru3Qg5avp783H >									
//	        < u =="0.000000000000000001" ; [ 000028898410706.000000000000000000 ; 000028903946072.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC3F79AEAC47EBEF >									
//	    < PI_YU_ROMA ; Line_2918 ; 6RZMWllJEit49SHLnV46lH2h5e8nUcmgLZZP8Ku768ak59KAF ; 20171122 ; subDT >									
//	        < FifJ8lcVEo5MMa2644Z52f66Mg4642034h10KXEusMhB5KH0AJo86KCKxqtz14ga >									
//	        < 1Iu8Q76iz3GsD6B0vG36bg01qrWh7LSd4n3A3wauvZj6MF7xiUcRt6E8778ij377 >									
//	        < u =="0.000000000000000001" ; [ 000028903946072.000000000000000000 ; 000028917937278.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC47EBEFAC5D453F >									
//	    < PI_YU_ROMA ; Line_2919 ; M23MC3mWy8y85pLeU73caxxnqzFqEs7o61Qe0Ul2fbXcOLo58 ; 20171122 ; subDT >									
//	        < hJ9W83UE13ShNb8tCbFem52QPTKZSALgBv82r22LQZ6QWyZ23bdBWW9L55PK3XaM >									
//	        < T59TUVa0W5ph09tN0VB3WxfO1GBzJj5QSF5vD9Z03M5ug6o98X3WV94T7981QBQ4 >									
//	        < u =="0.000000000000000001" ; [ 000028917937278.000000000000000000 ; 000028930583862.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC5D453FAC709152 >									
//	    < PI_YU_ROMA ; Line_2920 ; uW7L3ZM7HeTECedT35fwQs720Y6IfBh4OM26133CR0n3B2P05 ; 20171122 ; subDT >									
//	        < zN1rfqqt6Vp608WJjZ998E4Eg15UG6C0nOnL2dYFhRz6Ztn179M88y3sM9xhUCpE >									
//	        < lQRB72eX4L0Wr8S9cH308XdzWf0i0Sr1v3ZiCTX86JFaRHZRbg0AdH0h2ats2084 >									
//	        < u =="0.000000000000000001" ; [ 000028930583862.000000000000000000 ; 000028942491505.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC709152AC82BCBE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2921 à 2930									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2921 ; ioGx080879eGa4M5gHx8p5129qyQi94UY3g9jPWXa5ja961cI ; 20171122 ; subDT >									
//	        < 3Ip44H3KltHAhGY12rw4RIWeaZW0pOOsrLublGcoe5te7HF6n5J26nn45g2jQ1N5 >									
//	        < tZfQtr65170Z060KPz3f3aZuiZtTXR9O37k1W4UtS3KVS3Vc7MjoWFQ3T5bkx6r3 >									
//	        < u =="0.000000000000000001" ; [ 000028942491505.000000000000000000 ; 000028953633602.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC82BCBEAC93BD20 >									
//	    < PI_YU_ROMA ; Line_2922 ; OV5n8O832kls97H8T4a79hlU6XHLfxO9PE10Yzz8W5vXY2N6J ; 20171122 ; subDT >									
//	        < 2Eyb15ie3veEDVz4K6S17Q089ZGpUu58KwQ8ohrh13z2BFkR6Q06afBEDP0WGn9G >									
//	        < L9CFospubygU238Ac6q1cvyOvajuV2no2306JFt5tpe722ZF64w4A9PAlBTWag0E >									
//	        < u =="0.000000000000000001" ; [ 000028953633602.000000000000000000 ; 000028964773548.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AC93BD20ACA4BCAA >									
//	    < PI_YU_ROMA ; Line_2923 ; 78b3g5DboysUjIxo0G62T2h0Hc0Kr79fQ1tWuER4F33s0lqXV ; 20171122 ; subDT >									
//	        < iLRv973YNbXdD0Ln0YrdinMbUWs7AUUD6gr951dqScs5Ap8Ra7d0L59gmA932js0 >									
//	        < H6Hcx638v8lBolN1ItCZFSVX7rhbSTkXF4iuRsRO72YB2Wi86069gH2n9C92d8Km >									
//	        < u =="0.000000000000000001" ; [ 000028964773548.000000000000000000 ; 000028975806086.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ACA4BCAAACB59240 >									
//	    < PI_YU_ROMA ; Line_2924 ; FE9OSp1ryFfqHsZ9w7O1xt4RP1FOtF3wEfSh3v7DxYj41V7yv ; 20171122 ; subDT >									
//	        < 9rX25G21WtaoVD7S80P2mT23LUldKSO5t2y11977klM6q83Y5xt6J78g2gseIa5K >									
//	        < ET712e89tP09z6inh09PP5usQGO6eEJMxwS2g6c13JpwOmM6ab7UD9XJ2IsutiCW >									
//	        < u =="0.000000000000000001" ; [ 000028975806086.000000000000000000 ; 000028987005742.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ACB59240ACC6A91E >									
//	    < PI_YU_ROMA ; Line_2925 ; lGibDBtvvH3HusN1khCizN47vhyX5c9tiba81K8q4zI1b43qn ; 20171122 ; subDT >									
//	        < CEh1qsiJ076a8glB3e84D30RIqcD4rbKJkxLT898691cp6UbgkAM1qXyX1zvsUBb >									
//	        < XpTcG2RZ9V2Tn86AJ1KWmGQI556zD2HZh1h7v1I2Xp5A6o5mS4rJ0740JHjRw1yJ >									
//	        < u =="0.000000000000000001" ; [ 000028987005742.000000000000000000 ; 000028998650271.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ACC6A91EACD86DC3 >									
//	    < PI_YU_ROMA ; Line_2926 ; yGA9yqanPU7ki7uQ12rA222UNJmVy2c94756q1vZLnNqNN322 ; 20171122 ; subDT >									
//	        < VVJY8l0B39UP3Bp2op4lgAircIA8HZtEiif766bHI9MLua16f4eV4M3GZwL8002o >									
//	        < 0N993gokhPobEj0660n9Key6n9v7PPza57RTa3ScRa1Xge4Q0esz4o7kVd87WDLS >									
//	        < u =="0.000000000000000001" ; [ 000028998650271.000000000000000000 ; 000029008860630.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ACD86DC3ACE8022F >									
//	    < PI_YU_ROMA ; Line_2927 ; xxG3sBQ067M0oK8V28caSSe02d189Eknu7zU7YiQzPJy0XOWz ; 20171122 ; subDT >									
//	        < q11LQ26KCn80R9xAeBdsxs2l0Tc4E6Y6J0gddX1846D26q179fP7n9x4xK54srrZ >									
//	        < JNpxW1IOK5G0Mp67v62ak4zPF9yrYp8VZJEPw2IOCbrS5gF55LRE2xwNS1Z95RUx >									
//	        < u =="0.000000000000000001" ; [ 000029008860630.000000000000000000 ; 000029022706839.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ACE8022FACFD22DB >									
//	    < PI_YU_ROMA ; Line_2928 ; V3mV2xQFYXrjljsJ2mShqQmOT24uAYs04Ur3Ao19USWG52Uh6 ; 20171122 ; subDT >									
//	        < QIg3O3dpHGast8823Y6h2704hZjmQr0GrroFa0TrHK9b9lwnSI3Ea4T4fqvx30qk >									
//	        < Nc8oD0SiU2Lw7nHizrE6zqRna7Pq54z9h1130PWQILUqXnbABBQXkN5Riet2Priw >									
//	        < u =="0.000000000000000001" ; [ 000029022706839.000000000000000000 ; 000029037257644.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ACFD22DBAD1356C4 >									
//	    < PI_YU_ROMA ; Line_2929 ; ipqdWlxuZ0O10qm436zoGc37GMM8PZSil1SQ4dO1yZWcscIcJ ; 20171122 ; subDT >									
//	        < OgHiuzlh6ZU3H4djg30yZWgsYZg60MG38jPbD7C45nokv90kFJBPSdsVY9VwRu0n >									
//	        < pV0fk2k0Lz13Vs887f5Xk782t9bR6uyIAOSnXW2N6s096k4IPA0h3m40BA3mX7cq >									
//	        < u =="0.000000000000000001" ; [ 000029037257644.000000000000000000 ; 000029051413398.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD1356C4AD28F05B >									
//	    < PI_YU_ROMA ; Line_2930 ; EKr4XMe021uu0bx5JBXljTwlqeZw6WYz2JW2Fv88pTtmU41zn ; 20171122 ; subDT >									
//	        < ni1kURqVFbNIWnWWd9MB1L3hGDHnqXK7f3NgS5Uo2eezFO25hi05cvBkFRUN1199 >									
//	        < P6O9gukDpo80g2XQ5sDTedqmThxpWK3DL79l173f4r44CoFbQ35Pp6NxO5hCge94 >									
//	        < u =="0.000000000000000001" ; [ 000029051413398.000000000000000000 ; 000029058411950.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD28F05BAD339E2B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2931 à 2940									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2931 ; YZ6kZiySbv7aEJ2qd5rFf5b16Bm1EE5oIiARBI00xqA87YUs9 ; 20171122 ; subDT >									
//	        < y2q0Z0E5Tz975HVttou4QJ7LHfex1HXdj169c7TmfA25V7CN96kHB3RmV15Yv1ty >									
//	        < 0ZoQPCM7ru1KIXG66CdcQz121CtAPW37GA8F52HL4ow76QS1jZ73BtetV633Tb32 >									
//	        < u =="0.000000000000000001" ; [ 000029058411950.000000000000000000 ; 000029068689528.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD339E2BAD434CD8 >									
//	    < PI_YU_ROMA ; Line_2932 ; c78mG0WGUp9kD8lz04k61LJ7R7kS23UxV1w1IB1d6CF606OIp ; 20171122 ; subDT >									
//	        < l6ga3B5x621op65Xo75444bV9OX04y2KbuT5ddZy9G8cb8zkT2xS5VMF4hfgkM6p >									
//	        < itWDDT1tw22Hrv9HvnFOSwrIF0I5p6Ax11iG9G1g9h4tm1yLs6bVcQLjrs8gWTE7 >									
//	        < u =="0.000000000000000001" ; [ 000029068689528.000000000000000000 ; 000029077697478.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD434CD8AD510B93 >									
//	    < PI_YU_ROMA ; Line_2933 ; T85xi8Q8k8sSYC471y2FRj1ta68Td7tF3gAJH3Gk412XUyF1A ; 20171122 ; subDT >									
//	        < 4we65s8cBq7Do3R1Azem46UgXEa709S637EsMye4sA40ZX3tTx8QgC8ihKLPsgrb >									
//	        < T0AfJP5J4191ynMsa4SGCOhH0W2P14Pw8Ni1q278E68s889rt1h6Zd9H64eh6aiO >									
//	        < u =="0.000000000000000001" ; [ 000029077697478.000000000000000000 ; 000029087778500.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD510B93AD606D7A >									
//	    < PI_YU_ROMA ; Line_2934 ; 46zw6Zejlr49xaAgAb8V4B91z6EY42kEjxo9zJ9FDyx0f08Nz ; 20171122 ; subDT >									
//	        < pHH9UF4ol0kuNA4Cf8aPkQDKgKE53Xl7t5lItqyKXZ24R1SeEap0Qwp0i1W2Hf09 >									
//	        < KlNyzLB19cQCVM7dO35CVC7P1VF902zK9xhAIXVFFI63N5RU1S04rC8HZiDsVp2J >									
//	        < u =="0.000000000000000001" ; [ 000029087778500.000000000000000000 ; 000029097668304.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD606D7AAD6F84AE >									
//	    < PI_YU_ROMA ; Line_2935 ; Nkg2q4qb8dkn5e21skOuU3AyUzZqn3Fz34bB9vS0B6Y1aN5s1 ; 20171122 ; subDT >									
//	        < 842q1Vu9006Oal3rDOx5j5neR18SYnsclPdX2DuFK1eOqRNjwaS6qgJbaA8j5470 >									
//	        < R6KFn7ImmVWoF4VE7t60f38CSIg7525wJtb6uDY27V2CbSzobbhVu2iFk4nXW4jq >									
//	        < u =="0.000000000000000001" ; [ 000029097668304.000000000000000000 ; 000029103065999.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD6F84AEAD77C127 >									
//	    < PI_YU_ROMA ; Line_2936 ; gSHlmr1Oz3Mjbf9oxx94j6K4fo5M1ZYTh6iY0hyPvmj87pXv0 ; 20171122 ; subDT >									
//	        < 05sTSY9Q5q5t062e4RSZlW8eH95URwMIaPsh7JT70TEHYLn7m4cypirffo7lnX1I >									
//	        < SO9vqoeuJ204a9pUae3G417NGTWZb757lMJz2it3Z56Wr0AS1aCNbs1paf5s9T4O >									
//	        < u =="0.000000000000000001" ; [ 000029103065999.000000000000000000 ; 000029118053900.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD77C127AD8E9FCE >									
//	    < PI_YU_ROMA ; Line_2937 ; X6Jr5DbpkdKYp9Kewgn1Y7eJ27zc19L3k98c03q0GsLeBC7O7 ; 20171122 ; subDT >									
//	        < yZNl59S8dcz2bWp2Q9GkElUJ3a5DfiGCiD5Af7rqDOWIm0yeKyiQg8192p2z75gu >									
//	        < z1AJ0wAT7cstOt1psBs7Lj1zopa77dq3jn01nhg519eo9W72HIMvcEckbtFm4aeh >									
//	        < u =="0.000000000000000001" ; [ 000029118053900.000000000000000000 ; 000029132760292.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AD8E9FCEADA5107D >									
//	    < PI_YU_ROMA ; Line_2938 ; 618Rn5j146WtID77el1444WFY6hhq3XAgIG9qJ8Cz01KLdYT1 ; 20171122 ; subDT >									
//	        < 0I5eSY013o97951c7z2l7LFJBj7w6Dir7TF0H8s25f0O6cNh1aZ6AGbR61MIuFA5 >									
//	        < q16YwDl6F972IgLii0fNAw8n8rls3iFr69ZJ66eFYxCOCRZq1291DYm22761mL7c >									
//	        < u =="0.000000000000000001" ; [ 000029132760292.000000000000000000 ; 000029139306099.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ADA5107DADAF0D71 >									
//	    < PI_YU_ROMA ; Line_2939 ; vxzdlm51Ru9832UY66OycK57SjSg3KDRV8Alpp9PwQ2xBhiCP ; 20171122 ; subDT >									
//	        < 2u95tmPF76Y59pKZyj9jGk0jjyn6Xa1B633gMJ4h6w8aVvH7WT6u6P7q5p0ObOV2 >									
//	        < slSqHAXz5p05pBg21ft3S8zUV5bLwYf3g1udNAm1W2H3z1Iu6SR378I45X8v6zj4 >									
//	        < u =="0.000000000000000001" ; [ 000029139306099.000000000000000000 ; 000029150783193.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ADAF0D71ADC090AF >									
//	    < PI_YU_ROMA ; Line_2940 ; cYR0Tx0aVjre37J2H6HxmhhnU19D9NvyAZ0JELs6mdSu9USdb ; 20171122 ; subDT >									
//	        < eno5J14eQs80c6TUpgX0uyKskhBGUx3ukVkuBQ9jC288LI0weiW7FXceWd8674Ob >									
//	        < I9oczb2S229zt3607q1OMJH9370a2maXzl4xT482tA0gwumV3UBQM1DHm4nw9CE8 >									
//	        < u =="0.000000000000000001" ; [ 000029150783193.000000000000000000 ; 000029161732572.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ADC090AFADD145C9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2941 à 2950									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2941 ; 9uR6GYWK1og7Wm3661nj3Fiz7u6Eo7z039m9VVVZAzH5Kj8JW ; 20171122 ; subDT >									
//	        < 8rxgawV76842dCLKPGLCUKXEFJtqe97eTH17k7iuUFO7512S4UF76BL56By4u1kl >									
//	        < u1bUHTYhVUVD2Z9i9F6sk2xl967ZrJ1sS3D0WBI95GWu6UFnTv97lrGuhHZE60kG >									
//	        < u =="0.000000000000000001" ; [ 000029161732572.000000000000000000 ; 000029171900646.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ADD145C9ADE0C9B0 >									
//	    < PI_YU_ROMA ; Line_2942 ; JR0ITg6uSDn4927ws973p4r3PxW6C0Wzfv40ogpS0G9vztt6d ; 20171122 ; subDT >									
//	        < 9ST5gDC0SLvl5Z52p02C0dpsP9UUm9uCR6U8x79ez5xQqo5aX3g94ze7AuMr1ynX >									
//	        < 6Ky1xNwllf79nvHMhu3xytK3BXlM3Zr9jF45oMMX9KeoAv1q7kV075xyYvd967l9 >									
//	        < u =="0.000000000000000001" ; [ 000029171900646.000000000000000000 ; 000029181397037.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ADE0C9B0ADEF4737 >									
//	    < PI_YU_ROMA ; Line_2943 ; 6lE0RJsO5S9OV98wSRtxyW9ZCD4H4nxAfN6PCTo1C4UWZ2VbH ; 20171122 ; subDT >									
//	        < czGQTU0s2942WT91N02v0Ju6k408IYWE6M51hWn4F2c9sski74S24sbVtfcdiRjw >									
//	        < nkoON9C041z1i8Un2cGb8SMl9bK51JVAB29HAtILlyc4OuockAZ35Z48QAY9y8de >									
//	        < u =="0.000000000000000001" ; [ 000029181397037.000000000000000000 ; 000029190861071.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ADEF4737ADFDB81B >									
//	    < PI_YU_ROMA ; Line_2944 ; HZx9z41U0js37L7a6G11YcwZ09mU7HyCakLcv40Q0iB48xrim ; 20171122 ; subDT >									
//	        < 7RCbiW8msJK815Zr8CErQ3o4l60L4d66kEWGh95cEbAJX6q6pAz5DYqftv7z2K9i >									
//	        < 7ysbbI0tQeD47b054C93bpK8IMKI23T6XXc26LWuEbT8n76JfIlskaQEkS92hpL3 >									
//	        < u =="0.000000000000000001" ; [ 000029190861071.000000000000000000 ; 000029200867519.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ADFDB81BAE0CFCDF >									
//	    < PI_YU_ROMA ; Line_2945 ; 08o5V7O21njOZ4xYAmh4dR0oMT3Aj77e3p0n79gX7pe6iiwPO ; 20171122 ; subDT >									
//	        < uFO5S21y8JFnc6aySCUB5QcKL6Cf8GM9aLg3B1w6ZP2R44Ssu2ME0yJz1ho6Wa28 >									
//	        < kQX0Czm72ruyHj3XmPF5zx3VR06e0VW9TYCI50aLIGTOwT1Bk8E583LRRi55ElT0 >									
//	        < u =="0.000000000000000001" ; [ 000029200867519.000000000000000000 ; 000029210840532.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE0CFCDFAE1C3495 >									
//	    < PI_YU_ROMA ; Line_2946 ; v8D8RdGUk7jkRcD64ET8Nr1pQQOyS6E8PCWvW9ddfDw83YCu2 ; 20171122 ; subDT >									
//	        < 1RZ38ckI4953prjl8xN7jWDL28866yAEz7hCnemdNFMnNI8n5u7edN28n0N8eQ0E >									
//	        < goVnq6c3WzmUOeWR82h3i97Xd23Ih24Y8tO2r872L5Fu070Tyd1wtuBma8g0971I >									
//	        < u =="0.000000000000000001" ; [ 000029210840532.000000000000000000 ; 000029218921615.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE1C3495AE288941 >									
//	    < PI_YU_ROMA ; Line_2947 ; PWd3GdlaLyc1W1bv1xHD2jPnT36F58oOR15wlgsOMN5DskL6s ; 20171122 ; subDT >									
//	        < AWVr26LZJd299OOomMY5sDpgALpYwYs8i6J9UjU61cK6lL01Po8ni1XVbrPOgTow >									
//	        < gPjFkEkzZOE5TQ16gT2JE9IauJ4Uh6sWOclY80q0DX98nv3VwAwz2Es5YSxGdB84 >									
//	        < u =="0.000000000000000001" ; [ 000029218921615.000000000000000000 ; 000029231291701.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE288941AE3B6952 >									
//	    < PI_YU_ROMA ; Line_2948 ; 048P1eCr3013rnTDWm4c83lrSB95OR1V8Tf0y9P4K25faa5Hp ; 20171122 ; subDT >									
//	        < Os65OsKz2HTH31Fkk0X4jq1RZn921897dfHGsz1VQ473y5247pf1d7E2Gj7mfldF >									
//	        < b33757X53CM9i0Vr30BS82Yi4AD354CkCNZQU0665e02cDSxcb8cwvYgR0T7ufzJ >									
//	        < u =="0.000000000000000001" ; [ 000029231291701.000000000000000000 ; 000029244328117.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE3B6952AE4F4DAB >									
//	    < PI_YU_ROMA ; Line_2949 ; SNseqxfbj0nE1tzOFQ513OqJtk999xxY1u3p8INiSDKxG13UK ; 20171122 ; subDT >									
//	        < VFa0KIPs7joan3UX9QfpAl5t94Rx277dILYlcg96ir39g3n4CHcDB50fvMxpdWtm >									
//	        < l0BFnn38QnkD228bt3BqyhP26wQUR0AURpTuiH1wCL90S5L5hO9bSQ4eVMb0k8F3 >									
//	        < u =="0.000000000000000001" ; [ 000029244328117.000000000000000000 ; 000029251176077.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE4F4DABAE59C0A7 >									
//	    < PI_YU_ROMA ; Line_2950 ; 0tnUnuy78d2aW3VaA49yxxVmgJ0ozDI2LoUpor506bPJ9M4j7 ; 20171122 ; subDT >									
//	        < k889I2tRh3yI8741AIRbGsa4G988LJOMfLjzWXaor8XeX7zFX52kT5iY77YIGDGZ >									
//	        < 5l6ghxx9N6OIR2XAZ7J1hP5Mu0oMndkjH4xhjES36Sp2M31t51QEo186fUw2Nt7L >									
//	        < u =="0.000000000000000001" ; [ 000029251176077.000000000000000000 ; 000029263281141.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE59C0A7AE6C3932 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2951 à 2960									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2951 ; Zvu4FL5h4VE0ZhQZd7FMR7VdMqS4PAos98U0y2E8O9qhM75OU ; 20171122 ; subDT >									
//	        < 27j7026G1QthcK5e621W8V6WE73908b2CcrcUY96jP86gM72r1E78o1600zCO9p9 >									
//	        < zV3S01LJ7Kg2Hx06inBV4TYME2d0er2Cjw6Ph05Gg2NmP6v3g4mMza1dlPDDF652 >									
//	        < u =="0.000000000000000001" ; [ 000029263281141.000000000000000000 ; 000029271344173.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE6C3932AE7886D1 >									
//	    < PI_YU_ROMA ; Line_2952 ; 891PAD5Q9N5X0Mm0odOVV3zZdT4SF0H3t0KGyhyPx69b4vLy7 ; 20171122 ; subDT >									
//	        < J1EboNA39C9om9nf5jK69r8v4ydP0wn2ILxCuOMT279D2b67BPrlBa7ltfc9gnJ8 >									
//	        < ewI1Qkjpn3ZCY9ju48gNkzJj0RjOfCLEd6J212q1e1bLuADVoeaJL4A7Ae8XJm24 >									
//	        < u =="0.000000000000000001" ; [ 000029271344173.000000000000000000 ; 000029283625287.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE7886D1AE8B4420 >									
//	    < PI_YU_ROMA ; Line_2953 ; TEr4Q89j20kp4014VLVAeLhqFDC480U34YGq3TpY8PUZDdBw9 ; 20171122 ; subDT >									
//	        < 077TXy8SNR6v07pM46KF01Y7QBt6AMMt76Y4Lrz0hhq108tPm1K8IXS8Vlv107Pn >									
//	        < WPxU6o9odn50l7j1VtgCum8tbuJ9w67QkES0mwD4Ki1artJUb7PoJ8K9tPoYPk29 >									
//	        < u =="0.000000000000000001" ; [ 000029283625287.000000000000000000 ; 000029289899047.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE8B4420AE94D6D0 >									
//	    < PI_YU_ROMA ; Line_2954 ; 6D3LaLsHl9417Q50PGF5jf4aqFW1Rl32smF0E1rwu0X3DYWWI ; 20171122 ; subDT >									
//	        < y522usY38q8spTh9qO1byfzb7MFwYpst16bpYYBh00KR4QUertHJ32x6GLV51y36 >									
//	        < 0J1wZVTM1TPq6R88H6GIwL50ef75lN40R80W5wYyOwbDJZ5ZdZXYh152hLmdCunj >									
//	        < u =="0.000000000000000001" ; [ 000029289899047.000000000000000000 ; 000029302859476.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AE94D6D0AEA89D7B >									
//	    < PI_YU_ROMA ; Line_2955 ; Epu541V5Vjs7sYoR9dL736wc8btwVA6v6N5wUGZzE372j57of ; 20171122 ; subDT >									
//	        < 8M6grIR3xTL4VIrQf5v8d8X8Ds2PSM54QPr55Z5T68LgWZBvL3qaRqV6f6NoSTyf >									
//	        < 3J4xX9Dt7xYY80n8KgrX4mCd38MQ9164kdN53vZUoK59w205TVhkuZYlz9xsOq7d >									
//	        < u =="0.000000000000000001" ; [ 000029302859476.000000000000000000 ; 000029308747254.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AEA89D7BAEB19965 >									
//	    < PI_YU_ROMA ; Line_2956 ; QP0H874FaCfVrhM5B8wz6Ae01oa5696M307gJ0j5enL4582H8 ; 20171122 ; subDT >									
//	        < lMS547LnANyDng6sr3w9348U6RSf3bDCNC2HYs5NcW1H2X5MnyWpaOA7I32MNI7Y >									
//	        < Doo52qKU6dKwmpzp04m2wOnwyn0NEv218sy3H2N2nVL9b9T4o7tvS2ykbSXlzD01 >									
//	        < u =="0.000000000000000001" ; [ 000029308747254.000000000000000000 ; 000029319214191.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AEB19965AEC1920B >									
//	    < PI_YU_ROMA ; Line_2957 ; Hc9K9uy2yFVfuvR9fM75MXN3JHueo4IGk02Pkg62Q852jh9UO ; 20171122 ; subDT >									
//	        < 6HPn8CGf62m73QVO6j1KY10g23tzem2eX2HFT6mv5b0E98405NN3XkawMps056Uj >									
//	        < OSqvQB3YoPSXBng36rjF1QXP50N5H5LL8DIded5o53QNFzK4w6tsT0c67NVFOOGs >									
//	        < u =="0.000000000000000001" ; [ 000029319214191.000000000000000000 ; 000029333454560.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AEC1920BAED74CB0 >									
//	    < PI_YU_ROMA ; Line_2958 ; c6Vp7Y9T1DZzJJN1zb480e59ehIKNCPJ1Lmf0wVef6hCD79aJ ; 20171122 ; subDT >									
//	        < wC7ITh9dn2R73rAD077i9zHsr68cFJ7j6LRMFBb7p5C24t7oTa3ym4OoM79d9zF5 >									
//	        < ruIOabr7W2P4JxJ13X6wvTp9oSpi9W407C1ECd6evVK38x5Znxbp2rqnqWs1P9Xk >									
//	        < u =="0.000000000000000001" ; [ 000029333454560.000000000000000000 ; 000029341698446.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AED74CB0AEE3E0F4 >									
//	    < PI_YU_ROMA ; Line_2959 ; YA8kh9lHHq490Lg47eFmmjH2H89w7qTIz458FcZLo2p8nK1PR ; 20171122 ; subDT >									
//	        < iL522D0w3VKL88r4lVk0Sc3Xt7m9A7M4nIbS6SyK1deQVmCv3X2OyrEVRS47d7eR >									
//	        < W52Xwjm9IOCg1t8n866yAf8V4M0Es4S1z304m1Y8q5btQ0gp0MceAZQAwg2M8P6X >									
//	        < u =="0.000000000000000001" ; [ 000029341698446.000000000000000000 ; 000029356087617.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AEE3E0F4AEF9D5B9 >									
//	    < PI_YU_ROMA ; Line_2960 ; I401X1rmW422FUgzB8hPUYee4GBG4a1vLHB26HLDtSA1QS1uK ; 20171122 ; subDT >									
//	        < xLks84vhW0vcrAZ865jKoy6Md9t54x2CYkwamViYU7t1787f60Jy2J91TA0KMb7t >									
//	        < rrio39l0vzuoYQSd0k0txviU9pGDV5FQMf43KW94Jd26720EB93rKNEi671Zs3lU >									
//	        < u =="0.000000000000000001" ; [ 000029356087617.000000000000000000 ; 000029367070929.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AEF9D5B9AF0A9814 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2961 à 2970									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2961 ; nO7BCFKZGP5LKDQOzrRh8X0Sj648grF9aTAY5J56quygn1k3s ; 20171122 ; subDT >									
//	        < 63dKdKiu1vT0cqKqp4OgNhh47VstJrV52vTE0aZqruh6t72d821mcaDTv8P68q9o >									
//	        < UBp8A2HEO2it40k667n5DX01QmklzkI5x76D9G9jGYJexFKDQtIjTl85wYZ055Om >									
//	        < u =="0.000000000000000001" ; [ 000029367070929.000000000000000000 ; 000029376781607.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF0A9814AF196950 >									
//	    < PI_YU_ROMA ; Line_2962 ; VYhSpDOyxkqyVo3AHSXO52gv6uC3U5bXgg7K98dkG97YOi2KU ; 20171122 ; subDT >									
//	        < 8gbrF8X5hEMAz22vYeQBFcNfyXnIAlt1yMU6Xhso2R4DV9f37Mlkdv2wRQ71fUtV >									
//	        < pAs6hzrMF7V8JA2JAP0931nrM452447q5N740G82by79r3D5mtoDqYqn8nA65pWA >									
//	        < u =="0.000000000000000001" ; [ 000029376781607.000000000000000000 ; 000029390853555.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF196950AF2EE22B >									
//	    < PI_YU_ROMA ; Line_2963 ; 71ZCB2U1L5tyNb7AArSSOwJAmvmVT63e0GGc9gDTAQFu0omwP ; 20171122 ; subDT >									
//	        < EQ2L12TuePZa6HsI26eQ1N9W1HE73lhT651P2o9L80sixLFpf489NrSXZ7LBV02V >									
//	        < pgio7cF2avf3v8z66MQhyR59Bg2hVMjGe3ihCg4l9A596oFT9RCF7Ax84l831Rxk >									
//	        < u =="0.000000000000000001" ; [ 000029390853555.000000000000000000 ; 000029398318059.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF2EE22BAF3A45FD >									
//	    < PI_YU_ROMA ; Line_2964 ; 1qJ7m01n9Y4f0tpFb72Z71inFvhPE65gmp1pg0ht9VbAd0GfX ; 20171122 ; subDT >									
//	        < 0ifeKM34u72l9307n4qP9mvUH3303V56rph5Q2B7LZ0b53zH1mcLIkyRfv27YLdJ >									
//	        < xn0aR07tO3AoG124C7p47juDy8X5dsNw4uyoTqxh8qwI36rIi9q4PH9IyF2DH3XO >									
//	        < u =="0.000000000000000001" ; [ 000029398318059.000000000000000000 ; 000029407081125.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF3A45FDAF47A510 >									
//	    < PI_YU_ROMA ; Line_2965 ; i3ia55ChFdM536Vf10K0P90XXdImTENIB5XB3Y923nm2n2005 ; 20171122 ; subDT >									
//	        < a391tAlk30cYqWy975nf006X9W54QYDq8yj3ka2wT08V0wk2IYdd5YHkdWQawdH6 >									
//	        < 63S74T6dVVC8mHQZJs36NJCRONMFF6XlEoRfSov3xNsx7Fj6ZINxsxR6n6d8z93l >									
//	        < u =="0.000000000000000001" ; [ 000029407081125.000000000000000000 ; 000029413791329.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF47A510AF51E23C >									
//	    < PI_YU_ROMA ; Line_2966 ; j68H8t099YG05Ihi6k4Z2X4KAX0nLDG380BIb15SxvL2O6T2B ; 20171122 ; subDT >									
//	        < 2XdVI2Xz1118xMmhgcEeKvWpIhz8SC4ooa766KNDol8jpKc1W67TNKHF8qpyT3ji >									
//	        < if03679THT2OpiO7hExfCd99TR5V4mS6wFbDzoO64t485M3N8PXF9r9z8lEgl2yf >									
//	        < u =="0.000000000000000001" ; [ 000029413791329.000000000000000000 ; 000029422048126.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF51E23CAF5E7B8C >									
//	    < PI_YU_ROMA ; Line_2967 ; ihdPr15IroaY832bRzNzfJ5xsdd23lOKpZUX29Y7zy96g51JR ; 20171122 ; subDT >									
//	        < Sjbt4nIUGce8c9WL7X59BydPU0r8A682SP1SWSU1jxbyi7KPw1exGVVci25tITCz >									
//	        < J6C15X2v9Iy49u0wlJuYaGdHx3LJ1Eub7J4u1a9H8BMFjdj7soK6X2H8Xe916VjP >									
//	        < u =="0.000000000000000001" ; [ 000029422048126.000000000000000000 ; 000029429829917.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF5E7B8CAF6A5B4F >									
//	    < PI_YU_ROMA ; Line_2968 ; O3esgsd7KOsC8BX7LWANyJnb77M6f0d98f0WbXriL6z584t4k ; 20171122 ; subDT >									
//	        < 6Y6m8PP18IZ45oF3kXTISRGEhC6317Hv8CpI8OefbSCo3Q6D501o3yhLBhAw19mY >									
//	        < 5T3r4KWs9D3BedQ0V4R6yJbbDtzCC1z57116pk5hsp530J0Kqfh863Md3iLQCPYV >									
//	        < u =="0.000000000000000001" ; [ 000029429829917.000000000000000000 ; 000029437886929.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF6A5B4FAF76A694 >									
//	    < PI_YU_ROMA ; Line_2969 ; R8oB95YBI1z8yLHy4y3V3E4GexW8Ea83Y090an0kRm1ZTm30S ; 20171122 ; subDT >									
//	        < ILy9P660ClwY01FHDR4F2b0erf3lqe4LL7qOpG7N8C497ZHCDYt0H2K0WmE8erta >									
//	        < K6SV1j7989P75QA4r9SDV9ht2G31ab85zI9z9igFXDw4tm78d2Sok0l67XwsgOPT >									
//	        < u =="0.000000000000000001" ; [ 000029437886929.000000000000000000 ; 000029448375866.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF76A694AF86A7D2 >									
//	    < PI_YU_ROMA ; Line_2970 ; bxFxbey3F93KT69N4814qUP8IrOZPIfI2H3iKiDQVtbfjGJ13 ; 20171122 ; subDT >									
//	        < vroV2f3XvMGsFtOzN5jS3ANh12aQsxwX2MVeNhJoc1tMYOZ93BbQ9nxqC3eNTffY >									
//	        < B1q0c04p9BgsqJ6ip6Wgk6127WmmJ1HspxxuL3UzD2PY2r1D64vAZaZD79ER5U7O >									
//	        < u =="0.000000000000000001" ; [ 000029448375866.000000000000000000 ; 000029455380235.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF86A7D2AF9157E7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2971 à 2980									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2971 ; 8aW9323ZeFNhmALEvhETvzGm1680Dy22R62ToSPj5E4BhY7I2 ; 20171122 ; subDT >									
//	        < 2Ynao03kCdTf4QSEy71e4bU0vK6c3Tc818QZZR8LRxY0H57Iz1Ne4h767isofe6K >									
//	        < eEVa9fIY1TayTE8zY5v519HWXDLLu7qfmRdbAHe0e36FYX4bIQ509aLd5ddAZD99 >									
//	        < u =="0.000000000000000001" ; [ 000029455380235.000000000000000000 ; 000029464055682.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF9157E7AF9E94C0 >									
//	    < PI_YU_ROMA ; Line_2972 ; 3P9oI3Q7Db82aOrh33SvzL2ND66V9u2ondy4Z61t3Fv1JKnZV ; 20171122 ; subDT >									
//	        < tA6tATzfLxrfhu84HhgXB7Lo9Rkr48kIw0lTdbZ7t6BouG5qJH81ilrBuk862aEF >									
//	        < 43HR1I44AAtvrrwayYUG3haBm7oaleh18rfyDdb73TNV539zUx4MN3dApVV99m2H >									
//	        < u =="0.000000000000000001" ; [ 000029464055682.000000000000000000 ; 000029470257966.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AF9E94C0AFA80B84 >									
//	    < PI_YU_ROMA ; Line_2973 ; u32R9fg9pX54UR5GHnBW6T2oMt1vBkqV0QuTtUyvzkx2IHD5v ; 20171122 ; subDT >									
//	        < zbEJL2mX3omCIK6E13CIe73PqV07q1tQwiirO42EmK30pNLRJ3nS06C9SvPet3lK >									
//	        < aw8IxCB5v7JvV5x1P2W5jKf0f686Fc4321F2vS924kTmNO5L4j6X5GG1UzHO444f >									
//	        < u =="0.000000000000000001" ; [ 000029470257966.000000000000000000 ; 000029479328473.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AFA80B84AFB5E2AF >									
//	    < PI_YU_ROMA ; Line_2974 ; DUta24xfVwlQvym7688soJU1sg99DjictVNUKV0bRc12vWKOx ; 20171122 ; subDT >									
//	        < MkyS18aoAbhb990mqO6a5us2SHdEIv2f4kr3qJ2oDHmWGtzZlE4E82g9WWQ79v3t >									
//	        < e4y93YMKsFULmfn63myG0gKg6kGj1iO49fj24uX7rBas9F7LV78015VD6K07p58M >									
//	        < u =="0.000000000000000001" ; [ 000029479328473.000000000000000000 ; 000029492655181.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AFB5E2AFAFCA386E >									
//	    < PI_YU_ROMA ; Line_2975 ; KBv7V3v19s1b5g52axa12M6XuzKoPev2uPY9REl9qRxv8UZo6 ; 20171122 ; subDT >									
//	        < X1eMd7D430u99D6keaD2EV2uSy1nlB64eac14AH6le3mRh182BgrVcCzWC81582j >									
//	        < GM04E5W1s7FcA0coMPMJZRgd82ioXL97E461Ay4HitXfx54DJ5Q550OK1sncZDvf >									
//	        < u =="0.000000000000000001" ; [ 000029492655181.000000000000000000 ; 000029504258985.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AFCA386EAFDBED2A >									
//	    < PI_YU_ROMA ; Line_2976 ; NGQ0lBRPWfy6E7T2f9Cjze63J1q2Fy4AjCIRwOPxkzGP5I6VK ; 20171122 ; subDT >									
//	        < 495PMX382VgIE02NpW7FAb9NY79c0GCZV6SkfzdNQPz66fVefCd6VkwW4xlXCjX4 >									
//	        < CO5Rabk5C1amnH2NBj2eoI29VZWIcNM26uEGky546M9581Vl86BLPSDzRo4P9PMV >									
//	        < u =="0.000000000000000001" ; [ 000029504258985.000000000000000000 ; 000029518759409.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AFDBED2AAFF20D64 >									
//	    < PI_YU_ROMA ; Line_2977 ; 4BT0JIaZBpXw2Y9TocuAeUP729hmMN7hn4GeHSOkR7W7k4YRh ; 20171122 ; subDT >									
//	        < P5MFq7rTih16u83kR7UXgawdDWCiqCeTi6ltgIVxC8BFKL0tdMHPAffRv1S25Yhn >									
//	        < eg9c645vqGP9gqAB0lf21F3g0II6MfbV6EVO8gUKjYB6kRn1s89paI6060tpk695 >									
//	        < u =="0.000000000000000001" ; [ 000029518759409.000000000000000000 ; 000029527986714.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000AFF20D64B00021CF >									
//	    < PI_YU_ROMA ; Line_2978 ; 5pqt86nq992LDJGxIrfL56b6Y4T667x9919g01ulxFQbJ2X99 ; 20171122 ; subDT >									
//	        < 0Jvj9PU9635Jh3nli4Y6Huwe1kQ596C80KYnES6mz4hlfeGtxVf4xPs40m71StSO >									
//	        < 2lhfqO2245Q2Be5S8aeQ5p9djdvE80vZ04gKbe38A3035IgZ4oM9484zQzpRP5Z6 >									
//	        < u =="0.000000000000000001" ; [ 000029527986714.000000000000000000 ; 000029535901923.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B00021CFB00C35B0 >									
//	    < PI_YU_ROMA ; Line_2979 ; o27oN9ruSPL17MXq6k4EY3DotHAB6GbTX9Ov9hTd8c0Fq5aNK ; 20171122 ; subDT >									
//	        < 9R527B9558jwyrAR0iM7e55ku44FJ5IOE25aljbPKSChRAY1VWS3C9ln9v1N59D2 >									
//	        < GoGL6yH890czM6GU0FfnZflS9Bz1y6x7nai7q55kh7K35Hhu9Nm0430Wl81uj0B7 >									
//	        < u =="0.000000000000000001" ; [ 000029535901923.000000000000000000 ; 000029547992063.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B00C35B0B01EA866 >									
//	    < PI_YU_ROMA ; Line_2980 ; 9HD7gP6XDITzeD3N3ziPHCUdMnR9sm5A4uU7GVCZqxyvl64uW ; 20171122 ; subDT >									
//	        < bY1VM3c3OaLB5c5xwuu0d6qbchdk2YJR1KW38BTPrPC9s59Y3T4I2rDZL2k860T1 >									
//	        < 9xvh3U7TZCqedHE85RL9R7G417CA1TEi7bv87S29iNeP73m7EvStAz0g4zA7xI3R >									
//	        < u =="0.000000000000000001" ; [ 000029547992063.000000000000000000 ; 000029559047166.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B01EA866B02F86CC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2981 à 2990									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2981 ; oA1UwBL5c7MZn5QUreI3N9D2136s9vd4MzvvBYQ5Hw5s5ql24 ; 20171122 ; subDT >									
//	        < sGU54513DIezGExj3rru11XM1FXkNzad3mfHL3pXY90YmR326HNs2os0E82ADu6U >									
//	        < C7Kwu1jBY5k65t54jq7n7PHaPI40S0Umvl5co5526N189BOc9Tcjl4oyfbD8l7nX >									
//	        < u =="0.000000000000000001" ; [ 000029559047166.000000000000000000 ; 000029565435689.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B02F86CCB0394650 >									
//	    < PI_YU_ROMA ; Line_2982 ; sFsRC0e2EG0JkHdDydb5ZB5Y41qs7794CEv0Q3lR0tl9x8VgW ; 20171122 ; subDT >									
//	        < lza1i47m4g3xl7429k4YSgYM1xjufe2t1QOYv4660yrS3ziI9OA941BMrHPT081C >									
//	        < 72TL6KPcJu3SHS9dkk6Mp4D5q5D3L969zvl1DhPzunn74KEJ17846JGACOyKVbuX >									
//	        < u =="0.000000000000000001" ; [ 000029565435689.000000000000000000 ; 000029571319743.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0394650B04240C6 >									
//	    < PI_YU_ROMA ; Line_2983 ; BiQ8tH7VZZl78J37F3BnIg70XUz4pM301UJ86lkB149x019E7 ; 20171122 ; subDT >									
//	        < 5V58G28T8N65pcQohPr4JlJ15aOO6QWQz2Ma4pG7hyXoyXdq027sCLE2g2u8Q98n >									
//	        < Z32N1pIRoFPj9fqT8516F6nrRk0Crht3RR0VUH5rcM3H7KXwOqYUpHSe0DPaH2cU >									
//	        < u =="0.000000000000000001" ; [ 000029571319743.000000000000000000 ; 000029580007641.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B04240C6B04F827C >									
//	    < PI_YU_ROMA ; Line_2984 ; 6p9GEcTItS31m6Vupm8m7tGhHsy03454tdvFhK7VX6z07Qo87 ; 20171122 ; subDT >									
//	        < 1Mk062S0h35Z2ogFs19fjglPyfxwj9q0FjGir4m4K3Bs826147Sd3j6uw38642Zp >									
//	        < SL9U8Sc58OsD9E99VQ9aaH9edSFAxnekKYMOv8Wwi3x7Bs47E3q07V3hjt7s089w >									
//	        < u =="0.000000000000000001" ; [ 000029580007641.000000000000000000 ; 000029585282429.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B04F827CB0578EF2 >									
//	    < PI_YU_ROMA ; Line_2985 ; QAZ2cEOG6C8i58KaB78vAob4MuJWIkvVskr6vhY9JzhuN962m ; 20171122 ; subDT >									
//	        < XZrbZ9PKaCev8QPM5OXpv8Gmz6653mhvIq0suOmZv44BW8WlILCOX04958m7mwMQ >									
//	        < sM6kq3JCA99yL6bge20O2cU645hlu3VrCJ6395KiQ9FsWt4235C5KPCTS4UNM607 >									
//	        < u =="0.000000000000000001" ; [ 000029585282429.000000000000000000 ; 000029595492562.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0578EF2B0672348 >									
//	    < PI_YU_ROMA ; Line_2986 ; 0zz2Ys8f0UNIYaJNIQbyiUGvSxOqz2Vga2qw20F6Eb8fd1DqV ; 20171122 ; subDT >									
//	        < 45ib3UlgbYltxT87oQwWojV1S0z0ADpkIX35lPz3pAd0y001i4VYSSUC6r7xE6s8 >									
//	        < 55P3ADg3kzSL3x62EesFa1sEml4sX5C4OCXf5pBE4k438siqJVvlH1qe6B3B817z >									
//	        < u =="0.000000000000000001" ; [ 000029595492562.000000000000000000 ; 000029607843869.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0672348B079FC02 >									
//	    < PI_YU_ROMA ; Line_2987 ; 331GS8jx2t66DGR6vQ45e6K3lHZw3b533XD8e3d6LpS4bRPq5 ; 20171122 ; subDT >									
//	        < tAaB54qnTcg8C8mxIqa9PL6G61h28wI84S1CkP7y8COSgrh2Z1v7LXkKZjO0Oy03 >									
//	        < Lb8RX5zhzb6y730yLLN9fmM6MP3E1WDi29sv2GbN6d0X4Dn1VznOh6a87Eu2dX7O >									
//	        < u =="0.000000000000000001" ; [ 000029607843869.000000000000000000 ; 000029617981447.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B079FC02B0897400 >									
//	    < PI_YU_ROMA ; Line_2988 ; 55QKk0hr3N5e4LzxiwJQUmxznObXVg445x6oB6ksbr9BQHa19 ; 20171122 ; subDT >									
//	        < J4P3O17rcxlCIzlPFS1X4kTR0lg9wlXV57j8xy5uz03vncLI8iD86zi40ceIs0MY >									
//	        < J22xqw9f19RF1fCZE2T47640AE17EFGTzJExZ1gWu960l0piB9f98hxza8ebR7z2 >									
//	        < u =="0.000000000000000001" ; [ 000029617981447.000000000000000000 ; 000029625052016.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0897400B0943DF1 >									
//	    < PI_YU_ROMA ; Line_2989 ; K5vIB8x3rjoKm3nTV81p5ZK4FMCUPO5g52l75e5acmvvE2gum ; 20171122 ; subDT >									
//	        < Lw11QIxNM57jrF2e7k39o79g0H3k7W05rAR64z67tc6jN3X7S5q5YbTMbZVDLByI >									
//	        < upSH8uzDbIq2N52GW4svgnu022Gp13oMWB9m0Eoh4eala8y25J4877rmkkn6EHXh >									
//	        < u =="0.000000000000000001" ; [ 000029625052016.000000000000000000 ; 000029634713067.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0943DF1B0A2FBCA >									
//	    < PI_YU_ROMA ; Line_2990 ; pbMCL9aHcFwgL268xdzzQ14EI7k0oeOOGX0401I90KqPX340r ; 20171122 ; subDT >									
//	        < 5Zn48XkeDY7un9uBzSWnhe5n2uzzNJRU2LYF4Riql1c6AP09PFshAkIo72232I3l >									
//	        < C2lf7iQd6aMGBHD1INF617PDA4xS435W5vIJO1429vs9OoKoy3ILL8G7mN0O3AC9 >									
//	        < u =="0.000000000000000001" ; [ 000029634713067.000000000000000000 ; 000029639879807.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0A2FBCAB0AADE0C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 2991 à 3000									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_2991 ; CD5Dck6h2LDOQXsi296X23p658m0UI377L4YFI2gW9yo4qAHC ; 20171122 ; subDT >									
//	        < La1NrEIZ2e6W01K4M0XUumI5844vB6hC693Fb7JnegdDs0w6H2FH9mnbRnBBeX95 >									
//	        < 9aKplFEDa9k3qvfhE7Dx0y5DS0hP1iczB9hiWR81aS4xqoDidgoI9L10OuxvZvHs >									
//	        < u =="0.000000000000000001" ; [ 000029639879807.000000000000000000 ; 000029648630608.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0AADE0CB0B83854 >									
//	    < PI_YU_ROMA ; Line_2992 ; 5L0c0VA9J87Qe7vjQ0i67Pd6o141brS0OogJ1b0y0K445k7Q1 ; 20171122 ; subDT >									
//	        < pI1KD8fb912S4kI7uE0lon2cq4jA8f1P503w2en9yZJ0mHBFrC1d7G4r4eVIVEfM >									
//	        < 53vHfkREXefm11mu6h7Wo3o5w521v93W2M16cUoh2zY7P4O541Bslq43iY4pus0m >									
//	        < u =="0.000000000000000001" ; [ 000029648630608.000000000000000000 ; 000029661535985.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0B83854B0CBE97E >									
//	    < PI_YU_ROMA ; Line_2993 ; vR379N5BfaN91I149gf3Y3P3CjvV7XzpOw56XB2L5H62z3H51 ; 20171122 ; subDT >									
//	        < 76OhS90QupCaPQVFHLzdl2tU96d1VSPrz91d48p85Tn72Y2iewo2tqUAfkk10pHS >									
//	        < Oe1S3M5A3R94b92xTQc8MwF9QHukS3W4log941FYBXKCW1AR8TtZ151jKXYITOy8 >									
//	        < u =="0.000000000000000001" ; [ 000029661535985.000000000000000000 ; 000029670724010.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0CBE97EB0D9EE91 >									
//	    < PI_YU_ROMA ; Line_2994 ; r6Yo5Jep3TOwp85qEAGB70efeKcaOHnLH0b1KzzZW7l6ji8i5 ; 20171122 ; subDT >									
//	        < 5Y4IrK8EZjbmgnRwJsAiRI1ygwsTA5lJV6Js57RTLFk1Ck838F60Ze1FCllrfun3 >									
//	        < cWORVW325xD49i5foA7W0E78Yxi1N4bgHds3PM37AT60bqU7E53w9N4mJ85pRzwp >									
//	        < u =="0.000000000000000001" ; [ 000029670724010.000000000000000000 ; 000029676243932.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0D9EE91B0E25AC9 >									
//	    < PI_YU_ROMA ; Line_2995 ; 41ps5AfIf2ZG28ni3mkRd2Uyaf9UtLRzD2aF0mT4Ri3jCq3H0 ; 20171122 ; subDT >									
//	        < ZAT14sd7LmPw4VTiMk22TkNokJICdw5vhY65wewg6ixqeSk4tp06R3XlcC9YlqbZ >									
//	        < wkNOrV79hBT6S29TP31D7Cdu6HdaeU02l36v17n7VqFr2dCO2xhqze746J0A5yZ4 >									
//	        < u =="0.000000000000000001" ; [ 000029676243932.000000000000000000 ; 000029685324729.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0E25AC9B0F035F8 >									
//	    < PI_YU_ROMA ; Line_2996 ; 4k4t9WxLpz0d54DkdSY33Ms2YOIqshP2L3aEre2AmhwXn1j6Z ; 20171122 ; subDT >									
//	        < 8LxMaS75TiJSyynbdTlI4r7hQKe439A9d80426T4WjQ0LOc2lX7t2NyqgkEFdNaw >									
//	        < 3lMtkR9K0shnTCxt32i5BdNGZeR5hdP71L9Z552uMmSZVQkNKTaXL6h11a9eLFo7 >									
//	        < u =="0.000000000000000001" ; [ 000029685324729.000000000000000000 ; 000029696432480.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B0F035F8B10128F0 >									
//	    < PI_YU_ROMA ; Line_2997 ; 6jhPgb38jOsKi5V4m5wKLENG13m0ljYg5keNf1W5gc730JhSm ; 20171122 ; subDT >									
//	        < 83oURmswZ1sgaHr9zgbfpE4Zo317W7HO4jL6yrG8Y2Ipy66K74cy67UC64L8r1V2 >									
//	        < VPJAVIx9rv3kd1Z7hdIe4Ia4Qb0E4Uu5V63cqq4ya6tf3qf951a2428G88NQCUz2 >									
//	        < u =="0.000000000000000001" ; [ 000029696432480.000000000000000000 ; 000029702444533.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B10128F0B10A5565 >									
//	    < PI_YU_ROMA ; Line_2998 ; Qcg1vXR3a771F2C7h12o2QCH3Abvr4T4y1dtl7DKUl7E6bwUb ; 20171122 ; subDT >									
//	        < WRhh2x08XNkpwYV0Q6ioLVNdSc56HxkUd5Bumr2y8Yk0y8797nect69G79i2s90v >									
//	        < K1PByFeJNZzaav7UgUPH5t53gjAP2Vf24xZEXLYdiM7e7DfaP7P987qRi3TU8G0h >									
//	        < u =="0.000000000000000001" ; [ 000029702444533.000000000000000000 ; 000029709207259.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B10A5565B114A715 >									
//	    < PI_YU_ROMA ; Line_2999 ; TkJ9xkJrL8zT80Aw3q1BxTqE245aqrI2sB79023I1N8kj6mh1 ; 20171122 ; subDT >									
//	        < ZyWyxc78I9Uoi67o0h68WWJKV3Cc6ap938pM43Vs1wa83VYq633aG7tLa0AN91fY >									
//	        < yYVfd3qcf1291gyjX8y67W5S38DTCGCwsk0b4lUvQa8H8SC07x06NoLU5M148Zjv >									
//	        < u =="0.000000000000000001" ; [ 000029709207259.000000000000000000 ; 000029720712116.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B114A715B126352B >									
//	    < PI_YU_ROMA ; Line_3000 ; 0kztKbhxDJi29G47ay9818WHLC91anY8B0L6VV7J1o66M0E2Z ; 20171122 ; subDT >									
//	        < frT8250L3UnZ0Cx6s5Fur2FL4yheB4AXsPcsrVNsv7c8E8UJXF8aOJ0hxJzSVcf8 >									
//	        < 1rQ1IVjnd52396FzzgaOQ2bjj7S1F3on77856COmgohNTwz3PJ49QqrsiM52D121 >									
//	        < u =="0.000000000000000001" ; [ 000029720712116.000000000000000000 ; 000029728646391.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B126352BB132507F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3001 à 3010									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3001 ; SPuek7IRnIT595AF30nf80I3TvYDU33myM1phx0WzT6gDJEof ; 20171122 ; subDT >									
//	        < c2UmGyg22Hdl9y2KCjGX9DSGNziREZ6sN9z327beGt970XfXnNJtZ3D37b9hI6Y7 >									
//	        < 3g1VO8K21xZaNYCEP2P0UhEdS0tCewc8XSnMP2ummJ8of7dmWy0t2sOz8j5CMaTc >									
//	        < u =="0.000000000000000001" ; [ 000029728646391.000000000000000000 ; 000029735045656.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B132507FB13C1435 >									
//	    < PI_YU_ROMA ; Line_3002 ; dpzye1LquT6M0QC9IjU7eglmIwVhu66F8yXqUGfGT9XQrz93Q ; 20171122 ; subDT >									
//	        < 2tm29UYOd6S0i1c3pe36B9loX5E3PL3POJR09T1fEzCQiV3r4JzN09h5p5o63tM2 >									
//	        < CFR5h51ym9G5lCj6D18G7CNBTGQoRW49M36o06U3sq0QBR2Z38weAs461ZbIzTxJ >									
//	        < u =="0.000000000000000001" ; [ 000029735045656.000000000000000000 ; 000029745939914.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B13C1435B14CB3C7 >									
//	    < PI_YU_ROMA ; Line_3003 ; 444m54579t48aZU6AY4ki7Dv8j693ZyUl4VAgMg9xzELKzONx ; 20171122 ; subDT >									
//	        < MmW3vR51bI3V5737uNZ3p5c5Hcd76xRaQ4cg3uiL482gL5itG2991Se868I0ti1Z >									
//	        < Iqjer1PGnrZULgi8ZmtMti6VJe47jbRMS17f6ZxJVK12XR3PkDIk6C97QP6LmM0G >									
//	        < u =="0.000000000000000001" ; [ 000029745939914.000000000000000000 ; 000029758019239.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B14CB3C7B15F2243 >									
//	    < PI_YU_ROMA ; Line_3004 ; jQg9Tejjv5HWJHclAJy772aUVWqExc811c9Gg3CSWB0tQj2ec ; 20171122 ; subDT >									
//	        < W1M3UoyX86oRA9fI76mY409Gapun0H7Er40ZB3dpRbiKiA58rf98EoW9dZjIB0sk >									
//	        < 5PTsqMpkHF283YrSLHS88h4orhceHU4LqyGroWw246d0WroFT5rinBe2YoxIy1uk >									
//	        < u =="0.000000000000000001" ; [ 000029758019239.000000000000000000 ; 000029763271282.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B15F2243B16725D8 >									
//	    < PI_YU_ROMA ; Line_3005 ; X04LCIina2JR7BHKHFHVqF65gCIdD5ra9WL2A07MqKm4ty6sG ; 20171122 ; subDT >									
//	        < qI8w95MS521t3S88F3SD949n0AmLceC03r3VMtO2gXn03kmK6bE8eV8SjdBuvAZV >									
//	        < 915GTQA4FT9kf2Mc4zyEgP1r9eKbU0WZm4GzOyzH499C3c2bOLosV4gh524K81s4 >									
//	        < u =="0.000000000000000001" ; [ 000029763271282.000000000000000000 ; 000029775032638.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B16725D8B179181F >									
//	    < PI_YU_ROMA ; Line_3006 ; dcP5170A5Y6q06X0pISe5HP0rp69g0e9EL90J2r4gxK5065A6 ; 20171122 ; subDT >									
//	        < 8oEeJb12m6Vc8sxD1OZ2Od0UECPj9mR2190g45brE5Vur4382AWqr732b2lQ8K9K >									
//	        < 09cjfotKnSTqJ01LiTrIbd1jG4MuFRvuiQ0wQa66KM53X8c4SofSfVEMTb7LRWJH >									
//	        < u =="0.000000000000000001" ; [ 000029775032638.000000000000000000 ; 000029784565988.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B179181FB187A416 >									
//	    < PI_YU_ROMA ; Line_3007 ; WzeDH222Um4b8BIQ5xoS52Kjh7kY2K16JOm5e03ItVN97rF79 ; 20171122 ; subDT >									
//	        < 92pM62RWW1DaVyxj36Iq0sEqporGG8e6IJQ10w2382i66rJ2QF0X5lXQ7x147F1J >									
//	        < zFFZ4Be0h1OdU6IaOAH5N5a0bIvpp0b2666Xj2ff2kK1wtr1JY7p6z24aMGL6Rp6 >									
//	        < u =="0.000000000000000001" ; [ 000029784565988.000000000000000000 ; 000029793548874.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B187A416B1955907 >									
//	    < PI_YU_ROMA ; Line_3008 ; HprVkQ99AT7MYHN08NuW19iplkBOUU7K5UNj0d02GRpE1gFDI ; 20171122 ; subDT >									
//	        < oxyoDZggJOnYH1bDJn72eFK6hC30dn4ef1VHsY5l78U2w25D88SLrNffmuELhYRQ >									
//	        < UAjdTwF3qX65oEvH7R8LxbQl9Wd1z3bX3qHv4k5WhFClh5ukV1WxyBMcr6lQAXhc >									
//	        < u =="0.000000000000000001" ; [ 000029793548874.000000000000000000 ; 000029804249449.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1955907B1A5ACF0 >									
//	    < PI_YU_ROMA ; Line_3009 ; Wtj8yDKZ5kySP9Q6Su0Fl6G9K7o4pBdX76559e7o392fxny2c ; 20171122 ; subDT >									
//	        < Cqd23g0N1g5iiRMfA2Rp3yw590z28Nt3v4k6J9nBRf3Feg26zM11oO4Ialg5e028 >									
//	        < usma3209qW8kBsb45HDAlTSa0pzKfxvU3qA0b3j6x25bFkh783X0iD7Y2348BCa7 >									
//	        < u =="0.000000000000000001" ; [ 000029804249449.000000000000000000 ; 000029815728318.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1A5ACF0B1B730DF >									
//	    < PI_YU_ROMA ; Line_3010 ; AFNlH4syh2LON1Ffv2WEyScsc8fQ1sDY2P57ky34t96Hq33K0 ; 20171122 ; subDT >									
//	        < gd0kh1LOHwJO43yqwcqF9zgO6k5k821o8i4E79fhz3E2F0515Alc4X5at4XF8FnG >									
//	        < EJ6r40R4cM4MCw8cKyEC64T3kZ9vxLiX2ARUTVpO66kzrW6y4fFjLkU6p9ul9504 >									
//	        < u =="0.000000000000000001" ; [ 000029815728318.000000000000000000 ; 000029821000328.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1B730DFB1BF3C40 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3011 à 3020									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3011 ; 3bbPmZsV66G6fo9D8BsfU8Pekij719GTdTjsnIt3Uy7KUi1q8 ; 20171122 ; subDT >									
//	        < 4fOyY6or9lkm7hMC7UvMNy28gjVulHJUs6N63988txX6kBi7Sx6CqUf3rI1Qs146 >									
//	        < lpTF3AAi4909VBG0xZwpysOF6vIqB0Rj179ho1E7umV653PAlO2Z48dDnI5T6qfq >									
//	        < u =="0.000000000000000001" ; [ 000029821000328.000000000000000000 ; 000029833023033.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1BF3C40B1D1949F >									
//	    < PI_YU_ROMA ; Line_3012 ; 5a3WwM60ZMHlai698ZhJVt2cT3Cda2800t0ykLE9N1KZOn8tv ; 20171122 ; subDT >									
//	        < f6bkBl2p1WUJJ644RYaxQxHGhCvbKvsyS4rTo361mRmn3q8X751i8PAxY3iFk8Zx >									
//	        < D4N6D02yh5Ja3q3Al2UrZVwP3DFc8YAu5fm42T9v7BX06sc0WU72ckR4976UIPy7 >									
//	        < u =="0.000000000000000001" ; [ 000029833023033.000000000000000000 ; 000029840592652.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1D1949FB1DD2181 >									
//	    < PI_YU_ROMA ; Line_3013 ; W0lQ75wJPq4jN9Vs73mwXSOT273E2GQ7qRa95C4c7T488qbEF ; 20171122 ; subDT >									
//	        < V76q1Sckyk1Y28HJ3333ACN4P6F27bb2lLfOS1FI0X27om6pB8S3XnZ3Lg6M73q6 >									
//	        < 993zKcS01nG2x75Q8vbsT6C5zfyr9RWMZ5t4YXcEz2NiDKxDsd13yPi56I1T36lt >									
//	        < u =="0.000000000000000001" ; [ 000029840592652.000000000000000000 ; 000029853440740.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1DD2181B1F0BC4A >									
//	    < PI_YU_ROMA ; Line_3014 ; NixN59Y00g4hk8Dc5g3j6ufu2W0lC0ARWHBxSRV45C1FF0H4b ; 20171122 ; subDT >									
//	        < RbWOg2Na39eVO6cupyG0S8vC6FWCV1R1D7qRQaYR69erUIZoph2vA74593B4750E >									
//	        < 1T8nHAqis8jGOZTsJ355NjZAB2z4BXY3WDvC74bk6Qin1d324i39X3vf1Ml76X5u >									
//	        < u =="0.000000000000000001" ; [ 000029853440740.000000000000000000 ; 000029859737519.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1F0BC4AB1FA57F7 >									
//	    < PI_YU_ROMA ; Line_3015 ; U9Frr9Ej29y00568t7jh2yZnWVysL16DZG72h279QM30SkT7J ; 20171122 ; subDT >									
//	        < 68e307tjE0AS2gE0n23LI43Us41Ni7w002ehrDjb5xk76xpn2Hd085e1Z1kVS2h5 >									
//	        < 0nCp7M6j5bO2fIt6X6G6P9o59XMoo8px0UJ376Q08qIgnP5qRI02PkgmXZ1AqVKq >									
//	        < u =="0.000000000000000001" ; [ 000029859737519.000000000000000000 ; 000029867724622.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B1FA57F7B20687EE >									
//	    < PI_YU_ROMA ; Line_3016 ; r9563H0A1JQT2Xdbzg2HcHfYw469W94qkf7UfUx91qfaIXyKT ; 20171122 ; subDT >									
//	        < yNWGK81ZlP4q26xcIiWT5S87IoZfW4Zc907Dk97JJkKrbRJ9q4P180Ep3ws1Y7SB >									
//	        < EOw7y9g8TyZ5059Ega6kxLNh0vg4a8Qj5Qd2ET29BkCa4k7Ddyip8751idaFwF4B >									
//	        < u =="0.000000000000000001" ; [ 000029867724622.000000000000000000 ; 000029877176936.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B20687EEB214F43D >									
//	    < PI_YU_ROMA ; Line_3017 ; r8xpRw6E2x4Cj37KVRBY6TdAnRm1kwRzG1P6U7oxB4F3zL9gB ; 20171122 ; subDT >									
//	        < 6JnFS1J2K1Sdo1Z9KMroBvwc44X3PTO5408RiBcXnQ0D4M0WJb9K7yJcFe69Vb6S >									
//	        < Ff5dBIziZkFhv1407Zd3OLt3w04gu56v24RQqyzO8re6g11544cO44q56t8rL9Gw >									
//	        < u =="0.000000000000000001" ; [ 000029877176936.000000000000000000 ; 000029889743713.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B214F43DB2282123 >									
//	    < PI_YU_ROMA ; Line_3018 ; P61IcgB78jB6513MCHKQxp8OQDlB7Y8FO27qZO4l1J4c9ozhC ; 20171122 ; subDT >									
//	        < T1tzkBKz5v5iX140SG2zZ38u8I72S4X80o5gIRqjviLkMiy6S4aX6d0T6J741BiN >									
//	        < 5iK3652VCuF62o4Z6gTkA9Lmyb8esqxC02UYZEoK6PCj81781of8N9IjwrTU05Zo >									
//	        < u =="0.000000000000000001" ; [ 000029889743713.000000000000000000 ; 000029900301670.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2282123B2383D57 >									
//	    < PI_YU_ROMA ; Line_3019 ; Yy4nilV06f6s9bUs7EF6wrbkDe41Pci89EtQG4YZQSol50PxH ; 20171122 ; subDT >									
//	        < 7X0H5T2MMo44DBuV00A24ESxf4GoTQ4l26xN87bt313r1zUN3TcVVdw8mEKs18qs >									
//	        < 4sa9udiN402C4PhZd22C046jIuS42j0mQZnovsbiF4kj63J5vKks7Q24I85FX90v >									
//	        < u =="0.000000000000000001" ; [ 000029900301670.000000000000000000 ; 000029912477717.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2383D57B24AD19B >									
//	    < PI_YU_ROMA ; Line_3020 ; 1PRSz3Ml14X3F0t0krv78lK09L8NsRp8XdSUF9gU22dl5OOD1 ; 20171122 ; subDT >									
//	        < zuFFv881Yiu3mUZ6UYvw000E537P45h8IZi0g1MhhvTiyA0469s5Ht40CwSB1Zn4 >									
//	        < BBI8X21aBJQyYK8299i0or9fNY9Z1CjJXD2Vl2371hy657V715Co5qyi4yDh7lc9 >									
//	        < u =="0.000000000000000001" ; [ 000029912477717.000000000000000000 ; 000029918952286.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B24AD19BB254B2BC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3021 à 3030									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3021 ; P8K5Q3BI30DhP4wxZllf9jzC02h2CNdib8urOd6aPf3sSpv2P ; 20171122 ; subDT >									
//	        < 34e2OQtwWBrn7JEsj8SR0Gq5CBmh7BlGQzZJ40w0ME75tcJL8wej5DpY3PmqPHOl >									
//	        < U13Prvn8xs3E4umyYc7hH1AE1AA3n52nQI3E67lleP7c1h7f2WA2eR1Bi1mf1uNm >									
//	        < u =="0.000000000000000001" ; [ 000029918952286.000000000000000000 ; 000029929102716.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B254B2BCB2642FBF >									
//	    < PI_YU_ROMA ; Line_3022 ; o86Ec3Q1F14Nvw6589o1ZJDSNJo38X7D8mIj4zcKsjdO1E27z ; 20171122 ; subDT >									
//	        < Gl4EP6HCMn0WAi9O3o55fZrUU5ihD9D9lZkZ29jD9Olmkp2DQ10s6lAE74m99st9 >									
//	        < QfqfT3kSncbp1hmmK8tSN5z00K77GL4D06N79h80ovbDk54218Oc7lWD63zz3GeL >									
//	        < u =="0.000000000000000001" ; [ 000029929102716.000000000000000000 ; 000029941406464.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2642FBFB276F5E6 >									
//	    < PI_YU_ROMA ; Line_3023 ; 8711nE3DmEb2e3YT7f0VR1JKkNYuz6i7GyWqnAs1ZPXFm4W18 ; 20171122 ; subDT >									
//	        < uCPF1yNs2pU32tH76VB9C4Ob4N1NI9lLxbg97h7Lkl3B00uMB8kXs9nc49QzrH46 >									
//	        < KR6mgDQXarW8M7mx9G20kzvVq5M5Kd5932GZ1OP38qeccsV6zDbw004w92T3eqZ8 >									
//	        < u =="0.000000000000000001" ; [ 000029941406464.000000000000000000 ; 000029956190901.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B276F5E6B28D8512 >									
//	    < PI_YU_ROMA ; Line_3024 ; 98r2P88ooyLso79cNIYwr5Oo60j4P58g1d0rGx9eZG99JMGe9 ; 20171122 ; subDT >									
//	        < A8N0N50Q4JR2aMtKp08cEby0GS6F64aCzq8xecqbGJ236Yl0k137FX700xwkdjzN >									
//	        < A83zihV7gya7gp0Xgzu1Fkv3n3jER7B77Nn5EzlJLPPQ3UCh2O3qoWNr483ClnUL >									
//	        < u =="0.000000000000000001" ; [ 000029956190901.000000000000000000 ; 000029967658357.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B28D8512B29F048B >									
//	    < PI_YU_ROMA ; Line_3025 ; aygF4kDFw2nXwTnWVWDV07pFQorcQCmdFF5S8JXNk6BqsWhG9 ; 20171122 ; subDT >									
//	        < c8pxnPLfV61u7P4juxgRAaRnkFSEyIkF2c6xIW1538yt06SqlfHAQnpf75N5ZXQH >									
//	        < 7fbB9Q5838c6S840EIdvw4P7v0VSFK0y14U52dn2B2pDFOI0o3W5u1X9aJ9U3sZo >									
//	        < u =="0.000000000000000001" ; [ 000029967658357.000000000000000000 ; 000029973612995.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B29F048BB2A81A93 >									
//	    < PI_YU_ROMA ; Line_3026 ; dj9lN8Ck9dtt72hK2Bv30TDO21R4wLNKBf4dK7NOYkqy77ncx ; 20171122 ; subDT >									
//	        < d2TE6QnrUXvR7T1O7RRL7gxjBg01PObMJ733666v06CY1rl9I0Qh3FQ43IS27mK5 >									
//	        < 70I5PUSNumo5XHM1M32PCaz3aVB5FJQquD8C061uldK59oKSnxUWd7VH3lVei6gA >									
//	        < u =="0.000000000000000001" ; [ 000029973612995.000000000000000000 ; 000029981997395.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2A81A93B2B4E5BB >									
//	    < PI_YU_ROMA ; Line_3027 ; g9TY2XhgH5FNRR47qY5xRX97lfIeZv9468zV2G1K47lWW7T0j ; 20171122 ; subDT >									
//	        < h4XpLgs9eQ0n7oAy40vpZ1All82Bh4Ggs1N62y69aATcH5e0E53cnYUK7RyF2rPz >									
//	        < C8z0Bh9z3963r6u2E5Md8x7BaGK7l15eGztNlnj71D6fUuFf6ymUC91qooT9v208 >									
//	        < u =="0.000000000000000001" ; [ 000029981997395.000000000000000000 ; 000029991901242.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2B4E5BBB2C4026C >									
//	    < PI_YU_ROMA ; Line_3028 ; seO120JYEbOUO155h7x10BiOx1syrEE6eYk6wYVB7f8C3E7F2 ; 20171122 ; subDT >									
//	        < y7K924zUk57uimHb6UJk4b11lu7akrd65ZH4a0rP64r4b6r229vq0bR4B5dgL7Mn >									
//	        < AL92NCbcj3DyJ5dUL9cSR8aqErS9tA2o8v6o4fSx79BBmpLwaFi3gUC9rAg7Y2Oe >									
//	        < u =="0.000000000000000001" ; [ 000029991901242.000000000000000000 ; 000030004062731.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2C4026CB2D69101 >									
//	    < PI_YU_ROMA ; Line_3029 ; 98N7UYvkl5a0cj9ZE8Axf5amY46GFh3vduyZ925yIQOHqAj7Z ; 20171122 ; subDT >									
//	        < r8m6So5k3K7Ph5z289aNcdPGxaBSMr6moJnZ2KaGXp9PR0JIn5L4Bpc82E27HPiJ >									
//	        < XMLr3aW30D3kuoiS8L9BBQ3BVLkL2PU4DI199F682HAp8rHOG2feaX9tGY28lxWL >									
//	        < u =="0.000000000000000001" ; [ 000030004062731.000000000000000000 ; 000030016632133.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2D69101B2E9BEED >									
//	    < PI_YU_ROMA ; Line_3030 ; R8zhI1u8R8Z4DT9coVt597nFHgtYmlJfX88DsFB771EP5m4MN ; 20171122 ; subDT >									
//	        < y16h5FtvdbR308996430mc1jP0eV998Irl3cDIP84TwMcokxkCU7XPqh9lFwNVUC >									
//	        < Ro4TO4sC50q634yU51EQ443V84rtkcZp05GInBr15R6tGz3S7hmpRfvXKcUk1RIJ >									
//	        < u =="0.000000000000000001" ; [ 000030016632133.000000000000000000 ; 000030024146234.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2E9BEEDB2F5361F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3031 à 3040									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3031 ; 1ZhEV1Ub7u08m66wB2i4XwAAlR1Y6e30bZ5k90j01ufG9F36R ; 20171122 ; subDT >									
//	        < oOMVE9B3qhaz1im7jF777R9RdOAAm000L1Y3tGNsCct7RsM6e6WzR232r0kGX07d >									
//	        < bQ6a2K7CdnKwMvZ6Te9S20L4H8KNkhgZMYlU034T09GmMzxAoHHpQDDusY64O2g0 >									
//	        < u =="0.000000000000000001" ; [ 000030024146234.000000000000000000 ; 000030032154117.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B2F5361FB3016E33 >									
//	    < PI_YU_ROMA ; Line_3032 ; T04jMe4WUH7iE0M5Hj4OL0Wb9N5D1q73G95t958WB7Q9tDFdf ; 20171122 ; subDT >									
//	        < 3vvY38Hxe956j1WM1LP5Nz2T1w6lXAX8cr3lqk8LIAJG4jwRD9SO7C0igKY8Etlg >									
//	        < JuTSR74zBzKd45qBAPs36ybjP5VBae28El3mLx15t3ax3548ODBJ9oeD08koYXdv >									
//	        < u =="0.000000000000000001" ; [ 000030032154117.000000000000000000 ; 000030046794033.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3016E33B317C4EB >									
//	    < PI_YU_ROMA ; Line_3033 ; tE2uxrleE1roYRYsrGQG8pv0npYb744pOGM7w4EYV36cbt011 ; 20171122 ; subDT >									
//	        < UDHnydRRV6vIkT0k1fw57c5x3oEgq3lw7g98sk6Av7yJ1XNcWb8J66mhz50xDf8i >									
//	        < 428HOs6OpiV49q01SqJ078G1aPy865TH94m395LrtY5W08Ot7kZJ1L0t6lmrs774 >									
//	        < u =="0.000000000000000001" ; [ 000030046794033.000000000000000000 ; 000030061736662.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B317C4EBB32E91E2 >									
//	    < PI_YU_ROMA ; Line_3034 ; bt7Sz4k27z1oUf6UNZfyzLi9oQf16s3Wn9594C8M7M8MRZL68 ; 20171122 ; subDT >									
//	        < UR4v6VgvfpLJse8o4knSR87IX3272gc419HY0y95dmX06K5qjM9tchDGPs73R09M >									
//	        < 07Cy5a91Q3KAUh3a8ue7d4cE5YKP4Z237lwGHWg21j4834BS15sv0p62QpxcymnY >									
//	        < u =="0.000000000000000001" ; [ 000030061736662.000000000000000000 ; 000030071304066.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B32E91E2B33D2B26 >									
//	    < PI_YU_ROMA ; Line_3035 ; Q2T4U3LaXWyVcHwVXYZpmCS0k153H8XOk0RZMytYw48r2pkut ; 20171122 ; subDT >									
//	        < R8t6VcW110mW9g0N490EZ43flsG2kNf6404X5d31HgR7z5zBcUm3Wj66U7YXnWht >									
//	        < 6JJC9e6ITg0FM20z8uQlW41W18c62a7A8uj162fAu2L6RUwt2FIWmsi6QURIPK06 >									
//	        < u =="0.000000000000000001" ; [ 000030071304066.000000000000000000 ; 000030076587095.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B33D2B26B3453AD5 >									
//	    < PI_YU_ROMA ; Line_3036 ; oQMCK24G1F90Qr8do191bR9p1aEEtj51pu0tk2h9k638Z642S ; 20171122 ; subDT >									
//	        < 85GdmBIG0uuPVFSbe82H9G1j12y1D918PhP5301m4At2LUAQw6K2LCH0Nv1H65Dw >									
//	        < Gc0S0Sg4P52OGQd7o22l7Sl5dJ59m5O0UFT0sn7l1vzZBlkFqS1xWoEqAB9q7Y1r >									
//	        < u =="0.000000000000000001" ; [ 000030076587095.000000000000000000 ; 000030086347490.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3453AD5B3541F7D >									
//	    < PI_YU_ROMA ; Line_3037 ; 99n4K03cXWk6DbRDhDXp49C5DXP3j36qTpnXT9ijdr8gH8Mmp ; 20171122 ; subDT >									
//	        < UfM83g5jZZ1QH293o3fMv8yj2iMksq08wVn6699iDW56a2DuV551S2v2zSiM9l09 >									
//	        < 05P670Q31Hi0VRG9Ii8mEGe4uMl00BOtdb3kvL1sU4Y3sO5c128ucD4Wb92pYod7 >									
//	        < u =="0.000000000000000001" ; [ 000030086347490.000000000000000000 ; 000030093254405.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3541F7DB35EA980 >									
//	    < PI_YU_ROMA ; Line_3038 ; 1UT677kIBjd9YZ04DDCrLDwUM4TIu6910XT5529EXx9A58Xcg ; 20171122 ; subDT >									
//	        < LaEH49y9rxCNxCv3Q80bddng8xZgI8AfX1DsWmoA8848AjJwV5h41olx82Bbf34e >									
//	        < E2Ilv4QB98GCdcTbaf3X7CjJ9wgO2W4G1yc1rueq424v4J1b5a9KOolg8U1T02O1 >									
//	        < u =="0.000000000000000001" ; [ 000030093254405.000000000000000000 ; 000030100983580.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B35EA980B36A74B6 >									
//	    < PI_YU_ROMA ; Line_3039 ; v945P872c70TZjVoo85vTKF4X5scgEQju3wy5WyNZ61rZAFvN ; 20171122 ; subDT >									
//	        < 8Q796Ysjy34NhYIw01q19JYC5Vd1s1Bd0x4W90bCGlyXk6781A1ztIAO0BoVe2So >									
//	        < 5bAmTlHyy783df76rglT8X75VxoRD15kYP37363U9OVOxo6lOSeqP292AzLXk0BZ >									
//	        < u =="0.000000000000000001" ; [ 000030100983580.000000000000000000 ; 000030107546290.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B36A74B6B3747845 >									
//	    < PI_YU_ROMA ; Line_3040 ; 7oBr7eMlk345zL0m0c3zmvjMVHHg2ZcpsxZ4OMmsndqS4lYJC ; 20171122 ; subDT >									
//	        < 5CrD5mHrUlky0v9lfOdQlXhrWLxNS3Kh44Ts4hO70Czbb28rHXBBsQRFyOG4o4cs >									
//	        < ZLAy05GAA1Ee35WY802r2UXRBU8Hl39tc8rTVs5T0uCb1vBl1pc8CTGd8suWbgtL >									
//	        < u =="0.000000000000000001" ; [ 000030107546290.000000000000000000 ; 000030117828205.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3747845B38428A4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3041 à 3050									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3041 ; a4WtnIgB5Jf99sGo1AxVi2UmndP6J3CNm5h1xfY4ITxIG2WcH ; 20171122 ; subDT >									
//	        < aY8ZC5GM4o1v7ZwNPb7gonM7gtqm9XOK8xCZ1k62008W6cDfrbx26ZU13GlM81Li >									
//	        < A022kuVUQ5507taLqp34LEe2P55rY8fyvuNYa7vfbiDEDbg100NtmrlvewpI0KNs >									
//	        < u =="0.000000000000000001" ; [ 000030117828205.000000000000000000 ; 000030129117656.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B38428A4B3956295 >									
//	    < PI_YU_ROMA ; Line_3042 ; zcb652K4f8u858pb14yq5en6jEP02bZhN94ksgP3xlF2m38Z5 ; 20171122 ; subDT >									
//	        < f475DM4YzQwKm5u3Qa5cIvNzbGFr8A11bpYV8zwsVaojzEMo009BfRVq6Bf6TMjA >									
//	        < Eq1bFTZ8t6ZSmbnOChr66a7NmS82o19jCMT60KEtrz3gI1Tc1WK7ji86X7WQ31gH >									
//	        < u =="0.000000000000000001" ; [ 000030129117656.000000000000000000 ; 000030143524335.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3956295B3AB5E31 >									
//	    < PI_YU_ROMA ; Line_3043 ; JK79r4cZ1tlwZ96Q9s0q0oIR983AsNpc6DdI6beUj6Xn89Bty ; 20171122 ; subDT >									
//	        < 7v233iAbf92zjWF7g9aTUVN4ekW1YuDK22kerG5rpk1Nsbi212MNxeT7Rq3Ew5um >									
//	        < dhwPhT464wTo3tNq0uC2vtBDcHrpFm79fDEav27eOlTSRRCmT1Iyi7UA2lj2478U >									
//	        < u =="0.000000000000000001" ; [ 000030143524335.000000000000000000 ; 000030156049253.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3AB5E31B3BE7ABD >									
//	    < PI_YU_ROMA ; Line_3044 ; dFa3MLycTX9Rf9Df5tlo9k468z7z5WPT9iUa4xU5J6z914QO5 ; 20171122 ; subDT >									
//	        < 24NVG78DLJh8RA2Q3tYzqk1gKoI4279Ub55G34ezjNn7V815j5JqH4PXe96aCTtf >									
//	        < cr211EZUyNQtRM541m2Zryk25fTsxazE1Kj3p766374wj8O58e7J1Ibz3BeRMI2u >									
//	        < u =="0.000000000000000001" ; [ 000030156049253.000000000000000000 ; 000030162275783.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3BE7ABDB3C7FAFA >									
//	    < PI_YU_ROMA ; Line_3045 ; k52d7Cv2cz0xA18jo4Qp3wPc3f56pFasAdwdcSnHYtCTnlmjR ; 20171122 ; subDT >									
//	        < VFBzegXYy2rqq13XOi5vXKa628IZt9typp0w2ejX4fHzQ74fxDyi20Y9FJ5t31N1 >									
//	        < WE17b4h1iyJlRG4WAdXtaB6876rLFGre9h3QI5GLke9wZ03i5L0BC2rt5vA3eC04 >									
//	        < u =="0.000000000000000001" ; [ 000030162275783.000000000000000000 ; 000030167552661.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3C7FAFAB3D00842 >									
//	    < PI_YU_ROMA ; Line_3046 ; 9W0hJmZ4iTvV15ywQNFMtxO5TK1r9iywlm4N4Xk3tZx8NabbK ; 20171122 ; subDT >									
//	        < 06e8JcdpZokxVthlLUGBLkvR8WHghB2IPXJwDJP18eYBwsZQ0f03dg17kWoCR3CY >									
//	        < 8WM0Y2Wu8EP0U50h57tRc51UR6GfmO1MUx7XZb2So18YgSs2J1ZjjolfSYiRibvt >									
//	        < u =="0.000000000000000001" ; [ 000030167552661.000000000000000000 ; 000030174836660.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3D00842B3DB2592 >									
//	    < PI_YU_ROMA ; Line_3047 ; KhF33Gk3i2y7tKF4WNa8HWK2RjFR3KB7sqOzBYyCg6496134U ; 20171122 ; subDT >									
//	        < YWF0yKTPs4xlg5QZJ32IwZA9IU2dA0oevj6EXKbrV1Pbo2RdxE8m8icW1C6dN48y >									
//	        < erKPq47W9fPIoMW85436xV4K0sfSEzb7S2A17722Ul78yFm3GS7Vt094a91ZjRrt >									
//	        < u =="0.000000000000000001" ; [ 000030174836660.000000000000000000 ; 000030179920422.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3DB2592B3E2E76A >									
//	    < PI_YU_ROMA ; Line_3048 ; GqBF36ExIfheWVSedbLYB6x67k8Hn0y0NJo7e9kuJVrcD8Pm6 ; 20171122 ; subDT >									
//	        < 2o6Zfo7xyx0lyO73Y94c948j608pSVzsn2pf631Me1V5r3Jt4MAP5IvCxtnp93L0 >									
//	        < F19IcQQ9uiOrwVVAivDc9y49B2PhHdEDx12bSxM04KrqE4L9a9krUWdN9GKB5P74 >									
//	        < u =="0.000000000000000001" ; [ 000030179920422.000000000000000000 ; 000030192698122.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3E2E76AB3F666B4 >									
//	    < PI_YU_ROMA ; Line_3049 ; M7H60UuKCY27a87umBoP1e8yV5g72j070sl0YO286cpz2u77R ; 20171122 ; subDT >									
//	        < 7FAJ6LWepmz956V7V702w5b7NpkTs0k6ltCaD5lx8s2h03adCAY58752r31VGYNE >									
//	        < YC6182HSn89t7nA14Fm7S5WLRfvnB6HKCfQIOgutp5gHUafNvrQz1HaOcUe18Wd4 >									
//	        < u =="0.000000000000000001" ; [ 000030192698122.000000000000000000 ; 000030205669210.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B3F666B4B40A3189 >									
//	    < PI_YU_ROMA ; Line_3050 ; JJf68R688kifdM5k5w3Jb59u6TXpCVajPudK8lRe277v5E75g ; 20171122 ; subDT >									
//	        < tVMC0GqgQP8R0cubnkRWkS28Rb100RMQEshCqBS8T8X4R9Id12lyeFLdOjA6hkiM >									
//	        < 9U2pqk9do3V4pc7XS025Yk4g6v0jdNbD7nXIDYcK797eS6s06429LV9vkdBnL9d7 >									
//	        < u =="0.000000000000000001" ; [ 000030205669210.000000000000000000 ; 000030216746293.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B40A3189B41B1885 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3051 à 3060									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3051 ; 1a3n1ooYo7A1b43cu3S82gKSidDG7jchwp2491A0tYCwCGSy3 ; 20171122 ; subDT >									
//	        < zlg9kOC3ca3GRm2gx3bAk8aKN3p1B9QT2ZwRnqe93gM586S9r1f5rx127Qky20u0 >									
//	        < 41K8z8vDqwg3X8F0h8F2cv929bO1m4VZHojvebj3RfQ5dFP9gz0Emm4Q1907f9z1 >									
//	        < u =="0.000000000000000001" ; [ 000030216746293.000000000000000000 ; 000030221876985.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B41B1885B422ECB2 >									
//	    < PI_YU_ROMA ; Line_3052 ; wBz8LW18F2MYrMQL2v8QjIir85fG4q390wa117M8uv6V973cO ; 20171122 ; subDT >									
//	        < L3aG1CuVzooCZ84p272050uRU4vg3MMw3djFv5eeCqeP2zIiPYVPDNRdttIfPGna >									
//	        < w5itfh5yK8pr4e5I0r920RV8U72O73p5zB2Y1wH5GP5j3aNia249fj6gc6cIvenK >									
//	        < u =="0.000000000000000001" ; [ 000030221876985.000000000000000000 ; 000030232127857.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B422ECB2B43290F1 >									
//	    < PI_YU_ROMA ; Line_3053 ; F0FOVSkULK5Z75FQQMjp6Y39n66t5F0bh5Z5yUwAPm757L8cZ ; 20171122 ; subDT >									
//	        < D1Grl4qilohLH9g71Qnta3XrQ1F4Vm5Z2523KQPGU99rwK75aZdWnoYLL12N8jIZ >									
//	        < J2Ym1V01RT06wC364GfhN1EwB088062Y738JHl019t2kPONKLv6sYN5q9LVXsQux >									
//	        < u =="0.000000000000000001" ; [ 000030232127857.000000000000000000 ; 000030245675211.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B43290F1B4473CE1 >									
//	    < PI_YU_ROMA ; Line_3054 ; r2DHtQbJY0FmI98a7RPhN535Nx7vaQjiLqWxs2DjtjLD5bd0E ; 20171122 ; subDT >									
//	        < 0K10Tw20r83NB73NaE8mfS32hzjg3i4X05oX889JApB61ZqsBr3Tdnbn1fSsM6fb >									
//	        < HVpT8JG1Ov3Q407G377HU2akO0733E7XN64uT20E3Dmqh5U6hxx31HqN8KWly2GH >									
//	        < u =="0.000000000000000001" ; [ 000030245675211.000000000000000000 ; 000030259862631.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4473CE1B45CE2D7 >									
//	    < PI_YU_ROMA ; Line_3055 ; n5f38sPRNeehqmv9Z32yk4g4Ed8X09BMDohj9jt3J827254P2 ; 20171122 ; subDT >									
//	        < 4Er02zI5QoAO0D2b1B5Rgaq2YQ2l08TiP8qJQT5253azaN17XHj18YrO1Iu9IXhO >									
//	        < 39yfX2722HkQ3W2e1yoX8K6QRF7JFw1q2hB3opCx329gi6hg107x1Xui3hC6x6e9 >									
//	        < u =="0.000000000000000001" ; [ 000030259862631.000000000000000000 ; 000030265982981.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B45CE2D7B466399A >									
//	    < PI_YU_ROMA ; Line_3056 ; vp236M2Kh0G269wAspIFYh828F5VrPyf7Z9UBaNw9R8oTZDz5 ; 20171122 ; subDT >									
//	        < 5ScJQ44Prhzg0QHNuSc5IpZrZAaYY8Gr05VqLcTi217FC8o4kel64qR59nghk2HG >									
//	        < XszjoS8qv7MJQY4J3yD4m126YFc6O84uI5Y67zHsKf8yUpUY86Gl2i5W509lAFpl >									
//	        < u =="0.000000000000000001" ; [ 000030265982981.000000000000000000 ; 000030274166158.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B466399AB472B627 >									
//	    < PI_YU_ROMA ; Line_3057 ; WdJx66pwiWUTxHx49BzLy1WhYv2woCKTfTqV7988p7Rr1PvJ1 ; 20171122 ; subDT >									
//	        < 8HDuImREuRTF7i04VQyv7gV60y57x6s3sG8StW9Os1ptW7498PK820u78WLqST1g >									
//	        < 2L0I666xayfVFRepv0GTUE3A3cqGq0a20joT9C0BRbF3eyu3Ivq5lK24cZ17u7dk >									
//	        < u =="0.000000000000000001" ; [ 000030274166158.000000000000000000 ; 000030282463161.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B472B627B47F5F2C >									
//	    < PI_YU_ROMA ; Line_3058 ; fi5wstq1wTb1T360hF3wF852fnD5Gcsy4qwYWVV9182EBSZU5 ; 20171122 ; subDT >									
//	        < 8UVzMX1K91lvLF1rqmi7q9Wd05AEOZ6dZ5E3gtO2zgLj6BK1Eek88P99I747N9ea >									
//	        < 78y8nbkOZQX88uU16D2N19T34nkWFwX5j7Ud3J4mC7HsEVc2JgZ4xBl56XqG3L73 >									
//	        < u =="0.000000000000000001" ; [ 000030282463161.000000000000000000 ; 000030295747307.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B47F5F2CB493A44A >									
//	    < PI_YU_ROMA ; Line_3059 ; GgEjvVq9Ix3FL7CF2Kje6PzACf9VeogQnrbC91g7hMBwYgPmD ; 20171122 ; subDT >									
//	        < KAAeWDEhXs0hwQ54h0K55XiTOKivJ6qWFio5pYB7h2SuhpbR87KvzBI3pb222m3U >									
//	        < fsMN45Q24iRuITpsS89z16hwfwDD8XyJjH7l2r9fd0ex45kmIIbG4BQ5d0OO3kuw >									
//	        < u =="0.000000000000000001" ; [ 000030295747307.000000000000000000 ; 000030308113213.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B493A44AB4A682B9 >									
//	    < PI_YU_ROMA ; Line_3060 ; 1XT1AkE9B4oh834v9STlySigu9027949JWGu4Opod5iU50wxD ; 20171122 ; subDT >									
//	        < C6kVjA1FT42R0dc6J1qjV4WB5pn7U6puCRkQ9H966FBBmN9Qo3t4hd30un71e8H9 >									
//	        < WCuyhqY57HZ9evQDY15fE53gKzP484c77W0Ie5Z7b63Y3318Vr7ei5XaJaUS3942 >									
//	        < u =="0.000000000000000001" ; [ 000030308113213.000000000000000000 ; 000030319597860.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4A682B9B4B808EA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3061 à 3070									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3061 ; t5Y990D4MF79T1x2fla5pjiY112EOAE7B1T3oJCspnjLn4gqY ; 20171122 ; subDT >									
//	        < 6VEjEIr8g3Nrf2e0zxiN4NHa1s2KdoCeLAvRoxvXCn5X2K2pNTDNPz3M1Dh5yFCz >									
//	        < Jknf76kECdlceTR9jk5r5p54fLiD417zZ5GUC0WOng9v91ltOEp1IML5WUhOW3Ik >									
//	        < u =="0.000000000000000001" ; [ 000030319597860.000000000000000000 ; 000030328177937.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4B808EAB4C52081 >									
//	    < PI_YU_ROMA ; Line_3062 ; pRvCc9MWxk8tZ9kUOU124109ifMZ8bIn6Wv0Iy8YF5r651B54 ; 20171122 ; subDT >									
//	        < 7yHQzm9Vi0K48rjpYO6JCzwT45ZCw1jsdajN38IYoQSI3R91Ie0S9h9B6WQ3OtT2 >									
//	        < xUe0vwyN336Z6OUA7Ny17mr4GppXcsltZA69OrbOVfc1IW9JxEcVXY591a8cmZ0v >									
//	        < u =="0.000000000000000001" ; [ 000030328177937.000000000000000000 ; 000030340926603.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4C52081B4D89474 >									
//	    < PI_YU_ROMA ; Line_3063 ; 7EhN87Qu9ha51TK7i5GQXws8Y33852X64MRvP6g6464K5wQV1 ; 20171122 ; subDT >									
//	        < bOTTrjYqUQ4rkBJFf0rG4yX2u2KtPpkT6qvJ174hOB8dc59xuz1C8iB3j1VYE0Cz >									
//	        < 82pN83nn7wVkql4MW9cBVqJJQ9ror99sBFB5150b7f6GEcev4E28FbX5Tw19Yp1y >									
//	        < u =="0.000000000000000001" ; [ 000030340926603.000000000000000000 ; 000030349560601.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4D89474B4E5C11C >									
//	    < PI_YU_ROMA ; Line_3064 ; pzAgXw07I1B55aO2G6B9g3M70y370vugvdo2nhTGH5QtOrc19 ; 20171122 ; subDT >									
//	        < L8Okk5KZ6UY3N50L5W33Kj8N73LJD14v78ERLf84GB51M3iXi95fK3xT0KyrVng7 >									
//	        < dvI0iW2dGK4LM9CSg63igClgqe2w81SEG8YP724D4fJk52YO6640OK6IMpShZ7DL >									
//	        < u =="0.000000000000000001" ; [ 000030349560601.000000000000000000 ; 000030358098299.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4E5C11CB4F2C825 >									
//	    < PI_YU_ROMA ; Line_3065 ; Pqnq2kC4a61V4fLDQF519p4d5DC1BOoy0wmgRFg7nh8s48U3Y ; 20171122 ; subDT >									
//	        < va464t670NYBwhgDGJ8692QnxV4Dg5418Zvx3AQM8Ctdb1a0rD0u8TIM792u5pxW >									
//	        < XPhv64T21Ar9mcIuUs1jVJ8Bys13V2seeN1mOf18s5O5s6Qs07qVTf9tzcF8a7h2 >									
//	        < u =="0.000000000000000001" ; [ 000030358098299.000000000000000000 ; 000030371529058.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B4F2C825B5074689 >									
//	    < PI_YU_ROMA ; Line_3066 ; 3KeDZC3ORNB5epkmhljcRCo049I4205NT8ZPzc4ZGK5822a0s ; 20171122 ; subDT >									
//	        < mQ00b43PBSr84VszqbZiUJEdO5HfEpBcE3tb69oID1po3b94ZMkaai2l9g2MM9O4 >									
//	        < ZCbebP08AcxXRM76cwdYl58BL8YN5I84zs86xum7x1P5UMxdR2sD97vGiAh2RvoF >									
//	        < u =="0.000000000000000001" ; [ 000030371529058.000000000000000000 ; 000030384199919.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5074689B51A9C17 >									
//	    < PI_YU_ROMA ; Line_3067 ; KWyxhqCVdwa43zzINCMZ7leI2La99O4P7YK8M6OTXareT01Ym ; 20171122 ; subDT >									
//	        < 92YyWr1F4vi2OaqfUAmBQ9P6x9T5D9p5f23Zbn0Td7lGHBing617k04O747OGPBS >									
//	        < tt1707Y582PK9c6ZI48PvgorXdP2o9Knn4F9954Z96C1v6O61a7V1c9y1s0nG0E9 >									
//	        < u =="0.000000000000000001" ; [ 000030384199919.000000000000000000 ; 000030392724582.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B51A9C17B5279E0A >									
//	    < PI_YU_ROMA ; Line_3068 ; T4e7S0CFPlwX0q5X94E32IUWt0kR0Y3P0agUJ7seiv065px0n ; 20171122 ; subDT >									
//	        < QT2Mwx8Kk7afp1hggXce5vbJ9848XFOE6EhR5TQ1EuQVu2iRZ3DqmU7J2nGg0ia6 >									
//	        < EGLSS2lk1bTPMT4h3SXq91UVqpsCWt9pa6O5vH799pd5ej69Uuf6YJr0tMYbF9v2 >									
//	        < u =="0.000000000000000001" ; [ 000030392724582.000000000000000000 ; 000030405493945.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5279E0AB53B1A12 >									
//	    < PI_YU_ROMA ; Line_3069 ; l0v7k73o7A0QP03Vu34kU822182Jo2QZ179jd3yrf4T123Y4Q ; 20171122 ; subDT >									
//	        < Qqy6s9NnGLa8lY2D1OE9bm1bu6T6ipzESW1nMdenSS01zgQoGhq0fpb4D6I4CV93 >									
//	        < 4kcew6m8c3sCozQqQD12Tp2DLXeCmdi7kAJnxetCn8jnAWt4IYtNJVcmKD92XL3K >									
//	        < u =="0.000000000000000001" ; [ 000030405493945.000000000000000000 ; 000030417187357.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B53B1A12B54CF1CF >									
//	    < PI_YU_ROMA ; Line_3070 ; 756coy6R02tOE46m355G5A1jNje7ap20Ngx010dtE9OiQPDJ0 ; 20171122 ; subDT >									
//	        < rJYA17Z00iW9On5RZCyn5yCEYZ34O6hCaum33W5499FkbGlPvwfv2lUsHCjsrbDn >									
//	        < 8FVa821S3jYHqPgo5uM7iyen7z2xdKSCl51twEpcJ59DST648KQp6Ba31OUJj1gE >									
//	        < u =="0.000000000000000001" ; [ 000030417187357.000000000000000000 ; 000030427102623.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B54CF1CFB55C12F6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3071 à 3080									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3071 ; Oy2yD8L2ZzKVAGp1eBpn112lb0TmHMZXoTdUEsF218FpM7c8Y ; 20171122 ; subDT >									
//	        < sOU2r8nggQtrQ24h0o832f45ooDdY5c3HCiB9kFc5PMoJGLkodPqfJI8w9KVV8ko >									
//	        < 23z6jF70V18PVn4854J11I1xNF8614SIdI1vXvM0xtT6luysXJkvPy2053W4YXcL >									
//	        < u =="0.000000000000000001" ; [ 000030427102623.000000000000000000 ; 000030432790172.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B55C12F6B564C0A9 >									
//	    < PI_YU_ROMA ; Line_3072 ; 81Rif42bNzuXYT4u7H404ZcmmeJpG4QDmV88N0X145QUbS5zs ; 20171122 ; subDT >									
//	        < Jz89F5xG2h1D1T8Yhh8K31p63M41H1umo12X3ok4SF3NpqpLj784G9AhVXbN306a >									
//	        < 5g3y5L7520hSIQmcb599EKjBD1a41Mmso7p05pGyHb77wK2G34e97Rn3R18knf3B >									
//	        < u =="0.000000000000000001" ; [ 000030432790172.000000000000000000 ; 000030440147846.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B564C0A9B56FFAC0 >									
//	    < PI_YU_ROMA ; Line_3073 ; fcn9w9GK53pl750O6438F6NK5yZBpAcoJ394A0RdI56ga9Xd6 ; 20171122 ; subDT >									
//	        < t6toorMMV637Pj0a98O76Tc8mEQm1kQMtH6MBChP2xHx9Ti2Q95y7DOX3oJXO5Q0 >									
//	        < y1y3e9Gz3MH19nOy5F0nsI1a9GiV9A08Fr2XeL7jf2G12Fw1zvs3RxU8kyOQtsJs >									
//	        < u =="0.000000000000000001" ; [ 000030440147846.000000000000000000 ; 000030447270814.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B56FFAC0B57AD929 >									
//	    < PI_YU_ROMA ; Line_3074 ; PmFU0I1mB95LpJ07d1h0FY5077M0U8fbx9K2G1V2w4kZf85mi ; 20171122 ; subDT >									
//	        < 4WK1ra72I393O440w6vg9u6WEm04i09Klh6KpP96Q8xEiCdy5rtNZs5ykc7ZM3JD >									
//	        < D88HetiL2R96o7RCC98bv11ffaEa3c94j824Ms65M10f9986eIm8Wy1Xvw22BGcN >									
//	        < u =="0.000000000000000001" ; [ 000030447270814.000000000000000000 ; 000030460243857.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B57AD929B58EA4C1 >									
//	    < PI_YU_ROMA ; Line_3075 ; 6R7X3Hw8FV82qPCqkf3b5Dh0vOE6cnK0i552R24RT00K67ar2 ; 20171122 ; subDT >									
//	        < 6SRwtZAJsBNKx83LZLu8H9v2zd7RC5pAL4W76S25B0f5zbpq7x2N3pi08l7a5TKk >									
//	        < mB03hBm5WsWMEn7Zhos2xS352iLrSlxma3P7G8WIbt7hbrOqvuy4eXGgA6E2di1W >									
//	        < u =="0.000000000000000001" ; [ 000030460243857.000000000000000000 ; 000030465421970.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B58EA4C1B5968B75 >									
//	    < PI_YU_ROMA ; Line_3076 ; kxHKi46C7yCj79U0CpYAU842Kg0hCQ3P2rY6e01lgFaW7kuY9 ; 20171122 ; subDT >									
//	        < zc5r0SBmdQ9T7m4BPVc44ZY0Cl23B1bg5FMtodXCMl6GlIe15Hkns0U0YNK84Bae >									
//	        < k1NWu2tK98bTYky1r2fQK468vX3f7SXk2qu2zjWo9z2NF8gbMS2yW99CVdSYFkyD >									
//	        < u =="0.000000000000000001" ; [ 000030465421970.000000000000000000 ; 000030480338957.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5968B75B5AD4E67 >									
//	    < PI_YU_ROMA ; Line_3077 ; cwtZIt8l6Eg56JDlMJTxXTqX55oF9Ir4me6U37h6L2HXuoU21 ; 20171122 ; subDT >									
//	        < LEvG77q5Y8g1g2ihTfD260cjUxsP81JUufU5I9qf00oPHbr8c23Q42jZq5PFO55F >									
//	        < 29EpFc0x5x9ua3bX71Sv1Ai36SXHwxl7N4ar16GjhJ0cUcY9h5tA01t33WK0muX5 >									
//	        < u =="0.000000000000000001" ; [ 000030480338957.000000000000000000 ; 000030491103807.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5AD4E67B5BDBB6C >									
//	    < PI_YU_ROMA ; Line_3078 ; YOE3hup42qf4OTVfInTZSLEXVd6qLJ3EA3x8LRlETIzYZ685W ; 20171122 ; subDT >									
//	        < P4I7jqolh9iEhV0epz3lz6J38014fO3iOB0p3W27WLCig41yvg4DNvIO21bjMHKU >									
//	        < 4paI56i6u2647QCMxC9Eh9nXVRFf1v28VEkGTgW306aI9fgXJpV7XcwxRq9dz6JB >									
//	        < u =="0.000000000000000001" ; [ 000030491103807.000000000000000000 ; 000030499176404.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5BDBB6CB5CA0CC8 >									
//	    < PI_YU_ROMA ; Line_3079 ; C83Jzrfw7KO7EjtQ7Mf8OL578g9iecr2l47tp74v8F0ScejNf ; 20171122 ; subDT >									
//	        < x7zVP38s290PapcHHh85LA360iJR6ndKcwLPfrw9EENVE4V2eGG469ya90q5hj1K >									
//	        < Go1B78YBts5tiXTB125m0T3JP9Y77EoZ53V3EZHI2qs1rs6CdDuj93jy6ww8Pfdc >									
//	        < u =="0.000000000000000001" ; [ 000030499176404.000000000000000000 ; 000030511523211.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5CA0CC8B5DCE3C1 >									
//	    < PI_YU_ROMA ; Line_3080 ; UtqvKSbf1bhE1RYp0Zux6UIOs6o4C4hSSB3X18x23s53u49r8 ; 20171122 ; subDT >									
//	        < uNmrW7104BV4ZrM2ENPT21cGE7709c034i3P4a2rYhs77vRY69c467Sc8C4rP8L9 >									
//	        < A7i3CcojYW251Lg5j2JKzKtA95w8un82263uEPh63N59oO21738vyVS70Sj2l7Mc >									
//	        < u =="0.000000000000000001" ; [ 000030511523211.000000000000000000 ; 000030525467982.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5DCE3C1B5F22AEE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3081 à 3090									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3081 ; 0008v69vLSdah9NYJ3b0f7yMCr6cy2noHE437yER6C1MR9sTx ; 20171122 ; subDT >									
//	        < soxMvDF9rY0im53yN4jCZ47tnDVi1C37p0GU9gH5D3E212X3qXy1eHS1w2RluOcO >									
//	        < dE37VMfNbqsgVFdYhfp4455a21V2wBsW3UC14508D3MjEIIYhPt5G4r9207Q5ECk >									
//	        < u =="0.000000000000000001" ; [ 000030525467982.000000000000000000 ; 000030531627756.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5F22AEEB5FB9117 >									
//	    < PI_YU_ROMA ; Line_3082 ; Zbgia752pjU02m371X8o66JT9aqmMf59PQA16q46JoiaUWK7A ; 20171122 ; subDT >									
//	        < JcYpp5vIdWM6D3S0BKaK7T9wVmt1hT0bK4r18HV3pfCn29u2jlxz132rmar693bK >									
//	        < JwNjR00jVA3OY1Oly70J492q8hK5969kDm55NRxJFB8wT0p56PWcyjhMaOr0kPih >									
//	        < u =="0.000000000000000001" ; [ 000030531627756.000000000000000000 ; 000030537659105.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B5FB9117B604C516 >									
//	    < PI_YU_ROMA ; Line_3083 ; ryf768q8lFM51b7u81Y25Srr3B6LcBiN0t275i2U3WVSJd58M ; 20171122 ; subDT >									
//	        < 4OL237gc6I33YOrWlU7r274cZ2BjB48xCfv1dhi7qcKp9uA4j4TeSzxS9ZiT9Vpw >									
//	        < V7FY7Nrx1ZDI9ppjid36jtb3nDYZFt876gnIvu7ShwdMok59P0Ssb2ud9I5LzEBc >									
//	        < u =="0.000000000000000001" ; [ 000030537659105.000000000000000000 ; 000030550492894.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B604C516B6185A49 >									
//	    < PI_YU_ROMA ; Line_3084 ; g0pDvwzZY6LBdwVGgO1bM408b0PEaDRZF5A2l7bB05i4gZoE5 ; 20171122 ; subDT >									
//	        < tUmD1c3QLXy91V98J95lbG8aRSTAM7t18GA2majcx15412477Eo5W5shtB96O8Ot >									
//	        < 75ZLi5TZ6RlyA7ziGJlJuH27Ofn6x84Ut8N2klNLhYeymf5ZKQ4PxB6UDQdv72Hw >									
//	        < u =="0.000000000000000001" ; [ 000030550492894.000000000000000000 ; 000030559449102.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6185A49B62604CE >									
//	    < PI_YU_ROMA ; Line_3085 ; 9Ji0nTENPDO1Yik6It95V1iZlbwBBhr1C7dBGf4HS38eYSz61 ; 20171122 ; subDT >									
//	        < m2GH3y5YDXqK4b9A4sbR3qBp0bw796W7c4k3jaNKyMNMVnrX5TFCu7VY4vq00Juy >									
//	        < 1szNY937khBaNwCmL6yLPryoA3XkJqeH0o0VywaA6pB3p63s7i6iL9IbV9rfdPV0 >									
//	        < u =="0.000000000000000001" ; [ 000030559449102.000000000000000000 ; 000030571838289.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B62604CEB638EC54 >									
//	    < PI_YU_ROMA ; Line_3086 ; Balt59Qij5fT1oq42goCJpBX5D8168s3Q5xq5yY1KT68Bc665 ; 20171122 ; subDT >									
//	        < r6ex4py0D8e61WNNzBNQv009ptj0R8IuP75aVD7kc3btJI60T95h1cl94473O9tl >									
//	        < x1EMBQh0p07p4sIK0dlMb679BWoS9qny90BU9QB0AghoNLOlclo25qh89hoLA48u >									
//	        < u =="0.000000000000000001" ; [ 000030571838289.000000000000000000 ; 000030579343929.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B638EC54B6446038 >									
//	    < PI_YU_ROMA ; Line_3087 ; 47hzzOIzviP6Jao0WspS8L4x0PtMQ2BN8eM5597PRhj1Yay87 ; 20171122 ; subDT >									
//	        < 4lHHYP5K66QK3Xrv5UbFyJ70Pu2U1Lf5IW675PpTpK5T42ZqSgn9XhRktIbRZi8G >									
//	        < 3ljOdzZN93f2jL0ijl2240Y816ipTZvHSzchanP25JdI5IZlLcdd90nW2ap8C0ZI >									
//	        < u =="0.000000000000000001" ; [ 000030579343929.000000000000000000 ; 000030584994638.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6446038B64CFF87 >									
//	    < PI_YU_ROMA ; Line_3088 ; 3sTD5VaYq1B0y37FkFXva8yeR26o9BF6849Rl4vz20Y84k26b ; 20171122 ; subDT >									
//	        < xMoK8UA0B8sA58qf8IcO7aWpyiI5u22j835DI1p3HDsSw3LJcnd0UV5AdHCTHS5q >									
//	        < m3Ah3p5n931oCjMHZ163MuTrYAk1AcnKlHg4G7wodldbUX3ERx35UqXq36c8rV87 >									
//	        < u =="0.000000000000000001" ; [ 000030584994638.000000000000000000 ; 000030595359224.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B64CFF87B65CD032 >									
//	    < PI_YU_ROMA ; Line_3089 ; lH0jtin6p861MB55o94TA62Qr183Wqpx1bKn6d914PFch86fD ; 20171122 ; subDT >									
//	        < xmTG55Jcy4j0rPld8326SLP7q53TVf3d1waID09T7nMdprZNvXpj23oUgQ8Ah95P >									
//	        < 06ub7OA5tP1e03H8ZyF36wh7u2toa6qZsE75ZuB03Jx8eI4ooV7Tc4lo3500Ho3x >									
//	        < u =="0.000000000000000001" ; [ 000030595359224.000000000000000000 ; 000030601988240.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B65CD032B666EDA8 >									
//	    < PI_YU_ROMA ; Line_3090 ; ARjl3iE4M17UNNFA76zI3tSe4q2zVlv0R5ev5d2RvGqoT3Ow3 ; 20171122 ; subDT >									
//	        < R4W5DNkUpJn69115b2YUIrh3wr0l3xXJH4Ji6rwOx2KPc1RCtZrklG12p6mb84P0 >									
//	        < 1xcTxYM2u1q6Vyw1g6emClGOOYrm6gohe6P76082RyWv5GzbwnqS44yT4rssDLOM >									
//	        < u =="0.000000000000000001" ; [ 000030601988240.000000000000000000 ; 000030616212532.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B666EDA8B67CA205 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3091 à 3100									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3091 ; rz3ly2uGiG2gYT098TesDlthyKiQ2Fxlypm5ihN69iXvwzN1Y ; 20171122 ; subDT >									
//	        < i7WJu3BNdeNE7YPcb54aQWY5TR7nVcGi2ILh8niC0DRPF1WB79S5Nx88xTkx9AyY >									
//	        < FF0LyZ2Mwi8sV86iMch5wdP6jTRb9Q9aZ492QIw4r5nl59cXq2vSEtPTaIS2x5gq >									
//	        < u =="0.000000000000000001" ; [ 000030616212532.000000000000000000 ; 000030625790364.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B67CA205B68B3F5C >									
//	    < PI_YU_ROMA ; Line_3092 ; cRA9y0LR4nZ6dW9UGOcVil5q97R2n77U9YoWF0DMK6t1bg8JJ ; 20171122 ; subDT >									
//	        < g87OgTe2Z5vMi48qN1TbjQQuekLbhR1XBkhJ0367U1Q7cx9yM8U4VBIrY0y3ID1h >									
//	        < 959p5K66T017Ru89jmKD14LWbWCEc841u17771fb08ZBaJsm0AN6VA2pi81sUhuC >									
//	        < u =="0.000000000000000001" ; [ 000030625790364.000000000000000000 ; 000030639793369.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B68B3F5CB6A09D48 >									
//	    < PI_YU_ROMA ; Line_3093 ; uKzqH8egtCM4P2f4o8D38z0d6975ptx083Z088D31CR20Sj1T ; 20171122 ; subDT >									
//	        < S0tn2K1F3eUaEIpvb763ggfEDrfaaatVtLdmk9GW8Mf1O3ooHnhkREhkoKD6Ixgy >									
//	        < DfZA5e9qxw6A91rA1GKPNLL47EJ9ZT7iv9JcGiKJCDmn7Vw5kmUqAYX5q6D9eES8 >									
//	        < u =="0.000000000000000001" ; [ 000030639793369.000000000000000000 ; 000030647771694.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6A09D48B6ACC9D1 >									
//	    < PI_YU_ROMA ; Line_3094 ; fypv34nook1h4KhctW527At3AcdSW3yWZbQBx8FnNqY70z645 ; 20171122 ; subDT >									
//	        < H6GDchC13X5mguRPoH9m9PtWQ152rLMXk240SXXrH1eommAhNQ0Cc8n8CjvE5kt6 >									
//	        < PJ4k50618IwoX6nH36Lg4hbG4Zq6S56TnO7xxph5ZGdAq85VIvNxuHAVHPI7w71z >									
//	        < u =="0.000000000000000001" ; [ 000030647771694.000000000000000000 ; 000030656680792.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6ACC9D1B6BA61EF >									
//	    < PI_YU_ROMA ; Line_3095 ; XNFQ7yjM1ir78q9tnbb3JDu5y9n0q1Oe3VP614Q53RhSeFF4g ; 20171122 ; subDT >									
//	        < QO2fttbVGE0HpZU1nC5ji402r9LBNf5LiNXy4PxeV0p1o7Np3RYdb54NYikVLB5d >									
//	        < PkiOKVq06IYaE8fm4S07uN4BbN2EqckphOm8s854t7wU7W390z3V5rxDh5C851P4 >									
//	        < u =="0.000000000000000001" ; [ 000030656680792.000000000000000000 ; 000030669183763.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6BA61EFB6CD75E8 >									
//	    < PI_YU_ROMA ; Line_3096 ; WyWSaErI1nvfeHpZ6xKqA52Ka4Zx52JRtmQ9ItInxoRMSa3H5 ; 20171122 ; subDT >									
//	        < IkZQrV7tMR6fMzNZ7EJGwjvR931Q3pWl5403uV2k3f2B1P7mQkj081s9T41f767v >									
//	        < 6zhu2379k3HHHwm65r0229fagzrhBkh36V8EJdJ6cZGYqw3No212793XgQu188dF >									
//	        < u =="0.000000000000000001" ; [ 000030669183763.000000000000000000 ; 000030680477231.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6CD75E8B6DEB16B >									
//	    < PI_YU_ROMA ; Line_3097 ; 4oc3J5FVnbqrY2LGuIIJCatb645CteKe3xn0p48qpYZY85Z8Y ; 20171122 ; subDT >									
//	        < yKV2Zm4GYD1BzAoiwK0aOhB9WEoyS835RV794u3917K33jIwx0BD3WCSt1kzJMR2 >									
//	        < 0qRgP49g3SUDLG7RCKiTF1ifinSrQtF97P5t1Mn0h02s5SAfvQlVlpSGqs5X5ccw >									
//	        < u =="0.000000000000000001" ; [ 000030680477231.000000000000000000 ; 000030687710783.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6DEB16BB6E9BB06 >									
//	    < PI_YU_ROMA ; Line_3098 ; cD75QlJ3HfF6tZiEzr4S7IxPp98VdiAOWcv7iEfN45f5771sT ; 20171122 ; subDT >									
//	        < p4wW5dSdNoOSm0GQL9D22i9HIlxjJgke234dMF7u3Q013hX9HiBm6A4X018t8x95 >									
//	        < A41rdzljyJK6K9lQuRSZrGF4ZFZLLI5m5vgcbN90x5sE1p13Xkj349X8Jb7R0Rfw >									
//	        < u =="0.000000000000000001" ; [ 000030687710783.000000000000000000 ; 000030693318976.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6E9BB06B6F249B9 >									
//	    < PI_YU_ROMA ; Line_3099 ; y46wl2fp4bjA46yPCcf39xn4gb701E9D15G3N17QZTJ9mP919 ; 20171122 ; subDT >									
//	        < 54C2TJ8UgumiEUmX54MKcp77dFIhrX9QCbR7h1k75BZP6kDfYwjtARJKwvGQxogs >									
//	        < c8D7k453n10g8t9VDHF5ua7m8aDGFRZAYDIYd6S5fzhpKDqb2iGMQfQP4r7vW59t >									
//	        < u =="0.000000000000000001" ; [ 000030693318976.000000000000000000 ; 000030701005792.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6F249B9B6FE0463 >									
//	    < PI_YU_ROMA ; Line_3100 ; qhixgVx6tzy57KHMO2Y2MYFBoWK7ab9fMAa0fwW4k5TMAC49u ; 20171122 ; subDT >									
//	        < lUfP54M3e2jgSnV2s99SSGUB33B0qGuNMkTDb0I36Mj4RIMD7d2UPDxC16aP4u8N >									
//	        < 4914r83d9Lh0Ub4z8OghM2e5WLbNsZUP6wJIjYAE3W301AHr3gH69Z3onGdWfDi6 >									
//	        < u =="0.000000000000000001" ; [ 000030701005792.000000000000000000 ; 000030714102032.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B6FE0463B712001B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3101 à 3110									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3101 ; 1o1y4ppNBLldgG5Y9ggo6z40j1CsJF6RC0LD7DWYY9mBCR4OW ; 20171122 ; subDT >									
//	        < 37LZB6lEJek7rU769pHf5iWUTTdBZQ06VDJNFIu9OUbggMk3vIQT8xsDx1X67fQX >									
//	        < 1t8f7iv9E5838vJ8M1x7k3E6gV1R3H2bLjaym8Aea34ay51fXANv27kOP4s63B2G >									
//	        < u =="0.000000000000000001" ; [ 000030714102032.000000000000000000 ; 000030726027512.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B712001BB724327F >									
//	    < PI_YU_ROMA ; Line_3102 ; 1rVF07BUDqSO9c0RpX47q4aWd13X27l83Z0fMrWwnu9yipS08 ; 20171122 ; subDT >									
//	        < adLr0v7GQ6Z14ci9fId4yF1ugv91Bzxzo88SaQZ3341Q43P04z285jjJf155N76S >									
//	        < kf8nD78TAtp3bX5Z4e5lSq5n7oAyeY22N4xHOn6cH1531elWAFyXgt43xKa8uyag >									
//	        < u =="0.000000000000000001" ; [ 000030726027512.000000000000000000 ; 000030739040421.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B724327FB7380DAA >									
//	    < PI_YU_ROMA ; Line_3103 ; 6sxbrcPumL6JUTo60aYvbunMkZvR95NiEXLo03unpOW47t0V4 ; 20171122 ; subDT >									
//	        < 61q36REC4jeOgCK9yI98Ck0sA144M2dX3JwYrRV3mQV2Pvg4hzF0IkY7R5ZpPiex >									
//	        < 9v9F8NrVx98C5PDGt6fL5N8y9fPNbBrUb1uYhOi8Fe3uS07o1N8F3NMx6n4rvTba >									
//	        < u =="0.000000000000000001" ; [ 000030739040421.000000000000000000 ; 000030744584422.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7380DAAB740834A >									
//	    < PI_YU_ROMA ; Line_3104 ; w51LWg9RLw9x99m3Z9x4l2bYa18RvGi0xhXU4bqxB1KI3k1g6 ; 20171122 ; subDT >									
//	        < Zv0V8CGAtYT5w8us2m1ZAXYUsXzbSD96Hzo23qew76h498ijKmv5133L300zuBqy >									
//	        < KLP95sg442C826wIm50Hplf63NZ2I7gi86JYn0n6mHCVqF4z5R74hmguWyvG933K >									
//	        < u =="0.000000000000000001" ; [ 000030744584422.000000000000000000 ; 000030754033075.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B740834AB74EEE2B >									
//	    < PI_YU_ROMA ; Line_3105 ; TWbHVy2OeFLcGvmXH7vJkrr8kcGr04f967ctrv6ajlB31zG7s ; 20171122 ; subDT >									
//	        < g9tUW2RKStnNZ06nak44cFhjoNl9fXPRo95Ia91zJd6Zq4vs93gXldsQSG77b2Yr >									
//	        < 8U2n3FgAeq6Nn9Z8UN8PrYGh1EuU0iP6uS4MGt4vdihQaWh0REIm8bV659sPOke9 >									
//	        < u =="0.000000000000000001" ; [ 000030754033075.000000000000000000 ; 000030764414633.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B74EEE2BB75EC577 >									
//	    < PI_YU_ROMA ; Line_3106 ; R7544j162R78848lP2Y26MdO5aR9Z87iELO5P9Hu6O9A1ie84 ; 20171122 ; subDT >									
//	        < 6KmL8fd1Qw4X4MZ29q294R2WyxKQu9wjU62egoT9aawA2rZd0tvHcQ657r6Dy0a7 >									
//	        < 3MmE4rqV8re4Ku27hc67Pj85UuVKxInF4C8WFY6oS6155jxPUXWPSVJ8vVW7f0w4 >									
//	        < u =="0.000000000000000001" ; [ 000030764414633.000000000000000000 ; 000030775757663.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B75EC577B7701456 >									
//	    < PI_YU_ROMA ; Line_3107 ; 9W8dlA645i56SwQArIH88i4PZ56k9Nwh7GP689p9ONZfMjZJr ; 20171122 ; subDT >									
//	        < 8Fv314xyjsgt2m7pv4Z9D7026AWMe85UG2dChMfciA8uhs6u2330oZXlz6F52Lj8 >									
//	        < YSNivpM0yFgbb769Ec11hEd58mhd1UyeNY7Y0BvI9q1EQ2uSKJ4erT95SqI17k6c >									
//	        < u =="0.000000000000000001" ; [ 000030775757663.000000000000000000 ; 000030788188962.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7701456B7830C50 >									
//	    < PI_YU_ROMA ; Line_3108 ; P805sruW2Cp6DwNV29Ez3ajQIQeUGS41G0lJ002G7EYQ2yJNt ; 20171122 ; subDT >									
//	        < 4I6BFQQr95P9oNI90EPr7C98QLX7E5to30sF261aOU2R147h50aU5n9L9k0n90Z5 >									
//	        < iC4Jcw8OH3Cb6JRXlqNkBi1vWHYez9Z5NRDjmT8CeV53l6Y5Z0vePnAv4qa5234E >									
//	        < u =="0.000000000000000001" ; [ 000030788188962.000000000000000000 ; 000030802682983.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7830C50B7992A0A >									
//	    < PI_YU_ROMA ; Line_3109 ; o8924QPEhr5H0mfoM4Y3u41zfBqJ4qDbqi851MP7P7RW1JuJw ; 20171122 ; subDT >									
//	        < oQONb1KPz6Q841x8K73sM8hHO5uaV7O3NG1KC70FNWUBh8o5HrmBonQ7ykccM6X7 >									
//	        < ZeNpiGTFwHKC8Q4EvkbB9i4NT7Qz6SmSfTW4GtNY40OA4s4k0fy7C9ZxqSa2wlHG >									
//	        < u =="0.000000000000000001" ; [ 000030802682983.000000000000000000 ; 000030808821229.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7992A0AB7A287CA >									
//	    < PI_YU_ROMA ; Line_3110 ; 9GgbL0ZCyRxfnFiy51Cx23D9scNB9038U6T0Qq9advlbj4xA0 ; 20171122 ; subDT >									
//	        < qvZUl6RgQYj5n9IwET1tI1bM6FOniXkP2dXpE96T724j56J8C89gcACqk273P04z >									
//	        < I5yxVz3gckuAA508fR2Ii8sYI9gMFwi3jqRKZ8368TJ1y5L5vGPftgi0c7Ys21Bf >									
//	        < u =="0.000000000000000001" ; [ 000030808821229.000000000000000000 ; 000030815966003.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7A287CAB7AD6EB8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3111 à 3120									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3111 ; 6q4dgHf37cuKylzh6DSOnbxzup3FUcuAt05k68No8TbEWe4zd ; 20171122 ; subDT >									
//	        < 79k60OU2ea2g9zPw8IVgeyar21tPD0GDZen5X887L8O87A1FZP5uGBU9ZIuCGZ7i >									
//	        < VZ0QOw7w8g7g19Ub0wmlmDKG5M8cQN9IaSPgPKFSb1Mx9XC396iJ65k63ZvmTuT5 >									
//	        < u =="0.000000000000000001" ; [ 000030815966003.000000000000000000 ; 000030823542922.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7AD6EB8B7B8FE74 >									
//	    < PI_YU_ROMA ; Line_3112 ; EZqmI4O2oSGvlGF765294713G54zw18Y9V49TPhxStRGcrTE5 ; 20171122 ; subDT >									
//	        < 4OixfX5ixJA1L0N1S9qPdCE3uw36YAs7Jh15X8R2WKMYDJUVw0iRVIGFXbIWX5uu >									
//	        < FMNHU14yXp8aY612dow02u6nP0j76yU6ggBWrHdF2i6jERNe1qUJ0fgg13IZ1vOf >									
//	        < u =="0.000000000000000001" ; [ 000030823542922.000000000000000000 ; 000030829275555.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7B8FE74B7C1BDC3 >									
//	    < PI_YU_ROMA ; Line_3113 ; al774k8Vkh2fcm5aW8WRWtqzSQGUXE9NVceOyBJvvvlWPN1G3 ; 20171122 ; subDT >									
//	        < l90q68ye3Kay646aaX1d4OEz0R5V2N2bh2d0p2XpEV7ZSNuxI799vJcWhCc1QM2y >									
//	        < P0a4Lx5YqA1tb550h7154Iz0uo05i7C17m1IK1650o8y3A4Z472PH223W4i00h2w >									
//	        < u =="0.000000000000000001" ; [ 000030829275555.000000000000000000 ; 000030835856362.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7C1BDC3B7CBC864 >									
//	    < PI_YU_ROMA ; Line_3114 ; CqQ8uNNAqdt2WTrK125Ga4U2Lnbs250p78433368J87Ql970t ; 20171122 ; subDT >									
//	        < 0k3cH7yE74rUIfz7ZlhI9yOq025Dm0jdLDyN44aBME5GT9gXhtTYhv8ezJ8yAuk1 >									
//	        < 1nCg4B4tA2olbo3p7qD5T84Zcomf6G7xjmAjB5yxQQupGuxYrZiyH5j5kS8vK53b >									
//	        < u =="0.000000000000000001" ; [ 000030835856362.000000000000000000 ; 000030849020194.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7CBC864B7DFDE83 >									
//	    < PI_YU_ROMA ; Line_3115 ; hUcs2c3iL00B65W4gqFYfW13e26CE8C4oXZNP3B4WcAuSwWp4 ; 20171122 ; subDT >									
//	        < L1ja05J9O9OKtCYLBc7Y2OMR0O5Bfp4P4GR7T5C48045oTVzN60M8v2Pz26P1FbK >									
//	        < 05b8r2G34E89MI3rK1W0FpIVnOHU95IP56dm3pJq8YRz0H8yrtt9SUN169hu496r >									
//	        < u =="0.000000000000000001" ; [ 000030849020194.000000000000000000 ; 000030858797735.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7DFDE83B7EEC9DD >									
//	    < PI_YU_ROMA ; Line_3116 ; Z4ZOgR2uh0156ChO9lAJbNN1vVvoeE3UII8wY61DuD5nwcV3n ; 20171122 ; subDT >									
//	        < 8QB9y9p9JsP919zGlPU5wve9z8ZpwbZN21aDF9b9ZV1YPY0Yi4b84SYCi52Y7KB7 >									
//	        < Oqx4Gjexju9D4i9f3fSfA013vD9Ku9zrJF4F4D0p15Lk7XhB5hIX2mgkWh4Aym3s >									
//	        < u =="0.000000000000000001" ; [ 000030858797735.000000000000000000 ; 000030866197186.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7EEC9DDB7FA1446 >									
//	    < PI_YU_ROMA ; Line_3117 ; rG1bI5BIWELu81eUcMfI4GMQNR7ZN4uA824z0fx95w8Szxptd ; 20171122 ; subDT >									
//	        < 15ZR8VwqjMdSNHenE03PS0Cs775Eb4eDWeY7LV12685H6357s1Rj4gW31jtDSNa9 >									
//	        < 22iU40YIf8P56UzM526zQvjKl797yg2rv1F6yC7Oi265cYQa08s23S6eR73G0n5B >									
//	        < u =="0.000000000000000001" ; [ 000030866197186.000000000000000000 ; 000030878161384.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B7FA1446B80C55CA >									
//	    < PI_YU_ROMA ; Line_3118 ; 5vW9oDNNyp5pDSCWBrvPh95C2aw8lRH5a66zkXdM032Uu9155 ; 20171122 ; subDT >									
//	        < 48SXyyXg8Z0kLejA7eyx6Ml1izoA536qkRjw5KD5Zg7vmkCtRnrh11qlDYWHjw1c >									
//	        < h9LCbS9e9sXXWtGvSNWlCsbb8907J33N19lwUHyQoW417k1E8Nm0d2IBuV132S52 >									
//	        < u =="0.000000000000000001" ; [ 000030878161384.000000000000000000 ; 000030887123883.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B80C55CAB81A02C4 >									
//	    < PI_YU_ROMA ; Line_3119 ; 7s6MxNrLRa4471r34lZ0Z12TiKyyHUwfGtKPdhq03Dt9FD54X ; 20171122 ; subDT >									
//	        < go6hYrKMsvDxnJNzXEVUn8qrV6455UeG6OjZ5rbavbzQ39EGM0045REwo4v36hBA >									
//	        < dO131hES6BKo3c8VX0VlkCJe73c34OY68vGFu945RE7y59RkM8Wuja5pK3B9rG70 >									
//	        < u =="0.000000000000000001" ; [ 000030887123883.000000000000000000 ; 000030892509995.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B81A02C4B8223AB7 >									
//	    < PI_YU_ROMA ; Line_3120 ; qS7C71gWGCAM12RMNZujqeNL1Yy7VG9J83095yaR0ZVWKe87c ; 20171122 ; subDT >									
//	        < R9hp8di2DUFl703Fc9wC3V61WQQwt5uGWOI0T3wFV8Td9HTSdrIo9V4bO5xq6F88 >									
//	        < rMSl3Sd4Gh836qOpEjS2uYA87UXwNRe9139i4pgLOnKGX917Fw86kC4dRT4Dfgif >									
//	        < u =="0.000000000000000001" ; [ 000030892509995.000000000000000000 ; 000030902628727.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8223AB7B831AB58 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3121 à 3130									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3121 ; ZIEXCs1S1QlWW22GlIiw4Bc3lxfgG11Iu6qeoEBRP6jCqejy9 ; 20171122 ; subDT >									
//	        < 82K3AJ47P77a3KEWY77RLc59vlxzyyaX745F3Tth7S660wl7237vdR8DZS9yX00w >									
//	        < q66EBe1L5C8DfC4JjfX9KYpZjphR0jF9t9I5uGiRVv6EA57B7jR4PiHM1WI44MMX >									
//	        < u =="0.000000000000000001" ; [ 000030902628727.000000000000000000 ; 000030914527659.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B831AB58B843D35D >									
//	    < PI_YU_ROMA ; Line_3122 ; Fff67PpY414KLVX2XnbxL1359kV10tK8A6TjE6t8E3XgM8W0x ; 20171122 ; subDT >									
//	        < Tm1OSaV0u5270i6iO7ARPm9iK16F1B1jX30h9TmXk3aiZoIFpAOfm1U4upVJb4VH >									
//	        < 3yDu9123193Y26YWy0SqIS483T60yk4612d5jYE620jo4o9grNE5AR8JEGw0Cff5 >									
//	        < u =="0.000000000000000001" ; [ 000030914527659.000000000000000000 ; 000030925142296.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B843D35DB85405B5 >									
//	    < PI_YU_ROMA ; Line_3123 ; n859vrBGX8KUa9Hjs3Xm883q9Oj1mzye1qJ48h3vSaPc6hU2t ; 20171122 ; subDT >									
//	        < v1by72AuGPV91Z10kk643z1mrBk4q82lHRhTh96ibdOzKh47X046Wx1r0Mb2404A >									
//	        < Q10300fyKKu8Tf75G71xMoSa49h170f2nxyB4qUW5nmdJieJzEjuBv4vk97t5TlW >									
//	        < u =="0.000000000000000001" ; [ 000030925142296.000000000000000000 ; 000030933600726.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B85405B5B860EDC8 >									
//	    < PI_YU_ROMA ; Line_3124 ; ORjNKznOLCS815L9z73x1YQ92DVy8xk80c08zzJS1vZjkQnoH ; 20171122 ; subDT >									
//	        < 50tAImr9CT7G8sYrd6O72v7XKqsUg7UX8c7tmbs3Y4wVzs9qddtSZf464JTC9FDe >									
//	        < 24dIqq624mav0W7223e4MmxpsWz4W4Vh7X08GHgKWBq4CUpSJGhC95G3t28BGC2n >									
//	        < u =="0.000000000000000001" ; [ 000030933600726.000000000000000000 ; 000030947783901.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B860EDC8B8769216 >									
//	    < PI_YU_ROMA ; Line_3125 ; b58r4t53F7nx40zNd6O2y87rxwmcvKk6mw6x83ppX3dfzsijS ; 20171122 ; subDT >									
//	        < 61oajA4IxDa6JLtUBcdQsjN96gEAHsd7Y5nlLB4c4p9aYzm7CemwQ8fasj4Yb6dN >									
//	        < OxUn4JCeOPX49wlTb78qQIrzCZ6Gv1kdWYEdadHdo891ObaHorN2RdA6r4pGa4tc >									
//	        < u =="0.000000000000000001" ; [ 000030947783901.000000000000000000 ; 000030958867795.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8769216B8877BBB >									
//	    < PI_YU_ROMA ; Line_3126 ; osjN26Wsvk5w4niCGiTN1E6658KiJoRuse37x69e27PY7xh98 ; 20171122 ; subDT >									
//	        < ABvO1uqRb9ttDhV7b47m75xPR76pvZo9OaQhH7UJy7vD27Nzl267y9fh68VgQlXE >									
//	        < Kx5kNtLm0ng16obLeOUU7251z1Ybw3xWUbRz82nt89aaTuvR12GPDbp101jU333G >									
//	        < u =="0.000000000000000001" ; [ 000030958867795.000000000000000000 ; 000030966532010.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8877BBBB8932D91 >									
//	    < PI_YU_ROMA ; Line_3127 ; POEPq8LGgLaXZ8Z19N7p6f7pvrA1Wt11P1v0cq00y0I5J9S8z ; 20171122 ; subDT >									
//	        < 9UgROb532GhEwLqGEgJ4Y0E7w3hHEj5TSbJnqC728vG2oi22558A0v6Rg1671Cel >									
//	        < Q2s3Uh47m5105Aj28mEt60YX0ayyOda3xJ933PqVNxQWK0A0Hw6R0uiB9ba4iUIj >									
//	        < u =="0.000000000000000001" ; [ 000030966532010.000000000000000000 ; 000030977185400.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8932D91B8A36F0C >									
//	    < PI_YU_ROMA ; Line_3128 ; B0PK479Mv3737K2X4eDGuJIBr786Bg9F9Br47Y7Ap8RGN82E5 ; 20171122 ; subDT >									
//	        < hf6Dv3opPxs3Lbs9XZD49glQACS29o83FsQuQ7bGM8T88DI3kF2JLWTl9rC75DWo >									
//	        < 9FK59b3ql12LjW290uimrs063z085Q32vjVI84Pb3Lk6NkPL7q22W2XEUs7oMzLk >									
//	        < u =="0.000000000000000001" ; [ 000030977185400.000000000000000000 ; 000030984331081.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8A36F0CB8AE5654 >									
//	    < PI_YU_ROMA ; Line_3129 ; 9378440Sa42805jTD6xuVBvA3RPdOBxNd8AN19i5lvPjPayPA ; 20171122 ; subDT >									
//	        < Yn2OdIAFBh0G9h98P189i2Ac7u8l8M5e19IdnGLn7l5514mofuGD2zPsz34yG355 >									
//	        < k05zN7BzJW4Q2oauO9ak8rlu4k9In2BgOK1Aj2QTDq77D1vnfcw9x8a08RL52XWM >									
//	        < u =="0.000000000000000001" ; [ 000030984331081.000000000000000000 ; 000030992731706.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8AE5654B8BB27D2 >									
//	    < PI_YU_ROMA ; Line_3130 ; 8YbvQQXx2Pn6I6YWhVQ8dY72dJ4VWyBPJ39E18whu449Tw94P ; 20171122 ; subDT >									
//	        < wR64IkC85dty88gVV1Ks5Fq2zUAx3tfmo9zKRiwZa4ioGCmMiBXkPNIPjJi9LH7a >									
//	        < sg4o16ktii12VWdN0BnTQC9hf3T1e74iWkhRoUGce2it4D5FTEp0oJ2ex2W51dxI >									
//	        < u =="0.000000000000000001" ; [ 000030992731706.000000000000000000 ; 000031002903611.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8BB27D2B8CAAD39 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3131 à 3140									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3131 ; Vswhn04e1m6VK652mstH8sdXKLFll1FtvIqXK36Lslxpy509H ; 20171122 ; subDT >									
//	        < 2keyaxL5oJ0PrHETe443q40R2NFbiGM8oqMs1lS5CT847nV65Ce6mmd7L3JQGfNS >									
//	        < 6j090H6j118fN49sc46Iy2217djCxvMKQnko3BG1sGu4lp3qwX9LXw04v7f0lIW0 >									
//	        < u =="0.000000000000000001" ; [ 000031002903611.000000000000000000 ; 000031009398563.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8CAAD39B8D49650 >									
//	    < PI_YU_ROMA ; Line_3132 ; 0eqo634AB8FCaHaH9jXni4va5es0LPRxMXc62jHxRI2wk3tR0 ; 20171122 ; subDT >									
//	        < 3JD1s93jgU934f8aL01n87oqab5zBR18p80Jz01J8Ih08Zo2zm65zS9TG2toqqwi >									
//	        < VNF0frjO0ZPF6p4x2vau7I7VNLgpDz02PQ0bBstCLL8Ski53lrqfpt32nMFsTNoN >									
//	        < u =="0.000000000000000001" ; [ 000031009398563.000000000000000000 ; 000031022105577.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8D49650B8E7F9FD >									
//	    < PI_YU_ROMA ; Line_3133 ; R0xNt3az1kVaA3o2r29CVMp0213xI1fCTd3evj8lPweqwr961 ; 20171122 ; subDT >									
//	        < 5q9V4c3n6p2HDssg93E5E7by2mulxp9A3qI8Nh8Y8XV2hrA9B391fpiEB7a1kboI >									
//	        < 7kcU0CoE12pxDweH1yvuZsy3ndGk18m4c4h74i4v376dy0TPr51q00zVGKOz6exs >									
//	        < u =="0.000000000000000001" ; [ 000031022105577.000000000000000000 ; 000031034322692.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8E7F9FDB8FA9E4D >									
//	    < PI_YU_ROMA ; Line_3134 ; JZU8PP3DM1Kac0MqLqdZ902B24U8g9Hp9YE7N8l6c79NHGhbx ; 20171122 ; subDT >									
//	        < X09prVwDR3Y59a9578CDfnDmVFm3K89k3F2rM3zChZFW5zR4v1K79JM6Y40jdk8B >									
//	        < 3s1dm1672fn38HrX3rW90O9IF21z20y0W052J7t7fUOuBGU1753b3L9gjoV7y8q4 >									
//	        < u =="0.000000000000000001" ; [ 000031034322692.000000000000000000 ; 000031044463068.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B8FA9E4DB90A1762 >									
//	    < PI_YU_ROMA ; Line_3135 ; j1KJ5K3qK1Gjfom4W6aNg9717YFI8nr5jlGFG8er0XM3100n4 ; 20171122 ; subDT >									
//	        < OzUR6G4g6e3hRJzT7338n0HB2y5B1t5l7FEqx0wk91KUaS0dNDZEGJ08Y53JxdB6 >									
//	        < 9e8ZtZ7HLEkOuf7Ga4wgn60a7598Zva5gt7PP7AQyyuUtB0ruP2nxBYX92v73lxs >									
//	        < u =="0.000000000000000001" ; [ 000031044463068.000000000000000000 ; 000031051483829.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B90A1762B914CDDE >									
//	    < PI_YU_ROMA ; Line_3136 ; Emc1MRh4dQzk237g10CoSRBloNpq59FORc4YG0D855FeYBk2G ; 20171122 ; subDT >									
//	        < 1eM6u340t3Lm2mZeVLXazUStpDr8N455j00u1m7Y9R9c1ZRNcodVOvVfz19P7Ry3 >									
//	        < 4yazbzMvsrx1Uz9k62rQ2g7h1Yp73E5o0hH5N5q35b02E7P695oi9jRSrEF3rmEK >									
//	        < u =="0.000000000000000001" ; [ 000031051483829.000000000000000000 ; 000031056957021.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B914CDDEB91D27D6 >									
//	    < PI_YU_ROMA ; Line_3137 ; cxPR7EvkWfu1AUxXl2MiatCDkjH1V7D4VR1yR65cYF09KD1TV ; 20171122 ; subDT >									
//	        < 3hrcmmv3PMgqPuRY2x25c9vpL9ibrPp94od7Z22Xz2LxNP8RrTPQf473gM8lj9EA >									
//	        < VecDlr2m3Jrcr1g5Kv4F5D65TM8Cea1HO30KV2davX9TkBuq0inkSUJDtEATF4kJ >									
//	        < u =="0.000000000000000001" ; [ 000031056957021.000000000000000000 ; 000031063885759.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B91D27D6B927BA5F >									
//	    < PI_YU_ROMA ; Line_3138 ; Ff0kcV0vM9wLg8p45x9z1jfCFWV5Cs5PDdN5Uy4kmheTcNd7h ; 20171122 ; subDT >									
//	        < 6YbU54OF78GI19CJjfn657111GRSVTX7yW9320l24T7ZBBv0nrpV57OM8NPAeEab >									
//	        < I55e46XRcKb25Dvpy2VBExCE2xA67wAigj4fny6rw7QBdIWGk1VbNNXMCF59fW4A >									
//	        < u =="0.000000000000000001" ; [ 000031063885759.000000000000000000 ; 000031074397126.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B927BA5FB937C460 >									
//	    < PI_YU_ROMA ; Line_3139 ; zwysB4e0BZfq05OMIT53ul6S5oUeTs3FV9s90A0zPSgmW8ut9 ; 20171122 ; subDT >									
//	        < u82C8l3N78rlSBuQU55n3U6qDDoOw416363MMXZ8E3FfuL7MW35ksD5DoD0uV9mO >									
//	        < vmWj7qJom49u0W94rRhK741MaOY189nL76YNv3l28KAs89t7q9n78zXnI29I1Fpr >									
//	        < u =="0.000000000000000001" ; [ 000031074397126.000000000000000000 ; 000031084226848.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B937C460B946C41C >									
//	    < PI_YU_ROMA ; Line_3140 ; dB92trRSA96eEb9wT0K563e95K7Y09h6DK0G4Xq9KRXUFwqFe ; 20171122 ; subDT >									
//	        < w76jf8WRzwVOz0R630s0oe6Ub5Kpu0texcP962XS89ld14cCltXT9xAfOC85IXyu >									
//	        < j8fcBhYJq64Psej97iAcBl95GZ5rEZP317UC5Wd8b8Endk693j51vV7H3gT2g1bX >									
//	        < u =="0.000000000000000001" ; [ 000031084226848.000000000000000000 ; 000031089953659.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B946C41CB94F8125 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3141 à 3150									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3141 ; 6J7WhKdYLj5FXQdy8KI1ZXzLl7c6H9kH230o6QKFelA34AM7T ; 20171122 ; subDT >									
//	        < E02iQO19237B35b3wy5FOZuB2Wjf5b00W4Oj61QYN9Us34U3r2UP2Pl6cP8S23W2 >									
//	        < 6eEQBg994sbQA16pPQAmvXe6bHbw4PKVTLz0YHYfr028Mbn5u9vQp880UiG94701 >									
//	        < u =="0.000000000000000001" ; [ 000031089953659.000000000000000000 ; 000031102328681.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B94F8125B9626324 >									
//	    < PI_YU_ROMA ; Line_3142 ; 7GuZ8HwBXWxshIvkBPwC14Z2095id080435c94wDu9cS1elL0 ; 20171122 ; subDT >									
//	        < 6kx95hY1Z8NFS6xytnP6U1GH98I65TIEQHlzDI1F56ju3yC0Ey8viXEmuHTaB4og >									
//	        < 5i3i6bx3wMjMkQyb04dos84qliTWL9K9Opo50wpTqK3B87Sg6yGPBBElvD7969xO >									
//	        < u =="0.000000000000000001" ; [ 000031102328681.000000000000000000 ; 000031108402095.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9626324B96BA791 >									
//	    < PI_YU_ROMA ; Line_3143 ; dYVaFlHDCpr600NL3qs9fuz6M5g2UD1YhdmLSJq8F0tlM6WWS ; 20171122 ; subDT >									
//	        < a7871F035dib04mkiyi27DE8MFnm2wjbEA1y77y2xL6FiTOZOpj21jF2Xm77XbpL >									
//	        < WMmg2qzJwCnR5S8yxFY7Qtlrqdls2249sOG05a908ii0Rk48hrbPIF5464G7cVAP >									
//	        < u =="0.000000000000000001" ; [ 000031108402095.000000000000000000 ; 000031115380491.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B96BA791B9764D81 >									
//	    < PI_YU_ROMA ; Line_3144 ; 23iH7LvUEJea43j1GSJfbu6A44jjE1399oh3EB948VFYc8JJ2 ; 20171122 ; subDT >									
//	        < JFYsya18d6mY9XDP18hieOw43N2S2okH4RiP4CkaJLSR4vM3VQrS9PL86K95n1Vs >									
//	        < 1o3EfRq6t98pVlh6g779wX1PnK3A35SjlZlD3iCg91QqogY9Qz4Oxm4eK5ycj4bg >									
//	        < u =="0.000000000000000001" ; [ 000031115380491.000000000000000000 ; 000031122822692.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9764D81B981A89D >									
//	    < PI_YU_ROMA ; Line_3145 ; SN73U9tW0l253l49XSdhg44Vp0girmfkW65RU2154W1DF916O ; 20171122 ; subDT >									
//	        < v8t8uaY7NIi2bhRsImCKoa7Nzun042Iwn62yW1yitCQH4700t1RMFbr2o9NuiU7l >									
//	        < K884R3I32b2nwe47xsDg4i4liV1166X1100b80K7gor892b4A21E02Y6Zc2tX6bB >									
//	        < u =="0.000000000000000001" ; [ 000031122822692.000000000000000000 ; 000031134414972.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B981A89DB99358D9 >									
//	    < PI_YU_ROMA ; Line_3146 ; 4UJmIQBROSkDJ8X0PkrcxiNKx6Mv0zE5VOqc08f8ri2r10g0q ; 20171122 ; subDT >									
//	        < f8vgjp9zJ9lyKKb2LOT3q215hbk2nMi1mJ6yWJ1c54iQ3bJ9JxWh3GlkzH188uFY >									
//	        < gU6C9XNr4fN47Ru4hy2zjI4a0YXDQU2xm9ICxUIe1DB8WM5w9kviI66I94dR876n >									
//	        < u =="0.000000000000000001" ; [ 000031134414972.000000000000000000 ; 000031139937975.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B99358D9B99BC645 >									
//	    < PI_YU_ROMA ; Line_3147 ; T0f39NK0JGepPSwHaG5nd66R1xcEk5A2hqt644NTQqy1XvECB ; 20171122 ; subDT >									
//	        < C0M407GziWs6ao50Yfq80wtsaq1S1FxT6565iL5ZON738h5NLp3FjF9Pgjmu19H1 >									
//	        < 2N14bG6c32sWep6227VYp37PP3gEoIKel517O8svxTL6xWG4a46gUs38U7WvdYae >									
//	        < u =="0.000000000000000001" ; [ 000031139937975.000000000000000000 ; 000031148951116.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B99BC645B9A98707 >									
//	    < PI_YU_ROMA ; Line_3148 ; A9EL7yQdbq5uu53de1NvUzyO68vQVc8y6pgSW0F9y1x2vhLLQ ; 20171122 ; subDT >									
//	        < 8fSHKW77JO7xlTST7uf38X485fbEyxnSY65p3LWRonyTjCU7b1Z8598Ds45aVM4F >									
//	        < Xkq5q5f913RktKmlsCE80NG0qA69a7UF6tV703gg32OVM7Ujdf6piP7TOjp1W5yj >									
//	        < u =="0.000000000000000001" ; [ 000031148951116.000000000000000000 ; 000031160839010.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9A98707B9BBAABD >									
//	    < PI_YU_ROMA ; Line_3149 ; FZ5CYkl6dJsVomt8ph0DNGGK3whp99bi3crkAt662J6eZjPoQ ; 20171122 ; subDT >									
//	        < RNzkffYBO6fEbyMjO643msDl2MFOEUp4iSbpI2ZXv3Ch03f82I242qPw7o2V304S >									
//	        < FsIv2TE0B48e1i4GNI62FG8e180q52JOj8gge10iQh2jWHQNxnlR716TBqL9HjP2 >									
//	        < u =="0.000000000000000001" ; [ 000031160839010.000000000000000000 ; 000031169990436.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9BBAABDB9C9A183 >									
//	    < PI_YU_ROMA ; Line_3150 ; x0NV9SxW42Fb847KM919otug54ntPq8F91wWw8LTz5F9j80HH ; 20171122 ; subDT >									
//	        < oow7aFG7oxOt9S2r30Z842Pl70Y51Xo1HbNbcas7Jj3q5g02FORvou7939739dLV >									
//	        < J8iFz9v07pf25nj4i01GYQ1E6IAE07vqXvEspnG9l1CRI4IKaZSnJwocwBXdzmw4 >									
//	        < u =="0.000000000000000001" ; [ 000031169990436.000000000000000000 ; 000031175241602.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9C9A183B9D1A4C0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3151 à 3160									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3151 ; zqGtUE8H6U2P7ut7otyURcFbS4lM4MCKnetwkZcq2IpxeY058 ; 20171122 ; subDT >									
//	        < S892sJ8321C94zM6YA3It3F15l1hJ7A76bwYoNS19Hmu3uuf1be83OazPWOWO1iY >									
//	        < bQR9n0x7w1RGLM36G2bbekkblj0sKwd56vI5aAu9F2VcxgI6vK1mm9z4h13LOr7k >									
//	        < u =="0.000000000000000001" ; [ 000031175241602.000000000000000000 ; 000031182418922.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9D1A4C0B9DC9864 >									
//	    < PI_YU_ROMA ; Line_3152 ; 05mY5KgkKV7z4720LJy5CZfw10i2uBohmhhJxg10Zc9S0TmA2 ; 20171122 ; subDT >									
//	        < e6f3y98l2Pl18Ron29UT29uRvBbOcj8sgR3Q8KyUTD52uUyp6YWEqWE8Higg5CCT >									
//	        < Ik3n3E97HT8Mzt03V1W0rHB52oM0dAj5652HB697y97d17102rP92lbFLXz15dIg >									
//	        < u =="0.000000000000000001" ; [ 000031182418922.000000000000000000 ; 000031190091645.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9DC9864B9E84D8C >									
//	    < PI_YU_ROMA ; Line_3153 ; vrcGYc2d1yUYG60IYgE6kJMMCJDF6WL1w1eS86U9o6zV0Rzya ; 20171122 ; subDT >									
//	        < 4Kr3v3N47tg6603sk9iYCzZtVgng5j94tp7Ok83oUD5Y1x09Ll6uAqOMuKp2Z262 >									
//	        < 2TT5Og07lG2YJc8Rmg6ijNIYjuQ10j8kL7wG04j3iEtX42nvzc92GzYIuDR1YOUb >									
//	        < u =="0.000000000000000001" ; [ 000031190091645.000000000000000000 ; 000031205003016.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9E84D8CB9FF0E4D >									
//	    < PI_YU_ROMA ; Line_3154 ; Oa88293NzMnpAwf4pPKk48yl559uiu122zu9cibwdlD71m3zV ; 20171122 ; subDT >									
//	        < 719T929AF0FIrjW66L4GPWJCxfUcf3GVgxfAYAp529iYjQg6n1Mwuc6BuIIZFeXA >									
//	        < W089Fu1AqlFOW24ykNwI2xqb85G1nZGiaLR98DsBx33IhV5rC43TBgsmAH687j9d >									
//	        < u =="0.000000000000000001" ; [ 000031205003016.000000000000000000 ; 000031211633038.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000B9FF0E4DBA092C27 >									
//	    < PI_YU_ROMA ; Line_3155 ; 625tXU79sYJ6mwwd4Udjj4N3sO9kPVuonPTWKjQ9uLNV96ZmO ; 20171122 ; subDT >									
//	        < d98GtZT7UB84hED5BX46FdbtILm95O8045XZeu7VJyLe0vsRDcK64kF90Ybsfhpf >									
//	        < J6poBh9ZZ7c4oJt1jPp76mu2O7hc7Q7LeMZn9kArshAupcv8keWNUWyJ6IVf2ci5 >									
//	        < u =="0.000000000000000001" ; [ 000031211633038.000000000000000000 ; 000031223987141.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA092C27BA1C05FA >									
//	    < PI_YU_ROMA ; Line_3156 ; boCF3vkQnen0UWeAqw0XCoW74NB2834xPfQIih9SEc4501Hbq ; 20171122 ; subDT >									
//	        < m63wTjm59E2bv0wP0UA1i9jA5400cNsUFH9klp036MThRH028I64222tlJ5JALsM >									
//	        < 85EuVaCN7h7CxgH99BtxOTSzf55K59fVsiN9V63wN5tf0EmA7Hi11M2d29PAzB4Z >									
//	        < u =="0.000000000000000001" ; [ 000031223987141.000000000000000000 ; 000031229146055.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA1C05FABA23E52D >									
//	    < PI_YU_ROMA ; Line_3157 ; w44ZJ6190sGVj1taOPd361M3FjSWujZiIiag65wELoi6C0C0F ; 20171122 ; subDT >									
//	        < L7A7B9i7kyfe4sPJ8908NBiF7Jjbzk63lqYz3nikiX2zkq00teK7Pdj17Ym4w1HB >									
//	        < cehoq0y8Qz0Nn6o05rv46yX1Yu12E131TOd8JY1WiiuVfQA8SxVSo1Jx708QO6SU >									
//	        < u =="0.000000000000000001" ; [ 000031229146055.000000000000000000 ; 000031241482736.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA23E52DBA36B831 >									
//	    < PI_YU_ROMA ; Line_3158 ; E9z855DMGJtzrcYK92kl9wMsBgi5Rxpe682w6Hpis38K59bZH ; 20171122 ; subDT >									
//	        < 22TD27ogXbg41wKmeb6zd29M8CneVS6NbXPkNMY0WyNgSV4oA47HN8UE3k8T0Mri >									
//	        < WQFyvwhUH5ig1yUu37610X9374SexNeTM0jh4Zy6Y7GH7rG7Dic7v1FD37T95R1P >									
//	        < u =="0.000000000000000001" ; [ 000031241482736.000000000000000000 ; 000031253228498.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA36B831BA48A461 >									
//	    < PI_YU_ROMA ; Line_3159 ; xOVEDW8S3CuCMN2d3ZKr18v64RvzI94i680kVaGlgbPD8Q9qU ; 20171122 ; subDT >									
//	        < 01OWYS2qXqostA97ExV8z39vA48rgn1Rz4DBQlFG4xIYkBcud0rEh9cou1160YN1 >									
//	        < 02UFAp3AE3G9o686738cQ3TPqW9oX4oVpP2b58s8iP7133UeTPCcHb1fCMZF36U7 >									
//	        < u =="0.000000000000000001" ; [ 000031253228498.000000000000000000 ; 000031263801725.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA48A461BA58C68C >									
//	    < PI_YU_ROMA ; Line_3160 ; dmT2sfv05743OInBx25WL4j5C8wNEKs61bmfi5A9crsYs8uOk ; 20171122 ; subDT >									
//	        < 5Q5Nr0Q5YAsIfp9TfhDyV6bhs5L5PI8N8uS4c3XuGHkl2Pe7hPnyT3iT8Sbo7q1G >									
//	        < Y2uRiAAfXnM6f22ZJN57e5x783I6nB1C54ontfxGq5KbOC6lPvx90rBTLB8r8Bw7 >									
//	        < u =="0.000000000000000001" ; [ 000031263801725.000000000000000000 ; 000031268955003.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA58C68CBA60A38C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3161 à 3170									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3161 ; 38J8C2Ec4i7MumaZXJWen9tOUZg399D23Q8Y2329u3m82CBW6 ; 20171122 ; subDT >									
//	        < 01h55I847H9S2xV5hNFuOUvp31Ff83ZxMm3715wdUIr69T63FQiVAzehW4qDiz91 >									
//	        < dl61RQFI40NoP7wn59MepZZ3h4AN5zRt09aj0fApbrYo3iD1YsOf9KhCDKN3zjAw >									
//	        < u =="0.000000000000000001" ; [ 000031268955003.000000000000000000 ; 000031282755464.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA60A38CBA75B25A >									
//	    < PI_YU_ROMA ; Line_3162 ; MRykQF5tYI67i7XiW1V461F7Z9X3xe3ZYe7zZ7iR6x4GEIhKW ; 20171122 ; subDT >									
//	        < K56AU0wI154FM2U3u9F3LiXgJ0ehhQ5kvNCF00h8Yz6K6ETe7C5g17m64e6Hyt0a >									
//	        < YAlguy3w0446LriboEP09PrSUk05i1S754yJ5cqF9VAye85rD4vtE7qtLvNapn3Q >									
//	        < u =="0.000000000000000001" ; [ 000031282755464.000000000000000000 ; 000031295045081.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA75B25ABA8872FC >									
//	    < PI_YU_ROMA ; Line_3163 ; SthzMpUZc6UB304cTpt7DF1mAfVEE41oZoV1kgL891Q9zRajV ; 20171122 ; subDT >									
//	        < NK3ffaE2e9p8CMn85dqbmzTYJ7Uy9MU118DduoU99CEv5mGq1G2xY4pI7O9uF8uz >									
//	        < CBX659l99LkfF4a43OVP0Y3ss7Lx0qrR6tW284V6gx6B69wQf86y7gwdBSuSjF3A >									
//	        < u =="0.000000000000000001" ; [ 000031295045081.000000000000000000 ; 000031308724796.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA8872FCBA9D529F >									
//	    < PI_YU_ROMA ; Line_3164 ; KE6rvcP7dR517rU4o8E0g6rjePY2oC6VsFqtHtVio5SoH0X9o ; 20171122 ; subDT >									
//	        < 8nkr27Ce113hi5d6Z9o2O28rOAcR6GV6B8pF84Gf3LJWSO1yy6RhqJFKcy7g7AN8 >									
//	        < scj34zYow88wfht5FLdas219K8LKA79h87GJ7h8lZXkl8914R40pRhJG93m4p5kI >									
//	        < u =="0.000000000000000001" ; [ 000031308724796.000000000000000000 ; 000031316075617.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BA9D529FBAA88A09 >									
//	    < PI_YU_ROMA ; Line_3165 ; 61yb9FvRXBBHmK0mVMfCymLcni1fbJJ267BKCG5667LSv0ZH8 ; 20171122 ; subDT >									
//	        < cFSj17O98NKzs81xqS3w70uY3F2jA20FBx54hUwpKsGMK69G5Hj06MvHV1i9S9ve >									
//	        < L3r3VtK397Ygh3ydACVBYEOSune6d5jJUcCMbd71V4CCFh0Rj16V5f100AIhS8OI >									
//	        < u =="0.000000000000000001" ; [ 000031316075617.000000000000000000 ; 000031325599655.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BAA88A09BAB7125D >									
//	    < PI_YU_ROMA ; Line_3166 ; 216DnUGlAIydqrzkxuI5kH59w3Bk3APf56snHT4Le9vb3Fc73 ; 20171122 ; subDT >									
//	        < vty84tmOgt3moy0l51SoX3ow8SgG57WCtW3XR6dCs5J897eG1S65DCV9ADr7MtNM >									
//	        < 594sgxTM7sQtg327ht7538hoN2LxGp2rmyD3039Vc8N8fvf2YsVOcpuv8jtvmdG6 >									
//	        < u =="0.000000000000000001" ; [ 000031325599655.000000000000000000 ; 000031337578759.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BAB7125DBAC959B3 >									
//	    < PI_YU_ROMA ; Line_3167 ; Qe4pY9PSL77QoQeR3601vniGJJo7nqL5MN2P1vX3Z55R2qEk0 ; 20171122 ; subDT >									
//	        < GgnFHSHQ10Bdo7WVCr58kADq3Ogjy683979ohye3p9cA9s1jGHMmNJ07K3Q3FhFr >									
//	        < Aw6ClwvN9557B4G9vLb1l5u6ggHFudH919545I490295pPblSE8c9NDax5ivjXvk >									
//	        < u =="0.000000000000000001" ; [ 000031337578759.000000000000000000 ; 000031350263151.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BAC959B3BADCB48B >									
//	    < PI_YU_ROMA ; Line_3168 ; V7r017oKV29KS9rd775J9j01XqDW1E43tFta4S5qPT4aSO623 ; 20171122 ; subDT >									
//	        < 35PRzRs6V9iV95y7z9ZBYJPPZUo8JGVck5AYLQ4n5x945g2p7DRq2HYx5VgF1588 >									
//	        < 76412Xg0gIqvih809EFx6sa9p3zZ02X4rg0L5oDT29O2Rs9v6a6Wv5w45ie6qBxh >									
//	        < u =="0.000000000000000001" ; [ 000031350263151.000000000000000000 ; 000031358270786.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BADCB48BBAE8EC86 >									
//	    < PI_YU_ROMA ; Line_3169 ; 06Au2iIGEaLr5XOu93FcdGkYW6y8J3hu7Oa22PF799yDSfAN5 ; 20171122 ; subDT >									
//	        < V4HGXwbiUHmtPSfkDXr5a7v7640rd10uF4ABG8IW0Xe7UidIRUTP5Qy7NuTvBEEP >									
//	        < 5v3si46ep7Gr912vl0J0k04M4s5827uMGHF7Ep0j32eOZ0jSk0O7Z6jAK92y1ajK >									
//	        < u =="0.000000000000000001" ; [ 000031358270786.000000000000000000 ; 000031373187751.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BAE8EC86BAFFAF77 >									
//	    < PI_YU_ROMA ; Line_3170 ; ifi5w9B4Wc4nDk3JEy17t234suR0AdW21OuQ4HNw1seh50ruP ; 20171122 ; subDT >									
//	        < 3U8S8ilILvAM50NV6Ak1gaW3yCj7PYOwaOCL92m1oNK54U72v42EivA5x2t428si >									
//	        < 2w82Z62dapiQH33k8P49ANrSovE0pz4FSe9gm3CtztBR85Aur2D474RD4n06SiDM >									
//	        < u =="0.000000000000000001" ; [ 000031373187751.000000000000000000 ; 000031382370619.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BAFFAF77BB0DB285 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3171 à 3180									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3171 ; X0m4zJdbl2I7HkpaZy6m21mC0z7RZE9WM90VN4Z9187D1jCJu ; 20171122 ; subDT >									
//	        < 895n2EgN3GekKir5mQptKvjGYRQQ4bWM0T38S2d6X4maV36Qr7I2i1xE03W3DCL7 >									
//	        < 5y52Zkz32C4xUxGVpQMqk3UNItp2EBm53AdJD4nULUqKvZwPA5PR52Esys5h6tsD >									
//	        < u =="0.000000000000000001" ; [ 000031382370619.000000000000000000 ; 000031394673461.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB0DB285BB207852 >									
//	    < PI_YU_ROMA ; Line_3172 ; lA2Lg9SW6p8zu0XhxClkXg238rUVypZ9UivC7ij4Eh4wAG77h ; 20171122 ; subDT >									
//	        < 8WOnY60CXivZ3jk39U77Dj1HY9609esFcA9WZBvyl49k81P0OhBy1fc3ICxFG52O >									
//	        < 9QAi0Js3kZraF0L8QyM51H7F3HrDMBnUR48G45AY5ILgh9pgmd474HUz13oP4d16 >									
//	        < u =="0.000000000000000001" ; [ 000031394673461.000000000000000000 ; 000031407343153.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB207852BB33CD6B >									
//	    < PI_YU_ROMA ; Line_3173 ; 23k8VW5Fi9U1qMK0OiEk238Fir8JdzIn64S6nz4D3O5DX7GA7 ; 20171122 ; subDT >									
//	        < 24eJTpVavfD8D30Xy0S9d2m623fkgBBOEnJrQB7n1y9CfST00H47sBL5tII65P0V >									
//	        < q83mFRF8Vp5DtwIyY5CO60rXgwXfK2CkF0B590WAip0L6023FFW3hMg2S1P9HU1z >									
//	        < u =="0.000000000000000001" ; [ 000031407343153.000000000000000000 ; 000031419987236.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB33CD6BBB471883 >									
//	    < PI_YU_ROMA ; Line_3174 ; 34fe0qVamEEV9f5IiQRD21z6f8RADAZ2k1Xp3258p4w5VAJM2 ; 20171122 ; subDT >									
//	        < 3GJN8hYd4XRWqU2nPol6oXCnGhIRyPJ71sAvb3mYftad9M7ha05x7CqptkYMAr3z >									
//	        < AA8VdHk065r9D1dtYF111wl2Ff7bNsj81bZYl8BY4NtGFwj2XevNseFX8oIakSN5 >									
//	        < u =="0.000000000000000001" ; [ 000031419987236.000000000000000000 ; 000031434406002.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB471883BB5D18D8 >									
//	    < PI_YU_ROMA ; Line_3175 ; cj04nZ1rdK1KwULERlWftJr7uE7lK4llu2TqGhD4MXl5YeLh8 ; 20171122 ; subDT >									
//	        < rWlmr8lDgdj3ZS93ZrJfEH1H38h2g23Lej3nnYwt13gyYFn6Z8C4660D0a0wM3nm >									
//	        < z92OpdJH9yQx637hE9w74ST6hJ6TwQGpi42WuFH9YmhibLE5jtTtlAhGFuv46b90 >									
//	        < u =="0.000000000000000001" ; [ 000031434406002.000000000000000000 ; 000031442680746.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB5D18D8BB69B92A >									
//	    < PI_YU_ROMA ; Line_3176 ; B49Je3F181z3DW7F81YM7xDA1Jy0zepN4dyQ0kLq29CNr4dG3 ; 20171122 ; subDT >									
//	        < Bu5nrPBEwpNIPR1oFa3920ML0wt43CdL24lxYcH2f6o2mJ0kXiVX923anK7L6c90 >									
//	        < Q9c1sSV4c07mQ8n2WLPQcfjjVo1KnL3Q3KPH9V1Hn6yM7Q1pn8UmO9VajHeAMBH0 >									
//	        < u =="0.000000000000000001" ; [ 000031442680746.000000000000000000 ; 000031451583532.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB69B92ABB774ED1 >									
//	    < PI_YU_ROMA ; Line_3177 ; I0JrxiNEYsvl0Ce1v5392zc6zU2PBSRV5Ty9Vx2cuq9sdQZEv ; 20171122 ; subDT >									
//	        < s11N16BEoEVrEoXr491M84v2LURE955eN7KZNU5u0laqEzlvL72rEAne1UwV0r4B >									
//	        < Ni15H66vB16EBOxT5rXyCLktfIHl9AFIg6TaJ1eV1u87Zh07547avSzE42NbvQMC >									
//	        < u =="0.000000000000000001" ; [ 000031451583532.000000000000000000 ; 000031464437578.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB774ED1BB8AEBED >									
//	    < PI_YU_ROMA ; Line_3178 ; 3Z52h86QT3cynD8D36037QfbbRJvNvtT7XcJTQ059VzBag7Ga ; 20171122 ; subDT >									
//	        < eaQcbMgzXL7O1591i9Y8pwZrBr1QZucznDk8S72uwid73n12Go90POtZTA7go9xt >									
//	        < wKPzBl0hv2OI08JC5m1F16wF0EH16kjL23Oata3giq4191gp7Us581f00Pot0161 >									
//	        < u =="0.000000000000000001" ; [ 000031464437578.000000000000000000 ; 000031475330816.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB8AEBEDBB9B8B19 >									
//	    < PI_YU_ROMA ; Line_3179 ; Pmr2v77109sh6H7pY92P0Z4eB553OFX1mByD0ZwiQwT6KL8Yy ; 20171122 ; subDT >									
//	        < S8cx7H270P3gxhiQHrWRbAT4FGDjOv54F5MfK81MeikbV6xmP55rwQdu0g3lurFx >									
//	        < uSE862HT10Qqw049GF8o7kSuh2q4G24iu78oXQ53b87uxYSy5zJf551mu0CY1kIw >									
//	        < u =="0.000000000000000001" ; [ 000031475330816.000000000000000000 ; 000031487688656.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BB9B8B19BBAE6661 >									
//	    < PI_YU_ROMA ; Line_3180 ; 3P5KXe9d9SI5yLqR6APym0mhgv5zXc3oB2pj97Ddg4P8Hku7M ; 20171122 ; subDT >									
//	        < x069fZh37J6wT1e7bTUUk7h8v2F8480fk3mNaCE4sG96635HUaTfXjOFF068fCu0 >									
//	        < 9L4m4n4QgjDvlGNA4s8zyd66bCllN6Wi5VNr75hnteksVe75lrmwZn21TS2Q9Rc2 >									
//	        < u =="0.000000000000000001" ; [ 000031487688656.000000000000000000 ; 000031493225541.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BBAE6661BBB6D93A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3181 à 3190									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3181 ; D5SCy2Dua87Ik1IbCS0fR73pQXlc3d8m6qrxY86pjceQroL83 ; 20171122 ; subDT >									
//	        < SRw2Nd97eC2n4gJ0VEn5TAvgLR46uR1i4kg3Flxc1cV0C5agbRJP6zB0981flAdg >									
//	        < RrZEu1960KTIzsP9zqT7UDVXR8T7CHil8oGh3M1y4E0Y4FlhyA4B0fFA2bjrN9PL >									
//	        < u =="0.000000000000000001" ; [ 000031493225541.000000000000000000 ; 000031504930025.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BBB6D93ABBC8B54A >									
//	    < PI_YU_ROMA ; Line_3182 ; J28fDtotP19tTnHR7J17m8WnHnw4HH607vA0b8QaUb2550Hc5 ; 20171122 ; subDT >									
//	        < p3C19V36wyuu5v9fU8WHi34Zd7BE2sq5Y13Lx4E9Bly8TFvlmc16s86256CNaaY9 >									
//	        < UdXjFrfXbz5N2Lt56Fl2T73nR83fPCmxQc7l44To6jQXX2BqcfmEbSD0jh29U3Qo >									
//	        < u =="0.000000000000000001" ; [ 000031504930025.000000000000000000 ; 000031518840119.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BBC8B54ABBDDEEEB >									
//	    < PI_YU_ROMA ; Line_3183 ; mWS79sc0kmY259VgBgLig7Quo4XNB1nn6zvSC2C0sWmfG4TMp ; 20171122 ; subDT >									
//	        < ojTQ4JYo2I05zquuaoFRp44mTcU4D8qbzQRGFt3fj2X0TC8t2ZbQJI2vUiE0rDTj >									
//	        < 87399EkdGq2Ef9JL1AgaDf3Pex2Sm1044oP5D674CRo4m0crXNrdQCW8g8so0bWM >									
//	        < u =="0.000000000000000001" ; [ 000031518840119.000000000000000000 ; 000031533018757.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BBDDEEEBBBF39173 >									
//	    < PI_YU_ROMA ; Line_3184 ; 1F69HA14h1YGere3IQENFceV19UT10Hq9Pqz2k96hTHz215X7 ; 20171122 ; subDT >									
//	        < hWs0w1wb6OhZ1guNusF3fNBvg9Mv74DIWhKdezExsgUW05flEcG3l20NDkr8s5i8 >									
//	        < 2pzxjg7X4Iqj0psw7AXScacNU9h95Yk74Z6QleCPD5o221xAi84520BYFbiNM08N >									
//	        < u =="0.000000000000000001" ; [ 000031533018757.000000000000000000 ; 000031541619383.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BBF39173BC00B112 >									
//	    < PI_YU_ROMA ; Line_3185 ; 2849AZ3vw6p1ufvj7N5UxUswh4JBYHO1qkmnRBh62v6ZIduIa ; 20171122 ; subDT >									
//	        < jeFk33dq940QFE4ut658niK32N025G93TkhBaHst6Nvut7Edx4nXCzt43MbgcOUo >									
//	        < pFbw21Wg60UXGL147bm7GW9pk640CDT13sTDdo5Nf5eN6iWUhkio5x43W9pxK0OM >									
//	        < u =="0.000000000000000001" ; [ 000031541619383.000000000000000000 ; 000031547712218.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC00B112BC09FD15 >									
//	    < PI_YU_ROMA ; Line_3186 ; r07bELFc1o9mR5UEStlJl0jG36rVtZ15u0Po7vEAWX75QuY98 ; 20171122 ; subDT >									
//	        < 8fN7lq7af10xntq3x0zS1UqMF8iOpizBx52PM4IJu0w3r93bSI1161631RXhL4Vo >									
//	        < tA66hHJ6ljF1U3y6tYJ5rODw54645e6Ip52G810851fjkDkdWVXLmOm2NAILKngb >									
//	        < u =="0.000000000000000001" ; [ 000031547712218.000000000000000000 ; 000031554993865.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC09FD15BC15197A >									
//	    < PI_YU_ROMA ; Line_3187 ; cLu0jt6b7tm9wYm8K5If2m09bQ9551zk129Oo9kXfVhdfo2yX ; 20171122 ; subDT >									
//	        < 7Tyk4VAj4RvkltPJK7Fl27a3X5eu7iq0MYt5A6pVn494m775o40Bs1Ih0heXamX7 >									
//	        < rqS24oJ319n8o4jny2uPJN9ib0Ezr5GhqB58I6f31alcA1DyK4Rj5AiAeq2Q6IMh >									
//	        < u =="0.000000000000000001" ; [ 000031554993865.000000000000000000 ; 000031564231697.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC15197ABC233201 >									
//	    < PI_YU_ROMA ; Line_3188 ; 1UCaqJkH9H119C3ozTmEk7zP6PSLCaeD88kZU292XA8ER5ab8 ; 20171122 ; subDT >									
//	        < 8k895G3WY04J3mI578788RD99iuNiXku8QbXwXzlo21oEZTbN99lfATO1tEF8vOw >									
//	        < f73uhNDYni3gTg098a8SA5XBS99sg47aSPj9ZBo8Hy26xTL8kX1ObU7ow3Pyp6Hv >									
//	        < u =="0.000000000000000001" ; [ 000031564231697.000000000000000000 ; 000031576371162.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC233201BC35B7FC >									
//	    < PI_YU_ROMA ; Line_3189 ; H0UN61Zoiw3g45JDJztZ7EBq1i75kIM6mm1fAo1FWb99gPH8H ; 20171122 ; subDT >									
//	        < x77mWJl6WF9Uh4fdOMF6WB3hJO9x34MJXQjO4PTz91VfMAqI6d8a86Pd90c4XsI6 >									
//	        < t8q2bMZ7TtiN9jP9U3k81V5Th39g0z1m1K47xnC8sy992Cj363y8ekfTKVSmiD9p >									
//	        < u =="0.000000000000000001" ; [ 000031576371162.000000000000000000 ; 000031584296808.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC35B7FCBC41CFF0 >									
//	    < PI_YU_ROMA ; Line_3190 ; d8Zb3F61X8p67g9R4PJiD5VCrXU6f32lB1fy3665C316y88Tl ; 20171122 ; subDT >									
//	        < 0LEo7m5GUz470ZNge5hr5X9Cm08USUzY096Oe9wO9D40TqGJ3o22SGXY09044OAY >									
//	        < Cs2gl14e9i4Ex1Ry8BSnFd0UGB16y1iWNk46908tZMKWxvOrXie43YD3loYQg33p >									
//	        < u =="0.000000000000000001" ; [ 000031584296808.000000000000000000 ; 000031593435631.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC41CFF0BC4FC1CB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3191 à 3200									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3191 ; 6qqxmPHa59E2hL292re9CTC98Ps6soYAmi38xZj9IgQIXRQgo ; 20171122 ; subDT >									
//	        < J1EkSNUmlYx19JY11TzGNbt256FCWXUrr3CC3107DWx71vqQichidWvmA9SYSScL >									
//	        < 4GpfTFQtu88ic693XOIyy3nOv0Jw8jZTloFHRLySha773H819I75Tb3r4UG39uk3 >									
//	        < u =="0.000000000000000001" ; [ 000031593435631.000000000000000000 ; 000031599690518.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC4FC1CBBC594D1B >									
//	    < PI_YU_ROMA ; Line_3192 ; 2IkX6PLhk23w50Db9Y759LJM7BAopkL5l8pLzGXjF6476eZ6a ; 20171122 ; subDT >									
//	        < K43LUk96ygd9w2g2C7nUW8exwbAoS3KD9CE9u393Cj8ksbpZ8WV5v363SRz18yHD >									
//	        < 4uM2UvQg0mT0Al4S2r7k65GydOU37amne55UtZe0nuLy72Sa1okg924BL30I6828 >									
//	        < u =="0.000000000000000001" ; [ 000031599690518.000000000000000000 ; 000031605216571.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC594D1BBC61BBB9 >									
//	    < PI_YU_ROMA ; Line_3193 ; 1b0ScqnmBl40Ox1Q4b7v0s4v41GCw1gHxHeEEZYRCRZ7fX6N6 ; 20171122 ; subDT >									
//	        < OtOfkRVKIxB18uVltpQ0iGQoiENM25Ww435n7G495C7672h7TKfY7r6brzXa2vvS >									
//	        < U3m8rT5cTcDdOFVX9bE402r19ZqEdF5R35U2w3oH2MvS4cftp7eM2UhJ4eW9k1Z9 >									
//	        < u =="0.000000000000000001" ; [ 000031605216571.000000000000000000 ; 000031612775204.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC61BBB9BC6D4450 >									
//	    < PI_YU_ROMA ; Line_3194 ; 8g97Nj4nl11WIgajZcgnVFAl81o90i4u0988i546r5l1x158y ; 20171122 ; subDT >									
//	        < 3XZQLn009t62FhIarbI344GVxdMg4oj33H34W4LSr0oa7t1iO95S2AjV0g2nO4bL >									
//	        < yeP3lP4vVH27lPgdZMDaFiYAemUj7bjNC6hNsExg1qwF7f2a40wjI1Vk351G09BK >									
//	        < u =="0.000000000000000001" ; [ 000031612775204.000000000000000000 ; 000031626128471.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC6D4450BC81A46F >									
//	    < PI_YU_ROMA ; Line_3195 ; 247Zo8IJUi38fpN2S21dg6IR1XoXXX0KrkG8p5xF4GqAb2g80 ; 20171122 ; subDT >									
//	        < 35yE6MZyc3wgT78ff804mdt3JWqzSvvmV452yDj721C1FjU11xac2vICPc7Ngx7W >									
//	        < D4VN1ze7qA9L221jn601e3ud620qKo96V96GiS6cKKqx49at2M5sF4Fq3nkeT12A >									
//	        < u =="0.000000000000000001" ; [ 000031626128471.000000000000000000 ; 000031635791279.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC81A46FBC9062F7 >									
//	    < PI_YU_ROMA ; Line_3196 ; qabyQI2B56TT17wUVq33OvWOvjOo93lYc7wP4vRPEWl0zjeZO ; 20171122 ; subDT >									
//	        < krA1x3ACP3ENwJzE9f985Har7P90545xu227sFxpK4R6HsPb2oQ8UlSBowEF20lp >									
//	        < 6Pf6lLw5voqQ52480KMj92OKLgCPvWoAK5yzeZ4sy0thKDGlF10c7937Rag2JsuR >									
//	        < u =="0.000000000000000001" ; [ 000031635791279.000000000000000000 ; 000031646060208.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BC9062F7BCA00E44 >									
//	    < PI_YU_ROMA ; Line_3197 ; hRvy5FmOw7xTIka2ngZW1ms1Eo5nXRqRmhal5mPbFTwN42x4B ; 20171122 ; subDT >									
//	        < 0l8Uc96ebxY3GECO28946OvB3sK981zChk78E9OQ1y44v61650k0Ti6j9289d945 >									
//	        < Z69FDVXKcI4reiAe8BF6OYTeLpf4Sga5APXh4JpVwM6XkBomdV1Yd65dK5I1O11o >									
//	        < u =="0.000000000000000001" ; [ 000031646060208.000000000000000000 ; 000031653193820.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BCA00E44BCAAF0D6 >									
//	    < PI_YU_ROMA ; Line_3198 ; C5r7Ftz85c1zXRBzblSAq9n11MpW7p8HyW11pjE9DYy2R4JEP ; 20171122 ; subDT >									
//	        < Y5n67ZDzzm8wgkV6h7L9AawwdoCNtNl1Ut9j1CaJrybcxy60lOpVmZ59JXn7dIuN >									
//	        < YTF24S581vc1EjGwD0H53MV6Ntgt4gonnDmtoqb17uw7ku5gukrjV0wMSWBrBFOD >									
//	        < u =="0.000000000000000001" ; [ 000031653193820.000000000000000000 ; 000031665659286.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BCAAF0D6BCBDF628 >									
//	    < PI_YU_ROMA ; Line_3199 ; 4ef66mo36Ap293mX0YM69ypaegq2Y01eKlwEc57zhUI7S2X8V ; 20171122 ; subDT >									
//	        < cn6V6Ao9zO5Pc75k79myq2JTYzxYN1e9yfnsf6520m91zKevRb514OPYGi5C0479 >									
//	        < p3D4KvbCtcZwQkOse57ipltI8a2fVhEOP1014iumk75qMzukq3212XM87Tn3tCj6 >									
//	        < u =="0.000000000000000001" ; [ 000031665659286.000000000000000000 ; 000031678927134.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BCBDF628BCD234E9 >									
//	    < PI_YU_ROMA ; Line_3200 ; U414u6rz8OK8wd6703R2z70313Y3Be83ZPvPbcB4EN62B75Qk ; 20171122 ; subDT >									
//	        < 65U7IhjTEsJ4BZql61db4O90ocqkm9YPz2Ye25snt8t5wZUuR88ij14U6reYzUV0 >									
//	        < PkmUPxPKDWnG9ntckuwXnH02o4BhRb66lpSvFES3ww8944XmGP7B0Ot6r259lp2j >									
//	        < u =="0.000000000000000001" ; [ 000031678927134.000000000000000000 ; 000031692194292.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BCD234E9BCE67365 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3201 à 3210									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3201 ; 7Yx2mfK88PNB2PrmO4SW3dxZksPt9q6rOKgAKMutDSadaeY7h ; 20171122 ; subDT >									
//	        < 4BxhI0GNAQx9u9LakDiYV5WezXNUTzD8cTiXar6wsYmc3YH6V9pltb5ldC8n6agx >									
//	        < 46a81QgJiWh0aD88VU8kxpg0YkalT78F4B9et5E8j3So0L2Q27h05IfJljyxYXsS >									
//	        < u =="0.000000000000000001" ; [ 000031692194292.000000000000000000 ; 000031703545443.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BCE67365BCF7C570 >									
//	    < PI_YU_ROMA ; Line_3202 ; M6hzzJY585syGY9OJ43mM0Iq15QtK8nDh0kBE0Lo237RJDcpi ; 20171122 ; subDT >									
//	        < TvUx7Mh253j35hJiblT06j200P95siUKr965oNqc7zI6zLzpfn7efJIZQFh26sh5 >									
//	        < S9Y6tk0CuPWmyOx1VebOwR13I6kXV0F7Y45fNn1CR9hF04E75rZ4d4oM59P0wqp0 >									
//	        < u =="0.000000000000000001" ; [ 000031703545443.000000000000000000 ; 000031712874963.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BCF7C570BD0601C8 >									
//	    < PI_YU_ROMA ; Line_3203 ; ilz1HDALffPXGeAZ8Y5H4A7Gj0Dzfl24616ocDg0mH7x567UV ; 20171122 ; subDT >									
//	        < 849S881y2Qo5eppz4ODLVjRskSK3sdV9516lwiIN0v8mt40C9jzpi12JWnIiPz8Y >									
//	        < YB6hLHV2gzzai9bKXdTFcK8KYTtgW2jQ5Ng7uFuuzO5Vm9R8Cko7xEq0JO4ntjM5 >									
//	        < u =="0.000000000000000001" ; [ 000031712874963.000000000000000000 ; 000031722266380.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD0601C8BD14564E >									
//	    < PI_YU_ROMA ; Line_3204 ; W5M1uLqA3ATG6XGcnhyFpM1W44UNTc2k6Z9sCza9STwjHDcH2 ; 20171122 ; subDT >									
//	        < 8uy627E4fm3mfK3O674Z6nZ0m3W4R3SyoKLaBbWd2e60E85ASMXk6131Dq38Syd5 >									
//	        < TMBwfgquvfc7ob5VwSQEw7RYlMkOSOZrSHiU3GbQ9P6ti3B8pl0gzSX4ld8nIj80 >									
//	        < u =="0.000000000000000001" ; [ 000031722266380.000000000000000000 ; 000031732087964.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD14564EBD2352DC >									
//	    < PI_YU_ROMA ; Line_3205 ; 18O5n5RZinZ8r2i0qCXglU59gpL4aZQXP8xMIngz8tp9bbM1l ; 20171122 ; subDT >									
//	        < Y8VXkxDGzj409ro5mpnONCiJOgpw7HvE2J21927eSH6s40sgns4y4dI5w99y20WU >									
//	        < xF3P19sBP8qB34zKGtpTidx3aA7ue5rq3lYQNv2KJY6I1ngMK9tF7kmtf8Tu66tb >									
//	        < u =="0.000000000000000001" ; [ 000031732087964.000000000000000000 ; 000031742100645.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD2352DCBD329A10 >									
//	    < PI_YU_ROMA ; Line_3206 ; 0X5P2m5hyee4B7ZDv55k7Q4FITydGAZw1g0NjLDrkah77irou ; 20171122 ; subDT >									
//	        < Y0DFgYSmCrEmbx5c95jdkN19g94SHzYrL2s8sQg4RY94dXP4Y14d65Xyw0r844w2 >									
//	        < P3lgiiQTWxoXm3URBOcP2MrpZ0TV3259MmAZqk56vO0PALXqwEeTaSF0BROeLDfG >									
//	        < u =="0.000000000000000001" ; [ 000031742100645.000000000000000000 ; 000031749461705.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD329A10BD3DD57A >									
//	    < PI_YU_ROMA ; Line_3207 ; vkgFV40jBHW3wLs06n2IBe4JLE4V07tdl4q3P60BvTqVMQh18 ; 20171122 ; subDT >									
//	        < sr4v3xP6NZ9El86sdV1zec5Nzvd8C955Q9SfXpzs3ZFU0D6As1xf4A7l19U4xYP5 >									
//	        < dm9oJXjl6dVq1W8iVxfEcrpfY96w4yM7410DHLE1UkpIvErzqGnekN3o6QG4R2Wr >									
//	        < u =="0.000000000000000001" ; [ 000031749461705.000000000000000000 ; 000031763634360.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD3DD57ABD5375AC >									
//	    < PI_YU_ROMA ; Line_3208 ; Hwx2f134D7x85D0oFMAwCJrnixS9mX3TE03v327oI4r69Y1Vx ; 20171122 ; subDT >									
//	        < JPGEI27sNItr47NsEGCq8q29Cp2t2YI9V9yx618ow0YktF3F7IEuR8lk5ctYHC3l >									
//	        < xN0b2rFS29SN4q3feip9ffaJEXs7CpsQ4rLLo319cu46K0LYPblEQdgXSCT1ADKu >									
//	        < u =="0.000000000000000001" ; [ 000031763634360.000000000000000000 ; 000031777528235.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD5375ACBD68A8F7 >									
//	    < PI_YU_ROMA ; Line_3209 ; 8J1tUvQ6xW5OPaX7ILIjcpdrZpCPLO2354HZTD1zvTtV2R3Y7 ; 20171122 ; subDT >									
//	        < 0v20hmk47U4zaVI7Ur47X625vJrd35NFQ5XJ4S27R7o9IowP51d81wp9DKA32o6U >									
//	        < 3w51bTkZ1viGLPbIDkp0s8cjWG6Hs4dYkc85h4H9GsG5WU5h8WmR7E3YkosrSd7I >									
//	        < u =="0.000000000000000001" ; [ 000031777528235.000000000000000000 ; 000031783258660.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD68A8F7BD71676A >									
//	    < PI_YU_ROMA ; Line_3210 ; 3sb3b307V4sg251Qwmv146R1q07wsnb2rKSjX2lTJI3C4R4vK ; 20171122 ; subDT >									
//	        < N6IuYfz77ui2qRNf0hE3JKP9UeSUD8fQD7wS0QUwOiG1Gj2As1noxo86q0N640bd >									
//	        < 7LqM7HoRgH8L4JJ7Tiom3QRJKd208GVXlGuop76roYYs6TFgFf5utjRdQ8x6XqOw >									
//	        < u =="0.000000000000000001" ; [ 000031783258660.000000000000000000 ; 000031793985436.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD71676ABD81C58F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3211 à 3220									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3211 ; ofHMQ24Pxw680s5OvmhXhOFq7f248ux48Gjhy313kPpCV4yn1 ; 20171122 ; subDT >									
//	        < R919Qw3gw5UG1eiyrW5O7SxR06HJ4Mhw87s2Sh7vOd0964hy9PhNhxYse768o5u0 >									
//	        < 71t8N1zZha85e9xua2bir3NeS9OM4nF4053KD02r8qvEG4U17lLh5J4R0zuRm2t4 >									
//	        < u =="0.000000000000000001" ; [ 000031793985436.000000000000000000 ; 000031801920486.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD81C58FBD8DE130 >									
//	    < PI_YU_ROMA ; Line_3212 ; mJ5TUQbxJ1H8c15d0yjDG0N7v62OWy1O50hWtF7SeJIOTaWqF ; 20171122 ; subDT >									
//	        < F519l4rR6rq8FkV205y3XL4hdHvbPVCL8fMfQx6Ko8lVKO74c097AxiyrS8J5sh6 >									
//	        < PUZ1uC5V2Ds8Ew8y5Jt83l03Lyfr4N1g93A7BVw5n4iif0imd6odEhR2taPv24wd >									
//	        < u =="0.000000000000000001" ; [ 000031801920486.000000000000000000 ; 000031814092828.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BD8DE130BDA07402 >									
//	    < PI_YU_ROMA ; Line_3213 ; 65uIfTRtoo15yfT6CK1KxiWqXnAK6M14M9CjHLLuMdc1lwQ9c ; 20171122 ; subDT >									
//	        < ImZ0Qxp5K0Ob8uxghEKxQFkuLHpa709Y8xC0jGPi8Eu4RC6t4rLo8CFViy0aYmYy >									
//	        < tv7HLHq68563rosWu0S3K90oYH25zl9egjB3Q4t2Jptae39571bIYmYFRBa3x96f >									
//	        < u =="0.000000000000000001" ; [ 000031814092828.000000000000000000 ; 000031820378670.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BDA07402BDAA0B6B >									
//	    < PI_YU_ROMA ; Line_3214 ; lo97Dz3MDK2A348XbE467ulvql4534MB94RDh6118nkam1De2 ; 20171122 ; subDT >									
//	        < 56C1V5Vp59I1hc5Rk35Rj7fXo53we9jHANZwFGS7iQwO58cZ49YQX4OCGdQ1C7N6 >									
//	        < uDl90k2PTyz5A08M94M14LSa8X8RGq9q360wgfjPm8HM55g46goy40C2vzB3J3tR >									
//	        < u =="0.000000000000000001" ; [ 000031820378670.000000000000000000 ; 000031829846601.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BDAA0B6BBDB87DD4 >									
//	    < PI_YU_ROMA ; Line_3215 ; zc47CLDK1Y705CRFjXx34DFoR6he7j93ztB4V3upK07Ar4I8s ; 20171122 ; subDT >									
//	        < Dz0b5ZqNAP3m15fuVJR744AQ7Fo0n5x2p6MEaEZSNjOgp9RYdPQrj7A7X27WP1TH >									
//	        < y3a8temuAqQ1E60do237u2d9WRJrHdyWm9NUAKMR1AvCkOtH73o1XC6P25Nmcf4u >									
//	        < u =="0.000000000000000001" ; [ 000031829846601.000000000000000000 ; 000031842422932.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BDB87DD4BDCBAE75 >									
//	    < PI_YU_ROMA ; Line_3216 ; GoNb2w1MD76umF31Z39mG4G7HK9V6U461H7IkT1m0Xlk4KfR2 ; 20171122 ; subDT >									
//	        < ZSQK23FZ1KYs2D7fAS4boyIwXvSlJ9H5Pdw2T0bHyR18aW4v9SC4CjvXBr9XF9qz >									
//	        < NFL77lWzxtejgsclJ4hkN5VEs4D07V1uALs5hMVHGSN0Ad2PwB80hrbdC0XRLE29 >									
//	        < u =="0.000000000000000001" ; [ 000031842422932.000000000000000000 ; 000031849848672.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BDCBAE75BDD70323 >									
//	    < PI_YU_ROMA ; Line_3217 ; 2fI0eSaY8jR46l4g2YrC30kfu0eMlwWb4455hthaRh11ni0VE ; 20171122 ; subDT >									
//	        < cZdc3f1Q7T4HePWP42t7x9F2PnysrM32igJI7cSnPv4iP6uE4wG13kIjBtKGl2pf >									
//	        < tVsMyMD0B2r072aTO97wKAFH58osi0lw8oSiX6Ye3xK2jn7W6BOZ7eYv563oU1Ga >									
//	        < u =="0.000000000000000001" ; [ 000031849848672.000000000000000000 ; 000031856852363.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BDD70323BDE1B2F4 >									
//	    < PI_YU_ROMA ; Line_3218 ; 6dN98Bqh2Z854w7k36Qyjrd46K1Uetu0K8W14BEh5Z0RASL5F ; 20171122 ; subDT >									
//	        < IgXz3WIe4oI85O2o2o4hqdc4qGpPACp7Awzv57SF7GJv1M49uM4SxVI14RQ2Np2p >									
//	        < 8NmsPEU539wjNepC1ZnBZhZzu3My4hs2s8snqLp4B20mjEc1KzR9gg5FMy6bn0qG >									
//	        < u =="0.000000000000000001" ; [ 000031856852363.000000000000000000 ; 000031867127534.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BDE1B2F4BDF160B1 >									
//	    < PI_YU_ROMA ; Line_3219 ; UU8P6Z5F2nU9lhg32lZaz4KWxHNKj5LR8waV5504avz11w08i ; 20171122 ; subDT >									
//	        < 8hOKneN14YNwLo96KiSzMm0mUGqEfR74h21GXN305aY67b53f31Z8Y0xfBtPxDWc >									
//	        < 4o3QXdbAyK176a6Ll677tC713N8909imqVu1CsIH8T2XY9zRDx1Rl2QmM1T6Tt5u >									
//	        < u =="0.000000000000000001" ; [ 000031867127534.000000000000000000 ; 000031877729731.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BDF160B1BE018E2D >									
//	    < PI_YU_ROMA ; Line_3220 ; 094xz915sJvC5s1hIl62u7KeM0rCyYyDP6VBU3Uf8i1hGQ9IL ; 20171122 ; subDT >									
//	        < 85xT3HP4ixFQaKcCR3059jfN38I5h8v3Bs5r0N7Ut3b8g8TazT0SP5kUm09azVc1 >									
//	        < CKUw2seG7SHeYBC3fE052MExc5zFWktzH069OAI8hRpz61kDmdtj9c5xWj45K3Kq >									
//	        < u =="0.000000000000000001" ; [ 000031877729731.000000000000000000 ; 000031886565710.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE018E2DBE0F09BB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3221 à 3230									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3221 ; T9r02d7ru7HiwEM9823davksVWv2IAGbSgPbdOJWert9jU1Mg ; 20171122 ; subDT >									
//	        < hoCF4tmee92NhyxFtUTHY24y09HMB7kP3M3yF1S76u1ta20kk46yjh69aIl2VH7s >									
//	        < QmTgNI24sW5368Qxvgrv7v1JWl0UxxY5RB3RXFcLMBZviEKvjzSjr4GN0kb7wH8d >									
//	        < u =="0.000000000000000001" ; [ 000031886565710.000000000000000000 ; 000031897797765.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE0F09BBBE202D40 >									
//	    < PI_YU_ROMA ; Line_3222 ; YfJM8XvO542Z08r9t614p29usY55ps44o8J7DDL8OKT570mGb ; 20171122 ; subDT >									
//	        < eXx6ncCoA8lbfpvgPO8qOo9R7kFJqP7x0603N739QFGXwcZ6kP2DvXZ5hhzU8qGG >									
//	        < JhC036W90v60S6AwlxrJ5pjpgJd6q1823Jn8BG8836djI7cUhiY9bq1SeRX92e1j >									
//	        < u =="0.000000000000000001" ; [ 000031897797765.000000000000000000 ; 000031912493638.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE202D40BE3699D3 >									
//	    < PI_YU_ROMA ; Line_3223 ; 8LRs84KOw5IOBa58A296Uj6uk67312vG7LNwAl6KxxQWmuz5n ; 20171122 ; subDT >									
//	        < cDIOtGP4hvQ8YJgMC547Q2OfYISzBfaI04Q5cU879BO838O7cfDR6F8VnxW99GMr >									
//	        < JFaOCZ5v9IT60jY62Z5HjLw8QHIV89sUDnMnYa0CoecP28DQo2rVx2mKNn3sNpqj >									
//	        < u =="0.000000000000000001" ; [ 000031912493638.000000000000000000 ; 000031926932291.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE3699D3BE4CA1ED >									
//	    < PI_YU_ROMA ; Line_3224 ; ZpyPbXEdJ8Q874GWh69GT8CNfsBdjO0W6VXBmo54JyAuV696X ; 20171122 ; subDT >									
//	        < GlNomnC7QZd98HVSdi1LZj7t51krrN6TN38imoyIJtUf8JRRSHS1hE6NFsB4Om58 >									
//	        < ZADXl0ZJ0bo7zs56sf6QJ709z0URey1oyyCUJ04Ya018Z4X9prF5Z73UxXie34b5 >									
//	        < u =="0.000000000000000001" ; [ 000031926932291.000000000000000000 ; 000031940602572.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE4CA1EDBE617DE1 >									
//	    < PI_YU_ROMA ; Line_3225 ; 9zM17aofSgDVhEKFZM86tA1Eb9SMb6L4ImvG1FnZYpW87V30A ; 20171122 ; subDT >									
//	        < Us8TXbFju31971D496Dsj6pCNS3yrLaWF1OZr09e8qQGctJVBnp8Wffy2BSs0Xrj >									
//	        < nJ79We12u7QsLQ06FzrnO89DrKJO19yOh27P1akv94YPfpXin8PinHabBh06ID5U >									
//	        < u =="0.000000000000000001" ; [ 000031940602572.000000000000000000 ; 000031953708499.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE617DE1BE757D61 >									
//	    < PI_YU_ROMA ; Line_3226 ; JnU2kh3eq17qkclod8k0YqNgx1HGWI63jRLj6PT3H2rP3bNK7 ; 20171122 ; subDT >									
//	        < ICfn8x1gUJw9paNA9eEG29CuZYq1R133bwDawhL2UdJ0S2z1wQryrc9xtr835Us2 >									
//	        < K25h8Gjq189tE618v6SiTo3Ya0hYAyf9b3RrrYzP38Tc2jZ5q3orJS31hqrokx41 >									
//	        < u =="0.000000000000000001" ; [ 000031953708499.000000000000000000 ; 000031958757071.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE757D61BE7D317B >									
//	    < PI_YU_ROMA ; Line_3227 ; mwadL0L7LJA1as94ZHR0bHD3D9hiXucW3U0sDp2p35p4e1F4O ; 20171122 ; subDT >									
//	        < sOox42ejgvOv4TYQ7CS6PTN0d7Fe81DDAeW150Cpuew19xQrRE8CMYKPCw2HUE5M >									
//	        < NKF4w7mE4u8T3k3WnpTz8p2f84cF0IXh4NUzb73hIp142Qnz8iodBg7rM52z9W5v >									
//	        < u =="0.000000000000000001" ; [ 000031958757071.000000000000000000 ; 000031965168601.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE7D317BBE86F9FC >									
//	    < PI_YU_ROMA ; Line_3228 ; 0ya0ng614K1494H0cPmx6MVn3nE0ynFO1DfI1A5cAdwWbyk5j ; 20171122 ; subDT >									
//	        < NMBfV7nNTk9QzVt4A7PgevUy34yT1B26S317660d4KkvdSk73cnF9xw6i3xHW1jq >									
//	        < gH23Zd90ML5xqlZ0SCn1e2C191mC1E1eyrKo483a5re17L3zX1FTtZly6GqEhVXf >									
//	        < u =="0.000000000000000001" ; [ 000031965168601.000000000000000000 ; 000031975267228.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE86F9FCBE9662C2 >									
//	    < PI_YU_ROMA ; Line_3229 ; 9Rdwayq5nxf9oy5KRMQS2AkXl4425CmUZjWAG3oYb5OQ6ZVRJ ; 20171122 ; subDT >									
//	        < INu719Re77uVLxbb2s33pUNJ9dKbh8N30D8DC29r9GlGocahvfRs6w17ybsf29V5 >									
//	        < hyyY3dDQ7yiS33bI99i3ug592Z4nfx624as96a5U5x0aJsK15tRaJTCN5CxVNST5 >									
//	        < u =="0.000000000000000001" ; [ 000031975267228.000000000000000000 ; 000031985098804.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BE9662C2BEA56338 >									
//	    < PI_YU_ROMA ; Line_3230 ; GKiIZva5CnK2jOCl4RYq960x211txAAhWBCY99TBLX61KE46X ; 20171122 ; subDT >									
//	        < I1Tu4oYdRJVRbMVuwY1LPIkQdEIONRVAUzJL2Q8o8pak1YC7YD51cfq048vCGmaE >									
//	        < hLbPzn3M5ewFHa8777ng6wusHj7hLlGtiez6l0imGkO2pdaz17ViAV4lVRsDlh3H >									
//	        < u =="0.000000000000000001" ; [ 000031985098804.000000000000000000 ; 000031994790338.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BEA56338BEB42CF9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3231 à 3240									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3231 ; 3vgJM6v3eXMkht2F3071wX4eH8RY91klD6EXtT4AFvbFLsijJ ; 20171122 ; subDT >									
//	        < zjNx2INI79WG8lA071Nf0z4Tb5M9HYZ7V33T96z6O62ZoolEeWhAmSEs34k9UgrW >									
//	        < K2u372v76nJqoK8f1YpfY1LWG5b6kR1emwvzllFKwTncCF6L5HdpA4rVt3209R6V >									
//	        < u =="0.000000000000000001" ; [ 000031994790338.000000000000000000 ; 000032007013729.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BEB42CF9BEC6D3BC >									
//	    < PI_YU_ROMA ; Line_3232 ; 0jiZu4C8mF4ObZK4UA0MS7wyjf4s3VYiaK1J57pq3DQLC722H ; 20171122 ; subDT >									
//	        < xWf2QaUX380z59h80rW2J7N48o44tFvNv17Df6wTmp8ljIM92jmW70ow3jXnxBef >									
//	        < g5AY9fHqy168lsrptmGAx48I438V1nKZ71ri01ipHZhBy9Dzx5hyr5xba7lLKU8V >									
//	        < u =="0.000000000000000001" ; [ 000032007013729.000000000000000000 ; 000032016353183.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BEC6D3BCBED513F6 >									
//	    < PI_YU_ROMA ; Line_3233 ; BOg0CpXyBOgmpNKS2y75MXU1l80Z43fd4uoen78H2KY5v8i5s ; 20171122 ; subDT >									
//	        < I5NMqw9226Lf6zQFcT67vA6i61MlIlrjgo97JJLdNaIX44t9xF9OF1t1IhKqScEe >									
//	        < Va0P45iId0xK29YxZ13moxg2HkB6MQu6lZ5KcLA7N1BBCUtBv1GHK2HILe9beN9E >									
//	        < u =="0.000000000000000001" ; [ 000032016353183.000000000000000000 ; 000032027706054.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BED513F6BEE666AD >									
//	    < PI_YU_ROMA ; Line_3234 ; yNnKDknzfKmfCPPFvUBdDT1gK0pRt2g6pOD4IpsUTJ1e2r8Y5 ; 20171122 ; subDT >									
//	        < ja73t027VYbTPUN80aaGEu7nzplt1X5hrkQOwsI9U0b2ZdU97tY7ziX1D5G2GmVk >									
//	        < NO67kg7F97ck6hOAj7260QyuC71F8156h490vOV5q76j03usBo0R41U1njV7grYo >									
//	        < u =="0.000000000000000001" ; [ 000032027706054.000000000000000000 ; 000032034514456.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BEE666ADBEF0CA35 >									
//	    < PI_YU_ROMA ; Line_3235 ; NVokWBI3Pa2I3VsKlJ9RlG4DEghDH5KSPHViKusLkzkZn2B9R ; 20171122 ; subDT >									
//	        < vdg0eE73z3P14615gXC36ipn2yhoytLH2k1231H1Jyqfhz0j6KXz9QoT0z0bJ2Z4 >									
//	        < U6CY3ZLH3fY2iBZj9M6M238R0EYaW05sKIx81NvZsA54Slm5f93D6VW0s7ei06Cs >									
//	        < u =="0.000000000000000001" ; [ 000032034514456.000000000000000000 ; 000032042634092.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BEF0CA35BEFD2DF1 >									
//	    < PI_YU_ROMA ; Line_3236 ; E0cZ8W672UqO1WCPu60rzKXCrK2xoBUCs45bW2xrSv9g9ey2R ; 20171122 ; subDT >									
//	        < S3gcOeD8L66YGQtK95d0T10O4wJswiRk1i11r0kN9aF8PcxU8C1muGjHb9rlxJN9 >									
//	        < jRWSv0Y9x0z69pDH2U7dsd41kCbzbwyr5n6Y3wcSB4280EzUd1ZmWqcGD2Wirj2S >									
//	        < u =="0.000000000000000001" ; [ 000032042634092.000000000000000000 ; 000032050047090.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BEFD2DF1BF087DA5 >									
//	    < PI_YU_ROMA ; Line_3237 ; 48AZ7I9nr8EWG1412KSa19h3yJb6kZW3n501eJA8RVQZTvUUM ; 20171122 ; subDT >									
//	        < 85mvfz4OS746ct9buqRd6pjG5ZZd8YaJfue9O2I4F84FNT72788ndmTOA1cQdJ8Q >									
//	        < 1aPWoVRvS4DvWU2ULP4rg74XFdpkpd1zCUAz1sr0545UnXy5ayLxlWmIp9Mg1K1s >									
//	        < u =="0.000000000000000001" ; [ 000032050047090.000000000000000000 ; 000032062136751.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF087DA5BF1AF02B >									
//	    < PI_YU_ROMA ; Line_3238 ; U5QrZs8F7L8wNNbtDOl3TyaV9hM9eBjvtvww2gV5ri0A5qg7x ; 20171122 ; subDT >									
//	        < jXSJW0KPrnlW73tD9C2roLyrEQhCHChZreiRIU17Al3i9b6ffSj5AU88eNc9xP3h >									
//	        < W4I7jS5P5M7zZg1Bg6483un5eI5WMh1ZO4M7sO31Jz4YBLL9wOk7K8Z710Z0Nd5c >									
//	        < u =="0.000000000000000001" ; [ 000032062136751.000000000000000000 ; 000032073967923.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF1AF02BBF2CFDB8 >									
//	    < PI_YU_ROMA ; Line_3239 ; UtvQH7ug7P75r4jzPqmq562H1IeqvNdnj09LL6BY8yo4g34ez ; 20171122 ; subDT >									
//	        < IxtX88oOI89eBC592Lg58L83GG56xhjl0SmbEB713tTjh4JQh5mW08upT2nLT4jv >									
//	        < 76r9UE2l05y7268LnprtN3P1A284PR7G7JS3W16l2O7bWAZCfX1j3XAX6Yya80gf >									
//	        < u =="0.000000000000000001" ; [ 000032073967923.000000000000000000 ; 000032085442967.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF2CFDB8BF3E8028 >									
//	    < PI_YU_ROMA ; Line_3240 ; 99jbQq0YKgfx43S91262NACYNG92Q5L6E1jQeE7OK8K3smS7x ; 20171122 ; subDT >									
//	        < 8m22PIq65ynVqs90u6ePehr6j0e2i6w90sIOidj2UIz3R7HY2S75d1UKXEhnLOfZ >									
//	        < 7GXpt1cRC4ZoR0SVl3XOem0qWv27GyDI7033n6ntw29yx2twdvmE458FlOOG5BRa >									
//	        < u =="0.000000000000000001" ; [ 000032085442967.000000000000000000 ; 000032093139780.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF3E8028BF4A3EBA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3241 à 3250									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3241 ; z3w1RTZ6AIoYuulH76im0m45so6Vat59y87WtQTH0B6Sj1Cos ; 20171122 ; subDT >									
//	        < kh4XjWDLJF8S0u55k87tH21d23jaKY7uYmdf7M7D9AvqMM9u7UmLBTJ5dZk0fxj0 >									
//	        < NzTb7qJebk44qQOOINA886ZPUP35oH8E5IH2GzCbOAD1Dve177sTukl2SbCB8Qme >									
//	        < u =="0.000000000000000001" ; [ 000032093139780.000000000000000000 ; 000032107463408.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF4A3EBABF6019E4 >									
//	    < PI_YU_ROMA ; Line_3242 ; 5T46wyzwHu82wdFd825rIiTrxPQn9MKmhSHRynJ61V7mGdohc ; 20171122 ; subDT >									
//	        < 24hCIc6f1ztLt9wEVQ5zpZ6mNGl56mUjGpdo7X4oy4XOEuxUw9buAwNDeyh4siCL >									
//	        < eiyZimHP5u1kE4URe1p7V91rTvYg1PE8rwgbemty8YtG0op745xjHQCQ60t4YdXb >									
//	        < u =="0.000000000000000001" ; [ 000032107463408.000000000000000000 ; 000032118003862.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF6019E4BF702F42 >									
//	    < PI_YU_ROMA ; Line_3243 ; 04r97CLsCCUqkC3SwXP39F9IdB90k6wjUho73D6KhUfHq8J9w ; 20171122 ; subDT >									
//	        < 63RjgpiC688QWpO85XEZQdRR1Uy8o57lIZ04a1KO0r4yBGDuU3V06h0aQK9J9F6E >									
//	        < 0gmo66S8vTHNi560Ej3y7M73JWDr9Txszi2dGGF5HxyC07f8RJWZY2HguTaZx5Jn >									
//	        < u =="0.000000000000000001" ; [ 000032118003862.000000000000000000 ; 000032132988878.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF702F42BF870CC7 >									
//	    < PI_YU_ROMA ; Line_3244 ; 1o4Hd378auS7xvimRlJNtti0b42q63p9N04K49541zOe99nVz ; 20171122 ; subDT >									
//	        < 4G9rASW689Ar9PWiev8MBgP0pNoS6SI9jDC98L0StGX2zATkeko76eXzdXDDVc0K >									
//	        < 4opwCa4Mm3YLMR76EikZ25Uo1r9P603Oq24RC3kCtK4I2R4K5gBE57dctSouL24N >									
//	        < u =="0.000000000000000001" ; [ 000032132988878.000000000000000000 ; 000032141111149.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF870CC7BF93718A >									
//	    < PI_YU_ROMA ; Line_3245 ; StFUYtPA5GF5XbzEMfM66EFXQsPjk5e26EggYevi5gwx54rnG ; 20171122 ; subDT >									
//	        < W5QLqkKtvLdISyOSN96D7qz149Nj3jyms92X075mVk1uol0m7r3pJcrvRupv0570 >									
//	        < B4zsQR0K2858y9e62LY9Z0CxO1zXQp08l8fY1wvUAbXm7M7m9cYp29p2gkYZLvNC >									
//	        < u =="0.000000000000000001" ; [ 000032141111149.000000000000000000 ; 000032150652880.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BF93718ABFA200C8 >									
//	    < PI_YU_ROMA ; Line_3246 ; 95A9Y2WbeFp3d586SYgufSHlkKjWr7Do273b27m54u9eEZLzI ; 20171122 ; subDT >									
//	        < lNl7M6vKU1OhWY47J19U5tSHpBwkCDlGQWVpZ76bLg19ejs01zClNK1RUgA0XnvK >									
//	        < g0M1LQx90Jc9B9asD2x8PpOk0F9t71epWkiSL4ovu0o1Vm7J7aIdImL6cmSzuW2S >									
//	        < u =="0.000000000000000001" ; [ 000032150652880.000000000000000000 ; 000032164119810.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BFA200C8BFB68D4D >									
//	    < PI_YU_ROMA ; Line_3247 ; hXN7doQpa1Ztcbev2CT3guDO7EX5W29o1dPus9m2EvOLU3V5O ; 20171122 ; subDT >									
//	        < kKgQ5EIfo9ct2X72SFQbB2jB4254id6SmjmQz3sP2azNz8yg3EL4Rtsh6DAB9QLd >									
//	        < BjwpnIPj53XW28sc1Q0T21Jt6845d4YZISN49e32ZgxDUXXB7Xm9Kde9yjCUKddz >									
//	        < u =="0.000000000000000001" ; [ 000032164119810.000000000000000000 ; 000032174385478.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BFB68D4DBFC63753 >									
//	    < PI_YU_ROMA ; Line_3248 ; Jc005kCV95LrJe0vw36N3QpjpCcwD398U0sufoDT9WO0428do ; 20171122 ; subDT >									
//	        < Md8tkc5V7apAcQ3ypNrTq1SHk7CCOvE680y7riV9T8GY3z8zVn4l9e98r271XyPs >									
//	        < b5GEBJUrIGuG3z15JkD0uZVY62qs7DTI50jyS9iZoB7AhBkcZ60O7NQ5c9R3C1Ci >									
//	        < u =="0.000000000000000001" ; [ 000032174385478.000000000000000000 ; 000032182673357.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BFC63753BFD2DCC7 >									
//	    < PI_YU_ROMA ; Line_3249 ; g5w7PtA3yDdLLIF3YIan6DpHML8G9I7VFc9k2OBRqP7914Y3H ; 20171122 ; subDT >									
//	        < e10FszaWP9v0E79EZ746gV2AN3wZ8MGjsFR6ElKPMmC8aD3fPMH321RANBQb43wu >									
//	        < tPgy8eW54e0l05QyU7FyC714LjEXYKrbjQfR5mNdV9VNq33R3htG7Hq01qb97t8J >									
//	        < u =="0.000000000000000001" ; [ 000032182673357.000000000000000000 ; 000032192341347.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BFD2DCC7BFE19D56 >									
//	    < PI_YU_ROMA ; Line_3250 ; 7k0l119WxDgfo3wK13Ddco9VZcAz698Y49t2bAzUE7o0v5pWN ; 20171122 ; subDT >									
//	        < s2u5Mr5qE1G1XCuQ0094t5hTv20JOcyRsdk1TqqEaNwJ25T0E2M43IOaAPmw93jF >									
//	        < lk8nS06s9X1DJeiT74dCJ4I8006AujP7QFrhN6yzGc0D90Gy1IGoJcN4Guqi9Iad >									
//	        < u =="0.000000000000000001" ; [ 000032192341347.000000000000000000 ; 000032197860857.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BFE19D56BFEA0965 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3251 à 3260									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3251 ; ZocZcERa9083d8d5KUIo2EQ51cY8726107ZZ898RRXkx1VIT3 ; 20171122 ; subDT >									
//	        < M72htwT6oxSPV37ACkK432Sjz2nMkCty96b8hHdJ41rX4ny0Wn40ARHGhU1g90ek >									
//	        < j7b5kn5ri3Wdvc8K6cf259Mo6Q25ZEo1KLg9il562k5I6QWdXCH9D82w33kwkrYO >									
//	        < u =="0.000000000000000001" ; [ 000032197860857.000000000000000000 ; 000032209742361.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BFEA0965BFFC2A9C >									
//	    < PI_YU_ROMA ; Line_3252 ; ilKQ6Kt0JwKl9SB2vvPPA89fq47WJ51sW7470qoXAct1vp8B7 ; 20171122 ; subDT >									
//	        < FSqf4UEFjpJ6uS5mvohBCEOV9jNUfJZ8F31G7peQDDkwShl47m000rEbidjJnswY >									
//	        < KcYlIhM5jl9ugbKWzpqv4HC6ka2ODxzXV0shQ5r55i0UaeH1cHsHfrkvJetMe3Jc >									
//	        < u =="0.000000000000000001" ; [ 000032209742361.000000000000000000 ; 000032223285300.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000BFFC2A9CC010D4D2 >									
//	    < PI_YU_ROMA ; Line_3253 ; Ki8zPWlMnkBkur6FSKc4vzVTH7XmB8Akwrku8qfn1ryhR2TOl ; 20171122 ; subDT >									
//	        < 1CcUZlb4Beol0QIEIvrlY1495eZ7qO411Uco8PE3AEoADm1ga5Jmr484Vvirq7Ni >									
//	        < lyV2S2Us4cl0BdWx7WF0z977ANzZ0Y7487OE19t5S7W62zsg5YqNwMS1W0S80w6R >									
//	        < u =="0.000000000000000001" ; [ 000032223285300.000000000000000000 ; 000032236195787.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C010D4D2C02487FA >									
//	    < PI_YU_ROMA ; Line_3254 ; wToqS78sLNWzGE3y69y5sqRq44PjWBCPQw00nOyv602vxj5v1 ; 20171122 ; subDT >									
//	        < 1ka59X3sXdCKfJJTf9jpPZpZCPQmOj09sF6i9FLFhwI6fFeDY17X6npve25LoO0P >									
//	        < lm1l79tqTJQOH39Dh7s4YZV3kK0qeu4BH7FP8LD8Gh7K6bg4sG8u2l75gJc7h2FF >									
//	        < u =="0.000000000000000001" ; [ 000032236195787.000000000000000000 ; 000032241438834.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C02487FAC02C880B >									
//	    < PI_YU_ROMA ; Line_3255 ; YhMt4zO8bI8I30xCuo4PIo6lle03UJkI0pAf0u1na2895wpmS ; 20171122 ; subDT >									
//	        < h9PJpJs3kWWj3GEp5dlvZmmp46MitAg42i0YZt4yL81cayFE2a53G6pylyZosy8D >									
//	        < L0840PD0CqBm8DO2mUq20sUW30iJab3rJYdo8BdBd6h1PVT071T5SdRO207172Yr >									
//	        < u =="0.000000000000000001" ; [ 000032241438834.000000000000000000 ; 000032254958900.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C02C880BC0412952 >									
//	    < PI_YU_ROMA ; Line_3256 ; LPK8yk8t2I48Os718k24o89asMFwHNza2x385IafS6ASCdmyl ; 20171122 ; subDT >									
//	        < 92s7dF1gj8X8eJ3iWR67s5doMpWh9L4F9I6bTSlyMaKBYoT5HYbjr2U66FHFRzX2 >									
//	        < 5f8f3uPb6zRfNi0j0j06MTujK3fcoU65JzfnK6FV91Y91oDCg431ecNY6cOePsd4 >									
//	        < u =="0.000000000000000001" ; [ 000032254958900.000000000000000000 ; 000032268677138.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0412952C0561801 >									
//	    < PI_YU_ROMA ; Line_3257 ; bHemM36QkkQtOE0f3y6Vvb5wZ1kvsXvx8GORk31gEjyO31Qeq ; 20171122 ; subDT >									
//	        < 57K85xiHo4OH67oKc75Jko9REG6aUX8i3ArKn2TKqW5OFShryEYEchVbV96EY06n >									
//	        < UBh5BJ120k5NLwBF0u6043AMdzmt4w4H3MMWMvhZB5mWWxmIGxGWz8eyJ5HJ0GPF >									
//	        < u =="0.000000000000000001" ; [ 000032268677138.000000000000000000 ; 000032279398264.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0561801C06673F2 >									
//	    < PI_YU_ROMA ; Line_3258 ; sP2YOzztxHqZoz0jrfkBJ9625F6hvHa745s0znzpVxrL4Zk9c ; 20171122 ; subDT >									
//	        < 3ec69bC3b41qVm2Q144LmvY7ch3Svh0uM1oh8V9gXfd65dYZ1jBW4P9r76KjS99x >									
//	        < G1g9FD4r61697lw5517rp1B0b1T28yD1IJ1k0nqwLTuP341jksq351aa56G1G25w >									
//	        < u =="0.000000000000000001" ; [ 000032279398264.000000000000000000 ; 000032293643066.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C06673F2C07C3052 >									
//	    < PI_YU_ROMA ; Line_3259 ; L2nkYC2kI4S3n5hiBcS9M3C726jc8sIYkw86JBR1rCbkRlMP1 ; 20171122 ; subDT >									
//	        < 5WNhB4Rq6g31y88xVcAF51Pde6WaCgcY9jtS22ySeiA8wSk8TrQtg3SplM6Bys1R >									
//	        < qSjVcSt7FDRch28H7c5c8XO8iYUoIt30nI3538p8PDF57297krLyqvPk2h2y7802 >									
//	        < u =="0.000000000000000001" ; [ 000032293643066.000000000000000000 ; 000032302338979.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C07C3052C0897529 >									
//	    < PI_YU_ROMA ; Line_3260 ; BB0g6lkEzGiOYSvV85P6IHxr7dpn478IC251bTy74oWgYrRvz ; 20171122 ; subDT >									
//	        < Ip57p6cQK9W23MzwPIZvr2dSrf5D4xxK66sj4Z07wqe79znAQeDe6VWH8Dja4QnM >									
//	        < 1Ncl2hrqjBqHwwz83VFxTO95ySCwV60772uiOl5DX2n6KzUsEWR0z49U3H3LBl9X >									
//	        < u =="0.000000000000000001" ; [ 000032302338979.000000000000000000 ; 000032313854237.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0897529C09B074F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3261 à 3270									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3261 ; YiF1pm7dv09813xma7zly2q2CUVNM90o11hK45253UFNg2fNc ; 20171122 ; subDT >									
//	        < 9Ol1KymYIjdB03H7D09hRhrt265f3HboU7x8KCHwMx5914Tq9n9Vib5ly8iQwEFO >									
//	        < lgy9c1PYF1VdVa60I4VN6g5dw2o12fnpIZIYP1822f1f5Y122XRfr21ATds4o0Zd >									
//	        < u =="0.000000000000000001" ; [ 000032313854237.000000000000000000 ; 000032326093431.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C09B074FC0ADB43F >									
//	    < PI_YU_ROMA ; Line_3262 ; G2C89GMQ35w3W2lG5rW2T1tYAp4C1AOcvV7Pa78J1y2NmopSx ; 20171122 ; subDT >									
//	        < IOQ6S3j7P97eV2u0C91o0AxyA72i4jojM5cSot5co1adF665805MetQ62318Cx7Z >									
//	        < 5m48KFt4a56USXOX1YWWW9Si7p2DO98GQz0ey5Wnvh3K3HfTQ8h0Z5HAJorik6WT >									
//	        < u =="0.000000000000000001" ; [ 000032326093431.000000000000000000 ; 000032339085609.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0ADB43FC0C18750 >									
//	    < PI_YU_ROMA ; Line_3263 ; jIIeW1RKoPW1KR8PtK5UDRjo9J64yCZ2o95TYZRzaXh2rWUG4 ; 20171122 ; subDT >									
//	        < 62jW3lhJO5w1dNRT15wOuGW8YcRcZRlWb00y26j0d2coo0MuPhZ49d508J704Ma8 >									
//	        < w2dljLmhcgGjf4hKYi1IJroItNEWZ975687OKdo82OYFvdPhX2f6VRqI5yC6N1OA >									
//	        < u =="0.000000000000000001" ; [ 000032339085609.000000000000000000 ; 000032351195572.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0C18750C0D401C5 >									
//	    < PI_YU_ROMA ; Line_3264 ; 7boY187PE4W90Cp51pf9S5sXy1Tw5Zta5FL19rBw22hD28Az9 ; 20171122 ; subDT >									
//	        < WK0uk00W0klq34wr4C0o2f5Bgt9m4f1402IhDS1P86q23pkD6VuWp60SkNwCR43X >									
//	        < VtN76j3FYW7fLSleE9E8YP6t2SO8GB8O2DmExzS0rhK4F9C3jjdfVKt3HH6KCQZr >									
//	        < u =="0.000000000000000001" ; [ 000032351195572.000000000000000000 ; 000032364157346.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0D401C5C0E7C8F6 >									
//	    < PI_YU_ROMA ; Line_3265 ; aJ9VOi7vpr922g84IjK7Ir277T10fr1nk0Vc09k1q7b7Q1y0b ; 20171122 ; subDT >									
//	        < M2N1nln3v6Ep3ZWCP488985mc8110th84kPQX61AmObv4tc5RCln67kmGGB7j6YK >									
//	        < 842bsp5UC4GDV998rft0109Rna71lyR5qDFo5BG8wQt8Ew4219NJ62Rr6J36KR4W >									
//	        < u =="0.000000000000000001" ; [ 000032364157346.000000000000000000 ; 000032375725092.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0E7C8F6C0F96F9D >									
//	    < PI_YU_ROMA ; Line_3266 ; v8BQ6NjdqQJGIRDulRkDNHx47y0Ja135Y6nHo9Ra0B6o1ZD6J ; 20171122 ; subDT >									
//	        < NPFQh4jtwd4x04ECqN913a8L3IYJazB8f210b94J8rL28NvmmDuojJ8L3UEw435C >									
//	        < N8182qCMtZj0p01fS3g9qI72n3g5Ljb5c8NpZP7FrMxl2xW89KggHrlE9ztiTuHy >									
//	        < u =="0.000000000000000001" ; [ 000032375725092.000000000000000000 ; 000032385638914.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C0F96F9DC1089033 >									
//	    < PI_YU_ROMA ; Line_3267 ; Dz5mc5c6enHoCBx6tIKE2D7BL5ykUFa8u6QJgbUzAxgL2527f ; 20171122 ; subDT >									
//	        < wAML69u9WrccK7nZ20CXJY0wTFdnHkHjzY0qf07968s22cOr22pFn31r939QWzzV >									
//	        < 3M1Hn12uRWG3CS3Dlz22V8R5cNJCT28Y2s78fVloY125AxErLyX1ZXl2P9TMxBro >									
//	        < u =="0.000000000000000001" ; [ 000032385638914.000000000000000000 ; 000032395861812.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1089033C1182985 >									
//	    < PI_YU_ROMA ; Line_3268 ; GXN5a1fY4V0jDhqYHHf7x2mnfbyhkZmPznv965WXdIg80n4kK ; 20171122 ; subDT >									
//	        < er89KCBmrgOdXfK1C8FYc2Bx7M270h62cOcV7oq0phtBi32T0f30Chr783epI551 >									
//	        < sfAvcE8b4tk573zML2QdIcvdiaIr3Wp5F5JkE6pb2Wg9XU02QBxKo0eFI4yvLgq9 >									
//	        < u =="0.000000000000000001" ; [ 000032395861812.000000000000000000 ; 000032406637564.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1182985C1289ACC >									
//	    < PI_YU_ROMA ; Line_3269 ; J9KSn8v2Enhz16x8xfJf74vDI92NBE2GQixY8z4Bh9g66EH48 ; 20171122 ; subDT >									
//	        < 3xP9gc58w2e262i773r8vbTktbcciwugZArIFXg495VH1TU98ihAPDa9nNyhcWmF >									
//	        < 7arHUzUw0glbaxpGyeV6EtU25oZM6B09F5q1m91wf9VwsZDDBEYrU40O9c1LgyB1 >									
//	        < u =="0.000000000000000001" ; [ 000032406637564.000000000000000000 ; 000032419043666.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1289ACCC13B88EE >									
//	    < PI_YU_ROMA ; Line_3270 ; gvCX6695Ub59u0b741YVEy5C9d48zE80a4WQwogKHjcwQ4977 ; 20171122 ; subDT >									
//	        < Nd2Z3fn81I4o782j7YE9K0s1qD7KJMB529ohn5s6hMyemY93d67er2a7X9dE01k1 >									
//	        < DOO1f50585G5GyfYwNskKm7zqy2d1lHwTz3hGW1TyK3I4BzTX09w68Z20M2VIbSC >									
//	        < u =="0.000000000000000001" ; [ 000032419043666.000000000000000000 ; 000032431076621.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C13B88EEC14DE54E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3271 à 3280									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3271 ; eqaFr46UcVEdt1zbQ6cjeq05845Fg87ZhwXJoY0U971Qwj8im ; 20171122 ; subDT >									
//	        < EwSWAt3w72sk27ix21kENm2XM2u6x7CGpSN1KsjQ7mT97129bPd6QA5XL340jso8 >									
//	        < K9yP9tr3W7vMtqj7S3Qm3p08Kdl1sEX4AEHbKpZXyBonaGmX209vEcc8xD6wq5z0 >									
//	        < u =="0.000000000000000001" ; [ 000032431076621.000000000000000000 ; 000032440584845.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C14DE54EC15C6774 >									
//	    < PI_YU_ROMA ; Line_3272 ; 9sg7TNSCVt1u5p77V75dBC4pMDirBuZVvqu53g5t9xH4U1slD ; 20171122 ; subDT >									
//	        < pyMWJwpNuq4013Qtoo4L7IUxYyp6X1EaD39KSNLiu7r29Y2jsQ477B9vo034g3Ff >									
//	        < NY1tt6SrVgtcZeJb07900ui0uLpZfMl1AqyxWq7c9g4bu4z4SvhD81JIkDvaoiP6 >									
//	        < u =="0.000000000000000001" ; [ 000032440584845.000000000000000000 ; 000032454031745.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C15C6774C170EC26 >									
//	    < PI_YU_ROMA ; Line_3273 ; 66s9uv84OsyeGRCoX9JY1ZnR70HSW4F9Fa3o3khW1tT06KV5s ; 20171122 ; subDT >									
//	        < 6U94S8omHzXp7IdJNb8CEHLW416tqO4FyWKDiHz64N1e2wVoCG1zkgdJAE3iX80p >									
//	        < bqfJZrRvVgdyLI7yn2lN19gaZH5k0H5jI34TxHs135dU226L6kcB5xPxI2JD9xH7 >									
//	        < u =="0.000000000000000001" ; [ 000032454031745.000000000000000000 ; 000032459133873.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C170EC26C178B52B >									
//	    < PI_YU_ROMA ; Line_3274 ; D6ovpjOni96155SimL0F8HmG251bE13lG066ozXLOd4E9nAz5 ; 20171122 ; subDT >									
//	        < 8329m794V8Q0wkuiy08B975QxP8u9fCKPvL7v2Iqetr95154v7Dg3ZM2ic4r1FHO >									
//	        < AwHeac9196dNA8Z58qbw04fJv93Cy8qhr429aLi64ivUBw2E7mVF53QB6K3OvpOR >									
//	        < u =="0.000000000000000001" ; [ 000032459133873.000000000000000000 ; 000032470596449.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C178B52BC18A32BC >									
//	    < PI_YU_ROMA ; Line_3275 ; dKGyHQ03XC272xBhKzxlX6q452zZtRjRh6MuQTOZb485sDs6n ; 20171122 ; subDT >									
//	        < 4t0SLB683G1vieUQwy6GTDZcWo7d5916s9K6AZh5lIKgQN12rFy495iih9j2o7UP >									
//	        < 21CyhjK5wiyfQeHbR8w9a4y123Wcc6X8Y44ANn3J1fFI5ioa1tn8LO61DdQJ7SFu >									
//	        < u =="0.000000000000000001" ; [ 000032470596449.000000000000000000 ; 000032476327926.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C18A32BCC192F198 >									
//	    < PI_YU_ROMA ; Line_3276 ; a7KU8gEw93TkRQ989asZiB4oMWUVSP4ocCejwrwB26x5x9mdK ; 20171122 ; subDT >									
//	        < A917GC17H3YTgZ8r1Bwe92985N9B6chO7b7JR2c1BJ77My8vN11yDW0WS7p6iY4q >									
//	        < 6fU2G1KA9NsV2sj8n5bqf933L30O242RNf0le36BjmKSKCh3M4262sdP7M27I0aC >									
//	        < u =="0.000000000000000001" ; [ 000032476327926.000000000000000000 ; 000032485815576.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C192F198C1A16BB5 >									
//	    < PI_YU_ROMA ; Line_3277 ; XqRqFZ5Ft4LH98CCI4biSoX4kVvW3hac10f4JhG70vmH8Y020 ; 20171122 ; subDT >									
//	        < 3J0yK2pADthjYr7hIA5MnHE7LwlxAfD1DNgzsbk00Pd8XtZNTCF0rRSB8ZE1A9b1 >									
//	        < 665Yy44W4CYUjk74EZ1Yx763jk3Zo6m5UfD7tO3J5yKK4NsTnikSj6y28KPaKBG6 >									
//	        < u =="0.000000000000000001" ; [ 000032485815576.000000000000000000 ; 000032494236005.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1A16BB5C1AE44F0 >									
//	    < PI_YU_ROMA ; Line_3278 ; Y7tkJ6ytWecl5dkFnlUlKq6XHc68Ac3Mp51IB3RolqWwu15Lb ; 20171122 ; subDT >									
//	        < 31sIhwC3cX7871fBJn5757I5TVpnmP3Hjs4ZCYY1WG2Hhhj2qa9EJ1Wl0kKpaZvJ >									
//	        < 7aDm8j9T5dw69h4SiXFvqm5ae9XIiv1ImG25UAl5eI0vAgm1ENylZ13AOMHb8Q5S >									
//	        < u =="0.000000000000000001" ; [ 000032494236005.000000000000000000 ; 000032500824908.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1AE44F0C1B852BA >									
//	    < PI_YU_ROMA ; Line_3279 ; 8y17oKK9nzfGx9B996BpV8a0N9P8r8h21H3TydwfZIc08pi1g ; 20171122 ; subDT >									
//	        < VwB93eRxt7G7424Y5u6G093l83F7t0bkRI7W8eQm759AIv7kYKQotguy5NUii27A >									
//	        < Bnl5J03p5O0pb0263hgHwN982qbbVqLrq1O1j6saZcDpzpi65Yr1DTquPYJuwK88 >									
//	        < u =="0.000000000000000001" ; [ 000032500824908.000000000000000000 ; 000032508202202.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1B852BAC1C3947C >									
//	    < PI_YU_ROMA ; Line_3280 ; 95rzIjqk1MP9sw766AqDw3TbqEVRq5Z5dK778Fqq0bgPJ953E ; 20171122 ; subDT >									
//	        < C7F4tP911853lp0xdgz0CV09fID5WW3pGfdd2TzZ1dp2dIf2e588U10USp83NHtA >									
//	        < 3Kol20L7E9mkrz51bcBLO1a55c9ay9470QwyiY06U46xv73od4ARD2gZHou2T5bw >									
//	        < u =="0.000000000000000001" ; [ 000032508202202.000000000000000000 ; 000032519355481.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1C3947CC1D4993C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3281 à 3290									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3281 ; yUHt2fppVw5746mtpd46JS8ZpM1N4966JeD2x252e5XTf0292 ; 20171122 ; subDT >									
//	        < kbNhNLv315x9Tvs8yPGc1m92jJXKB4hugDe54eH604zwo27Do7gvNW4vnBrZbzpp >									
//	        < sc5AHci1C9icS2Fu5xrwJyU7xCha5RHR1Ac2fRh6nDS791FVb7B5MY41Lqvnj3Fj >									
//	        < u =="0.000000000000000001" ; [ 000032519355481.000000000000000000 ; 000032526323890.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1D4993CC1DF3B45 >									
//	    < PI_YU_ROMA ; Line_3282 ; pdYAElqs9pFyKdAhcf4duH20usow49M0J33u51v2rd1g9l2ie ; 20171122 ; subDT >									
//	        < fxkf3LkJxw4Vf232G2o98og6BD8n4UmX5Yl2YE8YA38VX6XD792APKY908dsNF20 >									
//	        < 239b9Mo484u944g3AJ8K6EemtRX6D63zdNi95aa1qXQ4Y1ga2xrfA0wIs2n30CtP >									
//	        < u =="0.000000000000000001" ; [ 000032526323890.000000000000000000 ; 000032535328546.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1DF3B45C1ECF8B6 >									
//	    < PI_YU_ROMA ; Line_3283 ; P3qz1M023w90R3xvuKGCm1OGUDq8jp2z1fDWmA6mfRTy4IX7m ; 20171122 ; subDT >									
//	        < 47SAL6dtBaVnXH4sWPPmhRutL3IHMENu5sp22u5EBleh9mSlxT2uiMnm08B09E25 >									
//	        < licEC6n7yJ5BRQh44mV70mtsjk3uWD3PyqaGYUA6ElPqpCp9KHbNN7c74KXrg0Bl >									
//	        < u =="0.000000000000000001" ; [ 000032535328546.000000000000000000 ; 000032541082890.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1ECF8B6C1F5C081 >									
//	    < PI_YU_ROMA ; Line_3284 ; 83gECp9JF7E24to4TzRfhNyYM3XSDz2e32T82685070Pjf0r3 ; 20171122 ; subDT >									
//	        < 1LuUl9NAOpY42mm3ix1AsH21BgSPVI6O20leuh5LweD3a537P66HYaotxJIojESC >									
//	        < ZopazgMRLZ61XelUy86ly8L9in6aXPPn88XW08uAMfoznj5jeI4eT90n3Te2W3x5 >									
//	        < u =="0.000000000000000001" ; [ 000032541082890.000000000000000000 ; 000032546673277.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1F5C081C1FE483F >									
//	    < PI_YU_ROMA ; Line_3285 ; 6aW6VPo66gIBo7ZqlxV4A7Ymo44p9MpE1CLCxWqtSVD6H877f ; 20171122 ; subDT >									
//	        < DM2p4W8I1vkW1Q8jcRlwoG333mDrmQe3jKUCFyTpZzD2LSwv2iKLfUf83NzEoHdu >									
//	        < NxkeNrsHS4gZ5hAq2EHXPA0X5VqeqQ9bvp4361lErim9vc2Gd1G52N345GOo3x1J >									
//	        < u =="0.000000000000000001" ; [ 000032546673277.000000000000000000 ; 000032553324960.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C1FE483FC2086E90 >									
//	    < PI_YU_ROMA ; Line_3286 ; 7h5Zpk921q8U86RZ2Udrpxa1TRW9ct8774bKe6499JAh3E7q9 ; 20171122 ; subDT >									
//	        < Jy81gFvfJ34VtK789cb9JPe477T03QKCHJWB67o3IX3YbPVFx2Unmja1xHRUSRN0 >									
//	        < JYmeddGWFAZ9ZUuYr8b19Gn5Z8v29Iqu2o8p585QBmcKPD9j4o1qpm5l1804cxdC >									
//	        < u =="0.000000000000000001" ; [ 000032553324960.000000000000000000 ; 000032559439788.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2086E90C211C32A >									
//	    < PI_YU_ROMA ; Line_3287 ; uh40M3474Znh15W9Yg2OwZ9hy1gdx5Ny089a1vev0j63EyYEK ; 20171122 ; subDT >									
//	        < ix3Tw4kAh1o1A4k705nUqb9Y0W8x5438C925ZaJi74jr5B5MT2x9I7v290cu1N6O >									
//	        < guyi7I7eve5C6HHTi9y2k52W6eb2A4k1I3P2S08iZQPV8eJ565aONo6wsIuu1wnX >									
//	        < u =="0.000000000000000001" ; [ 000032559439788.000000000000000000 ; 000032565526226.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C211C32AC21B0CAE >									
//	    < PI_YU_ROMA ; Line_3288 ; e55o6m4TlF8K98kSWcpoz4nq435mC4l93yt3oNWz5QT4Wm29m ; 20171122 ; subDT >									
//	        < Kx77mw5XiwSC4WXM411w45M14IwsqiVhn1puxu8V4P4w0zRRi634Xa0tLDF8Vrid >									
//	        < pYTf295x3650930Bi845pRoJDctaVtV7c6177N25Ec59xUbP4y3AFv6OQesHrRSa >									
//	        < u =="0.000000000000000001" ; [ 000032565526226.000000000000000000 ; 000032574822839.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C21B0CAEC2293C2B >									
//	    < PI_YU_ROMA ; Line_3289 ; y835t9y34fv9aaAvC3Ru9fyYuI1mXk783dlMxgud05iCG77l0 ; 20171122 ; subDT >									
//	        < zZQ97mBPm3q859coRvK6KfL82600AgnzWs4jCP4S5l2vCCE5G4U3R4lWYCC75imr >									
//	        < 5mm90G1E1FGb506m4MT2Fln3ijxJ8bfUNGaCeRb87dolOmFxInI46B6jsssK5v7U >									
//	        < u =="0.000000000000000001" ; [ 000032574822839.000000000000000000 ; 000032588346055.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2293C2BC23DDEAD >									
//	    < PI_YU_ROMA ; Line_3290 ; OZAjwxj0BtBPsL446J39x1X31RF41i1qi4iv5UrJ8R6bQSfrJ ; 20171122 ; subDT >									
//	        < jb8i37J33K8R51Y8zYr62sJ273l2blmPVg8WqZH099nS8xWE781Elb64SdH8wo13 >									
//	        < cZz3QRwCbOWWY13NmdMBv04Rj6Eq0WDyRsOXKxv0K1z094zrDG4Q6W58JM4Ihj1P >									
//	        < u =="0.000000000000000001" ; [ 000032588346055.000000000000000000 ; 000032599696817.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C23DDEADC24F3091 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3291 à 3300									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3291 ; 6h26I8Vuv6u4A1MyxkP8yhPv1jp186K062JYuF5ONa93IdBVL ; 20171122 ; subDT >									
//	        < 7h9pU67Pg0ylQut3C475gK3UVgue33oaGn91MHW689C3HM04EMk7iQjSDwfjVTG6 >									
//	        < 0PFf88Zzst767qAW2tPKh3d9S3Y3NgXsT3eVjy6Dt824R4aYS9A2KD7tF9d2A6TE >									
//	        < u =="0.000000000000000001" ; [ 000032599696817.000000000000000000 ; 000032607273788.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C24F3091C25AC052 >									
//	    < PI_YU_ROMA ; Line_3292 ; 7q183Ufq9Ipt3W6S4e66kW61I0Yik9x20156m922U2ou982kp ; 20171122 ; subDT >									
//	        < WuibX746r2663zU58y0u2z17Y71zx06B26z5j7LjzeVbe2wZ7bzPgcgs093W9J64 >									
//	        < q8b5EDObhU4B50XpZQbi3kvObBBqDVfRs7c92t7lRE8K49USHn908RK21h9JszII >									
//	        < u =="0.000000000000000001" ; [ 000032607273788.000000000000000000 ; 000032618635291.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C25AC052C26C1669 >									
//	    < PI_YU_ROMA ; Line_3293 ; 5jusSrNxxb4UaL0wD0XWB72kd56eaKME6QH4R4Q49uoE2564z ; 20171122 ; subDT >									
//	        < 125nDKGZ56A8AOyvy4652iX994OAgm1d8FRklfiN14laCtKXKgN7T6P6ac06HfA9 >									
//	        < 8gv9b6QhVg456Iqp43DhMTaXdYIf7QIE070Z429jMiZNTv2NfV8y58s3T5k68XS0 >									
//	        < u =="0.000000000000000001" ; [ 000032618635291.000000000000000000 ; 000032628530584.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C26C1669C27B2FC2 >									
//	    < PI_YU_ROMA ; Line_3294 ; 6q8E4U632XG745j4Xt8vPdl7g8p0DOp04YOPP3Sow6r92TlM3 ; 20171122 ; subDT >									
//	        < 1F19qj6IDJwcchIQqhx1m25sq7A76QU1gXN5V6bVzSIpbIEDBiD54VDj2x281Gl2 >									
//	        < 6Gr0kH8864PdPjnU397yoNLIaaJ911zT4P8jf45xl4OLrLP5U0V8Iyf3IOOKuetD >									
//	        < u =="0.000000000000000001" ; [ 000032628530584.000000000000000000 ; 000032634468864.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C27B2FC2C2843F66 >									
//	    < PI_YU_ROMA ; Line_3295 ; 6J5jY330LzQ2z8bVG25D3F8lJOk03ACBy2o8rC28G81clr6a5 ; 20171122 ; subDT >									
//	        < iN24VhLzMnXb4uvJq7eB6qC7RZaO4ZTA1tKZSJdXe4rZ33SE9D6yO7169NbYuw85 >									
//	        < uG27vS93ez2IwSoylg7YZ5Ls471j09d1z8ghv6o3VWc1Qqp9Ze807JWrpeZ29NXe >									
//	        < u =="0.000000000000000001" ; [ 000032634468864.000000000000000000 ; 000032644019631.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2843F66C292D22B >									
//	    < PI_YU_ROMA ; Line_3296 ; sU89C8EBvVd3IK54T4z8uo1G9ZB91SiitMIy9FdzE7vQ9U6C0 ; 20171122 ; subDT >									
//	        < 10e59QXB60Lip4qtjuq1y0Q02Toy1zS1bHlgg1z2cn8P4oAJgUkOEPC4C1VVGoU3 >									
//	        < SHgJZ3768ruiequb2ZrM63EN46J4H8U6C41TA1sI5tH80xBohV3C3bj3PzuM02b0 >									
//	        < u =="0.000000000000000001" ; [ 000032644019631.000000000000000000 ; 000032658669159.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C292D22BC2A92CA3 >									
//	    < PI_YU_ROMA ; Line_3297 ; nWxiHZxKfq45XCin3bCbb4x495Nl4FjeUZoO74WWmP3Msg5yE ; 20171122 ; subDT >									
//	        < qbEm2pxhFiY1nuzUVJyG5rYYKNqT0Zk4nNjTrVw3S3wszv75vljFitlIgZ2wd4h1 >									
//	        < b4ZaoLm4778J306uI36LP509dkD8YN61taCrpTWnzX7S721T75V003hAW57lx2Uv >									
//	        < u =="0.000000000000000001" ; [ 000032658669159.000000000000000000 ; 000032670204208.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2A92CA3C2BAC684 >									
//	    < PI_YU_ROMA ; Line_3298 ; Ap5sD17AY56Jo0tha2uqxvPk10vXorddeutLMmWw4NKO5qnt4 ; 20171122 ; subDT >									
//	        < H2ph6H29Of1HB07GqnElME7tH2QP5Km73YPxMA5KF5kSQNRyu9798C0WdCSJRfh1 >									
//	        < 26A9764a6i91ADWq8moqP1uCWR6959vJn5pw3fl99M1EZoTL8CRUz9di00nthS34 >									
//	        < u =="0.000000000000000001" ; [ 000032670204208.000000000000000000 ; 000032676728835.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2BAC684C2C4BB33 >									
//	    < PI_YU_ROMA ; Line_3299 ; 0KF5UFoi8r3J1880CTU9EHgZbGeceYxThlAl44f8Aw9BBHk43 ; 20171122 ; subDT >									
//	        < DH2iM4jm7PwX99T8f1tf50g34jlEIC8qbKKjyLh7M463xu16hVM1kJ517GfZptz8 >									
//	        < kx6munU0glF8NjFU8B41sm06EA8Gd7ZDQli40crX7a4Dotq9O9NsAxWVxSXu4UZv >									
//	        < u =="0.000000000000000001" ; [ 000032676728835.000000000000000000 ; 000032681895016.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2C4BB33C2CC9D3D >									
//	    < PI_YU_ROMA ; Line_3300 ; vhjz0GgEIB3iQ9D00m92DGbdClS114Isp8mj6IR90bfC6gvo4 ; 20171122 ; subDT >									
//	        < r4h0m1m2Le3F48dKV8zJdaIX2B26963w8YU6HTX0P647Z4G6ucsX52aWRkH9YCD4 >									
//	        < CrKN43i22pz2C6EEv960qk6lGP68ivDc3YrfiGVCnpyaTx7IUUGRK49j4jG8tJdT >									
//	        < u =="0.000000000000000001" ; [ 000032681895016.000000000000000000 ; 000032695194436.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2CC9D3DC2E0E853 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3301 à 3310									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3301 ; e555Eqpf2E9HkacPOkqllsBkwapXfA3A2cXw3jAg5s3Sgcehk ; 20171122 ; subDT >									
//	        < eg7U011XB1zC1s3FoqOI3KohI4egdXWI5ZSROOsr3UmPrB7E42Y446J4ZJfr73d3 >									
//	        < BB10hW6rc4tIgja0tVIzS7IvL2dzG215OlgKG4baO1aqsnQV35FaAg34mN12MwDj >									
//	        < u =="0.000000000000000001" ; [ 000032695194436.000000000000000000 ; 000032705926643.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2E0E853C2F14898 >									
//	    < PI_YU_ROMA ; Line_3302 ; bqr8RUt7jmEG9fgU9W1bFX7027gRX0ccx7uTPEQSJ4Z0x49q0 ; 20171122 ; subDT >									
//	        < J2oW5z0B02O02ivNiX7MwfdI4906eY3j7P38GmnJ9fyy8FsB9lbzkisp1d78OgQ5 >									
//	        < 92Oh264pDZWB4W0A0dCK7nwJYY1J6Ip60r6RD0W0uF7Sy2RxX87rQ8Ml1736y9CI >									
//	        < u =="0.000000000000000001" ; [ 000032705926643.000000000000000000 ; 000032715125377.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2F14898C2FF51D9 >									
//	    < PI_YU_ROMA ; Line_3303 ; k4XPte8y3AdnK9Z4DtEKMa08CUYT9ol89au1jh62A32hXAr0L ; 20171122 ; subDT >									
//	        < 7hQk98f8KmiZU5y64f2pR3M3vU32RK62dAO14b6082IOstlALya37q2L8847xxOm >									
//	        < mo9xqX7r44p1E74aSJv16oR2nH2WD3K3SPzuQCPE90w774ikKuXug3Q0jwJ6or7g >									
//	        < u =="0.000000000000000001" ; [ 000032715125377.000000000000000000 ; 000032720493795.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C2FF51D9C30782E3 >									
//	    < PI_YU_ROMA ; Line_3304 ; M65sO2vknZ6aN0BH0310o5v936kzjw3DT624mhGePCvOY8AgO ; 20171122 ; subDT >									
//	        < BBf8lO5K8WA11cEOuir5WmX9A6nt84C16f23eA65DUxJs4hG52q748373Ry3kmyR >									
//	        < jgZ0wZuzTd1j5cU9qJB2ruIkh83716e8dJlq1hhS88k578jshGd4zO58EjJzZI72 >									
//	        < u =="0.000000000000000001" ; [ 000032720493795.000000000000000000 ; 000032733848049.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C30782E3C31BE364 >									
//	    < PI_YU_ROMA ; Line_3305 ; u6IL63jX3ZE2w4wsw8n79Mf72ZR5CPyM2E1YS1gEl2l1U7H4C ; 20171122 ; subDT >									
//	        < 78OwqSJ8piEeVoFH57rUYws3Df7EfR08YQ9fDAl65P3SVsMZoLyRDbFN7sGy47R0 >									
//	        < sW846bqvwctoinYNSe8pd1x6J13LYrHE74SDYeNCv76zd7913TgIhk5w25uiz0Js >									
//	        < u =="0.000000000000000001" ; [ 000032733848049.000000000000000000 ; 000032745362192.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C31BE364C32D751B >									
//	    < PI_YU_ROMA ; Line_3306 ; XCImi597mq5aUdmvLWp78C3ufk6NXogfVWO1xc2fHXmpNmjO8 ; 20171122 ; subDT >									
//	        < equjDs7m7KUngvAKK824Btsq4RaYj45TK139uT9fR7O7I681mH9ETKGbd0WqNR3n >									
//	        < QnC97Jyn9xS9U991IFq13eMC6plurMWYi6O28Ttbje2NglOy0g44H145QBhjdE9y >									
//	        < u =="0.000000000000000001" ; [ 000032745362192.000000000000000000 ; 000032750566047.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C32D751BC33565DC >									
//	    < PI_YU_ROMA ; Line_3307 ; 1gaFC1PIy4QqfJ4k2G1yP5pTrnHe5nwHA0FTya2Xo5wYV65YI ; 20171122 ; subDT >									
//	        < 61bKf7adjn36s0AHNcx21Q9sI60LB3ZB5L01VRC4L8DVTUTmiBvC0B9HMGrxQZ8b >									
//	        < O9laF6TttmG567cQj8fot7yZq13Ysj604moy8tL96ZCjmd29C5Uu28t9Erqx2vrQ >									
//	        < u =="0.000000000000000001" ; [ 000032750566047.000000000000000000 ; 000032759038953.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C33565DCC3425397 >									
//	    < PI_YU_ROMA ; Line_3308 ; MC277Zz5E5mReZit3F8un7zbHDH0P3ncN662Q2Z2hTw651n52 ; 20171122 ; subDT >									
//	        < uuLR98kc5VMo0QNnH2491PAkGgBCagIwlS8w7M176q1aKfc0jC213c88qvWWN0s1 >									
//	        < 2UU0Pr1Yv9ru8VmY39TRJpNzM870bWH1rnK0ZRY6z5S1MVP7300SIk8JGQjw0791 >									
//	        < u =="0.000000000000000001" ; [ 000032759038953.000000000000000000 ; 000032767949422.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3425397C34FEC3E >									
//	    < PI_YU_ROMA ; Line_3309 ; bD3no2cQTlDfRz2oO29ORUD6NQ1d71g3Am1BKn281B1iGZ791 ; 20171122 ; subDT >									
//	        < WbAaYAhGtxFAeFaJM3aio8p99wX9e8N94v231LSU0Log9XQqqvhzcNqe0vNc7Q4o >									
//	        < Kb98B6JKgbqeZQHn7awfGwEwigN3Kwuu7huOUaVwwfmK8FL47NW8Yipp7BiOg5OS >									
//	        < u =="0.000000000000000001" ; [ 000032767949422.000000000000000000 ; 000032774175088.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C34FEC3EC3596C24 >									
//	    < PI_YU_ROMA ; Line_3310 ; d1VmWteVyeu8MFoJ3CVQ2chbR1FJJ7pZ6eh074Td5019bBdIx ; 20171122 ; subDT >									
//	        < 4qowB17K1189D1i0foq2IPynCqqnYB3sS6g545RKbPFNw7f754q34wN9Sp93KJsF >									
//	        < x66b3tlDKCWhc3UVf1598e9ukQ7o13544dXby3jc7c7oM7zv3OTkl0Z670c7MSPW >									
//	        < u =="0.000000000000000001" ; [ 000032774175088.000000000000000000 ; 000032780677286.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3596C24C3635810 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3311 à 3320									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3311 ; k8m7YGPy8NDsKs197jJ0pNiAICM3w36GHRUEXeHp8qRPsLipN ; 20171122 ; subDT >									
//	        < wnJ5pXJL25H53YGr28L8tMOdM1frcaz0230RVcu85vc6oCdGqJrtB4uf791FJg45 >									
//	        < 52Q14r2MxD67ptGMmbJU44F6V3U6O91AF3VIK9S751792mo8LDML2P386s6MU9uI >									
//	        < u =="0.000000000000000001" ; [ 000032780677286.000000000000000000 ; 000032794669330.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3635810C378B1B5 >									
//	    < PI_YU_ROMA ; Line_3312 ; Ho3sJ9oK1QLI4x41rcD4Rkr4X5B58O1FoPqx5XkG4s2c04728 ; 20171122 ; subDT >									
//	        < s938Buat392tf1B1RxZXs2UtXFNmcf7YkWqpKl46iRAs0jL5YYZBMdK774mx6wMr >									
//	        < t5v99lojDw4H8wLwRxkaS4ev04kqOBv5Fy71C90N3tIU8bwT81O1RatOJi92vUO9 >									
//	        < u =="0.000000000000000001" ; [ 000032794669330.000000000000000000 ; 000032807043126.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C378B1B5C38B9338 >									
//	    < PI_YU_ROMA ; Line_3313 ; 7P66k4P0c5nViTJhNgMjMy1JaAMPc34kR8l187ZV8ciVN4Q39 ; 20171122 ; subDT >									
//	        < 3ny7GIaairZxTMKtiJ3mS8gpmzewW20a0V2aXi2yNMS0O40653Pe3goK90GTIUw1 >									
//	        < EfzInhJdxVhdFWOn4o0ejG0Fjw5h80J5u5RQAU1y37XEeSHzNARLIw17w91jGB4S >									
//	        < u =="0.000000000000000001" ; [ 000032807043126.000000000000000000 ; 000032813057962.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C38B9338C394C0C4 >									
//	    < PI_YU_ROMA ; Line_3314 ; C2DQFfuE6A1JEFTuW8z6Va8td0bcxjmRx5B6Kp9IO9EYwHNQV ; 20171122 ; subDT >									
//	        < ZWS2eV587tjOlLgs1Q3A44622x6q60cfOmEQg3o15lbepo682cFcjH1Wjo5Ldng7 >									
//	        < n604Y3nJO2Y3p9DF77iuSKuJMbwY7jG0n2RSh3H07T9TdBp7t8S6s3x0Y57o552G >									
//	        < u =="0.000000000000000001" ; [ 000032813057962.000000000000000000 ; 000032821837462.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C394C0C4C3A22642 >									
//	    < PI_YU_ROMA ; Line_3315 ; mzJN310g9ybXNpJS0okC0qmd2992siBqL0594d8DW6lOudOPB ; 20171122 ; subDT >									
//	        < oqJwik05kMaZZ93NkFpkxgJu0rrmv7qE1Al330qVQWRUo3Cb12EIfs3AZR75MCab >									
//	        < etc99y9l7M3IKW8oSJ7WsmjQ05bZr6W9IIOd2v01jcfM4oz1Xl0x0vxHBk9kR4s7 >									
//	        < u =="0.000000000000000001" ; [ 000032821837462.000000000000000000 ; 000032828609220.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3A22642C3AC7B7A >									
//	    < PI_YU_ROMA ; Line_3316 ; 1nHW0Fwm1N7b041gJ0ODwFKKP8qQyZ7V8W0856VWqEbgJQhtT ; 20171122 ; subDT >									
//	        < 30O6DiXWP8OtWxV25gUaGg5Yi5qLC11L5D81Yl22tDJNTM23q6qZ23w0ghDpeD7q >									
//	        < 1m9y083940JFbAoKs1kT8BX1kYYCeQ3uGxJ6dL389XtP3aEXkXA1pq519I8d16T0 >									
//	        < u =="0.000000000000000001" ; [ 000032828609220.000000000000000000 ; 000032839632507.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3AC7B7AC3BD4D72 >									
//	    < PI_YU_ROMA ; Line_3317 ; KHD8X368hotgTTACIiKV9nUFAbTK9V9Wf54cvWgDnpv8V9NZu ; 20171122 ; subDT >									
//	        < 2uYy7x57nDuMAWp3X7684Z5bTJeL3Wge42Na4Vkf1qbhvHH3A4rEqsgfN39ZAs6i >									
//	        < 2iR6P7X1p0AAXWY7dSbbS4eL5o7k4rpkqgwz8G56a3gLMrs8yK0wf7kwKn4I93B6 >									
//	        < u =="0.000000000000000001" ; [ 000032839632507.000000000000000000 ; 000032846232708.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3BD4D72C3C75FA6 >									
//	    < PI_YU_ROMA ; Line_3318 ; 9klf6oQc6919y4JMaLKO334OOs9bX7WPvtUMck8UNzd6veuLg ; 20171122 ; subDT >									
//	        < 3hxJKg1erjk2Vxs3M3y5UHl0Z0LeCkX6dv9E01RmKFpUt8x3752AneZ8YY3I96fl >									
//	        < VEWXU5272i1ul7j4UnXvx8A68o7LH0CtBq9an4cZBAE5pbVRIz9UDW4884j25BzC >									
//	        < u =="0.000000000000000001" ; [ 000032846232708.000000000000000000 ; 000032855679202.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3C75FA6C3D5C9B0 >									
//	    < PI_YU_ROMA ; Line_3319 ; akYuIfT81OKLh0twX9u6acAodYC002guyPe2fku0SVXAB3Ds0 ; 20171122 ; subDT >									
//	        < HO6pZ48SBqtliJ0SD3cU5WBds0JL8P7WlZPi0p0GzJdxRme77Gsk4hHUiy909l16 >									
//	        < Ie0B0v5Y8625r18asLb782iUl3qN3i6Xcbmz6pLfwec2235Xn86Z2GgU1S27S5J5 >									
//	        < u =="0.000000000000000001" ; [ 000032855679202.000000000000000000 ; 000032861170562.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3D5C9B0C3DE2AC0 >									
//	    < PI_YU_ROMA ; Line_3320 ; w53En14dGgU2uQp831ZDzBb7tSUlw5SR22F12PlgLvp86YsDo ; 20171122 ; subDT >									
//	        < WqNr40m7Pw5oX2Yk2Pn0CQaGns27J13X0ulJy1799s16jSEpsVcq52YMxqwjias3 >									
//	        < k5sVM9T2Ae33gRnmMzNj9tyf2Q8C5J7Qy59VMY0tocTD80B1muCD8JsSx7nKQN42 >									
//	        < u =="0.000000000000000001" ; [ 000032861170562.000000000000000000 ; 000032871129692.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3DE2AC0C3ED5D09 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3321 à 3330									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3321 ; HLY3i84WHHhMssl736nblqe000rNONQ8hkGQF85d3M9B1w62z ; 20171122 ; subDT >									
//	        < PAie38eO3HV56pLo7ebP3Ez1QT0pd8xO19gn9O732M7uV74inlvs97TSSO4VLJ64 >									
//	        < m1a7mHGRk6i4Gvo1NI42kSJhG5S8jghGAGGfBXCcMADlDE4w15Y20lrU3b77t6e9 >									
//	        < u =="0.000000000000000001" ; [ 000032871129692.000000000000000000 ; 000032879740454.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3ED5D09C3FA809D >									
//	    < PI_YU_ROMA ; Line_3322 ; D27SB14o6COp3Y6H5622a6j24hT4ODY1BP10uq29hoMzAJtcw ; 20171122 ; subDT >									
//	        < H5WR7pq9uRHXw0Od9BJrz1lIj4NQ4p5xwyuku6XvL8GRq63xz070CY07Kl2tKZ4C >									
//	        < 29j73DTc7B70MN3Plmxhu14C1Jw2c146sirocIRi0mmMh2UrsrnG9BfoWwso600m >									
//	        < u =="0.000000000000000001" ; [ 000032879740454.000000000000000000 ; 000032888177306.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C3FA809DC4076042 >									
//	    < PI_YU_ROMA ; Line_3323 ; N5a15O4yIiHTrx72Nx6UlPBpM9y0yNcUvbS2FezxGAFw79G9z ; 20171122 ; subDT >									
//	        < q11kDnflKGzsZ4ADxpOy20W74oaIrJo660B60fOVZY5twy1WL4V73FV6CD0wbxs5 >									
//	        < OnCWwM50ODvWqDXENE6XEIg6l6zVWu3T076vS6E067K7La6xm3z0877a3Mar2RWa >									
//	        < u =="0.000000000000000001" ; [ 000032888177306.000000000000000000 ; 000032897985107.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4076042C416576E >									
//	    < PI_YU_ROMA ; Line_3324 ; 9p01C4zFGEI68q0XIX6YTmSZ5cmR1qnj8v41F7G5JsY38hYeO ; 20171122 ; subDT >									
//	        < u94Q16B7NI0E3EntDrS4heSrr2U3b535jD5eK22UTTNX6AhIa813f84yiWP4B7Sj >									
//	        < Xut48RMPL56HBVd8zQffKdfZh8KsYQ0P8IEDD2ZJ1LKS6j0dy9FS34p7Vw0vi6jU >									
//	        < u =="0.000000000000000001" ; [ 000032897985107.000000000000000000 ; 000032912521227.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C416576EC42C859A >									
//	    < PI_YU_ROMA ; Line_3325 ; 9jVX79Tew1E4i1kj3mFDa5OE4C5Z5UqkD4rWwJQk34bc6Sosx ; 20171122 ; subDT >									
//	        < X46s08763H5nDWLW60r3O5CKHV4ALNEouKj2w5KYnmdx6U203Dy69t3QX24C7J55 >									
//	        < Zrt8jP6ub786kX6gi9Pu16RI7XRpE234Xm3zqi2J6gW2k0EUmgO42b5IF2zv3i74 >									
//	        < u =="0.000000000000000001" ; [ 000032912521227.000000000000000000 ; 000032927474183.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C42C859AC443569A >									
//	    < PI_YU_ROMA ; Line_3326 ; 1Syaxv9y1E5FTSjO8WCM0Wm10p5L3S6U4UVh6q2NaeIMx7549 ; 20171122 ; subDT >									
//	        < 7OPk53hX2A4eec6f4FH6lpAYp1AJ36ktHe3Y7nnUyURbvzaDk14WZS3d5v0NhRU4 >									
//	        < QF11G9i0Q0e6d81jMoIXwC9v2YV7JvqJfcclJf1O8ioTIt4ArdzVU1Spj46mzvJ8 >									
//	        < u =="0.000000000000000001" ; [ 000032927474183.000000000000000000 ; 000032937377367.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C443569AC4527308 >									
//	    < PI_YU_ROMA ; Line_3327 ; XtUU51OsSGSXtTN74uJ9L33n26LWry00p7BR32XPP6qW9B860 ; 20171122 ; subDT >									
//	        < C9p9y8279009athAO1VSHI5fb9GP2xAIfwX7Mphyl0Q27u2C1a9ADSg8h47ypl2q >									
//	        < uFy4lT2i47669doxR3cO42lF0PYEF2dO6bLPtfa8GwLTI29f4hN3kep63ICFPCqS >									
//	        < u =="0.000000000000000001" ; [ 000032937377367.000000000000000000 ; 000032943125911.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4527308C45B388F >									
//	    < PI_YU_ROMA ; Line_3328 ; 125R5NnAK1tcVWnL8HUX8UY90P4YXoX5x746f3c5mv45PkM0M ; 20171122 ; subDT >									
//	        < Z5449cawQuHR733u4r3gDliFW14YfKT4eF72qTMgKZGk4o7J5Gkg3KXQl3yF3DNp >									
//	        < IB133nMk7G251d3B5k8dw2rs0BgwRzYoE3piJ8KeVJ9JIvL7n8RLfaq8tO92o338 >									
//	        < u =="0.000000000000000001" ; [ 000032943125911.000000000000000000 ; 000032954059774.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C45B388FC46BE799 >									
//	    < PI_YU_ROMA ; Line_3329 ; 9ll4cbpB2JEzAB9ZmJ9bkX2P755bfRyPw0390mo5b7G3f343Y ; 20171122 ; subDT >									
//	        < 1k5t23wyAit16K170S1Cn2d6b1DY68xAxf9q09odNkUR3RU7178rT6dzz642SzaX >									
//	        < kQkVtaI4jw8nXc2i1bb7cpMfdjA550hVh94lr3n4P7Dx8tjRVg2wHMZbLGyol9O1 >									
//	        < u =="0.000000000000000001" ; [ 000032954059774.000000000000000000 ; 000032959903930.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C46BE799C474D279 >									
//	    < PI_YU_ROMA ; Line_3330 ; 1BcT7f253bAg0ZB80q9xGJ952j6M1qcQy20P2MLTO4PVkHeOK ; 20171122 ; subDT >									
//	        < vWegDt8a04JyzujXs2cs8ai99K1lVXYVn1oAIs8xqPYih9U9hl4MsI1ACHtnUQw3 >									
//	        < i30eOcS14Fd3qGNSU2jg83xr5EJt0HU9zJCtr3Cxeb7bpk9gj15w5W6FS9nQLBxM >									
//	        < u =="0.000000000000000001" ; [ 000032959903930.000000000000000000 ; 000032971146920.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C474D279C485FA44 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3331 à 3340									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3331 ; 2C04NI81jgVY575o6HN0m71MmwbA5bJp5LW6skCkUS0TfS6d9 ; 20171122 ; subDT >									
//	        < jgYL3YUx09d56wJgXsm8a20YG0gz2qim98nr3MqUdU4O0DWmC1GR79U3L9qNc324 >									
//	        < kA21EEMp8cEL1Mi58jnwj2sDSXD8K098kctT1eX28D8T53jINhgPd6im4D0jHwN3 >									
//	        < u =="0.000000000000000001" ; [ 000032971146920.000000000000000000 ; 000032977521987.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C485FA44C48FB486 >									
//	    < PI_YU_ROMA ; Line_3332 ; a6KEG09R52BB0JyzELH4XfK6pEU87y8NPv0CJl8E1L08XhX62 ; 20171122 ; subDT >									
//	        < kmQH25T5469ly71oDmf6JVT26qU19R88XnalNV3IcgN950AWWH80byb15467P9Az >									
//	        < k3182G1L423cn55s4NJY4Z5w5Xd12J1niBcx91Sg5luP4XnDm5QsNpbIXxJ3o3ej >									
//	        < u =="0.000000000000000001" ; [ 000032977521987.000000000000000000 ; 000032989849478.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C48FB486C4A283F3 >									
//	    < PI_YU_ROMA ; Line_3333 ; R5eausOg52X9h0lvz41aTA745VeV95wYRkbRqIJBbKv2IFZ98 ; 20171122 ; subDT >									
//	        < Jiqi6RK4h71K3X8L5iPsYZ7s0Pp6c2vZ2h070Sv72EhwJt5u0soE1vP6n9EHjiq2 >									
//	        < 3f1Q2KGE9jKOaQ7jG81LDRAY7B5GVx61Hg73N49oBIMGm8HvyJC646R6lg79wT5G >									
//	        < u =="0.000000000000000001" ; [ 000032989849478.000000000000000000 ; 000033000121103.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4A283F3C4B2304E >									
//	    < PI_YU_ROMA ; Line_3334 ; dUUTgyq0Krc1de685YRbT2l58Rk9ssacTrjIS6Zmizx5Ho9I9 ; 20171122 ; subDT >									
//	        < 2Z8zY59b8764EG3H3z8do05dNpmtm2S4FNG71TI2cIjaLR94d80r0Q2F6Cl4IzYx >									
//	        < ugNK6Nh0SX3E9CYh8ciUTnJ7kHGsUk3uKJzFBB2qNYMCFIkUk93E9Hqjl9fwU8Zj >									
//	        < u =="0.000000000000000001" ; [ 000033000121103.000000000000000000 ; 000033010762963.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4B2304EC4C26D48 >									
//	    < PI_YU_ROMA ; Line_3335 ; zb8cM92D8peItil1q5ARg5pm69Q1s3S1W1zJ5Rtu09X26f16K ; 20171122 ; subDT >									
//	        < N650WV8mLgt3TeDnF7Xov8iDNvPQpYzf9eD560Z0MaRnHW5OKIPn845Q19iF7L2S >									
//	        < 6kQOg398aXz0cTYy992AW94PRmE0lU221iHC7Xq9159FJW044f0BpVqkyFqo5eqg >									
//	        < u =="0.000000000000000001" ; [ 000033010762963.000000000000000000 ; 000033020966789.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4C26D48C4D1FF26 >									
//	    < PI_YU_ROMA ; Line_3336 ; 8LK6267XL3Dg5XXIKg9rs25eR9Xpuyy8uhvW2jpiHhdwSA1E9 ; 20171122 ; subDT >									
//	        < 5q7vGA9KNZ25xhn3IwpwPcDH4080vK8JvFcHK1Hx9C0J7GU7Wq1RQX1Dy71112gg >									
//	        < 6nnZ626Lzin34JxpXp5Mqy7AiUtXVoSANfhd8jFeC8zF5mJYui99uT56t2I25x8M >									
//	        < u =="0.000000000000000001" ; [ 000033020966789.000000000000000000 ; 000033030109911.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4D1FF26C4DFF2AF >									
//	    < PI_YU_ROMA ; Line_3337 ; 9qVC8RibldijX97cFGGKHWDEM190011K8XmJ2xi2UUWGs6Ivw ; 20171122 ; subDT >									
//	        < 0Z12zM9vpBo6FoPEVFIf8nXa08g3n937edj3B49wAIA22OSoI8aoQ98r2OU7W6n6 >									
//	        < SLnv6CXhv4VC2Q3VGfR0073p5Bz2AN6qEyDnt9Z60s4157dk4Hsz02JhuH7ot526 >									
//	        < u =="0.000000000000000001" ; [ 000033030109911.000000000000000000 ; 000033038435175.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4DFF2AFC4ECA6BD >									
//	    < PI_YU_ROMA ; Line_3338 ; bFHin2296sH67SewpLQIwk4g2ApetG85PFt8w2j57YSh2q5f3 ; 20171122 ; subDT >									
//	        < DxhXcGRg9M2kVkj752nqQXuou17Alncf9L35B08tswOEEvFjGIye5YDqNadOmCoL >									
//	        < 87mhHG5K1I2O60Bv8F83XpGoHnaQei2mIoN7L705QQPAswHtfl8kB8005ZtyA2rR >									
//	        < u =="0.000000000000000001" ; [ 000033038435175.000000000000000000 ; 000033049400855.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4ECA6BDC4FD6235 >									
//	    < PI_YU_ROMA ; Line_3339 ; i4bU1CeIU25hq045h77RJ9IZ3pJg3UoLlIVKnSSWRDJ0jz6c6 ; 20171122 ; subDT >									
//	        < JSmMTJ7X5Fey4CraPiEav6q6sAMHYG5m9a62XF1Xy0H1K484rW5NT88QEHt3H379 >									
//	        < 026T8L18dFqyAWWgii43XR438ALZ7krdsk41CA0oPlP7rwu28oS1Gq9kZWS5q99F >									
//	        < u =="0.000000000000000001" ; [ 000033049400855.000000000000000000 ; 000033062343085.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C4FD6235C51121C4 >									
//	    < PI_YU_ROMA ; Line_3340 ; 3mp455s2dThH8H1r89s8p51ri0n6gzwWzZ39pQsF1mfaTJwd6 ; 20171122 ; subDT >									
//	        < 6eqFo8z4hvOJC2z67iON0BrLB5A624F1x5fWA0oNTNSeooX2L4zWPX3iERIIWaO2 >									
//	        < 31cN4RKwG9X51GXEiZeqHA66kj4T48RV6vdWT6m3J6RW4IURaV3SoWK5i918B01o >									
//	        < u =="0.000000000000000001" ; [ 000033062343085.000000000000000000 ; 000033070346204.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C51121C4C51D57FC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3341 à 3350									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3341 ; S4aErO8s3pq25bmv7S3veyJuOwwxkkgtHt5Qo2qcNS9rd4Jl0 ; 20171122 ; subDT >									
//	        < sgreS5142p69B60u2mjCt1umYMLA8hhix5ei0Zc9Gr2L4Bdm88ZUL8O33fm4jBUv >									
//	        < qRSxf2OhlnJz1lSDe5DP6txybYW5v0RxP109ireC82cWxA145dQe5IdoPnz42A9x >									
//	        < u =="0.000000000000000001" ; [ 000033070346204.000000000000000000 ; 000033080191484.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C51D57FCC52C5DCC >									
//	    < PI_YU_ROMA ; Line_3342 ; 9qW1cJbO8wCM2z880wNoyH0nXo6OYO19OVygP2c4678L5219n ; 20171122 ; subDT >									
//	        < a32Jg8cf7H6L5FWOcYm13hlDsh3mlA26Cmt7hKOaz5689fW2UPO2vH2s1lKt3EmG >									
//	        < uPuzWC83P1nawJ4e3Ic7m2Ijd6K90tZZd8DjAGFHrNq276n3M79eC8w7h6v6RG7A >									
//	        < u =="0.000000000000000001" ; [ 000033080191484.000000000000000000 ; 000033089317791.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C52C5DCCC53A4AC3 >									
//	    < PI_YU_ROMA ; Line_3343 ; zav0Vs9bG0Dn1Ouk7WVjks9o3Pc5k5t726tT4h6d9fQccth3b ; 20171122 ; subDT >									
//	        < OyOe3McM4ANpD6N20Yb861Re126xMXdbzF4OT9aT7bz7AYj05C9uWejWDNGle9O6 >									
//	        < 1vZXJb67L50ruEPXvZSA1h7lFj9XrfW0h06MhiRt75q15UMp8MJie8u5EbwVgjCo >									
//	        < u =="0.000000000000000001" ; [ 000033089317791.000000000000000000 ; 000033102048595.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C53A4AC3C54DB7BB >									
//	    < PI_YU_ROMA ; Line_3344 ; k5l68dbQ91FaLHA3wPm0k7X48HMvn9Ockfp5Tw4Gng5K9OuxB ; 20171122 ; subDT >									
//	        < S0srYUaXD50Wzv71HA67h0ps13K9X46aR4PC49VGQC84s74RhB4WrsB3H2bV97TE >									
//	        < O98v5tFF49HCp3WmugE7Z5xOu9vG88sv5949aEf66947W0TFw65Ga81vFk9meL3e >									
//	        < u =="0.000000000000000001" ; [ 000033102048595.000000000000000000 ; 000033115323624.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C54DB7BBC561F94A >									
//	    < PI_YU_ROMA ; Line_3345 ; 3l978XpgR5i6S3LOGH3lMEffX4Otq5AJ9q3sDMw8G40gebV0P ; 20171122 ; subDT >									
//	        < c5LZg9fq33Ev46J7i2QTLYyx6K0N0PYRrpygl3r8yv50V29Rrr86UOoHf2vB380t >									
//	        < 9eAfA77L21o6Au8iY9D9alsWMkR4lm05dTY68yq6p6EvGX03l1q80o7cnls1eal9 >									
//	        < u =="0.000000000000000001" ; [ 000033115323624.000000000000000000 ; 000033127311475.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C561F94AC574440B >									
//	    < PI_YU_ROMA ; Line_3346 ; 0U15nbVAG0m7Xkb6WSqqcS36k9p1eMZ6h0oJ8DaEFJ0B4dN3s ; 20171122 ; subDT >									
//	        < cy11pZ5Ts2Qz876EG8zqD23LI1jq8SMjEXy06u9noEV1foxHovED5T322p5dmyv1 >									
//	        < sn4EOj98IE66So4Kn41U4T9cI4kVLI44HDN1rlQcx8Gs84p0zcSlaT03Dm3ZH43m >									
//	        < u =="0.000000000000000001" ; [ 000033127311475.000000000000000000 ; 000033134474427.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C574440BC57F3212 >									
//	    < PI_YU_ROMA ; Line_3347 ; gTiL39jF38jG8knuMVCqXd41V6tCSMVv6Cz7782w7467yWxxB ; 20171122 ; subDT >									
//	        < uWIYAD01W23W41sIa3uyYf624AwmJ86nod0t6eeOy314ig4N5aC5GkvO1996I3G1 >									
//	        < 5MZ431Sib36Zm9MH328v7eh56nu88VRR5zG6SThagy8I5wIQ3HwRsrB7TU5p87Ad >									
//	        < u =="0.000000000000000001" ; [ 000033134474427.000000000000000000 ; 000033143411641.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C57F3212C58CD52C >									
//	    < PI_YU_ROMA ; Line_3348 ; o76PfZ7j343b85kxH75wRB4IC1wxkzs5u40o10Yqfscpx6r8e ; 20171122 ; subDT >									
//	        < b615vM6Ah0o2oWEDwS89c07VCu9UUHjxgm86Hx30ixbiWo23h61bGLvhTt0xJU96 >									
//	        < U6996q2R0m85r0r55PN9Syy8UV60qM7wNxJJS6q5K8hOzBRRMXmKpTnRB7Xmi23v >									
//	        < u =="0.000000000000000001" ; [ 000033143411641.000000000000000000 ; 000033152185810.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C58CD52CC59A3895 >									
//	    < PI_YU_ROMA ; Line_3349 ; IR91C6u9xJsTgBO0NyPUTWpZNndtZwH3lxTraCX392XqjY36h ; 20171122 ; subDT >									
//	        < 8FSMx174M0UcHX89I34Ujxoiaovss83or0B3an6gK9d8Pk9JjX2eht2Nj2d3KpUR >									
//	        < t303G3DeHsIoZ6Re9572XYG5p78O58TVgGeb8686Nj0tO03b8XOwhtoiDspT227Q >									
//	        < u =="0.000000000000000001" ; [ 000033152185810.000000000000000000 ; 000033166140548.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C59A3895C5AF83A6 >									
//	    < PI_YU_ROMA ; Line_3350 ; x2xNIvikpsCjees6c34yi4gNL1eyC3Rg1c9K059DxYrS6JT9P ; 20171122 ; subDT >									
//	        < 3ird9DRlMPO64Gfl9Ej1w6b42T7H88OG5nYMse2cSxSoYSZeO063iWU9cbY7D16R >									
//	        < cldpiWsXA655c2Bm0XiooGxr2Ec5e55NWxR00p3KW8j28RFTwKI5G8MFuj43wDdA >									
//	        < u =="0.000000000000000001" ; [ 000033166140548.000000000000000000 ; 000033180856384.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C5AF83A6C5C5F806 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3351 à 3360									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3351 ; ULo9UopG09xnm7f89MU6VrYTv4H1ToS6yHtUnX3TMV88CO6ca ; 20171122 ; subDT >									
//	        < zoaRM56UKtnPyuZcoEypECmDpd17goVsCbpFqAb22d6Mvh8H99az3k2aypkPchEs >									
//	        < MWv4Nv5qCN25KsddzI2512blWxm2Por6o37Tb7dNZnn10VLwCXdszx1929G90i4A >									
//	        < u =="0.000000000000000001" ; [ 000033180856384.000000000000000000 ; 000033189921803.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C5C5F806C5D3CD34 >									
//	    < PI_YU_ROMA ; Line_3352 ; e5WpVkGgAz5t01c1V4Crg5xvHmT3N2xbnp9MrhzQFj48mxO3D ; 20171122 ; subDT >									
//	        < OQ4brDDYMe6XMc1O28Gfm4s8do9f99F8tuFFfs6mDPLVeh4i64ebg6oMA33ZrpYx >									
//	        < DoO7tXBF8r5KVWj6JSosc2i0b78kt8Nb6748sewK4c94T5gK95igTmrN2xVws02A >									
//	        < u =="0.000000000000000001" ; [ 000033189921803.000000000000000000 ; 000033195851887.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C5D3CD34C5DCD9A4 >									
//	    < PI_YU_ROMA ; Line_3353 ; 98NOGaKg5GaGtVO30weHh1g27LBB1YCa5gKrJ43zcI0WKDy29 ; 20171122 ; subDT >									
//	        < uYZi0y3wqTcDf3s59d4VtC8MTT15o8803i85qIs9ii54u74U0247n7ESL8tbK7lb >									
//	        < qbyHIo7T6YBJTTT70NH3vPm0NghayI5L03hL047w8SZvf4B50uvJYs2kf39WaMbR >									
//	        < u =="0.000000000000000001" ; [ 000033195851887.000000000000000000 ; 000033206133956.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C5DCD9A4C5EC8A13 >									
//	    < PI_YU_ROMA ; Line_3354 ; DFzee3hO4G2Vbh9W8eY98M0WS062V1bSI8W6E2kpkChqQ8is7 ; 20171122 ; subDT >									
//	        < 6Es888f626c71yeSU73W3NU8UYBJG6Cv4130vd4Jx0w4B0H56ot8Ia45R3Xqw40e >									
//	        < I8TV45tR9iEnS5jW8xF8k48Ao6q8R9HVTu9FpT0578N8eeMkAoSWtZT64t690cvN >									
//	        < u =="0.000000000000000001" ; [ 000033206133956.000000000000000000 ; 000033216667685.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C5EC8A13C5FC9CD0 >									
//	    < PI_YU_ROMA ; Line_3355 ; htfoMz7waoIn9i12L6pF3i87lTG3Yb16O4X19Rqd8y20zgL7o ; 20171122 ; subDT >									
//	        < Z0p327XZgi3FVmraBMk5mqH6Xq3uxvtym5B8hq7l7KIpxJRhZZy6iUNx2Y4Gx6J8 >									
//	        < nX57hGS0343wTj9oJ70rL0u2ALQEEBaF8rQ221A2G9hjju169Av6X27UUIT6Gog1 >									
//	        < u =="0.000000000000000001" ; [ 000033216667685.000000000000000000 ; 000033229648205.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C5FC9CD0C6106B54 >									
//	    < PI_YU_ROMA ; Line_3356 ; q1w4vyRrJPT6EvdEO8165xdpKJM5w8eh53O4T6i5jUA87w49o ; 20171122 ; subDT >									
//	        < 1U54yr3xEJFBjl5e2Et5RPq1Yl0wUAN6nTqcGNmrt3oIQ0cWl2zVx0yBR06zDe8X >									
//	        < J5y52Pnk8j5fPpJ6ixjkvl9JL9jCtvJEbDzw0cNk74d726e6yalAUgU192iLk06j >									
//	        < u =="0.000000000000000001" ; [ 000033229648205.000000000000000000 ; 000033244304397.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6106B54C626C867 >									
//	    < PI_YU_ROMA ; Line_3357 ; Pb25vfeYLT3O7wppERK4E2u23VZOXg26uQyr0NXnU17IaaX47 ; 20171122 ; subDT >									
//	        < lOi7aEqj7SJUYi6lOvN08K9YCiK08a2a1sbA2l2KhiN8s07QB5hJWw5OQ68G88fg >									
//	        < mGY95PvgHwjQ8KL4db53w8x68Pa7cR2nHHDQB73EVp31rwr0BYPP2q7qXeK502U8 >									
//	        < u =="0.000000000000000001" ; [ 000033244304397.000000000000000000 ; 000033255735789.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C626C867C63839CA >									
//	    < PI_YU_ROMA ; Line_3358 ; 5I3yLmAvp1mVxXqPtHJjN5c937N7Dg75HdlpHyODjaohT5FCI ; 20171122 ; subDT >									
//	        < 3Qk4usgoPfO0F40qfBK8lYiljm51v3r4F7t014xi20fyaWC92z4MI1N3T4t64xcW >									
//	        < jn3npxDZ4gDpopQbdm60A3Tl8J7O00FjXhsOldY5jkdH5glotWnSF6FVX5LJG1w4 >									
//	        < u =="0.000000000000000001" ; [ 000033255735789.000000000000000000 ; 000033263983466.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C63839CAC644CF8A >									
//	    < PI_YU_ROMA ; Line_3359 ; rSVS7QY1ih6TjXX8X8qidq0ZvIHX5hgZuUKMdW6gi6fm35U7F ; 20171122 ; subDT >									
//	        < fImNZCsZi8teREUNS5s6HJmk66aNq22rg12913sJuP9W5ZMj03AZJ0ePI5a104dp >									
//	        < gtTRosa470idigk484tsibS368Lw5mZ9x1xlJ4t915rTwl7P395wWbfKDzWEs222 >									
//	        < u =="0.000000000000000001" ; [ 000033263983466.000000000000000000 ; 000033275716769.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C644CF8AC656B6DC >									
//	    < PI_YU_ROMA ; Line_3360 ; 27A5l1bRY65Ko79JsuIL6yP4JUkSrH5ljJ683K1BwFjzOh44w ; 20171122 ; subDT >									
//	        < w95a085sU2t7QBq98BF8GdQ75WJ2PejUS247Z4xqjZ0z9zlz476P314fr7Vr6nQ7 >									
//	        < j28n36K7z435yv74JDKkJ8O5oMSsG0Vr57KfN8gdJ2vuMT6HuXZ62I2wp718Ysq9 >									
//	        < u =="0.000000000000000001" ; [ 000033275716769.000000000000000000 ; 000033285286971.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C656B6DCC6655139 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3361 à 3370									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3361 ; mxl8PTx0puYL9pZZ35Zni2uPQ5268c1SYw1y4q5E7jig1L45M ; 20171122 ; subDT >									
//	        < k5dovj8ieCrgCIW4H3fklyT7vf3Zjgcqds717EbbVH7Z9x6KXc5LVpX57o8YJ8lm >									
//	        < mGUCiL3D1q9rJy27PQ99BUsftWYaJFtIsSUpk59Z86LN7qEsdDY2x7XfM8RhZOg3 >									
//	        < u =="0.000000000000000001" ; [ 000033285286971.000000000000000000 ; 000033295914168.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6655139C6758878 >									
//	    < PI_YU_ROMA ; Line_3362 ; QA1F061T6a4zv96Vm2KzS6WBiapD005D15l88116H5rAxh7US ; 20171122 ; subDT >									
//	        < 28VwAMldHf4gl0Yb4n03T0eXVkaaLPPSqSMPQGMFB9GeHSMUD8Z6DQvt91G89mrQ >									
//	        < vHcx3QVaxIviFdrF54jtS8Su1EMHwB1sIl060Beo73COTZ95w8vbAa4RBJ4BPOB0 >									
//	        < u =="0.000000000000000001" ; [ 000033295914168.000000000000000000 ; 000033306914650.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6758878C6865189 >									
//	    < PI_YU_ROMA ; Line_3363 ; Jp03DPpEr3pt0u5A8dt8PC5b8A5Lhc5INYuwqZ0uI27R25r15 ; 20171122 ; subDT >									
//	        < F0OHCtt3iDp0UL0c2zR156x77s7ex03kif9RhwRK7M6wr39rPTk8625zZNe81eb1 >									
//	        < ozQsoKEmJHhoj2lY5jR74I76UOycYF17y8EcAhNA1FEsqCTRiz5Lsk3ELnK18PtG >									
//	        < u =="0.000000000000000001" ; [ 000033306914650.000000000000000000 ; 000033316740527.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6865189C6954FC4 >									
//	    < PI_YU_ROMA ; Line_3364 ; 954C086z67g03rb4d74t6yJ93xe8soj99X99SGiik5x7FC5m8 ; 20171122 ; subDT >									
//	        < KHta8NCv8LvI813ORMWb9yP2jSzSn9ze8E0WeB11YdE87WSuRE3iE7ZY0Q6gFN2Q >									
//	        < uVyUPE6wLKh55UFk4e9Z4Ib0udJw6pAtu4bPfh744r816h5p1M4uNKek26SzAjlO >									
//	        < u =="0.000000000000000001" ; [ 000033316740527.000000000000000000 ; 000033323424076.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6954FC4C69F8287 >									
//	    < PI_YU_ROMA ; Line_3365 ; oz5hFdYh6Fa0fk5x1h33214I4K4t17Vy6xw6eLT7c8Y9IhO7O ; 20171122 ; subDT >									
//	        < n933068gMUxOS38lI3583520UvCH2S3qYlaRmK6l49dO0j650HdPJix68055Eo35 >									
//	        < aMcTmHw4gw4s7f0r1Be8R4vA717aMUW3tN46l3T3v0Igd0e0Ef9DAvUFD68mI1KV >									
//	        < u =="0.000000000000000001" ; [ 000033323424076.000000000000000000 ; 000033334706391.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C69F8287C6B0B9AF >									
//	    < PI_YU_ROMA ; Line_3366 ; Zm681T3dPN1X5Tl57QqPOvv646k2Jg8nad0JYih3YoKoS2v52 ; 20171122 ; subDT >									
//	        < w655C0vW32VHaTP6ZBL1b0xo414EsZBYimw4sFRYQrI04CYgoRQVF15N5DBY7Ab8 >									
//	        < 3Rl55f7H8NdGQ50893I3p9H4TPQJt800Jlx6ojw0T4couzJAv9z6JZ1o9F6D17q1 >									
//	        < u =="0.000000000000000001" ; [ 000033334706391.000000000000000000 ; 000033346650623.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6B0B9AFC6C2F366 >									
//	    < PI_YU_ROMA ; Line_3367 ; 0kTF8Svc9r81CFaqi7M9693qlWQaz9wETWPZDv9G467aui4hU ; 20171122 ; subDT >									
//	        < 821zVMBy81tT7e6kITbh5rsilrU3wb6hCrKeBqfo5PmrZ8CIuIdfw51D408Qk3jD >									
//	        < KuAKwbb4aMj67tze6X0iG3WsMw81SV43jj3vqV8HQ0vlFszgbWVhoxMOm4IArAjj >									
//	        < u =="0.000000000000000001" ; [ 000033346650623.000000000000000000 ; 000033351792274.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6C2F366C6CACBDB >									
//	    < PI_YU_ROMA ; Line_3368 ; Nbxg4EF1m54h9dIs8N6UTjbRY39Xsg73lvh7Q3lxB3ceToYn8 ; 20171122 ; subDT >									
//	        < 09kC3ujUexas5azLRjN7jPClZtFXrVx1It1Q35k1Z12xj96c6jhlZHiKrq20Z3V7 >									
//	        < rpUlD7vvy6Cx4Hr5w9raBkE8898PEGHOkFE6jW054bLiIbcaCW527Gmv53yO3wT8 >									
//	        < u =="0.000000000000000001" ; [ 000033351792274.000000000000000000 ; 000033366008707.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6CACBDBC6E07D26 >									
//	    < PI_YU_ROMA ; Line_3369 ; P1U4077yJuXS8ntCRPA1NiKO72j9ibL5OYFF94e051gYM2GdU ; 20171122 ; subDT >									
//	        < rAVbkJlS5jQqQUSjPX7w2605vi80D157agADAg86giqgwz6XBIo9Oz1nDV0X3E3y >									
//	        < U1ACvPeK4jgrJnAjDQVJ9ToMM0ye4mxEaQPZ9E04W7PRgPdPjRI421a2I0b73F3p >									
//	        < u =="0.000000000000000001" ; [ 000033366008707.000000000000000000 ; 000033379241331.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6E07D26C6F4AE25 >									
//	    < PI_YU_ROMA ; Line_3370 ; 7Ae2482K4gKBVg20v91HJRr4vvxYMltiAD862HsqabRMy0FZN ; 20171122 ; subDT >									
//	        < w3hpH3X7vfKuAH158BmLk45ljpM4z6cZ7u5MS374dJ0db7yQ7Lagz1rtUKLz5D8a >									
//	        < MGlQhbZS5E6S34zO4YUodGs1l0yz9O5H2d9V0sWFvitV07S65VWI24Ui7S1WO5s5 >									
//	        < u =="0.000000000000000001" ; [ 000033379241331.000000000000000000 ; 000033391450898.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C6F4AE25C7074F81 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3371 à 3380									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3371 ; yNi9204iOC6K70iyR09Iyu267SRHIR7G417ctl4OQoznN54co ; 20171122 ; subDT >									
//	        < nBvK0cuj54b4H21SpALq6IiB6N9OM8brs0zD03nOUfNa2iei0w0b6oxtHuJMdYa7 >									
//	        < 22x5z20RB5z8z19hmZdJQPKO7658CdsmuKbX0YN231pIhcTDeYd6b8P584QdC9rl >									
//	        < u =="0.000000000000000001" ; [ 000033391450898.000000000000000000 ; 000033401915793.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7074F81C717475B >									
//	    < PI_YU_ROMA ; Line_3372 ; kAfD5b8P4gqWpY32Vm2dBTIU7vdu6E1c21o7l6IR0XPIBuA74 ; 20171122 ; subDT >									
//	        < TA2gt1FuZY7s45iW32Ff8Mf4D4uyyNIl3J1n2emYDBLGPTisE9O85vGluF38S48h >									
//	        < 502xmR4833J1CJgpIcLz74OS4JFqfvchlISuO47HuREH5Gv24PpNM94AqH8EOhh5 >									
//	        < u =="0.000000000000000001" ; [ 000033401915793.000000000000000000 ; 000033412511960.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C717475BC727727C >									
//	    < PI_YU_ROMA ; Line_3373 ; G7HveDaB14rnT4Yk3t63oI9SozvXvi3YTP603Xk58j938vXp5 ; 20171122 ; subDT >									
//	        < THh7Hp4r64yf6w763PY657y48TA00I5qZxr31VLYzQB06RRP9NjkP71tIUzIANfI >									
//	        < Fd087T59U3dS3e9z72bOICZw85q20J63425QABkur38EkhVDnzRrRz2C97Qh1wa3 >									
//	        < u =="0.000000000000000001" ; [ 000033412511960.000000000000000000 ; 000033420346396.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C727727CC73366CF >									
//	    < PI_YU_ROMA ; Line_3374 ; JeR2bw193s0CX995fDWzEJ4yY50G5nNbxAZDC7u4GoG8SVL0B ; 20171122 ; subDT >									
//	        < C00t7aUa7V6y603V451u1VQ6337H513DWkh383V6wpg7q5FAY97SlEXxOq7249FK >									
//	        < y1jG6RBr0WJ8QCfYn9KZd0yF2LrQyRsA7FeyaO731o2zsENs8VJGF2VR4q21se8S >									
//	        < u =="0.000000000000000001" ; [ 000033420346396.000000000000000000 ; 000033425470437.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C73366CFC73B3863 >									
//	    < PI_YU_ROMA ; Line_3375 ; B6N990G7ZburaM34mLb2fBLS4Rpv16u852Ks3SCd7sKzcPAcY ; 20171122 ; subDT >									
//	        < gJ9Q33P6zxxrMnJlh2vSr2m1mKbyA60i8y3O5VE8vC7160hhCML73w78GMK292vt >									
//	        < yLfS0qbc38Ddd7r2f833ny717czTFN8AQPMbVSXuwQnP864Y8W23DqL8u7jru23k >									
//	        < u =="0.000000000000000001" ; [ 000033425470437.000000000000000000 ; 000033433094179.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C73B3863C746DA69 >									
//	    < PI_YU_ROMA ; Line_3376 ; 73MP0dAsx5a00GiNFd285AyT4mOOeR9m5sIy94Ah0HPz9ND2Z ; 20171122 ; subDT >									
//	        < bL5lg4yijhxgpnAc728iq66901IeekpzEt52aBPEQ996po4RGjTA9RyFI7c2a0RQ >									
//	        < C93rxe6y7B80cuh02D0xh9U82XUnBnhHtRS928lSlC4gGVpCqUHAHk9own2f13wg >									
//	        < u =="0.000000000000000001" ; [ 000033433094179.000000000000000000 ; 000033440911382.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C746DA69C752C802 >									
//	    < PI_YU_ROMA ; Line_3377 ; n1F3z4jl5J5wl3G416B2R5dZ9A0h3XAFf3inEQRoAoaCH82rY ; 20171122 ; subDT >									
//	        < 3gJl341OG9xi16NDeA5YqvlC2W99f701FP5w401n5GCHENnyu3ZzficZ5MVsqJeH >									
//	        < 3SVV40EDjBGzMRO02WVoCzyv32dHk2rh99DhgH970Bi4R1oo9Mi3TSBr64R3eWKo >									
//	        < u =="0.000000000000000001" ; [ 000033440911382.000000000000000000 ; 000033452383131.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C752C802C7644929 >									
//	    < PI_YU_ROMA ; Line_3378 ; NC012Jk09R47e0YJg2A3arXYGOpM6EGpyng55m07noR37LdS9 ; 20171122 ; subDT >									
//	        < ODNqM6O7V2ciHtNmIMvGT09Cp20gNC8dejSLmb3X0VC4ipx3A7z56sUj9a8xT6xp >									
//	        < RQdtkBtwKs9nRZshPyh6R1qVG23z9cq4gxs2uhMzS0bhR29tX1wopycRQPmFH05N >									
//	        < u =="0.000000000000000001" ; [ 000033452383131.000000000000000000 ; 000033457856931.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7644929C76CA35D >									
//	    < PI_YU_ROMA ; Line_3379 ; 3KkiuFxO6TWfh1G8Z0CbY33n008w0Ysznro6nnx22QxTNu6EJ ; 20171122 ; subDT >									
//	        < 90g1ppO9CM4A15ni3j59Uu7W71b66V91A9y2vxVccV869OfpaKU0cu0ziR2RNwtX >									
//	        < l1yo9JWa9chY2j3JU7ZHN922Z8MR9vR2u5yA82dc1aZv07r434cfWCv0R058W34y >									
//	        < u =="0.000000000000000001" ; [ 000033457856931.000000000000000000 ; 000033469339303.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C76CA35DC77E28AA >									
//	    < PI_YU_ROMA ; Line_3380 ; 6FZePRN27DG1zBbJN17Ik50z8KOOmmW2d7Dkw5KLlq8175Eyc ; 20171122 ; subDT >									
//	        < waXk5auAIC8z2ZbFO8kr62wOD7k7wUU87zugstc5DUfhy0huSGP0Gb69S9Fzbi2P >									
//	        < Zmc2DDGn87ewaF8VaURSNbV76m6RIHr5tMie999Z75hFIL7Np14YOy8K1HepXNv0 >									
//	        < u =="0.000000000000000001" ; [ 000033469339303.000000000000000000 ; 000033478761733.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C77E28AAC78C894D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3381 à 3390									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3381 ; D1H65pzpTvcV4L143C8IVWBwl8gbHnx35b3R9kuwVYshIcC0k ; 20171122 ; subDT >									
//	        < 26lSI984Z6LWUO2HFYx8yB3z42uEXsRU2Y234cfXN6WU77w5565zLAbl0t8gWH58 >									
//	        < 2n7gg082l2NIvy1MXs947BpVi3wY264LICm0VXB5Tl06bymQ1m80kgSIi2r3NvD8 >									
//	        < u =="0.000000000000000001" ; [ 000033478761733.000000000000000000 ; 000033488083838.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C78C894DC79AC2BF >									
//	    < PI_YU_ROMA ; Line_3382 ; 909MmyUX763j5835Fd52M9b26pQ1U0Rgy96P1UOdzERSJmjWy ; 20171122 ; subDT >									
//	        < 3qr0L7dv6fw6wtL1Xg1k02m5I8eC1eTcqx79Qg994YLLZrGTU246F4VFq15qziYn >									
//	        < o2gXT45kTj21q3X0q86X4dwb3Y0E9tyoEE6tevQh8lLCa74LJjjVkL2An77B5aIG >									
//	        < u =="0.000000000000000001" ; [ 000033488083838.000000000000000000 ; 000033495999193.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C79AC2BFC7A6D6AF >									
//	    < PI_YU_ROMA ; Line_3383 ; 9951OsZ7HJU5F4pS70m2WL938046NLDbD4r6u1903yjiX6eDC ; 20171122 ; subDT >									
//	        < 1K5GgNO94v6Kx9X9X6d7U7w1dLU1e7VufFu22QAeE8hBs8dLrcfZ5gl30X8t6aCx >									
//	        < 9bM7K75KA30YeDZpdkeX3EraWzMxwLwgT4BO468AUrz39Q1FOy8JiB242n2GXhMQ >									
//	        < u =="0.000000000000000001" ; [ 000033495999193.000000000000000000 ; 000033503497627.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7A6D6AFC7B247C2 >									
//	    < PI_YU_ROMA ; Line_3384 ; P2R8MbX0lo5IhD535aKJy8PdGdJctx2jJUJUlO26H4DubrYDg ; 20171122 ; subDT >									
//	        < 13OploTKXvj1w027E6PI4Z2k6jtc1Gz18MGGqHg49sBrWdGhMM84stw2Qfxhu640 >									
//	        < s739R6C1p3k3U68EfG9e8BWmn75LY6e82GAIrwEL4dFU0a20dq5tgyu50oWaZFOD >									
//	        < u =="0.000000000000000001" ; [ 000033503497627.000000000000000000 ; 000033508677622.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7B247C2C7BA2F32 >									
//	    < PI_YU_ROMA ; Line_3385 ; UE6Hvydayoa2aBmt5TEWY1v3INmHO354S7qiLc8bdDZT9txFR ; 20171122 ; subDT >									
//	        < hTD8WSem7FF17Z07QseB7Fet6zS7gJGBNb11tHcrc1lA74RX6114x02yTcY54A7x >									
//	        < JVvOlnZlI2RYgnjh56wQO3qYjhzbv5dWXFzAKx59qCWvg73mb08AM56Zi0Q9WByQ >									
//	        < u =="0.000000000000000001" ; [ 000033508677622.000000000000000000 ; 000033517730756.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7BA2F32C7C7FF93 >									
//	    < PI_YU_ROMA ; Line_3386 ; jgT259CAvh5H5ow8A0ssxuqDYm2qRCBFHwq809aoMk06G5cNX ; 20171122 ; subDT >									
//	        < K7P3Q6p8RvKSx837oJgq89URTO56Nt40d5F1ag87NbGaycj6v0VTXc5UO566NoTU >									
//	        < dKm1a8B55Q0pH04JOji0KPgvz7f7KNr3F8rowjrHY22uik6mp46ntm6rb8VxRYB3 >									
//	        < u =="0.000000000000000001" ; [ 000033517730756.000000000000000000 ; 000033525976324.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7C7FF93C7D49480 >									
//	    < PI_YU_ROMA ; Line_3387 ; w2L8MVKXydTV980Idy6434E11pfau8J3Y528L7OQ0i53t84b2 ; 20171122 ; subDT >									
//	        < 5U6tpDrWfpf0Z87u132L9eUNND9boQx2EqrwxWI5bH7jlz8BQzYazi13v18sKA4P >									
//	        < esAoszm31oCN7L2sQ79b7n0y93nNki23bd480D3gBeP9830w716rwx44TO3f88r2 >									
//	        < u =="0.000000000000000001" ; [ 000033525976324.000000000000000000 ; 000033533475397.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7D49480C7E005D3 >									
//	    < PI_YU_ROMA ; Line_3388 ; JgVO147tpRxzc7u7c5D3M2z2W0qH9w7q5K4TM36j84w63yvd3 ; 20171122 ; subDT >									
//	        < jgSTF2RoltN50j8Zh7nPp3MWpMt1Cp2SwEIyj6v71Ut03Y6AoTR6S2C2QNVd7Gd7 >									
//	        < VG9yINPkp18Jsj1XwmsO1nUSY07ytmO7YeS2EI6XTyIiie6IwajN3J6I24BLh0D9 >									
//	        < u =="0.000000000000000001" ; [ 000033533475397.000000000000000000 ; 000033545919772.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7E005D3C7F302E9 >									
//	    < PI_YU_ROMA ; Line_3389 ; Q8Q5ljzS8kRYC9q1FV1B6lwxr090ZRLxp5Xzw1Cm29ZXu1Yll ; 20171122 ; subDT >									
//	        < 50KDfs4Oihb3lZg138oLRi0fSyRZ05Nk0S0cj0nRAe6ud3E9Q7WZDz1Rm8dPmCon >									
//	        < QjNLuIMW4XXmy11TFb9GDOj7E5A6460T97CV8I5I5b32tpFUZ50A033A3HZ894Gz >									
//	        < u =="0.000000000000000001" ; [ 000033545919772.000000000000000000 ; 000033552879142.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7F302E9C7FDA16A >									
//	    < PI_YU_ROMA ; Line_3390 ; QnSaoV5j1V5SZXL7VL4DRwaig0J6Mi6Nt7by5M3vVFq281Hv5 ; 20171122 ; subDT >									
//	        < nuK66DoXY2D23FlqS2Sx831RpM9G36tX8gUKB5xwTSEm2vq5kX8Oi3yd550rN4nv >									
//	        < 66e2Muu7153s4sk7fjUMt3wm6ru2GYWXk920T45uxCC3P1arCa21MUlB278lS944 >									
//	        < u =="0.000000000000000001" ; [ 000033552879142.000000000000000000 ; 000033563653524.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C7FDA16AC80E1228 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3391 à 3400									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3391 ; 61rQ9v7uS318C39E2w60mK89A600AUTzhH41zt0M027in2V8H ; 20171122 ; subDT >									
//	        < 8pX1Fy71oSV3rh12B4uk1JBDtBe4jx8p45REcrP278ulzn8G1GeQO4p099qrTGm0 >									
//	        < BXxgv2nugHGr9wYFhCvsYk58sjGPkwB45Ac9OkctNKhgiz93XGlU19UR52khp0O4 >									
//	        < u =="0.000000000000000001" ; [ 000033563653524.000000000000000000 ; 000033569981120.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C80E1228C817B9E0 >									
//	    < PI_YU_ROMA ; Line_3392 ; o3Z7zQwSJM8527L6Pr7WkoSDFxS0Wg9CmdoHJWOc8UlwiP4ej ; 20171122 ; subDT >									
//	        < daiq0ew0D53n86zPF847T3uvYU00nu6P3CJ4T846ZHEPQ4WYeF8Vjyg4CctcJxCf >									
//	        < xI67ZH61piRtAf7j89112g9EkXZGbZXwjFw9zUNtxaT25DprRRv7893SF9PX1678 >									
//	        < u =="0.000000000000000001" ; [ 000033569981120.000000000000000000 ; 000033583074395.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C817B9E0C82BB46F >									
//	    < PI_YU_ROMA ; Line_3393 ; v7woymKoNk97DrJ6642S6ccrs2ZM221z83oos47h84067dT57 ; 20171122 ; subDT >									
//	        < JyTZoI79B7wmm18l11b14u858o30ppX9WQ3zfPM8fq42nn21XQ6P95qD46037gNi >									
//	        < H7CHZ8iGSBH5Iq4s9KzEusD1uAdhF14BeZBhog8zf5k0v6zTD62i4F5355vg8UW3 >									
//	        < u =="0.000000000000000001" ; [ 000033583074395.000000000000000000 ; 000033589215396.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C82BB46FC8351343 >									
//	    < PI_YU_ROMA ; Line_3394 ; F6ye5Cu2nYxBxvUlU4um3l25Jo7sAKM656ZA1YZ6qS02koQW0 ; 20171122 ; subDT >									
//	        < 7KO3c31Km97rbgu90BMSYql6kP4Sgmulk6aD3UL64w047B4wxIaH3F46w280xA88 >									
//	        < uKf7r60386cHTxz39TN2qJkRCo4w5exCjHkM19jds75v1mLX9E58nvQf2YYwb83g >									
//	        < u =="0.000000000000000001" ; [ 000033589215396.000000000000000000 ; 000033598041386.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8351343C8428AEA >									
//	    < PI_YU_ROMA ; Line_3395 ; 86m60q539cglDKCEVar6xDJhXY54zYt2HcnPj1fO791u11d3F ; 20171122 ; subDT >									
//	        < qZeHmGhwm3mLqy53G0pYH83zqO9ijKlWaO2AXCvQU4v4EJOaLC0xLWBtH4pLKBWX >									
//	        < LLm79l586pDZEVD5A05kX16xW3753cIpCDvs35bfDtW6k1NugrkI718dPnC6hH32 >									
//	        < u =="0.000000000000000001" ; [ 000033598041386.000000000000000000 ; 000033605466421.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8428AEAC84DDF52 >									
//	    < PI_YU_ROMA ; Line_3396 ; 8B6j4fuemnJ1RCnA1NWZQJmm5qZ18gUi4qevJ12C2q78lGogd ; 20171122 ; subDT >									
//	        < P2KZVrEHAI2M36IWfr8O78xqxQTiBcLDU3PZ69Cv3636I972jiOmvm24b42Ekmdk >									
//	        < 4mIP5fb2vHS473S4ZhZh69Ta6iBPz2vr47xDeS1TNE0Y1a7eY5IMZVJrAESlJcR8 >									
//	        < u =="0.000000000000000001" ; [ 000033605466421.000000000000000000 ; 000033615120841.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C84DDF52C85C9A94 >									
//	    < PI_YU_ROMA ; Line_3397 ; 7r1hYMZ75Ij0W7S074j7ilNnD8y8Q0zMVFA2p1elK20rQBfZ4 ; 20171122 ; subDT >									
//	        < 6Fmko1E8OO7Zyodc0Y2bW9Tq99LBrCLGqCGTKYiiTTFA8B7KiykCT688omkr9TK4 >									
//	        < URT1tst5BDrqwd17thl3w747qkAsx85AH2S8PA4W43jAIo7mhR61soFUQcPxcW47 >									
//	        < u =="0.000000000000000001" ; [ 000033615120841.000000000000000000 ; 000033620909902.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C85C9A94C8656FEE >									
//	    < PI_YU_ROMA ; Line_3398 ; 10wYt71Y0ty738UOCDqmM81LDT12I762RH9UHja3H02y8Koie ; 20171122 ; subDT >									
//	        < vIsC7u604izjnn15u5u86cg2aE6hcK494WomEjCl42jAc6KCpAqJutSe89gBg55W >									
//	        < LsA5tp3NIWm0ftHnPZuZ2ICS35E5om5f6xFyIbdBD698g7uxgr5JQJkD6V9A3V4l >									
//	        < u =="0.000000000000000001" ; [ 000033620909902.000000000000000000 ; 000033628789930.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8656FEEC8717611 >									
//	    < PI_YU_ROMA ; Line_3399 ; 8z6z1zX5533F179x8LbIIVi4NvF7rpX5Kpz2pPG4RR2eI96DX ; 20171122 ; subDT >									
//	        < gTzw3JkFxAdjk71n07kmP25QaBoL35129YQxUuUVh6p8E5ndK14L18ewV43K1g5M >									
//	        < 8E7g49cW4630YbcrGJXE8pdzI76a4y71TbW5V03nlBGhHo78ve6lhsWk8EAK1tz8 >									
//	        < u =="0.000000000000000001" ; [ 000033628789930.000000000000000000 ; 000033635625410.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8717611C87BE42D >									
//	    < PI_YU_ROMA ; Line_3400 ; fyVeY368923t84FpfI91424M95MDeBgLU7RGi18XBUsiR496T ; 20171122 ; subDT >									
//	        < WNzu08mZ8leV6DShkX6k1P9AN6993TGCQ2n2157404gwhPDSL85KV32IipN0Q1Dy >									
//	        < k1g022k2IoV04nbt6rZEinhXieHQT0nyuRh54PSikaRsUsi3GB35jZe1IOWCZO2Y >									
//	        < u =="0.000000000000000001" ; [ 000033635625410.000000000000000000 ; 000033647809561.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C87BE42DC88E7B9C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3401 à 3410									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3401 ; bHu2wRS7SEV57q9Z0m9lkz7B3sH7fps84sJTEjrA2bqXKNc13 ; 20171122 ; subDT >									
//	        < P87Ke7Tbg1CWe8AEw15Lot6BhVriqoV74o2N9BUXRl3otJ1WIE5E3g7TRNWnMCUI >									
//	        < 8M4OjsaRPoWFfvUlGAWp4W9a65G9aLbpg01k01im8qWcN4W0Gh2x6FaOZ4YN5MNd >									
//	        < u =="0.000000000000000001" ; [ 000033647809561.000000000000000000 ; 000033657461491.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C88E7B9CC89D35E5 >									
//	    < PI_YU_ROMA ; Line_3402 ; 8nEfIN3b2cyTf6MXgo52Dd3F04fpe6C56pYBAztIC6Es6Tz6c ; 20171122 ; subDT >									
//	        < 78XroX6gtPUJl2Q4b2Ze8GvjVWm18nKxFEIDUl2DF371b8NLDBy4PyaMK8rF130i >									
//	        < YPfcF8n7rHy7AvzJFWzjZEs266nzf4k9aOaU7Ru5pA9fXpH6j6I5F5u2XRf45237 >									
//	        < u =="0.000000000000000001" ; [ 000033657461491.000000000000000000 ; 000033663905249.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C89D35E5C8A70AFC >									
//	    < PI_YU_ROMA ; Line_3403 ; ks67CiqZcIhDj1p8w6L7WWJUs5G1WYUY9V4QI1atvW44926lB ; 20171122 ; subDT >									
//	        < 3bX2ij67pqa4nUmEo8e3vRFHmedv8MAO237jO4p7336gom5QBn2A56ZQM48K3y36 >									
//	        < 2u42VSY3S3pJNOm09V378110YF35umFP1S31vX7915DmiH29S1kgaf74lF47h4Dv >									
//	        < u =="0.000000000000000001" ; [ 000033663905249.000000000000000000 ; 000033675311830.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8A70AFCC8B872AF >									
//	    < PI_YU_ROMA ; Line_3404 ; RfNwm3U2DKP3EX8oNAAos7P3IPIi61uh2b1swFyMoS0Hl7U48 ; 20171122 ; subDT >									
//	        < K3qPPm6VoVLtgXZdSisef5gP4gYfQ8p547CUrgrr7CPvN3z3KW07ADaAhb7xp9V7 >									
//	        < 8Ki6ZU2IsAiYsL42sWlA0UsTW5URZ1HG0eUnaoEt4l5KwXHr8eBO04Qm6k0Q1g5Y >									
//	        < u =="0.000000000000000001" ; [ 000033675311830.000000000000000000 ; 000033688289934.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8B872AFC8CC4041 >									
//	    < PI_YU_ROMA ; Line_3405 ; 6mHzZ9364FHK8o391oJKuqwI84J3310Femb481USAawczN66Q ; 20171122 ; subDT >									
//	        < 6Qoe9cw6K0V44Dx4il5wh628P0B2p0wtuS4vLnz0y0Ve4mFuO57Tmz42A121NP8j >									
//	        < t954yIyb9d5iNztr4Ksc9eS9e1UzDMZ8zP4vFP41o1s963npB0R1yxT87KhvSi38 >									
//	        < u =="0.000000000000000001" ; [ 000033688289934.000000000000000000 ; 000033698396210.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8CC4041C8DBAC05 >									
//	    < PI_YU_ROMA ; Line_3406 ; 05TQl4glZ96SxRcvIJBoGElUzT50gYy5H4567jB5J464vOMIV ; 20171122 ; subDT >									
//	        < b6EybUm742QRDgNAy97iIdWYQ2N5oDINF9UZ950q8M6i53QGWlmV4hjkh7Cg519Y >									
//	        < 9Y3e0uFj9Ofr917rh5yVEs29X14c7kn9emM5xnmBnjxGLZ1nxN6Faq2z95c06LHA >									
//	        < u =="0.000000000000000001" ; [ 000033698396210.000000000000000000 ; 000033704529164.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8DBAC05C8E507B4 >									
//	    < PI_YU_ROMA ; Line_3407 ; i9kUYC4DG221VbJ359tm47vzDraTxB5B9e1E321CP8q7PxKzT ; 20171122 ; subDT >									
//	        < 5r5D99A845Df30gihygn19vBXf6RKRfh36DQ0H0H9hvFV4118NebFI1qUZy4051N >									
//	        < 9DlJ098m1lu3jG44rKlvX2VSMPJ290VH3NksMIwc4AOgd705AZWy6w1WfB74m40F >									
//	        < u =="0.000000000000000001" ; [ 000033704529164.000000000000000000 ; 000033714192943.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8E507B4C8F3C69E >									
//	    < PI_YU_ROMA ; Line_3408 ; 27095q1oX38CVDX1cCu78gj6T3ByzpGvq2e88Qe9Y5Sk1f1RE ; 20171122 ; subDT >									
//	        < hllLeV8F4RQ7jbNSzq5xQL9g66ZoUNx8b0692CwQ2Gg5XMDOaEy5r9pp7AN298KX >									
//	        < UzWyhYyVL6fYcj7cLsyHlK0q6ad1e2IZLEwG5bUYf00sQ3kt5282QfgU4iIo8XVK >									
//	        < u =="0.000000000000000001" ; [ 000033714192943.000000000000000000 ; 000033719264046.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8F3C69EC8FB8384 >									
//	    < PI_YU_ROMA ; Line_3409 ; esxiA7lNwCr2v9gSGTSh2cc2vT33fih8LEAAyM7C63oETxaEq ; 20171122 ; subDT >									
//	        < RQRU6252GN7BET0BG836Tn6kTbEmK0rn6sI5Sw0Y6ggu53Bm2vgA3Ey12i766vIZ >									
//	        < 9zYeS870iM8BfTyN7QaLQm4WvUrB0N63GGzW5h1Z544N81w9ejn44J32Hm3kSGYq >									
//	        < u =="0.000000000000000001" ; [ 000033719264046.000000000000000000 ; 000033728072586.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C8FB8384C908F45A >									
//	    < PI_YU_ROMA ; Line_3410 ; C8YMbpR9EJvPtJbjm5M4764UC40dLwPuRCE3U2utEReM1s0M7 ; 20171122 ; subDT >									
//	        < q8CG3z1hPdlm9g9f50892J0P9COkI1K0hcM5p7I2rt49jj2xtd8aJK4G0Ml9JQmU >									
//	        < I6Od1BUSt0ikZ6774eBwXSbw0uBzQ38c2lbR9lHJdC4qlvk6qc72fUMo95kP0C8u >									
//	        < u =="0.000000000000000001" ; [ 000033728072586.000000000000000000 ; 000033734120208.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C908F45AC9122EB4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3411 à 3420									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3411 ; v1z66635rRn5qoA1vjfVbaJk6UAe3Jn2qFKmc1elL5bE6uTOp ; 20171122 ; subDT >									
//	        < srh3o6NPpLJKp29Vv14iG9124i8ikOEz9qYG4wNQYFFGfp75o9n8Wb80Uo9tuWYl >									
//	        < qIPDQA2H5L3F6420F0pFma2VM9iyKEf6LIvK9jS0zaThWN0kDwH88x80yFl4H733 >									
//	        < u =="0.000000000000000001" ; [ 000033734120208.000000000000000000 ; 000033747739857.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9122EB4C926F6E1 >									
//	    < PI_YU_ROMA ; Line_3412 ; QQz36LN00GaWtlBCn5mtH0D4X3OdDXM61HuIBU3z6f237v4U9 ; 20171122 ; subDT >									
//	        < ix68Q85v1KubXqSM9Qj0B0RQS962z05Kj4Kd02D01Irj3H446S34364cnwg1hgaY >									
//	        < rxM79RBNa9zl0KXnCUZXpT2O9Y000P0ITzfY71k079L4Cz7vBr313Y3x0IaIPesN >									
//	        < u =="0.000000000000000001" ; [ 000033747739857.000000000000000000 ; 000033753280710.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C926F6E1C92F6B47 >									
//	    < PI_YU_ROMA ; Line_3413 ; K7cNu2ApB6VxAi3T8c8EyPdWYGw4N87G3r4P6CF1WXamk9Zm3 ; 20171122 ; subDT >									
//	        < OuFLusPsx8wil562hW5Qa5pCZu7IHX770JG9fk1yhKzTb6R3qUWkHwm0R46l0C3z >									
//	        < zA0p4d3QY691YVS77lC4uy7oLcX91avPETvH8I8UDTr4kGY5uRYvBlrGOIQ9yPDD >									
//	        < u =="0.000000000000000001" ; [ 000033753280710.000000000000000000 ; 000033760916289.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C92F6B47C93B11EC >									
//	    < PI_YU_ROMA ; Line_3414 ; 6YwWq4rrOSGxu3jx8Gq11yUkyp3vyvi6n5LR1dpkgNAk1ze68 ; 20171122 ; subDT >									
//	        < Z9g495Nv8BX1Lw8pi4B8jIJk1oZ6TuGh6t99dq77QU77TXk64J93j0zdVq40qn17 >									
//	        < MzLK38dH545Y446f4uAG1RciU956U677z0n8hmmA5055Tm18liycdw2dnO2LMTJC >									
//	        < u =="0.000000000000000001" ; [ 000033760916289.000000000000000000 ; 000033769954743.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C93B11ECC948DC92 >									
//	    < PI_YU_ROMA ; Line_3415 ; 3etucoBxCZJ2FF58BQQX12u14re1z66K554div79oM6lPgkM5 ; 20171122 ; subDT >									
//	        < icz9l9beDCp298uUpNzPzN248YrVO23hjfZ0c4dog1tmpBZez1cRqTS3171RT00J >									
//	        < rH2i7qFj074EGGl1R53hHK0Gv5Ldes6R31mX91Iyq4l0FuHOndd5n7KH7hecnX19 >									
//	        < u =="0.000000000000000001" ; [ 000033769954743.000000000000000000 ; 000033781808059.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C948DC92C95AF2C5 >									
//	    < PI_YU_ROMA ; Line_3416 ; fYvN3l9250lzKI9s79iw42wKyE7Q43CxPT8G0fS8J26hZZz46 ; 20171122 ; subDT >									
//	        < Hj0DpnS2yufrMQRSKUM7bKWuQa8095Q1b49pd911b6j4ANZ572092h0091d2mDmh >									
//	        < iRF62e9hF7n55i27FeNcZ44WVDrJpTFo1UCjIVucfBC5l8861mdm875yd7r28pwk >									
//	        < u =="0.000000000000000001" ; [ 000033781808059.000000000000000000 ; 000033793588609.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C95AF2C5C96CEC8C >									
//	    < PI_YU_ROMA ; Line_3417 ; 8V70N6KOVT90bgn3vRi6qeqmvFJzb2Q9S2ZA04TO97lH8rcfK ; 20171122 ; subDT >									
//	        < 3TZ0Y383Y7lzu1hKyIk2gEC4Rh3BFbynucgg9o3slE5VA9YaUjJ1Py00EFC56me1 >									
//	        < Fid9DlmmiqCib9AgC5uMK3S9iM9NX54rVXo509jWQ7O74spiE2J03dtXH4lv7rWr >									
//	        < u =="0.000000000000000001" ; [ 000033793588609.000000000000000000 ; 000033804039273.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C96CEC8CC97CDED7 >									
//	    < PI_YU_ROMA ; Line_3418 ; i7G54qT4JvGhi3Js3tx9lcET6JZ1UaN92669dceKV8dp9LmR0 ; 20171122 ; subDT >									
//	        < 01R18F4p5Bo61I88019S1dWgs5Q94dbzQyt6w1FRY79Uu637U21GFrBQU1Pp2M5p >									
//	        < 2lE83AIN4KMiYP2OggWJwLTMbQ03l7MrjTY6314aW79okj7mDvSqR92EZ53kqi2x >									
//	        < u =="0.000000000000000001" ; [ 000033804039273.000000000000000000 ; 000033812903814.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C97CDED7C98A658D >									
//	    < PI_YU_ROMA ; Line_3419 ; 4gM1Xw4Woe455F4xCuB0foMfX6F6342HC3yHLEb8l9GEdBhNk ; 20171122 ; subDT >									
//	        < gjwx8gs5DokMN1gjvYv9cmtmAPuoSg3L8JHtL39AT3lyicpmpJ060Ia859bIe2L9 >									
//	        < c85ak53TOg0z3VBcKJ60sWqg16DklwIB079vVay87BlcwJrtdiBHBz400d6PF68h >									
//	        < u =="0.000000000000000001" ; [ 000033812903814.000000000000000000 ; 000033826567892.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C98A658DC99F3F15 >									
//	    < PI_YU_ROMA ; Line_3420 ; 0dWVy9irqoy7EfttWge5Z4y1NLnpT6BhBcQaD8vkKZ7r4ycw7 ; 20171122 ; subDT >									
//	        < 7ZgMz5mgZ1WWa1rTTEQXsXhgNSUs3L9nTVzE9wR9v8rh2hxPVeX41q2RE5Zrr295 >									
//	        < 0stAQiZnuGXlQ56Co15iYyX4EyRO3Lcgj94ic8dd93f126GwcW2GsS7pK8EaYFBI >									
//	        < u =="0.000000000000000001" ; [ 000033826567892.000000000000000000 ; 000033834212127.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C99F3F15C9AAE91C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3421 à 3430									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3421 ; 569yoHVLO8qqn1emBp74195lk9AMxXcS5TcVUrUtgFiL2dUc4 ; 20171122 ; subDT >									
//	        < mr9315B4e4L1E83B1jX0IdTfTlHSRFoN78aCE9J6GpDxDx8m3D037P5sM4wm0CQ2 >									
//	        < o44m1eWR9lZk7vE0R3V92mnZKK6V46G2Y4s084vXU500lx08RG0GnF65558000Of >									
//	        < u =="0.000000000000000001" ; [ 000033834212127.000000000000000000 ; 000033846861454.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9AAE91CC9BE3641 >									
//	    < PI_YU_ROMA ; Line_3422 ; 03bWNF2LKnPU8LiPJs641I21MWa9yg8AB5BG65Y0W5plxVxro ; 20171122 ; subDT >									
//	        < w23X30X72iOaOXk2NKRuWqVb6r0es5RY970eKmcu1GpIM9c016wprwa4XRt389gv >									
//	        < g5G2EKswl8S55Oi45cD9IGFlPxV49XU46kANqkBowTWVZ80732Sr98AqUvogyHHJ >									
//	        < u =="0.000000000000000001" ; [ 000033846861454.000000000000000000 ; 000033852043408.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9BE3641C9C61E74 >									
//	    < PI_YU_ROMA ; Line_3423 ; 8TeckQ714FeVGpu0TxalkQy91rksnH0N7u3aVFJ6wRh6YOGna ; 20171122 ; subDT >									
//	        < b8Dq25S8wH9bh3Hj3sTG9k12067ueeg0Ms3b9s7d4Q4tgGF05rIei60rZN3A4acs >									
//	        < mb7ymZWo861eXlq015vW0nve1Pu91RL6TiBa9N11e83V4UnoFcc8Z62uh35kmVZ0 >									
//	        < u =="0.000000000000000001" ; [ 000033852043408.000000000000000000 ; 000033859446689.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9C61E74C9D16A5C >									
//	    < PI_YU_ROMA ; Line_3424 ; 095DFv04e769yY8s70K4118C0Y8svuQvIMGfnv60OTJ199M9j ; 20171122 ; subDT >									
//	        < rcnwD4JcD7zRrzeio1bWNFmYaplbudXS1J9Xt8RhxvNW77HuhyfAXp00k6XblBPY >									
//	        < xbOBF1JrI6zx3kp33y2Dmw8ZF071I5BM9oUb3vZAJztX3H3os208d4176KP20pJR >									
//	        < u =="0.000000000000000001" ; [ 000033859446689.000000000000000000 ; 000033865674773.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9D16A5CC9DAEB35 >									
//	    < PI_YU_ROMA ; Line_3425 ; x9O08k0Qyf99H706H27H5tQ8M2Q5BQ7RQriEc3Y92cuUP2BAM ; 20171122 ; subDT >									
//	        < 8K2r92y00h2dZuWtTZOy3hFU9uuRMCaMpJ5rLJ5M4T02r2HdV1g6wj5K507Yy5Az >									
//	        < 99bs4sM0QM976egTYh72tNy2lVs9vS24cx6C7jkXq1EBacauWJLHeo4uqfxmnf25 >									
//	        < u =="0.000000000000000001" ; [ 000033865674773.000000000000000000 ; 000033872211531.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9DAEB35C9E4E4A1 >									
//	    < PI_YU_ROMA ; Line_3426 ; 1pqrP0itj3xaYblkl02SlV0C8XnPUpV9q655FUNjfRi531GR3 ; 20171122 ; subDT >									
//	        < 60WXOEtbctkDhxt61uKT4e3URizXe3ETC2apUP8C5itlwYE5V7ZvmqgcaYZ2HT4H >									
//	        < Dypy0Cn1u32SyTea1kowmvw2UGV7WeMgO44ab8lrKEUWToNn3eNyUaV7I87wfYxu >									
//	        < u =="0.000000000000000001" ; [ 000033872211531.000000000000000000 ; 000033884039099.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9E4E4A1C9F6F0C5 >									
//	    < PI_YU_ROMA ; Line_3427 ; 9zr80Yk19sKjftt7q1X88j0JkH9wnDMw41ndOc8fbvc2Aakgb ; 20171122 ; subDT >									
//	        < y3wf6b4ryvVI7teXRn7I3dF2EBTU7UG7zS6Vl6uViv0V0eKxPA2E27P0XrU47sxL >									
//	        < QQ0h3uzZficgSLGXt6lIflYU51Fw1536jjghbisG8Gbi47jx57zM0Z2v5vW9Sn0C >									
//	        < u =="0.000000000000000001" ; [ 000033884039099.000000000000000000 ; 000033891957006.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000C9F6F0C5CA0305B4 >									
//	    < PI_YU_ROMA ; Line_3428 ; vzJZPM55C80ARH953mpJp2H32w0ZQ98o4IkBQX8L5lmrmNXue ; 20171122 ; subDT >									
//	        < A94Vv0tZtG6rqu0t2VnNo4H7b28Xzaz8IDNaYKiC60125QbvKTEoowZQjg80Z76U >									
//	        < f0NUgV5p7oZ34e75IW51n59iXGjw1PJo8Z76QG795716mUdDJ075v41a95RwRV4k >									
//	        < u =="0.000000000000000001" ; [ 000033891957006.000000000000000000 ; 000033898313926.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA0305B4CA0CB8E0 >									
//	    < PI_YU_ROMA ; Line_3429 ; 1Dfz396xwt52ZXniPcc6636wmUY7l5tRa875i254d1RWe6X2l ; 20171122 ; subDT >									
//	        < rpXOxD38k5Kr7tm1s00KPwwCJACm4UpbehHYK32b94slSXc4f3q6w4BLKf767ep2 >									
//	        < 883bXV0Vfn3h71t7d11292tq7l0u99000p3We37UDFxy5H87q4234f69jWMy7NH4 >									
//	        < u =="0.000000000000000001" ; [ 000033898313926.000000000000000000 ; 000033907371080.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA0CB8E0CA1A8AD4 >									
//	    < PI_YU_ROMA ; Line_3430 ; 36a62MWoIG7quSHGH9f1Zjp33i4wgnb3es11RsXdpNFnd0huM ; 20171122 ; subDT >									
//	        < Lw677G29G68Nx04c80IQ4b540YhR8rb57D3v5ruKE5RtA5eGR7IWAGRgg4sRK06g >									
//	        < 8OcH5sg42hTVtV0UXdO33SQ5k27gTJij5qw3P5mJW49WK9zgPmm0ZI59Fc75AqD9 >									
//	        < u =="0.000000000000000001" ; [ 000033907371080.000000000000000000 ; 000033921344373.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA1A8AD4CA2FDD25 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3431 à 3440									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3431 ; 7I24R2F29UDk59ajX31YG2dG76s72hQOzX8f9GN2M5AtsXrId ; 20171122 ; subDT >									
//	        < uhHh25ly2mWjOmwxw4zy6qRWEx283jc2yJYhjyDc91h95uCq98l4KZ4i2D8SBSG9 >									
//	        < x2a6Ck5xqMwx1rY24QK6O6U0CmO8A6KTLcQg4GnTP6bQUzmPONt8lK5OUqy4vYg9 >									
//	        < u =="0.000000000000000001" ; [ 000033921344373.000000000000000000 ; 000033929342280.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA2FDD25CA3C1154 >									
//	    < PI_YU_ROMA ; Line_3432 ; DIMQFU1G4UHS26T98Kx9Pa33OZey5A6d4xAWm7Zh46zcfjSSi ; 20171122 ; subDT >									
//	        < Xw92c4K75uK947kC44p02t8gY1Z87Aw3Ny72rG3VlPZ97ZF0V9nfF7T00t21mfIG >									
//	        < tj22i3dpjLbhbzhXo1xUWQz04Bg360H79yiqx4wqBI7CCn1p9kgNWc6FBJc9ud4o >									
//	        < u =="0.000000000000000001" ; [ 000033929342280.000000000000000000 ; 000033939239507.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA3C1154CA4B2B6E >									
//	    < PI_YU_ROMA ; Line_3433 ; 6UR5nP5AwH07HwOB0GN497B0qwdZo7Z37yqwE5na37TQvRpz2 ; 20171122 ; subDT >									
//	        < 6rpE65aIyC0IG8cnM200LBEx9GP9g05I42wpHH0TaWB46ZG4Bp6jJYgFGvCMbWqk >									
//	        < 48w43y9mqE6j8ijlKHsvhC0Tg0N104ilNwzXB50Fyxj8753JviYz22tRC466hju3 >									
//	        < u =="0.000000000000000001" ; [ 000033939239507.000000000000000000 ; 000033952224853.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA4B2B6ECA5EFBD5 >									
//	    < PI_YU_ROMA ; Line_3434 ; WazgB14Hf9s8Z68tuamJ2Zz9u8s3Vd5EQhGy61rrSVm8mJ5Pk ; 20171122 ; subDT >									
//	        < OyLUssUaoM53tVKzo0n0u62I94hKhKGBWgl5GW6V06t0FO8ik0HuW3K7N9BmV313 >									
//	        < G3MfQN07Mp179VN1d0fNFx0qzw5Ufn3llWa6sE22yT8VOqV4nA727VTj0B89lz6d >									
//	        < u =="0.000000000000000001" ; [ 000033952224853.000000000000000000 ; 000033959315678.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA5EFBD5CA69CDAF >									
//	    < PI_YU_ROMA ; Line_3435 ; lba3dn2Oy9tqtXxQGMt708O0Yjn17H4laYP3DEKv34TdF1oI2 ; 20171122 ; subDT >									
//	        < Bt07zeF5DZ3PQRh5d15GJi4kxx73mqCx2aQ72f3Gle0Db9jUbIMBcERkwfX7n6ej >									
//	        < QL4Egk6VR72J876likVvgqhw31rrHjNuOz18U7Nb3VSnH0KKMdPJtUgQqoSvFmUi >									
//	        < u =="0.000000000000000001" ; [ 000033959315678.000000000000000000 ; 000033968578426.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA69CDAFCA77EFF2 >									
//	    < PI_YU_ROMA ; Line_3436 ; y96ca7xbd6buZOwnyDm8zP6M0SWDacg8F0iXi751ttZcugdn6 ; 20171122 ; subDT >									
//	        < 83M2161H47md8359Wo3ITUYZ5i7004AR6sE8F4tbCjo3ztQ88f07kp9j7a98XANq >									
//	        < BUdZ7M2V0rq145OyI3RiKUDtOoK2jndYPVJw88AzoS728djtPiqZFnCgnw5MHFFh >									
//	        < u =="0.000000000000000001" ; [ 000033968578426.000000000000000000 ; 000033975722236.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA77EFF2CA82D67F >									
//	    < PI_YU_ROMA ; Line_3437 ; PDc8laod967Jy513XI5x5w5fLE7WWGO16okDU938TqKQ02E56 ; 20171122 ; subDT >									
//	        < bU2CHYQwOpnB99StmhI7duF5t9CDbT55XEcD73SqOgX5h0Eacm7P7ixz8ie00r8S >									
//	        < 814kL8WWmhI22S493uW5fN3a3E4WG3L4H6PXJEb7n3Y151o7c7D9a4zzRZnl3B93 >									
//	        < u =="0.000000000000000001" ; [ 000033975722236.000000000000000000 ; 000033990648134.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA82D67FCA999CED >									
//	    < PI_YU_ROMA ; Line_3438 ; lW60u91qT76Lr03b48JEzoQHIL8U6gMczK7qTN28rmnZhCq9C ; 20171122 ; subDT >									
//	        < xSuu3Cc2gQ9j6v3Zz49VXk0pK9523wkoKKwRqlUwcrMe8KNl8JH458lSs1nmTccK >									
//	        < i67IxSUxWGQ01yZ6uA8rZ3AVhW0JeBc4R0m8XCTbVEzStVYoY229lx3g6vkcwLsP >									
//	        < u =="0.000000000000000001" ; [ 000033990648134.000000000000000000 ; 000034004943501.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CA999CEDCAAF6D0E >									
//	    < PI_YU_ROMA ; Line_3439 ; 3cZyK7RBBm6Y9MOAg0c0n3e21G649B50Wb78Y4gb3J7itaG7j ; 20171122 ; subDT >									
//	        < HQoMp5Ll0Rp30vPU1048PTb0jfDW1D4199tr0yjR6J7e5823LDrO9NtB7sPHb8UI >									
//	        < tb5zZggBi290kVEEvEHDzx0584xzZvmK0VUK9CIe385662uljqE5LgdEw0nVxuD6 >									
//	        < u =="0.000000000000000001" ; [ 000034004943501.000000000000000000 ; 000034011017264.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CAAF6D0ECAB8B19E >									
//	    < PI_YU_ROMA ; Line_3440 ; AsWOs8g7zYaAIPll4cpqo5b9eQY0JwYQQf2B28Tu0l8WH83bQ ; 20171122 ; subDT >									
//	        < w5W53S3UH609G76Qj5SJwjS64Ka20kUy9QC7S47AqakmnC79b41l0T6yIm2UdS7U >									
//	        < 2Wbg7V4sTKwJy04vCFcF2STD190jX689v1yys9Zv5gzhQ41z0n8QOHi1dL01LlTR >									
//	        < u =="0.000000000000000001" ; [ 000034011017264.000000000000000000 ; 000034023617672.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CAB8B19ECACBEBA7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3441 à 3450									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3441 ; ZJ4z4sSJhTN2bo3w8u73R7zFm2sJBhp3k6KVKtj1j774A41I9 ; 20171122 ; subDT >									
//	        < Pe64fF1kJCCSb14EdVnVn5K4Z49BJh0K8fTQceQNq6t471DQyLa4DqjSL669RHQ2 >									
//	        < lF4H9QkvmRrBjPZngAu7aR65XyM55O50h9X8Nvq7J72xLXWNLW5131jqBjuzm47O >									
//	        < u =="0.000000000000000001" ; [ 000034023617672.000000000000000000 ; 000034038260924.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CACBEBA7CAE243AC >									
//	    < PI_YU_ROMA ; Line_3442 ; 9K412gBjk27tA1584T4MOZsi30vcwiu8kf30QaNr470k744M2 ; 20171122 ; subDT >									
//	        < 8647t6nDospk4YW3sTQ1BFFp72G0MG62q9QJafDgz0vxOP17yvav97N1lNlC9Y05 >									
//	        < m5219ZE20QOHZ8NezeR92c80y62TyEXXjON877I37MQPRha3kc0y25OQAF0KUDG7 >									
//	        < u =="0.000000000000000001" ; [ 000034038260924.000000000000000000 ; 000034049394206.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CAE243ACCAF3409C >									
//	    < PI_YU_ROMA ; Line_3443 ; hgIEiN3YTo512leXJAzcJ6bXl5zQP39JuMeNK46bg7nC8i3C9 ; 20171122 ; subDT >									
//	        < mLu9lzBodl91Fxg07mHYD3CYoKNY7Ix5N0Y0Fje483O2L5vw0BVzDc6s7cXU8Pa9 >									
//	        < GIiQvnbaYgy3qhdQLd8yJ8dxKoivf8MHiw7DtPaJ936GAuBF3Ibk4a3e0eBQ1EXK >									
//	        < u =="0.000000000000000001" ; [ 000034049394206.000000000000000000 ; 000034058491041.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CAF3409CCB012210 >									
//	    < PI_YU_ROMA ; Line_3444 ; 6pI5dL25w4wSmdOK4vAfbqOM667fxoA47pQFY4n53XKdg4TyE ; 20171122 ; subDT >									
//	        < 17m0GIfqpwyU92q0SNbOPtAL26NLJJC2lf1kZs11L87AKev2896jXkc4492ECtGV >									
//	        < jq5n683IhAfk51WikCdZ4EgXrzCjz779QR98DBKGQ6nRY07NGRicFX7597uy3SBQ >									
//	        < u =="0.000000000000000001" ; [ 000034058491041.000000000000000000 ; 000034065095783.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB012210CB0B360A >									
//	    < PI_YU_ROMA ; Line_3445 ; jXhC5I7sNVvxiec2HP3Tk1omQG4hgco6V7fsTxGgcpC7QtlQu ; 20171122 ; subDT >									
//	        < hlT7q9Hp5Jc24445D39R8cE5BmgsOn84MKmq7nDP1eLB1fcT394R3iXAO1pZj7xf >									
//	        < 6ehG71ZDJ8LutMu295U9Ild85y4926WEF9Pi246Z4UtyLso5LnHxX5q5wgnUjg0z >									
//	        < u =="0.000000000000000001" ; [ 000034065095783.000000000000000000 ; 000034070233498.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB0B360ACB130CF5 >									
//	    < PI_YU_ROMA ; Line_3446 ; 8LDSqCP98Xt4SOMZbD4d9666a4aKfwGA632etfEW462W60Qx1 ; 20171122 ; subDT >									
//	        < 7KwI8aYsbxVG2GI7Zwnqc8pqGFDzs66Ujviniw312E4bmEK6EpX3OLVtG605wNpq >									
//	        < 1ZuC4g3wie1tQB8S0U4WkLB0se9h9WsFKMtwMIs8H4Pu72heuvbRiwUS0tZsh7ZR >									
//	        < u =="0.000000000000000001" ; [ 000034070233498.000000000000000000 ; 000034078370780.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB130CF5CB1F7796 >									
//	    < PI_YU_ROMA ; Line_3447 ; t4o3FjKDrjy1U425PRC0cJsc5Tc2CgsSFq3tLZ47zy9Gc2owM ; 20171122 ; subDT >									
//	        < FKK2V18vii9wRNxCiTF5n25prw60H9W6sRyu6962Ap4C5I6i807YqFRzJ85k9qA3 >									
//	        < 7527upbhYQuBF3cR2CG5y6MLbkX080xNR3BwO872lMq0oL05NL70M6RdoM8vWXfW >									
//	        < u =="0.000000000000000001" ; [ 000034078370780.000000000000000000 ; 000034084152678.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB1F7796CB284A23 >									
//	    < PI_YU_ROMA ; Line_3448 ; ebx4CCp3xWY317pGFkPn3IegNiZ5Zi8mQqgT36MANc0wDGpZj ; 20171122 ; subDT >									
//	        < 5825gN219mgFu3K8v55he0IjKYhd4IyA4Nt04jNsgx725921A9PGO92NZE37l7F5 >									
//	        < R42b6ayOTT49GQQcPEo8TS1kGKFh2i2uxTIZnbY6dtmw6ge40yMd16K4N1H88EV0 >									
//	        < u =="0.000000000000000001" ; [ 000034084152678.000000000000000000 ; 000034090425763.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB284A23CB31DC90 >									
//	    < PI_YU_ROMA ; Line_3449 ; zI12lA817BFnO5v89CBpwhR0Ym1oW2Csc8mDnDHCYV0eoeQcX ; 20171122 ; subDT >									
//	        < n7Vp9tqtbea9XTJJi1d1oEyuJN602b8fqDVogjCa9J7MPuKIj6BFMFk6NGD571dq >									
//	        < S1Plh2H1359l2a7vjZv7F40SA8fRxqk59fX00DIM2k7I33t67Qa3BuWvtAmLgpyS >									
//	        < u =="0.000000000000000001" ; [ 000034090425763.000000000000000000 ; 000034098326966.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB31DC90CB3DEAF8 >									
//	    < PI_YU_ROMA ; Line_3450 ; b3XTE87l42nj1PaTXI7G6VtT6t5LYX6dQzbv19A69eaqCrVs8 ; 20171122 ; subDT >									
//	        < 10Oaou2YqrX82urGlOWs6WI37c8tl9noeFk5HA0bba1d62kBhf1BN9m9B1ImHIf0 >									
//	        < tRrL0jqS69cdK4S4QiDrwZ83Y0C5reKQr64RPu1jPj8epD28GF18730756s78ki6 >									
//	        < u =="0.000000000000000001" ; [ 000034098326966.000000000000000000 ; 000034105475306.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB3DEAF8CB48D34A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3451 à 3460									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3451 ; 3D4H4uL8bQr7jpY3evdKDQ1KtbG4f9CPo0LO54M4838rAh24Q ; 20171122 ; subDT >									
//	        < V8L1j93e0NY9K6AlZD0iB21zJZcK09WZ8bxa945s9322jBvGgXnX2kf10Kk8m6Y9 >									
//	        < 3aeF3Psuk28YtlYWK2xm2FCn1144chL5h56VVBAl0Nc5H517YTiWsMD9i0p7uH74 >									
//	        < u =="0.000000000000000001" ; [ 000034105475306.000000000000000000 ; 000034115269447.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB48D34ACB57C520 >									
//	    < PI_YU_ROMA ; Line_3452 ; oa2mk6WZ8nkkPoXt1tHmo4Ke8SJF646pHIZ90QwY6DMrgzu4o ; 20171122 ; subDT >									
//	        < K747FIDbQW6Ux36fkD55iTdnPtyhQ3I3Qu1zsFvIv4BJq3CGyQUxelaEJWaqf5G6 >									
//	        < CF7xYpQ5qbi6w98c9C0HrZ7wbImhWli90sEfUY2Gl6596U7Y8cFGUzAWGm53fj8J >									
//	        < u =="0.000000000000000001" ; [ 000034115269447.000000000000000000 ; 000034124652908.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB57C520CB66168A >									
//	    < PI_YU_ROMA ; Line_3453 ; h1irEiQyz9XxIjV551K72dRW8PjyQL2b3lwfT0YY5OEsDf6i9 ; 20171122 ; subDT >									
//	        < JPLq1R499c3WSCpC9GsCdQeqiBqMi9efEC7e10j024255fQdqP3uWz5ALb73wyUY >									
//	        < 0946T34XOIWVqWr8kB7V7dQqq05i1zs3g3cB2606LBZs91bc68vDy612W4R18bW4 >									
//	        < u =="0.000000000000000001" ; [ 000034124652908.000000000000000000 ; 000034131180971.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB66168ACB700C91 >									
//	    < PI_YU_ROMA ; Line_3454 ; Ao3iaU4XNu2qo6t2I292Ts4UQ7h7kjv92J724FC03DXpa85z4 ; 20171122 ; subDT >									
//	        < x4S330rz59Y2e3z2q4LX9X41C5zacXNFQ22X0b9nkb8F7HCPv6NLTYyUIC2qrYYG >									
//	        < 12Bmau5ye2NY2ZaM8608lattPtzCV1SMweH80Df3dMypXtO1J8iZGb50ts3gK9n7 >									
//	        < u =="0.000000000000000001" ; [ 000034131180971.000000000000000000 ; 000034138668359.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB700C91CB7B7953 >									
//	    < PI_YU_ROMA ; Line_3455 ; eI6Mygu8Fl0n3H9UteFy281xHeAfk4h410k0Ww13gO7jPR6Ua ; 20171122 ; subDT >									
//	        < 9BeXZCGvU2yQn8fV4W6w9FlR74t0IS3WD2oJQEjhKAmFB3yi2QZdvClC9f6Hvg7n >									
//	        < nthnQMsUaAr3LJKfAPX4olXbBKEW6uS696705lVZn698Ot0ov5mNcIea1I8Nn5HM >									
//	        < u =="0.000000000000000001" ; [ 000034138668359.000000000000000000 ; 000034149056041.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB7B7953CB8B5304 >									
//	    < PI_YU_ROMA ; Line_3456 ; ZJMLrmAOL6If193H712dIYrOEwB33trTnDcVZ40W6zw6wkIvq ; 20171122 ; subDT >									
//	        < RxPtlAx8Yew2Vjx4g0R4qfRopp7ciM5AFFQByXlDk2lE7vBxKm5UpnomPJnUiYMC >									
//	        < D55z444uGI4JL85C6lrfb161k8FE1151EjFK0Sb2cbaZ16900S0dKkLfqc1Pe1V9 >									
//	        < u =="0.000000000000000001" ; [ 000034149056041.000000000000000000 ; 000034161661710.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB8B5304CB9E8F1B >									
//	    < PI_YU_ROMA ; Line_3457 ; F7rJN9p0Nfp8I40B682T0NJrQ3m4hrx77W7Oz8vMtYMvzC7Bf ; 20171122 ; subDT >									
//	        < MR9UEKk5LZg81pN8u93VJRg8p9zXV8IJul87GdzTrRvt4O5MNxgz1L5s7H67Ax08 >									
//	        < f3rHM5b0vYShl7p5847aNN8325Wk7ptFXG7UEyV9qoLl0Dm9YjP7bLm3bV9vfcjS >									
//	        < u =="0.000000000000000001" ; [ 000034161661710.000000000000000000 ; 000034168227410.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CB9E8F1BCBA893D5 >									
//	    < PI_YU_ROMA ; Line_3458 ; 22s961RO2d3reEB0E1l79oWarbj1atw6Z15168uS82j5g7Ms5 ; 20171122 ; subDT >									
//	        < 8eNO56r76eMWXDC1qfe8AEuMuIE7toFy47V1xZX2jzN4ZPM6Z6c35dJVF90e75hL >									
//	        < igV0VbQINo37Y3DN4jQdC352T5kutNnx2W9KH3N7J0bfT452JD3987czD26y2So4 >									
//	        < u =="0.000000000000000001" ; [ 000034168227410.000000000000000000 ; 000034175484149.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CBA893D5CBB3A67E >									
//	    < PI_YU_ROMA ; Line_3459 ; 0al04Mv74qPM6RQK26YYpjkQ8Q8MLEIb88ps6jw99X69z2e89 ; 20171122 ; subDT >									
//	        < a9029OMR8Zzg0kL1IK755m2lvNWwu33mo9rQodQL4WLOEb38751XAS091IhbHWIr >									
//	        < 8Fd2KDa2WZoKfO2A7Tu7KSm66N59RbmVKnmeVwPtM5GlKJDrcgd2Cw06wofQ7ham >									
//	        < u =="0.000000000000000001" ; [ 000034175484149.000000000000000000 ; 000034183596423.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CBB3A67ECBC0075A >									
//	    < PI_YU_ROMA ; Line_3460 ; 7735t6z2C4VyN289dYyuv7kqNs89uoB8p6ZK2SF6GQJS9h1t6 ; 20171122 ; subDT >									
//	        < gsYUuoOXhr0bCSqpt24c46ox8teDwI4gn23215kSBDYWhb74ten8X2YoOg5yD8K6 >									
//	        < QTa6QvqvuplY98281C95W10U3Me38L8vJ7n7H3fbHg15gw3I3B97ZYbRHKQKx0LS >									
//	        < u =="0.000000000000000001" ; [ 000034183596423.000000000000000000 ; 000034191335255.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CBC0075ACBCBD655 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3461 à 3470									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3461 ; A1QbhYzZ9bezt6XunQYn6r7xS36doWgXB1NyYGp04BQOQpnRM ; 20171122 ; subDT >									
//	        < 2FY6cg88qT9Zg7ngZk880vcGl3Mq1N2UOoDn72RIEmzE5vF7bIKtyEz2dy79Q0Xx >									
//	        < l0U0Cywa6Rze58ijUw10R4g40GxcoM17pBYq7H87w6A5qWUL3Of9JlyjAO3711vd >									
//	        < u =="0.000000000000000001" ; [ 000034191335255.000000000000000000 ; 000034205390301.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CBCBD655CBE14896 >									
//	    < PI_YU_ROMA ; Line_3462 ; RJITe9l0391hRn9p4L17peMXy8s694PfNIXp3aYj91Kxe4eVZ ; 20171122 ; subDT >									
//	        < LSi9q5v18HPP30W6oEK2wVr2Q1SvcGt8mACl0I151Y0xGDae6949M2f7f4wx3vTA >									
//	        < 73g9M8u25v4NtLmvJ0OCW41nAhiNH2qy2f03nJIBCE2v7zZum7lDbTu5dP1nN625 >									
//	        < u =="0.000000000000000001" ; [ 000034205390301.000000000000000000 ; 000034211815851.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CBE14896CBEB1691 >									
//	    < PI_YU_ROMA ; Line_3463 ; mpmKBBP3S1w9R44Xx5NzCY63opxQMT3arxlQ0cYYD4c0TVr3w ; 20171122 ; subDT >									
//	        < 471vg33514UDG1chMq51Gq2493a6RbqRCJT8VSKL17219S850YWUFae5yvSuAa6b >									
//	        < k85A51oun6t127l9n2nYmfxOL8X440j1Q5gdV48Jay6E8z8rg66ve12W9Rh16Q81 >									
//	        < u =="0.000000000000000001" ; [ 000034211815851.000000000000000000 ; 000034223424077.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CBEB1691CBFCCD07 >									
//	    < PI_YU_ROMA ; Line_3464 ; j7OY6Igb5UqlGU0dEzGD9Xov5Shst5WXEKHtD3iIFBQGsC57O ; 20171122 ; subDT >									
//	        < 48OY8dyjj5Rw1Jj262FJ874C4iCGI15SxN3xfd0AdQA9lrf7LI9pVVR0imkm0w33 >									
//	        < fa0K4Dp5ct6RRCY23Il4yXiNFlvy6JPyA3tkn74wknl5vr9eYYDSxK1c2V2yn6G5 >									
//	        < u =="0.000000000000000001" ; [ 000034223424077.000000000000000000 ; 000034230649340.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CBFCCD07CC07D366 >									
//	    < PI_YU_ROMA ; Line_3465 ; eG3LoZjqi54Nz72sdJ8c2wrEB1JrA5gzSGsoEGgKv1o8fCR6G ; 20171122 ; subDT >									
//	        < ZIegv2dNHdSlgoGEgtNVmmK5p9xdYirE1SQYOupb64yLi459q88428qgPrjZEbRD >									
//	        < GUKrzo47xUaiSN7N79914DN104KxTC6npEBZej7rw7ZG2JLc5F6c02X16qLNpm32 >									
//	        < u =="0.000000000000000001" ; [ 000034230649340.000000000000000000 ; 000034243018122.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC07D366CC1AB2F4 >									
//	    < PI_YU_ROMA ; Line_3466 ; ajjF9p9HGU4jPmnPA8646qidkzzv15Za4dX4uuMcA9fth8iUy ; 20171122 ; subDT >									
//	        < 17R7V6f372Y19sg51ap1xKgz9G8P7S6W779jJI121474J3i9JMd14Rn19JI4m6P5 >									
//	        < v1BhQYh2rU6l5T62GGdE9GcDk4903G1Y48ySIYTzD113hp9HJnoE1p6H0yk8v51x >									
//	        < u =="0.000000000000000001" ; [ 000034243018122.000000000000000000 ; 000034249372344.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC1AB2F4CC246512 >									
//	    < PI_YU_ROMA ; Line_3467 ; A5r45d38pMV7H6W6hXCzk6r20YwJGYjp8i0OYU5fO3ko51T04 ; 20171122 ; subDT >									
//	        < 9wBNGpSV6jAK80XMtjKFSS44y9x85VS54p19rK3M93pXd5LruB6i0lLk0xaqA8vo >									
//	        < kiF7MkdCDH2Mw0De0Une8EpvQ4v1qBHMGeo99vs07rggXAdB68JPBlz7i7NINDe4 >									
//	        < u =="0.000000000000000001" ; [ 000034249372344.000000000000000000 ; 000034259633821.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC246512CC340D76 >									
//	    < PI_YU_ROMA ; Line_3468 ; e1UMpE342rB714FFT0T2ND01a0OE25N21gag679j28TPD6VAZ ; 20171122 ; subDT >									
//	        < 71wP3HpFwR1bB9kWRaVYOb3loUANhTcIQ1wKJ5Tp45o4O9lPD8Voht8Nmk8UTh7C >									
//	        < 0W308ljpOfYT1LBKd3A335VuehDA3i2XNxkec7W42e9iuoVH02279F4Lgwf5FYvN >									
//	        < u =="0.000000000000000001" ; [ 000034259633821.000000000000000000 ; 000034269408118.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC340D76CC42F78B >									
//	    < PI_YU_ROMA ; Line_3469 ; m5U21YmO3OD7rOtsaxzrE7b7l2k201Qy9I733XP6Nv1QwTZXf ; 20171122 ; subDT >									
//	        < 908h8d6wgU6qJNj5Gumf2tOZv0r4vIqvnpEtXUjH3V76BwVFKOjUplplLABk51Os >									
//	        < u5kezyC59FuzYZyG7pt7nnJ81v0a4nj46Y7lklFR7sA1PnUcLVtD7kfV5ORE0Jcd >									
//	        < u =="0.000000000000000001" ; [ 000034269408118.000000000000000000 ; 000034280267755.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC42F78BCC538997 >									
//	    < PI_YU_ROMA ; Line_3470 ; EipTAg1CQI4G0Q559d91Q2BH5K8sJEb21v5YvoiBk4zd5BC3v ; 20171122 ; subDT >									
//	        < J2u3Y8r200quRCQ85QgMC8vnv0X8o7vgI0MABbx166Sr2bG14YZf1zGi77qpt7nt >									
//	        < GpU7kGKSHsPkzkcfjM0w3OnI5mtLIbK6bvfrIejs2b1jP5qQrlE30xPPVQbV5iQa >									
//	        < u =="0.000000000000000001" ; [ 000034280267755.000000000000000000 ; 000034288258365.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC538997CC5FBAEC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3471 à 3480									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3471 ; PI89I6RZ2c14Qa13hr0ptsZI8729m2VN5NVdeOhQ7Eat5mm26 ; 20171122 ; subDT >									
//	        < PC6XD9Z7w6Cu72khrI7OPiJt27d8U92oS1v5mJUvhRTNqbc6vE2A00A8HJ35MZmx >									
//	        < U1wOk6qSF21HRs567P94N1tpnQDF2MWPNlku8w1ovNr8p0zcBN2MCN29S3hsb9NQ >									
//	        < u =="0.000000000000000001" ; [ 000034288258365.000000000000000000 ; 000034294998144.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC5FBAECCC6A03A6 >									
//	    < PI_YU_ROMA ; Line_3472 ; QJyUe5urES062C428gfyGGV2cZZVRg3g35e5wZU4tGjUAh080 ; 20171122 ; subDT >									
//	        < ShK0788GLDcitb9EYW4PUH633470Uw443nuiryGyL6fhiD6wpAwoh5EjPl55B2bZ >									
//	        < Ey0Xex7nx5QO8qj70p5Kdr4g7nUHF93K3549Wb7IW1fXWp7vp18Wq8BZ3El320y8 >									
//	        < u =="0.000000000000000001" ; [ 000034294998144.000000000000000000 ; 000034305314908.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC6A03A6CC79C1A2 >									
//	    < PI_YU_ROMA ; Line_3473 ; 03E624928wEaqWJ5187S3a7gGd0vFRw6vQWeF854wA24Z0mF5 ; 20171122 ; subDT >									
//	        < B0A7HP0X9f12oLjJd86YozL65j79kMQVaW4vBgmE55pifPY54pWRrmoC2P7B54Pm >									
//	        < 2ia0EtQ2P9zEausd9um980m0S4xlz9IU9x2V3xJ61W9eGe09uXod8pmt4JJvvuuZ >									
//	        < u =="0.000000000000000001" ; [ 000034305314908.000000000000000000 ; 000034317834398.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC79C1A2CC8CDC0F >									
//	    < PI_YU_ROMA ; Line_3474 ; qBqUZ2xUP37UW2G3yrpv52qgm9b3P24V921pCkb8DiLB69bv1 ; 20171122 ; subDT >									
//	        < yYME4w5S6lTA5LQQ0E60NIpR0Z8M04far85Q51FNf1R64t8xTtNOSoTy1418Wkb0 >									
//	        < lX02Xv2tJQdKYefD92W98xi0P5Qy3DFtDjcshIHRtm16YtjO5vI65e4X989Sc265 >									
//	        < u =="0.000000000000000001" ; [ 000034317834398.000000000000000000 ; 000034323142360.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC8CDC0FCC94F57C >									
//	    < PI_YU_ROMA ; Line_3475 ; 6vANS2Xv9DaWRG3oaiRglg37AWJ5f84884y7IkvftB1NvV8KL ; 20171122 ; subDT >									
//	        < NWGL52LITtYFC12fgHAL0gFJh194y19xEJMmD13K49FcYF0JxDFy696vIWEFWC5n >									
//	        < q5foTkDhR3b9XjhcXS9AQn2s3SEknW6KAQ0mA13l52hK6J24F1m9O15mlhs6dDoY >									
//	        < u =="0.000000000000000001" ; [ 000034323142360.000000000000000000 ; 000034332368660.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CC94F57CCCA30982 >									
//	    < PI_YU_ROMA ; Line_3476 ; AyG5Kn2v9QYy9b96DaZ31qP5J2jo3WV0HqHdu4P55gG0QR810 ; 20171122 ; subDT >									
//	        < i1PjY60wScuEB5tOa6zwNoz8Ys8EnRNeN5x15kS35fx0JeJ3HtyYmdl7gn4144R4 >									
//	        < FHgyS16l1i3LDeWuQ2Tj4wq4aT547za41445KTf5Q7KqpV926PslzURe4Ft3Zlk3 >									
//	        < u =="0.000000000000000001" ; [ 000034332368660.000000000000000000 ; 000034342064200.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CCA30982CCB1D4D4 >									
//	    < PI_YU_ROMA ; Line_3477 ; L11O5ziff310nD5rgKW2oUY3I0x9mkqNzKY2RImI2DBrkj9vd ; 20171122 ; subDT >									
//	        < Z3QtBxlM11To70ScAL75RWgfq4fTfXuP46s84Acc1PZdUz6v3EyC6JOQ507Uqwt0 >									
//	        < 3f113d5hWqSOOUe0ic4E36hZW87K10GRGz460AlcvPws82YjOYqrfA28FTkS7Y3a >									
//	        < u =="0.000000000000000001" ; [ 000034342064200.000000000000000000 ; 000034352633846.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CCB1D4D4CCC1F598 >									
//	    < PI_YU_ROMA ; Line_3478 ; ZN05JEYtEUU3MO81s2X1t68pKfj3doY0SSJgRoq9cTE81Jw3y ; 20171122 ; subDT >									
//	        < 10a8kzC6I50EE4yeWtsu2b9msNkuSJVq2M2SbFFYC1bbc8NpVxMKCHd2vbW6FtoB >									
//	        < 0YYklkTpLZkXMAq92035GWuNt1ZC7lbh4tyMXvjXoPqGFzegJxfWeYgJcaS1sXy9 >									
//	        < u =="0.000000000000000001" ; [ 000034352633846.000000000000000000 ; 000034366106762.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CCC1F598CCD68474 >									
//	    < PI_YU_ROMA ; Line_3479 ; J10afK5514O8v88ML3ZqjlEHssW9LT7nRDEKz6W5fRvYj4TmM ; 20171122 ; subDT >									
//	        < r6J04MbK778WmTu96GPt7swx3katojpe2Ep6csZE525k76LmR1UPtBKEa0fz6W3A >									
//	        < 37Ehd7f8bxZS5Nb35aq31lkVdrla6Hvlu0Qbv15vF24BT53B2nxrQqx8Q56l4dEo >									
//	        < u =="0.000000000000000001" ; [ 000034366106762.000000000000000000 ; 000034376637895.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CCD68474CCE6962D >									
//	    < PI_YU_ROMA ; Line_3480 ; wn5vbKnv4k865742D43wCQAn9Zp89yt6MJ96jZLUs39Pn0SWm ; 20171122 ; subDT >									
//	        < x4lkHf9bS00tLUkYEYxEx9P30e6dlyppBd1JJ2U6bCcO58nd1yqpYU49lps73wTD >									
//	        < 9u50PkJ4Bk20ef4wkQBZ48mVvALIHn8PLvXXBbmgpfp4pClSI9j5MK803Lzb9Vkd >									
//	        < u =="0.000000000000000001" ; [ 000034376637895.000000000000000000 ; 000034386860051.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CCE6962DCCF62F35 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3481 à 3490									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3481 ; kgs2uNeqnEciw8s7IF3gwcBMQ182Fwaod1oNf9V67X3Jco397 ; 20171122 ; subDT >									
//	        < Wpk649m8j86g364FR42VA98FO7D85l10FWzbnbgg97lH30M19G0VW34arJ8yFUY7 >									
//	        < 7dbJKG69tUn50xM5JP3JJ2ybuxmNTT69AYoLyyhtgKjF71e67R62J8811B5rpd4T >									
//	        < u =="0.000000000000000001" ; [ 000034386860051.000000000000000000 ; 000034398926186.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CCF62F35CD08988A >									
//	    < PI_YU_ROMA ; Line_3482 ; QnUqpy2HFO60cqYK6KNOq6wSrNQySFb2mlRA6Bd9I66Z5l0N2 ; 20171122 ; subDT >									
//	        < 2Vu0xV3x426En8uxol8Ov9hx4QV9y72Lh7a7gs1a6JNZW77Y2s4HbnIHcKFDe10w >									
//	        < 41GDXv6EH3CiCbm1P8v4117j19Bhp2U9QzyTn2N0fAe1obvXe53uiLPPuBYrM7iY >									
//	        < u =="0.000000000000000001" ; [ 000034398926186.000000000000000000 ; 000034405867777.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD08988ACD133019 >									
//	    < PI_YU_ROMA ; Line_3483 ; vDxOEXx3951dwNRbZFenu2aEey49nuBv3814Mw675ek9JG6Gt ; 20171122 ; subDT >									
//	        < Dw85JxqB7iziWwVM7KYHun2DU613J5L5bOLX088x5E690Z81YJjLFu012um7aziU >									
//	        < r7tpS4V98viI7ZFSEQoRV2wS8JGBx5HO5kzL3cvR644wFGGOMC949BfC6VMY727N >									
//	        < u =="0.000000000000000001" ; [ 000034405867777.000000000000000000 ; 000034414368991.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD133019CD2028E3 >									
//	    < PI_YU_ROMA ; Line_3484 ; wvaMFOxDwZ1fH6T2mSzFEx9rVmmcjhk458P4d7VPs6T3N8U8H ; 20171122 ; subDT >									
//	        < J745b9Y16fJs6TR9a8w8s05Qx1w071u9cncUsXVCgr6XhpQix6DUIt3I5uANMn6H >									
//	        < BkCP3343ifNVsBCjwkKPSGYPzMxrri18EbedDY3Ju8Xej1rx81iFcaCR8atQQp2Y >									
//	        < u =="0.000000000000000001" ; [ 000034414368991.000000000000000000 ; 000034428220461.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD2028E3CD354B9E >									
//	    < PI_YU_ROMA ; Line_3485 ; W4BRt3hM9Ib5LnUK5lHw2AJ1f9ELrGZ7RF7UV6kyFSLOa0020 ; 20171122 ; subDT >									
//	        < 8Nwi7vw8m041kyU8L8dR518dsDIx6uP5Q8I9Mga2fYDWaNeKYHQb0cBwsm1A8Of1 >									
//	        < 29aBAP1GRBAL4WYtOxZ444y0NM6A6jFokUHK2x9SIE22JHAwt0XWgCPKOW3ZVq7v >									
//	        < u =="0.000000000000000001" ; [ 000034428220461.000000000000000000 ; 000034438564141.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD354B9ECD45141E >									
//	    < PI_YU_ROMA ; Line_3486 ; N5HT0XGl390G6846yNxPtWSAK9Yqm6up5t6J1XMAzSw4WPv82 ; 20171122 ; subDT >									
//	        < 7B3MrQr6zOEiX43QYRt0aJEP4vBHzbp9x7DxJ1648yC9OMOD7qGg1Xe7Jp4oSy6X >									
//	        < QM6UE1XqsIhK8YVd9Oynf0HvJfAGzmt058Tx5o3CVlFwl9p6Z1imXr13cuX65b00 >									
//	        < u =="0.000000000000000001" ; [ 000034438564141.000000000000000000 ; 000034449240648.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD45141ECD555EA0 >									
//	    < PI_YU_ROMA ; Line_3487 ; Xd7F0HhL9n23W6T6pv7I5Jm0L0zhnA94R7642paV7Q3CFEyy4 ; 20171122 ; subDT >									
//	        < 3xqR739Dm7i8lbYHDhZeRpw99tTS9v3awA2iGLF4Vj63uPukrso75hlThSD5MgS5 >									
//	        < 7qe4nj4heH1z33782lB448w9oEkkDgwH51u8yjZ0B2Q6VSwrK03Y5RV6590W44q2 >									
//	        < u =="0.000000000000000001" ; [ 000034449240648.000000000000000000 ; 000034460563641.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD555EA0CD66A5AC >									
//	    < PI_YU_ROMA ; Line_3488 ; Zv46952By5WuVrX47Z2dehJLmwCc9l9i053VMQfCsc4p9uL7i ; 20171122 ; subDT >									
//	        < u6wv7UU0TuV56ndU8UD5AoTf8fkruHi3DQYOwiXGER9s71bKv4p9Q0HjP7h8EU9x >									
//	        < huK03vl884qPU5z592sT1B2BW611Uq487Y3U9vlifiQFjTyyougGToN0K4F7NZe3 >									
//	        < u =="0.000000000000000001" ; [ 000034460563641.000000000000000000 ; 000034468169312.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD66A5ACCD7240A3 >									
//	    < PI_YU_ROMA ; Line_3489 ; pNMm36g682V1VzxKnv1Hr8L95t611g4cRo7o6qIWZ4WJ7Id91 ; 20171122 ; subDT >									
//	        < j87DVNfhDw0g82qWIu41ok5bdo61mKAlneW814pt4eSOM5E4i12T51130YMIWVr3 >									
//	        < 9h9UMVh24P4hnw3d5LIwyQ8C92cx8vd7DKE19511XuRLUNZ9MppDZW657TWujpLf >									
//	        < u =="0.000000000000000001" ; [ 000034468169312.000000000000000000 ; 000034473539917.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD7240A3CD7A7287 >									
//	    < PI_YU_ROMA ; Line_3490 ; 75k3916J7nSS9z1HIIRxb1fZw6okCG53WY3lchjz2uqFcBT66 ; 20171122 ; subDT >									
//	        < KFiDZSum0C2xkxErzju9fM36e7mQcALHx9YmN4v7Jm1kbwzp2eSvCsdpPTVIH19Z >									
//	        < BoJfBaRCTzfS3S27Pkf8aqB677lhefOh6Oz8nEoi03O1SEM0lu4TKCqz777T6u68 >									
//	        < u =="0.000000000000000001" ; [ 000034473539917.000000000000000000 ; 000034485677360.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD7A7287CD8CF7B8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3491 à 3500									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3491 ; pdeNAUo4z0RT2ArbO7l3hyE13IJvzrim83R984bSc6o01LwGZ ; 20171122 ; subDT >									
//	        < jtHwEcbA2Eq204Y4058Xc8v556UUj2K4weQke8a48aQ01v5b9zvdoP6B2e455zrb >									
//	        < QoAbdYs8Ip4Nd2kU25l3dLIL1Q0Ir132SiYobOfWB8yW6C52j4tnkhkfc5Bey8vI >									
//	        < u =="0.000000000000000001" ; [ 000034485677360.000000000000000000 ; 000034499093155.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CD8CF7B8CDA17043 >									
//	    < PI_YU_ROMA ; Line_3492 ; Vdp34NxV32h3Vc04y1x3bh21YE6sSFQw5deate8Bj69Dr282l ; 20171122 ; subDT >									
//	        < 3895wimj35WwTF4urAJp0t54YMkTIM7an7xLzFH2Le0f9YcP3Nu1D77Oedz0bofW >									
//	        < rMP3u7Z8m3mcSg5n6b594DKUb1vRbUjH9cAc5z6j6d6OBz9Zw574G50f4XIV810f >									
//	        < u =="0.000000000000000001" ; [ 000034499093155.000000000000000000 ; 000034509232510.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CDA17043CDB0E8F3 >									
//	    < PI_YU_ROMA ; Line_3493 ; 013Ntp3yLN9P6v0kN6t9UbBNg550b4106SSe2z89ZY33rA2T9 ; 20171122 ; subDT >									
//	        < 7p66Yqzm8J4tBnIfifA05r2y709ld4CD8UV8BO86qx5V8ZkN68B2De0x9603uRNF >									
//	        < jne48S70810tRaRq2LKURw3938GG3H4R1GE308vT6B9yo7V8xqGOmgTmX1B4rCaa >									
//	        < u =="0.000000000000000001" ; [ 000034509232510.000000000000000000 ; 000034523757681.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CDB0E8F3CDC712D8 >									
//	    < PI_YU_ROMA ; Line_3494 ; QBncgQ7IgTG9b4zt6df7Rk3e56Wv3TNdL7iJOszEeap6c5B6u ; 20171122 ; subDT >									
//	        < DmsEDCZ8RyPs3UkGw3G3l8vhjKGrM1yBj885Mey8HCL86BYTT3M4Gn6CVsbhsimX >									
//	        < lhArC0Gf476iLBS1kZAII3J1sI8fbhCQ31w8TN1R61x8bx68X8g611YmKNvgJHYI >									
//	        < u =="0.000000000000000001" ; [ 000034523757681.000000000000000000 ; 000034535452461.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CDC712D8CDD8EB1E >									
//	    < PI_YU_ROMA ; Line_3495 ; yk45aWL0W60qGK635Sc26R9526JrI7C800icjxwLUKKmXwwWu ; 20171122 ; subDT >									
//	        < taVGYK82ze1Ak0n78oSorXu7ST2436C33LUmaIDyDox0h5fyK7L54vmYErmsDHLF >									
//	        < Qvp8UxT0EK0E3770j549ttdHGIw8r8v92gm3aDeLl6T6XZV5v53FyhJ5y0j8L3wI >									
//	        < u =="0.000000000000000001" ; [ 000034535452461.000000000000000000 ; 000034547038267.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CDD8EB1ECDEA98D2 >									
//	    < PI_YU_ROMA ; Line_3496 ; cjR1Y8fZ2e3CnoxTH2Pj9Q7Jfs7Drv6hbBPuW69Lj42bHnBFl ; 20171122 ; subDT >									
//	        < W5a3iKWlMu0k7Jgj110FI2N9HZucw7gN8D9tnYa792Fng1mJ4ad6Nx0iw07PGfIa >									
//	        < Wi51DQR35j85ivn0UU0C6hdz5tZ3p2DQnzKfwq8n0sDbZq1BIqM16eMA6Z2JaMYE >									
//	        < u =="0.000000000000000001" ; [ 000034547038267.000000000000000000 ; 000034560967287.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CDEA98D2CDFFD9D8 >									
//	    < PI_YU_ROMA ; Line_3497 ; N5c3EhnV8m0KP0J3Kg48mY3a118sj9K45ZdUC91hZsO0sT30Q ; 20171122 ; subDT >									
//	        < 34LpCrsWTEmN9gFRehsUZ1O12Z93c5n7K3v7wI3OD58V3051St94K8fvH9uUrh8E >									
//	        < T5C884b0aR3VOX56PW8x3rkEwsRA6WwFAZth1jUl5wqhV5ue9tf33286UW2MT0v8 >									
//	        < u =="0.000000000000000001" ; [ 000034560967287.000000000000000000 ; 000034574117611.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CDFFD9D8CE13EAB1 >									
//	    < PI_YU_ROMA ; Line_3498 ; 50r56xKsw09vWu63mm5xB3671uPB2W0sFm68uh0rFPRv09tyj ; 20171122 ; subDT >									
//	        < 816Ngwjw26C96E9360p36gdrouUL6Jza8a5CoV5J16MrzByD60IkWDe1aQ4PJ646 >									
//	        < 43PhxNskZCe88lDBa4QU8Tjjc6xY3kU069ZcvK0nFXW4JW8MS7E1zpE1N80r2ak5 >									
//	        < u =="0.000000000000000001" ; [ 000034574117611.000000000000000000 ; 000034584693773.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE13EAB1CE240E01 >									
//	    < PI_YU_ROMA ; Line_3499 ; eR4k7H5OzBqL8mR8jn3Kw6s6j04krPy1769yX6c8BgUjLeWW4 ; 20171122 ; subDT >									
//	        < DG3gMNjTe3h5HO9p8lZ2n6CQK15aG5iZqy0Gv9n6mTV14ZKuAQ8c1EPW1D1Vkz3G >									
//	        < Wcpk1s06gTC1uSEIQMHyZ0jhlU1V7t1N1tpPHZc15UJ3GojZId7u78NBvIxxyI6I >									
//	        < u =="0.000000000000000001" ; [ 000034584693773.000000000000000000 ; 000034593061937.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE240E01CE30D2D1 >									
//	    < PI_YU_ROMA ; Line_3500 ; 5NTBi9T4df38az3H4UAZZxp34B171ccknwP3MK2qO6SFq6Pr0 ; 20171122 ; subDT >									
//	        < 636i7pXlkCmK87Q1R6tVraw54V2e0O818H8E1urhx8dd02Gv4ZFV94o4rK1x4Pf0 >									
//	        < W33D88Z5Z1oDYy4U83V7HiAgOY90992W8Bw66oO05VkD4d7aTFAv0Path14h9yOF >									
//	        < u =="0.000000000000000001" ; [ 000034593061937.000000000000000000 ; 000034599027475.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE30D2D1CE39ED1B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3501 à 3510									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3501 ; GAn7V1wMA7oFZr7CKyTnowzB91R3s69D76r1h03Z85yf79d7x ; 20171122 ; subDT >									
//	        < 27rN678plEm6wS2W2fKfNBMPiBk995H73sxxW5wWrR97O525E9Us2j401UM6azvm >									
//	        < 9c7KbN9sBYweNcIzRQmD14t2N27B3tn843TsPSY5w35p7g87TcC4V69TSmpW4s85 >									
//	        < u =="0.000000000000000001" ; [ 000034599027475.000000000000000000 ; 000034609813558.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE39ED1BCE4A626B >									
//	    < PI_YU_ROMA ; Line_3502 ; kh1eaCsKe93Ut81L42uaLR9lx4o4euuKP69L6AnYSbtK9N52t ; 20171122 ; subDT >									
//	        < e3UYQR0r7gwocj8Db3i960WV0G8ZX6nxE5lalxsar10X13399s3aYfl57Mmv9H62 >									
//	        < AwLtDToERg99JzTfc30RZjkDA3VrXjnX2Z11V9u79pg6YVp3hxDEddAU34IdTQ9T >									
//	        < u =="0.000000000000000001" ; [ 000034609813558.000000000000000000 ; 000034622946735.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE4A626BCE5E6C91 >									
//	    < PI_YU_ROMA ; Line_3503 ; 1q30hud2a55qPuC8c029IO6e6QH1tQrR40NA8CfqVal3GJIoM ; 20171122 ; subDT >									
//	        < Tn302U25F9BVz1pcb5H260IPtWXZ35d3EYOHI4n8D171v6tGAS6i14Yjku0975qn >									
//	        < 3ykP1U3lJL64RpKy5Lem4o48J2lkEZRXKl00qYyz58PP1fR4dtHkZ79lP9LtQn1J >									
//	        < u =="0.000000000000000001" ; [ 000034622946735.000000000000000000 ; 000034632636865.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE5E6C91CE6D35C6 >									
//	    < PI_YU_ROMA ; Line_3504 ; IAZXX5Sj52I6lKH98WFcuXL9Uh2xO5D2uCE1LKK3B6O8GYZhI ; 20171122 ; subDT >									
//	        < Hz28lRj0KS3e162HJF2THBYB609b1I9e4s208Bvb9oxfZ7BdZWc52JAQa24F03wD >									
//	        < M525011s0U7U7nR8x15tE2e2ZyhWKPNx0VRrAzcdnvBbW5V9S226Jmx98h7OI298 >									
//	        < u =="0.000000000000000001" ; [ 000034632636865.000000000000000000 ; 000034640436397.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE6D35C6CE791C77 >									
//	    < PI_YU_ROMA ; Line_3505 ; nGk125sA9TF3S8C92MQAtuL1vM272X6H3yoMX3f2NTkihXxey ; 20171122 ; subDT >									
//	        < cvo90hePKiyJ6843q4lM87cjjy1NO1Oo38POeB1ycTPrSixUe30ZzlXd4p2Phsrm >									
//	        < r562Exs2rrfJ7606S5Ut1IF5643y5TOCMDqIs7mb2QZJmUx7X0jpu073i1OWk84a >									
//	        < u =="0.000000000000000001" ; [ 000034640436397.000000000000000000 ; 000034650529095.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE791C77CE8882ED >									
//	    < PI_YU_ROMA ; Line_3506 ; Q4vA34y4SYF49lKE25tbjMMHHn97sDxB6w4IX44g3KW0U0IFG ; 20171122 ; subDT >									
//	        < gM85wa3XoB1F0GsJ14c6i65H2FTT3s4I7JrmrfuObbtMvau4l2J2z6Y1F7l3pXxW >									
//	        < 47OgNsc7AM175MXS5t077FUcc7SHuI35pBk1F48jODQwk2lNk0zLUOUx8cB609kB >									
//	        < u =="0.000000000000000001" ; [ 000034650529095.000000000000000000 ; 000034658317272.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE8882EDCE94652F >									
//	    < PI_YU_ROMA ; Line_3507 ; 41oFE8s2Ql5GSDca5GvSNEy627Q2452TUW86iDI97M09FNn9l ; 20171122 ; subDT >									
//	        < 3ZRKM8h6bq8qnzis6u29tFt7y373N5EZg4bl5814O4FeiH7zz187fHV5ChtO58TL >									
//	        < YTGuRj53yL2UL9j2bnPFQpXz669BR3qUsr4NkTW99sq79GdnzHqLeo42s1i7HfY1 >									
//	        < u =="0.000000000000000001" ; [ 000034658317272.000000000000000000 ; 000034670749412.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CE94652FCEA75D7D >									
//	    < PI_YU_ROMA ; Line_3508 ; V7akXCm6FV1r974A6hdCeW9iQ63oQX8BZuk5r9uP9dv11YTRt ; 20171122 ; subDT >									
//	        < K9MEcdh0COnErPpL7FCP11SXwMLr97SWKb2937E6okHf9HG8qRQovc9mOMKr6Phi >									
//	        < 7420149poc1PGIWge947nhqk6RuBoom9vd5VdLQq4Jkb46UYg32b0bc36MCPsh7B >									
//	        < u =="0.000000000000000001" ; [ 000034670749412.000000000000000000 ; 000034677428347.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CEA75D7DCEB18E72 >									
//	    < PI_YU_ROMA ; Line_3509 ; 6c11nByKW3r2T9ZRQEntPAHGavH2656ngk7x3Yt85n4y1fH6v ; 20171122 ; subDT >									
//	        < d4tXSOjYYUh7sSxYQGt7XStRa9u9VpQ6MR62WK7b4iCuuL12OJo665zNZBBL0Ys5 >									
//	        < 6WhEFr4Gw2MHF8y3nlDmSrc5oQ2jPg4ade414b35zhiF2j3Kns3DZPrV7E1rYz4m >									
//	        < u =="0.000000000000000001" ; [ 000034677428347.000000000000000000 ; 000034690716004.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CEB18E72CEC5D4F0 >									
//	    < PI_YU_ROMA ; Line_3510 ; UCH44jbbTVX16tn5g3jqG0Nr4VgHLIV3S8jlSKTvQQ75U8tbP ; 20171122 ; subDT >									
//	        < l6o8rkF4DUIn3P8EhHD2Eiz6eVmAsclQu81zvyFkD9CUFSIt67Vjtp25kmmq4lN2 >									
//	        < penPefl1hbIzSJ7E0i4sP0358cSEr0GZkn0mI9biBa86CP7f5lGW4ffyX8U1eg1Y >									
//	        < u =="0.000000000000000001" ; [ 000034690716004.000000000000000000 ; 000034704580910.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CEC5D4F0CEDAFCEB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3511 à 3520									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3511 ; 8YVNmF6aNrK9pYxwBT88EKf300IBgWc816i632N067amafYY5 ; 20171122 ; subDT >									
//	        < b81DlVQKTwJ8rr9gPWy9a104vZi3DQYYxX1CxMmSiB6KaMTP0Q15Wn07HUlKwuj4 >									
//	        < dTTeGn5gPtd9h2XNbWsa82o0yAv54fSznIknTP8p8FZSR7E7saFXDpPs888KZ1ie >									
//	        < u =="0.000000000000000001" ; [ 000034704580910.000000000000000000 ; 000034711931341.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CEDAFCEBCEE6342E >									
//	    < PI_YU_ROMA ; Line_3512 ; x8Qswjb8n9tAg8DzSYY4im9vmLIF5Bvro1a9Wa808BsgRx1RD ; 20171122 ; subDT >									
//	        < 41MjN3p9126Eo64Q06T6aacO3q1TVQL0f48oXrJMg8W9WapIHSKAuOSc1P35tHm9 >									
//	        < 88hTtbFsNO4G0480Y5sw8tnPuLLvaJnp4NVT8W64mg7zyU4f6KIbLwppR2nk82Gw >									
//	        < u =="0.000000000000000001" ; [ 000034711931341.000000000000000000 ; 000034717758537.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CEE6342ECEEF186D >									
//	    < PI_YU_ROMA ; Line_3513 ; xDQO3M29U7EcPM0VLIOx86G1F5eC3wQ523RR193Ni6nBxk8Q5 ; 20171122 ; subDT >									
//	        < t864j4fnC80DKze47dw62wQlmjBC3c0u3ziC6u2IgskiRjKa47ME3KroP6967A5t >									
//	        < t49lXKT6K49273790Ag902g5DceG2uA58Ufc0kqPWVc285kR74Zy1O4j77zB73lW >									
//	        < u =="0.000000000000000001" ; [ 000034717758537.000000000000000000 ; 000034726764554.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CEEF186DCEFCD667 >									
//	    < PI_YU_ROMA ; Line_3514 ; 7BqOv02A5j96umldt9cdUUPztgC515md7XfC3l4zHRS0Mi2DM ; 20171122 ; subDT >									
//	        < 5SQBI0u0A7Wi9O410My99lDd51fxlH82BU06ReN30Q55ywdax7Y4jj8gUC98dPf5 >									
//	        < 6f52F01F33zeaMoFwd5JPQv473W2TpP6MR8zx2yTO3r10FVaEqAPmm26l23hl5H0 >									
//	        < u =="0.000000000000000001" ; [ 000034726764554.000000000000000000 ; 000034732111628.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CEFCD667CF04FF1A >									
//	    < PI_YU_ROMA ; Line_3515 ; JvcJ2F2eWyMskBGXg1X7Pd489FJM25GM7g6Y18oKXaZm884Ky ; 20171122 ; subDT >									
//	        < kG0mi4Ui85P8s4VAh5laLGqi6ZsGtzP6boGE6L8C21Reo1J06Zo82yHn9nSH38J0 >									
//	        < oR7E9qu0Q0J0yrasx47GbkRMK1qcaOuyASYTxxB8raGqwubynht9JpzFWbG9zjWz >									
//	        < u =="0.000000000000000001" ; [ 000034732111628.000000000000000000 ; 000034743863779.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF04FF1ACF16EDC9 >									
//	    < PI_YU_ROMA ; Line_3516 ; CuyEOuJv82tBB4p1gEDm6riZG3fV7l0qAwzedwiFcPNWa5m8l ; 20171122 ; subDT >									
//	        < bukojq7U9TDs42ONj2J175510p56qT61tmo459aa2344Gv9i2c6bj9275eEgr7jN >									
//	        < 21uhp60GkXtNv9Ed4HQX810SVd4lFk367XIJLf01zeMYQ2su9S5dlOVcuzng8k4P >									
//	        < u =="0.000000000000000001" ; [ 000034743863779.000000000000000000 ; 000034757745514.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF16EDC9CF2C1C57 >									
//	    < PI_YU_ROMA ; Line_3517 ; X3FMp2k91P17sPSe79rRzd37DRWvbca6P89SM009834edb026 ; 20171122 ; subDT >									
//	        < m130Obk8oGEV3EmYCl6TLbiEX5fz12VcBh6t4t89bw4mv9m5f53RJ31ilj86Lilh >									
//	        < 55UVseINmOar9ivH223c9TZn136Y12R17Di06px4VEaLcIlHSJ17GLHmtMha6tu9 >									
//	        < u =="0.000000000000000001" ; [ 000034757745514.000000000000000000 ; 000034765524209.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF2C1C57CF37FAE4 >									
//	    < PI_YU_ROMA ; Line_3518 ; P8J349SLBDtp91Ma3eK2LvYGx6OX7k89Aga2E052t8H5Kk2w8 ; 20171122 ; subDT >									
//	        < uk73U7tg5wqOiQBwt5O8A0lH81e6x87UZ1586dBObv1NW2HOmLqj1Odi77m0cvik >									
//	        < 8861UsgItM77O27QrXgb3RfpSQLudR00ZxQA1hVHy68zfgc5EQT9BfkM4K93E7WA >									
//	        < u =="0.000000000000000001" ; [ 000034765524209.000000000000000000 ; 000034778935009.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF37FAE4CF4C717C >									
//	    < PI_YU_ROMA ; Line_3519 ; 93Zbj13IgA3h1cE4Mz79j7BJwMAwKevMWq04ygdJ0JSp3Zk7L ; 20171122 ; subDT >									
//	        < HOUSFu37q1zsTw82m6bTJEfWzI3eG8C0BwlVF26h9j3yeLX9U66l28lW12IYhvoE >									
//	        < sXuVQ9SB1DF23COo0nW0WqT7Q34C8LE2PmFpO6phSrqUHWtDZ4lht714lTDYG6Sj >									
//	        < u =="0.000000000000000001" ; [ 000034778935009.000000000000000000 ; 000034784805191.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF4C717CCF556687 >									
//	    < PI_YU_ROMA ; Line_3520 ; CcUI08GVEeU9dQFci54bh8Uoye4bm7gc6X9rxKO2ST9kiFWw2 ; 20171122 ; subDT >									
//	        < fP4U8dG5F4Yv4935W871kCg5b5bVL6V2TXz5yRmlB0DEVM4hZ47le66c35k8uPml >									
//	        < 4UpruWD7iYzZH3xRaH427D53T3683DEYdZkoCSuEkcl9KDkEjuxQGvt7X8gjxZi0 >									
//	        < u =="0.000000000000000001" ; [ 000034784805191.000000000000000000 ; 000034798558789.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF556687CF6A6306 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3521 à 3530									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3521 ; 7w4pTECf7cGiWv75B2yCBMMS88SH2FQP30UBWGllW7emAY577 ; 20171122 ; subDT >									
//	        < e2d6t0Czyme0F9LmzUd51WgEuqx0TONVZ8ZGqiM5G9p9OFELzWX9izvK0YJM1oiv >									
//	        < x11K0wWLdw8dise32G6W623o9Jy7Cu950XD2XYvN3H5Pk2RdKZvqMAs1Ty4ZU3RD >									
//	        < u =="0.000000000000000001" ; [ 000034798558789.000000000000000000 ; 000034808311878.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF6A6306CF7944D3 >									
//	    < PI_YU_ROMA ; Line_3522 ; V6TUUgP1g3I53875SD9CYHyVpW5DT0xWY58sy1n4MnW45cSYM ; 20171122 ; subDT >									
//	        < 13AYMli5QCb7Ml7V265w45TbUDgvvGJR6qpC19Rs7uq0lP02207n58531vkc8sPM >									
//	        < IaO2r15992zUgOfny30A31096N9anxy1lIfKixaO14O4rZSSfD5Y9gl6Df6lEnB0 >									
//	        < u =="0.000000000000000001" ; [ 000034808311878.000000000000000000 ; 000034820810420.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF7944D3CF8C5712 >									
//	    < PI_YU_ROMA ; Line_3523 ; 4qIXL52ZcMeNKHhUbiXl1ToT81Br9S3t1eYQ1ZaJx0nE45IV1 ; 20171122 ; subDT >									
//	        < A16ieLm4L40e30HK2m5g42tu92B341355iaKLqT06COnHs8umvjFH70Pp0wKxTIg >									
//	        < Msk4WVH6l5H1vEUdK12Gqo7Ewq4bS7U36z5VVZHD70l0JcEz2X6QvFrJ6TvuNoA0 >									
//	        < u =="0.000000000000000001" ; [ 000034820810420.000000000000000000 ; 000034833332904.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF8C5712CF9F72AA >									
//	    < PI_YU_ROMA ; Line_3524 ; EwUlqIH456tr3pX2k66zIyyME53uL24Wch3cZgCUhr3RANuRk ; 20171122 ; subDT >									
//	        < 8NLW2J9X422a0D8xCP95N358E29RFkp8oZ9jjL69NYzXHw55t7A69zGQx174uZW3 >									
//	        < U8iv5wYJ3dS47ZEJzqlufFqM00z9bQlNS4880iKqQ6ovzm53V8A54C15P7T34hE2 >									
//	        < u =="0.000000000000000001" ; [ 000034833332904.000000000000000000 ; 000034844425073.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CF9F72AACFB05F8B >									
//	    < PI_YU_ROMA ; Line_3525 ; 38N1jD0ZGR7k2YAX7oGhg23ha79bBmLx262DYBqN456kIc185 ; 20171122 ; subDT >									
//	        < 9NCwk0r70uR7o1bxcy09t1F0zX3F1Yx801wE5v46aX17K68iZ37JptJl87gBBp86 >									
//	        < aeqbaVy0xXB7TL9TiNmcaYILS8tPmsET4e9G5gWyEhphY9v5X1BDYfhbyfYy1908 >									
//	        < u =="0.000000000000000001" ; [ 000034844425073.000000000000000000 ; 000034853751652.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CFB05F8BCFBE9ABD >									
//	    < PI_YU_ROMA ; Line_3526 ; r2E2gEyot7Y3unvC8Ry9O6n0Dpi2z97CYZxm1aCBkU13ynlqO ; 20171122 ; subDT >									
//	        < Z3pS7N4FlJ9ePp78mFN4144xqgd3ByIpm8fw1hldyro24QMtPrb1k8cLNelm9710 >									
//	        < 91pXL4KfIU85QF8284x9LnxI8IBoXI1a111m9M43I7nV43sZwePE5K59bgR6xR82 >									
//	        < u =="0.000000000000000001" ; [ 000034853751652.000000000000000000 ; 000034867570595.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CFBE9ABDCFD3B0C3 >									
//	    < PI_YU_ROMA ; Line_3527 ; HvM5016Wsi93Aw5I2B44bJB2bHLnM498M8ukuyV463L0yT33s ; 20171122 ; subDT >									
//	        < j76v1M4baHw03MUo0bpw1947RAlu3o42SXQ55Jy3D7an9e5day4pzK0S3ouJxklt >									
//	        < dg4wN80bP2Htg392WX0u4PuELg0Ww6cfXN5YE0w0Iviy0p9xBuz87bcWzLX1qlbN >									
//	        < u =="0.000000000000000001" ; [ 000034867570595.000000000000000000 ; 000034876961156.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CFD3B0C3CFE204F3 >									
//	    < PI_YU_ROMA ; Line_3528 ; 89zW0093JdnV6svbXi3YWw27bXrwbA3Enx4X6frx311gK0tUE ; 20171122 ; subDT >									
//	        < DaQloBdL911aLL22Z36593PMim00kguzpK90X61rfW2IH1lcX3XN9GA0v1XYdb35 >									
//	        < hb7Gxybq0pNFr8iej4Ikc51169z28WjNytgnYBqzRNGSH1320B4kYpIL6f6GvOE4 >									
//	        < u =="0.000000000000000001" ; [ 000034876961156.000000000000000000 ; 000034890504693.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CFE204F3CFF6AF65 >									
//	    < PI_YU_ROMA ; Line_3529 ; z5o9jt35tkxwHVL8Y1y9Qf1t1Ga3xyTNZ5Z22O13fV229u9nF ; 20171122 ; subDT >									
//	        < Oc0kF3wm12131kw9f6fz624qD05koY2uXcg0UH7g6L0Z9GVJ9B1n0tPA62qE0ux2 >									
//	        < 339rQ5083KwiNUhn8iD8vDVk0xbYhrIs3Sy5MdPI17i051ko1jGrCX3saW6jaCvu >									
//	        < u =="0.000000000000000001" ; [ 000034890504693.000000000000000000 ; 000034904574372.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000CFF6AF65D00C275D >									
//	    < PI_YU_ROMA ; Line_3530 ; 1cuus658RocA8326a86O5RRFEzdxuN8wDis2b92O7Y7Y45sWh ; 20171122 ; subDT >									
//	        < K2Y4LhtVJaIy5muZNU9FQ4j9vvq6ZI60Q62zC382q858QqVez3UDP903G5HuzUZt >									
//	        < o8fFYtcwUZU9Okf2ejCPpUto3aQwGKh5ZRlzmFb4t6TEIU3UYM1o0b7BDa3ZaK0C >									
//	        < u =="0.000000000000000001" ; [ 000034904574372.000000000000000000 ; 000034910877953.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D00C275DD015C5B3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3531 à 3540									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3531 ; 63nE6CNk8xKnJkvtfff0F75KpDE8ZWtoayGSb1Su83sB5W509 ; 20171122 ; subDT >									
//	        < n6fWQG8RzoB71Liq1lXRx7WwOpg82ubu12267uZqa15hKBtG18p9v2flu4J9V78l >									
//	        < E2Wy3Yg18Bx45T3nfPCWAvefFmhK1qx0676RY0a57bV230g7cwX57t949B7vY22F >									
//	        < u =="0.000000000000000001" ; [ 000034910877953.000000000000000000 ; 000034920583712.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D015C5B3D0249503 >									
//	    < PI_YU_ROMA ; Line_3532 ; iG4hvU3S5ULEhem5EJ25q0nTgTTLL5xc1NHKI9i8L6t8VFC67 ; 20171122 ; subDT >									
//	        < Mq2aCbX9v0rhXVyR9Dk48lP7Q81YKIrogJ3smo6QYMKoI1AMMClI4Dc4Di7ehK41 >									
//	        < 1o7Abi9L8hcA4eZ04c0Disi39V10Ofe4Y578q8iFYDlpsyn07265023f7329sgSm >									
//	        < u =="0.000000000000000001" ; [ 000034920583712.000000000000000000 ; 000034926340619.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0249503D02D5DCD >									
//	    < PI_YU_ROMA ; Line_3533 ; vLDb34FccHfL7UOw1SUR33Y8a7FlW32VKmPtuN5F9QEZWgr31 ; 20171122 ; subDT >									
//	        < Yrx3EOJohV807523FF0aB84s00QsG6r4SrA4TD1n102ivI034lmsnz99XI0P8sHE >									
//	        < 7839sXHnSwP3A6w3bV15YZ60XzG4fwuMJL3jGKNzPpa6Vw78ySviF4euJ5cy1S5o >									
//	        < u =="0.000000000000000001" ; [ 000034926340619.000000000000000000 ; 000034934389869.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D02D5DCDD039A60A >									
//	    < PI_YU_ROMA ; Line_3534 ; 8x0MgOuc3muj0y20F22ZRYwa3SO7V2nG1j1li4QF0Oz92311b ; 20171122 ; subDT >									
//	        < tg8NaNc2o6s8Qknyxru5QryQU7j8E8cTqDizcj840334JkZzHopmyKQe3Go84H7u >									
//	        < xVbMyGF8A4y2E9z8D2pz6c1c8g8liNF6Kj77k53uSBotayqlClZdh34J2eY1p0oD >									
//	        < u =="0.000000000000000001" ; [ 000034934389869.000000000000000000 ; 000034945842464.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D039A60AD04B1FB6 >									
//	    < PI_YU_ROMA ; Line_3535 ; LUvl2l3OfsgLMlz6knDFCsc58j0g7hNcALiGU0c944g5q37P0 ; 20171122 ; subDT >									
//	        < Cf33jnEGu9vNF4EXTzlQ37Lk5X2h7zq2l8G19uL2jgNykTJ88JG6nblLtb61xucg >									
//	        < 9cKsg8RzHykjJ4757NtypH2CpvO3OZlk984tOUe64s3hSIRKr6n8BW9WaJpEnQ88 >									
//	        < u =="0.000000000000000001" ; [ 000034945842464.000000000000000000 ; 000034958214696.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D04B1FB6D05E009D >									
//	    < PI_YU_ROMA ; Line_3536 ; s56uIArWzAEV86oinoRQ95j7bDx38bdf345bo6E1vg2Ge784H ; 20171122 ; subDT >									
//	        < ivji7A4MwwB543YJI37nh7Aeq6E1jwI326r9Qgk68J7rZ1h1Huv0m8s78gUYUtRX >									
//	        < R7VnztcQEb74Fg71L71bfE9S8He4aeXPgt0RTfhpWaBiT96n234Y5S34JF5YZs1p >									
//	        < u =="0.000000000000000001" ; [ 000034958214696.000000000000000000 ; 000034967236878.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D05E009DD06BC4E7 >									
//	    < PI_YU_ROMA ; Line_3537 ; OZsm82U0AMqRQeJTQPs9v2gPte82n3Pwhe30yw49GW3Oe9637 ; 20171122 ; subDT >									
//	        < WkfZl65fxM5LbgGYS2HKO1E28B3w8Yr7iG9P7N259MqK8KtKxO1lO0Rxx860473j >									
//	        < jXcyV96cCeEejMpEaI4f6x1bpUsY70317xwlVT7p53uj1p067wbLrBZ21TT615Oy >									
//	        < u =="0.000000000000000001" ; [ 000034967236878.000000000000000000 ; 000034979709986.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D06BC4E7D07ECD36 >									
//	    < PI_YU_ROMA ; Line_3538 ; oxlJZVq3rf0bxI613rq7g8lDHoC02HG2P5sI24AYcO9itQfkY ; 20171122 ; subDT >									
//	        < p8wwYGbFeXDI4Hfgdp3hAwGbCxN2LF4X7pplSDVPO6OXo55L7fCcX1houjJ248vL >									
//	        < d8e9c7B20218Hbsvjiqp6E0884MYd737bNtHPjhnJimaj7K8aeN780DHGtM0z7ax >									
//	        < u =="0.000000000000000001" ; [ 000034979709986.000000000000000000 ; 000034985107197.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D07ECD36D087097F >									
//	    < PI_YU_ROMA ; Line_3539 ; J6uK041bNEX3eJvYTYIePKdfq90Ql3D80chI0wPZ6By4Fy9Sy ; 20171122 ; subDT >									
//	        < 99nDJi8k5kyh6RQbl16i643U9fXk86SoZYJZG7OIX9E9m08tBfHL08Kthi1zKiAz >									
//	        < F1MpAqOL5N7Q0KwVu5m7ZtpGcfIQ42x583vs8yN0a9VTuSlBQb6zN4rQuv7R7249 >									
//	        < u =="0.000000000000000001" ; [ 000034985107197.000000000000000000 ; 000034990871254.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D087097FD08FD515 >									
//	    < PI_YU_ROMA ; Line_3540 ; T089BOEt017j73G3O7qDVvpMzUWYm6QiwbtZeF4Fd8QY388hD ; 20171122 ; subDT >									
//	        < R58b5O8m7nHt4vzGK140Ao84S471D6XNcS2wLiH7vDN6zjTUg583f63jsyGdNhF5 >									
//	        < t3146zqE98rlV3W7e121p0EI6Cs6GOvabs8G7LNCYIrIMyz6V3A0QcPCv1h7231R >									
//	        < u =="0.000000000000000001" ; [ 000034990871254.000000000000000000 ; 000035001870373.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D08FD515D0A09D9D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3541 à 3550									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3541 ; fwEh5zd717F0om0tumOLO50lXxV3zR1T67uwvweJx9QMA2iLS ; 20171122 ; subDT >									
//	        < Y3sczhtE07OYQITelW53yQpCOGx97l073295935Yp5pPvmy4WY383ZGoA7xuoYTl >									
//	        < dfD981Zj3Rz24S7uw62gYFzZ1MN3pWr19gHVw66Om76pb4vvw6186C6f06J0079L >									
//	        < u =="0.000000000000000001" ; [ 000035001870373.000000000000000000 ; 000035007777276.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0A09D9DD0A9A0FF >									
//	    < PI_YU_ROMA ; Line_3542 ; kTxr4d6UW2AM3dS3T50Ou3Tdx13Bkbv0P3Eb96GwwM7XE15PE ; 20171122 ; subDT >									
//	        < 0u0bMZTtuHou70BkvpBsmdTHEP4QzQrRrfOokV8Px5DNsJf34jzi1J1VU37GnWXK >									
//	        < d1h8L7oErwp50AdqdA2VDKk94mo5O48Cwg1ya5UCjBb6iCuR8921i6rt0X6OIRhT >									
//	        < u =="0.000000000000000001" ; [ 000035007777276.000000000000000000 ; 000035018451518.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0A9A0FFD0B9EA9F >									
//	    < PI_YU_ROMA ; Line_3543 ; 300USTK04vMMvahoDT10yhkWPcP266zgPx7hoK1rP6mGwjy9Y ; 20171122 ; subDT >									
//	        < grPd2rUVX7vRV7pniZH3CIezD65Rec8iF8F9bjBB9dQmjMeop9VVSs58TQGlvA1f >									
//	        < 0JjuXEgJ53q6zdTykfbfSZ03B69fNI243S12WmqCSr3MuRQwFssoB497F730s44Z >									
//	        < u =="0.000000000000000001" ; [ 000035018451518.000000000000000000 ; 000035023911139.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0B9EA9FD0C23F49 >									
//	    < PI_YU_ROMA ; Line_3544 ; 3lrPR02C6fd5uI7J4201yE780EhR38TuI66spIX8xn08xX6Ns ; 20171122 ; subDT >									
//	        < FC816Sg0yUcvW49JGD2qbiz7Zd8Q1GCu7HK1XIsJWQ7CFg49B4A9W5gn2P5sHHEP >									
//	        < vG5NF44nx6m1qZ53sr5MScFx5C2bkgfd2vVXncR33JV7j7E19bRs7Ivt74jVJFFK >									
//	        < u =="0.000000000000000001" ; [ 000035023911139.000000000000000000 ; 000035038541502.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0C23F49D0D89246 >									
//	    < PI_YU_ROMA ; Line_3545 ; UGE0Z9v1HqunMnU5F9Y7Hu2g635fy18Mw808Qtb77F1LWEdu0 ; 20171122 ; subDT >									
//	        < cBecuv1S0KfX8wVEZ99dF7ZCyLk8321mFQjPX9HK7JfJcoeN3Djoh7pNG0Yhxz2x >									
//	        < HZayj05dcbrw6ydv5V0XnX4r1KuSI5Aj576DdnrvU5sc9pF7K733nlt5iYY4R4Z2 >									
//	        < u =="0.000000000000000001" ; [ 000035038541502.000000000000000000 ; 000035045712519.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0D89246D0E38373 >									
//	    < PI_YU_ROMA ; Line_3546 ; a0dv1O8wmlYCCt7uqO00uNf0bmfgl2PcQR7RsvOaaN9kxy938 ; 20171122 ; subDT >									
//	        < Lc7K9wQgYvH97Jju9c02gE17W2D36tIDDh6lfW38a74W4vbG4MJm22eP1pju3opu >									
//	        < I6YG0KpSu1q1n8HI206A2b2NVdkJgHOY3KbPk1D955LWL447e235AdV4WXKlRnHQ >									
//	        < u =="0.000000000000000001" ; [ 000035045712519.000000000000000000 ; 000035053158252.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0E38373D0EEDFF1 >									
//	    < PI_YU_ROMA ; Line_3547 ; mLnaaUeBof7s6kbNE47v28VOAoVOnF9Z1I5WOi53Qvgez11rd ; 20171122 ; subDT >									
//	        < hzm1uYyuAI1ku0c8Cq867NYPaPjp07bk5HIArxvwy08l6qngr6X5o4NS7q43sCQS >									
//	        < T1gSxb9KL4VeanCsl3MhF043FPx0Vn0aTzn9HSq5O3cdUoFPHwYdGw1LzYzpkXA4 >									
//	        < u =="0.000000000000000001" ; [ 000035053158252.000000000000000000 ; 000035061284549.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0EEDFF1D0FB4646 >									
//	    < PI_YU_ROMA ; Line_3548 ; Ot9xGq7df7V6tT57ajsQ74B709MqwV6y55offhf3rK7840iEf ; 20171122 ; subDT >									
//	        < 4s8HOX3HFQRSqzMgP03e90F6sWYP321034Fiv2A335W402A618KJrn416NH5C9bk >									
//	        < VUlA7I8H51bNG7TH61X83PjUp1wOs06a0SeN8ruhaUAC7z0Le3RQk4R3H59GUpUV >									
//	        < u =="0.000000000000000001" ; [ 000035061284549.000000000000000000 ; 000035071722087.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D0FB4646D10B3370 >									
//	    < PI_YU_ROMA ; Line_3549 ; jJ90oXyhzZnX1GD2cX7rhyc3d0j7r5zjm9G849Itg7n9179wG ; 20171122 ; subDT >									
//	        < 1ZvuKrR0VpFiCdstwznu9N3rF74z9A8lft5xxh6JvM68IF4XM8Mp8p4RHI6v47R5 >									
//	        < WKB494Uh7b5cjJPzMJ115bvGqS5DrL1MxyATGuqzqyPFcM4TFgvCF5g6KFGVG3tL >									
//	        < u =="0.000000000000000001" ; [ 000035071722087.000000000000000000 ; 000035085760074.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D10B3370D1209F07 >									
//	    < PI_YU_ROMA ; Line_3550 ; x8dKagrBQbXWZ26uzBqKsJn348icrdkY4l7P2p708Yu06s5a4 ; 20171122 ; subDT >									
//	        < TFkK4wkN1Eu2r0foO8S56Oz4iorLdFB5KJMK15AikHq60062mFZ4O6V5r7G6175x >									
//	        < 9jIjg2pPS20P92v87s2AOL3OifIDvWYemAP6ZJULvZ7V5787721g1Ee2JRr58lRP >									
//	        < u =="0.000000000000000001" ; [ 000035085760074.000000000000000000 ; 000035094951258.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1209F07D12EA555 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3551 à 3560									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3551 ; K6jbC79T6iomHIT8BY3q1k0NnR50IwhqsY95YwEnpga9bcPb3 ; 20171122 ; subDT >									
//	        < Af586cNe5iBlu76W3iDQjHnci4Jlx3Ck2991T8R4Y37mp4PXzZmd5Lt94UiSK5Od >									
//	        < 89sPfUIjUgD0t52vxv0U8xw23gL2x7az0X7S6499KWounTu45S5d8702yu3I5q3z >									
//	        < u =="0.000000000000000001" ; [ 000035094951258.000000000000000000 ; 000035101663268.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D12EA555D138E336 >									
//	    < PI_YU_ROMA ; Line_3552 ; eJegk50VzdNpdtNgIR40fZWPOaz30Q19s92NX174WUydVFZf7 ; 20171122 ; subDT >									
//	        < w6q30vt6mJU6h9t2Pm58VOfqpOyUeXNk068627f93XMh93Ik4p797L5yJe1IHk3f >									
//	        < DcLI35NNf83QP7NMSQUkGe888UMldUZvT19UV8fti964kXCJf61UrEXuI5710TY4 >									
//	        < u =="0.000000000000000001" ; [ 000035101663268.000000000000000000 ; 000035111598892.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D138E336D1480C51 >									
//	    < PI_YU_ROMA ; Line_3553 ; 67G3V2mh1Ju7VSmQ75K83a0huAGbCz0SY4oCiK0ldS5ov721W ; 20171122 ; subDT >									
//	        < g355OGouB58W3Cl129nn87m617XU3Sf50dn951jcQxkX4FHQtGUyP1R58u0A5H13 >									
//	        < r4m0g25Kko25ol6h51ZXOc04vL9WcQM509d8B56mQf0Ha2JN2jHJ03D06J02o4HQ >									
//	        < u =="0.000000000000000001" ; [ 000035111598892.000000000000000000 ; 000035123213084.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1480C51D159C51C >									
//	    < PI_YU_ROMA ; Line_3554 ; I4vr6QPC6OvvzvaX7j2u498798X2676nE3tL88yJkuuZDXJ7h ; 20171122 ; subDT >									
//	        < 2L55lpsT5pDbY2I0E0Ew89fgjO2a6gG8cS9s2UVKgBN2BWdzufNf8E3AdwntDjl5 >									
//	        < 1prTw8tExkxc0NXC010Iv6zdfuFWO8YHftUVLc8Uz8azI65OEt593Ot4dU4Ln9A4 >									
//	        < u =="0.000000000000000001" ; [ 000035123213084.000000000000000000 ; 000035137298978.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D159C51CD16F4369 >									
//	    < PI_YU_ROMA ; Line_3555 ; xty9uJjXSKG36A89j81Y63X0g5830hA1Ttn1y72G0BJg3911O ; 20171122 ; subDT >									
//	        < mV3XS3nr45EUCS4hs5TZiMR2PB059MDYVtw7yTkbtONLSlsXH0RbHRK77ro889FD >									
//	        < dB5BIDCIvkr9FEqo1B8VllxiAcRN8HsGnMx3KBb1m6S4pUlKnKQU5Fdp67b06rxj >									
//	        < u =="0.000000000000000001" ; [ 000035137298978.000000000000000000 ; 000035144556225.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D16F4369D17A5646 >									
//	    < PI_YU_ROMA ; Line_3556 ; Ir5nIK5c5q0wDTvGso9Y6w67R4lUDhXmVk4Mb915NRm3rIouE ; 20171122 ; subDT >									
//	        < cXx824OreJT0u52t8KkI3F4g3v600Ai5HyRcc0RTxidnLTL31kSqssja76TDTP1m >									
//	        < 8t8RlenS5746iPF3H06Ut1jsiplK72I04K6NYdK9mcrqzin1fLa8wJlTmY1i5bDD >									
//	        < u =="0.000000000000000001" ; [ 000035144556225.000000000000000000 ; 000035154409927.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D17A5646D1895F60 >									
//	    < PI_YU_ROMA ; Line_3557 ; 1qYEAaiNHb9E6Q9t34D88v2T4NoLBe4uTM72i1WZarf80kZsd ; 20171122 ; subDT >									
//	        < 9TlcOa40B1E2P80vL3XB44hweW80rb2K545hAxR4nS62a1s48uy0miYHEo9e2WKV >									
//	        < 2YbXFvyKS5tlEL2fPe3Z8iNzqB9Ny6w9DXg6kUI1KT953riBIWCnk65UPY0kv6OH >									
//	        < u =="0.000000000000000001" ; [ 000035154409927.000000000000000000 ; 000035163561126.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1895F60D1975610 >									
//	    < PI_YU_ROMA ; Line_3558 ; h66zv2qKF3OJdV7GDe4aKw62k5dP47AK7yPaMo8tSIR3Kq96o ; 20171122 ; subDT >									
//	        < 4vbUpZ9WdEAbx7WTPfva2T3d6KcPGSXmMBnCO61OXtSh2K0SG4wWW5687O388D28 >									
//	        < 7F3w6Fw17tbFPr895nbXnEtiILUjkvhs203I9gcWx72YXCzsb6H17TX4719T9t56 >									
//	        < u =="0.000000000000000001" ; [ 000035163561126.000000000000000000 ; 000035172903957.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1975610D1A5979B >									
//	    < PI_YU_ROMA ; Line_3559 ; ExJS0y0jhkh9iOoPI5xM48PA892Eqy7OMNUyw8Krk09SqOn2t ; 20171122 ; subDT >									
//	        < HrsbzbmS79Ke13eyllAVY4nZur2e03bGn9PBW9H6nVz1W599P79ekM4LPQ3yZnL1 >									
//	        < QpgS0Cu573uamSDUIv7aRYLZYsNc9aVlghZNi12e99o5Z5EL8yyjzu1vUdHn5eqh >									
//	        < u =="0.000000000000000001" ; [ 000035172903957.000000000000000000 ; 000035183634778.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1A5979BD1B5F755 >									
//	    < PI_YU_ROMA ; Line_3560 ; MZ9cufxEOBX4lBAi4J39q1s77FH6tq7O3y04s0r6rmx244xbP ; 20171122 ; subDT >									
//	        < i7S3rh7Ea8JcfkiJ5m250wy2Fh9Y4g869VPCjdeB3YHZUH52032pa70fmkp4LT1B >									
//	        < Mkf3YVw6gANbX3Y2cy962AoiHWe4b9I9I3ANA1eD8C1136cN11leeRWcJ3Yov4sM >									
//	        < u =="0.000000000000000001" ; [ 000035183634778.000000000000000000 ; 000035195826737.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1B5F755D1C891D1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3561 à 3570									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3561 ; A61J13T8yz9jCcvFk66Z2Jl176Spf7p86CZSaa3XlCyOks1mq ; 20171122 ; subDT >									
//	        < A0X4A097XTLXZe4HR6CRY4NT93sF08Vlq63c3K06ym4qedTY4yOD28B4F3p4fAxR >									
//	        < j4SXBqmOcuqgp4i9eug3g17y9reQ86V6ND2XzSryP2k2uR5TXXdj2J1vY7b2Mcwu >									
//	        < u =="0.000000000000000001" ; [ 000035195826737.000000000000000000 ; 000035204111939.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1C891D1D1D53639 >									
//	    < PI_YU_ROMA ; Line_3562 ; XLYwuzEwK54fNLAD4HqlfR8cuiP8tYhs5P7tUv18lCsE98AQY ; 20171122 ; subDT >									
//	        < FJUt9KCFSy4PuOi50X9eFLss7oyG2sJC95AGGV7v0degozJG09i4m0l3ck85UvA5 >									
//	        < G6llc1VGY73U6PF21qJ23M85D91a9XS1TGMpphsm5Jpm3vIfGbMff6uxif3E0p8T >									
//	        < u =="0.000000000000000001" ; [ 000035204111939.000000000000000000 ; 000035213880376.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1D53639D1E41E05 >									
//	    < PI_YU_ROMA ; Line_3563 ; 72906MOhWfagxDaJaWO9pBD38hAPIiH12ilHhV5a47iuyArBa ; 20171122 ; subDT >									
//	        < 18O6PS24XHnW4y47ER9V8wE9tyav5Q83nn461whKp773hadI129a7Md5vlP8niNH >									
//	        < 75KOmM6OW4P2Grad19Bs8P1nFARDP314Uiq56Z5j6JCL6UxpNBlkHx5u9154jJXf >									
//	        < u =="0.000000000000000001" ; [ 000035213880376.000000000000000000 ; 000035227512511.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1E41E05D1F8EB13 >									
//	    < PI_YU_ROMA ; Line_3564 ; o6Myzd2044qEC75H97yUvcUk1M5k8Vkp64D8iql07bYRt23F5 ; 20171122 ; subDT >									
//	        < 7HSqx2sIGCz4lxO4FDqk8fs6qirXdSGK4Q10iVgl7b0r1Dh3S6tJDg4jq182SZ0T >									
//	        < 896s2f49KZvOguIn7oGkQkKf40w0hkI6GgcS4fvs0o2tNiyUk103AC207B4UftDd >									
//	        < u =="0.000000000000000001" ; [ 000035227512511.000000000000000000 ; 000035233900439.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D1F8EB13D202AA5B >									
//	    < PI_YU_ROMA ; Line_3565 ; FRQ4sVb5nsJ1h3T6G3lJB10dA82J7G4002fp0aM54hT72pLs2 ; 20171122 ; subDT >									
//	        < ok5IGn0OPS3kUyE5n7mzNg5c92b6bnoj9u7Dr3XdLrEBPSO2OA9x41vc3Ao6T0nu >									
//	        < 23Nbg0D3D49zvl68YGe97g7HfkiV1jnpAELR59VpSEM5KOoz1QdqM7bc9EHRzff9 >									
//	        < u =="0.000000000000000001" ; [ 000035233900439.000000000000000000 ; 000035248538964.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D202AA5BD2190088 >									
//	    < PI_YU_ROMA ; Line_3566 ; J5bPHa7foTgFcwh20E8M2C2i35KKxmDEevxtjxZaS622IOW0r ; 20171122 ; subDT >									
//	        < UF57tKgmj2kf56I0a00sJ02TC80E6893FDo1wh6r65a6CCAxNtnz9AWPeLAHbOP0 >									
//	        < M0k5Y8ef8VB5z082h3M5z0NS0C9KZuN2Du840Z1kT4X0Xto7161bK0V355Os41DO >									
//	        < u =="0.000000000000000001" ; [ 000035248538964.000000000000000000 ; 000035258727862.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2190088D2288C92 >									
//	    < PI_YU_ROMA ; Line_3567 ; y8CiZ7g18X7BYhi90TldFUJO1jI7f9TJpA495FL3qQ44sh424 ; 20171122 ; subDT >									
//	        < G6q86tb32uG5dzslKxYRo9x33c62FuTc01Hsd74ZUVH6h9YDV7loN12096jvl0zD >									
//	        < 48E58D5QRl868Np44G3e3VqiwjC6SApvgh18yy3Ex4RRN0UFkmk0hWyyJiquPTR3 >									
//	        < u =="0.000000000000000001" ; [ 000035258727862.000000000000000000 ; 000035268636301.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2288C92D237AB0E >									
//	    < PI_YU_ROMA ; Line_3568 ; G99lKWsh9l00GLx334p5820Il1Y92Z0qE0PcmDPk2F6pBCRxJ ; 20171122 ; subDT >									
//	        < bHo711bdF34s232y8tE9T35vdM4g4Olx9eMsfy9zYrtd432zSpEc4CX8hA0sJcx0 >									
//	        < 9TudigYA91S1frdp61iMJj13NH1D3x3Fu72NQ5IvRBf0118BMtw6QXQ9b7mKfPsq >									
//	        < u =="0.000000000000000001" ; [ 000035268636301.000000000000000000 ; 000035279349411.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D237AB0ED24803DD >									
//	    < PI_YU_ROMA ; Line_3569 ; D7tB5L3hwwL804UQwc9gnmFBPPAoP8ahaAg6lBBszvrYlqET1 ; 20171122 ; subDT >									
//	        < 3b7353T3EuWkFVdOXxZA6vxv7NYXSy66759n4hG9ByoiE9Jl6ZS9C15cbbJe8xT0 >									
//	        < t5bT0g0ahdS8dEV1uWD9jNqzNX49JVbHoIqE608R9S0deckV01P9hOQ7CK9s4Y28 >									
//	        < u =="0.000000000000000001" ; [ 000035279349411.000000000000000000 ; 000035289931765.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D24803DDD2582998 >									
//	    < PI_YU_ROMA ; Line_3570 ; pNmaFCo5x27EK7cTan3m1nOSde39r4ANzW8t3AajY1GmBT8Qr ; 20171122 ; subDT >									
//	        < 51dzf9k9npZZub51I82y8Z1E3FZQCsmAKz9vU31mcvAx3DBYC9tEs32Vr35qNX0t >									
//	        < lX1Jy8O11rngS9Yo64bkT1xXVk986NP3rh7w3Ptr9wh0XGuMN02He3D1vhYZdudD >									
//	        < u =="0.000000000000000001" ; [ 000035289931765.000000000000000000 ; 000035303454439.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2582998D26CCBE3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3571 à 3580									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3571 ; Vh7N4BA8c6H4o424K8424S0WJugSt4M754oMFHP8o4NfZX4m5 ; 20171122 ; subDT >									
//	        < 9Ndn0pG483R8Sfm98KhEN3Le1JOe61F94jxf0yLLsOF2CM4aw34S1dUct9sCIWg0 >									
//	        < Fe9SDXrDsrA0j7u4uHXdI8QWT8s8bEFw1g1E387Tse1Rb5LePfiQhxb7R2764JWE >									
//	        < u =="0.000000000000000001" ; [ 000035303454439.000000000000000000 ; 000035314065934.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D26CCBE3D27CFD01 >									
//	    < PI_YU_ROMA ; Line_3572 ; XU6VfcA9IHba5v76872IPc3C1u2HgFZl4YI94QNKCw9VBXjn7 ; 20171122 ; subDT >									
//	        < A39d9592xnrF6ptFHDHF3t5Qmj55432CpJa8i6Df0xw88xDwH6U4SSydvSu6IswW >									
//	        < N0R2R6ue9C8BClo7H4b0g7L6V3L0Y9WYI4rCBLtpQTTac46A2Xud1IT2c67S32F3 >									
//	        < u =="0.000000000000000001" ; [ 000035314065934.000000000000000000 ; 000035321353422.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D27CFD01D2881BAE >									
//	    < PI_YU_ROMA ; Line_3573 ; KN7omz4Vzfb4G18sDRL7WpZD9LJvV0mJ279FSWwl86DCk412A ; 20171122 ; subDT >									
//	        < BhlM2Cl9bXAdX7Qsb8DL70cCA6T1AuJ3YyhNfldGK04dMj0oGFb5S7sH9A93A26a >									
//	        < FA2j20FL6nIDBYaENpkaG419m6FRll812wG4lmPyn36m4b7w6J428Y4e369BMnj0 >									
//	        < u =="0.000000000000000001" ; [ 000035321353422.000000000000000000 ; 000035330344101.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2881BAED295D3AA >									
//	    < PI_YU_ROMA ; Line_3574 ; o7UcFVHi8QpQ9V87a6RGOiF8oPqpS393cZ189tpw1ZuPx6hDJ ; 20171122 ; subDT >									
//	        < 9I5bmBTp2R8v510U844hQz8S2DstmOTXoPxQtQfUl6R6Fjl4I3OPSg3FQ3P82t96 >									
//	        < THS3tae0Xi7fNhMuo1LQe4420C6IOdGs6z8Y19aCal99StSFvSCRJx1ZYcN633OD >									
//	        < u =="0.000000000000000001" ; [ 000035330344101.000000000000000000 ; 000035342996342.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D295D3AAD2A921F2 >									
//	    < PI_YU_ROMA ; Line_3575 ; QEdEKqAZG76EmCGoBm3FeKFGJ3lGa5MeNH929Kd7PX2JsQk8W ; 20171122 ; subDT >									
//	        < ShE343bF0m1lbbM2RirO94Jt72cIjien0dKvi9wWFkH32b8e8CQAFbL6kdLv33id >									
//	        < iy4Z0vzbIF7B4f4z1xnP7K580yVAtBNG1o13KK21fbFg5l3LLSeQDAN9M7ZtVH3l >									
//	        < u =="0.000000000000000001" ; [ 000035342996342.000000000000000000 ; 000035350638113.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2A921F2D2B4CB03 >									
//	    < PI_YU_ROMA ; Line_3576 ; e795o70YH03a2WDS4ilL6AdQ0w1Q76n5R1735m8VUYuGNzTl8 ; 20171122 ; subDT >									
//	        < ejtPkWrGqlmcmy3j4cRblo47iH7TJzZrNBqF77w4o09M608w5sn8W2vbZ1rx2Ljq >									
//	        < 0Un8V6S2y55232X43p4172LIpG89zrr6XWO1w8Wkw78LK01mArUPNqOaq7RO5tWk >									
//	        < u =="0.000000000000000001" ; [ 000035350638113.000000000000000000 ; 000035357882457.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2B4CB03D2BFD8D5 >									
//	    < PI_YU_ROMA ; Line_3577 ; APL96s8ub82OPLG2ybUoUc7BmAQh1l54nqbqxtIC3sXfF3DcG ; 20171122 ; subDT >									
//	        < P01IA6VBw1iiwRy60Yz0EZCyS20fsPHloSfIwkz90kusrz40rJ6ap1zWE31C8qMe >									
//	        < vM8nMHK891Jz9028n515Nx1FJmGBJrJ40ck84dKs9HyoMy80XVPq3X3C7D6VXaVQ >									
//	        < u =="0.000000000000000001" ; [ 000035357882457.000000000000000000 ; 000035371101743.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2BFD8D5D2D4049E >									
//	    < PI_YU_ROMA ; Line_3578 ; fXiX3vH9AkyQO1lz26IzaWUHojUlckv5S2Yy9kmcemASpAuv1 ; 20171122 ; subDT >									
//	        < PPYAV7gQTb8E1iUZ4ZOrz4N44971Wad61iAfquZfIn3A3C9cup61FNcd0770NJp7 >									
//	        < lx9u1y6AKV25603STV73ubFE0MUu9N64Ct9G06xbb4EJ9RaNJBaD69201kC8vqsB >									
//	        < u =="0.000000000000000001" ; [ 000035371101743.000000000000000000 ; 000035382568089.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2D4049ED2E583A8 >									
//	    < PI_YU_ROMA ; Line_3579 ; 96nEqx21Wm0c42aZh0hQAkuU9A7npcoV9MUG57LGuMw2w67Wx ; 20171122 ; subDT >									
//	        < DfOT9XBThvdRoO89Z2Cj3vmr75oP06hQ90ZU0Y17S1EIGcu6D9oGiQIexodsn7Yy >									
//	        < 4fHOz11c3mUq4v36RKip4qCaog7P60Pzt4U4L66L6vHv43VJAx6933aUB572o1v7 >									
//	        < u =="0.000000000000000001" ; [ 000035382568089.000000000000000000 ; 000035392414584.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2E583A8D2F489F2 >									
//	    < PI_YU_ROMA ; Line_3580 ; SW5g9JSen0N59PtU6BH17Wo14p4d8QSHGfD990196ZOD9vjX1 ; 20171122 ; subDT >									
//	        < lVv7w3W4BgdffaB6LOCRJpE5x0nKdYo0Y3m5yqtxS7nGG4dlhKV9I3uTs3kiZdka >									
//	        < ed29Q584EF266WKa2dXnm8ReOcdFCA3z1ws5Xl37g16454F93loXWhV0VNDEsWcc >									
//	        < u =="0.000000000000000001" ; [ 000035392414584.000000000000000000 ; 000035397669420.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2F489F2D2FC8E9E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3581 à 3590									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3581 ; AHr23S4Li9Qp39flE8ah3wBaqinKD20Yr9CIZa4qMbx3wD2br ; 20171122 ; subDT >									
//	        < to3Qzw18cJ3kDteJU0p2fDs5FSh2iX5o04Mo4DhRdGxMT4Cu46rUcUySw7AaDD2c >									
//	        < N7UW422iL9z4mf0gegU2Yx5MM0Rx2pD4p33PX1WS6HJ5TBoY41019S4nW54eFr5s >									
//	        < u =="0.000000000000000001" ; [ 000035397669420.000000000000000000 ; 000035408749860.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D2FC8E9ED30D76EA >									
//	    < PI_YU_ROMA ; Line_3582 ; lz4Ey14zISi4A1oaNuQx1Nw295GDI107r5x17rWXvTjg6X70y ; 20171122 ; subDT >									
//	        < 0dR5PR6c4Ks9wC489o8Q1nkINosi1K627if2v9TAUuc5i934W8gtSRDL5Lf4Q7ux >									
//	        < 19rDP0171MuRG7IX5lriE20AiH30qFA7sUQH1L0pG5qBZW9j1Go2PQ2W8Lq355A9 >									
//	        < u =="0.000000000000000001" ; [ 000035408749860.000000000000000000 ; 000035419225952.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D30D76EAD31D7323 >									
//	    < PI_YU_ROMA ; Line_3583 ; 32r96d0Vuk2Mu598oJAtveVPf3lM0esLsaYn0oCF58r63R4A3 ; 20171122 ; subDT >									
//	        < xi1i6OOQxJA92w4i66GtXHCN0jI4ntu433zfL27l6P05zZhH3NhTIhFa3iL5803Y >									
//	        < 9DQm8EwK8w9HJJc56b3l01B40678BZgDSr0si43TkweCL3n63510mkp67Gvmn73E >									
//	        < u =="0.000000000000000001" ; [ 000035419225952.000000000000000000 ; 000035426168915.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D31D7323D3280B3B >									
//	    < PI_YU_ROMA ; Line_3584 ; o8Ud7ZE3m61WpOyaN552dsKGUO47eTrhyf68i1Q1E39FN8bj7 ; 20171122 ; subDT >									
//	        < cP77P3CR5Ni3gSXUPfhM4HEUS53SPN9V0n0hv8bGbZIz68MQb69WnYM3FtVtqtf7 >									
//	        < 7zJCENF3aS4kaBsTSkgfSaiAWB0HyjunXghumlc8cK5lTF2x5F6tQG1uusWtdeu3 >									
//	        < u =="0.000000000000000001" ; [ 000035426168915.000000000000000000 ; 000035440521637.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3280B3BD33DF1C3 >									
//	    < PI_YU_ROMA ; Line_3585 ; rPH5i1wOwdu2dQD89uYYkg7Ko9988i0851vjXN80P2C7acw1R ; 20171122 ; subDT >									
//	        < Zbs9xtsdO662Mm5wDQ5QROJ9El764WMxPgVtR4cU31BmpOBCqPBcQhyle96N1fI2 >									
//	        < Q5SEOtKCW3yPv4xVYI0Q74rD45jq0875JgRGd74e682i7BhPa8GimW9718m8oGLy >									
//	        < u =="0.000000000000000001" ; [ 000035440521637.000000000000000000 ; 000035447453172.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D33DF1C3D3488565 >									
//	    < PI_YU_ROMA ; Line_3586 ; fuuY5fhm94vvftu632gRFn819FqC6349Q6dcpds4vTV19A739 ; 20171122 ; subDT >									
//	        < 7A7K798K20Dha880905W3dRi3u8JBI8Ev96dilb0geH223cY6CDg9k3i58uFphFf >									
//	        < z8So70gp7Bjej6L2q4oLKeFU2i91ehSUTl2J30O7Ew5zpc50X6y39o3oPsP8iW6j >									
//	        < u =="0.000000000000000001" ; [ 000035447453172.000000000000000000 ; 000035453834428.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3488565D3524212 >									
//	    < PI_YU_ROMA ; Line_3587 ; G91GYpD78RZT5OE9qIPi1X29l1VwcKj7x7LKTC852z4hUif3m ; 20171122 ; subDT >									
//	        < cc59510dz42FN4hlPwqo6YPa34n83UYqyBEF2I7y427iPx2wRoa86u9ZlI278z77 >									
//	        < 71YEXny92iCsh4J5n2JWaX2E4kI6G1Qc4T4zsd9NF5Lu0oksgsA982fwUlL83yy6 >									
//	        < u =="0.000000000000000001" ; [ 000035453834428.000000000000000000 ; 000035460438799.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3524212D35C55E7 >									
//	    < PI_YU_ROMA ; Line_3588 ; akb3XC60959dxGj2V1yciUWi8wX8rD15Mqbys4mrUI0Ll38B0 ; 20171122 ; subDT >									
//	        < E59zs1XSago23x63T0og1YZvFgt956E5dk8HgB3J85t1xJWLV5c9TYv7V7723V7G >									
//	        < x50L229XZ78lsvZNldSWWP7w5JVBEGtp4k1mW9w4bSB0euB8wlbEnvk9XlwbdXJP >									
//	        < u =="0.000000000000000001" ; [ 000035460438799.000000000000000000 ; 000035468747742.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D35C55E7D3690396 >									
//	    < PI_YU_ROMA ; Line_3589 ; 78VtYWphjI03l46ktm71mZ59KzA2uWj9sG5qLO7dr9LQPAdC5 ; 20171122 ; subDT >									
//	        < GcnWq040B1A9XlVJT5sQ6BcybbmkXm5x91q1Ler6S4Lfg2m9TpwgdHW3ghtcS1YA >									
//	        < 9m535eh16daRzC4SC800S0fg312mp0mQgX24zKR85gE94TI9v1puDLH5h0O4RbaY >									
//	        < u =="0.000000000000000001" ; [ 000035468747742.000000000000000000 ; 000035482936308.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3690396D37EA9FE >									
//	    < PI_YU_ROMA ; Line_3590 ; vaY16D1002mK63CBHk22tFyRylNNVvSUb0uxf0jD8jx7bbti3 ; 20171122 ; subDT >									
//	        < HpQf5p8hEm14IHyvs9uiHf7k4FlLhbg7LiR8QADg56c4jR2815e8V2TLDssa1u24 >									
//	        < n0NwAM7GJEt82YV18UWm6j7Bvk60gH7k94e61o9UB7JKNRDmOlB9dhj6n9YP5yt8 >									
//	        < u =="0.000000000000000001" ; [ 000035482936308.000000000000000000 ; 000035494921368.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D37EA9FED390F3A8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3591 à 3600									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3591 ; 5i20L5xsaqg8S4pXiUTZqzf34SvgYdM3n456w54e45xmHN7n4 ; 20171122 ; subDT >									
//	        < 5PRhP196L3Q1Wr43xo3373npG55o7DYCtTaQ4xbn61Fg4nerZQakmdT6721VSV5l >									
//	        < gTmvgK94yu1ViL7ABAx5a6n72G3l2r462VY74n8r3c4H82m2mrmLaXc813OXYeNe >									
//	        < u =="0.000000000000000001" ; [ 000035494921368.000000000000000000 ; 000035504617011.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D390F3A8D39FBF05 >									
//	    < PI_YU_ROMA ; Line_3592 ; JG93833Ge7Riahd2D872303gGa74O0r6ha4cG56Er4kNdRMMG ; 20171122 ; subDT >									
//	        < aDUVVF7WnyUCknHKt2YaH4IvQy6p3K2xh5pN06QHejf9W44Wb2Jigp3ATU5S3gJn >									
//	        < yq860SfZ79EjyF2L86RCv6aF133KEG8Q50m7e9hzdN1k8UU0mAkNKYNXmaclf6f8 >									
//	        < u =="0.000000000000000001" ; [ 000035504617011.000000000000000000 ; 000035514088586.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D39FBF05D3AE32DA >									
//	    < PI_YU_ROMA ; Line_3593 ; 3Z9296nHMl9HFI327xtR99IURlkWLXpfoU7s7BfHbq5pWE5SE ; 20171122 ; subDT >									
//	        < wfz81da45D07ADQ3l5uWJ6pJ18JU7vaoe1C3g4HrzjrsgFNk0BWWm0vyJ25MjOIY >									
//	        < ExE665497Y9lfzemrWl8sKHFIxO4Tj4fj6nEIftKkOu5Iw8r0UpkyX2Ll17Hdc4q >									
//	        < u =="0.000000000000000001" ; [ 000035514088586.000000000000000000 ; 000035526437501.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3AE32DAD3C10AA6 >									
//	    < PI_YU_ROMA ; Line_3594 ; 8Vj72UeU0cQ6h9EuBP7H3rfEK72256nzz0J8MZVf35176w9Q9 ; 20171122 ; subDT >									
//	        < byW93dSQ6qktirJx8v1WVqd7P625M2D4pSCUm0wwsz13vF5e5AHMIdKRWSqMIOag >									
//	        < X3gx1Us3gXbX863FU948zC2VFps0aMp4WiGcd6Vf24SOR9iqxwWEHiC6495n7jM4 >									
//	        < u =="0.000000000000000001" ; [ 000035526437501.000000000000000000 ; 000035531559882.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3C10AA6D3C8DB94 >									
//	    < PI_YU_ROMA ; Line_3595 ; E1Z4v3i24Mov8znNlFZ0n0CI5af5N8fZW3Wcn88R6D67Z9b8h ; 20171122 ; subDT >									
//	        < OxND3kiJB0G74VVPn68c2VZh1R6Xxmf4b9S2E3617c9WFm1NER8P6P8C0qvj1IEh >									
//	        < ZjGDUF17H6O3lZv1m8540LLln8tx0stJAv25OklP384x7Uu142BKJQi91590WACu >									
//	        < u =="0.000000000000000001" ; [ 000035531559882.000000000000000000 ; 000035540336352.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3C8DB94D3D63FE3 >									
//	    < PI_YU_ROMA ; Line_3596 ; p7hF77J9JWupBDDG7vdrUb07NeI545CrRq5AaMNKyyRt8JLU9 ; 20171122 ; subDT >									
//	        < 7V92a9geJ0rZ8W1r5ConU81ST9C23s0h1Z34nQcHa9P6NP61Rs23nzqnAZ84jgzS >									
//	        < s1976uZ4SKmeq47W0nmklyXOs4OuIJ1w3yI9liNk8fbLvZDfgT4kEt2yH68cR8m2 >									
//	        < u =="0.000000000000000001" ; [ 000035540336352.000000000000000000 ; 000035545413394.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3D63FE3D3DDFF1B >									
//	    < PI_YU_ROMA ; Line_3597 ; T0Qko0HUK89qFFhVnSAZ85nbF2T20FOTHl0x2NZf6Z9akXcgA ; 20171122 ; subDT >									
//	        < 6a9PkM63EUi37Z51u4lohg9Bc6DEa8jmj9f24ht8yWjN8h3NP7A75Kz8GDTJ9Z82 >									
//	        < 4nBzbZ7ca5GV8Vs37oxsxSq3W689u0WE3hKZDX9g8m3NVNCS0bvTlLJ0Flz7K7z9 >									
//	        < u =="0.000000000000000001" ; [ 000035545413394.000000000000000000 ; 000035559397876.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3DDFF1BD3F355CB >									
//	    < PI_YU_ROMA ; Line_3598 ; qSdq77L7Jd4Ew5OiA6fjP262PzTcN80xI335TGXfvOM2xRX71 ; 20171122 ; subDT >									
//	        < pj4j7P184D0ar7r2yTLFf7783iHtk41F68NTcC0Vj3clrV3fMy1x36wgznabZOU5 >									
//	        < ZTqf5ZAsPl892kP95si9ubTc5NZqwE3W9LD1SplC4k366qu06BBUfj0WtjrYbn2M >									
//	        < u =="0.000000000000000001" ; [ 000035559397876.000000000000000000 ; 000035571440884.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D3F355CBD405B618 >									
//	    < PI_YU_ROMA ; Line_3599 ; m9ps7JMEC3k9ZiRWFmgpCcZ3OseW1vh8leZ2aDXv58a2t0j06 ; 20171122 ; subDT >									
//	        < gmeVEfJ2j973Na08fAQG963xF4XzKVz992rk865i24OIGBkVE237Y6ZK6738S8W0 >									
//	        < retT3kJLW36CpWgyCHRXNh55Jr29CTWP486M4zK1bKrut5cSH62E3YvfB6C4RJtR >									
//	        < u =="0.000000000000000001" ; [ 000035571440884.000000000000000000 ; 000035585726182.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D405B618D41B824A >									
//	    < PI_YU_ROMA ; Line_3600 ; EL1XNrYi8Y440FYaM5Vn6LF9A98SWd0T6KrJD5ZU1SZ2ZioWO ; 20171122 ; subDT >									
//	        < 74S774H10zS0Au08W9cBm9d002L4832Jqdx7yM6PC6uiUA3tBrA47Ga4OEui9s8q >									
//	        < Thmj12TP40YIMRd15t2RE9R6IcPkKOt7IPrmeEXHktcFxWNep1902r4M7XL2saZE >									
//	        < u =="0.000000000000000001" ; [ 000035585726182.000000000000000000 ; 000035599304697.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D41B824AD4303A65 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3601 à 3610									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3601 ; 7uuIrwRt8Fwb5EHsY7eu8Y2mTn6DNsiD0myHKa68QOrDlQ055 ; 20171122 ; subDT >									
//	        < Y31yIf5npYL25154L9nOQt2wjrkmSW68X55Q33RPuE8zz9MRM84d897W38kA9p36 >									
//	        < d6E45Gwk71UVIJaP2fqD2W0GsV9uCJPytr1vLjOjqun96bFFstdx94NoY53K5aOW >									
//	        < u =="0.000000000000000001" ; [ 000035599304697.000000000000000000 ; 000035606180445.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4303A65D43AB83C >									
//	    < PI_YU_ROMA ; Line_3602 ; YrgO5db1n18UMNm6Br0S7wmtZ37P26owOz2fnn5uTOuYN4310 ; 20171122 ; subDT >									
//	        < O6Yoc4k4D8moixp6ZG5dFhUov6xhpa0LmKi11X5x9R9JGYJ65P8iZqoyxGJr6037 >									
//	        < n5Vb6HWI5bYnlG0ytzHwMdzQ5CO4DLaqe78wmM247pxCW2wCRY61gs4ty5eBnVzY >									
//	        < u =="0.000000000000000001" ; [ 000035606180445.000000000000000000 ; 000035612918809.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D43AB83CD4450068 >									
//	    < PI_YU_ROMA ; Line_3603 ; Fcq7loJMZ2lrBAxwD513wW6w12xQ1LhH5lpuP3tuTHcidd00n ; 20171122 ; subDT >									
//	        < O01mtptGTExZ9NHY5e6Hj9j2w26y6l0bzlR1r4GBXy3PSrFKAtyRP8pO42K20Byj >									
//	        < BU1Tnj6l1W3ITVQDBJ5rcac940BG5ig2iB10M9BMpO66w34e8L7g0nL4XF002MGD >									
//	        < u =="0.000000000000000001" ; [ 000035612918809.000000000000000000 ; 000035624073831.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4450068D45605D7 >									
//	    < PI_YU_ROMA ; Line_3604 ; 5hY05vJas461L00bhV5zC83o10s0V5gb03hj4sNZT0RIx7UKC ; 20171122 ; subDT >									
//	        < 04z7zX3RE2rJHRgKZf0U8Gw49L9fxigXQkpy9Kz40627FOZ7n23rFvKATASE12V3 >									
//	        < 69pu8q1ndqTe57djMnnUhZIZtoSbgGSmBeua6ngpZt421378ldkR0k1rULL67kqv >									
//	        < u =="0.000000000000000001" ; [ 000035624073831.000000000000000000 ; 000035638119425.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D45605D7D46B7466 >									
//	    < PI_YU_ROMA ; Line_3605 ; 4xZbApZ50sE3ROBG7oFA34FCP9c9jf387XnyymOh9lJfR87ql ; 20171122 ; subDT >									
//	        < HMFx2Vk1uU2Giji0aGI38LLPP7DZ96u3VXuRB43jK8z5XqV7VjBDu4zo53KyMLh7 >									
//	        < 2Tcf6X8V8EiewzI02AwjBm79c1o1KqSM9RDD8Nyr2F9R4O4FlLOVcHJ1Nznx261i >									
//	        < u =="0.000000000000000001" ; [ 000035638119425.000000000000000000 ; 000035652501914.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D46B7466D481668F >									
//	    < PI_YU_ROMA ; Line_3606 ; k5io2h2cls68Z36bX2GQe9MS3atB2F5xT5qXmxgP0g7wf5P08 ; 20171122 ; subDT >									
//	        < cfD5YO0gJQ548ce6753yFU355z2c81T3gh1fM879xuw36q3ik461dZ3b0GB6O7cj >									
//	        < 06OJ0ifCT33SrPEdD9E0w2VB3SPQ8iI4Ej930TTPiEp04g8KmgCvI57LtC9PR954 >									
//	        < u =="0.000000000000000001" ; [ 000035652501914.000000000000000000 ; 000035660630106.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D481668FD48DCDA2 >									
//	    < PI_YU_ROMA ; Line_3607 ; 069NeEot6IP7Ig1P6mx9S0VlZiyYjAvF3CLPgwonkhCjuXnXv ; 20171122 ; subDT >									
//	        < YSvh4v2I068C5sYuaahVhh0D72spIs6sYp3VZ3axG4lC3Gxvi036MlGwLndx0A8t >									
//	        < 358322C4T2fX3w25k4uEJAyNDAanS1C38XI973go94W2mpDXfUJYfE6Qs5k21OGs >									
//	        < u =="0.000000000000000001" ; [ 000035660630106.000000000000000000 ; 000035672547575.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D48DCDA2D49FFCE5 >									
//	    < PI_YU_ROMA ; Line_3608 ; J4wFwQDj7zKL5gknzZnZIY8Glm4D30v4jv67Kz6qS94z3sJ65 ; 20171122 ; subDT >									
//	        < VBBUEbZ2grR56IMDqfc2jZ3US21B8b48r8MOUDRKp69114VlfsNfVafUv4MUL9c9 >									
//	        < Y3015o8904N5g17N6N8794LBpFF9XCa29v0VUXIx7W003FS46FCsfMdJujE9v4fZ >									
//	        < u =="0.000000000000000001" ; [ 000035672547575.000000000000000000 ; 000035682539529.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D49FFCE5D4AF3C00 >									
//	    < PI_YU_ROMA ; Line_3609 ; Zp5WQKEv2IEXwoVSQ7m2s4D9RgZd361819wb4W05r7475ew60 ; 20171122 ; subDT >									
//	        < 88cl02No6lj93hEoNc1RG0zm9pRrJq2alGT6FCq40m85bCjRsDyQ570e29Q7VjYR >									
//	        < v7mFbbG8gC4RAAwKa83V96Zh6Tp6V70sl1O9SQD9Ex5hbq66mAwRr6a0QH209Hqf >									
//	        < u =="0.000000000000000001" ; [ 000035682539529.000000000000000000 ; 000035688819620.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4AF3C00D4B8D12A >									
//	    < PI_YU_ROMA ; Line_3610 ; 4t46uvCp3muoz97x8Z91H9rj559109lSM488xTv5Ning04SNo ; 20171122 ; subDT >									
//	        < 8lIARi9TLc4iGWs42d335xg299iMt9O2wCY8u31Zb7W82FVf4LoA3rY2tuUR22ts >									
//	        < 2S14E72KCM861O3lHrK3Ciu7yzP4Oj1J846Ra8GCl3qxbIDpKG57vR3251kzb1K8 >									
//	        < u =="0.000000000000000001" ; [ 000035688819620.000000000000000000 ; 000035699853893.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4B8D12AD4C9A76D >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3611 à 3620									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3611 ; 80d5GRXigiwJSl6A6mPK792H1CITkLsG874DX5xyQjNP1miX6 ; 20171122 ; subDT >									
//	        < 11i29YXO7GtpZe0Uc5kqEqSmQUZfkZfBUTUd6pQKt4p6yBnX6R1uTtkWZwR6r1wn >									
//	        < GMv7g2hV0GRaAb3k8ekVN5nZ8d3g1hELIJ1e0Lg4hACuSiPLIi94x6wAC2i1hSis >									
//	        < u =="0.000000000000000001" ; [ 000035699853893.000000000000000000 ; 000035706586795.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4C9A76DD4D3ED77 >									
//	    < PI_YU_ROMA ; Line_3612 ; i58D582Zs36dNDnZom03vr2k226B5Go03WMqhAc324e1ntyr1 ; 20171122 ; subDT >									
//	        < 9U2kEJfbSs0w8tgRs64Bm773XC5UqfE9xzVYJnCsX003eCx272HKrwjck5416C90 >									
//	        < 84Qmfg45CTd6cuKWP6hNIJi5h0c2gdg4K77v2N77u8g1ub2WEElLYvJ77U3M343a >									
//	        < u =="0.000000000000000001" ; [ 000035706586795.000000000000000000 ; 000035719841615.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4D3ED77D4E82721 >									
//	    < PI_YU_ROMA ; Line_3613 ; 2vrrK93PZyE5hht144ReVBI7qE4sRk6HhC5kpEfB9PUx0Chjv ; 20171122 ; subDT >									
//	        < T6mB7B0Jm7P78sJHB0xDhmHV45HrD6Qe4UU99xc8w876g1830cxCzIrinNCuYEAh >									
//	        < Ie0Cq9AKlq3VO9G5ZaSKCof0W7G4z43iZzw3qpB80IP4w7Wptb1H96N3a5hoUOYb >									
//	        < u =="0.000000000000000001" ; [ 000035719841615.000000000000000000 ; 000035732073822.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4E82721D4FAD156 >									
//	    < PI_YU_ROMA ; Line_3614 ; uNos68r4X6KHuYDK0q054yRafeMOe0D4vQ31w7uqZWi8S9fiA ; 20171122 ; subDT >									
//	        < JeIBMMU03iFO4x2C10KH76aP1u5PdR489iwphIGxmseAcP3BlX61ab16hInbSgs0 >									
//	        < z3ObYuCyjpp2fnI8IF82GnbOC6XJtI52E2g60b6Ni2Re3Pq9O47MrTC4S2hi8IiH >									
//	        < u =="0.000000000000000001" ; [ 000035732073822.000000000000000000 ; 000035744500737.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D4FAD156D50DC799 >									
//	    < PI_YU_ROMA ; Line_3615 ; eh3l27yQZ0zsVx575J6R6S92hc1fE1UQ9SEGwzQ9GIz8xOs6c ; 20171122 ; subDT >									
//	        < NlTblouw21N91mR44K7c0Tc5t9kN9Ixij6mQS2XPZttI2fIFQCJwXnPVYBwmyCpS >									
//	        < 6Rho981xqMGv270Z6vYBBql8KpwdP14WJI3W8XTzFb76609Z58kyBtZK8J73nrwB >									
//	        < u =="0.000000000000000001" ; [ 000035744500737.000000000000000000 ; 000035752744245.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D50DC799D51A5BB8 >									
//	    < PI_YU_ROMA ; Line_3616 ; 4BNPJl5I42iZq97jvFU10hj9ewOwZv4K03hk38C1WOJQqdw40 ; 20171122 ; subDT >									
//	        < pk1a7MzywUpBr52Cc1wNz3Za1F9jts6V415O5aPzfvcJWzPFrnFjsKfeim55a205 >									
//	        < 3G5qC6U8mm9xkmqTfoIT9Ov1Fqv75NW7KW781aDv02vs2I1iCz3qI3QbAgRTzdag >									
//	        < u =="0.000000000000000001" ; [ 000035752744245.000000000000000000 ; 000035758360174.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D51A5BB8D522ED71 >									
//	    < PI_YU_ROMA ; Line_3617 ; LegauX0By85F7fJ45V71M8bX9VFH7gfMenW8S4j45e5Icx13u ; 20171122 ; subDT >									
//	        < Q3a8WWl24uT16kC40j62pOt3S50GgMoShC2Xph0Tvz8fROjz6606iCe8167NAw51 >									
//	        < 72Oq6Y5R0VHV1wZN0xWB8aS5nXnsI2PeA9MZYr3bM9oQC7Qo46h8j1Ve4c8NrBdF >									
//	        < u =="0.000000000000000001" ; [ 000035758360174.000000000000000000 ; 000035772290641.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D522ED71D5382F08 >									
//	    < PI_YU_ROMA ; Line_3618 ; IXtJw92291vGCwd7Yd4mb49xkNimtIK9Cnd42J7X9e864aH2x ; 20171122 ; subDT >									
//	        < oVV3O878mFRHgh23w24VPSCVG99xpUGH74U5gja711uP6182n42Ylb5QxiAW9l3J >									
//	        < 9rQi04Rssd9NI6Iwf94uvPey8w8tb2l06i3Nd820Iu0W90eNzK41ejIr4BS9ybNS >									
//	        < u =="0.000000000000000001" ; [ 000035772290641.000000000000000000 ; 000035782161418.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5382F08D5473ECD >									
//	    < PI_YU_ROMA ; Line_3619 ; Q31vSRm5mnex3cBO2TQb6jpCVjUQD1W29Uc60IVgOWqBvbYr9 ; 20171122 ; subDT >									
//	        < g61VsMJ25U30baMFB976kGYB6PM678FWeyeObTONlMMh8uU90ZYq8WU609Wnd8Nu >									
//	        < Ft40a3RUV582wQEG0RXElwcjX9R8f32B1590ptFgq62AJUf6MxtCRK79TSOEgQ5y >									
//	        < u =="0.000000000000000001" ; [ 000035782161418.000000000000000000 ; 000035795755161.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5473ECDD55BFCDC >									
//	    < PI_YU_ROMA ; Line_3620 ; 28Amnci46l2086233Z7ef8T13gO94lfR8vmRv2cOT5b8675q2 ; 20171122 ; subDT >									
//	        < FaRU0ETK824WkX96rLd9KD8Y9x0lSU7XOEP1h55GXB88B1fv06fYdfTJ6976sV5P >									
//	        < ur4xMoZ81OANcFUC025xj8l4dNLw3t7L5S56E4rK8D1z5l92v2UB5jdD6aPt8NqN >									
//	        < u =="0.000000000000000001" ; [ 000035795755161.000000000000000000 ; 000035802100302.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D55BFCDCD565AB6E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3621 à 3630									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3621 ; v10cfAMPv8AV55UFf8057nPRA23a3am742dBW02Se8t0zp5Ka ; 20171122 ; subDT >									
//	        < PCZ8rhMJ3yjvLSA8ySFwjf5V4m85fO9Hg41pqh06h6I4BD4QT12qb2KAvZUy06h2 >									
//	        < RIMGE8N4w9fS015rrJR7LHO7rDL57yr8cmL64kmKZnR71A2F8zjrRV8DRbEcN44e >									
//	        < u =="0.000000000000000001" ; [ 000035802100302.000000000000000000 ; 000035811051528.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D565AB6ED5735400 >									
//	    < PI_YU_ROMA ; Line_3622 ; 46Rn7q69n77v1mZ8dWf002Gtn2HMWO06RmBD9Z4iVGjc6qBDW ; 20171122 ; subDT >									
//	        < H34UknMT4D4bao8lVxCPZU84pE9HNn9RhkUf395x33OajC3Nbd5hsTB7hzv6Dh6J >									
//	        < 4QbL940472UIo768dXa1urE5CJTaQBbM998h5081P13XR07CtFZFqVfD64kfCTu9 >									
//	        < u =="0.000000000000000001" ; [ 000035811051528.000000000000000000 ; 000035821546381.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5735400D583578E >									
//	    < PI_YU_ROMA ; Line_3623 ; A7xd8ff2p9sU0eI26h4iL725jJ64599O82nT7FK11eBbNcfmI ; 20171122 ; subDT >									
//	        < J7XW64XUw3KKz4P2H14KY677cBGs3p6X5jx3qYPeTuxyzEKdP96rwm7FHnAYak33 >									
//	        < 101cjUJyrUtP9vGBMZIJi8V98e73Lmu8RTwWX03A1eM8223wml6451MYZw7Zc4UA >									
//	        < u =="0.000000000000000001" ; [ 000035821546381.000000000000000000 ; 000035833410206.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D583578ED59571DC >									
//	    < PI_YU_ROMA ; Line_3624 ; BN7vxNeRcm87459fDHdsmpvxXbB7NyULsz5lKAD1yK17I3I6d ; 20171122 ; subDT >									
//	        < 0czLF7T2iYugd71fX7ge1NXcxiCLFIU780SNx2WT75E7kJtV9dGE9QHTjMPH7ppU >									
//	        < P2FV8dXB75mhR2MhnAEeDIzu69spp8t479zu3q7qzGBLeo0R5yV00So748Y8gJUF >									
//	        < u =="0.000000000000000001" ; [ 000035833410206.000000000000000000 ; 000035843517835.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D59571DCD5A4DE27 >									
//	    < PI_YU_ROMA ; Line_3625 ; 92Op7i24DzC47OV1A2y70KZrMQp6UM4Xq1n2XQJ3oIPE5Egjq ; 20171122 ; subDT >									
//	        < pnZ6lj98brS01MYIqR7qldfoaWfT7KaIjlRbXAuKbBgXlUG6nfR2y0AtB6a0QyDM >									
//	        < acty992JoGDJhj2bd4hMk4N1a42la79WiFxeh3TOcs78ZPxtzdP35SAxVR4O8H3s >									
//	        < u =="0.000000000000000001" ; [ 000035843517835.000000000000000000 ; 000035853395340.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5A4DE27D5B3F08E >									
//	    < PI_YU_ROMA ; Line_3626 ; 11WRO7hwtdYlbu7acIOE3gCa033J3q2a200yCT7fCwGmGU09M ; 20171122 ; subDT >									
//	        < 4ah31SNyttBOUKXCgaBaD3RA4RfrFiCZn5n9WzYWOT75912toQug9mXA7qUomgLg >									
//	        < Vbgjvu8kCR053TEd85JaeKcAt6HyPv96iW0n5y7437JNV6pW9QqadD1646g0P58O >									
//	        < u =="0.000000000000000001" ; [ 000035853395340.000000000000000000 ; 000035858530695.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5B3F08ED5BBC68D >									
//	    < PI_YU_ROMA ; Line_3627 ; 8LNA70Jp06608ZHJ0pK4f3WLwBR1HEXCoXSyxV44zqnG8aUZ2 ; 20171122 ; subDT >									
//	        < IJ8T42666BJHB0tKNrnzEf8kBWny7N8SvSOOhKUD83C0Xch3nX2R4f6DoPD5wuvF >									
//	        < LAo3SasDZ10xKW9h7XZt039a0cT15zo1O6jSKleG1t8022x5B9jnDVU9yh1bzRAO >									
//	        < u =="0.000000000000000001" ; [ 000035858530695.000000000000000000 ; 000035871010851.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5BBC68DD5CED19D >									
//	    < PI_YU_ROMA ; Line_3628 ; b44sJj4jXe2vNy768rP2qAGzJvP0nW39viD9r629VVbv5A96h ; 20171122 ; subDT >									
//	        < zUvuIE93Q9q3PoOSjhk29sYuO9axLUse2TXFJ3qxXBjB50Re47ilPzETpQodIxi9 >									
//	        < 3X708S8E385p8v9MI47204Oe7481DK7o54M30G8n2pmtjwxqLInwHNZ3JHOcxHRA >									
//	        < u =="0.000000000000000001" ; [ 000035871010851.000000000000000000 ; 000035883964388.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5CED19DD5E29596 >									
//	    < PI_YU_ROMA ; Line_3629 ; A7LI220Pg4ddP7Wwn2h9mho7X15wshWjIkG445SnLfjv8SaxD ; 20171122 ; subDT >									
//	        < Z06gEJKz0V5QRdZ2S604N2IExVpPzNdxqTD2t6v4uc2u8Ek96Fv29PQ6L6M2F06P >									
//	        < w1h5GU8F4f0f9b7NTmH3Hq7s123zOQ72is052rnT5kay9IYnu9un9Xd0hMHyVuDb >									
//	        < u =="0.000000000000000001" ; [ 000035883964388.000000000000000000 ; 000035895687719.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5E29596D5F47903 >									
//	    < PI_YU_ROMA ; Line_3630 ; 4Wq8o113N8BO87ZD4u4rzF91Ga01j67ftF52aQ4mOXt16Qjmb ; 20171122 ; subDT >									
//	        < QNs139oxqK177F88z2Gr53wmn04A5C4ljr2GFs244ML3UpWnN1p7AdOL0HRc57Kx >									
//	        < 6dfD8JA6Pl2z0kIa42HK3uHlwdE2838Df5u2N22obvjFS1eGc9kR07cdd6980y9q >									
//	        < u =="0.000000000000000001" ; [ 000035895687719.000000000000000000 ; 000035910678596.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D5F47903D60B58D3 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3631 à 3640									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3631 ; 3Zi82rY8zji46xBi4SBeI70X6V8jm2UF0Kz7t2p49b75oibcM ; 20171122 ; subDT >									
//	        < h7pI5kNoY8w2aIN1Mq0VjDl7jS9KT1koZcnOX2T01E9u8e1BFZycmqnFdzbZp3py >									
//	        < 08xPWGrzkFhoHcqo7IV5n0dpknXVtPB8g60TBs2CtN8IBMFZR4cnK0N2vGx9JCK2 >									
//	        < u =="0.000000000000000001" ; [ 000035910678596.000000000000000000 ; 000035917899390.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D60B58D3D6165D73 >									
//	    < PI_YU_ROMA ; Line_3632 ; NH7b8z6PVyh67OImf9K6Fk4C5uME6k8uxk2CLB1g2Dq9sMVLC ; 20171122 ; subDT >									
//	        < dg2zYn0XHmC16KAwlOJZ0x5igvZ74hZ71X5coxAH5f6cjJ43S3QUK6Ah8250WWb2 >									
//	        < 9abGcR6ANr5W5SWb9qpaqLR5t446iKg16f55bYhS61VSQJEKl55U3Qz4007hWims >									
//	        < u =="0.000000000000000001" ; [ 000035917899390.000000000000000000 ; 000035930965425.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6165D73D62A4D5E >									
//	    < PI_YU_ROMA ; Line_3633 ; 87aWO8VTRe541Q8y0s93AH34iMXj9D0fW6LW9u8GaiyTq1888 ; 20171122 ; subDT >									
//	        < 0Hj4ZWrZNkh6j6Pe0Hp9BAgO5l63t12oHiuY4020f27E1d07XdILHxb5200uOr7X >									
//	        < 826de72WzGD30lcvSIdv8zI4YW79dOc236ayW1GH0VBbrEqDP6CbMq1WgLhbs89i >									
//	        < u =="0.000000000000000001" ; [ 000035930965425.000000000000000000 ; 000035940951328.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D62A4D5ED6398A1C >									
//	    < PI_YU_ROMA ; Line_3634 ; nBaiAGyx37F6xGxMxTd40Ueq1Z89822jABRzNyAt0LBv3V279 ; 20171122 ; subDT >									
//	        < ZUC9OZYGF2d25Qd2IVBQt930j2N7u2jb0SCnORURJcByf4VTklBRbwvY5NLGs37S >									
//	        < 75lK1gkYSzD71t4XjOdNzbwLRHGu77988975IxeloefcA4sjjh4q8vdUIoJG1KA2 >									
//	        < u =="0.000000000000000001" ; [ 000035940951328.000000000000000000 ; 000035950506586.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6398A1CD6481EA2 >									
//	    < PI_YU_ROMA ; Line_3635 ; 88nJqh6reg4Gv68r7m1JpmLyB022FQaw5q12N4cP6jCz19q3G ; 20171122 ; subDT >									
//	        < OpOeGM2hXfFOomaOO0M3FT6thO53ULRb7O14HyZOzX7i5TP7QMQVSH0vVZTHthbW >									
//	        < 6D1AbCSoJ13HLqu5Sd8qukF5Iccl1NeDk6aBES0sSZK2dSdoNy7s4J3Y4I4lbPJ7 >									
//	        < u =="0.000000000000000001" ; [ 000035950506586.000000000000000000 ; 000035962280309.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6481EA2D65A15BE >									
//	    < PI_YU_ROMA ; Line_3636 ; F5sU841bl7Tmt5WxW6VzqXkp27Zv3wX82ydA1l6241b1LSgvd ; 20171122 ; subDT >									
//	        < iRl8l95dMsg86SP5lZ7hc043532hU29A9hnP79mEa8jfsGV5dT3C1t4L3j5pQDaG >									
//	        < 3iRbUQV1ODwZMcbb9kIbbzsjTRNG1Fg2xCM5R9sLjlhY8NZ6yBI24ifUXIGtLQb3 >									
//	        < u =="0.000000000000000001" ; [ 000035962280309.000000000000000000 ; 000035976431099.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D65A15BED66FAD65 >									
//	    < PI_YU_ROMA ; Line_3637 ; 163hNyKaH4D9667RjvZKZ8ZK5s2Ky6ypEuEhF5mAp57GSxAg6 ; 20171122 ; subDT >									
//	        < 3JGLaSFb9zl77FJG1JOtvNaxGvqE56jP0mZ6Yb7h4Bc429v6dIdLTs7cwi61HxAP >									
//	        < wF4QS23E8hN7kOlBbMLX4rHtgIfO62p6T5TFEfF2825swcF61i5MzEZmnanqmeXM >									
//	        < u =="0.000000000000000001" ; [ 000035976431099.000000000000000000 ; 000035983097099.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D66FAD65D679D94D >									
//	    < PI_YU_ROMA ; Line_3638 ; S58KWLN4zYH9w353MWPh07100CaBSV32M4Pjp7Bg9RrXG8SmR ; 20171122 ; subDT >									
//	        < EPdO11X7n9Cd70E3APVP7079z5Ujlb4LM588S00R2r5w5LHPIAL153z5Zv8583mk >									
//	        < 9l41iOTYbuSBSs5Ky1rz3fDXE6Gqv5dtF77xmVN18zS7a6ymYb5iCwf5l6N51B88 >									
//	        < u =="0.000000000000000001" ; [ 000035983097099.000000000000000000 ; 000035997011076.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D679D94DD68F1473 >									
//	    < PI_YU_ROMA ; Line_3639 ; A255u7L9AGGSdOyj321S2Z82Mt3lb4qQW3Dhz4p31e9237CEf ; 20171122 ; subDT >									
//	        < ly002ce7ccc8a5OkjdQ22F2V0TIQA6Ah05jJ57mqQNE3kA28HZmoO7c5MkBDhtfn >									
//	        < X6ub4Ewy6NxlngL5fGEU5s0GLG9a25dNPrap5AmUb2BzF9Dh0J81g8a9nK0pXBdb >									
//	        < u =="0.000000000000000001" ; [ 000035997011076.000000000000000000 ; 000036003411899.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D68F1473D698D8C5 >									
//	    < PI_YU_ROMA ; Line_3640 ; z705XV76dEZ1K6ZD4d6k8dID96vjZ253O5AjQ4B7mq4CN98pT ; 20171122 ; subDT >									
//	        < Qu9A53xp3ZXOwVgBqP103eK82XzwLkU2B5rn9s0DVu20paqzh0yfk41sO6koif3e >									
//	        < tMh442RbxL0IpUYgJ78Uq4hd02fq43d9I4oI0E0I6nsQ70qe6xEJ6G3pBN7JwkIF >									
//	        < u =="0.000000000000000001" ; [ 000036003411899.000000000000000000 ; 000036018306512.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D698D8C5D6AF92FB >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3641 à 3650									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3641 ; 0540z94x846X5GM1z3mUZNdTDS7L55kRE8qFPK5sQipVs8DfV ; 20171122 ; subDT >									
//	        < 2zBFBev0iN4Fxu0Zt7hwC1Cmgeiw4YgoNLaE65u913qy44oi51slFJUVK1A4Tf1e >									
//	        < Q6r9B81P2pJd9c8W52q9aUlRm3iA3Mo9qEF7iJ6p9wDkL7U9ELsGh622N21V8lrc >									
//	        < u =="0.000000000000000001" ; [ 000036018306512.000000000000000000 ; 000036030333292.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6AF92FBD6C1ECF1 >									
//	    < PI_YU_ROMA ; Line_3642 ; z9JQ5FwK0M7Wddar41APz3vm7XTtUrRggoN266u4WXwwG1m9C ; 20171122 ; subDT >									
//	        < 7bAO4F1sXCTyeAg9u8KRnjg0Au9Y7WmPULQ8JFfNKV9YYdgpe5NB46056zY53QwC >									
//	        < U8jm02zu8FZr9UL8AZnZ29GhTK91pCX0Yw0B9UukU44tA9AT5A5cs3AVMRKcS32c >									
//	        < u =="0.000000000000000001" ; [ 000036030333292.000000000000000000 ; 000036038234694.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6C1ECF1D6CDFB6D >									
//	    < PI_YU_ROMA ; Line_3643 ; hh3fVwZjQ4QIyca8K1aK2K34snodf5M9UHIYfy897lE55b1I9 ; 20171122 ; subDT >									
//	        < eXYvr9Fa32k0x92N9b2CYOcbt06t7xr81JrQOTJgkF500Ji05Z3S4Te6k543XLqW >									
//	        < jF1ZL9xjg3mk5Kwb2p8lS3Aj2yd4VRmX56nA6GOxRYlegJYK02AvERoCiqk6vx9F >									
//	        < u =="0.000000000000000001" ; [ 000036038234694.000000000000000000 ; 000036046362596.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6CDFB6DD6DA6263 >									
//	    < PI_YU_ROMA ; Line_3644 ; WFhbAjB752K44iZ6DS2Fc11FHyqT3uu7mXF7W12k2yX03Z2CO ; 20171122 ; subDT >									
//	        < sZNFSUnLWYk6ox5Z4uy9qm5PSRf6Cuiz2d8N8Gpg54XUVZq086JXpnXBjvnJd0P6 >									
//	        < 9BN35nA2VlJ4APAiwtH6ko8WBziqq8l5tQqv02mgEk8KNKK191P44L45Vo66SBHQ >									
//	        < u =="0.000000000000000001" ; [ 000036046362596.000000000000000000 ; 000036052345054.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6DA6263D6E38349 >									
//	    < PI_YU_ROMA ; Line_3645 ; o2s07lpGFQH59sy9fj5h7X468p8cM7m422Uo65JikI7r9eKu3 ; 20171122 ; subDT >									
//	        < JoBqUGpI5rJ4c61Mcg8E0Ye4QgBnpL1dBjtqlhPh2bo3RJEzv04YofB39GPRRbA8 >									
//	        < Le2rj3gJ46AG1N4Cc49BOv718R14DI9zqK69ojBfo0gba2gy621x26j7c7Syuq22 >									
//	        < u =="0.000000000000000001" ; [ 000036052345054.000000000000000000 ; 000036064079582.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6E38349D6F56B16 >									
//	    < PI_YU_ROMA ; Line_3646 ; USj93L8B6Vd4glG1f4DZYULQMHNRKw7ZO37tOyH1yqMod98h2 ; 20171122 ; subDT >									
//	        < 8KBubguKWkfmd4L3v7Q4IpqN7heXtl2284vym6d7F9XK7dYmt9joE64Cl72b84t9 >									
//	        < 3KIH58AUKWr71QTp0527HHk75D6o2c1J9c3UwLY1aT8b1ei3xR152MJX5j8U2NnD >									
//	        < u =="0.000000000000000001" ; [ 000036064079582.000000000000000000 ; 000036076620498.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D6F56B16D7088DE1 >									
//	    < PI_YU_ROMA ; Line_3647 ; dAoXRjn1UUHxtZpf92clxNjbw5qHP0hn8xva4qtUItX7k9bg0 ; 20171122 ; subDT >									
//	        < 4ry6xcFYmoyh2OmiM98dnL613MX4vT5eQEGic25yMkYQUx97qpnxL6567HVD330o >									
//	        < BT859kBkU1OrKDC8U2cISXM4NiPpxc8SC6y4l5243TzL5IEooTXaQNOJM47p005S >									
//	        < u =="0.000000000000000001" ; [ 000036076620498.000000000000000000 ; 000036085350475.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7088DE1D715E007 >									
//	    < PI_YU_ROMA ; Line_3648 ; 67qyak7BQ5VcQ848N5Ii6lh5eC9UhUP7Wp8l7ztZ4TL4404Xl ; 20171122 ; subDT >									
//	        < YTxVV1PoYtEMw5k1W0Ry8b4Whh96pwEdG9Rt7O03Uki9KfKbeW3bo76o7lOJGddI >									
//	        < 69cFndKY5Ljh5MiLKc5f77KqftS1yf9IWde14C10s0L4U3j4NL902r0QUswi02dk >									
//	        < u =="0.000000000000000001" ; [ 000036085350475.000000000000000000 ; 000036091435162.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D715E007D71F28DC >									
//	    < PI_YU_ROMA ; Line_3649 ; 20qGb2fpo2vp3NumCx628MqB3p899d4j91JT6QLSQ6MUSIOX2 ; 20171122 ; subDT >									
//	        < 98jH9AbAgA7u57c217Ovi0gy3d0gmmztVRD4QM10bD4DT3jrkqNQclzN7jJ9beV1 >									
//	        < 8kDhA12Cqzba3wv4qN2sF78K3DT3vziSm6PM3me4ajj5glfRoo9vu3jGf5H7C02C >									
//	        < u =="0.000000000000000001" ; [ 000036091435162.000000000000000000 ; 000036103303157.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D71F28DCD73144CB >									
//	    < PI_YU_ROMA ; Line_3650 ; 599Bja3xu38jA24TYN8B934yjn99WDRJfc7p00mm61h59cAmi ; 20171122 ; subDT >									
//	        < A9raHUoFchz9RuA39si4ZMyh5BWXcxm1I1kd8LVSB6Gw5umECyHC2x94HR1vt9Ix >									
//	        < txzO6W3bZA1CrhzGbqwt8RS76S77uQ9Zw4ycOtF8Wukt5moKzsyO1o64PzW0r7rx >									
//	        < u =="0.000000000000000001" ; [ 000036103303157.000000000000000000 ; 000036113898805.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D73144CBD7416FB8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3651 à 3660									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3651 ; Y7k77yStZfAtBZiF9oga28tE545ZY9SCpxdRSA0z0w30nX8fr ; 20171122 ; subDT >									
//	        < lUiU7w94HMpnrfgwCNVfjD6hTXlKZnIToFNRJa47gdLK4sDUMX0QYt9um5Y80693 >									
//	        < pL3GNYMMK5OoE8SljvToCx3830jv2n3RK9zIx5PB5k79BW1Z3HnGcBmn26AG89F8 >									
//	        < u =="0.000000000000000001" ; [ 000036113898805.000000000000000000 ; 000036123232149.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7416FB8D74FAD8E >									
//	    < PI_YU_ROMA ; Line_3652 ; WTGotB5xxSGH6WTKK55v0VPn5aSDt3Wug2izzJkwRgrNQnT08 ; 20171122 ; subDT >									
//	        < pJnsTn5fwzy51N7R0kPbL6P28Uc3OdVHT79x0NupkCN8Xi9MCsYj6jq56eMQZyFa >									
//	        < XgeoTz8t6s5u4H6Lob5jPH69xTCEAt67kDLcKSl6Z6Q17gL3X289VeEnZq2nk8h3 >									
//	        < u =="0.000000000000000001" ; [ 000036123232149.000000000000000000 ; 000036134307172.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D74FAD8ED76093BD >									
//	    < PI_YU_ROMA ; Line_3653 ; Ws7Yi2XkuVD6yY2Rj63G2hdE8Y95bqi3DRaYCka44XSKzbo9R ; 20171122 ; subDT >									
//	        < nIq87Kq3GtkMxft9CoFWYB01qzV5bwzVLgL9u6g5K88jNXRO8blW7ZTK5pSt93za >									
//	        < IH4g633Zz8K4M28N9I4FQ86SyCtX30XB822tvhI2cTHN7MZ4fcH73bN6DdZ0yglW >									
//	        < u =="0.000000000000000001" ; [ 000036134307172.000000000000000000 ; 000036146380345.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D76093BDD772FFD2 >									
//	    < PI_YU_ROMA ; Line_3654 ; TL50pocW8jsy825a8Ju9oLV1mQ0Kx1SV1z1vU50Dppu12P6kW ; 20171122 ; subDT >									
//	        < ga0Q7IZxVR3nGM37f0469vi5352Vh6XRE76p6778r541t9RbIiurqcp9P6hBApBv >									
//	        < 682Mn9Q18614HY4533KM3pt9167458G0pr6w70EDh2hRxBaqjv8Ap9NgNE1Q4Gk1 >									
//	        < u =="0.000000000000000001" ; [ 000036146380345.000000000000000000 ; 000036160761978.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D772FFD2D788F1A5 >									
//	    < PI_YU_ROMA ; Line_3655 ; 3ZlptC4Sx58I4P8HiAitNa6ezTPM88WnLlKR52mIdV1imHKIm ; 20171122 ; subDT >									
//	        < 068I6CduxXLGRntXdUR3yGs3iQ7orX5bRvnd705i1ABI4B8w5yn4h72Z8j25C17Z >									
//	        < F781MUz0OUl3pZBS3YfX5OUvMCt6d0PIvsEu3Z135cTo7nnHz55BpHmSGi88GxwB >									
//	        < u =="0.000000000000000001" ; [ 000036160761978.000000000000000000 ; 000036171475979.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D788F1A5D7994ACD >									
//	    < PI_YU_ROMA ; Line_3656 ; 1I0y3k604hC6FQJo00RkjwhRjLElNx9KT6C6w33LaP49e8Hj9 ; 20171122 ; subDT >									
//	        < h6AAW8a34Yr76Lj76CcT1JH009sPZQ0xOBe032340Q8SociY7mS9JnTaht0qCn9D >									
//	        < rG6BWgKMqeR542QUtb4MKb871h0E6a06418DAkCtVxMsTPkdV1xl06u7ekYzLByV >									
//	        < u =="0.000000000000000001" ; [ 000036171475979.000000000000000000 ; 000036185748403.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7994ACDD7AF11F8 >									
//	    < PI_YU_ROMA ; Line_3657 ; 48l0usbln8Z9921xQQrpCa4fMmgX5wz0D88p24xoOE4Ejao2H ; 20171122 ; subDT >									
//	        < v10YQ48bPyqWl21YJ8C09a89P9p8mPK9W044pZj2N5L7O5aUMDGOA77862A61xTP >									
//	        < xdK2dcw1k7h6v8pEpI32s4m143ae35G682ta85s5kSp7A4gQv6S64n2fpzyzmxfI >									
//	        < u =="0.000000000000000001" ; [ 000036185748403.000000000000000000 ; 000036198106490.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7AF11F8D7C1ED59 >									
//	    < PI_YU_ROMA ; Line_3658 ; 0D54s05f394dlDhQ9sNV84v5Jlxz0Z0480hE0EYzRKfeE92ma ; 20171122 ; subDT >									
//	        < tgKxF8VQXJFA11x9HG873Qpn6x73nsgyF51mJ2y3dRrfhS6A9sbJ930Mlj7WQnh6 >									
//	        < F16MIL6Fjvg4soQgq1lFcdHu6yVUZBok6Ay09pF4KnqAS3Q6tn4M9E69uASMLave >									
//	        < u =="0.000000000000000001" ; [ 000036198106490.000000000000000000 ; 000036207750415.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7C1ED59D7D0A481 >									
//	    < PI_YU_ROMA ; Line_3659 ; B3G4w3u1jvu8MAM3BZL246WF73kh98rWr5WXPX91Qe02r1HU1 ; 20171122 ; subDT >									
//	        < kw670zA4LE63GUZX4x542Dtjmx0vOhgp9I1h5MWoVHGW6c0QNAE3O6N6Pptwj54W >									
//	        < 6iEAbTXwTE144gjHYA5YizX78P2Vmepwbadq216n8kkk2A9Q0e104IAzeFe1V495 >									
//	        < u =="0.000000000000000001" ; [ 000036207750415.000000000000000000 ; 000036219525271.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7D0A481D7E29C0F >									
//	    < PI_YU_ROMA ; Line_3660 ; 3b6MTKNvCZKBCKgOkF2985oihdy5W7CR8gE8V1x8ywS9X5R61 ; 20171122 ; subDT >									
//	        < 1VEV13wzK32h2D0hnJ7ze370OoDKM7vQ30jjMPC330ucAxKVFgOFXldW03PCn1GL >									
//	        < Q4F72P5vhsyBeY5pcrTQ3zdMJ0J08yaJHIx39o1GGDKVN761oI7W6jiteBiX600F >									
//	        < u =="0.000000000000000001" ; [ 000036219525271.000000000000000000 ; 000036227710960.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7E29C0FD7EF1998 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3661 à 3670									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3661 ; 3Zs6bkAjar8180Ky1O7c89768LVbZ8kG5K3L0c8S6nBVwglPC ; 20171122 ; subDT >									
//	        < tzhZa8FQ3TnT9286OD2LeKWSLurE0S6XUeRqMy62H5M37DY7ioVmzcF03opwtVGF >									
//	        < MUurmO9H15e8b2xhCd8195Zi5Hub72eE66709f2nBNRrrY6oS2nuaxq506ZuOA0V >									
//	        < u =="0.000000000000000001" ; [ 000036227710960.000000000000000000 ; 000036240377835.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D7EF1998D8026D97 >									
//	    < PI_YU_ROMA ; Line_3662 ; 2SIbE7GSY3qm51CFoW8g2W10xp9HPgC00B727p327DuMCKoUd ; 20171122 ; subDT >									
//	        < VPV13L04k2kDesBGed59a9HsSTAe27LD59YlofL96TgHH83idn5Ffg67bDlxMw47 >									
//	        < 9qffB9KY9702A15n0E210n26oa5gXUpN7zy74jqT1tuG99Xd88HTuD34U1vtQ9Pg >									
//	        < u =="0.000000000000000001" ; [ 000036240377835.000000000000000000 ; 000036252178592.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8026D97D8146F43 >									
//	    < PI_YU_ROMA ; Line_3663 ; x3Nbv90B5Q71UeexE9SPmCbw081ogEQ2SikSjFuM6MVmp0r75 ; 20171122 ; subDT >									
//	        < 2439LbDJA2pmhw1w8M7H1z4lV22Tt5cJ8gC4Nj5skaJ68HerC9eGQkyoPN9X7UnY >									
//	        < 0DLGMydUebBe54H2NAc5C7111pO9tcNrNE21jQKy3k2OwEH1owIzgPKGI3rBy57D >									
//	        < u =="0.000000000000000001" ; [ 000036252178592.000000000000000000 ; 000036264806417.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8146F43D827B401 >									
//	    < PI_YU_ROMA ; Line_3664 ; 6NjHZa0Y5Jnij19qcAEU7KiOnE1E0854m9i80HBB9pzSg63J5 ; 20171122 ; subDT >									
//	        < nH7PJHlk7k1K2d4vmw1oQe1Fw4Ht3R2c21LrEr221188EL32rsMk9IsFI7vt5x14 >									
//	        < 2D88a7zWUu87U1twgugwzQ3l62vU48L5qhTxsHM6lOnylVD4VTP38YSyWfp1qTYX >									
//	        < u =="0.000000000000000001" ; [ 000036264806417.000000000000000000 ; 000036277949263.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D827B401D83BC1EE >									
//	    < PI_YU_ROMA ; Line_3665 ; J85tJh2mZre0o2ZZhp3f111k69EJT914qO7wCeBh4RsW67Es2 ; 20171122 ; subDT >									
//	        < 57hyHBIt39G1847fjAoI60fOh4Wp3ltVfJb6FrRBSL9QE3BKGc2JYD0811X9z2Ue >									
//	        < e08m04g3l4d3AJ4EIVXtZRBa6QGZO9WbHAm069X6Y2Tq43Ght89brtIY6inV5T5V >									
//	        < u =="0.000000000000000001" ; [ 000036277949263.000000000000000000 ; 000036290987210.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D83BC1EED84FA6E1 >									
//	    < PI_YU_ROMA ; Line_3666 ; gmKz73x6W0PPNe24f3WXB3kwYM2Z82A877Pvb50N821LlVZbC ; 20171122 ; subDT >									
//	        < k6dy1Ju7I2H1j66x6mSv9t08E6y8emyRAD9N147CDLm0Fpi74ESLBlltdg6C5s6A >									
//	        < m9pb54t5Z30s2M2VXYOj77MmZR1whMxiKOW5ZaIhchEL3eQTNNyPpLcYba4fHEJP >									
//	        < u =="0.000000000000000001" ; [ 000036290987210.000000000000000000 ; 000036298177155.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D84FA6E1D85A9F73 >									
//	    < PI_YU_ROMA ; Line_3667 ; 7574090SCymdQ604JgS63PlEuuR3y3BoM1n0d1K9c1Qc1ky71 ; 20171122 ; subDT >									
//	        < aceBRX32zayv8LBDsdZW78OwYqhH3WCz45rMo3vSV269O33dGN46OS9DzNlCbh7r >									
//	        < zXh3G41R9nToM0HZVEy4Z846hoo5QR6Ndi3lNeLX9k6eT73U1LHoNiBAs32P4V3L >									
//	        < u =="0.000000000000000001" ; [ 000036298177155.000000000000000000 ; 000036309766481.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D85A9F73D86C4E88 >									
//	    < PI_YU_ROMA ; Line_3668 ; jnmYhUGa34IGDhiif8OYvZrLBTBo00sRl1pYIIqeuO5A70520 ; 20171122 ; subDT >									
//	        < svrzzUCf3o2S594Y4Z0iN7JFB4tg9f1ROIs44JAc7kQoO8g07yB6NXpUj10nzQk7 >									
//	        < 02u621Hv5iBhbpABC18cI4vfdE68qt6U9004lgxDmjYuCTGu0a65O5iYwUA9a6VG >									
//	        < u =="0.000000000000000001" ; [ 000036309766481.000000000000000000 ; 000036316850951.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D86C4E88D8771DE7 >									
//	    < PI_YU_ROMA ; Line_3669 ; Z90DW616296nko56z4313jXXmZ7W8p9eyQqts3X80a9Z0EkWM ; 20171122 ; subDT >									
//	        < nqSasaRu633Py67UUw8G9eVY5Tcg12JXm130g7QIXA21pwsER5UA6Kd7nC4r0FAp >									
//	        < 6465ebKSxrs0yCJT73t8ip4vtgP4M7NXmg6x7QN4wjWajEL5j8K5TEgMYB56HXMw >									
//	        < u =="0.000000000000000001" ; [ 000036316850951.000000000000000000 ; 000036329853503.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8771DE7D88AF506 >									
//	    < PI_YU_ROMA ; Line_3670 ; Q9R2mK2DpyXWtU2mvG3hJXJ5R2HS41215s3thq6L3wCqPlUvz ; 20171122 ; subDT >									
//	        < uUlK0xgY5bVzHGO4I6mY9JDcQVCQNOUpu710O4E99cV1VhPj2DI2BH7axUa002hU >									
//	        < WFg98aqljp79QktlTq611Zmi5k4tc8EJ9RCRO2QS9SQfXBNRKpPBBa4dmn43b34R >									
//	        < u =="0.000000000000000001" ; [ 000036329853503.000000000000000000 ; 000036340406227.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D88AF506D89B0F2E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3671 à 3680									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3671 ; 363klNf3Dx0RbY418280eI1743P8221ijmRA2A1g990ytANce ; 20171122 ; subDT >									
//	        < 1l24j1x4JN3RQN3igJBsj2Eq1hU4wK54Pv5a8wPSi6m0mvV03LN595qOmbq522iz >									
//	        < 6Ly1le40M9f77WuzR0ch7nYrwdMAaDlekH4lVwWa1uIg3r01T9sJv2Oq2898n3iZ >									
//	        < u =="0.000000000000000001" ; [ 000036340406227.000000000000000000 ; 000036348820975.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D89B0F2ED8A7E631 >									
//	    < PI_YU_ROMA ; Line_3672 ; 21y06e38N608dzFMQ9T6qL7P8Vf1eQ1IAh3xNQ60BivcxGMDy ; 20171122 ; subDT >									
//	        < CvhGX8Q85Szv00E73b2G9K1yaqJ2cpiOPsX0tL85O5t6h2YMvxjm6O1pprom1D9s >									
//	        < z5M4M47Z956nL93jD8bbtTcqMI72G0P4C6tz95ZlE0UN47eK7YfkU5OnMTgNcWTb >									
//	        < u =="0.000000000000000001" ; [ 000036348820975.000000000000000000 ; 000036356546387.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8A7E631D8B3AFEE >									
//	    < PI_YU_ROMA ; Line_3673 ; FbSpTJ5Fu5tGptjD5oGL1Sox3vGJsqDPPVUJthVt2M605p441 ; 20171122 ; subDT >									
//	        < 467AP8YGO9oKQ82YY05s5F441KY60jl2dAydxawtKaL2OqW80EhHNd492388o6YZ >									
//	        < vmlkA764FmIJ2XUi5985EG3Vq3C62yiqbn4Pko6pGDx75XEzfI03KY2Gk9r5kv7t >									
//	        < u =="0.000000000000000001" ; [ 000036356546387.000000000000000000 ; 000036362132913.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8B3AFEED8BC362B >									
//	    < PI_YU_ROMA ; Line_3674 ; StPfga8iQk435mPo31Du404ePD2ez6ya9iJpiJ92OMIiyO6i2 ; 20171122 ; subDT >									
//	        < 469Wjjn09UxEbe6Cl2GjJ8vxeMV6jNq7rGlrgrH8iEtLa7kMldXChmfAlbR1p675 >									
//	        < 8wSAB15wYhguiAdL7l72Th3Zlf74OUkK8Cr35pzHv7f27ZRCb86mV8B6VcZ78GtO >									
//	        < u =="0.000000000000000001" ; [ 000036362132913.000000000000000000 ; 000036370081701.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8BC362BD8C8572A >									
//	    < PI_YU_ROMA ; Line_3675 ; MGy2XRYIcgdJi3hW74b108zU947tvOrc2weWw3mpTsPw20mNZ ; 20171122 ; subDT >									
//	        < zkK1brw6fjYzXZC504H9gk0I6015BW5wqFysupYv2UisBu49JOy3JB35tcdIv7e3 >									
//	        < 3n4RHpUQQ36QuNlDZRBO7RkDuNU69JhY149F5gJdTdB9rIdsE2JU6tx7y8aV8J2F >									
//	        < u =="0.000000000000000001" ; [ 000036370081701.000000000000000000 ; 000036378937980.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8C8572AD8D5DAA6 >									
//	    < PI_YU_ROMA ; Line_3676 ; nH3hqoc83NvnR90yAp9f9wxGID2M24L3AT7lWg3VzTAZc5quE ; 20171122 ; subDT >									
//	        < SdI9JLs3J5K85153P6U6x68SAFit67WkuiJsaA7io3by56d88n4AwFvZpgv3SXsd >									
//	        < Z215Gp09U30EaXy0BiA6dD61i8EsZ31h121POa3lw0j84cxAFELzKhuoltO9jPG8 >									
//	        < u =="0.000000000000000001" ; [ 000036378937980.000000000000000000 ; 000036391936806.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8D5DAA6D8E9B050 >									
//	    < PI_YU_ROMA ; Line_3677 ; eYH9T0K8Xav24cfhea965yI9v7KYuX3Fcb6mx5ybFLF2WQ5HM ; 20171122 ; subDT >									
//	        < 94d29gaUgtO08b56JakUT4H4glXQRVqFSUC8u8Xif9HMNeoA7XF3Ta0h2fSoJ0Z7 >									
//	        < n6qXQWkfRi4r9zEnI1x5oGDNbU7fie4KprD3q0BDAEQ72hsCUQa0llS22xV7KcjN >									
//	        < u =="0.000000000000000001" ; [ 000036391936806.000000000000000000 ; 000036399604829.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8E9B050D8F563A2 >									
//	    < PI_YU_ROMA ; Line_3678 ; qOo3H11j8uk3qIn1EsYg0oInq838QqdL7Zq3BmT4A59Q42meg ; 20171122 ; subDT >									
//	        < abihWS33M9h6zNvZ5p4xrwn2Mfa7wD6FML3lTvLTifs5D28nAnND7iUguMAk7eLg >									
//	        < k8HOU7iy4GeV2ltv8YfjX421p9m9s75f8P54LUPrrM9d2lZ19h75v25L3unKkCDf >									
//	        < u =="0.000000000000000001" ; [ 000036399604829.000000000000000000 ; 000036405332846.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8F563A2D8FE2124 >									
//	    < PI_YU_ROMA ; Line_3679 ; AE2ki80W0Alc2X8It16O1sr7g7qa8qG51z6r0Nej02dm3ouYg ; 20171122 ; subDT >									
//	        < HXsXJZX2S48tcByHP5zxtkCFGD440WHBM946VRM02w3k7eOVIo0SgWDZjVuZL5i6 >									
//	        < 9JXr46cR2oYMbGwa3tW76MBes5Iq0g07u9jHSsSet9R80XLxvTV89wD55WG80Tc9 >									
//	        < u =="0.000000000000000001" ; [ 000036405332846.000000000000000000 ; 000036417342747.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D8FE2124D9107482 >									
//	    < PI_YU_ROMA ; Line_3680 ; rr7zeG4MUv61P5Jz8QtCWexDlXF938y1DtnbKyqn6sTfTff64 ; 20171122 ; subDT >									
//	        < olD9zm917e14w1W2K9FKyr18Lz3pTbGitwJazNr6r1eYNYYCne45A8Rb5YO3QuAA >									
//	        < JGf9kc12Lh7vW7Wcrap06sv5suegaaa5909ad8vfGlYuBuG2Z8WR4f7t2caCA09Y >									
//	        < u =="0.000000000000000001" ; [ 000036417342747.000000000000000000 ; 000036430804953.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9107482D924FF2F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3681 à 3690									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3681 ; qx7hiN3194kf4mgwF0m66Xfn3NN8N6Dd7k41mA37p5494bp2V ; 20171122 ; subDT >									
//	        < 4G2Rv29Cx5Y916V7SywwY724UL8ahDQ430R18LI6wC6w3CNks85BSTaQ5k37t4P2 >									
//	        < 02a93J0H1jmbHfWyY04OSIiiLAbgA9XK078VJKRqzB2F1YQr2s115JH4014dP3SY >									
//	        < u =="0.000000000000000001" ; [ 000036430804953.000000000000000000 ; 000036445358215.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D924FF2FD93B340D >									
//	    < PI_YU_ROMA ; Line_3682 ; eu8QC3HoMbR3816630rR5xJ35DcxYE0OYyJB07w8b0ei3Y327 ; 20171122 ; subDT >									
//	        < ondM94Fj0pbk9M6pu41jij1X7V80g0V3IhG59Bo74o34YrTHpJJ3I9cnav6T1716 >									
//	        < 3RkI875W5zohJs4rh15RgLShk2uHNIzLnQDUwE6U2Kj3wREDvsdXEDrL3i5I4RPU >									
//	        < u =="0.000000000000000001" ; [ 000036445358215.000000000000000000 ; 000036452002591.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D93B340DD9455783 >									
//	    < PI_YU_ROMA ; Line_3683 ; tnhv6KxiWmt645vn4n6STjpAmSpVM203J1f661M06T1WgGLO0 ; 20171122 ; subDT >									
//	        < 8h4i49rNP4RvT8p1AduQtnFTK4ENyLA5GR4wNo8iAO6Jjrx32ipKnkLuHG77KVSF >									
//	        < cF52vG7rgsQKYDDr1qH9hpR9382zs2LA6U0K13K14fusn22bW290SN8r6gFfJONW >									
//	        < u =="0.000000000000000001" ; [ 000036452002591.000000000000000000 ; 000036459336402.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9455783D9508848 >									
//	    < PI_YU_ROMA ; Line_3684 ; 24bRp83W4dR17HhhdmL90OsNaPFOL10VgB5693H5HDV5NOB1P ; 20171122 ; subDT >									
//	        < 0UC7K2A49kQp6UB8P793uv0HDJB0C3M4HVO3UEEU01qX8Asq24BJbJdw37oF51dR >									
//	        < FW40C9W2qZ9wuw1ZvoYyK57Xjcl3PVqcdWQ092DpVl8j33zD75qw2ejlOrIGsTM5 >									
//	        < u =="0.000000000000000001" ; [ 000036459336402.000000000000000000 ; 000036465620760.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9508848D95A1F1C >									
//	    < PI_YU_ROMA ; Line_3685 ; 3cVmIqs0TJSOGM1MIQ3u7OoxJdgy2nBq5TnO7nTfn936wQ859 ; 20171122 ; subDT >									
//	        < 4WI29m112O40wGBb11x80aAjsptYVDS9FI47aX8z2xBTTQ4VhWJkTnGI9P1pEA0E >									
//	        < YRy27Pr4sheJ4bFUL77OP29uaZJXX5BIeCKDL0492i7DIWjrxK7vcTqNZ1DF05Ca >									
//	        < u =="0.000000000000000001" ; [ 000036465620760.000000000000000000 ; 000036471885167.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D95A1F1CD963AE24 >									
//	    < PI_YU_ROMA ; Line_3686 ; 93F0esoHR11x2Qi1pPfEjm678r13KNqx2xTuUZIw48soIYrrk ; 20171122 ; subDT >									
//	        < 8VPVQWVFChl11Gd3Xak22Bmz5AV5k9Odni0AB76cjPx9X1Dvj6uhCH86LwpnM7b0 >									
//	        < f1EKy3IpfG2x5y03LAd4CYf7L6h8f85fXBbIyH64k03tMr51a6GByy89iNKXM6B0 >									
//	        < u =="0.000000000000000001" ; [ 000036471885167.000000000000000000 ; 000036479423271.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D963AE24D96F2EB7 >									
//	    < PI_YU_ROMA ; Line_3687 ; 8690m08vK2rX3bx5lZiRK3RS7UixT4yzfWgSuqEqWi95z8Dm2 ; 20171122 ; subDT >									
//	        < V0SJZq2hL034g90JW775y7KE7Cri8Sl6fLG2wud88D0029n1I3977ItI4K5aUHo4 >									
//	        < O4B78X09Xe4st1O71Fcmr4p61018Nw21RYV92S5A48BZDTBkY5XdltNis0p8nAF2 >									
//	        < u =="0.000000000000000001" ; [ 000036479423271.000000000000000000 ; 000036491821405.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D96F2EB7D98219BC >									
//	    < PI_YU_ROMA ; Line_3688 ; hRQqc3P1ZI6zkiFiuCPP0s65QjQb467J94vNC072gUrgXR0dD ; 20171122 ; subDT >									
//	        < 6S0Va0YW9ZcvFPzIm4u7wk7HENKvVRfRCPBi9utQTypqZaj3nwHV90H39WD685x0 >									
//	        < GH9SWkuETS1LZ250pwJXm351mT6Sa13aQHY84N3PEp8JepOttbVUDJEE47GPU1QS >									
//	        < u =="0.000000000000000001" ; [ 000036491821405.000000000000000000 ; 000036501494970.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D98219BCD990DC79 >									
//	    < PI_YU_ROMA ; Line_3689 ; lUK885Qzq3neQnTx5iRkF4lEmWVK00jlBgvE0O7D48x1NcN6k ; 20171122 ; subDT >									
//	        < 3vu6H66nbwZIjRmD99kN9AA1jT182JveXOWR6UuxQP24A0iKabe7ynFJp7eyKdx3 >									
//	        < 3LnNu9IJ1y9HvTf1p6oqfywml10o2FWsbssh0058809CN88Ud0kyFAAy9r13Wv70 >									
//	        < u =="0.000000000000000001" ; [ 000036501494970.000000000000000000 ; 000036511699970.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D990DC79D9A06ECD >									
//	    < PI_YU_ROMA ; Line_3690 ; Ei7f7J872E6SM5oNcyC97S8HgceKm4Gz9quyg8pnDwPdm3GE7 ; 20171122 ; subDT >									
//	        < 99BzN4zxT8lSF6LUC1m9qxB00X3fRzhhbL868Oi0qqU46Y9ZMD5z5p1rRF2Voo91 >									
//	        < 19ZgPxV4883893lsZAO2HPNM4CAzdQV2hdi4PnkAX47FR7FOz84kJvY9DZzAwU06 >									
//	        < u =="0.000000000000000001" ; [ 000036511699970.000000000000000000 ; 000036522554185.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9A06ECDD9B0FEBA >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3691 à 3700									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3691 ; HnV0b9W4Tqwf2Z1EY4vFZE7pkLY0ddjs8J0bOrBvX7cYEpYFp ; 20171122 ; subDT >									
//	        < 5R1N18973n9n596EQ26v1ck6exmiufK2o7M19ha8FS2kdVmL9AZpnW3OQjf3Z4ib >									
//	        < k5IRqnHUbY8EPau8WrD4H4nJiPP0qsk40tDAG85PACBLHJf7T229p9u3i6uFdTDS >									
//	        < u =="0.000000000000000001" ; [ 000036522554185.000000000000000000 ; 000036537131454.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9B0FEBAD9C73CF9 >									
//	    < PI_YU_ROMA ; Line_3692 ; 4Y0u9VthomihD17997cU4I13qbeYTU80utxhr8Z44Fuj3Q0Tf ; 20171122 ; subDT >									
//	        < C6m0v5IUIBPb87Ikt10L9i410A6AF8c96kxu03XK9unI43FofWZiVL1W6sfFg8lm >									
//	        < 0eLL1cfUlu0w9aeeLgeAk8y939C109T8O4iV16YJmSt35ciSuTp2f3TZ6GjWl4FK >									
//	        < u =="0.000000000000000001" ; [ 000036537131454.000000000000000000 ; 000036548942321.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9C73CF9D9D94298 >									
//	    < PI_YU_ROMA ; Line_3693 ; ITedj10ocpEPm4KmSm40M2p25pwqz912TrZiqTl8t0r3CncWC ; 20171122 ; subDT >									
//	        < v7gT96kqFE9tAKE3s9G7hm3WvI17MsF3D1NiGVdhaJ14pkFFY7sB9iS0DSIgT0OU >									
//	        < 3Rgfa78De517JN1uQ7Oa7z74D2PGDNoIBf4aMk6R8vMAr00sZq1E3TfC905IKcH9 >									
//	        < u =="0.000000000000000001" ; [ 000036548942321.000000000000000000 ; 000036554141786.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9D94298D9E131A2 >									
//	    < PI_YU_ROMA ; Line_3694 ; NZb70fLRknxkntGqSpFoe95PW3R010mzGq0SxW2SY24Auknn9 ; 20171122 ; subDT >									
//	        < Jp6fi9PyZD389423wS0Mfd6N9GW8pH8qaw3zDmYnkaNfLSmb492oE19ws05VTFQx >									
//	        < 6Y6FbtB4sn6ZFfYeruX48mxjpE3iBYU1NFq7Z1EsJ5E1Y5Oi6XtkH5a042hLhek2 >									
//	        < u =="0.000000000000000001" ; [ 000036554141786.000000000000000000 ; 000036565364844.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9E131A2D9F251A4 >									
//	    < PI_YU_ROMA ; Line_3695 ; 1iHUCPTmRFiduydF2VKOp04aMWCp48SRrYss61q71Zg7770kb ; 20171122 ; subDT >									
//	        < MZo6F082Fuxr9yL5IF9p7C1uMz84udxNm334zs49hh41CRE6dwCAWk058Zld677G >									
//	        < YJp7VZpUWRAYi6EazmD0vAZcVThqTJK19z250cNXM32ye6dfKwa800l5J6jWuVH8 >									
//	        < u =="0.000000000000000001" ; [ 000036565364844.000000000000000000 ; 000036572558944.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9F251A4D9FD4BD6 >									
//	    < PI_YU_ROMA ; Line_3696 ; 41V2cMr7TcDvz17x1sx1w12YlGJ7Se52G9KwgvkecnEoRe2lC ; 20171122 ; subDT >									
//	        < y24bd1ZD2eCJr373O564yKrVyUfQZmPFTSPWKuP7QGew3r4Iq0D27r44zoknt909 >									
//	        < e00GA89h52i44Tv1F1fQSZXNUYZnI0nQ17ZQLx5jkf8yA6g55qGUmG7787Qu8aAo >									
//	        < u =="0.000000000000000001" ; [ 000036572558944.000000000000000000 ; 000036577679999.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000D9FD4BD6DA051C3F >									
//	    < PI_YU_ROMA ; Line_3697 ; Nfgr7zXu5W2O4sxBz4HdNs2122V44PGx9MZy7CV4aP3HTh4Tn ; 20171122 ; subDT >									
//	        < 0TqE2mP8d2De9Ko1hI5mv504elKZZ85s8SAW31AtXJjUEmJGaWqpR2NEQJiSKSb3 >									
//	        < 3rSzD86ojs3Ckf9C8HD9s5Lj1AauR8dgjUKrXJf6GgraTvG7V81id88KpDRC6vB7 >									
//	        < u =="0.000000000000000001" ; [ 000036577679999.000000000000000000 ; 000036583617967.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA051C3FDA0E2BC4 >									
//	    < PI_YU_ROMA ; Line_3698 ; N1dVYaLiledQkg8HfWJbVm8A0i37p2x8c8LnX09hcQg4AdrXN ; 20171122 ; subDT >									
//	        < mK8tgz4MO6BG0mkm5DOyhz2SsYWtB5jq2Q947w7P48GEh7mdfwdC7Z06z9ipWcBp >									
//	        < 9pjCrb24j49f5R0YKgZDSgN5EfK1129997rMGd937SW820R97y1uOM5AMitwiRr3 >									
//	        < u =="0.000000000000000001" ; [ 000036583617967.000000000000000000 ; 000036595048285.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA0E2BC4DA1F9CBC >									
//	    < PI_YU_ROMA ; Line_3699 ; 3oQI5Ke01hs6Ab0YdN8yU14J3c9sT72L324IhE2hOWfCpn8Zf ; 20171122 ; subDT >									
//	        < h10NfwU6y2U47Wyytu5KnmiB8AGZwLzve6vPGZ625gX7ZHrF5sxF4Q737c46pn92 >									
//	        < 5taEmWc6Oy6IpJ10320m02Yh3utWFF52k2Zwn5GeOvJNS490ywo600d2zL1Kq6E6 >									
//	        < u =="0.000000000000000001" ; [ 000036595048285.000000000000000000 ; 000036609079289.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA1F9CBCDA350598 >									
//	    < PI_YU_ROMA ; Line_3700 ; KTMaQSh2fnN5e0q9jF6on0H5qlI0jRe1830pjbxz5fd09DTNc ; 20171122 ; subDT >									
//	        < Ai94Gp0GSSY0zXq3KbpXs4a87sv85Q9gbNAvyiIy3TPrMseQdXJGknPH8jFg83us >									
//	        < O0t3VI96w5WpjvcT19B4226pTSSfT25qTkayJv0jk859sE5eFDU2QvS6ETTzr823 >									
//	        < u =="0.000000000000000001" ; [ 000036609079289.000000000000000000 ; 000036614608796.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA350598DA3D758F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3701 à 3710									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3701 ; Rm1PFC0aS05MIA1xA6r29mUdcHTio3ma6n3Rl51e728Rx2iWf ; 20171122 ; subDT >									
//	        < 98G65vHH533mGEFK6QA824XkXk15F94vJI8s1i2BtUr1JRS390e3uInZGJoiv58C >									
//	        < nWOwD2yRR4G9qftE6zxjK8y1XrgIY45280OBMwEsQ105kev6XKU2q0QlC3G6fuv9 >									
//	        < u =="0.000000000000000001" ; [ 000036614608796.000000000000000000 ; 000036627237965.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA3D758FDA50BAD4 >									
//	    < PI_YU_ROMA ; Line_3702 ; OcBL86EGDTvtr8urvQC22Byi2tuYTsy0Kn6FebbRhl15I2ASs ; 20171122 ; subDT >									
//	        < 6qA69TPsHrNW1UKdogKBr8nYTCXyWqsOoZwQyaZMXhOC6067V6G9D2pIf4l6RZfI >									
//	        < 36Yl9oM26uaTyI3GlfXWZ8U502c9RcCo5FQxeB4dOGFTmTMiyAU13iX5G3vD9O0O >									
//	        < u =="0.000000000000000001" ; [ 000036627237965.000000000000000000 ; 000036632672940.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA50BAD4DA5905DE >									
//	    < PI_YU_ROMA ; Line_3703 ; 2TaVIhfo0vjNXq09YrbC65Wn9leSJzE53vKBou6CV260u8ENm ; 20171122 ; subDT >									
//	        < zJBGmCUMc1k62a26e9int79g6yW3a31T1AEh747KUPv3584z1WV8p7Lb0xA368d9 >									
//	        < 6K1bc30PWVqm96R5fcKLtA68teek6DaLQhkC0TS04wkR8P4BW09POmMF7kp8ii8C >									
//	        < u =="0.000000000000000001" ; [ 000036632672940.000000000000000000 ; 000036642769393.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA5905DEDA686DCB >									
//	    < PI_YU_ROMA ; Line_3704 ; rxuAjtJ9730f5Ju8r17z9hIZl4doOpeMg4UoCgH2u8S798c7T ; 20171122 ; subDT >									
//	        < t81bAm5AALRJ5Hk805v5MXJN02dIGQz6qd5iV8siCROS6QO5i00PONOjsq0axdbq >									
//	        < Se1rUg28KmzvzG52K7528pmDi8DI9slx3SNqjC84N50TwrXBQy8nbZg0HEOqY1oc >									
//	        < u =="0.000000000000000001" ; [ 000036642769393.000000000000000000 ; 000036653716089.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA686DCBDA7921D8 >									
//	    < PI_YU_ROMA ; Line_3705 ; VJlw1cI4h9v1A0p02o1I08EWgS5Noas5rNnGAQm3RD1SB0ErS ; 20171122 ; subDT >									
//	        < Ay5hp4lG6Q5h5v3966rr3e74je7giQQSeC64qg5sVej277J1kP27I7CV9fwZ772l >									
//	        < Q29Cn4Q2KVZ4M7HZWps1dVbn1q9t0Z8Ey2X7NrDmX7V9IcboJaRw1187Gelc6uZB >									
//	        < u =="0.000000000000000001" ; [ 000036653716089.000000000000000000 ; 000036662568618.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA7921D8DA86A3DD >									
//	    < PI_YU_ROMA ; Line_3706 ; Lwwh7p2tPRgYENH27VfPaUO3dY5L04H28fswEB291jaRXS5Qr ; 20171122 ; subDT >									
//	        < 6Wrv0AzDoJ66RK6sDf2m0VPDj0kKE06E4X2g6ZoN9M5e8JJ891aP6EmQoRynxucc >									
//	        < Ct7W8dztUCh9bmrF4h389M9Kf91JTAZk71X08bFIkHFK8q70cx4baTVI73GX4RfD >									
//	        < u =="0.000000000000000001" ; [ 000036662568618.000000000000000000 ; 000036672160300.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA86A3DDDA95469E >									
//	    < PI_YU_ROMA ; Line_3707 ; 412MxGKu4in62QRG6WzB8Jyc239x63vxDok403T8s126b1pbE ; 20171122 ; subDT >									
//	        < xP4FoUwq38W96C837FpKBH8uA3L5VZHH659VeD9L0H68gmLv9bFo2R5sEQsI4530 >									
//	        < hedQ52DWdA143UGGA8g5zrn333q2IqAuBh1EA1SC3zEK98c4eBh9aCfdUY34o3N6 >									
//	        < u =="0.000000000000000001" ; [ 000036672160300.000000000000000000 ; 000036678153462.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA95469EDA9E6BB2 >									
//	    < PI_YU_ROMA ; Line_3708 ; GgbBl563j2uh570bah0Vm95WDZNQQf45Bq45wlQo217ZJ22Nb ; 20171122 ; subDT >									
//	        < IpcDxQTW8FZLBZlayU7nwX3uhivovL4Q9rI6Zd7gC1Xwb4a4FO2e1WA0Q4151ub4 >									
//	        < 9AG389194W8NI7CbgOmVMMp5448Pwl0kAI770vA39Re673IuYcc5thNN2Flaohfr >									
//	        < u =="0.000000000000000001" ; [ 000036678153462.000000000000000000 ; 000036689562830.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DA9E6BB2DAAFD47B >									
//	    < PI_YU_ROMA ; Line_3709 ; mwW9JU3VmT5Z1IVkySF77NmN5aK1xXG2Mb42iXJiG4pv3FgBv ; 20171122 ; subDT >									
//	        < IUtnN95perJfHq9pbbG6zxDlOE8BVwUbhpWEALk5pp18e3MmW6y55s183kr412rR >									
//	        < z3C01n53c6B50PYk5Qk525SI0DM0bsB278MRq9t0z4rJMT3zwg67DF672U97709z >									
//	        < u =="0.000000000000000001" ; [ 000036689562830.000000000000000000 ; 000036697005422.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DAAFD47BDABB2FBE >									
//	    < PI_YU_ROMA ; Line_3710 ; xh8rLx75jL9P3p68Ns0Y2TQy6qw9yFe7ODc4MwsJn9oSBV41X ; 20171122 ; subDT >									
//	        < hpplu1Ar2Z538PcyJUgqMe3m5VpbEQV069AfIqSDJN4mlA22hh34BEC01uA4F3sg >									
//	        < 5566ro4XVTU39En5um6I1ep8Z45b6P4UUd73m3015t9C0q0IOlboeaP58Ky0yip6 >									
//	        < u =="0.000000000000000001" ; [ 000036697005422.000000000000000000 ; 000036704553610.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DABB2FBEDAC6B441 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3711 à 3720									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3711 ; OdEroR209V8F2zM3x5400Z93Dhalo8dMCDukGmExNIQXB2DwN ; 20171122 ; subDT >									
//	        < rQzyaMN0Y2d9mV9fHawPsX6v7XSDNkUM9Y8xRc91s35M1U7uLXl63z5aIkZ7lP1l >									
//	        < 4Mf9X62mXJeL4ycAM9Oz9gi8tR6111BOQ9r4cOwpX5eo2M9897z8K30FluSUqC34 >									
//	        < u =="0.000000000000000001" ; [ 000036704553610.000000000000000000 ; 000036719098161.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DAC6B441DADCE5B8 >									
//	    < PI_YU_ROMA ; Line_3712 ; 1qbsxoRp9nXWYbK1Y3dD0NydDFy7KRV7vdv2d34gGirOX7U8m ; 20171122 ; subDT >									
//	        < HLDJOa3xtwh8UYRtiFuu3lwA4SosVEDMkX60f4D4q9g3kj8tbKbnWeJraIw27B53 >									
//	        < Gmj8y6Bi1xk77Ff39d4F5L0f2IV348BJY10J4WsVGj1ySdnCzFEXJdR5NAEeVlt7 >									
//	        < u =="0.000000000000000001" ; [ 000036719098161.000000000000000000 ; 000036725234502.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DADCE5B8DAE642BA >									
//	    < PI_YU_ROMA ; Line_3713 ; G64DDnTc51DMb76QNzvHKKH5c3edhH97n65g30jZ59Z9Clnv8 ; 20171122 ; subDT >									
//	        < DDa0kSV7vY2k106R0AnmNUMjT4mPBdH1HuF7b136O09bDNeXz99zcBNh3zQrdudI >									
//	        < XOz9t4zkT6SXnh7Ljy3j00egkBASkPo8dEPF21d8AQ9W2798PfKrZ9lml66P3dsU >									
//	        < u =="0.000000000000000001" ; [ 000036725234502.000000000000000000 ; 000036738181829.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DAE642BADAFA0446 >									
//	    < PI_YU_ROMA ; Line_3714 ; G4TmD3VH8iNv2YO4I5y9231z57dWG24od6yrbr93QZW81l1uG ; 20171122 ; subDT >									
//	        < 3X8bIPy687UKp509xMM41T4Y687M5nWF7guArPwd9m47Ym75XoX5b7naNx21QB06 >									
//	        < fU6TU5zh7R91893d5vUbovET1gVFkBC4ZbYRSG9APH4383K7OS725g09bc250zoE >									
//	        < u =="0.000000000000000001" ; [ 000036738181829.000000000000000000 ; 000036747991116.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DAFA0446DB08FC07 >									
//	    < PI_YU_ROMA ; Line_3715 ; rhhFxiKBJNe60p3b9MVWGOm2O846HXEt3603gHFyYF7D9Pfwj ; 20171122 ; subDT >									
//	        < 4pNDo19AoiNSL6y04F4TARC2t1w8t7G9qQzTA428sm7ml893O3sIaH81UD2a8zwQ >									
//	        < 7Ph452cg226I9h7TX5yTbu85kH6rMYoAxE6HuJVoNbFksRYs0HyuA4EtLG2IgbQe >									
//	        < u =="0.000000000000000001" ; [ 000036747991116.000000000000000000 ; 000036756869562.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB08FC07DB16882C >									
//	    < PI_YU_ROMA ; Line_3716 ; n5g57Fdi7Ob9341oU3B9uCnyVtS82Z0j0JETVXbAK0PWdmerY ; 20171122 ; subDT >									
//	        < oW9jVYnFgHs6v95w3ZGdoG1GW9D5Qw7VXm9fzdOnUtaM6980KlL71e4f0Hu1lsb2 >									
//	        < bvlKTha8kb3Vm6r2Bun5wssS1T5v3522nhPo993907uq8Pgebp3wLKAT1SB14C38 >									
//	        < u =="0.000000000000000001" ; [ 000036756869562.000000000000000000 ; 000036770033785.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB16882CDB2A9E72 >									
//	    < PI_YU_ROMA ; Line_3717 ; z7J3x1Wj1G8Qh61Tf2SuCx1E7P83VW0Gp739b8l5Gh47S9bbz ; 20171122 ; subDT >									
//	        < 6OxB4w659mc9OGR5KNdV5HAeD20OA3Y0f7HLW6CpRYE8ho34fU3H8tss3ZgvzXQd >									
//	        < lM5io156GLn2vdb893BU8U1D3E1SI8OUHyu9Rm5qqS281eR0MmiiB03g7a43HDx7 >									
//	        < u =="0.000000000000000001" ; [ 000036770033785.000000000000000000 ; 000036779687469.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB2A9E72DB39596A >									
//	    < PI_YU_ROMA ; Line_3718 ; n9VBX4Twd8834Sc21sYAGxVChe02tJi1JmAe8L6Wgg7xB9X5R ; 20171122 ; subDT >									
//	        < 3j7U1qV3BbiHmp14CY0Aq4J6G479qJTn2fK2Cx2d11kWzy8GTII4DhSBJh700Ypt >									
//	        < 3lXe4BtJfzcrFlb53Lx036rsayvY0e635J9dyPrCK6i53i5924a8TZ6E3HoZdZ8h >									
//	        < u =="0.000000000000000001" ; [ 000036779687469.000000000000000000 ; 000036788131292.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB39596ADB463BC9 >									
//	    < PI_YU_ROMA ; Line_3719 ; NOJw06f9FGv2TrGBXQ88Q52kkqoLMXN677760CzM9umqAfxn8 ; 20171122 ; subDT >									
//	        < duk5NQw73MCSoNQ9zMw4J4V1FDoKJ2B7yKa6dg96ucBkYbMA8g71o2FCTim9dz4e >									
//	        < 27q84gxLUOnzq67Z58m9zdgh34fF9J4hbcKg2f29aJb4u6v54DgVj2dJG7DOynK0 >									
//	        < u =="0.000000000000000001" ; [ 000036788131292.000000000000000000 ; 000036799737380.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB463BC9DB57F16A >									
//	    < PI_YU_ROMA ; Line_3720 ; u44XtaJk6nbKx0e9cjelLVp1Yj6ky7872s2RPSJ1fL8JEV4FR ; 20171122 ; subDT >									
//	        < oQ986wUv7t0Oj5wzrXWAUqHc8GauRCfr63lP6P6ke8e0NWp8tVXRbHTpL80f7j3Y >									
//	        < H0WCFcUE9QIn1a526kh9tI32An6iI1RlDTn3I9d8SOyE6Umt4IErjtAOU5vImU3g >									
//	        < u =="0.000000000000000001" ; [ 000036799737380.000000000000000000 ; 000036813413660.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB57F16ADB6CCFB6 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3721 à 3730									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3721 ; p9o5R1ZQ71uJ8Gk4bLF5t4YN0sJs0dkHx2UOU6PQJReuN7X4C ; 20171122 ; subDT >									
//	        < OdYe3Xbj2iwl4FC5SpVal627r7m2XXn6qho2v7I0gDrJjehk8A832aJ5t18oXuRl >									
//	        < dgn99uAWfau6VW1v591l45B6RH6mGe6M0dP1oE0B9gaANQ67a3QW3jq6SPh0uoJw >									
//	        < u =="0.000000000000000001" ; [ 000036813413660.000000000000000000 ; 000036826702286.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB6CCFB6DB811694 >									
//	    < PI_YU_ROMA ; Line_3722 ; QZ1ZoE5YF9VfzWWLRtw2P485PpS5ewuBpgzIV7CB74eKiQO62 ; 20171122 ; subDT >									
//	        < z6RK5W1C4ugtHDqNx8Sd97QXZTG77KD8O9yVTMch6LSVb9dB7iwgj0j8iG49Jb1J >									
//	        < 7Egfk7JYC6i0NuKzl429H3r9lv48AX04CiltSH97CZ3e1B882Dv5b6rKv1ND11x1 >									
//	        < u =="0.000000000000000001" ; [ 000036826702286.000000000000000000 ; 000036838119402.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB811694DB928264 >									
//	    < PI_YU_ROMA ; Line_3723 ; k411Vt1ShYWJgnRI5BHN19zoHO91dq5L9fy8H1k4Wn4f0N50f ; 20171122 ; subDT >									
//	        < e6C1JO6Z2Rt21a3aV7I8F9087Z2gQ34BV8aA3UEO8Nq3l2n79249CBg18sRugRaB >									
//	        < UK98k094OMxKs85RzxpKPz964g2v06yyNcI6V1NLl5Nwx4C2xj818d26Z6iZS8zM >									
//	        < u =="0.000000000000000001" ; [ 000036838119402.000000000000000000 ; 000036848889179.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DB928264DBA2F155 >									
//	    < PI_YU_ROMA ; Line_3724 ; NFWsM0KjM5YEHUVe7YlfSkq96044c0v12txBYDns1cQUOBRfq ; 20171122 ; subDT >									
//	        < a4wwJC010P64WvSDpNnU8L0U9iY154LKX2qP7C7s24Cu7EV7gQOb5cz0yZZzVP53 >									
//	        < itg6HGQ1ULrBzr2HEf4UV4294HaB2B8ol7VPX6Px9i3TSR4qBll2P6YW3ZNlYGce >									
//	        < u =="0.000000000000000001" ; [ 000036848889179.000000000000000000 ; 000036859261229.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DBA2F155DBB2C4EA >									
//	    < PI_YU_ROMA ; Line_3725 ; NTfeOVKKUaq06Ig2Rf618An35X0VQrKErbo73iN90smMGE6B6 ; 20171122 ; subDT >									
//	        < g547C9h2GyE3s8pPbe1RX2W6nbK7YbK6QdGNItuts8PfZ2zFF6b9vv1143w83904 >									
//	        < rb5VY2hklLXa9Eer4lXB3pSpBPVPsh9UmK0L3QR0VZBTtrO9qsL93cZQZYdpnRMG >									
//	        < u =="0.000000000000000001" ; [ 000036859261229.000000000000000000 ; 000036869659591.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DBB2C4EADBC2A2C7 >									
//	    < PI_YU_ROMA ; Line_3726 ; 9l32p3Kt6RkEM54tRU02fgb594t8OiRCjnc63UuKcrITKF1Q3 ; 20171122 ; subDT >									
//	        < aavt7LcuWS7CtUs8e6QSb34zGPf0Z98z16IptB4y46Qx56LCI08833AN9td6adIp >									
//	        < Zj12F5FXnI3naehE6693Vh1l9S0JP171gS7WkN0NXe0f1VVkwFVkDL0M6hi69V5K >									
//	        < u =="0.000000000000000001" ; [ 000036869659591.000000000000000000 ; 000036879586623.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DBC2A2C7DBD1C886 >									
//	    < PI_YU_ROMA ; Line_3727 ; x44kD5181rTVH0579yCx5buoOG7EoX614Xmz5r02Mr26m65o3 ; 20171122 ; subDT >									
//	        < ZvwlgiaHT5xfEJtW7Xs09Br6KHI6k0y0Xc7AO9ot0eV474gHZPq0or4u8lwlzHWR >									
//	        < 1rt4GL583WhXC20wa37Ffc59QNxTA6Nz8wvQ8VKDtC7BQI7xJB6N65Sw2rdmO66F >									
//	        < u =="0.000000000000000001" ; [ 000036879586623.000000000000000000 ; 000036893254622.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DBD1C886DBE6A396 >									
//	    < PI_YU_ROMA ; Line_3728 ; N7sm7fOJed4GCUBwOTfu5G384c85H2OJWSE59HROPxG4z4O4c ; 20171122 ; subDT >									
//	        < r39I5p57aY1SqVT25km0bflPkW60Lkh1k20vQ8285A17J2HFUcvg6CGFieq08yf7 >									
//	        < CquO7uTJp8TrF7oR9Ov9EV7C64g9iPoc58Zs29Q2Ey3JCS09Eyi4zNcQjRv6gwN7 >									
//	        < u =="0.000000000000000001" ; [ 000036893254622.000000000000000000 ; 000036903530848.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DBE6A396DBF651BC >									
//	    < PI_YU_ROMA ; Line_3729 ; i5ZjD1Qy96tvqSlHJ97FZ48VZkmy0dleeWE944YFhEs5GBdRP ; 20171122 ; subDT >									
//	        < 8gXX0FiCDu7DpsHy94cRzMutcEt57Fh92WPy3LM9IJ09J31y7gff8LG1Y478XP2a >									
//	        < 2M9ZoOx25Pf14t36kT1Oc3Fmjflk39008mkf4glksa0r72mOc5op58MSBcYnGVLq >									
//	        < u =="0.000000000000000001" ; [ 000036903530848.000000000000000000 ; 000036913152206.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DBF651BCDC050014 >									
//	    < PI_YU_ROMA ; Line_3730 ; gKb1Ei3x8dRO01qg7665onG5L63d6RPD8ApCF0lcOtq9bNGaD ; 20171122 ; subDT >									
//	        < CG80JCwld285KlE4a8P9k05l0a844ibEQO1zI2rzyega0e1z04CQ5eADfW4N3UAC >									
//	        < UX8n8g4co00xjE3EvhJOc2Ahx1YpQYD2T16G8hM2jmZQ3hlAuMOb657D5XO2F2hp >									
//	        < u =="0.000000000000000001" ; [ 000036913152206.000000000000000000 ; 000036919100785.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC050014DC0E13BE >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3731 à 3740									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3731 ; 7046T12wy0KX4qMzPS5GtGnv7Hg6KsoPbYlwQVbLuc21fh3Z2 ; 20171122 ; subDT >									
//	        < BKYL9E47Yfq8f21ApQHihH9190O3H3cQ0ZwaYdttB8xpid5G5RB5KEHFqM08553z >									
//	        < Kgz442Vr68DMg9xNPO6Jp0u0hUtF2bFs0rpW7GS5rho30pI6xB7TJTAg57I3WdCb >									
//	        < u =="0.000000000000000001" ; [ 000036919100785.000000000000000000 ; 000036926828560.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC0E13BEDC19DE68 >									
//	    < PI_YU_ROMA ; Line_3732 ; t8Q005JVjY51H489BqMWKZgU42mlzX9ttYT4qI8hl3mUl3cJY ; 20171122 ; subDT >									
//	        < BAd6cjIBPSg26mAq7sAh9oKCT9y7He82426i1A5ua63cu9Skn27B2ho2W9sMx130 >									
//	        < F4871nNjfDMNg4msXJm0YgXe36Z048J4bIRUd8WOI64E0I8g0fdRZPTNmIzYzLId >									
//	        < u =="0.000000000000000001" ; [ 000036926828560.000000000000000000 ; 000036935437008.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC19DE68DC270114 >									
//	    < PI_YU_ROMA ; Line_3733 ; ct32Ck6WV8N7Ao3fvTQ10hw6gx29rpH55u5051yP31Fv8srfR ; 20171122 ; subDT >									
//	        < 1B8eqm830D9IBdoTR557SBHu9TVkda30B3tpoTdzOan1p8mRMz1XnZvP116iAESm >									
//	        < UVgRRhug89Ie4Prd7l8tc24Cg4APVWh8xYz53e4xx92nyvc8j8975o38e7859G4L >									
//	        < u =="0.000000000000000001" ; [ 000036935437008.000000000000000000 ; 000036943869608.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC270114DC33DF10 >									
//	    < PI_YU_ROMA ; Line_3734 ; d72JqfK5R1C6WsXe5DteZ12p7S9D5px4Es6XIF19257fK7rwa ; 20171122 ; subDT >									
//	        < iH9xzl3MJ4mUG8PKw204R9jDkJkOYoQM766xiJ7IyG8IpvvY6yQ8Nv3T62C7rMZR >									
//	        < Q31CC07Y6Mvc3RUYDdqu2Ydb419T8Zc6uRc2Lke15UK8b2D4hXhCSq6OpHkY1ol4 >									
//	        < u =="0.000000000000000001" ; [ 000036943869608.000000000000000000 ; 000036955231158.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC33DF10DC45352B >									
//	    < PI_YU_ROMA ; Line_3735 ; 2X4Gx9ftdjJzPT34dP34TghM3w8Wt1aXQlZP9gE2ZFpnYtS42 ; 20171122 ; subDT >									
//	        < BK8ikDkod26B1614Ra8Yhuc5lih8jWHMO08OrnX0sraot1J4kM86N028fRXcVflH >									
//	        < 4xdcf51qHDs75rS7KXC4gxlOUxSc5k1UYDJYkItB98q8VN588xDwy20t6gOM5kC1 >									
//	        < u =="0.000000000000000001" ; [ 000036955231158.000000000000000000 ; 000036964686653.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC45352BDC53A2B9 >									
//	    < PI_YU_ROMA ; Line_3736 ; 3Ndn6zH12g4N91L9T26C186KW0ZH4Zur79U95ki9f8Y709Ivp ; 20171122 ; subDT >									
//	        < fv21G5t6YCg07y0o3gmX9rwz542E5F71gUytTG62dI2ZF1aXu3kG5848u8je3A0b >									
//	        < IhonyFDKROQ3q26Oap0Ym2FOv7ohQkS40NC3BX4WZCFAS9L8IFWNKN107ArZXt9N >									
//	        < u =="0.000000000000000001" ; [ 000036964686653.000000000000000000 ; 000036972172532.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC53A2B9DC5F0EE5 >									
//	    < PI_YU_ROMA ; Line_3737 ; p6N9lvVR4tz3pT2oelKJq06uWilE7nrzqvQebEtcWfws77do3 ; 20171122 ; subDT >									
//	        < J94NdS55YpRh3140uQ0B8Ff1H9KEPWS5OgetKpd6o39j9C4LxS6oBzxLc8a5BRdA >									
//	        < nJSuPoIarTp19Y9741IOP1k0bsIC64mHA2061FX6O17uF4DFphXOE34xm3Ui6fLf >									
//	        < u =="0.000000000000000001" ; [ 000036972172532.000000000000000000 ; 000036981294194.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC5F0EE5DC6CFA0B >									
//	    < PI_YU_ROMA ; Line_3738 ; AHUySEvgXZRdg8yGUt2YQ4Mxf2QTqbkB1R8026omB3KPjBzGD ; 20171122 ; subDT >									
//	        < 9mbSO329I84NaQb1j0JA1eU17k83ukrjbJvQ7Z9dxJC880LYprP3KsM1tsF3EY6L >									
//	        < mw2T83472E6sjUU8NIdCxQKtJ3674G096wEoEqnJXuHTc0SQXUBf7LlFKhYkt4Nv >									
//	        < u =="0.000000000000000001" ; [ 000036981294194.000000000000000000 ; 000036989842980.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC6CFA0BDC7A056A >									
//	    < PI_YU_ROMA ; Line_3739 ; rROrsNS515V928YSGChi5W0Ks6S85RuD1KrIZ146437KSGNGk ; 20171122 ; subDT >									
//	        < 1drSD81v8i3y57Ye8eIE73S7Lkk59ZlA11PZn0G87JGs0xURE1tbM7yBZ8FSpwKU >									
//	        < QO222qBLpj8XYjVLajydCL5sFzPULdYlbXNQ9L4KxY5pS198TS7vpZWRQp6O6f8S >									
//	        < u =="0.000000000000000001" ; [ 000036989842980.000000000000000000 ; 000037002777651.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC7A056ADC8DC205 >									
//	    < PI_YU_ROMA ; Line_3740 ; m7jua7i6oAxOiW6sd2d21srrB3D7v4h3kjRh55SKKGtrS533s ; 20171122 ; subDT >									
//	        < 7yAAg45T3KvxSTf4L0jL8O7xz2VsfZUnVlAY2R6l4XKxiv0I27DUKtnIzp7If5R8 >									
//	        < K4LgYFUp1fy81Logqs3qQo0E5IBc8eLe752F883AkrhKuD2UVM40z4eZ6sm86RuX >									
//	        < u =="0.000000000000000001" ; [ 000037002777651.000000000000000000 ; 000037013780012.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC8DC205DC9E8BD1 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3741 à 3750									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3741 ; vQS6Y8iwvPlLSEsTT92zJloD2XhsV1T515w50ss3IV3LK23aT ; 20171122 ; subDT >									
//	        < j22XwgQXfp7Yy3r3m2Q3o2G87gM2Gqv4BBt69X7KTo74Yn5rWH2Re7bSM8pDCZjw >									
//	        < 1lUCiFQEw8VXQIKiMAd9x0lNvM66GR4z1JA467BD2Woz48rgCt8d6LIM8w0275yS >									
//	        < u =="0.000000000000000001" ; [ 000037013780012.000000000000000000 ; 000037021102769.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DC9E8BD1DCA9B844 >									
//	    < PI_YU_ROMA ; Line_3742 ; ltjOqE6bw88C0kldTGyoR1yr1HHEFtYw18cgv139hEq8W0q3b ; 20171122 ; subDT >									
//	        < 54mPpXUOJ1RcZ7h570IGS68f6GFvg40SvUCJJ1505ah0MDS821Nuw1mCKqs3s1r7 >									
//	        < J8erOq1x07csZ2j8fDrCiu7zRn44i2HYt4u2kTAOxi9460NkZ67qwYd3721PqcvW >									
//	        < u =="0.000000000000000001" ; [ 000037021102769.000000000000000000 ; 000037027805018.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DCA9B844DCB3F255 >									
//	    < PI_YU_ROMA ; Line_3743 ; x02HUNPUZFcW5J3c54AXcyX1zxe8qQ83Kt7J5y3tG7WDg17nh ; 20171122 ; subDT >									
//	        < DjwxG33jge027tg9Ulvtf8eR1k1wXz2koV78OMIp8UENdNRoNeyfr9Vob0Slk9go >									
//	        < 5djuJG6qkxP7JG28Fc6x3y99x63wAmH4sJaWgyUvQOJ19j6N20662UqovdcAJ0uG >									
//	        < u =="0.000000000000000001" ; [ 000037027805018.000000000000000000 ; 000037038865394.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DCB3F255DCC4D2CB >									
//	    < PI_YU_ROMA ; Line_3744 ; KzWgz9OoTHrZLaX47LMzlC62Z3ABf9TUG2JBWP16mU2XebBaC ; 20171122 ; subDT >									
//	        < Dsid42xteNfqyD9eRcxQHokg35H376HB0IJ849gAMUJxTqV7k91d1xVYnwbkKjQK >									
//	        < THMihDmUh5ue24BwpFcbm6gH9WIhupCaRq7di9k3z0n07jGi57n7YS1fE4wXx7wE >									
//	        < u =="0.000000000000000001" ; [ 000037038865394.000000000000000000 ; 000037053463349.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DCC4D2CBDCDB191E >									
//	    < PI_YU_ROMA ; Line_3745 ; ENjC2qRkh5uqPnwt16fgnk2aIir12XELic92fh5k08lG9z2Q3 ; 20171122 ; subDT >									
//	        < T82N3BNM546kFr8rd450QmMB761dSJb0L2dM3vfpBsyT1wq8c7w490nuk1pqn9Hl >									
//	        < 5Ebw9H448IP2V3J7W2V6Mf7gE3r2FG2bB6ouR5C9N84dNHgj0UK8PBhWK2S2KVLd >									
//	        < u =="0.000000000000000001" ; [ 000037053463349.000000000000000000 ; 000037059602520.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DCDB191EDCE4773C >									
//	    < PI_YU_ROMA ; Line_3746 ; 7dzN0N24vb5B9cYwosOBY70J4f5MZ280RsvR13J46m8mIncIv ; 20171122 ; subDT >									
//	        < 34vptPSz45i14Gv1TaWW7nenGR6ie42zNL5Xpw0rGIVRZwn1LHe4YdQ54X6lnUop >									
//	        < bs47bFZ3q6ANsdkxF8LnRnqN46QRFu3xtFHZNmEH44t0ZOnOSo82ou048l499kuO >									
//	        < u =="0.000000000000000001" ; [ 000037059602520.000000000000000000 ; 000037068427368.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DCE4773CDCF1EE70 >									
//	    < PI_YU_ROMA ; Line_3747 ; F06fm6Jb59Ep1sxUxXzjJhQWaLrxSqrFEIYSc2VFm41A9jYC0 ; 20171122 ; subDT >									
//	        < SId72IQVG27wNvSi6XV15333Dsv1JCq3Bbhah6U82z75303kIu0EVTvFCVJ8i4nf >									
//	        < Sq42c3YtrCnpFnI4x04UybIVGFwO21f1iZ514kL4obls9DFu7T5JZpSp0P2bVl77 >									
//	        < u =="0.000000000000000001" ; [ 000037068427368.000000000000000000 ; 000037081157279.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DCF1EE70DD055B0F >									
//	    < PI_YU_ROMA ; Line_3748 ; 6v1p5dcpoUJtKqm6xElT7a56P2pgy1mj0z3KEAxJKlFEQv088 ; 20171122 ; subDT >									
//	        < l4K8rIvoC1S3Ax0279L4H6pxF1gktZ986bRojjTT17akD6RPSuuT9Y05cbpM1V9L >									
//	        < Ltm613qAoXslHOms9775l5Aqey3Eyp24YXT49kis3Hnu8C2Y9P7z7i55cjY8A3cU >									
//	        < u =="0.000000000000000001" ; [ 000037081157279.000000000000000000 ; 000037091481975.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD055B0FDD151C25 >									
//	    < PI_YU_ROMA ; Line_3749 ; 9VHlEqFpY4tPqj7fBjaTQUF4wr6D4LHQgPUsWaKf7HoaawKsP ; 20171122 ; subDT >									
//	        < OhzS4I9wM7Rs5Q71CcmYQtkBcc3nS3E8rdNQA2kxJw2C04IEwmxmTG18s9fHgz3D >									
//	        < JndXUYsg7xWtelOPG9lF9rxS4UNRsI5V2Sx83BHsDU47NBR0625lkS1QmERpEB58 >									
//	        < u =="0.000000000000000001" ; [ 000037091481975.000000000000000000 ; 000037104008205.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD151C25DD283934 >									
//	    < PI_YU_ROMA ; Line_3750 ; 6FnjO1ueXQ2T04SaO7xxu4YOu31j5Ag0V1Qe11hgK4nivQntL ; 20171122 ; subDT >									
//	        < klhqGdL8O6K02C7BN32Ofda8JejEPzYb91CXx9MlY5AZI5f5K9Qg2hvZhUf7MotA >									
//	        < lsCOkX0O4vQ0pA7yX4N8RW9190N5Y0hcbooj6bU39v3s2S40690s602UKLjm1TBo >									
//	        < u =="0.000000000000000001" ; [ 000037104008205.000000000000000000 ; 000037112800312.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD283934DD35A39F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3751 à 3760									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3751 ; 5UlUB2P02Bh7uo4n3P3FFQKtGffiAh46aPfXz17CvdxJM554X ; 20171122 ; subDT >									
//	        < 1o3QFq7j12AIuiOpdz9U83SUtqsl6m3EatezWsNAl48yS3XyANR3Hs94dw45rS4V >									
//	        < UZjXy5nrdO61KgL6E5IsB65i2I2H3eUg03lPV6m096IrvrYn4wCT171fSeJ8k1gI >									
//	        < u =="0.000000000000000001" ; [ 000037112800312.000000000000000000 ; 000037123847029.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD35A39FDD467EBE >									
//	    < PI_YU_ROMA ; Line_3752 ; xCV0F98DFuO72jn77LRM63hA4u0xl5hHdDyJDdCIGmb8b31eg ; 20171122 ; subDT >									
//	        < Yq15IrBmn9hq7x5tdvRlemRaSu8l3kt9UjnV2iXM13F2pWl2dD5Ho39m6v90fw2z >									
//	        < 2foJvW6br4AwluwegLpy75ybuVVVhvKK21P1Qz0P2Anc4dG2pfdmC7evs4uiLQEK >									
//	        < u =="0.000000000000000001" ; [ 000037123847029.000000000000000000 ; 000037137470511.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD467EBEDD5B486B >									
//	    < PI_YU_ROMA ; Line_3753 ; NSeNjt7os3Zm6SfC8TX6L5Gok30z8q5i6P0jyWbg332digj4x ; 20171122 ; subDT >									
//	        < rGixnfw5uI190yvJ9w9BXwiuD47336894iSdqk14DKRu7Ht0d4571zRFe8NuSKp8 >									
//	        < 7otXX0Y8Iy8VN7ZSIEZd3srAGEeL1U6AcdKco4P4eq80697hKufK70u92erLMQNW >									
//	        < u =="0.000000000000000001" ; [ 000037137470511.000000000000000000 ; 000037142819865.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD5B486BDD637202 >									
//	    < PI_YU_ROMA ; Line_3754 ; ZlOi8BU2H54Y8DI1qvL0WR4p63JorJPJ5qans0t6wf8Fh596B ; 20171122 ; subDT >									
//	        < P168hD3VJ8bRDJ86Z36YHZLXIWN7KWxCeZZLg6E50pHenIa3YOH08rQy8Qy60w2f >									
//	        < AF4pHsio5LGhN1Q0zHt957aTWD9da7c2Kuvp685XSPA7az84ttw5w7JhBMT02O9F >									
//	        < u =="0.000000000000000001" ; [ 000037142819865.000000000000000000 ; 000037153130094.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD637202DD732D71 >									
//	    < PI_YU_ROMA ; Line_3755 ; x83oNke2T4Xhd9t83iH5QPSxcJ5ND9F3J7XO6w922ZF4Z16L0 ; 20171122 ; subDT >									
//	        < 11bgGY6O8c7IC5LYZdwTFjw7gLH2Beer8nGc12k88U54xZ5xyf6p6S20cBBIkub6 >									
//	        < Dc512OR7hK0q5Mr3m2Tlw53kP3p3IemgxuW3AYL004w75EB0h9ZtyK63iE47thFa >									
//	        < u =="0.000000000000000001" ; [ 000037153130094.000000000000000000 ; 000037163340557.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD732D71DD82C1E7 >									
//	    < PI_YU_ROMA ; Line_3756 ; M7jJGmV9uZaZKRhavD4skpn4RBm6BlgcC6be5HjGLXwUWL8P8 ; 20171122 ; subDT >									
//	        < J5L7dy0K8pq8897ndAyz917vG06wRoDy2K3kDFmccpCt1I5b44xkqp74uI5W6FZv >									
//	        < 789FlRwSiCdfqzsDJP4wA2KxvTdn9X7aj0dYM3g5ZI7jxBBQ9RcX7zTfNjEn6d2g >									
//	        < u =="0.000000000000000001" ; [ 000037163340557.000000000000000000 ; 000037170600002.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD82C1E7DD8DD5A0 >									
//	    < PI_YU_ROMA ; Line_3757 ; d5ng97hqx42IfFIzZ4WpGnBN7t42P9HDdK9NXvYNRF5TUKfp4 ; 20171122 ; subDT >									
//	        < wKpiMl7D8F079s7qvxCn86ZLui3WK75JgfhpoT4dvtzyU60SmOc2gA00z1imJ46Y >									
//	        < X10LZzAE1APLO8298sS6dZsc5MOPHt5opf2a06ckhH2bKTv5Y4O3Hb98ofGvP8dn >									
//	        < u =="0.000000000000000001" ; [ 000037170600002.000000000000000000 ; 000037184292052.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DD8DD5A0DDA2BA15 >									
//	    < PI_YU_ROMA ; Line_3758 ; 3pbV7Vp4142nr04yLL7Ot446Mz4BC9BS53DvO1897D0dLgc4N ; 20171122 ; subDT >									
//	        < g01BQ7t9ohk77NcSdp9m1R4br37r9PwGp5Mm4b9U6iM5Z6CiDUjH695FlZOlUYvA >									
//	        < 17yt5Ho2vpHTws815dCQUK7bXte3JHmN0OSLm2869t8kxGEWH2bVEdeT8gsrOEer >									
//	        < u =="0.000000000000000001" ; [ 000037184292052.000000000000000000 ; 000037198366423.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DDA2BA15DDB833E2 >									
//	    < PI_YU_ROMA ; Line_3759 ; S2YWuVB1q7hfNeX0M3dZdCXAKDOrJPp23SJKU25zbp4fA1ajm ; 20171122 ; subDT >									
//	        < 34Ngo0JW97Yi4BN2EVlsTdWU962w2VcenrttOnZFk2Xsg5UX4v273a8k3svac6HI >									
//	        < rgj06NAcpH3p63WmZt95pcBCDpr4dY6g1t1AzLkvRF3vf6Ebrc00Suf7Iex07XZ5 >									
//	        < u =="0.000000000000000001" ; [ 000037198366423.000000000000000000 ; 000037210718146.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DDB833E2DDCB0CC6 >									
//	    < PI_YU_ROMA ; Line_3760 ; u2jF3hRFjpU4W2bwcD25m30N0C2ur8L0r32oV78r1A4s4z275 ; 20171122 ; subDT >									
//	        < mlBvKzBXCCU221U1dI7DUNuh9X0DdPT0KOOd9OBQKul95swIWt2ggOaUlkyRRU3r >									
//	        < JGrHjDwF0eLJLdU6yg3Jg5ZpyW8mNtTD4VBmP0y9Z85Q63qOnL402szXrdIk4w1q >									
//	        < u =="0.000000000000000001" ; [ 000037210718146.000000000000000000 ; 000037216559340.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DDCB0CC6DDD3F67E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3761 à 3770									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3761 ; PpUO1Si9CW08j2FE2SB9z2974EcBAOdP547RWfAJSnM8gZ7CA ; 20171122 ; subDT >									
//	        < Ryj3u1slHYcJcwVlCmsfdUN9PoOr0aM2f13DEigu45oik4w4k7umq85MhsEb0VUE >									
//	        < H237wYbP8T1JZb1htIsp8965B14e8PxM2ybhg0r6GnmPKtrERN5ROlC6Qn5qakCp >									
//	        < u =="0.000000000000000001" ; [ 000037216559340.000000000000000000 ; 000037222385002.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DDD3F67EDDDCDA24 >									
//	    < PI_YU_ROMA ; Line_3762 ; Jw14c1F72Rj5WLZYQJl3sqzVyk7wvug3X6z8VBJf5948dQ2F4 ; 20171122 ; subDT >									
//	        < Is8YpZ4yQmNBFVpfJL8FFFfKMs7B2YxVmF8Qf5H720hwIJ2w2T9x0S77iRM11Bvb >									
//	        < b6Z6kyE6Ui4ABm9PO8q7ASZHS5pcW00lPHRB4f1g3nM4glb0i226WQ3Zy261VhK1 >									
//	        < u =="0.000000000000000001" ; [ 000037222385002.000000000000000000 ; 000037232066987.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DDDCDA24DDEBA02A >									
//	    < PI_YU_ROMA ; Line_3763 ; R1IIO2T4swaw8cw3dCpQ9XScr8P4pjWB1Jr4ocNUryif3rlfH ; 20171122 ; subDT >									
//	        < QY9jRX7qg96vau7d922HFh0lVYa0YX99F2Ke3x7a90SViV1e2R006klQRXRbj0mO >									
//	        < 1fKw8KRyxf5moy9wrx3B3T6lsK7DFbCQCoXUWNl9xx652ZW5i0RSoUxdA75kgPA4 >									
//	        < u =="0.000000000000000001" ; [ 000037232066987.000000000000000000 ; 000037239925278.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DDEBA02ADDF79DCF >									
//	    < PI_YU_ROMA ; Line_3764 ; qU5nm6Hv98q1j48H4Nx3CN28P7Gbhiadmz2yGkC51x800deoO ; 20171122 ; subDT >									
//	        < 4EfO80dI617NxEXRw927srhwnT19v9v12AQhWZeru921A3XE8qY4eMXhxXh20564 >									
//	        < 5LtrGBg9a723yZD8uwau12ZJScK66C4MNkxhygTGh7pbM1f0EhkJ7gi13jp8V7A5 >									
//	        < u =="0.000000000000000001" ; [ 000037239925278.000000000000000000 ; 000037245220510.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DDF79DCFDDFFB243 >									
//	    < PI_YU_ROMA ; Line_3765 ; s51z15GzswV2qJUxaEQ7U9Humi4h5EnQG2no7r0U6UKM780si ; 20171122 ; subDT >									
//	        < X8gH64v7i5F3LAU4EgoHFWIfDABRzUEFJWqrU53u49yie871P1f716u399w55erz >									
//	        < ayc252JhnJ6npOCEP8jrWCtawv0211yt8Uw8h244d6p4mZ950xy5LUxBef01rS4p >									
//	        < u =="0.000000000000000001" ; [ 000037245220510.000000000000000000 ; 000037257419910.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DDFFB243DE124FA7 >									
//	    < PI_YU_ROMA ; Line_3766 ; al4X9N012np5UY6c0p3o6Lk5hjsh0K5E5dt8If8jtoCWMq5dP ; 20171122 ; subDT >									
//	        < F9ZyNocF41U8mfsL54QmFu3J0f818yOjf4Crx4u5Wg4235MBAfBPwt5m647bfSP7 >									
//	        < h4gHVD1meTUJKEKO2797Ua9o6Tvf738T9X928zI67zV4q0HuZarGS3Gs54JFC7W7 >									
//	        < u =="0.000000000000000001" ; [ 000037257419910.000000000000000000 ; 000037267251332.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE124FA7DE21500D >									
//	    < PI_YU_ROMA ; Line_3767 ; dZoDS8yDyLB1r864gV2Jy4bjzMF4EEu5378308fLs47Q4750Q ; 20171122 ; subDT >									
//	        < O9MyFp29aNgol2PbjxJ84mc1766L4KYrKemm1o6no00bSS0mQ1TE6ewc67Bxfc5v >									
//	        < dH8FoFx570er5vhC51Kg0E9uknF41E0O57UBjkvkB1jRM3oe9h4BbY6W3y1lO7X4 >									
//	        < u =="0.000000000000000001" ; [ 000037267251332.000000000000000000 ; 000037279969231.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE21500DDE34B7FB >									
//	    < PI_YU_ROMA ; Line_3768 ; q443bdfjo4Kqa5CAdEV3UT6os2Tb6s8H3tVqP2LaAATpE06X9 ; 20171122 ; subDT >									
//	        < 936c08lu3sTj32eP6gBguPou60mr55F5T4UT68pebK22vN6yYmJfAJw2veIn1wP4 >									
//	        < aa1n7P9654eK0IG3UM5HodTq6s1fZiFzX9U5EWIiKwz2TaK6O2NvJHd5FElQCqLd >									
//	        < u =="0.000000000000000001" ; [ 000037279969231.000000000000000000 ; 000037293304470.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE34B7FBDE49110F >									
//	    < PI_YU_ROMA ; Line_3769 ; 863I77qbD104Zzv4RETJd5r5RFX13v2FTI9nCsHB8y6WbGBfN ; 20171122 ; subDT >									
//	        < 9ExO3N7FG95Vx0rQDNLBHygNi8nOOuDe70OVy6u8C5ClUqHeYv0dHtA1j4m52ZEG >									
//	        < N7L6dhZl1o1bs3HBA0P9JFo292JRuzklFMfA2nk2A8v3alN19yl0Xr4jc54KLZMX >									
//	        < u =="0.000000000000000001" ; [ 000037293304470.000000000000000000 ; 000037305759056.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE49110FDE5C1221 >									
//	    < PI_YU_ROMA ; Line_3770 ; p99TirngOkSu97733Obk4UlXmeLfeGKxlj36xgD2KPQZ9kLRu ; 20171122 ; subDT >									
//	        < 6s240go111Ji6fx3u86l6CX1vS4HpWQl20ZW27jh88BmyG0o3bRNwuO51qyHeh3r >									
//	        < tbV50NC6KO6cFI1XnI7wXq0lt583uvPtE7NNawV7MfoF7792QJ2TnR14Glx04jKP >									
//	        < u =="0.000000000000000001" ; [ 000037305759056.000000000000000000 ; 000037316993374.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE5C1221DE6D3689 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3771 à 3780									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3771 ; Rvm57pDmP7H805O3AA6vb5Qt9mTv5Tb2QOK6uIp11z22wxzmT ; 20171122 ; subDT >									
//	        < VJ2Up1JUJ6O55UAjxes773DC00Z8c0hh1aoAT8W91RL1hQMNshV2SifRbZtz48Do >									
//	        < 3JO9EY4I9XHjVqiMPf93m2K47Jb8b22O5N7W3e7T5nq23px4G9FcHiYY8iD5Z197 >									
//	        < u =="0.000000000000000001" ; [ 000037316993374.000000000000000000 ; 000037326915301.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE6D3689DE7C5A4A >									
//	    < PI_YU_ROMA ; Line_3772 ; jml3X9KY85bXGMCAUtaF7RAIA8JdN5RRoEBk02h7p061sxm0P ; 20171122 ; subDT >									
//	        < I3zFLaLVpBciPF8zzZ53wd55Q001BA2p32rslZL5N9340pBVJH71QZWEVnD70w8g >									
//	        < Pkk3Hr0JGmN4FJ3LZvMg955pMys14hqm6F98F4g8Ok71MQu72S4F7b8Jx48Y8du3 >									
//	        < u =="0.000000000000000001" ; [ 000037326915301.000000000000000000 ; 000037338051609.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE7C5A4ADE8D5868 >									
//	    < PI_YU_ROMA ; Line_3773 ; 6wTyjM5ZKVg2PExX13FcQhne350ALkTr22b9Y9b2X2YcaWGd5 ; 20171122 ; subDT >									
//	        < VYrMb0vQSrlaNiYN0ljvCER2z1tZykmJBoCPXFBBR74v2zbjOOSZ8kahacUaMRd6 >									
//	        < bH2A1aoa3qZQzjCw3j9H7FJpY3MnFirE59mOkUgN7bt02hbMRliO8RwFrGQ427s0 >									
//	        < u =="0.000000000000000001" ; [ 000037338051609.000000000000000000 ; 000037345906008.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE8D5868DE995488 >									
//	    < PI_YU_ROMA ; Line_3774 ; XJuYKMNCXNu9f3LoNbLSvfJnmWX4RZPKrG7T7SWlXUVEgmjt1 ; 20171122 ; subDT >									
//	        < W5w2uAFBwLCRes538tWZW36k300PVb3AKOdAThgp8HzlL10aVoCamA3wnH531q7X >									
//	        < q6SBf1zxfoN0tulMDmNmkxvRfRD0fv2gLalR7VZ8DLMv9S32TYS08y2X1Am4Sf06 >									
//	        < u =="0.000000000000000001" ; [ 000037345906008.000000000000000000 ; 000037353081563.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DE995488DEA4477C >									
//	    < PI_YU_ROMA ; Line_3775 ; GN71wPhMTbM41mr4Hg8ua1jyr77nwvxY628B47ApUm68wI8in ; 20171122 ; subDT >									
//	        < vsNQPGnm34u8Tx1husaU8qdD2hbglTMH127gv5KTLx8KQ3SqolY6j1AZIoRz13Sz >									
//	        < yF8CAo2RNVKa12tPXl9l7y1M7zBm0sR3g9i5Wtm2Zn7L75Aszm95e4eF158h47Yc >									
//	        < u =="0.000000000000000001" ; [ 000037353081563.000000000000000000 ; 000037363838980.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DEA4477CDEB4B19A >									
//	    < PI_YU_ROMA ; Line_3776 ; fhCJ5qQxp8WOWK6a3VED860E7kFm1Y59243fCN7f3i6xmh70B ; 20171122 ; subDT >									
//	        < Wy03I77l0392VcHQL6na6NVDx27y9TA3cB21Ij6KXMch6VaANpW1DF7M3PjCh3wp >									
//	        < e56Tv6t78312zX3dVlPdMy0gn4sJz1fcAwsD0Cu5J8wUSx1PYNX36FAj6HPyljh8 >									
//	        < u =="0.000000000000000001" ; [ 000037363838980.000000000000000000 ; 000037378671149.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DEB4B19ADECB536A >									
//	    < PI_YU_ROMA ; Line_3777 ; NKefYMxIq9ES46bBCGcPrep69x7Dvdfk05ofxGundp6c8bCP8 ; 20171122 ; subDT >									
//	        < 1YzPsuYhV8dPayhritRu3r7791xIXRNyfP6QN98Ucst58cCxEpT8XVAkihhtz9Q3 >									
//	        < 3rbk2Yiera2Yn84QqqODk1Pln21K1R2m7bY1QPZLq7KHm88BtUGojYz6N9nZ9x1a >									
//	        < u =="0.000000000000000001" ; [ 000037378671149.000000000000000000 ; 000037385121442.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DECB536ADED52B10 >									
//	    < PI_YU_ROMA ; Line_3778 ; p93F4Uw8IrbuT8vQjkXVMdm8pou8N6mv5ReJy894E2Y9FC20d ; 20171122 ; subDT >									
//	        < VLGX5NSz49Z4Qx49v7E03hOWe8DU128cTw4nz0E9m3F4ZX6Wx3xbD6X9yItpVO3u >									
//	        < U67OXJ6KUaPOxKNNz06S7V8StI4MmTBGCt8H21DgLW1YN8940x4ORX054qYDcwDY >									
//	        < u =="0.000000000000000001" ; [ 000037385121442.000000000000000000 ; 000037393551828.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DED52B10DEE2082E >									
//	    < PI_YU_ROMA ; Line_3779 ; 2uiX5HwaJ5bS2vj28H0R08bLdF76ZoIuO34xaIGI7Wikj7Gso ; 20171122 ; subDT >									
//	        < 3ZfCEb71ob6E9bpn8ccV7W95RW8ZSqv4oSxo955li5w8l1376fx56Z0713h6bLCn >									
//	        < 7I09972zTtTI1l3fQEn1f87nMwX19YO524CAMiCmBIK5VRFRiCEep551Je1xYKfz >									
//	        < u =="0.000000000000000001" ; [ 000037393551828.000000000000000000 ; 000037401917956.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DEE2082EDEEECC33 >									
//	    < PI_YU_ROMA ; Line_3780 ; 9838j3gx4XE2I9Wur576OD43cCD3821O4F47B5YCWMi9t9Qkp ; 20171122 ; subDT >									
//	        < jh82lb2qIZ14whA1090440Z1r1e5hudBS021G4hX0iK21YKSg8d36CWD5ul571Yt >									
//	        < MWTf3QV5e19uj31X04o7042B5OkjB4JfsFSQJYRjRye70t1AIVX98J8O250Wp904 >									
//	        < u =="0.000000000000000001" ; [ 000037401917956.000000000000000000 ; 000037408592849.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DEEECC33DEF8FB94 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3781 à 3790									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3781 ; v24Y33oh3oRGk5xO61w51VIHwjDDEA69Smp89Oz0499VNqdG4 ; 20171122 ; subDT >									
//	        < 5x43xPd362BP91j7i6fD75u6iwT3lmSHajeIwMZA24R8BaRrNK1R7oCPwbe5co24 >									
//	        < 3N4Qy05c5Xgo6wN9TINe9yD804iSc8deHy6vzoU90aYRqMpaNX81Ke7FpJ95IX81 >									
//	        < u =="0.000000000000000001" ; [ 000037408592849.000000000000000000 ; 000037418640628.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DEF8FB94DF08507E >									
//	    < PI_YU_ROMA ; Line_3782 ; O8Sz27EHyv390o9kvj6p9evqls8LTHXvzDab15eW2Y5aHjP2P ; 20171122 ; subDT >									
//	        < B3qiup088w4LkO18y51DVheq6cp15o3IR3v6dtfTPDtlfxYEgXQmdN7jlNymcS6K >									
//	        < JGFFk4q2O5FzRA0BRd04neTqS2p54TG1th595uxvY8ER430877flN0m4115Sp557 >									
//	        < u =="0.000000000000000001" ; [ 000037418640628.000000000000000000 ; 000037431769912.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF08507EDF1C591F >									
//	    < PI_YU_ROMA ; Line_3783 ; xm20By3S760Ze9tJI2bo208zyJxzuVFv207EJqdx923R99306 ; 20171122 ; subDT >									
//	        < 2tdj0Mdyh9Drk7132s2e9JWotHs2814JtSnE7UTdaII6W2vVGkFVfEV5O1zDz16c >									
//	        < fyT05518b00pKTRd3z79opkbdnWcKQFXghay3NHgDW5fY4y7U5vma04OU30veu9z >									
//	        < u =="0.000000000000000001" ; [ 000037431769912.000000000000000000 ; 000037437661077.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF1C591FDF25565B >									
//	    < PI_YU_ROMA ; Line_3784 ; ZL0qtahnWZdsH8Ifa1Y9pUL2sCs3YMfVk3MYa16Yvozygp8qJ ; 20171122 ; subDT >									
//	        < V5v0dV3E75BBZmHWUaIs30s5z2131Xc5R9t8GzhK2m5B163qu7Gv59L4ZLSu060I >									
//	        < vGuD5Vu91iN13s0BRsP38bPDZGgae3xoyGL9Tvgvnu7P89HQyxs1HRpYljF3s03c >									
//	        < u =="0.000000000000000001" ; [ 000037437661077.000000000000000000 ; 000037443777661.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF25565BDF2EABA6 >									
//	    < PI_YU_ROMA ; Line_3785 ; g1P4X6B6FjKHSU9D78Yj2oWRmThah5Z1P2AFs8p3Pa20lR11Z ; 20171122 ; subDT >									
//	        < pe8PI7PH0gd01k5T4I4CItpnt4z817zq7U79v11E8oUmeA96FGZ96AaJg1t1TPrM >									
//	        < ZI54pqyLj421nVwl254YfWzJe785Ei0uK1f1CaT3VHTPmLUqJ89x2RN7hZp3ABbP >									
//	        < u =="0.000000000000000001" ; [ 000037443777661.000000000000000000 ; 000037454351702.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF2EABA6DF3ECE22 >									
//	    < PI_YU_ROMA ; Line_3786 ; W9tZN7f44NF1yWJd8115VQjX3a40560tr0z8u7E7Tgauk5sB5 ; 20171122 ; subDT >									
//	        < 7iPCx0J18vUAe1fRO1H1zRn4Sj5A8Pkqh2X30L2udZ9P9wcONr0wf4PIjO4b9u29 >									
//	        < HUBM9Wfh1p7Qj7zz6rRObx2z5bTf9o5F3nj03ln5W96TFozNi5MfD322uVBkl4mQ >									
//	        < u =="0.000000000000000001" ; [ 000037454351702.000000000000000000 ; 000037459860657.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF3ECE22DF473611 >									
//	    < PI_YU_ROMA ; Line_3787 ; 0GFfL9wH9i2N88CoJAinn96SRMx8IcYtlz5PHLnv00112KSIt ; 20171122 ; subDT >									
//	        < R5y6rv1wAMcHNqao4t6ubstXNY3Ka7SLoz4P99H6ftGOWesqw64K28SaP3xFH9Xf >									
//	        < dy6jxS2K549M7vu702rdQGo42O5IbM6BUUPuiq9r5DVuhb3un749AKxbg1tdO3fl >									
//	        < u =="0.000000000000000001" ; [ 000037459860657.000000000000000000 ; 000037472536018.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF473611DF5A8D61 >									
//	    < PI_YU_ROMA ; Line_3788 ; K24FuB9miVn6M2lnz10hIzhhRK921wyPsVwvpk61SUhy3L75U ; 20171122 ; subDT >									
//	        < 3VX4660bU629E59JMA90h9gA7R25ek7CB4Nxx52hkFbdz3cZZO1O68R1dYgl5u12 >									
//	        < Z39lRXvW4m038G0WmH1jedx658464QM3yoNKAOY3oylm1ssM217iXASt6AVv9ddC >									
//	        < u =="0.000000000000000001" ; [ 000037472536018.000000000000000000 ; 000037487291869.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF5A8D61DF711162 >									
//	    < PI_YU_ROMA ; Line_3789 ; xpQ64kp5bXy3SUaB2w7N5l8Vl9IVqI50BAZ9ha7A1HMZwq945 ; 20171122 ; subDT >									
//	        < 50FYZVV5lCI9dm1i6LZ02aH8BPWUu5lHc14QekQcn81c9702aUW4y41IGyjS1r0h >									
//	        < vk1mclQ0LLoX0M9SBu94A931mtxY40sleigC4A5uQY5b26Z4FJNXBFd3cdDDMoC9 >									
//	        < u =="0.000000000000000001" ; [ 000037487291869.000000000000000000 ; 000037502023736.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF711162DF878C05 >									
//	    < PI_YU_ROMA ; Line_3790 ; 0JCZj52Ah8PKiDY991kWM1CW7yEJO4xW2v0d9P86o4YBjsUq7 ; 20171122 ; subDT >									
//	        < z6v20s57Dmae3rOTr0VUjZ2b4FtnW9qDW251b6RrX9mpe338g1YT6Y6Ts4SH78JP >									
//	        < 9kojKdgv73wglg78OO5a077v870YYcp1sqWW65aB8Pya5Eia883JOSZacs6V1URE >									
//	        < u =="0.000000000000000001" ; [ 000037502023736.000000000000000000 ; 000037508933862.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF878C05DF92174A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3791 à 3800									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3791 ; f1M6uKnB237TOL7B2t89gI8P7j0m166O11wV6keV1tb3y94md ; 20171122 ; subDT >									
//	        < S57m9Ur0K3Sfm5rxizPc6769s0wQt9y1h5HC4prJ0UXBV78Wy3be4X97Sv3G3ijB >									
//	        < IgX55Pub70R7n651TcdYwuIHBLq4rvrfR1i57Dsdy8pD9KplhIjS9Gn1XMDgf0ax >									
//	        < u =="0.000000000000000001" ; [ 000037508933862.000000000000000000 ; 000037523752161.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DF92174ADFA8B3B0 >									
//	    < PI_YU_ROMA ; Line_3792 ; s4G68NG7VU7z885XEvI4Y2OzAdPxIjOhkBYqlm3zjz3Do05YN ; 20171122 ; subDT >									
//	        < ryF1Fncbia2q1e7E5khWi37g5L5xsXxPy7qBvm5F5d77xcl3ozzcp29C08t6CzW5 >									
//	        < 7qzp2QiWvJbk9Bt0LPRF7vmEat4AJS5kdRFO06b317pVt38G9o69xI0eZ3NGtpMX >									
//	        < u =="0.000000000000000001" ; [ 000037523752161.000000000000000000 ; 000037530868341.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DFA8B3B0DFB38F72 >									
//	    < PI_YU_ROMA ; Line_3793 ; Ap2Kv6Ev5o59B23n73eqiut0q7oyq8O2V5ekV5EcW7K7hYD1y ; 20171122 ; subDT >									
//	        < N4wAXEH07MVv7D095X81e9ZHJV9Svrps1LXLVchS2XVO9lFeL2UpCEFGSd9i87Rm >									
//	        < 98nphwUZ7BsgVb6JGI0boeWWiNjf1A66K41dpt09y0Abte6Ev49BrP0TBw5Wqj62 >									
//	        < u =="0.000000000000000001" ; [ 000037530868341.000000000000000000 ; 000037536239166.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DFB38F72DFBBC16C >									
//	    < PI_YU_ROMA ; Line_3794 ; uHmyym63375xgbis8B7o5r7VE09S8jP4M1RyntXpJUF4IcFPp ; 20171122 ; subDT >									
//	        < vka6PfGb06TOpWq1tf673fYLz8QH9kjC8m963RDg60D4E55zfx0E9u6T290eZdl9 >									
//	        < QzGj7jfihIcc1p7uTGABB793sQht9tJKBw8ELXZLx5j7jO8k1I68x7tH3WORl9hD >									
//	        < u =="0.000000000000000001" ; [ 000037536239166.000000000000000000 ; 000037548131172.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DFBBC16CDFCDE6BD >									
//	    < PI_YU_ROMA ; Line_3795 ; zKsW0mLMQ6EOK4w37t1quwVscXDj8PfBXo1O5uM84SXhAbuot ; 20171122 ; subDT >									
//	        < 2NM6o0etJw4xQURYyM1NY6sNfuV9szx3A0V7a5v2zfT7932RszPwIuy21guxgMF4 >									
//	        < sQnDZ4KlMBi8yNlCDM1HMR64yQ1nLgc55uW31770N7QVIM654Ouv7fu772l557yj >									
//	        < u =="0.000000000000000001" ; [ 000037548131172.000000000000000000 ; 000037561040104.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DFCDE6BDDFE1994A >									
//	    < PI_YU_ROMA ; Line_3796 ; 463sFq0dZ2nW03X13y8igs6QZ2PsV7HgCy0dNm5jPCq14gf3d ; 20171122 ; subDT >									
//	        < 3ZP793uE5E3a8ieo3ggZcNBPNsZj7qM45J3Jn2Z4ZlFRUpvh5CQhJ5eULKy7c1is >									
//	        < 09H0jG3GMqWgXm4aA2842BfKoA7Xwyqwj463NXJ2fcVwC0WtV5n360VraN0eC415 >									
//	        < u =="0.000000000000000001" ; [ 000037561040104.000000000000000000 ; 000037574182814.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DFE1994ADFF5A729 >									
//	    < PI_YU_ROMA ; Line_3797 ; 4B7CguZ0r69xb71J5tY7U5Qo9327936g2d8jqf2K4BbnskHw8 ; 20171122 ; subDT >									
//	        < CIK36ini16u3VCKn6u25tWzF1MnmjUzb1zEy666lvn2j6Xvyj0IDS6VAH80q37G0 >									
//	        < N9cktpY04aMyX3t2raT3458Fm6ROmz8VbZ185OsVHoFxx5b4g1XWOuTPXVOAlpvQ >									
//	        < u =="0.000000000000000001" ; [ 000037574182814.000000000000000000 ; 000037583547621.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000DFF5A729E003F14A >									
//	    < PI_YU_ROMA ; Line_3798 ; o0twEHWGF25Pde47yb6qlpims8Ewm7iK8108J58JWV359x6Q0 ; 20171122 ; subDT >									
//	        < n6EYBYp0YACfMpExRpqihbHgdyn6N3b77E5fO4Za197P00vC7AZq78VNA25Rgk67 >									
//	        < 1Rw8u5z089X91h9940SgCw878oON1QHB9TtIC6qa4i1Qo861y5BGh59vuU8A5B3T >									
//	        < u =="0.000000000000000001" ; [ 000037583547621.000000000000000000 ; 000037597301234.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E003F14AE018EDCB >									
//	    < PI_YU_ROMA ; Line_3799 ; x7tsEajjhF69t4pNOMnl1WD4iUxA9eH9h9mhxoEx5x4g97e4N ; 20171122 ; subDT >									
//	        < 4D4lq37637HiDZ7sUVMSUeE4HS9P80Zav70613i8D0xZb68pN1mk41AZ87rkDE9R >									
//	        < bbD45gG0XB7T4fjab1KPR9heE457j6e1g2IHTO3JwO9QnE83ZEc062907K0GB7aV >									
//	        < u =="0.000000000000000001" ; [ 000037597301234.000000000000000000 ; 000037608978858.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E018EDCBE02ABF5D >									
//	    < PI_YU_ROMA ; Line_3800 ; f98nI8q657H4AD1MD4B1S21QHPKLYr9782YJa13Xl9ry9fI2F ; 20171122 ; subDT >									
//	        < laCjaixB1Qv8Grwq6YL7l2ecWRL97Ge1Jsaeq13Jro1NR1nA8o3aM8AfEJ71WnI4 >									
//	        < KO6fdg59rNjo5W6807e5O6X462h9L018557I9fS4aw4U07WG5e4Pm35173Y6q1C2 >									
//	        < u =="0.000000000000000001" ; [ 000037608978858.000000000000000000 ; 000037615415750.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E02ABF5DE03491C7 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3801 à 3810									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3801 ; GjAs2ki0eU0dk1uqaQplNc0BzCt85SLP4tN2y27m8ewZ8goMf ; 20171122 ; subDT >									
//	        < zb2mjsbmzt9P3DSC3RwR9df12e376yvOsGp08QcF97N61xwhdzz75X4G4KnBNM74 >									
//	        < dLB016WI6kwzoLDCD1JBHJTAs3jdp7kEWkK85be3PjUq3uhnU0762uGj71009cZH >									
//	        < u =="0.000000000000000001" ; [ 000037615415750.000000000000000000 ; 000037622636965.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E03491C7E03F9690 >									
//	    < PI_YU_ROMA ; Line_3802 ; 7O340ykjzTa820jV6tU4nNWcHPx2Tscb9ekf9ds9OX8KYsvA8 ; 20171122 ; subDT >									
//	        < 83AmNHmtDTdVNoUA5yG0VBu9W8Ws3F59430Co2x7nWT79sCRj3C3C367e78npH3G >									
//	        < BG5ggYC0a4b23NW6e02V3359Ov0ySx0Wk0o3Ftii88HaWn1W0gr8ZC6N0PNV61P2 >									
//	        < u =="0.000000000000000001" ; [ 000037622636965.000000000000000000 ; 000037634041685.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E03F9690E050FD88 >									
//	    < PI_YU_ROMA ; Line_3803 ; y8FBRI8O6hYe987QX3UjKBxXxP4BAhwx2T7vyudelh0Rj2h4q ; 20171122 ; subDT >									
//	        < JEo0o9o77iXDQ0CDcexH24Ykbwn51zM0iSP1r196Ei1k5k3myTIC4v8v861sCNkC >									
//	        < r7hUv7DsDW57gFf46lD7qc7N92t5v0x7yfJ6E94991Ar717C12ik219tWhRJx8XF >									
//	        < u =="0.000000000000000001" ; [ 000037634041685.000000000000000000 ; 000037648263300.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E050FD88E066B0DA >									
//	    < PI_YU_ROMA ; Line_3804 ; uXbqO82SXruDU4f10yOETbbzmZqpVx4ayl17qZhWe5552557u ; 20171122 ; subDT >									
//	        < SEtOq0lz4HTOeg9NhJ6DpAZ02IS5Cc90Zn57zDHo0yVoYvYXe26w6ZA9Aui22bIg >									
//	        < DdX5tWuWcd73i014Z51202cj694gA0A23Z8891296WpsHw09j7WyI1z1LOBoI7jB >									
//	        < u =="0.000000000000000001" ; [ 000037648263300.000000000000000000 ; 000037658601562.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E066B0DAE076773C >									
//	    < PI_YU_ROMA ; Line_3805 ; 5i9n5Yhhw4eMC4xO262RuTUuBjnCyBrv0u00vFpJzrKG0601v ; 20171122 ; subDT >									
//	        < S0Y20u5I701xi13I1LkCc179ii3vP0anYkCM67S22g1K3Y5uvFXEc735w60uT55c >									
//	        < Xkce2my9lcVGDTVSD9eu0TT3yqGOz7SOvJqG0eF985gT6G0d5OYmmHP4Fz9TKAZB >									
//	        < u =="0.000000000000000001" ; [ 000037658601562.000000000000000000 ; 000037672521208.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E076773CE08BB498 >									
//	    < PI_YU_ROMA ; Line_3806 ; x7N5r33696N24QAvvts0veXaYhyH2a0ar9Y6M23HsJ4uz7e4O ; 20171122 ; subDT >									
//	        < QJnj4M22g6taC1N4p9QR3O7Dj2zq9M22CqqyPNUhA2W171B7jJD4ovR4Nf94DG18 >									
//	        < 943xdoZ9yR19Cp214zG7yTFkkXbtn6j3V410Gim8KU222ub7015x2R18q1PQV30W >									
//	        < u =="0.000000000000000001" ; [ 000037672521208.000000000000000000 ; 000037682765047.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E08BB498E09B5618 >									
//	    < PI_YU_ROMA ; Line_3807 ; Dv5Ooh1An75bAtxkAbcJh5uuPwy32Cp7V19q2knC0ok3E9MXJ ; 20171122 ; subDT >									
//	        < Y1PKl708uGqh7z01IURTfVoG6L5u1E0d1t31649w19krVNYl5r9P91Muhi01D94a >									
//	        < 7PcwjmajHLLltpKuAtK88tWk1Sr0y0Af6wMfoCShhB6qZs91ZP463vm93zT735Z8 >									
//	        < u =="0.000000000000000001" ; [ 000037682765047.000000000000000000 ; 000037689762513.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E09B5618E0A6037B >									
//	    < PI_YU_ROMA ; Line_3808 ; 6N9L7cQxxCXz70dNl49UeoH2NS8183dAm4QvWXvoQ157six99 ; 20171122 ; subDT >									
//	        < MnXorvu0rqqn98UbVh8w0Z3W5UqL0zK955aHUz7F7YxG0fT6Cjkw36d74IsoOY0n >									
//	        < d9pv6TmUABkSUuzJv41zJ6zwIYvfMi52u1G2ZQu66j9xA73R6NYvvdbsvnrylZ85 >									
//	        < u =="0.000000000000000001" ; [ 000037689762513.000000000000000000 ; 000037703124681.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0A6037BE0BA6714 >									
//	    < PI_YU_ROMA ; Line_3809 ; jx2gn4S02nb4yVV5Aav3ookX7td735VJolV98ymPP884llLYw ; 20171122 ; subDT >									
//	        < w6TxM4Zt3E84CQ52411OLW8wA4s9OL3I5y36g0lqkbdD8V92kSyM4S49F700JPgY >									
//	        < wIFp6BsiNKYrN28zB7y4zw2oxaTZoC6mO9u59eQbVs4f2gJLxvPuf1XOG6Xv5078 >									
//	        < u =="0.000000000000000001" ; [ 000037703124681.000000000000000000 ; 000037708816165.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0BA6714E0C31650 >									
//	    < PI_YU_ROMA ; Line_3810 ; q2LE6RB49g38i3t380bB2j96FHx2ZsM2bFFXA3MEKlB01T9a1 ; 20171122 ; subDT >									
//	        < JXIqCQMniwR0j9CI02QoH6w90Y4bNIHNeBK1VO5pf8582Xd73CeBeiNA7LUOdKK2 >									
//	        < 97t7WFgbi4WlhN5Vy6H7fzPA1Wo2fiRC0xnMAip5yG8SYQ7VxiEpgac5fKuNus05 >									
//	        < u =="0.000000000000000001" ; [ 000037708816165.000000000000000000 ; 000037722655789.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0C31650E0D8346A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3811 à 3820									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3811 ; 97K9Ara2OQrA2Y9Vl3ITHHSZmYX5X19A69UncraWhO39a00Co ; 20171122 ; subDT >									
//	        < 5Yr540V6l2s6osQTj8W9x84i3ctjm1UTcs5jfP96eSTH79pWXAuURzE5Jsw97UMI >									
//	        < 0LcJDP4Tqjj5YtC67miDbwh983M8HEZZ7M8ZNEAhyJ20EEE3g2M11IYnCHpvA8dH >									
//	        < u =="0.000000000000000001" ; [ 000037722655789.000000000000000000 ; 000037730153585.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0D8346AE0E3A53E >									
//	    < PI_YU_ROMA ; Line_3812 ; VLO44D1gbh8uLGI71Xthjncjie35UJPN1mZVv293b9X036guu ; 20171122 ; subDT >									
//	        < in5k6l3vtXna7dGuLl6h42n645LzT8619dXrtq284317kIm16Pe1pCDym9jK36d6 >									
//	        < WdGkzf3Mw6H3xjx23MXbL5czoh728hFwAmrCzVl9phBkL987cG6BiJ70gXy3Kw6G >									
//	        < u =="0.000000000000000001" ; [ 000037730153585.000000000000000000 ; 000037737179021.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0E3A53EE0EE5D8E >									
//	    < PI_YU_ROMA ; Line_3813 ; sFPIfiYe5WLMP6UWx0zPl2k6Q8vvC77Qn887fo8uC7Qi8EGb5 ; 20171122 ; subDT >									
//	        < to4suPjLNVFhyB4shtC4bnV7zv2IumVr4nUS53zgC18tpryDJFyGa3s5526pt6OL >									
//	        < kW0S2IJmzn87U060M113HykyQg20aJ9b6bgJKi08W2m4yF2Nr5DyOoZ56is0n1xJ >									
//	        < u =="0.000000000000000001" ; [ 000037737179021.000000000000000000 ; 000037748082960.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0EE5D8EE0FF00E8 >									
//	    < PI_YU_ROMA ; Line_3814 ; 3hx7WQ41aA3kTWikh2WkjQ02V8TNwDXiEOL4E43ftyDl2vUax ; 20171122 ; subDT >									
//	        < Mt49SqbUISvgJv537N9Z49m81NqtA5v98e1bQgrDy2Sz24Z79m36N6zBT2HEUR6Z >									
//	        < 2T9gjDKT21PqqPAf32P5IRKVbH1wqasICEhE0M7HObzk6P2mf0Y46dIKyXs4Pnz7 >									
//	        < u =="0.000000000000000001" ; [ 000037748082960.000000000000000000 ; 000037753756658.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E0FF00E8E107A931 >									
//	    < PI_YU_ROMA ; Line_3815 ; hATt8nVy1k514fT49FutXD0n1SIHh1k5zy2Kcy865UgPZJU94 ; 20171122 ; subDT >									
//	        < w14551AlkCLnzU8o2e8wn7QB1x0u6f282CzHt63Tkd2ICk6i4ek2pC2fA2e2m4zD >									
//	        < GV3czr7lS4q7XevR191Cvq18nAUtBx7CQW5G6W8gv3G2ZSK3X3p33a5azMEUFN17 >									
//	        < u =="0.000000000000000001" ; [ 000037753756658.000000000000000000 ; 000037763828590.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E107A931E117078B >									
//	    < PI_YU_ROMA ; Line_3816 ; F7UtdsGLJ1NOFBbAUtL7ntree7WOK1c0Flu0ApXWUfJFWc3qA ; 20171122 ; subDT >									
//	        < 68A52VqcQFFk6TCgR9PbXq0Fm03n25uBcd921ewyfU0P4RDra66jBGDom30wLr58 >									
//	        < v78TMJvXY1GsdV6wvm8s721pF2kVFRhs0oLQ1Zut0Ja324mCSO2x8maQOsPXt24s >									
//	        < u =="0.000000000000000001" ; [ 000037763828590.000000000000000000 ; 000037771186470.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E117078BE12241B7 >									
//	    < PI_YU_ROMA ; Line_3817 ; 9IgN30AGCG33H0or3H9KSC6l64g913307nDi9sE3s03dn1dq0 ; 20171122 ; subDT >									
//	        < 852PVzJJ72rfnOjL3SH3OhlU83VU57R05UYXTO06S0V0yb71BhROJE82r2zZ453g >									
//	        < jP9Co3v324cNQQ1Y1U8HNLw24UeY27tSDJEzJ2hJQ7nb7w1ea95I0p13d9Ep4icQ >									
//	        < u =="0.000000000000000001" ; [ 000037771186470.000000000000000000 ; 000037780209808.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E12241B7E1300674 >									
//	    < PI_YU_ROMA ; Line_3818 ; Lu52g3aybor6Tr1oQ9bX1s428edTWgdY3O7r844Ui5L2Va83s ; 20171122 ; subDT >									
//	        < 9Fahm90gJ4Nh84BLlYwzNVKbr9g2OJB62yhu007Jj1HB0G031As3DE8eZyHrwU01 >									
//	        < w9ry5O7k3073s1Ml60OexZVK67pZ596BQ95bjNvH788Q7akD4mTIY539vD43B1eg >									
//	        < u =="0.000000000000000001" ; [ 000037780209808.000000000000000000 ; 000037785902270.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1300674E138B613 >									
//	    < PI_YU_ROMA ; Line_3819 ; eLjZZg311Asjs4zDH6m5lFghltWs8gI0FXn5Osl3Q8fb1pd3L ; 20171122 ; subDT >									
//	        < GHMJ8wPuOEi47TXa9mS4Y0t56df53TB1hbEE0RQl084u9FQR51oC5c9n0f1d3txW >									
//	        < wyvsD6D931743tn6CIpzfIaPZwD26aM6PqP68WTLrwQKQ4r74RGH6vNm15OW7msT >									
//	        < u =="0.000000000000000001" ; [ 000037785902270.000000000000000000 ; 000037797530477.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E138B613E14A7457 >									
//	    < PI_YU_ROMA ; Line_3820 ; 2gG3yTSF36y21hOPW4826UpOJO404Fo068UeE4s816Cu9XAhd ; 20171122 ; subDT >									
//	        < OCFHLe078q5kG3HicDdm2834h57zmyEyvMQvIHv0fJp5lPbT24t0MEJz5KJRZxu9 >									
//	        < t7ww9QIXo6sEa5hjI04LaRfwU39n0731Z2V5adx9a4wIzm62emA6n9FeYscwXHzN >									
//	        < u =="0.000000000000000001" ; [ 000037797530477.000000000000000000 ; 000037805896957.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E14A7457E157387F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3821 à 3830									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3821 ; 08yL4X2G6udOd3HpKdv8la5DuLnOe7V9MC4q0Xa3Yi23x29E6 ; 20171122 ; subDT >									
//	        < FUPBpX4o5F03ngLgrAdw94Q1on9Vew3h16e8t5l3HH092G1220VQJDoZ1YsA99l9 >									
//	        < 69XHh415otx77bWwxyfZk4V026Dsr98x96Yrpp87XHa03HWm81UzFDIz8557u8I9 >									
//	        < u =="0.000000000000000001" ; [ 000037805896957.000000000000000000 ; 000037817234658.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E157387FE1688549 >									
//	    < PI_YU_ROMA ; Line_3822 ; Zk1JR2W7ee721GhL0xeHQ6P8h0LRrrBM634N41ZpIi0XIQsp2 ; 20171122 ; subDT >									
//	        < pc309fFD77pUfSBaD613Lw1Ijqsatm9SKc5oxHJ0TMb03u2N5EsmBU5dstRdTS9X >									
//	        < 2Ka9Gh4dUPBa77M193y1418dgI40n6po6r50MQUYn3b1oolQWZQIKY5p9q49g5EH >									
//	        < u =="0.000000000000000001" ; [ 000037817234658.000000000000000000 ; 000037824666053.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1688549E173DC2D >									
//	    < PI_YU_ROMA ; Line_3823 ; 6tC2OIxQ3133G6ql92d65lNCtwE9aP2muG61DQ4wvxObD2cn5 ; 20171122 ; subDT >									
//	        < yDi509imTNQX6FSRPz52Kv9RHx8kBS55PE427XEWn96sZ6GwqKVGgK83D4tJv4rC >									
//	        < fdVG853yEPr4mVH554Li0b2M0UzTs32U3FIL2N3k9YsT06DgWD4XjYalQiU2WO8C >									
//	        < u =="0.000000000000000001" ; [ 000037824666053.000000000000000000 ; 000037836265096.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E173DC2DE1858F0D >									
//	    < PI_YU_ROMA ; Line_3824 ; nO78M3p01V3Ud6wB1L4icY96j1jXd31ph82a28w5kw97k2S4w ; 20171122 ; subDT >									
//	        < z0yukzWL3Cx4P46aVZEs7aEbFE47T468Fo8cW90ivfDgeKrCCv6h4mVRPAERjZ46 >									
//	        < 7W5bqbB3zZygn7cWK9T8D52la4wV326UPT661glsG5YHHx050604690QVE478Uhq >									
//	        < u =="0.000000000000000001" ; [ 000037836265096.000000000000000000 ; 000037842969843.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1858F0DE18FCA18 >									
//	    < PI_YU_ROMA ; Line_3825 ; XIoiUpcn51ev1RE51owQsvjk87D97U8yHG6nNa63q0taC8Vi3 ; 20171122 ; subDT >									
//	        < k4ir5933H3f7dP8KEYb7M0I5OYA158EDok0Yolz8Md8E873rLVVL699Uko9E0P3d >									
//	        < 8r3b4CyNlVvYMGl5O9ir859U36y5HOOZb29dde20rjm16EaK5Qvm6Mo22cncAPYw >									
//	        < u =="0.000000000000000001" ; [ 000037842969843.000000000000000000 ; 000037855284432.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E18FCA18E1A2947B >									
//	    < PI_YU_ROMA ; Line_3826 ; NStdJ9lbeR37u6GwZcWyn76567HkY59xNiNmj981xg3HQ4wr4 ; 20171122 ; subDT >									
//	        < QVAFysTa53rp7o6RtWlgsNQdOfYbq02Qc04Jf7VCJMxM4z435xv1V17Rn6UvSfbx >									
//	        < qThLcbHT837H6NCa56p643TSaj9Dug00U4bYm0dm04r5fxXC19N4kK7JHylRU7F2 >									
//	        < u =="0.000000000000000001" ; [ 000037855284432.000000000000000000 ; 000037865037149.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1A2947BE1B17622 >									
//	    < PI_YU_ROMA ; Line_3827 ; u8M88Y8oUs1pIQ3eVc3lj6CaYgd41VXmjXhZ1cjMUW8S124Z1 ; 20171122 ; subDT >									
//	        < Hks1ZdAJm9P5Y7E8rc0YHOrg2n1RwMOcEDDw9ONck429i85p0Bgx875qy7r0m2V7 >									
//	        < B3lZworb5lC6flQL52C956WJgm1b3taQM6mpkyZ31GP403954Jp9Z0010SO348h0 >									
//	        < u =="0.000000000000000001" ; [ 000037865037149.000000000000000000 ; 000037878584026.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1B17622E1C621E2 >									
//	    < PI_YU_ROMA ; Line_3828 ; 1Jf9M1mIuraj81Tjptb5FZy8y678QKlI4v3zsW40lny1g5anl ; 20171122 ; subDT >									
//	        < 6N5tAn97bCfe6KkN5sEd7r4GTJv133QaWE2k3tjcQTsQVOjzVBzssWUfXhUQyxDj >									
//	        < I8072yOrrX4YBm1i29s3m6VCIJkwg45l8211OZj4JUtyc7UQ1j2V4f7c4huY8aOs >									
//	        < u =="0.000000000000000001" ; [ 000037878584026.000000000000000000 ; 000037891183602.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1C621E2E1D95B98 >									
//	    < PI_YU_ROMA ; Line_3829 ; 2210dKb3FkI97j0rO0S6Ta8D55ub4B0w1lxH69ztXPZPXIy8l ; 20171122 ; subDT >									
//	        < 1sGjlRk36796QKRcV8xgD5EL2uCqYWWuqC2fnWNxLfXH9k26yuVivLb7UT4e93d2 >									
//	        < 1R1nPVx521CN1AfC60CqZx7UGS2vqOklu6dZ0D804yM36878VIkyIjWxnqmxqTYP >									
//	        < u =="0.000000000000000001" ; [ 000037891183602.000000000000000000 ; 000037903822036.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1D95B98E1ECA47B >									
//	    < PI_YU_ROMA ; Line_3830 ; d6ZfUal2r49JnppVzvsArs5SK6M7OoQvQ57Ni3kxS8Np4S0w2 ; 20171122 ; subDT >									
//	        < i1829VaK20x6chyJ1It8gKt8BMaXcH52Pd4HJQ8N0J3GfJ8256A3ZK5Um8IvXnl9 >									
//	        < xyj22I0GqfvhwnHouzZLqB91q3LGUiblkTv7X2h9pVf12V5h13oMR6xJm6xwa2On >									
//	        < u =="0.000000000000000001" ; [ 000037903822036.000000000000000000 ; 000037916752811.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E1ECA47BE2005F91 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3831 à 3840									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3831 ; rxUzYFfB45YDWBtsxaKjV0WwkP5mEKHdlq6L8U1tE2ov8o51T ; 20171122 ; subDT >									
//	        < 828cz70hhyNBe248Z38eKW65AmCh26dclGXJk45ghxdRa019sHiC5197LLA3TA3S >									
//	        < pRIdHd2044v2sDrxBSyqesCglESbJI1lKoK0w44uiq70z6fGds6Az5VXLg7wwO8X >									
//	        < u =="0.000000000000000001" ; [ 000037916752811.000000000000000000 ; 000037927893725.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2005F91E2115F7C >									
//	    < PI_YU_ROMA ; Line_3832 ; 2gK8A04jTemWaAyqBQMh1girBDEY90VLX5LG2IZ288hv89VN5 ; 20171122 ; subDT >									
//	        < o8m3E68oPp6Km2AeSkngB9z7uv3V38APcBAaao53xn9ht7JS2ZU8xsu221a393n9 >									
//	        < g85wwMXJ8I9M1R1668PjHq25XQautXNe9296Uqz12Qr0S4ohPy5rerLhV5Bu1S88 >									
//	        < u =="0.000000000000000001" ; [ 000037927893725.000000000000000000 ; 000037939639132.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2115F7CE2234B89 >									
//	    < PI_YU_ROMA ; Line_3833 ; Nj3Z4fTZR5GxSzLrkX3sCk2LBKb84lk6e8DfDP400V3radE9b ; 20171122 ; subDT >									
//	        < N2b1215BCg662D7CFTgsNMIdxs5GGK759jbwK1LuOI66Q6h955968MRFNK2Gq5Y8 >									
//	        < aGc5bT19Hm6Gu7gqE429KLXSxhyWsf1VV09DbgZ8Z8gGnCyU8BaWIJvh92aKo7QV >									
//	        < u =="0.000000000000000001" ; [ 000037939639132.000000000000000000 ; 000037953151048.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2234B89E237E9A0 >									
//	    < PI_YU_ROMA ; Line_3834 ; i3N22uQkWtjpS8wez440SB36K3ynhbVH9ykZinBZ9eA3Z2vk8 ; 20171122 ; subDT >									
//	        < cD7k93qe6Efv635g1orn4jlq5924LrhUu5c15VF7KZs4W8EJ8601ipAcD4jhm7TQ >									
//	        < Ru7zqbOAssC85vkR05UilWArtu5k1qzOwRr4LU29xkD2Xs884bcKW0y7u14w8b91 >									
//	        < u =="0.000000000000000001" ; [ 000037953151048.000000000000000000 ; 000037958339782.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E237E9A0E23FD47A >									
//	    < PI_YU_ROMA ; Line_3835 ; tO44hqiF3fgC63s1o3LKAMgEABRgol8yDn81pXdg441m914r5 ; 20171122 ; subDT >									
//	        < 1SgcYbk7d2bA3MF2wArAeNnH4vqLFx51I2JbnuSo8QSK5rPLs7e58bZsY06KkG4d >									
//	        < Xqs2Q4hLIli85i92o3Hbd43HmB1xn4iwuRqEqXdrxxnR32gSI5jiUpAJcW2mAhfC >									
//	        < u =="0.000000000000000001" ; [ 000037958339782.000000000000000000 ; 000037966800659.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E23FD47AE24CBD81 >									
//	    < PI_YU_ROMA ; Line_3836 ; 179tDyN1AUH350fugC62sr81OpAbvf9Hw0rIRC5A6Fu1h689f ; 20171122 ; subDT >									
//	        < C8sSisApvzw8QtOUzU4k68h4x5p7zfNbv385O89Iwj1lQF6l13aD3z7sPf89sd5t >									
//	        < pw8v1mYH2K0EI55s1GFGmf8t4SjqffW8UWzHUg3ruJ3F103lB102yl97769530ZX >									
//	        < u =="0.000000000000000001" ; [ 000037966800659.000000000000000000 ; 000037979577360.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E24CBD81E2603C68 >									
//	    < PI_YU_ROMA ; Line_3837 ; 3hLwL6R111y3P39mVWpot93OKSA4L2mI736JU1T67l6Gjs5l9 ; 20171122 ; subDT >									
//	        < MP93DuAhWAS0h63R2k2lr4DNgAvR85NoA7KK5pjgr61iL23nRqx0112642hi5pXk >									
//	        < 14UUgwu1Mi2HjYM5YH8Q0pLS4rer6145pd04AJ6L76s4Dj832hV6Ql97c64hVaUx >									
//	        < u =="0.000000000000000001" ; [ 000037979577360.000000000000000000 ; 000037987237927.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2603C68E26BECD0 >									
//	    < PI_YU_ROMA ; Line_3838 ; 2FsRKQAT07n6T470aCinL4FxgV7gcK54E5zg78qzNoHA2457Z ; 20171122 ; subDT >									
//	        < aiB3yRl2Hq0oEOUv30wn9AZ6ObaWa7oVI7Dv9u6D3KN5u7978wQdUJVh3Xur1k93 >									
//	        < Vb7rWP6Pz1LxjDVwh4TZLYh7XsGfqU4AhPRNy1BpupVW9UrO9M6yOMlsM82r3ylP >									
//	        < u =="0.000000000000000001" ; [ 000037987237927.000000000000000000 ; 000037998817946.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E26BECD0E27D9842 >									
//	    < PI_YU_ROMA ; Line_3839 ; M5RLZu6p9qIUDQy49ByN2O47c43oEytc6s4KrNK69m50gC579 ; 20171122 ; subDT >									
//	        < 9RYF47p9rG2Of2MdX1A24i1CT4YfQwJq35k2IOsCpC6E07Ww9Msd48Kbd6wAfu3s >									
//	        < 5g0Mgw3z7w3v9hr8yBJRvP5nE6BYQ6mQ6h1G0H83FoFBZ32F51xS72YO8as20Gt5 >									
//	        < u =="0.000000000000000001" ; [ 000037998817946.000000000000000000 ; 000038010221694.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E27D9842E28EFED9 >									
//	    < PI_YU_ROMA ; Line_3840 ; Vvjwfw4aOH1ZD8nQ8Lx6Dk61VoGrHW1n8ZS4WtOW0vAT1U8D0 ; 20171122 ; subDT >									
//	        < LVqI40smYAq1sOatR8H2ded26LJW2HA5z4rl2PYuvCJUk608tubo4v15W68qqZ3W >									
//	        < 0kbp9X59X289B22Mm2PdO06EBqkCaTr9JazVD6i9IHyubfYh4BO8TVeE08V0evNU >									
//	        < u =="0.000000000000000001" ; [ 000038010221694.000000000000000000 ; 000038022046291.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E28EFED9E2A109D5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3841 à 3850									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3841 ; ppJ9grvqG6Y1F430sxPfLE8xYvlbd6t5VXFucPOx412699KZL ; 20171122 ; subDT >									
//	        < 26N7EH70YjA6RXN728nR7ShS5Y67C9NTlqoj01i5KBG7d61LBpQ90l4jEDy15NTh >									
//	        < n2fpJ0oHiMczUIF2I7p0fIq4jPDS54Q895sBpia4e4Ms2YW4wN44b4a0U60jCkzt >									
//	        < u =="0.000000000000000001" ; [ 000038022046291.000000000000000000 ; 000038035655581.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2A109D5E2B5CDF6 >									
//	    < PI_YU_ROMA ; Line_3842 ; PP0c4rx0Gau4Wpu4uNdLO713EaBflSbcroXXW93PkA1kGCzt0 ; 20171122 ; subDT >									
//	        < MOKJF9RBMX09goGpmm79Q0JP3tS89t1z40p8kiOrb0Nt1NW4UDg33Uc89s62CvVE >									
//	        < li8wQ20T8621t5CH2t0YppO263bWPvHu0i04DuiM9s0KMCn958Ey9kv52So4E5Vx >									
//	        < u =="0.000000000000000001" ; [ 000038035655581.000000000000000000 ; 000038047811149.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2B5CDF6E2C85A3A >									
//	    < PI_YU_ROMA ; Line_3843 ; 6tp38k0oLaS7D2ps7vP85jmmv97c5otrks4nxPszV43U662ij ; 20171122 ; subDT >									
//	        < D7dQe7cre62IgpQSyPm67kAUMPGPjXHxVt74t9Z4umWRVtj3I5rREKc8gNy6la84 >									
//	        < uO1uHE4hW4893GcvQFrzvO3GfcfyIsNEr7B5DYs640qWA806MLimOO7XlSP3M974 >									
//	        < u =="0.000000000000000001" ; [ 000038047811149.000000000000000000 ; 000038058381518.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2C85A3AE2D87B47 >									
//	    < PI_YU_ROMA ; Line_3844 ; Ts3NES20488zCUk9qLd4em1FaKYRgLyQ6yRg87SMI5IiL78Hq ; 20171122 ; subDT >									
//	        < jK19OtRtSSK70kuIJ6eF8h2l4mD201ErGDy289oRCC4V6ZBxn84QHQBF8K4dqo01 >									
//	        < 7RdyEZMmOE8OH6cF5T68h5ZbQZ4fiDFC1obAvXoLK1gC0nxO2wp10QM5VKlksPx2 >									
//	        < u =="0.000000000000000001" ; [ 000038058381518.000000000000000000 ; 000038066347497.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2D87B47E2E4A2FD >									
//	    < PI_YU_ROMA ; Line_3845 ; tQrEe4TT69xk6sQ318cy27blV70Y5owxtKft7MnmzD7TAZORF ; 20171122 ; subDT >									
//	        < 4T8m120319413oa5h7QS731c8x2e9Z2jj4aSq2BTHttFZeNYo8s0ho8cgz1ZHz5N >									
//	        < MTI14Hs1WKUotGRQ3MyDWNQyX6A5x4QWAd778JDcpooD8Ah7GAEC553kxCtemagL >									
//	        < u =="0.000000000000000001" ; [ 000038066347497.000000000000000000 ; 000038079128813.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2E4A2FDE2F823B1 >									
//	    < PI_YU_ROMA ; Line_3846 ; 91HP9Dy2eS486OMb366CMN0Ksreokt5R99oq8PCy83Dk73wm7 ; 20171122 ; subDT >									
//	        < IHuCzZ233wobiVHvN5LNVSia64I4nM8Qo8tD640S7K64pdp377NJL5e3KzGImaR6 >									
//	        < 9440D1qm34l2h221pzK4GBeD8HGE8ez43CT9XtRnVF0SCp1nM1tyP3548gMpOWQ0 >									
//	        < u =="0.000000000000000001" ; [ 000038079128813.000000000000000000 ; 000038087950008.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E2F823B1E3059978 >									
//	    < PI_YU_ROMA ; Line_3847 ; NnI09N2G8qDEB9dA2l2fUCKsHkB9246S9Dl857JhYQYc1l7Y1 ; 20171122 ; subDT >									
//	        < 6o6sxMqreoAeBEoM7qadnn5CN55j22n1u84qpPuf5sFB2AAiS9qxisM66xGwFg9T >									
//	        < ZM6DQ5BbTlTDAQLl3hB95seSjlGGS3P0qw6xv3I3t2x8mcl32I6B38v4ryUQzzd8 >									
//	        < u =="0.000000000000000001" ; [ 000038087950008.000000000000000000 ; 000038093950139.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3059978E30EC145 >									
//	    < PI_YU_ROMA ; Line_3848 ; u0ML03vakHX9Krcq1WPz190S492It3tP18xXq291kh2F12goV ; 20171122 ; subDT >									
//	        < 68spdceJPm6jK3Tj3gGprZG3dEeTUuL5HPWTBoyAQ4d3EgCs5lwj2c2X61mwSs2t >									
//	        < n8p6301w877pn3b9IEWeoYEfdRUp2NHY5Q6Vfo2F66iSWJZiy4hUx5KSdmal6H0F >									
//	        < u =="0.000000000000000001" ; [ 000038093950139.000000000000000000 ; 000038108021012.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E30EC145E32439B5 >									
//	    < PI_YU_ROMA ; Line_3849 ; DQcc2rN97tW1cGb3DzCesKVP0N0Hzm4b57OU9oH042kvpu7Ot ; 20171122 ; subDT >									
//	        < hJqfq7f4krvTH3rXz35ZU0Dsz3COXBtJV3PP8EBLE3Mgqk9il0do7pv8m4YWjE0g >									
//	        < nN9Ken4r18r9Lo6lzgq2LttMp8x8MBSz9lbZ71P1tqlXxTb14Nd6J1xU90glf8WY >									
//	        < u =="0.000000000000000001" ; [ 000038108021012.000000000000000000 ; 000038119203723.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E32439B5E33549F4 >									
//	    < PI_YU_ROMA ; Line_3850 ; XT3s53a5b9P5O00GW7649Jtr2KUgrGRanxg8SbfSZ0O7Mq0v2 ; 20171122 ; subDT >									
//	        < CP13pbmZ36B8T0C490NojCd1k0es56Sm9f7v5HYCU3bH00pEj3zR9yxtE67L44x0 >									
//	        < sz3qZ7NolO515ZM4MRw2wNz9H8D4fPON7CcnZE4E47GXRe6Lk3a16nwV6JjQ37oZ >									
//	        < u =="0.000000000000000001" ; [ 000038119203723.000000000000000000 ; 000038132502324.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E33549F4E34994B8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3851 à 3860									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3851 ; nystSTDNmE7kWoQG6OBb78k81yXsKeySQeUFdb0OM3xb76lxO ; 20171122 ; subDT >									
//	        < WjkvJ50VSWJ0G803Zng4aU0D7z48gRmBT4g06tqd3roNtm478M8K19eWdej0B54t >									
//	        < gFVa4SE9lVKRqe103WjY3Rh0t7v6g848kZqdV7Y0SjX11r4cuaY0ada8oO4AY968 >									
//	        < u =="0.000000000000000001" ; [ 000038132502324.000000000000000000 ; 000038142040815.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E34994B8E35822B1 >									
//	    < PI_YU_ROMA ; Line_3852 ; 0kGIHT31dPVV5dle0Z2VQfzq009KUGX6EGFF73PRBki61Fgq6 ; 20171122 ; subDT >									
//	        < 2kf0XIjO8vG3Fm8sN1i0Hgtwd86YTy7c261bzK55bGXNF3655C32pDQ1bU679z5d >									
//	        < hhey0L3f631gDb8m0Ubg83y0Ww8Ze5l13yGp89bSj2mzo1N6O19ZZbz3X0l5nkTL >									
//	        < u =="0.000000000000000001" ; [ 000038142040815.000000000000000000 ; 000038150349411.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E35822B1E364D03D >									
//	    < PI_YU_ROMA ; Line_3853 ; Qc9M13GZggHvkz3FST2Q5Byz3043U09jty80bbefZB5Y9F443 ; 20171122 ; subDT >									
//	        < 4riLd9UpMjvx5Ch7f6s3802OiiLzqWv8rLvVxnvLmtx4H8pfi0QJXMivJ1U4UaJs >									
//	        < 1LHju31bxII4VrM4Wynz330z4fZQMA2K9a1IBm6fFd005TMJ8e252Z9M6f07b3Z6 >									
//	        < u =="0.000000000000000001" ; [ 000038150349411.000000000000000000 ; 000038155959237.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E364D03DE36D5F93 >									
//	    < PI_YU_ROMA ; Line_3854 ; 8AbT7e8473LR9HjfzxCA2D46jO6xxU9kTd71ogfZIvNs4CsLt ; 20171122 ; subDT >									
//	        < 0t0l9bJ5KFqln8SG4mIslRKmHOJv2j54o2C95k8s3N6NCz0HEUb1bY1ICzgxy8JU >									
//	        < 93ngu3dHh35c70E5MM64opl54fNsub9PlTIL4UTphW006j61LJ3dM82m6G4D6YTK >									
//	        < u =="0.000000000000000001" ; [ 000038155959237.000000000000000000 ; 000038164355401.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E36D5F93E37A2F54 >									
//	    < PI_YU_ROMA ; Line_3855 ; 7uL2arMXk26q6R0LpBg8L2SGEANWFs3HJvSPe12fTg3H9Zxj4 ; 20171122 ; subDT >									
//	        < x0Z90Sm0T9v0RM616AGdc52BjI1Bt17pmzO75ulPF6Wst4gqVnas13EdmmpU97hy >									
//	        < 2h07Ap96dh7L2Z6xUp1712KVK74eNas34KI26MM3LmDOme5NLCyYPT2ftNMnqV6h >									
//	        < u =="0.000000000000000001" ; [ 000038164355401.000000000000000000 ; 000038173202980.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E37A2F54E387AF6A >									
//	    < PI_YU_ROMA ; Line_3856 ; sGnZ66Rn1qPtghxD884haF474LzCl3YrWop5LvkBJwtReLqj8 ; 20171122 ; subDT >									
//	        < gQ6wd0m2u5J51nZ8J1td1Qn1XC9MT81Os6pG2K259jck95kiHuZ92j4MJGe01MHe >									
//	        < A3mqzfhuZ5Mi3Jg32QMqZ0Z3yxft3X1eyCvZ2yctIv6HzL7dyOg0HZK2oM18xA1t >									
//	        < u =="0.000000000000000001" ; [ 000038173202980.000000000000000000 ; 000038180155286.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E387AF6AE3924B28 >									
//	    < PI_YU_ROMA ; Line_3857 ; 1hKw0O7uzeCNbc4cOpGm8HEPqrCoEwLbhA35342ogo2x452xc ; 20171122 ; subDT >									
//	        < 37q90GQGq51dAav2z3xkeaA9zZ2xUyDc93IS3r88T3eqM9Y8DmAyflm4et65ru95 >									
//	        < 656684UpCUvTz4uehGE2Wl6AG36ADGHCY00oqoLS09b4i2CI9NMt1qljPS8z15wU >									
//	        < u =="0.000000000000000001" ; [ 000038180155286.000000000000000000 ; 000038186537835.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3924B28E39C0857 >									
//	    < PI_YU_ROMA ; Line_3858 ; 77QGXx8F2mMGxXGocv7755pnArUnj752yt0ta09iev916LVBQ ; 20171122 ; subDT >									
//	        < r49e7Xca96rU54NpT4irw2M3u3fY9M8JD6k0Fk0P39aRtbXqJDk4x2gac3tAg0bO >									
//	        < 5sfK759dLeZBtM8iOmKwK5VpL01BJLAnpd1YyR65g9D19T113lrln8dDW9TN5SsG >									
//	        < u =="0.000000000000000001" ; [ 000038186537835.000000000000000000 ; 000038194738176.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E39C0857E3A88B99 >									
//	    < PI_YU_ROMA ; Line_3859 ; 8dcbTh5hy93gpWOYxfTX500gBbFRPh5gX6YQ20xZdQT7oM4pE ; 20171122 ; subDT >									
//	        < 543AfJz83nN4VEq57yGtY2qSBeYy15vG1WZJrBB10TBI4B4y63a7tXvBS4kzM8mz >									
//	        < BO0oWKN2107ewB627TF4LQxv7ADz2I5JcirGX4MFP6j0LY3t62wUD4FzxxXj9vwK >									
//	        < u =="0.000000000000000001" ; [ 000038194738176.000000000000000000 ; 000038206167109.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3A88B99E3B9FC06 >									
//	    < PI_YU_ROMA ; Line_3860 ; YF99ZK76UyNQ06iZhy8l1gY0YhUC6u19L8iMI7156Eza5upBl ; 20171122 ; subDT >									
//	        < 80loYilP94O3SPk87M684uHcu6XyECi4vaOdxZ83Z3R3VwtMU9DyVxEZWkTawI6H >									
//	        < 9Pu6CM9Ea2JktOkbYoFA2ivJ17j2941wPLnEed132LV5PxIxh0N4311gitJ95IOG >									
//	        < u =="0.000000000000000001" ; [ 000038206167109.000000000000000000 ; 000038217471097.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3B9FC06E3CB3BA5 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3861 à 3870									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3861 ; 9F82PG6bLuM7dBkK0VFtY79253Kw6Wonh5YXuNYBf24b6n2XB ; 20171122 ; subDT >									
//	        < 3RpD4KPy8Yd4U23PI3x4S7H8611PmSq1YuL0gFO0QqGS0K5wW472wccaV9YrtZ09 >									
//	        < h2531LGNUcgDc5m07s2b1GV0URK3CstGS47hZ68cm993vjx4wc29KSLp55S7lK55 >									
//	        < u =="0.000000000000000001" ; [ 000038217471097.000000000000000000 ; 000038227112205.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3CB3BA5E3D9F1B4 >									
//	    < PI_YU_ROMA ; Line_3862 ; dGl2717k1EZ27iud8ree9aZsS416819EFFa0332U9709kBmv1 ; 20171122 ; subDT >									
//	        < H3249Rw8N7o4u8v62xQ1dB434O9x2p4SpnzcYLdzQYH09geTeg51vW0twgZPtWI3 >									
//	        < 87rqElNuJoe48Io00twKkG4i3qT3tVa2mWqGL05jNx4VDVnJ00zrQh200AIDSk9a >									
//	        < u =="0.000000000000000001" ; [ 000038227112205.000000000000000000 ; 000038241232186.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3D9F1B4E3EF7D52 >									
//	    < PI_YU_ROMA ; Line_3863 ; 9h9cNOYe20sCKB7HvOHp9CFyN474f55g57S15j68sQ70NDR3b ; 20171122 ; subDT >									
//	        < wk8mNxvga9iq7gq1c346oHABAh56kCBvzMd27kEsBCCDfKaEcuc7X61L5FN28XYN >									
//	        < KD6MmFvxXEGZEF9r0eRbpyq7dddC4HGR34S6NAKXSLFaf1M0mRH3pdoY0sc20QPv >									
//	        < u =="0.000000000000000001" ; [ 000038241232186.000000000000000000 ; 000038254090182.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E3EF7D52E4031BFA >									
//	    < PI_YU_ROMA ; Line_3864 ; 99TdDqICBOP8q45cdrG56W9MlBB4I9Hc75CaF5M6XL18TIola ; 20171122 ; subDT >									
//	        < W54iUvptYBu81fhXiCj90I5BZuex87Y2F5T6agM1u7d4rqwC8ve9N7GkfbN58wJ9 >									
//	        < 0QglPn8QVn0CD06TGQl8o9jdN1cI47k90WbJSu3z23bR3zIL7Yb4U8H0Ej9RPdIk >									
//	        < u =="0.000000000000000001" ; [ 000038254090182.000000000000000000 ; 000038262319800.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4031BFAE40FAAAC >									
//	    < PI_YU_ROMA ; Line_3865 ; errlUQpHoA2I7118Yce09fG6D3hK7y074WR71591nf45Zwong ; 20171122 ; subDT >									
//	        < 350WW5yGKf4P06d76LsP3rGSsz1LKU2qC2XF3r93NVh93D6Zo5c5LFtUMSd72J15 >									
//	        < T896X72u6chlk84Q66YMNM9E5l7833dQV087R6fhoxoZ44O0sOriSLW71YNTS0xL >									
//	        < u =="0.000000000000000001" ; [ 000038262319800.000000000000000000 ; 000038273623297.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E40FAAACE420EA19 >									
//	    < PI_YU_ROMA ; Line_3866 ; 96l3HK1MW12I331jDr1t0J4553d4T6zKJ0VIUaHAb6JakuO18 ; 20171122 ; subDT >									
//	        < xKRPA2t3ZKbqbOtAm2fQYXBB64rB1XG3zdW0te21kr0eN3x02Cz0OmR7HKDQZfZR >									
//	        < K85PDnFgMhf7M8UZ6W2q6o9SyZ42GZhqg5i18an964syh930vD3Vi9BsnNswR0Si >									
//	        < u =="0.000000000000000001" ; [ 000038273623297.000000000000000000 ; 000038286421516.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E420EA19E4347167 >									
//	    < PI_YU_ROMA ; Line_3867 ; C70Hkks1tP0NaqB0xiZ4at56DLkpS3iq3dmza0U2O7QvU17g9 ; 20171122 ; subDT >									
//	        < 01BX6ys29xj6iJGM6NZEP3G8H0LGB1Pb6vx3WvjL9k15Aj57BXmm883OgG6lx3Zu >									
//	        < VB3KlYZwvVgP00w1gGF43i2bcT6EX2HfLhO5ZPuM122hI4Pd5bmz70KTYn0u2BEz >									
//	        < u =="0.000000000000000001" ; [ 000038286421516.000000000000000000 ; 000038298938652.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4347167E4478AE9 >									
//	    < PI_YU_ROMA ; Line_3868 ; BXj5244lZI2xV15Z3GK3duyt9Motqro1mrwy5GLMU1ChRD8yB ; 20171122 ; subDT >									
//	        < 4637CWS9XPDBXqNcl9K46VeLd0Z5GG9g8bPHL0aP6cjT8w5VPSrhcVoNvnuut5Iw >									
//	        < NZQ4qlhU0gJ11rJBy9B0Zc7o98PDr85E7IOxmYeL62ho5c212j68oxlB0lbYd9x2 >									
//	        < u =="0.000000000000000001" ; [ 000038298938652.000000000000000000 ; 000038310992570.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4478AE9E459EF79 >									
//	    < PI_YU_ROMA ; Line_3869 ; k69IeD622sa0l4nm56y1z0J5af1GvOSSXL58H0LWbihOUZ4yD ; 20171122 ; subDT >									
//	        < 53BWTiJGh97nERXveH3uwnaaWw0HpH1S9HNd3A9hp1LVOSj6aXI3VcB2YaodcXzR >									
//	        < UyGeac8K1eG1ZsQ0Zukgqm0b72R5pvnN0W1QrLmcK9HdM6Y5TEr1vUS24hegXvtz >									
//	        < u =="0.000000000000000001" ; [ 000038310992570.000000000000000000 ; 000038319839200.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E459EF79E4676F30 >									
//	    < PI_YU_ROMA ; Line_3870 ; 6OtOk1gVF1hpx61535G4bQ6kmsAp698p54ZuIHRB52irR8BcB ; 20171122 ; subDT >									
//	        < E3LCm1lPD5ApR59e1ldo6299OK1V4KnyotEpzBxktEU4tXQP9b9C6DcIWn4a19Zz >									
//	        < AYc7j82310LY3q7f6S8e8jd4OG4mFm5b4AYYT2rUP31j1eHK1v5saURDc55QRKv9 >									
//	        < u =="0.000000000000000001" ; [ 000038319839200.000000000000000000 ; 000038330691996.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4676F30E477FE8F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3871 à 3880									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3871 ; WpA2ExWVxWbQFFxE3Wr1Ch36L05MvObEjcz15255BQ9fK9jnR ; 20171122 ; subDT >									
//	        < 3xJNKsg3QcCqMdK915YR20G4798GUxI8x9236wu60OxkhiOHV3EY5NCQxEAKbC23 >									
//	        < EmK1dp1r6ENR52e8INi3fh93Mr9EBt9X8P3P86A6isPNFw3j4s3hB08UurL6i7bX >									
//	        < u =="0.000000000000000001" ; [ 000038330691996.000000000000000000 ; 000038339015772.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E477FE8FE484B209 >									
//	    < PI_YU_ROMA ; Line_3872 ; D9d306n6Q9F20C70c20ey8GI8Y2so58rEHujlliyqiL579X38 ; 20171122 ; subDT >									
//	        < z7HALCQ7Dpm33F82Z68IvRk6Zw3Q7KoaVIhIpsZ307dMsIY5o6h8wV5dg49td7o7 >									
//	        < 90L7Bps6VobGFtmIVfTyPol8k3r07z1T64y3X4Xx897zVl250uo2j5Epizp2vn28 >									
//	        < u =="0.000000000000000001" ; [ 000038339015772.000000000000000000 ; 000038349315259.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E484B209E4946945 >									
//	    < PI_YU_ROMA ; Line_3873 ; LyN5W808hx2R0UAA58fBg4Qf8X0H82WK314Z3F291OzM0gsV8 ; 20171122 ; subDT >									
//	        < Jh8NYZW9TaH24eeuzo8Kw079rX4acQ69oLchjp8LGoCNd3ve299ZFi6i0oKmR1uG >									
//	        < 05M194ILl6i0wlIH11rv9p0W7sl498SutvK53AeZXiOp16JxqJT3BYM35JzaPgXn >									
//	        < u =="0.000000000000000001" ; [ 000038349315259.000000000000000000 ; 000038361386238.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4946945E4A6D47F >									
//	    < PI_YU_ROMA ; Line_3874 ; Qn380nNEkkpOY01k9EX0DW42K74nthRihg4C5980mfUnD2UJ0 ; 20171122 ; subDT >									
//	        < kQEGhtF5L93A3776nX1zl3IUu4IqALtOSb72R1frglwOByJmyAflZlAYdVX66261 >									
//	        < ir2PniJ18LYcj8AjC21f8E6STCq8sy1LBw5Ld0KS4CO5fC1h2umw6j78rl05b7JR >									
//	        < u =="0.000000000000000001" ; [ 000038361386238.000000000000000000 ; 000038373222528.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4A6D47FE4B8E40C >									
//	    < PI_YU_ROMA ; Line_3875 ; 0y9TWp50txC9n56EVF79OBjow9HwWJixl8cB9qKSdtlIqczep ; 20171122 ; subDT >									
//	        < bAnX9uFuD99119D199g8GrhbdhmApq9rzc6DImL4q87DLNT46vQzWG3iVa7ovFUF >									
//	        < IRwQc35N0RxlgIDKxtqtl5SebOkb1KsaLrtY556b1l18Ts40TH850v7B4Wxs1n83 >									
//	        < u =="0.000000000000000001" ; [ 000038373222528.000000000000000000 ; 000038379288330.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4B8E40CE4C22581 >									
//	    < PI_YU_ROMA ; Line_3876 ; thU0UXYpT0nFDdoce9h1oX0Bry5wg628hQIEpiqND069vH67a ; 20171122 ; subDT >									
//	        < b79oFG14Gf7W467888IhnDCIT59rX97n3SgEoOEP36zsOrVcClf2mI9tDa4k08Gp >									
//	        < D3bS6uKV05SUoa98WQNBf96M8M1bCD1rI64ctWqAparXt0WdDD2l1xDX23qE1xl5 >									
//	        < u =="0.000000000000000001" ; [ 000038379288330.000000000000000000 ; 000038390899592.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4C22581E4D3DD27 >									
//	    < PI_YU_ROMA ; Line_3877 ; Cg4BWWF9M3ooUV6kIZrAN2l43bXR6ROHm566QIRFEFyb12pW8 ; 20171122 ; subDT >									
//	        < H9ZDU77W8HgqZOf4jPhvK241Pxh24UNl26E7B0Kgf0H9JRaHr136H15YObMQZFr2 >									
//	        < K881w8XQJcc3Z16vVtfxfCi3v9UR6v9S3Mnph2vz819si5AuJ6bUzFXQeJUX4BM8 >									
//	        < u =="0.000000000000000001" ; [ 000038390899592.000000000000000000 ; 000038405564896.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4D3DD27E4EA3DC9 >									
//	    < PI_YU_ROMA ; Line_3878 ; 69Ov8e60zxBVYhk4floqT88ZnkA80q2l6WKg9TO0Id31LvFk4 ; 20171122 ; subDT >									
//	        < 09fLijhQ24q43X73OFKmLcQ1TcuPZ5m7yZL1dg7ynTFHYD86fIO5ZAOQzS19grVG >									
//	        < YHBQ9KTh0At9LYc02u4oAy6RvJBMos84S3QlZB3avSS0rRCNj3XT6p7q5X01E87v >									
//	        < u =="0.000000000000000001" ; [ 000038405564896.000000000000000000 ; 000038412478467.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4EA3DC9E4F4CA66 >									
//	    < PI_YU_ROMA ; Line_3879 ; 360Rgl2akh027i1cJhJqVl1EzXC4q16lumFxKbQ64ncAV01Np ; 20171122 ; subDT >									
//	        < aGI9Mz0u9I69eF09dEIhsnt9pOkihcy16toZRX9GV57E3256TUI2d4xE3pa7IPdG >									
//	        < C42ei1N16e3xX126tzbPPNzjGTweQnqo90rSeL308nQM6QKmp9FS8T1P7vjtUc1H >									
//	        < u =="0.000000000000000001" ; [ 000038412478467.000000000000000000 ; 000038423711096.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E4F4CA66E505EE25 >									
//	    < PI_YU_ROMA ; Line_3880 ; fW8M7PX4lmPXvPVLw1v71N82KJ7NWEiBgm28xyFzIZpkFN94j ; 20171122 ; subDT >									
//	        < 3MV8RZ89Z9qrzWER5DO5aE9F3i8eMq4zMH4k8z8Y1bZ0qj5qC6N829r5pcCQ8Hh6 >									
//	        < 46g7g0V7Y13XBrYu4WlOM9gKZM3Ec4NW1j6H2yY6QO8359U3hihf4UNWq81z4CWB >									
//	        < u =="0.000000000000000001" ; [ 000038423711096.000000000000000000 ; 000038434002084.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E505EE25E515A210 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3881 à 3890									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3881 ; 1oHbAJDtkfP4R4v6u3m6maVXU4TZit2s9FX83i4nRX46O5b7L ; 20171122 ; subDT >									
//	        < 7H1Z0nn54D1lc3l6BIE0cj0PlKGBF5plIY6aaB4swG0S6gS3L29263rR59xKh1Pm >									
//	        < IibE83cg7ZJb577vdIs1FD5vBui3SBPtAoMtQngTVukG86knqwqGndja9Trph1q3 >									
//	        < u =="0.000000000000000001" ; [ 000038434002084.000000000000000000 ; 000038444995631.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E515A210E526686B >									
//	    < PI_YU_ROMA ; Line_3882 ; rcU7O365JBKSKYFt5b3A9WydmS1YjD2hQLOjarxBqsk64mrJZ ; 20171122 ; subDT >									
//	        < SdPH7j23N4k65CF1MPg6E6eB6PTOj040xW852By1Cbd67FOAw69b3gcbXZQOf544 >									
//	        < 2Gr3IY44Te31DkhV7P34k7vE7E13LXfVD9R1q8Ly37RHede9iq3d315Oho34b2Jf >									
//	        < u =="0.000000000000000001" ; [ 000038444995631.000000000000000000 ; 000038457014622.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E526686BE538BF56 >									
//	    < PI_YU_ROMA ; Line_3883 ; pBrIfb7T3BFgCvlg20JHsJu9mDXHPF6FAlAp1msm8HIZ4KUfK ; 20171122 ; subDT >									
//	        < 9s5MR190rS26tj39cKt37Qq5q28sERhe3ZC3H7V4TJ0sHpvx6jwPKE4TQ50VyuE5 >									
//	        < T0JfR1t4qIXiWunRdtJ3fpx9gbvxAa15YjMaKs5Kts4y7GN0qUD94ih6L4B23iLU >									
//	        < u =="0.000000000000000001" ; [ 000038457014622.000000000000000000 ; 000038471623783.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E538BF56E54F0A0A >									
//	    < PI_YU_ROMA ; Line_3884 ; 1641yqUI0VKMSR8unKCwRC9c491YdJ5yy7mNd1S6qNuKRZIKe ; 20171122 ; subDT >									
//	        < TIw104raIy1bkRXPwiD32qVb33cgTt42Pcy307aWjZ6j92Vjzd76Tx36jr5L48PC >									
//	        < 1n0C52v42udXTdWsc0K63710N41M152Ez23c8S1MCE5Z4y8Q1Qe4i9073n3TR5WH >									
//	        < u =="0.000000000000000001" ; [ 000038471623783.000000000000000000 ; 000038478799133.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E54F0A0AE559FCE9 >									
//	    < PI_YU_ROMA ; Line_3885 ; D95EwgZ680aAQe1x10HTDPC89Z6I5P1sdTaqPlJXOEGH4rJY2 ; 20171122 ; subDT >									
//	        < lpPaN5b8nJD605l2l6NxuisM9zeutPJ83yis2ZS3GMMa7X6lf1V8450ud8b9O4Rw >									
//	        < g8VRgsraQqY5z9NC6P1WBt1Zct2352Z9fooNKpXh5ioD8cN4Fd2O9b071a5Q7ioM >									
//	        < u =="0.000000000000000001" ; [ 000038478799133.000000000000000000 ; 000038490845130.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E559FCE9E56C5E61 >									
//	    < PI_YU_ROMA ; Line_3886 ; 1RkY848hxeLwJ5Qg2780soI3GTj26y65OZ2zNhIcO95GjQ9e6 ; 20171122 ; subDT >									
//	        < XGX45f1q4H5FMY8FL6hIc5QyKDQY7q07LkidANu0AvBd81tazPGeK8fgsBP4nO3S >									
//	        < Rk82Yu6j1Svy5k85D53Fi0axUG0I5l2DKp89sIcG6u1dUd3U8XI198nIuv84LZU0 >									
//	        < u =="0.000000000000000001" ; [ 000038490845130.000000000000000000 ; 000038498823068.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E56C5E61E5788AC2 >									
//	    < PI_YU_ROMA ; Line_3887 ; fQCNgv62bnAar5ln1BBQJdr8q9x7CsR4E6W8y67Z1wdtBecwa ; 20171122 ; subDT >									
//	        < 599r4KMn6tPPx71kvjg7xzp85RsAN8707O8X967jx0B4fJa7sSQ2INeNOG5RAyEQ >									
//	        < gqP3h3F9a6Cn60ae8dWw8Ors9r5gRD7N73M0nkXDiw0txB48ayR53M5gjT0t4496 >									
//	        < u =="0.000000000000000001" ; [ 000038498823068.000000000000000000 ; 000038506829772.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5788AC2E584C261 >									
//	    < PI_YU_ROMA ; Line_3888 ; 1SbAtS9206UAD166E8Lh3b0D60JTr9Dc9J0G3273yMTbU4Hea ; 20171122 ; subDT >									
//	        < 7v7hy8WMaXLU7Xs4qP0GP42aYEGQymz2q81D9cU2d87k0hUEgx3nV8ZDEbVbJJ88 >									
//	        < V2n3MI856C9q2gX48EFIp1mJx817Da8nWDgh9YezKgUO3aNv96q4eV29W9QhKBH4 >									
//	        < u =="0.000000000000000001" ; [ 000038506829772.000000000000000000 ; 000038514784948.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E584C261E590E5DE >									
//	    < PI_YU_ROMA ; Line_3889 ; 9CocT3z9Tg65cvryHhG8z83sSQz0cfDpElY7g7nt5ol4OiaU8 ; 20171122 ; subDT >									
//	        < wxHfVCS4R3CaeEN0fPCpd05gZFAJ4L0l910i9cmYeq7j0f4sg7hZ5xAkqQ1Kd1Lo >									
//	        < 8670S0b2Pn6IDHn0KSAOxztb8trEux448681956M8E9Y6tr7isYcxFOTi06Trir1 >									
//	        < u =="0.000000000000000001" ; [ 000038514784948.000000000000000000 ; 000038526893140.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E590E5DEE5A35FA2 >									
//	    < PI_YU_ROMA ; Line_3890 ; 5eQUR9c9A0iGHRr0S44G450HD33P5zuG5K1OFAB712Aa6BTaB ; 20171122 ; subDT >									
//	        < TFcUUnDBovWCJYFiLbX7sHYGq1VIct6s4B8QjvnCJPkJQsPbky9UN7FELYR66gcj >									
//	        < ZY4skNP0wPpR47ZjD93UR1C0J3Q39i8Y3pPq07o61A3J66s10hy7UQsmhbHGO01f >									
//	        < u =="0.000000000000000001" ; [ 000038526893140.000000000000000000 ; 000038536818247.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5A35FA2E5B284A0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3891 à 3900									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3891 ; MWfNvKii4345l202I8qOk9xpsH7K4p79X57u26w3ITLVQpl2m ; 20171122 ; subDT >									
//	        < UTH3JpIEURVB5ps9FffBB9TbnKUMgh3gG0y50KvAJMP94WlMVxstQVAmLBVZWfB2 >									
//	        < 6x7ezsPVQ76xg3AuR5986LG8JGfM2Os7mEs9nFbY5nw4w4FvJy62Y74JPz3HdYu3 >									
//	        < u =="0.000000000000000001" ; [ 000038536818247.000000000000000000 ; 000038544025951.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5B284A0E5BD8423 >									
//	    < PI_YU_ROMA ; Line_3892 ; HPfBW0wC603S72NU617MHI3K39sGJ2750Qu7r75uRjVEDVneF ; 20171122 ; subDT >									
//	        < le8k72mb64Go8IisOoBtWDhx5lz78TKe6Mpk3H6zDk52V2iu87s22VQTOydk37Op >									
//	        < Xn7q10f22cc5U7d5vEk5Zzt45E8B6SR88CjpHMgbp3G82Rgd3em466rBof1437Jj >									
//	        < u =="0.000000000000000001" ; [ 000038544025951.000000000000000000 ; 000038555700156.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5BD8423E5CF545F >									
//	    < PI_YU_ROMA ; Line_3893 ; oa8F787aoTy5qC6i2i63u42D1u0QPrsFr58418YMMFX3N8i6S ; 20171122 ; subDT >									
//	        < MHIvY4w942y32oDUcb1xXohYPIz0ZY6lM15RQCAP4t83hB9DF21b68yaHvPOZdEi >									
//	        < 7MItkVP4Orm046J4iOzeMx7cVsdaVv19WqthVGHe1JOh96Iv2s1ResdSZsdWoH3a >									
//	        < u =="0.000000000000000001" ; [ 000038555700156.000000000000000000 ; 000038565307942.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5CF545FE5DDFD6A >									
//	    < PI_YU_ROMA ; Line_3894 ; 68IhT54qEx0o3k0y8KGyVPGqs4s6O3owJo8004i239g4cY55e ; 20171122 ; subDT >									
//	        < 8aqd2uGtXCe6701Mt33x56mpH380Ce3ZvL06svMU1W2oTXSbcN596MBEcLf0b2HI >									
//	        < b1p3W4cVyfbn6JsRzBKg00iUddwB7EB7HifJ0b4geL22Te9dI3UJVhTxVNu1Rw2U >									
//	        < u =="0.000000000000000001" ; [ 000038565307942.000000000000000000 ; 000038579653619.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5DDFD6AE5F3E131 >									
//	    < PI_YU_ROMA ; Line_3895 ; fFaQ6DnK3Wqk319BtnC9os70RcrJ6NPqNLaQhnSx9SKqEx9Qr ; 20171122 ; subDT >									
//	        < 9s1PywIJyMfCmwMQ72H8su5vhD9LVEsgJmfsT7q0fc9mj6T2qq8Dx182CA5jGLZ5 >									
//	        < gwKcJmS180cDEj2h81218tnY9G346V4fo353dK93x3QKUDa4hBd6dtSPt8CH8sGy >									
//	        < u =="0.000000000000000001" ; [ 000038579653619.000000000000000000 ; 000038587371095.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5F3E131E5FFA7D5 >									
//	    < PI_YU_ROMA ; Line_3896 ; 6v82BrZ4dF0B8Llb7qJ7oEXu3SfY4k8AiO92418d3cHUDl46J ; 20171122 ; subDT >									
//	        < LDc8V9gJ838yiNxxdpp6WX13ge3zDd96wNMn0a122JW3905471235PdX1Isx20lz >									
//	        < 4UsBlh029xxJ65b1pNH3Yl53pQ2I9777sQR0F0xZULX80yg5MBNIIw8EsbsMxlK2 >									
//	        < u =="0.000000000000000001" ; [ 000038587371095.000000000000000000 ; 000038600662281.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E5FFA7D5E613EFB4 >									
//	    < PI_YU_ROMA ; Line_3897 ; m1NXGEKjQN96Q32ZWfgI063T9ZufkgvUK9oc2Av9AI4e92HIB ; 20171122 ; subDT >									
//	        < 05g9KFMsgnkn91Oxa45dYlE2P5dD0o1l5EfAkPKYg5L9nuH7fa1C861QDpdiwU5y >									
//	        < Wds39a1AFx5Eb03xBxPr8JH4L5v706gDBHGy2X3kR53jHt9sk448JGf0TqJ8aBTY >									
//	        < u =="0.000000000000000001" ; [ 000038600662281.000000000000000000 ; 000038609341964.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E613EFB4E6212E34 >									
//	    < PI_YU_ROMA ; Line_3898 ; n75W7Lu18X7pE27OO0VE818PUIW14H2ka7UFEn0TcszEIkSl9 ; 20171122 ; subDT >									
//	        < Y94QaqwRBMgnVTpp8PXPQ58yViDn0S55G069I52FThFGC3D10Pi8fIXWXHL56XBM >									
//	        < r7cibnM8S25TwGoFwjbuWasA79U7jgp6Ct2ElvAYj2Zylj5yxc2HpsqiWZ0QiQjG >									
//	        < u =="0.000000000000000001" ; [ 000038609341964.000000000000000000 ; 000038614795081.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6212E34E6298054 >									
//	    < PI_YU_ROMA ; Line_3899 ; YAvA5i3KR670Lp4v7v0Q6c6Fg24koAA3BYBN8Xw09yo7Mf0r2 ; 20171122 ; subDT >									
//	        < 6kWdZS5Nx84E0td7MGMnSagAfr2Iop43sg7zYBBn5ea6nmT1zvxzGHk5z4cFb67F >									
//	        < 80k3v4K89Ou40P7YbEkiN77D2zKyVHnwsY0VH865jbeJ0ZHjNaUsO6Z77kwynC7j >									
//	        < u =="0.000000000000000001" ; [ 000038614795081.000000000000000000 ; 000038623268140.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6298054E6366E1E >									
//	    < PI_YU_ROMA ; Line_3900 ; SnlxsFtszVZRPHx89i5q2J3H6N22kHfW669JFL5b9irwbp768 ; 20171122 ; subDT >									
//	        < 2k4ZinMdep5Uw60B2u312YUY97Adr2gV0415rTYxgNV3sJv6a8Evtt2v1p06N3kq >									
//	        < u951P1tf0K4odPMNy915TN8P83D5HrL4j4b8yGX3tz3xhbP542TaOE8T4TeVQ544 >									
//	        < u =="0.000000000000000001" ; [ 000038623268140.000000000000000000 ; 000038631616431.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6366E1EE6432B2B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3901 à 3910									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3901 ; 0hl9fKIBxyXM2qUZG68re66w8qPlveTUwHZi0sU3T5eXioD6C ; 20171122 ; subDT >									
//	        < 62dRQroe1MXv3mlnaZ894Vd1T0wbBy1AM54OuPhaFw94U9gybZHzRGjli4EWTx1j >									
//	        < WiZt64aVUve5uAs05m8vke95vvHF46TSCcuWll69547zZg8Kt9Ahg0Ga4wTkWVC4 >									
//	        < u =="0.000000000000000001" ; [ 000038631616431.000000000000000000 ; 000038646127930.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6432B2BE6594FB9 >									
//	    < PI_YU_ROMA ; Line_3902 ; xl0mHZa414HrkQH8U3h7b44pmAmq3OqKsru82xzHf6DtXCun1 ; 20171122 ; subDT >									
//	        < k3UW8DQ60oIbdNrswL1aftRx0o4C77N48z1HA9jXkGH9WES1zWEi81UVIhAF51jV >									
//	        < 4dBVVe80j2o5qdI1P484FbMy5w04UDl36ZTJKTLk8CAAB2nglw2wQC4iOy8vST4y >									
//	        < u =="0.000000000000000001" ; [ 000038646127930.000000000000000000 ; 000038656013564.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6594FB9E668654C >									
//	    < PI_YU_ROMA ; Line_3903 ; sYIJT6EM0093bw5MQDFvgRR8HXGz2utsO786YvBIAu91O8XH7 ; 20171122 ; subDT >									
//	        < iN9J2H18rm8XaDh5S5LM4Dob2s9408GlQ6b4vcXMc88w6SrLsf3i08rIUxU99rKO >									
//	        < LOl211zDK8lK6u0clYw30W13Pk6EiIuu4WKB9E8yGX79H3ruMR3Q5b2720iHULyB >									
//	        < u =="0.000000000000000001" ; [ 000038656013564.000000000000000000 ; 000038662132739.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E668654CE671BB99 >									
//	    < PI_YU_ROMA ; Line_3904 ; 4A28QV6q5BFCcK5rFk9g8qg7S95vj13Fu2FkZkX2317kMaN3t ; 20171122 ; subDT >									
//	        < v035DnfZAJKkBbN2GQVGqyGZpgUjnGsm7EUTian7Zz0Slp41yXDgx1Wv43F7RpmE >									
//	        < Y671SCT1m4ZlU0wzjg6FaAmz1cC5XQ6oc6uq37y75yH412u50O5fA3lqunTKT3N5 >									
//	        < u =="0.000000000000000001" ; [ 000038662132739.000000000000000000 ; 000038675401789.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E671BB99E685FAD2 >									
//	    < PI_YU_ROMA ; Line_3905 ; xvp2dMA1Xn80X2APSp4lVCWYjBqm4m3u3dwwcBZ77T1u8sf0T ; 20171122 ; subDT >									
//	        < wPCObXs396l931P3s0XsB3i6iuho8HR177Tte6KK00dtjM8SVEbhTsfg1q055IQ9 >									
//	        < Wqp9eiIq86Z40JCw0ZPxWVR1pzuXkZ094P55uXv6q85Y5R0bY8eyGh7M7brZq8Bo >									
//	        < u =="0.000000000000000001" ; [ 000038675401789.000000000000000000 ; 000038688406473.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E685FAD2E699D2C7 >									
//	    < PI_YU_ROMA ; Line_3906 ; 5t0B2mwF783qgX7X8uu2GeHmhRKrM4UO45vEXW1QL7nC39Uon ; 20171122 ; subDT >									
//	        < yK7nU5grf67G07Z2LEMDCK1bTv575Ss1smrHTiy4ssPhe5cFVRTD78tWgd88t19V >									
//	        < 5px23ESA4bQw9E4IsF40LN7crLM8ukeTrl71WO0R7bhXS9GYcluX5S78LwI6ULTg >									
//	        < u =="0.000000000000000001" ; [ 000038688406473.000000000000000000 ; 000038702194694.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E699D2C7E6AEDCCD >									
//	    < PI_YU_ROMA ; Line_3907 ; r7P7vkw836178EA29DDqKZfD30G7h7ew7ZVwk1H1CoUc32915 ; 20171122 ; subDT >									
//	        < uIHRaJYGHC7Hum2N4m3Pvj1wSU587BRTd05b700z5V8l7iS03f9RfweHSddM1nI9 >									
//	        < EpIy2R3Fy81HpP5fZ4a3kRqe972dli3ZKH56E9X6T5n1bUkvRy26LsicBiMo87Fm >									
//	        < u =="0.000000000000000001" ; [ 000038702194694.000000000000000000 ; 000038714033061.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6AEDCCDE6C0ED2A >									
//	    < PI_YU_ROMA ; Line_3908 ; 6GkWVp1IQfJKoG6LjPhFGFm7976qGNf3ah19h4noQE40Comqh ; 20171122 ; subDT >									
//	        < 4Q3s8v5auoxSVc60Cvj0iJc7rv11T4a6i233G9EpRmoqvmVPzLW8bEEbwu5144TH >									
//	        < oc7zze2l7MuNMT1f0MhJVP24rHwzw5x9V4kMy26NDwzgQvbN0H9W9bg92A7G003c >									
//	        < u =="0.000000000000000001" ; [ 000038714033061.000000000000000000 ; 000038722724266.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6C0ED2AE6CE302A >									
//	    < PI_YU_ROMA ; Line_3909 ; HJ5eNd3a83hT2SDNsn4yzLRP16YG8lnhWQw3mBilxMY9086G2 ; 20171122 ; subDT >									
//	        < Y7NGOlgf351om8KVD2D36PIYGtM1L0X06b9T013D13r4JpdVwImq3P8d4YXRy4rq >									
//	        < 640fgiY7FFIT8936t7B97LwZs8sK548OX8fEq76e0zZHDx5Vgo88p86l7BhwQOu3 >									
//	        < u =="0.000000000000000001" ; [ 000038722724266.000000000000000000 ; 000038736065290.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6CE302AE6E28B81 >									
//	    < PI_YU_ROMA ; Line_3910 ; D7rA0U1yc62T7iGN2WHxkw41f3B8kBlsT5I3568468CDUulBh ; 20171122 ; subDT >									
//	        < uwjfWFIhuO75kHVCu2UdHIy78Vi6yaQn6y9QdTvofK8y6177vs9YT0g8zq9n580D >									
//	        < k22NII7oT2i93WvM36tCf9aiFxB1ReER0t78g6CvzuYnboQ009707hE6SOlfcyLi >									
//	        < u =="0.000000000000000001" ; [ 000038736065290.000000000000000000 ; 000038747580449.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6E28B81E6F41D9C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3911 à 3920									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3911 ; 7Cby1STZFtljtQ3a5JXOwK7NT0onC942e5v8bXLw62wk3ra2u ; 20171122 ; subDT >									
//	        < s3bPS47Q6TvYA0GuIWElr42TOh72O1q0jUs3l7yxCv84Ai1ZJFYm6yWs2e289F4r >									
//	        < 468RJfJgB5MV83w0E274Ff80kn41pvX9fTw1jSZ7y5gkpr44O5Dw2R70O855L5tC >									
//	        < u =="0.000000000000000001" ; [ 000038747580449.000000000000000000 ; 000038752589821.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6F41D9CE6FBC266 >									
//	    < PI_YU_ROMA ; Line_3912 ; fsJIOtPQBP8Fcy27IeC3c5280xiN05NF9dcT2929YSF7HaPvz ; 20171122 ; subDT >									
//	        < 54p8171IE0g1X9aGuH7R22yxo1hnu8O70qpwdp90siWYB77YSpuY3ypQY6c5wpS0 >									
//	        < g8sdmQox00uRGe7p45j28siCNGC89iAKUnxPB7JGtbK9flnIQHOEf1Gqk1q4Jf5H >									
//	        < u =="0.000000000000000001" ; [ 000038752589821.000000000000000000 ; 000038759362592.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E6FBC266E7061803 >									
//	    < PI_YU_ROMA ; Line_3913 ; eU4ar3TaYzcajkwTh2hvI1Z5298o62sWSCb9ZPjM0y76x56mN ; 20171122 ; subDT >									
//	        < KCV5xP7ZSGd2CugaRQr62za8nzV82dYbeJXD4C64TO15wT0sOcpG1sRJObe993QK >									
//	        < jn4xoJ1dSdS92wI77OI1mhl9GjDmo5E5rJkpT2z6592ftNJXwbiR3Enm2bjDnUTv >									
//	        < u =="0.000000000000000001" ; [ 000038759362592.000000000000000000 ; 000038766922709.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7061803E711A12E >									
//	    < PI_YU_ROMA ; Line_3914 ; 9FEo55n9qd7G921NuypsL6cJvr7j0Y22bQ4c5W6FP8oKZbSMN ; 20171122 ; subDT >									
//	        < K96zlgWdSaaWWXoxiRAODD9GuV3UEH41FlEGvi6id5hIXy6FzH00JJj9oZrviCl9 >									
//	        < YdjR4Svu963fbnikrea3FT1lHV286Z9oM5Hd7ZIS2NIb45SyZw4329NFibe915nx >									
//	        < u =="0.000000000000000001" ; [ 000038766922709.000000000000000000 ; 000038772959598.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E711A12EE71AD757 >									
//	    < PI_YU_ROMA ; Line_3915 ; rrcO5j5gqyrT5Ui690g1yhqY4izOdtI2x4ObQQtgYrVU86X0w ; 20171122 ; subDT >									
//	        < qd9KXwD8XBYHB8oguDgf051YXwr3DnX9jJdCQ5he80M8TI71yRXnfoKuB5j28RBq >									
//	        < tVv1H58HTw87Vlz5Mf8pvjdnyDCY2H4ZpVULAqVP5BT75c9ZUwPg5JeI034VbE6t >									
//	        < u =="0.000000000000000001" ; [ 000038772959598.000000000000000000 ; 000038784902023.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E71AD757E72D105A >									
//	    < PI_YU_ROMA ; Line_3916 ; YcWf0U2mMB5g09w45P73n3msN4r74X0yvRz80r4O2qu15CYME ; 20171122 ; subDT >									
//	        < 1WWb0m02wiY5a27t1n03ir7MnBy7rh89aBSdNSVDYAvGOZjbVFkM69m5UW9CS9Zb >									
//	        < CCyECX7pDFKm1FhnZ6dBgIQ5ls58XBiOcp3lQ21L4El87B76smf5V3XyKsba3e8d >									
//	        < u =="0.000000000000000001" ; [ 000038784902023.000000000000000000 ; 000038794467484.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E72D105AE73BA8DC >									
//	    < PI_YU_ROMA ; Line_3917 ; SzQVw1oSp71O6MNb51odI413d9g15yc5710l6lU3U734PH80o ; 20171122 ; subDT >									
//	        < 6A62i803LnXoArTh5moy9YA36222gkN5wH91F1PrQ8ZYo1h0b9lw82Fy67rYdbEt >									
//	        < 1OnAbKrulECY73T2Ul8f6aE64JiyIGTXQ0PAg1DTE987wfR8QMws69M6s731WaI7 >									
//	        < u =="0.000000000000000001" ; [ 000038794467484.000000000000000000 ; 000038804814885.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E73BA8DCE74B72D0 >									
//	    < PI_YU_ROMA ; Line_3918 ; Qy7B4mH63t91e26k6gcG0uRezv5131iN7RqE28hk5rHkA33a6 ; 20171122 ; subDT >									
//	        < k02T3I1Rj7bW2ykn65566WWuGVl1n6242VVnhnSAQP8yEbH9RB00916T345d0WEB >									
//	        < 49kgYnsnsO7vIFN4iZVaTftvWX56JU5cb6VZn81sQxC151zORjj670JDhQQwp0s6 >									
//	        < u =="0.000000000000000001" ; [ 000038804814885.000000000000000000 ; 000038816924210.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E74B72D0E75DED05 >									
//	    < PI_YU_ROMA ; Line_3919 ; GU31c2qmf9anbP8ZX26B1lXXYRICU3aDfD1HV92LcD2X28HAY ; 20171122 ; subDT >									
//	        < Z9No4BmUVgP09q5jkIt0DZCi6769zlUnVg1ozvTPEFcRYJC7a3n6P1wQ79w1UUKZ >									
//	        < iv6Azl3lT00650B6ZgDT3T4CM51qv8BpvL0I638620Tbmw1p8bfl8O5Rk73J8aWY >									
//	        < u =="0.000000000000000001" ; [ 000038816924210.000000000000000000 ; 000038830311342.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E75DED05E7725A5E >									
//	    < PI_YU_ROMA ; Line_3920 ; h5G5QT1UXN5C7LB8z0Wkpi8rulqM4bjf6QJcMrVC791jru254 ; 20171122 ; subDT >									
//	        < qZ9992n0O8dm3AAGqATGtTiC9Or16wgXkj8By5vpzj3hfI0tow757YWCs6c3AZ73 >									
//	        < b5J4Z2aicc0bj61oX8254AX0bxX2JIW42WuI244Y05E0Wh0K64nfYn3ZQQTUg73e >									
//	        < u =="0.000000000000000001" ; [ 000038830311342.000000000000000000 ; 000038843962008.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7725A5EE7872EA8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3921 à 3930									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3921 ; 9f54V5iC7459D60a9p1b57jt59pUf0B1mv96UQs4cwX7KC8Z6 ; 20171122 ; subDT >									
//	        < ICUf4542T7Y714a21Efbyv2251D2GtGxl1xsF4381hJsN2c3XJ6N22L6BrC7r3Tn >									
//	        < j83IvoOcgyJ2pXBytDFg06X85l80zYTE1cd7j5hC6EUg49cz1Q8I5e44UDKoLpn5 >									
//	        < u =="0.000000000000000001" ; [ 000038843962008.000000000000000000 ; 000038855242567.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7872EA8E7986520 >									
//	    < PI_YU_ROMA ; Line_3922 ; kp74zjF81K2w8I799Ov6nCOkzfu69XVc4CRwjkkv0cXK46I25 ; 20171122 ; subDT >									
//	        < 8ebNENAwaBnyD9h51RXToMQtpIUDZD66156aa9N9NTJURuVqJ5rS1Ydwc80EyZoJ >									
//	        < yQJuctX3I9jcCR1EVWml3HGxo37DI897kTVUcdeT6IOomT61A3PvhPMmXylydp62 >									
//	        < u =="0.000000000000000001" ; [ 000038855242567.000000000000000000 ; 000038866283328.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7986520E7A93DEC >									
//	    < PI_YU_ROMA ; Line_3923 ; GEiD05JQ0OZQQ8F36YW402y4t10Ths43UV5950f4tvFle2Bs4 ; 20171122 ; subDT >									
//	        < d887TR4YnVWPhG6hVhBqOqOZ21A00UZ11r1j6DMfVjApQIW22sq3bt4QM1Q0jL33 >									
//	        < 3U2M6Nh6iuuFs1qXLlTS6SqcxmjUEHB4M8r35w68y4l9K2TfiK8o75285cqX62PV >									
//	        < u =="0.000000000000000001" ; [ 000038866283328.000000000000000000 ; 000038877703459.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7A93DECE7BAAAE9 >									
//	    < PI_YU_ROMA ; Line_3924 ; 6SZqobf8boXaxHi7MZXQ0xsa6A528y7Vi1232cjbw0l7itdx7 ; 20171122 ; subDT >									
//	        < 5WfmmdRjZuUzMn660cG3Pf5cQwfHtY5BpuPqEKZs91zAw0uRiQi72d7K212L91fL >									
//	        < dWUupkMvEn3o5PRwz0Jc7TbVcg0iz1gC0lQbSdnLlF8DoK85237q8ni6T2N9yHek >									
//	        < u =="0.000000000000000001" ; [ 000038877703459.000000000000000000 ; 000038883139461.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7BAAAE9E7C2F65A >									
//	    < PI_YU_ROMA ; Line_3925 ; BInIcGOtCS07zq0l9Lg0SFGmc32ML60bGfhzy7zjpaz9MS98y ; 20171122 ; subDT >									
//	        < 4ZD59Ci951Yn89rvb8v7CDznRwg4AKompbVGhQBgEkcpKo8cp9pHxHhWt73d4ye5 >									
//	        < KFu00mELw7gD43W5x593f3K062JEBh93t209B8ku181SkXI9Z2CunOul59njtI0z >									
//	        < u =="0.000000000000000001" ; [ 000038883139461.000000000000000000 ; 000038891873993.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7C2F65AE7D04A47 >									
//	    < PI_YU_ROMA ; Line_3926 ; 08RFa8X7P5xTdkt2zaiikWfJ3rx3hlXq3GYx56CS6wJCQ8PN5 ; 20171122 ; subDT >									
//	        < m965j46whM3w8CMWLUgw2QSY0F6t3A0xVC1Q3Ckd3D3fk0bxD93wWghb3FeT6Urr >									
//	        < nNXvZd26A09bPZW9xYGV8Q6hyC6MAc6gR81ovBxA09bq5OBPK1RDt8T41N4xQ005 >									
//	        < u =="0.000000000000000001" ; [ 000038891873993.000000000000000000 ; 000038903816936.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7D04A47E7E2837D >									
//	    < PI_YU_ROMA ; Line_3927 ; 2h21Q4vJHG3I66duiUmm0S3eDChn857C3Z8zOA125wg64jQ2V ; 20171122 ; subDT >									
//	        < rzilj2t9h0ml1Ur1ElRgI424t53019L5EJ4W2l50O4YTGM74ZDBe8tS8S2q85k2k >									
//	        < 9Kew6y2JMGbW99XDcjArpt9agzACq82fZbltupxfbzYUkoEM9irAvmw93b3Q0p3P >									
//	        < u =="0.000000000000000001" ; [ 000038903816936.000000000000000000 ; 000038917170285.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7E2837DE7F6E3A4 >									
//	    < PI_YU_ROMA ; Line_3928 ; uU3ujbsWn9ljTwaee8n7se386E6q0i616gc5iVA5Y6tz0cNCa ; 20171122 ; subDT >									
//	        < 2n47GYXDuPnqzshrg5rSlPcKtWBe45SaZ6gXbF9u5AOV1P5gEmD7byzu3R0YS94v >									
//	        < Cj5rzjcrzcUBz3Tn35M0LnIfa7eodtX0R2NMyj4qx7V59tB5IpFcZ580H66MAZFi >									
//	        < u =="0.000000000000000001" ; [ 000038917170285.000000000000000000 ; 000038926918159.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E7F6E3A4E805C367 >									
//	    < PI_YU_ROMA ; Line_3929 ; Q16VPAWQ0YKEjV4LV4GjOXB8onI6KJCgVR57hZI64d4oeQDB8 ; 20171122 ; subDT >									
//	        < 0tpfuonun9Z6FGamHP432z6pWW7rWF3p20O8e7Kl35snx9TvNj8Wg8H11ju0aUc8 >									
//	        < uU332vGudd7hVy65o6SZO4Le74792vpoI6KUh4ac9452q03Tiw8GkDYHFk5428AS >									
//	        < u =="0.000000000000000001" ; [ 000038926918159.000000000000000000 ; 000038940577402.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E805C367E81A9B0C >									
//	    < PI_YU_ROMA ; Line_3930 ; 9R9HlyjK08TX0768k348BEI5cQ67Zg3CJ3dgag7SQfjm09Szz ; 20171122 ; subDT >									
//	        < b72331o1x0ZczOHL3k4mCOnMF0Z9za9jIwA25Azf1T0LfYq7jy9zu2R4ER064Rsf >									
//	        < I75iT82JAtTs1Q1EXzyuIT46d733N630n9HDeiHP2PB87fONDjN29x074f08IJdy >									
//	        < u =="0.000000000000000001" ; [ 000038940577402.000000000000000000 ; 000038948192565.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E81A9B0CE82639B8 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3931 à 3940									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3931 ; UEz7826w9pHO5yrUcgDlANF67lhSdxp6PHR1A700p15EoY0lt ; 20171122 ; subDT >									
//	        < YWLdl2W5FZ5SalRcg0E59GOhY27bX06xG0SNuD1034EveLn3ydWY4fvc2e2fkt84 >									
//	        < K65RF6TrMTYocaJO3x6742vZc70LST6dox3yY7ia9Ugi862Usp0wgjE3MR5laZ2V >									
//	        < u =="0.000000000000000001" ; [ 000038948192565.000000000000000000 ; 000038962315930.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E82639B8E83BC6A9 >									
//	    < PI_YU_ROMA ; Line_3932 ; 3hekE3nq0I76I1f31E2q0P01lz9Tk2u6W0oWuhBO3V64Ia2D0 ; 20171122 ; subDT >									
//	        < 41Hohj1Fn5Iu823ov3p10EnQ62jCtYy7zIvlNv93St21hs0sv6FC9K84j27g6yy3 >									
//	        < IAqaSQbwMmJ90q0V3Q32f7T5AF6Yjw8jvfK7IL6IN1cCvmS6RSRHGzeNyQA982l0 >									
//	        < u =="0.000000000000000001" ; [ 000038962315930.000000000000000000 ; 000038971796348.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E83BC6A9E84A3DF2 >									
//	    < PI_YU_ROMA ; Line_3933 ; e4Tg4YL5w69OQ4PrZX93x9GJh8Va3Dl09v952H9TOhdrd5Lz2 ; 20171122 ; subDT >									
//	        < k3KMr54prR90byFOu12DMp1A6WvWEqY2AA3Tv8ETn80vAKNGVwtjhSdDh53mGj6m >									
//	        < w9B2Zl09RnNdE8S2CUb60pdORb9C8k81ybw79NPIeIz40O37884k1Ev6Yvw01EKL >									
//	        < u =="0.000000000000000001" ; [ 000038971796348.000000000000000000 ; 000038977024948.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E84A3DF2E852385E >									
//	    < PI_YU_ROMA ; Line_3934 ; 0hv3f5qKz0FjBE3fuJXocn5l32GkLp2cq78dwv8p89s7yeCC7 ; 20171122 ; subDT >									
//	        < 6ZNeF6YEqazmPm7sPk3jeOXPfmIFrZl0OwYp8CH37o1SJymR7uce615iA224dR43 >									
//	        < 9Txs1sps0qLTG5006j7D6KsF4G84IbiqwHW18YZX1lqJkD16qy5E1H80Tn7B3L08 >									
//	        < u =="0.000000000000000001" ; [ 000038977024948.000000000000000000 ; 000038985513723.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E852385EE85F2C4C >									
//	    < PI_YU_ROMA ; Line_3935 ; z9HAK3KssEpa275ddK0RVGb2hd21JHq5DJnslVXPCinRauMCB ; 20171122 ; subDT >									
//	        < 4ht6MVTRHVGq1Fw990q4rBfy5GpO5q6D681IQ1mD91OvkWdrZs646imeyRzI8kO2 >									
//	        < 4A8INEQdJagKX5U910jDH0sf9CphPUVw8Cs432bFC958Lpx6NI4Q0uxei87Tfneo >									
//	        < u =="0.000000000000000001" ; [ 000038985513723.000000000000000000 ; 000038990685151.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E85F2C4CE8671063 >									
//	    < PI_YU_ROMA ; Line_3936 ; L1hgTiMBL8J56morLR9N094U73iw034s1gAchp89o0VzX3Z7U ; 20171122 ; subDT >									
//	        < 1eBR9fv1963kN8Tik704qCD94c72vsAk5He1C5VSezcI9f00y10Mae0g0LUCDYgm >									
//	        < U1vEZznp6b6xDsWFFgeATG1J5Gln8234f90rAlwXRto34Qu0BQ4A1Usbbf61ge2x >									
//	        < u =="0.000000000000000001" ; [ 000038990685151.000000000000000000 ; 000039003490907.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8671063E87A9AA2 >									
//	    < PI_YU_ROMA ; Line_3937 ; EjmaU8J8Vhj9VX0RWZPTGpc60UCHoNg1HZNQ0rnPC08H70fWw ; 20171122 ; subDT >									
//	        < zUq1hGgwkOIhNJZsNro8LxN5O842XLo3ybC8VoUBIIlQ1Bf1PJyr37sTcm3fZUuC >									
//	        < BelfF3VC2nsz4E3kQ59Eq01M10C32bo3Ez56aloQsB9k79kQJ7Y9r41hwv237Vj1 >									
//	        < u =="0.000000000000000001" ; [ 000039003490907.000000000000000000 ; 000039009277165.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E87A9AA2E8836EE4 >									
//	    < PI_YU_ROMA ; Line_3938 ; y9Jj7i9iue21t6Kv00d0YscLk774pm55CPC0vu763H94BUA9i ; 20171122 ; subDT >									
//	        < LhxynV9ia6208sivvHg9m46t7afso52w9de5Z0RNNw33knA58J2A9I7nobrBsSy5 >									
//	        < vYroXu1kMX2r6rEWaVMV5SlvIr5005sLrxh1lv03Lr070037IS8SHM6w7039Lo4p >									
//	        < u =="0.000000000000000001" ; [ 000039009277165.000000000000000000 ; 000039017097602.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8836EE4E88F5DC0 >									
//	    < PI_YU_ROMA ; Line_3939 ; LlQwpVG2Et83iUuPabUq3x31fU4ATP3mY865StS5gVys7UFxb ; 20171122 ; subDT >									
//	        < n1S41cYJ8HtWmtD2tgAo680ABSlZhPSg7vc8r6h8bfnDAC9HX437263i24hlZrsN >									
//	        < h670USWo7M4035s0rU36ZKQ7Lx6mb9cnUdFttK3p4K8zJdt60p70c11wgqU1IBya >									
//	        < u =="0.000000000000000001" ; [ 000039017097602.000000000000000000 ; 000039030059559.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E88F5DC0E8A32503 >									
//	    < PI_YU_ROMA ; Line_3940 ; Jiyt6VWm62Rg1jFZ9yrmwp8H8DGuHOdqr3Btw82Jn6A4DmO4x ; 20171122 ; subDT >									
//	        < 6i3KzHhIg56l320p35zwib71PR8t9QV2N9H447d1mvI0Ukyjtl4F6x9QOemOiwZz >									
//	        < yU3RlDFytXjHt8eI6oHT45jsd4NXs001Seg82dNIBDvIR78IS0ao3Zo4kWQOW535 >									
//	        < u =="0.000000000000000001" ; [ 000039030059559.000000000000000000 ; 000039035603111.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8A32503E8AB9A77 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3941 à 3950									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3941 ; uIqeq723zmEtgd07vB9d84X10d7BXR9n9rUk6mFE7MX12Q9bq ; 20171122 ; subDT >									
//	        < 8AAR82rwfAnm1Awr0UDR2S3hCkv2MF4iD3az18083abLf0ycqF33aof8jWeC5CVD >									
//	        < yIQT4o2hS7tC6g3bEAEd3G0KHwdjCrC0LSIuUA37nsbnZgBi8dLIT7566jY405kp >									
//	        < u =="0.000000000000000001" ; [ 000039035603111.000000000000000000 ; 000039044710399.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8AB9A77E8B97FFF >									
//	    < PI_YU_ROMA ; Line_3942 ; Gbt82ebqoJc31Xy70PiAaVEc6m2v6yt8CzC1XLM7j5lO7Yhcg ; 20171122 ; subDT >									
//	        < d0ng7B9Sj1EFoewL878E57184OitXmj99X4G4WW6Yx6RzVs4u15dcuUiX3WJq1Ay >									
//	        < 4Uscx4W85mJqXgBbsq03AcFTQnPTbYrJAcQ9qu92TnVe0x6ab5to1Ae1Y70p32ss >									
//	        < u =="0.000000000000000001" ; [ 000039044710399.000000000000000000 ; 000039058506742.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8B97FFFE8CE8D32 >									
//	    < PI_YU_ROMA ; Line_3943 ; MLj9M35Y5GjLs0Lj4Llx4dp4Sw50lP0SgjV3hEfE7RxMS6k10 ; 20171122 ; subDT >									
//	        < q60E27ouV5F0e0l29X7QJ7Uz2ih146pD9f4XqrQME7Luy80tFdUH6F8Vb8RUVTW1 >									
//	        < mc0AjXYxY4Hj3c6X3mVv4tiVn82078ws3YiobmkYCtUr3ElOB09hrDTM610W2UN8 >									
//	        < u =="0.000000000000000001" ; [ 000039058506742.000000000000000000 ; 000039063850174.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8CE8D32E8D6B479 >									
//	    < PI_YU_ROMA ; Line_3944 ; u0WbwXF6Y9XqQP6ltKg1P2SxP3ZxmgWZK3fRe3SV1fWGo5n1X ; 20171122 ; subDT >									
//	        < D32G2CS6Wl2rg6z8V4taHXo77YiBY82fd9NL88fgnXLwDY7K2g5r0em9hCpZ0Rl4 >									
//	        < 69acrr0eI6XH47u24xSUgQI6L8mLog2ziJeG0ZCM30StPGGDetJx4wh0k8T1x8jP >									
//	        < u =="0.000000000000000001" ; [ 000039063850174.000000000000000000 ; 000039073969313.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8D6B479E8E62543 >									
//	    < PI_YU_ROMA ; Line_3945 ; QpBLxo5bm9dYpe7aK9gSS2EmSX2CWDRCnpKK7SbhklR58o9M1 ; 20171122 ; subDT >									
//	        < 9U9f65thLHbSaCCyJw37nvUn2FgvRXb3Yq4w1rAr54jSIF2C8r4Mi1tlu8ola0l8 >									
//	        < yE25hJP8RW2vl81xTs99seKrXE3O8jQ7X82xO8EgVe95F8YEo81BCO738YD7Qkfb >									
//	        < u =="0.000000000000000001" ; [ 000039073969313.000000000000000000 ; 000039083136419.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8E62543E8F42229 >									
//	    < PI_YU_ROMA ; Line_3946 ; 51v3rO1eD986QE81a2g0iaT1CGpLAmjPgR1pZo6vcClUzDDME ; 20171122 ; subDT >									
//	        < RQ6zWD0TF4Ne5ma1Iw0Orqo0voLDoM92997Mz43wezkSR50CKMKY4A3W2Cmv00Z4 >									
//	        < JeyQvwbQbj7HoPKRIDCadbRPl7VV333WRxs7mh9YhkhiDz2C0GgCVNkA08H18lHx >									
//	        < u =="0.000000000000000001" ; [ 000039083136419.000000000000000000 ; 000039088150575.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8F42229E8FBC8D1 >									
//	    < PI_YU_ROMA ; Line_3947 ; J9GPl3GFvtb2a1u2LZ551s9q5720SqIir5hdgL1NAf61e1393 ; 20171122 ; subDT >									
//	        < FTCNJ51lDGT49p2Ce5eeGPzIG2NKHJjbNA8pOdfRqpx4P1kMwxFUbdZe7bYNS0aq >									
//	        < x7cD131gd4KIPtZ3P890bp0er4k4HvaL976UzMiA35aA4KnkL5efX68js6qTIQAN >									
//	        < u =="0.000000000000000001" ; [ 000039088150575.000000000000000000 ; 000039096100138.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E8FBC8D1E907EA1D >									
//	    < PI_YU_ROMA ; Line_3948 ; W3ib2sR5y6eBNH9I89QcB9DV37CA4V415dO7dmqjvQ5kws4E1 ; 20171122 ; subDT >									
//	        < p65gsF2r2Ie77NrSg1Z0efP6vmgbCoMhRHPKV02G8Kg0Kgg6IlhkqdQ1Xq2UJGn9 >									
//	        < td2syzfp7LPBNeYs6r44c9W5ykN2PxRVx20sd4ZGHQl0614nFK3Z7Jh4rAQX14v3 >									
//	        < u =="0.000000000000000001" ; [ 000039096100138.000000000000000000 ; 000039103441687.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E907EA1DE9131DE8 >									
//	    < PI_YU_ROMA ; Line_3949 ; fcBlPN72Y0CtqWCli8bAGuf9GqqF9kTKbp8f6u7S3IyU8hGWq ; 20171122 ; subDT >									
//	        < TzcD0joSeuQuGB1HS4b0BtIUir5Ncv0bNg1l91G0yhn3aR6G8922hydhUoKqOCX6 >									
//	        < Ae38rCoS7ISw78By5q21Bbo13uo9M7vXRkQt171NFQ4YO871KjVRVq5T2y4O23s0 >									
//	        < u =="0.000000000000000001" ; [ 000039103441687.000000000000000000 ; 000039112907614.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9131DE8E9218F89 >									
//	    < PI_YU_ROMA ; Line_3950 ; Q87QLfUxT3Fz96e1MDQT94232l6c415NA364gLN9CGv16kk57 ; 20171122 ; subDT >									
//	        < LFIbyKnPDPTd4xtpm8EgS279Rl94e56TQP0KHyC88OKZ3n8q3e5Mmn3pS7Kiw87b >									
//	        < S7CsI5bL059va3prfcx29odgaW9eUyjZZ82wzxlPjkfdoMS8h45Vn5SFcF290QiV >									
//	        < u =="0.000000000000000001" ; [ 000039112907614.000000000000000000 ; 000039125297749.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9218F89E934776E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3951 à 3960									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3951 ; 2aH8H3l84Kx7E7297OjOz2q6gJ0N54tjlXT9AU84ExtxpUjf9 ; 20171122 ; subDT >									
//	        < lvS6e3MI31eh3n2U3E9ae7ZQ6Wm0lEm7gx843x0lp4C18boQNLn1pMPwDlha7mE3 >									
//	        < Cwq1bRtVJXq273SBjZA8ARNG0n704j9W2QsW8K8wV5Go5RdTz2MYQQSRC534n9Ic >									
//	        < u =="0.000000000000000001" ; [ 000039125297749.000000000000000000 ; 000039137129507.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E934776EE9468536 >									
//	    < PI_YU_ROMA ; Line_3952 ; 4YA99UicvM025f3bLricWWcH16e081DJ6sk67kv6af1U9ogvq ; 20171122 ; subDT >									
//	        < 15X701u84eiw53260TfgFxyBQjQol67H6iw08c1i5Eb072mVAOlzgEukQIa3FcE6 >									
//	        < 9ntkxncIMnMIsW5Sc1y16QZE73UB239q27OGRYhpF4E0V5m3e749aATkF2TlvgJc >									
//	        < u =="0.000000000000000001" ; [ 000039137129507.000000000000000000 ; 000039143959662.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9468536E950F13E >									
//	    < PI_YU_ROMA ; Line_3953 ; 826510TW64HTzEXm36C694169l8c8KxT5deFQG923RM9L7K3g ; 20171122 ; subDT >									
//	        < NECx03U04ulZlRK8FZtJ9wVo65yyN7qvbKyk6s8cNn8LcX2s3Scl2y4UB2LCG169 >									
//	        < 0r0HnX7dlo8a84O2w811qQ6H9NE85izf1cNlQ8Jx8WCc5XdPKY9m81stCEIcX1Ee >									
//	        < u =="0.000000000000000001" ; [ 000039143959662.000000000000000000 ; 000039150266923.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E950F13EE95A9104 >									
//	    < PI_YU_ROMA ; Line_3954 ; R4281cz5heBX3CXozVas7fKnspV3S3QooL1sn72Dhs1jK4m5k ; 20171122 ; subDT >									
//	        < i2898XY9ec8rD4Y46T260Zycjcvdj1de1mvRO8HFvOV3bqK363j8zukw5KhG3RRC >									
//	        < 773ceo0Dt1Vtl6bNb465B9I5n258S2BJBm7u3l0iEb4a31iZ1Fw4OH0fHzf3aWjO >									
//	        < u =="0.000000000000000001" ; [ 000039150266923.000000000000000000 ; 000039155730527.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E95A9104E962E73C >									
//	    < PI_YU_ROMA ; Line_3955 ; 97o6H9mgwBh8G7071Azd99IQRmUjJy4FSKDjNas519kiAs5g2 ; 20171122 ; subDT >									
//	        < QHmphv990b38A6dx17ekNJfDzeQ2iTG57Ltr86h764Gv5xOWC85g2LMjw2Ut3Ea6 >									
//	        < QKDN1V5Sef17E0On05CYFZWLuG6F32E6ldO0z69nn86rI0539dvBCy66dsn6wE95 >									
//	        < u =="0.000000000000000001" ; [ 000039155730527.000000000000000000 ; 000039162590708.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E962E73CE96D5EFE >									
//	    < PI_YU_ROMA ; Line_3956 ; VOUJvbas9KU9yq595T2X8WaO5573498ErkiUKIiLgT1DA8J3d ; 20171122 ; subDT >									
//	        < fUfXqHNgJhJnQ1b19l0L82oPJ0r621hs65pF78xpG2gFeUgR95j9EX2KjsJ409dB >									
//	        < bG8rWreA6d8Hf0KRDxWatO8dBa6RqY7f7d9zJ5YxdUn5x8MHzYbTj417IosKux2W >									
//	        < u =="0.000000000000000001" ; [ 000039162590708.000000000000000000 ; 000039169953312.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E96D5EFEE9789B03 >									
//	    < PI_YU_ROMA ; Line_3957 ; 978sBTPUe0ywty047vS785JSfhIKV4Zo3UxMiJE6I5TFY20Xc ; 20171122 ; subDT >									
//	        < 47ACsR2NrffcJ1r9C8VKPV96Y6195dJ349t1fENcK9iW2S37zv5j25URTGkT04hG >									
//	        < bHy1ez145nRXpAduYjQQ45UZm3Q8K4i84W6hvSR9eA1y9iq9Z7JgkkC4d3L34Vc4 >									
//	        < u =="0.000000000000000001" ; [ 000039169953312.000000000000000000 ; 000039177350902.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9789B03E983E4B2 >									
//	    < PI_YU_ROMA ; Line_3958 ; 78K39rLF7yuYixXQX3cGgQ2j7VkrsWX35fXAln6Z7eJcODcNt ; 20171122 ; subDT >									
//	        < 9qXq3OY9koGaBAo14r27QxofI9N52IVTm6RJqv898Ys9481GJ6Mo8qFikNpVpqEr >									
//	        < et59t6SRORYf8EZN584bKx580XPx9Nd0l2H7CXrTEAaA2240RrdUZUbAql1b13P7 >									
//	        < u =="0.000000000000000001" ; [ 000039177350902.000000000000000000 ; 000039189244181.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E983E4B2E9960A82 >									
//	    < PI_YU_ROMA ; Line_3959 ; gnxIyPmqT8LqtF6h4Hh8Q90gS7F28123TFAQ4BbSuGakxeBK2 ; 20171122 ; subDT >									
//	        < 2p3aq24G9lpX4rT36z8p8tJVqIsZrJzyHtWhJk5QFOF8y0E4s4oil6NJIH0XktqZ >									
//	        < vc5NJ2yWZ68vshz2BWuw0SXODqh1NYO55q1z1ZCS8eZbauwbSg8u7x2MOohb6391 >									
//	        < u =="0.000000000000000001" ; [ 000039189244181.000000000000000000 ; 000039202009217.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9960A82E9A984D9 >									
//	    < PI_YU_ROMA ; Line_3960 ; 3GQD3Iz173qtHaMg8Is6l5WTFC6z48q8906hd4t7TJHs42qUS ; 20171122 ; subDT >									
//	        < sdr5i8af75QnM6cwyLFh9358VfOulIN6VziPQ23VpT0wTmNE5hjOy8ITfxa24G9p >									
//	        < 6qnX8j3H74vP07L46zu8393bpvUyH13T2741UvgX3aRVsCHa4nPW2rWUam1533j4 >									
//	        < u =="0.000000000000000001" ; [ 000039202009217.000000000000000000 ; 000039211603547.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9A984D9E9B828A2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3961 à 3970									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3961 ; 94C1A8MZJQ7mMLOFT96cLXj739NrqWf250143LPCF3PNIIKuL ; 20171122 ; subDT >									
//	        < ODTb571JD2Z5A9F65ILtf7cev7KXjNmgEaVfjwD3Cxn5b9NsgYog3BK1e7g0Vnx6 >									
//	        < im2aUPATq9q15rTSZsAWI2Cx0mO6bKNDs542kdg36F37B6993344h8vcjgXcVAW3 >									
//	        < u =="0.000000000000000001" ; [ 000039211603547.000000000000000000 ; 000039216685887.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9B828A2E9BFE9EC >									
//	    < PI_YU_ROMA ; Line_3962 ; Z9yIXPYYvxDTCZ4SC5E4XJwD8OEchrDiPVJXN41529HgNuu2N ; 20171122 ; subDT >									
//	        < GYaAAMWUQbt8163y8u3AcccQ62tGMm94WEG8DNe66315PymI28P24q2g1Ek4e3El >									
//	        < 6IiJ9VIZc582xSkp0lR5E72C66HTW7de9F1jgr5ahIgsdAb1K3ykwVQ27E4Oi4g5 >									
//	        < u =="0.000000000000000001" ; [ 000039216685887.000000000000000000 ; 000039226095874.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9BFE9ECE9CE45B3 >									
//	    < PI_YU_ROMA ; Line_3963 ; 573U5bPp308hgWLa5wPpW8SGBu8E0L2mF6PR82v3jt3M1uK3M ; 20171122 ; subDT >									
//	        < E9X8uOj4Y7Ts10Z0422J6f15izn6T568Gz5F3qjlzTeGwoSK1IU2tfQyPm9wi46T >									
//	        < D3izsc95BGknLr25o9178gDq7sGP8f4rX6e8RrWd7mo73mj72eXf34d47837lmv7 >									
//	        < u =="0.000000000000000001" ; [ 000039226095874.000000000000000000 ; 000039236200934.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9CE45B3E9DDB0FD >									
//	    < PI_YU_ROMA ; Line_3964 ; V748xPXoe2UYN4uBJDyo3aw0ZWv63kB1BJCKwPWo6jR4s3Y4F ; 20171122 ; subDT >									
//	        < 2eGCLRr49Pe2r12vyH27iy3XUAVt4kj9AcAywn87uA2rW0551r9sr6K76058xCJJ >									
//	        < juI6bNTqjMK2WrhSFdCI6fXOZfEKNoqWkZr0kFw8T483JCF4nyl4S0Uwv1B8t2Ab >									
//	        < u =="0.000000000000000001" ; [ 000039236200934.000000000000000000 ; 000039245739078.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9DDB0FDE9EC3ED3 >									
//	    < PI_YU_ROMA ; Line_3965 ; w8K8D18BQiI65n7966Bs9mIf7u31XS0V4oO49L5KX1v2Y0kCl ; 20171122 ; subDT >									
//	        < 4gr6g19z3i86a350PdDT9j6yzmkPCFn2CMFAkSLNYk6r08TIqTz8IM9HuD0uZ91l >									
//	        < v7gI967W7X9cj8WIpiyjke5178axf39Forgb6l9W8WJxdzCx4xsqQn84xoZo6V0S >									
//	        < u =="0.000000000000000001" ; [ 000039245739078.000000000000000000 ; 000039260172515.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000E9EC3ED3EA0244E3 >									
//	    < PI_YU_ROMA ; Line_3966 ; at6l0mheUGpVV5ka9ehU2lghbBWqK9R7Vyxtw8pF7g3diIsyf ; 20171122 ; subDT >									
//	        < VCc4Lzor98T68iM4wT6z6DYG1P4dVD9G4514gmsT0BZNKL55ysH34Kkz0VUzALx8 >									
//	        < 5Gxqv29Sqf74noBgh17d8a2U8Rm4G3PG7G82ezWQ19xUFd0Svtw0d4LQzgj1boml >									
//	        < u =="0.000000000000000001" ; [ 000039260172515.000000000000000000 ; 000039271036671.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA0244E3EA12D8B3 >									
//	    < PI_YU_ROMA ; Line_3967 ; k2Pd8rYNiNudJw7T2m9u8oG014M006h72F65C4lt507P57hUa ; 20171122 ; subDT >									
//	        < d11Y4VD0a5q555es958To3n98Nx07Fw5Xo9Up485d5B1A1tFScVF6V6PngYBV4Mh >									
//	        < K72GT90T5W6nd581q0x1pS7cJ8Fvc03p7IPtm7z5NhhFkur973q6znQVoOinK0Zz >									
//	        < u =="0.000000000000000001" ; [ 000039271036671.000000000000000000 ; 000039283203931.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA12D8B3EA256989 >									
//	    < PI_YU_ROMA ; Line_3968 ; RAkCoKrRc27Z40fJ3Z20Ak9J7080RvoVxSH51TDg71hHq29oz ; 20171122 ; subDT >									
//	        < 1pcjShblf50P4h88B42j3nBRHd717OW99nb9Lgz1Wroe7G2yJYptoS967gIM5cFd >									
//	        < 1jb820OiLq645DOiuqjZf0FTnzV7kh1G61sBh9pO0t9R0SkIp8ndHa4JCUV146i1 >									
//	        < u =="0.000000000000000001" ; [ 000039283203931.000000000000000000 ; 000039295481186.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA256989EA382556 >									
//	    < PI_YU_ROMA ; Line_3969 ; s2cd4Nrpo3AZZi5stTqJB2uk9P1o69Md2wR5r3LPM8rV4ZHRJ ; 20171122 ; subDT >									
//	        < 4R1D0766DR9972e9kXsZaFbZF8gw68L7SLu3235gkJYEjT8xIYK3FbFNh18KZWqE >									
//	        < 2XgY8kIi9rPKoX708H9fGW75P2dh1cDku0vHjOBLQ9s46YAcDPQnmx97YJ9f6agS >									
//	        < u =="0.000000000000000001" ; [ 000039295481186.000000000000000000 ; 000039303417511.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA382556EA444177 >									
//	    < PI_YU_ROMA ; Line_3970 ; omJzvqWIaBPNun85z3r8z48Dg0CEAEPB5L02Y623E48Bx1eli ; 20171122 ; subDT >									
//	        < 0cf8kGo9R30jixctm4aNcz857yMG3767CqUx8rjPPLNuubtE0dhzuoL4ug36o8o5 >									
//	        < xz073U4AnKTs9703GREuonkMMxXGzvUaKJkYaFl4zl1xZT0gug3X31oJfsI8a3Oz >									
//	        < u =="0.000000000000000001" ; [ 000039303417511.000000000000000000 ; 000039310276044.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA444177EA4EB894 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3971 à 3980									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3971 ; 2FCO8h9lcT03Ok76i73PUCrIrPNF5C9x353VlaaSGTJL8ie9f ; 20171122 ; subDT >									
//	        < Q4Am0qPz5Rh8T1o1Sdv6VFXwZJ8uE3YJ73K71jRuZK28g2PK3GIB7zlm2ND3531X >									
//	        < 0Og0D6MIsg720qyXAfZ1C0a6Mk9BjH9F4mXOyTd4R5JbK4aKVaVBv3SxxYk7Mmmz >									
//	        < u =="0.000000000000000001" ; [ 000039310276044.000000000000000000 ; 000039322425765.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA4EB894EA614290 >									
//	    < PI_YU_ROMA ; Line_3972 ; opw06Dm4fSYkxy7bems5yJVPEty9K3gh016RKVrzK7Jk3FGlM ; 20171122 ; subDT >									
//	        < 4VecFz59gEOv1Y5yAFD5p1tICC50nhIlLBfK2rLk9W4xBjjnYQgJo05cblGnu1oB >									
//	        < UJxFsv4nb19sF9pK5MIDj0eL5H3f6tRhNSTvY1lFTPcSo4vj30m7171snbk72XP7 >									
//	        < u =="0.000000000000000001" ; [ 000039322425765.000000000000000000 ; 000039331294073.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA614290EA6ECABF >									
//	    < PI_YU_ROMA ; Line_3973 ; u01288YRR7H2ov9IUJLUIXWnPaQcb865O4d6bqEpsU048HHj7 ; 20171122 ; subDT >									
//	        < rgJDDj072J6f31tK1n1D477j3fZqAVw54maYt33QlDc9tuL207hV5MiWfJEG7601 >									
//	        < 87ecI2fzN3NO6Qh1kD75AjX94pbG83O0e4XfICr5JTO0svj3ZoL3CZ508IqB396g >									
//	        < u =="0.000000000000000001" ; [ 000039331294073.000000000000000000 ; 000039339651605.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA6ECABFEA7B8B68 >									
//	    < PI_YU_ROMA ; Line_3974 ; quSJeGfm27B7Lz589ki6LS40c0hi16D54V83Pu7oANzyKQ9M5 ; 20171122 ; subDT >									
//	        < 0M24vw2o2K0r9Va28dilk8mWFv9oD0McWa09J1pusQ7UPuB435EQss6V9zd2w6p7 >									
//	        < VuI1PgZ1Cyq3Hv4B8ABnw71ZIYs041Qv8a2o5ICZd68f9362cg1i998I6iVSWkZF >									
//	        < u =="0.000000000000000001" ; [ 000039339651605.000000000000000000 ; 000039349598166.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA7B8B68EA8AB8C8 >									
//	    < PI_YU_ROMA ; Line_3975 ; qu5vI15UMs9JakH9Yhp0rc8rhifk56ha7817L0AGb93teKNI4 ; 20171122 ; subDT >									
//	        < P2M0aZ0VBK19L31XAkUu95tuQciRmZ3mR8nHHT3wOVeG7rYm37JTtIawoQh9FQaa >									
//	        < gwkyL50yk3d8cjDn1WW8DQdVd939q050eJ58vaZyMRd0QmXbvv39p5388GPX4l12 >									
//	        < u =="0.000000000000000001" ; [ 000039349598166.000000000000000000 ; 000039360581123.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA8AB8C8EA9B7B00 >									
//	    < PI_YU_ROMA ; Line_3976 ; dmt719d6slt1PqI67Ulxaw2Pw5Cz42kCxbpwT0BX8DD148C34 ; 20171122 ; subDT >									
//	        < 64Wr9Knyo3nDqhCJ92zJ709lp1pD0oHITzelZEpyE6UBliGf2X6H9aR99299B52u >									
//	        < 1C1viK2T1Bz1RUaX2pAA7yqByHK4luevN21rNuFP0DECC59zsR0tNPXLytmzh2sc >									
//	        < u =="0.000000000000000001" ; [ 000039360581123.000000000000000000 ; 000039374395337.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EA9B7B00EAB08F2D >									
//	    < PI_YU_ROMA ; Line_3977 ; 3D2LM7X15hc44X58vmowbICjm1fjwIz5F10Q77IyF7VEvzsxi ; 20171122 ; subDT >									
//	        < e0YXXu88Dp8KA4ach7VCw72LAnX179qqQahD3PY6tDYN9561ddk0L0O9OWb7C0te >									
//	        < Z1Fh7hSy0osI394Nn8uEpkrfaS8Pr3nrpQLdHeRCSee720307Y5SW3709T3c7WZ8 >									
//	        < u =="0.000000000000000001" ; [ 000039374395337.000000000000000000 ; 000039380735799.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EAB08F2DEABA3BEB >									
//	    < PI_YU_ROMA ; Line_3978 ; kv80o97Tf2Yr4bNhM2Z8x5M7ii0tkF16LG45W34KDu82gYgtk ; 20171122 ; subDT >									
//	        < KJzLDEn98850S3sPYE697y28UEDZf4GUhSK48BXgoy03JPEXxSJ88m4EN8TIw6Vc >									
//	        < 4h9pQWPuK378bt7Urv986ZW1ZXSS0CYcPc76PU6X519a28LEwlyh4hQ9m0P18HD2 >									
//	        < u =="0.000000000000000001" ; [ 000039380735799.000000000000000000 ; 000039394983923.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EABA3BEBEACFF998 >									
//	    < PI_YU_ROMA ; Line_3979 ; QN7a8EEx6lX4h431X68LHTuVeI7rNsN9wG1Bc5Ml82tCr4w3H ; 20171122 ; subDT >									
//	        < rUB3e1hG8EZNUijuDcaC58x6CZLTU8420i3JfcvTL2WycUkgJ8RLPwqU8f85id11 >									
//	        < IKgH6zI06i8o7aW55U8hapo7WoASM203XAE16SINWu8743p4NYmwY0c52vd3uxc1 >									
//	        < u =="0.000000000000000001" ; [ 000039394983923.000000000000000000 ; 000039406331717.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EACFF998EAE14A53 >									
//	    < PI_YU_ROMA ; Line_3980 ; 3WAdi1zN3hxw2Cho32jjWBfSe320ik5U7dNI2v47ppTHHlC7j ; 20171122 ; subDT >									
//	        < 55m7FGbN3abu6nLHyoR4cbBl1365wx4x6v8t5J2bj2y76rpcE42rgju268x4c7Pe >									
//	        < 8cgZkiv6FgdVUIiA6FEwYCi347sBE1xbe6jNjJKMsJnwwia903vT3sL6rTZc78OX >									
//	        < u =="0.000000000000000001" ; [ 000039406331717.000000000000000000 ; 000039420615640.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EAE14A53EAF715FC >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3981 à 3990									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3981 ; KwAavCq1uXP8wvZwWm3UJQ211HCvfG2Y422275YM31GhH1g1s ; 20171122 ; subDT >									
//	        < ZOAd5b3Tes7P43Da68wHZ264A14xm93cz35FR1W03xAeB4z83efy7EEKVJ7H330P >									
//	        < NxItQO0F30DvagKu0pBarUuVGJ0NM335VIsYHKBlD9Q2B3bZ85XAM1V8FcI4srqu >									
//	        < u =="0.000000000000000001" ; [ 000039420615640.000000000000000000 ; 000039434113205.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EAF715FCEB0BAE78 >									
//	    < PI_YU_ROMA ; Line_3982 ; Q88DGMxbjEpwFlAnhL190K550CkcG0mS2uE8RMk06RxywS8mq ; 20171122 ; subDT >									
//	        < D09L51aw7g9wj8gTZ328F543vl0xU46xbahpt7Rp1eN3P70p7675EVqHx5p1W9FR >									
//	        < 2YU3PjQNAHVp16q7bE2AoB617XQGtY6q81XZCfO8p951Eq4E04z3QRYDIgmB7o0m >									
//	        < u =="0.000000000000000001" ; [ 000039434113205.000000000000000000 ; 000039442989011.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB0BAE78EB193995 >									
//	    < PI_YU_ROMA ; Line_3983 ; QASwhONTkLwDcDR7s83458ePWK2py4GJQ5Ol8Mq3Gs58Db637 ; 20171122 ; subDT >									
//	        < 385D3ZTP89HP9n0Go1cnhc67E36fmd42tF4v0KHaCw8053c2LlgYUIg4EFaf0L34 >									
//	        < qj6y5Q5812HZoYH9EdwT8r3X42VITz9B3L12w382U08kQuo9406sTMGd7c5MyN7t >									
//	        < u =="0.000000000000000001" ; [ 000039442989011.000000000000000000 ; 000039452002682.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB193995EB26FA8C >									
//	    < PI_YU_ROMA ; Line_3984 ; M6fgv3gt4Qk297T94L76r39KhoiqSy61ZGOYofdasBw6605Ny ; 20171122 ; subDT >									
//	        < 5tPenTyj3PjHO24VT0L2mCwOfnDgMfmPx0L9p6EkJ9M4s2495H09QFVRy0t3Oj6i >									
//	        < 59ZWJTSV7YyhygaDE1w37SknV6Z5HdEykP22Z258241jl0027PqTeYO4n55jElRv >									
//	        < u =="0.000000000000000001" ; [ 000039452002682.000000000000000000 ; 000039462590169.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB26FA8CEB372248 >									
//	    < PI_YU_ROMA ; Line_3985 ; a3R86egT474aowLoH6BOQVDrG1xSHc9Mz1Yt37m959G8Hw7Ks ; 20171122 ; subDT >									
//	        < 94G7USGN7x2KZKnsV589cEtO5rgc5JT9r83yqOz6391AQqMDJb0969jviUyKWWdS >									
//	        < TfDv42e9JLdz2z0E2ky9S0ED7xa06X4sSa2q7KgY33aNve0liL2BWHWL2Yc78P3b >									
//	        < u =="0.000000000000000001" ; [ 000039462590169.000000000000000000 ; 000039469117320.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB372248EB4117F4 >									
//	    < PI_YU_ROMA ; Line_3986 ; 7q9S524spibjdzP81Up073VzZ5Q1nh9iNb74YBrTxdAFCmnG7 ; 20171122 ; subDT >									
//	        < n6S243iapIkSvD7qg5gjKr03B29883l1l2sN4W16Q83Ywfog9C4koFt0WtCaR6Z8 >									
//	        < 9ksx9minIH8ybw9uw1jCq4Bc7QAnR450sM98hR7I4k2LKq1Ctj2f4Yqvp48vgCTJ >									
//	        < u =="0.000000000000000001" ; [ 000039469117320.000000000000000000 ; 000039478573170.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB4117F4EB4F85A5 >									
//	    < PI_YU_ROMA ; Line_3987 ; GGGyUL43ze15p4zQNffCnB8x3v7JuTtO5DYzUvB84Ejr53So6 ; 20171122 ; subDT >									
//	        < 0P1M87VfdAlgv6L2m5EX0S585Uei0tUk2zwg2166Vff883hO457veCSh1ZIe8Bks >									
//	        < b5969O28E2BkU5s8XIkD8Plx3h53Admg5Nt413i9vG1U7ZxV637Uzta912Ro438O >									
//	        < u =="0.000000000000000001" ; [ 000039478573170.000000000000000000 ; 000039483718676.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB4F85A5EB575F9B >									
//	    < PI_YU_ROMA ; Line_3988 ; 1QdSFnqOJfAy43f4gu9MSv7Ndo2NBONz202QqaV5Vah74Oy77 ; 20171122 ; subDT >									
//	        < 8KDfU3dcgxjwh7azUMbxGwZBkIxU90MYRKIJgtA5gB9s53qvFAJlIZJ55ydE1o19 >									
//	        < bjmiZrgb3YmaM50V9c8J08zG6C2dFyxuS4YYHVtM7r4sXN1rpz35QeZjW088GjLh >									
//	        < u =="0.000000000000000001" ; [ 000039483718676.000000000000000000 ; 000039498041959.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB575F9BEB6D3AA3 >									
//	    < PI_YU_ROMA ; Line_3989 ; 213skdA7c3Sm5e3xAtvu72OwugR2v3H2r0EON5YDk9GRESzu3 ; 20171122 ; subDT >									
//	        < EVR3xk5zZms6Z408o1NAu05aqr1Q6DBQlfXbit2lCe2QkzX1n7lUL2K7mhyLOxrW >									
//	        < 3t98SE3mN87LVPObpx073dbwk3PBp04z4DMkW68ENe7bk28fEraUm9gAG6wLVjCd >									
//	        < u =="0.000000000000000001" ; [ 000039498041959.000000000000000000 ; 000039511230589.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB6D3AA3EB815A72 >									
//	    < PI_YU_ROMA ; Line_3990 ; 178jzr4dlBoi8nr6RUCKUELe3R5074Zq88IO01gEOARHu6p18 ; 20171122 ; subDT >									
//	        < USr7oKWiA5Z4Vdt5KfU7iXuhrm2qp4DN4dvi0038j20uH90SKE8o40440paHCw7n >									
//	        < G5251lCy8ML9NeU80qFaq19R5pKf4K0hV2MvqVR5aI12dM7GC1tk8d08g0eJeTJ5 >									
//	        < u =="0.000000000000000001" ; [ 000039511230589.000000000000000000 ; 000039524865524.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB815A72EB962898 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 3991 à 4000									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_3991 ; ko1gs3GdB47RVioMW7y0HgMquN4465Gs4phF3a6x5DlFZgu5f ; 20171122 ; subDT >									
//	        < j1D4uagc9AWcOfrzHsHO1c8o64MRf62v4p3yoiY09bTL2vQBav0S4VpAZhhkxP72 >									
//	        < a0fP9g0k6bnTT6rf21QiV23os3b40JMbD007BlPoIfU6zEw6hU3jfY9U8d5Nl8uP >									
//	        < u =="0.000000000000000001" ; [ 000039524865524.000000000000000000 ; 000039533573215.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EB962898EBA37209 >									
//	    < PI_YU_ROMA ; Line_3992 ; 1iDUF6t0yPip0M14I39So37W3h4747JpF8nddQCZFXv1YVaLU ; 20171122 ; subDT >									
//	        < Ddb8rw4elx59PNr07T7P32OB2M85L9738ne825e51T5Ic030445XlXh9DIvX7DU9 >									
//	        < 7etjfs97m5yXz8yFd9jOMkAFak75tcwR2KY3VufS11ZaFhFoqh9Ut08RN78GTh9m >									
//	        < u =="0.000000000000000001" ; [ 000039533573215.000000000000000000 ; 000039547182627.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EBA37209EBB83636 >									
//	    < PI_YU_ROMA ; Line_3993 ; y27P8UW3tKQ2GaZ5GdKGL960yc80y8393SR034n741hQJRZP8 ; 20171122 ; subDT >									
//	        < APO8yl39L3Ma2C9sAnE000Ex9CTpo88LEy1Z0A9K7X3oR5FC1nq2yoG4WO9BVJj0 >									
//	        < kC5Alq8sU8h92V63N8LWLVCdYPRb4c76og62b5Ua0wsP8M30J83cCElnI3xGxvW8 >									
//	        < u =="0.000000000000000001" ; [ 000039547182627.000000000000000000 ; 000039560815043.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EBB83636EBCD0360 >									
//	    < PI_YU_ROMA ; Line_3994 ; DUY8p90Woiw31y01N05K8P545x6C4qMoRe1HtX3zqV0URFKxs ; 20171122 ; subDT >									
//	        < WZuA00eZf5YbB5vR5jqXlL46DO7J8p7gl4dFF6Ab3AfxmmG1tVXiJ0D7z3ew9sKd >									
//	        < 5J0V0vZyvvG3z2TESTu8z0hzSWQIWg2gmU4v0zJ5KcAEHi3baDrO0E0zs2j86IkB >									
//	        < u =="0.000000000000000001" ; [ 000039560815043.000000000000000000 ; 000039566643597.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EBCD0360EBD5E827 >									
//	    < PI_YU_ROMA ; Line_3995 ; CYb7rsQMv64U4wdABe18W5Lb8aRDsxIElBbMPc4Ws7T79h1J4 ; 20171122 ; subDT >									
//	        < DAH8iLE1Xm15QCg7efSX9y0E7TrU4VVmr52IZ5l7epa9yD8JOd2coByMA1zZ5wJo >									
//	        < 2OGgS1Vc73troQbCxmTf64VQ9rwVps7e1ED6jQ4KaQp27IDTQ21DheEBYn6NyB5B >									
//	        < u =="0.000000000000000001" ; [ 000039566643597.000000000000000000 ; 000039572843693.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EBD5E827EBDF5E11 >									
//	    < PI_YU_ROMA ; Line_3996 ; Z6nGKnZGXyF89Uar6J3mqN49L1lpSK4VCAfR4piZBcU2oQ6G3 ; 20171122 ; subDT >									
//	        < BOArzg4xKz63goKGWdwyGXAZoej3ViRMHp0fLLRg82R8AqUADZQ92sSyL7P0P0Pr >									
//	        < iiaDORcA4nRwBQb3R0R817V3My6dIc6NqMh8r9cadJN0lUvrTf0eidfpMYQ2HSaD >									
//	        < u =="0.000000000000000001" ; [ 000039572843693.000000000000000000 ; 000039587188543.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EBDF5E11EBF54186 >									
//	    < PI_YU_ROMA ; Line_3997 ; KqjB78t316d2eUfJrOMnj6280drLXw91f9NG63P9dKhBbc4Tc ; 20171122 ; subDT >									
//	        < 20t5WG1218bwNCb0e3oPs99wEmc7iMdE7e5x59yRbDGn6Alo96r7447e75nKWWLJ >									
//	        < 86QkrQnH9To24hzOuSuo2E604B1595W8o1h7S60ELAXYqw2fNnrk3E20v0pA12R7 >									
//	        < u =="0.000000000000000001" ; [ 000039587188543.000000000000000000 ; 000039599634042.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EBF54186EC083F0C >									
//	    < PI_YU_ROMA ; Line_3998 ; JefcQ0Xzqs2TS5tAZEf8lhx3av3K5Cop8eUFofoe6Vhig3D6u ; 20171122 ; subDT >									
//	        < 87nN8h584peaWEuoKw6Jh1l650YA41i1D50ovp56D36YwmoVpt4CPZGDK10Yh0VA >									
//	        < ug5j9jS6BCmj3NYe0ze5BBfNfQrw68N18zDRbx8F0cJaJN5y46PSh7IPmL60gCRf >									
//	        < u =="0.000000000000000001" ; [ 000039599634042.000000000000000000 ; 000039606556522.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EC083F0CEC12CF24 >									
//	    < PI_YU_ROMA ; Line_3999 ; X46j0Bc28L7TtChSodVH0zOL52TyG6l573x1GCzGgE8MUu3QU ; 20171122 ; subDT >									
//	        < HW1E4oXHwQS5rrl0y1b9H5Jp4G2m191B0V4937y5A4PHxif6tR6LorfFeaqEBOM0 >									
//	        < oPY4zt582jPpWp13EqbgGYFHA47OR5ZF6p13xrXKa1s8jJL4914l32Es1doGG7xZ >									
//	        < u =="0.000000000000000001" ; [ 000039606556522.000000000000000000 ; 000039612732588.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EC12CF24EC1C3BAA >									
//	    < PI_YU_ROMA ; Line_4000 ; BL85dc5w77PV328lyH7y8XahCJurzl26R9E5KRd5q0N8nG0ok ; 20171122 ; subDT >									
//	        < es6s3US87eEWNusU2l37OxMa6SluffBVrC75pM3N7HkAv9g5ep2Y678MwK0sipWN >									
//	        < 86R9tzTJJgCf5FxhH38Yeul5ANEgcfRgK9NlZ8ED7NeU804bpGrG5Rpa5jeqDrS1 >									
//	        < u =="0.000000000000000001" ; [ 000039612732588.000000000000000000 ; 000039619908151.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EC1C3BAAEC272E9F >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4001 à 4010									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4001 ; KYm8NSc9QR8o0E082CCxTBJ3ve7X1291fq30SX35663J0cg4o ; 20171122 ; subDT >									
//	        < vY084Mb63OZ4J048RNTUy9RZ9q9k7CAs05FI0FXSR6sCE8HKU3PKehS04plxt5z9 >									
//	        < qX9Kv6F40S906tkyD7iwQAi3g672m8XhFp2puljDf2YnJiaCkcec3uqQ26n2uAgP >									
//	        < u =="0.000000000000000001" ; [ 000039619908151.000000000000000000 ; 000039631648386.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EC272E9FEC3918A6 >									
//	    < PI_YU_ROMA ; Line_4002 ; 9F1zlBp0wak76ewiymCgg41IV4BGywFAhMk1BLcZ1Sc5Sl3Th ; 20171122 ; subDT >									
//	        < clO3zCmAuUZ1126BX0O7095RPDu13cTW64XLmw1L4w9Bc2mMRLj749WHrxxJ6Ppi >									
//	        < UF3tBizExcEUm3sHxMRf5Z4tP2aB69Qt8Cn2p4rkXS4QGWs169A3QoQ6iZrc8K9b >									
//	        < u =="0.000000000000000001" ; [ 000039631648386.000000000000000000 ; 000039639486027.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EC3918A6EC450E3A >									
//	    < PI_YU_ROMA ; Line_4003 ; Qh53615OxlOWZn9WCT92U92l6iqNPLx3TCcChm8G2B0Vj533x ; 20171122 ; subDT >									
//	        < RI7oY72vGi8nS378B55ub93Y0TR3vyAJrM0bYZs44jpAchfN27IgU3FNr82dgASU >									
//	        < TEIsK9c99v9p0zAJ78dTmkZDd5S1Hc6KfF0Owu9HbTx3si79wFpH5Z9tRgYQZVKa >									
//	        < u =="0.000000000000000001" ; [ 000039639486027.000000000000000000 ; 000039652195552.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EC450E3AEC5872E3 >									
//	    < PI_YU_ROMA ; Line_4004 ; 4RA0u275kMPScN9MyY2Vg1Rtf60Ffr9sP7578cVPg76CL5J2B ; 20171122 ; subDT >									
//	        < Z9vUpG2kV9C2jqsRdMLevmStziZ8h2zObzKNR8nn4rMf0rP6d3ehta7Qq6YPPF51 >									
//	        < 8uMeA0LV2btbM46YfAkGD1MriI1rT96s724563U75Zl837Ch80C1J4s9y0nSIzPz >									
//	        < u =="0.000000000000000001" ; [ 000039652195552.000000000000000000 ; 000039665007031.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EC5872E3EC6BFF5F >									
//	    < PI_YU_ROMA ; Line_4005 ; Loi0oarNEt8hRuI400tWhzdp32LOh4C5xMNS1R5bx0NlLdRd2 ; 20171122 ; subDT >									
//	        < x01GJYh5J6ZgS1XVu6Bkg0cH4nvvKP1a6royWd2r2DChF1x86WoRErKXv5C9hFqN >									
//	        < 5k5Vzv867q6ZBF4xQnYo5e8W8SGHL5zkOoFC137RD3wXntoaRy54tq3MfNId4zDq >									
//	        < u =="0.000000000000000001" ; [ 000039665007031.000000000000000000 ; 000039679023223.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EC6BFF5FEC816272 >									
//	    < PI_YU_ROMA ; Line_4006 ; ii0C8yd1Z5FtSZFfiU1fRm2pPJ01675bt1ECfW4ZYX4UzX1JC ; 20171122 ; subDT >									
//	        < L82I61PvtvaUmwP3lq09EKGsM9Rhbu030aHDS39I29NTY239Pbnek3Q5u37ZDN4u >									
//	        < 270zm5jl1Uef2bAMK237qmuh70t92272mZ6Ou3CC3juPllH2eIWUQH8hFH3241Zu >									
//	        < u =="0.000000000000000001" ; [ 000039679023223.000000000000000000 ; 000039687565655.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EC816272EC8E6B55 >									
//	    < PI_YU_ROMA ; Line_4007 ; 75UoM0Q39m0nIPuO0KFdBgQFk8zPfB6QTf3Z60v1R1yjza0ow ; 20171122 ; subDT >									
//	        < o3ytRQ510Xatoc3U3bQ8m6U88wJ975ZLzlaKRw7LWTKb9IQs8x51wX4JF0crp7Z8 >									
//	        < 3LAdJQTkPU4EhO03m57F9L99WfSPu3BmbgZGEOyZM7FZVmnkz9xYZZV9LA6Z02Sn >									
//	        < u =="0.000000000000000001" ; [ 000039687565655.000000000000000000 ; 000039697721803.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EC8E6B55EC9DEA94 >									
//	    < PI_YU_ROMA ; Line_4008 ; fHwvZJG0C65x7GxrGOQ7YEA9E5o8S92DJpv49fjjDsIu6y7GI ; 20171122 ; subDT >									
//	        < p0Cx1VTjXqk72XHU8yd27sO4M09taYXBid35HuQc9qL15G0j65200T42Wt40sPpB >									
//	        < Q94gPxNQ08g7aL1bj4gfC45PIn3u5XmjsZwkTn5x0M8Mp8d3v9pGYzF22X4u5O8W >									
//	        < u =="0.000000000000000001" ; [ 000039697721803.000000000000000000 ; 000039707792206.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EC9DEA94ECAD4854 >									
//	    < PI_YU_ROMA ; Line_4009 ; A42w2M9mc96I9rkUV8A3w68tNdbHr4OVkrK8oy3s88YQ2YM2V ; 20171122 ; subDT >									
//	        < 88gk0nnSe27VD2NR5wJq38Wgj1x37FgC0wszD366YjHXGr92140x1XC01A1VW3Qx >									
//	        < 57wyqco93I6tL2sa623qKhZ968f0idGjB6izjsOO4PW5RM81Sim765HdvflTmf82 >									
//	        < u =="0.000000000000000001" ; [ 000039707792206.000000000000000000 ; 000039719217810.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ECAD4854ECBEB775 >									
//	    < PI_YU_ROMA ; Line_4010 ; xsu2cx2ntWV06y3Zv9TtDOiNS0Ch6v9I017L86mdWwm5rhU1a ; 20171122 ; subDT >									
//	        < JBbwLTBeLXA4m3ldB8k0550wd4qqUqUSY8rhyGB3hfYTNo35iccnb5G10Xp276yh >									
//	        < 2FaayG0VD0wKs59pU513DKJ01FcP49UdSQiofjzV9c6a9AOFe8vPg7l72iQUR17D >									
//	        < u =="0.000000000000000001" ; [ 000039719217810.000000000000000000 ; 000039732198815.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ECBEB775ECD28629 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4011 à 4020									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4011 ; bmSvIG1H18eMuk2U3881E1m5Y6bR8994vls912AOe9sJ6556e ; 20171122 ; subDT >									
//	        < Oi97f7Zs16SW59y5r9BsRRE0GGL55at52w3CREkefH5zpDr2ZbbD45qo4a66Qz8s >									
//	        < cqB66cdowSm7qup40ZW5E81y0UuJjaf8SPC8nsq75bj1Umo8a5f9oNff4V2h408S >									
//	        < u =="0.000000000000000001" ; [ 000039732198815.000000000000000000 ; 000039744005544.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ECD28629ECE48A2A >									
//	    < PI_YU_ROMA ; Line_4012 ; vN9VaJyRg4GmH4ns73Wp8H5L63HClH606W39WygzqPxtXPL6n ; 20171122 ; subDT >									
//	        < yVXIJ90fSBIR1efOS4Yd5L7EXzBRo88yx6o0Dykz3tpS3yOpj3XMfnE5WtX2yaga >									
//	        < p485RXWGT4R9S88Wt29JHMeKM6n3g24WJuHQJNhGz15MLA910j5vpm0h2WYPNlS2 >									
//	        < u =="0.000000000000000001" ; [ 000039744005544.000000000000000000 ; 000039753448828.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ECE48A2AECF2F2F2 >									
//	    < PI_YU_ROMA ; Line_4013 ; 443pC88Ciejvd84c61JsR8JA2akX2FxujjpSk2v5U7By64n9Z ; 20171122 ; subDT >									
//	        < uIm86e8y48ukd346XTe7Fo3K1C33OYk2W9Lff98JNS53SyP86cq7h183d4NMZ387 >									
//	        < t84d9eOCsVWlwD9d8Uc69qiKc4r3q84zVS0657dp7LV6HJWUSu9SuSFXx8yhH4ZH >									
//	        < u =="0.000000000000000001" ; [ 000039753448828.000000000000000000 ; 000039762614565.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ECF2F2F2ED00EF50 >									
//	    < PI_YU_ROMA ; Line_4014 ; iAzmEP5nx2oXwW7OEfAlxMR820c99637M6ioK1OLior73Ftww ; 20171122 ; subDT >									
//	        < jrZbaHdVl968B2aSnmt7pqRYpDc5pLY11i78MT492Pdh5Wfy04G62ZD9t48HeM0y >									
//	        < M7jL99U6pda8gl1m87R7jGW509eIAEdjO2U8JuL4mzLVNq09HX1R60Mt0764LXQj >									
//	        < u =="0.000000000000000001" ; [ 000039762614565.000000000000000000 ; 000039771293798.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ED00EF50ED0E2DA3 >									
//	    < PI_YU_ROMA ; Line_4015 ; 9mS62FuJUU15bTJXZjl0wn1ya11NtE7xH0u2T3Hnv04b071Hf ; 20171122 ; subDT >									
//	        < 4FK4kjXWvSm9n5msV5j8vcKTCs1x44j6rDOAbio7T0G95eH2MdQQpfM9Q453K0SY >									
//	        < PTQO835uVPc0kH2J7c6aty8P4vEhlZZBtF5m5NfPjqQS63ogC2LV15D5On5sGBuC >									
//	        < u =="0.000000000000000001" ; [ 000039771293798.000000000000000000 ; 000039777213719.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ED0E2DA3ED17361B >									
//	    < PI_YU_ROMA ; Line_4016 ; 1JlPW9929TfdTS7DjFaSBUTK0m4DW25K6ewNff6n4k2F2G70G ; 20171122 ; subDT >									
//	        < 09Rhzp36h2Uz6B0Zl24Kd2vg36U9L0jYJRQb4noLV9I8UN0LDFADj3z83dW70msi >									
//	        < jI98KICr5Y1h5M2Afj6swAeh197jYw662z3RG5HMUV98FNVOB2eMC9slwtZ9w3Ry >									
//	        < u =="0.000000000000000001" ; [ 000039777213719.000000000000000000 ; 000039785682324.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ED17361BED242228 >									
//	    < PI_YU_ROMA ; Line_4017 ; KmLcpVYLzL1CyrIz4wa6N3I53U9I1MO6pTxC6ub18dgO0Qf4H ; 20171122 ; subDT >									
//	        < HTu04WiVwJWoGeORR2bO3wko0RTXHGs6054VLCwM0q3shPzqcSO5U6m7iQ6XPtZS >									
//	        < t8i5Geshywf5rX1l41UGjUG7QTw3li755ryx0I44e7wd15ZzZf8Zf0npbhmSX2ck >									
//	        < u =="0.000000000000000001" ; [ 000039785682324.000000000000000000 ; 000039794759840.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ED242228ED31FC10 >									
//	    < PI_YU_ROMA ; Line_4018 ; Fd5f76xVmJwxj838238uzxi7l50jtijNmaDkr0G5n82Kbu6UG ; 20171122 ; subDT >									
//	        < yqt9Yu1xS5EEkOMHQ6630Nu2g40b1OimMoHm2GCN5S649zKSSBc4y6w8k5fA61vr >									
//	        < Wpih8bJ9JF1aR9BM9YnwAnS3sL5uf8488xt4Q0Ivn2563XS80HJi3u0LKqB8Hto7 >									
//	        < u =="0.000000000000000001" ; [ 000039794759840.000000000000000000 ; 000039799886026.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ED31FC10ED39CE7A >									
//	    < PI_YU_ROMA ; Line_4019 ; v9zDFPexXqXvR33pyL7TL77FdfO57076Mp1x0sNiiZ0WK25rA ; 20171122 ; subDT >									
//	        < bWnzyh75rQL87jl3X72Vw75QL8NFuTCB26lnPzXSbAJ9Fdr5nW45v9UVX6z0Vs9D >									
//	        < YJL031zdm83KTCX6TD1I0ajN6hrAh4QLfW95tSp94aXYE0r58F2x9yw4x3aT9RLD >									
//	        < u =="0.000000000000000001" ; [ 000039799886026.000000000000000000 ; 000039811768654.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ED39CE7AED4BF021 >									
//	    < PI_YU_ROMA ; Line_4020 ; 2q8i8QDS5Wtky0zP7N4Xrq9zfXqMIuL5b9Cdp2AozXGS90cOy ; 20171122 ; subDT >									
//	        < PZY50nO49io054UEM07LpM3rCh5eXpC09mI9h267oN80dcHKQ8V01CTt9Z6XsR91 >									
//	        < 1ia5VsJof2N5n4d9JtL5Qo48F4TsJB4YUS9USxqg73DL44i49y8dyLiNBQXztMpG >									
//	        < u =="0.000000000000000001" ; [ 000039811768654.000000000000000000 ; 000039823034608.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ED4BF021ED5D20E4 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4021 à 4030									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4021 ; nsWdO053sThKlVl0ZUXJOvzyEUHkSk5RhdYeuCDL97N7wWkbj ; 20171122 ; subDT >									
//	        < v5o22Mc23tYywYU6mGcnZNCqtaVFG6vp9Dm22Eb5ED8bcZpQcAa01NmP2JjDLjnM >									
//	        < H5grGNVx2hd4Psr6zr5F7GoNrZQZNZ1NA39O8Gk35n4QONen7nUc9CmGmKd90oaO >									
//	        < u =="0.000000000000000001" ; [ 000039823034608.000000000000000000 ; 000039835939275.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ED5D20E4ED70D1C7 >									
//	    < PI_YU_ROMA ; Line_4022 ; 5Up9v5Gu0018216VgP7D0665A3ba7BenHG0gb5rLp069F2IU2 ; 20171122 ; subDT >									
//	        < 08pCVJ1jaJ0HB9059wTBg0MRhiBEK413CfT0v1La4G54QuyiL7WIk088167QPtVU >									
//	        < ICs38HLRyXo1nSHj9y68KcC8gr05HSD3pgqW22650skNmEovE4bTk5A87sb3Ood5 >									
//	        < u =="0.000000000000000001" ; [ 000039835939275.000000000000000000 ; 000039844651170.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ED70D1C7ED7E1CDD >									
//	    < PI_YU_ROMA ; Line_4023 ; 6mwdt5IyJ4rgNmJuA5AQ5x3i3018dfpM7AoL84pkGum1uqNbB ; 20171122 ; subDT >									
//	        < eVHt57nbDHC62si8fJXyxIu122h1ylrj307CDqOFi887ZcRU4MXPi8xd0H1BK4IR >									
//	        < CdZe5X1l8w93MQ1aMvjPn6cd8698lnB9sUOXtvVGlFvcG1I7Jf94j84QugxdwPkT >									
//	        < u =="0.000000000000000001" ; [ 000039844651170.000000000000000000 ; 000039854310820.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ED7E1CDDED8CDA2A >									
//	    < PI_YU_ROMA ; Line_4024 ; P47tM5mimEP0eUrj42niqF9Dfv1Di3h892CkQzQJ71Ds7xYf5 ; 20171122 ; subDT >									
//	        < f60yY2qLP4h926dCmd0TaSts9724KT4NvO4091ixn30gv3qU65yupzmFY03wbE2r >									
//	        < 92S5Qj5Pnhl6Y4WSWd835akuGO7d5c9DDVP9BLIOfrqF4BJucE6rqAYbF0s5ukAq >									
//	        < u =="0.000000000000000001" ; [ 000039854310820.000000000000000000 ; 000039866075651.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ED8CDA2AED9ECDCD >									
//	    < PI_YU_ROMA ; Line_4025 ; P1f1LI8ecuJ79KKGeGD0Ht5F5VWfp32CuB5HGVoL6cwl80avD ; 20171122 ; subDT >									
//	        < i7u58W9LeWce6R367i03GUqa21hJ2KlCoueaow6M0DY4OtfDe9A5XonPDFBS26i1 >									
//	        < 0pwOuKgLq2nHLb8iXBfzEZ19zBuO7g302k83eo5l5f58F8IAbdS8XARGb7d01kHb >									
//	        < u =="0.000000000000000001" ; [ 000039866075651.000000000000000000 ; 000039873634320.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000ED9ECDCDEDAA5668 >									
//	    < PI_YU_ROMA ; Line_4026 ; AFU5wdoWnK8vVv6k288W1L6vY23zOoHg5ok5hhthbkskH21o1 ; 20171122 ; subDT >									
//	        < ww4FtEJL7o6WzUU4rdhcsTQsc3fSba9Z8vswj0z7YiL554W63V2UB1yZ0qypjrIv >									
//	        < BNR06Q04o0EcXpIX4mP2eb98xEvENN0423a8HWQ4joj5PS9mAa5ie5z11pr3997T >									
//	        < u =="0.000000000000000001" ; [ 000039873634320.000000000000000000 ; 000039886947448.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EDAA5668EDBEA6D8 >									
//	    < PI_YU_ROMA ; Line_4027 ; aQujkwvJ4K3K1Qhza56SzFN4x8bjNJGYKCsFKxg97hFHO141c ; 20171122 ; subDT >									
//	        < 5FBcVaZZJlLMmgRsD3cY63GWlnn1H3fBUXqgjF0jIeG379eoS3Jju4ZNqxk7Y98T >									
//	        < 17zbX3Nh15et7iTUZ0q145U1387G8gTuyYv3ZvZ7sG5cMO8ff8r0F46uXXRMK9FD >									
//	        < u =="0.000000000000000001" ; [ 000039886947448.000000000000000000 ; 000039898694346.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EDBEA6D8EDD0937A >									
//	    < PI_YU_ROMA ; Line_4028 ; nb7kl1PL80ib6y8q98O9t5XYmiqdp72oY4s5tIy2pHNdeQDqu ; 20171122 ; subDT >									
//	        < Z3VyMz432AI0847th6449kDbQvCguB13Db54FQqw5LP65K91542AmER2mlyAyMZr >									
//	        < mp4Fmfm5gDOBxXS2MP1IQW36KiFlRjEz4dQy74l3q8cE6G8fD95626jbn2yJjm6e >									
//	        < u =="0.000000000000000001" ; [ 000039898694346.000000000000000000 ; 000039905479419.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EDD0937AEDDAEDE5 >									
//	    < PI_YU_ROMA ; Line_4029 ; Dnep5QF2sO7xGfUgh4aV9zAnrM6TYIttCFb8xIAGhT3yy0mk8 ; 20171122 ; subDT >									
//	        < uau6ktOuE8lrFqpuV48a3PGSMczyKjsn8NfK93oG4a2k2pOP3sbUtP1louJnizj6 >									
//	        < hW980tOWu6fKJtVSN86TU9IccFv4p9ETvbyqkB9f3W87o68kOBCnPh6UAt53DKxI >									
//	        < u =="0.000000000000000001" ; [ 000039905479419.000000000000000000 ; 000039914171154.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EDDAEDE5EDE8311B >									
//	    < PI_YU_ROMA ; Line_4030 ; B07lFU4382Sa2w56UhmuB9j5aFNrlLXQ2C5REhG233gfY9Nh8 ; 20171122 ; subDT >									
//	        < 4Ni2727NEZwYr5CRZ1225oq3655p01b1a16a6jjhQopKS54l3390U5uowT7i1hSf >									
//	        < wPj5tvR244j8d6Lf39yie0xPoy297v647mu9ObixTSrHE540ybm9vaQvDK36aZ0p >									
//	        < u =="0.000000000000000001" ; [ 000039914171154.000000000000000000 ; 000039922864025.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EDE8311BEDF574C2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4031 à 4040									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4031 ; a7af5M8qlD3b8tT6v766qTJ9FZGbD3736cK7676pOcxYYysnI ; 20171122 ; subDT >									
//	        < 9DP63685odmQ1FnRM82n4GcGPXVO6xmxFl8zeo1x32590fU5mlX1E27P0WWF3Fq3 >									
//	        < wnM3nnbZwN2w8u72zCJ52FPUZ3BROb81i0N3viEp0Xoo9sbMlO0SMIuX3mMnsQxb >									
//	        < u =="0.000000000000000001" ; [ 000039922864025.000000000000000000 ; 000039936627475.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EDF574C2EE0A751B >									
//	    < PI_YU_ROMA ; Line_4032 ; YBktRHCQt0kJ8Tu0xMjL5512Bp4Js5JKv663XM9pud9oYL4U6 ; 20171122 ; subDT >									
//	        < 4F7O4iZvN52HMcjmdT8JjSmR5TKbIliWk6B1RBaMNe2H174CsJHBcTHB4Dc9Lka1 >									
//	        < lSgr2oyR5qcWBYtZfbZ592p9WO34K2G6b9k7Nh499D69rORn4L2nklc4ORuQ06NE >									
//	        < u =="0.000000000000000001" ; [ 000039936627475.000000000000000000 ; 000039943575796.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EE0A751BEE150F4B >									
//	    < PI_YU_ROMA ; Line_4033 ; O44RF1X4C2PCohzdB66SmDn48um3sNC8wG77ED2tf0kVV2v50 ; 20171122 ; subDT >									
//	        < AP18U5000XzcKnYH7wZOz2z1KKY3fDxwAi0P375q0GDGbdraMGoBb3Xh56jaaKZh >									
//	        < 749r6KIxmKd6sxcM4QHl49cYyGaBpH4aEr8ciRUulcdme8qaWIh2C34nsQBRZ92b >									
//	        < u =="0.000000000000000001" ; [ 000039943575796.000000000000000000 ; 000039949694967.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EE150F4BEE1E6598 >									
//	    < PI_YU_ROMA ; Line_4034 ; 9P8baIxuSFX01Xl2W6QEz4h98wQDBcGNz1xjB1h3q2p71EWIA ; 20171122 ; subDT >									
//	        < Rbc5d5CliY9Xxo10g86kdojOxQNbxkcA5i2X627yR1N405p2yQbmd8n9T9We816u >									
//	        < DnKEu13P7NfEMTsXb8CdNPWC0YuKHPSgVSPZKImK9jMDf7PG88ixypFTkmPcL52L >									
//	        < u =="0.000000000000000001" ; [ 000039949694967.000000000000000000 ; 000039956408058.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EE1E6598EE28A3E5 >									
//	    < PI_YU_ROMA ; Line_4035 ; 9drOU6OePA086yk54VOrDCvq700JB6Ygr7kkchY1j8sCUI6D0 ; 20171122 ; subDT >									
//	        < UUl3b870726UC7UV5mxED9en683qUyyGxXGaj77360EJ98Y9EM2gz0MKUzt6Juxr >									
//	        < IA08w9e0PxrM5tN3CTqWuh1rggN4r8BZbYJ070ZN0y3Zv7E2p1Zq7u597eCznOJ2 >									
//	        < u =="0.000000000000000001" ; [ 000039956408058.000000000000000000 ; 000039966774868.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EE28A3E5EE38756E >									
//	    < PI_YU_ROMA ; Line_4036 ; 0Sa1E94321rrNaGlm4O37q40q7075B9LX159Ed76DKb8dk4rU ; 20171122 ; subDT >									
//	        < 3eD3OoZv42njzY7zhEx4CCWU2cMh19zyCvnp8m23w3jDdn0F072S4I91oKlB97A6 >									
//	        < LLsIcFlgZJB614Ir2JQhOfg35ww4HxzM3w0FFIqA7nJ5eVn7dtCP5ztTo1Om7nAc >									
//	        < u =="0.000000000000000001" ; [ 000039966774868.000000000000000000 ; 000039978490970.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EE38756EEE4A5609 >									
//	    < PI_YU_ROMA ; Line_4037 ; J4H4DPq5M4PhK5Fs8jJYe8e6EO23rPgC226d9S064xV4uqYwJ ; 20171122 ; subDT >									
//	        < 2x4c8dX2BEAn5DEZEiCd6eq905pZZ29da7a5Kw41xeKuBo09EwFjIv7693322Cmi >									
//	        < jG8h8G25oqOD4y5u28766zFAx51h625nM5Sdv6TRL0lMR8x6l3koh4uM7W3JRzrd >									
//	        < u =="0.000000000000000001" ; [ 000039978490970.000000000000000000 ; 000039991151927.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EE4A5609EE5DA7B8 >									
//	    < PI_YU_ROMA ; Line_4038 ; 8QhTYj051c1NcnJr42he92K7RrBAFwVaeY9ndM2M13PKWpE46 ; 20171122 ; subDT >									
//	        < tUxqhydTLZ5biQg3x7A6xKUaWM6SK5bzIj0Hu2xpVpsc8PnzErh35860IrMT7e51 >									
//	        < x6613YYA183Q8lBf615Iwaal0cp2HsWBJVp3MvpxNu6Y7E7Q063A4353enQZqVdQ >									
//	        < u =="0.000000000000000001" ; [ 000039991151927.000000000000000000 ; 000040003959087.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EE5DA7B8EE713284 >									
//	    < PI_YU_ROMA ; Line_4039 ; W682Go07I1LhYAtLsLdv1AI0mn4Uw9mi83Sxmx9K9hz0NUZ2y ; 20171122 ; subDT >									
//	        < s90Jeff7RL6xQ8e548q0G70hGZYmASBqkzXV8OF48n8skT2b7281e0T1fl1cGhhA >									
//	        < was8Drw6K63v54K1zj11zis5GimL87LB4M8u6bfco8IVR1cm5wg77oz5Ta8ZEadA >									
//	        < u =="0.000000000000000001" ; [ 000040003959087.000000000000000000 ; 000040015785232.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EE713284EE833E1B >									
//	    < PI_YU_ROMA ; Line_4040 ; u23iaALYT7We7rRDlbfSwDbG7Xx9woDubWWJK7561k1FMYAW4 ; 20171122 ; subDT >									
//	        < Jl8PFmpJTXm8WhxsxQT5sD3zkhv5u97766Ck2u72wNWKWkLUe4iUDLbExkXtkn7x >									
//	        < 5AE1kHN3567GI7LS1f6hwzHmZgkgp4sroIBB54iT0Le28q7RIP71CgVGX7zq7Liw >									
//	        < u =="0.000000000000000001" ; [ 000040015785232.000000000000000000 ; 000040026051008.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EE833E1BEE92E82C >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4041 à 4050									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4041 ; R7HvXjW86VU496gciP7z27Oo0F1Zn3bqhDk7tjP1hP8K03f5p ; 20171122 ; subDT >									
//	        < 6V1qAwazOex2D38d9BoWIPBpE58YUbicopmcs8UQz50x7419k4TvT8a572RQvaj6 >									
//	        < 5i9By0efINCW5OjZJ6R4OhhEdWyq61HuGfJ2nAAZzeQ8dL7pngcEcP23aGmI3S86 >									
//	        < u =="0.000000000000000001" ; [ 000040026051008.000000000000000000 ; 000040037447709.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EE92E82CEEA44C02 >									
//	    < PI_YU_ROMA ; Line_4042 ; A0k9PeLwefd73tm301TJAbS94mc5P22j39l5Yh4912SLoTWZ0 ; 20171122 ; subDT >									
//	        < b0FNMEX6Lj4wT10EgvV4tR4RrlX4723868pw3e74lur4lPFuIBOw537mUJEQks70 >									
//	        < XSD8n8b8VPXvf485Nq2E98u6p1KhHl3zYYIad675pMxeh9b3Oo384I4a5sd5DM3A >									
//	        < u =="0.000000000000000001" ; [ 000040037447709.000000000000000000 ; 000040044797866.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EEA44C02EEAF832A >									
//	    < PI_YU_ROMA ; Line_4043 ; 509sKQzY7iuAOR8XzN0KYcRMV1A1669ZX7q7rcN76B7w2knc5 ; 20171122 ; subDT >									
//	        < vF435ajLI0yyG0Xf1s0bzhF79263I3cw0OA0zJ6k2qLY4S49Bj9G6B8Gi9453HSK >									
//	        < 3aI73clutBt4Pe2AQ12n37c438E56xcn3vE8WX90PvL12Av9U7v85844t9wPSlRU >									
//	        < u =="0.000000000000000001" ; [ 000040044797866.000000000000000000 ; 000040054808809.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EEAF832AEEBEC9B0 >									
//	    < PI_YU_ROMA ; Line_4044 ; Q4Dpzvo098HUi6D27SeG6tHO6hxe2Q12k98KcfazCJchyjfKK ; 20171122 ; subDT >									
//	        < y7R215g3263xc8m0y6HZ0zVYRNY494ev1226pzqDu5IPYQ7PsX2l4r0dM4TKx3oe >									
//	        < 3jWgX33N24W7MIcCZ492E12e1b2VeAkeO518f71aUsaqj23oP5kQ9820nxYH48d0 >									
//	        < u =="0.000000000000000001" ; [ 000040054808809.000000000000000000 ; 000040061204780.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EEBEC9B0EEC88C1E >									
//	    < PI_YU_ROMA ; Line_4045 ; rvgh1Q4x69cP1F2Msw9Zjf640Pm1IfdAOdxKl6chooyygVNY9 ; 20171122 ; subDT >									
//	        < 1F25CmPP29yS220vIPjye106Amx2Dq3X81199eqsD0L4wUk7rEYDM9267mY2I24Q >									
//	        < dLTy9FQ9040kI44cwNmwN75u0Np8hvz4107R6i07J006w0VaT780Qw7dL0480a2u >									
//	        < u =="0.000000000000000001" ; [ 000040061204780.000000000000000000 ; 000040069538144.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EEC88C1EEED54356 >									
//	    < PI_YU_ROMA ; Line_4046 ; 0hP05rrmZO6g4U6d9wygNpeXBI4lycP8A2weCF25H9D5TzV98 ; 20171122 ; subDT >									
//	        < gDhx4mfdI250t2Q7lgIEug821oAw11d8GJX6s7255q99cAVR04ih2v5ND5hH0X5J >									
//	        < bcXD2i9hTfCv5f4ZfD8m1Gu5cCE88cKj74F0FdtW15uYXEX1emzZy7480iSsi2k7 >									
//	        < u =="0.000000000000000001" ; [ 000040069538144.000000000000000000 ; 000040082353635.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EED54356EEE8D163 >									
//	    < PI_YU_ROMA ; Line_4047 ; ikGQynrN5Ap5krfnWn911VljoYriL839IeIhE18vE64t150n6 ; 20171122 ; subDT >									
//	        < ekK3Pd1V06Ztr0u6f0p7xtE85wBY4Nv0kiBa45mTTGn4L3exworpyq6TIZ23EbTl >									
//	        < 0Dt9LQhn6pZ860bYQoLRR9FwrGK5TJ264jSGjbVIW3mMCzDu452K2Q61C3oo981g >									
//	        < u =="0.000000000000000001" ; [ 000040082353635.000000000000000000 ; 000040092487566.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EEE8D163EEF847F4 >									
//	    < PI_YU_ROMA ; Line_4048 ; E81lNSVaG316M569d6BEDhTP40x4a7o3aZ6C5U8S251F3Co50 ; 20171122 ; subDT >									
//	        < UaTn966Ve6DA2tTp32ocA5RYPKg7o1Y8iX3fgY9PY8Jj1o365w6iLIQJM9m0Wk4R >									
//	        < 5EFh0UH73ILA8Lge4lyrPn0NDaG2j66bwDW0JIv07do8uCDJ7dsvMiY0918yeF56 >									
//	        < u =="0.000000000000000001" ; [ 000040092487566.000000000000000000 ; 000040104989137.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EEF847F4EF0B5B61 >									
//	    < PI_YU_ROMA ; Line_4049 ; 8QZmLd5V6n8kE2ssE50dNAS3kI95vYeK19999OtkY3GrDfXh6 ; 20171122 ; subDT >									
//	        < rc146qTqBjRHTu3cKG5AWz49L0NTI4625DUic1r600D303W2LjJ5k32BD6P4MBRk >									
//	        < 6iLX0z427Mkq7L7Z96jXZFTW16LOnDwJDc2P2FOO6mbG4BnHcMyU19LgMA3Ni735 >									
//	        < u =="0.000000000000000001" ; [ 000040104989137.000000000000000000 ; 000040113786507.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EF0B5B61EF18C7DA >									
//	    < PI_YU_ROMA ; Line_4050 ; 9PNE56G9lsgtqq3tPy7Ms8l8KgT4Bwp5lQ2hQ3J5f4C5JX670 ; 20171122 ; subDT >									
//	        < yd4LTkWY3NIcdEB7S03Oe0n94B603152P508L0PWV0tf5D8ur5wnszL5qw3OawTa >									
//	        < 1JTOPvSZUuqgnw6esyF7MQWn8Kuvs945JL8PWD3l8V05Jo298U1KSK2DXqJ06U2G >									
//	        < u =="0.000000000000000001" ; [ 000040113786507.000000000000000000 ; 000040119468002.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EF18C7DAEF217330 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4051 à 4060									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4051 ; D4BZ6Av9QC65F9G6mB9El172cQ05m9b2ExGo4MDDoESnIOZOL ; 20171122 ; subDT >									
//	        < 4801nMine0Lb32f1dIIP89j9HkR3TVK742u07vjeuBh0JH1r7eCENnAayWKQK6B9 >									
//	        < I8YSR740ySjrg4ahZRrMG7u2mv4zQDY5wC2Y847428k38GHjz0OvJh8134840wU3 >									
//	        < u =="0.000000000000000001" ; [ 000040119468002.000000000000000000 ; 000040131578084.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EF217330EF33EDB0 >									
//	    < PI_YU_ROMA ; Line_4052 ; R08U2iELXFHZwwy5aB8KZL2HOL8zCWVrs5QHXI9W0Zvq5Y880 ; 20171122 ; subDT >									
//	        < w3D3jDUG3MON1xX5oiA61fSiV4kxgyPrbfNHt0IGDMF4869MuSMqy5S1ggwM7lN3 >									
//	        < SLeT582m6g089vkdy92XAbB1EN7BR632i0Yf407PzmWhCz57hPR51hFw3A5LvHkk >									
//	        < u =="0.000000000000000001" ; [ 000040131578084.000000000000000000 ; 000040140741364.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EF33EDB0EF41E918 >									
//	    < PI_YU_ROMA ; Line_4053 ; bmbPmG72Oj4p91w8LO5sckyiRKH7IEbj4647cvxjDfxp0Mpih ; 20171122 ; subDT >									
//	        < kyk4Iv6L3a4Y4tedl31mNJFmt9RRw6Q95qhabd2ohmmdAC0HAT1MhBl06L8eITxN >									
//	        < Oco5YMYu5jy85zuAe58nme9R4LMvvvk8P2MBVE3LFmjaHYMj00zsSgb1vh276Y6T >									
//	        < u =="0.000000000000000001" ; [ 000040140741364.000000000000000000 ; 000040146710747.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EF41E918EF4B04E2 >									
//	    < PI_YU_ROMA ; Line_4054 ; Y07nUdD3N22C1boQ0VFyrF613l90eTpR48pzQ9d34vmhA8C50 ; 20171122 ; subDT >									
//	        < 0t7G37QRSVxvhsAX332Ic31378agOHZfyhIOW7G151xC2J5j87g31Q2c264243vH >									
//	        < a8nEG72y49P1jzL9408le5D9VAhAg6ZPi0q88e01T37OG75mSdIBFO951Dyh1kWi >									
//	        < u =="0.000000000000000001" ; [ 000040146710747.000000000000000000 ; 000040161264816.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EF4B04E2EF613A11 >									
//	    < PI_YU_ROMA ; Line_4055 ; aE91LQceykN3925WJzu2mOyDd1cZ9Y8Us9m9E81AH0zS7KrBR ; 20171122 ; subDT >									
//	        < i3sC0mSt8I3e85435sM21Qdsm708sh7Q2leTyB91JF764DF2qN74FSQCGHomG1gQ >									
//	        < 4MNBEV2NDb1mL0ObNT2NOaHHzb5Z254z4rN8BZ3zQ5PnbR0YsIlwN6JdvBET3YBD >									
//	        < u =="0.000000000000000001" ; [ 000040161264816.000000000000000000 ; 000040173373890.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EF613A11EF73B42D >									
//	    < PI_YU_ROMA ; Line_4056 ; 2P5Zkhcz4029V3Gg8n95QSW7WGfm6DPkQbt4JZkLKr0k2EmW8 ; 20171122 ; subDT >									
//	        < A12ABXqci3VH9A6S573NTIU3F5KFGJ3RlGH15YA4vY01fsslvCDMYEwZUj02C1LV >									
//	        < QPYUj5J3nLW5ayipyFLp8el2gotf0IMkdvL0Jac68tGC6pO68N5mlZ5JCjU4d9GA >									
//	        < u =="0.000000000000000001" ; [ 000040173373890.000000000000000000 ; 000040183491935.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EF73B42DEF832489 >									
//	    < PI_YU_ROMA ; Line_4057 ; IU6xd3rQ0PR434dMww6z2ZlBFI6o902d60QV2E2TWgDG2Ju5R ; 20171122 ; subDT >									
//	        < tD9dHagM676FU4bE9Cs9T9FEY1tqs9kwrk0k4Ql7820gT93e70KHkVV8uQ11HX4A >									
//	        < NjOemn0XCeGul0eQ55SH552283qj0gKLQ8NL8xpctTWDF1991iyE14ZCh9wUYRfR >									
//	        < u =="0.000000000000000001" ; [ 000040183491935.000000000000000000 ; 000040193737628.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EF832489EF92C6C2 >									
//	    < PI_YU_ROMA ; Line_4058 ; 23JwiCcGPOTHCPhzQmQ59a4AcUm5mHFJiL9P1MxjPwtP1OURD ; 20171122 ; subDT >									
//	        < 95vSr95AqaZY4w4NQqHE31Qu94Bcu4D9jjXDtF8PfPw4b9lx69Fl7yqE4EbPPHI5 >									
//	        < d7kCKnQxz0l9XFgu6H0ZAgE8Uf7i0lRl58PA87VNh92MBnWQiXp6YGHksHTr926N >									
//	        < u =="0.000000000000000001" ; [ 000040193737628.000000000000000000 ; 000040205718346.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EF92C6C2EFA50EBA >									
//	    < PI_YU_ROMA ; Line_4059 ; Jd7RQYDpg0u3Ye3C6432crME060PAD6k2BCa5O48vZe2Fu6PX ; 20171122 ; subDT >									
//	        < CmW672562W3I3J88wlfjfHdKhNmUm3IY4Z2f8BU1b2C3s4j13yvOQ1owZ0XMk2Qx >									
//	        < KaQPXaa6zR7J61gNF2HZ7sEhw5TGbG5mcV1gIJCCNiH9Lw97DoDnx28Wx5t119Uf >									
//	        < u =="0.000000000000000001" ; [ 000040205718346.000000000000000000 ; 000040220176981.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EFA50EBAEFBB1EA2 >									
//	    < PI_YU_ROMA ; Line_4060 ; l0k06XmAa5vR3bv0s19RDw8ZV3QqR3oB3rcUvRDZ5kLCEDpcL ; 20171122 ; subDT >									
//	        < 23yh5rMH1FRlJ3f8l7FF8ZA6Ta51KL2ez6Hg33QsnE13EWpLmdfCZn6WB9aUDrwH >									
//	        < 4ACeA1dfJs116U4Ad0OKd5H0w8j390lw1qyV0y62AmM5YX8S24cNnJIXvg0BcZfi >									
//	        < u =="0.000000000000000001" ; [ 000040220176981.000000000000000000 ; 000040234399582.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EFBB1EA2EFD0D256 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4061 à 4070									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4061 ; dhvTD510cvJl60i5H9xylU98wG6CsUAlNyX6AD331UT4y918G ; 20171122 ; subDT >									
//	        < Xoox05vWxP89pjlay5Nqk9M2t2937RJ83R3A6v701JkdOb5uT4K0CpZhT2W462z0 >									
//	        < 7u2nqt94z8t88S8rW8qlNqcE0fF9bwmKGR30WcSrcm6a6148n64gk1kgHSt8BjSx >									
//	        < u =="0.000000000000000001" ; [ 000040234399582.000000000000000000 ; 000040245146975.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EFD0D256EFE13889 >									
//	    < PI_YU_ROMA ; Line_4062 ; 6zyh14v5qthXLuQw7Z0BTRAyW6HdGVMMwLyZ0P6pxmfLyqK1L ; 20171122 ; subDT >									
//	        < m2K7LG667ebrawV9V830090TNor91aV1R0Q01056ql9Qhb5bvya123ZNf550P1k2 >									
//	        < M9q1Au9V9OvJSVTG4he9fxa4Opf5i2w3tdu426yR43wjX0bl09qRs2u8ae3lAKsa >									
//	        < u =="0.000000000000000001" ; [ 000040245146975.000000000000000000 ; 000040256549542.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EFE13889EFF29EAA >									
//	    < PI_YU_ROMA ; Line_4063 ; 512aOyn44b8850nyseQfmYJBOyU15IV4M5QPp3zrV9ct8blSD ; 20171122 ; subDT >									
//	        < j5kwJ4F6c2gm6icqncy1mW1xOwlp5RMrW7P3WHfHL9fj6NvbIr4U3e51mBuRG6W0 >									
//	        < TPHhE6N67lp54a3qcp9D3T070rf7S0Mf3Gn67OK5nqg57wJp75cYL0vIoij6U5NW >									
//	        < u =="0.000000000000000001" ; [ 000040256549542.000000000000000000 ; 000040264720939.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EFF29EAAEFFF169D >									
//	    < PI_YU_ROMA ; Line_4064 ; 1h5H8688BT8I96igXGJ6406IAK8v9aUH7yKEfiTjKrzKRvij3 ; 20171122 ; subDT >									
//	        < w95m5X7B3ylnpwS9Of11nN54e2d2FD253g9ofAL3077c96oH06W0P6tyhbrwnZNK >									
//	        < ERC6JrkBUZLaFjQzR4E334Oe7AMpC2E90nxo5fankEbXFlw72Y8u58M4Ltt623j5 >									
//	        < u =="0.000000000000000001" ; [ 000040264720939.000000000000000000 ; 000040274131396.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000EFFF169DF00D7293 >									
//	    < PI_YU_ROMA ; Line_4065 ; wlmP3R059v1GU7gWTidS7P0429s5EFWeBXSTty7q6rXYB8fD4 ; 20171122 ; subDT >									
//	        < t64HnEUY49DlVQQ4R85MxC45F5L1YhPP1KKX2338L0Te3HK2EPF6O2wR5woD2dN4 >									
//	        < dN8F0IJUp4jx9p07O1lsQ0Eya80DY2R04JF5vbI5M801Dxlnj30fgI7wQS5Np9y9 >									
//	        < u =="0.000000000000000001" ; [ 000040274131396.000000000000000000 ; 000040280518419.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F00D7293F0173181 >									
//	    < PI_YU_ROMA ; Line_4066 ; Qrn3g3q6ZVltQNMUt4l1WOBNr7RPcVDh9Pk78CKgI7B52DB07 ; 20171122 ; subDT >									
//	        < e83QRn8ck3Q5DsY7q351N74ZwRj4f76YdpD4MUHZ7MPO7L0oaF768LvuGvev5p2V >									
//	        < X6442MwyMn1cKp4PVWNSwqsGGb44e5E1c4v47rwmErmQr7W4mh90ZEh0t6g74jn7 >									
//	        < u =="0.000000000000000001" ; [ 000040280518419.000000000000000000 ; 000040287859487.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F0173181F022651C >									
//	    < PI_YU_ROMA ; Line_4067 ; h04809487Y06M58JP9f7Ub9s31oTLn30m04FTz8Cecen6cSJO ; 20171122 ; subDT >									
//	        < MnHBMdG44HGlPehS9OKqc96N0PdCG6pbwQv0LNt5pFRT6DEuJsvEC6K5sF399PzT >									
//	        < ly4mQ1658LXnEb9R1J2U277T5qPPvZ0yFifAz0t7YT48KiXaZMt986S3nWq7dtkk >									
//	        < u =="0.000000000000000001" ; [ 000040287859487.000000000000000000 ; 000040301096160.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F022651CF03697B0 >									
//	    < PI_YU_ROMA ; Line_4068 ; D0VAs2f1uKfzRf41SLXNSac07C1P1aFr2d3kR1b47Oq0BnJC9 ; 20171122 ; subDT >									
//	        < AdKz7g0mhXXl4aNU9a72TBGH1mUHt8SRz9qYs942dWBN2ws4BbYA6YbddK07THr5 >									
//	        < V94H60gTN2QRD4350Pd1zf0EPkezm25oOy4Ge25z049G8nB9Q25p927wPfw0B5l6 >									
//	        < u =="0.000000000000000001" ; [ 000040301096160.000000000000000000 ; 000040309234945.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F03697B0F04302E6 >									
//	    < PI_YU_ROMA ; Line_4069 ; w810Y4odOqO19iy5Peo1RzC4139QnAo0s6UI901tcBGYc3mvr ; 20171122 ; subDT >									
//	        < J095ciMGOl3dZuIZQU1RX0l85v20w49Pa68iv9LhiX0obBmTMIi3binUew9dm1dj >									
//	        < Zh56jVC2CV8fLt7775n46Z427twhO0126z8maZ7BVa1B88zG5UIWnG935A2azNE4 >									
//	        < u =="0.000000000000000001" ; [ 000040309234945.000000000000000000 ; 000040321035397.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F04302E6F0550473 >									
//	    < PI_YU_ROMA ; Line_4070 ; 1lsnE2faPVycx37r175zAeRg9sQ6aXf1fltD28Ei2GJkbvuf1 ; 20171122 ; subDT >									
//	        < OKcec302Hr5381CYcSRDrIyRe4FMb2achUkY12QZ88ngI4L591cxpc0itujXG3TF >									
//	        < y8F1FgpQT5BXZQtYdjP6Yc5ZLSfW8eWTEwRiYNyvjr1vZ5WXZ6XqYXbqHdQ0c2r5 >									
//	        < u =="0.000000000000000001" ; [ 000040321035397.000000000000000000 ; 000040331222263.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F0550473F0648FB2 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4071 à 4080									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4071 ; FX57jH1OWzLZfQph3hU2T9c48fLpR308802sV7J6x6s2DM5jp ; 20171122 ; subDT >									
//	        < 1Lumgb7LJbnw67MRbgNLOG2UyEXSex4Gv3NHRcs4r5cEE690e4C0rdxAa89SvK81 >									
//	        < oFx2w6383m0m0QxT9BXVYDwI7Xyr4A4mwb1P40O135z96P2hEhgEsIET39Kr5utQ >									
//	        < u =="0.000000000000000001" ; [ 000040331222263.000000000000000000 ; 000040343772868.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F0648FB2F077B646 >									
//	    < PI_YU_ROMA ; Line_4072 ; 0I0QDtLzTK69qa3XJtLMPJjCPTPB96xifcB5IeOU77Xs4FDMK ; 20171122 ; subDT >									
//	        < 8Yo37Fibzz9s17hGD4PG15qZdv5j0TAHhC56H3T2755393ppgWCkr6cpCYu6gw6S >									
//	        < ZUbOM1UH5frvK9Mhw7PZI9xTHVQjsIi5633461p8D6zuDhn1AH77C6eu517n839T >									
//	        < u =="0.000000000000000001" ; [ 000040343772868.000000000000000000 ; 000040353371069.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F077B646F0865B92 >									
//	    < PI_YU_ROMA ; Line_4073 ; ygJKj9J7givL9GpmE9t284Uf979AlwmZkZUnw6raEu7lJ0y6a ; 20171122 ; subDT >									
//	        < uQn8aH4HSHrBKC42Pu8X6iL1P2m189dm6oq91V2l46Ld148dc1GnWtwJuK76IENC >									
//	        < W1c5l06iP0Bf06Bf40UOl6GEb1lW6j5m65gi2J0Gn21Bj0pv7q5adcVSM4R4l5nc >									
//	        < u =="0.000000000000000001" ; [ 000040353371069.000000000000000000 ; 000040360196678.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F0865B92F090C5D3 >									
//	    < PI_YU_ROMA ; Line_4074 ; C5YQiMWyoBVX1r5dgW1PQ315B3LPCpey7343ut8U4GctS3IU4 ; 20171122 ; subDT >									
//	        < P54alNwSR9NHodXod7oqByPK07WKeQvFxX2ysnNYX1fJ5blvA5h4X4V3occD8Mkj >									
//	        < Yv44bpp98EUTJI0s09pcG29O5vAbj2OJWAc73ORRrYH4rcE1cfkCZqF7bM2Ld461 >									
//	        < u =="0.000000000000000001" ; [ 000040360196678.000000000000000000 ; 000040373873731.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F090C5D3F0A5A46D >									
//	    < PI_YU_ROMA ; Line_4075 ; 07f55EBkL9GJx6s8Cl9kOepNsa4i9we4v59z7mgB2133BbQ8G ; 20171122 ; subDT >									
//	        < L61X2M8u86v6yAFNv1s3MH2DdB11hqwAJNk7IaLzW30MXgdt6HOf9kP4o0pdZqsC >									
//	        < 8HAN88c2wb5pBc99U892r9EDd4Z0Kx7Q9Ddd1M5R6I245fxySejedVlok6x0B5ht >									
//	        < u =="0.000000000000000001" ; [ 000040373873731.000000000000000000 ; 000040387021471.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F0A5A46DF0B9B443 >									
//	    < PI_YU_ROMA ; Line_4076 ; c1tO5Md9872OV18Al4frB535VjDWM2flwBK1R0jg31v527CQJ ; 20171122 ; subDT >									
//	        < 5I93kIE4vHm0B8MGC5Vh9mpRXkAjC3H652BPSs35GyK1417OnA7Wm1R7jP5LBuh7 >									
//	        < bc3T13a5S1R6F77KX013038uA3NbAyFP3wO6SO8oRJ3n8P2r42gIb2fdr7edxwfP >									
//	        < u =="0.000000000000000001" ; [ 000040387021471.000000000000000000 ; 000040394407715.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F0B9B443F0C4F983 >									
//	    < PI_YU_ROMA ; Line_4077 ; 42g2MdUK2nm3gHIhUy0aW9vOkd8MnxtY7IE598hK6bs57J9u9 ; 20171122 ; subDT >									
//	        < S2X372TFXJ115l0SOX4z29e91MofQ53btGOE2z2jJOS2LCjL9eF7T3O4FqiOzVa3 >									
//	        < dqWeTGw4pRzL45NBQ6vllGv6XW3cDKj1J3nONkC4zTRU5Ku3Nn76sI633fWg6Zgq >									
//	        < u =="0.000000000000000001" ; [ 000040394407715.000000000000000000 ; 000040400731692.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F0C4F983F0CE9FD1 >									
//	    < PI_YU_ROMA ; Line_4078 ; smhw5dB75d740ZmeEFG937ROTfK2NR4X29W02qIVE64Vlx05t ; 20171122 ; subDT >									
//	        < kN88D8xEh17fajE26O6Qz5Y9DGU5KWp18kyeh1ctA16X3hTZW5m1jv6tFpa7EM6p >									
//	        < 1k1mCOVAQmAgWk7waS9ldsIOAKkr5ZJsunLsEWJ83jRb97YR8AF5z06P5h16O6WG >									
//	        < u =="0.000000000000000001" ; [ 000040400731692.000000000000000000 ; 000040412860847.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F0CE9FD1F0E121C4 >									
//	    < PI_YU_ROMA ; Line_4079 ; K7F8ycmPewZ6jSNd2VIvP8B4nvXf7SjuW7yo16kfy1a37Z522 ; 20171122 ; subDT >									
//	        < fgGDHV9amlbvI9q1DGx61V516655yC6m61dsOCHZn67qCp39Y7ugu5Rk8VxrLOu8 >									
//	        < KEwCBtmsRgMcA7Ol1x7G6Qo8kgcW77ju23oVl76QjDVh695GK9xMF0ByqGWeEmQZ >									
//	        < u =="0.000000000000000001" ; [ 000040412860847.000000000000000000 ; 000040417897675.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F0E121C4F0E8D147 >									
//	    < PI_YU_ROMA ; Line_4080 ; nZr3Bfth30W7rjgyai9HYYK3oX85ZAP2uaU436w5vait5C9V6 ; 20171122 ; subDT >									
//	        < C4111uxtxO35X49U84qpwja0iFfDl32k7o3b1R328Up987zNCrjOnhuq3gdOXxi5 >									
//	        < I1T3p3fhuiAKjTwj31s4Y7f7wpFmq0g59ENUAII01Z0Pb9TccNt5iBpbfj3348Q7 >									
//	        < u =="0.000000000000000001" ; [ 000040417897675.000000000000000000 ; 000040431227154.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F0E8D147F0FD281B >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4081 à 4090									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4081 ; zm8vZt3Q1P9SxAPswEO9z4ELBJuHralx9jJ866j138c8MnlJU ; 20171122 ; subDT >									
//	        < M0sNLgYRuVD546apQCHOqFqBbkF6K1i2YQZ7Yn4hx1w5lp9hMJj114Px8654bETf >									
//	        < B6I0r709BXa0OxGMl3k709G7iufV26ds6G0zas7Y8t559MWF9o458k675h1Aru5i >									
//	        < u =="0.000000000000000001" ; [ 000040431227154.000000000000000000 ; 000040445241328.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F0FD281BF1128A64 >									
//	    < PI_YU_ROMA ; Line_4082 ; 31514X6B0D5A9679k1QQpB3jbx434zTiF3gScC48B7F4n76cr ; 20171122 ; subDT >									
//	        < 89VrAH7L537Eqv4TbE5H2J2ujA6ZX22W4h1YWQSZ71l084q82GEdqgvY4zFMD5zY >									
//	        < yGINmqfuVnN0Pzm8y91084G26Z18oH89LQu5bR622564KFf5KGlC9os3hWb7Z9s5 >									
//	        < u =="0.000000000000000001" ; [ 000040445241328.000000000000000000 ; 000040456209329.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F1128A64F12346C4 >									
//	    < PI_YU_ROMA ; Line_4083 ; 2Ls25rhBd94fVrW23cA96e1zmH2zSlcThIk8GAN3vZ8cPQ4s3 ; 20171122 ; subDT >									
//	        < qp0cDpzI22EvMZNMs3C8Vbgn41p5bsztbr3JCjRn6V8jQHk3pZK66Q9A4GWhlLSw >									
//	        < xmjtnw945U2QLNH0N8oDjjRN3vFz61b4xUNil0Dfo3PKgmVZ5HSh4zf19MT9YEia >									
//	        < u =="0.000000000000000001" ; [ 000040456209329.000000000000000000 ; 000040461877657.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F12346C4F12BECF5 >									
//	    < PI_YU_ROMA ; Line_4084 ; r40G41IqZbYZ4Sn1588PV0Rt3837433TIW2TcN5LIDgo9tGKT ; 20171122 ; subDT >									
//	        < uXo08eqUukZn03Y14I7AY04vABx7TRK49OL98d40O5W4WTznRCVKfl3GqA6nSEO9 >									
//	        < z9JwjE6V59EmnRhj4TJ5draU4VF9Y140wdSR2ik53pI7nHLDj9k1E6XI29KGfN3o >									
//	        < u =="0.000000000000000001" ; [ 000040461877657.000000000000000000 ; 000040474168701.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F12BECF5F13EAE26 >									
//	    < PI_YU_ROMA ; Line_4085 ; Hh89zjZmg0wpP844M3XMGG7XE7O9Sk4j37030vZUoa8r98l0O ; 20171122 ; subDT >									
//	        < d8KVc771tKh3lx8wClDuCMGK5mw9dS7418hNpFzxAt1Qe212ZUDqGC6DU943LG33 >									
//	        < 2Cn9dt0Lqu3L97101rQ2UBIzc48x4sTI0V0o39qK7edtI0tMS9EoROt1EXfeQIrV >									
//	        < u =="0.000000000000000001" ; [ 000040474168701.000000000000000000 ; 000040485328200.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F13EAE26F14FB554 >									
//	    < PI_YU_ROMA ; Line_4086 ; uT7CMaB81R7Dpi1W8ySw39BpKqKKX0MOcpx9g8uimtJs500gY ; 20171122 ; subDT >									
//	        < CEjz0L2I68f13LkOHw1246W96oZDrRg4K2K9R63PP70fgVf3Hk7A1K074RZ9v0s8 >									
//	        < 9cyW1o9FFE05btRyR5Di57D72Lj74GE260R4G357BCVmDiaXEuJ6NcJsp3a8a1Am >									
//	        < u =="0.000000000000000001" ; [ 000040485328200.000000000000000000 ; 000040493231298.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F14FB554F15BC479 >									
//	    < PI_YU_ROMA ; Line_4087 ; 3Q1HhkhuwRO3iY49E14CqtS7CE5F1IlRIyI5ZGHQ86KNmuJMR ; 20171122 ; subDT >									
//	        < 4OgmdM2FQk8IFXpR8g54y377Ah4GRF724Izl2Dd3al06ewPGgWQjuc1234QES26L >									
//	        < fGAg7V8Np2oh6i28HejrVtJDyWm2Rw3I6K7pu9UlSxURn87sYXmDax6O53Wo3866 >									
//	        < u =="0.000000000000000001" ; [ 000040493231298.000000000000000000 ; 000040500794043.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F15BC479F1674EAC >									
//	    < PI_YU_ROMA ; Line_4088 ; SbErprQ4czQNk12KeS7P7GShnD5782WL5QL2lbgtTQvVw5985 ; 20171122 ; subDT >									
//	        < 6WzYS6Et32IFf3I2SsIG918Z22bG6n7Agez3pBA4be4FZE24j96NakLV7XlrmrU5 >									
//	        < DEgaRoVmh44jnMF6glj0VxsN6rfha0d6wTbYa2928D95cJk28nsTUec1srrO5Q80 >									
//	        < u =="0.000000000000000001" ; [ 000040500794043.000000000000000000 ; 000040512833392.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F1674EACF179AD8B >									
//	    < PI_YU_ROMA ; Line_4089 ; 70803LU8OclR9RV4aq4S06Ta83XD08d6elOTshGQbty30g218 ; 20171122 ; subDT >									
//	        < kxf9SxvU3Fc8WYh4P9hS10ud7IWcIPUjz13QXJH7GQi3b9859Oc5OLAA4oGshh9p >									
//	        < SxYU3iXM0L9ye93jdHjg3aRq270ktgEQ8J628VFSWaU6260yM5m5mqUaFmo19jB0 >									
//	        < u =="0.000000000000000001" ; [ 000040512833392.000000000000000000 ; 000040524664516.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F179AD8BF18BBB13 >									
//	    < PI_YU_ROMA ; Line_4090 ; Nyqjl55cOhQop3gRwwR78yWU9VYx3t8h3bvQMWSiS946Dzm04 ; 20171122 ; subDT >									
//	        < WYOGJV30w0x8uVcf8qrigC3K8n9hay48btQ5K2Dd37O3c4088p93FGCl4NlF1RVC >									
//	        < 8VfpJeGjn6gRQO8E0Y5t0f0Kv2n53oZ2sN6amvx0vFbDyATo15mWlHsX1fv3UZWD >									
//	        < u =="0.000000000000000001" ; [ 000040524664516.000000000000000000 ; 000040531709531.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F18BBB13F1967B09 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4091 à 4100									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4091 ; xpAFfj8zmW2mNCrl9l77AqwEmM89oUmo8uDIMOyY6FCvx28xO ; 20171122 ; subDT >									
//	        < T6QV4CIyOt9JhiuacpP8iRMOO2q112oD19s3l4E2Rm35L7CA9q49BL7e6Z0qU5VG >									
//	        < FQt6VX6TqAsStT5E7F65rkCooY0G76on28C40318C9n0Vd9svrY4TGU0LLFs0e02 >									
//	        < u =="0.000000000000000001" ; [ 000040531709531.000000000000000000 ; 000040539389186.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F1967B09F1A232E6 >									
//	    < PI_YU_ROMA ; Line_4092 ; tLU927UG8vbF42qJAi30V5dG45p9k5hCf4115QAGC0JaB59fO ; 20171122 ; subDT >									
//	        < vwJ8Qas4X6AEP37gSQu3RFpo74ylr2W5QQuC4clIbiNJy5I9d4wN100mOMj5U5PA >									
//	        < h7LbeNVxt4b0kXSzb89aWe8eAxlamTzK7tap01p4K3s72Au725oH77X8PQ7z28Eg >									
//	        < u =="0.000000000000000001" ; [ 000040539389186.000000000000000000 ; 000040553028312.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F1A232E6F1B702AF >									
//	    < PI_YU_ROMA ; Line_4093 ; 40bxhBZoANA0D4dFr270kq5i6HEF9c4hyjCxt4l9VH21eYwO8 ; 20171122 ; subDT >									
//	        < FTsHUy6SpiQsOC34j067JyrddKcLj5Uc059f1X2kBO544QA8rfS5e42DP61b78x9 >									
//	        < 94gc97W8s5EkK4781i7ENt2mz1lvfq8h7IF3ckk7pINE7H1x2481L1E8Xnv2vs40 >									
//	        < u =="0.000000000000000001" ; [ 000040553028312.000000000000000000 ; 000040565508241.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F1B702AFF1CA0DA8 >									
//	    < PI_YU_ROMA ; Line_4094 ; 3nKJ4grh61rbK0K4kTX2dC8ms0SE467q54T2Lf30887cevI0Y ; 20171122 ; subDT >									
//	        < GVEwOG2SnGL671yypZB1UdEv9Vz3faLI5uJu62L4lR8BI40Tq8xUTebdGn44Whx2 >									
//	        < 746g2nUGOyVp7ld84tf3XJilyNSFb2kDrYoJPPsCz0hCpBcum04ck5u3DTv7oghC >									
//	        < u =="0.000000000000000001" ; [ 000040565508241.000000000000000000 ; 000040572607971.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F1CA0DA8F1D4E2FD >									
//	    < PI_YU_ROMA ; Line_4095 ; 363S5uShT0mCyP1lIDa6U2jOy596G4r8v8wNioe5fR652FWo6 ; 20171122 ; subDT >									
//	        < 4L4vaS0jWnzWninGtcURva909Pf75wow9hFmq8qu90ezp7w0BsAnzTlNxXT0573t >									
//	        < 7Am8PF9q198P9w7BX1s9glBH509t4j0ifpyR3Bp0clPYHL4RL949x34S9TEUb404 >									
//	        < u =="0.000000000000000001" ; [ 000040572607971.000000000000000000 ; 000040586987841.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F1D4E2FDF1EAD420 >									
//	    < PI_YU_ROMA ; Line_4096 ; lIjfi7sfa42XM8CZ95cPOUksmpQR651u8qQBq1pI6N7ehaVMN ; 20171122 ; subDT >									
//	        < xkZvf6l1tj0QI1D4H98k0UyKvIGEAg9eSMu1fcA4oW5M8743wW9KFxrNY4T4xcSM >									
//	        < ESTYetc3E1dJs9dDl5q9lt16TLKty5kch16eVc43a4drhjUDOE24TjchZffnX0xW >									
//	        < u =="0.000000000000000001" ; [ 000040586987841.000000000000000000 ; 000040597719095.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F1EAD420F1FB3405 >									
//	    < PI_YU_ROMA ; Line_4097 ; MDz6ZRaTF7aC32ChMhW1es8E47qU5Q0M944rc62Fj04O9D61l ; 20171122 ; subDT >									
//	        < b450MjMz38Es3u3O125m01DLeuoOPmb30bpHu25b23k4CVTpuxyAa73cKK38oDp8 >									
//	        < lK6H7DLrQy4QP4933i7BUPiiSoRtiiU7z5rp267W3ay81cvz1yq4x4S216q9HAN7 >									
//	        < u =="0.000000000000000001" ; [ 000040597719095.000000000000000000 ; 000040608790093.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F1FB3405F20C18A1 >									
//	    < PI_YU_ROMA ; Line_4098 ; 24AgI0y12F3Z12731B2006Z6cRa656VC0m8Kz3htn8p0VdqpT ; 20171122 ; subDT >									
//	        < 30GTyOKYB325UGvdfViQ7a82n3n57821uFjvW5xs0D03ts2w11dS3SaviL9B5qq8 >									
//	        < x50hkKJLMV6hoB9TWA6UmT7fe2EBr7qLQqUxdaB9d0mGlc681Cxy892z4yMQ9sV6 >									
//	        < u =="0.000000000000000001" ; [ 000040608790093.000000000000000000 ; 000040614155449.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F20C18A1F2144878 >									
//	    < PI_YU_ROMA ; Line_4099 ; 40L39KycmjJvDdLyrMzkH53T1m4ey8KN2VeAJ1HIC1IIie0A9 ; 20171122 ; subDT >									
//	        < RJDizh67aRo8UFmI70jtvYsE881ar7V1843e2R50m6WDFyi2JOa7gWLU9UC9SCL1 >									
//	        < x2z71ngBhlLZtg4e8cr85S3UZbgU3yu95LOahdJB2c00f05b0RaF2m4dAHHWrrFl >									
//	        < u =="0.000000000000000001" ; [ 000040614155449.000000000000000000 ; 000040621210883.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F2144878F21F0C80 >									
//	    < PI_YU_ROMA ; Line_4100 ; 7UXh6MwqpNhidw28OP1OzcSqo3iAw4w43VB4QAGXdasG8525p ; 20171122 ; subDT >									
//	        < 5Vvk149BVm92JrWBI37dM7S1DCIxCKkV35pR8wDg6Mps0J68A3s3213F0wK62vMN >									
//	        < Dx43TnN492jiAcUZ5G8i42wcQgp5nG3lSB88mP2589hB4o8eODur6Cyknb8eJL47 >									
//	        < u =="0.000000000000000001" ; [ 000040621210883.000000000000000000 ; 000040636019214.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F21F0C80F235A501 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4101 à 4110									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4101 ; 71rk7GvwPj9y0ZlzI7bq4LmRv18o5D6YkI0g9yGb7h9e8LYTT ; 20171122 ; subDT >									
//	        < CmN9SWkL2lOsry0zOjoj0I13HxW869O2o6H0ZC9jpn5cX5uicto9jZJA5Cc7469j >									
//	        < h9ZTt66Y62akIZ44kBN3Oeq7S1wXfmE9RbMJF6k1s3IO2on8GV5WVj6cS5y9yze6 >									
//	        < u =="0.000000000000000001" ; [ 000040636019214.000000000000000000 ; 000040650970404.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F235A501F24C7550 >									
//	    < PI_YU_ROMA ; Line_4102 ; g6zpfj7yZ71HgcCXr7jwoN9BCvo46fO12aRH7Vt022hEix37r ; 20171122 ; subDT >									
//	        < mU0I6gPvzngwqzq4B9CeltqoLzq6YWchKC1okN74q5115gCrG241F276VteYH9ef >									
//	        < jALGIBVDIZohc8Irew06DK445QWLp25qh4ysoI9v1zg3393WTiH68HIsFI5K4klK >									
//	        < u =="0.000000000000000001" ; [ 000040650970404.000000000000000000 ; 000040662143625.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F24C7550F25D81DA >									
//	    < PI_YU_ROMA ; Line_4103 ; 4xH2M7oc98l9Ykjwi5463D31XMXG01E6EX6gxZ05aVi39saAX ; 20171122 ; subDT >									
//	        < Vi60r1q4kLCZB3rc92Z36U4y7DDIMW14r1D1Ns7Ho9p13QZr8m44aB2524WWhuhq >									
//	        < 35JZl69kKS1c5A20NM5xz8lGype1lU0Cium28Ql81dmk2ca7I1eeHb351o635uMG >									
//	        < u =="0.000000000000000001" ; [ 000040662143625.000000000000000000 ; 000040667469183.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F25D81DAF265A226 >									
//	    < PI_YU_ROMA ; Line_4104 ; IlQg8MmL7MTxi0cogv0qX9iqCmbQ0s5QT89p659vs46NcT3VO ; 20171122 ; subDT >									
//	        < pcUY1swX1hj27pVtt8oe6t5jNLyNBV7dWeCheECjO7nldg1c35468BTbYg4E2b0o >									
//	        < eG75R80r3xESsK6l0R8zwZF8Waxz3lpNs2D3xg8L6BqRT841Lk2y6OGYxYoTsSVe >									
//	        < u =="0.000000000000000001" ; [ 000040667469183.000000000000000000 ; 000040680287430.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F265A226F2793147 >									
//	    < PI_YU_ROMA ; Line_4105 ; Wn7j5k8mkk2wMBWUHSX92srX5o84Dl2JUT66kc3y6BM293y7H ; 20171122 ; subDT >									
//	        < 051hD7Q62XE1w4WqaD7fPqVhj35M7jNj6u0vRtIm9U0m1wIy2vjOy94w64Q8c7sK >									
//	        < ChibVBZLIQL7Cn4C8E83y38D2KUPv80bIe592L1OKpiR708dDV17SU0F0O8iMd2E >									
//	        < u =="0.000000000000000001" ; [ 000040680287430.000000000000000000 ; 000040691010945.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F2793147F2898E26 >									
//	    < PI_YU_ROMA ; Line_4106 ; o5HA705lPCtVg8nK4FpMm9oJ3PF4DTEpHAHPDN1Xtak45mw1B ; 20171122 ; subDT >									
//	        < tB7OcP15wMqBkUziJq2raN0kK0u8f84L2Icc4r6OH4Z63HEFSdpsNSpAhosxGc3O >									
//	        < cO1Vg4k9IDKIJ1B5kJ09kUmnn3jGWk944IC8Pwsxuxusa3q4Y6T9kkuQb6U280fS >									
//	        < u =="0.000000000000000001" ; [ 000040691010945.000000000000000000 ; 000040705280404.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F2898E26F29F5428 >									
//	    < PI_YU_ROMA ; Line_4107 ; 9929KND12a41vv5zQ5t5jT5rslT20Ur1p49aln5je3B2m4EEA ; 20171122 ; subDT >									
//	        < lHnx4214w8xMl13hu8z6yq1QvN6L324qW5Ad8Pbn0i2p7E02Qn0tdar72GJ2r3KI >									
//	        < 5rAk8J0hu34NaJ54a8K7oWII2U2AiM50yy8e9a51dYx7q9j5QOSdtPc3U547w6jY >									
//	        < u =="0.000000000000000001" ; [ 000040705280404.000000000000000000 ; 000040715325716.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F29F5428F2AEA81B >									
//	    < PI_YU_ROMA ; Line_4108 ; 46CHTqPX64RfW2Svzbw329pW0u1MPHrcx8U0Mz8L3I6oDiZQH ; 20171122 ; subDT >									
//	        < I8noZ5k2FT013pG19F0Z7KZ7stvtYvT616w89h6g9OO3Dh0e4xdvC80s9TE3o29F >									
//	        < YJi69eij92bk3Wu9p9RO1H4OhlVZ7eV2lik1HoKg8K1M5DQ4o3D6737235aQL7V6 >									
//	        < u =="0.000000000000000001" ; [ 000040715325716.000000000000000000 ; 000040721309219.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F2AEA81BF2B7C969 >									
//	    < PI_YU_ROMA ; Line_4109 ; 1wO5202EyzZ6MUudbq9NNPcYY6r3mcPH9mvIgUxOymMA2SO66 ; 20171122 ; subDT >									
//	        < 39OVHKyLch70bXgQn80Oo9F65WXNGUbi5yyroHSqm32aIu6fpqQRWqcf3Zhqz1Yb >									
//	        < gW2q40HV40kd5Y6wt9k6EAoVFJQd1mor3SiR77w67Vo44CW4yycp7UGP7uP8x6Ma >									
//	        < u =="0.000000000000000001" ; [ 000040721309219.000000000000000000 ; 000040731985118.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F2B7C969F2C813AF >									
//	    < PI_YU_ROMA ; Line_4110 ; pBMBg8W0F6i8U4wYP97peTim1LW0sJWp5b400700dM3y088ER ; 20171122 ; subDT >									
//	        < tZuQCCLLE43V8G0D21N6Ecj7E6Rc2VOsbfzw2dudr4H8Qwiq84n591nRywDW0866 >									
//	        < zM83b1ALU50gJFJ01j6f3iJ8c0elucB0Au14gTrel2118wI41U4l5vgemr6U3IuJ >									
//	        < u =="0.000000000000000001" ; [ 000040731985118.000000000000000000 ; 000040745593302.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F2C813AFF2DCD762 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4111 à 4120									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4111 ; CZNn00W3IdrY3SNtteAL9xJmEho5e45P5ozSxxqB6bQDE9n01 ; 20171122 ; subDT >									
//	        < f7GGjzibf7ZfGcCv2OPz5c1N3V3JE3FsAySqYp676t1pJOHldnYcuuPbW9fNhm1g >									
//	        < VqFVbSgs13e4d68YOKIwc0n7Q87T5Zkbfm24TOmo907KoQo782OcaNZJ265Ty5kO >									
//	        < u =="0.000000000000000001" ; [ 000040745593302.000000000000000000 ; 000040755530946.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F2DCD762F2EC0146 >									
//	    < PI_YU_ROMA ; Line_4112 ; 5ZvFhGECJ01uFzQL98v4qF79b80ZBECKO9k039yZ18O6v5aGR ; 20171122 ; subDT >									
//	        < 2clwz66qut035EaXsaz3ALQ98GWgaI36FrJ3LMdQ3VEbHzXm2Wzk6P2Wc0NCcCv1 >									
//	        < alQQ2SY2qJ0u43g2kp2gbv85e5508F7xRX1zYP25ue31r4uo4A9f24rAr28J94R5 >									
//	        < u =="0.000000000000000001" ; [ 000040755530946.000000000000000000 ; 000040765470970.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F2EC0146F2FB2C19 >									
//	    < PI_YU_ROMA ; Line_4113 ; 848k90NFraWdL7lPklsSXN92i05V0C1ikoco0J3gNvok60Y33 ; 20171122 ; subDT >									
//	        < ygk6j9lsvixz9p02Byyx90pFw490KIC8D6D2qHTT1Vnro7I3pLQ48PZ0u53a8031 >									
//	        < 1A9GylIHkS9XUpFerk3C0AWaLu5J9nCn4Bdm4pJ831m5Q8JZZb7axaoOxSFUmY1a >									
//	        < u =="0.000000000000000001" ; [ 000040765470970.000000000000000000 ; 000040773239310.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F2FB2C19F307069B >									
//	    < PI_YU_ROMA ; Line_4114 ; XC40BzI0DVtX6VSzBEY2S4W8V8m93OQUuLMiSrsDYM5x29D2O ; 20171122 ; subDT >									
//	        < N52jkrsi6eUsl0v3rMhEGdU1jW91Js0TfB5f32zMAPtFmvHl63kr9RKlkH7453cA >									
//	        < w33kQk1ASbBMRbJEhR8Pfj661l6umGtId0Ehy1L5x25qy0FBP0w10odv44EfLycZ >									
//	        < u =="0.000000000000000001" ; [ 000040773239310.000000000000000000 ; 000040787358418.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F307069BF31C91E1 >									
//	    < PI_YU_ROMA ; Line_4115 ; HkYT5a0e7D686hkE767mT5KB0H5kXohy5vVJ43T49OFl6ct8j ; 20171122 ; subDT >									
//	        < Kuq0554kih65Dw38vBsWn9Yj1Ut71CyQtB4Sc7kNd45aznieirDa1r006j53g8HI >									
//	        < 3lN1Fpd21S4v1bjq18Y7iMuL24IvDdC150Xl98MXY0x2izT40x48jn2L2Ow7new8 >									
//	        < u =="0.000000000000000001" ; [ 000040787358418.000000000000000000 ; 000040801481187.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F31C91E1F3321E96 >									
//	    < PI_YU_ROMA ; Line_4116 ; ujJ6C87O1gT6P0jLxjqh17WHn60Md2PdD2egBxo1Om6884AB6 ; 20171122 ; subDT >									
//	        < wasyFi332YTntnpo5I9x0uk6de0Ud05Vjqg08252qHv22lFAJnoXqf01E9Bi028H >									
//	        < PObgx86L92r6Hm1dcSJ8whHOJx17zm98t36M89fxehO37KQKhsF8MY9T7H7ULi07 >									
//	        < u =="0.000000000000000001" ; [ 000040801481187.000000000000000000 ; 000040812943353.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F3321E96F3439BFF >									
//	    < PI_YU_ROMA ; Line_4117 ; 5xaP45468l4ZRah3l51cw6jmbRsM3WS3tuB7K724KO65FEPO0 ; 20171122 ; subDT >									
//	        < nt6C31d2X59muK8PrfZoe9r2MFGh2gx8y0jG2l25C4KPZH7tou2247N4i723GC6N >									
//	        < e16WC1vM0UBn0hD63Vp7h0gIafO9Er4u455Ymcy9463qzry7X1ZG89jy55VfT1ed >									
//	        < u =="0.000000000000000001" ; [ 000040812943353.000000000000000000 ; 000040818554479.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F3439BFFF34C2BD7 >									
//	    < PI_YU_ROMA ; Line_4118 ; cd23XfUa97hiyOK3W9VfXOzniCqIqHbNub0k6FdLwdl1fF4VI ; 20171122 ; subDT >									
//	        < q92v8qNvJH9Uw0l392mogRiI1j7D4p6Rt4LGzNWo26jckm9pcWJU178U4khUa8E7 >									
//	        < Bi2sl6IPe4z3U2w7zUJV6qo92p6jp36I3UobWR76u2A194pHAVz05b0oZ64I932i >									
//	        < u =="0.000000000000000001" ; [ 000040818554479.000000000000000000 ; 000040831502653.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F34C2BD7F35FEDB9 >									
//	    < PI_YU_ROMA ; Line_4119 ; 43QtE0F17vEiO3Wr7SnZW7g6SLDOow1B220oZ9gnGt4H1Uaed ; 20171122 ; subDT >									
//	        < n1DC8hg2R7OnCfLDLLUr5uP4LD6nVWttO2f1ik23v3b9hC45scU15I4Gc024h439 >									
//	        < Xk219g1mqRsbV6Rd29q371PtM1MYS0ALP4BxG1xVvb238cPk3J58LoEU83CUQ3IR >									
//	        < u =="0.000000000000000001" ; [ 000040831502653.000000000000000000 ; 000040841236029.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F35FEDB9F36EC7D2 >									
//	    < PI_YU_ROMA ; Line_4120 ; E1W6w2zufa2HyMH1RCkYaL4rk8Scxi4hGwzXb3H372QUeqZ1V ; 20171122 ; subDT >									
//	        < 6CcIsrMNv6W0GE9bpvN311nsre3R1L2lkoV5yy9915563F4qZhpa627BMqE0f43r >									
//	        < 08uDcgX8Ly3zVCzw28k8b81YwRZ7w9IG9b0j54X2pq9rcpd3ZL59U8S243ys1sU6 >									
//	        < u =="0.000000000000000001" ; [ 000040841236029.000000000000000000 ; 000040848673985.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F36EC7D2F37A2146 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4121 à 4130									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4121 ; d5f8Mm1l7I5kiPlu7rU6jMQkG1W5jsNL27u5fOVL7Zkbwo5Rd ; 20171122 ; subDT >									
//	        < H26O9DcYfmxRL086z6whV51LKPzrI64M4zNjEOqpMMtMJ3dM087l0u3z2e01V7DE >									
//	        < Q3mL7I4putwmxEbqz1CdXOk9688DdYwY5Uq6qDk9912E6HEJk7lQ97zHtva4Lenq >									
//	        < u =="0.000000000000000001" ; [ 000040848673985.000000000000000000 ; 000040861189649.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F37A2146F38D3A34 >									
//	    < PI_YU_ROMA ; Line_4122 ; w60GsXp4t859Y7CZIldo7gHKE75Cs25dSqPvRXYI0sCKEngSN ; 20171122 ; subDT >									
//	        < TVlly6l8mE837MBmJpLI80SjUGM3oKGpInq25875GycWHCcgomGR9Umix24w46eL >									
//	        < QrN0lx30OEb3badTv4MCz4I3GVMVwJc8Mp69TU3W0K45tQ5X95s6BtPt36Q3Xkcb >									
//	        < u =="0.000000000000000001" ; [ 000040861189649.000000000000000000 ; 000040868859942.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F38D3A34F398EE6A >									
//	    < PI_YU_ROMA ; Line_4123 ; 4nA7SVZjJTNQXdKCUgT8hrMikRuWBD0Q8694W95A9Cx78DTMx ; 20171122 ; subDT >									
//	        < ERE0I4HsaIn58Wj563UO67u2Df8L71rMJ4YWGqaqhrAFwXH89S7QFtO4Pt6x16Do >									
//	        < 6vjYC143zb5LrPpI2172Mg6p3pe7jOic4nm1Q796qMrPeP6A12w82K55ww8yrASf >									
//	        < u =="0.000000000000000001" ; [ 000040868859942.000000000000000000 ; 000040879440338.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F398EE6AF3A91361 >									
//	    < PI_YU_ROMA ; Line_4124 ; g2Nm4395NBHF1c13BBL17Q91h2y53k51cBlu3Xc877a3JuZ5P ; 20171122 ; subDT >									
//	        < CL68c8CMTPQ00ZD9KzNe3CEgQZu4pyR1fH9irtBbW27nMh329K47XBah8S7d0V6m >									
//	        < 7GO3V6hqGvJiQfM60hlF75Vttd1H47HJTywZd1bP2aTvUFd3639qlYzc4ccbK2sG >									
//	        < u =="0.000000000000000001" ; [ 000040879440338.000000000000000000 ; 000040886703649.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F3A91361F3B4289C >									
//	    < PI_YU_ROMA ; Line_4125 ; 21tg8XvdC1547gokiImC2D21GWfi7DjsWAer3qGpDRLNEEBIL ; 20171122 ; subDT >									
//	        < 7NGGDVsdi73O35eUCeRD3E9GilfooEHLXse6Si9eX05d5G9zvQUwB0VFx44Vg7iF >									
//	        < Fo4ODHfALHeMyLv16M9TSsUB40Gmj47as44577lQ96p2FY8088cVc780inPu14i3 >									
//	        < u =="0.000000000000000001" ; [ 000040886703649.000000000000000000 ; 000040892869745.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F3B4289CF3BD913E >									
//	    < PI_YU_ROMA ; Line_4126 ; PrCONZdmBG87751dLF5l69kcR2H5R6ZH526gLK75H5vS9i6RD ; 20171122 ; subDT >									
//	        < 9hiheDmgur4I4ME29aPO1183H5JbZeu27nzhuStG82jG88oyh2W251WzluWW0Fwa >									
//	        < TXCj0i625vtC02hWgE5xfr9QqBZpZn89npHUQr35595TfUI2m87cjw32uTgHIXqB >									
//	        < u =="0.000000000000000001" ; [ 000040892869745.000000000000000000 ; 000040899862245.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F3BD913EF3C83CB0 >									
//	    < PI_YU_ROMA ; Line_4127 ; 4c1G2Qepcwv5L96DNQ0m2sc41d2Q1FVxk04C3Y6gYMZj2TIxA ; 20171122 ; subDT >									
//	        < 4r4pz2f6b32VnEo64oqvR50098miF2Pe732pk1C8CoBPUgrgyK22CzkPBWSYz7Sp >									
//	        < WHk4BZ180Jn9Tz8q2eD94pWS41y0YOmoHG381yYzE02ZCs55GjExQwozA0OagD8B >									
//	        < u =="0.000000000000000001" ; [ 000040899862245.000000000000000000 ; 000040905691681.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F3C83CB0F3D121D0 >									
//	    < PI_YU_ROMA ; Line_4128 ; k2el6j6HFZFZyKYXcGUds95zDSd85P2m3C4maMnS0G26vQ0Gc ; 20171122 ; subDT >									
//	        < QHd05NAay4Wn2u7t4jP1E1AR89V49zN31XVdJ139RB18j8E8BqGH0vntin9d1Gn3 >									
//	        < Ua8u3Unj6IM4ghXC47dmz1yNmq3LYfY763U0b6qQF8LV8yvSFR9I68JwrYB2pvER >									
//	        < u =="0.000000000000000001" ; [ 000040905691681.000000000000000000 ; 000040918819764.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F3D121D0F3E529F8 >									
//	    < PI_YU_ROMA ; Line_4129 ; HiGHGE2OrK0pt2maF442mytquyQhpcH808RyG4bd88reOx6j6 ; 20171122 ; subDT >									
//	        < 5zK699I65D30HSAp29NrxTm7946L7iL4Hh4M3Zz0cN7TcVIyId6uuL0vIdK45otQ >									
//	        < XIZ0K39i1t81J63DgsG04bC0a1Dw92mxVt7haD9P6EX5zSa49Bv5859705e9ugoe >									
//	        < u =="0.000000000000000001" ; [ 000040918819764.000000000000000000 ; 000040929573687.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F3E529F8F3F592B8 >									
//	    < PI_YU_ROMA ; Line_4130 ; e6ZfK3Pu1tzzN7OwXp44Z88Bbk70IAlk7nk4LzjX4y192XCS5 ; 20171122 ; subDT >									
//	        < v32mXIRdMFYeq2cNXDb1bGCBOj19gMBH53P5lqY6FZyZ77a5MxazY7Y0U0mqZ7Zq >									
//	        < gPX0nVrNa955355U2T1o28u7GjK1f9Nb4u4Dlm6savTn1FrbGk69dIgryxxujF30 >									
//	        < u =="0.000000000000000001" ; [ 000040929573687.000000000000000000 ; 000040941431682.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F3F592B8F407AAC0 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4131 à 4140									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4131 ; tu6Y0kkaFz8Q30gU0kkDwBkP0jVoNQbmkP9IpiX5TB13r1m94 ; 20171122 ; subDT >									
//	        < 1bqM3KeLESW3Yx0H0qT94Y4y0UcPdhqR0rm4MYutkmXaP9m5U832qd3w9AgCEwNt >									
//	        < rXMqkCp11tWm1E7CV2K2fb5zj7Ty6AwwO35L154BULTwIkQ8641NPf3J185Uvs6f >									
//	        < u =="0.000000000000000001" ; [ 000040941431682.000000000000000000 ; 000040947204499.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F407AAC0F41079C1 >									
//	    < PI_YU_ROMA ; Line_4132 ; 8I66DhedaxOSFNzXVvv5j14bJr242v6A7Qd74mNN55K4598la ; 20171122 ; subDT >									
//	        < nQ7jl0hXWz1t8H1k4Dj66D1pVEL52As8m8e9K3fkXcyPkHHz56aON5w4pM518MwE >									
//	        < duexMgcNt1ii8za45e2fn90VFafF8F9EqPp6h0T3D8fMDhFge4MCkoAq1hAQhw4X >									
//	        < u =="0.000000000000000001" ; [ 000040947204499.000000000000000000 ; 000040958992841.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F41079C1F4227694 >									
//	    < PI_YU_ROMA ; Line_4133 ; Cdqb085O717vEWvCWM6xPBAVlZW05J0RLdK61G101FmMZ7v8F ; 20171122 ; subDT >									
//	        < q8h9rB989oXsuy8Q29HORUD0Ig19XhrqVT6959f5a7pnx9BZR95qfeBFCpWw5VBI >									
//	        < RMn67qG0d45opm4rc8093K8T4U39NgV4U72q72ddLde0qkSwT8XJ4WaO787tIG9g >									
//	        < u =="0.000000000000000001" ; [ 000040958992841.000000000000000000 ; 000040965026790.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F4227694F42BAB97 >									
//	    < PI_YU_ROMA ; Line_4134 ; H52xMVfCwQ11kX889svdD1ZS236PtA1eE57Pqov4X463t9n4H ; 20171122 ; subDT >									
//	        < Tar71Q6LRTC2933jf75UZthq3982CnD5MkD7ytdK6CGPk9GCBZh6iG39v84K78DL >									
//	        < Ozz66KPC51DCt7zyv14CTW4craXV0z206u9w8dBMlWEBpgrHFW8gMiitL3947YcX >									
//	        < u =="0.000000000000000001" ; [ 000040965026790.000000000000000000 ; 000040971178135.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F42BAB97F4350E75 >									
//	    < PI_YU_ROMA ; Line_4135 ; veNP5dlKE8wf9As9a6xLkmuM97115002OOZI362Q899BnrXH3 ; 20171122 ; subDT >									
//	        < qD0KSX7347kTF3MEhP5F30siDx7l7LilG43BRb07tUQgAtr64c8E5fg4MEd65fHQ >									
//	        < uUW3E3Ta78x1BD9hZ3vjx8872g1959368NIqY03fnGf8cz79i97vxQpDwk35HsKv >									
//	        < u =="0.000000000000000001" ; [ 000040971178135.000000000000000000 ; 000040980913884.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F4350E75F443E97C >									
//	    < PI_YU_ROMA ; Line_4136 ; KnGx69ZTT3iH0QM2nr98nBLiSzQ0g688P1wiJ0UWkuNA1E1zg ; 20171122 ; subDT >									
//	        < MXC9vOib1H25FO1YAqMb71712dfwkNXiqAu790KmRNM6l1GIRt0nn33WTSPU6N1D >									
//	        < 89IHp2hQX26n81hLd1d2Jr4ZvTQ5d64otp4USnTvjYTiJ8zM58gr6jtb588Z6Heh >									
//	        < u =="0.000000000000000001" ; [ 000040980913884.000000000000000000 ; 000040986437473.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F443E97CF44C5723 >									
//	    < PI_YU_ROMA ; Line_4137 ; Or3J22R7UlzVY5u8HMK056yTwa3AN5Sd07867oOEA38DflVB3 ; 20171122 ; subDT >									
//	        < 36627y0991r84fA0TF092G5qp5gODey1Bq56w06pR4grNDGDpKPM50bn87t92RCl >									
//	        < A3L77i1zyjs1aWWx5ppJ3gg7iL9vLac8n1r0xX785KZ482uKr8xVRgM64l5n0w5W >									
//	        < u =="0.000000000000000001" ; [ 000040986437473.000000000000000000 ; 000040996758833.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F44C5723F45C16EB >									
//	    < PI_YU_ROMA ; Line_4138 ; A029QahWH5udBINtnZC86COf4wVV35YBokglamcPY6IO7J2S3 ; 20171122 ; subDT >									
//	        < ecGxZVsDc0466wl8SSke6IlvC8z4t6n35e7FncRLh4Fb07JI4b9iGL7goQK5J9x9 >									
//	        < itBd9o513lt3UqDX2oeya4SC3yjC2DUbtJrQ8kwE0msYBr4341a2kG2kIMb1SaAL >									
//	        < u =="0.000000000000000001" ; [ 000040996758833.000000000000000000 ; 000041002759352.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F45C16EBF4653EDF >									
//	    < PI_YU_ROMA ; Line_4139 ; Lpd16Pb928yY86F8KQbW8939w84A5rSf401k1a3F47hvdaZr4 ; 20171122 ; subDT >									
//	        < 5467046h8fFXUjG51P9pJ7370a6nilfC7r9h6iz683h0YenJ52l0DF5fUBgjF8Dx >									
//	        < 7GCnyYj84TM2Owl4PbK751R4rf5U4l4Ry3jY7I1J79zmqgrca5VJnmLzFM0k26o6 >									
//	        < u =="0.000000000000000001" ; [ 000041002759352.000000000000000000 ; 000041009712681.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F4653EDFF46FDB04 >									
//	    < PI_YU_ROMA ; Line_4140 ; JLI7QwYP735wh005Ds7TOdITW95xa3QUGOO8k2ROp2XSK4guk ; 20171122 ; subDT >									
//	        < qgpPClBjbiGusuo1Q6vvfNYqTc64J4h5CN6D4jFkRVyt188pT94qXIN1iJaBA738 >									
//	        < uHsUt988AVgwtQul1MUvn7pmy429LbpJX3lccdh0W9jII9Zuw4YOE9slquZfG55v >									
//	        < u =="0.000000000000000001" ; [ 000041009712681.000000000000000000 ; 000041017798338.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F46FDB04F47C3179 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4141 à 4150									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4141 ; 995o7x1G41310cSKHPq9X5LK8Yl4two4BmWa808z3zzF6Ybg7 ; 20171122 ; subDT >									
//	        < pVY419scA65Q848EF520t3N78bnNS2mKZ4Eg1hAzpQ0SPp2qeXkh2ZQFm5qVWtsr >									
//	        < k6y68qiE7XPjh2QcoM3I9ATlpOfo928ouCN2eLZur206f4511t8M71MRR5HJ9xrK >									
//	        < u =="0.000000000000000001" ; [ 000041017798338.000000000000000000 ; 000041026854867.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F47C3179F48A032E >									
//	    < PI_YU_ROMA ; Line_4142 ; 32f9X99UD758veWSmW47gRQ04Y4WX9WknZ41zu1Aj5W73BMUR ; 20171122 ; subDT >									
//	        < 19C7yTdw4RkgSYWUdIga4SqmJwkVpakoFqtLD8Z6fwoU6C74pTp8cKBpj4mDi9kn >									
//	        < R80A9L97nE77sah7jot2tN0ZBOd7RJ5KNzum6xJW8J3Sv0tIEsNOGNXGnF5P1CjN >									
//	        < u =="0.000000000000000001" ; [ 000041026854867.000000000000000000 ; 000041037257479.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F48A032EF499E2B3 >									
//	    < PI_YU_ROMA ; Line_4143 ; zzs71xX1H9Zx5ke1iZy0YzWVk27qp0P6a8uTPxj87dr3I3M48 ; 20171122 ; subDT >									
//	        < 51HtAdHb88N808118w4kIAtosv561Gl30W5GJd2F9qG4370ZTg0gL45jhL750RFm >									
//	        < Y08BPT5Pw706WE6Lzp1QNvU0d2187H9c6w5T1bA15381HtVQ55m99uB80edN02Z3 >									
//	        < u =="0.000000000000000001" ; [ 000041037257479.000000000000000000 ; 000041042324969.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F499E2B3F4A19E30 >									
//	    < PI_YU_ROMA ; Line_4144 ; f3vK0I4ZGwJ4KHekgLuh56Bi4RjE1B2JNoY8k13iFmjixlO0p ; 20171122 ; subDT >									
//	        < 8X3znCeCPK9f74ZIruhsMDGrYfzJZqbjlAUC9MILWIWag21zY591QkG6k6lc103h >									
//	        < 8jAIlX4A8FXWurWKuwQvW15zi0bzg0u8BBljHS0rTpbjUY4INyS20L8YEjrvn86p >									
//	        < u =="0.000000000000000001" ; [ 000041042324969.000000000000000000 ; 000041049995971.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F4A19E30F4AD52AD >									
//	    < PI_YU_ROMA ; Line_4145 ; F5FP3WVmoL2WeKHv49xscLdKE8M5BCMIDgQb6XcdZ4d37MqAb ; 20171122 ; subDT >									
//	        < 1UCVo1V0li6b3K4b2dMY3bhpe1y5LVl1892Y154d0SjD1jy2btiw9F92AzUuBYTC >									
//	        < 57393iXnwb37xECSu24de73LB4ry3m6YF5ko3z83ec7vwv6ePZJc1Hj0LQ5406bT >									
//	        < u =="0.000000000000000001" ; [ 000041049995971.000000000000000000 ; 000041056370029.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F4AD52ADF4B70C8A >									
//	    < PI_YU_ROMA ; Line_4146 ; a4qSOFz9jJ0L5Pg8Y6nC66LQDNPNZEzapSV739oC7tmPNBNBr ; 20171122 ; subDT >									
//	        < qCUE3iUF3N6L0A454Ws71gqmyUvhxxztClf795fTuIqbTz2eNlNPc70524wEfOJF >									
//	        < 4p3Z9VZVnVH3Eo0J0N2zKTM5Tzh8hi9G1O3QG5Crc0Y1Bt50Eoy18rVfi561mCu2 >									
//	        < u =="0.000000000000000001" ; [ 000041056370029.000000000000000000 ; 000041067731515.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F4B70C8AF4C8629F >									
//	    < PI_YU_ROMA ; Line_4147 ; VxD0azI11O0N1E9f2RO3EeDb1vtLeWB9dehSh86eCe28CC081 ; 20171122 ; subDT >									
//	        < iojAHjjpDQi6OihDZMgc13bS8W5T6i955YR4QGs6u2f4TTsTp9Afjg805TiBbBrL >									
//	        < RFc6dUIo2aS59nL9R55SBuIQTaU2gxfEd0KbDeXLP2jLmFtiz2VCoR41jR4HkuV6 >									
//	        < u =="0.000000000000000001" ; [ 000041067731515.000000000000000000 ; 000041074571391.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F4C8629FF4D2D273 >									
//	    < PI_YU_ROMA ; Line_4148 ; 0B4SurRS6Fg6IYyU4ypYQs2bH2YD58kc7McJlLRZS0yqGWp42 ; 20171122 ; subDT >									
//	        < A6p7NK6H3b3F3mDW9thW2JvzT941Y3pBXGspdhNyt332nzITYTz3Zk03258cl0IZ >									
//	        < dY2zNxpH4png4wnNX4d8fKU0rx1Pm2YnPgNXNOW157fZbSiGLw7I2DBGtCWI8Ba5 >									
//	        < u =="0.000000000000000001" ; [ 000041074571391.000000000000000000 ; 000041081639797.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F4D2D273F4DD9B8B >									
//	    < PI_YU_ROMA ; Line_4149 ; T74r51X2K3MMG8u9CbtezLhR6e27nt3VZncI1982c71l86VOR ; 20171122 ; subDT >									
//	        < Qvq5fOsHwYpdSH09v2c9dXK13OIu14np7V9VoS01bpSu2BXRN795788njctsa6ZV >									
//	        < 3tzUFn5dyUMq97G79GW2SKB0GZK886F580A83co0k5j9S1WUpAmMlt97HVv12nuW >									
//	        < u =="0.000000000000000001" ; [ 000041081639797.000000000000000000 ; 000041095498673.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F4DD9B8BF4F2C12B >									
//	    < PI_YU_ROMA ; Line_4150 ; 4o5qKD125MEZQ1Fv14X0Uiz78AdUM3oWLTO63b1JmSR5q18pK ; 20171122 ; subDT >									
//	        < 3pce1Z6H9HSXKJJw0gtH7T66fYA4XSPkktlwWwlW8Xd97Bgc93z1t6upedhFH5DB >									
//	        < VWggi25E2XTBdDOhm3ud30Po8cgD5uDj9v237gVsS1Td3I7QY5nDQJ852cBk5F3M >									
//	        < u =="0.000000000000000001" ; [ 000041095498673.000000000000000000 ; 000041105936527.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F4F2C12BF502AE74 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4151 à 4160									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4151 ; c6s14N7d98NK9a3vn9EaGwjm49EJuhjosC1w85MAdG0R5Pl1x ; 20171122 ; subDT >									
//	        < j988S08NkCA6L4HE26W51X7b3aFX85fZmmzFX3r3Gu0oOH40VnkG8uKC1WvvPGg9 >									
//	        < WVKf7uQzx9B4sF2EARwP3c61zk2RGpykh46UDOWEw28iAULlqb0Ed6GtmCE021ME >									
//	        < u =="0.000000000000000001" ; [ 000041105936527.000000000000000000 ; 000041118383905.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F502AE74F515ACB6 >									
//	    < PI_YU_ROMA ; Line_4152 ; 0a5XI63dmC0bW2KrKWI48rGDYo9V6Oh43l3p8x5dF0000e46p ; 20171122 ; subDT >									
//	        < 3jD5e1TfI753uVPW1n6z428oZcf75r2J0qWCJ160QlCmsDTY5hHSni6194ZVWSaS >									
//	        < GvTVRPn0dF79RpvLeGA12x1u8irsv55ZUMXuSQ4D62YNNBb2eu10IjS8c4cny3E0 >									
//	        < u =="0.000000000000000001" ; [ 000041118383905.000000000000000000 ; 000041123539539.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F515ACB6F51D8AA1 >									
//	    < PI_YU_ROMA ; Line_4153 ; kJ2L0DaG229b6EBflh7rBv862JFZsH1SFHj3znT9G6mh7qvEG ; 20171122 ; subDT >									
//	        < XyNl2BLzcG2ysaAKk46giX8qjGT0Ri4ulKK72Y95f3GR03I7XD4oY2m7a01tG74u >									
//	        < 7J1a93IE0SmJ1eHyh0gMRkPImd0zWQ50TMZk29tSEjjL4YvFbr264Mqb5Nzk6TZ2 >									
//	        < u =="0.000000000000000001" ; [ 000041123539539.000000000000000000 ; 000041132530776.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F51D8AA1F52B42D5 >									
//	    < PI_YU_ROMA ; Line_4154 ; t8mZ4A63t621kG7C41wN6N0FY2Xt3m6KlR1t20Um8hgYUS9jG ; 20171122 ; subDT >									
//	        < 5fLNQH1Tu35Ldzw9717iJ8sASan81ASJQhcveI6A04j8oiy0IR8bV6OCURg06Ryn >									
//	        < jtms8i8d0jfN3I49Ywje4Wwa81G8PX5b11iBk4br4pq24u09462tJ4px732TVmNx >									
//	        < u =="0.000000000000000001" ; [ 000041132530776.000000000000000000 ; 000041142210809.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F52B42D5F53A0818 >									
//	    < PI_YU_ROMA ; Line_4155 ; Ndz57fgrqfAiGoJ74IdP71LfP73yX1Y6DhEyL8KUNgBWlz986 ; 20171122 ; subDT >									
//	        < ocgu9pA88oX397TNo67t983IPnId59yqacg01b95k94450mLKDj1usVWUEqdd0eP >									
//	        < 8eEb00vS4CKtO5iD07LgMHJ90224C9N00XKxJW5s2yWZw9423B5d9E3W4a416jyt >									
//	        < u =="0.000000000000000001" ; [ 000041142210809.000000000000000000 ; 000041147806586.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F53A0818F54291F2 >									
//	    < PI_YU_ROMA ; Line_4156 ; L0eK475gc61JpxXqcO6988GL31uNfYxZCTX411a367HgfR919 ; 20171122 ; subDT >									
//	        < ZU5O80B5F5qg6EGY48CMAqPGgXP66i18q4Xhh5QcmcQ3q864Z6b0705j0003HlRx >									
//	        < ZnKFe24c6b0MqNf10X9W84BjW8kb2cARNRRPX855uFNPjU6qD1a8w56mPNzSr9bs >									
//	        < u =="0.000000000000000001" ; [ 000041147806586.000000000000000000 ; 000041158659101.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F54291F2F5532136 >									
//	    < PI_YU_ROMA ; Line_4157 ; 3OYhyQKjHqHKU7xq7SDS2CZtiT22NX9u89wSteU3Ql7tlx2ik ; 20171122 ; subDT >									
//	        < YTeIZQcY3blOJXDcOv31P96g51Y0Qsm5Kro5GcKX4du84bzS7pAd219Oadt83Ph8 >									
//	        < y88vV05Sq1ppkL8XZYgR9nc4Q8bK2ep8ZSOQ6i54t64me77CD1A9407I831VqqGj >									
//	        < u =="0.000000000000000001" ; [ 000041158659101.000000000000000000 ; 000041170549200.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F5532136F56545C8 >									
//	    < PI_YU_ROMA ; Line_4158 ; g7JJUp2bYuW3c26AxieTRDC8zxG1z7QF6IAXZT8LpTOy8S437 ; 20171122 ; subDT >									
//	        < zqONN7MwSAo21Q7h7225NRMDvaGDWsADumvrkeZjM1B7f42o7epqM5Nhj7CQy2r1 >									
//	        < 8ByPRdCr7expnCO2Hp2x2e1F9QUQ94m8l83kwWib7907Tx25ueh6B3LmHR0YIcrv >									
//	        < u =="0.000000000000000001" ; [ 000041170549200.000000000000000000 ; 000041178206318.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F56545C8F570F4D7 >									
//	    < PI_YU_ROMA ; Line_4159 ; vk72Ql3Ut6Qv97RiP1W308egv8a02nee3u39arbDnH1wFQJ68 ; 20171122 ; subDT >									
//	        < QCv3XU0RQnK8cwJeo71a56s0u20VIs39Rr2oSfhGExidL97WqlpQs29L3VPcKe4X >									
//	        < 9GK0Z41RZrwGT8TSrc270Fq6S6Q3JIC9Pu35I4ZqjvpXC1eZS1OXyA4Qt3C1p76V >									
//	        < u =="0.000000000000000001" ; [ 000041178206318.000000000000000000 ; 000041188447422.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F570F4D7F5809546 >									
//	    < PI_YU_ROMA ; Line_4160 ; y6arAqgUXVZ6z5IHNJC53sZTu81Uf034109ta79Tk8mr631l0 ; 20171122 ; subDT >									
//	        < s5r12IDkMClQp46zxI6ZMzI5AlrThyr58U6oH045EhtMj9GblE4s2yy7jE5FHF8v >									
//	        < 0796S6al6Swcq0opk0e0Y0BtY7RRy44OK45c2Br9g0lH8Ao5Oyq74S59Xh3drFr7 >									
//	        < u =="0.000000000000000001" ; [ 000041188447422.000000000000000000 ; 000041197073378.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F5809546F58DBEC9 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4161 à 4170									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4161 ; 5ZwJ94hyy1F1Dzh3143D41oKBXi3QsE615qUI45T2K09yw53a ; 20171122 ; subDT >									
//	        < k5dmy7R296Y6QhQMvUg89RUg3Db8plnVUxGnNgHRE46kqrdMbI7fUcrdZhTo6QpQ >									
//	        < 8Bb4z2GoL97Ni647POJQ89C67Xokv3s5zv6PwOaj761elcb9q8gmhzR7oLaA03L3 >									
//	        < u =="0.000000000000000001" ; [ 000041197073378.000000000000000000 ; 000041211343800.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F58DBEC9F5A3852C >									
//	    < PI_YU_ROMA ; Line_4162 ; 4H3cXdcYeJ1X1G5OftcE7GPy9g7j475j7iV78CVd2EZ1dOY07 ; 20171122 ; subDT >									
//	        < LrnF92G34Ew8vULtUy6F2a9MWz21Cmk8fk37mDU68or7oA0B9t142cWZxyM4Sqq6 >									
//	        < 1ro05eOeIt8es3bzd4R6LOPCx92E32IGfXCCCM33C2M0Uo8KXJ3G0chFakB4s4PJ >									
//	        < u =="0.000000000000000001" ; [ 000041211343800.000000000000000000 ; 000041221186403.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F5A3852CF5B289F0 >									
//	    < PI_YU_ROMA ; Line_4163 ; l374H7As866166kb49AJ9hGEL4gA0b44PYZC1S2a4t9mIYUGb ; 20171122 ; subDT >									
//	        < qwQtnESH09jYAVA3XWdLQERKL7qWU533DW31mQh96wVtR7UhdkF3W9ej61xNUOiu >									
//	        < I92XC1X41jHHbil44tAt7e1U4sAgbO3Zl4X9OKn59L4ssw052z571arnJWP7tZSt >									
//	        < u =="0.000000000000000001" ; [ 000041221186403.000000000000000000 ; 000041234215196.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F5B289F0F5C66B4F >									
//	    < PI_YU_ROMA ; Line_4164 ; Zy86bY0bLux9mS51kjnFVD1Pv86ia8tJnh331PtCceIBGRLY0 ; 20171122 ; subDT >									
//	        < vmvMGZE5QHz08Sxzy93X3WNqw1jD1yNj0gC175w4emznBND3PvU17cE25w8qi8n6 >									
//	        < LOI1E9vq0l9b4e357jW3o996F7v8s8DDreBsWAzJQ2degK76myD3QaD7Qo3K06Ia >									
//	        < u =="0.000000000000000001" ; [ 000041234215196.000000000000000000 ; 000041246212456.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F5C66B4FF5D8B9BD >									
//	    < PI_YU_ROMA ; Line_4165 ; jt79FqiInkfk7Bl2OylY26HE18p9417B3unzB6ynD3o51S9Yl ; 20171122 ; subDT >									
//	        < Q9k6v9E0Rf143EOh78Ov5zbX3T315O43lzXUyKGHE2gh4MM0l0hrkh26qf7cNsTy >									
//	        < j20JebP9YWX02TouUlvJpnL5QikY9moBDG7757pLlUuZ7r2Bz8492ly34Ha48fGc >									
//	        < u =="0.000000000000000001" ; [ 000041246212456.000000000000000000 ; 000041257352721.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F5D8B9BDF5E9B968 >									
//	    < PI_YU_ROMA ; Line_4166 ; k17OE5a1596Lo4636O19ruNS0NyF11pqS03fYI3Wf3e0232J2 ; 20171122 ; subDT >									
//	        < 8s2GQEcIr3nG6VFh01rf52SE314LG6CnYoUTwevAo7oTYv38Y2s77lI44LAtBV9t >									
//	        < sOuChK0B0ikuMU0sJO0MxTH2g86Ct13mbzD9t4N887DNR0ZNZKEkD3bvfyJgvDf1 >									
//	        < u =="0.000000000000000001" ; [ 000041257352721.000000000000000000 ; 000041269168097.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F5E9B968F5FBC0C9 >									
//	    < PI_YU_ROMA ; Line_4167 ; O8NUctKi14814FF6HslQXK79n05dQ9JV1OBsN47S8v1eCJo26 ; 20171122 ; subDT >									
//	        < 9W6gZSR5Pz2DcwwtGdIbnJ3H9rJWECfkJkME6eI6AX740Erw6B2UukJr6q7ntM48 >									
//	        < zgvgDrDVcx8C8pQp3e4YxhqDS2e8hw6H2a3w13Tqo8K1YT7Azum25pqSzWEZM6ea >									
//	        < u =="0.000000000000000001" ; [ 000041269168097.000000000000000000 ; 000041275624718.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F5FBC0C9F6059AE7 >									
//	    < PI_YU_ROMA ; Line_4168 ; RHMP2j7xA5Ksa50L21M3q9uoUNUOTILPlFRUbBjoGE52b8k7M ; 20171122 ; subDT >									
//	        < C4mmJFrSzt5C4z5DvvP7S7Psc6Fsz0HouHZ0DLx18s12Cf5kahkZIX6d6s67llwo >									
//	        < 2558rmz6a0X5IvjmJjN1y16qI31miK3MnbbD26IbQ9yeTXPp3dlI563t6CK0PXer >									
//	        < u =="0.000000000000000001" ; [ 000041275624718.000000000000000000 ; 000041282140823.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F6059AE7F60F8C42 >									
//	    < PI_YU_ROMA ; Line_4169 ; k1460UFTeV5Z86w1uGZAWX02SvcGlarHpo56D79x4wmrxHn8I ; 20171122 ; subDT >									
//	        < bsLbT5mMvy0AKh8f934to5k5938l11mIJZw66xM8upLCy5O8T3j9P0C8VfdsB3Kf >									
//	        < 1oRx8FIX2PNrZDbwaDTX4M2E8WXM1712p467qugQuNbajFdzQ7XqfijYjlVsG1Ay >									
//	        < u =="0.000000000000000001" ; [ 000041282140823.000000000000000000 ; 000041293347628.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F60F8C42F620A5EA >									
//	    < PI_YU_ROMA ; Line_4170 ; 7Hel8clFR9SSNo203X207tg29Xw1okWDgU6V1e37O4Aa1eLrb ; 20171122 ; subDT >									
//	        < 3S2N65SbyV622flSTuexnXlEOVV58yGfY2poJ6OzV49jB4v6PZr75LBe8uI2ah4U >									
//	        < 9TY6qYhA8HbyZ5H0un6AJN780lfX98x1gE61tGAT7nE4q2rV5D7zgsq7H3Nm0c6k >									
//	        < u =="0.000000000000000001" ; [ 000041293347628.000000000000000000 ; 000041308113958.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F620A5EAF6372E03 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4171 à 4180									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4171 ; 0s3wp4f064jiHi8MKPOiE4f6u3xg13yBE82S16988ti9qr5C3 ; 20171122 ; subDT >									
//	        < n7AKC9Yw5bIk07oJQ5JM776rdem3FA31mRAr8Hp9w9PsvXGoj1Vu959L6uAd5Z6g >									
//	        < o72t895h3WoVc13TAm1yaFh2kz3yR6oZqL5b2FG7P33N3W3rPeAa7v15OIrTG8Dm >									
//	        < u =="0.000000000000000001" ; [ 000041308113958.000000000000000000 ; 000041315393001.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F6372E03F6424964 >									
//	    < PI_YU_ROMA ; Line_4172 ; Xw2svSLPwA494jNWt0bgq275XE4LCttAQPHsAi97b3G2DRtl7 ; 20171122 ; subDT >									
//	        < 2I11HC2PQwJs4lE31wTXKU8Zxv01kcPc0Of99gcHx1eojYzH6n1u0xR0QH76ote3 >									
//	        < b53glhy2rHu95j3yyIqs49y18x3JT4iAqABx0tWqqP4W0yyfm1duNBI4YXeWCDYp >									
//	        < u =="0.000000000000000001" ; [ 000041315393001.000000000000000000 ; 000041320986686.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F6424964F64AD26C >									
//	    < PI_YU_ROMA ; Line_4173 ; CrbMVsk80JN07qk0bRh29a4QPq1Pxmtj3G37KlQq5EwqjCCC2 ; 20171122 ; subDT >									
//	        < T404wDB3epu8Vhsy9Pcl77CwUHXxY1sDzq4lJ648CGqK0pj5Cd60Vyre2QX6U0uy >									
//	        < 9JsX5YW78brz7f03iBL0P604OUIi9I9C5e3Td22CaGl9A2Hf9qk7x6Jj81inhtJ9 >									
//	        < u =="0.000000000000000001" ; [ 000041320986686.000000000000000000 ; 000041330766206.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F64AD26CF659BE8C >									
//	    < PI_YU_ROMA ; Line_4174 ; CR3PE0fV0pTw58MmNIciiLth52Y8Fvd6GxRjEn92cQ72zCcXs ; 20171122 ; subDT >									
//	        < 9tWBZ6K3BKP557kEVL6uXXipz66RiRmu5Y6vLp5G1N4Oqit53Wl1agna0EdsTjs3 >									
//	        < M8033235eGHxXnVESSBv92mwMxW5NfKn0A9YmhQW84RZ9E3Y1zYAR78cpbkAWHVd >									
//	        < u =="0.000000000000000001" ; [ 000041330766206.000000000000000000 ; 000041341412277.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F659BE8CF669FD2B >									
//	    < PI_YU_ROMA ; Line_4175 ; lT3pkYSIRuT4fSi7iMyyfB8VNPf1fE191FcLMQs8uRjvepluH ; 20171122 ; subDT >									
//	        < vSLaETIfwtuqsM6e5kMB32I4Ilx63sPQ60sl1kHhXGlQ0c8JZUqIk0deeg9OtB01 >									
//	        < TJ5aGefp0BJ1rlPk8jVYRiW40I42BoCCPHNj0RsNbo4wcFHke37zNpo33bsWpM70 >									
//	        < u =="0.000000000000000001" ; [ 000041341412277.000000000000000000 ; 000041354978551.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F669FD2BF67EB07F >									
//	    < PI_YU_ROMA ; Line_4176 ; ZLOgwi0OvUnU6DtvaAfH55XlVjiFHsTVFpz1932TDB6I4T4Nv ; 20171122 ; subDT >									
//	        < 37NyUvMtxcLjqdlLv5b981gOCb0hvc7D7KE0bw53QGMX27M5F972lB213L7M3D33 >									
//	        < 14KFLP7H7l3Z6tBOukT406PeM7rMVRm5LIgI5pIO5M26VgZ13xa1ph1e8FB3lqBU >									
//	        < u =="0.000000000000000001" ; [ 000041354978551.000000000000000000 ; 000041367641881.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F67EB07FF692031C >									
//	    < PI_YU_ROMA ; Line_4177 ; fHNTi9XywGCZA9Em8YMW2a08fG38XBsoFZuB0ABZV9ey39ZEi ; 20171122 ; subDT >									
//	        < 4I8C2054ecIw3Mt2WkcY1oXe881N6Po2FDTv52D9ggz9EuS174Q8HMMCrgwl60yd >									
//	        < u77tr3TC3TAMq19AKeIquNcmbu6CP8sfTwnyyL2Qu6VR10xt4R60kCcR6aJ3w9j1 >									
//	        < u =="0.000000000000000001" ; [ 000041367641881.000000000000000000 ; 000041382484257.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F692031CF6A8A8E9 >									
//	    < PI_YU_ROMA ; Line_4178 ; pOcGViowAHq3SD0256F98sKPEG5Uw7AuoHN1i1f2L1558NdIV ; 20171122 ; subDT >									
//	        < ueBK80jv0XAn8RPK4cHW8Bx7N3kyYYZBT8V9TA86g59pt14Ytll672w4ULvgcvo5 >									
//	        < 173KN0vw4423dZSQ8tQ43s4k36uY9ggf369H2xu029dTphP5OickWQwV2aWu24IY >									
//	        < u =="0.000000000000000001" ; [ 000041382484257.000000000000000000 ; 000041394399199.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F6A8A8E9F6BAD72F >									
//	    < PI_YU_ROMA ; Line_4179 ; zq6eU4SS64Qnr1PzutaGXNcne01Zr49988nx8P25iodEVJmpM ; 20171122 ; subDT >									
//	        < 1pwq38QQJ9iz170MJJJfcpf1L1gjK1K6Fw6s77M0jgqwCpgFq0t7oGDY241bn0H0 >									
//	        < gEjiJ1j80Z4dZni27oPCW0g58G65vHEQAAU7X7W9j3PZ2trXC5Th1vY65e4f5sM7 >									
//	        < u =="0.000000000000000001" ; [ 000041394399199.000000000000000000 ; 000041403071547.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F6BAD72FF6C812D2 >									
//	    < PI_YU_ROMA ; Line_4180 ; r2P7Y5C4u381vuZ6z2yb9Q6mdWW4dUpGMcTjzi4rTT4C9Bi98 ; 20171122 ; subDT >									
//	        < nX324766f5c7q575n90ODU54Wzllik4i87DYQk5Kcuzo1MLgU98k3b8rAII1hB59 >									
//	        < 3Ey09509i1O96J53sRXhTYCDT4yckgdWI1b9rl2120T3L7qF02CE54Wzt1g9W90F >									
//	        < u =="0.000000000000000001" ; [ 000041403071547.000000000000000000 ; 000041414306707.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F6C812D2F6D9378E >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
//	Programme d'émission - lignes 4181 à 4190									
										
										
										
										
//	    [ Nom du portefeuille ; Numéro de la ligne ; Nom de la ligne ; Echéance ; couche technologique ]									
//	        [ Adresse exportée #1 ]									
//	        [ Adresse exportée #2 ]									
//	        [ Unité Dec ; Limite basse ; Limite haute ]									
//	        [ Hex ]									
										
										
										
										
//	    < PI_YU_ROMA ; Line_4181 ; d4fKkzH19s4Wg4iB855Swp7v2TNbFS55E5v6pX9KQuDh57k32 ; 20171122 ; subDT >									
//	        < FHRo1cLTX18D1FskSg0QpUIeqC6tdupZX2JhRPDQPtx78jG3OpbbvekYB5FBm938 >									
//	        < R9Lq9ur222459Cn8DPtSZfiI9vaOUgy5GBSfi2H4397k0RRIlAmJyHgI6CUe8Bz5 >									
//	        < u =="0.000000000000000001" ; [ 000041414306707.000000000000000000 ; 000041427532555.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F6D9378EF6ED65E7 >									
//	    < PI_YU_ROMA ; Line_4182 ; QRIE0g5yP1j00Jfsq2vS029T6b4mdN61WIFb5y3IZOx10eSB8 ; 20171122 ; subDT >									
//	        < Z40AW247VBd8SnKF0r7I227DSHIQ92lWRyq309a4DTIS4bD77iu4E9XE4qqC0saB >									
//	        < 6T27Owur6uNWsuCc595UbiVF87l2F63um3h2V8Ol8l6c0iuat3e0p70F1K97t2TB >									
//	        < u =="0.000000000000000001" ; [ 000041427532555.000000000000000000 ; 000041440155449.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F6ED65E7F700A8B8 >									
//	    < PI_YU_ROMA ; Line_4183 ; Z8Sb7h8o5kHvSOUj5L8VX66860BNx5ozKJ96JRg59W9jhndxj ; 20171122 ; subDT >									
//	        < Y28528wIl12UH17Ntx7xKe0Y11M84z8J4mfCCqEt685HIvL688k1i8x39Sk9cXka >									
//	        < Q7MbHBId55Q67FiFFQAF0TxexKX7FR62IfwRCt97739RVd3o8yguNXW7tetTzdja >									
//	        < u =="0.000000000000000001" ; [ 000041440155449.000000000000000000 ; 000041449534775.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F700A8B8F70EF885 >									
//	    < PI_YU_ROMA ; Line_4184 ; vYsID0zxAkSkdZV5Gz9Q73HxB9vZGj7T3yq8cpFQ35LN9C2v6 ; 20171122 ; subDT >									
//	        < kv8746Q7Js3p6R1F0eSDbi5FJlpM0m60O4V6dPKNYe0AM3kfGzbI10Ibm3MY5S3n >									
//	        < YC9YL5p1wVEpqP40WX7789G45IEST3i1CnnmnBB5EmcRO4moceMlu2pDB3YO58z3 >									
//	        < u =="0.000000000000000001" ; [ 000041449534775.000000000000000000 ; 000041459186333.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F70EF885F71DB2A9 >									
//	    < PI_YU_ROMA ; Line_4185 ; Ql2uA55TPw784v5670U8sms0BD81bswHg4ru74tx31JC3nv1A ; 20171122 ; subDT >									
//	        < 6EsmT1u6G3uNfZQPoja729657Jz8MOr298HXI966t3HnGZ91jm4oTf86e22VAR8Z >									
//	        < zTK2e2S46z6Imwf5zW72I9UBXfytDdseJunaZ1R5JBs7QMCRXdASvr66pH6QMzEX >									
//	        < u =="0.000000000000000001" ; [ 000041459186333.000000000000000000 ; 000041473423471.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F71DB2A9F7336C0B >									
//	    < PI_YU_ROMA ; Line_4186 ; r00gZv7Y9O38qwVO9B02Pz1hIuN5hg7MA9F5KF0re26FEwPWU ; 20171122 ; subDT >									
//	        < 65Qfb7289C6dthMy21r7MP86HO1PxcaX9WgB2zEkNsJqz707zE5H157TCzA7tNOa >									
//	        < 3Bt10IWiK0DsLhR9r67Sw810Cz57R27nZgdklS7sVoXtj2ZFY6ImPMT1O265B23H >									
//	        < u =="0.000000000000000001" ; [ 000041473423471.000000000000000000 ; 000041487592339.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F7336C0BF7490AC1 >									
//	    < PI_YU_ROMA ; Line_4187 ; KFq8DLPUode3IwX9Pr94XxCy7d60cgJRR87fYG37Dz35hlZ3I ; 20171122 ; subDT >									
//	        < zovEEq186Utf11O8br5E3DMLNfR7Hgm01RS0LPp21Fz0hnfn6fO7M16988Ba3k7c >									
//	        < OF5h3b83Wee4TCmp5Sc8axOW2uNKIT80EC0eOB1cf1Hs3y9Dsn6C18SHFM5d69PP >									
//	        < u =="0.000000000000000001" ; [ 000041487592339.000000000000000000 ; 000041501918428.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F7490AC1F75EE6E2 >									
//	    < PI_YU_ROMA ; Line_4188 ; Zin8Vc5l29H63ZLGjn7XLr4Iz3rwJObN4PADeRD1UE5f4v48N ; 20171122 ; subDT >									
//	        < v7y0HQmr39f0598R6s6XAe1vkQ3zrkt4GZT9e0f2xVWN3aMUScpIKgig2O37VI75 >									
//	        < gqP0fcAEhPaKOneVr87lchKc7ut7konnt9YzCtmbpfMFv7tRON67IdlzAM3C4773 >									
//	        < u =="0.000000000000000001" ; [ 000041501918428.000000000000000000 ; 000041510717453.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F75EE6E2F76C5401 >									
//	    < PI_YU_ROMA ; Line_4189 ; B7Q8xo8jq4MH3A2lFo2ZfIOmx79WqJT3nl42g5kWfSWhx8HNd ; 20171122 ; subDT >									
//	        < dXfj7HO2O9hyx4FV1vsF7NsPzKsXY3Ur1F5rww943SR5jK6ypF8R75r0NGM8hAyA >									
//	        < 0X148L9nNz2J3hNB0I3783VkpAOyv54L5WhF3fpNd9p2MU827HEUOe4QuATksB7L >									
//	        < u =="0.000000000000000001" ; [ 000041510717453.000000000000000000 ; 000041516131063.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F76C5401F77496B2 >									
//	    < PI_YU_ROMA ; Line_4190 ; sgVpqoNKy8a6qGHBT37Tj6ya6hqLl8SA20P7hKPj4BTteG92U ; 20171122 ; subDT >									
//	        < 5K95iFv349z8qob7O2U1y5tMP0tBJ9Ug59nkc56nNbVka1wW43LCh3x8QSc6wS1w >									
//	        < Jxjg2aB7gGv6Nz1s980L3600x6jNV2RG5po09IofR184uyla85J71U2Qn612JQP8 >									
//	        < u =="0.000000000000000001" ; [ 000041516131063.000000000000000000 ; 000041522896360.000000000000000000 [ >									
//	        < 88_32 0x000000000000000000000000000000000000000000000000F77496B2F77EE964 >									
}