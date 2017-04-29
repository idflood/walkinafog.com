/*
 * namespace.coffee v1.0.0
 * Copyright (c) 2011 CodeCatalyst, LLC.
 * Open source under the MIT License.
 */
((() => {
  var namespace;
  namespace = (name, values) => {
    var key;
    var subpackage;
    var target;
    var value;
    var _i;
    var _len;
    var _ref;
    var _results;
    target = typeof exports !== "undefined" && exports !== null ? exports : window;
    if (name.length > 0) {
      _ref = name.split('.');
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        subpackage = _ref[_i];
        target = target[subpackage] || (target[subpackage] = {});
      }
    }
    _results = [];
    for (key in values) {
      value = values[key];
      _results.push(target[key] = value);
    }
    return _results;
  };
  namespace("", {
    namespace
  });
})).call(this);
