LINK_TARGET_HOST = "https://wikirate.org"

FIELDS = ["revenue", "location", "owned_by", "profit", "number_of_workers", "top_production_countries"]

class window.BrandInfo
  constructor: (@data) ->

  render: ($output) ->
    data = @data
    $card = $(".template._brand-item").clone()
    $card.removeClass("template")
    $card.find("#wikirate-link").attr("href", "#{LINK_TARGET_HOST}/~#{data.id}?filter%5Bwikirate_topic%5D%5B%5D=Filling%20the%20Gap")
    $card.find("#title").text(data.holding)
    for index, name of FIELDS
      $card.find("._#{name}").text(data[name])
    $card.find("#worker-count").text(data.number_of_workers)
    selectImage($card.find("._living-wage-score"), "wage_score", data.scores.living_wage)
    selectImage($card.find("._transparency-score"), "transparency_score", data.scores.transparency)
    commitmentScore($card, "public-commitment", data.scores.commitment.public_commitment)
    commitmentScore($card, "action-plan", data.scores.commitment.action_plan)
    commitmentScore($card, "action-plan", data.scores.commitment.isolating_labour_cost)
    $card.find("._commitment-total-score").text(data.scores.commitment.total)
    $card.find("#living-wage-score").text(data.scores.living_wage)
    $card.find("#factory-count").text(data.suppliers.length)

    for index, brand of data.brands
      addBrand(brand, $card)
    for index, supplier of data.suppliers
      addSupplier(supplier, $card)
    $output.append($card)

  commitmentScore = ($el, name, value) ->
    $el.find("._#{name}").text(value)
    value = "Yes" if value.includes("Yes")
    selectImage($el.find("._#{name}-smiley"), "smiley", value)

  selectImage = ($el, folder, score) ->
    $el.attr("src", "images/#{folder}/#{score}.png")

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
    row = "<tr>"
    row += newRow companyLink(supplier.name), "medium-blue-bg"
    row += newRow("#{supplier.workers_by_gender.female || "-"} / #{supplier.workers_by_gender.male || "-" } / #{supplier.workers_by_gender.other || "-"}")
    row += newRow("#{supplier.workers_by_contract.permanent} / #{supplier.workers_by_contract.temporary}")
    row += newRow supplier["average_net_wage"], "other-blue-bg"
    row += newRow supplier["workers_have_cba"], "other-blue-bg"
    for index, property of ["workers_know_brand", "workers_get_pregnancy_leave"]
      row += newRow supplier[property]
    row += "</tr>"
    tbody.append $(row)


  newRow = (content, css_class) ->
    if (content == null)
      content = "-"
    css_class = if css_class? then " class='#{css_class}'" else ""
    "<td#{css_class}>#{content}</td>"

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

  companyLink = (company) ->
    "<a class='text-red' href=\"#{LINK_TARGET_HOST}/#{company}\">#{company}</a>"

exports.BrandInfo = BrandInfo