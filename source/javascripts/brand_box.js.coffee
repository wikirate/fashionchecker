$(document).ready ->
  $("body").on "change", "._year-select", ->
    companyId = $(this).data "company_id"
    year = $(this).val()
    window.location = FC.profilePath companyId, year

window.brandBox = (company_id, year) ->
  @company_id = company_id
  @year = year || 2026
  @template = new FC.util.templater "#brandBox"
  @statusGroups = [
    key: "multistakeholder_initiatives"
    items: [
      { key: "fair_labor_association", normalize: (value) -> value is "Yes" }
      { key: "fair_wear_foundation", normalize: (value) -> value is "Current Member" }
      { key: "ethical_trading_initiative", normalize: (value) -> value.indexOf("Full") is 0 }
      { key: "better_cotton", normalize: (value) -> value is "Yes" }
      { key: "cascale", normalize: (value) -> true }
    ]
  ,
    key: "binding_agreements"
    items: [
      { key: "international_accord", normalize: (value) -> value is "Yes" }
      { key: "bangladesh_accord", normalize: (value) -> value is "Yes" }
      { key: "pakistan_accord", normalize: (value) -> value is "Yes" }
      { key: "act_cambodia", normalize: (value) -> value is "Yes" }
    ]
  ,
    key: "non_binding_agreements"
    items: [
      { key: "industriall_gfa", normalize: (value) -> value is "Yes" }
      { key: "act", normalize: (value) -> value is "Yes" }
    ]
  ,
    key: "mhrdd_coverage"
    items: [
      { key: "csrd", normalize: (value) -> value is "Yes" }
      { key: "csddd", normalize: (value) -> value is "Yes" }
      { key: "norwegian_transparency_act", normalize: (value) -> value is "Yes" }
      { key: "duty_of_vigilance", normalize: (value) -> value is "Yes" }
    ]
  ]

  @build = () ->
    @fillName()
    @readyYearSelect()
    @fillSimple()
    @fillEuro()
    @fillCommitments()
    @fillTranslations()
    @fillSubBrands()
    @livingWageImage()
    @transparency()
    @fillStatusGroups()
    @fillGrievanceMechanisms()
    @wikiRateLinks()
    @tweetTheBrand()
    @template.publish()
    FC.brandProfileNavigation.refresh()

  @fillName = () ->
    @template.fill "brand_name", @data["name"]

  @readyYearSelect = () ->
    select = @find "._year-select"
    select.data "company_id", @company_id
    select.find("option[value='#{@year}']").prop "selected", true

  @fillCommitments = () ->
    for _i, fld of ["action_plan", "public_commitment", "freedom_of_association_n_bargaining"]
      @commitmentScore fld, @value(fld)

  @commitmentScore = (fld, value) ->
    el = @template.find "._#{fld}"
    # el.find("a").attr "href", FC.metricUrl(@metricId(fld))

    @handleNoData "#{fld} ._help", value, () ->
      el.find("._value").text(value)
      letterGrade = FC.score.commitment[value]

      el.find("._help").attr("data-target", "##{fld}-score-#{letterGrade}")
      FC.util.image.commitment el.find("._smiley"), value

  # TODO: move to FC.lang?
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

  @fillStatusGroups = () ->
    for _i, group of @statusGroups
      activeCount = 0
      for _j, item of group.items
        isActive = @statusItemActive item
        activeCount++ if isActive
        statusItem = @find "._status-item-#{item.key}"
        statusItem.toggleClass "is-active", isActive
        statusItem.toggleClass "is-not-reported", not isActive

      @template.fill "status-group-count-#{group.key}", "#{activeCount}/#{group.items.length}"

  @statusItemActive = (item) ->
    value = @value(item.key)
    return false if value == FC.lang.noData
    item.normalize(value)

  @fillGrievanceMechanisms = () ->
    grievanceMap =
      email: "grievance_email"
      hotline: "grievance_hotline"
      online: "grievance_online"

    $.each grievanceMap, (uiKey, metricKey) =>
      value = @normalizeGrievanceValue uiKey, @value(metricKey)
      valueElement = @find "._grievance-value-#{uiKey}"
      @renderGrievanceValue uiKey, value, valueElement
      @find("._grievance-#{uiKey}").toggleClass "is-empty", value == FC.lang.noData

  @renderGrievanceValue = (uiKey, value, valueElement) ->
    valueElement.empty()
    return valueElement.text(value) if value == FC.lang.noData or value == FC.lang.unknown

    value = $.trim(value)
    value = "https://#{value}" if uiKey == "online" and /^www\./i.test(value)
    if uiKey == "email" and /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(value)
      $("<a>", {
        class: "grievance-card-link"
        href: "mailto:#{encodeURIComponent(value)}"
        text: value
      }).appendTo valueElement
    else if uiKey == "online" and /^https?:\/\/[^\s]+$/i.test(value)
      linkAttributes =
        href: value
        rel: "noopener noreferrer"
        target: "_blank"

      $("<a>", $.extend({
        class: "grievance-card-link"
        text: valueElement.data("online-action")
      }, linkAttributes)).appendTo valueElement

      $("<a>", $.extend({
        class: "grievance-card-destination"
        text: @grievanceUrlLabel(value)
        title: value
      }, linkAttributes)).appendTo valueElement
    else
      valueElement.text value

  @grievanceUrlLabel = (url) ->
    url.replace(/^https?:\/\//i, "").replace(/\/$/, "")

  @normalizeGrievanceValue = (uiKey, value) ->
    return FC.lang.noData if value == FC.lang.noData
    return FC.lang.unknown if uiKey == "hotline" and /^http/i.test(value)
    value

  @fillEuro = () ->
    for _i, fld of ["revenue", "profit"]
      year = @valueYear fld
      @handleNoData fld, @value(fld), (val) ->
        num = val.replace /(\d)(?=(\d{3})+$)/g, "$1,"
        @template.fill fld, "EUR #{num}"
        @template.fill "#{fld}-year", "(#{year})"

  @value = (fld) ->
    val = @data[@metricId(fld)]
    val && val[0] || FC.lang.noData

  @valueYear = (fld) ->
    val = @data[@metricId(fld)]
    val && val[1]

  @metricId = (fld) ->
    FC.metrics.brandsMap[fld]

  @interpret = (data) ->
    @data = FC.company.hash(data)[@company_id]

  @find = (key) ->
    @template.current.find key

  @livingWageImage = () ->
    fld = "living_wages_score"
    @handleNoData fld, @value(fld), (val) ->
      FC.util.image.select @find("._#{fld} img"), "wage_score", val, "png"

  @transparency = () ->
    fld = "transparency-stars"
    @handleNoData fld, @value("transparency_score"), (val) ->
      FC.util.image.transparency @find("._#{fld}"), val

  @wikiRateLinks = () ->
    @find("._wikirate-link").attr "href", FC.companyUrl(@company_id, "Fashion Checker: Brand Data")

  @tweetTheBrand = () ->
    return unless (handle = @value "twitter_handle")

    link = @find "._tweet-the-brand"
#    tweetText = "#{handle}\n#{window.location.href} #LivingWageNow"
#    link.attr "href", link.attr("href") + $.param({ text: tweetText })
    link.attr "href", link.attr("href")
    link.removeClass("d-none")

  @handleNoData = (fld, val, fn) ->
    if val == FC.lang.noData
      @template.fill fld, FC.lang.noData
    else
      fn(val)

  box = this
  path = "~#{@company_id}+Answer/compact"

  annualUrl = FC.apiUrl path, filter:
    metric_id: Object.values(FC.metrics.brandsAnnualMap)
    year: @year

  latestUrl = FC.apiUrl path, filter:
    metric_id: Object.values(FC.metrics.brandsLatestMap)
    year: "latest"

  $.when(
    $.ajax url: annualUrl, dataType: "json"
    $.ajax url: latestUrl, dataType: "json"
    FC.loadSubBrands
  ).done (annual, latest) ->
    box.data = Object.assign {}, box.interpret(annual[0]), box.interpret(latest[0])
    box.build()
