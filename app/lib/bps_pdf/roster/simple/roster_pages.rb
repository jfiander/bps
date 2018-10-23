# frozen_string_literal: true

module BpsPdf::Roster::Simple::RosterPages
  def roster_pages(users, orientation)
    @orientation = orientation
    load_logo

    users.in_groups_of(roster_config[:per_page]) do |page|
      roster_page(page)
    end
  end

private

  def roster_page(page)
    start_new_page
    header

    page.in_groups_of(roster_config[:columns]).each_with_index do |row, row_i|
      row.each_with_index { |user, i| roster_entry(user, row_i, i) }
    end

    footer
  end

  def header
    insert_image(
      'tmp/run/ABC-B.png',
      at: [roster_config[:logo][:x], roster_config[:logo][:y]],
      width: roster_config[:logo][:width]
    )
  end

  def roster_entry(user, row_index, col_index)
    return unless user.present?

    entry_box(user, entry_box_x(col_index), entry_box_y(row_index))
  end

  def entry_box_x(col_index)
    roster_config[:base][:x] + col_index * (roster_config[:member][:width] + 10)
  end

  def entry_box_y(row_index)
    roster_config[:base][:y] - row_index * (roster_config[:member][:height] + 20)
  end

  def entry_box(user, base_x, base_y)
    bounding_box(
      [base_x, base_y],
      width: roster_config[:member][:width], height: roster_config[:member][:height]
    ) do
      roster_for_member(user)
    end
  end

  def roster_for_member(user)
    name(user)
    text user.certificate, size: 9
    move_down(5)
    email(user)
    user.mailing_address(name: false).each { |a| text a, size: 9 }
    move_down(5)
    phones(user)
  end

  def name(user)
    Prawn::Text::Formatted::Box.new(
      format_name(user.full_name(html: false).gsub(/&#39;/, "'")),
      document: self, overflow: :shrink_to_fit, style: :bold,
      width: roster_config[:member][:width], height: 20
    ).render
    move_down(roster_config[:member][:after_name])
  end

  def email(user)
    if user.placeholder_email?
      move_down(10)
    else
      text(user.email, size: 9)
      move_down(5)
    end
  end

  def phones(user)
    phone(user, :phone_h)
    phone(user, :phone_c)
    phone(user, :phone_w)
  end

  def phone(user, method)
    letter = method.to_s.last
    text "#{letter} " + user.send(method), size: 9 if user.send(method).present?
  end

  def footer
    bounding_box(
      [0, roster_config[:footer][:y]], width: roster_config[:footer][:width], height: 25
    ) do
      text 'Copyright © 2018 Birmingham Power Squadron', size: 10, align: :center
      text 'Non-Member and Commercial Use Prohibited.', size: 10, align: :center
    end
  end

  def roster_config
    config[:roster][@orientation]
  end
end
