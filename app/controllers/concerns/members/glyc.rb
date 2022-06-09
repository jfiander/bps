# frozen_string_literal: true

module Members
  module GLYC
    def glyc_members; end

    def update_glyc_members
      UpdateGLYCMembers.new(glyc_members_pdf).update

      redirect_to(glyc_members_path)
    end

  private

    def glyc_members_pdf
      params.permit(:file)[:file]
    end
  end
end
