# Update left value of group role of static
class UpdateStaticLeftValue
  include Interactor

  # required context
  # context.static
  def call
    left_value = GroupRole.default
    context.static.group_role.value.each do |role, v|
      v['by_class'].each do |character_class, value|
        exist = approved_subscribes.select { |item| item[0] == role && item[1] == character_class }.size
        left_value[role.to_sym][:by_class][character_class.to_sym] = value < exist ? 0 : (value - exist)
      end
    end
    context.static.group_role.update(left_value: left_value)
  end

  private

  def approved_subscribes
    @approved_subscribes ||= context.static.subscribes.includes(character: :character_class).where(status: 3).map { |subscribe| [modify(subscribe.for_role), subscribe.character.character_class.name['en'].downcase] }
  end

  def modify(role)
    case role
      when 'Tank' then 'tanks'
      when 'Healer' then 'healers'
      else 'dd'
    end
  end
end
