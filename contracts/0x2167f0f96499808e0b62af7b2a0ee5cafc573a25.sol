pragma solidity ^0.4.25;

/**
* https://rocket.cash
*
* RECOMMENDED GAS LIMIT: 350000
* RECOMMENDED GAS PRICE: https://ethgasstation.info/
*/
contract RocketCash
{
    uint constant public start = 1541678400;// The time Rocket.cash will start working (Thu Nov 08 2018 12:00:00 UTC)
    // Notice: you can make an investment, but you will not get your dividends until the project has started
    address constant public administrationFund = 0x97a121027a529B96f1a71135457Ab8e353060811;// For advertising (13%) and support (2%)
    mapping (address => uint) public invested;// Investors and their investments
    mapping (address => uint) private lastInvestmentTime;// Last investment time for each investor
    mapping (address => uint) private collected;// Collected amounts for each investor
    uint public investedTotal;// Invested sum (for statistics)
    uint public investorsCount;// Investors count (for statistics)

    event investment(address addr, uint amount, uint invested);// Investment event (for statistics)
    event withdraw(address addr, uint amount, uint invested);// Withdraw event (for statistics)

    function () external payable// This function has called every time someone makes a transaction to the Rocket.cash
    {
        if (msg.value > 0 ether)// If the sent value of ether is more than 0 - this is an investment
        {
            if (start < now)// If the project has started
            {
                if (invested[msg.sender] != 0) // If the investor has already invested to the Rocket.cash
                {
                    collected[msg.sender] = availableDividends(msg.sender);// Calculate dividends of the investor and remember it
                    // Notice: you can rise up your daily percentage by making an additional investment
                }
                //else// If the investor hasn't ever invested to the Rocket.cash - he has no percent to collect yet

                lastInvestmentTime[msg.sender] = now;// Save the last investment time for the investor
            }
            else// If the project hasn't started yet
            {
                lastInvestmentTime[msg.sender] = start;// Save the last investment time for the investor as the time of the project start
            }

            if (invested[msg.sender] == 0) investorsCount++;// Increase the investors counter (for statistics)
            investedTotal += msg.value;// Increase the invested value (for statistics)

            invested[msg.sender] += msg.value;// Increase the invested value for the investor

            administrationFund.transfer(msg.value * 15 / 100);// Transfer the Rocket.cash commission (15% - for advertising (13%) and support (2%))

            emit investment(msg.sender, msg.value, invested[msg.sender]);// Emit the Investment event (for statistics)
        }
        else// If the sent value of ether is 0 - this is an ask to get dividends or money back
        // WARNING! Any investor can only ask to get dividends or money back ONCE! Once the investor has got his dividends or money he would be excluded from the project!
        {
            uint withdrawalAmount = availableWithdraw(msg.sender);

            if (withdrawalAmount != 0)// If withdrawal amount is not 0
            {
                emit withdraw(msg.sender, withdrawalAmount, invested[msg.sender]);// Emit the Withdraw event (for statistics)

                msg.sender.transfer(withdrawalAmount);// Transfer the investor's money back minus the Rocket.cash commission or his dividends and bonuses

                lastInvestmentTime[msg.sender] = 0;// Remove investment information about the investor after he has got his money and have been excluded from the Project
                invested[msg.sender]           = 0;// Remove investment information about the investor after he has got his money and have been excluded from the Project
                collected[msg.sender]          = 0;// Remove investment information about the investor after he has got his money and have been excluded from the Project
            }
            //else// If withdrawal amount is 0 - do nothing
        }
    }

    function availableWithdraw (address investor) public view returns (uint)// This function calculate an available amount for withdrawal
    {
        if (start < now)// If the project has started
        {
            if (invested[investor] != 0)// If the investor of the Rocket.cash hasn't been excluded from the project and ever have been in it
            {
                uint dividends = availableDividends(investor);// Calculate dividends of the investor
                uint canReturn = invested[investor] - invested[investor] * 15 / 100;// The investor can get his money back minus the Rocket.cash commission

                if (canReturn < dividends)// If the investor has dividends more than he has invested minus the Rocket.cash commission
                {
                    return dividends;
                }
                else// If the investor has dividends less than he has invested minus the Rocket.cash commission
                {
                    return canReturn;
                }
            }
            else// If the investor of the Rocket.cash have been excluded from the project or never have been in it - available amount for withdraw = 0
            {
                return 0;
            }
        }
        else// If the project hasn't started yet - available amount for withdraw = 0
        {
            return 0;
        }
    }

    function availableDividends (address investor) private view returns (uint)// This function calculate available for withdraw amount
    {
        return collected[investor] + dailyDividends(investor) * (now - lastInvestmentTime[investor]) / 1 days;// Already collected amount plus Calculated daily dividends (depends on the invested amount) are multiplied by the count of spent days from the last investment
    }

    function dailyDividends (address investor) public view returns (uint)// This function calculate daily dividends (depends on the invested amount)
    {
        if (invested[investor] < 1 ether)// If the invested amount is lower than 1 ether
        {
            return invested[investor] * 222 / 10000;// The interest would be 2.22% (payback in 45 days)
        }
        else if (1 ether <= invested[investor] && invested[investor] < 5 ether)// If the invested amount is higher than 1 ether but lower than 5 ether
        {
            return invested[investor] * 255 / 10000;// The interest would be 2.55% (payback in 40 days)
        }
        else// If the invested amount is higher than 5 ether
        {
            return invested[investor] * 288 / 10000;// The interest would be 2.88% (payback in 35 days)
        }
    }
}