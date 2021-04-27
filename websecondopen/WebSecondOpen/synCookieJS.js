!function () {
    function d() {
        var e = document.location.hostname;
        if (typeof e === 'string' && e.length > 3) {
            return true
        };
        return false
    };

    if (d()) {
        var cookie_setter = document.__lookupSetter__('cookie');
        var cookie_getter = document.__lookupGetter__('cookie');

        Object.defineProperty(document,'cookie', {
            get: function() {
                return cookie_getter.apply(this,arguments);
            },
            set: function(n) {
                if (typeof n !== 'string') {
                    return
                };
                var info = {};
                info['key'] = 'synCookie';
                info['cookie'] = n;
                info['url'] = document.location.href;
                window.webkit.messageHandlers.jsObj.postMessage(info)
                return cookie_setter.apply(this,arguments);
            },
            configurable:true
        });
    }

} ();
