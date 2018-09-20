# frozen_string_literal: true

module RosterPDF::Shared
  private

  def load_logo
    logo = BpsS3.new(:static).download('logos/ABC.long.birmingham.1000.png')
    File.open('tmp/run/ABC-B.png', 'w+') { |f| f.write(logo) }
  end

  def load_burgee
    burgee = BpsS3.new(:static).download('flags/Birmingham/Birmingham.png')
    File.open('tmp/run/Burgee.png', 'w+') { |f| f.write(burgee) }
  end

  def load_ensign
    ensign = BpsS3.new(:static).download('flags/PNG/ENSIGN.500.png')
    File.open('tmp/run/Ensign.png', 'w+') { |f| f.write(ensign) }
  end
end
