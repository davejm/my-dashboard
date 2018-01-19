class Dashing.Forecast extends Dashing.Widget
  constructor: ->
    super
    @forecast_icons = new Skycons({"color": "white"})
    @forecast_icons.play()

  ready: ->
    # This is fired when the widget is done being rendered

    # Note that there could be a race condition with this and when the hourly
    # icon canvas elements get their id attributes from the data-bind-id.
    # So we wait a bit
    setTimeout ( =>
      @setIcons()
    ), 200

  onData: (data) ->
    # Handle incoming data
    # We want to make sure the first time they're set is after ready()
    # has been called, or the Skycons code will complain.
    if @forecast_icons.list.length
      @setIcons()

  setIcons: ->
    @setIcon('forecast-today-icon', 'today.icon')
    @setIcon('forecast-now-icon', 'current.icon')
    for i in [0..12]
      @setIcon("forecast-hour#{i}-icon", "nextHoursObjectKeys.#{i}.icon")

  setIcon: (elemId, dataName) ->
    skycon = @toSkycon(dataName)
    @forecast_icons.set(elemId, eval(skycon)) if skycon

  toSkycon: (data) ->
    if @get(data)
      'Skycons.' + @get(data).replace(/-/g, "_").toUpperCase()
