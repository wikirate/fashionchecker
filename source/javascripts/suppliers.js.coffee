metricsMap = FC.metrics.suppliersMap
headquartersMetricId = metricsMap["headquarters"]
wageMetricId = metricsMap["average"]

euros = (num) ->
  "<td>€#{parseFloat(num, 10).toFixed 2}</td>"

formatPercent = (num) ->
  parseFloat(num).toFixed 0

pieChart = (name, companyId, colors, values) ->
  tagId = "#{name}Pie-#{companyId}"
  $.ajax(url: "/content/pie.json", dataType: "json").done (spec) ->
    v = []
    $.each values, (key, val) ->
      v.push { name: key, value: formatPercent(val) }
    spec["data"][0]["values"] = v
    spec["scales"][0]["range"] = colors
    buildViz "##{tagId}", spec
  sortVal = values[Object.keys(values)[0]]
  "<td data-sort='#{sortVal}'><div id='#{tagId}'></div></td>"

genderPieChart = (val, companyId, companyHash) ->
  pieChart "gender", companyId, ["#fb4922", "#970000", "#FFB000"],
    female: val,
    male: (companyHash[metricsMap['male']] || "0"),
    other: (companyHash[metricsMap['other']] || "0")

contractPieChart = (val, companyId, companyHash) ->
  pieChart "contract", companyId, ["#ed40d9", "#fcc9fd"],
    permanent: val,
    temporary: (companyHash[metricsMap['temporary']] || "0")

gapPieChart = (val, companyId) ->
  not_paid =
    if val > 100
      0
    else
      100 - val

  pieChart "gap", companyId, ["#f9fe9c", "#000000"],
    "actual wage" : val,
    "wage gap" : not_paid

supplierWikirateLink = (val, companyId) ->
  "<td><a href='#{FC.wikirateUrl companyId}'>#{val}</a></td>"

suppliersColumnMap =
  name: supplierWikirateLink
  headquarters: 1
  average: euros
  gap: gapPieChart
  num_workers: 1

  female: genderPieChart
  permanent: contractPieChart

supplierURL = (companyId, metricId, view, answer) ->
  filter =
    metric_id: metricId
    relationship:
      company_id: companyId
      metric_id: FC.metrics.supplierOf
  filter["answer"] = answer if answer

  FC.apiUrl "Answer/#{view}", limit: 0, filter: filter

generateSuppliersTable = (template, data) ->
  companies = suppliersWithWageData data
  table = template.current.find "#suppliersTable"
  FC.company.table companies, table, suppliersColumnMap, metricsMap
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
  data = spec["data"][0]
  delete data["url"]
  data["values"] = values
  spec

suppliersViz = (companyId) ->
  dataUrl = supplierURL companyId, headquartersMetricId, "answer_list"

  # the simpler approach is to add the answer_list url to the vega spec,
  # but that wasn't working on dev.wikirate.org, because of a problem with
  # basic auth (or CORS or something)

  #  $.ajax(url: "content/dorling.json", dataType: "json").done (spec) ->
  #    spec["data"][0]["url"] = dataUrl

  template = new FC.util.templater "#supplierViz"
  template.publish()

  $.when(
    $.ajax url: "/content/dorling.json", dataType: "json"
    $.ajax url: dataUrl, dataType: "json"
  ).done (spec, answers) ->
    values = answers[0]
    if values.length == 0
      template.noResult()
    else
      buildViz ".result .supplierMap", suppliersVizSpec(spec, values), true

suppliersWithWageData = (data) ->
  withWage = {}
  $.each FC.company.hash(data), (companyId, supplier) ->
    if supplier[metricsMap["average"]] || supplier[metricsMap["gap"]]
      withWage[companyId] = supplier
  withWage

window.suppliersInfo = (companyId) ->
    suppliersViz companyId
    suppliersTable companyId
