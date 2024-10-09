class ZipCodeValidationService
  VALID_ZIP_CODE_REGEX = /^\d{5}$/.freeze

  def self.valid?(zip_code)
    new(zip_code).valid?
  end

  def initialize(zip_code)
    @zip_code = zip_code
  end

  def valid?
    !!(VALID_ZIP_CODE_REGEX.match(@zip_code))
  end
end
