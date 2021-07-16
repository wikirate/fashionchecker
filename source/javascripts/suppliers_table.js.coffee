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

supplierURL = (companyId, view) ->
  FC.apiUrl "Answer/#{view}",
    limit: 0
    filter:
      metric_id: Object.values(metricsMap)
      relationship:
        company_id: companyId
        metric_id: FC.metrics.supplierId

suppliersTable = (companyId) ->
  $.ajax(url: supplierURL(companyId, "compact"), dataType: "json").done (data) ->
    companies = suppliersWithWageData data
    template = new FC.util.templater "#suppliers"
    table = template.current.find "#suppliersTable"
    FC.company.table companies, table, suppliersColumnMap, metricsMap
    template.publish()

suppliersViz = (companyId) ->
  url = supplierURL companyId, "answer_list"
  $.ajax(url: url, dataType: "json").done (data) ->
    FC.vizUrl = url
    FC.vizData = data


suppliersWithWageData = (data) ->
  withWage = []
  $.each FC.company.hash(data), (_i, supplier) ->
    if supplier[metricsMap["average"]] || supplier[metricsMap["gap"]]
      withWage.push supplier
  withWage

window.suppliersInfo = (companyId) ->
    suppliersViz companyId
    suppliersTable companyId
