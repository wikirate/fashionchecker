$.fn.select2.defaults.set("theme", "bootstrap4")

API_HOST = "https://wikirate.org"
METRIC_URL = "#{API_HOST}/:commons_supplier_of"
BRAND_LIST_URL = "#{API_HOST}/company.json?view=brands_select2"
BRANDS_ANSWERS_URL = "content/brand_answers.json"

BRANDS_METRIC_MAP = {
  location: 5456201,
  transparency_score: 5780639,
  living_wages_score: 5990097,
  action_plan: 5768881,
  policy_promise_score: 5780757,
  isolating_labor: 5768917
}

window.FC = {}

$(document).ready ->
  loadSearchOptions()

  $("body").on "change", "._brand-search", ->
    selected = $("._brand-search").select2("data")
    if (selected.length > 0)
      company_id = selected[0].id
      if $(this).data("redirect")?
        redirectBrandSearch company_id
      else
        loadBrandInfo company_id

  $("body").on "click", ".flip-card", ->
    $(this).toggleClass("flipped")

  params = new URLSearchParams(window.location.search)

  if params.has('q')
    loadBrandInfo params.get("q")

  loadBrandsTable()

loadSearchOptions = () ->
  $.ajax(url: BRAND_LIST_URL, dataType: "json").done (data) ->
    $("._brand-search").select2(
      placeholder: "search for brand"
      allowClear: true
      data: data["results"]
    ).val(null).trigger('change')

loadBrandsTable = () ->
  $.ajax(url: BRANDS_ANSWERS_URL, dataType: "json").done((data) ->
    FC.CompanyTable data,"#brands-table", BRANDS_METRIC_MAP
  )

redirectBrandSearch = (company_id) ->
  href = "/brand-profile.html?q=#{company_id}"
  current = window.location.href
  if /(\/$|html)/.test current
    prefix = "."
  else
    prefix = current
  window.location.href = prefix + href

loadBrandInfo = (company_id) ->
  $.ajax(url: brandInfoURL(company_id), dataType: "json").done((data) ->
    $output = $("#result")
    $output.empty()
    new BrandInfo(data).render($output)
    $('[data-toggle="popover"]').popover()
  )

brandInfoURL = (company_id) ->
  "#{API_HOST}/~#{company_id}.json?view=transparency_info"

