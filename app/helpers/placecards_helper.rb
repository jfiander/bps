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
    return if person['image'].nil?

    image_tag(person['image'])
  end
end
