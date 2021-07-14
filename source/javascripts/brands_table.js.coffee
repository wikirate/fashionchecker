# @return [{ name: name, metric_id1: val, metric_id2: val ...}]
FC.companies = (data) ->
  companies = {}

  $.each data.companies, (id, name) ->
    companies[id] = { name: name }

  $.each data.answers, (_id, hash) ->
    companies[hash["company"]][hash["metric"]] = hash["value"]

  companies

#companyLink = (name, id) ->
#  "<a class='red' target='_wikirate' href=\"#{LINK_TARGET_HOST}/~#{id}\">#{name}</a>"


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
    $.each FC.companies(@data), (_id, companyHash) ->
      t.addRow companyHash

  @addRow = (hash) ->
    t = this
    cells = []
    $.each @columnMap, (key, fn) ->
      key = t.metricMap[key] unless key == "name"
      val = hash[key] || "-"
      unless fn == 1 || val == "-"
        val = fn val
      cells.push t.td(val)

    @tbody.append "<tr>#{cells.join()}</tr>"

  @td = (cell_content)->
    "<td>" + cell_content + "</td>"

  @render()
