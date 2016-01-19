class Report < ActiveRecord::Base
  include FillReport

  belongs_to :user
end
