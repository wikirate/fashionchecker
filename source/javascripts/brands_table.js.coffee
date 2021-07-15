commitment = (val) ->
  el = $('<img class="littleSmiley"/>')
  FC.util.image.commitment(el, val)
  "<td data-sort='#{val}' title='#{val}'>#{el.prop 'outerHTML'}</td>"

transparencyStars = (val) ->
  el = $("._transparencyTemplate").clone()
  FC.util.image.transparency(el, val)
  "<td data-sort='#{val}' title='#{val}'>#{el.html()}</td>"

subBrandsList = (brand) ->
  subs = FC.subBrands[brand]
  return "" unless subs
  subs = subs.join ', '
  "<span class='subBrandsList' title='#{subs}'>(#{subs})</span>"

brandLink = (val, companyId) ->
  "<td><a href='#{FC.profilePath companyId}'>#{val}</a> #{subBrandsList val}</td>"

livingWageLetter = (val) ->
  "<td class='livingWageLetter livingWage-#{val}'>#{val}</td>"

brandsColumnMap =
  name: brandLink
  headquarters: 1
  transparency_score: transparencyStars
  living_wages_score: livingWageLetter
  action_plan: commitment
  public_commitment: commitment
  isolating_labor: commitment

brandAnswersUrl = FC.apiSwitch "content/brand_answers.json",
  FC.apiUrl "Answer/compact",
    limit: 0
    filter:
      company_group: FC.companyGroup,
      metric_id: $.map(Object.keys(brandsColumnMap), (fld, _i) ->
        FC.metrics.brandsMap[fld]
      )
      year: "latest"

window.brandsTable = () ->
  $.when(
    $.ajax url: brandAnswersUrl, dataType: "json"
    FC.loadSubBrands
  ).done (brands, _owned) ->
    FC.company.table brands[0], $("#brandsTable"), brandsColumnMap, FC.metrics.brandsMap
