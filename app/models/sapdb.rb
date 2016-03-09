class Sapdb < ActiveRecord::Base
  establish_connection :sapdb
  self.primary_key = 'mandt'
  self.table_name = 'sapsr3.tcstr'

end