#Script de lootboxes creado por Nyaruko
#Si metes micropagos no me hago responsable

#edited, heavily #by low
COMMON     = [:POTION,:POKEBALL,:ANTIDOTE,:BURNHEAL,:PARALYZEHEAL,:ICEHEAL]
UNCOMMON   = [:AWAKENING,:GREATBALL,:HPUP,:PROTEIN,:IRON,:CALCIUM,:ZINC,:CARBOS]
RARE       = [:FULLHEAL,:ULTRABALL,:HYPERPOTION,:STARDUST]
SUPER_RARE = [:REVIVE,:QUICKBALL,:SHINYBERRY,:STARPIECE]
ULTRA_RARE = [:SACREDASH,:MASTERBALL,:COMETSHARD]
PENIS_RARE = %w[TicketA TicketB TicketC]
POSSIBLE_TICKETS = %w[TicketA TicketB TicketC GoldMilageTicket]
TICKETS_ARRAY = [[:PACUNA, 0, :LEFTOVERS],[:PACUNA, 1, :STICKYBARB],[:PACUNA, 1, :STICKYBARB]] 
# (pokeman, ability_index, item, form)
GACHA_USED = 97
GACHA_TIME = 96

# LootBox.new.pbStartMainScene on a npc

class LootBox
  def pbStartMainScene
    if $PokemonGlobal.ticketStorage.nil?
      $PokemonGlobal.ticketStorage = []
    end
    viewport = Viewport.new(0,0,Graphics.width,Graphics.height)
    viewport.z = 99999

    $game_variables[GACHA_TIME] = Time.now.to_i
    gachaamt = $game_variables[GACHA_USED]
    random0 = semiRandomRNG(85..100, gachaamt)
    
    common     = COMMON
    uncommon   = UNCOMMON
    rare       = RARE
    s_rare     = SUPER_RARE
    u_rare     = ULTRA_RARE
    p_rare     = PENIS_RARE
    
    sprites={}
    sprites["bg"]=Sprite.new
    sprites["bg"].z=99998
    sprites["bg"].bitmap = RPG::Cache.load_bitmap("Graphics/Pictures/Lootboxes/","background")
    
    sprites["bolsa"]=IconSprite.new(0,0,viewport)
    sprites["bolsa"].setBitmap("Graphics/Pictures/Lootboxes/bag_closed")
    sprites["bolsa"].x = 157
    sprites["bolsa"].y = 256
    
    sprites["item1"]=IconSprite.new(0,0,viewport)    
    sprites["item1"].x = 227
    sprites["item1"].y = 135
    
    sprites["item2"]=IconSprite.new(0,0,viewport)    
    sprites["item2"].x = 99
    sprites["item2"].y = 135
    
    sprites["item3"]=IconSprite.new(0,0,viewport)   
    sprites["item3"].x = 355
    sprites["item3"].y = 135

    sprites["icon1"] = ItemIconSprite.new(0, 0, nil, viewport)
    sprites["icon1"].x = 260
    sprites["icon1"].y = 195
    
    sprites["icon2"] = ItemIconSprite.new(0, 0, nil, viewport)
    sprites["icon2"].x = 134
    sprites["icon2"].y = 195
    
    sprites["icon3"] = ItemIconSprite.new(0, 0, nil, viewport)
    sprites["icon3"].x = 389
    sprites["icon3"].y = 195
    
    sprites["overlay"]=BitmapSprite.new(Graphics.width, Graphics.height, viewport)
    
    loop do
      Graphics.update
      Input.update
      #if Input.trigger?(Input::C)
        pbSEPlay("select")
        pbWait(20)
        sprites["bolsa"].setBitmap("Graphics/Pictures/Lootboxes/bag_open")
        for i in 1..3
          gachaamt = $game_variables[GACHA_USED]
          random_val = semiRandomRNG(random0, gachaamt)
          if Time.now.to_i - $game_variables[GACHA_TIME] > 172800 # 2 days
            random_val = random_val * 0.8
            random_val = random_val.to_i
          end
          $game_variables[GACHA_USED] += 1
          random_val = 0 if i == 3 && $game_variables[GACHA_USED] == 3

          case random_val
            when 0..3 # 4
              sprites["item#{i}"].setBitmap("Graphics/Pictures/Lootboxes/item_p_rare")
              pbWait(20)
              pokeman = semiRandomRNG(p_rare.length, gachaamt)
              sprites["icon#{i}"].item = GameData::Item.get(:GOLDTICKET).id
              pbMessage(_INTL("\\me[{1}]You obtained a \\c[1]{2}\\c[0]!\\wtnp[30]", "Item get", p_rare[pokeman].to_s))
              $PokemonGlobal.ticketStorage.push(p_rare[pokeman])
            when 4..10 # 6
              sprites["item#{i}"].setBitmap("Graphics/Pictures/Lootboxes/item_u_rare")
              pbWait(20)
              item = semiRandomRNG(u_rare.length, gachaamt)
              sprites["icon#{i}"].item = GameData::Item.get(u_rare[item]).id
              pbReceiveItem(u_rare[item])
            when 11..21 # 10
              sprites["item#{i}"].setBitmap("Graphics/Pictures/Lootboxes/item_s_rare")
              pbWait(20)
              item = semiRandomRNG(s_rare.length, gachaamt)
              sprites["icon#{i}"].item = GameData::Item.get(s_rare[item]).id
              pbReceiveItem(s_rare[item])
            when 22..42 # 20
              sprites["item#{i}"].setBitmap("Graphics/Pictures/Lootboxes/item_rare")
              pbWait(20)
              item = semiRandomRNG(rare.length, gachaamt)
              sprites["icon#{i}"].item = GameData::Item.get(rare[item]).id
              pbReceiveItem(rare[item])
            when 48..78 # 25
              sprites["item#{i}"].setBitmap("Graphics/Pictures/Lootboxes/item_uncommon")
              pbWait(20)
              item = semiRandomRNG(uncommon.length, gachaamt)
              sprites["icon#{i}"].item = GameData::Item.get(uncommon[item]).id
              pbReceiveItem(uncommon[item])
            else        # 35
              sprites["item#{i}"].setBitmap("Graphics/Pictures/Lootboxes/item_common")
              pbWait(20)
              item = semiRandomRNG(common.length, gachaamt)
              sprites["icon#{i}"].item = GameData::Item.get(common[item]).id
              pbReceiveItem(common[item])
            end
        end
        pbWait(10)
        pbFadeOutAndHide(sprites){pbUpdateSpriteHash(sprites)}
        pbDisposeSpriteHash(sprites)
        viewport.dispose if viewport
        break
     # end  
    end  
  end
