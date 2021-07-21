window.brandBox = (company_id) ->
  @company_id = company_id
  @template = new FC.util.templater "#brandBox"

  @build = () ->
    @fillName()
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

  @fillCommitments = () ->
    for _i, fld of ["action_plan", "public_commitment", "isolating_labor"]
      @commitmentScore @template.current, fld, @value(fld)

  @commitmentScore = (el, name, value) ->
    el.find("._#{name}").text(value)
    letterGrade = FC.score.commitment[value]

    el.find("._#{name}-help").attr("data-target", "##{name}-score-#{letterGrade}")
    FC.util.image.commitment el.find("._#{name}-smiley"), value

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
      @template.fill fld, @value(fld).replace(/(\d)(?=(\d{3})+$)/g, "$1,")

  @value = (fld) ->
    @data[FC.metrics.brandsMap[fld]]

  @interpret = (data) ->
    @data = FC.company.hash(data)[@company_id]

  @find = (key) ->
    @template.current.find key

  @livingWageImage = () ->
    fld = "living_wages_score"
    FC.util.image.select @find("._#{fld}"), "wage_score", @value(fld), "png"

  @transparency = () ->
    FC.util.image.transparency @find("._transparency-stars"), @value("transparency_score")

  @wikiRateLinks = () ->
    @find("._wikirate-link").attr "href", FC.wikirateUrl(@company_id)

  @tweetTheBrand = () ->
    return unless (handle = @value "twitter_handle")

    link = @find "._tweet-the-brand"
    tweetText = "#{handle}\n#{window.location.href} #LivingWageNow"
    link.attr "href", link.attr("href") + $.param({ text: tweetText })
    link.removeClass("d-none")

  box = this
  url = FC.apiUrl "~#{@company_id}+Answer/compact",
    filter:
      metric_id: Object.values(FC.metrics.brandsMap)
      year: "latest"

  $.when(
    $.ajax url: url, dataType: "json"
    FC.loadSubBrands
  ).done (data) ->
    box.data = box.interpret data[0]
    box.build()
