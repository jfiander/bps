# frozen_string_literal: true

module PlacecardsHelper
  def placecard_meal(person)
    return 'circle-question' if person.nil? || person['meal'].blank?

    {
      'chicken' => :turkey,
      'fish' => :fish,
      'vegetarian' => :carrot
    }[person['meal']]
  end

  def placecard_image(person)
    return if person.nil?

    if person['image'].blank?
      safe_join(
        [
          (image_tag(person['rank']) if person['rank'].present?),
          (image_tag(person['burgee']) if person['burgee'].present?)
        ]
      )
    else
      image_tag(person['image'])
    end
  end

  def placecard_mm(person)
    return if person.nil? || person['mm'].blank?

    safe_join(person['mm'].to_i.times.map do
      image_tag(BPS::S3.new(:static).link('insignia/PNG/mm.png'))
    end)
  end
end
