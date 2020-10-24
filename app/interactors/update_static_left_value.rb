# frozen_string_literal: true

# Update left value of group role of static
class UpdateStaticLeftValue
  include Interactor

  # required context
  # context..group_role
  def call
    left_value = GroupRole.default
    context.group_role.value.each do |role, v|
      v['by_class'].each do |character_class, value|
        exist = approved_subscribes.count { |item| item[0] == role && item[1] == character_class }
        left_value[role]['by_class'][character_class] = value < exist ? 0 : (value - exist)
      end
    end
    context.group_role.update(left_value: left_value)
  end

  private

  def approved_subscribes
    @approved_subscribes ||= context.group_role.groupable.subscribes.includes(character: :character_class).where(status: 3).map { |subscribe| [modify(subscribe.for_role), subscribe.character.character_class.name['en'].downcase] }
  end

  def modify(role)
    case role
    when 'Tank' then 'tanks'
    when 'Healer' then 'healers'
    else 'dd'
    end
  end
end
