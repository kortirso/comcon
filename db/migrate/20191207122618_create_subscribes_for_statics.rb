class CreateSubscribesForStatics < ActiveRecord::Migration[5.2]
  def change
    Static.all.each do |static|
      static.characters.each do |character|
        CreateSubscribe.call(subscribeable: static, character: character, status: 4)
      end
    end
  end
end
