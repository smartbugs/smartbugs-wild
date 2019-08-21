pragma solidity 		^0.4.21	;						
										
	contract	NDD_BOO_I_883				{				
										
		mapping (address => uint256) public balanceOf;								
										
		string	public		name =	"	NDD_BOO_I_883		"	;
		string	public		symbol =	"	NDD_BOO_I_1subDT		"	;
		uint8	public		decimals =		18			;
										
		uint256 public totalSupply =		298914476075191000000000000000					;	
										
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
	//     < NDD_BOO_I_metadata_line_1_____6938413225 Lab_x >									
	//        < 7165suVP0fDw3f3zg6TCL9402xv3N1PxBKPvchvw2L36ac210RKudFHw9XnUsDdE >									
	//        <  u =="0.000000000000000001" : ] 000000000000000.000000000000000000 ; 000000010000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000000000F4240 >									
	//     < NDD_BOO_I_metadata_line_2_____9781285179 Lab_y >									
	//        < r60K7hav2w49J1Gt8N20dxr8ru5KHMaO56Il6RCS73BL2mVFpFz8m7idLgG35A1u >									
	//        <  u =="0.000000000000000001" : ] 000000010000000.000000000000000000 ; 000000020000000.000000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000000F42401E8480 >									
	//     < NDD_BOO_I_metadata_line_3_____2397506438 Lab_100 >									
	//        < u263H2EXSU5wlu7f2GbpAjt686S3099TWX4Yt2j17nb697a2WIX3WULgaB6ps3KM >									
	//        <  u =="0.000000000000000001" : ] 000000020000000.000000000000000000 ; 000000031181379.774530000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000001E84802F943A >									
	//     < NDD_BOO_I_metadata_line_4_____2376360414 Lab_110 >									
	//        < 8iBDnw81jje7307F2MT7xYu26gP5iRfhT4OvJ9t4r3x7S1z941xtaCC1LMbZJs6z >									
	//        <  u =="0.000000000000000001" : ] 000000031181379.774530000000000000 ; 000000043396466.851773800000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000002F943A4237BF >									
	//     < NDD_BOO_I_metadata_line_5_____2344028548 Lab_410/401 >									
	//        < CHDXv58gT7vkUrTqeu56UHsOFRcRN9O628Ywu9uE8qc8H1wSQe4VY7f254UYsrJN >									
	//        <  u =="0.000000000000000001" : ] 000000043396466.851773800000000000 ; 000000062256815.160749100000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000004237BF5EFF12 >									
	//     < NDD_BOO_I_metadata_line_6_____1191770016 Lab_810/801 >									
	//        < e5n17F67ojlVD9I6tSeZhEk44gC5V7SJdl91oAVEAS1B01DR7l8oWG6Gcb73K8Hy >									
	//        <  u =="0.000000000000000001" : ] 000000062256815.160749100000000000 ; 000000089977511.778699600000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000000005EFF12894B77 >									
	//     < NDD_BOO_I_metadata_line_7_____2316846204 Lab_410_3Y1Y >									
	//        < 79Cdyn6bHn40a0z4ThdZfVRzex4Wf7gwaJ8Gw2KwilD577R4AcEH5qUYWhl2oDfZ >									
	//        <  u =="0.000000000000000001" : ] 000000089977511.778699600000000000 ; 000000136022050.946205000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000000894B77CF8D9D >									
	//     < NDD_BOO_I_metadata_line_8_____2391389817 Lab_410_5Y1Y >									
	//        < gzIMXnzr0yYw5qyDFr9L2h625bePcV8D70OaUU96U9CUZsc2yOX7YEM668vd7Ck8 >									
	//        <  u =="0.000000000000000001" : ] 000000136022050.946205000000000000 ; 000000314566765.381826000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000000CF8D9D1DFFDA5 >									
	//     < NDD_BOO_I_metadata_line_9_____2394394658 Lab_410_7Y1Y >									
	//        < eqgn1LJIBwW13azg2Wlm6XIUK02ruXic2fI2EeGPFFQvyEoaDCL6py3Ev486eU9N >									
	//        <  u =="0.000000000000000001" : ] 000000314566765.381826000000000000 ; 000000816384652.838339000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000001DFFDA54DDB441 >									
	//     < NDD_BOO_I_metadata_line_10_____1135477234 Lab_810_3Y1Y >									
	//        < X0J78Cxv3cgoQiF0wm5nH8KZD1qaog07ufnBY219Wo4qB7az1rx0ym24YK4j93f1 >									
	//        <  u =="0.000000000000000001" : ] 000000816384652.838339000000000000 ; 000000919762772.780635000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000004DDB44157B7255 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_BOO_I_metadata_line_11_____1151278668 Lab_810_5Y1Y >									
	//        < I6Xp517RudIIBaYWcOBl1CuJ3bjjG6Od215Az43e720x57pN126f4RnlKM2HEdTK >									
	//        <  u =="0.000000000000000001" : ] 000000919762772.780635000000000000 ; 000002018032218.606540000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000057B7255C0745D6 >									
	//     < NDD_BOO_I_metadata_line_12_____1121572500 Lab_810_7Y1Y >									
	//        < uKU3a76rDM1aH9Jq55430gU9knyE5Cl9p6lGBaqQ75cl7Q8UyVUaeRmMP0u8xyql >									
	//        <  u =="0.000000000000000001" : ] 000002018032218.606540000000000000 ; 000009939409125.705720000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000000C0745D63B3E55B1 >									
	//     < NDD_BOO_I_metadata_line_13_____2367266745 ro_Lab_110_3Y_1.00 >									
	//        < no1W5847N7Ff0wtFxF8A69O6xOBnZ6Uz9wKEdO5ka5AW4U0uVs88uA3K7ZVIw82T >									
	//        <  u =="0.000000000000000001" : ] 000009939409125.705720000000000000 ; 000009962389568.099230000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003B3E55B13B61666D >									
	//     < NDD_BOO_I_metadata_line_14_____2372066847 ro_Lab_110_5Y_1.00 >									
	//        < b068jKDzk0Cppp033UB6K1b2iJ141R4iWLbTexO85SEhl0aJsFwOBvR2WcJs0w6G >									
	//        <  u =="0.000000000000000001" : ] 000009962389568.099230000000000000 ; 000009994227118.245200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003B61666D3B91FAF8 >									
	//     < NDD_BOO_I_metadata_line_15_____2372504970 ro_Lab_110_5Y_1.10 >									
	//        < uUBQ78R34618GfuajQ6BCj81muLo328qMre5t6Zhe6U2BHu1KNswAj4U3Am6zJ9n >									
	//        <  u =="0.000000000000000001" : ] 000009994227118.245200000000000000 ; 000010027029729.704200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003B91FAF83BC4087D >									
	//     < NDD_BOO_I_metadata_line_16_____2376119198 ro_Lab_110_7Y_1.00 >									
	//        < D7B8yi5aJC2grG7j8j158bL9WG3t8P45tNdO3ruWUEy61zesFM5v90z31nG32GT9 >									
	//        <  u =="0.000000000000000001" : ] 000010027029729.704200000000000000 ; 000010067297733.215400000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003BC4087D3C017A2D >									
	//     < NDD_BOO_I_metadata_line_17_____2307265106 ro_Lab_210_3Y_1.00 >									
	//        < by3DzwT59q36dV6xd4k1pox6fHPaR6c1k4bRttO8t88tWV0q4UFlo5Oe57DT1cYA >									
	//        <  u =="0.000000000000000001" : ] 000010067297733.215400000000000000 ; 000010079196269.949200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003C017A2D3C13A20B >									
	//     < NDD_BOO_I_metadata_line_18_____2396047722 ro_Lab_210_5Y_1.00 >									
	//        < Bg3oQyC8435RX710Td4U7934Rsrh8476hy67LA5gZP6ZrzMuw0R48uL6YNj8rE28 >									
	//        <  u =="0.000000000000000001" : ] 000010079196269.949200000000000000 ; 000010096884340.899600000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003C13A20B3C2E9F72 >									
	//     < NDD_BOO_I_metadata_line_19_____2305448291 ro_Lab_210_5Y_1.10 >									
	//        < F7Sp4pR9MJK36BSX7b8sch9oV307uU9gaVsdgiduv6RVAJXqveN57j8INWreGOM6 >									
	//        <  u =="0.000000000000000001" : ] 000010096884340.899600000000000000 ; 000010111499544.753000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003C2E9F723C44EC82 >									
	//     < NDD_BOO_I_metadata_line_20_____2335675418 ro_Lab_210_7Y_1.00 >									
	//        < it3NWr7lu9H1Mz0lUe2Wx6Fo3gvuB173thn8156MQ8FV1mkjnX3cLP7tKHh6zc9V >									
	//        <  u =="0.000000000000000001" : ] 000010111499544.753000000000000000 ; 000010142082655.522900000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003C44EC823C73970A >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_BOO_I_metadata_line_21_____2304705832 ro_Lab_310_3Y_1.00 >									
	//        < edE6OOzj8hEM9Gk8wKFi68qsWqUNwiEH4ghK47dS17fo2Jik7fb9619FwCS6960V >									
	//        <  u =="0.000000000000000001" : ] 000010142082655.522900000000000000 ; 000010154779641.356500000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003C73970A3C86F6CC >									
	//     < NDD_BOO_I_metadata_line_22_____2387495267 ro_Lab_310_5Y_1.00 >									
	//        < 28C5J3Mh4QZk6l9sFGS2Rq91MOmt3zv7rp30I7YKHl61tz5Z12TEzQSDcHn50aQ2 >									
	//        <  u =="0.000000000000000001" : ] 000010154779641.356500000000000000 ; 000010179482374.421800000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003C86F6CC3CACA84D >									
	//     < NDD_BOO_I_metadata_line_23_____2396638262 ro_Lab_310_5Y_1.10 >									
	//        < HR49nqQFTS96qg0PwWH8kaR0fKbY01slLVWPwyNZ6EhquXrLQL1cvwa5uHYQw8vX >									
	//        <  u =="0.000000000000000001" : ] 000010179482374.421800000000000000 ; 000010197418713.918100000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003CACA84D3CC806AF >									
	//     < NDD_BOO_I_metadata_line_24_____2370372300 ro_Lab_310_7Y_1.00 >									
	//        < jnrnKiU47In65xsGyu07CcsKYai4971U8Elr7W6w300t0to1Bn68iU1vLQP16T15 >									
	//        <  u =="0.000000000000000001" : ] 000010197418713.918100000000000000 ; 000010256833416.804700000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003CC806AF3D22AF8E >									
	//     < NDD_BOO_I_metadata_line_25_____2397081024 ro_Lab_410_3Y_1.00 >									
	//        < nxxdbOC7oU5aDN74g98y0H9ia7bB7dS1u4z8Gt8fok6DObF53h5mSYXU0kkIBXaA >									
	//        <  u =="0.000000000000000001" : ] 000010256833416.804700000000000000 ; 000010270524617.653000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003D22AF8E3D3793AE >									
	//     < NDD_BOO_I_metadata_line_26_____2369868322 ro_Lab_410_5Y_1.00 >									
	//        < 0bV6invSy0mwTwl3X7j3GrQO5J78vHu0GE7O36u9X4r9N9y0LQjMMJ0Nq0Hc2NZ5 >									
	//        <  u =="0.000000000000000001" : ] 000010270524617.653000000000000000 ; 000010306544763.361300000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003D3793AE3D6E8A0C >									
	//     < NDD_BOO_I_metadata_line_27_____2378592563 ro_Lab_410_5Y_1.10 >									
	//        < 07cNcC9F23t70Vtp6n9eG3jO0wGUpQ5Rhsn899dLvy151a98yQh4eIaxi3JL7534 >									
	//        <  u =="0.000000000000000001" : ] 000010306544763.361300000000000000 ; 000010329858204.463400000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003D6E8A0C3D921CDC >									
	//     < NDD_BOO_I_metadata_line_28_____2360975490 ro_Lab_410_7Y_1.00 >									
	//        < 0cY4MuyMw6N4z6UphAmeWA1RDsk93utDg3sFfBe0sO1z8otv73f8mTsfO4r2LtI0 >									
	//        <  u =="0.000000000000000001" : ] 000010329858204.463400000000000000 ; 000010446938935.235600000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003D921CDC3E44C386 >									
	//     < NDD_BOO_I_metadata_line_29_____2376878709 ro_Lab_810_3Y_1.00 >									
	//        < z6KftvCbqkKULI6jUhTFwgtbZ31GqNd0y4383111YHBz9h7rXvo4i513RM6992Ms >									
	//        <  u =="0.000000000000000001" : ] 000010446938935.235600000000000000 ; 000010465183239.030900000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003E44C3863E609A34 >									
	//     < NDD_BOO_I_metadata_line_30_____2393119773 ro_Lab_810_5Y_1.00 >									
	//        < R9Pzk0l1Nh2W3X3zKg0QgAT0TaGLY1q367tMB440OO969493eCloj2kmxzTY7p0S >									
	//        <  u =="0.000000000000000001" : ] 000010465183239.030900000000000000 ; 000010629366277.430200000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003E609A343F5B2034 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
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
	//     < NDD_BOO_I_metadata_line_31_____2353874946 ro_Lab_810_5Y_1.10 >									
	//        < F9Txvjas3Yq4tV9b7MLZTqh15NTDQzH0cPwM5c76M9neVU24GH4pP0DIOUOXiUCx >									
	//        <  u =="0.000000000000000001" : ] 000010629366277.430200000000000000 ; 000010713752107.341000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003F5B20343FDBE36B >									
	//     < NDD_BOO_I_metadata_line_32_____1106772473 ro_Lab_810_7Y_1.00 >									
	//        < oyr045PF2gQPRFO0I9867Xx38icd7BGzJW7T015z8OsK1hoyll4JV8V27plG9KEH >									
	//        <  u =="0.000000000000000001" : ] 000010713752107.341000000000000000 ; 000012299103984.017400000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000003FDBE36B494EF17E >									
	//     < NDD_BOO_I_metadata_line_33_____2383198762 ro_Lab_411_3Y_1.00 >									
	//        < I351f2kisGLE3D23431QjUhbfz7lulwjK6Pd19E2ivd5Ye3T02n0AWlESdGv8C2z >									
	//        <  u =="0.000000000000000001" : ] 000012299103984.017400000000000000 ; 000012325747399.876300000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000494EF17E49779914 >									
	//     < NDD_BOO_I_metadata_line_34_____2338739766 ro_Lab_411_5Y_1.00 >									
	//        < 6eY7hvpfI0FM2tb789qko8v38r6qEf5UNW32CugcaAK427V56Sj36Y2CpNISbYfk >									
	//        <  u =="0.000000000000000001" : ] 000012325747399.876300000000000000 ; 000012624352714.221200000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000497799144B3F3BC7 >									
	//     < NDD_BOO_I_metadata_line_35_____2324567926 ro_Lab_411_5Y_1.10 >									
	//        < g2M1h5yP8FuYc7n8m26q85L0U9J1A6Y5Cp13k15we5P1oN7bSpARi2kneE4VKu5A >									
	//        <  u =="0.000000000000000001" : ] 000012624352714.221200000000000000 ; 000012772721347.935000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000004B3F3BC74C21A047 >									
	//     < NDD_BOO_I_metadata_line_36_____1193566006 ro_Lab_411_7Y_1.00 >									
	//        < j5trUNxqER7u34dwK4jw2248wb3W3gGT9069NpGG25ME1K60LDk155Mxa302j39p >									
	//        <  u =="0.000000000000000001" : ] 000012772721347.935000000000000000 ; 000024820240883.596000000000000000 ] >									
	//        < 0x0000000000000000000000000000000000000000000000004C21A04793F0AE98 >									
	//     < NDD_BOO_I_metadata_line_37_____1111641182 ro_Lab_811_3Y_1.00 >									
	//        < 8gEA3GU277m9I60TfZjJHFFeTuZ9WCQ7pZph1xNjjU4iXm08pAlNMct80izA6gzs >									
	//        <  u =="0.000000000000000001" : ] 000024820240883.596000000000000000 ; 000024901896352.202400000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000093F0AE98946D4743 >									
	//     < NDD_BOO_I_metadata_line_38_____1097101776 ro_Lab_811_5Y_1.00 >									
	//        < v17Am9EJlYomfd3VF4770a4Tf0YuTlhNf14Y2SYFa1FUGcfH8J8vEfPzM64O5KpZ >									
	//        <  u =="0.000000000000000001" : ] 000024901896352.202400000000000000 ; 000027812527166.071700000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000946D4743A5C68C6D >									
	//     < NDD_BOO_I_metadata_line_39_____1115969554 ro_Lab_811_5Y_1.10 >									
	//        < 367E7CcJT2xTrwb6BSW456w9ccShP74AwDkD9QAv7bM83dtKJyp1Sjpw573ipIOr >									
	//        <  u =="0.000000000000000001" : ] 000027812527166.071700000000000000 ; 000029198190793.559500000000000000 ] >									
	//        < 0x000000000000000000000000000000000000000000000000A5C68C6DAE08E747 >									
	//     < NDD_BOO_I_metadata_line_40_____969546698 ro_Lab_811_7Y_1.00 >									
	//        < crNqEoqHQ3An30P32E957t9v8wV9V0p8TLpAa11EzKb9uiJn4H72FE5wUxedO4xk >									
	//        <  u =="0.000000000000000001" : ] 000029198190793.559500000000000000 ; 000298914476075.191000000000000000 ] >									
	//        < 0x00000000000000000000000000000000000000000000000AE08E7476F5AB4B38 >									
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
										
	}