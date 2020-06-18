module Partials
  def property title, name
    partial "partials/brand_profile/property", locals: { title: title, name: name}
  end

  def brand_profile_partial template, args={}
    partial "partials/brand_profile/#{template}", args
  end

  def section color, &block
    partial "partials/section", locals: { color: "#{color}-bg" }, &block
  end

  def article filename
    partial "content/articles/#{filename}"
  end

  def score_desc t_name, count
    (1..count).map do |i|
      partial "partials/brand_profile/score_desc", locals: { t_name: "#{t_name}.score_#{i}", score: i}
    end.join
  end

  def compare title, min_wage_icons, living_wage_icons
    partial "partials/homepage/compare", locals: { title: title,
                                                   min_wage_icons: min_wage_icons,
                                                   living_wage_icons: living_wage_icons }
  end
end