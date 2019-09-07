#!/usr/bin/env ruby

require "json"
require "pry-byebug"

BANK_SIZE = Integer("4000", 16)

ROM_FILE = "./pokecrystal.gbc"
DEFAULT_SYM_FILE = "./pokecrystal.sym"
OUT_FILE = "./pokecrystal-label-details.json"

HIDDEN_ITEMS = ["MACHINE_PART"]
ITEM_BALLS = %w(COIN_CASE HM_WATERFALL)
GIVE_ITEMS = %w(BICYCLE RED_SCALE SECRETPOTION LOST_ITEM MYSTERY_EGG)
VERBOSE_GIVE_ITEMS = %w(SQUIRTBOTTLE BLUE_CARD BASEMENT_KEY CLEAR_BELL
                        OLD_ROD HM_WHIRLPOOL HM_CUT S_S_TICKET
                        CARD_KEY SUPER_ROD HM_SURF ITEMFINDER GOOD_ROD
                        HM_STRENGTH HM_FLASH PASS SILVER_WING HM_FLY)
CHECK_EVENT = %w(EVENT_RESTORED_POWER_TO_KANTO SAFFRON_EVENT_RESTORED_POWER_TO_KANTO)
SET_EVENT = %w(EVENT_ROUTE_30_YOUNGSTER_JOEY EVENT_ROUTE_30_BATTLE EVENT_OLIVINE_PORT_SPRITES_AFTER_HALL_OF_FAME)
IF_EQUAL_WEEKDAY = %w(WEEKDAY_SATURDAY WEEKDAY_SUNDAY WEEKDAY_TUESDAY WEEKDAY_WEDNESDAY WEEKDAY_THURSDAY)

def sym_file
  ARGV[0] || DEFAULT_SYM_FILE
end

def rom
  @rom ||= IO.binread(ROM_FILE)
end

def byte_to_string(byte)
  "$#{byte.ord.to_s(16)}"
end

def label_hex_addresses
  File
    .read(sym_file)
    .split("\n")
    .select { |l| l.include?("ckir") }
    .map { |line| line.split(" ") }
    .map { |address, label| [label, address] }
end

def label_addresses
  @label_addresses ||= Hash[label_hex_addresses.map do |label, hex_address|
    bank, internal_address = hex_address.split(":").map { |val| Integer(val, 16) }
    address = (internal_address % BANK_SIZE) + (bank * BANK_SIZE)
    [label, address]
  end]
end

def main
  key_item_address_ranges =
    label_addresses
      .keys
      .reject { |label| label.include?("AFTER") }
      .map do |label|
        post_label = label.gsub("ckir_BEFORE", "ckir_AFTER")
        address_range = label_addresses[label]...label_addresses[post_label]
        key_item =
          if label.include?("RECV_")
            label.split("RECV_").last
          elsif label.include?("CHECK_")
            label.split("CHECK_").last
          elsif label.include?("SET_")
            label.split("SET_").last
          elsif label.include?("IFEQUAL_")
            label.split("IFEQUAL_").last
          else
            label
          end
        [key_item, address_range]
      end

  key_item_details =
    key_item_address_ranges.map do |key_item, address_range|
      {
        "name" => key_item,
        "address_range" => { "begin" => address_range.begin, "end" => address_range.end },
        # "values" => rom[address_range], # it's difficult to write out raw bytes :(
        "integer_values" => rom[address_range].split('').map(&:bytes).flatten.join(" "),
        "hex_values" => rom[address_range].each_char.map(&method(:byte_to_string)).join(" "),
      }
    end.sort_by { |details| details["name"] }

  File.write(OUT_FILE, key_item_details.to_json)

  puts "generated #{OUT_FILE}"
end

main
