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
      .range(["#ea9999", "#e57f7f", "#e06666", "#db4c4c", "#d63232", "#cc0000", "#7a0000"])

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

            total = county.sulfur + county.nox + county.voc
            data = [{key:"SO2", y: county.sulfur/total},
            {key:"NOX", y: county.nox/total},
            {key:"VOC", y: county.voc/total}]
            height = 350
            width = 350

            nv.addGraph(() ->
              chart = nv.models.pieChart()
                .x((d) -> return d.key)
                .y((d) -> return d.y)
                .color(d3.scale.category20().range().slice(3))
                .growOnHover(false)
                .labelType('value')
                .width(width)
                .height(height)
              chart.pie.donutLabelsOutside(true).donut(true)

              d3.select("#test2")
                .datum(data)
                .transition().duration(1200)
                .attr('width', width)
                .attr('height', height)
                .call(chart)

              return chart
            )

            @$scope.showStats = true
            @$scope.current = county
          )
        )

      queue()
        .defer(d3.json, "/us.json")
        .await(ready)

