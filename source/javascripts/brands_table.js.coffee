# @return [{ name: name, metric_id1: val, metric_id2: val ...}]
FC.companies = (data) ->
  companies = {}

  $.each data.companies, (id, name) ->
    companies[id] = { name: name }

  $.each data.answers, (_id, hash) ->
    companies[hash["company"]][hash["metric"]] = hash["value"]

  companies


FC.companyTable = (data, table, columnMap, metricMap) ->
  @data = data
  @table = table
  @columnMap = columnMap
  @metricMap = metricMap

  @render = () ->
    return unless @table[0]

    @tbody = @table.children "tbody"
    @addRows()
    @table.DataTable autoWidth: false

  @addRows = () ->
    t = this
    $.each FC.companies(@data), (companyId, companyHash) ->
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
