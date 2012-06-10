class Shopping::Address < ActiveRecord::Base
  belongs_to :state
  belongs_to :cart, :class_name => 'Shopping::Cart'

  attr_accessible :cart_id, :cart,
                  :first_name, :last_name,
                  :address1, :address2, :city, :state, :state_id, :zip_code

  accepts_nested_attributes_for :cart

  validates_presence_of :cart
  validates_presence_of :address1
  validates_presence_of :city
  validates_presence_of :state
  validates_presence_of :zip_code

  before_save :check

  private #=================================================================================

  def check
    puts "save=>#{self.inspect}"
  end

end