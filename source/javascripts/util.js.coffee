FC.util =
  image:
    select: ($el, folder, score, ext) ->
      ext ||= "png"
      $el.attr("src", "/images/#{folder}/#{score}.#{ext}")

  templater: (id) ->
    @container = $("##{id}")

    @result = () ->
      @container.children(".result")

    @template = () ->
      @container.children(".template")

    @publish = () ->
      @find('[data-toggle="popover"]').popover()
      @result().append @current

    @fill = (field, value) ->
      @find("._#{field}").text(value)

    @find = (selector) ->
      @current.find selector

    @result().empty()
    @current = @template().clone()
    @current.removeClass "template"
    this

$.extend FC.util.image,
  commitment: (el, value) ->
    value = "Yes" if value.includes "Yes"
    FC.util.image.select el, "smiley", value, "svg"

  transparency: (el, val) ->
    return unless (stars = FC.score.transparency[val])
    current = 1
    while (current <= stars)
      img = el.find "._star-#{current}"
      FC.util.image.select img, "transparency_score", "star_solid", "svg"
      current++
