require 'test_helper'

class EnumExtensionsTest < ActiveSupport::TestCase

  setup do
    @book = books(:awdr)
  end

  test "module" do
    assert_kind_of Module, EnumExtensions
  end

  test "query state with strings" do
    assert_equal "proposed", @book.status
    assert_equal "unread", @book.read_status
  end

  test "update by setter" do
    @book.update! status: :written
    assert_equal 'written', @book.status
  end

  test "direct assignment" do
    @book.status = :written
    assert_equal 'written', @book.status
  end

  test "assign string value" do
    @book.status = "written"
    assert_equal 'written', @book.status
  end

  test "enum changed attributes" do
    old_status = @book.status
    @book.status = :published
    assert_equal old_status, @book.changed_attributes[:status]
  end

  test "enum changes" do
    old_status = @book.status
    @book.status = :published
    assert_equal [old_status, 'published'], @book.changes[:status]
  end

  test "enum attribute was" do
    old_status = @book.status
    @book.status = :published
    assert_equal old_status, @book.attribute_was(:status)
  end

  test "enum attribute changed" do
    @book.status = :published
    assert @book.attribute_changed?(:status)
  end

  test "enum attribute changed to" do
    @book.status = :published
    assert @book.attribute_changed?(:status, to: 'published')
  end

  test "enum attribute changed from" do
    old_status = @book.status
    @book.status = :published
    assert @book.attribute_changed?(:status, from: old_status)
  end

  test "enum attribute changed from old status to new status" do
    old_status = @book.status
    @book.status = :published
    assert @book.attribute_changed?(:status, from: old_status, to: 'published')
  end

  test "enum didn't change" do
    old_status = @book.status
    @book.status = old_status
    assert_not @book.attribute_changed?(:status)
  end

  test "persist changes that are dirty" do
    @book.status = :published
    assert @book.attribute_changed?(:status)
    @book.status = :written
    assert @book.attribute_changed?(:status)
  end

  test "reverted changes that are not dirty" do
    old_status = @book.status
    @book.status = :published
    assert @book.attribute_changed?(:status)
    @book.status = old_status
    assert_not @book.attribute_changed?(:status)
  end

  test "reverted changes are not dirty going from nil to value and back" do
    book = Book.create!(nullable_status: nil)

    book.nullable_status = :married
    assert book.attribute_changed?(:nullable_status)

    book.nullable_status = nil
    assert_not book.attribute_changed?(:nullable_status)
  end

  test "assign non existing value raises an error" do
    e = assert_raises(ArgumentError) do
      @book.status = :unknown
    end
    assert_equal "'unknown' is not a valid status", e.message
  end

  test "assign nil value" do
    @book.status = nil
    assert @book.status.nil?
  end

  test "assign empty string value" do
    @book.status = ''
    assert @book.status.nil?
  end

  test "assign long empty string value" do
    @book.status = '   '
    assert @book.status.nil?
  end

  test "constant to access the mapping" do
    assert_equal 0, Book.statuses[:proposed]
    assert_equal 1, Book.statuses["written"]
    assert_equal 2, Book.statuses[:published]
  end

  test "_before_type_cast returns the enum label (required for form fields)" do
    assert_equal "proposed", @book.status_before_type_cast
  end

  test "reserved enum names" do
    klass = Class.new(ActiveRecord::Base) do
      self.table_name = "books"
      enum status: [:proposed, :written, :published]
    end

    conflicts = [
      :column,     # generates class method .columns, which conflicts with an AR method
      :logger,     # generates #logger, which conflicts with an AR method
      :attributes, # generates #attributes=, which conflicts with an AR method
    ]

    conflicts.each_with_index do |name, i|
      assert_raises(ArgumentError, "enum name `#{name}` should not be allowed") do
        klass.class_eval { enum name => ["value_#{i}"] }
      end
    end
  end

  test "reserved enum values" do
    klass = Class.new(ActiveRecord::Base) do
      self.table_name = "books"
      enum status: [:proposed, :written, :published]
    end

    conflicts = [
      :new,      # generates a scope that conflicts with an AR class method
      :valid,    # generates #valid?, which conflicts with an AR method
      :save,     # generates #save!, which conflicts with an AR method
      :proposed, # same value as an existing enum
      :public, :private, :protected, # some important methods on Module and Class
      :name, :parent, :superclass
    ]

    conflicts.each_with_index do |value, i|
      assert_raises(ArgumentError, "enum value `#{value}` should not be allowed") do
        klass.class_eval { enum "status_#{i}" => [value] }
      end
    end
  end

  test "validate uniqueness" do
    klass = Class.new(ActiveRecord::Base) do
      def self.name; 'Book'; end
      enum status: [:proposed, :written]
      validates_uniqueness_of :status
    end
    klass.delete_all
    klass.create!(status: "proposed")
    book = klass.new(status: "written")
    assert book.valid?
    book.status = "proposed"
    assert_not book.valid?
  end

  test "validate inclusion of value in array" do
    klass = Class.new(ActiveRecord::Base) do
      def self.name; 'Book'; end
      enum status: [:proposed, :written]
      validates_inclusion_of :status, in: ["written"]
    end
    klass.delete_all
    invalid_book = klass.new(status: "proposed")
    assert_not invalid_book.valid?
    valid_book = klass.new(status: "written")
    assert valid_book.valid?
  end

  test "enums are distinct per class" do
    klass1 = Class.new(ActiveRecord::Base) do
      self.table_name = "books"
      enum status: [:proposed, :written]
    end

    klass2 = Class.new(ActiveRecord::Base) do
      self.table_name = "books"
      enum status: [:drafted, :uploaded]
    end

    book1 = klass1.proposed.create!
    book1.status = :written
    assert_equal ['proposed', 'written'], book1.status_change

    book2 = klass2.drafted.create!
    book2.status = :uploaded
    assert_equal ['drafted', 'uploaded'], book2.status_change
  end

  test "enums are inheritable" do
    subklass1 = Class.new(Book)

    subklass2 = Class.new(Book) do
      enum status: [:drafted, :uploaded]
    end

    book1 = subklass1.create! status: :proposed
    book1.status = :written
    assert_equal ['proposed', 'written'], book1.status_change

    book2 = subklass2.create! status: :drafted
    book2.status = :uploaded
    assert_equal ['drafted', 'uploaded'], book2.status_change
  end

end
