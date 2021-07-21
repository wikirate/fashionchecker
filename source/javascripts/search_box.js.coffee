window.searchBox = () ->
  loadSearchOptions()
  activateSearch()

brandsUrl = FC.apiSwitch "/content/brands.json",
  FC.apiUrl "#{FC.companyGroup}+Company", item: "nucleus"

loadSearchOptions = () ->
  $.when(
    $.ajax url: brandsUrl, dataType: "json"
    FC.loadSubBrands
  ).done (main, owned) ->
    $("._brand-search").select2(
      placeholder: "search for brand"
      allowClear: true
      data: searchOptions(main, owned)
    ).val(null).trigger('change')

searchOptions = (main, owned) ->
  opts = []
  lookup = {}
  $.each main[0].items, (_i, brand) ->
    opts.push { id: brand.id, text: brand.name }
    lookup[brand.name] = brand.id
  $.each owned[0].items, (_i, brand) ->
    opts.push { id: lookup[brand.subject_company], text: brand.object_company }
  opts

activateSearch = () ->
  $("body").on "change", "._brand-search", ->
    selected = $("._brand-search").select2("data")
    if (selected.length > 0)
      company_id = selected[0].id
      if $(this).data("redirect")?
        redirectSearch company_id
      else
        FC.loadBrand company_id

redirectSearch = (companyId) ->
  href = FC.profilePath companyId
  current = window.location.href
  if /(\/$|html)/.test current
    prefix = "./"
  else
    prefix = current
  window.location.href = prefix + href
