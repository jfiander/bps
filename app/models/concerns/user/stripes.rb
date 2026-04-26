# frozen_string_literal: true

class User
  module Stripes
    NARROW = /^P?[CD]C$/i
    NATIONAL = /^P?(([CVR]|Stf)C|N(FLt|Aide))$/i
    DISTRICT = /^P?D((Lt)?C|(F(irst)?)?Lt|Aide)$/i
    SQUADRON = /^(P?((Lt)?C|(F(irst)?)?Lt)|Cdr)$/i
    TWO = /^(P?([CVR]C|(D?(FirstLt|(Lt)?C)))|Cdr)$/i
    THREE = /^(P?([CV]|D?(Lt)?)?C|Cdr)$/i
    FOUR = /^(P?[CD]?C|Cdr)$/i
  end
end
