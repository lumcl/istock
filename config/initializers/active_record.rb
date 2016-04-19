class ActiveRecord::Base
  self.primary_key = :uuid
  connection.raw_connection.recv_timeout = 10
  connection.raw_connection.send_timeout = 5

  before_create :assign_uuid

  private

  def assign_uuid
    if attributes.include?('uuid')
      self.uuid = UUID.new.generate(:compact) if uuid.nil?
    end
  end

end