
bcQrReader = ($timeout) ->
  {
    restrict: "E"
    replace: 'true'
    scope: {
      onResult: '='
      onError: '='
      active: '='
      cameraStatus: '='
      cameraStream: '='
    }
    template: '<div><webcam on-stream="onStream(stream)" on-error="onError(err)" ng-if="active" channel="channel"></webcam><canvas id="qr-canvas"></canvas></div>',
    link: (scope, elem, attrs) ->
      scope.channel = {}

      if !scope.onError
        scope.onError = (error) -> console.log error

      turnOff = () ->
        video = scope.channel.video;
        if video
          video.pause();
          video.src = "";
        if scope.cameraStream
          scope.cameraStream.getTracks()[0].stop();
        return;

      scope.$on('$destroy', turnOff);

      scope.onStream = (stream) ->
        # Evil (TODO: use a directive to manipulate the DOM or try to use scope.channel):
        canvas = document.getElementById("qr-canvas")
        scope.cameraStream = stream

        scope.lookForQR()
        scope.cameraStatus = true

      scope.lookForQR = () ->
        canvas = document.getElementById("qr-canvas")
        video = document.getElementsByTagName("video")[0]

        if video? && video.videoWidth > 0
          # This won't be set at the first iteration.
          canvas.width =  video.videoWidth
          canvas.height = video.videoHeight

          canvas.getContext("2d").drawImage(video,0,0)

        res = undefined

        try
          res = qrcode.decode()
        catch e
          $timeout((->
            scope.lookForQR()
          ), 250)

        if res?
          scope.onResult(res)
          canvas.getContext("2d").clearRect(0, 0, canvas.width, canvas.height);
  }

angular
  .module('bcQrReader', [])
  .directive('bcQrReader', ['$timeout', bcQrReader])
