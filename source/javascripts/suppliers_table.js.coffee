metricsMap = FC.metrics.suppliersMap

euros = (num) ->
  "<td>€#{parseFloat(num, 10).toFixed 2}</td>"

suppliersColumnMap =
  name: (val, companyId) ->
    "<td><a href='#{FC.wikirateUrl companyId}'>#{val}</a></td>"

  headquarters: 1
  average: euros
  gap: euros
  num_workers: 1

  female: (val, _id, companyHash) ->
    male = companyHash[metricsMap['male']] || "-"
    other = companyHash[metricsMap['other']] || "-"
    "<td>#{val}/#{male}/#{other}</td>"

  permanent: (val, _id, companyHash) ->
    temporary = companyHash[metricsMap['temporary']] || "-"
    "<td>#{val}/#{temporary}</td>"

supplierURL = (companyId, metricId, view) ->
  FC.apiUrl "Answer/#{view}",
    limit: 0
    filter:
      metric_id: metricId
      relationship:
        company_id: companyId
        metric_id: FC.metrics.supplierId

suppliersTable = (companyId) ->
  url = supplierURL companyId, Object.values(metricsMap), "compact"
  $.ajax(url: url, dataType: "json").done (data) ->
    companies = suppliersWithWageData data
    template = new FC.util.templater "#suppliers"
    table = template.current.find "#suppliersTable"
    FC.company.table companies, table, suppliersColumnMap, metricsMap
    template.publish()

headquartersMetricId = FC.metrics.suppliersMap["headquarters"]

buildViz = (spec) ->
  view = new vega.View vega.parse(spec),
    renderer: 'svg'
    container: '#supplierViz',
    hover: true

  view.runAsync();

suppliersViz = (companyId) ->
  dataUrl = supplierURL companyId, headquartersMetricId, "answer_list"

#  .done (spec) ->
#    spec["data"][0]["url"] = dataUrl
#


  $.when(
    $.ajax(url: "content/dorling.json", dataType: "json")
    $.ajax(url: dataUrl, dataType: "json")
  ).done (spec, answers) ->
    spec = spec[0]
    data = spec["data"][0]
    delete data["url"]
    data["values"] = answers[0]
    buildViz(spec)





suppliersWithWageData = (data) ->
  withWage = []
  $.each FC.company.hash(data), (_i, supplier) ->
    if supplier[metricsMap["average"]] || supplier[metricsMap["gap"]]
      withWage.push supplier
  withWage

window.suppliersInfo = (companyId) ->
    suppliersViz companyId
    suppliersTable companyId
