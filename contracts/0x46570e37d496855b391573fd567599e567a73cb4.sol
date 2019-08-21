pragma solidity 		^0.4.25	;							
											
	contract	VOCC_I043_20181211				{					
											
		mapping (address => uint256) public balanceOf;									
											
		string	public		name =	"	VOCC_I043_20181211		"	;	
		string	public		symbol =	"	VOCC_I043_20181211_subDT		"	;	
		uint8	public		decimals =		18			;	
											
		uint256 public totalSupply =		19800000000000000000000000					;		
											
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
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
											
//	NABCHF										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; FD28Bf2C6FFDcfdD1A8BC7CcAaAbd5Ac7a87d4CebDadbC9abB2dEbdcAE79F784 ; < k2SR6nfbN2EJ6b2AMWmk65z9T6IqW0Op4GunR162OoXfxchdC4T48T3tG6791U8t > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14022012829845 ; -1 ; -0,00025 ; 0,00025 ; 5,5 ; -8,3 ; 9,1 ; -7,1 ; 4,8 ; -1,1 ; 0,59 ; NABCHF93JA19 ; 4baCAA8CFF9BDadE35feA82cC35DaCCA933cFbACacA6dEfE5cE67C9EDAFEeeee ; < B3Os41Ck3UlIYn6efoHq8G439a27R3vltA2LwSDk8gu5q99L42kNicW3OR09k4rR > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14079278481714 ; -1 ; -0,00025 ; 0,00025 ; -4,3 ; 0,4 ; 1,5 ; 6,9 ; -2,1 ; -2,7 ; -0,15 ; NABCHFMA1971 ; 7B7DA8CefD8fDfc4cA3f3F04Dfb8C110Af2DFF0D53Ca2d676E638dEe4ED70DD2 ; < 4438Dh6rRPL218n73F05GcN4X626kuVFWqLH3GY0C64RkNeebumBH0sHHbXGz8o2 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14142639814536 ; -1 ; -0,00025 ; 0,00025 ; -6,5 ; 2 ; 2,1 ; -2,3 ; -3,9 ; 4,1 ; 0,1 ; NABCHFMA1948 ; df9fcacB6c9E34Eb7DffC5Aba03a0d0bAceAffe866e7eF1fAb35e6eb811f8ce2 ; < EeuSGuN854799iqt5O4rP19N6nHrlte57b6vPWQTDQuinp9Flq9ersdZX27ikF9t > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14237451239954 ; -1 ; -0,00025 ; 0,00025 ; -5 ; -4,9 ; 1,4 ; -1,8 ; -0,8 ; 3,2 ; -0,87 ; NABCHFJU1924 ; 67EBD1Ea5CeC54c7b3daBC0c0f98630653C14faeAdDD1baF7DCEc49aD8bacea4 ; < hX151v3CmklD8T45e1PVeaA84qBqs8GWnva2gfnzZ23O394m1dU1bqTdhf1UI9uc > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14346880221948 ; -1 ; -0,00025 ; 0,00025 ; -8,2 ; 1,5 ; -3,7 ; -4,9 ; 4,5 ; 3,3 ; -0,73 ; NABCHFSE1987 ; BEDb9ACaf62f7821BDA4b438Df40Bfa3AE7d8acD2FCC6debfccC6aFbEfC8AaAE ; < J31WMmF5Qsm7M6Hjr5qUiqGMmaqrO81I21u725BJOLPl05020IrW2RnEWp5WpYzR > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14479319034117 ; -1 ; -0,00025 ; 0,00025 ; -4,3 ; -7,9 ; 3 ; -1 ; 0,1 ; 6 ; -0,63 ; NABCHFDE1960 ; 0F6ca653C4CfaCbf59FaDaBEca066AA0AABFAa1DabcBf6C7adfC0DCE85aE0aF5 ; < lT9E8P5y0FerM8Bqs0TgzvbassoKKosmqsZDPZH2j8E08OvI2j3KJFTvqxqlqzKm > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14644120563189 ; -1 ; -0,00025 ; 0,00025 ; -1,6 ; -9,9 ; -5,6 ; -8,1 ; -8,4 ; -6,2 ; 0,37 ; NABCHFJA2077 ; 4bDeb6eDCd4cca7cB38fc8fF5F1ABc90Ed1D60e4cDf66ca4dB6A25Ac5DA6AAdD ; < V5149966D1F998KNVSa3m63GzQhPH0MwG9i33N1j6J4NK8uk7AE8Z4DQzkR3ZVZ8 > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14824338024487 ; -1 ; -0,00025 ; 0,00025 ; 6,7 ; -6 ; -7,7 ; -7,6 ; -2,8 ; -1,1 ; 0,03 ; NABCHFMA2099 ; 3CeaeEA6d0aA862EC9AD34ebCFcDbBECbEABFBadE983FEdCddEaADBd1B0ef312 ; < 32Pg2P27LN8QbDxxzO3958BKft5efCTGal7WF1sL103L8Q30X9bVI5vg06S11v5n > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15045766962635 ; -1 ; -0,00025 ; 0,00025 ; -8,7 ; 0,5 ; -3,5 ; 8,2 ; -4,2 ; 4,6 ; 0,82 ; NABCHFMA2098 ; cDdBd07ebbCBEFCCF258AADAbaC8E6d27C5cDA4ca1eb39b8fD2bba28DfeEfbbe ; < Kz2YWe4s3b0YGrea33nPmum0mD9u0L01R82HXxJG98bR0uU34A1xlHaAx7U6m17V > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15287006399967 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 8,9 ; -9,8 ; 8,7 ; -9,5 ; -7,3 ; -0,14 ; NABCHFJU2099 ; Dd12ac8c52Dd087c0cd55cECBEFD5B916bd4AD7a2FEfa1CEA0Fce6aBe81A2fC1 ; < kM2EOxfPO3JT4H7uZ657721dG6Py386Kmh92BZu5Q712JG3SNArp8oVc36R0u5g0 > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15548296118516 ; -1 ; -0,00025 ; 0,00025 ; 2,9 ; 2,5 ; 0,5 ; 2,9 ; -8,5 ; -1 ; 0,9 ; NABCHFSE2027 ; d34aF6d403FE9bF0AFa6EbB3be0Fbcbc0f45e41a5aBf64Addc631eCcEdfDcFeC ; < CZjPtnbenu58McUhXw8wi3oh9Q934V132IV3ydsGDodqZ7X2gOHRIx6Vo0ttlCXA > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15846295174206 ; -1 ; -0,00025 ; 0,00025 ; -7,2 ; -8,4 ; -4,9 ; 0,8 ; -7,8 ; 7,8 ; 0,77 ; NABCHFDE2056 ; 5dCfBfE1ABDcc3eefDDF7DffeCeeec3F0BeEf815deEbBa4FAbC3126Bda4BF67a ; < GgPVOrC2U6H1lv5o112V46c75ycvgT6TPVg6Hq6r3t8HuGwi6435cO1d9B98AePv > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,16149420355209 ; -1 ; -0,00025 ; 0,00025 ; -5,5 ; 9,7 ; 9,3 ; -6,5 ; 7,6 ; 0 ; -0,92 ; NABCHFJA2180 ; 5d8a9eAAf19Ccaf8A0E11Ceb4B3FFEcbD7Ff5dDa7521Db9f821E8CECcAf36430 ; < eQEm0ejeasWYcXX1wD6xK52EXY61eD0OWQIy4Ir8O1R1ts9r79mWeNrLF9a82uNe > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16477806578029 ; -1 ; -0,00025 ; 0,00025 ; -2,6 ; -4,3 ; 6,4 ; 6,3 ; 9,9 ; -5,5 ; -0,35 ; NABCHFMA2159 ; A2Af98F1d8dC19DFaefF71AD1cD4Cd07ba3642BbdEDF44ceAcdD9E3DF575DED4 ; < hd5Fu8gTt7QH50zOsmBDlJSKD28cq3XFyCv56Iuw1kR1JD6My8mNVKn0T57EtRB8 > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16836089510099 ; -1 ; -0,00025 ; 0,00025 ; 5,1 ; -0,1 ; 6,2 ; -5,2 ; -6,5 ; 0,4 ; -0,23 ; NABCHFMA2124 ; cDABAE2e1a3162465267EeB9d0AcB53FFD95dDEB72d841a9d6A9a8Ea4391aCFE ; < e2G46C2DH1se80c7378ebrk7Qp987qikfs15kB08HdD172Er28B2bYC9a25zty89 > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,1723014509549 ; -1 ; -0,00025 ; 0,00025 ; 5,6 ; -1,7 ; 0,2 ; 6,8 ; 5,3 ; -8,1 ; -0,1 ; NABCHFJU2171 ; 01F0e9d1E2C2EeF2FbD35f0b1dcDdAFDAE3Df7DF5Cc609AA402D3c0db9f7b937 ; < bLt7wJY87zBEpGxwA9y5reIGGDi5cBGy8OdeXYJ5k6wBoELWaNJ04q3lZg6Q2cNF > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17637345222373 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; 4,1 ; -6,8 ; 2,7 ; 6 ; 7,3 ; 0,03 ; NABCHFSE2171 ; C6faBfC0B002cE02a9db6FCEEbac204F9E1e3AD47e8e47eef5B2ddedcD6Cc6ea ; < XXfLDU2fM2iY8PPKg4n6fu7hTC07R0IedjydF0vf25gZNC3ljGQLO3cX9JTvp7Ii > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18067702954261 ; -1 ; -0,00025 ; 0,00025 ; -7,3 ; 9,1 ; 0,8 ; 6,7 ; -2 ; 2,2 ; 0,6 ; NABCHFDE2113 ; AD5bfdbf7ECBF1fEa63E4Ee0fFAEAD0dE8aE69e3401809F6DcF4DdBcF4bCF3FA ; < 7L8oAqY376Xn2xSoxRYLGD5LN0tQZ45E9NTmT7E7mOMlh6ecjEqkLngqKigur25A > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18526067588708 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; 1,1 ; 3,4 ; -8 ; 4,8 ; 6,3 ; -0,72 ; NABCHFJA2141 ; dACeBdB2ffBecDffdC6AEc8aa2aaA7443ab94cEf6Bbb4Fd56bBDbde5DA8EcAbf ; < 11rvxSPZGo60UkKY1vxRRwmHD8wXA7iuTk5aB40XNq3t2dxRr13l8Iw5eImRjR75 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,1902934561942 ; -1 ; -0,00025 ; 0,00025 ; 7,9 ; 8 ; -7,8 ; -8,5 ; -3,1 ; -2,1 ; -0,39 ; NABCHFMA2182 ; dd55DCeB2EA6cffA85EBE7babe0eeabefA5B3FFE4fffC0CEcc36ECCcdC04Db8f ; < l8bH67KcPcaj8y9yFVg9WnfS5HKz4Tq05o8LBB99ic3xMdI2z57Ab813KjoGw1yn > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19549991964447 ; -1 ; -0,00025 ; 0,00025 ; 4 ; -3,9 ; 7,4 ; 8,3 ; 7,6 ; 5,3 ; -0,04 ; NABCHFMA2157 ; CFB1A6C4Ca0bA4CCFC25DEcffD7e1Adc275bbADb7A6b2e8fbdfeFcF92c4E0fC8 ; < vbr3PF1T95KfJ25zhXcRJVH0RvZ99U0f3CH67PO3y1XRF48ag9P6959a3rOJC40o > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20095391816801 ; -1 ; -0,00025 ; 0,00025 ; -3,9 ; 6,7 ; 6 ; 9,2 ; 8,1 ; 5 ; 0,69 ; NABCHFJU2192 ; Ac72206F728fE1dBcE7eC0CbdFeded8dB78eacABd4fda8DceCcE49EE56DbBDb0 ; < gS0q373tlGLVP1887PTP31Ns9vAk2Np9120eJDCI8ZuM7jYXxMilGzB5jeGw7Fth > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,2066814556377 ; -1 ; -0,00025 ; 0,00025 ; -7,4 ; 9 ; 8,9 ; -1,2 ; 0,4 ; -1,4 ; -0,11 ; NABCHFSE2185 ; 2E42cD2fE5bBe4fEF6E6bD1c9D8b91AE4B1ec4fDfaFcAba0FfC8CCFeB9c1aecA ; < 5eTK7c6z2SXEavxk8vB09vnEb94Ny89oVr97H0w6QV729bBE87T11F2J1N468G9V > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21261742338835 ; -1 ; -0,00025 ; 0,00025 ; 5,3 ; -3,7 ; 9,7 ; -2,1 ; -7,1 ; -3 ; 0,55 ; NABCHFDE2120 ; C2CDEFEAfC5fdC8Dfea8ECFe2bccad7c6E3DDADffaeB529Ce75CBA28A9eD9ccd ; < CBYLN2RPT20f9onrtqx7KYhr06yP7Lf4k15KqwPp58knhKon8339n86L3A3Mh49X > >										24
											
//	  < CALLS ; 3M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 3M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABCHF										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; FD28Bf2C6FFDcfdD1A8BC7CcAaAbd5Ac7a87d4CebDadbC9abB2dEbdcAE79F784 ; < k2SR6nfbN2EJ6b2AMWmk65z9T6IqW0Op4GunR162OoXfxchdC4T48T3tG6791U8t > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14022012829845 ; -1 ; -0,00025 ; 0,00025 ; 5,5 ; -8,3 ; 9,1 ; -7,1 ; 4,8 ; -1,1 ; 0,59 ; NABCHF93JA19 ; 4baCAA8CFF9BDadE35feA82cC35DaCCA933cFbACacA6dEfE5cE67C9EDAFEeeee ; < B3Os41Ck3UlIYn6efoHq8G439a27R3vltA2LwSDk8gu5q99L42kNicW3OR09k4rR > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14079278481714 ; -1 ; -0,00025 ; 0,00025 ; -4,3 ; 0,4 ; 1,5 ; 6,9 ; -2,1 ; -2,7 ; -0,15 ; NABCHFMA1971 ; 7B7DA8CefD8fDfc4cA3f3F04Dfb8C110Af2DFF0D53Ca2d676E638dEe4ED70DD2 ; < 4438Dh6rRPL218n73F05GcN4X626kuVFWqLH3GY0C64RkNeebumBH0sHHbXGz8o2 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14142639814536 ; -1 ; -0,00025 ; 0,00025 ; -6,5 ; 2 ; 2,1 ; -2,3 ; -3,9 ; 4,1 ; 0,1 ; NABCHFMA1948 ; df9fcacB6c9E34Eb7DffC5Aba03a0d0bAceAffe866e7eF1fAb35e6eb811f8ce2 ; < EeuSGuN854799iqt5O4rP19N6nHrlte57b6vPWQTDQuinp9Flq9ersdZX27ikF9t > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14237451239954 ; -1 ; -0,00025 ; 0,00025 ; -5 ; -4,9 ; 1,4 ; -1,8 ; -0,8 ; 3,2 ; -0,87 ; NABCHFJU1924 ; 67EBD1Ea5CeC54c7b3daBC0c0f98630653C14faeAdDD1baF7DCEc49aD8bacea4 ; < hX151v3CmklD8T45e1PVeaA84qBqs8GWnva2gfnzZ23O394m1dU1bqTdhf1UI9uc > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14346880221948 ; -1 ; -0,00025 ; 0,00025 ; -8,2 ; 1,5 ; -3,7 ; -4,9 ; 4,5 ; 3,3 ; -0,73 ; NABCHFSE1987 ; BEDb9ACaf62f7821BDA4b438Df40Bfa3AE7d8acD2FCC6debfccC6aFbEfC8AaAE ; < J31WMmF5Qsm7M6Hjr5qUiqGMmaqrO81I21u725BJOLPl05020IrW2RnEWp5WpYzR > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14479319034117 ; -1 ; -0,00025 ; 0,00025 ; -4,3 ; -7,9 ; 3 ; -1 ; 0,1 ; 6 ; -0,63 ; NABCHFDE1960 ; 0F6ca653C4CfaCbf59FaDaBEca066AA0AABFAa1DabcBf6C7adfC0DCE85aE0aF5 ; < lT9E8P5y0FerM8Bqs0TgzvbassoKKosmqsZDPZH2j8E08OvI2j3KJFTvqxqlqzKm > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14644120563189 ; -1 ; -0,00025 ; 0,00025 ; -1,6 ; -9,9 ; -5,6 ; -8,1 ; -8,4 ; -6,2 ; 0,37 ; NABCHFJA2077 ; 4bDeb6eDCd4cca7cB38fc8fF5F1ABc90Ed1D60e4cDf66ca4dB6A25Ac5DA6AAdD ; < V5149966D1F998KNVSa3m63GzQhPH0MwG9i33N1j6J4NK8uk7AE8Z4DQzkR3ZVZ8 > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14824338024487 ; -1 ; -0,00025 ; 0,00025 ; 6,7 ; -6 ; -7,7 ; -7,6 ; -2,8 ; -1,1 ; 0,03 ; NABCHFMA2099 ; 3CeaeEA6d0aA862EC9AD34ebCFcDbBECbEABFBadE983FEdCddEaADBd1B0ef312 ; < 32Pg2P27LN8QbDxxzO3958BKft5efCTGal7WF1sL103L8Q30X9bVI5vg06S11v5n > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15045766962635 ; -1 ; -0,00025 ; 0,00025 ; -8,7 ; 0,5 ; -3,5 ; 8,2 ; -4,2 ; 4,6 ; 0,82 ; NABCHFMA2098 ; cDdBd07ebbCBEFCCF258AADAbaC8E6d27C5cDA4ca1eb39b8fD2bba28DfeEfbbe ; < Kz2YWe4s3b0YGrea33nPmum0mD9u0L01R82HXxJG98bR0uU34A1xlHaAx7U6m17V > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15287006399967 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 8,9 ; -9,8 ; 8,7 ; -9,5 ; -7,3 ; -0,14 ; NABCHFJU2099 ; Dd12ac8c52Dd087c0cd55cECBEFD5B916bd4AD7a2FEfa1CEA0Fce6aBe81A2fC1 ; < kM2EOxfPO3JT4H7uZ657721dG6Py386Kmh92BZu5Q712JG3SNArp8oVc36R0u5g0 > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15548296118516 ; -1 ; -0,00025 ; 0,00025 ; 2,9 ; 2,5 ; 0,5 ; 2,9 ; -8,5 ; -1 ; 0,9 ; NABCHFSE2027 ; d34aF6d403FE9bF0AFa6EbB3be0Fbcbc0f45e41a5aBf64Addc631eCcEdfDcFeC ; < CZjPtnbenu58McUhXw8wi3oh9Q934V132IV3ydsGDodqZ7X2gOHRIx6Vo0ttlCXA > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15846295174206 ; -1 ; -0,00025 ; 0,00025 ; -7,2 ; -8,4 ; -4,9 ; 0,8 ; -7,8 ; 7,8 ; 0,77 ; NABCHFDE2056 ; 5dCfBfE1ABDcc3eefDDF7DffeCeeec3F0BeEf815deEbBa4FAbC3126Bda4BF67a ; < GgPVOrC2U6H1lv5o112V46c75ycvgT6TPVg6Hq6r3t8HuGwi6435cO1d9B98AePv > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,16149420355209 ; -1 ; -0,00025 ; 0,00025 ; -5,5 ; 9,7 ; 9,3 ; -6,5 ; 7,6 ; 0 ; -0,92 ; NABCHFJA2180 ; 5d8a9eAAf19Ccaf8A0E11Ceb4B3FFEcbD7Ff5dDa7521Db9f821E8CECcAf36430 ; < eQEm0ejeasWYcXX1wD6xK52EXY61eD0OWQIy4Ir8O1R1ts9r79mWeNrLF9a82uNe > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16477806578029 ; -1 ; -0,00025 ; 0,00025 ; -2,6 ; -4,3 ; 6,4 ; 6,3 ; 9,9 ; -5,5 ; -0,35 ; NABCHFMA2159 ; A2Af98F1d8dC19DFaefF71AD1cD4Cd07ba3642BbdEDF44ceAcdD9E3DF575DED4 ; < hd5Fu8gTt7QH50zOsmBDlJSKD28cq3XFyCv56Iuw1kR1JD6My8mNVKn0T57EtRB8 > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16836089510099 ; -1 ; -0,00025 ; 0,00025 ; 5,1 ; -0,1 ; 6,2 ; -5,2 ; -6,5 ; 0,4 ; -0,23 ; NABCHFMA2124 ; cDABAE2e1a3162465267EeB9d0AcB53FFD95dDEB72d841a9d6A9a8Ea4391aCFE ; < e2G46C2DH1se80c7378ebrk7Qp987qikfs15kB08HdD172Er28B2bYC9a25zty89 > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,1723014509549 ; -1 ; -0,00025 ; 0,00025 ; 5,6 ; -1,7 ; 0,2 ; 6,8 ; 5,3 ; -8,1 ; -0,1 ; NABCHFJU2171 ; 01F0e9d1E2C2EeF2FbD35f0b1dcDdAFDAE3Df7DF5Cc609AA402D3c0db9f7b937 ; < bLt7wJY87zBEpGxwA9y5reIGGDi5cBGy8OdeXYJ5k6wBoELWaNJ04q3lZg6Q2cNF > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17637345222373 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; 4,1 ; -6,8 ; 2,7 ; 6 ; 7,3 ; 0,03 ; NABCHFSE2171 ; C6faBfC0B002cE02a9db6FCEEbac204F9E1e3AD47e8e47eef5B2ddedcD6Cc6ea ; < XXfLDU2fM2iY8PPKg4n6fu7hTC07R0IedjydF0vf25gZNC3ljGQLO3cX9JTvp7Ii > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18067702954261 ; -1 ; -0,00025 ; 0,00025 ; -7,3 ; 9,1 ; 0,8 ; 6,7 ; -2 ; 2,2 ; 0,6 ; NABCHFDE2113 ; AD5bfdbf7ECBF1fEa63E4Ee0fFAEAD0dE8aE69e3401809F6DcF4DdBcF4bCF3FA ; < 7L8oAqY376Xn2xSoxRYLGD5LN0tQZ45E9NTmT7E7mOMlh6ecjEqkLngqKigur25A > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18526067588708 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; 1,1 ; 3,4 ; -8 ; 4,8 ; 6,3 ; -0,72 ; NABCHFJA2141 ; dACeBdB2ffBecDffdC6AEc8aa2aaA7443ab94cEf6Bbb4Fd56bBDbde5DA8EcAbf ; < 11rvxSPZGo60UkKY1vxRRwmHD8wXA7iuTk5aB40XNq3t2dxRr13l8Iw5eImRjR75 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,1902934561942 ; -1 ; -0,00025 ; 0,00025 ; 7,9 ; 8 ; -7,8 ; -8,5 ; -3,1 ; -2,1 ; -0,39 ; NABCHFMA2182 ; dd55DCeB2EA6cffA85EBE7babe0eeabefA5B3FFE4fffC0CEcc36ECCcdC04Db8f ; < l8bH67KcPcaj8y9yFVg9WnfS5HKz4Tq05o8LBB99ic3xMdI2z57Ab813KjoGw1yn > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19549991964447 ; -1 ; -0,00025 ; 0,00025 ; 4 ; -3,9 ; 7,4 ; 8,3 ; 7,6 ; 5,3 ; -0,04 ; NABCHFMA2157 ; CFB1A6C4Ca0bA4CCFC25DEcffD7e1Adc275bbADb7A6b2e8fbdfeFcF92c4E0fC8 ; < vbr3PF1T95KfJ25zhXcRJVH0RvZ99U0f3CH67PO3y1XRF48ag9P6959a3rOJC40o > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20095391816801 ; -1 ; -0,00025 ; 0,00025 ; -3,9 ; 6,7 ; 6 ; 9,2 ; 8,1 ; 5 ; 0,69 ; NABCHFJU2192 ; Ac72206F728fE1dBcE7eC0CbdFeded8dB78eacABd4fda8DceCcE49EE56DbBDb0 ; < gS0q373tlGLVP1887PTP31Ns9vAk2Np9120eJDCI8ZuM7jYXxMilGzB5jeGw7Fth > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,2066814556377 ; -1 ; -0,00025 ; 0,00025 ; -7,4 ; 9 ; 8,9 ; -1,2 ; 0,4 ; -1,4 ; -0,11 ; NABCHFSE2185 ; 2E42cD2fE5bBe4fEF6E6bD1c9D8b91AE4B1ec4fDfaFcAba0FfC8CCFeB9c1aecA ; < 5eTK7c6z2SXEavxk8vB09vnEb94Ny89oVr97H0w6QV729bBE87T11F2J1N468G9V > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21261742338835 ; -1 ; -0,00025 ; 0,00025 ; 5,3 ; -3,7 ; 9,7 ; -2,1 ; -7,1 ; -3 ; 0,55 ; NABCHFDE2120 ; C2CDEFEAfC5fdC8Dfea8ECFe2bccad7c6E3DDADffaeB529Ce75CBA28A9eD9ccd ; < CBYLN2RPT20f9onrtqx7KYhr06yP7Lf4k15KqwPp58knhKon8339n86L3A3Mh49X > >										24
											
//	  < CALLS ; 6M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 6M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABCHF										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; FD28Bf2C6FFDcfdD1A8BC7CcAaAbd5Ac7a87d4CebDadbC9abB2dEbdcAE79F784 ; < k2SR6nfbN2EJ6b2AMWmk65z9T6IqW0Op4GunR162OoXfxchdC4T48T3tG6791U8t > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14022012829845 ; -1 ; -0,00025 ; 0,00025 ; 5,5 ; -8,3 ; 9,1 ; -7,1 ; 4,8 ; -1,1 ; 0,59 ; NABCHF93JA19 ; 4baCAA8CFF9BDadE35feA82cC35DaCCA933cFbACacA6dEfE5cE67C9EDAFEeeee ; < B3Os41Ck3UlIYn6efoHq8G439a27R3vltA2LwSDk8gu5q99L42kNicW3OR09k4rR > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14079278481714 ; -1 ; -0,00025 ; 0,00025 ; -4,3 ; 0,4 ; 1,5 ; 6,9 ; -2,1 ; -2,7 ; -0,15 ; NABCHFMA1971 ; 7B7DA8CefD8fDfc4cA3f3F04Dfb8C110Af2DFF0D53Ca2d676E638dEe4ED70DD2 ; < 4438Dh6rRPL218n73F05GcN4X626kuVFWqLH3GY0C64RkNeebumBH0sHHbXGz8o2 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14142639814536 ; -1 ; -0,00025 ; 0,00025 ; -6,5 ; 2 ; 2,1 ; -2,3 ; -3,9 ; 4,1 ; 0,1 ; NABCHFMA1948 ; df9fcacB6c9E34Eb7DffC5Aba03a0d0bAceAffe866e7eF1fAb35e6eb811f8ce2 ; < EeuSGuN854799iqt5O4rP19N6nHrlte57b6vPWQTDQuinp9Flq9ersdZX27ikF9t > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14237451239954 ; -1 ; -0,00025 ; 0,00025 ; -5 ; -4,9 ; 1,4 ; -1,8 ; -0,8 ; 3,2 ; -0,87 ; NABCHFJU1924 ; 67EBD1Ea5CeC54c7b3daBC0c0f98630653C14faeAdDD1baF7DCEc49aD8bacea4 ; < hX151v3CmklD8T45e1PVeaA84qBqs8GWnva2gfnzZ23O394m1dU1bqTdhf1UI9uc > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14346880221948 ; -1 ; -0,00025 ; 0,00025 ; -8,2 ; 1,5 ; -3,7 ; -4,9 ; 4,5 ; 3,3 ; -0,73 ; NABCHFSE1987 ; BEDb9ACaf62f7821BDA4b438Df40Bfa3AE7d8acD2FCC6debfccC6aFbEfC8AaAE ; < J31WMmF5Qsm7M6Hjr5qUiqGMmaqrO81I21u725BJOLPl05020IrW2RnEWp5WpYzR > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14479319034117 ; -1 ; -0,00025 ; 0,00025 ; -4,3 ; -7,9 ; 3 ; -1 ; 0,1 ; 6 ; -0,63 ; NABCHFDE1960 ; 0F6ca653C4CfaCbf59FaDaBEca066AA0AABFAa1DabcBf6C7adfC0DCE85aE0aF5 ; < lT9E8P5y0FerM8Bqs0TgzvbassoKKosmqsZDPZH2j8E08OvI2j3KJFTvqxqlqzKm > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14644120563189 ; -1 ; -0,00025 ; 0,00025 ; -1,6 ; -9,9 ; -5,6 ; -8,1 ; -8,4 ; -6,2 ; 0,37 ; NABCHFJA2077 ; 4bDeb6eDCd4cca7cB38fc8fF5F1ABc90Ed1D60e4cDf66ca4dB6A25Ac5DA6AAdD ; < V5149966D1F998KNVSa3m63GzQhPH0MwG9i33N1j6J4NK8uk7AE8Z4DQzkR3ZVZ8 > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14824338024487 ; -1 ; -0,00025 ; 0,00025 ; 6,7 ; -6 ; -7,7 ; -7,6 ; -2,8 ; -1,1 ; 0,03 ; NABCHFMA2099 ; 3CeaeEA6d0aA862EC9AD34ebCFcDbBECbEABFBadE983FEdCddEaADBd1B0ef312 ; < 32Pg2P27LN8QbDxxzO3958BKft5efCTGal7WF1sL103L8Q30X9bVI5vg06S11v5n > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15045766962635 ; -1 ; -0,00025 ; 0,00025 ; -8,7 ; 0,5 ; -3,5 ; 8,2 ; -4,2 ; 4,6 ; 0,82 ; NABCHFMA2098 ; cDdBd07ebbCBEFCCF258AADAbaC8E6d27C5cDA4ca1eb39b8fD2bba28DfeEfbbe ; < Kz2YWe4s3b0YGrea33nPmum0mD9u0L01R82HXxJG98bR0uU34A1xlHaAx7U6m17V > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15287006399967 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 8,9 ; -9,8 ; 8,7 ; -9,5 ; -7,3 ; -0,14 ; NABCHFJU2099 ; Dd12ac8c52Dd087c0cd55cECBEFD5B916bd4AD7a2FEfa1CEA0Fce6aBe81A2fC1 ; < kM2EOxfPO3JT4H7uZ657721dG6Py386Kmh92BZu5Q712JG3SNArp8oVc36R0u5g0 > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15548296118516 ; -1 ; -0,00025 ; 0,00025 ; 2,9 ; 2,5 ; 0,5 ; 2,9 ; -8,5 ; -1 ; 0,9 ; NABCHFSE2027 ; d34aF6d403FE9bF0AFa6EbB3be0Fbcbc0f45e41a5aBf64Addc631eCcEdfDcFeC ; < CZjPtnbenu58McUhXw8wi3oh9Q934V132IV3ydsGDodqZ7X2gOHRIx6Vo0ttlCXA > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15846295174206 ; -1 ; -0,00025 ; 0,00025 ; -7,2 ; -8,4 ; -4,9 ; 0,8 ; -7,8 ; 7,8 ; 0,77 ; NABCHFDE2056 ; 5dCfBfE1ABDcc3eefDDF7DffeCeeec3F0BeEf815deEbBa4FAbC3126Bda4BF67a ; < GgPVOrC2U6H1lv5o112V46c75ycvgT6TPVg6Hq6r3t8HuGwi6435cO1d9B98AePv > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,16149420355209 ; -1 ; -0,00025 ; 0,00025 ; -5,5 ; 9,7 ; 9,3 ; -6,5 ; 7,6 ; 0 ; -0,92 ; NABCHFJA2180 ; 5d8a9eAAf19Ccaf8A0E11Ceb4B3FFEcbD7Ff5dDa7521Db9f821E8CECcAf36430 ; < eQEm0ejeasWYcXX1wD6xK52EXY61eD0OWQIy4Ir8O1R1ts9r79mWeNrLF9a82uNe > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16477806578029 ; -1 ; -0,00025 ; 0,00025 ; -2,6 ; -4,3 ; 6,4 ; 6,3 ; 9,9 ; -5,5 ; -0,35 ; NABCHFMA2159 ; A2Af98F1d8dC19DFaefF71AD1cD4Cd07ba3642BbdEDF44ceAcdD9E3DF575DED4 ; < hd5Fu8gTt7QH50zOsmBDlJSKD28cq3XFyCv56Iuw1kR1JD6My8mNVKn0T57EtRB8 > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16836089510099 ; -1 ; -0,00025 ; 0,00025 ; 5,1 ; -0,1 ; 6,2 ; -5,2 ; -6,5 ; 0,4 ; -0,23 ; NABCHFMA2124 ; cDABAE2e1a3162465267EeB9d0AcB53FFD95dDEB72d841a9d6A9a8Ea4391aCFE ; < e2G46C2DH1se80c7378ebrk7Qp987qikfs15kB08HdD172Er28B2bYC9a25zty89 > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,1723014509549 ; -1 ; -0,00025 ; 0,00025 ; 5,6 ; -1,7 ; 0,2 ; 6,8 ; 5,3 ; -8,1 ; -0,1 ; NABCHFJU2171 ; 01F0e9d1E2C2EeF2FbD35f0b1dcDdAFDAE3Df7DF5Cc609AA402D3c0db9f7b937 ; < bLt7wJY87zBEpGxwA9y5reIGGDi5cBGy8OdeXYJ5k6wBoELWaNJ04q3lZg6Q2cNF > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17637345222373 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; 4,1 ; -6,8 ; 2,7 ; 6 ; 7,3 ; 0,03 ; NABCHFSE2171 ; C6faBfC0B002cE02a9db6FCEEbac204F9E1e3AD47e8e47eef5B2ddedcD6Cc6ea ; < XXfLDU2fM2iY8PPKg4n6fu7hTC07R0IedjydF0vf25gZNC3ljGQLO3cX9JTvp7Ii > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18067702954261 ; -1 ; -0,00025 ; 0,00025 ; -7,3 ; 9,1 ; 0,8 ; 6,7 ; -2 ; 2,2 ; 0,6 ; NABCHFDE2113 ; AD5bfdbf7ECBF1fEa63E4Ee0fFAEAD0dE8aE69e3401809F6DcF4DdBcF4bCF3FA ; < 7L8oAqY376Xn2xSoxRYLGD5LN0tQZ45E9NTmT7E7mOMlh6ecjEqkLngqKigur25A > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18526067588708 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; 1,1 ; 3,4 ; -8 ; 4,8 ; 6,3 ; -0,72 ; NABCHFJA2141 ; dACeBdB2ffBecDffdC6AEc8aa2aaA7443ab94cEf6Bbb4Fd56bBDbde5DA8EcAbf ; < 11rvxSPZGo60UkKY1vxRRwmHD8wXA7iuTk5aB40XNq3t2dxRr13l8Iw5eImRjR75 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,1902934561942 ; -1 ; -0,00025 ; 0,00025 ; 7,9 ; 8 ; -7,8 ; -8,5 ; -3,1 ; -2,1 ; -0,39 ; NABCHFMA2182 ; dd55DCeB2EA6cffA85EBE7babe0eeabefA5B3FFE4fffC0CEcc36ECCcdC04Db8f ; < l8bH67KcPcaj8y9yFVg9WnfS5HKz4Tq05o8LBB99ic3xMdI2z57Ab813KjoGw1yn > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19549991964447 ; -1 ; -0,00025 ; 0,00025 ; 4 ; -3,9 ; 7,4 ; 8,3 ; 7,6 ; 5,3 ; -0,04 ; NABCHFMA2157 ; CFB1A6C4Ca0bA4CCFC25DEcffD7e1Adc275bbADb7A6b2e8fbdfeFcF92c4E0fC8 ; < vbr3PF1T95KfJ25zhXcRJVH0RvZ99U0f3CH67PO3y1XRF48ag9P6959a3rOJC40o > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20095391816801 ; -1 ; -0,00025 ; 0,00025 ; -3,9 ; 6,7 ; 6 ; 9,2 ; 8,1 ; 5 ; 0,69 ; NABCHFJU2192 ; Ac72206F728fE1dBcE7eC0CbdFeded8dB78eacABd4fda8DceCcE49EE56DbBDb0 ; < gS0q373tlGLVP1887PTP31Ns9vAk2Np9120eJDCI8ZuM7jYXxMilGzB5jeGw7Fth > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,2066814556377 ; -1 ; -0,00025 ; 0,00025 ; -7,4 ; 9 ; 8,9 ; -1,2 ; 0,4 ; -1,4 ; -0,11 ; NABCHFSE2185 ; 2E42cD2fE5bBe4fEF6E6bD1c9D8b91AE4B1ec4fDfaFcAba0FfC8CCFeB9c1aecA ; < 5eTK7c6z2SXEavxk8vB09vnEb94Ny89oVr97H0w6QV729bBE87T11F2J1N468G9V > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21261742338835 ; -1 ; -0,00025 ; 0,00025 ; 5,3 ; -3,7 ; 9,7 ; -2,1 ; -7,1 ; -3 ; 0,55 ; NABCHFDE2120 ; C2CDEFEAfC5fdC8Dfea8ECFe2bccad7c6E3DDADffaeB529Ce75CBA28A9eD9ccd ; < CBYLN2RPT20f9onrtqx7KYhr06yP7Lf4k15KqwPp58knhKon8339n86L3A3Mh49X > >										24
											
//	  < CALLS ; 12M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 12M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABCHF										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; FD28Bf2C6FFDcfdD1A8BC7CcAaAbd5Ac7a87d4CebDadbC9abB2dEbdcAE79F784 ; < k2SR6nfbN2EJ6b2AMWmk65z9T6IqW0Op4GunR162OoXfxchdC4T48T3tG6791U8t > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14022012829845 ; -1 ; -0,00025 ; 0,00025 ; 5,5 ; -8,3 ; 9,1 ; -7,1 ; 4,8 ; -1,1 ; 0,59 ; NABCHF93JA19 ; 4baCAA8CFF9BDadE35feA82cC35DaCCA933cFbACacA6dEfE5cE67C9EDAFEeeee ; < B3Os41Ck3UlIYn6efoHq8G439a27R3vltA2LwSDk8gu5q99L42kNicW3OR09k4rR > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14079278481714 ; -1 ; -0,00025 ; 0,00025 ; -4,3 ; 0,4 ; 1,5 ; 6,9 ; -2,1 ; -2,7 ; -0,15 ; NABCHFMA1971 ; 7B7DA8CefD8fDfc4cA3f3F04Dfb8C110Af2DFF0D53Ca2d676E638dEe4ED70DD2 ; < 4438Dh6rRPL218n73F05GcN4X626kuVFWqLH3GY0C64RkNeebumBH0sHHbXGz8o2 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14142639814536 ; -1 ; -0,00025 ; 0,00025 ; -6,5 ; 2 ; 2,1 ; -2,3 ; -3,9 ; 4,1 ; 0,1 ; NABCHFMA1948 ; df9fcacB6c9E34Eb7DffC5Aba03a0d0bAceAffe866e7eF1fAb35e6eb811f8ce2 ; < EeuSGuN854799iqt5O4rP19N6nHrlte57b6vPWQTDQuinp9Flq9ersdZX27ikF9t > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14237451239954 ; -1 ; -0,00025 ; 0,00025 ; -5 ; -4,9 ; 1,4 ; -1,8 ; -0,8 ; 3,2 ; -0,87 ; NABCHFJU1924 ; 67EBD1Ea5CeC54c7b3daBC0c0f98630653C14faeAdDD1baF7DCEc49aD8bacea4 ; < hX151v3CmklD8T45e1PVeaA84qBqs8GWnva2gfnzZ23O394m1dU1bqTdhf1UI9uc > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14346880221948 ; -1 ; -0,00025 ; 0,00025 ; -8,2 ; 1,5 ; -3,7 ; -4,9 ; 4,5 ; 3,3 ; -0,73 ; NABCHFSE1987 ; BEDb9ACaf62f7821BDA4b438Df40Bfa3AE7d8acD2FCC6debfccC6aFbEfC8AaAE ; < J31WMmF5Qsm7M6Hjr5qUiqGMmaqrO81I21u725BJOLPl05020IrW2RnEWp5WpYzR > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14479319034117 ; -1 ; -0,00025 ; 0,00025 ; -4,3 ; -7,9 ; 3 ; -1 ; 0,1 ; 6 ; -0,63 ; NABCHFDE1960 ; 0F6ca653C4CfaCbf59FaDaBEca066AA0AABFAa1DabcBf6C7adfC0DCE85aE0aF5 ; < lT9E8P5y0FerM8Bqs0TgzvbassoKKosmqsZDPZH2j8E08OvI2j3KJFTvqxqlqzKm > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14644120563189 ; -1 ; -0,00025 ; 0,00025 ; -1,6 ; -9,9 ; -5,6 ; -8,1 ; -8,4 ; -6,2 ; 0,37 ; NABCHFJA2077 ; 4bDeb6eDCd4cca7cB38fc8fF5F1ABc90Ed1D60e4cDf66ca4dB6A25Ac5DA6AAdD ; < V5149966D1F998KNVSa3m63GzQhPH0MwG9i33N1j6J4NK8uk7AE8Z4DQzkR3ZVZ8 > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14824338024487 ; -1 ; -0,00025 ; 0,00025 ; 6,7 ; -6 ; -7,7 ; -7,6 ; -2,8 ; -1,1 ; 0,03 ; NABCHFMA2099 ; 3CeaeEA6d0aA862EC9AD34ebCFcDbBECbEABFBadE983FEdCddEaADBd1B0ef312 ; < 32Pg2P27LN8QbDxxzO3958BKft5efCTGal7WF1sL103L8Q30X9bVI5vg06S11v5n > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15045766962635 ; -1 ; -0,00025 ; 0,00025 ; -8,7 ; 0,5 ; -3,5 ; 8,2 ; -4,2 ; 4,6 ; 0,82 ; NABCHFMA2098 ; cDdBd07ebbCBEFCCF258AADAbaC8E6d27C5cDA4ca1eb39b8fD2bba28DfeEfbbe ; < Kz2YWe4s3b0YGrea33nPmum0mD9u0L01R82HXxJG98bR0uU34A1xlHaAx7U6m17V > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15287006399967 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 8,9 ; -9,8 ; 8,7 ; -9,5 ; -7,3 ; -0,14 ; NABCHFJU2099 ; Dd12ac8c52Dd087c0cd55cECBEFD5B916bd4AD7a2FEfa1CEA0Fce6aBe81A2fC1 ; < kM2EOxfPO3JT4H7uZ657721dG6Py386Kmh92BZu5Q712JG3SNArp8oVc36R0u5g0 > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15548296118516 ; -1 ; -0,00025 ; 0,00025 ; 2,9 ; 2,5 ; 0,5 ; 2,9 ; -8,5 ; -1 ; 0,9 ; NABCHFSE2027 ; d34aF6d403FE9bF0AFa6EbB3be0Fbcbc0f45e41a5aBf64Addc631eCcEdfDcFeC ; < CZjPtnbenu58McUhXw8wi3oh9Q934V132IV3ydsGDodqZ7X2gOHRIx6Vo0ttlCXA > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15846295174206 ; -1 ; -0,00025 ; 0,00025 ; -7,2 ; -8,4 ; -4,9 ; 0,8 ; -7,8 ; 7,8 ; 0,77 ; NABCHFDE2056 ; 5dCfBfE1ABDcc3eefDDF7DffeCeeec3F0BeEf815deEbBa4FAbC3126Bda4BF67a ; < GgPVOrC2U6H1lv5o112V46c75ycvgT6TPVg6Hq6r3t8HuGwi6435cO1d9B98AePv > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,16149420355209 ; -1 ; -0,00025 ; 0,00025 ; -5,5 ; 9,7 ; 9,3 ; -6,5 ; 7,6 ; 0 ; -0,92 ; NABCHFJA2180 ; 5d8a9eAAf19Ccaf8A0E11Ceb4B3FFEcbD7Ff5dDa7521Db9f821E8CECcAf36430 ; < eQEm0ejeasWYcXX1wD6xK52EXY61eD0OWQIy4Ir8O1R1ts9r79mWeNrLF9a82uNe > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16477806578029 ; -1 ; -0,00025 ; 0,00025 ; -2,6 ; -4,3 ; 6,4 ; 6,3 ; 9,9 ; -5,5 ; -0,35 ; NABCHFMA2159 ; A2Af98F1d8dC19DFaefF71AD1cD4Cd07ba3642BbdEDF44ceAcdD9E3DF575DED4 ; < hd5Fu8gTt7QH50zOsmBDlJSKD28cq3XFyCv56Iuw1kR1JD6My8mNVKn0T57EtRB8 > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16836089510099 ; -1 ; -0,00025 ; 0,00025 ; 5,1 ; -0,1 ; 6,2 ; -5,2 ; -6,5 ; 0,4 ; -0,23 ; NABCHFMA2124 ; cDABAE2e1a3162465267EeB9d0AcB53FFD95dDEB72d841a9d6A9a8Ea4391aCFE ; < e2G46C2DH1se80c7378ebrk7Qp987qikfs15kB08HdD172Er28B2bYC9a25zty89 > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,1723014509549 ; -1 ; -0,00025 ; 0,00025 ; 5,6 ; -1,7 ; 0,2 ; 6,8 ; 5,3 ; -8,1 ; -0,1 ; NABCHFJU2171 ; 01F0e9d1E2C2EeF2FbD35f0b1dcDdAFDAE3Df7DF5Cc609AA402D3c0db9f7b937 ; < bLt7wJY87zBEpGxwA9y5reIGGDi5cBGy8OdeXYJ5k6wBoELWaNJ04q3lZg6Q2cNF > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17637345222373 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; 4,1 ; -6,8 ; 2,7 ; 6 ; 7,3 ; 0,03 ; NABCHFSE2171 ; C6faBfC0B002cE02a9db6FCEEbac204F9E1e3AD47e8e47eef5B2ddedcD6Cc6ea ; < XXfLDU2fM2iY8PPKg4n6fu7hTC07R0IedjydF0vf25gZNC3ljGQLO3cX9JTvp7Ii > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18067702954261 ; -1 ; -0,00025 ; 0,00025 ; -7,3 ; 9,1 ; 0,8 ; 6,7 ; -2 ; 2,2 ; 0,6 ; NABCHFDE2113 ; AD5bfdbf7ECBF1fEa63E4Ee0fFAEAD0dE8aE69e3401809F6DcF4DdBcF4bCF3FA ; < 7L8oAqY376Xn2xSoxRYLGD5LN0tQZ45E9NTmT7E7mOMlh6ecjEqkLngqKigur25A > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18526067588708 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; 1,1 ; 3,4 ; -8 ; 4,8 ; 6,3 ; -0,72 ; NABCHFJA2141 ; dACeBdB2ffBecDffdC6AEc8aa2aaA7443ab94cEf6Bbb4Fd56bBDbde5DA8EcAbf ; < 11rvxSPZGo60UkKY1vxRRwmHD8wXA7iuTk5aB40XNq3t2dxRr13l8Iw5eImRjR75 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,1902934561942 ; -1 ; -0,00025 ; 0,00025 ; 7,9 ; 8 ; -7,8 ; -8,5 ; -3,1 ; -2,1 ; -0,39 ; NABCHFMA2182 ; dd55DCeB2EA6cffA85EBE7babe0eeabefA5B3FFE4fffC0CEcc36ECCcdC04Db8f ; < l8bH67KcPcaj8y9yFVg9WnfS5HKz4Tq05o8LBB99ic3xMdI2z57Ab813KjoGw1yn > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19549991964447 ; -1 ; -0,00025 ; 0,00025 ; 4 ; -3,9 ; 7,4 ; 8,3 ; 7,6 ; 5,3 ; -0,04 ; NABCHFMA2157 ; CFB1A6C4Ca0bA4CCFC25DEcffD7e1Adc275bbADb7A6b2e8fbdfeFcF92c4E0fC8 ; < vbr3PF1T95KfJ25zhXcRJVH0RvZ99U0f3CH67PO3y1XRF48ag9P6959a3rOJC40o > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20095391816801 ; -1 ; -0,00025 ; 0,00025 ; -3,9 ; 6,7 ; 6 ; 9,2 ; 8,1 ; 5 ; 0,69 ; NABCHFJU2192 ; Ac72206F728fE1dBcE7eC0CbdFeded8dB78eacABd4fda8DceCcE49EE56DbBDb0 ; < gS0q373tlGLVP1887PTP31Ns9vAk2Np9120eJDCI8ZuM7jYXxMilGzB5jeGw7Fth > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,2066814556377 ; -1 ; -0,00025 ; 0,00025 ; -7,4 ; 9 ; 8,9 ; -1,2 ; 0,4 ; -1,4 ; -0,11 ; NABCHFSE2185 ; 2E42cD2fE5bBe4fEF6E6bD1c9D8b91AE4B1ec4fDfaFcAba0FfC8CCFeB9c1aecA ; < 5eTK7c6z2SXEavxk8vB09vnEb94Ny89oVr97H0w6QV729bBE87T11F2J1N468G9V > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21261742338835 ; -1 ; -0,00025 ; 0,00025 ; 5,3 ; -3,7 ; 9,7 ; -2,1 ; -7,1 ; -3 ; 0,55 ; NABCHFDE2120 ; C2CDEFEAfC5fdC8Dfea8ECFe2bccad7c6E3DDADffaeB529Ce75CBA28A9eD9ccd ; < CBYLN2RPT20f9onrtqx7KYhr06yP7Lf4k15KqwPp58knhKon8339n86L3A3Mh49X > >										24
											
//	  < CALLS ; 24M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 24M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABCHF										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; FD28Bf2C6FFDcfdD1A8BC7CcAaAbd5Ac7a87d4CebDadbC9abB2dEbdcAE79F784 ; < k2SR6nfbN2EJ6b2AMWmk65z9T6IqW0Op4GunR162OoXfxchdC4T48T3tG6791U8t > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14022012829845 ; -1 ; -0,00025 ; 0,00025 ; 5,5 ; -8,3 ; 9,1 ; -7,1 ; 4,8 ; -1,1 ; 0,59 ; NABCHF93JA19 ; 4baCAA8CFF9BDadE35feA82cC35DaCCA933cFbACacA6dEfE5cE67C9EDAFEeeee ; < B3Os41Ck3UlIYn6efoHq8G439a27R3vltA2LwSDk8gu5q99L42kNicW3OR09k4rR > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14079278481714 ; -1 ; -0,00025 ; 0,00025 ; -4,3 ; 0,4 ; 1,5 ; 6,9 ; -2,1 ; -2,7 ; -0,15 ; NABCHFMA1971 ; 7B7DA8CefD8fDfc4cA3f3F04Dfb8C110Af2DFF0D53Ca2d676E638dEe4ED70DD2 ; < 4438Dh6rRPL218n73F05GcN4X626kuVFWqLH3GY0C64RkNeebumBH0sHHbXGz8o2 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14142639814536 ; -1 ; -0,00025 ; 0,00025 ; -6,5 ; 2 ; 2,1 ; -2,3 ; -3,9 ; 4,1 ; 0,1 ; NABCHFMA1948 ; df9fcacB6c9E34Eb7DffC5Aba03a0d0bAceAffe866e7eF1fAb35e6eb811f8ce2 ; < EeuSGuN854799iqt5O4rP19N6nHrlte57b6vPWQTDQuinp9Flq9ersdZX27ikF9t > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14237451239954 ; -1 ; -0,00025 ; 0,00025 ; -5 ; -4,9 ; 1,4 ; -1,8 ; -0,8 ; 3,2 ; -0,87 ; NABCHFJU1924 ; 67EBD1Ea5CeC54c7b3daBC0c0f98630653C14faeAdDD1baF7DCEc49aD8bacea4 ; < hX151v3CmklD8T45e1PVeaA84qBqs8GWnva2gfnzZ23O394m1dU1bqTdhf1UI9uc > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14346880221948 ; -1 ; -0,00025 ; 0,00025 ; -8,2 ; 1,5 ; -3,7 ; -4,9 ; 4,5 ; 3,3 ; -0,73 ; NABCHFSE1987 ; BEDb9ACaf62f7821BDA4b438Df40Bfa3AE7d8acD2FCC6debfccC6aFbEfC8AaAE ; < J31WMmF5Qsm7M6Hjr5qUiqGMmaqrO81I21u725BJOLPl05020IrW2RnEWp5WpYzR > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14479319034117 ; -1 ; -0,00025 ; 0,00025 ; -4,3 ; -7,9 ; 3 ; -1 ; 0,1 ; 6 ; -0,63 ; NABCHFDE1960 ; 0F6ca653C4CfaCbf59FaDaBEca066AA0AABFAa1DabcBf6C7adfC0DCE85aE0aF5 ; < lT9E8P5y0FerM8Bqs0TgzvbassoKKosmqsZDPZH2j8E08OvI2j3KJFTvqxqlqzKm > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14644120563189 ; -1 ; -0,00025 ; 0,00025 ; -1,6 ; -9,9 ; -5,6 ; -8,1 ; -8,4 ; -6,2 ; 0,37 ; NABCHFJA2077 ; 4bDeb6eDCd4cca7cB38fc8fF5F1ABc90Ed1D60e4cDf66ca4dB6A25Ac5DA6AAdD ; < V5149966D1F998KNVSa3m63GzQhPH0MwG9i33N1j6J4NK8uk7AE8Z4DQzkR3ZVZ8 > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14824338024487 ; -1 ; -0,00025 ; 0,00025 ; 6,7 ; -6 ; -7,7 ; -7,6 ; -2,8 ; -1,1 ; 0,03 ; NABCHFMA2099 ; 3CeaeEA6d0aA862EC9AD34ebCFcDbBECbEABFBadE983FEdCddEaADBd1B0ef312 ; < 32Pg2P27LN8QbDxxzO3958BKft5efCTGal7WF1sL103L8Q30X9bVI5vg06S11v5n > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15045766962635 ; -1 ; -0,00025 ; 0,00025 ; -8,7 ; 0,5 ; -3,5 ; 8,2 ; -4,2 ; 4,6 ; 0,82 ; NABCHFMA2098 ; cDdBd07ebbCBEFCCF258AADAbaC8E6d27C5cDA4ca1eb39b8fD2bba28DfeEfbbe ; < Kz2YWe4s3b0YGrea33nPmum0mD9u0L01R82HXxJG98bR0uU34A1xlHaAx7U6m17V > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15287006399967 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 8,9 ; -9,8 ; 8,7 ; -9,5 ; -7,3 ; -0,14 ; NABCHFJU2099 ; Dd12ac8c52Dd087c0cd55cECBEFD5B916bd4AD7a2FEfa1CEA0Fce6aBe81A2fC1 ; < kM2EOxfPO3JT4H7uZ657721dG6Py386Kmh92BZu5Q712JG3SNArp8oVc36R0u5g0 > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15548296118516 ; -1 ; -0,00025 ; 0,00025 ; 2,9 ; 2,5 ; 0,5 ; 2,9 ; -8,5 ; -1 ; 0,9 ; NABCHFSE2027 ; d34aF6d403FE9bF0AFa6EbB3be0Fbcbc0f45e41a5aBf64Addc631eCcEdfDcFeC ; < CZjPtnbenu58McUhXw8wi3oh9Q934V132IV3ydsGDodqZ7X2gOHRIx6Vo0ttlCXA > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15846295174206 ; -1 ; -0,00025 ; 0,00025 ; -7,2 ; -8,4 ; -4,9 ; 0,8 ; -7,8 ; 7,8 ; 0,77 ; NABCHFDE2056 ; 5dCfBfE1ABDcc3eefDDF7DffeCeeec3F0BeEf815deEbBa4FAbC3126Bda4BF67a ; < GgPVOrC2U6H1lv5o112V46c75ycvgT6TPVg6Hq6r3t8HuGwi6435cO1d9B98AePv > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,16149420355209 ; -1 ; -0,00025 ; 0,00025 ; -5,5 ; 9,7 ; 9,3 ; -6,5 ; 7,6 ; 0 ; -0,92 ; NABCHFJA2180 ; 5d8a9eAAf19Ccaf8A0E11Ceb4B3FFEcbD7Ff5dDa7521Db9f821E8CECcAf36430 ; < eQEm0ejeasWYcXX1wD6xK52EXY61eD0OWQIy4Ir8O1R1ts9r79mWeNrLF9a82uNe > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16477806578029 ; -1 ; -0,00025 ; 0,00025 ; -2,6 ; -4,3 ; 6,4 ; 6,3 ; 9,9 ; -5,5 ; -0,35 ; NABCHFMA2159 ; A2Af98F1d8dC19DFaefF71AD1cD4Cd07ba3642BbdEDF44ceAcdD9E3DF575DED4 ; < hd5Fu8gTt7QH50zOsmBDlJSKD28cq3XFyCv56Iuw1kR1JD6My8mNVKn0T57EtRB8 > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16836089510099 ; -1 ; -0,00025 ; 0,00025 ; 5,1 ; -0,1 ; 6,2 ; -5,2 ; -6,5 ; 0,4 ; -0,23 ; NABCHFMA2124 ; cDABAE2e1a3162465267EeB9d0AcB53FFD95dDEB72d841a9d6A9a8Ea4391aCFE ; < e2G46C2DH1se80c7378ebrk7Qp987qikfs15kB08HdD172Er28B2bYC9a25zty89 > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,1723014509549 ; -1 ; -0,00025 ; 0,00025 ; 5,6 ; -1,7 ; 0,2 ; 6,8 ; 5,3 ; -8,1 ; -0,1 ; NABCHFJU2171 ; 01F0e9d1E2C2EeF2FbD35f0b1dcDdAFDAE3Df7DF5Cc609AA402D3c0db9f7b937 ; < bLt7wJY87zBEpGxwA9y5reIGGDi5cBGy8OdeXYJ5k6wBoELWaNJ04q3lZg6Q2cNF > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17637345222373 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; 4,1 ; -6,8 ; 2,7 ; 6 ; 7,3 ; 0,03 ; NABCHFSE2171 ; C6faBfC0B002cE02a9db6FCEEbac204F9E1e3AD47e8e47eef5B2ddedcD6Cc6ea ; < XXfLDU2fM2iY8PPKg4n6fu7hTC07R0IedjydF0vf25gZNC3ljGQLO3cX9JTvp7Ii > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18067702954261 ; -1 ; -0,00025 ; 0,00025 ; -7,3 ; 9,1 ; 0,8 ; 6,7 ; -2 ; 2,2 ; 0,6 ; NABCHFDE2113 ; AD5bfdbf7ECBF1fEa63E4Ee0fFAEAD0dE8aE69e3401809F6DcF4DdBcF4bCF3FA ; < 7L8oAqY376Xn2xSoxRYLGD5LN0tQZ45E9NTmT7E7mOMlh6ecjEqkLngqKigur25A > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18526067588708 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; 1,1 ; 3,4 ; -8 ; 4,8 ; 6,3 ; -0,72 ; NABCHFJA2141 ; dACeBdB2ffBecDffdC6AEc8aa2aaA7443ab94cEf6Bbb4Fd56bBDbde5DA8EcAbf ; < 11rvxSPZGo60UkKY1vxRRwmHD8wXA7iuTk5aB40XNq3t2dxRr13l8Iw5eImRjR75 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,1902934561942 ; -1 ; -0,00025 ; 0,00025 ; 7,9 ; 8 ; -7,8 ; -8,5 ; -3,1 ; -2,1 ; -0,39 ; NABCHFMA2182 ; dd55DCeB2EA6cffA85EBE7babe0eeabefA5B3FFE4fffC0CEcc36ECCcdC04Db8f ; < l8bH67KcPcaj8y9yFVg9WnfS5HKz4Tq05o8LBB99ic3xMdI2z57Ab813KjoGw1yn > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19549991964447 ; -1 ; -0,00025 ; 0,00025 ; 4 ; -3,9 ; 7,4 ; 8,3 ; 7,6 ; 5,3 ; -0,04 ; NABCHFMA2157 ; CFB1A6C4Ca0bA4CCFC25DEcffD7e1Adc275bbADb7A6b2e8fbdfeFcF92c4E0fC8 ; < vbr3PF1T95KfJ25zhXcRJVH0RvZ99U0f3CH67PO3y1XRF48ag9P6959a3rOJC40o > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20095391816801 ; -1 ; -0,00025 ; 0,00025 ; -3,9 ; 6,7 ; 6 ; 9,2 ; 8,1 ; 5 ; 0,69 ; NABCHFJU2192 ; Ac72206F728fE1dBcE7eC0CbdFeded8dB78eacABd4fda8DceCcE49EE56DbBDb0 ; < gS0q373tlGLVP1887PTP31Ns9vAk2Np9120eJDCI8ZuM7jYXxMilGzB5jeGw7Fth > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,2066814556377 ; -1 ; -0,00025 ; 0,00025 ; -7,4 ; 9 ; 8,9 ; -1,2 ; 0,4 ; -1,4 ; -0,11 ; NABCHFSE2185 ; 2E42cD2fE5bBe4fEF6E6bD1c9D8b91AE4B1ec4fDfaFcAba0FfC8CCFeB9c1aecA ; < 5eTK7c6z2SXEavxk8vB09vnEb94Ny89oVr97H0w6QV729bBE87T11F2J1N468G9V > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21261742338835 ; -1 ; -0,00025 ; 0,00025 ; 5,3 ; -3,7 ; 9,7 ; -2,1 ; -7,1 ; -3 ; 0,55 ; NABCHFDE2120 ; C2CDEFEAfC5fdC8Dfea8ECFe2bccad7c6E3DDADffaeB529Ce75CBA28A9eD9ccd ; < CBYLN2RPT20f9onrtqx7KYhr06yP7Lf4k15KqwPp58knhKon8339n86L3A3Mh49X > >										24
											
//	  < CALLS ; 36M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 36M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABEUR										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; f4AddAd7aaAc515DCFAD905Cc3Efa08cfEae8EF5Ae1F63Dfe7bcDcf23bf77ADA ; < to6Od76JFlu03IYs1nj527h6uJlLLYTm5282x757SG997ww449E1a0tZHpw467da > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,00026609499864 ; -1 ; -0,00025 ; 0,00025 ; -6 ; -0,2 ; 1,6 ; -5,3 ; -3,6 ; 6,5 ; -0,06 ; NABEUR26JA19 ; f2C9dDE6b26A4bADEe4cc9Ef2FedAbEDabEa2BDBBFB21Fdd3C0f0edBFDca2Bb6 ; < 92J4ya37SZ0k76941BELR494r7qJeZg8C18qkS6mWlQ8bA5JwIH780AjpGZvxEtr > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,00074045449057 ; -1 ; -0,00025 ; 0,00025 ; 2,5 ; 3,6 ; 6,8 ; -8,6 ; -3,6 ; -7,6 ; 0,53 ; NABEURMA1936 ; 76CADAa0dCAD4f9e28BC74fE36eeFBEfE0c9CACE2b9776e55b0FBF5Ae847c9e6 ; < aDwt79SowQO5Jght4jMa4q9HbJ4Dxg3sCHyK6E5K38KNkMxxUw4RYF1B9J4eQ8LM > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,00137633990192 ; -1 ; -0,00025 ; 0,00025 ; 9,4 ; 7,9 ; 9,5 ; -8,5 ; -0,4 ; -7,6 ; 0,86 ; NABEURMA1934 ; 7fdCCd9bCcFdFA6cDA36ACD1EBFC173C70Fb9BfE9BBe952efbAADfb890622c2a ; < jO618x9ekJ1Lv1XC0A6q53yEWscZpiC7RB7da97L32bR5r6aIPm75DW7CWFBYA06 > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,002286230351 ; -1 ; -0,00025 ; 0,00025 ; 7,4 ; 4,8 ; 7,4 ; 5,6 ; 9 ; -8,7 ; 0,63 ; NABEURJU1956 ; adeb1be4CaC7CEC2FF6B8Def4B04EdAebEa0ab08Ee40F632ceEDad3Ae3770C7f ; < h9KiF3XQO1ce6oS1qkKn5dfEBRA2YR35c1P159gH27JPFu8i0HHQP8q3P1ZZ23eq > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,00336860738833 ; -1 ; -0,00025 ; 0,00025 ; 7 ; -8,3 ; 0,7 ; -1,5 ; 4,5 ; -8,1 ; -0,59 ; NABEURSE1946 ; CaE2261bbaf5cBECBFdCfB4Ad2Ea2473fFd8BC7bD0f8F73dFACccECC1DBDc6af ; < zsRU1zArGtZiy309z3k2C00WdGVErZ7O1t9W7FO7r3BOP9E620ldq9GP588bB5I8 > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,00464410935353 ; -1 ; -0,00025 ; 0,00025 ; 5,4 ; -8 ; 7,6 ; -1 ; 4,6 ; 1,2 ; -0,37 ; NABEURDE1943 ; 3D9e234BA02FAcb1DaF3CaBCFE91361BD1afdC9eD42abc453C4b2fAACd8409E0 ; < gpAZ47OvET1pRg0pQD87yqF84pUinmn5pVX73kshaPTMK3JqV54qC2Kaz9Q1cWwk > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,00601301197941 ; -1 ; -0,00025 ; 0,00025 ; -8 ; -9,1 ; -9,1 ; 2,3 ; 7 ; -9,7 ; 0,13 ; NABEURJA2055 ; daacACddFE3abFf12fafdcA7eDbE4aD49fDd4303a6b6bF2fAa8F356EDA38bfA4 ; < OlTW7ZyeVHBImUL1ezKLrK2q52204WYB2JSG010aD0q96AGc71pbJT4LknHOVU3t > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,00770107464382 ; -1 ; -0,00025 ; 0,00025 ; 7,3 ; -4 ; -5,2 ; 9,8 ; -5 ; -3,8 ; -0,64 ; NABEURMA2056 ; 1AEbCbe8FdB51bFd1fA455eFcBAB42FdFCffEebb0eF2fAC8BC554Ab08d0Eed1A ; < J50jNaOyxAQ1Omzu54ljn1NWB5XwUfw4XRf8MPavU6ux411J3t8o2xTg2dfYe3GP > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,00951031593822 ; -1 ; -0,00025 ; 0,00025 ; -7,1 ; -6,6 ; 0,3 ; 3,6 ; 6,2 ; 3,2 ; 0,96 ; NABEURMA2075 ; FbdFB31EDa92e4ACfa6BddcFFdAbbDe5AEBAefF333Cb8BaDaebAd1afaCA1Bdef ; < C4T3SI0er22kd1B9Y2xZ278uMS9ODlZ1ZM5219wwxtKO2OfmW013g2ww084GE67H > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,01152216877121 ; -1 ; -0,00025 ; 0,00025 ; -6,6 ; 9,2 ; -0,7 ; 9,9 ; -9,4 ; -2,6 ; -0,7 ; NABEURJU2059 ; A0fac1445fdb0efdAd67F5Ecb1ddfaCa4a5d8e6feaF607FbAd6DfDdaA8f3ec83 ; < 9t2I3N9CkAxA1waJ8ab1ELsq0mf89UK09bju9P9f6K61644nS7N6N4iwsVmgmD3k > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,01378335391844 ; -1 ; -0,00025 ; 0,00025 ; -3 ; 5,2 ; 7 ; -4,3 ; 3,6 ; 1,8 ; -0,59 ; NABEURSE2053 ; EaEdBEAe86B8cB9C2a751ffdfFdf3Ce5EAf5D43eFBc41BfB3CFbCc8ecbbfeFbc ; < 6w6EFb938Y06481OxD1H2XU04EW50N34ure7877Jld7KRIo4SeiJLHZMO61fP06B > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,0162438061184 ; -1 ; -0,00025 ; 0,00025 ; -7,7 ; -5,3 ; -4,3 ; 5,5 ; -5,5 ; -2,8 ; -0,75 ; NABEURDE2057 ; DbEaec74bf0cbB8CF2A6E8b0C1dE278c8B1fE1bf5bFcFeFdB1E2D8a97feDd8ee ; < no7gRb56drzRvI6b0a6Z96j3ztslj3j91kB539IP85Eut44t8ojq3Ybm8p0993FW > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,01890292514512 ; -1 ; -0,00025 ; 0,00025 ; -2,5 ; -8,7 ; -2,6 ; -8,1 ; 3,3 ; 0 ; -0,2 ; NABEURJA2184 ; e8a1C0Fb1cB82AFecfAeF633ce61C4fF27dd1dbA9a6a7BCCe0EDacb9BBf9fCC9 ; < yrSx9HtjYOKzdDaGEWkgozy66NT58969kek0S4zf2M1107g3QD1cgc7hC6AU6pQY > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,02188145745659 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; -1,2 ; 0,8 ; 7,5 ; -9,7 ; -7 ; 0,25 ; NABEURMA2199 ; eed7645f2aEFB2dDA36E6db1bdAcD7e1a3e02F1c9909Ad58f19771d8faBa9bB7 ; < 8p38h80WchAdR6NnkqZ3zt7yzBG154moJMa4X2RA7ST6HE5P2OfNO3gVOX2F7y1a > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,02507276867486 ; -1 ; -0,00025 ; 0,00025 ; -8,3 ; -2,8 ; -7,8 ; 2,9 ; 0,8 ; -9,8 ; 0,87 ; NABEURMA2196 ; A70eE4aa2c95BDFc8c6a3b2A65c8E0f8AEafaab8aFecdCdE1bFf4Ce3f2e4fDCA ; < 1X5SWJzdl11a96EYU91pO1QrGgGY3kP71T02a13XHhm7t21Y8B86Q5266x4w336K > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,02853312880934 ; -1 ; -0,00025 ; 0,00025 ; -4,4 ; -9,2 ; -7,9 ; 1,8 ; 9,6 ; -6,9 ; -0,73 ; NABEURJU2190 ; fACf6b8d0efa5B1dcD50e8Fd7EcEf1F7BdBeBcca6cef79DbbD422b83DFBF6698 ; < 6PrBR9h1YW7g9Yqe7O057q7eT0vYzVo60H2GIzTs7gqq82r0JnqP9t6wD2shDNxF > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,03216540423907 ; -1 ; -0,00025 ; 0,00025 ; 6,1 ; -9 ; -2,8 ; 2,8 ; -9,6 ; -7 ; 0,56 ; NABEURSE2158 ; AdDfB4A3dddce7dBfdE8bA8Ce4E07f9fF63CaAFEcDCE76FbecA7B88eE0a7bFB4 ; < 456vbWlP96q6h6MPmEBLLWUKnb02lVUJVwwZOB8f8z56UTquQ6E1U6pUy41sg2nt > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,03597754487675 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; -6 ; -0,2 ; -6,6 ; -6,4 ; 1,1 ; -0,55 ; NABEURDE2189 ; D9e9FD3bA280a8Dd0bB95Fe0f05FaBFdA7abbFFb5ffdAAea8f103ecE2eEE78eC ; < DfeBeS81E21W5yn254eb8gYprE20i4T1MfUqTa057f2NQ675lH7Ljig651a0EM3r > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,0401651925952 ; -1 ; -0,00025 ; 0,00025 ; -8,9 ; 4,6 ; 6,6 ; 8,4 ; 9,9 ; -2,5 ; -0,67 ; NABEURJA2173 ; b02AFdeefB6f77BfaEfBb71ebFFfffB7bfd0a9f30b6b9Cce78Dd00aAfcEBce79 ; < Q86Hg9XX45JeiVng3NUzjhkpibSMok88Sw6Qk1u03672778af0QLtL34mtXtY69O > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,04460164060659 ; -1 ; -0,00025 ; 0,00025 ; 9,3 ; 5,9 ; 3,3 ; -5 ; 8,2 ; -5,5 ; -0,25 ; NABEURMA2182 ; dbb48caFae7cD5Fb2b1fEafc19aDdBfaeea9Dc324cea8EFC8d395A824f3DBad6 ; < rcXO3b06fE3bg0cnPWy3EDNYrs418LBSBp2Lf4vpvQ5jIBBc3pKHK1526CrO0biB > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,04924082169297 ; -1 ; -0,00025 ; 0,00025 ; 2,4 ; -6,8 ; -2 ; 1,6 ; 3,5 ; 5,1 ; -0,21 ; NABEURMA2171 ; EbDf1604c1A4EaBC9fe6ecAFdCEE4deFBfEEea9BFEf5ec4FeD96Bc70c8dD5a58 ; < 5reS9QDU2Jt1TLzEz25nUf4pS91q5mDJe334VhpwHJ6GMeZ1q2a82nZCX21OZb69 > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,05396671459775 ; -1 ; -0,00025 ; 0,00025 ; 9,1 ; 4,9 ; -7,3 ; -0,3 ; -2,8 ; 7,9 ; -0,97 ; NABEURJU2115 ; b734B8eDa418DE267bfa010E466dfe3c994BC3b5C890E21dc26b7e1a9cD7B83a ; < 5q1Gf021EhEX5K4P9hXmUOFXRkiDBxeJi2ApCpKoW94u2RJG4BI7Kk0B4r9KUVLQ > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,05907861835916 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -7,6 ; 3,7 ; 0,5 ; -4 ; -1,1 ; 0,62 ; NABEURSE2178 ; 917dAaAb2ABADFCF8fcddeE7AA9Eed37f07f5159adDb093BeFC8e4e8e60BeEaB ; < 1D833wPG6Tp5Ufoj8xfx617969Mx5mmt80YOqi6V7523t8DxvmC920t42e8iqm5v > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,0643160268966 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; -2,4 ; -0,2 ; 2 ; 1 ; -4,9 ; -0,07 ; NABEURDE2157 ; e82cf2220271bE9dd5D66fCfd329FFc1B9F0fDEcE3faBE8C9eDCE2BeE2cA2C1a ; < z40RCxvgSGy147H2c8dHcfNLh821rBvn6a8lEReP547loOWX3e15xL5D5R850KvN > >										24
											
//	  < CALLS ; 3M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 3M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABEUR										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; f4AddAd7aaAc515DCFAD905Cc3Efa08cfEae8EF5Ae1F63Dfe7bcDcf23bf77ADA ; < to6Od76JFlu03IYs1nj527h6uJlLLYTm5282x757SG997ww449E1a0tZHpw467da > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,00026609499864 ; -1 ; -0,00025 ; 0,00025 ; -6 ; -0,2 ; 1,6 ; -5,3 ; -3,6 ; 6,5 ; -0,06 ; NABEUR26JA19 ; f2C9dDE6b26A4bADEe4cc9Ef2FedAbEDabEa2BDBBFB21Fdd3C0f0edBFDca2Bb6 ; < 92J4ya37SZ0k76941BELR494r7qJeZg8C18qkS6mWlQ8bA5JwIH780AjpGZvxEtr > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,00074045449057 ; -1 ; -0,00025 ; 0,00025 ; 2,5 ; 3,6 ; 6,8 ; -8,6 ; -3,6 ; -7,6 ; 0,53 ; NABEURMA1936 ; 76CADAa0dCAD4f9e28BC74fE36eeFBEfE0c9CACE2b9776e55b0FBF5Ae847c9e6 ; < aDwt79SowQO5Jght4jMa4q9HbJ4Dxg3sCHyK6E5K38KNkMxxUw4RYF1B9J4eQ8LM > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,00137633990192 ; -1 ; -0,00025 ; 0,00025 ; 9,4 ; 7,9 ; 9,5 ; -8,5 ; -0,4 ; -7,6 ; 0,86 ; NABEURMA1934 ; 7fdCCd9bCcFdFA6cDA36ACD1EBFC173C70Fb9BfE9BBe952efbAADfb890622c2a ; < jO618x9ekJ1Lv1XC0A6q53yEWscZpiC7RB7da97L32bR5r6aIPm75DW7CWFBYA06 > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,002286230351 ; -1 ; -0,00025 ; 0,00025 ; 7,4 ; 4,8 ; 7,4 ; 5,6 ; 9 ; -8,7 ; 0,63 ; NABEURJU1956 ; adeb1be4CaC7CEC2FF6B8Def4B04EdAebEa0ab08Ee40F632ceEDad3Ae3770C7f ; < h9KiF3XQO1ce6oS1qkKn5dfEBRA2YR35c1P159gH27JPFu8i0HHQP8q3P1ZZ23eq > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,00336860738833 ; -1 ; -0,00025 ; 0,00025 ; 7 ; -8,3 ; 0,7 ; -1,5 ; 4,5 ; -8,1 ; -0,59 ; NABEURSE1946 ; CaE2261bbaf5cBECBFdCfB4Ad2Ea2473fFd8BC7bD0f8F73dFACccECC1DBDc6af ; < zsRU1zArGtZiy309z3k2C00WdGVErZ7O1t9W7FO7r3BOP9E620ldq9GP588bB5I8 > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,00464410935353 ; -1 ; -0,00025 ; 0,00025 ; 5,4 ; -8 ; 7,6 ; -1 ; 4,6 ; 1,2 ; -0,37 ; NABEURDE1943 ; 3D9e234BA02FAcb1DaF3CaBCFE91361BD1afdC9eD42abc453C4b2fAACd8409E0 ; < gpAZ47OvET1pRg0pQD87yqF84pUinmn5pVX73kshaPTMK3JqV54qC2Kaz9Q1cWwk > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,00601301197941 ; -1 ; -0,00025 ; 0,00025 ; -8 ; -9,1 ; -9,1 ; 2,3 ; 7 ; -9,7 ; 0,13 ; NABEURJA2055 ; daacACddFE3abFf12fafdcA7eDbE4aD49fDd4303a6b6bF2fAa8F356EDA38bfA4 ; < OlTW7ZyeVHBImUL1ezKLrK2q52204WYB2JSG010aD0q96AGc71pbJT4LknHOVU3t > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,00770107464382 ; -1 ; -0,00025 ; 0,00025 ; 7,3 ; -4 ; -5,2 ; 9,8 ; -5 ; -3,8 ; -0,64 ; NABEURMA2056 ; 1AEbCbe8FdB51bFd1fA455eFcBAB42FdFCffEebb0eF2fAC8BC554Ab08d0Eed1A ; < J50jNaOyxAQ1Omzu54ljn1NWB5XwUfw4XRf8MPavU6ux411J3t8o2xTg2dfYe3GP > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,00951031593822 ; -1 ; -0,00025 ; 0,00025 ; -7,1 ; -6,6 ; 0,3 ; 3,6 ; 6,2 ; 3,2 ; 0,96 ; NABEURMA2075 ; FbdFB31EDa92e4ACfa6BddcFFdAbbDe5AEBAefF333Cb8BaDaebAd1afaCA1Bdef ; < C4T3SI0er22kd1B9Y2xZ278uMS9ODlZ1ZM5219wwxtKO2OfmW013g2ww084GE67H > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,01152216877121 ; -1 ; -0,00025 ; 0,00025 ; -6,6 ; 9,2 ; -0,7 ; 9,9 ; -9,4 ; -2,6 ; -0,7 ; NABEURJU2059 ; A0fac1445fdb0efdAd67F5Ecb1ddfaCa4a5d8e6feaF607FbAd6DfDdaA8f3ec83 ; < 9t2I3N9CkAxA1waJ8ab1ELsq0mf89UK09bju9P9f6K61644nS7N6N4iwsVmgmD3k > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,01378335391844 ; -1 ; -0,00025 ; 0,00025 ; -3 ; 5,2 ; 7 ; -4,3 ; 3,6 ; 1,8 ; -0,59 ; NABEURSE2053 ; EaEdBEAe86B8cB9C2a751ffdfFdf3Ce5EAf5D43eFBc41BfB3CFbCc8ecbbfeFbc ; < 6w6EFb938Y06481OxD1H2XU04EW50N34ure7877Jld7KRIo4SeiJLHZMO61fP06B > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,0162438061184 ; -1 ; -0,00025 ; 0,00025 ; -7,7 ; -5,3 ; -4,3 ; 5,5 ; -5,5 ; -2,8 ; -0,75 ; NABEURDE2057 ; DbEaec74bf0cbB8CF2A6E8b0C1dE278c8B1fE1bf5bFcFeFdB1E2D8a97feDd8ee ; < no7gRb56drzRvI6b0a6Z96j3ztslj3j91kB539IP85Eut44t8ojq3Ybm8p0993FW > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,01890292514512 ; -1 ; -0,00025 ; 0,00025 ; -2,5 ; -8,7 ; -2,6 ; -8,1 ; 3,3 ; 0 ; -0,2 ; NABEURJA2184 ; e8a1C0Fb1cB82AFecfAeF633ce61C4fF27dd1dbA9a6a7BCCe0EDacb9BBf9fCC9 ; < yrSx9HtjYOKzdDaGEWkgozy66NT58969kek0S4zf2M1107g3QD1cgc7hC6AU6pQY > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,02188145745659 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; -1,2 ; 0,8 ; 7,5 ; -9,7 ; -7 ; 0,25 ; NABEURMA2199 ; eed7645f2aEFB2dDA36E6db1bdAcD7e1a3e02F1c9909Ad58f19771d8faBa9bB7 ; < 8p38h80WchAdR6NnkqZ3zt7yzBG154moJMa4X2RA7ST6HE5P2OfNO3gVOX2F7y1a > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,02507276867486 ; -1 ; -0,00025 ; 0,00025 ; -8,3 ; -2,8 ; -7,8 ; 2,9 ; 0,8 ; -9,8 ; 0,87 ; NABEURMA2196 ; A70eE4aa2c95BDFc8c6a3b2A65c8E0f8AEafaab8aFecdCdE1bFf4Ce3f2e4fDCA ; < 1X5SWJzdl11a96EYU91pO1QrGgGY3kP71T02a13XHhm7t21Y8B86Q5266x4w336K > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,02853312880934 ; -1 ; -0,00025 ; 0,00025 ; -4,4 ; -9,2 ; -7,9 ; 1,8 ; 9,6 ; -6,9 ; -0,73 ; NABEURJU2190 ; fACf6b8d0efa5B1dcD50e8Fd7EcEf1F7BdBeBcca6cef79DbbD422b83DFBF6698 ; < 6PrBR9h1YW7g9Yqe7O057q7eT0vYzVo60H2GIzTs7gqq82r0JnqP9t6wD2shDNxF > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,03216540423907 ; -1 ; -0,00025 ; 0,00025 ; 6,1 ; -9 ; -2,8 ; 2,8 ; -9,6 ; -7 ; 0,56 ; NABEURSE2158 ; AdDfB4A3dddce7dBfdE8bA8Ce4E07f9fF63CaAFEcDCE76FbecA7B88eE0a7bFB4 ; < 456vbWlP96q6h6MPmEBLLWUKnb02lVUJVwwZOB8f8z56UTquQ6E1U6pUy41sg2nt > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,03597754487675 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; -6 ; -0,2 ; -6,6 ; -6,4 ; 1,1 ; -0,55 ; NABEURDE2189 ; D9e9FD3bA280a8Dd0bB95Fe0f05FaBFdA7abbFFb5ffdAAea8f103ecE2eEE78eC ; < DfeBeS81E21W5yn254eb8gYprE20i4T1MfUqTa057f2NQ675lH7Ljig651a0EM3r > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,0401651925952 ; -1 ; -0,00025 ; 0,00025 ; -8,9 ; 4,6 ; 6,6 ; 8,4 ; 9,9 ; -2,5 ; -0,67 ; NABEURJA2173 ; b02AFdeefB6f77BfaEfBb71ebFFfffB7bfd0a9f30b6b9Cce78Dd00aAfcEBce79 ; < Q86Hg9XX45JeiVng3NUzjhkpibSMok88Sw6Qk1u03672778af0QLtL34mtXtY69O > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,04460164060659 ; -1 ; -0,00025 ; 0,00025 ; 9,3 ; 5,9 ; 3,3 ; -5 ; 8,2 ; -5,5 ; -0,25 ; NABEURMA2182 ; dbb48caFae7cD5Fb2b1fEafc19aDdBfaeea9Dc324cea8EFC8d395A824f3DBad6 ; < rcXO3b06fE3bg0cnPWy3EDNYrs418LBSBp2Lf4vpvQ5jIBBc3pKHK1526CrO0biB > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,04924082169297 ; -1 ; -0,00025 ; 0,00025 ; 2,4 ; -6,8 ; -2 ; 1,6 ; 3,5 ; 5,1 ; -0,21 ; NABEURMA2171 ; EbDf1604c1A4EaBC9fe6ecAFdCEE4deFBfEEea9BFEf5ec4FeD96Bc70c8dD5a58 ; < 5reS9QDU2Jt1TLzEz25nUf4pS91q5mDJe334VhpwHJ6GMeZ1q2a82nZCX21OZb69 > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,05396671459775 ; -1 ; -0,00025 ; 0,00025 ; 9,1 ; 4,9 ; -7,3 ; -0,3 ; -2,8 ; 7,9 ; -0,97 ; NABEURJU2115 ; b734B8eDa418DE267bfa010E466dfe3c994BC3b5C890E21dc26b7e1a9cD7B83a ; < 5q1Gf021EhEX5K4P9hXmUOFXRkiDBxeJi2ApCpKoW94u2RJG4BI7Kk0B4r9KUVLQ > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,05907861835916 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -7,6 ; 3,7 ; 0,5 ; -4 ; -1,1 ; 0,62 ; NABEURSE2178 ; 917dAaAb2ABADFCF8fcddeE7AA9Eed37f07f5159adDb093BeFC8e4e8e60BeEaB ; < 1D833wPG6Tp5Ufoj8xfx617969Mx5mmt80YOqi6V7523t8DxvmC920t42e8iqm5v > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,0643160268966 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; -2,4 ; -0,2 ; 2 ; 1 ; -4,9 ; -0,07 ; NABEURDE2157 ; e82cf2220271bE9dd5D66fCfd329FFc1B9F0fDEcE3faBE8C9eDCE2BeE2cA2C1a ; < z40RCxvgSGy147H2c8dHcfNLh821rBvn6a8lEReP547loOWX3e15xL5D5R850KvN > >										24
											
//	  < CALLS ; 6M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 6M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABEUR										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; f4AddAd7aaAc515DCFAD905Cc3Efa08cfEae8EF5Ae1F63Dfe7bcDcf23bf77ADA ; < to6Od76JFlu03IYs1nj527h6uJlLLYTm5282x757SG997ww449E1a0tZHpw467da > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,00026609499864 ; -1 ; -0,00025 ; 0,00025 ; -6 ; -0,2 ; 1,6 ; -5,3 ; -3,6 ; 6,5 ; -0,06 ; NABEUR26JA19 ; f2C9dDE6b26A4bADEe4cc9Ef2FedAbEDabEa2BDBBFB21Fdd3C0f0edBFDca2Bb6 ; < 92J4ya37SZ0k76941BELR494r7qJeZg8C18qkS6mWlQ8bA5JwIH780AjpGZvxEtr > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,00074045449057 ; -1 ; -0,00025 ; 0,00025 ; 2,5 ; 3,6 ; 6,8 ; -8,6 ; -3,6 ; -7,6 ; 0,53 ; NABEURMA1936 ; 76CADAa0dCAD4f9e28BC74fE36eeFBEfE0c9CACE2b9776e55b0FBF5Ae847c9e6 ; < aDwt79SowQO5Jght4jMa4q9HbJ4Dxg3sCHyK6E5K38KNkMxxUw4RYF1B9J4eQ8LM > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,00137633990192 ; -1 ; -0,00025 ; 0,00025 ; 9,4 ; 7,9 ; 9,5 ; -8,5 ; -0,4 ; -7,6 ; 0,86 ; NABEURMA1934 ; 7fdCCd9bCcFdFA6cDA36ACD1EBFC173C70Fb9BfE9BBe952efbAADfb890622c2a ; < jO618x9ekJ1Lv1XC0A6q53yEWscZpiC7RB7da97L32bR5r6aIPm75DW7CWFBYA06 > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,002286230351 ; -1 ; -0,00025 ; 0,00025 ; 7,4 ; 4,8 ; 7,4 ; 5,6 ; 9 ; -8,7 ; 0,63 ; NABEURJU1956 ; adeb1be4CaC7CEC2FF6B8Def4B04EdAebEa0ab08Ee40F632ceEDad3Ae3770C7f ; < h9KiF3XQO1ce6oS1qkKn5dfEBRA2YR35c1P159gH27JPFu8i0HHQP8q3P1ZZ23eq > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,00336860738833 ; -1 ; -0,00025 ; 0,00025 ; 7 ; -8,3 ; 0,7 ; -1,5 ; 4,5 ; -8,1 ; -0,59 ; NABEURSE1946 ; CaE2261bbaf5cBECBFdCfB4Ad2Ea2473fFd8BC7bD0f8F73dFACccECC1DBDc6af ; < zsRU1zArGtZiy309z3k2C00WdGVErZ7O1t9W7FO7r3BOP9E620ldq9GP588bB5I8 > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,00464410935353 ; -1 ; -0,00025 ; 0,00025 ; 5,4 ; -8 ; 7,6 ; -1 ; 4,6 ; 1,2 ; -0,37 ; NABEURDE1943 ; 3D9e234BA02FAcb1DaF3CaBCFE91361BD1afdC9eD42abc453C4b2fAACd8409E0 ; < gpAZ47OvET1pRg0pQD87yqF84pUinmn5pVX73kshaPTMK3JqV54qC2Kaz9Q1cWwk > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,00601301197941 ; -1 ; -0,00025 ; 0,00025 ; -8 ; -9,1 ; -9,1 ; 2,3 ; 7 ; -9,7 ; 0,13 ; NABEURJA2055 ; daacACddFE3abFf12fafdcA7eDbE4aD49fDd4303a6b6bF2fAa8F356EDA38bfA4 ; < OlTW7ZyeVHBImUL1ezKLrK2q52204WYB2JSG010aD0q96AGc71pbJT4LknHOVU3t > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,00770107464382 ; -1 ; -0,00025 ; 0,00025 ; 7,3 ; -4 ; -5,2 ; 9,8 ; -5 ; -3,8 ; -0,64 ; NABEURMA2056 ; 1AEbCbe8FdB51bFd1fA455eFcBAB42FdFCffEebb0eF2fAC8BC554Ab08d0Eed1A ; < J50jNaOyxAQ1Omzu54ljn1NWB5XwUfw4XRf8MPavU6ux411J3t8o2xTg2dfYe3GP > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,00951031593822 ; -1 ; -0,00025 ; 0,00025 ; -7,1 ; -6,6 ; 0,3 ; 3,6 ; 6,2 ; 3,2 ; 0,96 ; NABEURMA2075 ; FbdFB31EDa92e4ACfa6BddcFFdAbbDe5AEBAefF333Cb8BaDaebAd1afaCA1Bdef ; < C4T3SI0er22kd1B9Y2xZ278uMS9ODlZ1ZM5219wwxtKO2OfmW013g2ww084GE67H > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,01152216877121 ; -1 ; -0,00025 ; 0,00025 ; -6,6 ; 9,2 ; -0,7 ; 9,9 ; -9,4 ; -2,6 ; -0,7 ; NABEURJU2059 ; A0fac1445fdb0efdAd67F5Ecb1ddfaCa4a5d8e6feaF607FbAd6DfDdaA8f3ec83 ; < 9t2I3N9CkAxA1waJ8ab1ELsq0mf89UK09bju9P9f6K61644nS7N6N4iwsVmgmD3k > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,01378335391844 ; -1 ; -0,00025 ; 0,00025 ; -3 ; 5,2 ; 7 ; -4,3 ; 3,6 ; 1,8 ; -0,59 ; NABEURSE2053 ; EaEdBEAe86B8cB9C2a751ffdfFdf3Ce5EAf5D43eFBc41BfB3CFbCc8ecbbfeFbc ; < 6w6EFb938Y06481OxD1H2XU04EW50N34ure7877Jld7KRIo4SeiJLHZMO61fP06B > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,0162438061184 ; -1 ; -0,00025 ; 0,00025 ; -7,7 ; -5,3 ; -4,3 ; 5,5 ; -5,5 ; -2,8 ; -0,75 ; NABEURDE2057 ; DbEaec74bf0cbB8CF2A6E8b0C1dE278c8B1fE1bf5bFcFeFdB1E2D8a97feDd8ee ; < no7gRb56drzRvI6b0a6Z96j3ztslj3j91kB539IP85Eut44t8ojq3Ybm8p0993FW > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,01890292514512 ; -1 ; -0,00025 ; 0,00025 ; -2,5 ; -8,7 ; -2,6 ; -8,1 ; 3,3 ; 0 ; -0,2 ; NABEURJA2184 ; e8a1C0Fb1cB82AFecfAeF633ce61C4fF27dd1dbA9a6a7BCCe0EDacb9BBf9fCC9 ; < yrSx9HtjYOKzdDaGEWkgozy66NT58969kek0S4zf2M1107g3QD1cgc7hC6AU6pQY > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,02188145745659 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; -1,2 ; 0,8 ; 7,5 ; -9,7 ; -7 ; 0,25 ; NABEURMA2199 ; eed7645f2aEFB2dDA36E6db1bdAcD7e1a3e02F1c9909Ad58f19771d8faBa9bB7 ; < 8p38h80WchAdR6NnkqZ3zt7yzBG154moJMa4X2RA7ST6HE5P2OfNO3gVOX2F7y1a > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,02507276867486 ; -1 ; -0,00025 ; 0,00025 ; -8,3 ; -2,8 ; -7,8 ; 2,9 ; 0,8 ; -9,8 ; 0,87 ; NABEURMA2196 ; A70eE4aa2c95BDFc8c6a3b2A65c8E0f8AEafaab8aFecdCdE1bFf4Ce3f2e4fDCA ; < 1X5SWJzdl11a96EYU91pO1QrGgGY3kP71T02a13XHhm7t21Y8B86Q5266x4w336K > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,02853312880934 ; -1 ; -0,00025 ; 0,00025 ; -4,4 ; -9,2 ; -7,9 ; 1,8 ; 9,6 ; -6,9 ; -0,73 ; NABEURJU2190 ; fACf6b8d0efa5B1dcD50e8Fd7EcEf1F7BdBeBcca6cef79DbbD422b83DFBF6698 ; < 6PrBR9h1YW7g9Yqe7O057q7eT0vYzVo60H2GIzTs7gqq82r0JnqP9t6wD2shDNxF > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,03216540423907 ; -1 ; -0,00025 ; 0,00025 ; 6,1 ; -9 ; -2,8 ; 2,8 ; -9,6 ; -7 ; 0,56 ; NABEURSE2158 ; AdDfB4A3dddce7dBfdE8bA8Ce4E07f9fF63CaAFEcDCE76FbecA7B88eE0a7bFB4 ; < 456vbWlP96q6h6MPmEBLLWUKnb02lVUJVwwZOB8f8z56UTquQ6E1U6pUy41sg2nt > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,03597754487675 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; -6 ; -0,2 ; -6,6 ; -6,4 ; 1,1 ; -0,55 ; NABEURDE2189 ; D9e9FD3bA280a8Dd0bB95Fe0f05FaBFdA7abbFFb5ffdAAea8f103ecE2eEE78eC ; < DfeBeS81E21W5yn254eb8gYprE20i4T1MfUqTa057f2NQ675lH7Ljig651a0EM3r > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,0401651925952 ; -1 ; -0,00025 ; 0,00025 ; -8,9 ; 4,6 ; 6,6 ; 8,4 ; 9,9 ; -2,5 ; -0,67 ; NABEURJA2173 ; b02AFdeefB6f77BfaEfBb71ebFFfffB7bfd0a9f30b6b9Cce78Dd00aAfcEBce79 ; < Q86Hg9XX45JeiVng3NUzjhkpibSMok88Sw6Qk1u03672778af0QLtL34mtXtY69O > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,04460164060659 ; -1 ; -0,00025 ; 0,00025 ; 9,3 ; 5,9 ; 3,3 ; -5 ; 8,2 ; -5,5 ; -0,25 ; NABEURMA2182 ; dbb48caFae7cD5Fb2b1fEafc19aDdBfaeea9Dc324cea8EFC8d395A824f3DBad6 ; < rcXO3b06fE3bg0cnPWy3EDNYrs418LBSBp2Lf4vpvQ5jIBBc3pKHK1526CrO0biB > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,04924082169297 ; -1 ; -0,00025 ; 0,00025 ; 2,4 ; -6,8 ; -2 ; 1,6 ; 3,5 ; 5,1 ; -0,21 ; NABEURMA2171 ; EbDf1604c1A4EaBC9fe6ecAFdCEE4deFBfEEea9BFEf5ec4FeD96Bc70c8dD5a58 ; < 5reS9QDU2Jt1TLzEz25nUf4pS91q5mDJe334VhpwHJ6GMeZ1q2a82nZCX21OZb69 > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,05396671459775 ; -1 ; -0,00025 ; 0,00025 ; 9,1 ; 4,9 ; -7,3 ; -0,3 ; -2,8 ; 7,9 ; -0,97 ; NABEURJU2115 ; b734B8eDa418DE267bfa010E466dfe3c994BC3b5C890E21dc26b7e1a9cD7B83a ; < 5q1Gf021EhEX5K4P9hXmUOFXRkiDBxeJi2ApCpKoW94u2RJG4BI7Kk0B4r9KUVLQ > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,05907861835916 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -7,6 ; 3,7 ; 0,5 ; -4 ; -1,1 ; 0,62 ; NABEURSE2178 ; 917dAaAb2ABADFCF8fcddeE7AA9Eed37f07f5159adDb093BeFC8e4e8e60BeEaB ; < 1D833wPG6Tp5Ufoj8xfx617969Mx5mmt80YOqi6V7523t8DxvmC920t42e8iqm5v > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,0643160268966 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; -2,4 ; -0,2 ; 2 ; 1 ; -4,9 ; -0,07 ; NABEURDE2157 ; e82cf2220271bE9dd5D66fCfd329FFc1B9F0fDEcE3faBE8C9eDCE2BeE2cA2C1a ; < z40RCxvgSGy147H2c8dHcfNLh821rBvn6a8lEReP547loOWX3e15xL5D5R850KvN > >										24
											
//	  < CALLS ; 12M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 12M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABEUR										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; f4AddAd7aaAc515DCFAD905Cc3Efa08cfEae8EF5Ae1F63Dfe7bcDcf23bf77ADA ; < to6Od76JFlu03IYs1nj527h6uJlLLYTm5282x757SG997ww449E1a0tZHpw467da > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,00026609499864 ; -1 ; -0,00025 ; 0,00025 ; -6 ; -0,2 ; 1,6 ; -5,3 ; -3,6 ; 6,5 ; -0,06 ; NABEUR26JA19 ; f2C9dDE6b26A4bADEe4cc9Ef2FedAbEDabEa2BDBBFB21Fdd3C0f0edBFDca2Bb6 ; < 92J4ya37SZ0k76941BELR494r7qJeZg8C18qkS6mWlQ8bA5JwIH780AjpGZvxEtr > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,00074045449057 ; -1 ; -0,00025 ; 0,00025 ; 2,5 ; 3,6 ; 6,8 ; -8,6 ; -3,6 ; -7,6 ; 0,53 ; NABEURMA1936 ; 76CADAa0dCAD4f9e28BC74fE36eeFBEfE0c9CACE2b9776e55b0FBF5Ae847c9e6 ; < aDwt79SowQO5Jght4jMa4q9HbJ4Dxg3sCHyK6E5K38KNkMxxUw4RYF1B9J4eQ8LM > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,00137633990192 ; -1 ; -0,00025 ; 0,00025 ; 9,4 ; 7,9 ; 9,5 ; -8,5 ; -0,4 ; -7,6 ; 0,86 ; NABEURMA1934 ; 7fdCCd9bCcFdFA6cDA36ACD1EBFC173C70Fb9BfE9BBe952efbAADfb890622c2a ; < jO618x9ekJ1Lv1XC0A6q53yEWscZpiC7RB7da97L32bR5r6aIPm75DW7CWFBYA06 > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,002286230351 ; -1 ; -0,00025 ; 0,00025 ; 7,4 ; 4,8 ; 7,4 ; 5,6 ; 9 ; -8,7 ; 0,63 ; NABEURJU1956 ; adeb1be4CaC7CEC2FF6B8Def4B04EdAebEa0ab08Ee40F632ceEDad3Ae3770C7f ; < h9KiF3XQO1ce6oS1qkKn5dfEBRA2YR35c1P159gH27JPFu8i0HHQP8q3P1ZZ23eq > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,00336860738833 ; -1 ; -0,00025 ; 0,00025 ; 7 ; -8,3 ; 0,7 ; -1,5 ; 4,5 ; -8,1 ; -0,59 ; NABEURSE1946 ; CaE2261bbaf5cBECBFdCfB4Ad2Ea2473fFd8BC7bD0f8F73dFACccECC1DBDc6af ; < zsRU1zArGtZiy309z3k2C00WdGVErZ7O1t9W7FO7r3BOP9E620ldq9GP588bB5I8 > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,00464410935353 ; -1 ; -0,00025 ; 0,00025 ; 5,4 ; -8 ; 7,6 ; -1 ; 4,6 ; 1,2 ; -0,37 ; NABEURDE1943 ; 3D9e234BA02FAcb1DaF3CaBCFE91361BD1afdC9eD42abc453C4b2fAACd8409E0 ; < gpAZ47OvET1pRg0pQD87yqF84pUinmn5pVX73kshaPTMK3JqV54qC2Kaz9Q1cWwk > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,00601301197941 ; -1 ; -0,00025 ; 0,00025 ; -8 ; -9,1 ; -9,1 ; 2,3 ; 7 ; -9,7 ; 0,13 ; NABEURJA2055 ; daacACddFE3abFf12fafdcA7eDbE4aD49fDd4303a6b6bF2fAa8F356EDA38bfA4 ; < OlTW7ZyeVHBImUL1ezKLrK2q52204WYB2JSG010aD0q96AGc71pbJT4LknHOVU3t > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,00770107464382 ; -1 ; -0,00025 ; 0,00025 ; 7,3 ; -4 ; -5,2 ; 9,8 ; -5 ; -3,8 ; -0,64 ; NABEURMA2056 ; 1AEbCbe8FdB51bFd1fA455eFcBAB42FdFCffEebb0eF2fAC8BC554Ab08d0Eed1A ; < J50jNaOyxAQ1Omzu54ljn1NWB5XwUfw4XRf8MPavU6ux411J3t8o2xTg2dfYe3GP > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,00951031593822 ; -1 ; -0,00025 ; 0,00025 ; -7,1 ; -6,6 ; 0,3 ; 3,6 ; 6,2 ; 3,2 ; 0,96 ; NABEURMA2075 ; FbdFB31EDa92e4ACfa6BddcFFdAbbDe5AEBAefF333Cb8BaDaebAd1afaCA1Bdef ; < C4T3SI0er22kd1B9Y2xZ278uMS9ODlZ1ZM5219wwxtKO2OfmW013g2ww084GE67H > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,01152216877121 ; -1 ; -0,00025 ; 0,00025 ; -6,6 ; 9,2 ; -0,7 ; 9,9 ; -9,4 ; -2,6 ; -0,7 ; NABEURJU2059 ; A0fac1445fdb0efdAd67F5Ecb1ddfaCa4a5d8e6feaF607FbAd6DfDdaA8f3ec83 ; < 9t2I3N9CkAxA1waJ8ab1ELsq0mf89UK09bju9P9f6K61644nS7N6N4iwsVmgmD3k > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,01378335391844 ; -1 ; -0,00025 ; 0,00025 ; -3 ; 5,2 ; 7 ; -4,3 ; 3,6 ; 1,8 ; -0,59 ; NABEURSE2053 ; EaEdBEAe86B8cB9C2a751ffdfFdf3Ce5EAf5D43eFBc41BfB3CFbCc8ecbbfeFbc ; < 6w6EFb938Y06481OxD1H2XU04EW50N34ure7877Jld7KRIo4SeiJLHZMO61fP06B > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,0162438061184 ; -1 ; -0,00025 ; 0,00025 ; -7,7 ; -5,3 ; -4,3 ; 5,5 ; -5,5 ; -2,8 ; -0,75 ; NABEURDE2057 ; DbEaec74bf0cbB8CF2A6E8b0C1dE278c8B1fE1bf5bFcFeFdB1E2D8a97feDd8ee ; < no7gRb56drzRvI6b0a6Z96j3ztslj3j91kB539IP85Eut44t8ojq3Ybm8p0993FW > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,01890292514512 ; -1 ; -0,00025 ; 0,00025 ; -2,5 ; -8,7 ; -2,6 ; -8,1 ; 3,3 ; 0 ; -0,2 ; NABEURJA2184 ; e8a1C0Fb1cB82AFecfAeF633ce61C4fF27dd1dbA9a6a7BCCe0EDacb9BBf9fCC9 ; < yrSx9HtjYOKzdDaGEWkgozy66NT58969kek0S4zf2M1107g3QD1cgc7hC6AU6pQY > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,02188145745659 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; -1,2 ; 0,8 ; 7,5 ; -9,7 ; -7 ; 0,25 ; NABEURMA2199 ; eed7645f2aEFB2dDA36E6db1bdAcD7e1a3e02F1c9909Ad58f19771d8faBa9bB7 ; < 8p38h80WchAdR6NnkqZ3zt7yzBG154moJMa4X2RA7ST6HE5P2OfNO3gVOX2F7y1a > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,02507276867486 ; -1 ; -0,00025 ; 0,00025 ; -8,3 ; -2,8 ; -7,8 ; 2,9 ; 0,8 ; -9,8 ; 0,87 ; NABEURMA2196 ; A70eE4aa2c95BDFc8c6a3b2A65c8E0f8AEafaab8aFecdCdE1bFf4Ce3f2e4fDCA ; < 1X5SWJzdl11a96EYU91pO1QrGgGY3kP71T02a13XHhm7t21Y8B86Q5266x4w336K > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,02853312880934 ; -1 ; -0,00025 ; 0,00025 ; -4,4 ; -9,2 ; -7,9 ; 1,8 ; 9,6 ; -6,9 ; -0,73 ; NABEURJU2190 ; fACf6b8d0efa5B1dcD50e8Fd7EcEf1F7BdBeBcca6cef79DbbD422b83DFBF6698 ; < 6PrBR9h1YW7g9Yqe7O057q7eT0vYzVo60H2GIzTs7gqq82r0JnqP9t6wD2shDNxF > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,03216540423907 ; -1 ; -0,00025 ; 0,00025 ; 6,1 ; -9 ; -2,8 ; 2,8 ; -9,6 ; -7 ; 0,56 ; NABEURSE2158 ; AdDfB4A3dddce7dBfdE8bA8Ce4E07f9fF63CaAFEcDCE76FbecA7B88eE0a7bFB4 ; < 456vbWlP96q6h6MPmEBLLWUKnb02lVUJVwwZOB8f8z56UTquQ6E1U6pUy41sg2nt > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,03597754487675 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; -6 ; -0,2 ; -6,6 ; -6,4 ; 1,1 ; -0,55 ; NABEURDE2189 ; D9e9FD3bA280a8Dd0bB95Fe0f05FaBFdA7abbFFb5ffdAAea8f103ecE2eEE78eC ; < DfeBeS81E21W5yn254eb8gYprE20i4T1MfUqTa057f2NQ675lH7Ljig651a0EM3r > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,0401651925952 ; -1 ; -0,00025 ; 0,00025 ; -8,9 ; 4,6 ; 6,6 ; 8,4 ; 9,9 ; -2,5 ; -0,67 ; NABEURJA2173 ; b02AFdeefB6f77BfaEfBb71ebFFfffB7bfd0a9f30b6b9Cce78Dd00aAfcEBce79 ; < Q86Hg9XX45JeiVng3NUzjhkpibSMok88Sw6Qk1u03672778af0QLtL34mtXtY69O > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,04460164060659 ; -1 ; -0,00025 ; 0,00025 ; 9,3 ; 5,9 ; 3,3 ; -5 ; 8,2 ; -5,5 ; -0,25 ; NABEURMA2182 ; dbb48caFae7cD5Fb2b1fEafc19aDdBfaeea9Dc324cea8EFC8d395A824f3DBad6 ; < rcXO3b06fE3bg0cnPWy3EDNYrs418LBSBp2Lf4vpvQ5jIBBc3pKHK1526CrO0biB > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,04924082169297 ; -1 ; -0,00025 ; 0,00025 ; 2,4 ; -6,8 ; -2 ; 1,6 ; 3,5 ; 5,1 ; -0,21 ; NABEURMA2171 ; EbDf1604c1A4EaBC9fe6ecAFdCEE4deFBfEEea9BFEf5ec4FeD96Bc70c8dD5a58 ; < 5reS9QDU2Jt1TLzEz25nUf4pS91q5mDJe334VhpwHJ6GMeZ1q2a82nZCX21OZb69 > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,05396671459775 ; -1 ; -0,00025 ; 0,00025 ; 9,1 ; 4,9 ; -7,3 ; -0,3 ; -2,8 ; 7,9 ; -0,97 ; NABEURJU2115 ; b734B8eDa418DE267bfa010E466dfe3c994BC3b5C890E21dc26b7e1a9cD7B83a ; < 5q1Gf021EhEX5K4P9hXmUOFXRkiDBxeJi2ApCpKoW94u2RJG4BI7Kk0B4r9KUVLQ > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,05907861835916 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -7,6 ; 3,7 ; 0,5 ; -4 ; -1,1 ; 0,62 ; NABEURSE2178 ; 917dAaAb2ABADFCF8fcddeE7AA9Eed37f07f5159adDb093BeFC8e4e8e60BeEaB ; < 1D833wPG6Tp5Ufoj8xfx617969Mx5mmt80YOqi6V7523t8DxvmC920t42e8iqm5v > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,0643160268966 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; -2,4 ; -0,2 ; 2 ; 1 ; -4,9 ; -0,07 ; NABEURDE2157 ; e82cf2220271bE9dd5D66fCfd329FFc1B9F0fDEcE3faBE8C9eDCE2BeE2cA2C1a ; < z40RCxvgSGy147H2c8dHcfNLh821rBvn6a8lEReP547loOWX3e15xL5D5R850KvN > >										24
											
//	  < CALLS ; 24M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 24M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABEUR										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; f4AddAd7aaAc515DCFAD905Cc3Efa08cfEae8EF5Ae1F63Dfe7bcDcf23bf77ADA ; < to6Od76JFlu03IYs1nj527h6uJlLLYTm5282x757SG997ww449E1a0tZHpw467da > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,00026609499864 ; -1 ; -0,00025 ; 0,00025 ; -6 ; -0,2 ; 1,6 ; -5,3 ; -3,6 ; 6,5 ; -0,06 ; NABEUR26JA19 ; f2C9dDE6b26A4bADEe4cc9Ef2FedAbEDabEa2BDBBFB21Fdd3C0f0edBFDca2Bb6 ; < 92J4ya37SZ0k76941BELR494r7qJeZg8C18qkS6mWlQ8bA5JwIH780AjpGZvxEtr > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,00074045449057 ; -1 ; -0,00025 ; 0,00025 ; 2,5 ; 3,6 ; 6,8 ; -8,6 ; -3,6 ; -7,6 ; 0,53 ; NABEURMA1936 ; 76CADAa0dCAD4f9e28BC74fE36eeFBEfE0c9CACE2b9776e55b0FBF5Ae847c9e6 ; < aDwt79SowQO5Jght4jMa4q9HbJ4Dxg3sCHyK6E5K38KNkMxxUw4RYF1B9J4eQ8LM > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,00137633990192 ; -1 ; -0,00025 ; 0,00025 ; 9,4 ; 7,9 ; 9,5 ; -8,5 ; -0,4 ; -7,6 ; 0,86 ; NABEURMA1934 ; 7fdCCd9bCcFdFA6cDA36ACD1EBFC173C70Fb9BfE9BBe952efbAADfb890622c2a ; < jO618x9ekJ1Lv1XC0A6q53yEWscZpiC7RB7da97L32bR5r6aIPm75DW7CWFBYA06 > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,002286230351 ; -1 ; -0,00025 ; 0,00025 ; 7,4 ; 4,8 ; 7,4 ; 5,6 ; 9 ; -8,7 ; 0,63 ; NABEURJU1956 ; adeb1be4CaC7CEC2FF6B8Def4B04EdAebEa0ab08Ee40F632ceEDad3Ae3770C7f ; < h9KiF3XQO1ce6oS1qkKn5dfEBRA2YR35c1P159gH27JPFu8i0HHQP8q3P1ZZ23eq > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,00336860738833 ; -1 ; -0,00025 ; 0,00025 ; 7 ; -8,3 ; 0,7 ; -1,5 ; 4,5 ; -8,1 ; -0,59 ; NABEURSE1946 ; CaE2261bbaf5cBECBFdCfB4Ad2Ea2473fFd8BC7bD0f8F73dFACccECC1DBDc6af ; < zsRU1zArGtZiy309z3k2C00WdGVErZ7O1t9W7FO7r3BOP9E620ldq9GP588bB5I8 > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,00464410935353 ; -1 ; -0,00025 ; 0,00025 ; 5,4 ; -8 ; 7,6 ; -1 ; 4,6 ; 1,2 ; -0,37 ; NABEURDE1943 ; 3D9e234BA02FAcb1DaF3CaBCFE91361BD1afdC9eD42abc453C4b2fAACd8409E0 ; < gpAZ47OvET1pRg0pQD87yqF84pUinmn5pVX73kshaPTMK3JqV54qC2Kaz9Q1cWwk > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,00601301197941 ; -1 ; -0,00025 ; 0,00025 ; -8 ; -9,1 ; -9,1 ; 2,3 ; 7 ; -9,7 ; 0,13 ; NABEURJA2055 ; daacACddFE3abFf12fafdcA7eDbE4aD49fDd4303a6b6bF2fAa8F356EDA38bfA4 ; < OlTW7ZyeVHBImUL1ezKLrK2q52204WYB2JSG010aD0q96AGc71pbJT4LknHOVU3t > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,00770107464382 ; -1 ; -0,00025 ; 0,00025 ; 7,3 ; -4 ; -5,2 ; 9,8 ; -5 ; -3,8 ; -0,64 ; NABEURMA2056 ; 1AEbCbe8FdB51bFd1fA455eFcBAB42FdFCffEebb0eF2fAC8BC554Ab08d0Eed1A ; < J50jNaOyxAQ1Omzu54ljn1NWB5XwUfw4XRf8MPavU6ux411J3t8o2xTg2dfYe3GP > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,00951031593822 ; -1 ; -0,00025 ; 0,00025 ; -7,1 ; -6,6 ; 0,3 ; 3,6 ; 6,2 ; 3,2 ; 0,96 ; NABEURMA2075 ; FbdFB31EDa92e4ACfa6BddcFFdAbbDe5AEBAefF333Cb8BaDaebAd1afaCA1Bdef ; < C4T3SI0er22kd1B9Y2xZ278uMS9ODlZ1ZM5219wwxtKO2OfmW013g2ww084GE67H > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,01152216877121 ; -1 ; -0,00025 ; 0,00025 ; -6,6 ; 9,2 ; -0,7 ; 9,9 ; -9,4 ; -2,6 ; -0,7 ; NABEURJU2059 ; A0fac1445fdb0efdAd67F5Ecb1ddfaCa4a5d8e6feaF607FbAd6DfDdaA8f3ec83 ; < 9t2I3N9CkAxA1waJ8ab1ELsq0mf89UK09bju9P9f6K61644nS7N6N4iwsVmgmD3k > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,01378335391844 ; -1 ; -0,00025 ; 0,00025 ; -3 ; 5,2 ; 7 ; -4,3 ; 3,6 ; 1,8 ; -0,59 ; NABEURSE2053 ; EaEdBEAe86B8cB9C2a751ffdfFdf3Ce5EAf5D43eFBc41BfB3CFbCc8ecbbfeFbc ; < 6w6EFb938Y06481OxD1H2XU04EW50N34ure7877Jld7KRIo4SeiJLHZMO61fP06B > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,0162438061184 ; -1 ; -0,00025 ; 0,00025 ; -7,7 ; -5,3 ; -4,3 ; 5,5 ; -5,5 ; -2,8 ; -0,75 ; NABEURDE2057 ; DbEaec74bf0cbB8CF2A6E8b0C1dE278c8B1fE1bf5bFcFeFdB1E2D8a97feDd8ee ; < no7gRb56drzRvI6b0a6Z96j3ztslj3j91kB539IP85Eut44t8ojq3Ybm8p0993FW > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,01890292514512 ; -1 ; -0,00025 ; 0,00025 ; -2,5 ; -8,7 ; -2,6 ; -8,1 ; 3,3 ; 0 ; -0,2 ; NABEURJA2184 ; e8a1C0Fb1cB82AFecfAeF633ce61C4fF27dd1dbA9a6a7BCCe0EDacb9BBf9fCC9 ; < yrSx9HtjYOKzdDaGEWkgozy66NT58969kek0S4zf2M1107g3QD1cgc7hC6AU6pQY > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,02188145745659 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; -1,2 ; 0,8 ; 7,5 ; -9,7 ; -7 ; 0,25 ; NABEURMA2199 ; eed7645f2aEFB2dDA36E6db1bdAcD7e1a3e02F1c9909Ad58f19771d8faBa9bB7 ; < 8p38h80WchAdR6NnkqZ3zt7yzBG154moJMa4X2RA7ST6HE5P2OfNO3gVOX2F7y1a > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,02507276867486 ; -1 ; -0,00025 ; 0,00025 ; -8,3 ; -2,8 ; -7,8 ; 2,9 ; 0,8 ; -9,8 ; 0,87 ; NABEURMA2196 ; A70eE4aa2c95BDFc8c6a3b2A65c8E0f8AEafaab8aFecdCdE1bFf4Ce3f2e4fDCA ; < 1X5SWJzdl11a96EYU91pO1QrGgGY3kP71T02a13XHhm7t21Y8B86Q5266x4w336K > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,02853312880934 ; -1 ; -0,00025 ; 0,00025 ; -4,4 ; -9,2 ; -7,9 ; 1,8 ; 9,6 ; -6,9 ; -0,73 ; NABEURJU2190 ; fACf6b8d0efa5B1dcD50e8Fd7EcEf1F7BdBeBcca6cef79DbbD422b83DFBF6698 ; < 6PrBR9h1YW7g9Yqe7O057q7eT0vYzVo60H2GIzTs7gqq82r0JnqP9t6wD2shDNxF > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,03216540423907 ; -1 ; -0,00025 ; 0,00025 ; 6,1 ; -9 ; -2,8 ; 2,8 ; -9,6 ; -7 ; 0,56 ; NABEURSE2158 ; AdDfB4A3dddce7dBfdE8bA8Ce4E07f9fF63CaAFEcDCE76FbecA7B88eE0a7bFB4 ; < 456vbWlP96q6h6MPmEBLLWUKnb02lVUJVwwZOB8f8z56UTquQ6E1U6pUy41sg2nt > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,03597754487675 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; -6 ; -0,2 ; -6,6 ; -6,4 ; 1,1 ; -0,55 ; NABEURDE2189 ; D9e9FD3bA280a8Dd0bB95Fe0f05FaBFdA7abbFFb5ffdAAea8f103ecE2eEE78eC ; < DfeBeS81E21W5yn254eb8gYprE20i4T1MfUqTa057f2NQ675lH7Ljig651a0EM3r > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,0401651925952 ; -1 ; -0,00025 ; 0,00025 ; -8,9 ; 4,6 ; 6,6 ; 8,4 ; 9,9 ; -2,5 ; -0,67 ; NABEURJA2173 ; b02AFdeefB6f77BfaEfBb71ebFFfffB7bfd0a9f30b6b9Cce78Dd00aAfcEBce79 ; < Q86Hg9XX45JeiVng3NUzjhkpibSMok88Sw6Qk1u03672778af0QLtL34mtXtY69O > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,04460164060659 ; -1 ; -0,00025 ; 0,00025 ; 9,3 ; 5,9 ; 3,3 ; -5 ; 8,2 ; -5,5 ; -0,25 ; NABEURMA2182 ; dbb48caFae7cD5Fb2b1fEafc19aDdBfaeea9Dc324cea8EFC8d395A824f3DBad6 ; < rcXO3b06fE3bg0cnPWy3EDNYrs418LBSBp2Lf4vpvQ5jIBBc3pKHK1526CrO0biB > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,04924082169297 ; -1 ; -0,00025 ; 0,00025 ; 2,4 ; -6,8 ; -2 ; 1,6 ; 3,5 ; 5,1 ; -0,21 ; NABEURMA2171 ; EbDf1604c1A4EaBC9fe6ecAFdCEE4deFBfEEea9BFEf5ec4FeD96Bc70c8dD5a58 ; < 5reS9QDU2Jt1TLzEz25nUf4pS91q5mDJe334VhpwHJ6GMeZ1q2a82nZCX21OZb69 > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,05396671459775 ; -1 ; -0,00025 ; 0,00025 ; 9,1 ; 4,9 ; -7,3 ; -0,3 ; -2,8 ; 7,9 ; -0,97 ; NABEURJU2115 ; b734B8eDa418DE267bfa010E466dfe3c994BC3b5C890E21dc26b7e1a9cD7B83a ; < 5q1Gf021EhEX5K4P9hXmUOFXRkiDBxeJi2ApCpKoW94u2RJG4BI7Kk0B4r9KUVLQ > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,05907861835916 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -7,6 ; 3,7 ; 0,5 ; -4 ; -1,1 ; 0,62 ; NABEURSE2178 ; 917dAaAb2ABADFCF8fcddeE7AA9Eed37f07f5159adDb093BeFC8e4e8e60BeEaB ; < 1D833wPG6Tp5Ufoj8xfx617969Mx5mmt80YOqi6V7523t8DxvmC920t42e8iqm5v > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,0643160268966 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; -2,4 ; -0,2 ; 2 ; 1 ; -4,9 ; -0,07 ; NABEURDE2157 ; e82cf2220271bE9dd5D66fCfd329FFc1B9F0fDEcE3faBE8C9eDCE2BeE2cA2C1a ; < z40RCxvgSGy147H2c8dHcfNLh821rBvn6a8lEReP547loOWX3e15xL5D5R850KvN > >										24
											
//	  < CALLS ; 36M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 36M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABRUB										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; FacEfABEc15492BA55AcaaAece7CFEE2CC5E36aabdCEDfD809e0FFe7BfDBA9Ad ; < zot500hG0Lxr6CaU30Mrg84xyiCd77v86G15eM2F1hV5cptLQ1Pzs9pcW497982h > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14021100829845 ; -1 ; -0,00025 ; 0,00025 ; 8,6 ; 6,1 ; -4 ; -7,1 ; -8,9 ; 3,3 ; -0,11 ; NABRUB16JA19 ; AeC73b4d6aF50E8dDff5FA9C4CF47DFfEA6F4E260ab6B8FeB7Abcb5BEd2ae115 ; < DZT5fnz4H0nbk5Vz6rqL9RqHdxehf75R445fQ86rmCZ2wI64AdkzcO51Ft17tK15 > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14072893010838 ; -1 ; -0,00025 ; 0,00025 ; 0,3 ; -8,6 ; 7,9 ; -3,8 ; 0,9 ; 7,1 ; -0,41 ; NABRUBMA1976 ; aE2504D6dEBaA32D1be7DD23ADAC7a2fb9F6ddF7c1EBcc7d8f54fff9dC4DCe2E ; < Rm340ZMA35919KNYf9t3A0WkLX8fi31q94207B14wVLcH49FyGT8MHQ77gH3KzY9 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14151878783416 ; -1 ; -0,00025 ; 0,00025 ; 8,3 ; -7,9 ; 2,2 ; 1,7 ; -8,7 ; 7,3 ; -0,08 ; NABRUBMA1940 ; d65BbBc2a1AD5afD3ceCA65FB4E542fFE47e9C5366EeDb9Adfd9Ed82e47CAc3B ; < 5I13m5QQ8N8cy51KESaR2mDL5I55wo7T8x2tmIHO70Lt4M5cdYci2F3n0D3np6us > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14245213908666 ; -1 ; -0,00025 ; 0,00025 ; 4,2 ; -9,6 ; 6,2 ; -7 ; 8,3 ; 5,2 ; 0,61 ; NABRUBJU1923 ; e4BeEeB3Fb0cadf0cA9311E1b1BeACEc4Ff04Ea1FD3c5b92fd5DEfdDec5B7FDE ; < VMWd2947ZETt9W1f31A43IWr0qi36mVZD56K48zeY1hpiP5Dk2mGchzQqhgm2Ajp > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14356135514363 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; 9,7 ; -7,1 ; 4,2 ; 1,5 ; -8,1 ; -0,26 ; NABRUBSE1913 ; CFEC2EEcBbBb1DeeafCCFb15df5DE5F3AaeEfc23EAAc7796AbCafccccfB295Cb ; < k4BQNMe0S3z5vvHgc603VOkVjazfJUb1MHjve82ZCydzJQ9thHcLJH8QrfxXlByE > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14493273647751 ; -1 ; -0,00025 ; 0,00025 ; 6 ; 6,6 ; -4,7 ; -9,4 ; -4,2 ; 2,2 ; 0,83 ; NABRUBDE1952 ; eCDF1efbEd9A5dCAe31Dd6caEaC1291afaFBDD5eA47e5f04CC8dd6ffDAcFFfBD ; < igVHHCiciMhdR50Ua5qBQ8P78wR7J7kKSziAQP86MRJN7gaYs71rny9KLmWsq37R > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14658324252079 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; 9,6 ; 3,4 ; -9,9 ; 4,1 ; -2,5 ; -0,1 ; NABRUBJA2012 ; 3Ca0fdDEac1F7F27fD60Fb9bEdbac27Ac5fDAF1fdccAddCEfDbD63eFACd9f2bB ; < 29wt3xp2Fzi16Zl4TCm58t1w9v2C0KSPaC6KviMj0C8qddG8gQs3Rl9823OlDA9G > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14843838324108 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; 2,9 ; -0,6 ; -4,8 ; -8,3 ; 3,9 ; 0,85 ; NABRUBMA2085 ; bC1ACb5893DDdebAcFEB84a5Cfcc413BB5fa0B4FCAC5A1E1fc11a785f5fBB149 ; < SVgPlpQnc3lqwvsP2TdFTFY1f1isAZ3K4DiD65V0q7F71kzttFSqoC8v759lwOTf > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15053935326926 ; -1 ; -0,00025 ; 0,00025 ; 9,3 ; -0,2 ; -8,6 ; -5,2 ; 9 ; 4,1 ; -0,27 ; NABRUBMA2035 ; baABbCFB0bb7dbEc031Dd2231dddBAdcA35a7EDe2EeAB6beB6103641742DAded ; < ZEmHKXKs6JkkHxpf32m23aIdB8hhFnB9T9ns2RN2hfhp1F271oGGtWjhD26kE2ZW > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15296572539722 ; -1 ; -0,00025 ; 0,00025 ; -1,8 ; -3,8 ; -8,6 ; -1 ; 0,1 ; 8 ; -0,96 ; NABRUBJU2011 ; aAb2e5CBB2EBC4Dc375ed38eAb0ee3afF7eFbecE8B9bBdB53bcdd60fc1Fb999D ; < vO5dKp8162w054gagf5R50YKz1vBf0g1Sd3910qrKJ40W7mLJflcawmoUEAigO4N > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15565954699318 ; -1 ; -0,00025 ; 0,00025 ; 1,5 ; -2 ; 0,7 ; -8,2 ; 4,3 ; 5,9 ; -0,84 ; NABRUBSE2069 ; 35204BA3dA8888fB4B8D0Fc4781acBCc6da2EA49a4cb28afaAE870fe5d7C8F29 ; < qbOynA06C6B4qyx39EEA1wIzGL05coHP440B5Q6EI7Z48PT67Fq9a71oZ450YEfD > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15855331849885 ; -1 ; -0,00025 ; 0,00025 ; 4,3 ; 8 ; 2,6 ; -7,6 ; -0,9 ; 0,5 ; 0,07 ; NABRUBDE2078 ; CAebaDb4dcdbCFF7FcDA0CeBeBECa9C99ecBff3A32d962AA2ddbed33db3ebBd4 ; < BXbdOqwTNHLyvX62957Wn6W42f6bn8120Q91NP658dzt24K2gmA38CU8jwL3kIJS > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,16159986795705 ; -1 ; -0,00025 ; 0,00025 ; -3,6 ; -1,4 ; -1 ; 9,4 ; -8,8 ; 3 ; -0,45 ; NABRUBJA2157 ; 680d53DD08F71cCa7cd51BD4D3Ca3dB9ECCDCDeCACE1FC4abDbDDca67ab356D3 ; < HVmd5OQan6tSo3Yb9jL2VmCa6mjqg13cLHD5z4C8mZoBPV4366uEjK5ZgRWq7sU9 > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16501064331307 ; -1 ; -0,00025 ; 0,00025 ; 4,5 ; 4,9 ; 1,5 ; -7,9 ; 6,6 ; -7,4 ; 0,63 ; NABRUBMA2166 ; eaecB6cc7bEaDeE0fa3EA59E7d749Febb7fBCc8dc8d35AC36ea9DC21b280Ce9c ; < YcLj0dW1VZ74YLkcgsE3Uy9fxccQ1Izl4dDDUbQ5hz5yXOtCfR60Y8122t3GaynJ > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16875029946288 ; -1 ; -0,00025 ; 0,00025 ; -5,4 ; 8,3 ; -9,3 ; -0,9 ; -4,3 ; 6 ; -0,58 ; NABRUBMA2128 ; 15D1Fe7ABa8FC895db3FA2f31b5BAbbcEAE674F27ADBA19Be8D8aEEDFBdFF90b ; < 5aqMyQWVoLv900r5N037trOp17KH50PQiu6W9EC5Hi9OcOn44awxXS5s86CAUg4t > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,1725413998806 ; -1 ; -0,00025 ; 0,00025 ; -1,9 ; 3,6 ; 8,8 ; -8,4 ; 4,4 ; 6,1 ; -0,87 ; NABRUBJU2148 ; 8Eb2ACdfAeCC073F22abc3B1cCDfBa6308B7b0bF35Bf39CeA0FEA13DfEBeDBE8 ; < d7Vn70PFeob92XFfj4Niv4lk1NslUYvq0BTiZRmIo1qIkz9m45l3287X5svZRrg0 > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17673383383731 ; -1 ; -0,00025 ; 0,00025 ; 8,5 ; -3,6 ; -6,9 ; -2,8 ; -8,3 ; 2,1 ; -0,27 ; NABRUBSE2130 ; Dfb4BdbcFdEdBfa64a7a9eAc5CCDaB2Fd81aBdb6eF6a06A036a8C3Cc9deE6fa5 ; < iJz57Xy6tDW9SWtNhfZz25O8m6SeLB7KQkc7g3o1c3Hin3eOR02J22P9w7I514tz > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18115875640671 ; -1 ; -0,00025 ; 0,00025 ; 9,2 ; 3,3 ; -9,1 ; -6 ; 9,6 ; -7 ; -0,12 ; NABRUBDE2186 ; bbCe5A14250fDDaEA1F5EbBB2c76fcB3eba2cAf7A6AC2bD4CAFDcDBfeCb7DFb4 ; < FtI34q79Co8NT14DTEt19FmYxfmtff3Yr666YHsqcnMh544Xa54qqBF6Ufj2iNVT > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18578561347666 ; -1 ; -0,00025 ; 0,00025 ; 9,6 ; 6,8 ; 2 ; -9,6 ; 5,1 ; -6,2 ; 0,03 ; NABRUBJA2172 ; D4B5FeAbd5Bf6635efc2dfccbD12CEdBEE03Aecb8bAc2ebDaEa92CeB3aDdb67A ; < k38v0At8YIbjAXbO0h8XIsHa2QVT8P41QJVuS074bUll2182SUu6mgg1EzxB8YoF > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19083840952538 ; -1 ; -0,00025 ; 0,00025 ; -5,7 ; -5,6 ; 9,8 ; 9,2 ; -1,2 ; 2,9 ; 0,37 ; NABRUBMA2167 ; CA0EdfeFfc9BfF9fcb3fFD5933b96A05B47a39F0e1DC25aECcdAD8CFa3CbD5Ea ; < oPW1dBufssq1LUnK1H84Dv828NhEAL0rAt8v8ts04JW54c3ysoJ8DyeMv1f8Y448 > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19602939408026 ; -1 ; -0,00025 ; 0,00025 ; -3,5 ; -1,2 ; 8,6 ; -4 ; -2,8 ; -6,4 ; 0,11 ; NABRUBMA2126 ; fed12aCDf4Eeaae8AEfDBa498BCe5f5baAd3eF44bf33D0Abc8D3BeD967D25deE ; < nk0s72aab4KU8NxP5Di57dVNb9b90y6Iltu7bj0X5SUhH9543w3B6ks4y9xASA1E > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20145710341736 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; -0,8 ; 3,7 ; 8,4 ; -8,9 ; 2,2 ; -0,79 ; NABRUBJU2125 ; 77F7eFDBcabDaaD4d47Ca1d5da3dfAdD26B9C6bbebB7cEEcfaE917b3a5eaFBa1 ; < LtH7xCdIyURViVW1QB5c0jM67xJ9GmU7RdL2kSeN9I3059M2g999uz4Q0mUK52ru > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20718583919927 ; -1 ; -0,00025 ; 0,00025 ; 5,1 ; 8,3 ; -6,2 ; -5,9 ; -6,2 ; -2 ; 0,29 ; NABRUBSE2153 ; 56Caec1C2AFb5EeAe0bc1dcCb29DeFaDbdca32e78CCDACFDc67Bb85FAB4CBd3c ; < bcwt1s84AvUCro481ue580G4BRA7eDjzCQ4vl4F9B12o0C3cNuKybCTJ5FN4sBv6 > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,2131689540148 ; -1 ; -0,00025 ; 0,00025 ; 3,4 ; 1,7 ; 1,2 ; 6,9 ; 0,8 ; 7,7 ; 0,13 ; NABRUBDE2192 ; 2dCd740eDfCbDDCebc3CAdcc1dC59d7CE9dDF1A0CDbDcfc6Ab0BCd0DeC8a66EB ; < 4163pB13V4HV45KXfbli104pe8wp038Ug7CC8Lrz8R7GxuQPyDR16Cm1p9Td6nge > >										24
											
//	  < CALLS ; 3M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 3M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABRUB										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; FacEfABEc15492BA55AcaaAece7CFEE2CC5E36aabdCEDfD809e0FFe7BfDBA9Ad ; < zot500hG0Lxr6CaU30Mrg84xyiCd77v86G15eM2F1hV5cptLQ1Pzs9pcW497982h > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14021100829845 ; -1 ; -0,00025 ; 0,00025 ; 8,6 ; 6,1 ; -4 ; -7,1 ; -8,9 ; 3,3 ; -0,11 ; NABRUB16JA19 ; AeC73b4d6aF50E8dDff5FA9C4CF47DFfEA6F4E260ab6B8FeB7Abcb5BEd2ae115 ; < DZT5fnz4H0nbk5Vz6rqL9RqHdxehf75R445fQ86rmCZ2wI64AdkzcO51Ft17tK15 > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14072893010838 ; -1 ; -0,00025 ; 0,00025 ; 0,3 ; -8,6 ; 7,9 ; -3,8 ; 0,9 ; 7,1 ; -0,41 ; NABRUBMA1976 ; aE2504D6dEBaA32D1be7DD23ADAC7a2fb9F6ddF7c1EBcc7d8f54fff9dC4DCe2E ; < Rm340ZMA35919KNYf9t3A0WkLX8fi31q94207B14wVLcH49FyGT8MHQ77gH3KzY9 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14151878783416 ; -1 ; -0,00025 ; 0,00025 ; 8,3 ; -7,9 ; 2,2 ; 1,7 ; -8,7 ; 7,3 ; -0,08 ; NABRUBMA1940 ; d65BbBc2a1AD5afD3ceCA65FB4E542fFE47e9C5366EeDb9Adfd9Ed82e47CAc3B ; < 5I13m5QQ8N8cy51KESaR2mDL5I55wo7T8x2tmIHO70Lt4M5cdYci2F3n0D3np6us > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14245213908666 ; -1 ; -0,00025 ; 0,00025 ; 4,2 ; -9,6 ; 6,2 ; -7 ; 8,3 ; 5,2 ; 0,61 ; NABRUBJU1923 ; e4BeEeB3Fb0cadf0cA9311E1b1BeACEc4Ff04Ea1FD3c5b92fd5DEfdDec5B7FDE ; < VMWd2947ZETt9W1f31A43IWr0qi36mVZD56K48zeY1hpiP5Dk2mGchzQqhgm2Ajp > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14356135514363 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; 9,7 ; -7,1 ; 4,2 ; 1,5 ; -8,1 ; -0,26 ; NABRUBSE1913 ; CFEC2EEcBbBb1DeeafCCFb15df5DE5F3AaeEfc23EAAc7796AbCafccccfB295Cb ; < k4BQNMe0S3z5vvHgc603VOkVjazfJUb1MHjve82ZCydzJQ9thHcLJH8QrfxXlByE > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14493273647751 ; -1 ; -0,00025 ; 0,00025 ; 6 ; 6,6 ; -4,7 ; -9,4 ; -4,2 ; 2,2 ; 0,83 ; NABRUBDE1952 ; eCDF1efbEd9A5dCAe31Dd6caEaC1291afaFBDD5eA47e5f04CC8dd6ffDAcFFfBD ; < igVHHCiciMhdR50Ua5qBQ8P78wR7J7kKSziAQP86MRJN7gaYs71rny9KLmWsq37R > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14658324252079 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; 9,6 ; 3,4 ; -9,9 ; 4,1 ; -2,5 ; -0,1 ; NABRUBJA2012 ; 3Ca0fdDEac1F7F27fD60Fb9bEdbac27Ac5fDAF1fdccAddCEfDbD63eFACd9f2bB ; < 29wt3xp2Fzi16Zl4TCm58t1w9v2C0KSPaC6KviMj0C8qddG8gQs3Rl9823OlDA9G > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14843838324108 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; 2,9 ; -0,6 ; -4,8 ; -8,3 ; 3,9 ; 0,85 ; NABRUBMA2085 ; bC1ACb5893DDdebAcFEB84a5Cfcc413BB5fa0B4FCAC5A1E1fc11a785f5fBB149 ; < SVgPlpQnc3lqwvsP2TdFTFY1f1isAZ3K4DiD65V0q7F71kzttFSqoC8v759lwOTf > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15053935326926 ; -1 ; -0,00025 ; 0,00025 ; 9,3 ; -0,2 ; -8,6 ; -5,2 ; 9 ; 4,1 ; -0,27 ; NABRUBMA2035 ; baABbCFB0bb7dbEc031Dd2231dddBAdcA35a7EDe2EeAB6beB6103641742DAded ; < ZEmHKXKs6JkkHxpf32m23aIdB8hhFnB9T9ns2RN2hfhp1F271oGGtWjhD26kE2ZW > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15296572539722 ; -1 ; -0,00025 ; 0,00025 ; -1,8 ; -3,8 ; -8,6 ; -1 ; 0,1 ; 8 ; -0,96 ; NABRUBJU2011 ; aAb2e5CBB2EBC4Dc375ed38eAb0ee3afF7eFbecE8B9bBdB53bcdd60fc1Fb999D ; < vO5dKp8162w054gagf5R50YKz1vBf0g1Sd3910qrKJ40W7mLJflcawmoUEAigO4N > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15565954699318 ; -1 ; -0,00025 ; 0,00025 ; 1,5 ; -2 ; 0,7 ; -8,2 ; 4,3 ; 5,9 ; -0,84 ; NABRUBSE2069 ; 35204BA3dA8888fB4B8D0Fc4781acBCc6da2EA49a4cb28afaAE870fe5d7C8F29 ; < qbOynA06C6B4qyx39EEA1wIzGL05coHP440B5Q6EI7Z48PT67Fq9a71oZ450YEfD > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15855331849885 ; -1 ; -0,00025 ; 0,00025 ; 4,3 ; 8 ; 2,6 ; -7,6 ; -0,9 ; 0,5 ; 0,07 ; NABRUBDE2078 ; CAebaDb4dcdbCFF7FcDA0CeBeBECa9C99ecBff3A32d962AA2ddbed33db3ebBd4 ; < BXbdOqwTNHLyvX62957Wn6W42f6bn8120Q91NP658dzt24K2gmA38CU8jwL3kIJS > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,16159986795705 ; -1 ; -0,00025 ; 0,00025 ; -3,6 ; -1,4 ; -1 ; 9,4 ; -8,8 ; 3 ; -0,45 ; NABRUBJA2157 ; 680d53DD08F71cCa7cd51BD4D3Ca3dB9ECCDCDeCACE1FC4abDbDDca67ab356D3 ; < HVmd5OQan6tSo3Yb9jL2VmCa6mjqg13cLHD5z4C8mZoBPV4366uEjK5ZgRWq7sU9 > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16501064331307 ; -1 ; -0,00025 ; 0,00025 ; 4,5 ; 4,9 ; 1,5 ; -7,9 ; 6,6 ; -7,4 ; 0,63 ; NABRUBMA2166 ; eaecB6cc7bEaDeE0fa3EA59E7d749Febb7fBCc8dc8d35AC36ea9DC21b280Ce9c ; < YcLj0dW1VZ74YLkcgsE3Uy9fxccQ1Izl4dDDUbQ5hz5yXOtCfR60Y8122t3GaynJ > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16875029946288 ; -1 ; -0,00025 ; 0,00025 ; -5,4 ; 8,3 ; -9,3 ; -0,9 ; -4,3 ; 6 ; -0,58 ; NABRUBMA2128 ; 15D1Fe7ABa8FC895db3FA2f31b5BAbbcEAE674F27ADBA19Be8D8aEEDFBdFF90b ; < 5aqMyQWVoLv900r5N037trOp17KH50PQiu6W9EC5Hi9OcOn44awxXS5s86CAUg4t > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,1725413998806 ; -1 ; -0,00025 ; 0,00025 ; -1,9 ; 3,6 ; 8,8 ; -8,4 ; 4,4 ; 6,1 ; -0,87 ; NABRUBJU2148 ; 8Eb2ACdfAeCC073F22abc3B1cCDfBa6308B7b0bF35Bf39CeA0FEA13DfEBeDBE8 ; < d7Vn70PFeob92XFfj4Niv4lk1NslUYvq0BTiZRmIo1qIkz9m45l3287X5svZRrg0 > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17673383383731 ; -1 ; -0,00025 ; 0,00025 ; 8,5 ; -3,6 ; -6,9 ; -2,8 ; -8,3 ; 2,1 ; -0,27 ; NABRUBSE2130 ; Dfb4BdbcFdEdBfa64a7a9eAc5CCDaB2Fd81aBdb6eF6a06A036a8C3Cc9deE6fa5 ; < iJz57Xy6tDW9SWtNhfZz25O8m6SeLB7KQkc7g3o1c3Hin3eOR02J22P9w7I514tz > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18115875640671 ; -1 ; -0,00025 ; 0,00025 ; 9,2 ; 3,3 ; -9,1 ; -6 ; 9,6 ; -7 ; -0,12 ; NABRUBDE2186 ; bbCe5A14250fDDaEA1F5EbBB2c76fcB3eba2cAf7A6AC2bD4CAFDcDBfeCb7DFb4 ; < FtI34q79Co8NT14DTEt19FmYxfmtff3Yr666YHsqcnMh544Xa54qqBF6Ufj2iNVT > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18578561347666 ; -1 ; -0,00025 ; 0,00025 ; 9,6 ; 6,8 ; 2 ; -9,6 ; 5,1 ; -6,2 ; 0,03 ; NABRUBJA2172 ; D4B5FeAbd5Bf6635efc2dfccbD12CEdBEE03Aecb8bAc2ebDaEa92CeB3aDdb67A ; < k38v0At8YIbjAXbO0h8XIsHa2QVT8P41QJVuS074bUll2182SUu6mgg1EzxB8YoF > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19083840952538 ; -1 ; -0,00025 ; 0,00025 ; -5,7 ; -5,6 ; 9,8 ; 9,2 ; -1,2 ; 2,9 ; 0,37 ; NABRUBMA2167 ; CA0EdfeFfc9BfF9fcb3fFD5933b96A05B47a39F0e1DC25aECcdAD8CFa3CbD5Ea ; < oPW1dBufssq1LUnK1H84Dv828NhEAL0rAt8v8ts04JW54c3ysoJ8DyeMv1f8Y448 > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19602939408026 ; -1 ; -0,00025 ; 0,00025 ; -3,5 ; -1,2 ; 8,6 ; -4 ; -2,8 ; -6,4 ; 0,11 ; NABRUBMA2126 ; fed12aCDf4Eeaae8AEfDBa498BCe5f5baAd3eF44bf33D0Abc8D3BeD967D25deE ; < nk0s72aab4KU8NxP5Di57dVNb9b90y6Iltu7bj0X5SUhH9543w3B6ks4y9xASA1E > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20145710341736 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; -0,8 ; 3,7 ; 8,4 ; -8,9 ; 2,2 ; -0,79 ; NABRUBJU2125 ; 77F7eFDBcabDaaD4d47Ca1d5da3dfAdD26B9C6bbebB7cEEcfaE917b3a5eaFBa1 ; < LtH7xCdIyURViVW1QB5c0jM67xJ9GmU7RdL2kSeN9I3059M2g999uz4Q0mUK52ru > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20718583919927 ; -1 ; -0,00025 ; 0,00025 ; 5,1 ; 8,3 ; -6,2 ; -5,9 ; -6,2 ; -2 ; 0,29 ; NABRUBSE2153 ; 56Caec1C2AFb5EeAe0bc1dcCb29DeFaDbdca32e78CCDACFDc67Bb85FAB4CBd3c ; < bcwt1s84AvUCro481ue580G4BRA7eDjzCQ4vl4F9B12o0C3cNuKybCTJ5FN4sBv6 > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,2131689540148 ; -1 ; -0,00025 ; 0,00025 ; 3,4 ; 1,7 ; 1,2 ; 6,9 ; 0,8 ; 7,7 ; 0,13 ; NABRUBDE2192 ; 2dCd740eDfCbDDCebc3CAdcc1dC59d7CE9dDF1A0CDbDcfc6Ab0BCd0DeC8a66EB ; < 4163pB13V4HV45KXfbli104pe8wp038Ug7CC8Lrz8R7GxuQPyDR16Cm1p9Td6nge > >										24
											
//	  < CALLS ; 6M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 6M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABRUB										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; FacEfABEc15492BA55AcaaAece7CFEE2CC5E36aabdCEDfD809e0FFe7BfDBA9Ad ; < zot500hG0Lxr6CaU30Mrg84xyiCd77v86G15eM2F1hV5cptLQ1Pzs9pcW497982h > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14021100829845 ; -1 ; -0,00025 ; 0,00025 ; 8,6 ; 6,1 ; -4 ; -7,1 ; -8,9 ; 3,3 ; -0,11 ; NABRUB16JA19 ; AeC73b4d6aF50E8dDff5FA9C4CF47DFfEA6F4E260ab6B8FeB7Abcb5BEd2ae115 ; < DZT5fnz4H0nbk5Vz6rqL9RqHdxehf75R445fQ86rmCZ2wI64AdkzcO51Ft17tK15 > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14072893010838 ; -1 ; -0,00025 ; 0,00025 ; 0,3 ; -8,6 ; 7,9 ; -3,8 ; 0,9 ; 7,1 ; -0,41 ; NABRUBMA1976 ; aE2504D6dEBaA32D1be7DD23ADAC7a2fb9F6ddF7c1EBcc7d8f54fff9dC4DCe2E ; < Rm340ZMA35919KNYf9t3A0WkLX8fi31q94207B14wVLcH49FyGT8MHQ77gH3KzY9 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14151878783416 ; -1 ; -0,00025 ; 0,00025 ; 8,3 ; -7,9 ; 2,2 ; 1,7 ; -8,7 ; 7,3 ; -0,08 ; NABRUBMA1940 ; d65BbBc2a1AD5afD3ceCA65FB4E542fFE47e9C5366EeDb9Adfd9Ed82e47CAc3B ; < 5I13m5QQ8N8cy51KESaR2mDL5I55wo7T8x2tmIHO70Lt4M5cdYci2F3n0D3np6us > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14245213908666 ; -1 ; -0,00025 ; 0,00025 ; 4,2 ; -9,6 ; 6,2 ; -7 ; 8,3 ; 5,2 ; 0,61 ; NABRUBJU1923 ; e4BeEeB3Fb0cadf0cA9311E1b1BeACEc4Ff04Ea1FD3c5b92fd5DEfdDec5B7FDE ; < VMWd2947ZETt9W1f31A43IWr0qi36mVZD56K48zeY1hpiP5Dk2mGchzQqhgm2Ajp > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14356135514363 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; 9,7 ; -7,1 ; 4,2 ; 1,5 ; -8,1 ; -0,26 ; NABRUBSE1913 ; CFEC2EEcBbBb1DeeafCCFb15df5DE5F3AaeEfc23EAAc7796AbCafccccfB295Cb ; < k4BQNMe0S3z5vvHgc603VOkVjazfJUb1MHjve82ZCydzJQ9thHcLJH8QrfxXlByE > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14493273647751 ; -1 ; -0,00025 ; 0,00025 ; 6 ; 6,6 ; -4,7 ; -9,4 ; -4,2 ; 2,2 ; 0,83 ; NABRUBDE1952 ; eCDF1efbEd9A5dCAe31Dd6caEaC1291afaFBDD5eA47e5f04CC8dd6ffDAcFFfBD ; < igVHHCiciMhdR50Ua5qBQ8P78wR7J7kKSziAQP86MRJN7gaYs71rny9KLmWsq37R > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14658324252079 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; 9,6 ; 3,4 ; -9,9 ; 4,1 ; -2,5 ; -0,1 ; NABRUBJA2012 ; 3Ca0fdDEac1F7F27fD60Fb9bEdbac27Ac5fDAF1fdccAddCEfDbD63eFACd9f2bB ; < 29wt3xp2Fzi16Zl4TCm58t1w9v2C0KSPaC6KviMj0C8qddG8gQs3Rl9823OlDA9G > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14843838324108 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; 2,9 ; -0,6 ; -4,8 ; -8,3 ; 3,9 ; 0,85 ; NABRUBMA2085 ; bC1ACb5893DDdebAcFEB84a5Cfcc413BB5fa0B4FCAC5A1E1fc11a785f5fBB149 ; < SVgPlpQnc3lqwvsP2TdFTFY1f1isAZ3K4DiD65V0q7F71kzttFSqoC8v759lwOTf > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15053935326926 ; -1 ; -0,00025 ; 0,00025 ; 9,3 ; -0,2 ; -8,6 ; -5,2 ; 9 ; 4,1 ; -0,27 ; NABRUBMA2035 ; baABbCFB0bb7dbEc031Dd2231dddBAdcA35a7EDe2EeAB6beB6103641742DAded ; < ZEmHKXKs6JkkHxpf32m23aIdB8hhFnB9T9ns2RN2hfhp1F271oGGtWjhD26kE2ZW > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15296572539722 ; -1 ; -0,00025 ; 0,00025 ; -1,8 ; -3,8 ; -8,6 ; -1 ; 0,1 ; 8 ; -0,96 ; NABRUBJU2011 ; aAb2e5CBB2EBC4Dc375ed38eAb0ee3afF7eFbecE8B9bBdB53bcdd60fc1Fb999D ; < vO5dKp8162w054gagf5R50YKz1vBf0g1Sd3910qrKJ40W7mLJflcawmoUEAigO4N > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15565954699318 ; -1 ; -0,00025 ; 0,00025 ; 1,5 ; -2 ; 0,7 ; -8,2 ; 4,3 ; 5,9 ; -0,84 ; NABRUBSE2069 ; 35204BA3dA8888fB4B8D0Fc4781acBCc6da2EA49a4cb28afaAE870fe5d7C8F29 ; < qbOynA06C6B4qyx39EEA1wIzGL05coHP440B5Q6EI7Z48PT67Fq9a71oZ450YEfD > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15855331849885 ; -1 ; -0,00025 ; 0,00025 ; 4,3 ; 8 ; 2,6 ; -7,6 ; -0,9 ; 0,5 ; 0,07 ; NABRUBDE2078 ; CAebaDb4dcdbCFF7FcDA0CeBeBECa9C99ecBff3A32d962AA2ddbed33db3ebBd4 ; < BXbdOqwTNHLyvX62957Wn6W42f6bn8120Q91NP658dzt24K2gmA38CU8jwL3kIJS > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,16159986795705 ; -1 ; -0,00025 ; 0,00025 ; -3,6 ; -1,4 ; -1 ; 9,4 ; -8,8 ; 3 ; -0,45 ; NABRUBJA2157 ; 680d53DD08F71cCa7cd51BD4D3Ca3dB9ECCDCDeCACE1FC4abDbDDca67ab356D3 ; < HVmd5OQan6tSo3Yb9jL2VmCa6mjqg13cLHD5z4C8mZoBPV4366uEjK5ZgRWq7sU9 > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16501064331307 ; -1 ; -0,00025 ; 0,00025 ; 4,5 ; 4,9 ; 1,5 ; -7,9 ; 6,6 ; -7,4 ; 0,63 ; NABRUBMA2166 ; eaecB6cc7bEaDeE0fa3EA59E7d749Febb7fBCc8dc8d35AC36ea9DC21b280Ce9c ; < YcLj0dW1VZ74YLkcgsE3Uy9fxccQ1Izl4dDDUbQ5hz5yXOtCfR60Y8122t3GaynJ > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16875029946288 ; -1 ; -0,00025 ; 0,00025 ; -5,4 ; 8,3 ; -9,3 ; -0,9 ; -4,3 ; 6 ; -0,58 ; NABRUBMA2128 ; 15D1Fe7ABa8FC895db3FA2f31b5BAbbcEAE674F27ADBA19Be8D8aEEDFBdFF90b ; < 5aqMyQWVoLv900r5N037trOp17KH50PQiu6W9EC5Hi9OcOn44awxXS5s86CAUg4t > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,1725413998806 ; -1 ; -0,00025 ; 0,00025 ; -1,9 ; 3,6 ; 8,8 ; -8,4 ; 4,4 ; 6,1 ; -0,87 ; NABRUBJU2148 ; 8Eb2ACdfAeCC073F22abc3B1cCDfBa6308B7b0bF35Bf39CeA0FEA13DfEBeDBE8 ; < d7Vn70PFeob92XFfj4Niv4lk1NslUYvq0BTiZRmIo1qIkz9m45l3287X5svZRrg0 > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17673383383731 ; -1 ; -0,00025 ; 0,00025 ; 8,5 ; -3,6 ; -6,9 ; -2,8 ; -8,3 ; 2,1 ; -0,27 ; NABRUBSE2130 ; Dfb4BdbcFdEdBfa64a7a9eAc5CCDaB2Fd81aBdb6eF6a06A036a8C3Cc9deE6fa5 ; < iJz57Xy6tDW9SWtNhfZz25O8m6SeLB7KQkc7g3o1c3Hin3eOR02J22P9w7I514tz > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18115875640671 ; -1 ; -0,00025 ; 0,00025 ; 9,2 ; 3,3 ; -9,1 ; -6 ; 9,6 ; -7 ; -0,12 ; NABRUBDE2186 ; bbCe5A14250fDDaEA1F5EbBB2c76fcB3eba2cAf7A6AC2bD4CAFDcDBfeCb7DFb4 ; < FtI34q79Co8NT14DTEt19FmYxfmtff3Yr666YHsqcnMh544Xa54qqBF6Ufj2iNVT > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18578561347666 ; -1 ; -0,00025 ; 0,00025 ; 9,6 ; 6,8 ; 2 ; -9,6 ; 5,1 ; -6,2 ; 0,03 ; NABRUBJA2172 ; D4B5FeAbd5Bf6635efc2dfccbD12CEdBEE03Aecb8bAc2ebDaEa92CeB3aDdb67A ; < k38v0At8YIbjAXbO0h8XIsHa2QVT8P41QJVuS074bUll2182SUu6mgg1EzxB8YoF > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19083840952538 ; -1 ; -0,00025 ; 0,00025 ; -5,7 ; -5,6 ; 9,8 ; 9,2 ; -1,2 ; 2,9 ; 0,37 ; NABRUBMA2167 ; CA0EdfeFfc9BfF9fcb3fFD5933b96A05B47a39F0e1DC25aECcdAD8CFa3CbD5Ea ; < oPW1dBufssq1LUnK1H84Dv828NhEAL0rAt8v8ts04JW54c3ysoJ8DyeMv1f8Y448 > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19602939408026 ; -1 ; -0,00025 ; 0,00025 ; -3,5 ; -1,2 ; 8,6 ; -4 ; -2,8 ; -6,4 ; 0,11 ; NABRUBMA2126 ; fed12aCDf4Eeaae8AEfDBa498BCe5f5baAd3eF44bf33D0Abc8D3BeD967D25deE ; < nk0s72aab4KU8NxP5Di57dVNb9b90y6Iltu7bj0X5SUhH9543w3B6ks4y9xASA1E > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20145710341736 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; -0,8 ; 3,7 ; 8,4 ; -8,9 ; 2,2 ; -0,79 ; NABRUBJU2125 ; 77F7eFDBcabDaaD4d47Ca1d5da3dfAdD26B9C6bbebB7cEEcfaE917b3a5eaFBa1 ; < LtH7xCdIyURViVW1QB5c0jM67xJ9GmU7RdL2kSeN9I3059M2g999uz4Q0mUK52ru > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20718583919927 ; -1 ; -0,00025 ; 0,00025 ; 5,1 ; 8,3 ; -6,2 ; -5,9 ; -6,2 ; -2 ; 0,29 ; NABRUBSE2153 ; 56Caec1C2AFb5EeAe0bc1dcCb29DeFaDbdca32e78CCDACFDc67Bb85FAB4CBd3c ; < bcwt1s84AvUCro481ue580G4BRA7eDjzCQ4vl4F9B12o0C3cNuKybCTJ5FN4sBv6 > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,2131689540148 ; -1 ; -0,00025 ; 0,00025 ; 3,4 ; 1,7 ; 1,2 ; 6,9 ; 0,8 ; 7,7 ; 0,13 ; NABRUBDE2192 ; 2dCd740eDfCbDDCebc3CAdcc1dC59d7CE9dDF1A0CDbDcfc6Ab0BCd0DeC8a66EB ; < 4163pB13V4HV45KXfbli104pe8wp038Ug7CC8Lrz8R7GxuQPyDR16Cm1p9Td6nge > >										24
											
//	  < CALLS ; 12M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 12M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABRUB										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; FacEfABEc15492BA55AcaaAece7CFEE2CC5E36aabdCEDfD809e0FFe7BfDBA9Ad ; < zot500hG0Lxr6CaU30Mrg84xyiCd77v86G15eM2F1hV5cptLQ1Pzs9pcW497982h > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14021100829845 ; -1 ; -0,00025 ; 0,00025 ; 8,6 ; 6,1 ; -4 ; -7,1 ; -8,9 ; 3,3 ; -0,11 ; NABRUB16JA19 ; AeC73b4d6aF50E8dDff5FA9C4CF47DFfEA6F4E260ab6B8FeB7Abcb5BEd2ae115 ; < DZT5fnz4H0nbk5Vz6rqL9RqHdxehf75R445fQ86rmCZ2wI64AdkzcO51Ft17tK15 > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14072893010838 ; -1 ; -0,00025 ; 0,00025 ; 0,3 ; -8,6 ; 7,9 ; -3,8 ; 0,9 ; 7,1 ; -0,41 ; NABRUBMA1976 ; aE2504D6dEBaA32D1be7DD23ADAC7a2fb9F6ddF7c1EBcc7d8f54fff9dC4DCe2E ; < Rm340ZMA35919KNYf9t3A0WkLX8fi31q94207B14wVLcH49FyGT8MHQ77gH3KzY9 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14151878783416 ; -1 ; -0,00025 ; 0,00025 ; 8,3 ; -7,9 ; 2,2 ; 1,7 ; -8,7 ; 7,3 ; -0,08 ; NABRUBMA1940 ; d65BbBc2a1AD5afD3ceCA65FB4E542fFE47e9C5366EeDb9Adfd9Ed82e47CAc3B ; < 5I13m5QQ8N8cy51KESaR2mDL5I55wo7T8x2tmIHO70Lt4M5cdYci2F3n0D3np6us > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14245213908666 ; -1 ; -0,00025 ; 0,00025 ; 4,2 ; -9,6 ; 6,2 ; -7 ; 8,3 ; 5,2 ; 0,61 ; NABRUBJU1923 ; e4BeEeB3Fb0cadf0cA9311E1b1BeACEc4Ff04Ea1FD3c5b92fd5DEfdDec5B7FDE ; < VMWd2947ZETt9W1f31A43IWr0qi36mVZD56K48zeY1hpiP5Dk2mGchzQqhgm2Ajp > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14356135514363 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; 9,7 ; -7,1 ; 4,2 ; 1,5 ; -8,1 ; -0,26 ; NABRUBSE1913 ; CFEC2EEcBbBb1DeeafCCFb15df5DE5F3AaeEfc23EAAc7796AbCafccccfB295Cb ; < k4BQNMe0S3z5vvHgc603VOkVjazfJUb1MHjve82ZCydzJQ9thHcLJH8QrfxXlByE > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14493273647751 ; -1 ; -0,00025 ; 0,00025 ; 6 ; 6,6 ; -4,7 ; -9,4 ; -4,2 ; 2,2 ; 0,83 ; NABRUBDE1952 ; eCDF1efbEd9A5dCAe31Dd6caEaC1291afaFBDD5eA47e5f04CC8dd6ffDAcFFfBD ; < igVHHCiciMhdR50Ua5qBQ8P78wR7J7kKSziAQP86MRJN7gaYs71rny9KLmWsq37R > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14658324252079 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; 9,6 ; 3,4 ; -9,9 ; 4,1 ; -2,5 ; -0,1 ; NABRUBJA2012 ; 3Ca0fdDEac1F7F27fD60Fb9bEdbac27Ac5fDAF1fdccAddCEfDbD63eFACd9f2bB ; < 29wt3xp2Fzi16Zl4TCm58t1w9v2C0KSPaC6KviMj0C8qddG8gQs3Rl9823OlDA9G > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14843838324108 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; 2,9 ; -0,6 ; -4,8 ; -8,3 ; 3,9 ; 0,85 ; NABRUBMA2085 ; bC1ACb5893DDdebAcFEB84a5Cfcc413BB5fa0B4FCAC5A1E1fc11a785f5fBB149 ; < SVgPlpQnc3lqwvsP2TdFTFY1f1isAZ3K4DiD65V0q7F71kzttFSqoC8v759lwOTf > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15053935326926 ; -1 ; -0,00025 ; 0,00025 ; 9,3 ; -0,2 ; -8,6 ; -5,2 ; 9 ; 4,1 ; -0,27 ; NABRUBMA2035 ; baABbCFB0bb7dbEc031Dd2231dddBAdcA35a7EDe2EeAB6beB6103641742DAded ; < ZEmHKXKs6JkkHxpf32m23aIdB8hhFnB9T9ns2RN2hfhp1F271oGGtWjhD26kE2ZW > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15296572539722 ; -1 ; -0,00025 ; 0,00025 ; -1,8 ; -3,8 ; -8,6 ; -1 ; 0,1 ; 8 ; -0,96 ; NABRUBJU2011 ; aAb2e5CBB2EBC4Dc375ed38eAb0ee3afF7eFbecE8B9bBdB53bcdd60fc1Fb999D ; < vO5dKp8162w054gagf5R50YKz1vBf0g1Sd3910qrKJ40W7mLJflcawmoUEAigO4N > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15565954699318 ; -1 ; -0,00025 ; 0,00025 ; 1,5 ; -2 ; 0,7 ; -8,2 ; 4,3 ; 5,9 ; -0,84 ; NABRUBSE2069 ; 35204BA3dA8888fB4B8D0Fc4781acBCc6da2EA49a4cb28afaAE870fe5d7C8F29 ; < qbOynA06C6B4qyx39EEA1wIzGL05coHP440B5Q6EI7Z48PT67Fq9a71oZ450YEfD > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15855331849885 ; -1 ; -0,00025 ; 0,00025 ; 4,3 ; 8 ; 2,6 ; -7,6 ; -0,9 ; 0,5 ; 0,07 ; NABRUBDE2078 ; CAebaDb4dcdbCFF7FcDA0CeBeBECa9C99ecBff3A32d962AA2ddbed33db3ebBd4 ; < BXbdOqwTNHLyvX62957Wn6W42f6bn8120Q91NP658dzt24K2gmA38CU8jwL3kIJS > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,16159986795705 ; -1 ; -0,00025 ; 0,00025 ; -3,6 ; -1,4 ; -1 ; 9,4 ; -8,8 ; 3 ; -0,45 ; NABRUBJA2157 ; 680d53DD08F71cCa7cd51BD4D3Ca3dB9ECCDCDeCACE1FC4abDbDDca67ab356D3 ; < HVmd5OQan6tSo3Yb9jL2VmCa6mjqg13cLHD5z4C8mZoBPV4366uEjK5ZgRWq7sU9 > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16501064331307 ; -1 ; -0,00025 ; 0,00025 ; 4,5 ; 4,9 ; 1,5 ; -7,9 ; 6,6 ; -7,4 ; 0,63 ; NABRUBMA2166 ; eaecB6cc7bEaDeE0fa3EA59E7d749Febb7fBCc8dc8d35AC36ea9DC21b280Ce9c ; < YcLj0dW1VZ74YLkcgsE3Uy9fxccQ1Izl4dDDUbQ5hz5yXOtCfR60Y8122t3GaynJ > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16875029946288 ; -1 ; -0,00025 ; 0,00025 ; -5,4 ; 8,3 ; -9,3 ; -0,9 ; -4,3 ; 6 ; -0,58 ; NABRUBMA2128 ; 15D1Fe7ABa8FC895db3FA2f31b5BAbbcEAE674F27ADBA19Be8D8aEEDFBdFF90b ; < 5aqMyQWVoLv900r5N037trOp17KH50PQiu6W9EC5Hi9OcOn44awxXS5s86CAUg4t > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,1725413998806 ; -1 ; -0,00025 ; 0,00025 ; -1,9 ; 3,6 ; 8,8 ; -8,4 ; 4,4 ; 6,1 ; -0,87 ; NABRUBJU2148 ; 8Eb2ACdfAeCC073F22abc3B1cCDfBa6308B7b0bF35Bf39CeA0FEA13DfEBeDBE8 ; < d7Vn70PFeob92XFfj4Niv4lk1NslUYvq0BTiZRmIo1qIkz9m45l3287X5svZRrg0 > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17673383383731 ; -1 ; -0,00025 ; 0,00025 ; 8,5 ; -3,6 ; -6,9 ; -2,8 ; -8,3 ; 2,1 ; -0,27 ; NABRUBSE2130 ; Dfb4BdbcFdEdBfa64a7a9eAc5CCDaB2Fd81aBdb6eF6a06A036a8C3Cc9deE6fa5 ; < iJz57Xy6tDW9SWtNhfZz25O8m6SeLB7KQkc7g3o1c3Hin3eOR02J22P9w7I514tz > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18115875640671 ; -1 ; -0,00025 ; 0,00025 ; 9,2 ; 3,3 ; -9,1 ; -6 ; 9,6 ; -7 ; -0,12 ; NABRUBDE2186 ; bbCe5A14250fDDaEA1F5EbBB2c76fcB3eba2cAf7A6AC2bD4CAFDcDBfeCb7DFb4 ; < FtI34q79Co8NT14DTEt19FmYxfmtff3Yr666YHsqcnMh544Xa54qqBF6Ufj2iNVT > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18578561347666 ; -1 ; -0,00025 ; 0,00025 ; 9,6 ; 6,8 ; 2 ; -9,6 ; 5,1 ; -6,2 ; 0,03 ; NABRUBJA2172 ; D4B5FeAbd5Bf6635efc2dfccbD12CEdBEE03Aecb8bAc2ebDaEa92CeB3aDdb67A ; < k38v0At8YIbjAXbO0h8XIsHa2QVT8P41QJVuS074bUll2182SUu6mgg1EzxB8YoF > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19083840952538 ; -1 ; -0,00025 ; 0,00025 ; -5,7 ; -5,6 ; 9,8 ; 9,2 ; -1,2 ; 2,9 ; 0,37 ; NABRUBMA2167 ; CA0EdfeFfc9BfF9fcb3fFD5933b96A05B47a39F0e1DC25aECcdAD8CFa3CbD5Ea ; < oPW1dBufssq1LUnK1H84Dv828NhEAL0rAt8v8ts04JW54c3ysoJ8DyeMv1f8Y448 > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19602939408026 ; -1 ; -0,00025 ; 0,00025 ; -3,5 ; -1,2 ; 8,6 ; -4 ; -2,8 ; -6,4 ; 0,11 ; NABRUBMA2126 ; fed12aCDf4Eeaae8AEfDBa498BCe5f5baAd3eF44bf33D0Abc8D3BeD967D25deE ; < nk0s72aab4KU8NxP5Di57dVNb9b90y6Iltu7bj0X5SUhH9543w3B6ks4y9xASA1E > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20145710341736 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; -0,8 ; 3,7 ; 8,4 ; -8,9 ; 2,2 ; -0,79 ; NABRUBJU2125 ; 77F7eFDBcabDaaD4d47Ca1d5da3dfAdD26B9C6bbebB7cEEcfaE917b3a5eaFBa1 ; < LtH7xCdIyURViVW1QB5c0jM67xJ9GmU7RdL2kSeN9I3059M2g999uz4Q0mUK52ru > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20718583919927 ; -1 ; -0,00025 ; 0,00025 ; 5,1 ; 8,3 ; -6,2 ; -5,9 ; -6,2 ; -2 ; 0,29 ; NABRUBSE2153 ; 56Caec1C2AFb5EeAe0bc1dcCb29DeFaDbdca32e78CCDACFDc67Bb85FAB4CBd3c ; < bcwt1s84AvUCro481ue580G4BRA7eDjzCQ4vl4F9B12o0C3cNuKybCTJ5FN4sBv6 > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,2131689540148 ; -1 ; -0,00025 ; 0,00025 ; 3,4 ; 1,7 ; 1,2 ; 6,9 ; 0,8 ; 7,7 ; 0,13 ; NABRUBDE2192 ; 2dCd740eDfCbDDCebc3CAdcc1dC59d7CE9dDF1A0CDbDcfc6Ab0BCd0DeC8a66EB ; < 4163pB13V4HV45KXfbli104pe8wp038Ug7CC8Lrz8R7GxuQPyDR16Cm1p9Td6nge > >										24
											
//	  < CALLS ; 24M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 24M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABRUB										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; FacEfABEc15492BA55AcaaAece7CFEE2CC5E36aabdCEDfD809e0FFe7BfDBA9Ad ; < zot500hG0Lxr6CaU30Mrg84xyiCd77v86G15eM2F1hV5cptLQ1Pzs9pcW497982h > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14021100829845 ; -1 ; -0,00025 ; 0,00025 ; 8,6 ; 6,1 ; -4 ; -7,1 ; -8,9 ; 3,3 ; -0,11 ; NABRUB16JA19 ; AeC73b4d6aF50E8dDff5FA9C4CF47DFfEA6F4E260ab6B8FeB7Abcb5BEd2ae115 ; < DZT5fnz4H0nbk5Vz6rqL9RqHdxehf75R445fQ86rmCZ2wI64AdkzcO51Ft17tK15 > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14072893010838 ; -1 ; -0,00025 ; 0,00025 ; 0,3 ; -8,6 ; 7,9 ; -3,8 ; 0,9 ; 7,1 ; -0,41 ; NABRUBMA1976 ; aE2504D6dEBaA32D1be7DD23ADAC7a2fb9F6ddF7c1EBcc7d8f54fff9dC4DCe2E ; < Rm340ZMA35919KNYf9t3A0WkLX8fi31q94207B14wVLcH49FyGT8MHQ77gH3KzY9 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14151878783416 ; -1 ; -0,00025 ; 0,00025 ; 8,3 ; -7,9 ; 2,2 ; 1,7 ; -8,7 ; 7,3 ; -0,08 ; NABRUBMA1940 ; d65BbBc2a1AD5afD3ceCA65FB4E542fFE47e9C5366EeDb9Adfd9Ed82e47CAc3B ; < 5I13m5QQ8N8cy51KESaR2mDL5I55wo7T8x2tmIHO70Lt4M5cdYci2F3n0D3np6us > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14245213908666 ; -1 ; -0,00025 ; 0,00025 ; 4,2 ; -9,6 ; 6,2 ; -7 ; 8,3 ; 5,2 ; 0,61 ; NABRUBJU1923 ; e4BeEeB3Fb0cadf0cA9311E1b1BeACEc4Ff04Ea1FD3c5b92fd5DEfdDec5B7FDE ; < VMWd2947ZETt9W1f31A43IWr0qi36mVZD56K48zeY1hpiP5Dk2mGchzQqhgm2Ajp > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14356135514363 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; 9,7 ; -7,1 ; 4,2 ; 1,5 ; -8,1 ; -0,26 ; NABRUBSE1913 ; CFEC2EEcBbBb1DeeafCCFb15df5DE5F3AaeEfc23EAAc7796AbCafccccfB295Cb ; < k4BQNMe0S3z5vvHgc603VOkVjazfJUb1MHjve82ZCydzJQ9thHcLJH8QrfxXlByE > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14493273647751 ; -1 ; -0,00025 ; 0,00025 ; 6 ; 6,6 ; -4,7 ; -9,4 ; -4,2 ; 2,2 ; 0,83 ; NABRUBDE1952 ; eCDF1efbEd9A5dCAe31Dd6caEaC1291afaFBDD5eA47e5f04CC8dd6ffDAcFFfBD ; < igVHHCiciMhdR50Ua5qBQ8P78wR7J7kKSziAQP86MRJN7gaYs71rny9KLmWsq37R > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14658324252079 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; 9,6 ; 3,4 ; -9,9 ; 4,1 ; -2,5 ; -0,1 ; NABRUBJA2012 ; 3Ca0fdDEac1F7F27fD60Fb9bEdbac27Ac5fDAF1fdccAddCEfDbD63eFACd9f2bB ; < 29wt3xp2Fzi16Zl4TCm58t1w9v2C0KSPaC6KviMj0C8qddG8gQs3Rl9823OlDA9G > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14843838324108 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; 2,9 ; -0,6 ; -4,8 ; -8,3 ; 3,9 ; 0,85 ; NABRUBMA2085 ; bC1ACb5893DDdebAcFEB84a5Cfcc413BB5fa0B4FCAC5A1E1fc11a785f5fBB149 ; < SVgPlpQnc3lqwvsP2TdFTFY1f1isAZ3K4DiD65V0q7F71kzttFSqoC8v759lwOTf > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15053935326926 ; -1 ; -0,00025 ; 0,00025 ; 9,3 ; -0,2 ; -8,6 ; -5,2 ; 9 ; 4,1 ; -0,27 ; NABRUBMA2035 ; baABbCFB0bb7dbEc031Dd2231dddBAdcA35a7EDe2EeAB6beB6103641742DAded ; < ZEmHKXKs6JkkHxpf32m23aIdB8hhFnB9T9ns2RN2hfhp1F271oGGtWjhD26kE2ZW > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15296572539722 ; -1 ; -0,00025 ; 0,00025 ; -1,8 ; -3,8 ; -8,6 ; -1 ; 0,1 ; 8 ; -0,96 ; NABRUBJU2011 ; aAb2e5CBB2EBC4Dc375ed38eAb0ee3afF7eFbecE8B9bBdB53bcdd60fc1Fb999D ; < vO5dKp8162w054gagf5R50YKz1vBf0g1Sd3910qrKJ40W7mLJflcawmoUEAigO4N > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15565954699318 ; -1 ; -0,00025 ; 0,00025 ; 1,5 ; -2 ; 0,7 ; -8,2 ; 4,3 ; 5,9 ; -0,84 ; NABRUBSE2069 ; 35204BA3dA8888fB4B8D0Fc4781acBCc6da2EA49a4cb28afaAE870fe5d7C8F29 ; < qbOynA06C6B4qyx39EEA1wIzGL05coHP440B5Q6EI7Z48PT67Fq9a71oZ450YEfD > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15855331849885 ; -1 ; -0,00025 ; 0,00025 ; 4,3 ; 8 ; 2,6 ; -7,6 ; -0,9 ; 0,5 ; 0,07 ; NABRUBDE2078 ; CAebaDb4dcdbCFF7FcDA0CeBeBECa9C99ecBff3A32d962AA2ddbed33db3ebBd4 ; < BXbdOqwTNHLyvX62957Wn6W42f6bn8120Q91NP658dzt24K2gmA38CU8jwL3kIJS > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,16159986795705 ; -1 ; -0,00025 ; 0,00025 ; -3,6 ; -1,4 ; -1 ; 9,4 ; -8,8 ; 3 ; -0,45 ; NABRUBJA2157 ; 680d53DD08F71cCa7cd51BD4D3Ca3dB9ECCDCDeCACE1FC4abDbDDca67ab356D3 ; < HVmd5OQan6tSo3Yb9jL2VmCa6mjqg13cLHD5z4C8mZoBPV4366uEjK5ZgRWq7sU9 > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16501064331307 ; -1 ; -0,00025 ; 0,00025 ; 4,5 ; 4,9 ; 1,5 ; -7,9 ; 6,6 ; -7,4 ; 0,63 ; NABRUBMA2166 ; eaecB6cc7bEaDeE0fa3EA59E7d749Febb7fBCc8dc8d35AC36ea9DC21b280Ce9c ; < YcLj0dW1VZ74YLkcgsE3Uy9fxccQ1Izl4dDDUbQ5hz5yXOtCfR60Y8122t3GaynJ > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16875029946288 ; -1 ; -0,00025 ; 0,00025 ; -5,4 ; 8,3 ; -9,3 ; -0,9 ; -4,3 ; 6 ; -0,58 ; NABRUBMA2128 ; 15D1Fe7ABa8FC895db3FA2f31b5BAbbcEAE674F27ADBA19Be8D8aEEDFBdFF90b ; < 5aqMyQWVoLv900r5N037trOp17KH50PQiu6W9EC5Hi9OcOn44awxXS5s86CAUg4t > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,1725413998806 ; -1 ; -0,00025 ; 0,00025 ; -1,9 ; 3,6 ; 8,8 ; -8,4 ; 4,4 ; 6,1 ; -0,87 ; NABRUBJU2148 ; 8Eb2ACdfAeCC073F22abc3B1cCDfBa6308B7b0bF35Bf39CeA0FEA13DfEBeDBE8 ; < d7Vn70PFeob92XFfj4Niv4lk1NslUYvq0BTiZRmIo1qIkz9m45l3287X5svZRrg0 > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17673383383731 ; -1 ; -0,00025 ; 0,00025 ; 8,5 ; -3,6 ; -6,9 ; -2,8 ; -8,3 ; 2,1 ; -0,27 ; NABRUBSE2130 ; Dfb4BdbcFdEdBfa64a7a9eAc5CCDaB2Fd81aBdb6eF6a06A036a8C3Cc9deE6fa5 ; < iJz57Xy6tDW9SWtNhfZz25O8m6SeLB7KQkc7g3o1c3Hin3eOR02J22P9w7I514tz > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18115875640671 ; -1 ; -0,00025 ; 0,00025 ; 9,2 ; 3,3 ; -9,1 ; -6 ; 9,6 ; -7 ; -0,12 ; NABRUBDE2186 ; bbCe5A14250fDDaEA1F5EbBB2c76fcB3eba2cAf7A6AC2bD4CAFDcDBfeCb7DFb4 ; < FtI34q79Co8NT14DTEt19FmYxfmtff3Yr666YHsqcnMh544Xa54qqBF6Ufj2iNVT > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18578561347666 ; -1 ; -0,00025 ; 0,00025 ; 9,6 ; 6,8 ; 2 ; -9,6 ; 5,1 ; -6,2 ; 0,03 ; NABRUBJA2172 ; D4B5FeAbd5Bf6635efc2dfccbD12CEdBEE03Aecb8bAc2ebDaEa92CeB3aDdb67A ; < k38v0At8YIbjAXbO0h8XIsHa2QVT8P41QJVuS074bUll2182SUu6mgg1EzxB8YoF > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19083840952538 ; -1 ; -0,00025 ; 0,00025 ; -5,7 ; -5,6 ; 9,8 ; 9,2 ; -1,2 ; 2,9 ; 0,37 ; NABRUBMA2167 ; CA0EdfeFfc9BfF9fcb3fFD5933b96A05B47a39F0e1DC25aECcdAD8CFa3CbD5Ea ; < oPW1dBufssq1LUnK1H84Dv828NhEAL0rAt8v8ts04JW54c3ysoJ8DyeMv1f8Y448 > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19602939408026 ; -1 ; -0,00025 ; 0,00025 ; -3,5 ; -1,2 ; 8,6 ; -4 ; -2,8 ; -6,4 ; 0,11 ; NABRUBMA2126 ; fed12aCDf4Eeaae8AEfDBa498BCe5f5baAd3eF44bf33D0Abc8D3BeD967D25deE ; < nk0s72aab4KU8NxP5Di57dVNb9b90y6Iltu7bj0X5SUhH9543w3B6ks4y9xASA1E > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20145710341736 ; -1 ; -0,00025 ; 0,00025 ; 0,7 ; -0,8 ; 3,7 ; 8,4 ; -8,9 ; 2,2 ; -0,79 ; NABRUBJU2125 ; 77F7eFDBcabDaaD4d47Ca1d5da3dfAdD26B9C6bbebB7cEEcfaE917b3a5eaFBa1 ; < LtH7xCdIyURViVW1QB5c0jM67xJ9GmU7RdL2kSeN9I3059M2g999uz4Q0mUK52ru > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20718583919927 ; -1 ; -0,00025 ; 0,00025 ; 5,1 ; 8,3 ; -6,2 ; -5,9 ; -6,2 ; -2 ; 0,29 ; NABRUBSE2153 ; 56Caec1C2AFb5EeAe0bc1dcCb29DeFaDbdca32e78CCDACFDc67Bb85FAB4CBd3c ; < bcwt1s84AvUCro481ue580G4BRA7eDjzCQ4vl4F9B12o0C3cNuKybCTJ5FN4sBv6 > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,2131689540148 ; -1 ; -0,00025 ; 0,00025 ; 3,4 ; 1,7 ; 1,2 ; 6,9 ; 0,8 ; 7,7 ; 0,13 ; NABRUBDE2192 ; 2dCd740eDfCbDDCebc3CAdcc1dC59d7CE9dDF1A0CDbDcfc6Ab0BCd0DeC8a66EB ; < 4163pB13V4HV45KXfbli104pe8wp038Ug7CC8Lrz8R7GxuQPyDR16Cm1p9Td6nge > >										24
											
//	  < CALLS ; 36M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 36M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABCNY										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; 161bF94D215ACAD73A0058eF56DEdc8a0EBE8aD3aC9b5D8C0EfCBceaf5eddde9 ; < p0lVtq04AW915sCuurd9IMo7ewAd02z5XuO8AZ899704v6BmU47xYIJZ31BIpeD1 > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14013006829845 ; -1 ; -0,00025 ; 0,00025 ; -4,7 ; -8 ; 1,6 ; -6,4 ; -2,2 ; 5 ; -0,33 ; NABCNY63JA19 ; D5CcdeC0dBafEb4EaA8bF25E5eBB81eCAAB6eDfeecffAA9B9DEa21ddaBeBdfd0 ; < sPy4Ie2907w1OC892rVqS2b46rCkA82BauCob0qY3551nHXgfysy7SiI6qr6HPG2 > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14050657721427 ; -1 ; -0,00025 ; 0,00025 ; -3,7 ; -9,8 ; 6 ; 9 ; 2,3 ; -6,5 ; -0,94 ; NABCNYMA1919 ; 3FE89Da5C79AcB527d3005b4EEBCEA7DE00E876D51dc6Ff4BDF2AEfD9FEFf9e5 ; < 5T6Dh67YAH7KW85Mz6xwR22dzec3AcZ4v665J8r90P2pzy5g8wdqnXL44f973f6u > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,1412403961573 ; -1 ; -0,00025 ; 0,00025 ; 6,1 ; -8,9 ; -1 ; 2,4 ; -0,8 ; -3,6 ; -0,81 ; NABCNYMA1913 ; aaaDcBCEf8d3BfCb78116D7D631aaE82DDABCCE4B9fC3d14deE0CBfafeB9d5d8 ; < lTs2X2R2l2Bnqy0mSR8Ozke60QMh85g58Syj5F8MNUT4AaHBhkoMNE1Zlozev5oI > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14215525993933 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -4,6 ; -3,9 ; 8,4 ; 3,9 ; 1,2 ; 0,65 ; NABCNYJU1976 ; ccCA7CEDb3E1E1E5AC4FF643b8DAf5912CaBBA70454aCEEF499Ec24DeDB6c236 ; < 432VWTUx6hi6NcQDdr9Tv41312wj0kOb192AKpje19XkypR9iH0o2oS1NzT48QCy > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14344236397449 ; -1 ; -0,00025 ; 0,00025 ; 8,6 ; -9,9 ; 6,3 ; 1,1 ; 9,3 ; -8,5 ; -0,99 ; NABCNYSE1988 ; BaBCECC0DFaEA9ACFbE8142cFb4e0e9ce7DB5Ce1c9cF02A83eC2a8AEFfDf7f0a ; < tXm4UQlCP275o5JDzbzw7YINcn916if9ds0K29fDVYbq4Uso0SX3OhV2luF0QH5Y > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14496911077331 ; -1 ; -0,00025 ; 0,00025 ; -6,9 ; 7,8 ; -3,2 ; -4,8 ; -3,5 ; -1,1 ; -0,37 ; NABCNYDE1951 ; ADD9EbCecA8438CcDe94BbAB1E7DAF3cFd4daab21fc9efD3abEbcA63C7BcbDb2 ; < U63652m61QS6k92NGJv4Q32MC3k2Z61t30l8RjBiX9N7Fd1jh1Rsrw6Egkbtrl42 > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14671813659638 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; -4,2 ; 2,5 ; -2,7 ; 6,4 ; 3,7 ; 0,87 ; NABCNYJA2019 ; 1C7fB2eEcAbB127Ef51258CeDedFB9Cbe6A4a27Ff2AB32c3FEa70DC0Ff1DfAED ; < 49e0T6etNJX15426TrFIG0CDHsu8Cy9PCDLx8gv197X0M9LdmJC1xSPE78B8ao2H > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,1486789936402 ; -1 ; -0,00025 ; 0,00025 ; 2,3 ; 3 ; 8,2 ; -3,4 ; 9,2 ; -9,5 ; 0,66 ; NABCNYMA2034 ; 6DceAaECEfca15DD8FfcEbCdAD98b6fBCB0fa4Fc4dBEe6B34eBAEF2dEf1eEfDe ; < 0DUz3452QlPjWBd1G19zRAtO92C917AFOABHb5422IlwCe98W13dc9xnIt60TWeb > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15075513290672 ; -1 ; -0,00025 ; 0,00025 ; -7 ; 6,2 ; 9,4 ; -6,4 ; -3,5 ; 0,4 ; -0,08 ; NABCNYMA2082 ; 7F0769eeCCaFae5EfA9c6a6Ef0cA5C8de1BeEE7AdCcFcebE1A247f6adad07CBa ; < PE4cFA9OIt8UU9pY0lN0Fr3RR6mJwzPG6mVe0ihL2008owKCoeWe7d22JLH1Jhj1 > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15323719633868 ; -1 ; -0,00025 ; 0,00025 ; -3,2 ; 0,4 ; -1,5 ; -1,1 ; 3,2 ; -5,3 ; 0,98 ; NABCNYJU2013 ; ACCDCc2deeCC4bC7DDCdB8FbbD961E44bF3bBcE5ddAC7eEeE19AAdCf0fA413EE ; < rD22agS9q4IU2FbPL6YDE6L70AoKTOybcW3bcTA4MM25Em34cfnv9RAR0BR422XB > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15592473278381 ; -1 ; -0,00025 ; 0,00025 ; 4,6 ; -9,9 ; 4,7 ; -9,7 ; -0,5 ; -9,5 ; 0,51 ; NABCNYSE2084 ; Aa37CbE4aCAc30B2614FeDcC3Fc75423eF99b8eDC0A53DcdcC6AddfABE8A8725 ; < 683lRCz8K4tn2P0G1adTNZ03e1T15V4W97UJtS87s2CY122M2e40K2w1pMUPnt6B > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15882725978783 ; -1 ; -0,00025 ; 0,00025 ; 8,3 ; 7,8 ; -2,4 ; 9,9 ; 8,8 ; 9,1 ; -0,16 ; NABCNYDE2024 ; CfCFd78c988Cb402f6aFc0BdfeAACDabFAc8CbcadAbac6aDdAB32cABFC12eBFE ; < 3wV37G6b0yfQXP7hoOEEE94u14i7Q1t4qnRMpXqar0ACTup0F9m91ll3vb0t6WZ2 > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,1619069767695 ; -1 ; -0,00025 ; 0,00025 ; -7,8 ; -7,6 ; -3,6 ; -4,9 ; 8,6 ; -1,4 ; 0,48 ; NABCNYJA2135 ; FEFfc7CC0fCeF52DeFadAABc6B0b9fc19dd17A0172cddA7B5fbaFb1Dc5E543eE ; < g6j72OP1NCJ7hSL1JWIhZKsGzgA3Z74E1q35aWic66K2GJQ7DvqPRLK2puS6K5N7 > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16530819671831 ; -1 ; -0,00025 ; 0,00025 ; 6,8 ; -5,1 ; -2,8 ; 5,1 ; -2,5 ; 9,5 ; -0,6 ; NABCNYMA2159 ; 9dA7b7Ed9B54c6ecD3d8eDDEaFE7B352FDcedEbBbeF7F3dcD5bCEDF9bf1fCfc3 ; < DA33Sf075W65tqpGv6o3aier6qe9Ff33Ai5phyJ514sXml6EAdz1Q526Xq7133Gd > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16903832023362 ; -1 ; -0,00025 ; 0,00025 ; 6,5 ; -4 ; -3,6 ; 8 ; 4,1 ; -3,8 ; -0,69 ; NABCNYMA2193 ; E5CA2EdCEbfCbDaC21ABBF6eB4bD5ADb8C4aFEF00bF7eCd0dC23Ffe9B3BaFDdf ; < o2wb9enLSJYxIiLu1N7Y8r75jFbd1ND028A0Q39lVZ387uVQVtFgaDfj6C4SM47p > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,17293790643596 ; -1 ; -0,00025 ; 0,00025 ; -1,4 ; -3,8 ; -5,3 ; -7,7 ; -3,7 ; -3,6 ; 0,73 ; NABCNYJU2119 ; 8DA5DAC9fFeB4A29dbABe0C5EfdcDAF9F0ecFaB55DA212DbFf9BadBAde6efbb7 ; < 1j3H5Mv1T9y9yZatR41AlPWzvg5M1rk2a4ZhsmZR5r297r7lze7IH0HEYPx7xp7A > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17715756273991 ; -1 ; -0,00025 ; 0,00025 ; -5,7 ; 6,2 ; -5,9 ; -6,2 ; -8,9 ; 5,1 ; -0,78 ; NABCNYSE2194 ; 8aCFBF63ecFEDF9FA8B4F8d2A223FEbD41bAbdF6d55b940c6e7aDEaFEa447edC ; < l0A5OtztzB3FXEAWg3US0M7LOVV2DwffPWOwGMuuGwJYWXQHgXdaz5zC4SGz00ah > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18146754007652 ; -1 ; -0,00025 ; 0,00025 ; -3,7 ; -9,9 ; -9,4 ; -2,7 ; 6,1 ; -3,8 ; 0,85 ; NABCNYDE2126 ; 96BF911B9FbbFE2BABCF3de329dfA1Ee6a7A9d9aE03bb158ddD77B6fE13d1eD1 ; < 7o1Z7fyB8zVpisPimcs6761x7nN3s6mMA9Hv8Kg8Um601hot1Wl0o3uk3PCsBztq > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18614168395367 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -8,9 ; -1,2 ; -2,2 ; -4,6 ; 6,4 ; -0,71 ; NABCNYJA2171 ; DFbedE0AE0013C7AaaC5A6eb59f9ceeEadEfeEb9dEf9c8Ca5fBc4da7AeA6C19D ; < uTy8gn6WgMdiVF13l3At3Puj8g2za7fha3462ypB6PkKYzFI254X1j7fuAgkyll6 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19119718340949 ; -1 ; -0,00025 ; 0,00025 ; 5,9 ; -8,2 ; 9,1 ; 3,4 ; 0,5 ; -2,1 ; -0,66 ; NABCNYMA2142 ; Ade71ADeE10C9caaC3eBB7fD450AdEaAbf0eCEEEC67e48bB7e9B40b8C5e55424 ; < 4lLyJsKpElf6AU13nG9i98zD0ZzkxhNXFT60Bi0nS53fE7Frt9TJw1UTmIGg5YTX > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19645643893813 ; -1 ; -0,00025 ; 0,00025 ; 0,2 ; 8,3 ; -8,8 ; 3,9 ; 2,8 ; -4,9 ; -0,49 ; NABCNYMA2175 ; 7F2CABaa9CDD9e4BBBacFF2A9Fec2beCf919b5ba4DEcC9DeD7af4979DDC1Aa9d ; < o465vaEGkP4jxV046jPR698E6QfUL6wNqSMTz559uP90091V25ZAUKqE44gNgqFH > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20189924727131 ; -1 ; -0,00025 ; 0,00025 ; -7,5 ; 4,6 ; -2,4 ; -9,6 ; 9,3 ; 4,5 ; -0,38 ; NABCNYJU2159 ; 8dAfc3bDc35e1fED2c8CCD4aafbFEcefdedBddFDbB29BBabbd0aB1B9EDa1BaAc ; < GU32kzM05GZL59VvRv825Z2dhzl0goXPMZ4N84vz7k36l1VKTLAO582o0Ok71v98 > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20770100332001 ; -1 ; -0,00025 ; 0,00025 ; 4 ; 3,5 ; 8 ; -0,6 ; 4,7 ; -1 ; -0,66 ; NABCNYSE2122 ; 3dfccB7abEba4dcBb8dEcCaaccfdB1e0CadA3Eef4D33cfc3Fd4cAEFB8dacEdD0 ; < 47kI1e3v4r773628TG4Y38VfKc20k9P3YL9DA7R9UrQ08P7hOWyeC481A3tD6k7Z > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21380381841504 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 0,1 ; -3,7 ; 8,1 ; 0,3 ; -3,2 ; 0,94 ; NABCNYDE2171 ; AD5e5a3f0A9fBcb9aFcAd2Ef765d3FFffb4AFedBaBbAD9BBA9Fb4AAEE0B95F12 ; < M3w1D4447l4x7Z0hi8rp816U6KMu8oMI99T8CxOnEvxy92CYW2LgNiDWS4NeLdN7 > >										24
											
//	  < CALLS ; 3M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 3M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABCNY										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; 161bF94D215ACAD73A0058eF56DEdc8a0EBE8aD3aC9b5D8C0EfCBceaf5eddde9 ; < p0lVtq04AW915sCuurd9IMo7ewAd02z5XuO8AZ899704v6BmU47xYIJZ31BIpeD1 > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14013006829845 ; -1 ; -0,00025 ; 0,00025 ; -4,7 ; -8 ; 1,6 ; -6,4 ; -2,2 ; 5 ; -0,33 ; NABCNY63JA19 ; D5CcdeC0dBafEb4EaA8bF25E5eBB81eCAAB6eDfeecffAA9B9DEa21ddaBeBdfd0 ; < sPy4Ie2907w1OC892rVqS2b46rCkA82BauCob0qY3551nHXgfysy7SiI6qr6HPG2 > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14050657721427 ; -1 ; -0,00025 ; 0,00025 ; -3,7 ; -9,8 ; 6 ; 9 ; 2,3 ; -6,5 ; -0,94 ; NABCNYMA1919 ; 3FE89Da5C79AcB527d3005b4EEBCEA7DE00E876D51dc6Ff4BDF2AEfD9FEFf9e5 ; < 5T6Dh67YAH7KW85Mz6xwR22dzec3AcZ4v665J8r90P2pzy5g8wdqnXL44f973f6u > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,1412403961573 ; -1 ; -0,00025 ; 0,00025 ; 6,1 ; -8,9 ; -1 ; 2,4 ; -0,8 ; -3,6 ; -0,81 ; NABCNYMA1913 ; aaaDcBCEf8d3BfCb78116D7D631aaE82DDABCCE4B9fC3d14deE0CBfafeB9d5d8 ; < lTs2X2R2l2Bnqy0mSR8Ozke60QMh85g58Syj5F8MNUT4AaHBhkoMNE1Zlozev5oI > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14215525993933 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -4,6 ; -3,9 ; 8,4 ; 3,9 ; 1,2 ; 0,65 ; NABCNYJU1976 ; ccCA7CEDb3E1E1E5AC4FF643b8DAf5912CaBBA70454aCEEF499Ec24DeDB6c236 ; < 432VWTUx6hi6NcQDdr9Tv41312wj0kOb192AKpje19XkypR9iH0o2oS1NzT48QCy > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14344236397449 ; -1 ; -0,00025 ; 0,00025 ; 8,6 ; -9,9 ; 6,3 ; 1,1 ; 9,3 ; -8,5 ; -0,99 ; NABCNYSE1988 ; BaBCECC0DFaEA9ACFbE8142cFb4e0e9ce7DB5Ce1c9cF02A83eC2a8AEFfDf7f0a ; < tXm4UQlCP275o5JDzbzw7YINcn916if9ds0K29fDVYbq4Uso0SX3OhV2luF0QH5Y > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14496911077331 ; -1 ; -0,00025 ; 0,00025 ; -6,9 ; 7,8 ; -3,2 ; -4,8 ; -3,5 ; -1,1 ; -0,37 ; NABCNYDE1951 ; ADD9EbCecA8438CcDe94BbAB1E7DAF3cFd4daab21fc9efD3abEbcA63C7BcbDb2 ; < U63652m61QS6k92NGJv4Q32MC3k2Z61t30l8RjBiX9N7Fd1jh1Rsrw6Egkbtrl42 > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14671813659638 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; -4,2 ; 2,5 ; -2,7 ; 6,4 ; 3,7 ; 0,87 ; NABCNYJA2019 ; 1C7fB2eEcAbB127Ef51258CeDedFB9Cbe6A4a27Ff2AB32c3FEa70DC0Ff1DfAED ; < 49e0T6etNJX15426TrFIG0CDHsu8Cy9PCDLx8gv197X0M9LdmJC1xSPE78B8ao2H > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,1486789936402 ; -1 ; -0,00025 ; 0,00025 ; 2,3 ; 3 ; 8,2 ; -3,4 ; 9,2 ; -9,5 ; 0,66 ; NABCNYMA2034 ; 6DceAaECEfca15DD8FfcEbCdAD98b6fBCB0fa4Fc4dBEe6B34eBAEF2dEf1eEfDe ; < 0DUz3452QlPjWBd1G19zRAtO92C917AFOABHb5422IlwCe98W13dc9xnIt60TWeb > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15075513290672 ; -1 ; -0,00025 ; 0,00025 ; -7 ; 6,2 ; 9,4 ; -6,4 ; -3,5 ; 0,4 ; -0,08 ; NABCNYMA2082 ; 7F0769eeCCaFae5EfA9c6a6Ef0cA5C8de1BeEE7AdCcFcebE1A247f6adad07CBa ; < PE4cFA9OIt8UU9pY0lN0Fr3RR6mJwzPG6mVe0ihL2008owKCoeWe7d22JLH1Jhj1 > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15323719633868 ; -1 ; -0,00025 ; 0,00025 ; -3,2 ; 0,4 ; -1,5 ; -1,1 ; 3,2 ; -5,3 ; 0,98 ; NABCNYJU2013 ; ACCDCc2deeCC4bC7DDCdB8FbbD961E44bF3bBcE5ddAC7eEeE19AAdCf0fA413EE ; < rD22agS9q4IU2FbPL6YDE6L70AoKTOybcW3bcTA4MM25Em34cfnv9RAR0BR422XB > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15592473278381 ; -1 ; -0,00025 ; 0,00025 ; 4,6 ; -9,9 ; 4,7 ; -9,7 ; -0,5 ; -9,5 ; 0,51 ; NABCNYSE2084 ; Aa37CbE4aCAc30B2614FeDcC3Fc75423eF99b8eDC0A53DcdcC6AddfABE8A8725 ; < 683lRCz8K4tn2P0G1adTNZ03e1T15V4W97UJtS87s2CY122M2e40K2w1pMUPnt6B > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15882725978783 ; -1 ; -0,00025 ; 0,00025 ; 8,3 ; 7,8 ; -2,4 ; 9,9 ; 8,8 ; 9,1 ; -0,16 ; NABCNYDE2024 ; CfCFd78c988Cb402f6aFc0BdfeAACDabFAc8CbcadAbac6aDdAB32cABFC12eBFE ; < 3wV37G6b0yfQXP7hoOEEE94u14i7Q1t4qnRMpXqar0ACTup0F9m91ll3vb0t6WZ2 > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,1619069767695 ; -1 ; -0,00025 ; 0,00025 ; -7,8 ; -7,6 ; -3,6 ; -4,9 ; 8,6 ; -1,4 ; 0,48 ; NABCNYJA2135 ; FEFfc7CC0fCeF52DeFadAABc6B0b9fc19dd17A0172cddA7B5fbaFb1Dc5E543eE ; < g6j72OP1NCJ7hSL1JWIhZKsGzgA3Z74E1q35aWic66K2GJQ7DvqPRLK2puS6K5N7 > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16530819671831 ; -1 ; -0,00025 ; 0,00025 ; 6,8 ; -5,1 ; -2,8 ; 5,1 ; -2,5 ; 9,5 ; -0,6 ; NABCNYMA2159 ; 9dA7b7Ed9B54c6ecD3d8eDDEaFE7B352FDcedEbBbeF7F3dcD5bCEDF9bf1fCfc3 ; < DA33Sf075W65tqpGv6o3aier6qe9Ff33Ai5phyJ514sXml6EAdz1Q526Xq7133Gd > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16903832023362 ; -1 ; -0,00025 ; 0,00025 ; 6,5 ; -4 ; -3,6 ; 8 ; 4,1 ; -3,8 ; -0,69 ; NABCNYMA2193 ; E5CA2EdCEbfCbDaC21ABBF6eB4bD5ADb8C4aFEF00bF7eCd0dC23Ffe9B3BaFDdf ; < o2wb9enLSJYxIiLu1N7Y8r75jFbd1ND028A0Q39lVZ387uVQVtFgaDfj6C4SM47p > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,17293790643596 ; -1 ; -0,00025 ; 0,00025 ; -1,4 ; -3,8 ; -5,3 ; -7,7 ; -3,7 ; -3,6 ; 0,73 ; NABCNYJU2119 ; 8DA5DAC9fFeB4A29dbABe0C5EfdcDAF9F0ecFaB55DA212DbFf9BadBAde6efbb7 ; < 1j3H5Mv1T9y9yZatR41AlPWzvg5M1rk2a4ZhsmZR5r297r7lze7IH0HEYPx7xp7A > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17715756273991 ; -1 ; -0,00025 ; 0,00025 ; -5,7 ; 6,2 ; -5,9 ; -6,2 ; -8,9 ; 5,1 ; -0,78 ; NABCNYSE2194 ; 8aCFBF63ecFEDF9FA8B4F8d2A223FEbD41bAbdF6d55b940c6e7aDEaFEa447edC ; < l0A5OtztzB3FXEAWg3US0M7LOVV2DwffPWOwGMuuGwJYWXQHgXdaz5zC4SGz00ah > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18146754007652 ; -1 ; -0,00025 ; 0,00025 ; -3,7 ; -9,9 ; -9,4 ; -2,7 ; 6,1 ; -3,8 ; 0,85 ; NABCNYDE2126 ; 96BF911B9FbbFE2BABCF3de329dfA1Ee6a7A9d9aE03bb158ddD77B6fE13d1eD1 ; < 7o1Z7fyB8zVpisPimcs6761x7nN3s6mMA9Hv8Kg8Um601hot1Wl0o3uk3PCsBztq > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18614168395367 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -8,9 ; -1,2 ; -2,2 ; -4,6 ; 6,4 ; -0,71 ; NABCNYJA2171 ; DFbedE0AE0013C7AaaC5A6eb59f9ceeEadEfeEb9dEf9c8Ca5fBc4da7AeA6C19D ; < uTy8gn6WgMdiVF13l3At3Puj8g2za7fha3462ypB6PkKYzFI254X1j7fuAgkyll6 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19119718340949 ; -1 ; -0,00025 ; 0,00025 ; 5,9 ; -8,2 ; 9,1 ; 3,4 ; 0,5 ; -2,1 ; -0,66 ; NABCNYMA2142 ; Ade71ADeE10C9caaC3eBB7fD450AdEaAbf0eCEEEC67e48bB7e9B40b8C5e55424 ; < 4lLyJsKpElf6AU13nG9i98zD0ZzkxhNXFT60Bi0nS53fE7Frt9TJw1UTmIGg5YTX > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19645643893813 ; -1 ; -0,00025 ; 0,00025 ; 0,2 ; 8,3 ; -8,8 ; 3,9 ; 2,8 ; -4,9 ; -0,49 ; NABCNYMA2175 ; 7F2CABaa9CDD9e4BBBacFF2A9Fec2beCf919b5ba4DEcC9DeD7af4979DDC1Aa9d ; < o465vaEGkP4jxV046jPR698E6QfUL6wNqSMTz559uP90091V25ZAUKqE44gNgqFH > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20189924727131 ; -1 ; -0,00025 ; 0,00025 ; -7,5 ; 4,6 ; -2,4 ; -9,6 ; 9,3 ; 4,5 ; -0,38 ; NABCNYJU2159 ; 8dAfc3bDc35e1fED2c8CCD4aafbFEcefdedBddFDbB29BBabbd0aB1B9EDa1BaAc ; < GU32kzM05GZL59VvRv825Z2dhzl0goXPMZ4N84vz7k36l1VKTLAO582o0Ok71v98 > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20770100332001 ; -1 ; -0,00025 ; 0,00025 ; 4 ; 3,5 ; 8 ; -0,6 ; 4,7 ; -1 ; -0,66 ; NABCNYSE2122 ; 3dfccB7abEba4dcBb8dEcCaaccfdB1e0CadA3Eef4D33cfc3Fd4cAEFB8dacEdD0 ; < 47kI1e3v4r773628TG4Y38VfKc20k9P3YL9DA7R9UrQ08P7hOWyeC481A3tD6k7Z > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21380381841504 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 0,1 ; -3,7 ; 8,1 ; 0,3 ; -3,2 ; 0,94 ; NABCNYDE2171 ; AD5e5a3f0A9fBcb9aFcAd2Ef765d3FFffb4AFedBaBbAD9BBA9Fb4AAEE0B95F12 ; < M3w1D4447l4x7Z0hi8rp816U6KMu8oMI99T8CxOnEvxy92CYW2LgNiDWS4NeLdN7 > >										24
											
//	  < CALLS ; 6M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 6M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABCNY										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; 161bF94D215ACAD73A0058eF56DEdc8a0EBE8aD3aC9b5D8C0EfCBceaf5eddde9 ; < p0lVtq04AW915sCuurd9IMo7ewAd02z5XuO8AZ899704v6BmU47xYIJZ31BIpeD1 > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14013006829845 ; -1 ; -0,00025 ; 0,00025 ; -4,7 ; -8 ; 1,6 ; -6,4 ; -2,2 ; 5 ; -0,33 ; NABCNY63JA19 ; D5CcdeC0dBafEb4EaA8bF25E5eBB81eCAAB6eDfeecffAA9B9DEa21ddaBeBdfd0 ; < sPy4Ie2907w1OC892rVqS2b46rCkA82BauCob0qY3551nHXgfysy7SiI6qr6HPG2 > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14050657721427 ; -1 ; -0,00025 ; 0,00025 ; -3,7 ; -9,8 ; 6 ; 9 ; 2,3 ; -6,5 ; -0,94 ; NABCNYMA1919 ; 3FE89Da5C79AcB527d3005b4EEBCEA7DE00E876D51dc6Ff4BDF2AEfD9FEFf9e5 ; < 5T6Dh67YAH7KW85Mz6xwR22dzec3AcZ4v665J8r90P2pzy5g8wdqnXL44f973f6u > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,1412403961573 ; -1 ; -0,00025 ; 0,00025 ; 6,1 ; -8,9 ; -1 ; 2,4 ; -0,8 ; -3,6 ; -0,81 ; NABCNYMA1913 ; aaaDcBCEf8d3BfCb78116D7D631aaE82DDABCCE4B9fC3d14deE0CBfafeB9d5d8 ; < lTs2X2R2l2Bnqy0mSR8Ozke60QMh85g58Syj5F8MNUT4AaHBhkoMNE1Zlozev5oI > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14215525993933 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -4,6 ; -3,9 ; 8,4 ; 3,9 ; 1,2 ; 0,65 ; NABCNYJU1976 ; ccCA7CEDb3E1E1E5AC4FF643b8DAf5912CaBBA70454aCEEF499Ec24DeDB6c236 ; < 432VWTUx6hi6NcQDdr9Tv41312wj0kOb192AKpje19XkypR9iH0o2oS1NzT48QCy > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14344236397449 ; -1 ; -0,00025 ; 0,00025 ; 8,6 ; -9,9 ; 6,3 ; 1,1 ; 9,3 ; -8,5 ; -0,99 ; NABCNYSE1988 ; BaBCECC0DFaEA9ACFbE8142cFb4e0e9ce7DB5Ce1c9cF02A83eC2a8AEFfDf7f0a ; < tXm4UQlCP275o5JDzbzw7YINcn916if9ds0K29fDVYbq4Uso0SX3OhV2luF0QH5Y > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14496911077331 ; -1 ; -0,00025 ; 0,00025 ; -6,9 ; 7,8 ; -3,2 ; -4,8 ; -3,5 ; -1,1 ; -0,37 ; NABCNYDE1951 ; ADD9EbCecA8438CcDe94BbAB1E7DAF3cFd4daab21fc9efD3abEbcA63C7BcbDb2 ; < U63652m61QS6k92NGJv4Q32MC3k2Z61t30l8RjBiX9N7Fd1jh1Rsrw6Egkbtrl42 > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14671813659638 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; -4,2 ; 2,5 ; -2,7 ; 6,4 ; 3,7 ; 0,87 ; NABCNYJA2019 ; 1C7fB2eEcAbB127Ef51258CeDedFB9Cbe6A4a27Ff2AB32c3FEa70DC0Ff1DfAED ; < 49e0T6etNJX15426TrFIG0CDHsu8Cy9PCDLx8gv197X0M9LdmJC1xSPE78B8ao2H > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,1486789936402 ; -1 ; -0,00025 ; 0,00025 ; 2,3 ; 3 ; 8,2 ; -3,4 ; 9,2 ; -9,5 ; 0,66 ; NABCNYMA2034 ; 6DceAaECEfca15DD8FfcEbCdAD98b6fBCB0fa4Fc4dBEe6B34eBAEF2dEf1eEfDe ; < 0DUz3452QlPjWBd1G19zRAtO92C917AFOABHb5422IlwCe98W13dc9xnIt60TWeb > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15075513290672 ; -1 ; -0,00025 ; 0,00025 ; -7 ; 6,2 ; 9,4 ; -6,4 ; -3,5 ; 0,4 ; -0,08 ; NABCNYMA2082 ; 7F0769eeCCaFae5EfA9c6a6Ef0cA5C8de1BeEE7AdCcFcebE1A247f6adad07CBa ; < PE4cFA9OIt8UU9pY0lN0Fr3RR6mJwzPG6mVe0ihL2008owKCoeWe7d22JLH1Jhj1 > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15323719633868 ; -1 ; -0,00025 ; 0,00025 ; -3,2 ; 0,4 ; -1,5 ; -1,1 ; 3,2 ; -5,3 ; 0,98 ; NABCNYJU2013 ; ACCDCc2deeCC4bC7DDCdB8FbbD961E44bF3bBcE5ddAC7eEeE19AAdCf0fA413EE ; < rD22agS9q4IU2FbPL6YDE6L70AoKTOybcW3bcTA4MM25Em34cfnv9RAR0BR422XB > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15592473278381 ; -1 ; -0,00025 ; 0,00025 ; 4,6 ; -9,9 ; 4,7 ; -9,7 ; -0,5 ; -9,5 ; 0,51 ; NABCNYSE2084 ; Aa37CbE4aCAc30B2614FeDcC3Fc75423eF99b8eDC0A53DcdcC6AddfABE8A8725 ; < 683lRCz8K4tn2P0G1adTNZ03e1T15V4W97UJtS87s2CY122M2e40K2w1pMUPnt6B > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15882725978783 ; -1 ; -0,00025 ; 0,00025 ; 8,3 ; 7,8 ; -2,4 ; 9,9 ; 8,8 ; 9,1 ; -0,16 ; NABCNYDE2024 ; CfCFd78c988Cb402f6aFc0BdfeAACDabFAc8CbcadAbac6aDdAB32cABFC12eBFE ; < 3wV37G6b0yfQXP7hoOEEE94u14i7Q1t4qnRMpXqar0ACTup0F9m91ll3vb0t6WZ2 > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,1619069767695 ; -1 ; -0,00025 ; 0,00025 ; -7,8 ; -7,6 ; -3,6 ; -4,9 ; 8,6 ; -1,4 ; 0,48 ; NABCNYJA2135 ; FEFfc7CC0fCeF52DeFadAABc6B0b9fc19dd17A0172cddA7B5fbaFb1Dc5E543eE ; < g6j72OP1NCJ7hSL1JWIhZKsGzgA3Z74E1q35aWic66K2GJQ7DvqPRLK2puS6K5N7 > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16530819671831 ; -1 ; -0,00025 ; 0,00025 ; 6,8 ; -5,1 ; -2,8 ; 5,1 ; -2,5 ; 9,5 ; -0,6 ; NABCNYMA2159 ; 9dA7b7Ed9B54c6ecD3d8eDDEaFE7B352FDcedEbBbeF7F3dcD5bCEDF9bf1fCfc3 ; < DA33Sf075W65tqpGv6o3aier6qe9Ff33Ai5phyJ514sXml6EAdz1Q526Xq7133Gd > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16903832023362 ; -1 ; -0,00025 ; 0,00025 ; 6,5 ; -4 ; -3,6 ; 8 ; 4,1 ; -3,8 ; -0,69 ; NABCNYMA2193 ; E5CA2EdCEbfCbDaC21ABBF6eB4bD5ADb8C4aFEF00bF7eCd0dC23Ffe9B3BaFDdf ; < o2wb9enLSJYxIiLu1N7Y8r75jFbd1ND028A0Q39lVZ387uVQVtFgaDfj6C4SM47p > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,17293790643596 ; -1 ; -0,00025 ; 0,00025 ; -1,4 ; -3,8 ; -5,3 ; -7,7 ; -3,7 ; -3,6 ; 0,73 ; NABCNYJU2119 ; 8DA5DAC9fFeB4A29dbABe0C5EfdcDAF9F0ecFaB55DA212DbFf9BadBAde6efbb7 ; < 1j3H5Mv1T9y9yZatR41AlPWzvg5M1rk2a4ZhsmZR5r297r7lze7IH0HEYPx7xp7A > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17715756273991 ; -1 ; -0,00025 ; 0,00025 ; -5,7 ; 6,2 ; -5,9 ; -6,2 ; -8,9 ; 5,1 ; -0,78 ; NABCNYSE2194 ; 8aCFBF63ecFEDF9FA8B4F8d2A223FEbD41bAbdF6d55b940c6e7aDEaFEa447edC ; < l0A5OtztzB3FXEAWg3US0M7LOVV2DwffPWOwGMuuGwJYWXQHgXdaz5zC4SGz00ah > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18146754007652 ; -1 ; -0,00025 ; 0,00025 ; -3,7 ; -9,9 ; -9,4 ; -2,7 ; 6,1 ; -3,8 ; 0,85 ; NABCNYDE2126 ; 96BF911B9FbbFE2BABCF3de329dfA1Ee6a7A9d9aE03bb158ddD77B6fE13d1eD1 ; < 7o1Z7fyB8zVpisPimcs6761x7nN3s6mMA9Hv8Kg8Um601hot1Wl0o3uk3PCsBztq > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18614168395367 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -8,9 ; -1,2 ; -2,2 ; -4,6 ; 6,4 ; -0,71 ; NABCNYJA2171 ; DFbedE0AE0013C7AaaC5A6eb59f9ceeEadEfeEb9dEf9c8Ca5fBc4da7AeA6C19D ; < uTy8gn6WgMdiVF13l3At3Puj8g2za7fha3462ypB6PkKYzFI254X1j7fuAgkyll6 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19119718340949 ; -1 ; -0,00025 ; 0,00025 ; 5,9 ; -8,2 ; 9,1 ; 3,4 ; 0,5 ; -2,1 ; -0,66 ; NABCNYMA2142 ; Ade71ADeE10C9caaC3eBB7fD450AdEaAbf0eCEEEC67e48bB7e9B40b8C5e55424 ; < 4lLyJsKpElf6AU13nG9i98zD0ZzkxhNXFT60Bi0nS53fE7Frt9TJw1UTmIGg5YTX > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19645643893813 ; -1 ; -0,00025 ; 0,00025 ; 0,2 ; 8,3 ; -8,8 ; 3,9 ; 2,8 ; -4,9 ; -0,49 ; NABCNYMA2175 ; 7F2CABaa9CDD9e4BBBacFF2A9Fec2beCf919b5ba4DEcC9DeD7af4979DDC1Aa9d ; < o465vaEGkP4jxV046jPR698E6QfUL6wNqSMTz559uP90091V25ZAUKqE44gNgqFH > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20189924727131 ; -1 ; -0,00025 ; 0,00025 ; -7,5 ; 4,6 ; -2,4 ; -9,6 ; 9,3 ; 4,5 ; -0,38 ; NABCNYJU2159 ; 8dAfc3bDc35e1fED2c8CCD4aafbFEcefdedBddFDbB29BBabbd0aB1B9EDa1BaAc ; < GU32kzM05GZL59VvRv825Z2dhzl0goXPMZ4N84vz7k36l1VKTLAO582o0Ok71v98 > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20770100332001 ; -1 ; -0,00025 ; 0,00025 ; 4 ; 3,5 ; 8 ; -0,6 ; 4,7 ; -1 ; -0,66 ; NABCNYSE2122 ; 3dfccB7abEba4dcBb8dEcCaaccfdB1e0CadA3Eef4D33cfc3Fd4cAEFB8dacEdD0 ; < 47kI1e3v4r773628TG4Y38VfKc20k9P3YL9DA7R9UrQ08P7hOWyeC481A3tD6k7Z > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21380381841504 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 0,1 ; -3,7 ; 8,1 ; 0,3 ; -3,2 ; 0,94 ; NABCNYDE2171 ; AD5e5a3f0A9fBcb9aFcAd2Ef765d3FFffb4AFedBaBbAD9BBA9Fb4AAEE0B95F12 ; < M3w1D4447l4x7Z0hi8rp816U6KMu8oMI99T8CxOnEvxy92CYW2LgNiDWS4NeLdN7 > >										24
											
//	  < CALLS ; 12M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 12M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABCNY										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; 161bF94D215ACAD73A0058eF56DEdc8a0EBE8aD3aC9b5D8C0EfCBceaf5eddde9 ; < p0lVtq04AW915sCuurd9IMo7ewAd02z5XuO8AZ899704v6BmU47xYIJZ31BIpeD1 > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14013006829845 ; -1 ; -0,00025 ; 0,00025 ; -4,7 ; -8 ; 1,6 ; -6,4 ; -2,2 ; 5 ; -0,33 ; NABCNY63JA19 ; D5CcdeC0dBafEb4EaA8bF25E5eBB81eCAAB6eDfeecffAA9B9DEa21ddaBeBdfd0 ; < sPy4Ie2907w1OC892rVqS2b46rCkA82BauCob0qY3551nHXgfysy7SiI6qr6HPG2 > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14050657721427 ; -1 ; -0,00025 ; 0,00025 ; -3,7 ; -9,8 ; 6 ; 9 ; 2,3 ; -6,5 ; -0,94 ; NABCNYMA1919 ; 3FE89Da5C79AcB527d3005b4EEBCEA7DE00E876D51dc6Ff4BDF2AEfD9FEFf9e5 ; < 5T6Dh67YAH7KW85Mz6xwR22dzec3AcZ4v665J8r90P2pzy5g8wdqnXL44f973f6u > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,1412403961573 ; -1 ; -0,00025 ; 0,00025 ; 6,1 ; -8,9 ; -1 ; 2,4 ; -0,8 ; -3,6 ; -0,81 ; NABCNYMA1913 ; aaaDcBCEf8d3BfCb78116D7D631aaE82DDABCCE4B9fC3d14deE0CBfafeB9d5d8 ; < lTs2X2R2l2Bnqy0mSR8Ozke60QMh85g58Syj5F8MNUT4AaHBhkoMNE1Zlozev5oI > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14215525993933 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -4,6 ; -3,9 ; 8,4 ; 3,9 ; 1,2 ; 0,65 ; NABCNYJU1976 ; ccCA7CEDb3E1E1E5AC4FF643b8DAf5912CaBBA70454aCEEF499Ec24DeDB6c236 ; < 432VWTUx6hi6NcQDdr9Tv41312wj0kOb192AKpje19XkypR9iH0o2oS1NzT48QCy > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14344236397449 ; -1 ; -0,00025 ; 0,00025 ; 8,6 ; -9,9 ; 6,3 ; 1,1 ; 9,3 ; -8,5 ; -0,99 ; NABCNYSE1988 ; BaBCECC0DFaEA9ACFbE8142cFb4e0e9ce7DB5Ce1c9cF02A83eC2a8AEFfDf7f0a ; < tXm4UQlCP275o5JDzbzw7YINcn916if9ds0K29fDVYbq4Uso0SX3OhV2luF0QH5Y > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14496911077331 ; -1 ; -0,00025 ; 0,00025 ; -6,9 ; 7,8 ; -3,2 ; -4,8 ; -3,5 ; -1,1 ; -0,37 ; NABCNYDE1951 ; ADD9EbCecA8438CcDe94BbAB1E7DAF3cFd4daab21fc9efD3abEbcA63C7BcbDb2 ; < U63652m61QS6k92NGJv4Q32MC3k2Z61t30l8RjBiX9N7Fd1jh1Rsrw6Egkbtrl42 > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14671813659638 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; -4,2 ; 2,5 ; -2,7 ; 6,4 ; 3,7 ; 0,87 ; NABCNYJA2019 ; 1C7fB2eEcAbB127Ef51258CeDedFB9Cbe6A4a27Ff2AB32c3FEa70DC0Ff1DfAED ; < 49e0T6etNJX15426TrFIG0CDHsu8Cy9PCDLx8gv197X0M9LdmJC1xSPE78B8ao2H > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,1486789936402 ; -1 ; -0,00025 ; 0,00025 ; 2,3 ; 3 ; 8,2 ; -3,4 ; 9,2 ; -9,5 ; 0,66 ; NABCNYMA2034 ; 6DceAaECEfca15DD8FfcEbCdAD98b6fBCB0fa4Fc4dBEe6B34eBAEF2dEf1eEfDe ; < 0DUz3452QlPjWBd1G19zRAtO92C917AFOABHb5422IlwCe98W13dc9xnIt60TWeb > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15075513290672 ; -1 ; -0,00025 ; 0,00025 ; -7 ; 6,2 ; 9,4 ; -6,4 ; -3,5 ; 0,4 ; -0,08 ; NABCNYMA2082 ; 7F0769eeCCaFae5EfA9c6a6Ef0cA5C8de1BeEE7AdCcFcebE1A247f6adad07CBa ; < PE4cFA9OIt8UU9pY0lN0Fr3RR6mJwzPG6mVe0ihL2008owKCoeWe7d22JLH1Jhj1 > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15323719633868 ; -1 ; -0,00025 ; 0,00025 ; -3,2 ; 0,4 ; -1,5 ; -1,1 ; 3,2 ; -5,3 ; 0,98 ; NABCNYJU2013 ; ACCDCc2deeCC4bC7DDCdB8FbbD961E44bF3bBcE5ddAC7eEeE19AAdCf0fA413EE ; < rD22agS9q4IU2FbPL6YDE6L70AoKTOybcW3bcTA4MM25Em34cfnv9RAR0BR422XB > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15592473278381 ; -1 ; -0,00025 ; 0,00025 ; 4,6 ; -9,9 ; 4,7 ; -9,7 ; -0,5 ; -9,5 ; 0,51 ; NABCNYSE2084 ; Aa37CbE4aCAc30B2614FeDcC3Fc75423eF99b8eDC0A53DcdcC6AddfABE8A8725 ; < 683lRCz8K4tn2P0G1adTNZ03e1T15V4W97UJtS87s2CY122M2e40K2w1pMUPnt6B > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15882725978783 ; -1 ; -0,00025 ; 0,00025 ; 8,3 ; 7,8 ; -2,4 ; 9,9 ; 8,8 ; 9,1 ; -0,16 ; NABCNYDE2024 ; CfCFd78c988Cb402f6aFc0BdfeAACDabFAc8CbcadAbac6aDdAB32cABFC12eBFE ; < 3wV37G6b0yfQXP7hoOEEE94u14i7Q1t4qnRMpXqar0ACTup0F9m91ll3vb0t6WZ2 > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,1619069767695 ; -1 ; -0,00025 ; 0,00025 ; -7,8 ; -7,6 ; -3,6 ; -4,9 ; 8,6 ; -1,4 ; 0,48 ; NABCNYJA2135 ; FEFfc7CC0fCeF52DeFadAABc6B0b9fc19dd17A0172cddA7B5fbaFb1Dc5E543eE ; < g6j72OP1NCJ7hSL1JWIhZKsGzgA3Z74E1q35aWic66K2GJQ7DvqPRLK2puS6K5N7 > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16530819671831 ; -1 ; -0,00025 ; 0,00025 ; 6,8 ; -5,1 ; -2,8 ; 5,1 ; -2,5 ; 9,5 ; -0,6 ; NABCNYMA2159 ; 9dA7b7Ed9B54c6ecD3d8eDDEaFE7B352FDcedEbBbeF7F3dcD5bCEDF9bf1fCfc3 ; < DA33Sf075W65tqpGv6o3aier6qe9Ff33Ai5phyJ514sXml6EAdz1Q526Xq7133Gd > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16903832023362 ; -1 ; -0,00025 ; 0,00025 ; 6,5 ; -4 ; -3,6 ; 8 ; 4,1 ; -3,8 ; -0,69 ; NABCNYMA2193 ; E5CA2EdCEbfCbDaC21ABBF6eB4bD5ADb8C4aFEF00bF7eCd0dC23Ffe9B3BaFDdf ; < o2wb9enLSJYxIiLu1N7Y8r75jFbd1ND028A0Q39lVZ387uVQVtFgaDfj6C4SM47p > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,17293790643596 ; -1 ; -0,00025 ; 0,00025 ; -1,4 ; -3,8 ; -5,3 ; -7,7 ; -3,7 ; -3,6 ; 0,73 ; NABCNYJU2119 ; 8DA5DAC9fFeB4A29dbABe0C5EfdcDAF9F0ecFaB55DA212DbFf9BadBAde6efbb7 ; < 1j3H5Mv1T9y9yZatR41AlPWzvg5M1rk2a4ZhsmZR5r297r7lze7IH0HEYPx7xp7A > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17715756273991 ; -1 ; -0,00025 ; 0,00025 ; -5,7 ; 6,2 ; -5,9 ; -6,2 ; -8,9 ; 5,1 ; -0,78 ; NABCNYSE2194 ; 8aCFBF63ecFEDF9FA8B4F8d2A223FEbD41bAbdF6d55b940c6e7aDEaFEa447edC ; < l0A5OtztzB3FXEAWg3US0M7LOVV2DwffPWOwGMuuGwJYWXQHgXdaz5zC4SGz00ah > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18146754007652 ; -1 ; -0,00025 ; 0,00025 ; -3,7 ; -9,9 ; -9,4 ; -2,7 ; 6,1 ; -3,8 ; 0,85 ; NABCNYDE2126 ; 96BF911B9FbbFE2BABCF3de329dfA1Ee6a7A9d9aE03bb158ddD77B6fE13d1eD1 ; < 7o1Z7fyB8zVpisPimcs6761x7nN3s6mMA9Hv8Kg8Um601hot1Wl0o3uk3PCsBztq > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18614168395367 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -8,9 ; -1,2 ; -2,2 ; -4,6 ; 6,4 ; -0,71 ; NABCNYJA2171 ; DFbedE0AE0013C7AaaC5A6eb59f9ceeEadEfeEb9dEf9c8Ca5fBc4da7AeA6C19D ; < uTy8gn6WgMdiVF13l3At3Puj8g2za7fha3462ypB6PkKYzFI254X1j7fuAgkyll6 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19119718340949 ; -1 ; -0,00025 ; 0,00025 ; 5,9 ; -8,2 ; 9,1 ; 3,4 ; 0,5 ; -2,1 ; -0,66 ; NABCNYMA2142 ; Ade71ADeE10C9caaC3eBB7fD450AdEaAbf0eCEEEC67e48bB7e9B40b8C5e55424 ; < 4lLyJsKpElf6AU13nG9i98zD0ZzkxhNXFT60Bi0nS53fE7Frt9TJw1UTmIGg5YTX > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19645643893813 ; -1 ; -0,00025 ; 0,00025 ; 0,2 ; 8,3 ; -8,8 ; 3,9 ; 2,8 ; -4,9 ; -0,49 ; NABCNYMA2175 ; 7F2CABaa9CDD9e4BBBacFF2A9Fec2beCf919b5ba4DEcC9DeD7af4979DDC1Aa9d ; < o465vaEGkP4jxV046jPR698E6QfUL6wNqSMTz559uP90091V25ZAUKqE44gNgqFH > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20189924727131 ; -1 ; -0,00025 ; 0,00025 ; -7,5 ; 4,6 ; -2,4 ; -9,6 ; 9,3 ; 4,5 ; -0,38 ; NABCNYJU2159 ; 8dAfc3bDc35e1fED2c8CCD4aafbFEcefdedBddFDbB29BBabbd0aB1B9EDa1BaAc ; < GU32kzM05GZL59VvRv825Z2dhzl0goXPMZ4N84vz7k36l1VKTLAO582o0Ok71v98 > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20770100332001 ; -1 ; -0,00025 ; 0,00025 ; 4 ; 3,5 ; 8 ; -0,6 ; 4,7 ; -1 ; -0,66 ; NABCNYSE2122 ; 3dfccB7abEba4dcBb8dEcCaaccfdB1e0CadA3Eef4D33cfc3Fd4cAEFB8dacEdD0 ; < 47kI1e3v4r773628TG4Y38VfKc20k9P3YL9DA7R9UrQ08P7hOWyeC481A3tD6k7Z > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21380381841504 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 0,1 ; -3,7 ; 8,1 ; 0,3 ; -3,2 ; 0,94 ; NABCNYDE2171 ; AD5e5a3f0A9fBcb9aFcAd2Ef765d3FFffb4AFedBaBbAD9BBA9Fb4AAEE0B95F12 ; < M3w1D4447l4x7Z0hi8rp816U6KMu8oMI99T8CxOnEvxy92CYW2LgNiDWS4NeLdN7 > >										24
											
//	  < CALLS ; 24M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 24M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABCNY										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; 161bF94D215ACAD73A0058eF56DEdc8a0EBE8aD3aC9b5D8C0EfCBceaf5eddde9 ; < p0lVtq04AW915sCuurd9IMo7ewAd02z5XuO8AZ899704v6BmU47xYIJZ31BIpeD1 > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14013006829845 ; -1 ; -0,00025 ; 0,00025 ; -4,7 ; -8 ; 1,6 ; -6,4 ; -2,2 ; 5 ; -0,33 ; NABCNY63JA19 ; D5CcdeC0dBafEb4EaA8bF25E5eBB81eCAAB6eDfeecffAA9B9DEa21ddaBeBdfd0 ; < sPy4Ie2907w1OC892rVqS2b46rCkA82BauCob0qY3551nHXgfysy7SiI6qr6HPG2 > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14050657721427 ; -1 ; -0,00025 ; 0,00025 ; -3,7 ; -9,8 ; 6 ; 9 ; 2,3 ; -6,5 ; -0,94 ; NABCNYMA1919 ; 3FE89Da5C79AcB527d3005b4EEBCEA7DE00E876D51dc6Ff4BDF2AEfD9FEFf9e5 ; < 5T6Dh67YAH7KW85Mz6xwR22dzec3AcZ4v665J8r90P2pzy5g8wdqnXL44f973f6u > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,1412403961573 ; -1 ; -0,00025 ; 0,00025 ; 6,1 ; -8,9 ; -1 ; 2,4 ; -0,8 ; -3,6 ; -0,81 ; NABCNYMA1913 ; aaaDcBCEf8d3BfCb78116D7D631aaE82DDABCCE4B9fC3d14deE0CBfafeB9d5d8 ; < lTs2X2R2l2Bnqy0mSR8Ozke60QMh85g58Syj5F8MNUT4AaHBhkoMNE1Zlozev5oI > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14215525993933 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -4,6 ; -3,9 ; 8,4 ; 3,9 ; 1,2 ; 0,65 ; NABCNYJU1976 ; ccCA7CEDb3E1E1E5AC4FF643b8DAf5912CaBBA70454aCEEF499Ec24DeDB6c236 ; < 432VWTUx6hi6NcQDdr9Tv41312wj0kOb192AKpje19XkypR9iH0o2oS1NzT48QCy > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14344236397449 ; -1 ; -0,00025 ; 0,00025 ; 8,6 ; -9,9 ; 6,3 ; 1,1 ; 9,3 ; -8,5 ; -0,99 ; NABCNYSE1988 ; BaBCECC0DFaEA9ACFbE8142cFb4e0e9ce7DB5Ce1c9cF02A83eC2a8AEFfDf7f0a ; < tXm4UQlCP275o5JDzbzw7YINcn916if9ds0K29fDVYbq4Uso0SX3OhV2luF0QH5Y > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14496911077331 ; -1 ; -0,00025 ; 0,00025 ; -6,9 ; 7,8 ; -3,2 ; -4,8 ; -3,5 ; -1,1 ; -0,37 ; NABCNYDE1951 ; ADD9EbCecA8438CcDe94BbAB1E7DAF3cFd4daab21fc9efD3abEbcA63C7BcbDb2 ; < U63652m61QS6k92NGJv4Q32MC3k2Z61t30l8RjBiX9N7Fd1jh1Rsrw6Egkbtrl42 > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,14671813659638 ; -1 ; -0,00025 ; 0,00025 ; 5,7 ; -4,2 ; 2,5 ; -2,7 ; 6,4 ; 3,7 ; 0,87 ; NABCNYJA2019 ; 1C7fB2eEcAbB127Ef51258CeDedFB9Cbe6A4a27Ff2AB32c3FEa70DC0Ff1DfAED ; < 49e0T6etNJX15426TrFIG0CDHsu8Cy9PCDLx8gv197X0M9LdmJC1xSPE78B8ao2H > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,1486789936402 ; -1 ; -0,00025 ; 0,00025 ; 2,3 ; 3 ; 8,2 ; -3,4 ; 9,2 ; -9,5 ; 0,66 ; NABCNYMA2034 ; 6DceAaECEfca15DD8FfcEbCdAD98b6fBCB0fa4Fc4dBEe6B34eBAEF2dEf1eEfDe ; < 0DUz3452QlPjWBd1G19zRAtO92C917AFOABHb5422IlwCe98W13dc9xnIt60TWeb > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,15075513290672 ; -1 ; -0,00025 ; 0,00025 ; -7 ; 6,2 ; 9,4 ; -6,4 ; -3,5 ; 0,4 ; -0,08 ; NABCNYMA2082 ; 7F0769eeCCaFae5EfA9c6a6Ef0cA5C8de1BeEE7AdCcFcebE1A247f6adad07CBa ; < PE4cFA9OIt8UU9pY0lN0Fr3RR6mJwzPG6mVe0ihL2008owKCoeWe7d22JLH1Jhj1 > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15323719633868 ; -1 ; -0,00025 ; 0,00025 ; -3,2 ; 0,4 ; -1,5 ; -1,1 ; 3,2 ; -5,3 ; 0,98 ; NABCNYJU2013 ; ACCDCc2deeCC4bC7DDCdB8FbbD961E44bF3bBcE5ddAC7eEeE19AAdCf0fA413EE ; < rD22agS9q4IU2FbPL6YDE6L70AoKTOybcW3bcTA4MM25Em34cfnv9RAR0BR422XB > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15592473278381 ; -1 ; -0,00025 ; 0,00025 ; 4,6 ; -9,9 ; 4,7 ; -9,7 ; -0,5 ; -9,5 ; 0,51 ; NABCNYSE2084 ; Aa37CbE4aCAc30B2614FeDcC3Fc75423eF99b8eDC0A53DcdcC6AddfABE8A8725 ; < 683lRCz8K4tn2P0G1adTNZ03e1T15V4W97UJtS87s2CY122M2e40K2w1pMUPnt6B > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15882725978783 ; -1 ; -0,00025 ; 0,00025 ; 8,3 ; 7,8 ; -2,4 ; 9,9 ; 8,8 ; 9,1 ; -0,16 ; NABCNYDE2024 ; CfCFd78c988Cb402f6aFc0BdfeAACDabFAc8CbcadAbac6aDdAB32cABFC12eBFE ; < 3wV37G6b0yfQXP7hoOEEE94u14i7Q1t4qnRMpXqar0ACTup0F9m91ll3vb0t6WZ2 > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,1619069767695 ; -1 ; -0,00025 ; 0,00025 ; -7,8 ; -7,6 ; -3,6 ; -4,9 ; 8,6 ; -1,4 ; 0,48 ; NABCNYJA2135 ; FEFfc7CC0fCeF52DeFadAABc6B0b9fc19dd17A0172cddA7B5fbaFb1Dc5E543eE ; < g6j72OP1NCJ7hSL1JWIhZKsGzgA3Z74E1q35aWic66K2GJQ7DvqPRLK2puS6K5N7 > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16530819671831 ; -1 ; -0,00025 ; 0,00025 ; 6,8 ; -5,1 ; -2,8 ; 5,1 ; -2,5 ; 9,5 ; -0,6 ; NABCNYMA2159 ; 9dA7b7Ed9B54c6ecD3d8eDDEaFE7B352FDcedEbBbeF7F3dcD5bCEDF9bf1fCfc3 ; < DA33Sf075W65tqpGv6o3aier6qe9Ff33Ai5phyJ514sXml6EAdz1Q526Xq7133Gd > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16903832023362 ; -1 ; -0,00025 ; 0,00025 ; 6,5 ; -4 ; -3,6 ; 8 ; 4,1 ; -3,8 ; -0,69 ; NABCNYMA2193 ; E5CA2EdCEbfCbDaC21ABBF6eB4bD5ADb8C4aFEF00bF7eCd0dC23Ffe9B3BaFDdf ; < o2wb9enLSJYxIiLu1N7Y8r75jFbd1ND028A0Q39lVZ387uVQVtFgaDfj6C4SM47p > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,17293790643596 ; -1 ; -0,00025 ; 0,00025 ; -1,4 ; -3,8 ; -5,3 ; -7,7 ; -3,7 ; -3,6 ; 0,73 ; NABCNYJU2119 ; 8DA5DAC9fFeB4A29dbABe0C5EfdcDAF9F0ecFaB55DA212DbFf9BadBAde6efbb7 ; < 1j3H5Mv1T9y9yZatR41AlPWzvg5M1rk2a4ZhsmZR5r297r7lze7IH0HEYPx7xp7A > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17715756273991 ; -1 ; -0,00025 ; 0,00025 ; -5,7 ; 6,2 ; -5,9 ; -6,2 ; -8,9 ; 5,1 ; -0,78 ; NABCNYSE2194 ; 8aCFBF63ecFEDF9FA8B4F8d2A223FEbD41bAbdF6d55b940c6e7aDEaFEa447edC ; < l0A5OtztzB3FXEAWg3US0M7LOVV2DwffPWOwGMuuGwJYWXQHgXdaz5zC4SGz00ah > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,18146754007652 ; -1 ; -0,00025 ; 0,00025 ; -3,7 ; -9,9 ; -9,4 ; -2,7 ; 6,1 ; -3,8 ; 0,85 ; NABCNYDE2126 ; 96BF911B9FbbFE2BABCF3de329dfA1Ee6a7A9d9aE03bb158ddD77B6fE13d1eD1 ; < 7o1Z7fyB8zVpisPimcs6761x7nN3s6mMA9Hv8Kg8Um601hot1Wl0o3uk3PCsBztq > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18614168395367 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -8,9 ; -1,2 ; -2,2 ; -4,6 ; 6,4 ; -0,71 ; NABCNYJA2171 ; DFbedE0AE0013C7AaaC5A6eb59f9ceeEadEfeEb9dEf9c8Ca5fBc4da7AeA6C19D ; < uTy8gn6WgMdiVF13l3At3Puj8g2za7fha3462ypB6PkKYzFI254X1j7fuAgkyll6 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19119718340949 ; -1 ; -0,00025 ; 0,00025 ; 5,9 ; -8,2 ; 9,1 ; 3,4 ; 0,5 ; -2,1 ; -0,66 ; NABCNYMA2142 ; Ade71ADeE10C9caaC3eBB7fD450AdEaAbf0eCEEEC67e48bB7e9B40b8C5e55424 ; < 4lLyJsKpElf6AU13nG9i98zD0ZzkxhNXFT60Bi0nS53fE7Frt9TJw1UTmIGg5YTX > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19645643893813 ; -1 ; -0,00025 ; 0,00025 ; 0,2 ; 8,3 ; -8,8 ; 3,9 ; 2,8 ; -4,9 ; -0,49 ; NABCNYMA2175 ; 7F2CABaa9CDD9e4BBBacFF2A9Fec2beCf919b5ba4DEcC9DeD7af4979DDC1Aa9d ; < o465vaEGkP4jxV046jPR698E6QfUL6wNqSMTz559uP90091V25ZAUKqE44gNgqFH > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20189924727131 ; -1 ; -0,00025 ; 0,00025 ; -7,5 ; 4,6 ; -2,4 ; -9,6 ; 9,3 ; 4,5 ; -0,38 ; NABCNYJU2159 ; 8dAfc3bDc35e1fED2c8CCD4aafbFEcefdedBddFDbB29BBabbd0aB1B9EDa1BaAc ; < GU32kzM05GZL59VvRv825Z2dhzl0goXPMZ4N84vz7k36l1VKTLAO582o0Ok71v98 > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20770100332001 ; -1 ; -0,00025 ; 0,00025 ; 4 ; 3,5 ; 8 ; -0,6 ; 4,7 ; -1 ; -0,66 ; NABCNYSE2122 ; 3dfccB7abEba4dcBb8dEcCaaccfdB1e0CadA3Eef4D33cfc3Fd4cAEFB8dacEdD0 ; < 47kI1e3v4r773628TG4Y38VfKc20k9P3YL9DA7R9UrQ08P7hOWyeC481A3tD6k7Z > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21380381841504 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 0,1 ; -3,7 ; 8,1 ; 0,3 ; -3,2 ; 0,94 ; NABCNYDE2171 ; AD5e5a3f0A9fBcb9aFcAd2Ef765d3FFffb4AFedBaBbAD9BBA9Fb4AAEE0B95F12 ; < M3w1D4447l4x7Z0hi8rp816U6KMu8oMI99T8CxOnEvxy92CYW2LgNiDWS4NeLdN7 > >										24
											
//	  < CALLS ; 36M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 36M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABETH										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; c46dFe0BcdDbC242FCcffEfe7adEDb875fceE771dcdC74Ff9Eb380bdD9efDe7A ; < QmUiLtY4zThGlnc1nJ2DGdYQw7r8240UhM78Efgvv0U79C13zp4hW216opNi3hb1 > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14024520829845 ; -1 ; -0,00025 ; 0,00025 ; -0,1 ; -6,3 ; -6,3 ; 0,2 ; 8,4 ; 3,8 ; -0,62 ; NABETH45JA19 ; 79C41e7D8c24974e6dD7c8d87CBbd0Bc0AdE5abFB7EbBbfFFdDFDccB22bFba13 ; < yrv7q09CRZpc9y55DI8Ec2DNN33p0bB5IPDOQxkmxPAU83K5B9rI9hKpu6SO8A7j > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14066622480045 ; -1 ; -0,00025 ; 0,00025 ; -0,1 ; 1 ; -1,1 ; 4 ; -1,4 ; -6,5 ; 0,76 ; NABETHMA1928 ; DcAcBD1EBEF83ae2BDacdAeA21EAB85b044dDCafF1AccEAe1bcFABbB99CbD0cB ; < 3sfvlNKPMyXDXE3IN1OvD4Kb4glfnAw7lE9y1aqM55I5BD61rI5oQgTxabC5CvT0 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14145489844192 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; -7,8 ; -4,6 ; -7,6 ; 8,9 ; -9,8 ; 0,63 ; NABETHMA1962 ; E8c9cCccaBacFdccbc5cE54BFcA5BbBBCDBB7Fab6e20Fac16dE6e0Faca82d0e7 ; < 5sGtT7W5TwXnA4mAC9vvbs9Rg0Lez4S7A4X7DUl6hPO59MEbvD5KB0H3tC6Z8xZ7 > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14236650981283 ; -1 ; -0,00025 ; 0,00025 ; 0 ; -4,4 ; -8,4 ; -1,7 ; 8 ; 0,1 ; -0,59 ; NABETHJU1995 ; Ea359E7B2baaD89e40524bD3FcA3E51524adCb9A6DBFBd50bDdac2c7Bc3977A7 ; < iJAEK75E0Ubv76Bx008GgS8gs59uxF6lb70YM5enfP1HE60O1wuin1NySixqS0D6 > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14364357060859 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -7,6 ; 2,7 ; -9,1 ; 8,5 ; 3,6 ; -0,41 ; NABETHSE1971 ; 4df5dEFbf3B55A34fcc9cEa4eBCE2eCcA4BdAf38cd90EeF03d26e1FAfeeEDEa9 ; < 52rKCozn97zA5MoQ7824Z2p1nLq4oX1rYupZ457g5yapQdjVw67lG33dp0bXY592 > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14505850899257 ; -1 ; -0,00025 ; 0,00025 ; 4,5 ; 1,6 ; 1,9 ; -5,2 ; -8,3 ; -8,8 ; -0,39 ; NABETHDE1947 ; 6CECc2cD0Fa0CE9f9CF51AcDF9a8B4fAA0c3ED7EbA38B8c7b7fb23acD3cdE264 ; < Iddzjt1owEOidFRx17GlTeT2KuBF3E78lQO02q5NYB5011K14baC58w6L4K63Giv > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,1468088164366 ; -1 ; -0,00025 ; 0,00025 ; -0,5 ; -0,7 ; -1 ; -1,3 ; 0 ; -2,2 ; 0,75 ; NABETHJA2038 ; 2755a3b07Dbb6fe8BfDdCB5ceFC5acdADE0f114F37fEDC2F1b40C7eb1ddE38cc ; < c2nz3p653X412mg96Wk5zf8c1b40rruC2W8i35U3yz0r8jdHliVP4L1hwfcHlF2x > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14870675405559 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 3 ; 3,4 ; 1,3 ; 1,9 ; -4,9 ; -0,68 ; NABETHMA2031 ; 4d46f4adD81d1642EdcCa35CB87D1B9CC8c0B3B8Bd1AbB4efd5959e0bF83DF7d ; < c5Ph61U21D0Unfx8Mgf48C09GrD5J6ucSKPII2eGjzBY8CXq0J2cvTW85T1n2P16 > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,1508851783978 ; -1 ; -0,00025 ; 0,00025 ; -7,8 ; 2,3 ; -5 ; 8,1 ; 2,1 ; -5,6 ; -0,28 ; NABETHMA2082 ; cFcAbc9cd979fBEabCEE27bA1fb8e894eDbDdDFdcEdd05Eb3ABE7bb7e1ca0DfA ; < rqAyF2sWK93VZ2dKiS3xUVZe1wtvVm36YNBc7kqjdeyCNL62UrOEuziJhI1T0k0e > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15322826521826 ; -1 ; -0,00025 ; 0,00025 ; -9,6 ; -1,5 ; -4,5 ; -4,8 ; 4,5 ; 9,8 ; -0,71 ; NABETHJU2056 ; 67Bd2dBed3494Ffcfad21A61bebBDADfDC7Fe6Fd939Dfcca06FAafEC83AFd394 ; < 2mw08Ah2d6acW03CMM80fxats5NCBScv9o7ZzL71Fsm2a2clHA4YWzgMp1vRA9rj > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15581199030619 ; -1 ; -0,00025 ; 0,00025 ; 9,2 ; 4,6 ; 8,5 ; -5,7 ; -8 ; -1 ; -0,55 ; NABETHSE2052 ; f2b175edCBfb0eeAeEc83c6edF24bEdfe749A3de6C97bbcee4daAAcCbae6679F ; < WdeMg185lKS5ShGb383R1kZy22IWxkpa92dOc4dhLd6y8V8xfV3xR8F2Hvprvnzm > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15859402976686 ; -1 ; -0,00025 ; 0,00025 ; -4,2 ; -5,9 ; 3,6 ; -0,4 ; 7 ; -8,9 ; -0,6 ; NABETHDE2069 ; 66745Bb6e3b4ffC19Ae6CfC2ed0bBbCABfeDa5A3beBaE5BA2C4AE1882D3ceD8F ; < 7Reve50cr2qveV4NoiOJ77qH0qUM7I93LOLahuda2bMojR1EkGJH5747P0S2CsSo > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,1616314175278 ; -1 ; -0,00025 ; 0,00025 ; 3,4 ; -4,4 ; 9,1 ; -6,1 ; 5,6 ; -3,9 ; -0,76 ; NABETHJA2183 ; fAddebC2a1Ced0C3F8Da9a4Fa004B4Bb557DACCD172DBDAe1a80cF32A91fBcd7 ; < 702OiSygi1357Goesgb7u8MxM3Xu5OHn4F8OU59x9zUJ233JQT210f5NVYg71m2j > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16498188068828 ; -1 ; -0,00025 ; 0,00025 ; 6,2 ; 0 ; 7,8 ; -7,5 ; 7,5 ; 9,8 ; 0,13 ; NABETHMA2171 ; 7a4aAFAeBBD1878cdca13bE0cBbB9A0aa60AdCe69E46BeC9e8EB5E1B419C7fdC ; < 2q058Ox13HY87m44hvX70wC56Tc81290W3ZGft5H6Cvk2eT811pq9F6bc1650sGX > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16865387556168 ; -1 ; -0,00025 ; 0,00025 ; -9 ; -7,2 ; -0,6 ; 6,4 ; -9,3 ; -9,3 ; -0,11 ; NABETHMA2177 ; bcB3CAB5daDC0D2625F15Ffd8cabcB8a2e30f0fEAB90C9c9FcCa2EaEac071a5F ; < Ypfv6XBO8xMP4KObkC0N9z35gtx6JqwX6ourv34488Kl692G7b0l8Y3VSzV3JNC5 > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,17258840763381 ; -1 ; -0,00025 ; 0,00025 ; 1,5 ; -4,9 ; 1,8 ; 1,8 ; -1,9 ; -5,5 ; 0,13 ; NABETHJU2164 ; 952ad6AAbf1edF6fA928Ddbd0cDBCf195Fb9cEBe2A54aBa43Ce2CFE7cB5bBa9e ; < dU18045tiz1MsG8aKC2465E42K0712o74LQMsJb4PmRvMQ60SzPx95D8Tkqxw03v > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17664967976558 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -8,1 ; 3 ; 5,3 ; -7 ; 8 ; 0,08 ; NABETHSE2199 ; d9Eb9fc1db15db9Adc136AEadBc3b7E9baDDE0EafbB39e8e8597ebb0EC534a2a ; < VKK07sCndFz66ql3b4237i24RG0V83DWsv1o568dQB49s5lLfH8wz1lLUxI1u68w > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,1810354564474 ; -1 ; -0,00025 ; 0,00025 ; 2,2 ; 5,3 ; 2,3 ; -8,3 ; -2,5 ; 9 ; 0,49 ; NABETHDE2192 ; 2B2eD30DFDBb88C3fA315dF0E7b4A1331Fa2AD71B0db03305fC32AF3532DbC72 ; < JMaHybwD6VNFJthj2EZ7ju8dvpXBPAtFB16Xwnn1xb8U6VrEV40zC629pTktMGaU > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18570670987179 ; -1 ; -0,00025 ; 0,00025 ; 0,3 ; 1,3 ; -4,5 ; -6,8 ; 6,1 ; 9,1 ; 0,38 ; NABETHJA2155 ; bEeD0BC2a2cEc41bcbecA3BbaED46AF0bD59f4Ae4DcAC29C09DD5aaF06F8ab41 ; < Kn2yg13dkc8499i3Rw7ATZcv8mT8pqm0ZhtK84U05712huT8giNjc0I55nle9yT3 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19065601321761 ; -1 ; -0,00025 ; 0,00025 ; 3,8 ; 6,1 ; 7,7 ; 2,6 ; -9,4 ; 2,4 ; -0,31 ; NABETHMA2181 ; bbDe6bbbcFe2BdbEa3B8aFCfFE5fCfcDaCdDCCe1f9666bBfBadbd1A9DcdCfC35 ; < 6hVaA5f2Pr1ae1JFXLg5452c7smAXJEkz1CuBFQD7TIv30v3R2Tjj8wCp5H0q9M4 > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19580452972815 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; -7 ; 8,8 ; 6,3 ; -2 ; 9,1 ; -0,8 ; NABETHMA2194 ; EAA8F32c1DCE3Acd3FBA0e8D30DE032fB5a06cD5dAEe0fc9D5E99be8deA0be6A ; < 7IyUUYo2M7k4gw95N3aZu1O596JbXC0I8w89NTbM9nHSJ2YBKMn1ps01UK73SudD > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20122523958412 ; -1 ; -0,00025 ; 0,00025 ; 3 ; 3,6 ; -7,7 ; -2,5 ; 5,2 ; -5,8 ; -0,73 ; NABETHJU2120 ; AA015D8cc3ce74A16DB3FA9FEABb13733cDDFB6ebd1BeAAED3Fdb5cACFEfaa8c ; < UQ10B3C66OQXeZ8jJ4d6J7cnxy4DRJSNL9u6QOjvUFONOiecs483m4AU9qG2t5Pw > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20697088818153 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -8,5 ; -4,9 ; -3,1 ; -4,2 ; 3,7 ; 0,92 ; NABETHSE2119 ; 83B4D10b2C6d67A92fcFea4ABDdDBA5D3b5eDec77ebC409cdCaca6Ac28f4e04e ; < 3DXYCv5STs94OA97Z7RpsT2wYr1vtkm60uF5nYLJxtGbyqOWb09kK476USXg8TiX > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21309173929822 ; -1 ; -0,00025 ; 0,00025 ; 0,6 ; -7,5 ; 1,4 ; -8,1 ; -9,6 ; -2,5 ; 0,68 ; NABETHDE2151 ; d3eCfccC5feFebaAcbf36c3BDc51ce8eEe6edcB9c6d9DdDA0F1f9dBb6FACBcd1 ; < td1DP04x0GskJ30Ur579Mw7k31pn4Og1um5611ANuQqiajeu98J5ZT351o0THHgc > >										24
											
//	  < CALLS ; 3M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 3M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABETH										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; c46dFe0BcdDbC242FCcffEfe7adEDb875fceE771dcdC74Ff9Eb380bdD9efDe7A ; < QmUiLtY4zThGlnc1nJ2DGdYQw7r8240UhM78Efgvv0U79C13zp4hW216opNi3hb1 > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14024520829845 ; -1 ; -0,00025 ; 0,00025 ; -0,1 ; -6,3 ; -6,3 ; 0,2 ; 8,4 ; 3,8 ; -0,62 ; NABETH45JA19 ; 79C41e7D8c24974e6dD7c8d87CBbd0Bc0AdE5abFB7EbBbfFFdDFDccB22bFba13 ; < yrv7q09CRZpc9y55DI8Ec2DNN33p0bB5IPDOQxkmxPAU83K5B9rI9hKpu6SO8A7j > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14066622480045 ; -1 ; -0,00025 ; 0,00025 ; -0,1 ; 1 ; -1,1 ; 4 ; -1,4 ; -6,5 ; 0,76 ; NABETHMA1928 ; DcAcBD1EBEF83ae2BDacdAeA21EAB85b044dDCafF1AccEAe1bcFABbB99CbD0cB ; < 3sfvlNKPMyXDXE3IN1OvD4Kb4glfnAw7lE9y1aqM55I5BD61rI5oQgTxabC5CvT0 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14145489844192 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; -7,8 ; -4,6 ; -7,6 ; 8,9 ; -9,8 ; 0,63 ; NABETHMA1962 ; E8c9cCccaBacFdccbc5cE54BFcA5BbBBCDBB7Fab6e20Fac16dE6e0Faca82d0e7 ; < 5sGtT7W5TwXnA4mAC9vvbs9Rg0Lez4S7A4X7DUl6hPO59MEbvD5KB0H3tC6Z8xZ7 > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14236650981283 ; -1 ; -0,00025 ; 0,00025 ; 0 ; -4,4 ; -8,4 ; -1,7 ; 8 ; 0,1 ; -0,59 ; NABETHJU1995 ; Ea359E7B2baaD89e40524bD3FcA3E51524adCb9A6DBFBd50bDdac2c7Bc3977A7 ; < iJAEK75E0Ubv76Bx008GgS8gs59uxF6lb70YM5enfP1HE60O1wuin1NySixqS0D6 > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14364357060859 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -7,6 ; 2,7 ; -9,1 ; 8,5 ; 3,6 ; -0,41 ; NABETHSE1971 ; 4df5dEFbf3B55A34fcc9cEa4eBCE2eCcA4BdAf38cd90EeF03d26e1FAfeeEDEa9 ; < 52rKCozn97zA5MoQ7824Z2p1nLq4oX1rYupZ457g5yapQdjVw67lG33dp0bXY592 > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14505850899257 ; -1 ; -0,00025 ; 0,00025 ; 4,5 ; 1,6 ; 1,9 ; -5,2 ; -8,3 ; -8,8 ; -0,39 ; NABETHDE1947 ; 6CECc2cD0Fa0CE9f9CF51AcDF9a8B4fAA0c3ED7EbA38B8c7b7fb23acD3cdE264 ; < Iddzjt1owEOidFRx17GlTeT2KuBF3E78lQO02q5NYB5011K14baC58w6L4K63Giv > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,1468088164366 ; -1 ; -0,00025 ; 0,00025 ; -0,5 ; -0,7 ; -1 ; -1,3 ; 0 ; -2,2 ; 0,75 ; NABETHJA2038 ; 2755a3b07Dbb6fe8BfDdCB5ceFC5acdADE0f114F37fEDC2F1b40C7eb1ddE38cc ; < c2nz3p653X412mg96Wk5zf8c1b40rruC2W8i35U3yz0r8jdHliVP4L1hwfcHlF2x > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14870675405559 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 3 ; 3,4 ; 1,3 ; 1,9 ; -4,9 ; -0,68 ; NABETHMA2031 ; 4d46f4adD81d1642EdcCa35CB87D1B9CC8c0B3B8Bd1AbB4efd5959e0bF83DF7d ; < c5Ph61U21D0Unfx8Mgf48C09GrD5J6ucSKPII2eGjzBY8CXq0J2cvTW85T1n2P16 > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,1508851783978 ; -1 ; -0,00025 ; 0,00025 ; -7,8 ; 2,3 ; -5 ; 8,1 ; 2,1 ; -5,6 ; -0,28 ; NABETHMA2082 ; cFcAbc9cd979fBEabCEE27bA1fb8e894eDbDdDFdcEdd05Eb3ABE7bb7e1ca0DfA ; < rqAyF2sWK93VZ2dKiS3xUVZe1wtvVm36YNBc7kqjdeyCNL62UrOEuziJhI1T0k0e > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15322826521826 ; -1 ; -0,00025 ; 0,00025 ; -9,6 ; -1,5 ; -4,5 ; -4,8 ; 4,5 ; 9,8 ; -0,71 ; NABETHJU2056 ; 67Bd2dBed3494Ffcfad21A61bebBDADfDC7Fe6Fd939Dfcca06FAafEC83AFd394 ; < 2mw08Ah2d6acW03CMM80fxats5NCBScv9o7ZzL71Fsm2a2clHA4YWzgMp1vRA9rj > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15581199030619 ; -1 ; -0,00025 ; 0,00025 ; 9,2 ; 4,6 ; 8,5 ; -5,7 ; -8 ; -1 ; -0,55 ; NABETHSE2052 ; f2b175edCBfb0eeAeEc83c6edF24bEdfe749A3de6C97bbcee4daAAcCbae6679F ; < WdeMg185lKS5ShGb383R1kZy22IWxkpa92dOc4dhLd6y8V8xfV3xR8F2Hvprvnzm > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15859402976686 ; -1 ; -0,00025 ; 0,00025 ; -4,2 ; -5,9 ; 3,6 ; -0,4 ; 7 ; -8,9 ; -0,6 ; NABETHDE2069 ; 66745Bb6e3b4ffC19Ae6CfC2ed0bBbCABfeDa5A3beBaE5BA2C4AE1882D3ceD8F ; < 7Reve50cr2qveV4NoiOJ77qH0qUM7I93LOLahuda2bMojR1EkGJH5747P0S2CsSo > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,1616314175278 ; -1 ; -0,00025 ; 0,00025 ; 3,4 ; -4,4 ; 9,1 ; -6,1 ; 5,6 ; -3,9 ; -0,76 ; NABETHJA2183 ; fAddebC2a1Ced0C3F8Da9a4Fa004B4Bb557DACCD172DBDAe1a80cF32A91fBcd7 ; < 702OiSygi1357Goesgb7u8MxM3Xu5OHn4F8OU59x9zUJ233JQT210f5NVYg71m2j > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16498188068828 ; -1 ; -0,00025 ; 0,00025 ; 6,2 ; 0 ; 7,8 ; -7,5 ; 7,5 ; 9,8 ; 0,13 ; NABETHMA2171 ; 7a4aAFAeBBD1878cdca13bE0cBbB9A0aa60AdCe69E46BeC9e8EB5E1B419C7fdC ; < 2q058Ox13HY87m44hvX70wC56Tc81290W3ZGft5H6Cvk2eT811pq9F6bc1650sGX > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16865387556168 ; -1 ; -0,00025 ; 0,00025 ; -9 ; -7,2 ; -0,6 ; 6,4 ; -9,3 ; -9,3 ; -0,11 ; NABETHMA2177 ; bcB3CAB5daDC0D2625F15Ffd8cabcB8a2e30f0fEAB90C9c9FcCa2EaEac071a5F ; < Ypfv6XBO8xMP4KObkC0N9z35gtx6JqwX6ourv34488Kl692G7b0l8Y3VSzV3JNC5 > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,17258840763381 ; -1 ; -0,00025 ; 0,00025 ; 1,5 ; -4,9 ; 1,8 ; 1,8 ; -1,9 ; -5,5 ; 0,13 ; NABETHJU2164 ; 952ad6AAbf1edF6fA928Ddbd0cDBCf195Fb9cEBe2A54aBa43Ce2CFE7cB5bBa9e ; < dU18045tiz1MsG8aKC2465E42K0712o74LQMsJb4PmRvMQ60SzPx95D8Tkqxw03v > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17664967976558 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -8,1 ; 3 ; 5,3 ; -7 ; 8 ; 0,08 ; NABETHSE2199 ; d9Eb9fc1db15db9Adc136AEadBc3b7E9baDDE0EafbB39e8e8597ebb0EC534a2a ; < VKK07sCndFz66ql3b4237i24RG0V83DWsv1o568dQB49s5lLfH8wz1lLUxI1u68w > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,1810354564474 ; -1 ; -0,00025 ; 0,00025 ; 2,2 ; 5,3 ; 2,3 ; -8,3 ; -2,5 ; 9 ; 0,49 ; NABETHDE2192 ; 2B2eD30DFDBb88C3fA315dF0E7b4A1331Fa2AD71B0db03305fC32AF3532DbC72 ; < JMaHybwD6VNFJthj2EZ7ju8dvpXBPAtFB16Xwnn1xb8U6VrEV40zC629pTktMGaU > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18570670987179 ; -1 ; -0,00025 ; 0,00025 ; 0,3 ; 1,3 ; -4,5 ; -6,8 ; 6,1 ; 9,1 ; 0,38 ; NABETHJA2155 ; bEeD0BC2a2cEc41bcbecA3BbaED46AF0bD59f4Ae4DcAC29C09DD5aaF06F8ab41 ; < Kn2yg13dkc8499i3Rw7ATZcv8mT8pqm0ZhtK84U05712huT8giNjc0I55nle9yT3 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19065601321761 ; -1 ; -0,00025 ; 0,00025 ; 3,8 ; 6,1 ; 7,7 ; 2,6 ; -9,4 ; 2,4 ; -0,31 ; NABETHMA2181 ; bbDe6bbbcFe2BdbEa3B8aFCfFE5fCfcDaCdDCCe1f9666bBfBadbd1A9DcdCfC35 ; < 6hVaA5f2Pr1ae1JFXLg5452c7smAXJEkz1CuBFQD7TIv30v3R2Tjj8wCp5H0q9M4 > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19580452972815 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; -7 ; 8,8 ; 6,3 ; -2 ; 9,1 ; -0,8 ; NABETHMA2194 ; EAA8F32c1DCE3Acd3FBA0e8D30DE032fB5a06cD5dAEe0fc9D5E99be8deA0be6A ; < 7IyUUYo2M7k4gw95N3aZu1O596JbXC0I8w89NTbM9nHSJ2YBKMn1ps01UK73SudD > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20122523958412 ; -1 ; -0,00025 ; 0,00025 ; 3 ; 3,6 ; -7,7 ; -2,5 ; 5,2 ; -5,8 ; -0,73 ; NABETHJU2120 ; AA015D8cc3ce74A16DB3FA9FEABb13733cDDFB6ebd1BeAAED3Fdb5cACFEfaa8c ; < UQ10B3C66OQXeZ8jJ4d6J7cnxy4DRJSNL9u6QOjvUFONOiecs483m4AU9qG2t5Pw > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20697088818153 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -8,5 ; -4,9 ; -3,1 ; -4,2 ; 3,7 ; 0,92 ; NABETHSE2119 ; 83B4D10b2C6d67A92fcFea4ABDdDBA5D3b5eDec77ebC409cdCaca6Ac28f4e04e ; < 3DXYCv5STs94OA97Z7RpsT2wYr1vtkm60uF5nYLJxtGbyqOWb09kK476USXg8TiX > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21309173929822 ; -1 ; -0,00025 ; 0,00025 ; 0,6 ; -7,5 ; 1,4 ; -8,1 ; -9,6 ; -2,5 ; 0,68 ; NABETHDE2151 ; d3eCfccC5feFebaAcbf36c3BDc51ce8eEe6edcB9c6d9DdDA0F1f9dBb6FACBcd1 ; < td1DP04x0GskJ30Ur579Mw7k31pn4Og1um5611ANuQqiajeu98J5ZT351o0THHgc > >										24
											
//	  < CALLS ; 6M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 6M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABETH										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; c46dFe0BcdDbC242FCcffEfe7adEDb875fceE771dcdC74Ff9Eb380bdD9efDe7A ; < QmUiLtY4zThGlnc1nJ2DGdYQw7r8240UhM78Efgvv0U79C13zp4hW216opNi3hb1 > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14024520829845 ; -1 ; -0,00025 ; 0,00025 ; -0,1 ; -6,3 ; -6,3 ; 0,2 ; 8,4 ; 3,8 ; -0,62 ; NABETH45JA19 ; 79C41e7D8c24974e6dD7c8d87CBbd0Bc0AdE5abFB7EbBbfFFdDFDccB22bFba13 ; < yrv7q09CRZpc9y55DI8Ec2DNN33p0bB5IPDOQxkmxPAU83K5B9rI9hKpu6SO8A7j > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14066622480045 ; -1 ; -0,00025 ; 0,00025 ; -0,1 ; 1 ; -1,1 ; 4 ; -1,4 ; -6,5 ; 0,76 ; NABETHMA1928 ; DcAcBD1EBEF83ae2BDacdAeA21EAB85b044dDCafF1AccEAe1bcFABbB99CbD0cB ; < 3sfvlNKPMyXDXE3IN1OvD4Kb4glfnAw7lE9y1aqM55I5BD61rI5oQgTxabC5CvT0 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14145489844192 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; -7,8 ; -4,6 ; -7,6 ; 8,9 ; -9,8 ; 0,63 ; NABETHMA1962 ; E8c9cCccaBacFdccbc5cE54BFcA5BbBBCDBB7Fab6e20Fac16dE6e0Faca82d0e7 ; < 5sGtT7W5TwXnA4mAC9vvbs9Rg0Lez4S7A4X7DUl6hPO59MEbvD5KB0H3tC6Z8xZ7 > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14236650981283 ; -1 ; -0,00025 ; 0,00025 ; 0 ; -4,4 ; -8,4 ; -1,7 ; 8 ; 0,1 ; -0,59 ; NABETHJU1995 ; Ea359E7B2baaD89e40524bD3FcA3E51524adCb9A6DBFBd50bDdac2c7Bc3977A7 ; < iJAEK75E0Ubv76Bx008GgS8gs59uxF6lb70YM5enfP1HE60O1wuin1NySixqS0D6 > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14364357060859 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -7,6 ; 2,7 ; -9,1 ; 8,5 ; 3,6 ; -0,41 ; NABETHSE1971 ; 4df5dEFbf3B55A34fcc9cEa4eBCE2eCcA4BdAf38cd90EeF03d26e1FAfeeEDEa9 ; < 52rKCozn97zA5MoQ7824Z2p1nLq4oX1rYupZ457g5yapQdjVw67lG33dp0bXY592 > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14505850899257 ; -1 ; -0,00025 ; 0,00025 ; 4,5 ; 1,6 ; 1,9 ; -5,2 ; -8,3 ; -8,8 ; -0,39 ; NABETHDE1947 ; 6CECc2cD0Fa0CE9f9CF51AcDF9a8B4fAA0c3ED7EbA38B8c7b7fb23acD3cdE264 ; < Iddzjt1owEOidFRx17GlTeT2KuBF3E78lQO02q5NYB5011K14baC58w6L4K63Giv > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,1468088164366 ; -1 ; -0,00025 ; 0,00025 ; -0,5 ; -0,7 ; -1 ; -1,3 ; 0 ; -2,2 ; 0,75 ; NABETHJA2038 ; 2755a3b07Dbb6fe8BfDdCB5ceFC5acdADE0f114F37fEDC2F1b40C7eb1ddE38cc ; < c2nz3p653X412mg96Wk5zf8c1b40rruC2W8i35U3yz0r8jdHliVP4L1hwfcHlF2x > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14870675405559 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 3 ; 3,4 ; 1,3 ; 1,9 ; -4,9 ; -0,68 ; NABETHMA2031 ; 4d46f4adD81d1642EdcCa35CB87D1B9CC8c0B3B8Bd1AbB4efd5959e0bF83DF7d ; < c5Ph61U21D0Unfx8Mgf48C09GrD5J6ucSKPII2eGjzBY8CXq0J2cvTW85T1n2P16 > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,1508851783978 ; -1 ; -0,00025 ; 0,00025 ; -7,8 ; 2,3 ; -5 ; 8,1 ; 2,1 ; -5,6 ; -0,28 ; NABETHMA2082 ; cFcAbc9cd979fBEabCEE27bA1fb8e894eDbDdDFdcEdd05Eb3ABE7bb7e1ca0DfA ; < rqAyF2sWK93VZ2dKiS3xUVZe1wtvVm36YNBc7kqjdeyCNL62UrOEuziJhI1T0k0e > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15322826521826 ; -1 ; -0,00025 ; 0,00025 ; -9,6 ; -1,5 ; -4,5 ; -4,8 ; 4,5 ; 9,8 ; -0,71 ; NABETHJU2056 ; 67Bd2dBed3494Ffcfad21A61bebBDADfDC7Fe6Fd939Dfcca06FAafEC83AFd394 ; < 2mw08Ah2d6acW03CMM80fxats5NCBScv9o7ZzL71Fsm2a2clHA4YWzgMp1vRA9rj > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15581199030619 ; -1 ; -0,00025 ; 0,00025 ; 9,2 ; 4,6 ; 8,5 ; -5,7 ; -8 ; -1 ; -0,55 ; NABETHSE2052 ; f2b175edCBfb0eeAeEc83c6edF24bEdfe749A3de6C97bbcee4daAAcCbae6679F ; < WdeMg185lKS5ShGb383R1kZy22IWxkpa92dOc4dhLd6y8V8xfV3xR8F2Hvprvnzm > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15859402976686 ; -1 ; -0,00025 ; 0,00025 ; -4,2 ; -5,9 ; 3,6 ; -0,4 ; 7 ; -8,9 ; -0,6 ; NABETHDE2069 ; 66745Bb6e3b4ffC19Ae6CfC2ed0bBbCABfeDa5A3beBaE5BA2C4AE1882D3ceD8F ; < 7Reve50cr2qveV4NoiOJ77qH0qUM7I93LOLahuda2bMojR1EkGJH5747P0S2CsSo > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,1616314175278 ; -1 ; -0,00025 ; 0,00025 ; 3,4 ; -4,4 ; 9,1 ; -6,1 ; 5,6 ; -3,9 ; -0,76 ; NABETHJA2183 ; fAddebC2a1Ced0C3F8Da9a4Fa004B4Bb557DACCD172DBDAe1a80cF32A91fBcd7 ; < 702OiSygi1357Goesgb7u8MxM3Xu5OHn4F8OU59x9zUJ233JQT210f5NVYg71m2j > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16498188068828 ; -1 ; -0,00025 ; 0,00025 ; 6,2 ; 0 ; 7,8 ; -7,5 ; 7,5 ; 9,8 ; 0,13 ; NABETHMA2171 ; 7a4aAFAeBBD1878cdca13bE0cBbB9A0aa60AdCe69E46BeC9e8EB5E1B419C7fdC ; < 2q058Ox13HY87m44hvX70wC56Tc81290W3ZGft5H6Cvk2eT811pq9F6bc1650sGX > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16865387556168 ; -1 ; -0,00025 ; 0,00025 ; -9 ; -7,2 ; -0,6 ; 6,4 ; -9,3 ; -9,3 ; -0,11 ; NABETHMA2177 ; bcB3CAB5daDC0D2625F15Ffd8cabcB8a2e30f0fEAB90C9c9FcCa2EaEac071a5F ; < Ypfv6XBO8xMP4KObkC0N9z35gtx6JqwX6ourv34488Kl692G7b0l8Y3VSzV3JNC5 > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,17258840763381 ; -1 ; -0,00025 ; 0,00025 ; 1,5 ; -4,9 ; 1,8 ; 1,8 ; -1,9 ; -5,5 ; 0,13 ; NABETHJU2164 ; 952ad6AAbf1edF6fA928Ddbd0cDBCf195Fb9cEBe2A54aBa43Ce2CFE7cB5bBa9e ; < dU18045tiz1MsG8aKC2465E42K0712o74LQMsJb4PmRvMQ60SzPx95D8Tkqxw03v > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17664967976558 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -8,1 ; 3 ; 5,3 ; -7 ; 8 ; 0,08 ; NABETHSE2199 ; d9Eb9fc1db15db9Adc136AEadBc3b7E9baDDE0EafbB39e8e8597ebb0EC534a2a ; < VKK07sCndFz66ql3b4237i24RG0V83DWsv1o568dQB49s5lLfH8wz1lLUxI1u68w > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,1810354564474 ; -1 ; -0,00025 ; 0,00025 ; 2,2 ; 5,3 ; 2,3 ; -8,3 ; -2,5 ; 9 ; 0,49 ; NABETHDE2192 ; 2B2eD30DFDBb88C3fA315dF0E7b4A1331Fa2AD71B0db03305fC32AF3532DbC72 ; < JMaHybwD6VNFJthj2EZ7ju8dvpXBPAtFB16Xwnn1xb8U6VrEV40zC629pTktMGaU > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18570670987179 ; -1 ; -0,00025 ; 0,00025 ; 0,3 ; 1,3 ; -4,5 ; -6,8 ; 6,1 ; 9,1 ; 0,38 ; NABETHJA2155 ; bEeD0BC2a2cEc41bcbecA3BbaED46AF0bD59f4Ae4DcAC29C09DD5aaF06F8ab41 ; < Kn2yg13dkc8499i3Rw7ATZcv8mT8pqm0ZhtK84U05712huT8giNjc0I55nle9yT3 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19065601321761 ; -1 ; -0,00025 ; 0,00025 ; 3,8 ; 6,1 ; 7,7 ; 2,6 ; -9,4 ; 2,4 ; -0,31 ; NABETHMA2181 ; bbDe6bbbcFe2BdbEa3B8aFCfFE5fCfcDaCdDCCe1f9666bBfBadbd1A9DcdCfC35 ; < 6hVaA5f2Pr1ae1JFXLg5452c7smAXJEkz1CuBFQD7TIv30v3R2Tjj8wCp5H0q9M4 > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19580452972815 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; -7 ; 8,8 ; 6,3 ; -2 ; 9,1 ; -0,8 ; NABETHMA2194 ; EAA8F32c1DCE3Acd3FBA0e8D30DE032fB5a06cD5dAEe0fc9D5E99be8deA0be6A ; < 7IyUUYo2M7k4gw95N3aZu1O596JbXC0I8w89NTbM9nHSJ2YBKMn1ps01UK73SudD > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20122523958412 ; -1 ; -0,00025 ; 0,00025 ; 3 ; 3,6 ; -7,7 ; -2,5 ; 5,2 ; -5,8 ; -0,73 ; NABETHJU2120 ; AA015D8cc3ce74A16DB3FA9FEABb13733cDDFB6ebd1BeAAED3Fdb5cACFEfaa8c ; < UQ10B3C66OQXeZ8jJ4d6J7cnxy4DRJSNL9u6QOjvUFONOiecs483m4AU9qG2t5Pw > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20697088818153 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -8,5 ; -4,9 ; -3,1 ; -4,2 ; 3,7 ; 0,92 ; NABETHSE2119 ; 83B4D10b2C6d67A92fcFea4ABDdDBA5D3b5eDec77ebC409cdCaca6Ac28f4e04e ; < 3DXYCv5STs94OA97Z7RpsT2wYr1vtkm60uF5nYLJxtGbyqOWb09kK476USXg8TiX > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21309173929822 ; -1 ; -0,00025 ; 0,00025 ; 0,6 ; -7,5 ; 1,4 ; -8,1 ; -9,6 ; -2,5 ; 0,68 ; NABETHDE2151 ; d3eCfccC5feFebaAcbf36c3BDc51ce8eEe6edcB9c6d9DdDA0F1f9dBb6FACBcd1 ; < td1DP04x0GskJ30Ur579Mw7k31pn4Og1um5611ANuQqiajeu98J5ZT351o0THHgc > >										24
											
//	  < CALLS ; 12M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 12M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABETH										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; c46dFe0BcdDbC242FCcffEfe7adEDb875fceE771dcdC74Ff9Eb380bdD9efDe7A ; < QmUiLtY4zThGlnc1nJ2DGdYQw7r8240UhM78Efgvv0U79C13zp4hW216opNi3hb1 > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14024520829845 ; -1 ; -0,00025 ; 0,00025 ; -0,1 ; -6,3 ; -6,3 ; 0,2 ; 8,4 ; 3,8 ; -0,62 ; NABETH45JA19 ; 79C41e7D8c24974e6dD7c8d87CBbd0Bc0AdE5abFB7EbBbfFFdDFDccB22bFba13 ; < yrv7q09CRZpc9y55DI8Ec2DNN33p0bB5IPDOQxkmxPAU83K5B9rI9hKpu6SO8A7j > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14066622480045 ; -1 ; -0,00025 ; 0,00025 ; -0,1 ; 1 ; -1,1 ; 4 ; -1,4 ; -6,5 ; 0,76 ; NABETHMA1928 ; DcAcBD1EBEF83ae2BDacdAeA21EAB85b044dDCafF1AccEAe1bcFABbB99CbD0cB ; < 3sfvlNKPMyXDXE3IN1OvD4Kb4glfnAw7lE9y1aqM55I5BD61rI5oQgTxabC5CvT0 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14145489844192 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; -7,8 ; -4,6 ; -7,6 ; 8,9 ; -9,8 ; 0,63 ; NABETHMA1962 ; E8c9cCccaBacFdccbc5cE54BFcA5BbBBCDBB7Fab6e20Fac16dE6e0Faca82d0e7 ; < 5sGtT7W5TwXnA4mAC9vvbs9Rg0Lez4S7A4X7DUl6hPO59MEbvD5KB0H3tC6Z8xZ7 > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14236650981283 ; -1 ; -0,00025 ; 0,00025 ; 0 ; -4,4 ; -8,4 ; -1,7 ; 8 ; 0,1 ; -0,59 ; NABETHJU1995 ; Ea359E7B2baaD89e40524bD3FcA3E51524adCb9A6DBFBd50bDdac2c7Bc3977A7 ; < iJAEK75E0Ubv76Bx008GgS8gs59uxF6lb70YM5enfP1HE60O1wuin1NySixqS0D6 > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14364357060859 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -7,6 ; 2,7 ; -9,1 ; 8,5 ; 3,6 ; -0,41 ; NABETHSE1971 ; 4df5dEFbf3B55A34fcc9cEa4eBCE2eCcA4BdAf38cd90EeF03d26e1FAfeeEDEa9 ; < 52rKCozn97zA5MoQ7824Z2p1nLq4oX1rYupZ457g5yapQdjVw67lG33dp0bXY592 > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14505850899257 ; -1 ; -0,00025 ; 0,00025 ; 4,5 ; 1,6 ; 1,9 ; -5,2 ; -8,3 ; -8,8 ; -0,39 ; NABETHDE1947 ; 6CECc2cD0Fa0CE9f9CF51AcDF9a8B4fAA0c3ED7EbA38B8c7b7fb23acD3cdE264 ; < Iddzjt1owEOidFRx17GlTeT2KuBF3E78lQO02q5NYB5011K14baC58w6L4K63Giv > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,1468088164366 ; -1 ; -0,00025 ; 0,00025 ; -0,5 ; -0,7 ; -1 ; -1,3 ; 0 ; -2,2 ; 0,75 ; NABETHJA2038 ; 2755a3b07Dbb6fe8BfDdCB5ceFC5acdADE0f114F37fEDC2F1b40C7eb1ddE38cc ; < c2nz3p653X412mg96Wk5zf8c1b40rruC2W8i35U3yz0r8jdHliVP4L1hwfcHlF2x > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14870675405559 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 3 ; 3,4 ; 1,3 ; 1,9 ; -4,9 ; -0,68 ; NABETHMA2031 ; 4d46f4adD81d1642EdcCa35CB87D1B9CC8c0B3B8Bd1AbB4efd5959e0bF83DF7d ; < c5Ph61U21D0Unfx8Mgf48C09GrD5J6ucSKPII2eGjzBY8CXq0J2cvTW85T1n2P16 > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,1508851783978 ; -1 ; -0,00025 ; 0,00025 ; -7,8 ; 2,3 ; -5 ; 8,1 ; 2,1 ; -5,6 ; -0,28 ; NABETHMA2082 ; cFcAbc9cd979fBEabCEE27bA1fb8e894eDbDdDFdcEdd05Eb3ABE7bb7e1ca0DfA ; < rqAyF2sWK93VZ2dKiS3xUVZe1wtvVm36YNBc7kqjdeyCNL62UrOEuziJhI1T0k0e > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15322826521826 ; -1 ; -0,00025 ; 0,00025 ; -9,6 ; -1,5 ; -4,5 ; -4,8 ; 4,5 ; 9,8 ; -0,71 ; NABETHJU2056 ; 67Bd2dBed3494Ffcfad21A61bebBDADfDC7Fe6Fd939Dfcca06FAafEC83AFd394 ; < 2mw08Ah2d6acW03CMM80fxats5NCBScv9o7ZzL71Fsm2a2clHA4YWzgMp1vRA9rj > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15581199030619 ; -1 ; -0,00025 ; 0,00025 ; 9,2 ; 4,6 ; 8,5 ; -5,7 ; -8 ; -1 ; -0,55 ; NABETHSE2052 ; f2b175edCBfb0eeAeEc83c6edF24bEdfe749A3de6C97bbcee4daAAcCbae6679F ; < WdeMg185lKS5ShGb383R1kZy22IWxkpa92dOc4dhLd6y8V8xfV3xR8F2Hvprvnzm > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15859402976686 ; -1 ; -0,00025 ; 0,00025 ; -4,2 ; -5,9 ; 3,6 ; -0,4 ; 7 ; -8,9 ; -0,6 ; NABETHDE2069 ; 66745Bb6e3b4ffC19Ae6CfC2ed0bBbCABfeDa5A3beBaE5BA2C4AE1882D3ceD8F ; < 7Reve50cr2qveV4NoiOJ77qH0qUM7I93LOLahuda2bMojR1EkGJH5747P0S2CsSo > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,1616314175278 ; -1 ; -0,00025 ; 0,00025 ; 3,4 ; -4,4 ; 9,1 ; -6,1 ; 5,6 ; -3,9 ; -0,76 ; NABETHJA2183 ; fAddebC2a1Ced0C3F8Da9a4Fa004B4Bb557DACCD172DBDAe1a80cF32A91fBcd7 ; < 702OiSygi1357Goesgb7u8MxM3Xu5OHn4F8OU59x9zUJ233JQT210f5NVYg71m2j > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16498188068828 ; -1 ; -0,00025 ; 0,00025 ; 6,2 ; 0 ; 7,8 ; -7,5 ; 7,5 ; 9,8 ; 0,13 ; NABETHMA2171 ; 7a4aAFAeBBD1878cdca13bE0cBbB9A0aa60AdCe69E46BeC9e8EB5E1B419C7fdC ; < 2q058Ox13HY87m44hvX70wC56Tc81290W3ZGft5H6Cvk2eT811pq9F6bc1650sGX > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16865387556168 ; -1 ; -0,00025 ; 0,00025 ; -9 ; -7,2 ; -0,6 ; 6,4 ; -9,3 ; -9,3 ; -0,11 ; NABETHMA2177 ; bcB3CAB5daDC0D2625F15Ffd8cabcB8a2e30f0fEAB90C9c9FcCa2EaEac071a5F ; < Ypfv6XBO8xMP4KObkC0N9z35gtx6JqwX6ourv34488Kl692G7b0l8Y3VSzV3JNC5 > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,17258840763381 ; -1 ; -0,00025 ; 0,00025 ; 1,5 ; -4,9 ; 1,8 ; 1,8 ; -1,9 ; -5,5 ; 0,13 ; NABETHJU2164 ; 952ad6AAbf1edF6fA928Ddbd0cDBCf195Fb9cEBe2A54aBa43Ce2CFE7cB5bBa9e ; < dU18045tiz1MsG8aKC2465E42K0712o74LQMsJb4PmRvMQ60SzPx95D8Tkqxw03v > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17664967976558 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -8,1 ; 3 ; 5,3 ; -7 ; 8 ; 0,08 ; NABETHSE2199 ; d9Eb9fc1db15db9Adc136AEadBc3b7E9baDDE0EafbB39e8e8597ebb0EC534a2a ; < VKK07sCndFz66ql3b4237i24RG0V83DWsv1o568dQB49s5lLfH8wz1lLUxI1u68w > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,1810354564474 ; -1 ; -0,00025 ; 0,00025 ; 2,2 ; 5,3 ; 2,3 ; -8,3 ; -2,5 ; 9 ; 0,49 ; NABETHDE2192 ; 2B2eD30DFDBb88C3fA315dF0E7b4A1331Fa2AD71B0db03305fC32AF3532DbC72 ; < JMaHybwD6VNFJthj2EZ7ju8dvpXBPAtFB16Xwnn1xb8U6VrEV40zC629pTktMGaU > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18570670987179 ; -1 ; -0,00025 ; 0,00025 ; 0,3 ; 1,3 ; -4,5 ; -6,8 ; 6,1 ; 9,1 ; 0,38 ; NABETHJA2155 ; bEeD0BC2a2cEc41bcbecA3BbaED46AF0bD59f4Ae4DcAC29C09DD5aaF06F8ab41 ; < Kn2yg13dkc8499i3Rw7ATZcv8mT8pqm0ZhtK84U05712huT8giNjc0I55nle9yT3 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19065601321761 ; -1 ; -0,00025 ; 0,00025 ; 3,8 ; 6,1 ; 7,7 ; 2,6 ; -9,4 ; 2,4 ; -0,31 ; NABETHMA2181 ; bbDe6bbbcFe2BdbEa3B8aFCfFE5fCfcDaCdDCCe1f9666bBfBadbd1A9DcdCfC35 ; < 6hVaA5f2Pr1ae1JFXLg5452c7smAXJEkz1CuBFQD7TIv30v3R2Tjj8wCp5H0q9M4 > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19580452972815 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; -7 ; 8,8 ; 6,3 ; -2 ; 9,1 ; -0,8 ; NABETHMA2194 ; EAA8F32c1DCE3Acd3FBA0e8D30DE032fB5a06cD5dAEe0fc9D5E99be8deA0be6A ; < 7IyUUYo2M7k4gw95N3aZu1O596JbXC0I8w89NTbM9nHSJ2YBKMn1ps01UK73SudD > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20122523958412 ; -1 ; -0,00025 ; 0,00025 ; 3 ; 3,6 ; -7,7 ; -2,5 ; 5,2 ; -5,8 ; -0,73 ; NABETHJU2120 ; AA015D8cc3ce74A16DB3FA9FEABb13733cDDFB6ebd1BeAAED3Fdb5cACFEfaa8c ; < UQ10B3C66OQXeZ8jJ4d6J7cnxy4DRJSNL9u6QOjvUFONOiecs483m4AU9qG2t5Pw > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20697088818153 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -8,5 ; -4,9 ; -3,1 ; -4,2 ; 3,7 ; 0,92 ; NABETHSE2119 ; 83B4D10b2C6d67A92fcFea4ABDdDBA5D3b5eDec77ebC409cdCaca6Ac28f4e04e ; < 3DXYCv5STs94OA97Z7RpsT2wYr1vtkm60uF5nYLJxtGbyqOWb09kK476USXg8TiX > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21309173929822 ; -1 ; -0,00025 ; 0,00025 ; 0,6 ; -7,5 ; 1,4 ; -8,1 ; -9,6 ; -2,5 ; 0,68 ; NABETHDE2151 ; d3eCfccC5feFebaAcbf36c3BDc51ce8eEe6edcB9c6d9DdDA0F1f9dBb6FACBcd1 ; < td1DP04x0GskJ30Ur579Mw7k31pn4Og1um5611ANuQqiajeu98J5ZT351o0THHgc > >										24
											
//	  < CALLS ; 24M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 24M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABETH										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 1,14 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; c46dFe0BcdDbC242FCcffEfe7adEDb875fceE771dcdC74Ff9Eb380bdD9efDe7A ; < QmUiLtY4zThGlnc1nJ2DGdYQw7r8240UhM78Efgvv0U79C13zp4hW216opNi3hb1 > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 1,14024520829845 ; -1 ; -0,00025 ; 0,00025 ; -0,1 ; -6,3 ; -6,3 ; 0,2 ; 8,4 ; 3,8 ; -0,62 ; NABETH45JA19 ; 79C41e7D8c24974e6dD7c8d87CBbd0Bc0AdE5abFB7EbBbfFFdDFDccB22bFba13 ; < yrv7q09CRZpc9y55DI8Ec2DNN33p0bB5IPDOQxkmxPAU83K5B9rI9hKpu6SO8A7j > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 1,14066622480045 ; -1 ; -0,00025 ; 0,00025 ; -0,1 ; 1 ; -1,1 ; 4 ; -1,4 ; -6,5 ; 0,76 ; NABETHMA1928 ; DcAcBD1EBEF83ae2BDacdAeA21EAB85b044dDCafF1AccEAe1bcFABbB99CbD0cB ; < 3sfvlNKPMyXDXE3IN1OvD4Kb4glfnAw7lE9y1aqM55I5BD61rI5oQgTxabC5CvT0 > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 1,14145489844192 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; -7,8 ; -4,6 ; -7,6 ; 8,9 ; -9,8 ; 0,63 ; NABETHMA1962 ; E8c9cCccaBacFdccbc5cE54BFcA5BbBBCDBB7Fab6e20Fac16dE6e0Faca82d0e7 ; < 5sGtT7W5TwXnA4mAC9vvbs9Rg0Lez4S7A4X7DUl6hPO59MEbvD5KB0H3tC6Z8xZ7 > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 1,14236650981283 ; -1 ; -0,00025 ; 0,00025 ; 0 ; -4,4 ; -8,4 ; -1,7 ; 8 ; 0,1 ; -0,59 ; NABETHJU1995 ; Ea359E7B2baaD89e40524bD3FcA3E51524adCb9A6DBFBd50bDdac2c7Bc3977A7 ; < iJAEK75E0Ubv76Bx008GgS8gs59uxF6lb70YM5enfP1HE60O1wuin1NySixqS0D6 > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 1,14364357060859 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -7,6 ; 2,7 ; -9,1 ; 8,5 ; 3,6 ; -0,41 ; NABETHSE1971 ; 4df5dEFbf3B55A34fcc9cEa4eBCE2eCcA4BdAf38cd90EeF03d26e1FAfeeEDEa9 ; < 52rKCozn97zA5MoQ7824Z2p1nLq4oX1rYupZ457g5yapQdjVw67lG33dp0bXY592 > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 1,14505850899257 ; -1 ; -0,00025 ; 0,00025 ; 4,5 ; 1,6 ; 1,9 ; -5,2 ; -8,3 ; -8,8 ; -0,39 ; NABETHDE1947 ; 6CECc2cD0Fa0CE9f9CF51AcDF9a8B4fAA0c3ED7EbA38B8c7b7fb23acD3cdE264 ; < Iddzjt1owEOidFRx17GlTeT2KuBF3E78lQO02q5NYB5011K14baC58w6L4K63Giv > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 1,1468088164366 ; -1 ; -0,00025 ; 0,00025 ; -0,5 ; -0,7 ; -1 ; -1,3 ; 0 ; -2,2 ; 0,75 ; NABETHJA2038 ; 2755a3b07Dbb6fe8BfDdCB5ceFC5acdADE0f114F37fEDC2F1b40C7eb1ddE38cc ; < c2nz3p653X412mg96Wk5zf8c1b40rruC2W8i35U3yz0r8jdHliVP4L1hwfcHlF2x > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 1,14870675405559 ; -1 ; -0,00025 ; 0,00025 ; -0,3 ; 3 ; 3,4 ; 1,3 ; 1,9 ; -4,9 ; -0,68 ; NABETHMA2031 ; 4d46f4adD81d1642EdcCa35CB87D1B9CC8c0B3B8Bd1AbB4efd5959e0bF83DF7d ; < c5Ph61U21D0Unfx8Mgf48C09GrD5J6ucSKPII2eGjzBY8CXq0J2cvTW85T1n2P16 > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 1,1508851783978 ; -1 ; -0,00025 ; 0,00025 ; -7,8 ; 2,3 ; -5 ; 8,1 ; 2,1 ; -5,6 ; -0,28 ; NABETHMA2082 ; cFcAbc9cd979fBEabCEE27bA1fb8e894eDbDdDFdcEdd05Eb3ABE7bb7e1ca0DfA ; < rqAyF2sWK93VZ2dKiS3xUVZe1wtvVm36YNBc7kqjdeyCNL62UrOEuziJhI1T0k0e > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 1,15322826521826 ; -1 ; -0,00025 ; 0,00025 ; -9,6 ; -1,5 ; -4,5 ; -4,8 ; 4,5 ; 9,8 ; -0,71 ; NABETHJU2056 ; 67Bd2dBed3494Ffcfad21A61bebBDADfDC7Fe6Fd939Dfcca06FAafEC83AFd394 ; < 2mw08Ah2d6acW03CMM80fxats5NCBScv9o7ZzL71Fsm2a2clHA4YWzgMp1vRA9rj > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 1,15581199030619 ; -1 ; -0,00025 ; 0,00025 ; 9,2 ; 4,6 ; 8,5 ; -5,7 ; -8 ; -1 ; -0,55 ; NABETHSE2052 ; f2b175edCBfb0eeAeEc83c6edF24bEdfe749A3de6C97bbcee4daAAcCbae6679F ; < WdeMg185lKS5ShGb383R1kZy22IWxkpa92dOc4dhLd6y8V8xfV3xR8F2Hvprvnzm > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 1,15859402976686 ; -1 ; -0,00025 ; 0,00025 ; -4,2 ; -5,9 ; 3,6 ; -0,4 ; 7 ; -8,9 ; -0,6 ; NABETHDE2069 ; 66745Bb6e3b4ffC19Ae6CfC2ed0bBbCABfeDa5A3beBaE5BA2C4AE1882D3ceD8F ; < 7Reve50cr2qveV4NoiOJ77qH0qUM7I93LOLahuda2bMojR1EkGJH5747P0S2CsSo > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 1,1616314175278 ; -1 ; -0,00025 ; 0,00025 ; 3,4 ; -4,4 ; 9,1 ; -6,1 ; 5,6 ; -3,9 ; -0,76 ; NABETHJA2183 ; fAddebC2a1Ced0C3F8Da9a4Fa004B4Bb557DACCD172DBDAe1a80cF32A91fBcd7 ; < 702OiSygi1357Goesgb7u8MxM3Xu5OHn4F8OU59x9zUJ233JQT210f5NVYg71m2j > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 1,16498188068828 ; -1 ; -0,00025 ; 0,00025 ; 6,2 ; 0 ; 7,8 ; -7,5 ; 7,5 ; 9,8 ; 0,13 ; NABETHMA2171 ; 7a4aAFAeBBD1878cdca13bE0cBbB9A0aa60AdCe69E46BeC9e8EB5E1B419C7fdC ; < 2q058Ox13HY87m44hvX70wC56Tc81290W3ZGft5H6Cvk2eT811pq9F6bc1650sGX > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 1,16865387556168 ; -1 ; -0,00025 ; 0,00025 ; -9 ; -7,2 ; -0,6 ; 6,4 ; -9,3 ; -9,3 ; -0,11 ; NABETHMA2177 ; bcB3CAB5daDC0D2625F15Ffd8cabcB8a2e30f0fEAB90C9c9FcCa2EaEac071a5F ; < Ypfv6XBO8xMP4KObkC0N9z35gtx6JqwX6ourv34488Kl692G7b0l8Y3VSzV3JNC5 > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 1,17258840763381 ; -1 ; -0,00025 ; 0,00025 ; 1,5 ; -4,9 ; 1,8 ; 1,8 ; -1,9 ; -5,5 ; 0,13 ; NABETHJU2164 ; 952ad6AAbf1edF6fA928Ddbd0cDBCf195Fb9cEBe2A54aBa43Ce2CFE7cB5bBa9e ; < dU18045tiz1MsG8aKC2465E42K0712o74LQMsJb4PmRvMQ60SzPx95D8Tkqxw03v > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 1,17664967976558 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -8,1 ; 3 ; 5,3 ; -7 ; 8 ; 0,08 ; NABETHSE2199 ; d9Eb9fc1db15db9Adc136AEadBc3b7E9baDDE0EafbB39e8e8597ebb0EC534a2a ; < VKK07sCndFz66ql3b4237i24RG0V83DWsv1o568dQB49s5lLfH8wz1lLUxI1u68w > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 1,1810354564474 ; -1 ; -0,00025 ; 0,00025 ; 2,2 ; 5,3 ; 2,3 ; -8,3 ; -2,5 ; 9 ; 0,49 ; NABETHDE2192 ; 2B2eD30DFDBb88C3fA315dF0E7b4A1331Fa2AD71B0db03305fC32AF3532DbC72 ; < JMaHybwD6VNFJthj2EZ7ju8dvpXBPAtFB16Xwnn1xb8U6VrEV40zC629pTktMGaU > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 1,18570670987179 ; -1 ; -0,00025 ; 0,00025 ; 0,3 ; 1,3 ; -4,5 ; -6,8 ; 6,1 ; 9,1 ; 0,38 ; NABETHJA2155 ; bEeD0BC2a2cEc41bcbecA3BbaED46AF0bD59f4Ae4DcAC29C09DD5aaF06F8ab41 ; < Kn2yg13dkc8499i3Rw7ATZcv8mT8pqm0ZhtK84U05712huT8giNjc0I55nle9yT3 > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 1,19065601321761 ; -1 ; -0,00025 ; 0,00025 ; 3,8 ; 6,1 ; 7,7 ; 2,6 ; -9,4 ; 2,4 ; -0,31 ; NABETHMA2181 ; bbDe6bbbcFe2BdbEa3B8aFCfFE5fCfcDaCdDCCe1f9666bBfBadbd1A9DcdCfC35 ; < 6hVaA5f2Pr1ae1JFXLg5452c7smAXJEkz1CuBFQD7TIv30v3R2Tjj8wCp5H0q9M4 > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 1,19580452972815 ; -1 ; -0,00025 ; 0,00025 ; -9,2 ; -7 ; 8,8 ; 6,3 ; -2 ; 9,1 ; -0,8 ; NABETHMA2194 ; EAA8F32c1DCE3Acd3FBA0e8D30DE032fB5a06cD5dAEe0fc9D5E99be8deA0be6A ; < 7IyUUYo2M7k4gw95N3aZu1O596JbXC0I8w89NTbM9nHSJ2YBKMn1ps01UK73SudD > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 1,20122523958412 ; -1 ; -0,00025 ; 0,00025 ; 3 ; 3,6 ; -7,7 ; -2,5 ; 5,2 ; -5,8 ; -0,73 ; NABETHJU2120 ; AA015D8cc3ce74A16DB3FA9FEABb13733cDDFB6ebd1BeAAED3Fdb5cACFEfaa8c ; < UQ10B3C66OQXeZ8jJ4d6J7cnxy4DRJSNL9u6QOjvUFONOiecs483m4AU9qG2t5Pw > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 1,20697088818153 ; -1 ; -0,00025 ; 0,00025 ; -9,4 ; -8,5 ; -4,9 ; -3,1 ; -4,2 ; 3,7 ; 0,92 ; NABETHSE2119 ; 83B4D10b2C6d67A92fcFea4ABDdDBA5D3b5eDec77ebC409cdCaca6Ac28f4e04e ; < 3DXYCv5STs94OA97Z7RpsT2wYr1vtkm60uF5nYLJxtGbyqOWb09kK476USXg8TiX > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 1,21309173929822 ; -1 ; -0,00025 ; 0,00025 ; 0,6 ; -7,5 ; 1,4 ; -8,1 ; -9,6 ; -2,5 ; 0,68 ; NABETHDE2151 ; d3eCfccC5feFebaAcbf36c3BDc51ce8eEe6edcB9c6d9DdDA0F1f9dBb6FACBcd1 ; < td1DP04x0GskJ30Ur579Mw7k31pn4Og1um5611ANuQqiajeu98J5ZT351o0THHgc > >										24
											
//	  < CALLS ; 36M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 36M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABBTC										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 0,0000440550542260437 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; EE23C8F0AAB2FCCcf514Fe30bE8D5f28bFA9c3bfDccc90FC8e6ABFc6a99fa4b4 ; < S8iBCc8103aaUo44672xd5w60P1I82Kuz5Ih2hZmf50A48N8P6di4n3vmBft11YC > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 0,0000440625918254867 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -8 ; 5,7 ; -9,2 ; -2,8 ; 6,6 ; -0,15 ; NABBTC19JA19 ; 87d0EDf5AFEa1Ae2e9aD5d8badA7DDcfBBEcF0460D2C6dDD78f8D7d7AaCdc91d ; < UjRh45OBMC0s7B9qB4HjYPlX08TQKhsYl369SzY5X456PMH32j8DP8TeR4Uuw8XU > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 0,0000440785527635661 ; -1 ; -0,00025 ; 0,00025 ; 6,8 ; -6,1 ; 3,1 ; -4,6 ; 8,8 ; 9,6 ; -0,27 ; NABBTCMA1992 ; 3de0C8effB82FDA0C82bdA1DaFACbEbc6dFA2CfE0B30dc0aECa1faaEbcCBBEBe ; < cSh8v72P9udt5dZ76W3d8kAMv7Nn3839453YM88TjTp20Jc4MxMiPH0josYI6tpL > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 0,0000441069576404218 ; -1 ; -0,00025 ; 0,00025 ; -3,2 ; -1,3 ; 3,4 ; -9,1 ; 1,3 ; -5 ; 0,12 ; NABBTCMA1979 ; 2Ce1cAaadb2dDDFd3Ac2c60aE3AbDDeBdfAEFCAe0f2DEacCDF2f68AfAaF87FDD ; < 5th40B7ZCgN9bgrtG1K59F0kNe8L8wu6S3ZZ8aOr8LdeNtae1xp2aUU0iRdWgSPF > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 0,0000441404630431867 ; -1 ; -0,00025 ; 0,00025 ; -1,7 ; -0,3 ; -9,1 ; -9,6 ; -9,7 ; -4,4 ; 0,35 ; NABBTCJU1923 ; CBCAB777BCa1fdB8feC8F2b149f2EBd122FeEF6c6A4dFCDA5186d6aA83D4FcEC ; < kcK5plndNfWa9T8h7w1T8RQU3A8Lvnyk94dV52UmZLLKQO2Hb2rXGM7oeN71rMIV > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 0,000044182260006002 ; -1 ; -0,00025 ; 0,00025 ; -1,6 ; -1,3 ; -3,9 ; -0,5 ; -1,8 ; 0,2 ; -0,11 ; NABBTCSE1981 ; de54D71b3ABddDFdd419b6aDAbFAFAAFb44E0c1cC4efAfbDE0A07a2fdd83ECE5 ; < 60w650tN8i4kMZcqS0I8pE58KuP9LTyJ926ld4HMnLQ9334324dp0Z5fBZJgHJ1J > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 0,0000442369673518382 ; -1 ; -0,00025 ; 0,00025 ; -7,9 ; 3,1 ; 7 ; -4,7 ; 9,1 ; -7 ; -0,31 ; NABBTCDE1963 ; 8AADCC6fac34B8A3f392Fa6e2bdFe53BffFB02a5eff7aEfCF28C1CcEFBDf1a9E ; < MuPk57l9t4796WGQ3fw1wyoSSQicn9xgyO3JFN869T0X7Y5cutpb4e5faGC4M3X6 > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 0,0000442991014761032 ; -1 ; -0,00025 ; 0,00025 ; -8,8 ; 3,4 ; -3,3 ; 6,6 ; 0 ; -8 ; -0,56 ; NABBTCJA2010 ; 7be6ad784be3e6832F45Df1a9a1DD7deb4fE5F6b2F87e6fAFCcE80DffCafBFb2 ; < 8m8T7SXEMyMH45qbt4wQXNOnAMzS195xa27GExbOn9Avw31f2vfieO23m73X824H > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 0,0000443709534222985 ; -1 ; -0,00025 ; 0,00025 ; 8,5 ; -8,7 ; -8,8 ; -3,6 ; 5,6 ; -6,6 ; -0,08 ; NABBTCMA2013 ; E99FE2fa5eD9B23EcdCEd6F7be27bD9cF0F45A89F7FFfF90cFDDDfcEAF28C314 ; < F7YggcN7i24PX615se6jZrCKKQYa2n9A0G9C66Qtu10znpn2K0Wa5276db44W6AM > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 0,0000444515938440585 ; -1 ; -0,00025 ; 0,00025 ; -0,7 ; -5,9 ; -4,8 ; -2,1 ; -3,6 ; -4,4 ; 0,23 ; NABBTCMA2017 ; CAaBedaa4d92b75BBb49dA5FB6BfFbEdDCD04a6Ce24c131caE2ABADfd7971ceA ; < 30NY4SvYUm4l7q7IJ577GA79wvpo7C589lx7ztoo89s0M36k8xnmTOXA7Uf1gP9M > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 0,0000445465379912128 ; -1 ; -0,00025 ; 0,00025 ; 5,4 ; -9,6 ; -0,6 ; 3,9 ; -3 ; -7,6 ; 0,28 ; NABBTCJU2027 ; F92B9Eb5533c9d3dF6f3A1aDfCbaB459290EBF0aD2ed0bFaED2cAf38519abAFa ; < p68YlL2YEJf8Rt0i487HC7f2u6aUh97PJy950pr6i4B6j87txZEYavl7ZknAj577 > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 0,0000446506623238387 ; -1 ; -0,00025 ; 0,00025 ; 5,6 ; -8,9 ; -4,2 ; -1,8 ; -7,2 ; -4,5 ; -0,35 ; NABBTCSE2032 ; 2dBA0abC6Ef1aBfeFdB0ca7e8d0eCdCed6a9Fc1df0ad9BfFe4aa1e3dba71e63B ; < L82d4d6grLq0nII9x663vIU84803ottc5Ok8jEfG5LVblp569EnN0JF13qu8R440 > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 0,0000447662182379327 ; -1 ; -0,00025 ; 0,00025 ; -1,2 ; 0,4 ; 3,6 ; 1,5 ; -4,5 ; -9 ; -0,02 ; NABBTCDE2063 ; eBBdBBFBecAf2FBCF8DbD8FfFfFDDa17BFFAB561bBD6Aaaf51fFA2Ffdf889FeB ; < Z950Io3KLgggH3L5Q1ZxD8GT4SQO75WRZ8Qm6QYeZn1LQ5xhG7c21fvwnz4VR1eZ > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 0,0000448885918541723 ; -1 ; -0,00025 ; 0,00025 ; 6,6 ; -2,3 ; 7,7 ; -6,4 ; -7,7 ; 8,3 ; 0,21 ; NABBTCJA2183 ; 0bf6CAB5b1DF5f1aDDEc13dcdFE9CAaD17547e1E16eCE7aC2173CDeC4FDaad0f ; < L9P1Uma4XO1Z06xB1TaK42cE74nV5uvBreJsQgG7lvH8prD2isrj12g39UgKkxyc > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 0,0000450218334890655 ; -1 ; -0,00025 ; 0,00025 ; -8,1 ; -2,5 ; -4,6 ; -7 ; -7,5 ; -8,8 ; 0,66 ; NABBTCMA2137 ; CC5157E8F3C50b86aFdAA5aCC0Df7D5bddEbEEd5A9cea925B7caAF4A9cc621a2 ; < ULOA6G2x7ertNPVC3K2oJJ83XbhN42zUuurglq9iZHCGk0WbjUvRjFM8c1qRNG67 > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 0,0000451594191295597 ; -1 ; -0,00025 ; 0,00025 ; -3,6 ; 6,5 ; 2,7 ; 2 ; 1,9 ; -5,9 ; 0,51 ; NABBTCMA2145 ; 1706ebd6374e8EA9CC5FA22C0dcc4aE5ffb1dc8B85Caa6e35e6E1Ac97530FB64 ; < vEXqioc3dV5J8WDhqpURFKeRU9jB2N8S9MGfxC65gXB0CVZ2f983Y8YW89vL2TpU > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 0,0000453065810974108 ; -1 ; -0,00025 ; 0,00025 ; 2,5 ; 6,8 ; -6,6 ; -8,5 ; 4,1 ; -3,2 ; -0,38 ; NABBTCJU2131 ; 1cb2eCCe33EA5aA505C62FB4336DD48cDAE5d7aCB7b6FfBb2CE5ce4f6dbe1C4A ; < 1cLt6PLEVqUO8j4X1n8HBdkfoZpFgO9C90bWt2JgzH1oOkwCnJI8g4nE9EN68l7B > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 0,0000454640445907012 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; 8,4 ; 7,7 ; -1,6 ; 7 ; 5,6 ; -0,78 ; NABBTCSE2168 ; eEeAeD3e0e8dEcfEAB647edCddeaccACfe1eFc94eabBEefddebcAfDD0eB15fA9 ; < KlZ47582B9Qpu3HpzW0cSQ435P6Ibl1u5An5Wc7DCQu19Xz6Q05T8I14HV71JzD8 > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 0,0000456336865249775 ; -1 ; -0,00025 ; 0,00025 ; -1,7 ; 2,4 ; 5,7 ; 1,5 ; -1,8 ; -1,5 ; 0,47 ; NABBTCDE2130 ; 054bdacC248cD6fEa7B5BAC5Dbc8ec3BCEA9cfaca90DFCCbc1EB269cCbDE52CD ; < 5p9750wg2Ca2cV1W3GSpIl9hTtit25C6Km90LrdML8uR1eSMs8uhtpP1M41wzr52 > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 0,0000458160487126199 ; -1 ; -0,00025 ; 0,00025 ; -4 ; 1,7 ; 6,8 ; -5,8 ; 8,3 ; -8,5 ; 0,97 ; NABBTCJA2187 ; dCBFdEc1BBDbEDbB0D9c5Ecd2cf1FF0A73A8a738cbeB9A3AECD2BDFeeEf8D4ed ; < xN5PBNWYB05KW3vjtxPxhuetNCJh06QU3c7jHs66wmFnx7cn1U29Oju248576ekO > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 0,0000460061916339643 ; -1 ; -0,00025 ; 0,00025 ; 6 ; 3,1 ; 2,5 ; -3,6 ; 3,2 ; -8,8 ; 0,66 ; NABBTCMA2183 ; f3FF9Ce1Baa1B8B3Ab0C5AD91A2acD9baCCeda9cCc5CE8A09BCAA0Cc2d0babb9 ; < 7N6FIu4PcbU3fS0c7714P99GWTTUekVpwx0y7bExIqyz2YPt5kqGleCMU8jilO1g > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 0,0000462048510026623 ; -1 ; -0,00025 ; 0,00025 ; -5,4 ; -9,5 ; -2,4 ; -9,3 ; 4,8 ; -5,7 ; -0,67 ; NABBTCMA2194 ; D73AeDBAAcfd5c4d13E3013cEb77E1BADE9A5EEABAFb725e1bd2A086D7c9FAec ; < T3CGjnj1PAw8I3zHHigwU4JmDbLj4huAgEg6X8tdY9g150XLmb8eSQ0kFRZK1ZgM > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 0,0000464156424757591 ; -1 ; -0,00025 ; 0,00025 ; -8,3 ; -9,3 ; 6,6 ; 7,8 ; 6,2 ; 1,9 ; 0,83 ; NABBTCJU2148 ; 05cb83C7Ebda3Ec9a169Afbcbbce4ECA9dFA3db9Dd5ae7EB98A95D5d3B7beA7B ; < 92XzHi6pOmin2n7rDxKYHYs34g94G2n4WCnV2RhQdUnuep46AJuW3TTq30d9R7Zf > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 0,0000466337568548027 ; -1 ; -0,00025 ; 0,00025 ; -3,1 ; 2,5 ; 3,3 ; -9,5 ; 8,5 ; -3,1 ; -0,43 ; NABBTCSE2145 ; cb5B5A4AB3F4a33baEEC7fEF03BEeBCCDACC46CFADb1dFCD19Bfdd7d2dEC51b2 ; < jCak5C37O1Mp1r6Uc7dIG67RiT0a081ULv8qXJvGdQI3tScl49l5SmozApsAf4Sw > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 0,000046867217100057 ; -1 ; -0,00025 ; 0,00025 ; 0,5 ; -6,5 ; -6,5 ; 0,7 ; 0,6 ; 2 ; -0,2 ; NABBTCDE2133 ; b1ecB1aCECfBFEFCaD556F5BE1DEaCf8EECDF3ABBAeEcB97cFFDBe68Db4De2aa ; < z5pbs7djdM6MTWuGDFuE6xPLeCpFJSq8V7lm67rsK722v587B5wq86L4G8Se9xyh > >										24
											
//	  < CALLS ; 3M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 3M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABBTC										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 0,0000440550542260437 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; EE23C8F0AAB2FCCcf514Fe30bE8D5f28bFA9c3bfDccc90FC8e6ABFc6a99fa4b4 ; < S8iBCc8103aaUo44672xd5w60P1I82Kuz5Ih2hZmf50A48N8P6di4n3vmBft11YC > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 0,0000440625918254867 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -8 ; 5,7 ; -9,2 ; -2,8 ; 6,6 ; -0,15 ; NABBTC19JA19 ; 87d0EDf5AFEa1Ae2e9aD5d8badA7DDcfBBEcF0460D2C6dDD78f8D7d7AaCdc91d ; < UjRh45OBMC0s7B9qB4HjYPlX08TQKhsYl369SzY5X456PMH32j8DP8TeR4Uuw8XU > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 0,0000440785527635661 ; -1 ; -0,00025 ; 0,00025 ; 6,8 ; -6,1 ; 3,1 ; -4,6 ; 8,8 ; 9,6 ; -0,27 ; NABBTCMA1992 ; 3de0C8effB82FDA0C82bdA1DaFACbEbc6dFA2CfE0B30dc0aECa1faaEbcCBBEBe ; < cSh8v72P9udt5dZ76W3d8kAMv7Nn3839453YM88TjTp20Jc4MxMiPH0josYI6tpL > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 0,0000441069576404218 ; -1 ; -0,00025 ; 0,00025 ; -3,2 ; -1,3 ; 3,4 ; -9,1 ; 1,3 ; -5 ; 0,12 ; NABBTCMA1979 ; 2Ce1cAaadb2dDDFd3Ac2c60aE3AbDDeBdfAEFCAe0f2DEacCDF2f68AfAaF87FDD ; < 5th40B7ZCgN9bgrtG1K59F0kNe8L8wu6S3ZZ8aOr8LdeNtae1xp2aUU0iRdWgSPF > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 0,0000441404630431867 ; -1 ; -0,00025 ; 0,00025 ; -1,7 ; -0,3 ; -9,1 ; -9,6 ; -9,7 ; -4,4 ; 0,35 ; NABBTCJU1923 ; CBCAB777BCa1fdB8feC8F2b149f2EBd122FeEF6c6A4dFCDA5186d6aA83D4FcEC ; < kcK5plndNfWa9T8h7w1T8RQU3A8Lvnyk94dV52UmZLLKQO2Hb2rXGM7oeN71rMIV > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 0,000044182260006002 ; -1 ; -0,00025 ; 0,00025 ; -1,6 ; -1,3 ; -3,9 ; -0,5 ; -1,8 ; 0,2 ; -0,11 ; NABBTCSE1981 ; de54D71b3ABddDFdd419b6aDAbFAFAAFb44E0c1cC4efAfbDE0A07a2fdd83ECE5 ; < 60w650tN8i4kMZcqS0I8pE58KuP9LTyJ926ld4HMnLQ9334324dp0Z5fBZJgHJ1J > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 0,0000442369673518382 ; -1 ; -0,00025 ; 0,00025 ; -7,9 ; 3,1 ; 7 ; -4,7 ; 9,1 ; -7 ; -0,31 ; NABBTCDE1963 ; 8AADCC6fac34B8A3f392Fa6e2bdFe53BffFB02a5eff7aEfCF28C1CcEFBDf1a9E ; < MuPk57l9t4796WGQ3fw1wyoSSQicn9xgyO3JFN869T0X7Y5cutpb4e5faGC4M3X6 > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 0,0000442991014761032 ; -1 ; -0,00025 ; 0,00025 ; -8,8 ; 3,4 ; -3,3 ; 6,6 ; 0 ; -8 ; -0,56 ; NABBTCJA2010 ; 7be6ad784be3e6832F45Df1a9a1DD7deb4fE5F6b2F87e6fAFCcE80DffCafBFb2 ; < 8m8T7SXEMyMH45qbt4wQXNOnAMzS195xa27GExbOn9Avw31f2vfieO23m73X824H > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 0,0000443709534222985 ; -1 ; -0,00025 ; 0,00025 ; 8,5 ; -8,7 ; -8,8 ; -3,6 ; 5,6 ; -6,6 ; -0,08 ; NABBTCMA2013 ; E99FE2fa5eD9B23EcdCEd6F7be27bD9cF0F45A89F7FFfF90cFDDDfcEAF28C314 ; < F7YggcN7i24PX615se6jZrCKKQYa2n9A0G9C66Qtu10znpn2K0Wa5276db44W6AM > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 0,0000444515938440585 ; -1 ; -0,00025 ; 0,00025 ; -0,7 ; -5,9 ; -4,8 ; -2,1 ; -3,6 ; -4,4 ; 0,23 ; NABBTCMA2017 ; CAaBedaa4d92b75BBb49dA5FB6BfFbEdDCD04a6Ce24c131caE2ABADfd7971ceA ; < 30NY4SvYUm4l7q7IJ577GA79wvpo7C589lx7ztoo89s0M36k8xnmTOXA7Uf1gP9M > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 0,0000445465379912128 ; -1 ; -0,00025 ; 0,00025 ; 5,4 ; -9,6 ; -0,6 ; 3,9 ; -3 ; -7,6 ; 0,28 ; NABBTCJU2027 ; F92B9Eb5533c9d3dF6f3A1aDfCbaB459290EBF0aD2ed0bFaED2cAf38519abAFa ; < p68YlL2YEJf8Rt0i487HC7f2u6aUh97PJy950pr6i4B6j87txZEYavl7ZknAj577 > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 0,0000446506623238387 ; -1 ; -0,00025 ; 0,00025 ; 5,6 ; -8,9 ; -4,2 ; -1,8 ; -7,2 ; -4,5 ; -0,35 ; NABBTCSE2032 ; 2dBA0abC6Ef1aBfeFdB0ca7e8d0eCdCed6a9Fc1df0ad9BfFe4aa1e3dba71e63B ; < L82d4d6grLq0nII9x663vIU84803ottc5Ok8jEfG5LVblp569EnN0JF13qu8R440 > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 0,0000447662182379327 ; -1 ; -0,00025 ; 0,00025 ; -1,2 ; 0,4 ; 3,6 ; 1,5 ; -4,5 ; -9 ; -0,02 ; NABBTCDE2063 ; eBBdBBFBecAf2FBCF8DbD8FfFfFDDa17BFFAB561bBD6Aaaf51fFA2Ffdf889FeB ; < Z950Io3KLgggH3L5Q1ZxD8GT4SQO75WRZ8Qm6QYeZn1LQ5xhG7c21fvwnz4VR1eZ > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 0,0000448885918541723 ; -1 ; -0,00025 ; 0,00025 ; 6,6 ; -2,3 ; 7,7 ; -6,4 ; -7,7 ; 8,3 ; 0,21 ; NABBTCJA2183 ; 0bf6CAB5b1DF5f1aDDEc13dcdFE9CAaD17547e1E16eCE7aC2173CDeC4FDaad0f ; < L9P1Uma4XO1Z06xB1TaK42cE74nV5uvBreJsQgG7lvH8prD2isrj12g39UgKkxyc > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 0,0000450218334890655 ; -1 ; -0,00025 ; 0,00025 ; -8,1 ; -2,5 ; -4,6 ; -7 ; -7,5 ; -8,8 ; 0,66 ; NABBTCMA2137 ; CC5157E8F3C50b86aFdAA5aCC0Df7D5bddEbEEd5A9cea925B7caAF4A9cc621a2 ; < ULOA6G2x7ertNPVC3K2oJJ83XbhN42zUuurglq9iZHCGk0WbjUvRjFM8c1qRNG67 > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 0,0000451594191295597 ; -1 ; -0,00025 ; 0,00025 ; -3,6 ; 6,5 ; 2,7 ; 2 ; 1,9 ; -5,9 ; 0,51 ; NABBTCMA2145 ; 1706ebd6374e8EA9CC5FA22C0dcc4aE5ffb1dc8B85Caa6e35e6E1Ac97530FB64 ; < vEXqioc3dV5J8WDhqpURFKeRU9jB2N8S9MGfxC65gXB0CVZ2f983Y8YW89vL2TpU > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 0,0000453065810974108 ; -1 ; -0,00025 ; 0,00025 ; 2,5 ; 6,8 ; -6,6 ; -8,5 ; 4,1 ; -3,2 ; -0,38 ; NABBTCJU2131 ; 1cb2eCCe33EA5aA505C62FB4336DD48cDAE5d7aCB7b6FfBb2CE5ce4f6dbe1C4A ; < 1cLt6PLEVqUO8j4X1n8HBdkfoZpFgO9C90bWt2JgzH1oOkwCnJI8g4nE9EN68l7B > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 0,0000454640445907012 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; 8,4 ; 7,7 ; -1,6 ; 7 ; 5,6 ; -0,78 ; NABBTCSE2168 ; eEeAeD3e0e8dEcfEAB647edCddeaccACfe1eFc94eabBEefddebcAfDD0eB15fA9 ; < KlZ47582B9Qpu3HpzW0cSQ435P6Ibl1u5An5Wc7DCQu19Xz6Q05T8I14HV71JzD8 > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 0,0000456336865249775 ; -1 ; -0,00025 ; 0,00025 ; -1,7 ; 2,4 ; 5,7 ; 1,5 ; -1,8 ; -1,5 ; 0,47 ; NABBTCDE2130 ; 054bdacC248cD6fEa7B5BAC5Dbc8ec3BCEA9cfaca90DFCCbc1EB269cCbDE52CD ; < 5p9750wg2Ca2cV1W3GSpIl9hTtit25C6Km90LrdML8uR1eSMs8uhtpP1M41wzr52 > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 0,0000458160487126199 ; -1 ; -0,00025 ; 0,00025 ; -4 ; 1,7 ; 6,8 ; -5,8 ; 8,3 ; -8,5 ; 0,97 ; NABBTCJA2187 ; dCBFdEc1BBDbEDbB0D9c5Ecd2cf1FF0A73A8a738cbeB9A3AECD2BDFeeEf8D4ed ; < xN5PBNWYB05KW3vjtxPxhuetNCJh06QU3c7jHs66wmFnx7cn1U29Oju248576ekO > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 0,0000460061916339643 ; -1 ; -0,00025 ; 0,00025 ; 6 ; 3,1 ; 2,5 ; -3,6 ; 3,2 ; -8,8 ; 0,66 ; NABBTCMA2183 ; f3FF9Ce1Baa1B8B3Ab0C5AD91A2acD9baCCeda9cCc5CE8A09BCAA0Cc2d0babb9 ; < 7N6FIu4PcbU3fS0c7714P99GWTTUekVpwx0y7bExIqyz2YPt5kqGleCMU8jilO1g > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 0,0000462048510026623 ; -1 ; -0,00025 ; 0,00025 ; -5,4 ; -9,5 ; -2,4 ; -9,3 ; 4,8 ; -5,7 ; -0,67 ; NABBTCMA2194 ; D73AeDBAAcfd5c4d13E3013cEb77E1BADE9A5EEABAFb725e1bd2A086D7c9FAec ; < T3CGjnj1PAw8I3zHHigwU4JmDbLj4huAgEg6X8tdY9g150XLmb8eSQ0kFRZK1ZgM > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 0,0000464156424757591 ; -1 ; -0,00025 ; 0,00025 ; -8,3 ; -9,3 ; 6,6 ; 7,8 ; 6,2 ; 1,9 ; 0,83 ; NABBTCJU2148 ; 05cb83C7Ebda3Ec9a169Afbcbbce4ECA9dFA3db9Dd5ae7EB98A95D5d3B7beA7B ; < 92XzHi6pOmin2n7rDxKYHYs34g94G2n4WCnV2RhQdUnuep46AJuW3TTq30d9R7Zf > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 0,0000466337568548027 ; -1 ; -0,00025 ; 0,00025 ; -3,1 ; 2,5 ; 3,3 ; -9,5 ; 8,5 ; -3,1 ; -0,43 ; NABBTCSE2145 ; cb5B5A4AB3F4a33baEEC7fEF03BEeBCCDACC46CFADb1dFCD19Bfdd7d2dEC51b2 ; < jCak5C37O1Mp1r6Uc7dIG67RiT0a081ULv8qXJvGdQI3tScl49l5SmozApsAf4Sw > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 0,000046867217100057 ; -1 ; -0,00025 ; 0,00025 ; 0,5 ; -6,5 ; -6,5 ; 0,7 ; 0,6 ; 2 ; -0,2 ; NABBTCDE2133 ; b1ecB1aCECfBFEFCaD556F5BE1DEaCf8EECDF3ABBAeEcB97cFFDBe68Db4De2aa ; < z5pbs7djdM6MTWuGDFuE6xPLeCpFJSq8V7lm67rsK722v587B5wq86L4G8Se9xyh > >										24
											
//	  < CALLS ; 6M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 6M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABBTC										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 0,0000440550542260437 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; EE23C8F0AAB2FCCcf514Fe30bE8D5f28bFA9c3bfDccc90FC8e6ABFc6a99fa4b4 ; < S8iBCc8103aaUo44672xd5w60P1I82Kuz5Ih2hZmf50A48N8P6di4n3vmBft11YC > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 0,0000440625918254867 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -8 ; 5,7 ; -9,2 ; -2,8 ; 6,6 ; -0,15 ; NABBTC19JA19 ; 87d0EDf5AFEa1Ae2e9aD5d8badA7DDcfBBEcF0460D2C6dDD78f8D7d7AaCdc91d ; < UjRh45OBMC0s7B9qB4HjYPlX08TQKhsYl369SzY5X456PMH32j8DP8TeR4Uuw8XU > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 0,0000440785527635661 ; -1 ; -0,00025 ; 0,00025 ; 6,8 ; -6,1 ; 3,1 ; -4,6 ; 8,8 ; 9,6 ; -0,27 ; NABBTCMA1992 ; 3de0C8effB82FDA0C82bdA1DaFACbEbc6dFA2CfE0B30dc0aECa1faaEbcCBBEBe ; < cSh8v72P9udt5dZ76W3d8kAMv7Nn3839453YM88TjTp20Jc4MxMiPH0josYI6tpL > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 0,0000441069576404218 ; -1 ; -0,00025 ; 0,00025 ; -3,2 ; -1,3 ; 3,4 ; -9,1 ; 1,3 ; -5 ; 0,12 ; NABBTCMA1979 ; 2Ce1cAaadb2dDDFd3Ac2c60aE3AbDDeBdfAEFCAe0f2DEacCDF2f68AfAaF87FDD ; < 5th40B7ZCgN9bgrtG1K59F0kNe8L8wu6S3ZZ8aOr8LdeNtae1xp2aUU0iRdWgSPF > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 0,0000441404630431867 ; -1 ; -0,00025 ; 0,00025 ; -1,7 ; -0,3 ; -9,1 ; -9,6 ; -9,7 ; -4,4 ; 0,35 ; NABBTCJU1923 ; CBCAB777BCa1fdB8feC8F2b149f2EBd122FeEF6c6A4dFCDA5186d6aA83D4FcEC ; < kcK5plndNfWa9T8h7w1T8RQU3A8Lvnyk94dV52UmZLLKQO2Hb2rXGM7oeN71rMIV > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 0,000044182260006002 ; -1 ; -0,00025 ; 0,00025 ; -1,6 ; -1,3 ; -3,9 ; -0,5 ; -1,8 ; 0,2 ; -0,11 ; NABBTCSE1981 ; de54D71b3ABddDFdd419b6aDAbFAFAAFb44E0c1cC4efAfbDE0A07a2fdd83ECE5 ; < 60w650tN8i4kMZcqS0I8pE58KuP9LTyJ926ld4HMnLQ9334324dp0Z5fBZJgHJ1J > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 0,0000442369673518382 ; -1 ; -0,00025 ; 0,00025 ; -7,9 ; 3,1 ; 7 ; -4,7 ; 9,1 ; -7 ; -0,31 ; NABBTCDE1963 ; 8AADCC6fac34B8A3f392Fa6e2bdFe53BffFB02a5eff7aEfCF28C1CcEFBDf1a9E ; < MuPk57l9t4796WGQ3fw1wyoSSQicn9xgyO3JFN869T0X7Y5cutpb4e5faGC4M3X6 > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 0,0000442991014761032 ; -1 ; -0,00025 ; 0,00025 ; -8,8 ; 3,4 ; -3,3 ; 6,6 ; 0 ; -8 ; -0,56 ; NABBTCJA2010 ; 7be6ad784be3e6832F45Df1a9a1DD7deb4fE5F6b2F87e6fAFCcE80DffCafBFb2 ; < 8m8T7SXEMyMH45qbt4wQXNOnAMzS195xa27GExbOn9Avw31f2vfieO23m73X824H > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 0,0000443709534222985 ; -1 ; -0,00025 ; 0,00025 ; 8,5 ; -8,7 ; -8,8 ; -3,6 ; 5,6 ; -6,6 ; -0,08 ; NABBTCMA2013 ; E99FE2fa5eD9B23EcdCEd6F7be27bD9cF0F45A89F7FFfF90cFDDDfcEAF28C314 ; < F7YggcN7i24PX615se6jZrCKKQYa2n9A0G9C66Qtu10znpn2K0Wa5276db44W6AM > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 0,0000444515938440585 ; -1 ; -0,00025 ; 0,00025 ; -0,7 ; -5,9 ; -4,8 ; -2,1 ; -3,6 ; -4,4 ; 0,23 ; NABBTCMA2017 ; CAaBedaa4d92b75BBb49dA5FB6BfFbEdDCD04a6Ce24c131caE2ABADfd7971ceA ; < 30NY4SvYUm4l7q7IJ577GA79wvpo7C589lx7ztoo89s0M36k8xnmTOXA7Uf1gP9M > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 0,0000445465379912128 ; -1 ; -0,00025 ; 0,00025 ; 5,4 ; -9,6 ; -0,6 ; 3,9 ; -3 ; -7,6 ; 0,28 ; NABBTCJU2027 ; F92B9Eb5533c9d3dF6f3A1aDfCbaB459290EBF0aD2ed0bFaED2cAf38519abAFa ; < p68YlL2YEJf8Rt0i487HC7f2u6aUh97PJy950pr6i4B6j87txZEYavl7ZknAj577 > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 0,0000446506623238387 ; -1 ; -0,00025 ; 0,00025 ; 5,6 ; -8,9 ; -4,2 ; -1,8 ; -7,2 ; -4,5 ; -0,35 ; NABBTCSE2032 ; 2dBA0abC6Ef1aBfeFdB0ca7e8d0eCdCed6a9Fc1df0ad9BfFe4aa1e3dba71e63B ; < L82d4d6grLq0nII9x663vIU84803ottc5Ok8jEfG5LVblp569EnN0JF13qu8R440 > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 0,0000447662182379327 ; -1 ; -0,00025 ; 0,00025 ; -1,2 ; 0,4 ; 3,6 ; 1,5 ; -4,5 ; -9 ; -0,02 ; NABBTCDE2063 ; eBBdBBFBecAf2FBCF8DbD8FfFfFDDa17BFFAB561bBD6Aaaf51fFA2Ffdf889FeB ; < Z950Io3KLgggH3L5Q1ZxD8GT4SQO75WRZ8Qm6QYeZn1LQ5xhG7c21fvwnz4VR1eZ > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 0,0000448885918541723 ; -1 ; -0,00025 ; 0,00025 ; 6,6 ; -2,3 ; 7,7 ; -6,4 ; -7,7 ; 8,3 ; 0,21 ; NABBTCJA2183 ; 0bf6CAB5b1DF5f1aDDEc13dcdFE9CAaD17547e1E16eCE7aC2173CDeC4FDaad0f ; < L9P1Uma4XO1Z06xB1TaK42cE74nV5uvBreJsQgG7lvH8prD2isrj12g39UgKkxyc > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 0,0000450218334890655 ; -1 ; -0,00025 ; 0,00025 ; -8,1 ; -2,5 ; -4,6 ; -7 ; -7,5 ; -8,8 ; 0,66 ; NABBTCMA2137 ; CC5157E8F3C50b86aFdAA5aCC0Df7D5bddEbEEd5A9cea925B7caAF4A9cc621a2 ; < ULOA6G2x7ertNPVC3K2oJJ83XbhN42zUuurglq9iZHCGk0WbjUvRjFM8c1qRNG67 > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 0,0000451594191295597 ; -1 ; -0,00025 ; 0,00025 ; -3,6 ; 6,5 ; 2,7 ; 2 ; 1,9 ; -5,9 ; 0,51 ; NABBTCMA2145 ; 1706ebd6374e8EA9CC5FA22C0dcc4aE5ffb1dc8B85Caa6e35e6E1Ac97530FB64 ; < vEXqioc3dV5J8WDhqpURFKeRU9jB2N8S9MGfxC65gXB0CVZ2f983Y8YW89vL2TpU > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 0,0000453065810974108 ; -1 ; -0,00025 ; 0,00025 ; 2,5 ; 6,8 ; -6,6 ; -8,5 ; 4,1 ; -3,2 ; -0,38 ; NABBTCJU2131 ; 1cb2eCCe33EA5aA505C62FB4336DD48cDAE5d7aCB7b6FfBb2CE5ce4f6dbe1C4A ; < 1cLt6PLEVqUO8j4X1n8HBdkfoZpFgO9C90bWt2JgzH1oOkwCnJI8g4nE9EN68l7B > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 0,0000454640445907012 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; 8,4 ; 7,7 ; -1,6 ; 7 ; 5,6 ; -0,78 ; NABBTCSE2168 ; eEeAeD3e0e8dEcfEAB647edCddeaccACfe1eFc94eabBEefddebcAfDD0eB15fA9 ; < KlZ47582B9Qpu3HpzW0cSQ435P6Ibl1u5An5Wc7DCQu19Xz6Q05T8I14HV71JzD8 > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 0,0000456336865249775 ; -1 ; -0,00025 ; 0,00025 ; -1,7 ; 2,4 ; 5,7 ; 1,5 ; -1,8 ; -1,5 ; 0,47 ; NABBTCDE2130 ; 054bdacC248cD6fEa7B5BAC5Dbc8ec3BCEA9cfaca90DFCCbc1EB269cCbDE52CD ; < 5p9750wg2Ca2cV1W3GSpIl9hTtit25C6Km90LrdML8uR1eSMs8uhtpP1M41wzr52 > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 0,0000458160487126199 ; -1 ; -0,00025 ; 0,00025 ; -4 ; 1,7 ; 6,8 ; -5,8 ; 8,3 ; -8,5 ; 0,97 ; NABBTCJA2187 ; dCBFdEc1BBDbEDbB0D9c5Ecd2cf1FF0A73A8a738cbeB9A3AECD2BDFeeEf8D4ed ; < xN5PBNWYB05KW3vjtxPxhuetNCJh06QU3c7jHs66wmFnx7cn1U29Oju248576ekO > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 0,0000460061916339643 ; -1 ; -0,00025 ; 0,00025 ; 6 ; 3,1 ; 2,5 ; -3,6 ; 3,2 ; -8,8 ; 0,66 ; NABBTCMA2183 ; f3FF9Ce1Baa1B8B3Ab0C5AD91A2acD9baCCeda9cCc5CE8A09BCAA0Cc2d0babb9 ; < 7N6FIu4PcbU3fS0c7714P99GWTTUekVpwx0y7bExIqyz2YPt5kqGleCMU8jilO1g > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 0,0000462048510026623 ; -1 ; -0,00025 ; 0,00025 ; -5,4 ; -9,5 ; -2,4 ; -9,3 ; 4,8 ; -5,7 ; -0,67 ; NABBTCMA2194 ; D73AeDBAAcfd5c4d13E3013cEb77E1BADE9A5EEABAFb725e1bd2A086D7c9FAec ; < T3CGjnj1PAw8I3zHHigwU4JmDbLj4huAgEg6X8tdY9g150XLmb8eSQ0kFRZK1ZgM > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 0,0000464156424757591 ; -1 ; -0,00025 ; 0,00025 ; -8,3 ; -9,3 ; 6,6 ; 7,8 ; 6,2 ; 1,9 ; 0,83 ; NABBTCJU2148 ; 05cb83C7Ebda3Ec9a169Afbcbbce4ECA9dFA3db9Dd5ae7EB98A95D5d3B7beA7B ; < 92XzHi6pOmin2n7rDxKYHYs34g94G2n4WCnV2RhQdUnuep46AJuW3TTq30d9R7Zf > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 0,0000466337568548027 ; -1 ; -0,00025 ; 0,00025 ; -3,1 ; 2,5 ; 3,3 ; -9,5 ; 8,5 ; -3,1 ; -0,43 ; NABBTCSE2145 ; cb5B5A4AB3F4a33baEEC7fEF03BEeBCCDACC46CFADb1dFCD19Bfdd7d2dEC51b2 ; < jCak5C37O1Mp1r6Uc7dIG67RiT0a081ULv8qXJvGdQI3tScl49l5SmozApsAf4Sw > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 0,000046867217100057 ; -1 ; -0,00025 ; 0,00025 ; 0,5 ; -6,5 ; -6,5 ; 0,7 ; 0,6 ; 2 ; -0,2 ; NABBTCDE2133 ; b1ecB1aCECfBFEFCaD556F5BE1DEaCf8EECDF3ABBAeEcB97cFFDBe68Db4De2aa ; < z5pbs7djdM6MTWuGDFuE6xPLeCpFJSq8V7lm67rsK722v587B5wq86L4G8Se9xyh > >										24
											
//	  < CALLS ; 12M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 12M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABBTC										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 0,0000440550542260437 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; EE23C8F0AAB2FCCcf514Fe30bE8D5f28bFA9c3bfDccc90FC8e6ABFc6a99fa4b4 ; < S8iBCc8103aaUo44672xd5w60P1I82Kuz5Ih2hZmf50A48N8P6di4n3vmBft11YC > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 0,0000440625918254867 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -8 ; 5,7 ; -9,2 ; -2,8 ; 6,6 ; -0,15 ; NABBTC19JA19 ; 87d0EDf5AFEa1Ae2e9aD5d8badA7DDcfBBEcF0460D2C6dDD78f8D7d7AaCdc91d ; < UjRh45OBMC0s7B9qB4HjYPlX08TQKhsYl369SzY5X456PMH32j8DP8TeR4Uuw8XU > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 0,0000440785527635661 ; -1 ; -0,00025 ; 0,00025 ; 6,8 ; -6,1 ; 3,1 ; -4,6 ; 8,8 ; 9,6 ; -0,27 ; NABBTCMA1992 ; 3de0C8effB82FDA0C82bdA1DaFACbEbc6dFA2CfE0B30dc0aECa1faaEbcCBBEBe ; < cSh8v72P9udt5dZ76W3d8kAMv7Nn3839453YM88TjTp20Jc4MxMiPH0josYI6tpL > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 0,0000441069576404218 ; -1 ; -0,00025 ; 0,00025 ; -3,2 ; -1,3 ; 3,4 ; -9,1 ; 1,3 ; -5 ; 0,12 ; NABBTCMA1979 ; 2Ce1cAaadb2dDDFd3Ac2c60aE3AbDDeBdfAEFCAe0f2DEacCDF2f68AfAaF87FDD ; < 5th40B7ZCgN9bgrtG1K59F0kNe8L8wu6S3ZZ8aOr8LdeNtae1xp2aUU0iRdWgSPF > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 0,0000441404630431867 ; -1 ; -0,00025 ; 0,00025 ; -1,7 ; -0,3 ; -9,1 ; -9,6 ; -9,7 ; -4,4 ; 0,35 ; NABBTCJU1923 ; CBCAB777BCa1fdB8feC8F2b149f2EBd122FeEF6c6A4dFCDA5186d6aA83D4FcEC ; < kcK5plndNfWa9T8h7w1T8RQU3A8Lvnyk94dV52UmZLLKQO2Hb2rXGM7oeN71rMIV > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 0,000044182260006002 ; -1 ; -0,00025 ; 0,00025 ; -1,6 ; -1,3 ; -3,9 ; -0,5 ; -1,8 ; 0,2 ; -0,11 ; NABBTCSE1981 ; de54D71b3ABddDFdd419b6aDAbFAFAAFb44E0c1cC4efAfbDE0A07a2fdd83ECE5 ; < 60w650tN8i4kMZcqS0I8pE58KuP9LTyJ926ld4HMnLQ9334324dp0Z5fBZJgHJ1J > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 0,0000442369673518382 ; -1 ; -0,00025 ; 0,00025 ; -7,9 ; 3,1 ; 7 ; -4,7 ; 9,1 ; -7 ; -0,31 ; NABBTCDE1963 ; 8AADCC6fac34B8A3f392Fa6e2bdFe53BffFB02a5eff7aEfCF28C1CcEFBDf1a9E ; < MuPk57l9t4796WGQ3fw1wyoSSQicn9xgyO3JFN869T0X7Y5cutpb4e5faGC4M3X6 > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 0,0000442991014761032 ; -1 ; -0,00025 ; 0,00025 ; -8,8 ; 3,4 ; -3,3 ; 6,6 ; 0 ; -8 ; -0,56 ; NABBTCJA2010 ; 7be6ad784be3e6832F45Df1a9a1DD7deb4fE5F6b2F87e6fAFCcE80DffCafBFb2 ; < 8m8T7SXEMyMH45qbt4wQXNOnAMzS195xa27GExbOn9Avw31f2vfieO23m73X824H > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 0,0000443709534222985 ; -1 ; -0,00025 ; 0,00025 ; 8,5 ; -8,7 ; -8,8 ; -3,6 ; 5,6 ; -6,6 ; -0,08 ; NABBTCMA2013 ; E99FE2fa5eD9B23EcdCEd6F7be27bD9cF0F45A89F7FFfF90cFDDDfcEAF28C314 ; < F7YggcN7i24PX615se6jZrCKKQYa2n9A0G9C66Qtu10znpn2K0Wa5276db44W6AM > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 0,0000444515938440585 ; -1 ; -0,00025 ; 0,00025 ; -0,7 ; -5,9 ; -4,8 ; -2,1 ; -3,6 ; -4,4 ; 0,23 ; NABBTCMA2017 ; CAaBedaa4d92b75BBb49dA5FB6BfFbEdDCD04a6Ce24c131caE2ABADfd7971ceA ; < 30NY4SvYUm4l7q7IJ577GA79wvpo7C589lx7ztoo89s0M36k8xnmTOXA7Uf1gP9M > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 0,0000445465379912128 ; -1 ; -0,00025 ; 0,00025 ; 5,4 ; -9,6 ; -0,6 ; 3,9 ; -3 ; -7,6 ; 0,28 ; NABBTCJU2027 ; F92B9Eb5533c9d3dF6f3A1aDfCbaB459290EBF0aD2ed0bFaED2cAf38519abAFa ; < p68YlL2YEJf8Rt0i487HC7f2u6aUh97PJy950pr6i4B6j87txZEYavl7ZknAj577 > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 0,0000446506623238387 ; -1 ; -0,00025 ; 0,00025 ; 5,6 ; -8,9 ; -4,2 ; -1,8 ; -7,2 ; -4,5 ; -0,35 ; NABBTCSE2032 ; 2dBA0abC6Ef1aBfeFdB0ca7e8d0eCdCed6a9Fc1df0ad9BfFe4aa1e3dba71e63B ; < L82d4d6grLq0nII9x663vIU84803ottc5Ok8jEfG5LVblp569EnN0JF13qu8R440 > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 0,0000447662182379327 ; -1 ; -0,00025 ; 0,00025 ; -1,2 ; 0,4 ; 3,6 ; 1,5 ; -4,5 ; -9 ; -0,02 ; NABBTCDE2063 ; eBBdBBFBecAf2FBCF8DbD8FfFfFDDa17BFFAB561bBD6Aaaf51fFA2Ffdf889FeB ; < Z950Io3KLgggH3L5Q1ZxD8GT4SQO75WRZ8Qm6QYeZn1LQ5xhG7c21fvwnz4VR1eZ > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 0,0000448885918541723 ; -1 ; -0,00025 ; 0,00025 ; 6,6 ; -2,3 ; 7,7 ; -6,4 ; -7,7 ; 8,3 ; 0,21 ; NABBTCJA2183 ; 0bf6CAB5b1DF5f1aDDEc13dcdFE9CAaD17547e1E16eCE7aC2173CDeC4FDaad0f ; < L9P1Uma4XO1Z06xB1TaK42cE74nV5uvBreJsQgG7lvH8prD2isrj12g39UgKkxyc > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 0,0000450218334890655 ; -1 ; -0,00025 ; 0,00025 ; -8,1 ; -2,5 ; -4,6 ; -7 ; -7,5 ; -8,8 ; 0,66 ; NABBTCMA2137 ; CC5157E8F3C50b86aFdAA5aCC0Df7D5bddEbEEd5A9cea925B7caAF4A9cc621a2 ; < ULOA6G2x7ertNPVC3K2oJJ83XbhN42zUuurglq9iZHCGk0WbjUvRjFM8c1qRNG67 > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 0,0000451594191295597 ; -1 ; -0,00025 ; 0,00025 ; -3,6 ; 6,5 ; 2,7 ; 2 ; 1,9 ; -5,9 ; 0,51 ; NABBTCMA2145 ; 1706ebd6374e8EA9CC5FA22C0dcc4aE5ffb1dc8B85Caa6e35e6E1Ac97530FB64 ; < vEXqioc3dV5J8WDhqpURFKeRU9jB2N8S9MGfxC65gXB0CVZ2f983Y8YW89vL2TpU > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 0,0000453065810974108 ; -1 ; -0,00025 ; 0,00025 ; 2,5 ; 6,8 ; -6,6 ; -8,5 ; 4,1 ; -3,2 ; -0,38 ; NABBTCJU2131 ; 1cb2eCCe33EA5aA505C62FB4336DD48cDAE5d7aCB7b6FfBb2CE5ce4f6dbe1C4A ; < 1cLt6PLEVqUO8j4X1n8HBdkfoZpFgO9C90bWt2JgzH1oOkwCnJI8g4nE9EN68l7B > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 0,0000454640445907012 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; 8,4 ; 7,7 ; -1,6 ; 7 ; 5,6 ; -0,78 ; NABBTCSE2168 ; eEeAeD3e0e8dEcfEAB647edCddeaccACfe1eFc94eabBEefddebcAfDD0eB15fA9 ; < KlZ47582B9Qpu3HpzW0cSQ435P6Ibl1u5An5Wc7DCQu19Xz6Q05T8I14HV71JzD8 > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 0,0000456336865249775 ; -1 ; -0,00025 ; 0,00025 ; -1,7 ; 2,4 ; 5,7 ; 1,5 ; -1,8 ; -1,5 ; 0,47 ; NABBTCDE2130 ; 054bdacC248cD6fEa7B5BAC5Dbc8ec3BCEA9cfaca90DFCCbc1EB269cCbDE52CD ; < 5p9750wg2Ca2cV1W3GSpIl9hTtit25C6Km90LrdML8uR1eSMs8uhtpP1M41wzr52 > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 0,0000458160487126199 ; -1 ; -0,00025 ; 0,00025 ; -4 ; 1,7 ; 6,8 ; -5,8 ; 8,3 ; -8,5 ; 0,97 ; NABBTCJA2187 ; dCBFdEc1BBDbEDbB0D9c5Ecd2cf1FF0A73A8a738cbeB9A3AECD2BDFeeEf8D4ed ; < xN5PBNWYB05KW3vjtxPxhuetNCJh06QU3c7jHs66wmFnx7cn1U29Oju248576ekO > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 0,0000460061916339643 ; -1 ; -0,00025 ; 0,00025 ; 6 ; 3,1 ; 2,5 ; -3,6 ; 3,2 ; -8,8 ; 0,66 ; NABBTCMA2183 ; f3FF9Ce1Baa1B8B3Ab0C5AD91A2acD9baCCeda9cCc5CE8A09BCAA0Cc2d0babb9 ; < 7N6FIu4PcbU3fS0c7714P99GWTTUekVpwx0y7bExIqyz2YPt5kqGleCMU8jilO1g > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 0,0000462048510026623 ; -1 ; -0,00025 ; 0,00025 ; -5,4 ; -9,5 ; -2,4 ; -9,3 ; 4,8 ; -5,7 ; -0,67 ; NABBTCMA2194 ; D73AeDBAAcfd5c4d13E3013cEb77E1BADE9A5EEABAFb725e1bd2A086D7c9FAec ; < T3CGjnj1PAw8I3zHHigwU4JmDbLj4huAgEg6X8tdY9g150XLmb8eSQ0kFRZK1ZgM > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 0,0000464156424757591 ; -1 ; -0,00025 ; 0,00025 ; -8,3 ; -9,3 ; 6,6 ; 7,8 ; 6,2 ; 1,9 ; 0,83 ; NABBTCJU2148 ; 05cb83C7Ebda3Ec9a169Afbcbbce4ECA9dFA3db9Dd5ae7EB98A95D5d3B7beA7B ; < 92XzHi6pOmin2n7rDxKYHYs34g94G2n4WCnV2RhQdUnuep46AJuW3TTq30d9R7Zf > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 0,0000466337568548027 ; -1 ; -0,00025 ; 0,00025 ; -3,1 ; 2,5 ; 3,3 ; -9,5 ; 8,5 ; -3,1 ; -0,43 ; NABBTCSE2145 ; cb5B5A4AB3F4a33baEEC7fEF03BEeBCCDACC46CFADb1dFCD19Bfdd7d2dEC51b2 ; < jCak5C37O1Mp1r6Uc7dIG67RiT0a081ULv8qXJvGdQI3tScl49l5SmozApsAf4Sw > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 0,000046867217100057 ; -1 ; -0,00025 ; 0,00025 ; 0,5 ; -6,5 ; -6,5 ; 0,7 ; 0,6 ; 2 ; -0,2 ; NABBTCDE2133 ; b1ecB1aCECfBFEFCaD556F5BE1DEaCf8EECDF3ABBAeEcB97cFFDBe68Db4De2aa ; < z5pbs7djdM6MTWuGDFuE6xPLeCpFJSq8V7lm67rsK722v587B5wq86L4G8Se9xyh > >										24
											
//	  < CALLS ; 24M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 24M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
											
//	NABBTC										
											
//	  < # ; REF ; Month ; Optionchain ; Chart ; Last ; T(-1) ; Change ; BAS_1 ; BAS_2 ; Prior. Settle ; Open ; High ; Low ; Volume ; Hi / Lo ; Updated (s) ; Code ; @ eth_hex ; @ btc_882 >										
											
//	        < 0 ; T0 ; - ; - ; - ; 0 ; 0,0000440550542260437 ; -1 ; - ; - ; - ; - ; - ; - ; - ; - ; - ; - ; EE23C8F0AAB2FCCcf514Fe30bE8D5f28bFA9c3bfDccc90FC8e6ABFc6a99fa4b4 ; < S8iBCc8103aaUo44672xd5w60P1I82Kuz5Ih2hZmf50A48N8P6di4n3vmBft11YC > >										0
//	        < 1 ; 0M ; JAN 2019 ; opt. ; - ; 0 ; 0,0000440625918254867 ; -1 ; -0,00025 ; 0,00025 ; -2,2 ; -8 ; 5,7 ; -9,2 ; -2,8 ; 6,6 ; -0,15 ; NABBTC19JA19 ; 87d0EDf5AFEa1Ae2e9aD5d8badA7DDcfBBEcF0460D2C6dDD78f8D7d7AaCdc91d ; < UjRh45OBMC0s7B9qB4HjYPlX08TQKhsYl369SzY5X456PMH32j8DP8TeR4Uuw8XU > >										1
//	        < 2 ; 2M ; MAR 2019 ; opt. ; - ; 0 ; 0,0000440785527635661 ; -1 ; -0,00025 ; 0,00025 ; 6,8 ; -6,1 ; 3,1 ; -4,6 ; 8,8 ; 9,6 ; -0,27 ; NABBTCMA1992 ; 3de0C8effB82FDA0C82bdA1DaFACbEbc6dFA2CfE0B30dc0aECa1faaEbcCBBEBe ; < cSh8v72P9udt5dZ76W3d8kAMv7Nn3839453YM88TjTp20Jc4MxMiPH0josYI6tpL > >										2
//	        < 3 ; 4M ; MAY 2019 ; opt. ; - ; 0 ; 0,0000441069576404218 ; -1 ; -0,00025 ; 0,00025 ; -3,2 ; -1,3 ; 3,4 ; -9,1 ; 1,3 ; -5 ; 0,12 ; NABBTCMA1979 ; 2Ce1cAaadb2dDDFd3Ac2c60aE3AbDDeBdfAEFCAe0f2DEacCDF2f68AfAaF87FDD ; < 5th40B7ZCgN9bgrtG1K59F0kNe8L8wu6S3ZZ8aOr8LdeNtae1xp2aUU0iRdWgSPF > >										3
//	        < 4 ; 6M ; JUL 2019 ; opt. ; - ; 0 ; 0,0000441404630431867 ; -1 ; -0,00025 ; 0,00025 ; -1,7 ; -0,3 ; -9,1 ; -9,6 ; -9,7 ; -4,4 ; 0,35 ; NABBTCJU1923 ; CBCAB777BCa1fdB8feC8F2b149f2EBd122FeEF6c6A4dFCDA5186d6aA83D4FcEC ; < kcK5plndNfWa9T8h7w1T8RQU3A8Lvnyk94dV52UmZLLKQO2Hb2rXGM7oeN71rMIV > >										4
//	        < 5 ; 8M ; SEP 2019 ; opt. ; - ; 0 ; 0,000044182260006002 ; -1 ; -0,00025 ; 0,00025 ; -1,6 ; -1,3 ; -3,9 ; -0,5 ; -1,8 ; 0,2 ; -0,11 ; NABBTCSE1981 ; de54D71b3ABddDFdd419b6aDAbFAFAAFb44E0c1cC4efAfbDE0A07a2fdd83ECE5 ; < 60w650tN8i4kMZcqS0I8pE58KuP9LTyJ926ld4HMnLQ9334324dp0Z5fBZJgHJ1J > >										5
//	        < 6 ; 11M ; DEC 2019 ; opt. ; - ; 0 ; 0,0000442369673518382 ; -1 ; -0,00025 ; 0,00025 ; -7,9 ; 3,1 ; 7 ; -4,7 ; 9,1 ; -7 ; -0,31 ; NABBTCDE1963 ; 8AADCC6fac34B8A3f392Fa6e2bdFe53BffFB02a5eff7aEfCF28C1CcEFBDf1a9E ; < MuPk57l9t4796WGQ3fw1wyoSSQicn9xgyO3JFN869T0X7Y5cutpb4e5faGC4M3X6 > >										6
//	        < 7 ; 12M ; JAN 2020 ; opt. ; - ; 0 ; 0,0000442991014761032 ; -1 ; -0,00025 ; 0,00025 ; -8,8 ; 3,4 ; -3,3 ; 6,6 ; 0 ; -8 ; -0,56 ; NABBTCJA2010 ; 7be6ad784be3e6832F45Df1a9a1DD7deb4fE5F6b2F87e6fAFCcE80DffCafBFb2 ; < 8m8T7SXEMyMH45qbt4wQXNOnAMzS195xa27GExbOn9Avw31f2vfieO23m73X824H > >										7
//	        < 8 ; 14M ; MAR 2020 ; opt. ; - ; 0 ; 0,0000443709534222985 ; -1 ; -0,00025 ; 0,00025 ; 8,5 ; -8,7 ; -8,8 ; -3,6 ; 5,6 ; -6,6 ; -0,08 ; NABBTCMA2013 ; E99FE2fa5eD9B23EcdCEd6F7be27bD9cF0F45A89F7FFfF90cFDDDfcEAF28C314 ; < F7YggcN7i24PX615se6jZrCKKQYa2n9A0G9C66Qtu10znpn2K0Wa5276db44W6AM > >										8
//	        < 9 ; 16M ; MAY 2020 ; opt. ; - ; 0 ; 0,0000444515938440585 ; -1 ; -0,00025 ; 0,00025 ; -0,7 ; -5,9 ; -4,8 ; -2,1 ; -3,6 ; -4,4 ; 0,23 ; NABBTCMA2017 ; CAaBedaa4d92b75BBb49dA5FB6BfFbEdDCD04a6Ce24c131caE2ABADfd7971ceA ; < 30NY4SvYUm4l7q7IJ577GA79wvpo7C589lx7ztoo89s0M36k8xnmTOXA7Uf1gP9M > >										9
//	        < 10 ; 18M ; JUL 2020 ; opt. ; - ; 0 ; 0,0000445465379912128 ; -1 ; -0,00025 ; 0,00025 ; 5,4 ; -9,6 ; -0,6 ; 3,9 ; -3 ; -7,6 ; 0,28 ; NABBTCJU2027 ; F92B9Eb5533c9d3dF6f3A1aDfCbaB459290EBF0aD2ed0bFaED2cAf38519abAFa ; < p68YlL2YEJf8Rt0i487HC7f2u6aUh97PJy950pr6i4B6j87txZEYavl7ZknAj577 > >										10
//	        < 11 ; 20M ; SEP 2020 ; opt. ; - ; 0 ; 0,0000446506623238387 ; -1 ; -0,00025 ; 0,00025 ; 5,6 ; -8,9 ; -4,2 ; -1,8 ; -7,2 ; -4,5 ; -0,35 ; NABBTCSE2032 ; 2dBA0abC6Ef1aBfeFdB0ca7e8d0eCdCed6a9Fc1df0ad9BfFe4aa1e3dba71e63B ; < L82d4d6grLq0nII9x663vIU84803ottc5Ok8jEfG5LVblp569EnN0JF13qu8R440 > >										11
//	        < 12 ; 23M ; DEC 2020 ; opt. ; - ; 0 ; 0,0000447662182379327 ; -1 ; -0,00025 ; 0,00025 ; -1,2 ; 0,4 ; 3,6 ; 1,5 ; -4,5 ; -9 ; -0,02 ; NABBTCDE2063 ; eBBdBBFBecAf2FBCF8DbD8FfFfFDDa17BFFAB561bBD6Aaaf51fFA2Ffdf889FeB ; < Z950Io3KLgggH3L5Q1ZxD8GT4SQO75WRZ8Qm6QYeZn1LQ5xhG7c21fvwnz4VR1eZ > >										12
//	        < 13 ; 24M ; JAN 2021 ; opt. ; - ; 0 ; 0,0000448885918541723 ; -1 ; -0,00025 ; 0,00025 ; 6,6 ; -2,3 ; 7,7 ; -6,4 ; -7,7 ; 8,3 ; 0,21 ; NABBTCJA2183 ; 0bf6CAB5b1DF5f1aDDEc13dcdFE9CAaD17547e1E16eCE7aC2173CDeC4FDaad0f ; < L9P1Uma4XO1Z06xB1TaK42cE74nV5uvBreJsQgG7lvH8prD2isrj12g39UgKkxyc > >										13
//	        < 14 ; 26M ; MAR 2021 ; opt. ; - ; 0 ; 0,0000450218334890655 ; -1 ; -0,00025 ; 0,00025 ; -8,1 ; -2,5 ; -4,6 ; -7 ; -7,5 ; -8,8 ; 0,66 ; NABBTCMA2137 ; CC5157E8F3C50b86aFdAA5aCC0Df7D5bddEbEEd5A9cea925B7caAF4A9cc621a2 ; < ULOA6G2x7ertNPVC3K2oJJ83XbhN42zUuurglq9iZHCGk0WbjUvRjFM8c1qRNG67 > >										14
//	        < 15 ; 28M ; MAY 2021 ; opt. ; - ; 0 ; 0,0000451594191295597 ; -1 ; -0,00025 ; 0,00025 ; -3,6 ; 6,5 ; 2,7 ; 2 ; 1,9 ; -5,9 ; 0,51 ; NABBTCMA2145 ; 1706ebd6374e8EA9CC5FA22C0dcc4aE5ffb1dc8B85Caa6e35e6E1Ac97530FB64 ; < vEXqioc3dV5J8WDhqpURFKeRU9jB2N8S9MGfxC65gXB0CVZ2f983Y8YW89vL2TpU > >										15
//	        < 16 ; 30M ; JUL 2021 ; opt. ; - ; 0 ; 0,0000453065810974108 ; -1 ; -0,00025 ; 0,00025 ; 2,5 ; 6,8 ; -6,6 ; -8,5 ; 4,1 ; -3,2 ; -0,38 ; NABBTCJU2131 ; 1cb2eCCe33EA5aA505C62FB4336DD48cDAE5d7aCB7b6FfBb2CE5ce4f6dbe1C4A ; < 1cLt6PLEVqUO8j4X1n8HBdkfoZpFgO9C90bWt2JgzH1oOkwCnJI8g4nE9EN68l7B > >										16
//	        < 17 ; 32M ; SEP 2021 ; opt. ; - ; 0 ; 0,0000454640445907012 ; -1 ; -0,00025 ; 0,00025 ; 4,9 ; 8,4 ; 7,7 ; -1,6 ; 7 ; 5,6 ; -0,78 ; NABBTCSE2168 ; eEeAeD3e0e8dEcfEAB647edCddeaccACfe1eFc94eabBEefddebcAfDD0eB15fA9 ; < KlZ47582B9Qpu3HpzW0cSQ435P6Ibl1u5An5Wc7DCQu19Xz6Q05T8I14HV71JzD8 > >										17
//	        < 18 ; 35M ; DEC 2021 ; opt. ; - ; 0 ; 0,0000456336865249775 ; -1 ; -0,00025 ; 0,00025 ; -1,7 ; 2,4 ; 5,7 ; 1,5 ; -1,8 ; -1,5 ; 0,47 ; NABBTCDE2130 ; 054bdacC248cD6fEa7B5BAC5Dbc8ec3BCEA9cfaca90DFCCbc1EB269cCbDE52CD ; < 5p9750wg2Ca2cV1W3GSpIl9hTtit25C6Km90LrdML8uR1eSMs8uhtpP1M41wzr52 > >										18
//	        < 19 ; 36M ; JAN 2021 ; opt. ; - ; 0 ; 0,0000458160487126199 ; -1 ; -0,00025 ; 0,00025 ; -4 ; 1,7 ; 6,8 ; -5,8 ; 8,3 ; -8,5 ; 0,97 ; NABBTCJA2187 ; dCBFdEc1BBDbEDbB0D9c5Ecd2cf1FF0A73A8a738cbeB9A3AECD2BDFeeEf8D4ed ; < xN5PBNWYB05KW3vjtxPxhuetNCJh06QU3c7jHs66wmFnx7cn1U29Oju248576ekO > >										19
//	        < 20 ; 38M ; MAR 2021 ; opt. ; - ; 0 ; 0,0000460061916339643 ; -1 ; -0,00025 ; 0,00025 ; 6 ; 3,1 ; 2,5 ; -3,6 ; 3,2 ; -8,8 ; 0,66 ; NABBTCMA2183 ; f3FF9Ce1Baa1B8B3Ab0C5AD91A2acD9baCCeda9cCc5CE8A09BCAA0Cc2d0babb9 ; < 7N6FIu4PcbU3fS0c7714P99GWTTUekVpwx0y7bExIqyz2YPt5kqGleCMU8jilO1g > >										20
//	        < 21 ; 40M ; MAY 2021 ; opt. ; - ; 0 ; 0,0000462048510026623 ; -1 ; -0,00025 ; 0,00025 ; -5,4 ; -9,5 ; -2,4 ; -9,3 ; 4,8 ; -5,7 ; -0,67 ; NABBTCMA2194 ; D73AeDBAAcfd5c4d13E3013cEb77E1BADE9A5EEABAFb725e1bd2A086D7c9FAec ; < T3CGjnj1PAw8I3zHHigwU4JmDbLj4huAgEg6X8tdY9g150XLmb8eSQ0kFRZK1ZgM > >										21
//	        < 22 ; 42M ; JUL 2021 ; opt. ; - ; 0 ; 0,0000464156424757591 ; -1 ; -0,00025 ; 0,00025 ; -8,3 ; -9,3 ; 6,6 ; 7,8 ; 6,2 ; 1,9 ; 0,83 ; NABBTCJU2148 ; 05cb83C7Ebda3Ec9a169Afbcbbce4ECA9dFA3db9Dd5ae7EB98A95D5d3B7beA7B ; < 92XzHi6pOmin2n7rDxKYHYs34g94G2n4WCnV2RhQdUnuep46AJuW3TTq30d9R7Zf > >										22
//	        < 23 ; 44M ; SEP 2021 ; opt. ; - ; 0 ; 0,0000466337568548027 ; -1 ; -0,00025 ; 0,00025 ; -3,1 ; 2,5 ; 3,3 ; -9,5 ; 8,5 ; -3,1 ; -0,43 ; NABBTCSE2145 ; cb5B5A4AB3F4a33baEEC7fEF03BEeBCCDACC46CFADb1dFCD19Bfdd7d2dEC51b2 ; < jCak5C37O1Mp1r6Uc7dIG67RiT0a081ULv8qXJvGdQI3tScl49l5SmozApsAf4Sw > >										23
//	        < 24 ; 47M ; DEC 2021 ; opt. ; - ; 0 ; 0,000046867217100057 ; -1 ; -0,00025 ; 0,00025 ; 0,5 ; -6,5 ; -6,5 ; 0,7 ; 0,6 ; 2 ; -0,2 ; NABBTCDE2133 ; b1ecB1aCECfBFEFCaD556F5BE1DEaCf8EECDF3ABBAeEcB97cFFDBe68Db4De2aa ; < z5pbs7djdM6MTWuGDFuE6xPLeCpFJSq8V7lm67rsK722v587B5wq86L4G8Se9xyh > >										24
											
//	  < CALLS ; 36M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
//											
//	  < PUTS ; 36M ; Strike ; Symbol ; Last ; T(-1) ; Change ; Volume ; BAS_1 ; BAS_2 ; o.i. @ eth_hex ; @ btc_882 >										
//											
//	#DIV/0 !										1
//	#DIV/0 !										2
//	#DIV/0 !										3
//	#DIV/0 !										4
//	#DIV/0 !										5
//	#DIV/0 !										6
//	#DIV/0 !										7
//	#DIV/0 !										8
//	#DIV/0 !										9
//	#DIV/0 !										10
//	#DIV/0 !										11
//	#DIV/0 !										12
//	#DIV/0 !										13
//	#DIV/0 !										14
//	#DIV/0 !										15
//	#DIV/0 !										16
//	#DIV/0 !										17
//	#DIV/0 !										18
//	#DIV/0 !										19
//	#DIV/0 !										20
//	#DIV/0 !										21
											
											
											
											
	}