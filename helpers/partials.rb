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
end