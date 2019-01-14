# frozen_string_literal: true

module ScssHelper
  def render_scss(file)
    text = render(file) # "#{Rails.root}/app/assets/stylesheets/#{file}.scss"

    raw sass_engine(text).render
  end

  def sass_engine(text)
    view_context = controller.view_context

    Sass::Engine.new(
      text,
      syntax: :scss, cache: false, read_cache: false, style: :compressed,
      sprockets: {
        context: view_context,
        environment: view_context.assets_environment
      }
    )
  end
end
