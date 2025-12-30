class Current < ActiveSupport::CurrentAttributes
  attribute :user, :tenant, :plan
end
