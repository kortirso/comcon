# Import data for guild bank
class ImportGuildBankData
  include Interactor::Organizer

  organize FindOrCreateBank, UpdateBankCells
end
