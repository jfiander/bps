# frozen_string_literal: true

module Menu
  module MainMenuHelper
    def main_menu
      content_tag(:ul, safe_join(main_menu_buttons), class: 'simple')
    end

  private

    def main_menu_yaml
      return @main_menu_yaml unless @main_menu_yaml.nil?

      main_menu_yaml = load_yaml('app/lib/nav/*.yml.erb')
      propagate_defaults!(main_menu_yaml)
      @main_menu_yaml = main_menu_yaml.sort_by { |_menu, data| data[:order] }
    end

    def main_menu_buttons
      main_menu_yaml.map do |_menu, data|
        safe_join(data[:items].map do |d|
          menu_link(d) if H.display?(d)
        end)
      end
    end
  end
end
