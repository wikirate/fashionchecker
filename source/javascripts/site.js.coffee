$.fn.select2.defaults.set("theme", "bootstrap4")

window.FC = {
  wikirate_api_host: "https://dev.wikirate.org"
  wikirate_link_target: "https://wikirate.org"
  wikirate_auth: "wikirate:wikirat"

  supplier_metric_id: 2929009 # Commons+Supplied By

  brands_metric_map: {
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
  }

  brands_table_fields: [
    "headquarters", "transparency_score", "living_wages_score",
    "action_plan", "public_commitment", "isolating_labor"
  ]

  suppliers_metric_map: {
    headquarters: 6126450
    female: 3233894
    male: 3233883
    other: 6019448
    num_workers: 4780588
    permanent: 6019621
    temporary: 6019632
    average: 6019687
    gap: 7347357
    #    cba: 6020927
    #    know_brand: 6019511
    #    pregnancy: 6019786
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

  # STATIC URLS
  brandsUrl: "content/brands.json"
  subBrandsUrl: "content/sub_brands.json"
  brandAnswersUrl: "content/brand_answers.json"

  # LIVE URLS
  #  brandsUrl: FC.apiUrl(":filling_the_gap_group+Company", item: "nucleus")
  #
  #  subBrandsUrl: FC.apiUrl(":commons_has_brands+Relationship_Answer",
  #    limit: 500
  #    filter: { company_group: ":filling_the_gap_group", year: "latest" }
  #  )
  #
  #  brandAnswersUrl: FC.apiUrl("Answer/compact",
  #    limit: 0
  #    # filter: { project: "Fashion Checker Brand Profile Metrics" }
  #    filter:
  #      company_group: ":filling_the_gap_group",
  #      metric_id: $.map(FC.brands_table_fields, (fld, _i) ->
  #        FC.brands_metric_map[fld]
  #      )
  #  )

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

FC.subBrands = {}

FC.loadSubBrands = $.ajax(url: FC.subBrandsUrl, dataType: "json").done (owned) ->
  $.each owned.items, (_i, brand) ->
    key = brand.subject_company
    FC.subBrands[key] ||= []
    FC.subBrands[key].push brand.object_company
    FC.subBrands[key].sort()

loadSearchOptions = () ->
  $.when(
    $.ajax(url: FC.brandsUrl, dataType: "json"),
    FC.loadSubBrands
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

profileLink = (companyId) ->
  "/brand-profile.html?q=#{companyId}"

redirectSearch = (companyId) ->
  href = profileLink companyId
  current = window.location.href
  if /(\/$|html)/.test current
    prefix = "."
  else
    prefix = current
  window.location.href = prefix + href

#~~~~~~~~ BRANDS ~~~~~~~~~~

simpleCommitment = (val) ->
  el = $('<img class="littleSmiley"/>')
  FC.commitmentImage(el, val)
  "<td data-sort='#{val}' title='#{val}'>#{el.prop 'outerHTML'}</td>"

transparencyStars = (val) ->
  el = $("._transparencyTemplate").clone()
  FC.transparencyImage(el, val)
  "<td data-sort='#{val}' title='#{val}'>#{el.html()}</td>"

subBrandsList = (brand) ->
  subs = FC.subBrands[brand]
  return "" unless subs
  subs = subs.join ', '
  "<span class='subBrandsList' title='#{subs}'>(#{subs})</span>"

brandsColumnMap = {
  name: (val, companyId) ->
    "<td><a href='#{profileLink companyId}'>#{val}</a> #{subBrandsList val}</td>"
  headquarters: 1
  transparency_score: transparencyStars
  living_wages_score: 1
  action_plan: simpleCommitment
  public_commitment: simpleCommitment
  isolating_labor: simpleCommitment
}

loadBrand = (company_id) ->
  FC.brandBox company_id
  loadSuppliersTable company_id

loadBrandsTable = () ->
  $.when(
    $.ajax(url: FC.brandAnswersUrl, dataType: "json"),
    FC.loadSubBrands
  ).done (brands, owned) ->
  $.ajax(url: FC.brandAnswersUrl, dataType: "json").done((data) ->
    FC.companyTable data, $("#brandsTable"), brandsColumnMap, FC.brands_metric_map
  )

suppliersColumnMap = {
  name: (val, companyId) ->
    "<td><a href='#{FC.wikirateUrl companyId}'>#{val}</a></td>"

  headquarters: 1
  average: 1
  gap: 1
  num_workers: 1

  female: (val, _id, companyHash) ->
    male = companyHash[FC.suppliers_metric_map['male']] || "-"
    other = companyHash[FC.suppliers_metric_map['other']] || "-"
    "<td>#{val}/#{male}/#{other}</td>"

  permanent: (val, _id, companyHash) ->
    temporary = companyHash[FC.suppliers_metric_map['temporary']] || "-"
    "<td>#{val}/#{temporary}</td>"
}

loadSuppliersTable = (companyId) ->
  $.ajax(url: supplierURL(companyId), dataType: "json").done((data) ->
    template = new FC.templater "suppliers"
    table = template.current.find "#suppliersTable"
    FC.companyTable data, table, suppliersColumnMap, FC.suppliers_metric_map
    template.publish()
  )

supplierURL = (company_id) ->
  FC.apiUrl "Answer/compact",
    limit: 0
    filter:
      relationship:
        company_id: company_id
        metric_id: FC.supplier_metric_id
      metric_id: Object.values(FC.suppliers_metric_map)
