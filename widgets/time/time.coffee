class Dashing.Time extends Dashing.Widget

  ready: ->
    setInterval(@startTime, 500)

  startTime: =>
    today = new Date()

    h = today.getHours()
    m = today.getMinutes()
    s = today.getSeconds()
    h = @formatTime(h)
    m = @formatTime(m)
    s = @formatTime(s)
    y = today.getFullYear()
    mo = @formatTime(today.getMonth())
    d = @formatTime(today.getDay())
    @set('time', h + ":" + m + ":" + s)
    @set('date', y + '-' + mo + '-' + d)

  formatTime: (i) ->
    if i < 10 then "0" + i else i