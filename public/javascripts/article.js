var Utils = Utils || {};

Utils.scrollDown = function () {
  window.scrollBy(0, 50);
};

Utils.scrollUp = function () {
  window.scrollBy(0, -50);
};

Utils.scrollBottom = function () {
  window.scrollBy(0, window.scrollMaxY);
};

Utils.scrollTop = function () {
  window.scroll(0, 0);
};

Utils.scrollerDerby = function (e) {
  var key = e.charCode;

  switch(key) {
    case 106:
      Utils.scrollDown();
      break;

    case 107:
      Utils.scrollUp();
      break;

    case 74:
      Utils.scrollBottom();
      break;

    case 75:
      Utils.scrollTop();
  }
};

window.onkeypress = Utils.scrollerDerby;
