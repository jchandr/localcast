module.exports = Utils =

  msToHumanString : (ms) ->

    seconds = Math.floor((ms / 1000) % 60)
    minutes = Math.floor(seconds / 60)
    if minutes < 60
      return "#{@zeroPadded(minutes)}:#{@zeroPadded(seconds)}"
    else
      minutes = seconds % 60
      hours = Math.floor(minutes / 60)
      return "#{@zeroPadded(hours)}:#{@zeroPadded(minutes)}:#{@zeroPadded(seconds)}"


  zeroPadded : (number) ->

    string = number.toString()
    if string.length == 1
      string = "0#{string}"

    return string
