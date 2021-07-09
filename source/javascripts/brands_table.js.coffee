# @return [{ name: name, metric_id1: val, metric_id2: val ...}]
Companies = (data) ->
  companies = {}

  $.each data.companies, (id, name) ->
    companies[id] = { name: name }

  $.each data.answers, (_id, hash) ->
    companies[hash["company"]][hash["metric"]] = hash["value"]

  companies


FC.CompanyTable = (data, tableSelector, metricMap) ->
  @data = data
  @table = $(tableSelector)
  @metricMap = metricMap

  @render = () ->
    return unless @table[0]

    @tbody = @table.children "tbody"
    @addRows()
    @table.DataTable()

  @addRows = () ->
    t = this
    $.each Companies(@data), (_id, companyHash) ->
      t.addRow companyHash

  @addRow = (hash) ->
    t = this
    cells = [@td hash["name"]]
    $.each @metricMap, (_key, id) ->
      cells.push t.td(hash[id])

    @tbody.append "<tr>" + cells.join() + "</tr>"

  @td = (cell_content)->
    "<td>" + cell_content + "</td>"

  @render()
