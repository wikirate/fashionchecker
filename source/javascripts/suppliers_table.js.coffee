metricsMap = FC.metrics.suppliersMap
headquartersMetricId = metricsMap["headquarters"]
wageMetricId = metricsMap["average"]

euros = (num) ->
  "<td class='lighter-blue-bg'>€#{parseFloat(num, 10).toFixed 2}</td>"

percent = (num) ->
  "<td class='lighter-blue-bg'>#{parseFloat(num).toFixed 1}%</td>"

suppliersColumnMap =
  name: (val, companyId) ->
    "<td><a href='#{FC.wikirateUrl companyId}'>#{val}</a></td>"

  headquarters: 1
  average: euros
  gap: percent
  num_workers: 1

  female: (val, _id, companyHash) ->
    male = companyHash[metricsMap['male']] || "-"
    other = companyHash[metricsMap['other']] || "-"
    "<td>#{val}/#{male}/#{other}</td>"

  permanent: (val, _id, companyHash) ->
    temporary = companyHash[metricsMap['temporary']] || "-"
    "<td>#{val}/#{temporary}</td>"

supplierURL = (companyId, metricId, view, answer) ->
  filter =
    metric_id: metricId
    relationship:
      company_id: companyId
      metric_id: FC.metrics.supplierId
  filter["answer"] = answer if answer

  FC.apiUrl "Answer/#{view}", limit: 0, filter: filter

suppliersTable = (companyId) ->
  template = new FC.util.templater "#suppliers"
  answer_filter = metric_id: wageMetricId
  url = supplierURL companyId, Object.values(metricsMap), "compact", answer_filter
  $.ajax(url: url, dataType: "json").done (data) ->
    companies = suppliersWithWageData data
    table = template.current.find "#suppliersTable"
    FC.company.table companies, table, suppliersColumnMap, metricsMap
    template.publish()


buildViz = (spec) ->
  vegaEmbed ".result .supplierMap", spec,
    renderer: "svg"
    hover: true


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
    $.ajax url: "content/dorling.json", dataType: "json"
    $.ajax url: dataUrl, dataType: "json"
  ).done (spec, answers) ->
    spec = spec[0]
    data = spec["data"][0]
    delete data["url"]
    data["values"] = answers[0]

    buildViz spec

suppliersWithWageData = (data) ->
  withWage = []
  $.each FC.company.hash(data), (_i, supplier) ->
    if supplier[metricsMap["average"]] || supplier[metricsMap["gap"]]
      withWage.push supplier
  withWage

window.suppliersInfo = (companyId) ->
    suppliersViz companyId
    suppliersTable companyId
