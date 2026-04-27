# frozen_string_literal: true

module ScssHelper
  # rubocop:disable Rails/OutputSafety
  # No user data
  def render_scss(file)
    name = file.sub(%r{\.scss\z}, '')
    parts = name.split('/')
    partial_name = "_#{parts.pop}.scss"
    path = Rails.root.join('app/views', *parts, partial_name)

    raw SassC::Engine.new(File.read(path), syntax: :scss, style: :compressed).render
  end
  # rubocop:enable Rails/OutputSafety
end
