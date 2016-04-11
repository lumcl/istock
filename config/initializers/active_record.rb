class ActiveRecord::Base
  self.primary_key = :uuid
  connection.raw_connection.recv_timeout = 150
  connection.raw_connection.send_timeout = 10

  before_create :assign_uuid

  private

  def assign_uuid
    if attributes.include?('uuid')
      self.uuid = UUID.new.generate(:compact) if uuid.nil?
    end
  end

end