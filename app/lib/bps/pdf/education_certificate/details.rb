# frozen_string_literal: true

module BPS
  module PDF
    class EducationCertificate
      module Details
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
          EncryptedKeystore.decrypt(
            file: Rails.root.join('app/assets/images/signatures/education.png.enc'),
            out: Rails.root.join('tmp', 'run', 'signature.png'),
            key: ENV.fetch('SIGNATURE_KEY', nil), iv: ENV.fetch('SIGNATURE_IV', nil)
          )
        end
      end
    end
  end
end
