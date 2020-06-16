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
end