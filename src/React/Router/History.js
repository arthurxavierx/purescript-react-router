'use strict';

exports.watchHistory = function(handler) {
  return function() {
    handler(typeof window !== 'undefined' ? window.location.pathname : '');
    if (typeof window !== 'undefined') {
      window.onpopstate = function () {
        handler(window.location.pathname);
      };
    }
  };
};
