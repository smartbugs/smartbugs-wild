contract ZeroDollarHomePage {
    event InvalidPullRequest(uint indexed pullRequestId);
    event PullRequestAlreadyClaimed(uint indexed pullRequestId, uint timeBeforeDisplay, bool past);
    event PullRequestClaimed(uint indexed pullRequestId, uint timeBeforeDisplay);
    event QueueIsEmpty();

    bool _handledFirst;
    uint[] _queue;
    uint _current;
    address owner;

    function ZeroDollarHomePage() {
        owner = msg.sender;
        _handledFirst = false;
        _current = 0;
    }

    function remove() {
        if (msg.sender == owner){
            suicide(owner);
        }
    }

    /*
     * Register a new pull request.
     */
    function newRequest(uint pullRequestId) {
        if (pullRequestId <= 0) {
            InvalidPullRequest(pullRequestId);
            return;
        }

        // Check that the pr hasn't already been claimed
        bool found = false;
        uint index = 0;

        while (!found && index < _queue.length) {
            if (_queue[index] == pullRequestId) {
                found = true;
                break;
            } else {
                index++;
            }
        }

        if (found) {
            PullRequestAlreadyClaimed(pullRequestId, (index - _current) * 1 days, _current > index);
            return;
        }

        _queue.push(pullRequestId);
        PullRequestClaimed(pullRequestId, (_queue.length - _current) * 1 days);
    }

    /*
     * Close the current request in queue and move the queue to its next element.
     */
    function closeRequest() {
        if (_handledFirst && _current < _queue.length - 1) {
            _current += 1;
        }

        _handledFirst = true;
    }

    /*
     * Get the last non published pull-request from the queue
     */
    function getLastNonPublished() constant returns (uint pullRequestId) {
        if (_current >= _queue.length) {
            return 0;
        }

        return _queue[_current];
    }
}