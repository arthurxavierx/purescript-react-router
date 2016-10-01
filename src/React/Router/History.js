'use strict';

exports.watchHistory = function(handler) {
  return function() {
    handler(typeof window !== 'undefined' ? window.location.pathname : '')();
    if (typeof window !== 'undefined') {
      window.addEventListener('popstate', function () {
        handler(window.location.pathname)();
      });
    }
  };
};

exports.linkHandler = function(url) {
  return function(ev) {
    return function() {
      ev.preventDefault();
      if (typeof window !== 'undefined') {
        window.history.pushState({}, document.title, url);
        window.dispatchEvent(new Event('popstate'));
      }
    };
  };
};

exports.navigateTo = function(url) {
  return function() {
    if (typeof window !== 'undefined') {
      window.history.pushState({}, document.title, url);
      window.dispatchEvent(new Event('popstate'));
    }
  };
};
