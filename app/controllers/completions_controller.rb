# frozen_string_literal: true

class CompletionsController < ApplicationController
  secure!(:education)

  def list
    @completions = CourseCompletion.with_users.all.by_user
  end

  def ytd
    @completions = CourseCompletion.with_users.ytd.by_user
    @ytd = true
    render :list
  end
end
