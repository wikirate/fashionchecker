$.fn.select2.defaults.set("theme", "bootstrap4")

window.FC = {
  wikirate_api_host: "https://dev.wikirate.org"
  wikirate_link_target: "https://wikirate.org"
  wikirate_auth: "wikirate:wikirat"

  supplier_metric_id: 2929009 # Commons+Supplied By
  supplier_project_id: 7611147
  brand_project_id: 7611143

  brands_metric_map: {
    country: 6126450
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
  }

  brands_table_fields: [
    "country", "transparency_score", "living_wages_score",
    "action_plan", "public_commitment", "isolating_labor"
  ]

  suppliers_metric_map: {
    country: 6126450
    female: 3233894
    male: 3233883
    other: 6019448
    permanent: 6019621
    temporary: 6019632
    average: 6019687
    gap: 7347357
    cba: 6020927
    know_brand: 6019511
    pregnancy: 6019786
  }

  score: {
    living_wage: {
      "E": 1
      "D": 2
      "C": 3
      "B": 4
      "A": 5
    }
    transparency: {
      "0.0": 1
      "2.5": 2
      "5.0": 3
      "7.5": 4
      "10.0": 5
    }
    commitment: {
      "No": 1
      "Partial": 2
      "Yes": 3
      "Yes, Other": 3
      "Yes, ACT": 3
      "Yes, Fair Wear Foundation": 3
    }
  }
}

FC.apiUrl = (path, query) ->
  "#{FC.wikirate_api_host}/#{path}.json?" + $.param(query)

$.extend FC,
  brandsUrl: FC.apiUrl(":filling_the_gap_group+Company", item: "nucleus")

  subBrandsUrl: FC.apiUrl(":commons_has_brands+Relationship_Answer",
    filter: { company_group: ":filling_the_gap_group", year: "latest" }, limit: 500
  )

  brandAnswersUrl: FC.apiUrl("Answer/compact",
    filter: { project: "Fashion Checker Brand Profile Metrics" }, limit: 0)
#    filter: { company_group: ":filling_the_gap_group", metrics: }

# pass basic authentication on WikiRate dev/staging servers
if FC.wikirate_auth
  $.ajaxSetup(
    beforeSend: (xhr) ->
      xhr.setRequestHeader "Authorization", "Basic " + btoa(FC.wikirate_auth)
  )


$(document).ready ->
  prepareSearch()
  prepareFlipCards()

  params = new URLSearchParams(window.location.search)
  if params.has "q"
    loadBrand params.get "q"
  else
    loadBrandsTable()

#~~~~~~~~ FLIP CARDS ~~~~~~~~~~

prepareFlipCards = () ->
  $("body").on "click", ".flip-card", ->
  $(this).toggleClass("flipped")

#~~~~~~~~ SEARCH ~~~~~~~~~~

prepareSearch = () ->
  loadSearchOptions()
  activateSearch()

loadSearchOptions = () ->
  $.when(
    $.ajax(url: FC.brandsUrl, dataType: "json"),
    $.ajax(url: FC.subBrandsUrl, dataType: "json")
  ).done (main, owned) ->
    $("._brand-search").select2(
      placeholder: "search for brand"
      allowClear: true
      data: searchOptions(main, owned)
    ).val(null).trigger('change')

searchOptions = (main, owned) ->
  opts = []
  lookup = {}
  $.each main[0].items, (_i, brand) ->
    opts.push { id: brand.id, text: brand.name }
    lookup[brand.name] = brand.id
  $.each owned[0].items, (_i, brand) ->
    opts.push { id: lookup[brand.subject_company], text: brand.object_company }
  opts

activateSearch = () ->
  $("body").on "change", "._brand-search", ->
    selected = $("._brand-search").select2("data")
    if (selected.length > 0)
      company_id = selected[0].id
      if $(this).data("redirect")?
        redirectSearch company_id
      else
        loadBrand company_id

redirectSearch = (company_id) ->
  href = "/brand-profile.html?q=#{company_id}"
  current = window.location.href
  if /(\/$|html)/.test current
    prefix = "."
  else
    prefix = current
  window.location.href = prefix + href

#~~~~~~~~ BRANDS ~~~~~~~~~~

brandsTableMap = ()->
  map = {}
  $.each FC.brands_table_fields, (_i, fld) ->
    map[fld] = FC.brands_metric_map[fld]
  map

loadBrand = (company_id) ->
  FC.brandBox company_id
  loadSuppliersTable company_id

loadBrandsTable = () ->
  $.ajax(url: FC.brandAnswersUrl, dataType: "json").done((data) ->
    FC.companyTable data, $("#brands-table"), brandsTableMap()
  )

loadSuppliersTable = (companyId) ->
  $.ajax(url: supplierURL(companyId), dataType: "json").done((data) ->
    template = new FC.templater "suppliers"
    table = template.current.find "#suppliersTable"
    FC.companyTable data, table, FC.suppliers_metric_map
    template.publish()
  )

supplierURL = (company_id) ->
  FC.apiUrl "Answer/compact",
    limit: 0,
    filter: {
      relationship: {
        company_id: company_id,
        metric_id: FC.supplier_metric_id
      },
      project_metric: "~#{FC.supplier_project_id}"
    }
