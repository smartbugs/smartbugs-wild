pragma solidity ^0.4.11;


contract Consents {

    enum ActionType { REVOKE, CONSENT, NONE }

    struct Action {
        ActionType actionType;
        string inputDate;
        string endDate;
    }

    mapping (address => Action[]) consentHistoryByUser;

    function giveConsent(string inputDate, string endDate){
        address userId = msg.sender;
        consentHistoryByUser[userId].push(Action(ActionType.CONSENT, inputDate, endDate));
    }

    function revokeConsent(string inputDate){
        address userId = msg.sender;
        consentHistoryByUser[userId].push(Action(ActionType.REVOKE, inputDate, ""));
    }

    function getLastAction(address userId) returns (ActionType, string, string) {
        Action[] memory history = consentHistoryByUser[userId];
        if (history.length < 1) {
            return (ActionType.NONE, "", "");
        }
        Action memory lastAction = history[history.length - 1];
        return (lastAction.actionType, lastAction.inputDate, lastAction.endDate);
    }

    function getActionHistorySize() returns (uint) {
        address userId = msg.sender;
        return consentHistoryByUser[userId].length;
    }

    function getActionHistoryItem(uint index) returns (ActionType, string, string) {
        address userId = msg.sender;
        Action[] memory history = consentHistoryByUser[userId];
        Action memory action = history[index];
        return (action.actionType, action.inputDate, action.endDate);
    }

    function strActionType(ActionType actionType) internal constant returns (string) {
        if (actionType == ActionType.REVOKE) {
            return "REVOCATION";
        }
        else if (actionType == ActionType.CONSENT) {
            return "ACTIVATION";
        }
        else {
            return "";
        }
    }

    function strConcatAction(string accumulator, Action action, bool firstItem) internal constant returns (string) {

        string memory str_separator = ", ";
        string memory str_link = " ";

        bytes memory bytes_separator = bytes(str_separator);
        bytes memory bytes_accumulator = bytes(accumulator);
        bytes memory bytes_date = bytes(action.inputDate);
        bytes memory bytes_link = bytes(str_link);
        bytes memory bytes_action = bytes(strActionType(action.actionType));

        uint str_length = 0;
        str_length += bytes_accumulator.length;
        if (!firstItem) {
            str_length += bytes_separator.length;
        }
        str_length += bytes_date.length;
        str_length += bytes_link.length;
        str_length += bytes_action.length;

        string memory result = new string(str_length);
        bytes memory bytes_result = bytes(result);
        uint k = 0;
        uint i = 0;
        for (i = 0; i < bytes_accumulator.length; i++) bytes_result[k++] = bytes_accumulator[i];
        if (!firstItem) {
            for (i = 0; i < bytes_separator.length; i++) bytes_result[k++] = bytes_separator[i];
        }
        for (i = 0; i < bytes_date.length; i++) bytes_result[k++] = bytes_date[i];
        for (i = 0; i < bytes_link.length; i++) bytes_result[k++] = bytes_link[i];
        for (i = 0; i < bytes_action.length; i++) bytes_result[k++] = bytes_action[i];
        return string(bytes_result);

    }

    function Restitution_Historique_Transactions(address userId) public constant returns (string) {
        Action[] memory history = consentHistoryByUser[userId];
        string memory result = "";
        if (history.length > 0) {
            result = strConcatAction(result, history[0], true);
            for (uint i = 1; i < history.length; i++) {
                result = strConcatAction(result, history[i], false);
            }
        }
        return result;
    }
}