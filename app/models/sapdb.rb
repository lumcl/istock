class Sapdb < ActiveRecord::Base
  establish_connection :sapdb
  connection.raw_connection.recv_timeout = 300
  connection.raw_connection.send_timeout = 10
  self.primary_key = 'mandt'
  self.table_name = 'sapsr3.tcstr'

end