$.fn.select2.defaults.set("theme", "bootstrap4")

wikirateApiHost = "https://wikirate.org"
wikirateApiAuth = null

# wikirateApiHost = "https://dev.wikirate.org"
# wikirateApiAuth = "wikirate:wikirat"
wikirateApiMode = "cached"
# wikirateApiMode = "live" # anything but "cached" means live

wikirateLinkTarget = "https://wikirate.org"

# pass basic authentication on Wikirate dev/staging servers
if wikirateApiAuth
  $.ajaxSetup
    beforeSend: (xhr) ->
      xhr.setRequestHeader "Authorization", "Basic " + btoa(wikirateApiAuth)

window.FC =
  # @template = new FC.util.templater "main"
  # note: remember to update urls in update_cached_data.rb when updating company group
  companyGroup: 13479530
  countryList: 20354046

  metrics:
    hasBrands: 5768810
    supplierOf: 2929015

    brandsLatestMap:
      headquarters: 6126450
      twitter_handle: 6140253

      revenue: 5780267
      profit: 5780278
      top_3_production_countries: 5768935

    brandsAnnualMap:
      transparency_score: 5780639
      living_wages_score: 5990097

      public_commitment: 7616258
      action_plan: 7624093
      freedom_of_association_n_bargaining: 19884143

      transparency_key: 6261816
      living_wages_key: 6261809

    suppliersMap:
      headquarters: 6126450
      female: 3233894
      male: 3233883
      other: 6019448
      num_workers: 4780588
      migrant: 4781556
#      permanent: 6019621
#      temporary: 6019632
      average: 6019687
      gap: 7347357
      # cba: 6020927
      # know_brand: 6019511
      # pregnancy: 6019786

  score:
    transparency:
      "0.0": 1
      "2.5": 2
      "5.0": 3
      "7.5": 4
      "10.0": 5
    commitment:
      "No": 1
      "Partial": 2
      "Yes": 3
      "Yes, Other": 3
      "Yes, ACT": 3
      "Yes, Fair Wear Foundation": 3

  subBrands: {}

FC.metrics.brandsMap =
  Object.assign {}, FC.metrics.brandsLatestMap, FC.metrics.brandsAnnualMap

$.extend FC,
  apiSwitch: (cached, live) ->
    if wikirateApiMode == "cached"
      cached
    else
      live

  apiUrl: (path, query) ->
    "#{wikirateApiHost}/#{path}.json?" + $.param(query)

  profilePath: (companyId, year) ->
    p = "brand-profile.html?q=#{companyId}"
    p += "&year=#{year}" if year
    p

  metricUrl: (metricId) ->
    "#{wikirateLinkTarget}/~#{metricId}"

  companyUrl: (companyId) ->
    "#{wikirateLinkTarget}/~#{companyId}?" +
      $.param
        contrib: "N"
        tab: "metric_answer"
        filter:
          topic: "Filling the Gap"

subBrandsUrl = FC.apiSwitch "/content/sub_brands.json",
  FC.apiUrl "~#{FC.metrics.hasBrands}+Relationship",
    limit: 999
    filter:
      company_group: "~#{FC.companyGroup}"
      year: "latest"

livingWageUrl =  FC.apiSwitch "/content/living_wage_scores.json",
  FC.apiUrl "~#{FC.metrics.brandsAnnualMap.living_wages_score}+Answer",
      limit: 2000
      filter:
        company_group: "~#{FC.companyGroup}"
        year: "latest"

countryListUrl = FC.apiSwitch "/content/country_list.json",
  FC.apiUrl "~#{FC.metrics.hasBrands}",
      limit: 10

gapAsPercentUrl = (country) -> 
  FC.apiSwitch "/content/#{country}.json",
    FC.apiUrl "~#{FC.metrics.suppliersMap.gap}+Answer",
        limit: 0
        filter:
          country: country
          year: "latest"

livingWageGapDonut = (country) ->
    "<div class='col-sm-6 col-md-4 col-lg-3'><div class='row d-flex justify-content-center'><div class='row col-12 justify-content-center p-4'><div class='chart-wrapper vega-embed' id='#{country.toLowerCase()}-donut-chart'></div></div><div class='col-12 display-5 text-uppercase text-center'>#{country}</div></div></div>"

buildDonutViz = (el, spec, actions) ->
  actions ||= false
  vegaEmbed el, spec,
    renderer: "svg"
    hover: true
    actions: actions

donutChart = (country, colors, values, domain) ->
  tagId = "#{country}-donut-chart"
  $.ajax(url: "/content/donut.json", dataType: "json").done (spec) ->
    spec["data"][0]["url"] = gapAsPercentUrl country
    spec["scales"][0]["domain"] = domain
    buildDonutViz "##{tagId}", spec

$.extend FC,
  loadBrand: (companyId, year) ->
    $(".section-header > div, .result, .noResult").hide()
    brandBox companyId, year
    suppliersInfo companyId

  loadSubBrands: $.ajax(url: subBrandsUrl, dataType: "json").done (owned) ->
    $.each owned.items, (_i, brand) ->
      key = brand.subject_company
      FC.subBrands[key] ||= []
      FC.subBrands[key].push brand.object_company
      FC.subBrands[key].sort()

  formatPercent = (num) ->
    parseFloat(num).toFixed 0

  loadCountries: () -> $.ajax(url: countryListUrl, dataType: "json").done (countries) ->
    countries = countries.content
    countries.forEach (country) -> 
      $('#wage_gap_per_country').append(livingWageGapDonut(country))
      donutChart(country.toLowerCase(), ["#e5e5ea", "#ed40d9"])


  loadLivingWage: () -> $.ajax(url: livingWageUrl, dataType: "json").done (scores) ->
    totalItems = scores.items.length
    eItems = (scores.items.filter (item) -> item.value is 'E').length

    percentage = parseFloat((eItems / totalItems) * 100).toFixed(1);
    document.getElementById("living-wage-percentage").textContent = percentage + "%"

preparePopovers = () ->
  $('[data-toggle="popover"]').popover()

prepareFlipCards = () ->
  $("body").on "click", ".flip-card", ->
    $(this).toggleClass("flipped")

$(document).ready ->
  searchBox()
  prepareFlipCards()
  preparePopovers()

  params = new URLSearchParams(window.location.search)
  if params.has "q"
    FC.loadBrand params.get("q"), params.get("year")
  else
    FC.loadLivingWage() if $("#living-wage-percentage")[0];
    FC.loadCountries() if $("#wage_gap_per_country")[0];
    brandsTable()
