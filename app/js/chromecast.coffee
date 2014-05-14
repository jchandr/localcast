nodecastor = require("nodecastor")
Backbone = require("backbone")
_ = require("lodash")
app = require("./app")
server = require("./server")

module.exports = class Chromecast

  DEFAULT_MEDIA_RECEIVER : "CC1AD845"
  MEDIA_NAMESPACE : "urn:x-cast:com.google.cast.media"

  constructor : ->

    _.extend(@, Backbone.Events)

    nodecastor
      .scan()
      .on("online", (device) =>
        @connect(device)
      )
      .on("offline", (device) ->
        console.log("Removed device", device)
      )
      .start()

    @listenTo(app.vent, "playlist:playTrack", @playMedia)
    @isAppRunning = false


  connect : (device) ->

    device.on("connect", =>

      @device = device

      device.status((err, s) ->
        if (!err)
          console.log("Chromecast status", s)
      )

      device.on("status", (status) ->
        console.log("Chromecast status updated", status)
      )

      device.on("error", (err) ->
        console.error("An error occurred with some Chromecast device", err)
      )

      device.application(@DEFAULT_MEDIA_RECEIVER, (err, app) =>
        if (!err)

          if @isAppRunning
            app.join(@MEDIA_NAMESPACE, @requestSession)
          else
            app.run(@MEDIA_NAMESPACE, @requestSession)
            @isAppRunning = true
      )
    )

  requestSession : (err, session) =>

      if(!err)
        @session = session


  playMedia : (file) ->

    @mediaSessionId = 1234

    mediaInfo =
      contentId : "#{server.getServerUrl()}#{file.get('path')}",
      streamType : file.get("streamType"),
      contentType : file.get("type")

    request =
      type : "LOAD",
      media : mediaInfo

    @sendCommand(request)


  seek : (time) ->

    request =
      type : "SEEK",
      currentTime : time

    @sendCommand(request)


  play : ->

    request =
      type : "PLAY",

    @sendCommand(request)


  pause : ->

    request =
      type : "PAUSE",

    @sendCommand(request)


  sendCommand : (request) ->

    if @session

      request = _.extend(request,
        mediaSessionId : @medmediaSessionId
        requestId : 123,
      )

      @session.send(request, (err, message) =>
        if (err)
          console.error("Unable to cast:", err.message)
          @device.stop()

        if message
          console.log(message)
      )





