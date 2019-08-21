pragma solidity ^0.4.6;

contract WinMatrix
{
   
   address developer; 

   enum BetTypes{number0, number1,number2,number3,number4,number5,number6,number7,number8,number9,
   number10,number11,number12,number13,number14,number15,number16,number17,number18,number19,number20,number21,
   number22,number23,number24,number25,number26,number27,number28,number29,number30,number31,number32,number33,
   number34,number35,number36, red, black, odd, even, dozen1,dozen2,dozen3, column1,column2,column3, low,high,
   pair_01, pair_02, pair_03, pair_12, pair_23, pair_36, pair_25, pair_14, pair_45, pair_56, pair_69, pair_58, pair_47,
   pair_78, pair_89, pair_912, pair_811, pair_710, pair_1011, pair_1112, pair_1215, pair_1518, pair_1617, pair_1718, pair_1720,
   pair_1619, pair_1922, pair_2023, pair_2124, pair_2223, pair_2324, pair_2528, pair_2629, pair_2730, pair_2829, pair_2930, pair_1114,
   pair_1013, pair_1314, pair_1415, pair_1316, pair_1417, pair_1821, pair_1920, pair_2021, pair_2225, pair_2326, pair_2427, pair_2526,
   pair_2627, pair_2831, pair_2932, pair_3033, pair_3132, pair_3233, pair_3134, pair_3235, pair_3336, pair_3435, pair_3536, corner_0_1_2_3,
   corner_1_2_5_4, corner_2_3_6_5, corner_4_5_8_7, corner_5_6_9_8, corner_7_8_11_10, corner_8_9_12_11, corner_10_11_14_13, corner_11_12_15_14,
   corner_13_14_17_16, corner_14_15_18_17, corner_16_17_20_19, corner_17_18_21_20, corner_19_20_23_22, corner_20_21_24_23, corner_22_23_26_25,
   corner_23_24_27_26, corner_25_26_29_28, corner_26_27_30_29, corner_28_29_32_31, corner_29_30_33_32, corner_31_32_35_34, corner_32_33_36_35,
   three_0_2_3, three_0_1_2, three_1_2_3, three_4_5_6, three_7_8_9, three_10_11_12, three_13_14_15, three_16_17_18, three_19_20_21, three_22_23_24,
   three_25_26_27, three_28_29_30, three_31_32_33, three_34_35_36, six_1_2_3_4_5_6, six_4_5_6_7_8_9, six_7_8_9_10_11_12, six_10_11_12_13_14_15,
   six_13_14_15_16_17_18, six_16_17_18_19_20_21, six_19_20_21_22_23_24, six_22_23_24_25_26_27, six_25_26_27_28_29_30, six_28_29_30_31_32_33,
   six_31_32_33_34_35_36}
   

   uint16 constant maxTypeBets = 157;
   uint16 private betsProcessed;
   mapping (uint16 => uint8) private winMatrix;
      
   function WinMatrix() 
   {
      developer = msg.sender;
      betsProcessed   = 0;       
   }

   function getBetsProcessed() external constant returns (uint16)
   {
        return betsProcessed;
   }

   function deleteContract() onlyDeveloper  
   {
        suicide(msg.sender);
   }

   function generateWinMatrix(uint16 count) onlyDeveloper
   {      
      if (betsProcessed == maxTypeBets) throw;
      var max = betsProcessed + count;
      if (max > maxTypeBets) max = maxTypeBets;

      for(uint16 bet=betsProcessed; bet<max; bet++)
      {   
        BetTypes betType = BetTypes(bet);                   
        for(uint8 wheelResult=0; wheelResult<=36; wheelResult++)
        {
          uint16 index = getIndex(bet, wheelResult);
          
          if (bet <= 36) // bet on number
          {
              if (bet == wheelResult) winMatrix[index] = 35;
          }
          else if (betType == BetTypes.red)
          {
            if ((wheelResult == 1 ||
                wheelResult == 3  ||
                wheelResult == 5  ||
                wheelResult == 7  ||
                wheelResult == 9  ||
                wheelResult == 12 ||
                wheelResult == 14 ||
                wheelResult == 16 ||
                wheelResult == 18 ||
                wheelResult == 19 ||
                wheelResult == 21 ||
                wheelResult == 23 ||
                wheelResult == 25 ||
                wheelResult == 27 ||
                wheelResult == 30 ||
                wheelResult == 32 ||
                wheelResult == 34 ||
                wheelResult == 36) && wheelResult != 0) winMatrix[index] = 1; 
                
          }
          else if (betType == BetTypes.black)
          {
              if (!(wheelResult == 1 ||
                wheelResult == 3  ||
                wheelResult == 5  ||
                wheelResult == 7  ||
                wheelResult == 9  ||
                wheelResult == 12 ||
                wheelResult == 14 ||
                wheelResult == 16 ||
                wheelResult == 18 ||
                wheelResult == 19 ||
                wheelResult == 21 ||
                wheelResult == 23 ||
                wheelResult == 25 ||
                wheelResult == 27 ||
                wheelResult == 30 ||
                wheelResult == 32 ||
                wheelResult == 34 ||
                wheelResult == 36) && wheelResult != 0) winMatrix[index] = 1;
          }
          else if (betType == BetTypes.odd)
          {
            if (wheelResult % 2 != 0 && wheelResult != 0) winMatrix[index] = 1;  
          }
          else if (betType == BetTypes.even)
          {
            if (wheelResult % 2 == 0 && wheelResult != 0) winMatrix[index] = 1;     
          }
          else if (betType == BetTypes.low)
          {
              if (wheelResult < 19 && wheelResult != 0) winMatrix[index] = 1; 
          }
          else if (betType == BetTypes.high)
          {
            if (wheelResult > 18 && wheelResult != 0) winMatrix[index] = 1;     
          }
          else if (betType == BetTypes.dozen1)
          {
            if (wheelResult <13 && wheelResult != 0) winMatrix[index] = 2;
          }
          else if (betType == BetTypes.dozen2)
          {
            if (wheelResult >13 && wheelResult < 25 && wheelResult != 0) winMatrix[index] = 2;
          }              
          else if (betType == BetTypes.dozen3)
          {
              if (wheelResult >24 && wheelResult != 0) winMatrix[index] = 2;
          }   
          else if (betType == BetTypes.column1)
          {
              if (wheelResult%3 == 1 && wheelResult != 0) winMatrix[index] = 2;
          }
          else if (betType == BetTypes.column2)
          {
            if (wheelResult%3 == 2 && wheelResult != 0) winMatrix[index] = 2;    
          }              
          else if (betType == BetTypes.column3)
          {
              if (wheelResult%3 == 0 && wheelResult != 0) winMatrix[index] = 2;
          }
          else if (betType == BetTypes.pair_01)
          {
              if (wheelResult == 0 || wheelResult == 1) winMatrix[index] = 17;
          }               
          else if (betType == BetTypes.pair_02)
          {
              if (wheelResult == 0 || wheelResult == 2) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_03)
          {
              if (wheelResult == 0 || wheelResult == 3) winMatrix[index] = 17;
          }               
          else if (betType == BetTypes.pair_03)
          {
              if (wheelResult == 0 || wheelResult == 3) winMatrix[index] = 17;
          }          
          else if (betType == BetTypes.pair_12)
          {
              if (wheelResult == 1 || wheelResult == 2) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_23)
          {
              if (wheelResult == 2 || wheelResult == 3) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_36)
          {
              if (wheelResult == 3 || wheelResult == 6) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_25)
          {
              if (wheelResult == 2 || wheelResult == 5) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_14)
          {
              if (wheelResult == 1 || wheelResult == 4) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_45)
          {
              if (wheelResult == 4 || wheelResult == 5) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_56)
          {
              if (wheelResult == 5 || wheelResult == 6) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_69)
          {
              if (wheelResult == 6 || wheelResult == 9) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_58)
          {
              if (wheelResult == 5 || wheelResult == 8) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_47)
          {
              if (wheelResult == 4 || wheelResult == 7) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_78)
          {
              if (wheelResult == 7 || wheelResult == 8) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_89)
          {
              if (wheelResult == 8 || wheelResult == 9) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_912)
          {
              if (wheelResult == 9 || wheelResult == 12) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_811)
          {
              if (wheelResult == 8 || wheelResult == 11) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_710)
          {
              if (wheelResult == 7 || wheelResult == 10) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_1011)
          {
              if (wheelResult == 10 || wheelResult == 11) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_1112)
          {
              if (wheelResult == 12 || wheelResult == 12) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_1215)
          {
              if (wheelResult == 12 || wheelResult == 15) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_1518)
          {
              if (wheelResult == 15 || wheelResult == 18) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_1617)
          {
              if (wheelResult == 16 || wheelResult == 17) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_1718)
          {
              if (wheelResult == 17 || wheelResult == 18) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_1720)
          {
              if (wheelResult == 17 || wheelResult == 20) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_1619)
          {
              if (wheelResult == 16 || wheelResult == 19) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_1922)
          {
              if (wheelResult == 19 || wheelResult == 22) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_2023)
          {
              if (wheelResult == 20 || wheelResult == 23) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_2124)
          {
              if (wheelResult == 21 || wheelResult == 24) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_2223)
          {
              if (wheelResult == 22 || wheelResult == 23) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_2324)
          {
              if (wheelResult == 23 || wheelResult == 24) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_2528)
          {
              if (wheelResult == 25 || wheelResult == 28) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_2629)
          {
              if (wheelResult == 26 || wheelResult == 29) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_2730)
          {
              if (wheelResult == 27 || wheelResult == 30) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_2829)
          {
              if (wheelResult == 28 || wheelResult == 29) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_2930)
          {
              if (wheelResult == 29 || wheelResult == 30) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_1114)
          {
              if (wheelResult == 11 || wheelResult == 14) winMatrix[index] = 17;
          } 
          else if (betType == BetTypes.pair_1013)
          {
              if (wheelResult == 10 || wheelResult == 13) winMatrix[index] = 17;
          } 
          else if (betType == BetTypes.pair_1314)
          {
              if (wheelResult == 13 || wheelResult == 14) winMatrix[index] = 17;
          } 
          else if (betType == BetTypes.pair_1415)
          {
              if (wheelResult == 14 || wheelResult == 15) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_1316)
          {
              if (wheelResult == 13 || wheelResult == 16) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_1417)
          {
              if (wheelResult == 14 || wheelResult == 17) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_1821)
          {
              if (wheelResult == 18 || wheelResult == 21) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_1920)
          {
              if (wheelResult == 19 || wheelResult == 20) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_2021)
          {
              if (wheelResult == 20 || wheelResult == 21) winMatrix[index] = 17;
          } 
          else if (betType == BetTypes.pair_2225)
          {
              if (wheelResult == 22 || wheelResult == 25) winMatrix[index] = 17;
          } 
          else if (betType == BetTypes.pair_2326)
          {
              if (wheelResult == 23 || wheelResult == 26) winMatrix[index] = 17;
          } 
          else if (betType == BetTypes.pair_2427)
          {
              if (wheelResult == 24 || wheelResult == 27) winMatrix[index] = 17;
          } 
          else if (betType == BetTypes.pair_2526)
          {
              if (wheelResult == 25 || wheelResult == 26) winMatrix[index] = 17;
          } 
          else if (betType == BetTypes.pair_2627)
          {
              if (wheelResult == 26 || wheelResult == 27) winMatrix[index] = 17;
          } 
          else if (betType == BetTypes.pair_2831)
          {
              if (wheelResult == 28 || wheelResult == 31) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_2932)
          {
              if (wheelResult == 29 || wheelResult == 32) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_3033)
          {
              if (wheelResult == 30 || wheelResult == 33) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_3132)
          {
              if (wheelResult == 31 || wheelResult == 32) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_3233)
          {
              if (wheelResult == 32 || wheelResult == 33) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_3134)
          {
              if (wheelResult == 31 || wheelResult == 34) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_3235)
          {
              if (wheelResult == 32 || wheelResult == 35) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_3336)
          {
              if (wheelResult == 33 || wheelResult == 36) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_3435)
          {
              if (wheelResult == 34 || wheelResult == 35) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.pair_3536)
          {
              if (wheelResult == 35 || wheelResult == 36) winMatrix[index] = 17;
          }
          else if (betType == BetTypes.corner_0_1_2_3)
          {
            if (wheelResult == 0 || wheelResult == 1  || wheelResult == 2  || wheelResult == 3) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_1_2_5_4)
          {
            if (wheelResult == 1 || wheelResult == 2  || wheelResult == 5  || wheelResult == 4) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_2_3_6_5)
          {
            if (wheelResult == 2 || wheelResult == 3  || wheelResult == 6  || wheelResult == 5) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_4_5_8_7)
          {
            if (wheelResult == 4 || wheelResult == 5  || wheelResult == 8  || wheelResult == 7) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_5_6_9_8)
          {
            if (wheelResult == 5 || wheelResult == 6  || wheelResult == 9  || wheelResult == 8) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_7_8_11_10)
          {
            if (wheelResult == 7 || wheelResult == 8  || wheelResult == 11  || wheelResult == 10) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_8_9_12_11)
          {
            if (wheelResult == 8 || wheelResult == 9  || wheelResult == 12  || wheelResult == 11) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_10_11_14_13)
          {
            if (wheelResult == 10 || wheelResult == 11  || wheelResult == 14  || wheelResult == 13) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_11_12_15_14)
          {
            if (wheelResult == 11 || wheelResult == 12  || wheelResult == 15  || wheelResult == 14) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_13_14_17_16)
          {
            if (wheelResult == 13 || wheelResult == 14  || wheelResult == 17  || wheelResult == 16) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_14_15_18_17)
          {
            if (wheelResult == 14 || wheelResult == 15  || wheelResult == 18  || wheelResult == 17) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_16_17_20_19)
          {
            if (wheelResult == 16 || wheelResult == 17  || wheelResult == 20  || wheelResult == 19) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_17_18_21_20)
          {
            if (wheelResult == 17 || wheelResult == 18  || wheelResult == 21  || wheelResult == 20) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_19_20_23_22)
          {
            if (wheelResult == 19 || wheelResult == 20  || wheelResult == 23  || wheelResult == 22) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_20_21_24_23)
          {
            if (wheelResult == 20 || wheelResult == 21  || wheelResult == 24  || wheelResult == 23) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_22_23_26_25)
          {
            if (wheelResult == 22 || wheelResult == 23  || wheelResult == 26  || wheelResult == 25) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_23_24_27_26)
          {
            if (wheelResult == 23 || wheelResult == 24  || wheelResult == 27  || wheelResult == 26) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_25_26_29_28)
          {
            if (wheelResult == 25 || wheelResult == 26  || wheelResult == 29  || wheelResult == 28) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_26_27_30_29)
          {
            if (wheelResult == 26 || wheelResult == 27  || wheelResult == 30  || wheelResult == 29) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_28_29_32_31)
          {
            if (wheelResult == 28 || wheelResult == 29  || wheelResult == 32  || wheelResult == 31) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_29_30_33_32)
          {
            if (wheelResult == 29 || wheelResult == 30  || wheelResult == 33  || wheelResult == 32) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_31_32_35_34)
          {
            if (wheelResult == 31 || wheelResult == 32  || wheelResult == 35  || wheelResult == 34) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.corner_32_33_36_35)
          {
            if (wheelResult == 32 || wheelResult == 33  || wheelResult == 36  || wheelResult == 35) winMatrix[index] = 8;
          }
          else if (betType == BetTypes.three_0_2_3)
          {
            if (wheelResult == 0 || wheelResult == 2  || wheelResult == 3) winMatrix[index] = 11;
          }          
          else if (betType == BetTypes.three_0_1_2)
          {
            if (wheelResult == 0 || wheelResult == 1  || wheelResult == 2) winMatrix[index] = 11;
          }          
          else if (betType == BetTypes.three_1_2_3)
          {
            if (wheelResult == 1 || wheelResult == 2  || wheelResult == 3) winMatrix[index] = 11;
          }
          else if (betType == BetTypes.three_4_5_6)
          {
            if (wheelResult == 4 || wheelResult == 5  || wheelResult == 6) winMatrix[index] = 11;
          }
          else if (betType == BetTypes.three_7_8_9)
          {
            if (wheelResult == 7 || wheelResult == 8  || wheelResult == 9) winMatrix[index] = 11;
          }
          else if (betType == BetTypes.three_10_11_12)
          {
            if (wheelResult == 10 || wheelResult == 11  || wheelResult == 12) winMatrix[index] = 11;
          }
          else if (betType == BetTypes.three_13_14_15)
          {
            if (wheelResult == 13 || wheelResult == 14  || wheelResult == 15) winMatrix[index] = 11;
          }
          else if (betType == BetTypes.three_16_17_18)
          {
            if (wheelResult == 16 || wheelResult == 17  || wheelResult == 18) winMatrix[index] = 11;
          }
          else if (betType == BetTypes.three_19_20_21)
          {
            if (wheelResult == 19 || wheelResult == 20  || wheelResult == 21) winMatrix[index] = 11;
          }
          else if (betType == BetTypes.three_22_23_24)
          {
            if (wheelResult == 22 || wheelResult == 23  || wheelResult == 24) winMatrix[index] = 11;
          }
          else if (betType == BetTypes.three_25_26_27)
          {
            if (wheelResult == 25 || wheelResult == 26  || wheelResult == 27) winMatrix[index] = 11;
          }
          else if (betType == BetTypes.three_28_29_30)
          {
            if (wheelResult == 28 || wheelResult == 29  || wheelResult == 30) winMatrix[index] = 11;
          }
          else if (betType == BetTypes.three_31_32_33)
          {
            if (wheelResult == 31 || wheelResult == 32  || wheelResult == 33) winMatrix[index] = 11;
          }
          else if (betType == BetTypes.three_34_35_36)
          {
            if (wheelResult == 34 || wheelResult == 35  || wheelResult == 36) winMatrix[index] = 11;
          }
          else if (betType == BetTypes.six_1_2_3_4_5_6)
          {
            if (wheelResult == 1 || wheelResult == 2  || wheelResult == 3  || wheelResult == 4  || wheelResult == 5  || wheelResult == 6) winMatrix[index] = 5;
          }
          else if (betType == BetTypes.six_4_5_6_7_8_9)
          {
            if (wheelResult == 4 || wheelResult == 5  || wheelResult == 6  || wheelResult == 7  || wheelResult == 8  || wheelResult == 9) winMatrix[index] = 5;
          }
          else if (betType == BetTypes.six_7_8_9_10_11_12)
          {
            if (wheelResult == 7 || wheelResult == 8  || wheelResult == 9  || wheelResult == 10  || wheelResult == 11  || wheelResult == 12) winMatrix[index] = 5;
          }
          else if (betType == BetTypes.six_10_11_12_13_14_15)
          {
            if (wheelResult == 10 || wheelResult == 11  || wheelResult == 12  || wheelResult == 13  || wheelResult == 14  || wheelResult == 15) winMatrix[index] = 5;
          }
          else if (betType == BetTypes.six_13_14_15_16_17_18)
          {
            if (wheelResult == 13 || wheelResult == 14  || wheelResult == 15  || wheelResult == 16  || wheelResult == 17  || wheelResult == 18) winMatrix[index] = 5;
          }
          else if (betType == BetTypes.six_16_17_18_19_20_21)
          {
            if (wheelResult == 16 || wheelResult == 17  || wheelResult == 18  || wheelResult == 19  || wheelResult == 20  || wheelResult == 21) winMatrix[index] = 5;
          }
          else if (betType == BetTypes.six_19_20_21_22_23_24)
          {
            if (wheelResult == 19 || wheelResult == 20  || wheelResult == 21  || wheelResult == 22  || wheelResult == 23  || wheelResult == 24) winMatrix[index] = 5;
          }
          else if (betType == BetTypes.six_22_23_24_25_26_27)
          {
            if (wheelResult == 22 || wheelResult == 23  || wheelResult == 24  || wheelResult == 25  || wheelResult == 26  || wheelResult == 27) winMatrix[index] = 5;
          }
          else if (betType == BetTypes.six_25_26_27_28_29_30)
          {
            if (wheelResult == 25 || wheelResult == 26  || wheelResult == 27  || wheelResult == 28  || wheelResult == 29  || wheelResult == 30) winMatrix[index] = 5;
          }
          else if (betType == BetTypes.six_28_29_30_31_32_33)
          {
            if (wheelResult == 28 || wheelResult == 29  || wheelResult == 30  || wheelResult == 31  || wheelResult == 32  || wheelResult == 33) winMatrix[index] = 5;
          }
          else if (betType == BetTypes.six_31_32_33_34_35_36)
          {
            if (wheelResult == 31 || wheelResult == 32  || wheelResult == 33  || wheelResult == 34  || wheelResult == 35  || wheelResult == 36) winMatrix[index] = 5;
          }
        }
      }

      betsProcessed = max;
   }

   function getIndex(uint16 bet, uint16 wheelResult) private returns (uint16)
   {
      return (bet+1)*256 + (wheelResult+1);
   }
       
    modifier onlyDeveloper() 
    {
       if (msg.sender!=developer) throw;
       _;
    }


    function getCoeff(uint16 n) external returns (uint256) 
    {
        return winMatrix[n];
    }

   function() 
   {
      throw;
   }
   

}