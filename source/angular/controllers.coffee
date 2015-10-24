

module.exports = (app) ->
  app.controller 'AppController', class AppController
    constructor: (@$scope, @$http) ->
      @$scope.counties = null;
      @getCounties()

    getCounties: () ->
      @$http({
        method: 'GET',
        url: '/counties'
        }).then((response) ->
            console.log response.counties
            @$scope.counties = response.counties
            @createMap()
          , (err) ->
            console.log err
          )
    createMap: () ->
      console.log 'creating!'
      width = 960
      height = 600

      tonsByFips = d3.map()
      quantize = d3.scale.quantize()
        .domain([1, 100000])
        .range(d3.range(9).map((i) ->
          return "q" + i + "-9"))
      projection = d3.geo.albersUsa()
        .scale(1280)
        .translate([width / 2, height / 2])
      path = d3.geo.path()
        .projection(projection)
      svg = d3.select(".main").append("svg")
        .attr("width", width)
        .attr("height", height)

      queue()
        .defer(d3.json, "/us.json")