# frozen_string_literal: true

module SignalFlagsHelper
  # rubocop:disable Rails/OutputSafety
  # html_safe: Text is sanitized before display.
  def signal_flags(text, css: nil)
    bucket = BPS::S3.new(:static)
    text = ActionController::Base.helpers.sanitize(text)

    <<~OUTER.html_safe
      <div class="signals #{css}" title="#{text}">
        #{text.scan(/[A-Za-z0-9\s]/).map(&:downcase).split { |s| s =~ /\s/ }.map do |word|
          <<~INNER
            <div class="word">
              #{word.map do |letter|
                %(<img src="#{bucket.link("signals/PNG/short/#{letter}.png")}" alt="#{letter}">)
              end.join}
            </div>
          INNER
        end.join}
      </div>
    OUTER
  end
  # rubocop:enable Rails/OutputSafety
end
