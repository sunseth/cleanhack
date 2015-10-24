_ = require 'lodash'

module.exports = (app) ->
  app.controller 'AppController', class AppController
    constructor: (@$scope, @$http) ->
      @$scope.counties = null
      @$scope.countiesByFips = null
      @$scope.current = null
      @$scope.maxSul = null
      @$scope.maxNox = null
      @$scope.maxVoc = null
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
      height = 500
      redraw = () ->
        d3.select("g").attr("transform", "scale(" + d3.event.scale + ")")

      color_domain = [100, 3000]
      ext_color_domain = [100, 500, 1000, 1500, 2500, 5000]
      legend_labels = ["100", "500", "1000", "1500", "2500", "5000 (tons)"]
      color = d3.scale.quantize()
      .domain(color_domain)
      .range(["#ea9999", "#e57f7f", "#e06666", "#db4c4c", "#d63232", "#cc0000"])

      div = d3.select(".main").append("div")
      .attr("class", "tooltip")
      .style("opacity", 0)

      svg = d3.select(".main").append("svg")
      .attr("width", width)
      .attr("height", height)
      .style("margin", "10px auto")

      # legend = svg.selectAll("g.legend")
      #   .data(ext_color_domain)
      #   .enter().append("g")
      #   .attr("class", "legend")

      # ls_w = 20
      # ls_h = 20
      # legend.append("rect")
      #   .attr("x", 20)
      #   .attr("y", (d, i) -> return height - (i*ls_h) - 2*ls_h)
      #   .attr("width", ls_w)
      #   .attr("height", ls_h)
      #   .style("fill", (d, i) -> return color(d))
      #   .style("opacity", 0.8)
      # legend.append("text")
      #   .attr("x", 50)
      #   .attr("y", (d, i) -> return height - (i*ls_h) - ls_h - 4)
      #   .text((d, i) -> return legend_labels[i])

      path = d3.geo.path()

      ready = (error, us) =>
        pairTonsWithFips = {}
        pairNameWithFips = {}
        for county in @$scope.counties
          fips = county.fips
          pairTonsWithFips[fips] = county.sulfur + county.nox + county.voc
          pairNameWithFips[fips] = county.name

        g = svg.append("g")
        .attr("class", "county")
        .selectAll("path")
        .data(topojson.feature(us, us.objects.counties).features)
        .enter().append("path")
        .attr("d", path)
        .style("fill", (d) =>
          return color(pairTonsWithFips[d.id]) || "#f9e5e5"
        )
        .call(d3.behavior.zoom().on("zoom", () ->
          g.attr("transform", "translate(" + d3.event.translate + ")" + " scale(" + d3.event.scale + ")")
        ))
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
                .labelType('percent')
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

            req = (county, type) ->
              return {
                method: 'POST',
                url: '/offender',
                headers: {
                  'Content-Type': 'application/x-www-form-urlencoded'
                },
                data: {county: county, type: type}
              }
            @$http(req(county.name, "Sulfur Dioxide"))
              .then((response) =>
                @$scope.maxSul = response.data
                @$http(req(county.name, "Nitrogen Oxides"))
                  .then((response1) =>
                    @$scope.maxNox = response1.data
                    @$http(req(county.name, "Volatile Organic Compounds"))
                      .then((response2) =>
                        @$scope.maxVoc = response2.data
                      , (err) ->
                        console.log err
                    )
                  , (err) ->
                    console.log err
                )
              , (err) ->
                console.log err
            )
          )
        )

      queue()
        .defer(d3.json, "/us.json")
        .await(ready)

