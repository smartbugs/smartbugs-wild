contract ChineseCookies {

        address[] bakers;
        mapping(address => string[]) cookies;
        mapping(string => string) wishes;

        function ChineseCookies() {
                bakeCookie("A friend asks only for your time not your money.");
                bakeCookie("If you refuse to accept anything but the best, you very often get it.");
                bakeCookie("A smile is your passport into the hearts of others.");
                bakeCookie("A good way to keep healthy is to eat more Chinese food.");
                bakeCookie("Your high-minded principles spell success.");
                bakeCookie("Hard work pays off in the future, laziness pays off now.");
                bakeCookie("Change can hurt, but it leads a path to something better.");
                bakeCookie("Enjoy the good luck a companion brings you.");
                bakeCookie("People are naturally attracted to you.");
                bakeCookie("A chance meeting opens new doors to success and friendship.");
                bakeCookie("You learn from your mistakes... You will learn a lot today.");
        }

        function bakeCookie(string wish) {
                var cookiesCount = cookies[msg.sender].push(wish);

                // if it's the first cookie then we add sender to bakers list
                if (cookiesCount == 1) {
                        bakers.push(msg.sender);
                }
        }

        function breakCookie(string name) {
                var bakerAddress = bakers[block.number % bakers.length];
                var bakerCookies = cookies[bakerAddress];

                wishes[name] = bakerCookies[block.number % bakerCookies.length];
        }
}