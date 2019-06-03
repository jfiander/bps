class AddLengthPiecesToEvents < ActiveRecord::Migration[5.2]
  def up
    add_column :events, :length_h, :integer
    add_column :events, :length_m, :integer

    Event.all.each do |event|
      next unless event.length.present?

      event.update(
        length_h: event.length.strftime('%H').to_i,
        length_m: event.length.strftime('%M').to_i
      )
    end

    remove_column :events, :length
  end

  def down
    add_column :events, :length, :time

    Event.all.each do |event|
      next unless event.length_h.present?

      length_h = event.length_h.to_s.rjust(2, '0')
      length_m = event.length_m.present? ? event.length_m.to_s.rjust(2, '0') : '00'

      event.update(length: Time.strptime("#{length_h}#{length_m}", '%H%M'))
    end

    remove_column :events, :length_h
    remove_column :events, :length_m
  end
end
