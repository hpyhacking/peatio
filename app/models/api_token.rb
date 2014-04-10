class APIToken < ActiveRecord::Base

  belongs_to :member

  validates_presence_of :access_key, :secret_key

  before_validation :generate_keys, on: :create

  private

  def generate_keys
    self.access_key = APIv2::Auth::Utils.generate_access_key
    self.secret_key = APIv2::Auth::Utils.generate_secret_key
  end

end
