class Barcode < ActiveRecord::Base
  self.primary_key = :uuid
  belongs_to :stock_master
  belongs_to :parent, class_name: 'Barcode', foreign_key: 'parent_id', primary_key: 'uuid'

  def self.test
    str =
        "
        ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD15^JUS^LRN^CI0^XZ
        ^XA
        ^MMT
        ^PW900
        ^LL0600
        ^LS0
        ^FT20,494^A0N,42,196^FH\^FDfff^FS
        ^FT20,417^A0N,42,196^FH\^FDfff^FS
        ^FT22,339^A0N,42,196^FH\^FDfff^FS
        ^FT25,267^A0N,42,196^FH\^FDfff^FS
        ^FT28,185^A0N,42,196^FH\^FDfff^FS
        ^FT28,91^A0N,42,196^FH\^FDfff^FSb
        ^BY4,3,236^FT594,264^BCN,,Y,N
        ^FD>;123456^FS
        ^FT344,128^A0N,42,40^FH\^FDdfdsf^FS
        ^PQ1,0,1,Y^XB^XZ
    "
    s = TCPSocket.new('172.91.8.56','9100')
    s.write str
    s.close
  end

  def self.finish_goods_label(hash)
    lab1 = "
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD20^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW945
      ^LL0768
      ^LS0
      ^FT130,340^BQN,2,7
      ^FDLA,#{hash[:id]}^FS
      ^FT667,350^A0B,33,33^FH\^FDDate^FS
      ^FT749,355^A0B,75,74^FH\^FD#{hash[:date]}^FS
      ^FT247,763^A0B,33,33^FH\^FDDate Code^FS
      ^FT335,763^A0B,75,74^FH\^FD#{hash[:date_code]}^FS
      ^FT376,225^A0B,33,33^FH\^FDPlant^FS
      ^FT466,225^A0B,75,74^FH\^FD#{hash[:factory]}^FS
      ^FT390,763^A0B,33,33^FH\^FDLot No^FS
      ^FT473,763^A0B,75,74^FH\^FD#{hash[:lot_no]}^FS
      ^FT127,763^A0B,33,33^FH\^FDMO^FS
      ^FT666,768^A0B,33,33^FH\^FDQuantity^FS
      ^FT193,763^A0B,75,74^FH\^FD#{hash[:mo]}^FS
    "
    lab1_1 = ""
    if hash[:product_no].to_s.eql?'MH30-V1120-K00S-C' or hash[:product_no].to_s.eql?'MH30-V1120-K02S-C' or hash[:product_no].to_s.eql?'MH30-21120-K00S-C' or hash[:product_no].to_s.eql?'MH30-21120-300S-C' or hash[:product_no].to_s.eql?'MH30-V1120-K05S-C' or hash[:product_no].to_s.eql?'MH18-V1120-K20S-C'
      lab1_1 = "^FT529,768^A0B,33,33^FH\^FD^FS"
    else
      lab1_1 = "^FT529,768^A0B,33,33^FH\^FDLEI Product No^FS"
    end
    lab2 = "
      ^FT855,768^A0B,28,50^FH\^FD#{hash[:name]}^FS
      ^FT871,532^A0B,55,67^FH\^FD**#{hash[:seq]}**^FS
      ^FT808,768^A0B,28,50^FH\^FD#{hash[:name_parent]}^FS
      ^FT806,425^A0B,38,50^FH\^FD**#{hash[:seq_parent]}**^FS
    "
    if hash[:seq_parent].blank?
      lab2 = "
      ^FT901,768^A0B,50,50^FH\^FD#{hash[:name]}^FS
      ^FT901,414^A0B,50,50^FH\^FD**#{hash[:seq]}**^FS
     "

    end
    lab3 = "
      ^FT744,768^A0B,75,74^FH\^FD#{hash[:qty]} #{hash[:meins]}^FS
    "
    if hash[:product_no].to_s.eql?'MH30-V1120-K00S-C' or hash[:product_no].to_s.eql?'MH30-V1120-K02S-C' or hash[:product_no].to_s.eql?'MH30-21120-K00S-C' or hash[:product_no].to_s.eql?'MH30-21120-300S-C'
      lab3_2 = "^FT615,768^A0B,58,57^FH\^FD^FS"
    else
      lab3_2 = "^FT615,768^A0B,58,57^FH\^FD#{hash[:product_no]}^FS"
    end

    lab3_3 = "
      ^FT135,763^A0B,75,74^FH\^FD^FS
      ^PQ1,0,1,Y#{hash[:xb]}^XZ
    "
    lab = lab1 +lab1_1 + lab2 + lab3 + lab3_2 + lab3_3
    finish_goods_label_end lab
  end

  def self.finish_storage_label(hash)
    lab1 = "
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD20^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW945
      ^LL0768
      ^LS0
      ^FT531,574^BQN,2,10
      ^FDLA,#{hash[:name]}^FS
      ^FT368,721^A0B,130,74^FH\^FD#{hash[:name]}^FS
      ^FT135,763^A0B,75,74^FH\^FDLeader Electronics Inc^FS
      ^PQ1,0,1,Y#{hash[:xb]}^XZ
    "
    finish_goods_label_end lab1
  end

  def self.finish_goods_label_end(str)
     str
  end

  def self.finish_goods_label_old(hash)
    "
      ^XA~TA000~JSN^LT0^MNW^MTT^PON^PMN^LH0,0^JMA^PR4,4~SD20^JUS^LRN^CI0^XZ
      ^XA
      ^MMT
      ^PW945
      ^LL0768
      ^LS0
      ^FT154,276^BQN,2,7
      ^FDLA,http://bc.l-e-i.com:3088/bc/#{hash[:id]}^FS
      ^FT695,345^A0B,33,33^FH\^FDDate^FS
      ^FT773,344^A0B,75,74^FH\^FD#{hash[:date]}^FS
      ^FT270,763^A0B,33,33^FH\^FDDate Code^FS
      ^FT359,763^A0B,75,74^FH\^FD#{hash[:date_code]}^FS
      ^FT414,763^A0B,33,33^FH\^FDLot No^FS
      ^FT496,763^A0B,75,74^FH\^FD#{hash[:lot_no]}^FS
      ^FT151,763^A0B,33,33^FH\^FDMO^FS
      ^FT694,763^A0B,33,33^FH\^FDQuantity^FS
      ^FT217,763^A0B,75,74^FH\^FD#{hash[:mo]}^FS
      ^FT557,763^A0B,33,33^FH\^FDLEI Product No^FS
      ^FT772,763^A0B,75,74^FH\^FD#{hash[:qty]}^FS
      ^FT644,763^A0B,75,74^FH\^FD#{hash[:product_no]}^FS
      ^FT100,763^A0B,75,74^FH\^FDLeader Electronics Inc^FS
      ^BY5,3,94^FT885,768^B3B,N,,Y,N
      ^FD#{hash[:id]}^FS
      ^PQ1,0,1,Y^XZ
    "
  end

  def self.in_scan(uuid, storage)
    sql = "
      select a.uuid,a.seq,a.name,a.menge,b.matnr,b.charg
        from barcode a join stock_master b on b.uuid = a.stock_master_id
        where a.uuid = ?
    "
    rows = Barcode.find_by_sql [sql, params[:barcode]]

    if rows.present?
      row = rows.first
    end
  end

end
