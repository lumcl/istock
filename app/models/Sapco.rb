class Sapco < ActiveRecord::Base
  establish_connection :sapco
  connection.raw_connection.recv_timeout = 150
  connection.raw_connection.send_timeout = 10
  self.primary_key = 'rid'
  self.table_name = 'it.tlog'
end