

module.exports = (app) ->
  app.controller 'AppController', class AppController
    constructor: (@$scope, @$http) ->
      @$scope.counties = null
      @$scope.current = null
      @getCounties()

    getCounties: () ->
      @$http({
        method: 'GET',
        url: '/counties'
        }).then((response) =>
            @$scope.counties = response.data.counties
            @createMap()
          , (err) ->
            console.log err
          )
    createMap: () ->
      console.log 'creating!'
      width = 960
      height = 600

      color_domain = [1, 10000]
      ext_color_domain = [0, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000]
      legend_labels = ["< 500", "500+", "1000+", "1500+", "2000+", "2500+", "3000+", "3500+", "4000+", "4500+", "5000+", "5500+", "6000+"]
      color = d3.scale.quantize()
      .domain(color_domain)
      .range(["#cc0000"])

      div = d3.select(".main").append("div")
      .attr("class", "tooltip")
      .style("opacity", 0)

      svg = d3.select(".main").append("svg")
      .attr("width", width)
      .attr("height", height)
      .style("margin", "10px auto");
      path = d3.geo.path()

      ready = (error, us) =>
        pairTonsWithFips = {}
        pairNameWithFips = {}
        for county in @$scope.counties
          fips = county.fips
          pairTonsWithFips[fips] = county.sulfur
          pairNameWithFips[fips] = county.name

        svg.append("g")
        .attr("class", "county")
        .selectAll("path")
        .data(topojson.feature(us, us.objects.counties).features)
        .enter().append("path")
        .attr("d", path)
        .style("fill", (d) ->
          console.log color(pairTonsWithFips[d.id])
          return color(pairTonsWithFips[d.id])
        )
        .on("mouseover", (d) ->
          @$scope.current = d.id
          console.log @$scope.current
        )

      queue()
        .defer(d3.json, "/us.json")
        .await(ready)

