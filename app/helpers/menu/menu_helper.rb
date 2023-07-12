# frozen_string_literal: true

module Menu
  module MenuHelper
    include Rails.application.routes.url_helpers
    include MainMenuHelper
    include AdminMenuHelper

    DEFAULTABLE_FIELDS = %i[show_when display].freeze

    def show_link?(*roles, strict: false, **options)
      req_cont, req_act, not_cont, not_act = H.link_requirements(options)
      return false unless current_user&.permitted?(roles, strict: strict)
      return false if H.invalid?(req_cont, req_act, not_cont, not_act, controller)

      true
    end

  private

    def load_yaml(glob)
      Rails.root.glob(glob).each_with_object({}) do |path, hash|
        yaml = YAML.safe_load(ERB.new(File.read(path)).result(binding))
        hash.merge!(yaml)
      end.deep_symbolize_keys!
    end

    def propagate_defaults!(yaml)
      yaml.each do |_menu, data|
        menu_defaults = data.slice(*DEFAULTABLE_FIELDS).reverse_merge(display: true)
        data[:items].each do |item|
          item.reverse_merge!(menu_defaults)
          next unless item.key?(:children)

          submenu_defaults = item&.slice(:show_when, :display)
          item[:children].each { |child| child.reverse_merge!(submenu_defaults) }
        end
      end
    end

    def menu_link(data)
      d = data.dup
      return unless d.delete(:display)

      fa = d.delete(:fa)
      d[:fa] = { name: d.delete(:icon), options: { style: :duotone, fa: "fw #{fa}" } } if d[:icon]

      d[:css_class] = d.delete(:button)
      link(d.delete(:text), d)
    end
  end

  # Internal helper methods
  module H
    class << self
      def link_requirements(options)
        req_cont = *options[:controller] || []
        req_action = *options[:action] || []
        not_cont = *options[:not_controller] || []
        not_action = *options[:not_action] || []

        [req_cont, req_action, not_cont, not_action]
      end

      def invalid?(req_cont, req_act, not_cont, not_act, controller)
        @controller = controller

        invalid_controller?(req_cont, req_act, not_cont, not_act) ||
          invalid_action?(req_cont, req_act, not_cont, not_act) ||
          invalid_combination?(req_cont, req_act, not_cont, not_act)
      end

      def display?(data)
        return data[:display] || data[:children].any? { |c| H.display?(c) } if data.key?(:children)
        return data[:display] || data[:items].any? { |d| H.display?(d) } if data.key?(:items)

        data[:display]
      end

    private

      def invalid_controller?(req_cont, req_act, not_cont, not_act)
        (missing_controller?(req_cont) && req_act.blank?) ||
          (wrong_controller?(not_cont) && not_act.blank?)
      end

      def invalid_action?(req_cont, req_act, not_cont, not_act)
        (missing_action?(req_act) && req_cont.blank?) || (wrong_action?(not_act) && not_cont.blank?)
      end

      def invalid_combination?(req_cont, req_act, not_cont, not_act)
        (missing_controller?(req_cont) && missing_action?(req_act)) ||
          (wrong_controller?(not_cont) && wrong_action?(not_act))
      end

      def missing_controller?(req_controller = nil)
        return false if req_controller.blank?

        !@controller.controller_name.in?(req_controller)
      end

      def wrong_controller?(not_controller = nil)
        return false if not_controller.blank?

        @controller.controller_name.in?(not_controller)
      end

      def missing_action?(req_action = nil)
        return false if req_action.blank?

        !@controller.action_name.in?(req_action)
      end

      def wrong_action?(not_action = nil)
        return false if not_action.blank?

        @controller.action_name.in?(not_action)
      end
    end
  end
end
