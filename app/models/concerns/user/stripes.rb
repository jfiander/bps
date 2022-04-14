# frozen_string_literal: true

class User
  module Stripes
    NARROW = /^P?[CD]C$/i.freeze
    NATIONAL = /^P?(([CVR]|Stf)C|N(FLt|Aide))$/i.freeze
    DISTRICT = /^P?D((Lt)?C|(F(irst)?)?Lt|Aide)$/i.freeze
    SQUADRON = /^(P?((Lt)?C|(F(irst)?)?Lt)|Cdr)$/i.freeze
    TWO = /^(P?([CVR]C|(D?((First)?Lt|(Lt)?C)))|Cdr)$/i.freeze
    THREE = /^(P?([CV]|D?(Lt)?)?C|Cdr)$/i.freeze
    FOUR = /^(P?[CD]?C|Cdr)$/i.freeze
  end
end
