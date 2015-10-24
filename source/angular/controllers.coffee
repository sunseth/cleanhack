_ = require 'lodash'

module.exports = (app) ->
  app.controller 'AppController', class AppController
    constructor: (@$scope, @$http) ->
      @$scope.counties = null
      @$scope.countiesByFips = null
      @$scope.current = null
      @$scope.showStats = false
      @$scope.stats = null
      @getCounties()

    getCounties: () =>
      @$http({
        method: 'GET',
        url: '/counties'
        }).then((response) =>
            @$scope.counties = response.data.counties
            for county in @$scope.counties
              county.fips = +county.fips
            @$scope.countiesByFips = _.indexBy(response.data.counties, "fips")
            @createMap()
          , (err) ->
            console.log err
          )
    createMap: () =>
      width = 960
      height = 540

      color_domain = [100, 3000]
      ext_color_domain = [0, 500, 1000, 1500, 2000, 2500, 3000, 3500, 4000, 4500, 5000, 5500, 6000]
      legend_labels = ["< 500", "500+", "1000+", "1500+", "2000+", "2500+", "3000+", "3500+", "4000+", "4500+", "5000+", "5500+", "6000+"]
      color = d3.scale.threshold()
      .domain(color_domain)
      .range(["#ea9999", "#e57f7f", "#e06666", "#db4c4c", "#d63232", "#d11919", "#cc0000"])

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
          fips = county.fips
          pairTonsWithFips[fips] = county.sulfur + county.nox + county.voc
          pairNameWithFips[fips] = county.name

        svg.append("g")
        .attr("class", "county")
        .selectAll("path")
        .data(topojson.feature(us, us.objects.counties).features)
        .enter().append("path")
        .attr("d", path)
        .style("fill", (d) =>
          return color(pairTonsWithFips[d.id]) || "#f9e5e5"
        )
        .on("click", (d) =>
          @$scope.$apply(() =>
            county = @$scope.countiesByFips[d.id]
            return unless county
            @$scope.showStats = true
            @$scope.current = county
            @$scope.stats = [{"label": "sulfur dioxide", "value": Math.round(county.sulfur)},
             {"label": "nitrogen oxide", "value": Math.round(county.nox)},
             {"label": "volatile organic compounds", "value": Math.round(county.voc)}
            ]
          )
        )

      queue()
        .defer(d3.json, "/us.json")
        .await(ready)

