window.brandBox = (company_id, year) ->
  @company_id = company_id
  @year = year || 2020
  @template = new FC.util.templater "#brandBox"

  @build = () ->
    @fillName()
    @readyYearLinks()
    @fillSimple()
    @fillEuro()
    @fillCommitments()
    @fillTranslations()
    @fillSubBrands()
    @livingWageImage()
    @transparency()
    @wikiRateLinks()
    @tweetTheBrand()
    @template.publish()

  @fillName = () ->
    @template.fill "brand_name", @data["name"]

  @readyYearLinks = () ->
    companyId = @company_id
    year = @year.toString()
    @find("._year-buttons a").each ()->
      el = $(this)
      buttonYear = el.data("year").toString()
      el.attr "href", FC.profilePath(companyId, buttonYear)
      el.addClass "current" if buttonYear == year

  @fillCommitments = () ->
    for _i, fld of ["action_plan", "public_commitment", "isolating_labor"]
      @commitmentScore fld, @value(fld)

  @commitmentScore = (fld, value) ->
    el = @template.find "._#{fld}"
    el.find("a").attr "href", FC.metricUrl(@metricId(fld))

    handleNoData "#{fld} ._help", value, () ->
      el.find("._value").text(value)
      letterGrade = FC.score.commitment[value]

      el.find("._help").attr("data-target", "##{fld}-score-#{letterGrade}")
      FC.util.image.commitment el.find("._smiley"), value

  # TODO: move to FC.lang
  @fillTranslations = () ->
    for _i, fld of ["transparency_key", "living_wages_key"]
      @template.fill fld, scoreTranslation[@value(fld)]

  @fillSubBrands = () ->
    subs = FC.subBrands[@data["name"]]
    return unless subs

    list = @find "._sub_brand_list"
    for _i, brand of subs
      list.append $("<li>#{brand}</li>")

  @fillSimple = () ->
    for _i, fld of ["headquarters", "top_3_production_countries"]
      @template.fill fld, @value(fld)

  @fillEuro = () ->
    for _i, fld of ["revenue", "profit"]
      handleNoData fld, @value(fld), (val) ->
        num = val.replace /(\d)(?=(\d{3})+$)/g, "$1,"
        @template.fill fld, "EUR #{num}"

  @value = (fld) ->
    @data[@metricId(fld)] || FC.lang.noData

  @metricId = (fld) ->
    FC.metrics.brandsMap[fld]

  @interpret = (data) ->
    @data = FC.company.hash(data)[@company_id]

  @find = (key) ->
    @template.current.find key

  @livingWageImage = () ->
    fld = "living_wages_score"
    handleNoData fld, @value(fld), (val) ->
      FC.util.image.select @find("._#{fld} img"), "wage_score", val, "png"

  @transparency = () ->
    fld = "transparency-stars"
    handleNoData fld, @value("transparency_score"), (val) ->
      FC.util.image.transparency @find("._#{fld}"), val

  @wikiRateLinks = () ->
    @find("._wikirate-link").attr "href", FC.companyUrl(@company_id)

  @tweetTheBrand = () ->
    return unless (handle = @value "twitter_handle")

    link = @find "._tweet-the-brand"
    tweetText = "#{handle}\n#{window.location.href} #LivingWageNow"
    link.attr "href", link.attr("href") + $.param({ text: tweetText })
    link.removeClass("d-none")

  @handleNoData = (fld, val, fn) ->
    if val == FC.lang.noData
      @template.fill fld, FC.lang.noData
      # @find("_#{fld}").addClass "noImage"
    else
      fn(val)

  box = this
  url = FC.apiUrl "~#{@company_id}+Answer/compact",
    filter:
      metric_id: Object.values(FC.metrics.brandsMap)
      year: year

  $.when(
    $.ajax url: url, dataType: "json"
    FC.loadSubBrands
  ).done (data) ->
    box.data = box.interpret data[0]
    box.build()
