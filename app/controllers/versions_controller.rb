class VersionsController < ApplicationController
  before_action :authenticate_user!
  before_action { require_permission(:admin, strict: true) }

  before_action :load_versions, only: %i[show diff revert]

  def index
    return list_objects if clean_params[:model].present?

    versioned_models
  end

  def show
    @current_version = model_class.find_by(id: clean_params[:id])
  end

  def diff
    # html_safe: Text is sanitized before display
    @a = clean_params[:a]
    @b = clean_params[:b]
    return if @a == @b
    fix_version_order
    return unless version_jsons.compact.count == 2

    @diff = sanitize(
      Differ.send(diff_method, *version_jsons).format_as(:html)
    ).html_safe
  end

  def revert
    @version = @versions.last(clean_params[:a]).first
    if @version.reify
      @version.reify.save!
    else
      @version.item.destroy
    end

    redirect_to show_versions_path
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

  def load_versions
    @model = clean_params[:model]
    @id = clean_params[:id]
    @versions = model_class&.find_by(id: @id)&.versions
  end

  def clean_params
    params.permit(:model, :id, :a, :b, :mode)
  end

  def version_jsons
    a = if @a == '0'
          model_class.find_by(id: clean_params[:id]).to_json
        else
          @versions.last(@a)&.first&.reify&.to_json
        end

    b = @versions.last(@b)&.first&.reify&.to_json

    [a, b].map { |v| v&.gsub(',"', ', "')&.gsub('":', '": ') }
  end

  def diff_method
    case clean_params[:mode]
    when 'word'
      :diff_by_word
    when 'line'
      :diff_by_line
    when 'char'
      :diff_by_char
    else
      :diff_by_word
    end
  end

  def fix_version_order
    return unless @a > @b

    c = @a.dup
    @b = @a
    @a = c
  end
end
