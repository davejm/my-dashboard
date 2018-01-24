class Dashing.News extends Dashing.Widget

  ready: ->
    @pageIndex = -1
    @headlineContainerElem = $(@node).find('.headline-container')
    @headlinesPerPage = $(@node).attr('data-headlines-per-page')
    @headlinesPerPage = 1 if not @headlinesPerPage
    @nextComment()
    @startCarousel()

  onData: (data) ->
    @pageIndex = -1

  startCarousel: ->
    interval = $(@node).attr('data-interval')
    interval = "30" if not interval
    setInterval(@nextComment, parseInt( interval ) * 1000)

  nextComment: =>
    headlines = @get('headlines')
    if headlines
      @headlineContainerElem.fadeOut =>
        @pageIndex = (@pageIndex + 1) % Math.ceil(headlines.length / @headlinesPerPage)
        startIndex = @pageIndex * @headlinesPerPage
        endIndex = Math.min(startIndex + (@headlinesPerPage - 1), headlines.length - 1)
        @set 'current_headlines', headlines[startIndex..endIndex]
        # @headlineContainerElem.fadeIn()
        @headlineContainerElem.css("display", "flex").hide().fadeIn()

        @set 'pageNumber', @pageIndex + 1
        @set 'numPages', Math.ceil(headlines.length / @headlinesPerPage)
