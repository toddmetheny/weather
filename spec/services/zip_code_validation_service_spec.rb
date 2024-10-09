require 'rails_helper'

RSpec.describe ZipCodeValidationService, type: :service do
  describe '.valid?' do
    subject { described_class.valid?(zip_code) }

    context 'when the zip code is valid' do
      let(:zip_code) { '12345' }

      it 'returns true' do
        expect(subject).to be true
      end
    end

    context 'when the zip code is invalid' do
      context 'when the zip code has fewer than 5 digits' do
        let(:zip_code) { '1234' }

        it 'returns false' do
          expect(subject).to be false
        end
      end

      context 'when the zip code has more than 5 digits' do
        let(:zip_code) { '123456' }

        it 'returns false' do
          expect(subject).to be false
        end
      end

      context 'when the zip code contains non-numeric characters' do
        let(:zip_code) { '12a45' }

        it 'returns false' do
          expect(subject).to be false
        end
      end

      context 'when the zip code is an empty string' do
        let(:zip_code) { '' }

        it 'returns false' do
          expect(subject).to be false
        end
      end
    end
  end
end
