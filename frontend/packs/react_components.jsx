import WebpackerReact from "webpacker-react";

import ActivitiesList from "components_react/activities_list/activities_list";
import ActivityForm from "components_react/activity_form/activity_form";
import CharacterEquipmentImport from "components_react/character_equipment_import/character_equipment_import";
import CharacterForm from "components_react/character_form/character_form";
import CharacterTransferForm from "components_react/character_transfer_form/character_transfer_form";
import Craft from "components_react/craft/craft";
import DeliveryForm from "components_react/delivery_form/delivery_form";
import EventCalendar from "components_react/event_calendar/event_calendar";
import EventForm from "components_react/event_form/event_form";
import GuildBankImport from "components_react/guild_bank_import/guild_bank_import";
import GuildBank from "components_react/guild_bank/guild_bank";
import GuildForm from "components_react/guild_form/guild_form";
import Guild from "components_react/guild/guild";
import GuildsList from "components_react/guilds_list/guilds_list";
import InviteFormForCharacter from "components_react/invite_form_for_character/invite_form_for_character";
import InviteFormForGuild from "components_react/invite_form_for_guild/invite_form_for_guild";
import LineUp from "components_react/line_up/line_up";
import RecipeForm from "components_react/recipe_form/recipe_form";
import RecipeUploader from "components_react/recipe_uploader/recipe_uploader";
import RecipesList from "components_react/recipes_list/recipes_list";
import RequestToGuild from "components_react/request_to_guild/request_to_guild";
import RequestToStatic from "components_react/request_to_static/request_to_static";
import StaticForm from "components_react/static_form/static_form";
import StaticInviteFormForCharacter from "components_react/static_invite_form_for_character/static_invite_form_for_character";
import StaticManagement from "components_react/static_management/static_management";
import Static from "components_react/static/static";
import StaticsList from "components_react/statics_list/statics_list";
import UserPassword from "components_react/user_password/user_password";
import UserSettings from "components_react/user_settings/user_settings";

WebpackerReact.setup({
  ActivitiesList, ActivityForm, CharacterEquipmentImport, CharacterForm, CharacterTransferForm, Craft, DeliveryForm,
  EventCalendar, EventForm, GuildBankImport, GuildBank, GuildForm, Guild, GuildsList, InviteFormForCharacter, InviteFormForGuild,
  LineUp, RecipeForm, RecipeUploader, RecipesList, RequestToGuild, RequestToStatic, StaticForm, StaticInviteFormForCharacter,
  StaticManagement, Static, StaticsList, UserPassword, UserSettings
});
