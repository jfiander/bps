# frozen_string_literal: true

require 'rails_helper'

RSpec.describe FontAwesomeHelper, type: :helper do
  describe 'icon' do
    it 'should generate the correct icon from a string or symbol name' do
      expect(fa_icon('help')).to eql(
        "<i class='fas fa-help' data-fa-transform='' title=''></i>"
      )

      expect(fa_icon(:help)).to eql(
        "<i class='fas fa-help' data-fa-transform='' title=''></i>"
      )
    end

    it 'should generate the correct icon from a configuration hash' do
      fa = { name: 'help', options: { style: :light, size: 2 } }
      expect(fa_icon(fa)).to eql(
        "<i class='fal fa-help fa-2x' data-fa-transform='' title=''></i>"
      )
    end

    it 'should raise ArgumentError for other input types' do
      [nil, [], 0].each do |fa|
        expect { fa_icon(fa) }.to raise_error(
          ArgumentError, 'Unexpected argument type.'
        )
      end
    end

    it 'should generate the correct brand icon' do
      expect(fa_icon(:github, style: :brands)).to eql(
        "<i class='fab fa-github' data-fa-transform='' title=''></i>"
      )
    end
  end

  describe 'layer' do
    it 'should generate the correct layer from string or symbol names' do
      icons = [
        { name: :square },
        { name: :circle, options: { grow: 1 } },
        { name: 'exclamation', options: { style: :regular } }
      ]

      expect(fa_layer(icons, grow: 2)).to eql(
        "<span class='icon fa-layers fa-fw ' title=''>" \
        "<i class='fas fa-square' data-fa-transform='grow-2' title=''></i>" \
        "<i class='fas fa-circle' data-fa-transform='grow-3' title=''></i>" \
        "<i class='far fa-exclamation' data-fa-transform='grow-2' title=''>" \
        '</i></span>'
      )
    end

    it 'should generate the correct layer with a span' do
      icons = [
        { name: :square },
        { name: :counter, text: 17, options: { position: :tl } }
      ]

      expect(fa_layer(icons)).to eql(
        "<span class='icon fa-layers fa-fw ' title=''>" \
        "<i class='fas fa-square' data-fa-transform='grow-0' title=''></i>" \
        "<span class='fa-layers-counter fa-layers-top-left' " \
        "data-fa-transform='grow-0'>17</span></span>"
      )
    end
  end

  describe 'span' do
    it 'should generate the correct span from a string or symbol type' do
      expect(fa_span(:text, 'Hello')).to eql(
        "<span class='fa-layers-text ' data-fa-transform=''>Hello</span>"
      )
    end

    it 'should generate the correct span from a configuration hash' do
      span = { type: :text, text: 'World', options: { position: :bl } }
      expect(fa_span(span)).to eql(
        "<span class='fa-layers-text fa-layers-bottom-left' " \
        "data-fa-transform=''>World</span>"
      )
    end

    it 'should raise ArgumentError for other input types' do
      [nil, [], 0].each do |fa|
        expect { fa_span(fa) }.to raise_error(
          ArgumentError, 'Unexpected argument type.'
        )
      end
    end
  end
end
