# frozen_string_literal: true

require 'rails_helper'

RSpec.describe MarkdownHelper, type: :helper do
  it 'defines a constant of available views' do
    expect(MarkdownHelper::VIEWS).to be_a(Hash)
    expect(MarkdownHelper::VIEWS.keys.all? { |l| l.is_a?(String) }).to be(true)
    expect(MarkdownHelper::VIEWS.values.all? { |l| l.is_a?(Array) }).to be(true)
  end

  it 'raises an ArgumentError if not given a name or raw markdown' do
    expect { MarkdownHelper.render_markdown_raw }.to raise_error(
      ArgumentError, 'Must provide name or markdown.'
    )
  end

  describe 'rendering a page' do
    before do
      @page = FactoryBot.create(:static_page)
    end

    it 'correctly renders a page' do
      expect(MarkdownHelper.render_markdown_raw(name: @page.name)).to eql(
        "<div class=\"markdown\"><p>Just some text</p>\n</div>"
      )
    end

    it 'correctly renders a comented section' do
      expect(MarkdownHelper.render_markdown_raw(markdown: '//Commented')).to eql(
        "<div class=\"markdown\"><p style=\"display: none;\">Commented</p>\n</div>"
      )
    end

    it 'correctly renders a centered section' do
      expect(MarkdownHelper.render_markdown_raw(markdown: '@Centered')).to eql(
        "<div class=\"markdown\"><p class=\"center\">Centered</p>\n</div>"
      )
    end

    it 'correctly renders a bigger section' do
      expect(MarkdownHelper.render_markdown_raw(markdown: '+Bigger')).to eql(
        "<div class=\"markdown\"><p class=\"bigger bold\">Bigger</p>\n</div>"
      )
    end

    describe 'correctly renders a centered bigger section' do
      it 'with centered first' do
        expect(MarkdownHelper.render_markdown_raw(markdown: '@+Big Centered')).to eql(
          "<div class=\"markdown\"><p class=\"center bigger bold\">Big Centered</p>\n</div>"
        )
      end

      it 'with bigger first' do
        expect(MarkdownHelper.render_markdown_raw(markdown: '+@Big Centered')).to eql(
          "<div class=\"markdown\"><p class=\"center bigger bold\">Big Centered</p>\n</div>"
        )
      end
    end

    it 'correctly superscripts the registered trademark symbol' do
      expect(MarkdownHelper.render_markdown_raw(markdown: '&reg;')).to eql(
        "<div class=\"markdown\"><p><sup>&reg;</sup></p>\n</div>"
      )
    end

    it 'correctly renders the burgee' do
      expect(MarkdownHelper.render_markdown_raw(markdown: '%burgee')).to(
        include(
          '<svg',
          "<path d=\"M 22500 -10750\nl 1175.55 818.05\nl -414.7 -1370.85",
          '<title>Birmingham Burgee</title>',
          'fill="#1086FF"'
        )
      )
    end

    it 'correctly links an email address' do
      expect(MarkdownHelper.render_markdown_raw(markdown: 'test@bpsd9.org')).to(
        eql(
          "<div class=\"markdown\"><p><a target='_blank' " \
          'href="mailto:test@bpsd9.org" ' \
          "title=''>test@bpsd9.org</a></p>\n</div>"
        )
      )
    end
  end

  it 'correctly parses using simple_markdown' do
    expect(MarkdownHelper.simple_markdown('This is **bold** text.')).to eql(
      "<p>This is <strong>bold</strong> text.</p>\n"
    )
  end
end