end

def ticketExchangeNPC
  commands = []
  commands.push(_INTL("My Tickets"))
  counts = Hash.new(0)
  $PokemonGlobal.ticketStorage.each { |str| counts[str] += 1 }
  resultsCommander = {
    "TicketA" => "HexSex",
    "TicketB" => "ZinniaPlush",
    "TicketC" => "EleggFigurine"
  }
  duped=gold=false
  counts.each do |str, count|
    if str == "GoldMilageTicket"
      gold=true if count > 4
    else
      commands.push(_INTL("A #{str} for 1 #{resultsCommander[str]}")) if count >= 1
      duped=true if count > 1
    end
  end
  commands.push(_INTL("2 Dupe Tickets for 1 Gold Milage")) if duped
  commands.push(_INTL("Cancel"))

  helpwindow = Window_UnformattedTextPokemon.new("")
  helpwindow.visible = false
  cmd = UIHelper.pbShowCommands(helpwindow,"You can exchange tickets for various things.",commands) {}
  Input.update
  selectedCommander = commands[cmd]
  case selectedCommander
  when "My Tickets"
    ticketbag = POSSIBLE_TICKETS.map { |b| "#{b}: #{counts[b]}" }.join("\n")
    pbMessage(_INTL("You have the following tickets:\n#{ticketbag}"))
  when "A TicketA for 1 HexSex"
    return true
  when "A TicketB for 1 ZinniaPlush"
    return true
  when "A TicketC for 1 EleggFigurine"
    return true
  when "2 Dupe Tickets for 1 Gold Milage"
    counts.each do |str, count|
      if count > 1 && str != "GoldMilageTicket"
        $PokemonGlobal.ticketStorage.delete_at($PokemonGlobal.ticketStorage.index(str))
        $PokemonGlobal.ticketStorage.delete_at($PokemonGlobal.ticketStorage.index(str))
        $PokemonGlobal.ticketStorage.push("GoldMilageTicket")
        break
      end
    end
    return true
  else
    return false
  end
end

def goldTicketExchangeNPC
end