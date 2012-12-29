class PartLayout < ActiveRecord::Base
  attr_accessible :operator, :layout, :layout_attributes

  belongs_to :part, :class_name => 'Admin::Merchandise::Part'

  has_one :layout, :class_name => 'ImageLayout', :as => :layout
  accepts_nested_attributes_for :layout

  def x
    layout.x.to_i
  end

  def y
    layout.y.to_i
  end

  def w
    layout.w.to_i
  end

  def h
    layout.h.to_i
  end

  def size
    return layout.w, layout.h
  end

  # draw the scr_image onto the part_image background
  def draw_piece(part_image, src_image)
    layout.draw_piece(part_image, src_image)
  end

  # draw the scr_image onto the part_image background
  def draw_custom_part(part_image, src_image)
    layout.draw_custom_part(part_image, src_image)
  end

end