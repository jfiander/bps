# frozen_string_literal: true

module RosterPDF::Detailed::Benefits
  def benefits
    formatted_page do
      benefits_intro
      benefits_list
      store_info
      benefits_disclaimer
    end
  end

  private

  def benefits_intro
    bounding_box([0, 540], width: 325, height: 60) do
      text(
        'Member Benefits',
        size: RosterPDF::Detailed::SECTION_TITLE_SIZE, style: :bold, align: :center
      )
      move_down(10)

      text(
        config_text[:benefits][:top],
        size: RosterPDF::Detailed::BODY_REG_SIZE, align: :justify
      )
    end
  end

  def benefits_list
    link_groups = config_text[:benefits][:links]
    return unless link_groups.size.positive?

    left = link_groups.slice(:'Advancing Education', :'Goods and Services', :'Health Benefits', :'Marine Benefits')
    right = link_groups.slice(:'Travel Benefits', :'Insurance Benefits', :'USPS Benefits')

    bounding_box([0, 480], width: 150, height: 400) do
      display_link_groups(left)
    end

    bounding_box([175, 480], width: 150, height: 400) do
      display_link_groups(right)
    end
  end

  def display_link_groups(groups)
    groups.each do |category, links|
      body_text "<b>#{category}</b>"
      links.each do |link|
        body_text "– <a href='#{link[:url]}'>#{link[:text]}</a>"
      end
      body_text '<br>'
    end
  end

  def store_info
    supply_officer = Committee.find_by(department: :treasurer, name: 'Supply')
    supply = supply_officer.present? ? ", #{supply_officer.user.simple_name}, " : ''
    bounding_box([0, 100], width: 325, height: 80) do
      text "Ship's Store", size: RosterPDF::Detailed::HEADING_SIZE, style: :bold, align: :center
      move_down(10)
      body_text config_text[:benefits][:store].gsub('%supply', supply)
    end
  end

  def benefits_disclaimer
    bounding_box([0, 15], width: 325, height: 15) do
      text(
        config_text[:benefits][:disclaimer],
        size: RosterPDF::Detailed::BODY_SM_SIZE, align: :justify
      )
    end
  end
end
