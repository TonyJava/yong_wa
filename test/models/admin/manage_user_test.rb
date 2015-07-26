# == Schema Information
#
# Table name: admin_manage_users
#
#  id         :integer          not null, primary key
#  user_name  :string(255)
#  password   :string(255)
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'test_helper'

class Admin::ManageUserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
end
