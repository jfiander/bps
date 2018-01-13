module ViewHelper
  def officer_flag(office, mode: :svg)
    rank = case office
    when "commander"
      "CDR"
    when "executive", "educational", "administrative", "secretary", "treasurer"
      "LTC"
    when "asst_educational", "asst_secretary"
      "1LT"
    end

    if mode == :svg
      open(static_bucket.link(key: "flags/SVG/#{rank}.svg")).read.html_safe
    elsif mode == :png
      image_tag static_bucket.link(key: "flags/PNG/#{rank}.thumb.png")
    end
  end

  def spinner_button(form = nil, button_text: "Submit", disable_text: nil, name: "button")
    disable_text ||= button_text == "Submit" ? "Submitting" : button_text.sub(/e$/, '') + "ing"
    data_hash = { disable_with: (fa_icon("spinner pulse") + "#{disable_text}...") }

    return form.button(button_text, data: data_hash, name: name) if form.present?
    button_tag(button_text, data: data_hash, name: name)
  end
end
