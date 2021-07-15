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

supplierURL = (companyId) ->
  FC.apiUrl "Answer/compact",
    limit: 0
    filter:
      relationship:
        company_id: companyId
        metric_id: FC.metrics.supplierId
      metric_id: Object.values(metricsMap)

suppliersTable = (companies) ->
  template = new FC.util.templater "#suppliers"
  table = template.current.find "#suppliersTable"
  FC.company.table companies, table, suppliersColumnMap, metricsMap
  template.publish()

suppliersViz = (companies) ->
  "hi"


suppliersWithWageData = (companies) ->
  withWage = []
  $.each companies, (_i, supplier) ->
    if supplier[metricsMap["average"]] || supplier[metricsMap["gap"]]
      withWage.push supplier
  withWage

window.suppliersInfo = (companyId) ->
  $.ajax(url: supplierURL(companyId), dataType: "json").done (data) ->
    companies = FC.company.hash data
    suppliersViz companies
    suppliersTable suppliersWithWageData(companies)
