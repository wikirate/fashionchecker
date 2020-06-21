module Partials
  def property title, name
    partial "partials/brand_profile/property", locals: { title: title, name: name}
  end

  def brand_profile_partial template, args={}
    partial "partials/brand_profile/#{template}", args
  end

  def section color, second_color=nil, py="py-5", &block
    color = [color, second_color].compact.join('-')
    partial "partials/section", locals: { color: "#{color}-bg", py: py }, &block
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
    partial "partials/shared/compare", locals: { title: title,
                                                   min_wage_icons: min_wage_icons,
                                                   living_wage_icons: living_wage_icons }
  end

  def commitment_modals title, values, id=nil
    values.map.with_index do |value, index|
      partial "partials/brand_profile/modal",
              locals: { title: "#{title}: #{value}",
                        id: modal_id(id || title, index + 1),
                        text: t("commitment_score.#{title.downcase.gsub(" ", "_")}_score_#{index + 1}") }
    end.join
  end

  def modal_id title, index
    "#{title.downcase.gsub(" ", "-")}-score-#{index}"
  end
end