// Generated by CoffeeScript 1.3.1
(function() {

  window.orders = {
    deliveries: [],
    container: null,
    window: null,
    makeElements: function() {
      var i, _i;
      for (i = _i = 1; _i <= 5; i = ++_i) {
        this.deliveries.push($("#d" + i));
      }
      this.container = $("#deliverybox");
      return this.window = $(window);
    },
    setBackgroundColors: function() {
      var bgs, d, i, _i, _ref, _results;
      bgs = ["lightgray", "white"];
      _results = [];
      for (i = _i = 0, _ref = this.deliveries.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        d = this.deliveries[i];
        _results.push(d.css("background-color", bgs[i % 2]));
      }
      return _results;
    },
    setOnClicks: function() {
      var i, _i, _ref, _results,
        _this = this;
      _results = [];
      for (i = _i = 0, _ref = this.deliveries.length - 1; 0 <= _ref ? _i <= _ref : _i >= _ref; i = 0 <= _ref ? ++_i : --_i) {
        _results.push(this.deliveries[i].bind('click', function() {
          return _this.toggleExpanded(3);
        }));
      }
      return _results;
    },
    expand: function(i) {
      return $(".expanded" + i).show();
    },
    collapse: function(i) {
      return $(".expanded" + i).hide();
    },
    toggleExpanded: function(i) {
      var extra;
      extra = $("#d" + i);
      if (extra.css("display") === "none") {
        this.expand(i);
        return console.log("none " + i);
      } else {
        this.collapse(i);
        return console.log("block " + i);
      }
    }
  };

  $(document).ready(function() {
    orders.makeElements();
    orders.setOnClicks();
    return orders.setBackgroundColors();
  });

}).call(this);
