contract DataService {
    event NewDataRequest(uint id, bool initialized, string dataUrl); 
    event GetDataRequestLength(uint length);
    event GetDataRequest(uint id, bool initialized, string dataurl, uint dataPointsLength);

    event AddDataPoint(uint dataRequestId, bool success, string response);
    event GetDataPoint(uint dataRequestId, uint id, bool success, string response);

    struct DataPoint {
        bool initialized;
        bool success;
        string response; 
    }
    struct DataRequest {
        bool initialized;
        string dataUrl;
        DataPoint[] dataPoints;
    }

    address private organizer;
    DataRequest[] private dataRequests;

    // Create a new lottery with numOfBets supported bets.
    function DataService() {
        organizer = msg.sender;
    }
    
    // Fallback function returns ether
    function() {
        throw;
    }
    
    // Lets the organizer add a new data request
    function addDataRequest(string dataUrl) {
        // Only let organizer add requests for now
        if(msg.sender != organizer) { throw; }

        // Figure out where to store the new DataRequest (next available element)
        uint nextIndex = dataRequests.length++;
    
        // Init the data request and save it
        DataRequest newDataRequest = dataRequests[nextIndex];
        newDataRequest.initialized = true;
        newDataRequest.dataUrl = dataUrl;

        NewDataRequest(dataRequests.length - 1, newDataRequest.initialized, newDataRequest.dataUrl);
    }

    // Returns the amount of dataRequests currently present
    function getDataRequestLength() {
        GetDataRequestLength(dataRequests.length);
    }

    // Logs the data request with the requested ID
    function getDataRequest(uint id) {
        DataRequest dataRequest = dataRequests[id];
        GetDataRequest(id, dataRequest.initialized, dataRequest.dataUrl, dataRequest.dataPoints.length);
    }

    // Gets the data point associated with the provided dataRequest.
    function getDataPoint(uint dataRequestId, uint dataPointId) {
        DataRequest dataRequest = dataRequests[dataRequestId];
        DataPoint dataPoint = dataRequest.dataPoints[dataPointId];

        GetDataPoint(dataRequestId, dataPointId, dataPoint.success, dataPoint.response);
    }

    // Lets the organizer add a new data point
    function addDataPoint(uint dataRequestId, bool success, string response) {
        if(msg.sender != organizer) { throw; }
        
        // Get the DataRequest to edit, only allow adding a data point if initialized
        DataRequest dataRequest = dataRequests[dataRequestId];
        if(!dataRequest.initialized) { throw; }

        // Init the new DataPoint and save it
        DataPoint newDataPoint = dataRequest.dataPoints[dataRequest.dataPoints.length++];
        newDataPoint.initialized = true;
        newDataPoint.success = success;
        newDataPoint.response = response;

        AddDataPoint(dataRequestId, success, response);
    }

    // Suicide :(
    function destroy() {
        if(msg.sender != organizer) { throw; }
        
        suicide(organizer);
    }
}