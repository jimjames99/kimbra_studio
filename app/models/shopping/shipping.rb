class Shopping::Shipping < ActiveRecord::Base

  belongs_to :cart, class_name: 'Shopping::Cart'

  attr_accessible :cart_id, :cart,
                  :shipping_option_name, :tracking, :amount

  # Note that :shipping_option_name is not a foreign key here. That's because shipping options will change over
  # time (names, descriptions and prices) and we do not want/need to maintain an audit trail of these.
  # So, all we are doing is using ShippingOption as a reference table of the values (as opposed to row ids)
  # to be inserted into the fields here. That way, ShippingOptions can change in the future but older
  #values in this Shipping table are not (incorrectly) updated. Clear as mud?

  accepts_nested_attributes_for :cart

  # 1Z xxx xxx yy zzzz zzz c
  # xxx xxx is the alphanumeric account number of the shipper, Kimbra's: A51 47X
  # yy is the service code
  # UPS Standard 	11
  # UPS Ground 	03
  # UPS 3 Day Select 	12
  # UPS 2nd Day Air 	02
  # UPS 2nd Day Air AM 	59
  # UPS Next Day Air Saver 	13
  # UPS Next Day Air 	01
  # 01	UPS United States Next Day Air ("Red")
  # 02	UPS United States Second Day Air ("Blue")
  # 03	UPS United States Ground
  # 12	UPS United States Third Day Select
  # 13	UPS United States Next Day Air Saver ("Red Saver")
  # 15	UPS United States Next Day Air Early A.M.
  # 22	UPS United States Ground - Returns Plus - Three Pickup Attempts
  # 32	UPS United States Next Day Air Early A.M. - COD
  # 33	UPS United States Next Day Air Early A.M. - Saturday Delivery, COD
  # 41	UPS United States Next Day Air Early A.M. - Saturday Delivery
  # 42	UPS United States Ground - Signature Required
  # 44	UPS United States Next Day Air - Saturday Delivery
  # 66	UPS United States Worldwide Express
  # zzzz zzz is the package identifier
  # c is a checksum
  @tracking_regex = /\b(1Z ?[0-9A-Z]{3} ?[0-9A-Z]{3} ?[0-9A-Z]{2} ?[0-9A-Z]{4} ?[0-9A-Z]{3} ?[0-9A-Z]|[\dT]\d\d\d ?\d\d\d\d ?\d\d\d)\b/i

  validates :cart, :shipping_option_name, :amount, presence: true
  validates :tracking,
            format: {with: @tracking_regex, message: 'UPS tracking numbers look like 1Z xxx xxx yy zzzz zzz c'},
            :if     => Proc.new { |shipping| shipping.tracking.present? }
  validate :valid_checksum_for_tracking

  before_save :set_amount
  after_save :update_cart_invoice

          # amount in dollars
  def total
    amount / 100.0
  end

  def tracking=(trk)
    if trk
      trk.upcase!
      trk.gsub!(/[^\w^\d]/, '')
      trk.gsub!(/\s/, '')
    end
    write_attribute :tracking, trk
  end

  def valid_checksum_for_tracking
    unless valid_checksum?
      errors.add(:tracking, 'number digits do not agree with checksum - check your number')
    end if tracking.present?
  end

  def checksum
    sequence = tracking.slice(2...17)
    total    = 0
    sequence.chars.each_with_index do |c, i|
      x = if c[/[0-9]/] # numeric
            c.to_i
          else
            (c[0].ord - 3) % 10
          end
      x *= 2 if i.odd?
      total += x
    end
    check = (total % 10)
    check = (10 - check) unless (check.zero?)
    check.to_i
  end

  private #====================================================================================

  def valid_checksum?
    check_digit = tracking.slice(17, 18)
    checksum == check_digit.to_i
  end

  # monitor if shipping_option_name changed so we can recalc cart invoice_total
  def set_amount
    # who is setting the amount when the shipping_option_name changes?
    if @update_cart_invoice = shipping_option_name_changed?
      # need to recalculate cart invoice for new shipping_option_name
      shipping_option = ShippingOption.find_by_name(shipping_option_name)
      raise "snap:: shipping_option_name:#{shipping_option_name} does not exist?" if shipping_option.nil?
      self.amount = shipping_option.cost_cents
    end
    true
  end

  def update_cart_invoice
    if (@update_cart_invoice)
      cart.shipping_changed = true
      cart.save
    end
    true
  end
end