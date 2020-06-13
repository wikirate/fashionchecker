
$.fn.select2.defaults.set("theme", "bootstrap4")

API_HOST = "https://dev.wikirate.org"
## "http://127.0.0.1:3000" # "https://staging.wikirate.org

LINK_TARGET_HOST = "https://wikirate.org"
METRIC_URL = "#{API_HOST}/:commons_supplier_of"
BRAND_LIST_URL = "#{API_HOST}/company.json?view=brands_select2"

EMPTY_RESULT = "<div class='alert alert-info'>no result</div>"

$(document).ready ->
  $("._brand-search").select2
    placeholder: "search for brand"
    allowClear: true
    #data: [{"id":"8994","text":"Google"},
    #  {"id":"18215","text":"Zara > Inditex"},
    #  {"id":"1215","text":"Zalando"},
    #  {"id":"1215","text":"Inditex"},
    #  {"id":"1578","text":"Apple"}]
    ajax:
      url: BRAND_LIST_URL
      dataType: "json"

  $("body").on "change", "#brand-select", ->
    selected = $("#brand-select").select2("data")
    if (selected.length > 0)
      company_id = selected[0].id
      loadBrandInfo(company_id)

  $("body").on "change", "#brand-redirect", ->
    selected = $("#brand-redirect").select2("data")
    if (selected.length > 0)
      company_id = selected[0].id
      window.location.href = "/brand-profile.html?q=#{company_id}"

  $("body").on 'shown.bs.collapse', ".collapse", ->
    updateSuppliersTable($(this))

  params = new URLSearchParams(window.location.search)

  unless params.get('embed-info') == "show"
    $("._embed-info").hide()

  if params.has('background')
    $('body').css("background", params.get("background"))

  if params.has('q')
    loadBrandInfo(params.get("q"))
    # $("#brand-select").val params.get("q")
    # $("#barnd-select").trigger "change"


loadBrandInfo = (company_id) ->
  $.ajax(url: brandInfoURL(company_id), dataType: "json").done((data) ->
    $output = $("#result")
    $output.empty()
    new BrandInfo(data).render($output)
  )

brandInfoURL = (company_id) ->
  "#{API_HOST}/~#{company_id}.json?view=transparency_info"
