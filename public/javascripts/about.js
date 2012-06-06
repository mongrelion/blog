var RecentTracks = function (data) {
  this.tracks = [];
  var track = data.track;
  if ($.isArray(data.track)) {
    track = data.track[0];
  }
  this.tracks.push(new Track(track));
};

RecentTracks.prototype.nowPlaying = function () {
  return this.tracks[0];
};

var Track = function (data) {
  this.name   = data.name;
  this.artist = data.artist['#text'];
  this.image  = data.image[0]['#text'];
};

Track.prototype.toString = function () {
  return this.name + " - " + this.artist;
};

$(function () {
  if (false || api_key = window.LastFmApiKey) {
    var url = 'http://ws.audioscrobbler.com/2.0/?method=user.getrecenttracks&user=mongrelion&format=json&limit=1&api_key=' + api_key;
    var ajaxSettings = {
        url: url
      , success: function (data, textStatus, jqXHR) {
          var recentTracks = new RecentTracks(data.recenttracks);
          var currentTrack = recentTracks.nowPlaying();
          var $musicBox    = $('div#now-playing');
          var $viewPort    = $musicBox.find('span.viewport');
          $viewPort.html(recentTracks.nowPlaying().toString());
          $musicBox.show();
        }
    };
    $.ajax(ajaxSettings);
  }
});
