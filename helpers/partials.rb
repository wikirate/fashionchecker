module Partials
  require "json"

  SCORE_KEYS = %i[
     lw_c_50_plausible_notpublic
     lw_d_25_public
     lw_d_started
     lw_e_noclaim_notpublic
     lw_e_noevidence
     transp_none
     transp_partial
     transp_partial_additional
     transp_partial_additional_machinereadable
     transp_partial_machinereadable
     transp_pledge
     transp_pledge_additional
     transp_pledge_additional_machinereadable
     transp_pledge_machinereadable
  ].freeze

  def property key, prefix=nil
    partial "partials/brand_profile/property",
            locals: { key: key, prefix: prefix }
  end

  def brand_profile_partial template, args={}
    partial "partials/brand_profile/#{template}", args
  end

  def section color, second_color=nil, klass="py-5", &block
    color = [color, second_color].compact.join('-')
    partial "partials/shared/section",
            locals: { color: "#{color}-bg", klass: klass }, &block
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
      text = t "commitment_score.#{title.downcase.gsub(" ", "_")}_score_#{index + 1}"
      partial "partials/brand_profile/modal",
              locals: { title: "#{title}: #{value}",
                        id: modal_id(id || title, index + 1),
                        text: text }
    end.join
  end

  def modal_id title, index
    "#{title.downcase.gsub(" ", "-")}-score-#{index}"
  end

  def resource title, url, args={}
    partial "partials/resources/resource", locals: { title: title,
                                                     url: url,
                                                     new: args[:new],
                                                     year: args[:year],
                                                     desc: args[:desc] }
  end

  def brand_demand &block
    partial "partials/demand/brand", &block
  end

  def policy_demand &block
    partial "partials/demand/policy", &block
  end

  def score_translation_script
    hash = SCORE_KEYS.each_with_object({}) { |key, hash| hash[key] = t key }
    "var scoreTranslation = #{JSON.generate hash}"
  end

  def banner image_url, text=nil
    partial "partials/shared/banner", locals: { image_url: image_url, text: text }
  end

  def donate_button button_id, filename
    partial "partials/shared/donate",
            locals: { button_id: button_id, filename: filename }
  end

  def image_quote url, quote, citation
    partial "partials/shared/image_quote",
            locals: { url: url, quote: quote, citation: citation }
  end

  def legend_row icon, title_key
    partial "partials/shared/legend_row",
            locals: { icon: icon, title_key: title_key }
  end

  def th_icon icon, title_key
    partial "partials/shared/th_icon",
            locals: { icon: icon, title_key: title_key }
  end

  def supplier_table_header key
    brand_profile_partial :suppliers_table_header, locals: { key: key }
  end
end
