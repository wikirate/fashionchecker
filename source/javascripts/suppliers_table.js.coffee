metricsMap = FC.metrics.suppliersMap

suppliersColumnMap = {
  name: (val, companyId) ->
    "<td><a href='#{FC.wikirateUrl companyId}'>#{val}</a></td>"

  headquarters: 1
  average: 1
  gap: 1
  num_workers: 1

  female: (val, _id, companyHash) ->
    male = companyHash[metricsMap['male']] || "-"
    other = companyHash[metricsMap['other']] || "-"
    "<td>#{val}/#{male}/#{other}</td>"

  permanent: (val, _id, companyHash) ->
    temporary = companyHash[metricsMap['temporary']] || "-"
    "<td>#{val}/#{temporary}</td>"
}

supplierURL = (companyId) ->
  FC.apiUrl "Answer/compact",
    limit: 0
    filter:
      relationship:
        company_id: companyId
        metric_id: FC.metrics.supplierId
      metric_id: Object.values(metricsMap)

window.suppliersTable = (companyId) ->
  $.ajax(url: supplierURL(companyId), dataType: "json").done((data) ->
    template = new FC.util.templater "suppliers"
    table = template.current.find "#suppliersTable"
    FC.company.table data, table, suppliersColumnMap, metricsMap
    template.publish()
  )
