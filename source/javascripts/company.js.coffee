# @return [{ name: name, metric_id1: val, metric_id2: val ...}]
FC.company = {
  hash: (data) ->
    companies = {}

    $.each data.companies, (id, name) ->
      companies[id] = {name: name}

    $.each data.answers, (_id, hash) ->
      companies[hash["company"]][hash["metric"]] = hash["value"]

    companies
}

FC.company.table = (data, tag, columnMap, metricMap) ->
  @data = data
  @tag = tag
  @columnMap = columnMap
  @metricMap = metricMap

  @render = () ->
    return unless @tag[0]

    @tbody = @tag.children "tbody"
    @addRows()
    @tag.DataTable autoWidth: false, pagingType: "numbers", language: FC.lang

  @addRows = () ->
    t = this
    $.each @data, (companyId, companyHash) ->
      t.addRow companyId, companyHash

  @addRow = (companyId, companyHash) ->
    t = this
    cells = []
    $.each @columnMap, (key, fn) ->
      key = t.metricMap[key] unless key == "name"
      val = companyHash[key] || "-"
      if fn == 1 || val == "-"
        val = t.td val
      else
        val = fn val, companyId, companyHash
      cells.push val

    @tbody.append "<tr>#{cells.join()}</tr>"

  @td = (cell_content)->
    "<td>" + cell_content + "</td>"

  @render()
