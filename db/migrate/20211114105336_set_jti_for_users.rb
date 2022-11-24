class SetJtiForUsers < ActiveRecord::Migration[5.2]
  def up
    User.find_each{ |u| u.update(jti: SecureRandom.base64) }
  end

  def down
  end
end
