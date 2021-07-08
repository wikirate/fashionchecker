$.fn.select2.defaults.set("theme", "bootstrap4")

API_HOST = "https://wikirate.org"
METRIC_URL = "#{API_HOST}/:commons_supplier_of"
BRAND_LIST_URL = "#{API_HOST}/company.json?view=brands_select2"
BRANDS_ANSWERS_URL = "content/brand_answers.json"

window.FC = {}

$(document).ready ->
  $.ajax(url: BRAND_LIST_URL, dataType: "json").done (data) ->
    $("._brand-search").select2(
      placeholder: "search for brand"
      allowClear: true
      data: data["results"]
    ).val(null).trigger('change')

  $("body").on "change", "._brand-search", ->
    selected = $("._brand-search").select2("data")
    if (selected.length > 0)
      company_id = selected[0].id
      if $(this).data("redirect")?
        redirectBrandSearch company_id
      else
        loadBrandInfo company_id

  $("body").on 'shown.bs.collapse', ".collapse", ->
    updateSuppliersTable($(this))

  $("body").on "click", ".flip-card", ->
    $(this).toggleClass("flipped")

  params = new URLSearchParams(window.location.search)

  unless params.get('embed-info') == "show"
    $("._embed-info").hide()

  if params.has('background')
    $('body').css("background", params.get("background"))

  if params.has('q')
    loadBrandInfo params.get("q")

  loadBrandsTable()

loadBrandsTable = () ->
  $.ajax(url: BRANDS_ANSWERS_URL, dataType: "json").done((data) ->
    table = new FC.BrandsTable data,"#brands-table"
    table.render()
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

updateSuppliersTable = ($collapse) ->
  loadOnlyOnce $collapse, ($collapse) ->
    $.ajax(url: suppliedCompaniesSearchURL($collapse), dataType: "json").done((data) ->
      tbody = $collapse.find("tbody")
      tbody.find("tr.loading").remove()
      for company, year of data
        addRow tbody, company, year
    )

loadOnlyOnce = ($target, load) ->
  return if $target.hasClass("_loaded")
  $target.addClass("_loaded")
  load($target)

suppliedCompaniesSearchURL = (elem) ->
  factory = elem.data("company-url-key")
  "#{METRIC_URL}+#{factory}.json?view=related_companies_with_year"
