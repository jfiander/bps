# frozen_string_literal: true

module Members::Markdown
  def edit_markdown
    @page = StaticPage.find_by(name: clean_params[:page_name])
  end

  def update_markdown
    clean_params['markdown'] = sanitize(clean_params['markdown'])
    if clean_params['save']
      save_markdown
    elsif clean_params['preview']
      preview_markdown
      render 'preview_markdown'
    end
  end

  private

  def save_markdown
    page = StaticPage.find_by(name: static_page_params[:name])

    if page.update(markdown: static_page_params[:markdown])
      flash[:success] = "Successfully updated #{page.name} page."
    else
      flash[:alert] = "Unable to update #{page.name} page."
    end
    redirect_to send("#{page.name}_path")
  end

  def preview_markdown
    # html_safe: Text is sanitized before display
    @page = StaticPage.find_by(name: clean_params[:page_name])
    @new_markdown = sanitize(static_page_params[:markdown])
    @preview_html = render_markdown_raw(
      markdown: @new_markdown
    ).html_safe
  end
end
