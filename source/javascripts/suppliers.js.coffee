metricsMap = FC.metrics.suppliersMap
headquartersMetricId = metricsMap["headquarters"]
wageMetricId = metricsMap["average"]

euros = (val, companyId, companyHash) ->
  console.log(val)
  "<td>#{parseInt(companyHash[metricsMap['average']][1])}</td><td>€#{parseFloat(val, 10).toFixed 2}</td>"

formatPercent = (num) ->
  parseFloat(num).toFixed 0

pieChart = (name, companyId, colors, values) ->
  tagId = "#{name}Pie-#{companyId}"
  $.ajax(url: "/content/pie.json", dataType: "json").done (spec) ->
    v = []
    $.each values, (key, val) ->
      v.push { name: FC.lang.suppliers_table[key], value: formatPercent(val) }
    spec["data"][0]["values"] = v
    spec["scales"][0]["range"] = colors
    buildViz "##{tagId}", spec
  sortVal = values[Object.keys(values)[0]]
  "<td data-sort='#{sortVal}'><div id='#{tagId}'></div></td>"

genderPieChart = (val, companyId, companyHash) ->
  pieChart "gender", companyId, ["#fb4922", "#970000", "#FFB000"],
    female: val,
    male: (companyHash[metricsMap['male']] || (remainder(val))),
    other: (companyHash[metricsMap['other']] || "0")

contractPieChart = (val, companyId) ->
  pieChart "contract", companyId, ["#ed40d9", "#fcc9fd"],
    migrant: val,
    nonmigrant: remainder(val)

remainder = (percent) ->
  if percent > 100
    0
  else
    100 - percent

gapPieChart = (val, companyId) ->
  pieChart "gap", companyId, ["#f9fe9c", "#000000"],
    paid: val,
    not_paid: remainder(val)

supplierWikirateLink = (val, companyId) ->
  "<td><a href='#{FC.companyUrl companyId}'>#{val}</a></td>"

suppliersColumnMap =
  name: supplierWikirateLink
  headquarters: 1
  average: euros
  gap: gapPieChart
  num_workers: 1

  female: genderPieChart
  migrant: contractPieChart

supplierURL = (companyId, metricId, view, answer) ->
  filter =
    year: "latest"
    metric_id: metricId
    relationship:
      company_id: companyId
      metric_id: FC.metrics.supplierOf
  filter["company_answer"] = answer if answer

  FC.apiUrl "Answer/#{view}", limit: 0, filter: filter

generateSuppliersTable = (template, data) ->
  companies = suppliersWithWageData data
  table = template.current.find "#suppliersTable"
  FC.company.table companies, table, suppliersColumnMap, metricsMap, false
  template.publish()

suppliersTableUrl = (companyId) ->
  supplierURL companyId, Object.values(metricsMap), "compact", metric_id: wageMetricId

suppliersTable = (companyId) ->
  template = new FC.util.templater "#suppliers"
  $.ajax(url: suppliersTableUrl(companyId), dataType: "json").done (data) ->
    if Object.keys(data.answers).length == 0
      template.noResult()
    else
      generateSuppliersTable template, data

buildViz = (el, spec, actions) ->
  actions ||= false
  vegaEmbed el, spec,
    renderer: "svg"
    hover: true
    actions: actions

suppliersVizSpec = (spec, values) ->
  spec = spec[0]

  # the answers data comprise the first data row in the dorling spec
  # this replaces their values
  data = spec.data[0]
  delete data.url
  data.values = values

  # add localization for supplier map legend title and tooltip text
  lang = FC.lang.supplier_map_viz
  spec.legends[0].title = lang.legend_title
  spec.marks[2].encode.enter.tooltip.signal += " + ' #{lang.tooltip_suppliers}'"

  spec

suppliersViz = (companyId) ->
  dataUrl = supplierURL companyId, headquartersMetricId, "answer_list"

  # the simpler approach is to add the answer_list url to the vega spec,
  # but that wasn't working on dev.wikirate.org, because of a problem with
  # basic auth (or CORS or something)

  #  $.ajax(url: "content/dorling.json", dataType: "json").done (spec) ->
  #    spec["data"][0]["url"] = dataUrl

  template = new FC.util.templater "#supplierViz"

  $.when(
    $.ajax url: "/content/dorling.json", dataType: "json"
    $.ajax url: dataUrl, dataType: "json"
  ).done (spec, answers) ->
    values = answers[0]
    if values.length == 0
      template.noResult()
    else
      buildViz ".result .supplierMap", suppliersVizSpec(spec, values), true
      template.publish()

suppliersWithWageData = (data) ->
  withWage = {}
  $.each FC.company.hash(data), (companyId, supplier) ->
    if supplier[metricsMap["average"]] || supplier[metricsMap["gap"]]
      withWage[companyId] = supplier
  withWage

window.suppliersInfo = (companyId) ->
    suppliersViz companyId
    suppliersTable companyId
