

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
      width = 960
      height = 900

      color_domain = [5, 1000]
      ext_color_domain = [0, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000]
      legend_labels = ["< 500", "500+", "1000+", "1500+", "2000+", "2500+", "3000+", "3500+", "4000+", "4500+", "5000+", "5500+", "6000+"]
      color = d3.scale.threshold()
      .domain(color_domain)
      .range(["#f4cccc", "#efb2b2", "#ea9999", "#e57f7f", "#e06666", "#db4c4c", "#d63232", "#d11919", "#cc0000"])

      div = d3.select(".main").append("div")
      .attr("class", "tooltip")
      .style("opacity", 0)

      svg = d3.select(".main").append("svg")
      .attr("width", width)
      .attr("height", height)
      .style("margin", "10px auto")

      path = d3.geo.path()

      ready = (error, us) =>
        pairTonsWithFips = {}
        pairNameWithFips = {}
        for county in @$scope.counties
          fips = +county.fips
          pairTonsWithFips[fips] = county.sulfur + county.nox
          pairNameWithFips[fips] = county.name

        svg.append("g")
        .attr("class", "county")
        .selectAll("path")
        .data(topojson.feature(us, us.objects.counties).features)
        .enter().append("path")
        .attr("d", path)
        .style("fill", (d) ->
          return color(pairTonsWithFips[d.id]) || "#f9e5e5"
        )
        .on("mouseover", (d) =>
          console.log d.id
          @$scope.current = d.id
        )

      queue()
        .defer(d3.json, "/us.json")
        .await(ready)

