class User < ActiveRecord::Base
  self.primary_key = :uuid
  self.table_name ='users'

  belongs_to :printer, class_name: 'Printer', foreign_key: 'printer_id'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable,:registerable,
  # :validatable

  devise :database_authenticatable, :recoverable, :rememberable, :trackable


  def name
    username
  end

  def to_s
    username
  end
end
