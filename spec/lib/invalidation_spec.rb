# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Invalidation, type: :lib do
  let(:invalidation) { described_class.new(:files, 'dev/test_file') }

  context 'with a pending request' do
    it 'generates the correct environmented subdomain' do
      expect(invalidation.send(:subdomain)).to eql('files.development')
    end

    it 'generates the correct subdomain for production' do
      allow(ENV).to receive(:[]).with('ASSET_ENVIRONMENT').and_return('production')

      expect(invalidation.send(:subdomain)).to eql('files')
    end

    it 'fixes simple invalid keys' do
      expect(invalidation.keys.first).to eql('/dev/test_file')
    end

    it 'rejects unrecognizable invalid keys' do
      expect { described_class.new(:files, 'invalid&key') }.to raise_error(
        RuntimeError, 'Invalid key detected: invalid&key'
      )
    end

    it 'adds keys' do
      invalidation.add_keys('dev/something_else', '/dev/test_dir/')

      expect(invalidation.keys.sort).to eql(
        ['/dev/something_else', '/dev/test_dir/*', '/dev/test_file']
      )
    end
  end

  context 'with a submitted request' do
    let(:inv_hash) { described_class.submit(:files, 'dev/test_file') }

    it 'returns a pending invalidation' do
      expect(inv_hash[:result].invalidation.status).to eql('InProgress')
    end

    it 'detects a pending invalidation' do
      expect(described_class.new(:files).pending?).to be(true)
    end

    it 'lists invalidations' do
      list = described_class.list(:files, verbose: false)[:result]
      expect(list.invalidation_list.items[0].id).to eq('I3TUSXES93FBM3')
    end

    it 'gets the pending invalidation' do
      pending = described_class.pending(:files)[:result]
      expect(pending[0].status).to eq('InProgress')
    end

    it 'does not add keys' do
      inv_hash[:invalidation].add_keys('dev/something_else', '/dev/test_dir/')

      expect(invalidation.keys.sort).to eql(['/dev/test_file'])
    end
  end
end
