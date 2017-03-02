var  _ceph3us$killalytics$Native_Endpoint = function() {


    /* Gets a WebSocket URL relative to the current domain/protocol.
     */
    function wsUrl(value)
    {
        var stringValue = _elm_lang$core$Native_Utils.toString(value);
        if (location) {
            var protocol = location.protocol === 'https:' ? 'wss://' : 'ws://';
            return protocol + location.host + '/' + value;
        }

        return '';
    }

    return {
        wsUrl: wsUrl
    };

}();