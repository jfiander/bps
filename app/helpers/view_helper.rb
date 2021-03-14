# frozen_string_literal: true

module ViewHelper
  # html_safe: No user content
  def officer_flag(office, mode: :svg)
    rank = office_rank(office)

    case mode
    when :svg
      URI.parse(BpsS3.new(:static).link("flags/SVG/#{rank}.svg")).open.read.html_safe
    when :png
      image_tag(BpsS3.new(:static).link("flags/PNG/#{rank}.thumb.png"), alt: rank)
    end
  end

  def spinner_button(form = nil, button_text: 'Submit', disable_text: nil, name: 'button', css: '')
    disable_text ||= button_text == 'Submit' ? 'Submitting' : "#{button_text.sub(/e$/, '')}ing"
    data_hash = { disable_with: (FA::Icon.p('spinner', fa: 'pulse') + "#{disable_text}...") }
    return form.button(button_text, data: data_hash, name: name, class: css) if form.present?

    button_tag(button_text, data: data_hash, name: name, class: css)
  end

  def summer_months(select_tag, mode: :summer)
    select_tag.gsub(
      "<option value=\"7\">July</option>\n<option value=\"8\">August</option>\n",
      (mode == :summer ? '<option value="7">* Summer</option>' : '')
    ).html_safe
  end

private

  def office_rank(office)
    case office
    when 'commander'
      'CDR'
    when *dept_heads
      'LTC'
    when *asst_dept_heads
      '1LT'
    end
  end

  def dept_heads
    %w[executive educational administrative secretary treasurer]
  end

  def asst_dept_heads
    %w[asst_educational asst_secretary]
  end
end
