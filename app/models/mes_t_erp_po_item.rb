class MesTErpPoItem < ActiveRecord::Base
  establish_connection :leimes
  connection.raw_connection.recv_timeout = 10
  connection.raw_connection.send_timeout = 5
  self.primary_key = 'item_sn'
  self.table_name = 't_erp_po_item'

end