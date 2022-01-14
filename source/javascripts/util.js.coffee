FC.util =
  # image functions (extended below)
  image:
    # find score image and assign src attribute
    select: (el, folder, score, ext) ->
      ext ||= "svg"
      el.attr("src", "/images/#{folder}/#{score}.#{ext}")

  # supports cloning, filling, and publishing reusable html templates
  # copies from .template child and publishes to .result child.
  templater: (selector) ->
    @container = $(selector)

    @result = () ->
      @container.children ".result"

    @template = () ->
      @container.children ".template"

    @publish = () ->
      @showHeaders()
      @container.children(".result").show()

    @showHeaders = () ->
      @container.parent().find(".section-header > div").show()

    @fill = (field, value) ->
      @find("._#{field}").text(value)

    @find = (selector) ->
      @current.find selector

    @noResult = () ->
      @showHeaders()
      @container.children(".noResult").show()

    @result().empty()
    @container.children(".noResult").hide()
    @current = @template().clone()
    @current.removeClass "template"
    @result().append @current

    this

$.extend FC.util.image,
  # commitment score to smiley face image
  commitment: (el, value) ->
    value = "Yes" if value.includes "Yes"
    FC.util.image.select el, "smiley", value

  # transparency score to stars images
  # (loops through five outline images and makes some of them solid.)
  transparency: (el, val) ->
    return unless (stars = FC.score.transparency[val])
    current = 1
    while (current <= stars)
      img = el.find "._star-#{current}"
      FC.util.image.select img, "transparency_score", "star_solid"
      current++
