# frozen_string_literal: true

module BpsPdf::EducationCertificate::Details
  def details(user, **_)
    certificate(user)
    date
    signature
  end

private

  def certificate(user)
    bounding_box([0, 500], width: 100, height: 30) do
      text user.certificate, align: :center, size: 14
    end
    stroke_line([0, 485], [100, 485])
    bounding_box([0, 480], width: 100, height: 30) do
      text 'Certificate', align: :center, size: 10
    end
  end

  def date
    bounding_box([0, 440], width: 160, height: 20) do
      text Date.today.strftime('%-d %B %Y'), align: :center, size: 14
    end
    stroke_line([0, 425], [160, 425])
    bounding_box([0, 420], width: 160, height: 15) do
      text 'Date', align: :center, size: 10
    end
  end

  def signature
    decrypt_signature
    bounding_box([200, 460], width: 200, height: 50) do
      # seo = BridgeOffice.find_by(office: :educational).user
      image 'tmp/run/signature.png', width: 150, position: :center
    end
    stroke_line([200, 425], [400, 425])
    bounding_box([200, 420], width: 200, height: 15) do
      text 'Squadron Educational Officer', align: :center, size: 10
    end
  end

  def decrypt_signature
    buffer = +''
    File.open('tmp/run/signature.png', 'wb') do |outfile|
      File.open(signature_enc, 'rb') do |inf|
        outfile << dec_cipher.update(buffer) while inf.read(4096, buffer)
        outfile << dec_cipher.final
      end
    end
  end

  def signature_enc
    File.join(
      Rails.root, 'app', 'assets', 'images', 'signatures', 'education.png.enc'
    )
  end

  def dec_cipher
    return @cipher if @cipher.present?

    @cipher = OpenSSL::Cipher.new('aes-256-cbc')
    @cipher.decrypt
    @cipher.key = Base64.decode64(ENV['SIGNATURE_KEY'])
    @cipher.iv = Base64.decode64(ENV['SIGNATURE_IV'])
    @cipher
  end
end
