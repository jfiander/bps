# frozen_string_literal: true

class Admin::VersionsController < ApplicationController
  secure!(:admin, strict: true)

  before_action :load_versions, only: %i[show diff revert]
  before_action :find_version_numbers, only: %i[diff]

  def index
    return list_objects if clean_params[:model].present?

    versioned_models
  end

  def show
    @current_version = model_class.find_by(id: clean_params[:id])
  end

  def diff
    fix_version_order
    return unless version_jsons.compact.count == 2

    @mode = clean_params[:mode] || 'line'
    find_changers
    @event = version_b&.event

    generate_diff
  end

  def revert
    @version = @versions.first(clean_params[:a].to_i).last
    @version.reify ? @version.reify.save! : @version.item.destroy

    redirect_to admin_show_versions_path
  end

private

  def versioned_models
    Rails.application.eager_load!
    @models = ApplicationRecord.descendants.map(&:name).sort
  end

  def list_objects
    @objects = model_class.with_deleted.all
  end

  def model_class
    raise 'Unpermitted class.' unless clean_params[:model].in?(versioned_models)

    clean_params[:model].classify.constantize
  end

  def find_version_numbers
    @a = clean_params[:a].to_i
    @b = clean_params[:b].to_i
    redirect_to versions_path if @a == @b
  end

  def load_versions
    @model = clean_params[:model]
    @id = clean_params[:id]
    @versions = model_class&.find_by(id: @id)&.versions&.to_a&.sort_by(&:id)&.reverse
  end

  def clean_params
    params.permit(:model, :id, :a, :b, :mode)
  end

  def version_jsons
    [version_a_json, version_b&.reify&.to_json].map { |v| v&.gsub(',"', ', "')&.gsub('":', '": ') }
  end

  def version_a_json
    if @a.zero?
      model_class.find_by(id: clean_params[:id]).to_json
    else
      version_a&.reify&.to_json
    end
  end

  def version_a
    @versions.first(@a)&.last
  end

  def version_b
    @versions.first(@b)&.last
  end

  def diff_method
    case @mode
    when 'word'
      :diff_by_word
    when 'line'
      :diff_by_line
    when 'char'
      :diff_by_char
    else
      :diff_by_line
    end
  end

  def fix_version_order
    return unless @a > @b

    c = @a.dup
    @b = @a
    @a = c
  end

  def find_changers
    @changer = User.find_by(id: version_b&.whodunnit.to_i)
    @previous = User.find_by(id: version_a&.whodunnit.to_i)
  end

  def generate_diff
    # html_safe: Text is sanitized before display
    jsons = version_jsons.map { |j| pretty_json(j) }
    differ = Differ.send(diff_method, *jsons).format_as(:html)
    @diff = sanitize(differ).html_safe
  end

  def pretty_json(json)
    JSON.pretty_generate(JSON.parse(json), indent: '  ')
  end
  helper_method :pretty_json
end
