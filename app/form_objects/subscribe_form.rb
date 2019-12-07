# Represents form object for Subscribe model
class SubscribeForm
  include ActiveModel::Model
  include Virtus.model

  attribute :id, Integer
  attribute :subscribeable_id, Integer
  attribute :subscribeable_type, String
  attribute :character, Character
  attribute :status, Integer, default: 2
  attribute :comment, String, default: nil
  attribute :for_role, Integer, default: nil

  validates :subscribeable_id, :subscribeable_type, :character, :status, presence: true
  validates :subscribeable_type, inclusion: { in: %w[Event Static] }
  validates :status, inclusion: 0..4
  validates :for_role, inclusion: 0..2, allow_nil: true
  validates :comment, length: { maximum: 100 }, allow_nil: true
  validate :subscribeable_exists?

  attr_reader :subscribe

  def persist?
    self.status = status_to_integer
    self.for_role = for_role_nil_to_integer if for_role.nil?
    self.for_role = for_role_string_to_integer if for_role.is_a?(String)
    return false unless valid?
    @subscribe = id ? Subscribe.find_by(id: id) : Subscribe.new
    return false if @subscribe.nil?
    @subscribe.attributes = attributes.except(:id)
    @subscribe.save
    true
  end

  private

  def subscribeable_exists?
    return unless subscribeable_type.present?
    return if subscribeable_type.constantize.where(id: subscribeable_id).exists?
    errors[:subscribeable] << I18n.t('activemodel.errors.models.subscribe_form.attributes.subscribeable.is_not_exist')
  end

  def status_to_integer
    return status if status.is_a?(Integer)
    case status
      when 'reserve' then 4
      when 'approved' then 3
      when 'signed' then 2
      when 'unknown' then 1
      when 'rejected' then 0
    end
  end

  def for_role_string_to_integer
    case for_role
      when 'Dd' then 2
      when 'Healer' then 1
      when 'Tank' then 0
      else 2
    end
  end

  def for_role_nil_to_integer
    return nil if character.nil?
    return nil if character.roles.size.zero?
    main_role_name = character.roles.order(main: :desc)[0].name['en']
    case main_role_name
      when 'Melee' then 2
      when 'Ranged' then 2
      when 'Healer' then 1
      when 'Tank' then 0
    end
  end
end
