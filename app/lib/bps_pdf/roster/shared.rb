# frozen_string_literal: true

module BpsPdf::Roster::Shared
private

  def load_burgee
    burgee = BpsS3.new(:static).download('flags/Birmingham/Birmingham.png')
    File.open('tmp/run/Burgee.png', 'w+') { |f| f.write(burgee) }
  end

  def load_ensign
    ensign = BpsS3.new(:static).download('flags/PNG/ENSIGN.500.png')
    File.open('tmp/run/Ensign.png', 'w+') { |f| f.write(ensign) }
  end

  def format_name(name)
    if name.to_s&.match?(%r{1st/Lt})
      pre, name = name.split('1st/Lt')
      [{ text: "#{pre}1" }, { text: 'st', styles: [:superscript] }, { text: "/Lt#{name}" }]
    else
      [{ text: name }]
    end
  end
end
