LINK_TARGET_HOST = "https://wikirate.org"

FIELDS = ["name", "revenue", "location", "owned_by", "profit", "number_of_workers", "top_production_countries"]

class window.BrandInfo
  constructor: (@data) ->

  render: ($output) ->
    data = @data
    $template = $(".template._brand-item").clone()
    $template.removeClass("template")

    $template.find("._wikirate-link").attr("href", wikirateUrl(data.id))
    
    for index, name of FIELDS
      $template.find("._#{name}").text(data[name])
    debugger
    selectImage($template.find("._living-wage-score"), "wage_score", data.scores.living_wage)
    selectImage($template.find("._transparency-score"), "transparency_score", data.scores.transparency)
    commitmentScore($template, "public-commitment", data.scores.commitment.public_commitment)
    commitmentScore($template, "action-plan", data.scores.commitment.action_plan)
    commitmentScore($template, "isolating-labour-cost", data.scores.commitment.isolating_labour_cost)
    $template.find("._commitment-total-score").text(data.scores.commitment.total)
    $template.find("#living-wage-score").text(data.scores.living_wage)
    $template.find("#factory-count").text(data.suppliers.length)

    for index, brand of data.brands
      addBrand(brand, $template)
    for index, supplier of data.suppliers
      addSupplier(supplier, $template)
    $output.append($template)

  commitmentScore = ($el, name, value) ->
    $el.find("._#{name}").text(value)
    value = "Yes" if value.includes("Yes")
    selectImage($el.find("._#{name}-smiley"), "smiley", value)

  selectImage = ($el, folder, score) ->
    $el.attr("src", "images/#{folder}/#{score}.png")

  replaceNull = (content) ->
    if (content == null) then "-" else content

  addBrand = (brand, $container) ->
    $container.find("#brands").append $("<li>#{brand}</li>")

  addSupplier = (supplier, $output) ->
    tbody = $output.find("tbody")
    addRow(tbody, supplier)

  addRow = (tbody, supplier) ->
    row = "<tr>"
    row += newRow companyLink(supplier.name), "medium-blue-bg"
    row += newRow(
      [supplier.workers_by_gender.female, supplier.workers_by_gender.male, supplier.workers_by_gender.other]
        .map(replaceNull).join(" / "))
    row += newRow(
      [supplier.workers_by_contract.permanent, supplier.workers_by_contract.temporary]
        .map(replaceNull).join(" / "))
    row += newRow supplier["average_net_wage"], "other-blue-bg"
    row += newRow supplier["wage_gap"], "other-blue-bg"
    for index, property of ["workers_have_cba", "workers_know_brand", "workers_get_pregnancy_leave"]
      row += newRow supplier[property]
    row += "</tr>"
    tbody.append $(row)


  newRow = (content, css_class) ->
    if (content == null)
      content = "-"
    css_class = if css_class? then " class='#{css_class}'" else ""
    "<td#{css_class}>#{content}</td>"

  companyLink = (company) ->
    "<a class='red' href=\"#{LINK_TARGET_HOST}/#{company}\">#{company}</a>"

  wikirateUrl = (company_id) ->
    "#{LINK_TARGET_HOST}/~#{company_id}?filter%5Bwikirate_topic%5D%5B%5D=Filling%20the%20Gap"