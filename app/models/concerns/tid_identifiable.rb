module TIDIdentifiable
  extend ActiveSupport::Concern

  included do
    validates :tid, presence: true, uniqueness: { case_sensitive: false }

    before_validation do
      next unless tid.blank?
      begin
        self.tid = "TID#{SecureRandom.hex(5).upcase}"
      end while self.class.where(tid: tid).any?
    end

    before_validation { self.tid = tid.to_s.upcase }
  end
end
