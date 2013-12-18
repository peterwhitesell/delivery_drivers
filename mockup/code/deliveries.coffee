#coffee -c ./static/graphthought.coffee
window.orders =
  deliveries: []
  container: null
  window: null
  
    
  makeElements: ->
    for i in [1..5]
      @deliveries.push $("#d#{i}")
    @container = $("#deliverybox")
    @window = $(window)
  
  setBackgroundColors: ->
    bgs = ["lightgray", "white"]
    for i in [0...@deliveries.length]
      d = @deliveries[i]
      d.css "background-color", bgs[i%2]
      
  setOnClicks: ->
    for i in [0..@deliveries.length - 1]
      @deliveries[i].bind 'click', =>
        @toggleExpanded(3)
  
  expand: (i) ->
    $(".expanded#{i}").show()  
 
  collapse: (i) ->
    $(".expanded#{i}").hide()
  
  toggleExpanded: (i) ->
    extra = $("#d#{i}")
    if extra.css("display") == "none"
      @expand(i)
      console.log "none " + i
    else
      @collapse(i)
      console.log "block " + i
  
  
    
$(document).ready ->
  orders.makeElements()
  orders.setOnClicks()
  orders.setBackgroundColors()
  
