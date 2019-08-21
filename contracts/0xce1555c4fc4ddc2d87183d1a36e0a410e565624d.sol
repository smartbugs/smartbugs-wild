contract storadge {
    event log(string description);
	function save(
        string mdhash
    )
    {
        log(mdhash);
    }
}