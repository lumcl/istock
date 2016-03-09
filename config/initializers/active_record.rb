class ActiveRecord::Base
  self.primary_key = :uuid
  before_create :assign_uuid

  private

  def assign_uuid
    if attributes.include?('uuid')
      self.uuid = UUID.new.generate(:compact) if uuid.nil?
    end
  end

end