# == Schema Information
#
# Table name: users
#
#  id         :integer          not null, primary key
#  mobile     :string(255)
#  password   :string(255)
#  auth_token :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
