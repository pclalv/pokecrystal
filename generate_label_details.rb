#!/usr/bin/env ruby

require "json"

BANK_SIZE = Integer("4000", 16)

OUT_FILE = "./pokecrystal-label-details"
ROM_FILE = "./pokecrystal.gbc"
# file should be a list of only the address labels you wanna compute -
# basically a subset of pokecrystal.sym, in this case obtained by
# grepping for "pclalv"
DEFAULT_SYM_FILE = "./pokecrystal.original.address_labels"

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

def label_hex_addresses
  File
    .read(sym_file)
    .split("\n")
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
      .reject { |label| label.include?("POST") }
      .map do |label|
        post_label = label.gsub("pclalv", "pclalv_POST")
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
      case key_item
      when *VERBOSE_GIVE_ITEMS
        address = address_range.begin + 1
        instruction = "verbosegiveitem"
      when *GIVE_ITEMS
        address = address_range.begin + 1
        instruction = "giveitem"
      when *ITEM_BALLS
        address = address_range.begin
        instruction = "itemball"
      when *HIDDEN_ITEMS
        address = address_range.last - 1 # all ranges are exclusive
        instruction = "hiddenitem"
      when *CHECK_EVENT
        address = address_range.begin + 1
        instruction = "checkevent"
      when *SET_EVENT
        address = address_range.begin + 1
        instruction = "setevent"
      when *IF_EQUAL_WEEKDAY
        address = address_range.begin + 2
        instruction = "ifequal"
      else
        puts "unknown key item #{key_item}; skipping"
      end

      {
        "name" => key_item,
        "address_range" => { "begin" => address_range.begin, "end" => address_range.end },
        "address" => address,
        "value" => address && rom[address].ord,
        "hex_value" => address && byte_to_string(rom[address]),
        "hex_values" => rom[address_range].each_char.map(&method(:byte_to_string)).join(" "),
        "instruction" => instruction,
      }
    end.sort_by { |details| details["name"] }

  File.write(OUT_FILE + ".json", key_item_details.to_json)
  puts "generated #{OUT_FILE}.json"
end

def byte_to_string(byte)
  "$#{byte.ord.to_s(16)}"
end

main
