class Book < ActiveRecord::Base

  simple_enum status: [ :proposed, :written, :published ]
  simple_enum read_status: { unread: 0, reading: 2, read: 3 }
  simple_enum nullable_status: [ :single, :married ]

end
