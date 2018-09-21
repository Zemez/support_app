class User < ActiveRecord::Base
  CUSTOMER_USER_ID = 1

  def support?
    role == SUPPORT_ROLE_ID
  end
end
