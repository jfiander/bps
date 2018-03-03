module ViewHelper
  def officer_flag(office, mode: :svg)
    rank = case office
           when 'commander'
             'CDR'
           when %w[executive educational administrative secretary treasurer]
             'LTC'
           when %w[asst_educational asst_secretary]
             '1LT'
           end

    if mode == :svg
      open(static_bucket.link("flags/SVG/#{rank}.svg")).read.html_safe
    elsif mode == :png
      image_tag static_bucket.link("flags/PNG/#{rank}.thumb.png")
    end
  end

  def spinner_button(form = nil, button_text: 'Submit', disable_text: nil, name: 'button', css_class: '')
    disable_text ||= button_text == 'Submit' ? 'Submitting' : button_text.sub(/e$/, '') + 'ing'
    data_hash = { disable_with: (fa_icon('spinner', fa: 'pulse') + "#{disable_text}...") }

    return form.button(button_text, data: data_hash, name: name, class: css_class) if form.present?
    button_tag(button_text, data: data_hash, name: name, class: css_class)
  end

  def summer_months(select_tag, mode: :summer)
    select_tag.gsub(
      "<option value=\"7\">July</option>\n<option value=\"8\">August</option>\n",
      (mode == :summer ? '<option value="7">* Summer</option>' : '')
    ).html_safe
  end
end
