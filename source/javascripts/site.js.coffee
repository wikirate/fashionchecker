$.fn.select2.defaults.set("theme", "bootstrap4")

wikirateApiHost = "https://wikirate.org"
wikirateApiAuth = null

# wikirateApiHost = "https://dev.wikirate.org"
# wikirateApiAuth = "wikirate:wikirat"
wikirateApiMode = "cached" # anything but "cached" means live

wikirateLinkTarget = "https://wikirate.org"

# pass basic authentication on WikiRate dev/staging servers
if wikirateApiAuth
  $.ajaxSetup
    beforeSend: (xhr) ->
      xhr.setRequestHeader "Authorization", "Basic " + btoa(wikirateApiAuth)

window.FC =
  companyGroup: ":filling_the_gap_group"

  metrics:
    suppliedBy: 2929009
    supplierOf: 2929015

    brandsMap:
      headquarters: 6126450
      twitter_handle: 6140253

      transparency_score: 5780639
      transparency_key: 6261816
      living_wages_score: 5990097
      living_wages_key: 6261809

      public_commitment: 5780757
      action_plan: 5768881
      isolating_labor: 5768917

      revenue: 5780267
      profit: 5780278
      top_3_production_countries: 5768935

    suppliersMap:
      headquarters: 6126450
      female: 3233894
      male: 3233883
      other: 6019448
      num_workers: 4780588
      permanent: 6019621
      temporary: 6019632
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

$.extend FC,
  apiSwitch: (cached, live) ->
    if wikirateApiMode == "cached"
      cached
    else
      live

  apiUrl: (path, query) ->
    "#{wikirateApiHost}/#{path}.json?" + $.param(query)

  profilePath: (companyId) ->
    "brand-profile.html?q=#{companyId}"

  wikirateUrl: (companyId) ->
    "#{wikirateLinkTarget}/~#{companyId}?" +
      $.param
        contrib: "N"
        filter:
          wikirate_topic: "Filling the Gap"

subBrandsUrl = FC.apiSwitch "/content/sub_brands.json",
  FC.apiUrl "~#{FC.metrics.suppliedBy}+Relationship_Answer",
    limit: 500
    filter:
      company_group: FC.companyGroup
      year: "latest"

$.extend FC,
  loadBrand: (companyId) ->
    brandBox companyId
    suppliersInfo companyId

  loadSubBrands: $.ajax(url: subBrandsUrl, dataType: "json").done (owned) ->
    $.each owned.items, (_i, brand) ->
      key = brand.subject_company
      FC.subBrands[key] ||= []
      FC.subBrands[key].push brand.object_company
      FC.subBrands[key].sort()

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
    FC.loadBrand params.get "q"
  else
    brandsTable()
