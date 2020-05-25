$.fn.select2.defaults.set("theme", "bootstrap")

API_HOST = "https://dev.wikirate.org"
## "http://127.0.0.1:3000" # "https://staging.wikirate.org

LINK_TARGET_HOST = "https://wikirate.org"
METRIC_URL = "#{API_HOST}/:commons_supplier_of"
BRAND_LIST_URL = "#{API_HOST}/company.json?view=brands_select2"

EMPTY_RESULT = "<div class='alert alert-info'>no result</div>"

$(document).ready ->
  $("#brand-select").select2
    placeholder: "Brand"
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
    loadBrandInfo()

  $("body").on 'shown.bs.collapse', ".collapse", ->
    updateSuppliersTable($(this))

  params = new URLSearchParams(window.location.search)

  unless params.get('embed-info') == "show"
    $("._embed-info").hide()

  if params.has('background')
    $('body').css("background", params.get("background"))


loadBrandInfo = ->
  $.ajax(url: brandInfoURL(), dataType: "json").done((data) ->
    $output = $("#result")
    $output.empty()
    showBrandInfo(data, $output)
  )

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

brandInfoURL = ->
  selected = $("#brand-select").select2("data")
  if (selected.length > 0)
    company_id = selected[0].id
  "#{API_HOST}/~#{company_id}.json?view=transparency_info"

suppliedCompaniesSearchURL = (elem) ->
  factory = elem.data("company-url-key")
  "#{METRIC_URL}+#{factory}.json?view=related_companies_with_year"

showBrandInfo = (data, $output) ->
  $card = $(".template._brand-item").clone()
  collapse_class = "id"
  $card.removeClass("template")
  $card.find("#wikirate-link").attr("href", "#{LINK_TARGET_HOST}/~#{data.id}?filter%5Bwikirate_topic%5D%5B%5D=Filling%20the%20Gap")
  $card.find("#title").text(data.holding)
  $card.find("#location").text(data.location)
  $card.find("#worker-count").text(data.number_of_workers)
  $card.find("#transparency-score").text(data.scores.transparency)
  $card.find("#commitment-score").text(data.scores.commitment.total)
  $card.find("#living-wage-score").text(data.scores.living_wage)
  $card.find("#factory-count").text(data.suppliers.length)
  for index, brand of data.brands
    addBrand(brand, $card)
  for index, supplier of data.suppliers
    addSupplier(supplier, $card)
  $output.append($card)

showInfo = ($container, selector, content) ->
  if (content == null)
    $container.find(selector).text("-")
  else
    $container.find(selector).text(content)

addBrand = (brand, $container) ->
  $container.find("#brands").append $("<li>#{brand}</li>")

addSupplier = (supplier, $output) ->
  tbody = $output.find("tbody")
  addRow(tbody, supplier)

addRow = (tbody, supplier) ->
  row = "<tr>#{newRow(companyLink(supplier.name))}" +
    newRow("#{supplier.workers_by_gender.female || "-"} / #{supplier.workers_by_gender.male || "-" } / #{supplier.workers_by_gender.other || "-"}") +
    newRow("#{supplier.workers_by_contract.permanent} / #{supplier.workers_by_contract.temporary}")
  for index, property of ["average_net_wage", "wage_gap", "workers_have_cba", "workers_know_brand", "workers_get_pregnancy_leave"]
    row += newRow supplier[property]
  row += "</tr>"
  tbody.append $(row)

newRow = (content) ->
  if (content == null)
    content = "-"
  "<td>#{content}</td>"

companyLink = (company) ->
  "<a class='text-red' href=\"#{LINK_TARGET_HOST}/#{company}\">#{company}</a>"
