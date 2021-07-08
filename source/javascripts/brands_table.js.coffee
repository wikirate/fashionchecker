BRANDS_METRIC_IDS = {
  location: 5456201,
  transparency_score: 5780639,
  living_wages_score: 5990097,
  action_plan: 5768881,
  policy_promise_score: 5780757,
  isolating_labor: 5768917
}

# twitter: 6140253,


# @return [{ name: name, metric_id1: val, metric_id2: val ...}]
FC.Companies = (data) ->
  companies = {}

  $.each data.companies, (id, name) ->
    companies[id] = { name: name }

  $.each data.answers, (_id, hash) ->
    companies[hash["company"]][hash["metric"]] = hash["value"]

  companies

FC.BrandsTable = (data, tableSelector) ->
  @data = data
  @table = $(tableSelector)

  @render = () ->
    return unless @table[0]

    @tbody = @table.children "tbody"
    @addRows()
    @table.DataTable()

  @addRows = () ->
    t = this
    $.each FC.Companies(@data), (_id, companyHash) ->
      t.addRow companyHash

  @addRow = (hash) ->
    t = this
    cells = [@td hash["name"]]
    $.each BRANDS_METRIC_IDS, (_key, id) ->
      cells.push t.td(hash[id])

    @tbody.append "<tr>" + cells.join() + "</tr>"

  @td = (cell_content)->
    "<td>" + cell_content + "</td>"

  this
