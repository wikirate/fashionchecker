$.fn.select2.defaults.set("theme", "bootstrap")

API_HOST = "https://staging.wikirate.org"
LINK_TARGET_HOST = "https://wikirate.org"
METRIC_URL = "#{API_HOST}/:commons_supplier_of"
COUNTRY_OPTIONS_URL = "#{API_HOST}/jurisdiction.json?view=select2"

EMPTY_RESULT = "<div class='alert alert-info'>no result</div>"

$(document).ready ->
  $("#country-select").select2
    placeholder: "Country"
    allowClear: true
    ajax:
      url: COUNTRY_OPTIONS_URL,
      dataType: "json"

  $("body").on "change", "._factory-search", ->
    updateFactoryList()

  $("body").on 'shown.bs.collapse', ".collapse", ->
    updateSuppliedCompaniesTable($(this))

  params = new URLSearchParams(window.location.search)

  unless params.get('embed-info') == "show"
    $("._embed-info").hide()

  if params.has('background')
    $('body').css("background", params.get("background"))



updateFactoryList = ->
  $.ajax(url: factorySearchURL(), dataType: "json").done((data) ->
    header = "Found #{data.length} factor#{if data.length == 1 then "y" else "ies"}"
    $("._result-header").text(header)
    $accordion = $("#search-result-accordion")
    $accordion.empty()
    if data.length == 0
      # $accordion.append(EMPTY_RESULT)
    else
      for factory in data
        addFactoryCard(factory, $accordion)
  )

updateSuppliedCompaniesTable = ($collapse) ->
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

factorySearchURL = ->
  keyword = $("#keyword-input").val()
  selected = $("#country-select").select2("data")
  if (selected.length > 0)
    country_code = selected[0].id
  "#{API_HOST}/company.json?view=search_factories&keyword=#{keyword}&country_code=#{country_code}"

suppliedCompaniesSearchURL = (elem) ->
  :factory = elem.data("company-url-key")
  "#{METRIC_URL}+#{factory}.json?view=related_companies_with_year"

addFactoryCard = (factory, $accordion) ->
  $card = $(".card.template._factory-item").clone()
  collapse_class = "id-#{factory.id}"
  $card.removeClass("template")
       .find("a.card-header").text(factory.name)
                             .attr("href", "div#search-result-accordion .#{collapse_class}")
                             .attr("aria-controls", "search-result-accordion .#{collapse_class}")
  $card.find(".collapse").attr("data-company-url-key", factory.url_key)
                         .addClass(collapse_class)
  $accordion.append($card)

addRow = (tbody, company, year) ->
  tbody.append $("<tr><td>#{companyLink(company)}</td><td>#{year.join(", ")}</td></tr>")

companyLink = (company) ->
  "<a class='text-light' href=\"#{LINK_TARGET_HOST}/#{company}\">#{company}</a>"
