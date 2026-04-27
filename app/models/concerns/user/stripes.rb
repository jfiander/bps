# frozen_string_literal: true

class User
  module Stripes
    module Ranks
      NATIONAL = %w[CC PCC VC PVC RC PRC STFC PSTFC NFLT PNFLT NAIDE].freeze
      DISTRICT = %w[DC PDC DLTC PDLTC DLT DFLT D1LT DAIDE].freeze
      SQUADRON = %w[CDR PC LTC PLTC LT FLT].freeze
    end

    module Style
      NARROW = %w[CC PCC DC PDC].freeze
      TWO    = %w[RC PRC D1LT 1LT].freeze
      THREE  = %w[VC PVC DLTC PDLTC LTC PLTC].freeze
      FOUR   = %w[CC PCC DC PDC CDR PC].freeze
    end
  end
end
